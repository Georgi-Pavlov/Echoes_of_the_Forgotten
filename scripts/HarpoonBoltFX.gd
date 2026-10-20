class_name HarpoonBoltFX
extends Node2D

## Purely cosmetic: a Drowned Empire harpooner's shot ("projectile":
## "harpoon_bolt"). A burst of brine off the harpoon gun, then a heavy,
## barbed iron bolt that streaks to the target dragging a thin taut line
## behind it, and bites in with a spray of water (`on_hit` fires then).

const FLIGHT_TIME := 0.5
const LINGER := 0.4

const IRON := Color(0.25, 0.22, 0.2)
const IRON_DARK := Color(0.08, 0.07, 0.07)
const IRON_LIGHT := Color(0.42, 0.34, 0.28)
const ROPE := Color(0.26, 0.2, 0.12)
const FOAM := Color(0.72, 0.95, 1.0)
const RUST := Color(0.5, 0.22, 0.08)

## Where the harpoon's head sits on a harpooner's art (fraction of the
## node's size) when it faces left - mirror x when it faces right.
const MUZZLE_FACING_LEFT := Vector2(0.03, 0.2)

const BOLT_LENGTH := 88.0

var _from: Vector2
var _to: Vector2
var _on_hit := Callable()
var _age := 0.0
var _hit := false


static func play(host: Node, from: Vector2, to: Vector2, on_hit: Callable = Callable()) -> void:
	var fx := HarpoonBoltFX.new()
	fx._from = from
	fx._to = to
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	AudioManager.play_event("hand_projectile")
	var dir := _to - _from
	var heading := dir.normalized() if dir.length() > 1.0 else Vector2.LEFT
	_spray(_from, heading, 12, 22.0, 50.0, 150.0, 0.4)


func _spray(at: Vector2, heading: Vector2, amount: int, spread: float, vmin: float, vmax: float, life: float) -> void:
	var p := CPUParticles2D.new()
	p.position = at
	p.one_shot = true
	p.amount = amount
	p.lifetime = life
	p.explosiveness = 0.95
	p.texture = VoidReachFX._dot()
	p.direction = heading
	p.spread = spread
	p.gravity = Vector2(0.0, 260.0)
	p.initial_velocity_min = vmin
	p.initial_velocity_max = vmax
	p.damping_min = 40.0
	p.damping_max = 120.0
	p.scale_amount_min = 0.7
	p.scale_amount_max = 1.8
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 0.9), Color(FOAM, 0.6), Color(FOAM, 0.0)])
	p.color_ramp = ramp
	p.material = VoidReachFX._additive()
	add_child(p)
	p.emitting = true


func _process(delta: float) -> void:
	_age += delta
	if not _hit and _age >= FLIGHT_TIME:
		_hit = true
		var dir := (_to - _from).normalized()
		_spray(_to, -dir, 18, 70.0, 70.0, 210.0, 0.45)
		if _on_hit.is_valid():
			_on_hit.call()
	if _age >= FLIGHT_TIME + LINGER:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var dir := (_to - _from).normalized()
	var side := dir.orthogonal()
	var reach := (_to - _from).length()

	# Muzzle burst of brine.
	if _age < 0.09:
		var k := 1.0 - _age / 0.09
		draw_circle(_from, 16.0 * k, Color(FOAM, 0.4 * k))
		draw_arc(_from, 30.0 * (1.0 - k) + 6.0, 0.0, TAU, 20, Color(FOAM, 0.6 * k), 2.0, true)

	var t := clampf(_age / FLIGHT_TIME, 0.0, 1.0)
	var e := t * t * (3.0 - 2.0 * t) * 0.35 + t * 0.65  # leaves fast, never stalls
	var tip := _from + dir * reach * e
	var tail := tip - dir * BOLT_LENGTH

	# The line paying out behind it: a slight sag that tightens as it flies,
	# then goes slack and sinks once the bolt has bitten.
	var sag := 19.0 * (1.0 - t) if not _hit else 19.0 * clampf((_age - FLIGHT_TIME) / 0.3, 0.0, 1.0)
	var fade := 1.0 if not _hit else 1.0 - clampf((_age - FLIGHT_TIME - 0.1) / 0.3, 0.0, 1.0)
	if fade > 0.0:
		var pts := PackedVector2Array()
		var steps := 14
		for i in steps + 1:
			var f := float(i) / steps
			var p := _from.lerp(tail if not _hit else _to, f)
			p += side * sin(f * PI) * sag + Vector2(0.0, sin(f * PI) * sag * (0.6 if _hit else 0.0))
			pts.append(p)
		draw_polyline(pts, Color(IRON_DARK, 0.5 * fade), 3.8, true)
		draw_polyline(pts, Color(ROPE, 0.9 * fade), 2.0, true)

	if t < 1.0 or not _hit:
		# Shaft.
		draw_line(tail, tip, IRON_DARK, 9.5, true)
		draw_line(tail, tip, IRON, 6.2, true)
		draw_line(tail + side * 1.6, tip + side * 1.6, Color(IRON_LIGHT, 0.5), 1.2, true)
		# Rust bleeding through the pitted iron in uneven patches.
		for r in 5:
			var f0 := 0.08 + 0.19 * r
			draw_line(tail.lerp(tip, f0), tail.lerp(tip, f0 + 0.1 + 0.03 * (r % 2)), Color(RUST, 0.75), 4.0 + float(r % 3), true)
		# Fletching ring at the tail.
		draw_line(tail + side * 8.5, tail - side * 8.5, IRON_DARK, 4.0, true)
		# Barbed head: a spear point with two swept-back barbs.
		var neck := tip - dir * 19.0
		draw_colored_polygon(PackedVector2Array([tip + dir * 16.0, neck + side * 7.0, neck - side * 7.0]), IRON_LIGHT)
		draw_colored_polygon(PackedVector2Array([neck + dir * 4.0 + side * 5.0, neck + dir * 4.0 - side * 5.0, neck - dir * 1.0]), Color(RUST, 0.7))
		draw_colored_polygon(PackedVector2Array([neck + side * 2.8, neck + side * 15.0 - dir * 9.5, neck + dir * 3.0 + side * 7.0]), IRON)
		draw_colored_polygon(PackedVector2Array([neck - side * 2.8, neck - side * 15.0 - dir * 9.5, neck + dir * 3.0 - side * 7.0]), IRON)
		# A wet glint along the flight.
		draw_circle(tip + dir * 11.0, 7.0, Color(FOAM, 0.12))

	# Where it bites: a flash and a ring of water.
	if _hit:
		var ik := clampf((_age - FLIGHT_TIME) / 0.25, 0.0, 1.0)
		draw_circle(_to, lerpf(20.0, 6.0, ik), Color(FOAM, 0.5 * (1.0 - ik)))
		draw_arc(_to, lerpf(6.0, 36.0, 1.0 - pow(1.0 - ik, 2.0)), 0.0, TAU, 24, Color(FOAM, 0.75 * (1.0 - ik)), 2.5 * (1.0 - ik) + 0.5, true)
