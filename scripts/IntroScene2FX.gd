extends IntroSceneFX

## Effects over the intro's second scene (the golden empire at its height):
## islands drifting in the sky, the great galleon and a small airship
## rocking on the wind, waterfalls flowing, the sea and the terrace pool
## glittering, the statues' staff rings glowing with magic, beams of
## sunlight slanting across everything, and flocks of birds flying past.
## See IntroSceneFX.gd for how positions and areas are given; "exclude"
## areas are (left, top, right, bottom).

const FLOAT_SHADER := preload("res://shaders/intro_float.gdshader")
const ROCK_SHADER := preload("res://shaders/intro_rock.gdshader")
const WATERFALL_SHADER := preload("res://shaders/intro_waterfall.gdshader")
const WATER_SHADER := preload("res://shaders/intro_water.gdshader")
const RAYS_SHADER := preload("res://shaders/intro_sun_rays.gdshader")

## Floating islands: area, and up to two areas inside it belonging to a
## neighbour that drifts on its own.
const ISLANDS: Array[Dictionary] = [
	{"area": Rect2(0.333, 0.0, 0.093, 0.2), "edge_fade": Vector4(0.12, 0.001, 0.12, 0.12)},
	{"area": Rect2(0.455, 0.012, 0.048, 0.11)},
	{"area": Rect2(0.598, 0.165, 0.036, 0.09)},
	{"area": Rect2(0.645, 0.195, 0.043, 0.13)},
	{
		"area": Rect2(0.668, 0.015, 0.122, 0.285),
		"exclude_a": Vector4(0.64, 0.193, 0.688, 0.33),
		"exclude_b": Vector4(0.765, 0.175, 0.8, 0.345),
		"edge_fade": Vector4(0.06, 0.06, 0.06, 0.1),
	},
	{"area": Rect2(0.765, 0.172, 0.065, 0.155)},
	{"area": Rect2(0.826, 0.098, 0.047, 0.11)},
]
const ISLAND_DRIFT_PX := 3.5
const ISLAND_PERIOD_MIN := 5.0
const ISLAND_PERIOD_MAX := 8.0

const GALLEON_AREA := Rect2(0.84, 0.03, 0.16, 0.4)
const GALLEON_PIVOT := Vector2(0.93, 0.3)
const AIRSHIP_AREA := Rect2(0.697, 0.292, 0.045, 0.08)
const AIRSHIP_PIVOT := Vector2(0.719, 0.335)

const WATERFALLS: Array[Rect2] = [
	Rect2(0.222, 0.26, 0.023, 0.13),
	Rect2(0.379, 0.352, 0.018, 0.05),
	Rect2(0.64, 0.41, 0.026, 0.065),
	Rect2(0.605, 0.525, 0.03, 0.065),
	Rect2(0.808, 0.588, 0.035, 0.07),
	Rect2(0.514, 0.765, 0.036, 0.145),
	Rect2(0.805, 0.91, 0.032, 0.09),
	Rect2(0.857, 0.93, 0.03, 0.07),
	# Pouring off the big floating island.
	Rect2(0.69, 0.1, 0.017, 0.17),
	Rect2(0.737, 0.1, 0.017, 0.27),
	Rect2(0.757, 0.11, 0.016, 0.15),
]

const SEA_AREAS: Array[Rect2] = [
	Rect2(0.58, 0.52, 0.3, 0.3),
	Rect2(0.86, 0.52, 0.11, 0.085),
]
const POOL_AREA := Rect2(0.0, 0.68, 0.145, 0.1)

## The statues' staff rings (and the right statue's halo), glowing gold.
const MAGIC_GLOWS: Array[Vector2] = [
	Vector2(0.307, 0.154),
	Vector2(0.845, 0.391),
	Vector2(0.866, 0.377),
]
const MAGIC_COLOR := Color(1.0, 0.85, 0.45)

## Birds fly across the upper sky, left to right, in small flocks.
const BIRD_SKY_TOP := 0.05
const BIRD_SKY_BOTTOM := 0.3

## Per glow: {core, halo, phase}.
var _glows: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	# Screen-reading effects, in passes: each later pass re-captures the
	# picture first, so it works on what the earlier passes moved (a ship
	# rocking against a drifting island, a waterfall falling off one).
	for island in ISLANDS:
		_add_island(island)
	_recapture()
	_add_ship(GALLEON_AREA, GALLEON_PIVOT, 1.2, 4.0, {
		"exclude_a": Vector4(0.82, 0.0, 0.875, 0.215),
		"exclude_b": Vector4(0.82, 0.335, 0.885, 0.5),
		"edge_fade": Vector4(0.06, 0.06, 0.001, 0.1),
	})
	_add_ship(AIRSHIP_AREA, AIRSHIP_PIVOT, 2.5, 3.0, {
		"exclude_a": Vector4(0.736, 0.0, 0.76, 0.4),
	})
	_recapture()
	for fall in WATERFALLS:
		_add_shader_rect(fall, WATERFALL_SHADER)
	for sea in SEA_AREAS:
		_add_water(sea, 0.8, Color(1.0, 0.97, 0.88), 1.0)
	_add_water(POOL_AREA, 1.5, Color(1.0, 0.95, 0.8), 0.7)

	var rays := _add_shader_rect(Rect2(0, 0, 1, 1), RAYS_SHADER)
	(rays.material as ShaderMaterial).set_shader_parameter("intensity", 0.16)

	for i in MAGIC_GLOWS.size():
		_glows.append({
			"halo": _add_glow(MAGIC_GLOWS[i], 80.0, 0.45, MAGIC_COLOR),
			"core": _add_glow(MAGIC_GLOWS[i], 12.0, 0.6, Color(1.0, 0.97, 0.85)),
			"phase": i * 2.3,
		})

	var birds := IntroBirds.new()
	birds.sky_top = BIRD_SKY_TOP
	birds.sky_bottom = BIRD_SKY_BOTTOM
	add_child(birds)


func _process(delta: float) -> void:
	_time += delta

	# Staff rings: a slow golden pulse, each out of step, with a quick
	# glint now and then.
	for glow in _glows:
		var t: float = _time + glow["phase"]
		var pulse := 0.6 + 0.3 * sin(t * 1.4) + 0.1 * sin(t * 3.7)
		var glint := pow(maxf(sin(t * 0.7), 0.0), 20.0) * 0.5
		(glow["halo"] as TextureRect).modulate.a = clampf(pulse + glint, 0.0, 1.0)
		(glow["core"] as TextureRect).modulate.a = clampf(pulse * 0.8 + glint * 1.5, 0.0, 1.0)


func _add_island(island: Dictionary) -> void:
	var mat: ShaderMaterial = _add_shader_rect(island["area"], FLOAT_SHADER).material
	mat.set_shader_parameter("amplitude", ISLAND_DRIFT_PX)
	mat.set_shader_parameter("period", _rng.randf_range(ISLAND_PERIOD_MIN, ISLAND_PERIOD_MAX))
	mat.set_shader_parameter("phase", _rng.randf() * TAU)
	for key in ["edge_fade", "exclude_a", "exclude_b"]:
		if island.has(key):
			mat.set_shader_parameter(key, island[key])
	mat.set_shader_parameter("period", _rng.randf_range(ISLAND_PERIOD_MIN, ISLAND_PERIOD_MAX))
	mat.set_shader_parameter("phase", _rng.randf() * TAU)
	for key in ["edge_fade", "exclude_a", "exclude_b"]:
		if island.has(key):
			mat.set_shader_parameter(key, island[key])


func _add_ship(area: Rect2, pivot: Vector2, rock_degrees: float, sway_px: float, extra: Dictionary) -> void:
	var mat: ShaderMaterial = _add_shader_rect(area, ROCK_SHADER).material
	mat.set_shader_parameter("pivot", pivot * SIZE)
	mat.set_shader_parameter("rock_degrees", rock_degrees)
	mat.set_shader_parameter("sway_px", sway_px)
	mat.set_shader_parameter("phase", _rng.randf() * TAU)
	for key in extra:
		mat.set_shader_parameter(key, extra[key])


func _add_water(area: Rect2, shift_px: float, glint_color: Color, glint_strength: float) -> void:
	var mat: ShaderMaterial = _add_shader_rect(area, WATER_SHADER).material
	mat.set_shader_parameter("max_shift_px", shift_px)
	mat.set_shader_parameter("speed", 1.0)
	mat.set_shader_parameter("glint_color", glint_color)
	mat.set_shader_parameter("glint_strength", glint_strength)
	mat.set_shader_parameter("blue_only", 1.0)
	mat.set_shader_parameter("edge_fade", Vector4(0.03, 0.05, 0.03, 0.05))
