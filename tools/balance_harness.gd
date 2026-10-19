extends Node

## Balance harness: plays real hero-vs-rival duels in the real Battle scene
## (headless, sped up) with a simple autopilot standing in for the player, and
## writes the results to a CSV.
##
## Run:
##   Godot_console.exe --headless --path <project> res://tools/balance_harness.tscn \
##       -- --level=6 --out=C:/some/dir/duels_L6.csv [--only=raze] [--vs=veyrik] [--potions=0] [--seed=1] [--tag=x] [--waves=1] [--immortal=1]
##   By default a pure 1v1 duel (the rival's creep reinforcements are switched off,
##   --waves=1 restores them). --immortal=1 heals the player to full every turn, so
##   the result is simply how many turns the hero needs to kill the rival.
##   (--tag keeps parallel runs from sharing a save file)
##
## Both sides are built the same way: the hero at `--level`, stats grown by its
## own level_up table, skill points spent by the same rule (an eligible ultimate
## first, otherwise the lowest-level standard skill), no equipment. The player
## side is driven by the autopilot below, the rival by the game's own AI.
##
## The autopilot is deliberately simple - ultimate, then every other ready
## skill in order, then Attack, else walk toward the rival; a health potion
## below 35% HP, a mana potion below 20% mana - so the numbers are good for
## comparing heroes with each other, not for predicting how a human plays.

const TIME_SCALE := 40.0
const TURN_CAP := 70

var _level := 6
var _only := ""
var _vs := ""
var _potions := true
var _out := ""
var _seed := 1
var _waves := false
var _trace := false
var _immortal := false
var PLAYER_NAME := "balance_harness_tmp"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=")
		if kv.size() != 2:
			continue
		match kv[0]:
			"level": _level = int(kv[1])
			"only": _only = kv[1]
			"vs": _vs = kv[1]
			"potions": _potions = kv[1] != "0"
			"out": _out = kv[1]
			"seed": _seed = int(kv[1])
			"waves": _waves = kv[1] != "0"
			"trace": _trace = kv[1] != "0"
			"immortal": _immortal = kv[1] != "0"
			"tag": PLAYER_NAME = "balance_harness_" + kv[1]
	Engine.time_scale = TIME_SCALE
	await _run_all()
	_cleanup_player_file()
	get_tree().quit()


func _hero_ids() -> Array:
	var ids: Array = []
	for zone_id in GameManager.zones.keys():
		for h in GameManager.zones[zone_id].get("heroes", []):
			ids.append(h["id"])
	return ids


func _run_all() -> void:
	var ids := _hero_ids()
	var header := "player,rival,level,result,turns,player_hp_pct,rival_hp_pct,potions_used,skills_cast"
	if _out != "":
		var hf := FileAccess.open(_out, FileAccess.WRITE)
		hf.store_line(header)
		hf.close()
	for p in ids:
		if _only != "" and p != _only:
			continue
		for r in ids:
			if r == p or (_vs != "" and r != _vs):
				continue
			var res: Dictionary = await _duel(p, r)
			var row := "%s,%s,%d,%s,%d,%.0f,%.0f,%d,%d" % [p, r, _level, res["result"], res["turns"], res["player_hp_pct"], res["rival_hp_pct"], res["potions"], res["casts"]]
			print(row)
			# Appended as it goes, so a long run can be read (or killed) midway.
			if _out != "":
				var f := FileAccess.open(_out, FileAccess.READ_WRITE)
				f.seek_end()
				f.store_line(row)
				f.close()


# --- setup ----------------------------------------------------------

## Skill levels a hero has after `level` levels of play: one point per level,
## an eligible ultimate first, otherwise the lowest-level standard skill.
func _allocate_skills(hero_static: Dictionary, level: int) -> Dictionary:
	var levels: Dictionary = {}
	var skills: Array = hero_static.get("skills", [])
	for lv in range(1, level + 1):
		var best_id := ""
		var best_level := 99
		var ultimate_id := ""
		for skill in skills:
			var sid: String = skill.get("id", "")
			var stype: String = skill.get("type", "standard")
			var cur: int = int(levels.get(sid, 0))
			if cur + 1 > GameManager.get_max_skill_level(stype):
				continue
			if GameManager.get_skill_level_unlock_requirement(stype, cur + 1) > lv:
				continue
			if stype == "ultimate":
				ultimate_id = sid
			elif cur < best_level:
				best_level = cur
				best_id = sid
		var pick := ultimate_id if ultimate_id != "" else best_id
		if pick != "":
			levels[pick] = int(levels.get(pick, 0)) + 1
	return levels


func _grown_stats(hero_static: Dictionary, level: int) -> Dictionary:
	var base: Dictionary = hero_static.get("stats", {})
	var growth: Dictionary = hero_static.get("level_up", {})
	var out := {}
	for k in ["strength", "agility", "intelligence"]:
		out[k] = float(base.get(k, 0)) + float(growth.get(k, 0)) * float(level - 1)
	return out


func _cleanup_player_file() -> void:
	var path := "user://players/%s.txt" % PLAYER_NAME
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _setup_duel(player_id: String, rival_id: String) -> void:
	_cleanup_player_file()
	PlayerManager.current_player = PLAYER_NAME
	var ps: Dictionary = GameManager.get_hero_by_id(player_id)
	var rs: Dictionary = GameManager.get_hero_by_id(rival_id)

	# The player.
	var p_skills := _allocate_skills(ps, _level)
	var starting_skill: Dictionary = ps["skills"][0]
	for skill in ps["skills"]:
		if p_skills.has(skill["id"]) and skill.get("type", "standard") == "standard":
			starting_skill = skill
			break
	PlayerManager.recruit_hero(ps, starting_skill)
	var data: Dictionary = PlayerManager._read_player_data(PLAYER_NAME)
	var grown := _grown_stats(ps, _level)
	for k in grown.keys():
		data["hero_stat_" + k] = str(grown[k])
	var derived: Dictionary = GameManager.compute_derived_stats(ps, grown["strength"], grown["agility"], grown["intelligence"])
	data["hero_current_hp"] = str(derived["hp"])
	data["hero_current_mana"] = str(derived["mana"])
	data["level"] = str(_level)
	data["skill_points"] = "0"
	for key in data.keys():
		if str(key).begins_with("skill_level_"):
			data.erase(key)
	for sid in p_skills.keys():
		data["skill_level_" + sid] = str(p_skills[sid])
	data["inventory"] = "health:3,mana:5" if _potions else ""
	PlayerManager._write_player_data(PLAYER_NAME, data)

	# The rival.
	var home: String = GameManager.get_zone_id_for_hero(rival_id)
	PlayerManager.initialize_npc_hero(rs, home)
	PlayerManager.set_npc_level(rival_id, _level)
	var rgrown := _grown_stats(rs, _level)
	for k in rgrown.keys():
		PlayerManager.set_npc_stat(rival_id, k, rgrown[k])
	var rd: Dictionary = GameManager.compute_derived_stats(rs, rgrown["strength"], rgrown["agility"], rgrown["intelligence"])
	PlayerManager.set_npc_current_hp(rival_id, rd["hp"])
	PlayerManager.set_npc_current_mana(rival_id, rd["mana"])
	var r_skills := _allocate_skills(rs, _level)
	for skill in rs["skills"]:
		PlayerManager.set_npc_skill_level(rival_id, skill["id"], int(r_skills.get(skill["id"], 0)))
	PlayerManager.set_npc_skill_points(rival_id, 0)
	PlayerManager.set_npc_potion_count(rival_id, "health", 3 if _potions else 0)
	PlayerManager.set_npc_potion_count(rival_id, "mana", 5 if _potions else 0)
	GameManager.selected_zone = home


# --- the duel -------------------------------------------------------

func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _duel(player_id: String, rival_id: String) -> Dictionary:
	seed(_seed)
	_setup_duel(player_id, rival_id)
	var battle: Node = load("res://scenes/Battle.tscn").instantiate()
	add_child(battle)
	await _frames(3)
	battle._start_hero_fight(GameManager.get_hero_by_id(rival_id))
	if not _waves:
		battle._next_reinforcement_turn = 1000000
	await _frames(3)

	var potions_used := 0
	var casts := 0
	var turns := 0
	var result := "timeout"
	var rival_max: float = 1.0
	var boss: Dictionary = battle._get_hero_fight_boss()
	if not boss.is_empty():
		rival_max = maxf(float(battle._enemy_hero_effective_max_hp(boss)), 1.0)
	var player_max: float = maxf(float(battle._hero_max_hp()), 1.0)

	while turns < TURN_CAP:
		# Wait for the player's turn to open.
		var waited := 0
		while waited < 600 and not battle._battle_over and (battle._has_acted_this_turn or battle._rival_fx_in_flight):
			await get_tree().process_frame
			waited += 1
		boss = battle._get_hero_fight_boss()
		if boss.is_empty():
			result = "win"
			break
		if float(battle._recruited.get("current_hp", 1)) <= 0.0 or battle._battle_over:
			result = "loss"
			break
		turns += 1
		if _immortal:
			battle.heal(1000000.0)
		var hp_before: float = float(boss.get("current_hp", 0))
		var acted: Dictionary = await _player_turn(battle, boss)
		if _trace:
			print("  turn %d: %s | boss hp %.0f -> %.0f | hero col %d boss col %d | player hp %.0f mana %.0f" % [turns, acted.get("what", "?"), hp_before, float(boss.get("current_hp", 0)), battle._hero_pos_index, int(boss.get("pos_index", -1)), float(battle._recruited.get("current_hp", 0)), float(battle._recruited.get("current_mana", 0))])
		potions_used += int(acted["potion"])
		casts += int(acted["cast"])
		# Let the turn play out.
		await _frames(2)
		var settle := 0
		while settle < 600 and not battle._battle_over and battle._has_acted_this_turn:
			await get_tree().process_frame
			settle += 1
		boss = battle._get_hero_fight_boss()
		if boss.is_empty():
			result = "win"
			break
		if float(battle._recruited.get("current_hp", 1)) <= 0.0:
			result = "loss"
			break

	var rival_hp := 0.0 if boss.is_empty() else maxf(float(boss.get("current_hp", 0)), 0.0)
	var player_hp: float = maxf(float(battle._recruited.get("current_hp", 0)), 0.0)
	battle.queue_free()
	await _frames(2)
	return {
		"result": result, "turns": turns,
		"player_hp_pct": 100.0 * player_hp / player_max,
		"rival_hp_pct": 100.0 * rival_hp / rival_max,
		"potions": potions_used, "casts": casts,
	}


## One autopilot turn. Returns {potion, cast} counts.
func _player_turn(b: Node, boss: Dictionary) -> Dictionary:
	var out := {"potion": 0, "cast": 0, "what": "?"}
	var hp: float = float(b._recruited.get("current_hp", 0))
	var max_hp: float = float(b._hero_max_hp())
	var mana: float = float(b._recruited.get("current_mana", 0))
	var max_mana: float = float(b._recruited.get("stats", {}).get("mana", 1))

	if _potions:
		if hp < 0.35 * max_hp and PlayerManager.get_inventory().get("health", 0) > 0:
			b._on_item_pressed("health")
			out["what"] = "health potion"
			out["potion"] = 1
			return out
		if mana < 0.2 * max_mana and PlayerManager.get_inventory().get("mana", 0) > 0:
			b._on_item_pressed("mana")
			out["what"] = "mana potion"
			out["potion"] = 1
			return out

	# Skills: the ultimate first, then the rest in order.
	var skills: Array = []
	for skill in b._hero_static.get("skills", []):
		if skill.get("type", "standard") == "passive":
			continue
		if PlayerManager.get_skill_level(skill["id"]) <= 0:
			continue
		if skill.get("type", "") == "ultimate":
			skills.push_front(skill)
		else:
			skills.append(skill)
	for skill in skills:
		if b._has_acted_this_turn:
			break
		b._on_skill_pressed(skill)
		if b._targeting_mode:
			if b._valid_targets.has(boss):
				b._on_enemy_clicked(boss)
			else:
				b._cancel_targeting()
		if b._has_acted_this_turn:
			out["cast"] = 1
			out["what"] = "cast " + str(skill["id"])
			return out

	# Attack, or close the distance.
	var distance: int = absi(int(boss["pos_index"]) - int(b._hero_pos_index))
	var reach: int = b._hero_attack_column_range() if b._is_ranged_hero() else 0
	out["what"] = "attack" if distance <= reach else "move"
	if distance <= reach:
		b._on_attack_pressed()
		if b._targeting_mode:
			if b._valid_targets.has(boss):
				b._on_enemy_clicked(boss)
			else:
				b._cancel_targeting()
	else:
		b._hero_move(1 if int(boss["pos_index"]) > int(b._hero_pos_index) else -1)
	if not b._has_acted_this_turn:
		b._mark_turn_used()
	return out
