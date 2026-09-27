extends Control
# ------------------------------------------------------------------
# IronboundAtmosphere
# The Ironbound Isles' effects for the hero picker. ZoneAtmosphere
# creates one of these (and frees it again with the rest of its
# children) when Kaelen Varr's background is shown, then calls build().
# Purely visual: never takes input, never touches game state.
#
#   - the fires and lit windows on the ships, the docks and the castle
#     flicker, each on its own rhythm
#   - the lighthouse lamp pulses and sweeps a beam across the bay; the
#     small lighthouse on the rocks glows too
#   - the sea rolls and its foam glints
#   - rain slants down across the whole scene
#   - water drips off the sword's edge
#   - the tentacles on his face writhe, twitching every few seconds
#   - tentacles like his rise out of the dark behind him, sway, and
#     sink back out of sight
#
# Positions of art features are fractions (0..1) of the background
# image, like ZoneAtmosphere's own.
# ------------------------------------------------------------------

const BG_SHADER := preload("res://shaders/ironbound_background.gdshader")

# The painted stats frame (UV x0, y0, x1, y1) - kept still.
const FRAME_CALM_RECT := Vector4(0.02, 0.63, 0.47, 0.94)

# The bay (two rects, UV).
const SEA_RECT_A := Vector4(0.49, 0.50, 0.87, 0.80)
const SEA_RECT_B := Vector4(0.77, 0.66, 0.87, 0.97)

# The tentacles hanging from his face, and where they're rooted.
const FACE_RECT := Vector4(0.225, 0.14, 0.305, 0.33)
const FACE_ROOT_Y := 0.155
const TWITCH_EVERY := Vector2(3.5, 7.5)

# Tentacles in the dark behind him: the region, the line they rise from
# (just under the frame's top edge, so they come up from behind it), and
# each one's base x and reach (UV).
const DEEP_RECT := Vector4(0.0, 0.0, 0.475, 0.66)
const DEEP_FLOOR := 0.645
const DEEP_X := [0.022, 0.065, 0.105, 0.405, 0.438, 0.468]
const DEEP_REACH := [0.5, 0.62, 0.42, 0.58, 0.48, 0.64]

# Fires (fast, ragged flicker) and lit windows (slow, gentle), by image
# UV and glow radius in source pixels.
const FIRES := [
	{"uv": Vector2(0.5514, 0.6642), "r": 42.0},   # torch on the left dock
	{"uv": Vector2(0.9809, 0.7917), "r": 58.0},   # brazier, bottom right
	{"uv": Vector2(0.8935, 0.4113), "r": 26.0},   # fire below the castle
	{"uv": Vector2(0.7895, 0.6429), "r": 36.0},   # ship's stern
	{"uv": Vector2(0.6860, 0.5313), "r": 40.0},   # the house-ship's hall
]
const WINDOWS := [
	Vector2(0.7428, 0.2519), Vector2(0.7984, 0.3826), Vector2(0.8600, 0.3188),
	Vector2(0.9282, 0.3241), Vector2(0.9809, 0.3188), Vector2(0.9510, 0.2444),
	Vector2(0.9576, 0.1987), Vector2(0.8696, 0.1275), Vector2(0.6669, 0.4995),
]
const FIRE_COLOR := Color(1.0, 0.55, 0.18)
const WINDOW_COLOR := Color(1.0, 0.72, 0.38)

const LIGHTHOUSE_UV := Vector2(0.8541, 0.0680)
const SMALL_LIGHTHOUSE_UV := Vector2(0.5084, 0.4782)
const BEAM_LENGTH := 330.0     # px at 1280-wide
const BEAM_PERIOD := 9.0

# Where water drips off the sword's lower edge (image UV), hilt to tip.
const DRIP_ORIGINS := [
	Vector2(0.1824, 0.5367), Vector2(0.2063, 0.5600), Vector2(0.2225, 0.5749),
	Vector2(0.2362, 0.5866), Vector2(0.2584, 0.6004), Vector2(0.2811, 0.6121),
	Vector2(0.3038, 0.6196),
]
const DRIP_WAIT := Vector2(0.8, 3.5)
const DRIP_FORM_TIME := Vector2(0.5, 1.2)
const DRIP_FALL := Vector2(40.0, 90.0)   # source px before it fades
const DRIP_COLOR := Color(0.78, 0.88, 0.95)

# Rain: per layer, how many streaks, their length and speed (px at
# 1280-wide), and opacity. The far layer is thinner and fainter.
const RAIN_LAYERS := [
	{"count": 120, "length": 11.0, "speed": 820.0, "alpha": 0.13, "width": 1.0},
	{"count": 55, "length": 24.0, "speed": 1250.0, "alpha": 0.22, "width": 1.4},
]
const RAIN_SLANT := Vector2(-0.22, 1.0)
const RAIN_COLOR := Color(0.75, 0.85, 0.95)

var _atm: Control
var _background: TextureRect
var _bg_mat: ShaderMaterial
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0     # image scale
var _k := 1.0     # tuned-at-1280 scale

var _fires: Array[Dictionary] = []
var _windows: Array[Dictionary] = []
var _lighthouse: TextureRect
var _small_lighthouse: TextureRect
var _beam: Control
var _drop_tex: Texture2D
var _drips: Array[Dictionary] = []
var _rain: Array[Dictionary] = []
var _twitch := 0.0
var _next_twitch := 0.0
var _fx_layer: Control


## `atm` is the owning ZoneAtmosphere - its image mapping helpers are
## reused so positions line up exactly with its own effects.
func build(atm: Control, background: TextureRect) -> void:
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_k = _s / 0.7656
	var tex_size := _background.texture.get_size()

	# Sea, face tentacles and the tentacles in the deep, on the art itself.
	_bg_mat = ShaderMaterial.new()
	_bg_mat.shader = BG_SHADER
	_bg_mat.set_shader_parameter("aspect", tex_size.x / tex_size.y)
	_bg_mat.set_shader_parameter("calm_rect", FRAME_CALM_RECT)
	_bg_mat.set_shader_parameter("sea_rect_a", SEA_RECT_A)
	_bg_mat.set_shader_parameter("sea_rect_b", SEA_RECT_B)
	_bg_mat.set_shader_parameter("face_rect", FACE_RECT)
	_bg_mat.set_shader_parameter("face_root_y", FACE_ROOT_Y)
	_bg_mat.set_shader_parameter("deep_rect", DEEP_RECT)
	_bg_mat.set_shader_parameter("deep_floor", DEEP_FLOOR)
	_bg_mat.set_shader_parameter("deep_x", PackedFloat32Array(DEEP_X))
	_bg_mat.set_shader_parameter("deep_reach", PackedFloat32Array(DEEP_REACH))
	_bg_mat.set_shader_parameter("twitch", 0.0)
	_background.material = _bg_mat
	_next_twitch = _rng.randf_range(1.5, 3.5)

	# Fires and windows.
	var glow_tex: Texture2D = _atm._radial(64,
		PackedFloat32Array([0.0, 0.22, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.75), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.0)]))
	_fires.clear()
	for f in FIRES:
		var node := _glow(glow_tex, f["uv"], f["r"] * _s * 2.6, FIRE_COLOR)
		_fires.append({"node": node, "phase": _rng.randf() * TAU, "f1": _rng.randf_range(7.0, 11.0), "f2": _rng.randf_range(15.0, 23.0), "dip": 0.0})
	_windows.clear()
	for uv in WINDOWS:
		var node := _glow(glow_tex, uv, 34.0 * _s, WINDOW_COLOR)
		_windows.append({"node": node, "phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.6, 1.4)})

	# Lighthouses: the beam first, so the lamp's glow sits over its root.
	_beam = Control.new()
	_beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_beam.set_anchors_preset(Control.PRESET_FULL_RECT)
	_beam.material = _atm._additive()
	_beam.draw.connect(_draw_beam)
	add_child(_beam)
	_lighthouse = _glow(glow_tex, LIGHTHOUSE_UV, 120.0 * _s, Color(1.0, 0.85, 0.55))
	_small_lighthouse = _glow(glow_tex, SMALL_LIGHTHOUSE_UV, 60.0 * _s, Color(1.0, 0.8, 0.5))

	# Drips and rain, over everything else.
	_drop_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.55, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.0)]))
	_drips.clear()
	for origin in DRIP_ORIGINS:
		_drips.append({"origin": _atm._image_to_local(origin), "state": "wait", "t": _rng.randf_range(0.1, DRIP_WAIT.y)})
	var view := get_viewport_rect().size
	_rain.clear()
	for li in RAIN_LAYERS.size():
		for i in int(RAIN_LAYERS[li]["count"]):
			_rain.append({"layer": li, "pos": Vector2(_rng.randf() * view.x * 1.3, _rng.randf() * view.y), "speed_mul": _rng.randf_range(0.85, 1.15)})
	_fx_layer = Control.new()
	_fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fx_layer.draw.connect(_draw_fx)
	add_child(_fx_layer)

	set_process(true)


func _glow(tex: Texture2D, uv: Vector2, diameter: float, color: Color) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.size = Vector2.ONE * diameter
	r.position = _atm._image_to_local(uv) - r.size * 0.5
	r.pivot_offset = r.size * 0.5
	r.material = _atm._additive()
	r.self_modulate = color
	add_child(r)
	return r


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_lights(delta)
	_update_twitch(delta)
	_update_drips(delta)
	_update_rain(delta)
	_beam.queue_redraw()
	_fx_layer.queue_redraw()


func _update_lights(delta: float) -> void:
	for f in _fires:
		# Now and then a gust makes the flame gutter.
		if _rng.randf() < delta * 0.25:
			f["dip"] = 1.0
		f["dip"] = move_toward(f["dip"], 0.0, delta * 3.5)
		var flick: float = 0.78 + 0.14 * sin(_time * f["f1"] + f["phase"]) + 0.08 * sin(_time * f["f2"] + f["phase"] * 1.7)
		var b: float = flick * (1.0 - 0.45 * f["dip"])
		f["node"].modulate = Color(b, b, b, 1.0)
		f["node"].scale = Vector2.ONE * (0.94 + 0.08 * flick)
	for w in _windows:
		var b: float = 0.55 + 0.2 * sin(_time * w["speed"] + w["phase"]) + 0.05 * sin(_time * 7.0 + w["phase"])
		w["node"].modulate = Color(b, b, b, 1.0)
	# The big lamp brightens as the beam swings toward the viewer.
	var facing := 0.5 + 0.5 * sin(_time * TAU / BEAM_PERIOD)
	var lamp := 0.7 + 0.5 * facing
	_lighthouse.modulate = Color(lamp, lamp, lamp, 1.0)
	_lighthouse.scale = Vector2.ONE * (0.9 + 0.25 * facing)
	var small := 0.6 + 0.25 * sin(_time * 1.7)
	_small_lighthouse.modulate = Color(small, small, small, 1.0)


## The lighthouse beam: a long soft cone turning around the lamp, seen
## from the side - it sweeps left and right, and is shortest and
## brightest as it swings round toward the viewer.
func _draw_beam() -> void:
	var origin: Vector2 = _atm._image_to_local(LIGHTHOUSE_UV)
	var angle := _time * TAU / BEAM_PERIOD
	for beam_i in 2:
		var a := angle + PI * beam_i
		var sweep := cos(a)                      # -1 left .. 1 right
		var toward := sin(a)                     # > 0: turned toward us
		var length := BEAM_LENGTH * _k * (0.35 + 0.65 * absf(sweep))
		var dir := Vector2(sweep, 0.12 * toward).normalized()
		var spread := 0.1 + 0.06 * (1.0 - absf(sweep))
		var alpha := 0.1 + 0.12 * maxf(toward, 0.0)
		var n := dir.orthogonal()
		var tip := origin + dir * length
		var col := Color(1.0, 0.88, 0.6, alpha)
		var clear := Color(1.0, 0.88, 0.6, 0.0)
		var half := n * length * spread
		# Solid down the middle, clear at the edges and the far end.
		_beam.draw_polygon(PackedVector2Array([origin, tip + half, tip]), PackedColorArray([col, clear, clear]))
		_beam.draw_polygon(PackedVector2Array([origin, tip, tip - half]), PackedColorArray([col, clear, clear]))


func _update_twitch(delta: float) -> void:
	_next_twitch -= delta
	if _next_twitch <= 0.0:
		_twitch = 1.0
		_next_twitch = _rng.randf_range(TWITCH_EVERY.x, TWITCH_EVERY.y)
	_twitch = move_toward(_twitch, 0.0, delta * 1.3)
	# Sharp jerk, slow relax.
	_bg_mat.set_shader_parameter("twitch", _twitch * _twitch)


func _update_drips(delta: float) -> void:
	for d in _drips:
		match d["state"]:
			"wait":
				d["t"] -= delta
				if d["t"] <= 0.0:
					d["state"] = "form"
					d["t"] = 0.0
					d["form_time"] = _rng.randf_range(DRIP_FORM_TIME.x, DRIP_FORM_TIME.y)
					d["r"] = _rng.randf_range(1.3, 2.2) * _k
			"form":
				d["t"] += delta
				if d["t"] >= d["form_time"]:
					d["state"] = "fall"
					d["dist"] = 0.0
					d["v"] = 0.0
					d["fall_max"] = _rng.randf_range(DRIP_FALL.x, DRIP_FALL.y) * _s
			"fall":
				d["v"] += 360.0 * _k * delta
				d["dist"] += d["v"] * delta
				if d["dist"] >= d["fall_max"]:
					d["state"] = "wait"
					d["t"] = _rng.randf_range(DRIP_WAIT.x, DRIP_WAIT.y)


func _update_rain(delta: float) -> void:
	var view := get_viewport_rect().size
	var dir := RAIN_SLANT.normalized()
	for r in _rain:
		var layer: Dictionary = RAIN_LAYERS[r["layer"]]
		r["pos"] += dir * float(layer["speed"]) * _k * float(r["speed_mul"]) * delta
		if r["pos"].y > view.y + 30.0:
			r["pos"] = Vector2(_rng.randf() * view.x * 1.3, -30.0 - _rng.randf() * 60.0)


func _draw_fx() -> void:
	var dir := RAIN_SLANT.normalized()
	for r in _rain:
		var layer: Dictionary = RAIN_LAYERS[r["layer"]]
		var p: Vector2 = r["pos"]
		_fx_layer.draw_line(p, p - dir * float(layer["length"]) * _k, Color(RAIN_COLOR, layer["alpha"]), float(layer["width"]), true)
	for d in _drips:
		if d["state"] == "wait":
			continue
		var origin: Vector2 = d["origin"]
		var r: float = d["r"]
		if d["state"] == "form":
			# Swells on the edge, still clinging by a thin thread.
			var g: float = smoothstep(0.0, 1.0, d["t"] / d["form_time"])
			var center := origin + Vector2(0.0, r * 1.5 * g)
			var sz := Vector2(2.0 * r * g, 2.0 * r * g * (1.0 + 0.4 * g))
			_fx_layer.draw_line(origin, center, Color(DRIP_COLOR, 0.45 * g), maxf(r * 0.5 * g, 0.5))
			_fx_layer.draw_texture_rect(_drop_tex, Rect2(center - sz * 0.5, sz), false, Color(DRIP_COLOR, 0.85))
		else:
			var dist: float = d["dist"]
			var a: float = 0.85 * (1.0 - smoothstep(0.6, 1.0, dist / d["fall_max"]))
			var center := origin + Vector2(0.0, r * 1.5 + dist)
			var stretch := 1.0 + minf(d["v"] / 150.0, 1.5)
			var sz := Vector2(2.0 * r * 0.85, 2.0 * r * stretch)
			_fx_layer.draw_line(center - Vector2(0.0, d["v"] * 0.05), center, Color(DRIP_COLOR, a * 0.35), maxf(r * 0.6, 0.5))
			_fx_layer.draw_texture_rect(_drop_tex, Rect2(center - sz * 0.5, sz), false, Color(DRIP_COLOR, a))
