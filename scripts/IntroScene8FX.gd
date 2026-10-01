extends IntroSceneFX

## Effects over the intro's eighth and last scene (the warrior squaring up
## to the corrupted giant): the moment before the clash. The warrior's
## blade burns, light running along it and sparks dripping from it; the
## giant breathes, its crown of branches swaying, the wound in its chest
## throbbing like a heart and its eye sockets smouldering. Dark rain falls,
## splashing in the shallows, embers rise from the debris, and behind them
## the planet burns, the eye glares, spires drift, waterfalls
## flow and mist rolls through the valley. It builds with the narration:
## the blade flares on "Fight your way to the throne", and on the last line
## blade and wound blaze, the ground shakes and light floods the scene as
## the intro fades out. See IntroSceneFX.gd for how positions and areas are
## given.

const BREATHE_SHADER := preload("res://shaders/intro_breathe.gdshader")
const HEART_SHADER := preload("res://shaders/intro_heart.gdshader")
const BLADE_SHADER := preload("res://shaders/intro_blade.gdshader")
const SHAKE_SHADER := preload("res://shaders/intro_shake.gdshader")
const SUN_SHADER := preload("res://shaders/intro_molten_sun.gdshader")
const FLOAT_SHADER := preload("res://shaders/intro_float.gdshader")
const WATERFALL_SHADER := preload("res://shaders/intro_waterfall.gdshader")
const WATER_SHADER := preload("res://shaders/intro_water.gdshader")
const MIST_SHADER := preload("res://shaders/intro_mist.gdshader")

## Seconds after the scene appears that the narration beats land - the
## narration starts 1s in (Intro.gd's NEXT_VOICE_DELAY): "Fight your way to
## the throne" at 27.9s into it, the last line at 30.0s.
const THRONE_BEAT := 28.9
const FINALE_START := 31.0
## How long the finale takes to build to its height.
const FINALE_RISE := 1.8

## The blade: its base just past the guard, and its tip.
const BLADE_BASE := Vector2(0.4635, 0.6748)
const BLADE_TIP := Vector2(0.6029, 0.7407)
const BLADE_AREA := Rect2(0.45, 0.63, 0.165, 0.13)
const BLADE_COLOR := Color(1.0, 0.7, 0.35)
const SPARK_RATE := 7.0

## The giant: the area that breathes and the point at its feet it's
## anchored to; the wound's area and core; its eye sockets.
const GIANT_AREA := Rect2(0.47, 0.0, 0.47, 0.66)
const GIANT_PIVOT := Vector2(0.71, 0.7)
const WOUND_AREA := Rect2(0.62, 0.19, 0.18, 0.35)
const WOUND_CORE := Vector2(0.689, 0.324)
const WOUND_COLOR := Color(1.0, 0.15, 0.1)
## Each socket: position and glow size in screen pixels.
const GIANT_EYES: Array[Dictionary] = [
	{"pos": Vector2(0.57, 0.337), "size": 30.0},
	{"pos": Vector2(0.5425, 0.356), "size": 22.0},
]
const GIANT_EYE_COLOR := Color(1.0, 0.2, 0.1)

## The eye in the sky.
const SKY_EYE_POS := Vector2(0.3236, 0.0606)
const SKY_EYE_COLOR := Color(1.0, 0.25, 0.15)

const PLANET_AREA := Rect2(0.105, 0.075, 0.2, 0.27)
const PLANET_POS := Vector2(0.192, 0.235)
const PLANET_HEAT := 0.55

const DRIFTING: Array[Rect2] = [
	Rect2(0.395, 0.15, 0.04, 0.105),
	Rect2(0.153, 0.015, 0.03, 0.06),
	Rect2(0.383, 0.252, 0.012, 0.05),
	Rect2(0.351, 0.188, 0.018, 0.06),
]
const DRIFT_PX := 3.5

const WATERFALLS: Array[Rect2] = [
	Rect2(0.213, 0.36, 0.03, 0.12),
	Rect2(0.264, 0.37, 0.026, 0.13),
	Rect2(0.302, 0.38, 0.03, 0.08),
]

## The shallows around the warrior's feet.
const WATER_AREA := Rect2(0.3, 0.86, 0.5, 0.08)

const MISTS: Array[Dictionary] = [
	{"area": Rect2(0.0, 0.38, 0.37, 0.12), "density": 0.55, "speed": 0.02},
	{"area": Rect2(0.12, 0.32, 0.3, 0.07), "density": 0.3, "speed": 0.015},
]
const MIST_COLOR := Color(0.7, 0.62, 0.64)

## Rain: how many streaks, which way they fall (wind from the right, as
## the cloak streams) and how fast, and how often a drop splashes in the
## shallows.
const RAIN_COUNT := 170
const RAIN_DIR := Vector2(-0.22, 1.0)
const RAIN_SPEED := Vector2(750.0, 1050.0)
const RAIN_COLOR := Color(0.85, 0.8, 0.82, 0.32)
const SPLASH_RATE := 14.0
const SPLASH_LIFE := 0.35

## Where embers rise from: centre and half-extent, both as fractions.
const EMBER_SOURCES: Array[Dictionary] = [
	{"pos": Vector2(0.1, 0.92), "extent": Vector2(0.09, 0.03), "amount": 16},
	{"pos": Vector2(0.8, 0.92), "extent": Vector2(0.1, 0.03), "amount": 14},
	{"pos": Vector2(0.52, 0.9), "extent": Vector2(0.04, 0.015), "amount": 8},
]
const EMBER_COLOR := Color(1.0, 0.55, 0.2)

const FINALE_LIGHT := Color(1.0, 0.6, 0.35)
const SHAKE_PX := 4.0

var _blade: ShaderMaterial
var _heart: ShaderMaterial
var _shake: ShaderMaterial
var _blade_glow: TextureRect
## A wide blaze round the blade, shown only when it flares.
var _blade_flare_glow: TextureRect
var _wound_glow: TextureRect
var _planet_glow: TextureRect
var _giant_eyes: Array[TextureRect] = []
var _sky_eye_glow: TextureRect
var _finale_light: ColorRect
## Per streak: {pos, speed, length}.
var _rain: Array = []
## Per splash: {pos, age, size}.
var _splashes: Array = []
var _splash_debt := 0.0
## Per spark: {pos, vel, life, max_life}.
var _sparks: Array = []
var _spark_debt := 0.0
var _rain_layer: Control
var _spark_layer: Control
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	# First everything that moves the painting itself, all reading it as
	# painted; then the glows that work on the moved picture.
	var giant: ShaderMaterial = _add_shader_rect(GIANT_AREA, BREATHE_SHADER).material
	giant.set_shader_parameter("pivot_px", GIANT_PIVOT * SIZE)
	var planet: ShaderMaterial = _add_shader_rect(PLANET_AREA, SUN_SHADER).material
	planet.set_shader_parameter("speed", 1.2)
	planet.set_shader_parameter("strength", PLANET_HEAT)
	for area in DRIFTING:
		var mat: ShaderMaterial = _add_shader_rect(area, FLOAT_SHADER).material
		mat.set_shader_parameter("amplitude", DRIFT_PX)
		mat.set_shader_parameter("period", _rng.randf_range(5.0, 8.0))
		mat.set_shader_parameter("phase", _rng.randf() * TAU)
	for fall in WATERFALLS:
		_add_shader_rect(fall, WATERFALL_SHADER)
	var water: ShaderMaterial = _add_shader_rect(WATER_AREA, WATER_SHADER).material
	water.set_shader_parameter("max_shift_px", 2.0)
	water.set_shader_parameter("edge_fade", Vector4(0.1, 0.3, 0.1, 0.2))
	_recapture()

	_heart = _add_shader_rect(WOUND_AREA, HEART_SHADER).material
	_heart.set_shader_parameter("core_px", WOUND_CORE * SIZE)
	_blade = _add_shader_rect(BLADE_AREA, BLADE_SHADER).material
	_blade.set_shader_parameter("base_px", BLADE_BASE * SIZE)
	_blade.set_shader_parameter("tip_px", BLADE_TIP * SIZE)

	for mist in MISTS:
		var rect := _add_shader_rect(mist["area"], MIST_SHADER)
		var mat: ShaderMaterial = rect.material
		mat.set_shader_parameter("fog_color", MIST_COLOR)
		mat.set_shader_parameter("density", mist["density"])
		mat.set_shader_parameter("speed", mist["speed"])
		mat.set_shader_parameter("aspect", rect.size.x / rect.size.y)
		mat.set_shader_parameter("band_center", 0.5)
		mat.set_shader_parameter("band_height", 0.6)
		mat.set_shader_parameter("edge_fade", Vector4(0.15, 0.3, 0.15, 0.3))

	_planet_glow = _add_glow(PLANET_POS, 300.0, 0.16, Color(1.0, 0.35, 0.15))
	_wound_glow = _add_glow(WOUND_CORE, 240.0, 0.22, WOUND_COLOR)
	for eye in GIANT_EYES:
		_giant_eyes.append(_add_glow(eye["pos"], eye["size"], 0.8, GIANT_EYE_COLOR))
	_sky_eye_glow = _add_glow(SKY_EYE_POS, 60.0, 0.6, SKY_EYE_COLOR)
	_blade_glow = _add_blade_glow(Vector2(1.25, 34.0), 0.35)
	_blade_flare_glow = _add_blade_glow(Vector2(1.7, 110.0), 0.55)
	_blade_flare_glow.modulate.a = 0.0

	for source in EMBER_SOURCES:
		_add_embers(source)
	for i in RAIN_COUNT:
		_rain.append(_new_streak(_rng.randf() * SIZE.y))
	_rain_layer = _add_draw_layer(_draw_rain)
	_spark_layer = _add_draw_layer(_draw_sparks, true)

	_finale_light = ColorRect.new()
	_finale_light.mouse_filter = MOUSE_FILTER_IGNORE
	_finale_light.set_anchors_preset(PRESET_FULL_RECT)
	_finale_light.color = Color(FINALE_LIGHT, 0.0)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_finale_light.material = add
	add_child(_finale_light)

	# Last, so it shakes everything above.
	_recapture()
	_shake = _add_shader_rect(Rect2(Vector2.ZERO, Vector2.ONE), SHAKE_SHADER).material


func _process(delta: float) -> void:
	_time += delta

	# The narration beats: a single flare of the blade for the throne, then
	# the finale building and holding through the fade-out.
	var throne := exp(-pow((_time - THRONE_BEAT - 0.4) / 0.5, 2.0))
	var finale := smoothstep(FINALE_START, FINALE_START + FINALE_RISE, _time)

	var blade_flare := maxf(throne, finale)
	_blade.set_shader_parameter("flare", blade_flare)
	_blade_glow.modulate.a = 0.55 + 0.15 * sin(_time * 2.3) + 0.1 * sin(_time * 7.9) + 0.9 * blade_flare
	_blade_flare_glow.modulate.a = blade_flare
	_heart.set_shader_parameter("flare", finale)

	# The wound's glow beats with it (same lub-dub as intro_heart.gdshader,
	# at the core).
	var phase := fposmod(_time / 2.4, 1.0)
	var beat := exp(-pow((phase - 0.08) * 18.0, 2.0)) + 0.65 * exp(-pow((phase - 0.24) * 18.0, 2.0))
	_wound_glow.modulate.a = 0.4 + 0.6 * beat + 1.5 * finale
	for i in _giant_eyes.size():
		_giant_eyes[i].modulate.a = 0.35 + 0.25 * sin(_time * 0.8 + i) + 0.5 * beat * 0.4 + finale
	_planet_glow.modulate.a = 0.75 + 0.25 * sin(_time * 0.7)
	_sky_eye_glow.modulate.a = 0.7 + 0.3 * sin(_time * 1.2)

	_finale_light.color = Color(FINALE_LIGHT, 0.18 * finale)
	var shake := finale * (1.0 - smoothstep(FINALE_START + FINALE_RISE, FINALE_START + FINALE_RISE + 2.5, _time))
	_shake.set_shader_parameter("offset_px", Vector2(
			_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * SHAKE_PX * shake)

	_update_rain(delta)
	_update_sparks(delta, blade_flare)
	_rain_layer.queue_redraw()
	_spark_layer.queue_redraw()


func _update_rain(delta: float) -> void:
	var dir := RAIN_DIR.normalized()
	for streak in _rain:
		var pos: Vector2 = streak["pos"] + dir * streak["speed"] * delta
		if pos.y > SIZE.y + 20.0:
			streak.merge(_new_streak(-20.0), true)
			continue
		if pos.x < -20.0:
			pos.x += SIZE.x + 40.0
		streak["pos"] = pos

	_splash_debt += delta * SPLASH_RATE
	while _splash_debt >= 1.0:
		_splash_debt -= 1.0
		_splashes.append({
			"pos": (WATER_AREA.position + Vector2(_rng.randf(), _rng.randf()) * WATER_AREA.size) * SIZE,
			"age": 0.0,
			"size": _rng.randf_range(3.0, 6.0),
		})
	for splash in _splashes:
		splash["age"] += delta
	_splashes = _splashes.filter(func(s): return s["age"] < SPLASH_LIFE)


func _new_streak(y: float) -> Dictionary:
	return {
		"pos": Vector2(_rng.randf() * (SIZE.x + 200.0), y),
		"speed": _rng.randf_range(RAIN_SPEED.x, RAIN_SPEED.y),
		"length": _rng.randf_range(10.0, 20.0),
	}


## Sparks shaken off the burning blade, mostly near the tip, falling away
## - more of them when it flares.
func _update_sparks(delta: float, flare: float) -> void:
	_spark_debt += delta * SPARK_RATE * (1.0 + 4.0 * flare)
	var base := BLADE_BASE * SIZE
	var tip := BLADE_TIP * SIZE
	while _spark_debt >= 1.0:
		_spark_debt -= 1.0
		_sparks.append({
			"pos": base.lerp(tip, sqrt(_rng.randf())),
			"vel": Vector2(_rng.randf_range(-25.0, 35.0), _rng.randf_range(-40.0, 10.0)),
			"life": 0.0,
			"max_life": _rng.randf_range(0.4, 1.0),
		})
	for spark in _sparks:
		spark["life"] += delta
		spark["vel"] += Vector2(0.0, 90.0) * delta
		spark["pos"] += spark["vel"] * delta
	_sparks = _sparks.filter(func(s): return s["life"] < s["max_life"])


func _draw_rain(layer: Control) -> void:
	var dir := RAIN_DIR.normalized()
	for streak in _rain:
		var head: Vector2 = streak["pos"]
		layer.draw_line(head - dir * streak["length"], head, RAIN_COLOR, 1.0)
	for splash in _splashes:
		var k: float = splash["age"] / SPLASH_LIFE
		var r: float = splash["size"] * (0.4 + k)
		layer.draw_set_transform(splash["pos"], 0.0, Vector2(1.0, 0.35))
		layer.draw_arc(Vector2.ZERO, r, 0.0, TAU, 12, Color(0.9, 0.85, 0.85, 0.5 * (1.0 - k)), 1.0)
	layer.draw_set_transform(Vector2.ZERO)


func _draw_sparks(layer: Control) -> void:
	for spark in _sparks:
		var k: float = 1.0 - spark["life"] / spark["max_life"]
		layer.draw_circle(spark["pos"], 1.2, Color(BLADE_COLOR, 0.9 * k))
		layer.draw_circle(spark["pos"], 3.0, Color(BLADE_COLOR, 0.15 * k))


## A long soft glow laid along the blade: `stretch` is its length (times
## the blade's) and its thickness in screen pixels.
func _add_blade_glow(stretch: Vector2, strength: float) -> TextureRect:
	var base := BLADE_BASE * SIZE
	var tip := BLADE_TIP * SIZE
	var mid := (base + tip) / 2.0
	var glow := _add_glow(mid / SIZE, 1.0, strength, BLADE_COLOR)
	glow.size = Vector2(base.distance_to(tip) * stretch.x, stretch.y)
	glow.position = mid - glow.size / 2.0
	glow.pivot_offset = glow.size / 2.0
	glow.rotation = (tip - base).angle()
	return glow


## Embers rising from glowing debris and fading.
func _add_embers(source: Dictionary) -> void:
	var ramp := Gradient.new()
	ramp.set_color(0, Color(EMBER_COLOR, 0.0))
	ramp.set_color(1, Color(EMBER_COLOR, 0.0))
	ramp.add_point(0.15, Color(EMBER_COLOR, 1.0))
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	var p := CPUParticles2D.new()
	p.material = add
	p.position = source["pos"] * SIZE
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = source["extent"] * SIZE
	p.amount = source["amount"]
	p.lifetime = 2.4
	p.direction = Vector2(-0.3, -1.0)
	p.spread = 25.0
	p.gravity = Vector2(-8.0, -12.0)
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 50.0
	p.tangential_accel_min = -10.0
	p.tangential_accel_max = 10.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.2
	p.color_ramp = ramp
	p.preprocess = 2.0
	add_child(p)
