class_name BloomHazardFX
extends Control
## The Blackbloom's zone hazard, drawn over one battlefield column (see
## TERRAIN_DESIGN.md). Two stages:
##   show_hint()  - a dark purple lotus bud rises out of the ground
##                  (visual only, nothing happens yet).
##   bloom()      - the lotus opens and releases a purple mist that fills
##                  the whole column.
##   fade_out()   - the mist thins out and the lotus sinks away.
## Purely cosmetic: the gameplay rules live in battle.gd (_hazard_*).

const MIST_COLOR := Color(0.62, 0.3, 0.85, 1.0)
const MIST_PUFF_COUNT := 14
const CORE_COLOR := Color(0.95, 0.78, 1.0, 1.0)
## Lotus petal rows, drawn back to front: how many petals, how far the row
## fans out to each side when fully open (radians), its length relative to
## the biggest row, and how much darker (-) or lighter (+) than the mist
## colour it is (dark outside, lighter in the middle).
const PETAL_ROWS := [
	{"count": 6, "fan": 1.2, "length": 1.0, "shade": -0.3},
	{"count": 5, "fan": 0.8, "length": 0.88, "shade": 0.0},
	{"count": 3, "fan": 0.4, "length": 0.72, "shade": 0.3},
]

# 0..1 how far the lotus has grown out of the ground / opened its petals,
# and how thick the mist is. Tweened by the stage functions below.
var _rise: float = 0.0
var _open: float = 0.0
var _mist: float = 0.0
var _time: float = 0.0
# Fixed per-puff random seeds so the mist drifts the same way every frame.
var _puffs: Array = []


## `column_rect` is the column's full area in this node's parent space:
## x/width are the column, y/height run from the top of the mist down to
## the ground line the fighters stand on.
func setup(column_rect: Rect2) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = column_rect.position
	size = column_rect.size
	for i in MIST_PUFF_COUNT:
		_puffs.append({
			"x": randf(),
			"y": randf(),
			"r": randf_range(0.22, 0.42),
			"phase": randf() * TAU,
			"speed": randf_range(0.4, 0.9),
		})


func show_hint() -> void:
	var tween := create_tween()
	tween.tween_property(self, "_rise", 1.0, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func bloom() -> void:
	var tween := create_tween()
	tween.tween_property(self, "_open", 1.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "_mist", 1.0, 0.9)


func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _mist > 0.0:
		_draw_mist()
	if _rise > 0.0:
		_draw_lotus()


func _draw_mist() -> void:
	# A soft violet wash up the whole column, thickest near the ground...
	var wash_steps := 8
	for i in wash_steps:
		var t: float = float(i) / float(wash_steps)
		var band_h: float = size.y / float(wash_steps)
		var alpha: float = (0.1 + 0.26 * t) * _mist
		draw_rect(Rect2(0.0, t * size.y, size.x, band_h + 1.0), Color(MIST_COLOR.r, MIST_COLOR.g, MIST_COLOR.b, alpha))
	# ...with puffs drifting through it.
	for puff in _puffs:
		var drift: float = sin(_time * puff["speed"] + puff["phase"])
		var cx: float = size.x * (0.15 + 0.7 * puff["x"]) + drift * size.x * 0.08
		var cy: float = size.y * (0.2 + 0.75 * puff["y"]) + cos(_time * puff["speed"] * 0.7 + puff["phase"]) * size.y * 0.03
		var radius: float = size.x * puff["r"]
		draw_circle(Vector2(cx, cy), radius, Color(MIST_COLOR.r, MIST_COLOR.g, MIST_COLOR.b, 0.2 * _mist))
		draw_circle(Vector2(cx, cy), radius * 0.6, Color(0.75, 0.5, 0.95, 0.15 * _mist))


## A lotus in the same violet as the mist. As a bud the three petal
## rows stand almost upright and close together; opened, the outer rows fan
## out to the sides.
func _draw_lotus() -> void:
	var ground := Vector2(size.x * 0.5, size.y - 4.0)

	var head := ground + Vector2(sin(_time * 1.2) * 1.5 * _rise, -size.x * 0.1 * _rise)
	draw_line(ground, head, MIST_COLOR.darkened(0.5), 3.0, true)

	var base_len: float = size.x * 0.42 * (0.55 + 0.45 * _rise) * (1.0 + 0.2 * _open)
	var open_amount: float = 0.22 + 0.78 * _open
	for row in PETAL_ROWS:
		var count: int = row["count"]
		var length: float = base_len * row["length"]
		var width: float = length * (0.2 + 0.07 * _open)
		for i in count:
			var t: float = 0.5 if count == 1 else float(i) / float(count - 1)
			var angle: float = -PI * 0.5 + lerpf(-1.0, 1.0, t) * float(row["fan"]) * open_amount
			_draw_petal(head, angle, length, width, MIST_COLOR.lightened(row["shade"]) if row["shade"] >= 0.0 else MIST_COLOR.darkened(-row["shade"]))

	# A glowing heart - dim in the bud, bright once it has bloomed.
	var core_radius: float = size.x * (0.035 + 0.035 * _open)
	draw_circle(head, core_radius * 2.0, Color(CORE_COLOR.r, CORE_COLOR.g, CORE_COLOR.b, 0.2 + 0.3 * _open))
	draw_circle(head, core_radius, CORE_COLOR)


## One pointed lotus petal: widest about two thirds of the way out, ending in
## a tip, with a lighter vein down the middle.
func _draw_petal(origin: Vector2, angle: float, length: float, width: float, color: Color) -> void:
	var dir := Vector2.from_angle(angle)
	var perp := Vector2(-dir.y, dir.x)
	var outline := PackedVector2Array([
		origin,
		origin + dir * length * 0.25 + perp * width * 0.7,
		origin + dir * length * 0.6 + perp * width,
		origin + dir * length * 0.88 + perp * width * 0.55,
		origin + dir * length,
		origin + dir * length * 0.88 - perp * width * 0.55,
		origin + dir * length * 0.6 - perp * width,
		origin + dir * length * 0.25 - perp * width * 0.7,
	])
	draw_colored_polygon(outline, color)
	draw_polyline(outline + PackedVector2Array([outline[0]]), MIST_COLOR.darkened(0.55), 1.3, true)
	draw_line(origin + dir * length * 0.15, origin + dir * length * 0.85, color.lightened(0.22), 1.2, true)
