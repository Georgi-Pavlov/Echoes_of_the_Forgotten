class_name FrostRavenFX
extends Node2D

## Purely cosmetic: Frost Daughter's normal attack ("attack_effect":
## "frost_raven"). The ice crystals in her raised hand flare, and a
## ghostly raven of snow and ice bursts out of them, climbs, then swoops
## down onto the target on beating wings, trailing snow - and explodes
## into a swirl of flakes as it strikes. `on_hit` fires at that moment.
##
## Drawn by this node (the raven's body, wings and trail) plus an
## additive child for its cold glow.

const FLIGHT_TIME := 0.46
const BURST_TIME := 0.55
const FLAP_SPEED := 26.0
const TRAIL := 16

const SNOW := Color(0.94, 0.97, 1.0)
const ICE := Color(0.62, 0.84, 1.0)
const DEEP := Color(0.28, 0.46, 0.82)
const GLOW := Color(0.55, 0.85, 1.0)

var _from: Vector2
var _to: Vector2
var _ctrl: Vector2         # the swoop's arc: up and over, then down onto the target
var _on_hit: Callable
var _size := 28.0
var _age := 0.0
var _hit := false
var _pos := Vector2.ZERO
var _dir := Vector2.RIGHT
var _trail: Array[Vector2] = []
var _flakes: Array[Dictionary] = []
var _glow: Node2D


static func play(host: Node, from: Vector2, to: Vector2, on_hit: Callable = Callable()) -> void:
	var fx := FrostRavenFX.new()
	fx._from = from
	fx._to = to
	fx._on_hit = on_hit
	var dist := from.distance_to(to)
	fx._size = clampf(dist * 0.08, 30.0, 46.0)
	fx._ctrl = (from + to) * 0.5 + Vector2(0.0, -clampf(dist * 0.35, 60.0, 170.0))
	host.add_child(fx)
	fx.global_position = Vector2.ZERO
	fx._pos = from


func _ready() -> void:
	_glow = Node2D.new()
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = m
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	move_child(_glow, 0)


func _process(delta: float) -> void:
	_age += delta
	if _age < FLIGHT_TIME:
		# eases in slowly out of her hand, then dives faster and faster
		var u := _age / FLIGHT_TIME
		var t := u * u * (1.6 - 0.6 * u)
		var p := _bezier(t)
		_dir = (_bezier(minf(t + 0.02, 1.0)) - p).normalized()
		_pos = p
		_trail.append(p)
		if _trail.size() > TRAIL:
			_trail.remove_at(0)
		if randf() < 0.8:
			_flakes.append({"pos": p, "vel": Vector2(randf_range(-30, 30), randf_range(-20, 30)), "age": 0.0, "life": randf_range(0.3, 0.5), "size": randf_range(1.2, 2.4)})
	elif not _hit:
		_hit = true
		_pos = _to
		for i in 34:
			var a := randf() * TAU
			var sp := randf_range(60.0, 220.0)
			# spun round the impact, like a small whirl of snow
			_flakes.append({"pos": _to, "vel": Vector2.from_angle(a) * sp + Vector2.from_angle(a + PI * 0.5) * sp * 0.6,
				"age": 0.0, "life": randf_range(0.35, BURST_TIME), "size": randf_range(1.6, 3.6)})
		if _on_hit.is_valid():
			_on_hit.call()
	if _hit and not _trail.is_empty():
		_trail.remove_at(0)
	for f in _flakes:
		f.age += delta
		f.vel *= 1.0 - 3.0 * delta
		f.vel.y += 40.0 * delta
		f.pos += f.vel * delta
	_flakes = _flakes.filter(func(f): return f.age < f.life)
	if _hit and _flakes.is_empty() and _trail.is_empty():
		queue_free()
		return
	queue_redraw()
	_glow.queue_redraw()


func _bezier(t: float) -> Vector2:
	return _from.lerp(_ctrl, t).lerp(_ctrl.lerp(_to, t), t)


# --- drawing ------------------------------------------------------------

func _draw() -> void:
	for i in range(1, _trail.size()):
		var k := float(i) / _trail.size()
		draw_line(_trail[i - 1], _trail[i], Color(SNOW, 0.45 * k), maxf(1.0, _size * 0.22 * k), true)
	for f in _flakes:
		draw_circle(f.pos, f.size, Color(SNOW, 1.0 - f.age / f.life))
	if not _hit:
		_draw_raven()


## The raven, facing along _dir: a teardrop body with a hooked beak, a
## fanned tail, and two long ragged wings beating up and down.
func _draw_raven() -> void:
	var s := _size * (0.6 + 0.4 * smoothstep(0.0, 0.25, _age / FLIGHT_TIME))
	var flap := sin(_age * FLAP_SPEED)
	draw_set_transform(_pos, _dir.angle(), Vector2.ONE)
	# wings: from the shoulders, sweeping back, tips raised or lowered by
	# the beat (the far wing a little darker)
	for side in [-1.0, 1.0]:
		var tip := Vector2(-s * 0.55, side * s * (0.95 + 0.25 * flap * side))
		var mid := Vector2(-s * 0.05, side * s * (0.55 + 0.2 * flap * side))
		var wing := PackedVector2Array([
			Vector2(s * 0.15, side * s * 0.08), mid, tip,
			Vector2(-s * 0.4, side * s * 0.62), Vector2(-s * 0.5, side * s * 0.42),
			Vector2(-s * 0.3, side * s * 0.3), Vector2(-s * 0.35, side * s * 0.12)])
		draw_colored_polygon(wing, Color(ICE if side > 0.0 else DEEP, 0.82))
		var closed := wing.duplicate()
		closed.append(wing[0])
		draw_polyline(closed, Color(SNOW, 0.9), 1.4, true)
	# tail
	draw_colored_polygon(PackedVector2Array([
		Vector2(-s * 0.45, 0.0), Vector2(-s * 0.95, -s * 0.2), Vector2(-s * 0.85, 0.0), Vector2(-s * 0.95, s * 0.2)]),
		Color(ICE, 0.85))
	# body and head
	var body := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		body.append(Vector2(cos(a) * s * 0.5 - s * 0.05, sin(a) * s * 0.17))
	draw_colored_polygon(body, Color(SNOW, 0.95))
	draw_circle(Vector2(s * 0.42, 0.0), s * 0.14, Color(SNOW, 0.95))
	# beak and a cold eye
	draw_colored_polygon(PackedVector2Array([
		Vector2(s * 0.52, -s * 0.06), Vector2(s * 0.8, s * 0.02), Vector2(s * 0.52, s * 0.06)]), Color(DEEP, 0.95))
	draw_circle(Vector2(s * 0.45, -s * 0.04), s * 0.035, Color(0.1, 0.3, 0.7))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_glow() -> void:
	# her hand's crystals flare as the raven bursts out of them
	var flare := 1.0 - smoothstep(0.0, 0.3, _age)
	if flare > 0.0:
		_glow.draw_circle(_from, _size * 1.6, Color(GLOW, 0.35 * flare))
		_glow.draw_circle(_from, _size * 0.7, Color(SNOW, 0.6 * flare))
	if not _hit:
		_glow.draw_circle(_pos, _size * 1.1, Color(GLOW, 0.22))
	else:
		var u := clampf((_age - FLIGHT_TIME) / 0.3, 0.0, 1.0)
		if u < 1.0:
			_glow.draw_circle(_to, _size * (0.8 + 1.4 * u), Color(GLOW, 0.4 * (1.0 - u)))
