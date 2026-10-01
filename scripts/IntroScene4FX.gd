extends IntroSceneFX

## Effects over the intro's fourth scene (the door opened - the rift torn
## in the sky above the ritual): the void inside the rift churning and its
## burning rim crackling, the two eyes in it glowing and blinking, two
## tentacles writhing out of the dark, the floating rocks and spires
## drifting and tumbling, the beam of light pulsing down onto the altar,
## the braziers burning, the ritual circle pulsing, and the rift's light
## flickering over the whole scene. See IntroSceneFX.gd for how positions
## and areas are given.

const RIFT_SHADER := preload("res://shaders/intro_rift.gdshader")
const FLOAT_SHADER := preload("res://shaders/intro_float.gdshader")
const ROCK_SHADER := preload("res://shaders/intro_rock.gdshader")
const FLAME_SHADER := preload("res://shaders/intro_flame.gdshader")
const RITUAL_SHADER := preload("res://shaders/intro_ritual.gdshader")

const RIFT_AREA := Rect2(0.47, 0.0, 0.27, 0.7)

const EYE_POSITIONS: Array[Vector2] = [
	Vector2(0.6166, 0.067),
	Vector2(0.6687, 0.4708),
]
const EYE_COLOR := Color(0.85, 0.7, 1.0)
const EYE_LID_COLOR := Color(0.07, 0.05, 0.1)
const BLINK_TIME := 0.4
const BLINK_GAP_MIN := 3.0
const BLINK_GAP_MAX := 7.0

## The two added tentacles, rising out of the void like the painted ones:
## where each one's root sits in the dark, the way it starts out (degrees,
## 0 = right, -90 = up), its length and thickness at the root in screen
## pixels, and how hard (and which way) its tip curls over.
const TENTACLES: Array[Dictionary] = [
	{"root": Vector2(0.62, 0.37), "angle": -112.0, "length": 120.0, "width": 20.0, "curl": -2.4},
	{"root": Vector2(0.626, 0.215), "angle": -135.0, "length": 100.0, "width": 17.0, "curl": 2.4},
]
## Root (lost in the dark of the void) to body colour, and the light from
## the burning rim catching one edge.
const TENTACLE_ROOT_COLOR := Color(0.05, 0.035, 0.07, 0.0)
const TENTACLE_COLOR := Color(0.13, 0.09, 0.15)
const TENTACLE_RIM_COLOR := Color(0.62, 0.45, 0.6, 0.4)
const TENTACLE_SEGMENTS := 24

## Floating rocks and spires that drift up and down.
const DRIFTING: Array[Dictionary] = [
	{"area": Rect2(0.338, 0.0, 0.057, 0.175), "edge_fade": Vector4(0.12, 0.001, 0.12, 0.12)},
	{"area": Rect2(0.405, 0.0, 0.07, 0.33), "edge_fade": Vector4(0.1, 0.001, 0.1, 0.08)},
	{"area": Rect2(0.48, 0.16, 0.045, 0.22)},
	{"area": Rect2(0.528, 0.37, 0.03, 0.19)},
	{"area": Rect2(0.722, 0.0, 0.038, 0.13), "edge_fade": Vector4(0.15, 0.001, 0.15, 0.12)},
	{"area": Rect2(0.757, 0.14, 0.037, 0.19)},
	{"area": Rect2(0.828, 0.05, 0.045, 0.11)},
	{"area": Rect2(0.798, 0.28, 0.045, 0.13)},
	{"area": Rect2(0.768, 0.4, 0.045, 0.16)},
]
const DRIFT_PX := 4.0
## Loose rocks that tumble slowly as they drift: area and the rock's
## centre to turn about.
const TUMBLING: Array[Dictionary] = [
	{"area": Rect2(0.736, 0.352, 0.034, 0.086), "pivot": Vector2(0.753, 0.395)},
	{"area": Rect2(0.753, 0.432, 0.025, 0.065), "pivot": Vector2(0.766, 0.465)},
	{"area": Rect2(0.518, 0.325, 0.03, 0.06), "pivot": Vector2(0.533, 0.355)},
]

## Each fire: the flames' area.
const FIRES: Array[Rect2] = [
	Rect2(0.0, 0.46, 0.1, 0.075),
	Rect2(0.428, 0.615, 0.045, 0.06),
	Rect2(0.82, 0.615, 0.045, 0.06),
	Rect2(0.86, 0.63, 0.05, 0.08),
	Rect2(0.925, 0.49, 0.075, 0.1),
	Rect2(0.895, 0.775, 0.06, 0.06),
]

const RITUAL_AREA := Rect2(0.55, 0.78, 0.37, 0.17)
const RITUAL_CENTER := Vector2(0.72, 0.87)

## The beam of light pouring from the rift onto the altar.
const BEAM_CENTER := Vector2(0.641, 0.6)
const BEAM_SIZE := Vector2(70.0, 260.0)
const BEAM_COLOR := Color(1.0, 0.9, 0.75)

const RIFT_LIGHT_GOLD := Color(1.0, 0.75, 0.4)
const RIFT_LIGHT_VIOLET := Color(0.6, 0.4, 0.9)

## Per eye: {glow, core, lid, next_blink, blink_t (-1 = not blinking)}.
var _eyes: Array[Dictionary] = []
var _tentacle_layer: Control
var _beam: TextureRect
var _beam_core: TextureRect
var _light_add: ColorRect
var _light_dim: ColorRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	# The rift first, on the plain painting; then everything that moves
	# over or around it works on the picture with the rift already alive.
	_add_shader_rect(RIFT_AREA, RIFT_SHADER)
	_recapture()
	for item in DRIFTING:
		var mat: ShaderMaterial = _add_shader_rect(item["area"], FLOAT_SHADER).material
		mat.set_shader_parameter("amplitude", DRIFT_PX)
		mat.set_shader_parameter("period", _rng.randf_range(4.5, 7.5))
		mat.set_shader_parameter("phase", _rng.randf() * TAU)
		if item.has("edge_fade"):
			mat.set_shader_parameter("edge_fade", item["edge_fade"])
	for rock in TUMBLING:
		var mat: ShaderMaterial = _add_shader_rect(rock["area"], ROCK_SHADER).material
		mat.set_shader_parameter("pivot", rock["pivot"] * SIZE)
		mat.set_shader_parameter("rock_degrees", _rng.randf_range(6.0, 10.0))
		mat.set_shader_parameter("rock_period", _rng.randf_range(6.0, 9.0))
		mat.set_shader_parameter("bob_px", 3.0)
		mat.set_shader_parameter("sway_px", 1.5)
		mat.set_shader_parameter("phase", _rng.randf() * TAU)
		mat.set_shader_parameter("edge_fade", Vector4(0.2, 0.2, 0.2, 0.2))
	for fire in FIRES:
		var mat: ShaderMaterial = _add_shader_rect(fire, FLAME_SHADER).material
		mat.set_shader_parameter("seed", _rng.randf() * 50.0)
	var ritual: ShaderMaterial = _add_shader_rect(RITUAL_AREA, RITUAL_SHADER).material
	ritual.set_shader_parameter("center_px", RITUAL_CENTER * SIZE)

	_tentacle_layer = _add_draw_layer(_draw_tentacles)

	for pos in EYE_POSITIONS:
		_eyes.append({
			"glow": _add_glow(pos, 56.0, 0.55, EYE_COLOR),
			"core": _add_glow(pos, 14.0, 0.9, Color(1.0, 0.95, 1.0)),
			"lid": _add_glow(pos, 30.0, 1.0, EYE_LID_COLOR, false),
			"next_blink": _rng.randf_range(1.5, BLINK_GAP_MAX),
			"blink_t": -1.0,
		})

	_beam = _add_beam(BEAM_SIZE, 0.35)
	_beam_core = _add_beam(BEAM_SIZE * Vector2(0.3, 0.95), 0.5)
	_add_beam_sparks()
	for fire in FIRES:
		_add_embers(fire)

	_light_dim = _add_full_rect(Color(1, 1, 1), CanvasItemMaterial.BLEND_MODE_MUL)
	_light_add = _add_full_rect(Color(RIFT_LIGHT_GOLD, 0.0), CanvasItemMaterial.BLEND_MODE_ADD)


func _process(delta: float) -> void:
	_time += delta

	for eye in _eyes:
		_update_eye(eye, delta)

	# The beam surges: a slow swell with quick shivers on top.
	var surge := 0.7 + 0.2 * sin(_time * 1.3) + 0.1 * sin(_time * 7.1)
	_beam.modulate.a = surge
	_beam_core.modulate.a = surge
	_beam.scale.x = 0.9 + 0.15 * sin(_time * 1.3)

	# The rift's light washes over the scene: brightening gold on a surge,
	# sinking a little and turning violet between them.
	var pulse := sin(_time * 0.9) * 0.6 + sin(_time * 2.3 + 1.0) * 0.3 + sin(_time * 5.7) * 0.1
	var bright := maxf(pulse, 0.0)
	var dark := maxf(-pulse, 0.0)
	_light_add.color = Color(RIFT_LIGHT_GOLD.lerp(RIFT_LIGHT_VIOLET, dark), 0.07 * bright + 0.04 * dark)
	var dim := 1.0 - 0.08 * dark
	_light_dim.color = Color(dim, dim, dim)

	_tentacle_layer.queue_redraw()


## An eye in the void: a steady violet glow, and every few seconds a slow
## blink as the dark closes over it.
func _update_eye(eye: Dictionary, delta: float) -> void:
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

	var glow := 0.75 + 0.25 * sin(_time * 1.1 + eye["next_blink"])
	(eye["glow"] as TextureRect).modulate.a = glow * (1.0 - closed)
	(eye["core"] as TextureRect).modulate.a = glow * (1.0 - closed)
	var lid: TextureRect = eye["lid"]
	lid.modulate.a = closed
	lid.scale = Vector2(1.0, 0.4 + 0.6 * closed)


## Each tentacle: a tapering body bending along its length in waves that
## travel from root to tip, so it coils and uncoils - dark, with a faint
## violet sheen along one edge.
func _draw_tentacles(layer: Control) -> void:
	for i in TENTACLES.size():
		var tentacle: Dictionary = TENTACLES[i]
		var spine := _tentacle_spine(tentacle, i * 2.7)
		var width: float = tentacle["width"]

		var left := PackedVector2Array()
		var right := PackedVector2Array()
		var left_colors := PackedColorArray()
		var right_colors := PackedColorArray()
		for s in spine.size():
			var k := float(s) / (spine.size() - 1)
			var dir := (spine[mini(s + 1, spine.size() - 1)] - spine[maxi(s - 1, 0)]).normalized()
			var normal := Vector2(-dir.y, dir.x)
			var half := _tentacle_half_width(width, k)
			left.append(spine[s] + normal * half)
			right.append(spine[s] - normal * half)
			# It emerges out of the dark: fully see-through at the root.
			var color := TENTACLE_ROOT_COLOR.lerp(TENTACLE_COLOR, smoothstep(0.0, 0.3, k))
			left_colors.append(color)
			right_colors.append(color)
		right.reverse()
		right_colors.reverse()
		var outline := left.duplicate()
		outline.append_array(right)
		var colors := left_colors.duplicate()
		colors.append_array(right_colors)
		layer.draw_polygon(outline, colors)

		var sheen := left.slice(int(spine.size() * 0.25))
		layer.draw_polyline(sheen, TENTACLE_RIM_COLOR, 1.0, true)
		# Suckers along the underside: faint pale dots shrinking to the tip.
		for s in range(int(spine.size() * 0.3), spine.size() - 3, 2):
			var k := float(s) / (spine.size() - 1)
			var dir := (spine[s + 1] - spine[s - 1]).normalized()
			var normal := Vector2(-dir.y, dir.x)
			var half := _tentacle_half_width(width, k)
			layer.draw_circle(spine[s] - normal * half * 0.45, maxf(half * 0.2, 0.6), Color(0.4, 0.3, 0.42, 0.45))


## A tentacle's centre line, root to tip: it rises along its heading,
## swaying in slow waves that run out along it, and its tip curls over -
## curling and uncurling as it sways.
func _tentacle_spine(tentacle: Dictionary, phase: float) -> PackedVector2Array:
	var pos: Vector2 = tentacle["root"] * SIZE
	var heading := deg_to_rad(tentacle["angle"])
	var step: float = tentacle["length"] / TENTACLE_SEGMENTS
	var curl: float = tentacle["curl"] * (0.75 + 0.25 * sin(_time * 0.8 + phase))
	var spine := PackedVector2Array([pos])
	for s in TENTACLE_SEGMENTS:
		var k := float(s) / TENTACLE_SEGMENTS
		heading += sin(_time * 1.1 - k * 3.5 + phase) * 0.045 * (0.5 + k)
		heading += curl * pow(k, 3.0) / TENTACLE_SEGMENTS * 3.0
		pos += Vector2.from_angle(heading) * step
		spine.append(pos)
	return spine


## Thick at the root, tapering to a fine tip.
func _tentacle_half_width(width: float, k: float) -> float:
	return width * 0.5 * pow(1.0 - k * 0.94, 1.2)


## A soft vertical shaft of light, centred on the beam.
func _add_beam(size: Vector2, strength: float) -> TextureRect:
	var beam := _add_glow(BEAM_CENTER, 1.0, strength, BEAM_COLOR)
	beam.size = size
	beam.position = BEAM_CENTER * SIZE - size / 2.0
	beam.pivot_offset = size / 2.0
	return beam


func _add_beam_sparks() -> void:
	var sparks := _make_particles(Color(1.0, 0.95, 0.8))
	sparks.position = BEAM_CENTER * SIZE + Vector2(0, BEAM_SIZE.y * 0.3)
	sparks.emission_rect_extents = Vector2(8.0, BEAM_SIZE.y * 0.2)
	sparks.amount = 24
	sparks.lifetime = 2.2
	sparks.initial_velocity_min = 30.0
	sparks.initial_velocity_max = 70.0
	sparks.spread = 12.0


func _add_embers(fire: Rect2) -> void:
	var embers := _make_particles(Color(1.0, 0.6, 0.2))
	embers.position = (fire.position + Vector2(fire.size.x * 0.5, fire.size.y * 0.3)) * SIZE
	embers.emission_rect_extents = Vector2(fire.size.x * SIZE.x * 0.35, 3.0)
	embers.amount = 8
	embers.lifetime = 1.8
	embers.initial_velocity_min = 20.0
	embers.initial_velocity_max = 45.0
	embers.spread = 25.0


## Small glowing specks rising and fading.
func _make_particles(color: Color) -> CPUParticles2D:
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color, 0.0))
	ramp.add_point(0.15, Color(color, 1.0))
	ramp.set_color(ramp.get_point_count() - 1, Color(color, 0.0))
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	var p := CPUParticles2D.new()
	p.material = add
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.direction = Vector2.UP
	p.gravity = Vector2(0, -10)
	p.tangential_accel_min = -10.0
	p.tangential_accel_max = 10.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.0
	p.color_ramp = ramp
	p.preprocess = 2.0
	add_child(p)
	return p


func _add_full_rect(color: Color, blend: CanvasItemMaterial.BlendMode) -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(PRESET_FULL_RECT)
	rect.color = color
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = blend
	rect.material = mat
	add_child(rect)
	return rect
