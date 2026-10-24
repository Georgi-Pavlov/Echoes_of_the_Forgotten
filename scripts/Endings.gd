class_name Endings
extends RefCounted

## The demo's endings, in the order they are numbered to the player
## ("Ending 2/5"). How each one is reached:
##
##   FADING_ECHO       a rival gathers enough Echoes, opens the final stage and wins
##   WORLD_REBORN      the player chose to restore the old world, then enters the vortex
##   CROWN_OF_ASHES    the player chose to rule the new world, then enters the vortex
##   LAST_REMEMBERED   chose to restore, but killed every rival before entering the vortex
##   FINAL_TYRANT      chose to rule, but killed every rival before entering the vortex
##
## The player's choice (PlayerManager.get_path_choice()) is one of the two
## PATH_* values, made once after the first-choice dream.

const FADING_ECHO := "fading_echo"
const WORLD_REBORN := "world_reborn"
const CROWN_OF_ASHES := "crown_of_ashes"
const LAST_REMEMBERED := "last_remembered"
const FINAL_TYRANT := "final_tyrant"

const PATH_RESTORE := "restore"
const PATH_RULE := "rule"

const ORDER: Array[String] = [FADING_ECHO, WORLD_REBORN, CROWN_OF_ASHES, LAST_REMEMBERED, FINAL_TYRANT]

const NAMES := {
	FADING_ECHO: "Demo - A Fading Echo",
	WORLD_REBORN: "Demo - The World Reborn",
	CROWN_OF_ASHES: "Demo - Crown of Ashes",
	LAST_REMEMBERED: "Demo - The Last Remembered",
	FINAL_TYRANT: "Demo - The Final Tyrant",
}

## The ending the player earns by entering the vortex: their path, and
## whether every rival is already dead.
static func for_vortex(path: String, all_rivals_dead: bool) -> String:
	if path == PATH_RESTORE:
		return LAST_REMEMBERED if all_rivals_dead else WORLD_REBORN
	return FINAL_TYRANT if all_rivals_dead else CROWN_OF_ASHES


static func total() -> int:
	return ORDER.size()


## 1-based number of an ending ("Ending 2/5").
static func number(ending_id: String) -> int:
	return ORDER.find(ending_id) + 1


static func title(ending_id: String) -> String:
	return NAMES.get(ending_id, ending_id)


## "Ending 2/5 (Demo - The World Reborn)".
static func banner_text(ending_id: String) -> String:
	return "Ending %d/%d (%s)" % [number(ending_id), total(), title(ending_id)]
