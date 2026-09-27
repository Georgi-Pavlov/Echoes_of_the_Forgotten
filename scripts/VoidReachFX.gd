class_name VoidReachFX
extends Node2D

## Purely cosmetic: Nhal's Touch of the First Cold - "The Reaching Void".
##
##   1. Gather: a shard of Nhal's void forms at his hand - a dark crystal
##      with stars in it, rimmed in frost - drawing warmth in toward it.
##   2. Reach: a limb of void stretches from it to the target along a
##      slight arc - black, nebula-tinted, stars drifting along it, an
##      icy rim down both edges - splitting into three talons at its tip
##      and shedding frozen stardust that hangs and falls.
##   3. The touch: the talons close and plunge into the target. The
##      target's silhouette turns to void for a moment (hollowed out by
##      the cold before flesh), the whole scene freezes for a heartbeat,
##      the target is thrown back and snaps into place, ice shards and a
##      cold shockwave burst out of it, and its warmth - embers - is
##      pulled out of it, turning pale blue as it rises and winks out.
##   4. The limb dissolves into falling stardust.
##
## Damage, and anything else gameplay-side, is the caller's: `on_hit`
## fires at the moment of the touch.

const GATHER_TIME := 0.3
const REACH_TIME := 0.35
const HOLD_TIME := 0.22
const DISSOLVE_TIME := 0.45
const SEGMENTS := 30

const HIT_STOP_SCALE := 0.05
const HIT_STOP_SECONDS := 0.07       # real time
const KNOCKBACK := 0.16              # fraction of the target's width
const HOLLOW_HOLD := 0.22

const VOID := Color(0.03, 0.02, 0.08)
const VIOLET := Color(0.38, 0.12, 0.62)
const BLUE := Color(0.12, 0.3, 0.85)
const RIM := Color(0.72, 0.88, 1.0)
const GLOW := Color(0.45, 0.55, 1.0)
const STAR := Color(0.9, 0.93, 1.0)
const EMBER := Color(1.0, 0.55, 0.2)
const FROST := Color(0.8, 0.93, 1.0)

const SILHOUETTE_SHADER := preload("res://shaders/void_silhouette.gdshader")

var _from: Vector2
var _to: Vector2
var _target: TextureRect
var _on_hit: Callable
var _age := 0.0
var _hit_done := false
var _phase := 0.0
var _bow := 0.0
var _star_seeds: Array[Vector2] = []
var _glow: Node2D
var _body: Node2D
var _trail: CPUParticles2D
var _ring_age := -1.0


## Plays one reach from `from` to `to` (global positions) under `host`.
## `target` (the struck unit's sprite, if any) is what gets hollowed out
## and thrown back. `on_hit` fires the moment the talons strike.
static func play(host: Node, from: Vector2, to: Vector2, target: Variant, on_hit: Callable = Callable()) -> void:
	var fx := VoidReachFX.new()
	fx._from = from
	fx._to = to
	fx._target = target if is_instance_valid(target) and target is TextureRect else null
	fx._on_hit = on_hit
	fx._phase = randf() * TAU
	# Arcs up and over, a little more for longer reaches.
	fx._bow = clampf(from.distance_to(to) * 0.12, 14.0, 60.0)
	for i in 14:
		fx._star_seeds.append(Vector2(randf(), randf_range(-0.7, 0.7)))
	host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	_body = Node2D.new()
	_body.draw.connect(_draw_body)
	add_child(_body)
	# Glow and rims add light, over the body.
	_glow = Node2D.new()
	_glow.material = _additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)

	# Warmth drawn in toward the shard as it forms.
	var drain := _particles(0.35, 18)
	drain.position = _from
	drain.one_shot = true
	drain.explosiveness = 0.5
	drain.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	drain.emission_sphere_radius = 46.0
	drain.initial_velocity_min = 0.0
	drain.initial_velocity_max = 0.0
	drain.radial_accel_min = -700.0
	drain.radial_accel_max = -500.0
	drain.scale_amount_min = 0.5
	drain.scale_amount_max = 1.0
	drain.color_ramp = _ramp([EMBER, FROST, Color(GLOW, 0.0)], [0.0, 0.6, 1.0], true)
	drain.emitting = true
	_free_later(drain, 0.6)

	# Frozen stardust shed from the tip as it reaches.
	_trail = _particles(0.9, 80)
	_trail.position = _from
	_trail.gravity = Vector2(0.0, 70.0)
	_trail.spread = 180.0
	_trail.initial_velocity_min = 5.0
	_trail.initial_velocity_max = 25.0
	_trail.scale_amount_min = 0.45
	_trail.scale_amount_max = 1.0
	_trail.color_ramp = _ramp([STAR, Color(RIM, 0.8), Color(VIOLET, 0.0)], [0.0, 0.5, 1.0])
	_trail.emitting = false


func _process(delta: float) -> void:
	_age += delta
	var reach_start := GATHER_TIME
	var hit_at := GATHER_TIME + REACH_TIME
	if _age >= reach_start and _age < hit_at:
		_trail.emitting = true
		_trail.position = _point(_state().x)
	elif _trail.emitting:
		_trail.emitting = false
	if not _hit_done and _age >= hit_at:
		_hit_done = true
		_impact()
	if _ring_age >= 0.0:
		_ring_age += delta
	if _age >= hit_at + HOLD_TIME + DISSOLVE_TIME:
		_trail.emitting = false
		_free_later(_trail, _trail.lifetime + 0.1)
		queue_free()
		return
	_glow.queue_redraw()
	_body.queue_redraw()


## x: how far the limb reaches (0 = at the shard, 1 = at the target,
## a little past once it plunges in); y: how solid it is; z: how far it
## has dissolved; w: how formed the shard is.
func _state() -> Vector4:
	var shard := clampf(_age / GATHER_TIME, 0.0, 1.0)
	var grow := clampf((_age - GATHER_TIME) / REACH_TIME, 0.0, 1.0)
	grow = 1.0 - pow(1.0 - grow, 2.2)
	var plunge := clampf((_age - GATHER_TIME - REACH_TIME) / 0.08, 0.0, 1.0)
	var fade := clampf((_age - GATHER_TIME - REACH_TIME - HOLD_TIME) / DISSOLVE_TIME, 0.0, 1.0)
	return Vector4(grow + 0.06 * plunge, 1.0 - fade * fade, fade, shard)


## Point `t` (0..1+) along the limb: a gentle arc up and over, with a
## slow ripple running along it, pinned at the shard.
func _point(t: float) -> Vector2:
	var dir := _to - _from
	var normal := Vector2(-dir.y, dir.x).normalized()
	var arc := -_bow * 4.0 * t * (1.0 - t)
	var ripple := sin(t * TAU * 1.3 + _phase - _age * 6.0) * 8.0 * sin(clampf(t, 0.0, 1.0) * PI)
	return _from + dir * t + Vector2(0.0, arc) + normal * ripple


func _points() -> PackedVector2Array:
	var reach := _state().x
	var pts := PackedVector2Array()
	for i in SEGMENTS + 1:
		pts.append(_point(float(i) / SEGMENTS * reach))
	return pts


## Half-width at `k` (0 = the shard, 1 = the tip).
func _half_width(k: float) -> float:
	# Swells out of the shard, then tapers toward the talons.
	return lerpf(14.0, 4.5, pow(k, 0.85)) * (0.35 + 0.65 * smoothstep(0.0, 0.1, k))


func _normals(pts: PackedVector2Array) -> PackedVector2Array:
	var normals := PackedVector2Array()
	var n := pts.size()
	for i in n:
		var d := pts[mini(i + 1, n - 1)] - pts[maxi(i - 1, 0)]
		normals.append(d.orthogonal().normalized() if d.length() > 0.0001 else Vector2.UP)
	return normals


## The three talons at the tip: each a curved, tapering hook, spread
## wide as it reaches and closing as it plunges in. Returns one polygon
## per talon.
func _talons(tip: Vector2, dir: Vector2) -> Array[PackedVector2Array]:
	var close := clampf((_age - GATHER_TIME - REACH_TIME + 0.05) / 0.12, 0.0, 1.0)
	var spread := lerpf(0.7, 0.24, close)
	var length := lerpf(36.0, 28.0, close)
	var result: Array[PackedVector2Array] = []
	for j in 3:
		var side := float(j - 1)
		var a := dir.angle() + side * spread
		var base_dir := Vector2.from_angle(a)
		var n := base_dir.orthogonal()
		var left := PackedVector2Array()
		var right := PackedVector2Array()
		for i in 7:
			var k := float(i) / 6.0
			# Hooks inward toward the middle talon as it goes.
			var hook := -side * k * k * length * 0.45
			var c := tip + base_dir * k * length * (1.0 if side == 0.0 else 0.9) + n * hook
			var w := lerpf(5.5, 0.0, pow(k, 0.8))
			left.append(c + n * w)
			right.append(c - n * w)
		right.reverse()
		left.append_array(right)
		result.append(left)
	return result


## The shard of void at Nhal's hand: a tall, jagged diamond.
func _shard(size: float) -> PackedVector2Array:
	var c := _from
	return PackedVector2Array([
		c + Vector2(0.0, -size * 1.4), c + Vector2(size * 0.55, -size * 0.3),
		c + Vector2(size * 0.4, size * 0.5), c + Vector2(0.0, size * 1.1),
		c + Vector2(-size * 0.5, size * 0.35), c + Vector2(-size * 0.45, -size * 0.45),
	])


func _draw_body() -> void:
	var s := _state()
	var solid := s.y
	# The shard: forming, then fading as the limb dissolves.
	var shard_size := 16.0 * (1.0 - pow(1.0 - s.w, 2.0)) * (1.0 - s.z)
	if shard_size > 0.5:
		_body.draw_colored_polygon(_shard(shard_size), Color(VOID, 0.95))
	if s.x <= 0.0:
		return
	var pts := _points()
	var normals := _normals(pts)
	# The limb: solid void, nebula colors drifting through it.
	for i in pts.size() - 1:
		var k0 := float(i) / SEGMENTS
		var k1 := float(i + 1) / SEGMENTS
		var w0 := _half_width(k0) * (1.0 - 0.6 * s.z)
		var w1 := _half_width(k1) * (1.0 - 0.6 * s.z)
		var c0 := _void_color(k0, solid)
		var c1 := _void_color(k1, solid)
		_body.draw_primitive(PackedVector2Array([pts[i] + normals[i] * w0, pts[i + 1] + normals[i + 1] * w1,
				pts[i + 1] - normals[i + 1] * w1, pts[i] - normals[i] * w0]),
				PackedColorArray([c0, c1, c1, c0]), PackedVector2Array())
	var tip := pts[pts.size() - 1]
	var dir := (pts[pts.size() - 1] - pts[pts.size() - 2]).normalized()
	for talon in _talons(tip, dir):
		_body.draw_colored_polygon(talon, Color(VOID, 0.95 * solid))


func _void_color(k: float, alpha: float) -> Color:
	var n := 0.5 + 0.5 * sin(k * 9.0 + _phase - _age * 5.0)
	var m := 0.5 + 0.5 * sin(k * 5.0 - _phase + _age * 2.5)
	# Mostly black, nebula patches drifting through it.
	var patch := pow(n, 4.0)
	var c := VOID.lerp(VIOLET, patch * 0.6).lerp(BLUE, m * patch * 0.5)
	return Color(c, 0.95 * alpha)


func _draw_glow() -> void:
	var s := _state()
	# The shard's frost rim, glow and a star in its heart.
	var shard_size := 16.0 * (1.0 - pow(1.0 - s.w, 2.0)) * (1.0 - s.z)
	if shard_size > 0.5:
		var outline := _shard(shard_size)
		outline.append(outline[0])
		_glow.draw_circle(_from, shard_size * 2.8, Color(GLOW, 0.18))
		_glow.draw_polyline(outline, Color(RIM, 0.85), 1.4, true)
		var tw := 0.5 + 0.5 * sin(_age * 18.0)
		_glow.draw_circle(_from + Vector2(0.0, -shard_size * 0.2), 1.2 + tw, Color(STAR, 0.9))
	if s.x <= 0.0:
		return
	var pts := _points()
	var normals := _normals(pts)
	var solid := s.y
	# A faint cold halo, then an icy rim down both edges.
	for i in pts.size() - 1:
		var k := float(i) / SEGMENTS
		var w := _half_width(k) * (1.0 - 0.6 * s.z)
		_glow.draw_line(pts[i], pts[i + 1], Color(GLOW, 0.05 * solid), w * 3.0)
		_glow.draw_line(pts[i] + normals[i] * w, pts[i + 1] + normals[i + 1] * w, Color(RIM, 0.75 * solid), 1.3, true)
		_glow.draw_line(pts[i] - normals[i] * w, pts[i + 1] - normals[i + 1] * w, Color(RIM, 0.75 * solid), 1.3, true)
	# Stars drifting along it toward the target, twinkling.
	for star in _star_seeds:
		var t := fmod(star.x + _age * 0.9, 1.0) * s.x
		var k := t / maxf(s.x, 0.001)
		var i := clampi(int(t / maxf(s.x, 0.001) * SEGMENTS), 0, pts.size() - 1)
		var p := _point(t) + normals[i] * star.y * _half_width(k) * 0.7
		var tw := 0.5 + 0.5 * sin(_age * 14.0 + star.x * 40.0)
		_glow.draw_circle(p, 0.8 + 0.8 * tw, Color(STAR, 0.9 * tw * solid))
	# Rims on the talons.
	var tip := pts[pts.size() - 1]
	var dir := (pts[pts.size() - 1] - pts[pts.size() - 2]).normalized()
	for talon in _talons(tip, dir):
		var closed := talon.duplicate()
		closed.append(talon[0])
		_glow.draw_polyline(closed, Color(RIM, 0.9 * solid), 1.2, true)
	# The cold shockwave from the touch: a flattened ring racing out.
	if _ring_age >= 0.0 and _ring_age < 0.4:
		var r := _ring_age / 0.4
		var radius := 12.0 + 90.0 * (1.0 - pow(1.0 - r, 2.0))
		var ring := PackedVector2Array()
		for j in 41:
			var a := TAU * j / 40.0
			ring.append(_to + Vector2(cos(a) * radius, sin(a) * radius * 0.45))
		_glow.draw_polyline(ring, Color(RIM, 0.8 * (1.0 - r)), 3.0 * (1.0 - r) + 1.0, true)
		_glow.draw_circle(_to, 30.0 * (1.0 - r), Color(GLOW, 0.4 * (1.0 - r)))


## The touch itself.
func _impact() -> void:
	_ring_age = 0.0
	_hit_stop()
	_burst_shards()
	if _target != null and is_instance_valid(_target):
		hollow_out(_target)
		_knock_back(_target)
		_drain_warmth(_target)
	if _on_hit.is_valid():
		_on_hit.call()


## A heartbeat's freeze of everything at the moment of the touch. Put
## back by a SceneTree timer that ignores the time scale, so it's
## restored even if this node is freed in the meantime.
func _hit_stop() -> void:
	Engine.time_scale = HIT_STOP_SCALE
	get_tree().create_timer(HIT_STOP_SECONDS, true, false, true).timeout.connect(Engine.set_time_scale.bind(1.0))


func _burst_shards() -> void:
	var shards := _particles(0.6, 26, false)
	shards.position = _to
	shards.one_shot = true
	shards.explosiveness = 0.95
	shards.spread = 180.0
	shards.gravity = Vector2(0.0, 420.0)
	shards.initial_velocity_min = 140.0
	shards.initial_velocity_max = 300.0
	shards.angle_min = 0.0
	shards.angle_max = 360.0
	shards.angular_velocity_min = -540.0
	shards.angular_velocity_max = 540.0
	shards.scale_amount_min = 2.0
	shards.scale_amount_max = 4.5
	shards.color_ramp = _ramp([Color(1, 1, 1), FROST, Color(RIM, 0.0)], [0.0, 0.5, 1.0])
	shards.emitting = true
	_free_later(shards, 0.8)


## The target's silhouette turns to void for `hold` seconds: a copy of
## its sprite, filled by void_silhouette.gdshader, faded in and out on
## top. Also used by Return to the Void (ReturnToVoidFX).
static func hollow_out(node: TextureRect, hold: float = HOLLOW_HOLD) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = SILHOUETTE_SHADER
	mat.set_shader_parameter("seed", randf() * 10.0)
	var hollow := TextureRect.new()
	hollow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hollow.material = mat
	hollow.texture = node.texture
	hollow.expand_mode = node.expand_mode
	hollow.stretch_mode = node.stretch_mode
	hollow.flip_h = node.flip_h
	hollow.flip_v = node.flip_v
	hollow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hollow.modulate.a = 0.0
	node.add_child(hollow)
	var t := hollow.create_tween()
	t.tween_property(hollow, "modulate:a", 1.0, 0.06)
	t.tween_interval(hold)
	t.tween_property(hollow, "modulate:a", 0.0, 0.3)
	t.tween_callback(hollow.queue_free)


## Thrown back, away from Nhal, then snapped back into place. Applied as
## a change on top of wherever the battle has the node, never as absolute
## positions - if the battle moves it meanwhile (a stage reset, its own
## move), restoring a position captured up front would drag its art back
## to the old spot (see RoarFX._shudder()).
func _knock_back(node: TextureRect) -> void:
	var away := signf(_to.x - _from.x)
	if away == 0.0:
		away = 1.0
	var applied := [0.0]
	var set_offset := func(offset: float) -> void:
		if is_instance_valid(node):
			node.position.x += offset - applied[0]
			applied[0] = offset
	var push: float = away * node.size.x * KNOCKBACK
	var t := node.create_tween()
	t.tween_method(set_offset, 0.0, push, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_method(set_offset, push, 0.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Its warmth pulled out of it: embers rising off it, cooling to pale
## blue and winking out.
func _drain_warmth(node: TextureRect) -> void:
	var embers := _particles(1.0, 26)
	embers.position = _to
	embers.one_shot = true
	embers.explosiveness = 0.35
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = node.size * Vector2(0.28, 0.3)
	embers.direction = Vector2(0.0, -1.0)
	embers.spread = 25.0
	embers.gravity = Vector2(0.0, -40.0)
	embers.initial_velocity_min = 30.0
	embers.initial_velocity_max = 70.0
	embers.scale_amount_min = 0.5
	embers.scale_amount_max = 1.1
	embers.color_ramp = _ramp([EMBER, Color(1.0, 0.8, 0.55), FROST, Color(RIM, 0.0)], [0.0, 0.25, 0.65, 1.0])
	embers.emitting = true
	_free_later(embers, 1.2)


# --- helpers --------------------------------------------------------

## A CPUParticles2D added next to this node (so it outlives it),
## additive - soft round dots unless `soft` is false (plain square
## chips, for the ice shards).
func _particles(lifetime: float, amount: int, soft: bool = true) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	if soft:
		p.texture = _dot()
	p.lifetime = lifetime
	p.amount = amount
	p.gravity = Vector2.ZERO
	p.material = _additive()
	get_parent().add_child.call_deferred(p)
	return p


func _free_later(node: Node, seconds: float) -> void:
	get_tree().create_timer(seconds).timeout.connect(node.queue_free)


static func _ramp(colors: Array, offsets: Array, fade_in: bool = false) -> Gradient:
	var g := Gradient.new()
	var cols := PackedColorArray(colors)
	var offs := PackedFloat32Array(offsets)
	if fade_in:
		cols.insert(0, Color(cols[0], 0.0))
		offs.insert(0, 0.0)
		offs[1] = 0.15
	g.offsets = offs
	g.colors = cols
	return g


## A small soft round dot (8 px), so particle scales are roughly their
## size in px / 8 * 2.
static func _dot() -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.7), Color(1, 1, 1, 0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 8
	t.height = 8
	return t


static func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m
