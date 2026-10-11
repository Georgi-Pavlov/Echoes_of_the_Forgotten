class_name SweepFlamesFX
extends Node2D

## Purely cosmetic: Cinder's Sweep. As he swings the flamethrower round,
## a wall of tall flames erupts out of the ground around him - from his
## feet outward to both sides, out to the skill's reach - roars for a
## moment, then dies down into smoke and drifting embers. A band of
## fire glows along the ground beneath it.

const WALL_SHADER := preload("res://shaders/flame_wall.gdshader")
const SWEEP_SPEED := 1400.0    # px/s the eruption spreads outward
const ROAR_TIME := 0.75        # s the wall roars at full height
const HEIGHT := 1.7            # of a creature's height

const HOT := Color(1.0, 0.88, 0.5)
const FIRE := Color(1.0, 0.5, 0.12)
const DEEP := Color(0.8, 0.18, 0.04)

var _center: Vector2           # on the ground, under the caster
var _half_width := 100.0
var _unit_height := 180.0
var _age := 0.0
var _wall_mat: ShaderMaterial
var _glow: Node2D
var _life := 2.0


## Erupts the flames around ground point `center` (global), `half_width`
## px to either side, for creatures `unit_height` px tall.
static func play(host: Node, center: Vector2, half_width: float, unit_height: float) -> void:
	var fx := SweepFlamesFX.new()
	fx._center = center
	fx._half_width = half_width
	fx._unit_height = unit_height
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	var height := _unit_height * HEIGHT
	# The wall of flame itself (flame_wall.gdshader), standing on the ground.
	_wall_mat = ShaderMaterial.new()
	_wall_mat.shader = WALL_SHADER
	_wall_mat.set_shader_parameter("aspect", _half_width * 2.0 / height)
	_wall_mat.set_shader_parameter("seed", randf() * 50.0)
	_wall_mat.set_shader_parameter("reveal", 0.0)
	_wall_mat.set_shader_parameter("strength", 0.0)
	var wall := ColorRect.new()
	wall.material = _wall_mat
	wall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wall.position = _center + Vector2(-_half_width, -height)
	wall.size = Vector2(_half_width * 2.0, height)
	add_child(wall)
	_life = _half_width / SWEEP_SPEED + ROAR_TIME + 1.6
	# The roar lasts as long as the wall stands at full height - it is cut
	# off as the flames begin to die down.
	AudioManager.play_event_for("fire_attack", _half_width / SWEEP_SPEED + ROAR_TIME)

	# Smoke rolling up once the flames die down, and embers.
	var smoke := CPUParticles2D.new()
	smoke.position = _center + Vector2(0.0, -height * 0.5)
	smoke.amount = 30
	smoke.lifetime = 1.6
	smoke.one_shot = true
	smoke.explosiveness = 0.6
	smoke.texture = VoidReachFX._dot()
	smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	smoke.emission_rect_extents = Vector2(_half_width, height * 0.4)
	smoke.direction = Vector2(0.0, -1.0)
	smoke.spread = 20.0
	smoke.gravity = Vector2(0.0, -20.0)
	smoke.initial_velocity_min = 15.0
	smoke.initial_velocity_max = 40.0
	smoke.scale_amount_min = 6.0
	smoke.scale_amount_max = 10.0
	var smoke_ramp := Gradient.new()
	smoke_ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	smoke_ramp.colors = PackedColorArray([Color(0.15, 0.1, 0.08, 0.0), Color(0.14, 0.1, 0.08, 0.45), Color(0.1, 0.08, 0.08, 0.0)])
	smoke.color_ramp = smoke_ramp
	smoke.emitting = false
	add_child(smoke)
	get_tree().create_timer(_half_width / SWEEP_SPEED + ROAR_TIME * 0.7, false).timeout.connect(func() -> void:
		if is_instance_valid(smoke):
			smoke.emitting = true)

	var embers := CPUParticles2D.new()
	embers.position = _center
	embers.amount = 40
	embers.lifetime = 1.6
	embers.one_shot = true
	embers.explosiveness = 0.5
	embers.texture = VoidReachFX._dot()
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(_half_width, 8.0)
	embers.direction = Vector2(0.0, -1.0)
	embers.spread = 30.0
	embers.gravity = Vector2(0.0, -30.0)
	embers.initial_velocity_min = 80.0
	embers.initial_velocity_max = 220.0
	embers.tangential_accel_min = -30.0
	embers.tangential_accel_max = 30.0
	embers.scale_amount_min = 0.4
	embers.scale_amount_max = 0.9
	var ember_ramp := Gradient.new()
	ember_ramp.offsets = PackedFloat32Array([0.0, 0.1, 0.7, 1.0])
	ember_ramp.colors = PackedColorArray([Color(HOT, 0.0), Color(1.0, 0.8, 0.35, 1.0), Color(FIRE, 0.8), Color(DEEP, 0.0)])
	embers.color_ramp = ember_ramp
	embers.material = VoidReachFX._additive()
	add_child(embers)
	embers.emitting = true

	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)


func _process(delta: float) -> void:
	_age += delta
	# Spreads out from him as fast as the swing, roars up, then dies down.
	var out_time := _half_width / SWEEP_SPEED
	_wall_mat.set_shader_parameter("reveal", clampf(_age / maxf(out_time, 0.01), 0.0, 1.0) * 1.12)
	var rise := clampf(_age / 0.18, 0.0, 1.0)
	var die := 1.0 - clampf((_age - out_time - ROAR_TIME) / 0.45, 0.0, 1.0)
	_wall_mat.set_shader_parameter("strength", rise * die)
	if _age >= _life:
		queue_free()
		return
	_glow.queue_redraw()


## The fire's glow on the ground and in the air above it: spreading out
## with the eruption, flickering, fading as the flames die.
func _draw_glow() -> void:
	var spread := clampf(_age * SWEEP_SPEED, 0.0, _half_width)
	var fade := 1.0 - clampf((_age - _half_width / SWEEP_SPEED - ROAR_TIME * 0.6) / 0.6, 0.0, 1.0)
	if fade <= 0.0 or spread < 2.0:
		return
	var flicker := 0.85 + 0.15 * sin(_age * 37.0) * sin(_age * 23.0 + 1.0)
	var a := fade * flicker
	var ground := PackedVector2Array()
	for i in 33:
		var t := TAU * i / 32.0
		ground.append(_center + Vector2(cos(t) * (spread + 20.0), sin(t) * 16.0))
	_glow.draw_colored_polygon(ground, Color(FIRE, 0.35 * a))
	var h := _unit_height * HEIGHT
	var rect := Rect2(_center + Vector2(-spread, -h * 0.75), Vector2(spread * 2.0, h * 0.75))
	_glow.draw_rect(rect, Color(DEEP, 0.08 * a))
