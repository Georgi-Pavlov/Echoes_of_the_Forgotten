class_name WovenFleshFX
extends Control

## Purely cosmetic: the Rootmother's Woven Flesh - living roots drawn up
## beneath her skin, weaving bark, flesh and plant into a shell.
##
##   1. Cast: the ground splits at her feet, and strands of thorned bark
##      and raw red fibre grow up out of it, spiralling around her body
##      and knitting into a woven sheath from the hips to the shoulders
##      (her face is left clear).
##   2. While it holds: the strands slowly shift as if breathing, a dull
##      warm light creeping along them. Each time it mends her (pulse_on())
##      a wave of that light runs up the weave and motes of life rise from
##      it.
##   3. When it ends the strands loosen, unravel and sink back into the
##      ground.
##
## A child of the hero's (or rival's) sprite, so it follows it around;
## Everything is drawn in the sprite's own proportions, mirrored with it
## when it faces the other way. battle.gd drives it with set_on() and
## pulse_on().

const MARK_NAME := "WovenFleshShell"
const GROW_TIME := 0.9
const LEAVE_TIME := 0.7
const WAVE_TIME := 0.9
const SEGMENTS := 40

const BARK := Color(0.15, 0.09, 0.06)
const BARK_LIGHT := Color(0.46, 0.32, 0.2)
const FLESH := Color(0.32, 0.05, 0.08)
const FLESH_LIGHT := Color(0.62, 0.18, 0.16)
const MOSS := Color(0.28, 0.33, 0.12)
const ROOT := Color(0.15, 0.1, 0.07)
const SOIL := Color(0.26, 0.17, 0.1)
const LIFE := Color(0.55, 0.72, 0.3)

## Her body as a column, in fractions of the sprite: [y, centre x, half
## width], from the roots up to the base of her neck.
const BODY := [[0.93, 0.58, 0.27], [0.75, 0.6, 0.22], [0.55, 0.63, 0.15], [0.4, 0.65, 0.12], [0.3, 0.67, 0.1]]
const Y_BOTTOM := 0.93
const Y_TOP := 0.3

var _age := 0.0
var _leave_t := -1.0
var _wave := -1.0
var _strands: Array[Dictionary] = []
var _ground_roots: Array[Dictionary] = []
var _glow: Control
var _motes: CPUParticles2D


## Puts Woven Flesh's shell on `node` (a TextureRect), or takes it off. Only
## does anything when the state actually changes - the shell's presence on
## the node is the "currently on" marker.
static func set_on(node: Variant, active: bool) -> void:
	if node == null or not is_instance_valid(node) or not (node is TextureRect):
		return
	var existing := node.get_node_or_null(MARK_NAME) as WovenFleshFX
	if active == (existing != null):
		return
	if not active:
		# Renamed right away so a quick recast during the unravel creates a
		# fresh shell instead of finding this dying one.
		existing.name = MARK_NAME + "Fading"
		existing._leave_t = 0.0
		return
	var shell := WovenFleshFX.new()
	shell.name = MARK_NAME
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.add_child(shell)


## Runs a wave of light up `node`'s shell as it mends her.
static func pulse_on(node: Variant) -> void:
	if node == null or not is_instance_valid(node) or not (node is Node):
		return
	var shell := (node as Node).get_node_or_null(MARK_NAME) as WovenFleshFX
	if shell != null:
		shell._start_wave()


func _ready() -> void:
	# Gnarled strands of thorned bark with raw red fibre twisted between
	# them, wound both ways round her so they cross and knot.
	var pitches := [1.5, 2.3, 3.1, 4.0, 1.9, 2.8, 3.6]
	for i in 7:
		var flesh := i == 2 or i == 5
		_strands.append({
			"kind": "flesh" if flesh else "bark",
			"dir": 1.0 if i % 3 != 0 else -1.0,
			"turns": float(pitches[i]) + randf_range(-0.15, 0.15),
			"phase": randf() * TAU,
			"width": 3.8 if flesh else 6.0,
			"delay": randf_range(0.0, 0.3),
		})
	for i in 7:
		_ground_roots.append({
			"dir": Vector2(randf_range(-1.0, 1.0), randf_range(0.0, 0.25)).normalized(),
			"length": randf_range(0.12, 0.26),
			"seed": randf() * TAU,
		})

	_glow = Control.new()
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = mat
	_glow.draw.connect(_draw_glow)
	add_child(_glow)

	_motes = CPUParticles2D.new()
	_motes.material = mat
	_motes.texture = _dot()
	_motes.one_shot = true
	_motes.emitting = false
	_motes.amount = 12
	_motes.lifetime = 1.3
	_motes.explosiveness = 0.5
	_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_motes.direction = Vector2(0.0, -1.0)
	_motes.spread = 25.0
	_motes.gravity = Vector2(0.0, -22.0)
	_motes.initial_velocity_min = 6.0
	_motes.initial_velocity_max = 20.0
	_motes.scale_amount_min = 0.15
	_motes.scale_amount_max = 0.4
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(LIFE, 0.0), Color(LIFE, 0.7), Color(LIFE, 0.3), Color(LIFE, 0.0)])
	_motes.color_ramp = ramp
	add_child(_motes)

	# The ground splits as it begins.
	var parent := get_parent() as Control
	if parent != null:
		var burst := CPUParticles2D.new()
		burst.one_shot = true
		burst.explosiveness = 0.95
		burst.amount = 14
		burst.lifetime = 0.55
		burst.spread = 80.0
		burst.direction = Vector2(0.0, -1.0)
		burst.gravity = Vector2(0.0, 320.0)
		burst.initial_velocity_min = 50.0
		burst.initial_velocity_max = 140.0
		burst.scale_amount_min = 1.6
		burst.scale_amount_max = 3.2
		burst.color = SOIL
		burst.position = Vector2(parent.size.x * 0.5, parent.size.y * Y_BOTTOM)
		add_child(burst)
		burst.emitting = true
		burst.finished.connect(burst.queue_free)


func _process(delta: float) -> void:
	_age += delta
	if _leave_t >= 0.0:
		_leave_t += delta
		if _leave_t >= LEAVE_TIME:
			queue_free()
			return
	if _wave >= 0.0:
		_wave += delta
		if _wave >= WAVE_TIME:
			_wave = -1.0
	queue_redraw()
	if is_instance_valid(_glow):
		_glow.queue_redraw()


func _start_wave() -> void:
	_wave = 0.0
	var parent := get_parent() as Control
	if parent == null or not is_instance_valid(_motes):
		return
	var cx := _body(0.6).x
	if parent is TextureRect and (parent as TextureRect).flip_h:
		cx = 1.0 - cx
	_motes.position = Vector2(parent.size.x * cx, parent.size.y * 0.62)
	_motes.emission_rect_extents = Vector2(parent.size.x * 0.14, parent.size.y * 0.2)
	_motes.restart()
	_motes.emitting = true


# --- the weave ------------------------------------------------------

func _grow() -> float:
	return clampf(_age / GROW_TIME, 0.0, 1.0)


func _leave() -> float:
	if _leave_t < 0.0:
		return 0.0
	var t := clampf(_leave_t / LEAVE_TIME, 0.0, 1.0)
	return t * t


## Centre x and half width (fractions of the sprite) of her body at `y`.
func _body(y: float) -> Vector2:
	for i in BODY.size() - 1:
		var a: Array = BODY[i]
		var b: Array = BODY[i + 1]
		if y <= float(a[0]) and y >= float(b[0]):
			var t := (float(a[0]) - y) / (float(a[0]) - float(b[0]))
			return Vector2(lerpf(float(a[1]), float(b[1]), t), lerpf(float(a[2]), float(b[2]), t))
	var edge: Array = BODY[0] if y > float(BODY[0][0]) else BODY[BODY.size() - 1]
	return Vector2(float(edge[1]), float(edge[2]))


## How far up the body strand `s` has grown (0..1) - each rises on its own
## delay, and they all withdraw as the shell unravels.
func _reach(s: Dictionary) -> float:
	var g := clampf((_grow() - float(s["delay"])) / (1.0 - float(s["delay"])), 0.0, 1.0)
	g = 1.0 - pow(1.0 - g, 2.5)
	return g * (1.0 - _leave())


## A point on strand `s` at `u` (0 = ground .. 1 = shoulders): x, y in
## sprite pixels, z the depth (> 0: round the front of her).
func _strand_point(s: Dictionary, u: float, size: Vector2, flip: bool, spread: float) -> Vector3:
	var y := lerpf(Y_BOTTOM, Y_TOP, u)
	var body := _body(y)
	var cx := (1.0 - body.x) if flip else body.x
	var ph: float = s["phase"]
	# The twist speeds up and slows down along its length and the radius
	# swells and pinches, so no two strands run alike.
	var phi: float = float(s["dir"]) * float(s["turns"]) * u * TAU + ph + _age * 0.3 * float(s["dir"]) + sin(u * 5.0 + ph * 2.0) * 0.9
	var hw := body.y * (0.85 + 0.2 * sin(u * 9.0 + ph) + 0.05 * sin(_age * 1.3 + u * 6.0 + ph)) * spread
	# A little knotty wobble so no strand runs true.
	var wobble := sin(u * 23.0 + float(s["phase"]) * 1.7) * 1.8 + sin(u * 51.0 + float(s["phase"])) * 0.8
	return Vector3((cx + hw * cos(phi)) * size.x + wobble, y * size.y + sin(phi) * hw * size.y * 0.07 + wobble * 0.5, sin(phi))


func _draw() -> void:
	var node := get_parent() as TextureRect
	if node == null:
		return
	var size := node.size
	var flip := node.flip_h
	var leave := _leave()
	var spread := 1.0 + 0.5 * leave
	var alpha := 1.0 - leave * leave
	_draw_ground_roots(size, flip, alpha)
	# Back of the weave first, then the front over it.
	for pass_i in 2:
		for s in _strands:
			_draw_strand(s, pass_i == 1, size, flip, spread, alpha)


## Roots gripping the ground at her feet, where the strands come up.
func _draw_ground_roots(size: Vector2, flip: bool, alpha: float) -> void:
	var g := 1.0 - pow(1.0 - clampf(_grow() / 0.5, 0.0, 1.0), 2.0)
	g *= 1.0 - _leave()
	var base_x := (1.0 - 0.5) if flip else 0.5
	var origin := Vector2(size.x * base_x, size.y * 0.94)
	for r in _ground_roots:
		var dir: Vector2 = r["dir"]
		var length: float = float(r["length"]) * size.x * g
		var prev := origin
		for k in range(1, 7):
			var t := float(k) / 6.0
			var wave := sin(t * 5.0 + float(r["seed"])) * 2.0 * t
			var p := origin + Vector2(dir.x * length * t, dir.y * length * t * 0.5 + wave)
			draw_line(prev, p, Color(ROOT, alpha), lerpf(3.0, 0.8, t), true)
			prev = p


func _draw_strand(s: Dictionary, front_pass: bool, size: Vector2, flip: bool, spread: float, alpha: float) -> void:
	var reach := _reach(s)
	if reach <= 0.01:
		return
	var flesh: bool = s["kind"] == "flesh"
	var base_col := FLESH if flesh else BARK
	var light_col := FLESH_LIGHT if flesh else BARK_LIGHT
	var width0: float = s["width"]
	var prev := _strand_point(s, 0.0, size, flip, spread)
	for k in range(1, SEGMENTS + 1):
		var u := float(k) / SEGMENTS * reach
		var p := _strand_point(s, u, size, flip, spread)
		var front := (p.z + prev.z) * 0.5 >= 0.0
		if front == front_pass:
			var width := lerpf(width0, width0 * 0.3, float(k) / SEGMENTS) * (1.0 if front else 0.75)
			# Fat in the middle of each run, pinched where it dives round the
			# back - so it reads as a rope going round, not a wire.
			width *= 0.75 + 0.25 * clampf(absf(p.z) * 1.4, 0.0, 1.0)
			var col := base_col
			if not flesh:
				col = col.lerp(MOSS, 0.22 * smoothstep(0.5, 0.95, sin(float(k) * 0.9 + float(s["phase"])) * 0.5 + 0.5))
			if not front:
				col = col.darkened(0.45)
			var a := alpha * (1.0 if front else 0.7)
			var from := Vector2(prev.x, prev.y)
			var to := Vector2(p.x, p.y)
			# Dark outline, then the body, both with rounded joints so the
			# strand reads as one smooth rope.
			var dark := Color(col.darkened(0.5), a)
			draw_line(from, to, dark, width + 1.6, true)
			draw_circle(to, (width + 1.6) * 0.5, dark)
			draw_line(from, to, Color(col, a), width, true)
			draw_circle(to, width * 0.5, Color(col, a))
			if front:
				draw_line(from + Vector2(-0.9, -0.9), to + Vector2(-0.9, -0.9), Color(light_col, 0.3 * alpha), maxf(width * 0.28, 1.0), true)
				var dir := (to - from).normalized()
				var n := dir.orthogonal()
				# Ridges of bark across the strand.
				if k % 2 == 0:
					draw_line(to + n * width * 0.45, to - n * width * 0.45, Color(0.04, 0.02, 0.01, 0.45 * alpha), 1.0, true)
				# A thorn here and there on the bark.
				if not flesh and k % 6 == 0 and k < SEGMENTS:
					var side := 1.0 if k % 12 == 0 else -1.0
					draw_colored_polygon(PackedVector2Array([from - dir * 2.0, from + n * side * (5.0 + width * 0.3) + dir, from + dir * 2.0]), Color(ROOT.lightened(0.08), alpha))
		prev = p


## A dull warm light creeping along the strands and across her body, and the
## wave of light that runs up the weave each time it mends her.
func _draw_glow() -> void:
	var node := get_parent() as TextureRect
	if node == null:
		return
	var size := node.size
	var flip := node.flip_h
	var leave := _leave()
	var spread := 1.0 + 0.5 * leave
	var keep := 1.0 - leave
	var breathe := 0.8 + 0.2 * sin(_age * 1.8)
	var g := _grow()
	# A faint haze over the sheath.
	for y in [0.5, 0.65, 0.8]:
		var body := _body(y)
		var cx := (1.0 - body.x) if flip else body.x
		_glow.draw_circle(Vector2(cx * size.x, y * size.y), size.x * 0.17, Color(LIFE, 0.025 * breathe * g * keep))
	for s in _strands:
		var reach := _reach(s)
		if reach <= 0.05:
			continue
		# A bead of light drifting up each strand.
		var bu := fposmod(_age * 0.22 + float(s["phase"]), 1.0) * reach
		var bp := _strand_point(s, bu, size, flip, spread)
		_glow.draw_circle(Vector2(bp.x, bp.y), 1.8, Color(LIFE, (0.5 if bp.z >= 0.0 else 0.2) * keep))
		# The wave.
		if _wave >= 0.0:
			var wu := _wave / WAVE_TIME
			var prev := _strand_point(s, 0.0, size, flip, spread)
			for k in range(1, SEGMENTS + 1):
				var u := float(k) / SEGMENTS * reach
				var p := _strand_point(s, u, size, flip, spread)
				var d := absf(u - wu)
				var f := clampf(1.0 - d / 0.18, 0.0, 1.0)
				if f > 0.0 and p.z >= -0.2:
					_glow.draw_line(Vector2(prev.x, prev.y), Vector2(p.x, p.y), Color(LIFE, 0.32 * f * (1.0 - wu * 0.5) * keep), 3.0 * f + 1.0, true)
				prev = p


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
