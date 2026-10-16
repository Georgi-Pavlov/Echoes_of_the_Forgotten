class_name DreadlureFX
extends RefCounted

## Purely cosmetic: the effects of Dreadlure's four skills - the deep-sea
## ambusher's cold blue light, murky water and pale venom.
##
##   Hunting Instinct - surge(): a dark streak and afterimages along the path,
##                      bubbles in its wake, and claw slashes where it lands.
##   Paralytic Venom  - venom_cloud(): a ring of toxic cloud rolling out from
##                      the caster. set_paralysis(): the held state on every
##                      unit it stunned, for as long as the stun lasts.
##   Might of the Deep - set_might_charge(): dark bubbles gathering at the
##                      claws as the strikes build up, the claws glowing once
##                      the next one is ready. might_strike(): the shockwave
##                      and silt of the hit that lands.
##   Deathlight Lure  - lure_flash(): the lure flares blue and a thread of
##                      light runs to the target. set_mark(): the lure hung
##                      over a marked unit, with a cold outline.
##
## State-driven where a state lasts (the held state, the charge, the mark):
## the battle calls the set_*() functions constantly from its refresh pass,
## and they only act on a change - same approach as LuringGazeFX.

const BLUE := Color(0.35, 0.82, 1.0)
const BLUE_PALE := Color(0.75, 0.95, 1.0)
const VENOM := Color(0.5, 0.9, 0.4)
const VENOM_DEEP := Color(0.12, 0.3, 0.14)
const DEEP := Color(0.03, 0.08, 0.14)
const SILT := Color(0.45, 0.42, 0.36)
const BLOOD := Color(0.62, 0.1, 0.16)

## Where things sit on Dreadlure's art (fractions of the sprite, art facing
## right - mirrored when the sprite is flipped).
const LURE_FRAC := Vector2(0.95, 0.175)
const CLAW_FRACS := [Vector2(0.52, 0.62), Vector2(0.9, 0.72)]

const PARALYSIS_NAME := "DreadlureParalysis"
const MIGHT_NAME := "DreadlureMight"
const MARK_NAME := "DreadlureMark"

static var _glow: Texture2D


# --- helpers --------------------------------------------------------

static func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


static func _glow_tex() -> Texture2D:
	if _glow == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.2, 0.55, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.14), Color(1, 1, 1, 0.0)])
		var t := GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		t.width = 128
		t.height = 128
		_glow = t
	return _glow


## A point on `node`'s art, in global coordinates, mirrored if it's flipped.
static func _point(node: Control, frac: Vector2) -> Vector2:
	var f := frac
	if node is TextureRect and node.flip_h:
		f.x = 1.0 - f.x
	return node.global_position + node.size * f


static func _center(node: Control) -> Vector2:
	return node.global_position + node.size * 0.5


static func _feet(node: Control) -> Vector2:
	return node.global_position + Vector2(node.size.x * 0.5, node.size.y * 0.92)


## A one-shot drawing node: `draw_fn.call(runner, age)` every frame until
## `life` runs out. Added to `host` at the origin, so it draws in global
## coordinates.
class Runner extends Node2D:
	var life := 1.0
	var age := 0.0
	var draw_fn := Callable()

	func _process(delta: float) -> void:
		age += delta
		if age >= life:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		if draw_fn.is_valid():
			draw_fn.call(self, age)


static func _runner(host: Node, life: float, draw_fn: Callable, additive: bool = true) -> Runner:
	var r := Runner.new()
	r.life = life
	r.draw_fn = draw_fn
	if additive:
		r.material = _additive()
	host.add_child(r)
	r.global_position = Vector2.ZERO
	return r


static func _burst(host: Node, at: Vector2, amount: int, color: Color, speed: Vector2, life: float, size: Vector2, gravity: Vector2 = Vector2.ZERO, direction: Vector2 = Vector2(0, -1), spread: float = 180.0, add: bool = true) -> void:
	var p := CPUParticles2D.new()
	p.position = at
	p.one_shot = true
	p.amount = amount
	p.lifetime = life
	p.explosiveness = 0.95
	p.texture = VoidReachFX._dot()
	p.direction = direction
	p.spread = spread
	p.gravity = gravity
	p.initial_velocity_min = speed.x
	p.initial_velocity_max = speed.y
	p.damping_min = 30.0
	p.damping_max = 90.0
	p.scale_amount_min = size.x
	p.scale_amount_max = size.y
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	ramp.colors = PackedColorArray([Color(color, 0.9), Color(color, 0.5), Color(color, 0.0)])
	p.color_ramp = ramp
	if add:
		p.material = _additive()
	host.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


# --- Hunting Instinct -----------------------------------------------

## Dreadlure surges from `from_global` to `to_global` (the sprite's global
## top-left before and after the move). `hit_node` is whatever it struck, or
## null if it ran clean.
static func surge(host: Node, node: TextureRect, from_global: Vector2, to_global: Vector2, hit_node: Variant = null) -> void:
	if not is_instance_valid(host) or not is_instance_valid(node):
		return
	var shift := to_global - from_global
	if shift.length() < 4.0:
		return
	var tex := node.texture
	var size := node.size
	var flip := node.flip_h

	# Afterimages: dark blue ghosts left along the path, each fading out.
	var ghosts := 5
	for i in ghosts:
		var f := float(i) / float(ghosts)
		var ghost := TextureRect.new()
		ghost.texture = tex
		ghost.flip_h = flip
		ghost.expand_mode = node.expand_mode
		ghost.stretch_mode = node.stretch_mode
		ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ghost.size = size
		ghost.global_position = from_global.lerp(to_global, f)
		ghost.modulate = Color(0.35, 0.65, 0.95, 0.0)
		host.add_child(ghost)
		var tw := ghost.create_tween()
		tw.tween_interval(0.03 * i)
		tw.tween_property(ghost, "modulate:a", 0.6 * (0.4 + 0.6 * f), 0.05)
		tw.tween_property(ghost, "modulate:a", 0.0, 0.32)
		tw.tween_callback(ghost.queue_free)

	# The streak and floor ripples.
	var a := from_global + size * Vector2(0.5, 0.55)
	var b := to_global + size * Vector2(0.5, 0.55)
	var feet_a := from_global + Vector2(size.x * 0.5, size.y * 0.92)
	var feet_b := to_global + Vector2(size.x * 0.5, size.y * 0.92)
	_runner(host, 0.45, func(r: Runner, age: float) -> void:
		var k := 1.0 - age / 0.45
		var dir := (b - a).normalized()
		var side := dir.orthogonal()
		var half := size.y * 0.16 * k
		r.draw_colored_polygon(PackedVector2Array([a + side * half * 0.3, b + side * half, b - side * half, a - side * half * 0.3]), Color(BLUE, 0.18 * k))
		for j in 3:
			var off := float(j - 1) * 7.0
			r.draw_line(feet_a + Vector2(0, off * 0.4), feet_b + Vector2(0, off * 0.4), Color(BLUE_PALE, 0.35 * k), 1.5, true)
	)

	# Bubbles in its wake.
	var mid := (a + b) * 0.5
	var p := CPUParticles2D.new()
	p.position = mid
	p.one_shot = true
	p.amount = int(clampf(shift.length() / 14.0, 8.0, 36.0))
	p.lifetime = 0.9
	p.explosiveness = 0.7
	p.texture = VoidReachFX._dot()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(absf(shift.x) * 0.5 + 6.0, size.y * 0.22)
	p.direction = Vector2(0, -1)
	p.spread = 25.0
	p.gravity = Vector2(0, -30)
	p.initial_velocity_min = 15.0
	p.initial_velocity_max = 45.0
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.3
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	ramp.colors = PackedColorArray([Color(BLUE_PALE, 0.0), Color(BLUE_PALE, 0.7), Color(BLUE_PALE, 0.0)])
	p.color_ramp = ramp
	p.material = _additive()
	host.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)

	if hit_node != null and is_instance_valid(hit_node) and hit_node is Control:
		var target_center := _center(hit_node)
		var dir_sign := signf(shift.x) if absf(shift.x) > 1.0 else 1.0
		_runner(host, 0.55, func(r: Runner, age: float) -> void:
			# The jolt of the stop, then three claw slashes.
			var ring := clampf(age / 0.3, 0.0, 1.0)
			r.draw_arc(target_center, lerpf(10.0, 70.0, 1.0 - pow(1.0 - ring, 2.0)), 0.0, TAU, 28, Color(BLUE_PALE, 0.6 * (1.0 - ring)), 3.0 * (1.0 - ring) + 0.5, true)
			r.draw_circle(target_center, lerpf(36.0, 10.0, ring), Color(BLUE, 0.35 * (1.0 - ring)))
			for j in 3:
				var t0 := 0.04 + 0.05 * j
				var s := clampf((age - t0) / 0.14, 0.0, 1.0)
				if s <= 0.0:
					continue
				var fade := 1.0 - clampf((age - t0 - 0.14) / 0.3, 0.0, 1.0)
				var base := target_center + Vector2(dir_sign * (-24.0 + 24.0 * j), -34.0 + 8.0 * j)
				var slash := Vector2(dir_sign * 30.0, 70.0)
				var tip := base + slash * s
				r.draw_line(base, tip, Color(1.0, 0.95, 0.95, 0.85 * fade), 3.0, true)
				r.draw_line(base, tip, Color(BLOOD, 0.8 * fade), 6.0, true)
		)
		_burst(host, target_center, 10, BLOOD.lightened(0.25), Vector2(80.0, 200.0), 0.4, Vector2(0.6, 1.4), Vector2(0, 300), Vector2(0, -1), 90.0, false)


# --- Paralytic Venom ------------------------------------------------

## The toxin cloud: a flattened ring of pale green cloud rolling out of
## `caster` to `reach` px, thick as ink in water, with threads of venom
## flung up along its edge and a spark where it reaches each of `hit_nodes`.
static func venom_cloud(host: Node, caster: Control, reach: float, wave_seconds: float, hit_nodes: Array) -> void:
	if not is_instance_valid(host) or not is_instance_valid(caster):
		return
	var feet := _feet(caster)
	var blobs := 30
	var seeds: Array[float] = []
	for i in blobs:
		seeds.append(randf())
	var life := wave_seconds + 0.9
	_runner(host, life, func(r: Runner, age: float) -> void:
		var t := clampf(age / wave_seconds, 0.0, 1.0)
		var radius := reach * (1.0 - pow(1.0 - t, 2.0))
		var fade := 1.0 - clampf((age - wave_seconds) / 0.9, 0.0, 1.0)
		var tex := _glow_tex()
		for i in blobs:
			var ang := TAU * float(i) / float(blobs) + seeds[i] * 0.4
			var rr := radius * (0.82 + 0.2 * seeds[i]) + sin(age * 3.0 + seeds[i] * 9.0) * 5.0
			var p := feet + Vector2(cos(ang) * rr, sin(ang) * rr * 0.3 - 6.0 * seeds[i])
			var d := (60.0 + 52.0 * seeds[i]) * (0.5 + 0.5 * t)
			var col := VENOM.lerp(VENOM_DEEP, 0.35 + 0.4 * seeds[i])
			r.draw_texture_rect(tex, Rect2(p - Vector2(d, d * 0.62), Vector2(d * 2.0, d * 1.24)), false, Color(col, 0.8 * fade))
		# A pale core line along the front edge.
		var pts := PackedVector2Array()
		for i in 49:
			var ang2 := TAU * float(i) / 48.0
			pts.append(feet + Vector2(cos(ang2), sin(ang2) * 0.3) * radius)
		r.draw_polyline(pts, Color(0.8, 1.0, 0.7, 0.35 * fade), 2.0, true)
	)
	# Toxin thrown up where the wave front arrives.
	for k in 8:
		var ang := TAU * float(k) / 8.0
		var edge := feet + Vector2(cos(ang), sin(ang) * 0.3) * reach
		var tw := host.create_tween()
		tw.tween_interval(wave_seconds * 0.8)
		tw.tween_callback(func() -> void:
			_burst(host, edge, 8, VENOM, Vector2(60.0, 150.0), 0.7, Vector2(0.7, 1.6), Vector2(0, 160), Vector2(0, -1), 40.0)
		)
	for node in hit_nodes:
		if not is_instance_valid(node) or not (node is Control):
			continue
		var nf := _feet(node)
		var frac := clampf(absf(nf.x - feet.x) / maxf(reach, 1.0), 0.0, 1.0)
		var nc := _center(node)
		var tw2 := host.create_tween()
		tw2.tween_interval(wave_seconds * sqrt(frac))
		tw2.tween_callback(func() -> void:
			_burst(host, nc, 14, VENOM, Vector2(40.0, 130.0), 0.65, Vector2(0.6, 1.4), Vector2(0, 90), Vector2(0, -1), 180.0)
		)


## The held state on a unit the venom stunned: set `active` for as long as
## the stun lasts.
static func set_paralysis(node: Variant, active: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	var existing := node.get_node_or_null(PARALYSIS_NAME) as Paralysis
	if active == (existing != null):
		return
	if not active:
		existing.name = PARALYSIS_NAME + "Fading"
		existing.release()
		return
	var p := Paralysis.new()
	p.name = PARALYSIS_NAME
	p.setup(node)
	node.add_child(p)


class Paralysis extends Control:
	var _node: TextureRect
	var _sheen: TextureRect
	var _motes: CPUParticles2D
	var _age := 0.0
	var _release_t := -1.0

	func setup(node: TextureRect) -> void:
		_node = node
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		modulate.a = 0.0
		# A cold green sheen over the whole body: it's gone rigid.
		_sheen = TextureRect.new()
		_sheen.texture = node.texture
		_sheen.expand_mode = node.expand_mode
		_sheen.stretch_mode = node.stretch_mode
		_sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_sheen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_sheen.material = DreadlureFX._additive()
		_sheen.self_modulate = Color(VENOM, 0.0)
		add_child(_sheen)
		# Slow motes of toxin settling off it.
		_motes = CPUParticles2D.new()
		_motes.position = Vector2(node.size.x * 0.5, node.size.y * 0.5)
		_motes.amount = 12
		_motes.lifetime = 2.2
		_motes.texture = VoidReachFX._dot()
		_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		_motes.emission_rect_extents = Vector2(node.size.x * 0.3, node.size.y * 0.3)
		_motes.direction = Vector2(0, 1)
		_motes.spread = 30.0
		_motes.gravity = Vector2(0, 14)
		_motes.initial_velocity_min = 4.0
		_motes.initial_velocity_max = 12.0
		_motes.scale_amount_min = 0.6
		_motes.scale_amount_max = 1.4
		var ramp := Gradient.new()
		ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
		ramp.colors = PackedColorArray([Color(VENOM, 0.0), Color(VENOM, 0.7), Color(VENOM, 0.0)])
		_motes.color_ramp = ramp
		_motes.material = DreadlureFX._additive()
		add_child(_motes)
		_motes.emitting = true
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 1.0, 0.4)

	func release() -> void:
		_release_t = 0.0
		_motes.emitting = false
		DreadlureFX._burst(self, Vector2(_node.size.x * 0.5, _node.size.y * 0.5), 12, DreadlureFX.BLUE_PALE, Vector2(30.0, 90.0), 0.7, Vector2(0.6, 1.4), Vector2(0, -40), Vector2(0, -1), 180.0)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.5)
		tw.tween_callback(queue_free)

	func _process(delta: float) -> void:
		_age += delta
		if not is_instance_valid(_node):
			return
		_sheen.flip_h = _node.flip_h
		var pulse := 0.5 + 0.5 * sin(_age * 2.2)
		_sheen.self_modulate = Color(DreadlureFX.VENOM, 0.24 + 0.14 * pulse)
		queue_redraw()

	func _draw() -> void:
		if not is_instance_valid(_node):
			return
		# Threads of venom hanging off the body.
		var s := _node.size
		for i in 4:
			var x := s.x * (0.28 + 0.15 * i)
			var top := s.y * (0.3 + 0.08 * ((i * 3) % 4))
			var len := s.y * (0.16 + 0.05 * (i % 3)) * (0.85 + 0.15 * sin(_age * 1.5 + i))
			draw_line(Vector2(x, top), Vector2(x + sin(_age + i) * 2.0, top + len), Color(DreadlureFX.VENOM, 0.45), 1.6, true)
			draw_circle(Vector2(x + sin(_age + i) * 2.0, top + len), 2.2, Color(DreadlureFX.VENOM, 0.6))


# --- Might of the Deep ----------------------------------------------

## The charge building toward the next strike: `charge` strikes landed so far
## (0 = none, and nothing shown unless `ready`), `ready` once the next
## attack is the one that lands the full blow.
static func set_might_charge(node: Variant, charge: int, ready: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	var existing := node.get_node_or_null(MIGHT_NAME) as MightCharge
	var wanted := charge > 0 or ready
	if not wanted:
		if existing != null:
			existing.name = MIGHT_NAME + "Fading"
			existing.release()
		return
	if existing == null:
		existing = MightCharge.new()
		existing.name = MIGHT_NAME
		existing.setup(node)
		node.add_child(existing)
	existing.set_state(charge, ready)


class MightCharge extends Control:
	var _node: TextureRect
	var _bubbles: Array[CPUParticles2D] = []
	var _ready_amount := 0.0
	var _ready_target := 0.0
	var _age := 0.0
	var _glows: Array[TextureRect] = []

	func setup(node: TextureRect) -> void:
		_node = node
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 1.0, 0.3)
		for i in DreadlureFX.CLAW_FRACS.size():
			var p := CPUParticles2D.new()
			p.amount = 3
			p.lifetime = 1.6
			p.texture = VoidReachFX._dot()
			p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
			p.emission_sphere_radius = node.size.x * 0.05
			p.direction = Vector2(0, -1)
			p.spread = 30.0
			p.gravity = Vector2(0, -22)
			p.initial_velocity_min = 6.0
			p.initial_velocity_max = 20.0
			p.scale_amount_min = 0.9
			p.scale_amount_max = 1.8
			p.material = DreadlureFX._additive()
			var ramp := Gradient.new()
			ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
			ramp.colors = PackedColorArray([Color(0.35, 0.6, 0.85, 0.0), Color(0.5, 0.75, 1.0, 0.95), Color(0.35, 0.6, 0.85, 0.0)])
			p.color_ramp = ramp
			add_child(p)
			p.emitting = true
			_bubbles.append(p)
			var g := TextureRect.new()
			g.texture = DreadlureFX._glow_tex()
			g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			g.mouse_filter = Control.MOUSE_FILTER_IGNORE
			g.size = Vector2.ONE * node.size.x * 0.22
			g.material = DreadlureFX._additive()
			g.self_modulate = Color(DreadlureFX.BLUE, 0.0)
			add_child(g)
			_glows.append(g)

	func set_state(charge: int, ready: bool) -> void:
		for p in _bubbles:
			p.amount = 3 + 3 * clampi(charge, 0, 4)
		_ready_target = 1.0 if ready else 0.0

	func release() -> void:
		for p in _bubbles:
			p.emitting = false
		_ready_target = 0.0
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.5)
		tw.tween_callback(queue_free)

	func _process(delta: float) -> void:
		_age += delta
		if not is_instance_valid(_node):
			return
		_ready_amount = move_toward(_ready_amount, _ready_target, delta * 3.0)
		for i in DreadlureFX.CLAW_FRACS.size():
			var f: Vector2 = DreadlureFX.CLAW_FRACS[i]
			if _node.flip_h:
				f.x = 1.0 - f.x
			var at := _node.size * f
			_bubbles[i].position = at
			var g := _glows[i]
			g.position = at - g.size * 0.5
			g.pivot_offset = g.size * 0.5
			var pulse := 0.5 + 0.5 * sin(_age * 3.4 + i * 1.7)
			g.self_modulate = Color(DreadlureFX.BLUE, _ready_amount * (0.35 + 0.3 * pulse))
			g.scale = Vector2.ONE * (0.8 + 0.3 * pulse)
		queue_redraw()

	func _draw() -> void:
		if _ready_amount <= 0.01 or not is_instance_valid(_node):
			return
		# Pressure rolling off it: a slow ring on the floor.
		var feet := Vector2(_node.size.x * 0.5, _node.size.y * 0.92)
		var cycle := fposmod(_age * 0.8, 1.0)
		var rad := _node.size.x * (0.2 + 0.32 * cycle)
		draw_arc(feet, rad, 0.0, TAU, 32, Color(DreadlureFX.BLUE_PALE, 0.35 * _ready_amount * (1.0 - cycle)), 2.0, true)


## The full blow landing on `target` (and `direction`: +1 or -1, the way it's
## shoved): a deep shockwave rolling off the point of impact, silt thrown up
## off the floor, pressure lines streaking after the target.
static func might_strike(host: Node, target: Control, direction: int) -> void:
	if not is_instance_valid(host) or not is_instance_valid(target):
		return
	var center := _center(target)
	var feet := _feet(target)
	var dir := float(direction) if direction != 0 else 1.0
	_runner(host, 0.6, func(r: Runner, age: float) -> void:
		var t := clampf(age / 0.45, 0.0, 1.0)
		var e := 1.0 - pow(1.0 - t, 3.0)
		var fade := 1.0 - t
		# The shockwave ring, on the water and across the floor.
		r.draw_arc(center, lerpf(14.0, 110.0, e), 0.0, TAU, 36, Color(BLUE_PALE, 0.65 * fade), 4.0 * fade + 0.8, true)
		var pts := PackedVector2Array()
		for i in 41:
			var a := TAU * float(i) / 40.0
			pts.append(feet + Vector2(cos(a), sin(a) * 0.28) * lerpf(10.0, 150.0, e))
		r.draw_polyline(pts, Color(BLUE, 0.5 * fade), 3.0 * fade + 0.6, true)
		r.draw_circle(center, lerpf(46.0, 8.0, t), Color(1, 1, 1, 0.4 * fade))
		# Pressure lines, in the direction it's thrown.
		for j in 5:
			var y := center.y + (float(j) - 2.0) * 16.0
			var x0 := center.x + dir * (20.0 + 12.0 * j)
			var len := lerpf(10.0, 80.0, e) * (0.7 + 0.3 * float(j % 2))
			r.draw_line(Vector2(x0, y), Vector2(x0 + dir * len, y), Color(BLUE_PALE, 0.5 * fade), 1.8, true)
	)
	_burst(host, feet, 30, SILT, Vector2(60.0, 190.0), 0.9, Vector2(2.0, 4.5), Vector2(0, 120), Vector2(0, -1), 70.0, false)
	_burst(host, feet, 12, BLUE_PALE, Vector2(30.0, 110.0), 0.8, Vector2(0.6, 1.4), Vector2(0, -30), Vector2(0, -1), 120.0)


# --- Deathlight Lure ------------------------------------------------

## The cast: the lure on `caster` flares with blue light, and a thread of
## that light runs out to `target`; `on_connect` fires where it lands.
static func lure_flash(host: Node, caster: Control, target: Control, on_connect: Callable = Callable()) -> void:
	if not is_instance_valid(host) or not is_instance_valid(caster) or not is_instance_valid(target):
		return
	var origin := _point(caster, LURE_FRAC)
	var aim := _center(target)
	var flare := 0.28
	var travel := 0.3
	var hold := 0.35
	_runner(host, flare + travel + hold + 0.35, func(r: Runner, age: float) -> void:
		var tex := _glow_tex()
		# The flare: a bloom with cold rays, swelling then dying down.
		var fk := clampf(age / flare, 0.0, 1.0)
		var fade_f := 1.0 - clampf((age - flare) / (travel + hold + 0.3), 0.0, 1.0)
		var bloom := (28.0 + 70.0 * fk) * (0.5 + 0.5 * fade_f)
		r.draw_texture_rect(tex, Rect2(origin - Vector2.ONE * bloom, Vector2.ONE * bloom * 2.0), false, Color(BLUE, 0.9 * fade_f))
		r.draw_circle(origin, 10.0 * (0.6 + 0.4 * fade_f), Color(1, 1, 1, 0.9 * fade_f))
		for i in 6:
			var ang := TAU * float(i) / 6.0 + 0.3
			var l := bloom * (1.1 + 0.4 * sin(float(i) * 2.0))
			r.draw_line(origin, origin + Vector2(cos(ang), sin(ang)) * l * fk, Color(BLUE_PALE, 0.5 * fade_f), 1.6, true)
		# The thread: reaches out to the target, then thins away.
		var tk := clampf((age - flare) / travel, 0.0, 1.0)
		if tk > 0.0:
			var end := origin.lerp(aim, tk)
			var thin := 1.0 - clampf((age - flare - travel) / hold, 0.0, 1.0)
			var mid := (origin + end) * 0.5 + Vector2(0, 14.0 * sin(tk * PI))
			var pts := PackedVector2Array()
			for i in 13:
				var f := float(i) / 12.0
				pts.append(origin.lerp(mid, f).lerp(mid.lerp(end, f), f))
			r.draw_polyline(pts, Color(BLUE, 0.35 * thin), 9.0 * thin + 1.0, true)
			r.draw_polyline(pts, Color(BLUE_PALE, 0.9 * thin), 2.6 * thin + 0.6, true)
			r.draw_circle(end, 6.0 + 4.0 * thin, Color(1, 1, 1, 0.8 * thin))
		# Where it lands: a ring.
		var ik := clampf((age - flare - travel) / 0.4, 0.0, 1.0)
		if age > flare + travel:
			r.draw_arc(aim, lerpf(10.0, 64.0, 1.0 - pow(1.0 - ik, 2.0)), 0.0, TAU, 28, Color(BLUE_PALE, 0.7 * (1.0 - ik)), 3.0 * (1.0 - ik) + 0.5, true)
			r.draw_circle(aim, lerpf(40.0, 8.0, ik), Color(BLUE, 0.35 * (1.0 - ik)))
	)
	if on_connect.is_valid():
		var tw := host.create_tween()
		tw.tween_interval(flare + travel)
		tw.tween_callback(func() -> void: on_connect.call(target))


## The mark on a unit: the lure hung over its head, bobbing, with rings of
## light pulsing out of it, and a cold outline round the body.
static func set_mark(node: Variant, active: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	var existing := node.get_node_or_null(MARK_NAME) as Mark
	if active == (existing != null):
		return
	if not active:
		existing.name = MARK_NAME + "Fading"
		existing.release()
		return
	var m := Mark.new()
	m.name = MARK_NAME
	m.setup(node)
	node.add_child(m)


class Mark extends Control:
	const LURE_AT := Vector2(0.5, -0.1)

	var _node: TextureRect
	var _outline: TextureRect
	var _glow: TextureRect
	var _age := 0.0

	func setup(node: TextureRect) -> void:
		_node = node
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		modulate.a = 0.0
		var add := DreadlureFX._additive()
		# The outline: a slightly larger additive copy, tinted cold blue.
		_outline = TextureRect.new()
		_outline.texture = node.texture
		_outline.expand_mode = node.expand_mode
		_outline.stretch_mode = node.stretch_mode
		_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_outline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_outline.pivot_offset = node.size * 0.5
		_outline.scale = Vector2.ONE * 1.04
		_outline.material = add
		_outline.self_modulate = Color(DreadlureFX.BLUE, 0.0)
		add_child(_outline)
		_glow = TextureRect.new()
		_glow.texture = DreadlureFX._glow_tex()
		_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_glow.size = Vector2.ONE * minf(node.size.x, node.size.y) * 0.5
		_glow.pivot_offset = _glow.size * 0.5
		_glow.material = add
		_glow.self_modulate = Color(DreadlureFX.BLUE, 0.9)
		add_child(_glow)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 1.0, 0.4)

	func release() -> void:
		if is_instance_valid(_node):
			DreadlureFX._burst(self, _node.size * Vector2(LURE_AT.x, LURE_AT.y), 14, DreadlureFX.BLUE_PALE, Vector2(30.0, 100.0), 0.8, Vector2(0.6, 1.5), Vector2(0, 30), Vector2(0, -1), 180.0)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.5)
		tw.tween_callback(queue_free)

	func _process(delta: float) -> void:
		_age += delta
		if not is_instance_valid(_node):
			return
		_outline.flip_h = _node.flip_h
		var pulse := 0.5 + 0.5 * sin(_age * 2.0)
		_outline.self_modulate = Color(DreadlureFX.BLUE, 0.14 + 0.14 * pulse)
		var at := _lure_pos()
		_glow.position = at - _glow.size * 0.5
		_glow.scale = Vector2.ONE * (0.8 + 0.25 * pulse)
		queue_redraw()

	func _lure_pos() -> Vector2:
		return _node.size * LURE_AT + Vector2(0.0, sin(_age * 1.6) * 5.0)

	func _draw() -> void:
		if not is_instance_valid(_node):
			return
		var at := _lure_pos()
		var head := Vector2(_node.size.x * 0.5, _node.size.y * 0.1)
		# The stalk it hangs from, curving down to the head.
		var ctrl := (at + head) * 0.5 + Vector2(10.0, 0.0)
		var pts := PackedVector2Array()
		for i in 11:
			var f := float(i) / 10.0
			pts.append(at.lerp(ctrl, f).lerp(ctrl.lerp(head, f), f))
		draw_polyline(pts, Color(0.55, 0.85, 1.0, 0.45), 1.4, true)
		draw_circle(at, 4.5, Color(1, 1, 1, 0.95))
		# Rings of light pulsing out of it.
		for k in 2:
			var cycle := fposmod(_age * 0.7 + 0.5 * k, 1.0)
			draw_arc(at, 8.0 + 34.0 * cycle, 0.0, TAU, 28, Color(DreadlureFX.BLUE_PALE, 0.5 * (1.0 - cycle)), 1.8, true)
