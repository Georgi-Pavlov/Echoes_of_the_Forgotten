extends IntroSceneFX

## Effects over the intro's seventh scene (the wanderer by the campfire,
## reaching toward a window onto the lost world). Everything leads the eye
## to the window: the old world inside it shimmers like a living memory,
## its waterfalls flow, light sweeps across it and its cracked frame
## crackles; golden motes drift out of it into the wanderer's open hand,
## sparks flick off its edges, and every so often it echoes - flaring and
## sending a ring of light out along the cracks. The first echo lands on
## the narration's "But its echoes remain". The rest of the scene is gently
## darkened around it and kept calmer: the campfire flickers, the burning
## planet's cracks surge, red lightning strikes far off beneath it, the
## hanging spires drift, the valley's waterfalls flow and mist creeps
## through it. See IntroSceneFX.gd for how positions and areas are given.

const ECHO_SHADER := preload("res://shaders/intro_echo.gdshader")
const WATERFALL_SHADER := preload("res://shaders/intro_waterfall.gdshader")
const FLAME_SHADER := preload("res://shaders/intro_flame.gdshader")
const SUN_SHADER := preload("res://shaders/intro_molten_sun.gdshader")
const FLOAT_SHADER := preload("res://shaders/intro_float.gdshader")
const MIST_SHADER := preload("res://shaders/intro_mist.gdshader")

## The window's corners, clockwise from the top, and the area its effects
## (window plus cracked frame) cover.
const WINDOW_TOP := Vector2(0.3678, 0.1679)
const WINDOW_RIGHT := Vector2(0.4216, 0.3135)
const WINDOW_BOTTOM := Vector2(0.3541, 0.4803)
const WINDOW_LEFT := Vector2(0.299, 0.3188)
const WINDOW_AREA := Rect2(0.281, 0.09, 0.165, 0.42)
const WINDOW_GLOW_COLOR := Color(1.0, 0.8, 0.5)

## The waterfalls: the one inside the window, then those down in the
## ruined valley.
const WATERFALLS: Array[Rect2] = [
	Rect2(0.332, 0.335, 0.051, 0.1),
	Rect2(0.655, 0.45, 0.04, 0.12),
	Rect2(0.478, 0.4, 0.013, 0.04),
	Rect2(0.76, 0.452, 0.016, 0.04),
	Rect2(0.55, 0.64, 0.027, 0.07),
	Rect2(0.752, 0.77, 0.05, 0.11),
	Rect2(0.88, 0.84, 0.034, 0.08),
]

## Spires and rocks hanging in the sky, drifting up and down.
const DRIFTING: Array[Rect2] = [
	Rect2(0.488, 0.105, 0.04, 0.14),
	Rect2(0.531, 0.16, 0.021, 0.05),
	Rect2(0.544, 0.195, 0.022, 0.065),
	Rect2(0.665, 0.18, 0.026, 0.08),
	Rect2(0.688, 0.14, 0.016, 0.04),
	Rect2(0.711, 0.155, 0.032, 0.11),
	Rect2(0.74, 0.063, 0.028, 0.08),
	Rect2(0.75, 0.22, 0.017, 0.045),
	Rect2(0.782, 0.235, 0.024, 0.075),
	Rect2(0.894, 0.265, 0.018, 0.045),
	Rect2(0.907, 0.195, 0.036, 0.115),
	Rect2(0.919, 0.035, 0.034, 0.14),
	Rect2(0.951, 0.09, 0.026, 0.115),
	Rect2(0.982, 0.175, 0.018, 0.08),
]
const DRIFT_PX := 3.5

## The burning planet: the area its cracks surge in (it fits as an
## ellipse) and the halo of heat around it.
const PLANET_AREA := Rect2(0.759, -0.009, 0.19, 0.338)
const PLANET_POS := Vector2(0.854, 0.16)
const PLANET_GLOW_COLOR := Color(1.0, 0.35, 0.15)
## How hard its cracks flare (intro_molten_sun.gdshader's strength) - well
## below scene 1's sun, as this one is already painted glowing.
const PLANET_HEAT := 0.55

## Red lightning far off on the horizon beneath the planet: the band the
## bolts fall from (cloud base) to (ground), across x.
const BOLT_X_RANGE := Vector2(0.78, 0.93)
const BOLT_TOP_Y := 0.235
const BOLT_BOTTOM_Y := 0.305
const BOLT_GAP_MIN := 1.2
const BOLT_GAP_MAX := 3.5
const BOLT_LIFE := 0.35
const BOLT_COLOR := Color(1.0, 0.2, 0.15)
const BOLT_CORE_COLOR := Color(1.0, 0.75, 0.7)

## Banks of mist lying in the valley: area, density, drift speed.
const MISTS: Array[Dictionary] = [
	{"area": Rect2(0.42, 0.49, 0.58, 0.12), "density": 0.6, "speed": 0.02},
	{"area": Rect2(0.55, 0.59, 0.45, 0.12), "density": 0.65, "speed": 0.025},
	{"area": Rect2(0.48, 0.74, 0.52, 0.18), "density": 0.75, "speed": 0.018},
]
const MIST_COLOR := Color(0.72, 0.63, 0.66)

const PALM_POS := Vector2(0.354, 0.484)

## Seconds after the scene appears that its first echo goes off - the
## narration starts 1s in (Intro.gd's NEXT_VOICE_DELAY), and "But its
## echoes remain" 4.9s into that.
const FIRST_ECHO := 5.9
const ECHO_GAP_MIN := 6.0
const ECHO_GAP_MAX := 8.0

const MOTE_COUNT := 36
const MOTE_COLOR := Color(1.0, 0.85, 0.5)
## Sparks flicked off the window's frame, per second (more on an echo).
const SPARK_RATE := 6.0
const SPARK_COLOR := Color(1.0, 0.7, 0.35)

const FIRE_AREA := Rect2(0.35, 0.68, 0.07, 0.1)
const FIRE_POS := Vector2(0.38, 0.735)

## How dark the scene gets towards the corners, away from the window.
const VIGNETTE_EDGE := 0.8

var _echo: ShaderMaterial
var _halo: TextureRect
var _palm_glow: TextureRect
var _fire_glow: TextureRect
var _echo_t := 100.0
var _next_echo := FIRST_ECHO
## Per mote: {from, ctrl, t, speed, size}. Each drifts along a curve from
## a point in the window to the palm.
var _motes: Array = []
## Per spark: {pos, vel, life, max_life}.
var _sparks: Array = []
var _spark_debt := 0.0
var _mote_layer: Control
var _planet_glow: TextureRect
## Per bolt: {points, branch, age}.
var _bolts: Array = []
var _next_bolt := 0.8
var _bolt_glow: TextureRect
var _bolt_layer: Control
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	_add_vignette()
	var fire := _add_shader_rect(FIRE_AREA, FLAME_SHADER)
	(fire.material as ShaderMaterial).set_shader_parameter("seed", 3.0)
	_fire_glow = _add_glow(FIRE_POS, 200.0, 0.22, Color(1.0, 0.5, 0.2))

	var planet: ShaderMaterial = _add_shader_rect(PLANET_AREA, SUN_SHADER).material
	planet.set_shader_parameter("speed", 1.2)
	planet.set_shader_parameter("strength", PLANET_HEAT)
	for area in DRIFTING:
		var mat: ShaderMaterial = _add_shader_rect(area, FLOAT_SHADER).material
		mat.set_shader_parameter("amplitude", DRIFT_PX)
		mat.set_shader_parameter("period", _rng.randf_range(5.0, 8.0))
		mat.set_shader_parameter("phase", _rng.randf() * TAU)
	for fall in WATERFALLS:
		var mat: ShaderMaterial = _add_shader_rect(fall, WATERFALL_SHADER).material
		mat.set_shader_parameter("speed", 2.2)
	for mist in MISTS:
		var rect := _add_shader_rect(mist["area"], MIST_SHADER)
		var mat: ShaderMaterial = rect.material
		mat.set_shader_parameter("fog_color", MIST_COLOR)
		mat.set_shader_parameter("density", mist["density"])
		mat.set_shader_parameter("speed", mist["speed"])
		mat.set_shader_parameter("aspect", rect.size.x / rect.size.y)
		mat.set_shader_parameter("band_center", 0.5)
		mat.set_shader_parameter("band_height", 0.6)
		mat.set_shader_parameter("edge_fade", Vector4(0.15, 0.3, 0.02, 0.3))

	_planet_glow = _add_glow(PLANET_POS, 330.0, 0.18, PLANET_GLOW_COLOR)
	_bolt_glow = _add_glow(Vector2.ZERO, 170.0, 0.6, BOLT_COLOR)
	_bolt_glow.modulate.a = 0.0
	_bolt_layer = _add_draw_layer(_draw_bolts, true)
	_recapture()
	_echo = _add_shader_rect(WINDOW_AREA, ECHO_SHADER).material
	_echo.set_shader_parameter("top_px", WINDOW_TOP * SIZE)
	_echo.set_shader_parameter("right_px", WINDOW_RIGHT * SIZE)
	_echo.set_shader_parameter("bottom_px", WINDOW_BOTTOM * SIZE)
	_echo.set_shader_parameter("left_px", WINDOW_LEFT * SIZE)

	_halo = _add_glow(_window_center(), 380.0, 0.12, WINDOW_GLOW_COLOR)
	_palm_glow = _add_glow(PALM_POS, 60.0, 0.5, Color(1.0, 0.85, 0.55))

	for i in MOTE_COUNT:
		var mote := _new_mote()
		mote["t"] = _rng.randf()
		_motes.append(mote)
	_mote_layer = _add_draw_layer(_draw_motes, true)


func _process(delta: float) -> void:
	_time += delta

	# The echo: every few seconds the window flares and a ring of light
	# runs out along its cracks.
	if _time >= _next_echo:
		_echo_t = 0.0
		_next_echo = _time + _rng.randf_range(ECHO_GAP_MIN, ECHO_GAP_MAX)
	_echo_t += delta
	_echo.set_shader_parameter("echo_t", _echo_t)
	var echo := exp(-_echo_t * 1.6)

	var breathe := 0.5 + 0.5 * sin(_time * 0.9)
	_halo.modulate.a = 0.7 + 0.3 * breathe + 0.4 * echo
	_halo.scale = Vector2.ONE * (1.0 + 0.04 * breathe + 0.12 * echo)
	_palm_glow.modulate.a = 0.6 + 0.25 * sin(_time * 2.1) + 0.4 * echo

	var flicker := 0.75 + 0.15 * sin(_time * 9.0) + 0.1 * sin(_time * 23.0 + 1.0)
	_fire_glow.modulate.a = flicker

	# The planet's heat swells and ebbs, slower than its cracks surge.
	_planet_glow.modulate.a = 0.75 + 0.25 * sin(_time * 0.7)

	# Distant lightning: every few seconds a bolt (now and then two in
	# quick succession), lighting the cloud base it falls from.
	if _time >= _next_bolt:
		_bolts.append(_new_bolt())
		_next_bolt = _time + (0.15 if _rng.randf() < 0.3 else _rng.randf_range(BOLT_GAP_MIN, BOLT_GAP_MAX))
	var flash := 0.0
	for bolt in _bolts:
		bolt["age"] += delta
		flash = maxf(flash, _bolt_brightness(bolt))
	_bolts = _bolts.filter(func(b): return b["age"] < BOLT_LIFE)
	_bolt_glow.modulate.a = flash
	if not _bolts.is_empty():
		_bolt_glow.position = (_bolts[-1]["points"] as PackedVector2Array)[0] - _bolt_glow.size / 2.0
	_bolt_layer.queue_redraw()

	for mote in _motes:
		mote["t"] += delta * mote["speed"] * (1.0 + 1.5 * echo)
		if mote["t"] >= 1.0:
			mote.merge(_new_mote(), true)

	_spark_debt += delta * SPARK_RATE * (1.0 + 4.0 * echo)
	while _spark_debt >= 1.0:
		_spark_debt -= 1.0
		_sparks.append(_new_spark())
	for spark in _sparks:
		spark["life"] += delta
		spark["vel"] += Vector2(0.0, 30.0) * delta
		spark["pos"] += spark["vel"] * delta
	_sparks = _sparks.filter(func(s): return s["life"] < s["max_life"])

	_mote_layer.queue_redraw()


func _window_center() -> Vector2:
	return (WINDOW_TOP + WINDOW_RIGHT + WINDOW_BOTTOM + WINDOW_LEFT) / 4.0


## A random point inside the window (or on its edge when `on_edge`), in
## screen pixels.
func _window_point(on_edge := false) -> Vector2:
	var corners := [WINDOW_TOP, WINDOW_RIGHT, WINDOW_BOTTOM, WINDOW_LEFT]
	var i := _rng.randi() % 4
	var a: Vector2 = corners[i]
	var b: Vector2 = corners[(i + 1) % 4]
	var p := a.lerp(b, _rng.randf())
	if not on_edge:
		p = p.lerp(_window_center(), _rng.randf_range(0.1, 0.9))
	return p * SIZE


## A mote setting off from somewhere in the window, curving down to the
## palm.
func _new_mote() -> Dictionary:
	var from := _window_point()
	var palm := PALM_POS * SIZE
	var side := Vector2(_rng.randf_range(-60.0, 60.0), _rng.randf_range(-20.0, 20.0))
	return {
		"from": from,
		"ctrl": from.lerp(palm, 0.5) + side,
		"t": 0.0,
		"speed": _rng.randf_range(0.18, 0.35),
		"size": _rng.randf_range(0.8, 1.8),
	}


## A spark flicked outward off the window's edge.
func _new_spark() -> Dictionary:
	var pos := _window_point(true)
	var out := (pos - _window_center() * SIZE).normalized()
	return {
		"pos": pos,
		"vel": out.rotated(_rng.randf_range(-0.6, 0.6)) * _rng.randf_range(25.0, 70.0),
		"life": 0.0,
		"max_life": _rng.randf_range(0.4, 1.0),
	}


func _draw_motes(layer: Control) -> void:
	var palm := PALM_POS * SIZE
	for mote in _motes:
		var t: float = mote["t"]
		# Quadratic curve from the window, past the control point, into
		# the palm - easing in so they gather speed as they're drawn in.
		var e := t * t
		var a: Vector2 = (mote["from"] as Vector2).lerp(mote["ctrl"], e)
		var b: Vector2 = (mote["ctrl"] as Vector2).lerp(palm, e)
		var p := a.lerp(b, e)
		var alpha := sin(t * PI) * (0.7 + 0.3 * sin(_time * 5.0 + t * 20.0))
		layer.draw_circle(p, mote["size"] * 3.0, Color(MOTE_COLOR, 0.12 * alpha))
		layer.draw_circle(p, mote["size"], Color(MOTE_COLOR, 0.85 * alpha))
	for spark in _sparks:
		var k: float = 1.0 - spark["life"] / spark["max_life"]
		var tail: Vector2 = spark["pos"] - (spark["vel"] as Vector2) * 0.05
		layer.draw_line(tail, spark["pos"], Color(SPARK_COLOR, 0.9 * k), 1.2, true)


## A jagged bolt from the cloud base down to the horizon, with a shorter
## fork splitting off partway.
func _new_bolt() -> Dictionary:
	var x := _rng.randf_range(BOLT_X_RANGE.x, BOLT_X_RANGE.y) * SIZE.x
	var top := Vector2(x, BOLT_TOP_Y * SIZE.y)
	var bottom := Vector2(x + _rng.randf_range(-15.0, 15.0), BOLT_BOTTOM_Y * SIZE.y * _rng.randf_range(0.97, 1.0))
	var points := _jagged(top, bottom, 9, 4.0)
	var fork_from := points[_rng.randi_range(3, 5)]
	var fork_to := fork_from + Vector2(_rng.randf_range(10.0, 18.0) * (1 if _rng.randf() < 0.5 else -1), _rng.randf_range(10.0, 18.0))
	return {"points": points, "branch": _jagged(fork_from, fork_to, 4, 2.5), "age": 0.0}


func _jagged(from: Vector2, to: Vector2, segments: int, jitter: float) -> PackedVector2Array:
	var points := PackedVector2Array([from])
	for i in range(1, segments):
		var p := from.lerp(to, float(i) / segments)
		points.append(p + Vector2(_rng.randf_range(-jitter, jitter), 0.0))
	points.append(to)
	return points


## A sharp flash that flickers once more before dying away.
func _bolt_brightness(bolt: Dictionary) -> float:
	var k: float = bolt["age"] / BOLT_LIFE
	return (1.0 - k) * (0.55 + 0.45 * absf(cos(k * 9.0)))


func _draw_bolts(layer: Control) -> void:
	for bolt in _bolts:
		var b := _bolt_brightness(bolt)
		for line in [bolt["points"], bolt["branch"]]:
			layer.draw_polyline(line, Color(BOLT_COLOR, 0.4 * b), 5.0, true)
			layer.draw_polyline(line, Color(BOLT_COLOR, 1.0 * b), 2.0, true)
			layer.draw_polyline(line, Color(BOLT_CORE_COLOR, 0.9 * b), 0.9, true)


## Darkens the scene gently toward the corners, centred on the window, so
## the eye settles there.
func _add_vignette() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1))
	gradient.set_color(1, Color(VIGNETTE_EDGE, VIGNETTE_EDGE, VIGNETTE_EDGE))
	gradient.add_point(0.25, Color(1, 1, 1))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 128
	tex.height = 128

	var rect := TextureRect.new()
	rect.texture = tex
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.mouse_filter = MOUSE_FILTER_IGNORE
	rect.size = Vector2.ONE * 2200.0
	rect.position = _window_center() * SIZE - rect.size / 2.0
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	rect.material = mat
	add_child(rect)
