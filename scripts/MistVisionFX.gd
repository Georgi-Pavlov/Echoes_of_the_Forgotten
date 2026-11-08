class_name MistVisionFX
extends Control
## What a hero sees around the Kingdom of Morvain's mist wall (see
## TERRAIN_DESIGN.md): drawn over the fighters but under the battle UI by
## shaders/mist_vision.gdshader. Purely cosmetic - which targets are usable
## is decided in battle.gd (_vision_between()). battle.gd feeds it x ranges
## in screen pixels; they glide to new values as the hero moves.

const SHADER := preload("res://shaders/mist_vision.gdshader")
## Where a range sits when it is unused: well off screen.
const OFF := Vector2(-5000.0, -4000.0)

var _rect: ColorRect
var _material: ShaderMaterial
var _time: float = 0.0
var _placed: bool = false
# Current shader values and the ones they are heading for.
var _now: Dictionary = {}
var _goal: Dictionary = {}


func setup(view_size: Vector2) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = view_size
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("view_size", view_size)
	_rect = ColorRect.new()
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.material = _material
	_rect.size = view_size
	add_child(_rect)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.45)


## Outside the wall: sharp sight on the hero's side (`clear_range`), fog over
## the wall and the column behind it (`fog_range`), shadow beyond.
func set_outside(clear_range: Vector2, fog_range: Vector2) -> void:
	_set_goal({
		"clear_range": clear_range, "fog_a": fog_range, "fog_b": OFF,
		"region_shadow": 1.0, "ellipse_on": 0.0,
	})


## Inside the wall: only the hero's own column is sharp (`own_range`), the
## columns beside it are fogged, and an ellipse around `center` (semi-axes
## `radius`) hides the rest in shadow.
func set_inside(own_range: Vector2, fog_left: Vector2, fog_right: Vector2, center: Vector2, radius: Vector2) -> void:
	_set_goal({
		"clear_range": own_range, "fog_a": fog_left, "fog_b": fog_right,
		"region_shadow": 0.0, "ellipse_on": 1.0, "center": center, "radius": radius,
	})


func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(queue_free)


func _set_goal(values: Dictionary) -> void:
	for key in values:
		_goal[key] = values[key]
	if not _placed:
		_now = _goal.duplicate()
		_placed = true
	for key in _goal:
		if not _now.has(key):
			_now[key] = _goal[key]
	_apply()


func _process(delta: float) -> void:
	_time += delta
	var k: float = minf(1.0, delta * 10.0)
	for key in _goal:
		var cur = _now[key]
		var goal = _goal[key]
		if cur is Vector2:
			# A range that is switching on or off snaps rather than sweeping
			# across the screen.
			if absf(cur.x) > 3000.0 or absf(goal.x) > 3000.0:
				_now[key] = goal
			else:
				_now[key] = cur.lerp(goal, k)
		else:
			_now[key] = lerpf(cur, goal, k)
	_apply()


func _apply() -> void:
	if _material == null:
		return
	for key in _now:
		_material.set_shader_parameter(key, _now[key])
	_material.set_shader_parameter("time", _time)
