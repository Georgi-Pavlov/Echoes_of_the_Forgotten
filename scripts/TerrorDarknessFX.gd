class_name TerrorDarknessFX
extends Node2D

## Purely cosmetic: Nightshroud's The Terror Within - the air around the
## victim goes black and pale eyes open in the dark, watching, blinking and
## closing again. Plays for `duration` seconds alongside the "voices" sound.

const EYE_PAIRS := 9
const EYE_COLOR := Color(0.88, 0.92, 1.0)
const FADE_IN := 0.35
const FADE_OUT := 0.5

var _center: Vector2
var _radius := 260.0
var _duration := 2.0
var _age := 0.0
var _soft: GradientTexture2D
var _dark: GradientTexture2D
## Per eye pair: where (angle/distance as shares of the radius), when it
## opens, how long it stays, its size and how it tilts.
var _eyes: Array[Dictionary] = []


## Plunges the area round `center` (global position) into darkness under `host`.
static func play(host: Node, center: Vector2, radius: float = 260.0, duration: float = 2.0) -> void:
	var fx := TerrorDarknessFX.new()
	fx._center = center
	fx._radius = radius
	fx._duration = duration
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

	# The dark: black everywhere but the victim's own middle, which stays
	# dimly visible, thinning to nothing at the edge.
	var d := Gradient.new()
	d.offsets = PackedFloat32Array([0.0, 0.3, 0.65, 1.0])
	d.colors = PackedColorArray([
		Color(0.0, 0.0, 0.02, 0.5), Color(0.0, 0.0, 0.02, 0.88),
		Color(0.0, 0.0, 0.03, 0.7), Color(0.0, 0.0, 0.03, 0.0)])
	_dark = GradientTexture2D.new()
	_dark.gradient = d
	_dark.fill = GradientTexture2D.FILL_RADIAL
	_dark.fill_from = Vector2(0.5, 0.5)
	_dark.fill_to = Vector2(1.0, 0.5)
	_dark.width = 256
	_dark.height = 256

	for i in EYE_PAIRS:
		# Spread round the victim, never right on top of it.
		var angle := TAU * (float(i) + randf() * 0.7) / EYE_PAIRS
		_eyes.append({
			"angle": angle,
			"dist": randf_range(0.38, 0.85),
			"open": randf_range(0.2, _duration - 0.9),
			"stay": randf_range(0.5, 0.9),
			"size": randf_range(0.7, 1.3),
			"tilt": randf_range(-0.35, 0.35),
			"blink": randf() * TAU,
		})


func _process(delta: float) -> void:
	_age += delta
	if _age >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var envelope := minf(_age / FADE_IN, 1.0) * minf((_duration - _age) / FADE_OUT, 1.0)
	envelope = clampf(envelope, 0.0, 1.0)

	# The darkness: a little uneasy, swelling and ebbing.
	var swell := 1.0 + 0.04 * sin(_age * 5.0)
	var size := _radius * 2.0 * swell
	draw_texture_rect(_dark, Rect2(_center - Vector2.ONE * size * 0.5, Vector2.ONE * size), false, Color(1, 1, 1, envelope))

	# The eyes: each opens, blinks once or twice, then closes.
	for e in _eyes:
		var t: float = _age - e["open"]
		if t < 0.0 or t > e["stay"]:
			continue
		var life: float = t / e["stay"]
		var lid := sin(life * PI)
		# A blink: the eyes narrow to a slit for a moment.
		var blink := 1.0 - 0.9 * pow(maxf(0.0, sin(life * TAU * 1.5 + e["blink"])), 12.0)
		var open: float = clampf(lid * 2.0, 0.0, 1.0) * blink
		if open <= 0.02:
			continue
		var pos: Vector2 = _center + Vector2(cos(e["angle"]), sin(e["angle"])) * _radius * e["dist"]
		var s: float = e["size"]
		var gap := 9.0 * s
		var tilt: float = e["tilt"]
		for side: float in [-1.0, 1.0]:
			var at: Vector2 = pos + Vector2(cos(tilt), sin(tilt)) * gap * side
			# A pale glow, then the small white eye - a slit when it blinks.
			var glow := 22.0 * s
			draw_texture_rect(_soft, Rect2(at - Vector2.ONE * glow * 0.5, Vector2.ONE * glow), false, Color(EYE_COLOR, 0.35 * envelope * open))
			draw_set_transform(at, tilt, Vector2(1.0, maxf(open, 0.12)))
			draw_circle(Vector2.ZERO, 3.2 * s, Color(EYE_COLOR, envelope * open))
			draw_set_transform(Vector2.ZERO)
