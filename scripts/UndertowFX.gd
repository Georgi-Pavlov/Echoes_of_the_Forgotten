class_name UndertowFX
extends RefCounted

## Purely cosmetic: Kaelen Varr's Undertow jump. The creature sinks
## straight down into a splash of water where it stood, then surfaces
## out of a fresh splash where it lands.
##
## battle.gd moves the node itself instantly, as before - this only
## draws the trip: the real node is hidden while two copies of it (one
## sinking at the old spot, one rising at the new) are clipped at the
## ground line, so they seem to go under the surface and come back up.

const SINK_TIME := 0.42
const UNDER_TIME := 0.18
const RISE_TIME := 0.48
const WATER := Color(0.7, 0.92, 0.97, 0.8)
const DEEP := Color(0.35, 0.75, 0.85, 0.7)


## `node` has already been moved to `to_pos`; `from_pos` is where it was
## (both in its parent's coordinates). `ground_y` is the ground line in
## that same space; `front` gets the splashes (drawn over the fighters).
static func play(node: TextureRect, from_pos: Vector2, to_pos: Vector2, ground_y: float, front: Control) -> void:
	var parent := node.get_parent() as Control
	if parent == null:
		return
	node.visible = false

	var sinker := _copy_in_clip(node, parent, from_pos, ground_y)
	_splash(front, parent, Vector2(from_pos.x + node.size.x * 0.5, ground_y), node.size.x, false)
	var sink_img: TextureRect = sinker.get_child(0)
	var sink := sink_img.create_tween()
	sink.tween_property(sink_img, "position:y", sink_img.position.y + node.size.y * 1.05, SINK_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	sink.parallel().tween_property(sink_img, "rotation", 0.08 if node.flip_h else -0.08, SINK_TIME)
	sink.tween_callback(sinker.queue_free)

	var riser := _copy_in_clip(node, parent, to_pos, ground_y)
	var rise_img: TextureRect = riser.get_child(0)
	var up_y := rise_img.position.y
	rise_img.position.y += node.size.y * 1.05
	var rise := rise_img.create_tween()
	rise.tween_interval(SINK_TIME + UNDER_TIME)
	rise.tween_callback(func() -> void:
		_splash(front, parent, Vector2(to_pos.x + node.size.x * 0.5, ground_y), node.size.x, true)
	)
	rise.tween_property(rise_img, "position:y", up_y - 10.0, RISE_TIME * 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rise.tween_property(rise_img, "position:y", up_y, RISE_TIME * 0.2).set_trans(Tween.TRANS_SINE)
	rise.tween_callback(func() -> void:
		if is_instance_valid(node):
			node.visible = true
		riser.queue_free()
	)


## A copy of `node` at `pos`, inside a control that clips everything
## below the ground line.
static func _copy_in_clip(node: TextureRect, parent: Control, pos: Vector2, ground_y: float) -> Control:
	var clip := Control.new()
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.clip_contents = true
	var top := minf(pos.y, ground_y) - node.size.y
	clip.position = Vector2(pos.x - node.size.x * 0.3, top)
	clip.size = Vector2(node.size.x * 1.6, ground_y + 6.0 - top)
	parent.add_child(clip)
	parent.move_child(clip, node.get_index() + 1)

	var img := TextureRect.new()
	img.texture = node.texture
	img.expand_mode = node.expand_mode
	img.stretch_mode = node.stretch_mode
	img.flip_h = node.flip_h
	img.size = node.size
	img.pivot_offset = Vector2(node.size.x * 0.5, node.size.y)
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	img.position = pos - clip.position
	clip.add_child(img)
	return clip


## A burst of water at `at` (in `space`'s coordinates): a spout of spray,
## droplets flying out and falling, and a ring of foam spreading on the
## surface. A surfacing splash is taller than a sinking one.
static func _splash(front: Control, space: Control, at: Vector2, width: float, surfacing: bool) -> void:
	if not is_instance_valid(front):
		return
	var global_at := space.get_global_transform() * at

	var spout := CPUParticles2D.new()
	spout.one_shot = true
	spout.explosiveness = 0.75
	spout.amount = 90 if surfacing else 70
	spout.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	spout.emission_rect_extents = Vector2(width * 0.34, 4.0)
	spout.direction = Vector2(0, -1)
	spout.spread = 22.0
	spout.gravity = Vector2(0, 520)
	spout.initial_velocity_min = 220.0 if surfacing else 160.0
	spout.initial_velocity_max = 480.0 if surfacing else 360.0
	ProjectileFX._make_misty(spout, WATER, 0.9)
	spout.scale_amount_min = 1.6
	spout.scale_amount_max = 3.0
	front.add_child(spout)
	spout.global_position = global_at
	spout.emitting = true
	spout.finished.connect(spout.queue_free)

	var drops := CPUParticles2D.new()
	drops.one_shot = true
	drops.explosiveness = 0.9
	drops.amount = 44
	drops.spread = 70.0
	drops.direction = Vector2(0, -1)
	drops.gravity = Vector2(0, 700)
	drops.initial_velocity_min = 180.0
	drops.initial_velocity_max = 420.0
	drops.scale_amount_min = 3.0
	drops.scale_amount_max = 5.5
	drops.color = WATER
	front.add_child(drops)
	drops.global_position = global_at
	drops.emitting = true
	drops.finished.connect(drops.queue_free)

	# Foam ring spreading on the surface.
	var ring := Line2D.new()
	ring.width = 4.0
	ring.default_color = DEEP
	front.add_child(ring)
	ring.global_position = global_at
	var grow := func(r: float) -> void:
		var pts := PackedVector2Array()
		for i in 33:
			var a := TAU * i / 32.0
			pts.append(Vector2(cos(a), sin(a) * 0.22) * r)
		ring.points = pts
	grow.call(width * 0.2)
	var rt := ring.create_tween().set_parallel()
	rt.tween_method(grow, width * 0.25, width * 0.95, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rt.tween_property(ring, "modulate:a", 0.0, 0.7)
	rt.chain().tween_callback(ring.queue_free)
