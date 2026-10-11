extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

const SFX_PLAYER_COUNT := 16

# A button with this meta set to true makes no generic click when pressed
# (it plays its own sound instead - see the Shop's Buy and Sell buttons).
const NO_CLICK_META := "no_click_sound"

# Sound effects are played by EVENT NAME (see SfxSynth.EVENTS). Each event
# is generated in code by default; to use a real recording instead, drop a
# file called <event>.ogg / .wav / .mp3 into this folder - it is picked up
# automatically, no code change needed (see assets/sounds/README.md).
const SOUND_DIR := "res://assets/sounds/"
const SOUND_EXTENSIONS := ["ogg", "wav", "mp3"]
const MENU_MUSIC := "menu_music"

# Events with no sound of their own play another event's instead (so a
# single recording can serve both until a second one is added).
const EVENT_FALLBACKS := {
	"bear_summon": "bear_attack", "button": "ui_click",
	"raze_shoot": "shotgun", "kiss_the_wastes": "napalm_shot", "reload": "ui_click",
}

# event name -> AudioStream (file or generated), built on first use.
var _event_cache: Dictionary = {}
var _prewarm_queue: Array = []
var _music_tween: Tween
var _music_fading_out := false


func _ready() -> void:

	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

	# SFX players
	for i in range(SFX_PLAYER_COUNT):

		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer" + str(i)
		player.bus = "SFX"

		add_child(player)
		sfx_players.append(player)

	# Every button in the game clicks, without each scene having to ask.
	get_tree().node_added.connect(_on_node_added)

	# Generate the built-in sounds a few per frame, so no sound ever has to
	# be built in the middle of a fight.
	_prewarm_queue = SfxSynth.EVENTS.keys()
	set_process(true)


func _process(_delta: float) -> void:
	if _prewarm_queue.is_empty():
		set_process(false)
		return
	_stream_for(_prewarm_queue.pop_back())


func play_music(stream: AudioStream) -> void:
	_kill_music_tween()
	music_player.volume_db = 0.0

	if music_player.stream == stream and music_player.playing:
		return

	music_player.stream = stream
	music_player.play()


## The menu music: starts (fading in) the first time it's asked for and
## then simply keeps playing - every menu screen calls this on entering,
## and calling it while it already plays does nothing, so changing screens
## never restarts it. Replace assets/sounds/menu_music.(mp3|ogg|wav) to
## change the track.
func play_menu_music(fade_in: float = 1.5) -> void:
	var stream := _music_file(MENU_MUSIC)
	if stream == null:
		return
	if music_player.stream == stream and music_player.playing and not _music_fading_out:
		return
	if "loop" in stream:
		stream.loop = true
	_kill_music_tween()
	music_player.stream = stream
	music_player.volume_db = -40.0
	music_player.play()
	_music_tween = create_tween()
	_music_tween.tween_property(music_player, "volume_db", 0.0, fade_in)


## Stops the music, fading it out over `fade_out` seconds (0 = at once).
func stop_music_fade(fade_out: float = 0.8) -> void:
	if not music_player.playing:
		return
	_kill_music_tween()
	if fade_out <= 0.0:
		music_player.stop()
		music_player.volume_db = 0.0
		return
	_music_fading_out = true
	_music_tween = create_tween()
	_music_tween.tween_property(music_player, "volume_db", -40.0, fade_out)
	_music_tween.tween_callback(func() -> void:
		music_player.stop()
		music_player.volume_db = 0.0
		_music_fading_out = false)


func _kill_music_tween() -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_fading_out = false


func _music_file(base_name: String) -> AudioStream:
	for ext in SOUND_EXTENSIONS:
		var path: String = SOUND_DIR + base_name + "." + ext
		if ResourceLoader.exists(path):
			return load(path)
	return null


func stop_music() -> void:
	music_player.stop()


func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:

	for player in sfx_players:

		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch_scale
			player.play()
			return


# When (in seconds of engine time) the latest attack sound will have
# finished playing.
var _attack_sound_until := 0.0
const MAX_DEATH_WAIT := 1.5


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


func note_attack_sound(event: String, length: float) -> void:
	if SfxSynth.ATTACK_EVENTS.has(event):
		_attack_sound_until = maxf(_attack_sound_until, _now() + length)


## Seconds until the attack sound(s) now playing have finished (capped at
## MAX_DEATH_WAIT) - how long a death must hold off so the blow is heard
## first, then the death animation and its sound play together.
func attack_wait() -> float:
	return clampf(_attack_sound_until - _now(), 0.0, MAX_DEATH_WAIT)


## Plays `event` once the attack sound(s) already playing have finished -
## for a death sound, so the blow is heard first and the death after it.
## Waits at most MAX_DEATH_WAIT seconds, however long the attack clip is.
func play_event_after_attacks(event: String, volume_db: float = 0.0) -> void:
	var wait: float = attack_wait()
	if wait <= 0.02:
		play_event(event, volume_db)
		return
	get_tree().create_timer(wait).timeout.connect(func() -> void: play_event(event, volume_db))


## Plays the sound for `event` (a SfxSynth.EVENTS key, or the name of any
## file in res://assets/sounds/). `volume_db` is added to the event's own
## default level; `pitch_variation` randomizes the pitch a little (0.06 =
## up to 6% either way) so repeated sounds don't sound identical.
func play_event(event: String, volume_db: float = 0.0, pitch_variation: float = 0.05) -> void:
	var stream := _stream_for(event)
	if stream == null:
		return
	var level: float = SfxSynth.EVENTS.get(event, 0.0) + volume_db
	var pitch := 1.0 + randf_range(-pitch_variation, pitch_variation)
	note_attack_sound(event, stream.get_length() / pitch)
	play_sfx(stream, level, pitch)


## Plays `event` once, but cuts it off after `seconds` (fading out over
## `fade_out`) - for a sound that must end with the effect it belongs to
## even if the clip itself is longer. A clip shorter than that just ends.
func play_event_for(event: String, seconds: float, fade_out: float = 0.15, volume_db: float = 0.0) -> void:
	var stream := _stream_for(event)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "SFX"
	player.volume_db = SfxSynth.EVENTS.get(event, 0.0) + volume_db
	player.pitch_scale = 1.0 + randf_range(-0.04, 0.04)
	add_child(player)
	note_attack_sound(event, minf(seconds, stream.get_length()))
	player.finished.connect(player.queue_free)
	player.play()
	var tween := player.create_tween()
	tween.tween_interval(maxf(seconds - fade_out, 0.0))
	tween.tween_property(player, "volume_db", -40.0, fade_out)
	tween.tween_callback(player.queue_free)


## How long the sound for `event` lasts, in seconds (0 if there is none).
func event_length(event: String) -> float:
	var stream := _stream_for(event)
	return stream.get_length() if stream != null else 0.0


## Starts `event` playing in a loop under `parent` (the sound ends with it
## if `parent` is freed) and returns its player - hand it to stop_loop().
## For sounds that last as long as something burns or hovers. Fades in over
## `fade_in` seconds.
func play_loop(event: String, parent: Node, volume_db: float = 0.0, fade_in: float = 0.2) -> AudioStreamPlayer:
	var stream := _stream_for(event)
	if stream == null or parent == null:
		return null
	# Loop a copy, so the shared cached sound stays one-shot for play_event().
	var looped: AudioStream = stream.duplicate()
	if looped is AudioStreamWAV:
		looped.loop_mode = AudioStreamWAV.LOOP_FORWARD
		looped.loop_begin = 0
		looped.loop_end = looped.data.size() / 2
	elif "loop" in looped:
		looped.loop = true
	var player := AudioStreamPlayer.new()
	player.stream = looped
	player.bus = "SFX"
	var level: float = SfxSynth.EVENTS.get(event, 0.0) + volume_db
	player.volume_db = -40.0
	parent.add_child(player)
	player.play()
	player.create_tween().tween_property(player, "volume_db", level, fade_in)
	return player


## Fades out and frees a loop started with play_loop().
func stop_loop(player: Variant, fade_out: float = 0.5) -> void:
	if player == null or not is_instance_valid(player):
		return
	var tween: Tween = player.create_tween()
	tween.tween_property(player, "volume_db", -40.0, fade_out)
	tween.tween_callback(player.queue_free)


## The stream for `event`: a file from SOUND_DIR if one exists, otherwise
## the generated sound. Cached.
func _stream_for(event: String) -> AudioStream:
	if _event_cache.has(event):
		return _event_cache[event]
	var stream: AudioStream = null
	for ext in SOUND_EXTENSIONS:
		var path: String = SOUND_DIR + event + "." + ext
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	if stream == null:
		stream = SfxSynth.make(event)
	# A file-only event with no file of its own borrows its fallback's.
	if stream == null and EVENT_FALLBACKS.has(event):
		stream = _stream_for(EVENT_FALLBACKS[event])
	_event_cache[event] = stream
	return stream


func _on_node_added(node: Node) -> void:
	if node is BaseButton and not node.pressed.is_connected(_on_button_pressed.bind(node)):
		node.pressed.connect(_on_button_pressed.bind(node))


func _on_button_pressed(button: BaseButton) -> void:
	if is_instance_valid(button) and button.get_meta(NO_CLICK_META, false):
		return
	play_event("button")
