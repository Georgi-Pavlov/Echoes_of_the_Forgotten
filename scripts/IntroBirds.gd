class_name IntroBirds
extends Control

## Small flocks of birds flying left to right across a band of an intro
## scene's sky, wings beating. Add it to a scene's effects layer and set
## the band (fractions of the screen height) before it enters the tree.

const SIZE := Vector2(1280, 720)

var sky_top := 0.05
var sky_bottom := 0.3
var color := Color(0.22, 0.22, 0.26, 0.85)
var speed_min := 55.0
var speed_max := 85.0
var flock_gap_min := 3.0
var flock_gap_max := 6.0
## Wing span range, in screen pixels (half of it each side of the body).
var size_min := 4.0
var size_max := 7.0

## Per bird: {pos, speed, size, flap_rate, flap_phase, wobble_phase}.
var _birds: Array = []
var _next_flock := 0.0
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	_rng.randomize()
	# The sky shouldn't start empty: a couple of flocks already on their way.
	_spawn_flock(_rng.randf_range(0.1, 0.4) * SIZE.x)
	_spawn_flock(_rng.randf_range(0.5, 0.8) * SIZE.x)
	_next_flock = _rng.randf_range(flock_gap_min, flock_gap_max)


func _process(delta: float) -> void:
	_time += delta
	if _time >= _next_flock:
		_spawn_flock(-20.0)
		_next_flock = _time + _rng.randf_range(flock_gap_min, flock_gap_max)
	for bird in _birds:
		bird["pos"] += Vector2(bird["speed"] * delta, 0.0)
	_birds = _birds.filter(func(b): return b["pos"].x < SIZE.x + 40.0)
	queue_redraw()


## A loose flock of 3-6 birds, leader in front, the rest trailing behind
## and around it, all flying at the leader's speed (give or take).
func _spawn_flock(x: float) -> void:
	var lead := Vector2(x, _rng.randf_range(sky_top, sky_bottom) * SIZE.y)
	var speed := _rng.randf_range(speed_min, speed_max)
	for i in _rng.randi_range(3, 6):
		var offset := Vector2.ZERO if i == 0 else Vector2(-_rng.randf_range(10, 45), _rng.randf_range(-18, 18))
		_birds.append({
			"pos": lead + offset,
			"speed": speed * _rng.randf_range(0.95, 1.05),
			"size": _rng.randf_range(size_min, size_max),
			"flap_rate": _rng.randf_range(7.0, 10.0),
			"flap_phase": _rng.randf() * TAU,
			"wobble_phase": _rng.randf() * TAU,
		})


## Each bird is a little "M": two wings beating up and down around its
## body, gliding with a gentle rise and fall.
func _draw() -> void:
	for bird in _birds:
		var size: float = bird["size"]
		var flap := sin(_time * bird["flap_rate"] + bird["flap_phase"])
		var pos: Vector2 = bird["pos"] + Vector2(0, sin(_time * 1.3 + bird["wobble_phase"]) * 2.0)
		var tip_y := -flap * size * 0.7
		var elbow_y := -flap * size * 0.25 - size * 0.15
		draw_polyline(PackedVector2Array([
			pos + Vector2(-size, tip_y),
			pos + Vector2(-size * 0.45, elbow_y),
			pos,
			pos + Vector2(size * 0.45, elbow_y),
			pos + Vector2(size, tip_y),
		]), color, 1.4, true)
