class_name NapalmFX
extends Node2D

## Purely cosmetic: one incendiary shot of Raze's Kiss the Wastes. A hard
## muzzle flash, a glowing shell lobbed to the target's column, then a
## fireball that splashes burning jelly across the ground - a main pool
## on the column that was hit, and smaller spatters on the columns either
## side - which keeps burning for a few seconds like napalm: low, licking
## flames over a scorched, glowing patch, shedding embers and smoke, and
## guttering out. `on_hit` fires as the shell lands.

const SHELL_TIME := 0.2
const BURN_TIME := 3.4

const CORE := Color(1.0, 0.97, 0.8)
const FLAME := Color(1.0, 0.6, 0.15)
const DEEP := Color(0.9, 0.25, 0.06)

var _from: Vector2
var _ground: Vector2          # centre of the hit column, on the ground
var _unit: float              # one column's width in px
var _on_hit := Callable()
var _age := 0.0
var _hit := false
var _pools: Array[Dictionary] = []
var _scorch: Node2D


## `muzzle`: where the shell leaves (global); `ground`: the hit column's
## centre on the ground; `unit`: one column's width in px.
static func play(host: Node, muzzle: Vector2, ground: Vector2, unit: float, on_hit: Callable = Callable()) -> void:
	var fx := NapalmFX.new()
	fx._from = muzzle
	fx._ground = ground
	fx._unit = maxf(unit, 80.0)
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()
	# The scorch marks and smoke under the flames: ordinary blending, so
	# they darken the ground rather than glow.
	AudioManager.play_event("kiss_the_wastes")
	_scorch = Node2D.new()
	_scorch.draw.connect(_draw_scorch)
	add_child(_scorch)
	move_child(_scorch, 0)

	var dir := (_ground - _from).normalized()
	var puff := _particles(_from, 24, 0.25)
	puff.direction = dir
	puff.spread = 20.0
	puff.initial_velocity_min = 140.0
	puff.initial_velocity_max = 320.0
	puff.damping_min = 400.0
	puff.damping_max = 560.0
	puff.scale_amount_min = 1.6
	puff.scale_amount_max = 3.0
	puff.color_ramp = _ramp(
		PackedColorArray([Color(CORE, 0.95), Color(FLAME, 0.7), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.25, 1.0]))
	puff.emitting = true


func _process(delta: float) -> void:
	_age += delta
	if not _hit and _age >= SHELL_TIME:
		_hit = true
		_splash()
		if _on_hit.is_valid():
			_on_hit.call()
	if _age >= SHELL_TIME + BURN_TIME + 0.6:
		queue_free()
		return
	queue_redraw()
	_scorch.queue_redraw()


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


## The shell lands: a fireball, jelly flung out, and the pools that start
## to burn where it falls.
func _splash() -> void:
	AudioManager.play_event("napalm_impact")
	AudioManager.play_event("napalm_burn")
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var fire := _particles(_ground, 60, 0.5)
	fire.direction = Vector2(0.0, -1.0)
	fire.spread = 70.0
	fire.gravity = Vector2(0.0, 160.0)
	fire.initial_velocity_min = 120.0
	fire.initial_velocity_max = 340.0
	fire.damping_min = 90.0
	fire.damping_max = 220.0
	fire.scale_amount_min = 2.0
	fire.scale_amount_max = 4.4
	fire.color_ramp = _ramp(
		PackedColorArray([Color(CORE, 1.0), Color(1.0, 0.8, 0.35, 0.9), Color(FLAME, 0.6), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.2, 0.55, 1.0]))
	fire.emitting = true

	# Burning globs thrown wide, falling back to the ground.
	var globs := _particles(_ground, 26, 0.7)
	globs.direction = Vector2(0.0, -1.0)
	globs.spread = 80.0
	globs.gravity = Vector2(0.0, 520.0)
	globs.initial_velocity_min = 180.0
	globs.initial_velocity_max = 420.0
	globs.scale_amount_min = 1.2
	globs.scale_amount_max = 2.6
	globs.color_ramp = _ramp(
		PackedColorArray([Color(1.0, 0.9, 0.5, 1.0), Color(FLAME, 0.95), Color(DEEP, 0.0)]),
		PackedFloat32Array([0.0, 0.5, 1.0]))
	globs.emitting = true

	# The main pool on the hit column, and spatters on the ones either side.
	for i in 3:
		_add_pool(_ground.x + (float(i) - 1.0) * _unit * 0.22 + rng.randf_range(-6.0, 6.0), _unit * rng.randf_range(0.13, 0.19), 1.0, rng)
	for side in [-1.0, 1.0]:
		for i in 2:
			_add_pool(_ground.x + side * _unit * rng.randf_range(0.55, 1.2), _unit * rng.randf_range(0.06, 0.1), 0.6, rng)


func _add_pool(x: float, half_width: float, strength: float, rng: RandomNumberGenerator) -> void:
	var tongues: Array[Dictionary] = []
	for i in rng.randi_range(4, 6):
		tongues.append({
			"off": rng.randf_range(-0.8, 0.8) * half_width,
			"height": rng.randf_range(0.7, 1.2) * _unit * 0.3 * strength,
			"width": rng.randf_range(0.5, 0.9) * half_width * 0.6,
			"speed": rng.randf_range(7.0, 13.0), "phase": rng.randf() * TAU,
		})
	_pools.append({
		"x": x, "w": half_width, "tongues": tongues,
		"burn": BURN_TIME * rng.randf_range(0.7, 1.0) * (0.75 + 0.25 * strength),
		"start": rng.randf_range(0.0, 0.18),
		"strength": strength,
	})
	# Embers and smoke rising off the larger pools.
	if strength >= 1.0:
		var pos := Vector2(x, _ground.y)
		var embers := CPUParticles2D.new()
		embers.position = pos
		embers.amount = 7
		embers.lifetime = 1.1
		embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		embers.emission_rect_extents = Vector2(half_width * 0.7, 3.0)
		embers.texture = VoidReachFX._dot()
		embers.direction = Vector2(0.0, -1.0)
		embers.spread = 25.0
		embers.gravity = Vector2(0.0, -30.0)
		embers.initial_velocity_min = 30.0
		embers.initial_velocity_max = 80.0
		embers.scale_amount_min = 0.6
		embers.scale_amount_max = 1.4
		embers.color_ramp = _ramp(
			PackedColorArray([Color(1.0, 0.85, 0.45, 0.0), Color(1.0, 0.7, 0.3, 0.95), Color(DEEP, 0.0)]),
			PackedFloat32Array([0.0, 0.2, 1.0]))
		embers.material = VoidReachFX._additive()
		add_child(embers)
		embers.emitting = true
		get_tree().create_timer(BURN_TIME * 0.8).timeout.connect(func() -> void:
			if is_instance_valid(embers):
				embers.emitting = false)

		var smoke := CPUParticles2D.new()
		smoke.position = pos + Vector2(0.0, -10.0)
		smoke.amount = 5
		smoke.lifetime = 1.6
		smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		smoke.emission_rect_extents = Vector2(half_width * 0.6, 3.0)
		smoke.texture = VoidReachFX._dot()
		smoke.direction = Vector2(0.0, -1.0)
		smoke.spread = 20.0
		smoke.gravity = Vector2(0.0, -20.0)
		smoke.initial_velocity_min = 20.0
		smoke.initial_velocity_max = 50.0
		smoke.scale_amount_min = 3.0
		smoke.scale_amount_max = 6.0
		smoke.color_ramp = _ramp(
			PackedColorArray([Color(0.2, 0.15, 0.12, 0.0), Color(0.18, 0.14, 0.12, 0.4), Color(0.1, 0.1, 0.1, 0.0)]),
			PackedFloat32Array([0.0, 0.25, 1.0]))
		add_child(smoke)
		smoke.emitting = true
		get_tree().create_timer(BURN_TIME * 0.7).timeout.connect(func() -> void:
			if is_instance_valid(smoke):
				smoke.emitting = false)


## 0..1: how strongly a pool still burns - flares up, holds, then gutters.
func _pool_life(pool: Dictionary) -> float:
	var t: float = _age - SHELL_TIME - float(pool["start"])
	if t <= 0.0:
		return 0.0
	var burn: float = pool["burn"]
	if t >= burn:
		return 0.0
	return smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(burn * 0.65, burn, t))


# --- drawing --------------------------------------------------------

func _draw() -> void:
	var dir := (_ground - _from).normalized()
	var side := dir.orthogonal()
	# Muzzle flash.
	if _age < 0.12:
		var k := 1.0 - _age / 0.12
		var len := 90.0 * (0.6 + 0.4 * k)
		var half := 22.0 * k
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.5 + side * half, _from + dir * len, _from + dir * len * 0.5 - side * half]), Color(FLAME, 0.75 * k))
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.4 + side * half * 0.4, _from + dir * len * 0.62, _from + dir * len * 0.4 - side * half * 0.4]), Color(CORE, 0.95 * k))
		draw_circle(_from, 32.0 * k, Color(1.0, 0.85, 0.5, 0.55 * k))

	# The shell: a glowing lobbed ball dragging a fiery tail.
	var t := clampf(_age / SHELL_TIME, 0.0, 1.0)
	if t < 1.0:
		var head := _arc_point(t)
		for i in 7:
			var f := float(i) / 7.0
			var p := _arc_point(maxf(t - 0.28 * (1.0 - f), 0.0))
			draw_circle(p, 3.0 + 7.0 * f, Color(FLAME, 0.15 + 0.4 * f))
		draw_circle(head, 15.0, Color(1.0, 0.55, 0.15, 0.4))
		draw_circle(head, 9.0, Color(1.0, 0.8, 0.4, 0.7))
		draw_circle(head, 5.0, Color(CORE, 1.0))

	if not _hit:
		return
	# The fireball as it lands.
	var flash := 1.0 - clampf((_age - SHELL_TIME) / 0.2, 0.0, 1.0)
	if flash > 0.0:
		draw_circle(_ground + Vector2(0.0, -20.0), _unit * 0.42 * (1.3 - 0.3 * flash), Color(1.0, 0.7, 0.3, 0.5 * flash))
		draw_circle(_ground + Vector2(0.0, -20.0), _unit * 0.2, Color(CORE, 0.9 * flash))
	# The pools burn: a glowing bed of jelly with flame tongues licking up.
	for pool in _pools:
		var life := _pool_life(pool)
		if life <= 0.01:
			continue
		var x: float = pool["x"]
		var w: float = pool["w"]
		var base := Vector2(x, _ground.y)
		draw_circle(base + Vector2(0.0, -4.0), w * 1.2, Color(DEEP, 0.18 * life))
		var bed := PackedVector2Array()
		for i in 21:
			var a := TAU * float(i) / 20.0
			bed.append(base + Vector2(cos(a) * w, sin(a) * w * 0.22 - 2.0))
		draw_colored_polygon(bed, Color(FLAME, 0.5 * life))
		for tongue in pool["tongues"]:
			var flick: float = 0.65 + 0.35 * sin(_age * float(tongue["speed"]) + float(tongue["phase"]))
			var h: float = float(tongue["height"]) * flick * life
			var tw: float = float(tongue["width"]) * (0.8 + 0.2 * life)
			var bx: float = x + float(tongue["off"])
			var sway: float = 6.0 * sin(_age * float(tongue["speed"]) * 0.7 + float(tongue["phase"]) * 2.0)
			_draw_tongue(Vector2(bx, base.y), tw, h, sway, Color(FLAME, 0.6 * life))
			_draw_tongue(Vector2(bx, base.y), tw * 0.55, h * 0.62, sway * 0.6, Color(1.0, 0.88, 0.45, 0.8 * life))


func _draw_tongue(base: Vector2, width: float, height: float, sway: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-width, 0.0),
		base + Vector2(-width * 0.8 + sway * 0.2, -height * 0.45),
		base + Vector2(sway, -height),
		base + Vector2(width * 0.8 + sway * 0.2, -height * 0.45),
		base + Vector2(width, 0.0)]), color)


## The shell's flight: a lobbed arc from the muzzle to the ground.
func _arc_point(t: float) -> Vector2:
	var p := _from.lerp(_ground, t)
	p.y -= 70.0 * 4.0 * t * (1.0 - t)
	return p


func _draw_scorch() -> void:
	if not _hit:
		return
	for pool in _pools:
		var life := _pool_life(pool)
		# The scorch stays after the flames have gone, fading slowly.
		var t: float = _age - SHELL_TIME - float(pool["start"])
		if t <= 0.0:
			continue
		var stain := 1.0 - smoothstep(float(pool["burn"]), float(pool["burn"]) + 0.6, t)
		if stain <= 0.01:
			continue
		var base := Vector2(float(pool["x"]), _ground.y)
		var w: float = pool["w"]
		var pts := PackedVector2Array()
		for i in 21:
			var a := TAU * float(i) / 20.0
			pts.append(base + Vector2(cos(a) * w * 1.3, sin(a) * w * 0.3))
		_scorch.draw_colored_polygon(pts, Color(0.06, 0.04, 0.03, 0.55 * stain))
