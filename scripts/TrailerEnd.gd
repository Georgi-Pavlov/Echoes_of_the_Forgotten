extends Control

## Trailer capture (see Trailer.gd): the closing screenshots, one after another
## with the menu music underneath, ending on the menu with the camera pushing
## in on the game title, then a fade to black and quit.

const FOLDER := "res://assets/trailer/"
const SHOTS: Array[String] = ["ss4.webp", "ss2.webp", "ss3.webp", "ss1.webp"]
const HOLD_TIME := 3.5
const FADE_TIME := 0.8
const START_FADE := 1.0
const END_FADE := 1.5

# The last shot is the menu: the title's centre (UV), how far the camera
# pushes in on it, how long it holds before the push starts, and how long
# the shot stays up.
const TITLE_FOCUS := Vector2(0.48, 0.2)
const TITLE_ZOOM := 1.8
const TITLE_HOLD_TIME := 9.0
const TITLE_ZOOM_DELAY := 2.5


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	AudioManager.play_menu_music(START_FADE)
	_run()


func _make_shot(file_name: String) -> TextureRect:
	var shot := TextureRect.new()
	shot.texture = load(FOLDER + file_name)
	shot.set_anchors_preset(Control.PRESET_FULL_RECT)
	shot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	shot.modulate.a = 0.0
	add_child(shot)
	return shot


## Toward the title: zoom about it while sliding it to the middle.
func _push_in_on_title(shot: TextureRect, duration: float) -> void:
	var size_px := get_viewport_rect().size
	var title_px := TITLE_FOCUS * size_px
	shot.pivot_offset = title_px
	var tween := shot.create_tween().set_parallel(true)
	tween.tween_property(shot, "scale", Vector2.ONE * TITLE_ZOOM, duration) \
			.set_delay(TITLE_ZOOM_DELAY).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(shot, "position", size_px / 2.0 - title_px, duration) \
			.set_delay(TITLE_ZOOM_DELAY).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _run() -> void:
	var front: TextureRect = null
	for file_name in SHOTS:
		var shot := _make_shot(file_name)
		var fade_in := create_tween()
		fade_in.tween_property(shot, "modulate:a", 1.0, START_FADE if front == null else FADE_TIME)
		if front != null:
			fade_in.finished.connect(front.queue_free)
		var hold := HOLD_TIME
		if file_name == SHOTS[-1]:
			hold = TITLE_HOLD_TIME
			_push_in_on_title(shot, hold + END_FADE - TITLE_ZOOM_DELAY)
		await get_tree().create_timer(hold).timeout
		front = shot

	AudioManager.stop_music_fade(END_FADE)
	var out := create_tween()
	out.tween_property(front, "modulate:a", 0.0, END_FADE)
	await out.finished
	get_tree().quit()
