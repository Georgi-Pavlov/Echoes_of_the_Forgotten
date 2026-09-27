class_name IceShardProjectile
extends Node2D

## Purely cosmetic: the flying half of Nhal's normal attack (see
## IceShardFX). Leaves `from` at the hanging shard's own angle, swings
## its tip round toward the target as it goes, flies there along a
## slight arc trailing frost, and bursts into ice chips and a puff of
## frost on impact - then `on_hit` fires and it's gone.

var _from: Vector2
var _to: Vector2
var _start_angle := 0.0
var _length := 16.0
var _on_hit: Callable
var _flight := 0.3
var _age := 0.0
var _arc := 0.0
var _trail: Array[Vector2] = []
var _glow: Node2D
var _body: Node2D
var _frost: CPUParticles2D


static func launch(host: Node, from: Vector2, start_angle: float, to: Vector2, length: float, on_hit: Callable) -> void:
	var fx := IceShardProjectile.new()
	fx._from = from
	fx._to = to
	fx._start_angle = start_angle
	fx._length = length
	fx._on_hit = on_hit
	var dist := from.distance_to(to)
	fx._flight = clampf(dist / IceShardFX.SPEED, IceShardFX.FLIGHT_TIME.x, IceShardFX.FLIGHT_TIME.y)
	fx._arc = clampf(dist * 0.08, 6.0, 40.0)
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	_body = Node2D.new()
	_body.draw.connect(_draw_body)
	add_child(_body)
	_frost = _particles(30, 0.45)
	_frost.spread = 180.0
	_frost.initial_velocity_min = 5.0
	_frost.initial_velocity_max = 25.0
	_frost.gravity = Vector2(0.0, 40.0)
	_frost.position = _from
	get_parent().add_child.call_deferred(_frost)


func _pos(t: float) -> Vector2:
	return _from.lerp(_to, t) + Vector2(0.0, -_arc * 4.0 * t * (1.0 - t))


func _process(delta: float) -> void:
	_age += delta
	var t := clampf(_age / _flight, 0.0, 1.0)
	var p := _pos(t)
	_trail.push_front(p)
	if _trail.size() > 7:
		_trail.pop_back()
	if is_instance_valid(_frost):
		_frost.position = p
		_frost.emitting = true
	if t >= 1.0:
		_impact()
		return
	_glow.queue_redraw()
	_body.queue_redraw()


## Heading: from its hanging angle, swung round to point its tip along
## the flight within the first part of it.
func _angle() -> float:
	var t := clampf(_age / _flight, 0.0, 1.0)
	var d := _pos(minf(t + 0.05, 1.0)) - _pos(maxf(t - 0.05, 0.0))
	var heading := d.angle() - PI * 0.5
	var turn := smoothstep(0.0, 0.3, t)
	return lerp_angle(_start_angle, heading, turn)


func _draw_body() -> void:
	var t := clampf(_age / _flight, 0.0, 1.0)
	IceShardFX.draw_crystal(_body, _pos(t), _angle(), _length, 1.0)


func _draw_glow() -> void:
	# A cold streak behind it.
	for i in _trail.size() - 1:
		var k := 1.0 - float(i) / _trail.size()
		_glow.draw_line(_trail[i], _trail[i + 1], Color(IceShardFX.GLOW, 0.35 * k), _length * 0.35 * k, true)
	var t := clampf(_age / _flight, 0.0, 1.0)
	_glow.draw_circle(_pos(t), _length * 0.6, Color(IceShardFX.GLOW, 0.18))


func _impact() -> void:
	if is_instance_valid(_frost):
		_frost.emitting = false
		get_tree().create_timer(_frost.lifetime + 0.1).timeout.connect(_frost.queue_free)
	# Ice chips flying off, a puff of frost, a quick flash.
	var chips := CPUParticles2D.new()
	chips.position = _to
	chips.amount = 14
	chips.lifetime = 0.45
	chips.one_shot = true
	chips.explosiveness = 0.95
	chips.spread = 180.0
	chips.gravity = Vector2(0.0, 380.0)
	chips.initial_velocity_min = 90.0
	chips.initial_velocity_max = 200.0
	chips.angle_min = 0.0
	chips.angle_max = 360.0
	chips.angular_velocity_min = -540.0
	chips.angular_velocity_max = 540.0
	chips.scale_amount_min = 1.5
	chips.scale_amount_max = 3.5
	chips.color = IceShardFX.LIGHT
	get_parent().add_child(chips)
	chips.emitting = true
	var puff := _particles(16, 0.5)
	puff.position = _to
	puff.one_shot = true
	puff.explosiveness = 0.9
	puff.spread = 180.0
	puff.initial_velocity_min = 30.0
	puff.initial_velocity_max = 80.0
	puff.damping_min = 60.0
	puff.damping_max = 120.0
	puff.scale_amount_min = 0.6
	puff.scale_amount_max = 1.3
	get_parent().add_child(puff)
	puff.emitting = true
	var flash := Node2D.new()
	flash.material = VoidReachFX._additive()
	flash.position = _to
	var r := _length
	flash.draw.connect(func() -> void: flash.draw_circle(Vector2.ZERO, r, Color(IceShardFX.RIM, 0.55)))
	get_parent().add_child(flash)
	var fade := flash.create_tween()
	fade.tween_property(flash, "scale", Vector2.ONE * 1.8, 0.18)
	fade.parallel().tween_property(flash, "modulate:a", 0.0, 0.18)
	fade.tween_callback(flash.queue_free)
	for node in [chips, puff]:
		get_tree().create_timer(0.8).timeout.connect(node.queue_free)
	if _on_hit.is_valid():
		_on_hit.call()
	queue_free()


func _particles(amount: int, lifetime: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.lifetime = lifetime
	p.texture = VoidReachFX._dot()
	p.scale_amount_min = 0.35
	p.scale_amount_max = 0.75
	p.gravity = Vector2.ZERO
	p.material = VoidReachFX._additive()
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.15, 1.0])
	ramp.colors = PackedColorArray([Color(IceShardFX.FROST, 0.0), IceShardFX.FROST, Color(IceShardFX.GLOW, 0.0)])
	p.color_ramp = ramp
	return p
