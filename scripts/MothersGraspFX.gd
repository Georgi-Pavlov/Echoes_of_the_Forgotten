class_name MothersGraspFX
extends Control

## Purely cosmetic: the Rootmother's ultimate, Mother's Grasp.
##
##   1. The slam: she brings her power down on the ground, and a ridge of
##      upheaval races out beneath the floor toward each unit caught,
##      kicking up soil (ridge()).
##   2. The eruption: where it arrives, thick thorned roots tear up out of
##      the earth around the unit, arching in over it and gripping, their
##      tips hooked into its body, soil and stones flying. The ground is
##      cracked and scorched where they burst through. The roots on the far
##      side are drawn BEHIND the unit, so it really is wrapped.
##   3. The hold: they strain slowly, and clench with a spatter of blood
##      each time they tear into the unit (pulse_on()).
##   4. The release: they sink back and crumble into the ground.
##
## One of these is a child of each held unit's sprite, so it follows it.
## battle.gd drives it with set_on() and pulse_on().

const MARK_NAME := "MothersGraspHold"
## How long after the cast the ground is struck, and how fast the ridge
## races across it (px/s).
const SLAM_DELAY := CreatureAnimator.SLAM_IMPACT_TIME
const RIDGE_SPEED := 1100.0
const ERUPT_TIME := 0.24
const RELEASE_TIME := 0.5
const ROOT_COUNT := 7
const ROOT_POINTS := 14

const ROOT_OUTLINE := Color(0.05, 0.03, 0.02)
const ROOT_BASE := Color(0.09, 0.055, 0.035)
const ROOT_MID := Color(0.2, 0.125, 0.07)
const ROOT_TIP := Color(0.4, 0.31, 0.19)
const ROOT_LIGHT := Color(0.55, 0.42, 0.26)
const FIBRE := Color(0.6, 0.08, 0.11)
const SOIL := Color(0.14, 0.09, 0.06)
const SOIL_LIGHT := Color(0.34, 0.24, 0.15)
const STONE := Color(0.32, 0.3, 0.27)
const BLOOD := Color(0.55, 0.04, 0.06)

var _mode := "hold"
var _age := 0.0

# Hold.
var _delay := 0.0
var _erupted := false
var _releasing := false
var _release_t := 0.0
var _size := Vector2.ONE
var _back: Control
var _holders: Array[Dictionary] = []
var _cracks: Array[PackedVector2Array] = []
var _mound_noise: Array[float] = []
var _ground := 0.0
var _squeeze := 0.0

# Ridge.
var _from: Vector2
var _to: Vector2
var _travel := 0.2
var _head: CPUParticles2D


## Seizes `node` (a TextureRect) in the roots, or lets it go. `origin` is
## the caster's feet (global) - the ridge runs from there, over `host` - and
## the roots wait for it to arrive. Only does anything when the state
## actually changes (the hold's presence on the node is the marker).
static func set_on(node: Variant, active: bool, origin: Vector2 = Vector2.ZERO, host: Node = null) -> void:
	if node == null or not is_instance_valid(node) or not (node is TextureRect):
		return
	var existing := node.get_node_or_null(MARK_NAME) as MothersGraspFX
	if active == (existing != null):
		return
	if not active:
		existing.name = MARK_NAME + "Fading"
		existing._begin_release()
		return
	var fx := MothersGraspFX.new()
	fx._mode = "hold"
	fx.name = MARK_NAME
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fx._size = (node as Control).size
	var feet: Vector2 = node.global_position + Vector2(node.size.x * 0.5, node.size.y * 0.95)
	if origin != Vector2.ZERO:
		var travel := clampf(origin.distance_to(feet) / RIDGE_SPEED, 0.12, 0.5)
		fx._delay = SLAM_DELAY + travel
		if host != null:
			ridge(host, origin, feet)
	node.add_child(fx)


## The roots clench on `node` as they tear into it.
static func pulse_on(node: Variant) -> void:
	if node == null or not is_instance_valid(node) or not (node is Node):
		return
	var hold := (node as Node).get_node_or_null(MARK_NAME) as MothersGraspFX
	if hold != null:
		hold._clench()


## The ridge racing across the ground from `from` to `to` (global), under
## `host`.
static func ridge(host: Node, from: Vector2, to: Vector2) -> void:
	var fx := MothersGraspFX.new()
	fx._mode = "ridge"
	fx._from = from
	fx._to = to
	fx._travel = clampf(from.distance_to(to) / RIDGE_SPEED, 0.12, 0.5)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(fx)
	fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _ready() -> void:
	if _mode == "ridge":
		_head = _soil_particles(18, 0.4, 60.0, 140.0, 500.0)
		_head.one_shot = false
		_head.explosiveness = 0.0
		add_child(_head)
		return
	_build_hold()


func _exit_tree() -> void:
	if _mode == "hold" and is_instance_valid(_back):
		_back.queue_free()


# --- the hold -------------------------------------------------------

func _build_hold() -> void:
	var node := get_parent() as Control
	var s := _size
	# The ground under and behind the unit - drawn beneath its sprite.
	_back = Control.new()
	_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_back.size = s
	_back.position = node.position
	_back.draw.connect(_draw_ground)
	node.get_parent().add_child(_back)
	node.get_parent().move_child(_back, node.get_index())

	for i in 22:
		_mound_noise.append(randf_range(0.85, 1.12))
	for i in 9:
		var ang := TAU * (float(i) + randf_range(0.2, 0.8)) / 9.0
		var pts := PackedVector2Array([Vector2.ZERO])
		var p := Vector2.ZERO
		for k in 4:
			p += Vector2.from_angle(ang + randf_range(-0.4, 0.4)) * s.x * randf_range(0.1, 0.19) * Vector2(1.0, 0.32)
			pts.append(p)
		_cracks.append(pts)

	var width := clampf(s.x * 0.085, 9.0, 20.0)
	for i in ROOT_COUNT:
		_make_root(i, s, width)


## One root: its geometry is fixed here, and animated afterwards by scaling
## and swaying its holder (which sits at the root's base).
func _make_root(i: int, s: Vector2, width: float) -> void:
	var back := i % 2 == 1
	var fx := (float(i) + 0.5) / ROOT_COUNT
	var base := Vector2(s.x * (0.5 + (fx - 0.5) * 0.96), s.y * (0.84 if back else 0.97))
	var side := 1.0 if fx >= 0.5 else -1.0
	var w := width * (0.85 if back else 1.0)
	# Leans outward as it rises, then curls over inward like a claw - the
	# farther from the middle, the harder it has to turn back in.
	var reach := absf(fx - 0.5) * 2.0
	# No two alike: some hook tight over the unit, some only half curl and
	# stab up and in, some lean hard, some are short stubs.
	var params := {
		"length": s.y * randf_range(0.6, 1.3) * (0.85 if back else 1.0),
		"a0": side * randf_range(0.05, 0.75),
		"curl": -side * randf_range(0.9, 3.3) * (0.7 + 0.5 * reach),
		"phase": randf() * TAU,
	}
	w *= randf_range(0.8, 1.2)
	var holder := Node2D.new()
	holder.position = base
	holder.scale = Vector2(1.0, 0.0)
	holder.modulate = Color(0.78, 0.78, 0.78) if back else Color.WHITE
	(_back if back else self).add_child(holder)

	var pts := _root_points(params, ROOT_POINTS)
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(0.35, 0.72))
	curve.add_point(Vector2(0.8, 0.3))
	curve.add_point(Vector2(1.0, 0.03))
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	gradient.colors = PackedColorArray([ROOT_BASE, ROOT_MID, ROOT_TIP])

	holder.add_child(_line(pts, w + 3.0, curve, null, ROOT_OUTLINE))
	holder.add_child(_line(pts, w, curve, gradient, Color.WHITE))
	# A lighter ridge along the root catching the light.
	var lit := PackedVector2Array()
	for k in range(1, int(ROOT_POINTS * 0.8)):
		lit.append(pts[k] + Vector2(-w * 0.2, -w * 0.12))
	holder.add_child(_line(lit, maxf(w * 0.28, 1.2), null, null, Color(ROOT_LIGHT, 0.45)))
	# Raw red fibre twisting through it.
	var fibre := PackedVector2Array()
	for k in range(1, int(ROOT_POINTS * 0.88)):
		fibre.append(pts[k] + Vector2(sin(float(k) * 1.4 + float(params["phase"])) * w * 0.22, 0.0))
	holder.add_child(_line(fibre, 1.8, null, null, Color(FIBRE, 0.6)))
	# Ridges of bark across it, narrowing toward the tip.
	for k in range(1, ROOT_POINTS - 1):
		if k % 2 != 0:
			continue
		var tangent := (pts[k + 1] - pts[k - 1]).normalized()
		var n := tangent.orthogonal()
		var half := w * 0.5 * lerpf(1.0, 0.25, float(k) / ROOT_POINTS) * 0.85
		holder.add_child(_line(PackedVector2Array([pts[k] + n * half, pts[k] - n * half]), 1.3, null, null, Color(0.02, 0.01, 0.01, 0.5)))
	# Thorns hooking out along it, pale-tipped.
	for j in 6:
		var u := 0.16 + 0.12 * j
		var k := int(u * ROOT_POINTS)
		var at := pts[k]
		var tangent := (pts[k + 1] - pts[k]).normalized()
		var n := tangent.orthogonal() * (1.0 if j % 2 == 0 else -1.0)
		var half_w := w * lerpf(0.5, 0.15, u)
		var thorn := Polygon2D.new()
		thorn.polygon = PackedVector2Array([at - tangent * 3.5 + n * half_w * 0.6, at + n * (half_w + 11.0) - tangent * 3.0, at + tangent * 3.5 + n * half_w * 0.6])
		thorn.color = ROOT_OUTLINE.lightened(0.1)
		holder.add_child(thorn)
		var tip := Polygon2D.new()
		tip.polygon = PackedVector2Array([at + n * (half_w + 6.0) - tangent * 1.6, at + n * (half_w + 11.0) - tangent * 3.0, at + n * (half_w + 6.0) + tangent * 0.4])
		tip.color = Color(ROOT_TIP, 0.9)
		holder.add_child(tip)

	_holders.append({"node": holder, "phase": randf() * TAU, "back": back, "tilt": randf_range(-0.12, 0.12)})


## The root's centreline, walked step by step: it heads up (angle measured
## from straight up, + to the right), and its heading keeps turning, faster
## toward the end, so it arches over and its tip hooks down into the unit.
## A knotty wobble in the heading keeps it from running true.
func _root_points(p: Dictionary, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array([Vector2.ZERO])
	var pos := Vector2.ZERO
	var step: float = float(p["length"]) / n
	for k in range(1, n + 1):
		var u := float(k) / n
		var heading: float = float(p["a0"]) + float(p["curl"]) * pow(u, 1.6) + sin(u * 9.0 + float(p["phase"])) * 0.22 + sin(u * 17.0 + float(p["phase"]) * 2.0) * 0.1
		pos += Vector2(sin(heading), -cos(heading)) * step
		pts.append(pos)
	return pts


func _line(pts: PackedVector2Array, width: float, curve: Curve, gradient: Gradient, color: Color) -> Line2D:
	var line := Line2D.new()
	line.points = pts
	line.width = width
	if curve != null:
		line.width_curve = curve
	if gradient != null:
		line.gradient = gradient
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.antialiased = true
	return line


func _process(delta: float) -> void:
	_age += delta
	if _mode == "ridge":
		_process_ridge()
		return
	var node := get_parent() as Control
	if node == null or not is_instance_valid(_back):
		return
	_back.position = node.position
	if not _erupted and not _releasing and _age >= _delay:
		_erupt()
	_squeeze = move_toward(_squeeze, 0.0, delta * 2.2)
	var squeeze := _squeeze * _squeeze
	for h in _holders:
		var holder: Node2D = h["node"]
		if not _erupted or _releasing:
			continue
		# Straining against the unit while it holds, clenching on each tear.
		holder.rotation = float(h["tilt"]) + sin(_age * 1.2 + float(h["phase"])) * 0.035 + (0.05 if holder.position.x < _size.x * 0.5 else -0.05) * squeeze
		holder.scale.x = 1.0 - 0.14 * squeeze
	if _releasing:
		_release_t += delta
		if _release_t >= RELEASE_TIME:
			queue_free()
			return
	if _erupted and not _releasing:
		_ground = move_toward(_ground, 1.0, delta * 3.0)
	elif _releasing:
		_ground = clampf(1.0 - _release_t / RELEASE_TIME, 0.0, 1.0)
	_back.queue_redraw()


## The ground splits and the roots tear up out of it.
func _erupt() -> void:
	_erupted = true
	var tween := create_tween()
	for i in _holders.size():
		var holder: Node2D = _holders[i]["node"]
		tween.parallel().tween_property(holder, "scale:y", 1.0, ERUPT_TIME).set_delay(i * 0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var burst := _soil_particles(26, 0.65, 100.0, 230.0, 700.0)
	burst.position = Vector2(_size.x * 0.5, _size.y * 0.95)
	burst.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	burst.emission_rect_extents = Vector2(_size.x * 0.4, 4.0)
	burst.spread = 55.0
	add_child(burst)
	burst.emitting = true
	burst.finished.connect(burst.queue_free)


## The roots clench: they squeeze in, and blood spatters where they tear.
func _clench() -> void:
	if not _erupted or _releasing:
		return
	_squeeze = 1.0
	var blood := _soil_particles(9, 0.55, 40.0, 110.0, 520.0)
	blood.color = BLOOD
	blood.position = Vector2(_size.x * 0.5, _size.y * 0.62)
	blood.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	blood.emission_sphere_radius = _size.x * 0.12
	blood.scale_amount_min = 1.6
	blood.scale_amount_max = 3.0
	blood.spread = 90.0
	add_child(blood)
	blood.emitting = true
	blood.finished.connect(blood.queue_free)


func _begin_release() -> void:
	if _releasing:
		return
	_releasing = true
	_release_t = 0.0
	if not _erupted:
		queue_free()
		return
	var tween := create_tween()
	for i in _holders.size():
		var holder: Node2D = _holders[i]["node"]
		holder.rotation = 0.0
		tween.parallel().tween_property(holder, "scale:y", 0.0, RELEASE_TIME * 0.8).set_delay(i * 0.02).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var crumble := _soil_particles(14, 0.5, 20.0, 80.0, 500.0)
	crumble.position = Vector2(_size.x * 0.5, _size.y * 0.9)
	crumble.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	crumble.emission_rect_extents = Vector2(_size.x * 0.35, 4.0)
	add_child(crumble)
	crumble.emitting = true
	crumble.finished.connect(crumble.queue_free)


## The torn ground under and behind the unit: a dark mound of upturned
## earth with cracks fanning out of it, a dull red light in the cracks.
func _draw_ground() -> void:
	if _ground <= 0.01:
		return
	var s := _size
	var c := Vector2(s.x * 0.5, s.y * 0.96)
	var rim := PackedVector2Array()
	for i in _mound_noise.size():
		var a := TAU * i / _mound_noise.size()
		rim.append(c + Vector2(cos(a) * s.x * 0.46, sin(a) * s.y * 0.07) * _mound_noise[i] * _ground)
	_back.draw_colored_polygon(rim, Color(SOIL, 0.9 * _ground))
	_back.draw_polyline(rim + PackedVector2Array([rim[0]]), Color(SOIL_LIGHT, 0.35 * _ground), 1.5, true)
	for pts in _cracks:
		var placed := PackedVector2Array()
		for p in pts:
			placed.append(c + p * _ground)
		_back.draw_polyline(placed, Color(0.03, 0.02, 0.01, 0.9 * _ground), 3.0, true)
		_back.draw_polyline(placed, Color(0.7, 0.12, 0.1, 0.35 * _ground), 1.0, true)


# --- the ridge ------------------------------------------------------

func _process_ridge() -> void:
	if _age >= SLAM_DELAY + _travel + 0.5:
		queue_free()
		return
	var p := clampf((_age - SLAM_DELAY) / _travel, 0.0, 1.0)
	if is_instance_valid(_head):
		_head.emitting = _age >= SLAM_DELAY and p < 1.0
		_head.position = to_local_point(_from.lerp(_to, p))
	queue_redraw()


func to_local_point(global_point: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * global_point


func _draw() -> void:
	if _mode != "ridge" or _age < SLAM_DELAY:
		return
	var head := clampf((_age - SLAM_DELAY) / _travel, 0.0, 1.0)
	var n := 24
	var normal := (_to - _from).normalized().orthogonal()
	var prev := Vector2.ZERO
	for i in range(0, n + 1):
		var s := float(i) / n
		if s > head:
			break
		var g := _from.lerp(_to, s) + normal * sin(s * 47.0) * 2.0 + Vector2(0.0, -2.0 * sin(s * PI * 6.0))
		var p := to_local_point(g)
		# Each stretch of ground fades as the ridge moves on past it.
		var passed := _age - (SLAM_DELAY + s * _travel)
		var a := clampf(1.0 - passed / 0.4, 0.0, 1.0)
		if i > 0 and a > 0.0:
			draw_line(prev, p, Color(SOIL, 0.9 * a), 7.0 * a + 1.0, true)
			draw_line(prev + Vector2(0.0, -2.0), p + Vector2(0.0, -2.0), Color(SOIL_LIGHT, 0.55 * a), 2.0, true)
			draw_line(prev, p, Color(0.7, 0.12, 0.1, 0.25 * a), 1.0, true)
		prev = p


# --- helpers --------------------------------------------------------

## A one-shot spray of soil clods and pebbles - not yet emitting.
func _soil_particles(amount: int, lifetime: float, vel_min: float, vel_max: float, gravity: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.explosiveness = 0.9
	p.amount = amount
	p.lifetime = lifetime
	p.direction = Vector2(0.0, -1.0)
	p.spread = 50.0
	p.gravity = Vector2(0.0, gravity)
	p.initial_velocity_min = vel_min
	p.initial_velocity_max = vel_max
	p.angle_min = 0.0
	p.angle_max = 360.0
	p.angular_velocity_min = -300.0
	p.angular_velocity_max = 300.0
	p.scale_amount_min = 2.4
	p.scale_amount_max = 5.0
	p.color = SOIL_LIGHT
	p.hue_variation_min = -0.03
	p.hue_variation_max = 0.03
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 1), Color(0.8, 0.8, 0.8, 0.9), Color(0.6, 0.6, 0.6, 0.0)])
	p.color_ramp = ramp
	return p
