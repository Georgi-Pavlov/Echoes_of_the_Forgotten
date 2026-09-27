class_name ReturnToVoidFX
extends Node2D

## Purely cosmetic: Nhal's ultimate, Return to the Void - "The Unmaking".
##
##   1. The mark: a sigil brands itself onto the target - a ring of frost
##      runes around a black, star-filled eye that opens.
##   2. The world holds its breath: the battlefield dims and drains toward
##      grey while hairline cracks of cold light spread from the target
##      out across the radius.
##   3. Erasure: the world inside that dome breaks into shards that fall
##      away into nothing, revealing the void before creation. Everyone
##      caught is hollowed out (their silhouettes turn to void), a cold
##      shockwave rolls out to the edge, the screen shakes. This is the
##      moment `on_impact` fires - the damage is the caller's.
##   4. Aftermath: reality knits back from the edges in, leaving a ring
##      of rime on the ground, and the world's colour returns.
##
## The erasure itself is void_erasure.gdshader on a full-screen rect the
## caller puts behind the fighters; the sigil and the shockwave are
## drawn by this node, over them.
##
## Also home to Return to the Void's lingering pieces, which battle.gd
## keeps in sync with game state: the void mark on everyone still under
## its DoT (set_void_mark()), the execute threshold under an enemy's HP
## label (update_threshold_bar()), and the death of anyone the threshold
## claims (claim()).

const SIGIL_TIME := 0.4
const BREATH_TIME := 0.5
const ERASE_TIME := 0.45
const VOID_HOLD := 0.4
const HEAL_TIME := 0.8
const FROST_FADE := 0.9
const SHOCK_TIME := 0.45
const RUNES := 10

const ERASURE_SHADER := preload("res://shaders/void_erasure.gdshader")
const TEAR_SHADER := preload("res://shaders/hollow_cold_tear.gdshader")
const SILHOUETTE_SHADER := preload("res://shaders/void_silhouette.gdshader")

const VOID := Color(0.03, 0.02, 0.08)
const RIM := Color(0.72, 0.88, 1.0)
const GLOW := Color(0.45, 0.55, 1.0)
const STAR := Color(0.9, 0.93, 1.0)
const EMBER := Color(1.0, 0.55, 0.2)
const FROST := Color(0.8, 0.93, 1.0)

const VOID_MARK_NAME := "VoidMark"
const THRESHOLD_BAR_NAME := "VoidThreshold"

var _center: Vector2
var _radii: Vector2
var _sigil_size := 30.0
var _struck: Array = []
var _on_impact: Callable
var _on_finished: Callable
var _erasure: ColorRect
var _mat: ShaderMaterial
var _age := 0.0
var _impacted := false
var _glow: Node2D
var _body: Node2D
var _runes: Array[PackedVector2Array] = []


## Plays Return to the Void on `target` (its sprite). `behind_host` gets
## the full-screen erasure rect at child index `behind_index` (behind the
## fighters, over the battle background); `front_host` gets the sigil
## and shockwave. `radii` is the erased dome's half-size in px, and
## `struck` every unit sprite caught in it (hollowed out at the moment of
## impact). Positions are captured now, so a unit killed by the blast
## still gets the whole show.
static func play(behind_host: Control, behind_index: int, front_host: Node, target: Control,
		radii: Vector2, struck: Array, on_impact: Callable = Callable(), on_finished: Callable = Callable()) -> void:
	var fx := ReturnToVoidFX.new()
	fx._center = target.global_position + target.size * Vector2(0.5, 0.5)
	fx._radii = radii
	fx._sigil_size = clampf(target.size.x * 0.3, 24.0, 56.0)
	fx._struck = struck
	fx._on_impact = on_impact
	fx._on_finished = on_finished

	var mat := ShaderMaterial.new()
	mat.shader = ERASURE_SHADER
	var view: Vector2 = behind_host.get_viewport_rect().size
	mat.set_shader_parameter("rect_size", view)
	mat.set_shader_parameter("center_px", fx._center - behind_host.global_position)
	mat.set_shader_parameter("radii_px", radii)
	mat.set_shader_parameter("seed", randf() * 50.0)
	var erasure := ColorRect.new()
	erasure.material = mat
	erasure.mouse_filter = Control.MOUSE_FILTER_IGNORE
	erasure.position = Vector2.ZERO
	erasure.size = view
	behind_host.add_child(erasure)
	behind_host.move_child(erasure, behind_index)
	fx._erasure = erasure
	fx._mat = mat

	front_host.add_child(fx)
	fx.global_position = Vector2.ZERO


func _ready() -> void:
	_body = Node2D.new()
	_body.draw.connect(_draw_body)
	add_child(_body)
	_glow = Node2D.new()
	_glow.material = _additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	# Each rune a few short strokes, in its own cell (-1..1).
	for i in RUNES:
		var strokes := PackedVector2Array()
		for j in 3:
			var a := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
			var b := a + Vector2.from_angle(randi_range(0, 3) * PI * 0.5 + randf_range(-0.3, 0.3)) * randf_range(0.8, 1.4)
			strokes.append(a.clamp(Vector2(-1, -1), Vector2(1, 1)))
			strokes.append(b.clamp(Vector2(-1, -1), Vector2(1, 1)))
		_runes.append(strokes)


func _process(delta: float) -> void:
	_age += delta
	var t_breath := SIGIL_TIME
	var t_erase := t_breath + BREATH_TIME
	var t_hold := t_erase + ERASE_TIME
	var t_heal := t_hold + VOID_HOLD
	var t_end := t_heal + HEAL_TIME + FROST_FADE

	var dim := smoothstep(t_breath, t_erase, _age) * (1.0 - smoothstep(t_heal, t_heal + HEAL_TIME, _age))
	# The cracks spread while the world holds its breath, and are gone
	# once it has knit back.
	var crack := smoothstep(t_breath, t_erase, _age) * (1.0 - smoothstep(t_heal, t_heal + HEAL_TIME * 0.6, _age))
	var erase := clampf((_age - t_erase) / ERASE_TIME, 0.0, 1.0)
	var heal := clampf((_age - t_heal) / HEAL_TIME, 0.0, 1.0)
	var frost := smoothstep(t_heal + HEAL_TIME * 0.4, t_heal + HEAL_TIME, _age) * (1.0 - clampf((_age - t_heal - HEAL_TIME) / FROST_FADE, 0.0, 1.0))
	if is_instance_valid(_mat):
		_mat.set_shader_parameter("dim", dim)
		_mat.set_shader_parameter("crack", crack)
		_mat.set_shader_parameter("erase", erase)
		_mat.set_shader_parameter("heal", heal)
		_mat.set_shader_parameter("frost", frost)

	if not _impacted and _age >= t_erase:
		_impacted = true
		_impact()
	if _age >= t_end:
		if is_instance_valid(_erasure):
			_erasure.queue_free()
		if _on_finished.is_valid():
			_on_finished.call()
		queue_free()
		return
	_glow.queue_redraw()
	_body.queue_redraw()


func _impact() -> void:
	for node in _struck:
		if is_instance_valid(node) and node is TextureRect:
			VoidReachFX.hollow_out(node, ERASE_TIME + 0.15)
	# Stardust torn off the world, sucked in toward the center.
	var dust := CPUParticles2D.new()
	dust.position = _center
	dust.amount = 60
	dust.lifetime = 0.7
	dust.one_shot = true
	dust.explosiveness = 0.7
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = _radii
	dust.gravity = Vector2.ZERO
	dust.radial_accel_min = -500.0
	dust.radial_accel_max = -300.0
	dust.texture = VoidReachFX._dot()
	dust.scale_amount_min = 0.5
	dust.scale_amount_max = 1.0
	dust.material = _additive()
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	ramp.colors = PackedColorArray([Color(STAR, 0.0), STAR, Color(GLOW, 0.0)])
	dust.color_ramp = ramp
	get_parent().add_child(dust)
	dust.emitting = true
	get_tree().create_timer(1.0).timeout.connect(dust.queue_free)
	if _on_impact.is_valid():
		_on_impact.call()


# --- the sigil and the shockwave -------------------------------------

## x: how far the sigil has formed (0..1), y: how open its eye is, z: how
## far it has collapsed into the eye at the impact (0..1).
func _sigil_state() -> Vector3:
	var form := clampf(_age / SIGIL_TIME, 0.0, 1.0)
	var open := smoothstep(SIGIL_TIME * 0.6, SIGIL_TIME + BREATH_TIME * 0.6, _age)
	var collapse := clampf((_age - SIGIL_TIME - BREATH_TIME) / 0.15, 0.0, 1.0)
	return Vector3(form, open, collapse)


func _ellipse(center: Vector2, radii: Vector2, points: int = 32) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in points + 1:
		var a := TAU * i / points
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	return pts


func _draw_body() -> void:
	var s := _sigil_state()
	if s.x <= 0.0 or s.z >= 1.0:
		return
	var ease_in := 1.0 - pow(1.0 - s.x, 3.0)
	var r := _sigil_size * lerpf(1.8, 1.0, ease_in) * (1.0 - s.z)
	# The eye: black, opening, stars glinting in it.
	var eye := _ellipse(_center, Vector2(r * 0.5, r * 0.5 * lerpf(0.1, 0.62, s.y)))
	_body.draw_colored_polygon(eye, Color(VOID, 0.95 * s.x))


func _draw_glow() -> void:
	var s := _sigil_state()
	if s.x > 0.0 and s.z < 1.0:
		var ease_in := 1.0 - pow(1.0 - s.x, 3.0)
		var r := _sigil_size * lerpf(1.8, 1.0, ease_in) * (1.0 - s.z)
		var a := s.x
		# Charging up while the world holds its breath.
		var charge := smoothstep(SIGIL_TIME, SIGIL_TIME + BREATH_TIME, _age)
		var pulse := 0.8 + 0.2 * sin(_age * 18.0) * charge
		_glow.draw_circle(_center, r * (1.6 + 0.5 * charge), Color(GLOW, 0.14 * a * pulse))
		_glow.draw_polyline(_ellipse(_center, Vector2(r, r)), Color(RIM, 0.85 * a * pulse), 2.0, true)
		_glow.draw_polyline(_ellipse(_center, Vector2(r * 0.72, r * 0.72)), Color(RIM, 0.6 * a * pulse), 1.2, true)
		# Runes between the rings, burning in one by one, turning slowly.
		var turn := _age * 0.7
		for i in RUNES:
			var shown := clampf((_age - 0.03 * i) / 0.12, 0.0, 1.0)
			if shown <= 0.0:
				continue
			var ang := turn + TAU * i / RUNES
			var c := _center + Vector2.from_angle(ang) * r * 0.86
			var rot := Vector2.from_angle(ang + PI * 0.5)
			var glyph_size := r * 0.09
			var strokes: PackedVector2Array = _runes[i]
			for j in range(0, strokes.size(), 2):
				var p0 := c + (rot * strokes[j].x + rot.orthogonal() * strokes[j].y) * glyph_size
				var p1 := c + (rot * strokes[j + 1].x + rot.orthogonal() * strokes[j + 1].y) * glyph_size
				_glow.draw_line(p0, p1, Color(RIM, 0.9 * a * shown * pulse), 1.3, true)
		# The eye's icy iris and a star in its pupil.
		var eye_r := Vector2(r * 0.5, r * 0.5 * lerpf(0.1, 0.62, s.y))
		_glow.draw_polyline(_ellipse(_center, eye_r), Color(RIM, 0.9 * a), 1.4, true)
		var tw := 0.6 + 0.4 * sin(_age * 22.0)
		_glow.draw_circle(_center, 1.5 + 2.0 * s.y * tw, Color(STAR, a * s.y))
	# The flash as the world is erased, and the shockwave rolling out to
	# the dome's edge.
	var since := _age - SIGIL_TIME - BREATH_TIME
	if since >= 0.0:
		var f := clampf(since / 0.25, 0.0, 1.0)
		if f < 1.0:
			_glow.draw_circle(_center, _sigil_size * (1.0 + 3.0 * f), Color(RIM, 0.7 * (1.0 - f)))
		var w := clampf(since / SHOCK_TIME, 0.0, 1.0)
		if w < 1.0:
			var grow := 1.0 - pow(1.0 - w, 2.0)
			var ring := _ellipse(_center, _radii * (0.15 + 0.9 * grow), 48)
			_glow.draw_polyline(ring, Color(RIM, 0.75 * (1.0 - w)), 4.0 * (1.0 - w) + 1.0, true)


# --- lingering pieces, kept in sync by battle.gd ----------------------

## Puts Return to the Void's lingering mark on `node` (a unit's sprite)
## or takes it off: a faint copy of its silhouette filled with void,
## slowly pulsing, and a thin stream of warm life motes leaking out of
## it, cooling to pale blue as they rise. Only does anything when the
## state actually changes (the child's presence is the "on" marker).
static func set_void_mark(node: Variant, active: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	var mark: Control = node.get_node_or_null(VOID_MARK_NAME)
	if active == (mark != null):
		return
	if not active:
		mark.name = VOID_MARK_NAME + "Fading"
		var motes: CPUParticles2D = mark.get_meta("motes", null)
		if is_instance_valid(motes):
			motes.emitting = false
		var fade: Tween = mark.create_tween()
		fade.tween_property(mark, "modulate:a", 0.0, 0.6)
		fade.tween_callback(mark.queue_free)
		return

	mark = Control.new()
	mark.name = VOID_MARK_NAME
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mark.modulate.a = 0.0
	node.add_child(mark)

	var mat := ShaderMaterial.new()
	mat.shader = SILHOUETTE_SHADER
	mat.set_shader_parameter("seed", randf() * 10.0)
	var veil := TextureRect.new()
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.material = mat
	veil.texture = node.texture
	veil.expand_mode = node.expand_mode
	veil.stretch_mode = node.stretch_mode
	veil.flip_h = node.flip_h
	veil.flip_v = node.flip_v
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mark.add_child(veil)
	var pulse: Tween = veil.create_tween().set_loops()
	pulse.tween_property(veil, "modulate:a", 0.32, 1.1).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(veil, "modulate:a", 0.12, 1.1).set_trans(Tween.TRANS_SINE)
	veil.modulate.a = 0.12

	var motes := CPUParticles2D.new()
	motes.position = node.size * Vector2(0.5, 0.55)
	motes.amount = 12
	motes.lifetime = 1.6
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = node.size * Vector2(0.25, 0.3)
	motes.direction = Vector2(0.0, -1.0)
	motes.spread = 20.0
	motes.gravity = Vector2(0.0, -12.0)
	motes.initial_velocity_min = 10.0
	motes.initial_velocity_max = 24.0
	motes.texture = VoidReachFX._dot()
	motes.scale_amount_min = 0.45
	motes.scale_amount_max = 0.8
	motes.material = _additive()
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.15, 0.55, 1.0])
	ramp.colors = PackedColorArray([Color(EMBER, 0.0), EMBER, FROST, Color(RIM, 0.0)])
	motes.color_ramp = ramp
	mark.add_child(motes)
	motes.emitting = true
	mark.set_meta("motes", motes)

	mark.create_tween().tween_property(mark, "modulate:a", 1.0, 0.4)


## Shows (or hides) Return to the Void's execute threshold as a slim bar
## under an enemy's HP label: its current HP in pale ice, the marked
## threshold as a band of void from the left, and a bright notch where
## the threshold is - so how close it is to being claimed reads at a
## glance. `hp_frac`/`threshold` are fractions of its max HP.
static func update_threshold_bar(label: Control, active: bool, hp_frac: float, threshold: float) -> void:
	if not is_instance_valid(label):
		return
	var bar: Control = label.get_node_or_null(THRESHOLD_BAR_NAME)
	if not active:
		if bar != null:
			bar.queue_free()
		return
	if bar == null:
		bar = Control.new()
		bar.name = THRESHOLD_BAR_NAME
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.draw.connect(_draw_threshold_bar.bind(bar))
		label.add_child(bar)
		# The notch pulses, so it's redrawn every frame while shown.
		var pulse: Tween = bar.create_tween().set_loops()
		pulse.tween_callback(bar.queue_redraw).set_delay(0.05)
	var width: float = label.size.x * 0.8
	bar.size = Vector2(width, 5.0)
	bar.position = Vector2((label.size.x - width) * 0.5, label.size.y - 1.0)
	bar.set_meta("hp_frac", clampf(hp_frac, 0.0, 1.0))
	bar.set_meta("threshold", clampf(threshold, 0.0, 1.0))
	bar.queue_redraw()


static func _draw_threshold_bar(bar: Control) -> void:
	var w: float = bar.size.x
	var h: float = bar.size.y
	var hp_frac: float = bar.get_meta("hp_frac", 1.0)
	var threshold: float = bar.get_meta("threshold", 0.0)
	bar.draw_rect(Rect2(-1.0, -1.0, w + 2.0, h + 2.0), Color(0, 0, 0, 0.85))
	bar.draw_rect(Rect2(0.0, 0.0, w * hp_frac, h), Color(0.62, 0.8, 1.0, 0.95))
	# The claimed part: void, with a faint violet shimmer.
	var shimmer := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 250.0)
	bar.draw_rect(Rect2(0.0, 0.0, w * threshold, h), Color(0.12 + 0.1 * shimmer, 0.04, 0.22 + 0.12 * shimmer, 1.0))
	var x := w * threshold
	bar.draw_line(Vector2(x, -2.0), Vector2(x, h + 2.0), Color(0.85, 0.95, 1.0, 0.75 + 0.25 * shimmer), 2.0)


## The death of anyone Return to the Void's threshold claims, played in
## place of the usual dissolve: a small tear opens in the air behind
## them, their silhouette turns to void, and they're pulled into it and
## gone as it seals. The copy joins CreatureAnimator's death-ghost group
## while it plays, so leaving the battle waits for it like any death.
static func claim(node: Variant, layer: Node) -> void:
	if not is_instance_valid(node) or not (node is TextureRect) or not is_instance_valid(layer):
		return
	var center: Vector2 = node.global_position + node.size * 0.5
	var duration := CreatureAnimator.DEATH_DURATION

	var tear_mat := ShaderMaterial.new()
	tear_mat.shader = TEAR_SHADER
	var tear_size: Vector2 = node.size * Vector2(0.7, 1.25)
	tear_mat.set_shader_parameter("aspect", tear_size.x / tear_size.y)
	tear_mat.set_shader_parameter("seed", randf() * 10.0)
	tear_mat.set_shader_parameter("rip", 0.0)
	tear_mat.set_shader_parameter("gape", 0.0)
	var tear := ColorRect.new()
	tear.material = tear_mat
	tear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tear.size = tear_size
	layer.add_child(tear)
	tear.global_position = center - tear_size * 0.5

	var ghost_mat := ShaderMaterial.new()
	ghost_mat.shader = SILHOUETTE_SHADER
	ghost_mat.set_shader_parameter("seed", randf() * 10.0)
	var ghost := TextureRect.new()
	ghost.material = ghost_mat
	ghost.texture = node.texture
	ghost.expand_mode = node.expand_mode
	ghost.stretch_mode = node.stretch_mode
	ghost.flip_h = node.flip_h
	ghost.size = node.size
	ghost.pivot_offset = node.size * 0.5
	ghost.scale = node.get_meta("base_scale", Vector2.ONE)
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.add_to_group(CreatureAnimator.DEATH_GHOST_GROUP)
	layer.add_child(ghost)
	ghost.global_position = node.global_position

	var open := tear.create_tween()
	open.tween_property(tear_mat, "shader_parameter/rip", 1.0, 0.1)
	open.tween_property(tear_mat, "shader_parameter/gape", 1.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	open.tween_interval(duration * 0.45)
	open.tween_property(tear_mat, "shader_parameter/gape", 0.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	open.tween_property(tear_mat, "shader_parameter/rip", 0.0, 0.1)
	open.tween_callback(tear.queue_free)

	# Pulled in: squeezed thin and small toward the tear's heart, a
	# little twist, gone just before it seals.
	var pull := ghost.create_tween()
	pull.tween_interval(0.12)
	pull.tween_property(ghost, "scale", ghost.scale * Vector2(0.08, 0.3), duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	pull.parallel().tween_property(ghost, "rotation", randf_range(-0.5, 0.5), duration * 0.6)
	pull.parallel().tween_property(ghost, "modulate:a", 0.0, duration * 0.6).set_delay(duration * 0.3)
	pull.tween_callback(ghost.queue_free)


static func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m
