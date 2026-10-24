class_name ChoiceBanner
extends CanvasLayer

## A banner that makes the player choose: a dark band across the middle of
## the screen (the StoryBanner's look), a title and one button per option.
## Nothing under it can be clicked, and it can't be skipped - it stays
## until an option is pressed, then fades out and emits `chosen(id)`:
##
##   var banner := ChoiceBanner.play(self, "The choice is yours.", [
##       {"id": "a", "text": "First"}, {"id": "b", "text": "Second"}])
##   var id: String = await banner.chosen

signal chosen(id: String)

const FADE_IN_TIME := 0.3
const FADE_TIME := 0.8

const GOLD := Color(1.0, 0.8, 0.42)
const CREAM := Color(1.0, 0.93, 0.8)

var _title_text: String
var _options: Array
var _root: Control
var _buttons: Array[Button] = []
var _picked := false


static func play(host: Node, title: String, options: Array) -> ChoiceBanner:
	var banner := ChoiceBanner.new()
	banner._title_text = title
	banner._options = options
	banner.layer = 60
	host.add_child(banner)
	return banner


func _ready() -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size

	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# The whole screen: nothing underneath can be pressed while this is up.
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.modulate.a = 0.0
	add_child(_root)

	var dim := ColorRect.new()
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.color = Color(0, 0, 0, 0.55)
	dim.size = view
	_root.add_child(dim)

	var band_gradient := Gradient.new()
	band_gradient.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	band_gradient.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.8), Color(0, 0, 0, 0.8), Color(0, 0, 0, 0)])
	var band_texture := GradientTexture2D.new()
	band_texture.gradient = band_gradient
	band_texture.width = 8
	band_texture.height = 128
	band_texture.fill_to = Vector2(0, 1)
	var band := TextureRect.new()
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.texture = band_texture
	band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	band.size = Vector2(view.x, view.y * 0.5)
	band.position = Vector2(0, view.y * 0.25)
	_root.add_child(band)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 34)
	column.size = Vector2(view.x * 0.8, view.y * 0.5)
	column.position = Vector2(view.x * 0.1, view.y * 0.25)
	_root.add_child(column)

	var title := Label.new()
	title.text = _title_text
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 3)
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_font_size_override("font_size", 36)
	column.add_child(title)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 40)
	column.add_child(row)

	for option in _options:
		var button := _make_button(str(option.get("text", "")))
		button.pressed.connect(_on_picked.bind(str(option.get("id", ""))))
		row.add_child(button)
		_buttons.append(button)

	create_tween().tween_property(_root, "modulate:a", 1.0, FADE_IN_TIME)


## Dark wood and tarnished bronze, like the Map's plaques, with the gold of
## the banner's title lighting up the one under the mouse.
func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(330, 76)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	button.add_theme_constant_override("outline_size", 4)
	button.add_theme_stylebox_override("normal", _plate(Color(0.07, 0.045, 0.035, 0.95), Color(0.55, 0.4, 0.22)))
	button.add_theme_stylebox_override("hover", _plate(Color(0.16, 0.09, 0.05, 0.98), GOLD))
	button.add_theme_stylebox_override("pressed", _plate(Color(0.22, 0.12, 0.06, 1.0), GOLD))
	button.add_theme_stylebox_override("disabled", _plate(Color(0.07, 0.045, 0.035, 0.6), Color(0.4, 0.3, 0.2, 0.6)))
	return button


func _plate(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 8
	return style


## Once pressed the choice is made and can't be taken back: every button is
## switched off and the pick is reported straight away (so it can be saved
## before anything else happens), while the banner fades out.
func _on_picked(id: String) -> void:
	if _picked:
		return
	_picked = true
	for button in _buttons:
		button.disabled = true
	chosen.emit(id)
	var tween := create_tween()
	tween.tween_property(_root, "modulate:a", 0.0, FADE_TIME)
	await tween.finished
	queue_free()
