extends IntroSceneFX

## Effects over the intro's fifth scene (the celebration - power pouring
## down from the sky onto the great cathedral): the column of magic
## surging, light racing along the ribbons of energy spiralling round it,
## magic sparkles drifting in the sky, cherry blossom petals falling across
## the festival, waterfalls flowing, the foreground pool rippling, floating
## islands drifting and the statues' halos glowing. See IntroSceneFX.gd for
## how positions and areas are given.

const RIBBONS_SHADER := preload("res://shaders/intro_ribbons.gdshader")
const FLOAT_SHADER := preload("res://shaders/intro_float.gdshader")
const WATERFALL_SHADER := preload("res://shaders/intro_waterfall.gdshader")
const WATER_SHADER := preload("res://shaders/intro_water.gdshader")

## The column of magic pouring down onto the cathedral.
const COLUMN_X := 0.629
const COLUMN_TOP := 0.0
const COLUMN_BOTTOM := 0.32
const COLUMN_COLOR := Color(0.8, 0.9, 1.0)
const COLUMN_FLARE := Vector2(0.629, 0.07)

const RIBBONS_AREA := Rect2(0.45, 0.0, 0.37, 0.42)

## Sparkles drift and twinkle in the sky around the column.
const SPARKLE_AREA := Rect2(0.42, 0.0, 0.42, 0.4)
const SPARKLE_COUNT := 50
const SPARKLE_COLOR := Color(0.8, 0.92, 1.0)

## Petals fall across this part of the scene (wrapping round to the top).
const PETAL_AREA := Rect2(0.0, -0.05, 1.0, 1.1)
const PETAL_COUNT := 55
const PETAL_COLORS: Array[Color] = [
	Color(1.0, 0.78, 0.85),
	Color(0.98, 0.7, 0.8),
	Color(1.0, 0.88, 0.92),
]

const WATERFALLS: Array[Rect2] = [
	Rect2(0.152, 0.25, 0.022, 0.2),
	Rect2(0.205, 0.3, 0.02, 0.15),
	Rect2(0.35, 0.33, 0.026, 0.07),
	Rect2(0.44, 0.38, 0.022, 0.09),
	Rect2(0.57, 0.42, 0.032, 0.08),
	Rect2(0.673, 0.42, 0.028, 0.08),
	Rect2(0.728, 0.43, 0.032, 0.07),
	Rect2(0.818, 0.545, 0.036, 0.12),
	Rect2(0.913, 0.24, 0.024, 0.06),
	Rect2(0.6, 0.61, 0.12, 0.07),
]

## The pool's open water (the blurred flowers in front are left alone).
const POOL_AREAS: Array[Rect2] = [
	Rect2(0.47, 0.875, 0.28, 0.125),
	Rect2(0.17, 0.865, 0.3, 0.07),
]

const ISLANDS: Array[Dictionary] = [
	{"area": Rect2(0.415, 0.02, 0.07, 0.17)},
	{"area": Rect2(0.708, 0.085, 0.04, 0.1)},
	{"area": Rect2(0.765, 0.14, 0.028, 0.06)},
	{"area": Rect2(0.788, 0.0, 0.05, 0.13), "edge_fade": Vector4(0.15, 0.001, 0.15, 0.12)},
	{"area": Rect2(0.515, 0.225, 0.045, 0.08)},
]

## The statues' golden halos.
const HALOS: Array[Vector2] = [
	Vector2(0.367, 0.115),
	Vector2(0.903, 0.295),
	Vector2(0.822, 0.69),
]
const HALO_COLOR := Color(1.0, 0.85, 0.45)

var _column: TextureRect
var _column_core: TextureRect
var _flare: TextureRect
## Per halo: {glow, phase}.
var _halos: Array[Dictionary] = []
## Per sparkle: {pos, drift, size, phase}.
var _sparkles: Array = []
## Per petal: {pos, fall, sway, sway_phase, spin, angle, size, color}.
var _petals: Array = []
var _sparkle_layer: Control
var _petal_layer: Control
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	# The islands drift first; the ribbons and falls then work on the
	# picture with them already moved.
	for island in ISLANDS:
		var mat: ShaderMaterial = _add_shader_rect(island["area"], FLOAT_SHADER).material
		mat.set_shader_parameter("amplitude", 3.5)
		mat.set_shader_parameter("period", _rng.randf_range(5.0, 8.0))
		mat.set_shader_parameter("phase", _rng.randf() * TAU)
		if island.has("edge_fade"):
			mat.set_shader_parameter("edge_fade", island["edge_fade"])
	_recapture()
	var ribbons: ShaderMaterial = _add_shader_rect(RIBBONS_AREA, RIBBONS_SHADER).material
	ribbons.set_shader_parameter("axis_px", COLUMN_X * SIZE.x)
	for fall in WATERFALLS:
		_add_shader_rect(fall, WATERFALL_SHADER)
	for pool in POOL_AREAS:
		var mat: ShaderMaterial = _add_shader_rect(pool, WATER_SHADER).material
		mat.set_shader_parameter("max_shift_px", 1.5)
		mat.set_shader_parameter("speed", 1.0)
		mat.set_shader_parameter("glint_color", Color(1.0, 0.92, 0.85))
		mat.set_shader_parameter("glint_strength", 0.8)
		mat.set_shader_parameter("skip_pale", 1.0)
		mat.set_shader_parameter("edge_fade", Vector4(0.05, 0.15, 0.05, 0.001))

	var column_center := Vector2(COLUMN_X, (COLUMN_TOP + COLUMN_BOTTOM) / 2.0)
	var column_height := (COLUMN_BOTTOM - COLUMN_TOP) * SIZE.y * 1.3
	_column = _add_stretched_glow(column_center, Vector2(110.0, column_height), 0.35, COLUMN_COLOR)
	_column_core = _add_stretched_glow(column_center, Vector2(26.0, column_height), 0.5, Color(0.95, 0.98, 1.0))
	_flare = _add_glow(COLUMN_FLARE, 150.0, 0.45, COLUMN_COLOR)

	for pos in HALOS:
		_halos.append({"glow": _add_glow(pos, 70.0, 0.5, HALO_COLOR), "phase": _rng.randf() * TAU})

	for i in SPARKLE_COUNT:
		_sparkles.append({
			"pos": _random_point(SPARKLE_AREA),
			"drift": Vector2(_rng.randf_range(-4.0, 4.0), _rng.randf_range(-6.0, -1.0)),
			"size": _rng.randf_range(0.8, 1.8),
			"phase": _rng.randf() * TAU,
		})
	_sparkle_layer = _add_draw_layer(_draw_sparkles, true)

	for i in PETAL_COUNT:
		_petals.append({
			"pos": _random_point(PETAL_AREA),
			"fall": _rng.randf_range(18.0, 35.0),
			"sway": _rng.randf_range(10.0, 25.0),
			"sway_phase": _rng.randf() * TAU,
			"spin": _rng.randf_range(-2.5, 2.5),
			"angle": _rng.randf() * TAU,
			"size": _rng.randf_range(4.0, 6.5),
			"color": PETAL_COLORS[_rng.randi() % PETAL_COLORS.size()],
		})
	_petal_layer = _add_draw_layer(_draw_petals)


func _process(delta: float) -> void:
	_time += delta

	# The column surges - a slow swell with quicker shivers - and its heart
	# flares with it.
	var surge := 0.7 + 0.2 * sin(_time * 1.2) + 0.1 * sin(_time * 6.3)
	_column.modulate.a = surge
	_column_core.modulate.a = surge
	_column.scale.x = 0.85 + 0.2 * sin(_time * 1.2)
	_flare.modulate.a = 0.5 + 0.5 * pow(0.5 + 0.5 * sin(_time * 1.2), 2.0)

	for halo in _halos:
		(halo["glow"] as TextureRect).modulate.a = 0.6 + 0.4 * sin(_time * 1.3 + halo["phase"])

	var sky := _area_px(SPARKLE_AREA)
	for s in _sparkles:
		s["pos"] = _wrap(s["pos"] + s["drift"] * delta, sky)

	var field := _area_px(PETAL_AREA)
	for p in _petals:
		var sway: float = cos(_time * 1.2 + p["sway_phase"]) * p["sway"]
		# A light breeze carries them a little to the right as they fall.
		p["pos"] = _wrap(p["pos"] + Vector2(sway + 8.0, p["fall"]) * delta, field)
		p["angle"] += p["spin"] * delta

	_sparkle_layer.queue_redraw()
	_petal_layer.queue_redraw()


func _draw_sparkles(layer: Control) -> void:
	for s in _sparkles:
		var twinkle := pow(0.5 + 0.5 * sin(_time * 2.5 + s["phase"]), 3.0)
		var size: float = s["size"]
		layer.draw_circle(s["pos"], size * 3.0, Color(SPARKLE_COLOR, 0.12 * twinkle))
		layer.draw_circle(s["pos"], size, Color(SPARKLE_COLOR, 0.9 * twinkle))
		# A tiny cross of light on the brightest moments.
		if twinkle > 0.6:
			var arm := size * 4.0 * twinkle
			var c := Color(SPARKLE_COLOR, 0.5 * twinkle)
			layer.draw_line(s["pos"] - Vector2(arm, 0), s["pos"] + Vector2(arm, 0), c, 1.0)
			layer.draw_line(s["pos"] - Vector2(0, arm), s["pos"] + Vector2(0, arm), c, 1.0)


## Each petal: a small oval tumbling as it falls - it narrows to edge-on
## and widens again as it turns.
func _draw_petals(layer: Control) -> void:
	for p in _petals:
		var size: float = p["size"]
		var angle: float = p["angle"]
		var turn := 0.3 + 0.7 * absf(cos(angle * 1.7))
		var points := PackedVector2Array()
		for k in 8:
			var a := k * TAU / 8.0
			var v := Vector2(cos(a) * size, sin(a) * size * 0.55 * turn).rotated(angle)
			points.append(p["pos"] + v)
		layer.draw_colored_polygon(points, Color(p["color"], 0.9))


## A soft glow stretched to `size` (screen pixels), centred on `pos`.
func _add_stretched_glow(pos: Vector2, size: Vector2, strength: float, color: Color) -> TextureRect:
	var glow := _add_glow(pos, 1.0, strength, color)
	glow.size = size
	glow.position = pos * SIZE - size / 2.0
	glow.pivot_offset = size / 2.0
	return glow


func _random_point(area: Rect2) -> Vector2:
	return (area.position + area.size * Vector2(_rng.randf(), _rng.randf())) * SIZE


func _area_px(area: Rect2) -> Rect2:
	return Rect2(area.position * SIZE, area.size * SIZE)


func _wrap(p: Vector2, area: Rect2) -> Vector2:
	return Vector2(area.position.x + fposmod(p.x - area.position.x, area.size.x),
			area.position.y + fposmod(p.y - area.position.y, area.size.y))
