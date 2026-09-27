class_name SunkenOneFX
extends Control

## Purely cosmetic: Kaelen Varr's ultimate, The Sunken One. The ghost
## ship surfaces from below the waves behind the caster - water pouring
## off it, spray bursting up around its hull - fires a broadside from
## its cannon ports, one after another, the balls arcing out over the
## battlefield in the direction the caster is facing and bursting where
## they land, then sinks back beneath the surface.
##
## The ship goes in this node, which the caller places behind the
## fighters; the cannonballs and their bursts go in `front_host`, over
## them. Damage is the caller's: `on_impact` fires once, when the first
## ball lands, and `on_finished` when the ship has gone back under.

const SHIP_TEXTURE_PATH := "res://assets/heroes skills/Kaelen_Varr_The_Sunken_One.png"

# The ship's cannon ports (fractions of the art, which faces right),
# stern to bow.
const PORTS := [
	Vector2(0.3236, 0.7813), Vector2(0.3776, 0.7666), Vector2(0.4492, 0.7344),
	Vector2(0.5286, 0.6973), Vector2(0.6172, 0.6523),
]
const SHIP_HEIGHT := 0.6             # fraction of the screen height
const WATERLINE_DROP := 0.14         # how far below the ground line its keel sits (fraction of ship height)

const RISE_TIME := 1.1
const PRIME_TIME := 0.35
const SHOT_GAP := 0.13
const SINK_DELAY := 0.5
const SINK_TIME := 0.9

const SPRAY_COLOR := Color(0.75, 0.95, 0.97, 0.75)
const PORT_GLOW := Color(0.45, 1.0, 0.95)
const FLASH_COLOR := Color(0.8, 1.0, 0.98)
const FIRE_COLOR := Color(1.0, 0.62, 0.28)
const SMOKE_COLOR := Color(0.55, 0.7, 0.72, 0.55)

var _front: Control
var _dir := 1.0
var _ground_y := 0.0
var _targets: Array[Vector2] = []
var _on_impact: Callable
var _on_finished: Callable
var _impacted := false
var _landed := 0

var _clip: Control
var _ship: TextureRect
var _port_glows: Array[TextureRect] = []
var _glow_tex: Texture2D


## Plays The Sunken One. `behind_host` gets this node (put it behind the
## fighters); `front_host` gets the cannonballs. `caster_center` and the
## `targets` (where each ball lands, in the order they're fired) are in
## the same coordinates as both hosts' parent.
static func play(behind_host: Control, front_host: Control, caster_center: Vector2, ground_y: float,
		dir: float, targets: Array[Vector2], on_impact: Callable = Callable(), on_finished: Callable = Callable()) -> SunkenOneFX:
	var fx := SunkenOneFX.new()
	fx._front = front_host
	fx._dir = 1.0 if dir >= 0.0 else -1.0
	fx._ground_y = ground_y
	fx._targets = targets
	fx._on_impact = on_impact
	fx._on_finished = on_finished
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	behind_host.add_child(fx)
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx._build(caster_center)
	return fx


func _build(caster_center: Vector2) -> void:
	var view := get_viewport_rect().size
	var tex: Texture2D = load(SHIP_TEXTURE_PATH) if ResourceLoader.exists(SHIP_TEXTURE_PATH) else null
	var h := view.y * SHIP_HEIGHT
	var w := h * (tex.get_size().x / tex.get_size().y if tex else 1.5)

	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0)])
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 64
	gt.height = 64
	_glow_tex = gt

	# Everything below the waterline is clipped away, so the ship rises
	# up out of it.
	var waterline := _ground_y + 10.0
	_clip = Control.new()
	_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clip.clip_contents = true
	_clip.position = Vector2(0.0, waterline - view.y * 1.5)
	_clip.size = Vector2(view.x, view.y * 1.5)
	add_child(_clip)

	_ship = TextureRect.new()
	_ship.texture = tex
	_ship.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ship.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ship.size = Vector2(w, h)
	_ship.flip_h = _dir < 0.0
	_ship.pivot_offset = Vector2(w * 0.5, h)
	# Behind the caster and toward his back, so it towers over him and its
	# guns sit at his side.
	var final_pos := Vector2(caster_center.x - w * 0.5 - _dir * w * 0.3, _ground_y + h * WATERLINE_DROP - h) - _clip.position
	_ship.position = final_pos + Vector2(0.0, h * 1.05)
	_ship.rotation = -_dir * 0.1
	_clip.add_child(_ship)

	for port in PORTS:
		var glow := TextureRect.new()
		glow.texture = _glow_tex
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glow.size = Vector2.ONE * h * 0.09
		glow.position = _port_local(port) - glow.size * 0.5
		glow.pivot_offset = glow.size * 0.5
		glow.self_modulate = PORT_GLOW
		glow.modulate.a = 0.0
		glow.material = _additive()
		_ship.add_child(glow)
		_port_glows.append(glow)

	# Water pouring off the hull as it rises.
	var pour := _particles(SPRAY_COLOR, 0.9, 70)
	pour.position = Vector2(w * 0.5, h * 0.72)
	pour.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	pour.emission_rect_extents = Vector2(w * 0.3, h * 0.08)
	pour.direction = Vector2(0, 1)
	pour.spread = 20.0
	pour.gravity = Vector2(0, 520)
	pour.initial_velocity_min = 10.0
	pour.initial_velocity_max = 60.0
	pour.local_coords = false
	_ship.add_child(pour)
	pour.emitting = true

	# Spray bursting up along the waterline where it breaks the surface.
	var spray := _particles(SPRAY_COLOR, 1.0, 90)
	spray.position = Vector2(caster_center.x - _dir * w * 0.3, waterline)
	spray.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	spray.emission_rect_extents = Vector2(w * 0.42, 4.0)
	spray.direction = Vector2(0, -1)
	spray.spread = 28.0
	spray.gravity = Vector2(0, 380)
	spray.initial_velocity_min = 90.0
	spray.initial_velocity_max = 240.0
	add_child(spray)
	spray.emitting = true

	# Surface, rocking up and settling.
	var rise := create_tween().set_parallel()
	rise.tween_property(_ship, "position", final_pos, RISE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rise.tween_property(_ship, "rotation", _dir * 0.03, RISE_TIME * 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	rise.chain().tween_property(_ship, "rotation", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
	get_tree().create_timer(RISE_TIME * 0.8).timeout.connect(func() -> void:
		if is_instance_valid(spray):
			spray.emitting = false
		if is_instance_valid(pour):
			pour.emitting = false
	)

	# Ports kindle, then fire one after another.
	var prime := create_tween()
	prime.tween_interval(RISE_TIME * 0.85)
	for glow in _port_glows:
		prime.parallel().tween_property(glow, "modulate:a", 0.8, PRIME_TIME)
	for i in PORTS.size():
		get_tree().create_timer(RISE_TIME + PRIME_TIME + SHOT_GAP * i).timeout.connect(_fire.bind(i))


func _port_local(port: Vector2) -> Vector2:
	var fx := (1.0 - port.x) if _ship.flip_h else port.x
	return Vector2(fx, port.y) * _ship.size


## Where a port is, in this node's (and the hosts' parent's) coordinates.
func _port_point(i: int) -> Vector2:
	return _clip.position + _ship.position + _port_local(PORTS[i])


func _fire(i: int) -> void:
	if not is_instance_valid(_ship):
		return
	var muzzle := _port_point(i)

	# Muzzle flash and a puff of gun smoke.
	var glow: TextureRect = _port_glows[i]
	glow.modulate.a = 1.0
	glow.scale = Vector2.ONE * 2.4
	var flash := create_tween().set_parallel()
	flash.tween_property(glow, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	flash.tween_property(glow, "modulate:a", 0.15, 0.4)
	var smoke := _particles(SMOKE_COLOR, 1.1, 14)
	smoke.one_shot = true
	smoke.explosiveness = 0.85
	smoke.position = muzzle
	smoke.direction = Vector2(_dir, -0.25)
	smoke.spread = 30.0
	smoke.gravity = Vector2(0, -25)
	smoke.initial_velocity_min = 30.0
	smoke.initial_velocity_max = 80.0
	smoke.damping_min = 40.0
	smoke.damping_max = 80.0
	add_child(smoke)
	smoke.emitting = true
	smoke.finished.connect(smoke.queue_free)

	# The recoil rocks the ship back a touch.
	var base_x := _ship.position.x
	var recoil := create_tween()
	recoil.tween_property(_ship, "position:x", base_x - _dir * 6.0, 0.05)
	recoil.tween_property(_ship, "position:x", base_x, 0.2).set_trans(Tween.TRANS_SINE)

	var target: Vector2 = _targets[i % _targets.size()] if not _targets.is_empty() else muzzle + Vector2(_dir * 300.0, 0.0)
	_launch_ball(muzzle, target)


func _launch_ball(from: Vector2, to: Vector2) -> void:
	if not is_instance_valid(_front):
		return
	var ball := CannonBall.new()
	_front.add_child(ball)
	ball.global_position = from

	var trail := _particles(SMOKE_COLOR, 0.45, 30)
	trail.local_coords = false
	trail.initial_velocity_min = 4.0
	trail.initial_velocity_max = 16.0
	trail.spread = 180.0
	trail.gravity = Vector2(0, -20)
	ball.add_child(trail)
	trail.emitting = true

	var distance := from.distance_to(to)
	var arc := clampf(distance * 0.18, 20.0, 70.0)
	var duration := clampf(0.18 + distance / 1400.0, 0.25, 0.6)
	var flight := func(p: float) -> void:
		ball.global_position = from.lerp(to, p) + Vector2(0.0, -arc * 4.0 * p * (1.0 - p))
		ball.rotation += 0.35
	var tween := ball.create_tween()
	tween.tween_method(flight, 0.0, 1.0, duration)
	tween.tween_callback(func() -> void:
		trail.emitting = false
		ball.visible = false
		_burst(to)
		_landed += 1
		if not _impacted:
			_impacted = true
			if _on_impact.is_valid():
				_on_impact.call()
		if _landed == PORTS.size():
			get_tree().create_timer(SINK_DELAY).timeout.connect(_sink)
	)
	tween.tween_interval(0.5)
	tween.tween_callback(ball.queue_free)


## Where a ball lands: a flash, spectral fire flying out, and a cloud
## of smoke and spray.
func _burst(at: Vector2) -> void:
	if not is_instance_valid(_front):
		return
	var flash := Sprite2D.new()
	flash.texture = _glow_tex
	flash.material = _additive()
	flash.modulate = FLASH_COLOR
	flash.global_position = at
	flash.scale = Vector2.ONE * 0.4
	_front.add_child(flash)
	flash.global_position = at
	var ft := flash.create_tween().set_parallel()
	ft.tween_property(flash, "scale", Vector2.ONE * 2.2, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	ft.tween_property(flash, "modulate:a", 0.0, 0.3)
	ft.chain().tween_callback(flash.queue_free)

	var fire := CPUParticles2D.new()
	fire.one_shot = true
	fire.explosiveness = 1.0
	fire.amount = 22
	fire.lifetime = 0.45
	fire.spread = 180.0
	fire.gravity = Vector2(0, 260)
	fire.initial_velocity_min = 80.0
	fire.initial_velocity_max = 220.0
	fire.scale_amount_min = 2.0
	fire.scale_amount_max = 4.0
	var ramp := Gradient.new()
	ramp.set_color(0, FIRE_COLOR)
	ramp.set_color(1, Color(PORT_GLOW, 0.0))
	fire.color_ramp = ramp
	fire.material = _additive()
	_front.add_child(fire)
	fire.global_position = at
	fire.emitting = true
	fire.finished.connect(fire.queue_free)

	ProjectileFX._spawn_impact(_front, at, SMOKE_COLOR, true)


func _sink() -> void:
	if not is_instance_valid(_ship):
		return
	for glow in _port_glows:
		var gt := glow.create_tween()
		gt.tween_property(glow, "modulate:a", 0.0, 0.3)
	var sink := create_tween().set_parallel()
	sink.tween_property(_ship, "position:y", _ship.position.y + _ship.size.y * 1.05, SINK_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	sink.tween_property(_ship, "rotation", _dir * 0.08, SINK_TIME).set_trans(Tween.TRANS_SINE)
	sink.chain().tween_callback(func() -> void:
		if _on_finished.is_valid():
			_on_finished.call()
		queue_free()
	)
	# A last swell of spray as it goes under.
	var spray := _particles(SPRAY_COLOR, 0.8, 50)
	spray.position = Vector2(_clip.position.x + _ship.position.x + _ship.size.x * 0.5, _ground_y + 10.0)
	spray.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	spray.emission_rect_extents = Vector2(_ship.size.x * 0.35, 4.0)
	spray.direction = Vector2(0, -1)
	spray.spread = 30.0
	spray.gravity = Vector2(0, 380)
	spray.initial_velocity_min = 50.0
	spray.initial_velocity_max = 140.0
	add_child(spray)
	spray.emitting = true
	get_tree().create_timer(SINK_TIME * 0.6).timeout.connect(func() -> void:
		if is_instance_valid(spray):
			spray.emitting = false
	)


# --- helpers --------------------------------------------------------

func _particles(color: Color, lifetime: float, amount: int) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.emitting = false
	ProjectileFX._make_misty(p, color, lifetime)
	return p


static func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


## A spectral iron cannonball: dark, with a pale teal rim and a glow.
class CannonBall:
	extends Node2D

	func _draw() -> void:
		draw_circle(Vector2.ZERO, 16.0, Color(0.3, 1.0, 0.92, 0.18))
		draw_circle(Vector2.ZERO, 10.0, Color(0.3, 1.0, 0.92, 0.3))
		draw_circle(Vector2.ZERO, 7.0, Color(0.1, 0.13, 0.15))
		draw_arc(Vector2.ZERO, 7.0, -2.4, -0.6, 10, Color(0.7, 1.0, 0.97, 0.9), 2.0)
		draw_circle(Vector2(-2.2, -2.4), 1.8, Color(0.85, 1.0, 1.0, 0.8))
