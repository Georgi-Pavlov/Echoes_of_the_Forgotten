class_name RimecleaverFX
extends Node2D

## Purely cosmetic: Frost Daughter's Rimecleaver.
##
##   1. Forming: frost motes rush together above the target and a great
##      axe of solid ice takes shape out of them, then tilts back.
##   2. The fall: it drops and chops down onto the target. This is the
##      moment `on_impact` fires - the damage is the caller's. Shards of
##      ice burst out and a ring of frost rolls across the ground.
##   3. The pendulum (only when `sweep_radius` > 0, levels 3 and 4): the
##      axe wrenches free and hangs from a chain of ice high above the
##      target, then swings like a pendulum across the skill's radius -
##      once, slowly, out to one side and back through to the other before
##      settling (it's double-bitted, so an edge leads both ways without it
##      turning) - leaving a frozen trail. `on_pass` fires for each of
##      `pass_nodes` as the axe cuts through it, then `on_sweep` (the
##      splash damage, again the caller's).
##   4. The axe shatters into falling shards and melts away.
##
## Positions are captured at play(), so a unit killed by the blow still
## gets the whole show. Drawn by this one node (plus an additive child
## for the glow), over the fighters.

const FORM_TIME := 0.55
const HOVER_TIME := 0.14
const FALL_TIME := 0.2
const STUCK_TIME := 0.28
const LIFT_TIME := 0.18
const SWEEP_TIME := 2.4          # one slow swing out and back
const SWING_PERIODS := 1.0
const SWING_DAMPING := 0.12      # how much the return has lost vs the first swing out
const SHATTER_TIME := 0.45
const MOTES := 26
const TRAIL_POINTS := 22
const SWEEP_FLATTEN := 0.3   # the frost ring on the ground, seen from the side
const RAISED_ROT := -1.45    # formed upright: haft hanging below the head, edge facing right
const WINDUP_ROT := -1.75    # drawn back a little further before the chop

const ICE := Color(0.62, 0.84, 1.0)
const ICE_DEEP := Color(0.26, 0.5, 0.86)
const RIM := Color(0.9, 0.97, 1.0)
const GLOW := Color(0.5, 0.78, 1.0)

var _impact: Vector2          # where the blade bites (on the target)
var _hover: Vector2           # where the axe forms
var _ground: Vector2          # the target's feet (the frost ring)
var _sweep_center: Vector2    # the target's body (the bottom of the pendulum's arc)
var _pivot: Vector2           # where the pendulum hangs from
var _arm := 100.0             # pivot -> axe head
var _swing_amp := 0.8         # the swing's widest angle, radians
var _h := 80.0                # axe length
var _sweep_radius := 0.0
var _on_impact: Callable
var _on_sweep: Callable
var _on_finished: Callable
var _pass_x: Array[float] = []    # centre x of each unit the swing can cut through
var _passed: Array[bool] = []
var _on_pass: Callable
var _last_head_x := 0.0

var _age := 0.0
var _impacted := false
var _swept := false
var _axe_pos := Vector2.ZERO
var _axe_rot := 0.0
var _axe_scale := 1.0
var _axe_alpha := 0.0
var _motes: Array[Dictionary] = []
var _shards: Array[Dictionary] = []
var _trail: Array[Vector2] = []
var _ring_age := -1.0
var _glow: Node2D


## Plays Rimecleaver on `target` (its sprite), drawn on `host`.
## `sweep_radius` is the cleave's radius in px (0 = no cleave).
static func play(host: Node, target: Control, sweep_radius: float,
		on_impact: Callable = Callable(), on_sweep: Callable = Callable(),
		pass_nodes: Array = [], on_pass: Callable = Callable(), on_finished: Callable = Callable()) -> void:
	var fx := RimecleaverFX.new()
	var top := target.global_position + Vector2(target.size.x * 0.5, 0.0)
	fx._h = clampf(target.size.y * 1.15, 80.0, 260.0)
	# where the axe HEAD sits at the moment of impact: the blade's edge,
	# about 0.5 * _h below it, bites into the target's upper body
	fx._impact = top + Vector2(0.0, target.size.y * 0.08)
	fx._hover = top - Vector2(fx._h * 0.1, fx._h * 0.95)
	fx._ground = top + Vector2(0.0, target.size.y * 0.95)
	fx._sweep_center = top + Vector2(0.0, target.size.y * 0.55)
	fx._sweep_radius = sweep_radius
	if sweep_radius > 0.0:
		# long enough that the widest swing reaches the edge of the radius
		# without the arm going near-horizontal
		fx._arm = maxf(sweep_radius * 1.3, fx._h * 1.6)
		fx._swing_amp = asin(clampf(sweep_radius / fx._arm, 0.0, 0.95))
		fx._pivot = fx._sweep_center - Vector2(0.0, fx._arm)
	fx._on_impact = on_impact
	fx._on_sweep = on_sweep
	fx._on_finished = on_finished
	fx._on_pass = on_pass
	# kept index-for-index with the caller's list; a unit already gone is never "passed"
	for n in pass_nodes:
		var ok: bool = is_instance_valid(n) and n is Control
		fx._pass_x.append(n.global_position.x + n.size.x * 0.5 if ok else INF)
		fx._passed.append(false)
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	_glow = Node2D.new()
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = m
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	for i in MOTES:
		var a := randf() * TAU
		_motes.append({"dir": Vector2.from_angle(a), "dist": randf_range(0.9, 1.7) * _h, "delay": randf() * 0.35, "size": randf_range(1.5, 3.2)})
	_axe_pos = _hover


func _process(delta: float) -> void:
	_age += delta
	var t_fall := FORM_TIME + HOVER_TIME
	var t_hit := t_fall + FALL_TIME
	var t_after := t_hit + STUCK_TIME
	var sweeping := _sweep_radius > 0.0
	var t_sweep := t_after + LIFT_TIME
	var t_shatter := t_sweep + SWEEP_TIME if sweeping else t_after
	var t_end := t_shatter + SHATTER_TIME

	if _age < FORM_TIME:
		var u := _age / FORM_TIME
		_axe_alpha = smoothstep(0.25, 1.0, u)
		_axe_scale = lerpf(0.55, 1.0, _ease_out(u))
		_axe_rot = lerpf(RAISED_ROT, WINDUP_ROT, smoothstep(0.55, 1.0, u))   # drawn back, winding up
		_axe_pos = _hover
	elif _age < t_fall:
		_axe_alpha = 1.0
		_axe_scale = 1.0
		_axe_rot = WINDUP_ROT
		_axe_pos = _hover + Vector2(sin(_age * 70.0) * 1.2, 0.0)   # straining to fall
	elif _age < t_hit:
		var u := (_age - t_fall) / FALL_TIME
		var e := u * u   # accelerating
		# the head arcs down onto the target as the axe turns edge-down
		_axe_pos = _hover.lerp(_impact, e) + Vector2(sin(e * PI) * _h * 0.35, 0.0)
		_axe_rot = lerpf(WINDUP_ROT, 0.0, e)
	elif not _impacted:
		_impacted = true
		_axe_pos = _impact
		_axe_rot = 0.0
		_burst(_impact + Vector2(0.0, _h * 0.5), 22, 1.0)
		_ring_age = 0.0
		if _on_impact.is_valid():
			_on_impact.call()
	elif sweeping and _age < t_sweep and _age >= t_after:
		# wrench free and turn flat for the swing
		var u := (_age - t_after) / LIFT_TIME
		var start := _swing_point(0.0)
		_axe_pos = _impact.lerp(start, _ease_out(u))
		_last_head_x = _axe_pos.x
		_axe_rot = lerp_angle(0.0, _swing_rot(0.0), _ease_out(u))
	elif sweeping and _age >= t_sweep and _age < t_shatter:
		var u := (_age - t_sweep) / SWEEP_TIME
		var theta := _swing_angle(u)
		_axe_pos = _swing_point(theta)
		_axe_rot = _swing_rot(theta)
		_trail.append(_axe_pos)
		for k in _pass_x.size():
			if not _passed[k] and (_last_head_x - _pass_x[k]) * (_axe_pos.x - _pass_x[k]) <= 0.0:
				_passed[k] = true
				if _on_pass.is_valid():
					_on_pass.call(k)
		_last_head_x = _axe_pos.x
		if _trail.size() > TRAIL_POINTS:
			_trail.remove_at(0)
	elif sweeping and _age >= t_shatter and not _swept:
		_swept = true
		if _on_sweep.is_valid():
			_on_sweep.call()
	elif _age >= t_shatter and _age < t_end:
		if _axe_alpha > 0.0 and not _shards.any(func(s): return s.get("axe", false)):
			_shatter_axe()
		_axe_alpha = 0.0
	elif _age >= t_end and _shards.is_empty():
		if not _swept and sweeping and _on_sweep.is_valid():
			_on_sweep.call()
		if _on_finished.is_valid():
			_on_finished.call()
		queue_free()
		return

	if _ring_age >= 0.0:
		_ring_age += delta
	# the swing's trail fades away once it's done
	if _age >= t_shatter and not _trail.is_empty():
		_trail.remove_at(0)

	for s in _shards:
		s.age += delta
		s.vel.y += 520.0 * delta
		s.pos += s.vel * delta
		s.rot += s.spin * delta
	_shards = _shards.filter(func(s): return s.age < s.life)

	queue_redraw()
	_glow.queue_redraw()


## The pendulum's angle from straight down, `u` = 0..1 through the swing:
## out to the right first, then back and forth, losing a little each pass.
func _swing_angle(u: float) -> float:
	return _swing_amp * sin(u * TAU * SWING_PERIODS) * (1.0 - SWING_DAMPING * u)


func _swing_point(theta: float) -> Vector2:
	return _pivot + Vector2(sin(theta), cos(theta)) * _arm


## Haft (local -x) pointing up the chain at the pivot, blade across it.
func _swing_rot(theta: float) -> float:
	return (_swing_point(theta) - _pivot).angle()


func _ease_out(u: float) -> float:
	return 1.0 - (1.0 - u) * (1.0 - u)


func _ease_in_out(u: float) -> float:
	return u * u * (3.0 - 2.0 * u)


# --- shards -----------------------------------------------------------

func _burst(at: Vector2, count: int, power: float) -> void:
	for i in count:
		var a := randf_range(-PI, 0.0) + randf_range(-0.3, 0.3)   # mostly upward
		_shards.append({
			"pos": at, "vel": Vector2.from_angle(a) * randf_range(120.0, 340.0) * power,
			"rot": randf() * TAU, "spin": randf_range(-14.0, 14.0),
			"size": randf_range(3.0, 7.0) * (_h / 100.0 + 0.4), "age": 0.0, "life": randf_range(0.45, 0.8),
			"bright": randf() < 0.5,
		})


func _shatter_axe() -> void:
	var xf := Transform2D(_axe_rot, Vector2.ONE * _axe_scale, 0.0, _axe_pos)
	for i in 26:
		var local := Vector2(randf_range(-1.0, 0.25) * _h, randf_range(-0.45, 0.45) * _h)
		_shards.append({
			"pos": xf * local, "vel": Vector2(randf_range(-90, 90), randf_range(-160, -20)),
			"rot": randf() * TAU, "spin": randf_range(-10.0, 10.0),
			"size": randf_range(4.0, 9.0) * (_h / 100.0 + 0.4), "age": 0.0, "life": randf_range(0.35, 0.6), "axe": true,
			"bright": randf() < 0.5,
		})


# --- drawing ----------------------------------------------------------

## The axe in its own space: the head at the origin, the haft running
## left along -x to the grip, and a bearded blade on each side of the
## head - "blade" is the one below (+y, its curved cutting edge at the
## bottom, so rotation 0 is the moment of a downward chop); the one above
## is drawn as its mirror image.
func _axe_outline() -> Dictionary:
	var h := _h
	var haft := PackedVector2Array([
		Vector2(-h * 1.0, -h * 0.03), Vector2(h * 0.1, -h * 0.035),
		Vector2(h * 0.1, h * 0.035), Vector2(-h * 1.0, h * 0.03)])
	var pommel := PackedVector2Array([
		Vector2(-h * 0.98, -h * 0.06), Vector2(-h * 1.12, 0.0), Vector2(-h * 0.98, h * 0.06)])
	var blade := PackedVector2Array()
	blade.append(Vector2(h * 0.12, h * 0.02))      # front, where it meets the haft
	blade.append(Vector2(h * 0.2, h * 0.26))       # front of the edge
	# the cutting edge: a curve bulging downward, front to back
	var a := Vector2(h * 0.22, h * 0.3)
	var c := Vector2(h * 0.02, h * 0.56)
	var b := Vector2(-h * 0.3, h * 0.36)
	for k in 11:
		var t := float(k) / 10.0
		blade.append(a.lerp(c, t).lerp(c.lerp(b, t), t))
	blade.append(Vector2(-h * 0.24, h * 0.24))     # the beard, hooking back towards the haft
	blade.append(Vector2(-h * 0.12, h * 0.12))
	blade.append(Vector2(-h * 0.1, h * 0.02))
	# a jagged ice spike crowning the head, past the end of the haft
	var spike := PackedVector2Array([
		Vector2(h * 0.09, -h * 0.05), Vector2(h * 0.17, -h * 0.02), Vector2(h * 0.26, 0.0),
		Vector2(h * 0.17, h * 0.02), Vector2(h * 0.09, h * 0.05)])
	return {"blade": blade, "haft": haft, "pommel": pommel, "spike": spike}


func _draw() -> void:
	# frost trail of the swing
	if _trail.size() > 1:
		for i in range(1, _trail.size()):
			var f := float(i) / _trail.size()
			draw_line(_trail[i - 1], _trail[i], Color(RIM, 0.55 * f), maxf(1.0, 7.0 * f), true)

	if _axe_alpha > 0.0:
		var o := _axe_outline()
		# the frozen chain it hangs from, while it swings
		var lift_at := FORM_TIME + HOVER_TIME + FALL_TIME + STUCK_TIME
		if _sweep_radius > 0.0 and _age > lift_at and _age < _shatter_at():
			var grip := _axe_pos - Vector2.from_angle(_axe_rot) * _h * 1.1 * _axe_scale
			_draw_chain(_pivot, grip, _axe_alpha * clampf((_age - lift_at) / LIFT_TIME, 0.0, 1.0))
		var a := _axe_alpha
		draw_set_transform(_axe_pos, _axe_rot, Vector2.ONE * _axe_scale)
		draw_colored_polygon(o.haft, Color(ICE_DEEP, 0.9 * a))
		draw_line(Vector2(-_h * 0.98, -_h * 0.012), Vector2(_h * 0.08, -_h * 0.015), Color(RIM, 0.45 * a), 1.2, true)
		draw_colored_polygon(o.pommel, Color(ICE, 0.9 * a))
		draw_colored_polygon(o.spike, Color(ICE, 0.85 * a))
		# the two blades: the one below, then its mirror image above
		for side in [1.0, -1.0]:
			draw_set_transform(_axe_pos, _axe_rot, Vector2(_axe_scale, _axe_scale * side))
			draw_colored_polygon(o.blade, Color(ICE, 0.8 * a))
			# a deeper core inside the blade, and bright facets
			var core := PackedVector2Array()
			var centre := Vector2(-_h * 0.03, _h * 0.24)
			for p in o.blade:
				core.append(centre + (p - centre) * 0.58)
			draw_colored_polygon(core, Color(ICE_DEEP, 0.45 * a))
			var closed: PackedVector2Array = o.blade.duplicate()
			closed.append(o.blade[0])
			draw_polyline(closed, Color(RIM, a), 2.0, true)
			# the bright cutting edge
			draw_polyline(o.blade.slice(2, 13), Color(Color.WHITE, 0.9 * a), 3.0, true)
			draw_line(Vector2(-_h * 0.08, _h * 0.1), Vector2(_h * 0.06, _h * 0.4), Color(RIM, 0.55 * a), 1.4, true)
			draw_line(Vector2(_h * 0.05, _h * 0.06), Vector2(_h * 0.16, _h * 0.26), Color(RIM, 0.45 * a), 1.2, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for s in _shards:
		var k: float = 1.0 - s.age / s.life
		var r: float = s.size
		var tri := PackedVector2Array([
			s.pos + Vector2.from_angle(s.rot) * r,
			s.pos + Vector2.from_angle(s.rot + 2.3) * r * 0.6,
			s.pos + Vector2.from_angle(s.rot - 2.3) * r * 0.6])
		draw_colored_polygon(tri, Color(RIM if s.bright else ICE, k))


func _shatter_at() -> float:
	var t := FORM_TIME + HOVER_TIME + FALL_TIME + STUCK_TIME
	return t + LIFT_TIME + SWEEP_TIME if _sweep_radius > 0.0 else t


## A chain of ice links from the pivot down to the axe's grip, the links
## fading out towards the top as if it hangs from the frozen air.
func _draw_chain(from: Vector2, to: Vector2, alpha: float) -> void:
	var length := from.distance_to(to)
	var dir := (to - from) / maxf(length, 1.0)
	var link := clampf(_h * 0.09, 7.0, 16.0)
	var n := int(length / link)
	for k in n:
		var t := (k + 0.5) / float(n)
		var p := from + dir * length * t
		var fade := smoothstep(0.0, 0.25, t) * alpha
		var r := Vector2(link * 0.55, link * 0.28) if k % 2 == 0 else Vector2(link * 0.18, link * 0.5)
		var pts := PackedVector2Array()
		for i in 13:
			var a := TAU * i / 12.0
			pts.append(p + (dir * cos(a) * r.x + dir.orthogonal() * sin(a) * r.y))
		draw_polyline(pts, Color(RIM, 0.95 * fade), 2.6, true)


func _draw_glow() -> void:
	var lift_at := FORM_TIME + HOVER_TIME + FALL_TIME + STUCK_TIME
	if _sweep_radius > 0.0 and _axe_alpha > 0.0 and _age > lift_at and _age < _shatter_at():
		var grip := _axe_pos - Vector2.from_angle(_axe_rot) * _h * 1.1 * _axe_scale
		var k := clampf((_age - lift_at) / LIFT_TIME, 0.0, 1.0) * _axe_alpha
		var mid := _pivot.lerp(grip, 0.25)
		_glow.draw_line(mid, grip, Color(GLOW, 0.22 * k), 9.0, true)
		_glow.draw_line(_pivot, mid, Color(GLOW, 0.08 * k), 7.0, true)
	# motes gathering into the axe while it forms
	if _age < FORM_TIME:
		for m in _motes:
			var u := clampf((_age - m.delay) / (FORM_TIME - m.delay), 0.0, 1.0)
			if u <= 0.0 or u >= 1.0:
				continue
			var p: Vector2 = _hover + m.dir * m.dist * (1.0 - _ease_out(u))
			_glow.draw_circle(p, m.size * 2.2, Color(GLOW, 0.25 * (1.0 - u * 0.5)))
			_glow.draw_circle(p, m.size, Color(RIM, 0.9))
	# cold halo around the axe while it forms and hangs there - it would
	# only wash over the target once the blade has landed
	if _axe_alpha > 0.0 and not _impacted:
		var c := _axe_pos
		for i in 3:
			_glow.draw_circle(c, _h * (0.2 + i * 0.1) * _axe_scale, Color(GLOW, 0.06 * _axe_alpha))
	# impact flash and the frost ring rolling out across the ground
	if _ring_age >= 0.0 and _ring_age < 0.6:
		var u := _ring_age / 0.6
		var ground := _ground
		var reach := maxf(_sweep_radius, _h * 0.7)
		var rx := lerpf(_h * 0.15, reach, _ease_out(u))
		_glow_ellipse(ground, Vector2(rx, rx * SWEEP_FLATTEN), Color(RIM, 0.8 * (1.0 - u)), 3.0)
		if _ring_age < 0.12:
			_glow.draw_circle(_impact + Vector2(0.0, _h * 0.5), _h * 0.28, Color(RIM, 0.35 * (1.0 - _ring_age / 0.12)))


func _glow_ellipse(c: Vector2, radii: Vector2, col: Color, width: float) -> void:
	var pts := PackedVector2Array()
	for i in 41:
		var a := TAU * i / 40.0
		pts.append(c + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	_glow.draw_polyline(pts, col, width, true)
