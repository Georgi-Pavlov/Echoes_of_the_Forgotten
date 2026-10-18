class_name ChakramFX
extends Node2D

## Purely cosmetic: Lunara's normal attack ("attack_effect": "chakram") and
## her Lunar Ricochet. A ring of thorned crimson blades forms in her open
## hand and is thrown - it spins up to a blur as it flies, bowing a little
## off a straight line and shedding red sparks - bites into the target
## (`on_hit` fires then, with a flash and a spray of blood-red sparks), and
## curves back to her hand, where it fades in a last glint.
##
## With Lunar Ricochet learned, the same chakram does not come straight
## back: battle.gd adds a waypoint per bounced enemy (add_bounce()), and it
## glances off the target and cuts from enemy to enemy, each bite firing
## that enemy's own callback, before it returns.

const OUT_SPEED := 1500.0      # px/s outbound
const MIN_OUT := 0.16
const MAX_OUT := 0.38
const BOUNCE_SPEED := 1800.0   # px/s between enemies
const MIN_BOUNCE := 0.1
const MAX_BOUNCE := 0.26
const BACK_TIME := 0.3
const GLINT_TIME := 0.18
const RADIUS := 26.0           # px, tip of the blades
const BLADES := 8

const RED := Color(0.95, 0.12, 0.2)
const DEEP := Color(0.45, 0.04, 0.1)
const METAL := Color(0.82, 0.62, 0.55)
const HOT := Color(1.0, 0.75, 0.7)

## The chakram thrown most recently (null once it has gone) - battle.gd
## uses it to chain Lunar Ricochet's bounces onto the attack's own throw.
static var _latest: ChakramFX

var _from: Vector2
var _points: Array[Vector2] = []      # waypoints after `_from`: the target, then each bounce
var _callbacks: Array[Callable] = []  # one per waypoint, fired on arrival
var _legs: Array[Dictionary] = []     # {from, to, start, time, bow}, ending with the return
var _total := 0.0
var _arrived := 0                     # how many waypoints have been reached
var _age := 0.0
var _spin := 0.0
var _trail: CPUParticles2D
var _glow: Node2D


static func play(host: Node, from: Vector2, to: Vector2, on_hit: Callable = Callable()) -> void:
	var fx := ChakramFX.new()
	fx._from = from
	fx._points.append(to)
	fx._callbacks.append(on_hit)
	fx._rebuild_legs()
	host.add_child(fx)
	fx.global_position = Vector2.ZERO
	_latest = fx


## The chakram thrown most recently, if it is still flying.
static func latest() -> ChakramFX:
	return _latest if is_instance_valid(_latest) else null


## Sends the chakram on to `to` (global) after its last waypoint, firing
## `on_hit` as it bites in there. Call right after play().
func add_bounce(to: Vector2, on_hit: Callable = Callable()) -> void:
	_points.append(to)
	_callbacks.append(on_hit)
	_rebuild_legs()


func _ready() -> void:
	# Red sparks shed along the flight, left where they fall.
	_trail = CPUParticles2D.new()
	_trail.local_coords = false
	_trail.amount = 80
	_trail.lifetime = 0.35
	_trail.texture = VoidReachFX._dot()
	_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_trail.emission_sphere_radius = RADIUS * 0.6
	_trail.spread = 180.0
	_trail.gravity = Vector2(0.0, 40.0)
	_trail.initial_velocity_min = 10.0
	_trail.initial_velocity_max = 50.0
	_trail.scale_amount_min = 0.7
	_trail.scale_amount_max = 1.7
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(HOT, 0.9), Color(RED, 0.7), Color(DEEP, 0.0)])
	_trail.color_ramp = ramp
	_trail.material = VoidReachFX._additive()
	add_child(_trail)

	# The glow and trail ribbon, drawn additively under the blades.
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)


## Lays out the flight: out to the first waypoint, on through each bounce,
## then back to the hand.
func _rebuild_legs() -> void:
	_legs.clear()
	var t := 0.0
	var at := _from
	for i in _points.size():
		var p: Vector2 = _points[i]
		var dist := at.distance_to(p)
		var time: float
		var bow: float
		if i == 0:
			time = clampf(dist / OUT_SPEED, MIN_OUT, MAX_OUT)
			bow = 34.0
		else:
			time = clampf(dist / BOUNCE_SPEED, MIN_BOUNCE, MAX_BOUNCE)
			bow = 16.0 * (1.0 if i % 2 == 0 else -1.0)
		_legs.append({"from": at, "to": p, "start": t, "time": time, "bow": bow})
		t += time
		at = p
	_legs.append({"from": at, "to": _from, "start": t, "time": BACK_TIME, "bow": -28.0})
	_total = t + BACK_TIME


func _process(delta: float) -> void:
	_age += delta
	# Spins up fast and stays a blur.
	_spin += delta * (22.0 + 18.0 * minf(_age / 0.15, 1.0))
	# Each waypoint is bitten as the chakram arrives at it.
	while _arrived < _points.size():
		var leg: Dictionary = _legs[_arrived]
		if _age < float(leg["start"]) + float(leg["time"]):
			break
		_impact(Vector2(leg["to"]))
		var cb: Callable = _callbacks[_arrived]
		if cb.is_valid():
			cb.call()
		_arrived += 1
	if _age >= _total + GLINT_TIME:
		if _latest == self:
			_latest = null
		queue_free()
		return
	_trail.global_position = _position()
	_trail.emitting = _age < _total
	queue_redraw()
	_glow.queue_redraw()


## Where the chakram is at `age` seconds into its flight.
func _position_at(age: float) -> Vector2:
	var last := _legs.size() - 1
	var index := last
	for i in _legs.size():
		var l: Dictionary = _legs[i]
		if age < float(l["start"]) + float(l["time"]):
			index = i
			break
	var leg: Dictionary = _legs[index]
	var t := clampf((age - float(leg["start"])) / float(leg["time"]), 0.0, 1.0)
	var a: Vector2 = leg["from"]
	var b: Vector2 = leg["to"]
	var e: float
	if index == last:
		e = t * t * (3.0 - 2.0 * t)          # eases into the hand
	elif index == 0:
		e = 1.0 - pow(1.0 - t, 1.6)          # leaves it fast
	else:
		e = t
	var perp := (b - a).orthogonal().normalized()
	return a.lerp(b, e) + perp * float(leg["bow"]) * sin(t * PI)


func _position() -> Vector2:
	return _position_at(_age)


func _impact(at: Vector2) -> void:
	var burst := CPUParticles2D.new()
	burst.position = at
	burst.one_shot = true
	burst.amount = 22
	burst.lifetime = 0.4
	burst.explosiveness = 0.95
	burst.texture = VoidReachFX._dot()
	burst.spread = 180.0
	burst.gravity = Vector2(0.0, 180.0)
	burst.initial_velocity_min = 70.0
	burst.initial_velocity_max = 220.0
	burst.damping_min = 80.0
	burst.damping_max = 170.0
	burst.scale_amount_min = 0.8
	burst.scale_amount_max = 1.9
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(HOT, 1.0), Color(RED, 0.85), Color(DEEP, 0.0)])
	burst.color_ramp = ramp
	burst.material = VoidReachFX._additive()
	add_child(burst)
	burst.emitting = true


func _draw_glow() -> void:
	if _age >= _total:
		return
	var pos := _position()
	# A fading ribbon of where it has just been.
	for i in 8:
		var back := float(i + 1) * 0.012
		var p := _position_at(maxf(_age - back, 0.0))
		var f := 1.0 - float(i) / 8.0
		_glow.draw_circle(p, RADIUS * (0.5 + 0.4 * f), Color(RED, 0.16 * f))
	_glow.draw_circle(pos, RADIUS * 1.7, Color(RED, 0.16))
	_glow.draw_circle(pos, RADIUS * 1.1, Color(HOT, 0.14))
	# A bright bite wherever it has just landed.
	for i in _arrived:
		var leg: Dictionary = _legs[i]
		var hk := 1.0 - clampf((_age - float(leg["start"]) - float(leg["time"])) / 0.18, 0.0, 1.0)
		if hk > 0.0:
			_glow.draw_circle(Vector2(leg["to"]), 30.0 * (1.4 - 0.4 * hk), Color(1.0, 0.5, 0.55, 0.5 * hk))
	# The glint as it is caught.
	var gt := (_age - _total) / GLINT_TIME
	if gt > 0.0 and gt < 1.0:
		var s := 1.0 - gt
		_glow.draw_circle(_from, 22.0 * s, Color(HOT, 0.6 * s))
		_glow.draw_line(_from - Vector2(34.0 * s, 0.0), _from + Vector2(34.0 * s, 0.0), Color(HOT, 0.8 * s), 2.0, true)
		_glow.draw_line(_from - Vector2(0.0, 34.0 * s), _from + Vector2(0.0, 34.0 * s), Color(HOT, 0.8 * s), 2.0, true)


func _draw() -> void:
	var glint_t := (_age - _total) / GLINT_TIME
	if glint_t >= 1.0:
		return
	var pos := _position()
	# Forms in the hand: swells to full size over its first moments.
	var grow := smoothstep(0.0, 0.08, _age)
	var r := RADIUS * grow
	if glint_t > 0.0:
		r *= 1.0 - glint_t
	if r <= 1.0:
		return
	# Squashed a little, as if turning edge-on while it spins.
	var tilt := 0.55 + 0.45 * absf(cos(_spin * 0.35))
	var xf := Transform2D(0.0, Vector2(1.0, tilt), 0.0, pos)
	draw_set_transform_matrix(xf)
	# The ring itself, then the curved thorn-blades sweeping off it.
	draw_arc(Vector2.ZERO, r * 0.78, 0.0, TAU, 28, Color(DEEP, 0.95), r * 0.3, true)
	draw_arc(Vector2.ZERO, r * 0.78, 0.0, TAU, 28, Color(METAL, 0.9), r * 0.1, true)
	for i in BLADES:
		var a := _spin + TAU * float(i) / float(BLADES)
		var tip := Vector2(cos(a + 0.45), sin(a + 0.45)) * r
		var b0 := Vector2(cos(a), sin(a)) * r * 0.74
		var b1 := Vector2(cos(a + 0.28), sin(a + 0.28)) * r * 0.86
		draw_colored_polygon(PackedVector2Array([b0, tip, b1]), Color(RED, 0.95))
		draw_line(b0, tip, Color(HOT, 0.85), 1.2, true)
	# A hot red core ring.
	draw_arc(Vector2.ZERO, r * 0.55, 0.0, TAU, 24, Color(RED, 0.7), r * 0.07, true)
	draw_set_transform_matrix(Transform2D.IDENTITY)
