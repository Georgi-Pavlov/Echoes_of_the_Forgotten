class_name ArrowRainFX
extends RefCounted

## Purely cosmetic: Solara's Fallen Grace. She looses a volley of arrows
## straight up out of the screen from the tip of her bow, one after another
## - golden-headed shafts streaking skyward, trailing amber motes
## - and after a held breath they come back down: each arrow reappears high
## above its target and plunges straight down onto it, bursting in gold
## sparks. Several arrows fall on each target, in a rolling scatter, one
## target after another.
##
## Arrows are ProjectileFX's own "grace_arrow" style, so their look lives
## there (colors, length, how many fall on each target - "count").

const UP_TIME := Vector2(0.4, 0.5)    # seconds an arrow takes to leave the screen
const LAUNCH_GAP := 0.045             # between one arrow leaving and the next
const HOLD := 0.18                    # the pause before the first one falls
const FALL_TIME := Vector2(0.26, 0.34)
const GROUP_GAP := 0.1                # between one target's rain and the next's
const ARROW_GAP := 0.055              # between arrows falling on the same target


## `shots`: one Dictionary per target - {"land": Vector2 (global), "on_hit":
## Callable (fired as that target's first arrow lands)}. `from` is the bow
## tip (global); `facing` (+1 or -1, the way she faces) is unused now that
## the arrows fly straight up and straight down.
static func play(host: Node, from: Vector2, shots: Array, facing: float) -> void:
	var style := ProjectileFX._style("grace_arrow")
	var per_target: int = maxi(int(style["count"]), 1)
	var total: int = shots.size() * per_target
	if total <= 0:
		return

	var launch_end := LAUNCH_GAP * float(total) + UP_TIME.y
	var fall_base := launch_end + HOLD
	var k := 0
	for g in shots.size():
		var shot: Dictionary = shots[g]
		var land: Vector2 = shot["land"]
		for i in per_target:
			var aim := land
			if i > 0:
				aim += Vector2(randf_range(-38.0, 38.0), randf_range(-26.0, 26.0))
			var on_hit: Callable = shot["on_hit"] if i == 0 else Callable()
			_one_arrow(host, style, from, aim, facing, float(k) * LAUNCH_GAP,
				fall_base + float(g) * GROUP_GAP + float(i) * ARROW_GAP, on_hit)
			k += 1


static func _one_arrow(host: Node, style: Dictionary, from: Vector2, land: Vector2, facing: float,
		launch_delay: float, fall_delay: float, on_hit: Callable) -> void:
	var arrow: Node2D = ProjectileFX._build_arrow(style)
	host.add_child(arrow)
	arrow.global_position = from
	arrow.visible = false

	# A trail of motes shed from the tail, in world space.
	var trail := CPUParticles2D.new()
	trail.local_coords = false
	trail.position = Vector2(-float(style["length"]), 0.0)
	trail.amount = 28
	trail.lifetime = 0.3
	trail.spread = 18.0
	trail.direction = Vector2(-1, 0)
	trail.initial_velocity_min = 8.0
	trail.initial_velocity_max = 30.0
	trail.scale_amount_min = 1.2
	trail.scale_amount_max = 2.6
	trail.color = style["trail_color"]
	trail.emitting = false
	arrow.add_child(trail)

	# Up: straight out of the top of the screen.
	var view_top: float = -140.0
	var apex := Vector2(from.x + randf_range(-14.0, 14.0), view_top)
	var up_time: float = randf_range(UP_TIME.x, UP_TIME.y)
	var up_flight := func(p: float) -> void:
		var e: float = 1.0 - pow(1.0 - p, 2.2)               # leaves fast, slows near the top
		var pos: Vector2 = from.lerp(apex, e)
		arrow.global_position = pos
		arrow.rotation = -PI * 0.5                            # straight up

	# Down: straight down from above the target, plunging onto it.
	var drop_start := Vector2(land.x, view_top)
	var fall_time: float = randf_range(FALL_TIME.x, FALL_TIME.y)
	var down_flight := func(p: float) -> void:
		var e: float = p * p                                   # accelerating
		arrow.global_position = drop_start.lerp(land, e)
		arrow.rotation = PI * 0.5                             # straight down

	var tween := arrow.create_tween()
	tween.tween_interval(launch_delay)
	tween.tween_callback(func() -> void:
		arrow.visible = true
		trail.emitting = true
		up_flight.call(0.0))
	tween.tween_method(up_flight, 0.0, 1.0, up_time)
	tween.tween_callback(func() -> void:
		arrow.visible = false
		trail.emitting = false)
	tween.tween_interval(maxf(fall_delay - launch_delay - up_time, 0.0))
	tween.tween_callback(func() -> void:
		down_flight.call(0.0)
		arrow.visible = true
		trail.emitting = true)
	tween.tween_method(down_flight, 0.0, 1.0, fall_time)
	tween.tween_callback(func() -> void:
		trail.emitting = false
		ProjectileFX._spawn_impact(host, land, style["impact_color"], false)
		if on_hit.is_valid():
			on_hit.call())
	tween.tween_property(arrow, "modulate:a", 0.0, 0.1)
	tween.tween_callback(arrow.queue_free)
