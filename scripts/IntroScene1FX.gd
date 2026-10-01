extends IntroSceneFX

## Effects over the intro's first scene (the ruined world, the creature
## crouched at the dark pool): the pool's water rippling and glinting, the
## distant waterfalls flowing, the broken spires hanging in the sky
## drifting gently up and down, the cracked sun throbbing with heat, mist
## drifting through the ruins, the three eyes in the sky smouldering and
## now and then blinking, and the creature's eye glowing out from under its
## hair. See IntroSceneFX.gd for how positions and areas are given.

const MIST_SHADER := preload("res://shaders/intro_mist.gdshader")
const WATER_SHADER := preload("res://shaders/intro_water.gdshader")
const WATERFALL_SHADER := preload("res://shaders/intro_waterfall.gdshader")
const SUN_SHADER := preload("res://shaders/intro_molten_sun.gdshader")
const FLOAT_SHADER := preload("res://shaders/intro_float.gdshader")

const CREATURE_EYE_POS := Vector2(0.428, 0.606)
const CREATURE_EYE_COLOR := Color(1.0, 0.92, 0.75)

const SKY_EYE_POSITIONS: Array[Vector2] = [
	Vector2(0.4587, 0.0946),
	Vector2(0.6112, 0.0797),
	Vector2(0.9737, 0.0925),
]
const SKY_EYE_COLOR := Color(1.0, 0.3, 0.1)
## The cloud colour a blinking eye closes to.
const SKY_LID_COLOR := Color(0.12, 0.1, 0.1)
const BLINK_TIME := 0.35
const BLINK_GAP_MIN := 2.5
const BLINK_GAP_MAX := 6.0

## The sun's disc, as a box it fits inside, and its breathing corona.
const SUN_AREA := Rect2(0.757, 0.055, 0.138, 0.19)
const SUN_CENTER := Vector2(0.826, 0.15)
const SUN_GLOW_COLOR := Color(1.0, 0.55, 0.25)

## Each waterfall, as a box hugging it (left, top, width, height).
const WATERFALLS: Array[Rect2] = [
	Rect2(0.365, 0.33, 0.03, 0.06),
	Rect2(0.462, 0.335, 0.028, 0.08),
	Rect2(0.693, 0.38, 0.055, 0.09),
	Rect2(0.842, 0.395, 0.051, 0.085),
	Rect2(0.588, 0.5, 0.08, 0.085),
	Rect2(0.705, 0.595, 0.025, 0.045),
	Rect2(0.755, 0.595, 0.02, 0.045),
	Rect2(0.788, 0.588, 0.03, 0.052),
]

## Each floating spire, as a box with a little sky around it (left, top,
## width, height).
const SPIRES: Array[Rect2] = [
	Rect2(0.35, 0.14, 0.02, 0.07),
	Rect2(0.375, 0.09, 0.03, 0.11),
	Rect2(0.405, 0.145, 0.016, 0.055),
	Rect2(0.63, 0.17, 0.025, 0.08),
	Rect2(0.655, 0.125, 0.035, 0.125),
	Rect2(0.812, 0.145, 0.034, 0.113),
	Rect2(0.888, 0.18, 0.038, 0.135),
	Rect2(0.93, 0.07, 0.036, 0.14),
]
## How far (in screen pixels) and how slowly the spires drift.
const SPIRE_DRIFT_PX := 3.0
const SPIRE_PERIOD_MIN := 5.0
const SPIRE_PERIOD_MAX := 8.0

var _creature_eye_core: TextureRect
var _creature_eye_halo: TextureRect
var _sun_glow: TextureRect
## Per sky eye: {glow, lid, phase, next_blink, blink_t (-1 = not blinking)}.
var _sky_eyes: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	# The screen-reading effects first, so they all see the plain painting.
	_add_water(Rect2(0.2, 0.755, 0.8, 0.215), Vector2(0.35, 0.44))
	for fall in WATERFALLS:
		_add_shader_rect(fall, WATERFALL_SHADER)
	for spire in SPIRES:
		var mat: ShaderMaterial = _add_shader_rect(spire, FLOAT_SHADER).material
		mat.set_shader_parameter("amplitude", SPIRE_DRIFT_PX)
		mat.set_shader_parameter("period", _rng.randf_range(SPIRE_PERIOD_MIN, SPIRE_PERIOD_MAX))
		mat.set_shader_parameter("phase", _rng.randf() * TAU)
	# One spire hangs in front of the sun: re-capture the picture with the
	# spires moved, so the sun's throbbing is drawn around it where it is
	# now, not where it was painted.
	_recapture()
	_add_shader_rect(SUN_AREA, SUN_SHADER)

	# Three banks of mist: one rolling through the ruins and waterfalls in
	# the distance, one along the valley floor - kept to the right of the
	# creature so it doesn't cover the figure - and a low one creeping
	# across the dark pool, where it shows up best.
	_add_mist(Rect2(0.08, 0.24, 0.92, 0.26), 0.7, 0.03, Vector4(0.15, 0.3, 0.02, 0.3))
	_add_mist(Rect2(0.44, 0.48, 0.56, 0.22), 0.75, 0.035, Vector4(0.3, 0.3, 0.02, 0.35))
	_add_mist(Rect2(0.3, 0.66, 0.7, 0.2), 0.55, 0.04, Vector4(0.25, 0.35, 0.02, 0.35))

	_sun_glow = _add_glow(SUN_CENTER, 340.0, 0.5, SUN_GLOW_COLOR)

	for i in SKY_EYE_POSITIONS.size():
		var pos := SKY_EYE_POSITIONS[i]
		_sky_eyes.append({
			"glow": _add_glow(pos, 64.0, 0.6, SKY_EYE_COLOR),
			"lid": _add_glow(pos, 48.0, 1.0, SKY_LID_COLOR, false),
			"phase": i * 2.1,
			"next_blink": _rng.randf_range(1.0, BLINK_GAP_MAX),
			"blink_t": -1.0,
		})

	_creature_eye_halo = _add_glow(CREATURE_EYE_POS, 70.0, 0.35, CREATURE_EYE_COLOR)
	_creature_eye_core = _add_glow(CREATURE_EYE_POS, 16.0, 1.0, CREATURE_EYE_COLOR)


func _process(delta: float) -> void:
	_time += delta

	# Creature's eye: a slow, uneven pulse - two out-of-step waves - with
	# the occasional brighter flare, like something waking.
	var pulse := 0.55 + 0.25 * sin(_time * 1.7) + 0.2 * sin(_time * 0.63 + 1.0)
	var flare := pow(maxf(sin(_time * 0.45 - 0.8), 0.0), 12.0) * 0.6
	_creature_eye_core.modulate.a = clampf(pulse + flare, 0.0, 1.0)
	_creature_eye_halo.modulate.a = clampf((pulse + flare) * 0.8, 0.0, 1.0)
	_creature_eye_halo.scale = Vector2.ONE * (1.0 + flare * 0.5)

	# The sun's corona breathes slowly.
	_sun_glow.modulate.a = 0.55 + 0.45 * sin(_time * 0.9)

	for eye in _sky_eyes:
		_update_sky_eye(eye, delta)


## A sky eye smoulders - each out of step with the others - and every few
## seconds blinks: the cloud closes over it and its glow dies for a moment.
func _update_sky_eye(eye: Dictionary, delta: float) -> void:
	var closed := 0.0
	if eye["blink_t"] >= 0.0:
		eye["blink_t"] += delta
		var t: float = eye["blink_t"] / BLINK_TIME
		if t >= 1.0:
			eye["blink_t"] = -1.0
			eye["next_blink"] = _time + _rng.randf_range(BLINK_GAP_MIN, BLINK_GAP_MAX)
		else:
			closed = sin(t * PI)
	elif _time >= eye["next_blink"]:
		eye["blink_t"] = 0.0

	var glow_pulse := 0.6 + 0.4 * sin(_time * 1.3 + eye["phase"])
	(eye["glow"] as TextureRect).modulate.a = glow_pulse * (1.0 - closed)
	var lid: TextureRect = eye["lid"]
	lid.modulate.a = closed
	lid.scale = Vector2(1.0, 0.4 + 0.6 * closed)


func _add_mist(area: Rect2, density: float, speed: float, edge_fade: Vector4) -> void:
	var rect := _add_shader_rect(area, MIST_SHADER)
	var mat: ShaderMaterial = rect.material
	mat.set_shader_parameter("fog_color", Color(0.86, 0.84, 0.86))
	mat.set_shader_parameter("density", density)
	mat.set_shader_parameter("speed", speed)
	mat.set_shader_parameter("scale", 3.0)
	mat.set_shader_parameter("aspect", rect.size.x / rect.size.y)
	mat.set_shader_parameter("band_center", 0.5)
	mat.set_shader_parameter("band_height", 0.55)
	mat.set_shader_parameter("edge_fade", edge_fade)


func _add_water(area: Rect2, cut: Vector2) -> void:
	var rect := _add_shader_rect(area, WATER_SHADER)
	(rect.material as ShaderMaterial).set_shader_parameter("cut", cut)
