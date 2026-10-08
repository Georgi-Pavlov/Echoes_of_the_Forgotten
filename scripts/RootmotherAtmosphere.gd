extends Control
# ------------------------------------------------------------------
# RootmotherAtmosphere
# The Verdant Scar's effects for the hero picker. ZoneAtmosphere creates
# one of these (and frees it again with the rest of its children) when
# The Rootmother's background is shown, then calls build(). Purely
# visual: never takes input, never touches game state.
#
# The Rootmother (left half):
#   - she slowly breathes (a soft swell of her body)
#   - her eyes glow green, flaring every few seconds
#   - fireflies wander through the dark around her, each blinking on its
#     own rhythm
#   - pink petals drift down off her flowers
#
# The valley (right half):
#   - the green light at the heart of the central tower breathes and
#     flares, its rays fanning down over the ruins in step with it
#   - mist drifts through the valley, and thicker along the ground
#   - the waterfalls run and splash, and light glints on the stream
#
# Positions of art features are given in pixels of the 1672x941 source
# image, so they stay on target whatever the screen size.
# ------------------------------------------------------------------

const RIPPLE_SHADER := preload("res://shaders/underwater_ripple.gdshader")
const SHAFTS_SHADER := preload("res://shaders/light_shafts.gdshader")
const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")

# The painted stats frame (UV x0, y0, x1, y1) - kept still.
const FRAME_CALM_RECT := Vector4(0.01, 0.62, 0.466, 0.972)

# Breathing: centred on her torso.
const BREATHE_CENTER_UV := Vector2(0.19, 0.34)
const BREATHE_RADIUS := 0.3             # in units of image height
const BREATHE_AMOUNT := 0.022
const BREATHE_PERIOD := 5.0

# Her eyes, and how often they flare.
const EYES_PX := [Vector2(392.0, 108.0), Vector2(425.0, 122.0)]
const EYE_DIAMETER := 30.0
const EYE_COLOR := Color(0.55, 1.0, 0.62)
const EYE_FLARE_EVERY := Vector2(3.5, 7.0)

# The green light in the central tower, its rays (a rect in image UV, and
# where in that rect's own UV they come from), and how often it flares.
const TOWER_PX := Vector2(1360.0, 205.0)
const TOWER_CORE_DIAMETER := 170.0
const TOWER_HALO_DIAMETER := 440.0
const TOWER_COLOR := Color(0.42, 1.0, 0.58)
const TOWER_FLARE_EVERY := Vector2(4.0, 8.0)
const SHAFTS_RECT_UV := Rect2(0.48, 0.0, 0.52, 0.75)
const SHAFTS_ORIGIN := Vector2(0.644, 0.128)
const SHAFT_COLOR := Color(0.6, 1.0, 0.72)

# Mist (image UV): through the valley, and low along the ground.
const MIST_RECT_UV := Rect2(0.5, 0.3, 0.5, 0.46)
const LOW_MIST_RECT_UV := Rect2(0.5, 0.62, 0.5, 0.33)
const MIST_COLOR := Color(0.92, 0.94, 0.86)

# Waterfalls: x is the centre, y0/y1 the top and foot, w the width.
const FALLS := [
	{"x": 905.0, "y0": 475.0, "y1": 565.0, "w": 13.0},
	{"x": 1107.0, "y0": 525.0, "y1": 600.0, "w": 11.0},
	{"x": 1456.0, "y0": 590.0, "y1": 655.0, "w": 13.0},
	{"x": 1562.0, "y0": 585.0, "y1": 650.0, "w": 12.0},
	{"x": 1417.0, "y0": 380.0, "y1": 425.0, "w": 9.0},
	{"x": 1438.0, "y0": 380.0, "y1": 425.0, "w": 9.0},
	{"x": 1264.0, "y0": 478.0, "y1": 520.0, "w": 8.0},
]
const STREAK_COUNT := 4
const STREAM_RECT_PX := Rect2(1340.0, 665.0, 140.0, 100.0)
const STREAM_GLINTS := 12
const WATER_COLOR := Color(0.85, 0.95, 1.0)

# Fireflies wander this region (image UV) - the dark around her, above the
# stats frame.
const FLY_REGION_UV := Rect2(0.015, 0.04, 0.45, 0.56)
const FLY_COUNT := 22
const FLY_COLORS := [Color(0.78, 1.0, 0.42), Color(0.78, 1.0, 0.42), Color(1.0, 0.86, 0.42)]

# Petals fall from her hair and body (image UV), and fade out before the
# stats frame.
const PETAL_SOURCES := [Rect2(0.04, 0.08, 0.3, 0.25), Rect2(0.08, 0.3, 0.36, 0.14)]
const PETAL_COUNT := 12
const PETAL_LIFE := Vector2(7.0, 12.0)
const PETAL_COLORS := [Color(0.93, 0.58, 0.66), Color(0.85, 0.45, 0.55), Color(0.96, 0.72, 0.74)]
const PETAL_FADE_START_UV := 0.5
const PETAL_FADE_END_UV := 0.6

var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0                # image scale (screen px per source px)
var _origin := Vector2.ZERO  # where the source image's top-left lands
var _tex_size := Vector2.ONE

var _glow_tex: Texture2D
var _dot_tex: Texture2D

var _eyes: Array[TextureRect] = []
var _eye_flare := 0.0
var _eye_next_flare := 0.0

var _tower_core: TextureRect
var _tower_halo: TextureRect
var _tower_flare := 0.0
var _tower_next_flare := 0.0
var _shafts_mat: ShaderMaterial

var _falls: Array[Dictionary] = []
var _glints: Array[Dictionary] = []
var _water_layer: Control

var _flies: Array[Dictionary] = []
var _fly_layer: Control

var _petals: Array[Dictionary] = []
var _petal_accum := 0.0
var _petal_layer: Control
var _petal_fade_y := Vector2.ZERO


## `atm` is the owning ZoneAtmosphere - its image mapping helpers are
## reused so positions line up exactly with its own effects.
func build(atm: Control, background: TextureRect) -> void:
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_origin = _atm._image_to_local(Vector2.ZERO)
	_tex_size = _background.texture.get_size()

	# Breathing, straight on the background texture (the ripple itself is
	# switched off - strength 0 - so only the swell is left).
	var mat := ShaderMaterial.new()
	mat.shader = RIPPLE_SHADER
	mat.set_shader_parameter("strength", 0.0)
	mat.set_shader_parameter("calm_rect", FRAME_CALM_RECT)
	mat.set_shader_parameter("aspect", _tex_size.x / _tex_size.y)
	mat.set_shader_parameter("breathe_center", BREATHE_CENTER_UV)
	mat.set_shader_parameter("breathe_radius", BREATHE_RADIUS)
	mat.set_shader_parameter("breathe_amount", BREATHE_AMOUNT)
	mat.set_shader_parameter("breathe_period", BREATHE_PERIOD)
	_background.material = mat

	_glow_tex = _atm._radial(128,
		PackedFloat32Array([0.0, 0.12, 0.35, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0.22), Color(1, 1, 1, 0.0)]))
	_dot_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.25, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))

	# Rays from the tower, behind everything else; then the mist over them.
	var sa: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.position)
	var sb: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.end)
	_shafts_mat = ShaderMaterial.new()
	_shafts_mat.shader = SHAFTS_SHADER
	_shafts_mat.set_shader_parameter("origin", SHAFTS_ORIGIN)
	_shafts_mat.set_shader_parameter("shaft_color", SHAFT_COLOR)
	_shafts_mat.set_shader_parameter("intensity", 0.16)
	_shafts_mat.set_shader_parameter("spread", 0.75)
	_shafts_mat.set_shader_parameter("reach", 1.3)
	_shafts_mat.set_shader_parameter("sway", 0.04)
	_shafts_mat.set_shader_parameter("aspect", (sb.x - sa.x) / (sb.y - sa.y))
	var shafts := ColorRect.new()
	shafts.material = _shafts_mat
	shafts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shafts.position = sa
	shafts.size = sb - sa
	add_child(shafts)

	_add_fog(MIST_RECT_UV, {
		"density": 0.34, "speed": 0.014, "scale": 2.2,
		"band_center": 0.6, "band_height": 0.5,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.25, 0.2, 0.02, 0.25),
	})
	_add_fog(LOW_MIST_RECT_UV, {
		"density": 0.3, "speed": 0.026, "scale": 3.4,
		"band_center": 0.7, "band_height": 0.6,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.25, 0.4, 0.02, 0.02),
	})

	# The tower's light: a wide faint halo under a brighter core.
	_tower_halo = _glow(TOWER_PX, TOWER_HALO_DIAMETER, TOWER_COLOR)
	_tower_core = _glow(TOWER_PX, TOWER_CORE_DIAMETER, TOWER_COLOR)
	_tower_next_flare = _rng.randf_range(1.5, TOWER_FLARE_EVERY.x)

	# Falling water and the glints on the stream.
	_falls.clear()
	for f in FALLS:
		var streaks: Array[Dictionary] = []
		for i in STREAK_COUNT:
			streaks.append({
				"off": _rng.randf(), "phase": _rng.randf(), "speed": _rng.randf_range(45.0, 80.0),
				"len": _rng.randf_range(8.0, 16.0), "alpha": _rng.randf_range(0.3, 0.55),
			})
		_falls.append({"fall": f, "streaks": streaks, "splash_phase": _rng.randf() * TAU})
	_glints.clear()
	for i in STREAM_GLINTS:
		_glints.append({
			"pos": STREAM_RECT_PX.position + Vector2(_rng.randf(), _rng.randf()) * STREAM_RECT_PX.size,
			"speed": _rng.randf_range(0.8, 1.9), "phase": _rng.randf() * TAU,
		})
	_water_layer = _new_layer(true)
	_water_layer.draw.connect(_draw_water)

	# Her eyes, over the mist so they burn through it.
	_eyes.clear()
	for px in EYES_PX:
		_eyes.append(_glow(px, EYE_DIAMETER, EYE_COLOR))
	_eye_next_flare = _rng.randf_range(1.0, EYE_FLARE_EVERY.x)

	# Fireflies and petals, over everything.
	_flies.clear()
	for i in FLY_COUNT:
		_flies.append({
			"base": Vector2(_rng.randf_range(0.2, 0.8), _rng.randf_range(0.2, 0.8)),
			"amp": Vector2(_rng.randf_range(0.05, 0.11), _rng.randf_range(0.05, 0.11)),
			"freq": Vector2(_rng.randf_range(0.12, 0.34), _rng.randf_range(0.1, 0.3)),
			"phase": Vector4(_rng.randf() * TAU, _rng.randf() * TAU, _rng.randf() * TAU, _rng.randf() * TAU),
			"blink": _rng.randf_range(1.0, 2.2), "blink_phase": _rng.randf() * TAU,
			"size": _rng.randf_range(26.0, 44.0),
			"tint": FLY_COLORS[_rng.randi() % FLY_COLORS.size()],
		})
	_fly_layer = _new_layer(true)
	_fly_layer.draw.connect(_draw_flies)

	_petal_fade_y = Vector2(
		_atm._image_to_local(Vector2(0.0, PETAL_FADE_START_UV)).y,
		_atm._image_to_local(Vector2(0.0, PETAL_FADE_END_UV)).y)
	_petals.clear()
	_petal_layer = _new_layer(false)
	_petal_layer.draw.connect(_draw_petals)
	# Pre-warm so the screen doesn't open without petals.
	for i in 200:
		_update_petals(1.0 / 30.0)

	set_process(true)


# --- helpers --------------------------------------------------------

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


## A fog_drift.gdshader layer over `rect_uv` of the image.
func _add_fog(rect_uv: Rect2, params: Dictionary) -> void:
	var a: Vector2 = _atm._image_to_local(rect_uv.position)
	var b: Vector2 = _atm._image_to_local(rect_uv.end)
	var mat := ShaderMaterial.new()
	mat.shader = FOG_SHADER
	mat.set_shader_parameter("aspect", (b.x - a.x) / (b.y - a.y))
	for key in params:
		mat.set_shader_parameter(key, params[key])
	var fog := ColorRect.new()
	fog.material = mat
	fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog.position = a
	fog.size = b - a
	add_child(fog)


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_eyes(delta)
	_update_tower(delta)
	_update_petals(delta)
	_water_layer.queue_redraw()
	_fly_layer.queue_redraw()
	_petal_layer.queue_redraw()


func _update_eyes(delta: float) -> void:
	_eye_next_flare -= delta
	if _eye_next_flare <= 0.0:
		_eye_flare = 1.0
		_eye_next_flare = _rng.randf_range(EYE_FLARE_EVERY.x, EYE_FLARE_EVERY.y)
	_eye_flare = move_toward(_eye_flare, 0.0, delta / 1.2)
	var flare := _eye_flare * _eye_flare
	for i in _eyes.size():
		var b: float = 0.42 + 0.1 * sin(_time * 1.3 + i * 0.9) + 0.58 * flare
		_eyes[i].modulate = Color(b, b, b, 1.0)
		_eyes[i].scale = Vector2.ONE * (0.9 + 0.1 * sin(_time * 1.3 + i * 0.9) + 0.35 * flare)


func _update_tower(delta: float) -> void:
	_tower_next_flare -= delta
	if _tower_next_flare <= 0.0:
		_tower_flare = 1.0
		_tower_next_flare = _rng.randf_range(TOWER_FLARE_EVERY.x, TOWER_FLARE_EVERY.y)
	_tower_flare = move_toward(_tower_flare, 0.0, delta / 1.6)
	var flare := smoothstep(0.0, 1.0, _tower_flare)
	var pulse: float = 0.62 + 0.14 * sin(_time * 0.8) + 0.05 * sin(_time * 2.3)
	var b: float = pulse + 0.38 * flare
	_tower_core.modulate = Color(b, b, b, 1.0)
	_tower_core.scale = Vector2.ONE * (0.95 + 0.1 * pulse + 0.18 * flare)
	var h: float = 0.25 + 0.15 * pulse + 0.5 * flare
	_tower_halo.modulate = Color(h, h, h, 1.0)
	_tower_halo.scale = Vector2.ONE * (0.95 + 0.1 * sin(_time * 0.6) + 0.12 * flare)
	_shafts_mat.set_shader_parameter("intensity", 0.13 + 0.04 * sin(_time * 0.8) + 0.1 * flare)


func _update_petals(delta: float) -> void:
	_petal_accum += delta * float(PETAL_COUNT) / ((PETAL_LIFE.x + PETAL_LIFE.y) * 0.5)
	while _petal_accum >= 1.0 and _petals.size() < PETAL_COUNT:
		_petal_accum -= 1.0
		var src: Rect2 = PETAL_SOURCES[_rng.randi() % PETAL_SOURCES.size()]
		var uv := src.position + Vector2(_rng.randf(), _rng.randf()) * src.size
		_petals.append({
			"pos": _atm._image_to_local(uv),
			"fall": _rng.randf_range(16.0, 30.0), "sway": _rng.randf_range(10.0, 22.0),
			"sway_freq": _rng.randf_range(0.7, 1.4), "sway_phase": _rng.randf() * TAU,
			"rot": _rng.randf() * TAU, "spin": _rng.randf_range(-1.6, 1.6),
			"flip": _rng.randf() * TAU, "flip_speed": _rng.randf_range(1.2, 2.6),
			"size": _rng.randf_range(5.0, 8.0), "age": 0.0, "life": _rng.randf_range(PETAL_LIFE.x, PETAL_LIFE.y),
			"color": PETAL_COLORS[_rng.randi() % PETAL_COLORS.size()],
		})
	_petal_accum = minf(_petal_accum, 1.0)
	for i in range(_petals.size() - 1, -1, -1):
		var p: Dictionary = _petals[i]
		p["age"] += delta
		p["pos"].y += float(p["fall"]) * _s * delta
		p["pos"].x += float(p["sway"]) * _s * cos(_time * float(p["sway_freq"]) + float(p["sway_phase"])) * delta
		p["rot"] += float(p["spin"]) * delta
		p["flip"] += float(p["flip_speed"]) * delta
		if p["age"] >= p["life"] or p["pos"].y >= _petal_fade_y.y:
			_petals.remove_at(i)


# --- drawing --------------------------------------------------------

func _draw_water() -> void:
	for entry in _falls:
		var f: Dictionary = entry["fall"]
		var span: float = f["y1"] - f["y0"]
		for st in entry["streaks"]:
			var frac := fposmod(float(st["phase"]) + _time * float(st["speed"]) / span, 1.0)
			var y: float = f["y0"] + frac * span
			var x: float = f["x"] - f["w"] * 0.5 + float(st["off"]) * f["w"]
			var a: float = sin(frac * PI) * float(st["alpha"])
			var top := _pl(Vector2(x, y))
			_water_layer.draw_line(top, top + Vector2(0.0, float(st["len"]) * _s), Color(WATER_COLOR, a), 1.3 * _s, true)
		# The splash where it lands, gently pulsing.
		var splash: float = 0.6 + 0.4 * sin(_time * 2.1 + float(entry["splash_phase"]))
		var size := Vector2(f["w"] * 2.6, f["w"] * 1.3) * _s
		_water_layer.draw_texture_rect(_glow_tex, Rect2(_pl(Vector2(f["x"], f["y1"])) - size * 0.5, size), false, Color(WATER_COLOR, 0.22 * splash))
	# Glints on the stream.
	for g in _glints:
		var b: float = pow(maxf(sin(_time * float(g["speed"]) + float(g["phase"])), 0.0), 8.0)
		if b < 0.05:
			continue
		var p := _pl(g["pos"])
		var d := Vector2.ONE * 7.0 * _s
		_water_layer.draw_texture_rect(_dot_tex, Rect2(p - d * 0.5, d), false, Color(1, 1, 1, 0.85 * b))
		var arm := 5.0 * _s * b
		_water_layer.draw_line(p - Vector2(arm, 0.0), p + Vector2(arm, 0.0), Color(1, 1, 1, 0.5 * b), 1.0, true)
		_water_layer.draw_line(p - Vector2(0.0, arm), p + Vector2(0.0, arm), Color(1, 1, 1, 0.5 * b), 1.0, true)


func _draw_flies() -> void:
	for f in _flies:
		var b: float = 0.06 + pow(maxf(sin(_time * float(f["blink"]) + float(f["blink_phase"])), 0.0), 1.5)
		var ph: Vector4 = f["phase"]
		var fr: Vector2 = f["freq"]
		var wander := Vector2(
			sin(_time * fr.x + ph.x) + 0.5 * sin(_time * fr.y * 2.3 + ph.z),
			sin(_time * fr.y + ph.y) + 0.5 * sin(_time * fr.x * 1.9 + ph.w))
		var uv: Vector2 = FLY_REGION_UV.position + (f["base"] + Vector2(f["amp"]) * wander) * FLY_REGION_UV.size
		var p: Vector2 = _atm._image_to_local(uv)
		var halo := Vector2.ONE * float(f["size"]) * _s
		_fly_layer.draw_texture_rect(_glow_tex, Rect2(p - halo * 0.5, halo), false, Color(Color(f["tint"]), 0.85 * minf(b, 1.0)))
		var core := Vector2.ONE * float(f["size"]) * 0.3 * _s
		_fly_layer.draw_texture_rect(_dot_tex, Rect2(p - core * 0.5, core), false, Color(1.0, 1.0, 0.85, minf(b, 1.0)))


func _draw_petals() -> void:
	for p in _petals:
		var age: float = p["age"]
		var fade: float = smoothstep(0.0, 0.6, age) * (1.0 - smoothstep(float(p["life"]) - 1.5, float(p["life"]), age))
		fade *= 1.0 - smoothstep(_petal_fade_y.x, _petal_fade_y.y, p["pos"].y)
		if fade <= 0.01:
			continue
		var size: float = float(p["size"]) * _s
		var squash := 0.35 + 0.65 * absf(cos(float(p["flip"])))
		var rot: float = p["rot"]
		var pts := PackedVector2Array()
		for i in 8:
			var a := TAU * i / 8.0
			# A teardrop: fuller at one end, drawn to a point at the other.
			var v := Vector2(cos(a) * size, sin(a) * size * 0.55 * squash * (1.0 - 0.35 * cos(a)))
			pts.append(Vector2(p["pos"]) + v.rotated(rot))
		_petal_layer.draw_colored_polygon(pts, Color(Color(p["color"]), 0.85 * fade))
