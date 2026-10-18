class_name EclipseBeamFX
extends Node2D

## Purely cosmetic: one beam of Lunara's Eternal Eclipse. A shaft of
## blood-moon light drops from the black sun to the target in a blink,
## cored in white-pink with a crimson glow - it hammers into the target
## in a flash, a ring of shock racing across the ground, a crescent-shaped
## slash of light and a spray of red sparks - then the shaft thins and
## fades while dark crimson petals drift down from the spot.

const DROP_TIME := 0.1
const HOLD_TIME := 0.12
const FADE_TIME := 0.3
const LIFE := DROP_TIME + HOLD_TIME + FADE_TIME + 0.7

const CORONA := Color(1.0, 0.18, 0.28)
const CORE := Color(1.0, 0.88, 0.88)
const DEEP := Color(0.5, 0.04, 0.12)

var _from: Vector2
var _to: Vector2
var _age := 0.0
var _struck := false
var _ground_y := 0.0


## A beam from `from` (the black sun's rim) to `to` (the struck unit's
## chest), the ground running through `ground_y`.
static func strike(host: Node, from: Vector2, to: Vector2, ground_y: float) -> void:
	var fx := EclipseBeamFX.new()
	fx._from = from
	fx._to = to
	fx._ground_y = ground_y
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()


func _process(delta: float) -> void:
	_age += delta
	if not _struck and _age >= DROP_TIME:
		_struck = true
		_impact()
	if _age >= LIFE:
		queue_free()
		return
	queue_redraw()


func _impact() -> void:
	# Red sparks thrown up and out.
	var sparks := CPUParticles2D.new()
	sparks.position = _to
	sparks.one_shot = true
	sparks.amount = 30
	sparks.lifetime = 0.55
	sparks.explosiveness = 0.95
	sparks.texture = VoidReachFX._dot()
	sparks.direction = Vector2(0.0, -1.0)
	sparks.spread = 100.0
	sparks.gravity = Vector2(0.0, 360.0)
	sparks.initial_velocity_min = 90.0
	sparks.initial_velocity_max = 300.0
	sparks.damping_min = 40.0
	sparks.damping_max = 120.0
	sparks.scale_amount_min = 0.9
	sparks.scale_amount_max = 2.0
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(CORE, 1.0), Color(CORONA, 0.85), Color(DEEP, 0.0)])
	sparks.color_ramp = ramp
	sparks.material = VoidReachFX._additive()
	add_child(sparks)
	sparks.emitting = true

	# Dark crimson petals drifting down off the spot.
	var petals := CPUParticles2D.new()
	petals.position = _to + Vector2(0.0, -50.0)
	petals.one_shot = true
	petals.amount = 12
	petals.lifetime = 1.3
	petals.explosiveness = 0.8
	petals.texture = VoidReachFX._dot()
	petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	petals.emission_sphere_radius = 30.0
	petals.direction = Vector2(0.0, -1.0)
	petals.spread = 120.0
	petals.gravity = Vector2(0.0, 70.0)
	petals.initial_velocity_min = 20.0
	petals.initial_velocity_max = 90.0
	petals.damping_min = 40.0
	petals.damping_max = 80.0
	petals.scale_amount_min = 1.6
	petals.scale_amount_max = 3.2
	var pr := Gradient.new()
	pr.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	pr.colors = PackedColorArray([Color(0.7, 0.05, 0.15, 0.0), Color(0.75, 0.06, 0.16, 0.85), Color(0.35, 0.02, 0.08, 0.0)])
	petals.color_ramp = pr
	add_child(petals)
	petals.emitting = true


func _draw() -> void:
	var dir := (_to - _from).normalized()
	var side := dir.orthogonal()
	var reach := (_to - _from).length()
	var drop := clampf(_age / DROP_TIME, 0.0, 1.0)
	var head := _from + dir * reach * (1.0 - pow(1.0 - drop, 2.0))

	# How strong the shaft still is: full through the hold, then thinning.
	var strength := 1.0
	if _age > DROP_TIME + HOLD_TIME:
		strength = 1.0 - clampf((_age - DROP_TIME - HOLD_TIME) / FADE_TIME, 0.0, 1.0)
	if strength > 0.0:
		# Glow, body, core - each a tapering quad, wide at the target.
		_shaft(head, side, 26.0 * strength, Color(CORONA, 0.22 * strength))
		_shaft(head, side, 13.0 * strength, Color(CORONA, 0.5 * strength))
		_shaft(head, side, 5.0 * strength, Color(CORE, 0.95 * strength))
		draw_circle(head, 12.0 * strength + 4.0, Color(CORE, 0.8 * strength))

	if not _struck:
		return
	var t := _age - DROP_TIME
	# The flash where it lands.
	var flash := 1.0 - clampf(t / 0.2, 0.0, 1.0)
	if flash > 0.0:
		draw_circle(_to, 46.0 * (1.3 - 0.3 * flash), Color(CORONA, 0.4 * flash))
		draw_circle(_to, 22.0, Color(CORE, 0.9 * flash))
	# The crescent slash: an arc of light opening upward, flung wide.
	var ck := clampf(t / 0.35, 0.0, 1.0)
	if ck < 1.0:
		var cr := lerpf(18.0, 78.0, 1.0 - pow(1.0 - ck, 2.0))
		draw_arc(_to, cr, deg_to_rad(200.0), deg_to_rad(340.0), 28, Color(CORE, 0.85 * (1.0 - ck)), 7.0 * (1.0 - ck) + 1.0, true)
		draw_arc(_to, cr * 0.86, deg_to_rad(210.0), deg_to_rad(330.0), 24, Color(CORONA, 0.7 * (1.0 - ck)), 4.0 * (1.0 - ck) + 1.0, true)
	# The shock ring racing out along the ground.
	var gk := clampf(t / 0.45, 0.0, 1.0)
	if gk < 1.0:
		var gr := lerpf(10.0, 130.0, 1.0 - pow(1.0 - gk, 2.5))
		var ring := PackedVector2Array()
		for i in 41:
			var a := TAU * float(i) / 40.0
			ring.append(Vector2(_to.x + cos(a) * gr, _ground_y + sin(a) * gr * 0.26))
		draw_polyline(ring, Color(CORONA, 0.8 * (1.0 - gk)), 4.0 * (1.0 - gk) + 1.0, true)


## One tapering shaft from the black sun down to `head`.
func _shaft(head: Vector2, side: Vector2, width: float, color: Color) -> void:
	if head.distance_to(_from) < 3.0 or width < 0.5:
		return
	draw_colored_polygon(PackedVector2Array([
		_from + side * width * 0.15, head + side * width * 0.5,
		head - side * width * 0.5, _from - side * width * 0.15]), color)
