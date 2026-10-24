extends Control

const EXPLANATION_TEXT := """Welcome to Echoes of the Forgotten

You are one of the Remembered - someone carrying an echo of the forgotten world. Pick a hero and a starting skill in a zone with a green dot. Some zones may have more than one hero in them.

Fight turn-based battles through each zone's stages. Each turn you can move, attack, cast a skill or use an item. Defeating enemies earns XP and gold - level up to grow stronger and spend gold at the Shop on the map.

Clear your home zone to unlock the rest of the world. Then find and challenge the other Remembered. Every hero you defeat gives you all the echoes they’ve gathered.

Your rivals are doing the same in the background, hunting echoes for their own ambition - check World Status on the map to follow them.

Gather enough echoes to open the final stage. There are many different available endings, try to find them all. You can check them in the "Achievements" in the main menu.

New here? Press Tutorial to learn it step by step.
"""


func _ready() -> void:
	AudioManager.play_menu_music()
	$TextPanel/Margin/ScrollContainer/ExplanationLabel.text = EXPLANATION_TEXT
	$BackButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/PostLogin.tscn"))
	$TutorialButton.pressed.connect(func(): TutorialManager.start_tutorial())
	_style_tutorial_button()


## Gives the Tutorial button the same warm, glowing treatment every
## forced button during the tutorial itself uses (see TutorialManager.
## make_glow_style()/start_glow_pulse()) - a slowly pulsing shadow
## rather than a static highlight, so it stands out from the wall of
## text next to it and keeps catching the eye instead of blending in
## once the player's looked at it once.
func _style_tutorial_button() -> void:
	var button: Button = $TutorialButton

	var normal_style: StyleBoxFlat = TutorialManager.make_glow_style()

	var hover_style: StyleBoxFlat = normal_style.duplicate()
	hover_style.bg_color = Color(0.5, 0.35, 0.08, 1.0)
	hover_style.shadow_size = 14

	var pressed_style: StyleBoxFlat = normal_style.duplicate()
	pressed_style.bg_color = Color(0.22, 0.14, 0.03, 1.0)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(1, 0.95, 0.8, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 0.9, 1))

	TutorialManager.start_glow_pulse(normal_style, self)
