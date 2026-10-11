class_name KissHeartsFX
extends Node2D

## Purely cosmetic: the blown kiss that opens Raze's Kiss the Wastes. A
## stream of small glowing ember hearts leaves her lips and drifts forward and
## up in front of her face - wobbling, swelling and fading as they float
## away - before the barrage follows (battle.gd times that against
## BLOW_TIME). They go the way she is FACING, not toward the target: this
## is a flourish, the shot comes after it. Played from either side.

const HEARTS := 6
const GAP := 0.11
const FLIGHT := Vector2(0.7, 0.9)
## When the kiss is over and a beat has passed - what the caller waits for
## before the barrage's own first shot.
const PAUSE := 0.4        # a beat of stillness after the last heart, before the shot
const BLOW_TIME := GAP * float(HEARTS - 1) + 0.9 + PAUSE

const PINK := Color(1.0, 0.45, 0.12)   # ember orange
const HOT := Color(1.0, 0.3, 0.06)
const CORE := Color(1.0, 0.9, 0.6)

var _from: Vector2
var _direction := 1
var _scale := 270.0           # the blower's height, in px - everything sizes off it
var _age := 0.0
var _hearts: Array[Dictionary] = []
var _glow: Node2D


## `from`: her lips (global); `direction`: +1 right, -1 left (the way she
## faces); `hero_height`: her on-screen height in px.
static func play(host: Node, from: Vector2, direction: int, hero_height: float) -> void:
	var fx := KissHeartsFX.new()
	fx._from = from
	fx._direction = 1 if direction >= 0 else -1
	fx._scale = maxf(hero_height, 120.0)
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in HEARTS:
		_hearts.append({
			"delay": float(i) * GAP,
			"time": rng.randf_range(FLIGHT.x, FLIGHT.y),
			# Where it ends up: forward and up from her lips.
			"end": Vector2(float(_direction) * rng.randf_range(0.5, 0.95), -rng.randf_range(0.3, 0.75)) * _scale,
			"wobble": rng.randf_range(0.03, 0.07) * _scale,
			"wobble_freq": rng.randf_range(6.0, 10.0),
			"phase": rng.randf() * TAU,
			"size": rng.randf_range(0.05, 0.08) * _scale,
			"tilt": rng.randf_range(-0.4, 0.4),
		})

	# A glow under the hearts, additive so it burns against the sky.
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)

	# A puff of sparkles at the lips as the kiss leaves.
	var puff := CPUParticles2D.new()
	puff.position = _from
	puff.one_shot = true
	puff.amount = 18
	puff.lifetime = 0.5
	puff.explosiveness = 0.9
	puff.texture = VoidReachFX._dot()
	puff.direction = Vector2(float(_direction), -0.6)
	puff.spread = 45.0
	puff.initial_velocity_min = 50.0
	puff.initial_velocity_max = 150.0
	puff.damping_min = 90.0
	puff.damping_max = 170.0
	puff.scale_amount_min = 1.0
	puff.scale_amount_max = 2.2
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(CORE, 0.95), Color(PINK, 0.85), Color(HOT, 0.0)])
	puff.color_ramp = ramp
	puff.material = VoidReachFX._additive()
	add_child(puff)
	puff.emitting = true


func _process(delta: float) -> void:
	_age += delta
	if _age >= GAP * float(HEARTS) + FLIGHT.y + 0.1:
		queue_free()
		return
	queue_redraw()
	_glow.queue_redraw()


## Where a heart is, and how visible, `t` (0..1) of the way through its
## own flight.
func _place(h: Dictionary, t: float) -> Vector2:
	var e := 1.0 - pow(1.0 - t, 2.0)             # leaves quickly, drifts to a stop
	var end: Vector2 = h["end"]
	var pos := _from + end * e
	# A lazy sway across its path as it floats.
	pos.x += float(h["wobble"]) * sin(t * float(h["wobble_freq"]) + float(h["phase"]))
	return pos


func _fade(t: float) -> float:
	return smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.65, 1.0, t))


func _swell(h: Dictionary, t: float) -> float:
	return float(h["size"]) * (0.35 + 0.65 * smoothstep(0.0, 0.35, t))


func _draw_glow() -> void:
	for h in _hearts:
		var t: float = (_age - float(h["delay"])) / float(h["time"])
		if t <= 0.0 or t >= 1.0:
			continue
		var pos := _place(h, t)
		var s := _swell(h, t)
		var fade := _fade(t)
		_glow.draw_circle(pos, s * 2.6, Color(HOT, 0.18 * fade))
		_glow.draw_circle(pos, s * 1.6, Color(PINK, 0.22 * fade))


func _draw() -> void:
	for h in _hearts:
		var t: float = (_age - float(h["delay"])) / float(h["time"])
		if t <= 0.0 or t >= 1.0:
			continue
		var pos := _place(h, t)
		var s := _swell(h, t)
		var fade := _fade(t)
		var tilt: float = float(h["tilt"]) + 0.25 * sin(t * 5.0 + float(h["phase"]))
		var pts := _heart(pos, s, tilt)
		draw_colored_polygon(pts, Color(PINK, 0.95 * fade))
		draw_polyline(_closed(pts), Color(CORE, 0.8 * fade), 2.0, true)
		draw_colored_polygon(_heart(pos + Vector2(-s * 0.15, -s * 0.12), s * 0.4, tilt), Color(CORE, 0.65 * fade))


func _heart(center: Vector2, size: float, tilt: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 32:
		var a := TAU * float(i) / 32.0
		var x := 16.0 * pow(sin(a), 3.0)
		var y := -(13.0 * cos(a) - 5.0 * cos(2.0 * a) - 2.0 * cos(3.0 * a) - cos(4.0 * a))
		pts.append(center + (Vector2(x, y) / 17.0 * size).rotated(tilt))
	return pts


func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var out := pts.duplicate()
	out.append(pts[0])
	return out
