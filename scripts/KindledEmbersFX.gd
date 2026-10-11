class_name KindledEmbersFX
extends Node2D

## Purely cosmetic: Cinder's Kindled Resolve. Embers smoulder on his
## battered armor and rags while stacks are up - each stack its own little
## bed of embers, so the more he's been hit the more of him glows and the
## thicker the sparks fly - over a heat glow on his armor that deepens
## with them. Every new stack bursts in with a shower of sparks; as
## stacks run out their embers die away one by one.
##
## Kept in step with the battle's stack count by sync(), called whenever
## bars refresh: it adds a bed per new stack, drops one per expired one,
## and frees itself when none are left.

const NODE_NAME := "KindledEmbers"

# Where on his art the armor is (fraction of its size) - the embers
# smoulder over this.
const ARMOR := Rect2(0.25, 0.3, 0.33, 0.35)
const EMBER := Color(1.0, 0.55, 0.15)
const HOT := Color(1.0, 0.85, 0.45)

var _unit: TextureRect
var _beds: Array[CPUParticles2D] = []
var _glow: TextureRect
# A glowing coal on his armor per stack, where its embers lift off.
var _coals: Node2D
var _time := 0.0
var _ending := false


## Shows `stacks` (of `max_stacks`) on `unit`: creates the effect on the
## first stack, grows or shrinks it after, ends it at zero.
static func sync(unit: Variant, stacks: int, max_stacks: int) -> void:
	if not (unit is TextureRect) or not is_instance_valid(unit):
		return
	var fx: KindledEmbersFX = unit.get_node_or_null(NODE_NAME) as KindledEmbersFX
	if stacks <= 0:
		if fx != null:
			fx._end()
		return
	if fx == null:
		fx = KindledEmbersFX.new()
		fx.name = NODE_NAME
		fx._unit = unit
		unit.add_child(fx)
	fx._set_stacks(stacks, maxi(max_stacks, 1))


func _ready() -> void:
	# A copy of his art, added in warm light over the armor - the heat in
	# it, deepening with every stack.
	_glow = TextureRect.new()
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.texture = _unit.texture
	_glow.expand_mode = _unit.expand_mode
	_glow.stretch_mode = _unit.stretch_mode
	_glow.flip_h = _unit.flip_h
	_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_glow.material = VoidReachFX._additive()
	_glow.self_modulate = Color(EMBER, 0.0)
	add_child(_glow)
	_coals = Node2D.new()
	_coals.material = VoidReachFX._additive()
	_coals.draw.connect(_draw_coals)
	add_child(_coals)


func _set_stacks(stacks: int, max_stacks: int) -> void:
	while _beds.size() < stacks:
		_beds.append(_new_bed())
		_spark_burst()
	while _beds.size() > stacks:
		var bed: CPUParticles2D = _beds.pop_back()
		bed.emitting = false
		get_tree().create_timer(bed.lifetime + 0.1).timeout.connect(bed.queue_free)
	set_meta("max_stacks", max_stacks)


## One stack's bed of embers: sparks lifting off a random patch of his
## armor, drifting up and winking out.
func _new_bed() -> CPUParticles2D:
	var size: Vector2 = _unit.size
	var p := CPUParticles2D.new()
	var patch := Vector2(randf_range(ARMOR.position.x, ARMOR.end.x), randf_range(ARMOR.position.y, ARMOR.end.y))
	if _unit.flip_h:
		patch.x = 1.0 - patch.x
	p.position = size * patch
	p.amount = 24
	p.lifetime = 1.2
	p.texture = VoidReachFX._dot()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = size * Vector2(0.12, 0.1)
	p.direction = Vector2(0.0, -1.0)
	p.spread = 35.0
	p.gravity = Vector2(0.0, -30.0)
	p.initial_velocity_min = 12.0
	p.initial_velocity_max = 38.0
	p.tangential_accel_min = -20.0
	p.tangential_accel_max = 20.0
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.3
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.15, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(HOT, 0.0), Color(HOT, 1.0), Color(EMBER, 0.8), Color(0.6, 0.12, 0.03, 0.0)])
	p.color_ramp = ramp
	p.material = VoidReachFX._additive()
	add_child(p)
	p.emitting = true
	return p


## A new stack: a shower of sparks bursting off his armor.
func _spark_burst() -> void:
	var p := CPUParticles2D.new()
	p.position = _unit.size * ARMOR.get_center()
	p.amount = 18
	p.lifetime = 0.6
	p.one_shot = true
	p.explosiveness = 0.95
	p.texture = VoidReachFX._dot()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = _unit.size * ARMOR.size * 0.4
	p.spread = 180.0
	p.gravity = Vector2(0.0, 160.0)
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 150.0
	p.scale_amount_min = 0.4
	p.scale_amount_max = 0.9
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	ramp.colors = PackedColorArray([Color(1.0, 0.95, 0.7, 1.0), Color(EMBER, 0.8), Color(EMBER, 0.0)])
	p.color_ramp = ramp
	p.material = VoidReachFX._additive()
	add_child(p)
	p.emitting = true
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)


## Each stack's coal: a hot core in a soft orange glow, smouldering on its
## own rhythm.
func _draw_coals() -> void:
	var r := _unit.size.x * 0.05
	for i in _beds.size():
		var bed: CPUParticles2D = _beds[i]
		var pulse := 0.7 + 0.3 * sin(_time * (3.0 + i * 0.7) + i * 1.9)
		_coals.draw_circle(bed.position, r * 2.2, Color(EMBER, 0.22 * pulse))
		_coals.draw_circle(bed.position, r, Color(HOT, 0.55 * pulse))
		_coals.draw_circle(bed.position, r * 0.4, Color(1.0, 0.95, 0.8, 0.7 * pulse))


func _end() -> void:
	if _ending:
		return
	_ending = true
	name = NODE_NAME + "Ending"
	for bed in _beds:
		bed.emitting = false
	_beds.clear()
	_coals.queue_redraw()
	var fade := create_tween()
	fade.tween_property(_glow, "self_modulate:a", 0.0, 0.6)
	get_tree().create_timer(1.3).timeout.connect(queue_free)


func _process(delta: float) -> void:
	_time += delta
	if not is_instance_valid(_unit):
		queue_free()
		return
	_glow.flip_h = _unit.flip_h
	_glow.texture = _unit.texture
	if _ending:
		return
	# The heat in his armor: deeper with every stack, flickering like coals.
	var share := float(_beds.size()) / float(get_meta("max_stacks", 1))
	var flicker := 0.8 + 0.12 * sin(_time * 7.0) + 0.08 * sin(_time * 17.0)
	_glow.self_modulate = Color(EMBER, (0.1 + 0.35 * share) * flicker)
	_coals.queue_redraw()
