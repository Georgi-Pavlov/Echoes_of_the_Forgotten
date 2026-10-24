extends Control
# ------------------------------------------------------------------
# WorldStatus
# ------------------------------------------------------------------
# A read-only, scrollable overview of every zone's hero roster: each
# hero shown as "Name (Level N)" if still alive, "Name - Dead" once
# PlayerManager.is_hero_defeated() says otherwise - including the
# player's own recruited hero, shown at their own PlayerManager.
# get_level() rather than the NPC level fields that back everyone
# else (see PlayerManager's "NPC hero state" section from Step 1/2).
# Reached from the Map via the new "World Status" button next to Shop.
# ------------------------------------------------------------------

func _ready() -> void:
	$BackButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Map.tscn"))
	_style_list_panel()
	_populate_zones()
	if TutorialManager.is_active and TutorialManager.current_stage == 4 and TutorialManager.current_step == 1:
		_tutorial_tour()


# Lunara's row, kept so the tutorial tour can point at it.
var _lunara_row: Label = null


## Tutorial stage 4 (see Map.gd): leaving is only possible through the
## tour's own last popup, which sends the player back to the Map.
func _tutorial_tour() -> void:
	$BackButton.disabled = true
	TutorialManager.show_popup(
		"Here you can see all other Remembered. They are not sitting and waiting, each one is doing what "
		+ "you are - gathering power and seeking the echoes of the others for its own ambition.",
		_tutorial_point_at_lunara
	)


func _tutorial_point_at_lunara() -> void:
	if _lunara_row != null:
		var style: StyleBoxFlat = TutorialManager.make_glow_style()
		style.set_content_margin_all(4)
		_lunara_row.add_theme_stylebox_override("normal", style)
		TutorialManager.start_glow_pulse(style, self)
		# The list has to have been laid out before it can scroll to a row.
		await get_tree().process_frame
		$ListPanel/Margin/ScrollContainer.ensure_control_visible(_lunara_row)
	TutorialManager.show_popup(
		"Look here, Lunara has almost enough echoes to face the final challenge! You have to face her and "
		+ "try to get those echoes for yourself. If she falls in the final challenge all of them will be "
		+ "lost and if she succeed, you will be at her mercy.",
		func():
			TutorialManager.current_step = 2
			get_tree().change_scene_to_file("res://scenes/Map.tscn"),
		"Continue",
		false
	)


func _style_list_panel() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.55)
	panel_style.border_color = Color(1, 1, 1, 0.25)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	$ListPanel.add_theme_stylebox_override("panel", panel_style)


## Builds one header + hero-line block per zone that actually has
## heroes in it - zones with an empty "heroes" list (unused/reserved
## regions on the map) are skipped entirely rather than showing an
## empty header.
func _populate_zones() -> void:
	var list: VBoxContainer = $ListPanel/Margin/ScrollContainer/ZonesList
	for child in list.get_children():
		child.queue_free()

	var player_hero_id: String = PlayerManager.get_recruited_hero().get("id", "")

	for zone_id in GameManager.zones.keys():
		var zone_data: Dictionary = GameManager.get_zone(zone_id)
		var heroes: Array = zone_data.get("heroes", [])
		if heroes.is_empty():
			continue

		list.add_child(_build_zone_header(zone_data.get("name", zone_id)))
		for hero in heroes:
			list.add_child(_build_hero_row(hero, player_hero_id))
		list.add_child(_build_spacer())


func _build_zone_header(zone_name: String) -> Label:
	var label := Label.new()
	label.text = zone_name
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.4, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_font_size_override("font_size", 18)
	return label


## One "  Name (Level N)" / "  Name - Dead" row for a single hero -
## green and bolded (via a "You" suffix) for the player's own hero,
## red for a defeated one, plain white otherwise.
func _build_hero_row(hero: Dictionary, player_hero_id: String) -> Label:
	var hero_id: String = hero.get("id", "")
	var hero_name: String = hero.get("name", hero_id)

	var label := Label.new()
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_font_size_override("font_size", 14)

	if hero_id != "" and hero_id == player_hero_id:
		label.text = "    %s (Level %d) - You - Echoes: %s" % [hero_name, PlayerManager.get_level(), GameManager.format_echoes(PlayerManager.get_echoes())]
		label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.4, 1))
	elif PlayerManager.is_hero_defeated(hero_id):
		label.text = "    %s - Dead" % hero_name
		label.add_theme_color_override("font_color", Color(0.85, 0.3, 0.3, 1))
	else:
		label.text = "    %s (Level %d) - Echoes: %s" % [hero_name, PlayerManager.get_npc_level(hero_id), GameManager.format_echoes(PlayerManager.get_npc_echoes(hero_id))]
		label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

	if hero_id == "lunara":
		_lunara_row = label
	return label


func _build_spacer() -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	return spacer
