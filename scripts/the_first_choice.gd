class_name TheFirstChoice
extends Control

## The dream after the player has killed their third rival and picked up
## the Echo: the images in assets/cutscenes/The_first_choice shown one after
## another (filename order), each crossfading into the next, then a fade to
## black and on to the next scene. Started with TheFirstChoice.play(); no
## camera or picture movement - effects and sounds come later. Click / Enter
## / Space moves on, Esc or the Skip button ends the whole dream.
##
## To preview it alone, run scenes/the_first_choice.tscn (F6) - set Start
## Scene / Loop Scene in the Inspector, or pass --choice-scene=N /
## --choice-loop after a bare "--" on the command line.

const SCENE_PATH := "res://scenes/the_first_choice.tscn"
const FOLDER := "res://assets/cutscenes/The_first_choice/"
const IMAGE_EXTENSIONS: Array[String] = ["jpg", "jpeg", "png", "webp"]

## How many rivals the player has to kill to earn this dream.
const RIVALS_REQUIRED := 3

const HOLD_TIME := 5.0
const FADE_TIME := 1.0
const SUBTITLE_FADE := 0.3

# The first scene fades up out of black this slowly.
const FIRST_FADE_IN_TIME := 2.0

# Scene 1: the portal on the battlefield. Where the camera heads (UV), how
# far in, how long the scene lasts, when (fraction of it) the white-out
# starts, the water on the lens, and the rain sound.
const PORTAL_FOCUS := Vector2(0.52, 0.4)
const PORTAL_ZOOM := 1.6
const PORTAL_TIME := 7.0
const PORTAL_WHITE_START := 0.55
const DRIPS_SHADER := preload("res://shaders/dream_drips.gdshader")
const DRIPS_FADE_IN := 1.5
const RAIN_DB := 0.0
const RAIN_FADE := 1.5

# Scene 2: the void. Where the camera heads (UV), how far in, how long the
# scene lasts, when (fraction of it) the white-out starts, where the sparks
# rise from, and the sounds.
const VOID_SHADER := preload("res://shaders/the_first_choice_void.gdshader")
const VOID_FOCUS := Vector2(0.5, 0.5)
const VOID_ZOOM := 1.5
const VOID_TIME := 7.0
const VOID_WHITE_START := 0.55
const SPARK_BASE := Vector2(0.51, 0.84)
const VOICES_DB := -9.0
const ECHO_STEPS_DB := 1.0
const VOID_SOUND_FADE := 1.5

# Scene 3: the city. How long the scene lasts, when (fraction of it) the
# closing wipe starts, and the sounds - the crowd sits under the rumble.
const CITY_SHADER := preload("res://shaders/the_first_choice_city.gdshader")
const CITY_TIME := 6
const CITY_WIPE_START := 0.55
const RUMBLE_DB := 0.0
const CROWD_DB := -9.0
const CITY_SOUND_FADE := 1.5

# Scene 4: the hand in the rain. The narration sets its length: the voice
# starts once the scene has faded in, and the scene ends a beat after the
# last word (the speech stops at HAND_SPEECH_END, a little before the file
# does). Its water on the lens is scene 1's (DRIPS_*); the rain sits under
# the voice.
const HAND_VOICE := "res://assets/cutscenes/The_first_choice/The_first_choice_scene_4.mp3"
const HAND_VOICE_DELAY := 1.0
const HAND_SPEECH_END := 22.95
const HAND_TAIL := 0.8
const HAND_TIME := HAND_VOICE_DELAY + HAND_SPEECH_END + HAND_TAIL
const HAND_RAIN_DB := -6.0

## The subtitles: [start, end, text], in seconds into the narration (found
## from where the speech actually is in the file, so each line is up while
## it's spoken).
const HAND_SUBTITLES: Array = [
	[0.1, 2.7, "Now, you know the truth."],
	[3.6, 6.3, "The memories of the old world have returned."],
	[6.7, 9.8, "And with them, a power long forgotten."],
	[10.4, 13.3, "But what will you do with this newfound strength?"],
	[14.0, 16.3, "Will you restore the world that was lost..."],
	[16.8, 19.9, "Or claim dominion over the world that remains?"],
	[20.6, 23.0, "The choice is yours, Remembered."],
]

@export var start_scene := 1
@export var loop_scene := false

static var _next_scene := ""

var _textures: Array[Texture2D] = []
var _fade: ColorRect
var _skip_button: Button
# Players that fade out with the final fade to black (narration, rain).
var _fade_with_scene: Array[AudioStreamPlayer] = []
var _advance_requested := false
var _skip_requested := false
var _finished := false


static func play(next_scene: String) -> void:
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

	# Same bottom-right Skip button as the intro, on its own layer so the
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

	_read_test_args()
	_textures = _load_folder(FOLDER)
	_run()


## Picks up --choice-scene=N and --choice-loop from the command line (after
## a bare "--"), overriding start_scene/loop_scene.
func _read_test_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--choice-scene="):
			start_scene = arg.get_slice("=", 1).to_int()
		elif arg == "--choice-loop":
			loop_scene = true


func _load_folder(folder: String) -> Array[Texture2D]:
	var names: Array[String] = []
	# Exported builds only keep the imported remaps, so list the originals
	# (".import" files in the editor, ".remap" in exports) rather than
	# relying on the raw image files being present.
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
## own).
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
## One slide: a full-screen Control (so the picture and any particles can be
## moved as one) holding the picture. It starts transparent; _run() fades
## it in.
func _make_stage(texture: Texture2D) -> Control:
	var stage := Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.modulate.a = 0.0

	var picture := TextureRect.new()
	picture.name = "Picture"
	picture.texture = texture
	picture.set_anchors_preset(Control.PRESET_FULL_RECT)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(picture)

	add_child(stage)
	return stage


## Sets up the animation for slide `index` (0-based) and returns how long
## the slide stays up, fade-in included.
func _animate_stage(index: int, stage: Control) -> float:
	if index == 0:
		return _animate_portal(stage)
	if index == 1:
		return _animate_void(stage)
	if index == 2:
		return _animate_city(stage)
	if index == 3:
		return _animate_hand(stage)
	return HOLD_TIME + FADE_TIME


## Scene 1: water running down the lens (with the sound of rain) while the camera creeps in on the
## portal; the portal's light then swells and washes the picture out to
## white, which carries us into the next scene. The white lives on the
## stage itself, so it stays up while the next picture fades in over it.
func _animate_portal(stage: Control) -> float:
	var size_px := get_viewport_rect().size
	var portal_px := PORTAL_FOCUS * size_px

	_add_lens_drips(PORTAL_TIME)

	var white := ColorRect.new()
	white.color = Color(1, 1, 1, 0)
	white.set_anchors_preset(Control.PRESET_FULL_RECT)
	white.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(white)

	# Toward the portal: zoom about it while sliding it to the middle.
	stage.pivot_offset = portal_px
	var tween := stage.create_tween().set_parallel(true)
	tween.tween_property(stage, "scale", Vector2.ONE * PORTAL_ZOOM, PORTAL_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(stage, "position", size_px / 2.0 - portal_px, PORTAL_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var white_start := PORTAL_TIME * PORTAL_WHITE_START
	tween.tween_property(white, "color:a", 1.0, PORTAL_TIME - white_start) \
			.set_delay(white_start).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# The rain, for as long as the scene lasts, fading out into the white.
	var rain := AudioManager.play_loop("rain", stage, RAIN_DB, 1.0)
	tween.tween_callback(func() -> void: AudioManager.stop_loop(rain, RAIN_FADE)) \
			.set_delay(maxf(PORTAL_TIME - RAIN_FADE, 0.0))
	return PORTAL_TIME


## Scene 2: the void inside the portal. Its purple breathes, the golden
## cracks pulse and glitter, the eyes glow, shards of rock drift up and
## sparks stream off the base - all in the shader and the particles, the
## picture itself never shakes. The camera creeps in toward the portal, and
## the light swells and washes everything out to white for the next scene.
func _animate_void(stage: Control) -> float:
	var picture: TextureRect = stage.get_node("Picture")
	var size_px := get_viewport_rect().size
	var portal_px := VOID_FOCUS * size_px

	var void_material := ShaderMaterial.new()
	void_material.shader = VOID_SHADER
	void_material.set_shader_parameter("aspect", size_px.x / size_px.y)
	picture.material = void_material

	var shards := _make_shards(size_px)
	var sparks := _make_sparks(size_px)
	var motes := _make_void_motes(size_px)
	stage.add_child(shards)
	stage.add_child(sparks)
	stage.add_child(motes)

	# Toward the portal: zoom about it while sliding it to the middle.
	stage.pivot_offset = portal_px
	var tween := stage.create_tween().set_parallel(true)
	tween.tween_property(stage, "scale", Vector2.ONE * VOID_ZOOM, VOID_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(stage, "position", size_px / 2.0 - portal_px, VOID_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# The white-out; the dark shards and the motes dissolve into it.
	var white_start := VOID_TIME * VOID_WHITE_START
	var white_time := VOID_TIME - white_start
	tween.tween_method(func(value: float) -> void: void_material.set_shader_parameter("white", value),
			0.0, 1.0, white_time).set_delay(white_start).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	for particles in [shards, sparks, motes]:
		tween.tween_property(particles, "modulate:a", 0.0, white_time * 0.4).set_delay(white_start)

	# Whispering voices and footsteps echoing as if from far down the void,
	# both for the whole scene, fading out into the white.
	var voices := AudioManager.play_loop("voices", stage, VOICES_DB, 1.0)
	var steps := AudioManager.play_loop("echoing_footsteps", stage, ECHO_STEPS_DB, 1.0)
	tween.tween_callback(func() -> void:
		AudioManager.stop_loop(voices, VOID_SOUND_FADE)
		AudioManager.stop_loop(steps, VOID_SOUND_FADE)).set_delay(maxf(VOID_TIME - VOID_SOUND_FADE, 0.0))
	return VOID_TIME


## Scene 3: the floating city under the torn sky. The waterfalls run, mist
## rolls, the eye glows and blinks, the sunset shimmers, lightning flickers
## along the cracks and debris drifts through the air - all in the shader and
## the particles. The camera stays where it is. The scene closes with the left
## bleeding out to white and black shadow tendrils creeping in from the right.
func _animate_city(stage: Control) -> float:
	var picture: TextureRect = stage.get_node("Picture")
	var size_px := get_viewport_rect().size

	var city_material := ShaderMaterial.new()
	city_material.shader = CITY_SHADER
	city_material.set_shader_parameter("aspect", size_px.x / size_px.y)
	picture.material = city_material

	var debris := _make_shards(size_px)
	debris.amount = 16
	debris.scale_amount_min = 0.15
	debris.scale_amount_max = 0.55
	debris.direction = Vector2(0.3, -1.0)
	debris.emission_rect_extents = size_px * Vector2(0.5, 0.45)
	var motes := _make_gold_motes(size_px)
	stage.add_child(debris)
	stage.add_child(motes)

	# The closing; the dark debris and the motes dissolve as it starts.
	var wipe_start := CITY_TIME * CITY_WIPE_START
	var wipe_time := CITY_TIME - wipe_start
	var tween := stage.create_tween().set_parallel(true)
	tween.tween_method(func(value: float) -> void: city_material.set_shader_parameter("wipe", value),
			0.0, 1.0, wipe_time).set_delay(wipe_start).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	for particles in [debris, motes]:
		tween.tween_property(particles, "modulate:a", 0.0, wipe_time * 0.4).set_delay(wipe_start)

	# The ground rumbling and a crowd in a panic, a little under it, for the
	# whole scene and fading out into the wipe.
	var rumble := AudioManager.play_loop("earthquake_rumble", stage, RUMBLE_DB, 1.0)
	var crowd := AudioManager.play_loop("crowd_panic", stage, CROWD_DB, 1.0)
	tween.tween_callback(func() -> void:
		AudioManager.stop_loop(rumble, CITY_SOUND_FADE)
		AudioManager.stop_loop(crowd, CITY_SOUND_FADE)).set_delay(maxf(CITY_TIME - CITY_SOUND_FADE, 0.0))
	return CITY_TIME


## Golden motes drifting in the sunset light on the left of the picture.
func _make_gold_motes(size_px: Vector2) -> CPUParticles2D:
	var life := Gradient.new()
	life.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	life.colors = PackedColorArray([
		Color(1.0, 0.85, 0.5, 0.0),
		Color(1.0, 0.85, 0.5, 0.85),
		Color(1.0, 0.8, 0.45, 0.7),
		Color(1.0, 0.75, 0.4, 0.0),
	])

	var motes := CPUParticles2D.new()
	motes.position = size_px * Vector2(0.28, 0.5)
	motes.texture = _glow_texture(16)
	motes.local_coords = true
	motes.amount = 50
	motes.lifetime = 6.0
	motes.lifetime_randomness = 0.5
	motes.preprocess = 6.0
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = size_px * Vector2(0.28, 0.45)
	motes.direction = Vector2(0.5, -1.0)
	motes.spread = 50.0
	motes.initial_velocity_min = 5.0
	motes.initial_velocity_max = 20.0
	motes.gravity = Vector2.ZERO
	motes.scale_amount_min = 0.2
	motes.scale_amount_max = 0.5
	motes.color_ramp = life
	motes.material = _additive()
	return motes


## Scene 4: the battlefield again, rain still falling. The same water on
## the lens as scene 1, and the rain sound. The picture itself is still; this
## is the last scene, so it ends in the fade to black that hands over to the
## game, and the drops and the rain stay until then.
func _animate_hand(stage: Control) -> float:
	var duration := HAND_TIME
	_add_lens_drips(duration + FADE_TIME)

	var rain := AudioManager.play_loop("rain", stage, HAND_RAIN_DB, 1.0)
	if rain != null:
		_fade_with_scene.append(rain)
	var tween := stage.create_tween()
	tween.tween_callback(func() -> void: AudioManager.stop_loop(rain, RAIN_FADE)) \
			.set_delay(maxf(duration + FADE_TIME - RAIN_FADE, 0.0))

	# Narration, with its subtitles shown while each line is spoken.
	var voice := AudioStreamPlayer.new()
	voice.stream = load(HAND_VOICE)
	voice.bus = "SFX"
	stage.add_child(voice)
	_fade_with_scene.append(voice)
	stage.create_tween().tween_callback(voice.play).set_delay(HAND_VOICE_DELAY)
	_play_subtitles(HAND_SUBTITLES, HAND_VOICE_DELAY)
	return duration


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


## Water on the lens: a full-screen overlay that bends the picture behind it
## (so it sits on the screen rather than in the scene, and doesn't zoom). It
## eases in over DRIPS_FADE_IN and is removed after `lifetime` seconds.
func _add_lens_drips(lifetime: float) -> void:
	var size_px := get_viewport_rect().size
	var drips := ColorRect.new()
	drips.set_anchors_preset(Control.PRESET_FULL_RECT)
	drips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var drips_material := ShaderMaterial.new()
	drips_material.shader = DRIPS_SHADER
	drips_material.set_shader_parameter("aspect", size_px.x / size_px.y)
	drips_material.set_shader_parameter("amount", 0.0)
	drips.material = drips_material
	add_child(drips)
	var drips_tween := drips.create_tween()
	drips_tween.tween_method(func(value: float) -> void: drips_material.set_shader_parameter("amount", value),
			0.0, 1.0, DRIPS_FADE_IN)
	drips_tween.tween_interval(maxf(lifetime - DRIPS_FADE_IN, 0.0))
	drips_tween.tween_callback(drips.queue_free)


## A soft round glow, the base texture of the sparks and motes.
func _glow_texture(size: int) -> GradientTexture2D:
	var glow := Gradient.new()
	glow.set_color(0, Color(1, 1, 1, 1))
	glow.set_color(1, Color(1, 1, 1, 0))
	var dot := GradientTexture2D.new()
	dot.gradient = glow
	dot.fill = GradientTexture2D.FILL_RADIAL
	dot.fill_from = Vector2(0.5, 0.5)
	dot.fill_to = Vector2(0.5, 0.0)
	dot.width = size
	dot.height = size
	return dot


func _additive() -> CanvasItemMaterial:
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return additive


## Golden sparks streaming up off the base of the portal.
func _make_sparks(size_px: Vector2) -> CPUParticles2D:
	var life := Gradient.new()
	life.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	life.colors = PackedColorArray([
		Color(1.0, 0.9, 0.5, 1.0),
		Color(1.0, 0.55, 0.15, 0.8),
		Color(0.8, 0.2, 0.05, 0.0),
	])
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(1.0, 0.2))

	var sparks := CPUParticles2D.new()
	sparks.position = SPARK_BASE * size_px
	sparks.texture = _glow_texture(16)
	sparks.local_coords = true
	sparks.amount = 110
	sparks.lifetime = 3.2
	sparks.lifetime_randomness = 0.5
	sparks.preprocess = 3.0
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparks.emission_rect_extents = Vector2(size_px.x * 0.13, 6.0)
	sparks.direction = Vector2(0, -1)
	sparks.spread = 28.0
	sparks.initial_velocity_min = 60.0
	sparks.initial_velocity_max = 190.0
	sparks.gravity = Vector2(0, -12)
	sparks.damping_min = 6.0
	sparks.damping_max = 18.0
	sparks.scale_amount_min = 0.2
	sparks.scale_amount_max = 0.6
	sparks.scale_amount_curve = shrink
	sparks.color_ramp = life
	sparks.material = _additive()
	return sparks


## Violet motes rising slowly through the void.
func _make_void_motes(size_px: Vector2) -> CPUParticles2D:
	var life := Gradient.new()
	life.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	life.colors = PackedColorArray([
		Color(0.8, 0.5, 1.0, 0.0),
		Color(0.8, 0.5, 1.0, 0.85),
		Color(0.7, 0.45, 1.0, 0.7),
		Color(0.7, 0.4, 1.0, 0.0),
	])

	var motes := CPUParticles2D.new()
	motes.position = size_px * Vector2(0.5, 0.48)
	motes.texture = _glow_texture(16)
	motes.local_coords = true
	motes.amount = 60
	motes.lifetime = 6.0
	motes.lifetime_randomness = 0.5
	motes.preprocess = 6.0
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = size_px * Vector2(0.11, 0.3)
	motes.direction = Vector2(0, -1)
	motes.spread = 40.0
	motes.initial_velocity_min = 6.0
	motes.initial_velocity_max = 22.0
	motes.gravity = Vector2.ZERO
	motes.scale_amount_min = 0.2
	motes.scale_amount_max = 0.55
	motes.color_ramp = life
	motes.material = _additive()
	return motes


## Rock shards hanging in the air and drifting slowly upward, each turning a
## little: dark stone with a gold edge, like the ones in the picture.
func _make_shards(size_px: Vector2) -> CPUParticles2D:
	var width := 24
	var height := 60
	var shard := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var half_w := width / 2.0
	for y in height:
		# A kite: widest a third of the way down, pointed at both ends.
		var along := (y + 0.5) / height
		var reach := (along / 0.33) if along < 0.33 else ((1.0 - along) / 0.67)
		var edge := half_w * reach
		for x in width:
			var dx := absf(x + 0.5 - half_w)
			if dx > edge:
				continue
			var rim := clampf(1.0 - (edge - dx) / 2.5, 0.0, 1.0)
			var stone := Color(0.16, 0.1, 0.06, 1.0)
			var gold := Color(1.0, 0.7, 0.25, 1.0)
			var shade := stone.lerp(gold, rim * 0.45)
			shade.a = 0.8 - 0.3 * rim
			shard.set_pixel(x, y, shade)

	var tint := Gradient.new()
	tint.offsets = PackedFloat32Array([0.0, 0.15, 0.85, 1.0])
	tint.colors = PackedColorArray([
		Color(1, 1, 1, 0.0),
		Color(1, 1, 1, 1.0),
		Color(1, 1, 1, 1.0),
		Color(1, 1, 1, 0.0),
	])

	var shards := CPUParticles2D.new()
	shards.position = size_px * 0.5
	shards.texture = ImageTexture.create_from_image(shard)
	shards.local_coords = true
	shards.amount = 12
	shards.lifetime = 9.0
	shards.lifetime_randomness = 0.4
	shards.preprocess = 9.0
	shards.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	shards.emission_rect_extents = size_px * Vector2(0.5, 0.4)
	shards.direction = Vector2(0, -1)
	shards.spread = 12.0
	shards.initial_velocity_min = 8.0
	shards.initial_velocity_max = 26.0
	shards.gravity = Vector2.ZERO
	shards.angle_min = -25.0
	shards.angle_max = 25.0
	shards.angular_velocity_min = -6.0
	shards.angular_velocity_max = 6.0
	shards.scale_amount_min = 0.25
	shards.scale_amount_max = 0.8
	shards.color_ramp = tint
	return shards


func _run() -> void:
	var front: Control = null
	var index := clampi(start_scene, 1, maxi(_textures.size(), 1)) - 1

	while index < _textures.size():
		if _skip_requested:
			break
		_advance_requested = false

		var stage := _make_stage(_textures[index])
		_fade.move_to_front()
		var duration := _animate_stage(index, stage)

		# The new slide fades in over the old one (rather than both fading
		# at once, which would dip to grey - and the old one ends white);
		# the very first fades up out of black.
		var fade_in := create_tween().set_parallel(true)
		if front != null:
			fade_in.tween_property(stage, "modulate:a", 1.0, FADE_TIME)
			fade_in.finished.connect(front.queue_free)
		else:
			stage.modulate.a = 1.0
			fade_in.tween_property(_fade, "color:a", 0.0, FIRST_FADE_IN_TIME)

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
	# Cut the narration and the rain with the fade, so a skip doesn't leave
	# them playing.
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
