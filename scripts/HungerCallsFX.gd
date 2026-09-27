class_name HungerCallsFX
extends Node2D

## Purely cosmetic: The Primordial Hunger's ultimate, The Hunger Calls.
##
##   1. A gust of wind: swirling streaks of wind and frost sent from the
##      caster to the target.
##   2. As it arrives, a vortex opens on the ground round the target -
##      blood-red arms spiralling in round a dark core, as wide as the
##      curse's reach - and stays for as long as the curse holds.
##   3. The frozen target pulsates, slow and heavy, like a heartbeat.
##   4. Every other enemy the curse drives at it (set_hungry_nodes()) is
##      steeped in a throbbing reddish hue - the hunger.
##
## The caller keeps the returned node and calls end() when the curse is
## over (the vortex dies away, the pulsing and the red hue fade).

const WIND_TIME := 0.45
const STREAKS := 7
const TAIL := 140.0                 # px
const VORTEX_HEIGHT := 0.18         # of its width
const PULSE_AMOUNT := 0.05
const PULSE_SPEED := 4.5

const VORTEX_SHADER := preload("res://shaders/hunger_vortex.gdshader")
const TINT_SHADER := preload("res://shaders/hunger_tint.gdshader")
const TINT_NAME := "HungerTint"

const WIND := Color(0.82, 0.9, 1.0)

var _from: Vector2
var _target: Control
var _to: Vector2
var _radius := 100.0
var _behind_host: Control
var _behind_index := 0
var _age := 0.0
var _arrived := false
var _ending := false
var _vortex: ColorRect
var _vortex_mat: ShaderMaterial
var _hungry: Array = []
var _pending_hungry: Array = []
var _offsets: Array[float] = []
var _glow: Node2D
var _trail: CPUParticles2D


## Sends the gust from `from` (global) at `target`, whose vortex will be
## `radius` px wide either side. The gust and trail go under `fx_layer`;
## the vortex under `behind_host` at child index `behind_index` (behind
## the fighters).
static func cast(fx_layer: Node, behind_host: Control, behind_index: int, from: Vector2, target: Control, radius: float) -> HungerCallsFX:
	var fx := HungerCallsFX.new()
	fx._from = from
	fx._target = target
	fx._to = target.global_position + target.size * Vector2(0.5, 0.5)
	fx._radius = radius
	fx._behind_host = behind_host
	fx._behind_index = behind_index
	for i in STREAKS:
		fx._offsets.append(randf_range(-1.0, 1.0))
	fx_layer.add_child(fx)
	fx.global_position = Vector2.ZERO
	return fx


## The units the curse is driving at its victim right now - each gets the
## red hue (once the vortex has opened), anyone no longer listed loses it.
func set_hungry_nodes(nodes: Array) -> void:
	if not _arrived:
		_pending_hungry = nodes.duplicate()
		return
	for node in _hungry.duplicate():
		if not nodes.has(node):
			_set_hungry(node, false)
			_hungry.erase(node)
	for node in nodes:
		if not _hungry.has(node) and is_instance_valid(node) and node is TextureRect:
			_set_hungry(node, true)
			_hungry.append(node)


## The curse is over: the vortex dies away, the target stops pulsing, the
## red hue fades from everyone, and this frees itself.
func end() -> void:
	if _ending:
		return
	_ending = true
	_pulse(_target, false)
	for node in _hungry:
		_set_hungry(node, false)
	_hungry.clear()
	if is_instance_valid(_vortex):
		var fade := _vortex.create_tween()
		fade.tween_property(_vortex, "modulate:a", 0.0, 0.6)
		fade.tween_callback(_vortex.queue_free)
	if is_instance_valid(_trail):
		_trail.emitting = false
	get_tree().create_timer(0.7).timeout.connect(queue_free)


func _ready() -> void:
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_wind)
	add_child(_glow)
	_trail = CPUParticles2D.new()
	_trail.amount = 40
	_trail.lifetime = 0.6
	_trail.texture = VoidReachFX._dot()
	_trail.spread = 180.0
	_trail.initial_velocity_min = 10.0
	_trail.initial_velocity_max = 40.0
	_trail.scale_amount_min = 0.4
	_trail.scale_amount_max = 0.9
	_trail.material = VoidReachFX._additive()
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	ramp.colors = PackedColorArray([Color(WIND, 0.0), Color(WIND, 0.85), Color(WIND, 0.0)])
	_trail.color_ramp = ramp
	_trail.position = _from
	get_parent().add_child.call_deferred(_trail)


func _process(delta: float) -> void:
	_age += delta
	var t := clampf(_age / WIND_TIME, 0.0, 1.0)
	if is_instance_valid(_trail):
		_trail.position = _from.lerp(_to, t)
		_trail.emitting = t < 1.0 and not _ending
	if not _arrived and t >= 1.0:
		_arrived = true
		if not _ending:
			_open_vortex()
			_pulse(_target, true)
			set_hungry_nodes(_pending_hungry)
	# The hungry turn to face their victim as they close in - keep their red
	# copies facing the same way.
	for node in _hungry:
		if is_instance_valid(node):
			var tint: TextureRect = node.get_node_or_null(TINT_NAME)
			if tint != null:
				tint.flip_h = node.flip_h
	_glow.queue_redraw()


func _open_vortex() -> void:
	if not is_instance_valid(_behind_host) or not is_instance_valid(_target):
		return
	_vortex_mat = ShaderMaterial.new()
	_vortex_mat.shader = VORTEX_SHADER
	_vortex = ColorRect.new()
	_vortex.material = _vortex_mat
	_vortex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vortex.size = Vector2(_radius * 2.0, _radius * 2.0 * VORTEX_HEIGHT)
	_vortex.pivot_offset = _vortex.size * 0.5
	# On the ground under the target.
	var feet: Vector2 = _target.global_position + _target.size * Vector2(0.5, 0.97)
	_behind_host.add_child(_vortex)
	_behind_host.move_child(_vortex, _behind_index)
	_vortex.global_position = feet - _vortex.size * 0.5
	_vortex.scale = Vector2.ZERO
	var open := _vortex.create_tween()
	open.tween_property(_vortex, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## The gust: several streaks of wind travelling together from the caster
## to the target, each with a fading tail, curling as they go.
func _draw_wind() -> void:
	var t := clampf(_age / WIND_TIME, 0.0, 1.0)
	var fade := 1.0 - clampf((_age - WIND_TIME) / 0.25, 0.0, 1.0)
	if fade <= 0.0:
		return
	var dir := _to - _from
	var dist := dir.length()
	if dist < 1.0:
		return
	dir /= dist
	var n := dir.orthogonal()
	for i in STREAKS:
		var offset: float = _offsets[i]
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for k in 11:
			var along := dist * t - TAIL * float(k) / 10.0
			if along < 0.0:
				break
			var curl := sin(along * 0.05 + _age * 14.0 + offset * 5.0) * 10.0
			pts.append(_from + dir * along + n * (offset * 22.0 + curl))
			cols.append(Color(WIND, 0.8 * fade * (1.0 - float(k) / 10.0)))
		if pts.size() >= 2:
			_glow.draw_polyline_colors(pts, cols, 3.5, true)


## Makes `node` pulsate like a slow, heavy heartbeat (or stops it), by
## turning up its CreatureAnimator's own breathing - so it never fights the
## battle's own tweens of the node - and putting it back afterwards.
static func _pulse(node: Variant, on: bool) -> void:
	var animator := CreatureAnimator.of(node)
	if animator == null:
		return
	var mat: ShaderMaterial = animator._mat
	if on:
		if not node.has_meta("hunger_pulse_saved"):
			node.set_meta("hunger_pulse_saved", [mat.get_shader_parameter("breath_amount"), mat.get_shader_parameter("breath_speed")])
		mat.set_shader_parameter("breath_amount", PULSE_AMOUNT)
		mat.set_shader_parameter("breath_speed", PULSE_SPEED)
	elif node.has_meta("hunger_pulse_saved"):
		var saved: Array = node.get_meta("hunger_pulse_saved")
		mat.set_shader_parameter("breath_amount", saved[0])
		mat.set_shader_parameter("breath_speed", saved[1])
		node.remove_meta("hunger_pulse_saved")


## Steeps `node` (a unit's sprite) in the hunger's red, or fades it back
## out: a copy of its art over it, drawn by hunger_tint.gdshader.
static func _set_hungry(node: Variant, on: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	var tint: TextureRect = node.get_node_or_null(TINT_NAME)
	if not on:
		if tint != null:
			tint.name = TINT_NAME + "Fading"
			var fade := tint.create_tween()
			fade.tween_property(tint, "modulate:a", 0.0, 0.4)
			fade.tween_callback(tint.queue_free)
		return
	if tint != null:
		return
	var mat := ShaderMaterial.new()
	mat.shader = TINT_SHADER
	tint = TextureRect.new()
	tint.name = TINT_NAME
	tint.material = mat
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tint.texture = node.texture
	tint.expand_mode = node.expand_mode
	tint.stretch_mode = node.stretch_mode
	tint.flip_h = node.flip_h
	tint.flip_v = node.flip_v
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tint.modulate.a = 0.0
	node.add_child(tint)
	tint.create_tween().tween_property(tint, "modulate:a", 1.0, 0.4)
