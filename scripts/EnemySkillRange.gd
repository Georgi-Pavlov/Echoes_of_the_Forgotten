extends RefCounted
class_name EnemySkillRange

# ============================================================
# EnemySkillRange
# ============================================================
# Pure helper for battle.gd's rival-hero AI (_enemy_hero_turn()/
# _pick_enemy_ready_skill()): decides whether a rival hero is actually
# within range to land a given skill on the player, so a boss can't
# hit the player with Abyssal Spasm or Thornbind from clear across the
# board regardless of distance - it has to close in first, same as it
# already must for a plain Attack (see battle.gd's
# RANGE_ENEMY_ATTACK_RANGE/_enemy_hero_turn()).
#
# Only skills that hit the player directly need a range check here:
#   - Abyssal Spasm: an AoE centered on the caster - in range whenever the
#     player is within the skill's own `radius` field (0 at low
#     levels, meaning the same column; 1 only at max level).
#   - Drowned Surge/Undertow/The Sunken One: targeted casts with their own
#     `range` field (a constant 3 for Drowned Surge, 2-5 growing with level
#     for Undertow, 4-6 for The Sunken One) - in range whenever the
#     player is within it, the same "distance <= radius" comparison as
#     Abyssal Spasm, just against a targeting range instead of a self-
#     centered AoE radius (see battle.gd's _enemy_skill_in_range(),
#     which reads whichever of the two fields a given skill actually
#     has).
#   - Thornbind/Whisper of the Veil/Touch of the First Cold/Maddening Roar/The Hunger Calls/
#     Rimecleaver/Winter's Grip: none of the seven has a range field of its
#     own (Maddening Roar has `shatter_range`, but that's its splash
#     radius around whichever target gets hit, not its own targeting
#     range; Rimecleaver's own `radius` field is the same story;
#     The Hunger Calls has no range field at all), so all seven use the
#     rival's own basic-attack range for its type instead, mirroring how
#     the player's own copies of each use the player's attack-column
#     range (_hero_attack_column_range(), via _start_rimecleaver_
#     targeting()/_start_winters_grip_targeting()).
#   - Barbed Lunge: a gap-closer, but only up to its own `distance` field of
#     columns - it stops the moment it lands on the player's column
#     (see battle.gd's _cast_enemy_barbed_lunge()), so a player standing
#     farther away than that just watches the rival leap partway and
#     whiff instead of taking the hit. In range whenever the player is
#     within `distance`, the same "distance <= radius" comparison as
#     Abyssal Spasm/Drowned Surge/Undertow/The Sunken One, just against the
#     leap's own reach instead of a targeting range or AoE radius.
#   - Mark of Stillness: a targeted cast with its own per-level `range` field
#     (2-4, growing with level) - same "distance <= radius" comparison
#     as Drowned Surge/Undertow/The Sunken One, just against Mark of Stillness's
#     own range instead of theirs.
#   - The Hollow Cold: also a targeted cast, but its own targeting range is
#     a FIXED constant (battle.gd's THE_HOLLOW_COLD_RANGE) rather than a
#     per-level field - its level only changes the AoE radius applied
#     around whichever target gets hit, never the targeting range
#     itself. battle.gd's own _enemy_skill_in_range() special-cases
#     this before calling in here, passing THE_HOLLOW_COLD_RANGE as `radius`
#     instead of pulling from level data (which would otherwise
#     silently grab the AoE radius field instead - see that function's
#     own comment).
#   - Frostbound Rupture/Charge (both Skarn's): targeted casts with their own
#     per-level `range` field, same "distance <= radius" comparison as
#     Mark of Stillness's own - Skarn himself fights at melee range, but both are
#     thrown/charged well past it.
#   - Glacier Breaker (Skarn's ultimate): strictly melee range (same column
#     as the player, sharing his own basic-attack reach for "melee" - 0
#     columns) rather than any range/radius field of its own, mirroring
#     the player's own _start_glacier_breaker_targeting()'s "shares his own
#     column" requirement - so this uses the same attack_range fallback
#     Thornbind/Whisper of the Veil do, just against a hero whose own type is
#     always "melee" (see GameManager's own Skarn entry), where that
#     fallback is always 0 anyway.
#   - Sanguine Bloom (The Rootmother's): a targeted cast with its own
#     per-level `range` field (a constant 2 per the design doc), same
#     "distance <= radius" comparison as Mark of Stillness's/Frostbound Rupture'/
#     Charge's own.
#   - Whirling Death (Timbersaw's): an AoE centered on the caster, same
#     shape as Abyssal Spasm's own - in range whenever the player is within
#     the skill's own `radius` field. It has no `range` field of its
#     own, so the generic fallback chain battle.gd's own
#     _enemy_skill_in_range() already uses (range, then radius, then
#     distance) correctly falls through to `radius` here, exactly like
#     Abyssal Spasm's own case.
#   - Timber Chain/Chakram (both Timbersaw's): targeted casts with their
#     own per-level `range` field, same "distance <= radius" comparison
#     as Mark of Stillness's/Sanguine Bloom's own. Chakram ALSO has its own `radius`
#     field (the AoE size once it's already landed - see EnemySkillAI's
#     own _timbersaw_chakram_modifier()), but that's never what gates
#     whether the cast itself is reachable - the generic fallback chain
#     always prefers `range` first when a skill has both, same
#     "targeting range, not AoE radius" distinction Drowned Surge's own
#     level-4 splash radius already needs.
#   - Lil' Shredder/Mortimer Kisses (both Snapfire's): targeted casts
#     with no range/radius/distance field of their own - both are
#     described as "within normal attack range" (Snapfire's own is
#     always "range" type, so that's a real reach, not melee), so both
#     use the rival's own basic-attack range instead, same fallback
#     Thornbind/Whisper of the Veil/Glacier Breaker already use.
#   - Scatterblast (Snapfire's): DIRECTIONAL, not a plain "distance <=
#     radius" check the way every other AoE skill above is - it only
#     reaches the player when they're AHEAD of the rival in whichever
#     direction it's currently facing (mirroring the player's own
#     _cast_scatterblast()'s own "ahead" math), never behind or on the
#     wrong side of a shared column. battle.gd's own _enemy_skill_in_
#     range() special-cases this before ever reaching is_in_range()
#     below - it's still listed in RANGE_CHECKED_SKILL_IDS purely so
#     requires_range_check() reports it needs a check at all (the actual
#     comparison never runs through this file's own generic radius/
#     attack_range chain).
# Return to the Void is deliberately NOT range-checked at all (not in
# RANGE_CHECKED_SKILL_IDS below) - it "targets any enemy on the field,"
# with no range limit, mirroring the player's own _start_return_to_the_void_
# targeting()'s complete lack of a distance filter.
#   - Ensnare (Naga Siren's): a targeted cast with its own per-level
#     `range` field, same "distance <= radius" comparison as Mark of Stillness's/
#     Sanguine Bloom's own.
#   - Corrosive Haze (Slardar's ultimate): also a targeted cast with its
#     own per-level `range` field, same "distance <= radius" comparison
#     as Ensnare's own just above.
#   - Sacred Arrow (Mirana's): also a targeted cast with its own per-
#     level `range` field, same "distance <= radius" comparison as
#     Ensnare's/Corrosive Haze's own just above.
#   - Lucent Beam (Luna's): also a targeted cast with its own per-level
#     `range` field, same "distance <= radius" comparison as Sacred
#     Arrow's own just above.
# Naga Siren's Song of the Siren is deliberately NOT range-checked here
# either, despite being a self-centered AoE like Abyssal Spasm/Whirling
# Death above - unlike those two, it's scored (not gated) against range,
# the same "out of range scores low rather than being excluded outright"
# shape Mother's Grasp's/The Frost Tempest's own self-cast ultimates already use
# (see EnemySkillAI's own _naga_song_of_the_siren_modifier(), which reads
# `target_distance` itself). Mirror Image is a self-buff with no target
# of its own to reach at cast time at all, same as Bestial Rage/Rootveil/Woven Flesh above. Rip Tide is passive and never even reaches
# this file, same as Reactive Armor/Frostborn.
# Slardar's Slithereen Crush follows Song of the Siren's own precedent
# exactly - a self-centered AoE stun scored (not gated) against range via
# EnemySkillAI's own _slardar_slithereen_crush_modifier() (fed by
# `living_target_hps`, already empty out of range), so it's never in
# RANGE_CHECKED_SKILL_IDS either. Guardian Sprint is a self-buff with no
# target of its own to reach at cast time, same as Mirror Image above -
# its value is purely about what the boosted NEXT move can then reach
# (see EnemySkillAI's own _slardar_guardian_sprint_modifier()). Bash of
# the Deep is passive and never even reaches this file.
# Mirana's Starstorm follows Slithereen Crush's own precedent exactly - a
# self-centered AoE scored (not gated) against range via EnemySkillAI's
# own _mirana_starstorm_modifier() (fed by `living_target_hps`, already
# empty out of range), so it's never in RANGE_CHECKED_SKILL_IDS either.
# Leap is a self-directed hop with no target requirement at all to even
# attempt it, same as Firesnap Cookie above - it "sails clean over any
# enemy in the way" regardless of range (see battle.gd's own
# _activate_leap()). Moonlight Shadow is a self-buff with no target of
# its own to reach at cast time, same as Mirror Image/Guardian Sprint
# above.
# Luna's Eclipse is a self-cast ultimate with no target of its own to
# reach at cast time either, same as Moonlight Shadow above - its own
# radius moves with her and is scored (via EnemySkillAI's own _luna_
# eclipse_modifier()), never gated here. Moon Glaives and Lunar Blessing
# are both passive and never even reach this file.
# Every other known skill (Leeching Hunger, Depthsveil, Wildbond,
# Beast of the Elderwild, Elderwild Companion, Veil of the Forgotten, Frostbound Fangs, The Test of
# Time, Frost Daughter's own The Frost Tempest, Skarn's own Bestial Rage, and
# The Rootmother's own Rootveil/Woven Flesh/Mother's Grasp) is a
# self-buff/summon/AoE with no target to range-check, so this always
# reports those as in range - The Frost Tempest/Mother's Grasp in particular
# are centered on the caster's OWN position (see EnemySkillAI's own
# _fd_frost_tempest_modifier()/_tp_mothers_grasp_modifier()), never a
# selected enemy's, so there's nothing here to check range against in
# the first place, exactly like every other self-cast skill in this
# list; Bestial Rage/Rootveil/Woven Flesh are simpler still - no
# target of their own to reach at cast time at all (Rootveil's own
# "attack from stealth" follow-up reuses the player's normal Attack
# range/targeting, not a skill-cast range check here). Timbersaw's own
# Reactive Armor is passive and never even reaches this file - see
# battle.gd's ENEMY_KNOWN_SKILL_IDS/EnemyHeroManager's own
# KNOWN_ACTIVE_SKILL_IDS, neither of which lists it. Snapfire's own
# Firesnap Cookie is simpler still - a self-directed hop with no target
# requirement at all to even attempt it (mirroring the player's own
# _activate_firesnap_cookie(), which "never fails for lack of a target"
# the way Barbed Lunge/Abyssal Spasm/Thornbind can) - whether it actually LANDS
# somewhere useful is purely a scoring question (see EnemySkillAI's own
# _snapfire_firesnap_cookie_modifier()), never a candidacy gate here.
# ============================================================

const RANGE_CHECKED_SKILL_IDS: Array[String] = ["abyssal_spasm", "thornbind", "whisper_of_the_veil", "drowned_surge", "undertow", "the_sunken_one", "barbed_lunge", "mark_of_stillness", "the_hollow_cold", "touch_of_the_first_cold", "maddening_roar", "the_hunger_calls", "rimecleaver", "winters_grip", "frostbound_rupture", "charge", "glacier_breaker", "sanguine_bloom", "whirling_death", "timber_chain", "chakram", "lil_shredder", "mortimer_kisses", "scatterblast", "ensnare", "corrosive_haze", "sacred_arrow", "lucent_beam"]


## True if `skill_id` needs a range check at all before being cast -
## see the header comment above for which skills those are and why.
static func requires_range_check(skill_id: String) -> bool:
	return skill_id in RANGE_CHECKED_SKILL_IDS


## True if a rival hero standing `distance` columns from the player can
## reach them with `skill_id` right now. `radius` is Abyssal Spasm's own
## `radius` field, Drowned Surge's/Undertow's/The Sunken One's own `range`
## field, or Barbed Lunge's own `distance` field, depending on the skill (all
## compared the same way as "distance <= radius"); `attack_range` is the
## rival's basic-attack range for its type (0 for "melee", battle.gd's
## RANGE_ENEMY_ATTACK_RANGE for "range") - Thornbind/Whisper of the Veil piggyback
## on that since neither has a range field of its own. Any skill not in
## RANGE_CHECKED_SKILL_IDS always reports true here, matching
## requires_range_check().
static func is_in_range(skill_id: String, distance: int, radius: int, attack_range: int) -> bool:
	match skill_id:
		"abyssal_spasm", "drowned_surge", "undertow", "the_sunken_one", "barbed_lunge", "mark_of_stillness", "the_hollow_cold", "frostbound_rupture", "charge", "sanguine_bloom", "whirling_death", "timber_chain", "chakram", "ensnare", "corrosive_haze", "sacred_arrow", "lucent_beam":
			return distance <= radius
		"thornbind", "whisper_of_the_veil", "touch_of_the_first_cold", "maddening_roar", "the_hunger_calls", "rimecleaver", "winters_grip", "glacier_breaker", "lil_shredder", "mortimer_kisses":
			return distance <= attack_range
		_:
			# scatterblast never reaches this generic chain - battle.gd's
			# own _enemy_skill_in_range() special-cases its directional
			# check before ever calling in here (see this file's own
			# header comment).
			return true
