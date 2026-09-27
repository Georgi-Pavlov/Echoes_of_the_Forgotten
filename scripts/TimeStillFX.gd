class_name TimeStillFX
extends Node2D

## Purely cosmetic: The Primordial Hunger's The Test of Time.
##
## The unit rises slowly into the air and hangs there, gently bobbing,
## a soft shadow left on the ground beneath it, inside a column of wind
## spiralling up from the ground to the sky. It fades, half there, and an
## ancient frost clock appears over it: an icy rim with twelve tick marks, the second
## hand ticking round in steps (each tick sending a faint pulse through
## the rim), the minute hand creeping. A glowing arc round the rim shows
## the turns it has left, shrinking - with a chime of light - as each one
## passes (set_turns()). When it ends (finish()) the hands spin wildly,
## the clock bursts into frost motes, the wind dies down, and the unit
## settles back down and fades back in.
##
## Lives as a child of the unit's sprite, so it follows it; the lift is
## applied to the sprite's own position, as an offset on top of wherever
## the battle puts it.

const NODE_NAME := "TimeStill"

const RISE_TIME := 0.6
const SETTLE_TIME := 0.4
const LIFT := 0.12              # of the unit's height
const BOB := 4.0                # px
const APPEAR_TIME := 0.35
const TICK_EVERY := 1.0         # s
const TICK_STEP := TAU / 12.0   # the second hand's jump per tick
# How faded the unit is while held, and how quickly it fades.
const FADE_ALPHA := 0.5
const FADE_TIME := 0.4
# The wind column's width, as a share of the unit's.
const WIND_WIDTH := 0.6

const WIND_SHADER := preload("res://shaders/wind_column.gdshader")

const FACE := Color(0.04, 0.06, 0.14, 0.78)
const RIM := Color(0.75, 0.9, 1.0)
const GLOW := Color(0.45, 0.65, 1.0)
const TIME_ARC := Color(0.6, 0.95, 1.0)

var _unit: Control
var _total := 1
var _remaining := 1
var _age := 0.0
var _lift := 0.0            # px currently applied to the unit's position
var _finishing := false
var _finish_age := 0.0
var _chime := 0.0
var _clock: Node2D
var _clock_glow: Node2D
var _shadow: Node2D
var _motes: CPUParticles2D
var _wind: ColorRect
var _wind_mat: ShaderMaterial
var _gusts: CPUParticles2D


## Starts The Test of Time's look on `unit` (a battle sprite), for
## `turns` turns. Replaces one already running on it.
static func begin(unit: Control, turns: int) -> TimeStillFX:
	var existing := of(unit)
	if existing != null:
		existing._total = maxi(turns, 1)
		existing._remaining = existing._total
		existing._chime = 1.0
		return existing
	var fx := TimeStillFX.new()
	fx.name = NODE_NAME
	fx._unit = unit
	fx._total = maxi(turns, 1)
	fx._remaining = fx._total
	unit.add_child(fx)
	return fx


static func of(unit: Variant) -> TimeStillFX:
	if not is_instance_valid(unit) or not (unit is Node):
		return null
	var fx := unit.get_node_or_null(NODE_NAME) as TimeStillFX
	return null if fx == null or fx._finishing else fx


## `remaining` turns left - the arc shrinks to match, with a chime.
func set_turns(remaining: int) -> void:
	_remaining = clampi(remaining, 0, _total)
	_chime = 1.0


## Time runs out: the clock bursts and the unit settles back down.
func finish() -> void:
	if _finishing:
		return
	_finishing = true
	# Out of the way of a fresh one, should it be recast while this settles.
	name = NODE_NAME + "Ending"
	_finish_age = 0.0
	_motes.emitting = false
	_gusts.emitting = false
	if is_instance_valid(_unit):
		_unit.create_tween().tween_property(_unit, "self_modulate:a", 1.0, FADE_TIME)
	var burst := CPUParticles2D.new()
	burst.position = _clock.position
	burst.amount = 30
	burst.lifetime = 0.8
	burst.one_shot = true
	burst.explosiveness = 0.9
	burst.spread = 180.0
	burst.initial_velocity_min = 40.0
	burst.initial_velocity_max = 110.0
	burst.damping_min = 60.0
	burst.damping_max = 120.0
	burst.texture = VoidReachFX._dot()
	burst.scale_amount_min = 0.5
	burst.scale_amount_max = 1.1
	burst.material = VoidReachFX._additive()
	burst.color_ramp = _ramp()
	add_child(burst)
	burst.emitting = true


func _ready() -> void:
	# The wind column, from the sky down to the ground, behind the unit's art.
	_wind_mat = ShaderMaterial.new()
	_wind_mat.shader = WIND_SHADER
	_wind = ColorRect.new()
	_wind.material = _wind_mat
	_wind.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wind.show_behind_parent = true
	add_child(_wind)
	# The shadow on the ground, behind the unit's art.
	_shadow = Node2D.new()
	_shadow.show_behind_parent = true
	_shadow.draw.connect(_draw_shadow)
	add_child(_shadow)
	# Frost swept up the column in front of the unit.
	_gusts = CPUParticles2D.new()
	_gusts.amount = 26
	_gusts.lifetime = 1.4
	_gusts.texture = VoidReachFX._dot()
	_gusts.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_gusts.emission_rect_extents = Vector2(_unit.size.x * WIND_WIDTH * 0.4, 6.0)
	_gusts.position = Vector2(_unit.size.x * 0.5, _unit.size.y)
	_gusts.direction = Vector2(0.0, -1.0)
	_gusts.spread = 12.0
	_gusts.gravity = Vector2(0.0, -60.0)
	_gusts.initial_velocity_min = 90.0
	_gusts.initial_velocity_max = 170.0
	_gusts.tangential_accel_min = -40.0
	_gusts.tangential_accel_max = 40.0
	_gusts.scale_amount_min = 0.4
	_gusts.scale_amount_max = 0.9
	_gusts.material = VoidReachFX._additive()
	_gusts.color_ramp = _ramp()
	add_child(_gusts)
	_gusts.emitting = true
	_clock_glow = Node2D.new()
	_clock_glow.material = VoidReachFX._additive()
	_clock_glow.draw.connect(_draw_clock_glow)
	add_child(_clock_glow)
	_clock = Node2D.new()
	_clock.draw.connect(_draw_clock)
	add_child(_clock)

	_motes = CPUParticles2D.new()
	_motes.amount = 10
	_motes.lifetime = 1.8
	_motes.texture = VoidReachFX._dot()
	_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	_motes.emission_sphere_radius = _radius() * 1.2
	_motes.gravity = Vector2(0.0, 10.0)
	_motes.initial_velocity_min = 2.0
	_motes.initial_velocity_max = 8.0
	_motes.spread = 180.0
	_motes.scale_amount_min = 0.35
	_motes.scale_amount_max = 0.7
	_motes.material = VoidReachFX._additive()
	_motes.color_ramp = _ramp()
	_clock.add_child(_motes)
	_motes.emitting = true

	# Fades, half there, so the clock over it reads clearly. Only its own
	# art (self_modulate) - not the clock and wind, its children.
	_unit.create_tween().tween_property(_unit, "self_modulate:a", FADE_ALPHA, FADE_TIME)


func _radius() -> float:
	return clampf(minf(_unit.size.x, _unit.size.y) * 0.2, 26.0, 64.0) if is_instance_valid(_unit) else 40.0


func _process(delta: float) -> void:
	_age += delta
	if not is_instance_valid(_unit):
		queue_free()
		return
	var target_lift: float
	if _finishing:
		_finish_age += delta
		var k := clampf(_finish_age / SETTLE_TIME, 0.0, 1.0)
		target_lift = lerpf(_lift_at(_age), 0.0, k * k)
	else:
		target_lift = _lift_at(_age)
	# Applied as a change on top of wherever the battle has the unit.
	_unit.position.y -= target_lift - _lift
	_lift = target_lift
	if _finishing and _finish_age >= maxf(SETTLE_TIME, 0.8):
		_unit.position.y += _lift
		_lift = 0.0
		queue_free()
		return

	_chime = move_toward(_chime, 0.0, delta * 1.5)
	# Over the middle of its art.
	_clock.position = Vector2(_unit.size.x * 0.5, _unit.size.y * 0.45)
	_layout_wind()
	_clock_glow.position = _clock.position
	var appear := clampf(_age / APPEAR_TIME, 0.0, 1.0)
	var s := 1.0 + 2.70158 * pow(appear - 1.0, 3.0) + 1.70158 * pow(appear - 1.0, 2.0)
	if _finishing:
		var f := clampf(_finish_age / 0.3, 0.0, 1.0)
		s *= 1.0 + 0.4 * f
		_clock.modulate.a = 1.0 - f
		_clock_glow.modulate.a = 1.0 - f
	_clock.scale = Vector2.ONE * maxf(s, 0.0)
	_clock_glow.scale = _clock.scale
	_clock.queue_redraw()
	_clock_glow.queue_redraw()
	_shadow.queue_redraw()


## The wind column: centred on the unit, from the top of the screen down
## to the ground it rose from (so it stays planted as the unit lifts),
## blowing up to full strength as the effect starts and dying away as it
## ends.
func _layout_wind() -> void:
	var w := _unit.size.x * WIND_WIDTH
	var top := -_unit.global_position.y
	var bottom := _unit.size.y + _lift
	_wind.position = Vector2((_unit.size.x - w) * 0.5, top)
	_wind.size = Vector2(w, maxf(bottom - top, 1.0))
	_wind_mat.set_shader_parameter("aspect", w / maxf(_wind.size.y, 1.0))
	var strength := clampf(_age / RISE_TIME, 0.0, 1.0)
	if _finishing:
		strength *= 1.0 - clampf(_finish_age / SETTLE_TIME, 0.0, 1.0)
	_wind_mat.set_shader_parameter("intensity", strength)
	_gusts.position = Vector2(_unit.size.x * 0.5, _unit.size.y + _lift)


## How high the unit hangs at time `t`: rising, then gently bobbing.
func _lift_at(t: float) -> float:
	if not is_instance_valid(_unit):
		return 0.0
	var rise := 1.0 - pow(1.0 - clampf(t / RISE_TIME, 0.0, 1.0), 3.0)
	return (_unit.size.y * LIFT + BOB * sin(t * 1.6)) * rise


## The second hand's angle: a jump of TICK_STEP every TICK_EVERY seconds,
## with a small overshoot as it lands - or a wild spin as time runs out.
func _second_angle() -> float:
	if _finishing:
		return _age * 25.0
	var ticks := floorf(_age / TICK_EVERY)
	var into := fmod(_age, TICK_EVERY) / 0.14
	var step := 1.0
	if into < 1.0:
		step = 1.0 + 2.70158 * pow(into - 1.0, 3.0) + 1.70158 * pow(into - 1.0, 2.0)
	return (ticks - 1.0 + step) * TICK_STEP


## 1 right on a tick, fading to 0 over the next fraction of a second.
func _tick_pulse() -> float:
	return 1.0 - clampf(fmod(_age, TICK_EVERY) / 0.3, 0.0, 1.0)


func _draw_shadow() -> void:
	if not is_instance_valid(_unit):
		return
	var height := _unit.size.y * LIFT
	var k := clampf(_lift / maxf(height, 1.0), 0.0, 1.2)
	var center := Vector2(_unit.size.x * 0.5, _unit.size.y - 6.0 + _lift)
	var w := _unit.size.x * 0.3 * (1.0 - 0.25 * k)
	var pts := PackedVector2Array()
	for i in 25:
		var a := TAU * i / 24.0
		pts.append(center + Vector2(cos(a) * w, sin(a) * w * 0.14))
	_shadow.draw_colored_polygon(pts, Color(0.0, 0.02, 0.08, 0.35 * k))


func _draw_clock() -> void:
	var r := _radius()
	_clock.draw_circle(Vector2.ZERO, r, FACE)
	# Twelve tick marks, the quarters longer.
	for i in 12:
		var a := TAU * i / 12.0 - PI * 0.5
		var d := Vector2.from_angle(a)
		var inner := r * (0.72 if i % 3 == 0 else 0.82)
		_clock.draw_line(d * inner, d * r * 0.92, Color(RIM, 0.85), 2.0 if i % 3 == 0 else 1.0, true)
	# The minute hand creeping, the second hand ticking.
	var minute := _age * TAU / 40.0 - PI * 0.5
	_clock.draw_line(Vector2.ZERO, Vector2.from_angle(minute) * r * 0.55, Color(RIM, 0.9), 2.5, true)
	var second := _second_angle() - PI * 0.5
	_clock.draw_line(-Vector2.from_angle(second) * r * 0.15, Vector2.from_angle(second) * r * 0.8, Color(1, 1, 1, 0.95), 1.4, true)
	_clock.draw_circle(Vector2.ZERO, 2.5, Color(1, 1, 1, 0.95))
	var rim := PackedVector2Array()
	for i in 49:
		rim.append(Vector2.from_angle(TAU * i / 48.0) * r)
	_clock.draw_polyline(rim, Color(RIM, 0.95), 2.0, true)


func _draw_clock_glow() -> void:
	var r := _radius()
	var pulse := _tick_pulse() if not _finishing else 0.0
	_clock_glow.draw_circle(Vector2.ZERO, r * 1.6, Color(GLOW, 0.1 + 0.08 * pulse + 0.25 * _chime))
	var rim := PackedVector2Array()
	for i in 49:
		rim.append(Vector2.from_angle(TAU * i / 48.0) * r * (1.0 + 0.04 * pulse))
	_clock_glow.draw_polyline(rim, Color(RIM, 0.25 + 0.35 * pulse + 0.5 * _chime), 4.0, true)
	# The turns left, as a glowing arc round the rim from the top.
	var frac := float(_remaining) / float(_total)
	if frac > 0.0:
		var arc := PackedVector2Array()
		var steps := maxi(int(48 * frac), 2)
		for i in steps + 1:
			var a := -PI * 0.5 + TAU * frac * float(i) / steps
			arc.append(Vector2.from_angle(a) * r * 1.18)
		_clock_glow.draw_polyline(arc, Color(TIME_ARC, 0.75 + 0.25 * _chime), 3.0, true)


static func _ramp() -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	g.colors = PackedColorArray([Color(0.8, 0.93, 1.0, 0.0), Color(0.8, 0.93, 1.0, 0.9), Color(0.45, 0.65, 1.0, 0.0)])
	return g
