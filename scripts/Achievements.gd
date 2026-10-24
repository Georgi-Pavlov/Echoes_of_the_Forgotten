class_name Achievements
extends Control

## Every ending of the demo with a stamp beside the ones the player has
## reached (see Endings.gd and PlayerManager.get_achievements()), then the
## achievements that aren't endings (FEATS). Reached from the main menu and
## the post-login menu, which say where Back goes.

const MAIN_MENU := "res://scenes/MainMenu.tscn"

# Achievements that aren't endings: earned mid-run, the run carries on.
# Stored alongside the endings (PlayerManager.add_achievement()).
const NOT_IN_MY_REALM := "not_in_my_realm"     # killed a rival who invaded the player

const FEATS: Array[String] = [NOT_IN_MY_REALM]
const FEAT_NAMES := {
	NOT_IN_MY_REALM: "Not in My Realm",
}


static func feat_title(feat_id: String) -> String:
	return FEAT_NAMES.get(feat_id, feat_id)

## Where Back leads - set by whoever opens this screen.
static var return_scene := MAIN_MENU

const GOLD := Color(1, 0.85, 0.4)
const STAMP_RED := Color(0.82, 0.16, 0.12)


## Opens the Achievements screen from `from_scene`'s menu, and remembers to
## go back there.
static func open(tree: SceneTree, back_to: String) -> void:
	return_scene = back_to
	tree.change_scene_to_file("res://scenes/Achievements.tscn")


func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color(0.06, 0.06, 0.08, 1)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var title := Label.new()
	title.text = "Achievements"
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20.0
	title.offset_bottom = 60.0
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title.add_theme_constant_override("outline_size", 3)
	title.add_theme_font_size_override("font_size", 28)
	add_child(title)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.15
	panel.anchor_top = 0.12
	panel.anchor_right = 0.85
	panel.anchor_bottom = 0.9
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.55)
	panel_style.border_color = Color(1, 1, 1, 0.25)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 22)
	panel.add_child(margin)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 18)
	margin.add_child(list)

	var earned: Array = PlayerManager.get_achievements()
	var reached := 0
	for ending_id in Endings.ORDER:
		var achieved: bool = ending_id in earned
		if achieved:
			reached += 1
		list.add_child(_build_row("%d.  %s" % [Endings.number(ending_id), Endings.title(ending_id)], achieved))

	# The achievements that aren't endings, set a little apart below them.
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	list.add_child(gap)
	var feats_earned := 0
	for feat_id in FEATS:
		var achieved: bool = feat_id in earned
		if achieved:
			feats_earned += 1
		list.add_child(_build_row("★  %s" % feat_title(feat_id), achieved))

	var footer := Label.new()
	footer.text = "Endings reached: %d/%d     Achievements: %d/%d" % [reached, Endings.total(), feats_earned, FEATS.size()]
	if PlayerManager.current_player == "":
		footer.text = "Log in to keep track of the endings and achievements you reach."
	footer.add_theme_color_override("font_color", Color(0.8, 0.75, 0.68))
	footer.add_theme_font_size_override("font_size", 16)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(footer)

	var back := Button.new()
	back.text = "Back"
	back.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	back.offset_left = -157.0
	back.offset_top = -68.0
	back.offset_right = -36.0
	back.offset_bottom = -31.0
	back.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	back.grow_vertical = Control.GROW_DIRECTION_BEGIN
	back.pressed.connect(func(): get_tree().change_scene_to_file(return_scene))
	add_child(back)


## `text` ("1.  Demo - A Fading Echo", "★  Not in My Realm") on the left
## and, if reached, a red stamp on the right; one not yet reached is shown
## dimmed.
func _build_row(text: String, achieved: bool) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 54)
	row.add_theme_constant_override("separation", 16)

	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1, 0.93, 0.8) if achieved else Color(0.5, 0.48, 0.46))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	row.add_child(label)

	var slot := Control.new()
	slot.custom_minimum_size = Vector2(170, 0)
	row.add_child(slot)
	if achieved:
		slot.add_child(_build_stamp())
	return row


## A rubber-stamp look: a red rounded frame round bold red letters, tilted a
## little, as if pressed on by hand.
func _build_stamp() -> Control:
	var stamp := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(STAMP_RED, 0.08)
	style.border_color = STAMP_RED
	style.set_border_width_all(3)
	style.set_corner_radius_all(7)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	stamp.add_theme_stylebox_override("panel", style)

	var text := Label.new()
	text.text = "ACHIEVED"
	text.add_theme_font_size_override("font_size", 20)
	text.add_theme_color_override("font_color", STAMP_RED)
	stamp.add_child(text)

	# Centred in its slot and turned about its own middle once it has a size.
	stamp.set_anchors_preset(Control.PRESET_CENTER)
	stamp.grow_horizontal = Control.GROW_DIRECTION_BOTH
	stamp.grow_vertical = Control.GROW_DIRECTION_BOTH
	stamp.rotation = -0.17
	stamp.resized.connect(func() -> void: stamp.pivot_offset = stamp.size / 2.0)
	return stamp
