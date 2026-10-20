extends Control

@onready var gold_value_label: Label = $GoldPanel/GoldMargin/GoldRow/GoldValueLabel
@onready var items_grid: GridContainer = $ShopItemsPanel/ItemsMargin/ItemsVBox/ItemsGrid
@onready var title_label: Label = $ShopItemsPanel/ItemsMargin/ItemsVBox/TitleRow/TitleLabel
@onready var prev_page_button: Button = $ShopItemsPanel/ItemsMargin/ItemsVBox/TitleRow/PrevPageButton
@onready var next_page_button: Button = $ShopItemsPanel/ItemsMargin/ItemsVBox/TitleRow/NextPageButton
@onready var message_label: Label = $MessageLabel
@onready var back_button: Button = $BackButton

@onready var details_name_label: Label = $ItemDetailsPanel/DetailsMargin/DetailsVBox/DetailsNameLabel
@onready var details_description_label: Label = $ItemDetailsPanel/DetailsMargin/DetailsVBox/DetailsDescriptionLabel
@onready var details_cost_label: Label = $ItemDetailsPanel/DetailsMargin/DetailsVBox/DetailsCostLabel
@onready var details_buy_button: Button = $ItemDetailsPanel/DetailsMargin/DetailsVBox/DetailsBuyButton

@onready var sell_button: Button = $SellButton
@onready var sell_popup: PanelContainer = $SellPopup
@onready var sell_items_list: VBoxContainer = $SellPopup/SellMargin/SellVBox/SellItemsList
@onready var sell_close_button: Button = $SellPopup/SellMargin/SellVBox/SellCloseButton

@onready var backpack_panel: PanelContainer = $BackpackPanel
@onready var backpack_slots_box: HBoxContainer = $BackpackPanel/BackpackMargin/BackpackVBox/BackpackSlots

# The Take/Sell popup for a clicked Backpack item (null when closed).
var _backpack_popup: PanelContainer = null

# 3 items per row, 2 rows per page (matches ItemsGrid's column count).
const ITEMS_PER_PAGE := 6

# Which page of GameManager.SHOP_ITEM_IDS is currently shown - page 0
# is items [0:6), page 1 is [6:12), etc.
var _current_page: int = 0

# item_id -> how many are left this visit, for every limited-stock
# item (GameManager.SHOP_LIMITED_STOCK_IDS, not just the current page)
# so stock survives flipping pages. Items missing here are unlimited. Intentionally
# not saved anywhere - stock refills whenever the player re-enters the shop.
var _stock: Dictionary = {}

# item_id -> {button, cost_label, stock_label}, so a purchase can
# update just that one card instead of rebuilding the whole page.
var _cards: Dictionary = {}

# Which item's details are currently shown in the panel below the
# merchant - "" means nothing selected yet.
var _selected_item_id: String = ""

var _message_tween: Tween

# Health and Mana are forced SIMULTANEOUSLY here (unlike battle.gd's
# steps, which only ever force one action at a time) - both glow at
# once, so this tracks both tweens for _tutorial_clear_glow() to kill.
var _tutorial_glow_tweens: Array = []


func _ready() -> void:
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Map.tscn"))
	message_label.text = ""
	message_label.modulate.a = 0.0

	details_buy_button.pressed.connect(_on_buy_pressed)
	details_buy_button.set_meta(AudioManager.NO_CLICK_META, true)
	prev_page_button.pressed.connect(_on_prev_page_pressed)
	next_page_button.pressed.connect(_on_next_page_pressed)
	sell_button.pressed.connect(_on_sell_button_pressed)
	sell_close_button.pressed.connect(func(): sell_popup.visible = false)

	# The allowed-actions gate is set BEFORE _refresh_page() builds the
	# item cards - _refresh_item_card() reads TutorialManager.
	# is_action_allowed() to decide each card's disabled state, so the
	# restriction has to already be in place or every card (including
	# Health/Mana) builds as disabled, using whatever _allowed_actions
	# was left over from wherever the player was before this scene.
	if TutorialManager.is_active and TutorialManager.current_stage == 2:
		TutorialManager.set_allowed_actions(["buy:health", "buy:mana"])

	_initialize_stock()
	_refresh_page()
	_refresh_gold_label()
	_refresh_details_panel()
	_refresh_backpack()

	# Back/sell/paging are disabled AFTER _refresh_page() runs, since
	# _refresh_page() unconditionally recomputes both page buttons'
	# disabled state itself (based on _current_page/_total_pages()) -
	# setting these first would just get overwritten by that call.
	if TutorialManager.is_active and TutorialManager.current_stage == 2:
		back_button.disabled = true
		sell_button.disabled = true
		prev_page_button.disabled = true
		next_page_button.disabled = true
		_tutorial_glow_forced_items()
		TutorialManager.show_popup(
			"You've got exactly enough gold for one Health Potion and one Mana Potion - buy both "
			+ "before heading back out."
		)


## Gives both the Health and Mana Potion cards - and the details panel's
## own Buy button - the same glowing treatment every other forced button
## during the tutorial uses (see TutorialManager.make_glow_style()). All
## three glow at once, since either potion can be bought first here, and
## the actual purchase only happens once the player clicks Buy AFTER
## selecting one - without its own glow, a player who'd only ever seen
## the icon glow before this point had nothing marking the button that
## actually completes the purchase. details_buy_button stays glowing
## across selection changes since _refresh_details_panel() never touches
## its stylebox overrides, only its text/visible/disabled state, and
## starts glowing even while it's still hidden (nothing selected yet) -
## harmless, since it just shows once the player picks an item. Called
## once _cards is actually populated (_refresh_page() has to have run
## already - see its own call site).
func _tutorial_glow_forced_items() -> void:
	for item_id in ["health", "mana"]:
		if not _cards.has(item_id):
			continue
		var button: Button = _cards[item_id]["button"]
		var glow_style: StyleBoxFlat = TutorialManager.make_glow_style()
		button.add_theme_stylebox_override("normal", glow_style)
		button.add_theme_stylebox_override("hover", glow_style)
		_tutorial_glow_tweens.append(TutorialManager.start_glow_pulse(glow_style, self))

	var buy_glow_style: StyleBoxFlat = TutorialManager.make_glow_style()
	details_buy_button.add_theme_stylebox_override("normal", buy_glow_style)
	details_buy_button.add_theme_stylebox_override("hover", buy_glow_style)
	details_buy_button.add_theme_stylebox_override("disabled", buy_glow_style)
	_tutorial_glow_tweens.append(TutorialManager.start_glow_pulse(buy_glow_style, self))


## Undoes _tutorial_glow_forced_items() once both potions are bought -
## called from _tutorial_check_progress() right before it opens the
## checkpoint.
func _tutorial_clear_glow() -> void:
	for item_id in ["health", "mana"]:
		if _cards.has(item_id):
			var button: Button = _cards[item_id]["button"]
			button.remove_theme_stylebox_override("normal")
			button.remove_theme_stylebox_override("hover")
	details_buy_button.remove_theme_stylebox_override("normal")
	details_buy_button.remove_theme_stylebox_override("hover")
	details_buy_button.remove_theme_stylebox_override("disabled")
	for tween in _tutorial_glow_tweens:
		if tween:
			tween.kill()
	_tutorial_glow_tweens.clear()


## Polled after every successful purchase - once both potions are in
## the inventory, opens the "continue to the final tutorial stage, or
## stop here" checkpoint and lifts every restriction _apply_tutorial_
## restrictions() put in place.
func _tutorial_check_progress() -> void:
	if not TutorialManager.is_active or TutorialManager.current_stage != 2:
		return

	var inventory: Dictionary = PlayerManager.get_inventory()
	if inventory.get("health", 0) <= 0 or inventory.get("mana", 0) <= 0:
		return

	back_button.disabled = false
	sell_button.disabled = false
	prev_page_button.disabled = _current_page <= 0
	next_page_button.disabled = _current_page >= _total_pages() - 1
	TutorialManager.set_allowed_actions([])
	_tutorial_clear_glow()

	TutorialManager.show_checkpoint(
		"Stocked up! That's the other half of surviving a run: knowing when to cut your losses, "
		+ "and having potions ready for when you do.\n\nContinue with the final tutorial stage, or "
		+ "stop here?",
		TutorialManager.start_stage3
	)


func _refresh_gold_label() -> void:
	gold_value_label.text = str(PlayerManager.get_gold())


## Stocks every limited item once, up front - not just the current
## page's items - so switching pages never resets what's already been
## bought. Every other shop item is unlimited and never sells out.
func _initialize_stock() -> void:
	_stock.clear()
	for item_id in GameManager.SHOP_LIMITED_STOCK_IDS:
		_stock[item_id] = GameManager.SHOP_STOCK_PER_ITEM


func _is_sold_out(item_id: String) -> bool:
	return _stock.has(item_id) and _stock[item_id] <= 0


func _total_pages() -> int:
	return maxi(1, ceili(GameManager.SHOP_ITEM_IDS.size() / float(ITEMS_PER_PAGE)))


func _on_prev_page_pressed() -> void:
	if _current_page > 0:
		_current_page -= 1
		_refresh_page()


func _on_next_page_pressed() -> void:
	if _current_page < _total_pages() - 1:
		_current_page += 1
		_refresh_page()


## Rebuilds the current page's item cards and updates the title/page
## arrows to match.
func _refresh_page() -> void:
	_build_shop_items()

	var total_pages: int = _total_pages()
	prev_page_button.disabled = _current_page <= 0
	next_page_button.disabled = _current_page >= total_pages - 1
	title_label.text = "For Sale (%d/%d)" % [_current_page + 1, total_pages] if total_pages > 1 else "For Sale"


## Builds one card per item id on the current page (first 6 ids -> page
## 1, next 6 -> page 2, etc.), each reflecting whatever's already in
## _stock for it.
func _build_shop_items() -> void:
	for child in items_grid.get_children():
		child.queue_free()
	_cards.clear()

	var start: int = _current_page * ITEMS_PER_PAGE
	var end: int = mini(start + ITEMS_PER_PAGE, GameManager.SHOP_ITEM_IDS.size())

	for i in range(start, end):
		var item_id: String = GameManager.SHOP_ITEM_IDS[i]
		var item_data: Dictionary = GameManager.get_item(item_id)
		if item_data.is_empty():
			print("ERROR: Shop item id not found in GameManager.items: ", item_id)
			continue

		items_grid.add_child(_build_item_card(item_id, item_data))


func _build_item_card(item_id: String, item_data: Dictionary) -> Control:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(100, 0)
	card.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_theme_constant_override("separation", 6)

	var icon_button := Button.new()
	icon_button.custom_minimum_size = Vector2(96, 96)
	icon_button.expand_icon = true
	icon_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var image_path: String = item_data.get("image", "")
	if image_path != "" and ResourceLoader.exists(image_path):
		icon_button.icon = load(image_path)
	icon_button.pressed.connect(_on_item_selected.bind(item_id))

	var name_label := Label.new()
	name_label.text = item_data.get("name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.72, 1))
	name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	name_label.add_theme_constant_override("outline_size", 3)
	name_label.add_theme_font_size_override("font_size", 15)

	var cost_label := Label.new()
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_color_override("font_color", Color(0.95, 0.78, 0.4, 1))
	cost_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	cost_label.add_theme_constant_override("outline_size", 3)
	cost_label.add_theme_font_size_override("font_size", 14)

	var stock_label := Label.new()
	stock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stock_label.add_theme_color_override("font_color", Color(0.65, 0.58, 0.5, 1))
	stock_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	stock_label.add_theme_constant_override("outline_size", 2)
	stock_label.add_theme_font_size_override("font_size", 12)

	card.add_child(icon_button)
	card.add_child(name_label)
	card.add_child(cost_label)
	card.add_child(stock_label)

	_cards[item_id] = {
		"button": icon_button,
		"cost_label": cost_label,
		"stock_label": stock_label,
	}
	_refresh_item_card(item_id)

	return card


func _refresh_item_card(item_id: String) -> void:
	if not _cards.has(item_id):
		return

	var item_data: Dictionary = GameManager.get_item(item_id)
	var cost: int = int(item_data.get("cost", 0))

	var card: Dictionary = _cards[item_id]
	var button: Button = card["button"]
	var cost_label: Label = card["cost_label"]
	var stock_label: Label = card["stock_label"]

	if _is_sold_out(item_id):
		button.disabled = true
		cost_label.text = "Sold out"
		stock_label.text = ""
	else:
		button.disabled = not TutorialManager.is_action_allowed("buy:" + item_id)
		cost_label.text = str(cost) + " Gold"
		# Only limited items show a stock count; the label stays (empty)
		# on unlimited ones so every card keeps the same height.
		stock_label.text = "x%d in stock" % _stock[item_id] if _stock.has(item_id) else ""


## Clicking an item's icon no longer buys it directly - it just shows
## that item's details (description + cost + a Buy button) in the
## panel under the merchant portrait. Buying happens from there.
func _on_item_selected(item_id: String) -> void:
	_selected_item_id = item_id
	_refresh_details_panel()


## Fills the details panel for whichever item is selected, or shows a
## prompt if nothing's been clicked yet.
func _refresh_details_panel() -> void:
	if _selected_item_id == "":
		details_name_label.text = "Select an item to see its details"
		details_description_label.text = ""
		details_cost_label.text = ""
		details_buy_button.visible = false
		return

	var item_data: Dictionary = GameManager.get_item(_selected_item_id)
	var cost: int = int(item_data.get("cost", 0))

	details_name_label.text = item_data.get("name", "")
	details_description_label.text = item_data.get("description", "")
	details_buy_button.visible = true
	# Default to the normal price - only the `stock <= 0` branch below
	# overrides it to "Sold out". Previously only that branch ever set
	# this label at all, so once you'd viewed one sold-out item, its
	# "Sold out" text stuck around forever: the elif/else branches below
	# only ever touched details_buy_button, never this label, so a fully
	# in-stock item selected afterward still showed a stale "Sold out"
	# price even though its own Buy button correctly re-enabled.
	details_cost_label.text = str(cost) + " Gold"

	if _is_sold_out(_selected_item_id):
		details_cost_label.text = "Sold out"
		details_buy_button.disabled = true
		details_buy_button.text = "Sold Out"
	elif not TutorialManager.is_action_allowed("buy:" + _selected_item_id):
		details_buy_button.disabled = true
		details_buy_button.text = "Buy"
	elif not _missing_requirements(_selected_item_id).is_empty():
		details_buy_button.disabled = true
		details_buy_button.text = "Missing Components"
	elif _recipe_item(_selected_item_id) and _recipe_destination(_selected_item_id) == "":
		details_buy_button.disabled = true
		details_buy_button.text = "No Room"
	elif not _recipe_item(_selected_item_id) and not PlayerManager.can_add_item(_selected_item_id):
		details_buy_button.disabled = true
		details_buy_button.text = "Inventory Full"
	else:
		details_buy_button.disabled = false
		details_buy_button.text = "Buy"


func _on_buy_pressed() -> void:
	var item_id: String = _selected_item_id
	if item_id == "":
		return

	if not TutorialManager.is_action_allowed("buy:" + item_id):
		return

	if _is_sold_out(item_id):
		_show_message("Sold out")
		return

	var item_data: Dictionary = GameManager.get_item(item_id)
	var cost: int = int(item_data.get("cost", 0))

	if PlayerManager.get_gold() < cost:
		_show_message("Not enough gold")
		return

	var missing: Array = _missing_requirements(item_id)
	if not missing.is_empty():
		var names: Array = []
		for missing_id in missing:
			names.append(GameManager.get_item(missing_id).get("name", missing_id))
		_show_message("Requires " + ", ".join(names))
		return

	var destination: String = ""
	if _recipe_item(item_id):
		destination = _recipe_destination(item_id)
		if destination == "":
			_show_message("No room for " + item_data.get("name", "item"))
			return
	elif not PlayerManager.can_add_item(item_id):
		_show_message("Inventory full")
		return

	PlayerManager.add_gold(-cost)
	var placed_in_backpack: bool = false
	if _recipe_item(item_id):
		_consume_requirements(item_id)
		if destination == "backpack":
			PlayerManager.add_to_backpack(item_id)
			placed_in_backpack = true
		else:
			PlayerManager.add_item(item_id, 1)
	else:
		PlayerManager.add_item(item_id, 1)
	AudioManager.play_event("shop_transaction")
	if _stock.has(item_id):
		_stock[item_id] -= 1
	# The tutorial's gold covers exactly one of each potion: once one is
	# bought, that potion can't be bought again (or the gold goes on it
	# instead of the other).
	if TutorialManager.is_active and TutorialManager.current_stage == 2:
		var allowed: Array = TutorialManager.get_allowed_actions()
		allowed.erase("buy:" + item_id)
		if not allowed.is_empty():
			TutorialManager.set_allowed_actions(allowed)

	_refresh_gold_label()
	_refresh_item_card(item_id)
	_refresh_details_panel()
	_refresh_backpack()
	var message: String = item_data.get("name", "Item") + " purchased!"
	if placed_in_backpack:
		message += " (sent to Backpack)"
	_show_message(message)
	_tutorial_check_progress()


## True if `item_id` is bought by combining other items (has "requires").
func _recipe_item(item_id: String) -> bool:
	return not GameManager.get_item(item_id).get("requires", []).is_empty()


## Ids from `item_id`'s "requires" list the player owns neither in the
## inventory nor in the Backpack.
func _missing_requirements(item_id: String) -> Array:
	var inventory: Dictionary = PlayerManager.get_inventory()
	var backpack: Dictionary = PlayerManager.get_backpack()
	var missing: Array = []
	for required_id in GameManager.get_item(item_id).get("requires", []):
		if inventory.get(required_id, 0) + backpack.get(required_id, 0) <= 0:
			missing.append(required_id)
	return missing


## Which components come out of the Backpack (taken from there first) and
## which out of the inventory, as {"backpack": [ids], "inventory": [ids]}.
func _requirement_sources(item_id: String) -> Dictionary:
	var backpack: Dictionary = PlayerManager.get_backpack()
	var sources := {"backpack": [], "inventory": []}
	for required_id in GameManager.get_item(item_id).get("requires", []):
		if backpack.get(required_id, 0) > 0:
			sources["backpack"].append(required_id)
		else:
			sources["inventory"].append(required_id)
	return sources


## Where a combined item lands once its components are consumed: the
## inventory by default, the Backpack if only that has room, "" if neither
## does. Slots freed by the consumed components count as free.
func _recipe_destination(item_id: String) -> String:
	var sources: Dictionary = _requirement_sources(item_id)
	var inventory_used: int = PlayerManager.get_inventory_slots().size() - sources["inventory"].size()
	if inventory_used < PlayerManager.get_max_inventory_slots():
		return "inventory"
	var backpack_used: int = PlayerManager.get_backpack_slots().size() - sources["backpack"].size()
	if backpack_used < PlayerManager.get_max_backpack_slots():
		return "backpack"
	return ""


func _consume_requirements(item_id: String) -> void:
	var sources: Dictionary = _requirement_sources(item_id)
	for required_id in sources["backpack"]:
		PlayerManager.remove_from_backpack(required_id)
	for required_id in sources["inventory"]:
		PlayerManager.use_item(required_id)


# ------------------------------------------------------------------
# Backpack: 4 slots under the shop items. Items in it give no bonuses.
# Clicking one opens a small popup to Take it into the inventory or
# Sell it; the Sell Items popup has a "To Backpack" button per row.
# ------------------------------------------------------------------

func _refresh_backpack() -> void:
	for child in backpack_slots_box.get_children():
		child.queue_free()

	var slots: Array = PlayerManager.get_backpack_slots()
	for i in range(PlayerManager.get_max_backpack_slots()):
		var slot_button := Button.new()
		slot_button.custom_minimum_size = Vector2(60, 60)
		slot_button.expand_icon = true
		if i < slots.size():
			var item_id: String = slots[i]["item_id"]
			var item_data: Dictionary = GameManager.get_item(item_id)
			var image_path: String = item_data.get("image", "")
			if image_path != "" and ResourceLoader.exists(image_path):
				slot_button.icon = load(image_path)
			slot_button.tooltip_text = item_data.get("name", "")
			if slots[i]["count"] > 1:
				slot_button.text = "x%d" % slots[i]["count"]
			slot_button.pressed.connect(_on_backpack_slot_pressed.bind(item_id))
		else:
			slot_button.disabled = true
		backpack_slots_box.add_child(slot_button)


func _on_backpack_slot_pressed(item_id: String) -> void:
	_close_backpack_popup()
	var item_data: Dictionary = GameManager.get_item(item_id)

	var popup := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.035, 0.028, 0.97)
	style.set_border_width_all(2)
	style.border_color = Color(0.55, 0.4, 0.22, 1)
	style.set_corner_radius_all(3)
	popup.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.text = item_data.get("name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color(0.9, 0.74, 0.45, 1))
	name_label.add_theme_font_size_override("font_size", 16)

	var take_button := Button.new()
	take_button.text = "Take"
	take_button.theme_type_variation = &"BloodButton"
	take_button.custom_minimum_size = Vector2(150, 34)
	take_button.disabled = not PlayerManager.can_add_item(item_id)
	if take_button.disabled:
		take_button.tooltip_text = "Inventory full"
	take_button.pressed.connect(_on_backpack_take.bind(item_id))

	var sell_price: int = _sell_price_for(item_id)
	var sell_btn := Button.new()
	sell_btn.text = "Sell for %d Gold" % sell_price
	sell_btn.theme_type_variation = &"BloodButton"
	sell_btn.custom_minimum_size = Vector2(150, 34)
	sell_btn.pressed.connect(_on_backpack_sell.bind(item_id))

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(150, 30)
	close_btn.pressed.connect(_close_backpack_popup)

	vbox.add_child(name_label)
	vbox.add_child(take_button)
	vbox.add_child(sell_btn)
	vbox.add_child(close_btn)
	margin.add_child(vbox)
	popup.add_child(margin)
	add_child(popup)
	_backpack_popup = popup

	# Centered above the backpack panel once its size is known.
	popup.reset_size()
	var panel_rect: Rect2 = backpack_panel.get_global_rect()
	popup.position = Vector2(
		panel_rect.position.x + panel_rect.size.x * 0.5 - popup.size.x * 0.5,
		panel_rect.position.y - popup.size.y - 8.0
	)


func _close_backpack_popup() -> void:
	if _backpack_popup != null and is_instance_valid(_backpack_popup):
		_backpack_popup.queue_free()
	_backpack_popup = null


func _on_backpack_take(item_id: String) -> void:
	_close_backpack_popup()
	if not PlayerManager.take_from_backpack(item_id):
		_show_message("Inventory full")
		return
	_refresh_backpack()
	_refresh_details_panel()
	_show_message("Took %s from the Backpack" % GameManager.get_item(item_id).get("name", "item"))


func _on_backpack_sell(item_id: String) -> void:
	_close_backpack_popup()
	if not PlayerManager.remove_from_backpack(item_id):
		return
	var sell_price: int = _sell_price_for(item_id)
	PlayerManager.add_gold(sell_price)
	AudioManager.play_event("shop_transaction")
	_refresh_gold_label()
	_refresh_backpack()
	_refresh_details_panel()
	_show_message("Sold %s for %d Gold" % [GameManager.get_item(item_id).get("name", "item"), sell_price])


func _on_send_to_backpack(item_id: String) -> void:
	if not PlayerManager.move_to_backpack(item_id):
		_show_message("Backpack full")
		return
	_refresh_backpack()
	_refresh_sell_popup()
	_refresh_details_panel()
	_show_message("Sent %s to the Backpack" % GameManager.get_item(item_id).get("name", "item"))


## Brief fade-in/fade-out status message (purchase confirmation,
## "not enough gold", "sold out") shown under the shop panel.
func _show_message(text: String) -> void:
	if _message_tween:
		_message_tween.kill()

	message_label.text = text
	message_label.modulate.a = 1.0

	_message_tween = create_tween()
	_message_tween.tween_interval(1.0)
	_message_tween.tween_property(message_label, "modulate:a", 0.0, 0.6)


func _on_sell_button_pressed() -> void:
	_refresh_sell_popup()
	sell_popup.visible = true


## Rebuilds the sell popup's item rows from the hero's current
## inventory. Called on open and after every sale so quantities (and
## the "nothing left to sell" state) stay accurate.
func _refresh_sell_popup() -> void:
	for child in sell_items_list.get_children():
		child.queue_free()

	var inventory: Dictionary = PlayerManager.get_inventory()
	if inventory.is_empty():
		var empty_label := Label.new()
		empty_label.text = "You have no items to sell."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.65, 0.58, 0.5, 1))
		empty_label.add_theme_font_size_override("font_size", 14)
		sell_items_list.add_child(empty_label)
		return

	for item_id in inventory.keys():
		var item_data: Dictionary = GameManager.get_item(item_id)
		if item_data.is_empty():
			continue
		sell_items_list.add_child(_build_sell_row(item_id, item_data, inventory[item_id]))


func _build_sell_row(item_id: String, item_data: Dictionary, count: int) -> Control:
	var row := PanelContainer.new()
	var row_style := StyleBoxFlat.new()
	row_style.bg_color = Color(0.13, 0.075, 0.05, 0.75)
	row_style.border_width_bottom = 1
	row_style.border_color = Color(0.45, 0.3, 0.18, 0.5)
	row_style.set_corner_radius_all(2)
	row.add_theme_stylebox_override("panel", row_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 6)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)

	var icon_rect := TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(40, 40)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var image_path: String = item_data.get("image", "")
	if image_path != "" and ResourceLoader.exists(image_path):
		icon_rect.texture = load(image_path)

	var name_label := Label.new()
	name_label.text = "%s  x%d" % [item_data.get("name", ""), count]
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.72, 1))
	name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.add_theme_font_size_override("font_size", 15)

	var sell_price: int = _sell_price_for(item_id)

	var sell_button := Button.new()
	sell_button.text = "Sell for %d Gold" % sell_price
	sell_button.custom_minimum_size = Vector2(150, 36)
	sell_button.theme_type_variation = &"BloodButton"
	sell_button.pressed.connect(_on_sell_item_pressed.bind(item_id))
	sell_button.set_meta(AudioManager.NO_CLICK_META, true)

	var backpack_button := Button.new()
	backpack_button.text = "To Backpack"
	backpack_button.custom_minimum_size = Vector2(120, 36)
	backpack_button.disabled = not PlayerManager.can_add_to_backpack(item_id)
	backpack_button.pressed.connect(_on_send_to_backpack.bind(item_id))

	hbox.add_child(icon_rect)
	hbox.add_child(name_label)
	hbox.add_child(backpack_button)
	hbox.add_child(sell_button)
	margin.add_child(hbox)
	row.add_child(margin)

	return row


## Sell price is always 50% of that item's shop buy cost, rounded down.
func _sell_price_for(item_id: String) -> int:
	var item_data: Dictionary = GameManager.get_item(item_id)
	var cost: int = int(item_data.get("cost", 0))
	return int(cost * 0.5)


func _on_sell_item_pressed(item_id: String) -> void:
	if not PlayerManager.use_item(item_id):
		return

	var sell_price: int = _sell_price_for(item_id)
	PlayerManager.add_gold(sell_price)
	AudioManager.play_event("shop_transaction")

	_refresh_gold_label()
	_refresh_sell_popup()
	_refresh_details_panel()
	_refresh_backpack()

	var item_data: Dictionary = GameManager.get_item(item_id)
	_show_message("Sold %s for %d Gold" % [item_data.get("name", "item"), sell_price])
