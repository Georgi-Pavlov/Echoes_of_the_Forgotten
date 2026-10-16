extends Control
# ------------------------------------------------------------------
# LastEmpressAtmosphere
# The Drowned Empire's effects for The Last Empress's and Dreadlure's hero
# pickers (build()'s `hero` picks which half-left art is animated; the
# drowned city on the right runs the same effects for both).
# ZoneAtmosphere creates one of these (and frees it again with the rest
# of its children) when her background is shown, then calls build().
# Purely visual: never takes input, never touches game state.
#
# The Last Empress (left half):
#   - she slowly breathes (a soft swell of her body, the stats frame kept
#     still)
#   - the teal jewels in her crown, armour and the frame's emblem glow,
#     each on its own rhythm, flaring now and then
#   - bubbles rise through the dark water around her
#
# The drowned city (right half):
#   - shafts of light slant down from the surface, swaying
#   - the jellyfish pulse and bob, the sharks drift through the water
#     (the painted creatures themselves move - see
#     last_empress_background.gdshader)
#   - schools of fish sweep across
#   - the palace windows flicker
#   - fine marine snow drifts slowly down over everything
#
# Positions of art features are given in pixels of the 1665x944 source
# image, so they stay on target whatever the screen size.
# ------------------------------------------------------------------

const BG_SHADER := preload("res://shaders/last_empress_background.gdshader")
const SHAFTS_SHADER := preload("res://shaders/light_shafts.gdshader")

# The painted stats frame (UV x0, y0, x1, y1) - kept still, and kept clear of
# bubbles and snow.
const FRAME_CALM_RECT := Vector4(0.008, 0.635, 0.475, 0.965)

# Breathing: centred on her torso.
const BREATHE_CENTER_UV := Vector2(0.312, 0.4)
const BREATHE_RADIUS := 0.3             # in units of image height
const BREATHE_AMOUNT := 0.02
const BREATHE_PERIOD := 5.0

# The painted creatures that move: x, y (source px), radius (units of image
# height), amplitude, speed (cycles/s).
const JELLYFISH := [
	{"px": Vector2(914.0, 204.0), "radius": 0.06, "amp": 0.05, "speed": 0.42},
	{"px": Vector2(859.0, 457.0), "radius": 0.07, "amp": 0.05, "speed": 0.36},
	{"px": Vector2(1003.0, 571.0), "radius": 0.06, "amp": 0.05, "speed": 0.45},
	{"px": Vector2(1128.0, 688.0), "radius": 0.06, "amp": 0.05, "speed": 0.4},
	{"px": Vector2(1476.0, 161.0), "radius": 0.06, "amp": 0.05, "speed": 0.38},
	{"px": Vector2(1551.0, 252.0), "radius": 0.07, "amp": 0.05, "speed": 0.44},
]
const SHARKS := [
	{"px": Vector2(1388.0, 126.0), "radius": 0.12, "amp": 0.005, "speed": 0.1},
	{"px": Vector2(1456.0, 62.0), "radius": 0.1, "amp": 0.004, "speed": 0.08},
]
const JELLY_COLOR := Color(0.45, 0.8, 1.0)

# The teal jewels: where they sit (source px) and the glow's diameter.
const GEMS := [
	{"px": Vector2(611.0, 94.0), "d": 34.0},    # big crown jewel
	{"px": Vector2(463.0, 85.0), "d": 20.0},
	{"px": Vector2(524.0, 100.0), "d": 20.0},
	{"px": Vector2(557.0, 92.0), "d": 20.0},
	{"px": Vector2(504.0, 186.0), "d": 22.0},   # earring
	{"px": Vector2(438.0, 303.0), "d": 22.0},   # shoulder
	{"px": Vector2(461.0, 290.0), "d": 18.0},
	{"px": Vector2(567.0, 322.0), "d": 20.0},   # necklace
	{"px": Vector2(594.0, 427.0), "d": 22.0},   # chest
	{"px": Vector2(587.0, 451.0), "d": 16.0},
	{"px": Vector2(526.0, 582.0), "d": 26.0},   # waist
	{"px": Vector2(559.0, 561.0), "d": 18.0},
	{"px": Vector2(397.0, 587.0), "d": 40.0},   # the frame's emblem
]
const GEM_COLOR := Color(0.4, 1.0, 0.9)
const GEM_FLARE_EVERY := Vector2(2.5, 6.0)

# --- Dreadlure (the same city on the right, a different creature on the left) ---
const DREADLURE_FRAME_CALM_RECT := Vector4(0.008, 0.62, 0.478, 0.965)
const DREADLURE_BREATHE_CENTER_UV := Vector2(0.18, 0.4)
const DREADLURE_JELLYFISH := [
	{"px": Vector2(912.0, 208.0), "radius": 0.06, "amp": 0.05, "speed": 0.42},
	{"px": Vector2(862.0, 452.0), "radius": 0.07, "amp": 0.05, "speed": 0.36},
	{"px": Vector2(1000.0, 566.0), "radius": 0.06, "amp": 0.05, "speed": 0.45},
	{"px": Vector2(1120.0, 678.0), "radius": 0.05, "amp": 0.05, "speed": 0.4},
	{"px": Vector2(1467.0, 155.0), "radius": 0.06, "amp": 0.05, "speed": 0.38},
	{"px": Vector2(1545.0, 265.0), "radius": 0.07, "amp": 0.05, "speed": 0.44},
]
const DREADLURE_SHARKS := [
	{"px": Vector2(1395.0, 125.0), "radius": 0.12, "amp": 0.005, "speed": 0.1},
	{"px": Vector2(1440.0, 60.0), "radius": 0.1, "amp": 0.004, "speed": 0.08},
]
# The bioluminescent lure and the glowing tips of its tendrils (a wide, faint
# halo first), then the frame's emblem.
const DREADLURE_GEMS := [
	{"px": Vector2(772.0, 157.0), "d": 150.0, "halo": true},
	{"px": Vector2(772.0, 157.0), "d": 46.0},
	{"px": Vector2(747.0, 481.0), "d": 22.0},
	{"px": Vector2(798.0, 247.0), "d": 22.0},
	{"px": Vector2(722.0, 200.0), "d": 16.0},
	{"px": Vector2(397.0, 600.0), "d": 40.0},   # the frame's emblem
]
const DREADLURE_GEM_COLOR := Color(0.35, 0.82, 1.0)
const DREADLURE_WINDOWS := [
	Vector2(1204.0, 250.0), Vector2(1170.0, 270.0), Vector2(1205.0, 290.0),
	Vector2(1170.0, 330.0), Vector2(1202.0, 330.0), Vector2(1205.0, 350.0),
	Vector2(1205.0, 400.0), Vector2(1170.0, 400.0), Vector2(1205.0, 625.0),
]

# The palace's lit windows.
const WINDOWS := [
	Vector2(1175.0, 268.0), Vector2(1210.0, 264.0), Vector2(1243.0, 270.0),
	Vector2(1209.0, 300.0), Vector2(1174.0, 345.0), Vector2(1209.0, 341.0),
	Vector2(1241.0, 345.0), Vector2(1173.0, 402.0), Vector2(1210.0, 400.0),
	Vector2(1241.0, 398.0),
]
const WINDOW_COLOR := Color(1.0, 0.76, 0.42)

# Light from the surface (a rect in image UV, and where in its own UV the
# light comes from).
const SHAFTS_RECT_UV := Rect2(0.5, 0.0, 0.5, 0.85)
const SHAFTS_ORIGIN := Vector2(0.49, -0.06)
const SHAFT_COLOR := Color(0.55, 0.82, 1.0)

# Bubbles rise through the left half, born low and above the frame.
const BUBBLE_SPAWN_UV := Rect2(0.02, 0.45, 0.44, 0.17)
const BUBBLE_TOP_UV := 0.02
const BUBBLE_COUNT := 30

# Schools of fish: the region each swims in (image UV), how many, the
# speed (px/s), the size (px) and which way.
const SCHOOLS := [
	{"rect": Rect2(0.56, 0.2, 0.42, 0.14), "count": 9, "speed": 26.0, "size": 8.0, "dir": -1.0},
	{"rect": Rect2(0.52, 0.5, 0.45, 0.14), "count": 9, "speed": 20.0, "size": 7.0, "dir": 1.0},
	{"rect": Rect2(0.56, 0.74, 0.42, 0.1), "count": 7, "speed": 23.0, "size": 8.0, "dir": -1.0},
]
const FISH_COLORS := [Color(0.6, 0.76, 0.88), Color(0.5, 0.68, 0.82), Color(0.9, 0.6, 0.38)]

# Marine snow.
const SNOW_COUNT := 70

var _atm: Control
# Per-hero art features (see build()).
var _frame_rect := FRAME_CALM_RECT
var _breathe_center := BREATHE_CENTER_UV
var _jellyfish: Array = JELLYFISH
var _sharks: Array = SHARKS
var _gem_defs: Array = GEMS
var _gem_color := GEM_COLOR
var _window_pts: Array = WINDOWS
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0                # image scale (screen px per source px)
var _origin := Vector2.ZERO  # where the source image's top-left lands
var _tex_size := Vector2.ONE
var _start_ticks := 0.0

var _glow_tex: Texture2D
var _dot_tex: Texture2D

var _jelly_glows: Array[Dictionary] = []
var _gems: Array[Dictionary] = []
var _windows: Array[Dictionary] = []

var _fish_layer: Control
var _schools: Array[Dictionary] = []

var _bubble_layer: Control
var _bubbles: Array[Dictionary] = []
var _bubble_accum := 0.0

var _snow_layer: Control
var _snow: Array[Dictionary] = []


## `atm` is the owning ZoneAtmosphere - its image mapping helpers are
## reused so positions line up exactly with its own effects.
func build(atm: Control, background: TextureRect, hero: String = "last_empress") -> void:
	if hero == "dreadlure":
		_frame_rect = DREADLURE_FRAME_CALM_RECT
		_breathe_center = DREADLURE_BREATHE_CENTER_UV
		_jellyfish = DREADLURE_JELLYFISH
		_sharks = DREADLURE_SHARKS
		_gem_defs = DREADLURE_GEMS
		_gem_color = DREADLURE_GEM_COLOR
		_window_pts = DREADLURE_WINDOWS
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_origin = _atm._image_to_local(Vector2.ZERO)
	_tex_size = _background.texture.get_size()
	_start_ticks = Time.get_ticks_msec() / 1000.0

	# Her breathing and the painted jellyfish and sharks moving, straight on
	# the background texture.
	var mat := ShaderMaterial.new()
	mat.shader = BG_SHADER
	mat.set_shader_parameter("calm_rect", _frame_rect)
	mat.set_shader_parameter("aspect", _tex_size.x / _tex_size.y)
	mat.set_shader_parameter("breathe_center", _breathe_center)
	mat.set_shader_parameter("breathe_radius", BREATHE_RADIUS)
	mat.set_shader_parameter("breathe_amount", BREATHE_AMOUNT)
	mat.set_shader_parameter("breathe_period", BREATHE_PERIOD)
	var cx := PackedFloat32Array()
	var cy := PackedFloat32Array()
	var radius := PackedFloat32Array()
	var kind := PackedFloat32Array()
	var phase := PackedFloat32Array()
	var amp := PackedFloat32Array()
	var speed := PackedFloat32Array()
	var jelly_phases: Array[float] = []
	for j in _jellyfish:
		var uv: Vector2 = j["px"] / _tex_size
		cx.append(uv.x)
		cy.append(uv.y)
		radius.append(float(j["radius"]))
		kind.append(0.0)
		var ph := _rng.randf()
		phase.append(ph)
		jelly_phases.append(ph)
		amp.append(float(j["amp"]))
		speed.append(float(j["speed"]))
	for sh in _sharks:
		var uv: Vector2 = sh["px"] / _tex_size
		cx.append(uv.x)
		cy.append(uv.y)
		radius.append(float(sh["radius"]))
		kind.append(1.0)
		phase.append(_rng.randf())
		amp.append(float(sh["amp"]))
		speed.append(float(sh["speed"]))
	mat.set_shader_parameter("region_count", cx.size())
	# The arrays are fixed-size in the shader - pad them out.
	mat.set_shader_parameter("region_cx", _padded(cx))
	mat.set_shader_parameter("region_cy", _padded(cy))
	mat.set_shader_parameter("region_radius", _padded(radius))
	mat.set_shader_parameter("region_kind", _padded(kind))
	mat.set_shader_parameter("region_phase", _padded(phase))
	mat.set_shader_parameter("region_amp", _padded(amp))
	mat.set_shader_parameter("region_speed", _padded(speed))
	_background.material = mat

	_glow_tex = _atm._radial(128,
		PackedFloat32Array([0.0, 0.12, 0.35, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0.22), Color(1, 1, 1, 0.0)]))
	_dot_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.25, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))

	# Light from the surface, behind everything else.
	var sa: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.position)
	var sb: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.end)
	var shafts_mat := ShaderMaterial.new()
	shafts_mat.shader = SHAFTS_SHADER
	shafts_mat.set_shader_parameter("origin", SHAFTS_ORIGIN)
	shafts_mat.set_shader_parameter("shaft_color", SHAFT_COLOR)
	shafts_mat.set_shader_parameter("intensity", 0.2)
	shafts_mat.set_shader_parameter("spread", 0.8)
	shafts_mat.set_shader_parameter("reach", 1.4)
	shafts_mat.set_shader_parameter("sway", 0.05)
	shafts_mat.set_shader_parameter("aspect", (sb.x - sa.x) / (sb.y - sa.y))
	var shafts := ColorRect.new()
	shafts.material = shafts_mat
	shafts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shafts.position = sa
	shafts.size = sb - sa
	add_child(shafts)

	# Fish sweep across the city.
	_schools.clear()
	for s in SCHOOLS:
		var fish: Array[Dictionary] = []
		for i in int(s["count"]):
			fish.append({
				"off": Vector2(_rng.randf_range(0.0, 1.0), _rng.randf_range(0.0, 1.0)),
				"phase": _rng.randf() * TAU,
				"wag": _rng.randf_range(5.0, 9.0),
				"color": FISH_COLORS[_rng.randi() % FISH_COLORS.size()],
				"scale": _rng.randf_range(0.8, 1.2),
			})
		_schools.append({"def": s, "fish": fish, "pos": _rng.randf()})
	_fish_layer = _new_layer(false)
	_fish_layer.draw.connect(_draw_fish)

	# The jellyfish's own glow, pulsing with their bells.
	_jelly_glows.clear()
	for i in _jellyfish.size():
		var j: Dictionary = _jellyfish[i]
		_jelly_glows.append({
			"node": _glow(j["px"], 54.0, JELLY_COLOR),
			"phase": jelly_phases[i], "speed": float(j["speed"]),
		})

	# The palace windows.
	_windows.clear()
	for px in _window_pts:
		_windows.append({
			"node": _glow(px, 26.0, WINDOW_COLOR),
			"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.5, 1.3),
			"base": _rng.randf_range(0.5, 0.75),
		})

	# The jewels.
	_gems.clear()
	for g in _gem_defs:
		_gems.append({
			"node": _glow(g["px"], float(g["d"]) * 1.8, _gem_color),
			"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.6, 1.4),
			"flare": 0.0, "next": _rng.randf_range(1.0, GEM_FLARE_EVERY.y),
			"halo": bool(g.get("halo", false)),
		})

	# Bubbles and marine snow, over everything.
	_bubbles.clear()
	_bubble_layer = _new_layer(false)
	_bubble_layer.draw.connect(_draw_bubbles)
	for i in 240:
		_update_bubbles(1.0 / 30.0)
	_snow.clear()
	for i in SNOW_COUNT:
		_snow.append(_new_snow(true))
	_snow_layer = _new_layer(true)
	_snow_layer.draw.connect(_draw_snow)

	set_process(true)


# --- helpers --------------------------------------------------------

func _padded(values: PackedFloat32Array) -> PackedFloat32Array:
	var out := values.duplicate()
	while out.size() < 10:
		out.append(0.0)
	return out


## Source-image pixels -> this node's local coordinates.
func _pl(p: Vector2) -> Vector2:
	return _origin + p * _s


func _glow(px: Vector2, diameter: float, color: Color) -> TextureRect:
	var r := TextureRect.new()
	r.texture = _glow_tex
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.size = Vector2.ONE * diameter * _s
	r.position = _pl(px) - r.size * 0.5
	r.pivot_offset = r.size * 0.5
	r.material = _atm._additive()
	r.self_modulate = color
	add_child(r)
	return r


func _new_layer(additive: bool) -> Control:
	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	if additive:
		layer.material = _atm._additive()
	add_child(layer)
	return layer


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_glows(delta)
	_update_schools(delta)
	_update_bubbles(delta)
	_update_snow(delta)
	_fish_layer.queue_redraw()
	_bubble_layer.queue_redraw()
	_snow_layer.queue_redraw()


func _update_glows(delta: float) -> void:
	# The jellyfish glow swells as the bell does (the shader's own clock).
	var now := Time.get_ticks_msec() / 1000.0
	for j in _jelly_glows:
		var pulse := sin((now * float(j["speed"]) + float(j["phase"])) * TAU)
		var b: float = 0.3 + 0.2 * pulse
		j["node"].modulate = Color(b, b, b, 1.0)
		j["node"].scale = Vector2.ONE * (1.0 + 0.12 * pulse)
	for w in _windows:
		var b: float = float(w["base"]) + 0.15 * sin(_time * float(w["speed"]) + float(w["phase"])) + 0.05 * sin(_time * 6.0 + float(w["phase"]))
		w["node"].modulate = Color(b, b, b, 1.0)
	for g in _gems:
		g["next"] = float(g["next"]) - delta
		if g["next"] <= 0.0:
			g["flare"] = 1.0
			g["next"] = _rng.randf_range(GEM_FLARE_EVERY.x, GEM_FLARE_EVERY.y)
		g["flare"] = move_toward(float(g["flare"]), 0.0, delta / 0.9)
		var flare: float = float(g["flare"]) * float(g["flare"])
		var b: float = 0.35 + 0.15 * sin(_time * float(g["speed"]) + float(g["phase"])) + 0.5 * flare
		# A wide halo stays faint, only swelling as its light flares.
		if g["halo"]:
			b *= 0.45
		g["node"].modulate = Color(b, b, b, 1.0)
		g["node"].scale = Vector2.ONE * (0.9 + 0.1 * sin(_time * float(g["speed"]) + float(g["phase"])) + 0.4 * flare)


func _update_schools(delta: float) -> void:
	for sc in _schools:
		var def: Dictionary = sc["def"]
		var rect: Rect2 = def["rect"]
		var width: float = rect.size.x * _tex_size.x
		sc["pos"] = fposmod(float(sc["pos"]) + float(def["dir"]) * float(def["speed"]) * delta / width, 1.0)


func _new_snow(anywhere: bool) -> Dictionary:
	return {
		"uv": Vector2(_rng.randf(), _rng.randf() if anywhere else -0.02),
		"fall": _rng.randf_range(5.0, 14.0), "sway": _rng.randf_range(4.0, 12.0),
		"sway_freq": _rng.randf_range(0.2, 0.6), "phase": _rng.randf() * TAU,
		"size": _rng.randf_range(0.8, 2.0), "alpha": _rng.randf_range(0.18, 0.4),
	}


func _update_snow(delta: float) -> void:
	for i in _snow.size():
		var p: Dictionary = _snow[i]
		var uv: Vector2 = p["uv"]
		uv.y += float(p["fall"]) * delta / _tex_size.y
		uv.x += sin(_time * float(p["sway_freq"]) + float(p["phase"])) * float(p["sway"]) * delta / _tex_size.x
		p["uv"] = uv
		if uv.y > 1.02:
			_snow[i] = _new_snow(false)


func _update_bubbles(delta: float) -> void:
	_bubble_accum += delta * 2.4
	while _bubble_accum >= 1.0 and _bubbles.size() < BUBBLE_COUNT:
		_bubble_accum -= 1.0
		var uv := BUBBLE_SPAWN_UV.position + Vector2(_rng.randf(), _rng.randf()) * BUBBLE_SPAWN_UV.size
		_bubbles.append({
			"px": uv * _tex_size, "rise": _rng.randf_range(22.0, 48.0),
			"size": _rng.randf_range(2.0, 6.0), "phase": _rng.randf() * TAU,
			"wobble": _rng.randf_range(4.0, 12.0), "age": 0.0,
			"top": _rng.randf_range(BUBBLE_TOP_UV, 0.3) * _tex_size.y, "pop": -1.0,
		})
	_bubble_accum = minf(_bubble_accum, 1.0)
	for i in range(_bubbles.size() - 1, -1, -1):
		var b: Dictionary = _bubbles[i]
		b["age"] += delta
		if float(b["pop"]) >= 0.0:
			b["pop"] += delta
			if b["pop"] > 0.18:
				_bubbles.remove_at(i)
			continue
		var p: Vector2 = b["px"]
		p.y -= float(b["rise"]) * delta
		b["px"] = p
		if p.y <= float(b["top"]):
			b["pop"] = 0.0


# --- drawing --------------------------------------------------------

func _draw_fish() -> void:
	for sc in _schools:
		var def: Dictionary = sc["def"]
		var rect: Rect2 = def["rect"]
		var dir: float = def["dir"]
		var size: float = float(def["size"])
		for f in sc["fish"]:
			var off: Vector2 = f["off"]
			# Spread along the school's own length, trailing the leader.
			var u := fposmod(float(sc["pos"]) + off.x * 0.35 * -dir, 1.0)
			var x := (rect.position.x + u * rect.size.x) * _tex_size.x
			var y := (rect.position.y + off.y * rect.size.y) * _tex_size.y + sin(_time * 1.3 + float(f["phase"])) * 6.0
			# Fade in and out at the region's edges.
			var edge := smoothstep(0.0, 0.1, u) * (1.0 - smoothstep(0.9, 1.0, u))
			var c: Color = f["color"]
			var length := size * _s * float(f["scale"])
			var p := _pl(Vector2(x, y))
			var wag := sin(_time * float(f["wag"]) + float(f["phase"])) * 0.25 * length
			var head := p + Vector2(dir * length * 0.5, 0.0)
			var tail := p - Vector2(dir * length * 0.5, 0.0)
			# A slim body and a forked tail.
			_fish_layer.draw_colored_polygon(PackedVector2Array([
				head, p + Vector2(0.0, -length * 0.2), tail + Vector2(0.0, wag * 0.3),
				p + Vector2(0.0, length * 0.2)]), Color(c, 0.55 * edge))
			_fish_layer.draw_colored_polygon(PackedVector2Array([
				tail, tail - Vector2(dir * length * 0.35, -length * 0.25 + wag), tail - Vector2(dir * length * 0.35, length * 0.25 + wag)]), Color(c, 0.5 * edge))


func _draw_bubbles() -> void:
	for b in _bubbles:
		var p: Vector2 = b["px"]
		var pos := _pl(Vector2(p.x + sin(_time * 1.6 + float(b["phase"])) * float(b["wobble"]), p.y))
		var r: float = float(b["size"]) * _s
		var a := minf(float(b["age"]) / 0.5, 1.0)
		if float(b["pop"]) >= 0.0:
			var f := float(b["pop"]) / 0.18
			r *= 1.0 + 0.7 * f
			a *= 1.0 - f
		_bubble_layer.draw_arc(pos, r, 0.0, TAU, 14, Color(0.7, 0.9, 1.0, 0.5 * a), 1.2, true)
		_bubble_layer.draw_circle(pos + Vector2(-r * 0.35, -r * 0.35), maxf(r * 0.22, 0.6), Color(1, 1, 1, 0.7 * a))


func _draw_snow() -> void:
	for p in _snow:
		var uv: Vector2 = p["uv"]
		# Not over the painted stats frame.
		if uv.x < _frame_rect.z and uv.y > _frame_rect.y - 0.02:
			continue
		var pos := _pl(uv * _tex_size)
		var d := Vector2.ONE * float(p["size"]) * 3.0 * _s
		_snow_layer.draw_texture_rect(_dot_tex, Rect2(pos - d * 0.5, d), false, Color(0.75, 0.9, 1.0, float(p["alpha"])))
