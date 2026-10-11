class_name CinderbombFX
extends Node2D

## Purely cosmetic: Cinder's ultimate, Cinderbomb.
##
##   1. The throw: a burning fuel barrel - red-painted, iron-banded, a
##      skull on its side, fire licking off it - is hurled from Cinder in a
##      high arc, tumbling end over end, trailing flame and smoke.
##   2. The blast: it lands on the target and bursts - a white flash, a
##      rolling fireball, burning fuel splashed out across the blast's
##      reach, a shockwave ring, iron scraps flung out, the screen shaking.
##      `on_explode` fires here (the damage, and the burning ground).
##   3. The burning ground (burn_ground(), a separate node the battle
##      keeps): low flames dancing over the spilt fuel across the reach,
##      a hot glow on the scorched ground and embers drifting up, for as
##      long as the skill lasts, then guttering out (end_ground()).

const FLIGHT_TIME := 0.7
const ARC := 0.45              # arc height, of the throw's length (capped)
const BARREL := Vector2(42.0, 58.0)

const WALL_SHADER := preload("res://shaders/flame_wall.gdshader")

const RED := Color(0.62, 0.12, 0.08)
const IRON := Color(0.28, 0.25, 0.23)
const HOT := Color(1.0, 0.88, 0.5)
const FIRE := Color(1.0, 0.5, 0.12)
const DEEP := Color(0.8, 0.18, 0.04)

var _from: Vector2
var _to: Vector2
var _reach := 120.0
var _on_explode: Callable
var _age := 0.0
var _exploded := false
var _arc := 0.0
var _barrel: Node2D
var _trail: CPUParticles2D
var _smoke: CPUParticles2D
var _glow: Node2D


## Throws the barrel from `from` to `to` (global), whose blast reaches
## `reach` px to either side. `on_explode` fires as it bursts.
static func throw(host: Node, from: Vector2, to: Vector2, reach: float, on_explode: Callable = Callable()) -> void:
	var fx := CinderbombFX.new()
	fx._from = from
	fx._to = to
	fx._reach = reach
	fx._on_explode = on_explode
	fx._arc = minf(from.distance_to(to) * ARC, 260.0)
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	_barrel = Node2D.new()
	_barrel.draw.connect(_draw_barrel)
	add_child(_barrel)
	_trail = _particles(60, 0.45, 2.2, 3.6, [Color(HOT, 0.0), Color(1.0, 0.9, 0.55, 0.9), Color(FIRE, 0.7), Color(DEEP, 0.0)], true)
	_trail.gravity = Vector2(0.0, -120.0)
	_trail.spread = 60.0
	_trail.initial_velocity_min = 20.0
	_trail.initial_velocity_max = 60.0
	_trail.local_coords = false
	add_child(_trail)
	_trail.emitting = true
	_smoke = _particles(30, 1.0, 3.0, 5.0, [Color(0.15, 0.1, 0.08, 0.0), Color(0.15, 0.11, 0.09, 0.45), Color(0.1, 0.08, 0.08, 0.0)], false)
	_smoke.gravity = Vector2(0.0, -30.0)
	_smoke.spread = 40.0
	_smoke.initial_velocity_min = 5.0
	_smoke.initial_velocity_max = 20.0
	_smoke.local_coords = false
	add_child(_smoke)
	_smoke.emitting = true
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)


func _pos(t: float) -> Vector2:
	return _from.lerp(_to, t) + Vector2(0.0, -_arc * 4.0 * t * (1.0 - t))


func _process(delta: float) -> void:
	_age += delta
	var t := clampf(_age / FLIGHT_TIME, 0.0, 1.0)
	if not _exploded:
		var p := _pos(t)
		_barrel.position = p
		# Tumbling end over end the way it was thrown.
		_barrel.rotation = _age * 9.0 * signf(_to.x - _from.x + 0.001)
		_trail.position = p
		_smoke.position = p
		if t >= 1.0:
			_exploded = true
			_barrel.visible = false
			_trail.emitting = false
			_smoke.emitting = false
			_explode()
			AudioManager.play_event("Cinderbomb_explosion")
			if _on_explode.is_valid():
				_on_explode.call()
	if _age >= FLIGHT_TIME + 1.4:
		queue_free()
		return
	_glow.queue_redraw()


func _explode() -> void:
	var host := get_parent()
	# The fireball: a dense burst of flame, rolling up and out.
	var fireball := _particles(55, 0.8, 3.2, 6.0, [Color(1.0, 0.85, 0.5, 0.75), Color(FIRE, 0.65), Color(DEEP, 0.5), Color(0.35, 0.08, 0.03, 0.25), Color(0.15, 0.06, 0.03, 0.0)], true)
	fireball.position = _to
	fireball.one_shot = true
	fireball.explosiveness = 0.9
	fireball.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	fireball.emission_sphere_radius = 18.0
	fireball.spread = 180.0
	fireball.gravity = Vector2(0.0, -160.0)
	fireball.initial_velocity_min = 90.0
	fireball.initial_velocity_max = 230.0
	fireball.damping_min = 120.0
	fireball.damping_max = 200.0
	host.add_child(fireball)
	fireball.emitting = true
	# Burning fuel splashed out low across the blast's reach.
	var splash := _particles(50, 0.7, 2.0, 3.6, [Color(HOT, 1.0), Color(FIRE, 0.85), Color(DEEP, 0.0)], true)
	splash.position = _to
	splash.one_shot = true
	splash.explosiveness = 0.95
	splash.direction = Vector2(0.0, -1.0)
	splash.spread = 75.0
	splash.gravity = Vector2(0.0, 520.0)
	splash.initial_velocity_min = _reach * 1.2
	splash.initial_velocity_max = _reach * 2.2
	host.add_child(splash)
	splash.emitting = true
	# Iron scraps of the barrel flung out.
	var scraps := CPUParticles2D.new()
	scraps.position = _to
	scraps.amount = 10
	scraps.lifetime = 0.8
	scraps.one_shot = true
	scraps.explosiveness = 1.0
	scraps.spread = 180.0
	scraps.gravity = Vector2(0.0, 600.0)
	scraps.initial_velocity_min = 200.0
	scraps.initial_velocity_max = 380.0
	scraps.angle_min = 0.0
	scraps.angle_max = 360.0
	scraps.angular_velocity_min = -700.0
	scraps.angular_velocity_max = 700.0
	scraps.scale_amount_min = 3.0
	scraps.scale_amount_max = 6.0
	scraps.color = Color(0.45, 0.3, 0.2)
	host.add_child(scraps)
	scraps.emitting = true
	# Smoke billowing up after.
	var smoke := _particles(22, 1.8, 6.0, 10.0, [Color(0.15, 0.1, 0.08, 0.0), Color(0.15, 0.11, 0.09, 0.3), Color(0.1, 0.08, 0.08, 0.0)], false)
	smoke.position = _to
	smoke.one_shot = true
	smoke.explosiveness = 0.7
	smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	smoke.emission_sphere_radius = 30.0
	smoke.direction = Vector2(0.0, -1.0)
	smoke.spread = 50.0
	smoke.gravity = Vector2(0.0, -40.0)
	smoke.initial_velocity_min = 30.0
	smoke.initial_velocity_max = 80.0
	host.add_child(smoke)
	smoke.emitting = true
	for node in [fireball, splash, scraps, smoke]:
		get_tree().create_timer(2.2).timeout.connect(node.queue_free)


func _draw_barrel() -> void:
	var w := BARREL.x * 0.5
	var h := BARREL.y * 0.5
	# A slightly bulging drum.
	var body := PackedVector2Array([
		Vector2(-w * 0.85, -h), Vector2(w * 0.85, -h), Vector2(w, -h * 0.4), Vector2(w, h * 0.4),
		Vector2(w * 0.85, h), Vector2(-w * 0.85, h), Vector2(-w, h * 0.4), Vector2(-w, -h * 0.4),
	])
	_barrel.draw_colored_polygon(body, RED)
	# Shading down one side, a highlight on the other.
	_barrel.draw_colored_polygon(PackedVector2Array([Vector2(w * 0.35, -h), Vector2(w * 0.85, -h), Vector2(w, -h * 0.4), Vector2(w, h * 0.4), Vector2(w * 0.85, h), Vector2(w * 0.35, h)]), Color(0.0, 0.0, 0.0, 0.3))
	_barrel.draw_line(Vector2(-w * 0.55, -h * 0.85), Vector2(-w * 0.55, h * 0.85), Color(1.0, 0.6, 0.5, 0.35), 2.0)
	# Iron bands.
	for y in [-h * 0.92, -h * 0.35, h * 0.35, h * 0.92]:
		var half := w if absf(y) < h * 0.5 else w * 0.88
		_barrel.draw_line(Vector2(-half, y), Vector2(half, y), IRON, 3.0)
	# A pale skull daubed on its side.
	_barrel.draw_circle(Vector2(0.0, -1.5), w * 0.32, Color(0.92, 0.88, 0.8, 0.85))
	_barrel.draw_rect(Rect2(-w * 0.16, w * 0.1, w * 0.32, w * 0.22), Color(0.92, 0.88, 0.8, 0.85))
	_barrel.draw_circle(Vector2(-w * 0.12, -2.5), w * 0.08, RED)
	_barrel.draw_circle(Vector2(w * 0.12, -2.5), w * 0.08, RED)


func _draw_glow() -> void:
	if not _exploded:
		# The fire licking off the barrel.
		var flicker := 0.8 + 0.2 * sin(_age * 40.0)
		_glow.draw_circle(_barrel.position, BARREL.y * 0.9 * flicker, Color(FIRE, 0.3))
		return
	var since := _age - FLIGHT_TIME
	# The flash, then the shockwave ring racing out across the reach.
	var f := clampf(since / 0.2, 0.0, 1.0)
	if f < 1.0:
		_glow.draw_circle(_to, 30.0 + 70.0 * f, Color(1.0, 0.75, 0.4, 0.5 * (1.0 - f)))
	var w := clampf(since / 0.4, 0.0, 1.0)
	if w < 1.0:
		var r := 20.0 + (_reach + 30.0) * (1.0 - pow(1.0 - w, 2.0))
		var ring := PackedVector2Array()
		for k in 41:
			var a := TAU * k / 40.0
			ring.append(_to + Vector2(cos(a) * r, sin(a) * r * 0.35))
		_glow.draw_polyline(ring, Color(HOT, 0.75 * (1.0 - w)), 6.0 * (1.0 - w) + 1.5, true)


func _particles(amount: int, lifetime: float, smin: float, smax: float, colors: Array, additive: bool) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.lifetime = lifetime
	p.texture = VoidReachFX._dot()
	p.scale_amount_min = smin
	p.scale_amount_max = smax
	var ramp := Gradient.new()
	var offs := PackedFloat32Array()
	for i in colors.size():
		offs.append(float(i) / float(colors.size() - 1))
	ramp.offsets = offs
	ramp.colors = PackedColorArray(colors)
	p.color_ramp = ramp
	if additive:
		p.material = VoidReachFX._additive()
	return p


# --- the burning ground ---------------------------------------------

## The fuel left burning on the ground: low flames dancing across `reach`
## px either side of ground point `center` (global), a hot glow on the
## scorched ground and embers drifting up. Returns the node, for the
## battle to keep for the skill's duration and pass to end_ground().
static func burn_ground(host: Node, center: Vector2, reach: float, unit_height: float) -> Node2D:
	var ground := Node2D.new()
	host.add_child(ground)
	ground.global_position = center
	# The burning fuel roars for as long as it burns.
	ground.set_meta("fire_loop", AudioManager.play_loop("fire_attack", ground, 0.0, 0.5))
	var height := unit_height * 1.0

	var glow := Node2D.new()
	glow.material = VoidReachFX._additive()
	glow.draw.connect(func() -> void:
		var flick := 0.85 + 0.15 * sin(Time.get_ticks_msec() / 90.0) * sin(Time.get_ticks_msec() / 57.0)
		var pts := PackedVector2Array()
		for k in 33:
			var a := TAU * k / 32.0
			pts.append(Vector2(cos(a) * (reach + 10.0), sin(a) * 14.0))
		glow.draw_colored_polygon(pts, Color(FIRE, 0.3 * flick))
		glow.queue_redraw())
	ground.add_child(glow)

	var mat := ShaderMaterial.new()
	mat.shader = WALL_SHADER
	mat.set_shader_parameter("aspect", reach * 2.0 / height)
	mat.set_shader_parameter("seed", randf() * 50.0)
	mat.set_shader_parameter("reveal", 1.12)
	mat.set_shader_parameter("strength", 0.0)
	var flames := ColorRect.new()
	flames.material = mat
	flames.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flames.position = Vector2(-reach, -height)
	flames.size = Vector2(reach * 2.0, height)
	ground.add_child(flames)
	ground.set_meta("flames", mat)
	# Flaring up as the fuel catches, then settling into a steady burn.
	var catch: Tween = ground.create_tween()
	catch.tween_method(func(v: float) -> void: mat.set_shader_parameter("strength", v), 0.0, 1.0, 0.25)
	catch.tween_method(func(v: float) -> void: mat.set_shader_parameter("strength", v), 1.0, 0.85, 0.6)

	var embers := CPUParticles2D.new()
	embers.amount = 26
	embers.lifetime = 1.6
	embers.texture = VoidReachFX._dot()
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(reach, 6.0)
	embers.direction = Vector2(0.0, -1.0)
	embers.spread = 25.0
	embers.gravity = Vector2(0.0, -25.0)
	embers.initial_velocity_min = 40.0
	embers.initial_velocity_max = 110.0
	embers.scale_amount_min = 0.4
	embers.scale_amount_max = 0.85
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.1, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(HOT, 0.0), Color(1.0, 0.8, 0.35, 1.0), Color(FIRE, 0.8), Color(DEEP, 0.0)])
	embers.color_ramp = ramp
	embers.material = VoidReachFX._additive()
	ground.add_child(embers)
	embers.emitting = true
	ground.set_meta("embers", embers)
	return ground


## The fuel burns out: the flames gutter down and the ground fades.
static func end_ground(ground: Variant) -> void:
	if not (ground is Node2D) or not is_instance_valid(ground):
		return
	AudioManager.stop_loop(ground.get_meta("fire_loop", null), 0.7)
	var embers: Variant = ground.get_meta("embers", null)
	if is_instance_valid(embers):
		embers.emitting = false
	var mat: ShaderMaterial = ground.get_meta("flames", null)
	var out: Tween = ground.create_tween()
	if mat != null:
		out.tween_method(func(v: float) -> void: mat.set_shader_parameter("strength", v), 0.85, 0.0, 0.5)
	out.parallel().tween_property(ground, "modulate:a", 0.0, 0.7)
	out.tween_callback(ground.queue_free)
