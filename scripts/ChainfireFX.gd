class_name ChainfireFX
extends Node2D

## Purely cosmetic (plus moving the caster's sprite): Cinder's Chainfire.
##
##   1. The shot: a hooked chain flies from his flamethrower up to a point
##      above the target and bites in there with a spark.
##   2. The swing: he swings across on it - lifted off the ground, the
##      chain taut from his weapon to the hook - his flamethrower jetting
##      fire down and back behind him as he goes: the trail starts the
##      moment he leaves and stops the moment he lands, each patch
##      burning where it fell and dying away behind him.
##   3. The landing: he touches down, the chain lets go and whips back.
##      `on_landed` fires (damage, and his position in the battle).
##
## The caster's sprite is moved along the swing (its `position`, in its
## parent's space); the caller sets it to its final spot in on_landed.

const SHOT_TIME := 0.2
const SWING_TIME := 0.5
const RETRACT_TIME := 0.18
const LIFT := 0.3            # how high he's carried mid-swing, of his height
const HOOK_ABOVE := 70.0     # px the hook bites in above the target's head

const CHAIN := Color(0.45, 0.42, 0.4)
const CHAIN_HI := Color(0.85, 0.75, 0.6)
const FIRE := Color(1.0, 0.5, 0.12)
const HOT := Color(1.0, 0.85, 0.45)

var _unit: Control
var _from: Vector2           # the sprite's start position (parent space)
var _to: Vector2             # where it lands (parent space)
var _hand := Vector2(0.9, 0.45)
var _hook: Vector2           # global
var _on_landed: Callable
var _age := 0.0
var _landed := false
var _lines: Node2D
var _glow: Node2D
var _trail: CPUParticles2D
var _fire_loop: AudioStreamPlayer
var _embers: CPUParticles2D


## Swings `unit` (a battle sprite) from where it is to `to` (its position
## in its parent's space at the landing spot), on a chain hooked in above
## `target` (global point at the target's head). `hand` is where on its
## art the chain leaves from (a fraction of its size, already mirrored
## for its facing).
static func play(host: Node, unit: Control, to: Vector2, target_top: Vector2, hand: Vector2, on_landed: Callable = Callable()) -> void:
	var fx := ChainfireFX.new()
	fx._unit = unit
	fx._from = unit.position
	fx._to = to
	fx._hand = hand
	fx._hook = target_top - Vector2(0.0, HOOK_ABOVE)
	fx._on_landed = on_landed
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	AudioManager.play_event("chain")
	_lines = Node2D.new()
	_lines.draw.connect(_draw_chain)
	add_child(_lines)
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)

	# The fire jetting from his flamethrower: emitted in world space, so each
	# patch stays where it fell and burns down there.
	_trail = CPUParticles2D.new()
	_trail.local_coords = false
	_trail.amount = 320
	_trail.lifetime = 1.1
	_trail.texture = VoidReachFX._dot()
	_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_trail.emission_rect_extents = Vector2(6.0, 6.0)
	# Jetting out of the nozzle down and back behind him (set per frame
	# in _process() for the way he swings), slowing, then rising as it burns.
	_trail.direction = Vector2(0.0, 1.0)
	_trail.spread = 16.0
	_trail.gravity = Vector2(0.0, -140.0)
	_trail.initial_velocity_min = 160.0
	_trail.initial_velocity_max = 260.0
	_trail.damping_min = 220.0
	_trail.damping_max = 320.0
	_trail.scale_amount_min = 3.4
	_trail.scale_amount_max = 5.8
	var shape := Curve.new()
	shape.add_point(Vector2(0.0, 0.6))
	shape.add_point(Vector2(0.3, 1.1))
	shape.add_point(Vector2(1.0, 0.2))
	_trail.scale_amount_curve = shape
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.1, 0.4, 0.8, 1.0])
	ramp.colors = PackedColorArray([Color(HOT, 0.0), Color(1.0, 0.9, 0.6, 0.85), Color(FIRE, 0.7), Color(0.75, 0.15, 0.04, 0.4), Color(0.2, 0.05, 0.02, 0.0)])
	_trail.color_ramp = ramp
	_trail.material = VoidReachFX._additive()
	_trail.emitting = false
	get_parent().add_child.call_deferred(_trail)

	_embers = CPUParticles2D.new()
	_embers.local_coords = false
	_embers.amount = 30
	_embers.lifetime = 1.2
	_embers.texture = VoidReachFX._dot()
	_embers.direction = Vector2(0.0, -1.0)
	_embers.spread = 40.0
	_embers.gravity = Vector2(0.0, -20.0)
	_embers.initial_velocity_min = 60.0
	_embers.initial_velocity_max = 150.0
	_embers.scale_amount_min = 0.4
	_embers.scale_amount_max = 0.8
	var ember_ramp := Gradient.new()
	ember_ramp.offsets = PackedFloat32Array([0.0, 0.1, 1.0])
	ember_ramp.colors = PackedColorArray([Color(HOT, 0.0), Color(1.0, 0.8, 0.35, 1.0), Color(FIRE, 0.0)])
	_embers.color_ramp = ember_ramp
	_embers.material = VoidReachFX._additive()
	_embers.emitting = false
	get_parent().add_child.call_deferred(_embers)


## 0..1 through the swing (0 before it starts, 1 once he's landed).
func _swing_t() -> float:
	return clampf((_age - SHOT_TIME) / SWING_TIME, 0.0, 1.0)


func _process(delta: float) -> void:
	_age += delta
	var swinging := _age >= SHOT_TIME and _age < SHOT_TIME + SWING_TIME
	if is_instance_valid(_unit) and _age >= SHOT_TIME and not _landed:
		var t := _swing_t()
		# Eased like a pendulum: picks up speed, then slows into the landing.
		var e := t * t * (3.0 - 2.0 * t)
		var lift := sin(t * PI) * _unit.size.y * LIFT
		_unit.position = _from.lerp(_to, e) - Vector2(0.0, lift)
	# The fire trail runs only while he's swinging - from his first move
	# to his landing - poured from under him.
	if is_instance_valid(_trail) and is_instance_valid(_unit):
		_trail.global_position = _hand_global()
		_trail.direction = Vector2(-signf(_to.x - _from.x) * 0.6, 1.0).normalized()
		_trail.emitting = swinging
		# The fire roars for as long as he swings and trails flame.
		if swinging and _fire_loop == null:
			_fire_loop = AudioManager.play_loop("fire_attack", self)
		_embers.global_position = _hand_global()
		_embers.emitting = swinging
	if not _landed and _age >= SHOT_TIME + SWING_TIME:
		_landed = true
		AudioManager.stop_loop(_fire_loop, 0.2)
		if is_instance_valid(_unit):
			_unit.position = _to
		if is_instance_valid(_trail):
			_trail.emitting = false
			_embers.emitting = false
		if _on_landed.is_valid():
			_on_landed.call()
	if _age >= SHOT_TIME + SWING_TIME + RETRACT_TIME:
		_lines.visible = false
	if _age >= SHOT_TIME + SWING_TIME + 1.4:
		if is_instance_valid(_trail):
			_trail.queue_free()
		if is_instance_valid(_embers):
			_embers.queue_free()
		queue_free()
		return
	_lines.queue_redraw()
	_glow.queue_redraw()


func _hand_global() -> Vector2:
	return _unit.global_position + _unit.size * _hand if is_instance_valid(_unit) else _hook


func _draw_chain() -> void:
	var hand := _hand_global()
	var end: Vector2
	if _age < SHOT_TIME:
		# Flying out to the hook point.
		end = hand.lerp(_hook, 1.0 - pow(1.0 - _age / SHOT_TIME, 2.0))
	elif _age < SHOT_TIME + SWING_TIME:
		end = _hook
	else:
		# Let go - whipping back to his hand.
		end = _hook.lerp(hand, clampf((_age - SHOT_TIME - SWING_TIME) / RETRACT_TIME, 0.0, 1.0))
	# Links: alternating short strokes along the line, so it reads as chain.
	var d := end - hand
	var length := d.length()
	if length < 2.0:
		return
	var dir := d / length
	var n := dir.orthogonal()
	var link := 9.0
	var count := int(length / link)
	for i in count:
		var a := hand + dir * (i * link)
		var b := a + dir * link * 0.9
		var w := 3.0 if i % 2 == 0 else 1.6
		var off := n * (1.5 if i % 2 == 0 else 0.0)
		_lines.draw_line(a + off, b + off, CHAIN, w + 1.5, true)
		_lines.draw_line(a + off, b + off, CHAIN_HI, w * 0.5, true)
	# The hook at its end: a curved prong.
	var hook_pts := PackedVector2Array()
	for k in 7:
		var ang := PI * 0.15 + PI * 0.9 * float(k) / 6.0
		hook_pts.append(end + Vector2(cos(ang), sin(ang)) * 9.0 + dir * 4.0)
	_lines.draw_polyline(hook_pts, CHAIN_HI, 3.0, true)


func _draw_glow() -> void:
	# A spark where the hook bites in.
	var bite := _age - SHOT_TIME
	if bite >= 0.0 and bite < 0.3:
		var k := 1.0 - bite / 0.3
		_glow.draw_circle(_hook, 6.0 + 18.0 * (1.0 - k), Color(HOT, 0.8 * k))
	# The flamethrower's muzzle glowing as it pours fire during the swing.
	if _age >= SHOT_TIME and _age < SHOT_TIME + SWING_TIME and is_instance_valid(_unit):
		var flicker := 0.8 + 0.2 * sin(_age * 50.0)
		_glow.draw_circle(_hand_global(), 22.0 * flicker, Color(FIRE, 0.45))
