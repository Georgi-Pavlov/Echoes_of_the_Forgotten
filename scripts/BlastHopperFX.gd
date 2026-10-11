class_name BlastHopperFX
extends Node2D

## Purely cosmetic: Raze's Blast Hopper, in three beats (see battle.gd's
## _play_blast_hop_effect(), which times them against the leap itself):
##   - launch(): a charge goes off under her feet - a white-hot flash, a
##     fountain of fire and sparks, smoke and a ring of dust racing out
##     along the ground - and throws her into the air;
##   - slam(): at the peak of the leap both barrels fire down at where
##     she is going to land - two fat slugs rip to the ground and
##     detonate in a deafening flash and shockwave (`on_hit` fires then);
##   - land(): the dust she kicks up as she touches down.
## One instance per beat; each frees itself.

const CORE := Color(1.0, 0.97, 0.85)
const FLAME := Color(1.0, 0.6, 0.15)
const DEEP := Color(0.9, 0.25, 0.06)
const DUST := Color(0.85, 0.62, 0.38)

const LAUNCH := 0
const SLAM := 1
const LAND := 2

const SLUG_TIME := 0.09

var _kind := LAUNCH
var _at := Vector2.ZERO       # feet (launch/land) or target (slam)
var _from := Vector2.ZERO     # muzzle (slam)
var _direction := 1
var _radius := 120.0
var _on_hit := Callable()
var _age := 0.0
var _hit := false


## The charge under her feet at `feet` (global).
static func launch(host: Node, feet: Vector2, direction: int) -> void:
	_spawn(host, LAUNCH, feet, Vector2.ZERO, direction, 0.0, Callable())


## Both barrels fired from `muzzle` down at `target` (the landing point),
## the blast covering `radius` px.
static func slam(host: Node, muzzle: Vector2, target: Vector2, radius: float, on_hit: Callable = Callable()) -> void:
	_spawn(host, SLAM, target, muzzle, 1, radius, on_hit)


static func land(host: Node, feet: Vector2) -> void:
	_spawn(host, LAND, feet, Vector2.ZERO, 1, 0.0, Callable())


static func _spawn(host: Node, kind: int, at: Vector2, from: Vector2, direction: int, radius: float, on_hit: Callable) -> void:
	var fx := BlastHopperFX.new()
	fx._kind = kind
	fx._at = at
	fx._from = from
	fx._direction = direction
	fx._radius = maxf(radius, 80.0)
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()
	match _kind:
		LAUNCH:
			AudioManager.play_event("blast_hopper_launch")
			_build_launch()
		SLAM:
			AudioManager.play_event("raze_shoot", 2.0)
			_build_muzzle()
		LAND:
			AudioManager.play_event("land_thud")
			_burst_dust(14, 0.6, 1.0)


func _process(delta: float) -> void:
	_age += delta
	if _kind == SLAM and not _hit and _age >= SLUG_TIME:
		_hit = true
		_build_detonation()
		if _on_hit.is_valid():
			_on_hit.call()
	var life := 0.9
	if _kind == SLAM:
		life = SLUG_TIME + 1.0
	if _age >= life:
		queue_free()
		return
	queue_redraw()


# --- particle beats -------------------------------------------------

func _particles(pos: Vector2, amount: int, lifetime: float, additive: bool = true) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = pos
	p.one_shot = true
	p.amount = amount
	p.lifetime = lifetime
	p.explosiveness = 0.95
	p.texture = VoidReachFX._dot()
	if additive:
		p.material = VoidReachFX._additive()
	add_child(p)
	return p


func _ramp(colors: PackedColorArray, offsets: PackedFloat32Array) -> Gradient:
	var g := Gradient.new()
	g.offsets = offsets
	g.colors = colors
	return g


func _build_launch() -> void:
	# The fountain of fire straight up, leaning back from where she's going.
	var fire := _particles(_at, 70, 0.55)
	fire.direction = Vector2(-0.35 * _direction, -1.0)
	fire.spread = 34.0
	fire.gravity = Vector2(0.0, 120.0)
	fire.initial_velocity_min = 180.0
	fire.initial_velocity_max = 420.0
	fire.damping_min = 80.0
	fire.damping_max = 200.0
	fire.scale_amount_min = 2.4
	fire.scale_amount_max = 5.2
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.6))
	grow.add_point(Vector2(0.3, 1.5))
	grow.add_point(Vector2(1.0, 0.2))
	fire.scale_amount_curve = grow
	fire.color_ramp = _ramp(
		PackedColorArray([Color(CORE, 0.95), Color(1.0, 0.8, 0.35, 0.9), Color(FLAME, 0.65), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.2, 0.55, 1.0]))
	fire.emitting = true

	# Sparks flung out, falling as they cool.
	var sparks := _particles(_at, 40, 0.8)
	sparks.direction = Vector2(0.0, -1.0)
	sparks.spread = 75.0
	sparks.gravity = Vector2(0.0, 420.0)
	sparks.initial_velocity_min = 160.0
	sparks.initial_velocity_max = 440.0
	sparks.damping_min = 30.0
	sparks.damping_max = 100.0
	sparks.scale_amount_min = 0.8
	sparks.scale_amount_max = 1.8
	sparks.color_ramp = _ramp(
		PackedColorArray([Color(1.0, 0.95, 0.6, 1.0), Color(FLAME, 0.9), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.3, 1.0]))
	sparks.emitting = true

	# Black smoke boiling up behind the flash.
	var smoke := _particles(_at, 22, 1.0, false)
	smoke.direction = Vector2(0.0, -1.0)
	smoke.spread = 50.0
	smoke.gravity = Vector2(0.0, -40.0)
	smoke.initial_velocity_min = 40.0
	smoke.initial_velocity_max = 160.0
	smoke.damping_min = 60.0
	smoke.damping_max = 120.0
	smoke.scale_amount_min = 4.0
	smoke.scale_amount_max = 8.0
	smoke.color_ramp = _ramp(
		PackedColorArray([Color(0.3, 0.24, 0.2, 0.0), Color(0.26, 0.2, 0.17, 0.6), Color(0.1, 0.09, 0.09, 0.0)]),
		PackedFloat32Array([0.0, 0.2, 1.0]))
	smoke.emitting = true

	_burst_dust(20, 0.8, 1.4)


## Dust racing out along the ground in both directions.
func _burst_dust(amount: int, lifetime: float, strength: float) -> void:
	for side in [-1.0, 1.0]:
		var dust := _particles(_at, amount, lifetime, false)
		dust.direction = Vector2(side, -0.12)
		dust.spread = 12.0
		dust.gravity = Vector2(0.0, -20.0)
		dust.initial_velocity_min = 90.0 * strength
		dust.initial_velocity_max = 260.0 * strength
		dust.damping_min = 120.0
		dust.damping_max = 220.0
		dust.scale_amount_min = 3.0
		dust.scale_amount_max = 6.5
		dust.color_ramp = _ramp(
			PackedColorArray([Color(DUST, 0.0), Color(DUST, 0.55), Color(0.6, 0.42, 0.28, 0.0)]),
			PackedFloat32Array([0.0, 0.2, 1.0]))
		dust.emitting = true


func _build_muzzle() -> void:
	var dir := (_at - _from).normalized()
	var puff := _particles(_from, 26, 0.25)
	puff.direction = dir
	puff.spread = 20.0
	puff.initial_velocity_min = 140.0
	puff.initial_velocity_max = 320.0
	puff.damping_min = 400.0
	puff.damping_max = 560.0
	puff.scale_amount_min = 1.6
	puff.scale_amount_max = 3.2
	puff.color_ramp = _ramp(
		PackedColorArray([Color(CORE, 0.95), Color(FLAME, 0.7), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.25, 1.0]))
	puff.emitting = true


func _build_detonation() -> void:
	AudioManager.play_event("explosion")
	var fire := _particles(_at, 80, 0.5)
	fire.direction = Vector2(0.0, -1.0)
	fire.spread = 80.0
	fire.gravity = Vector2(0.0, 90.0)
	fire.initial_velocity_min = 140.0
	fire.initial_velocity_max = 380.0
	fire.damping_min = 100.0
	fire.damping_max = 240.0
	fire.scale_amount_min = 2.0
	fire.scale_amount_max = 4.6
	fire.color_ramp = _ramp(
		PackedColorArray([Color(CORE, 1.0), Color(1.0, 0.8, 0.35, 0.9), Color(FLAME, 0.6), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.2, 0.55, 1.0]))
	fire.emitting = true

	var sparks := _particles(_at, 36, 0.7)
	sparks.direction = Vector2(0.0, -1.0)
	sparks.spread = 90.0
	sparks.gravity = Vector2(0.0, 380.0)
	sparks.initial_velocity_min = 140.0
	sparks.initial_velocity_max = 380.0
	sparks.damping_min = 30.0
	sparks.damping_max = 100.0
	sparks.scale_amount_min = 0.8
	sparks.scale_amount_max = 1.8
	sparks.color_ramp = _ramp(
		PackedColorArray([Color(1.0, 0.95, 0.6, 1.0), Color(FLAME, 0.9), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.3, 1.0]))
	sparks.emitting = true
	_burst_dust(18, 0.7, 1.3)


# --- drawing --------------------------------------------------------

func _draw() -> void:
	match _kind:
		LAUNCH:
			_draw_launch()
		SLAM:
			_draw_slam()
		LAND:
			_draw_ring(_at, _age / 0.5, 110.0, Color(DUST, 0.5), 0.5)


## An expanding ellipse hugging the ground: `t` runs 0..1.
func _draw_ring(center: Vector2, t: float, max_radius: float, color: Color, squash: float) -> void:
	if t >= 1.0:
		return
	var e := 1.0 - pow(1.0 - t, 2.5)
	var r := lerpf(8.0, max_radius, e)
	var pts := PackedVector2Array()
	for i in 41:
		var a := TAU * float(i) / 40.0
		pts.append(center + Vector2(cos(a) * r, sin(a) * r * squash))
	draw_polyline(pts, Color(color, color.a * (1.0 - t)), 5.0 * (1.0 - t) + 1.0, true)


func _draw_launch() -> void:
	# The flash: a hot column and ball of light at her feet.
	if _age < 0.22:
		var k := 1.0 - _age / 0.22
		draw_circle(_at + Vector2(0.0, -10.0), 70.0 * (0.5 + 0.5 * k), Color(1.0, 0.7, 0.3, 0.35 * k))
		draw_circle(_at + Vector2(0.0, -10.0), 42.0 * (0.5 + 0.5 * k), Color(1.0, 0.88, 0.55, 0.6 * k))
		draw_circle(_at + Vector2(0.0, -10.0), 22.0 * k, Color(CORE, 0.95 * k))
		var h := 170.0 * (0.4 + 0.6 * k)
		draw_colored_polygon(PackedVector2Array([
			_at + Vector2(-26.0 * k, 0.0), _at + Vector2(0.0, -h), _at + Vector2(26.0 * k, 0.0)]), Color(FLAME, 0.55 * k))
	_draw_ring(_at, _age / 0.5, 190.0, Color(CORE, 0.8), 0.28)
	_draw_ring(_at, (_age - 0.05) / 0.55, 140.0, Color(FLAME, 0.6), 0.28)
	# The scorch the charge leaves, fading slowly.
	var scorch := 1.0 - clampf(_age / 0.9, 0.0, 1.0)
	draw_circle(_at, 26.0, Color(DEEP, 0.18 * scorch))


func _draw_slam() -> void:
	var dir := (_at - _from).normalized()
	var side := dir.orthogonal()
	# Muzzle flash from both barrels.
	if _age < 0.12:
		var k := 1.0 - _age / 0.12
		for barrel in 2:
			var o := _from + side * (8.0 * (float(barrel) - 0.5))
			var len := 100.0 * (0.6 + 0.4 * k)
			var half := 26.0 * k
			draw_colored_polygon(PackedVector2Array([o, o + dir * len * 0.5 + side * half, o + dir * len, o + dir * len * 0.5 - side * half]), Color(FLAME, 0.75 * k))
			draw_colored_polygon(PackedVector2Array([o, o + dir * len * 0.4 + side * half * 0.4, o + dir * len * 0.62, o + dir * len * 0.4 - side * half * 0.4]), Color(CORE, 0.95 * k))
		draw_circle(_from, 38.0 * k, Color(1.0, 0.85, 0.5, 0.55 * k))

	# Two fat slugs, side by side, ripping down to the target.
	var t := clampf(_age / SLUG_TIME, 0.0, 1.0)
	if t < 1.0:
		var reach := (_at - _from).length()
		for barrel in 2:
			var off := side * (8.0 * (float(barrel) - 0.5)) * (1.0 - t)
			var head := _from + off + dir * reach * t
			var tail := _from + off + dir * maxf(reach * t - 140.0, 0.0)
			for i in 5:
				var f := float(i) / 5.0
				draw_line(tail.lerp(head, f), tail.lerp(head, f + 0.2), Color(FLAME, 0.2 + 0.5 * f), 3.0 + 8.0 * f, true)
			draw_line(tail.lerp(head, 0.5), head, Color(CORE, 0.9), 3.5, true)
			draw_circle(head, 12.0, Color(1.0, 0.6, 0.2, 0.4))
			draw_circle(head, 5.5, Color(CORE, 1.0))

	# The detonation: a blinding flash, the shockwave out to the blast's
	# radius, and hard rays of light - the "deafening" bang.
	if _hit:
		var ik := clampf((_age - SLUG_TIME) / 0.5, 0.0, 1.0)
		var flash := 1.0 - clampf((_age - SLUG_TIME) / 0.18, 0.0, 1.0)
		if flash > 0.0:
			draw_circle(_at + Vector2(0.0, -14.0), _radius * 0.55 * (1.2 - 0.2 * flash), Color(1.0, 0.92, 0.7, 0.55 * flash))
			draw_circle(_at + Vector2(0.0, -14.0), _radius * 0.28, Color(CORE, 0.9 * flash))
			for i in 10:
				var a := TAU * float(i) / 10.0 + 0.3
				var ray := Vector2(cos(a), sin(a) * 0.6)
				draw_line(_at + ray * 12.0, _at + ray * _radius * (0.5 + 0.5 * flash), Color(CORE, 0.7 * flash), 4.0 * flash + 1.0, true)
		_draw_ring(_at, ik, _radius, Color(CORE, 0.9), 0.3)
		_draw_ring(_at, (ik - 0.1) / 0.9, _radius * 0.75, Color(FLAME, 0.65), 0.3)
		_draw_ring(_at, (ik - 0.2) / 0.8, _radius * 0.5, Color(DEEP, 0.5), 0.3)
		var scorch := 1.0 - clampf((_age - SLUG_TIME) / 1.0, 0.0, 1.0)
		draw_circle(_at, 30.0, Color(DEEP, 0.15 * scorch))
