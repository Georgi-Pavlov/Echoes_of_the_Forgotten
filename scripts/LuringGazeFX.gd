class_name LuringGazeFX
extends Node2D

## Purely cosmetic: the Last Empress's ultimate, Luring Gaze.
##
## The cast (cast()):
##   1. Her eyes ignite with a cold pale glow, and a violet-black vignette
##      closes in on the arena's edges, drawing every eye to her.
##   2. The glamour: her whole sprite goes pearly and luminous for a beat -
##      the beautiful face she shows her victims - then snaps back to her
##      monstrous self with a flash.
##   3. The gaze lands: thin threads of pale light curve from her eyes to
##      every enemy in range, and each one locks rigid as its thread
##      connects, a ripple of light spreading from where it met them.
##
## While they're held (set_trance(), kept in step with the stun):
##   4. A slowly turning spiral hangs over each victim, like an iris.
##   5. Pearl-white motes stream off them toward the Empress.
##   A faint pearly sheen breathes over the sprite. When the stun ends the
##   spiral shatters into glass-like shards and the glow fades.
##
## battle.gd calls cast() once per cast, and keeps set_trance() on whoever
## is held (it follows the stun, like Shackles' chains follow the root).

const EYE_FRAC := Vector2(0.915, 0.33)       # her eyes, on her sprite (facing right)
const TARGET_EYE_FRAC := Vector2(0.5, 0.3)
const TRANCE_NAME := "LuringGazeTrance"

const PALE := Color(1.0, 0.95, 0.78)
const GOLD := Color(1.0, 0.82, 0.45)
const TEAL := Color(0.45, 1.0, 0.92)
const VIOLET := Color(0.38, 0.22, 0.62)
const PEARL := Color(0.92, 0.9, 1.0)

const EYE_TIME := 0.55
const GLAMOUR_TIME := 0.55
const THREAD_START := 0.3
const THREAD_TIME := 0.38
const THREAD_HOLD := 0.7
const VIGNETTE_TIME := 1.7
const TOTAL_TIME := 2.2

var _caster: Control
var _targets: Array[Dictionary] = []
var _age := 0.0
var _on_connect: Callable


## Plays the cast: from `caster`'s eyes to each of `targets` (sprites).
## `vignette_under` is the node the arena-darkening vignette is placed just
## below (so the fighters stay bright against it); `heavy` makes the
## vignette stronger - for when it's the player being gazed at. `on_connect`
## is called with each target the moment its thread reaches it.
static func cast(host: Node, caster: Variant, targets: Array, vignette_under: Node, heavy: bool = false, on_connect: Callable = Callable()) -> void:
	if host == null or not (caster is Control) or not is_instance_valid(caster):
		return
	var fx := LuringGazeFX.new()
	fx._caster = caster
	fx._on_connect = on_connect
	var i := 0
	for t in targets:
		if t is Control and is_instance_valid(t):
			fx._targets.append({"node": t, "delay": 0.07 * i, "connected": false, "ripple": -1.0})
			i += 1
	host.add_child(fx)
	fx.global_position = Vector2.ZERO

	_add_vignette(host, vignette_under, heavy)
	_add_glamour(caster)


static func _add_vignette(host: Node, under: Node, heavy: bool) -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([Color(VIOLET.r * 0.3, 0.0, VIOLET.b * 0.4, 0.0), Color(0.05, 0.0, 0.12, 0.18), Color(0.04, 0.0, 0.1, 0.62)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256
	var vignette := TextureRect.new()
	vignette.texture = texture
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.size = host.get_viewport().get_visible_rect().size
	vignette.modulate.a = 0.0
	host.add_child(vignette)
	if under != null and under.get_parent() == host:
		host.move_child(vignette, under.get_index())
	var peak := 1.0 if heavy else 0.65
	var tween := vignette.create_tween()
	tween.tween_property(vignette, "modulate:a", peak, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(VIGNETTE_TIME - 0.3 - 0.5)
	tween.tween_property(vignette, "modulate:a", 0.0, 0.5)
	tween.tween_callback(vignette.queue_free)


## The glamour: a pearly copy of her sprite laid over it, rising and falling
## in a beat, and ending in a quick flash. It's an overlay (never her own
## modulate), so it can't fight the animator or a hit flash.
static func _add_glamour(caster: Control) -> void:
	if not (caster is TextureRect):
		return
	var glam := TextureRect.new()
	glam.texture = caster.texture
	glam.expand_mode = caster.expand_mode
	glam.stretch_mode = caster.stretch_mode
	glam.flip_h = caster.flip_h
	glam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glam.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glam.material = mat
	glam.self_modulate = Color(PALE, 0.0)
	caster.add_child(glam)
	var tween := glam.create_tween()
	tween.tween_property(glam, "self_modulate:a", 0.72, 0.28).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.1)
	# The mask slips: a flash as the monster shows through.
	tween.tween_property(glam, "self_modulate", Color(1.0, 1.0, 1.0, 0.95), 0.05)
	tween.tween_property(glam, "self_modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(glam.queue_free)


func _process(delta: float) -> void:
	_age += delta
	if _age >= TOTAL_TIME:
		queue_free()
		return
	for t in _targets:
		var node = t["node"]
		if not is_instance_valid(node):
			continue
		if not t["connected"] and _progress(t) >= 1.0:
			t["connected"] = true
			t["ripple"] = 0.0
			if _on_connect.is_valid():
				_on_connect.call(node)
		if t["ripple"] >= 0.0:
			t["ripple"] += delta
	queue_redraw()


# --- geometry -------------------------------------------------------

func _caster_eye() -> Vector2:
	if not is_instance_valid(_caster):
		return Vector2.ZERO
	var frac := EYE_FRAC
	if _caster is TextureRect and (_caster as TextureRect).flip_h:
		frac.x = 1.0 - frac.x
	return _caster.global_position + _caster.size * frac


func _target_eye(node: Control) -> Vector2:
	return node.global_position + node.size * TARGET_EYE_FRAC


## 0..1: how far this target's thread has travelled.
func _progress(t: Dictionary) -> float:
	var p := clampf((_age - THREAD_START - float(t["delay"])) / THREAD_TIME, 0.0, 1.0)
	return 1.0 - pow(1.0 - p, 2.2)


## A point on the thread from `a` to `b` at `u`, bowed upward and graceful.
func _curve(a: Vector2, b: Vector2, u: float) -> Vector2:
	var mid := (a + b) * 0.5 + Vector2(0.0, -minf(70.0, a.distance_to(b) * 0.22))
	var p1 := a.lerp(mid, u)
	var p2 := mid.lerp(b, u)
	return p1.lerp(p2, u)


# --- drawing --------------------------------------------------------

func _draw() -> void:
	_draw_eyes()
	var fade := 1.0 - smoothstep(THREAD_START + THREAD_TIME + THREAD_HOLD, TOTAL_TIME - 0.1, _age)
	for t in _targets:
		var node = t["node"]
		if not is_instance_valid(node):
			continue
		_draw_thread(t, node, fade)
		_draw_ripple(t, node)


## Her eyes igniting: a glow that swells, flares, and settles down.
func _draw_eyes() -> void:
	var f := clampf(_age / EYE_TIME, 0.0, 1.0)
	var swell := sin(f * PI)
	var hold := 1.0 - smoothstep(THREAD_START + THREAD_TIME, TOTAL_TIME - 0.4, _age)
	var strength := maxf(swell, 0.45 * hold) * (0.5 + 0.5 * f)
	if strength <= 0.01:
		return
	var eye := _caster_eye()
	draw_circle(eye, 26.0 * strength + 6.0, Color(GOLD, 0.16 * strength))
	draw_circle(eye, 14.0 * strength + 4.0, Color(PALE, 0.4 * strength))
	draw_circle(eye, 5.0 + 3.0 * strength, Color(1.0, 1.0, 1.0, 0.9 * strength))
	# A cold cross-flare through the pupil.
	var arm := 30.0 * strength
	draw_line(eye - Vector2(arm, 0.0), eye + Vector2(arm, 0.0), Color(PALE, 0.55 * strength), 1.5, true)
	draw_line(eye - Vector2(0.0, arm * 0.6), eye + Vector2(0.0, arm * 0.6), Color(PALE, 0.4 * strength), 1.2, true)


## One thread of light: three strands braiding along a curve from her eye to
## the target's, brightest at the head, with a bead of light running down.
func _draw_thread(t: Dictionary, node: Control, fade: float) -> void:
	var p := _progress(t)
	if p <= 0.0 or fade <= 0.0:
		return
	var a := _caster_eye()
	var b := _target_eye(node)
	var segs := 36
	for strand in 3:
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for k in range(segs + 1):
			var u := float(k) / segs * p
			var base := _curve(a, b, u)
			var tangent := (_curve(a, b, minf(u + 0.01, 1.0)) - base).normalized()
			var wiggle := sin(_age * 7.0 + u * 11.0 + float(strand) * 2.1) * 5.0 * sin(u * PI) * (float(strand) - 1.0)
			pts.append(base + tangent.orthogonal() * wiggle)
			var head := smoothstep(0.0, 1.0, float(k) / segs)
			cols.append(Color(GOLD.lerp(TEAL, 0.5 * float(strand) / 2.0 + 0.25 * head), (0.25 + 0.55 * head) * fade))
		if pts.size() > 1:
			draw_polyline_colors(pts, cols, 2.2 if strand == 1 else 1.3, true)
	# The head of the thread, and a bead of light running down it.
	var head_pos := _curve(a, b, p)
	draw_circle(head_pos, 7.0, Color(PALE, 0.22 * fade))
	draw_circle(head_pos, 3.0, Color(1.0, 1.0, 1.0, 0.9 * fade))
	var bead := fposmod(_age * 1.6 + float(t["delay"]) * 4.0, 1.0) * p
	draw_circle(_curve(a, b, bead), 2.6, Color(PALE, 0.8 * fade))


## The ripple spreading from where a thread met its target, as it locks.
func _draw_ripple(t: Dictionary, node: Control) -> void:
	var r: float = t["ripple"]
	if r < 0.0 or r > 0.6:
		return
	var f := r / 0.6
	var center := _target_eye(node)
	var radius := 10.0 + 46.0 * (1.0 - pow(1.0 - f, 2.0))
	var ring := PackedVector2Array()
	for i in 33:
		var ang := TAU * i / 32.0
		ring.append(center + Vector2(cos(ang), sin(ang)) * radius)
	draw_polyline(ring, Color(PALE, 0.8 * (1.0 - f)), 2.5 * (1.0 - f) + 0.8, true)
	draw_polyline(ring, Color(TEAL, 0.3 * (1.0 - f)), 6.0 * (1.0 - f) + 1.0, true)


# --- the trance -----------------------------------------------------

## Holds `node` (a sprite) in the gaze, or lets it go. `caster` is the node
## the motes stream toward (the Empress). Only does anything when the state
## actually changes - the trance's presence on the node is the marker.
static func set_trance(node: Variant, active: bool, caster: Variant) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	var existing := node.get_node_or_null(TRANCE_NAME) as Trance
	if active == (existing != null):
		return
	if not active:
		# Renamed right away so a quick re-trance during the fade creates a
		# fresh one instead of finding this dying one.
		existing.name = TRANCE_NAME + "Fading"
		existing.release()
		return
	var trance := Trance.new()
	trance.name = TRANCE_NAME
	trance.setup(node, caster)
	node.add_child(trance)


## The held state on one sprite: the sigil, the streaming motes and the
## faint sheen. A child Control of the sprite, so it follows it for free.
class Trance extends Control:
	const DELAY := 0.7            # waits for the gaze to land
	const SIGIL_FRAC := Vector2(0.5, 0.3)

	var _node: TextureRect
	var _caster: Variant
	var _age := 0.0
	var _release_t := -1.0
	var _motes: Array[Dictionary] = []
	var _spawn_accum := 0.0
	var _sheen: TextureRect


	func setup(node: TextureRect, caster: Variant) -> void:
		_node = node
		_caster = caster
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		# The sigil and the motes are pure light: drawn additively.
		var glow := CanvasItemMaterial.new()
		glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = glow
		# A pearly sheen over the sprite's own silhouette (a tinted copy of
		# its texture - it never touches the sprite's own modulate).
		_sheen = TextureRect.new()
		_sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_sheen.texture = node.texture
		_sheen.expand_mode = node.expand_mode
		_sheen.stretch_mode = node.stretch_mode
		_sheen.flip_h = node.flip_h
		_sheen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_sheen.self_modulate = Color(PEARL, 0.0)
		add_child(_sheen)


	func release() -> void:
		if _release_t >= 0.0:
			return
		_release_t = 0.0
		# The spiral shatters into glass-like shards.
		if _age > DELAY and is_instance_valid(_node):
			var shards := CPUParticles2D.new()
			shards.one_shot = true
			shards.explosiveness = 0.95
			shards.amount = 14
			shards.lifetime = 0.7
			shards.spread = 180.0
			shards.direction = Vector2(0.0, -1.0)
			shards.gravity = Vector2(0.0, 260.0)
			shards.initial_velocity_min = 50.0
			shards.initial_velocity_max = 140.0
			shards.angular_velocity_min = -360.0
			shards.angular_velocity_max = 360.0
			shards.scale_amount_min = 2.2
			shards.scale_amount_max = 4.4
			shards.color = GOLD.lerp(PALE, 0.5)
			var mat := CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			shards.material = mat
			add_child(shards)
			shards.position = _sigil_center()
			shards.emitting = true


	func _sigil_center() -> Vector2:
		return Vector2(_node.size.x * SIGIL_FRAC.x, _node.size.y * SIGIL_FRAC.y)


	func _shown() -> float:
		var s := smoothstep(DELAY, DELAY + 0.4, _age)
		if _release_t >= 0.0:
			s *= 1.0 - clampf(_release_t / 0.4, 0.0, 1.0)
		return s


	func _process(delta: float) -> void:
		if not is_instance_valid(_node):
			queue_free()
			return
		_age += delta
		if _release_t >= 0.0:
			_release_t += delta
			if _release_t >= 0.5:
				queue_free()
				return
		var shown := _shown()
		# The sheen follows the sprite turning around, and breathes.
		_sheen.flip_h = _node.flip_h
		_sheen.texture = _node.texture
		_sheen.self_modulate = Color(PEARL, shown * (0.12 + 0.1 * (0.5 - 0.5 * cos(_age * 2.4))))
		_update_motes(delta, shown)
		queue_redraw()


	## Motes lift off the victim's body and stream toward the Empress,
	## quickening as they go.
	func _update_motes(delta: float, shown: float) -> void:
		var dest := Vector2(0.0, -1.0) * 100.0
		if is_instance_valid(_caster) and _caster is Control:
			var caster_center: Vector2 = (_caster as Control).global_position + (_caster as Control).size * 0.5
			dest = get_global_transform().affine_inverse() * caster_center
		var dir := (dest - size * 0.5).normalized()
		_spawn_accum += delta * 13.0 * shown
		while _spawn_accum >= 1.0:
			_spawn_accum -= 1.0
			_motes.append({
				"pos": Vector2(randf_range(0.15, 0.85) * size.x, randf_range(0.2, 0.95) * size.y),
				"age": 0.0, "life": randf_range(1.1, 1.7),
				"wobble": randf() * TAU, "size": randf_range(1.6, 3.2),
			})
		for i in range(_motes.size() - 1, -1, -1):
			var m: Dictionary = _motes[i]
			m["age"] += delta
			if m["age"] >= m["life"]:
				_motes.remove_at(i)
				continue
			var speed := lerpf(26.0, 150.0, pow(float(m["age"]) / float(m["life"]), 1.5))
			var sway := dir.orthogonal() * sin(float(m["age"]) * 4.0 + float(m["wobble"])) * 14.0
			m["pos"] += (dir * speed + sway) * delta


	func _draw() -> void:
		var shown := _shown()
		if shown <= 0.01 or not is_instance_valid(_node):
			return
		_draw_motes(shown)
		_draw_sigil(shown)


	func _draw_motes(shown: float) -> void:
		for m in _motes:
			var t: float = float(m["age"]) / float(m["life"])
			var a := smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(0.6, 1.0, t))
			var pos: Vector2 = m["pos"]
			var s: float = m["size"]
			draw_circle(pos, s * 2.6, Color(PEARL, 0.12 * a * shown))
			draw_circle(pos, s, Color(PALE, 0.8 * a * shown))


	## The hypnotic iris: a ring with tick marks and two spiral arms turning
	## slowly the other way, a small bright core, pulsing gently.
	func _draw_sigil(shown: float) -> void:
		var c := _sigil_center()
		var r := clampf(minf(_node.size.x, _node.size.y) * 0.26, 18.0, 42.0)
		var pulse := 0.85 + 0.15 * sin(_age * 3.0)
		var a := shown * pulse
		# Outer ring with tick marks, turning slowly.
		var ring := PackedVector2Array()
		for i in 41:
			var ang := TAU * i / 40.0
			ring.append(c + Vector2(cos(ang), sin(ang)) * r)
		draw_polyline(ring, Color(GOLD, 0.95 * a), 2.4, true)
		draw_polyline(ring, Color(GOLD, 0.3 * a), 6.0, true)
		draw_circle(c, r * 1.05, Color(VIOLET, 0.35 * a))
		for i in 12:
			var ang := TAU * i / 12.0 + _age * 0.5
			var d := Vector2(cos(ang), sin(ang))
			draw_line(c + d * r * 0.88, c + d * r * 1.12, Color(PALE, 0.7 * a), 1.4, true)
		# Two spiral arms, turning the other way.
		for arm in 2:
			var pts := PackedVector2Array()
			var cols := PackedColorArray()
			for k in 30:
				var u := float(k) / 29.0
				var ang := -_age * 1.4 + float(arm) * PI + u * TAU * 1.5
				pts.append(c + Vector2(cos(ang), sin(ang)) * r * 0.85 * u)
				cols.append(Color(TEAL.lerp(PALE, u), (0.35 + 0.65 * u) * a))
			draw_polyline_colors(pts, cols, 2.6, true)
		draw_circle(c, 3.2, Color(1.0, 1.0, 1.0, 0.9 * a))
		draw_circle(c, 9.0, Color(PALE, 0.22 * a))
