extends Control
# ------------------------------------------------------------------
# ScorchlandsBattleAtmosphere
# The Scorchlands arena's battle-area effects. BattleAtmosphere creates
# one of these (and frees it with the rest of its children) for the
# scorchlands_area.jpg arena, then calls build(). Purely visual: never
# takes input, never touches game state. It sits under the fighters, and
# the painted battle UI panel at the bottom is left alone.
#
#   - the sun's glow pulsing, a hot haze breathing around it
#   - flames dancing in the braziers, each flickering on its own, with
#     sparks and a little smoke rising off them
#   - smoke rising from the stacks on the cliff and the far tower
#   - a sandstorm: dust banks rolling across the dunes and the arena,
#     with streaks of blown sand that rush past in gusts
#
# Positions of art features are given in pixels of the 1670x941 source
# image, so they stay on target whatever the screen size.
# ------------------------------------------------------------------

const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")

# The painted UI panel starts below this (image UV y).
const FLOOR_UV := 0.68

# The sun, and the haze around it.
const SUN_PX := Vector2(1117.0, 185.0)
const SUN_DIAMETER := 420.0
const SUN_COLOR := Color(1.0, 0.72, 0.36)

# Braziers (flame base, source px) and how big each burns.
const FIRES := [
	{"px": Vector2(98.0, 218.0), "size": 1.0},
	{"px": Vector2(1598.0, 270.0), "size": 1.0},
]
const FIRE_COLOR := Color(1.0, 0.55, 0.18)

# Smoke sources (source px) and how fast each emits.
const SMOKE_SOURCES := [
	{"px": Vector2(572.0, 92.0), "rate": 1.0},
	{"px": Vector2(655.0, 140.0), "rate": 0.6},
	{"px": Vector2(1638.0, 70.0), "rate": 0.8},
]
const SMOKE_COUNT := 30
const SMOKE_LIFE := Vector2(8.0, 12.0)
const SMOKE_COLOR := Color(0.17, 0.13, 0.11)

# Dust banks (image UV): over the far dunes, across the arena floor, and
# a thin low one that keeps rolling over the whole width.
const DUST_RECT_UV := Rect2(0.0, 0.25, 1.0, 0.3)
const DUST_LOW_RECT_UV := Rect2(0.0, 0.42, 1.0, 0.26)
const DUST_COLOR := Color(0.95, 0.72, 0.45)

# Blown sand: how many streaks, the region they cross (image UV) and the
# gust rhythm.
const SAND_COUNT := 90
const SAND_RECT_UV := Rect2(0.0, 0.2, 1.0, 0.48)
const GUST_EVERY := Vector2(6.0, 12.0)
const GUST_TIME := 4.5
const SAND_COLOR := Color(1.0, 0.8, 0.52)

var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0                # image scale (screen px per source px)
var _origin := Vector2.ZERO  # where the source image's top-left lands

var _glow_tex: Texture2D
var _dot_tex: Texture2D

var _sun: TextureRect

var _fires: Array[Dictionary] = []

var _smoke: Array[Dictionary] = []
var _smoke_accum := 0.0
var _smoke_layer: Control

var _gust := 0.0
var _gust_t := -1.0
var _next_gust := 0.0
var _dust_mats: Array[ShaderMaterial] = []
var _sand: Array[Dictionary] = []
var _sand_layer: Control


## `atm` is the owning BattleAtmosphere - its image mapping helpers are
## reused so positions line up with the Background exactly.
func build(atm: Control, background: TextureRect) -> void:
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_origin = _atm._image_to_local(Vector2.ZERO)

	_glow_tex = _atm._radial(128,
		PackedFloat32Array([0.0, 0.12, 0.35, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0.22), Color(1, 1, 1, 0.0)]))
	_dot_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.25, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))

	_sun = _glow(SUN_PX, SUN_DIAMETER, SUN_COLOR)

	# Smoke, behind the dust and the flames.
	_smoke_layer = _new_layer(false)
	_smoke_layer.draw.connect(_draw_smoke)
	for i in 450:
		_update_smoke(1.0 / 30.0)

	# The dust banks.
	_dust_mats.clear()
	_add_dust(DUST_RECT_UV, {
		"density": 0.3, "speed": 0.05, "scale": 2.6,
		"band_center": 0.5, "band_height": 0.55,
		"fog_color": DUST_COLOR,
		"edge_fade": Vector4(0.02, 0.35, 0.02, 0.35),
	})
	_add_dust(DUST_LOW_RECT_UV, {
		"density": 0.26, "speed": 0.08, "scale": 3.8,
		"band_center": 0.5, "band_height": 0.5,
		"fog_color": DUST_COLOR,
		"edge_fade": Vector4(0.02, 0.4, 0.02, 0.45),
	})

	# The braziers' fire, over the dust so it burns through it.
	_fires.clear()
	for f in FIRES:
		_add_fire(f["px"], float(f["size"]))

	_sand.clear()
	for i in SAND_COUNT:
		_sand.append({
			"pos": Vector2(_rng.randf(), _rng.randf()),
			"speed": _rng.randf_range(0.7, 1.4), "len": _rng.randf_range(14.0, 34.0),
			"alpha": _rng.randf_range(0.25, 0.6), "drift": _rng.randf_range(-0.01, 0.04),
		})
	_next_gust = _rng.randf_range(2.0, 5.0)
	_sand_layer = _new_layer(true)
	_sand_layer.draw.connect(_draw_sand)

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


## A fog_drift.gdshader layer over `rect_uv` of the image; its density is
## remembered so gusts can thicken it.
func _add_dust(rect_uv: Rect2, params: Dictionary) -> void:
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
	_dust_mats.append(mat)
	mat.set_meta("base_density", float(params["density"]))
	mat.set_meta("base_speed", float(params["speed"]))


## A brazier: a flickering glow under a column of flame particles, with
## sparks rising off it and a thin smoke above.
func _add_fire(px: Vector2, size: float) -> void:
	var halo := _glow(px + Vector2(0.0, -14.0 * size), 120.0 * size, FIRE_COLOR)
	var core := _glow(px + Vector2(0.0, -8.0 * size), 46.0 * size, Color(1.0, 0.85, 0.5))
	_fires.append({
		"halo": halo, "core": core,
		"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.9, 1.2),
	})

	var flame := CPUParticles2D.new()
	flame.position = _pl(px)
	flame.material = _atm._additive()
	flame.texture = _glow_tex
	flame.amount = 26
	flame.lifetime = 0.85
	flame.preprocess = 0.85
	flame.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	flame.emission_rect_extents = Vector2(11.0, 3.0) * size * _s
	flame.direction = Vector2(0.0, -1.0)
	flame.spread = 14.0
	flame.gravity = Vector2(0.0, -26.0) * _s
	flame.initial_velocity_min = 26.0 * size * _s
	flame.initial_velocity_max = 50.0 * size * _s
	flame.scale_amount_min = 0.22 * size * _s
	flame.scale_amount_max = 0.42 * size * _s
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 0.7))
	shrink.add_point(Vector2(0.35, 1.0))
	shrink.add_point(Vector2(1.0, 0.1))
	flame.scale_amount_curve = shrink
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.55, 1.0])
	ramp.colors = PackedColorArray([
		Color(1.0, 0.95, 0.6, 0.0), Color(1.0, 0.8, 0.35, 0.8),
		Color(1.0, 0.45, 0.12, 0.5), Color(0.8, 0.15, 0.05, 0.0)])
	flame.color_ramp = ramp
	add_child(flame)

	var sparks := CPUParticles2D.new()
	sparks.position = _pl(px)
	sparks.material = _atm._additive()
	sparks.texture = _dot_tex
	sparks.amount = 9
	sparks.lifetime = 2.4
	sparks.preprocess = 2.4
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparks.emission_rect_extents = Vector2(9.0, 3.0) * size * _s
	sparks.direction = Vector2(0.4, -1.0)
	sparks.spread = 28.0
	sparks.gravity = Vector2(10.0, -10.0) * _s
	sparks.initial_velocity_min = 30.0 * _s
	sparks.initial_velocity_max = 70.0 * _s
	sparks.scale_amount_min = 0.25 * _s
	sparks.scale_amount_max = 0.6 * _s
	var spark_ramp := Gradient.new()
	spark_ramp.offsets = PackedFloat32Array([0.0, 0.15, 0.7, 1.0])
	spark_ramp.colors = PackedColorArray([
		Color(1.0, 0.9, 0.5, 0.0), Color(1.0, 0.85, 0.45, 1.0),
		Color(1.0, 0.45, 0.12, 0.6), Color(1.0, 0.3, 0.1, 0.0)])
	sparks.color_ramp = spark_ramp
	add_child(sparks)


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_gust(delta)
	_update_sun()
	_update_fires()
	_update_smoke(delta)
	_smoke_layer.queue_redraw()
	_sand_layer.queue_redraw()


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
	# A gust thickens the dust banks and speeds them up.
	for mat in _dust_mats:
		mat.set_shader_parameter("density", float(mat.get_meta("base_density")) * (1.0 + 0.7 * _gust))
		mat.set_shader_parameter("speed", float(mat.get_meta("base_speed")) * (1.0 + 1.2 * _gust))


func _update_sun() -> void:
	var b: float = 0.62 + 0.12 * sin(_time * 0.7) + 0.05 * sin(_time * 1.9)
	# The dust dims it a touch as a gust passes over.
	b *= 1.0 - 0.15 * _gust
	_sun.modulate = Color(b, b, b, 1.0)
	_sun.scale = Vector2.ONE * (0.95 + 0.08 * sin(_time * 0.5))


func _update_fires() -> void:
	for f in _fires:
		var ph: float = f["phase"]
		var sp: float = f["speed"]
		# A quick, uneven flicker.
		var flick: float = 0.75 + 0.15 * sin(_time * 9.0 * sp + ph) + 0.1 * sin(_time * 17.0 * sp + ph * 2.3) + 0.06 * sin(_time * 3.1 + ph)
		f["halo"].modulate = Color(flick, flick, flick, 1.0)
		f["halo"].scale = Vector2.ONE * (0.9 + 0.2 * flick)
		var core: float = 0.6 + 0.4 * flick
		f["core"].modulate = Color(core, core, core, 1.0)


func _update_smoke(delta: float) -> void:
	var total_rate := 0.0
	for src in SMOKE_SOURCES:
		total_rate += float(src["rate"])
	_smoke_accum += delta * float(SMOKE_COUNT) / ((SMOKE_LIFE.x + SMOKE_LIFE.y) * 0.5)
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
			"pos": px + Vector2(_rng.randf_range(-4.0, 4.0), 0.0),
			"rise": _rng.randf_range(10.0, 18.0), "drift": _rng.randf_range(8.0, 16.0),
			"wobble": _rng.randf_range(2.0, 6.0), "wobble_phase": _rng.randf() * TAU,
			"size": _rng.randf_range(24.0, 38.0), "grow": _rng.randf_range(8.0, 14.0),
			"age": 0.0, "life": _rng.randf_range(SMOKE_LIFE.x, SMOKE_LIFE.y),
		})
	_smoke_accum = minf(_smoke_accum, 1.0)
	for i in range(_smoke.size() - 1, -1, -1):
		var p: Dictionary = _smoke[i]
		p["age"] += delta
		p["pos"].y -= float(p["rise"]) * delta
		# The wind carries the smoke the same way the sand blows.
		p["pos"].x += (float(p["drift"]) * (1.0 + 1.5 * _gust) + float(p["wobble"]) * sin(_time * 0.8 + float(p["wobble_phase"]))) * delta
		if p["age"] >= p["life"]:
			_smoke.remove_at(i)


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
	# Always a faint breeze; a gust makes the streaks faster, longer and
	# brighter.
	var strength: float = 0.3 + 0.7 * _gust
	for sp in _sand:
		var pos: Vector2 = sp["pos"]
		pos.x += float(sp["speed"]) * (0.06 + 0.55 * _gust) * delta
		pos.y += float(sp["drift"]) * delta
		if pos.x > 1.1:
			pos = Vector2(-0.05, _rng.randf())
		pos.y = fposmod(pos.y, 1.0)
		sp["pos"] = pos
		var fade: float = smoothstep(0.0, 0.06, pos.x) * (1.0 - smoothstep(0.92, 1.0, pos.x))
		var alpha: float = float(sp["alpha"]) * strength * fade
		if alpha <= 0.01:
			continue
		var p := a + pos * size
		var length: float = float(sp["len"]) * _s * (0.6 + 1.6 * _gust)
		_sand_layer.draw_line(p, p + Vector2(length, length * 0.05), Color(SAND_COLOR, alpha), 1.3 * _s, true)
