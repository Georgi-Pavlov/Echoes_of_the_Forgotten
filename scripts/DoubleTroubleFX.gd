class_name DoubleTroubleFX
extends Node2D

## Purely cosmetic: Raze's Double Trouble. Both barrels of her shotgun go
## off at once - a white-hot flash and a cone of fire at the muzzle, a ring
## of smoke, and a spray of glowing pellets that fan out in the facing
## direction, streaking `reach` pixels before they burn out. Cast by the
## player's hero and by a rival Raze alike.

const FLASH_TIME := 0.24
const PELLETS_PER_BARREL := 22
const PELLET_TIME := Vector2(0.26, 0.4)
const SPREAD_DEGREES := 24.0
const BARREL_GAP := 9.0       # px between the two barrels
const RING_TIME := 0.32       # the shockwave leaving the muzzle

const CORE := Color(1.0, 0.96, 0.8)
const FLAME := Color(1.0, 0.58, 0.14)
const DEEP := Color(0.85, 0.22, 0.06)

var _from: Vector2
var _heading: Vector2
var _reach: float
var _age := 0.0
var _pellets: Array[Dictionary] = []


## `from`: the muzzle (global position); `direction`: +1 right, -1 left;
## `reach`: how far the pellets fly, in pixels.
static func play(host: Node, from: Vector2, direction: int, reach: float) -> void:
	var fx := DoubleTroubleFX.new()
	fx._from = from
	fx._heading = Vector2(float(direction), 0.0)
	fx._reach = maxf(reach, 120.0)
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()
	AudioManager.play_event("raze_shoot", 2.0)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var side := Vector2(0.0, 1.0)
	for barrel in 2:
		var origin := _from + side * (BARREL_GAP * (float(barrel) - 0.5))
		for i in PELLETS_PER_BARREL:
			var angle := deg_to_rad(rng.randf_range(-SPREAD_DEGREES, SPREAD_DEGREES))
			_pellets.append({
				"origin": origin,
				"dir": _heading.rotated(angle),
				"time": rng.randf_range(PELLET_TIME.x, PELLET_TIME.y),
				"dist": _reach * rng.randf_range(0.8, 1.1),
				"trail": rng.randf_range(24.0, 64.0),
				"width": rng.randf_range(2.4, 4.4),
			})

	# A roaring cone of fire right at the muzzle.
	var fire := CPUParticles2D.new()
	fire.position = _from
	fire.one_shot = true
	fire.amount = 90
	fire.lifetime = 0.3
	fire.explosiveness = 0.95
	fire.texture = VoidReachFX._dot()
	fire.direction = _heading
	fire.spread = 30.0
	fire.gravity = Vector2(0.0, -40.0)
	fire.initial_velocity_min = _reach * 0.5
	fire.initial_velocity_max = _reach * 1.1
	fire.damping_min = _reach * 2.0
	fire.damping_max = _reach * 3.0
	fire.scale_amount_min = 2.6
	fire.scale_amount_max = 5.0
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.5))
	grow.add_point(Vector2(0.4, 1.6))
	grow.add_point(Vector2(1.0, 0.2))
	fire.scale_amount_curve = grow
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.55, 1.0])
	ramp.colors = PackedColorArray([Color(CORE, 0.95), Color(1.0, 0.8, 0.35, 0.9), Color(FLAME, 0.6), Color(DEEP, 0.0)])
	fire.color_ramp = ramp
	fire.material = VoidReachFX._additive()
	add_child(fire)
	fire.emitting = true

	# A shower of sparks thrown out of the blast, falling as they cool.
	var sparks := CPUParticles2D.new()
	sparks.position = _from
	sparks.one_shot = true
	sparks.amount = 40
	sparks.lifetime = 0.7
	sparks.explosiveness = 0.9
	sparks.texture = VoidReachFX._dot()
	sparks.direction = _heading
	sparks.spread = 55.0
	sparks.gravity = Vector2(0.0, 260.0)
	sparks.initial_velocity_min = _reach * 0.6
	sparks.initial_velocity_max = _reach * 1.4
	sparks.damping_min = 40.0
	sparks.damping_max = 120.0
	sparks.scale_amount_min = 0.8
	sparks.scale_amount_max = 1.8
	var spark_ramp := Gradient.new()
	spark_ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	spark_ramp.colors = PackedColorArray([Color(1.0, 0.95, 0.6, 1.0), Color(FLAME, 0.9), Color(DEEP, 0.0)])
	sparks.color_ramp = spark_ramp
	sparks.material = VoidReachFX._additive()
	add_child(sparks)
	sparks.emitting = true

	# Powder smoke hanging in the air after the shot.
	var smoke := CPUParticles2D.new()
	smoke.position = _from + _heading * 18.0
	smoke.one_shot = true
	smoke.amount = 28
	smoke.lifetime = 0.9
	smoke.explosiveness = 0.9
	smoke.texture = VoidReachFX._dot()
	smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	smoke.emission_sphere_radius = 8.0
	smoke.direction = _heading
	smoke.spread = 40.0
	smoke.gravity = Vector2(0.0, -30.0)
	smoke.initial_velocity_min = 30.0
	smoke.initial_velocity_max = 90.0
	smoke.damping_min = 50.0
	smoke.damping_max = 90.0
	smoke.scale_amount_min = 3.4
	smoke.scale_amount_max = 6.0
	var smoke_ramp := Gradient.new()
	smoke_ramp.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	smoke_ramp.colors = PackedColorArray([Color(0.3, 0.24, 0.2, 0.0), Color(0.28, 0.22, 0.18, 0.55), Color(0.12, 0.1, 0.1, 0.0)])
	smoke.color_ramp = smoke_ramp
	add_child(smoke)
	smoke.emitting = true


func _process(delta: float) -> void:
	_age += delta
	if _age >= PELLET_TIME.y + 0.9:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# The muzzle flash: a hot cone and a bright burst at each barrel.
	if _age < FLASH_TIME:
		var k := 1.0 - _age / FLASH_TIME
		var side := Vector2(0.0, 1.0)
		for barrel in 2:
			var o := _from + side * (BARREL_GAP * (float(barrel) - 0.5))
			var len := 120.0 * (0.6 + 0.4 * k)
			var half := 34.0 * k
			var pts := PackedVector2Array([
				o, o + _heading * len * 0.55 + side * half, o + _heading * len, o + _heading * len * 0.55 - side * half])
			draw_colored_polygon(pts, Color(FLAME, 0.7 * k))
			var inner := PackedVector2Array([
				o, o + _heading * len * 0.4 + side * half * 0.45, o + _heading * len * 0.62, o + _heading * len * 0.4 - side * half * 0.45])
			draw_colored_polygon(inner, Color(CORE, 0.9 * k))
			_glow(o + _heading * 6.0, 58.0 * (0.7 + 0.3 * k), Color(1.0, 0.85, 0.5, 0.9 * k))

	# The shockwave: a bright arc spreading out of the muzzle.
	if _age < RING_TIME:
		var rk := _age / RING_TIME
		var radius := lerpf(10.0, 150.0, 1.0 - pow(1.0 - rk, 2.0))
		var start := _heading.angle() - 1.0
		draw_arc(_from + _heading * 10.0, radius, start, start + 2.0, 28, Color(CORE, 0.8 * (1.0 - rk)), 5.0 * (1.0 - rk) + 1.0, true)
		draw_arc(_from + _heading * 10.0, radius * 0.8, start + 0.1, start + 1.9, 28, Color(FLAME, 0.5 * (1.0 - rk)), 3.0 * (1.0 - rk) + 1.0, true)

	# The pellets: a glowing head with a streaking tail.
	for p in _pellets:
		var t: float = _age / float(p["time"])
		if t >= 1.0:
			continue
		var travelled: float = float(p["dist"]) * (1.0 - pow(1.0 - t, 2.2))
		var head: Vector2 = Vector2(p["origin"]) + Vector2(p["dir"]) * travelled
		var tail: Vector2 = head - Vector2(p["dir"]) * minf(float(p["trail"]), travelled)
		var fade := 1.0 - smoothstep(0.55, 1.0, t)
		draw_line(tail, head, Color(FLAME, 0.55 * fade), float(p["width"]), true)
		draw_line(head - Vector2(p["dir"]) * minf(float(p["trail"]) * 0.4, travelled), head, Color(CORE, 0.9 * fade), float(p["width"]) * 0.6, true)
		_glow(head, 9.0, Color(1.0, 0.7, 0.3, 0.7 * fade))


func _glow(at: Vector2, radius: float, color: Color) -> void:
	for i in 3:
		var r := radius * (1.0 - float(i) * 0.3)
		draw_circle(at, r, Color(color, color.a * (0.2 + 0.25 * float(i))))
