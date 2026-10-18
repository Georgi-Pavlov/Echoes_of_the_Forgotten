class_name HopeChargeFX
extends Node2D

## Purely cosmetic: the gathering before Solara's Hope of the Fallen is
## loosed. A faint golden glow wells up from her body and flows along a
## gentle curve to her bow in a stream of drifting motes, the bow itself
## brightening as it fills - then, with the charge full, the arrow is
## released (battle.gd waits HOLD seconds for it). Everything she has left
## of her lost world, poured into one shot.

const GOLD := Color(1.0, 0.78, 0.38)
const PALE := Color(1.0, 0.94, 0.8)
const MOTES := 18
const TAIL := 0.28                    # seconds the glow lingers after the charge

var _from: Vector2                    # her body (global)
var _to: Vector2                      # the bow (global)
var _duration := 0.6
var _age := 0.0
var _glow_tex: Texture2D
var _motes: Array[Dictionary] = []


## Plays the charge for `duration` seconds, flowing from `from` (her body)
## to `to` (her bow).
static func play(host: Node, from: Vector2, to: Vector2, duration: float) -> void:
	var fx := HopeChargeFX.new()
	fx._from = from
	fx._to = to
	fx._duration = maxf(duration, 0.2)
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	material = VoidReachFX._additive()
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.2, 0.5, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.16), Color(1, 1, 1, 0.0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 96
	t.height = 96
	_glow_tex = t
	for i in MOTES:
		_motes.append({
			"start": float(i) / float(MOTES) * _duration * 0.7,
			"travel": _duration * randf_range(0.34, 0.46),
			"lift": randf_range(18.0, 52.0),
			"wobble": randf_range(-10.0, 10.0),
			"size": randf_range(7.0, 15.0),
			"phase": randf() * TAU,
		})


func _process(delta: float) -> void:
	_age += delta
	if _age >= _duration + TAIL:
		queue_free()
		return
	queue_redraw()


## Point `t` (0..1) along the curve from her body to her bow, bowing up.
func _curve(t: float, lift: float, wobble: float) -> Vector2:
	var mid := (_from + _to) * 0.5 + Vector2(wobble, -lift)
	var a := _from.lerp(mid, t)
	var b := mid.lerp(_to, t)
	return a.lerp(b, t)


func _draw() -> void:
	var charge := clampf(_age / _duration, 0.0, 1.0)
	var fade := 1.0 - clampf((_age - _duration) / TAIL, 0.0, 1.0)

	# A faint ribbon along the path, brightening as the charge builds.
	var pts := PackedVector2Array()
	for i in 21:
		pts.append(_curve(float(i) / 20.0, 34.0, 0.0))
	draw_polyline(pts, Color(GOLD, 0.1 * charge * fade), 10.0, true)
	draw_polyline(pts, Color(PALE, 0.12 * charge * fade), 3.0, true)

	# The glow welling up at her body.
	var well := Vector2.ONE * (46.0 + 30.0 * sin(_age * 9.0)) * (0.4 + 0.6 * charge)
	draw_texture_rect(_glow_tex, Rect2(_from - well * 0.5, well), false, Color(GOLD, 0.35 * fade))

	# The motes drifting along it.
	for m in _motes:
		var t: float = (_age - float(m["start"])) / float(m["travel"])
		if t <= 0.0 or t >= 1.0:
			continue
		var p := _curve(t, float(m["lift"]), float(m["wobble"]))
		var a: float = sin(t * PI) * fade
		var s: float = float(m["size"]) * (0.7 + 0.3 * sin(_age * 12.0 + float(m["phase"])))
		draw_texture_rect(_glow_tex, Rect2(p - Vector2.ONE * s * 1.8, Vector2.ONE * s * 3.6), false, Color(GOLD, 0.45 * a))
		draw_texture_rect(_glow_tex, Rect2(p - Vector2.ONE * s * 0.6, Vector2.ONE * s * 1.2), false, Color(PALE, 0.9 * a))

	# The bow filling: its glow swells and flickers, brightest at the release.
	var swell := (24.0 + 62.0 * charge) * (1.0 + 0.08 * sin(_age * 17.0))
	var bow := Vector2.ONE * swell * 2.0
	draw_texture_rect(_glow_tex, Rect2(_to - bow * 0.5, bow), false, Color(GOLD, (0.25 + 0.5 * charge) * fade))
	var core := Vector2.ONE * swell * 0.7
	draw_texture_rect(_glow_tex, Rect2(_to - core * 0.5, core), false, Color(PALE, (0.2 + 0.6 * charge) * fade))
