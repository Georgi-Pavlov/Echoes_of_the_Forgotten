class_name RoarFX
extends Node2D

## Purely cosmetic: The Primordial Hunger's Maddening Roar.
##
##   1. The roar: the caster shudders as arcs of sound roll out of its
##      jaws toward the target, widening as they travel.
##   2. The target: struck by the roar, it shudders and drains dark and
##      grey for a moment - its will to live gone. `on_target_hit` fires.
##   3. The shattering: rings of sound burst out from the target across
##      the roar's reach. As they pass each other unit in range, its
##      mind shatters - it shudders, flashes violet and throws off
##      glass-like shards. `on_shatter` fires once the rings have reached
##      the last of them (right away if there are none).
##
## Damage is the caller's, through those two callbacks.

const ROAR_ARCS := 7
const ARC_GAP := 0.07          # s between arcs leaving the jaws
const ARC_TRAVEL := 0.4        # s for an arc to reach the target
const SHATTER_SPEED := 650.0   # px/s the rings spread from the target
const RING_COUNT := 3
const RING_SPACING := 28.0     # px between the rings

const WAVE := Color(0.78, 0.88, 1.0)
const MIND := Color(0.78, 0.6, 1.0)

var _caster: Control
var _mouth: Vector2
var _target: Control
var _target_pos: Vector2
# Every other unit in range: {"node", "pos", "dist", "hit"}.
var _others: Array[Dictionary] = []
var _reach := 0.0
var _on_target_hit: Callable
var _on_shatter: Callable
var _age := 0.0
var _target_hit := false
var _shattered := false
var _glow: Node2D


## Plays the roar from `mouth` (global position of the caster's jaws) on
## `caster`, at `target`, shattering every node in `others`. Positions
## are captured now, so a unit killed along the way still gets its show.
static func play(host: Node, caster: Control, mouth: Vector2, target: Control, others: Array,
		on_target_hit: Callable = Callable(), on_shatter: Callable = Callable()) -> void:
	var fx := RoarFX.new()
	fx._caster = caster
	fx._mouth = mouth
	fx._target = target
	fx._target_pos = target.global_position + target.size * Vector2(0.5, 0.5)
	for node in others:
		if is_instance_valid(node) and node is Control:
			var pos: Vector2 = node.global_position + node.size * Vector2(0.5, 0.5)
			var dist := absf(pos.x - fx._target_pos.x)
			fx._others.append({"node": node, "pos": pos, "dist": dist, "hit": false})
			fx._reach = maxf(fx._reach, dist)
	fx._on_target_hit = on_target_hit
	fx._on_shatter = on_shatter
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_waves)
	add_child(_glow)
	if is_instance_valid(_caster):
		_shudder(_caster, ROAR_ARCS * ARC_GAP + 0.25, 4.0)


## When the target is struck: once the middle of the train of arcs
## arrives.
func _hit_time() -> float:
	return ARC_TRAVEL + ARC_GAP * (ROAR_ARCS - 1) * 0.5


func _process(delta: float) -> void:
	_age += delta
	var hit_at := _hit_time()
	if not _target_hit and _age >= hit_at:
		_target_hit = true
		_strike_target()
		if _on_target_hit.is_valid():
			_on_target_hit.call()
	if _target_hit:
		var front := (_age - hit_at) * SHATTER_SPEED
		for o in _others:
			if not o["hit"] and front >= float(o["dist"]):
				o["hit"] = true
				_shatter_mind(o)
		if not _shattered and front >= _reach:
			_shattered = true
			if _on_shatter.is_valid():
				_on_shatter.call()
	var ring_end := hit_at + (maxf(_reach, 120.0) + RING_SPACING * RING_COUNT) / SHATTER_SPEED + 0.3
	if _shattered and _age >= ring_end:
		queue_free()
		return
	_glow.queue_redraw()


func _strike_target() -> void:
	if not (is_instance_valid(_target) and _target is CanvasItem):
		return
	_shudder(_target, 0.45, 6.0)
	# Its will to live drained away: darkened and greyed, then slowly back.
	var drain := _target.create_tween()
	drain.tween_property(_target, "self_modulate", Color(0.35, 0.35, 0.45), 0.08)
	drain.tween_interval(0.25)
	drain.tween_property(_target, "self_modulate", Color.WHITE, 0.5)


func _shatter_mind(o: Dictionary) -> void:
	var node: Variant = o["node"]
	if is_instance_valid(node):
		_shudder(node, 0.3, 4.0)
		var flash: Tween = node.create_tween()
		flash.tween_property(node, "self_modulate", Color(1.4, 1.1, 1.8), 0.05)
		flash.tween_property(node, "self_modulate", Color.WHITE, 0.35)
	# Glass-like shards of a broken mind bursting off its head.
	var shards := CPUParticles2D.new()
	var head: Vector2 = o["pos"] + Vector2(0.0, -40.0)
	if is_instance_valid(node):
		head = node.global_position + node.size * Vector2(0.5, 0.2)
	shards.position = head
	shards.amount = 14
	shards.lifetime = 0.6
	shards.one_shot = true
	shards.explosiveness = 0.95
	shards.direction = Vector2(0.0, -1.0)
	shards.spread = 70.0
	shards.gravity = Vector2(0.0, 260.0)
	shards.initial_velocity_min = 80.0
	shards.initial_velocity_max = 170.0
	shards.angle_min = 0.0
	shards.angle_max = 360.0
	shards.angular_velocity_min = -600.0
	shards.angular_velocity_max = 600.0
	shards.scale_amount_min = 2.0
	shards.scale_amount_max = 4.0
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 0.95), Color(MIND, 0.8), Color(MIND, 0.0)])
	shards.color_ramp = ramp
	shards.material = VoidReachFX._additive()
	get_parent().add_child(shards)
	shards.emitting = true
	get_tree().create_timer(0.9).timeout.connect(shards.queue_free)


## A quick, fading jitter of `node`, settling back to where it was.
## Applied as a change on top of wherever the battle has the node (same
## as TimeStillFX's lift), never as absolute positions - the roar's own
## hits can clear the stage mid-shudder, and the battle then snaps the
## caster back to its starting column; restoring a position captured
## before that would drag its art back to the old spot.
func _shudder(node: Variant, seconds: float, strength: float) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var applied := [Vector2.ZERO]
	var set_offset := func(offset: Vector2) -> void:
		if is_instance_valid(node):
			node.position += offset - applied[0]
			applied[0] = offset
	var t: Tween = node.create_tween()
	var steps := int(seconds / 0.04)
	var prev := Vector2.ZERO
	for i in steps:
		var k := 1.0 - float(i) / steps
		var next := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * k
		t.tween_method(set_offset, prev, next, 0.04)
		prev = next
	t.tween_method(set_offset, prev, Vector2.ZERO, 0.04)


func _draw_waves() -> void:
	# The arcs rolling from the jaws to the target.
	var dir := (_target_pos - _mouth)
	var dist := dir.length()
	if dist > 1.0:
		dir /= dist
		for i in ROAR_ARCS:
			var t := (_age - i * ARC_GAP) / ARC_TRAVEL
			if t <= 0.0 or t >= 1.0:
				continue
			var front := _mouth + dir * dist * t
			var radius := lerpf(24.0, 120.0, t)
			var alpha := minf(sin(t * PI) * 1.3, 1.0)
			_arc(front, dir, radius, deg_to_rad(50.0), Color(WAVE, alpha), 5.0 * (1.0 - t) + 2.0)
	# The rings bursting out from the target.
	if _target_hit:
		var since := _age - _hit_time()
		var extent := maxf(_reach, 120.0) + RING_SPACING * RING_COUNT
		for j in RING_COUNT:
			var r := since * SHATTER_SPEED - j * RING_SPACING
			if r <= 4.0 or r >= extent:
				continue
			var fade := 1.0 - r / extent
			var ring := PackedVector2Array()
			for k in 49:
				var a := TAU * k / 48.0
				ring.append(_target_pos + Vector2(cos(a) * r, sin(a) * r * 0.45))
			var col := WAVE.lerp(MIND, float(j) / RING_COUNT)
			_glow.draw_polyline(ring, Color(col, 0.18 * fade), 9.0 * fade + 2.0, true)
			_glow.draw_polyline(ring, Color(col, 0.75 * fade), 2.0 * fade + 1.0, true)


## An arc of a circle whose front is at `front`, bulging along `dir`,
## `half_angle` either side - drawn as a soft wide stroke and a bright
## thin one.
func _arc(front: Vector2, dir: Vector2, radius: float, half_angle: float, color: Color, width: float) -> void:
	var center := front - dir * radius
	var base := dir.angle()
	var pts := PackedVector2Array()
	for k in 17:
		var a := base + lerpf(-half_angle, half_angle, float(k) / 16.0)
		pts.append(center + Vector2.from_angle(a) * radius)
	_glow.draw_polyline(pts, Color(color, color.a * 0.25), width * 4.0, true)
	_glow.draw_polyline(pts, color, width, true)
