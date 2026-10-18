class_name EclipseSkyFX
extends Control

## Purely cosmetic: the sky of Lunara's Eternal Eclipse, up for as long as
## the ultimate lasts. The battlefield sinks into a bruised violet dark with
## a heavy vignette, and a black sun hangs over it - a dead disc ringed by a
## blood-red corona that breathes, with slow spokes of crimson light turning
## round it and one bright bead of light creeping along its rim like a
## diamond ring. Each beam that strikes flares the corona (flare()).
##
## It lives in the battle scene UNDER the fighters (battle.gd inserts it
## below the hero and the enemies layer), so the fighters stay readable in
## the dark. Fades in over FADE_IN and out over FADE_OUT.

const FADE_IN := 1.2
const FADE_OUT := 1.0
const DARKNESS := 0.4              # alpha of the dark violet wash
const SPOKES := 28

const CORONA := Color(1.0, 0.18, 0.28)
const CORONA_HOT := Color(1.0, 0.55, 0.5)
const VOID := Color(0.02, 0.0, 0.05)
const WASH := Color(0.04, 0.0, 0.1)

var _time := 0.0
var _flare := 0.0
var _radius := 70.0
var _center := Vector2.ZERO
var _glow_tex: Texture2D
var _corona: Node2D
var _disc: Node2D
var _tween: Tween
var _ending := false


## Raises the eclipse in `parent`, below its child at `below_index` (so the
## fighters draw over it), and returns it.
static func begin(parent: Control, below_index: int) -> EclipseSkyFX:
	var sky := EclipseSkyFX.new()
	parent.add_child(sky)
	parent.move_child(sky, below_index)
	return sky


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var view := get_viewport_rect().size
	_radius = view.y * 0.082
	_center = Vector2(view.x * 0.5, view.y * 0.2)

	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.15, 0.4, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.16), Color(1, 1, 1, 0.0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 128
	t.height = 128
	_glow_tex = t

	# The dark wash, then a vignette that closes in from the edges.
	var wash := ColorRect.new()
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wash.color = Color(WASH, DARKNESS)
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(wash)
	var vg := Gradient.new()
	vg.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	vg.colors = PackedColorArray([Color(VOID, 0.0), Color(VOID, 0.15), Color(VOID, 0.8)])
	var vt := GradientTexture2D.new()
	vt.gradient = vg
	vt.fill = GradientTexture2D.FILL_RADIAL
	vt.fill_from = Vector2(0.5, 0.5)
	vt.fill_to = Vector2(1.0, 1.0)
	vt.width = 128
	vt.height = 128
	var vignette := TextureRect.new()
	vignette.texture = vt
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vignette)

	# The corona (additive), then the black disc over it.
	_corona = Node2D.new()
	_corona.material = _additive()
	_corona.draw.connect(_draw_corona)
	add_child(_corona)
	_disc = Node2D.new()
	_disc.draw.connect(_draw_disc)
	add_child(_disc)

	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN)


func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


## Where the eclipse hangs (this node's own coordinates, which are the
## battle scene's).
func center() -> Vector2:
	return _center


## The point on the disc's rim facing `toward`, where a beam leaves it.
func rim_toward(toward: Vector2) -> Vector2:
	return _center + (toward - _center).normalized() * _radius * 1.05


## A beam has struck: the corona flares up and settles.
func flare() -> void:
	_flare = 1.0


## Lowers the eclipse: fades out and frees itself.
func end() -> void:
	if _ending:
		return
	_ending = true
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT)
	_tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_time += delta
	_flare = move_toward(_flare, 0.0, delta / 0.45)
	_corona.queue_redraw()
	_disc.queue_redraw()


func _draw_corona() -> void:
	var breathe := 0.8 + 0.2 * sin(_time * 1.3)
	var boost := 1.0 + 0.9 * _flare
	# The wide red haze around the sun.
	var halo := Vector2.ONE * _radius * 7.0 * (0.95 + 0.1 * breathe + 0.12 * _flare)
	_corona.draw_texture_rect(_glow_tex, Rect2(_center - halo * 0.5, halo), false, Color(CORONA, 0.42 * breathe * boost))
	var inner := Vector2.ONE * _radius * 3.6
	_corona.draw_texture_rect(_glow_tex, Rect2(_center - inner * 0.5, inner), false, Color(CORONA_HOT, 0.5 * boost))
	# Spokes of crimson light, turning slowly, long and short alternating.
	for i in SPOKES:
		var a := TAU * float(i) / float(SPOKES) + _time * 0.05
		var long := 0.5 + 0.5 * sin(float(i) * 2.3 + _time * 0.7)
		var r0 := _radius * 1.1
		var r1 := _radius * (1.7 + 1.5 * long + 0.6 * _flare)
		var dir := Vector2(cos(a), sin(a))
		_corona.draw_line(_center + dir * r0, _center + dir * r1, Color(CORONA, (0.16 + 0.16 * long) * boost), 2.0 + 2.0 * long, true)
	# The corona ring hugging the disc.
	_corona.draw_arc(_center, _radius * 1.1, 0.0, TAU, 64, Color(CORONA, 0.8 * boost), _radius * 0.2, true)
	_corona.draw_arc(_center, _radius * 1.03, 0.0, TAU, 64, Color(CORONA_HOT, 0.8 * boost), _radius * 0.06, true)
	# The diamond ring: a bead of white-hot light creeping around the rim.
	var bead := _time * 0.25
	var at := _center + Vector2(cos(bead), sin(bead)) * _radius * 1.08
	_corona.draw_texture_rect(_glow_tex, Rect2(at - Vector2.ONE * _radius * 0.9, Vector2.ONE * _radius * 1.8), false, Color(1.0, 0.85, 0.85, 0.55 + 0.25 * sin(_time * 3.0)))


func _draw_disc() -> void:
	_disc.draw_circle(_center, _radius * 1.02, Color(VOID, 1.0))
	# A hair of cold violet at the edge, so it reads as a sphere rather than
	# a hole.
	_disc.draw_arc(_center, _radius * 0.98, 0.0, TAU, 64, Color(0.35, 0.18, 0.55, 0.3), 2.0, true)
