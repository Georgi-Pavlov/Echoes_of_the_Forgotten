extends Control

## The story intro: plays once right after a new player registers (see
## Register.gd) and again any time from PostLogin's "Intro" button. Shows
## each scene's image while its narration plays, with the narrated lines as
## subtitles along the bottom, then burns the image away
## (shaders/intro_burn.gdshader) to reveal the next one. Each scene is drawn
## into its own SubViewport - the image plus that scene's animated effects
## (see IntroScene1FX.gd etc.) - and it's that whole picture that burns,
## so the effects burn away with the image instead of just vanishing. The next scene's
## narration (and its subtitles) starts a moment after the last one ends,
## while the fire is still burning, so the story never stalls. A scene
## with no narration yet types its text out instead and holds it for a
## reading pause. Tap/click/Space moves on to the next scene (or, mid-typing, just
## finishes the line); Skip (or Esc) leaves for PostLogin straight away.
## Told to the end, the story goes out in a flash of light straight off the
## last scene's finale, fading away over PostLogin (see _flash_out()).

const NEXT_SCENE := "res://scenes/PostLogin.tscn"
const BURN_SHADER := preload("res://shaders/intro_burn.gdshader")

## Each scene: its image, optionally "effects" - a script whose node is
## laid over the image while the scene is shown - then either
##   "audio" - the narration - plus "subtitles": [start, end, text] per
##   line, in seconds into the narration, shown while that line is spoken.
##   The last line's end is where the speech itself stops: the burn starts
##   right there, without waiting out the silence at the end of the file.
##   Two scenes can share one file: the second gives the same "audio" plus
##   "audio_from" - where in the file its part starts (in the pause before
##   its first line) - and its subtitles in seconds into the whole file.
##   The narration then runs straight on through the burn between them; it
##   only starts afresh from "audio_from" if the scene is reached any other
##   way (tapped to, started on, looped);
## or, until a scene has narration, "text" - typed out over the image.
const SCENES: Array[Dictionary] = [
	{
		"image": "res://assets/introduction/scene 1.jpg",
		"effects": "res://scripts/IntroScene1FX.gd",
		"audio": "res://assets/introduction/scene 1.mp3",
		"subtitles": [
			[0.1, 3.5, "No one remembers what this world was once called."],
			[4.7, 7.7, "We only know that it was not always like this."],
		],
	},
	{
		"image": "res://assets/introduction/scene 2.jpg",
		"effects": "res://scripts/IntroScene2FX.gd",
		"audio": "res://assets/introduction/scene 2.mp3",
		"subtitles": [
			[0.0, 3.4, "Once, this was a world of wonder."],
			[3.8, 9.5, "Mighty empires rose across the land, their cities reaching higher than the mountains."],
			[9.9, 15.0, "Magic flowed through their kingdoms, shaping stone, water and sky."],
		],
	},
	{
		"image": "res://assets/introduction/scene 3.jpg",
		"effects": "res://scripts/IntroScene3FX.gd",
		"audio": "res://assets/introduction/scene 3 and 4.mp3",
		"subtitles": [
			[0.0, 2.9, "Nature flourished beneath their hands."],
			[3.4, 10.5, "Forests stretched beyond the horizon, rivers ran clear, and life filled every corner of the land."],
			[10.8, 15.3, "Disease, hunger and hardship became little more than memories."],
			[15.9, 18.6, "There was only one thing they could not conquer."],
		],
	},
	{
		"image": "res://assets/introduction/scene 4.jpg",
		"effects": "res://scripts/IntroScene4FX.gd",
		"audio": "res://assets/introduction/scene 3 and 4.mp3",
		"audio_from": 19.6,
		"subtitles": [
			[19.9, 20.9, "Death."],
			[21.2, 24.5, "They sought a way beyond the limits of mortal flesh."],
			[24.9, 26.4, "And they found a door."],
			[26.8, 32.1, "Beyond it lay a realm where thought had weight, and will could shape reality."],
			[32.6, 36.3, "They believed they had found the power to become more than mortal."],
		],
	},
	{
		"image": "res://assets/introduction/scene 5.jpg",
		"effects": "res://scripts/IntroScene5FX.gd",
		"audio": "res://assets/introduction/scene 5.mp3",
		"subtitles": [
			[0.0, 4.5, "At first, the power gave them everything they desired."],
			[4.9, 6.5, "The sick were healed."],
			[6.6, 8.6, "The dying were restored."],
			[8.7, 11.8, "The limits of the flesh began to disappear."],
			[12.1, 15.2, "They had opened the way to another world."],
			[15.7, 18.2, "But nothing is ever that simple..."],
		],
	},
	{
		"image": "res://assets/introduction/scene 6.jpg",
		"effects": "res://scripts/IntroScene6FX.gd",
		"audio": "res://assets/introduction/scene 6.mp3",
		"subtitles": [
			[0.0, 3.8, "The newfound power completely overwhelmed them."],
			[4.1, 6.1, "It fed on their thoughts."],
			[6.3, 9.9, "On desire, fear ... hatred."],
			[10.1, 13.0, "It took the shape of those who wielded it."],
			[13.3, 18.3, "Their ambition became corruption, fears became flesh."],
			[18.6, 20.8, "And the world slowly changed."],
		],
	},
	{
		"image": "res://assets/introduction/scene 7.jpg",
		"effects": "res://scripts/IntroScene7FX.gd",
		"audio": "res://assets/introduction/scene 7.mp3",
		"subtitles": [
			[0.0, 2.1, "The old world is gone."],
			[2.4, 4.6, "Its rulers are forgotten."],
			[4.9, 6.7, "But its echoes remain."],
		],
	},
	{
		"image": "res://assets/introduction/scene 8.jpg",
		"effects": "res://scripts/IntroScene8FX.gd",
		"audio": "res://assets/introduction/scene 8.mp3",
		"subtitles": [
			[0.0, 3.5, "The Echoes call to your kind, the Remembered."],
			[3.8, 8.3, "Each one bringing another fragment of the past back into your mind."],
			[8.5, 14.1, "Some of you fight to protect what remains and preserve the last fragments of the old world."],
			[14.4, 17.7, "Some seek to cleanse the corruption that consumed it."],
			[17.9, 21.5, "And some simply seek the power to rule it."],
			[21.8, 25.1, "Whatever your reason, the path is the same."],
			[25.4, 27.7, "Walk the ruins of this world."],
			[27.9, 29.9, "Fight your way to the throne."],
			[30.0, 32.8, "And become the new lord of the FORGOTTEN realm."],
		],
	},
]

const FADE_IN_TIME := 1.5
const FADE_OUT_TIME := 1.2
const SKIP_FADE_TIME := 0.4
const BURN_TIME := 2.4
const TEXT_FADE_TIME := 0.4
const SUBTITLE_FADE_TIME := 0.25
## Pause before scene 1's narration starts, so the image has mostly faded
## in from black first.
const FIRST_VOICE_DELAY := 0.8
## When the last line has been spoken, the story ends on the last scene's
## finale (IntroScene8FX.gd) at its height: a beat for the line to land,
## then a flash of light that swells over the scene, holds while the menu
## loads underneath it, and fades away there.
const FINAL_HOLD_TIME := 0.3
const FLASH_COLOR := Color(1.0, 0.84, 0.68)
const FLASH_IN_TIME := 0.5
const FLASH_HOLD_TIME := 0.15
const FLASH_OUT_TIME := 1.4
## How long after one scene's narration ends (and its burn starts) the
## next scene's narration begins - partway through the burn, not after it.
const NEXT_VOICE_DELAY := 1.0
## How fast a narration cut short by a tap fades out.
const VOICE_CUT_FADE_TIME := 0.5
## Typing speed, and how long a finished line stays up before the burn
## starts on its own - a base plus a little per character, so longer
## lines get more reading time.
const SECONDS_PER_CHAR := 0.035
const HOLD_BASE_TIME := 2.5
const HOLD_PER_CHAR := 0.04

## WAITING: between one scene's narration and the next's.
enum Phase { NARRATING, TYPING, HOLDING, WAITING, DONE }

signal burn_finished

## Testing aids, set on the Intro node in the editor (then F6 to run just
## this scene) or from the command line:
##   godot --path . res://scenes/Intro.tscn -- --intro-scene=3 --intro-loop
## Which scene (1-8) the intro starts at.
@export_range(1, 8) var start_scene := 1
## Keep replaying start_scene - narration, effects and its burn (into
## itself) - instead of moving on, to look at one scene's effects.
@export var loop_scene := false

@onready var _image_holder: Control = $ImageHolder
@onready var _story_label: Label = $StoryLabel
@onready var _fade: ColorRect = $Fade
@onready var _skip_button: Button = $SkipButton

## The two on-screen images, each showing its own scene viewport: the
## front one is the scene being shown (and, during a transition, burning
## away); the back one holds the scene coming up underneath it.
var _front: TextureRect
var _back: TextureRect
var _voice: AudioStreamPlayer
var _voice_tween: Tween
var _burning := false
var _text_tween: Tween
var _index := 0
var _phase := Phase.TYPING
## Bumped every time a hold timer starts, so a timer left over from a line
## the player already tapped past can tell it's stale and do nothing.
var _hold_token := 0
## Which of the current scene's subtitles is on screen (-1 = none).
var _subtitle_index := -1


func _ready() -> void:
	_front = $ImageHolder/ImageA
	_back = $ImageHolder/ImageB
	for rect in [_front, _back]:
		var mat := ShaderMaterial.new()
		mat.shader = BURN_SHADER
		rect.material = mat
		var view := _make_scene_view()
		rect.texture = view.get_texture()
		rect.set_meta("view", view)

	_voice = AudioStreamPlayer.new()
	_voice.bus = "SFX"
	_voice.finished.connect(_on_voice_finished)
	add_child(_voice)

	_skip_button.pressed.connect(func(): _finish(SKIP_FADE_TIME))

	_story_label.text = ""
	_fade.color.a = 1.0
	_read_test_args()
	_index = clampi(start_scene, 1, SCENES.size()) - 1
	_show_image(_front, _index)
	_back.visible = false
	create_tween().tween_property(_fade, "color:a", 0.0, FADE_IN_TIME)
	_play_scene(FIRST_VOICE_DELAY)


func _process(_delta: float) -> void:
	if _phase == Phase.NARRATING and _voice.playing:
		var time := _voice.get_playback_position() + AudioServer.get_time_since_last_mix()
		var subtitles: Array = SCENES[_index]["subtitles"]
		if time >= subtitles[-1][1]:
			_next_scene(true)
		else:
			_update_subtitle(time)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_finish(SKIP_FADE_TIME)
	elif event.is_action_pressed("ui_accept"):
		_advance()
	else:
		return
	get_viewport().set_input_as_handled()


## Tap: finish the line being typed, or burn on to the next scene -
## cutting the narration short if it's still going. Taps mid-burn are
## ignored.
func _advance() -> void:
	if _burning:
		return
	match _phase:
		Phase.TYPING:
			if _text_tween:
				_text_tween.kill()
			_story_label.visible_ratio = 1.0
			_hold(HOLD_BASE_TIME + _story_label.text.length() * HOLD_PER_CHAR)
		Phase.NARRATING, Phase.HOLDING:
			_next_scene()


func _play_scene(voice_delay := 0.0) -> void:
	var scene: Dictionary = SCENES[_index]
	if not scene.has("audio"):
		_type_text(scene["text"])
		return

	_phase = Phase.NARRATING
	_subtitle_index = -1
	_story_label.text = ""
	_story_label.visible_ratio = 1.0
	# Already playing on into this scene's part of a shared file.
	if _voice_runs_into(_index):
		return
	if _voice_tween:
		_voice_tween.kill()
	_voice.volume_db = 0.0
	_voice.stream = load(scene["audio"])
	if voice_delay > 0.0:
		await get_tree().create_timer(voice_delay).timeout
		if _phase != Phase.NARRATING:
			return
	_voice.play(scene.get("audio_from", 0.0))


## Whether the narration playing now is the previous scene's part of a
## file scene `index` shares with it, nearly through to where scene
## `index`'s part starts - so it can just play on into it.
func _voice_runs_into(index: int) -> bool:
	var scene: Dictionary = SCENES[index]
	if not scene.has("audio_from") or not _voice.playing or _voice.stream == null:
		return false
	if _voice.stream.resource_path != scene["audio"]:
		return false
	var position := _voice.get_playback_position()
	return position >= scene["audio_from"] - 2.0 and position <= scene["audio_from"] + 0.3


## Shows whichever subtitle line covers `time` (seconds into the
## narration), fading lines in and out as they change.
func _update_subtitle(time: float) -> void:
	var subtitles: Array = SCENES[_index]["subtitles"]
	var current := -1
	for i in subtitles.size():
		if time >= subtitles[i][0] and time < subtitles[i][1]:
			current = i
			break
	if current == _subtitle_index:
		return
	_subtitle_index = current

	if _text_tween:
		_text_tween.kill()
	var showing := _story_label.modulate.a > 0.0 and _story_label.text != ""
	if current == -1 and not showing:
		return
	_text_tween = create_tween()
	if showing:
		_text_tween.tween_property(_story_label, "modulate:a", 0.0, SUBTITLE_FADE_TIME)
	if current == -1:
		return
	_text_tween.tween_callback(func(): _story_label.text = subtitles[current][2])
	_text_tween.tween_property(_story_label, "modulate:a", 1.0, SUBTITLE_FADE_TIME)


func _on_voice_finished() -> void:
	if _phase != Phase.NARRATING:
		return
	# Only reached if the last subtitle runs past the end of the file -
	# normally _process() starts the burn when the speech stops.
	_next_scene(true)


func _type_text(text: String) -> void:
	_phase = Phase.TYPING
	_story_label.text = text
	_story_label.visible_ratio = 0.0
	_story_label.modulate.a = 1.0
	_text_tween = create_tween()
	_text_tween.tween_property(_story_label, "visible_ratio", 1.0, text.length() * SECONDS_PER_CHAR)
	_text_tween.tween_callback(func(): _hold(HOLD_BASE_TIME + text.length() * HOLD_PER_CHAR))


func _hold(duration: float) -> void:
	_phase = Phase.HOLDING
	_hold_token += 1
	var token := _hold_token
	await get_tree().create_timer(duration).timeout
	if token == _hold_token and _phase == Phase.HOLDING:
		_next_scene()


## Moves on from the current scene - `ended` when its narration has run
## to the end, rather than the player tapping past it.
func _next_scene(ended := false) -> void:
	if _index + 1 >= SCENES.size() and not loop_scene:
		# The story told to the end goes out in a flash; tapped past, it
		# just fades to black.
		if not ended:
			_finish(FADE_OUT_TIME)
			return
		_phase = Phase.WAITING
		await get_tree().create_timer(FINAL_HOLD_TIME).timeout
		_flash_out()
		return
	# Narration shorter than a burn could end before the last burn does -
	# let that one finish before starting the next.
	while _burning:
		await burn_finished
	if _phase == Phase.DONE:
		return

	_phase = Phase.WAITING
	if not loop_scene:
		_index += 1
	if _text_tween:
		_text_tween.kill()
	create_tween().tween_property(_story_label, "modulate:a", 0.0, TEXT_FADE_TIME)
	if not _voice_runs_into(_index):
		_cut_voice(VOICE_CUT_FADE_TIME)
	_burn_to(_index)

	await get_tree().create_timer(NEXT_VOICE_DELAY).timeout
	if _phase == Phase.WAITING:
		_play_scene()


## Burns the image on screen away to reveal scene `index`'s underneath.
func _burn_to(index: int) -> void:
	_burning = true
	_show_image(_back, index)
	_back.visible = true

	var mat: ShaderMaterial = _front.material
	mat.set_shader_parameter("aspect", _front.size.x / _front.size.y)
	mat.set_shader_parameter("origin", Vector2(randf_range(0.25, 0.75), randf_range(0.3, 0.8)))
	mat.set_shader_parameter("seed", randf() * 10.0)
	mat.set_shader_parameter("progress", 0.0)

	var burn := create_tween()
	burn.tween_method(func(p: float): mat.set_shader_parameter("progress", p), 0.0, 1.0, BURN_TIME) 		.set_trans(Tween.TRANS_LINEAR)
	await burn.finished

	# The burned-away image drops to the back, ready to take the scene
	# after this one.
	_image_holder.move_child(_front, 0)
	_front.visible = false
	var old := _front
	_front = _back
	_back = old
	_burning = false
	burn_finished.emit()


## Picks up --intro-scene=N and --intro-loop from the command line (after
## a bare "--"), overriding start_scene/loop_scene.
func _read_test_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--intro-scene="):
			start_scene = arg.get_slice("=", 1).to_int()
		elif arg == "--intro-loop":
			loop_scene = true


## An offscreen viewport the size of the screen (rendered at the window's
## real resolution, laid out at the game's 1280x720) holding a scene's
## image and, while that scene is shown, its effects.
func _make_scene_view() -> SubViewport:
	var base := get_viewport_rect().size
	var view := SubViewport.new()
	view.disable_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.size = Vector2i(base * get_viewport().get_final_transform().get_scale())
	view.size_2d_override = Vector2i(base)
	view.size_2d_override_stretch = true
	add_child(view)

	var image := TextureRect.new()
	image.name = "Image"
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	view.add_child(image)
	return view


## Loads scene `index` into `rect`'s viewport: its image, and its effects
## in place of the previous scene's (which go with it).
func _show_image(rect: TextureRect, index: int) -> void:
	var view: SubViewport = rect.get_meta("view")
	(view.get_node("Image") as TextureRect).texture = load(SCENES[index]["image"])
	var old_fx := view.get_node_or_null("Effects")
	if old_fx:
		view.remove_child(old_fx)
		old_fx.queue_free()
	if SCENES[index].has("effects"):
		var fx: Control = load(SCENES[index]["effects"]).new()
		fx.name = "Effects"
		view.add_child(fx)
	(rect.material as ShaderMaterial).set_shader_parameter("progress", 0.0)


## Fades out narration that's still playing (a tap or Skip cut it short)
## rather than stopping it dead mid-word.
func _cut_voice(fade_time: float) -> void:
	if not _voice.playing:
		return
	if _voice_tween:
		_voice_tween.kill()
	_voice_tween = create_tween()
	_voice_tween.tween_property(_voice, "volume_db", -60.0, fade_time)
	_voice_tween.tween_callback(_voice.stop)


func _finish(fade_time: float) -> void:
	if _phase == Phase.DONE:
		return
	_phase = Phase.DONE
	_skip_button.disabled = true
	_cut_voice(fade_time)
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, fade_time)
	await tween.finished
	get_tree().change_scene_to_file(NEXT_SCENE)


## Ends the story in a flash of light (see FLASH_COLOR): it swells over the
## scene, the menu loads underneath it, and it fades away over the menu.
## The flash lives on the root viewport rather than in this scene, so it
## outlasts the scene change, and frees itself once it's gone.
func _flash_out() -> void:
	if _phase == Phase.DONE:
		return
	_phase = Phase.DONE
	_skip_button.disabled = true
	_cut_voice(FLASH_IN_TIME)

	var layer := CanvasLayer.new()
	layer.layer = 128
	var flash := ColorRect.new()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(FLASH_COLOR, 0.0)
	layer.add_child(flash)
	get_tree().root.add_child(layer)

	var tree := get_tree()
	var tween := layer.create_tween()
	tween.tween_property(flash, "color:a", 1.0, FLASH_IN_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): tree.change_scene_to_file(NEXT_SCENE))
	tween.tween_interval(FLASH_HOLD_TIME)
	tween.tween_property(flash, "color:a", 0.0, FLASH_OUT_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(layer.queue_free)
