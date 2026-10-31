class_name DarkHaloFX
extends Node2D

## Purely cosmetic: Nightshroud's normal attack - a halo of shadow that
## drops over the target's head. Not a crisp ring but a loose band of
## living darkness: soft black smoke circling the head, torn tendrils
## curling up off it, and the faintest violet bleed where it is thickest.
## It sinks onto the head from above as it thickens, the target flinches as
## it lands, it swells and churns once, then thins out, rising and
## unravelling.
##
## A hero uses it by naming it in its GameManager definition
## ("attack_effect": "dark_halo") - see battle.gd's _play_hero_attack_effect().

const DROP_TIME := 0.22
const HOLD_TIME := 0.34
const FADE_TIME := 0.38

# How far above the head the shadow starts, and how far it rises on the
# way out, as a share of its own width.
const START_LIFT := 0.7
const END_LIFT := 0.45
# The band is seen from slightly above, so it's squashed to this height.
const TILT := 0.32

const SHADOW := Color(0.015, 0.0, 0.03)
const BLEED := Color(0.45, 0.25, 0.8)
# Smoke puffs around the band, and tendrils curling off it.
const PUFFS := 16
const TENDRILS := 9

var _head: Vector2
var _width := 100.0
var _on_hit: Callable
var _age := 0.0
var _hit_done := false
var _soft: GradientTexture2D
var _glow: Node2D
var _body: Node2D
## Per puff: its angle round the band, spin, size and flicker phase.
var _puffs: Array[Dictionary] = []
var _tendril_seeds: Array[float] = []


## Drops the shadow on `target`'s head (a battle sprite). `on_hit` fires
## the moment it lands.
static func play(host: Node, target: Control, on_hit: Callable = Callable()) -> void:
	var fx := DarkHaloFX.new()
	fx._head = target.global_position + target.size * Vector2(0.5, 0.06)
	fx._width = clampf(target.size.x * 0.45, 80.0, 170.0)
	fx._on_hit = on_hit
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

	for i in PUFFS:
		_puffs.append({
			"angle": TAU * float(i) / PUFFS + randf() * 0.3,
			"spin": randf_range(0.6, 1.6) * (1.0 if i % 2 == 0 else -0.6),
			"size": randf_range(0.28, 0.5),
			"phase": randf() * TAU,
		})
	for i in TENDRILS:
		_tendril_seeds.append(randf())

	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_bleed)
	add_child(_glow)
	# Added after the glow, so the shadow draws over its faint light.
	_body = Node2D.new()
	_body.draw.connect(_draw_shadow)
	add_child(_body)


func _process(delta: float) -> void:
	_age += delta
	if not _hit_done and _age >= DROP_TIME:
		_hit_done = true
		if _on_hit.is_valid():
			_on_hit.call()
	if _age >= DROP_TIME + HOLD_TIME + FADE_TIME:
		queue_free()
		return
	_glow.queue_redraw()
	_body.queue_redraw()


## Overall thickness: gathers as it drops, thins out as it rises.
func _alpha() -> float:
	var fade_start := DROP_TIME + HOLD_TIME
	if _age >= fade_start:
		var k := clampf((_age - fade_start) / FADE_TIME, 0.0, 1.0)
		return 1.0 - k * k
	return clampf(_age / (DROP_TIME * 0.7), 0.0, 1.0)


## Where the band's centre is: dropping from above onto the head, resting
## there, then rising again as it fades.
func _center() -> Vector2:
	if _age < DROP_TIME:
		var k := _age / DROP_TIME
		return _head - Vector2(0.0, _width * START_LIFT * (1.0 - k) * (1.0 - k))
	var fade_start := DROP_TIME + HOLD_TIME
	if _age >= fade_start:
		var k := clampf((_age - fade_start) / FADE_TIME, 0.0, 1.0)
		return _head - Vector2(0.0, _width * END_LIFT * k)
	return _head


## Swells once on landing and settles; a little wider while dropping.
func _scale() -> float:
	if _age < DROP_TIME:
		return lerpf(1.35, 1.0, _age / DROP_TIME)
	var since := _age - DROP_TIME
	return 1.0 + 0.14 * sin(since * 12.0) * exp(-since * 4.5)


## A point on the band at `angle` (before any spin), `radius` out.
func _on_band(c: Vector2, w: float, angle: float, radius: float = 0.5) -> Vector2:
	return c + Vector2(cos(angle) * w * radius, sin(angle) * w * radius * TILT)


func _draw_bleed() -> void:
	var a := _alpha()
	var c := _center()
	var w := _width * _scale()
	_glow.draw_set_transform(c, 0.0, Vector2(1.0, TILT))
	# A dim violet haze where the band is thickest - hardly there at all.
	_glow.draw_arc(Vector2.ZERO, w * 0.5, 0.0, TAU, 48, Color(BLEED, 0.07 * a), w * 0.4, true)
	_glow.draw_arc(Vector2.ZERO, w * 0.5, 0.0, TAU, 48, Color(BLEED, 0.09 * a), w * 0.14, true)
	_glow.draw_set_transform(Vector2.ZERO)


func _draw_shadow() -> void:
	var a := _alpha()
	var c := _center()
	var w := _width * _scale()
	var t := _age

	# A wide, soft base of darkness under everything.
	_body.draw_set_transform(c, 0.0, Vector2(1.0, TILT))
	_body.draw_arc(Vector2.ZERO, w * 0.5, 0.0, TAU, 48, Color(SHADOW, 0.35 * a), w * 0.34, true)
	_body.draw_set_transform(Vector2.ZERO)

	# Smoke circling the head: overlapping soft puffs that drift round the
	# band, breathing in and out, so it never reads as a hard ring.
	for puff in _puffs:
		var angle: float = puff["angle"] + t * puff["spin"]
		var flicker: float = 0.75 + 0.25 * sin(t * 9.0 + puff["phase"])
		var size: float = w * puff["size"] * (0.9 + 0.3 * flicker)
		var pos := _on_band(c, w, angle, 0.5 + 0.05 * sin(t * 6.0 + puff["phase"]))
		_body.draw_texture_rect(_soft, Rect2(pos - Vector2.ONE * size * 0.5, Vector2.ONE * size), false, Color(SHADOW, 0.6 * a * flicker))

	# Tendrils torn off the band, curling up and unravelling as they rise.
	if _age >= DROP_TIME * 0.7:
		var rt := _age - DROP_TIME * 0.7
		for i in _tendril_seeds.size():
			var sd := _tendril_seeds[i]
			var angle := TAU * (float(i) / _tendril_seeds.size() + sd * 0.08) + t * 0.5
			var base := _on_band(c, w, angle)
			var rise := fmod(rt * (0.7 + sd * 0.7) + sd, 1.0)
			var points := PackedVector2Array()
			for s in 7:
				var k := float(s) / 6.0 * rise
				points.append(base + Vector2(sin(k * 7.0 + sd * 9.0 + t * 3.0) * w * 0.07 * k * 3.0, -k * w * 0.7))
			var fade := a * (1.0 - rise) * 0.8
			_body.draw_polyline(points, Color(SHADOW, fade * 0.5), maxf(w * 0.07 * (1.0 - rise), 2.0), true)
			_body.draw_polyline(points, Color(SHADOW, fade), maxf(w * 0.03 * (1.0 - rise), 1.0), true)
