extends Control

@onready var name_edit: LineEdit = $Panel/VBoxContainer/NameEdit
@onready var error_label: Label = $Panel/VBoxContainer/ErrorLabel

func _ready() -> void:
	AudioManager.play_menu_music()
	$Panel/VBoxContainer/HBoxContainer/SubmitButton.pressed.connect(_on_submit_pressed)
	$Panel/VBoxContainer/HBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	name_edit.text_submitted.connect(func(_text: String): _on_submit_pressed())

func _on_submit_pressed() -> void:
	var username := name_edit.text.strip_edges()

	if username == "":
		error_label.text = "Name cannot be empty."
		return
	if username.contains("|") or username.contains("/") or username.contains("\\") or username.contains(":"):
		error_label.text = "Name cannot contain | / \\ or :"
		return
	if PlayerManager.player_exists(username):
		error_label.text = "That name is already registered."
		return

	PlayerManager.register_player(username)
	PlayerManager.current_player = username
	# A brand-new player sees the story intro first; it moves on to
	# PostLogin by itself when it ends or is skipped.
	# The intro has its own narration - the menu music ends here.
	AudioManager.stop_music_fade()
	get_tree().change_scene_to_file("res://scenes/Intro.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
