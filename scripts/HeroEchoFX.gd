class_name HeroEchoFX
extends Node2D

## Purely cosmetic: a fallen rival hero's Echo.
##
##   1. Spawn: a small tear in reality rips open where they died - golden
##      light pouring out of it, golden cracks splintering out around it
##      like broken glass, a glimpse of the past swirling behind it.
##      Motes of gold drift up from it while it waits.
##   2. Collect: the tear blazes up, then breaks apart into shards of
##      golden light that stream through the air into the hero, wrapping
##      him in a golden aura - light rising up his figure, a ring at his
##      feet, motes swirling round him - before it all settles.
##
## The tear itself is echo_tear.gdshader on its own rect; the shards and
## the aura are drawn by this node. battle.gd owns when it's collected
## (spawn() / collect()) - this only shows it.

const OPEN_DELAY := 0.25
const OPEN_TIME := 0.6
const FLARE_TIME := 0.3
const BREAK_TIME := 0.25
const FLOW_TIME := 0.9
const AURA_TIME := 1.3
const SHARDS := 22

const TEAR_SHADER := preload("res://shaders/echo_tear.gdshader")

const GOLD := Color(1.0, 0.76, 0.28)
const LIGHT := Color(1.0, 0.95, 0.78)
const AMBER := Color(0.95, 0.55, 0.15)

var _center: Vector2
var _tear_size: Vector2
var _tear: ColorRect
var _mat: ShaderMaterial
var _motes: CPUParticles2D
var _glow: Node2D
var _age := -OPEN_DELAY

var _collecting := false
var _collect_age := 0.0
var _hero: CanvasItem
var _hero_rect: Rect2
var _shards: Array = []
var _aura_started := false
var _on_collected: Callable
var _done := false


## Opens an Echo centred on `center` (global px), its tear `height` px
## long, on `layer`. Starts a beat late, so it rips open out of the
## fallen hero's own death dissolve rather than over it.
static func spawn(layer: Node, center: Vector2, height: float) -> HeroEchoFX:
	var fx := HeroEchoFX.new()
	fx._center = center
	# The rect is the tear plus room round it for the cracks and glow -
	# the tear runs 0.42 of its height (echo_tear's tear_half_len).
	fx._tear_size = Vector2.ONE * height / 0.42
	layer.add_child(fx)
	fx.global_position = Vector2.ZERO
	return fx


func _ready() -> void:
	_mat = ShaderMaterial.new()
	_mat.shader = TEAR_SHADER
	_mat.set_shader_parameter("aspect", _tear_size.x / _tear_size.y)
	_mat.set_shader_parameter("seed", randf() * 10.0)
	_mat.set_shader_parameter("rip", 0.0)
	_mat.set_shader_parameter("gape", 0.0)
	_mat.set_shader_parameter("crack", 0.0)
	_mat.set_shader_parameter("flare", 0.0)
	_tear = ColorRect.new()
	_tear.material = _mat
	_tear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tear.size = _tear_size
	_tear.position = _center - _tear_size * 0.5
	add_child(_tear)

	_motes = _gold_motes(_center, _tear_size * Vector2(0.07, 0.18), 14, 1.8)
	add_child(_motes)

	_glow = Node2D.new()
	_glow.material = _additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)

	var open := create_tween()
	open.tween_interval(OPEN_DELAY)
	open.tween_callback(func(): _motes.emitting = true)
	open.tween_property(_mat, "shader_parameter/rip", 1.0, OPEN_TIME * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	open.tween_property(_mat, "shader_parameter/gape", 1.0, OPEN_TIME * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var spread := create_tween()
	spread.tween_interval(OPEN_DELAY + OPEN_TIME * 0.2)
	spread.tween_property(_mat, "shader_parameter/crack", 1.0, OPEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Breaks the Echo apart and flows it into `hero` (his sprite), wrapping
## him in golden light; `on_collected` fires once it has all settled.
## If the Echo has only just appeared, it finishes opening first, so it's
## always seen before it's taken.
func collect(hero: Control, on_collected: Callable) -> void:
	if _collecting:
		return
	_collecting = true
	_hero = hero
	_hero_rect = hero.get_global_rect()
	_on_collected = on_collected
	_collect_age = minf(0.0, _age - OPEN_TIME - 0.3)

	var target := _hero_rect.get_center()
	for i in SHARDS:
		var start := _center + Vector2(randf_range(-0.05, 0.05) * _tear_size.x, randf_range(-0.2, 0.2) * _tear_size.y)
		var out := (start - _center).normalized()
		if out == Vector2.ZERO:
			out = Vector2.from_angle(randf() * TAU)
		var size := randf_range(3.0, 8.0)
		var poly := PackedVector2Array()
		for k in 3 + randi() % 2:
			poly.append(Vector2.from_angle(TAU * k / 3.5 + randf_range(-0.4, 0.4)) * size * randf_range(0.6, 1.3))
		_shards.append({
			"p0": start,
			"p1": start + out * randf_range(50.0, 120.0) + Vector2(0.0, -randf_range(30.0, 80.0)),
			"p2": target + Vector2(randf_range(-0.25, 0.25) * _hero_rect.size.x, randf_range(-0.3, 0.3) * _hero_rect.size.y),
			"delay": FLARE_TIME + randf() * BREAK_TIME,
			"dur": FLOW_TIME * randf_range(0.7, 1.0),
			"poly": poly,
			"spin": randf_range(-8.0, 8.0),
		})

	var wait: float = -_collect_age
	var blaze := create_tween()
	blaze.tween_interval(wait)
	blaze.tween_property(_mat, "shader_parameter/flare", 1.0, FLARE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	blaze.parallel().tween_property(_mat, "shader_parameter/crack", 1.25, FLARE_TIME)
	blaze.tween_callback(func(): _motes.emitting = false)
	blaze.tween_property(_mat, "shader_parameter/gape", 0.0, BREAK_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	blaze.parallel().tween_property(_tear, "modulate:a", 0.0, BREAK_TIME)


func _process(delta: float) -> void:
	_age += delta
	if _collecting:
		_collect_age += delta
		var aura_start := FLARE_TIME + BREAK_TIME + FLOW_TIME * 0.55
		if not _aura_started and _collect_age >= aura_start:
			_aura_started = true
			_start_aura()
		if not _done and _collect_age >= aura_start + AURA_TIME:
			_done = true
			if _on_collected.is_valid():
				_on_collected.call()
			queue_free()
			return
	_glow.queue_redraw()


## The hero lighting up as the Echo pours into him: his own art warmed
## to gold and back, and motes of gold swirling up around him.
func _start_aura() -> void:
	if is_instance_valid(_hero):
		var warm := _hero.create_tween()
		warm.tween_property(_hero, "self_modulate", Color(1.5, 1.3, 0.85), 0.3)
		warm.tween_interval(AURA_TIME * 0.35)
		warm.tween_property(_hero, "self_modulate", Color.WHITE, AURA_TIME * 0.5)
	var motes := _gold_motes(_hero_rect.get_center(), _hero_rect.size * Vector2(0.35, 0.4), 40, 1.2)
	motes.one_shot = true
	motes.explosiveness = 0.35
	motes.initial_velocity_min = 20.0
	motes.initial_velocity_max = 50.0
	motes.tangential_accel_min = -30.0
	motes.tangential_accel_max = 30.0
	add_child(motes)
	motes.emitting = true


# --- the flash, the shards and the aura ------------------------------

func _bezier(s: Dictionary, t: float) -> Vector2:
	var u := 1.0 - t
	return s["p0"] * u * u + s["p1"] * 2.0 * u * t + s["p2"] * t * t


func _ellipse(center: Vector2, radii: Vector2, points: int = 32) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in points + 1:
		var a := TAU * i / points
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	return pts


func _draw_glow() -> void:
	# The flash as the tear rips open.
	if _age >= 0.0 and _age < 0.45:
		var f := _age / 0.45
		_glow.draw_circle(_center, _tear_size.x * 0.08 * (1.0 + 2.5 * f), Color(LIGHT, 0.55 * (1.0 - f)))
	if not _collecting:
		return

	# The flash as it breaks apart.
	var since_break := _collect_age - FLARE_TIME
	if since_break >= 0.0 and since_break < 0.35:
		var f := since_break / 0.35
		_glow.draw_circle(_center, _tear_size.x * 0.1 * (1.0 + 3.0 * f), Color(LIGHT, 0.7 * (1.0 - f)))
		_glow.draw_polyline(_ellipse(_center, Vector2.ONE * _tear_size.x * (0.14 + 0.4 * f)), Color(GOLD, 0.8 * (1.0 - f)), 2.5, true)

	# The shards, streaming into the hero, each trailing light.
	for s in _shards:
		var t := clampf((_collect_age - float(s["delay"])) / float(s["dur"]), 0.0, 1.0)
		if t <= 0.0 or t >= 1.0:
			continue
		var eased := t * t * (3.0 - 2.0 * t)
		var pos := _bezier(s, eased)
		var a := minf(1.0, (1.0 - t) * 4.0)
		var tail := _bezier(s, maxf(0.0, eased - 0.25))
		_glow.draw_line(tail, pos, Color(GOLD, 0.7 * a), 2.5, true)
		var rot := Vector2.from_angle(float(s["spin"]) * t)
		var pts := PackedVector2Array()
		for v in s["poly"]:
			pts.append(pos + Vector2(v.x * rot.x - v.y * rot.y, v.x * rot.y + v.y * rot.x))
		_glow.draw_colored_polygon(pts, Color(LIGHT, 0.9 * a))
		_glow.draw_circle(pos, 5.0, Color(LIGHT, 0.3 * a))

	# The aura: a glow wrapping the hero, light rising up his figure, a
	# ring of gold spreading at his feet.
	var aura_t := (_collect_age - FLARE_TIME - BREAK_TIME - FLOW_TIME * 0.55) / AURA_TIME
	if aura_t <= 0.0 or aura_t >= 1.0:
		return
	var swell := sin(aura_t * PI)
	var c := _hero_rect.get_center()
	var radii := _hero_rect.size * Vector2(0.42, 0.55)
	for k in 4:
		_glow.draw_colored_polygon(_ellipse(c, radii * (0.8 + 0.18 * k)), Color(AMBER if k == 3 else GOLD, 0.07 * swell))
	var feet := Vector2(c.x, _hero_rect.end.y - _hero_rect.size.y * 0.05)
	var rise := 1.0 - pow(1.0 - aura_t, 2.0)
	var ring_y := feet.y - _hero_rect.size.y * 0.9 * rise
	_glow.draw_polyline(_ellipse(Vector2(c.x, ring_y), Vector2(radii.x * 1.05, radii.x * 0.22)), Color(LIGHT, 0.85 * (1.0 - aura_t)), 2.5, true)
	_glow.draw_polyline(_ellipse(feet, Vector2(radii.x * (0.6 + 1.1 * aura_t), radii.x * (0.15 + 0.25 * aura_t))), Color(GOLD, 0.75 * (1.0 - aura_t)), 3.0, true)


# --- helpers ----------------------------------------------------------

## Golden motes drifting upward from a box `extents` round `center` -
## not emitting until the caller says so.
func _gold_motes(center: Vector2, extents: Vector2, amount: int, lifetime: float) -> CPUParticles2D:
	var motes := CPUParticles2D.new()
	motes.position = center
	motes.emitting = false
	motes.amount = amount
	motes.lifetime = lifetime
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = extents
	motes.direction = Vector2(0.0, -1.0)
	motes.spread = 25.0
	motes.gravity = Vector2(0.0, -14.0)
	motes.initial_velocity_min = 8.0
	motes.initial_velocity_max = 22.0
	motes.texture = VoidReachFX._dot()
	motes.scale_amount_min = 0.4
	motes.scale_amount_max = 0.85
	motes.material = _additive()
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.6, 1.0])
	ramp.colors = PackedColorArray([Color(LIGHT, 0.0), LIGHT, GOLD, Color(AMBER, 0.0)])
	motes.color_ramp = ramp
	return motes


static func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m
