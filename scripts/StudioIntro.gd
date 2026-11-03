extends Control

## Studio intro shown before the loading screen: the Trickster Forge logo
## is hurled in from the player's side of the screen, slams down in the
## middle, ignites in deep green fire, and then the
## TRICKSTER and FORGE wordmarks burn in above and below it.
@export_file("*.tscn") var next_scene_path: String = "res://scenes/LoadingScreen.tscn"

## The sound builds for ~1.65s and hits as the logo lands, so it starts
## with the scene and the throw is timed to meet that hit.
const INTRO_SOUND := preload("res://assets/trickster_forge/intro_sound.mp3")
const THROW_DELAY := 0.5
const LOGO_SIZE := 340.0
const THROW_TIME := 1.15
const THROW_SPIN := -100.0 # degrees at the start of the throw
const IGNITE_TIME := 1.4
const WORD_TIME := 1.0
const HOLD_TIME := 1.3
const FADE_OUT_TIME := 0.7

## Wordmarks: width on screen, vertical centre, and where the glyphs'
## visual centre sits in the image (FORGE has an empty left margin).
const WORD_WIDTH := 440.0
const WORD_PAD := Vector2(0.05, 0.3)
const TRICKSTER_Y := 110.0
const FORGE_Y := 612.0
const TRICKSTER_CENTER_X := 0.5046
const FORGE_CENTER_X := 0.5405

@onready var logo_root: Control = $LogoRoot
@onready var fill: TextureRect = $LogoRoot/Fill
@onready var halo: TextureRect = $Halo
@onready var trickster: TextureRect = $Trickster
@onready var forge: TextureRect = $Forge
@onready var black: ColorRect = $Black

var _skipping := false
var _fill_mat: ShaderMaterial
var _dust: CPUParticles2D


func _ready() -> void:
	var centre := size * 0.5
	logo_root.size = Vector2.ONE * LOGO_SIZE
	logo_root.pivot_offset = logo_root.size * 0.5
	logo_root.position = centre - logo_root.size * 0.5
	_fill_mat = fill.material as ShaderMaterial
	_fill_mat.set_shader_parameter("progress", 0.0)
	halo.position = centre - halo.size * 0.5
	halo.modulate.a = 0.0
	_dust = _make_dust(centre)
	_place_word(trickster, TRICKSTER_Y, TRICKSTER_CENTER_X)
	_place_word(forge, FORGE_Y, FORGE_CENTER_X)
	# Start of the throw: huge (right at the camera), spun and unseen.
	logo_root.scale = Vector2.ONE * 4.5
	logo_root.rotation = deg_to_rad(THROW_SPIN)
	logo_root.modulate.a = 0.0
	var sound := AudioStreamPlayer.new()
	sound.stream = INTRO_SOUND
	sound.bus = "SFX"
	add_child(sound)
	sound.play()
	_play()


## A ring of dust puffs thrown outward from the edge of the logo on impact.
func _make_dust(centre: Vector2) -> CPUParticles2D:
	var soft := Gradient.new()
	soft.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var tex := GradientTexture2D.new()
	tex.gradient = soft
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64

	var fade := Gradient.new()
	fade.colors = PackedColorArray([Color(0.62, 0.6, 0.56, 0.55), Color(0.45, 0.45, 0.42, 0.0)])
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.4))
	grow.add_point(Vector2(1.0, 1.0))

	var d := CPUParticles2D.new()
	d.position = centre
	d.texture = tex
	d.emitting = false
	d.one_shot = true
	d.explosiveness = 1.0
	d.amount = 36
	d.lifetime = 1.6
	d.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	d.emission_sphere_radius = LOGO_SIZE * 0.5
	d.gravity = Vector2.ZERO
	d.radial_accel_min = 160.0
	d.radial_accel_max = 320.0
	d.damping_min = 110.0
	d.damping_max = 180.0
	d.scale_amount_min = 1.6
	d.scale_amount_max = 3.2
	d.scale_amount_curve = grow
	d.angle_max = 360.0
	d.color_ramp = fade
	add_child(d)
	move_child(d, halo.get_index())
	return d


## Sizes a wordmark's rect (a little larger than its image, so the flames
## have room) so the glyphs' visual centre lands on the screen centre line.
func _place_word(word: TextureRect, centre_y: float, glyph_centre_x: float) -> void:
	var tex_size := word.texture.get_size()
	var w := WORD_WIDTH
	var h := w * tex_size.y / tex_size.x
	word.size = Vector2(w * (1.0 + 2.0 * WORD_PAD.x), h * (1.0 + 2.0 * WORD_PAD.y))
	var centre_x := size.x * 0.5 - (glyph_centre_x - 0.5) * w
	word.position = Vector2(centre_x, centre_y) - word.size * 0.5
	var mat := word.material as ShaderMaterial
	mat.set_shader_parameter("pad", WORD_PAD)
	mat.set_shader_parameter("reveal", 0.0)


func _input(event: InputEvent) -> void:
	if _skipping:
		return
	if (event is InputEventKey and event.pressed and not event.echo) \
			or (event is InputEventMouseButton and event.pressed) \
			or (event is InputEventScreenTouch and event.pressed):
		_skipping = true
		_go_next(true)


func _play() -> void:
	await _wait(THROW_DELAY)
	await _throw()
	await _ignite()
	await _burn_word(trickster)
	await _burn_word(forge)
	await _wait(HOLD_TIME)
	if _skipping:
		return
	_skipping = true
	await _go_next(false)


## Waits, and gives up on the sequence for good once the player skips.
func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	if _skipping:
		await get_tree().create_timer(100.0).timeout


## Thrown away from the viewer: it starts enormous and close, then
## shrinks into the middle of the screen, spinning less and less.
func _throw() -> void:
	var tw := create_tween().set_parallel()
	tw.tween_property(logo_root, "modulate:a", 1.0, THROW_TIME * 0.2)
	tw.tween_property(logo_root, "scale", Vector2.ONE, THROW_TIME) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(logo_root, "rotation", 0.0, THROW_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished
	_impact()


## The slam: a squash, a burst of dust and a short screen shake.
func _impact() -> void:
	var tw := create_tween()
	tw.tween_property(logo_root, "scale", Vector2.ONE * 0.93, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(logo_root, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	_dust.restart()

	var shake := create_tween()
	for i in 7:
		var amp := 14.0 * (1.0 - i / 7.0)
		shake.tween_property(self, "position", Vector2(randf_range(-amp, amp), randf_range(-amp, amp)), 0.035)
	shake.tween_property(self, "position", Vector2.ZERO, 0.035)


func _ignite() -> void:
	await _wait(0.45)
	var tw := create_tween().set_parallel()
	tw.tween_method(func(v: float) -> void: _fill_mat.set_shader_parameter("progress", v), \
		0.0, 1.0, IGNITE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(halo, "modulate:a", 1.0, IGNITE_TIME).set_trans(Tween.TRANS_SINE)
	await tw.finished
	# Keep breathing while the rest plays.
	var pulse := create_tween().set_loops()
	pulse.tween_property(halo, "modulate:a", 0.65, 0.6).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(halo, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)


func _burn_word(word: TextureRect) -> void:
	var mat := word.material as ShaderMaterial
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("reveal", v), \
		0.0, 1.0, WORD_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished


func _go_next(quick := false) -> void:
	var tw := create_tween()
	tw.tween_property(black, "color:a", 1.0, 0.25 if quick else FADE_OUT_TIME)
	await tw.finished
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
