class_name FrostTempestFX
extends Node2D

## Purely cosmetic: Frost Daughter's ultimate, The Frost Tempest, for as
## long as it lasts.
##
##   - her eyes and the sigil on her forehead burn with cold light
##   - she rises off the ground and hovers there, gently bobbing
##     (through her CreatureAnimator's shader - her node never moves)
##   - a tornado of snow, ice shards and wind wheels round her, as wide
##     on the ground as the skill's radius; the half behind her is drawn
##     under her art (show_behind_parent), the half in front over it
##   - frost spreads on the ground beneath the storm
## When it ends she settles back down and the storm winds away.
##
## Added as a child of the unit's node (so it follows it and is freed
## with it). battle.gd drives it with attach()/release().

const NODE_NAME := "FrostTempestFX"
const RISE_TIME := 0.7
const END_TIME := 0.8
const HOVER_HEIGHT := 0.1     # of the unit's height
const BOB := 0.018             # of the unit's height
const STREAKS := 40
const FLAKES := 160
const SHARDS := 14
const FLATTEN := 0.3           # the storm's circles, seen from the side

# Eyes and forehead sigil on Frost Daughter.png, as UV fractions.
const GLOW_SPOTS := [
	{"uv": Vector2(0.599, 0.143), "r": 0.012},
	{"uv": Vector2(0.647, 0.138), "r": 0.012},
	{"uv": Vector2(0.622, 0.111), "r": 0.016},
]

const SNOW := Color(0.94, 0.97, 1.0)
const ICE := Color(0.62, 0.84, 1.0)
const DEEP := Color(0.35, 0.55, 0.9)
const GLOW := Color(0.55, 0.85, 1.0)

var _target: TextureRect
var _back: Node2D
var _glow: Node2D
var radius_px := 256.0
var _age := 0.0
var _strength := 0.0          # 0..1, ramps in and out
var _ending := false
var _end_t := 0.0
var _streaks: Array[Dictionary] = []
var _flakes: Array[Dictionary] = []
var _shards: Array[Dictionary] = []


## Starts the tempest on `node` (or just updates its radius if already on).
static func attach(node: TextureRect, p_radius_px: float) -> void:
	var fx := node.get_node_or_null(NODE_NAME) as FrostTempestFX
	if fx != null:
		fx.radius_px = p_radius_px
		return
	fx = FrostTempestFX.new()
	fx.name = NODE_NAME
	fx._target = node
	fx.radius_px = p_radius_px
	node.add_child(fx)


static func release(node: Variant) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var fx := (node as Control).get_node_or_null(NODE_NAME) as FrostTempestFX
	if fx != null:
		fx._start_end()


func _ready() -> void:
	_back = Node2D.new()
	_back.show_behind_parent = true
	_back.draw.connect(_draw_layer.bind(false))
	_target.add_child(_back)
	_glow = Node2D.new()
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = m
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	for i in STREAKS:
		_streaks.append({"h": randf(), "ang": randf() * TAU, "len": randf_range(0.5, 1.1), "speed": randf_range(2.2, 3.4), "w": randf_range(1.5, 3.5)})
	for i in FLAKES:
		_flakes.append({"h": randf(), "ang": randf() * TAU, "speed": randf_range(2.5, 4.5), "size": randf_range(1.2, 3.0), "rise": randf_range(0.05, 0.25)})
	for i in SHARDS:
		_shards.append({"h": randf_range(0.1, 0.9), "ang": randf() * TAU, "speed": randf_range(1.8, 2.8), "size": randf_range(4.0, 8.0), "spin": randf() * TAU})


func _exit_tree() -> void:
	if is_instance_valid(_back):
		_back.queue_free()
	var animator := CreatureAnimator.of(_target)
	if animator != null:
		animator.set_hover(0.0)


func _start_end() -> void:
	if _ending:
		return
	_ending = true
	name = NODE_NAME + "Ending"


func _process(delta: float) -> void:
	_age += delta
	if _ending:
		_end_t += delta / END_TIME
		_strength = 1.0 - smoothstep(0.0, 1.0, _end_t)
		if _end_t >= 1.0:
			queue_free()
			return
	else:
		_strength = smoothstep(0.0, 1.0, _age / RISE_TIME)
	for s in _streaks:
		s.ang += s.speed * delta
	for f in _flakes:
		f.ang += f.speed * delta
		f.h = fmod(f.h + f.rise * delta, 1.0)
	for s in _shards:
		s.ang += s.speed * delta
		s.spin += 5.0 * delta
	var animator := CreatureAnimator.of(_target)
	if animator != null:
		animator.set_hover(_lift())
	queue_redraw()
	_back.queue_redraw()
	_glow.queue_redraw()


func _lift() -> float:
	var h := _target.size.y
	return _strength * (HOVER_HEIGHT * h + sin(_age * 1.8) * BOB * h)


# --- the storm ------------------------------------------------------------

func _feet() -> Vector2:
	return Vector2(_target.size.x * 0.5, _target.size.y * 0.97)


## The funnel: its radius at height `h` (0 = ground .. 1 = top), a little
## narrower at the ground, flaring out towards the top.
func _ring_radius(h: float) -> float:
	return radius_px * lerpf(0.82, 1.08, h) * (0.6 + 0.4 * _strength)


func _height() -> float:
	return _target.size.y * 1.35


## Point on the storm at angle `ang` and height `h`, and whether it's on
## the near (front) side.
func _storm_point(ang: float, h: float) -> Array:
	var sway := sin(_age * 1.1 + h * 3.0) * radius_px * 0.04
	var c := _feet() + Vector2(sway, -h * _height())
	var r := _ring_radius(h)
	return [c + Vector2(cos(ang) * r, sin(ang) * r * FLATTEN), sin(ang) > 0.0]


func _draw() -> void:
	_draw_layer(true)


func _draw_layer(front: bool) -> void:
	var canvas: CanvasItem = self if front else _back
	if _target == null or _strength <= 0.0:
		return
	var a := _strength
	# Frost on the ground under the storm (behind the unit).
	if not front:
		canvas.draw_set_transform(_feet(), 0.0, Vector2(1.0, FLATTEN))
		canvas.draw_circle(Vector2.ZERO, radius_px, Color(ICE, 0.1 * a))
		canvas.draw_circle(Vector2.ZERO, radius_px * 0.7, Color(SNOW, 0.08 * a))
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Faint walls of blowing snow: a few translucent bands wheeling round.
	# (Angles 0..PI are the near half of each ring, PI..TAU the far half.)
	for band in 5:
		var h0 := float(band) / 5.0 + 0.1
		var pts := PackedVector2Array()
		var steps := 24
		var from := 0.0 if front else PI
		for i in steps + 1:
			var p: Array = _storm_point(from + PI * float(i) / steps, h0)
			pts.append(p[0])
		var pulse := 0.75 + 0.25 * sin(_age * 3.0 + band * 1.7)
		canvas.draw_polyline(pts, Color(SNOW, (0.24 if front else 0.16) * a * pulse), 14.0, true)
		canvas.draw_polyline(pts, Color(ICE, (0.18 if front else 0.12) * a * pulse), 4.0, true)
	# Wind streaks: short arcs wheeling round the funnel.
	for s in _streaks:
		var pts := PackedVector2Array()
		var n := 8
		var on_side := 0
		for i in n:
			var ang: float = s.ang - s.len * float(i) / n
			var p: Array = _storm_point(ang, s.h)
			if p[1] == front:
				on_side += 1
			pts.append(p[0])
		if on_side < n / 2:
			continue
		canvas.draw_polyline(pts, Color(SNOW, (0.8 if front else 0.45) * a), s.w, true)
	# Snowflakes and ice shards swept round.
	for f in _flakes:
		var p: Array = _storm_point(f.ang, f.h)
		if p[1] != front:
			continue
		canvas.draw_circle(p[0], f.size, Color(SNOW, (0.85 if front else 0.45) * a))
	for s in _shards:
		var p: Array = _storm_point(s.ang, s.h)
		if p[1] != front:
			continue
		var c: Vector2 = p[0]
		var r: float = s.size
		canvas.draw_colored_polygon(PackedVector2Array([
			c + Vector2.from_angle(s.spin) * r,
			c + Vector2.from_angle(s.spin + 2.4) * r * 0.45,
			c + Vector2.from_angle(s.spin + PI) * r * 0.8,
			c + Vector2.from_angle(s.spin - 2.4) * r * 0.45]), Color(ICE if front else DEEP, (0.9 if front else 0.5) * a))


# --- the glow in her eyes and sigil ---------------------------------------

func _draw_glow() -> void:
	if _target == null or _strength <= 0.0:
		return
	var size := _target.size
	var lift := Vector2(0.0, -_lift())
	for g in GLOW_SPOTS:
		var uv: Vector2 = g.uv
		if _target.flip_h:
			uv.x = 1.0 - uv.x
		var c := uv * size + lift
		var r: float = g.r * size.y
		var flick := 0.9 + 0.1 * sin(_age * 7.0 + uv.x * 40.0)
		_glow.draw_circle(c, r * 1.4, Color(GLOW, 0.22 * _strength * flick))
		_glow.draw_circle(c, r * 0.7, Color(GLOW, 0.45 * _strength * flick))
		_glow.draw_circle(c, r * 0.32, Color(SNOW, 0.8 * _strength * flick))
