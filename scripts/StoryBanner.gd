class_name StoryBanner
extends CanvasLayer

## A moment of story laid over the screen, in the Intro's caption style -
## nothing to click, it reads itself in, stays just long enough to be
## read and fades away, then emits `finished`:
##
##   1. The screen dims and a dark band settles across its middle, a few
##      motes of gold drifting up through it.
##   2. The title fades in, in gold; a thin golden rule draws out from
##      its centre beneath it.
##   3. The body types itself in, in the Intro's warm cream.
##   4. A hold scaled to the text's length (the Intro's own reading
##      pace), then everything fades out together.

signal finished

const DIM_TIME := 0.7
const TITLE_FADE_TIME := 1.0
const RULE_TIME := 0.7
const FADE_OUT_TIME := 1.0
# Same typing speed and reading time as the Intro's captions (see
# Intro.gd).
const SECONDS_PER_CHAR := 0.035
const HOLD_BASE_TIME := 2.5
const HOLD_PER_CHAR := 0.04

const GOLD := Color(1.0, 0.8, 0.42)
const CREAM := Color(1.0, 0.93, 0.8)

var _title_text: String
var _body_text: String
var _root: Control
var _title: Label
var _rule: Control
var _rule_t := 0.0
var _body: Label


## Shows `title` over `body` on top of everything in `host`'s scene.
## Await the returned banner's `finished` to know when it's gone.
static func play(host: Node, title: String, body: String) -> StoryBanner:
	var banner := StoryBanner.new()
	banner._title_text = title
	banner._body_text = body
	banner.layer = 50
	host.add_child(banner)
	return banner


func _ready() -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size

	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.size = view
	_root.modulate.a = 0.0
	add_child(_root)

	var dim := ColorRect.new()
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.color = Color(0, 0, 0, 0.3)
	dim.size = view
	_root.add_child(dim)

	var band_gradient := Gradient.new()
	band_gradient.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	band_gradient.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.75), Color(0, 0, 0, 0.75), Color(0, 0, 0, 0)])
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

	var motes := CPUParticles2D.new()
	motes.position = view * 0.5
	motes.amount = 24
	motes.lifetime = 3.0
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(view.x * 0.35, view.y * 0.1)
	motes.direction = Vector2(0, -1)
	motes.spread = 20.0
	motes.gravity = Vector2(0, -6)
	motes.initial_velocity_min = 6.0
	motes.initial_velocity_max = 16.0
	motes.texture = VoidReachFX._dot()
	motes.scale_amount_min = 0.35
	motes.scale_amount_max = 0.7
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	motes.material = additive
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(GOLD, 0.0), Color(CREAM, 0.8), Color(GOLD, 0.5), Color(GOLD, 0.0)])
	motes.color_ramp = ramp
	_root.add_child(motes)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 14)
	column.size = Vector2(view.x * 0.72, view.y * 0.5)
	column.position = Vector2(view.x * 0.14, view.y * 0.25)
	_root.add_child(column)

	_title = _story_label(_title_text, GOLD, 36)
	_title.modulate.a = 0.0
	column.add_child(_title)

	_rule = Control.new()
	_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rule.custom_minimum_size = Vector2(0, 12)
	_rule.draw.connect(_draw_rule)
	column.add_child(_rule)

	_body = _story_label(_body_text, CREAM, 26)
	_body.visible_ratio = 0.0
	# Lay out the whole text up front, so the lines don't re-wrap (and
	# the block doesn't jump) as it types in.
	_body.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	column.add_child(_body)

	_run()


func _run() -> void:
	var type_time: float = _body_text.length() * SECONDS_PER_CHAR
	var hold: float = HOLD_BASE_TIME + (_title_text.length() + _body_text.length()) * HOLD_PER_CHAR

	var tw := create_tween()
	tw.tween_property(_root, "modulate:a", 1.0, DIM_TIME)
	tw.tween_property(_title, "modulate:a", 1.0, TITLE_FADE_TIME)
	tw.parallel().tween_method(_set_rule_t, 0.0, 1.0, RULE_TIME).set_delay(TITLE_FADE_TIME * 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_body, "visible_ratio", 1.0, type_time)
	tw.tween_interval(hold)
	tw.tween_property(_root, "modulate:a", 0.0, FADE_OUT_TIME)
	await tw.finished
	finished.emit()
	queue_free()


## The Intro's StoryLabel look: outlined, shadowed, centred, wrapping.
func _story_label(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.add_theme_constant_override("outline_size", 8)
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _set_rule_t(t: float) -> void:
	_rule_t = t
	_rule.queue_redraw()


## A thin golden rule under the title, drawn out from a small diamond at
## its centre and fading toward both ends.
func _draw_rule() -> void:
	if _rule_t <= 0.0:
		return
	var mid := _rule.size * 0.5
	var half: float = minf(_rule.size.x * 0.22, 220.0) * _rule_t
	var steps := 12
	for i in steps:
		var a := float(i) / steps
		var b := float(i + 1) / steps
		var color := Color(GOLD, 0.85 * (1.0 - a))
		_rule.draw_line(mid + Vector2(half * a, 0), mid + Vector2(half * b, 0), color, 1.5, true)
		_rule.draw_line(mid - Vector2(half * a, 0), mid - Vector2(half * b, 0), color, 1.5, true)
	var d := 4.5 * _rule_t
	_rule.draw_colored_polygon(PackedVector2Array([mid + Vector2(0, -d), mid + Vector2(d, 0), mid + Vector2(0, d), mid + Vector2(-d, 0)]), GOLD)
