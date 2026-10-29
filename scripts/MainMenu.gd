extends Control

func _ready() -> void:
	AudioManager.play_menu_music()
	$ButtonsContainer/NewPlayerButton.pressed.connect(_on_new_player_pressed)
	$ButtonsContainer/LoadButton.pressed.connect(_on_load_pressed)
	$SettingsButton.pressed.connect(func(): $SettingsPopup.open())
	# Tilting the phone (or moving the mouse) gives the art depth: the
	# painting drifts the most, its fog and embers a little less, the
	# buttons not at all (see TiltParallax).
	TiltParallax.attach(self, [[$Background, 1.0], [$MenuAtmosphere, 0.8]])

func _on_new_player_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Register.tscn")

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Load.tscn")
