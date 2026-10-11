class_name ShotgunBlastFX
extends Node2D

## Purely cosmetic: Raze's normal attack ("attack_effect": "shotgun_blast").
## One lean shot - a small muzzle flash and puff of smoke, and a tight
## cluster of pellets that streak to the target and spark where they hit
## (`on_hit` fires then). Deliberately lighter and narrower than Double
## Trouble's two-barrel blast (see DoubleTroubleFX), so the two don't read
## alike.

const FLIGHT_TIME := 0.16
const FADE_TIME := 0.25
const PELLETS := 7
const SPREAD_DEGREES := 5.0

const CORE := Color(1.0, 0.96, 0.8)
const FLAME := Color(1.0, 0.58, 0.14)
const DEEP := Color(0.85, 0.22, 0.06)

var _from: Vector2
var _to: Vector2
var _on_hit: Callable
var _age := 0.0
var _hit := false
var _pellets: Array[Dictionary] = []


static func play(host: Node, from: Vector2, to: Vector2, on_hit: Callable = Callable()) -> void:
	var fx := ShotgunBlastFX.new()
	fx._from = from
	fx._to = to
	fx._on_hit = on_hit
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()
	# Reload first, then - the moment it ends - the shot: the flash, pellets
	# and the shot sound all wait for it, so they line up.
	var reload: float = AudioManager.event_length("reload")
	_age = -reload
	AudioManager.play_event("reload")
	get_tree().create_timer(reload).timeout.connect(func() -> void: AudioManager.play_event("raze_shoot"))
	# The shot is not playing yet, but a kill by this blow must wait for it.
	AudioManager.note_attack_sound("raze_shoot", reload + AudioManager.event_length("raze_shoot"))
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var dir := _to - _from
	var heading := dir.normalized() if dir.length() > 1.0 else Vector2.RIGHT
	for i in PELLETS:
		var angle := deg_to_rad(rng.randf_range(-SPREAD_DEGREES, SPREAD_DEGREES))
		# Each pellet converges on a point near the target's centre.
		var aim := _to + Vector2(rng.randf_range(-8.0, 8.0), rng.randf_range(-10.0, 10.0))
		_pellets.append({
			"dir": ((aim - _from).normalized()).rotated(angle * 0.4),
			"len": (aim - _from).length(),
			"speed": rng.randf_range(0.9, 1.1),
			"trail": rng.randf_range(14.0, 30.0),
			"width": rng.randf_range(1.6, 2.6),
		})

	var puff := CPUParticles2D.new()
	puff.position = _from
	puff.one_shot = true
	puff.amount = 16
	puff.lifetime = 0.25
	puff.explosiveness = 0.95
	puff.texture = VoidReachFX._dot()
	puff.direction = heading
	puff.spread = 18.0
	puff.initial_velocity_min = 90.0
	puff.initial_velocity_max = 190.0
	puff.damping_min = 300.0
	puff.damping_max = 420.0
	puff.scale_amount_min = 1.2
	puff.scale_amount_max = 2.4
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	ramp.colors = PackedColorArray([Color(CORE, 0.9), Color(FLAME, 0.7), Color(DEEP, 0.0)])
	puff.color_ramp = ramp
	puff.material = VoidReachFX._additive()
	add_child(puff)
	get_tree().create_timer(reload).timeout.connect(func() -> void:
		if is_instance_valid(puff):
			puff.emitting = true)


func _process(delta: float) -> void:
	_age += delta
	if not _hit and _age >= FLIGHT_TIME:
		_hit = true
		_impact()
		if _on_hit.is_valid():
			_on_hit.call()
	if _age >= FLIGHT_TIME + FADE_TIME + 0.2:
		queue_free()
		return
	queue_redraw()


func _impact() -> void:
	var burst := CPUParticles2D.new()
	burst.position = _to
	burst.one_shot = true
	burst.amount = 18
	burst.lifetime = 0.35
	burst.explosiveness = 0.95
	burst.texture = VoidReachFX._dot()
	burst.spread = 180.0
	burst.gravity = Vector2(0.0, 160.0)
	burst.initial_velocity_min = 60.0
	burst.initial_velocity_max = 170.0
	burst.damping_min = 80.0
	burst.damping_max = 160.0
	burst.scale_amount_min = 0.8
	burst.scale_amount_max = 1.8
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(1.0, 0.9, 0.5, 0.95), Color(FLAME, 0.8), Color(DEEP, 0.0)])
	burst.color_ramp = ramp
	burst.material = VoidReachFX._additive()
	add_child(burst)
	burst.emitting = true


func _draw() -> void:
	if _age < 0.0:
		return   # still reloading
	var dir := (_to - _from).normalized()
	# Muzzle flash.
	if _age < 0.1:
		var k := 1.0 - _age / 0.1
		var side := dir.orthogonal()
		var len := 46.0 * (0.6 + 0.4 * k)
		var half := 11.0 * k
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.55 + side * half, _from + dir * len, _from + dir * len * 0.55 - side * half]), Color(FLAME, 0.7 * k))
		draw_colored_polygon(PackedVector2Array([_from, _from + dir * len * 0.4 + side * half * 0.4, _from + dir * len * 0.6, _from + dir * len * 0.4 - side * half * 0.4]), Color(CORE, 0.9 * k))
		draw_circle(_from, 15.0 * k, Color(1.0, 0.85, 0.5, 0.5 * k))
	# Pellets.
	for p in _pellets:
		var t := clampf(_age / (FLIGHT_TIME / float(p["speed"])), 0.0, 1.0)
		if t >= 1.0:
			continue
		var travelled: float = float(p["len"]) * t
		var head: Vector2 = _from + Vector2(p["dir"]) * travelled
		var tail: Vector2 = head - Vector2(p["dir"]) * minf(float(p["trail"]), travelled)
		draw_line(tail, head, Color(FLAME, 0.55), float(p["width"]), true)
		draw_line(head - Vector2(p["dir"]) * minf(float(p["trail"]) * 0.4, travelled), head, Color(CORE, 0.9), float(p["width"]) * 0.6, true)
	# Flash where they land.
	if _hit:
		var hk := 1.0 - clampf((_age - FLIGHT_TIME) / 0.15, 0.0, 1.0)
		if hk > 0.0:
			draw_circle(_to, 20.0 * (1.5 - hk * 0.5), Color(1.0, 0.8, 0.45, 0.5 * hk))
