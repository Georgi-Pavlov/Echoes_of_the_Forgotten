class_name WintersGripHands
extends Node2D

## Purely cosmetic: Winter's Grip's hold - two skeletal hands of ice
## bursting up out of the frozen ground at a unit's feet, one in front of
## it and one behind, their long finger bones closing round its legs,
## holding it for as long as the stun lasts, then cracking apart and
## sinking back into the earth.
##
## Like Thornbind's vines (ThornbindVines), the hold really wraps the
## unit: the hand behind it is drawn on a second node with
## show_behind_parent, underneath the unit's art, the one in front over
## it. While they hold, their fingers slowly tighten and a cold mist
## rises off them.
##
## Added as a child of the unit's node (so it follows it around and is
## freed with it). battle.gd drives it with attach()/release().

const NODE_NAME := "WintersGripHands"
const RISE_TIME := 0.45
const RELEASE_TIME := 0.5
const MIST := 7

# Where on the unit the hands sit, as fractions of its node's size.
const FEET_Y := 0.93

const ICE := Color(0.66, 0.86, 1.0)
const ICE_DEEP := Color(0.24, 0.46, 0.8)
const RIM := Color(0.92, 0.98, 1.0)
const FROST_GROUND := Color(0.78, 0.9, 1.0)

var _target: Control
var _back: Node2D
var _rise := 0.0
var _fade := 1.0
var _age := 0.0
var _releasing := false
var _release_t := 0.0
# Each hand: where it breaks the ground and where its wrist ends up
# (fractions of the unit's size), which side of the legs it grips from,
# and whether it's in front of the unit or behind it.
var _hands: Array[Dictionary] = []
var _shards: Array[Dictionary] = []


## Starts holding `node` (no-op if it's already held).
static func attach(node: Control) -> void:
	if node.get_node_or_null(NODE_NAME) != null:
		return
	var hands := WintersGripHands.new()
	hands.name = NODE_NAME
	hands._target = node
	node.add_child(hands)


## Cracks `node`'s hands apart and sinks them (no-op if it has none).
static func release(node: Variant) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var hands := (node as Control).get_node_or_null(NODE_NAME) as WintersGripHands
	if hands != null:
		hands._start_release()


func _ready() -> void:
	_back = Node2D.new()
	_back.show_behind_parent = true
	_back.draw.connect(_draw_layer.bind(false))
	_target.add_child(_back)
	# One hand in front of the unit (its left), one behind it (its right),
	# each reaching for the nearer leg - they never overlap.
	for spec in [
		{"base": Vector2(0.18, 0.03), "wrist": Vector2(0.24, -0.24), "side": -1.0, "front": true, "delay": 0.0},
		{"base": Vector2(0.86, -0.02), "wrist": Vector2(0.8, -0.3), "side": 1.0, "front": false, "delay": 0.1},
	]:
		spec["phase"] = randf() * TAU
		_hands.append(spec)


func _exit_tree() -> void:
	if is_instance_valid(_back):
		_back.queue_free()


func _start_release() -> void:
	if _releasing:
		return
	_releasing = true
	# Renamed right away so a quick re-grip raises a fresh set instead of
	# finding this one mid-release.
	name = NODE_NAME + "Releasing"
	# The hands crack apart: ice shards burst off each one.
	var size := _target.size
	for h in _hands:
		var wrist := _point(h, 1.0)
		for i in 9:
			_shards.append({
				"pos": wrist + Vector2(randf_range(-6, 6), randf_range(-4, 10)),
				"vel": Vector2(randf_range(-70, 70), randf_range(-150, -40)),
				"rot": randf() * TAU, "spin": randf_range(-12.0, 12.0),
				"size": randf_range(2.5, 5.0) * (size.x / 128.0 + 0.3), "age": 0.0, "life": randf_range(0.35, 0.6),
				"front": h["front"],
			})


func _process(delta: float) -> void:
	_age += delta
	if _releasing:
		_release_t += delta / RELEASE_TIME
		_rise = 1.0 - smoothstep(0.1, 1.0, _release_t)
		_fade = 1.0 - smoothstep(0.4, 1.0, _release_t)
		if _release_t >= 1.0 and _shards.is_empty():
			queue_free()
			return
	else:
		_rise = clampf(_age / RISE_TIME, 0.0, 1.0)
	for s in _shards:
		s.age += delta
		s.vel.y += 480.0 * delta
		s.pos += s.vel * delta
		s.rot += s.spin * delta
	_shards = _shards.filter(func(s): return s.age < s.life)
	queue_redraw()
	_back.queue_redraw()


func _draw() -> void:
	_draw_layer(true)


## How far hand `h` has risen (0..1), each on its own slight delay.
func _hand_rise(h: Dictionary) -> float:
	var r := clampf((_rise * RISE_TIME - h["delay"]) / (RISE_TIME - h["delay"]), 0.0, 1.0) if not _releasing else _rise
	return 1.0 - pow(1.0 - r, 3.0)


## Point along hand `h`'s forearm, `s` = 0 at the ground .. 1 at the wrist.
func _point(h: Dictionary, s: float) -> Vector2:
	var size := _target.size
	var base: Vector2 = Vector2(h["base"].x * size.x, size.y * FEET_Y + h["base"].y * size.y)
	var wrist: Vector2 = Vector2(h["wrist"].x * size.x, size.y * FEET_Y + h["wrist"].y * size.y)
	# Bowed outward a touch, like an arm straining to hold on.
	var bow: Vector2 = Vector2(h["side"] * size.x * 0.02, 0.0) * sin(s * PI)
	return base.lerp(wrist, s) + bow


func _draw_layer(front: bool) -> void:
	var canvas: CanvasItem = self if front else _back
	if _target == null:
		return
	var size := _target.size
	var a := _fade
	var unit := size.x / 128.0

	# The ground frosting over and cracking where they burst out, behind
	# the unit's feet.
	if not front and _rise > 0.0:
		var feet := Vector2(size.x * 0.5, size.y * FEET_Y)
		var r := size.x * 0.42 * minf(_rise * 1.5, 1.0)
		canvas.draw_set_transform(feet, 0.0, Vector2(1.0, 0.26))
		canvas.draw_circle(Vector2.ZERO, r, Color(FROST_GROUND, 0.28 * a))
		canvas.draw_circle(Vector2.ZERO, r * 0.65, Color(FROST_GROUND, 0.22 * a))
		for i in 7:
			var ang := TAU * i / 7.0 + 0.4
			canvas.draw_line(Vector2.from_angle(ang) * r * 0.2, Vector2.from_angle(ang + 0.15) * r * 1.05,
				Color(RIM, 0.55 * a), 2.0, true)
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for h in _hands:
		if h["front"] != front:
			continue
		var rise := _hand_rise(h)
		if rise <= 0.0:
			continue
		_draw_hand(canvas, h, rise, a, unit)

	# rising cold mist while they hold
	if front and not _releasing and _rise >= 1.0:
		for i in MIST:
			var t := fmod(_age * 0.45 + float(i) / MIST, 1.0)
			var x := size.x * (0.25 + 0.5 * fmod(i * 0.37, 1.0)) + sin(_age * 1.3 + i) * 5.0 * unit
			var y := size.y * FEET_Y - t * size.y * 0.35
			canvas.draw_circle(Vector2(x, y), (5.0 + 7.0 * t) * unit, Color(RIM, 0.12 * (1.0 - t) * sin(t * PI) * 2.0))

	for s in _shards:
		if s.front != front:
			continue
		var k: float = 1.0 - s.age / s.life
		var r: float = s.size
		canvas.draw_colored_polygon(PackedVector2Array([
			s.pos + Vector2.from_angle(s.rot) * r,
			s.pos + Vector2.from_angle(s.rot + 2.3) * r * 0.6,
			s.pos + Vector2.from_angle(s.rot - 2.3) * r * 0.6]), Color(RIM, k))


## One skeletal hand of ice, sized off the unit's width: the two
## forearm bones rising out of the ground, a knot of wrist bones, four
## finger bones fanning from the palm, each finger three jointed bones
## ending in a hooked claw, and a two-boned thumb. `rise` grows the arm
## out of the ground and then closes the fingers round the leg.
func _draw_hand(canvas: CanvasItem, h: Dictionary, rise: float, a: float, _unit: float) -> void:
	var p := _target.size.x * 1.6   # bone sizes below are fractions of this
	var side: float = h["side"]
	var shade := 1.0 if h["front"] else 0.7
	var bone := Color(Color(0.86, 0.94, 1.0) * shade, 0.95 * a)
	var edge := Color(ICE_DEEP * shade, 0.95 * a)
	var aura := Color(ICE, 0.18 * a * shade)

	# forearm: radius and ulna side by side, meeting at the wrist
	var steps := 8
	var wrist := _point(h, rise)
	var up := (wrist - _point(h, maxf(rise - 0.1, 0.0))).normalized()
	if up == Vector2.ZERO:
		up = Vector2.UP
	var across := up.orthogonal()
	for k: float in [-1.0, 1.0]:
		var pts := PackedVector2Array()
		for i in steps + 1:
			var s := float(i) / steps * rise
			var gap: float = lerpf(0.026, 0.012, s) * p * k
			pts.append(_point(h, s) + across * gap)
		_bone(canvas, pts, 0.024 * p if k < 0.0 else 0.018 * p, bone, edge, aura)

	var open := clampf((rise - 0.5) / 0.5, 0.0, 1.0)
	if open <= 0.0:
		return
	# the wrist: a knot of small bones
	for c in [Vector2(-0.018, 0.012), Vector2(0.0, 0.02), Vector2(0.018, 0.012), Vector2(0.0, 0.036)]:
		var pc: Vector2 = wrist + across * c.x * p + up * c.y * p
		canvas.draw_circle(pc, 0.016 * p, edge)
		canvas.draw_circle(pc, 0.011 * p, bone)

	# fingers: long palm bones fanning out, then three jointed bones each,
	# closing over the leg towards the unit's middle
	var inward := Vector2(-side, 0.0)
	var turn := _toward(inward, up)
	var tighten := 0.0 if _releasing else 0.08 * (0.5 + 0.5 * sin(_age * 2.2 + h["phase"]))
	var curl := lerpf(0.05, 1.0, open) + tighten
	var palm_base := wrist + up * 0.045 * p
	for f in 4:
		var off := (f - 1.5) / 1.5
		var fan := up.angle() + off * 0.22
		var knuckle := palm_base + Vector2.from_angle(fan) * (0.085 - absf(off) * 0.012) * p
		_bone(canvas, PackedVector2Array([palm_base + across * off * 0.012 * p, knuckle]), 0.016 * p, bone, edge, aura)
		var joint := knuckle
		var ang := fan
		var pts := PackedVector2Array([joint])
		for seg: float in [0.07, 0.055, 0.042]:
			ang += turn * curl * 0.62
			joint = joint + Vector2.from_angle(ang) * (seg - absf(off) * 0.008) * p
			pts.append(joint)
		_bone(canvas, pts, 0.014 * p, bone, edge, aura)
		for q: Vector2 in pts:
			canvas.draw_circle(q, 0.012 * p, edge)
			canvas.draw_circle(q, 0.008 * p, bone)
		# a hooked claw of ice
		var claw_dir := Vector2.from_angle(ang + turn * 0.5)
		var tip := joint + claw_dir * 0.05 * p
		canvas.draw_colored_polygon(PackedVector2Array([
			joint + claw_dir.orthogonal() * 0.01 * p, tip, joint - claw_dir.orthogonal() * 0.01 * p]),
			Color(RIM, 0.95 * a * shade))
	# the thumb: two bones from the outer side of the wrist
	var t0 := wrist + up * 0.02 * p - across * turn * 0.03 * p
	var t1 := t0 + (up - inward * 0.2).normalized() * 0.07 * p
	var t2 := t1 + (up * 0.3 + inward).normalized() * 0.055 * p * (0.4 + 0.6 * open)
	_bone(canvas, PackedVector2Array([t0, t1, t2]), 0.015 * p, bone, edge, aura)
	canvas.draw_circle(t1, 0.011 * p, edge)
	canvas.draw_circle(t1, 0.007 * p, bone)


## A bone of ice along `pts`: a faint cold aura, a dark edge and the pale
## bone, with a knob at each end.
func _bone(canvas: CanvasItem, pts: PackedVector2Array, width: float, bone: Color, edge: Color, aura: Color) -> void:
	if pts.size() < 2:
		return
	canvas.draw_polyline(pts, aura, width * 2.6, true)
	canvas.draw_polyline(pts, edge, width * 1.35, true)
	canvas.draw_polyline(pts, bone, width, true)
	for q: Vector2 in [pts[0], pts[pts.size() - 1]]:
		canvas.draw_circle(q, width * 0.75, edge)
		canvas.draw_circle(q, width * 0.52, bone)


## +1 / -1: which way to turn from `up` to bend towards `inward`.
func _toward(inward: Vector2, up: Vector2) -> float:
	return signf(up.cross(inward)) if up.cross(inward) != 0.0 else 1.0
