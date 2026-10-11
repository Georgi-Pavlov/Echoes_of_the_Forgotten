class_name FlamethrowerFX
extends Node2D

## Purely cosmetic: Cinder's normal attack ("attack_effect": "flamethrower").
## A gout of fire roars out of the flamethrower's nozzle: a white-hot jet
## right at the muzzle, billowing into rolling yellow-orange flame that
## widens and reddens as it travels and breaks into dark smoke and
## embers at its tip. It reaches the target, engulfs it in a burst of
## flame (`on_hit` fires), keeps pouring for a moment, then sputters out.

const REACH_TIME := 0.22       # s for the flame front to reach the target
const POUR_TIME := 0.35        # s it keeps pouring once it has
const FADE_TIME := 0.3

const CORE := Color(1.0, 0.95, 0.75)
const FLAME := Color(1.0, 0.55, 0.12)
const DEEP := Color(0.85, 0.2, 0.05)

var _from: Vector2
var _to: Vector2
var _on_hit: Callable
var _age := 0.0
var _hit := false
var _flames: CPUParticles2D
var _smoke: CPUParticles2D
var _glow: Node2D


static func play(host: Node, from: Vector2, to: Vector2, on_hit: Callable = Callable()) -> void:
	var fx := FlamethrowerFX.new()
	AudioManager.play_event_for("fire_attack", REACH_TIME + POUR_TIME)
	fx._from = from
	fx._to = to
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	var dir := _to - _from
	var dist := maxf(dir.length(), 40.0)
	var heading := dir.normalized() if dir.length() > 1.0 else Vector2.RIGHT

	# The billowing flame: fast particles from the nozzle, slowing and
	# growing as they go, so they just reach the target before burning out.
	_flames = CPUParticles2D.new()
	_flames.position = _from
	_flames.amount = 170
	_flames.lifetime = 0.42
	_flames.texture = VoidReachFX._dot()
	_flames.direction = heading
	_flames.spread = 13.0
	_flames.gravity = Vector2(0.0, -60.0)
	_flames.initial_velocity_min = dist / 0.42 * 1.25
	_flames.initial_velocity_max = dist / 0.42 * 1.55
	_flames.damping_min = dist * 2.2
	_flames.damping_max = dist * 3.0
	_flames.scale_amount_min = 2.0
	_flames.scale_amount_max = 3.4
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.35))
	grow.add_point(Vector2(0.6, 2.2))
	grow.add_point(Vector2(1.0, 3.2))
	_flames.scale_amount_curve = grow
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.15, 0.45, 0.8, 1.0])
	ramp.colors = PackedColorArray([Color(CORE, 0.95), Color(1.0, 0.82, 0.35, 0.95), Color(FLAME, 0.85), Color(DEEP, 0.55), Color(0.25, 0.08, 0.04, 0.0)])
	_flames.color_ramp = ramp
	_flames.material = VoidReachFX._additive()
	add_child(_flames)
	_flames.emitting = true

	# Dark smoke curling off the flame's far end.
	_smoke = CPUParticles2D.new()
	_smoke.position = _from + heading * dist * 0.7
	_smoke.amount = 24
	_smoke.lifetime = 0.9
	_smoke.texture = VoidReachFX._dot()
	_smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_smoke.emission_sphere_radius = 12.0
	_smoke.direction = Vector2(0.0, -1.0)
	_smoke.spread = 40.0
	_smoke.gravity = Vector2(0.0, -40.0)
	_smoke.initial_velocity_min = 10.0
	_smoke.initial_velocity_max = 30.0
	_smoke.scale_amount_min = 2.0
	_smoke.scale_amount_max = 3.5
	var smoke_ramp := Gradient.new()
	smoke_ramp.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	smoke_ramp.colors = PackedColorArray([Color(0.2, 0.15, 0.12, 0.0), Color(0.18, 0.14, 0.12, 0.4), Color(0.1, 0.1, 0.1, 0.0)])
	_smoke.color_ramp = smoke_ramp
	add_child(_smoke)
	_smoke.emitting = false

	# Heat glow along the stream and a hot muzzle flash.
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)


func _process(delta: float) -> void:
	_age += delta
	if not _hit and _age >= REACH_TIME:
		_hit = true
		_smoke.emitting = true
		_engulf()
		if _on_hit.is_valid():
			_on_hit.call()
	if _age >= REACH_TIME + POUR_TIME:
		_flames.emitting = false
		_smoke.emitting = false
	if _age >= REACH_TIME + POUR_TIME + _smoke.lifetime + 0.1:
		queue_free()
		return
	_glow.queue_redraw()


## The burst of flame and embers wrapping the target as the fire lands.
func _engulf() -> void:
	var burst := CPUParticles2D.new()
	burst.position = _to
	burst.amount = 30
	burst.lifetime = 0.55
	burst.one_shot = true
	burst.explosiveness = 0.85
	burst.texture = VoidReachFX._dot()
	burst.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	burst.emission_sphere_radius = 14.0
	burst.spread = 180.0
	burst.gravity = Vector2(0.0, -120.0)
	burst.initial_velocity_min = 40.0
	burst.initial_velocity_max = 120.0
	burst.damping_min = 60.0
	burst.damping_max = 120.0
	burst.scale_amount_min = 1.0
	burst.scale_amount_max = 2.4
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(1.0, 0.85, 0.4, 0.95), Color(FLAME, 0.8), Color(DEEP, 0.0)])
	burst.color_ramp = ramp
	burst.material = VoidReachFX._additive()
	get_parent().add_child(burst)
	burst.emitting = true
	get_tree().create_timer(0.8).timeout.connect(burst.queue_free)


func _draw_glow() -> void:
	var on := clampf(_age / 0.06, 0.0, 1.0) * (1.0 - clampf((_age - REACH_TIME - POUR_TIME) / FADE_TIME, 0.0, 1.0))
	if on <= 0.0:
		return
	var flicker := 0.85 + 0.15 * sin(_age * 60.0)
	var reach := clampf(_age / REACH_TIME, 0.0, 1.0)
	var tip := _from.lerp(_to, reach)
	_glow.draw_line(_from, tip, Color(FLAME, 0.18 * on * flicker), 26.0, true)
	_glow.draw_line(_from, _from.lerp(tip, 0.35), Color(CORE, 0.35 * on * flicker), 7.0, true)
	_glow.draw_circle(_from, 11.0 * flicker, Color(CORE, 0.55 * on))
	if _hit:
		_glow.draw_circle(_to, 30.0 * flicker, Color(FLAME, 0.25 * on))
