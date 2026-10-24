extends Control

func _ready() -> void:
	AudioManager.play_menu_music()
	$ButtonsContainer/NewPlayerButton.pressed.connect(_on_new_player_pressed)
	$ButtonsContainer/LogInButton.pressed.connect(_on_log_in_pressed)
	$ButtonsContainer/AchievementsButton.pressed.connect(_on_achievements_pressed)
	$SettingsButton.pressed.connect(func(): $SettingsPopup.open())
	# Tilting the phone (or moving the mouse) gives the art depth: the
	# painting drifts the most, its fog and embers a little less, the
	# buttons not at all (see TiltParallax).
	TiltParallax.attach(self, [[$Background, 1.0], [$MenuAtmosphere, 0.8]])

func _on_new_player_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Register.tscn")

func _on_log_in_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Login.tscn")

func _on_achievements_pressed() -> void:
	Achievements.open(get_tree(), "res://scenes/MainMenu.tscn")
