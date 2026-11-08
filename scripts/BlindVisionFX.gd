class_name BlindVisionFX
extends Control
## What a blinded hero sees (see TERRAIN_DESIGN.md, The Scorchlands): only an
## elliptical window around them - everything outside it, above and below
## included, is lost in a soft, slowly shifting shadow. Drawn over the
## fighters but under the battle UI. Purely cosmetic: which targets are
## actually usable is decided in battle.gd (_is_target_blinded()).

const SHADER := preload("res://shaders/blind_vision.gdshader")

var _rect: ColorRect
var _material: ShaderMaterial
var _time: float = 0.0
# Where the window is drawn right now, and where it is heading.
var _center: Vector2 = Vector2.ZERO
var _radius: Vector2 = Vector2.ONE
var _target_center: Vector2 = Vector2.ZERO
var _placed: bool = false


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
	create_tween().tween_property(self, "modulate:a", 1.0, 0.35)


## `center` and `radius` (semi-axes) of the clear ellipse, in screen pixels.
## The first call snaps the window there; later ones glide it along as the
## hero walks.
func set_window(center: Vector2, radius: Vector2) -> void:
	_target_center = center
	_radius = radius
	if not _placed:
		_center = center
		_placed = true
	_apply()


func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_time += delta
	_center = _center.lerp(_target_center, minf(1.0, delta * 12.0))
	_apply()


func _apply() -> void:
	if _material == null:
		return
	_material.set_shader_parameter("center", _center)
	_material.set_shader_parameter("radius", _radius)
	_material.set_shader_parameter("time", _time)
