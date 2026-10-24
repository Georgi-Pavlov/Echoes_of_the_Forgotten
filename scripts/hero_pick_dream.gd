class_name HeroPickDream
extends Control

## Plays a folder of still images as a fading slideshow, then changes to
## another scene. Set up with HeroPickDream.play() from any scene: it
## stashes the folder + destination in statics and switches to
## hero_pick_dream.tscn. Images are shown in filename order (natural sort, so
## _2 comes before _10). Click / Enter / Space advances, Esc skips it all.

const SCENE_PATH := "res://scenes/hero_pick_dream.tscn"
const IMAGE_EXTENSIONS: Array[String] = ["jpg", "jpeg", "png", "webp"]

const HOLD_TIME := 4.5
const FADE_TIME := 1.0
const SUBTITLE_FADE := 0.3

# Scene 1: the campfire. The flame's base in the image (UV), how long the
# stare into it lasts, and how far the camera pushes in by the end.
const FIRE_SHADER := preload("res://shaders/dream_fire.gdshader")
const FIRE_FOCUS := Vector2(0.55, 0.69)
const FIRE_TIME := 6.0
const FIRE_START_DIM := 0.7
const FIRE_SOUND_DB := 0.0
const FIRE_SOUND_FADE := 1.5
const FIRE_END_ZOOM :=3.6

const DEFAULT_FOLDER := "res://assets/cutscenes/hero_pick_dream/"

## For previewing: run this scene on its own (F6) with these set in the
## Inspector, or pass --dream-scene=N / --dream-loop after a bare "--" on
## the command line. The game itself plays it from the start, so leave
## them alone.
@export var start_scene := 1
@export var loop_scene := false

# Scene 2: the garden. The far end of the path the camera pushes down, how
# far it pushes in, and when (fraction of the scene) the white-out begins.
const GARDEN_SHADER := preload("res://shaders/dream_garden.gdshader")
const GARDEN_PATH_FOCUS := Vector2(0.64, 0.7)
const GARDEN_TIME := 5
const GARDEN_END_ZOOM := 1.5
const GARDEN_WHITE_START := 0.55
# footsteps_gravel is a plain file (no built-in level offset). -6 dB would
# match the birds; it sits 4 dB above them so the steps read.
const GARDEN_STEPS_DB := -2.0
const BIRDS_DB := -6.0
const GARDEN_STEPS_FADE := 1.5

# Scene 3: the doorway. Where the camera climbs to, how far in, when (as a
# fraction of the scene) it arrives and the door opens, and when the
# white-out starts. Fewer petals/pollen than the garden.
const DOOR_SHADER := preload("res://shaders/dream_door.gdshader")
const DOOR_FOCUS := Vector2(0.66, 0.5)
const DOOR_END_ZOOM := 1.5
const DOOR_ARRIVE := 0.55
const DOOR_WHITE_START := 0.6
const DOOR_PARTICLE_DENSITY := 0.5

# Scene 4: waking up. The narration sets its length: the voice starts once
# the scene has faded in, and the scene ends a beat after the last word (the
# speech stops at WAKE_SPEECH_END, a little before the file does). Also
# where the smoke rises from, how
# many autumn leaves fall, and how long the eyes take to clear.
const WAKE_SHADER := preload("res://shaders/dream_wake.gdshader")
const WAKE_VOICE := "res://assets/cutscenes/hero_pick_dream/hero_pick_dream_4.mp3"
const WAKE_VOICE_DELAY := 1.0
const WAKE_SPEECH_END := 26.5
const WAKE_TAIL := 0.8
const WAKE_TIME := WAKE_VOICE_DELAY + WAKE_SPEECH_END + WAKE_TAIL
const WAKE_CLEAR_TIME := 5.0
const WAKE_SMOKE_POS := Vector2(0.31, 0.57)
const WAKE_LEAF_DENSITY := 0.3

## The subtitles: [start, end, text], in seconds into the narration (found
## from where the speech actually is in the file, so each line is up while
## it's spoken).
const WAKE_SUBTITLES: Array = [
	[0.1, 4.1, "You've had this same dream, over and over again."],
	[4.9, 6.3, "You cannot explain it."],
	[6.7, 8.6, "You cannot understand it."],
	[9.0, 12.1, "But every time you wake, the feeling remains."],
	[12.6, 14.7, "Something feels so familiar."],
	[15.1, 17.5, "So strangely... longed for."],
	[18.2, 22.6, "As if it's calling you somewhere, deep within these forgotten lands..."],
	[23.3, 26.5, "And just like that, you feel compelled to follow."],
]

## Footsteps join from "As if it's calling you..." to the end.
const WAKE_STEPS_FROM := 18.2
# Quieter than in the garden: they sit under the narration.
const WAKE_STEPS_DB := -9.0

static var _folder := ""
static var _next_scene := ""

var _textures: Array[Texture2D] = []
var _fade: ColorRect
var _skip_button: Button
var _voice: AudioStreamPlayer
# Players that fade out with the final fade to black (narration, steps).
var _fade_with_scene: Array[AudioStreamPlayer] = []
var _index := -1
var _advance_requested := false
var _skip_requested := false
var _finished := false


static func play(folder: String, next_scene: String) -> void:
	_folder = folder
	_next_scene = next_scene
	(Engine.get_main_loop() as SceneTree).change_scene_to_file(SCENE_PATH)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)

	# Same bottom-right Skip button as Intro.tscn, on its own layer so the
	# black fade never covers it.
	var button_layer := CanvasLayer.new()
	button_layer.layer = 1
	add_child(button_layer)
	_skip_button = Button.new()
	_skip_button.text = "Skip"
	_skip_button.focus_mode = Control.FOCUS_NONE
	_skip_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_skip_button.offset_left = -140.0
	_skip_button.offset_top = -56.0
	_skip_button.offset_right = -20.0
	_skip_button.offset_bottom = -16.0
	_skip_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_skip_button.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_skip_button.pressed.connect(func(): _skip_requested = true)
	button_layer.add_child(_skip_button)

	# Run on its own (F6 / command line) there's no caller to hand us a
	# folder or a scene to go on to: use the default folder and just quit.
	if _folder == "":
		_folder = DEFAULT_FOLDER
	_read_test_args()
	_textures = _load_folder(_folder)
	_run()


## One slide: a full-screen Control (so the whole slide - picture and any
## particles - can be scaled/moved as one) holding the picture. It starts
## transparent; _run() fades it in.
func _make_stage(texture: Texture2D, stretch_mode: TextureRect.StretchMode) -> Control:
	var stage := Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.modulate.a = 0.0

	var rect := TextureRect.new()
	rect.name = "Picture"
	rect.texture = texture
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = stretch_mode
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(rect)

	add_child(stage)
	return stage


## Sets up the animation for slide `index` (0-based) and returns how long
## the slide stays up, fade-in included.
func _animate_stage(index: int, stage: Control) -> float:
	if index == 0:
		return _animate_campfire(stage)
	if index == 1:
		return _animate_garden(stage)
	if index == 2:
		return _animate_door(stage)
	if index == 3:
		return _animate_wake(stage)
	return HOLD_TIME + FADE_TIME


## Scene 4: waking up by the dead fire. The eyes open (a blink in the
## middle) on a blurry, dark forest that sharpens and brightens; smoke
## curls up from the ashes, mist drifts, the sunrise rays breathe, autumn
## leaves and dust fall. The camera stays still. It's the
## last scene, so it ends in the fade to black that hands over to the game.
func _animate_wake(stage: Control) -> float:
	var picture: TextureRect = stage.get_node("Picture")
	var size_px := get_viewport_rect().size

	var wake_material := ShaderMaterial.new()
	wake_material.shader = WAKE_SHADER
	wake_material.set_shader_parameter("aspect", size_px.x / size_px.y)
	picture.material = wake_material

	stage.add_child(_make_smoke(WAKE_SMOKE_POS * size_px))
	stage.add_child(_make_petals(size_px, WAKE_LEAF_DENSITY, _leaf_tint()))
	stage.add_child(_make_motes(size_px, 0.5))

	var tween := stage.create_tween().set_parallel(true)
	tween.tween_method(func(value: float) -> void: wake_material.set_shader_parameter("wake", value),
			0.0, 1.0, WAKE_CLEAR_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Eyelids: they part, flutter shut once, then open for good.
	var lids := stage.create_tween()
	var set_lids := func(value: float) -> void: wake_material.set_shader_parameter("lids", value)
	for step in [[1.0, 0.45, 1.5], [0.45, 0.9, 0.5], [0.9, 0.0, 0.7]]:
		lids.tween_method(set_lids, step[0], step[1], step[2]) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Narration, with its subtitles shown while each line is spoken.
	_voice = AudioStreamPlayer.new()
	_voice.stream = load(WAKE_VOICE)
	_voice.bus = "SFX"
	stage.add_child(_voice)
	_fade_with_scene.append(_voice)
	tween.tween_callback(_voice.play).set_delay(WAKE_VOICE_DELAY)
	_play_subtitles(WAKE_SUBTITLES, WAKE_VOICE_DELAY)

	# Footsteps join in as the voice starts calling the hero onward.
	tween.tween_callback(func() -> void:
		var steps := AudioManager.play_loop("steps", stage, WAKE_STEPS_DB, 0.5)
		if steps != null:
			_fade_with_scene.append(steps)) \
			.set_delay(WAKE_VOICE_DELAY + WAKE_STEPS_FROM)
	return WAKE_TIME


## Subtitle lines along the bottom, styled like the intro's, each fading in
## at its start and out at its end (`lines` are [start, end, text] in
## seconds, `offset` seconds after now).
func _play_subtitles(lines: Array, offset: float) -> void:
	var label := Label.new()
	label.anchor_left = 0.14
	label.anchor_top = 0.8
	label.anchor_right = 0.86
	label.anchor_bottom = 0.96
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color(1, 0.93, 0.8, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.add_theme_constant_override("outline_size", 8)
	label.modulate.a = 0.0
	add_child(label)
	_fade.move_to_front()

	var tween := label.create_tween()
	var clock := 0.0
	for line in lines:
		var start: float = offset + line[0]
		var end: float = offset + line[1]
		tween.tween_interval(maxf(start - clock, 0.0))
		tween.tween_callback(func() -> void: label.text = line[2])
		tween.tween_property(label, "modulate:a", 1.0, SUBTITLE_FADE)
		tween.tween_interval(maxf(end - start - 2.0 * SUBTITLE_FADE, 0.0))
		tween.tween_property(label, "modulate:a", 0.0, SUBTITLE_FADE)
		clock = maxf(end, start + 2.0 * SUBTITLE_FADE)


## Browns and burnt oranges for the falling autumn leaves.
func _leaf_tint() -> Gradient:
	var tint := Gradient.new()
	tint.offsets = PackedFloat32Array([0.0, 1.0])
	tint.colors = PackedColorArray([Color(0.75, 0.3, 0.1, 0.95), Color(0.9, 0.55, 0.15, 0.95)])
	return tint


## A thin pale thread of smoke from the dead fire: big soft puffs that
## rise slowly, swell and fade.
func _make_smoke(pos: Vector2) -> CPUParticles2D:
	var puff := Gradient.new()
	puff.set_color(0, Color(1, 1, 1, 0.5))
	puff.set_color(1, Color(1, 1, 1, 0))
	var dot := GradientTexture2D.new()
	dot.gradient = puff
	dot.fill = GradientTexture2D.FILL_RADIAL
	dot.fill_from = Vector2(0.5, 0.5)
	dot.fill_to = Vector2(0.5, 0.0)
	dot.width = 64
	dot.height = 64

	var life := Gradient.new()
	life.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	life.colors = PackedColorArray([
		Color(0.8, 0.78, 0.78, 0.0),
		Color(0.8, 0.78, 0.78, 0.35),
		Color(0.7, 0.68, 0.7, 0.0),
	])

	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.4))
	grow.add_point(Vector2(1.0, 1.4))

	var smoke := CPUParticles2D.new()
	smoke.position = pos
	smoke.texture = dot
	smoke.local_coords = true
	smoke.amount = 14
	smoke.lifetime = 5.0
	smoke.lifetime_randomness = 0.3
	smoke.preprocess = 5.0
	smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	smoke.emission_rect_extents = Vector2(25, 4)
	smoke.direction = Vector2(0.15, -1.0)
	smoke.spread = 12.0
	smoke.initial_velocity_min = 14.0
	smoke.initial_velocity_max = 28.0
	smoke.gravity = Vector2(6, -2)
	smoke.scale_amount_min = 0.6
	smoke.scale_amount_max = 1.0
	smoke.scale_amount_curve = grow
	smoke.color_ramp = life
	return smoke


## Scene 2: a breeze in the greenery, petals and pollen drifting through the
## sunlight, a flickering lantern and soft rays. The camera creeps down the
## path while the light swells and washes everything out to white, which
## carries us into the next scene. Same length as the campfire.
func _animate_garden(stage: Control) -> float:
	var picture: TextureRect = stage.get_node("Picture")
	var size_px := get_viewport_rect().size
	var path_px := GARDEN_PATH_FOCUS * size_px

	var garden_material := ShaderMaterial.new()
	garden_material.shader = GARDEN_SHADER
	garden_material.set_shader_parameter("aspect", size_px.x / size_px.y)
	picture.material = garden_material

	var petals := _make_petals(size_px)
	var motes := _make_motes(size_px)
	stage.add_child(petals)
	stage.add_child(motes)

	# Straight down the path: zoom about its far end, nothing else moves.
	stage.pivot_offset = path_px
	var tween := stage.create_tween().set_parallel(true)
	tween.tween_property(stage, "scale", Vector2.ONE * GARDEN_END_ZOOM, GARDEN_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# The white-out only starts in the last stretch; petals and pollen
	# dissolve into it.
	var white_start := GARDEN_TIME * GARDEN_WHITE_START
	var white_time := GARDEN_TIME - white_start
	tween.tween_method(func(value: float) -> void: garden_material.set_shader_parameter("white", value),
			0.0, 1.0, white_time).set_delay(white_start).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(petals, "modulate:a", 0.0, white_time).set_delay(white_start)
	tween.tween_property(motes, "modulate:a", 0.0, white_time).set_delay(white_start)

	# Footsteps along the path, looped for the whole walk (the player lives
	# on the stage, so it goes when the stage does) and fading out into the
	# white.
	var steps := AudioManager.play_loop("footsteps_gravel", stage, GARDEN_STEPS_DB, 0.3)
	var birds := AudioManager.play_loop("birds", stage, BIRDS_DB, 1.0)
	tween.tween_callback(func() -> void: AudioManager.stop_loop(birds, GARDEN_STEPS_FADE)) \
			.set_delay(maxf(GARDEN_TIME - GARDEN_STEPS_FADE, 0.0))
	tween.tween_callback(func() -> void: AudioManager.stop_loop(steps, GARDEN_STEPS_FADE)) \
			.set_delay(maxf(GARDEN_TIME - GARDEN_STEPS_FADE, 0.0))
	return GARDEN_TIME


## Scene 3: the doorway at the end of the path. The lantern flickers, leaf
## shadows shimmer over the door (which itself stays shut still), a few
## petals and pollen drift by, and the camera climbs the steps toward the
## door with footsteps. When it arrives the door opens (sound only) and the
## light from inside washes everything out to white.
func _animate_door(stage: Control) -> float:
	var picture: TextureRect = stage.get_node("Picture")
	var size_px := get_viewport_rect().size
	var door_px := DOOR_FOCUS * size_px

	var door_material := ShaderMaterial.new()
	door_material.shader = DOOR_SHADER
	door_material.set_shader_parameter("doorway", DOOR_FOCUS)
	door_material.set_shader_parameter("aspect", size_px.x / size_px.y)
	picture.material = door_material

	var petals := _make_petals(size_px, DOOR_PARTICLE_DENSITY)
	var motes := _make_motes(size_px, DOOR_PARTICLE_DENSITY)
	stage.add_child(petals)
	stage.add_child(motes)

	# Up the steps to the door: zoom about the doorway.
	stage.pivot_offset = door_px
	var tween := stage.create_tween().set_parallel(true)
	tween.tween_property(stage, "scale", Vector2.ONE * DOOR_END_ZOOM, FIRE_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Footsteps while climbing; they stop on arrival, the door opens, and the
	# white-out follows right behind it.
	var arrive_time := FIRE_TIME * DOOR_ARRIVE
	var steps := AudioManager.play_loop("footsteps_gravel", stage, GARDEN_STEPS_DB, 0.3)
	var birds := AudioManager.play_loop("birds", stage, BIRDS_DB, 1.0)
	tween.tween_callback(func() -> void: AudioManager.stop_loop(birds, 1.5)).set_delay(arrive_time)
	tween.tween_callback(func() -> void:
		AudioManager.stop_loop(steps, 0.15)
		AudioManager.play_event("door_open")).set_delay(arrive_time)

	var white_start := FIRE_TIME * DOOR_WHITE_START
	var white_time := FIRE_TIME - white_start
	tween.tween_method(func(value: float) -> void: door_material.set_shader_parameter("white", value),
			0.0, 1.0, white_time).set_delay(white_start).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(petals, "modulate:a", 0.0, white_time).set_delay(white_start)
	tween.tween_property(motes, "modulate:a", 0.0, white_time).set_delay(white_start)
	return FIRE_TIME


## Pink and cream petals falling slowly through the whole picture.
func _make_petals(size_px: Vector2, density: float = 1.0, tint: Gradient = null) -> CPUParticles2D:
	var petal_image := Image.create(16, 8, false, Image.FORMAT_RGBA8)
	for y in 8:
		for x in 16:
			var dx := (x - 7.5) / 8.0
			var dy := (y - 3.5) / 4.0
			var edge := clampf(1.0 - (dx * dx + dy * dy), 0.0, 1.0)
			petal_image.set_pixel(x, y, Color(1, 1, 1, minf(edge * 2.0, 1.0)))

	if tint == null:
		tint = Gradient.new()
		tint.offsets = PackedFloat32Array([0.0, 1.0])
		tint.colors = PackedColorArray([Color(1.0, 0.72, 0.8, 0.95), Color(1.0, 0.94, 0.88, 0.95)])

	var petals := CPUParticles2D.new()
	petals.position = Vector2(size_px.x * 0.5, -20.0)
	petals.texture = ImageTexture.create_from_image(petal_image)
	petals.local_coords = true
	petals.amount = maxi(1, roundi(34 * density))
	petals.lifetime = 9.0
	petals.lifetime_randomness = 0.4
	petals.preprocess = 9.0
	petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	petals.emission_rect_extents = Vector2(size_px.x * 0.6, 10.0)
	petals.direction = Vector2(0.35, 1.0)
	petals.spread = 22.0
	petals.initial_velocity_min = 25.0
	petals.initial_velocity_max = 60.0
	petals.gravity = Vector2(10, 6)
	petals.angle_max = 360.0
	petals.angular_velocity_min = -80.0
	petals.angular_velocity_max = 80.0
	petals.scale_amount_min = 0.7
	petals.scale_amount_max = 1.6
	petals.color_initial_ramp = tint
	return petals


## Tiny motes of pollen hanging in the sunlight, additively blended so they
## glint, drifting slowly upward.
func _make_motes(size_px: Vector2, density: float = 1.0) -> CPUParticles2D:
	var glow := Gradient.new()
	glow.set_color(0, Color(1, 1, 1, 1))
	glow.set_color(1, Color(1, 1, 1, 0))
	var dot := GradientTexture2D.new()
	dot.gradient = glow
	dot.fill = GradientTexture2D.FILL_RADIAL
	dot.fill_from = Vector2(0.5, 0.5)
	dot.fill_to = Vector2(0.5, 0.0)
	dot.width = 16
	dot.height = 16

	var life := Gradient.new()
	life.offsets = PackedFloat32Array([0.0, 0.25, 0.75, 1.0])
	life.colors = PackedColorArray([
		Color(1.0, 0.9, 0.55, 0.0),
		Color(1.0, 0.9, 0.55, 0.9),
		Color(1.0, 0.85, 0.5, 0.9),
		Color(1.0, 0.85, 0.5, 0.0),
	])

	var motes := CPUParticles2D.new()
	motes.position = size_px / 2.0
	motes.texture = dot
	motes.local_coords = true
	motes.amount = maxi(1, roundi(70 * density))
	motes.lifetime = 7.0
	motes.lifetime_randomness = 0.5
	motes.preprocess = 7.0
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = size_px / 2.0
	motes.direction = Vector2(0.4, -1.0)
	motes.spread = 60.0
	motes.initial_velocity_min = 4.0
	motes.initial_velocity_max = 16.0
	motes.gravity = Vector2.ZERO
	motes.scale_amount_min = 0.2
	motes.scale_amount_max = 0.6
	motes.color_ramp = life

	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	motes.material = additive
	return motes


## Scene 1: a flickering fire with embers drifting up from it, the rest of
## the picture dimming and closing in until the camera is pushed right into
## the flame - which is what carries us into the next scene.
func _animate_campfire(stage: Control) -> float:
	var picture: TextureRect = stage.get_node("Picture")
	var size_px := get_viewport_rect().size
	var flame_px := FIRE_FOCUS * size_px

	var fire_material := ShaderMaterial.new()
	fire_material.shader = FIRE_SHADER
	fire_material.set_shader_parameter("focus", FIRE_FOCUS)
	fire_material.set_shader_parameter("aspect", size_px.x / size_px.y)
	fire_material.set_shader_parameter("dim", FIRE_START_DIM)
	picture.material = fire_material

	stage.add_child(_make_embers(flame_px))

	# Zoom about the flame while sliding it to the middle of the screen.
	stage.pivot_offset = flame_px
	var tween := stage.create_tween().set_parallel(true)
	tween.tween_property(stage, "scale", Vector2.ONE * FIRE_END_ZOOM, FIRE_TIME) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(stage, "position", size_px / 2.0 - flame_px, FIRE_TIME) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_method(func(value: float) -> void: fire_material.set_shader_parameter("dim", value),
			FIRE_START_DIM, 1.0, FIRE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# The crackle of the fire for the whole scene (the player lives on the
	# stage, so it goes when the stage does), fading as the dark closes in.
	var crackle := AudioManager.play_loop("campfire", stage, FIRE_SOUND_DB, 0.8)
	tween.tween_callback(func() -> void: AudioManager.stop_loop(crackle, FIRE_SOUND_FADE)) \
			.set_delay(maxf(FIRE_TIME - FIRE_SOUND_FADE, 0.0))
	return FIRE_TIME


## Soft glowing sparks leaving the fire, additively blended so they burn
## bright against the dark. local_coords keeps them inside the stage, so
## they grow with the zoom.
func _make_embers(flame_px: Vector2) -> CPUParticles2D:
	var glow := Gradient.new()
	glow.set_color(0, Color(1, 1, 1, 1))
	glow.set_color(1, Color(1, 1, 1, 0))
	var dot := GradientTexture2D.new()
	dot.gradient = glow
	dot.fill = GradientTexture2D.FILL_RADIAL
	dot.fill_from = Vector2(0.5, 0.5)
	dot.fill_to = Vector2(0.5, 0.0)
	dot.width = 16
	dot.height = 16

	var life := Gradient.new()
	life.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	life.colors = PackedColorArray([
		Color(1.0, 0.85, 0.4, 1.0),
		Color(1.0, 0.45, 0.12, 0.85),
		Color(0.7, 0.1, 0.02, 0.0),
	])

	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(1.0, 0.2))

	var embers := CPUParticles2D.new()
	embers.position = flame_px - Vector2(0, 20)
	embers.texture = dot
	embers.local_coords = true
	embers.amount = 90
	embers.lifetime = 3.6
	embers.lifetime_randomness = 0.5
	embers.preprocess = 4.0
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(45, 8)
	embers.direction = Vector2(0, -1)
	embers.spread = 24.0
	embers.initial_velocity_min = 40.0
	embers.initial_velocity_max = 130.0
	embers.gravity = Vector2(18, -14)
	embers.damping_min = 4.0
	embers.damping_max = 14.0
	embers.angle_max = 360.0
	embers.scale_amount_min = 0.25
	embers.scale_amount_max = 0.75
	embers.scale_amount_curve = shrink
	embers.color_ramp = life

	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	embers.material = additive
	return embers


func _load_folder(folder: String) -> Array[Texture2D]:
	var names: Array[String] = []
	# Exported builds only keep the imported .ctex remaps, so list the
	# originals (".import" files in the editor, ".remap" in exports) rather
	# than relying on the raw image files being present.
	for file_name in DirAccess.get_files_at(folder):
		var base := file_name.trim_suffix(".import").trim_suffix(".remap")
		if base.get_extension().to_lower() in IMAGE_EXTENSIONS and not names.has(base):
			names.append(base)
	names.sort_custom(func(a: String, b: String) -> bool: return a.naturalnocasecmp_to(b) < 0)

	var textures: Array[Texture2D] = []
	for file_name in names:
		var texture := load(folder.path_join(file_name)) as Texture2D
		if texture != null:
			textures.append(texture)
	return textures


## Clicks land here only when they miss the Skip button (which consumes its
## own), so tapping the button can no longer be mistaken for "next image".
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance_requested = true
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_skip_requested = true
	elif event.is_action_pressed("ui_accept"):
		_advance_requested = true
	else:
		return
	get_viewport().set_input_as_handled()


## Picks up --dream-scene=N and --dream-loop from the command line (after a
## bare "--"), overriding start_scene/loop_scene.
func _read_test_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--dream-scene="):
			start_scene = arg.get_slice("=", 1).to_int()
		elif arg == "--dream-loop":
			loop_scene = true


func _run() -> void:
	var front: Control = null
	var index := clampi(start_scene, 1, maxi(_textures.size(), 1)) - 1

	while index < _textures.size():
		if _skip_requested:
			break
		_advance_requested = false

		# The campfire's shader needs the picture stretched edge to edge; the
		# images are 16:9 like the screen, so nothing is distorted.
		var stretch := TextureRect.STRETCH_SCALE if index <= 3 else TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var stage := _make_stage(_textures[index], stretch)
		_fade.move_to_front()
		var duration := _animate_stage(index, stage)

		var fade_in := create_tween().set_parallel(true)
		fade_in.tween_property(stage, "modulate:a", 1.0, FADE_TIME)
		# The new slide fades in over the old one rather than both fading
		# at once (which would dip to grey): the old one ends black (scene
		# 1) or white (scene 2) anyway.
		if front != null:
			fade_in.finished.connect(front.queue_free)
		else:
			fade_in.tween_property(_fade, "color:a", 0.0, FADE_TIME)

		var elapsed := 0.0
		while elapsed < duration and not _advance_requested and not _skip_requested:
			await get_tree().process_frame
			elapsed += get_process_delta_time()

		front = stage
		if not loop_scene:
			index += 1

	_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	_skip_button.disabled = true
	_fade.move_to_front()
	# Cut the narration (and anything else still sounding) with the fade.
	for player in _fade_with_scene:
		if is_instance_valid(player):
			create_tween().tween_property(player, "volume_db", -60.0, FADE_TIME)
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, FADE_TIME)
	await tween.finished
	if _next_scene == "":
		get_tree().quit()
		return
	get_tree().change_scene_to_file(_next_scene)
