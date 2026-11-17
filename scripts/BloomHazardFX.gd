class_name BloomHazardFX
extends Control
## A zone hazard flower, drawn over one battlefield column (see
## TERRAIN_DESIGN.md). Three styles, picked in setup():
##   "lotus" - The Blackbloom's dark purple lotus and purple mist.
##   "bell"  - The Verdant Scar's blood red bell flower and red mist.
##   "sand"  - The Scorchlands' small dust cloud (the hint) that becomes a
##             sandstorm filling the column.
## Three stages:
##   show_hint()  - the flower rises out of the ground as a bud
##                  (visual only, nothing happens yet).
##   bloom()      - it opens and releases a mist that fills the whole column.
##   fade_out()   - the mist thins out and the flower sinks away.
## Purely cosmetic: the gameplay rules live in battle.gd (_hazard_*).

const MIST_PUFF_COUNT := 14
## Lotus petal rows, drawn back to front: how many petals, how far the row
## fans out to each side when fully open (radians), its length relative to
## the biggest row, and how much darker (-) or lighter (+) than the mist
## colour it is (dark outside, lighter in the middle).
const PETAL_ROWS := [
	{"count": 6, "fan": 1.2, "length": 1.0, "shade": -0.3},
	{"count": 5, "fan": 0.8, "length": 0.88, "shade": 0.0},
	{"count": 3, "fan": 0.4, "length": 0.72, "shade": 0.3},
]

# Colours per style: the mist and flower, the glowing heart, and the lighter
# inner puffs of the mist.
const STYLES := {
	"lotus": {
		"mist": Color(0.62, 0.3, 0.85, 1.0),
		"core": Color(0.95, 0.78, 1.0, 1.0),
		"puff": Color(0.75, 0.5, 0.95, 1.0),
	},
	"bell": {
		"mist": Color(0.72, 0.07, 0.1, 1.0),
		"core": Color(1.0, 0.72, 0.62, 1.0),
		"puff": Color(0.92, 0.3, 0.28, 1.0),
	},
	"sand": {
		"mist": Color(0.82, 0.6, 0.3, 1.0),
		"core": Color(0.97, 0.86, 0.6, 1.0),
		"puff": Color(0.93, 0.76, 0.46, 1.0),
	},
	"mist": {
		"mist": Color(0.78, 0.83, 0.88, 1.0),
		"core": Color(0.96, 0.98, 1.0, 1.0),
		"puff": Color(0.9, 0.93, 0.96, 1.0),
	},
	"wave": {
		"mist": Color(0.1, 0.36, 0.5, 1.0),
		"core": Color(0.93, 0.98, 1.0, 1.0),
		"puff": Color(0.26, 0.64, 0.74, 1.0),
	},
	"bees": {
		"mist": Color(0.42, 0.3, 0.07, 1.0),
		"core": Color(1.0, 0.82, 0.2, 1.0),
		"puff": Color(0.7, 0.5, 0.12, 1.0),
	},
	"ink": {
		"mist": Color(0.03, 0.05, 0.09, 1.0),
		"core": Color(0.35, 0.85, 0.8, 1.0),
		"puff": Color(0.07, 0.12, 0.17, 1.0),
	},
}
# The Drowned Empire's octopus (style "ink"): body, shaded body, dark outline.
const OCTO_BODY := Color(0.07, 0.27, 0.3, 1.0)
const OCTO_LIGHT := Color(0.13, 0.42, 0.43, 1.0)
const OCTO_DARK := Color(0.025, 0.1, 0.12, 1.0)
const GRAIN_COUNT := 46
const WALL_PUFF_COUNT := 34
const BEE_SWARM_COUNT := 40

var _style: String = "lotus"
var _mist_color: Color = STYLES["lotus"]["mist"]
var _core_color: Color = STYLES["lotus"]["core"]
var _puff_color: Color = STYLES["lotus"]["puff"]

# 0..1 how far the flower has grown out of the ground / opened, and how thick
# the mist is. Tweened by the stage functions below.
var _rise: float = 0.0
var _open: float = 0.0
var _mist: float = 0.0
var _time: float = 0.0
# The octopus's own opacity multiplier (it fades out at the top).
var _fade: float = 1.0
# Fixed per-puff random seeds so the mist drifts the same way every frame.
var _puffs: Array = []
# The sandstorm's wind-blown grains, seeded the same way.
var _grains: Array = []


## `column_rect` is the column's full area in this node's parent space:
## x/width are the column, y/height run from the top of the mist down to
## the ground line the fighters stand on.
func setup(column_rect: Rect2, style: String = "lotus") -> void:
	_style = style if STYLES.has(style) else "lotus"
	_mist_color = STYLES[_style]["mist"]
	_core_color = STYLES[_style]["core"]
	_puff_color = STYLES[_style]["puff"]
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
	for i in GRAIN_COUNT:
		_grains.append({
			"x": randf(),
			"y": randf(),
			"len": randf_range(0.08, 0.3),
			"phase": randf() * TAU,
			"speed": randf_range(0.6, 1.6),
		})


func show_hint() -> void:
	var tween := create_tween()
	tween.tween_property(self, "_rise", 1.0, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func bloom() -> void:
	var tween := create_tween()
	if _style == "wave":
		# The big wave surges toward the screen, breaks and spreads out, then
		# churns as a foaming sheet until it is cleared.
		tween.tween_property(self, "_mist", 1.0, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		return
	if _style == "bees":
		# The loose bees pull together into the swarm cloud.
		tween.tween_property(self, "_mist", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		return
	if _style == "ink":
		# The octopus jets up the column (_mist = how far up it is), then
		# fades at the top; the ink it left behind stays.
		tween.tween_property(self, "_mist", 1.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "_fade", 0.0, 0.5)
		return
	if _style == "mist":
		# The gathered mist shoots up into a wall: fast at first, then settling.
		tween.tween_property(self, "_mist", 1.0, 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		return
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
	if _style == "wave":
		if _rise > 0.0:
			_draw_wash(clampf(1.0 - _mist * 3.0, 0.0, 1.0))
		if _mist > 0.0:
			_draw_big_wave()
		return
	if _style == "bees":
		if _rise > 0.0 and _mist < 1.0:
			_draw_loose_bees()
		if _mist > 0.0:
			_draw_bee_swarm()
		return
	if _style == "ink":
		var octopus_y: float = _octopus_origin_y()
		if _mist > 0.0:
			_draw_ink(octopus_y)
		if _rise > 0.0 and _fade > 0.0:
			_draw_octopus(Vector2(size.x * 0.5 + sin(_time * 1.3) * size.x * 0.02 * _mist, octopus_y))
		return
	if _style == "mist":
		if _rise > 0.0:
			_draw_gathering_mist()
		if _mist > 0.0:
			_draw_mist_wall()
		return
	if _style == "sand":
		if _rise > 0.0:
			_draw_dust_cloud()
		if _mist > 0.0:
			_draw_sandstorm()
		return
	if _mist > 0.0:
		_draw_mist()
	if _rise > 0.0:
		if _style == "bell":
			_draw_bell()
		else:
			_draw_lotus()


## The hint: a small cloud of dust boiling up right above the ground. It
## stays, thicker, at the foot of the sandstorm once that breaks.
func _draw_dust_cloud() -> void:
	var cloud_count := 7
	for i in cloud_count:
		var f: float = float(i) / float(cloud_count - 1)
		var phase: float = float(i) * 1.7
		var radius: float = size.x * (0.09 + 0.05 * sin(phase * 1.3 + 1.0) + 0.03 * _open) * _rise
		var cx: float = size.x * (0.14 + 0.72 * f) + sin(_time * 0.9 + phase) * size.x * 0.03
		var cy: float = size.y - radius * 0.7 - size.x * 0.03 - (0.5 + 0.5 * sin(_time * 1.3 + phase)) * size.x * 0.04 * _rise
		draw_circle(Vector2(cx, cy), radius, Color(_mist_color.r, _mist_color.g, _mist_color.b, 0.42 * _rise))
		draw_circle(Vector2(cx - radius * 0.2, cy - radius * 0.25), radius * 0.6, Color(_puff_color.r, _puff_color.g, _puff_color.b, 0.3 * _rise))
	# A few grains kicked up off the top.
	for i in 8:
		var phase2: float = float(i) * 2.3
		var life: float = fposmod(_time * 0.5 + phase2, 1.0)
		var gx: float = size.x * (0.2 + 0.6 * fposmod(phase2 * 0.37, 1.0)) + sin(_time * 2.0 + phase2) * size.x * 0.05
		var gy: float = size.y - size.x * 0.08 - life * size.x * 0.28 * _rise
		draw_circle(Vector2(gx, gy), 1.6, Color(_core_color.r, _core_color.g, _core_color.b, (1.0 - life) * 0.7 * _rise))


## Stage 2: a sandstorm - a heavy tan wash over the whole column, big dust
## billows rolling through it and wind-blown grains streaking sideways.
func _draw_sandstorm() -> void:
	var wash_steps := 8
	for i in wash_steps:
		var t: float = float(i) / float(wash_steps)
		var band_h: float = size.y / float(wash_steps)
		var alpha: float = (0.22 + 0.28 * t) * _mist
		draw_rect(Rect2(0.0, t * size.y, size.x, band_h + 1.0), Color(_mist_color.r, _mist_color.g, _mist_color.b, alpha))
	for puff in _puffs:
		var drift: float = sin(_time * puff["speed"] * 1.6 + puff["phase"])
		var cx: float = size.x * (0.15 + 0.7 * puff["x"]) + drift * size.x * 0.14
		var cy: float = size.y * (0.12 + 0.82 * puff["y"]) + cos(_time * puff["speed"] + puff["phase"]) * size.y * 0.04
		var radius: float = size.x * puff["r"] * 1.15
		draw_circle(Vector2(cx, cy), radius, Color(_mist_color.r, _mist_color.g, _mist_color.b, 0.26 * _mist))
		draw_circle(Vector2(cx, cy), radius * 0.6, Color(_puff_color.r, _puff_color.g, _puff_color.b, 0.2 * _mist))
	for grain in _grains:
		var gx: float = fposmod(grain["x"] + _time * grain["speed"] * 0.35, 1.0) * (size.x + 20.0) - 10.0
		var gy: float = size.y * grain["y"] + sin(_time * 3.0 + grain["phase"]) * size.y * 0.02
		var length: float = size.x * grain["len"]
		draw_line(Vector2(gx, gy), Vector2(gx + length, gy - length * 0.18), Color(_core_color.r, _core_color.g, _core_color.b, 0.6 * _mist), 1.6, true)


## The hint: small waves wash toward the screen along the floor of the
## column. Each starts far back (higher up, narrow and low), grows as it
## comes forward and thins out into a sheet of foam on the near edge.
func _draw_wash(strength: float) -> void:
	if strength <= 0.0:
		return
	for k in 2:
		var phase: float = fposmod(_time * 0.42 + 0.5 * float(k), 1.0)
		var grow: float = lerpf(0.45, 1.05, phase)
		var y: float = lerpf(size.y - size.x * 0.34, size.y - size.x * 0.02, phase)
		var half: float = size.x * 0.5 * grow
		var fade: float = sin(phase * PI) * _rise * strength
		var cx: float = size.x * 0.5
		# The sheet of water running up the floor: a flat, soft ellipse.
		var sheet := PackedVector2Array()
		for i in 25:
			var a: float = TAU * float(i) / 25.0
			sheet.append(Vector2(cx + cos(a) * half * 1.1, y + sin(a) * size.x * 0.07 * grow))
		draw_colored_polygon(sheet, Color(_mist_color.r, _mist_color.g, _mist_color.b, 0.28 * fade))
		# The small wave riding its front: a low rolling mound with foam on it.
		var hump := PackedVector2Array()
		var steps := 18
		for i in steps + 1:
			var t: float = float(i) / float(steps)
			var hx: float = cx + (t - 0.5) * 2.0 * half
			var hh: float = size.x * 0.16 * grow * pow(maxf(sin(PI * t), 0.0), 0.8) * (0.85 + 0.15 * sin(_time * 3.0 + t * 8.0 + float(k)))
			hump.append(Vector2(hx, y - hh))
		var body := PackedVector2Array(hump)
		body.append(Vector2(cx + half, y + size.x * 0.02))
		body.append(Vector2(cx - half, y + size.x * 0.02))
		draw_colored_polygon(body, Color(_puff_color.r, _puff_color.g, _puff_color.b, 0.4 * fade))
		for i in steps + 1:
			var fr: float = size.x * 0.035 * grow * (0.8 + 0.4 * sin(float(i) * 2.3 + _time * 2.0))
			draw_circle(hump[i], fr, Color(_core_color.r, _core_color.g, _core_color.b, 0.5 * fade))


## Stage 2: a big wave that washes over toward the screen. `_mist` runs 0 -> 1
## through its whole journey: it starts far back (small, narrow, standing
## higher on the ground), grows and surges forward as it comes at the viewer,
## peaks, then breaks - the crest tumbling forward and the water spreading out
## over the foreground as a foaming sheet that stays until it is cleared.
## Sides and top are curves, never straight.
func _draw_big_wave() -> void:
	var p: float = _mist
	var forward: float = smoothstep(0.0, 1.0, p)
	var rise: float = smoothstep(0.0, 0.5, p)
	var collapse: float = smoothstep(0.5, 1.0, p)
	var height: float = size.y * 0.85 * rise * (1.0 - 0.68 * collapse)
	if height < 3.0:
		return
	var scale_x: float = lerpf(0.6, 1.25, forward)
	var base_y: float = lerpf(size.y * 0.8, size.y + size.x * 0.08, forward)
	var cx: float = size.x * 0.5
	var half: float = size.x * 0.64 * scale_x
	var steps := 30
	var outline := PackedVector2Array()
	var tops: Array = []
	for i in steps + 1:
		var t: float = float(i) / float(steps)
		var h: float = height * pow(maxf(sin(PI * t), 0.0), 0.5) * (0.92 + 0.08 * sin(_time * 2.2 + t * 9.0))
		var pt := Vector2(cx + (t - 0.5) * 2.0 * half, base_y - h)
		outline.append(pt)
		tops.append(pt)
	draw_colored_polygon(outline, Color(_mist_color.r, _mist_color.g, _mist_color.b, 0.56))
	# A lighter inner swell and rolling streaks give the water depth.
	var inner := PackedVector2Array()
	for i in steps + 1:
		var t2: float = float(i) / float(steps)
		inner.append(Vector2(cx + (t2 - 0.5) * 2.0 * half * 0.92, base_y - height * 0.72 * pow(maxf(sin(PI * t2), 0.0), 0.6)))
	draw_colored_polygon(inner, Color(_puff_color.r, _puff_color.g, _puff_color.b, 0.26))
	for s in 5:
		var fs: float = float(s)
		var line_y: float = base_y - height * (0.15 + 0.14 * fs)
		var streak := PackedVector2Array()
		for i in 12:
			var t3: float = float(i) / 11.0
			streak.append(Vector2(cx + (t3 - 0.5) * 2.0 * half * 0.85, line_y + sin(_time * 1.6 + t3 * 6.0 + fs * 1.4) * size.x * 0.03))
		draw_polyline(streak, Color(_core_color.r, _core_color.g, _core_color.b, 0.18), 2.0, true)
	# The crest: foam along the top edge. As the wave breaks it tumbles
	# forward and down, toward the screen.
	var tumble: float = collapse * height * 0.55
	var foam_in: float = minf(1.0, p * 4.0)
	for i in tops.size():
		var tc: float = float(i) / float(steps)
		var fr: float = size.x * (0.05 + 0.05 * fposmod(float(i) * 0.57, 1.0)) * foam_in * scale_x
		var wob := Vector2(sin(_time * 2.5 + float(i)) * 2.0, cos(_time * 2.0 + float(i) * 1.7) * 3.0)
		var spot: Vector2 = tops[i] + wob + Vector2(0.0, tumble * sin(PI * tc))
		draw_circle(spot, fr, Color(_core_color.r, _core_color.g, _core_color.b, 0.62 * sin(PI * tc) + 0.1))
		draw_circle(spot + Vector2(0.0, fr * 0.9), fr * 0.8, Color(_core_color.r, _core_color.g, _core_color.b, 0.3 * sin(PI * tc)))
	# Spray flung up and forward off the crest while it is still climbing.
	var spray: float = rise * (1.0 - collapse)
	for i in 16:
		var fi: float = float(i)
		var life: float = fposmod(_time * 0.7 + fi * 0.37, 1.0)
		var u: float = 0.1 + 0.8 * fposmod(fi * 0.618, 1.0)
		var crest_y: float = base_y - height * pow(maxf(sin(PI * u), 0.0), 0.5)
		var sx: float = cx + (u - 0.5) * 2.0 * half
		var sy: float = crest_y - sin(life * PI) * size.x * 0.35 * rise + life * life * size.x * 0.12
		draw_circle(Vector2(sx, sy), 1.5 + 1.8 * (1.0 - life), Color(_core_color.r, _core_color.g, _core_color.b, 0.75 * (1.0 - life) * spray))
	# The foaming sheet it leaves spread over the foreground.
	if collapse > 0.0:
		var sheet := PackedVector2Array()
		for i in 25:
			var a: float = TAU * float(i) / 25.0
			sheet.append(Vector2(cx + cos(a) * half * 1.15, base_y + size.x * 0.03 + sin(a) * size.x * 0.13 * collapse))
		draw_colored_polygon(sheet, Color(_puff_color.r, _puff_color.g, _puff_color.b, 0.34 * collapse))
	# Foam churning along the foot of the wave.
	for i in 14:
		var fb: float = float(i)
		var bx: float = cx + (fposmod(fb * 0.381 + 0.1, 1.0) - 0.5) * 2.0 * half + sin(_time * 1.3 + fb) * size.x * 0.04
		var by: float = base_y + size.x * 0.02 * collapse - size.x * (0.02 + 0.05 * fposmod(fb * 0.73, 1.0)) + sin(_time * 2.0 + fb * 2.0) * 2.0
		draw_circle(Vector2(bx, by), size.x * (0.05 + 0.04 * fposmod(fb * 0.29, 1.0)) * scale_x, Color(_core_color.r, _core_color.g, _core_color.b, 0.4 * foam_in))


## Drawing scale of the octopus: its local coordinates are about 110 units
## tall, and fit the column's width.
func _octo_scale() -> float:
	return size.x / 105.0


## The octopus's body-centre height: resting on the floor, then up the column
## as _mist runs 0 -> 1.
func _octopus_origin_y() -> float:
	var s: float = _octo_scale()
	var rest_y: float = size.y - 4.0 - 38.0 * s
	var top_y: float = 80.0 * s
	var p: float = _mist
	var eased: float = p * p * (3.0 - 2.0 * p)
	return lerpf(rest_y + (1.0 - clampf(_rise, 0.0, 1.0)) * 34.0 * s, top_y, eased)


## A cloud of black ink, left behind as the octopus passes: soft puffs fill
## the column below it and stay thick after it is gone.
func _draw_ink(octopus_y: float) -> void:
	var s: float = _octo_scale()
	for i in 38:
		var fi: float = float(i)
		var fx: float = fposmod(fi * 0.618 + 0.21, 1.0)
		var fy: float = fposmod(fi * 0.381 + 0.09, 1.0)
		var speed: float = 0.2 + 0.25 * fposmod(fi * 0.73, 1.0)
		var phase: float = fi * 2.3
		var cx: float = size.x * (-0.05 + 1.1 * fx) + sin(_time * speed + phase) * size.x * 0.1
		var cy: float = size.y * (0.02 + 0.98 * fy) + cos(_time * speed * 0.8 + phase) * size.x * 0.05
		var behind: float = clampf((cy - octopus_y + 10.0 * s) / (70.0 * s), 0.0, 1.0)
		var radius: float = size.x * (0.32 + 0.3 * fposmod(fi * 0.47, 1.0))
		var across: float = 1.0 - minf(1.0, absf(cx / size.x - 0.5) * 1.4)
		var color: Color = _mist_color.lerp(_puff_color, fposmod(fi * 0.29, 1.0))
		_soft_puff(Vector2(cx, cy), radius, color, 0.62 * behind * (0.55 + 0.45 * across) * clampf(_mist * 6.0, 0.0, 1.0))


## An octopus, kept sober: dark teal, mottled skin, a small amber eye with a
## horizontal slit pupil, tapering arms with rows of suckers. Resting it sits
## on the floor with its arms spread; as it swims (_mist) the arms stream
## behind it. `origin` is the middle of the body.
func _draw_octopus(origin: Vector2) -> void:
	var s: float = _octo_scale()
	var alpha: float = clampf(_rise, 0.0, 1.0) * _fade
	var pose: float = smoothstep(0.0, 0.12, _mist)
	_draw_octopus_arms(origin, s, pose, alpha)
	# Mantle: a long teardrop leaning slightly with the swim.
	var lean: float = 3.0 * sin(_time * 1.6) * pose
	var outline := PackedVector2Array()
	var steps := 16
	for i in steps + 1:
		var t: float = float(i) / float(steps)
		var y: float = lerpf(8.0, -78.0, t)
		var half: float = 24.0 * pow(sin(minf(t * 1.0, 1.0) * PI * 0.5 + 0.35), 1.0) * (1.0 - pow(t, 2.6) * 0.85)
		outline.append(origin + Vector2(-half + lean * t, y) * s)
	for i in range(steps, -1, -1):
		var t2: float = float(i) / float(steps)
		var y2: float = lerpf(8.0, -78.0, t2)
		var half2: float = 24.0 * pow(sin(minf(t2 * 1.0, 1.0) * PI * 0.5 + 0.35), 1.0) * (1.0 - pow(t2, 2.6) * 0.85)
		outline.append(origin + Vector2(half2 + lean * t2, y2) * s)
	draw_colored_polygon(outline, _octo_color(OCTO_BODY, alpha))
	# The head: a rounder, lighter swell at the base of the mantle.
	draw_circle(origin + Vector2(0.0, -6.0) * s, 22.0 * s, _octo_color(OCTO_BODY, alpha))
	draw_circle(origin + Vector2(-5.0, -14.0) * s, 15.0 * s, _octo_color(OCTO_LIGHT, alpha * 0.55))
	# Mottled skin and a few faint glowing spots along the mantle.
	for i in 14:
		var fi: float = float(i)
		var t3: float = fposmod(fi * 0.37 + 0.1, 1.0)
		var bx: float = (fposmod(fi * 0.61, 1.0) - 0.5) * 30.0 * (1.0 - t3 * 0.6)
		var by: float = lerpf(-4.0, -68.0, t3)
		var dark: bool = i % 2 == 0
		draw_circle(origin + Vector2(bx + lean * t3, by) * s, (2.5 + 2.5 * fposmod(fi * 0.53, 1.0)) * s, _octo_color(OCTO_DARK if dark else OCTO_LIGHT, alpha * 0.4))
	for i in 6:
		var fi2: float = float(i)
		var pulse: float = 0.5 + 0.5 * sin(_time * 1.4 + fi2 * 1.7)
		var gx: float = (fposmod(fi2 * 0.43, 1.0) - 0.5) * 22.0
		var gy: float = -20.0 - fi2 * 9.0
		draw_circle(origin + Vector2(gx + lean * (-gy / 78.0), gy) * s, 1.3 * s, Color(_core_color.r, _core_color.g, _core_color.b, alpha * (0.25 + 0.5 * pulse)))
	# The eyes: amber with a horizontal slit pupil, under a heavy lid.
	for side in [-1.0, 1.0]:
		var eye: Vector2 = origin + Vector2(side * 14.0, -4.0) * s
		draw_circle(eye, 6.6 * s, _octo_color(OCTO_DARK, alpha))
		draw_circle(eye, 5.0 * s, _octo_color(Color(0.8, 0.62, 0.2, 1.0), alpha))
		draw_circle(eye + Vector2(0.0, 1.0) * s, 3.0 * s, _octo_color(Color(0.55, 0.38, 0.1, 1.0), alpha * 0.7))
		draw_rect(Rect2(eye + Vector2(-3.4, -0.9) * s, Vector2(6.8, 1.9) * s), _octo_color(Color(0.02, 0.02, 0.02, 1.0), alpha))
		draw_arc(eye, 5.6 * s, PI * 1.05, PI * 1.95, 8, _octo_color(OCTO_DARK, alpha), 2.2 * s, true)


func _octo_color(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, color.a * alpha)


## Eight tapering arms. Resting they spread out and curl along the floor;
## swimming they stream down together behind the body in a lazy wave.
func _draw_octopus_arms(origin: Vector2, s: float, pose: float, alpha: float) -> void:
	for i in 8:
		var t: float = float(i) / 7.0
		var root := origin + Vector2(lerpf(-17.0, 17.0, t), 4.0) * s
		var rest_tip := origin + Vector2(lerpf(-78.0, 78.0, t) + (t - 0.5) * 8.0, 36.0) * s
		var swim_tip := origin + Vector2(lerpf(-9.0, 9.0, t) + sin(_time * 2.4 + float(i)) * 5.0, 96.0 + 8.0 * sin(float(i) * 2.0)) * s
		var tip: Vector2 = rest_tip.lerp(swim_tip, pose)
		var c1_rest := origin + Vector2(lerpf(-36.0, 36.0, t), 14.0) * s
		var c2_rest := origin + Vector2(lerpf(-70.0, 70.0, t), 40.0 - 8.0 * sin(float(i) * 1.3)) * s
		var c1_swim := origin + Vector2(lerpf(-12.0, 12.0, t) + sin(_time * 2.0 + float(i) * 0.8) * 6.0, 34.0) * s
		var c2_swim := origin + Vector2(lerpf(-10.0, 10.0, t) + sin(_time * 2.0 + float(i) * 0.8 + 1.4) * 8.0, 68.0) * s
		var c1: Vector2 = c1_rest.lerp(c1_swim, pose)
		var c2: Vector2 = c2_rest.lerp(c2_swim, pose)
		var points := PackedVector2Array()
		var samples := 14
		for k in samples + 1:
			var u: float = float(k) / float(samples)
			var q0: Vector2 = root.lerp(c1, u)
			var q1: Vector2 = c1.lerp(c2, u)
			var q2: Vector2 = c2.lerp(tip, u)
			points.append(q0.lerp(q1, u).lerp(q1.lerp(q2, u), u))
		var left := PackedVector2Array()
		var right := PackedVector2Array()
		for k in points.size():
			var u2: float = float(k) / float(samples)
			var dir: Vector2 = (points[mini(k + 1, points.size() - 1)] - points[maxi(k - 1, 0)]).normalized()
			var normal := Vector2(-dir.y, dir.x)
			var width: float = lerpf(6.5, 0.9, pow(u2, 0.8)) * s
			left.append(points[k] + normal * width)
			right.append(points[k] - normal * width)
		right.reverse()
		left.append_array(right)
		draw_colored_polygon(left, _octo_color(OCTO_BODY.darkened(0.12), alpha))
		draw_polyline(points, _octo_color(OCTO_LIGHT, alpha * 0.35), 1.2 * s, true)
		# Suckers along the underside.
		for k in range(2, samples, 2):
			var u3: float = float(k) / float(samples)
			draw_circle(points[k], lerpf(1.6, 0.5, u3) * s, _octo_color(Color(0.55, 0.78, 0.72, 1.0), alpha * 0.45))


## The hint: low, pale mist pooling along the floor of the column, with a few
## wisps curling up off it. It stays, thicker, at the foot of the wall.
func _draw_gathering_mist() -> void:
	var count := 9
	for i in count:
		var f: float = float(i) / float(count - 1)
		var phase: float = float(i) * 1.9
		var radius: float = size.x * (0.13 + 0.05 * sin(phase * 1.3 + 1.0) + 0.04 * _mist) * _rise
		var cx: float = size.x * (0.1 + 0.8 * f) + sin(_time * 0.6 + phase) * size.x * 0.05
		var cy: float = size.y - radius * 0.55 - (0.5 + 0.5 * sin(_time * 0.9 + phase)) * size.x * 0.035 * _rise
		draw_circle(Vector2(cx, cy), radius, Color(_mist_color.r, _mist_color.g, _mist_color.b, 0.3 * _rise))
		draw_circle(Vector2(cx - radius * 0.15, cy - radius * 0.25), radius * 0.6, Color(_puff_color.r, _puff_color.g, _puff_color.b, 0.26 * _rise))
	for i in 5:
		var phase2: float = float(i) * 2.7
		var life: float = fposmod(_time * 0.22 + phase2, 1.0)
		var wx: float = size.x * (0.2 + 0.6 * fposmod(phase2 * 0.43, 1.0)) + sin(_time * 1.1 + phase2) * size.x * 0.08
		var wy: float = size.y - size.x * 0.1 - life * size.x * 0.5 * _rise
		draw_circle(Vector2(wx, wy), size.x * 0.07 * (0.6 + life), Color(_puff_color.r, _puff_color.g, _puff_color.b, (1.0 - life) * 0.25 * _rise))


## Stage 2: the mist shoots up the column - a heavy, billowing bank of fog
## whose top climbs with _mist, spilling past the column's sides.
func _draw_mist_wall() -> void:
	var top: float = size.y * (1.0 - _mist)
	var height: float = size.y - top
	# No rectangles: only feathered puffs, so no side or top is a straight
	# line. They are denser toward the middle of the column and the ground,
	# thin out toward the sides and the top, and drift slowly.
	var fade_in: float = minf(1.0, _mist * 2.0)
	for i in WALL_PUFF_COUNT:
		var fi: float = float(i)
		var fx: float = fposmod(fi * 0.618 + 0.13, 1.0)
		var fy: float = fposmod(fi * 0.381 + 0.27, 1.0)
		var speed: float = 0.25 + 0.3 * fposmod(fi * 0.73, 1.0)
		var phase: float = fi * 2.1
		var cx: float = size.x * (-0.1 + 1.2 * fx) + sin(_time * speed + phase) * size.x * 0.12
		var cy: float = top + height * fy + cos(_time * speed * 0.7 + phase) * size.x * 0.06
		var radius: float = size.x * (0.4 + 0.3 * fposmod(fi * 0.47, 1.0))
		var across: float = 1.0 - minf(1.0, absf(cx / size.x - 0.5) * 1.6)
		var down: float = smoothstep(0.0, 0.35, fy) * (0.6 + 0.4 * fy)
		_soft_puff(Vector2(cx, cy), radius, _mist_color.lerp(_puff_color, fposmod(fi * 0.29, 1.0)), 0.5 * across * down * fade_in)


## A circle with no edge: stacked discs shrinking and thickening toward the
## middle, so it fades smoothly into whatever is behind it.
func _soft_puff(at: Vector2, radius: float, color: Color, alpha: float) -> void:
	if alpha <= 0.0:
		return
	var layers := 6
	for l in layers:
		var t: float = float(l) / float(layers)
		draw_circle(at, radius * (1.0 - 0.8 * t), Color(color.r, color.g, color.b, alpha / float(layers) * 1.6))


## Where bee `i` is at time `t` while flying loose near the ground (the hint):
## a lazy looping path over the lower part of the column.
func _bee_loose_pos(i: int, t: float) -> Vector2:
	var fi: float = float(i)
	var fx: float = fposmod(fi * 0.618 + 0.1, 1.0)
	var fy: float = fposmod(fi * 0.381 + 0.2, 1.0)
	var speed: float = 0.8 + 0.6 * fposmod(fi * 0.73, 1.0)
	var x: float = size.x * (0.5 + (fx - 0.5) * 0.7) + sin(t * speed + fi * 2.1) * size.x * 0.22
	var y: float = size.y * (0.55 + 0.4 * fy) + cos(t * speed * 1.3 + fi * 1.3) * size.y * 0.07
	return Vector2(x, y)


## Where bee `i` is at time `t` while circling inside the swarm cloud.
func _bee_swarm_pos(i: int, t: float) -> Vector2:
	var fi: float = float(i)
	var spread: float = fposmod(fi * 0.618 + 0.05, 1.0)
	var speed: float = (0.9 + 1.1 * fposmod(fi * 0.37, 1.0)) * (1.0 if i % 2 == 0 else -1.0)
	var angle: float = fi * 2.4 + t * speed
	var center := Vector2(size.x * 0.5, size.y * 0.55)
	var rx: float = size.x * 0.62 * _mist * (0.25 + 0.75 * spread)
	var ry: float = size.y * 0.36 * _mist * (0.25 + 0.75 * spread)
	return center + Vector2(cos(angle) * rx, sin(angle * 1.3) * ry) + Vector2(sin(t * 3.0 + fi), cos(t * 2.6 + fi * 1.7)) * size.x * 0.02


## One bee: striped body, dark head, two blurry wings that flap. `dir` is the
## way it is flying (it faces that way).
func _draw_bee(at: Vector2, dir: Vector2, s: float, alpha: float, phase: float) -> void:
	if alpha <= 0.0:
		return
	var d: Vector2 = dir.normalized() if dir.length() > 0.001 else Vector2.RIGHT
	var side := Vector2(-d.y, d.x)
	var flap: float = 0.55 + 0.45 * sin(_time * 40.0 + phase)
	var wing := Color(0.9, 0.96, 1.0, 0.55 * alpha)
	draw_circle(at - d * s * 0.1 + side * s * 0.55 * flap, s * 0.55, wing)
	draw_circle(at - d * s * 0.1 - side * s * 0.55 * flap, s * 0.55, wing)
	draw_circle(at - d * s * 0.55, s * 0.62, Color(0.98, 0.78, 0.12, alpha))
	draw_circle(at + d * s * 0.2, s * 0.68, Color(0.98, 0.78, 0.12, alpha))
	draw_circle(at - d * s * 0.2, s * 0.4, Color(0.12, 0.08, 0.04, alpha))
	draw_circle(at + d * s * 0.85, s * 0.42, Color(0.12, 0.08, 0.04, alpha))


## The hint: a few bees flying lazily around near the ground.
func _draw_loose_bees() -> void:
	var count := 6
	var s: float = size.x * 0.05
	for i in count:
		var p: Vector2 = _bee_loose_pos(i, _time)
		var dir: Vector2 = _bee_loose_pos(i, _time + 0.05) - p
		_draw_bee(p, dir, s, _rise, float(i) * 1.9)


## Stage 2: the bees gather into a swarm - a drifting golden-brown haze with
## many bees circling inside it. It grows with _mist and stays until cleared.
func _draw_bee_swarm() -> void:
	var fade_in: float = minf(1.0, _mist * 2.0)
	var center := Vector2(size.x * 0.5, size.y * 0.55)
	for i in 14:
		var fi: float = float(i)
		var speed: float = 0.3 + 0.3 * fposmod(fi * 0.73, 1.0)
		var angle: float = fi * 2.4 + _time * speed
		var at: Vector2 = center + Vector2(cos(angle) * size.x * 0.45, sin(angle * 1.2) * size.y * 0.25) * _mist
		var radius: float = size.x * (0.3 + 0.2 * fposmod(fi * 0.47, 1.0)) * (0.4 + 0.6 * _mist)
		_soft_puff(at, radius, _mist_color.lerp(_puff_color, fposmod(fi * 0.29, 1.0)), 0.5 * fade_in)
	var s: float = size.x * 0.045
	for i in BEE_SWARM_COUNT:
		var p: Vector2 = _bee_swarm_pos(i, _time)
		var dir: Vector2 = _bee_swarm_pos(i, _time + 0.05) - p
		_draw_bee(p, dir, s, fade_in, float(i) * 1.3)


func _draw_mist() -> void:
	# A soft wash up the whole column, thickest near the ground...
	var wash_steps := 8
	for i in wash_steps:
		var t: float = float(i) / float(wash_steps)
		var band_h: float = size.y / float(wash_steps)
		var alpha: float = (0.1 + 0.26 * t) * _mist
		draw_rect(Rect2(0.0, t * size.y, size.x, band_h + 1.0), Color(_mist_color.r, _mist_color.g, _mist_color.b, alpha))
	# ...with puffs drifting through it.
	for puff in _puffs:
		var drift: float = sin(_time * puff["speed"] + puff["phase"])
		var cx: float = size.x * (0.15 + 0.7 * puff["x"]) + drift * size.x * 0.08
		var cy: float = size.y * (0.2 + 0.75 * puff["y"]) + cos(_time * puff["speed"] * 0.7 + puff["phase"]) * size.y * 0.03
		var radius: float = size.x * puff["r"]
		draw_circle(Vector2(cx, cy), radius, Color(_mist_color.r, _mist_color.g, _mist_color.b, 0.2 * _mist))
		draw_circle(Vector2(cx, cy), radius * 0.6, Color(_puff_color.r, _puff_color.g, _puff_color.b, 0.15 * _mist))


## A lotus in the same violet as the mist. As a bud the three petal
## rows stand almost upright and close together; opened, the outer rows fan
## out to the sides.
func _draw_lotus() -> void:
	var ground := Vector2(size.x * 0.5, size.y - 4.0)

	var head := ground + Vector2(sin(_time * 1.2) * 1.5 * _rise, -size.x * 0.1 * _rise)
	draw_line(ground, head, _mist_color.darkened(0.5), 3.0, true)

	var base_len: float = size.x * 0.42 * (0.55 + 0.45 * _rise) * (1.0 + 0.2 * _open)
	var open_amount: float = 0.22 + 0.78 * _open
	for row in PETAL_ROWS:
		var count: int = row["count"]
		var length: float = base_len * row["length"]
		var width: float = length * (0.2 + 0.07 * _open)
		for i in count:
			var t: float = 0.5 if count == 1 else float(i) / float(count - 1)
			var angle: float = -PI * 0.5 + lerpf(-1.0, 1.0, t) * float(row["fan"]) * open_amount
			_draw_petal(head, angle, length, width, _mist_color.lightened(row["shade"]) if row["shade"] >= 0.0 else _mist_color.darkened(-row["shade"]))

	# A glowing heart - dim in the bud, bright once it has bloomed.
	var core_radius: float = size.x * (0.035 + 0.035 * _open)
	draw_circle(head, core_radius * 2.0, Color(_core_color.r, _core_color.g, _core_color.b, 0.2 + 0.3 * _open))
	draw_circle(head, core_radius, _core_color)


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
	draw_polyline(outline + PackedVector2Array([outline[0]]), _mist_color.darkened(0.55), 1.3, true)
	draw_line(origin + dir * length * 0.15, origin + dir * length * 0.85, color.lightened(0.22), 1.2, true)


## A bell flower in blood red: a stalk that arches over and a bell hanging
## mouth-down from its tip. As a bud the bell is a narrow closed teardrop;
## opened, it swells and its rim flares out, showing a pale inside and a
## glowing clapper hanging in the mouth.
func _draw_bell() -> void:
	var ground := Vector2(size.x * 0.5, size.y - 4.0)
	var sway: float = sin(_time * 1.2) * 1.5 * _rise
	var bell_h: float = size.x * 0.42 * (0.6 + 0.4 * _rise)
	var tip := Vector2(ground.x + size.x * 0.05 + sway, ground.y - size.x * 0.28 * _rise - bell_h)

	# The stalk bows away from the bell and curves back under its apex.
	var bow := Vector2(ground.x - size.x * 0.1 * _rise, (ground.y + tip.y) * 0.5)
	var stalk := PackedVector2Array()
	for i in 13:
		var t: float = float(i) / 12.0
		stalk.append(ground.lerp(bow, t).lerp(bow.lerp(tip, t), t))
	draw_polyline(stalk, _mist_color.darkened(0.55), 3.0, true)

	var mouth_half: float = size.x * (0.1 + 0.2 * _open)
	var flare: float = size.x * 0.07 * _open
	var steps := 10
	# Outline down the left side, along the flared rim, and back up the right.
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for i in steps + 1:
		var t: float = float(i) / float(steps)
		var half: float = mouth_half * (0.5 * pow(t, 0.6) + 0.5 * pow(t, 3.0))
		left.append(Vector2(tip.x - half, tip.y + t * bell_h))
		right.append(Vector2(tip.x + half, tip.y + t * bell_h))
	var mouth_y: float = tip.y + bell_h
	var outline := PackedVector2Array()
	outline.append_array(left)
	outline.append(Vector2(tip.x - mouth_half - flare, mouth_y + flare * 0.5))
	outline.append(Vector2(tip.x + mouth_half + flare, mouth_y + flare * 0.5))
	right.reverse()
	outline.append_array(right)

	# The dark inside of the mouth shows once it opens.
	if _open > 0.0:
		var inside := PackedVector2Array()
		for i in 13:
			var a: float = PI * float(i) / 12.0
			inside.append(Vector2(tip.x + cos(a) * (mouth_half + flare), mouth_y + flare * 0.25 + sin(a) * mouth_half * 0.28))
		draw_colored_polygon(inside, _mist_color.darkened(0.6))

	draw_colored_polygon(outline, _mist_color)
	draw_polyline(outline, _mist_color.darkened(0.55), 1.3, true)
	# A lighter sheen down the bell, and a ridge near the rim.
	draw_line(Vector2(tip.x - mouth_half * 0.3, tip.y + bell_h * 0.2), Vector2(tip.x - mouth_half * 0.45, tip.y + bell_h * 0.85), _mist_color.lightened(0.3), 2.0, true)
	draw_line(Vector2(tip.x - mouth_half * 0.97, mouth_y - bell_h * 0.08), Vector2(tip.x + mouth_half * 0.97, mouth_y - bell_h * 0.08), _mist_color.darkened(0.3), 1.5, true)

	# The clapper: a glowing bead hanging in the mouth - dim in the bud, bright
	# once it has bloomed.
	var clapper := Vector2(tip.x + sin(_time * 2.0) * size.x * 0.02 * _open, mouth_y + size.x * (0.03 + 0.05 * _open))
	draw_line(Vector2(tip.x, tip.y + bell_h * 0.45), clapper, _mist_color.darkened(0.4), 1.5, true)
	var core_radius: float = size.x * (0.03 + 0.03 * _open)
	draw_circle(clapper, core_radius * 2.0, Color(_core_color.r, _core_color.g, _core_color.b, 0.2 + 0.3 * _open))
	draw_circle(clapper, core_radius, _core_color)
