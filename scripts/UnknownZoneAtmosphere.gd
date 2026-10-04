extends Control
# ------------------------------------------------------------------
# UnknownZoneAtmosphere
# Effects for the hero picker in every zone no hero has been made for
# yet (empty_zone.jpg - a drowned, rocky land lost in mist). ZoneAtmosphere
# creates one of these (and frees it again with the rest of its
# children) when that background is shown, then calls build().
# Purely visual: never takes input, never touches game state.
#
#   - mist so heavy you can't see what's out there: a pale veil over the
#     whole land, and banks of fog in four depths on top of it, each
#     drifting its own way and slowly thickening and thinning, so the
#     rocks only ever half-show through it
#   - rain slanting down over everything, splashing on the water
#   - now and then lightning far off in the mist: a bolt glimpsed through
#     the fog (or just the fog lighting up from somewhere inside it), and
#     a flash that lights the whole scene, flickering before it dies
#   - the dark water rippling
#
# Positions of art features are fractions (0..1) of the background
# image, like ZoneAtmosphere's own.
# ------------------------------------------------------------------

const MIST_SHADER := preload("res://shaders/intro_mist.gdshader")
const WATER_SHADER := preload("res://shaders/intro_water.gdshader")

const MIST_COLOR := Color(0.62, 0.58, 0.68)
## A flat pale veil over the whole land, under the moving fog, so even
## the nearest rocks are muted.
const VEIL_ALPHA := 0.32
# Each bank: the rect it covers (image UV), how thick and how fast (a
# negative speed drifts the other way), how big its billows are, how
# long one slow thicken-and-thin takes, and how far from its middle it
# spreads (band_height). The first one covers the whole picture, the
# rest pile up at their own depths.
const MISTS := [
	{"rect": Rect2(0.0, 0.0, 1.0, 1.0), "density": 0.7, "speed": 0.008, "scale": 2.2, "period": 17.0, "band": 0.9},
	{"rect": Rect2(0.0, 0.2, 1.0, 0.45), "density": 0.85, "speed": 0.012, "scale": 3.0, "period": 11.0, "band": 0.6},
	{"rect": Rect2(0.0, 0.48, 1.0, 0.3), "density": 0.85, "speed": -0.018, "scale": 2.6, "period": 8.5, "band": 0.6},
	{"rect": Rect2(0.0, 0.7, 1.0, 0.3), "density": 0.9, "speed": 0.028, "scale": 2.0, "period": 13.0, "band": 0.6},
]

const WATER_RECT_UV := Rect2(0.08, 0.6, 0.84, 0.37)

## Rain: how many streaks, which way they fall, how fast (in screen
## heights per second) and how often a drop splashes on the water.
const RAIN_COUNT := 260
const RAIN_DIR := Vector2(-0.18, 1.0)
const RAIN_SPEED := Vector2(1.3, 1.8)
const RAIN_COLOR := Color(0.82, 0.8, 0.9, 0.22)
const SPLASH_RATE := 18.0
const SPLASH_LIFE := 0.3
## Where splashes land: the open water, nearer the viewer.
const SPLASH_RECT_UV := Rect2(0.15, 0.68, 0.7, 0.28)

## Lightning: seconds between strikes, how long one lasts, and where far
## off in the mist a bolt can come down (image UV: x range, top, bottom).
## Some strikes show no bolt - only the fog lighting up.
const STRIKE_EVERY := Vector2(5.0, 12.0)
const STRIKE_TIME := 0.9
const BOLT_X_RANGE := Vector2(0.15, 0.85)
const BOLT_TOP_Y := 0.04
const BOLT_BOTTOM_Y := 0.38
const BOLT_CHANCE := 0.65
const FLASH_COLOR := Color(0.78, 0.74, 0.95)
## The fog's colour at the height of a flash, lit from within.
const FLASH_MIST_COLOR := Color(0.86, 0.84, 0.97)
## How much light a flash adds over the whole scene at its brightest.
const FLASH_STRENGTH := 0.28
const BOLT_COLOR := Color(0.9, 0.88, 1.0)

var _atmos: Control
var _background: TextureRect
var _mists: Array[ShaderMaterial] = []
var _bolt_layer: Control
var _rain_layer: Control
var _flash: ColorRect
## Per streak: {pos (local px), speed, length}.
var _rain: Array = []
## Per splash: {pos, age, size}.
var _splashes: Array = []
var _splash_debt := 0.0
## The current strike's age (-1 = none) and its bolt (empty = no bolt).
var _strike_t := -1.0
var _next_strike := 2.5
var _bolt: Array[PackedVector2Array] = []
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func build(atmos: Control, background: TextureRect) -> void:
	_atmos = atmos
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var water: ShaderMaterial = _add_rect(WATER_RECT_UV, WATER_SHADER).material
	water.set_shader_parameter("max_shift_px", 1.2)
	water.set_shader_parameter("speed", 0.9)
	water.set_shader_parameter("glint_color", FLASH_COLOR)
	water.set_shader_parameter("glint_strength", 0.12)
	water.set_shader_parameter("edge_fade", Vector4(0.12, 0.15, 0.12, 0.05))

	# The bolts strike far off, so they're drawn behind all the mist.
	_bolt_layer = _add_draw_layer(_draw_bolt, true)

	var veil := ColorRect.new()
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(MIST_COLOR, VEIL_ALPHA)
	add_child(veil)

	for mist in MISTS:
		var rect := _add_rect(mist["rect"], MIST_SHADER)
		var mat: ShaderMaterial = rect.material
		var whole: bool = mist["rect"].size.y >= 1.0
		mat.set_shader_parameter("fog_color", MIST_COLOR)
		mat.set_shader_parameter("density", mist["density"])
		mat.set_shader_parameter("speed", mist["speed"])
		mat.set_shader_parameter("scale", mist["scale"])
		mat.set_shader_parameter("aspect", rect.size.x / rect.size.y)
		mat.set_shader_parameter("band_center", 0.5)
		mat.set_shader_parameter("band_height", mist["band"])
		mat.set_shader_parameter("edge_fade", Vector4(0.001, 0.001, 0.001, 0.001) if whole else Vector4(0.001, 0.25, 0.001, 0.25))
		_mists.append(mat)

	_flash = ColorRect.new()
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(FLASH_COLOR, 0.0)
	_flash.material = atmos._additive()
	add_child(_flash)

	for i in RAIN_COUNT:
		_rain.append(_new_streak(_rng.randf() * background.size.y))
	_rain_layer = _add_draw_layer(_draw_rain, false)
	set_process(true)


func _process(delta: float) -> void:
	_time += delta

	var flash := _update_lightning(delta)
	# Each bank thickens and thins on its own slow cycle, and glows from
	# within as a flash passes through it.
	var fog_color := MIST_COLOR.lerp(FLASH_MIST_COLOR, flash)
	for i in _mists.size():
		var period: float = MISTS[i]["period"]
		var density: float = MISTS[i]["density"]
		_mists[i].set_shader_parameter("density", density * (0.8 + 0.2 * sin(_time * TAU / period + i * 2.1)))
		_mists[i].set_shader_parameter("fog_color", fog_color)

	_update_rain(delta)
	_bolt_layer.queue_redraw()
	_rain_layer.queue_redraw()


## Every few seconds a strike lights the whole scene. Returns how bright
## the flash is right now (0..1).
func _update_lightning(delta: float) -> float:
	if _strike_t < 0.0 and _time >= _next_strike:
		_strike_t = 0.0
		_bolt.clear()
		if _rng.randf() < BOLT_CHANCE:
			_new_bolt()
	var flash := 0.0
	if _strike_t >= 0.0:
		_strike_t += delta
		if _strike_t >= STRIKE_TIME:
			_strike_t = -1.0
			_next_strike = _time + _rng.randf_range(STRIKE_EVERY.x, STRIKE_EVERY.y)
		else:
			flash = _flash_at(_strike_t)
	_flash.color = Color(FLASH_COLOR, FLASH_STRENGTH * flash)
	return flash


## Brightness through a strike: a sharp first flash, a dip, a second
## smaller flash, then a fading glow.
func _flash_at(t: float) -> float:
	var first := exp(-pow((t - 0.05) / 0.05, 2.0))
	var second := 0.75 * exp(-pow((t - 0.22) / 0.06, 2.0))
	var tail := 0.35 * exp(-maxf(t - 0.25, 0.0) * 5.0) * smoothstep(0.2, 0.26, t)
	return clampf(first + second + tail, 0.0, 1.0)


## A jagged bolt from the clouds down into the mist, with a fork or two.
func _new_bolt() -> void:
	var x := _rng.randf_range(BOLT_X_RANGE.x, BOLT_X_RANGE.y)
	var top: Vector2 = _atmos._image_to_local(Vector2(x, BOLT_TOP_Y))
	var bottom: Vector2 = _atmos._image_to_local(Vector2(x + _rng.randf_range(-0.05, 0.05), BOLT_BOTTOM_Y))
	var main := _jagged(top, bottom, 14, 14.0)
	_bolt.append(main)
	for i in _rng.randi_range(1, 2):
		var from := main[_rng.randi_range(3, 9)]
		var to := from + Vector2(_rng.randf_range(30.0, 70.0) * (1 if _rng.randf() < 0.5 else -1), _rng.randf_range(40.0, 90.0))
		_bolt.append(_jagged(from, to, 6, 8.0))


func _jagged(from: Vector2, to: Vector2, segments: int, jitter: float) -> PackedVector2Array:
	var points := PackedVector2Array([from])
	for i in range(1, segments):
		points.append(from.lerp(to, float(i) / segments) + Vector2(_rng.randf_range(-jitter, jitter), 0.0))
	points.append(to)
	return points


func _update_rain(delta: float) -> void:
	var area := _background.size
	var dir := RAIN_DIR.normalized()
	for streak in _rain:
		var pos: Vector2 = streak["pos"] + dir * streak["speed"] * area.y * delta
		if pos.y > area.y + 20.0:
			streak.merge(_new_streak(-20.0), true)
			continue
		if pos.x < -20.0:
			pos.x += area.x + 40.0
		streak["pos"] = pos

	_splash_debt += delta * SPLASH_RATE
	while _splash_debt >= 1.0:
		_splash_debt -= 1.0
		var uv := SPLASH_RECT_UV.position + Vector2(_rng.randf(), _rng.randf()) * SPLASH_RECT_UV.size
		_splashes.append({"pos": _atmos._image_to_local(uv), "age": 0.0, "size": _rng.randf_range(2.5, 5.0)})
	for splash in _splashes:
		splash["age"] += delta
	_splashes = _splashes.filter(func(s): return s["age"] < SPLASH_LIFE)


func _new_streak(y: float) -> Dictionary:
	return {
		"pos": Vector2(_rng.randf() * (_background.size.x + 150.0), y),
		"speed": _rng.randf_range(RAIN_SPEED.x, RAIN_SPEED.y),
		"length": _rng.randf_range(12.0, 24.0),
	}


func _draw_bolt(layer: Control) -> void:
	if _strike_t < 0.0 or _bolt.is_empty():
		return
	var b := _flash_at(_strike_t)
	for line in _bolt:
		layer.draw_polyline(line, Color(BOLT_COLOR, 0.12 * b), 14.0, true)
		layer.draw_polyline(line, Color(BOLT_COLOR, 0.2 * b), 6.0, true)
		layer.draw_polyline(line, Color(BOLT_COLOR, 0.45 * b), 1.5, true)


func _draw_rain(layer: Control) -> void:
	var dir := RAIN_DIR.normalized()
	# The rain catches the light of a flash.
	var lit := 1.0 + 1.5 * (_flash_at(_strike_t) if _strike_t >= 0.0 else 0.0)
	var color := Color(RAIN_COLOR, minf(RAIN_COLOR.a * lit, 1.0))
	for streak in _rain:
		var head: Vector2 = streak["pos"]
		layer.draw_line(head - dir * streak["length"], head, color, 1.0)
	for splash in _splashes:
		var k: float = splash["age"] / SPLASH_LIFE
		layer.draw_set_transform(splash["pos"], 0.0, Vector2(1.0, 0.35))
		layer.draw_arc(Vector2.ZERO, splash["size"] * (0.4 + k), 0.0, TAU, 12, Color(0.85, 0.83, 0.92, 0.4 * (1.0 - k)), 1.0)
	layer.draw_set_transform(Vector2.ZERO)


## A rect over `rect_uv` of the image drawn with `shader`.
func _add_rect(rect_uv: Rect2, shader: Shader) -> ColorRect:
	var a: Vector2 = _atmos._image_to_local(rect_uv.position)
	var b: Vector2 = _atmos._image_to_local(rect_uv.end)
	var mat := ShaderMaterial.new()
	mat.shader = shader
	var rect := ColorRect.new()
	rect.material = mat
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.position = a
	rect.size = b - a
	add_child(rect)
	return rect


func _add_draw_layer(draw_fn: Callable, additive: bool) -> Control:
	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if additive:
		layer.material = _atmos._additive()
	layer.draw.connect(draw_fn.bind(layer))
	add_child(layer)
	return layer
