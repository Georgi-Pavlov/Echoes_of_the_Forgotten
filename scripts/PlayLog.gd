class_name PlayLog
extends RefCounted

## An optional record of what happens in battle while you play, for balance
## analysis. Off by default; the Settings screen has a "Play log" switch.
## Every event is one JSON object on its own line, appended to
## user://play_log.jsonl (see path()). Purely observational: nothing here reads
## or changes game state beyond what the battle hands it.
##
## Events (all carry "t", the wall-clock time, and "ev"):
##   session       battle scene opened: hero, level, stats, skill levels
##   stage_start   a wave's enemies are on the field
##   fight_start   a rival hero challenges you: its level, stats, skill levels
##   reinforcements  more enemies arrived (turn)
##   action        what you did this turn (move / attack / skill:<id> / potion:<id>)
##                 with HP and mana at the moment you acted
##   turn_end      the turn resolved: HP, mana, enemies left and their total HP
##   level_up      the level you reached
##   victory / defeat / flee   how a stage or fight ended, with its totals
##                 (turns, potions used, skills cast)

const FILE := "user://play_log.jsonl"


static func enabled() -> bool:
	return SettingsManager.play_log_on


## The file's real path on disk, for telling the person where it is.
static func path() -> String:
	return ProjectSettings.globalize_path(FILE)


static func event(type: String, data: Dictionary = {}) -> void:
	if not enabled():
		return
	var row := {"t": Time.get_datetime_string_from_system(), "ev": type}
	row.merge(data)
	var f := FileAccess.open(FILE, FileAccess.READ_WRITE if FileAccess.file_exists(FILE) else FileAccess.WRITE)
	if f == null:
		return
	f.seek_end()
	f.store_line(JSON.stringify(row))
	f.close()
