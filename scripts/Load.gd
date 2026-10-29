extends Control

@onready var player_tree: Tree = $Panel/VBoxContainer/PlayerTree
@onready var empty_label: Label = $Panel/VBoxContainer/EmptyLabel
@onready var load_button: Button = $Panel/VBoxContainer/HBoxContainer/LoadButton
@onready var delete_button: Button = $Panel/VBoxContainer/HBoxContainer/DeleteButton
@onready var confirm_popup: PanelContainer = $ConfirmDeletePopup
@onready var confirm_label: Label = $ConfirmDeletePopup/Margin/VBox/ConfirmLabel

const COLUMN_TITLES := ["Player", "Hero", "Level", "Echoes"]


func _ready() -> void:
	AudioManager.play_menu_music()
	$Panel/VBoxContainer/HBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	load_button.pressed.connect(_on_load_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	$ConfirmDeletePopup/Margin/VBox/Buttons/ConfirmDeleteButton.pressed.connect(_on_confirm_delete)
	$ConfirmDeletePopup/Margin/VBox/Buttons/CancelDeleteButton.pressed.connect(func(): confirm_popup.visible = false)
	player_tree.item_selected.connect(_update_buttons)
	player_tree.nothing_selected.connect(_update_buttons)
	player_tree.item_activated.connect(_on_load_pressed)

	for i in COLUMN_TITLES.size():
		player_tree.set_column_title(i, COLUMN_TITLES[i])
		player_tree.set_column_title_alignment(i, HORIZONTAL_ALIGNMENT_CENTER)
		player_tree.set_column_expand(i, i < 2)
		player_tree.set_column_custom_minimum_width(i, 70)
	_populate()


func _populate() -> void:
	player_tree.clear()
	var root: TreeItem = player_tree.create_item()
	var players: Array = PlayerManager.get_active_players()
	for player: Dictionary in players:
		var item: TreeItem = player_tree.create_item(root)
		var has_hero: bool = player["has_hero"]
		item.set_text(0, player["name"])
		item.set_text(1, player["hero_name"] if has_hero else "-")
		item.set_text(2, str(player["level"]) if has_hero else "-")
		item.set_text(3, str(player["echoes"]) if has_hero else "-")
		# Only the player name can be selected, not the info cells.
		for column in COLUMN_TITLES.size():
			item.set_text_alignment(column, HORIZONTAL_ALIGNMENT_CENTER)
			item.set_selectable(column, column == 0)
		item.set_metadata(0, {"name": player["name"], "has_hero": has_hero})
	empty_label.visible = players.is_empty()
	player_tree.visible = not players.is_empty()
	_update_buttons()


func _selected_entry() -> Dictionary:
	var item: TreeItem = player_tree.get_selected()
	return {} if item == null else item.get_metadata(0)


func _selected_name() -> String:
	return _selected_entry().get("name", "")


func _update_buttons() -> void:
	var has_selection: bool = _selected_name() != ""
	load_button.disabled = not has_selection
	delete_button.disabled = not has_selection


func _on_load_pressed() -> void:
	var username: String = _selected_name()
	if username == "":
		return
	# Everything lives in the player's save file already, so loading is
	# just switching to them and going to the map - Zone.tscn's existing
	# hero-lock check picks the rest up (same as PostLogin's Continue).
	PlayerManager.current_player = username
	# Nobody to continue with yet - land on the New Game / Continue screen.
	if not _selected_entry().get("has_hero", false):
		get_tree().change_scene_to_file("res://scenes/PostLogin.tscn")
		return
	AudioManager.stop_music_fade()
	get_tree().change_scene_to_file("res://scenes/Map.tscn")


func _on_delete_pressed() -> void:
	var username: String = _selected_name()
	if username == "":
		return
	confirm_label.text = "Delete %s and their save? This can't be undone." % username
	confirm_popup.visible = true


func _on_confirm_delete() -> void:
	confirm_popup.visible = false
	var username: String = _selected_name()
	if username != "":
		PlayerManager.delete_player(username)
	_populate()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
