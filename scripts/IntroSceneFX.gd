class_name IntroSceneFX
extends Control

## Base for one intro scene's effects layer (IntroScene1FX.gd etc.): the
## node Intro.gd lays over that scene's image, inside the scene's own
## viewport, so everything added here burns away along with the image.
##
## Positions are fractions of the image (0-1 across, 0-1 down) - the image
## fills the 1280x720 screen exactly. Areas are Rect2(left, top, width,
## height).

const SIZE := Vector2(1280, 720)


func _init() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE


## A rect over `area` drawn with `shader` (in a fresh material of its own).
func _add_shader_rect(area: Rect2, shader: Shader) -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = MOUSE_FILTER_IGNORE
	rect.position = area.position * SIZE
	rect.size = area.size * SIZE
	var mat := ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)
	return rect


## Makes the screen-reading effects added after this see the picture as
## the ones before it left it (by default they all see the plain image).
func _recapture() -> void:
	var copy := BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(copy)


## A soft round glow centred on `pos`, `diameter` screen pixels across -
## added on top of the picture (`additive`), or painted over it (for
## something like an eyelid, solid in the middle so it fully covers).
func _add_glow(pos: Vector2, diameter: float, strength: float, color: Color, additive := true) -> TextureRect:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(color, strength))
	gradient.set_color(1, Color(color, 0.0))
	if not additive:
		gradient.add_point(0.55, Color(color, strength))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64

	var glow := TextureRect.new()
	glow.texture = tex
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.mouse_filter = MOUSE_FILTER_IGNORE
	glow.size = Vector2.ONE * diameter
	glow.position = pos * SIZE - glow.size / 2.0
	glow.pivot_offset = glow.size / 2.0
	if additive:
		var add := CanvasItemMaterial.new()
		add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = add
	add_child(glow)
	return glow


## A full-screen layer that draws itself with `draw_fn(layer)` every frame
## - for small hand-drawn creatures and specks.
func _add_draw_layer(draw_fn: Callable, additive := false) -> Control:
	var layer := Control.new()
	layer.set_anchors_preset(PRESET_FULL_RECT)
	layer.mouse_filter = MOUSE_FILTER_IGNORE
	layer.draw.connect(draw_fn.bind(layer))
	if additive:
		var add := CanvasItemMaterial.new()
		add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		layer.material = add
	add_child(layer)
	return layer
