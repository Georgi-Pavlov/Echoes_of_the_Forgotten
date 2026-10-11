extends Control
# ------------------------------------------------------------------
# ScorchlandsAtmosphere
# Raze's Scorchlands effects for the hero picker. ZoneAtmosphere creates
# one of these (and frees it again with the rest of its children) when
# scorchlands_raze.jpg is shown, then calls build(). Purely visual: never
# takes input, never touches game state.
#
# Raze (left half):
#   - embers rising out of the debris around her
#   - she slowly breathes (a soft swell of her body)
#   - her blown kiss: glowing embers shaped like hearts flying off her
#     hand toward the screen
#   - the glow behind her head breathing
#
# The wastes (right half):
#   - sand haze drifting over the dunes, thicker along the ground
#   - gusts of blown sand streaking across, calm between gusts
#   - smoke rising from the chimneys and burning towers
#   - the sun's glow pulsing
#   - the tattered scaffold cloth swaying (wind gusts push it
#     harder, in step with the blown sand)
#
# Positions of art features are given in pixels of the 1672x941 source
# image, so they stay on target whatever the screen size.
# ------------------------------------------------------------------

const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")
const SWAY_SHADER := preload("res://shaders/banner_sway.gdshader")

# Cloth (image UV x0, y0, x1, y1): the scaffold cloth on the right,
# anchored on its pole at the left. The painted banners stay still.
const FLAG_A := Vector4(0.870, 0.553, 0.963, 0.63)    # right scaffold

# Sand haze (image UV): over the whole wasteland, and low along the dunes.
const HAZE_RECT_UV := Rect2(0.48, 0.3, 0.52, 0.5)
const LOW_HAZE_RECT_UV := Rect2(0.48, 0.58, 0.52, 0.4)
const HAZE_COLOR := Color(0.96, 0.78, 0.52)

# Blown sand: the region it crosses (image UV), and the gust rhythm.
const SAND_RECT_UV := Rect2(0.48, 0.3, 0.52, 0.7)
const SAND_COUNT := 70
const GUST_EVERY := Vector2(7.0, 13.0)
const GUST_TIME := 4.0
const SAND_COLOR := Color(1.0, 0.82, 0.55)

# Smoke sources (source pixels) - the chimney stack, a burning tower and a
# smaller stack - with how fast each emits.
const SMOKE_SOURCES := [
	{"px": Vector2(822.0, 150.0), "rate": 1.0},
	{"px": Vector2(858.0, 190.0), "rate": 0.6},
	{"px": Vector2(945.0, 224.0), "rate": 0.5},
]
const SMOKE_COUNT := 26
const SMOKE_LIFE := Vector2(7.0, 11.0)
const SMOKE_COLOR := Color(0.2, 0.15, 0.12)

# The sun, and the glow behind Raze's head.
const SUN_PX := Vector2(1300.0, 195.0)
const SUN_DIAMETER := 420.0
const SUN_COLOR := Color(1.0, 0.72, 0.36)
const MOON_PX := Vector2(520.0, 150.0)
const MOON_DIAMETER := 300.0
const MOON_COLOR := Color(1.0, 0.6, 0.28)

# Embers rise from here (image UV) and fade out well before the top.
const EMBER_SOURCE_UV := Rect2(0.02, 0.5, 0.44, 0.14)
const EMBER_COUNT := 38
const EMBER_LIFE := Vector2(3.5, 6.5)
const EMBER_COLORS := [Color(1.0, 0.55, 0.15), Color(1.0, 0.72, 0.3), Color(1.0, 0.4, 0.1)]

# Breathing: centred on her torso; kept off the painted stats frame.
const BREATHE_CENTER_UV := Vector2(0.24, 0.40)
const BREATHE_RADIUS := 0.27             # in units of image height
const BREATHE_AMOUNT := 0.02
const BREATHE_PERIOD := 5.0
const FRAME_CALM_RECT := Vector4(0.01, 0.62, 0.466, 0.972)

# Her blown kiss: hearts leave her fingertips (source pixels), grow as they
# fly at the screen, drifting a little toward its centre.
const KISS_PX := Vector2(385.0, 292.0)
const KISS_EVERY := Vector2(4.0, 7.0)
const KISS_HEARTS := 5
const KISS_GAP := 0.2
const KISS_LIFE := 2.4
const KISS_DRIFT_PX := Vector2(260.0, 40.0)
const KISS_START_SIZE := 14.0
const KISS_END_SIZE := 130.0
const KISS_COLOR := Color(1.0, 0.5, 0.2)

var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0
var _origin := Vector2.ZERO

var _glow_tex: Texture2D
var _dot_tex: Texture2D
var _sway_mat: ShaderMaterial

var _sun: TextureRect
var _moon: TextureRect

var _gust := 0.0
var _gust_t := -1.0
var _next_gust := 0.0
var _sand: Array[Dictionary] = []
var _sand_layer: Control

var _smoke: Array[Dictionary] = []
var _smoke_accum := 0.0
var _smoke_layer: Control

var _embers: Array[Dictionary] = []
var _ember_accum := 0.0
var _ember_layer: Control

var _hearts: Array[Dictionary] = []
var _kiss_next := 0.0
var _kiss_left := 0
var _kiss_gap := 0.0
var _heart_layer: Control


func build(atm: Control, background: TextureRect) -> void:
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_origin = _atm._image_to_local(Vector2.ZERO)

	# Swaying cloth, straight on the background texture.
	_sway_mat = ShaderMaterial.new()
	_sway_mat.shader = SWAY_SHADER
	_sway_mat.set_shader_parameter("flag_a", FLAG_A)
	_sway_mat.set_shader_parameter("aspect", _background.texture.get_size().x / _background.texture.get_size().y)
	_sway_mat.set_shader_parameter("breathe_center", BREATHE_CENTER_UV)
	_sway_mat.set_shader_parameter("breathe_radius", BREATHE_RADIUS)
	_sway_mat.set_shader_parameter("breathe_amount", BREATHE_AMOUNT)
	_sway_mat.set_shader_parameter("breathe_period", BREATHE_PERIOD)
	_sway_mat.set_shader_parameter("calm_rect", FRAME_CALM_RECT)
	_background.material = _sway_mat

	_glow_tex = _atm._radial(128,
		PackedFloat32Array([0.0, 0.12, 0.35, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0.22), Color(1, 1, 1, 0.0)]))
	_dot_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.25, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))

	# Glows first, so haze and smoke pass over them.
	_sun = _glow(SUN_PX, SUN_DIAMETER, SUN_COLOR)
	_moon = _glow(MOON_PX, MOON_DIAMETER, MOON_COLOR)

	_add_fog(HAZE_RECT_UV, {
		"density": 0.3, "speed": 0.03, "scale": 2.4,
		"band_center": 0.6, "band_height": 0.5,
		"fog_color": HAZE_COLOR,
		"edge_fade": Vector4(0.08, 0.2, 0.02, 0.25),
	})
	_add_fog(LOW_HAZE_RECT_UV, {
		"density": 0.34, "speed": 0.05, "scale": 3.6,
		"band_center": 0.75, "band_height": 0.5,
		"fog_color": HAZE_COLOR,
		"edge_fade": Vector4(0.08, 0.4, 0.02, 0.02),
	})

	_smoke_layer = _new_layer(false)
	_smoke_layer.draw.connect(_draw_smoke)
	for i in 400:
		_update_smoke(1.0 / 30.0)

	_sand.clear()
	for i in SAND_COUNT:
		_sand.append({
			"pos": Vector2(_rng.randf(), _rng.randf()),
			"speed": _rng.randf_range(0.7, 1.4), "len": _rng.randf_range(10.0, 26.0),
			"alpha": _rng.randf_range(0.25, 0.6), "drift": _rng.randf_range(-0.02, 0.05),
		})
	_next_gust = _rng.randf_range(2.0, 5.0)
	_sand_layer = _new_layer(true)
	_sand_layer.draw.connect(_draw_sand)

	_embers.clear()
	_kiss_next = _rng.randf_range(1.5, 3.0)
	_heart_layer = _new_layer(true)
	_heart_layer.draw.connect(_draw_hearts)
	_ember_layer = _new_layer(true)
	_ember_layer.draw.connect(_draw_embers)
	for i in 200:
		_update_embers(1.0 / 30.0)

	set_process(true)


# --- helpers --------------------------------------------------------

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
	_update_gust(delta)
	_update_glows()
	_update_smoke(delta)
	_update_embers(delta)
	_update_kiss(delta)
	_smoke_layer.queue_redraw()
	_sand_layer.queue_redraw()
	_ember_layer.queue_redraw()
	_heart_layer.queue_redraw()


func _update_gust(delta: float) -> void:
	_next_gust -= delta
	if _next_gust <= 0.0:
		_gust_t = 0.0
		_next_gust = _rng.randf_range(GUST_EVERY.x, GUST_EVERY.y)
	if _gust_t >= 0.0:
		_gust_t += delta
		if _gust_t >= GUST_TIME:
			_gust_t = -1.0
	_gust = sin(clampf(_gust_t / GUST_TIME, 0.0, 1.0) * PI) if _gust_t >= 0.0 else 0.0
	_sway_mat.set_shader_parameter("wind", 0.7 + 0.9 * _gust)


func _update_glows() -> void:
	var sun_b: float = 0.62 + 0.12 * sin(_time * 0.7) + 0.05 * sin(_time * 1.9)
	_sun.modulate = Color(sun_b, sun_b, sun_b, 1.0)
	_sun.scale = Vector2.ONE * (0.95 + 0.08 * sin(_time * 0.5))
	var moon_b: float = 0.5 + 0.12 * sin(_time * 0.9 + 1.0) + 0.04 * sin(_time * 2.3)
	_moon.modulate = Color(moon_b, moon_b, moon_b, 1.0)
	_moon.scale = Vector2.ONE * (0.95 + 0.07 * sin(_time * 0.65 + 0.5))


func _update_smoke(delta: float) -> void:
	var total_rate := 0.0
	for src in SMOKE_SOURCES:
		total_rate += float(src["rate"])
	var avg_life := (SMOKE_LIFE.x + SMOKE_LIFE.y) * 0.5
	_smoke_accum += delta * float(SMOKE_COUNT) / avg_life
	while _smoke_accum >= 1.0 and _smoke.size() < SMOKE_COUNT:
		_smoke_accum -= 1.0
		var pick := _rng.randf() * total_rate
		var px := Vector2.ZERO
		for src in SMOKE_SOURCES:
			pick -= float(src["rate"])
			if pick <= 0.0:
				px = src["px"]
				break
		_smoke.append({
			"pos": px + Vector2(_rng.randf_range(-3.0, 3.0), 0.0),
			"rise": _rng.randf_range(10.0, 18.0), "drift": _rng.randf_range(3.0, 9.0),
			"wobble": _rng.randf_range(2.0, 6.0), "wobble_phase": _rng.randf() * TAU,
			"size": _rng.randf_range(16.0, 26.0), "grow": _rng.randf_range(6.0, 11.0),
			"age": 0.0, "life": _rng.randf_range(SMOKE_LIFE.x, SMOKE_LIFE.y),
		})
	_smoke_accum = minf(_smoke_accum, 1.0)
	for i in range(_smoke.size() - 1, -1, -1):
		var p: Dictionary = _smoke[i]
		p["age"] += delta
		p["pos"].y -= float(p["rise"]) * delta
		p["pos"].x += (float(p["drift"]) * (1.0 + 0.8 * _gust) + float(p["wobble"]) * sin(_time * 0.8 + float(p["wobble_phase"]))) * delta
		if p["age"] >= p["life"]:
			_smoke.remove_at(i)


func _update_embers(delta: float) -> void:
	_ember_accum += delta * float(EMBER_COUNT) / ((EMBER_LIFE.x + EMBER_LIFE.y) * 0.5)
	while _ember_accum >= 1.0 and _embers.size() < EMBER_COUNT:
		_ember_accum -= 1.0
		var uv := EMBER_SOURCE_UV.position + Vector2(_rng.randf(), _rng.randf()) * EMBER_SOURCE_UV.size
		_embers.append({
			"pos": _atm._image_to_local(uv),
			"rise": _rng.randf_range(28.0, 62.0), "sway": _rng.randf_range(8.0, 22.0),
			"sway_freq": _rng.randf_range(0.8, 2.0), "sway_phase": _rng.randf() * TAU,
			"size": _rng.randf_range(7.0, 15.0), "flicker": _rng.randf_range(4.0, 9.0),
			"age": 0.0, "life": _rng.randf_range(EMBER_LIFE.x, EMBER_LIFE.y),
			"color": EMBER_COLORS[_rng.randi() % EMBER_COLORS.size()],
		})
	_ember_accum = minf(_ember_accum, 1.0)
	for i in range(_embers.size() - 1, -1, -1):
		var p: Dictionary = _embers[i]
		p["age"] += delta
		p["pos"].y -= float(p["rise"]) * _s * delta
		p["pos"].x += float(p["sway"]) * _s * cos(_time * float(p["sway_freq"]) + float(p["sway_phase"])) * delta
		if p["age"] >= p["life"]:
			_embers.remove_at(i)


# --- drawing --------------------------------------------------------

func _draw_smoke() -> void:
	for p in _smoke:
		var age: float = p["age"]
		var life: float = p["life"]
		var fade: float = smoothstep(0.0, 1.2, age) * (1.0 - smoothstep(life * 0.35, life, age))
		if fade <= 0.01:
			continue
		var d: float = (float(p["size"]) + float(p["grow"]) * age) * _s
		var size := Vector2(d, d * 0.85)
		_smoke_layer.draw_texture_rect(_glow_tex, Rect2(_pl(p["pos"]) - size * 0.5, size), false, Color(SMOKE_COLOR, 0.42 * fade))


func _draw_sand() -> void:
	var a: Vector2 = _atm._image_to_local(SAND_RECT_UV.position)
	var b: Vector2 = _atm._image_to_local(SAND_RECT_UV.end)
	var size := b - a
	var delta := get_process_delta_time()
	# Always a faint breeze; a gust makes it faster, denser and longer.
	var strength: float = 0.25 + 0.75 * _gust
	for sp in _sand:
		var pos: Vector2 = sp["pos"]
		pos.x += float(sp["speed"]) * (0.05 + 0.5 * _gust) * delta
		pos.y += float(sp["drift"]) * delta
		if pos.x > 1.1:
			pos = Vector2(-0.05, _rng.randf())
		pos.y = fposmod(pos.y, 1.0)
		sp["pos"] = pos
		var fade: float = smoothstep(0.0, 0.08, pos.x) * (1.0 - smoothstep(0.9, 1.0, pos.x))
		var alpha: float = float(sp["alpha"]) * strength * fade
		if alpha <= 0.01:
			continue
		var p := a + pos * size
		var length: float = float(sp["len"]) * _s * (0.6 + 1.4 * _gust)
		_sand_layer.draw_line(p, p + Vector2(length, length * 0.04), Color(SAND_COLOR, alpha), 1.2 * _s, true)


func _draw_embers() -> void:
	var top: float = _atm._image_to_local(Vector2(0.0, 0.18)).y
	var bottom: float = _atm._image_to_local(Vector2(0.0, 0.62)).y
	for p in _embers:
		var age: float = p["age"]
		var life: float = p["life"]
		var fade: float = smoothstep(0.0, 0.5, age) * (1.0 - smoothstep(life * 0.5, life, age))
		fade *= smoothstep(top, top + (bottom - top) * 0.5, p["pos"].y)
		var flick: float = 0.65 + 0.35 * sin(_time * float(p["flicker"]) + float(p["sway_phase"]))
		var alpha := fade * flick
		if alpha <= 0.02:
			continue
		var d: float = float(p["size"]) * _s
		var halo := Vector2.ONE * d
		_ember_layer.draw_texture_rect(_glow_tex, Rect2(Vector2(p["pos"]) - halo * 0.5, halo), false, Color(Color(p["color"]), 0.8 * alpha))
		var core := Vector2.ONE * d * 0.3
		_ember_layer.draw_texture_rect(_dot_tex, Rect2(Vector2(p["pos"]) - core * 0.5, core), false, Color(1.0, 0.92, 0.7, alpha))



func _update_kiss(delta: float) -> void:
	if _kiss_left > 0:
		_kiss_gap -= delta
		if _kiss_gap <= 0.0:
			_kiss_left -= 1
			_kiss_gap = KISS_GAP
			_hearts.append({
				"age": 0.0, "side": _rng.randf_range(-14.0, 14.0), "rise": _rng.randf_range(-6.0, 22.0),
				"tilt": _rng.randf_range(-0.35, 0.35), "wobble": _rng.randf() * TAU,
			})
	else:
		_kiss_next -= delta
		if _kiss_next <= 0.0:
			_kiss_left = KISS_HEARTS
			_kiss_gap = 0.0
			_kiss_next = _rng.randf_range(KISS_EVERY.x, KISS_EVERY.y)
	for i in range(_hearts.size() - 1, -1, -1):
		_hearts[i]["age"] += delta
		if _hearts[i]["age"] >= KISS_LIFE:
			_hearts.remove_at(i)


func _draw_hearts() -> void:
	for h in _hearts:
		var t: float = float(h["age"]) / KISS_LIFE
		var e := t * t * (3.0 - 2.0 * t)
		# Born at the fingertips, swelling as it nears the viewer.
		var size: float = lerpf(KISS_START_SIZE, KISS_END_SIZE, e * e) * _s
		var pos := _pl(KISS_PX + KISS_DRIFT_PX * e + Vector2(float(h["side"]) * e, -float(h["rise"]) * e + 20.0 * sin(t * 5.0 + float(h["wobble"]))))
		var fade: float = smoothstep(0.0, 0.12, t) * (1.0 - smoothstep(0.55, 1.0, t))
		if fade <= 0.01:
			continue
		var halo := Vector2.ONE * size * 2.2
		_heart_layer.draw_texture_rect(_glow_tex, Rect2(pos - halo * 0.5, halo), false, Color(KISS_COLOR, 0.55 * fade))
		var pts := PackedVector2Array()
		for i in 28:
			var a := TAU * i / 28.0
			var x := 16.0 * pow(sin(a), 3.0)
			var y := -(13.0 * cos(a) - 5.0 * cos(2.0 * a) - 2.0 * cos(3.0 * a) - cos(4.0 * a))
			pts.append(pos + (Vector2(x, y) / 17.0 * size * 0.5).rotated(float(h["tilt"])))
		_heart_layer.draw_colored_polygon(pts, Color(1.0, 0.55, 0.22, 0.75 * fade))
		var core := PackedVector2Array()
		for p in pts:
			core.append(pos + (p - pos) * 0.5)
		_heart_layer.draw_colored_polygon(core, Color(1.0, 0.9, 0.6, 0.8 * fade))
