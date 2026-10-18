extends RefCounted
class_name EnemyShopAI

# ============================================================
# EnemyShopAI
# ============================================================
# Pure helper for EnemyHeroManager's shopping step: decides which
# equipment item a rival hero should work towards next. Everything is
# derived from the hero's own definition (main stat + melee/ranged type)
# rather than a hand-written list per hero:
#   - every item stat is converted into one "value" currency using the
#     weights below, which depend on the hero's main stat (a point of
#     the main stat also adds damage, and mana is worth less to heroes
#     that aren't intelligence-based);
#   - an item's rating is value per gold still to be spent on it, where a
#     recipe item (one with "requires") counts the components the hero
#     doesn't own yet and is worth only what it adds on top of the
#     components it already holds (they are consumed on purchase);
#   - items restricted to one hero type (Cleaver: melee, Hunter's Bow:
#     ranged) are skipped for the other type.
# Potions are never ranked here - see EnemyHeroManager's potion reserve.
# ============================================================

const VALUE_PER_DAMAGE: float = 10.0
const VALUE_PER_HP: float = 0.4
const VALUE_PER_ARMOR: float = 12.0
const VALUE_PER_HP_REGEN: float = 6.0
const VALUE_PER_MANA: float = 0.3
const VALUE_PER_MANA_REGEN: float = 5.0
# Mana is worth this fraction of its normal value to heroes whose main
# stat isn't intelligence.
const OFF_STAT_MANA_DEPENDENCE: float = 0.5
# What the Morbid Mask's lifesteal is worth on top of having no stats.
const MORBID_MASK_VALUE: float = 100.0
# Extra worth of each point of the hero's main stat beyond its direct damage:
# it scales the whole kit (skills, scaling over a run), so heroes
# should clearly prefer gear that feeds their own main stat.
const MAIN_STAT_EXTRA_VALUE: float = 0.0

# Per-point regen granted by strength/intelligence (battle.gd's own
# PASSIVE_HP_REGEN_PER_STRENGTH/PASSIVE_MANA_REGEN_PER_INT).
const HP_REGEN_PER_STRENGTH: float = 0.25
const MANA_REGEN_PER_INTELLIGENCE: float = 0.1


## All bonuses an item grants as {stat_key: amount}.
static func item_bonuses(item: Dictionary) -> Dictionary:
	var bonuses := {}
	if item.has("stats"):
		for key in item["stats"].keys():
			bonuses[key] = float(item["stats"][key])
	if item.has("stat"):
		var stat_field = item["stat"]
		var keys: Array = stat_field if stat_field is Array else [stat_field]
		for key in keys:
			bonuses[key] = float(bonuses.get(key, 0.0)) + float(item.get("value", 0))
	return bonuses


static func _stat_weight(stat_key: String, main_stat: String, mana_dependence: float) -> float:
	var main_damage: float = GameManager.DAMAGE_PER_MAIN_STAT * VALUE_PER_DAMAGE + MAIN_STAT_EXTRA_VALUE
	match stat_key:
		"damage":
			return VALUE_PER_DAMAGE
		"strength":
			return GameManager.HP_PER_STRENGTH * VALUE_PER_HP + HP_REGEN_PER_STRENGTH * VALUE_PER_HP_REGEN + (main_damage if main_stat == "strength" else 0.0)
		"agility":
			return GameManager.ARMOR_PER_AGILITY * VALUE_PER_ARMOR + (main_damage if main_stat == "agility" else 0.0)
		"intelligence":
			return (GameManager.MANA_PER_INTELLIGENCE * VALUE_PER_MANA + MANA_REGEN_PER_INTELLIGENCE * VALUE_PER_MANA_REGEN) * mana_dependence + (main_damage if main_stat == "intelligence" else 0.0)
		"armor":
			return VALUE_PER_ARMOR
		"max_hp":
			return VALUE_PER_HP
		"hp_regen":
			return VALUE_PER_HP_REGEN
		"max_mana":
			return VALUE_PER_MANA * mana_dependence
		"mana_regen":
			return VALUE_PER_MANA_REGEN * mana_dependence
		_:
			return 0.0


## What `item` is worth to `hero_static`, in the value currency above.
static func item_value(item: Dictionary, hero_static: Dictionary) -> float:
	var main_stat: String = str(hero_static.get("main_stat", "")).strip_edges().to_lower()
	var mana_dependence: float = 1.0 if main_stat == "intelligence" else OFF_STAT_MANA_DEPENDENCE
	var bonuses: Dictionary = item_bonuses(item)
	var total: float = 0.0
	for key in bonuses.keys():
		total += float(bonuses[key]) * _stat_weight(str(key), main_stat, mana_dependence)
	if item.get("id", "") == "morbid_mask":
		total += MORBID_MASK_VALUE
	return total


## False for equipment restricted to the other melee/ranged type.
static func item_fits_hero(item: Dictionary, hero_static: Dictionary) -> bool:
	var required_type: String = str(item.get("hero_type", ""))
	if required_type == "":
		return true
	var is_ranged: bool = str(hero_static.get("range_type", "")).strip_edges().to_lower().begins_with("range")
	return required_type == ("range" if is_ranged else "melee")


static func is_potion(item: Dictionary) -> bool:
	var effect: String = str(item.get("effect", ""))
	return effect == "heal" or effect == "mana"


## Gold still needed to own `item_id`: its own price plus every
## component of it the hero doesn't have yet.
static func missing_cost(item_id: String, owned: Dictionary) -> int:
	var item: Dictionary = GameManager.get_item(item_id)
	var cost: int = int(item.get("cost", 0))
	for required_id in item.get("requires", []):
		if owned.get(required_id, 0) <= 0:
			cost += int(GameManager.get_item(required_id).get("cost", 0))
	return cost


## The item `hero_static` should work towards next, "" if there's nothing
## worth (or room) to buy. `owned` is the hero's {item_id: count}; at most
## one copy of each item is ever wanted. `max_items` caps how many items
## the hero can hold at once, counting the components it would have to
## carry before combining them.
## `allow_recipes` false skips every recipe item (the set items) so only basic
## items are considered.
static func pick_target(hero_static: Dictionary, owned: Dictionary, max_items: int, allow_recipes: bool = true) -> String:
	var owned_count: int = 0
	for item_id in owned.keys():
		owned_count += int(owned[item_id])

	var best_id: String = ""
	var best_rating: float = 0.0
	for item_id in GameManager.SHOP_ITEM_IDS:
		var item: Dictionary = GameManager.get_item(item_id)
		if item.is_empty() or is_potion(item) or owned.get(item_id, 0) > 0:
			continue
		if not item_fits_hero(item, hero_static):
			continue
		if not allow_recipes and item.has("requires"):
			continue

		var requires: Array = item.get("requires", [])
		var held_components_value: float = 0.0
		var missing_components: int = 0
		for required_id in requires:
			if owned.get(required_id, 0) > 0:
				held_components_value += item_value(GameManager.get_item(required_id), hero_static)
			else:
				missing_components += 1
		# Components are bought one by one before combining, so the hero
		# needs a free slot for each missing one (the recipe item itself
		# takes the place of the three components).
		if requires.is_empty():
			if owned_count + 1 > max_items:
				continue
		elif owned_count + missing_components > max_items:
			continue

		var gain: float = item_value(item, hero_static) - held_components_value
		var cost: int = missing_cost(item_id, owned)
		if gain <= 0.0 or cost <= 0:
			continue
		var rating: float = gain / float(cost)
		if rating > best_rating:
			best_rating = rating
			best_id = item_id
	return best_id
