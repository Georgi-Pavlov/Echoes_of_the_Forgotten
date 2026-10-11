class_name ThreeCheersFX
extends Node2D

## Purely cosmetic: ONE shot of Raze's Three Cheers (the skill fires three,
## each its own instance - see battle.gd's _play_three_cheers_shot_effect()).
## A sharp muzzle flash, then a single fat, white-hot slug that rips to the
## target in a blink, trailing a long streak, and slams into it in a flash
## and ring of sparks (`on_hit` fires then).

const FLIGHT_TIME := 0.1
const LINGER := 0.4

const CORE := Color(1.0, 0.97, 0.85)
const FLAME := Color(1.0, 0.6, 0.15)
const DEEP := Color(0.9, 0.25, 0.06)

var _from: Vector2
var _to: Vector2
var _on_hit: Callable
var _age := 0.0
var _hit := false


static func play(host: Node, from: Vector2, to: Vector2, on_hit: Callable = Callable()) -> void:
	var fx := ThreeCheersFX.new()
	fx._from = from
	fx._to = to
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()
	AudioManager.play_event("raze_shoot")
	var dir := _to - _from
	var heading := dir.normalized() if dir.length() > 1.0 else Vector2.RIGHT

	var puff := CPUParticles2D.new()
	puff.position = _from
	puff.one_shot = true
	puff.amount = 18
	puff.lifetime = 0.22
	puff.explosiveness = 0.95
	puff.texture = VoidReachFX._dot()
	puff.direction = heading
	puff.spread = 22.0
	puff.initial_velocity_min = 120.0
	puff.initial_velocity_max = 260.0
	puff.damping_min = 380.0
	puff.damping_max = 520.0
	puff.scale_amount_min = 1.4
	puff.scale_amount_max = 2.8
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	ramp.colors = PackedColorArray([Color(CORE, 0.95), Color(FLAME, 0.7), Color(DEEP, 0.0)])
	puff.color_ramp = ramp
	puff.material = VoidReachFX._additive()
	add_child(puff)
	puff.emitting = true


func _process(delta: float) -> void:
	_age += delta
	if not _hit and _age >= FLIGHT_TIME:
		_hit = true
		_impact()
		if _on_hit.is_valid():
			_on_hit.call()
	if _age >= FLIGHT_TIME + LINGER:
		queue_free()
		return
	queue_redraw()


func _impact() -> void:
	AudioManager.play_event("bullet_impact")
	var burst := CPUParticles2D.new()
	burst.position = _to
	burst.one_shot = true
	burst.amount = 30
	burst.lifetime = 0.4
	burst.explosiveness = 0.95
	burst.texture = VoidReachFX._dot()
	burst.spread = 180.0
	burst.gravity = Vector2(0.0, 220.0)
	burst.initial_velocity_min = 90.0
	burst.initial_velocity_max = 260.0
	burst.damping_min = 100.0
	burst.damping_max = 200.0
	burst.scale_amount_min = 1.0
	burst.scale_amount_max = 2.4
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(1.0, 0.92, 0.55, 1.0), Color(FLAME, 0.85), Color(DEEP, 0.0)])
	burst.color_ramp = ramp
	burst.material = VoidReachFX._additive()
	add_child(burst)
	burst.emitting = true


func _draw() -> void:
	var dir := (_to - _from).normalized()
	var side := dir.orthogonal()
	# Muzzle flash: short and hard.
	if _age < 0.09:
		var k := 1.0 - _age / 0.09
		var len := 64.0 * (0.6 + 0.4 * k)
		var half := 14.0 * k
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.5 + side * half, _from + dir * len, _from + dir * len * 0.5 - side * half]), Color(FLAME, 0.75 * k))
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.4 + side * half * 0.4, _from + dir * len * 0.62, _from + dir * len * 0.4 - side * half * 0.4]), Color(CORE, 0.95 * k))
		draw_circle(_from, 20.0 * k, Color(1.0, 0.85, 0.5, 0.55 * k))

	# The slug: a fat glowing head dragging a long, tapering streak.
	var t := clampf(_age / FLIGHT_TIME, 0.0, 1.0)
	if t < 1.0:
		var reach := (_to - _from).length()
		var head := _from + dir * reach * t
		var tail := _from + dir * maxf(reach * t - 150.0, 0.0)
		for i in 5:
			var f := float(i) / 5.0
			var a := tail.lerp(head, f)
			var b := tail.lerp(head, f + 0.2)
			draw_line(a, b, Color(FLAME, 0.2 + 0.5 * f), 3.0 + 9.0 * f, true)
		draw_line(tail.lerp(head, 0.5), head, Color(CORE, 0.9), 4.0, true)
		draw_circle(head, 15.0, Color(1.0, 0.6, 0.2, 0.35))
		draw_circle(head, 10.0, Color(1.0, 0.8, 0.4, 0.6))
		draw_circle(head, 6.0, Color(CORE, 1.0))

	# Impact: a flash and an expanding ring.
	if _hit:
		var ik := clampf((_age - FLIGHT_TIME) / 0.22, 0.0, 1.0)
		draw_circle(_to, lerpf(30.0, 14.0, ik), Color(1.0, 0.85, 0.5, 0.65 * (1.0 - ik)))
		draw_arc(_to, lerpf(10.0, 62.0, 1.0 - pow(1.0 - ik, 2.0)), 0.0, TAU, 32, Color(CORE, 0.8 * (1.0 - ik)), 4.0 * (1.0 - ik) + 1.0, true)
