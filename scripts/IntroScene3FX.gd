extends IntroSceneFX

## Effects over the intro's third scene (the green golden age - the
## valley, the village, the shepherd and his flock): the brook tumbling
## over its rocks, the river glittering, waterfalls flowing, the mill
## wheel turning, smoke curling from the chimneys, wind rolling across the
## wheat, the old oak's leaves rustling, butterflies over the meadow, birds
## passing the mountains, and sunbeams slanting through the canopy with
## pollen drifting in them. See IntroSceneFX.gd for how positions and
## areas are given.

const STREAM_SHADER := preload("res://shaders/intro_stream.gdshader")
const WATER_SHADER := preload("res://shaders/intro_water.gdshader")
const WATERFALL_SHADER := preload("res://shaders/intro_waterfall.gdshader")
const SPIN_SHADER := preload("res://shaders/intro_spin.gdshader")
const WHEAT_SHADER := preload("res://shaders/intro_wheat.gdshader")
const FOLIAGE_SHADER := preload("res://shaders/intro_foliage.gdshader")
const RAYS_SHADER := preload("res://shaders/intro_sun_rays.gdshader")

## The wheat field, in two parts - the left one stops short of the deer,
## whose golden back would ripple too. The ripple is worked out in screen
## space, so the two parts join without a seam.
const WHEAT_AREAS: Array[Dictionary] = [
	{"area": Rect2(0.26, 0.47, 0.15, 0.09), "edge_fade": Vector4(0.15, 0.15, 0.001, 0.2)},
	{"area": Rect2(0.41, 0.47, 0.45, 0.2), "edge_fade": Vector4(0.001, 0.15, 0.08, 0.15)},
]

## The foreground brook, in stretches, each with the way its water runs.
const BROOK: Array[Dictionary] = [
	{"area": Rect2(0.37, 0.745, 0.14, 0.13), "flow": Vector2(0.7, 0.7)},
	{"area": Rect2(0.44, 0.83, 0.36, 0.17), "flow": Vector2(1.0, 0.25)},
]
const RIVER_AREAS: Array[Rect2] = [
	Rect2(0.62, 0.535, 0.32, 0.13),
	Rect2(0.74, 0.67, 0.22, 0.14),
]
const WATERFALLS: Array[Rect2] = [
	Rect2(0.683, 0.15, 0.03, 0.075),
	Rect2(0.532, 0.285, 0.04, 0.08),
	Rect2(0.598, 0.315, 0.012, 0.055),
	Rect2(0.82, 0.265, 0.028, 0.08),
	Rect2(0.88, 0.255, 0.02, 0.075),
	Rect2(0.918, 0.232, 0.02, 0.083),
	Rect2(0.677, 0.46, 0.036, 0.085),
	Rect2(0.76, 0.46, 0.022, 0.04),
]

## The mill wheel: centre and half-width/half-height (it's seen at an
## angle, so it's an upright ellipse).
const WHEEL_CENTER := Vector2(0.5467, 0.532)
const WHEEL_RADII := Vector2(0.0092, 0.024)
const WHEEL_SPEED := 0.7

const CHIMNEYS: Array[Vector2] = [
	Vector2(0.302, 0.433),
	Vector2(0.517, 0.468),
]

## The old oak's canopy (its trunk is off to the left, outside this): the
## leaves spreading across the top, and the lower boughs on the left -
## leaving out the mountains that show beneath the leaves.
const CANOPY_AREAS: Array[Rect2] = [
	Rect2(0.12, 0.0, 0.42, 0.14),
	Rect2(0.12, 0.0, 0.18, 0.33),
]

const BIRD_SKY_TOP := 0.03
const BIRD_SKY_BOTTOM := 0.14

## Butterflies flutter about inside these meadow areas, so many in each.
const BUTTERFLY_MEADOWS: Array[Dictionary] = [
	{"area": Rect2(0.04, 0.6, 0.55, 0.32), "count": 4},
	{"area": Rect2(0.74, 0.74, 0.24, 0.2), "count": 2},
]
const BUTTERFLY_COLORS: Array[Color] = [
	Color(0.98, 0.97, 0.92),
	Color(1.0, 0.85, 0.3),
	Color(1.0, 0.55, 0.15),
	Color(0.7, 0.85, 1.0),
]

## Pollen drifts in the sunbeams falling through the canopy.
const POLLEN_AREA := Rect2(0.08, 0.08, 0.5, 0.55)
const POLLEN_COUNT := 40

## Per butterfly: {pos, heading, speed, size, color, flap_phase, area}.
var _butterflies: Array = []
## Per speck: {pos, drift, size, twinkle_phase}.
var _pollen: Array = []
var _butterfly_layer: Control
var _pollen_layer: Control
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	# The wheat first: the mill wheel sits on its edge and has golden
	# spokes, and the wheel (drawn after) must win there.
	for wheat in WHEAT_AREAS:
		var mat: ShaderMaterial = _add_shader_rect(wheat["area"], WHEAT_SHADER).material
		mat.set_shader_parameter("edge_fade", wheat["edge_fade"])
	for stretch in BROOK:
		var mat: ShaderMaterial = _add_shader_rect(stretch["area"], STREAM_SHADER).material
		mat.set_shader_parameter("flow", stretch["flow"])
	for river in RIVER_AREAS:
		var mat: ShaderMaterial = _add_shader_rect(river, WATER_SHADER).material
		mat.set_shader_parameter("max_shift_px", 1.0)
		mat.set_shader_parameter("speed", 1.0)
		mat.set_shader_parameter("glint_color", Color(1.0, 0.97, 0.88))
		mat.set_shader_parameter("glint_strength", 1.0)
		mat.set_shader_parameter("blue_only", 1.0)
		mat.set_shader_parameter("edge_fade", Vector4(0.03, 0.05, 0.03, 0.05))
	for fall in WATERFALLS:
		_add_shader_rect(fall, WATERFALL_SHADER)
	_add_wheel()

	for chimney in CHIMNEYS:
		_add_smoke(chimney)

	var birds := IntroBirds.new()
	birds.sky_top = BIRD_SKY_TOP
	birds.sky_bottom = BIRD_SKY_BOTTOM
	add_child(birds)

	# The oak is in the foreground: re-capture, so smoke and birds passing
	# behind its canopy go behind the leaves - and rustle with them.
	_recapture()
	for canopy in CANOPY_AREAS:
		_add_shader_rect(canopy, FOLIAGE_SHADER)

	var rays: ShaderMaterial = _add_shader_rect(Rect2(0, 0, 1, 1), RAYS_SHADER).material
	rays.set_shader_parameter("origin", Vector2(0.12, -0.12))
	rays.set_shader_parameter("direction", 0.55)
	rays.set_shader_parameter("spread", 0.6)
	rays.set_shader_parameter("intensity", 0.18)

	for i in POLLEN_COUNT:
		_pollen.append({
			"pos": (POLLEN_AREA.position + POLLEN_AREA.size * Vector2(_rng.randf(), _rng.randf())) * SIZE,
			"drift": Vector2(_rng.randf_range(2.0, 7.0), _rng.randf_range(-4.0, 1.0)),
			"size": _rng.randf_range(0.8, 1.8),
			"twinkle_phase": _rng.randf() * TAU,
		})
	_pollen_layer = _add_draw_layer(_draw_pollen, true)

	for meadow in BUTTERFLY_MEADOWS:
		for i in meadow["count"]:
			var area: Rect2 = meadow["area"]
			_butterflies.append({
				"pos": (area.position + area.size * Vector2(_rng.randf(), _rng.randf())) * SIZE,
				"heading": _rng.randf() * TAU,
				"speed": _rng.randf_range(25.0, 45.0),
				"size": _rng.randf_range(3.5, 5.5),
				"color": BUTTERFLY_COLORS[_rng.randi() % BUTTERFLY_COLORS.size()],
				"flap_phase": _rng.randf() * TAU,
				"area": Rect2(area.position * SIZE, area.size * SIZE),
			})
	_butterfly_layer = _add_draw_layer(_draw_butterflies)


func _process(delta: float) -> void:
	_time += delta

	# Butterflies wander: their heading jitters constantly, and they turn
	# back towards the middle of their meadow when they stray to its edge.
	for b in _butterflies:
		var area: Rect2 = b["area"]
		b["heading"] += _rng.randf_range(-4.0, 4.0) * delta
		if not area.grow(-10.0).has_point(b["pos"]):
			var home: float = (area.get_center() - b["pos"]).angle()
			b["heading"] = lerp_angle(b["heading"], home, 3.0 * delta)
		b["pos"] += Vector2.from_angle(b["heading"]) * b["speed"] * delta

	# Pollen drifts lazily, wrapping round inside its patch of sunlight.
	var patch := Rect2(POLLEN_AREA.position * SIZE, POLLEN_AREA.size * SIZE)
	for speck in _pollen:
		var wander := Vector2(sin(_time * 0.7 + speck["twinkle_phase"]), cos(_time * 0.5 + speck["twinkle_phase"])) * 3.0
		var p: Vector2 = speck["pos"] + (speck["drift"] + wander) * delta
		p.x = patch.position.x + fposmod(p.x - patch.position.x, patch.size.x)
		p.y = patch.position.y + fposmod(p.y - patch.position.y, patch.size.y)
		speck["pos"] = p

	_butterfly_layer.queue_redraw()
	_pollen_layer.queue_redraw()


## Each butterfly: two pairs of wings - big forewings, smaller hindwings -
## flapping fast (they fold to edge-on and open again), and a dark body.
func _draw_butterflies(layer: Control) -> void:
	for b in _butterflies:
		var pos: Vector2 = b["pos"]
		var size: float = b["size"]
		var color: Color = b["color"]
		var open := absf(sin(_time * 14.0 + b["flap_phase"]))
		var span := size * (0.25 + 0.75 * open)
		for side in [-1.0, 1.0]:
			layer.draw_colored_polygon(PackedVector2Array([
				pos,
				pos + Vector2(side * span, -size * 0.9),
				pos + Vector2(side * span * 1.1, -size * 0.1),
			]), color)
			layer.draw_colored_polygon(PackedVector2Array([
				pos,
				pos + Vector2(side * span * 0.8, size * 0.1),
				pos + Vector2(side * span * 0.55, size * 0.7),
			]), color.darkened(0.15))
		layer.draw_line(pos + Vector2(0, -size * 0.4), pos + Vector2(0, size * 0.5), Color(0.15, 0.12, 0.1), 1.0)


func _draw_pollen(layer: Control) -> void:
	for speck in _pollen:
		var twinkle := 0.4 + 0.6 * pow(0.5 + 0.5 * sin(_time * 2.0 + speck["twinkle_phase"]), 2.0)
		layer.draw_circle(speck["pos"], speck["size"] * 2.2, Color(1.0, 0.9, 0.6, 0.12 * twinkle))
		layer.draw_circle(speck["pos"], speck["size"], Color(1.0, 0.95, 0.75, 0.6 * twinkle))


func _add_wheel() -> void:
	var center := WHEEL_CENTER * SIZE
	var radii := WHEEL_RADII * SIZE
	var area := Rect2((center - radii * 1.05) / SIZE, radii * 2.1 / SIZE)
	var mat: ShaderMaterial = _add_shader_rect(area, SPIN_SHADER).material
	mat.set_shader_parameter("center_px", center)
	mat.set_shader_parameter("radii_px", radii)
	mat.set_shader_parameter("speed", WHEEL_SPEED)


## A thin column of chimney smoke: soft puffs that rise, swell, drift off
## downwind and fade.
func _add_smoke(chimney: Vector2) -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	var puff := GradientTexture2D.new()
	puff.gradient = gradient
	puff.fill = GradientTexture2D.FILL_RADIAL
	puff.fill_from = Vector2(0.5, 0.5)
	puff.fill_to = Vector2(1.0, 0.5)
	puff.width = 32
	puff.height = 32

	var fade := Gradient.new()
	fade.set_color(0, Color(0.92, 0.9, 0.88, 0.0))
	fade.add_point(0.15, Color(0.92, 0.9, 0.88, 0.45))
	fade.set_color(fade.get_point_count() - 1, Color(0.95, 0.94, 0.93, 0.0))
	var swell := Curve.new()
	swell.add_point(Vector2(0.0, 0.25))
	swell.add_point(Vector2(1.0, 1.0))

	var smoke := CPUParticles2D.new()
	smoke.position = chimney * SIZE
	smoke.texture = puff
	smoke.amount = 16
	smoke.lifetime = 5.0
	smoke.preprocess = 5.0
	smoke.direction = Vector2.UP
	smoke.spread = 8.0
	smoke.gravity = Vector2(4.0, -1.0)
	smoke.initial_velocity_min = 9.0
	smoke.initial_velocity_max = 14.0
	smoke.scale_amount_min = 0.35
	smoke.scale_amount_max = 0.6
	smoke.scale_amount_curve = swell
	smoke.color_ramp = fade
	add_child(smoke)
