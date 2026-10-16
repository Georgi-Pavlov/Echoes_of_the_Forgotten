class_name ShacklesFX
extends Node2D

## Purely cosmetic: the Last Empress's Shackles - chains torn up out of the
## drowned floor and bound round the target for as long as its root lasts.
##
##   1. The floor splits at the target's feet: a ring of ghost-light runs
##      out across it, and silt is thrown up.
##   2. Four chains of heavy iron links burst up out of the ground, each
##      anchored to the floor by an eyebolt, and spiral up the target's body,
##      passing behind it and in front of it.
##   3. Where each one ends, a loop of the same chain is thrown round the
##      body and cinched tight with a flash of cold light, a padlock
##      clamping shut at its front.
##   4. The chains hold, straining a little, for as long as the root does -
##      then rust over, crumble and fade (release()).
##
## Two of these are made per target, sharing a seed so their geometry is
## identical: one drawn BEHIND the target's sprite (the far side of every
## coil and loop) and one in FRONT of it (the near side), which is what makes
## the chains really go round the target instead of lying over it. battle.gd
## keeps them in step with the root: ShacklesFX.set_on().

const GROW_TIME := 0.55
const SNAP_TIME := 0.16
const FADE_TIME := 0.55
const CHAIN_COUNT := 4
const LINK_SPACING := 13.0
const META := "shackles_fx"

const IRON_DARK := Color(0.04, 0.045, 0.06)
const IRON := Color(0.5, 0.52, 0.58)
const IRON_LIGHT := Color(0.85, 0.89, 0.95)
const RUST := Color(0.42, 0.22, 0.1)
const GHOST := Color(0.4, 0.95, 0.9)
const SILT := Color(0.18, 0.2, 0.2)

var _front := false
var _seed := 0
var _target: Control
var _center := Vector2.ZERO     # global: middle of the target's feet
var _radius := 40.0             # how far out the coils reach
var _height := 100.0            # how high the highest loop sits
var _chains: Array[Dictionary] = []
var _age := 0.0
var _snapped := false
var _release_t := -1.0
var _on_snap: Callable


## Binds `target` (a sprite) in chains, or lets it go. Only does anything
## when the state actually changes - the pair's presence on the target (its
## "shackles_fx" meta) is the "currently on" marker. `on_snap` fires the
## moment the loops cinch shut.
static func set_on(host: Node, target: Variant, active: bool, on_snap: Callable = Callable()) -> void:
	if host == null or not (target is Control) or not is_instance_valid(target):
		return
	var node: Control = target
	var existing: Array = node.get_meta(META, [])
	var alive := false
	for fx in existing:
		if is_instance_valid(fx) and fx._release_t < 0.0:
			alive = true
	if active == alive:
		return
	if not active:
		for fx in existing:
			if is_instance_valid(fx):
				fx._release()
		node.remove_meta(META)
		return

	var seed_value := randi()
	var pair: Array = []
	for front in [false, true]:
		var fx := ShacklesFX.new()
		fx._front = front
		fx._seed = seed_value
		fx._target = node
		fx._follow()
		if front:
			fx._on_snap = on_snap
		host.add_child(fx)
		fx.global_position = fx._center
		pair.append(fx)
	node.set_meta(META, pair)

	# The far side of the coils goes just under the target's sprite and the
	# near side just over it. Creeps live in a layer of their own, so for
	# them it's that whole layer that's straddled (the same for the hero and
	# the bear, which are direct children of the host).
	var anchor: Node = node
	while anchor != null and anchor.get_parent() != host:
		anchor = anchor.get_parent()
	if anchor != null:
		host.move_child(pair[0], anchor.get_index())
		host.move_child(pair[1], anchor.get_index() + 1)


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed
	# Four chains, each anchored at its own angle round the target and
	# winding up it a different way, ending at its own height.
	var heights := [0.28, 0.5, 0.72, 0.95]
	for i in CHAIN_COUNT:
		_chains.append({
			"phi0": TAU * (float(i) + rng.randf_range(-0.12, 0.12)) / CHAIN_COUNT,
			"dir": 1.0 if i % 2 == 0 else -1.0,
			"turns": rng.randf_range(0.5, 0.8),
			"top": float(heights[i]),
			"delay": rng.randf_range(0.0, 0.16),
			"wobble": rng.randf() * TAU,
		})
	if _front:
		_burst()


## The floor splitting: silt thrown up round the target's feet.
func _burst() -> void:
	for pass_i in 2:
		var p := CPUParticles2D.new()
		p.one_shot = true
		p.explosiveness = 0.9
		p.amount = 18 if pass_i == 0 else 10
		p.lifetime = 0.55 if pass_i == 0 else 0.9
		p.spread = 75.0
		p.direction = Vector2(0.0, -1.0)
		p.gravity = Vector2(0.0, 360.0) if pass_i == 0 else Vector2(0.0, -26.0)
		p.initial_velocity_min = 50.0 if pass_i == 0 else 14.0
		p.initial_velocity_max = 160.0 if pass_i == 0 else 60.0
		p.scale_amount_min = 1.6
		p.scale_amount_max = 3.4
		p.color = SILT if pass_i == 0 else Color(GHOST, 0.5)
		if pass_i == 1:
			var mat := CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			p.material = mat
		add_child(p)
		p.position = Vector2.ZERO
		p.emitting = true
		p.finished.connect(p.queue_free)


## The manacles' closing: a spray of cold sparks off the cinched loops.
func _snap_flash() -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 24
	p.lifetime = 0.5
	p.spread = 180.0
	p.gravity = Vector2(0.0, 120.0)
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 130.0
	p.scale_amount_min = 1.4
	p.scale_amount_max = 2.8
	p.color = GHOST
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	p.material = mat
	add_child(p)
	p.position = Vector2(0.0, -_height * 0.5)
	p.emitting = true
	p.finished.connect(p.queue_free)


## Lets go: the chains rust, crumble and fade, then this frees itself.
func _release() -> void:
	if _release_t < 0.0:
		_release_t = 0.0


## Re-reads where the target stands - it can lunge, or be shoved, while
## shackled, and the chains go with it.
func _follow() -> void:
	if not is_instance_valid(_target):
		return
	_center = _target.global_position + Vector2(_target.size.x * 0.5, _target.size.y * 0.93)
	_radius = clampf(_target.size.x * 0.34, 30.0, 70.0)
	_height = clampf(_target.size.y * 0.78, 60.0, 190.0)


func _process(delta: float) -> void:
	_age += delta
	if _release_t < 0.0 and not is_instance_valid(_target):
		# Its target is gone (killed, or the stage changed) - nothing to
		# hold on to.
		_release_t = 0.0
	if _release_t >= 0.0:
		_release_t += delta
		if _release_t >= FADE_TIME:
			queue_free()
			return
	_follow()
	global_position = _center
	if not _snapped and _age >= GROW_TIME:
		_snapped = true
		if _on_snap.is_valid():
			_on_snap.call()
		if _front:
			_snap_flash()
	queue_redraw()


# --- geometry -------------------------------------------------------

## How much of the chain has burst out of the ground (0..1).
func _grow_of(chain: Dictionary) -> float:
	var g := clampf((_age - float(chain["delay"])) / (GROW_TIME - 0.16), 0.0, 1.0)
	return 1.0 - pow(1.0 - g, 2.6)


## 0..1 as the whole thing crumbles away at the end.
func _fade() -> float:
	if _release_t < 0.0:
		return 0.0
	return clampf(_release_t / FADE_TIME, 0.0, 1.0)


## 0..1: how far the loops have been cinched round the body.
func _cinch() -> float:
	var t := clampf((_age - GROW_TIME) / SNAP_TIME, 0.0, 1.0)
	return 1.0 - pow(1.0 - t, 2.0)


## A point on a chain at `u` (0 = anchored in the floor .. 1 = where its
## loop meets it), local to `_center`. z > 0 is the near side of the coil,
## < 0 the far side.
func _point(chain: Dictionary, u: float) -> Vector3:
	var top: float = chain["top"]
	var phi: float = float(chain["phi0"]) + float(chain["dir"]) * float(chain["turns"]) * u * TAU
	# Springs out from further away and tightens onto the body as it rises.
	var out := _radius * lerpf(1.35, 1.0, smoothstep(0.0, 0.5, u))
	var strain := sin(_age * 1.7 + float(chain["wobble"]) + u * 3.0) * 1.1 * (1.0 - u * 0.6)
	var x := cos(phi) * out + strain
	var y := -_height * top * u + sin(phi) * out * 0.2
	# The chain arcs up off the floor rather than running along it.
	y -= sin(minf(u * 3.0, PI)) * 6.0 * (1.0 - u)
	return Vector3(x, y, sin(phi))


## A point on the loop of chain thrown round the body at `chain`'s height,
## at angle `a` round it (z > 0 is the near side). It starts wide and cinches
## in to the body.
func _loop_point(chain: Dictionary, a: float) -> Vector3:
	var y := -_height * float(chain["top"])
	var rx := _radius * lerpf(1.45, 1.0, _cinch()) * (1.0 + 0.012 * sin(_age * 1.6 + float(chain["wobble"])))
	return Vector3(cos(a) * rx, y + sin(a) * rx * 0.2, sin(a))


# --- drawing --------------------------------------------------------

func _draw() -> void:
	var fade := _fade()
	var alpha := 1.0 - fade * fade
	_draw_floor_ring(alpha)
	for chain in _chains:
		_draw_chain(chain, alpha, fade)


## The ghost-light ring running out across the floor where it split -
## drawn once, by the far-side node (so it sits under the target), and
## settling to a faint glow while the chains hold.
func _draw_floor_ring(alpha: float) -> void:
	if _front:
		return
	var f := clampf(_age / 0.35, 0.0, 1.0)
	var r := _radius * (0.6 + 1.1 * (1.0 - pow(1.0 - f, 2.0)))
	var settle := 0.18 + 0.1 * sin(_age * 2.0)
	var a := lerpf(0.7, settle, f) * alpha
	var ring := PackedVector2Array()
	for i in 33:
		var ang := TAU * i / 32.0
		ring.append(Vector2(cos(ang) * r, sin(ang) * r * 0.2))
	draw_polyline(ring, Color(GHOST, a), 2.0, true)
	draw_polyline(ring, Color(GHOST, a * 0.3), 6.0, true)


func _draw_chain(chain: Dictionary, alpha: float, fade: float) -> void:
	var grow := _grow_of(chain)
	if grow <= 0.0:
		return
	var steps := 60
	var path: Array[Vector3] = []
	for k in steps + 1:
		path.append(_point(chain, float(k) / steps * grow))
	_draw_links(path, 0, alpha, fade, float(chain["wobble"]))
	# Where it's anchored: an eyebolt sunk into the floor.
	_draw_eyebolt(path[0], alpha, fade)

	# The loop thrown round the body at its end, cinching tight.
	if _age >= GROW_TIME:
		var loop: Array[Vector3] = []
		var loops := 48
		# Starts from where the coil meets it, so it reads as the same chain.
		var join := _point(chain, 1.0)
		var start_angle := atan2(join.z, join.x / maxf(_radius, 0.001))
		for k in loops + 1:
			loop.append(_loop_point(chain, start_angle + TAU * float(k) / loops))
		_draw_links(loop, 7, alpha * clampf(_cinch() * 1.6, 0.0, 1.0), fade, float(chain["wobble"]) + 2.0)
		_draw_padlock(chain, alpha, fade)


## Places chain links evenly along `path` (points relative to `_center`, z =
## depth) and draws the ones belonging to this node's side. Alternate links
## lie flat (a thick oval ring, seen through) and edge-on (a short fat bar),
## so the chain reads as interlocked. Far-side links are darker.
func _draw_links(path: Array[Vector3], first_index: int, alpha: float, fade: float, wobble: float) -> void:
	var link_index := first_index
	var carried := 0.0
	for k in range(1, path.size()):
		var a: Vector3 = path[k - 1]
		var b: Vector3 = path[k]
		var seg := Vector2(b.x - a.x, b.y - a.y)
		var seg_len := seg.length()
		if seg_len <= 0.0001:
			continue
		var near := (a.z + b.z) * 0.5 >= 0.0
		carried += seg_len
		while carried >= LINK_SPACING:
			carried -= LINK_SPACING
			link_index += 1
			if near == _front:
				var at := Vector2(a.x, a.y).lerp(Vector2(b.x, b.y), clampf(1.0 - carried / seg_len, 0.0, 1.0))
				_draw_link(at, seg.angle(), link_index, near, alpha, fade, wobble)


func _draw_link(at: Vector2, angle: float, index: int, near: bool, alpha: float, fade: float, wobble: float) -> void:
	var flat := index % 2 == 0
	var dim := 1.0 if near else 0.55
	var rust := clampf(fade * 1.2, 0.0, 1.0)
	var body := IRON.lerp(RUST, rust * 0.8 + 0.14 * absf(sin(wobble + float(index)))) * dim
	var edge := IRON_DARK * dim
	body.a = 1.0
	edge.a = 1.0
	var dir := Vector2.from_angle(angle)
	var side := dir.orthogonal()
	if flat:
		# A thick oval ring - the hole shows what's behind.
		var half_len := 9.0
		var half_wid := 5.4
		var pts := PackedVector2Array()
		for i in 17:
			var t := TAU * i / 16.0
			pts.append(at + dir * cos(t) * half_len + side * sin(t) * half_wid)
		draw_polyline(pts, Color(edge, alpha), 5.6, true)
		draw_polyline(pts, Color(body, alpha), 3.4, true)
		if near:
			var gleam := PackedVector2Array()
			for i in 6:
				var t := PI * (1.05 + 0.5 * float(i) / 5.0)
				gleam.append(at + dir * cos(t) * (half_len - 0.5) + side * sin(t) * (half_wid - 0.5))
			draw_polyline(gleam, Color(IRON_LIGHT, 0.75 * alpha), 1.2, true)
	else:
		# Edge-on: a short, fat bar capping the ends of its neighbours.
		var half_len := 6.6
		draw_line(at - dir * half_len, at + dir * half_len, Color(edge, alpha), 7.0, true)
		draw_line(at - dir * half_len, at + dir * half_len, Color(body, alpha), 4.6, true)
		if near:
			draw_line(at - dir * (half_len - 1.5) - side * 1.2, at + dir * (half_len - 2.5) - side * 1.2, Color(IRON_LIGHT, 0.7 * alpha), 1.3, true)
	if near:
		draw_circle(at, 7.0, Color(GHOST, 0.1 * alpha))


## The eyebolt a chain is anchored by: a plate set into the floor and a ring
## through it, which the first link passes through.
func _draw_eyebolt(p: Vector3, alpha: float, fade: float) -> void:
	if (p.z >= 0.0) != _front:
		return
	var rust := clampf(fade * 1.2, 0.0, 1.0)
	var body := IRON.lerp(RUST, rust * 0.8)
	var at := Vector2(p.x, p.y)
	draw_circle(at + Vector2(0.0, 2.0), 7.0, Color(0.02, 0.03, 0.04, 0.55 * alpha))
	draw_arc(at, 6.0, PI, TAU, 14, Color(IRON_DARK, alpha), 5.0, true)
	draw_arc(at, 6.0, PI, TAU, 14, Color(body, alpha), 3.0, true)


## The padlock clamped on the front of each loop: a small iron body with a
## shackle arching over it and a keyhole, appearing as the loop cinches.
func _draw_padlock(chain: Dictionary, alpha: float, fade: float) -> void:
	if not _front or _cinch() < 0.7:
		return
	var rust := clampf(fade * 1.2, 0.0, 1.0)
	var body := IRON.lerp(RUST, rust * 0.8)
	var at := Vector2(0.0, -_height * float(chain["top"]) + _radius * 0.2)
	var w := 7.5
	var h := 6.5
	# The shackle arching over the body, then the body itself.
	draw_arc(at + Vector2(0.0, -h * 0.4), w * 0.6, PI, TAU, 12, Color(IRON_DARK, alpha), 4.6, true)
	draw_arc(at + Vector2(0.0, -h * 0.4), w * 0.6, PI, TAU, 12, Color(IRON_LIGHT * 0.8, alpha), 2.6, true)
	var box := Rect2(at - Vector2(w, h * 0.4), Vector2(w * 2.0, h * 1.6))
	draw_rect(box.grow(1.5), Color(IRON_DARK, alpha))
	draw_rect(box, Color(body, alpha))
	draw_line(box.position + Vector2(1.5, 1.5), box.position + Vector2(box.size.x - 1.5, 1.5), Color(IRON_LIGHT, 0.7 * alpha), 1.2, true)
	draw_circle(at + Vector2(0.0, h * 0.3), 1.7, Color(IRON_DARK, alpha))
	draw_line(at + Vector2(0.0, h * 0.3), at + Vector2(0.0, h * 0.9), Color(IRON_DARK, alpha), 1.6, true)
	# The flash as it clamps shut.
	if _age < GROW_TIME + SNAP_TIME + 0.25:
		var f := clampf((_age - GROW_TIME) / (SNAP_TIME + 0.25), 0.0, 1.0)
		draw_circle(at, 6.0 + 16.0 * f, Color(GHOST, 0.35 * (1.0 - f) * alpha))
