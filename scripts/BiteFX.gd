class_name BiteFX
extends Node2D

## Purely cosmetic: The Primordial Hunger's normal attack - a spectral echo
## of the maw that splits its own body, biting the target. Like the one on
## its art, the mouth stands upright: two jaws, left and right, lined with
## long curved ivory tusks that sweep upward, longest in the middle. The
## maw materializes over the target, sliding in from the attacker's side
## as it gapes open, then snaps shut sideways - tusks interlocking - with a
## flash of cold light, a spray of ice shards and a few dark drops, holds a
## moment with a shudder, and fades as it slackens.
##
## A hero uses it by naming it in its GameManager definition
## ("attack_effect": "bite") - see battle.gd's _play_hero_attack_effect().

const OPEN_TIME := 0.16
const SNAP_TIME := 0.06
const HOLD_TIME := 0.12
const FADE_TIME := 0.26

# How far apart the two tooth lines are at the middle of the mouth, as a
# share of its length: slightly open as it appears, wide at the top of the
# gape, and a little PAST closed on the snap so the tusks overlap.
const GAP_START := 0.15
const GAP_WIDE := 0.8
const GAP_SHUT := -0.06
const GAP_SLACK := 0.12

# Tusks per jaw - the right jaw's sit between the left jaw's.
const LEFT_TEETH := 7
const RIGHT_TEETH := 6
# How much of the mouth's length the tusks cover, end to end (of 2).
const TEETH_SPAN := 1.76

const IVORY := Color(0.96, 0.95, 0.9)
const IVORY_ROOT := Color(0.42, 0.38, 0.36)
const GUM := Color(0.06, 0.07, 0.14)
const RIM := Color(0.6, 0.85, 1.0)
const GLOW := Color(0.45, 0.72, 1.0)
const BLOOD := Color(0.45, 0.04, 0.06)

var _to: Vector2
var _dir := 1.0            # +1 when the attacker is to the target's left
var _length := 120.0       # the mouth's height, top corner to bottom
var _on_hit: Callable
var _age := 0.0
var _hit_done := false
var _glow: Node2D
var _body: Node2D


## Bites `target` (a battle sprite) for an attacker at `from` (a global
## position - only its side matters). `on_hit` fires the moment the jaws
## snap shut.
static func play(host: Node, from: Vector2, target: Control, on_hit: Callable = Callable()) -> void:
	var fx := BiteFX.new()
	fx._to = target.global_position + target.size * Vector2(0.5, 0.45)
	fx._dir = 1.0 if fx._to.x >= from.x else -1.0
	fx._length = clampf(target.size.y * 0.62, 80.0, 170.0)
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	# Added after the glow, so the jaws draw on top of it.
	_body = Node2D.new()
	_body.draw.connect(_draw_jaws)
	add_child(_body)


func _process(delta: float) -> void:
	_age += delta
	if not _hit_done and _age >= OPEN_TIME + SNAP_TIME:
		_hit_done = true
		_burst()
		if _on_hit.is_valid():
			_on_hit.call()
	if _age >= OPEN_TIME + SNAP_TIME + HOLD_TIME + FADE_TIME:
		queue_free()
		return
	_glow.queue_redraw()
	_body.queue_redraw()


## Jaw separation right now, as a share of the length (see GAP_*).
func _gap() -> float:
	if _age < OPEN_TIME:
		var k := _age / OPEN_TIME
		return lerpf(GAP_START, GAP_WIDE, 1.0 - (1.0 - k) * (1.0 - k))
	if _age < OPEN_TIME + SNAP_TIME:
		var k := (_age - OPEN_TIME) / SNAP_TIME
		return lerpf(GAP_WIDE, GAP_SHUT, k * k)
	if _age < OPEN_TIME + SNAP_TIME + HOLD_TIME:
		return GAP_SHUT
	var k := clampf((_age - OPEN_TIME - SNAP_TIME - HOLD_TIME) / FADE_TIME, 0.0, 1.0)
	return lerpf(GAP_SHUT, GAP_SLACK, k)


## Overall opacity: a quick fade in, then out as the jaws slacken.
func _alpha() -> float:
	var fade_start := OPEN_TIME + SNAP_TIME + HOLD_TIME
	if _age >= fade_start:
		return 1.0 - clampf((_age - fade_start) / FADE_TIME, 0.0, 1.0)
	return clampf(_age / 0.08, 0.0, 1.0)


## Where the maw is centred: sliding in from the attacker's side while it
## opens, then clamped on the target with a shudder that dies away.
func _center() -> Vector2:
	var c := _to
	if _age < OPEN_TIME:
		var k := _age / OPEN_TIME
		c.x -= _dir * _length * 0.45 * (1.0 - k) * (1.0 - k)
	var since_snap := _age - OPEN_TIME - SNAP_TIME
	if since_snap > 0.0:
		var shake := 3.0 * (1.0 - clampf(since_snap / (HOLD_TIME + 0.1), 0.0, 1.0))
		c += Vector2(sin(_age * 90.0), cos(_age * 70.0)) * shake
	return c


## Size multiplier: grows as it opens, squeezes on the bite, then settles.
func _scale() -> float:
	if _age < OPEN_TIME:
		return lerpf(0.8, 1.0, _age / OPEN_TIME)
	if _age < OPEN_TIME + SNAP_TIME:
		return lerpf(1.0, 0.92, (_age - OPEN_TIME) / SNAP_TIME)
	return lerpf(0.92, 1.0, clampf((_age - OPEN_TIME - SNAP_TIME) / HOLD_TIME, 0.0, 1.0))


## The line a jaw's tusks grow from, at `v` (-1 = top corner, 1 = bottom),
## for the left (`side` -1) or right (`side` +1) jaw - an arch that's
## widest in the middle of the mouth and meets at the corners.
func _tooth_line(v: float, side: float, gap: float) -> Vector2:
	return Vector2(side * gap * _length * 0.5 * (1.0 - 0.45 * v * v), v * _length * 0.5)


func _set_transform(node: Node2D) -> void:
	# Leaning a little into the bite, away from the attacker.
	node.draw_set_transform(_center(), _dir * 0.08, Vector2.ONE * _scale())


func _draw_jaws() -> void:
	var a := _alpha()
	if a <= 0.0:
		return
	_set_transform(_body)
	var gap := _gap()
	for side in [-1.0, 1.0]:
		_draw_gum(side, gap, a)
	for side in [-1.0, 1.0]:
		_draw_tusks(side, gap, a)


## One jaw's gum: a dark band arching away from its tooth line, tapering
## at the corners, with a cold rim along its outer edge.
func _draw_gum(side: float, gap: float, a: float) -> void:
	var inner := PackedVector2Array()
	var outer := PackedVector2Array()
	for i in 17:
		var v := -1.0 + 2.0 * float(i) / 16.0
		var p := _tooth_line(v, side, gap)
		inner.append(p)
		outer.append(p + Vector2(side * _length * 0.08 * (1.0 - 0.8 * pow(v, 4.0)), 0.0))
	var band := inner.duplicate()
	for i in range(outer.size() - 1, -1, -1):
		band.append(outer[i])
	_body.draw_colored_polygon(band, Color(GUM, 0.75 * a))
	_body.draw_polyline(outer, Color(RIM, 0.7 * a), 2.0, true)


## One jaw's tusks, reaching across for the other jaw and sweeping upward
## at the tips, like the ones down the Hunger's body: longest just above
## the middle of the mouth, shorter toward the corners.
func _draw_tusks(side: float, gap: float, a: float) -> void:
	var count := LEFT_TEETH if side < 0.0 else RIGHT_TEETH
	var spacing := TEETH_SPAN / float(LEFT_TEETH - 1)
	var half_w := spacing * _length * 0.5 * 0.26
	for i in count:
		var v := -TEETH_SPAN * 0.5 + spacing * (float(i) + (0.0 if side < 0.0 else 0.5))
		var base := _tooth_line(v, side, gap)
		var length := _length * 0.16 * (0.55 + 1.3 * exp(-pow((v + 0.15) / 0.55, 2.0)))
		_draw_tusk(base, -side, length, half_w, a)


## A single curved tusk from `base`, reaching in direction `reach` (+1 =
## right, -1 = left) for `length`, its tip hooked upward: a dark root
## fading into ivory, a lit ridge along it, and a cold rim.
func _draw_tusk(base: Vector2, reach: float, length: float, half_w: float, a: float) -> void:
	# Quadratic curve: out across the mouth, dipping slightly, then sweeping up.
	var ctrl := base + Vector2(reach * length * 0.7, length * 0.12)
	var tip := base + Vector2(reach * length * 0.95, -length * 0.62)
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var ridge := PackedVector2Array()
	var steps := 8
	for s in steps + 1:
		var t := float(s) / steps
		var p := base.lerp(ctrl, t).lerp(ctrl.lerp(tip, t), t)
		var tangent := (ctrl - base).lerp(tip - ctrl, t).normalized()
		var n := tangent.orthogonal()
		var w := half_w * pow(1.0 - t, 0.8)
		left.append(p + n * w)
		right.append(p - n * w)
		ridge.append(p + n * w * 0.35)
	var outline := left.duplicate()
	for s in range(right.size() - 1, -1, -1):
		outline.append(right[s])
	_body.draw_colored_polygon(outline, Color(IVORY_ROOT.lerp(IVORY, 0.7), a))
	# Ivory lit face over most of its length, leaving the root darker.
	var lit := PackedVector2Array()
	for s in range(2, left.size()):
		lit.append(left[s])
	for s in range(ridge.size() - 1, 1, -1):
		lit.append(ridge[s])
	if lit.size() >= 3:
		_body.draw_colored_polygon(lit, Color(IVORY, a))
	# The root, where it grows from the gum.
	_body.draw_circle(base, half_w * 0.9, Color(IVORY_ROOT, a))
	outline.append(outline[0])
	_body.draw_polyline(outline, Color(RIM, 0.45 * a), 1.0, true)


## A cold aura around the jaws, and a flash of light when they snap shut.
func _draw_glow() -> void:
	var a := _alpha()
	if a <= 0.0:
		return
	_set_transform(_glow)
	var gap := _gap()
	for side in [-1.0, 1.0]:
		var pts := PackedVector2Array()
		for i in 13:
			var v := -1.0 + 2.0 * float(i) / 12.0
			pts.append(_tooth_line(v, side, gap) + Vector2(side * _length * 0.05, 0.0))
		_glow.draw_polyline(pts, Color(GLOW, 0.22 * a), 14.0, true)
	if _hit_done:
		var f := 1.0 - clampf((_age - OPEN_TIME - SNAP_TIME) / 0.28, 0.0, 1.0)
		if f > 0.0:
			_glow.draw_circle(Vector2.ZERO, _length * 0.35, Color(GLOW, 0.35 * f))
			_glow.draw_arc(Vector2.ZERO, _length * (0.3 + 0.45 * (1.0 - f)), 0.0, TAU, 40, Color(RIM, 0.8 * f), 3.0, true)


## Ice shards and a few dark drops, flung out from the bite.
func _burst() -> void:
	var host := get_parent()
	if host == null:
		return
	for pass_i in 2:
		var p := CPUParticles2D.new()
		p.one_shot = true
		p.explosiveness = 0.95
		p.amount = 20 if pass_i == 0 else 6
		p.lifetime = 0.45 if pass_i == 0 else 0.6
		p.spread = 180.0
		p.gravity = Vector2(0, 30) if pass_i == 0 else Vector2(0, 380)
		p.initial_velocity_min = 60.0 if pass_i == 0 else 90.0
		p.initial_velocity_max = 170.0 if pass_i == 0 else 200.0
		p.damping_min = 80.0 if pass_i == 0 else 0.0
		p.damping_max = 160.0 if pass_i == 0 else 0.0
		p.scale_amount_min = 1.2 if pass_i == 0 else 0.7
		p.scale_amount_max = 2.6 if pass_i == 0 else 1.3
		p.texture = VoidReachFX._dot()
		p.color = RIM if pass_i == 0 else BLOOD
		if pass_i == 0:
			p.material = VoidReachFX._additive()
		host.add_child(p)
		p.global_position = _to
		p.emitting = true
		p.finished.connect(p.queue_free)
