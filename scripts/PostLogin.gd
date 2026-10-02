extends Control

@onready var confirm_popup: PanelContainer = $ConfirmNewGamePopup
@onready var confirm_ok_button: Button = $ConfirmNewGamePopup/ConfirmMargin/ConfirmVBox/ConfirmButtons/ConfirmOkButton
@onready var confirm_cancel_button: Button = $ConfirmNewGamePopup/ConfirmMargin/ConfirmVBox/ConfirmButtons/ConfirmCancelButton

func _ready() -> void:
	$WelcomeLabel.text = "Welcome, " + PlayerManager.current_player
	$ButtonsContainer/NewGameButton.pressed.connect(_on_new_game_pressed)
	$ButtonsContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$ButtonsContainer/ExtraButtons/HighScoresButton.pressed.connect(_on_high_scores_pressed)
	$ButtonsContainer/ExtraButtons/HowToPlayButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/HowToPlay.tscn"))
	$ButtonsContainer/ExtraButtons/IntroButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Intro.tscn"))
	$LogOutButton.pressed.connect(_on_log_out_pressed)
	confirm_ok_button.pressed.connect(_on_confirm_new_game_ok)
	confirm_cancel_button.pressed.connect(_on_confirm_new_game_cancel)
	$SettingsButton.pressed.connect(func(): $SettingsPopup.open())

	# Nothing to continue if no hero has been recruited yet, or the
	# current one has died - in both cases only New Game makes sense.
	var recruited: Dictionary = PlayerManager.get_recruited_hero()
	var continue_button: Button = $ButtonsContainer/ContinueButton
	continue_button.disabled = recruited.is_empty() or recruited.get("current_hp", 0) <= 0
	# When there's nothing to continue it should read as unavailable, not
	# vanish - the default disabled look nearly disappears over the art.
	var disabled_style := StyleBoxFlat.new()
	disabled_style.bg_color = Color(0.08, 0.08, 0.1, 0.7)
	disabled_style.border_color = Color(0.4, 0.4, 0.42, 0.6)
	disabled_style.set_border_width_all(1)
	disabled_style.set_corner_radius_all(6)
	continue_button.add_theme_stylebox_override("disabled", disabled_style)
	continue_button.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.62, 1))

func _on_new_game_pressed() -> void:
	# A brand-new player's first New Game runs the tutorial instead, then
	# carries on into the real game (the map) when it's over.
	if PlayerManager.is_tutorial_pending():
		PlayerManager.clear_tutorial_pending()
		TutorialManager.start_tutorial("res://scenes/Map.tscn")
		return

	var recruited: Dictionary = PlayerManager.get_recruited_hero()

	# Only warn if there's an actual hero with progress to lose. If no
	# hero has been recruited yet, or the current one has already
	# died, there's nothing at stake - just start fresh directly.
	if not recruited.is_empty() and recruited.get("current_hp", 0) > 0:
		confirm_popup.visible = true
		return

	_start_new_game()

func _on_confirm_new_game_ok() -> void:
	confirm_popup.visible = false
	_start_new_game()

func _on_confirm_new_game_cancel() -> void:
	confirm_popup.visible = false

func _start_new_game() -> void:
	PlayerManager.clear_recruited_hero()
	get_tree().change_scene_to_file("res://scenes/Map.tscn")

func _on_continue_pressed() -> void:
	# The current hero and all their stats live in the player's save
	# file already (PlayerManager persists everything as it happens),
	# so continuing just means going back to the map - Zone.tscn's
	# existing hero-lock check picks the rest up automatically.
	get_tree().change_scene_to_file("res://scenes/Map.tscn")

func _on_log_out_pressed() -> void:
	# Clearing the current player saves anything they had pending (see
	# PlayerManager.current_player's setter).
	PlayerManager.current_player = ""
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_high_scores_pressed() -> void:
	# TODO: high score screen goes here - PlayerManager.get_high_score()
	# already has the data ready for it.
	print("High Scores - coming soon")
