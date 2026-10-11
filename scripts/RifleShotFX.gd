class_name RifleShotFX
extends Node2D

## Purely cosmetic: a Scorchlands rifleman's shot ("projectile":
## "rifle_bullet"). A hard muzzle flash and a curl of powder smoke, then a
## single glowing round that streaks to the target in a blink, trailing a
## thin line of heat, and sparks off it (`on_hit` fires then).

const FLIGHT_TIME := 0.12
const LINGER := 0.35

const CORE := Color(1.0, 0.97, 0.85)
const FLAME := Color(1.0, 0.6, 0.15)
const DEEP := Color(0.9, 0.25, 0.06)

## Where the rifle's muzzle sits on a rifleman's art (fraction of the
## node's size) when it faces left - mirror x when it faces right.
const MUZZLE_FACING_LEFT := Vector2(0.015, 0.155)

var _from: Vector2
var _to: Vector2
var _on_hit := Callable()
var _age := 0.0
var _hit := false


static func play(host: Node, from: Vector2, to: Vector2, on_hit: Callable = Callable()) -> void:
	var fx := RifleShotFX.new()
	fx._from = from
	fx._to = to
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()
	AudioManager.play_event("creep_shoot")
	var dir := _to - _from
	var heading := dir.normalized() if dir.length() > 1.0 else Vector2.LEFT

	var puff := CPUParticles2D.new()
	puff.position = _from
	puff.one_shot = true
	puff.amount = 14
	puff.lifetime = 0.35
	puff.explosiveness = 0.95
	puff.texture = VoidReachFX._dot()
	puff.direction = heading
	puff.spread = 18.0
	puff.initial_velocity_min = 60.0
	puff.initial_velocity_max = 170.0
	puff.damping_min = 240.0
	puff.damping_max = 360.0
	puff.scale_amount_min = 1.2
	puff.scale_amount_max = 2.6
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	ramp.colors = PackedColorArray([Color(CORE, 0.9), Color(FLAME, 0.6), Color(0.3, 0.25, 0.22, 0.0)])
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
	var burst := CPUParticles2D.new()
	burst.position = _to
	burst.one_shot = true
	burst.amount = 16
	burst.lifetime = 0.3
	burst.explosiveness = 0.95
	burst.texture = VoidReachFX._dot()
	burst.spread = 180.0
	burst.gravity = Vector2(0.0, 200.0)
	burst.initial_velocity_min = 60.0
	burst.initial_velocity_max = 190.0
	burst.damping_min = 80.0
	burst.damping_max = 160.0
	burst.scale_amount_min = 0.7
	burst.scale_amount_max = 1.6
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
	# Muzzle flash: a short hard star of light.
	if _age < 0.08:
		var k := 1.0 - _age / 0.08
		var len := 52.0 * (0.6 + 0.4 * k)
		var half := 9.0 * k
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.5 + side * half, _from + dir * len, _from + dir * len * 0.5 - side * half]), Color(FLAME, 0.75 * k))
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.4 + side * half * 0.4, _from + dir * len * 0.6, _from + dir * len * 0.4 - side * half * 0.4]), Color(CORE, 0.95 * k))
		draw_circle(_from, 14.0 * k, Color(1.0, 0.85, 0.5, 0.5 * k))

	# The round: a bright head dragging a long, thin streak.
	var t := clampf(_age / FLIGHT_TIME, 0.0, 1.0)
	if t < 1.0:
		var reach := (_to - _from).length()
		var head := _from + dir * reach * t
		var tail := _from + dir * maxf(reach * t - 170.0, 0.0)
		for i in 5:
			var f := float(i) / 5.0
			draw_line(tail.lerp(head, f), tail.lerp(head, f + 0.2), Color(FLAME, 0.15 + 0.5 * f), 1.5 + 3.0 * f, true)
		draw_line(tail.lerp(head, 0.6), head, Color(CORE, 0.9), 2.0, true)
		draw_circle(head, 7.0, Color(1.0, 0.65, 0.25, 0.4))
		draw_circle(head, 3.5, Color(CORE, 1.0))

	# A flash and a small ring where it lands.
	if _hit:
		var ik := clampf((_age - FLIGHT_TIME) / 0.2, 0.0, 1.0)
		draw_circle(_to, lerpf(18.0, 8.0, ik), Color(1.0, 0.85, 0.5, 0.55 * (1.0 - ik)))
		draw_arc(_to, lerpf(6.0, 34.0, 1.0 - pow(1.0 - ik, 2.0)), 0.0, TAU, 24, Color(CORE, 0.7 * (1.0 - ik)), 2.5 * (1.0 - ik) + 0.5, true)
