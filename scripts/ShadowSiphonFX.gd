class_name ShadowSiphonFX
extends Node2D

## Purely cosmetic: Nightshroud's Mind Devourer - a shadow torn out of the
## target that streaks to the hero along an arc, dragging a tail of dark
## smoke, and sinks into him in a puff of darkness.
##
## The damage and healing have already happened by the time this plays;
## `on_arrive` fires when the shadow lands (used for the hero's reaction).

const FLIGHT_TIME := 0.5
const LINGER_TIME := 0.3
const TAIL_PUFFS := 22
const SHADOW := Color(0.02, 0.0, 0.05)
const BLEED := Color(0.5, 0.28, 0.85)

var _from: Vector2
var _to: Vector2
var _ctrl: Vector2
var _size := 46.0
var _on_arrive: Callable
var _age := 0.0
var _arrived := false
var _soft: GradientTexture2D
## Recent head positions, newest last, sampled every frame.
var _trail: Array[Vector2] = []


## Streaks a shadow from `from` to `to` (global positions) under `host`.
static func play(host: Node, from: Vector2, to: Vector2, on_arrive: Callable = Callable()) -> void:
	var fx := ShadowSiphonFX.new()
	fx._from = from
	fx._to = to
	var travel := to - from
	var normal := Vector2(-travel.y, travel.x).normalized() if travel.length() > 0.001 else Vector2.UP
	# Bulge upward-ish so it reads as being pulled out and lifted away.
	if normal.y > 0.0:
		normal = -normal
	fx._ctrl = (from + to) * 0.5 + normal * maxf(40.0, travel.length() * 0.3)
	fx._on_arrive = on_arrive
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.4), Color(1, 1, 1, 0)])
	_soft = GradientTexture2D.new()
	_soft.gradient = g
	_soft.fill = GradientTexture2D.FILL_RADIAL
	_soft.fill_from = Vector2(0.5, 0.5)
	_soft.fill_to = Vector2(1.0, 0.5)
	_soft.width = 64
	_soft.height = 64


func _head(p: float) -> Vector2:
	var a := _from.lerp(_ctrl, p)
	var b := _ctrl.lerp(_to, p)
	return a.lerp(b, p)


func _process(delta: float) -> void:
	_age += delta
	var p := clampf(_age / FLIGHT_TIME, 0.0, 1.0)
	# Slow to peel off the target, then snapping toward the hero.
	var eased := p * p * (3.0 - 2.0 * p)
	if p < 1.0:
		_trail.append(_head(eased))
		if _trail.size() > TAIL_PUFFS:
			_trail.pop_front()
	elif not _arrived:
		_arrived = true
		if _on_arrive.is_valid():
			_on_arrive.call()
	elif _trail.size() > 0:
		_trail.pop_front()
	if _age >= FLIGHT_TIME + LINGER_TIME:
		queue_free()
		return
	queue_redraw()


func _puff(pos: Vector2, size: float, alpha: float) -> void:
	draw_texture_rect(_soft, Rect2(pos - Vector2.ONE * size * 0.5, Vector2.ONE * size), false, Color(SHADOW, alpha))


func _draw() -> void:
	var p := clampf(_age / FLIGHT_TIME, 0.0, 1.0)
	var t := _age
	# The tail: puffs left behind, shrinking and thinning toward its end,
	# wobbling sideways so it ripples like smoke.
	var n := _trail.size()
	for i in n:
		var k := float(i + 1) / float(maxi(n, 1))
		var wob := Vector2(sin(t * 18.0 + i * 0.9), cos(t * 15.0 + i * 1.3)) * 5.0 * (1.0 - k)
		_puff(_trail[i] + wob, _size * (0.35 + 0.65 * k), 0.55 * k)

	if p < 1.0:
		var head := _trail[n - 1] if n > 0 else _from
		var pulse := 1.0 + 0.1 * sin(t * 22.0)
		# A faint violet bleed, then the dark body, with a few licking wisps.
		draw_texture_rect(_soft, Rect2(head - Vector2.ONE * _size * 0.9, Vector2.ONE * _size * 1.8), false, Color(BLEED, 0.12))
		_puff(head, _size * 1.25 * pulse, 0.95)
		_puff(head, _size * 0.8 * pulse, 1.0)
		for w in 4:
			var ang := t * 9.0 + w * TAU / 4.0
			var tip := head + Vector2(cos(ang), sin(ang)) * _size * 0.55
			_puff(tip, _size * 0.4, 0.7)
	else:
		# Sinking into the hero: a ring of smoke that swells and thins out.
		var q := clampf((_age - FLIGHT_TIME) / LINGER_TIME, 0.0, 1.0)
		var r := _size * (0.6 + 1.6 * q)
		for i in 8:
			var ang := TAU * i / 8.0 + q * 1.5
			_puff(_to + Vector2(cos(ang), sin(ang)) * r * 0.5, _size * (1.0 - 0.4 * q), 0.7 * (1.0 - q))
