class_name SanguineBloomFX
extends Node2D

## Purely cosmetic: the Rootmother's Sanguine Bloom, planted.
##
##   1. The seed: a dark, thorned pod flung from her hand in a high arc to
##      the target, spinning, trailing a few red motes.
##   2. The planting: it lands with a burst of soil and spores and a ring
##      rolling out across the ground, and the bloom takes root.
##   3. The bloom: thorned roots grip the ground round a swollen knot, and
##      a cup of thick, veined petals pushes up out of it, opening slowly
##      around a faint red light, thin filaments curling from its heart.
##      It stays on the target for as long as the damage-over-time lasts,
##      breathing, and flexes open with a flush of light along its veins
##      each time it drains the target (pulse_on()).
##   4. The wilt: when the effect ends the petals sag and darken to the
##      colour of dead leaves, and it fades away (wither_on()).
##
## The bloom is a child of the target's sprite, so it follows it around and
## goes with it when it dies. battle.gd drives it: plant() on the cast,
## pulse_on() on every tick, wither_on() when the last tick is done.

const MARK_NAME := "SanguineBloomMark"
## Where on the target's sprite the bloom takes root (fractions of its
## size) - low, and toward the hero, so it doesn't cover the creature.
const ROOT_ANCHOR := Vector2(0.25, 0.9)

const FLIGHT_TIME := 0.45
const RING_TIME := 0.4
const GROW_TIME := 1.0
const WITHER_TIME := 0.8

# Muted, wet and dark - the bloom should look grown, not drawn.
const PETAL_BASE := Color(0.13, 0.025, 0.04)
const PETAL_MID := Color(0.42, 0.05, 0.08)
const PETAL_TIP := Color(0.66, 0.15, 0.13)
const PETAL_DEAD := Color(0.24, 0.17, 0.12)
const LIGHT := Color(0.95, 0.28, 0.14)
const VEIN := Color(0.85, 0.3, 0.22)
const ROOT := Color(0.15, 0.1, 0.07)
const MOSS := Color(0.27, 0.31, 0.12)
const SOIL := Color(0.26, 0.17, 0.1)
const SEED_DARK := Color(0.2, 0.04, 0.06)
const SEED_MID := Color(0.5, 0.08, 0.1)

const LAYER_SHADE := [0.5, 0.78, 1.0]
const ROOT_COUNT := 6

var _mode := "seed"
var _age := 0.0

# Seed.
var _target: Control
var _from: Vector2
var _land: Vector2
var _ctrl: Vector2
var _seed_pos: Vector2
var _landed := false
var _ring_age := 0.0
var _trail: CPUParticles2D

# Bloom.
var _height := 60.0
var _phase := 0.0
var _pulse := 0.0
var _wither_t := -1.0
var _glow: Node2D
var _motes: CPUParticles2D
var _petals: Array[Dictionary] = []
var _filaments: Array[Dictionary] = []
var _roots: Array[Dictionary] = []


## Flings a seed from `from` (global) to `target`'s sprite and plants a
## bloom there, under `host`. Re-planting on a target that already carries
## a bloom just revives and flexes it.
static func plant(host: Node, from: Vector2, target: Control) -> void:
	if host == null or not is_instance_valid(target):
		return
	var fx := SanguineBloomFX.new()
	fx._mode = "seed"
	fx._target = target
	fx._from = from
	fx._land = target.global_position + target.size * ROOT_ANCHOR
	var dist := from.distance_to(fx._land)
	fx._ctrl = (from + fx._land) * 0.5 + Vector2(0.0, -clampf(dist * 0.4, 50.0, 140.0))
	fx._seed_pos = from
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


## The bloom on `node`, if it has one.
static func of(node: Variant) -> SanguineBloomFX:
	if node == null or not is_instance_valid(node) or not (node is Node):
		return null
	return (node as Node).get_node_or_null(MARK_NAME) as SanguineBloomFX


## Flexes `node`'s bloom as it drains the target.
static func pulse_on(node: Variant) -> void:
	var mark := of(node)
	if mark != null:
		mark._pulse = 1.0


## Wilts and removes `node`'s bloom.
static func wither_on(node: Variant) -> void:
	var mark := of(node)
	if mark != null and mark._wither_t < 0.0:
		mark._wither_t = 0.0
		if is_instance_valid(mark._motes):
			mark._motes.emitting = false


func _ready() -> void:
	if _mode == "seed":
		_trail = _make_motes(14, 0.5)
		_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
		_trail.gravity = Vector2.ZERO
		_trail.spread = 180.0
		_trail.initial_velocity_min = 6.0
		_trail.initial_velocity_max = 22.0
		_trail.position = _from
		add_child(_trail)
		_trail.emitting = true
		return

	_phase = randf() * TAU
	var h := _height
	# The cup: three layers of petals, the back ones tallest and darkest,
	# the front ones short and lit - each a little different from the rest.
	var counts := [5, 4, 3]
	var lengths := [1.1, 0.88, 0.64]
	var spreads := [0.95, 0.78, 0.55]
	for layer in 3:
		for i in int(counts[layer]):
			var f := (float(i) + 0.5) / float(counts[layer]) * 2.0 - 1.0
			_petals.append({
				"layer": layer,
				"theta": f * float(spreads[layer]) + randf_range(-0.12, 0.12),
				"length": h * float(lengths[layer]) * randf_range(0.88, 1.08),
				"width": h * 0.2 * randf_range(0.85, 1.15),
				"bend": randf_range(0.1, 0.3),
				"phase": randf() * TAU,
			})
	for i in 6:
		_filaments.append({
			"theta": randf_range(-0.5, 0.5),
			"length": h * randf_range(0.45, 0.8),
			"curl": randf_range(-1.0, 1.0),
			"phase": randf() * TAU,
		})
	for i in ROOT_COUNT:
		var side := -1.0 if i % 2 == 0 else 1.0
		_roots.append({
			"dir": Vector2(side * randf_range(0.55, 1.0), randf_range(0.0, 0.32)).normalized(),
			"length": h * randf_range(0.55, 0.95),
			"seed": randf() * TAU,
		})

	_glow = Node2D.new()
	_glow.material = _additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	_motes = _make_motes(4, 2.2)
	_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_motes.emission_sphere_radius = h * 0.1
	_motes.direction = Vector2(0.0, -1.0)
	_motes.spread = 35.0
	_motes.gravity = Vector2(0.0, -5.0)
	_motes.initial_velocity_min = 3.0
	_motes.initial_velocity_max = 9.0
	_motes.position = Vector2(0.0, -h * 0.4)
	add_child(_motes)
	_motes.emitting = true


func _process(delta: float) -> void:
	_age += delta
	if _mode == "seed":
		_process_seed(delta)
	else:
		_process_bloom(delta)


# --- the seed -------------------------------------------------------

func _process_seed(delta: float) -> void:
	if not _landed:
		var t := clampf(_age / FLIGHT_TIME, 0.0, 1.0)
		var e := t * t * (3.0 - 2.0 * t)
		var u := 1.0 - e
		_seed_pos = _from * u * u + _ctrl * 2.0 * u * e + _land * e * e
		_trail.position = _seed_pos
		if t >= 1.0:
			_land_now()
	else:
		_ring_age += delta
		if _ring_age >= RING_TIME:
			queue_free()
			return
	queue_redraw()


## The seed hits the ground: soil and spores burst up, the bloom takes root.
func _land_now() -> void:
	_landed = true
	_trail.emitting = false
	for pass_i in 2:
		var p := CPUParticles2D.new()
		p.one_shot = true
		p.explosiveness = 0.95
		p.amount = 14 if pass_i == 0 else 8
		p.lifetime = 0.5 if pass_i == 0 else 0.9
		p.spread = 70.0
		p.direction = Vector2(0.0, -1.0)
		p.gravity = Vector2(0.0, 320.0) if pass_i == 0 else Vector2(0.0, -24.0)
		p.initial_velocity_min = 50.0 if pass_i == 0 else 14.0
		p.initial_velocity_max = 150.0 if pass_i == 0 else 55.0
		p.scale_amount_min = 1.6
		p.scale_amount_max = 3.2
		p.color = SOIL if pass_i == 0 else Color(0.6, 0.12, 0.1, 0.8)
		add_child(p)
		p.global_position = _land
		p.emitting = true
		p.finished.connect(p.queue_free)

	if not is_instance_valid(_target):
		return
	var existing := SanguineBloomFX.of(_target)
	if existing != null:
		existing._wither_t = -1.0
		existing.modulate.a = 1.0
		existing._pulse = 1.0
		if is_instance_valid(existing._motes):
			existing._motes.emitting = true
		return
	var mark := SanguineBloomFX.new()
	mark._mode = "bloom"
	mark.name = MARK_NAME
	mark._height = clampf(_target.size.y * 0.34, 38.0, 85.0)
	mark.position = _target.size * ROOT_ANCHOR
	_target.add_child(mark)


func _draw() -> void:
	if _mode == "seed":
		_draw_seed()
	else:
		_draw_bloom()


func _draw_seed() -> void:
	if not _landed:
		# A dark, thorned pod spinning as it flies, a dull red light
		# seeping from its seams.
		var rot := _age * 13.0
		draw_circle(_seed_pos, 8.0, Color(LIGHT, 0.1))
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for i in 12:
			var a := TAU * i / 12.0
			var v := Vector2(cos(a) * 6.5, sin(a) * 4.2 * (1.0 - 0.3 * cos(a)))
			pts.append(_seed_pos + v.rotated(rot))
			cols.append(SEED_MID if cos(a) > 0.0 else SEED_DARK)
		draw_polygon(pts, cols)
		draw_line(_seed_pos + Vector2(-5.0, 0.0).rotated(rot), _seed_pos + Vector2(5.0, 0.0).rotated(rot), Color(LIGHT, 0.45), 1.0, true)
		for k in 3:
			var ta := rot + TAU * k / 3.0
			var base := _seed_pos + Vector2.from_angle(ta) * 5.2
			draw_colored_polygon(PackedVector2Array([
				base + Vector2.from_angle(ta + 1.57) * 1.3,
				base + Vector2.from_angle(ta) * 4.2,
				base + Vector2.from_angle(ta - 1.57) * 1.3]), ROOT)
		return
	# The ring rolling out over the ground where it landed.
	var f := clampf(_ring_age / RING_TIME, 0.0, 1.0)
	var r := 10.0 + 34.0 * (1.0 - pow(1.0 - f, 2.0))
	var ring := PackedVector2Array()
	for i in 33:
		var a := TAU * i / 32.0
		ring.append(_land + Vector2(cos(a) * r, sin(a) * r * 0.35))
	draw_polyline(ring, Color(VEIN, 0.5 * (1.0 - f)), 2.0 * (1.0 - f) + 0.5, true)


# --- the bloom ------------------------------------------------------

func _process_bloom(delta: float) -> void:
	_pulse = move_toward(_pulse, 0.0, delta / 0.6)
	if _wither_t >= 0.0:
		_wither_t += delta
		var w := clampf(_wither_t / WITHER_TIME, 0.0, 1.0)
		modulate.a = 1.0 - w * w
		if w >= 1.0:
			queue_free()
			return
	queue_redraw()
	if is_instance_valid(_glow):
		_glow.queue_redraw()


func _grow() -> float:
	var g := clampf(_age / GROW_TIME, 0.0, 1.0)
	return 1.0 - pow(1.0 - g, 3.0)


func _wither() -> float:
	if _wither_t < 0.0:
		return 0.0
	return clampf(_wither_t / WITHER_TIME, 0.0, 1.0)


## How far the cup has opened (0 = a closed bud pushing out of the knot).
func _open() -> float:
	return smoothstep(0.35, 1.0, _grow())


## The middle of the cup, where the light seeps from.
func _heart() -> Vector2:
	return Vector2(0.0, -_height * 0.36 * (0.5 + 0.5 * _grow()))


func _draw_bloom() -> void:
	var g := _grow()
	var h := _height
	var wilt := _wither()

	# A scuffed patch of disturbed soil round the base.
	var soil := PackedVector2Array()
	for i in 17:
		var a := TAU * i / 16.0
		soil.append(Vector2(cos(a) * h * 0.42, sin(a) * h * 0.1 + h * 0.02))
	draw_colored_polygon(soil, Color(SOIL, 0.55 * g))

	_draw_roots(g)

	# The cup: back petals first, the heart's light between them and the
	# front ones, then the filaments rising out of it.
	for p in _petals:
		if int(p["layer"]) == 0:
			_draw_petal(p, g, wilt)
	_draw_heart_light(g, wilt)
	_draw_filaments(g, wilt)
	for p in _petals:
		if int(p["layer"]) == 1:
			_draw_petal(p, g, wilt)
	for p in _petals:
		if int(p["layer"]) == 2:
			_draw_petal(p, g, wilt)

	# The knot it all grows out of: a swollen, ridged bulb, mossy and wet.
	if g > 0.05:
		var knot := PackedVector2Array()
		var knot_cols := PackedColorArray()
		for i in 14:
			var a := TAU * i / 14.0
			knot.append(Vector2(cos(a) * h * 0.2, sin(a) * h * 0.1 - h * 0.03) * g)
			knot_cols.append(ROOT.lerp(MOSS, 0.5 if sin(a) < 0.0 else 0.1))
		draw_polygon(knot, knot_cols)
		for i in 3:
			var kx := (float(i) - 1.0) * h * 0.09 * g
			draw_line(Vector2(kx, -h * 0.1 * g), Vector2(kx * 1.3, h * 0.03 * g), Color(0.05, 0.03, 0.02, 0.6), 1.0, true)


## Thorned, mossy roots gripping the ground and creeping outward, thinning
## to the tips, a tiny thorn here and there.
func _draw_roots(g: float) -> void:
	var root_g := clampf(g / 0.55, 0.0, 1.0)
	root_g = 1.0 - pow(1.0 - root_g, 2.0)
	for r in _roots:
		var dir: Vector2 = r["dir"]
		var length: float = float(r["length"]) * root_g
		var root_seed: float = r["seed"]
		var prev := Vector2.ZERO
		for k in range(1, 9):
			var s := float(k) / 8.0
			var wave := sin(s * 6.0 + root_seed) * 2.2 * s
			var p := Vector2(dir.x * length * s, dir.y * length * s * 0.6 + wave)
			var width := lerpf(3.4, 0.8, s)
			var col := ROOT.lerp(MOSS, 0.35 * smoothstep(0.3, 0.9, sin(s * 9.0 + root_seed) * 0.5 + 0.5))
			draw_line(prev, p, col, width, true)
			if k % 2 == 0 and k < 8:
				var n := (p - prev).normalized().orthogonal() * (1.0 if k % 4 == 0 else -1.0)
				draw_colored_polygon(PackedVector2Array([
					p - (p - prev).normalized() * 1.5, p + n * 3.8, p + (p - prev).normalized() * 1.5]), ROOT.darkened(0.2))
			prev = p


## One thick, veined petal: a curved teardrop shaded from a near-black
## base through deep crimson to a dull, wet red tip, edges darker than the
## midrib, veins catching the light.
func _draw_petal(p: Dictionary, g: float, wilt: float) -> void:
	var layer: int = p["layer"]
	var open := _open()
	var theta: float = p["theta"]
	# Closed bud -> opening cup -> sagging petals as it wilts.
	theta *= lerpf(0.18, 1.0, open) * (1.0 + 0.2 * _pulse)
	theta *= 1.0 + 0.9 * wilt
	theta += sin(_age * 0.9 + float(p["phase"])) * 0.035
	theta = clampf(theta, -1.9, 1.9)
	var length: float = float(p["length"]) * lerpf(0.45, 1.0, g) * (1.0 - 0.3 * wilt)
	var width: float = float(p["width"]) * lerpf(0.7, 1.0, open)
	var bend: float = float(p["bend"])
	var shade: float = LAYER_SHADE[layer]

	var dir := Vector2(sin(theta), -cos(theta))
	var out := Vector2(signf(theta) if absf(theta) > 0.001 else 0.0, 0.0)
	var n_seg := 6
	var centers: Array[Vector2] = []
	var normals: Array[Vector2] = []
	var widths: Array[float] = []
	for i in n_seg + 1:
		var s := float(i) / n_seg
		var c := dir * length * s + out * bend * length * s * s * 0.5
		var tangent := dir * length + out * bend * length * s
		centers.append(c)
		normals.append(tangent.normalized().orthogonal())
		widths.append(width * sin(PI * pow(maxf(s, 0.001), 0.75)) * (1.0 - 0.25 * s) + 0.35 + 0.6 * (1.0 - s))
	for i in n_seg:
		var s0 := float(i) / n_seg
		var s1 := float(i + 1) / n_seg
		for half in [-1.0, 1.0]:
			var q := PackedVector2Array([
				centers[i], centers[i] + normals[i] * widths[i] * half,
				centers[i + 1] + normals[i + 1] * widths[i + 1] * half, centers[i + 1]])
			var cols := PackedColorArray([
				_petal_color(s0, 0.0, shade, wilt), _petal_color(s0, 1.0, shade, wilt),
				_petal_color(s1, 1.0, shade, wilt), _petal_color(s1, 0.0, shade, wilt)])
			draw_polygon(q, cols)
	# Veins: a midrib and two side veins, flushing with light on each pulse.
	if layer > 0:
		var flush := 0.2 + 0.55 * _pulse
		for v in [-0.45, 0.0, 0.45]:
			var line := PackedVector2Array()
			for i in range(1, n_seg):
				line.append(centers[i] + normals[i] * widths[i] * float(v))
			if line.size() > 1:
				draw_polyline(line, Color(VEIN, flush * shade * (1.0 - wilt)), 1.0, true)


## Colour at `s` (0 base .. 1 tip) and `e` (0 midrib .. 1 edge).
func _petal_color(s: float, e: float, shade: float, wilt: float) -> Color:
	var c := PETAL_BASE.lerp(PETAL_MID, smoothstep(0.0, 0.5, s)).lerp(PETAL_TIP, smoothstep(0.45, 1.0, s) * 0.85)
	c = c.lerp(PETAL_BASE, e * e * 0.55)
	c = c.lightened(0.18 * (1.0 - e) * smoothstep(0.2, 0.7, s))
	c = c.lerp(PETAL_DEAD, wilt)
	return Color(c.r * shade, c.g * shade, c.b * shade, 1.0)


## The faint red light inside the cup, brightening with each pulse.
func _draw_heart_light(g: float, wilt: float) -> void:
	var c := _heart()
	var r := _height * 0.3 * _open()
	if r < 1.0:
		return
	var strength := (0.4 + 0.45 * _pulse) * (1.0 - wilt) * (0.85 + 0.15 * sin(_age * 2.0 + _phase))
	# A soft radial glow, as a fan of triangles (a fan drawn as one polygon
	# has its centre on the outline, which the triangulator rejects).
	var centre_col := Color(LIGHT, 0.55 * strength)
	var rim_col := Color(LIGHT, 0.0)
	for i in 16:
		var a0 := TAU * i / 16.0
		var a1 := TAU * (i + 1) / 16.0
		draw_polygon(PackedVector2Array([
			c, c + Vector2(cos(a0) * r * 0.8, sin(a0) * r), c + Vector2(cos(a1) * r * 0.8, sin(a1) * r)]),
			PackedColorArray([centre_col, rim_col, rim_col]))


## Thin filaments curling up out of the heart, swaying.
func _draw_filaments(g: float, wilt: float) -> void:
	var open := _open()
	if open < 0.15:
		return
	var base := _heart()
	for f in _filaments:
		var length: float = float(f["length"]) * open * (1.0 - 0.6 * wilt)
		var theta: float = f["theta"]
		var curl: float = f["curl"]
		var phase: float = f["phase"]
		var prev := base
		for k in range(1, 8):
			var s := float(k) / 7.0
			var sway := sin(_age * 1.1 + phase + s * 2.0) * 0.06
			var p := base + Vector2((theta + sway) * length * s + curl * length * 0.22 * s * s, -length * s * (1.0 - 0.3 * s))
			draw_line(prev, p, Color(0.3, 0.06, 0.07, 0.85 * (1.0 - wilt)), lerpf(1.4, 0.6, s), true)
			prev = p


## A very low red light in the cup and along the roots, and a ripple of
## blood-light across the ground on each pulse.
func _draw_glow() -> void:
	var open := _open()
	var keep := 1.0 - _wither()
	var h := _height
	var c := _heart()
	var breathe := 0.8 + 0.2 * sin(_age * 2.0 + _phase)
	var strength := (0.35 + 0.65 * open) * keep
	_glow.draw_circle(c, h * 0.85, Color(LIGHT, 0.03 * strength * breathe))
	_glow.draw_circle(c, h * 0.4, Color(LIGHT, (0.06 + 0.1 * _pulse) * strength * breathe))
	# Beads of light on the filaments' tips.
	if open > 0.3:
		for f in _filaments:
			var length: float = float(f["length"]) * open
			var s := 1.0
			var sway := sin(_age * 1.1 + float(f["phase"]) + s * 2.0) * 0.06
			var tip := c + Vector2((float(f["theta"]) + sway) * length + float(f["curl"]) * length * 0.22, -length * 0.7)
			_glow.draw_circle(tip, 1.6, Color(LIGHT, 0.5 * strength))
	# Blood-light drawn up the roots toward the knot.
	var root_g := clampf(_grow() / 0.55, 0.0, 1.0)
	for r in _roots:
		var dir: Vector2 = r["dir"]
		var length: float = float(r["length"]) * root_g
		var s := 1.0 - fposmod(_age * 0.6 + float(r["seed"]), 1.0)
		_glow.draw_circle(Vector2(dir.x * length * s, dir.y * length * s * 0.6), 1.5, Color(LIGHT, 0.45 * keep * root_g))
	if _pulse > 0.01:
		var f := 1.0 - _pulse
		var ring := PackedVector2Array()
		for i in 33:
			var a := TAU * i / 32.0
			ring.append(Vector2(cos(a) * h * (0.3 + 0.9 * f), sin(a) * h * (0.3 + 0.9 * f) * 0.3))
		_glow.draw_polyline(ring, Color(VEIN, 0.5 * _pulse), 1.5, true)


# --- helpers --------------------------------------------------------

func _make_motes(amount: int, lifetime: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.material = _additive()
	p.texture = _dot()
	p.amount = amount
	p.lifetime = lifetime
	p.scale_amount_min = 0.15
	p.scale_amount_max = 0.38
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(LIGHT, 0.0), Color(LIGHT, 0.55), Color(VEIN, 0.3), Color(VEIN, 0.0)])
	p.color_ramp = ramp
	p.emitting = false
	return p


static func _dot() -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 32
	t.height = 32
	return t


static func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m
