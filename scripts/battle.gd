extends Control

@onready var background: TextureRect = $Background
@onready var hero_image: TextureRect = $HeroImage
@onready var enemies_layer: Control = $EnemiesLayer
@onready var hp_bar: ProgressBar = $BarsBox/HPRow/HPBar
@onready var hp_value_label: Label = $BarsBox/HPRow/HPBar/HPValueLabel
@onready var mana_bar: ProgressBar = $BarsBox/ManaRow/ManaBar
@onready var mana_value_label: Label = $BarsBox/ManaRow/ManaBar/ManaValueLabel
@onready var xp_bar: ProgressBar = $BarsBox/XPRow/XPBar
@onready var xp_value_label: Label = $BarsBox/XPRow/XPBar/XPValueLabel
@onready var return_to_the_void_reserve_overlay: ColorRect = $BarsBox/HPRow/HPBar/ReturnToTheVoidReserveOverlay
@onready var frost_status_icon: PanelContainer = $BarsBox/HPRow/StatusIconRow/FrostIcon
@onready var curse_status_icon: PanelContainer = $BarsBox/HPRow/StatusIconRow/CurseIcon
@onready var root_status_icon: PanelContainer = $BarsBox/HPRow/StatusIconRow/RootIcon
@onready var ambient_tint_overlay: ColorRect = $AmbientTintOverlay
@onready var cast_flash_overlay: ColorRect = $CastFlashOverlay
@onready var skill_buttons_container: HBoxContainer = $SkillsPanel/SkillsMargin/SkillButtons
@onready var items_grid: GridContainer = $ItemsPanel/ItemsMargin/ItemsVBox/ItemsGrid
@onready var gold_value_label: Label = $ItemsPanel/ItemsMargin/ItemsVBox/GoldRow/GoldValueLabel
@onready var move_left_button: Button = $ActionsPanel/MoveRow/MoveLeftButton
@onready var move_right_button: Button = $ActionsPanel/MoveRow/MoveRightButton
@onready var attack_button: Button = $ActionsPanel/AttackButton
@onready var flee_button: Button = $FleeButton
@onready var defeat_popup: PanelContainer = $DefeatPopup
@onready var defeat_ok_button: Button = $DefeatPopup/DefeatMargin/DefeatVBox/DefeatOkButton
@onready var level_up_popup: PanelContainer = $LevelUpPopup
@onready var echo_popup: PanelContainer = $EchoPopup
@onready var echo_ok_button: Button = $EchoPopup/EchoMargin/EchoVBox/EchoOkButton
@onready var level_up_level_label: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/LevelUpLevelLabel
@onready var level_up_ok_button: Button = $LevelUpPopup/LevelUpMargin/LevelUpVBox/LevelUpOkButton
@onready var level_up_strength_old: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/StrengthOld
@onready var level_up_strength_new: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/StrengthNew
@onready var level_up_agility_old: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/AgilityOld
@onready var level_up_agility_new: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/AgilityNew
@onready var level_up_intelligence_old: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/IntelligenceOld
@onready var level_up_intelligence_new: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/IntelligenceNew
@onready var level_up_hp_old: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/HPOld
@onready var level_up_hp_new: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/HPNew
@onready var level_up_mana_old: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/ManaOld
@onready var level_up_mana_new: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/ManaNew
@onready var level_up_damage_old: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/DamageOld
@onready var level_up_damage_new: Label = $LevelUpPopup/LevelUpMargin/LevelUpVBox/StatsGrid/DamageNew
@onready var skill_choice_popup: PanelContainer = $SkillChoicePopup
@onready var skill_choice_points_label: Label = $SkillChoicePopup/SkillChoiceMargin/SkillChoiceVBox/SkillChoicePointsLabel
@onready var skill_choice_options: VBoxContainer = $SkillChoicePopup/SkillChoiceMargin/SkillChoiceVBox/SkillChoiceOptions
@onready var skill_choice_desc_popup: PanelContainer = $SkillChoiceDescPopup
@onready var skill_choice_desc_name_label: Label = $SkillChoiceDescPopup/SkillChoiceDescMargin/SkillChoiceDescVBox/SkillChoiceDescNameLabel
@onready var skill_choice_desc_label: Label = $SkillChoiceDescPopup/SkillChoiceDescMargin/SkillChoiceDescVBox/SkillChoiceDescLabel
@onready var skill_choice_desc_ok_button: Button = $SkillChoiceDescPopup/SkillChoiceDescMargin/SkillChoiceDescVBox/SkillChoiceDescButtons/OkButton
@onready var skill_choice_desc_cancel_button: Button = $SkillChoiceDescPopup/SkillChoiceDescMargin/SkillChoiceDescVBox/SkillChoiceDescButtons/CancelButton
@onready var stage_label: Label = $StagePanel/StageMargin/StageLabel

# Heroes/creeps (by their GameManager id) whose static art gets a
# CreatureAnimator (idle breathing/sway plus attack, hit, cast, move and
# death reactions), mapped to the animator's tuning profile. Everything
# not listed here stays a plain static portrait.
const ANIMATED_CREATURE_PROFILES := {
	"veyrik": "veyrik",
	"the_iron_abyss_melee": "iron_abyss_melee",
	"the_iron_abyss_melee_2": "iron_abyss_melee",
	"the_iron_abyss_range": "iron_abyss_range",
	"erynd": "erynd",
	"the_elderwild_melee": "elderwild_melee",
	"the_elderwild_melee_2": "elderwild_melee",
	"the_elderwild_range": "elderwild_range",
	"morvael": "morvael",
	"kingdom_of_morvain_melee": "morvain_melee",
	"kingdom_of_morvain_melee_2": "morvain_melee",
	"kingdom_of_morvain_range": "morvain_range",
	"kaelen_varr": "kaelen_varr",
	"the_ironbound_isles_melee": "ironbound_melee",
	"the_ironbound_isles_melee_2": "ironbound_melee",
	"the_ironbound_isles_range": "ironbound_range",
	"nhal": "nhal",
	"the_primordial_hunger": "the_primordial_hunger",
	"frostspire_melee": "frostspire_melee",
	"frostspire_melee_2": "frostspire_melee",
	"frostspire_range": "frostspire_range",
	"frost_daughter": "frost_daughter",
	"skarn": "skarn",
	"the_everfrost_melee": "everfrost_melee",
	"the_everfrost_melee_2": "everfrost_melee",
	"the_everfrost_range": "everfrost_range",
	"the_rootmother": "the_rootmother",
	"cinder": "cinder",
	"lunara": "lunara",
	"solara": "solara",
	"raze": "raze",
	# Scorchlands has its own creep art (the Verdant Scar ones above are separate).
	"the_verdant_scar_melee": "verdant_scar_melee",
	"the_verdant_scar_melee_2": "verdant_scar_melee",
	"the_verdant_scar_range": "verdant_scar_range",
	"scorchlands_melee": "scorchlands_melee",
	"scorchlands_melee_2": "scorchlands_melee",
	"scorchlands_range": "scorchlands_range",
	"the_blackbloom_melee": "blackbloom_melee",
	"the_blackbloom_melee_2": "blackbloom_melee",
	"the_blackbloom_range": "blackbloom_range",
	"the_last_empress": "the_last_empress",
	"dreadlure": "dreadlure",
	"drowned_empire_melee": "drowned_empire_melee",
	"drowned_empire_melee_2": "drowned_empire_melee",
	"drowned_empire_range": "drowned_empire_range",
	# A rival Erynd's own bear; the player's is attached in
	# _elderwild_companion() (it isn't spawned through _spawn_enemy()).
	"enemy_elderwild_companion": "elderwild_companion",
}

const BATTLE_ATMOSPHERE := preload("res://scripts/BattleAtmosphere.gd")

# Holds CreatureAnimator death dissolves and ProjectileFX shots, just
# above enemies_layer (so they draw over the creatures but under the UI).
# Separate because enemies_layer is wiped on every stage change/hero
# fight - usually right as the last kill's dissolve starts.
var _fx_layer: Control

# While an attack projectile is in flight, the node it's headed for -
# the damage lands immediately, but the CreatureAnimator hit reaction
# is held back until the projectile actually arrives (see
# _fire_enemy_projectile()).
var _deferred_hit_node: Control = null

# The battlefield is divided into 10 columns. Movement shifts by one
# column (1/10 screen width); "same space" for attacks/melee means
# matching column index.
const GRID_COLUMNS := 10

# How long a floating status message (_show_message_over_hero()/
# _show_message_over_enemy() - "No enemy in range", "Not enough mana",
# "Stunned!", an enemy's own cast-name banner, etc.) holds still and
# fully readable before it starts floating up and fading out. Previously
# both started the instant the message appeared, so a player barely had
# a moment to read it before it was already fading away.
const MESSAGE_READ_HOLD_DURATION := 1.0

# Pull of the Abyss's proc callout (see _show_rising_message_over()): deep
# blue text, with a light outline so the dark blue stays readable.
const PULL_OF_THE_ABYSS_TEXT_COLOR := Color(0.05, 0.2, 0.8, 1)
const PULL_OF_THE_ABYSS_TEXT_OUTLINE_COLOR := Color(0.85, 0.93, 1, 1)

# Every _start_X_targeting() function marks its valid targets with this
# highlight (see _highlight_valid_targets()) instead of each picking its
# own flat tint - those used to each land somewhere in the same pale,
# desaturated blue range (0.5-0.95 per channel), easy to lose against a
# similarly pale sprite or background. This pushes brightness well past
# 1.0 (an "overbright" modulate, the same trick _pulse_caster_sprite()'s
# own cast-feedback flash already uses) into a warm, saturated gold -
# high contrast against the game's mostly cool/icy palette - and pulses
# continuously between the two values below rather than sitting flat, so
# motion helps draw the eye too.
const TARGET_HIGHLIGHT_COLOR := Color(1.5, 1.2, 0.3, 1)
const TARGET_HIGHLIGHT_PULSE_COLOR := Color(1.9, 1.7, 0.7, 1)

# Lunar Ricochet' own bounce-hit flash (_flash_bounce_hit()) - same
# "overbright modulate" trick as TARGET_HIGHLIGHT_COLOR/
# _pulse_caster_sprite() above, just pushed toward red instead of gold
# or plain white brightness, so a bounced enemy visibly reads as "just
# got hit" rather than "something happened to it."
const BOUNCE_HIT_FLASH_COLOR := Color(1.8, 0.25, 0.25, 1)

# Thornbind's one-shot flash on cast (same overbright trick as
# BOUNCE_HIT_FLASH_COLOR, pushed toward green). The vines holding the
# target for as long as the root lasts are ThornbindVines' (see
# _refresh_thornbind_vines()).
const THORNBIND_FLASH_COLOR := Color(0.5, 1.8, 0.4, 1)

# The "empowered" enlargement (see _set_hero_enlarged()) - Spirit
# Link's and Frostbound Fangs' own visual while either is active: the
# sprite grows to this scale. The enlarged scale is stored as the
# node's "base_scale" meta, which _pulse_caster_sprite()/
# _flash_bounce_hit() return to instead of a hard-coded Vector2.ONE.
const HERO_ENLARGED_SCALE := 1.1

# Mote colors for _play_drain_effect(): Leeching Hunger's drained health
# in Veyrik's teal, any lifesteal in red (see _play_lifesteal_effect()).
const LEECHING_HUNGER_MOTE_COLOR := Color(0.2, 0.9, 0.8, 1.0)
const LIFESTEAL_MOTE_COLOR := Color(1.0, 0.2, 0.15, 1.0)

# Whisper of the Veil (see _play_whisper_of_the_veil_effect()): the
# overbright teal flash its target gets when the mist tendril strikes
# (same trick as BOUNCE_HIT_FLASH_COLOR).
const WHISPER_OF_THE_VEIL_FLASH_COLOR := Color(0.7, 1.8, 1.7, 1)

# The dirt kicked up when the ground bursts open (see _play_ground_dirt()).
const GROUND_DIRT_COLOR := Color(0.45, 0.32, 0.18, 1.0)

# Veil of the Forgotten's visuals (see _show_veil_shell() and friends): a
# shroud of swirling mist (mist_shroud.gdshader) wrapped around the
# shielded sprite, thinning with every hit it soaks up. The mist's color,
# the cast flash, and the color of the mist the cleanse lifts off and the
# break bursts into. The shroud is a child ColorRect of the sprite, named
# VEIL_SHELL_NAME so its presence can be looked up.
const VEIL_SHROUD_SHADER := preload("res://shaders/mist_shroud.gdshader")
const VEIL_MIST_COLOR := Color(0.6, 0.9, 0.88, 1.0)
const VEIL_FLASH_COLOR := Color(0.8, 1.6, 1.55, 1)
const VEIL_BURST_COLOR := Color(0.5, 0.95, 0.9, 0.8)
# How far the shroud reaches past the sprite on each side (fraction of its size).
const VEIL_SHROUD_MARGIN := 0.18
const VEIL_SHELL_NAME := "VeilShell"

# The Mist Remembers's visual (see _set_the_mist_remembers_visual()): a pulsing
# greenish-teal glow over the sprite for as long as it's active. It's
# an additive-blended copy of the sprite itself rather than a change to
# the sprite's own modulate/self_modulate, which the hit flashes,
# stealth fades and Thornbind's tint already own.
const THE_MIST_REMEMBERS_GLOW_COLOR := Color(0.25, 1.0, 0.75, 1.0)
const THE_MIST_REMEMBERS_GLOW_NAME := "MistRemembersGlow"
const THE_MIST_REMEMBERS_PULSE_SECONDS := 1.1
# Alongside the glow: mist rising from the ground and pouring into the
# sprite (mist_inflow.gdshader) - a surge as it triggers, then a gentler
# steady flow. It's a child ColorRect reaching past the sprite's sides
# and a little below its feet.
const THE_MIST_REMEMBERS_INFLOW_SHADER := preload("res://shaders/mist_inflow.gdshader")
const THE_MIST_REMEMBERS_INFLOW_NAME := "MistRemembersInflow"
const THE_MIST_REMEMBERS_SURGE_SECONDS := 1.8
const THE_MIST_REMEMBERS_STEADY_INTENSITY := 0.45

# The Hollow Cold's wound in the air (hollow_cold_tear.gdshader): a
# ragged tear opening onto a swirling nebula, torn open behind the unit
# it's cast on and left there for as long as the skill's DoT lasts (see
# _open_hollow_cold_tear()), with frost motes being drawn into it from
# across the skill's radius. Its rect's size relative to that unit's
# sprite, and how far it sits above the sprite's centre (in sprite
# heights).
const HOLLOW_COLD_TEAR_SHADER := preload("res://shaders/hollow_cold_tear.gdshader")
const HOLLOW_COLD_TEAR_SIZE := Vector2(0.8, 1.45)
const HOLLOW_COLD_TEAR_LIFT := 0.06

# Mark of Stillness's/The Hollow Cold's frost on a marked unit (see
# _set_mark_of_stillness_frost()/_play_the_hollow_cold_swirl()): the
# additive icy sheen over the sprite, the snowflakes, and the one-shot
# flash on cast (same overbright trick as BOUNCE_HIT_FLASH_COLOR). The
# frost is a child node named MARK_OF_STILLNESS_FROST_NAME, so - like The Mist
# Remembers's glow - it never touches the sprite's own modulate/
# self_modulate, which the hit flashes and Thornbind's tint own.
const MARK_OF_STILLNESS_SHEEN_COLOR := Color(0.35, 0.6, 0.95, 1.0)
const MARK_OF_STILLNESS_FLAKE_COLOR := Color(0.85, 0.95, 1.0, 1.0)
const MARK_OF_STILLNESS_FLASH_COLOR := Color(0.7, 1.3, 1.9, 1)
const MARK_OF_STILLNESS_FROST_NAME := "MarkOfStillnessFrost"

# How long Rimecleaver's frost lingers on everything it hit (see
# _flash_frost_briefly()) - it's a single burst with no DoT to keep the
# frost up, unlike Mark of Stillness/The Hollow Cold/Return to the Void/Winter's Grip.
const RIMECLEAVER_FROST_SECONDS := 2.5

# Drowned Surge's water spray color (see _play_drowned_surge_splash()).
const DROWNED_SURGE_SPRAY_COLOR := Color(0.55, 0.8, 1.0, 1.0)

# Same pulsing treatment as TARGET_HIGHLIGHT_COLOR/_PULSE_COLOR above,
# just in green rather than gold - marks the hero's own portrait as a
# valid target for a skill that can be self-cast (right now, only Whisper of the
# Veil - see _highlight_hero_self_target()). Deliberately a different
# hue rather than reusing the gold: for a skill like Whisper of the Veil that can
# be cast on either an enemy in range OR the hero, both highlights can
# be lit and pulsing at the same time, so they need to read as two
# distinct options rather than one ambiguous "the target."
const HERO_TARGET_HIGHLIGHT_COLOR := Color(0.3, 1.7, 0.5, 1)
const HERO_TARGET_HIGHLIGHT_PULSE_COLOR := Color(0.6, 2.0, 0.8, 1)

# Erynd's Elderwild Companion (elderwild_companion) always uses this art,
# regardless of skill level.
const ELDERWILD_COMPANION_IMAGE_PATH := "res://assets/heroes/Erynd Bear.png"
# Beast of the Elderwild's transformed portrait, likewise fixed regardless of level.
const BEAST_OF_THE_ELDERWILD_IMAGE_PATH := "res://assets/heroes/Erynd Ultimate.png"

# Width/height of the standard creature art (every creep, and most
# heroes) - see _creature_size().
const CREATURE_BASE_ASPECT := 1.5
# How much of the hero's own max HP he loses when the bear dies (see
# _apply_bear_death_penalty()).
const BEAR_DEATH_HP_PENALTY_PCT := 0.2
# A rival Erynd's companion is scaled down by this on top of its level
# percentages, so fighting him never feels like fighting two heroes.
const ENEMY_BEAR_STAT_MULT := 1.0

# While a rival skill whose damage lands only when its visual effect
# connects is still playing out - Kaelen Varr's The Sunken One
# broadside (see _cast_enemy_the_sunken_one()), Nhal's Touch of the
# First Cold (see _cast_enemy_touch_of_the_first_cold()) - the player
# can't act yet.
var _rival_fx_in_flight: bool = false

# The Last Empress's Imperial Guard (see _spawn_guard()): the art of one of
# her drowned warriors - the player's guards and a rival's alike.
const IMPERIAL_GUARD_IMAGE_PATH := "res://assets/heroes/The_Last_Empress_imperial_guard.png"

# The Primordial Hunger's The Test of Time (see _activate_the_test_of_time()) always
# uses this art for the hero's portrait while it's active, regardless
# of skill level - reverted back to the hero's own normal image
# (_hero_static.image) once it ends (see _end_the_test_of_time()).

# Skarn's Charge (see _play_charge()): how long he stays locked onto his
# prey with the battlefield dimmed around the two of them, and how long
# the charge itself takes (base + per column crossed).
const CHARGE_LOCK_ON_TIME := 0.8
const CHARGE_TRAVEL_BASE := 0.16
const CHARGE_TRAVEL_PER_COLUMN := 0.07
const CHARGE_DIM_ALPHA := 0.62
const CHARGE_LOCK_COLOR := Color(1.0, 0.25, 0.2)

# Lunara's Moonfall Lance (see _play_moonfall_lance_impact()) has no dedicated
# art asset, unlike the skills above - drawn instead as a plain pale
# moonlight-colored ColorRect that grows downward from above the target
# onto it, purely cosmetic and played alongside the instant,
# already-resolved damage (_resolve_moonfall_lance_cast()) rather than
# gating it, same split as The Sunken One's/Charge's own animation above.
const MOONFALL_LANCE_COLOR := Color(1.5, 1.6, 2.0, 0.85)
const MOONFALL_LANCE_WIDTH := 14.0
const MOONFALL_LANCE_FALL_HEIGHT := 220.0
const MOONFALL_LANCE_FALL_DURATION := 0.16

# Solara's Hope of the Fallen (see _play_hope_of_the_fallen_flight()) - no
# dedicated art asset, so the arrow is drawn from plain shapes (a
# glowing shaft, a pointed head, two fletching feathers) played
# alongside the already-resolved instant damage. Deliberately varied
# from Moonfall Lance's "grows down out of the sky" drop: it FLIES
# HORIZONTALLY in from the caster, trailing blue sparks, with a flight
# time that scales with the shot's own distance (HOPE_OF_THE_FALLEN_BASE_
# DURATION + HOPE_OF_THE_FALLEN_DURATION_PER_COLUMN per column travelled) -
# echoing the skill's own "more damage the further it travels" identity
# - instead of Moonfall Lance's fixed fall duration.
const HOPE_OF_THE_FALLEN_COLOR := Color(0.65, 1.3, 1.9, 0.9)
const HOPE_OF_THE_FALLEN_HEAD_COLOR := Color(0.9, 1.4, 2.0, 1.0)
const HOPE_OF_THE_FALLEN_FLETCH_COLOR := Color(0.45, 0.85, 1.6, 0.95)
const HOPE_OF_THE_FALLEN_SHAFT_WIDTH := 4.0
const HOPE_OF_THE_FALLEN_LENGTH := 64.0
const HOPE_OF_THE_FALLEN_BASE_DURATION := 0.12
# How long Solara's charge (the glow flowing from her to her bow) lasts before
# the arrow is loosed.
const HOPE_OF_THE_FALLEN_CHARGE_TIME := 0.6

# Solara's Fallen Grace (see _play_arrow_volley()): where the arrows leave
# her bow (fraction of her art, facing right - mirrored when she faces left),
# (the timing lives in ArrowRainFX). How many arrows fall
# on each target is the "grace_arrow" style's own "count" (ProjectileFX).
const SOLARA_BOW_TIP := Vector2(0.99, 0.23)

# Dreadlure's Paralytic Venom (see _play_paralytic_venom()): how long the
# toxin cloud takes to reach full size.
const PARALYTIC_VENOM_WAVE_SECONDS := 0.5
const HOPE_OF_THE_FALLEN_DURATION_PER_COLUMN := 0.025

# Skarn's Glacier Breaker (see _resolve_glacier_breaker_cast()) deliberately
# flips Charge's/The Sunken One's own "instant, already-resolved outcome,
# cosmetic animation layered on top" split: the knockback slide plays
# FIRST, then damage/death/stun are only resolved once it finishes (see
# _resolve_glacier_breaker_damage()) - so a lethal punch still visibly
# sends the target flying before it drops, instead of it just vanishing
# on the spot mid-hit.
const GLACIER_BREAKER_KNOCKBACK_DURATION := 0.35

var _hero_static: Dictionary = {}   # full definition from GameManager (stats, skills, image)
var _recruited: Dictionary = {}     # saved state from PlayerManager (current hp/mana/xp, chosen skill)

var _hero_pos_index: int = 1

# Each entry: {static, current_hp, current_main_stat_value, pos_index, node}
var _enemies: Array = []

# Turn state: exactly one action - move, attack, skill, or item - per
# turn, then the turn ends automatically (see _mark_turn_used()).
var _has_acted_this_turn: bool = false
var _battle_over: bool = false

# skill_id -> that skill's Button, for every LEARNED skill (level > 0).
# _update_action_buttons() toggles all of them with the turn; unlearned
# skills' buttons stay permanently disabled and aren't tracked here.
var _skill_buttons: Dictionary = {}

# skill_id -> turns remaining before it can be used again (0 = ready).
# Ticks down once per End Turn - see _tick_skill_cooldowns().
var _skill_cooldowns: Dictionary = {}
# skill_id -> the Label under that skill's button showing "Ready" or
# "N turns left".
var _skill_cooldown_labels: Dictionary = {}

# The skill_id currently shown in the level-up skill-choice
# description popup, awaiting OK/Cancel - not yet spent on.
var _pending_level_up_skill_id: String = ""

# ------------------------------------------------------------------
# Veyrik's Leeching Hunger: while active, Veyrik's next
# _leeching_hunger_attacks_remaining melee hits each heal him for
# _leeching_hunger_lifesteal_pct of the damage they deal (see
# _apply_leeching_hunger_steal()). It runs out after that many hits, or
# once _leeching_hunger_turns_remaining counts down to 0 (see
# _tick_leeching_hunger() / _end_leeching_hunger()), whichever is first.
# ------------------------------------------------------------------
var _leeching_hunger_active: bool = false
var _leeching_hunger_attacks_remaining: int = 0
var _leeching_hunger_lifesteal_pct: float = 0.0
var _leeching_hunger_turns_remaining: int = 0
# True from the moment the skill is cast until the first End Turn
# after that - the casting turn itself doesn't count against the
# duration, so this makes _tick_leeching_hunger() skip exactly one
# decrement before duration starts counting down for real.
var _leeching_hunger_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Veyrik's Depthsveil: while active, the hero is hidden (see
# _is_hero_hidden()) - regular enemy attacks can't land on him at all
# (see _enemy_turn()). His next Attack while hidden adds
# _depthsveil_bonus_damage on top of the normal roll (still mitigated
# by the target's armor same as any other damage) and ends the
# invisibility right there; casting any OTHER skill also ends it
# early with no bonus damage; using an item does not. Otherwise it
# just runs out on its own after _depthsveil_turns_remaining turns.
# ------------------------------------------------------------------
var _depthsveil_active: bool = false
var _depthsveil_bonus_damage: float = 0.0
var _depthsveil_turns_remaining: int = 0
# Same "doesn't count on the casting turn" behavior as Leeching Hunger's
# duration - see _leeching_hunger_duration_pending_start.
var _depthsveil_duration_pending_start: bool = false

# ------------------------------------------------------------------
# The Rootmother's Rootveil: functionally the same invisibility
# as Veyrik's own Depthsveil - folded into the very same _is_hero_
# hidden() check, so every "enemies can't target or chase a hidden
# hero" rule in _enemy_turn() already applies here for free - just with
# a different payoff for the Attack that breaks it: instead of bonus
# damage, the target gets rooted (root_turns_left, the same shared
# per-enemy field Thornbind's own root uses and _tick_enemy_turn_start_
# effects() already ticks down - it can still attack/cast/use items while rooted,
# same as any other rooted enemy) for _rootveil_root_turns turns.
# Casting any OTHER skill still just ends it early with no root, same
# as Depthsveil's own "no bonus damage" rule for that case. While
# active, the hero also moves a flat +1 column further per move (see
# _hero_move_distance()) - moving unseen covers more ground.
# ------------------------------------------------------------------
var _rootveil_active: bool = false
var _rootveil_root_turns: int = 0
var _rootveil_turns_remaining: int = 0
var _rootveil_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Solara's ultimate, Ambush Strike: functionally the same
# invisibility as Veyrik's own Depthsveil - folded into the very same
# _is_hero_hidden() check, so every "enemies can't target or chase a
# hidden hero" rule in _enemy_turn() already applies here for free, and
# the same bonus-damage-on-breaking-Attack payoff too, just as a
# PERCENTAGE of the attack's own rolled damage (bonus_damage_pct,
# applied AFTER the roll) rather than Depthsveil's own flat pre-roll
# bonus_damage - see _apply_hero_attack()'s own read of whichever of
# the two is actually active (only one hero's kit ever has either, but
# each still gets its own flag/fields rather than reusing Shadow
# Dance's, same reasoning Rootveil's own separate flag above
# already follows). Casting any OTHER skill still just ends it early
# with no bonus damage, same as Depthsveil's own rule for that case.
# ------------------------------------------------------------------
var _ambush_strike_active: bool = false
var _ambush_strike_bonus_damage_pct: float = 0.0
var _ambush_strike_turns_remaining: int = 0
var _ambush_strike_duration_pending_start: bool = false

# ------------------------------------------------------------------
# The Rootmother's Woven Flesh: a self-cast that adds a flat
# bonus_armor (folded into _hero_armor(), same slot Wildbond's own
# bonus armor uses) plus a flat bonus_hp_regen healed every turn on top
# of the hero's own baseline passive regen (_apply_passive_hero_regen()
# - same "bonus stacks on top of the baseline" relationship Arcane
# Aura's own regen already has) for the duration. Same "casting turn
# doesn't count" pattern as every other duration-based buff (see
# _tick_woven_flesh()).
# ------------------------------------------------------------------
var _woven_flesh_active: bool = false
var _woven_flesh_bonus_armor: float = 0.0
var _woven_flesh_bonus_hp_regen: float = 0.0
var _woven_flesh_turns_remaining: int = 0
var _woven_flesh_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Dreadlure's Hunting Instinct: a self-cast that arms this level's own
# bonus_movement/charge_damage_pct for `level_data.duration` turns -
# doesn't move the hero itself (casting just consumes the turn like any
# other self-buff), it only changes what his NEXT normal moves do (see
# _hero_move()'s own read of _hunting_instinct_turns_remaining). While
# active, a move adds bonus_movement to the usual distance AND always
# stops on the first enemy in its path (the melee "stop on top of an
# enemy" rule _melee_move_target() already uses, applied here
# regardless of range_type), dealing charge_damage_pct of a freshly-
# rolled hero Attack to whatever it stopped on - no stun, just the hit.
# Same "casting turn doesn't count" pattern as every other duration-
# based buff (see _tick_hunting_instinct()).
# ------------------------------------------------------------------
var _hunting_instinct_turns_remaining: int = 0
var _hunting_instinct_bonus_movement: int = 0
var _hunting_instinct_charge_damage_pct: float = 0.0
var _hunting_instinct_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Cinder's Kindled Resolve: a passive - no cast, no cooldown/mana
# spend of its own. Every hit the hero takes (see apply_damage())
# earns one stack, each with its OWN independent turns-remaining
# counter (unlike every other duration-based buff above, which only
# ever tracks one shared timer for the whole effect) so stacks fall
# off individually rather than all at once. Gaining a stack past this
# level's own max_stacks drops the oldest one first, same as it being
# replaced. Folds bonus_armor_per_stack * stack count into _hero_armor()
# (same slot Woven Flesh's/Wildbond's own bonus armor use) and
# heals bonus_hp_regen_per_stack * stack count every hero turn
# (_apply_kindled_resolve_regen(), same timing/stacking relationship as
# Frostborn's/the baseline passive regen).
# ------------------------------------------------------------------
var _kindled_resolve_stack_turns: Array[int] = []

# ------------------------------------------------------------------
# The Primordial Hunger's Frostbound Fangs: while active, the hero's plain Attacks
# get a flat bonus_damage (folded into _roll_hero_damage(), same slot
# Depthsveil's/Beast of the Elderwild's own bonus damage use) and
# extra reach (folded into _hero_attack_column_range(), so ranged
# targeting opens further out too), for this level's own `attacks`
# count of Attacks or `duration` turns - whichever runs out first, same
# two-limits race as Leeching Hunger's attacks_remaining/turns_remaining
# (see _apply_frostbound_fangs_attack()/_tick_frostbound_fangs()). Recasting
# while a previous activation is still running just overwrites it
# outright.
# ------------------------------------------------------------------
var _frostbound_fangs_active: bool = false
var _frostbound_fangs_bonus_damage: float = 0.0
var _frostbound_fangs_bonus_range: int = 0
var _frostbound_fangs_attacks_remaining: int = 0
var _frostbound_fangs_turns_remaining: int = 0
var _frostbound_fangs_duration_pending_start: bool = false

# ------------------------------------------------------------------
# The Primordial Hunger's The Test of Time: a defensive self-cast that lifts
# the hero into the air under a ticking clock (TimeStillFX), makes him
# fully immune to
# damage (see apply_damage()), heals him once per turn, and locks out
# EVERY other action - move, attack, skill, or item (see _hero_move()/
# _on_attack_pressed()/_on_skill_pressed()/_on_item_pressed()) - for the
# duration, same "casting turn doesn't count" pattern as every other
# buff (see _tick_the_test_of_time()). With no action possible, the turn
# auto-skips straight through to the next one (_end_turn()'s own tail),
# the same way a stunned turn does. Casting it also dispels every OTHER
# effect currently on the hero, good or bad, before establishing itself
# (see _dispel_all_hero_effects(), called from _activate_the_test_of_time()).
# ------------------------------------------------------------------
var _the_test_of_time_active: bool = false
var _the_test_of_time_heal_per_turn: float = 0.0
var _the_test_of_time_turns_remaining: int = 0
var _the_test_of_time_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Raze's ultimate, Kiss the Wastes: a targeted channel, not a
# self-cast buff like The Test of Time above, but locked out the same way -
# move, attack, skill, and item are all disabled for its whole
# duration (same 7 check sites The Test of Time already touches: _populate_
# item_grid(), _on_item_pressed(), _on_skill_pressed(), _hero_move(),
# _on_attack_pressed(), _update_action_buttons(), _apply_tutorial_
# gate()). Unlike The Test of Time, an unable-to-act turn here doesn't just
# skip - it AUTO-FIRES one shot instead, from _end_turn()'s own tail
# (see the block right before it reopens the action buttons), for
# level_data.hits total shots counting the cast turn's own immediate
# one (_resolve_kiss_the_wastes_cast() fires that first one directly;
# _kiss_the_wastes_turns_left only tracks the REMAINING auto-fired
# ones). _kiss_marked_enemy is a live Dictionary reference into
# _enemies - reading its own "pos_index" tracks it turn to turn while
# it's alive, and keeps returning wherever it died once it isn't (see
# _fire_kiss_the_wastes_shot()'s own comment - _kill_enemy() only ever
# removes a dead enemy from the _enemies array, it never mutates the
# Dictionary's own fields).
# ------------------------------------------------------------------
var _kiss_the_wastes_active: bool = false
var _kiss_the_wastes_turns_left: int = 0
var _kiss_marked_enemy: Dictionary = {}
var _kiss_the_wastes_level_data: Dictionary = {}

# ------------------------------------------------------------------
# The Last Empress's Imperial Guard: a cast, from anywhere on the board,
# that raises this level's own `guards` count (3) of drowned warriors around
# the enemy closest to the hero (see _activate_imperial_guard()) - each a
# Dictionary of {pos_index, current_hp, max_hp, facing, node, hp_label} in
# `_guards`, own HP pool sized off `hp_pct` of the hero's own max HP. They
# are real units on the board, like the Elderwild Companion: every turn
# (_guards_turn(), just before the enemies') each one strikes an enemy
# sharing its column - melee range, for `damage_pct` of a freshly-rolled
# hero Attack - or, with none there, walks toward the nearest enemy,
# turning left or right as it goes. The enemies fight them back: a creep
# attacks the hero if he's in its reach, and the guards only when he
# isn't (see _enemy_turn()). Same "casting turn doesn't count" pattern as
# every other duration-based buff. Ends (despawning every surviving guard)
# once the duration runs out; recasting mid-duration replaces the set
# outright, same as Woven Flesh/Cinderbomb's own "recast overwrites" reasoning.
# ------------------------------------------------------------------
var _guards: Array = []
var _guard_damage_pct: float = 0.0
## Chance (the level's hit_chance_pct) that an enemy's basic attack on the
## hero lands on one of his guards instead - see _try_redirect_hit_to_guard().
var _guard_redirect_chance: float = 0.0

## Solara's Withering Pursuit: for `_withering_miss_turns` enemy phases after
## the cast, each enemy basic attack on her misses with this chance (see
## _enemy_attack_misses_hero()). Ticked down once per End Turn alongside the
## other durations.
var _withering_miss_chance: float = 0.0
var _withering_miss_turns: int = 0
var _guards_turns_remaining: int = 0
var _guards_duration_pending_start: bool = false

# ------------------------------------------------------------------
# The Primordial Hunger's ultimate, The Hunger Calls: freezes a target enemy
# (target["stun_turns_left"], same shared per-enemy field Drowned Surge's/
# Return to the Void's own stun already uses) for `level_data.duration` of its
# own turns. There's no separate duration counter for the "nearby
# enemies pile onto it instead of the hero" half of the effect either -
# _is_the_hunger_calls_active() derives it straight from that same stun
# counter, so both halves always wear off together. _enemy_turn()
# captures whether the curse is active once at the very top of each
# full enemy-turn pass (see its own `curse_active`/`curse_target_pos`
# locals) rather than re-checking per enemy, so every enemy this turn
# sees the same answer even though the target's own stun_turns_left
# ticks down partway through that same pass.
# ------------------------------------------------------------------
var _hunger_calls_target: Dictionary = {}
var _hunger_calls_bonus_damage_pct: float = 0.0
var _hunger_calls_range: int = 0
# Its look (HungerCallsFX) while it holds - the player's cast, and a
# rival's cast on the player or his Elderwild Companion. Kept in sync
# with the curse's state by _refresh_hunger_calls_fx().
var _hunger_calls_fx: HungerCallsFX = null
var _enemy_hunger_calls_fx: HungerCallsFX = null
var _enemy_hunger_calls_fx_on_bear: bool = false

# ------------------------------------------------------------------
# Frost Daughter's ultimate, The Frost Tempest: a self-cast that deals
# this level's own damage to every enemy within radius columns of the
# hero's CURRENT position (re-checked fresh every tick, not fixed at
# cast time - so it follows him if he moves) at the start of every
# turn for the duration, same "casting turn doesn't count" pattern as
# every other buff (see _tick_frost_tempest()).
# ------------------------------------------------------------------
var _frost_tempest_active: bool = false
var _frost_tempest_damage_per_turn: float = 0.0
var _frost_tempest_radius: int = 0
var _frost_tempest_turns_remaining: int = 0
var _frost_tempest_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Lunara's ultimate, Eternal Eclipse: a self-cast that, at the start of every turn
# for as long as beams remain, fires ETERNAL_ECLIPSE_BEAMS_PER_TURN beams (or
# however many are left, if fewer) at random living, targetable enemies
# within radius columns of the hero's CURRENT position (re-checked
# fresh every tick, same as The Frost Tempest's own radius above - so it
# follows her if she moves), each for this level's own damage. Ends the
# instant every beam has landed, rather than running a fixed number of
# turns like The Frost Tempest's own duration does. Same "casting turn
# doesn't count" pattern as every other buff (see _tick_eternal_eclipse()).
# ------------------------------------------------------------------
var _eternal_eclipse_active: bool = false
var _eternal_eclipse_damage_per_beam: float = 0.0
var _eternal_eclipse_radius: int = 0
var _eternal_eclipse_beams_remaining: int = 0
var _eternal_eclipse_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Cinder's ultimate, Cinderbomb: a targeted cast that deals this
# level's own cast_damage to the target and every enemy within radius
# columns of the target's position AT CAST TIME, then plants a marker
# there - fixed at that snapshot, unlike The Frost Tempest's own
# hero-centered radius above, which re-checks the hero's current
# position every tick - dealing damage_per_turn to every enemy within
# radius columns of that FIXED spot at the start of every turn for the
# duration (same "casting turn doesn't count" pattern as every other
# duration-based buff). Empty dictionary means no cinderbomb is currently
# planted; see _resolve_cinderbomb_cast()/_tick_cinderbomb()/
# _despawn_cinderbomb().
# ------------------------------------------------------------------
var _cinderbomb: Dictionary = {}

# ------------------------------------------------------------------
# Skarn's Frostbound Rupture: on cast, deals a straight instant hit to the
# target, then walls off a line of columns - starting on the hero's OWN
# column and continuing toward the target, `blocked_columns` of them
# total - for the duration (see _is_column_frostbound_rupture_blocked(),
# checked from every plain-movement decision in _enemy_turn()/
# _enemy_hero_turn()). Fixed at cast time, unlike The Frost Tempest's own
# radius - the wall doesn't follow the hero if he moves afterward.
# Recasting while a previous wall is still up simply replaces it
# outright - there's nothing to give back, same as Frostbound Fangs/The Hunger
# Calls.
# ------------------------------------------------------------------
var _frostbound_rupture_active: bool = false
var _frostbound_rupture_blocked_columns: Array[int] = []
var _frostbound_rupture_turns_remaining: int = 0
var _frostbound_rupture_duration_pending_start: bool = false

# Frostbound Rupture's walls (see _refresh_frostbound_rupture_visuals()/
# _build_ice_block()): drawn as a cluster of jagged ice crystals per
# walled column rather than loaded from an image - the crystals' body/
# facet/outline colors, how tall the block is relative to a creature,
# and how many crystals make one up.
const FROSTBOUND_RUPTURE_BODY_COLOR := Color(0.62, 0.85, 1.0, 0.72)
const FROSTBOUND_RUPTURE_FACET_COLOR := Color(0.88, 0.97, 1.0, 0.8)
const FROSTBOUND_RUPTURE_OUTLINE_COLOR := Color(0.4, 0.68, 0.95, 0.9)
const FROSTBOUND_RUPTURE_HEIGHT_RATIO := 0.62
const FROSTBOUND_RUPTURE_CRYSTALS_PER_BLOCK := 4

# One ice block per currently-walled column (either side's - both use
# the same visual), keyed by column, kept in sync by
# _refresh_frostbound_rupture_visuals() every time either side's own blocked-
# columns list changes: new columns get a block rising out of the
# ground, columns no longer walled have theirs shatter, and columns
# that stay walled keep theirs untouched. Keyed by column (not tracked
# per side) so a column walled by both at once only ever gets one.
var _frostbound_rupture_wall_nodes: Dictionary = {}

# ------------------------------------------------------------------
# Skarn's Bestial Rage: a self-cast that adds a flat bonus_damage to the
# hero's own Attacks (folded into _roll_hero_damage(), same slot
# Frostbound Fangs'/Leeching Hunger's/Beast of the Elderwild's own bonus damage use) for
# the duration - no attack-count cap, unlike Frostbound Fangs, just a plain
# turn-based buff. Same "casting turn doesn't count" pattern as every
# other duration-based buff (see _tick_bestial_rage()).
# ------------------------------------------------------------------
var _bestial_rage_active: bool = false
var _bestial_rage_bonus_damage: float = 0.0
var _bestial_rage_turns_remaining: int = 0
var _bestial_rage_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Erynd's Elderwild Companion (elderwild_companion): a persistent ally
# that fights alongside the hero. {} when no bear is out (see
# _is_bear_alive()); otherwise {hp, current_hp, damage_min,
# damage_max, armor, speed, pos_index, node}. It lives outside
# _enemies/enemies_layer entirely, so stage transitions - which only
# clear those - leave it untouched (see _load_enemies(),
# _start_hero_fight()); it's only ever removed by _despawn_bear()
# (recasting the skill, or the hero fleeing the scene entirely) or by
# _kill_bear() (an enemy brings its HP to 0 - notably not the same
# path as _kill_enemy(), so it never grants XP/gold - though it does
# cost the hero HP of his own, see _apply_bear_death_penalty()).
# ------------------------------------------------------------------
var _bear: Dictionary = {}

# The rival hero's single-target skills that can be aimed at the
# player's Elderwild Companion instead of the player himself - see
# _choose_enemy_skill_on_bear() for how the AI picks between the two,
# and each skill's own _cast_enemy_*_on_bear() for what it does to the
# bear. Skills left out are either about the player's own position
# (Undertow, The Sunken One/Chainfire's line, Cinderbomb's/Frostbound
# Rupture' placement, Kiss the Wastes' channel, Rimecleaver's area) or
# not targeted at all; those still reach the bear through their own
# AoE collateral, same as before.
const ENEMY_BEAR_TARGETABLE_SKILLS: Array[String] = [
	"thornbind", "whisper_of_the_veil", "drowned_surge", "deathlight_lure", "hope_of_the_fallen",
	"moonfall_lance", "shackles", "mark_of_stillness", "the_hollow_cold", "touch_of_the_first_cold",
	"return_to_the_void", "maddening_roar", "the_hunger_calls", "winters_grip", "charge",
	"glacier_breaker", "sanguine_bloom", "three_cheers",
]

# Set by _cast_enemy_skill() for the duration of one cast: true when
# the rival's current skill is aimed at the player's Elderwild Companion rather
# than the player (see _choose_enemy_skill_on_bear()). Each bear-
# targetable _cast_enemy_*() checks it first and hands off to its own
# _cast_enemy_*_on_bear() counterpart.
var _enemy_skill_on_bear: bool = false

# Set by _cast_enemy_skill() for the duration of one cast: true when the
# rival's current Whisper of the Veil is aimed at himself (the self-heal - see
# EnemySkillAI.WHISPER_OF_THE_VEIL_SELF_ID) rather than at the player or his bear.
var _enemy_whisper_of_the_veil_self: bool = false

# True while the player's current stun came from a rival's Luring Gaze
# - purely cosmetic, so the trance (see _refresh_luring_gaze_
# trances()) shows for that stun and not for any other stun sharing
# _player_stun_turns_left. Cleared once that stun runs out.
var _player_luring_gaze_entranced: bool = false
# Set by a rival's Paralytic Venom alongside its stun - drives the held state
# (see _refresh_venom_paralysis()).
var _player_venom_paralyzed: bool = false

# Whether the player is hidden from the rival for the turn being
# decided right now (see _enemy_hero_turn()) - lets the skill picker
# still consider the bear as a target while the player himself can't
# be seen.
var _enemy_ai_hero_hidden: bool = false

# ------------------------------------------------------------------
# Erynd's Wildbond: while active, the hero gets a flat armor
# bonus (folded into _hero_armor()) and lifesteal on his Attacks - a % of an Attack's
# damage, taken AFTER the target's armor has already reduced it, paid
# back as HP (see _apply_wildbond_lifesteal(), called only from
# _apply_hero_attack() - skill damage never triggers it). Same
# "casting turn doesn't count" duration pattern as Leeching Hunger/
# Depthsveil. Recasting simply overwrites the running values with
# the new cast's, so there's no need to end the old one first.
# ------------------------------------------------------------------
var _wildbond_active: bool = false
var _wildbond_lifesteal_pct: float = 0.0
var _wildbond_bonus_armor: float = 0.0
var _wildbond_turns_remaining: int = 0
var _wildbond_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Erynd's Blood of the Wild: a passive (no button press, no mana, no
# cooldown - see _populate_skill_buttons()'s "passive" branch) that
# turns itself on and off automatically based on the hero's own HP%,
# recalculated every time the bars refresh (_update_blood_of_the_wild_state,
# called from _refresh_bars()). Uses hysteresis rather than a single
# threshold - see _update_blood_of_the_wild_state() - so it doesn't flicker
# on/off turn to turn while HP hovers in the 50-80% band. While
# active, both _hero_move_distance() and incoming damage on the hero
# (apply_damage()) AND the bear (_deal_damage_to_bear()) read the
# bonus movement/damage reduction below; while inactive they're 0, so
# nothing extra needs to be undone when it turns off.
# ------------------------------------------------------------------
var _blood_of_the_wild_active: bool = false
var _blood_of_the_wild_bonus_movement: int = 0
var _blood_of_the_wild_damage_reduction_pct: float = 0.0
# The skill button slot's status label ("Passive"/"Active"/
# "Inactive"), captured when _populate_skill_buttons() builds it, so
# _update_blood_of_the_wild_state() can keep it current live.
var _blood_of_the_wild_status_label: Label = null

# ------------------------------------------------------------------
# Erynd's ultimate, Beast of the Elderwild: transforms the hero into a bear
# for the duration - swaps his portrait to BEAST_OF_THE_ELDERWILD_IMAGE_PATH (and
# back to his normal one on expiry), grants bonus max HP (added to his
# CURRENT HP too the moment it's granted, then taken back off again on
# expiry, clamped so it can never do that part below 1 - see
# _activate_beast_of_the_elderwild()/_end_beast_of_the_elderwild()), bonus damage (folded into
# _roll_hero_damage() the same way Leeching Hunger's/Depthsveil's
# bonus damage is), and forces melee range for the duration regardless
# of his own range_type stat (see _is_ranged_hero()) - so if he's
# normally ranged, Attack just resolves as a melee hit on whatever
# shares his own column instead of opening ranged targeting. Same
# "casting turn doesn't count" duration pattern as the other buffs.
# ------------------------------------------------------------------
var _beast_of_the_elderwild_active: bool = false
var _beast_of_the_elderwild_bonus_hp: float = 0.0
var _beast_of_the_elderwild_bonus_damage: float = 0.0
var _beast_of_the_elderwild_turns_remaining: int = 0
var _beast_of_the_elderwild_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Morvael's Veil of the Forgotten: a self-cast shield with its own HP pool
# that absorbs incoming damage in the hero's place (see
# apply_damage()) until either its duration runs out (fades quietly,
# see _tick_veil_of_the_forgotten()) or enough damage drains it to 0 (see
# apply_damage()/_end_veil_of_the_forgotten()) - in which case it explodes,
# dealing _veil_of_the_forgotten_aoe_damage to every enemy within
# _veil_of_the_forgotten_radius columns of the hero, the same radius-around-
# a-position AoE concept Abyssal Spasm uses (_cast_abyssal_spasm()). Casting
# it also dispels every negative effect currently on the player - root,
# a hostile Thornbind's damage-over-time and Barbed Lunge's stun (see
# _activate_veil_of_the_forgotten()) - except
# silence, since _on_skill_pressed() already refuses to cast ANY skill
# while silenced, so that debuff can never still be active by the time
# this one goes off.
# ------------------------------------------------------------------
var _veil_of_the_forgotten_active: bool = false
var _veil_of_the_forgotten_hp: float = 0.0
var _veil_of_the_forgotten_aoe_damage: float = 0.0
var _veil_of_the_forgotten_radius: int = 0
var _veil_of_the_forgotten_turns_remaining: int = 0
var _veil_of_the_forgotten_duration_pending_start: bool = false

# ------------------------------------------------------------------
# Morvael's The Mist Remembers: not cast at all - it auto-activates once
# the hero's own HP falls to or below a level-based threshold (see
# apply_damage()/_maybe_auto_activate_the_mist_remembers()), then for its
# duration every attack that would otherwise damage the hero heals him
# instead (a full reversal, not just a reduction - see apply_damage()
# again). Its cooldown reuses the same generic _skill_cooldowns/
# _skill_cooldown_labels tracking every manually-cast skill uses (see
# _populate_skill_buttons()'s "auto_activate" branch), started the
# moment it auto-activates rather than by a button press.
# ------------------------------------------------------------------
var _the_mist_remembers_active: bool = false
var _the_mist_remembers_heal_conversion_pct: float = 0.0
var _the_mist_remembers_turns_remaining: int = 0
var _the_mist_remembers_duration_pending_start: bool = false

# Kaelen Varr's Pull of the Abyss: a passive counter of plain Attacks landed (see
# _maybe_consume_pull_of_the_abyss_stack(), called from _apply_hero_attack())
# - never reset by a turn going by without attacking, only by another
# empowered hit consuming it once this level's own hits_to_activate is
# reached. No duration, no on/off state to track - unlike every buff
# above, so just the one counter.
var _pull_of_the_abyss_attack_count: int = 0

# Dreadlure's Might of the Deep - same "count plain Attacks toward a
# threshold, consume them all once reached" idiom as Pull of the Abyss's own
# counter just above (see _maybe_consume_might_of_the_deep_stack(),
# called from _apply_hero_attack()).
var _might_of_the_deep_attack_count: int = 0

# ------------------------------------------------------------------
# A rival hero's own skills, during a hero fight (_in_hero_fight) -
# see _enemy_hero_turn()/_cast_enemy_skill() and everything below it.
# This is the enemy-side mirror of the block above: same skills, same
# mechanics, just cast by the boss at the player instead of by the
# player at his enemies. Reset fresh for each new hero fight by
# _reset_enemy_hero_state() (called from _start_hero_fight()), since
# nothing here should carry over from a previously-fought rival.
# ------------------------------------------------------------------

# The full hero definition (stats, skills) of whichever rival is
# currently being fought - "" is a full hero_static.get("id","") away
# for _enemy_hero_id, the more commonly needed value. Both are {}/""
# outside a hero fight.
var _enemy_hero_static: Dictionary = {}
var _enemy_hero_id: String = ""

var _enemy_max_mana: float = 0.0
var _enemy_current_mana: float = 0.0

# The rival's Health/Mana Potions for this fight - seeded from whatever
# PlayerManager.get_npc_potion_count() says they've actually got banked
# (see _reset_enemy_hero_state()), same as their skill levels are read
# live from PlayerManager rather than reset to some fixed loadout. Each
# drink (_drink_enemy_health_potion()/_drink_enemy_mana_potion()) writes
# the new count straight back to PlayerManager too, so a rival that
# survives the duel - by winning it (_handle_defeat()) or by the player
# fleeing it (_on_flee_pressed()) - keeps whatever it didn't use, and
# EnemyHeroManager.npc_shop() tops it back up (gold
# permitting) before the next encounter, exactly mirroring how the
# simulation restocks after every fight of its own.
var _enemy_potion_health_count: int = 0
var _enemy_potion_mana_count: int = 0

# skill_id -> turns remaining before the rival hero can cast it again -
# the enemy-side mirror of the player's own _skill_cooldowns. Unlike
# the player's, these never persist between fights (see
# _reset_enemy_hero_state()) - a freshly re-challenged rival always
# starts every skill ready.
var _enemy_skill_cooldowns: Dictionary = {}

# Veyrik's Leeching Hunger, cast by the rival: the mirror of the player's
# own copy - its next hits heal the rival for a share of the damage they
# deal to the player.
var _enemy_leeching_hunger_active: bool = false
var _enemy_leeching_hunger_attacks_remaining: int = 0
var _enemy_leeching_hunger_lifesteal_pct: float = 0.0
var _enemy_leeching_hunger_turns_remaining: int = 0
var _enemy_leeching_hunger_duration_pending_start: bool = false

# Veyrik's Depthsveil, cast by the rival: while active the boss can't
# be targeted by any of the player's attacks or targeted skills (see
# _is_target_hidden(), checked from _get_enemy_at()/
# _start_ranged_targeting()/_start_thornbind_targeting()/
# _cast_abyssal_spasm()) and skips the player's own retaliation-avoidance
# entirely - rather, HIS retaliation against the player still happens
# normally (see _enemy_hero_turn()); only being attacked back is
# blocked.
var _enemy_depthsveil_active: bool = false
var _enemy_depthsveil_bonus_damage: float = 0.0
var _enemy_depthsveil_turns_remaining: int = 0
var _enemy_depthsveil_duration_pending_start: bool = false

# Erynd's Wildbond, cast by the rival on himself.
var _enemy_wildbond_active: bool = false
var _enemy_wildbond_lifesteal_pct: float = 0.0
var _enemy_wildbond_bonus_armor: float = 0.0
var _enemy_wildbond_turns_remaining: int = 0
var _enemy_wildbond_duration_pending_start: bool = false

# Erynd's Beast of the Elderwild, cast by the rival on himself. No forced-
# melee-range or portrait-swap-on-a-dedicated-node concept is needed
# here the way the player's own copy has one - Beast of the Elderwild just swaps
# the boss's existing enemy node's texture (see
# _activate_enemy_beast_of_the_elderwild()/_end_enemy_beast_of_the_elderwild()) and adds bonus
# hp/damage.
var _enemy_beast_of_the_elderwild_active: bool = false
var _enemy_beast_of_the_elderwild_bonus_hp: float = 0.0
var _enemy_beast_of_the_elderwild_bonus_damage: float = 0.0
var _enemy_beast_of_the_elderwild_turns_remaining: int = 0
var _enemy_beast_of_the_elderwild_duration_pending_start: bool = false

# Erynd's Blood of the Wild, on the rival - same automatic hysteresis
# as the player's own copy, just re-evaluated once per rival turn (see
# _update_enemy_blood_of_the_wild_state()) rather than after every HP change,
# since there's no bars UI to keep live for an enemy.
var _enemy_blood_of_the_wild_active: bool = false
var _enemy_blood_of_the_wild_damage_reduction_pct: float = 0.0

# Morvael's Veil of the Forgotten, cast by the rival on himself.
var _enemy_veil_of_the_forgotten_active: bool = false
var _enemy_veil_of_the_forgotten_hp: float = 0.0
var _enemy_veil_of_the_forgotten_aoe_damage: float = 0.0
var _enemy_veil_of_the_forgotten_radius: int = 0
var _enemy_veil_of_the_forgotten_turns_remaining: int = 0
var _enemy_veil_of_the_forgotten_duration_pending_start: bool = false

# Morvael's The Mist Remembers, on the rival - same auto-activate-off-HP%
# pattern as the player's own copy: nothing ever "casts" this, it just
# triggers itself from _deal_fixed_damage_to_enemy() the moment the
# rival's HP crosses this level's threshold - see
# _maybe_auto_activate_enemy_the_mist_remembers().
var _enemy_the_mist_remembers_active: bool = false
var _enemy_the_mist_remembers_heal_conversion_pct: float = 0.0
var _enemy_the_mist_remembers_turns_remaining: int = 0
var _enemy_the_mist_remembers_duration_pending_start: bool = false

# Kaelen Varr's Pull of the Abyss, on the rival - same plain-Attack counter as the
# player's own copy, just counting the rival's own Attacks on the
# player instead (see _maybe_consume_enemy_pull_of_the_abyss_stack(), called
# from _resolve_enemy_hero_attack()).
var _enemy_pull_of_the_abyss_attack_count: int = 0

# Dreadlure's Might of the Deep, on the rival - same "count plain Attacks
# toward a threshold, consume them all once reached" idiom as
# Pull of the Abyss's own counter just above (see
# _maybe_consume_enemy_might_of_the_deep_stack(), called from
# _resolve_enemy_hero_attack()).
var _enemy_might_of_the_deep_attack_count: int = 0

# Dreadlure's Hunting Instinct, on the rival - mirrors the player's own
# _hunting_instinct_bonus_movement/_hunting_instinct_charge_damage_pct/
# _hunting_instinct_turns_remaining/_hunting_instinct_duration_pending_
# start fields exactly: a self-buff that boosts the rival's own NEXT
# moves (see _enemy_hero_turn()'s own movement fallback) rather than an
# instant leap - doesn't move the rival itself when cast.
var _enemy_hunting_instinct_bonus_movement: int = 0
var _enemy_hunting_instinct_charge_damage_pct: float = 0.0
var _enemy_hunting_instinct_turns_remaining: int = 0
var _enemy_hunting_instinct_duration_pending_start: bool = false

# Solara's ultimate, Ambush Strike, cast by the rival - mirrors Shadow
# Dance's own shape above: while active the boss can't be targeted by any
# of the player's attacks or targeted skills (see _is_target_hidden()/
# _update_enemy_hero_visibility(), both extended to also read this flag),
# and its own bonus_damage_pct folds into the rival's next Attack as a
# PERCENTAGE of the roll (see _resolve_enemy_hero_attack()), same "post-
# roll percentage" shape Might of the Deep's own bonus uses, rather than
# Depthsveil's flat pre-roll one. Reveals itself (ends) the instant
# that empowered Attack actually lands, whether or not it kills the
# player - same "one guaranteed hit, then the invisibility is spent"
# rule the player-side copy follows in _apply_hero_attack().
var _enemy_ambush_strike_active: bool = false
var _enemy_ambush_strike_bonus_damage_pct: float = 0.0
var _enemy_ambush_strike_turns_remaining: int = 0
var _enemy_ambush_strike_duration_pending_start: bool = false

# Lunara's ultimate, Eternal Eclipse, cast by the rival - mirrors the player's own
# _eternal_eclipse_active/_eternal_eclipse_damage_per_beam/_eternal_eclipse_radius/_eternal_eclipse_
# beams_remaining/_eternal_eclipse_duration_pending_start fields exactly: fires
# ETERNAL_ECLIPSE_BEAMS_PER_TURN beams per End Turn (see _tick_enemy_eternal_eclipse()),
# each independently picking ONE random living, targetable candidate from
# everything within radius columns of the rival's CURRENT position - the
# player, one of his own guards, or his own Elderwild Companion, all equally
# likely (see _tick_enemy_eternal_eclipse()'s own docstring) - with NO cap on how
# many beams the same candidate can take. Doesn't lock the rival's own
# actions while it's ticking, same as the player-side copy.
var _enemy_eternal_eclipse_active: bool = false
var _enemy_eternal_eclipse_damage_per_beam: float = 0.0
var _enemy_eternal_eclipse_radius: int = 0
var _enemy_eternal_eclipse_beams_remaining: int = 0
var _enemy_eternal_eclipse_duration_pending_start: bool = false

# Kaelen Varr's Undertow, on the rival - unlike the player's own
# copy, the target is always the player (the only other participant in
# a hero fight, same simplification Abyssal Spasm/Whisper of the Veil/Drowned Surge already
# use), so there's nothing to hold onto but a single pending flag - see
# _cast_enemy_undertow()/_enemy_hero_turn()'s own teleport check at its
# very top.
var _enemy_undertow_pending: bool = false

# The Primordial Hunger's Frostbound Fangs, cast by the rival on themselves - mirrors
# the player's own _activate_frostbound_fangs()/_apply_frostbound_fangs_attack()/
# _tick_frostbound_fangs()/_end_frostbound_fangs(): bonus damage/range for this
# level's own `attacks` count of Attacks, or `duration` turns, whichever
# runs out first.
var _enemy_frostbound_fangs_active: bool = false
var _enemy_frostbound_fangs_bonus_damage: float = 0.0
var _enemy_frostbound_fangs_bonus_range: int = 0
var _enemy_frostbound_fangs_attacks_remaining: int = 0
var _enemy_frostbound_fangs_turns_remaining: int = 0
var _enemy_frostbound_fangs_duration_pending_start: bool = false

# The Primordial Hunger's The Test of Time, cast by the rival on themselves - mirrors
# the player's own _activate_the_test_of_time()/_tick_the_test_of_time()/
# _end_the_test_of_time(): full damage immunity (see
# _deal_fixed_damage_to_enemy()) plus a heal every turn, for the
# duration - during which the rival can't move or attack (see
# _enemy_hero_turn()'s own lockout) but CAN still cast another skill,
# same as the player's own copy only blocks Move/Attack, never
# _on_skill_pressed(). Casting it also dispels every other effect
# currently on the rival, good or bad - see
# _dispel_all_enemy_hero_effects().
var _enemy_the_test_of_time_active: bool = false
var _enemy_the_test_of_time_heal_per_turn: float = 0.0
var _enemy_the_test_of_time_turns_remaining: int = 0
var _enemy_the_test_of_time_duration_pending_start: bool = false

# Frost Daughter's The Frost Tempest, cast by the rival on herself - mirrors
# the player's own _activate_frost_tempest()/_tick_frost_tempest()/
# _end_frost_tempest(): every tick that counts against the duration,
# whichever of the player/rival is within `radius` columns of the
# rival's OWN current position takes `damage_per_turn` (re-checked fresh
# each tick, not fixed at cast time, same as the player's own copy) -
# see _tick_enemy_frost_tempest().
var _enemy_frost_tempest_active: bool = false
var _enemy_frost_tempest_damage_per_turn: float = 0.0
var _enemy_frost_tempest_radius: int = 0
var _enemy_frost_tempest_turns_remaining: int = 0
var _enemy_frost_tempest_duration_pending_start: bool = false

# Skarn's Frostbound Rupture, cast by the rival - mirrors the player's own
# _resolve_frostbound_rupture_cast()/_tick_frostbound_rupture()/_end_frostbound_rupture(): walls
# off `blocked_columns` columns, starting on the rival's OWN column and
# continuing toward the player's, for the duration - see
# _is_column_enemy_frostbound_rupture_blocked(), checked from _hero_move() so
# the player can't step into (or act from within) a walled column,
# mirroring how the player's own _is_column_frostbound_rupture_blocked() gates
# every enemy's own movement in _enemy_turn()/_enemy_hero_turn(). Never
# blocks the RIVAL's own movement - same asymmetry the player's own copy
# already has (see _hero_move(), which never checks its own wall).
var _enemy_frostbound_rupture_active: bool = false
var _enemy_frostbound_rupture_blocked_columns: Array[int] = []
var _enemy_frostbound_rupture_turns_remaining: int = 0
var _enemy_frostbound_rupture_duration_pending_start: bool = false

# Skarn's Bestial Rage, cast by the rival on himself - mirrors the player's
# own _activate_bestial_rage()/_tick_bestial_rage()/_end_bestial_rage(): a flat
# bonus_damage added to _roll_enemy_hero_damage() for the duration, same
# "add to the bonus sum" spot Frostbound Fangs' own bonus_damage already
# occupies there.
var _enemy_bestial_rage_active: bool = false
var _enemy_bestial_rage_bonus_damage: float = 0.0
var _enemy_bestial_rage_turns_remaining: int = 0
var _enemy_bestial_rage_duration_pending_start: bool = false

# The Rootmother's Rootveil, cast by the rival on himself -
# mirrors the player's own _activate_rootveil()/_tick_rootveil()/_end_rootveil(): folded into _is_target_hidden() (the
# enemy-side mirror of the player's own _is_hero_hidden()) so the
# player can't target/select the hidden boss, same as Depthsveil's own
# copy - see _is_target_hidden()/_update_enemy_hero_visibility(). The
# Attack that breaks it roots the player instead of dealing bonus damage
# - see _resolve_enemy_hero_attack()'s own "attacking_from_enemy_
# rootveil" capture.
var _enemy_rootveil_active: bool = false
var _enemy_rootveil_root_turns: int = 0
var _enemy_rootveil_turns_remaining: int = 0
var _enemy_rootveil_duration_pending_start: bool = false

# The Rootmother's Woven Flesh, cast by the rival on himself - mirrors
# the player's own _activate_woven_flesh()/_tick_woven_flesh()/
# _end_woven_flesh(): bonus_armor folds into _enemy_hero_bonus_armor()
# (the same slot Wildbond's own bonus armor already uses there), bonus_hp_regen heals the rival on top of his own
# baseline passive regen (_tick_enemy_passive_regen()) every tick - see
# _tick_enemy_woven_flesh().
var _enemy_woven_flesh_active: bool = false
var _enemy_woven_flesh_bonus_armor: float = 0.0
var _enemy_woven_flesh_bonus_hp_regen: float = 0.0
var _enemy_woven_flesh_turns_remaining: int = 0
var _enemy_woven_flesh_duration_pending_start: bool = false

# Cinder's Kindled Resolve, on the rival - mirrors the player's own
# _kindled_resolve_stack_turns/_apply_kindled_resolve_stack()/_tick_
# kindled_resolve_stacks()/_apply_kindled_resolve_regen(): each entry is
# one stack's own remaining-turns counter, ticking down independently
# (unlike every other duration-based buff in this file, which only ever
# tracks one shared timer). Stacked from _deal_fixed_damage_to_enemy()
# every time a hit actually lands on the boss, folded into _enemy_hero_
# bonus_armor() for the armor half and healed via
# _apply_enemy_kindled_resolve_regen() for the regen half - see
# _apply_enemy_kindled_resolve_stack().
var _enemy_kindled_resolve_stack_turns: Array[int] = []

# Cinder's ultimate, Cinderbomb, on the rival - mirrors the player's own
# _cinderbomb field/_resolve_cinderbomb_cast()/_tick_cinderbomb()/_despawn_
# cinderbomb(): a targeted cast that deals this level's own cast_damage to
# the player (the only possible initial-AoE target in a hero fight - see
# _cast_enemy_cinderbomb()'s own "no cleave" simplification every other
# rival AoE already uses), then plants the cinderbomb at the player's
# CURRENT position at that moment (never re-checked against where the
# player moves to afterward), dealing damage_per_turn to the player
# every tick they're still within radius columns of that fixed spot, for
# the duration. Empty dictionary means no cinderbomb is currently planted;
# see _cast_enemy_cinderbomb()/_tick_enemy_cinderbomb()/_despawn_enemy_
# cinderbomb().
var _enemy_cinderbomb: Dictionary = {}

# Raze's ultimate, Kiss the Wastes, on the rival - mirrors the
# player's own _kiss_the_wastes_active/_kiss_the_wastes_turns_left/
# _kiss_the_wastes_level_data field shape (see that block's own comment
# for the full lock-site list): channels for `hits` turns, unable to
# move/attack/cast another skill/use items for the duration - see
# _enemy_hero_turn()'s own top-of-function lockout. Unlike the player's
# own _kiss_marked_enemy, there's no separate "marked enemy"
# reference to hold here - the only possible target in a hero fight is
# the player himself, tracked live via _hero_pos_index, which (unlike a
# creep) never needs a "last known column" fallback since the battle
# would already be over if he'd died.
var _enemy_kiss_the_wastes_active: bool = false
var _enemy_kiss_the_wastes_turns_left: int = 0
var _enemy_kiss_the_wastes_level_data: Dictionary = {}

# The Last Empress's Imperial Guard, cast by the rival - the same skill as
# the player's own (see the block above _guards), just on the other side:
# a cast raises this level's `guards` count of drowned warriors around the
# player-side unit CLOSEST to the boss (the hero, his Elderwild Companion
# or one of his own guards), and each entry in _enemy_guards is the same
# {pos_index, current_hp, max_hp, facing, node, hp_label, enemy} Dictionary
# the player's guards use, own HP pool sized off `hp_pct` of the boss's own
# effective max HP. Every rival turn (_enemy_guards_turn(), after the
# player's guards and before the creeps') each one strikes whoever of the
# player's side shares its column - the hero first, if he's there and
# visible, else the bear, else one of his guards, for `damage_pct` of a
# freshly-rolled rival Attack - or, with nobody there, walks toward the
# nearest of them, turning as it goes. The player's guards, AoE skills and
# a melee Attack in the same column can all hit them back. Empress's Will's
# own bonuses (extra_guard, guardians_damage_bonus_pct, guard_duration_
# bonus) are folded straight in at cast time, read fresh off
# _get_enemy_empress_will_level_data() - a no-op while the rival hasn't
# learned it, same "empty means locked" convention every other auto-
# triggered skill's own level-data getter uses.
var _enemy_guards: Array = []
var _enemy_guard_damage_pct: float = 0.0
var _enemy_guards_turns_remaining: int = 0
var _enemy_guards_duration_pending_start: bool = false

# ------------------------------------------------------------------
# What the rival's skills above do TO THE PLAYER. All of this only
# ever gets set during a hero fight and is reset by
# _reset_enemy_hero_state() before each new one.
# ------------------------------------------------------------------

# Thornbind's root/silence/damage-over-time, cast by the rival on the
# player - the mirror of _apply_root(), just aimed at the player
# instead of an enemy. Root blocks _hero_move(); silence blocks
# _on_skill_pressed(); the DoT ticks at the start of the player's own
# turn, alongside everything else in _tick_player_turn_start_effects().
var _player_root_turns_left: int = 0
# True while that root came from a rival's Shackles - purely cosmetic, so the
# chains (see _refresh_shackles()) show for it and for no other root.
var _player_shackled: bool = false
var _player_silence_turns_left: int = 0
var _player_thornbind_dot_damage: float = 0.0
var _player_thornbind_dot_turns_left: int = 0

# Barbed Lunge's stun on the player - counts down once per _end_turn() call
# while > 0, each time skipping the player's own action entirely and
# immediately re-triggering _end_turn() again (see its tail) so the
# rival keeps acting until it wears off, the same way a stunned enemy
# just loses its turn to the player's own Barbed Lunge.
var _player_stun_turns_left: int = 0
# _player_stun_turns_left as _end_turn() began - lets it tell a stun already
# in force (consumes this turn) from one a rival just landed (starts next turn).
var _stun_before_enemy_phase: int = 0

# Set alongside _player_stun_turns_left specifically by
# _cast_enemy_the_hunger_calls() (see that function's own comment on why
# it collapses onto the shared stun field) - purely cosmetic, so the
# frost screen tint/status icon can tell "frozen by The Hunger Calls"
# apart from a Drowned Surge/Barbed Lunge/Return to the Void/Winter's Grip stun, all of which
# also just set the same field. Cleared wherever the stun itself is
# (a fresh dispel or the stun's own natural countdown reaching 0).
var _player_the_hunger_calls_active: bool = false

# Mark of the Mist's stacks/DoT on the player, built by the rival's own
# plain Attacks - the mirror of the same fields _apply_mark_of_the_mist_
# stack() writes onto an enemy Dictionary, just held as battle-local
# vars since there's only one player to track them on. Silence isn't
# among them - it shares the _player_silence_turns_left field above,
# same as how a cursed enemy shares its own silence_turns_left with
# Thornbind.
var _player_curse_stacks: int = 0
var _player_curse_active: bool = false
var _player_curse_dot_damage: float = 0.0
var _player_curse_dot_turns_left: int = 0
var _player_curse_last_hit_turn: int = 0

# Nhal's Mark of Stillness/The Hollow Cold, cast by the rival on the
# player - both are plain damage-over-time, so both mirror Thornbind's
# own _player_thornbind_dot_* fields exactly, just held separately (each
# under its own dedicated pair of fields) since a different skill's DoT
# shouldn't silently share or clobber another's counters, the same
# reasoning the player-side per-enemy mark_of_stillness_dot_*/the_hollow_cold_dot_*
# fields already follow.
var _player_mark_of_stillness_dot_damage: float = 0.0
var _player_mark_of_stillness_dot_turns_left: int = 0
var _player_the_hollow_cold_dot_damage: float = 0.0
var _player_the_hollow_cold_dot_turns_left: int = 0

# Every The Hollow Cold tear currently open (see _open_hollow_cold_tear()),
# each {"tear": ColorRect, "motes": CPUParticles2D, "pos_index": int,
# "turns_left": int, "hits_player_side": bool}. A tear counts down at the
# same moment its DoT ticks - the start of the enemy turn for the
# player's casts, the start of the player's turn for the rival's (see
# _tick_hollow_cold_tears()) - and seals shut once it runs out.
var _hollow_cold_tears: Array[Dictionary] = []

# Nhal's Return to the Void, cast by the rival on the player -
# mirrors the player-side per-enemy return_to_the_void_dot_damage/return_to_the_void_dot_
# turns_left/return_to_the_void_execute_pct fields (see _resolve_return_to_the_void_
# cast()), just held as battle-local vars since there's only one player
# to track them on. The stun shares _player_stun_turns_left above, same
# as Drowned Surge's own stun does.
var _player_return_to_the_void_dot_damage: float = 0.0
var _player_return_to_the_void_dot_turns_left: int = 0
var _player_return_to_the_void_execute_pct: float = 0.0

# Frost Daughter's Winter's Grip, cast by the rival on the player - mirrors
# the player-side per-enemy winters_grip_dot_damage/winters_grip_dot_turns_
# left fields (see _resolve_winters_grip_cast()), just held as battle-local
# vars since there's only one player to track them on. The stun shares
# _player_stun_turns_left above, same as Drowned Surge's/Return to the Void's own stun
# does.
var _player_winters_grip_dot_damage: float = 0.0
var _player_winters_grip_dot_turns_left: int = 0
# True while the player's own stun came from a rival's Winter's Grip -
# its ice hands (WintersGripHands) hold him until that stun runs out.
# Enemies/the bear carry the same as a "winters_grip_hold" field. See
# _refresh_winters_grip_hands().
var _player_winters_grip_hold: bool = false

# The Rootmother's Sanguine Bloom, cast by the rival on the player -
# mirrors the player-side per-enemy sanguine_bloom_dot_damage/sanguine_bloom_
# heal_per_turn/sanguine_bloom_dot_turns_left fields (see _resolve_sanguine_bloom_cast()), just held as battle-local vars since there's only one
# player to track them on. Unlike every other DoT here, the healing half
# goes to the CASTER (the rival), not the player - see _tick_player_
# turn_start_effects()'s own "sanguine_bloom" case, which heals the boss
# directly (via _get_hero_fight_boss()) each tick instead.
var _player_sanguine_bloom_dot_damage: float = 0.0
var _player_sanguine_bloom_heal_per_turn: float = 0.0
var _player_sanguine_bloom_dot_turns_left: int = 0

# The Rootmother's ultimate, Mother's Grasp, cast by the rival - mirrors
# the player-side per-enemy mothers_grasp_dot_damage/mothers_grasp_dot_turns_
# left fields (see _activate_mothers_grasp()), just held as battle-local
# vars since there's only one player to track them on. The root shares
# _player_root_turns_left above, the same field Thornbind's own root
# already uses - Mother's Grasp's own "can't move, can still attack/cast/
# use items" rule is exactly what that field already means everywhere
# it's checked (_hero_move()), so there's nothing extra to enforce here.
var _player_mothers_grasp_dot_damage: float = 0.0
var _player_mothers_grasp_dot_turns_left: int = 0

# Raze's Three Cheers, cast by the rival on the player - mirrors
# the player-side per-enemy armor_reduction/armor_reduction_turns_left
# fields (see _resolve_three_cheers_cast()), just held as battle-local
# vars since there's only one player to track them on. Folded into
# _hero_armor() as a straight subtraction, same "runtime field, never
# touching the static template" reasoning the enemy-side version uses.
var _player_armor_reduction: float = 0.0
var _player_armor_reduction_turns_left: int = 0

# Dreadlure's ultimate, Deathlight Lure, cast by the rival on the player -
# mirrors the player-side per-enemy "deathlight_lure_bonus_pct" field
# (see _resolve_deathlight_lure_cast()), just held as a battle-local var
# since there's only one player to track it on. Read by apply_damage()
# to boost every hit the player takes from the rival's own attacks/
# skills, mirroring _deal_fixed_damage_to_enemy()'s own "is_hero_action"
# check. Shares _player_armor_reduction_turns_left above as its own
# turns-left counter, same "share the shred's own timer" convention the
# player-side copy uses (see _resolve_deathlight_lure_cast()'s own
# comment) - Deathlight Lure's own armor_reduction half is folded
# straight into that same shared field, additively, rather than getting
# a second one of its own.
var _player_deathlight_lure_bonus_pct: float = 0.0

# Raze's ultimate, Kiss the Wastes, cast by the rival on the player -
# mirrors the player-side per-enemy kiss_burn_dot_damage/kiss_
# burn_dot_turns_left fields (see _fire_kiss_the_wastes_shot()), just
# held as battle-local vars since there's only one player to track them
# on.
var _player_kiss_burn_dot_damage: float = 0.0
var _player_kiss_burn_dot_turns_left: int = 0

# ------------------------------------------------------------------
# Ranged-hero target selection: when true, the enemies in
# _valid_targets are highlighted and clickable; clicking one resolves
# either a plain attack or a targeted skill, depending on
# _targeting_purpose ("attack" or a skill id like "thornbind" or
# "whisper_of_the_veil") - see _on_enemy_clicked(). Whisper of the Veil additionally lets
# the player click the hero's own portrait instead (self-cast) - see
# _on_hero_image_gui_input()/_resolve_whisper_of_the_veil_self_cast(). Every
# _start_X_targeting() function marks _valid_targets via the shared
# _highlight_valid_targets() (see TARGET_HIGHLIGHT_COLOR/_PULSE_COLOR),
# whose pulsing tweens are tracked here so _cancel_targeting() can kill
# them before resetting modulate back to normal.
var _targeting_mode: bool = false
var _valid_targets: Array = []
var _targeting_purpose: String = "attack"
var _target_highlight_tweens: Array = []

# Thornbind's level data, held from the moment its target-picking
# starts (_start_thornbind_targeting) until a target is actually
# clicked (_resolve_thornbind_cast) - mana/cooldown/turn are only spent
# once that click resolves, same as a normal ranged Attack.
var _pending_thornbind_level_data: Dictionary = {}

# Whisper of the Veil's level data, held the same way as Thornbind's above, from
# the moment _start_whisper_of_the_veil_targeting() opens targeting until either
# an enemy or the hero's own portrait is clicked
# (_resolve_whisper_of_the_veil_enemy_cast()/_resolve_whisper_of_the_veil_self_cast()).
var _pending_whisper_of_the_veil_level_data: Dictionary = {}

# Kaelen Varr's Drowned Surge, held the same way as Thornbind's/Whisper of the Veil's own
# pending level data above, from the moment _start_drowned_surge_targeting()
# opens targeting until a target is actually clicked
# (_resolve_drowned_surge_cast()).
var _pending_drowned_surge_level_data: Dictionary = {}

# Kaelen Varr's Undertow, held the same way while its own targeting
# is open (_start_undertow_targeting()) until a target is clicked
# (_resolve_undertow_cast()).
var _pending_undertow_level_data: Dictionary = {}

# Undertow's actual mark, set once _resolve_undertow_cast() spends
# the cast and held until the hero's own NEXT turn opens (_end_turn()),
# at which point he teleports onto the marked enemy's CURRENT position
# (see _resolve_undertow_teleport()) - wherever it's moved to by then -
# for free, without spending that turn's action. `target` is the marked
# enemy's own Dictionary reference (live - its "pos_index" updates as it
# moves, so reading it later reads wherever it ended up), {} meaning no
# mark is pending. `stage_generation` is _stage_generation at the moment
# of marking, so a stage transition/hero fight change in between (a
# fresh _enemies array, making `target` a stale reference into a fight
# that's already over) fizzles the mark instead of teleporting into
# nothing - see _resolve_undertow_teleport().
var _pending_undertow_target: Dictionary = {}
var _pending_undertow_stage_generation: int = -1

# Cinder's Chainfire, held the same way as every other targeted
# skill's own pending level data above, from the moment
# _start_chainfire_targeting() opens targeting until a target is
# actually clicked (_resolve_chainfire_cast()).
var _pending_chainfire_level_data: Dictionary = {}

# Cinder's Cinderbomb, held the same way as every other targeted
# skill's own pending level data above, from the moment _start_cinderbomb_
# targeting() opens targeting until a target is actually clicked
# (_resolve_cinderbomb_cast()).
var _pending_cinderbomb_level_data: Dictionary = {}

# Raze's Three Cheers, held the same way as every other targeted
# skill's own pending level data above, from the moment _start_lil_
# cheers_targeting() opens targeting until a target is actually
# clicked (_resolve_three_cheers_cast()).
var _pending_three_cheers_level_data: Dictionary = {}

# Raze's Kiss the Wastes, held the same way as every other targeted
# skill's own pending level data above, from the moment _start_
# kiss_the_wastes_targeting() opens targeting until a target is
# actually clicked (_resolve_kiss_the_wastes_cast()).
var _pending_kiss_the_wastes_level_data: Dictionary = {}

# The Last Empress's Shackles, held the same way as every other targeted
# skill's own pending level data above, from the moment _start_shackles_
# targeting() opens targeting until a target is actually clicked
# (_resolve_shackles_cast()).
var _pending_shackles_level_data: Dictionary = {}

# Dreadlure's Deathlight Lure, held the same way as every other targeted
# skill's own pending level data above, from the moment _start_
# deathlight_lure_targeting() opens targeting until a target is actually
# clicked (_resolve_deathlight_lure_cast()).
var _pending_deathlight_lure_level_data: Dictionary = {}

# Solara's Hope of the Fallen, held the same way as every other targeted
# skill's own pending level data above, from the moment _start_
# hope_of_the_fallen_targeting() opens targeting until a target is actually
# clicked (_resolve_hope_of_the_fallen_cast()).
var _pending_hope_of_the_fallen_level_data: Dictionary = {}

# Lunara's Moonfall Lance, held the same way as every other targeted skill's
# own pending level data above, from the moment _start_moonfall_lance_
# targeting() opens targeting until a target is actually clicked
# (_resolve_moonfall_lance_cast()).
var _pending_moonfall_lance_level_data: Dictionary = {}

# Nhal's Mark of Stillness, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_mark_of_stillness_targeting() opens targeting until a target is
# actually clicked (_resolve_mark_of_stillness_cast()).
var _pending_mark_of_stillness_level_data: Dictionary = {}

# Nhal's The Hollow Cold, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_the_hollow_cold_targeting() opens targeting until a target is
# actually clicked (_resolve_the_hollow_cold_cast()).
var _pending_the_hollow_cold_level_data: Dictionary = {}

# Nhal's Touch of the First Cold, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_touch_of_the_first_cold_targeting() opens targeting until a target is
# actually clicked (_resolve_touch_of_the_first_cold_cast()).
var _pending_touch_of_the_first_cold_level_data: Dictionary = {}

# Nhal's Return to the Void, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_return_to_the_void_targeting() opens targeting until a target is
# actually clicked (_resolve_return_to_the_void_cast()).
var _pending_return_to_the_void_level_data: Dictionary = {}

# The Primordial Hunger's Maddening Roar, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_maddening_roar_targeting() opens targeting until a target is
# actually clicked (_resolve_maddening_roar_cast()).
var _pending_maddening_roar_level_data: Dictionary = {}

# The Primordial Hunger's ultimate, The Hunger Calls, held the same way as every
# other targeted skill's own pending level data above, from the moment
# _start_the_hunger_calls_targeting() opens targeting until a target is
# actually clicked (_resolve_the_hunger_calls_cast()).
var _pending_the_hunger_calls_level_data: Dictionary = {}

# Frost Daughter's Rimecleaver, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_rimecleaver_targeting() opens targeting until a target is
# actually clicked (_resolve_rimecleaver_cast()).
var _pending_rimecleaver_level_data: Dictionary = {}

# Frost Daughter's Winter's Grip, held the same way as every other targeted
# skill's own pending level data above, from the moment
# _start_winters_grip_targeting() opens targeting until a target is
# actually clicked (_resolve_winters_grip_cast()).
var _pending_winters_grip_level_data: Dictionary = {}

# Skarn's Frostbound Rupture, held the same way as every other targeted skill's
# own pending level data above, from the moment _start_frostbound_rupture_
# targeting() opens targeting until a target is actually clicked
# (_resolve_frostbound_rupture_cast()).
var _pending_frostbound_rupture_level_data: Dictionary = {}

# Skarn's Charge, held the same way as every other targeted skill's
# own pending level data above, from the moment _start_charge_
# targeting() opens targeting until a target is actually clicked
# (_resolve_charge_cast()).
var _pending_charge_level_data: Dictionary = {}

# Skarn's ultimate, Glacier Breaker, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_glacier_breaker_targeting() opens targeting until a target is
# actually clicked (_resolve_glacier_breaker_cast()).
var _pending_glacier_breaker_level_data: Dictionary = {}

# The Rootmother's Sanguine Bloom, held the same way as every other
# targeted skill's own pending level data above, from the moment
# _start_sanguine_bloom_targeting() opens targeting until a target is
# actually clicked (_resolve_sanguine_bloom_cast()).
var _pending_sanguine_bloom_level_data: Dictionary = {}

const RANGE_ENEMY_ATTACK_RANGE := 3
const RANGE_ENEMY_FLEE_DISTANCE := 1


## A ranged enemy's attack reach in columns: its own "attack_range" if it
## has one (a rival hero whose data sets it - e.g. Cinder, 1), otherwise
## RANGE_ENEMY_ATTACK_RANGE.
func _enemy_attack_range(enemy: Dictionary) -> int:
	var own: int = int(enemy.get("static", {}).get("attack_range", -1))
	return own if own > 0 else RANGE_ENEMY_ATTACK_RANGE


## Whether a ranged enemy backs away from the hero standing `hero_distance`
## columns off - never one whose reach is no longer than the distance it
## would back away from, or it would never get to attack at all.
func _enemy_flees_at(enemy: Dictionary, hero_distance: int) -> bool:
	return hero_distance <= RANGE_ENEMY_FLEE_DISTANCE and _enemy_attack_range(enemy) > RANGE_ENEMY_FLEE_DISTANCE

# Every ACTIVE skill a rival hero might cast during a hero fight - the
# full candidate pool _pick_enemy_ready_skill() checks for cooldown/
# worth-casting/mana/range before handing survivors to EnemySkillAI to
# score and pick from (the same pool EnemyHeroManager.
# KNOWN_ACTIVE_SKILL_IDS drives for its own background simulation).
# This is no longer a priority order - see EnemySkillAI.HERO_TIE_BREAK
# for each hero's own tie-break fallback order, only ever consulted
# when two skills' scores are too close to call outright. Blood of the Wild,
# Mark of the Mist, The Mist Remembers, and Pull of the Abyss aren't here - none
# of them are ever "cast" or scored: Blood of the Wild and The Mist Remembers turn
# themselves on/off automatically off the rival's own HP% (see
# _update_enemy_blood_of_the_wild_state()/
# _maybe_auto_activate_enemy_the_mist_remembers()), and Mark of the Mist/
# Pull of the Abyss only ever build off the rival's own plain Attacks (see
# _apply_enemy_mark_of_the_mist_stack()/
# _maybe_consume_enemy_pull_of_the_abyss_stack()).
const ENEMY_KNOWN_SKILL_IDS: Array[String] = [
	"abyssal_spasm", "barbed_lunge", "leeching_hunger", "depthsveil",
	"thornbind", "elderwild_companion", "wildbond", "beast_of_the_elderwild",
	"whisper_of_the_veil", "veil_of_the_forgotten", "drowned_surge", "undertow", "the_sunken_one",
	"mark_of_stillness", "the_hollow_cold", "touch_of_the_first_cold", "return_to_the_void",
	"frostbound_fangs", "maddening_roar", "the_test_of_time", "the_hunger_calls",
	"rimecleaver", "winters_grip", "the_frost_tempest",
	"frostbound_rupture", "charge", "bestial_rage", "glacier_breaker",
	"rootveil", "sanguine_bloom", "woven_flesh", "mother's_grasp",
	"sweep", "chainfire", "cinderbomb",
	"double_trouble", "blast_hopper", "three_cheers", "kiss_the_wastes",
	"imperial_guard", "shackles", "luring_gaze",
	"hunting_instinct", "paralytic_venom", "deathlight_lure",
	"fallen_grace", "hope_of_the_fallen", "withering_pursuit", "ambush_strike",
	"moonfall_lance", "eternal_eclipse",
]

# Reinforcements: if the hero hasn't cleared every enemy within
# REINFORCEMENT_INTERVAL turns of the stage/fight starting, a fresh
# wave (sized by GameManager.REINFORCEMENT_ENEMY_COUNTS for the current
# stage, or the FULL stage 3 STAGE_ENEMY_COUNTS during a hero fight -
# see _spawn_reinforcements()) joins the fight, scaled to that same
# stage's stats. Every wave after that first one gives the player a
# shorter REINFORCEMENT_REPEAT_INTERVAL-turn grace period instead - see
# _next_reinforcement_turn, which tracks the turn count the NEXT wave
# is due on and advances by REPEAT (not INTERVAL) each time one
# actually spawns, so it keeps arriving every REPEAT turns for as long
# as the stage/fight goes on. Both counters reset (_turn_count back to
# 0, _next_reinforcement_turn back to REINFORCEMENT_INTERVAL) whenever
# a fresh stage or hero fight starts - see _advance_to_next_stage()/
# _start_hero_fight() - and stop mattering entirely once the stage
# clears or the player flees, since there's no more fight for them to
# fire into.
# (Stage waves: see GameManager.get_reinforcement_interval()/_repeat().)
# A hero fight (duel with a rival) gives the player more room: its first wave
# comes later and the repeats are spaced further apart.
const HERO_FIGHT_REINFORCEMENT_INTERVAL := 15
const HERO_FIGHT_REINFORCEMENT_REPEAT_INTERVAL := 10
var _turn_count: int = 0
var _next_reinforcement_turn: int = GameManager.get_reinforcement_interval(1)

# Which of the zone's up-to-GameManager.MAX_ZONE_STAGE waves this
# battle is currently on. Starts at whatever PlayerManager.
# get_zone_start_stage() says (always 1, even for a zone that's
# already been fully cleared). Clearing every enemy in a non-final stage reloads the next
# stage's enemies in this same scene instance - see _handle_victory()
# and _advance_to_next_stage() - rather than returning to the Map.
var _current_stage: int = 1

# True while fighting a post-stage-3 rival hero instead of the zone's
# regular creeps - see _try_start_hero_fight()/_start_hero_fight().
# _current_stage stays at MAX_ZONE_STAGE throughout, so code that
# needs to know "are we in the normal stage progression or a hero
# fight" should check this rather than _current_stage.
var _in_hero_fight: bool = false

# Which hero id is being fought, so _handle_victory() knows who to
# mark defeated via PlayerManager.mark_hero_defeated() when it's won.
var _hero_fight_target_id: String = ""

# The fallen rival's Echo (see HeroEchoFX), left in the column where
# they died - a hero fight isn't won until the hero goes over it with
# no enemies left standing (see _try_collect_hero_echo()). null while
# there's no Echo waiting.
var _hero_echo: HeroEchoFX = null
var _hero_echo_pos_index: int = -1

# The Echo can't be collected until the player has closed EchoPopup,
# which opens once it's collectible (see _show_hero_echo_popup()).
# Pending while the level-up flow is still open on top of it.
var _echo_popup_acknowledged: bool = false
var _echo_popup_pending: bool = false
## The last enemy fell while the level-up flow was open - _handle_victory()
## runs once it closes instead of burying the skill choice.
var _victory_pending: bool = false

# Where the hero stood as of the last _update_hero_position(), so a
# move that carries him across several columns still counts as going
# over the Echo, not only one that lands right on it.
var _last_hero_pos_index: int = -1

# Bumped every time _advance_to_next_stage() runs. Action handlers
# that might kill the last enemy of a stage (attack, Barbed Lunge, Dark
# Pact) capture this before acting and check it again after - if it
# changed, a stage transition already reset the turn state (fresh
# actions, only skill cooldowns carried over) and they must NOT then
# overwrite that by unconditionally marking the turn as used.
var _stage_generation: int = 0



func _process(_delta: float) -> void:
	_refresh_bear_hp_label()
	_refresh_guard_hp_labels()


func _ready() -> void:
	flee_button.pressed.connect(_on_flee_pressed)
	$SettingsButton.pressed.connect(func(): $SettingsPopup.open())
	defeat_ok_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/PostLogin.tscn"))
	move_left_button.pressed.connect(_on_move_left_pressed)
	move_right_button.pressed.connect(_on_move_right_pressed)
	# Moving has its own sound (the steps), so no generic button click.
	move_left_button.set_meta(AudioManager.NO_CLICK_META, true)
	move_right_button.set_meta(AudioManager.NO_CLICK_META, true)
	attack_button.set_meta(AudioManager.NO_CLICK_META, true)
	attack_button.pressed.connect(_on_attack_pressed)
	hero_image.gui_input.connect(_on_hero_image_gui_input)
	level_up_ok_button.pressed.connect(_on_level_up_continue_pressed)
	echo_ok_button.pressed.connect(_on_echo_popup_ok_pressed)
	skill_choice_desc_ok_button.pressed.connect(_on_skill_choice_desc_ok_pressed)
	skill_choice_desc_cancel_button.pressed.connect(_on_skill_choice_desc_cancel_pressed)

	_fx_layer = Control.new()
	_fx_layer.name = "FxLayer"
	_fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enemies_layer.add_sibling(_fx_layer)

	_build_level_up_input_blocker()

	_recruited = PlayerManager.get_recruited_hero()
	if _recruited.is_empty():
		print("ERROR: No recruited hero found - accept a hero in a zone first.")
		return

	_hero_static = GameManager.get_hero_by_id(_recruited["id"])
	_current_stage = PlayerManager.get_zone_start_stage(GameManager.selected_zone)

	# Tutorial stages 2 and 3 are manufactured mid-run scenarios (see
	# TutorialManager.start_stage2()/start_stage3()) rather than a real
	# zone-cleared state, so they override the stage computed above
	# directly.
	if TutorialManager.is_active and (TutorialManager.current_stage == 2 or TutorialManager.current_stage == 3):
		_current_stage = 3
	_next_reinforcement_turn = GameManager.get_reinforcement_interval(_current_stage)

	# Every player battle attempt (not just full zone clears - fleeing
	# after a partial clear still counts) also ticks the background
	# simulation for every other hero in the game, so their world
	# keeps progressing whether or not the player's own runs finish.
	# See EnemyHeroManager.tick_all_npc_heroes().
	EnemyHeroManager.tick_all_npc_heroes(_recruited["id"])

	_load_battle_background()
	_load_hero_image()
	_attach_hero_attack_prop(_hero_static, hero_image)
	_build_bar_styles()
	_refresh_bars()
	_populate_skill_buttons()
	_populate_item_grid()
	_refresh_gold_label()
	_load_enemies()
	_update_stage_label()
	_update_action_buttons()
	_play_log_session()

	if TutorialManager.is_active and TutorialManager.current_stage == 1:
		_advance_tutorial_stage1_step("move_to_drowned_surge_range")
	elif TutorialManager.is_active and TutorialManager.current_stage == 2:
		_start_tutorial_stage2_battle()
	elif TutorialManager.is_active and TutorialManager.current_stage == 3:
		_start_tutorial_stage3_battle()


func _load_battle_background() -> void:
	var zone_data: Dictionary = GameManager.get_selected_zone()
	_ground_offset = float(zone_data.get("battle_ground_offset", 0.0))
	var battle_bg_path: String = zone_data.get("battle_background", "")
	if battle_bg_path != "" and ResourceLoader.exists(battle_bg_path):
		background.texture = load(battle_bg_path)
		# Per-zone ambient effects (e.g. the Elderwild's blowing leaves),
		# right over the background and under the hero/creeps.
		var atmosphere: Control = BATTLE_ATMOSPHERE.new()
		atmosphere.name = "BattleAtmosphere"
		background.add_sibling(atmosphere)
		atmosphere.setup(GameManager.selected_zone)
		_fit_hud_to_plate(battle_bg_path)
	else:
		print("No battle_background set for the current zone - using fallback color.")


# Every battle area's art has the HUD plate baked in at a slightly
# different spot (and the 3:2 images get their top/bottom cropped by the
# cover-fit Background). Per image: [width, height, x0, y0, x1, y1] - the
# dark inner area of the plate in image pixels.
const BATTLE_PLATE_RECTS := {
	"the_iron_abyss_area.png": [1536, 1024, 60, 755, 1475, 980],
	"Elderwild_area.png": [1536, 1024, 80, 765, 1460, 980],
	"kingdom_of_morvain_area.jpg": [1672, 941, 85, 760, 1610, 905],
	"the_ironbound_isles_area.png": [1536, 1024, 80, 765, 1460, 985],
	"frostspire_area.jpg": [1536, 1024, 55, 795, 1480, 995],
	"the_everfrost_area.jpg": [1536, 1024, 65, 745, 1475, 985],
	"the_verdant_scar_area.jpg": [1670, 941, 55, 690, 1615, 885],
	"drowned_empire_area.png": [1536, 1024, 80, 765, 1460, 980],
	"the_blackbloom_area.jpg": [1672, 941, 100, 720, 1580, 895],
	"scorchlands_area.jpg": [1670, 941, 55, 685, 1615, 870],
}


## Places the skills, items and actions panels inside this area's baked-in
## HUD plate, mapping the plate's image rect through the Background's
## cover-fit scaling (centered crop) into screen space.
func _fit_hud_to_plate(battle_bg_path: String) -> void:
	var plate: Array = BATTLE_PLATE_RECTS.get(battle_bg_path.get_file(), [])
	if plate.is_empty():
		return
	var view: Vector2 = get_viewport_rect().size
	var image_scale: float = maxf(view.x / float(plate[0]), view.y / float(plate[1]))
	var origin := Vector2(view.x - plate[0] * image_scale, view.y - plate[1] * image_scale) * 0.5
	var left: float = origin.x + plate[2] * image_scale
	var right: float = origin.x + plate[4] * image_scale
	var top: float = maxf(origin.y + plate[3] * image_scale, 0.0) + 4.0
	var bottom: float = minf(origin.y + plate[5] * image_scale, view.y) - 6.0
	var width: float = right - left

	_place_hud_panel($SkillsPanel, left + width * 0.02, top, left + width * 0.59, bottom)
	_place_hud_panel($ItemsPanel, left + width * 0.615, top, left + width * 0.865, bottom)
	_place_hud_panel($ActionsPanel, left + width * 0.88, top, left + width * 0.985, bottom)


func _place_hud_panel(panel: Control, x0: float, y0: float, x1: float, y1: float) -> void:
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = x0
	panel.offset_top = y0
	panel.offset_right = x1
	panel.offset_bottom = y1


func _grid_unit() -> float:
	return get_viewport_rect().size.x / float(GRID_COLUMNS)


func _index_to_x(index: int) -> float:
	return index * _grid_unit()


# How much lower than standard (fraction of the screen height) the
# current arena's fighters stand - its "battle_ground_offset", for art
# whose platform sits lower than the usual ground line. Set by
# _load_battle_background().
var _ground_offset: float = 0.0


func _creature_y() -> float:
	var target_height: float = get_viewport_rect().size.y / 4.0
	return (get_viewport_rect().size.y - target_height) / 2.0 + get_viewport_rect().size.y * _ground_offset


## On-screen size for a hero's (or hero-fight boss's) art. The standard
## 3:2 landscape art - which every creep uses - is 1/4 of the screen
## tall. Narrower art (e.g. Erynd's portrait-shaped standing figure)
## is scaled up to cover that same area instead, so a tall figure
## isn't dwarfed by the wide creep art beside it. Wider art is left at
## the standard height. `scale` is the hero's own "battle_scale" (hero
## data, default 1) on top of that - for a creature meant to loom larger
## than its art alone would make it (e.g. The Primordial Hunger).
func _creature_size(texture: Texture2D, scale: float = 1.0) -> Vector2:
	var base_height: float = get_viewport_rect().size.y / 4.0 * scale
	var tex_size: Vector2 = texture.get_size()
	var aspect: float = tex_size.x / tex_size.y
	var height: float = base_height * maxf(1.0, sqrt(CREATURE_BASE_ASPECT / aspect))
	return Vector2(height * aspect, height)


## Top y for creature art `height` tall, keeping its feet on the same
## ground line as standard-size art placed at _creature_y().
func _creature_top_y(height: float) -> float:
	return _creature_y() + get_viewport_rect().size.y / 4.0 - height


## Re-sizes a hero-fight boss's node to its current texture (e.g. after
## Beast of the Elderwild swaps the art) and re-seats it on the ground line.
func _refit_creature_node(node: TextureRect, pos_index: int) -> void:
	node.size = _creature_size(node.texture, float(node.get_meta("battle_scale", 1.0)))
	node.position = Vector2(_index_to_x(pos_index), _creature_top_y(node.size.y))


## Shortest distance between two columns, accounting for the fact
## that moving off one edge wraps to the other.
func _distance(a: int, b: int) -> int:
	return absi(a - b)


## Fraction of incoming damage an armor value blocks, on a 0-1 scale
## (e.g. armor 5 -> ~0.23, meaning 23% reduced). Approaches but never
## reaches 1, so damage can be mitigated heavily but never nullified.
func _damage_reduction(armor: float) -> float:
	return (0.06 * armor) / (1.0 + 0.06 * armor)


## Applies an armor value's damage reduction to a raw damage amount.
## Negative armor increases damage taken instead of reducing it.
## Result is clamped to 0 so negative armor can't flip a hit into a heal.
func _apply_armor_reduction(raw_damage: float, armor: float) -> float:
	var reduction: float = _damage_reduction(armor)
	return maxf(0.0, raw_damage * (1.0 - reduction))


## Hero's total max HP: base stat plus Beast of the Elderwild's bonus hp
## while it is active - the one place
## that combination is computed, used by the HP bar, Blood of the Wild's
## threshold check, and the bear-death HP penalty.
func _hero_max_hp() -> float:
	var stats: Dictionary = _recruited.get("stats", {})
	return float(stats.get("hp", 0)) + _beast_of_the_elderwild_bonus_hp


## Hero's total armor: base stat from GameManager plus any permanent
## bonus picked up from items (mirrors how damage bonus is combined
## in _roll_hero_damage), plus Wildbond's flat bonus, Woven Flesh's own
## flat bonus, and Kindled Resolve's own per-stack bonus, each while
## active.
func _hero_armor() -> float:
	var stats: Dictionary = _recruited.get("stats", {})
	return float(stats.get("armor", 0)) + _wildbond_bonus_armor + _woven_flesh_bonus_armor + _kindled_resolve_bonus_armor() - _player_armor_reduction


## Blood of the Wild's current level data ({} if not learned yet) - looked
## up fresh each time rather than cached, so a mid-battle level-up
## (via a banked skill point) is picked up immediately.
func _get_blood_of_the_wild_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("blood_of_the_wild")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "blood_of_the_wild":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Recomputes Blood of the Wild's on/off state and its bonus values, and
## refreshes its status label to match. Called from _refresh_bars()
## (i.e. after every HP change) and right after _populate_skill_
## buttons() rebuilds that label, so it's never stale.
##
## Uses hysteresis rather than one threshold: it switches ON once HP
## drops below 50%, then stays on through the whole climb back up
## until HP actually reaches 80%, rather than flicking on and off
## every time HP crosses a single line. Between 50% and 80%, whatever
## state it was already in just holds.
func _update_blood_of_the_wild_state() -> void:
	var level_data: Dictionary = _get_blood_of_the_wild_level_data()

	if level_data.is_empty():
		_blood_of_the_wild_active = false
	else:
		var max_hp: float = _hero_max_hp()
		if max_hp > 0.0:
			var hp_pct: float = float(_recruited.get("current_hp", 0)) / max_hp
			if _blood_of_the_wild_active:
				if hp_pct >= 0.8:
					_blood_of_the_wild_active = false
			elif hp_pct < 0.5:
				_blood_of_the_wild_active = true

	if _blood_of_the_wild_active:
		_blood_of_the_wild_bonus_movement = int(level_data.get("bonus_movement", 0))
		_blood_of_the_wild_damage_reduction_pct = float(level_data.get("damage_reduction_pct", 0.0))
	else:
		_blood_of_the_wild_bonus_movement = 0
		_blood_of_the_wild_damage_reduction_pct = 0.0

	if not is_instance_valid(_blood_of_the_wild_status_label):
		return

	if level_data.is_empty():
		_blood_of_the_wild_status_label.text = "Passive"
		_blood_of_the_wild_status_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1, 1))
	elif _blood_of_the_wild_active:
		_blood_of_the_wild_status_label.text = "Active"
		_blood_of_the_wild_status_label.add_theme_color_override("font_color", Color(1, 0.65, 0.2, 1))
	else:
		_blood_of_the_wild_status_label.text = "Inactive"
		_blood_of_the_wild_status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))


## Which direction (+1 or -1) is the shorter path from `from` to `to`,
## going around the wraparound board rather than always picking the
## raw lower/higher index.
func _step_toward(from: int, to: int) -> int:
	if from < to:
		return 1
	elif from > to:
		return -1

	return 0


func _load_hero_image() -> void:
	_set_hero_image(_hero_static.get("image", ""))
	var profile_id: String = ANIMATED_CREATURE_PROFILES.get(_hero_static.get("id", ""), "")
	if profile_id != "":
		CreatureAnimator.attach(hero_image, profile_id)


## Loads `image_path` into hero_image, scaled to a quarter of the
## screen's height with its own aspect ratio preserved - shared by the
## normal hero portrait (_load_hero_image()) and Beast of the Elderwild's swap to
## its bear portrait/back again (see _activate_beast_of_the_elderwild()/
## _end_beast_of_the_elderwild()). No-ops (with a printed warning) if the path is
## empty or missing, leaving whatever's already showing untouched.
func _set_hero_image(image_path: String) -> void:
	if image_path == "" or not ResourceLoader.exists(image_path):
		print("No hero image found at: ", image_path)
		return

	var texture: Texture2D = load(image_path)
	hero_image.texture = texture

	# Standard art is 1/4 of the screen tall; see _creature_size() for
	# how narrower art is scaled.
	hero_image.size = _creature_size(texture, float(_hero_static.get("battle_scale", 1.0)))
	_update_hero_position()


func _update_hero_position() -> void:
	var old_x: float = hero_image.position.x
	hero_image.position = Vector2(_index_to_x(_hero_pos_index), _creature_top_y(hero_image.size.y))
	var animator := CreatureAnimator.of(hero_image)
	if animator != null and not is_equal_approx(old_x, hero_image.position.x):
		animator.play_move(old_x - hero_image.position.x)

	var from_index: int = _last_hero_pos_index if _last_hero_pos_index >= 0 else _hero_pos_index
	_last_hero_pos_index = _hero_pos_index
	_try_collect_hero_echo(from_index, _hero_pos_index)
	

## Spawns the current stage's enemies: GameManager.STAGE_ENEMY_COUNTS
## says how many melee/ranged enemies this stage has, cycling through
## the zone's own melee/ranged templates if it needs more than the
## zone defines (e.g. 5 melee out of only 2 distinct templates just
## repeats them). Each spawned enemy gets its own stage-adjusted stats
## via _build_stage_enemy_def() - the zone's template dictionaries
## themselves are never modified.
func _load_enemies() -> void:
	for child in enemies_layer.get_children():
		child.queue_free()
	_enemies.clear()

	var zone_data: Dictionary = GameManager.get_selected_zone()
	var enemy_defs: Array = zone_data.get("enemies", [])

	var melee_templates: Array = []
	var range_templates: Array = []
	for enemy_def in enemy_defs:
		if enemy_def.get("type", "") == "range":
			range_templates.append(enemy_def)
		else:
			melee_templates.append(enemy_def)

	var counts: Dictionary = GameManager.get_stage_enemy_counts(_current_stage)

	# Tutorial stage 3 (see TutorialManager.start_stage3()) puts the
	# hero into this stage's real enemy composition (5 melee + 2 range
	# at The Ironbound Isles) while deliberately low on HP - fine for the brief
	# stage 2 scenario (one attack, then flee), but that many attackers
	# every turn is lethal over stage 3's longer script (level up, wait
	# for reinforcements, cast the ultimate, mop up). Opens with stage
	# 1's smaller count instead - reinforcements (still sized for the
	# real stage 3, see _spawn_reinforcements()) bring the numbers back
	# up right as The Sunken One becomes available to deal with them.
	if TutorialManager.is_active and TutorialManager.current_stage == 3:
		counts = GameManager.get_stage_enemy_counts(1)

	_spawn_stage_enemies(melee_templates, int(counts.get("melee", 0)))
	_spawn_stage_enemies(range_templates, int(counts.get("range", 0)))
	_play_log_reset_stage()
	if PlayLog.enabled():
		PlayLog.event("stage_start", _play_log_state())


func _spawn_stage_enemies(templates: Array, count: int, stage: int = -1) -> void:
	if templates.is_empty():
		return
	var wave_stage: int = _current_stage if stage < 0 else stage
	for i in range(count):
		var template: Dictionary = templates[i % templates.size()]
		_spawn_enemy(GameManager.scale_creep_for_level(_build_stage_enemy_def(template, wave_stage), PlayerManager.get_level()))


## Returns a copy of `base_def` with this stage's hp/damage/gold
## bonuses baked in - both are cumulative across stages (see
## GameManager.get_stage_stat_bonus / get_stage_cumulative_gold_bonus),
## each stage adding its own increment on top of whatever the
## previous stage already added, not a flat total over the base value.
func _build_stage_enemy_def(base_def: Dictionary, stage: int) -> Dictionary:
	if stage <= 1:
		return base_def

	var staged: Dictionary = base_def.duplicate()
	var stat_bonus: Dictionary = GameManager.get_stage_stat_bonus(stage)
	staged["hp"] = float(base_def.get("hp", 0)) + float(stat_bonus.get("hp", 0))
	staged["damage"] = float(base_def.get("damage", 0)) + float(stat_bonus.get("damage", 0))

	var gold_bonus: int = GameManager.get_stage_cumulative_gold_bonus(stage)
	if gold_bonus != 0:
		var gold_parts: PackedStringArray = str(base_def.get("gold", "0-0")).split("-")
		var gold_min: float = float(gold_parts[0]) if gold_parts.size() > 0 else 0.0
		var gold_max: float = float(gold_parts[1]) if gold_parts.size() > 1 else gold_min
		staged["gold"] = "%d-%d" % [int(gold_min + gold_bonus), int(gold_max + gold_bonus)]

	return staged


## Creates one enemy (image, position, hitbox) from a definition and
## adds it to `_enemies`. Used both for the zone's starting roster and
## for reinforcements later. Melee enemies stack at column 7, ranged
## at column 8, offset visually so same-column enemies don't render
## exactly on top of each other - the offset is based on how many
## enemies of that type are already on the field, so this works
## whether it's the initial load or a reinforcement arriving mid-fight.
func _spawn_enemy(enemy_def: Dictionary) -> void:
	var image_path: String = enemy_def.get("image", "")
	if image_path == "" or not ResourceLoader.exists(image_path):
		print("No enemy image found at: ", image_path)
		return

	var texture: Texture2D = load(image_path)
	var battle_scale: float = float(enemy_def.get("battle_scale", 1.0))
	var target_size: Vector2 = _creature_size(texture, battle_scale)
	var y_pos: float = _creature_top_y(target_size.y)

	var tex_rect := TextureRect.new()
	tex_rect.texture = texture
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	tex_rect.size = target_size
	tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	# Kept for _refit_creature_node(), when a swap of art resizes it.
	tex_rect.set_meta("battle_scale", battle_scale)

	# Hero art is drawn facing right (toward the enemy side, where the
	# player's own hero always stands) - a hero fight puts that same
	# art on the enemy side instead, facing the player's hero, so it
	# needs to be mirrored to face left. Regular creep art is already
	# drawn facing left and is untouched.
	tex_rect.flip_h = enemy_def.get("is_hero_fight", false)

	var enemy_type: String = enemy_def.get("type", "")
	var pos_index: int
	var visual_offset: float

	if enemy_type == "range":
		pos_index = 8
		visual_offset = _enemy_count_of_type("range") * 16.0
	else:
		pos_index = 7
		visual_offset = _enemy_count_of_type("melee") * 16.0

	tex_rect.position = Vector2(_index_to_x(pos_index) + visual_offset, y_pos)

	enemies_layer.add_child(tex_rect)

	var hp_label := Label.new()
	hp_label.size = Vector2(ENEMY_HP_LABEL_WIDTH, ENEMY_HP_LABEL_HEIGHT)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	hp_label.add_theme_constant_override("outline_size", 3)
	enemies_layer.add_child(hp_label)

	var status_label := Label.new()
	status_label.size = Vector2(ENEMY_STATUS_LABEL_WIDTH, ENEMY_HP_LABEL_HEIGHT)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_label.visible = false
	status_label.add_theme_color_override("font_color", ENEMY_STATUS_LABEL_COLOR)
	status_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	status_label.add_theme_constant_override("outline_size", 3)
	status_label.add_theme_font_size_override("font_size", ENEMY_STATUS_LABEL_FONT_SIZE)
	enemies_layer.add_child(status_label)

	var enemy_data := {
		"static": enemy_def,
		"current_hp": float(enemy_def.get("hp", 1)),
		"current_main_stat_value": float(enemy_def.get("main_stat_value", 0)),
		"pos_index": pos_index,
		"node": tex_rect,
		"hp_label": hp_label,
		"status_label": status_label,
	}
	_enemies.append(enemy_data)

	tex_rect.gui_input.connect(_on_enemy_gui_input.bind(enemy_data))

	var profile_id: String = ANIMATED_CREATURE_PROFILES.get(enemy_def.get("id", ""), "")
	if profile_id != "":
		CreatureAnimator.attach(tex_rect, profile_id)

	_refresh_enemy_overhead_labels()


func _enemy_count_of_type(type: String) -> int:
	var count := 0
	for enemy in _enemies:
		if enemy["static"].get("type", "") == type:
			count += 1
	return count


# ------------------------------------------------------------------
# Enemy HP number display - "current / max" over every enemy's own
# image (no bars, just the numbers, per the design ask), in gold and a
# little bigger for a hero-fight boss specifically so it reads as
# unmistakably different from a regular creep's - plus, right next to
# it, a plain-text list of whatever status effects are currently
# active on that enemy ("Stunned", "Rooted", etc. - see
# _enemy_status_effect_text()). Every enemy that shares a column (they
# can end up sharing one via movement even though spawning only ever
# uses columns 7/8 - see _spawn_enemy()'s own visual_offset fan-out)
# gets its HP/status pair stacked vertically above that shared spot
# instead of overlapping, with whichever one _get_enemy_at() would
# actually resolve an attack on that column against - the "front" one
# - always at the bottom of the stack, since that's the one actually
# being attacked whenever that column is hit.
# ------------------------------------------------------------------

const ENEMY_HP_LABEL_WIDTH := 90.0
const ENEMY_HP_LABEL_HEIGHT := 22.0
const ENEMY_HP_LABEL_GAP := 4.0
const ENEMY_HP_LABEL_FONT_SIZE := 15
const ENEMY_HERO_HP_LABEL_FONT_SIZE := 20
const ENEMY_HP_LABEL_COLOR := Color(1, 1, 1, 1)
const ENEMY_HERO_HP_LABEL_COLOR := Color(1, 0.85, 0.2, 1)

const ENEMY_STATUS_LABEL_WIDTH := 220.0
const ENEMY_STATUS_LABEL_GAP := 6.0
const ENEMY_STATUS_LABEL_FONT_SIZE := 13
const ENEMY_STATUS_LABEL_COLOR := Color(1, 0.55, 0.3, 1)


## Every status effect currently on `enemy` that's worth calling out,
## as a comma-separated string ("" if none) - one entry per distinct
## effect a player skill (or a wall the player's own Frostbound Rupture put
## under its feet) can inflict directly on an enemy Dictionary. Mirrors
## _enemy_has_harmful_debuff()'s own field list (used for The Test of Time's
## AI scoring) plus the effects that helper doesn't need for that
## purpose - stun, Winter's Grip's/Sanguine Bloom's/Mother's Grasp's own DoTs, and
## an Frostbound-Rupture-blocked column, which isn't a Dictionary field at all
## but reads as "rooted" just the same since the enemy can't move
## either way (see _is_column_frostbound_rupture_blocked()).
func _enemy_status_effect_text(enemy: Dictionary) -> String:
	var effects: PackedStringArray = []

	if enemy.get("stun_turns_left", 0) > 0:
		effects.append("Stunned")

	# Thornbind roots AND silences for the exact same duration - every
	# level's own data sets root_turns == silence_turns, and both now
	# tick down together every turn (see _enemy_turn()'s own silence
	# decrement, added to match root's) - so silence_turns_left > 0 is
	# a reliable "this root is Thornbind's, not Rootveil's" signal
	# (Rootveil only ever sets root_turns_left, never silence -
	# see _apply_hero_attack()'s own "attacking_from_rootveil"
	# branch), without needing thornbind_dot_turns_left at all - that
	# field's own duration runs one turn longer than root/silence by
	# design, but the "Thornbound" status itself shouldn't outlive the
	# root/silence it actually represents, just the residual DoT tick.
	# An activated Mark of the Mist also silences through that same
	# silence_turns_left field, so while it's active silence alone no
	# longer proves Thornbind - fall back to Thornbind's own DoT counter.
	# Only an ACTIVATED curse counts as "Cursed"; stacks still building
	# toward hits_to_activate aren't a curse yet.
	var cursed: bool = enemy.get("curse_active", false)
	var silenced: bool = enemy.get("silence_turns_left", 0) > 0
	var thornbound: bool = silenced and (not cursed or enemy.get("thornbind_dot_turns_left", 0) > 0)
	var rooted: bool = enemy.get("root_turns_left", 0) > 0 or _is_column_frostbound_rupture_blocked(enemy["pos_index"])
	var grasped: bool = enemy.get("mothers_grasp_dot_turns_left", 0) > 0

	if thornbound:
		effects.append("Thornbound")
	elif rooted and not grasped:
		# Mother's Grasp's own root already gets its own label below - so
		# only fall back to plain "Rooted" when nothing more specific
		# (Thornbind, Mother's Grasp) is already covering it.
		effects.append("Rooted")
	if silenced:
		effects.append("Silenced")
	if cursed:
		effects.append("Cursed")
	if enemy.get("mark_of_stillness_dot_turns_left", 0) > 0:
		effects.append("Mark of Stillness")
	if enemy.get("the_hollow_cold_dot_turns_left", 0) > 0:
		effects.append("The Hollow Cold")
	if enemy.get("return_to_the_void_dot_turns_left", 0) > 0:
		effects.append("Return to the Void")
	if enemy.get("winters_grip_dot_turns_left", 0) > 0:
		effects.append("Frostbitten")
	if enemy.get("sanguine_bloom_dot_turns_left", 0) > 0:
		effects.append("Sanguine Bloom")
	if enemy.get("mothers_grasp_dot_turns_left", 0) > 0:
		effects.append("Mother's Grasp")

	return ", ".join(effects)


## Recomputes every enemy's HP/status label text and position from
## scratch - cheap enough to call from anywhere the enemy roster, any
## enemy's current_hp, pos_index, or status effects could have changed
## (spawning, dying, moving, taking damage, regenerating, a fresh
## debuff landing or an old one ticking off) rather than trying to
## track exactly which of those actually happened at each call site.
func _refresh_enemy_overhead_labels() -> void:
	_refresh_kindled_embers()
	var groups: Dictionary = {}
	for enemy in _enemies:
		# An invisible rival hero takes no slot in the stack - a gap would
		# give its column away.
		if enemy["static"].get("is_hero_fight_boss", false) and _is_enemy_hero_invisible():
			continue
		var col: int = enemy["pos_index"]
		if not groups.has(col):
			groups[col] = []
		groups[col].append(enemy)

	for col in groups.keys():
		var group: Array = groups[col]

		# _get_enemy_at() is the same lookup melee attacks/ranged range-
		# checks already resolve a column against - whichever enemy it
		# returns here IS "the one being attacked" for this column, so
		# that's the one anchored at the bottom. Falls back to the
		# group's own first entry on the rare all-hidden case (see
		# _get_enemy_at()'s own is_target_hidden() skip), so the stack
		# still has *a* bottom rather than silently doing nothing.
		var front: Dictionary = _get_enemy_at(col)
		if front.is_empty():
			front = group[0]

		var ordered: Array = [front]
		for enemy in group:
			if not is_same(enemy, front):
				ordered.append(enemy)

		var front_node: Control = front["node"]
		var center_x: float = front_node.position.x + front_node.size.x / 2.0
		var base_y: float = front_node.position.y - ENEMY_HP_LABEL_GAP

		for i in range(ordered.size()):
			var enemy: Dictionary = ordered[i]
			var label: Label = enemy.get("hp_label")
			if label == null:
				continue

			var is_boss: bool = enemy["static"].get("is_hero_fight_boss", false)
			var concealed: bool = is_boss and _is_enemy_hero_invisible()
			label.visible = not concealed
			var max_hp: float = _enemy_hero_effective_max_hp(enemy) if is_boss else float(enemy["static"].get("hp", 1))
			var current_hp: float = maxf(0.0, float(enemy.get("current_hp", 0)))
			label.text = "%d / %d" % [roundi(current_hp), maxi(1, roundi(max_hp))]

			label.add_theme_color_override("font_color", ENEMY_HERO_HP_LABEL_COLOR if is_boss else ENEMY_HP_LABEL_COLOR)
			label.add_theme_font_size_override("font_size", ENEMY_HERO_HP_LABEL_FONT_SIZE if is_boss else ENEMY_HP_LABEL_FONT_SIZE)

			var slot_bottom: float = base_y - float(i) * (ENEMY_HP_LABEL_HEIGHT + ENEMY_HP_LABEL_GAP)
			var label_top: float = slot_bottom - ENEMY_HP_LABEL_HEIGHT
			label.position = Vector2(center_x - ENEMY_HP_LABEL_WIDTH / 2.0, label_top)
			# Return to the Void's execute threshold, while it's armed.
			var threshold: float = float(enemy.get("return_to_the_void_execute_pct", 0.0))
			ReturnToVoidFX.update_threshold_bar(label, threshold > 0.0 and int(enemy.get("return_to_the_void_dot_turns_left", 0)) > 0,
					current_hp / maxf(max_hp, 1.0), threshold)

			var status_label: Label = enemy.get("status_label")
			if status_label != null:
				var status_text: String = _enemy_status_effect_text(enemy)
				status_label.visible = status_text != "" and not concealed
				if status_label.visible:
					status_label.text = status_text
					status_label.position = Vector2(label.position.x + ENEMY_HP_LABEL_WIDTH + ENEMY_STATUS_LABEL_GAP, label_top)


## Called every REINFORCEMENT_INTERVAL/REINFORCEMENT_REPEAT_INTERVAL
## turns the current stage/fight isn't cleared yet. Spawns a wave sized
## by GameManager.get_reinforcement_enemy_counts(_current_stage) - a
## smaller top-up than that same stage's own opening STAGE_ENEMY_COUNTS
## - built the exact same way _load_enemies() builds a stage's opening
## wave (_spawn_stage_enemies(), which bakes in _build_stage_enemy_def()'s
## hp/damage/gold scaling for _current_stage), so reinforcements always
## come in at the stats of whatever's currently on the field rather
## than unscaled base stats.
## A hero fight is the one exception: rather than the usual smaller
## top-up, it throws the FULL stage 3 composition (STAGE_ENEMY_COUNTS,
## not REINFORCEMENT_ENEMY_COUNTS) at the player every time - a boss
## fight already means business, so its own reinforcements should hit
## as hard as an entire fresh stage 3 wave rather than a token trickle.
## _current_stage stays at MAX_ZONE_STAGE throughout a hero fight, same
## as everywhere else that reads it, so the stat scaling still lines up
## either way.
func _spawn_reinforcements() -> void:
	PlayLog.event("reinforcements", _play_log_state())
	var zone_data: Dictionary = GameManager.get_selected_zone()
	var enemy_defs: Array = zone_data.get("enemies", [])

	var melee_templates: Array = []
	var range_templates: Array = []
	for enemy_def in enemy_defs:
		if enemy_def.get("type", "") == "range":
			range_templates.append(enemy_def)
		else:
			melee_templates.append(enemy_def)

	var wave_stage: int = GameManager.HERO_FIGHT_REINFORCEMENT_STAGE if _in_hero_fight else _current_stage
	var counts: Dictionary = GameManager.get_stage_enemy_counts(wave_stage) if _in_hero_fight else GameManager.get_reinforcement_enemy_counts(_current_stage)
	var melee_count: int = int(counts.get("melee", 0))
	var range_count: int = int(counts.get("range", 0))

	_spawn_stage_enemies(melee_templates, melee_count, wave_stage)
	_spawn_stage_enemies(range_templates, range_count, wave_stage)

	if (not melee_templates.is_empty() and melee_count > 0) or (not range_templates.is_empty() and range_count > 0):
		_show_message_over_hero("Reinforcements arrived!")
		_tutorial_maybe_explain_reinforcements()
		_tutorial_maybe_advance_stage3_for_reinforcements()


## Only items that are actually consumed by use (heal/mana potions)
## show up as clickable battle actions - equipment-type items ("stat"
## effect, like Grimfangs or Iron Grips) apply their
## bonus passively just by being in the inventory (see PlayerManager.
## get_inventory_stat_bonus) and are managed from the Shop instead.
## Shows every occupied inventory slot (PlayerManager caps this at 6,
## matching the panel's 3x2 grid, so nothing is ever hidden). Only
## consumables (heal/mana effect) are clickable battle actions -
## equipment ("stat" effect, like Grimfangs) is shown so it's
## visible in the inventory, but stays disabled since it applies its
## bonus passively just by being held (see PlayerManager.
## get_inventory_stat_bonus) rather than being "used".
func _populate_item_grid() -> void:
	var slots: Array = PlayerManager.get_inventory_slots()
	var buttons: Array = items_grid.get_children()

	for i in buttons.size():
		var btn: Button = buttons[i]

		# Clear any previous connection before rebinding - otherwise
		# repeated refreshes stack up multiple connections on the
		# same button, each bound to a stale item_id.
		for connection in btn.pressed.get_connections():
			btn.pressed.disconnect(connection["callable"])

		if i < slots.size():
			var slot: Dictionary = slots[i]
			var item_id: String = slot["item_id"]
			var count: int = slot["count"]
			var item_data: Dictionary = GameManager.get_item(item_id)
			var image_path: String = item_data.get("image", "")
			var effect: String = item_data.get("effect", "")
			var is_consumable: bool = effect == "heal" or effect == "mana"

			btn.icon = load(image_path) if (image_path != "" and ResourceLoader.exists(image_path)) else null
			btn.text = "x" + str(count) if count > 1 else ""
			# Hunter's Bow shows its split-shot charge instead ("2/3"),
			# so the player can plan for the split - only while it can
			# actually charge (a ranged hero).
			if item_id == "hunters_bow" and _is_ranged_hero():
				btn.text = "%d/%d" % [_hunters_bow_charge, HUNTERS_BOW_ATTACKS_PER_SPLIT]

			if is_consumable:
				btn.mouse_filter = Control.MOUSE_FILTER_STOP
				# Items are locked out for as long as The Test of Time is
				# active on the hero (see _the_test_of_time_active), or while
				# he's stunned/frozen (_player_stun_turns_left > 0 - set
				# by Drowned Surge's/Barbed Lunge's/Return to the Void's/Winter's Grip's/The Hunger
				# Calls's own stun, whether cast by the player or a rival
				# hero) - a stunned hero loses the turn entirely, same as
				# a stunned enemy loses its own (see _enemy_turn()'s stun
				# check), so there's nothing left for him to spend it on.
				btn.disabled = _battle_over or _has_acted_this_turn or _rival_fx_in_flight or _the_test_of_time_active or _player_stun_turns_left > 0 or _kiss_the_wastes_active
				btn.pressed.connect(_on_item_pressed.bind(item_id))
				# Lets _apply_tutorial_gate() find this button again by
				# item id without needing its own tracking dict, the way
				# _skill_buttons already does for skills.
				btn.set_meta("tutorial_item_id", item_id)
			else:
				# Equipment is passive, not clickable - but `disabled`
				# also dims the icon in Godot's default theme, which
				# would make owned gear look faded/less visible than a
				# potion. Blocking input via mouse_filter instead keeps
				# it fully bright while still being unclickable.
				btn.disabled = false
				btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.set_meta("tutorial_item_id", "")
		else:
			btn.icon = null
			btn.text = ""
			btn.disabled = true
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			btn.set_meta("tutorial_item_id", "")


func _refresh_gold_label() -> void:
	gold_value_label.text = str(PlayerManager.get_gold())


func _on_item_pressed(item_id: String) -> void:
	if _battle_over or _has_acted_this_turn or _rival_fx_in_flight or _the_test_of_time_active or _player_stun_turns_left > 0 or _kiss_the_wastes_active:
		return
	if not PlayerManager.use_item(item_id):
		return

	var item_data: Dictionary = GameManager.get_item(item_id)
	var effect: String = item_data.get("effect", "")
	var value: float = float(item_data.get("value", 0))
	_log_pending_action = "potion:" + item_id
	_log_potions[item_id] = int(_log_potions.get(item_id, 0)) + 1

	match effect:
		"heal":
			heal(value)
		"mana":
			restore_mana(value)

	if TutorialManager.is_active and TutorialManager.current_stage == 3:
		if _tutorial_stage3_step == "heal_up" and item_id == "health":
			_advance_tutorial_stage3_step("attack_to_level_up")
		elif _tutorial_stage3_step == "need_mana_potion" and item_id == "mana":
			_advance_tutorial_stage3_step("cast_ultimate_ready")

	_mark_turn_used()


func _build_bar_styles() -> void:
	var hp_fill := StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.8, 0.15, 0.15, 1)
	hp_fill.set_corner_radius_all(4)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)

	var mana_fill := StyleBoxFlat.new()
	mana_fill.bg_color = Color(0.2, 0.4, 0.9, 1)
	mana_fill.set_corner_radius_all(4)
	mana_bar.add_theme_stylebox_override("fill", mana_fill)

	var xp_fill := StyleBoxFlat.new()
	xp_fill.bg_color = Color(0.95, 0.65, 0.1, 1)
	xp_fill.set_corner_radius_all(4)
	xp_bar.add_theme_stylebox_override("fill", xp_fill)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	bg_style.set_corner_radius_all(4)
	hp_bar.add_theme_stylebox_override("background", bg_style)
	mana_bar.add_theme_stylebox_override("background", bg_style)
	xp_bar.add_theme_stylebox_override("background", bg_style)


func _refresh_bars() -> void:
	# Re-read from PlayerManager each time so bars always reflect the
	# saved values, even if damage/xp were applied elsewhere.
	_recruited = PlayerManager.get_recruited_hero()
	var stats: Dictionary = _recruited.get("stats", {})

	# Beast of the Elderwild's bonus hp while it's active shows up as extra
	# max here - a battle-local display bonus only, never written back to
	# PlayerManager (see _beast_of_the_elderwild_bonus_hp).
	hp_bar.max_value = _hero_max_hp()
	hp_bar.value = _recruited.get("current_hp", 0)
	hp_value_label.text = str(int(hp_bar.value)) + "/" + str(int(hp_bar.max_value))

	mana_bar.max_value = float(stats.get("mana", 1))
	mana_bar.value = _recruited.get("current_mana", 0)
	mana_value_label.text = str(int(mana_bar.value)) + "/" + str(int(mana_bar.max_value))

	# hero_xp tracks progress within the current level (see
	# PlayerManager.check_level_up), so the bar always fills from 0 up
	# to whatever the current level requires - no lifetime-total math.
	var xp_required: int = GameManager.get_xp_required_for_level(PlayerManager.get_level())
	if xp_required <= 0:
		# Max level - nothing further to progress toward, show a full bar.
		xp_bar.max_value = 1.0
		xp_bar.value = 1.0
		xp_value_label.text = "MAX"
	else:
		xp_bar.max_value = float(xp_required)
		xp_bar.value = clamp(_recruited.get("xp", 0), 0.0, float(xp_required))
		xp_value_label.text = str(int(xp_bar.value)) + "/" + str(int(xp_bar.max_value))

	# HP just changed (or at least might have) - re-check Savage
	# Roar's on/off state against the fresh numbers above.
	_update_blood_of_the_wild_state()

	_refresh_status_effects()
	_refresh_thornbind_vines()
	_refresh_winters_grip_hands()
	_refresh_frost_tempest_fx()
	_refresh_mothers_grasp_roots()
	_refresh_shackles()
	_refresh_luring_gaze_trances()
	_refresh_deathlight_lure()
	_refresh_venom_paralysis()
	_refresh_might_of_the_deep()
	_refresh_mark_of_stillness_frost()
	_refresh_void_marks()
	_refresh_kindled_embers()
	_refresh_hunger_calls_fx()

	# Called this pervasively (after nearly every action/tick in the
	# game - see _refresh_bars()'s own many call sites) so an enemy's
	# HP number stays current after damage/regen/potions too, not just
	# the movement/spawn/death paths that already call this directly.
	_refresh_enemy_overhead_labels()


## Keeps the "reserved HP" danger-zone marker and the three status
## badges (frost/curse/root) in sync with whatever's currently on the
## player - called every time _refresh_bars() is (i.e. constantly), so
## each one just reflects current state rather than being toggled from
## every individual cast/tick/dispel site.
func _refresh_status_effects() -> void:
	# Return to the Void's execute mechanic (see _tick_player_turn_start_effects())
	# reserves execute_pct of the player's OWN max HP as a fixed danger
	# zone near the bottom of the bar, not a chunk of current HP - so
	# this is a static width fraction of the bar, not tied to hp_bar's
	# own value.
	var reserving: bool = _player_return_to_the_void_execute_pct > 0.0 and _player_return_to_the_void_dot_turns_left > 0
	return_to_the_void_reserve_overlay.visible = reserving
	if reserving:
		return_to_the_void_reserve_overlay.anchor_right = clampf(_player_return_to_the_void_execute_pct, 0.0, 1.0)

	var frost_active: bool = _player_return_to_the_void_dot_turns_left > 0 or _player_winters_grip_dot_turns_left > 0 \
		or _player_mark_of_stillness_dot_turns_left > 0 or _player_the_hollow_cold_dot_turns_left > 0 \
		or _player_the_hunger_calls_active
	_set_status_icon_visible(frost_status_icon, frost_active)

	var curse_active: bool = _player_curse_active or _player_thornbind_dot_turns_left > 0
	_set_status_icon_visible(curse_status_icon, curse_active)

	var root_active: bool = _player_root_turns_left > 0 or _player_silence_turns_left > 0 or _player_stun_turns_left > 0
	_set_status_icon_visible(root_status_icon, root_active)

	# The frost skills' own ambient reminder - a persistent tint while
	# any of The Hunger Calls/Winter's Grip/Return to the Void's own effects are still
	# on the player, fading out the instant they all are (a win, a
	# flee, or the effect just running out all reach this the same way
	# - every one of them already ends up back through _refresh_bars()).
	var target_alpha: float = 0.24 if frost_active else 0.0
	if not is_equal_approx(ambient_tint_overlay.color.a, target_alpha):
		var tween := create_tween()
		tween.tween_property(ambient_tint_overlay, "color:a", target_alpha, 0.35)


## Toggles one of the three HP-bar status badges, playing a quick
## pop-in scale bounce the moment it switches from hidden to shown so
## a newly-applied effect catches the eye instead of just silently
## appearing - easy to miss otherwise at this size, tucked next to the
## HP bar. A no-op re-call while already in the target state (the
## common case, since this runs on every _refresh_bars()) doesn't
## replay the bounce.
func _set_status_icon_visible(icon: PanelContainer, should_be_visible: bool) -> void:
	if icon.visible == should_be_visible:
		return

	icon.visible = should_be_visible
	if not should_be_visible:
		return

	icon.pivot_offset = icon.size / 2.0
	icon.scale = Vector2(0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(icon, "scale", Vector2(1.25, 1.25), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "scale", Vector2.ONE, 0.1)


func _populate_skill_buttons() -> void:
	for child in skill_buttons_container.get_children():
		child.queue_free()
	_skill_buttons.clear()
	_skill_cooldown_labels.clear()
	_blood_of_the_wild_status_label = null

	var skills: Array = _hero_static.get("skills", [])
	var learned_skills: Dictionary = _recruited.get("learned_skills", {})

	for skill in skills:
		var skill_id: String = skill.get("id", "")
		var learned_level: int = learned_skills.get(skill_id, 0)
		var is_passive: bool = skill.get("type", "") == "passive"
		# The Mist Remembers is the one skill that's neither: a real
		# ("ultimate") level track and cooldown, but never clicked and
		# no mana cost -
		# it auto-activates off the hero's own HP% (see
		# _maybe_auto_activate_the_mist_remembers()) same as a passive would.
		var is_auto_activate: bool = skill.get("auto_activate", false)

		var slot := VBoxContainer.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.add_theme_constant_override("separation", 2)

		# Rows 1-2: the skill's name, split across two lines (see
		# _skill_name_button_text()) so a multi-word name doesn't get
		# clipped or force the slot wider than its neighbors.
		var btn := Button.new()
		btn.text = _skill_name_button_text(skill.get("name", "Skill"))
		btn.custom_minimum_size = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Row 3: mana cost, just the number - blank for a skill with no
		# point in it yet, since there's no level data behind it to make
		# a mana cost (or a Ready/Passive status, below) mean anything
		# yet; it's not "castable at this cost", it's not learned at all.
		var mana_label := Label.new()
		mana_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mana_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		mana_label.add_theme_constant_override("outline_size", 2)
		mana_label.add_theme_font_size_override("font_size", 12)
		mana_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1, 1))
		# Blank for skills that are never cast (passives, and The Mist
		# Remembers, which triggers itself) - they have no mana cost.
		if not is_passive and not is_auto_activate and learned_level > 0:
			var mana_level_data: Dictionary = GameManager.get_skill_level_data(skill, learned_level)
			var mana_cost: float = float(mana_level_data.get("mana_cost", skill.get("mana_cost", 0)))
			mana_label.text = str(int(mana_cost))

		# Row 4: ready/cooldown status.
		var status_label := Label.new()
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		status_label.add_theme_constant_override("outline_size", 2)
		status_label.add_theme_font_size_override("font_size", 12)

		if learned_level <= 0:
			# No skill point spent here yet - leave both labels blank
			# (mana above, status here) and the button disabled; there's
			# nothing "Ready" or "Passive" about a skill that isn't
			# learned at all.
			btn.disabled = true
		elif is_passive:
			# Passives (currently just Blood of the Wild and Mark of the
			# Mist) apply themselves automatically rather than
			# being cast - no click, no mana, no cooldown. The label
			# instead shows whether its effect is live right now (see
			# _update_blood_of_the_wild_state) or just "Passive" as a
			# default for one with no such live state to report.
			btn.disabled = true
			status_label.text = "Passive"
			status_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1, 1))
		elif is_auto_activate:
			# Never clickable, same as a passive, but it DOES have a
			# real cooldown - tracked and ticked exactly like a
			# manually-cast skill's (see _skill_cooldown_labels/
			# _skill_cooldowns below), just started by
			# _maybe_auto_activate_the_mist_remembers() instead of a button
			# press. _refresh_skill_cooldown_labels() overlays "Active"
			# on top of the normal Ready/cooldown text while it's
			# actually in effect.
			btn.disabled = true
			status_label.text = "Ready"
			status_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5, 1))
		else:
			btn.disabled = false
			btn.pressed.connect(_on_skill_pressed.bind(skill))
			status_label.text = "Ready"
			status_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5, 1))

		btn.set_meta(AudioManager.NO_CLICK_META, true)
		slot.add_child(btn)
		slot.add_child(mana_label)
		slot.add_child(status_label)
		skill_buttons_container.add_child(slot)

		if learned_level > 0:
			if is_passive:
				if skill_id == "blood_of_the_wild":
					_blood_of_the_wild_status_label = status_label
			else:
				_skill_cooldown_labels[skill_id] = status_label
				# Cooldowns persist across battles (see PlayerManager.
				# get_skill_cooldown/set_skill_cooldown), so a skill used
				# near the end of one fight stays locked into the next.
				_skill_cooldowns[skill_id] = PlayerManager.get_skill_cooldown(skill_id)

				# The Mist Remembers is never added to _skill_buttons - that
				# dict drives _update_action_buttons()'s per-turn lock,
				# which would re-enable its button (nothing handles a
				# click on it) the moment the hero hasn't acted yet.
				if not is_auto_activate:
					_skill_buttons[skill_id] = btn

	_refresh_skill_cooldown_labels()
	_update_blood_of_the_wild_state()


## Splits a skill's name across two lines for its button - the first
## word on its own line, every word after it on the second - so a
## multi-word name (e.g. "Elderwild Companion") doesn't get clipped or
## force its slot wider than its single-word neighbors (e.g. "Barbed Lunge").
## A one-word name is returned as-is, with no second line.
func _skill_name_button_text(skill_name: String) -> String:
	var space_index: int = skill_name.find(" ")
	if space_index == -1:
		return skill_name
	return skill_name.substr(0, space_index) + "\n" + skill_name.substr(space_index + 1)


func _on_skill_pressed(skill: Dictionary) -> void:
	if _battle_over or _has_acted_this_turn or _rival_fx_in_flight:
		return

	if _the_test_of_time_active:
		return

	if _kiss_the_wastes_active:
		_show_message_over_hero("Focused on Kiss the Wastes!")
		return

	if _player_silence_turns_left > 0:
		_show_message_over_hero("Silenced!")
		return

	var skill_id: String = skill.get("id", "")
	if _skill_cooldowns.get(skill_id, 0) > 0:
		return

	var skill_level: int = PlayerManager.get_skill_level(skill_id)
	if skill_level <= 0:
		return

	var level_data: Dictionary = GameManager.get_skill_level_data(skill, skill_level)

	# Mana cost lives per-level now (like every other per-level number),
	# so it can be tuned per level - skill.get() is only a fallback for
	# a skill that hasn't been given a "levels" array at all.
	var mana_cost: float = float(level_data.get("mana_cost", skill.get("mana_cost", 0)))
	if _recruited.get("current_mana", 0) < mana_cost:
		_show_message_over_hero("Not enough mana")
		if TutorialManager.is_active and TutorialManager.current_stage == 3 \
		and skill_id == "the_sunken_one" and _tutorial_stage3_step == "cast_ultimate":
			_advance_tutorial_stage3_step("need_mana_potion")
		return

	var generation_before: int = _stage_generation
	_log_pending_action = "skill:" + skill_id

	match skill_id:
		"barbed_lunge":
			if not _cast_barbed_lunge(level_data):
				# No target found - nothing happened, so don't spend
				# mana, the turn, or start the cooldown.
				return
		"abyssal_spasm":
			if not _cast_abyssal_spasm(level_data):
				# No enemies in range - same as above, no-op.
				return
		"sweep":
			if not _cast_sweep(level_data):
				# No enemies in range - same as above, no-op.
				return
		"double_trouble":
			if not _cast_double_trouble(level_data):
				# No enemies in range - same as above, no-op.
				return
		"blast_hopper":
			_activate_blast_hopper(level_data)
		"three_cheers":
			if not _start_three_cheers_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_three_cheers_cast), not here.
			return
		"kiss_the_wastes":
			if not _start_kiss_the_wastes_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_kiss_the_wastes_cast), not here.
			return
		"imperial_guard":
			_activate_imperial_guard(level_data)
		"hunting_instinct":
			_activate_hunting_instinct(level_data)
		"paralytic_venom":
			if not _cast_paralytic_venom(level_data):
				# No enemies in range - same as above, no-op.
				return
		"fallen_grace":
			if not _cast_fallen_grace(level_data):
				# No enemies in range - same as above, no-op.
				return
		"hope_of_the_fallen":
			if not _start_hope_of_the_fallen_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_hope_of_the_fallen_cast), not here.
			return
		"moonfall_lance":
			if not _start_moonfall_lance_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_moonfall_lance_cast), not here.
			return
		"eternal_eclipse":
			_activate_eternal_eclipse(level_data)
		"withering_pursuit":
			_activate_withering_pursuit(level_data)
		"ambush_strike":
			_activate_ambush_strike(level_data)
		"deathlight_lure":
			if not _start_deathlight_lure_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_deathlight_lure_cast), not here.
			return
		"shackles":
			if not _start_shackles_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_shackles_cast), not here.
			return
		"luring_gaze":
			if not _cast_luring_gaze(level_data):
				# No enemies in range - same as above, no-op.
				return
		"chainfire":
			if not _start_chainfire_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_chainfire_cast), not here.
			return
		"cinderbomb":
			if not _start_cinderbomb_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_cinderbomb_cast), not here.
			return
		"whisper_of_the_veil":
			# Pressing the button again while its own targeting is still
			# open self-casts - the hero's portrait can be fully covered
			# by a melee creep sharing his column, leaving no spot to
			# click it.
			if _targeting_mode and _targeting_purpose == "whisper_of_the_veil":
				_resolve_whisper_of_the_veil_self_cast(_pending_whisper_of_the_veil_level_data)
				return
			_start_whisper_of_the_veil_targeting(level_data)
			# Whisper of the Veil needs the player to click a target first - an
			# enemy to damage, or the hero's own portrait to heal
			# himself - so the mana/cooldown/turn spend happens once
			# that click resolves (_resolve_whisper_of_the_veil_enemy_cast()/
			# _resolve_whisper_of_the_veil_self_cast()), not here. Bail out of
			# this function without falling through to the shared
			# spend logic below, same as Thornbind.
			return
		"leeching_hunger":
			_activate_leeching_hunger(level_data)
		"depthsveil":
			_activate_depthsveil(level_data)
		"rootveil":
			_activate_rootveil(level_data)
		"frostbound_fangs":
			_activate_frostbound_fangs(level_data)
		"the_test_of_time":
			_activate_the_test_of_time(level_data)
		"elderwild_companion":
			_elderwild_companion(level_data)
		"wildbond":
			_activate_wildbond(level_data)
		"beast_of_the_elderwild":
			_activate_beast_of_the_elderwild(level_data)
		"veil_of_the_forgotten":
			_activate_veil_of_the_forgotten(level_data)
		"thornbind":
			if not _start_thornbind_targeting(level_data):
				# No enemy in range - nothing happened, so don't spend
				# mana, the turn, or start the cooldown, same as above.
				return
			# Thornbind needs the player to click a target first - the
			# mana/cooldown/turn spend below happens once that click
			# resolves (_resolve_thornbind_cast), not here, so bail out
			# of this function without falling through to it.
			return
		"drowned_surge":
			if not _start_drowned_surge_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as Thornbind/Whisper of the Veil - the
			# mana/cooldown/turn spend happens once the click resolves
			# (_resolve_drowned_surge_cast), not here.
			return
		"undertow":
			if not _start_undertow_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_undertow_cast), not here.
			return
		"the_sunken_one":
			if not _cast_the_sunken_one(level_data):
				# No enemy in the line of fire - nothing happened, so
				# don't spend mana, the turn, or start the cooldown.
				return
			# No target to pick: it fires the way Kaelen Varr faces.
			# _cast_the_sunken_one() spends the mana and starts the
			# cooldown itself, and ends the turn once the broadside lands.
			return
		"mark_of_stillness":
			if not _start_mark_of_stillness_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_mark_of_stillness_cast), not here.
			return
		"the_hollow_cold":
			if not _start_the_hollow_cold_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_the_hollow_cold_cast), not here.
			return
		"touch_of_the_first_cold":
			if not _start_touch_of_the_first_cold_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_touch_of_the_first_cold_cast), not here.
			return
		"return_to_the_void":
			if not _start_return_to_the_void_targeting(level_data):
				# No living enemy anywhere on the field - nothing
				# happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_return_to_the_void_cast), not here.
			return
		"maddening_roar":
			if not _start_maddening_roar_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_maddening_roar_cast), not here.
			return
		"the_hunger_calls":
			if not _start_the_hunger_calls_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_the_hunger_calls_cast), not here.
			return
		"rimecleaver":
			if not _start_rimecleaver_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_rimecleaver_cast), not here.
			return
		"winters_grip":
			if not _start_winters_grip_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_winters_grip_cast), not here.
			return
		"the_frost_tempest":
			_activate_frost_tempest(level_data)
		"frostbound_rupture":
			if not _start_frostbound_rupture_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_frostbound_rupture_cast), not here.
			return
		"charge":
			if not _start_charge_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_charge_cast), not here.
			return
		"bestial_rage":
			_activate_bestial_rage(level_data)
		"glacier_breaker":
			if not _start_glacier_breaker_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_glacier_breaker_cast), not here.
			return
		"sanguine_bloom":
			if not _start_sanguine_bloom_targeting(level_data):
				# No enemy in range - nothing happened, same as above.
				return
			# Same deferred-spend pattern as every other targeted skill
			# above - the mana/cooldown/turn spend happens once the
			# click resolves (_resolve_sanguine_bloom_cast), not here.
			return
		"woven_flesh":
			_activate_woven_flesh(level_data)
		"mother's_grasp":
			_activate_mothers_grasp(level_data)
		_:
			# No effect implemented yet for other skills - this is the
			# hook point for when they're added. For now it just
			# confirms the wiring works end to end.
			print("Used skill: ", skill.get("name", ""))

	# Depthsveil/Rootveil/Ambush Strike only break from
	# attacking or casting ANOTHER skill - not from the cast that just
	# activated them in the first place, and not from items/potions
	# (those never reach this function at all). Only one of the three
	# could ever be active in a given battle (different heroes' own
	# kits), so this just ends whichever one actually is.
	if _is_hero_hidden() and skill_id != "depthsveil" and skill_id != "rootveil" and skill_id != "ambush_strike":
		if _depthsveil_active:
			_end_depthsveil()
		elif _rootveil_active:
			_end_rootveil()
		elif _ambush_strike_active:
			_end_ambush_strike()

	spend_mana(mana_cost)
	_skill_cooldowns[skill_id] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown(skill_id, _skill_cooldowns[skill_id])
	_refresh_skill_cooldown_labels()

	# If that cast cleared the stage (or won a hero fight) and a fresh
	# encounter started, the turn lock has already been reset for it -
	# re-locking it here would carry the old turn's "used" state into
	# an encounter that hasn't had a turn yet. The cooldown/mana spend
	# above still applies regardless.
	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Veyrik's Barbed Lunge: leaps `level_data.distance` columns toward the
## nearest enemy - overriding the hero's normal speed-based move
## distance - and stops early if it lands on an enemy's column along
## the way. That enemy takes a standard attack and gets stunned for
## `level_data.stun_turns` of its own turns (see the "stun_turns_left"
## counter checked at the top of each enemy's turn in _enemy_turn()).
## Returns false (leaving position/turn untouched) if there's no
## enemy anywhere to leap toward.
func _cast_barbed_lunge(level_data: Dictionary) -> bool:
	if _enemies.is_empty():
		_show_message_over_hero("No target for Barbed Lunge")
		return false

	var nearest: Dictionary = {}
	var nearest_distance: int = GRID_COLUMNS + 1
	for enemy in _enemies:
		var d: int = _distance(enemy["pos_index"], _hero_pos_index)
		if d < nearest_distance:
			nearest_distance = d
			nearest = enemy

	var direction: int = _step_toward(_hero_pos_index, nearest["pos_index"])
	if direction == 0:
		# Already sharing the enemy's column - still leap somewhere
		# rather than doing nothing.
		direction = 1

	var move_distance: int = int(level_data.get("distance", 2))
	var pos: int = _hero_pos_index
	var hit_enemy: Dictionary = {}

	for i in range(move_distance):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		# A rival's Frostbound Rupture wall stops the leap dead - it can't carry
		# the hero past a blocked column, same "can't step into one"
		# rule _melee_move_target()/_ranged_move_target() already
		# enforce for a normal move.
		if _is_column_enemy_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos

		var enemy_here: Dictionary = _get_enemy_at(pos)
		if not enemy_here.is_empty():
			hit_enemy = enemy_here
			break

	_hero_pos_index = pos
	_update_hero_position()

	if not hit_enemy.is_empty():
		_deal_damage_to_enemy(hit_enemy)
		# Only stun if it survived the hit - a dead enemy has already
		# been removed from _enemies by _deal_damage_to_enemy's kill check.
		if hit_enemy.get("current_hp", 0) > 0:
			hit_enemy["stun_turns_left"] = int(level_data.get("stun_turns", 1))

	return true


## Veyrik's Abyssal Spasm: deals `level_data.damage_multiplier` of one
## rolled hero-damage hit to every enemy within `level_data.radius`
## columns of Veyrik (0 = only Veyrik's own column), each still
## mitigated by that enemy's own armor. All hits share the same
## rolled amount - it's one burst around Veyrik, not a separate attack
## roll per enemy. (Silencing enemies caught in it isn't implemented yet.)
## Returns false (no mana/turn/cooldown spent) if nothing is in range.
func _cast_abyssal_spasm(level_data: Dictionary) -> bool:
	var radius: int = int(level_data.get("radius", 0))
	var targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			targets.append(enemy)

	if targets.is_empty():
		_show_message_over_hero("No enemies in range")
		return false

	var multiplier: float = float(level_data.get("damage_multiplier", 0.75))
	var pact_damage: float = _roll_hero_damage() * multiplier
	for enemy in targets:
		_deal_fixed_damage_to_enemy(enemy, pact_damage)
		# Same red hit-flash as Lunar Ricochet' bounce, so every enemy
		# caught in the burst visibly reacts, not just via damage numbers.
		if is_instance_valid(enemy.get("node")):
			_flash_bounce_hit(enemy["node"])
	# Self-centered on the hero, same as the check above - a rival's own
	# guard (The Last Empress's Imperial Guard) can be in range independently
	# of whether the boss itself currently is.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, radius, pact_damage, true)

	return true


## Cinder's Sweep: deals `level_data.damage` (a flat amount,
## not a roll off the hero's own attack) to every enemy within
## `level_data.radius` columns of Cinder. Same shape as
## _cast_abyssal_spasm() above, just with a flat damage value instead of a
## multiplier on a rolled hit. Returns false (no mana/turn/cooldown
## spent) if nothing is in range.
func _cast_sweep(level_data: Dictionary) -> bool:
	var radius: int = int(level_data.get("radius", 0))
	var targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			targets.append(enemy)

	if targets.is_empty():
		_show_message_over_hero("No enemies in range")
		return false

	var sweep_damage: float = float(level_data.get("damage", 0))
	_play_sweep_flames(_hero_pos_index, radius)
	for enemy in targets:
		_deal_fixed_damage_to_enemy(enemy, sweep_damage)
		# The standard splash hit-flash (see _apply_splash_damage()).
		if is_instance_valid(enemy.get("node")):
			_flash_bounce_hit(enemy["node"])
	# Self-centered on the hero, same as the check above - a rival's own
	# guard (The Last Empress's Imperial Guard) can be in range independently
	# of whether the boss itself currently is.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, radius, sweep_damage, true)

	return true


## Purely cosmetic: Sweep's wall of tall flames (SweepFlamesFX), erupting
## out of the ground around the caster's column `pos_index` - from its
## feet outward - to `radius` columns either side, on the ground line.
func _play_sweep_flames(pos_index: int, radius: int) -> void:
	if not is_instance_valid(_fx_layer):
		return
	var center := Vector2(_index_to_x(pos_index) + _grid_unit() * 0.5, _the_sunken_one_ground_y())
	var half_width: float = _grid_unit() * (float(radius) + 0.5)
	SweepFlamesFX.play(_fx_layer, center, half_width, get_viewport_rect().size.y / 4.0)


## Dreadlure's Paralytic Venom: deals `level_data.damage` and stuns
## (target["stun_turns_left"], same shared field Barbed Lunge's/Drowned Surge's own
## stun use) every enemy within `level_data.radius` columns of Dreadlure -
## same shape as _cast_sweep() above, just with a stun folded
## in and only ever stunning a hit that actually left the target alive.
## Returns false (no mana/turn/cooldown spent) if nothing is in range.
func _cast_paralytic_venom(level_data: Dictionary) -> bool:
	var radius: int = int(level_data.get("radius", 0))
	var targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			targets.append(enemy)

	if targets.is_empty():
		_show_message_over_hero("No enemies in range")
		return false

	var venom_damage: float = float(level_data.get("damage", 0))
	var stun_turns: int = int(level_data.get("stun_turns", 0))
	# Everyone the wave will hit, captured (and the slam played) before
	# any damage lands - a kill frees its node.
	var hit_nodes: Array = []
	for enemy in targets:
		hit_nodes.append(enemy.get("node"))
	for guard in _enemy_guards:
		if _distance(guard["pos_index"], _hero_pos_index) <= radius:
			hit_nodes.append(guard.get("node"))
	_play_paralytic_venom(hero_image, radius, hit_nodes)

	for enemy in targets:
		_deal_fixed_damage_to_enemy(enemy, venom_damage)
		if enemy.get("current_hp", 0) > 0:
			enemy["stun_turns_left"] = stun_turns
			enemy["venom_paralyzed"] = stun_turns > 0
			enemy["luring_gaze_entranced"] = false
	# Self-centered on the hero, same as the check above - a rival's own
	# guard (The Last Empress's Imperial Guard) can be in range independently
	# of whether the boss itself currently is. The rival's own Spirit
	# Bear needs no equivalent call - it's a genuine _enemies entry
	# (see _summon_enemy_elderwild_companion()), so the `targets` loop above
	# already caught it, stun included.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, radius, venom_damage)

	return true


## Solara's Fallen Grace: deals `level_data.damage` (a flat amount, not a
## roll off the hero's own attack) to every enemy within
## `level_data.radius` columns of Solara - same shape as
## _cast_sweep()/_cast_paralytic_venom() above, just with no
## stun/CC folded in. Returns false (no mana/turn/cooldown spent) if
## nothing is in range.
func _cast_fallen_grace(level_data: Dictionary) -> bool:
	var radius: int = int(level_data.get("radius", 0))
	var targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			targets.append(enemy)

	if targets.is_empty():
		_show_message_over_hero("No enemies in range")
		return false

	var fallen_grace_damage: float = float(level_data.get("damage", 0))
	# Arrows at every unit about to be hit - launched before any damage
	# lands, since a kill frees its node.
	var star_nodes: Array = []
	for enemy in targets:
		star_nodes.append(enemy.get("node"))
	for guard in _enemy_guards:
		if _distance(guard["pos_index"], _hero_pos_index) <= radius:
			star_nodes.append(guard.get("node"))
	_play_arrow_volley(hero_image, star_nodes)

	for enemy in targets:
		_deal_fixed_damage_to_enemy(enemy, fallen_grace_damage)
	# Self-centered on the hero, same as the check above - a rival's own
	# guard (The Last Empress's Imperial Guard) can be in range independently
	# of whether the boss itself currently is. The rival's own Spirit
	# Bear needs no equivalent call - it's a genuine _enemies entry
	# (see _summon_enemy_elderwild_companion()), so the `targets` loop above
	# already caught it.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, radius, fallen_grace_damage)

	return true


## The Last Empress's ultimate, Luring Gaze: stuns (target["stun_turns_
## left"], same shared field Barbed Lunge's/Drowned Surge's/Blast Hopper's own
## stun use) and shreds the armor (target["armor_reduction"]/
## "armor_reduction_turns_left", the same per-instance runtime fields
## Three Cheers's own shred uses - stacking additively with any
## already on a target, but refreshing (not adding to) the turns left,
## same "reapplying overwrites the timer" convention every other
## refreshable debuff in this file uses) of every enemy within this
## level's own radius of the hero's CURRENT position, both for this
## level's own stun_turns. Purely offensive - no damage of its own, and
## nothing about the hero himself changes (he and his guards can
## still move/attack normally the whole time, unlike Kiss the Wastes'
## own channel). Returns false (no mana/turn/cooldown spent) if nothing
## is in range.
func _cast_luring_gaze(level_data: Dictionary) -> bool:
	var radius: int = int(level_data.get("radius", 0))
	var targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			targets.append(enemy)

	if targets.is_empty():
		_show_message_over_hero("No enemies in range")
		return false

	var stun_turns: int = int(level_data.get("stun_turns", 0))
	var armor_reduction: float = float(level_data.get("armor_reduction", 0))
	for enemy in targets:
		enemy["stun_turns_left"] = stun_turns
		enemy["armor_reduction"] = float(enemy.get("armor_reduction", 0.0)) + armor_reduction
		# +1: the shred ticks at the start of each enemy turn, BEFORE that
		# turn's stun check, so it must outlast the last stunned turn.
		enemy["armor_reduction_turns_left"] = stun_turns + 1
		# Marks this stun as the gaze's trance - drives its visual (see
		# _refresh_luring_gaze_trances()).
		enemy["luring_gaze_entranced"] = true
		enemy["venom_paralyzed"] = false

	var gazed: Array = []
	for enemy in targets:
		gazed.append(enemy.get("node"))
	_play_luring_gaze(hero_image, gazed)
	_refresh_luring_gaze_trances()
	_show_message_over_hero("Luring Gaze!")
	return true


## Raze's Double Trouble: fires straight in whatever direction she's
## currently facing (hero_image.flip_h, kept up to date by _hero_move()/
## every other repositioning skill that sets it), dealing
## level_data.damage to every enemy within level_data.range columns
## AHEAD of her in that direction only - unlike Sweep's/Dark
## Pact's own radius checks above, which look every direction at once,
## an enemy behind her (or sharing her own column) is never hit. Returns
## false (no mana/turn/cooldown spent) if nothing is in range.
func _cast_double_trouble(level_data: Dictionary) -> bool:
	var range_columns: int = int(level_data.get("range", 0))
	var direction: int = -1 if hero_image.flip_h else 1

	var targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		# 0 = sharing Raze's own column (point-blank - still in front
		# of the blast regardless of which way she's facing), up through
		# range_columns strictly ahead in her facing direction.
		var ahead: int = (enemy["pos_index"] - _hero_pos_index) * direction
		if ahead >= 0 and ahead <= range_columns:
			targets.append(enemy)

	if targets.is_empty():
		_show_message_over_hero("No enemies in range")
		return false

	var trouble_damage: float = float(level_data.get("damage", 0))
	for enemy in targets:
		_deal_fixed_damage_to_enemy(enemy, trouble_damage)
	# Same directional cone as the check above - a rival's own guard
	# (The Last Empress's Imperial Guard) ahead of the hero can be caught in it
	# independently of whether the boss itself currently is.
	_deal_directional_aoe_damage_to_enemy_guards(_hero_pos_index, direction, range_columns, trouble_damage)

	_play_double_trouble_effect(hero_image, direction, range_columns)

	return true


## Where the muzzle of Raze's shotgun sits on her art (fraction of the
## node's size, facing right - mirrored when she faces left).
const DOUBLE_TROUBLE_MUZZLE := Vector2(0.965, 0.13)

## Where her mouth sits on her art (same convention) - the blown kiss of
## Kiss the Wastes starts here.
const RAZE_MOUTH := Vector2(0.44, 0.16)


## Purely cosmetic: both barrels go off at `origin_node`'s muzzle - a
## flash, a cone of fire and smoke, and pellets fanning out toward
## `direction` (+1 right, -1 left) for roughly `range_columns` columns
## (see DoubleTroubleFX) - visualizes Double Trouble's blast, from
## whichever side cast it (the player's own hero_image, or a rival's own
## node). The damage above has already fully resolved by the time this
## plays; it never gates on this.
func _play_double_trouble_effect(origin_node: Control, direction: int, range_columns: int) -> void:
	if not is_instance_valid(origin_node):
		return

	var muzzle := DOUBLE_TROUBLE_MUZZLE
	if direction < 0:
		muzzle.x = 1.0 - muzzle.x
	var from: Vector2 = origin_node.global_position + origin_node.size * muzzle
	DoubleTroubleFX.play(_fx_layer, from, direction, _grid_unit() * maxf(1.0, float(range_columns)))
	_shake_screen()


## How long Blast Hopper's leap lasts - the animator's own arc, the
## launch charge at the start, the shots at the peak (half way) and the
## landing all key off this.
const BLAST_HOP_DURATION := 0.7


## Purely cosmetic: Blast Hopper's leap, from either side. A charge goes
## off under `node`'s feet where it stood (`old_x`, its x before the move
## - the node itself has already been moved to the landing column) and
## throws it high into the air toward `direction`; at the peak both
## barrels fire down at the landing spot (the blast covering
## `radius_columns`), and it comes down in a puff of dust. The damage and
## stun have already fully resolved - none of this gates them.
func _play_blast_hop_effect(node: TextureRect, old_x: float, direction: int, radius_columns: int) -> void:
	if not is_instance_valid(node):
		return
	var height: float = get_viewport_rect().size.y * 0.2
	var shift: float = old_x - node.position.x   # how far back the leap starts
	var feet_new: Vector2 = node.global_position + Vector2(node.size.x * 0.5, node.size.y - 4.0)
	var feet_old: Vector2 = feet_new + Vector2(shift, 0.0)
	var muzzle_frac := DOUBLE_TROUBLE_MUZZLE
	if node.flip_h:
		muzzle_frac.x = 1.0 - muzzle_frac.x
	var peak_muzzle: Vector2 = node.global_position + Vector2(shift * 0.5, -height) + node.size * muzzle_frac
	var radius_px: float = _grid_unit() * (float(radius_columns) + 0.5)

	var animator := CreatureAnimator.of(node)
	if animator != null:
		animator.play_blast_hop(shift, height, BLAST_HOP_DURATION)

	BlastHopperFX.launch(_fx_layer, feet_old, direction)
	get_tree().create_timer(BLAST_HOP_DURATION * 0.5).timeout.connect(func() -> void:
		if _battle_over or not is_instance_valid(node):
			return
		BlastHopperFX.slam(_fx_layer, peak_muzzle, feet_new, radius_px, _shake_screen))
	get_tree().create_timer(BLAST_HOP_DURATION).timeout.connect(func() -> void:
		if _battle_over or not is_instance_valid(node):
			return
		BlastHopperFX.land(_fx_layer, feet_new))


## Raze's Blast Hopper: hops level_data.jump_distance columns in
## whatever direction she's currently facing (hero_image.flip_h, same
## convention Double Trouble reads), same move-distance rules
## (board edge/Frostbound Rupture wall, ranged-vs-melee straight-through-or-
## stop-on-enemy) as a normal move (see _hero_move()) - then, on
## landing, deals level_data.damage and stuns for level_data.stun_turns
## every enemy within level_data.radius columns of wherever she ends
## up, if any (there doesn't need to be one for the hop itself to
## happen - unlike Barbed Lunge, this never "fails" for lack of a target).
## Only stuns a hit enemy that's still alive - a dead one has already
## been removed from _enemies by _deal_fixed_damage_to_enemy's kill
## check.
func _activate_blast_hopper(level_data: Dictionary) -> void:
	var jump_distance: int = int(level_data.get("jump_distance", 0))
	var direction: int = -1 if hero_image.flip_h else 1
	var old_x: float = hero_image.position.x

	if _is_ranged_hero():
		_hero_pos_index = _ranged_move_target(_hero_pos_index, direction, jump_distance)
	else:
		_hero_pos_index = _melee_move_target(_hero_pos_index, direction, jump_distance)
	_update_hero_position()
	_play_blast_hop_effect(hero_image, old_x, direction, int(level_data.get("radius", 0)))

	var radius: int = int(level_data.get("radius", 0))
	var damage: float = float(level_data.get("damage", 0))
	var stun_turns: int = int(level_data.get("stun_turns", 0))
	for enemy in _enemies.duplicate():
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			_deal_fixed_damage_to_enemy(enemy, damage)
			if enemy.get("current_hp", 0) > 0:
				enemy["stun_turns_left"] = stun_turns
	# Centered on the landing spot, same as the check above - a rival's
	# own guard (The Last Empress's Imperial Guard) can be in range
	# independently of whether the boss itself currently is.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, radius, damage)


## Withering Pursuit's pacing: how long each column of the RUN takes (a dash
## is much quicker), and the jump's base time, extra time per column, and
## height (as a fraction of the screen's height) - taller for a longer jump.
const WITHERING_PURSUIT_RUN_PER_COLUMN := 0.17
const WITHERING_PURSUIT_DASH_PER_COLUMN := 0.07
const WITHERING_PURSUIT_JUMP_BASE := 0.4
const WITHERING_PURSUIT_JUMP_PER_COLUMN := 0.1
const WITHERING_PURSUIT_HEIGHT_BASE := 0.12
const WITHERING_PURSUIT_HEIGHT_PER_COLUMN := 0.025


## Purely cosmetic: Withering Pursuit, from either side - a RUN (a fast
## DASH, with a blur of afterimages streaming behind, at the higher levels)
## of `move_cols` columns along the ground, then a JUMP of `jump_cols`
## columns up and over. `node` has already been moved to its landing column
## (it stood at `old_x`); `direction` is +1/-1. Dust kicks up at each step
## and at the takeoff and landing. The move itself has already resolved -
## none of this gates it.
func _play_withering_pursuit_effect(node: TextureRect, old_x: float, direction: int, move_cols: int, jump_cols: int, dash: bool) -> void:
	if not is_instance_valid(node):
		return
	var unit: float = _grid_unit()
	var run_dx: float = float(direction * move_cols) * unit
	var run_time: float = float(move_cols) * (WITHERING_PURSUIT_DASH_PER_COLUMN if dash else WITHERING_PURSUIT_RUN_PER_COLUMN)
	var jump_time: float = WITHERING_PURSUIT_JUMP_BASE + WITHERING_PURSUIT_JUMP_PER_COLUMN * float(jump_cols)
	var height: float = get_viewport_rect().size.y * (WITHERING_PURSUIT_HEIGHT_BASE + WITHERING_PURSUIT_HEIGHT_PER_COLUMN * float(jump_cols))
	var start_x: float = old_x - node.position.x
	var feet_new: Vector2 = node.global_position + Vector2(node.size.x * 0.5, node.size.y - 4.0)
	var feet_old: Vector2 = feet_new + Vector2(start_x, 0.0)
	var feet_takeoff: Vector2 = feet_old + Vector2(run_dx, 0.0)

	var animator := CreatureAnimator.of(node)
	if animator != null:
		animator.play_run_leap(start_x, run_dx, float(direction), height, run_time, jump_time, dash)

	# The footsteps of the run (the steps sound, cut to the length of the run
	# so a dash is a quick patter), then dust at the start and kicked up
	# behind her at every column she runs.
	if move_cols > 0:
		AudioManager.play_event_for("steps", run_time, 0.05)
	BlastHopperFX.land(_fx_layer, feet_old, true)
	for i in range(1, move_cols + 1):
		var at := feet_old + Vector2(float(direction * i) * unit, 0.0)
		get_tree().create_timer(run_time * float(i) / float(move_cols)).timeout.connect(func() -> void:
			if not _battle_over and is_instance_valid(_fx_layer):
				BlastHopperFX.land(_fx_layer, at, true))
	# The jump: dust at takeoff (if she ran at all - the run's last puff is it
	# otherwise) and at the landing.
	get_tree().create_timer(run_time + jump_time).timeout.connect(func() -> void:
		if not _battle_over and is_instance_valid(_fx_layer):
			BlastHopperFX.land(_fx_layer, feet_new, true)
			AudioManager.play_event_for("steps", 0.22, 0.08))

	# A trail of golden dust riding her body through the jump.
	var trail := CPUParticles2D.new()
	trail.local_coords = false
	trail.amount = 40
	trail.lifetime = 0.4
	trail.texture = VoidReachFX._dot()
	trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	trail.emission_sphere_radius = node.size.x * 0.12
	trail.spread = 180.0
	trail.gravity = Vector2(0.0, 30.0)
	trail.initial_velocity_min = 6.0
	trail.initial_velocity_max = 28.0
	trail.scale_amount_min = 0.8
	trail.scale_amount_max = 2.0
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(1.0, 0.9, 0.6, 0.0), Color(1.0, 0.75, 0.35, 0.7), Color(0.7, 0.35, 0.15, 0.0)])
	trail.color_ramp = ramp
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	trail.material = additive
	trail.emitting = false
	_fx_layer.add_child(trail)
	var body_offset := Vector2(0.0, -node.size.y * 0.45)
	var tween := trail.create_tween()
	tween.tween_interval(run_time)
	tween.tween_callback(func() -> void: trail.emitting = true)
	tween.tween_method(func(p: float) -> void:
		trail.global_position = feet_takeoff.lerp(feet_new, p) + body_offset - Vector2(0.0, height * 4.0 * p * (1.0 - p)), 0.0, 1.0, jump_time)
	tween.tween_callback(func() -> void: trail.emitting = false)
	tween.tween_interval(trail.lifetime + 0.1)
	tween.tween_callback(trail.queue_free)

	# The dash's blur: afterimages shed behind her, fading fast.
	if dash and animator != null:
		var blur_for: float = run_time + jump_time
		var spawned: Array = [0.0]
		var blur := trail.create_tween().set_loops()
		blur.tween_callback(func() -> void:
			if not is_instance_valid(node) or spawned[0] >= blur_for:
				return
			_spawn_pursuit_afterimage(node, animator, direction))
		blur.tween_callback(func() -> void: spawned[0] += 0.03)
		blur.tween_interval(0.03)


## One afterimage of `node` where the animation currently has it drawn:
## a golden-tinted copy of its sprite just BEHIND it, fading and shrinking
## away in a fraction of a second - strung together they read as a blur.
func _spawn_pursuit_afterimage(node: TextureRect, animator: CreatureAnimator, direction: int) -> void:
	var parent := node.get_parent()
	if parent == null:
		return
	var ghost := TextureRect.new()
	ghost.texture = node.texture
	ghost.expand_mode = node.expand_mode
	ghost.stretch_mode = node.stretch_mode
	ghost.flip_h = node.flip_h
	ghost.size = node.size
	ghost.pivot_offset = node.pivot_offset
	ghost.scale = node.scale
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.modulate = Color(1.0, 0.82, 0.5, 0.42)
	parent.add_child(ghost)
	parent.move_child(ghost, node.get_index())
	var offset := animator.current_offset()
	ghost.global_position = node.global_position + offset
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "global_position:x", ghost.global_position.x - float(direction) * 28.0, 0.22)
	tween.parallel().tween_property(ghost, "modulate:a", 0.0, 0.22)
	tween.tween_callback(ghost.queue_free)


## Solara's Withering Pursuit: a RUN of level_data.move_distance columns
## (a fast dash at the higher levels - level_data.dash) followed by a JUMP
## of level_data.jump_distance columns, all in whatever direction she's
## currently facing (hero_image.flip_h, same convention Double
## Trouble/Blast Hopper already read) - so she covers move_distance +
## jump_distance columns in all. Unlike Blast Hopper's own hop, this
## ALWAYS sails clean over any enemy in the way regardless of range_type
## (the unobstructed "walk straight through" rule _ranged_move_target()
## already uses for a ranged hero, applied here even for a melee one),
## stopping only at the board edge or a rival's Frostbound Rupture wall -
## and if it is cut short, the run is what keeps its length and the jump
## is what shortens. No damage, no target required - always "succeeds",
## same as every other self-cast buff.
func _activate_withering_pursuit(level_data: Dictionary) -> void:
	_withering_miss_chance = float(level_data.get("miss_chance_pct", 0.0))
	_withering_miss_turns = int(level_data.get("miss_turns", 0))
	var move_distance: int = int(level_data.get("move_distance", 0))
	var jump_distance: int = int(level_data.get("jump_distance", 0))
	var direction: int = -1 if hero_image.flip_h else 1
	var old_x: float = hero_image.position.x
	var old_index: int = _hero_pos_index

	_hero_pos_index = _ranged_move_target(_hero_pos_index, direction, move_distance + jump_distance)
	CreatureAnimator.silent_moves = true
	_update_hero_position()
	CreatureAnimator.silent_moves = false
	var moved: int = absi(_hero_pos_index - old_index)
	var run_columns: int = mini(move_distance, moved)
	_play_withering_pursuit_effect(hero_image, old_x, direction, run_columns, moved - run_columns, bool(level_data.get("dash", false)))


## Resolves an Shackles cast on `target`: `level_data.damage` (mitigated
## by the target's own armor via _deal_fixed_damage_to_enemy(), same
## helper Abyssal Spasm/Drowned Surge/The Sunken One use) plus a root for this level's
## own `root_turns` - reusing _apply_root() with no `silence_turns`/
## `dot_damage`/`dot_duration` keys in `level_data` (all default to 0
## there), so unlike Thornbind this only ever roots, never silences or
## burns - a rooted enemy can still attack and cast skills, just not
## move or jump (see _is_enemy_rooted()'s own call sites in
## _enemy_turn()/_enemy_hero_turn(), which only ever gate movement
## branches). Only roots if the hit actually left it alive.
func _resolve_shackles_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	# Higher levels also catch enemies up to `spread_radius` columns either
	# side of the target (the closest first, then the weakest), up to
	# `extra_targets` of them - picked before the hit, since a kill can
	# change who is left standing there.
	var shackled_targets: Array = [target]
	var extras: Array = []
	for enemy in _enemies:
		if enemy != target and not _is_target_hidden(enemy) and _distance(enemy["pos_index"], target["pos_index"]) <= int(level_data.get("spread_radius", 0)):
			extras.append(enemy)
	extras.sort_custom(func(a, b):
		var da: int = _distance(a["pos_index"], target["pos_index"])
		var db: int = _distance(b["pos_index"], target["pos_index"])
		if da != db:
			return da < db
		return float(a.get("current_hp", 0)) < float(b.get("current_hp", 0)))
	shackled_targets.append_array(extras.slice(0, int(level_data.get("extra_targets", 0))))

	for shackled in shackled_targets:
		_deal_fixed_damage_to_enemy(shackled, damage)
		if shackled.get("current_hp", 0) > 0:
			_apply_root(shackled, level_data)
			# The chains stay on it for as long as this root does (see
			# _refresh_shackles()).
			shackled["shackled"] = true
	_refresh_shackles()

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["shackles"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("shackles", _skill_cooldowns["shackles"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves a Deathlight Lure cast on `target`: reduces its armor by
## this level's own `armor_reduction` (target["armor_reduction"], the
## same per-instance runtime field Three Cheers's own shred and Luring
## Gaze use - stacking additively with any already on it) and
## marks it with `bonus_damage_pct` (target["deathlight_lure_bonus_pct"],
## read by _deal_fixed_damage_to_enemy() to boost every hit it takes
## from the hero's own attacks/skills - overwritten outright on
## recast, not stacked, since a second mark isn't meant to double the
## vulnerability). Both share `duration`'s own turns-left counter
## (target["armor_reduction_turns_left"]) - see
## _tick_enemy_turn_start_effects()'s own comment on why that's fine to
## share with Three Cheers's shred. Deals no damage of its own - a
## pure debuff.
func _resolve_deathlight_lure_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	target["armor_reduction"] = float(target.get("armor_reduction", 0.0)) + float(level_data.get("armor_reduction", 0))
	target["deathlight_lure_bonus_pct"] = float(level_data.get("bonus_damage_pct", 0.0))
	target["armor_reduction_turns_left"] = int(level_data.get("duration", 0))
	if target["static"].get("is_hero_fight_boss", false):
		_reveal_enemy_hero()

	_play_deathlight_lure(hero_image, target.get("node"))
	_refresh_deathlight_lure()
	_show_message_over_hero("Deathlight Lure!")

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["deathlight_lure"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("deathlight_lure", _skill_cooldowns["deathlight_lure"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves a Hope of the Fallen cast on `target`: deals this level's own
## base_damage plus bonus_per_column for every column between Solara
## and `target` at the moment it was clicked (mitigated by the target's
## own armor via _deal_fixed_damage_to_enemy(), same helper Abyssal Spasm/
## Drowned Surge/The Sunken One use) - since `target` was only ever a valid click
## within this level's own `range` in the first place (see
## _start_hope_of_the_fallen_targeting()), the farthest it can ever reach is
## exactly the table's own "Max Damage" column, reached at max range.
## Then stuns it (target["stun_turns_left"], same shared field Barbed Lunge's/
## Drowned Surge's own stun use) for this level's own stun_turns, only if the
## hit left it alive. _play_hope_of_the_fallen_flight() plays the actual
## flight alongside this already-resolved damage, same "cosmetic only,
## never gates the outcome" split Moonfall Lance's own impact uses.
func _resolve_hope_of_the_fallen_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var target_node: TextureRect = target.get("node")
	var distance: int = _distance(target["pos_index"], _hero_pos_index)
	var damage: float = float(level_data.get("base_damage", 0)) + float(level_data.get("bonus_per_column", 0)) * distance
	_deal_fixed_damage_to_enemy(target, damage)
	if target.get("current_hp", 0) > 0:
		target["stun_turns_left"] = int(level_data.get("stun_turns", 0))
	_play_hope_of_the_fallen_flight(hero_image, target_node, distance)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["hope_of_the_fallen"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("hope_of_the_fallen", _skill_cooldowns["hope_of_the_fallen"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves a Moonfall Lance cast on `target`: deals this level's own flat
## `damage` (mitigated by the target's own armor via
## _deal_fixed_damage_to_enemy(), same helper Hope of the Fallen uses above),
## then stuns it (target["stun_turns_left"], same shared field Sacred
## Arrow's/Barbed Lunge's/Drowned Surge's own stun use) for this level's own
## stun_turns, only if the hit left it alive.
func _resolve_moonfall_lance_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var target_node: TextureRect = target.get("node")
	var damage: float = float(level_data.get("damage", 0))
	_deal_fixed_damage_to_enemy(target, damage)
	if target.get("current_hp", 0) > 0:
		target["stun_turns_left"] = int(level_data.get("stun_turns", 0))
	_play_moonfall_lance_impact(target_node)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["moonfall_lance"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("moonfall_lance", _skill_cooldowns["moonfall_lance"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves an Thornbind cast once the player has clicked a target
## (see _start_thornbind_targeting()/_on_enemy_clicked()): roots and
## silences `target` for this level's turn counts and arms its
## damage-over-time (ticked once per turn, at the start of that enemy's
## own turn, by _tick_enemy_turn_start_effects()). Then spends mana, starts Thornbind's own
## cooldown, and ends the turn - the same bookkeeping _on_skill_pressed
## does for every other skill, just deferred to here since Thornbind's
## target isn't known until after that function already returned.
func _resolve_thornbind_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	_apply_root(target, level_data)
	if is_instance_valid(target.get("node")):
		_play_thornbind_effect(target["node"])
	_refresh_thornbind_vines()

	if _is_hero_hidden():
		_end_depthsveil()

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["thornbind"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("thornbind", _skill_cooldowns["thornbind"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves a Whisper of the Veil cast on an enemy: deals `level_data.damage`
## straight damage (still mitigated by the target's own armor, via
## _deal_fixed_damage_to_enemy() - same helper Abyssal Spasm and the bear
## use), then spends mana, starts Whisper of the Veil's cooldown, and ends the
## turn - the same bookkeeping _resolve_thornbind_cast() does for
## Thornbind, since Whisper of the Veil's target isn't known until after
## _on_skill_pressed() already returned.
func _resolve_whisper_of_the_veil_enemy_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	# Captured before the hit, which may kill (and free) the target.
	_play_whisper_of_the_veil_effect(hero_image, target.get("node"))
	_deal_fixed_damage_to_enemy(target, damage)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["whisper_of_the_veil"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("whisper_of_the_veil", _skill_cooldowns["whisper_of_the_veil"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves a Drowned Surge cast on `target`: deals `level_data.damage`
## (mitigated by the target's own armor, via _deal_fixed_damage_to_
## enemy() - same helper Abyssal Spasm/Whisper of the Veil use) and stuns it for
## `level_data.stun_turns` if it survives, exactly like Barbed Lunge's own
## stun. At max level (level_data.radius > 0), also splashes every
## OTHER living, targetable enemy within that radius of `target`'s own
## column for the same damage - centered on the target rather than the
## hero, unlike Abyssal Spasm's radius (which is centered on Kaelen Varr
## himself) - so the splash never re-hits `target` a second time.
func _resolve_drowned_surge_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	# Played before the hit, which may kill (and free) the target.
	_play_drowned_surge_splash(target.get("node"))
	_deal_fixed_damage_to_enemy(target, damage)
	if target.get("current_hp", 0) > 0:
		target["stun_turns_left"] = int(level_data.get("stun_turns", 1))

	var radius: int = int(level_data.get("radius", 0))
	if radius > 0:
		var target_pos: int = target["pos_index"]
		for enemy in _enemies:
			if is_same(enemy, target) or _is_target_hidden(enemy):
				continue
			if _distance(enemy["pos_index"], target_pos) <= radius:
				_play_drowned_surge_splash(enemy.get("node"))
				_deal_fixed_damage_to_enemy(enemy, damage)
		# Centered on the target's own column, same as the splash above -
		# a rival's own guard (The Last Empress's Imperial Guard) can be in
		# range independently of whether the boss itself currently is.
		_play_drowned_surge_splash_on_guards(_enemy_guards, target_pos, radius)
		_deal_aoe_damage_to_enemy_guards(target_pos, radius, damage)

	# No Depthsveil check here, unlike Thornbind's own resolve - that
	# only ever matters for Veyrik's own kit, and Drowned Surge belongs to
	# Kaelen Varr (same reasoning as Whisper of the Veil's enemy-cast, Morvael's own
	# skill, right above/below this).
	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["drowned_surge"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("drowned_surge", _skill_cooldowns["drowned_surge"])
	_refresh_skill_cooldown_labels()

	if TutorialManager.is_active and TutorialManager.current_stage == 1 \
	and (_tutorial_stage1_step == "cast_drowned_surge_on_range" or _tutorial_stage1_step == "recast_drowned_surge_on_range"):
		# A recast (see "melee_in_range"'s own check below) can land while
		# the hero isn't actually standing next to a melee creep yet - a
		# reinforcement's melee creep spawns at its own fixed column,
		# independent of wherever the hero happens to be by then. Only
		# jump straight to "attack" if one is already right there;
		# otherwise route through "approach_melee" same as the very
		# first cast always has.
		if _get_enemy_at(_hero_pos_index).is_empty():
			_advance_tutorial_stage1_step("approach_melee")
		else:
			_advance_tutorial_stage1_step("melee_in_range")

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves an Undertow cast on `target`: no damage, no
## immediate effect at all beyond setting the mark itself - see
## _pending_undertow_target's own comment above and _resolve_undertow_
## teleport() (called from _end_turn()) for what actually happens with
## it, on the hero's own next turn. Recasting (marking a different
## target before the first one ever triggers) simply overwrites the
## pending mark outright, same as Leeching Hunger/Beast of the Elderwild being
## recast - there's nothing to "give back" from the old one.
func _resolve_undertow_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	_pending_undertow_target = target
	_pending_undertow_stage_generation = _stage_generation

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["undertow"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("undertow", _skill_cooldowns["undertow"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Called once per _end_turn() call, right as the hero's new turn opens
## (see its own call site) - resolves whatever Undertow mark is
## pending, if any. Teleports the hero onto the marked enemy's CURRENT
## pos_index (it may well have moved since it was marked) and clears
## the mark either way; no-ops (a silent fizzle, no teleport) if the
## mark's target died in the meantime or the stage/hero fight moved on
## since it was placed (_pending_undertow_stage_generation mismatch,
## meaning `target` is a stale reference into a fight that's already
## over). Never spends the hero's turn - _end_turn() calls this before
## reopening the action buttons, not in response to one of them.
func _resolve_undertow_teleport() -> void:
	if _pending_undertow_target.is_empty():
		return

	var target: Dictionary = _pending_undertow_target
	var stage_generation: int = _pending_undertow_stage_generation
	_pending_undertow_target = {}
	_pending_undertow_stage_generation = -1

	if stage_generation != _stage_generation or target.get("current_hp", 0) <= 0:
		return

	var from_pos: Vector2 = hero_image.position
	_hero_pos_index = target["pos_index"]
	_update_hero_position()
	_show_message_over_hero("Undertow!")
	_play_undertow_dive(hero_image, from_pos)


## Purely cosmetic: Undertow's jump - `node` (already moved) sinks into a
## splash where it stood (`from_pos`) and surfaces out of a new one where
## it landed (UndertowFX). Nothing to draw if it didn't actually move.
func _play_undertow_dive(node: Variant, from_pos: Vector2) -> void:
	if not is_instance_valid(node) or not (node is TextureRect) or from_pos.is_equal_approx(node.position):
		return
	# Its feet are on the ground line (see _creature_top_y()).
	var ground_y: float = node.position.y + node.size.y
	UndertowFX.play(node, from_pos, node.position, ground_y, _fx_layer)


## Kaelen Varr's The Sunken One: the ghost ship surfaces behind him and
## fires a broadside the way he's facing (hero_image.flip_h), out to
## this level's `range` in columns. Every enemy standing anywhere in
## that span - his own column included - takes `level_data.damage`,
## each hit still mitigated by that enemy's armor via
## _deal_fixed_damage_to_enemy(). There's no target to pick.
##
## Returns false (and shows a message) if nobody is in the line of fire,
## so the cast isn't wasted. Otherwise it spends the mana and starts the
## cooldown right away, locks the turn while SunkenOneFX plays, and deals
## the damage when the first cannonball lands - then ends the turn. Who
## gets hit is snapshotted now, so a kill partway through the loop
## (removing the dead enemy from _enemies) can't skip anyone.
func _cast_the_sunken_one(level_data: Dictionary) -> bool:
	var dir: int = -1 if hero_image.flip_h else 1
	var span: Vector2i = _the_sunken_one_span(_hero_pos_index, dir, level_data)
	var hit_targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		var pos: int = enemy["pos_index"]
		if pos >= span.x and pos <= span.y:
			hit_targets.append(enemy)
	if hit_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	var damage: float = float(level_data.get("damage", 0))
	spend_mana(float(level_data.get("mana_cost", 0)))
	_skill_cooldowns["the_sunken_one"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("the_sunken_one", _skill_cooldowns["the_sunken_one"])
	_refresh_skill_cooldown_labels()
	# Nothing else happens this turn while the ship is up.
	_has_acted_this_turn = true
	_update_action_buttons()

	var landings: Array[Vector2] = []
	for enemy in hit_targets:
		var node: Control = enemy["node"]
		if is_instance_valid(node):
			landings.append(node.global_position + node.size * 0.5)
	_pad_the_sunken_one_landings(landings, span)

	var generation_before: int = _stage_generation
	var fx: SunkenOneFX = SunkenOneFX.play(self, _fx_layer, hero_image.global_position + hero_image.size * 0.5,
			_the_sunken_one_ground_y(), dir, landings, func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		for enemy in hit_targets:
			if _enemies.any(func(e: Dictionary) -> bool: return is_same(e, enemy)):
				_deal_fixed_damage_to_enemy(enemy, damage)
		# A rival's own guard (The Last Empress's Imperial Guard) in the line
		# of fire is caught in it too.
		_deal_line_aoe_damage_to_enemy_guards(span.x, span.y, damage)
		_shake_screen()
		if TutorialManager.is_active and TutorialManager.current_stage == 3 \
		and (_tutorial_stage3_step == "cast_ultimate" or _tutorial_stage3_step == "cast_ultimate_ready"):
			_advance_tutorial_stage3_step("mop_up")
		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	)
	# Behind every fighter, over the battle area.
	move_child(fx, mini(hero_image.get_index(), enemies_layer.get_index()))
	return true


## The columns (low, high) The Sunken One's broadside covers, cast from
## `from_pos` facing `dir`: the caster's own column out to this level's
## `range`, clamped to the board.
func _the_sunken_one_span(from_pos: int, dir: int, level_data: Dictionary) -> Vector2i:
	var reach: int = int(level_data.get("range", 4))
	var far: int = clampi(from_pos + dir * reach, 0, GRID_COLUMNS - 1)
	return Vector2i(mini(from_pos, far), maxi(from_pos, far))


## Where creatures stand - the ground line the ship rises out of.
func _the_sunken_one_ground_y() -> float:
	return _creature_y() + get_viewport_rect().size.y / 4.0


## The ship has one ball per cannon port: after the ones aimed at whoever
## is hit, the rest land spread across the span, so the whole range is
## visibly raked.
func _pad_the_sunken_one_landings(landings: Array[Vector2], span: Vector2i) -> void:
	var y: float = _the_sunken_one_ground_y() - get_viewport_rect().size.y / 8.0
	var i: int = 0
	while landings.size() < SunkenOneFX.PORTS.size():
		var col: int = span.x + (i * 2 + 1) * (span.y - span.x + 1) / (2 * SunkenOneFX.PORTS.size()) if span.y > span.x else span.x
		landings.append(Vector2(_index_to_x(clampi(col, span.x, span.y)) + _grid_unit() * randf_range(0.2, 0.8), y + randf_range(-20.0, 20.0)))
		i += 1


## Resolves a Chainfire cast on `target`: chains a line from
## Cinder's own column to `target`'s, so every enemy currently
## standing anywhere between the two (inclusive of both ends) takes
## `level_data.damage` - `target` itself takes the same amount, it's
## not a separate/bonus hit. The whole path is snapshotted into
## `hit_targets` before any damage is dealt, so a kill partway through
## can't skip anyone after it. Cinder then pulls himself onto
## `target`'s own pos_index (read after the damage above, but a dead
## enemy keeps its last "pos_index" around, so this still lands in the
## right spot even if the chain itself killed `target`) - UNLESS a
## rival's Frostbound Rupture wall sits somewhere in that path, in which case
## the pull itself stops one column short of it (the chain's damage
## above still reaches the full line regardless - only the hero's own
## physical landing spot is blocked).
func _resolve_chainfire_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	var start_col: int = mini(_hero_pos_index, target["pos_index"])
	var end_col: int = maxi(_hero_pos_index, target["pos_index"])

	var hit_targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		var pos: int = enemy["pos_index"]
		if pos >= start_col and pos <= end_col:
			hit_targets.append(enemy)

	# The chain's own damage still reaches every enemy across the full
	# line (a magical effect, not the hero physically walking it) but a
	# rival's Frostbound Rupture wall in that same path stops the hero's
	# own pull short of target's column - same "can't step into one"
	# rule every other hero movement enforces, just walked one column
	# at a time here instead of using _melee_move_target()/_ranged_
	# move_target() (this pull crosses a whole line at once, not a
	# fixed per-move distance).
	var chain_direction: int = _step_toward(_hero_pos_index, target["pos_index"])
	var landing_pos: int = _hero_pos_index
	while chain_direction != 0 and landing_pos != target["pos_index"]:
		var next_pos: int = landing_pos + chain_direction
		if _is_column_enemy_frostbound_rupture_blocked(next_pos):
			break
		landing_pos = next_pos

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["chainfire"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("chainfire", _skill_cooldowns["chainfire"])
	_refresh_skill_cooldown_labels()
	# Nothing else happens this turn while he swings across.
	_has_acted_this_turn = true
	_update_action_buttons()

	# Facing the way he swings (art faces right natively).
	if chain_direction != 0:
		hero_image.flip_h = chain_direction < 0
	var on_landed := func() -> void:
		_hero_pos_index = landing_pos
		_update_hero_position()
		if _battle_over or _stage_generation != generation_before:
			return
		for enemy in hit_targets:
			if not _enemies.any(func(e: Dictionary) -> bool: return is_same(e, enemy)):
				continue
			_deal_fixed_damage_to_enemy(enemy, damage)
			# The standard splash hit-flash (see _apply_splash_damage()).
			if is_instance_valid(enemy.get("node")):
				_flash_bounce_hit(enemy["node"])
		# Same line as above (captured before the pull moved the hero off
		# start_col) - a rival's own guard (The Last Empress's Imperial Guard)
		# standing anywhere along it can still be caught in it.
		_deal_line_aoe_damage_to_enemy_guards(start_col, end_col, damage, true)
		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	var landing := Vector2(_index_to_x(landing_pos), _creature_top_y(hero_image.size.y))
	_play_chainfire(hero_image, _hero_static, target.get("node"), landing, on_landed)


## Purely cosmetic (plus the swing itself): Chainfire (ChainfireFX). The
## chain flies from `unit`'s flamethrower (its hero data's "attack_origin",
## mirrored for its facing) to a hook point above `target_node`'s head, and
## `unit` swings across to `landing` (its position in its parent's space)
## laying a fire trail as it goes. `on_landed` fires as it touches down -
## or right away if a sprite is already gone, so the turn never stalls.
func _play_chainfire(unit: Variant, hero_static: Dictionary, target_node: Variant, landing: Vector2, on_landed: Callable) -> void:
	if not (unit is Control) or not (target_node is Control) or not is_instance_valid(unit) \
			or not is_instance_valid(target_node) or not is_instance_valid(_fx_layer):
		on_landed.call()
		return
	var hand: Vector2 = hero_static.get("attack_origin", Vector2(0.85, 0.45))
	if unit.flip_h:
		hand.x = 1.0 - hand.x
	var target_top: Vector2 = target_node.global_position + target_node.size * Vector2(0.5, 0.08)
	ChainfireFX.play(_fx_layer, unit, landing, target_top, hand, on_landed)


# ------------------------------------------------------------------
# Cinder's ultimate, Cinderbomb (see the field comment above _cinderbomb
# for the overall shape).
# ------------------------------------------------------------------

## Resolves a Cinderbomb cast on `target`: deals this level's own
## cast_damage to `target` and every other enemy within radius columns
## of `target`'s position at this moment, then plants the cinderbomb
## there - snapshotting that position now, so it stays fixed even if
## `target` (or anything else) moves later. Any cinderbomb already planted
## from a previous cast is torn down first, same "recast replaces
## outright" reasoning as _elderwild_companion()'s own _despawn_bear()
## call, since the ultimate's long cooldown makes an overlapping recast
## a rare, deliberate choice rather than something worth stacking.
func _resolve_cinderbomb_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var pos_index: int = target["pos_index"]
	var radius: int = int(level_data.get("radius", 0))

	var cast_damage: float = float(level_data.get("cast_damage", 0))
	var hit_targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], pos_index) <= radius:
			hit_targets.append(enemy)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["cinderbomb"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("cinderbomb", _skill_cooldowns["cinderbomb"])
	_refresh_skill_cooldown_labels()
	_show_message_over_hero("Cinderbomb!")
	# Nothing else happens this turn while the barrel is in the air.
	_has_acted_this_turn = true
	_update_action_buttons()

	# Everything lands when the barrel bursts: the blast, then the burning
	# ground planted at the target's position at cast time.
	var on_explode := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		for enemy in hit_targets:
			if not _enemies.any(func(e: Dictionary) -> bool: return is_same(e, enemy)):
				continue
			_deal_fixed_damage_to_enemy(enemy, cast_damage)
			# The standard splash hit-flash (see _apply_splash_damage()).
			if is_instance_valid(enemy.get("node")):
				_flash_bounce_hit(enemy["node"])
		# Planted at the target's own position at cast time - a rival's
		# own guard (The Last Empress's Imperial Guard) there (or nearby) takes
		# the same initial burst.
		_deal_aoe_damage_to_enemy_guards(pos_index, radius, cast_damage, true)
		_shake_screen()

		_despawn_cinderbomb()
		_cinderbomb = {
			"pos_index": pos_index,
			"radius": radius,
			"damage_per_turn": float(level_data.get("damage_per_turn", 0)),
			"turns_remaining": int(level_data.get("duration", 0)),
			"duration_pending_start": true,
			"node": _spawn_cinderbomb_marker(pos_index, radius),
		}
		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	_throw_cinderbomb(hero_image, _hero_static, target.get("node"), pos_index, radius, on_explode)


## Purely cosmetic: Cinderbomb's burning barrel (CinderbombFX), hurled from
## `caster`'s flamethrower (its hero data's "attack_origin", mirrored for
## its facing) onto `target_node`, bursting across `radius` columns of
## column `pos_index`. `on_explode` fires as it bursts - or right away if a
## sprite is already gone, so the turn never stalls.
func _throw_cinderbomb(caster: Variant, hero_static: Dictionary, target_node: Variant, pos_index: int, radius: int, on_explode: Callable) -> void:
	if not (caster is Control) or not is_instance_valid(caster) or not is_instance_valid(_fx_layer):
		on_explode.call()
		return
	var origin: Vector2 = hero_static.get("attack_origin", Vector2(0.85, 0.45))
	if caster.flip_h:
		origin.x = 1.0 - origin.x
	var from: Vector2 = caster.global_position + caster.size * origin
	var to := Vector2(_index_to_x(pos_index) + _grid_unit() * 0.5, _the_sunken_one_ground_y() - get_viewport_rect().size.y / 10.0)
	if target_node is Control and is_instance_valid(target_node):
		to.x = target_node.global_position.x + target_node.size.x * 0.5
	CinderbombFX.throw(_fx_layer, from, to, _grid_unit() * (float(radius) + 0.5), on_explode)


## Purely cosmetic: the burning ground Cinderbomb leaves (CinderbombFX.
## burn_ground()) - low flames across `radius` columns either side of
## column `pos_index`, on the ground line, in front of the fighters'
## feet. Returns the node for the cinderbomb's "node" - ended via
## _dismiss_cinderbomb_marker().
func _spawn_cinderbomb_marker(pos_index: int, radius: int) -> Node2D:
	var center := Vector2(_index_to_x(pos_index) + _grid_unit() * 0.5, _the_sunken_one_ground_y())
	var ground: Node2D = CinderbombFX.burn_ground(self, center, _grid_unit() * (float(radius) + 0.5), get_viewport_rect().size.y / 4.0)
	# Same reasoning as _elderwild_companion()'s own move_child() call -
	# render at the hero/enemy layer, not on top of every UI panel.
	move_child(ground, enemies_layer.get_index() + 1)
	return ground


## Removes a planted cinderbomb's burning ground (see
## _spawn_cinderbomb_marker()) - the flames gutter out rather than just
## vanishing. Safe on a missing/already-freed node.
func _dismiss_cinderbomb_marker(marker: Variant) -> void:
	CinderbombFX.end_ground(marker)


## Ticks the planted Cinderbomb's duration down once per End Turn, same
## timing (and same "the casting turn doesn't count" skip) as every
## other duration-based buff - dealing this level's own damage_per_turn
## to every living, targetable enemy within radius columns of the
## FIXED position it was planted at (not re-checked against any
## enemy's current position - see the field comment above _cinderbomb) on
## every tick that actually counts against the duration. A no-op while
## no cinderbomb is planted.
func _tick_cinderbomb() -> void:
	if _cinderbomb.is_empty():
		return

	if _cinderbomb.get("duration_pending_start", false):
		_cinderbomb["duration_pending_start"] = false
		return

	var pos_index: int = int(_cinderbomb["pos_index"])
	var radius: int = int(_cinderbomb["radius"])
	var damage_per_turn: float = float(_cinderbomb["damage_per_turn"])
	for enemy in _enemies.duplicate():
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], pos_index) <= radius:
			_deal_fixed_damage_to_enemy(enemy, damage_per_turn)
			if _battle_over:
				return
			# The standard splash hit-flash (see _apply_splash_damage()).
			if is_instance_valid(enemy.get("node")):
				_flash_bounce_hit(enemy["node"])
	# Same FIXED planted position as the check above - a rival's own
	# guard can be in range independently of whether the boss itself
	# currently is.
	_deal_aoe_damage_to_enemy_guards(pos_index, radius, damage_per_turn, true)

	_cinderbomb["turns_remaining"] = int(_cinderbomb["turns_remaining"]) - 1
	if int(_cinderbomb["turns_remaining"]) <= 0:
		_despawn_cinderbomb()


## Removes whatever cinderbomb is currently planted, if any - used both
## when a fresh cast replaces one still active (see
## _resolve_cinderbomb_cast()) and when its duration runs out
## (_tick_cinderbomb()). Scene teardown at battle end frees the node
## implicitly either way, same reasoning as _despawn_bear()'s own
## comment.
func _despawn_cinderbomb() -> void:
	if _cinderbomb.is_empty():
		return
	_dismiss_cinderbomb_marker(_cinderbomb.get("node"))
	_cinderbomb = {}


## Purely cosmetic: drops a thin beam of moonlight (MOONFALL_LANCE_COLOR)
## from above straight down onto `target_node`'s own position, growing
## into place top-down rather than flying in from the side - the damage
## has already been resolved; this only draws it. Once the beam
## reaches the target it flashes the struck sprite the same quick
## brightness pulse an enemy's own cast already gets
## (_pulse_caster_sprite()), so the hit itself reads as a clear impact,
## then fades the beam out and frees it. No-op if the target's node is
## already gone (e.g. the hit killed it) by the time this runs.
func _play_moonfall_lance_impact(target_node: TextureRect) -> void:
	if not is_instance_valid(target_node):
		return

	var beam := ColorRect.new()
	beam.color = MOONFALL_LANCE_COLOR
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	beam.size = Vector2(MOONFALL_LANCE_WIDTH, 0.0)
	beam.position = Vector2(
		target_node.position.x + target_node.size.x / 2.0 - MOONFALL_LANCE_WIDTH / 2.0,
		target_node.position.y - MOONFALL_LANCE_FALL_HEIGHT
	)
	add_child(beam)
	# Same reasoning as _elderwild_companion()'s own move_child() call -
	# render at the hero/enemy layer, not on top of every UI panel.
	move_child(beam, enemies_layer.get_index() + 1)

	var tween := create_tween()
	tween.tween_property(beam, "size:y", MOONFALL_LANCE_FALL_HEIGHT, MOONFALL_LANCE_FALL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		if is_instance_valid(target_node):
			_pulse_caster_sprite(target_node, false)
	)
	tween.tween_property(beam, "modulate:a", 0.0, 0.18)
	tween.tween_callback(beam.queue_free)


## Purely cosmetic: Solara's Hope of the Fallen - an arrow drawn from plain
## shapes (a glowing HOPE_OF_THE_FALLEN_COLOR shaft, a pointed head, two
## fletching feathers at the tail - see _build_hope_of_the_fallen()) that
## flies horizontally from `caster_node`'s own position to
## `target_node`'s, pointing whichever way it travels (the player's own
## hero_image shooting an enemy, or a rival's own node shooting the
## player's hero_image or bear), trailing blue sparks. `distance`
## (already known to the caller - see _resolve_hope_of_the_fallen_cast()/
## _cast_enemy_hope_of_the_fallen()) stretches the flight time for a longer
## shot, same value the damage itself already scales off. On arrival it
## bursts in blue sparks, pulses the struck sprite, and fades. No-op if
## either node is already gone by the time this runs.
func _play_hope_of_the_fallen_flight(caster_node: Control, target_node: TextureRect, distance: int, palette: Dictionary = {}) -> void:
	if not is_instance_valid(caster_node) or not is_instance_valid(target_node):
		return
	var trail_color: Color = palette.get("shaft", HOPE_OF_THE_FALLEN_COLOR)

	# Where the arrow leaves and where it lands (global), captured up front so
	# a target killed by the hit still takes its arrow. It leaves from the
	# middle of the caster, at the target's height - or, for Solara's own cast
	# (no recolor), from the tip of her bow.
	var end := target_node.global_position + target_node.size * 0.5
	var start := Vector2(caster_node.global_position.x + caster_node.size.x / 2.0, end.y)

	# Solara's own cast is charged first: a faint golden glow flows from her
	# body to her bow, and the arrow is loosed from the bow once it is full.
	var hold := 0.0
	if palette.is_empty() and caster_node is TextureRect:
		hold = HOPE_OF_THE_FALLEN_CHARGE_TIME
		var shooter: TextureRect = caster_node
		var tip := SOLARA_BOW_TIP
		var body := Vector2(0.5, 0.42)
		if shooter.flip_h:
			tip.x = 1.0 - tip.x
			body.x = 1.0 - body.x
		start = shooter.global_position + shooter.size * tip
		HopeChargeFX.play(_fx_layer, shooter.global_position + shooter.size * body, start, hold)

	var launch := func() -> void:
		if _battle_over:
			return
		_launch_hope_of_the_fallen_arrow(start, end, distance, palette, trail_color, target_node)
	if hold > 0.0:
		get_tree().create_timer(hold).timeout.connect(launch)
	else:
		launch.call()


## The arrow of Hope of the Fallen, loosed (see _play_hope_of_the_fallen_flight()):
## it flies from `start` (global) straight at the target `end`, wrapped in a soft
## glow of its own that pulses as it goes, trailing sparks, and bursts on
## the target.
func _launch_hope_of_the_fallen_arrow(start: Vector2, end: Vector2, distance: int, palette: Dictionary, trail_color: Color, target_node: TextureRect) -> void:
	var arrow: Node2D = _build_hope_of_the_fallen(palette)
	# Drawn pointing right - turned to point along its flight.
	var aim: Vector2 = (end - start).normalized()
	arrow.rotation = aim.angle()
	add_child(arrow)
	arrow.global_position = start
	# Same reasoning as _elderwild_companion()'s own move_child() call -
	# render at the hero/enemy layer, not on top of every UI panel.
	move_child(arrow, enemies_layer.get_index() + 1)

	# The arrow's own glow: a soft additive halo riding it, brighter at the
	# head, and pulsing.
	var halo_tex := GradientTexture2D.new()
	var halo_ramp := Gradient.new()
	halo_ramp.offsets = PackedFloat32Array([0.0, 0.25, 0.6, 1.0])
	halo_ramp.colors = PackedColorArray([Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.15), Color(1, 1, 1, 0.0)])
	halo_tex.gradient = halo_ramp
	halo_tex.fill = GradientTexture2D.FILL_RADIAL
	halo_tex.fill_from = Vector2(0.5, 0.5)
	halo_tex.fill_to = Vector2(1.0, 0.5)
	halo_tex.width = 96
	halo_tex.height = 96
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var halo_color := Color(trail_color.r, trail_color.g, trail_color.b, 1.0).lightened(0.15)
	for layer in [[HOPE_OF_THE_FALLEN_LENGTH * 2.6, 0.38, 0.0], [HOPE_OF_THE_FALLEN_LENGTH * 1.1, 0.7, HOPE_OF_THE_FALLEN_LENGTH * 0.28]]:
		var halo := TextureRect.new()
		halo.texture = halo_tex
		halo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		halo.size = Vector2(layer[0], layer[0] * 0.55)
		halo.position = Vector2(float(layer[2]) - halo.size.x * 0.5, -halo.size.y * 0.5)
		halo.material = additive
		halo.self_modulate = Color(halo_color, float(layer[1]))
		arrow.add_child(halo)
		var pulse := halo.create_tween().set_loops()
		pulse.tween_property(halo, "modulate:a", 0.6, 0.12)
		pulse.tween_property(halo, "modulate:a", 1.0, 0.12)

	var trail := CPUParticles2D.new()
	trail.local_coords = false
	trail.position = Vector2(-HOPE_OF_THE_FALLEN_LENGTH / 2.0, 0.0)
	trail.amount = 48
	trail.lifetime = 0.34
	trail.spread = 25.0
	trail.direction = Vector2(-1, 0)
	trail.gravity = Vector2.ZERO
	trail.initial_velocity_min = 10.0
	trail.initial_velocity_max = 40.0
	trail.scale_amount_min = 1.5
	trail.scale_amount_max = 3.8
	trail.color = trail_color
	arrow.add_child(trail)
	trail.emitting = true

	var flight_duration: float = HOPE_OF_THE_FALLEN_BASE_DURATION + HOPE_OF_THE_FALLEN_DURATION_PER_COLUMN * float(distance)
	# Lands with its head in the target's middle.
	var land: Vector2 = end - aim * HOPE_OF_THE_FALLEN_LENGTH * 0.3

	var tween := create_tween()
	tween.tween_property(arrow, "global_position", land, flight_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void:
		trail.emitting = false
		_play_orb_impact(end, trail_color, 0.8)
		if is_instance_valid(target_node):
			_pulse_caster_sprite(target_node, false)
	)
	tween.tween_property(arrow, "modulate:a", 0.0, 0.18)
	tween.tween_callback(arrow.queue_free)


## Purely cosmetic: Luring Gaze - her eyes ignite, the arena darkens round
## the edges, her glamour slips, and threads of light run from her eyes to
## every one of `target_nodes`, each locking rigid as its thread connects
## (see LuringGazeFX). The stun itself is shown per unit, for as long as it
## lasts, by _refresh_luring_gaze_trances(). `heavy` darkens the vignette
## more - for a rival's cast, when it's the player being gazed at.
func _play_luring_gaze(caster_node: Variant, target_nodes: Array, heavy: bool = false) -> void:
	LuringGazeFX.cast(self, caster_node, target_nodes, hero_image, heavy, func(node: Variant) -> void:
		if is_instance_valid(node) and node is TextureRect:
			_sprite_flash(node, 1.06, Color(1.5, 1.45, 1.7, 1.0))
	)


## Keeps Luring Gaze's hold (see LuringGazeFX.set_trance()) in sync with
## who's currently held by it - every enemy whose stun came from the gaze
## (the "luring_gaze_entranced" mark its cast sets), the player (the
## _player_luring_gaze_entranced flag a rival's cast sets), and his Elderwild
## Companion (the same mark, on _bear). The motes stream toward whoever
## cast it: the hero, for his own cast, or the rival boss for theirs. Called
## from _refresh_bars() (i.e. constantly), same approach as
## _refresh_thornbind_vines(). A mark only counts while the stun it rode
## in on is still running, and is cleared here once that stun is over -
## so a later stun from anything else (Drowned Surge, Winter's Grip...) never
## shows the hold.
func _refresh_luring_gaze_trances() -> void:
	var rival: Variant = _get_hero_fight_boss().get("node")
	for enemy in _enemies:
		if enemy.get("luring_gaze_entranced", false) and int(enemy.get("stun_turns_left", 0)) <= 0:
			enemy["luring_gaze_entranced"] = false
		LuringGazeFX.set_trance(enemy.get("node"), bool(enemy.get("luring_gaze_entranced", false)), hero_image)
	if _player_luring_gaze_entranced and _player_stun_turns_left <= 0:
		_player_luring_gaze_entranced = false
	LuringGazeFX.set_trance(hero_image, _player_luring_gaze_entranced, rival)
	if _is_bear_alive():
		if _bear.get("luring_gaze_entranced", false) and int(_bear.get("stun_turns_left", 0)) <= 0:
			_bear["luring_gaze_entranced"] = false
		LuringGazeFX.set_trance(_bear.get("node"), bool(_bear.get("luring_gaze_entranced", false)), rival)


## Purely cosmetic: Deathlight Lure's cast - the lure on `from_node`
## (Dreadlure) flares with blue light and a thread of it runs out to
## `to_node` (the marked target), which flashes cold blue as it lands (see
## DreadlureFX.lure_flash()). The lingering mark is _set_deathlight_lure()'s.
func _play_deathlight_lure(from_node: Variant, to_node: Variant) -> void:
	if not (from_node is Control) or not (to_node is Control):
		return
	DreadlureFX.lure_flash(_fx_layer, from_node, to_node, func(node: Variant) -> void:
		if is_instance_valid(node) and node is TextureRect:
			_sprite_flash(node, 1.05, Color(0.8, 1.2, 1.6, 1.0))
	)


## Keeps Deathlight Lure's lingering lure in sync with who's currently
## marked - every enemy and the player's own Elderwild Companion carrying a
## "deathlight_lure_bonus_pct" > 0, and the player while
## _player_deathlight_lure_bonus_pct > 0 (a rival's cast). The mark's
## own countdown (armor_reduction_turns_left) already clears those to 0
## when it ends, so the lure just follows them. Called from
## _refresh_bars() (i.e. constantly), same approach as
## _refresh_thornbind_vines().
func _refresh_deathlight_lure() -> void:
	for enemy in _enemies:
		_set_deathlight_lure(enemy.get("node"), float(enemy.get("deathlight_lure_bonus_pct", 0.0)) > 0.0)
	_set_deathlight_lure(hero_image, _player_deathlight_lure_bonus_pct > 0.0)
	if _is_bear_alive():
		_set_deathlight_lure(_bear.get("node"), float(_bear.get("deathlight_lure_bonus_pct", 0.0)) > 0.0)


## Purely cosmetic: hangs Deathlight Lure's mark on a marked `node` (or
## takes it off) - the lure bobbing over its head with rings of light, and a
## cold outline round the body (see DreadlureFX.set_mark()). Lives under a
## child Control, so it follows the sprite for free; only does anything when
## the state actually changes.
func _set_deathlight_lure(node: Variant, active: bool) -> void:
	DreadlureFX.set_mark(node, active)


## Purely cosmetic: Paralytic Venom - Dreadlure (`caster_node`) rears up
## and releases the toxins: a ring of pale cloud rolls out from its body to
## about `radius` columns (at least half a column for a radius-0 cast),
## throwing up threads of venom along its edge (see DreadlureFX.
## venom_cloud()). Each node in `hit_nodes` (every unit the venom hits) gets
## a hit-flash right as the cloud reaches it. The held state afterward is
## _refresh_venom_paralysis()'s.
func _play_paralytic_venom(caster_node: Variant, radius: int, hit_nodes: Array) -> void:
	if not is_instance_valid(caster_node) or not (caster_node is Control):
		return
	var feet: Vector2 = caster_node.position + Vector2(caster_node.size.x / 2.0, caster_node.size.y * 0.9)
	var reach: float = _grid_unit() * maxf(0.5, float(radius)) + caster_node.size.x * 0.3

	# Rearing up, then settling, from whatever base scale an enlarging buff
	# currently has it at.
	var base_scale: Vector2 = caster_node.get_meta("base_scale", Vector2.ONE)
	caster_node.pivot_offset = Vector2(caster_node.size.x / 2.0, caster_node.size.y)
	var rear: Tween = caster_node.create_tween()
	rear.tween_property(caster_node, "scale", base_scale * Vector2(0.97, 1.07), 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	rear.tween_property(caster_node, "scale", base_scale, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	rear.tween_callback(func() -> void:
		# Every other effect scales around the sprite's center.
		if is_instance_valid(caster_node):
			caster_node.pivot_offset = caster_node.size / 2.0
	)

	DreadlureFX.venom_cloud(_fx_layer, caster_node, reach, PARALYTIC_VENOM_WAVE_SECONDS, hit_nodes)

	for node in hit_nodes:
		if not is_instance_valid(node) or not (node is Control):
			continue
		var node_feet: Vector2 = node.position + Vector2(node.size.x / 2.0, node.size.y * 0.9)
		var reach_fraction: float = clampf(absf(node_feet.x - feet.x) / reach, 0.0, 1.0)
		var on_hit: Tween = create_tween()
		on_hit.tween_interval(PARALYTIC_VENOM_WAVE_SECONDS * sqrt(reach_fraction))
		on_hit.tween_callback(func() -> void:
			if is_instance_valid(node) and node is TextureRect:
				_flash_bounce_hit(node)
		)


## Keeps Paralytic Venom's held state (see DreadlureFX.set_paralysis()) on
## everyone it stunned - every enemy and the Elderwild Companion marked
## "venom_paralyzed", and the player (a rival's cast) - for as long as the
## stun that came with it lasts. Called from _refresh_bars() (i.e.
## constantly), same approach as _refresh_luring_gaze_trances(): a mark
## only counts while its stun is still running, and is cleared here once
## it's over.
func _refresh_venom_paralysis() -> void:
	for enemy in _enemies:
		if enemy.get("venom_paralyzed", false) and int(enemy.get("stun_turns_left", 0)) <= 0:
			enemy["venom_paralyzed"] = false
		DreadlureFX.set_paralysis(enemy.get("node"), bool(enemy.get("venom_paralyzed", false)))
	if _player_venom_paralyzed and _player_stun_turns_left <= 0:
		_player_venom_paralyzed = false
	DreadlureFX.set_paralysis(hero_image, _player_venom_paralyzed)
	if _is_bear_alive():
		if _bear.get("venom_paralyzed", false) and int(_bear.get("stun_turns_left", 0)) <= 0:
			_bear["venom_paralyzed"] = false
		DreadlureFX.set_paralysis(_bear.get("node"), bool(_bear.get("venom_paralyzed", false)))


## Keeps Might of the Deep's charge (see DreadlureFX.set_might_charge()) on
## whichever side has the passive: the player's hero, and - in a hero fight -
## the rival, if it's the one with it.
func _refresh_might_of_the_deep() -> void:
	var data: Dictionary = _get_might_of_the_deep_level_data()
	var charge: int = _might_of_the_deep_attack_count if not data.is_empty() else 0
	DreadlureFX.set_might_charge(hero_image, charge, not data.is_empty() and charge + 1 >= int(data.get("attacks_required", 1)))
	if _in_hero_fight:
		var rival: Variant = _get_hero_fight_boss().get("node")
		var rival_data: Dictionary = _get_enemy_might_of_the_deep_level_data()
		var rival_charge: int = _enemy_might_of_the_deep_attack_count if not rival_data.is_empty() else 0
		DreadlureFX.set_might_charge(rival, rival_charge, not rival_data.is_empty() and rival_charge + 1 >= int(rival_data.get("attacks_required", 1)))


## Keeps Shackles' chains (see ShacklesFX) on whoever is currently held by
## them - every enemy and the Elderwild Companion marked "shackled", and the
## player (a rival's cast) - for exactly as long as the root that came with
## the cast lasts. Called from _refresh_bars() (i.e. constantly), same
## approach as _refresh_mothers_grasp_roots(): the chains just follow
## current state instead of being toggled at every cast/tick/dispel site. A
## root from anything else (Thornbind, Rootveil) never raises them: the flag
## is only ever set by Shackles itself, and cleared here the moment its
## root has run out, so a later root of another kind can't resurrect them.
func _refresh_shackles() -> void:
	for enemy in _enemies:
		if int(enemy.get("root_turns_left", 0)) <= 0:
			enemy["shackled"] = false
		ShacklesFX.set_on(self, enemy.get("node"), bool(enemy.get("shackled", false)), _on_shackles_snapped.bind(enemy.get("node")))
	if _player_root_turns_left <= 0:
		_player_shackled = false
	ShacklesFX.set_on(self, hero_image, _player_shackled, _on_shackles_snapped.bind(hero_image))
	if _is_bear_alive():
		if int(_bear.get("root_turns_left", 0)) <= 0:
			_bear["shackled"] = false
		ShacklesFX.set_on(self, _bear.get("node"), bool(_bear.get("shackled", false)), _on_shackles_snapped.bind(_bear.get("node")))


## The chains cinching shut on `node`: its sprite pulses.
func _on_shackles_snapped(node: Variant) -> void:
	if is_instance_valid(node) and node is TextureRect:
		_pulse_caster_sprite(node, false)


## Purely cosmetic: Fallen Grace's arrow rain (see ArrowRainFX) - the
## caster looses a volley of arrows straight up from the tip of its bow,
## and they come back down on each node in `nodes` (every unit the cast
## hits), several on each, one target after another. Each struck sprite
## pulses as its first arrow lands. Landing spots are captured up front,
## so a unit killed by the hit still takes its arrows. `caster` is the
## TextureRect the arrows leave (the player's hero_image, or the rival's own
## node); the bow tip is Solara's (SOLARA_BOW_TIP).
func _play_arrow_volley(caster: Variant, nodes: Array) -> void:
	if caster == null or not is_instance_valid(caster) or not (caster is TextureRect):
		return
	var shooter: TextureRect = caster
	var tip := SOLARA_BOW_TIP
	if shooter.flip_h:
		tip.x = 1.0 - tip.x
	var from: Vector2 = shooter.global_position + shooter.size * tip

	var shots: Array = []
	for node in nodes:
		if not is_instance_valid(node) or not (node is TextureRect):
			continue
		var target: TextureRect = node
		shots.append({
			"land": target.global_position + target.size * Vector2(0.5, 0.5),
			"on_hit": func() -> void:
				if is_instance_valid(target):
					_pulse_caster_sprite(target, false),
		})
	if shots.is_empty():
		return
	ArrowRainFX.play(_fx_layer, from, shots, -1.0 if shooter.flip_h else 1.0)




## Builds Hope of the Fallen's arrow out of plain Polygon2D shapes (or, with a
## `palette` of "shaft"/"head"/"fletch" colors, the same arrow recolored
## - Hunter's Bow's split shot), pointing
## right (+x) and centered on its own origin: a thin shaft with a soft
## glow around it, a pointed head at the front, and two swept-back
## fletching feathers at the tail. The caller mirrors it (scale.x = -1)
## for a shot flying left.
func _build_hope_of_the_fallen(palette: Dictionary = {}) -> Node2D:
	var shaft_color: Color = palette.get("shaft", HOPE_OF_THE_FALLEN_COLOR)
	var head_color: Color = palette.get("head", HOPE_OF_THE_FALLEN_HEAD_COLOR)
	var fletch_color: Color = palette.get("fletch", HOPE_OF_THE_FALLEN_FLETCH_COLOR)
	var arrow := Node2D.new()
	var half_len: float = HOPE_OF_THE_FALLEN_LENGTH / 2.0
	var shaft_half: float = HOPE_OF_THE_FALLEN_SHAFT_WIDTH / 2.0
	var head_len: float = 14.0
	var head_half: float = 7.0

	# Soft glow behind the whole arrow.
	var glow := Polygon2D.new()
	glow.color = Color(shaft_color.r, shaft_color.g, shaft_color.b, 0.3)
	glow.polygon = PackedVector2Array([
		Vector2(-half_len, -shaft_half - 4.0), Vector2(half_len - head_len, -shaft_half - 4.0),
		Vector2(half_len + 3.0, 0.0),
		Vector2(half_len - head_len, shaft_half + 4.0), Vector2(-half_len, shaft_half + 4.0),
	])
	arrow.add_child(glow)

	var shaft := Polygon2D.new()
	shaft.color = shaft_color
	shaft.polygon = PackedVector2Array([
		Vector2(-half_len, -shaft_half), Vector2(half_len - head_len, -shaft_half),
		Vector2(half_len - head_len, shaft_half), Vector2(-half_len, shaft_half),
	])
	arrow.add_child(shaft)

	var head := Polygon2D.new()
	head.color = head_color
	head.polygon = PackedVector2Array([
		Vector2(half_len - head_len - 2.0, -head_half), Vector2(half_len, 0.0),
		Vector2(half_len - head_len - 2.0, head_half), Vector2(half_len - head_len + 2.0, 0.0),
	])
	arrow.add_child(head)

	# Two feathers at the tail, swept back from the shaft.
	for side in [-1.0, 1.0]:
		var fletch := Polygon2D.new()
		fletch.color = fletch_color
		fletch.polygon = PackedVector2Array([
			Vector2(-half_len + 14.0, side * shaft_half),
			Vector2(-half_len + 2.0, side * (shaft_half + 7.0)),
			Vector2(-half_len - 3.0, side * (shaft_half + 7.0)),
			Vector2(-half_len + 3.0, side * shaft_half),
		])
		arrow.add_child(fletch)

	return arrow


## Resolves a Mark of Stillness cast on `target`: no immediate damage, just
## arms this level's own damage/duration onto `target`'s own
## Dictionary (dedicated mark_of_stillness_dot_damage/mark_of_stillness_dot_turns_left
## fields, separate from Thornbind's/Mark of the Mist's own DoT fields
## even though the mechanism is identical, since a different skill's
## effect shouldn't silently share or clobber another's state) - ticked
## once per turn, at the start of that enemy's own turn, by
## _tick_enemy_turn_start_effects(). Recasting on an already-frozen target simply
## overwrites its counters with this cast's fresh values, same as
## Thornbind's own recast rule.
func _resolve_mark_of_stillness_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	target["mark_of_stillness_dot_damage"] = float(level_data.get("damage", 0))
	target["mark_of_stillness_dot_turns_left"] = int(level_data.get("duration", 0))
	if is_instance_valid(target.get("node")):
		_flash_bounce_hit(target["node"], MARK_OF_STILLNESS_FLASH_COLOR)
	_refresh_mark_of_stillness_frost()

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["mark_of_stillness"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("mark_of_stillness", _skill_cooldowns["mark_of_stillness"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves a cast of The Hollow Cold on `target`: no immediate damage, just
## arms this level's own damage/duration onto EVERY enemy within
## this level's own radius of `target`'s column (`target` included -
## it's just the center of the AoE, not a special case) via dedicated
## the_hollow_cold_dot_damage/the_hollow_cold_dot_turns_left fields, kept
## separate from Mark of Stillness's/Thornbind's/Mark of the Mist's own DoT
## fields for the same reason Mark of Stillness's are separate from theirs.
## Ticked once per turn, at the start of that enemy's own turn, by
## _tick_enemy_turn_start_effects(). Recasting overwrites whatever DoT
## an already-affected enemy was carrying, same as every other DoT
## skill's own recast rule.
func _resolve_the_hollow_cold_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	var duration: int = int(level_data.get("duration", 0))
	var radius: int = int(level_data.get("radius", 1))
	var target_pos: int = target["pos_index"]

	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], target_pos) <= radius:
			enemy["the_hollow_cold_dot_damage"] = damage
			enemy["the_hollow_cold_dot_turns_left"] = duration
			if is_instance_valid(enemy.get("node")):
				_flash_bounce_hit(enemy["node"], MARK_OF_STILLNESS_FLASH_COLOR)
	# The rival's own guards (The Last Empress's Imperial Guard) in the same
	# area get the same DoT - ticked by _tick_enemy_guards_the_hollow_cold()
	# at the start of the enemy turn. The rival's own Elderwild Companion needs
	# nothing extra: it's a regular _enemies entry, already marked above.
	_mark_guards_the_hollow_cold(_enemy_guards, target_pos, radius, damage, duration)

	_play_the_hollow_cold_swirl(target.get("node"), radius)
	_open_hollow_cold_tear(target.get("node"), target_pos, radius, duration, false)
	_refresh_mark_of_stillness_frost()

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["the_hollow_cold"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("the_hollow_cold", _skill_cooldowns["the_hollow_cold"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Resolves a Touch of the First Cold cast on `target`: one hit for the
## hero's own rolled Attack damage (_roll_hero_damage(), the same roll
## a plain Attack uses) plus this level's own flat bonus_damage on top,
## mitigated by the target's own armor via _deal_fixed_damage_to_enemy()
## - same helper Abyssal Spasm/Drowned Surge/The Sunken One use. This is SKILL damage,
## not the plain Attack action itself, so - same as every other skill
## here - it never triggers Leeching Hunger's steal, Wildbond's
## lifesteal, or Mark of the Mist's stacking; those are all scoped
## specifically to _apply_hero_attack().
##
## The hit lands when The Reaching Void's talons strike (see
## _play_the_reaching_void()): mana and cooldown are spent right away,
## the turn stays locked while the limb reaches, and the damage lands
## (and the turn ends) at the touch - same flow as _cast_the_sunken_one().
func _resolve_touch_of_the_first_cold_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = _roll_hero_damage() + float(level_data.get("bonus_damage", 0))

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["touch_of_the_first_cold"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("touch_of_the_first_cold", _skill_cooldowns["touch_of_the_first_cold"])
	_refresh_skill_cooldown_labels()
	# Nothing else happens this turn while the void reaches.
	_has_acted_this_turn = true
	_update_action_buttons()

	_play_the_reaching_void(hero_image, target.get("node"), func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		if _enemies.any(func(e: Dictionary) -> bool: return is_same(e, target)):
			_deal_fixed_damage_to_enemy(target, damage)
		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	)


## Resolves a Three Cheers cast on `target`: fires this level's own
## `shots` count of separately-rolled hits at it (each
## _roll_hero_damage() * damage_pct, same "own roll per shot" idiom
## Sweep/Abyssal Spasm use for "one roll shared across many
## targets" just inverted here into "many rolls at one target"), each
## shot ALSO stacking armor_reduction_per_shot onto `target`'s own
## armor_reduction - a per-instance runtime field folded into
## _deal_fixed_damage_to_enemy()'s own armor calc, never touching
## target["static"]'s shared template armor - so a later shot in the
## SAME volley already lands harder than the first, having shredded
## some of the target's armor away. Stops early if `target` dies
## partway through. The whole stack's own duration (this level's own
## `duration`, in the target's own upcoming turns) is only set once,
## after the last shot connects - see _tick_enemy_turn_start_effects()'s
## own comment for why the casting round is never counted against it
## for free, with no separate "pending start" flag needed here.
func _resolve_three_cheers_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var shots: int = int(level_data.get("shots", 3))
	var damage_pct: float = float(level_data.get("damage_pct", 0))
	var armor_reduction_per_shot: float = float(level_data.get("armor_reduction_per_shot", 0))
	var target_pos_index: int = target["pos_index"]

	for i in range(shots):
		if target.get("current_hp", 0) <= 0:
			break
		var shot_damage: float = _roll_hero_damage() * damage_pct
		_deal_fixed_damage_to_enemy(target, shot_damage)
		_play_three_cheers_shot_effect(target_pos_index, i * 0.11, hero_image)
		if target.get("current_hp", 0) <= 0:
			break
		target["armor_reduction"] = float(target.get("armor_reduction", 0.0)) + armor_reduction_per_shot

	if target.get("current_hp", 0) > 0:
		target["armor_reduction_turns_left"] = int(level_data.get("duration", 0))

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["three_cheers"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("three_cheers", _skill_cooldowns["three_cheers"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Purely cosmetic: schedules one small impact-spark burst at
## `target_pos_index` after `delay` seconds - called once per shot from
## _resolve_three_cheers_cast() with a slight stagger (0, 0.15, 0.3s) so
## the 3 shots read as a rapid volley instead of one simultaneous flash.
## The damage above has already fully resolved by the time each of
## these plays; none of this ever gates it. Guards _battle_over at fire
## time since the delay can outlive the battle (a scene change from the
## last shot's own kill, say) - same reasoning every other delayed
## cleanup in this file already follows.
func _play_three_cheers_shot_effect(target_pos_index: int, delay: float, caster: TextureRect = null) -> void:
	get_tree().create_timer(maxf(delay, 0.01)).timeout.connect(_spawn_three_cheers_shot.bind(target_pos_index, caster))


## One shot of the volley: from `caster`'s muzzle (if it has one) a single
## big slug rips to the target's column (see ThreeCheersFX), with the
## spark burst of _spawn_three_cheers_impact() as it lands. Falls back to
## just the sparks with no caster.
func _spawn_three_cheers_shot(target_pos_index: int, caster: TextureRect) -> void:
	if _battle_over:
		return
	if caster != null and is_instance_valid(caster):
		var muzzle := DOUBLE_TROUBLE_MUZZLE
		if caster.flip_h:
			muzzle.x = 1.0 - muzzle.x
		var from: Vector2 = caster.global_position + caster.size * muzzle
		var to := Vector2(_index_to_x(target_pos_index) + _grid_unit() / 2.0, _creature_y() + get_viewport_rect().size.y / 8.0)
		ThreeCheersFX.play(_fx_layer, from, to)
		get_tree().create_timer(ThreeCheersFX.FLIGHT_TIME).timeout.connect(_spawn_three_cheers_impact.bind(target_pos_index))
		return
	_spawn_three_cheers_impact(target_pos_index)


func _spawn_three_cheers_impact(target_pos_index: int) -> void:
	if _battle_over:
		return

	var lifetime: float = 0.2

	var particles := CPUParticles2D.new()
	particles.position = Vector2(_index_to_x(target_pos_index) + _grid_unit() / 2.0, _creature_y() + get_viewport_rect().size.y / 8.0)
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 14
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 70.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 120.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(1.0, 0.85, 0.3, 1.0)
	add_child(particles)
	# Same reasoning as _elderwild_companion()'s own move_child() call -
	# render at the hero/enemy layer, not on top of every UI panel.
	move_child(particles, enemies_layer.get_index() + 1)
	particles.emitting = true

	get_tree().create_timer(lifetime + 0.2).timeout.connect(particles.queue_free)


# ------------------------------------------------------------------
# Raze's ultimate, Kiss the Wastes (see the field comment above
# _kiss_the_wastes_active for the overall channel shape).
# ------------------------------------------------------------------

## Raze's Kiss the Wastes target picking: same "normal attack
## range" gate (_hero_attack_column_range()) every other attack-range
## targeted skill uses - marking a target for the whole channel is the
## only click involved; the following shots never need another one.
## Returns false (and shows a message) if nothing is in range.
func _start_kiss_the_wastes_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "kiss_the_wastes"
	_pending_kiss_the_wastes_level_data = level_data
	_highlight_valid_targets()
	return true


## Resolves a Kiss the Wastes cast on `target`: marks it, fires the
## FIRST of this level's own `hits` shots immediately (right now, as
## part of this cast, same as any other instant skill), and arms
## _kiss_the_wastes_turns_left with however many are left (hits - 1) -
## _end_turn()'s own tail auto-fires the rest, one per hero turn, with
## every other action locked out for as long as any remain (see
## _kiss_the_wastes_active's own field comment for the full list of
## lock sites). Always "succeeds" once a target's been marked - there's
## nothing further for this cast itself to fail on.
func _resolve_kiss_the_wastes_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	_kiss_marked_enemy = target
	_kiss_the_wastes_level_data = level_data
	_kiss_the_wastes_active = true
	_kiss_the_wastes_turns_left = int(level_data.get("hits", 1)) - 1

	# The kiss first, then the barrage - its first impact waits for it.
	_play_kiss_blow(hero_image)
	_fire_kiss_the_wastes_shot(KissHeartsFX.BLOW_TIME)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["kiss_the_wastes"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("kiss_the_wastes", _skill_cooldowns["kiss_the_wastes"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Purely cosmetic: the kiss that opens Kiss the Wastes - a burst of
## glowing hearts blown from `caster`'s lips, drifting forward and up the way it faces (see
## KissHeartsFX; callers wait KissHeartsFX.BLOW_TIME before the barrage's
## first impact). Works from either side.
func _play_kiss_blow(caster: Variant) -> void:
	if caster == null or not is_instance_valid(caster) or not (caster is TextureRect):
		return
	var node: TextureRect = caster
	var mouth := RAZE_MOUTH
	if node.flip_h:
		mouth.x = 1.0 - mouth.x
	var from: Vector2 = node.global_position + node.size * mouth
	KissHeartsFX.play(_fx_layer, from, -1 if node.flip_h else 1, node.size.y)


## Fires one Kiss the Wastes shot: the impact column is always
## `_kiss_marked_enemy`'s own "pos_index" - while it's alive that
## tracks it turn to turn (a live Dictionary reference into _enemies),
## and once it's dead _kill_enemy() never mutates that field further,
## so it keeps reading as wherever it died - "the last column that the
## enemy occupied" falls out for free. The marked enemy (or, once it's
## dead, whoever's weakest on that column now) takes main_damage;
## EVERY other enemy within 1 column of the impact - the column itself
## included, since creeps stack in one column - takes splash_damage. All of
## them, main and splash alike, are set burning (refreshed by every shot).
## Always plays the lava-pool impact visual at that column, even if
## nothing was actually standing there to hit.
func _fire_kiss_the_wastes_shot(impact_delay: float = 0.0) -> void:
	var level_data: Dictionary = _kiss_the_wastes_level_data
	var impact_pos: int = int(_kiss_marked_enemy.get("pos_index", _hero_pos_index))

	var main_damage: float = float(level_data.get("main_damage", 0))
	var splash_damage: float = float(level_data.get("splash_damage", 0))
	var burn_per_turn: float = float(level_data.get("burn_per_turn", 0))
	var burn_duration: int = int(level_data.get("burn_duration", 0))

	# Everyone in the blast, captured before any damage lands - a kill
	# changes _enemies.
	var main_target: Dictionary = {}
	if _enemies.any(func(e: Dictionary) -> bool: return is_same(e, _kiss_marked_enemy)) and not _is_target_hidden(_kiss_marked_enemy):
		main_target = _kiss_marked_enemy
	else:
		main_target = _get_enemy_at(impact_pos)
	var blast: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if is_same(enemy, main_target) or _distance(enemy["pos_index"], impact_pos) <= 1:
			blast.append(enemy)

	for enemy in blast:
		var damage: float = main_damage if is_same(enemy, main_target) else splash_damage
		_deal_fixed_damage_to_enemy(enemy, damage)
		if _battle_over:
			return
		if enemy.get("current_hp", 0) > 0 and burn_per_turn > 0.0:
			enemy["kiss_burn_dot_damage"] = burn_per_turn
			enemy["kiss_burn_dot_turns_left"] = burn_duration

	# A rival's own guard (The Last Empress's Imperial Guard) exactly on the
	# impact column takes main_damage, one column either side takes
	# splash_damage - same split as the regular-enemy checks above,
	# rather than the single flat radius _deal_aoe_damage_to_enemy_
	# guards() would give (which can't tell "the impact column
	# itself" apart from "one column over").
	if not _enemy_guards.is_empty():
		var boss: Dictionary = _get_hero_fight_boss()
		if not boss.is_empty():
			var boss_armor: float = _enemy_hero_effective_armor(boss)
			for guard in _enemy_guards.duplicate():
				var guard_dist: int = _distance(guard["pos_index"], impact_pos)
				if guard_dist == 0:
					_deal_damage_to_enemy_guard(guard, _apply_armor_reduction(main_damage, boss_armor))
				elif guard_dist == 1:
					_deal_damage_to_enemy_guard(guard, _apply_armor_reduction(splash_damage, boss_armor))

	_play_kiss_the_wastes_impact_effect(impact_pos, impact_delay, hero_image)


## Ends the Kiss the Wastes channel - called once its last shot has
## fired (see _end_turn()'s own tail). Clears every bit of state the
## lock/auto-fire logic reads, so a stale reference to a long-dead
## `_kiss_marked_enemy` can never leak into some later, unrelated
## check.
func _end_kiss_the_wastes() -> void:
	_kiss_the_wastes_active = false
	_kiss_the_wastes_turns_left = 0
	_kiss_marked_enemy = {}
	_kiss_the_wastes_level_data = {}
	_show_message_over_hero("Kiss the Wastes ends")


## Purely cosmetic: a brief burning/lava-pool flare at `pos_index` -
## visualizes each of Kiss the Wastes' own shots landing. The damage
## above has already fully resolved by the time this plays; it never
## gates on this. Same CPUParticles2D one-shot-burst recipe as Lil'
## Three Cheers' own impact spark, just wider, slower, and colored like
## fire/lava rather than a gunshot's spark.
func _play_kiss_the_wastes_impact_effect(pos_index: int, delay: float = 0.0, caster: Variant = null) -> void:
	if delay > 0.0:
		get_tree().create_timer(delay).timeout.connect(func() -> void:
			if not _battle_over:
				_play_kiss_the_wastes_impact_effect(pos_index, 0.0, caster))
		return

	var column_width: float = _grid_unit()
	var ground := Vector2(_index_to_x(pos_index) + column_width / 2.0, _creature_y() + get_viewport_rect().size.y / 4.0 - 6.0)
	# The shell leaves the caster's muzzle (or just drops in from above if
	# there's nothing to fire from).
	var muzzle: Vector2 = ground + Vector2(0.0, -300.0)
	if caster != null and is_instance_valid(caster) and caster is TextureRect:
		var node: TextureRect = caster
		var frac := DOUBLE_TROUBLE_MUZZLE
		if node.flip_h:
			frac.x = 1.0 - frac.x
		muzzle = node.global_position + node.size * frac
	NapalmFX.play(_fx_layer, muzzle, ground, column_width)


# ------------------------------------------------------------------
# The Last Empress's Imperial Guard (see the field comment above _guards for
# the overall shape).
# ------------------------------------------------------------------

## How far a guard walks each turn, in columns - the same single step a
## creep takes.
const IMPERIAL_GUARD_SPEED := 1

## Activates Imperial Guard: replaces any guards already up outright
## (_end_imperial_guard() first - recasting mid-duration just resets the
## set, nothing carries over), then raises this level's own `guards` count
## of drowned warriors around the enemy CLOSEST to the hero - from
## anywhere on the board, no range needed. One rises on the side of that
## enemy facing the hero, one on its far side (both clamped to the grid,
## so at the very edge one can end up sharing the enemy's own column), and
## any beyond those first two double up randomly on one of those same two
## columns. With no enemy left to rise around, they gather beside the hero
## instead. Every guard starts out facing the enemy it was raised around.
## Empress's Will's own bonuses (extra_guard, guardians_damage_bonus_pct,
## guard_duration_bonus) are folded straight in here, read fresh off
## _get_empress_will_level_data() at cast time - a no-op contribution while
## that skill isn't learned, same "empty means locked" convention every
## other auto-triggered skill's own level-data getter uses. Always
## "succeeds" - no target or range requirement, same as every other
## self-cast buff.
func _activate_imperial_guard(level_data: Dictionary) -> void:
	_end_imperial_guard()

	var empress_will_level_data: Dictionary = _get_empress_will_level_data()

	var anchor_pos: int
	var near_side: int
	var closest: Dictionary = _closest_enemy_to_hero()
	if closest.is_empty():
		anchor_pos = _hero_pos_index
		near_side = 1 if hero_image.flip_h else -1
	else:
		anchor_pos = int(closest["pos_index"])
		near_side = _step_toward(anchor_pos, _hero_pos_index)
		if near_side == 0:
			near_side = -1
	var near_pos: int = clampi(anchor_pos + near_side, 0, GRID_COLUMNS - 1)
	var far_pos: int = clampi(anchor_pos - near_side, 0, GRID_COLUMNS - 1)

	var guards_count: int = int(level_data.get("guards", 3)) + int(empress_will_level_data.get("extra_guard", 0))
	var guard_hp: float = _hero_max_hp() * float(level_data.get("hp_pct", 0.0))

	for i in range(guards_count):
		var pos: int
		if i == 0:
			pos = near_pos
		elif i == 1:
			pos = far_pos
		else:
			pos = near_pos if randf() < 0.5 else far_pos
		var facing: int = _step_toward(pos, anchor_pos)
		if facing == 0:
			facing = -near_side
		_guards.append(_spawn_guard(pos, facing, guard_hp))

	_guard_damage_pct = float(level_data.get("damage_pct", 0.0)) + float(empress_will_level_data.get("guardians_damage_bonus_pct", 0.0))
	_guard_redirect_chance = float(level_data.get("hit_chance_pct", 0.0))
	_guards_turns_remaining = int(level_data.get("duration", 0)) + int(empress_will_level_data.get("guard_duration_bonus", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking (and the guards only start acting) from the turn after (see
	# _guards_turn()/_tick_imperial_guard()), same as every other duration-
	# based buff. The enemies can still go for them this very turn.
	_guards_duration_pending_start = true

	_show_message_over_hero("Imperial Guard!")


## The living enemy closest to the hero, by columns (ties go to whichever
## comes first) - {} when none are left.
func _closest_enemy_to_hero() -> Dictionary:
	var closest: Dictionary = {}
	var closest_distance: int = GRID_COLUMNS + 1
	for enemy in _enemies:
		var d: int = _distance(enemy["pos_index"], _hero_pos_index)
		if d < closest_distance:
			closest_distance = d
			closest = enemy
	return closest


## Raises one guard on `pos_index`'s own column facing `facing` (+1 right,
## -1 left; its art faces right natively, so left is a flip): its sprite
## at the same height and size as a creep's, climbing up out of the floor
## as it fades in, with an "current / max" HP label over it (kept in sync
## by _refresh_guard_hp_labels()) and a CreatureAnimator for the same
## idle/attack/hit/move reactions the creeps have. Returns the guard's
## Dictionary: {pos_index, current_hp, max_hp, facing, node, hp_label,
## enemy}. `enemy_side` marks one raised by a rival Last Empress (kept in
## _enemy_guards instead of _guards - see _guard_group()).
func _spawn_guard(pos_index: int, facing: int, hp: float, enemy_side: bool = false) -> Dictionary:
	var texture: Texture2D = hero_image.texture
	if ResourceLoader.exists(IMPERIAL_GUARD_IMAGE_PATH):
		texture = load(IMPERIAL_GUARD_IMAGE_PATH)

	var tex_rect := TextureRect.new()
	tex_rect.texture = texture
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	tex_rect.size = _creature_size(texture)
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_rect.flip_h = facing < 0
	# A guard joining others already in its column stands a little apart,
	# so you can see how many there are.
	var group: Array = _enemy_guards if enemy_side else _guards
	var already_here: int = 0
	for other in group:
		if other["pos_index"] == pos_index:
			already_here += 1
	var rest := Vector2(_index_to_x(pos_index) + _guard_stack_offset(already_here), _creature_top_y(tex_rect.size.y))
	tex_rect.position = rest + Vector2(0.0, 36.0)
	tex_rect.modulate.a = 0.0
	add_child(tex_rect)
	# Same reasoning as _elderwild_companion()'s own move_child() call -
	# render at the hero/enemy layer, not on top of every UI panel.
	move_child(tex_rect, enemies_layer.get_index() + 1)
	CreatureAnimator.attach(tex_rect, "imperial_guard")

	var rise := tex_rect.create_tween()
	rise.tween_property(tex_rect, "position", rest, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rise.parallel().tween_property(tex_rect, "modulate:a", 1.0, 0.3)

	var hp_label := Label.new()
	hp_label.size = Vector2(ENEMY_HP_LABEL_WIDTH, ENEMY_HP_LABEL_HEIGHT)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_label.add_theme_color_override("font_color", ENEMY_HP_LABEL_COLOR)
	hp_label.add_theme_font_size_override("font_size", ENEMY_HP_LABEL_FONT_SIZE)
	hp_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	hp_label.add_theme_constant_override("outline_size", 3)
	add_child(hp_label)
	move_child(hp_label, tex_rect.get_index() + 1)

	var guard := {
		"pos_index": pos_index,
		"current_hp": hp,
		"max_hp": hp,
		"facing": facing,
		"node": tex_rect,
		"hp_label": hp_label,
		"enemy": enemy_side,
	}
	_refresh_guard_hp_label(guard)
	return guard


## The array `guard` belongs to: the rival's guards for one raised by a
## rival Last Empress, the player's own otherwise.
func _guard_group(guard: Dictionary) -> Array:
	return _enemy_guards if bool(guard.get("enemy", false)) else _guards


## Keeps every guard's HP label's text and position current. Run every
## frame from _process() (same reasoning as _refresh_bear_hp_label()): a
## guard's HP changes through many generic paths, and its node slides
## between columns. Guards sharing a column stack their labels upward, above
## any creep labels already stacked there (see
## _refresh_enemy_overhead_labels()), so none print over another - the
## player's guards and the rival's alike.
func _refresh_guard_hp_labels() -> void:
	var slots: Dictionary = {}
	for group in [_guards, _enemy_guards]:
		for guard in group:
			var col: int = guard["pos_index"]
			if not slots.has(col):
				var enemies_here: int = 0
				for enemy in _enemies:
					if enemy["pos_index"] == col:
						enemies_here += 1
				slots[col] = enemies_here
			_refresh_guard_hp_label(guard, int(slots[col]))
			slots[col] = int(slots[col]) + 1


func _refresh_guard_hp_label(guard: Dictionary, slot: int = 0) -> void:
	var label: Label = guard.get("hp_label")
	var node: Control = guard.get("node")
	if not is_instance_valid(label) or not is_instance_valid(node):
		return
	label.text = "%d / %d" % [roundi(maxf(0.0, float(guard.get("current_hp", 0)))), maxi(1, roundi(float(guard.get("max_hp", 1))))]
	label.position = Vector2(
		node.position.x + node.size.x / 2.0 - ENEMY_HP_LABEL_WIDTH / 2.0,
		node.position.y - ENEMY_HP_LABEL_GAP - ENEMY_HP_LABEL_HEIGHT - float(slot) * (ENEMY_HP_LABEL_HEIGHT + ENEMY_HP_LABEL_GAP))


## How far to the right the `slot`th guard standing in one column is set
## from the first.
func _guard_stack_offset(slot: int) -> float:
	return float(slot) * 26.0


## Where `guard`'s sprite belongs: its column, nudged right by its place
## among the guards sharing that column.
func _guard_rest_position(guard: Dictionary) -> Vector2:
	var slot: int = 0
	for other in _guard_group(guard):
		if is_same(other, guard):
			break
		if other["pos_index"] == guard["pos_index"]:
			slot += 1
	var node: Control = guard["node"]
	return Vector2(_index_to_x(guard["pos_index"]) + _guard_stack_offset(slot), _creature_top_y(node.size.y))


## Re-seats every guard, on both sides, on its column after any of them
## moved or died.
func _relayout_guards() -> void:
	for group in [_guards, _enemy_guards]:
		for guard in group:
			if is_instance_valid(guard.get("node")):
				guard["node"].position = _guard_rest_position(guard)


## Ticks Imperial Guard's duration down once per End Turn, same timing
## (and same "the casting turn doesn't count" skip) as every other
## duration-based buff, then ends the effect once it runs out. The guards'
## own actions happen separately, in _guards_turn(). A no-op once every
## guard has already died in combat (see _kill_guard()) even if the
## duration itself hasn't run out yet.
func _tick_imperial_guard() -> void:
	if _guards.is_empty():
		return

	if _guards_duration_pending_start:
		_guards_duration_pending_start = false
		return

	_guards_turns_remaining -= 1
	if _guards_turns_remaining <= 0:
		_end_imperial_guard()


## The guards act automatically once per turn, right alongside the enemies
## (see _end_turn(), where they go just before them): each one attacks an
## enemy sharing its column - melee range - or, failing that, a guard a
## rival Last Empress raised there; with neither, it closes in on the
## nearest of them at its own speed (columns per turn), turning to face
## the way it walks and stopping early if that walk would carry it onto an
## enemy's column anyway (see _melee_move_target()). They sit out the
## casting turn, and do nothing once every enemy is already dead.
func _guards_turn() -> void:
	if _guards.is_empty() or _enemies.is_empty() or _guards_duration_pending_start:
		return

	for guard in _guards.duplicate():
		if not is_instance_valid(guard.get("node")):
			continue
		var target: Dictionary = _get_enemy_at(guard["pos_index"])
		if not target.is_empty():
			_guard_attack(guard, target)
			if _battle_over:
				return
			continue
		var rival_guard: Dictionary = _enemy_guard_at(guard["pos_index"])
		if not rival_guard.is_empty():
			_guard_attack_enemy_guard(guard, rival_guard)
			continue

		var nearest_pos: int = -1
		var nearest_distance: int = GRID_COLUMNS + 1
		for enemy in _enemies:
			var d: int = _distance(enemy["pos_index"], guard["pos_index"])
			if d < nearest_distance:
				nearest_distance = d
				nearest_pos = enemy["pos_index"]
		for rival in _enemy_guards:
			var dg: int = _distance(rival["pos_index"], guard["pos_index"])
			if dg < nearest_distance:
				nearest_distance = dg
				nearest_pos = rival["pos_index"]
		if nearest_pos == -1:
			return
		var direction: int = _step_toward(guard["pos_index"], nearest_pos)
		if direction == 0:
			continue
		_move_guard(guard, _melee_move_target(guard["pos_index"], direction, IMPERIAL_GUARD_SPEED), direction)
	_relayout_guards()


## The rival's guard standing in `pos_index`'s own column, the one with the
## least HP left (ties go to whichever comes first) - {} when none is
## there.
func _enemy_guard_at(pos_index: int) -> Dictionary:
	var lowest: Dictionary = {}
	for guard in _enemy_guards:
		if guard["pos_index"] != pos_index:
			continue
		if lowest.is_empty() or float(guard.get("current_hp", 0)) < float(lowest.get("current_hp", 0)):
			lowest = guard
	return lowest


## One of the player's guards strikes a guard the rival raised, in its own
## column: the same freshly-rolled hero Attack scaled by _guard_damage_pct as
## any other guard blow, mitigated by the boss's own effective armor.
func _guard_attack_enemy_guard(guard: Dictionary, rival_guard: Dictionary) -> void:
	var animator := CreatureAnimator.of(guard["node"])
	if animator != null:
		animator.play_attack(float(guard.get("facing", 1)))
	var boss: Dictionary = _get_hero_fight_boss()
	var armor: float = _enemy_hero_effective_armor(boss) if not boss.is_empty() else 0.0
	_deal_damage_to_enemy_guard(rival_guard, _apply_armor_reduction(_roll_hero_damage() * _guard_damage_pct, armor))


## One guard strikes `target`, an enemy in its own column: a freshly-rolled
## hero Attack scaled by _guard_damage_pct (the same "own roll per hit"
## idiom Three Cheers's shots use), mitigated by the target's own armor via
## _deal_fixed_damage_to_enemy() - the guard's own blow, not the hero's, so
## Deathlight Lure's bonus never applies to it (same as the bear's).
func _guard_attack(guard: Dictionary, target: Dictionary) -> void:
	var animator := CreatureAnimator.of(guard["node"])
	if animator != null:
		animator.play_attack(float(guard.get("facing", 1)))
	_deal_fixed_damage_to_enemy(target, _roll_hero_damage() * _guard_damage_pct, false, false)


## Slides a guard to column `new_pos`, turning its art to face the way it
## walked (left or right) and sliding it over with a CreatureAnimator hop,
## the same as a creep's _move_enemy().
func _move_guard(guard: Dictionary, new_pos: int, direction: int) -> void:
	var node: TextureRect = guard["node"]
	guard["pos_index"] = new_pos
	guard["facing"] = direction
	node.flip_h = direction < 0
	var old_x: float = node.position.x
	node.position = _guard_rest_position(guard)
	var animator := CreatureAnimator.of(node)
	if animator != null and not is_equal_approx(old_x, node.position.x):
		animator.play_move(old_x - node.position.x)


## Puts every guard back on the hero's own column, facing right, at the
## start of a new stage/hero fight - no slide, they simply start the fresh
## encounter there (same as _reset_bear_to_hero_column()).
func _reset_guards_to_hero_column() -> void:
	for guard in _guards:
		guard["pos_index"] = _hero_pos_index
		guard["facing"] = 1
		var node: TextureRect = guard.get("node")
		if is_instance_valid(node):
			node.flip_h = false
	_relayout_guards()
	for guard in _guards:
		_refresh_guard_hp_label(guard)


## The guards standing in `pos_index`'s own column (melee reach).
func _guards_at(pos_index: int) -> Array:
	var found: Array = []
	for guard in _guards:
		if guard["pos_index"] == pos_index:
			found.append(guard)
	return found


## The nearest guard within `reach` columns of `pos_index` (ties go to the
## one with the least HP left) - {} when none is that close.
func _nearest_guard_within(pos_index: int, reach: int) -> Dictionary:
	var best: Dictionary = {}
	var best_distance: int = reach + 1
	for guard in _guards:
		var d: int = _distance(guard["pos_index"], pos_index)
		if d > reach:
			continue
		if d < best_distance or (d == best_distance and float(guard.get("current_hp", 0)) < float(best.get("current_hp", 0))):
			best_distance = d
			best = guard
	return best


## An enemy's attack landing on `guard`: `raw_damage` mitigated by the
## hero's own armor (a guard has no defense stat of its own), same as the
## redirected hits and AoE collateral always were.
func _enemy_attack_guard(guard: Dictionary, raw_damage: float) -> void:
	_deal_damage_to_guard(guard, _apply_armor_reduction(raw_damage, _hero_armor()))


## Imperial Guard's redirect: an enemy's basic attack aimed at the hero lands
## on a random living guard instead with _guard_redirect_chance. Returns the
## (armor-mitigated) damage the guard took, or -1.0 when the hit stays on the
## hero. Only basic attacks roll it - DoTs, skills and AoE keep their own
## rules (AoE already hits guards separately).
func _enemy_attack_misses_hero() -> bool:
	if _withering_miss_turns <= 0 or randf() >= _withering_miss_chance:
		return false
	_show_rising_message_over(hero_image, "Missed!", Color(0.8, 0.9, 1.0, 1.0))
	return true


func _try_redirect_hit_to_guard(raw_damage: float) -> float:
	if _guards.is_empty() or _guard_redirect_chance <= 0.0 or randf() >= _guard_redirect_chance:
		return -1.0
	var guard: Dictionary = _guards[randi() % _guards.size()]
	var mitigated: float = _apply_armor_reduction(raw_damage, _hero_armor())
	_deal_damage_to_guard(guard, mitigated)
	return mitigated

## Ends Imperial Guard, despawning every surviving guard - called both
## when its duration runs out (_tick_imperial_guard()) and defensively at
## the top of _activate_imperial_guard() so a recast mid-duration never
## leaks the old set's nodes. Only shows the "fades" message if there
## was actually something to end (so casting it fresh, with nothing yet
## up to replace, stays silent).
func _end_imperial_guard() -> void:
	var had_guards: bool = not _guards.is_empty()
	for guard in _guards:
		if is_instance_valid(guard.get("node")):
			guard["node"].queue_free()
		if is_instance_valid(guard.get("hp_label")):
			guard["hp_label"].queue_free()
	_guards.clear()
	_guard_damage_pct = 0.0
	_guard_redirect_chance = 0.0
	_guards_turns_remaining = 0
	_guards_duration_pending_start = false

	if had_guards:
		_show_message_over_hero("Imperial Guard fades")


## Applies `amount` of already-mitigated damage to `guard` - the
## guard-side equivalent of _deal_damage_to_bear(), just against the
## `_guards` array instead of the single `_bear` dict. Called when an
## enemy attacks a guard (_enemy_attack_guard()) and from every enemy AoE
## that sweeps over one. The guard flinches, unless a projectile is still
## flying toward it (see _deferred_hit_node).
func _deal_damage_to_guard(guard: Dictionary, amount: float) -> void:
	guard["current_hp"] = float(guard.get("current_hp", 0.0)) - amount
	var node: Variant = guard.get("node")
	if is_instance_valid(node):
		_show_damage_number(node, amount)
		var animator := CreatureAnimator.of(node)
		if animator != null and node != _deferred_hit_node:
			animator.play_hit()
	if guard["current_hp"] <= 0:
		_kill_guard(guard)


## Removes one guard that's died in combat, its body dissolving the way a
## creep's does. Doesn't end Imperial Guard outright even if this was the
## last one; _tick_imperial_guard()'s own early-empty check just makes
## every remaining tick a no-op until the duration itself finally runs out.
func _kill_guard(guard: Dictionary) -> void:
	if is_instance_valid(guard.get("node")):
		CreatureAnimator.spawn_death_ghost(guard["node"], _fx_layer)
		guard["node"].queue_free()
	if is_instance_valid(guard.get("hp_label")):
		guard["hp_label"].queue_free()
	_guards.erase(guard)
	_relayout_guards()


## Any enemy AoE skill that damages the hero over an area should ALSO
## independently hit every surviving guard within that same area -
## guards are real occupants of their own columns, not something
## folded into apply_damage()'s own redirect-chance roll (that roll
## only ever fires for a hit actually landing on the hero; an AoE's
## OTHER victims, guards included, are unconditional collateral, not
## a chance). Called alongside (never instead of) whatever apply_damage()
## call the AoE skill already makes for the hero himself - see each
## enemy skill cast function's own call site. `amount` is the RAW,
## pre-mitigation damage the AoE deals to the hero - each guard
## mitigates it separately via the hero's own armor, same as apply_
## damage()'s own redirect roll does, since a guard is a copy of
## him, not a separate combatant with its own defense stat. A no-op
## while no guards are up.
## `flash_hits` gives each one hit the same red hit-flash as Lunar
## Ricochet's bounce (_flash_bounce_hit()) - off by default, opted into by
## Abyssal Spasm.
func _deal_aoe_damage_to_guards(center_pos_index: int, radius: int, amount: float, flash_hits: bool = false) -> void:
	if _guards.is_empty() or amount <= 0.0:
		return

	var mitigated: float = _apply_armor_reduction(amount, _hero_armor())
	for guard in _guards.duplicate():
		if _distance(guard["pos_index"], center_pos_index) <= radius:
			_deal_damage_to_guard(guard, mitigated)
			if flash_hits and is_instance_valid(guard.get("node")):
				_flash_bounce_hit(guard["node"])


## The line-shaped equivalent of _deal_aoe_damage_to_guards() above -
## for The Sunken One's/Chainfire's own "every column between the caster
## and the target, inclusive of both ends" line, rather than a radius
## around one point. Same "amount is raw, each guard mitigates it
## separately via the hero's own armor" contract.
## `flash_hits` gives each one hit the standard splash hit-flash
## (_flash_bounce_hit()) - off by default, opted into by Chainfire.
func _deal_line_aoe_damage_to_guards(start_pos_index: int, end_pos_index: int, amount: float, flash_hits: bool = false) -> void:
	if _guards.is_empty() or amount <= 0.0:
		return

	var start_col: int = mini(start_pos_index, end_pos_index)
	var end_col: int = maxi(start_pos_index, end_pos_index)
	var mitigated: float = _apply_armor_reduction(amount, _hero_armor())
	for guard in _guards.duplicate():
		var pos: int = guard["pos_index"]
		if pos >= start_col and pos <= end_col:
			_deal_damage_to_guard(guard, mitigated)
			if flash_hits and is_instance_valid(guard.get("node")):
				_flash_bounce_hit(guard["node"])


## The directional-cone equivalent of the two AoE-shape helpers above -
## for a rival Double Trouble's own "every column strictly ahead of the
## caster, in whichever direction it's facing, up to range_columns"
## cone (same shape _cast_double_trouble()'s own "ahead" check uses for
## the player's copy), rather than a radius or a line between two
## points. Same "amount is raw, each guard mitigates it separately
## via the hero's own armor" contract.
func _deal_directional_aoe_damage_to_guards(origin_pos_index: int, direction: int, range_columns: int, amount: float) -> void:
	if _guards.is_empty() or amount <= 0.0:
		return

	var mitigated: float = _apply_armor_reduction(amount, _hero_armor())
	for guard in _guards.duplicate():
		var ahead: int = (guard["pos_index"] - origin_pos_index) * direction
		if ahead >= 0 and ahead <= range_columns:
			_deal_damage_to_guard(guard, mitigated)


## Resolves a Return to the Void cast on `target`: `level_data.damage` to
## `target` and every OTHER living, targetable enemy within
## `level_data.radius` columns of it (mirroring Abyssal Spasm's/Drowned Surge's
## own "one rolled amount, many separately-mitigated hits" pattern),
## then arms this level's own DoT (dot_damage/dot_duration) AND execute
## threshold (execute_pct, the "reserved %" of max HP - see
## _tick_enemy_turn_start_effects() for how that's actually enforced) on every
## one of them that survived the initial hit. `target` alone also gets
## stunned, mirroring Drowned Surge's own "only the primary target" rule for
## its stun.
##
## All of it lands when the world is erased (see _play_return_to_the_void()):
## mana and cooldown are spent right away, the turn stays locked while the
## sigil brands the target and the world holds its breath, and the hits
## land (and the turn ends) at the erasure - same flow as
## _cast_the_sunken_one(). Who's caught is snapshotted now.
func _resolve_return_to_the_void_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	var dot_damage: float = float(level_data.get("dot_damage", 0))
	var dot_duration: int = int(level_data.get("dot_duration", 0))
	var execute_pct: float = float(level_data.get("execute_pct", 0.0))
	var radius: int = int(level_data.get("radius", 1))
	var target_pos: int = target["pos_index"]

	var hit_targets: Array = []
	var struck: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], target_pos) <= radius:
			hit_targets.append(enemy)
			struck.append(enemy.get("node"))
	for guard in _enemy_guards:
		if _distance(guard["pos_index"], target_pos) <= radius:
			struck.append(guard.get("node"))

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["return_to_the_void"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("return_to_the_void", _skill_cooldowns["return_to_the_void"])
	_refresh_skill_cooldown_labels()
	# Nothing else happens this turn while the world is unmade.
	_has_acted_this_turn = true
	_update_action_buttons()

	_play_return_to_the_void(target.get("node"), radius, struck, func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		for enemy in hit_targets:
			if not _enemies.any(func(e: Dictionary) -> bool: return is_same(e, enemy)):
				continue
			_deal_fixed_damage_to_enemy(enemy, damage)
			if enemy.get("current_hp", 0) > 0:
				enemy["return_to_the_void_dot_damage"] = dot_damage
				enemy["return_to_the_void_dot_turns_left"] = dot_duration
				enemy["return_to_the_void_execute_pct"] = execute_pct
		_refresh_mark_of_stillness_frost()
		# Centered on the target's own column, same as the check above - a
		# rival's own guard (The Last Empress's Imperial Guard) can be in range
		# independently of whether the boss itself currently is.
		_deal_aoe_damage_to_enemy_guards(target_pos, radius, damage)

		if target.get("current_hp", 0) > 0:
			target["stun_turns_left"] = int(level_data.get("stun_turns", 1))
		_refresh_bars()

		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	)


## Resolves a Maddening Roar cast on `target`: `level_data.damage` to
## `target` alone, then `level_data.shatter_damage` - a separate,
## lighter amount, not a fraction of the main hit - to every OTHER
## living, targetable enemy within `level_data.shatter_range` columns
## of `target`'s own position, mirroring Drowned Surge's own "splash centered
## on the target, never re-hitting it" radius (_resolve_drowned_surge_cast()),
## just with the splash using its own flat damage figure instead of
## reusing the primary hit's.
##
## Both land with the roar (see _play_maddening_roar()): mana and cooldown
## are spent right away and the turn stays locked while it plays; the
## main hit lands when the roar strikes the target, the shatter damage
## when its rings have spread to the others - then the turn ends. Who's
## caught is snapshotted now.
func _resolve_maddening_roar_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	var shatter_damage: float = float(level_data.get("shatter_damage", 0))
	var shatter_range: int = int(level_data.get("shatter_range", 0))
	var target_pos: int = target["pos_index"]

	var shatter_targets: Array = []
	var shatter_nodes: Array = []
	for enemy in _enemies:
		if is_same(enemy, target) or _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], target_pos) <= shatter_range:
			shatter_targets.append(enemy)
			shatter_nodes.append(enemy.get("node"))
	for guard in _enemy_guards:
		if _distance(guard["pos_index"], target_pos) <= shatter_range:
			shatter_nodes.append(guard.get("node"))

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["maddening_roar"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("maddening_roar", _skill_cooldowns["maddening_roar"])
	_refresh_skill_cooldown_labels()
	# Nothing else happens this turn while the roar plays out.
	_has_acted_this_turn = true
	_update_action_buttons()

	var still_here := func(enemy: Dictionary) -> bool:
		return _enemies.any(func(e: Dictionary) -> bool: return is_same(e, enemy))
	var on_target_hit := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		if still_here.call(target):
			_deal_fixed_damage_to_enemy(target, damage)
	var on_shatter := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		for enemy in shatter_targets:
			if still_here.call(enemy):
				_deal_fixed_damage_to_enemy(enemy, shatter_damage)
		# Centered on the target's own column, same as the check above - a
		# rival's own guard (The Last Empress's Imperial Guard) can be in range
		# independently of whether the boss itself currently is.
		_deal_aoe_damage_to_enemy_guards(target_pos, shatter_range, shatter_damage)
		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	_play_maddening_roar(hero_image, _hero_static, target.get("node"), shatter_nodes, on_target_hit, on_shatter)


## Resolves a cast of The Hunger Calls on `target`: freezes it in place for
## `level_data.duration` of its own turns (target["stun_turns_left"],
## the same shared per-enemy field Drowned Surge's/Return to the Void's own stun
## already uses - see _enemy_turn()'s stun check), then marks it as the
## hero's current curse target so _enemy_turn() redirects every OTHER
## enemy within `level_data.curse_range` columns of it for as long as
## that freeze holds (see _is_the_hunger_calls_active()). Recasting while a
## previous curse is still running simply overwrites it outright -
## there's nothing to give back.
func _resolve_the_hunger_calls_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	target["stun_turns_left"] = int(level_data.get("duration", 0))
	_hunger_calls_target = target
	_hunger_calls_bonus_damage_pct = float(level_data.get("bonus_damage_pct", 0.0))
	_hunger_calls_range = int(level_data.get("curse_range", 0))

	_show_message_over_hero("The Hunger Calls!")
	if _hunger_calls_fx != null:
		_hunger_calls_fx.end()
	_hunger_calls_fx = _play_the_hunger_calls(hero_image, _hero_static, target.get("node"), _hunger_calls_range)
	_refresh_mark_of_stillness_frost()
	_refresh_hunger_calls_fx()

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["the_hunger_calls"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("the_hunger_calls", _skill_cooldowns["the_hunger_calls"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Whether The Hunger Calls is still actively redirecting enemies toward
## its target right now: there's a target at all, it's still part of
## the current fight (_is_enemy_still_active() - the same "hasn't died
## or been cleared by a stage/hero-fight transition" check Essence
## Shift's own donors use), and its freeze (target["stun_turns_left"])
## hasn't run out. No separate duration counter to keep in sync - the
## curse's "pile onto the target" half rides on exactly the same clock
## as the freeze itself, by design (see the state-var block's own
## comment above).
func _is_the_hunger_calls_active() -> bool:
	if _hunger_calls_target.is_empty():
		return false
	if not _is_enemy_still_active(_hunger_calls_target):
		return false
	return _hunger_calls_target.get("stun_turns_left", 0) > 0


## Purely cosmetic: The Hunger Calls (HungerCallsFX) - a gust of wind from
## `caster`'s jaws (its hero data's "roar_origin", mirrored when it faces
## left) to `target_node`, opening a vortex on the ground under it as wide
## as `curse_range` columns either side, the target pulsing. Returns the
## running effect (null if either sprite is already gone) for
## _refresh_hunger_calls_fx() to keep in sync with the curse.
func _play_the_hunger_calls(caster: Variant, hero_static: Dictionary, target_node: Variant, curse_range: int) -> HungerCallsFX:
	if not is_instance_valid(caster) or not is_instance_valid(target_node) or not is_instance_valid(_fx_layer) \
			or not (caster is Control) or not (target_node is Control):
		return null
	var origin: Vector2 = hero_static.get("roar_origin", Vector2(0.5, 0.3))
	if caster.flip_h:
		origin.x = 1.0 - origin.x
	var from: Vector2 = caster.global_position + caster.size * origin
	var radius: float = _grid_unit() * (float(curse_range) + 0.5)
	# The vortex goes behind every fighter, over the battle background.
	return HungerCallsFX.cast(_fx_layer, self, hero_image.get_index(), from, target_node, radius)


## Keeps The Hunger Calls' look in step with the curse: the player's own
## cast marks every other enemy it's currently driving at the frozen
## target (the same "within curse_range of it" rule _enemy_turn() uses)
## with the hunger's red, and any running effect ends once its freeze
## does - worn off, dispelled, or its target gone. Called from
## _refresh_bars(), so it just follows current state.
func _refresh_hunger_calls_fx() -> void:
	if _hunger_calls_fx != null:
		if not is_instance_valid(_hunger_calls_fx) or not _is_the_hunger_calls_active():
			if is_instance_valid(_hunger_calls_fx):
				_hunger_calls_fx.end()
			_hunger_calls_fx = null
		else:
			var target_pos: int = _hunger_calls_target["pos_index"]
			var hungry: Array = []
			for enemy in _enemies:
				if is_same(enemy, _hunger_calls_target) or _is_target_hidden(enemy):
					continue
				if _distance(enemy["pos_index"], target_pos) <= _hunger_calls_range:
					hungry.append(enemy.get("node"))
			_hunger_calls_fx.set_hungry_nodes(hungry)
	if _enemy_hunger_calls_fx != null:
		var held: bool
		if _enemy_hunger_calls_fx_on_bear:
			held = _is_bear_alive() and bool(_bear.get("the_hunger_calls_active", false)) and int(_bear.get("stun_turns_left", 0)) > 0
		else:
			held = _player_the_hunger_calls_active and _player_stun_turns_left > 0
		if not is_instance_valid(_enemy_hunger_calls_fx) or not held:
			if is_instance_valid(_enemy_hunger_calls_fx):
				_enemy_hunger_calls_fx.end()
			_enemy_hunger_calls_fx = null


## Ends every running The Hunger Calls look at once - a new stage or hero
## fight starts from a clean field.
func _end_hunger_calls_fx() -> void:
	if _hunger_calls_fx != null and is_instance_valid(_hunger_calls_fx):
		_hunger_calls_fx.end()
	_hunger_calls_fx = null
	if _enemy_hunger_calls_fx != null and is_instance_valid(_enemy_hunger_calls_fx):
		_enemy_hunger_calls_fx.end()
	_enemy_hunger_calls_fx = null


## Resolves a Rimecleaver cast on `target`: `level_data.damage` to
## `target`, then - once level_data.radius rises above 0, starting at
## level 3 - that same damage to every OTHER living, targetable enemy
## within `level_data.radius` columns of `target`'s own position too,
## mirroring Drowned Surge's own "splash centered on the target, never
## re-hitting it, same amount as the primary hit" radius
## (_resolve_drowned_surge_cast()).
##
## Both land with the axe (see _play_rimecleaver()): mana and cooldown
## are spent right away and the turn stays locked while the axe forms;
## the main hit lands when it chops into `target`, the splash when its
## cleave has swung round the radius - then the turn ends. Who's caught
## is snapshotted now.
func _resolve_rimecleaver_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var damage: float = float(level_data.get("damage", 0))
	var radius: int = int(level_data.get("radius", 0))
	var target_pos: int = target["pos_index"]

	var splash_targets: Array = []
	var splash_guards: Array = []
	if radius > 0:
		for enemy in _enemies:
			if is_same(enemy, target) or _is_target_hidden(enemy):
				continue
			if _distance(enemy["pos_index"], target_pos) <= radius:
				splash_targets.append(enemy)
		# Centered on the target's own column, same as the splash above -
		# a rival's own guard (The Last Empress's Imperial Guard) can be in
		# range independently of whether the boss itself currently is.
		for guard in _enemy_guards:
			if _distance(guard["pos_index"], target_pos) <= radius:
				splash_guards.append(guard)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["rimecleaver"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("rimecleaver", _skill_cooldowns["rimecleaver"])
	_refresh_skill_cooldown_labels()
	# Nothing else happens this turn while the axe forms and falls.
	_has_acted_this_turn = true
	_update_action_buttons()

	var on_impact := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		if _enemies.any(func(e: Dictionary) -> bool: return is_same(e, target)):
			# Flashed red and frosted before the hit lands - a kill frees the node.
			_flash_frost_briefly(target.get("node"), RIMECLEAVER_FROST_SECONDS, BOUNCE_HIT_FLASH_COLOR)
			_deal_fixed_damage_to_enemy(target, damage)
		if radius <= 0 and not _battle_over and _stage_generation == generation_before:
			_mark_turn_used()
	var on_sweep := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		for enemy in splash_targets:
			if not _enemies.any(func(e: Dictionary) -> bool: return is_same(e, enemy)):
				continue
			_deal_fixed_damage_to_enemy(enemy, damage)
		_deal_aoe_damage_to_enemy_guards(target_pos, radius, damage)
		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	# Everyone else caught flashes red (and frosts) as the swing cuts through them.
	var pass_nodes: Array = []
	for enemy in splash_targets:
		pass_nodes.append(enemy.get("node"))
	for guard in splash_guards:
		pass_nodes.append(guard.get("node"))
	var on_pass := func(i: int) -> void:
		if not _battle_over and _stage_generation == generation_before:
			_flash_frost_briefly(pass_nodes[i], RIMECLEAVER_FROST_SECONDS, BOUNCE_HIT_FLASH_COLOR)
	_play_rimecleaver(target.get("node"), radius, on_impact, on_sweep, pass_nodes, on_pass)


## Purely cosmetic: Rimecleaver (RimecleaverFX). An axe of ice forms over
## `target_node` and chops down onto it - `on_impact` fires then - and,
## when `radius` > 0, swings a full circle round it across `radius`
## columns before `on_sweep` fires. Both fire right away if the target's
## sprite is already gone, so the caller's turn flow never stalls.
func _play_rimecleaver(target_node: Variant, radius: int, on_impact: Callable, on_sweep: Callable,
		pass_nodes: Array = [], on_pass: Callable = Callable()) -> void:
	if not is_instance_valid(target_node) or not (target_node is Control) or not is_instance_valid(_fx_layer):
		on_impact.call()
		if radius > 0:
			on_sweep.call()
		return
	var sweep_px := _grid_unit() * (float(radius) + 0.5) if radius > 0 else 0.0
	RimecleaverFX.play(_fx_layer, target_node, sweep_px, func() -> void:
		_shake_screen()
		on_impact.call()
	, on_sweep, pass_nodes, on_pass)


## Resolves a Winter's Grip cast on `target`: freezes it in place for
## `level_data.stun_turns` of its own turns (target["stun_turns_left"],
## the same shared per-enemy field Drowned Surge's/Return to the Void's/The Hunger
## Calls's own stun already uses), then arms its own damage-over-time
## (target["winters_grip_dot_damage"]/["winters_grip_dot_turns_left"], ticked
## by _tick_enemy_turn_start_effects() at the start of that enemy's own
## turn, alongside every other DoT) - a
## dedicated pair of fields rather than reusing Mark of Stillness's/Ice
## Vortex's/Return to the Void's own, so a different skill's DoT never silently
## shares or clobbers another's counters on the same target.
func _resolve_winters_grip_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	target["stun_turns_left"] = int(level_data.get("stun_turns", 0))
	target["winters_grip_dot_damage"] = float(level_data.get("dot_damage", 0))
	target["winters_grip_dot_turns_left"] = int(level_data.get("dot_duration", 0))
	target["winters_grip_hold"] = true
	if is_instance_valid(target.get("node")):
		_flash_bounce_hit(target["node"], MARK_OF_STILLNESS_FLASH_COLOR)
	_refresh_mark_of_stillness_frost()
	_refresh_winters_grip_hands()

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["winters_grip"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("winters_grip", _skill_cooldowns["winters_grip"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()



# ------------------------------------------------------------------
# Kaelen Varr's Pull of the Abyss - a passive, so unlike Drowned Surge above there's no
# button/cast/mana/cooldown for it (see _populate_skill_buttons()'s
# "passive" branch); it just triggers off the hero's own plain Attacks
# (_apply_hero_attack()), exactly the way Mark of the Mist's stacking
# does for Morvael.
# ------------------------------------------------------------------

## Pull of the Abyss's level data for whatever level the player has it at
## right now - {} if it isn't learned at all (level 0), the same
## "empty means locked" convention every other auto-triggered skill's
## own _get_*_level_data() helper uses.
func _get_pull_of_the_abyss_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("pull_of_the_abyss")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "pull_of_the_abyss":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Called from _apply_hero_attack() right before rolling that Attack's
## damage: counts one more plain Attack toward this level's own
## hits_to_activate - never reset by a turn going by without attacking
## (only consuming the count resets it, never time) - and, once that
## threshold is reached, consumes the count and returns this level's
## data for _apply_hero_attack() to fold bonus_damage into the roll and
## then cleave with (_apply_pull_of_the_abyss_cleave()). Returns {} (an
## ordinary Attack, no bonus) if the hero hasn't learned Pull of the Abyss or
## hasn't reached the threshold yet.
func _maybe_consume_pull_of_the_abyss_stack() -> Dictionary:
	var level_data: Dictionary = _get_pull_of_the_abyss_level_data()
	if level_data.is_empty():
		return {}

	_pull_of_the_abyss_attack_count += 1
	if _pull_of_the_abyss_attack_count < int(level_data.get("hits_to_activate", 1)):
		return {}

	_pull_of_the_abyss_attack_count = 0
	_show_rising_message_over(hero_image, "Pull of the Abyss!", PULL_OF_THE_ABYSS_TEXT_COLOR)
	return level_data


## Pull of the Abyss's cleave: every OTHER living, targetable enemy within
## this level's cleave_columns of `target`'s own column takes
## cleave_damage_pct of `attack_damage` - the same raw, pre-mitigation
## roll `target` was just hit with (bonus damage already folded in by
## _apply_hero_attack()), each still mitigated by ITS OWN armor via
## _deal_fixed_damage_to_enemy(), mirroring Abyssal Spasm's own "one rolled
## amount, many separately-mitigated hits" pattern (_cast_abyssal_spasm()).
func _apply_pull_of_the_abyss_cleave(target: Dictionary, attack_damage: float, level_data: Dictionary) -> void:
	var cleave_damage: float = attack_damage * float(level_data.get("cleave_damage_pct", 0.0))
	if cleave_damage <= 0.0:
		return

	_apply_splash_damage(target, cleave_damage, int(level_data.get("cleave_columns", 1)))


const CLEAVER_DAMAGE_PCT := 0.30
const CLEAVER_RANGE := 1

# The Hunter's Bow item (see _apply_hunters_bow_split()): every
# HUNTERS_BOW_ATTACKS_PER_SPLIT-th plain Attack from a ranged hero also
# hits one more enemy within HUNTERS_BOW_RANGE columns of the target,
# for HUNTERS_BOW_DAMAGE_PCT of the Attack's damage. The split arrow is
# drawn with the Hope of the Fallen's shape, in these gold colors.
const HUNTERS_BOW_ATTACKS_PER_SPLIT := 3
const HUNTERS_BOW_RANGE := 2
const HUNTERS_BOW_DAMAGE_PCT := 1.0
const HUNTERS_BOW_ARROW_PALETTE := {
	"shaft": Color(1.0, 0.8, 0.35, 0.95),
	"head": Color(1.4, 1.2, 0.7, 1.0),
	"fletch": Color(0.75, 0.2, 0.18, 0.95),
}

# Hunter's Bow's charge: plain Attacks landed toward the next split,
# 0..HUNTERS_BOW_ATTACKS_PER_SPLIT. Battle-local (resets every fight -
# a fresh battle scene starts it at 0), never saved. Once full it stays
# full until an Attack actually has a second enemy in range to split
# onto, rather than being wasted on a lone target.
var _hunters_bow_charge: int = 0


## The Cleaver item's own passive: identical shape to Pull of the Abyss's
## cleave just above (same "% of the attack's own raw damage, before
## the main target's own armor reduces it, splashed to every OTHER
## living enemy within `radius` columns, each mitigated by its own
## armor separately" rule - see _apply_pull_of_the_abyss_cleave()) but a
## flat, always-on item bonus rather than a levelled, stack-consuming
## skill proc. Gated on actually owning one - a no-op the instant it's
## sold, same as every other passive "stat" item's own bonus (see
## PlayerManager.get_inventory_stat_bonus()'s own comment on why
## nothing needs to be stored beyond "is it in the inventory right
## now").
func _apply_cleaver_cleave(target: Dictionary, attack_damage: float) -> void:
	if PlayerManager.get_inventory().get("cleaver", 0) <= 0:
		return
	# The cleave is melee-only - a ranged hero still gets Cleaver's flat
	# +10 damage (a plain "stat" bonus, see GameManager's item entry),
	# just no splash. Beast of the Elderwild's forced melee counts as melee here,
	# same as everywhere else _is_ranged_hero() is asked.
	if _is_ranged_hero():
		return

	var cleave_damage: float = attack_damage * CLEAVER_DAMAGE_PCT
	if cleave_damage <= 0.0:
		return

	_apply_splash_damage(target, cleave_damage, CLEAVER_RANGE)


## The Hunter's Bow item's own passive: the ranged-hero counterpart of
## Cleaver's cleave (_apply_cleaver_cleave()). Each plain Attack from a
## ranged hero who owns one adds a charge; on the
## HUNTERS_BOW_ATTACKS_PER_SPLIT-th, the shot splits - the nearest other
## living, visible enemy within HUNTERS_BOW_RANGE columns of `target`
## also takes HUNTERS_BOW_DAMAGE_PCT of `attack_damage` (the Attack's
## raw, pre-mitigation roll), mitigated by its own armor, with a gold
## arrow peeling off to it and the standard red splash flash. Damage
## only - no on-hit effects (lifesteal, Leeching Hunger, Lunar Ricochet...)
## for the second target, same as Cleaver's splash. A full charge with
## no second enemy in range stays full for the next Attack instead of
## being spent. Rival guards aren't eligible - they only ever take
## redirected attacks and AoE damage; the rival's own Elderwild Companion, a
## regular enemy, is. Owning several doesn't split more often (the +10
## damage still stacks per copy), same as Cleaver. No-op for melee
## heroes (Beast of the Elderwild's forced melee included) and without the item.
func _apply_hunters_bow_split(target: Dictionary, attack_damage: float) -> void:
	if PlayerManager.get_inventory().get("hunters_bow", 0) <= 0 or not _is_ranged_hero():
		return

	_hunters_bow_charge = mini(_hunters_bow_charge + 1, HUNTERS_BOW_ATTACKS_PER_SPLIT)
	if _hunters_bow_charge >= HUNTERS_BOW_ATTACKS_PER_SPLIT:
		var second: Dictionary = _find_hunters_bow_second_target(target)
		if not second.is_empty():
			_hunters_bow_charge = 0
			_play_hope_of_the_fallen_flight(target.get("node"), second.get("node"), _distance(target["pos_index"], second["pos_index"]), HUNTERS_BOW_ARROW_PALETTE)
			if is_instance_valid(second.get("node")):
				_flash_bounce_hit(second["node"])
			_show_rising_message_over(hero_image, "Split Shot!", Color(1.0, 0.8, 0.3, 1.0))
			_deal_fixed_damage_to_enemy(second, attack_damage * HUNTERS_BOW_DAMAGE_PCT)
	_populate_item_grid()


## The nearest other living, visible enemy within HUNTERS_BOW_RANGE
## columns of `target` - Hunter's Bow's split shot's second target - or
## {} if there's none. Ties go to whichever comes first in _enemies.
func _find_hunters_bow_second_target(target: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	var best_distance: int = HUNTERS_BOW_RANGE + 1
	for enemy in _enemies:
		if is_same(enemy, target) or _is_target_hidden(enemy) or enemy.get("current_hp", 0) <= 0:
			continue
		var d: int = _distance(enemy["pos_index"], target["pos_index"])
		if d <= HUNTERS_BOW_RANGE and d < best_distance:
			best = enemy
			best_distance = d
	return best


# ------------------------------------------------------------------
# The Last Empress's Empress's Will - a passive, so unlike every cast skill above
# there's no button/cast/mana/cooldown for it. Two independent halves:
# a Pull of the Abyss/Cleaver-style AoE splash off the hero's own plain
# Attacks (_apply_empress_will_cleave(), called from _apply_hero_attack()),
# and a set of flat bonuses folded into Imperial Guard's own cast
# (_activate_imperial_guard() reads _get_empress_will_level_data() itself -
# see that function's own comment) rather than anything ticked or
# tracked here.
# ------------------------------------------------------------------

## Empress's Will's level data for whatever level the player has it at right
## now - {} if it isn't learned at all (level 0), the same "empty means
## locked" convention every other auto-triggered skill's own
## _get_*_level_data() helper uses.
func _get_empress_will_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("empress's_will")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "empress's_will":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Empress's Will's own AoE splash: identical shape to Pull of the Abyss's/
## Cleaver's own cleave above (% of the attack's own raw damage, before
## the main target's own armor reduces it, splashed to every OTHER
## living enemy within `radius` columns, each mitigated by its own
## armor separately) but keyed off this level's own aoe_damage_pct/
## radius rather than a flat item bonus or a consumed stack - independent
## of and stacks with Pull of the Abyss's/Cleaver's, same as those two already
## stack with each other. A no-op while the skill isn't learned.
func _apply_empress_will_cleave(target: Dictionary, attack_damage: float) -> void:
	var level_data: Dictionary = _get_empress_will_level_data()
	if level_data.is_empty():
		return

	var cleave_damage: float = attack_damage * float(level_data.get("aoe_damage_pct", 0.0))
	if cleave_damage <= 0.0:
		return

	_apply_splash_damage(target, cleave_damage, int(level_data.get("radius", 0)))


## The standard splash/cleave off a hit on `target`: every OTHER living,
## targetable enemy within `radius` columns of `target`'s own column
## takes `splash_damage` - raw and pre-mitigation, each still mitigated
## by ITS OWN armor via _deal_fixed_damage_to_enemy() - and gets
## _flash_bounce_hit()'s red flash, the same one Lunar Ricochet' bounces
## use, so a splashed enemy visibly reads as hit. Every enemy guard
## within that same radius is hit (and flashed) too - guards are
## unconditional collateral on any AoE splash, same rule Lunar Ricochet
## follows. The boss's own Elderwild Companion needs nothing extra: it's a
## regular _enemies entry, so the loop reaches it like any other enemy.
##
## Shared by Pull of the Abyss, the Cleaver item and Empress's Will - any future
## cleave/splash should route through here too, so they all behave and
## look the same.
func _apply_splash_damage(target: Dictionary, splash_damage: float, radius: int) -> void:
	if splash_damage <= 0.0:
		return

	var target_pos: int = target["pos_index"]
	# Iterates a copy - a splash kill removes that enemy from _enemies
	# mid-loop.
	for enemy in _enemies.duplicate():
		if is_same(enemy, target) or _is_target_hidden(enemy):
			continue
		if enemy.get("current_hp", 0) <= 0:
			continue
		if _distance(enemy["pos_index"], target_pos) <= radius:
			_deal_fixed_damage_to_enemy(enemy, splash_damage)
			if is_instance_valid(enemy.get("node")):
				_flash_bounce_hit(enemy["node"])

	_deal_aoe_damage_to_enemy_guards(target_pos, radius, splash_damage, true)


# ------------------------------------------------------------------
# Lunara's Lunar Ricochet - a passive, so unlike every cast skill above
# there's no button/cast/mana/cooldown for it. Unlike Pull of the Abyss's/
# Cleaver's/Empress's Will's cleave above (every OTHER enemy within radius,
# uncapped), this caps at this level's own `bounces` count - see
# _apply_lunar_ricochet_bounces()'s own comment.
# ------------------------------------------------------------------

## Lunar Ricochet' level data for whatever level the player has it at
## right now - {} if it isn't learned at all (level 0), same "empty
## means locked" convention every other auto-triggered skill's own
## _get_*_level_data() helper uses.
func _get_lunar_ricochet_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("lunar_ricochet")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "lunar_ricochet":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Lunar Ricochet' own bounce: the nearest `bounces` other living,
## targetable enemies within `bounce_range` columns of `target`'s own
## column each take `bounce_damage_pct` of `attack_damage` - the same
## raw, pre-mitigation roll `target` was just hit with - still mitigated
## by their own armor separately via _deal_fixed_damage_to_enemy(),
## mirroring Pull of the Abyss's/Cleaver's/Empress's Will's own "one rolled amount,
## many separately-mitigated hits" pattern, just capped at `bounces`
## targets (nearest first) instead of hitting everyone in range. Any
## enemy guard within that same radius is ALSO hit, via
## _deal_aoe_damage_to_enemy_guards() - guards are unconditional
## collateral on any AoE splash, never counted toward the bounce cap
## (see that function's own comment). The boss's own Elderwild Companion needs
## no separate call: it's a regular _enemies entry (see
## _get_enemy_elderwild_companion()), so the loop below already reaches it like
## any other enemy. Each bounced enemy also gets _flash_bounce_hit()'s
## own quick scale/red-flash, so a bounce reads as a distinct hit
## instead of a damage number appearing on an enemy that was never
## targeted. A no-op while the skill isn't learned.
func _apply_lunar_ricochet_bounces(target: Dictionary, attack_damage: float) -> void:
	var level_data: Dictionary = _get_lunar_ricochet_level_data()
	if level_data.is_empty():
		return

	var bounce_damage: float = attack_damage * float(level_data.get("bounce_damage_pct", 0.0))
	if bounce_damage <= 0.0:
		return

	var bounces: int = int(level_data.get("bounces", 0))
	if bounces <= 0:
		return

	var radius: int = int(level_data.get("bounce_range", 0))
	var target_pos: int = target["pos_index"]

	_deal_aoe_damage_to_enemy_guards(target_pos, radius, bounce_damage)

	var candidates: Array = []
	for enemy in _enemies:
		if is_same(enemy, target) or _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], target_pos) <= radius:
			candidates.append(enemy)

	candidates.sort_custom(func(a, b): return _distance(a["pos_index"], target_pos) < _distance(b["pos_index"], target_pos))

	# The attack's own chakram (see ChakramFX) glances off the target and cuts
	# from enemy to enemy; each bounce is flashed as it bites in, not the
	# instant the damage lands. Without one in flight, flash at once.
	var chakram := ChakramFX.latest()
	for i in range(mini(bounces, candidates.size())):
		var bounced_enemy: Dictionary = candidates[i]
		var bounced_node: Variant = bounced_enemy.get("node")
		var chest := Vector2.ZERO
		if chakram != null and is_instance_valid(bounced_node):
			chest = bounced_node.global_position + bounced_node.size * Vector2(0.5, 0.45)
		_deal_fixed_damage_to_enemy(bounced_enemy, bounce_damage)
		if chakram != null and chest != Vector2.ZERO:
			chakram.add_bounce(chest, func() -> void:
				if is_instance_valid(bounced_node):
					_flash_bounce_hit(bounced_node))
		elif is_instance_valid(bounced_node):
			_flash_bounce_hit(bounced_node)


# ------------------------------------------------------------------
# Lunara's Moonbound Might - a passive, so unlike every cast skill above
# there's no button/cast/mana/cooldown for it. Just a permanent %
# increase to the hero's own Attack damage, read fresh off this level's
# own bonus_damage_pct by _roll_hero_damage() itself (see that
# function's own comment) rather than anything ticked or tracked here.
# ------------------------------------------------------------------

## Moonbound Might's level data for whatever level the player has it at
## right now - {} if it isn't learned at all (level 0), same "empty
## means locked" convention every other auto-triggered skill's own
## _get_*_level_data() helper uses.
func _get_moonbound_might_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("moonbound_might")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "moonbound_might":
			return GameManager.get_skill_level_data(skill, level)
	return {}


# ------------------------------------------------------------------
# Dreadlure's Might of the Deep - a passive, so unlike every cast skill
# above there's no button/cast/mana/cooldown for it. Counts the hero's
# own plain Attacks toward this level's own attacks_required threshold
# (same "build a stack, consume it all once the threshold's reached"
# idiom Pull of the Abyss's own _maybe_consume_pull_of_the_abyss_stack() uses,
# just under its own counter rather than a per-enemy one - there's
# only one hero to track this on), then _apply_hero_attack() itself
# folds the returned level data's own bonus_damage_pct into that SAME
# attack's damage (see its own comment) and knocks the target back
# afterward.
# ------------------------------------------------------------------

## Might of the Deep's level data for whatever level the player has it
## at right now - {} if it isn't learned at all (level 0), the same
## "empty means locked" convention every other auto-triggered skill's
## own _get_*_level_data() helper uses.
func _get_might_of_the_deep_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("might_of_the_deep")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "might_of_the_deep":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Called on every plain hero Attack (see _apply_hero_attack()): builds
## one stack, or - once this level's own attacks_required is reached -
## consumes them all and returns the level data for that same Attack to
## apply its bonus/knockback with. Returns {} (a no-op contribution)
## every other Attack, and while the skill isn't learned at all.
func _maybe_consume_might_of_the_deep_stack() -> Dictionary:
	var level_data: Dictionary = _get_might_of_the_deep_level_data()
	if level_data.is_empty():
		return {}

	_might_of_the_deep_attack_count += 1
	if _might_of_the_deep_attack_count < int(level_data.get("attacks_required", 1)):
		return {}

	_might_of_the_deep_attack_count = 0
	return level_data


## Knocks `target` back this level's own `knockback` columns, away from
## the hero (his current facing, hero_image.flip_h) - stopping early at
## the board edge or another enemy already occupying the next column,
## same rules Glacier Breaker's own knockback follows, just without that
## ultimate's own wall-bonus-damage/stun/animated-slide flourishes
## (this is a passive proc off a plain Attack, not its own cast).
## Repositions instantly via _move_enemy(), the same helper regular
## enemy AI movement already uses.
func _apply_might_of_the_deep_knockback(target: Dictionary, level_data: Dictionary) -> void:
	var knockback_columns: int = int(level_data.get("knockback", 0))
	var direction: int = -1 if hero_image.flip_h else 1
	var pos: int = target["pos_index"]

	for i in range(knockback_columns):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if not _get_enemy_at(next_pos).is_empty():
			break
		pos = next_pos

	if pos != target["pos_index"]:
		_move_enemy(target, pos)


# ------------------------------------------------------------------
# Frost Daughter's Frostborn - a passive, so unlike every cast skill
# above there's no button/cast/mana/cooldown for it (see
# _populate_skill_buttons()'s "passive" branch); it just regenerates
# mana on its own at the start of every hero turn (_apply_frostborn_
# regen(), called from _end_turn()).
# ------------------------------------------------------------------

## Frostborn's level data for whatever level the player has it at
## right now - {} if it isn't learned at all (level 0), the same
## "empty means locked" convention every other auto-triggered skill's
## own _get_*_level_data() helper uses.
func _get_frostborn_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("frostborn")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "frostborn":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Restores this level's own flat bonus_mana_regen, on top of the
## hero's own passive mana regen (_apply_passive_hero_regen(), called
## right after this in _end_turn()) rather than replacing it - once at
## the very start of every hero turn, regardless of whether the player
## actually gets to act that turn (e.g. still stunned or held in The
## Test of Time). A no-op while the skill isn't learned.
func _apply_frostborn_regen() -> void:
	var level_data: Dictionary = _get_frostborn_level_data()
	if level_data.is_empty():
		return

	# A share of max mana, so it keeps pace with her growing skill costs; a
	# flat bonus_mana_regen still adds on if a level ever carries one.
	var max_mana: float = float(_recruited.get("stats", {}).get("mana", 0))
	restore_mana(float(level_data.get("bonus_mana_regen", 0)) + float(level_data.get("bonus_mana_regen_pct", 0.0)) * max_mana)


# ------------------------------------------------------------------
# Frost Daughter's ultimate, The Frost Tempest.
# ------------------------------------------------------------------

## Activates The Frost Tempest: arms this level's own damage/radius for
## `level_data.duration` turns. Always "succeeds" - cast on the hero
## himself, no target or range requirement, same as every other
## self-cast buff.
func _activate_frost_tempest(level_data: Dictionary) -> void:
	_frost_tempest_active = true
	_frost_tempest_damage_per_turn = float(level_data.get("damage", 0))
	_frost_tempest_radius = int(level_data.get("radius", 0))
	_frost_tempest_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_frost_tempest()), same as
	# every other duration-based buff.
	_frost_tempest_duration_pending_start = true

	_show_message_over_hero("The Frost Tempest!")


## Ticks The Frost Tempest's duration down once per End Turn, same timing
## (and same "the casting turn doesn't count" skip) as every other
## duration-based buff - dealing this level's own damage to every
## living, targetable enemy within radius columns of the hero's CURRENT
## position (re-checked fresh here, not fixed at cast time) on every
## tick that actually counts against the duration.
func _tick_frost_tempest() -> void:
	if not _frost_tempest_active:
		return

	if _frost_tempest_duration_pending_start:
		_frost_tempest_duration_pending_start = false
		return

	# Every unit this tick is about to hit flashes red - gathered before
	# any damage lands, since a kill frees its node.
	var hit_nodes: Array = []
	for enemy in _enemies:
		if not _is_target_hidden(enemy) and _distance(enemy["pos_index"], _hero_pos_index) <= _frost_tempest_radius:
			hit_nodes.append(enemy.get("node"))
	for guard in _enemy_guards:
		if _distance(guard["pos_index"], _hero_pos_index) <= _frost_tempest_radius:
			hit_nodes.append(guard.get("node"))
	_flash_frost_tempest_hits(hit_nodes)

	for enemy in _enemies.duplicate():
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= _frost_tempest_radius:
			_deal_fixed_damage_to_enemy(enemy, _frost_tempest_damage_per_turn)
			if _battle_over:
				return
	# Self-centered on the hero's CURRENT position, same as the check
	# above - a rival's own guard (The Last Empress's Imperial Guard) can be
	# in range independently of whether the boss itself currently is.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, _frost_tempest_radius, _frost_tempest_damage_per_turn)

	_frost_tempest_turns_remaining -= 1
	if _frost_tempest_turns_remaining <= 0:
		_end_frost_tempest()
	_refresh_mark_of_stillness_frost()


## Purely cosmetic: The Frost Tempest's tick - every unit in `nodes` (all
## the tick is about to hit, gathered before the damage lands since a
## kill frees its node) flashes red as the storm tears into it.
func _flash_frost_tempest_hits(nodes: Array) -> void:
	for node in nodes:
		if is_instance_valid(node) and node is TextureRect:
			_flash_bounce_hit(node)


## Ends The Frost Tempest once its duration runs out.
func _end_frost_tempest() -> void:
	_frost_tempest_active = false
	_frost_tempest_damage_per_turn = 0.0
	_frost_tempest_radius = 0
	_frost_tempest_turns_remaining = 0
	_frost_tempest_duration_pending_start = false
	_refresh_mark_of_stillness_frost()

	_show_message_over_hero("The Frost Tempest fades")


# ------------------------------------------------------------------
# Lunara's ultimate, Eternal Eclipse.
# ------------------------------------------------------------------
# The black sun of Eternal Eclipse (see EclipseSkyFX), up while either side's
# Eternal Eclipse lasts.
var _eclipse_sky: EclipseSkyFX


## Raises the eclipse over the battlefield, under the fighters. No-op if
## it is already up.
func _begin_eclipse_sky() -> void:
	if is_instance_valid(_eclipse_sky):
		return
	var below: int = mini(hero_image.get_index(), enemies_layer.get_index())
	_eclipse_sky = EclipseSkyFX.begin(self, below)


## Lowers the eclipse - fades it out.
func _end_eclipse_sky() -> void:
	if is_instance_valid(_eclipse_sky):
		_eclipse_sky.end()
	_eclipse_sky = null


## Keeps the eclipse sky in step with the ultimates: down once neither
## side's Eternal Eclipse is active any more.
func _refresh_eclipse_sky() -> void:
	if not _eternal_eclipse_active and not _enemy_eternal_eclipse_active:
		_end_eclipse_sky()


## Purely cosmetic: one Eternal Eclipse beam drops from the black sun onto
## `target_node` (see EclipseBeamFX), the sun's corona flaring as it fires,
## and the struck sprite pulses as it lands. No-op if the node is gone.
func _play_eclipse_strike(target_node: Variant) -> void:
	if target_node == null or not is_instance_valid(target_node) or not (target_node is TextureRect):
		return
	var node: TextureRect = target_node
	var chest: Vector2 = node.global_position + node.size * Vector2(0.5, 0.45)
	var ground_y: float = node.global_position.y + node.size.y * 0.97
	var from: Vector2 = chest + Vector2(0.0, -420.0)
	if is_instance_valid(_eclipse_sky):
		from = _eclipse_sky.rim_toward(chest)
		_eclipse_sky.flare()
	EclipseBeamFX.strike(_fx_layer, from, chest, ground_y)
	get_tree().create_timer(EclipseBeamFX.DROP_TIME).timeout.connect(func() -> void:
		if is_instance_valid(node):
			_pulse_caster_sprite(node, false))



# How many beams _tick_eternal_eclipse() fires per End Turn while Eternal Eclipse is
# active - a flat rule, not a per-level number (only the total beam
# count, damage, and radius scale with level - see GameManager's own
# "eternal_eclipse" skill data).
const ETERNAL_ECLIPSE_BEAMS_PER_TURN := 2


## Activates Eternal Eclipse: arms this level's own damage/radius/beams. Always
## "succeeds" - cast on the hero himself, no target or range
## requirement, same as every other self-cast buff.
func _activate_eternal_eclipse(level_data: Dictionary) -> void:
	_eternal_eclipse_active = true
	_eternal_eclipse_damage_per_beam = float(level_data.get("damage", 0))
	_eternal_eclipse_radius = int(level_data.get("radius", 0))
	_eternal_eclipse_beams_remaining = int(level_data.get("beams", 0))
	# The casting turn itself doesn't count - beams only start landing
	# from the turn after (see _tick_eternal_eclipse()), same as every other
	# duration-based buff.
	_eternal_eclipse_duration_pending_start = true

	_begin_eclipse_sky()
	_show_message_over_hero("Eternal Eclipse!")


## Ticks Eternal Eclipse once per End Turn, same timing (and same "the casting
## turn doesn't count" skip) as every other duration-based buff: fires
## up to ETERNAL_ECLIPSE_BEAMS_PER_TURN beams (or however many are left, if
## fewer) this turn. Each beam independently rolls ONE random living,
## targetable candidate from everything within radius columns of the
## hero's CURRENT position (re-checked fresh here, not fixed at cast
## time, so the range follows her if she moves) - a real enemy or, while
## the rival has Imperial Guard up, one of its guards, both equally
## likely since a guard is a real occupant of its own column same as
## the boss's own Elderwild Companion already is (it's a regular _enemies entry,
## same reasoning as Lunar Ricochet' own bounce - see
## _apply_lunar_ricochet_bounces()'s own comment). A beam with nothing in
## range still counts against the total, same as a Dota Eternal Eclipse beam
## that finds no target. Every beam that does land also plays Moonfall
## Lance's own falling-moonlight visual (_play_moonfall_lance_impact()) on
## whatever it struck. Ends the instant every beam has landed.
func _tick_eternal_eclipse() -> void:
	if not _eternal_eclipse_active:
		return

	if _eternal_eclipse_duration_pending_start:
		_eternal_eclipse_duration_pending_start = false
		return

	var boss: Dictionary = _get_hero_fight_boss()

	for i in range(ETERNAL_ECLIPSE_BEAMS_PER_TURN):
		if _eternal_eclipse_beams_remaining <= 0:
			break
		_eternal_eclipse_beams_remaining -= 1

		var candidates: Array = []
		for enemy in _enemies:
			if _is_target_hidden(enemy):
				continue
			if _distance(enemy["pos_index"], _hero_pos_index) <= _eternal_eclipse_radius:
				candidates.append(enemy)
		if not boss.is_empty():
			for guard in _enemy_guards:
				if _distance(guard["pos_index"], _hero_pos_index) <= _eternal_eclipse_radius:
					candidates.append(guard)

		if not candidates.is_empty():
			var picked: Dictionary = candidates[randi() % candidates.size()]
			if picked.has("static"):
				_deal_fixed_damage_to_enemy(picked, _eternal_eclipse_damage_per_beam)
			else:
				var mitigated: float = _apply_armor_reduction(_eternal_eclipse_damage_per_beam, _enemy_hero_effective_armor(boss))
				_deal_damage_to_enemy_guard(picked, mitigated)
			# Same falling moonlight beam Moonfall Lance lands with (see
			# _play_moonfall_lance_impact()'s own comment) - purely cosmetic,
			# played alongside the damage above rather than gating it.
			_play_eclipse_strike(picked.get("node"))

		if _battle_over:
			return

	if _eternal_eclipse_beams_remaining <= 0:
		_end_eternal_eclipse()


## Ends Eternal Eclipse once every beam has landed.
func _end_eternal_eclipse() -> void:
	_eternal_eclipse_active = false
	_eternal_eclipse_damage_per_beam = 0.0
	_eternal_eclipse_radius = 0
	_eternal_eclipse_beams_remaining = 0
	_eternal_eclipse_duration_pending_start = false

	_refresh_eclipse_sky()
	_show_message_over_hero("Eternal Eclipse fades")


# ------------------------------------------------------------------
# Skarn's Frostbound Rupture.
# ------------------------------------------------------------------

## Resolves a Frostbound Rupture cast on `target`: `level_data.damage` to
## `target` (still mitigated by its own armor, via _deal_fixed_damage_
## to_enemy() - same helper every other targeted skill uses), then
## walls off `level_data.blocked_columns` columns for `level_data.
## duration` turns - starting on the hero's OWN column and continuing
## one column at a time toward `target`'s, stopping early if that walk
## would run off either edge of the board. Recasting while a previous
## wall is still up simply replaces it outright.
func _resolve_frostbound_rupture_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	# Mana and cooldown are spent right away; nothing else happens this
	# turn while Skarn slams the ground - the shards, hit and walls all
	# come out of that slam (_play_ground_slam()).
	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["frostbound_rupture"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("frostbound_rupture", _skill_cooldowns["frostbound_rupture"])
	_refresh_skill_cooldown_labels()
	_has_acted_this_turn = true
	_update_action_buttons()

	_play_ground_slam(hero_image, func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		if not _enemies.any(func(e: Dictionary) -> bool: return is_same(e, target)):
			_mark_turn_used()
			return
		_land_frostbound_rupture(target, level_data)
	)


## The part of a Frostbound Rupture cast that comes out of the slam: the
## shards fly, `target` takes the hit and the columns wall off.
func _land_frostbound_rupture(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation
	var damage: float = float(level_data.get("damage", 0))
	# Thrown before the hit lands - it may kill (and free) the target.
	_play_frostbound_rupture_hit(hero_image, target.get("node"))
	_deal_fixed_damage_to_enemy(target, damage)

	var direction: int = _step_toward(_hero_pos_index, target["pos_index"])
	if direction == 0:
		direction = 1

	var blocked_columns: int = int(level_data.get("blocked_columns", 0))
	var columns: Array[int] = []
	var col: int = _hero_pos_index
	for i in range(blocked_columns):
		if col < 0 or col >= GRID_COLUMNS:
			break
		columns.append(col)
		col += direction

	_frostbound_rupture_active = true
	_frostbound_rupture_blocked_columns = columns
	_frostbound_rupture_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_frostbound_rupture()), same as
	# every other duration-based effect.
	_frostbound_rupture_duration_pending_start = true
	_refresh_frostbound_rupture_visuals()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Purely cosmetic: `node` (a hero's sprite) rears up and slams the
## ground (CreatureAnimator.play_slam()); on impact the screen shakes,
## a burst of ice and snow erupts at its feet and cracks of frost race
## out across the ground - then `on_impact` fires. Fires right away if
## the sprite is gone, so the caller's turn flow never stalls.
func _play_ground_slam(node: Variant, on_impact: Callable) -> void:
	if not is_instance_valid(node) or not (node is Control):
		on_impact.call()
		return
	var animator := CreatureAnimator.of(node)
	if animator != null:
		animator.play_slam()
	var feet: Vector2 = node.global_position - global_position + Vector2(node.size.x * 0.5, node.size.y * 0.96)
	var width: float = node.size.x
	get_tree().create_timer(CreatureAnimator.SLAM_IMPACT_TIME if animator != null else 0.0).timeout.connect(func() -> void:
		if not is_inside_tree():
			return
		_shake_screen()
		_play_orb_impact(feet, FROSTBOUND_RUPTURE_FACET_COLOR, 1.6)
		var cracks := Node2D.new()
		cracks.position = feet
		add_child(cracks)
		move_child(cracks, enemies_layer.get_index())
		var lines: Array = []
		for i in 9:
			var ang: float = TAU * (float(i) + randf_range(0.2, 0.8)) / 9.0
			var pts := PackedVector2Array([Vector2.ZERO])
			var p := Vector2.ZERO
			for k in 4:
				p += Vector2.from_angle(ang + randf_range(-0.35, 0.35)) * width * randf_range(0.12, 0.2) * Vector2(1.0, 0.3)
				pts.append(p)
			lines.append(pts)
		var grow := [0.0]
		cracks.draw.connect(func() -> void:
			for pts in lines:
				var n: int = maxi(2, int(ceil(pts.size() * grow[0])))
				cracks.draw_polyline(pts.slice(0, n), Color(0.85, 0.95, 1.0, 0.9), 2.2, true)
		)
		var tw := cracks.create_tween()
		tw.tween_method(func(v: float) -> void:
			grow[0] = v
			cracks.queue_redraw(), 0.0, 1.0, 0.18)
		tw.tween_interval(0.35)
		tw.tween_property(cracks, "modulate:a", 0.0, 0.4)
		tw.tween_callback(cracks.queue_free)
		on_impact.call()
	)


## Ticks Frostbound Rupture's duration down once per End Turn, same timing (and
## same "the casting turn doesn't count" skip) as every other duration-
## based effect.
func _tick_frostbound_rupture() -> void:
	if not _frostbound_rupture_active:
		return

	if _frostbound_rupture_duration_pending_start:
		_frostbound_rupture_duration_pending_start = false
		return

	_frostbound_rupture_turns_remaining -= 1
	if _frostbound_rupture_turns_remaining <= 0:
		_end_frostbound_rupture()


## Ends Frostbound Rupture once its duration runs out - the walled-off columns
## reopen to movement immediately.
func _end_frostbound_rupture() -> void:
	_frostbound_rupture_active = false
	_frostbound_rupture_blocked_columns = []
	_frostbound_rupture_turns_remaining = 0
	_frostbound_rupture_duration_pending_start = false
	_refresh_frostbound_rupture_visuals()


## Keeps the on-screen ice blocks in sync with whatever's actually
## walled off right now, on either side (the player's own Frostbound Rupture and
## a rival Skarn's both use the same look) - called from every place
## either side's own blocked-columns list changes (cast, natural expiry,
## a recast replacing the old columns). Columns newly walled get a block
## rising out of the ground (_build_ice_block()), columns no longer
## walled have theirs shatter, and columns still walled are left as
## they are - so one side's wall changing never re-plays the other's.
## Blocks are semi-transparent and layered right after enemies_layer
## (drawing over the hero/enemy sprites without a z-order fight), so a
## creature standing in a walled column - very likely, both sides'
## walls always start on the caster's own column - still reads through.
func _refresh_frostbound_rupture_visuals() -> void:
	var columns: Array[int] = []
	if _frostbound_rupture_active:
		columns.append_array(_frostbound_rupture_blocked_columns)
	if _enemy_frostbound_rupture_active:
		for col in _enemy_frostbound_rupture_blocked_columns:
			if col not in columns:
				columns.append(col)

	for col in _frostbound_rupture_wall_nodes.keys():
		if col not in columns:
			_shatter_ice_block(_frostbound_rupture_wall_nodes[col])
			_frostbound_rupture_wall_nodes.erase(col)

	var ground_y: float = _creature_y() + get_viewport_rect().size.y / 4.0
	var block_height: float = get_viewport_rect().size.y / 4.0 * FROSTBOUND_RUPTURE_HEIGHT_RATIO
	var block_width: float = _grid_unit() * 0.9
	for i in columns.size():
		var col: int = columns[i]
		if _frostbound_rupture_wall_nodes.has(col) and is_instance_valid(_frostbound_rupture_wall_nodes[col]):
			continue
		var block: Node2D = _build_ice_block(block_width, block_height)
		# Origin at the ground, so scaling it grows the ice up out of it.
		block.position = Vector2(_index_to_x(col) + _grid_unit() / 2.0, ground_y)
		block.scale = Vector2(1.0, 0.0)
		add_child(block)
		move_child(block, enemies_layer.get_index() + 1)
		_frostbound_rupture_wall_nodes[col] = block

		# Each new block bursts up in turn along the wall.
		var rise: Tween = block.create_tween()
		rise.tween_interval(i * 0.06)
		rise.tween_callback(func() -> void:
			_play_orb_impact(block.position, FROSTBOUND_RUPTURE_FACET_COLOR, 1.0)
		)
		rise.tween_property(block, "scale:y", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Purely cosmetic: Frostbound Rupture's hit on its target - a volley of five
## sharp ice shards flying from `from_node` (Skarn) to `to_node` (the
## target), slightly spread and staggered, each pointed along its own
## flight. When the volley lands: an icy burst, the target's icy-blue
## flash, and a small ice spike (a miniature _build_ice_block()) erupting
## at its feet, which shatters a moment later. The walls themselves are
## _refresh_frostbound_rupture_visuals()'s. Start/end points are captured up
## front, so a target killed by the hit still gets its volley and spike.
## Same layering as _play_double_trouble_effect().
func _play_frostbound_rupture_hit(from_node: Variant, to_node: Variant) -> void:
	if not (from_node is Control) or not (to_node is Control):
		return
	if not is_instance_valid(from_node) or not is_instance_valid(to_node):
		return
	var start: Vector2 = from_node.position + from_node.size / 2.0
	var end: Vector2 = to_node.position + to_node.size / 2.0
	var feet: Vector2 = to_node.position + Vector2(to_node.size.x / 2.0, to_node.size.y * 0.9)
	var target_width: float = to_node.size.x
	var travel: Vector2 = end - start
	var normal: Vector2 = Vector2(-travel.y, travel.x).normalized() if travel.length() > 1.0 else Vector2.UP
	var flight_time: float = clampf(travel.length() / 1200.0, 0.15, 0.35)
	var shard_count: int = 5

	for i in shard_count:
		var shard := Polygon2D.new()
		# A long, thin diamond pointing along +x.
		shard.polygon = PackedVector2Array([Vector2(-11, 0), Vector2(0, -3.5), Vector2(13, 0), Vector2(0, 3.5)])
		shard.color = FROSTBOUND_RUPTURE_FACET_COLOR
		var shard_start: Vector2 = start + normal * randf_range(-10.0, 10.0)
		var shard_end: Vector2 = end + normal * randf_range(-16.0, 16.0)
		shard.position = shard_start
		shard.rotation = (shard_end - shard_start).angle()
		shard.modulate.a = 0.0
		add_child(shard)
		move_child(shard, enemies_layer.get_index() + 1)

		var tween: Tween = shard.create_tween()
		tween.tween_interval(i * 0.04)
		tween.tween_property(shard, "modulate:a", 1.0, 0.03)
		tween.tween_property(shard, "position", shard_end, flight_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		if i == shard_count - 1:
			tween.tween_callback(func() -> void:
				_play_orb_impact(end, FROSTBOUND_RUPTURE_FACET_COLOR, 1.4)
				if is_instance_valid(to_node) and to_node is TextureRect:
					_flash_bounce_hit(to_node, MARK_OF_STILLNESS_FLASH_COLOR)
				_play_ice_spike(feet, target_width)
			)
		tween.tween_property(shard, "modulate:a", 0.0, 0.06)
		tween.tween_callback(shard.queue_free)


## A small ice spike erupting at `feet` under a unit about `unit_width`
## px wide - a miniature Frostbound Rupture block (_build_ice_block()) that
## shoots up, holds for a beat, then shatters. Used for Frostbound Rupture'
## own hit on its target.
func _play_ice_spike(feet: Vector2, unit_width: float) -> void:
	var height: float = get_viewport_rect().size.y / 4.0 * 0.3
	var spike: Node2D = _build_ice_block(unit_width * 0.5, height)
	spike.position = feet
	spike.scale = Vector2(1.0, 0.0)
	add_child(spike)
	move_child(spike, enemies_layer.get_index() + 1)
	var rise: Tween = spike.create_tween()
	rise.tween_property(spike, "scale:y", 1.0, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rise.tween_interval(0.4)
	rise.tween_callback(func() -> void: _shatter_ice_block(spike, height, 1.0))


## One Frostbound Rupture block, `width` x `height` px, drawn from plain shapes
## with its origin at the middle of its base (on the ground): a cluster
## of FROSTBOUND_RUPTURE_CRYSTALS_PER_BLOCK jagged crystals of varied height and
## lean, the tallest in the middle, each a translucent icy body with a
## lighter facet down one side and a darker outline. Same "no art asset"
## approach as _build_hope_of_the_fallen().
func _build_ice_block(width: float, height: float) -> Node2D:
	var block := Node2D.new()
	var count: int = FROSTBOUND_RUPTURE_CRYSTALS_PER_BLOCK
	var crystal_width: float = width / float(count) * 1.5
	for k in range(count):
		# -1..1 across the block; taller toward the middle.
		var across: float = (float(k) + 0.5) / count * 2.0 - 1.0
		var crystal_height: float = height * (1.0 - absf(across) * 0.45) * randf_range(0.85, 1.05)
		var base_x: float = across * (width - crystal_width) / 2.0
		var lean: float = across * crystal_width * 0.35 + randf_range(-4.0, 4.0)
		var half: float = crystal_width / 2.0 * randf_range(0.8, 1.0)

		# A pointed crystal: straight-ish sides, a shoulder, a sharp tip.
		var tip := Vector2(base_x + lean, -crystal_height)
		var left_shoulder := Vector2(base_x - half * 0.9 + lean * 0.7, -crystal_height * 0.72)
		var right_shoulder := Vector2(base_x + half * 0.9 + lean * 0.7, -crystal_height * 0.68)
		var outline_points := PackedVector2Array([
			Vector2(base_x - half, 0.0), left_shoulder, tip, right_shoulder, Vector2(base_x + half, 0.0),
		])

		var body := Polygon2D.new()
		body.polygon = outline_points
		body.color = FROSTBOUND_RUPTURE_BODY_COLOR
		block.add_child(body)

		# The lit face: from the tip down the left shoulder to the base's
		# middle.
		var facet := Polygon2D.new()
		facet.polygon = PackedVector2Array([
			Vector2(base_x - half, 0.0), left_shoulder, tip, Vector2(base_x + lean * 0.2, 0.0),
		])
		facet.color = FROSTBOUND_RUPTURE_FACET_COLOR
		facet.modulate.a = 0.55
		block.add_child(facet)

		var outline := Line2D.new()
		outline.width = 2.0
		outline.default_color = FROSTBOUND_RUPTURE_OUTLINE_COLOR
		outline.joint_mode = Line2D.LINE_JOINT_ROUND
		outline.antialiased = true
		outline.points = outline_points
		block.add_child(outline)

	return block


## A Frostbound Rupture block breaking apart when its wall ends: a burst of ice
## shards (_play_orb_impact(), at `burst_scale`) from its middle while
## the block itself quickly collapses back into the ground and fades.
## `height` is the block's own height (defaults to a full wall block's).
## Safe on a missing/already-freed node.
func _shatter_ice_block(block: Variant, height: float = -1.0, burst_scale: float = 1.8) -> void:
	if not is_instance_valid(block) or not (block is Node2D):
		return
	if height < 0.0:
		height = get_viewport_rect().size.y / 4.0 * FROSTBOUND_RUPTURE_HEIGHT_RATIO
	_play_orb_impact(block.position - Vector2(0.0, height * 0.5), FROSTBOUND_RUPTURE_FACET_COLOR, burst_scale)
	var collapse: Tween = block.create_tween()
	collapse.tween_property(block, "scale", Vector2(1.15, 0.2), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	collapse.parallel().tween_property(block, "modulate:a", 0.0, 0.18)
	collapse.tween_callback(block.queue_free)


## Whether `col` is currently walled off by Frostbound Rupture - checked from
## every PLAIN movement decision in _enemy_turn()/_enemy_hero_turn()
## (flee, "close in", The Hunger Calls's own redirect) so an enemy
## standing in a blocked column can't move at all and one standing
## outside it can't step into one, i.e. can't move past it. A true
## teleport (Undertow) still isn't checked against this - it
## doesn't travel through the columns in between at all, unlike a jump
## (Barbed Lunge, Charge) or a pull (Chainfire), which now ARE stopped
## by a wall in their path on both sides (see _cast_barbed_lunge()/
## _resolve_charge_cast()/_resolve_chainfire_cast() and their own
## _is_column_enemy_frostbound_rupture_blocked() checks for the player's own
## copies, _cast_enemy_barbed_lunge()/_cast_enemy_charge() for the rival's).
func _is_column_frostbound_rupture_blocked(col: int) -> bool:
	return _frostbound_rupture_active and col in _frostbound_rupture_blocked_columns


# ------------------------------------------------------------------
# Skarn's Charge.
# ------------------------------------------------------------------

## Resolves a Charge cast on `target`: moves the hero straight onto
## `target`'s own column - or, if a rival's Frostbound Rupture wall sits
## somewhere in that path, only as far as one column short of it -
## updating his LOGICAL position immediately, same as every other
## action, so anything checked right after (range, _stage_generation,
## etc.) already sees him there - then deals `level_data.damage` and
## stuns it for `level_data.stun_turns` if it survives, same stun
## mechanism Drowned Surge's/Return to the Void's/Winter's Grip's own use.
##
## The hit lands when he crashes into it (see _play_charge()): mana and
## cooldown are spent right away, the turn stays locked while he locks
## on and charges, then the turn ends.
func _resolve_charge_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var start_pos_index: int = _hero_pos_index
	var target_pos_index: int = target["pos_index"]

	# The charge physically carries the hero across every column in
	# between (unlike Undertow's true teleport), so a rival's
	# Frostbound Rupture wall in its path stops it one column short of
	# target_pos_index, same rule Barbed Lunge's own leap and Chainfire's
	# own pull now follow.
	var charge_direction: int = _step_toward(start_pos_index, target_pos_index)
	var landing_pos_index: int = start_pos_index
	while charge_direction != 0 and landing_pos_index != target_pos_index:
		var next_pos: int = landing_pos_index + charge_direction
		if _is_column_enemy_frostbound_rupture_blocked(next_pos):
			break
		landing_pos_index = next_pos
	_hero_pos_index = landing_pos_index

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["charge"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("charge", _skill_cooldowns["charge"])
	_refresh_skill_cooldown_labels()
	_has_acted_this_turn = true
	_update_action_buttons()

	var damage: float = float(level_data.get("damage", 0))
	var start_x: float = hero_image.position.x
	_play_charge(hero_image, target.get("node"), func() -> float:
		# Hero art is drawn facing right by default (see _hero_move()'s own
		# note on art orientation), so charging left mirrors it to face
		# that way. Snapped to where he lands; the animator rushes the art
		# across from where he stood.
		hero_image.flip_h = landing_pos_index < start_pos_index
		hero_image.position.x = _index_to_x(landing_pos_index)
		return start_x - hero_image.position.x
	, func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		if _enemies.any(func(e: Dictionary) -> bool: return is_same(e, target)):
			_deal_fixed_damage_to_enemy(target, damage)
			if target.get("current_hp", 0) > 0:
				target["stun_turns_left"] = int(level_data.get("stun_turns", 1))
			_refresh_bars()
		if _battle_over or _stage_generation != generation_before:
			return
		_mark_turn_used()
	)


## Purely cosmetic: Skarn's Charge from `attacker` (his sprite) at
## `target` (its sprite).
##   1. Lock-on: the whole battlefield dims except the two of them; he
##      snarls with a cold glow and a red ring closes onto his prey.
##   2. The charge: `start` runs - it snaps the attacker to where the
##      charge ends (logically it's there already) and returns how far it
##      moved (old x - new x); the animator then rushes the art across
##      that distance, accelerating (CreatureAnimator.play_charge()).
##   3. Impact: the screen shakes, ice bursts off the target, the target
##      reels - `on_impact` fires (the damage/stun are the caller's) and
##      the dimness lifts.
## If either sprite is already gone the whole thing is skipped straight
## to `start` and `on_impact`, so the caller's turn flow never stalls.
func _play_charge(attacker: Variant, target: Variant, start: Callable, on_impact: Callable) -> void:
	if not is_instance_valid(attacker) or not is_instance_valid(target) or not (attacker is Control) or not (target is Control):
		start.call()
		on_impact.call()
		return
	# Dim everything but the two of them: an overlay over the whole
	# battle, with attacker and target lifted above it.
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.01, 0.03, 0.0)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.size = get_viewport_rect().size * 1.2
	dim.position = -get_viewport_rect().size * 0.1
	dim.z_index = 50
	add_child(dim)
	var lifted: Array = [attacker, target]
	var old_z: Array = []
	for n in lifted:
		old_z.append(n.z_index)
		n.z_index = 51
	var restore := func() -> void:
		for k in lifted.size():
			if is_instance_valid(lifted[k]):
				lifted[k].z_index = old_z[k]

	# The red lock-on ring closing onto the target.
	var reticle := Node2D.new()
	reticle.z_index = 52
	add_child(reticle)
	var centre: Vector2 = target.global_position - global_position + target.size * Vector2(0.5, 0.5)
	var ring_r: float = maxf(target.size.x, target.size.y) * 0.55
	var lock := [0.0]   # 0 = wide and faint, 1 = locked on
	reticle.draw.connect(func() -> void:
		var u: float = lock[0]
		var r: float = lerpf(ring_r * 2.2, ring_r, u)
		var a: float = lerpf(0.2, 0.95, u)
		var spin: float = (1.0 - u) * 1.6
		for q in 4:
			var mid: float = spin + q * PI * 0.5
			reticle.draw_arc(centre, r, mid - 0.45, mid + 0.45, 12, Color(CHARGE_LOCK_COLOR, a), 3.0, true)
			var d := Vector2.from_angle(mid + PI * 0.25)
			reticle.draw_line(centre + d * r * 0.8, centre + d * r * 1.15, Color(CHARGE_LOCK_COLOR, a), 2.5, true)
		reticle.draw_circle(centre, 3.0 + 3.0 * u, Color(CHARGE_LOCK_COLOR, a))
	)
	var attacker_anim := CreatureAnimator.of(attacker)
	if attacker_anim != null:
		attacker_anim.play_cast()
	var target_node: Control = target

	var tw := create_tween()
	tw.tween_property(dim, "color:a", CHARGE_DIM_ALPHA, 0.22)
	tw.parallel().tween_method(func(v: float) -> void:
		lock[0] = v
		reticle.queue_redraw(), 0.0, 1.0, CHARGE_LOCK_ON_TIME * 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(CHARGE_LOCK_ON_TIME * 0.25)
	tw.tween_callback(func() -> void:
		var moved: float = start.call()
		var travel: float = CHARGE_TRAVEL_BASE + CHARGE_TRAVEL_PER_COLUMN * absf(moved) / _grid_unit()
		var anim := CreatureAnimator.of(attacker)
		if anim != null and absf(moved) > 1.0:
			anim.play_charge(moved, travel)
		else:
			travel = 0.12
		var impact := create_tween()
		impact.tween_interval(travel)
		impact.tween_callback(func() -> void:
			reticle.queue_free()
			_shake_screen()
			if is_instance_valid(target_node):
				_play_orb_impact(target_node.global_position - global_position + target_node.size * Vector2(0.5, 0.55), FROSTBOUND_RUPTURE_FACET_COLOR, 1.4)
				var hit := CreatureAnimator.of(target_node)
				if hit != null:
					hit.play_hit(signf(moved))
			on_impact.call()
			var lift := create_tween()
			lift.tween_property(dim, "color:a", 0.0, 0.35)
			lift.tween_callback(func() -> void:
				restore.call()
				dim.queue_free())
		)
	)


# ------------------------------------------------------------------
# Skarn's Bestial Rage.
# ------------------------------------------------------------------

## Activates Bestial Rage: arms this level's own bonus_damage for
## `level_data.duration` turns. Always "succeeds" - no target or range
## requirement to cast it, same as every other self-cast buff.
func _activate_bestial_rage(level_data: Dictionary) -> void:
	_bestial_rage_active = true
	_bestial_rage_bonus_damage = float(level_data.get("bonus_damage", 0))
	_bestial_rage_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_bestial_rage()), same as every
	# other duration-based buff.
	_bestial_rage_duration_pending_start = true
	_set_hero_enlarged(hero_image, true)

	_show_message_over_hero("Bestial Rage!")


## Ticks Bestial Rage's duration down once per End Turn, same timing (and
## same "the casting turn doesn't count" skip) as every other duration-
## based buff.
func _tick_bestial_rage() -> void:
	if not _bestial_rage_active:
		return

	if _bestial_rage_duration_pending_start:
		_bestial_rage_duration_pending_start = false
		return

	_bestial_rage_turns_remaining -= 1
	if _bestial_rage_turns_remaining <= 0:
		_end_bestial_rage()


## Ends Bestial Rage once its duration runs out.
func _end_bestial_rage() -> void:
	_bestial_rage_active = false
	_bestial_rage_bonus_damage = 0.0
	_bestial_rage_turns_remaining = 0
	_bestial_rage_duration_pending_start = false
	_set_hero_enlarged(hero_image, false)

	_show_message_over_hero("Bestial Rage wears off")


# ------------------------------------------------------------------
# Skarn's ultimate, Glacier Breaker.
# ------------------------------------------------------------------

## Resolves a Glacier Breaker cast on `target`: rolls the hero's own
## Attack damage (_roll_hero_damage(), same roll a plain Attack uses)
## and multiplies it by this level's own damage_multiplier, then works
## out how far the knockback actually carries - walking one column at a
## time, away from Skarn's current facing direction (hero_image.flip_h),
## for up to `level_data.knockback` columns, stopping early at the edge
## of the board or at the first column another living, targetable enemy
## already occupies. Coming up short either way ("hits a wall or
## another obstacle") adds 50% more damage to this same hit before it
## lands - the critical-hit-styled number _deal_fixed_damage_to_enemy()
## shows either way (see its own `is_critical` param) is already that
## boosted total.
## Unlike every other targeted skill here, the knockback plays out
## BEFORE damage: `target`'s LOGICAL position updates immediately (same
## as always), but its VISUAL slide (GLACIER_BREAKER_KNOCKBACK_DURATION)
## has to actually finish before _resolve_glacier_breaker_damage() deals
## the hit, checks for death, and stuns it if it survives - so a punch
## that kills still visibly sends its target flying first, instead of
## it just vanishing on the spot. Skips the tween entirely (resolving
## instantly) if the target never actually moved - already pinned
## against something this same turn, so there's nothing to show.
func _resolve_glacier_breaker_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	var multiplier: float = float(level_data.get("damage_multiplier", 1.0))
	var punch_damage: float = _roll_hero_damage() * multiplier

	var knockback_columns: int = int(level_data.get("knockback", 0))
	var direction: int = -1 if hero_image.flip_h else 1
	var pos: int = target["pos_index"]
	var actual_distance: int = 0
	for i in range(knockback_columns):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if not _get_enemy_at(next_pos).is_empty():
			break
		pos = next_pos
		actual_distance += 1

	var hit_wall: bool = actual_distance < knockback_columns
	if hit_wall:
		punch_damage *= 1.5

	if actual_distance > 0 and is_instance_valid(target.get("node")):
		target["pos_index"] = pos
		# Same facing convention as _move_enemy() - hero-fight art
		# faces right natively, every other enemy's faces left.
		var native_faces_right: bool = target["static"].get("is_hero_fight", false)
		target["node"].flip_h = (direction < 0) if native_faces_right else (direction > 0)

		var tween := create_tween()
		tween.tween_property(target["node"], "position:x", _index_to_x(pos), GLACIER_BREAKER_KNOCKBACK_DURATION)
		tween.finished.connect(_resolve_glacier_breaker_damage.bind(target, punch_damage, hit_wall, level_data, generation_before))
	else:
		_resolve_glacier_breaker_damage(target, punch_damage, hit_wall, level_data, generation_before)


## Second half of a Glacier Breaker cast, deferred until the knockback
## slide (see _resolve_glacier_breaker_cast()) has actually finished
## playing: deals the punch's own damage, shows "Wall hit!" if it fell
## short of its full knockback distance, and - if the target survived -
## stuns it in place for `level_data.stun_turns`, the same shared
## stun_turns_left field Drowned Surge's/Return to the Void's/Winter's Grip's/Charge's
## own stun already uses. Bails out first if a stage/hero-fight
## transition already happened while the slide was playing - the same
## generation guard every other targeted cast checks before spending
## anything.
func _resolve_glacier_breaker_damage(target: Dictionary, punch_damage: float, hit_wall: bool, level_data: Dictionary, generation_before: int) -> void:
	if _stage_generation != generation_before:
		return

	_deal_fixed_damage_to_enemy(target, punch_damage, true)

	if hit_wall:
		_show_message_over_hero("Wall hit!")

	if target.get("current_hp", 0) > 0:
		target["stun_turns_left"] = int(level_data.get("stun_turns", 1))

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["glacier_breaker"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("glacier_breaker", _skill_cooldowns["glacier_breaker"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


# ------------------------------------------------------------------
# The Rootmother's Sanguine Bloom.
# ------------------------------------------------------------------

## Resolves a Sanguine Bloom cast on `target`: no immediate damage, just
## arms this level's own dot_damage/heal_per_turn onto `target`'s own
## dedicated sanguine_bloom_dot_turns_left counter - a separate pair of
## fields from Mark of Stillness's/The Hollow Cold's/Return to the Void's/Winter's Grip's own
## DoTs, same "never silently shares or clobbers another skill's
## counters on the same target" reasoning those already follow - ticked
## once per turn, at the start of that enemy's own turn, by
## _tick_enemy_turn_start_effects(), healing the hero the same amount
## it damages the target.
func _resolve_sanguine_bloom_cast(target: Dictionary, level_data: Dictionary) -> void:
	var generation_before: int = _stage_generation

	target["sanguine_bloom_dot_damage"] = float(level_data.get("dot_damage", 0))
	target["sanguine_bloom_heal_per_turn"] = float(level_data.get("heal_per_turn", 0))
	target["sanguine_bloom_dot_turns_left"] = int(level_data.get("duration", 0))

	# The seed is flung from whichever of her hands faces the target, and
	# takes root in it (see SanguineBloomFX).
	var target_node: Variant = target.get("node")
	if target_node is Control and is_instance_valid(target_node):
		var side: float = signf((target_node.global_position.x + target_node.size.x * 0.5) - (hero_image.global_position.x + hero_image.size.x * 0.5))
		var hand: Vector2 = hero_image.global_position + hero_image.size * Vector2(0.5 + 0.36 * (side if side != 0.0 else 1.0), 0.5)
		SanguineBloomFX.plant(_fx_layer, hand, target_node)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["sanguine_bloom"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("sanguine_bloom", _skill_cooldowns["sanguine_bloom"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()



# ------------------------------------------------------------------
# The Rootmother's Woven Flesh.
# ------------------------------------------------------------------

## Activates Woven Flesh: arms this level's own bonus_armor/
## bonus_hp_regen for `level_data.duration` turns. Always "succeeds" -
## cast on the hero himself, no target or range requirement, same as
## every other self-cast buff.
func _activate_woven_flesh(level_data: Dictionary) -> void:
	_woven_flesh_active = true
	_woven_flesh_bonus_armor = float(level_data.get("bonus_armor", 0))
	# Per-turn healing is a share of max HP (so it keeps pace with Strength's
	# own passive regen), fixed at cast time; a flat bonus_hp_regen still adds on.
	_woven_flesh_bonus_hp_regen = float(level_data.get("bonus_hp_regen", 0)) + float(level_data.get("bonus_hp_regen_pct", 0.0)) * _hero_max_hp()
	_woven_flesh_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_woven_flesh()), same as
	# every other duration-based buff.
	_woven_flesh_duration_pending_start = true
	WovenFleshFX.set_on(hero_image, true)

	_show_message_over_hero("Woven Flesh!")


## Ticks Woven Flesh's duration down once per End Turn, same timing
## (and same "the casting turn doesn't count" skip) as every other
## duration-based buff - healing the hero for this level's own
## bonus_hp_regen, on top of his baseline passive regen
## (_apply_passive_hero_regen()), on every tick that actually counts
## against the duration.
func _tick_woven_flesh() -> void:
	if not _woven_flesh_active:
		return

	if _woven_flesh_duration_pending_start:
		_woven_flesh_duration_pending_start = false
		return

	heal(_woven_flesh_bonus_hp_regen)
	WovenFleshFX.pulse_on(hero_image)
	_woven_flesh_turns_remaining -= 1
	if _woven_flesh_turns_remaining <= 0:
		_end_woven_flesh()


## Ends Woven Flesh once its duration runs out.
func _end_woven_flesh() -> void:
	_woven_flesh_active = false
	_woven_flesh_bonus_armor = 0.0
	_woven_flesh_bonus_hp_regen = 0.0
	_woven_flesh_turns_remaining = 0
	_woven_flesh_duration_pending_start = false
	WovenFleshFX.set_on(hero_image, false)

	_show_message_over_hero("Woven Flesh wears off")


# ------------------------------------------------------------------
# Cinder's Kindled Resolve (passive - see the field comment above
# _kindled_resolve_stack_turns for the overall shape).
# ------------------------------------------------------------------

## Kindled Resolve's level data for whatever level the player has it at
## right now - {} if it isn't learned at all (level 0) or the current
## hero isn't Cinder, the same "empty means locked" convention every
## other auto-triggered skill's own _get_*_level_data() helper uses.
func _get_kindled_resolve_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("kindled_resolve")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "kindled_resolve":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Kindled Resolve's current total armor bonus - this level's own
## bonus_armor_per_stack times however many stacks are currently up.
## Folded into _hero_armor(). A no-op (0.0) while the skill isn't
## learned or no stacks are up.
func _kindled_resolve_bonus_armor() -> float:
	var level_data: Dictionary = _get_kindled_resolve_level_data()
	if level_data.is_empty():
		return 0.0
	return _kindled_resolve_stack_turns.size() * float(level_data.get("bonus_armor_per_stack", 0.0))


## Called from apply_damage() every time a hit actually lands on the
## hero, regardless of source (Attack, skill nuke, DoT tick - anything
## routed through apply_damage()). Adds one stack with this level's own
## full duration; if that would exceed max_stacks, the oldest stack
## (soonest to expire) is dropped first so the count never exceeds the
## cap. A no-op while the skill isn't learned.
func _apply_kindled_resolve_stack() -> void:
	var level_data: Dictionary = _get_kindled_resolve_level_data()
	if level_data.is_empty():
		return

	var max_stacks: int = int(level_data.get("max_stacks", 0))
	if _kindled_resolve_stack_turns.size() >= max_stacks:
		_kindled_resolve_stack_turns.pop_front()
	_kindled_resolve_stack_turns.append(int(level_data.get("duration", 0)))


## Keeps Kindled Resolve's embers (KindledEmbersFX) in step with the
## current stacks - the player's Cinder and a rival Cinder - growing with
## every new one and dying away as each runs out. Called from
## _refresh_bars()/_refresh_enemy_overhead_labels(), so it just follows
## current state.
func _refresh_kindled_embers() -> void:
	KindledEmbersFX.sync(hero_image, _kindled_resolve_stack_turns.size(),
			int(_get_kindled_resolve_level_data().get("max_stacks", 1)))
	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty():
		KindledEmbersFX.sync(boss.get("node"), _enemy_kindled_resolve_stack_turns.size(),
				int(_get_enemy_kindled_resolve_level_data().get("max_stacks", 1)))


## Ticks every active stack's own remaining-turns counter down by one,
## once per End Turn, dropping any that reach zero - independently of
## each other, unlike every other duration-based buff in this file
## which only ever tracks one shared timer. A no-op while no stacks are
## up (including while the skill isn't learned, since then none can
## ever have been added).
func _tick_kindled_resolve_stacks() -> void:
	for i in range(_kindled_resolve_stack_turns.size()):
		_kindled_resolve_stack_turns[i] -= 1
	_kindled_resolve_stack_turns = _kindled_resolve_stack_turns.filter(func(turns_left): return turns_left > 0)


## Heals this level's own bonus_hp_regen_per_stack times however many
## stacks are currently up, once at the start of every hero turn - same
## timing/stacking relationship (on top of, not instead of) as Arcane
## Aura's and the baseline passive regen. A no-op while the skill isn't
## learned or no stacks are up.
func _apply_kindled_resolve_regen() -> void:
	var level_data: Dictionary = _get_kindled_resolve_level_data()
	if level_data.is_empty() or _kindled_resolve_stack_turns.is_empty():
		return

	heal(_kindled_resolve_stack_turns.size() * float(level_data.get("bonus_hp_regen_per_stack", 0.0)))


# ------------------------------------------------------------------
# The Rootmother's ultimate, Mother's Grasp.
# ------------------------------------------------------------------

## Activates Mother's Grasp: every living, targetable enemy within
## `level_data.radius` columns of the hero's CURRENT position gets
## rooted (target["root_turns_left"], the same shared per-enemy field
## Thornbind's/Rootveil's/Frostbound Rupture'/The Hunger Calls's own root/
## freeze effects already use - it can still attack and cast skills
## while rooted, same as any other rooted enemy) for `level_data.
## root_duration` turns, and armed with that same level's own DoT
## (target["mothers_grasp_dot_damage"]/["mothers_grasp_dot_turns_left"], a
## dedicated pair of fields so it never clobbers another skill's DoT on
## the same enemy) for the same duration - ticked, at the start of each
## enemy's own turn, by _tick_enemy_turn_start_effects(). Always
## "succeeds" - cast on the hero himself, no target or range
## requirement, same as every other self-cast buff/AoE.
func _activate_mothers_grasp(level_data: Dictionary) -> void:
	var dot_damage: float = float(level_data.get("dot_damage", 0))
	var root_duration: int = int(level_data.get("root_duration", 0))
	var radius: int = int(level_data.get("radius", 0))

	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			enemy["root_turns_left"] = root_duration
			enemy["mothers_grasp_dot_damage"] = dot_damage
			enemy["mothers_grasp_dot_turns_left"] = root_duration

	# A rival's own guard (The Last Empress's Imperial Guard) has no root/DoT
	# of its own to carry the way a regular enemy does above - just a
	# one-time hit for whatever's caught in the burst, centered on the
	# hero's own position, same as the check above.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, radius, dot_damage)
	_play_mothers_grasp_slam(hero_image)
	_refresh_mothers_grasp_roots()

	_show_message_over_hero("Mother's Grasp!")


## Resolves a Whisper of the Veil cast on Morvael himself: pays `level_data.
## hp_cost` straight off current_hp - no armor mitigation, same as the
## Elderwild Companion's death penalty (_apply_bear_death_penalty()) - then
## heals for `level_data.heal`, which is always more than the HP cost,
## for a net gain. If the hero doesn't have enough HP to cover the
## cost, nothing happens at all: no HP lost, no heal, and - like a
## failed Barbed Lunge/Abyssal Spasm/Thornbind target search - no mana, cooldown,
## or turn spent either, so the player can simply try something else.
func _resolve_whisper_of_the_veil_self_cast(level_data: Dictionary) -> void:
	var hp_cost: float = float(level_data.get("hp_cost", 0))
	var current_hp: float = float(_recruited.get("current_hp", 0))
	if current_hp < hp_cost:
		_cancel_targeting()
		_show_message_over_hero("Not enough HP")
		return

	_cancel_targeting()
	var generation_before: int = _stage_generation

	PlayerManager.damage_hero(hp_cost)
	heal(float(level_data.get("heal", 0)))
	_play_whisper_of_the_veil_effect(hero_image, hero_image)

	var mana_cost: float = float(level_data.get("mana_cost", 0))
	spend_mana(mana_cost)
	_skill_cooldowns["whisper_of_the_veil"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("whisper_of_the_veil", _skill_cooldowns["whisper_of_the_veil"])
	_refresh_skill_cooldown_labels()

	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Puts Thornbind's root/silence/damage-over-time state onto `target`:
##   - "root_turns_left": can't move while > 0 (checked in
##     _enemy_turn()'s movement fallback and flee logic) - it can
##     still attack normally if something's already in its range.
##   - "silence_turns_left": blocks a hero-fight boss's own skill casts
##     while it's > 0 (see _is_enemy_silenced()/_enemy_hero_turn()) -
##     the same field Mark of the Mist's own silence writes onto this
##     target (_apply_mark_of_the_mist_stack()). Regular creeps never
##     cast skills in the first place, so this only ever matters
##     against a hero-fight boss.
##   - "thornbind_dot_damage"/"thornbind_dot_turns_left": ticked once per
##     turn by _tick_enemy_turn_start_effects(), dealing that much
##     damage (through normal armor mitigation) for that many turns.
## Recasting Thornbind on an already-rooted target simply overwrites
## its counters with this cast's fresh values rather than stacking.
func _apply_root(target: Dictionary, level_data: Dictionary) -> void:
	target["root_turns_left"] = int(level_data.get("root_turns", 0))
	target["silence_turns_left"] = int(level_data.get("silence_turns", 0))
	target["thornbind_dot_damage"] = float(level_data.get("dot_damage", 0))
	target["thornbind_dot_turns_left"] = int(level_data.get("dot_duration", 0))


## Applies every "start of its own turn" damage-over-time currently on
## `enemy`, all in one pass, right before anything else about its turn
## is decided (stun included - see the call site in _enemy_turn()/
## _enemy_hero_turn()): Thornbind's own DoT, Mark of the Mist's DoT
## (ending the curse once its own duration runs out - stack decay for a
## NOT-yet-activated curse is a separate, turn-count-based check handled
## by _tick_mark_of_the_mist_effects() instead, since it isn't a DoT),
## Mark of Stillness's/The Hollow Cold's/Winter's Grip's/Sanguine Bloom's own DoTs (also healing the hero back), Return to the Void's DoT plus its own
## execute-threshold check, and The Rootmother's Mother's Grasp DoT -
## each a dedicated pair of fields so none of them ever clobber each
## other on the same enemy. Every damage instance is still mitigated by
## the enemy's own armor, via _deal_fixed_damage_to_enemy(). Bails out
## the moment a hit ends the battle (last enemy dies, stage clears,
## etc.) - the caller then knows to stop processing this enemy (and the
## turn) immediately, same reasoning the old per-skill tick functions
## this replaces used to need individually. Also stops early (without
## ending the battle) the moment `enemy` itself dies partway through,
## since there's nothing left on it worth ticking further that turn.
## Root/silence (Thornbind's own counters, also reused by Rootveil's
## root) are deliberately NOT decremented here, unlike everything else in
## this function - unlike a DoT, they GATE a decision later in this same
## turn (_is_enemy_rooted()/_is_enemy_silenced(), checked from _enemy_
## turn()/_enemy_hero_turn() after this call returns), so decrementing
## them up front would burn off one full turn's worth of root/silence
## before it ever actually blocked anything - a 1-turn root would never
## stop a single move. They're decremented instead at the point they're
## actually consumed, the same "check with the CURRENT value, use it,
## decrement after" pattern stun_turns_left already uses in _enemy_turn().
func _tick_enemy_turn_start_effects(enemy: Dictionary) -> void:
	# Three Cheers's armor shred and Dreadlure's Deathlight Lure both
	# write "armor_reduction" (Deathlight Lure also "deathlight_lure_
	# bonus_pct", see _deal_fixed_damage_to_enemy()'s own read of it) -
	# cast during the PLAYER's turn, but only ever ticked here (the
	# start of THIS enemy's own turn), so the round either was cast in
	# is never counted against duration for free, no separate "pending
	# start" flag needed (see _resolve_three_cheers_cast()'s own
	# comment). Both share the one counter/expiry, same "reapplying
	# overwrites the timer" convention every other refreshable debuff in
	# this file already uses - a rare edge case if both ever land on the
	# same enemy at once, not worth a second counter for.
	if enemy.get("armor_reduction_turns_left", 0) > 0:
		enemy["armor_reduction_turns_left"] -= 1
		if enemy.get("armor_reduction_turns_left", 0) <= 0:
			enemy["armor_reduction"] = 0.0
			enemy["deathlight_lure_bonus_pct"] = 0.0

	# Kiss the Wastes' burn: re-armed (both damage and turns_left) by
	# every shot that catches this enemy, main target or splash (see
	# _fire_kiss_the_wastes_shot()) - so "the DoT duration starts from
	# the first hit" falls out for free here too, same reasoning the armor
	# shred block above already spells out.
	if enemy.get("kiss_burn_dot_turns_left", 0) > 0:
		enemy["kiss_burn_dot_turns_left"] -= 1
		var kiss_burn_dot: float = float(enemy.get("kiss_burn_dot_damage", 0))
		if kiss_burn_dot > 0.0:
			_deal_fixed_damage_to_enemy(enemy, kiss_burn_dot, false, false)
			if _battle_over or enemy.get("current_hp", 0) <= 0:
				return

	if enemy.get("thornbind_dot_turns_left", 0) > 0:
		enemy["thornbind_dot_turns_left"] -= 1
		var thornbind_dot: float = float(enemy.get("thornbind_dot_damage", 0))
		if thornbind_dot > 0.0:
			_deal_fixed_damage_to_enemy(enemy, thornbind_dot, false, false)
			if _battle_over or enemy.get("current_hp", 0) <= 0:
				return

	if enemy.get("curse_active", false):
		if enemy.get("curse_dot_turns_left", 0) > 0:
			enemy["curse_dot_turns_left"] -= 1
			var curse_dot: float = float(enemy.get("curse_dot_damage", 0))
			if curse_dot > 0.0:
				_deal_fixed_damage_to_enemy(enemy, curse_dot, false, false)
				if _battle_over or enemy.get("current_hp", 0) <= 0:
					return
		if enemy.get("curse_dot_turns_left", 0) <= 0:
			enemy["curse_active"] = false
			enemy["curse_dot_damage"] = 0.0

	if enemy.get("mark_of_stillness_dot_turns_left", 0) > 0:
		enemy["mark_of_stillness_dot_turns_left"] -= 1
		var mark_of_stillness_dot: float = float(enemy.get("mark_of_stillness_dot_damage", 0))
		if mark_of_stillness_dot > 0.0:
			_deal_fixed_damage_to_enemy(enemy, mark_of_stillness_dot, false, false)
			if _battle_over or enemy.get("current_hp", 0) <= 0:
				return

	if enemy.get("the_hollow_cold_dot_turns_left", 0) > 0:
		enemy["the_hollow_cold_dot_turns_left"] -= 1
		var the_hollow_cold_dot: float = float(enemy.get("the_hollow_cold_dot_damage", 0))
		if the_hollow_cold_dot > 0.0:
			_deal_fixed_damage_to_enemy(enemy, the_hollow_cold_dot, false, false)
			if _battle_over or enemy.get("current_hp", 0) <= 0:
				return

	if enemy.get("return_to_the_void_dot_turns_left", 0) > 0:
		enemy["return_to_the_void_dot_turns_left"] -= 1
		var return_to_the_void_dot: float = float(enemy.get("return_to_the_void_dot_damage", 0))
		if return_to_the_void_dot > 0.0:
			_deal_fixed_damage_to_enemy(enemy, return_to_the_void_dot, false, false)
			if _battle_over or enemy.get("current_hp", 0) <= 0:
				return

		if enemy.get("current_hp", 0) > 0:
			var execute_pct: float = float(enemy.get("return_to_the_void_execute_pct", 0.0))
			var max_hp: float = float(enemy["static"].get("hp", 1))
			if execute_pct > 0.0 and enemy["current_hp"] <= max_hp * execute_pct:
				_kill_enemy(enemy, true)
				if _battle_over:
					return

		if enemy.get("return_to_the_void_dot_turns_left", 0) <= 0:
			enemy["return_to_the_void_execute_pct"] = 0.0

		if enemy.get("current_hp", 0) <= 0:
			return

	if enemy.get("winters_grip_dot_turns_left", 0) > 0:
		enemy["winters_grip_dot_turns_left"] -= 1
		var winters_grip_dot: float = float(enemy.get("winters_grip_dot_damage", 0))
		if winters_grip_dot > 0.0:
			_deal_fixed_damage_to_enemy(enemy, winters_grip_dot, false, false)
			if _battle_over or enemy.get("current_hp", 0) <= 0:
				return

	if enemy.get("sanguine_bloom_dot_turns_left", 0) > 0:
		enemy["sanguine_bloom_dot_turns_left"] -= 1
		# Captured before the tick - a kill frees the node.
		var seeded_node: Variant = enemy.get("node")
		var sanguine_bloom_dot: float = float(enemy.get("sanguine_bloom_dot_damage", 0))
		if sanguine_bloom_dot > 0.0:
			_deal_fixed_damage_to_enemy(enemy, sanguine_bloom_dot, false, false)
			if _battle_over:
				return
		# The bloom flares as it drains (right as the red motes fly to
		# her), and wilts once this was its last tick.
		if enemy.get("sanguine_bloom_dot_turns_left", 0) <= 0:
			SanguineBloomFX.wither_on(seeded_node)
		else:
			SanguineBloomFX.pulse_on(seeded_node)
		var sanguine_bloom_heal: float = float(enemy.get("sanguine_bloom_heal_per_turn", 0))
		if sanguine_bloom_heal > 0.0:
			heal(sanguine_bloom_heal)
			_play_lifesteal_effect(seeded_node, hero_image)
		if enemy.get("current_hp", 0) <= 0:
			return

	if enemy.get("mothers_grasp_dot_turns_left", 0) > 0:
		enemy["mothers_grasp_dot_turns_left"] -= 1
		var mothers_grasp_dot: float = float(enemy.get("mothers_grasp_dot_damage", 0))
		if mothers_grasp_dot > 0.0:
			# Captured before the tick - a kill frees the node.
			var grasped_node: Variant = enemy.get("node")
			_deal_fixed_damage_to_enemy(enemy, mothers_grasp_dot, false, false)
			MothersGraspFX.pulse_on(grasped_node)


## The player-side mirror of _tick_enemy_turn_start_effects(): every
## "start of the player's own turn" duration counter and damage-over-
## time a rival hero could have inflicted on him, ticked in one pass
## against the single-player battle-local vars instead of a per-enemy
## Dictionary - Thornbind's root/silence counters and DoT, Mark of the
## Mist's DoT (stack decay lives in _tick_enemy_mark_of_the_mist_
## effects() instead, same "not a DoT" reasoning as the enemy-side
## version), Mark of Stillness's/The Hollow Cold's/Winter's Grip's own DoTs, Return to the Void's
## DoT plus its own execute-threshold check, The Rootmother's Sanguine
## Bloom (unlike every other DoT here, its own healing half goes to the
## CASTER - the rival - not the player, so this heals the boss directly
## via _get_hero_fight_boss() each tick instead of calling heal()), and
## Mother's Grasp's own DoT (its root shares _player_root_turns_left above,
## the same field Thornbind's own root already ticks down), Raze's
## Three Cheers armor reduction (a plain countdown, zeroing the
## reduction itself once it runs out - no damage of its own to deal,
## just folded into _hero_armor() for as long as it's up), and Kiss the Wastes
## own burn DoT. Called once, right where the player's own new
## turn opens in _end_turn() - before he gets to act. Unlike the
## enemy-side version, nothing here needs to bail out mid-function on a
## kill: apply_damage() never frees nodes or changes scenes the way
## killing an enemy can, so _end_turn() just checks the hero's HP once,
## right after calling this.
func _tick_player_turn_start_effects() -> void:
	if _player_root_turns_left > 0:
		_player_root_turns_left -= 1
	if _player_silence_turns_left > 0:
		_player_silence_turns_left -= 1

	if _player_thornbind_dot_turns_left > 0:
		_player_thornbind_dot_turns_left -= 1
		if _player_thornbind_dot_damage > 0.0:
			apply_damage(_player_thornbind_dot_damage)

	if _player_curse_active:
		if _player_curse_dot_turns_left > 0:
			_player_curse_dot_turns_left -= 1
			if _player_curse_dot_damage > 0.0:
				apply_damage(_player_curse_dot_damage)
		if _player_curse_dot_turns_left <= 0:
			_player_curse_active = false
			_player_curse_dot_damage = 0.0

	if _player_mark_of_stillness_dot_turns_left > 0:
		_player_mark_of_stillness_dot_turns_left -= 1
		if _player_mark_of_stillness_dot_damage > 0.0:
			apply_damage(_player_mark_of_stillness_dot_damage)

	if _player_the_hollow_cold_dot_turns_left > 0:
		_player_the_hollow_cold_dot_turns_left -= 1
		if _player_the_hollow_cold_dot_damage > 0.0:
			apply_damage(_player_the_hollow_cold_dot_damage)
	# His guards caught in the same vortex tick right here too,
	# independently of whether the hero himself still is - and so does
	# every DoT a rival has put on his Elderwild Companion.
	_tick_player_allies_the_hollow_cold()
	_tick_hollow_cold_tears(true)
	_tick_bear_turn_start_effects()

	if _player_return_to_the_void_dot_turns_left > 0:
		_player_return_to_the_void_dot_turns_left -= 1
		if _player_return_to_the_void_dot_damage > 0.0:
			apply_damage(_player_return_to_the_void_dot_damage)

		if _recruited.get("current_hp", 0) > 0 and _player_return_to_the_void_execute_pct > 0.0:
			var max_hp: float = _hero_max_hp()
			if max_hp > 0.0 and float(_recruited.get("current_hp", 0)) <= max_hp * _player_return_to_the_void_execute_pct:
				PlayerManager.damage_hero(float(_recruited.get("current_hp", 0)))
				_refresh_bars()

		if _player_return_to_the_void_dot_turns_left <= 0:
			_player_return_to_the_void_execute_pct = 0.0

	if _player_winters_grip_dot_turns_left > 0:
		_player_winters_grip_dot_turns_left -= 1
		if _player_winters_grip_dot_damage > 0.0:
			apply_damage(_player_winters_grip_dot_damage)

	if _player_sanguine_bloom_dot_turns_left > 0:
		_player_sanguine_bloom_dot_turns_left -= 1
		if _player_sanguine_bloom_dot_damage > 0.0:
			apply_damage(_player_sanguine_bloom_dot_damage)
		# Unlike every other DoT above, the healing half goes to the
		# CASTER (the rival), not the player - mirrors the player's own
		# _resolve_sanguine_bloom_cast()/_tick_enemy_turn_start_effects()
		# ("sanguine_bloom" case), just healing the boss directly here
		# instead of the player.
		if _player_sanguine_bloom_heal_per_turn > 0.0:
			var sanguine_bloom_caster: Dictionary = _get_hero_fight_boss()
			if not sanguine_bloom_caster.is_empty():
				var caster_max_hp: float = _enemy_hero_effective_max_hp(sanguine_bloom_caster)
				sanguine_bloom_caster["current_hp"] = minf(caster_max_hp, float(sanguine_bloom_caster.get("current_hp", 0.0)) + _player_sanguine_bloom_heal_per_turn)
				_play_lifesteal_effect(hero_image, sanguine_bloom_caster.get("node"))

	if _player_mothers_grasp_dot_turns_left > 0:
		_player_mothers_grasp_dot_turns_left -= 1
		if _player_mothers_grasp_dot_damage > 0.0:
			apply_damage(_player_mothers_grasp_dot_damage)
			MothersGraspFX.pulse_on(hero_image)

	if _player_armor_reduction_turns_left > 0:
		_player_armor_reduction_turns_left -= 1
		if _player_armor_reduction_turns_left <= 0:
			_player_armor_reduction = 0.0
			_player_deathlight_lure_bonus_pct = 0.0

	if _player_kiss_burn_dot_turns_left > 0:
		_player_kiss_burn_dot_turns_left -= 1
		if _player_kiss_burn_dot_damage > 0.0:
			apply_damage(_player_kiss_burn_dot_damage)


## Whether `enemy` is currently rooted by Thornbind and therefore can't
## move (it can still attack normally if something's already in
## range) - checked from _enemy_turn()'s flee/movement-fallback logic.
func _is_enemy_rooted(enemy: Dictionary) -> bool:
	return enemy.get("root_turns_left", 0) > 0


## Whether `enemy` is currently silenced - by Thornbind or Mark of the
## Mist, both of which write the same `silence_turns_left` field
## (see _apply_root()/_apply_mark_of_the_mist_stack()) - and therefore
## can't cast a skill this turn. Checked from _enemy_hero_turn(), the
## only enemy AI that ever casts skills in the first place.
func _is_enemy_silenced(enemy: Dictionary) -> bool:
	return enemy.get("silence_turns_left", 0) > 0


## Activates Leeching Hunger: arms the next `level_data.attacks` melee
## hits to each steal 1 point of their target's main stat, for
## `level_data.duration` turns. Always "succeeds" (there's no target
## or range requirement to activate it, unlike Barbed Lunge/Abyssal Spasm) - it
## just arms the effect for upcoming attacks. Recasting while a
## previous activation is still running first ends it (as if its duration
## had just run out) so the two instances' durations/attack counts never
## get mixed together.
func _activate_leeching_hunger(level_data: Dictionary) -> void:
	if _leeching_hunger_active:
		_end_leeching_hunger()

	_leeching_hunger_active = true
	_leeching_hunger_attacks_remaining = int(level_data.get("attacks", 0))
	_leeching_hunger_lifesteal_pct = float(level_data.get("lifesteal_pct", 0.0))
	_leeching_hunger_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_leeching_hunger()).
	_leeching_hunger_duration_pending_start = true


## Called right after a melee Attack lands (see _apply_hero_attack()), with
## the damage it dealt after armor. If Leeching Hunger is active and still
## has hits banked, heals Veyrik for its lifesteal share of that damage and
## spends one of the banked hits.
func _apply_leeching_hunger_steal(target: Dictionary, mitigated_damage: float) -> void:
	if not _leeching_hunger_active or _leeching_hunger_attacks_remaining <= 0:
		return
	if mitigated_damage <= 0.0:
		return

	_leeching_hunger_attacks_remaining -= 1
	heal(mitigated_damage * _leeching_hunger_lifesteal_pct)
	_play_drain_effect(target.get("node"), hero_image, LEECHING_HUNGER_MOTE_COLOR)
	if _leeching_hunger_attacks_remaining <= 0:
		_end_leeching_hunger()


## Purely cosmetic: a short stream of small motes drifting from
## `from_node` (whoever was just drained) to `to_node` (whoever did the
## draining), each along its own slightly-arced path and staggered so
## they read as a flow rather than a single blob, in `mote_color`. Used
## by Leeching Hunger's steal (LEECHING_HUNGER_MOTE_COLOR) and Wildbond's
## lifesteal (LIFESTEAL_MOTE_COLOR, via _play_lifesteal_effect()), each from both the player's side
## and the rival's - the stat/HP has already moved by the time this
## plays; it never gates on this. Individual tweened ColorRects rather than
## CPUParticles2D (see _play_double_trouble_effect()) since every mote has
## to land on a specific moving-free target point, not just spray out.
func _play_drain_effect(from_node: Variant, to_node: Variant, mote_color: Color) -> void:
	if not (from_node is Control) or not (to_node is Control):
		return
	if not is_instance_valid(from_node) or not is_instance_valid(to_node):
		return

	var start: Vector2 = from_node.position + from_node.size / 2.0
	var end: Vector2 = to_node.position + to_node.size / 2.0
	var travel: Vector2 = end - start
	# Perpendicular to the flight line - each mote's arc bulges along
	# this by a random amount, up or down.
	var normal: Vector2 = Vector2(-travel.y, travel.x).normalized() if travel.length() > 0.001 else Vector2.UP
	var arc_height: float = maxf(24.0, travel.length() * 0.25)

	var mote_count: int = 14
	var flight_time: float = 0.55
	var stagger: float = 0.025
	var mote_size: float = 7.0

	for i in mote_count:
		var mote := ColorRect.new()
		mote.color = mote_color
		mote.size = Vector2(mote_size, mote_size)
		mote.pivot_offset = mote.size / 2.0
		mote.rotation = PI / 4.0
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.modulate.a = 0.0
		var jitter: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * from_node.size * 0.2
		var mote_start: Vector2 = start + jitter
		var control_point: Vector2 = (mote_start + end) / 2.0 + normal * arc_height * randf_range(-1.0, 1.0)
		mote.position = mote_start - mote.pivot_offset
		add_child(mote)
		# Same layering as _play_double_trouble_effect() - at the hero/enemy
		# layer, not on top of every UI panel.
		move_child(mote, enemies_layer.get_index() + 1)

		var tween: Tween = mote.create_tween()
		tween.tween_interval(i * stagger)
		tween.tween_property(mote, "modulate:a", 1.0, 0.08)
		tween.parallel().tween_method(
			func(t: float) -> void:
				var a: Vector2 = mote_start.lerp(control_point, t)
				var b: Vector2 = control_point.lerp(end, t)
				mote.position = a.lerp(b, t) - mote.pivot_offset,
			0.0, 1.0, flight_time
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		# Shrink/fade on arrival, as if absorbed.
		tween.tween_property(mote, "scale", Vector2(0.2, 0.2), 0.12)
		tween.parallel().tween_property(mote, "modulate:a", 0.0, 0.12)
		tween.tween_callback(mote.queue_free)


## Ticks Leeching Hunger's duration down once per End Turn, same timing
## as _tick_skill_cooldowns() - except the very first call after the
## skill is cast is skipped (see _leeching_hunger_duration_pending_start)
## so the casting turn itself doesn't count against the duration.
func _tick_leeching_hunger() -> void:
	if not _leeching_hunger_active:
		return

	if _leeching_hunger_duration_pending_start:
		_leeching_hunger_duration_pending_start = false
		return

	_leeching_hunger_turns_remaining -= 1
	if _leeching_hunger_turns_remaining <= 0:
		_end_leeching_hunger()


## Leeching Hunger has run its course - out of hits, or out of turns.
func _end_leeching_hunger() -> void:
	_leeching_hunger_active = false
	_leeching_hunger_attacks_remaining = 0
	_leeching_hunger_lifesteal_pct = 0.0
	_leeching_hunger_turns_remaining = 0
	_leeching_hunger_duration_pending_start = false

	_show_message_over_hero("Leeching Hunger wore off")


## Whether `enemy_ref` (one of _enemies' own dictionaries) is still part of the current
## fight - false once it's died, or once a stage/hero-fight transition
## has cleared and replaced the whole _enemies roster.
func _is_enemy_still_active(enemy_ref: Dictionary) -> bool:
	for enemy in _enemies:
		if enemy == enemy_ref:
			return true
	return false


# ------------------------------------------------------------------
# The Primordial Hunger's Frostbound Fangs.
# ------------------------------------------------------------------

## Activates Frostbound Fangs: arms this level's own bonus_damage/bonus_range
## for the next `level_data.attacks` plain Attacks, or `level_data.
## duration` turns - whichever runs out first (see
## _apply_frostbound_fangs_attack()/_tick_frostbound_fangs()). Always "succeeds" -
## no target or range requirement to cast it, same as Leeching Hunger/
## Depthsveil.
func _activate_frostbound_fangs(level_data: Dictionary) -> void:
	_frostbound_fangs_active = true
	_frostbound_fangs_bonus_damage = float(level_data.get("bonus_damage", 0))
	_frostbound_fangs_bonus_range = int(level_data.get("bonus_range", 0))
	_frostbound_fangs_attacks_remaining = int(level_data.get("attacks", 0))
	_frostbound_fangs_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_frostbound_fangs()), same as
	# every other duration-based buff.
	_frostbound_fangs_duration_pending_start = true
	_set_hero_enlarged(hero_image, true)


## Called right after a plain Attack lands (see _apply_hero_attack()).
## Spends one of Frostbound Fangs' banked attacks, if any are left, and ends
## the whole effect right there once the last one is used - the other
## half of the attacks-or-duration race _tick_frostbound_fangs() runs on the
## turn-count side.
func _apply_frostbound_fangs_attack() -> void:
	if not _frostbound_fangs_active or _frostbound_fangs_attacks_remaining <= 0:
		return

	_frostbound_fangs_attacks_remaining -= 1
	if _frostbound_fangs_attacks_remaining <= 0:
		_end_frostbound_fangs()


## Ticks Frostbound Fangs' duration down once per End Turn, same timing (and
## same "the casting turn doesn't count" skip) as Leeching Hunger's own
## _tick_leeching_hunger().
func _tick_frostbound_fangs() -> void:
	if not _frostbound_fangs_active:
		return

	if _frostbound_fangs_duration_pending_start:
		_frostbound_fangs_duration_pending_start = false
		return

	_frostbound_fangs_turns_remaining -= 1
	if _frostbound_fangs_turns_remaining <= 0:
		_end_frostbound_fangs()


## Frostbound Fangs has run its course - either every banked Attack got used
## (_apply_frostbound_fangs_attack()) or its duration ran out first
## (_tick_frostbound_fangs()), whichever came first.
func _end_frostbound_fangs() -> void:
	_frostbound_fangs_active = false
	_frostbound_fangs_bonus_damage = 0.0
	_frostbound_fangs_bonus_range = 0
	_frostbound_fangs_attacks_remaining = 0
	_frostbound_fangs_turns_remaining = 0
	_frostbound_fangs_duration_pending_start = false
	_set_hero_enlarged(hero_image, false)

	_show_message_over_hero("Frostbound Fangs wore off")


# ------------------------------------------------------------------
# The Primordial Hunger's The Test of Time.
# ------------------------------------------------------------------

## Activates The Test of Time: dispels every OTHER effect currently on the
## hero (see _dispel_all_hero_effects()), lifts him into the air under a
## ticking clock (TimeStillFX), and arms this level's own heal_per_turn for
## `level_data.duration` turns - during which apply_damage() blocks
## every hit outright and _hero_move()/_on_attack_pressed() refuse to
## act. Always "succeeds" - no target or range requirement to cast it,
## same as every other self-cast buff.
func _activate_the_test_of_time(level_data: Dictionary) -> void:
	_dispel_all_hero_effects()

	_the_test_of_time_active = true
	_the_test_of_time_heal_per_turn = float(level_data.get("heal", 0))
	_the_test_of_time_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_the_test_of_time()), same as
	# every other duration-based buff.
	_the_test_of_time_duration_pending_start = true

	# Rises into the air under an ancient ticking clock (TimeStillFX).
	TimeStillFX.begin(hero_image, _the_test_of_time_turns_remaining)


## Dispels every other effect currently on the hero, good or bad, right
## before The Test of Time establishes its own state
## (_activate_the_test_of_time()): every self-buff that could in principle
## be active - only
## ever really Frostbound Fangs for The Primordial Hunger's own kit, since the rest
## belong to other heroes, but this stays generic and correct regardless
## of whose battle it runs in - plus every debuff a rival hero fight
## boss could have inflicted (root, silence, Thornbind's/Mark of the
## Mist's/Mark of Stillness's/The Hollow Cold's/Return to the Void's/Winter's Grip's/Sanguine
## Bloom's/Mother's Grasp's/Kiss the Wastes' burn damage-over-time, Ice
## Blast's execute threshold, Barbed Lunge's/Drowned Surge's stun, Three Cheers's
## own armor reduction) -
## the same field list _reset_enemy_hero_state() clears fresh for each
## new hero fight.
func _dispel_all_hero_effects() -> void:
	if _frostbound_fangs_active:
		_end_frostbound_fangs()
	if _leeching_hunger_active:
		_end_leeching_hunger()
	if _depthsveil_active:
		_end_depthsveil()
	if _ambush_strike_active:
		_end_ambush_strike()
	if _wildbond_active:
		_end_wildbond()
	if _beast_of_the_elderwild_active:
		_end_beast_of_the_elderwild()
	if _veil_of_the_forgotten_active:
		_end_veil_of_the_forgotten(false)
	if _the_mist_remembers_active:
		_end_the_mist_remembers()

	_player_root_turns_left = 0
	_player_silence_turns_left = 0
	_player_thornbind_dot_damage = 0.0
	_player_thornbind_dot_turns_left = 0
	_player_stun_turns_left = 0
	_player_the_hunger_calls_active = false
	_player_curse_stacks = 0
	_player_curse_active = false
	_player_curse_dot_damage = 0.0
	_player_curse_dot_turns_left = 0
	_player_curse_last_hit_turn = 0
	_player_mark_of_stillness_dot_damage = 0.0
	_player_mark_of_stillness_dot_turns_left = 0
	_player_the_hollow_cold_dot_damage = 0.0
	_player_the_hollow_cold_dot_turns_left = 0
	_player_return_to_the_void_dot_damage = 0.0
	_player_return_to_the_void_dot_turns_left = 0
	_player_return_to_the_void_execute_pct = 0.0
	_player_winters_grip_dot_damage = 0.0
	_player_winters_grip_dot_turns_left = 0
	_player_winters_grip_hold = false
	_player_sanguine_bloom_dot_damage = 0.0
	_player_sanguine_bloom_heal_per_turn = 0.0
	_player_sanguine_bloom_dot_turns_left = 0
	_player_mothers_grasp_dot_damage = 0.0
	_player_mothers_grasp_dot_turns_left = 0
	_player_armor_reduction = 0.0
	_player_armor_reduction_turns_left = 0
	_player_deathlight_lure_bonus_pct = 0.0
	_player_kiss_burn_dot_damage = 0.0
	_player_kiss_burn_dot_turns_left = 0

	_refresh_bars()


## Ticks The Test of Time's duration down once per End Turn, same timing
## (and same "the casting turn doesn't count" skip) as every other
## duration-based buff - healing the hero for this level's own
## heal_per_turn on every tick that actually counts against the
## duration (the skipped casting-turn one doesn't heal either).
func _tick_the_test_of_time() -> void:
	if not _the_test_of_time_active:
		return

	if _the_test_of_time_duration_pending_start:
		_the_test_of_time_duration_pending_start = false
		return

	heal(_the_test_of_time_heal_per_turn)
	_the_test_of_time_turns_remaining -= 1
	var clock := TimeStillFX.of(hero_image)
	if clock != null:
		clock.set_turns(_the_test_of_time_turns_remaining)
	if _the_test_of_time_turns_remaining <= 0:
		_end_the_test_of_time()


## Ends The Test of Time once its duration runs out: reverts the hero's
## portrait and drops his damage immunity/heal-per-turn/full-action
## lockout (see _update_action_buttons()/_end_turn()'s own auto-skip).
func _end_the_test_of_time() -> void:
	_the_test_of_time_active = false
	_the_test_of_time_heal_per_turn = 0.0
	_the_test_of_time_turns_remaining = 0
	_the_test_of_time_duration_pending_start = false

	var clock := TimeStillFX.of(hero_image)
	if clock != null:
		clock.finish()
	_show_message_over_hero("The Test of Time wears off")


# ------------------------------------------------------------------
# Veyrik's Depthsveil.
# ------------------------------------------------------------------

## True while the hero is hidden by Depthsveil OR Rootveil -
## whichever the current hero actually has, since only one of the two
## could ever be active in a given battle. Enemy attacks check this in
## _enemy_turn() and simply don't land while it's true.
func _is_hero_hidden() -> bool:
	return _depthsveil_active or _rootveil_active or _ambush_strike_active


## Whether the rival can currently see (and therefore attack, chase, or
## otherwise target) the player, despite Depthsveil's/Rootveil's/Ambush Strike's own stealth - true sight from a rival
## Dreadlure's own Deathlight Lure (_player_deathlight_lure_bonus_pct > 0,
## the same field _cast_enemy_deathlight_lure() writes and apply_damage()
## reads for its own damage bonus, both sharing _player_armor_reduction_
## turns_left's own countdown) overrides it for as long as the mark
## holds. Deliberately kept separate from _is_hero_hidden() itself -
## that one still needs to report the player's OWN actual stealth state
## honestly (e.g. so casting another skill still ends it early, see
## _on_skill_pressed()'s own check) - true sight only ever changes
## whether an ENEMY can currently perceive it, never whether it's
## really active. Used everywhere the rival's own AI decides whether it
## can currently see the player (_enemy_turn()/_enemy_hero_turn()) in
## place of a bare _is_hero_hidden() read.
func _can_enemy_see_hero() -> bool:
	if _player_deathlight_lure_bonus_pct > 0.0:
		return true
	return not _is_hero_hidden()


## Activates Depthsveil: hides Veyrik for `level_data.duration` turns
## (not counting the casting turn itself - see
## _depthsveil_duration_pending_start) and arms
## `level_data.bonus_damage_pct` of his max damage for whichever comes
## first, his next Attack or the duration running out.
func _activate_depthsveil(level_data: Dictionary) -> void:
	_depthsveil_active = true
	_depthsveil_bonus_damage = float(level_data.get("bonus_damage_pct", 0.0)) * _hero_max_damage()
	_depthsveil_turns_remaining = int(level_data.get("duration", 0))
	_depthsveil_duration_pending_start = true
	_update_hero_visibility()


## Ticks Depthsveil's duration down once per End Turn, same timing
## and same "casting turn doesn't count" rule as Leeching Hunger (see
## _tick_leeching_hunger()).
func _tick_depthsveil() -> void:
	if not _depthsveil_active:
		return

	if _depthsveil_duration_pending_start:
		_depthsveil_duration_pending_start = false
		return

	_depthsveil_turns_remaining -= 1
	if _depthsveil_turns_remaining <= 0:
		_end_depthsveil()


## Ends Depthsveil, whether from its duration running out, Veyrik
## attacking while hidden, or casting another skill while hidden.
func _end_depthsveil() -> void:
	_depthsveil_active = false
	_depthsveil_bonus_damage = 0.0
	_depthsveil_turns_remaining = 0
	_depthsveil_duration_pending_start = false
	_update_hero_visibility()


# ------------------------------------------------------------------
# The Rootmother's Rootveil.
# ------------------------------------------------------------------

## Activates Rootveil: hides the hero for `level_data.duration`
## turns (not counting the casting turn itself) and arms `level_data.
## root_turns` for whichever comes first, his next Attack or the
## duration running out - same "casting turn doesn't count"/"one-shot
## payoff on the breaking Attack" shape as Depthsveil's own
## _activate_depthsveil(), just with a root instead of bonus damage.
func _activate_rootveil(level_data: Dictionary) -> void:
	_rootveil_active = true
	_rootveil_root_turns = int(level_data.get("root_turns", 0))
	_rootveil_turns_remaining = int(level_data.get("duration", 0))
	_rootveil_duration_pending_start = true
	_update_hero_visibility()


## Ticks Rootveil's duration down once per End Turn, same timing
## and same "casting turn doesn't count" rule as Depthsveil's own
## _tick_depthsveil().
func _tick_rootveil() -> void:
	if not _rootveil_active:
		return

	if _rootveil_duration_pending_start:
		_rootveil_duration_pending_start = false
		return

	_rootveil_turns_remaining -= 1
	if _rootveil_turns_remaining <= 0:
		_end_rootveil()


## Ends Rootveil, whether from its duration running out, the hero
## attacking while hidden, or casting another skill while hidden.
func _end_rootveil() -> void:
	_rootveil_active = false
	_rootveil_root_turns = 0
	_rootveil_turns_remaining = 0
	_rootveil_duration_pending_start = false
	_update_hero_visibility()


# ------------------------------------------------------------------
# Solara's ultimate, Ambush Strike.
# ------------------------------------------------------------------

## Activates Ambush Strike: hides Solara for `level_data.duration`
## turns (not counting the casting turn itself - see
## _ambush_strike_duration_pending_start) and arms
## `level_data.bonus_damage_pct` for whichever comes first, her next
## Attack or the duration running out - same overall shape as Shadow
## Dance's own _activate_depthsveil(), just a percentage bonus
## instead of a flat one (see the field comment above
## _ambush_strike_active).
func _activate_ambush_strike(level_data: Dictionary) -> void:
	_ambush_strike_active = true
	_ambush_strike_bonus_damage_pct = float(level_data.get("bonus_damage_pct", 0.0))
	_ambush_strike_turns_remaining = int(level_data.get("duration", 0))
	_ambush_strike_duration_pending_start = true
	_update_hero_visibility()


## Ticks Ambush Strike's duration down once per End Turn, same
## timing and same "casting turn doesn't count" rule as Depthsveil
## (see _tick_depthsveil()).
func _tick_ambush_strike() -> void:
	if not _ambush_strike_active:
		return

	if _ambush_strike_duration_pending_start:
		_ambush_strike_duration_pending_start = false
		return

	_ambush_strike_turns_remaining -= 1
	if _ambush_strike_turns_remaining <= 0:
		_end_ambush_strike()


## Ends Ambush Strike, whether from its duration running out, Solara
## attacking while hidden, or casting another skill while hidden.
func _end_ambush_strike() -> void:
	_ambush_strike_active = false
	_ambush_strike_bonus_damage_pct = 0.0
	_ambush_strike_turns_remaining = 0
	_ambush_strike_duration_pending_start = false
	_update_hero_visibility()


## Breaks whichever veil the player's hero is under - what a rival's
## true sight (Deathlight Lure) does to him: he is revealed on the spot.
func _reveal_player_hero() -> void:
	if not _is_hero_hidden():
		return
	_end_depthsveil()
	_end_rootveil()
	_end_ambush_strike()


## Slight fade to represent invisibility - fully opaque and visible
## otherwise. Called whenever Depthsveil, Rootveil, or
## Ambush Strike starts or ends.
func _update_hero_visibility() -> void:
	hero_image.modulate = Color(1, 1, 1, 0.4) if _is_hero_hidden() else Color(1, 1, 1, 1)


# ------------------------------------------------------------------
# Erynd's Wildbond.
# ------------------------------------------------------------------

## Activates (or refreshes) Wildbond at `level_data`'s values.
## Overwriting the running values is enough on a recast.
func _activate_wildbond(level_data: Dictionary) -> void:
	_wildbond_active = true
	_wildbond_lifesteal_pct = float(level_data.get("lifesteal_pct", 0.0))
	_wildbond_bonus_armor = float(level_data.get("bonus_armor", 0))
	_wildbond_turns_remaining = int(level_data.get("duration", 0))
	_wildbond_duration_pending_start = true
	_set_hero_enlarged(hero_image, true)


## Ticks Wildbond's duration down once per End Turn, same timing
## and "casting turn doesn't count" rule as Leeching Hunger/Depthsveil.
func _tick_wildbond() -> void:
	if not _wildbond_active:
		return

	if _wildbond_duration_pending_start:
		_wildbond_duration_pending_start = false
		return

	_wildbond_turns_remaining -= 1
	if _wildbond_turns_remaining <= 0:
		_end_wildbond()


## Ends Wildbond, whether from its duration running out or a fresh
## cast overwriting it outright (see _activate_wildbond()).
func _end_wildbond() -> void:
	_wildbond_active = false
	_wildbond_lifesteal_pct = 0.0
	_wildbond_bonus_armor = 0.0
	_wildbond_turns_remaining = 0
	_wildbond_duration_pending_start = false
	_set_hero_enlarged(hero_image, false)


## Purely cosmetic: while an empowering self-buff is active - Spirit
## Link (Erynd), Frostbound Fangs (The Primordial Hunger) or Bestial Rage (Skarn) -
## `node` (the player's hero_image, or the rival's own node) grows to
## HERO_ENLARGED_SCALE. Shared because no hero has more than one of
## them, so they never overlap on one sprite. Only does anything when the state
## actually changes (the "base_scale" meta is the "currently on"
## marker), so a recast while it's already up just leaves it as is.
func _set_hero_enlarged(node: Variant, active: bool) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var target_scale: Vector2 = Vector2.ONE * (HERO_ENLARGED_SCALE if active else 1.0)
	if node.get_meta("base_scale", Vector2.ONE) == target_scale:
		return

	node.set_meta("base_scale", target_scale)
	node.pivot_offset = node.size / 2.0
	var scale_tween: Tween = node.create_tween()
	scale_tween.tween_property(node, "scale", target_scale, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Wildbond's lifesteal: converts `_wildbond_lifesteal_pct` of an
## Attack's damage - AFTER the target's armor has already reduced it -
## into HP for the hero. Only called from _apply_hero_attack() (the
## plain Attack action, melee or ranged) - skill damage (Barbed Lunge, Dark
## Pact, Thornbind's DoT, the Elderwild Companion's own hits, etc.) never routes
## through here, matching the skill's own wording. No-op while Spirit
## Link isn't active or the hit did no damage (e.g. fully absorbed).
## `target` is only used for the lifesteal visual flowing from it back
## to the hero (_play_lifesteal_effect()).
func _apply_wildbond_lifesteal(mitigated_attack_damage: float, target: Dictionary) -> void:
	if not _wildbond_active or mitigated_attack_damage <= 0.0:
		return
	heal(mitigated_attack_damage * _wildbond_lifesteal_pct)
	_play_lifesteal_effect(target.get("node"), hero_image)


const MORBID_MASK_LIFESTEAL_PCT := GameManager.MORBID_MASK_LIFESTEAL_PCT


## The Morbid Mask item's own passive: identical shape to Spirit
## Link's own lifesteal just above (same "% of the plain Attack's
## damage, after the target's own armor already reduced it" rule,
## never skill damage) but a flat, always-on item bonus rather than a
## temporary skill buff - stacks with Wildbond if the player has
## both active at once. Gated on actually owning one, same as
## Cleaver's own item check (see _apply_cleaver_cleave()). `target` is
## only used for the lifesteal visual flowing from it back to the hero
## (_play_lifesteal_effect()).
func _apply_morbid_mask_lifesteal(mitigated_attack_damage: float, target: Dictionary) -> void:
	if mitigated_attack_damage <= 0.0 or PlayerManager.get_inventory().get("morbid_mask", 0) <= 0:
		return
	heal(mitigated_attack_damage * MORBID_MASK_LIFESTEAL_PCT)
	_play_lifesteal_effect(target.get("node"), hero_image)


## Purely cosmetic: the standard lifesteal visual - red motes flowing
## from `from_node` (whoever was hit) to `to_node` (whoever healed off
## the hit), the same drain stream Leeching Hunger uses (_play_drain_
## effect()), in LIFESTEAL_MOTE_COLOR. Any lifesteal - Wildbond, the
## Morbid Mask item, and future ones - should play it, so they all look
## the same. Two lifesteals off the same hit (Wildbond + Morbid Mask)
## each play their own stream, reading as a denser flow.
func _play_lifesteal_effect(from_node: Variant, to_node: Variant) -> void:
	_play_drain_effect(from_node, to_node, LIFESTEAL_MOTE_COLOR)


# ------------------------------------------------------------------
# Erynd's ultimate, Beast of the Elderwild.
# ------------------------------------------------------------------

## Activates (or, if already active, restarts) Beast of the Elderwild at
## `level_data`'s values: swaps the hero's portrait to his bear form,
## and arms the bonus HP/damage plus the forced-melee range for the
## duration (see _hero_max_hp(), _roll_hero_damage(), _is_ranged_hero()
## respectively - each reads the state set here directly). The bonus
## HP raises his max HP (see _hero_max_hp()) rather than instantly
## topping him up - it's extra capacity for the duration, not a free heal.
func _activate_beast_of_the_elderwild(level_data: Dictionary) -> void:
	if _beast_of_the_elderwild_active:
		_end_beast_of_the_elderwild()

	_beast_of_the_elderwild_active = true
	_beast_of_the_elderwild_bonus_hp = float(level_data.get("bonus_hp", 0))
	# A share of his damage range's top, taken without the buff's own current
	# bonus (a recast while it is running must not feed on itself).
	var base_max_damage: float = _hero_max_damage() - _beast_of_the_elderwild_bonus_damage
	_beast_of_the_elderwild_bonus_damage = float(level_data.get("bonus_damage_pct", 0.0)) * base_max_damage
	_beast_of_the_elderwild_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_beast_of_the_elderwild()).
	_beast_of_the_elderwild_duration_pending_start = true

	_set_hero_image(BEAST_OF_THE_ELDERWILD_IMAGE_PATH)
	_refresh_bars()


## Ticks Beast of the Elderwild's duration down once per End Turn, same timing and
## "casting turn doesn't count" rule as Leeching Hunger/Depthsveil/
## Wildbond.
func _tick_beast_of_the_elderwild() -> void:
	if not _beast_of_the_elderwild_active:
		return

	if _beast_of_the_elderwild_duration_pending_start:
		_beast_of_the_elderwild_duration_pending_start = false
		return

	_beast_of_the_elderwild_turns_remaining -= 1
	if _beast_of_the_elderwild_turns_remaining <= 0:
		_end_beast_of_the_elderwild()


## Ends Beast of the Elderwild, whether from its duration running out or a fresh
## cast restarting it outright (see _activate_beast_of_the_elderwild()): reverts
## the portrait, drops the bonus HP/damage and the forced melee range
## back to normal.
func _end_beast_of_the_elderwild() -> void:
	_beast_of_the_elderwild_active = false
	_beast_of_the_elderwild_bonus_hp = 0.0
	_beast_of_the_elderwild_bonus_damage = 0.0
	_beast_of_the_elderwild_turns_remaining = 0
	_beast_of_the_elderwild_duration_pending_start = false

	_set_hero_image(_hero_static.get("image", ""))
	# Transforming back gets the same pulse transforming in did (that one
	# comes from the cast itself, via spend_mana()).
	var hero_animator := CreatureAnimator.of(hero_image)
	if hero_animator != null:
		hero_animator.play_cast()
	_refresh_bars()
	_show_message_over_hero("Beast of the Elderwild wears off")


# ------------------------------------------------------------------
# Erynd's Elderwild Companion.
# ------------------------------------------------------------------

func _is_bear_alive() -> bool:
	return not _bear.is_empty()


## Summons (or re-summons) the Elderwild Companion at `level_data`'s stats,
## starting on the hero's own column. Any bear already out - even a
## stronger one from a previous cast at a higher level, since the
## player might recast at the same level just to top it back up to
## full HP - is replaced outright, per _despawn_bear().
func _elderwild_companion(level_data: Dictionary) -> void:
	_despawn_bear()

	if not ResourceLoader.exists(ELDERWILD_COMPANION_IMAGE_PATH):
		print("No bear image found at: ", ELDERWILD_COMPANION_IMAGE_PATH)
		return

	var target_height: float = get_viewport_rect().size.y / 4.0
	var texture: Texture2D = load(ELDERWILD_COMPANION_IMAGE_PATH)
	var tex_size: Vector2 = texture.get_size()
	var scale_factor: float = target_height / tex_size.y
	var target_width: float = tex_size.x * scale_factor

	var tex_rect := TextureRect.new()
	tex_rect.texture = texture
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	tex_rect.size = Vector2(target_width, target_height)
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_rect.position = Vector2(_index_to_x(_hero_pos_index), _creature_y())
	add_child(tex_rect)
	# add_child() appends as the LAST sibling, which would draw on top
	# of every UI panel and popup (LevelUpPopup, DefeatPopup, etc.) -
	# move it right after EnemiesLayer instead, so it renders at the
	# same visual layer as the hero/enemies and stays behind all UI.
	move_child(tex_rect, enemies_layer.get_index() + 1)

	# "current / max" over the bear, styled like a creep's own HP label
	# (see _spawn_enemy()); kept in sync every frame by
	# _refresh_bear_hp_label().
	var hp_label := Label.new()
	hp_label.size = Vector2(ENEMY_HP_LABEL_WIDTH, ENEMY_HP_LABEL_HEIGHT)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_label.add_theme_color_override("font_color", ENEMY_HP_LABEL_COLOR)
	hp_label.add_theme_font_size_override("font_size", ENEMY_HP_LABEL_FONT_SIZE)
	hp_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	hp_label.add_theme_constant_override("outline_size", 3)
	add_child(hp_label)
	move_child(hp_label, tex_rect.get_index() + 1)

	# Its health and damage are a share of Erynd's own (his stats with gear,
	# not counting a running Beast of the Elderwild).
	var hero_stats: Dictionary = _recruited.get("stats", {})
	var hero_damage_parts: PackedStringArray = str(hero_stats.get("damage", "0-0")).split("-")
	var hero_min_damage: float = float(hero_damage_parts[0])
	var hero_max_damage: float = float(hero_damage_parts[1]) if hero_damage_parts.size() > 1 else hero_min_damage
	var damage_pct: float = float(level_data.get("damage_pct", 0.0))
	var hp: float = maxf(1.0, float(level_data.get("hp_pct", 0.0)) * float(hero_stats.get("hp", 0)))
	_bear = {
		"hp": hp,
		"current_hp": hp,
		"damage_min": damage_pct * hero_min_damage,
		"damage_max": damage_pct * hero_max_damage,
		"armor": float(level_data.get("armor", 0)),
		"speed": maxi(1, int(level_data.get("speed", 1))),
		"lifesteal_pct": float(level_data.get("bear_lifesteal_pct", 0.0)),
		"pos_index": _hero_pos_index,
		"node": tex_rect,
		"hp_label": hp_label,
	}
	CreatureAnimator.attach(tex_rect, "elderwild_companion")
	AudioManager.play_event("bear_summon")
	_refresh_bear_hp_label()


## Keeps the bear's HP label's text and position current. Run every
## frame from _process() rather than at each call site, since the bear's
## HP changes through many generic paths (regen, DoTs, heals) that take
## it as a plain Dictionary, and its node slides between columns.
func _refresh_bear_hp_label() -> void:
	if not _is_bear_alive():
		return
	var label: Label = _bear.get("hp_label")
	var node: Control = _bear.get("node")
	if not is_instance_valid(label) or not is_instance_valid(node):
		return
	label.text = "%d / %d" % [roundi(maxf(0.0, float(_bear.get("current_hp", 0)))), maxi(1, roundi(float(_bear.get("hp", 1))))]
	label.position = Vector2(
		node.position.x + node.size.x / 2.0 - ENEMY_HP_LABEL_WIDTH / 2.0,
		node.position.y - ENEMY_HP_LABEL_GAP - ENEMY_HP_LABEL_HEIGHT)


## Puts the bear back beside the hero at the start of a new stage/hero
## fight - no slide, it simply starts the fresh encounter there.
func _reset_bear_to_hero_column() -> void:
	if not _is_bear_alive():
		return
	_bear["pos_index"] = _hero_pos_index
	if is_instance_valid(_bear["node"]):
		_bear["node"].position = Vector2(_index_to_x(_hero_pos_index), _creature_y())
	_refresh_bear_hp_label()


## Removes whatever bear is currently out, if any, with no XP/gold and
## no message - used both when a fresh bear replaces it (see
## _elderwild_companion()) and when the hero leaves the battle for good
## (the scene tearing down would free the node either way, but this
## keeps _bear itself consistent for as long as the script is alive).
func _despawn_bear() -> void:
	if not _is_bear_alive():
		return
	if is_instance_valid(_bear["node"]):
		_bear["node"].queue_free()
	if is_instance_valid(_bear.get("hp_label")):
		_bear["hp_label"].queue_free()
	_bear = {}


## An enemy's hit landed on the bear instead of the hero: mitigated by
## the bear's own armor, same formula as any other target's, plus
## Blood of the Wild's damage reduction on top while it's active - the
## skill covers the bear as well as the hero (see
## _update_blood_of_the_wild_state()).
func _deal_damage_to_bear(amount: float) -> void:
	if not _is_bear_alive():
		return

	# A rival's Deathlight Lure on the bear boosts every hit it takes,
	# and its/Three Cheers's armor shred lowers its armor - same two
	# effects the player's own apply_damage() applies to him.
	amount *= (1.0 + float(_bear.get("deathlight_lure_bonus_pct", 0.0)))
	var bear_armor: float = float(_bear.get("armor", 0)) - float(_bear.get("armor_reduction", 0.0))
	var mitigated: float = _apply_armor_reduction(amount, bear_armor)
	mitigated *= (1.0 - _blood_of_the_wild_damage_reduction_pct)
	_bear["current_hp"] -= mitigated
	_show_damage_number(_bear["node"], mitigated)

	if _bear["current_hp"] <= 0:
		_kill_bear()


## Any enemy AoE skill that damages the hero over an area should ALSO
## independently hit the Elderwild Companion if it's standing within that same
## area - same reasoning as the guard-side equivalent
## (_deal_aoe_damage_to_guards()), just against the single `_bear`
## dict instead of the `_guards` array. Unlike that helper, `amount`
## is passed straight to _deal_damage_to_bear() un-mitigated - the bear
## has its own armor stat (set at summon time), not the hero's, and
## that function already mitigates with it internally. A no-op while no
## bear is out.
## `flash_hits` gives each one hit the same red hit-flash as Lunar
## Ricochet's bounce (_flash_bounce_hit()) - off by default, opted into by
## Abyssal Spasm.
func _deal_aoe_damage_to_bear(center_pos_index: int, radius: int, amount: float, flash_hits: bool = false) -> void:
	if not _is_bear_alive() or amount <= 0.0:
		return
	if _distance(_bear["pos_index"], center_pos_index) <= radius:
		_deal_damage_to_bear(amount)
		if flash_hits and _is_bear_alive() and is_instance_valid(_bear.get("node")):
			_flash_bounce_hit(_bear["node"])


## The line-shaped equivalent of _deal_aoe_damage_to_bear() above - for
## The Sunken One's/Chainfire's own "every column between the caster and
## the target, inclusive of both ends" line. Same "amount is raw, the
## bear mitigates it with its own armor" contract.
## `flash_hits` gives each one hit the standard splash hit-flash
## (_flash_bounce_hit()) - off by default, opted into by Chainfire.
func _deal_line_aoe_damage_to_bear(start_pos_index: int, end_pos_index: int, amount: float, flash_hits: bool = false) -> void:
	if not _is_bear_alive() or amount <= 0.0:
		return
	var start_col: int = mini(start_pos_index, end_pos_index)
	var end_col: int = maxi(start_pos_index, end_pos_index)
	var pos: int = _bear["pos_index"]
	if pos >= start_col and pos <= end_col:
		_deal_damage_to_bear(amount)
		if flash_hits and _is_bear_alive() and is_instance_valid(_bear.get("node")):
			_flash_bounce_hit(_bear["node"])


## The directional-cone equivalent of the two AoE-shape helpers above -
## for a rival Double Trouble's own facing-based cone. Same "amount is
## raw, the bear mitigates it with its own armor" contract.
func _deal_directional_aoe_damage_to_bear(origin_pos_index: int, direction: int, range_columns: int, amount: float) -> void:
	if not _is_bear_alive() or amount <= 0.0:
		return
	var ahead: int = (_bear["pos_index"] - origin_pos_index) * direction
	if ahead >= 0 and ahead <= range_columns:
		_deal_damage_to_bear(amount)


## The bear falls - unlike _kill_enemy(), this never grants XP or
## gold, since it's the hero's own summon rather than a foe. Losing it
## also costs the hero a chunk of his own HP (see
## _apply_bear_death_penalty()).
## `claimed_by_void`: see _kill_enemy().
func _kill_bear(claimed_by_void: bool = false) -> void:
	if claimed_by_void:
		ReturnToVoidFX.claim(_bear.get("node"), _fx_layer)
	else:
		CreatureAnimator.spawn_death_ghost(_bear.get("node"), _fx_layer)
	_despawn_bear()
	_apply_bear_death_penalty()


## Losing the bear costs the hero BEAR_DEATH_HP_PENALTY_PCT of his max
## HP, taken directly off current_hp with no armor mitigation at all
## (unlike apply_damage(), which always mitigates) - but this specific
## penalty is capped so it can never bring him below 1 HP; it's a
## punishment for losing the bear, not a death sentence on its own.
func _apply_bear_death_penalty() -> void:
	var max_hp: float = _hero_max_hp()
	var current_hp: float = float(_recruited.get("current_hp", 0))

	var penalty: float = max_hp * BEAR_DEATH_HP_PENALTY_PCT
	var actual_damage: float = minf(penalty, maxf(0.0, current_hp - 1.0))

	if actual_damage > 0.0:
		PlayerManager.damage_hero(actual_damage)
		_refresh_bars()

	_show_message_over_hero("The Elderwild Companion falls - Erynd is weakened!")


func _roll_bear_damage() -> float:
	return randi_range(int(_bear.get("damage_min", 0)), int(_bear.get("damage_max", 0)))


## The bear acts automatically once per turn, right alongside the
## enemies (see _end_turn()): attacks whatever enemy shares its
## column, or - if none does - closes in on the nearest enemy at its
## own speed (columns per turn), stopping early if that walk would
## carry it onto an enemy's column anyway (see _melee_move_target()).
## No-ops entirely while no bear is summoned, or once every enemy is
## already dead.
func _bear_turn() -> void:
	if not _is_bear_alive() or _enemies.is_empty():
		return

	# A rival's stun (Drowned Surge/Hope of the Fallen/Moonfall Lance/Return to the Void/
	# Winter's Grip/The Hunger Calls/Charge/Glacier Breaker aimed at the bear)
	# costs it this whole turn; a root (Thornbind/Shackles) still lets it
	# attack what's already on its column, just not walk. Both are
	# checked with their CURRENT value before ticking down - the same
	# "use it, then decrement" order the rival's own root/stun use - so
	# a 1-turn stun/root actually blocks the one turn it's meant to.
	var stunned: bool = int(_bear.get("stun_turns_left", 0)) > 0
	if stunned:
		_bear["stun_turns_left"] -= 1
		return
	var rooted: bool = int(_bear.get("root_turns_left", 0)) > 0
	if rooted:
		_bear["root_turns_left"] -= 1

	var target: Dictionary = _get_enemy_at(_bear["pos_index"])
	if not target.is_empty():
		# The bear's own attack, not the hero's - Deathlight Lure's own
		# bonus (see _deal_fixed_damage_to_enemy()'s own is_hero_action
		# param) never applies to it.
		var bear_animator := CreatureAnimator.of(_bear["node"])
		if bear_animator != null:
			# Art faces right natively; flip_h means it's facing left.
			bear_animator.play_attack(-1.0 if _bear["node"].flip_h else 1.0)
		var bear_dealt: float = _deal_fixed_damage_to_enemy(target, _roll_bear_damage(), false, false)
		_apply_bear_hit_effects(bear_dealt, target)
		return

	if rooted:
		return

	var nearest: Dictionary = {}
	var nearest_distance: int = GRID_COLUMNS + 1
	for enemy in _enemies:
		var d: int = _distance(enemy["pos_index"], _bear["pos_index"])
		if d < nearest_distance:
			nearest_distance = d
			nearest = enemy

	var direction: int = _step_toward(_bear["pos_index"], nearest["pos_index"])
	if direction == 0:
		return

	var new_pos: int = _melee_move_target(_bear["pos_index"], direction, int(_bear["speed"]))
	_bear["pos_index"] = new_pos
	_place_bear_node(new_pos)


## What a landed hit of the companion's gives back: Wildbond heals Erynd for
## its share of the damage (the same share his own Attacks give), and a
## top-level companion heals itself for its own lifesteal share.
func _apply_bear_hit_effects(dealt: float, target: Dictionary) -> void:
	if dealt <= 0.0 or not _is_bear_alive():
		return
	if _wildbond_active:
		heal(dealt * _wildbond_lifesteal_pct)
		_play_lifesteal_effect(target.get("node"), hero_image)
	# Wildbond shares its lifesteal with the companion too; the top-level
	# companion's own share doesn't stack on it, the larger one applies.
	var bear_lifesteal: float = float(_bear.get("lifesteal_pct", 0.0))
	if _wildbond_active:
		bear_lifesteal = maxf(bear_lifesteal, _wildbond_lifesteal_pct)
	if bear_lifesteal > 0.0:
		_bear["current_hp"] = minf(float(_bear["hp"]), float(_bear["current_hp"]) + dealt * bear_lifesteal)
		_play_lifesteal_effect(target.get("node"), _bear.get("node"))


## Snaps the bear's node onto column `pos`, sliding its art over from
## where it was if it has a CreatureAnimator (same as _move_enemy()).
func _place_bear_node(pos: int) -> void:
	var node: Control = _bear["node"]
	var old_x: float = node.position.x
	node.position = Vector2(_index_to_x(pos), _creature_y())
	var animator := CreatureAnimator.of(node)
	if animator != null and not is_equal_approx(old_x, node.position.x):
		animator.play_move(old_x - node.position.x)


## Updates every skill's cooldown label - "Ready" or "N turns left" -
## to match _skill_cooldowns. Called after a skill is used and after
## cooldowns tick down at End Turn.
func _refresh_skill_cooldown_labels() -> void:
	for skill_id in _skill_cooldown_labels.keys():
		var label: Label = _skill_cooldown_labels[skill_id]
		var remaining: int = _skill_cooldowns.get(skill_id, 0)
		if remaining <= 0:
			label.text = "Ready"
			label.add_theme_color_override("font_color", Color(0.5, 1, 0.5, 1))
		else:
			var noun: String = "turn" if remaining == 1 else "turns"
			label.text = "%d %s left" % [remaining, noun]
			label.add_theme_color_override("font_color", Color(1, 0.6, 0.4, 1))

	# The Mist Remembers has no button click to show its own "in effect"
	# state the way a manually-cast buff's activation message does, so
	# this overlays "Active" on top of whatever the loop above just
	# wrote (its cooldown only starts counting down once it ends - see
	# _end_the_mist_remembers() - so "Ready"/"N turns left"
	# would otherwise read as if it wasn't doing anything right now).
	if _the_mist_remembers_active and _skill_cooldown_labels.has("the_mist_remembers"):
		var the_mist_remembers_label: Label = _skill_cooldown_labels["the_mist_remembers"]
		the_mist_remembers_label.text = "Active"
		the_mist_remembers_label.add_theme_color_override("font_color", Color(1, 0.65, 0.2, 1))


## Ticks every tracked skill cooldown down by one turn, clamped at 0,
## and ticks Leeching Hunger's, Depthsveil's, Frostbound Fangs', The Test of
## Time's, The Frost Tempest's, Frostbound Rupture', Bestial Rage's, Rootveil's, Woven Flesh's, Kindled Resolve's (each stack independently),
## Cinderbomb's, Wildbond's, Beast of the Elderwild's, Veil of the Forgotten's, and The Mist
## Remembers's durations, plus Mark of the Mist's own (enemy- and player-side)
## un-activated-stack decay - not a DoT, so it
## stays here rather than moving to turn-start with the rest (see
## _tick_mark_of_the_mist_effects()'s own comment) - and, during a hero
## fight, the rival's own mirrored buff/cooldown durations. Every actual
## DoT/root/silence/execute effect, on either side, now ticks at the
## start of whichever turn it belongs to instead
## (_tick_enemy_turn_start_effects()/_tick_player_turn_start_effects()).
## Called once per End Turn.
func _tick_skill_cooldowns() -> void:
	for skill_id in _skill_cooldowns.keys():
		var new_value: int = maxi(0, _skill_cooldowns[skill_id] - 1)
		_skill_cooldowns[skill_id] = new_value
		PlayerManager.set_skill_cooldown(skill_id, new_value)

	_tick_leeching_hunger()
	_tick_depthsveil()
	_tick_rootveil()
	_tick_ambush_strike()
	_tick_frostbound_fangs()
	_tick_the_test_of_time()
	_tick_frost_tempest()
	_tick_eternal_eclipse()
	_tick_frostbound_rupture()
	_tick_bestial_rage()
	_tick_woven_flesh()
	if _withering_miss_turns > 0:
		_withering_miss_turns -= 1
		if _withering_miss_turns <= 0:
			_withering_miss_chance = 0.0
	_tick_wildbond()
	_tick_beast_of_the_elderwild()
	_tick_veil_of_the_forgotten()
	_tick_the_mist_remembers()
	_tick_mark_of_the_mist_effects()
	_tick_kindled_resolve_stacks()
	_tick_cinderbomb()
	_tick_imperial_guard()
	_tick_hunting_instinct()
	_tick_enemy_passive_regen()

	if _in_hero_fight:
		for skill_id in _enemy_skill_cooldowns.keys():
			_enemy_skill_cooldowns[skill_id] = maxi(0, _enemy_skill_cooldowns[skill_id] - 1)

		_tick_enemy_leeching_hunger()
		_tick_enemy_depthsveil()
		_tick_enemy_wildbond()
		_tick_enemy_beast_of_the_elderwild()
		_tick_enemy_veil_of_the_forgotten()
		_tick_enemy_the_mist_remembers()
		_tick_enemy_mark_of_the_mist_effects()
		_tick_enemy_frostbound_fangs()
		_tick_enemy_the_test_of_time()
		_tick_enemy_frost_tempest()
		_tick_enemy_frostbound_rupture()
		_tick_enemy_bestial_rage()
		_tick_enemy_rootveil()
		_tick_enemy_woven_flesh()
		_tick_enemy_kindled_resolve_stacks()
		_apply_enemy_kindled_resolve_regen()
		_tick_enemy_cinderbomb()
		_tick_enemy_imperial_guard()
		_tick_enemy_hunting_instinct()
		_tick_enemy_ambush_strike()
		_tick_enemy_eternal_eclipse()


# ------------------------------------------------------------------
# Passive HP/mana regen - a small amount every turn for every
# creature in the fight (the player's own hero, a hero fight's rival
# boss, and every regular creep), scaled off the same stat each side's
# HP/mana already derive from (strength for HP, intelligence for
# mana). Ticks right after status effects/DoT for that same "turn" -
# _apply_passive_hero_regen() is called from _end_turn() right where
# Frostborn's own regen already is (right after _tick_skill_
# cooldowns()' DoT tick, before the player's action buttons reopen);
# _tick_enemy_passive_regen() is called from _tick_skill_cooldowns()
# itself, alongside every other unconditional enemy-side tick, so a
# creep's own regen lands between its last action and its next one the
# same way its DoT ticks already do.
# ------------------------------------------------------------------

const PASSIVE_HP_REGEN_BASE := 2.0
const PASSIVE_HP_REGEN_PER_STRENGTH := 0.25
const PASSIVE_MANA_REGEN_BASE := 1.0
const PASSIVE_MANA_REGEN_PER_INT := 0.1


## The player hero's own passive regen. Reads strength/intelligence
## straight off _recruited's own stats - the same raw base values
## _hero_armor()/_hero_max_hp() already read for their own bonus terms
## - since Leeching Hunger/Beast of the Elderwild never touch strength/intelligence
## themselves (only derived hp/mana/armor/damage), no extra bonus
## terms belong here.
func _apply_passive_hero_regen() -> void:
	var stats: Dictionary = _recruited.get("stats", {})
	var strength: float = float(stats.get("strength", 0))
	var intelligence: float = float(stats.get("intelligence", 0))

	heal(PASSIVE_HP_REGEN_BASE + strength * PASSIVE_HP_REGEN_PER_STRENGTH + PlayerManager.get_inventory_stat_bonus("hp_regen"))
	restore_mana(PASSIVE_MANA_REGEN_BASE + intelligence * PASSIVE_MANA_REGEN_PER_INT + PlayerManager.get_inventory_stat_bonus("mana_regen"))


## The enemy-side mirror, for every living entry in _enemies at once -
## a regular creep, a hero fight's rival boss, or its summoned Spirit
## Bear ally. HP regen applies to all three, using whichever stat each
## kind actually tracks: the boss's real strength (from
## _enemy_hero_static's own stats, mirroring the player's own read
## above - a hero-fight enemy_def only ever carries flattened hp/
## damage/armor, never strength/intelligence, see GameManager.gd's own
## build_hero_fight_enemy_def()), or a creep's/bear's own
## current_main_stat_value ONLY when its static main_stat is actually
## "strength" - an agility/intelligence creep has no tracked strength
## at all, so it just gets the flat base. Mana regen only applies to
## the boss: a regular creep's own "mana" field (see GameManager.gd's
## own creep entries) is never read or spent anywhere in this file, so
## ticking it would just be dead state - _enemy_current_mana is the
## boss's own single shared mana pool (there's only ever one boss per
## fight).
func _tick_enemy_passive_regen() -> void:
	for enemy in _enemies.duplicate():
		var enemy_static: Dictionary = enemy["static"]
		var is_boss: bool = enemy_static.get("is_hero_fight_boss", false)

		var strength: float = 0.0
		if is_boss:
			strength = float(_enemy_hero_static.get("stats", {}).get("strength", 0))
		elif enemy_static.get("main_stat", "") == "strength":
			strength = float(enemy.get("current_main_stat_value", 0))

		var hp_regen: float = PASSIVE_HP_REGEN_BASE + strength * PASSIVE_HP_REGEN_PER_STRENGTH + (PlayerManager.get_npc_item_bonus(_enemy_hero_id, "hp_regen") if is_boss else 0.0)
		var max_hp: float = _enemy_hero_effective_max_hp(enemy) if is_boss else float(enemy_static.get("hp", 1))
		enemy["current_hp"] = minf(max_hp, enemy["current_hp"] + hp_regen)

		if is_boss:
			var intelligence: float = float(_enemy_hero_static.get("stats", {}).get("intelligence", 0))
			var mana_regen: float = PASSIVE_MANA_REGEN_BASE + intelligence * PASSIVE_MANA_REGEN_PER_INT + PlayerManager.get_npc_item_bonus(_enemy_hero_id, "mana_regen")
			_enemy_current_mana = minf(_enemy_max_mana, _enemy_current_mana + mana_regen)


# ------------------------------------------------------------------
# Morvael's Veil of the Forgotten.
# ------------------------------------------------------------------

## Activates (or, if already active, replaces outright - no explosion
## from the old one, same "silently overwritten" rule Beast of the Elderwild uses
## when recast) Veil of the Forgotten at `level_data`'s values, and dispels
## every negative effect currently on the player - see the state-var
## block's comment above for exactly which ones and why silence isn't
## among them.
func _activate_veil_of_the_forgotten(level_data: Dictionary) -> void:
	_veil_of_the_forgotten_active = true
	_veil_of_the_forgotten_hp = float(level_data.get("shield_hp", 0))
	_veil_of_the_forgotten_aoe_damage = float(level_data.get("aoe_damage", 0))
	_veil_of_the_forgotten_radius = int(level_data.get("radius", 0))
	_veil_of_the_forgotten_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_veil_of_the_forgotten()), same as
	# every other duration-based buff.
	_veil_of_the_forgotten_duration_pending_start = true

	# Checked before the dispel below clears it all - only drives the
	# cleanse sparks in _show_veil_shell().
	var cleansed: bool = _player_root_turns_left > 0 or _player_thornbind_dot_turns_left > 0 \
		or _player_stun_turns_left > 0 or _player_the_hunger_calls_active

	_player_root_turns_left = 0
	_player_thornbind_dot_damage = 0.0
	_player_thornbind_dot_turns_left = 0
	_player_stun_turns_left = 0
	_player_the_hunger_calls_active = false

	_show_message_over_hero("Shield up!")
	_show_veil_shell(hero_image, _veil_of_the_forgotten_hp, cleansed)
	_refresh_bars()


## Ticks the shield's duration down once per End Turn, same "casting
## turn doesn't count" pattern as Leeching Hunger/Depthsveil/Spirit
## Link/Beast of the Elderwild. Only reached while the shield is still standing -
## see apply_damage() for the other way it can end, mid-turn, from
## being drained to 0 instead of outlasting its clock.
func _tick_veil_of_the_forgotten() -> void:
	if not _veil_of_the_forgotten_active:
		return

	if _veil_of_the_forgotten_duration_pending_start:
		_veil_of_the_forgotten_duration_pending_start = false
		return

	_veil_of_the_forgotten_turns_remaining -= 1
	if _veil_of_the_forgotten_turns_remaining <= 0:
		_end_veil_of_the_forgotten(false)


## Ends Veil of the Forgotten, whether its duration simply ran out (`exploded`
## false - it just fades) or enough damage drained it to 0 HP
## (`exploded` true, from apply_damage()) - in which case it deals the
## cast's own aoe_damage to every living, targetable enemy within its
## own radius columns of the hero, mirroring Abyssal Spasm's radius-around-
## a-position AoE (_cast_abyssal_spasm()). Captures the level's aoe_damage/
## radius into locals before clearing the state below, since the
## explosion still needs them afterward.
func _end_veil_of_the_forgotten(exploded: bool) -> void:
	var aoe_damage: float = _veil_of_the_forgotten_aoe_damage
	var radius: int = _veil_of_the_forgotten_radius

	_veil_of_the_forgotten_active = false
	_veil_of_the_forgotten_hp = 0.0
	_veil_of_the_forgotten_aoe_damage = 0.0
	_veil_of_the_forgotten_radius = 0
	_veil_of_the_forgotten_turns_remaining = 0
	_veil_of_the_forgotten_duration_pending_start = false

	_remove_veil_shell(hero_image, exploded, radius)

	if not exploded:
		_show_message_over_hero("Shield fades")
		return

	var targets: Array = []
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
			targets.append(enemy)
	for enemy in targets:
		_deal_fixed_damage_to_enemy(enemy, aoe_damage)
		# Same red hit-flash as Abyssal Spasm.
		if is_instance_valid(enemy.get("node")):
			_flash_bounce_hit(enemy["node"])
	# Self-centered on the hero, same as the check above - a rival's own
	# guard (The Last Empress's Imperial Guard) can be in range independently
	# of whether the boss itself currently is.
	_deal_aoe_damage_to_enemy_guards(_hero_pos_index, radius, aoe_damage, true)

	_show_message_over_hero("Shield shattered!")


## Purely cosmetic: puts Veil of the Forgotten's shell on `node` (the
## player's hero_image, or the rival Morvael's own node) - a
## translucent dark purple bubble, a child Panel so it follows the
## sprite's position/scale/fades for free, snapping on from small with
## an overshoot, then slowly "breathing" for as long as it's up. Also
## flashes the sprite purple and, if the cast actually `cleansed`
## anything, lets off a few purple sparks. `shield_hp` is remembered as
## the shell's full strength so _update_veil_shell() can fade it as
## it drains. A recast replaces any existing shell outright, the same
## way the shield itself is replaced.
func _show_veil_shell(node: Variant, shield_hp: float, cleansed: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return

	var old_shell: Node = node.get_node_or_null(VEIL_SHELL_NAME)
	if old_shell != null:
		old_shell.name = VEIL_SHELL_NAME + "Replaced"
		old_shell.queue_free()

	var shell := ColorRect.new()
	shell.name = VEIL_SHELL_NAME
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Wraps the whole sprite with a margin of mist around it.
	shell.size = node.size * (1.0 + VEIL_SHROUD_MARGIN * 2.0)
	shell.position = (node.size - shell.size) / 2.0
	shell.pivot_offset = shell.size / 2.0
	var mat := ShaderMaterial.new()
	mat.shader = VEIL_SHROUD_SHADER
	mat.set_shader_parameter("mist_color", VEIL_MIST_COLOR)
	mat.set_shader_parameter("aspect", shell.size.x / maxf(1.0, shell.size.y))
	mat.set_shader_parameter("seed", randf() * 50.0)
	mat.set_shader_parameter("strength", 1.0)
	shell.material = mat
	shell.set_meta("max_hp", maxf(1.0, shield_hp))
	# Gathers in: swells in from wide and faint.
	shell.scale = Vector2(1.35, 1.35)
	shell.modulate.a = 0.0
	node.add_child(shell)

	var gather: Tween = shell.create_tween().set_parallel()
	gather.tween_property(shell, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	gather.tween_property(shell, "modulate:a", 1.0, 0.35)

	_flash_bounce_hit(node, VEIL_FLASH_COLOR)

	if cleansed:
		_play_veil_cleanse_sparks(node)


## Called whenever the shield soaks up part of a hit but survives it:
## the mist thins toward a few ragged wisps as `remaining_hp` drops
## (dense when fresh, barely there just before it breaks), and puffs
## out and back so the absorbed hit visibly lands in it.
func _update_veil_shell(node: Variant, remaining_hp: float) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var shell: ColorRect = node.get_node_or_null(VEIL_SHELL_NAME)
	if shell == null:
		return

	var fraction: float = clampf(remaining_hp / float(shell.get_meta("max_hp", 1.0)), 0.0, 1.0)
	var mat := shell.material as ShaderMaterial
	var tween: Tween = shell.create_tween()
	tween.tween_property(shell, "scale", Vector2(1.1, 1.1), 0.08).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(mat, "shader_parameter/strength", fraction, 0.35)
	tween.parallel().tween_property(shell, "modulate:a", lerpf(0.55, 1.0, fraction), 0.35)
	tween.tween_property(shell, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE)


## Takes Veil of the Forgotten's shroud off `node`: the mist drifts apart
## over ~0.4s when it just ran out (or was cleared on a reset), or - when
## `shattered` - it erupts in a burst of mist rolling out about `radius` columns (the
## explosion's own reach) plus a light screen shake. The explosion's
## damage and hit flashes are the caller's.
func _remove_veil_shell(node: Variant, shattered: bool, radius: int) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var shell: ColorRect = node.get_node_or_null(VEIL_SHELL_NAME)
	if shell == null:
		return

	# Renamed right away so a recast during the fade creates a fresh
	# shroud instead of finding this dying one.
	shell.name = VEIL_SHELL_NAME + "Ending"

	var fade_time: float = 0.15 if shattered else 0.4
	var tween: Tween = shell.create_tween()
	tween.tween_property(shell, "scale", Vector2(1.25, 1.25) if shattered else Vector2(1.1, 1.1), fade_time)
	tween.parallel().tween_property(shell, "modulate:a", 0.0, fade_time)
	tween.tween_callback(shell.queue_free)

	if not shattered:
		return

	_play_veil_shatter(node.position + node.size / 2.0, radius)
	_shake_screen()


## The eruption when the veil breaks: a one-shot radial burst of mist
## rolling out fast enough to reach about `radius` columns before it
## fades (at least one column, even for a radius-0 shield). Same
## CPUParticles2D one-shot-burst recipe as _spawn_three_cheers_impact().
func _play_veil_shatter(pos: Vector2, radius: int) -> void:
	var lifetime: float = 0.7
	var reach: float = _grid_unit() * maxf(1.0, float(radius))
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 60
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = reach / lifetime * 0.6
	particles.initial_velocity_max = reach / lifetime * 1.1
	ProjectileFX._make_misty(particles, VEIL_BURST_COLOR, lifetime)
	particles.scale_amount_min = 1.2
	particles.scale_amount_max = 2.4
	add_child(particles)
	# Same reasoning as _play_double_trouble_effect()'s own move_child()
	# call - render at the hero/enemy layer, not on top of every UI panel.
	move_child(particles, enemies_layer.get_index() + 1)
	particles.emitting = true

	get_tree().create_timer(lifetime + 0.2).timeout.connect(particles.queue_free)


## The cleanse: a few wisps of mist drifting up off `node`, as if
## the removed debuffs are being lifted away. Only played when the
## cast actually dispelled something.
func _play_veil_cleanse_sparks(node: Control) -> void:
	var lifetime: float = 0.8
	var particles := CPUParticles2D.new()
	particles.position = node.position + node.size / 2.0
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 16
	particles.lifetime = lifetime
	particles.explosiveness = 0.7
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = node.size * 0.3
	particles.direction = Vector2(0, -1)
	particles.spread = 25.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 90.0
	ProjectileFX._make_misty(particles, VEIL_BURST_COLOR, lifetime)
	add_child(particles)
	move_child(particles, enemies_layer.get_index() + 1)
	particles.emitting = true

	get_tree().create_timer(lifetime + 0.2).timeout.connect(particles.queue_free)


# ------------------------------------------------------------------
# Morvael's Mark of the Mist - a passive, so unlike every skill above
# there's no button/cast/mana/cooldown for it (see _populate_skill_
# buttons()'s "passive" branch); it just triggers off the hero's own
# plain Attacks (_apply_hero_attack()). Per-target progress (stacks,
# the active curse's own DoT, and the turn count feeding stack decay)
# lives directly on each enemy's own Dictionary in _enemies, the same
# way Thornbind's root/silence/DoT fields do (_apply_root()) - it's
# per-enemy state, not per-hero, so it can't live in a single instance
# variable the way the rest of this hero's kit does.
# ------------------------------------------------------------------

# How many full turns a target can go without being hit by the hero's
# Attack before its un-activated stacks are lost (see
# _tick_mark_of_the_mist_effects()) - independent of skill level.
const MARK_OF_THE_MIST_STACK_DECAY_TURNS := 3


## Mark of the Mist's level data for whatever level the player has it
## at right now - {} if it isn't learned at all (level 0), the same
## "empty means locked" convention _get_blood_of_the_wild_level_data() uses.
func _get_mark_of_the_mist_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("mark_of_the_mist")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "mark_of_the_mist":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Called on every plain Attack hit (see _apply_hero_attack()): builds
## one stack of Mark of the Mist on `target`, or - once this level's
## hits_to_activate is reached - consumes all of them to activate the
## actual curse instead (silence, via the same `silence_turns_left`
## field Thornbind uses; and a damage-over-time - both ticked, at the
## start of that enemy's own turn, by _tick_enemy_turn_start_effects()).
## No-ops entirely if the hero doesn't have this skill learned, if the
## hit already killed the target, or if it's already cursed - a curse
## has nothing left to build toward until it wears off on its own.
func _apply_mark_of_the_mist_stack(target: Dictionary) -> void:
	var level_data: Dictionary = _get_mark_of_the_mist_level_data()
	if level_data.is_empty() or target.get("current_hp", 0) <= 0 or target.get("curse_active", false):
		return

	# Being hit at all resets the decay clock, whether or not this
	# particular hit is the one that pushes the stacks over the top.
	target["curse_last_hit_turn"] = _turn_count

	var stacks: int = target.get("curse_stacks", 0) + 1
	var hits_to_activate: int = int(level_data.get("hits_to_activate", 1))
	if stacks < hits_to_activate:
		target["curse_stacks"] = stacks
		return

	target["curse_stacks"] = 0
	target["curse_active"] = true
	target["silence_turns_left"] = int(level_data.get("silence_turns", 0))
	target["curse_dot_damage"] = float(level_data.get("dot_damage", 0))
	target["curse_dot_turns_left"] = int(level_data.get("dot_duration", 0))
	_refresh_enemy_overhead_labels()


## Mark of the Mist's own DoT (and the silence sharing Thornbind's
## `silence_turns_left` field) both moved to _tick_enemy_turn_start_
## effects() along with every other DoT - this is only what's left:
## decaying a NOT-yet-activated curse's stacks back to 0 once
## MARK_OF_THE_MIST_STACK_DECAY_TURNS full ROUNDS (not that enemy's own
## turns - _turn_count is a global round counter) have passed since the
## last hit that touched it. Not a DoT itself, so it stays here, ticked
## once per End Turn same as before.
func _tick_mark_of_the_mist_effects() -> void:
	for enemy in _enemies.duplicate():
		if not enemy.get("curse_active", false) and enemy.get("curse_stacks", 0) > 0:
			var last_hit_turn: int = int(enemy.get("curse_last_hit_turn", _turn_count))
			if _turn_count - last_hit_turn >= MARK_OF_THE_MIST_STACK_DECAY_TURNS:
				enemy["curse_stacks"] = 0


# ------------------------------------------------------------------
# Morvael's The Mist Remembers - see the state-var block's own comment
# above for the general shape of it. Unlike every other skill here,
# nothing ever calls _maybe_auto_activate_the_mist_remembers() from a
# button; the only entry point is apply_damage() noticing the hero has
# crossed this level's HP threshold.
# ------------------------------------------------------------------

## The Mist Remembers's level data for whatever level the player has it at
## right now - {} if it isn't learned at all (level 0), the same
## "empty means locked" convention _get_blood_of_the_wild_level_data()/
## _get_mark_of_the_mist_level_data() use.
func _get_the_mist_remembers_level_data() -> Dictionary:
	var level: int = PlayerManager.get_skill_level("the_mist_remembers")
	if level <= 0:
		return {}
	for skill in _hero_static.get("skills", []):
		if skill.get("id", "") == "the_mist_remembers":
			return GameManager.get_skill_level_data(skill, level)
	return {}


## Checked from apply_damage() every time the hero takes real damage
## (i.e. NOT while The Mist Remembers is already active, since it can't
## retrigger on top of itself): if he's learned it, it isn't already
## on cooldown, and his HP is now at or below this level's own
## auto_activate_hp_pct, this is the hit that crosses the threshold -
## it still deals its damage normally (see apply_damage()), but every
## hit AFTER this one heals him instead for the rest of the duration.
## Starts the cooldown immediately, the same way a manually-cast
## skill's does the moment it's used, so this can't re-trigger again
## the instant it wears off just because HP is still low.
func _maybe_auto_activate_the_mist_remembers() -> void:
	if _the_mist_remembers_active or _skill_cooldowns.get("the_mist_remembers", 0) > 0:
		return

	var level_data: Dictionary = _get_the_mist_remembers_level_data()
	if level_data.is_empty():
		return

	var max_hp: float = _hero_max_hp()
	if max_hp <= 0.0:
		return

	var hp_pct: float = float(_recruited.get("current_hp", 0)) / max_hp
	if hp_pct > float(level_data.get("auto_activate_hp_pct", 0.3)):
		return

	_the_mist_remembers_active = true
	_the_mist_remembers_heal_conversion_pct = float(level_data.get("heal_conversion_pct", 1.0))
	_the_mist_remembers_turns_remaining = int(level_data.get("duration", 0))
	# The activating turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_the_mist_remembers()), same as
	# every other duration-based buff.
	_the_mist_remembers_duration_pending_start = true

	_skill_cooldowns["the_mist_remembers"] = int(level_data.get("cooldown", 0))
	PlayerManager.set_skill_cooldown("the_mist_remembers", _skill_cooldowns["the_mist_remembers"])

	_show_message_over_hero("The Mist Remembers!")
	_set_the_mist_remembers_visual(hero_image, true)
	_refresh_bars()
	_refresh_skill_cooldown_labels()


## Ticks The Mist Remembers's duration down once per End Turn, same
## "activating turn doesn't count" pattern as every other duration-
## based buff here.
func _tick_the_mist_remembers() -> void:
	if not _the_mist_remembers_active:
		return

	if _the_mist_remembers_duration_pending_start:
		_the_mist_remembers_duration_pending_start = false
		return

	_the_mist_remembers_turns_remaining -= 1
	if _the_mist_remembers_turns_remaining <= 0:
		_end_the_mist_remembers()


## Ends The Mist Remembers once its duration runs out (or it's dispelled) and
## restarts its cooldown at the full value from here - the cooldown set
## at activation keeps ticking down WHILE the buff is active, so without
## this reset the wait after it ends would only be cooldown - duration.
func _end_the_mist_remembers() -> void:
	_the_mist_remembers_active = false
	_the_mist_remembers_heal_conversion_pct = 0.0
	_the_mist_remembers_turns_remaining = 0
	_the_mist_remembers_duration_pending_start = false
	_set_the_mist_remembers_visual(hero_image, false)

	var level_data: Dictionary = _get_the_mist_remembers_level_data()
	if not level_data.is_empty():
		_skill_cooldowns["the_mist_remembers"] = int(level_data.get("cooldown", 0))
		PlayerManager.set_skill_cooldown("the_mist_remembers", _skill_cooldowns["the_mist_remembers"])

	_show_message_over_hero("The Mist Remembers fades")
	_refresh_bars()
	_refresh_skill_cooldown_labels()


## Purely cosmetic: turns The Mist Remembers's pulsing greenish-teal glow on
## or off for `node` (the player's hero_image, or the rival Morvael's
## own node). The glow is a child TextureRect showing the same texture,
## additively blended and tinted THE_MIST_REMEMBERS_GLOW_COLOR, so it
## brightens the sprite's own silhouette toward teal and follows its
## position/scale/fades for free. Its strength pulses on a loop; the
## same per-frame update also keeps its flip_h/texture in sync with the
## sprite, since the hero can turn around while it's up. Only does
## anything when the state actually changes (the glow child's presence
## is the "currently on" marker).
##
## Also starts or stops the mist pouring into it (see
## _set_the_mist_remembers_inflow()).
func _set_the_mist_remembers_visual(node: Variant, active: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	var glow: TextureRect = node.get_node_or_null(THE_MIST_REMEMBERS_GLOW_NAME)
	if active == (glow != null):
		return

	if not active:
		# Renamed right away so a quick re-activation during the fade
		# creates a fresh glow instead of finding this dying one.
		glow.name = THE_MIST_REMEMBERS_GLOW_NAME + "Fading"
		var pulse: Variant = glow.get_meta("pulse_tween", null)
		if pulse is Tween and pulse.is_valid():
			pulse.kill()
		var fade: Tween = glow.create_tween()
		fade.tween_property(glow, "modulate:a", 0.0, 0.4)
		fade.tween_callback(glow.queue_free)
		_set_the_mist_remembers_inflow(node, false)
		return

	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow = TextureRect.new()
	glow.name = THE_MIST_REMEMBERS_GLOW_NAME
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.material = material
	glow.texture = node.texture
	glow.expand_mode = node.expand_mode
	glow.stretch_mode = node.stretch_mode
	glow.flip_h = node.flip_h
	glow.flip_v = node.flip_v
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.self_modulate = THE_MIST_REMEMBERS_GLOW_COLOR
	glow.modulate.a = 0.0
	node.add_child(glow)

	# 0 -> 1 is one full pulse: faint -> strong -> faint.
	var pulse: Tween = glow.create_tween().set_loops()
	pulse.tween_method(
		func(phase: float) -> void:
			if not is_instance_valid(node):
				return
			glow.flip_h = node.flip_h
			glow.texture = node.texture
			glow.modulate.a = lerpf(0.15, 0.8, 0.5 - 0.5 * cos(phase * TAU)),
		0.0, 1.0, THE_MIST_REMEMBERS_PULSE_SECONDS
	)
	glow.set_meta("pulse_tween", pulse)
	_set_the_mist_remembers_inflow(node, true)


## The Mist Remembers's mist pouring into `node`: on activation it rises
## out of the ground and floods in (a surge), then settles to a steady,
## gentler flow for as long as the ultimate lasts; off, it thins away.
func _set_the_mist_remembers_inflow(node: TextureRect, active: bool) -> void:
	var inflow: ColorRect = node.get_node_or_null(THE_MIST_REMEMBERS_INFLOW_NAME)
	if not active:
		if inflow == null:
			return
		inflow.name = THE_MIST_REMEMBERS_INFLOW_NAME + "Fading"
		var fade: Tween = inflow.create_tween()
		fade.tween_property(inflow.material, "shader_parameter/intensity", 0.0, 0.6)
		fade.tween_callback(inflow.queue_free)
		return
	if inflow != null:
		return

	inflow = ColorRect.new()
	inflow.name = THE_MIST_REMEMBERS_INFLOW_NAME
	inflow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Wider than the sprite so the streams can rise from either side, and
	# a little below its feet so the mist comes up out of the ground.
	inflow.size = node.size * Vector2(1.6, 1.2)
	inflow.position = Vector2((node.size.x - inflow.size.x) / 2.0, node.size.y * 1.08 - inflow.size.y)
	var mat := ShaderMaterial.new()
	mat.shader = THE_MIST_REMEMBERS_INFLOW_SHADER
	mat.set_shader_parameter("aspect", inflow.size.x / maxf(1.0, inflow.size.y))
	mat.set_shader_parameter("ground", 0.93)
	# The chest: halfway across, about 40% down the sprite.
	mat.set_shader_parameter("target", Vector2(0.5, (inflow.size.y - node.size.y * 1.08 + node.size.y * 0.4) / inflow.size.y))
	mat.set_shader_parameter("seed", randf() * 20.0)
	mat.set_shader_parameter("intensity", 0.0)
	inflow.material = mat
	node.add_child(inflow)

	var surge: Tween = inflow.create_tween()
	surge.tween_property(mat, "shader_parameter/intensity", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	surge.tween_interval(THE_MIST_REMEMBERS_SURGE_SECONDS - 0.35)
	surge.tween_property(mat, "shader_parameter/intensity", THE_MIST_REMEMBERS_STEADY_INTENSITY, 1.2).set_trans(Tween.TRANS_SINE)


# ------------------------------------------------------------------
# Public API for future combat/enemy scripts to call into.
# Each one persists through PlayerManager and refreshes the bars.
# ------------------------------------------------------------------

## Returns the mitigated damage actually dealt - the full hit's worth,
## even when it ends up somewhere other than the hero's own HP: fully
## converted into a heal while The Mist Remembers is active (see below), or
## absorbed some/all by Veil of the Forgotten's own HP pool instead - so
## callers that need it (a rival hero's own Wildbond lifesteal, via
## _resolve_enemy_hero_attack()) don't have to re-derive it. While
## The Primordial Hunger's The Test of Time is active the hero is fully immune -
## every hit (a creep's, a rival hero's skill, any ongoing DoT) is
## discarded outright before armor mitigation, The Mist Remembers, or Veil of the
## Forgotten ever get a look at it.
func apply_damage(amount: float) -> float:
	if _the_test_of_time_active:
		return 0.0

	# Dreadlure's Deathlight Lure: boosts every hit the player takes from the
	# rival's own attacks/skills by this level's own bonus_damage_pct -
	# applied to the RAW amount, before armor mitigation, mirroring
	# _deal_fixed_damage_to_enemy()'s own "is_hero_action" check (the
	# mark is about how fragile the PLAYER is). 0.0 (a no-op) while
	# nothing has marked him.
	if _player_deathlight_lure_bonus_pct > 0.0:
		amount *= (1.0 + _player_deathlight_lure_bonus_pct)

	var hero_animator := CreatureAnimator.of(hero_image)
	if hero_animator != null and hero_image != _deferred_hit_node:
		hero_animator.play_hit()

	var reduced: float = _apply_armor_reduction(amount, _hero_armor())
	# Kindled Resolve stacks off of this hit landing - added only after
	# _hero_armor() above already read the stack count, so the stack
	# this hit just earned reduces the NEXT hit, not this one.
	_apply_kindled_resolve_stack()
	# Blood of the Wild's damage reduction stacks on top of armor mitigation
	# rather than replacing it, and only applies while it's active.
	reduced *= (1.0 - _blood_of_the_wild_damage_reduction_pct)

	# The Mist Remembers reverses the hit entirely into a heal - there's no
	# damage left for Veil of the Forgotten to absorb, so that check is
	# skipped for as long as this is active.
	if _the_mist_remembers_active:
		heal(reduced * _the_mist_remembers_heal_conversion_pct)
		return reduced

	if _veil_of_the_forgotten_active:
		var absorbed: float = minf(reduced, _veil_of_the_forgotten_hp)
		_veil_of_the_forgotten_hp -= absorbed
		var overflow: float = reduced - absorbed
		if overflow > 0.0:
			PlayerManager.damage_hero(overflow)
		if _veil_of_the_forgotten_hp <= 0.0:
			_end_veil_of_the_forgotten(true)
		elif absorbed > 0.0:
			_update_veil_shell(hero_image, _veil_of_the_forgotten_hp)
		_refresh_bars()
		_maybe_auto_activate_the_mist_remembers()
		return reduced

	PlayerManager.damage_hero(reduced)
	_refresh_bars()
	_maybe_auto_activate_the_mist_remembers()
	return reduced


func spend_mana(amount: float) -> void:
	PlayerManager.use_mana(amount)
	_refresh_bars()
	# Every hero skill cast pays its mana through here.
	var hero_animator := CreatureAnimator.of(hero_image)
	if hero_animator != null:
		hero_animator.play_cast()


func heal(amount: float) -> void:
	PlayerManager.heal_hero(amount)
	_refresh_bars()


func restore_mana(amount: float) -> void:
	PlayerManager.restore_mana(amount)
	_refresh_bars()


func gain_xp(amount: float) -> void:
	PlayerManager.add_xp(amount)
	var level_ups: Array = PlayerManager.check_level_up(_hero_static)
	_refresh_bars()
	if not level_ups.is_empty():
		PlayLog.event("level_up", {"level": PlayerManager.get_level()})
		_show_level_up_popup(level_ups)


## Displays the LEVEL UP popup for one or more levels gained from a
## single XP gain. Shows the level reached and, for each of the six
## tracked stats, the value from just before the first level-up next
## to the value after the last one - so a multi-level jump reads as
## one clean before/after instead of a stack of popups.
func _show_level_up_popup(level_ups: Array) -> void:
	var first: Dictionary = level_ups[0]
	var last: Dictionary = level_ups[level_ups.size() - 1]
	var old_stats: Dictionary = first["old_stats"]
	var new_stats: Dictionary = last["new_stats"]

	level_up_level_label.text = "Level " + str(last["new_level"])

	_set_stat_row(level_up_strength_old, level_up_strength_new, old_stats["strength"], new_stats["strength"])
	_set_stat_row(level_up_agility_old, level_up_agility_new, old_stats["agility"], new_stats["agility"])
	_set_stat_row(level_up_intelligence_old, level_up_intelligence_new, old_stats["intelligence"], new_stats["intelligence"])
	_set_stat_row(level_up_hp_old, level_up_hp_new, old_stats["hp"], new_stats["hp"])
	_set_stat_row(level_up_mana_old, level_up_mana_new, old_stats["mana"], new_stats["mana"])
	# Damage has no level-up growth yet, so old/new will read the same -
	# still shown for completeness and consistency with the other stats.
	_set_stat_row(level_up_damage_old, level_up_damage_new, old_stats["damage"], new_stats["damage"])

	level_up_popup.visible = true


## Full-screen dim that swallows every click while the level-up flow
## (LevelUpPopup -> SkillChoicePopup -> SkillChoiceDescPopup) is open,
## so the player can't move/attack/cast/use items/end turn/flee or
## click enemies until they've dealt with it. Sits directly beneath
## LevelUpPopup in draw order - above every battle control, below the
## popups themselves. The tutorial's own popups live on
## TutorialManager's separate CanvasLayer, so they stay clickable.
## Driven by the popups' own visibility_changed signals rather than
## each call site, since their visibility is toggled in several places.
var _level_up_input_blocker: ColorRect


func _build_level_up_input_blocker() -> void:
	_level_up_input_blocker = ColorRect.new()
	_level_up_input_blocker.name = "LevelUpInputBlocker"
	_level_up_input_blocker.color = Color(0, 0, 0, 0.4)
	_level_up_input_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_level_up_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_level_up_input_blocker.visible = false
	add_child(_level_up_input_blocker)
	move_child(_level_up_input_blocker, level_up_popup.get_index())

	for popup in [level_up_popup, skill_choice_popup, skill_choice_desc_popup, echo_popup]:
		popup.visibility_changed.connect(_refresh_level_up_input_blocker)
	_refresh_level_up_input_blocker()


func _is_level_up_flow_open() -> bool:
	return level_up_popup.visible or skill_choice_popup.visible or skill_choice_desc_popup.visible


## Also blocks input under EchoPopup (drawn above the blocker, like the
## level-up popups), and opens a held-back EchoPopup once the level-up
## flow closes - deferred, since closing LevelUpPopup can immediately
## open SkillChoicePopup in the same call.
func _refresh_level_up_input_blocker() -> void:
	_level_up_input_blocker.visible = _is_level_up_flow_open() or echo_popup.visible
	if _echo_popup_pending and not _is_level_up_flow_open():
		_show_hero_echo_popup.call_deferred()
	if _victory_pending and not _is_level_up_flow_open():
		_resume_pending_victory.call_deferred()


func _resume_pending_victory() -> void:
	# Deferred for the same reason as the echo popup: closing LevelUpPopup
	# can open SkillChoicePopup in the same call.
	if _victory_pending and not _is_level_up_flow_open():
		_handle_victory()


func _set_stat_row(old_label: Label, new_label: Label, old_value, new_value) -> void:
	old_label.text = _format_stat_value(old_value)
	new_label.text = _format_stat_value(new_value)


## Numeric stats (strength, agility, intelligence, hp, mana) print
## with one decimal place; damage is stored as a "min-max" string and
## just passes through unchanged.
func _format_stat_value(value) -> String:
	if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
		return "%.1f" % float(value)
	return str(value)


func _on_level_up_continue_pressed() -> void:
	level_up_popup.visible = false
	_maybe_show_skill_choice_popup()


## Opens the skill-choice popup if the player has any banked skill
## points AND at least one skill they could currently learn or
## upgrade with one - otherwise there's nothing to do (points with no
## legal use yet just stay banked for a later level).
func _maybe_show_skill_choice_popup() -> void:
	if not PlayerManager.has_spendable_skill_action(_hero_static):
		return
	_refresh_skill_choice_popup()
	skill_choice_popup.visible = true

	match _tutorial_forced_skill_id():
		"pull_of_the_abyss":
			TutorialManager.show_popup(
				"You've got a skill point to spend. Kaelen Varr needs more damage output to clear every "
				+ "enemy here in time - learn Pull of the Abyss."
			)
		"the_sunken_one":
			TutorialManager.show_popup(
				"You've got a skill point to spend. Learn The Sunken One - it's your ultimate, and the "
				+ "single most powerful attack in your kit."
			)


## Rebuilds the skill-choice popup's option buttons from scratch:
## one per skill the player could currently learn (unlearned, level-1
## requirement met) or upgrade (learned, next-level requirement met).
func _refresh_skill_choice_popup() -> void:
	for child in skill_choice_options.get_children():
		child.queue_free()

	var points: int = PlayerManager.get_skill_points()
	var noun: String = "point" if points == 1 else "points"
	skill_choice_points_label.text = "You have %d skill %s to spend" % [points, noun]

	for skill in _hero_static.get("skills", []):
		var skill_id: String = skill.get("id", "")
		if not PlayerManager.can_spend_skill_point_on(skill_id, _hero_static):
			continue

		var current_level: int = PlayerManager.get_skill_level(skill_id)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 40)
		if current_level <= 0:
			btn.text = "Learn " + skill.get("name", skill_id)
		else:
			btn.text = "Upgrade " + skill.get("name", skill_id) + " to Lv " + str(current_level + 1)
		# Clicking an option no longer spends the point right away -
		# it opens the same explanation popup used elsewhere, so the
		# player can read the skill before committing (see
		# _on_skill_choice_option_pressed()).
		btn.pressed.connect(_on_skill_choice_option_pressed.bind(skill))

		# Tutorial support: locks every option except whichever skill
		# the current stage is forcing (see _on_skill_choice_desc_ok_
		# pressed()) - once that one's been taught, any later level-up's
		# skill point is the player's own free choice again, same as a
		# real playthrough.
		var forced_skill_id: String = _tutorial_forced_skill_id()
		if forced_skill_id != "" and skill_id != forced_skill_id:
			btn.disabled = true

		skill_choice_options.add_child(btn)


## Opens the description popup for a skill the player is considering
## learning/upgrading with a banked point. Nothing is spent yet - that
## only happens if they confirm with OK (_on_skill_choice_desc_ok_pressed).
func _on_skill_choice_option_pressed(skill: Dictionary) -> void:
	var skill_id: String = skill.get("id", "")
	_pending_level_up_skill_id = skill_id

	var current_level: int = PlayerManager.get_skill_level(skill_id)
	var target_level: int = 1 if current_level <= 0 else current_level + 1
	var action_text: String
	if current_level <= 0:
		action_text = "Learning this will put it at level 1."
	else:
		action_text = "Upgrading this will bring it to level %d." % target_level

	# The level being learned/upgraded TO, not the current one - shows
	# what the player is actually about to get, same reasoning
	# action_text above already uses.
	var level_data: Dictionary = GameManager.get_skill_level_data(skill, target_level)
	var stats_summary: String = GameManager.format_skill_level_stats(level_data)

	skill_choice_desc_name_label.text = skill.get("name", "")
	skill_choice_desc_label.text = skill.get("description", "") + "\n\n" + stats_summary + "\n\n" + action_text

	# Swap the list popup for the description popup - Cancel brings
	# the list back rather than closing everything, so the player can
	# still look at (or pick) a different option.
	skill_choice_popup.visible = false
	skill_choice_desc_popup.visible = true


## Confirms the pending skill: spends the point, refreshes the skill
## buttons (a newly learned skill needs its button re-enabled), then
## either loops back to the choice popup for another point/option, or
## closes everything once there's nothing left to spend.
func _on_skill_choice_desc_ok_pressed() -> void:
	skill_choice_desc_popup.visible = false

	var skill_id: String = _pending_level_up_skill_id
	_pending_level_up_skill_id = ""

	if skill_id == "":
		return

	if PlayerManager.spend_skill_point(skill_id, _hero_static):
		# Everything below reacts to a specific skill being learned
		# purely for the guided tutorial's own scripted beats (forcing
		# the next action, popping up its own explanation) - none of it
		# should ever fire for a normal playthrough, so it's all gated
		# behind TutorialManager.is_active. Without this, any player
		# leveling up Kaelen Varr's Pull of the Abyss or The Sunken One outside the
		# tutorial would still get stage 3's "The Sunken One is yours now..."
		# popup and its action lock, since TutorialManager.show_popup()/
		# set_allowed_actions() don't check is_active themselves.
		if TutorialManager.is_active:
			if skill_id == "pull_of_the_abyss":
				_tutorial_taught_pull_of_the_abyss = true
			elif skill_id == "the_sunken_one":
				_tutorial_taught_the_sunken_one = true
				# Starts the reinforcement countdown fresh from HERE rather
				# than from stage 3's battle start - landing that first kill
				# (to trigger this level-up) can itself take several attacks
				# against a melee creep's real HP, so counting from turn 0
				# let reinforcements arrive mid-leveling, before The Sunken One
				# even existed to answer them - roughly doubling the enemy
				# count on top of the original roster and proving fatal.
				_next_reinforcement_turn = _turn_count + 2
				_advance_tutorial_stage3_step("attack_before_reinforcements")
		_recruited = PlayerManager.get_recruited_hero()
		_populate_skill_buttons()
		_update_action_buttons()

	if PlayerManager.has_spendable_skill_action(_hero_static):
		_refresh_skill_choice_popup()
		skill_choice_popup.visible = true
	else:
		skill_choice_popup.visible = false


## Backs out of the description popup without spending anything,
## returning to the list so the player can check other skills or pick
## the same one again.
func _on_skill_choice_desc_cancel_pressed() -> void:
	_pending_level_up_skill_id = ""
	skill_choice_desc_popup.visible = false
	skill_choice_popup.visible = true


# ------------------------------------------------------------------
# Turn actions: at most one move and one attack per turn.
# ------------------------------------------------------------------

## Heroes move faster than enemies as part of their stats - a speed
## of 1.5-2.7 rounds to 2-3 columns per move, while every enemy
## always takes exactly one column per turn (see _enemy_turn()). Adds
## Blood of the Wild's bonus columns while it's active (see
## _update_blood_of_the_wild_state()), plus a flat +1 column while Rootveil is active - moving unseen covers more ground, same "bonus on
## top of the normal speed-based distance" shape Blood of the Wild's own
## bonus already has, just gated on _rootveil_active instead of an
## HP threshold.
func _hero_move_distance() -> int:
	var speed: float = float(_recruited.get("stats", {}).get("speed", 1.0))
	var rootveil_bonus: int = 1 if _rootveil_active else 0
	return maxi(1, roundi(speed)) + _blood_of_the_wild_bonus_movement + rootveil_bonus


## Whether the hero currently fights at range - normally just his
## range_type stat, but Beast of the Elderwild forces melee for its duration
## regardless of that stat (see _activate_beast_of_the_elderwild()).
func _is_ranged_hero() -> bool:
	if _beast_of_the_elderwild_active:
		return false
	return _hero_static.get("range_type", "Melee") == "Range"


## Melee heroes only fight by standing exactly on an enemy's column,
## so a multi-column move that would otherwise carry them past one
## stops right on top of it instead - covering less distance than
## their full speed, but landing somewhere they can actually attack.
## `_is_column_enemy_frostbound_rupture_blocked()` stops the walk one column
## short of entering a rival-walled one, exactly like it already stops
## one column short of an occupied one below - a wall blocks movement
## the same way an enemy standing in the way does, it just isn't a
## valid landing spot either (unlike an enemy's column, which IS - see
## the early return right after).
func _melee_move_target(start: int, direction: int, distance: int) -> int:
	var pos: int = start

	for i in range(distance):
		var next_pos := pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if _is_column_enemy_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos

		if not _get_enemy_at(pos).is_empty():
			return pos

	return pos


## A ranged hero's own movement is normally a single unobstructed jump
## (see _hero_move()) - this only exists so a rival's Frostbound Rupture wall
## still stops it early, same "can't move into a blocked column" rule
## _melee_move_target() enforces for a melee one, just without that
## function's own "stop on top of an enemy" rule (a ranged hero doesn't
## need to stand ON an enemy's column to fight it).
func _ranged_move_target(start: int, direction: int, distance: int) -> int:
	var pos: int = start

	for i in range(distance):
		var next_pos := pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if _is_column_enemy_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos

	return pos


## Hunting Instinct's own movement rule: walks up to `distance` columns
## from `start` in `direction`, stopping early at the board edge, a
## rival's Frostbound Rupture wall, OR - unlike a plain ranged move, and
## regardless of the hero's own range_type - the first enemy's column
## along the way, same "stop on top of an enemy" rule
## _melee_move_target() already uses. Returns both the landing column
## and whatever enemy it stopped on ({} if it ran the full distance
## clean), for _hero_move() to deal Hunting Instinct's own charge_damage
## to.
func _hunting_instinct_move_target(start: int, direction: int, distance: int) -> Dictionary:
	var pos: int = start
	var hit_enemy: Dictionary = {}

	for i in range(distance):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos

		var enemy_here: Dictionary = _get_enemy_at(pos)
		if not enemy_here.is_empty():
			hit_enemy = enemy_here
			break

	return {"pos": pos, "hit_enemy": hit_enemy}


## Activates Hunting Instinct: arms this level's own bonus_movement/
## charge_damage_pct for `level_data.duration` turns. Doesn't move the
## hero himself - only _hero_move()'s own read of
## _hunting_instinct_turns_remaining changes what his NEXT normal moves
## do. Always "succeeds" - no target or range requirement, same as
## every other self-cast buff.
func _activate_hunting_instinct(level_data: Dictionary) -> void:
	_hunting_instinct_bonus_movement = int(level_data.get("bonus_movement", 0))
	_hunting_instinct_charge_damage_pct = float(level_data.get("charge_damage_pct", 0.0))
	_hunting_instinct_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_hunting_instinct()), same as
	# every other duration-based buff. The bonus itself is already live
	# the instant this returns, same as Woven Flesh's own bonus_armor -
	# only the countdown toward it running out is delayed.
	_hunting_instinct_duration_pending_start = true

	_show_message_over_hero("Hunting Instinct!")


## Ticks Hunting Instinct's duration down once per End Turn, same timing
## (and same "the casting turn doesn't count" skip) as every other
## duration-based buff.
func _tick_hunting_instinct() -> void:
	if _hunting_instinct_turns_remaining <= 0:
		return

	if _hunting_instinct_duration_pending_start:
		_hunting_instinct_duration_pending_start = false
		return

	_hunting_instinct_turns_remaining -= 1
	if _hunting_instinct_turns_remaining <= 0:
		_end_hunting_instinct()


## Ends Hunting Instinct once its duration runs out.
func _end_hunting_instinct() -> void:
	_hunting_instinct_turns_remaining = 0
	_hunting_instinct_bonus_movement = 0
	_hunting_instinct_charge_damage_pct = 0.0
	_hunting_instinct_duration_pending_start = false

	_show_message_over_hero("Hunting Instinct wears off")


func _hero_move(direction: int) -> void:
	if _battle_over or _has_acted_this_turn or _rival_fx_in_flight:
		return

	if _player_root_turns_left > 0:
		_show_message_over_hero("Rooted!")
		return

	if _the_test_of_time_active:
		return

	if _kiss_the_wastes_active:
		_show_message_over_hero("Focused on Kiss the Wastes!")
		return

	if _is_column_enemy_frostbound_rupture_blocked(_hero_pos_index):
		_show_message_over_hero("Frozen in place!")
		return

	_cancel_targeting()

	var generation_before: int = _stage_generation
	var distance: int = _hero_move_distance()

	if _hunting_instinct_turns_remaining > 0:
		distance += _hunting_instinct_bonus_movement
		var instinct_result: Dictionary = _hunting_instinct_move_target(_hero_pos_index, direction, distance)
		_hero_pos_index = int(instinct_result["pos"])
		var charged_enemy: Dictionary = instinct_result["hit_enemy"]
		hero_image.flip_h = direction < 0
		var from_global: Vector2 = hero_image.global_position
		var landing_shift := Vector2(_index_to_x(_hero_pos_index) - hero_image.position.x, 0.0)
		DreadlureFX.surge(_fx_layer, hero_image, from_global, from_global + landing_shift, charged_enemy.get("node") if not charged_enemy.is_empty() else null)
		if not charged_enemy.is_empty():
			var charge_damage: float = _roll_hero_damage() * _hunting_instinct_charge_damage_pct
			_deal_fixed_damage_to_enemy(charged_enemy, charge_damage)
	elif _is_ranged_hero():
		_hero_pos_index = _ranged_move_target(_hero_pos_index, direction, distance)
	else:
		_hero_pos_index = _melee_move_target(_hero_pos_index, direction, distance)

	# Hero art is drawn facing right by default (see _spawn_enemy()'s own
	# note on art orientation), so moving left mirrors it to face that way.
	hero_image.flip_h = direction < 0

	_update_hero_position()

	# A Hunting Instinct charge landing the killing blow could clear the
	# stage (or win a hero fight) and move on to a fresh encounter -
	# same bail-out every skill resolver already uses before spending
	# the turn, needed here for the first time since this is the first
	# path through _hero_move() that can ever deal damage.
	if _battle_over or _stage_generation != generation_before:
		return

	_log_pending_action = "move"
	_mark_turn_used()


## Fleeing a hero fight leaves the rival alive and, unlike an actual
## loss, was never going to be caught by _handle_defeat()'s own
## restock - so it needs its own copy of that same "the rival gets a
## chance to restock before the player can meet them again" step (see
## EnemyHeroManager.npc_shop()) or a fled fight would let
## the player whittle a rival's potions down for free, over and over,
## with no gold cost ever attached the way losing to them does. Only
## fires during an actual hero fight - fleeing a normal creep stage has
## no rival hero to restock.
func _on_flee_pressed() -> void:
	_play_log_stage_end("flee")
	if _in_hero_fight:
		EnemyHeroManager.npc_shop(_enemy_hero_id)
	get_tree().change_scene_to_file("res://scenes/Map.tscn")


func _on_move_left_pressed() -> void:
	_hero_move(-1)


func _on_move_right_pressed() -> void:
	_hero_move(1)


func _on_attack_pressed() -> void:
	if _battle_over or _has_acted_this_turn or _rival_fx_in_flight:
		return

	if _the_test_of_time_active:
		return

	if _kiss_the_wastes_active:
		_show_message_over_hero("Focused on Kiss the Wastes!")
		return

	_log_pending_action = "attack"
	if _is_ranged_hero():
		_start_ranged_targeting()
	else:
		_resolve_melee_attack()


func _resolve_melee_attack() -> void:
	var target: Dictionary = _get_enemy_at(_hero_pos_index)
	if target.is_empty():
		# Nothing real here - but a guard a rival Last Empress raised may
		# be standing in this column, and a melee blow can fell it.
		var rival_guard: Dictionary = _enemy_guard_at(_hero_pos_index)
		if not rival_guard.is_empty():
			_attack_enemy_guard(rival_guard)
			return
		_show_message_over_hero("No enemy in range")
		return
	_apply_hero_attack(target)


## The hero's plain melee Attack on one of the rival's guards in his own
## column: his usual attack lunge and a freshly-rolled hero hit, mitigated
## by the boss's own effective armor (a guard has no defense stat of its
## own). Spends the turn like any Attack. None of the on-hit extras of
## _apply_hero_attack() (cleaves, lifesteal, knockback) apply - they're
## all written around a real enemy.
func _attack_enemy_guard(rival_guard: Dictionary) -> void:
	var generation_before: int = _stage_generation
	var hero_animator := CreatureAnimator.of(hero_image)
	if hero_animator != null:
		hero_animator.play_attack(-1.0 if hero_image.flip_h else 1.0, true)
	var boss: Dictionary = _get_hero_fight_boss()
	var armor: float = _enemy_hero_effective_armor(boss) if not boss.is_empty() else 0.0
	_deal_damage_to_enemy_guard(rival_guard, _apply_armor_reduction(_roll_hero_damage(), armor))
	if _battle_over or _stage_generation != generation_before:
		return
	_mark_turn_used()


## How many columns away a ranged hero can hit, from their Range
## stat: 200-300 -> 1 column, 300-400 -> 2 columns, and so on
## (+100 range per extra column) - plus The Primordial Hunger's Frostbound Fangs
## bonus_range while it's active, folded straight in so it stretches
## every consumer of this helper (a plain ranged Attack, Chilling
## Touch's own "same as attack range" targeting) the same way.
func _hero_attack_column_range() -> int:
	var range_stat: float = float(_recruited.get("stats", {}).get("range", 200))
	return maxi(1, floori((range_stat - 200.0) / 100.0) + 1) + _frostbound_fangs_bonus_range


func _start_ranged_targeting() -> void:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return

	_targeting_mode = true
	_targeting_purpose = "attack"
	_highlight_valid_targets()


## Thornbind's target picking: same column-range/highlight mechanism as
## a ranged Attack (_start_ranged_targeting), but resolves through
## _resolve_thornbind_cast() on click instead of a plain attack.
## Returns false (and shows a message) if nothing is in range - the
## caller then knows not to spend mana/cooldown/the turn.
func _start_thornbind_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "thornbind"
	_pending_thornbind_level_data = level_data
	_highlight_valid_targets()
	return true


## Whisper of the Veil's own targeting range, in columns - fixed regardless of
## the hero's Range stat (unlike a plain ranged Attack or Thornbind,
## which both scale with it via _hero_attack_column_range()), since
## it's a bolt of mist rather than a physical attack.
const WHISPER_OF_THE_VEIL_RANGE := 2


## Whisper of the Veil's target picking: highlights any enemy within
## WHISPER_OF_THE_VEIL_RANGE columns AND the hero's own portrait, since Whisper of the Veil
## can be cast on either - a damaging bolt on an enemy, or a costly-
## but-net-positive heal on Morvael himself (see
## _resolve_whisper_of_the_veil_enemy_cast()/_resolve_whisper_of_the_veil_self_cast()).
## Self-casting is always available regardless of range, so - unlike
## Thornbind/ranged Attack - this never fails for lack of a target;
## it only bails out (returning false) if the player is already stuck
## with no enemies AND can't afford the HP cost, in which case there's
## nothing legal to click at all.
func _start_whisper_of_the_veil_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", WHISPER_OF_THE_VEIL_RANGE))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	var hp_cost: float = float(level_data.get("hp_cost", 0))
	var can_self_cast: bool = float(_recruited.get("current_hp", 0)) >= hp_cost

	if _valid_targets.is_empty() and not can_self_cast:
		_show_message_over_hero("No enemy in range and not enough HP")
		return false

	_targeting_mode = true
	_targeting_purpose = "whisper_of_the_veil"
	_pending_whisper_of_the_veil_level_data = level_data
	_highlight_valid_targets()
	if can_self_cast:
		_highlight_hero_self_target()
	return true


## Kaelen Varr's Drowned Surge target picking: same column-range/highlight
## mechanism as Thornbind/ranged Attack, but the range itself comes
## straight from this level's own `range` field (a constant 3 at every
## level per the design doc) rather than _hero_attack_column_range() -
## Drowned Surge lands where Kaelen Varr calls it down, regardless of his Range
## stat, the same way Whisper of the Veil's own fixed WHISPER_OF_THE_VEIL_RANGE does.
## Returns false (and shows a message) if nothing is in range.
func _start_drowned_surge_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 3))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "drowned_surge"
	_pending_drowned_surge_level_data = level_data
	_highlight_valid_targets()
	return true


## Kaelen Varr's Undertow target picking: same column-range/
## highlight mechanism as Drowned Surge, using this level's own `range` field
## (2-5 columns, growing with level, unlike Drowned Surge's constant 3).
## Returns false (and shows a message) if nothing is in range.
func _start_undertow_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 2))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "undertow"
	_pending_undertow_level_data = level_data
	_highlight_valid_targets()
	return true


## Dreadlure's Deathlight Lure target picking: same column-range/highlight
## mechanism as every other targeted skill above, using this level's
## own `range` field (4-6 columns, growing with level). Returns false
## (and shows a message) if nothing is in range.
func _start_deathlight_lure_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 4))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "deathlight_lure"
	_pending_deathlight_lure_level_data = level_data
	_highlight_valid_targets()
	return true


## Solara's Hope of the Fallen target picking: same column-range/highlight
## mechanism as every other targeted skill above, using this level's
## own `range` field (4-7 columns, growing with level) - the same
## distance the damage formula scales off of (see
## _resolve_hope_of_the_fallen_cast()), so a target at the very edge of range
## is exactly where the "Max Damage" table column comes from. Returns
## false (and shows a message) if nothing is in range.
func _start_hope_of_the_fallen_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 4))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "hope_of_the_fallen"
	_pending_hope_of_the_fallen_level_data = level_data
	_highlight_valid_targets()
	return true


## Lunara's Moonfall Lance target picking: same column-range/highlight
## mechanism as every other targeted skill above, using this level's own
## `range` field (4-7 columns, growing with level). Returns false (and
## shows a message) if nothing is in range.
func _start_moonfall_lance_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 4))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "moonfall_lance"
	_pending_moonfall_lance_level_data = level_data
	_highlight_valid_targets()
	return true


## The Last Empress's Shackles target picking: same column-range/highlight
## mechanism as every other targeted skill above, using this level's
## own `range` field (3-6 columns, growing with level) rather than the
## hero's normal attack range - Shackles reaches further than a plain
## Attack. Returns false (and shows a message) if nothing is in range.
func _start_shackles_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 3))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "shackles"
	_pending_shackles_level_data = level_data
	_highlight_valid_targets()
	return true


## Cinder's Chainfire target picking: same column-range/highlight
## mechanism as every other targeted skill above, using this level's
## own `range` field (3-5 columns, growing with level).
## Returns false (and shows a message) if nothing is in range.
func _start_chainfire_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 3))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "chainfire"
	_pending_chainfire_level_data = level_data
	_highlight_valid_targets()
	return true


## Cinder's Cinderbomb target picking: same column-range/highlight
## mechanism as every other targeted skill above, using this level's
## own `range` field (5-7 columns, growing with level) - separate from
## the `radius` field used for the AoE once it's planted (see
## _resolve_cinderbomb_cast()/_tick_cinderbomb()). Returns false (and shows a
## message) if nothing is in range.
func _start_cinderbomb_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 5))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "cinderbomb"
	_pending_cinderbomb_level_data = level_data
	_highlight_valid_targets()
	return true


## Nhal's Mark of Stillness target picking: same column-range/
## highlight mechanism as every other targeted skill above, using this
## level's own `range` field (2-4 columns, growing with level).
## Returns false (and shows a message) if nothing is in range.
func _start_mark_of_stillness_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 2))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "mark_of_stillness"
	_pending_mark_of_stillness_level_data = level_data
	_highlight_valid_targets()
	return true


## The Hollow Cold's own targeting range, in columns - fixed regardless of
## level or the hero's Range stat (unlike Mark of Stillness's own per-level
## range), since it's a cast point, not a stat-scaled attack.
const THE_HOLLOW_COLD_RANGE := 3


## Nhal's The Hollow Cold target picking: same column-range/
## highlight mechanism as every other targeted skill above, but always
## at THE_HOLLOW_COLD_RANGE - the level only changes the AoE radius applied
## around whichever enemy gets clicked (see _resolve_the_hollow_cold_cast()),
## never the targeting range itself. Returns false (and shows a
## message) if nothing is in range.
func _start_the_hollow_cold_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= THE_HOLLOW_COLD_RANGE:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "the_hollow_cold"
	_pending_the_hollow_cold_level_data = level_data
	_highlight_valid_targets()
	return true


## Nhal's Touch of the First Cold target picking: same column-
## range/highlight mechanism as every other targeted skill above, but
## using the hero's own normal attack range (_hero_attack_column_
## range(), the same stat-scaled helper a plain ranged Attack/Thornbind
## use) rather than a skill-specific field - Touch of the First Cold is
## explicitly "attack range", not its own distance. Returns false (and
## shows a message) if nothing is in range.
func _start_touch_of_the_first_cold_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "touch_of_the_first_cold"
	_pending_touch_of_the_first_cold_level_data = level_data
	_highlight_valid_targets()
	return true


## Nhal's Return to the Void target picking: no range limit at
## all, unlike every other targeted skill above - the design doc's own
## "targets an enemy anywhere on the field" - so every living,
## targetable enemy is a valid target regardless of column distance
## from the hero. Returns false (and shows a message) only if there's
## no enemy left to target at all.
func _start_return_to_the_void_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "return_to_the_void"
	_pending_return_to_the_void_level_data = level_data
	_highlight_valid_targets()
	return true


## The Primordial Hunger's Maddening Roar target picking: same column-range/
## highlight mechanism as Touch of the First Cold - the hero's own normal attack
## range (_hero_attack_column_range()), since the design doc calls for
## "an enemy in range (range of normal attack)" rather than a skill-
## specific distance. Returns false (and shows a message) if nothing is
## in range.
func _start_maddening_roar_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "maddening_roar"
	_pending_maddening_roar_level_data = level_data
	_highlight_valid_targets()
	return true


## The Primordial Hunger's The Hunger Calls target picking: same column-range/
## highlight mechanism as Maddening Roar/Touch of the First Cold - the hero's own
## normal attack range (_hero_attack_column_range()), per the design
## doc's own "an enemy in range (normal attack range)". Returns false
## (and shows a message) if nothing is in range.
func _start_the_hunger_calls_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "the_hunger_calls"
	_pending_the_hunger_calls_level_data = level_data
	_highlight_valid_targets()
	return true


## Frost Daughter's Rimecleaver target picking: same column-range/
## highlight mechanism as every other "normal attack range" targeted
## skill above (_hero_attack_column_range()). Returns false (and shows
## a message) if nothing is in range.
func _start_rimecleaver_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "rimecleaver"
	_pending_rimecleaver_level_data = level_data
	_highlight_valid_targets()
	return true


## Raze's Three Cheers target picking: same "normal attack range"
## gate (_hero_attack_column_range()) every other attack-range targeted
## skill above uses - Three Cheers is a volley of shots at ONE marked
## target, not an extended-range skill of its own, so it shares the
## plain Attack's own reach rather than a level-specific `range` field.
## Returns false (and shows a message) if nothing is in range.
func _start_three_cheers_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "three_cheers"
	_pending_three_cheers_level_data = level_data
	_highlight_valid_targets()
	return true


## Frost Daughter's Winter's Grip target picking: same column-range/
## highlight mechanism as every other "normal attack range" targeted
## skill above (_hero_attack_column_range()). Returns false (and shows
## a message) if nothing is in range.
func _start_winters_grip_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = _hero_attack_column_range()
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "winters_grip"
	_pending_winters_grip_level_data = level_data
	_highlight_valid_targets()
	return true


## Skarn's Frostbound Rupture target picking: unlike every "normal attack range"
## targeted skill above, this uses the skill's OWN level_data.range
## field instead of _hero_attack_column_range() - same reasoning as
## Drowned Surge's own targeting (_start_drowned_surge_targeting()), since Skarn
## fights at melee range but Frostbound Rupture is thrown well past it. Returns
## false (and shows a message) if nothing is in range.
func _start_frostbound_rupture_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 0))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "frostbound_rupture"
	_pending_frostbound_rupture_level_data = level_data
	_highlight_valid_targets()
	return true


## Skarn's Charge target picking: same skill-specific level_data.range
## reasoning as Frostbound Rupture's own targeting - Skarn fights at melee range,
## but Charges well past it. Returns false (and shows a
## message) if nothing is in range.
func _start_charge_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 0))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "charge"
	_pending_charge_level_data = level_data
	_highlight_valid_targets()
	return true


## Skarn's Glacier Breaker target picking: strictly melee range (sharing
## his own column, same as a plain melee Attack - _resolve_melee_
## attack()) rather than any column-range field, since the design doc
## calls for "melee range" specifically. Returns false (and shows a
## message) if nothing shares his column.
func _start_glacier_breaker_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if enemy["pos_index"] == _hero_pos_index:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "glacier_breaker"
	_pending_glacier_breaker_level_data = level_data
	_highlight_valid_targets()
	return true


## The Rootmother's Sanguine Bloom target picking: same column-range/
## highlight mechanism as every other targeted skill above, using this
## level's own fixed range field (a constant 2 columns per the design
## doc, still stored per-level like every other skill's own range).
## Returns false (and shows a message) if nothing is in range.
func _start_sanguine_bloom_targeting(level_data: Dictionary) -> bool:
	_cancel_targeting()

	var col_range: int = int(level_data.get("range", 0))
	for enemy in _enemies:
		if _is_target_hidden(enemy):
			continue
		if _distance(enemy["pos_index"], _hero_pos_index) <= col_range:
			_valid_targets.append(enemy)

	if _valid_targets.is_empty():
		_show_message_over_hero("No enemy in range")
		return false

	_targeting_mode = true
	_targeting_purpose = "sanguine_bloom"
	_pending_sanguine_bloom_level_data = level_data
	_highlight_valid_targets()
	return true


## Marks every enemy currently in `_valid_targets` with a bright,
## pulsing highlight (TARGET_HIGHLIGHT_COLOR/_PULSE_COLOR) instead of
## the flat, easy-to-miss pastel tint each _start_X_targeting() function
## used to set on its own - called by every one of them right after
## `_valid_targets` is actually populated. Each node's own pulse tween
## is tracked in _target_highlight_tweens so _cancel_targeting() can
## kill it before resetting modulate back to normal - an untracked,
## still-running tween would just fight that reset every frame.
func _highlight_valid_targets() -> void:
	for enemy in _valid_targets:
		var node: TextureRect = enemy["node"]
		node.modulate = TARGET_HIGHLIGHT_COLOR
		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(node, "modulate", TARGET_HIGHLIGHT_PULSE_COLOR, 0.4).set_trans(Tween.TRANS_SINE)
		tween.tween_property(node, "modulate", TARGET_HIGHLIGHT_COLOR, 0.4).set_trans(Tween.TRANS_SINE)
		_target_highlight_tweens.append(tween)


## Same bright, pulsing treatment as _highlight_valid_targets(), just on
## the hero's own portrait (HERO_TARGET_HIGHLIGHT_COLOR/_PULSE_COLOR's
## green, not TARGET_HIGHLIGHT_COLOR's gold) - for a skill that can be
## self-cast (right now, only Whisper of the Veil's _start_whisper_of_the_veil_targeting(),
## when can_self_cast is true). Tracked in the same
## _target_highlight_tweens _cancel_targeting() already kills and resets
## (via _update_hero_visibility()) - one shared cleanup handles both the
## enemy and hero highlights, whichever combination is currently lit.
func _highlight_hero_self_target() -> void:
	hero_image.modulate = HERO_TARGET_HIGHLIGHT_COLOR
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(hero_image, "modulate", HERO_TARGET_HIGHLIGHT_PULSE_COLOR, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(hero_image, "modulate", HERO_TARGET_HIGHLIGHT_COLOR, 0.4).set_trans(Tween.TRANS_SINE)
	_target_highlight_tweens.append(tween)


## Clears any still-highlighted valid-target tint and resets the hero's
## own portrait modulate back to whatever it's SUPPOSED to be right now
## (_update_hero_visibility(), not a hardcoded Color(1,1,1)) - Whisper of the
## Veil's own self-target highlight tints hero_image the same way a
## valid enemy target gets tinted, so this needs to undo that without
## also stomping Depthsveil's/Rootveil's own invisibility fade
## if either is still active. _cancel_targeting() runs constantly -
## every _end_turn() call, every new targeting session - so a hardcoded
## reset here was clobbering the invisibility fade back to fully opaque
## one turn after casting Rootveil, even though _rootveil_
## active stayed true for its whole duration. Kills every pulsing
## highlight tween FIRST (see _highlight_valid_targets()) so none of
## them are still running to immediately overwrite the reset below.
func _cancel_targeting() -> void:
	for tween in _target_highlight_tweens:
		if tween:
			tween.kill()
	_target_highlight_tweens.clear()
	for enemy in _valid_targets:
		if is_instance_valid(enemy["node"]):
			enemy["node"].modulate = Color(1, 1, 1)
			# A hit flash running on it right now (_sprite_flash()) would
			# otherwise fade back to the highlight it started from.
			if enemy["node"].has_meta(SPRITE_FLASH_REST_META):
				enemy["node"].set_meta(SPRITE_FLASH_REST_META, Color(1, 1, 1))
	_update_hero_visibility()
	_valid_targets.clear()
	_targeting_mode = false
	_targeting_purpose = "attack"
	_pending_thornbind_level_data = {}
	_pending_whisper_of_the_veil_level_data = {}


func _on_enemy_gui_input(event: InputEvent, enemy: Dictionary) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_enemy_clicked(_pick_enemy_under_mouse(enemy))


## Every enemy's TextureRect catches clicks across its whole rectangle,
## transparent padding included - so where two sprites overlap, whichever
## was added to enemies_layer last swallows the click even when the
## cursor is plainly over the creature drawn behind it. This re-resolves
## the click against actual opaque pixels instead: of every enemy whose
## sprite is visibly under the cursor, prefer the topmost one that's
## currently a valid target (so a non-targetable sprite overlapping a
## targetable one doesn't block it), else the topmost opaque one. Falls
## back to `fallback` (the node Godot actually delivered the click to)
## when the cursor is only over transparent padding.
func _pick_enemy_under_mouse(fallback: Dictionary) -> Dictionary:
	var hits: Array = []
	for enemy in _enemies:
		var node: TextureRect = enemy.get("node")
		if node == null or not is_instance_valid(node) or not node.is_visible_in_tree():
			continue
		if _is_texture_rect_opaque_at(node, node.get_local_mouse_position()):
			hits.append(enemy)
	if hits.is_empty():
		return fallback
	# Topmost first - later siblings draw over earlier ones.
	hits.sort_custom(func(a, b): return a["node"].get_index() > b["node"].get_index())
	if _targeting_mode:
		for enemy in hits:
			if _valid_targets.has(enemy):
				return enemy
	return hits[0]


# Texture -> decompressed Image, so repeated clicks don't re-fetch the
# texture data from the GPU every time.
var _hit_test_image_cache: Dictionary = {}


## Whether `node`'s texture has a visible (non-transparent) pixel at
## `local_pos` - accounts for STRETCH_KEEP_ASPECT's centered letterboxing
## and flip_h, the two modes _spawn_enemy() actually uses.
func _is_texture_rect_opaque_at(node: TextureRect, local_pos: Vector2) -> bool:
	if not Rect2(Vector2.ZERO, node.size).has_point(local_pos):
		return false
	var texture: Texture2D = node.texture
	if texture == null:
		return false
	var image: Image = _hit_test_image_cache.get(texture)
	if image == null:
		image = texture.get_image()
		if image == null:
			return true
		if image.is_compressed():
			image = image.duplicate()
			image.decompress()
		_hit_test_image_cache[texture] = image
	var tex_size: Vector2 = Vector2(image.get_size())
	var s: float = minf(node.size.x / tex_size.x, node.size.y / tex_size.y)
	var offset: Vector2 = (node.size - tex_size * s) / 2.0
	var px: Vector2 = (local_pos - offset) / s
	if px.x < 0 or px.y < 0 or px.x >= tex_size.x or px.y >= tex_size.y:
		return false
	var x: int = int(px.x)
	if node.flip_h:
		x = int(tex_size.x) - 1 - x
	return image.get_pixel(x, int(px.y)).a > 0.1


func _on_enemy_clicked(enemy: Dictionary) -> void:
	if not _targeting_mode or _battle_over or _has_acted_this_turn or _rival_fx_in_flight:
		return
	if not _valid_targets.has(enemy):
		return
	if not _tutorial_allows_enemy_click(enemy):
		return

	# Resolve to whichever enemy on this same column is actually lowest
	# HP, same as a melee Attack/Barbed Lunge/the bear already do via
	# _get_enemy_at() - clicking a specific sprite just picks the
	# column/spot to strike, not necessarily which of several stacked
	# enemies there takes the hit. Falls back to the clicked enemy
	# itself on the (should-be-impossible) case _get_enemy_at() finds
	# nothing at its own column.
	var resolved: Dictionary = _get_enemy_at(enemy["pos_index"])
	if not resolved.is_empty():
		enemy = resolved

	var purpose: String = _targeting_purpose
	var thornbind_level_data: Dictionary = _pending_thornbind_level_data
	var whisper_of_the_veil_level_data: Dictionary = _pending_whisper_of_the_veil_level_data
	var drowned_surge_level_data: Dictionary = _pending_drowned_surge_level_data
	var undertow_level_data: Dictionary = _pending_undertow_level_data
	var deathlight_lure_level_data: Dictionary = _pending_deathlight_lure_level_data
	var hope_of_the_fallen_level_data: Dictionary = _pending_hope_of_the_fallen_level_data
	var moonfall_lance_level_data: Dictionary = _pending_moonfall_lance_level_data
	var shackles_level_data: Dictionary = _pending_shackles_level_data
	var chainfire_level_data: Dictionary = _pending_chainfire_level_data
	var cinderbomb_level_data: Dictionary = _pending_cinderbomb_level_data
	var three_cheers_level_data: Dictionary = _pending_three_cheers_level_data
	var kiss_the_wastes_level_data: Dictionary = _pending_kiss_the_wastes_level_data
	var mark_of_stillness_level_data: Dictionary = _pending_mark_of_stillness_level_data
	var the_hollow_cold_level_data: Dictionary = _pending_the_hollow_cold_level_data
	var touch_of_the_first_cold_level_data: Dictionary = _pending_touch_of_the_first_cold_level_data
	var return_to_the_void_level_data: Dictionary = _pending_return_to_the_void_level_data
	var maddening_roar_level_data: Dictionary = _pending_maddening_roar_level_data
	var the_hunger_calls_level_data: Dictionary = _pending_the_hunger_calls_level_data
	var rimecleaver_level_data: Dictionary = _pending_rimecleaver_level_data
	var winters_grip_level_data: Dictionary = _pending_winters_grip_level_data
	var frostbound_rupture_level_data: Dictionary = _pending_frostbound_rupture_level_data
	var charge_level_data: Dictionary = _pending_charge_level_data
	var glacier_breaker_level_data: Dictionary = _pending_glacier_breaker_level_data
	var sanguine_bloom_level_data: Dictionary = _pending_sanguine_bloom_level_data
	_cancel_targeting()

	if purpose == "thornbind":
		_resolve_thornbind_cast(enemy, thornbind_level_data)
	elif purpose == "whisper_of_the_veil":
		_resolve_whisper_of_the_veil_enemy_cast(enemy, whisper_of_the_veil_level_data)
	elif purpose == "drowned_surge":
		_resolve_drowned_surge_cast(enemy, drowned_surge_level_data)
	elif purpose == "undertow":
		_resolve_undertow_cast(enemy, undertow_level_data)
	elif purpose == "deathlight_lure":
		_resolve_deathlight_lure_cast(enemy, deathlight_lure_level_data)
	elif purpose == "hope_of_the_fallen":
		_resolve_hope_of_the_fallen_cast(enemy, hope_of_the_fallen_level_data)
	elif purpose == "moonfall_lance":
		_resolve_moonfall_lance_cast(enemy, moonfall_lance_level_data)
	elif purpose == "shackles":
		_resolve_shackles_cast(enemy, shackles_level_data)
	elif purpose == "chainfire":
		_resolve_chainfire_cast(enemy, chainfire_level_data)
	elif purpose == "cinderbomb":
		_resolve_cinderbomb_cast(enemy, cinderbomb_level_data)
	elif purpose == "three_cheers":
		_resolve_three_cheers_cast(enemy, three_cheers_level_data)
	elif purpose == "kiss_the_wastes":
		_resolve_kiss_the_wastes_cast(enemy, kiss_the_wastes_level_data)
	elif purpose == "mark_of_stillness":
		_resolve_mark_of_stillness_cast(enemy, mark_of_stillness_level_data)
	elif purpose == "the_hollow_cold":
		_resolve_the_hollow_cold_cast(enemy, the_hollow_cold_level_data)
	elif purpose == "touch_of_the_first_cold":
		_resolve_touch_of_the_first_cold_cast(enemy, touch_of_the_first_cold_level_data)
	elif purpose == "return_to_the_void":
		_resolve_return_to_the_void_cast(enemy, return_to_the_void_level_data)
	elif purpose == "maddening_roar":
		_resolve_maddening_roar_cast(enemy, maddening_roar_level_data)
	elif purpose == "the_hunger_calls":
		_resolve_the_hunger_calls_cast(enemy, the_hunger_calls_level_data)
	elif purpose == "rimecleaver":
		_resolve_rimecleaver_cast(enemy, rimecleaver_level_data)
	elif purpose == "winters_grip":
		_resolve_winters_grip_cast(enemy, winters_grip_level_data)
	elif purpose == "frostbound_rupture":
		_resolve_frostbound_rupture_cast(enemy, frostbound_rupture_level_data)
	elif purpose == "charge":
		_resolve_charge_cast(enemy, charge_level_data)
	elif purpose == "glacier_breaker":
		_resolve_glacier_breaker_cast(enemy, glacier_breaker_level_data)
	elif purpose == "sanguine_bloom":
		_resolve_sanguine_bloom_cast(enemy, sanguine_bloom_level_data)
	else:
		_apply_hero_attack(enemy)


func _on_hero_image_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_hero_image_clicked()


## Only meaningful while Whisper of the Veil's targeting is open - clicking the
## hero's own portrait at any other time (or for any other skill) is a
## no-op, same as clicking a non-highlighted enemy while targeting.
func _on_hero_image_clicked() -> void:
	if not _targeting_mode or _battle_over or _has_acted_this_turn or _rival_fx_in_flight:
		return
	if _targeting_purpose != "whisper_of_the_veil":
		return

	var level_data: Dictionary = _pending_whisper_of_the_veil_level_data
	_resolve_whisper_of_the_veil_self_cast(level_data)


func _apply_hero_attack(target: Dictionary) -> void:
	var generation_before: int = _stage_generation

	# A ranged hero turns to face whoever he's shooting (art faces right
	# natively - same flip convention as _hero_move()). A melee target
	# shares his column, so his facing is left alone.
	var target_pos: int = int(target.get("pos_index", _hero_pos_index))
	if _is_ranged_hero() and target_pos != _hero_pos_index:
		hero_image.flip_h = target_pos < _hero_pos_index

	var hero_animator := CreatureAnimator.of(hero_image)
	if hero_animator != null:
		# Toward the target; a melee target shares his column, so fall
		# back to the way he's facing.
		var attack_direction: float = signf(float(target_pos - _hero_pos_index))
		if attack_direction == 0.0:
			attack_direction = -1.0 if hero_image.flip_h else 1.0
		# A ranged hero strikes from where he stands - no dash forward.
		hero_animator.play_attack(attack_direction, not _is_ranged_hero())

	_play_hero_attack_effect(_hero_static, hero_image, target.get("node"), _beast_of_the_elderwild_active)

	# If Veyrik is hidden, this Attack gets Depthsveil's own bonus
	# damage folded straight into the roll (added to the min/max range
	# BEFORE rolling, so it goes through armor mitigation exactly like
	# the rest of the hit - see _roll_hero_damage()) and ends the
	# invisibility right here, whether or not the hit kills the target.
	var depthsveil_bonus: float = _depthsveil_bonus_damage if _depthsveil_active else 0.0
	# Solara's own Ambush Strike pays off the same way, just as a
	# PERCENTAGE of the attack's own rolled damage (folded in AFTER the
	# roll, below - same "post-roll percentage" shape Might of the
	# Deep's own bonus uses) rather than Depthsveil's flat pre-roll
	# bonus. Only one of the two could ever be active in a given battle
	# (different heroes' own kits), so this never double-counts either
	# way.
	var ambush_strike_active_bonus_pct: float = _ambush_strike_bonus_damage_pct if _ambush_strike_active else 0.0
	# Same idea for Rootveil, just with a root on the target
	# instead of bonus damage - captured now, before the attack (and
	# possibly _end_rootveil()) below can change what _rootveil_active reads.
	var attacking_from_rootveil: bool = _rootveil_active
	# Pull of the Abyss counts this Attack toward its own threshold - once
	# reached, THIS hit's roll gets its bonus damage folded in below
	# (so the cleave that follows is based on the same empowered
	# total), same as Depthsveil's own one-shot bonus above.
	var pull_of_the_abyss_level_data: Dictionary = _maybe_consume_pull_of_the_abyss_stack()
	var pull_of_the_abyss_bonus: float = float(pull_of_the_abyss_level_data.get("bonus_damage", 0.0))
	# Might of the Deep counts this Attack toward its own threshold too,
	# same idea as Pull of the Abyss's stack just above - once reached, this
	# hit's own damage is boosted by a PERCENTAGE of itself (folded in
	# below, after the roll - unlike Pull of the Abyss's flat pre-roll bonus),
	# and the target gets knocked back afterward (see
	# _apply_might_of_the_deep_knockback(), called once the target's
	# final position actually matters again, after every cleave above
	# that reads it has already resolved).
	var might_level_data: Dictionary = _maybe_consume_might_of_the_deep_stack()

	var attack_damage: float = _roll_hero_damage(depthsveil_bonus + pull_of_the_abyss_bonus)
	if ambush_strike_active_bonus_pct > 0.0:
		attack_damage += attack_damage * ambush_strike_active_bonus_pct
	if not might_level_data.is_empty():
		attack_damage += attack_damage * float(might_level_data.get("bonus_damage_pct", 0.0))
	var mitigated_damage: float = _deal_fixed_damage_to_enemy(target, attack_damage)
	_deferred_hit_node = null
	_apply_leeching_hunger_steal(target, mitigated_damage)
	# Frostbound Fangs' bonus_damage is already folded into the roll above
	# (see _roll_hero_damage()) - this just spends one of its banked
	# Attacks, ending the effect once the last one is used.
	_apply_frostbound_fangs_attack()
	# Lifesteal only ever applies to this plain Attack action - never
	# to skill damage (Barbed Lunge, Abyssal Spasm, Thornbind's DoT, etc.) - and
	# uses the damage actually dealt, i.e. after the target's armor
	# has already reduced it.
	_apply_wildbond_lifesteal(mitigated_damage, target)
	# Morbid Mask's own lifesteal - independent of and stacks with
	# Wildbond's above.
	_apply_morbid_mask_lifesteal(mitigated_damage, target)
	# Mark of the Mist stacks the same way - only this plain Attack
	# action builds toward it, never skill damage.
	_apply_mark_of_the_mist_stack(target)

	if not pull_of_the_abyss_level_data.is_empty():
		_apply_pull_of_the_abyss_cleave(target, attack_damage, pull_of_the_abyss_level_data)

	# Cleaver's own cleave - a no-op unless the item is actually owned
	# (see _apply_cleaver_cleave()'s own gate). Independent of
	# Pull of the Abyss's: both can splash off the same Attack if the player
	# has both.
	_apply_cleaver_cleave(target, attack_damage)
	# Hunter's Bow's split shot - Cleaver's ranged counterpart, a no-op
	# unless the item is owned by a ranged hero (see
	# _apply_hunters_bow_split()'s own gates).
	_apply_hunters_bow_split(target, attack_damage)

	# Empress's Will's own AoE splash - a no-op unless the skill is learned
	# (see _apply_empress_will_cleave()'s own gate). Independent of and
	# stacks with Pull of the Abyss's/Cleaver's above.
	_apply_empress_will_cleave(target, attack_damage)

	# Lunar Ricochet' own bounce - a no-op unless the skill is learned
	# (see _apply_lunar_ricochet_bounces()'s own gate). Independent of and
	# stacks with Pull of the Abyss's/Cleaver's/Empress's Will's above.
	_apply_lunar_ricochet_bounces(target, attack_damage)

	# Might of the Deep's own knockback - after every cleave above that
	# reads target["pos_index"] as ITS OWN splash center, so none of
	# them end up centered on where the target gets shoved to instead
	# of where it actually stood when hit. A no-op unless this attack
	# is the one that triggered the stack (see
	# _maybe_consume_might_of_the_deep_stack()).
	if not might_level_data.is_empty():
		DreadlureFX.might_strike(_fx_layer, target.get("node"), -1 if hero_image.flip_h else 1)
		if target.get("current_hp", 0) > 0:
			_apply_might_of_the_deep_knockback(target, might_level_data)

	if depthsveil_bonus > 0.0:
		_end_depthsveil()
	elif ambush_strike_active_bonus_pct > 0.0:
		_end_ambush_strike()

	if attacking_from_rootveil:
		if target.get("current_hp", 0) > 0:
			target["root_turns_left"] = _rootveil_root_turns
		_end_rootveil()

	# If that kill cleared the stage (or won a hero fight) and a fresh
	# encounter started, the turn lock has already been reset for it -
	# re-locking it here would carry the old turn's "used" state into
	# an encounter that hasn't had a turn yet.
	if _battle_over or _stage_generation != generation_before:
		return

	_mark_turn_used()


## Rolls hero damage, applies the target's armor mitigation, subtracts
## it from the target's HP, and kills it if that brings it to 0.
## Shared by Barbed Lunge and other skills that deal a standard attack as
## part of their effect but shouldn't duplicate the turn-flag/button
## bookkeeping (the plain Attack button goes through
## _apply_hero_attack() directly instead, since it also needs to fold
## in Depthsveil's one-shot bonus damage).
## Rolls hero damage and applies it to a single target via
## _deal_fixed_damage_to_enemy. Used by the plain Attack button and by
## skills (like Barbed Lunge) that deal exactly one standard attack.
func _deal_damage_to_enemy(target: Dictionary) -> void:
	_deal_fixed_damage_to_enemy(target, _roll_hero_damage())


## Applies an already-determined damage amount to one target (still
## mitigated by that target's own armor) and kills it if that brings
## it to 0. Shared by _deal_damage_to_enemy (single rolled hit),
## Abyssal Spasm (one rolled amount split across every enemy in range),
## and Thornbind's DoT. Returns the mitigated damage actually dealt, so
## callers that need it (Wildbond's lifesteal, via
## _apply_hero_attack()) don't have to re-derive it.
## For a hero-fight boss, this also doubles as the enemy-side mirror of
## the player's own apply_damage(): The Mist Remembers reverses the hit into
## a heal, and failing that, Veil of the Forgotten absorbs it into its own HP
## pool first - same redirection order as the player's copy, just
## checked here since every source of damage to an enemy (attacks,
## Abyssal Spasm, DoTs) already funnels through this one function.
## `is_critical` just forwards to _show_damage_number()'s own bigger-
## and-golden-with-a-"!" treatment (see Glacier Breaker's own
## _resolve_glacier_breaker_cast()) - it has no effect on the damage math
## itself, only how the number reads. `is_hero_action` gates Dreadlure's
## own Deathlight Lure bonus (see below) - true for every hero attack/
## skill call site (the overwhelming majority, so it defaults true),
## false only at the handful of calls that AREN'T the hero's own doing:
## a DoT tick (_tick_enemy_turn_start_effects()), the Elderwild Companion's own
## attack (_bear_turn()), and another creep piling onto a The Hunger
## Calls target (_enemy_turn()'s own curse redirect).
func _deal_fixed_damage_to_enemy(target: Dictionary, amount: float, is_critical: bool = false, is_hero_action: bool = true) -> float:
	# Dreadlure's Deathlight Lure: boosts every hit THIS specific marked
	# target takes from the hero's own attacks/skills by this level's
	# own bonus_damage_pct - applied to the RAW amount, before armor
	# mitigation and before Imperial Guard's own redirect just below, so
	# a hit that ends up landing on one of the boss's own guards
	# instead still carries the mark's bonus (the mark is about how
	# fragile the TARGET is, not about whatever ends up absorbing the
	# hit).
	if is_hero_action:
		var vulnerability_pct: float = float(target.get("deathlight_lure_bonus_pct", 0.0))
		if vulnerability_pct > 0.0:
			amount *= (1.0 + vulnerability_pct)

	var is_boss: bool = target["static"].get("is_hero_fight_boss", false)

	# Raze's Three Cheers is the only thing that ever writes
	# "armor_reduction" (see _resolve_three_cheers_cast()/
	# _tick_enemy_turn_start_effects()'s own revert) - a per-INSTANCE
	# runtime field on this one spawned enemy, never on target["static"]
	# itself, since that dictionary can be shared across every enemy
	# spawned from the same zone template (mutating it would debuff
	# every enemy of that type, not just this one).
	var enemy_armor: float = float(target["static"].get("armor", 0)) + _enemy_hero_bonus_armor(target) - float(target.get("armor_reduction", 0.0))
	var mitigated: float = _apply_armor_reduction(amount, enemy_armor)
	if is_boss:
		mitigated *= (1.0 - _enemy_blood_of_the_wild_damage_reduction_pct)

	if is_boss and _enemy_the_test_of_time_active:
		# Full immunity, same as the player's own apply_damage() check -
		# no absorption pool to track the way Veil of the Forgotten has, the
		# hit just never happens.
		return mitigated

	if is_boss:
		# Cinder's Kindled Resolve stacks off of this hit landing -
		# added only after enemy_armor above already read the stack
		# count, so the stack this hit just earned reduces the NEXT hit,
		# not this one, mirroring the player's own apply_damage(). A
		# no-op for every other hero (see _apply_enemy_kindled_resolve_
		# stack()'s own "not learned" check).
		_apply_enemy_kindled_resolve_stack()

	if is_boss and _enemy_the_mist_remembers_active:
		var max_hp: float = _enemy_hero_effective_max_hp(target)
		target["current_hp"] = minf(max_hp, target["current_hp"] + mitigated * _enemy_the_mist_remembers_heal_conversion_pct)
		return mitigated

	if is_boss and _enemy_veil_of_the_forgotten_active:
		var absorbed: float = minf(mitigated, _enemy_veil_of_the_forgotten_hp)
		_enemy_veil_of_the_forgotten_hp -= absorbed
		var overflow: float = mitigated - absorbed
		if overflow > 0.0:
			target["current_hp"] -= overflow
			_show_damage_number(target["node"], overflow, is_critical)
		if _enemy_veil_of_the_forgotten_hp <= 0.0:
			_end_enemy_veil_of_the_forgotten(true)
		elif absorbed > 0.0:
			_update_veil_shell(target.get("node"), _enemy_veil_of_the_forgotten_hp)
		if target["current_hp"] <= 0:
			_kill_enemy(target)
		else:
			_maybe_auto_activate_enemy_the_mist_remembers(target)
		return mitigated

	target["current_hp"] -= mitigated
	_show_damage_number(target["node"], mitigated, is_critical)

	if target["current_hp"] <= 0:
		_kill_enemy(target)
	elif is_boss:
		_maybe_auto_activate_enemy_the_mist_remembers(target)

	return mitigated


## A rival hero's own Wildbond/Woven Flesh/Kindled Resolve armor bonuses,
## folded into the armor the player's damage has to punch through - the
## enemy-side mirror of _hero_armor()'s own bonus terms. 0 for
## anything that isn't the actual boss (a regular creep, or the boss's
## own summoned Elderwild Companion ally).
func _enemy_hero_bonus_armor(target: Dictionary) -> float:
	if not target["static"].get("is_hero_fight_boss", false):
		return 0.0
	return _enemy_wildbond_bonus_armor + _enemy_woven_flesh_bonus_armor + _enemy_kindled_resolve_bonus_armor()


## The enemy to actually hit for whatever's on `pos_index` - the
## lowest-HP living, targetable one there, matching EnemyHeroManager.gd's
## own _lowest_hp_enemy() convention for its background simulation (so
## a real hero fight and its simulated equivalent make the same call).
## Ties keep whichever comes first in _enemies (stable, arbitrary but
## consistent). Used for every "whatever's on this column" resolution -
## a melee Attack, the bear's own attack, Barbed Lunge's leap, and (via
## _on_enemy_clicked()'s own redirect) every ranged-click skill cast
## too - so stacking two weak creeps in one column can't be used to
## soak hits meant for a low-HP kill target hiding behind them.
func _get_enemy_at(pos_index: int) -> Dictionary:
	var lowest: Dictionary = {}
	for enemy in _enemies:
		if enemy["pos_index"] != pos_index or _is_target_hidden(enemy):
			continue
		if lowest.is_empty() or float(enemy.get("current_hp", 0)) < float(lowest.get("current_hp", 0)):
			lowest = enemy
	return lowest


## True for the rival hero currently hidden by their own Depthsveil or
## Rootveil - the player can't select, attack, or target them with
## a skill while this holds (see _get_enemy_at(), _start_ranged_
## targeting(), _start_thornbind_targeting(), _cast_abyssal_spasm()), exactly
## mirroring what the player's own Depthsveil/Rootveil does to
## him in _enemy_turn() (both folded into his own _is_hero_hidden()).
## Dreadlure's Deathlight Lure overrides this for whichever enemy it's
## currently marked (target["deathlight_lure_bonus_pct"] > 0, the same
## per-instance field _resolve_deathlight_lure_cast() writes and _deal_
## fixed_damage_to_enemy() reads for its own damage bonus, both sharing
## armor_reduction_turns_left's own countdown) - true sight lets Dreadlure
## keep attacking it, targeting it with a skill, or catching it in an
## AoE for as long as the mark holds, stealth notwithstanding. Since
## this function is the single choke point literally every one of those
## call sites already checks, that one override covers all of them for
## free - no per-skill changes needed.
func _is_target_hidden(target: Dictionary) -> bool:
	if float(target.get("deathlight_lure_bonus_pct", 0.0)) > 0.0:
		return false
	return target["static"].get("is_hero_fight_boss", false) and (_enemy_depthsveil_active or _enemy_rootveil_active or _enemy_ambush_strike_active)


## The top of the hero's damage range - the base a percentage bonus like
## Depthsveil's is taken from - with the flat damage buffs that are active.
func _hero_max_damage() -> float:
	var parts: PackedStringArray = str(_recruited.get("stats", {}).get("damage", "0-0")).split("-")
	var max_dmg: float = float(parts[1]) if parts.size() > 1 else float(parts[0])
	return max_dmg + _beast_of_the_elderwild_bonus_damage + _frostbound_fangs_bonus_damage + _bestial_rage_bonus_damage


## The rival's top damage, from the damage range its stats were built from.
func _enemy_hero_max_damage() -> float:
	var parts: PackedStringArray = str(_enemy_hero_static.get("stats", {}).get("damage", "0-0")).split("-")
	var max_dmg: float = float(parts[1]) if parts.size() > 1 else float(parts[0])
	return max_dmg + _enemy_beast_of_the_elderwild_bonus_damage + _enemy_frostbound_fangs_bonus_damage + _enemy_bestial_rage_bonus_damage


## Rolls a hero attack's damage, adding Beast of the Elderwild's bonus damage, The Primordial Hunger's Frostbound
## Fangs bonus damage, and Skarn's Bestial Rage bonus damage (while each is
## active) plus (for the single hit that triggers it) Depthsveil's
## one-shot `extra_bonus`, before mitigation. Lunara's Moonbound Might then
## scales the resulting total by its own bonus_damage_pct, same as a
## permanent stat-derived damage bonus would.
func _roll_hero_damage(extra_bonus: float = 0.0) -> float:
	var stats: Dictionary = _recruited.get("stats", {})
	var damage_str: String = str(stats.get("damage", "0-0"))
	var parts: PackedStringArray = damage_str.split("-")
	var min_dmg: float = float(parts[0]) if parts.size() > 0 else 0.0
	var max_dmg: float = float(parts[1]) if parts.size() > 1 else min_dmg

	# Beast of the Elderwild's bonus damage, Frostbound
	# Fangs's bonus damage, and Bestial Rage's bonus damage (while each is
	# active) apply on top of both ends of the roll, same as a permanent
	# damage bonus would - Depthsveil's bonus (passed in by the
	# caller, only for the specific hit that triggers it) stacks on top
	# of that the same way.
	var bonus_damage: float = _beast_of_the_elderwild_bonus_damage + _frostbound_fangs_bonus_damage + _bestial_rage_bonus_damage + extra_bonus
	min_dmg += bonus_damage
	max_dmg += bonus_damage

	# Moonbound Might - read fresh off the player's current level every
	# roll (see _get_moonbound_might_level_data()) rather than tracked in
	# a field, since it's never toggled on/off like Depthsveil/Frostbound
	# Fangs/Bestial Rage above, just always-on once learned. Applied last so
	# it scales the whole roll (base weapon damage plus every flat bonus
	# above), not just the hero's own base stat.
	var moonbound_might_bonus_pct: float = float(_get_moonbound_might_level_data().get("bonus_damage_pct", 0.0))
	if moonbound_might_bonus_pct > 0.0:
		min_dmg += min_dmg * moonbound_might_bonus_pct
		max_dmg += max_dmg * moonbound_might_bonus_pct

	return randi_range(int(min_dmg), int(max_dmg))


## `is_critical` (Glacier Breaker's own multiplied hit - see
## _resolve_glacier_breaker_cast()) renders bigger, in gold instead of the
## usual red, with a trailing "!" - the same "stands out from a normal
## hit" treatment a critical usually gets, layered on top of the plain
## damage-number styling below rather than replacing it outright.
func _show_damage_number(target_node: Control, amount: float, is_critical: bool = false) -> void:
	var animator := CreatureAnimator.of(target_node)
	if animator != null and target_node != _deferred_hit_node:
		animator.play_hit(signf(hero_image.position.x - target_node.position.x))

	var label := Label.new()
	label.text = str(int(amount)) + ("!" if is_critical else "")
	label.add_theme_color_override("font_color", Color(1, 0.75, 0.1, 1) if is_critical else Color(1, 0.15, 0.15, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 36 if is_critical else 24)
	label.position = target_node.position + Vector2(target_node.size.x / 2.0 - 15, -10)
	enemies_layer.add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.finished.connect(label.queue_free)


## Same floating/fading style as _show_damage_number, but for text
## (e.g. "No enemy in range") shown over the hero instead of a number
## over an enemy. Holds still and fully readable for
## MESSAGE_READ_HOLD_DURATION before it starts floating up and fading -
## it used to start doing both the instant it appeared, which barely
## gave the player time to read it before it was gone.
func _show_message_over_hero(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1, 0.15, 0.15, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 18)
	label.position = hero_image.position + Vector2(hero_image.size.x / 2.0 - 70, -10)
	add_child(label)

	var tween := create_tween()
	tween.tween_interval(MESSAGE_READ_HOLD_DURATION)
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.finished.connect(label.queue_free)


## A callout that floats up from the moment it appears instead of
## holding still first like _show_message_over_hero() - rising ~70px
## over 1.4s, fading out over the last part of the climb - over `node`
## (the hero_image or an enemy's node), in `color`. Used for passive
## procs like Pull of the Abyss's, where the text is flavor that doesn't need
## a still, readable hold.
func _show_rising_message_over(node: Control, text: String, color: Color) -> void:
	if not is_instance_valid(node):
		return

	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", PULL_OF_THE_ABYSS_TEXT_OUTLINE_COLOR)
	label.add_theme_constant_override("outline_size", 5)
	label.add_theme_font_size_override("font_size", 20)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = node.position + Vector2(node.size.x / 2.0 - 70, -10)
	add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 70, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.8)
	tween.finished.connect(label.queue_free)


## `claimed_by_void`: killed by Return to the Void's execute threshold -
## pulled into the void (ReturnToVoidFX.claim()) instead of the usual
## death dissolve.
func _kill_enemy(enemy: Dictionary, claimed_by_void: bool = false) -> void:
	var xp_gain: float = float(enemy["static"].get("XP", 0))
	gain_xp(xp_gain)

	var gold_gain: int = _roll_enemy_gold(enemy["static"])
	PlayerManager.add_gold(gold_gain)
	_refresh_gold_label()
	_show_gold_gain(enemy["node"], gold_gain)

	if claimed_by_void:
		ReturnToVoidFX.claim(enemy["node"], _fx_layer)
	else:
		CreatureAnimator.spawn_death_ghost(enemy["node"], _fx_layer)
	if _in_hero_fight and enemy["static"].get("is_hero_fight_boss", false):
		_spawn_hero_echo(enemy)
	enemy["node"].queue_free()
	if enemy.get("hp_label") != null:
		enemy["hp_label"].queue_free()
	if enemy.get("status_label") != null:
		enemy["status_label"].queue_free()
	_enemies.erase(enemy)
	_refresh_enemy_overhead_labels()

	if _enemies.is_empty():
		_handle_victory()


## Parses an enemy's "gold" field ("34-39") the same way hero damage
## is rolled from a "min-max" string, returning a random amount in
## that range. Missing/malformed fields just yield 0.
func _roll_enemy_gold(enemy_static: Dictionary) -> int:
	var gold_str: String = str(enemy_static.get("gold", "0"))
	var parts: PackedStringArray = gold_str.split("-")
	var min_gold: int = int(parts[0]) if parts.size() > 0 else 0
	var max_gold: int = int(parts[1]) if parts.size() > 1 else min_gold
	return randi_range(min_gold, max_gold)


## Same floating/fading style as _show_damage_number, but in gold for
## the amount of gold just earned from a kill.
func _show_gold_gain(target_node: Control, amount: int) -> void:
	var label := Label.new()
	label.text = "+%d gold" % amount
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 18)
	label.position = target_node.position + Vector2(target_node.size.x / 2.0 - 30, 10)
	enemies_layer.add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40, 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tween.finished.connect(label.queue_free)


## Clearing a non-final stage reloads the next stage's enemies in this
## same Battle scene instance rather than returning to the Map. Only
## clearing the final stage counts as actually winning the zone - and
## if that's reached without ever fleeing in between (nothing resets
## _current_stage except leaving the scene), the zone is marked fully
## cleared so it always reopens on the final stage from now on.
## Clearing a non-final stage reloads the next stage's enemies in this
## same Battle scene instance rather than returning to the Map.
## Clearing the final stage tries to start a hero fight (see
## _try_start_hero_fight()) before actually finishing the zone;
## winning that hero fight (_in_hero_fight was true when the last
## enemy died) marks it defeated and then finishes for real.
func _handle_victory() -> void:
	# A level-up from the killing blow comes first: hold the stage/zone
	# clear until the player has picked their skill (see
	# _refresh_level_up_input_blocker(), which re-runs this once the
	# level-up flow closes).
	if _is_level_up_flow_open():
		_victory_pending = true
		return
	_victory_pending = false
	_play_log_stage_end("victory")
	# Tutorial stage 1 ends here rather than rolling into the zone's own
	# stage 2 - the next tutorial stage is a separately scripted scenario
	# (Kaelen Varr at level 5, mid-fight, low on resources - not a straight
	# continuation of this fight), so it needs its own checkpoint instead
	# of _advance_to_next_stage()'s normal handoff.
	if TutorialManager.is_active and TutorialManager.current_stage == 1 and _current_stage == 1:
		_advance_tutorial_stage1_step("stage_cleared")
		return

	# Tutorial stage 3 is the closing scenario - ends the whole tutorial
	# here with its own closing popup rather than falling through to a
	# real hero-fight/zone-finished flow the sandbox was never set up
	# for (no NPC rivals exist in it - see PlayerManager.
	# clear_recruited_hero()'s npc_* wipe).
	if TutorialManager.is_active and TutorialManager.current_stage == 3:
		_advance_tutorial_stage3_step("zone_cleared")
		return

	if _in_hero_fight:
		# The rival already fell (see _spawn_hero_echo()) - the fight is
		# only won once the hero goes over the Echo they left behind,
		# which may be right where he's standing.
		if _hero_echo != null:
			_try_collect_hero_echo(_hero_pos_index, _hero_pos_index)
			return
		PlayerManager.mark_hero_defeated(_hero_fight_target_id)
		_in_hero_fight = false
		_finish_zone_victory()
		return

	if _current_stage < GameManager.MAX_ZONE_STAGE:
		_advance_to_next_stage()
		return

	if _try_start_hero_fight():
		return

	_finish_zone_victory()


## The rival hero has fallen: they're marked defeated on the spot (their
## kill message is queued now, whatever happens after), and their Echo
## opens in the column they died in, waiting to be collected.
func _spawn_hero_echo(boss: Dictionary) -> void:
	PlayerManager.mark_hero_defeated(_hero_fight_target_id)
	var node: Control = boss["node"]
	var center: Vector2 = node.global_position + node.size * 0.5
	_hero_echo = HeroEchoFX.spawn(_fx_layer, center, get_viewport_rect().size.y / 4.0 * 0.5)
	_hero_echo_pos_index = int(boss["pos_index"])
	_echo_popup_acknowledged = false
	_echo_popup_pending = false


## Collects the Echo if the hero's move from `from_index` to `to_index`
## went over it - but only once every enemy is dead; with any still
## standing, he just passes over it. The first time it's collectible,
## EchoPopup opens instead, and it can only be collected once that's
## been closed.
func _try_collect_hero_echo(from_index: int, to_index: int) -> void:
	if _hero_echo == null or _battle_over or not _enemies.is_empty():
		return
	if not _echo_popup_acknowledged:
		_show_hero_echo_popup()
		return
	if _hero_echo_pos_index < mini(from_index, to_index) or _hero_echo_pos_index > maxi(from_index, to_index):
		return
	# Nothing left to fight - the battle is locked while the Echo flows
	# into the hero, then the fight is won for real.
	_battle_over = true
	_cancel_targeting()
	_update_action_buttons()
	_hero_echo.collect(hero_image, _on_hero_echo_collected)


## Opens EchoPopup - or, if the killing blow also opened the level-up
## flow, holds it back until that's closed (see
## _refresh_level_up_input_blocker()).
func _show_hero_echo_popup() -> void:
	if _hero_echo == null or _echo_popup_acknowledged or echo_popup.visible or _battle_over:
		return
	if _is_level_up_flow_open():
		_echo_popup_pending = true
		return
	_echo_popup_pending = false
	_cancel_targeting()
	echo_popup.visible = true


## Closing EchoPopup frees the Echo to be collected - straight away if
## the hero is already standing on it.
func _on_echo_popup_ok_pressed() -> void:
	echo_popup.visible = false
	_echo_popup_acknowledged = true
	_try_collect_hero_echo(_hero_pos_index, _hero_pos_index)


func _on_hero_echo_collected() -> void:
	_hero_echo = null
	_in_hero_fight = false
	# The Echo is absorbed into the hero's attributes (see
	# PlayerManager.apply_echo_bonus()); a moment to read what it gave.
	var gained: Dictionary = PlayerManager.apply_echo_bonus(_hero_static)
	if not gained.is_empty():
		_show_message_over_hero("Echo absorbed!  +%.1f Strength  +%.1f Agility  +%.1f Intelligence" % [gained.get("strength", 0.0), gained.get("agility", 0.0), gained.get("intelligence", 0.0)])
		await get_tree().create_timer(1.6).timeout
	_finish_zone_victory()


func _finish_zone_victory() -> void:
	# The first clear of the player's own home zone is what opens up the
	# rest of the world (see PlayerManager.is_home_zone_cleared()) - so
	# it gets a moment of story before heading back to the Map.
	var first_home_clear: bool = GameManager.selected_zone == PlayerManager.get_home_zone_id() \
			and not PlayerManager.is_zone_cleared(GameManager.selected_zone)
	PlayerManager.set_zone_cleared(GameManager.selected_zone)

	_battle_over = true
	_update_action_buttons()
	PlayerManager.record_high_score()
	# Let the killing blow's death dissolve finish before leaving.
	if not get_tree().get_nodes_in_group(CreatureAnimator.DEATH_GHOST_GROUP).is_empty():
		await get_tree().create_timer(CreatureAnimator.DEATH_DURATION + 0.15 + AudioManager.attack_wait()).timeout
	if first_home_clear:
		await StoryBanner.play(self, "Your journey has only begun.",
				"The world lies beyond your home. Seek the other Remembered and gather their Echoes.").finished
	get_tree().change_scene_to_file("res://scenes/Map.tscn")


## Moves on to the next wave without leaving the Battle scene: hero
## HP/mana/skill cooldowns carry over as-is (no free heal between
## stages), but position, turn count, and the per-turn action lock
## reset like a fresh encounter.
func _advance_to_next_stage() -> void:
	_current_stage += 1
	_stage_generation += 1
	_close_all_hollow_cold_tears()
	_end_hunger_calls_fx()
	_update_stage_label()
	_show_message_over_hero("Stage %d!" % _current_stage)

	_cancel_targeting()
	_hero_pos_index = 1
	_update_hero_position()
	_reset_bear_to_hero_column()
	_reset_guards_to_hero_column()

	_turn_count = 0
	_next_reinforcement_turn = GameManager.get_reinforcement_interval(_current_stage)
	_has_acted_this_turn = false

	_load_enemies()
	_update_action_buttons()


## If this zone still has an undefeated rival hero available, starts a
## fight against a random one of them and returns true. Otherwise
## returns false and leaves the battle unaffected, so the caller can
## fall through to actually finishing the zone.
## The player's own home zone holds its zone-mate fight back on the
## FIRST clear specifically - that run is meant to introduce the zone
## itself, not immediately throw a boss-tier rival at someone who just
## finished their very first playthrough of it. Every other zone (and
## the home zone's own second-and-later clears) still tries the fight
## the normal way. PlayerManager.is_zone_cleared() only flips true once
## _finish_zone_victory() runs - right after this returns false and the
## caller (_handle_victory()) falls through to it - so checking it HERE,
## before that happens, is exactly "has this zone ever been cleared
## before THIS victory."
func _try_start_hero_fight() -> bool:
	var own_hero_id: String = _recruited.get("id", "")
	var is_own_home_zone: bool = GameManager.selected_zone == GameManager.get_zone_id_for_hero(own_hero_id)
	if is_own_home_zone and not PlayerManager.is_zone_cleared(GameManager.selected_zone):
		return false

	var eligible: Array = _get_eligible_hero_fight_heroes()
	if eligible.is_empty():
		return false

	_start_hero_fight(eligible[randi() % eligible.size()])
	return true


## Every hero in this zone that's fair game for a hero fight right
## now: if this is the player's own recruited hero's home zone, their
## own hero is excluded (fighting themselves makes no sense) but any
## OTHER hero recruited from that same zone still counts; in a zone
## that isn't their own, every hero in it is eligible. Either way,
## anyone already marked defeated (PlayerManager.mark_hero_defeated)
## is excluded, so the same hero is never offered for a rematch.
func _get_eligible_hero_fight_heroes() -> Array:
	var heroes: Array = GameManager.get_selected_zone().get("heroes", [])
	if heroes.is_empty():
		return []

	var own_hero_id: String = _recruited.get("id", "")
	var is_own_zone: bool = GameManager.selected_zone == GameManager.get_zone_id_for_hero(own_hero_id)

	var eligible: Array = []
	for hero in heroes:
		var hero_id: String = hero.get("id", "")
		if is_own_zone and hero_id == own_hero_id:
			continue
		if PlayerManager.is_hero_defeated(hero_id):
			continue
		eligible.append(hero)

	return eligible


## Starts a one-enemy fight against a rival hero: same fresh-encounter
## reset as advancing a stage (position, turn count, action lock), but
## _current_stage itself doesn't change - see _in_hero_fight.
func _start_hero_fight(hero_static: Dictionary) -> void:
	# The rival fights with the stats it has levelled up to and the
	# equipment it has bought (see EnemyHeroManager.npc_shop()).
	hero_static = EnemyHeroManager.apply_npc_progress(hero_static)
	_in_hero_fight = true
	_hero_fight_target_id = hero_static.get("id", "")
	_stage_generation += 1
	_close_all_hollow_cold_tears()
	_end_hunger_calls_fx()

	_update_stage_label()
	_show_message_over_hero("%s challenges you!" % hero_static.get("name", "A rival hero"))

	_cancel_targeting()
	_hero_pos_index = 1
	_update_hero_position()
	_reset_bear_to_hero_column()
	_reset_guards_to_hero_column()

	_turn_count = 0
	_next_reinforcement_turn = HERO_FIGHT_REINFORCEMENT_INTERVAL
	_has_acted_this_turn = false

	for child in enemies_layer.get_children():
		child.queue_free()
	_enemies.clear()

	_reset_enemy_hero_state(hero_static)
	_spawn_enemy(GameManager.build_hero_fight_enemy_def(hero_static))
	_attach_hero_attack_prop(hero_static, _get_hero_fight_boss().get("node"))

	# The player's skills come into the boss fight fresh - no cooldown left
	# over from the stages before it (the rival starts with all of its own
	# ready, see _reset_enemy_hero_state()).
	for skill_id in _skill_cooldowns.keys():
		_skill_cooldowns[skill_id] = 0
		PlayerManager.set_skill_cooldown(skill_id, 0)
	_refresh_skill_cooldown_labels()

	_update_action_buttons()
	_play_log_reset_stage()
	_play_log_fight_start(hero_static)


## Fresh state for a newly-challenged rival hero's own skills, and for
## whatever they might have inflicted on the player in a PREVIOUS hero
## fight this scene - none of it should leak from one rival to the
## next (or from a hero fight into the zone's regular stages, though
## _current_stage staying at MAX_ZONE_STAGE throughout a hero fight
## means this is only ever called right before one starts anyway).
func _reset_enemy_hero_state(hero_static: Dictionary) -> void:
	_enemy_hero_static = hero_static
	_enemy_hero_id = hero_static.get("id", "")
	_enemy_skill_cooldowns.clear()

	_enemy_leeching_hunger_active = false
	_enemy_leeching_hunger_attacks_remaining = 0
	_enemy_leeching_hunger_lifesteal_pct = 0.0
	_enemy_leeching_hunger_turns_remaining = 0
	_enemy_leeching_hunger_duration_pending_start = false

	_enemy_depthsveil_active = false
	_enemy_depthsveil_bonus_damage = 0.0
	_enemy_depthsveil_turns_remaining = 0
	_enemy_depthsveil_duration_pending_start = false

	_enemy_wildbond_active = false
	_enemy_wildbond_lifesteal_pct = 0.0
	_enemy_wildbond_bonus_armor = 0.0
	_enemy_wildbond_turns_remaining = 0
	_enemy_wildbond_duration_pending_start = false
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), false)

	_enemy_beast_of_the_elderwild_active = false
	_enemy_beast_of_the_elderwild_bonus_hp = 0.0
	_enemy_beast_of_the_elderwild_bonus_damage = 0.0
	_enemy_beast_of_the_elderwild_turns_remaining = 0
	_enemy_beast_of_the_elderwild_duration_pending_start = false

	_enemy_blood_of_the_wild_active = false
	_enemy_blood_of_the_wild_damage_reduction_pct = 0.0

	_enemy_veil_of_the_forgotten_active = false
	_enemy_veil_of_the_forgotten_hp = 0.0
	_enemy_veil_of_the_forgotten_aoe_damage = 0.0
	_enemy_veil_of_the_forgotten_radius = 0
	_enemy_veil_of_the_forgotten_turns_remaining = 0
	_enemy_veil_of_the_forgotten_duration_pending_start = false
	_remove_veil_shell(_get_hero_fight_boss().get("node"), false, 0)

	_enemy_the_mist_remembers_active = false
	_enemy_the_mist_remembers_heal_conversion_pct = 0.0
	_enemy_the_mist_remembers_turns_remaining = 0
	_enemy_the_mist_remembers_duration_pending_start = false
	_set_the_mist_remembers_visual(_get_hero_fight_boss().get("node"), false)

	_enemy_pull_of_the_abyss_attack_count = 0
	_enemy_undertow_pending = false

	_enemy_frostbound_fangs_active = false
	_enemy_frostbound_fangs_bonus_damage = 0.0
	_enemy_frostbound_fangs_bonus_range = 0
	_enemy_frostbound_fangs_attacks_remaining = 0
	_enemy_frostbound_fangs_turns_remaining = 0
	_enemy_frostbound_fangs_duration_pending_start = false
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), false)

	_enemy_the_test_of_time_active = false
	_enemy_the_test_of_time_heal_per_turn = 0.0
	_enemy_the_test_of_time_turns_remaining = 0
	_enemy_the_test_of_time_duration_pending_start = false

	_enemy_frost_tempest_active = false
	_enemy_frost_tempest_damage_per_turn = 0.0
	_enemy_frost_tempest_radius = 0
	_enemy_frost_tempest_turns_remaining = 0
	_enemy_frost_tempest_duration_pending_start = false

	_enemy_frostbound_rupture_active = false
	_enemy_frostbound_rupture_blocked_columns = []
	_enemy_frostbound_rupture_turns_remaining = 0
	_enemy_frostbound_rupture_duration_pending_start = false
	_refresh_frostbound_rupture_visuals()

	_enemy_bestial_rage_active = false
	_enemy_bestial_rage_bonus_damage = 0.0
	_enemy_bestial_rage_turns_remaining = 0
	_enemy_bestial_rage_duration_pending_start = false
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), false)

	_enemy_rootveil_active = false
	_enemy_rootveil_root_turns = 0
	_enemy_rootveil_turns_remaining = 0
	_enemy_rootveil_duration_pending_start = false

	_enemy_woven_flesh_active = false
	_enemy_woven_flesh_bonus_armor = 0.0
	_enemy_woven_flesh_bonus_hp_regen = 0.0
	_enemy_woven_flesh_turns_remaining = 0
	_enemy_woven_flesh_duration_pending_start = false
	WovenFleshFX.set_on(_get_hero_fight_boss().get("node"), false)

	_enemy_kindled_resolve_stack_turns = []
	_despawn_enemy_cinderbomb()

	_enemy_kiss_the_wastes_active = false
	_enemy_kiss_the_wastes_turns_left = 0
	_enemy_kiss_the_wastes_level_data = {}

	_end_enemy_imperial_guard()

	var stats: Dictionary = hero_static.get("stats", {})
	_enemy_max_mana = float(stats.get("mana", 0))
	_enemy_current_mana = _enemy_max_mana

	_enemy_potion_health_count = PlayerManager.get_npc_potion_count(_enemy_hero_id, "health")
	_enemy_potion_mana_count = PlayerManager.get_npc_potion_count(_enemy_hero_id, "mana")

	_player_root_turns_left = 0
	_player_silence_turns_left = 0
	_player_thornbind_dot_damage = 0.0
	_player_thornbind_dot_turns_left = 0
	_player_stun_turns_left = 0
	_player_the_hunger_calls_active = false
	_player_curse_stacks = 0
	_player_curse_active = false
	_player_curse_dot_damage = 0.0
	_player_curse_dot_turns_left = 0
	_player_curse_last_hit_turn = 0
	_player_mark_of_stillness_dot_damage = 0.0
	_player_mark_of_stillness_dot_turns_left = 0
	_player_the_hollow_cold_dot_damage = 0.0
	_player_the_hollow_cold_dot_turns_left = 0
	_player_return_to_the_void_dot_damage = 0.0
	_player_return_to_the_void_dot_turns_left = 0
	_player_return_to_the_void_execute_pct = 0.0
	_player_winters_grip_dot_damage = 0.0
	_player_winters_grip_dot_turns_left = 0
	_player_winters_grip_hold = false
	_player_sanguine_bloom_dot_damage = 0.0
	_player_sanguine_bloom_heal_per_turn = 0.0
	_player_sanguine_bloom_dot_turns_left = 0
	_player_mothers_grasp_dot_damage = 0.0
	_player_mothers_grasp_dot_turns_left = 0
	_player_armor_reduction = 0.0
	_player_armor_reduction_turns_left = 0
	_player_deathlight_lure_bonus_pct = 0.0
	_player_kiss_burn_dot_damage = 0.0
	_player_kiss_burn_dot_turns_left = 0

	_end_enemy_hunting_instinct()
	_enemy_might_of_the_deep_attack_count = 0
	_end_enemy_ambush_strike()
	_end_enemy_eternal_eclipse()


func _update_stage_label() -> void:
	if _in_hero_fight:
		stage_label.text = "Hero Fight!"
	else:
		stage_label.text = "Stage %d/%d" % [_current_stage, GameManager.MAX_ZONE_STAGE]


# ------------------------------------------------------------------
# End of turn: the hero only gets one action (move, attack, skill, or
# item) per turn, so as soon as one resolves, the turn ends on its
# own - no End Turn button to press. Range enemies then attack every
# turn; melee enemies attack only if sharing the hero's column,
# otherwise take one step toward the hero. Then the turn's
# move/attack allowance resets.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Play log (see PlayLog.gd): what the player's next turn-ending action is,
# and what's been spent since the current wave/fight began. Only read when
# the log is on.
# ------------------------------------------------------------------
var _log_pending_action: String = ""
var _log_potions: Dictionary = {}
var _log_casts: Dictionary = {}
var _log_turns_in_stage: int = 0


## The numbers every play-log row carries.
func _play_log_state() -> Dictionary:
	var enemy_hp := 0.0
	for enemy in _enemies:
		enemy_hp += maxf(float(enemy.get("current_hp", 0)), 0.0)
	var state := {
		"turn": _turn_count,
		"stage": _current_stage,
		"hp": roundi(float(_recruited.get("current_hp", 0))),
		"max_hp": roundi(_hero_max_hp()),
		"mana": roundi(float(_recruited.get("current_mana", 0))),
		"max_mana": roundi(float(_recruited.get("stats", {}).get("mana", 0))),
		"enemies": _enemies.size(),
		"enemy_hp": roundi(enemy_hp),
	}
	if _is_bear_alive():
		state["bear_hp"] = roundi(float(_bear.get("current_hp", 0)))
		state["bear_max_hp"] = roundi(float(_bear.get("hp", 0)))
		state["bear_dmg"] = roundi((float(_bear.get("damage_min", 0)) + float(_bear.get("damage_max", 0))) / 2.0)
	# Summons on each side. Only present while something is out, so rows stay
	# short; the rival's bear is also counted inside enemies/enemy_hp above.
	_play_log_add_guards(state, "guards", _guards)
	_play_log_add_guards(state, "rival_guards", _enemy_guards)
	if _in_hero_fight:
		var boss: Dictionary = _get_hero_fight_boss()
		state["rival"] = _enemy_hero_id
		state["rival_hp"] = 0 if boss.is_empty() else roundi(float(boss.get("current_hp", 0)))
		state["rival_mana"] = roundi(_enemy_current_mana)
		var rival_bear: Dictionary = _get_enemy_elderwild_companion()
		if not rival_bear.is_empty():
			state["rival_bear_hp"] = roundi(float(rival_bear.get("current_hp", 0)))
			state["rival_bear_dmg"] = roundi(float(rival_bear["static"].get("damage", 0)))
	return state


func _play_log_add_guards(state: Dictionary, key: String, guards: Array) -> void:
	var total_hp := 0.0
	var alive := 0
	for guard in guards:
		if float(guard.get("current_hp", 0)) > 0.0:
			alive += 1
			total_hp += float(guard["current_hp"])
	if alive > 0:
		state[key] = alive
		state[key + "_hp"] = roundi(total_hp)


## Who you are going into this battle scene: level, stats, skill levels, potions.
func _play_log_session() -> void:
	if not PlayLog.enabled():
		return
	var skills := {}
	for skill in _hero_static.get("skills", []):
		var level: int = PlayerManager.get_skill_level(skill.get("id", ""))
		if level > 0:
			skills[skill["id"]] = level
	var inventory: Dictionary = PlayerManager.get_inventory()
	var data: Dictionary = _play_log_state()
	data["hero"] = _recruited.get("id", "")
	data["level"] = PlayerManager.get_level()
	data["zone"] = GameManager.selected_zone
	data["stats"] = _recruited.get("stats", {})
	data["skills"] = skills
	data["potions_held"] = {"health": int(inventory.get("health", 0)), "mana": int(inventory.get("mana", 0))}
	PlayLog.event("session", data)


## The rival you are about to fight: its level, stats and skill levels.
func _play_log_fight_start(rival_static: Dictionary) -> void:
	if not PlayLog.enabled():
		return
	var rival_id: String = rival_static.get("id", "")
	var skills := {}
	for skill in rival_static.get("skills", []):
		var level: int = PlayerManager.get_npc_skill_level(rival_id, skill.get("id", ""))
		if level > 0:
			skills[skill["id"]] = level
	var data: Dictionary = _play_log_state()
	data["rival"] = rival_id
	data["rival_level"] = PlayerManager.get_npc_level(rival_id)
	data["rival_stats"] = rival_static.get("stats", {})
	data["rival_skills"] = skills
	data["rival_potions"] = {"health": _enemy_potion_health_count, "mana": _enemy_potion_mana_count}
	data["rival_items"] = PlayerManager.get_npc_items(rival_id)
	data["rival_mana"] = roundi(_enemy_current_mana)
	data["rival_max_mana"] = roundi(_enemy_max_mana)
	PlayLog.event("fight_start", data)


func _play_log_reset_stage() -> void:
	_log_potions.clear()
	_log_casts.clear()
	_log_turns_in_stage = 0


func _play_log_stage_end(kind: String) -> void:
	var data: Dictionary = _play_log_state()
	data["potions"] = _log_potions.duplicate()
	data["casts"] = _log_casts.duplicate()
	data["turns"] = _log_turns_in_stage
	data["level"] = PlayerManager.get_level()
	PlayLog.event(kind, data)


## Locks the action buttons and, after a brief pause so the player can
## see the result of their action (damage numbers, messages, etc.),
## triggers the enemies' turn automatically. Bails out first if the
## action that just called this (an attack or skill cast can kill the
## last enemy outright, same as a DoT tick can - see _kill_enemy()/
## _handle_victory()) already resolved the battle: _handle_victory()/
## _handle_defeat() may already have changed scene by this point (see
## _finish_zone_victory()), and scheduling a timer into _end_turn()
## regardless would risk it firing after this node's been removed from
## the tree entirely, crashing on a null get_tree() the same way an
## unguarded _end_turn() could (see that function's own _battle_over
## check right after _tick_skill_cooldowns()).
func _mark_turn_used() -> void:
	if _battle_over:
		return
	# A lockout (stun/The Test of Time) that landed mid-action already
	# scheduled this turn's end - a second _end_turn() would hand the
	# enemies an extra turn.
	if _auto_skip_pending and _auto_skip_generation == _stage_generation:
		return
	_has_acted_this_turn = true
	if PlayLog.enabled():
		var what: String = _log_pending_action if _log_pending_action != "" else "other"
		if what.begins_with("skill:"):
			var skill_name: String = what.substr(6)
			_log_casts[skill_name] = int(_log_casts.get(skill_name, 0)) + 1
		var data: Dictionary = _play_log_state()
		data["action"] = what
		PlayLog.event("action", data)
		_log_pending_action = ""
	_update_action_buttons()
	get_tree().create_timer(0.9).timeout.connect(_end_turn)


func _end_turn() -> void:
	if _battle_over:
		return

	_cancel_targeting()
	_stun_before_enemy_phase = _player_stun_turns_left
	_bear_turn()
	_guards_turn()
	_enemy_guards_turn()
	_enemy_turn()

	if _recruited.get("current_hp", 0) <= 0:
		_handle_defeat()
		return

	_turn_count += 1
	# Only turns with an enemy still alive count toward reinforcements -
	# once they're all down and only the Echo is left to collect, the
	# countdown holds where it is.
	if _enemies.is_empty():
		_next_reinforcement_turn += 1
		# Covers the last enemy leaving the field some way other than
		# _kill_enemy() (e.g. a rival's Elderwild Companion despawning).
		_try_collect_hero_echo(_hero_pos_index, _hero_pos_index)
	elif _turn_count >= _next_reinforcement_turn:
		_spawn_reinforcements()
		_next_reinforcement_turn += HERO_FIGHT_REINFORCEMENT_REPEAT_INTERVAL if _in_hero_fight else GameManager.get_reinforcement_repeat(_current_stage)

	_tick_skill_cooldowns()

	# A rival's own buff tick inside _tick_skill_cooldowns() above (e.g.
	# The Frost Tempest, if it ever damages its own caster) could in
	# principle finish either side off outside the normal attack/skill/
	# enemy-turn paths already checked earlier in this function, so this
	# still needs its own defeat check. A kill can just as easily finish
	# off the LAST enemy instead - _kill_enemy() already calls
	# _handle_victory() for that on its own, which can set _battle_over
	# and change scene outright (see _finish_zone_victory()) - so THIS
	# needs its own bail-out too: without it, a hero fight the boss just
	# lost would fall through to the stun/The Test of Time check at the tail
	# of this function and schedule another _end_turn() call via
	# get_tree().create_timer() - a timer that fires after this node has
	# already been removed from the tree by that scene change, crashing
	# on a null get_tree().
	if _battle_over:
		return
	if _recruited.get("current_hp", 0) <= 0:
		_handle_defeat()
		return

	# A stun a rival landed during THIS end-of-turn (or one raised past what
	# was already there) hasn't cost the player a turn yet - it starts
	# counting from his next turn, so only a stun that was already in force
	# when this function began is decremented here.
	if _player_stun_turns_left > 0 and _player_stun_turns_left <= _stun_before_enemy_phase:
		_player_stun_turns_left -= 1
		if _player_stun_turns_left <= 0:
			_player_the_hunger_calls_active = false

	# Every DoT/root/silence/execute effect a rival hero could have
	# inflicted on the player lands right here, at the very start of his
	# own new turn - before he gets to act - same reasoning as the
	# enemy-side version (_tick_enemy_turn_start_effects(), ticked from
	# _enemy_turn() instead). Unlike that version, a kill here can't
	# free any nodes or change scenes on its own, so a plain HP check
	# right after is enough - no bail-out needed mid-function.
	_tick_player_turn_start_effects()
	if _recruited.get("current_hp", 0) <= 0:
		_handle_defeat()
		return

	# The hero's new turn is opening right here - if Undertow
	# marked something last turn, this is "his next turn", so he
	# teleports now, for free (see _resolve_undertow_teleport() - it
	# never spends the turn this function is about to reopen below).
	_resolve_undertow_teleport()

	# Frostborn regenerates mana at the start of every hero turn,
	# whether or not he actually gets to act on it (see
	# _apply_frostborn_regen()'s own comment) - a no-op while it isn't
	# learned.
	_apply_frostborn_regen()

	# Passive HP/mana regen (see _apply_passive_hero_regen()) - same
	# timing as Frostborn's own regen just above, on top of it rather
	# than instead of it.
	_apply_passive_hero_regen()

	# Kindled Resolve's own regen, off of whatever stacks are currently
	# active - same timing/stacking relationship as Frostborn's and
	# the baseline regen above.
	_apply_kindled_resolve_regen()

	# Kiss the Wastes' channel: the hero's new turn is opening right
	# here, same point Undertow's own teleport claims for free
	# above - except this doesn't just do something for free, it
	# consumes the ENTIRE turn on an automatic shot, same as a stunned
	# turn, or one held in The Test of Time, being skipped below, just
	# with a shot fired instead of nothing happening. Never falls through to the normal
	# "reopen the action buttons" code beneath it while a shot remains -
	# only once _fire_kiss_the_wastes_shot() has fired the LAST one
	# (_end_kiss_the_wastes() clears _kiss_the_wastes_active) does
	# control reach the ordinary turn-opening logic below, exactly as if
	# the channel had never been active this turn.
	if _kiss_the_wastes_active:
		var generation_before: int = _stage_generation
		_fire_kiss_the_wastes_shot()
		_kiss_the_wastes_turns_left -= 1
		if _kiss_the_wastes_turns_left <= 0:
			_end_kiss_the_wastes()

		# A kill from that shot (or its splash) could have cleared the
		# stage/won a hero fight and moved on to a fresh encounter -
		# same bail-out reasoning _end_turn()'s own top-of-function
		# comment already gives for the general case: scheduling
		# another _end_turn() timer here would fire after this node (or
		# this fight's own state) has already moved on.
		if _battle_over or _stage_generation != generation_before:
			return

		if _kiss_the_wastes_active:
			_has_acted_this_turn = true
			_update_action_buttons()
			get_tree().create_timer(0.9).timeout.connect(_end_turn)
			return

	_log_turns_in_stage += 1
	if PlayLog.enabled():
		PlayLog.event("turn_end", _play_log_state())

	# Reopens the turn - and if the player is still stunned or held in
	# The Test of Time, _update_action_buttons() hands it straight back
	# via _maybe_auto_skip_player_turn().
	_has_acted_this_turn = false
	_update_action_buttons()
	_refresh_skill_cooldown_labels()


## Skips the player's turn automatically whenever it's open but he has
## no way to act in it: stunned (_player_stun_turns_left), or held in
## The Test of Time - straight back to another _end_turn() (Elderwild
## Companion + enemy turn again) after a short pause, the same way a
## stunned enemy just loses its own turn. Run from
## _update_action_buttons() rather than only from _end_turn()'s tail,
## since a lockout can also land AFTER the turn has already reopened:
## a rival's delayed skill hit (Return to the Void's stun, resolved once
## its animation finishes - see _rival_fx_in_flight) arrives mid-turn,
## and nothing else would ever end that turn, leaving the player stuck
## with every button locked. Marks the turn as used first, so repeated
## _update_action_buttons() calls don't schedule the skip twice.
func _maybe_auto_skip_player_turn() -> void:
	if _battle_over or _has_acted_this_turn or _rival_fx_in_flight:
		return
	if _player_stun_turns_left <= 0 and not _the_test_of_time_active:
		return

	_has_acted_this_turn = true
	if PlayLog.enabled():
		var skipped: Dictionary = _play_log_state()
		skipped["action"] = "skipped (stunned or held)"
		PlayLog.event("action", skipped)
	_auto_skip_pending = true
	_auto_skip_generation = _stage_generation
	_cancel_targeting()
	# The Test of Time speaks for itself (the floating, the clock) - only
	# a stun gets a message.
	if not _the_test_of_time_active:
		_show_message_over_hero("Stunned - turn skipped")

	var generation_before: int = _stage_generation
	get_tree().create_timer(0.9).timeout.connect(func() -> void:
		_auto_skip_pending = false
		# A stage/hero-fight change in the meantime opened a fresh turn of
		# its own - this skip belonged to the old one.
		if _stage_generation != generation_before:
			return
		_end_turn()
	)


# True from the moment _maybe_auto_skip_player_turn() schedules a skip
# until it fires - see _mark_turn_used()'s own check. Only counts for the
# stage/hero fight it was scheduled in (_auto_skip_generation).
var _auto_skip_pending: bool = false
var _auto_skip_generation: int = -1


## Ranged enemies get exactly one action per turn too - flee, attack,
## or approach - never a flee-then-attack combo in the same turn:
##
##        too close
##            |
##          FLEE
##            |
##        safe range
##            |
##         ATTACK
##            ^
##            |
##        too far
##            |
##          MOVE
##
## While Veyrik is hidden by Depthsveil (_is_hero_hidden()), neither
## enemy type's attack can land on him, AND enemies stop moving/
## chasing him entirely - they hold their ground instead of stepping
## toward where he was. If the Elderwild Companion is out, it's still fair
## game: enemies will shoot/swing at it, and will still chase it down,
## since only Veyrik himself is untraceable while invisible. The hero
## is always the priority target when both he and the bear are in
## range at once (while visible); only "too close" flee logic keys
## off him specifically, not the bear.
##
## A rooted enemy (root_turns_left > 0, from Thornbind - see
## _apply_root()) never moves either, for the same reason as above:
## every movement branch (flee and the "close in" fallback) is
## skipped. Its attack is untouched, though - if it's already within
## range/on the hero's column, a root doesn't stop it from swinging.
##
## Skarn's Frostbound Rupture works alongside root rather than replacing it: an
## enemy standing IN a walled-off column (_is_column_frostbound_rupture_
## blocked()) is frozen exactly like a rooted one - see `ice_frozen`
## below, folded into every `not rooted` movement gate the same way -
## and one standing outside the wall simply can't step INTO a blocked
## column, checked against each individual destination right before the
## _move_enemy() call that would land it there. Attacking, casting a
## skill, and using an item are all untouched either way, same as root.
##
## The Hunger Calls overrides all of the above for whichever OTHER
## enemies currently fall within its own curse_range of its frozen
## target (see _is_the_hunger_calls_active()): they ignore the hero (and
## the bear) entirely for as long as the freeze holds, piling onto the
## target instead - see the dedicated block right after `rooted` is
## computed below. `curse_active`/`curse_target`/`curse_target_pos` are
## captured once, right here at the top, rather than re-checked per
## enemy - the target's own stun_turns_left (what actually drives
## _is_the_hunger_calls_active()) ticks down partway through this same
## loop once its own turn comes up, so every enemy this pass needs to
## see the same answer regardless of iteration order.
func _enemy_turn() -> void:
	var curse_active: bool = _is_the_hunger_calls_active()
	var curse_target: Dictionary = _hunger_calls_target if curse_active else {}
	var curse_target_pos: int = curse_target.get("pos_index", -1) if curse_active else -1
	var curse_damage_multiplier: float = 1.0 + _hunger_calls_bonus_damage_pct

	# The rival's own guards caught in the player's The Hollow Cold tick
	# at the start of the enemy turn, same as every enemy's own DoT
	# does just below. Guards never decide the battle, so no
	# _battle_over bail-out is needed here.
	_tick_enemy_guards_the_hollow_cold()
	_tick_hollow_cold_tears(false)

	for enemy in _enemies.duplicate():
		# Every DoT/execute effect currently on this enemy lands right
		# here, at the very start of its own turn - before stun is even
		# checked, so a DoT still burns through one. See
		# _tick_enemy_turn_start_effects()'s own comment for the full
		# list. A kill from one of these can end the whole battle (last
		# enemy standing, stage clears, etc.), so this needs the same
		# bail-out every other kill site in this function already uses;
		# a kill that leaves the fight still going just skips the rest
		# of this specific enemy's turn instead.
		_tick_enemy_turn_start_effects(enemy)
		if _battle_over:
			return
		if not _is_enemy_still_active(enemy):
			continue

		var stun_turns_left: int = enemy.get("stun_turns_left", 0)
		if stun_turns_left > 0:
			# Loses this turn entirely - no move, no attack - then the
			# counter ticks down toward wearing off.
			enemy["stun_turns_left"] = stun_turns_left - 1
			continue

		var enemy_static: Dictionary = enemy["static"]

		if enemy_static.get("is_hero_fight_boss", false):
			_enemy_hero_turn(enemy)
			continue

		var enemy_type: String = enemy_static.get("type", "")
		var enemy_damage: float = float(enemy_static.get("damage", 0))
		# Dreadlure's own Deathlight Lure (see _can_enemy_see_hero()'s own
		# comment) overrides this - true sight lets him keep fighting a
		# hidden player normally, stealth notwithstanding.
		var hero_hidden: bool = not _can_enemy_see_hero()
		# Root (Thornbind's own, or Rootveil's) is checked with its
		# CURRENT value before ticking it down - same "use it, then
		# decrement" order stun_turns_left uses just above - so a 1-turn
		# root actually blocks the one movement it's meant to, instead of
		# expiring before it's ever consulted.
		var rooted: bool = _is_enemy_rooted(enemy) or _is_column_frostbound_rupture_blocked(enemy["pos_index"])
		if enemy.get("root_turns_left", 0) > 0:
			enemy["root_turns_left"] -= 1
		# Silence has nothing to gate for a regular creep - only
		# _enemy_hero_turn() (the boss) ever checks _is_enemy_silenced()
		# before attempting a skill cast - so unlike root above, there's
		# no "consumed" moment to decrement it at here. Tick it down
		# unconditionally instead (same as _enemy_hero_turn()'s own copy
		# does for the boss), or a creep silenced by Thornbind would carry
		# it forever - never expiring since nothing ever "uses" it.
		if enemy.get("silence_turns_left", 0) > 0:
			enemy["silence_turns_left"] -= 1

		if curse_active and not is_same(enemy, curse_target) and _distance(enemy["pos_index"], curse_target_pos) <= _hunger_calls_range:
			# Cursed: this enemy drops the hero/bear entirely for this
			# turn and piles onto the frozen target instead - attacking
			# it (for bonus damage) if already within its own normal
			# attack reach of the target, otherwise closing in on it one
			# step at a time, same movement rules (including staying put
			# while rooted or ice-frozen) as it would use against the
			# hero.
			if enemy_type == "range":
				if _distance(enemy["pos_index"], curse_target_pos) <= _enemy_attack_range(enemy):
					_play_enemy_attack_lunge(enemy, curse_target_pos)
					_fire_enemy_projectile(enemy, curse_target.get("node"))
					# Another creep's own attack, not the hero's - Corrosive
					# Lure's own bonus never applies to it.
					_deal_fixed_damage_to_enemy(curse_target, enemy_damage * curse_damage_multiplier, false, false)
					_deferred_hit_node = null
				elif not rooted:
					var step: int = _step_toward(enemy["pos_index"], curse_target_pos)
					var next_pos: int = enemy["pos_index"] + step
					if not _is_column_frostbound_rupture_blocked(next_pos):
						_move_enemy(enemy, next_pos)
			elif enemy_type == "melee":
				if enemy["pos_index"] == curse_target_pos:
					_play_enemy_attack_lunge(enemy)
					# Same reasoning as the ranged branch above.
					_deal_fixed_damage_to_enemy(curse_target, enemy_damage * curse_damage_multiplier, false, false)
				elif not rooted:
					var step: int = _step_toward(enemy["pos_index"], curse_target_pos)
					var next_pos: int = enemy["pos_index"] + step
					if not _is_column_frostbound_rupture_blocked(next_pos):
						_move_enemy(enemy, next_pos)
			continue

		if enemy_type == "range":
			var hero_distance: int = _distance(enemy["pos_index"], _hero_pos_index)

			if not hero_hidden and not rooted and _enemy_flees_at(enemy, hero_distance):
				# TOO CLOSE to the hero: move away. Attacking is next
				# turn's business, even if the flee step happens to
				# land back in range. Doesn't apply while he's
				# invisible (nothing visible to flee from), rooted, or
				# ice-frozen (can't move at all either way) - and not at
				# all if the flee spot itself is walled off, same as any
				# other blocked destination.
				var flee_pos: int = _get_flee_position(enemy)
				if not _is_column_frostbound_rupture_blocked(flee_pos):
					_move_enemy(enemy, flee_pos)
				continue

			var attacked: bool = false
			if hero_distance <= _enemy_attack_range(enemy) and not hero_hidden:
				# SAFE RANGE on the hero, and he's a valid target -
				# always the priority over the bear.
				_play_enemy_attack_lunge(enemy, _hero_pos_index)
				_fire_enemy_projectile(enemy, hero_image)
				if not _enemy_attack_misses_hero() and _try_redirect_hit_to_guard(enemy_damage) < 0.0:
					apply_damage(enemy_damage)
				_deferred_hit_node = null
				attacked = true
			elif _is_bear_alive() and _distance(enemy["pos_index"], _bear["pos_index"]) <= _enemy_attack_range(enemy):
				# Hero's out of range (or hidden), but the bear is
				# close enough to shoot instead.
				_play_enemy_attack_lunge(enemy, _bear["pos_index"])
				_fire_enemy_projectile(enemy, _bear.get("node"))
				_deal_damage_to_bear(enemy_damage)
				_deferred_hit_node = null
				attacked = true
			elif not _nearest_guard_within(enemy["pos_index"], _enemy_attack_range(enemy)).is_empty():
				# The hero's out of reach (or hidden), but one of his Imperial
				# Guard is close enough to shoot instead - the nearest one.
				var shot_guard: Dictionary = _nearest_guard_within(enemy["pos_index"], _enemy_attack_range(enemy))
				_play_enemy_attack_lunge(enemy, shot_guard["pos_index"])
				_fire_enemy_projectile(enemy, shot_guard.get("node"))
				_enemy_attack_guard(shot_guard, enemy_damage)
				_deferred_hit_node = null
				attacked = true

			if not attacked and not rooted:
				# TOO FAR from anything worth shooting: close in on
				# whichever threat is nearer - but while the hero is
				# hidden, the bear is the only thing worth chasing at
				# all, so stand still if it's not around either. A
				# rooted (or ice-frozen) enemy skips this whole branch
				# and just stays put regardless.
				var target_pos: int = _nearest_threat_pos(enemy["pos_index"], hero_hidden)
				if target_pos != -1:
					var step: int = _step_toward(enemy["pos_index"], target_pos)
					var next_pos: int = enemy["pos_index"] + step
					if not _is_column_frostbound_rupture_blocked(next_pos):
						_move_enemy(enemy, next_pos)

		elif enemy_type == "melee":
			var attacked: bool = false
			if enemy["pos_index"] == _hero_pos_index and not hero_hidden:
				_play_enemy_attack_lunge(enemy)
				var melee_dealt: float = 0.0
				if not _enemy_attack_misses_hero():
					melee_dealt = _try_redirect_hit_to_guard(enemy_damage)
					if melee_dealt < 0.0:
						melee_dealt = apply_damage(enemy_damage)
				_apply_enemy_companion_hit_effects(enemy, melee_dealt)
				attacked = true
			elif _is_bear_alive() and enemy["pos_index"] == _bear["pos_index"]:
				_play_enemy_attack_lunge(enemy)
				_deal_damage_to_bear(enemy_damage)
				_apply_enemy_companion_hit_effects(enemy, enemy_damage)
				attacked = true
			elif not _guards_at(enemy["pos_index"]).is_empty():
				# The hero isn't in reach (or can't be seen), but one of his
				# Imperial Guard stands right here - the weakest of them
				# takes the blow.
				_play_enemy_attack_lunge(enemy)
				_enemy_attack_guard(_nearest_guard_within(enemy["pos_index"], 0), enemy_damage)
				attacked = true

			if not attacked and not rooted:
				var target_pos: int = _nearest_threat_pos(enemy["pos_index"], hero_hidden)
				if target_pos != -1:
					var step: int = _step_toward(enemy["pos_index"], target_pos)
					var next_pos: int = enemy["pos_index"] + step
					if not _is_column_frostbound_rupture_blocked(next_pos):
						_move_enemy(enemy, next_pos)


## Whichever "threat" - the hero, the Elderwild Companion if one is
## currently summoned, or any of the Last Empress's Imperial Guard - sits
## closest to `enemy_pos`, ties going to the hero. Only used to choose a
## movement target when nothing is in attack/flee range this turn (see
## _enemy_turn()).
##
## `hero_is_hidden` excludes the hero from consideration entirely -
## while Veyrik is invisible enemies can't track him to move toward
## him, only the bear and the guards (if any are out). Returns -1 when
## there's nothing left to chase, which the caller reads as "don't move".
func _nearest_threat_pos(enemy_pos: int, hero_is_hidden: bool = false) -> int:
	var best_pos: int = -1
	var best_distance: int = GRID_COLUMNS + 1
	if not hero_is_hidden:
		best_pos = _hero_pos_index
		best_distance = _distance(enemy_pos, _hero_pos_index)
	if _is_bear_alive():
		var bear_distance: int = _distance(enemy_pos, _bear["pos_index"])
		if bear_distance < best_distance:
			best_pos = _bear["pos_index"]
			best_distance = bear_distance
	for guard in _guards:
		var guard_distance: int = _distance(enemy_pos, guard["pos_index"])
		if guard_distance < best_distance:
			best_pos = guard["pos_index"]
			best_distance = guard_distance
	return best_pos


# ------------------------------------------------------------------
# A rival hero's own turn, during a hero fight - tries a skill first
# (see _pick_enemy_ready_skill()/_cast_enemy_skill()), falling back to
# the same flee/attack/approach behavior a regular creep uses in
# _enemy_turn() if nothing is ready/affordable/worthwhile right now, or
# if the player is currently untargetable (his own Depthsveil).
#
# Two simplifications versus a regular creep's own targeting: a rival
# hero always focuses the player's hero directly rather than ever
# being drawn to the player's Elderwild Companion the way a creep can be, and
# (like a creep) always moves exactly one column per turn regardless
# of the hero's own speed stat - matching how a hero fight boss has
# always been treated as a single flattened enemy rather than a full
# player-equivalent hero.
# ------------------------------------------------------------------

func _enemy_hero_turn(enemy: Dictionary) -> void:
	# Held in The Test of Time - no action at all this turn, not even a free
	# Undertow teleport or a potion: move, attack, skill, and
	# item are ALL locked out for the duration, matching the player's
	# own copy (_update_action_buttons()/_end_turn()'s auto-skip). Its
	# immunity/heal-per-turn already run via _tick_enemy_the_test_of_time()
	# regardless of what this turn does, so this just needs to do
	# nothing and let the turn pass.
	if _enemy_the_test_of_time_active:
		return

	# Kiss the Wastes' channel: consumes this ENTIRE turn on an automatic
	# shot instead of the normal potion/skill/attack/move decision below
	# - no move, no attack, no other skill, no item, mirroring the
	# player's own copy (_end_turn()'s own "the hero's new turn is
	# opening right here" tail). Never falls through to anything else
	# below while a shot remains.
	if _enemy_kiss_the_wastes_active:
		_fire_enemy_kiss_the_wastes_shot()
		_enemy_kiss_the_wastes_turns_left -= 1
		if _enemy_kiss_the_wastes_turns_left <= 0:
			_end_enemy_kiss_the_wastes()
		return

	# If Undertow marked the player last turn, this is the
	# rival's own "next turn" - teleport now, for free, then fall
	# straight through to everything below so it can still act (skill,
	# attack, or move) this same turn, same as the player's own copy
	# never spends the turn it teleports on (_resolve_undertow_teleport()).
	if _enemy_undertow_pending:
		_enemy_undertow_pending = false
		var from_pos: Vector2 = enemy["node"].position
		_move_enemy(enemy, _hero_pos_index)
		_show_message_over_hero("Undertow!")
		_play_undertow_dive(enemy["node"], from_pos)

	_update_enemy_blood_of_the_wild_state(enemy)

	var enemy_type: String = _enemy_hero_attack_type(enemy)
	var hero_distance: int = _distance(enemy["pos_index"], _hero_pos_index)
	# Dreadlure's own Deathlight Lure (see _can_enemy_see_hero()'s own
	# comment) overrides this - true sight lets him keep fighting a
	# hidden player normally, stealth notwithstanding.
	var hero_hidden: bool = not _can_enemy_see_hero()
	# Frostbound Rupture (the player's own, cast on this rival's turn) freezes
	# movement exactly like a root does - see _enemy_turn()'s own
	# comment for the full reasoning - so it's folded into the same
	# `rooted` flag rather than tracked separately here.
	# Root/silence are both checked with their CURRENT value before
	# ticking them down - same "use it, then decrement" order stun
	# uses in _enemy_turn() - so a 1-turn root/silence actually blocks
	# the one turn it's meant to, instead of expiring before it's ever
	# consulted (see _tick_enemy_turn_start_effects()'s own comment).
	var rooted: bool = _is_enemy_rooted(enemy) or _is_column_frostbound_rupture_blocked(enemy["pos_index"])
	if enemy.get("root_turns_left", 0) > 0:
		enemy["root_turns_left"] -= 1
	var silenced: bool = _is_enemy_silenced(enemy)
	if enemy.get("silence_turns_left", 0) > 0:
		enemy["silence_turns_left"] -= 1

	# Potion, skill, or basic attack - in that priority, one action per
	# turn, exactly mirroring EnemyHeroManager's own simulated turn
	# order. Drinking a potion is an item, not a spell, so - like the
	# player's own item buttons - it's never gated by hero_hidden/
	# silence/root the way casting a skill or attacking is.
	var effective_max_hp: float = _enemy_hero_effective_max_hp(enemy)
	if float(enemy.get("current_hp", 0.0)) <= effective_max_hp * EnemyHeroManager.LOW_HP_POTION_THRESHOLD and _enemy_potion_health_count > 0:
		_drink_enemy_health_potion(enemy)
		return

	# A hidden player can't be targeted, but his Elderwild Companion still can,
	# and a self-cast heal (Whisper of the Veil on himself) needs no target at all
	# - so the rival still gets to pick a skill; the picker (via
	# _enemy_ai_hero_hidden) then only considers the bear-targetable
	# ones, aimed at the bear, plus that self-heal.
	# Beast of the Elderwild is committed to: the rival walks in for it (see
	# closing_for_beast below), so once the player is within its reach it is
	# cast regardless of what the scorer thinks of it at his current HP - it's
	# his best skill. The one thing allowed to go first is a missing companion.
	if not silenced and not hero_hidden and hero_distance <= EnemySkillRange.BEAST_OF_THE_ELDERWILD_REACH 			and _is_enemy_skill_ready("beast_of_the_elderwild", enemy_type, hero_distance, enemy):
		var companion_first: bool = _get_enemy_elderwild_companion().is_empty() 				and _is_enemy_skill_ready("elderwild_companion", enemy_type, hero_distance, enemy)
		if not companion_first:
			_cast_enemy_skill(enemy, "beast_of_the_elderwild")
			return

	if not silenced:
		_enemy_ai_hero_hidden = hero_hidden
		var skill_id: String = _pick_enemy_ready_skill(enemy, enemy_type, hero_distance)
		if skill_id != "":
			_cast_enemy_skill(enemy, skill_id)
			_enemy_ai_hero_hidden = false
			return
		_enemy_ai_hero_hidden = false
		if not hero_hidden and _enemy_has_unaffordable_ready_skill(enemy_type, hero_distance, enemy) and _enemy_potion_mana_count > 0:
			_drink_enemy_mana_potion()
			return

	# Beast of the Elderwild is a melee form: if it's ready but the player is
	# further than its reach, close in (skipping the usual kite/shoot) so it
	# can actually be cast next turn.
	var closing_for_beast: bool = enemy_type == "range" and not hero_hidden and not rooted and hero_distance > EnemySkillRange.BEAST_OF_THE_ELDERWILD_REACH and _is_enemy_skill_ready("beast_of_the_elderwild", enemy_type, hero_distance, enemy, true)

	if enemy_type == "range" and not closing_for_beast:
		if not hero_hidden and not rooted and _enemy_flees_at(enemy, hero_distance):
			var flee_pos: int = _get_flee_position(enemy)
			if not _is_column_frostbound_rupture_blocked(flee_pos):
				_move_enemy(enemy, flee_pos)
			return

		if hero_distance <= _enemy_attack_range(enemy) and not hero_hidden:
			_resolve_enemy_hero_attack(enemy)
			return
	else:  # "melee"
		if hero_distance <= 0 and not hero_hidden:
			_resolve_enemy_hero_attack(enemy)
			return

	if not hero_hidden and not rooted:
		var step: int = _step_toward(enemy["pos_index"], _hero_pos_index)
		if step != 0:
			# Dreadlure's Hunting Instinct boosts this same fallback move,
			# same "changes what the NEXT normal move does" shape the
			# player's own copy has in _hero_move() - a no-op walk of 1
			# column, same as every other enemy, while it isn't active.
			if _enemy_hunting_instinct_turns_remaining > 0:
				var instinct_distance: int = 1 + _enemy_hunting_instinct_bonus_movement
				var instinct_result: Dictionary = _enemy_hunting_instinct_move_target(enemy["pos_index"], step, instinct_distance)
				var landing_pos: int = int(instinct_result["pos"])
				if landing_pos != enemy["pos_index"]:
					var rival_node: TextureRect = enemy["node"]
					rival_node.flip_h = step < 0
					var rival_from: Vector2 = rival_node.global_position
					var rival_shift := Vector2(_index_to_x(landing_pos) - rival_node.position.x, 0.0)
					DreadlureFX.surge(_fx_layer, rival_node, rival_from, rival_from + rival_shift, hero_image if bool(instinct_result["hit_player"]) else null)
					_move_enemy(enemy, landing_pos)
				if bool(instinct_result["hit_player"]):
					var charge_damage: float = _roll_enemy_hero_damage(enemy) * _enemy_hunting_instinct_charge_damage_pct
					apply_damage(charge_damage)
			else:
				var next_pos: int = enemy["pos_index"] + step
				if not _is_column_frostbound_rupture_blocked(next_pos):
					_move_enemy(enemy, next_pos)


## Heals the boss for the Health Potion's own flat value (same item
## data the player's own copy in _on_item_pressed() reads), clamped to
## their current effective max hp, and writes the new count straight
## back to PlayerManager immediately rather than waiting for the fight
## to resolve - it's already reflected there no matter how the fight
## ends (win, loss, or a flee - see _handle_defeat()/_on_flee_pressed()).
func _drink_enemy_health_potion(enemy: Dictionary) -> void:
	_enemy_potion_health_count -= 1
	PlayerManager.set_npc_potion_count(_enemy_hero_id, "health", _enemy_potion_health_count)
	PlayLog.event("rival_potion", {"potion": "health", "left": _enemy_potion_health_count, "turn": _turn_count})

	var heal_amount: float = float(GameManager.get_item("health").get("value", 0))
	var max_hp: float = _enemy_hero_effective_max_hp(enemy)
	enemy["current_hp"] = minf(max_hp, enemy["current_hp"] + heal_amount)
	_show_message_over_hero("Rival drank a Health Potion")
	_refresh_bars()


## Restores the Mana Potion's own flat value, clamped to _enemy_max_mana.
func _drink_enemy_mana_potion() -> void:
	_enemy_potion_mana_count -= 1
	PlayerManager.set_npc_potion_count(_enemy_hero_id, "mana", _enemy_potion_mana_count)
	PlayLog.event("rival_potion", {"potion": "mana", "left": _enemy_potion_mana_count, "turn": _turn_count})

	var mana_amount: float = float(GameManager.get_item("mana").get("value", 0))
	_enemy_current_mana = minf(_enemy_max_mana, _enemy_current_mana + mana_amount)
	_show_message_over_hero("Rival drank a Mana Potion")
	_refresh_bars()


## The rival hero's plain Attack against the player: rolls their
## effective damage (folding in their own Leeching Hunger/Beast of the Elderwild
## bonuses and, once per activation, Depthsveil's one-shot bonus if
## they're currently hidden), applies it to the player, then runs
## Leeching Hunger's steal and Wildbond's lifesteal - both of which,
## exactly like the player's own copies, only ever trigger off this
## plain Attack, never off a skill.
func _resolve_enemy_hero_attack(enemy: Dictionary) -> void:
	# Always aimed at the player; a ranged rival turns to face him first
	# (a melee one shares his column, so this leaves its facing alone).
	_play_enemy_attack_lunge(enemy, _hero_pos_index)
	var shadow_bonus: float = _enemy_depthsveil_bonus_damage if _enemy_depthsveil_active else 0.0
	# Same idea for Rootveil, just with a root on the player
	# instead of bonus damage - captured now, before the attack (and
	# possibly _end_enemy_rootveil()) below can change what
	# _enemy_rootveil_active reads.
	var attacking_from_enemy_rootveil: bool = _enemy_rootveil_active
	var pull_of_the_abyss_level_data: Dictionary = _maybe_consume_enemy_pull_of_the_abyss_stack()
	var pull_of_the_abyss_bonus: float = float(pull_of_the_abyss_level_data.get("bonus_damage", 0.0))
	# Might of the Deep counts this Attack toward its own threshold too,
	# same idea as Pull of the Abyss's stack just above - once reached, this
	# hit's own damage is boosted by a PERCENTAGE of itself (folded in
	# below, after the roll - unlike Pull of the Abyss's flat pre-roll bonus),
	# and the player gets knocked back afterward (see
	# _apply_enemy_might_of_the_deep_knockback(), called once apply_
	# damage() has already resolved).
	var might_level_data: Dictionary = _maybe_consume_enemy_might_of_the_deep_stack()
	# Solara's own Ambush Strike pays off the same way, just as a
	# PERCENTAGE of the attack's own rolled damage (folded in AFTER the
	# roll, below), same "post-roll percentage" shape Might of the Deep's
	# own bonus uses. Only one of Depthsveil/Ambush Strike could
	# ever be active in a given fight (different heroes' own kits), so
	# this never double-counts either way.
	var ambush_strike_active_bonus_pct: float = _enemy_ambush_strike_bonus_damage_pct if _enemy_ambush_strike_active else 0.0
	var attack_damage: float = _roll_enemy_hero_damage(enemy, shadow_bonus + pull_of_the_abyss_bonus)
	if ambush_strike_active_bonus_pct > 0.0:
		attack_damage += attack_damage * ambush_strike_active_bonus_pct
	if not might_level_data.is_empty():
		attack_damage += attack_damage * float(might_level_data.get("bonus_damage_pct", 0.0))
	_play_hero_attack_effect(_enemy_hero_static, enemy.get("node"), hero_image, _enemy_beast_of_the_elderwild_active)
	var rival_missed: bool = _enemy_attack_misses_hero()
	var mitigated: float = 0.0 if rival_missed else _try_redirect_hit_to_guard(attack_damage)
	if not rival_missed and mitigated < 0.0:
		mitigated = apply_damage(attack_damage)
	_deferred_hit_node = null
	var hit_log: Dictionary = _play_log_state()
	hit_log["raw"] = roundi(attack_damage)
	hit_log["dealt"] = roundi(mitigated)
	hit_log["armor"] = snappedf(_hero_armor(), 0.01)
	hit_log["beast"] = _enemy_beast_of_the_elderwild_active
	PlayLog.event("rival_hit", hit_log)

	_apply_enemy_leeching_hunger_steal(enemy, mitigated)
	_apply_enemy_wildbond_lifesteal(enemy, mitigated)
	_apply_enemy_mark_of_the_mist_stack()
	_apply_enemy_frostbound_fangs_attack()
	# Empress's Will's splash onto the player's guards/bear near him - a
	# no-op unless the skill is learned.
	_apply_enemy_empress_will_splash(attack_damage)

	if not pull_of_the_abyss_level_data.is_empty():
		# Its bonus damage is already folded into the roll above; the
		# cleave reaches the player's own guards/bear standing near
		# him (see _apply_enemy_pull_of_the_abyss_cleave()).
		_show_rising_message_over(hero_image, "Pull of the Abyss!", PULL_OF_THE_ABYSS_TEXT_COLOR)
		_apply_enemy_pull_of_the_abyss_cleave(attack_damage, pull_of_the_abyss_level_data)

	# Lunar Ricochet' own bounce - a no-op unless the skill is learned (see
	# _apply_enemy_lunar_ricochet_bounces()'s own gate). Independent of
	# Pull of the Abyss's above.
	_apply_enemy_lunar_ricochet_bounces(attack_damage)

	# Might of the Deep's own knockback - after leeching hunger/lifesteal/
	# Mark of the Mist above, same "resolve every OTHER effect of the hit
	# before shoving the target somewhere else" ordering
	# _apply_hero_attack()'s own player-side copy follows. A no-op unless
	# this attack is the one that triggered the stack, and only if the
	# player actually survived it.
	if not might_level_data.is_empty():
		var strike_dir: int = _step_toward(enemy["pos_index"], _hero_pos_index)
		if strike_dir == 0:
			strike_dir = -1 if bool(enemy["node"].flip_h) else 1
		DreadlureFX.might_strike(_fx_layer, hero_image, strike_dir)
	if not might_level_data.is_empty() and _recruited.get("current_hp", 0) > 0:
		_apply_enemy_might_of_the_deep_knockback(enemy, might_level_data)

	if _enemy_depthsveil_active and shadow_bonus > 0.0:
		_end_enemy_depthsveil()
	elif ambush_strike_active_bonus_pct > 0.0:
		_end_enemy_ambush_strike()

	if attacking_from_enemy_rootveil:
		if _recruited.get("current_hp", 0) > 0:
			_player_root_turns_left = _enemy_rootveil_root_turns
		_end_enemy_rootveil()


## The rival hero's flat "damage" stat (see GameManager.build_hero_
## fight_enemy_def(), which averages their real min-max damage into
## one number the same way every other enemy in this scene works)
## plus whatever their own active buffs currently add - the enemy-side
## mirror of _roll_hero_damage(). No randomness, matching how every
## other enemy in this scene deals a flat amount rather than rolling a
## range.
func _roll_enemy_hero_damage(enemy: Dictionary, extra_bonus: float = 0.0) -> float:
	var base_damage: float = float(enemy["static"].get("damage", 0))
	var bonus: float = _enemy_beast_of_the_elderwild_bonus_damage + _enemy_frostbound_fangs_bonus_damage + _enemy_bestial_rage_bonus_damage + extra_bonus
	var total: float = maxf(0.0, base_damage + bonus)

	# Lunara's Moonbound Might - read fresh off the rival's current level
	# every roll (see _get_enemy_moonbound_might_level_data()) rather than
	# tracked in a field, since it's never toggled on/off, just always-on
	# once learned. Applied last so it scales the whole roll, mirroring
	# the player's own _roll_hero_damage() exactly - this is the ONE
	# place it's ever folded in, so every caller of this function (a
	# plain Attack, Hunting Instinct's own charge damage, etc.) already has
	# it baked into whatever it reads back, with nothing further to add.
	var moonbound_might_bonus_pct: float = float(_get_enemy_moonbound_might_level_data().get("bonus_damage_pct", 0.0))
	if moonbound_might_bonus_pct > 0.0:
		total += total * moonbound_might_bonus_pct

	return total


## The rival's current max hp: base + Beast of the Elderwild's bonus hp
## while it is active - the enemy-side mirror of _hero_max_hp(). Used to clamp Wildbond's lifesteal.
func _enemy_hero_effective_max_hp(enemy: Dictionary) -> float:
	return float(enemy["static"].get("hp", 1)) + _enemy_beast_of_the_elderwild_bonus_hp


func _get_hero_fight_boss() -> Dictionary:
	if not _in_hero_fight:
		return {}
	for enemy in _enemies:
		if enemy["static"].get("is_hero_fight_boss", false):
			return enemy
	return {}


func _get_enemy_elderwild_companion() -> Dictionary:
	for enemy in _enemies:
		if enemy["static"].get("is_enemy_elderwild_companion", false):
			return enemy
	return {}


func _find_enemy_skill(skill_id: String) -> Dictionary:
	for skill in _enemy_hero_static.get("skills", []):
		if skill.get("id", "") == skill_id:
			return skill
	return {}


func _get_enemy_skill_level_data(skill_id: String) -> Dictionary:
	var skill: Dictionary = _find_enemy_skill(skill_id)
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, skill_id)
	return GameManager.get_skill_level_data(skill, level)


func _enemy_skill_mana_cost(skill_id: String) -> float:
	return float(_get_enemy_skill_level_data(skill_id).get("mana_cost", 0))


## False for a buff/summon skill that's already active and wouldn't do
## anything new right now (recasting Leeching Hunger/Depthsveil/Spirit
## Link/Beast of the Elderwild just restarts their duration from the same values,
## and a Elderwild Companion that's already out doesn't need replacing) - so
## the rival doesn't burn mana refreshing something with no benefit
## instead of attacking. Abyssal Spasm/Barbed Lunge/Thornbind always report true.
func _enemy_skill_worth_casting(skill_id: String) -> bool:
	match skill_id:
		"leeching_hunger":
			return not _enemy_leeching_hunger_active
		"depthsveil":
			return not _enemy_depthsveil_active
		"ambush_strike":
			return not _enemy_ambush_strike_active
		"eternal_eclipse":
			return not _enemy_eternal_eclipse_active
		"wildbond":
			return not _enemy_wildbond_active
		"beast_of_the_elderwild":
			return not _enemy_beast_of_the_elderwild_active
		"elderwild_companion":
			return _get_enemy_elderwild_companion().is_empty()
		"veil_of_the_forgotten":
			return not _enemy_veil_of_the_forgotten_active
		"undertow":
			# Not worth recasting while a mark is already pending -
			# there's only ever one possible target anyway (the
			# player), so a second cast would just burn mana/cooldown
			# on a mark that hasn't even resolved yet.
			return not _enemy_undertow_pending
		"mark_of_stillness":
			# Recasting on an already-frozen player just resets the
			# same level's own damage/duration back to full - no extra
			# total damage over just letting the existing DoT run out,
			# so (same simplification as every buff above) it's simply
			# not worth it while one is already ticking.
			return _enemy_skill_worth_on_target("mark_of_stillness", false) or (_is_bear_alive() and _enemy_skill_worth_on_target("mark_of_stillness", true))
		"the_hollow_cold":
			# Same "no benefit from resetting your own DoT" reasoning
			# as Mark of Stillness above.
			return _enemy_skill_worth_on_target("the_hollow_cold", false) or (_is_bear_alive() and _enemy_skill_worth_on_target("the_hollow_cold", true))
		"frostbound_fangs":
			return not _enemy_frostbound_fangs_active
		"the_test_of_time":
			return not _enemy_the_test_of_time_active
		"the_frost_tempest":
			return not _enemy_frost_tempest_active
		"winters_grip":
			# Recasting on an already-frostbitten player just resets the
			# same level's own DoT back to full - no extra total damage
			# over just letting it run out, same "no benefit from
			# resetting your own DoT" reasoning as Mark of Stillness/The Hollow Cold
			# above (there's only one possible target in a hero fight, so
			# unlike the simulation's own copy - which always targets
			# whichever living enemy is currently lowest-HP and so can't
			# rely on a single flag like this - recasting here can only
			# ever land on the same, already-frozen player).
			return _enemy_skill_worth_on_target("winters_grip", false) or (_is_bear_alive() and _enemy_skill_worth_on_target("winters_grip", true))
		"bestial_rage":
			return not _enemy_bestial_rage_active
		"rootveil":
			return not _enemy_rootveil_active
		"woven_flesh":
			return not _enemy_woven_flesh_active
		"sanguine_bloom":
			# Same "no benefit from resetting your own DoT" reasoning as
			# Mark of Stillness/The Hollow Cold/Winter's Grip above - recasting on an
			# already-seeded player just restarts the same level's own
			# damage/healing back to full, no extra total value over
			# letting the existing one run its course.
			return _enemy_skill_worth_on_target("sanguine_bloom", false) or (_is_bear_alive() and _enemy_skill_worth_on_target("sanguine_bloom", true))
		"kiss_the_wastes":
			# Purely defensive/documentation consistency, mirroring The Test of
			# Time's own case above - _enemy_hero_turn()'s own top-of-
			# function lockout already returns before this could ever be
			# QUERIED while the channel is active in practice.
			return not _enemy_kiss_the_wastes_active
		_:
			return true


## True if `skill_id` is known, off cooldown, worth casting, and
## affordable right now - the same four gates _pick_enemy_ready_skill()
## always applied inline, factored out so combo scoring (see
## _build_enemy_ai_context()'s "kaelen_varr_drowned_surge_combo_ready"/
## "kaelen_varr_the_sunken_one_combo_ready") can ask "would this skill be usable
## if range weren't the issue" via `ignore_range`, without duplicating
## the other four checks. `ignore_range` is only ever true for that
## combo-readiness question - the real candidate loop below always
## leaves it false, so nothing here changes for any existing hero.
## `enemy` is only ever read by _enemy_skill_in_range()'s own
## Double Trouble special-case (its own facing/position, for the
## directional check) - every other skill's range check ignores it.
func _is_enemy_skill_ready(skill_id: String, enemy_type: String, hero_distance: int, enemy: Dictionary, ignore_range: bool = false) -> bool:
	if PlayerManager.get_npc_skill_level(_enemy_hero_id, skill_id) <= 0:
		return false
	if _enemy_skill_cooldowns.get(skill_id, 0) > 0:
		return false
	if not _enemy_skill_worth_casting(skill_id):
		return false
	var level_data: Dictionary = _get_enemy_skill_level_data(skill_id)
	if _enemy_current_mana < float(level_data.get("mana_cost", 0)):
		return false
	# A skill that can be aimed at the player's Elderwild Companion is ready as
	# long as EITHER target is reachable and worth hitting - see
	# _enemy_skill_target_options(). Every other skill still needs the
	# player himself, visible and in range.
	if ENEMY_BEAR_TARGETABLE_SKILLS.has(skill_id):
		var options: Dictionary = _enemy_skill_target_options(skill_id, enemy_type, hero_distance, enemy, ignore_range)
		return options["hero"] or options["bear"]
	if _enemy_ai_hero_hidden:
		return false
	if not ignore_range and not _enemy_skill_in_range(skill_id, enemy_type, hero_distance, enemy):
		return false
	return true


## Every known, off-cooldown, currently-worthwhile, currently-
## affordable, in-range active skill the rival hero has right now (that
## is, every skill in ENEMY_KNOWN_SKILL_IDS that survives all of those
## checks), PLUS a plain Attack for whichever heroes EnemySkillAI.
## basic_attack_participates() opts in (today: only Kaelen Varr, whose
## Pull of the Abyss can make a plain Attack the better play - see
## EnemySkillAI's own "basic_attack" scoring), is scored by
## EnemySkillAI.evaluate_skill()/evaluate_basic_attack(), and the
## highest-scoring one wins - ties within EnemySkillAI.
## CLOSE_SCORE_THRESHOLD are resolved by a score-weighted random pick,
## falling back to the hero's own EnemySkillAI.HERO_TIE_BREAK order only
## if that still doesn't settle it. Returns "" if no candidate qualifies
## at all, OR if the winner was that plain-Attack candidate - either way
## the caller's own existing basic-attack fallback takes over unchanged.
## `enemy_type`/`hero_distance` still gate skills that actually need to
## reach the player - see _enemy_skill_in_range()/EnemySkillRange - so a
## boss can't land Abyssal Spasm or Thornbind from clear across the board; it
## has to close in first, same as it already must for a plain Attack.
## This replaces the old "first match in ENEMY_KNOWN_SKILL_IDS wins"
## rule - the array is still every skill this AI ever considers, it's
## just no longer the order they're preferred in.
func _pick_enemy_ready_skill(enemy: Dictionary, enemy_type: String, hero_distance: int) -> String:
	var context: Dictionary = _build_enemy_ai_context(enemy, enemy_type, hero_distance)
	var candidates: Array = []

	for skill_id in ENEMY_KNOWN_SKILL_IDS:
		if not _is_enemy_skill_ready(skill_id, enemy_type, hero_distance, enemy):
			continue
		var level_data: Dictionary = _get_enemy_skill_level_data(skill_id)
		candidates.append({"id": skill_id, "score": EnemySkillAI.evaluate_skill(skill_id, level_data, context)})

	# Whisper of the Veil on himself (the self-heal) competes as its own candidate,
	# alongside Whisper of the Veil aimed at the player - see
	# EnemySkillAI.WHISPER_OF_THE_VEIL_SELF_ID. _cast_enemy_skill() maps a win
	# back onto a self-targeted "whisper_of_the_veil" cast.
	if _enemy_whisper_of_the_veil_self_ready(enemy):
		var whisper_of_the_veil_level_data: Dictionary = _get_enemy_skill_level_data("whisper_of_the_veil")
		candidates.append({"id": EnemySkillAI.WHISPER_OF_THE_VEIL_SELF_ID, "score": EnemySkillAI.evaluate_skill(EnemySkillAI.WHISPER_OF_THE_VEIL_SELF_ID, whisper_of_the_veil_level_data, context)})

	var archetype: String = str(context.get("archetype", ""))
	if EnemySkillAI.basic_attack_participates(archetype):
		candidates.append({"id": EnemySkillAI.BASIC_ATTACK_ID, "score": EnemySkillAI.evaluate_basic_attack(context)})

	var chosen_id: String = EnemySkillAI.pick_best_skill(archetype, candidates, str(_enemy_hero_static.get("name", _enemy_hero_id)))
	return "" if chosen_id == EnemySkillAI.BASIC_ATTACK_ID else chosen_id


## Whether the rival could cast Whisper of the Veil on himself right now: learned,
## off cooldown, affordable, and with more HP than its hp_cost - paying
## it must never kill him. No range or "worth casting" gate (it's a
## self-cast heal; EnemySkillAI's own scoring decides whether it's worth
## it), and - being self-targeted - it stays available even while the
## player is hidden.
func _enemy_whisper_of_the_veil_self_ready(enemy: Dictionary) -> bool:
	if PlayerManager.get_npc_skill_level(_enemy_hero_id, "whisper_of_the_veil") <= 0:
		return false
	if _enemy_skill_cooldowns.get("whisper_of_the_veil", 0) > 0:
		return false
	var level_data: Dictionary = _get_enemy_skill_level_data("whisper_of_the_veil")
	if _enemy_current_mana < float(level_data.get("mana_cost", 0)):
		return false
	return float(enemy.get("current_hp", 0.0)) > float(level_data.get("hp_cost", 0))


## True if there's a known, off-cooldown, currently-worthwhile, in-range
## active skill the rival just can't afford right now - the trigger for
## drinking a Mana Potion instead of attacking this turn, mirroring
## EnemyHeroManager's own _has_unaffordable_ready_skill(). Only ever
## checked once _pick_enemy_ready_skill() has already come up empty, so
## this only needs to explain WHY it came up empty (mana, specifically)
## rather than re-picking anything.
func _enemy_has_unaffordable_ready_skill(enemy_type: String, hero_distance: int, enemy: Dictionary) -> bool:
	for skill_id in ENEMY_KNOWN_SKILL_IDS:
		if PlayerManager.get_npc_skill_level(_enemy_hero_id, skill_id) <= 0:
			continue
		if _enemy_skill_cooldowns.get(skill_id, 0) > 0:
			continue
		if not _enemy_skill_worth_casting(skill_id):
			continue
		if not _enemy_skill_in_range(skill_id, enemy_type, hero_distance, enemy):
			continue
		var level_data: Dictionary = _get_enemy_skill_level_data(skill_id)
		if _enemy_current_mana < float(level_data.get("mana_cost", 0)):
			return true
	return false


## Builds the AI context EnemySkillAI scores every candidate skill
## against for this rival's turn - the battle-mode counterpart of
## EnemyHeroManager.gd's own _build_npc_ai_context(). The player is
## always the rival's only possible target during a hero fight, so
## `enemy_count` is always 1 here (contrast the simulation, where it's
## however many creeps are still alive) and there's no per-target
## selection step the way a multi-enemy sim needs one. `living_target_
## hps`/`living_target_max_hps` are the single-player mirror of the
## simulation's own living-enemy HP/max-HP lists - always one entry
## here, but kept under the same keys so EnemySkillAI's shared multi-
## kill/execute scoring (see Kaelen Varr's own The Sunken One/Drowned Surge modifiers
## and Nhal's own Return to the Void modifier) doesn't need a
## battle-vs-sim branch.
##
## The three "kaelen_varr_*"/"pull_of_the_abyss_*" fields only ever matter for
## Kaelen Varr (every other hero's own modifier ignores them) - they're
## still computed unconditionally since that's cheap and keeps this
## function hero-agnostic, same as every other field here:
##   - pull_of_the_abyss_ready/pull_of_the_abyss_cleave_targets/pull_of_the_abyss_bonus_
##     damage: whether the rival's NEXT plain Attack would activate
##     Pull of the Abyss, and what that's worth - see
##     _maybe_consume_enemy_pull_of_the_abyss_stack() for the real activation
##     this only ever previews. cleave_targets counts the player's own
##     guards/Elderwild Companion within cleave_columns of him - the only
##     things besides the player himself the cleave can reach (see
##     _apply_enemy_pull_of_the_abyss_cleave()).
##   - kaelen_varr_drowned_surge_combo_ready/kaelen_varr_the_sunken_one_combo_ready: whether
##     Drowned Surge/The Sunken One would be castable right now if range weren't
##     the issue (see _is_enemy_skill_ready()'s `ignore_range`) - X
##     Marks the Spot always closes the distance to 0 by the rival's own
##     next turn (see _enemy_hero_turn()'s teleport-consumption step),
##     so "everything else about it is ready" is the real question for
##     whether marking now sets up a real follow-up.
##   - in_attack_range_now/in_attack_range_with_frostbound_fangs_bonus/
##     frostbound_fangs_active: for The Primordial Hunger's own Frostbound Fangs - whether
##     the player is (or would be, with the bonus range folded in)
##     within the rival's own basic-attack reach right now, so casting
##     it only scores well when there's a realistic attack coming, not
##     just because it's off cooldown.
##   - has_harmful_debuff: whether the rival currently has anything the
##     player inflicted on it (root/silence/a DoT/Mark of the Mist) -
##     for The Primordial Hunger's own The Test of Time, which dispels it.
##   - redirect_candidate_count/avg_enemy_damage: for The Primordial Hunger's own
##     The Hunger Calls. Always 0/0.0 here - a hero fight only ever has
##     the player to curse, and nothing else on the rival's own side to
##     redirect onto the frozen target the way the simulation's other
##     living creeps can (see EnemyHeroManager's own _build_npc_ai_
##     context() for the real multi-enemy version of both fields).
##   - target_distance: also doubles as Frost Daughter's own Freezing
##     Field range check (see EnemySkillAI's own _fd_frost_tempest_
##     modifier()) - The Frost Tempest is centered on HERSELF, not the
##     player, but in a hero fight `hero_distance` (the rival's distance
##     to the player) and "the player's distance to the rival" are the
##     same number, so there's no separate field to compute.
##   - caster_pos_index/target_pos_index/grid_columns/caster_facing_left:
##     for Skarn's own Frostbound Rupture (whether its wall actually reaches the
##     player's column, and how close to either board edge that leaves
##     them) and Glacier Breaker (working out the knockback's actual
##     landing column, the same walk _cast_enemy_glacier_breaker() itself
##     does, just to SCORE it beforehand rather than to resolve it) -
##     see EnemySkillAI's own _skarn_frostbound_rupture_modifier()/_skarn_glacier_
##     breaker_modifier(). Never present in the simulation (no positions
##     there at all - see EnemyHeroManager's own _build_npc_ai_context()
##     docstring), where `grid_columns` defaults to 0 and both modifiers
##     fall back to their own no-columns proxy instead.
##   - kindled_resolve_stacks/kindled_resolve_max_stacks: Cinder's own
##     current Kindled Resolve stack count/cap, for EnemySkillAI's own
##     _cinder_modifier() to fold into its survival/aggression
##     calculations (see that function's own docstring) - 0/0 for every
##     other hero (a no-op there, same as every other hero-specific
##     field in this context).
##   - target_is_hero: always true here - the player is the only
##     possible target in a hero fight, and always a hero. Used by
##     Cinder's own Sweep (see _cinder_sweep_
##     modifier()) for its own qualitative "a hero was hit" value;
##     EnemyHeroManager's own _build_npc_ai_context() reports false
##     instead, since the simulation's own targets are always creeps.
##   - target_armor: the player's own current _hero_armor() (already
##     folding in every buff/debuff currently on him, Three Cheers's own
##     armor reduction included) - for Raze's own Three Cheers (see
##     EnemySkillAI's own _raze_three_cheers_modifier()), which
##     values shredding a heavily-armored target more than a lightly-
##     armored one. EnemyHeroManager's own _build_npc_ai_context() reads
##     a creep target's own static armor instead, since the simulation
##     has no per-turn buff/debuff armor system of its own.
##   - guards_active/guard_count/guard_turns_remaining/guard_
##     total_damage_per_turn: The Last Empress's own Imperial Guard, live off
##     _enemy_guards - for EnemySkillAI's own _last_empress_imperial_guard_
##     modifier()/_last_empress_shackles_modifier()/_last_empress_luring_gaze_
##     modifier()/_last_empress_basic_attack_modifier(), all of which read this
##     turn's guard state to score their own Imperial Guard synergy (see
##     each one's own docstring). guard_total_damage_per_turn is the
##     WHOLE squad's own expected hit next turn (_roll_enemy_hero_damage()
##     x _enemy_guard_damage_pct x guard count), not a per-guard
##     figure, so callers never have to re-multiply by guard_count
##     themselves.
##   - empress_will_guardians_damage_bonus_pct/empress_will_extra_guard/
##     empress_will_guard_duration_bonus/empress_will_aoe_damage_pct: The Last Empress's
##     own Empress's Will, read fresh off _get_enemy_empress_will_level_data() -
##     Empress's Will is passive and never itself a scored candidate (see
##     EnemySkillAI's own header comment), so its bonuses only ever reach
##     Imperial Guard/Luring Gaze/a plain Attack through these four
##     fields. All 0/0.0 while the rival hasn't learned it.
##   - hero_move_distance: the rival's own baseline per-turn movement (1 -
##     every enemy always takes exactly one column per turn, see
##     _hero_move_distance()'s own header comment) before Guardian
##     Instinct's own bonus - for Dreadlure's own reach math.
##   - instinct_bonus_movement/instinct_charge_damage_pct: Hunting Instinct's
##     CURRENT level, read fresh off _get_enemy_skill_level_data() - 0/0.0
##     while unlearned. Hunting Instinct is scored as a candidate only on
##     the turn it's actually cast, so other skills (Deathlight Lure's own
##     reach check, a plain Attack's own knockback-wash check) need these
##     independently of whatever Instinct itself is being scored with.
##   - might_attacks_required/might_current_progress/might_bonus_damage_pct/
##     might_knockback: Dreadlure's own Might of the Deep, read fresh off
##     _get_enemy_might_of_the_deep_level_data()/_enemy_might_of_the_deep_
##     attack_count - passive and never itself a scored candidate (see
##     EnemySkillAI's own header comment), so its progression only ever
##     reaches Hunting Instinct/Paralytic Venom/Deathlight Lure/a plain
##     Attack through these fields. All 0/0.0 while unlearned.
##   - venom_radius/venom_damage: Paralytic Venom's CURRENT level, read
##     fresh off _get_enemy_skill_level_data() - for Hunting Instinct's/
##     Deathlight Lure's own combo bonuses, same reasoning as Instinct's own
##     fields above.
##   - target_marked_bonus_pct: whether the player is CURRENTLY Corrosive
##     Lure-marked, and by how much (_player_deathlight_lure_bonus_pct) -
##     for a plain Attack's own synergy bonus.
##   - hero_attack_range: the rival's own basic-attack reach for its type
##     (base_attack_range, already computed below) - for Solara's own
##     Withering Pursuit/Ambush Strike, which both need to compare a real distance
##     against attack range rather than just the boolean "in_attack_
##     range_now" every other hero's own fields already cover.
##   - fallen_grace_radius/hope_of_the_fallen_range/hope_of_the_fallen_base_damage/
##     hope_of_the_fallen_bonus_per_column: Solara's OTHER skills' CURRENT
##     levels, read fresh off _get_enemy_skill_level_data() - each of her
##     skills is only ever scored as a candidate on the turn it's itself
##     being cast, so Withering Pursuit's/Ambush Strike's own combo bonuses need
##     these independently, same reasoning Dreadlure's own "venom_radius"/
##     "venom_damage" fields already established.
##   - ambush_strike_active/ambush_strike_bonus_damage_pct:
##     Solara's own current stealth state - for a plain Attack's own
##     substantial bonus while it's up (see EnemySkillAI's own _solara_
##     basic_attack_modifier()).
##   - target_stunned: whether the player currently has a stun on him
##     (_player_stun_turns_left > 0) - for Hope of the Fallen's own follow-up-
##     Attack synergy (see EnemySkillAI's own _solara_basic_attack_
##     modifier()'s "target_stunned" case).
##   - lunar_ricochet_bounces/lunar_ricochet_bounce_damage_pct/lunar_ricochet_
##     bounce_range: Lunara's own Lunar Ricochet, CURRENT level, read fresh
##     off _get_enemy_lunar_ricochet_level_data() - 0/0.0 while unlearned.
##   - lunar_ricochet_valid_bounce_targets/lunar_ricochet_bounce_target_hps:
##     the ACTUAL bounce targets right now - every one of the player's
##     own guards, plus his own Elderwild Companion, within bounce_range of
##     his own column (the only column a rival Attack could ever bounce
##     from - see _apply_enemy_lunar_ricochet_bounces()'s own docstring for
##     why there's no second real _enemies-style target here) - never the
##     skill's own maximum bounce count.
##   - moonbound_might_bonus_pct: Lunara's own Moonbound Might, CURRENT
##     level - exposed for transparency only; "hero_damage" itself
##     already has it folded in (see _roll_enemy_hero_damage()'s own
##     docstring), so nothing reads this to re-derive the damage number.
##   - eternal_eclipse_candidate_count/eternal_eclipse_candidate_hps/eternal_eclipse_candidate_
##     max_hps: every REAL beam candidate within Lunara's own Eternal Eclipse
##     radius right now - the player (if in range), each of his own
##     guards in range, and his own Elderwild Companion if in range - mirrors
##     _tick_enemy_eternal_eclipse()'s own candidate pool exactly (see
##     EnemySkillAI's own _lunara_eternal_eclipse_modifier()/_lunara_eternal_eclipse_
##     expected_damage() for how this drives the ultimate's own scoring).
func _build_enemy_ai_context(enemy: Dictionary, enemy_type: String, hero_distance: int) -> Dictionary:
	var max_hp: float = _enemy_hero_effective_max_hp(enemy)
	var current_hp: float = float(enemy.get("current_hp", 0.0))

	var pull_of_the_abyss_level_data: Dictionary = _get_enemy_pull_of_the_abyss_level_data()
	var pull_of_the_abyss_ready: bool = not pull_of_the_abyss_level_data.is_empty() \
		and (_enemy_pull_of_the_abyss_attack_count + 1) >= int(pull_of_the_abyss_level_data.get("hits_to_activate", 1))

	var base_attack_range: int = _enemy_attack_range(enemy) if enemy_type == "range" else 0

	# Lunara's Lunar Ricochet: the ACTUAL bounce targets right now - every one
	# of the player's own guards, plus his own Elderwild Companion, within
	# bounce_range of his own column (see _apply_enemy_lunar_ricochet_
	# bounces()'s own docstring for why that's the only column a rival
	# Attack could ever bounce from in a hero fight).
	var lunar_ricochet_level_data: Dictionary = _get_enemy_skill_level_data("lunar_ricochet")
	var lunar_ricochet_bounce_range: int = int(lunar_ricochet_level_data.get("bounce_range", 0))
	var lunar_ricochet_bounce_target_hps: Array = []
	for guard in _guards:
		if _distance(guard["pos_index"], _hero_pos_index) <= lunar_ricochet_bounce_range:
			lunar_ricochet_bounce_target_hps.append(float(guard.get("current_hp", 0.0)))
	if _is_bear_alive() and _distance(_bear["pos_index"], _hero_pos_index) <= lunar_ricochet_bounce_range:
		lunar_ricochet_bounce_target_hps.append(float(_bear.get("current_hp", 0.0)))

	# Lunara's Eternal Eclipse: every REAL beam candidate within radius of the
	# rival's OWN current position right now - the player himself, each
	# of his own guards, and his own Elderwild Companion - mirrors
	# _tick_enemy_eternal_eclipse()'s own candidate pool exactly.
	var eternal_eclipse_level_data: Dictionary = _get_enemy_skill_level_data("eternal_eclipse")
	var eternal_eclipse_radius: int = int(eternal_eclipse_level_data.get("radius", 0))
	var eternal_eclipse_candidate_hps: Array = []
	var eternal_eclipse_candidate_max_hps: Array = []
	if hero_distance <= eternal_eclipse_radius:
		eternal_eclipse_candidate_hps.append(float(_recruited.get("current_hp", 0)))
		eternal_eclipse_candidate_max_hps.append(_hero_max_hp())
	for guard in _guards:
		if _distance(guard["pos_index"], enemy["pos_index"]) <= eternal_eclipse_radius:
			eternal_eclipse_candidate_hps.append(float(guard.get("current_hp", 0.0)))
			eternal_eclipse_candidate_max_hps.append(float(guard.get("max_hp", 0.0)))
	if _is_bear_alive() and _distance(_bear["pos_index"], enemy["pos_index"]) <= eternal_eclipse_radius:
		eternal_eclipse_candidate_hps.append(float(_bear.get("current_hp", 0.0)))
		eternal_eclipse_candidate_max_hps.append(float(_bear.get("hp", _bear.get("current_hp", 0.0))))

	return {
		"game_mode": "battle",
		"archetype": EnemySkillAI.resolve_hero_archetype(_enemy_hero_static),
		"hero_hp": current_hp,
		"hero_max_hp": max_hp,
		"hero_hp_ratio": (current_hp / max_hp) if max_hp > 0.0 else 0.0,
		"hero_mana": _enemy_current_mana,
		"hero_max_mana": _enemy_max_mana,
		"hero_damage": _roll_enemy_hero_damage(enemy),
		"enemy_count": 1,
		"target_hp": float(_recruited.get("current_hp", 0)),
		"target_max_hp": _hero_max_hp(),
		"target_distance": hero_distance,
		"bear_active": not _get_enemy_elderwild_companion().is_empty(),
		"living_target_hps": [float(_recruited.get("current_hp", 0))],
		"living_target_max_hps": [_hero_max_hp()],
		"pull_of_the_abyss_ready": pull_of_the_abyss_ready,
		"pull_of_the_abyss_bonus_damage": float(pull_of_the_abyss_level_data.get("bonus_damage", 0.0)),
		"pull_of_the_abyss_cleave_targets": _count_player_allies_near_hero(int(pull_of_the_abyss_level_data.get("cleave_columns", 1))) if pull_of_the_abyss_ready else 0,
		"kaelen_varr_drowned_surge_combo_ready": _is_enemy_skill_ready("drowned_surge", enemy_type, hero_distance, enemy, true),
		"kaelen_varr_the_sunken_one_combo_ready": _is_enemy_skill_ready("the_sunken_one", enemy_type, hero_distance, enemy, true),
		"in_attack_range_now": hero_distance <= base_attack_range,
		"in_attack_range_with_frostbound_fangs_bonus": hero_distance <= (base_attack_range + _enemy_frostbound_fangs_bonus_range),
		"frostbound_fangs_active": _enemy_frostbound_fangs_active,
		"has_harmful_debuff": _enemy_has_harmful_debuff(enemy),
		"redirect_candidate_count": 0,
		"avg_enemy_damage": 0.0,
		"caster_pos_index": enemy["pos_index"],
		"target_pos_index": _hero_pos_index,
		"grid_columns": GRID_COLUMNS,
		"caster_facing_left": bool(enemy["node"].flip_h),
		"kindled_resolve_stacks": _enemy_kindled_resolve_stack_turns.size(),
		"kindled_resolve_max_stacks": int(_get_enemy_kindled_resolve_level_data().get("max_stacks", 0)),
		"target_is_hero": true,
		"target_armor": _hero_armor(),
		"guards_active": not _enemy_guards.is_empty(),
		"guard_count": _enemy_guards.size(),
		"guard_turns_remaining": _enemy_guards_turns_remaining,
		"guard_total_damage_per_turn": _roll_enemy_hero_damage(enemy) * _enemy_guard_damage_pct * float(_enemy_guards.size()),
		"empress_will_guardians_damage_bonus_pct": float(_get_enemy_empress_will_level_data().get("guardians_damage_bonus_pct", 0.0)),
		"empress_will_extra_guard": int(_get_enemy_empress_will_level_data().get("extra_guard", 0)),
		"empress_will_guard_duration_bonus": int(_get_enemy_empress_will_level_data().get("guard_duration_bonus", 0)),
		"empress_will_aoe_damage_pct": float(_get_enemy_empress_will_level_data().get("aoe_damage_pct", 0.0)),
		"hero_move_distance": 1,
		"instinct_bonus_movement": int(_get_enemy_skill_level_data("hunting_instinct").get("bonus_movement", 0)),
		"instinct_charge_damage_pct": float(_get_enemy_skill_level_data("hunting_instinct").get("charge_damage_pct", 0.0)),
		"might_attacks_required": int(_get_enemy_might_of_the_deep_level_data().get("attacks_required", 0)),
		"might_current_progress": _enemy_might_of_the_deep_attack_count,
		"might_bonus_damage_pct": float(_get_enemy_might_of_the_deep_level_data().get("bonus_damage_pct", 0.0)),
		"might_knockback": int(_get_enemy_might_of_the_deep_level_data().get("knockback", 0)),
		"venom_radius": int(_get_enemy_skill_level_data("paralytic_venom").get("radius", 0)),
		"venom_damage": float(_get_enemy_skill_level_data("paralytic_venom").get("damage", 0.0)),
		"target_marked_bonus_pct": _player_deathlight_lure_bonus_pct,
		"hero_attack_range": base_attack_range,
		"fallen_grace_radius": int(_get_enemy_skill_level_data("fallen_grace").get("radius", 0)),
		"hope_of_the_fallen_range": int(_get_enemy_skill_level_data("hope_of_the_fallen").get("range", 0)),
		"hope_of_the_fallen_base_damage": float(_get_enemy_skill_level_data("hope_of_the_fallen").get("base_damage", 0.0)),
		"hope_of_the_fallen_bonus_per_column": float(_get_enemy_skill_level_data("hope_of_the_fallen").get("bonus_per_column", 0.0)),
		"ambush_strike_active": _enemy_ambush_strike_active,
		"ambush_strike_bonus_damage_pct": _enemy_ambush_strike_bonus_damage_pct,
		"target_stunned": _player_stun_turns_left > 0,
		"lunar_ricochet_bounces": int(lunar_ricochet_level_data.get("bounces", 0)),
		"lunar_ricochet_bounce_damage_pct": float(lunar_ricochet_level_data.get("bounce_damage_pct", 0.0)),
		"lunar_ricochet_bounce_range": lunar_ricochet_bounce_range,
		"lunar_ricochet_valid_bounce_targets": lunar_ricochet_bounce_target_hps.size(),
		"lunar_ricochet_bounce_target_hps": lunar_ricochet_bounce_target_hps,
		"moonbound_might_bonus_pct": float(_get_enemy_moonbound_might_level_data().get("bonus_damage_pct", 0.0)),
		"eternal_eclipse_candidate_count": eternal_eclipse_candidate_hps.size(),
		"eternal_eclipse_candidate_hps": eternal_eclipse_candidate_hps,
		"eternal_eclipse_candidate_max_hps": eternal_eclipse_candidate_max_hps,
	}


## Whether `enemy` (a hero-fight boss) currently has anything the player
## inflicted on it - root, silence, or any of the DoTs a player skill
## can apply directly onto an enemy Dictionary (Thornbind's, Mark of the
## Mist's, Mark of Stillness's, The Hollow Cold's, Return to the
## Void's) - used by The Primordial Hunger's own The Test of Time scoring (see
## EnemySkillAI's own "the_primordial_hunger" modifier), since casting it
## dispels all of them at once.
func _enemy_has_harmful_debuff(enemy: Dictionary) -> bool:
	if enemy.get("root_turns_left", 0) > 0:
		return true
	if enemy.get("silence_turns_left", 0) > 0:
		return true
	if enemy.get("thornbind_dot_turns_left", 0) > 0:
		return true
	if enemy.get("curse_active", false) or enemy.get("curse_stacks", 0) > 0:
		return true
	if enemy.get("mark_of_stillness_dot_turns_left", 0) > 0:
		return true
	if enemy.get("the_hollow_cold_dot_turns_left", 0) > 0:
		return true
	if enemy.get("return_to_the_void_dot_turns_left", 0) > 0:
		return true
	return false


## True if a rival hero of `enemy_type`, `hero_distance` columns from
## the player, can currently reach the player with `skill_id` - see
## EnemySkillRange for which skills need this check and why. `enemy` is
## only ever read by the Double Trouble special-case below (its own
## position/facing, for the directional check) - every other skill's
## check below ignores it entirely, same as EnemySkillRange.is_in_range()
## itself.
func _enemy_skill_in_range(skill_id: String, enemy_type: String, hero_distance: int, enemy: Dictionary) -> bool:
	# Self-cast skills (Frost Tempest, Leeching Hunger, ...) have no
	# targeting range, but are only worth casting when the player is within
	# reach this turn or after the rival's next step.
	if EnemySkillRange.requires_engagement_check(skill_id):
		var engage_data: Dictionary = _get_enemy_skill_level_data(skill_id)
		var engage_attack_range: int = _enemy_attack_range(enemy) if enemy_type == "range" else 0
		return EnemySkillRange.is_engagement_ready(skill_id, hero_distance, int(engage_data.get("radius", 0)), engage_attack_range)
	if not EnemySkillRange.requires_range_check(skill_id):
		return true

	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, skill_id)
	var level_data: Dictionary = GameManager.get_skill_level_data(_find_enemy_skill(skill_id), level)

	if skill_id == "double_trouble":
		# Directional, not a plain "distance <= radius/attack_range"
		# check - mirrors the player's own _cast_double_trouble()'s "ahead"
		# math exactly: only in range if the player is ahead of the
		# rival in whichever direction it's CURRENTLY facing
		# (enemy["node"].flip_h, kept up to date by _move_enemy()), never
		# behind or on the wrong side of a shared column. See
		# EnemySkillRange's own header comment for why this never
		# reaches its generic is_in_range() chain at all.
		var range_columns: int = int(level_data.get("range", 0))
		var direction: int = -1 if bool(enemy["node"].flip_h) else 1
		var ahead: int = (_hero_pos_index - int(enemy["pos_index"])) * direction
		return ahead >= 0 and ahead <= range_columns

	# Drowned Surge's/Undertow's/The Sunken One's/Mark of Stillness's own targeting
	# range lives in a "range" field rather than "radius" (Drowned Surge's
	# separate, level-4-only splash radius); Barbed Lunge's own leap reach
	# lives in a "distance" field instead - see EnemySkillRange's
	# "drowned_surge"/"undertow"/"the_sunken_one"/"barbed_lunge"/"mark_of_stillness" case,
	# which compares distance against whichever of the three this
	# resolves to. The Hollow Cold is the one exception: its own targeting
	# range is the FIXED constant THE_HOLLOW_COLD_RANGE, never part of its
	# level data (which only carries its AoE radius, 1-2) - falling
	# through the same generic chain would silently grab that AoE
	# radius instead, so it's special-cased here first.
	return _enemy_skill_reaches_distance(skill_id, enemy_type, hero_distance)


## The generic half of _enemy_skill_in_range() - whether `skill_id`
## reaches a target `distance` columns away - split out so the same
## check can be asked about the player's Elderwild Companion too (see
## _enemy_skill_target_options()). Double Trouble's directional check
## stays in _enemy_skill_in_range() itself; it's never bear-targetable.
func _enemy_skill_reaches_distance(skill_id: String, enemy_type: String, distance: int) -> bool:
	if not EnemySkillRange.requires_range_check(skill_id):
		return true
	var level_data: Dictionary = _get_enemy_skill_level_data(skill_id)
	var radius: int = THE_HOLLOW_COLD_RANGE if skill_id == "the_hollow_cold" else int(level_data.get("range", level_data.get("radius", level_data.get("distance", 0))))
	var attack_range: int = _enemy_attack_range(_get_hero_fight_boss()) if enemy_type == "range" else 0
	return EnemySkillRange.is_in_range(skill_id, distance, radius, attack_range)


func _cast_enemy_skill(enemy: Dictionary, skill_id: String) -> void:
	# The self-heal candidate (EnemySkillAI.WHISPER_OF_THE_VEIL_SELF_ID) is just
	# Whisper of the Veil aimed at himself - same skill, cooldown and mana.
	var whisper_of_the_veil_self: bool = skill_id == EnemySkillAI.WHISPER_OF_THE_VEIL_SELF_ID
	if whisper_of_the_veil_self:
		skill_id = "whisper_of_the_veil"
	var skill: Dictionary = _find_enemy_skill(skill_id)
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, skill_id)
	var level_data: Dictionary = GameManager.get_skill_level_data(skill, level)
	_enemy_skill_cooldowns[skill_id] = int(level_data.get("cooldown", 0))
	_enemy_current_mana -= float(level_data.get("mana_cost", 0))
	var cast_log: Dictionary = _play_log_state()
	cast_log["skill"] = skill_id
	cast_log["skill_level"] = level
	cast_log["distance"] = _distance(enemy["pos_index"], _hero_pos_index)
	PlayLog.event("rival_cast", cast_log)

	# Aimed at the player's Elderwild Companion instead of the player? Each
	# bear-targetable _cast_enemy_*() below reads this first.
	_enemy_whisper_of_the_veil_self = whisper_of_the_veil_self
	_enemy_skill_on_bear = not whisper_of_the_veil_self and ENEMY_BEAR_TARGETABLE_SKILLS.has(skill_id) and _choose_enemy_skill_on_bear(enemy, skill_id)

	match skill_id:
		"abyssal_spasm":
			_cast_enemy_abyssal_spasm(enemy, level_data)
		"barbed_lunge":
			_cast_enemy_barbed_lunge(enemy, level_data)
		"leeching_hunger":
			_activate_enemy_leeching_hunger(level_data)
		"depthsveil":
			_activate_enemy_depthsveil(level_data)
		"thornbind":
			_cast_enemy_thornbind(level_data)
		"elderwild_companion":
			_summon_enemy_elderwild_companion(level_data)
		"wildbond":
			_activate_enemy_wildbond(level_data)
		"beast_of_the_elderwild":
			_activate_enemy_beast_of_the_elderwild(enemy, level_data)
		"whisper_of_the_veil":
			_cast_enemy_whisper_of_the_veil(enemy, level_data)
		"veil_of_the_forgotten":
			_activate_enemy_veil_of_the_forgotten(enemy, level_data)
		"drowned_surge":
			_cast_enemy_drowned_surge(level_data)
		"undertow":
			_cast_enemy_undertow()
		"the_sunken_one":
			_cast_enemy_the_sunken_one(enemy, level_data)
		"mark_of_stillness":
			_cast_enemy_mark_of_stillness(level_data)
		"the_hollow_cold":
			_cast_enemy_the_hollow_cold(level_data)
		"touch_of_the_first_cold":
			_cast_enemy_touch_of_the_first_cold(enemy, level_data)
		"return_to_the_void":
			_cast_enemy_return_to_the_void(level_data)
		"frostbound_fangs":
			_cast_enemy_frostbound_fangs(level_data)
		"maddening_roar":
			_cast_enemy_maddening_roar(level_data)
		"the_test_of_time":
			_cast_enemy_the_test_of_time(level_data)
		"the_hunger_calls":
			_cast_enemy_the_hunger_calls(level_data)
		"rimecleaver":
			_cast_enemy_rimecleaver(level_data)
		"winters_grip":
			_cast_enemy_winters_grip(level_data)
		"the_frost_tempest":
			_cast_enemy_frost_tempest(level_data)
		"frostbound_rupture":
			_cast_enemy_frostbound_rupture(enemy, level_data)
		"charge":
			_cast_enemy_charge(enemy, level_data)
		"bestial_rage":
			_cast_enemy_bestial_rage(level_data)
		"glacier_breaker":
			_cast_enemy_glacier_breaker(enemy, level_data)
		"rootveil":
			_activate_enemy_rootveil(level_data)
		"sanguine_bloom":
			_cast_enemy_sanguine_bloom(level_data)
		"woven_flesh":
			_activate_enemy_woven_flesh(level_data)
		"mother's_grasp":
			_cast_enemy_mothers_grasp(enemy, level_data)
		"sweep":
			_cast_enemy_sweep(enemy, level_data)
		"chainfire":
			_cast_enemy_chainfire(enemy, level_data)
		"cinderbomb":
			_cast_enemy_cinderbomb(enemy, level_data)
		"double_trouble":
			_cast_enemy_double_trouble(enemy, level_data)
		"blast_hopper":
			_cast_enemy_blast_hopper(enemy, level_data)
		"three_cheers":
			_cast_enemy_three_cheers(enemy, level_data)
		"kiss_the_wastes":
			_cast_enemy_kiss_the_wastes(level_data)
		"imperial_guard":
			_cast_enemy_imperial_guard(enemy, level_data)
		"shackles":
			_cast_enemy_shackles(level_data)
		"luring_gaze":
			_cast_enemy_luring_gaze(enemy, level_data)
		"hunting_instinct":
			_cast_enemy_hunting_instinct(level_data)
		"paralytic_venom":
			_cast_enemy_paralytic_venom(enemy, level_data)
		"deathlight_lure":
			_cast_enemy_deathlight_lure(level_data)
		"fallen_grace":
			_cast_enemy_fallen_grace(enemy, level_data)
		"hope_of_the_fallen":
			_cast_enemy_hope_of_the_fallen(enemy, level_data)
		"withering_pursuit":
			_cast_enemy_withering_pursuit(enemy, level_data)
		"ambush_strike":
			_cast_enemy_ambush_strike(level_data)
		"moonfall_lance":
			_cast_enemy_moonfall_lance(level_data)
		"eternal_eclipse":
			_cast_enemy_eternal_eclipse(level_data)

	# Depthsveil/Rootveil only break from casting ANOTHER skill
	# (or attacking, handled separately in _resolve_enemy_hero_attack()),
	# never from a cast/recast of themselves - mirrors the player's own
	# _on_skill_pressed(). Only one of the two could ever be active at
	# once (different heroes' kits), so this just ends whichever one
	# actually is.
	_enemy_skill_on_bear = false
	_enemy_whisper_of_the_veil_self = false

	if _enemy_depthsveil_active and skill_id != "depthsveil":
		_end_enemy_depthsveil()
	if _enemy_rootveil_active and skill_id != "rootveil":
		_end_enemy_rootveil()
	# Hope of the Fallen is deliberately exempt - mirrors the player's own
	# _on_skill_pressed(), where a TARGETED skill's deferred-spend path
	# (_resolve_hope_of_the_fallen_cast()) never reaches the equivalent check at
	# all, so firing Hope of the Fallen from stealth never breaks it there
	# either (see EnemySkillAI's own _solara_ambush_strike_modifier()'s
	# docstring for why this matters to scoring, not just execution).
	if _enemy_ambush_strike_active and skill_id != "ambush_strike" and skill_id != "hope_of_the_fallen":
		_end_enemy_ambush_strike()

	# After Depthsveil's own break above, so the caster's modulate is
	# already back to opaque before the flash reads/writes it.
	_play_enemy_cast_feedback(enemy, skill)

	_refresh_bars()


# ------------------------------------------------------------------
# Enemy hero skill cast feedback - a scale/brightness pulse on the
# caster, a floating cast-name banner over it, a frost screen tint for
# The Hunger Calls/Winter's Grip/Return to the Void specifically (their own lingering
# "ambient reminder" while still active lives in _refresh_status_
# effects() instead, since that has to persist past this one moment),
# and extra weight (a bigger pulse plus a screen shake) for ultimates.
# All driven from _cast_enemy_skill() so every enemy hero skill gets
# this for free.
# ------------------------------------------------------------------

const FROST_TINT_SKILL_IDS := ["the_hunger_calls", "winters_grip", "return_to_the_void"]
const FROST_TINT_COLOR := Color(0.55, 0.85, 1.0)


func _play_enemy_cast_feedback(enemy: Dictionary, skill: Dictionary) -> void:
	var node: TextureRect = enemy["node"]
	var is_ultimate: bool = skill.get("type", "") == "ultimate"

	_pulse_caster_sprite(node, is_ultimate)
	var animator := CreatureAnimator.of(node)
	if animator != null:
		animator.play_cast()
	_show_message_over_enemy(node, skill.get("name", ""))

	if skill.get("id", "") in FROST_TINT_SKILL_IDS:
		_flash_screen_tint(FROST_TINT_COLOR, 0.32 if is_ultimate else 0.2, 0.5)

	if is_ultimate:
		_shake_screen()


## A quick scale-up + brightness flash on `node`, back to normal -
## reads as "this caster just did something," bigger and brighter for
## an ultimate than a standard cast.
func _pulse_caster_sprite(node: TextureRect, big: bool) -> void:
	var rest: Color = node.get_meta(SPRITE_FLASH_REST_META, node.modulate)
	_sprite_flash(node, 1.28 if big else 1.12, Color(1.6, 1.6, 1.6, rest.a))


const SPRITE_FLASH_REST_META := "sprite_flash_rest_modulate"
const SPRITE_FLASH_TWEEN_META := "sprite_flash_tween"


## The pop both _pulse_caster_sprite() and _flash_bounce_hit() play: a
## quick scale-up to `peak_scale` while the sprite's modulate goes to
## `flash_modulate`, then back to its resting scale/modulate. The resting
## modulate is remembered on the node for as long as a flash is running,
## and a new flash replaces a running one rather than stacking on it -
## otherwise a second flash landing mid-way through the first (an AoE
## hit plus a bounce/splash on the same enemy) would take the half-red
## modulate as "normal" and hand it back at the end, leaving the sprite
## stuck red for good.
func _sprite_flash(node: TextureRect, peak_scale: float, flash_modulate: Color) -> void:
	if not is_instance_valid(node):
		return
	# (has_meta first: get_meta() with a null default still logs an error
	# for a key that isn't there, which it never is for a sprite's first flash.)
	var running: Variant = node.get_meta(SPRITE_FLASH_TWEEN_META) if node.has_meta(SPRITE_FLASH_TWEEN_META) else null
	if running is Tween and running.is_valid():
		running.kill()
	var rest_modulate: Color = node.get_meta(SPRITE_FLASH_REST_META, node.modulate)
	node.set_meta(SPRITE_FLASH_REST_META, rest_modulate)

	node.pivot_offset = node.size / 2.0
	var base_scale: Vector2 = node.get_meta("base_scale", Vector2.ONE)
	var tween := create_tween()
	node.set_meta(SPRITE_FLASH_TWEEN_META, tween)
	tween.tween_property(node, "scale", base_scale * peak_scale, 0.12).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "modulate", flash_modulate, 0.12)
	tween.tween_property(node, "scale", base_scale, 0.18).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "modulate", rest_modulate, 0.18)
	tween.tween_callback(func() -> void:
		if is_instance_valid(node):
			# Whatever the resting modulate is by now - _cancel_targeting()
			# can update it mid-flash.
			node.modulate = node.get_meta(SPRITE_FLASH_REST_META, rest_modulate)
			node.remove_meta(SPRITE_FLASH_REST_META)
			node.remove_meta(SPRITE_FLASH_TWEEN_META)
	)


## Same quick scale-up + flash shape as _pulse_caster_sprite() above, but
## tinted red (BOUNCE_HIT_FLASH_COLOR) instead of brightened white -
## reads as "this sprite just got hit" rather than "this sprite just did
## something." Used by Lunar Ricochet' own bounce (_apply_lunar_ricochet_
## bounces()) so a bounced enemy visibly flashes red instead of only a
## damage number appearing on an enemy that was never the main target.
##
## `flash_color` defaults to that red; Thornbind passes
## THORNBIND_FLASH_COLOR for the same pop in green.
func _flash_bounce_hit(node: TextureRect, flash_color: Color = BOUNCE_HIT_FLASH_COLOR) -> void:
	_sprite_flash(node, 1.12, flash_color)


## Purely cosmetic: Thornbind's cast visual on `node` (an enemy, the
## player's own hero_image when a rival casts it, or the bear) - the
## ground bursts open at its feet in a spray of earth and a few leaves,
## with a green version of the hit flash, as the vines start climbing
## (ThornbindVines, via _refresh_thornbind_vines()). The root itself has
## already been applied by the time this plays.
func _play_thornbind_effect(node: TextureRect) -> void:
	_flash_bounce_hit(node, THORNBIND_FLASH_COLOR)
	_play_ground_dirt(node.position + Vector2(node.size.x / 2.0, node.size.y * ThornbindVines.FEET_Y), node.size.x * ThornbindVines.WRAP_RADIUS * 3.0)

	var lifetime: float = 0.7
	var leaves := CPUParticles2D.new()
	leaves.position = node.position + Vector2(node.size.x / 2.0, node.size.y * ThornbindVines.FEET_Y)
	leaves.emitting = false
	leaves.one_shot = true
	leaves.amount = 10
	leaves.lifetime = lifetime
	leaves.explosiveness = 0.9
	leaves.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	leaves.emission_rect_extents = Vector2(node.size.x * 0.25, 4.0)
	leaves.direction = Vector2(0, -1)
	leaves.spread = 40.0
	leaves.gravity = Vector2(0, 260)
	leaves.initial_velocity_min = 80.0
	leaves.initial_velocity_max = 150.0
	leaves.angle_min = 0.0
	leaves.angle_max = 360.0
	leaves.angular_velocity_min = -240.0
	leaves.angular_velocity_max = 240.0
	leaves.scale_amount_min = 3.0
	leaves.scale_amount_max = 5.0
	leaves.color = Color(0.4, 0.6, 0.2, 1.0)
	leaves.hue_variation_min = -0.08
	leaves.hue_variation_max = 0.04
	add_child(leaves)
	move_child(leaves, enemies_layer.get_index() + 1)
	leaves.emitting = true
	get_tree().create_timer(lifetime + 0.2).timeout.connect(leaves.queue_free)


## Keeps Mother's Grasp's roots in sync with who's currently held by it -
## every enemy carrying its DoT, and the player (a rival's cast) - called
## from _refresh_bars() (i.e. constantly), same approach as
## _refresh_thornbind_vines(). Mother's Grasp's DoT runs exactly as long as
## its root (both armed with the same root_duration) and ticks down
## right as the last rooted turn begins, so the vines sink back into
## the ground just as the unit is about to be free - and a root from
## anything else (Thornbind, Shackles) never grows vines.
func _refresh_mothers_grasp_roots() -> void:
	# The ridge of upheaval runs from the caster's feet - the hero's for
	# his own cast, the rival's for theirs.
	var hero_feet: Vector2 = hero_image.global_position + Vector2(hero_image.size.x * 0.5, hero_image.size.y * 0.95)
	for enemy in _enemies:
		MothersGraspFX.set_on(enemy.get("node"), enemy.get("mothers_grasp_dot_turns_left", 0) > 0, hero_feet, _fx_layer)
	var caster_feet: Vector2 = hero_feet
	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty() and is_instance_valid(boss.get("node")):
		var boss_node: Control = boss["node"]
		caster_feet = boss_node.global_position + Vector2(boss_node.size.x * 0.5, boss_node.size.y * 0.95)
	MothersGraspFX.set_on(hero_image, _player_mothers_grasp_dot_turns_left > 0, caster_feet, _fx_layer)


## Purely cosmetic: the caster (`node`) rears up and slams the ground, and
## the screen shakes as it lands - the blow that sends the roots out (see
## MothersGraspFX, which waits for it).
func _play_mothers_grasp_slam(node: Variant) -> void:
	var animator := CreatureAnimator.of(node)
	if animator != null:
		animator.play_slam()
	get_tree().create_timer(CreatureAnimator.SLAM_IMPACT_TIME if animator != null else 0.0).timeout.connect(func() -> void:
		if is_inside_tree():
			_shake_screen()
	)


## A one-shot spray of dirt clods kicked up across `width` px of ground
## centered on `pos` (Thornbind's burst). Same CPUParticles2D one-shot-burst
## recipe as _spawn_three_cheers_impact().
func _play_ground_dirt(pos: Vector2, width: float) -> void:
	var lifetime: float = 0.6
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 22
	particles.lifetime = lifetime
	particles.explosiveness = 0.9
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(width * 0.4, 3.0)
	particles.direction = Vector2(0, -1)
	particles.spread = 50.0
	particles.gravity = Vector2(0, 600)
	particles.initial_velocity_min = 90.0
	particles.initial_velocity_max = 190.0
	particles.angle_min = 0.0
	particles.angle_max = 360.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = GROUND_DIRT_COLOR
	add_child(particles)
	move_child(particles, enemies_layer.get_index() + 1)
	particles.emitting = true

	get_tree().create_timer(lifetime + 0.2).timeout.connect(particles.queue_free)


## Keeps Thornbind's vines in sync with who's actually thornbound right
## now - called from _refresh_bars() (i.e. constantly), so they just
## follow current state instead of being toggled at every cast/tick/
## dispel/reset site, same approach as _refresh_status_effects().
## "Thornbound" = rooted AND still carrying Thornbind's own DoT, so
## Shackles's/Mother's Grasp's plain roots (which never set the Thornbind DoT)
## don't grow them.
func _refresh_thornbind_vines() -> void:
	for enemy in _enemies:
		var thornbound: bool = enemy.get("root_turns_left", 0) > 0 and enemy.get("thornbind_dot_turns_left", 0) > 0
		_set_thornbind_vines(enemy.get("node"), thornbound)
	_set_thornbind_vines(hero_image, _player_root_turns_left > 0 and _player_thornbind_dot_turns_left > 0)
	if _is_bear_alive():
		_set_thornbind_vines(_bear.get("node"), int(_bear.get("root_turns_left", 0)) > 0 and int(_bear.get("thornbind_dot_turns_left", 0)) > 0)


## Keeps the frost in sync with who's currently frozen by Mark of Stillness's,
## The Hollow Cold's, Return to the Void's OR Winter's Grip's DoT, or held by The Hunger
## Calls's freeze (for as long as its stun lasts), or standing inside the other side's active Freezing
## Field - every enemy (their own mark_of_stillness_dot_turns_left/
## the_hollow_cold_dot_turns_left) and the player's hero (the matching
## _player_* counters, from a rival's cast). Both skills share the one
## frost look, so being marked by both never stacks two. Called from
## _refresh_bars() (i.e. constantly), same approach as
## _refresh_thornbind_vines(), so the frost just follows current state
## instead of being toggled at every cast/tick/dispel site.
func _refresh_mark_of_stillness_frost() -> void:
	# The Frost Tempest's zones: every unit standing inside an active field
	# is frosted, from its first damaging tick on (the casting turn
	# itself doesn't hit anything yet - see _tick_frost_tempest()), so
	# the frost follows whoever the field is actually hitting - on when
	# they're inside it, off once they walk out or it ends. -1 = no
	# field of that side's right now.
	var player_field_center: int = _hero_pos_index if (_frost_tempest_active and not _frost_tempest_duration_pending_start) else -1
	var rival_field_center: int = -1
	if _enemy_frost_tempest_active and not _enemy_frost_tempest_duration_pending_start:
		var field_boss: Dictionary = _get_hero_fight_boss()
		if not field_boss.is_empty():
			rival_field_center = field_boss["pos_index"]

	for enemy in _enemies:
		var frozen: bool = enemy.get("mark_of_stillness_dot_turns_left", 0) > 0 or enemy.get("the_hollow_cold_dot_turns_left", 0) > 0 \
			or enemy.get("return_to_the_void_dot_turns_left", 0) > 0 or enemy.get("winters_grip_dot_turns_left", 0) > 0 \
			or (is_same(enemy, _hunger_calls_target) and _is_the_hunger_calls_active()) \
			or (_enemy_the_test_of_time_active and enemy["static"].get("is_hero_fight_boss", false)) \
			or (player_field_center >= 0 and not _is_target_hidden(enemy) and _distance(enemy["pos_index"], player_field_center) <= _frost_tempest_radius)
		_set_mark_of_stillness_frost(enemy.get("node"), frozen)
	_set_mark_of_stillness_frost(hero_image, _player_mark_of_stillness_dot_turns_left > 0 or _player_the_hollow_cold_dot_turns_left > 0 \
		or _player_return_to_the_void_dot_turns_left > 0 or _player_winters_grip_dot_turns_left > 0 or _player_the_hunger_calls_active \
		or _the_test_of_time_active \
		or (rival_field_center >= 0 and _distance(_hero_pos_index, rival_field_center) <= _enemy_frost_tempest_radius))
	# Guards (either side) can only ever carry The Hollow Cold's DoT,
	# never Mark of Stillness's - a single-target cast never lands on one - or
	# stand inside the opposing side's The Frost Tempest. The player's own
	# Elderwild Companion can carry either DoT (a rival can aim Mark of Stillness at it -
	# see _cast_enemy_mark_of_stillness_on_bear()).
	for guard in _guards:
		var guard_frozen: bool = guard.get("the_hollow_cold_dot_turns_left", 0) > 0 \
			or (rival_field_center >= 0 and _distance(guard["pos_index"], rival_field_center) <= _enemy_frost_tempest_radius)
		_set_mark_of_stillness_frost(guard.get("node"), guard_frozen)
	for guard in _enemy_guards:
		var enemy_guard_frozen: bool = guard.get("the_hollow_cold_dot_turns_left", 0) > 0 \
			or (player_field_center >= 0 and _distance(guard["pos_index"], player_field_center) <= _frost_tempest_radius)
		_set_mark_of_stillness_frost(guard.get("node"), enemy_guard_frozen)
	if _is_bear_alive():
		var bear_frozen: bool = int(_bear.get("mark_of_stillness_dot_turns_left", 0)) > 0 or int(_bear.get("the_hollow_cold_dot_turns_left", 0)) > 0 \
			or int(_bear.get("return_to_the_void_dot_turns_left", 0)) > 0 or int(_bear.get("winters_grip_dot_turns_left", 0)) > 0 \
			or (bool(_bear.get("the_hunger_calls_active", false)) and int(_bear.get("stun_turns_left", 0)) > 0) \
			or (rival_field_center >= 0 and _distance(_bear["pos_index"], rival_field_center) <= _enemy_frost_tempest_radius)
		_set_mark_of_stillness_frost(_bear.get("node"), bear_frozen)


## Purely cosmetic: The Hollow Cold's cast - a ring of ice crystals swirling
## outward from `center_node`, sized to reach about `radius` columns (at
## least half a column, so a radius-0 cast still reads), spinning as
## they go. The lingering frost on everyone caught is
## _refresh_mark_of_stillness_frost()'s. Same CPUParticles2D one-shot-burst
## recipe as _spawn_three_cheers_impact(), with tangential acceleration
## for the swirl.
func _play_the_hollow_cold_swirl(center_node: Variant, radius: int) -> void:
	if not is_instance_valid(center_node) or not (center_node is Control):
		return

	var lifetime: float = 0.9
	var reach: float = _grid_unit() * maxf(0.5, float(radius))
	var particles := CPUParticles2D.new()
	particles.position = center_node.position + center_node.size / 2.0
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 60
	particles.lifetime = lifetime
	particles.explosiveness = 0.8
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = reach / lifetime * 0.5
	particles.initial_velocity_max = reach / lifetime * 0.9
	particles.tangential_accel_min = 180.0
	particles.tangential_accel_max = 260.0
	particles.damping_min = 20.0
	particles.damping_max = 40.0
	particles.angle_min = 0.0
	particles.angle_max = 360.0
	particles.angular_velocity_min = -270.0
	particles.angular_velocity_max = 270.0
	particles.scale_amount_min = 2.5
	particles.scale_amount_max = 5.5
	particles.color = MARK_OF_STILLNESS_FLAKE_COLOR
	particles.hue_variation_min = -0.04
	particles.hue_variation_max = 0.04
	add_child(particles)
	# Same reasoning as _play_double_trouble_effect()'s own move_child()
	# call - render at the hero/enemy layer, not on top of every UI panel.
	move_child(particles, enemies_layer.get_index() + 1)
	particles.emitting = true

	get_tree().create_timer(lifetime + 0.2).timeout.connect(particles.queue_free)


## Purely cosmetic: tears The Hollow Cold's wound open in the air where
## `center_node` (the unit it was cast on) stands - a ragged rift onto a
## swirling nebula, drawn behind every unit so whoever stands there is
## silhouetted against it - and keeps it open for `duration` turns (see
## _tick_hollow_cold_tears()). Frost motes are drawn into it from about
## `radius` columns around, the warmth being pulled out of everything
## caught within. `hits_player_side` says whose turn it counts down on:
## true for a rival's cast (it hurts the player's side), false for the
## player's. A new tear on the same side and column replaces the old one
## (a recast overwrites the DoT it stood for anyway).
func _open_hollow_cold_tear(center_node: Variant, pos_index: int, radius: int, duration: int, hits_player_side: bool) -> void:
	if not is_instance_valid(center_node) or not (center_node is Control) or duration <= 0:
		return
	for existing in _hollow_cold_tears.duplicate():
		if existing["hits_player_side"] == hits_player_side and existing["pos_index"] == pos_index:
			_close_hollow_cold_tear(existing)

	var unit_size: Vector2 = center_node.size
	var center: Vector2 = center_node.position + unit_size / 2.0 - Vector2(0.0, unit_size.y * HOLLOW_COLD_TEAR_LIFT)
	var tear_size := Vector2(unit_size.x * HOLLOW_COLD_TEAR_SIZE.x, unit_size.y * HOLLOW_COLD_TEAR_SIZE.y)

	var material := ShaderMaterial.new()
	material.shader = HOLLOW_COLD_TEAR_SHADER
	material.set_shader_parameter("aspect", tear_size.x / tear_size.y)
	material.set_shader_parameter("seed", randf() * 10.0)
	material.set_shader_parameter("rip", 0.0)
	material.set_shader_parameter("gape", 0.0)
	var tear := ColorRect.new()
	tear.material = material
	tear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tear.size = tear_size
	tear.position = center - tear_size / 2.0
	add_child(tear)
	# Behind the hero and every enemy, over the battle background.
	move_child(tear, hero_image.get_index())

	# Frost motes pulled in from the skill's reach, drawn over the units.
	var reach: float = maxf(_grid_unit() * maxf(0.5, float(radius)), tear_size.y * 0.5)
	var lifetime: float = 1.3
	var motes := CPUParticles2D.new()
	motes.position = center
	motes.amount = 36
	motes.lifetime = lifetime
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	motes.emission_sphere_radius = reach
	motes.gravity = Vector2.ZERO
	motes.initial_velocity_min = 0.0
	motes.initial_velocity_max = 0.0
	# Accelerating inward so they arrive at the tear by the end of
	# their life, curving round a little on the way.
	motes.radial_accel_min = -2.2 * reach / (lifetime * lifetime)
	motes.radial_accel_max = -1.6 * reach / (lifetime * lifetime)
	motes.tangential_accel_min = 20.0
	motes.tangential_accel_max = 60.0
	motes.scale_amount_min = 1.5
	motes.scale_amount_max = 3.5
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 0.85, 1.0])
	ramp.colors = PackedColorArray([Color(MARK_OF_STILLNESS_FLAKE_COLOR, 0.0), MARK_OF_STILLNESS_FLAKE_COLOR,
			Color(0.7, 0.8, 1.0, 0.9), Color(0.6, 0.7, 1.0, 0.0)])
	motes.color_ramp = ramp
	add_child(motes)
	move_child(motes, enemies_layer.get_index() + 1)
	motes.emitting = true

	# Rips open top to bottom, then gapes wide with a little overshoot.
	var open: Tween = tear.create_tween()
	open.tween_property(material, "shader_parameter/rip", 1.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	open.tween_property(material, "shader_parameter/gape", 1.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_hollow_cold_tears.append({
		"tear": tear,
		"motes": motes,
		"pos_index": pos_index,
		"turns_left": duration,
		"hits_player_side": hits_player_side,
	})


## Counts down every open The Hollow Cold tear on the given side by one
## turn, sealing any that run out. Called right where that side's The
## Hollow Cold DoT ticks: _enemy_turn() (hits_player_side = false, the
## player's casts) and _tick_player_turn_start_effects() (true, the
## rival's).
func _tick_hollow_cold_tears(hits_player_side: bool) -> void:
	for entry in _hollow_cold_tears.duplicate():
		if entry["hits_player_side"] != hits_player_side:
			continue
		entry["turns_left"] -= 1
		if entry["turns_left"] <= 0:
			_close_hollow_cold_tear(entry)


## Seals a tear shut - it narrows to a line, then the line fades from
## the ends in - and frees it, letting its last motes finish drifting in.
func _close_hollow_cold_tear(entry: Dictionary) -> void:
	_hollow_cold_tears.erase(entry)
	var motes: Variant = entry.get("motes")
	if is_instance_valid(motes):
		motes.emitting = false
		get_tree().create_timer(motes.lifetime + 0.1).timeout.connect(motes.queue_free)
	var tear: Variant = entry.get("tear")
	if not is_instance_valid(tear):
		return
	var material: ShaderMaterial = tear.material
	var seal: Tween = tear.create_tween()
	seal.tween_property(material, "shader_parameter/gape", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	seal.tween_property(material, "shader_parameter/rip", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	seal.tween_callback(tear.queue_free)


## Seals every open tear at once - a new stage or hero fight starts from
## a clean field.
func _close_all_hollow_cold_tears() -> void:
	for entry in _hollow_cold_tears.duplicate():
		_close_hollow_cold_tear(entry)


## Purely cosmetic: frosts `node` (any unit's sprite) for `seconds`
## regardless of any DoT - the icy flash plus the same frost Mark of Stillness/
## The Hollow Cold/Return to the Void/Winter's Grip leave, which then fades on its own.
## Used by Rimecleaver, a single burst with nothing lingering to tie
## the frost to. If a DoT-driven frost is also on the unit, whichever
## lasts longer wins - the timed hold only ever keeps frost on, never
## takes it off early.
func _flash_frost_briefly(node: Variant, seconds: float, flash_color: Color = MARK_OF_STILLNESS_FLASH_COLOR) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	node.set_meta("frost_hold_until_msec", Time.get_ticks_msec() + int(seconds * 1000.0))
	_flash_bounce_hit(node, flash_color)
	_set_mark_of_stillness_frost(node, true)
	# Re-evaluated once the hold runs out: stays frosted if a DoT is
	# still holding it, otherwise fades. A tween bound to this node (not
	# a SceneTree timer) so it dies with the battle scene if it closes
	# first.
	create_tween().tween_callback(_refresh_mark_of_stillness_frost).set_delay(seconds + 0.05)


## Purely cosmetic: puts Mark of Stillness's frost on `node` - an enemy's node
## or the player's hero_image - (or takes it off):
## an additive icy-blue copy of the sprite for a frosty sheen that
## slowly shimmers, plus a few snowflakes drifting off it. Both live
## under one child Control, so they follow the sprite's position/
## scale/fades for free and fade in/out together. The shimmer's
## per-frame update also keeps the sheen's flip_h/texture in sync with
## the sprite, the same way The Mist Remembers's glow does. Only does
## anything when the state actually changes (the child's presence is
## the "currently on" marker).
func _set_mark_of_stillness_frost(node: Variant, active: bool) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	# A timed hold (Rimecleaver - see _flash_frost_briefly()) keeps the
	# frost up even when no DoT is holding it anymore, until it expires.
	if not active and Time.get_ticks_msec() < int(node.get_meta("frost_hold_until_msec", 0)):
		active = true
	var frost: Control = node.get_node_or_null(MARK_OF_STILLNESS_FROST_NAME)
	if active == (frost != null):
		return

	if not active:
		# Renamed right away so a quick re-mark during the fade creates a
		# fresh frost instead of finding this dying one.
		frost.name = MARK_OF_STILLNESS_FROST_NAME + "Fading"
		var shimmer: Variant = frost.get_meta("shimmer_tween", null)
		if shimmer is Tween and shimmer.is_valid():
			shimmer.kill()
		var flakes: CPUParticles2D = frost.get_meta("flakes", null)
		if is_instance_valid(flakes):
			flakes.emitting = false
		var fade: Tween = frost.create_tween()
		fade.tween_property(frost, "modulate:a", 0.0, 0.5)
		fade.tween_callback(frost.queue_free)
		return

	frost = Control.new()
	frost.name = MARK_OF_STILLNESS_FROST_NAME
	frost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frost.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frost.modulate.a = 0.0
	node.add_child(frost)

	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var sheen := TextureRect.new()
	sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheen.material = material
	sheen.texture = node.texture
	sheen.expand_mode = node.expand_mode
	sheen.stretch_mode = node.stretch_mode
	sheen.flip_h = node.flip_h
	sheen.flip_v = node.flip_v
	sheen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheen.self_modulate = MARK_OF_STILLNESS_SHEEN_COLOR
	frost.add_child(sheen)

	var flakes := CPUParticles2D.new()
	flakes.position = node.size / 2.0
	flakes.amount = 14
	flakes.lifetime = 1.4
	flakes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	flakes.emission_rect_extents = node.size * 0.35
	flakes.direction = Vector2(0, -1)
	flakes.spread = 60.0
	flakes.gravity = Vector2(0, 25)
	flakes.initial_velocity_min = 8.0
	flakes.initial_velocity_max = 22.0
	flakes.angle_min = 0.0
	flakes.angle_max = 360.0
	flakes.angular_velocity_min = -90.0
	flakes.angular_velocity_max = 90.0
	flakes.scale_amount_min = 2.0
	flakes.scale_amount_max = 4.0
	flakes.color = MARK_OF_STILLNESS_FLAKE_COLOR
	frost.add_child(flakes)
	flakes.emitting = true
	frost.set_meta("flakes", flakes)

	var fade_in: Tween = frost.create_tween()
	fade_in.tween_property(frost, "modulate:a", 1.0, 0.35)

	# 0 -> 1 is one full shimmer: dimmer -> brighter -> dimmer.
	var shimmer: Tween = frost.create_tween().set_loops()
	shimmer.tween_method(
		func(phase: float) -> void:
			if not is_instance_valid(node):
				return
			sheen.flip_h = node.flip_h
			sheen.texture = node.texture
			sheen.modulate.a = lerpf(0.35, 0.6, 0.5 - 0.5 * cos(phase * TAU)),
		0.0, 1.0, 1.8
	)
	frost.set_meta("shimmer_tween", shimmer)


## Grows Thornbind's vines around `node`, or unwinds them - both no-ops
## when that's already the state, so the constant _refresh_bars() calls
## don't keep restarting them.
## Keeps Winter's Grip's ice hands (WintersGripHands) on everyone it's
## currently holding - every enemy, the player's hero (a rival's cast)
## and his Elderwild Companion - for exactly as long as the stun it
## applied lasts. Called from _refresh_bars() (i.e. constantly), like
## _refresh_thornbind_vines(). The stun counter is shared with every
## other stun, so the "held by Winter's Grip" flag is dropped the moment
## it runs out - a later stun from anything else doesn't bring the
## hands back.
func _refresh_winters_grip_hands() -> void:
	for enemy in _enemies:
		if int(enemy.get("stun_turns_left", 0)) <= 0:
			enemy["winters_grip_hold"] = false
		_set_winters_grip_hands(enemy.get("node"), enemy.get("winters_grip_hold", false))
	if _player_stun_turns_left <= 0:
		_player_winters_grip_hold = false
	_set_winters_grip_hands(hero_image, _player_winters_grip_hold)
	if _is_bear_alive():
		if int(_bear.get("stun_turns_left", 0)) <= 0:
			_bear["winters_grip_hold"] = false
		_set_winters_grip_hands(_bear.get("node"), _bear.get("winters_grip_hold", false))


## Keeps The Frost Tempest's storm, levitation and glowing eyes
## (FrostTempestFX) on whoever has it active - the player's hero or a
## rival Frost Daughter - from the cast until it ends, sized to that
## cast's radius. Called from _refresh_bars() (i.e. constantly), like
## _refresh_winters_grip_hands().
func _refresh_frost_tempest_fx() -> void:
	_set_frost_tempest_fx(hero_image, _frost_tempest_active, _frost_tempest_radius)
	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty():
		_set_frost_tempest_fx(boss.get("node"), _enemy_frost_tempest_active, _enemy_frost_tempest_radius)


func _set_frost_tempest_fx(node: Variant, active: bool, radius: int) -> void:
	if not is_instance_valid(node) or not (node is TextureRect):
		return
	if active:
		FrostTempestFX.attach(node, _grid_unit() * (float(radius) + 0.5))
	else:
		FrostTempestFX.release(node)


func _set_winters_grip_hands(node: Variant, held: bool) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	if held:
		WintersGripHands.attach(node)
	else:
		WintersGripHands.release(node)


func _set_thornbind_vines(node: Variant, thornbound: bool) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	if thornbound:
		ThornbindVines.attach(node)
	else:
		ThornbindVines.release(node)


## Same floating/fading style as _show_message_over_hero(), just over
## `target_node` instead of always the player's own hero - so a rival's
## cast reads as something THEY did, not something that just happened
## to the player.
func _show_message_over_enemy(target_node: Control, text: String) -> void:
	if text == "":
		return

	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 18)
	label.position = target_node.position + Vector2(target_node.size.x / 2.0 - 60, -10)
	enemies_layer.add_child(label)

	var tween := create_tween()
	tween.tween_interval(MESSAGE_READ_HOLD_DURATION)
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.finished.connect(label.queue_free)


## A brief full-screen color flash (fade in, fade out) on
## cast_flash_overlay - separate from ambient_tint_overlay's own
## persistent tint (see _refresh_status_effects()) so the two never
## fight over the same tween.
func _flash_screen_tint(color: Color, peak_alpha: float, duration: float) -> void:
	cast_flash_overlay.color = Color(color.r, color.g, color.b, 0.0)

	var tween := create_tween()
	tween.tween_property(cast_flash_overlay, "color:a", peak_alpha, duration * 0.3)
	tween.tween_property(cast_flash_overlay, "color:a", 0.0, duration * 0.7)


## A short, small random-jitter shake of the whole battle view - the
## "impact weight" cue for an enemy hero's ultimate.
func _shake_screen() -> void:
	var base_position: Vector2 = position
	var tween := create_tween()
	for i in range(5):
		var offset := Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
		tween.tween_property(self, "position", base_position + offset, 0.03)
	tween.tween_property(self, "position", base_position, 0.03)


## Abyssal Spasm only ever has one possible target here (there's no other
## enemy for the rival to hit besides the player), unlike the player's
## own _cast_abyssal_spasm() which has to scan multiple enemies - so this
## just hits. The radius check against the player's distance already
## happened before this skill was even picked (see
## _enemy_skill_in_range()/EnemySkillRange), so by the time this runs
## the player is guaranteed to be in range.
func _cast_enemy_abyssal_spasm(enemy: Dictionary, level_data: Dictionary) -> void:
	var multiplier: float = float(level_data.get("damage_multiplier", 0.75))
	var pact_damage: float = _roll_enemy_hero_damage(enemy) * multiplier
	apply_damage(pact_damage)
	# Same red hit-flash the player's own Abyssal Spasm gives every enemy it
	# catches (see _cast_abyssal_spasm()).
	_flash_bounce_hit(hero_image)
	# Abyssal Spasm is centered on the CASTER's own column, not the
	# player's - a guard standing near the rival (not necessarily
	# near the hero) can still be caught in it.
	_deal_aoe_damage_to_guards(enemy["pos_index"], int(level_data.get("radius", 0)), pact_damage, true)
	_deal_aoe_damage_to_bear(enemy["pos_index"], int(level_data.get("radius", 0)), pact_damage, true)


func _cast_enemy_barbed_lunge(enemy: Dictionary, level_data: Dictionary) -> void:
	var direction: int = _step_toward(enemy["pos_index"], _hero_pos_index)
	if direction == 0:
		direction = 1

	var move_distance: int = int(level_data.get("distance", 2))
	var pos: int = enemy["pos_index"]
	var hit_hero: bool = false

	for i in range(move_distance):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		# The player's own Frostbound Rupture wall stops the leap dead, same
		# "can't jump past a wall in its path" rule the player's own
		# Barbed Lunge follows now (see _cast_barbed_lunge()).
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos
		if pos == _hero_pos_index:
			hit_hero = true
			break

	_move_enemy(enemy, pos)

	if hit_hero:
		apply_damage(_roll_enemy_hero_damage(enemy))
		_player_stun_turns_left = int(level_data.get("stun_turns", 1))
		_show_message_over_hero("Stunned!")


# ------------------------------------------------------------------
# Veyrik's Leeching Hunger, cast by the rival - mirrors the player's own
# _activate_leeching_hunger()/_tick_leeching_hunger()/_end_leeching_hunger():
# its next hits on the player heal the rival for a share of the damage.
# ------------------------------------------------------------------

func _activate_enemy_leeching_hunger(level_data: Dictionary) -> void:
	if _enemy_leeching_hunger_active:
		_end_enemy_leeching_hunger()
	_enemy_leeching_hunger_active = true
	_enemy_leeching_hunger_attacks_remaining = int(level_data.get("attacks", 0))
	_enemy_leeching_hunger_lifesteal_pct = float(level_data.get("lifesteal_pct", 0.0))
	_enemy_leeching_hunger_turns_remaining = int(level_data.get("duration", 0))
	_enemy_leeching_hunger_duration_pending_start = true


## Called right after the rival's plain Attack lands on the player, with the
## damage it dealt: heals the rival for the skill's share of it and spends
## one of the banked hits.
func _apply_enemy_leeching_hunger_steal(enemy: Dictionary, mitigated_damage: float) -> void:
	if not _enemy_leeching_hunger_active or _enemy_leeching_hunger_attacks_remaining <= 0:
		return
	if mitigated_damage <= 0.0:
		return

	_enemy_leeching_hunger_attacks_remaining -= 1
	var max_hp: float = _enemy_hero_effective_max_hp(enemy)
	enemy["current_hp"] = minf(max_hp, enemy["current_hp"] + mitigated_damage * _enemy_leeching_hunger_lifesteal_pct)
	_play_drain_effect(hero_image, enemy.get("node"), LEECHING_HUNGER_MOTE_COLOR)
	if _enemy_leeching_hunger_attacks_remaining <= 0:
		_end_enemy_leeching_hunger()


func _tick_enemy_leeching_hunger() -> void:
	if not _enemy_leeching_hunger_active:
		return
	if _enemy_leeching_hunger_duration_pending_start:
		_enemy_leeching_hunger_duration_pending_start = false
		return
	_enemy_leeching_hunger_turns_remaining -= 1
	if _enemy_leeching_hunger_turns_remaining <= 0:
		_end_enemy_leeching_hunger()


func _end_enemy_leeching_hunger() -> void:
	_enemy_leeching_hunger_active = false
	_enemy_leeching_hunger_attacks_remaining = 0
	_enemy_leeching_hunger_lifesteal_pct = 0.0
	_enemy_leeching_hunger_turns_remaining = 0
	_enemy_leeching_hunger_duration_pending_start = false


# ------------------------------------------------------------------
# Veyrik's Depthsveil, cast by the rival on themselves - mirrors the
# player's own _activate_depthsveil()/_tick_depthsveil()/
# _end_depthsveil(). "Hidden" here means the player's attacks and
# targeted skills can't select them at all (_is_target_hidden(),
# checked from _get_enemy_at()/_start_ranged_targeting()/
# _start_thornbind_targeting()/_cast_abyssal_spasm()) - their own turn
# proceeds completely normally while hidden.
# ------------------------------------------------------------------

func _activate_enemy_depthsveil(level_data: Dictionary) -> void:
	_enemy_depthsveil_active = true
	_enemy_depthsveil_bonus_damage = float(level_data.get("bonus_damage_pct", 0.0)) * _enemy_hero_max_damage()
	_enemy_depthsveil_turns_remaining = int(level_data.get("duration", 0))
	_enemy_depthsveil_duration_pending_start = true
	_update_enemy_hero_visibility()


func _tick_enemy_depthsveil() -> void:
	if not _enemy_depthsveil_active:
		return
	if _enemy_depthsveil_duration_pending_start:
		_enemy_depthsveil_duration_pending_start = false
		return
	_enemy_depthsveil_turns_remaining -= 1
	if _enemy_depthsveil_turns_remaining <= 0:
		_end_enemy_depthsveil()


func _end_enemy_depthsveil() -> void:
	_enemy_depthsveil_active = false
	_enemy_depthsveil_bonus_damage = 0.0
	_enemy_depthsveil_turns_remaining = 0
	_enemy_depthsveil_duration_pending_start = false
	_update_enemy_hero_visibility()


## Whether the rival hero is currently invisible (any of its veils).
func _is_enemy_hero_invisible() -> bool:
	return _enemy_depthsveil_active or _enemy_rootveil_active or _enemy_ambush_strike_active


## An invisible rival hero genuinely vanishes: its sprite, HP and status
## labels are hidden, so the player can't see - or play around - where it
## is (the player's OWN invisibility, by contrast, only fades his portrait
## so he can still find himself on the board).
func _update_enemy_hero_visibility() -> void:
	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty() or not is_instance_valid(boss["node"]):
		return
	# Deathlight Lure is true sight: a hero it marks can't stay invisible -
	# the veil breaks the moment it would take hold (or the mark lands).
	if _is_enemy_hero_invisible() and float(boss.get("deathlight_lure_bonus_pct", 0.0)) > 0.0:
		_reveal_enemy_hero()
		return
	var hidden: bool = _is_enemy_hero_invisible()
	boss["node"].visible = not hidden
	boss["node"].modulate = Color(1, 1, 1, 1)
	var hp_label: Control = boss.get("hp_label")
	if is_instance_valid(hp_label):
		hp_label.visible = not hidden
	var status_label: Control = boss.get("status_label")
	if hidden and is_instance_valid(status_label):
		status_label.visible = false
	_refresh_enemy_overhead_labels()


## Breaks every veil on the rival hero - what a "see invisible" skill or item
## calls when it catches it: the hero is revealed on the spot.
func _reveal_enemy_hero() -> void:
	if not _is_enemy_hero_invisible():
		return
	_end_enemy_depthsveil()
	_end_enemy_rootveil()
	_end_enemy_ambush_strike()


# ------------------------------------------------------------------
# Erynd's Thornbind, cast by the rival on the player - mirrors
# _apply_root(), just aimed at the player instead of an enemy. There's
# only one possible target (the player),
# so no targeting step is needed the way the player's own Thornbind
# needs _start_thornbind_targeting()/_resolve_thornbind_cast().
# ------------------------------------------------------------------

func _cast_enemy_thornbind(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_thornbind_on_bear(level_data)
		return
	_player_root_turns_left = int(level_data.get("root_turns", 0))
	_player_silence_turns_left = int(level_data.get("silence_turns", 0))
	_player_thornbind_dot_damage = float(level_data.get("dot_damage", 0))
	_player_thornbind_dot_turns_left = int(level_data.get("dot_duration", 0))
	_show_message_over_hero("Thornbound!")
	_play_thornbind_effect(hero_image)
	_refresh_thornbind_vines()



# ------------------------------------------------------------------
# Erynd's Elderwild Companion, cast by the rival - spawned as a
# genuine extra entry in _enemies via the normal _spawn_enemy() path,
# so it automatically gets real movement/attack behavior, a real
# position on the board, and can be fought and killed by the player
# like anything else, all for free. XP/gold are zeroed out so killing
# it doesn't reward anything beyond clearing it out of the way - only
# the rival hero itself is worth a bounty.
#
# Simplification versus the player's own Elderwild Companion: defeating the
# boss requires _enemies to be empty (see _handle_victory()), so as
# long as this bear is alive the fight isn't over even after the
# rival hero itself has been reduced to 0 HP and removed - the same
# way any other enemy sharing the field would keep a fight going.
# ------------------------------------------------------------------

func _summon_enemy_elderwild_companion(level_data: Dictionary) -> void:
	_despawn_enemy_elderwild_companion()

	# Its health and damage are a share of the rival's own.
	var rival_static: Dictionary = _get_hero_fight_boss().get("static", {})

	_spawn_enemy({
		"id": "enemy_elderwild_companion",
		"name": "Elderwild Companion",
		"image": ELDERWILD_COMPANION_IMAGE_PATH,
		"type": "melee",
		"hp": maxf(1.0, float(level_data.get("hp_pct", 0.0)) * float(rival_static.get("hp", 0)) * ENEMY_BEAR_STAT_MULT),
		"damage": roundi(float(level_data.get("damage_pct", 0.0)) * float(rival_static.get("damage", 0)) * ENEMY_BEAR_STAT_MULT),
		"armor": float(level_data.get("armor", 0)),
		"XP": 0,
		"gold": "0-0",
		# Same art the player's own Elderwild Companion uses is drawn facing
		# right (toward wherever it's an ally of); placed on the enemy
		# side here, it needs the same left-facing flip hero portraits
		# get - see _spawn_enemy()'s use of this flag.
		"is_hero_fight": true,
		"is_enemy_elderwild_companion": true,
		"lifesteal_pct": float(level_data.get("bear_lifesteal_pct", 0.0)),
	})
	AudioManager.play_event("bear_summon")


## What a landed hit of the rival's companion gives back: Wildbond heals the
## rival for its share of the damage, and a top-level companion heals itself.
func _apply_enemy_companion_hit_effects(companion: Dictionary, dealt: float) -> void:
	if dealt <= 0.0 or not companion["static"].get("is_enemy_elderwild_companion", false):
		return
	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty() and _enemy_wildbond_active:
		var max_hp: float = _enemy_hero_effective_max_hp(boss)
		boss["current_hp"] = minf(max_hp, float(boss["current_hp"]) + dealt * _enemy_wildbond_lifesteal_pct)
		_play_lifesteal_effect(hero_image, boss.get("node"))
	# Same as the player's own: Wildbond's share also heals the companion, the
	# larger of that and its own top-level share (not stacked).
	var self_lifesteal: float = float(companion["static"].get("lifesteal_pct", 0.0))
	if not boss.is_empty() and _enemy_wildbond_active:
		self_lifesteal = maxf(self_lifesteal, _enemy_wildbond_lifesteal_pct)
	if self_lifesteal > 0.0:
		companion["current_hp"] = minf(float(companion["static"].get("hp", 1)), float(companion["current_hp"]) + dealt * self_lifesteal)
		_play_lifesteal_effect(hero_image, companion.get("node"))


func _despawn_enemy_elderwild_companion() -> void:
	for existing in _enemies.duplicate():
		if existing["static"].get("is_enemy_elderwild_companion", false):
			if is_instance_valid(existing["node"]):
				existing["node"].queue_free()
			if is_instance_valid(existing.get("hp_label")):
				existing["hp_label"].queue_free()
			if is_instance_valid(existing.get("status_label")):
				existing["status_label"].queue_free()
			_enemies.erase(existing)
	_refresh_enemy_overhead_labels()


# ------------------------------------------------------------------
# Erynd's Wildbond, cast by the rival on themselves - mirrors
# _activate_wildbond()/_tick_wildbond()/_end_wildbond()/
# _apply_wildbond_lifesteal().
# ------------------------------------------------------------------

func _activate_enemy_wildbond(level_data: Dictionary) -> void:
	_enemy_wildbond_active = true
	_enemy_wildbond_lifesteal_pct = float(level_data.get("lifesteal_pct", 0.0))
	_enemy_wildbond_bonus_armor = float(level_data.get("bonus_armor", 0))
	_enemy_wildbond_turns_remaining = int(level_data.get("duration", 0))
	_enemy_wildbond_duration_pending_start = true
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), true)


func _tick_enemy_wildbond() -> void:
	if not _enemy_wildbond_active:
		return
	if _enemy_wildbond_duration_pending_start:
		_enemy_wildbond_duration_pending_start = false
		return
	_enemy_wildbond_turns_remaining -= 1
	if _enemy_wildbond_turns_remaining <= 0:
		_end_enemy_wildbond()


func _end_enemy_wildbond() -> void:
	_enemy_wildbond_active = false
	_enemy_wildbond_lifesteal_pct = 0.0
	_enemy_wildbond_bonus_armor = 0.0
	_enemy_wildbond_turns_remaining = 0
	_enemy_wildbond_duration_pending_start = false
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), false)


## Only ever called for the plain basic-attack branch of the rival's
## turn - like the player's own copy, skill damage (Abyssal Spasm, Barbed Lunge,
## Thornbind's DoT) never triggers this. Heals the boss directly,
## clamped to their current effective max hp.
func _apply_enemy_wildbond_lifesteal(enemy: Dictionary, mitigated_attack_damage: float) -> void:
	if mitigated_attack_damage <= 0.0:
		return
	# A Morbid Mask the rival has bought stacks with Wildbond, same as the
	# player's own (see _apply_morbid_mask_lifesteal()).
	var lifesteal_pct: float = _enemy_wildbond_lifesteal_pct if _enemy_wildbond_active else 0.0
	if PlayerManager.get_npc_items(_enemy_hero_id).get("morbid_mask", 0) > 0:
		lifesteal_pct += MORBID_MASK_LIFESTEAL_PCT
	if lifesteal_pct <= 0.0:
		return
	var heal_amount: float = mitigated_attack_damage * lifesteal_pct
	var max_hp: float = _enemy_hero_effective_max_hp(enemy)
	enemy["current_hp"] = minf(max_hp, enemy["current_hp"] + heal_amount)
	_play_lifesteal_effect(hero_image, enemy.get("node"))


# ------------------------------------------------------------------
# Erynd's Beast of the Elderwild (ultimate), cast by the rival on themselves -
# mirrors _activate_beast_of_the_elderwild()/_tick_beast_of_the_elderwild()/_end_beast_of_the_elderwild().
# The bonus hp/damage, swapping the boss's own node texture the same way
# the player's portrait swaps, and - same as the player's own
# _is_ranged_hero() - forcing the rival into melee for the duration
# (see _enemy_hero_attack_type()).
# ------------------------------------------------------------------

## Whether the rival hero fights at "range" or in "melee" right now: its
## own "type", except that Beast of the Elderwild's bear form always
## fights in melee - it closes in and attacks on the player's column
## instead of keeping its distance.
func _enemy_hero_attack_type(enemy: Dictionary) -> String:
	if _enemy_beast_of_the_elderwild_active:
		return "melee"
	return enemy["static"].get("type", "")


func _activate_enemy_beast_of_the_elderwild(enemy: Dictionary, level_data: Dictionary) -> void:
	if _enemy_beast_of_the_elderwild_active:
		_end_enemy_beast_of_the_elderwild()
	_enemy_beast_of_the_elderwild_active = true
	_enemy_beast_of_the_elderwild_bonus_hp = float(level_data.get("bonus_hp", 0))
	var base_max_damage: float = _enemy_hero_max_damage() - _enemy_beast_of_the_elderwild_bonus_damage
	_enemy_beast_of_the_elderwild_bonus_damage = float(level_data.get("bonus_damage_pct", 0.0)) * base_max_damage
	_enemy_beast_of_the_elderwild_turns_remaining = int(level_data.get("duration", 0))
	_enemy_beast_of_the_elderwild_duration_pending_start = true

	if ResourceLoader.exists(BEAST_OF_THE_ELDERWILD_IMAGE_PATH) and is_instance_valid(enemy["node"]):
		enemy["node"].texture = load(BEAST_OF_THE_ELDERWILD_IMAGE_PATH)
		_refit_creature_node(enemy["node"], enemy["pos_index"])


func _tick_enemy_beast_of_the_elderwild() -> void:
	if not _enemy_beast_of_the_elderwild_active:
		return
	if _enemy_beast_of_the_elderwild_duration_pending_start:
		_enemy_beast_of_the_elderwild_duration_pending_start = false
		return
	_enemy_beast_of_the_elderwild_turns_remaining -= 1
	if _enemy_beast_of_the_elderwild_turns_remaining <= 0:
		_end_enemy_beast_of_the_elderwild()


func _end_enemy_beast_of_the_elderwild() -> void:
	_enemy_beast_of_the_elderwild_active = false
	_enemy_beast_of_the_elderwild_bonus_hp = 0.0
	_enemy_beast_of_the_elderwild_bonus_damage = 0.0
	_enemy_beast_of_the_elderwild_turns_remaining = 0
	_enemy_beast_of_the_elderwild_duration_pending_start = false

	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty() or not is_instance_valid(boss["node"]):
		return
	var original_image: String = str(boss["static"].get("image", ""))
	if original_image != "" and ResourceLoader.exists(original_image):
		boss["node"].texture = load(original_image)
		_refit_creature_node(boss["node"], boss["pos_index"])
		var animator := CreatureAnimator.of(boss["node"])
		if animator != null:
			animator.play_cast()


# ------------------------------------------------------------------
# Erynd's Blood of the Wild (passive), on the rival - mirrors
# _get_blood_of_the_wild_level_data()/_update_blood_of_the_wild_state(), same
# hysteresis: switches on once HP drops below 50%, stays on through
# the climb back up until HP reaches 80%. Re-evaluated once at the
# start of the rival's own turn (see _enemy_hero_turn()) rather than
# after every HP change, since there's no bars UI to keep live for an
# enemy the way _refresh_bars() does for the player.
# ------------------------------------------------------------------

func _get_enemy_blood_of_the_wild_level_data() -> Dictionary:
	if _enemy_hero_id == "":
		return {}
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "blood_of_the_wild")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("blood_of_the_wild")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


func _update_enemy_blood_of_the_wild_state(enemy: Dictionary) -> void:
	var level_data: Dictionary = _get_enemy_blood_of_the_wild_level_data()

	if level_data.is_empty():
		_enemy_blood_of_the_wild_active = false
	else:
		var max_hp: float = _enemy_hero_effective_max_hp(enemy)
		var hp_pct: float = float(enemy.get("current_hp", 0)) / max_hp if max_hp > 0.0 else 0.0
		if _enemy_blood_of_the_wild_active:
			if hp_pct >= 0.8:
				_enemy_blood_of_the_wild_active = false
		elif hp_pct < 0.5:
			_enemy_blood_of_the_wild_active = true

	_enemy_blood_of_the_wild_damage_reduction_pct = float(level_data.get("damage_reduction_pct", 0.0)) if _enemy_blood_of_the_wild_active else 0.0


# ------------------------------------------------------------------
# Morvael's Whisper of the Veil and Veil of the Forgotten, cast by the rival at (or on
# behalf of) himself - mirrors the player's own
# _resolve_whisper_of_the_veil_enemy_cast()/_activate_veil_of_the_forgotten()/
# _tick_veil_of_the_forgotten()/_end_veil_of_the_forgotten(). Whisper of the Veil goes either
# way, same as the player's own copy: a hit on the player (or his
# bear), or - picked by EnemySkillAI as its own "whisper_of_the_veil_self"
# candidate when he's hurt - a self-heal (_cast_enemy_whisper_of_the_veil_on_
# self()).
# ------------------------------------------------------------------

func _cast_enemy_whisper_of_the_veil(enemy: Dictionary, level_data: Dictionary) -> void:
	if _enemy_whisper_of_the_veil_self:
		_cast_enemy_whisper_of_the_veil_on_self(enemy, level_data)
		return
	if _enemy_skill_on_bear:
		_cast_enemy_whisper_of_the_veil_on_bear(enemy, level_data)
		return
	_play_whisper_of_the_veil_effect(enemy.get("node"), hero_image)
	apply_damage(float(level_data.get("damage", 0)))


## Purely cosmetic: Whisper of the Veil - a tendril of living mist
## (MistTendrilFX) reaching from the front of `from_node` - the side
## facing its target - to `to_node`'s middle, which flashes teal as it
## strikes. On a self-cast (both nodes the same) it curls down from
## above and sinks into him.
## Positions are captured up front, so a target killed by the hit still
## gets its tendril, just no flash. The damage/heal has already been
## applied by the time this plays; it never gates on it.
func _play_whisper_of_the_veil_effect(from_node: Variant, to_node: Variant) -> void:
	if not (from_node is Control) or not (to_node is Control):
		return
	if not is_instance_valid(from_node) or not is_instance_valid(to_node) or not is_instance_valid(_fx_layer):
		return
	var end: Vector2 = to_node.global_position + to_node.size * Vector2(0.5, 0.45)
	var start: Vector2
	if from_node == to_node:
		start = end + Vector2(-to_node.size.x * 0.35, -to_node.size.y * 0.85)
	else:
		var center: Vector2 = from_node.global_position + from_node.size * 0.5
		var facing: float = signf(end.x - center.x) if absf(end.x - center.x) > 1.0 else 1.0
		start = center + Vector2(facing * from_node.size.x * 0.25, -from_node.size.y * 0.1)
	MistTendrilFX.play(_fx_layer, start, end, func() -> void:
		if is_instance_valid(to_node) and to_node is TextureRect:
			_flash_bounce_hit(to_node, WHISPER_OF_THE_VEIL_FLASH_COLOR)
	)


## The glowing-ball projectile behind Deathlight Lure's visual: a ball
## of `color` (rimmed in `rim_color`) flies on a slight upward arc from
## `from_node` to `to_node`, trailing sparks, then bursts
## (_play_orb_impact()) and flashes the target in `flash_color`.
## Everything scales off `ball_size` - its glow, trail and burst - so a
## bigger ball reads as a heavier hit. When both nodes are the same it
## drops from above instead.
## Start/end points are captured up front, so a target killed by the
## hit still gets its ball and burst, just no flash.
func _play_orb_projectile(from_node: Variant, to_node: Variant, color: Color, rim_color: Color, flash_color: Color, ball_size: float) -> void:
	if not (from_node is Control) or not (to_node is Control):
		return
	if not is_instance_valid(from_node) or not is_instance_valid(to_node):
		return
	var size_scale: float = ball_size / 22.0

	var end: Vector2 = to_node.position + to_node.size / 2.0
	var start: Vector2 = from_node.position + from_node.size / 2.0
	if from_node == to_node:
		start = end - Vector2(0, to_node.size.y * 0.9)
	var travel: Vector2 = end - start
	var normal: Vector2 = Vector2(-travel.y, travel.x).normalized() if travel.length() > 0.001 else Vector2.UP
	# Always bulge upward, whichever way it's flying.
	if normal.y > 0.0:
		normal = -normal
	var control_point: Vector2 = (start + end) / 2.0 + normal * minf(60.0, travel.length() * 0.2)
	# A bigger ball travels a little slower, so it reads as heavier.
	var flight_time: float = clampf(travel.length() / (900.0 / sqrt(size_scale)), 0.3, 0.6 * sqrt(size_scale))

	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = rim_color
	style.set_border_width_all(maxi(0, int(size_scale) - 1))
	style.set_corner_radius_all(int(ceilf(ball_size / 2.0)))
	style.corner_detail = 16
	# The glow.
	style.shadow_color = Color(color.r, color.g, color.b, 0.6)
	style.shadow_size = int(10 * size_scale)
	var ball := Panel.new()
	ball.add_theme_stylebox_override("panel", style)
	ball.size = Vector2(ball_size, ball_size)
	ball.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ball.position = start - ball.size / 2.0
	add_child(ball)
	# Same layering as _play_double_trouble_effect() - at the hero/enemy
	# layer, not on top of every UI panel.
	move_child(ball, enemies_layer.get_index() + 1)

	var trail := CPUParticles2D.new()
	trail.local_coords = false
	trail.position = ball.size / 2.0
	trail.amount = int(30 * size_scale)
	trail.lifetime = 0.3 * sqrt(size_scale)
	if size_scale > 1.0:
		# A big ball sheds sparks from its whole body, not one point.
		trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		trail.emission_sphere_radius = ball_size * 0.3
	trail.spread = 180.0
	trail.gravity = Vector2.ZERO
	trail.initial_velocity_min = 5.0
	trail.initial_velocity_max = 25.0
	trail.scale_amount_min = 2.0 * size_scale
	trail.scale_amount_max = 5.0 * size_scale
	trail.color = color
	ball.add_child(trail)
	trail.emitting = true

	var tween: Tween = ball.create_tween()
	tween.tween_method(
		func(t: float) -> void:
			var a: Vector2 = start.lerp(control_point, t)
			var b: Vector2 = control_point.lerp(end, t)
			ball.position = a.lerp(b, t) - ball.size / 2.0,
		0.0, 1.0, flight_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		_play_orb_impact(end, color, size_scale)
		if is_instance_valid(to_node) and to_node is TextureRect:
			_flash_bounce_hit(to_node, flash_color)
		# Hide the ball but let the trail's last sparks finish fading.
		# (self_modulate hides the ball itself, not its trail child.)
		trail.emitting = false
		ball.self_modulate.a = 0.0
	)
	tween.tween_interval(trail.lifetime + 0.1)
	tween.tween_callback(ball.queue_free)


## The orb projectile's impact (see _play_orb_projectile()): a one-shot
## ring of `color` sparks at `pos`, scaled by `size_scale` (1.0 =
## Whisper of the Veil's own size). Same CPUParticles2D one-shot-burst recipe as
## _spawn_three_cheers_impact().
func _play_orb_impact(pos: Vector2, color: Color, size_scale: float) -> void:
	var lifetime: float = 0.45 * sqrt(size_scale)
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = false
	particles.one_shot = true
	particles.amount = int(28 * size_scale)
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 80.0 * sqrt(size_scale)
	particles.initial_velocity_max = 170.0 * sqrt(size_scale)
	particles.damping_min = 120.0
	particles.damping_max = 200.0
	if size_scale > 1.0:
		# Bigger bursts read as shards - randomly rotated pieces.
		particles.angle_min = 0.0
		particles.angle_max = 360.0
	particles.scale_amount_min = 3.0 * sqrt(size_scale)
	particles.scale_amount_max = 6.0 * sqrt(size_scale)
	particles.color = color
	add_child(particles)
	move_child(particles, enemies_layer.get_index() + 1)
	particles.emitting = true

	get_tree().create_timer(lifetime + 0.2).timeout.connect(particles.queue_free)


## Activates (or, if already active, replaces outright, same as the
## player's own copy) Veil of the Forgotten on the rival, and dispels every
## negative effect currently on him - here that's whatever the
## player's own Thornbind/Barbed Lunge/Mark of the Mist wrote directly onto
## this enemy Dictionary (see _apply_root()/_apply_mark_of_the_mist_
## stack()), since a hero-fight boss is otherwise a completely ordinary
## entry in _enemies.
func _activate_enemy_veil_of_the_forgotten(enemy: Dictionary, level_data: Dictionary) -> void:
	_enemy_veil_of_the_forgotten_active = true
	_enemy_veil_of_the_forgotten_hp = float(level_data.get("shield_hp", 0))
	_enemy_veil_of_the_forgotten_aoe_damage = float(level_data.get("aoe_damage", 0))
	_enemy_veil_of_the_forgotten_radius = int(level_data.get("radius", 0))
	_enemy_veil_of_the_forgotten_turns_remaining = int(level_data.get("duration", 0))
	_enemy_veil_of_the_forgotten_duration_pending_start = true

	# Checked before the dispel below clears it all - only drives the
	# cleanse sparks in _show_veil_shell().
	var cleansed: bool = bool(enemy.get("curse_active", false))
	for field in ["root_turns_left", "silence_turns_left", "thornbind_dot_turns_left", "stun_turns_left", "curse_stacks", "curse_dot_turns_left"]:
		if int(enemy.get(field, 0)) > 0:
			cleansed = true

	enemy["root_turns_left"] = 0
	enemy["silence_turns_left"] = 0
	enemy["thornbind_dot_damage"] = 0.0
	enemy["thornbind_dot_turns_left"] = 0
	enemy["stun_turns_left"] = 0
	enemy["curse_stacks"] = 0
	enemy["curse_active"] = false
	enemy["curse_dot_damage"] = 0.0
	enemy["curse_dot_turns_left"] = 0

	_show_veil_shell(enemy.get("node"), _enemy_veil_of_the_forgotten_hp, cleansed)


func _tick_enemy_veil_of_the_forgotten() -> void:
	if not _enemy_veil_of_the_forgotten_active:
		return
	if _enemy_veil_of_the_forgotten_duration_pending_start:
		_enemy_veil_of_the_forgotten_duration_pending_start = false
		return
	_enemy_veil_of_the_forgotten_turns_remaining -= 1
	if _enemy_veil_of_the_forgotten_turns_remaining <= 0:
		_end_enemy_veil_of_the_forgotten(false)


## Ends the rival's Veil of the Forgotten, whether its duration simply ran out
## (`exploded` false) or enough damage drained it to 0 HP (`exploded`
## true, from _deal_fixed_damage_to_enemy()) - in which case it deals
## the cast's own aoe_damage to the player, his guards and his bear,
## each only if within the shield's own radius columns of the boss -
## the same radius-around-the-caster rule the player's own explosion
## uses (see _end_veil_of_the_forgotten()).
func _end_enemy_veil_of_the_forgotten(exploded: bool) -> void:
	var aoe_damage: float = _enemy_veil_of_the_forgotten_aoe_damage
	var radius: int = _enemy_veil_of_the_forgotten_radius
	var boss: Dictionary = _get_hero_fight_boss()

	_enemy_veil_of_the_forgotten_active = false
	_enemy_veil_of_the_forgotten_hp = 0.0
	_enemy_veil_of_the_forgotten_aoe_damage = 0.0
	_enemy_veil_of_the_forgotten_radius = 0
	_enemy_veil_of_the_forgotten_turns_remaining = 0
	_enemy_veil_of_the_forgotten_duration_pending_start = false

	_remove_veil_shell(boss.get("node"), exploded, radius)

	if not exploded:
		return

	# Same radius-around-the-boss check as his guards/bear below - the
	# hero is only caught in it if he's actually standing close enough.
	var hero_in_range: bool = not boss.is_empty() and _distance(_hero_pos_index, boss["pos_index"]) <= radius
	if hero_in_range and not _is_hero_hidden():
		apply_damage(aoe_damage)
		# Same red hit-flash as Abyssal Spasm.
		_flash_bounce_hit(hero_image)
	# The explosion is centered on the boss's own column, not the
	# player's - a guard or the bear standing near him can still be
	# caught in it. Outside the stealth check above on purpose: the
	# hero hiding only protects the hero, not his guards or bear.
	if not boss.is_empty():
		_deal_aoe_damage_to_guards(boss["pos_index"], radius, aoe_damage, true)
		_deal_aoe_damage_to_bear(boss["pos_index"], radius, aoe_damage, true)


# ------------------------------------------------------------------
# Kaelen Varr's Drowned Surge, cast by the rival on the player - mirrors the
# player's own _resolve_drowned_surge_cast(). Simplification versus that
# player-facing copy: like Abyssal Spasm/Whisper of the Veil, there's only one
# possible target in a hero fight (no other enemy, and no bear/column
# concept to splash onto), so the level-4 AoE radius has nothing extra
# to reach here - this always resolves as a single hit.
# ------------------------------------------------------------------

func _cast_enemy_drowned_surge(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_drowned_surge_on_bear(level_data)
		return
	var damage: float = float(level_data.get("damage", 0))
	_play_drowned_surge_splash(hero_image)
	apply_damage(damage)
	# Drowned Surge's own splash radius is centered on the impact point (the
	# player, the only possible target here) - a guard near the
	# player can still be caught in it even though the single-hit
	# simplification above skips it for other creeps.
	var radius: int = int(level_data.get("radius", 0))
	_play_drowned_surge_splash_on_guards(_guards, _hero_pos_index, radius)
	if _is_bear_alive() and _distance(_bear["pos_index"], _hero_pos_index) <= radius:
		_play_drowned_surge_splash(_bear.get("node"))
	_deal_aoe_damage_to_guards(_hero_pos_index, radius, damage)
	_deal_aoe_damage_to_bear(_hero_pos_index, radius, damage)
	_player_stun_turns_left = int(level_data.get("stun_turns", 1))
	_show_message_over_hero("Stunned!")


## Drowned Surge's spray under every guard in `guards` (either side's
## array - `_guards` or `_enemy_guards`) within `radius` columns
## of `center_pos_index` - the same area check the matching
## _deal_aoe_damage_to_*guards() helper uses. Called just BEFORE
## that damage, since a killed guard's node gets freed.
func _play_drowned_surge_splash_on_guards(guards: Array, center_pos_index: int, radius: int) -> void:
	for guard in guards:
		if _distance(guard["pos_index"], center_pos_index) <= radius:
			_play_drowned_surge_splash(guard.get("node"))


## Purely cosmetic: Drowned Surge erupting under `node` (an enemy hit by the
## player's Drowned Surge, or the player's own hero_image when a rival casts
## it) - a geyser-like burst of water spray shooting up from its feet
## and falling back down. The position is captured up front, so a
## target killed by the hit still gets its splash.
func _play_drowned_surge_splash(node: Variant) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return

	var feet: Vector2 = node.position + Vector2(node.size.x / 2.0, node.size.y * 0.9)

	# The spray: a geyser-like burst straight up that rains back down.
	# Same CPUParticles2D one-shot-burst recipe as
	# _spawn_three_cheers_impact().
	var lifetime: float = 0.8
	var spray := CPUParticles2D.new()
	spray.position = feet
	spray.emitting = false
	spray.one_shot = true
	spray.amount = 40
	spray.lifetime = lifetime
	spray.explosiveness = 0.85
	spray.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	spray.emission_rect_extents = Vector2(node.size.x * 0.12, 2.0)
	spray.direction = Vector2(0, -1)
	spray.spread = 12.0
	spray.gravity = Vector2(0, 700)
	spray.initial_velocity_min = 220.0
	spray.initial_velocity_max = 380.0
	spray.scale_amount_min = 3.0
	spray.scale_amount_max = 6.0
	spray.color = DROWNED_SURGE_SPRAY_COLOR
	spray.hue_variation_min = -0.03
	spray.hue_variation_max = 0.03
	add_child(spray)
	# Same reasoning as _play_double_trouble_effect()'s own move_child()
	# call - render at the hero/enemy layer, not on top of every UI panel.
	move_child(spray, enemies_layer.get_index() + 1)
	spray.emitting = true

	get_tree().create_timer(lifetime + 0.2).timeout.connect(spray.queue_free)


# ------------------------------------------------------------------
# Kaelen Varr's Pull of the Abyss, on the rival - same plain-Attack counter as the
# player's own copy, just counting the rival's own Attacks on the
# player (see _resolve_enemy_hero_attack()) instead. No cleave here -
# same "only one possible target" simplification as Drowned Surge's own
# enemy-side copy above.
# ------------------------------------------------------------------

func _get_enemy_pull_of_the_abyss_level_data() -> Dictionary:
	if _enemy_hero_id == "":
		return {}
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "pull_of_the_abyss")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("pull_of_the_abyss")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


func _maybe_consume_enemy_pull_of_the_abyss_stack() -> Dictionary:
	var level_data: Dictionary = _get_enemy_pull_of_the_abyss_level_data()
	if level_data.is_empty():
		return {}

	_enemy_pull_of_the_abyss_attack_count += 1
	if _enemy_pull_of_the_abyss_attack_count < int(level_data.get("hits_to_activate", 1)):
		return {}

	_enemy_pull_of_the_abyss_attack_count = 0
	return level_data


# ------------------------------------------------------------------
# Kaelen Varr's Undertow, cast by the rival - marks the player (the
# only other participant in a hero fight), so unlike the player's own
# copy there's nothing to remember but the fact that a mark is pending
# (_enemy_undertow_pending) - see _enemy_hero_turn()'s own teleport check
# at its very top, which resolves it on the rival's next turn without
# spending that turn's action, mirroring _resolve_undertow_teleport().
# ------------------------------------------------------------------

func _cast_enemy_undertow() -> void:
	_enemy_undertow_pending = true


# ------------------------------------------------------------------
# Kaelen Varr's The Sunken One, cast by the rival - mirrors the player's
# own _cast_the_sunken_one(): the ship surfaces behind the rival and
# fires toward the player, out to this level's range. The player (if
# he's in that span - the AI only picks it when he is), the player's
# Elderwild Companion and any guards standing in it all take the
# damage when the first ball lands. Until then the player can't act
# (_rival_fx_in_flight), since the rival's turn is already over by the
# time the ship has even surfaced.
# ------------------------------------------------------------------

func _cast_enemy_the_sunken_one(enemy: Dictionary, level_data: Dictionary) -> void:
	var node: Control = enemy["node"]
	var from_pos: int = enemy["pos_index"]
	var dir: int = signi(_hero_pos_index - from_pos)
	if dir == 0:
		# Same column: fire the way the art faces (hero art faces right natively).
		dir = -1 if node.flip_h else 1
	var span: Vector2i = _the_sunken_one_span(from_pos, dir, level_data)
	var damage: float = float(level_data.get("damage", 0))

	var landings: Array[Vector2] = []
	if _hero_pos_index >= span.x and _hero_pos_index <= span.y:
		landings.append(hero_image.global_position + hero_image.size * 0.5)
	if not _bear.is_empty() and is_instance_valid(_bear.get("node")):
		var bear_node: Control = _bear["node"]
		var bear_pos: int = _bear.get("pos_index", -1)
		if bear_pos >= span.x and bear_pos <= span.y:
			landings.append(bear_node.global_position + bear_node.size * 0.5)
	_pad_the_sunken_one_landings(landings, span)

	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var fx: SunkenOneFX = SunkenOneFX.play(self, _fx_layer, node.global_position + node.size * 0.5,
			_the_sunken_one_ground_y(), dir, landings, func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		if _hero_pos_index >= span.x and _hero_pos_index <= span.y:
			apply_damage(damage)
		_deal_line_aoe_damage_to_guards(span.x, span.y, damage)
		_deal_line_aoe_damage_to_bear(span.x, span.y, damage)
		_shake_screen()
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	)
	move_child(fx, mini(hero_image.get_index(), enemies_layer.get_index()))


# ------------------------------------------------------------------
# Morvael's Mark of the Mist, cast by the rival - mirrors
# _apply_mark_of_the_mist_stack()/_tick_mark_of_the_mist_effects(),
# just building stacks on the player (via the _player_curse_* battle-
# local vars, since there's only one player to track state on) instead
# of on an enemy Dictionary, the same way Thornbind's own root/silence/
# DoT is mirrored by the _player_root_*/_player_thornbind_* vars above.
# ------------------------------------------------------------------

func _get_enemy_mark_of_the_mist_level_data() -> Dictionary:
	if _enemy_hero_id == "":
		return {}
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "mark_of_the_mist")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("mark_of_the_mist")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


## Called on every rival plain Attack against the player (see
## _resolve_enemy_hero_attack()): builds one stack, or - once this
## level's hits_to_activate is reached - consumes them all to actually
## curse the player (silence, sharing the same _player_silence_turns_
## left field Thornbind uses; and a damage-over-time, ticked by
## _tick_enemy_mark_of_the_mist_effects() below). No-ops entirely if
## the rival doesn't have this skill learned or the player is already
## cursed, same as the player's own copy.
func _apply_enemy_mark_of_the_mist_stack() -> void:
	var level_data: Dictionary = _get_enemy_mark_of_the_mist_level_data()
	if level_data.is_empty() or _player_curse_active:
		return

	_player_curse_last_hit_turn = _turn_count

	var stacks: int = _player_curse_stacks + 1
	var hits_to_activate: int = int(level_data.get("hits_to_activate", 1))
	if stacks < hits_to_activate:
		_player_curse_stacks = stacks
		return

	_player_curse_stacks = 0
	_player_curse_active = true
	_player_silence_turns_left = int(level_data.get("silence_turns", 0))
	_player_curse_dot_damage = float(level_data.get("dot_damage", 0))
	_player_curse_dot_turns_left = int(level_data.get("dot_duration", 0))
	_refresh_status_effects()


## The player-side mirror of _tick_mark_of_the_mist_effects(): the
## curse's own DoT moved to _tick_player_turn_start_effects() along with
## every other DoT - this is only the leftover, turn-count-based decay
## for a not-yet-cursed player still carrying stacks, same rules as the
## enemy-side version.
func _tick_enemy_mark_of_the_mist_effects() -> void:
	if not _player_curse_active and _player_curse_stacks > 0:
		if _turn_count - _player_curse_last_hit_turn >= MARK_OF_THE_MIST_STACK_DECAY_TURNS:
			_player_curse_stacks = 0


# ------------------------------------------------------------------
# Morvael's The Mist Remembers, on the rival - mirrors
# _maybe_auto_activate_the_mist_remembers()/_tick_the_mist_remembers()/
# _end_the_mist_remembers(). Like the player's own copy, nothing "casts"
# this - the only entry point is _deal_fixed_damage_to_enemy() noticing
# the rival's HP has crossed this level's threshold.
# ------------------------------------------------------------------

func _get_enemy_the_mist_remembers_level_data() -> Dictionary:
	if _enemy_hero_id == "":
		return {}
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "the_mist_remembers")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("the_mist_remembers")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


func _maybe_auto_activate_enemy_the_mist_remembers(enemy: Dictionary) -> void:
	if _enemy_the_mist_remembers_active or _enemy_skill_cooldowns.get("the_mist_remembers", 0) > 0:
		return

	var level_data: Dictionary = _get_enemy_the_mist_remembers_level_data()
	if level_data.is_empty():
		return

	var max_hp: float = _enemy_hero_effective_max_hp(enemy)
	if max_hp <= 0.0:
		return

	var hp_pct: float = float(enemy.get("current_hp", 0)) / max_hp
	if hp_pct > float(level_data.get("auto_activate_hp_pct", 0.3)):
		return

	_enemy_the_mist_remembers_active = true
	_enemy_the_mist_remembers_heal_conversion_pct = float(level_data.get("heal_conversion_pct", 1.0))
	_enemy_the_mist_remembers_turns_remaining = int(level_data.get("duration", 0))
	_enemy_the_mist_remembers_duration_pending_start = true
	_set_the_mist_remembers_visual(enemy.get("node"), true)

	_enemy_skill_cooldowns["the_mist_remembers"] = int(level_data.get("cooldown", 0))


func _tick_enemy_the_mist_remembers() -> void:
	if not _enemy_the_mist_remembers_active:
		return
	if _enemy_the_mist_remembers_duration_pending_start:
		_enemy_the_mist_remembers_duration_pending_start = false
		return
	_enemy_the_mist_remembers_turns_remaining -= 1
	if _enemy_the_mist_remembers_turns_remaining <= 0:
		_end_enemy_the_mist_remembers()


func _end_enemy_the_mist_remembers() -> void:
	_enemy_the_mist_remembers_active = false
	_enemy_the_mist_remembers_heal_conversion_pct = 0.0
	_enemy_the_mist_remembers_turns_remaining = 0
	_enemy_the_mist_remembers_duration_pending_start = false
	_set_the_mist_remembers_visual(_get_hero_fight_boss().get("node"), false)

	# Full cooldown from the moment it ends - see _end_the_mist_remembers().
	var level_data: Dictionary = _get_enemy_the_mist_remembers_level_data()
	if not level_data.is_empty():
		_enemy_skill_cooldowns["the_mist_remembers"] = int(level_data.get("cooldown", 0))


# ------------------------------------------------------------------
# Nhal's Mark of Stillness/The Hollow Cold, cast by the rival on the
# player - mirrors the player-side _resolve_mark_of_stillness_cast()/
# _resolve_the_hollow_cold_cast(), just arming the single-player _player_
# mark_of_stillness_dot_*/_player_the_hollow_cold_dot_* vars instead of per-enemy
# Dictionary fields, since there's only one player to track them on
# (same simplification Thornbind's own _player_thornbind_dot_* fields
# already use). The Hollow Cold's own AoE has nothing else to reach in a
# hero fight (there's no other enemy besides the player), same "only
# one possible target" simplification Abyssal Spasm/Drowned Surge's splash
# already use for a rival.
# ------------------------------------------------------------------

func _cast_enemy_mark_of_stillness(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_mark_of_stillness_on_bear(level_data)
		return
	_player_mark_of_stillness_dot_damage = float(level_data.get("damage", 0))
	_player_mark_of_stillness_dot_turns_left = int(level_data.get("duration", 0))
	_show_message_over_hero("Mark of Stillness!")
	_flash_bounce_hit(hero_image, MARK_OF_STILLNESS_FLASH_COLOR)
	_refresh_mark_of_stillness_frost()


func _cast_enemy_the_hollow_cold(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_the_hollow_cold_on_bear(level_data)
		return
	var damage: float = float(level_data.get("damage", 0))
	var duration: int = int(level_data.get("duration", 0))
	# Same default as the player's own copy (_resolve_the_hollow_cold_cast()).
	var radius: int = int(level_data.get("radius", 1))
	_player_the_hollow_cold_dot_damage = damage
	_player_the_hollow_cold_dot_turns_left = duration
	_show_message_over_hero("The Hollow Cold!")
	_flash_bounce_hit(hero_image, MARK_OF_STILLNESS_FLASH_COLOR)

	# Centered on the player (the vortex's only possible target here) -
	# his guards and Elderwild Companion within that radius get the same DoT,
	# ticked alongside his own in _tick_player_turn_start_effects().
	_mark_guards_the_hollow_cold(_guards, _hero_pos_index, radius, damage, duration)
	if _is_bear_alive() and _distance(_bear["pos_index"], _hero_pos_index) <= radius:
		_bear["the_hollow_cold_dot_damage"] = damage
		_bear["the_hollow_cold_dot_turns_left"] = duration
		if is_instance_valid(_bear.get("node")):
			_flash_bounce_hit(_bear["node"], MARK_OF_STILLNESS_FLASH_COLOR)

	_play_the_hollow_cold_swirl(hero_image, radius)
	_open_hollow_cold_tear(hero_image, _hero_pos_index, radius, duration, true)
	_refresh_mark_of_stillness_frost()


## Arms The Hollow Cold's DoT (`damage` per turn for `duration` turns) onto
## every guard in `guards` - either side's array, `_guards` or
## `_enemy_guards` - within `radius` columns of `center_pos_index`,
## the same area check the enemy-side loop uses, and gives each one the
## cast's icy flash. Stored on the guard's own Dictionary under the
## same the_hollow_cold_dot_* keys an enemy uses; ticked by
## _tick_enemy_guards_the_hollow_cold()/_tick_player_allies_the_hollow_cold().
func _mark_guards_the_hollow_cold(guards: Array, center_pos_index: int, radius: int, damage: float, duration: int) -> void:
	for guard in guards:
		if _distance(guard["pos_index"], center_pos_index) <= radius:
			guard["the_hollow_cold_dot_damage"] = damage
			guard["the_hollow_cold_dot_turns_left"] = duration
			if is_instance_valid(guard.get("node")):
				_flash_bounce_hit(guard["node"], MARK_OF_STILLNESS_FLASH_COLOR)


## Ticks The Hollow Cold's DoT on the rival's own guards - once per enemy
## turn, at its very start (see _enemy_turn()), the same timing every
## enemy's own DoT ticks at. Each tick is mitigated by the boss's own
## effective armor, the same way every other hit on one of his
## guards is (see _deal_aoe_damage_to_enemy_guards()).
func _tick_enemy_guards_the_hollow_cold() -> void:
	if _enemy_guards.is_empty():
		return
	var boss: Dictionary = _get_hero_fight_boss()
	var armor: float = _enemy_hero_effective_armor(boss) if not boss.is_empty() else 0.0
	for guard in _enemy_guards.duplicate():
		if guard.get("the_hollow_cold_dot_turns_left", 0) <= 0:
			continue
		guard["the_hollow_cold_dot_turns_left"] -= 1
		var dot: float = float(guard.get("the_hollow_cold_dot_damage", 0))
		if dot > 0.0:
			_deal_damage_to_enemy_guard(guard, _apply_armor_reduction(dot, armor))


## Ticks The Hollow Cold's DoT on the player's own guards - called from
## _tick_player_turn_start_effects(), right alongside the hero's own
## tick. Guards mitigate with the hero's own armor (same as every
## other hit on them - see _deal_aoe_damage_to_guards()).
func _tick_player_allies_the_hollow_cold() -> void:
	var hero_armor: float = _hero_armor()
	for guard in _guards.duplicate():
		if guard.get("the_hollow_cold_dot_turns_left", 0) <= 0:
			continue
		guard["the_hollow_cold_dot_turns_left"] -= 1
		var dot: float = float(guard.get("the_hollow_cold_dot_damage", 0))
		if dot > 0.0:
			_deal_damage_to_guard(guard, _apply_armor_reduction(dot, hero_armor))

	# The Elderwild Companion's own The Hollow Cold tick - along with every other DoT
	# a rival can put on it - lives in _tick_bear_turn_start_effects().


# ------------------------------------------------------------------
# Nhal's Touch of the First Cold, cast by the rival - mirrors the
# player's own _resolve_touch_of_the_first_cold_cast(): the rival's own rolled
# Attack damage (_roll_enemy_hero_damage(), the enemy-side mirror of
# _roll_hero_damage()) plus this level's own flat bonus_damage on top.
# Like the player's own copy, this is SKILL damage, not the plain
# Attack action itself, so it never triggers Leeching Hunger's steal,
# Wildbond's lifesteal, or Mark of the Mist's stacking - those stay
# scoped specifically to _resolve_enemy_hero_attack().
# The hit lands when The Reaching Void's talons strike (see
# _play_the_reaching_void()), and until then the player can't act
# (_rival_fx_in_flight) - same as the rival's The Sunken One.
# ------------------------------------------------------------------

func _cast_enemy_touch_of_the_first_cold(enemy: Dictionary, level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_touch_of_the_first_cold_on_bear(enemy, level_data)
		return
	var damage: float = _roll_enemy_hero_damage(enemy) + float(level_data.get("bonus_damage", 0))
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	_play_the_reaching_void(enemy.get("node"), hero_image, func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		apply_damage(damage)
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	)


## Purely cosmetic: Touch of the First Cold - The Reaching Void
## (VoidReachFX). A shard of void forms at the front of `from_node` (the
## side facing its target) and a limb of void reaches from it into
## `to_node`'s middle; at the touch the target is hollowed out, thrown
## back and frosted, and the screen shakes. `on_hit` (the damage) fires
## at that moment - or right away if either node is already gone, so
## the caller's turn flow never stalls.
func _play_the_reaching_void(from_node: Variant, to_node: Variant, on_hit: Callable) -> void:
	if not (from_node is Control) or not (to_node is Control) \
			or not is_instance_valid(from_node) or not is_instance_valid(to_node) or not is_instance_valid(_fx_layer):
		on_hit.call()
		return
	var end: Vector2 = to_node.global_position + to_node.size * Vector2(0.5, 0.45)
	var center: Vector2 = from_node.global_position + from_node.size * 0.5
	var facing: float = signf(end.x - center.x) if absf(end.x - center.x) > 1.0 else 1.0
	var start: Vector2 = center + Vector2(facing * from_node.size.x * 0.25, -from_node.size.y * 0.1)
	VoidReachFX.play(_fx_layer, start, end, to_node, func() -> void:
		if is_instance_valid(to_node):
			_flash_frost_briefly(to_node, 1.0)
		_shake_screen()
		on_hit.call()
	)


# ------------------------------------------------------------------
# Nhal's Return to the Void, cast by the rival - mirrors the
# player's own _resolve_return_to_the_void_cast().
# Like Abyssal Spasm/Drowned Surge/The Sunken One's own rival copies, there's only one
# possible target in a hero fight (the player), so the "hit everyone
# within radius" AoE collapses to a single hit; the DoT/execute state
# lives in the single-player _player_return_to_the_void_* vars instead of a
# per-enemy Dictionary field for the same reason Mark of Stillness's/Ice
# Vortex's own rival copies do.
# ------------------------------------------------------------------

func _cast_enemy_return_to_the_void(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_return_to_the_void_on_bear(level_data)
		return
	var damage: float = float(level_data.get("damage", 0))
	var radius: int = int(level_data.get("radius", 0))
	var struck: Array = [hero_image]
	for guard in _guards:
		if _distance(guard["pos_index"], _hero_pos_index) <= radius:
			struck.append(guard.get("node"))
	if _is_bear_alive() and _distance(_bear["pos_index"], _hero_pos_index) <= radius:
		struck.append(_bear.get("node"))
	_show_message_over_hero("Return to the Void!")
	# The player can't act until the world has been erased around him and
	# the hit has landed - same as the rival's The Sunken One.
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	_play_return_to_the_void(hero_image, radius, struck, func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		apply_damage(damage)
		# Return to the Void's own splash radius is centered on the impact point (the
		# player, the only possible target here) - a guard near the
		# player can still be caught in it.
		_deal_aoe_damage_to_guards(_hero_pos_index, radius, damage)
		_deal_aoe_damage_to_bear(_hero_pos_index, radius, damage)
		_player_return_to_the_void_dot_damage = float(level_data.get("dot_damage", 0))
		_player_return_to_the_void_dot_turns_left = int(level_data.get("dot_duration", 0))
		_player_return_to_the_void_execute_pct = float(level_data.get("execute_pct", 0.0))
		_player_stun_turns_left = int(level_data.get("stun_turns", 1))
		_refresh_mark_of_stillness_frost()
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	)


## Purely cosmetic: Return to the Void - The Unmaking (ReturnToVoidFX). A
## sigil brands itself onto `target_node`, the battlefield dims while
## cracks of cold light spread across `radius` columns around it, then
## the world inside that dome is erased into the void - every sprite in
## `struck` hollowed out, the screen shaking - and knits back. `on_impact`
## (the hits) fires at the erasure, or right away if the target's sprite
## is already gone, so the caller's turn flow never stalls. The erasure
## is drawn behind every fighter, over the battle background.
func _play_return_to_the_void(target_node: Variant, radius: int, struck: Array, on_impact: Callable) -> void:
	if not is_instance_valid(target_node) or not (target_node is Control) or not is_instance_valid(_fx_layer):
		on_impact.call()
		return
	var radii := Vector2(_grid_unit() * (float(radius) + 0.5), target_node.size.y * 0.75)
	ReturnToVoidFX.play(self, hero_image.get_index(), _fx_layer, target_node, radii, struck, func() -> void:
		_shake_screen()
		on_impact.call()
	)


## Keeps Return to the Void's lingering void mark (ReturnToVoidFX.
## set_void_mark()) on everyone still under its DoT - every enemy, the
## player's hero, and his Elderwild Companion - the same always-follow-
## current-state way _refresh_mark_of_stillness_frost() handles frost.
func _refresh_void_marks() -> void:
	for enemy in _enemies:
		ReturnToVoidFX.set_void_mark(enemy.get("node"), int(enemy.get("return_to_the_void_dot_turns_left", 0)) > 0)
	ReturnToVoidFX.set_void_mark(hero_image, _player_return_to_the_void_dot_turns_left > 0)
	if _is_bear_alive():
		ReturnToVoidFX.set_void_mark(_bear.get("node"), int(_bear.get("return_to_the_void_dot_turns_left", 0)) > 0)


# ------------------------------------------------------------------
# The Primordial Hunger's Frostbound Fangs, cast by the rival on themselves - mirrors
# the player's own _activate_frostbound_fangs()/_apply_frostbound_fangs_attack()/
# _tick_frostbound_fangs()/_end_frostbound_fangs(). _apply_enemy_frostbound_fangs_
# attack() is called from _resolve_enemy_hero_attack(), the enemy-side
# mirror of _apply_hero_attack()'s own call to _apply_frostbound_fangs_
# attack().
# ------------------------------------------------------------------

func _cast_enemy_frostbound_fangs(level_data: Dictionary) -> void:
	_enemy_frostbound_fangs_active = true
	_enemy_frostbound_fangs_bonus_damage = float(level_data.get("bonus_damage", 0))
	_enemy_frostbound_fangs_bonus_range = int(level_data.get("bonus_range", 0))
	_enemy_frostbound_fangs_attacks_remaining = int(level_data.get("attacks", 0))
	_enemy_frostbound_fangs_turns_remaining = int(level_data.get("duration", 0))
	_enemy_frostbound_fangs_duration_pending_start = true
	_show_message_over_hero("Frostbound Fangs!")
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), true)


func _apply_enemy_frostbound_fangs_attack() -> void:
	if not _enemy_frostbound_fangs_active or _enemy_frostbound_fangs_attacks_remaining <= 0:
		return
	_enemy_frostbound_fangs_attacks_remaining -= 1
	if _enemy_frostbound_fangs_attacks_remaining <= 0:
		_end_enemy_frostbound_fangs()


func _tick_enemy_frostbound_fangs() -> void:
	if not _enemy_frostbound_fangs_active:
		return
	if _enemy_frostbound_fangs_duration_pending_start:
		_enemy_frostbound_fangs_duration_pending_start = false
		return
	_enemy_frostbound_fangs_turns_remaining -= 1
	if _enemy_frostbound_fangs_turns_remaining <= 0:
		_end_enemy_frostbound_fangs()


func _end_enemy_frostbound_fangs() -> void:
	_enemy_frostbound_fangs_active = false
	_enemy_frostbound_fangs_bonus_damage = 0.0
	_enemy_frostbound_fangs_bonus_range = 0
	_enemy_frostbound_fangs_attacks_remaining = 0
	_enemy_frostbound_fangs_turns_remaining = 0
	_enemy_frostbound_fangs_duration_pending_start = false
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), false)


# ------------------------------------------------------------------
# The Primordial Hunger's Maddening Roar, cast by the rival on the player -
# mirrors the player's own _resolve_maddening_roar_cast(). Simplification
# versus that player-facing copy: like Abyssal Spasm/Whisper of the Veil/Drowned Surge,
# there's only one possible target in a hero fight, so the splash onto
# "every OTHER enemy within shatter_range" has nothing else to reach -
# this always resolves as a single hit.
# ------------------------------------------------------------------

func _cast_enemy_maddening_roar(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_maddening_roar_on_bear(level_data)
		return
	var damage: float = float(level_data.get("damage", 0))
	var shatter_range: int = int(level_data.get("shatter_range", 0))
	var shatter_damage: float = float(level_data.get("shatter_damage", 0))
	var shatter_nodes: Array = []
	for guard in _guards:
		if _distance(guard["pos_index"], _hero_pos_index) <= shatter_range:
			shatter_nodes.append(guard.get("node"))
	if _is_bear_alive() and _distance(_bear["pos_index"], _hero_pos_index) <= shatter_range:
		shatter_nodes.append(_bear.get("node"))
	# The player can't act until the roar has landed - same as the
	# rival's The Sunken One.
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var on_target_hit := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		apply_damage(damage)
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_rival_fx_in_flight = false
			_handle_defeat()
	var on_shatter := func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		# Maddening Roar's own splash (its lighter shatter_damage, not the
		# main hit) is centered on the impact point (the player, the only
		# possible target here) - a guard near the player can still be
		# caught in it.
		_deal_aoe_damage_to_guards(_hero_pos_index, shatter_range, shatter_damage)
		_deal_aoe_damage_to_bear(_hero_pos_index, shatter_range, shatter_damage)
		_refresh_bars()
		_update_action_buttons()
	_play_maddening_roar(_get_hero_fight_boss().get("node"), _enemy_hero_static, hero_image, shatter_nodes, on_target_hit, on_shatter)


## Purely cosmetic: Maddening Roar (RoarFX) - roared from `caster`'s jaws
## (its hero data's "roar_origin", a point on its art, mirrored when it
## faces left) at `target_node`, the rings then shattering every node in
## `others`. `on_target_hit` (the main hit) fires when the roar strikes
## the target and `on_shatter` (the splash) when the rings have reached
## the others - both right away if either sprite is already gone, so the
## caller's turn flow never stalls.
func _play_maddening_roar(caster: Variant, hero_static: Dictionary, target_node: Variant, others: Array, on_target_hit: Callable, on_shatter: Callable) -> void:
	if not is_instance_valid(caster) or not is_instance_valid(target_node) or not is_instance_valid(_fx_layer) \
			or not (caster is Control) or not (target_node is Control):
		on_target_hit.call()
		on_shatter.call()
		return
	var origin: Vector2 = hero_static.get("roar_origin", Vector2(0.5, 0.3))
	if caster.flip_h:
		origin.x = 1.0 - origin.x
	var mouth: Vector2 = caster.global_position + caster.size * origin
	RoarFX.play(_fx_layer, caster, mouth, target_node, others, on_target_hit, on_shatter)


# ------------------------------------------------------------------
# The Primordial Hunger's The Test of Time, cast by the rival on themselves -
# mirrors the player's own _activate_the_test_of_time()/_dispel_all_hero_
# effects()/_tick_the_test_of_time()/_end_the_test_of_time(), including the
# same floating and ticking clock (TimeStillFX) on the boss. Damage
# immunity is enforced in _deal_fixed_damage_to_enemy() (checked before
# The Mist Remembers/Veil of the Forgotten, same as the player's own apply_damage()
# checks The Test of Time before anything else); the full action lockout (no
# move, attack, OR skill cast - stricter than the player's own copy,
# which can still cast something else meanwhile) is enforced at the
# very top of _enemy_hero_turn().
# ------------------------------------------------------------------

func _cast_enemy_the_test_of_time(level_data: Dictionary) -> void:
	_dispel_all_enemy_hero_effects()

	_enemy_the_test_of_time_active = true
	_enemy_the_test_of_time_heal_per_turn = float(level_data.get("heal", 0))
	_enemy_the_test_of_time_turns_remaining = int(level_data.get("duration", 0))
	_enemy_the_test_of_time_duration_pending_start = true

	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty() and is_instance_valid(boss["node"]):
		TimeStillFX.begin(boss["node"], _enemy_the_test_of_time_turns_remaining)


## Dispels every other effect currently on the rival, good or bad, right
## before The Test of Time establishes its own state - the enemy-side mirror
## of the player's own _dispel_all_hero_effects(), enumerating the same
## kind of fields but from the "_enemy_*" block instead (this rival's
## own buffs) - there's nothing equivalent to the player's debuff-
## receiving fields to clear here, since nothing in this game currently
## lets a rival hero's own AI inflict a debuff on ITSELF.
func _dispel_all_enemy_hero_effects() -> void:
	if _enemy_frostbound_fangs_active:
		_end_enemy_frostbound_fangs()
	if _enemy_leeching_hunger_active:
		_end_enemy_leeching_hunger()
	if _enemy_depthsveil_active:
		_end_enemy_depthsveil()
	if _enemy_wildbond_active:
		_end_enemy_wildbond()
	if _enemy_beast_of_the_elderwild_active:
		_end_enemy_beast_of_the_elderwild()
	if _enemy_veil_of_the_forgotten_active:
		_end_enemy_veil_of_the_forgotten(false)
	if _enemy_the_mist_remembers_active:
		_end_enemy_the_mist_remembers()


func _tick_enemy_the_test_of_time() -> void:
	if not _enemy_the_test_of_time_active:
		return

	if _enemy_the_test_of_time_duration_pending_start:
		_enemy_the_test_of_time_duration_pending_start = false
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty():
		var max_hp: float = _enemy_hero_effective_max_hp(boss)
		boss["current_hp"] = minf(max_hp, float(boss.get("current_hp", 0.0)) + _enemy_the_test_of_time_heal_per_turn)

	_enemy_the_test_of_time_turns_remaining -= 1
	if not boss.is_empty():
		var clock := TimeStillFX.of(boss.get("node"))
		if clock != null:
			clock.set_turns(_enemy_the_test_of_time_turns_remaining)
	if _enemy_the_test_of_time_turns_remaining <= 0:
		_end_enemy_the_test_of_time()


func _end_enemy_the_test_of_time() -> void:
	_enemy_the_test_of_time_active = false
	_enemy_the_test_of_time_heal_per_turn = 0.0
	_enemy_the_test_of_time_turns_remaining = 0
	_enemy_the_test_of_time_duration_pending_start = false

	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty():
		var clock := TimeStillFX.of(boss.get("node"))
		if clock != null:
			clock.finish()


# ------------------------------------------------------------------
# The Primordial Hunger's ultimate, The Hunger Calls, cast by the rival - mirrors
# the player's own _resolve_the_hunger_calls_cast()/_is_the_hunger_calls_
# active(). Simplification versus that player-facing copy: the "every
# OTHER enemy within curse_range piles onto the frozen target instead
# of the caster" half of the effect has nothing to redirect in a hero
# fight - the rival's only possible "attacker" is the player himself,
# controlled directly rather than by the same AI _enemy_turn() redirect
# logic uses, so there's no second enemy to pull off of him. This
# collapses The Hunger Calls down to freezing the player outright
# (reusing the shared _player_stun_turns_left field Drowned Surge's/Barbed Lunge's/
# Return to the Void's own stun already use), the same "AoE/redirect skill with
# only one possible target" simplification Abyssal Spasm/Maddening Roar/
# The Hollow Cold already use for a rival.
# ------------------------------------------------------------------

func _cast_enemy_the_hunger_calls(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_the_hunger_calls_on_bear(level_data)
		return
	_player_stun_turns_left = int(level_data.get("duration", 0))
	_player_the_hunger_calls_active = true
	_show_message_over_hero("The Hunger Calls!")
	if _enemy_hunger_calls_fx != null:
		_enemy_hunger_calls_fx.end()
	_enemy_hunger_calls_fx = _play_the_hunger_calls(_get_hero_fight_boss().get("node"), _enemy_hero_static, hero_image, int(level_data.get("curse_range", 0)))
	_enemy_hunger_calls_fx_on_bear = false
	_refresh_mark_of_stillness_frost()


# ------------------------------------------------------------------
# Frost Daughter's Rimecleaver/Winter's Grip, cast by the rival on the
# player - mirror the player's own _resolve_rimecleaver_cast()/
# _resolve_winters_grip_cast(). Simplification versus those player-facing
# copies: there's only one possible target in a hero fight (the player),
# so Rimecleaver's own "every other enemy within radius of the primary
# target" splash has nothing else to reach - same "AoE skill with only
# one possible target" simplification Abyssal Spasm/Maddening Roar/Ice
# Vortex already use for a rival.
# ------------------------------------------------------------------

func _cast_enemy_rimecleaver(level_data: Dictionary) -> void:
	var damage: float = float(level_data.get("damage", 0))
	var radius: int = int(level_data.get("radius", 0))
	_show_message_over_hero("Rimecleaver!")
	# The player can't act until the axe has fallen (and swung) and the
	# hits have landed - same as the rival's Return to the Void.
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var on_impact := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		# Flashed red and frosted before the hit lands.
		_flash_frost_briefly(hero_image, RIMECLEAVER_FROST_SECONDS, BOUNCE_HIT_FLASH_COLOR)
		apply_damage(damage)
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_rival_fx_in_flight = false
			_handle_defeat()
			return
		if radius <= 0:
			_rival_fx_in_flight = false
			_update_action_buttons()
	var on_sweep := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			_rival_fx_in_flight = false
			_update_action_buttons()
			return
		# Rimecleaver's own splash (the same damage as the main hit) is
		# centered on the impact point (the player, the only possible
		# target here) - a guard near the player can still be caught
		# in it.
		_deal_aoe_damage_to_guards(_hero_pos_index, radius, damage)
		_deal_aoe_damage_to_bear(_hero_pos_index, radius, damage)
		_rival_fx_in_flight = false
		_refresh_bars()
		_update_action_buttons()
	# Anyone else caught (a guard, the bear) flashes red and frosts as
	# the swing cuts through them.
	var pass_nodes: Array = []
	if radius > 0:
		for guard in _guards:
			if _distance(guard["pos_index"], _hero_pos_index) <= radius:
				pass_nodes.append(guard.get("node"))
		if _is_bear_alive() and _distance(_bear["pos_index"], _hero_pos_index) <= radius:
			pass_nodes.append(_bear.get("node"))
	var on_pass := func(i: int) -> void:
		if not _battle_over and _stage_generation == generation_before:
			_flash_frost_briefly(pass_nodes[i], RIMECLEAVER_FROST_SECONDS, BOUNCE_HIT_FLASH_COLOR)
	_play_rimecleaver(hero_image, radius, on_impact, on_sweep, pass_nodes, on_pass)


func _cast_enemy_winters_grip(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_winters_grip_on_bear(level_data)
		return
	_player_winters_grip_dot_damage = float(level_data.get("dot_damage", 0))
	_player_winters_grip_dot_turns_left = int(level_data.get("dot_duration", 0))
	_player_stun_turns_left = int(level_data.get("stun_turns", 1))
	_player_winters_grip_hold = true
	_show_message_over_hero("Winter's Grip!")
	_flash_bounce_hit(hero_image, MARK_OF_STILLNESS_FLASH_COLOR)
	_refresh_mark_of_stillness_frost()
	_refresh_winters_grip_hands()



# ------------------------------------------------------------------
# Frost Daughter's ultimate, The Frost Tempest, cast by the rival on
# herself - mirrors the player's own _activate_frost_tempest()/_tick_
# frost_tempest()/_end_frost_tempest(). Damage is applied straight to
# the player via apply_damage() (which already checks the player's own
# The Test of Time immunity, same as every other rival hit) rather than
# _deal_fixed_damage_to_enemy() (an enemy-side helper, for damage FROM
# the player), the same split every other "rival hits the player" cast
# above already uses.
# ------------------------------------------------------------------

func _cast_enemy_frost_tempest(level_data: Dictionary) -> void:
	_enemy_frost_tempest_active = true
	_enemy_frost_tempest_damage_per_turn = float(level_data.get("damage", 0))
	_enemy_frost_tempest_radius = int(level_data.get("radius", 0))
	_enemy_frost_tempest_turns_remaining = int(level_data.get("duration", 0))
	_enemy_frost_tempest_duration_pending_start = true
	_show_message_over_hero("The Frost Tempest!")


## Ticks The Frost Tempest's duration down once per End Turn, same timing
## (and same "the casting turn doesn't count" skip) as every other
## duration-based buff - dealing this level's own damage to the player
## whenever they're within radius columns of the rival's CURRENT
## position (re-checked fresh here, not fixed at cast time, mirroring
## the player's own _tick_frost_tempest()). There's only one possible
## target in a hero fight, so this collapses to a single conditional hit
## rather than a loop over multiple enemies.
func _tick_enemy_frost_tempest() -> void:
	if not _enemy_frost_tempest_active:
		return

	if _enemy_frost_tempest_duration_pending_start:
		_enemy_frost_tempest_duration_pending_start = false
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty():
		# Every unit this tick is about to hit flashes red, before the
		# damage lands (a kill frees its node).
		var boss_pos: int = boss["pos_index"]
		var hit_nodes: Array = []
		if _distance(boss_pos, _hero_pos_index) <= _enemy_frost_tempest_radius:
			hit_nodes.append(hero_image)
		for guard in _guards:
			if _distance(guard["pos_index"], boss_pos) <= _enemy_frost_tempest_radius:
				hit_nodes.append(guard.get("node"))
		if _is_bear_alive() and _distance(_bear["pos_index"], boss_pos) <= _enemy_frost_tempest_radius:
			hit_nodes.append(_bear.get("node"))
		_flash_frost_tempest_hits(hit_nodes)

		if _distance(boss["pos_index"], _hero_pos_index) <= _enemy_frost_tempest_radius:
			apply_damage(_enemy_frost_tempest_damage_per_turn)
		# Centered on the boss's own CURRENT position, same as the hero
		# check above - a guard can be in range independently of
		# whether the hero himself currently is.
		_deal_aoe_damage_to_guards(boss["pos_index"], _enemy_frost_tempest_radius, _enemy_frost_tempest_damage_per_turn)
		_deal_aoe_damage_to_bear(boss["pos_index"], _enemy_frost_tempest_radius, _enemy_frost_tempest_damage_per_turn)

	_enemy_frost_tempest_turns_remaining -= 1
	if _enemy_frost_tempest_turns_remaining <= 0:
		_end_enemy_frost_tempest()
	_refresh_mark_of_stillness_frost()


func _end_enemy_frost_tempest() -> void:
	_enemy_frost_tempest_active = false
	_enemy_frost_tempest_damage_per_turn = 0.0
	_enemy_frost_tempest_radius = 0
	_enemy_frost_tempest_turns_remaining = 0
	_enemy_frost_tempest_duration_pending_start = false
	_refresh_mark_of_stillness_frost()


# ------------------------------------------------------------------
# Skarn's Frostbound Rupture, cast by the rival on the player - mirrors the
# player's own _resolve_frostbound_rupture_cast()/_tick_frostbound_rupture()/_end_frostbound_
# rupture(). Walls off `blocked_columns` columns starting on the rival's
# OWN column and continuing toward the player's, same directional walk
# the player's own copy uses, just from the other side.
# ------------------------------------------------------------------

func _cast_enemy_frostbound_rupture(enemy: Dictionary, level_data: Dictionary) -> void:
	_show_message_over_hero("Frostbound Rupture!")
	# The player can't act until the rival's slam has landed and the
	# shards have hit - same as the rival's Rimecleaver.
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	_play_ground_slam(enemy.get("node"), func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		_land_enemy_frostbound_rupture(enemy, level_data)
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	)


func _land_enemy_frostbound_rupture(enemy: Dictionary, level_data: Dictionary) -> void:
	_play_frostbound_rupture_hit(enemy.get("node"), hero_image)
	apply_damage(float(level_data.get("damage", 0)))

	var direction: int = _step_toward(enemy["pos_index"], _hero_pos_index)
	if direction == 0:
		direction = 1

	var blocked_columns: int = int(level_data.get("blocked_columns", 0))
	var columns: Array[int] = []
	var col: int = enemy["pos_index"]
	for i in range(blocked_columns):
		if col < 0 or col >= GRID_COLUMNS:
			break
		columns.append(col)
		col += direction

	_enemy_frostbound_rupture_active = true
	_enemy_frostbound_rupture_blocked_columns = columns
	_enemy_frostbound_rupture_turns_remaining = int(level_data.get("duration", 0))
	_enemy_frostbound_rupture_duration_pending_start = true
	_refresh_frostbound_rupture_visuals()


func _tick_enemy_frostbound_rupture() -> void:
	if not _enemy_frostbound_rupture_active:
		return

	if _enemy_frostbound_rupture_duration_pending_start:
		_enemy_frostbound_rupture_duration_pending_start = false
		return

	_enemy_frostbound_rupture_turns_remaining -= 1
	if _enemy_frostbound_rupture_turns_remaining <= 0:
		_end_enemy_frostbound_rupture()


func _end_enemy_frostbound_rupture() -> void:
	_enemy_frostbound_rupture_active = false
	_enemy_frostbound_rupture_blocked_columns = []
	_enemy_frostbound_rupture_turns_remaining = 0
	_enemy_frostbound_rupture_duration_pending_start = false
	_refresh_frostbound_rupture_visuals()


## Whether `col` is currently walled off by the RIVAL's own Frostbound Rupture -
## checked from _hero_move() (and the movement helpers it delegates to)
## so the player can't move at all while standing in one, and can't step
## into one from outside it, mirroring the player's own _is_column_frostbound_
## rupture_blocked() (which does the same to every enemy's own movement).
## Attacking, casting a skill, and using an item are all untouched
## either way, same as the player's own copy.
func _is_column_enemy_frostbound_rupture_blocked(col: int) -> bool:
	return _enemy_frostbound_rupture_active and col in _enemy_frostbound_rupture_blocked_columns


# ------------------------------------------------------------------
# Skarn's Charge, cast by the rival on the player - mirrors the
# player's own _resolve_charge_cast(): moves the rival straight onto
# the player's own column, dealing damage and stunning on impact.
# ------------------------------------------------------------------

func _cast_enemy_charge(enemy: Dictionary, level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_charge_on_bear(enemy, level_data)
		return

	# The charge physically carries the rival across every column in
	# between, so the player's own Frostbound Rupture wall in its path stops it
	# one column short - same rule the player's own Charge
	# follows now (see _resolve_charge_cast()).
	var charge_direction: int = _step_toward(enemy["pos_index"], _hero_pos_index)
	var landing_pos: int = enemy["pos_index"]
	while charge_direction != 0 and landing_pos != _hero_pos_index:
		var next_pos: int = landing_pos + charge_direction
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		landing_pos = next_pos

	_show_message_over_hero("Charge!")
	# The player can't act until the rival has locked on, charged and hit -
	# same as the rival's Rimecleaver.
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var damage: float = float(level_data.get("damage", 0))
	var stun: int = int(level_data.get("stun_turns", 1))
	_play_charge(enemy.get("node"), hero_image, func() -> float:
		var old_x: float = enemy["node"].position.x
		_move_enemy(enemy, landing_pos)
		return old_x - enemy["node"].position.x
	, func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		apply_damage(damage)
		_player_stun_turns_left = stun
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	)


# ------------------------------------------------------------------
# Skarn's Bestial Rage, cast by the rival on himself - mirrors the player's
# own _activate_bestial_rage()/_tick_bestial_rage()/_end_bestial_rage(): a flat
# bonus_damage added to _roll_enemy_hero_damage() for the duration.
# ------------------------------------------------------------------

func _cast_enemy_bestial_rage(level_data: Dictionary) -> void:
	_enemy_bestial_rage_active = true
	_enemy_bestial_rage_bonus_damage = float(level_data.get("bonus_damage", 0))
	_enemy_bestial_rage_turns_remaining = int(level_data.get("duration", 0))
	_enemy_bestial_rage_duration_pending_start = true
	_show_message_over_hero("Bestial Rage!")
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), true)


func _tick_enemy_bestial_rage() -> void:
	if not _enemy_bestial_rage_active:
		return

	if _enemy_bestial_rage_duration_pending_start:
		_enemy_bestial_rage_duration_pending_start = false
		return

	_enemy_bestial_rage_turns_remaining -= 1
	if _enemy_bestial_rage_turns_remaining <= 0:
		_end_enemy_bestial_rage()


func _end_enemy_bestial_rage() -> void:
	_enemy_bestial_rage_active = false
	_enemy_bestial_rage_bonus_damage = 0.0
	_enemy_bestial_rage_turns_remaining = 0
	_enemy_bestial_rage_duration_pending_start = false
	_set_hero_enlarged(_get_hero_fight_boss().get("node"), false)


# ------------------------------------------------------------------
# Skarn's ultimate, Glacier Breaker, cast by the rival on the player -
# mirrors the player's own _resolve_glacier_breaker_cast(): rolls the
# rival's own Attack damage (_roll_enemy_hero_damage(), already folding
# in Bestial Rage's bonus while active) times this level's own
# damage_multiplier, then works out how far the knockback actually
# carries - walking one column at a time, away from the rival's current
# facing (its node's own flip_h, the enemy-side mirror of the player's
# own hero_image.flip_h), for up to `knockback` columns, stopping early
# at the edge of the board or at the first column another living,
# targetable enemy already occupies (a reinforcement creep, during a
# hero fight that's gone on long enough to spawn one - see
# _spawn_reinforcements()'s own "hero fights still get reinforcements"
# note). Coming up short either way adds 50% more damage before it
# lands, then stuns the player in place if they survive.
# ------------------------------------------------------------------

func _cast_enemy_glacier_breaker(enemy: Dictionary, level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_glacier_breaker_on_bear(enemy, level_data)
		return
	var multiplier: float = float(level_data.get("damage_multiplier", 1.0))
	var punch_damage: float = _roll_enemy_hero_damage(enemy) * multiplier

	var knockback_columns: int = int(level_data.get("knockback", 0))
	var direction: int = -1 if enemy["node"].flip_h else 1
	var pos: int = _hero_pos_index
	var actual_distance: int = 0
	for i in range(knockback_columns):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if not _get_enemy_at(next_pos).is_empty():
			break
		# Knocked straight into the rival's own Frostbound Rupture wall (if
		# they've cast it) - stops here same as hitting the board edge
		# or another enemy, and counts as the same "hit_wall" bonus
		# damage below (a literal wall, this time).
		if _is_column_enemy_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos
		actual_distance += 1

	var hit_wall: bool = actual_distance < knockback_columns
	if hit_wall:
		punch_damage *= 1.5

	apply_damage(punch_damage)

	if hit_wall:
		_show_message_over_hero("Wall hit!")

	if _recruited.get("current_hp", 0) > 0:
		_hero_pos_index = pos
		# Same facing convention as _hero_move()'s own copy - faces the
		# direction it just got knocked in, rather than staying turned
		# toward the boss that just punched it.
		hero_image.flip_h = direction < 0
		_update_hero_position()
		_player_stun_turns_left = int(level_data.get("stun_turns", 1))


# ------------------------------------------------------------------
# The Rootmother's Rootveil, cast by the rival on himself -
# mirrors the player's own _activate_rootveil()/_tick_rootveil()/_end_rootveil(): functionally the same invisibility as
# Depthsveil (folded into the very same _is_target_hidden()/_update_
# enemy_hero_visibility() checks), just with a root on the player
# instead of bonus damage for the Attack that breaks it - see
# _resolve_enemy_hero_attack()'s own "attacking_from_enemy_rootveil" capture.
# ------------------------------------------------------------------

func _activate_enemy_rootveil(level_data: Dictionary) -> void:
	_enemy_rootveil_active = true
	_enemy_rootveil_root_turns = int(level_data.get("root_turns", 0))
	_enemy_rootveil_turns_remaining = int(level_data.get("duration", 0))
	_enemy_rootveil_duration_pending_start = true
	_update_enemy_hero_visibility()


func _tick_enemy_rootveil() -> void:
	if not _enemy_rootveil_active:
		return
	if _enemy_rootveil_duration_pending_start:
		_enemy_rootveil_duration_pending_start = false
		return
	_enemy_rootveil_turns_remaining -= 1
	if _enemy_rootveil_turns_remaining <= 0:
		_end_enemy_rootveil()


func _end_enemy_rootveil() -> void:
	_enemy_rootveil_active = false
	_enemy_rootveil_root_turns = 0
	_enemy_rootveil_turns_remaining = 0
	_enemy_rootveil_duration_pending_start = false
	_update_enemy_hero_visibility()


# ------------------------------------------------------------------
# The Rootmother's Sanguine Bloom, cast by the rival on the player -
# mirrors the player's own _resolve_sanguine_bloom_cast(): no immediate
# damage, just arms this level's own dot_damage/heal_per_turn on the
# player's own dedicated _player_sanguine_bloom_* fields, ticked once per
# turn (alongside every other rival-inflicted DoT) by _tick_player_
# turn_start_effects() - which, unlike every other DoT there, also heals
# the CASTER (the rival, via _get_hero_fight_boss()) each tick instead
# of the player.
# ------------------------------------------------------------------

func _cast_enemy_sanguine_bloom(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_sanguine_bloom_on_bear(level_data)
		return
	_player_sanguine_bloom_dot_damage = float(level_data.get("dot_damage", 0))
	_player_sanguine_bloom_heal_per_turn = float(level_data.get("heal_per_turn", 0))
	_player_sanguine_bloom_dot_turns_left = int(level_data.get("duration", 0))
	_show_message_over_hero("Sanguine Bloom!")


# ------------------------------------------------------------------
# The Rootmother's Woven Flesh, cast by the rival on himself - mirrors
# the player's own _activate_woven_flesh()/_tick_woven_flesh()/
# _end_woven_flesh(): bonus_armor folds into _enemy_hero_bonus_armor(),
# bonus_hp_regen heals the rival on top of his own baseline passive
# regen (_tick_enemy_passive_regen()) every tick, same "on top of the
# baseline, not instead of it" relationship the player's own copy has
# with _apply_passive_hero_regen().
# ------------------------------------------------------------------

func _activate_enemy_woven_flesh(level_data: Dictionary) -> void:
	_enemy_woven_flesh_active = true
	_enemy_woven_flesh_bonus_armor = float(level_data.get("bonus_armor", 0))
	var rival_woven_max_hp: float = _enemy_hero_effective_max_hp(_get_hero_fight_boss())
	_enemy_woven_flesh_bonus_hp_regen = float(level_data.get("bonus_hp_regen", 0)) + float(level_data.get("bonus_hp_regen_pct", 0.0)) * rival_woven_max_hp
	_enemy_woven_flesh_turns_remaining = int(level_data.get("duration", 0))
	_enemy_woven_flesh_duration_pending_start = true
	_show_message_over_hero("Woven Flesh!")
	WovenFleshFX.set_on(_get_hero_fight_boss().get("node"), true)


func _tick_enemy_woven_flesh() -> void:
	if not _enemy_woven_flesh_active:
		return
	if _enemy_woven_flesh_duration_pending_start:
		_enemy_woven_flesh_duration_pending_start = false
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if not boss.is_empty():
		var max_hp: float = _enemy_hero_effective_max_hp(boss)
		boss["current_hp"] = minf(max_hp, float(boss.get("current_hp", 0.0)) + _enemy_woven_flesh_bonus_hp_regen)
		WovenFleshFX.pulse_on(boss.get("node"))

	_enemy_woven_flesh_turns_remaining -= 1
	if _enemy_woven_flesh_turns_remaining <= 0:
		_end_enemy_woven_flesh()


func _end_enemy_woven_flesh() -> void:
	_enemy_woven_flesh_active = false
	_enemy_woven_flesh_bonus_armor = 0.0
	_enemy_woven_flesh_bonus_hp_regen = 0.0
	_enemy_woven_flesh_turns_remaining = 0
	_enemy_woven_flesh_duration_pending_start = false
	WovenFleshFX.set_on(_get_hero_fight_boss().get("node"), false)


# ------------------------------------------------------------------
# The Rootmother's ultimate, Mother's Grasp, cast by the rival - mirrors
# the player's own _activate_mothers_grasp(): every living, targetable
# enemy within `radius` columns of the rival's CURRENT position gets
# rooted (_player_root_turns_left, the same shared field Thornbind's own
# root already uses - it can still attack and cast skills while rooted,
# same as any other rooted enemy) for `root_duration` turns, armed with
# that same level's own DoT (_player_mothers_grasp_dot_damage/_player_
# mothers_grasp_dot_turns_left, a dedicated pair so it never clobbers
# another skill's DoT on the player) for the same duration - ticked, at
# the start of the player's own turn, by _tick_player_turn_start_
# effects(). There's only one possible target in a hero fight, so this
# collapses to a single conditional hit rather than a loop over multiple
# enemies, same simplification every other AoE skill's own rival copy
# already uses.
# ------------------------------------------------------------------

func _cast_enemy_mothers_grasp(enemy: Dictionary, level_data: Dictionary) -> void:
	var radius: int = int(level_data.get("radius", 0))
	var dot_damage: float = float(level_data.get("dot_damage", 0))
	if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
		var root_duration: int = int(level_data.get("root_duration", 0))
		_player_root_turns_left = root_duration
		_player_mothers_grasp_dot_damage = dot_damage
		_player_mothers_grasp_dot_turns_left = root_duration

	# Guards have no root/DoT of their own to carry the way the hero
	# does above - just a one-time hit for whatever's caught in the
	# burst, centered on the caster's own column, same as the check
	# above.
	_deal_aoe_damage_to_guards(enemy["pos_index"], radius, dot_damage)
	_deal_aoe_damage_to_bear(enemy["pos_index"], radius, dot_damage)
	_play_mothers_grasp_slam(enemy.get("node"))
	_refresh_mothers_grasp_roots()

	_show_message_over_hero("Mother's Grasp!")


# ------------------------------------------------------------------
# Cinder's Sweep, cast by the rival on himself - mirrors the
# player's own _cast_sweep(): `level_data.damage` to the player
# whenever they're within `radius` columns of the rival's CURRENT
# position. There's only one possible target in a hero fight, so this
# collapses to a single conditional hit rather than a loop over multiple
# enemies, same simplification every other self-centered AoE's own
# rival copy already uses (see _cast_enemy_frost_tempest()/_cast_enemy_
# mothers_grasp()). "Pure damage" and the primary-attribute reduction are
# both purely descriptive here - neither is mechanically implemented
# anywhere in this project (the player's own _cast_sweep() also
# just calls _deal_fixed_damage_to_enemy(), the same armor-mitigated
# path every other skill uses, and no reduction amount exists anywhere
# in its own level data), so this mirrors that exact behavior rather
# than inventing either one - see EnemySkillAI's own _cinder_
# sweep_modifier() for how the AI still accounts for the
# qualitative "a hero was hit" value without a real stat system behind
# it.
# ------------------------------------------------------------------

func _cast_enemy_sweep(enemy: Dictionary, level_data: Dictionary) -> void:
	var radius: int = int(level_data.get("radius", 0))
	var damage: float = float(level_data.get("damage", 0))
	_play_sweep_flames(enemy["pos_index"], radius)
	if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
		apply_damage(damage)
		# The standard splash hit-flash (see _apply_splash_damage()).
		_flash_bounce_hit(hero_image)
	# Centered on the caster's own column, same as the check above - an
	# guard can be in range independently of whether the player
	# himself currently is.
	_deal_aoe_damage_to_guards(enemy["pos_index"], radius, damage, true)
	_deal_aoe_damage_to_bear(enemy["pos_index"], radius, damage, true)
	_show_message_over_hero("Sweep!")


# ------------------------------------------------------------------
# Cinder's Chainfire, cast by the rival on the player - mirrors
# the player's own _resolve_chainfire_cast(): `level_data.damage` to
# the player (there's only one possible target/path occupant in a hero
# fight - see this section's own header comment above), then pulls the
# rival onto the player's own column, stopping one column short of a
# player-cast Frostbound Rupture wall in the way, exactly the same "the damage
# still reaches the full line, only the physical landing spot is
# blocked" split the player's own copy uses.
# ------------------------------------------------------------------

func _cast_enemy_chainfire(enemy: Dictionary, level_data: Dictionary) -> void:
	var damage: float = float(level_data.get("damage", 0))
	# The chain reaches the whole line from the rival's own column to
	# the player's - a guard standing anywhere along that path can
	# still be caught in it, same as every enemy along the player's own
	# Chainfire's path. Read BEFORE the rival's own pull below moves
	# it off "enemy["pos_index"]".
	var from_col: int = enemy["pos_index"]
	var to_col: int = _hero_pos_index

	var chain_direction: int = _step_toward(enemy["pos_index"], _hero_pos_index)
	var landing_pos: int = enemy["pos_index"]
	while chain_direction != 0 and landing_pos != _hero_pos_index:
		var next_pos: int = landing_pos + chain_direction
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		landing_pos = next_pos

	_show_message_over_hero("Chainfire!")
	# The player can't act until the rival has landed - same as its The
	# Sunken One.
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var node: Control = enemy["node"]
	var on_landed := func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		_move_enemy(enemy, landing_pos)
		apply_damage(damage)
		# The standard splash hit-flash (see _apply_splash_damage()).
		_flash_bounce_hit(hero_image)
		_deal_line_aoe_damage_to_guards(from_col, to_col, damage, true)
		_deal_line_aoe_damage_to_bear(from_col, to_col, damage, true)
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	# Facing the way it swings (hero art faces right natively).
	if chain_direction != 0 and is_instance_valid(node):
		node.flip_h = chain_direction < 0
	var landing := Vector2(_index_to_x(landing_pos), _creature_top_y(node.size.y)) if is_instance_valid(node) else Vector2.ZERO
	_play_chainfire(node, _enemy_hero_static, hero_image, landing, on_landed)


# ------------------------------------------------------------------
# Cinder's Kindled Resolve (passive) - mirrors the player's own
# _kindled_resolve_stack_turns/_get_kindled_resolve_level_data()/
# _apply_kindled_resolve_stack()/_tick_kindled_resolve_stacks()/
# _apply_kindled_resolve_regen().
# ------------------------------------------------------------------

## Kindled Resolve's level data for whatever level the rival has it at
## right now - {} if it isn't learned at all (level 0), the same "empty
## means locked" convention every other auto-triggered skill's own
## _get_*_level_data() helper uses.
func _get_enemy_kindled_resolve_level_data() -> Dictionary:
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "kindled_resolve")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("kindled_resolve")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


func _enemy_kindled_resolve_bonus_armor() -> float:
	if _enemy_kindled_resolve_stack_turns.is_empty():
		return 0.0
	var level_data: Dictionary = _get_enemy_kindled_resolve_level_data()
	if level_data.is_empty():
		return 0.0
	return _enemy_kindled_resolve_stack_turns.size() * float(level_data.get("bonus_armor_per_stack", 0.0))


func _apply_enemy_kindled_resolve_stack() -> void:
	var level_data: Dictionary = _get_enemy_kindled_resolve_level_data()
	if level_data.is_empty():
		return

	var max_stacks: int = int(level_data.get("max_stacks", 0))
	if _enemy_kindled_resolve_stack_turns.size() >= max_stacks:
		_enemy_kindled_resolve_stack_turns.pop_front()
	_enemy_kindled_resolve_stack_turns.append(int(level_data.get("duration", 0)))


func _tick_enemy_kindled_resolve_stacks() -> void:
	for i in range(_enemy_kindled_resolve_stack_turns.size()):
		_enemy_kindled_resolve_stack_turns[i] -= 1
	_enemy_kindled_resolve_stack_turns = _enemy_kindled_resolve_stack_turns.filter(func(turns_left): return turns_left > 0)


func _apply_enemy_kindled_resolve_regen() -> void:
	var level_data: Dictionary = _get_enemy_kindled_resolve_level_data()
	if level_data.is_empty() or _enemy_kindled_resolve_stack_turns.is_empty():
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty():
		return

	var max_hp: float = _enemy_hero_effective_max_hp(boss)
	var heal_amount: float = _enemy_kindled_resolve_stack_turns.size() * float(level_data.get("bonus_hp_regen_per_stack", 0.0))
	boss["current_hp"] = minf(max_hp, float(boss.get("current_hp", 0.0)) + heal_amount)


# ------------------------------------------------------------------
# Cinder's ultimate, Cinderbomb, cast by the rival - mirrors the
# player's own _cinderbomb field/_resolve_cinderbomb_cast()/_tick_cinderbomb()/
# _despawn_cinderbomb(). There's only one possible initial-AoE target in a
# hero fight (the player), so this collapses the "every OTHER enemy
# within radius" splash to a single hit, same simplification every other
# rival AoE cast already uses.
# ------------------------------------------------------------------

func _cast_enemy_cinderbomb(enemy: Dictionary, level_data: Dictionary) -> void:
	var pos_index: int = _hero_pos_index
	var cast_damage: float = float(level_data.get("cast_damage", 0))
	var radius: int = int(level_data.get("radius", 0))
	_show_message_over_hero("Cinderbomb!")
	# The player can't act until the barrel has burst - same as the
	# rival's The Sunken One.
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var on_explode := func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		if _distance(_hero_pos_index, pos_index) <= radius:
			apply_damage(cast_damage)
			# The standard splash hit-flash (see _apply_splash_damage()).
			_flash_bounce_hit(hero_image)
		# Planted at the player's own position at cast time - a guard
		# there (or nearby) takes the same initial burst.
		_deal_aoe_damage_to_guards(pos_index, radius, cast_damage, true)
		_deal_aoe_damage_to_bear(pos_index, radius, cast_damage, true)
		_shake_screen()

		_despawn_enemy_cinderbomb()
		_enemy_cinderbomb = {
			"pos_index": pos_index,
			"radius": radius,
			"damage_per_turn": float(level_data.get("damage_per_turn", 0)),
			"turns_remaining": int(level_data.get("duration", 0)),
			"duration_pending_start": true,
			"node": _spawn_cinderbomb_marker(pos_index, radius),
		}
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	_throw_cinderbomb(enemy.get("node"), _enemy_hero_static, hero_image, pos_index, radius, on_explode)


## Ticks the rival's planted Cinderbomb's duration down once per End Turn,
## same timing (and same "the casting turn doesn't count" skip) as every
## other duration-based buff - dealing this level's own damage_per_turn
## to the player whenever they're within radius columns of the FIXED
## position it was planted at (not re-checked against the player's
## current position - same as the player's own copy), on every tick that
## actually counts against the duration. A no-op while no cinderbomb is
## planted.
func _tick_enemy_cinderbomb() -> void:
	if _enemy_cinderbomb.is_empty():
		return

	if _enemy_cinderbomb.get("duration_pending_start", false):
		_enemy_cinderbomb["duration_pending_start"] = false
		return

	var pos_index: int = int(_enemy_cinderbomb["pos_index"])
	var radius: int = int(_enemy_cinderbomb["radius"])
	var damage_per_turn: float = float(_enemy_cinderbomb["damage_per_turn"])
	if _distance(_hero_pos_index, pos_index) <= radius:
		apply_damage(damage_per_turn)
		# The standard splash hit-flash (see _apply_splash_damage()).
		_flash_bounce_hit(hero_image)
	# Centered on the same FIXED planted position as the check above -
	# a guard can be in range independently of whether the player
	# himself currently is.
	_deal_aoe_damage_to_guards(pos_index, radius, damage_per_turn, true)
	_deal_aoe_damage_to_bear(pos_index, radius, damage_per_turn, true)

	_enemy_cinderbomb["turns_remaining"] = int(_enemy_cinderbomb["turns_remaining"]) - 1
	if int(_enemy_cinderbomb["turns_remaining"]) <= 0:
		_despawn_enemy_cinderbomb()


## Removes whatever cinderbomb the rival currently has planted, if any -
## used both when a fresh cast replaces one still active and when its
## duration runs out, same reasoning as the player's own _despawn_
## cinderbomb(). Scene teardown at battle end frees the node implicitly
## either way; also called from _reset_enemy_hero_state() so a marker
## from a PREVIOUS hero fight never lingers into a new one.
func _despawn_enemy_cinderbomb() -> void:
	if _enemy_cinderbomb.is_empty():
		return
	_dismiss_cinderbomb_marker(_enemy_cinderbomb.get("node"))
	_enemy_cinderbomb = {}


# ------------------------------------------------------------------
# Raze's Double Trouble, cast by the rival - mirrors the player's own
# _cast_double_trouble(): `level_data.damage` to the player, straight
# ahead of the rival in whichever direction it's currently facing. The
# directional "is the player actually ahead" check already happened
# before this was ever picked as a candidate (see _enemy_skill_in_
# range()'s own "double_trouble" case), so by the time this runs it's
# guaranteed to land - a plain hit, same as every other rival nuke.
# ------------------------------------------------------------------

func _cast_enemy_double_trouble(enemy: Dictionary, level_data: Dictionary) -> void:
	var damage: float = float(level_data.get("damage", 0))
	apply_damage(damage)
	# Directional, not a radius - same "ahead of the caster, in whichever
	# direction it's facing" cone _enemy_skill_in_range()'s own
	# Double Trouble case already checks against the player.
	var direction: int = -1 if bool(enemy["node"].flip_h) else 1
	_deal_directional_aoe_damage_to_guards(int(enemy["pos_index"]), direction, int(level_data.get("range", 0)), damage)
	_deal_directional_aoe_damage_to_bear(int(enemy["pos_index"]), direction, int(level_data.get("range", 0)), damage)
	# Same particle cone the player's own cast gets (see
	# _play_double_trouble_effect()'s own comment), bursting from the
	# rival's own node instead of hero_image.
	_play_double_trouble_effect(enemy["node"], direction, int(level_data.get("range", 0)))
	_show_message_over_hero("Double Trouble!")


# ------------------------------------------------------------------
# Raze's Blast Hopper, cast by the rival - mirrors the player's
# own _activate_blast_hopper(): hops `jump_distance` columns in
# whichever direction the rival is currently facing (walked one column
# at a time here, stopping early at the board edge or a player-cast Frostbound
# Rupture wall - Raze's own range_type is always "Range", so this
# never needs the melee "stop on top of an enemy" rule the way a
# point-blank hero's own copy would), then - on landing - deals damage
# and stuns the player if they're within `radius` columns of wherever it
# ends up. Never "fails" for lack of a target, same as the player's own
# copy - the hop itself always happens.
# ------------------------------------------------------------------

func _cast_enemy_blast_hopper(enemy: Dictionary, level_data: Dictionary) -> void:
	var jump_distance: int = int(level_data.get("jump_distance", 0))
	var direction: int = -1 if bool(enemy["node"].flip_h) else 1

	var landing_pos: int = enemy["pos_index"]
	for i in range(jump_distance):
		var next_pos: int = landing_pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		landing_pos = next_pos

	var old_x: float = enemy["node"].position.x
	_move_enemy(enemy, landing_pos)
	_play_blast_hop_effect(enemy["node"], old_x, direction, int(level_data.get("radius", 0)))

	var radius: int = int(level_data.get("radius", 0))
	var damage: float = float(level_data.get("damage", 0))
	if _distance(_hero_pos_index, landing_pos) <= radius:
		apply_damage(damage)
		if _recruited.get("current_hp", 0) > 0:
			_player_stun_turns_left = int(level_data.get("stun_turns", 0))
	# Centered on the landing spot, same as the check above - an
	# guard can be in range independently of whether the player
	# himself currently is.
	_deal_aoe_damage_to_guards(landing_pos, radius, damage)
	_deal_aoe_damage_to_bear(landing_pos, radius, damage)

	_show_message_over_hero("Blast Hopper!")


# ------------------------------------------------------------------
# Raze's Three Cheers, cast by the rival - mirrors the player's own
# _resolve_three_cheers_cast(): fires this level's own `shots` count of
# separately-rolled hits at the player (each _roll_enemy_hero_damage()
# times damage_pct), each shot ALSO stacking armor_reduction_per_shot
# onto _player_armor_reduction - a battle-local runtime value folded
# into _hero_armor() as a straight subtraction, mirroring the player-
# side per-enemy "armor_reduction" field - so a later shot in the SAME
# volley already lands harder than the first, having shredded some of
# the player's armor away already. Stops early if the player dies
# partway through. The whole stack's own duration (this level's own
# `duration`) is only set once, after the last shot connects, same "the
# casting round is never counted against it for free" reasoning
# _tick_player_turn_start_effects() already follows for every other
# duration-based effect.
# ------------------------------------------------------------------

func _cast_enemy_three_cheers(enemy: Dictionary, level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_three_cheers_on_bear(enemy, level_data)
		return
	var shots: int = int(level_data.get("shots", 3))
	var damage_pct: float = float(level_data.get("damage_pct", 0))
	var armor_reduction_per_shot: float = float(level_data.get("armor_reduction_per_shot", 0))

	for i in range(shots):
		if _recruited.get("current_hp", 0) <= 0:
			break
		var shot_damage: float = _roll_enemy_hero_damage(enemy) * damage_pct
		apply_damage(shot_damage)
		# Same staggered impact-spark volley the player's own shots get
		# (see _play_three_cheers_shot_effect()'s own comment) - purely
		# position-based, so it works the same regardless of which side
		# is casting.
		_play_three_cheers_shot_effect(_hero_pos_index, i * 0.11, enemy["node"])
		if _recruited.get("current_hp", 0) <= 0:
			break
		_player_armor_reduction += armor_reduction_per_shot

	if _recruited.get("current_hp", 0) > 0:
		_player_armor_reduction_turns_left = int(level_data.get("duration", 0))

	_show_message_over_hero("Three Cheers!")


# ------------------------------------------------------------------
# The Last Empress's passive, Empress's Will, on the rival - mirrors the player's own
# _get_empress_will_level_data(). Never a scored candidate of its own (see
# EnemySkillAI's own header comment) - its bonuses only ever reach Imperial
# Guard/Luring Gaze/a plain Attack through _build_enemy_ai_
# context()'s own "empress_will_*" fields. Its AoE splash (aoe_damage_pct/
# radius) never has an actual second target to reach in a real hero fight
# (there's only ever the one player to hit - same "no cleave" collapse
# Abyssal Spasm's/The Sunken One's/Sweep's own rival copies already have,
# see _cast_enemy_abyssal_spasm()'s own docstring), so unlike the player's
# own _apply_empress_will_cleave(), its splash off her plain Attack reaches
# the player's own guards and Elderwild Companion near him (see
# _apply_enemy_empress_will_splash()) - the player himself is the struck
# target, never hit twice. "empress_will_aoe_damage_pct" also feeds
# EnemySkillAI's own scoring.
# ------------------------------------------------------------------

## Empress's Will's level data for whatever level the rival has it at right
## now - {} if it isn't learned at all (level 0), the same "empty means
## locked" convention every other auto-triggered skill's own _get_enemy_
## *_level_data() helper uses.
func _get_enemy_empress_will_level_data() -> Dictionary:
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "empress's_will")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("empress's_will")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


## The rival's Empress's Will splash off her plain Attack on the player - the
## mirror of the player's own _apply_empress_will_cleave(): this level's
## aoe_damage_pct of `attack_damage` (the Attack's raw, pre-mitigation
## roll) splashed onto every one of the player's guards and his
## Elderwild Companion within this level's radius of the player (the struck
## target, never hit twice), each mitigated by its own armor (the
## guards via the hero's, the bear via its own - see
## _deal_aoe_damage_to_guards()/_deal_aoe_damage_to_bear()) and
## given the standard splash hit-flash. A no-op while the skill isn't
## learned. Only her own Attack splashes - her guards' attacks
## (_enemy_guards_turn()) don't.
func _apply_enemy_empress_will_splash(attack_damage: float) -> void:
	var level_data: Dictionary = _get_enemy_empress_will_level_data()
	if level_data.is_empty():
		return
	var splash_damage: float = attack_damage * float(level_data.get("aoe_damage_pct", 0.0))
	if splash_damage <= 0.0:
		return
	var radius: int = int(level_data.get("radius", 0))
	_deal_aoe_damage_to_guards(_hero_pos_index, radius, splash_damage, true)
	_deal_aoe_damage_to_bear(_hero_pos_index, radius, splash_damage, true)


## The rival Kaelen Varr's Pull of the Abyss cleave off his empowered plain Attack
## on the player - the mirror of the player's own
## _apply_pull_of_the_abyss_cleave(): `level_data`'s cleave_damage_pct of
## `attack_damage` (the Attack's raw, pre-mitigation roll, Pull of the Abyss's
## own bonus already folded in) to every one of the player's guards
## and his Elderwild Companion within cleave_columns of the player (the struck
## target, never hit twice), each mitigated by its own armor and given
## the standard splash hit-flash.
func _apply_enemy_pull_of_the_abyss_cleave(attack_damage: float, level_data: Dictionary) -> void:
	var cleave_damage: float = attack_damage * float(level_data.get("cleave_damage_pct", 0.0))
	if cleave_damage <= 0.0:
		return
	var radius: int = int(level_data.get("cleave_columns", 1))
	_deal_aoe_damage_to_guards(_hero_pos_index, radius, cleave_damage, true)
	_deal_aoe_damage_to_bear(_hero_pos_index, radius, cleave_damage, true)


## How many of the player's own guards, plus his Elderwild Companion, stand
## within `radius` columns of him - what a rival's splash/cleave off an
## Attack on the player could also reach. Feeds the AI's own scoring
## (e.g. Pull of the Abyss's cleave target count).
func _count_player_allies_near_hero(radius: int) -> int:
	var count: int = 0
	for guard in _guards:
		if _distance(guard["pos_index"], _hero_pos_index) <= radius:
			count += 1
	if _is_bear_alive() and _distance(_bear["pos_index"], _hero_pos_index) <= radius:
		count += 1
	return count


# ------------------------------------------------------------------
# The Last Empress's Imperial Guard, cast by the rival - the same skill as
# the player's own (see the block above _guards and _activate_imperial_
# guard()), played from the boss's side: _cast_enemy_imperial_guard()/
# _tick_enemy_imperial_guard()/_enemy_guards_turn()/_end_enemy_imperial_
# guard()/_deal_damage_to_enemy_guard()/_kill_enemy_guard(). The guards are
# the same walking units - same art, labels and reactions (see
# _spawn_guard()) - kept in _enemy_guards, and fight the player's side: the
# hero, his Elderwild Companion and his own guards.
# ------------------------------------------------------------------

## Raises the rival's guards around the player-side unit closest to the
## boss - the hero, his Elderwild Companion or one of his own guards - from
## anywhere on the board. One rises on the side of that unit facing the
## boss, one on its far side (both clamped to the grid), and any beyond
## those first two double up randomly on one of the same two columns. Every
## guard starts out facing the unit it was raised around. Recasting
## replaces the set outright, like the player's.
func _cast_enemy_imperial_guard(enemy: Dictionary, level_data: Dictionary) -> void:
	_end_enemy_imperial_guard()

	var empress_will_level_data: Dictionary = _get_enemy_empress_will_level_data()

	var caster_pos: int = int(enemy["pos_index"])
	var anchor_pos: int = _hero_pos_index
	var anchor_distance: int = _distance(caster_pos, _hero_pos_index)
	if _is_bear_alive() and _distance(caster_pos, _bear["pos_index"]) < anchor_distance:
		anchor_pos = int(_bear["pos_index"])
		anchor_distance = _distance(caster_pos, anchor_pos)
	for guard in _guards:
		if _distance(caster_pos, guard["pos_index"]) < anchor_distance:
			anchor_pos = int(guard["pos_index"])
			anchor_distance = _distance(caster_pos, anchor_pos)

	var near_side: int = _step_toward(anchor_pos, caster_pos)
	if near_side == 0:
		near_side = -1
	var near_pos: int = clampi(anchor_pos + near_side, 0, GRID_COLUMNS - 1)
	var far_pos: int = clampi(anchor_pos - near_side, 0, GRID_COLUMNS - 1)

	var guards_count: int = int(level_data.get("guards", 3)) + int(empress_will_level_data.get("extra_guard", 0))
	var guard_hp: float = _enemy_hero_effective_max_hp(enemy) * float(level_data.get("hp_pct", 0.0))

	for i in range(guards_count):
		var pos: int
		if i == 0:
			pos = near_pos
		elif i == 1:
			pos = far_pos
		else:
			pos = near_pos if randf() < 0.5 else far_pos
		var facing: int = _step_toward(pos, anchor_pos)
		if facing == 0:
			facing = -near_side
		_enemy_guards.append(_spawn_guard(pos, facing, guard_hp, true))

	_enemy_guard_damage_pct = float(level_data.get("damage_pct", 0.0)) + float(empress_will_level_data.get("guardians_damage_bonus_pct", 0.0))
	_enemy_guards_turns_remaining = int(level_data.get("duration", 0)) + int(empress_will_level_data.get("guard_duration_bonus", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking (and the guards only start acting) from the turn after (see
	# _enemy_guards_turn()/_tick_enemy_imperial_guard()), same as every
	# other duration-based buff.
	_enemy_guards_duration_pending_start = true

	_show_message_over_hero("Imperial Guard!")


## Ticks the rival's Imperial Guard duration down once per End Turn, same
## timing (and same "the casting turn doesn't count" skip) as every other
## duration-based buff, then ends the effect once it runs out. The guards'
## own actions happen separately, in _enemy_guards_turn(). A no-op once
## every guard has already died in combat, and while none are up at all.
func _tick_enemy_imperial_guard() -> void:
	if _enemy_guards.is_empty():
		return

	if _enemy_guards_duration_pending_start:
		_enemy_guards_duration_pending_start = false
		return

	_enemy_guards_turns_remaining -= 1
	if _enemy_guards_turns_remaining <= 0:
		_end_enemy_imperial_guard()


## The rival's guards act once per turn (see _end_turn(), where they go after
## the player's guards and just before the creeps): each one strikes
## whoever of the player's side shares its column - the hero first, if
## he's there and the rival can see him, then his Elderwild Companion, then
## one of his guards - for `damage_pct` of a freshly-rolled rival Attack. With
## nobody in its column it closes in on the nearest of them, one column a
## turn, turning to face the way it walks. They sit out the casting turn.
func _enemy_guards_turn() -> void:
	if _enemy_guards.is_empty() or _enemy_guards_duration_pending_start:
		return
	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty():
		return

	var can_see_hero: bool = _can_enemy_see_hero()
	for guard in _enemy_guards.duplicate():
		if not is_instance_valid(guard.get("node")):
			continue
		var pos: int = guard["pos_index"]
		var damage: float = _roll_enemy_hero_damage(boss) * _enemy_guard_damage_pct

		var struck: bool = true
		if pos == _hero_pos_index and can_see_hero:
			_enemy_guard_swing(guard)
			apply_damage(damage)
			if _recruited.get("current_hp", 0) <= 0:
				return
		elif _is_bear_alive() and _bear["pos_index"] == pos:
			_enemy_guard_swing(guard)
			_deal_damage_to_bear(damage)
		elif not _guards_at(pos).is_empty():
			_enemy_guard_swing(guard)
			_enemy_attack_guard(_nearest_guard_within(pos, 0), damage)
		else:
			struck = false
		if struck:
			continue

		var target_pos: int = -1
		var target_distance: int = GRID_COLUMNS + 1
		if can_see_hero:
			target_pos = _hero_pos_index
			target_distance = _distance(pos, _hero_pos_index)
		if _is_bear_alive() and _distance(pos, _bear["pos_index"]) < target_distance:
			target_pos = int(_bear["pos_index"])
			target_distance = _distance(pos, target_pos)
		for ally in _guards:
			if _distance(pos, ally["pos_index"]) < target_distance:
				target_pos = int(ally["pos_index"])
				target_distance = _distance(pos, target_pos)
		if target_pos == -1:
			continue
		var direction: int = _step_toward(pos, target_pos)
		if direction == 0:
			continue
		_move_guard(guard, clampi(pos + direction, 0, GRID_COLUMNS - 1), direction)
	_relayout_guards()


## The swing animation of one of the rival's guards - the blow itself is
## resolved by _enemy_guards_turn().
func _enemy_guard_swing(guard: Dictionary) -> void:
	var animator := CreatureAnimator.of(guard["node"])
	if animator != null:
		animator.play_attack(float(guard.get("facing", 1)))


## Ends the rival's Imperial Guard, despawning every surviving guard -
## called both when its duration runs out (_tick_enemy_imperial_guard())
## and defensively at the top of _cast_enemy_imperial_guard() so a recast
## mid-duration never leaks the old set's nodes, and from
## _reset_enemy_hero_state() so a set from a PREVIOUS hero fight never
## lingers into a new one.
func _end_enemy_imperial_guard() -> void:
	for guard in _enemy_guards:
		if is_instance_valid(guard.get("node")):
			guard["node"].queue_free()
		if is_instance_valid(guard.get("hp_label")):
			guard["hp_label"].queue_free()
	_enemy_guards.clear()
	_enemy_guard_damage_pct = 0.0
	_enemy_guards_turns_remaining = 0
	_enemy_guards_duration_pending_start = false


## Applies `amount` of already-mitigated damage to `guard` - the
## rival-side equivalent of the player's own _deal_damage_to_guard(), just
## against _enemy_guards instead of _guards. Called when the player's
## guards or a melee Attack strike one, and from every player AoE that
## sweeps over one. The guard flinches, unless a projectile is still
## flying toward it (see _deferred_hit_node).
func _deal_damage_to_enemy_guard(guard: Dictionary, amount: float, is_critical: bool = false) -> void:
	guard["current_hp"] = float(guard.get("current_hp", 0.0)) - amount
	var node: Variant = guard.get("node")
	if is_instance_valid(node):
		_show_damage_number(node, amount, is_critical)
		var animator := CreatureAnimator.of(node)
		if animator != null and node != _deferred_hit_node:
			animator.play_hit()
	if guard["current_hp"] <= 0:
		_kill_enemy_guard(guard)


## Removes one guard that's died in combat, its body dissolving the way a
## creep's does - the rival-side mirror of the player's own _kill_guard().
## Doesn't end Imperial Guard outright even if this was the last one;
## _tick_enemy_imperial_guard()'s own early-empty check just makes every
## remaining tick a no-op until the duration itself finally runs out.
func _kill_enemy_guard(guard: Dictionary) -> void:
	if is_instance_valid(guard.get("node")):
		CreatureAnimator.spawn_death_ghost(guard["node"], _fx_layer)
		guard["node"].queue_free()
	if is_instance_valid(guard.get("hp_label")):
		guard["hp_label"].queue_free()
	_enemy_guards.erase(guard)
	_relayout_guards()


## The boss's own effective armor for mitigating a hit onto one of its
## guards - base armor plus its own bonuses (Kindled
## Resolve's stack, Wildbond, etc., via _enemy_hero_bonus_armor())
## minus Three Cheers's own shred, same three terms
## _deal_fixed_damage_to_enemy()'s own redirect branch already reads.
## A guard is a copy of the boss, not a separate combatant with its
## own defense stat, so it mitigates exactly as if the boss had taken
## the hit itself.
func _enemy_hero_effective_armor(boss: Dictionary) -> float:
	return float(boss["static"].get("armor", 0)) + _enemy_hero_bonus_armor(boss) - float(boss.get("armor_reduction", 0.0))


## Any player AoE skill that damages the boss over an area should ALSO
## independently hit every surviving enemy guard within that same
## area - the mirror of _deal_aoe_damage_to_guards() for the rival's
## own Imperial Guard. `amount` is the RAW, pre-mitigation damage the AoE
## would deal to the boss - each guard mitigates it separately via
## the boss's own effective armor (_enemy_hero_effective_armor()). A
## no-op while no enemy guards are up or there's no boss to read
## armor from (i.e. outside a hero fight).
## `flash_hits` gives each one hit the same red hit-flash as Lunar
## Ricochet's bounce (_flash_bounce_hit()) - off by default, opted into by
## Abyssal Spasm.
func _deal_aoe_damage_to_enemy_guards(center_pos_index: int, radius: int, amount: float, flash_hits: bool = false) -> void:
	if _enemy_guards.is_empty() or amount <= 0.0:
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty():
		return

	var mitigated: float = _apply_armor_reduction(amount, _enemy_hero_effective_armor(boss))
	for guard in _enemy_guards.duplicate():
		if _distance(guard["pos_index"], center_pos_index) <= radius:
			_deal_damage_to_enemy_guard(guard, mitigated)
			if flash_hits and is_instance_valid(guard.get("node")):
				_flash_bounce_hit(guard["node"])


## The line-shaped equivalent of _deal_aoe_damage_to_enemy_guards()
## above - for The Sunken One's/Chainfire's own "every column between the
## caster and the target, inclusive of both ends" line. Same "amount is
## raw, each guard mitigates it separately via the boss's own
## effective armor" contract.
## `flash_hits` gives each one hit the standard splash hit-flash
## (_flash_bounce_hit()) - off by default, opted into by Chainfire.
func _deal_line_aoe_damage_to_enemy_guards(start_pos_index: int, end_pos_index: int, amount: float, flash_hits: bool = false) -> void:
	if _enemy_guards.is_empty() or amount <= 0.0:
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty():
		return

	var start_col: int = mini(start_pos_index, end_pos_index)
	var end_col: int = maxi(start_pos_index, end_pos_index)
	var mitigated: float = _apply_armor_reduction(amount, _enemy_hero_effective_armor(boss))
	for guard in _enemy_guards.duplicate():
		var pos: int = guard["pos_index"]
		if pos >= start_col and pos <= end_col:
			_deal_damage_to_enemy_guard(guard, mitigated)
			if flash_hits and is_instance_valid(guard.get("node")):
				_flash_bounce_hit(guard["node"])


## The directional-cone equivalent of the two AoE-shape helpers above -
## for the player's own Double Trouble facing-based cone. Same "amount is
## raw, each guard mitigates it separately via the boss's own
## effective armor" contract.
func _deal_directional_aoe_damage_to_enemy_guards(origin_pos_index: int, direction: int, range_columns: int, amount: float) -> void:
	if _enemy_guards.is_empty() or amount <= 0.0:
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty():
		return

	var mitigated: float = _apply_armor_reduction(amount, _enemy_hero_effective_armor(boss))
	for guard in _enemy_guards.duplicate():
		var ahead: int = (guard["pos_index"] - origin_pos_index) * direction
		if ahead >= 0 and ahead <= range_columns:
			_deal_damage_to_enemy_guard(guard, mitigated)


# ------------------------------------------------------------------
# The Last Empress's Shackles, cast by the rival on the player - mirrors the
# player's own _resolve_shackles_cast(): this level's own `damage`
# (through normal armor mitigation, via apply_damage()) plus a root for
# `root_turns` of the player's own turns (_player_root_turns_left, the
# same shared field Thornbind's/Mother's Grasp's own root already use) -
# unlike Thornbind, no silence/DoT fields are touched at all, so (per the
# design doc's own explicit "Shackles is not a stun" instruction) the
# player can still attack/cast skills while rooted, just not move. Only
# roots if the hit actually left the player alive.
# ------------------------------------------------------------------

func _cast_enemy_shackles(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_shackles_on_bear(level_data)
		return
	apply_damage(float(level_data.get("damage", 0)))
	if _recruited.get("current_hp", 0) > 0:
		_player_root_turns_left = int(level_data.get("root_turns", 0))
		_player_shackled = true
		_refresh_shackles()
	_show_message_over_hero("Shackles!")


# ------------------------------------------------------------------
# The Last Empress's ultimate, Luring Gaze, cast by the rival - mirrors
# the player's own _cast_luring_gaze(): stuns (_player_stun_turns_
# left, the same shared field Barbed Lunge's/Drowned Surge's/Blast Hopper's own
# stun already use) and shreds the armor (_player_armor_reduction/
# _player_armor_reduction_turns_left, the same per-instance runtime
# fields Three Cheers's own shred uses - stacking additively with any
# already there, but refreshing, not adding to, the turns left) of the
# player, if they're within this level's own radius of the rival's
# CURRENT position - there's only one possible target in a hero fight, so
# this collapses to a single conditional hit rather than a loop over
# multiple enemies, same simplification every other rival AoE cast
# already uses. Purely offensive - no damage of its own, and nothing
# about the rival itself changes (it and its guards can still move/
# attack normally the whole time).
# ------------------------------------------------------------------

func _cast_enemy_luring_gaze(enemy: Dictionary, level_data: Dictionary) -> void:
	var radius: int = int(level_data.get("radius", 0))
	# Whoever the gaze actually catches: the thread runs to each of them.
	var gazed: Array = []
	var player_gazed: bool = false
	if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
		_player_stun_turns_left = int(level_data.get("stun_turns", 0))
		_player_armor_reduction += float(level_data.get("armor_reduction", 0))
		# +1: ticks at the start of the player's turn, which comes before the
		# stunned turn's enemy phase, so it must outlast the last stunned turn.
		_player_armor_reduction_turns_left = int(level_data.get("stun_turns", 0)) + 1
		_player_luring_gaze_entranced = true
		_player_venom_paralyzed = false
		gazed.append(hero_image)
		player_gazed = true
	# The player's own Elderwild Companion within the same radius falls asleep
	# too - same stun and armor shred, the armor's turns refreshed (not
	# added to) the same way the player's own are.
	if _is_bear_alive() and _distance(enemy["pos_index"], _bear["pos_index"]) <= radius:
		_stun_bear(int(level_data.get("stun_turns", 0)))
		if _is_bear_alive():
			_bear["armor_reduction"] = float(_bear.get("armor_reduction", 0.0)) + float(level_data.get("armor_reduction", 0))
			_bear["armor_reduction_turns_left"] = int(level_data.get("stun_turns", 0)) + 1
			# Set after _stun_bear(), which clears it for any other stun.
			_bear["luring_gaze_entranced"] = true
			gazed.append(_bear.get("node"))

	# Heavier vignette when it's the player himself being gazed at.
	_play_luring_gaze(enemy.get("node"), gazed, player_gazed)
	_refresh_luring_gaze_trances()
	_show_message_over_hero("Luring Gaze!")


# ------------------------------------------------------------------
# Dreadlure's Hunting Instinct, cast by the rival - mirrors the player's own
# _activate_hunting_instinct()/_hunting_instinct_move_target()/_tick_
# hunting_instinct()/_end_hunting_instinct(). Arms the buff exactly the
# same way (doesn't move the rival itself when cast); only its own
# fallback movement (_enemy_hero_turn()'s own "not hero_hidden and not
# rooted" tail, once no skill/attack is available) actually reads it,
# same "only the NEXT normal move changes" shape the player's own copy
# has in _hero_move().
# ------------------------------------------------------------------

func _cast_enemy_hunting_instinct(level_data: Dictionary) -> void:
	_enemy_hunting_instinct_bonus_movement = int(level_data.get("bonus_movement", 0))
	_enemy_hunting_instinct_charge_damage_pct = float(level_data.get("charge_damage_pct", 0.0))
	_enemy_hunting_instinct_turns_remaining = int(level_data.get("duration", 0))
	# The casting turn itself doesn't count - duration only starts
	# ticking from the turn after (see _tick_enemy_hunting_instinct()),
	# same as every other duration-based buff. The bonus itself is
	# already live the instant this returns.
	_enemy_hunting_instinct_duration_pending_start = true

	_show_message_over_hero("Hunting Instinct!")


## Hunting Instinct's own movement rule, on the rival's side - mirrors the
## player's own _hunting_instinct_move_target() exactly, just stopping on
## the PLAYER's own column instead of searching _enemies for one (there's
## only ever the one possible "enemy" to stop on in a hero fight - see
## this section's own header comment). Walks up to `distance` columns
## from `start` in `direction`, stopping early at the board edge, a
## player-cast Frostbound Rupture wall, OR the player's own column - regardless
## of the rival's own type, same "stop on top of an enemy" rule every
## other rival gap-closer (Blast Hopper's hop, Chainfire's pull)
## already follows. Returns both the landing column and whether it
## actually stopped on the player, for the caller to deal Guardian
## Instinct's own charge_damage to.
func _enemy_hunting_instinct_move_target(start: int, direction: int, distance: int) -> Dictionary:
	var pos: int = start
	var hit_player: bool = false

	for i in range(distance):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos

		if pos == _hero_pos_index:
			hit_player = true
			break

	return {"pos": pos, "hit_player": hit_player}


func _tick_enemy_hunting_instinct() -> void:
	if _enemy_hunting_instinct_turns_remaining <= 0:
		return

	if _enemy_hunting_instinct_duration_pending_start:
		_enemy_hunting_instinct_duration_pending_start = false
		return

	_enemy_hunting_instinct_turns_remaining -= 1
	if _enemy_hunting_instinct_turns_remaining <= 0:
		_end_enemy_hunting_instinct()


func _end_enemy_hunting_instinct() -> void:
	_enemy_hunting_instinct_turns_remaining = 0
	_enemy_hunting_instinct_bonus_movement = 0
	_enemy_hunting_instinct_charge_damage_pct = 0.0
	_enemy_hunting_instinct_duration_pending_start = false


# ------------------------------------------------------------------
# Dreadlure's Paralytic Venom, cast by the rival - mirrors the player's
# own _cast_paralytic_venom(): this level's own `damage` (through normal
# armor mitigation, via apply_damage()) plus a stun (_player_stun_turns_
# left, the same shared field Barbed Lunge's/Drowned Surge's/Luring Gaze's own
# stun already use) for `stun_turns` of the player's own turns, if
# they're within `radius` columns of the rival's CURRENT position -
# there's only one possible target in a hero fight, so this collapses to
# a single conditional hit rather than a loop over multiple enemies, same
# simplification every other self-centered rival AoE cast already uses
# (see _cast_enemy_mothers_grasp()'s own docstring). Only stuns if the hit
# actually left the player alive. Centered on the caster's own column,
# same as the check above - a guard/the player's own Elderwild Companion can
# be in range independently of whether the player himself currently is,
# same "one-time hit for whatever's caught in the burst" reasoning
# _cast_enemy_sweep()'s own copy already follows (guards have
# no stun of their own to carry, same as they have no root/DoT in
# Mother's Grasp's own copy).
# ------------------------------------------------------------------

func _cast_enemy_paralytic_venom(enemy: Dictionary, level_data: Dictionary) -> void:
	var radius: int = int(level_data.get("radius", 0))
	var damage: float = float(level_data.get("damage", 0))
	# Everyone the wave will hit, captured (and the slam played) before
	# any damage lands - a kill frees its node.
	var hit_nodes: Array = []
	if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
		hit_nodes.append(hero_image)
	for guard in _guards:
		if _distance(guard["pos_index"], enemy["pos_index"]) <= radius:
			hit_nodes.append(guard.get("node"))
	if _is_bear_alive() and _distance(_bear["pos_index"], enemy["pos_index"]) <= radius:
		hit_nodes.append(_bear.get("node"))
	_play_paralytic_venom(enemy.get("node"), radius, hit_nodes)

	if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
		apply_damage(damage)
		if _recruited.get("current_hp", 0) > 0:
			_player_stun_turns_left = int(level_data.get("stun_turns", 0))
			_player_venom_paralyzed = _player_stun_turns_left > 0
			_player_luring_gaze_entranced = false
	_deal_aoe_damage_to_guards(enemy["pos_index"], radius, damage)
	# The player's own Elderwild Companion caught in it is stunned too, if it
	# survived the hit - same "only a hit that left it alive" rule as
	# the player's own stun above (_stun_bear() is a no-op on a dead bear).
	var bear_in_venom: bool = _is_bear_alive() and _distance(_bear["pos_index"], enemy["pos_index"]) <= radius
	_deal_aoe_damage_to_bear(enemy["pos_index"], radius, damage)
	if bear_in_venom:
		_stun_bear(int(level_data.get("stun_turns", 0)))
		if _is_bear_alive():
			_bear["venom_paralyzed"] = true

	_show_message_over_hero("Paralytic Venom!")


# ------------------------------------------------------------------
# Dreadlure's passive, Might of the Deep, on the rival - mirrors the
# player's own _get_might_of_the_deep_level_data()/_maybe_consume_might_of_
# the_deep_stack()/_apply_might_of_the_deep_knockback(). Never a scored
# candidate of its own (see EnemySkillAI's own header comment) - its
# progression only ever reaches Hunting Instinct/Paralytic Venom/
# Deathlight Lure/a plain Attack through _build_enemy_ai_context()'s own
# "might_*" fields, and its actual bonus damage/knockback only ever land
# through _resolve_enemy_hero_attack()'s own plain-Attack path, same
# "only a real Attack builds/consumes the stack" rule the player's own
# copy follows.
# ------------------------------------------------------------------

func _get_enemy_might_of_the_deep_level_data() -> Dictionary:
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "might_of_the_deep")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("might_of_the_deep")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


func _maybe_consume_enemy_might_of_the_deep_stack() -> Dictionary:
	var level_data: Dictionary = _get_enemy_might_of_the_deep_level_data()
	if level_data.is_empty():
		return {}

	_enemy_might_of_the_deep_attack_count += 1
	if _enemy_might_of_the_deep_attack_count < int(level_data.get("attacks_required", 1)):
		return {}

	_enemy_might_of_the_deep_attack_count = 0
	return level_data


## Knocks the player back this level's own `knockback` columns, away from
## the rival (its own distance-to-player direction, falling back to its
## own facing on the rare column-share tie, same "still shove SOMEWHERE"
## reasoning Barbed Lunge's own leap uses for the mirror-image case) - stopping
## early at the board edge or a player-cast Frostbound Rupture wall. Repositions
## instantly via _hero_pos_index/_update_hero_position(), the same path
## every other player-repositioning effect in this file uses.
func _apply_enemy_might_of_the_deep_knockback(enemy: Dictionary, level_data: Dictionary) -> void:
	var knockback_columns: int = int(level_data.get("knockback", 0))
	var direction: int = _step_toward(enemy["pos_index"], _hero_pos_index)
	if direction == 0:
		direction = -1 if bool(enemy["node"].flip_h) else 1
	var pos: int = _hero_pos_index

	for i in range(knockback_columns):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos

	if pos != _hero_pos_index:
		_hero_pos_index = pos
		_update_hero_position()


# ------------------------------------------------------------------
# Dreadlure's ultimate, Deathlight Lure, cast by the rival on the player -
# mirrors the player's own _resolve_deathlight_lure_cast(): reduces the
# player's own armor by this level's own `armor_reduction`
# (_player_armor_reduction, the same shared runtime field Three Cheers's
# own shred/Luring Gaze's own shred already use - stacking
# additively with any already there) and marks him with `bonus_damage_
# pct` (_player_deathlight_lure_bonus_pct, read by apply_damage() to boost
# every hit he takes from the rival's own attacks/skills - overwritten
# outright on recast, not stacked). Both share _player_armor_reduction_
# turns_left as their own turns-left counter, same "share the shred's own
# timer" convention the player-side copy uses. There's only one possible
# target in a hero fight, so - unlike the player's own copy, which needs
# to pick one among several enemies - this needs no separate targeting
# step at all, same simplification Thornbind's/Drowned Surge's own enemy-side
# copies already use. Deals no damage of its own - a pure debuff.
# ------------------------------------------------------------------

func _cast_enemy_deathlight_lure(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_deathlight_lure_on_bear(level_data)
		return
	_player_armor_reduction += float(level_data.get("armor_reduction", 0))
	_player_deathlight_lure_bonus_pct = float(level_data.get("bonus_damage_pct", 0.0))
	_player_armor_reduction_turns_left = int(level_data.get("duration", 0))
	_reveal_player_hero()

	_play_deathlight_lure(_get_hero_fight_boss().get("node"), hero_image)
	_refresh_deathlight_lure()
	_show_message_over_hero("Deathlight Lure!")


# ------------------------------------------------------------------
# Solara's Fallen Grace, cast by the rival - mirrors the player's own
# _cast_fallen_grace(): this level's own `damage` (through normal armor
# mitigation, via apply_damage()) if the player is within `radius`
# columns of the rival's CURRENT position - there's only one possible
# target in a hero fight, so this collapses to a single conditional hit
# rather than a loop over multiple enemies, same simplification every
# other self-centered rival AoE cast already uses (see
# _cast_enemy_mothers_grasp()'s own docstring). No stun of its own - purely
# a damage nuke, same as the player-side copy. Centered on the caster's
# own column, same as the check above - a guard/the player's own
# Elderwild Companion can be in range independently of whether the player himself
# currently is, same "one-time hit for whatever's caught in the burst"
# reasoning _cast_enemy_sweep()'s own copy already follows.
# ------------------------------------------------------------------

func _cast_enemy_fallen_grace(enemy: Dictionary, level_data: Dictionary) -> void:
	var radius: int = int(level_data.get("radius", 0))
	var damage: float = float(level_data.get("damage", 0))
	# Arrows at every unit about to be hit, launched before the damage
	# lands (a kill frees its node).
	var star_nodes: Array = []
	if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
		star_nodes.append(hero_image)
	for guard in _guards:
		if _distance(guard["pos_index"], enemy["pos_index"]) <= radius:
			star_nodes.append(guard.get("node"))
	if _is_bear_alive() and _distance(_bear["pos_index"], enemy["pos_index"]) <= radius:
		star_nodes.append(_bear.get("node"))
	_play_arrow_volley(enemy.get("node"), star_nodes)

	if _distance(enemy["pos_index"], _hero_pos_index) <= radius:
		apply_damage(damage)
	_deal_aoe_damage_to_guards(enemy["pos_index"], radius, damage)
	_deal_aoe_damage_to_bear(enemy["pos_index"], radius, damage)

	_show_message_over_hero("Fallen Grace!")


# ------------------------------------------------------------------
# Solara's Hope of the Fallen, cast by the rival on the player - mirrors the
# player's own _resolve_hope_of_the_fallen_cast(): this level's own base_damage
# plus bonus_per_column for every column between the rival and the
# player at the moment it's cast (through normal armor mitigation, via
# apply_damage()), then stuns the player (_player_stun_turns_left, the
# same shared field Barbed Lunge's/Drowned Surge's/Luring Gaze's own stun
# already use) for this level's own stun_turns, only if the hit left him
# alive. There's only one possible target in a hero fight, so - unlike
# the player's own copy, which needs a separate targeting click - this
# needs no separate targeting step at all, same simplification Thornbind's/
# Drowned Surge's own enemy-side copies already use.
# ------------------------------------------------------------------

func _cast_enemy_hope_of_the_fallen(enemy: Dictionary, level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_hope_of_the_fallen_on_bear(enemy, level_data)
		return
	var distance: int = _distance(enemy["pos_index"], _hero_pos_index)
	var damage: float = float(level_data.get("base_damage", 0)) + float(level_data.get("bonus_per_column", 0)) * distance
	apply_damage(damage)
	if _recruited.get("current_hp", 0) > 0:
		_player_stun_turns_left = int(level_data.get("stun_turns", 0))
	# Same light-blue flight the player's own cast gets (see
	# _play_hope_of_the_fallen_flight()'s own comment), just flying the other
	# way - from the rival's own node to hero_image.
	_play_hope_of_the_fallen_flight(enemy["node"], hero_image, distance)

	_show_message_over_hero("Hope of the Fallen!")


# ------------------------------------------------------------------
# Solara's Withering Pursuit, cast by the rival - mirrors the player's own
# _activate_withering_pursuit(): hops `jump_distance` columns, always sailing clean
# over the player regardless of range_type (the unobstructed "walk
# straight through" rule _ranged_move_target() already uses), stopping
# only at the board edge or a player-cast Frostbound Rupture wall. No damage, no
# target required - always "succeeds". Unlike a gap-closer that always
# steps toward the nearest enemy, the direction here is CHOSEN by the
# rival's own current danger, mirroring the exact hp_ratio threshold
# EnemySkillAI's own _solara_withering_pursuit_modifier() scores both directions
# against (see that function's own docstring for why the two must stay
# in lockstep): away from the player while genuinely threatened, toward
# the player otherwise (closing distance is the dominant, offensive use
# per the design doc's own framing).
# ------------------------------------------------------------------

func _cast_enemy_withering_pursuit(enemy: Dictionary, level_data: Dictionary) -> void:
	var move_distance: int = int(level_data.get("move_distance", 0))
	var jump_distance: int = int(level_data.get("jump_distance", 0))

	var effective_max_hp: float = _enemy_hero_effective_max_hp(enemy)
	var hp_ratio: float = (float(enemy.get("current_hp", 0.0)) / effective_max_hp) if effective_max_hp > 0.0 else 1.0

	var toward_player: int = _step_toward(enemy["pos_index"], _hero_pos_index)
	var direction: int = toward_player
	if hp_ratio < 0.35 and toward_player != 0:
		direction = -toward_player
	elif toward_player == 0:
		direction = -1 if bool(enemy["node"].flip_h) else 1

	var pos: int = enemy["pos_index"]
	for i in range(move_distance + jump_distance):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos

	var old_x: float = enemy["node"].position.x
	var moved: int = absi(pos - int(enemy["pos_index"]))
	CreatureAnimator.silent_moves = true
	_move_enemy(enemy, pos)
	CreatureAnimator.silent_moves = false
	_play_withering_pursuit_effect(enemy["node"], old_x, direction, mini(move_distance, moved), moved - mini(move_distance, moved), bool(level_data.get("dash", false)))
	_show_message_over_hero("Withering Pursuit!")


# ------------------------------------------------------------------
# Solara's ultimate, Ambush Strike, cast by the rival - mirrors the
# player's own _activate_ambush_strike()/_tick_ambush_strike()/
# _end_ambush_strike(). Arms the buff exactly the same way; its own
# targeting/visibility effects are enforced elsewhere (_is_target_
# hidden()/_update_enemy_hero_visibility(), both already extended to read
# this flag) and its own Attack bonus is folded into
# _resolve_enemy_hero_attack()'s own roll, same "only the NEXT Attack
# pays off" shape the player-side copy has in _apply_hero_attack().
# ------------------------------------------------------------------

func _cast_enemy_ambush_strike(level_data: Dictionary) -> void:
	_enemy_ambush_strike_active = true
	_enemy_ambush_strike_bonus_damage_pct = float(level_data.get("bonus_damage_pct", 0.0))
	_enemy_ambush_strike_turns_remaining = int(level_data.get("duration", 0))
	_enemy_ambush_strike_duration_pending_start = true

	_show_message_over_hero("Ambush Strike!")
	_update_enemy_hero_visibility()


func _tick_enemy_ambush_strike() -> void:
	if not _enemy_ambush_strike_active:
		return

	if _enemy_ambush_strike_duration_pending_start:
		_enemy_ambush_strike_duration_pending_start = false
		return

	_enemy_ambush_strike_turns_remaining -= 1
	if _enemy_ambush_strike_turns_remaining <= 0:
		_end_enemy_ambush_strike()


func _end_enemy_ambush_strike() -> void:
	var was_active: bool = _enemy_ambush_strike_active
	_enemy_ambush_strike_active = false
	_enemy_ambush_strike_bonus_damage_pct = 0.0
	_enemy_ambush_strike_turns_remaining = 0
	_enemy_ambush_strike_duration_pending_start = false

	if was_active:
		_update_enemy_hero_visibility()


# ------------------------------------------------------------------
# Lunara's Lunar Ricochet, on the rival - a passive, so unlike every cast
# skill above there's no button/cast/mana/cooldown for it. Mirrors the
# player's own _get_lunar_ricochet_level_data()/_apply_lunar_ricochet_
# bounces(), simplified for the one real difference a hero fight has:
# there's no second real _enemies-style target the rival's own Attack
# could bounce onto besides the player himself (already the primary
# hit) - only the player's own guards/Elderwild Companion are real, separate
# occupants of their own columns near him, so those are the only actual
# bounce targets here, hit exactly the same "unconditional collateral,
# never counted toward the bounce cap" way the player-side copy already
# treats them (see that function's own comment).
# ------------------------------------------------------------------

func _get_enemy_lunar_ricochet_level_data() -> Dictionary:
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "lunar_ricochet")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("lunar_ricochet")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


## `attack_damage` is the rival's own already-rolled Attack damage
## (already including Moonbound Might - see _roll_enemy_hero_damage()'s
## own docstring), same raw, pre-mitigation figure the player-side copy
## bounces off of. A no-op while the skill isn't learned.
func _apply_enemy_lunar_ricochet_bounces(attack_damage: float) -> void:
	var level_data: Dictionary = _get_enemy_lunar_ricochet_level_data()
	if level_data.is_empty():
		return

	var bounce_damage: float = attack_damage * float(level_data.get("bounce_damage_pct", 0.0))
	if bounce_damage <= 0.0:
		return

	var radius: int = int(level_data.get("bounce_range", 0))
	_deal_aoe_damage_to_guards(_hero_pos_index, radius, bounce_damage)
	_deal_aoe_damage_to_bear(_hero_pos_index, radius, bounce_damage)


# ------------------------------------------------------------------
# Lunara's Moonbound Might, on the rival - a passive, so unlike every cast
# skill above there's no button/cast/mana/cooldown for it. Just a
# permanent % increase to the rival's own Attack damage, read fresh off
# this level's own bonus_damage_pct by _roll_enemy_hero_damage() itself
# (see that function's own comment) rather than anything ticked or
# tracked here.
# ------------------------------------------------------------------

func _get_enemy_moonbound_might_level_data() -> Dictionary:
	var level: int = PlayerManager.get_npc_skill_level(_enemy_hero_id, "moonbound_might")
	if level <= 0:
		return {}
	var skill: Dictionary = _find_enemy_skill("moonbound_might")
	if skill.is_empty():
		return {}
	return GameManager.get_skill_level_data(skill, level)


# ------------------------------------------------------------------
# Lunara's Moonfall Lance, cast by the rival on the player - mirrors the
# player's own _resolve_moonfall_lance_cast(): this level's own flat
# `damage` (through normal armor mitigation, via apply_damage()), then
# stuns the player (_player_stun_turns_left, the same shared field
# Barbed Lunge's/Drowned Surge's/Hope of the Fallen's own stun already use) for this
# level's own stun_turns, only if the hit left him alive. There's only
# one possible target in a hero fight, so - unlike the player's own copy,
# which needs a separate targeting click - this needs no separate
# targeting step at all, same simplification Thornbind's/Drowned Surge's own
# enemy-side copies already use. No Lunar Ricochet bounce here - the
# player-side copy never applies it to Moonfall Lance either (only a plain
# Attack triggers it - see _apply_hero_attack()'s own call site).
# ------------------------------------------------------------------

func _cast_enemy_moonfall_lance(level_data: Dictionary) -> void:
	if _enemy_skill_on_bear:
		_cast_enemy_moonfall_lance_on_bear(level_data)
		return
	apply_damage(float(level_data.get("damage", 0)))
	if _recruited.get("current_hp", 0) > 0:
		_player_stun_turns_left = int(level_data.get("stun_turns", 0))
	# Same falling-moonlight visual the player's own cast gets (see
	# _play_moonfall_lance_impact()'s own comment) - hero_image is a
	# TextureRect just like an enemy's own node, so it drops onto him
	# exactly the same way.
	_play_moonfall_lance_impact(hero_image)

	_show_message_over_hero("Moonfall Lance!")


# ------------------------------------------------------------------
# Lunara's ultimate, Eternal Eclipse, cast by the rival - mirrors the player's own
# _activate_eternal_eclipse()/_tick_eternal_eclipse()/_end_eternal_eclipse().
# ------------------------------------------------------------------

func _cast_enemy_eternal_eclipse(level_data: Dictionary) -> void:
	_enemy_eternal_eclipse_active = true
	_enemy_eternal_eclipse_damage_per_beam = float(level_data.get("damage", 0))
	_enemy_eternal_eclipse_radius = int(level_data.get("radius", 0))
	_enemy_eternal_eclipse_beams_remaining = int(level_data.get("beams", 0))
	# The casting turn itself doesn't count - beams only start landing
	# from the turn after (see _tick_enemy_eternal_eclipse()), same as every
	# other duration-based buff.
	_enemy_eternal_eclipse_duration_pending_start = true

	_begin_eclipse_sky()
	_show_message_over_hero("Eternal Eclipse!")


## Ticks Eternal Eclipse once per End Turn, same timing (and same "the casting
## turn doesn't count" skip) as the player-side copy - fires up to
## ETERNAL_ECLIPSE_BEAMS_PER_TURN beams (or however many are left) this turn.
## Each beam independently rolls ONE random living, targetable candidate
## from the player himself (if within `radius` columns of the rival's
## CURRENT position, re-checked fresh here, not fixed at cast time), any
## of the player's own guards within that same radius of the rival,
## and the player's own Elderwild Companion if it's alive and in range too - the
## enemy-side mirror of the player-side copy's own "boss, or one of its
## guards" pool, extended with the bear since (unlike the boss's own
## Elderwild Companion, a genuine _enemies entry the player-side pool already
## reaches for free) the player's own bear is a separate structure with
## no equivalent array to fall into automatically. A beam with nothing in
## range still counts against the total, same as the player-side copy.
## Ends the instant every beam has landed.
func _tick_enemy_eternal_eclipse() -> void:
	if not _enemy_eternal_eclipse_active:
		return

	if _enemy_eternal_eclipse_duration_pending_start:
		_enemy_eternal_eclipse_duration_pending_start = false
		return

	var boss: Dictionary = _get_hero_fight_boss()
	if boss.is_empty():
		_end_enemy_eternal_eclipse()
		return

	for i in range(ETERNAL_ECLIPSE_BEAMS_PER_TURN):
		if _enemy_eternal_eclipse_beams_remaining <= 0:
			break
		_enemy_eternal_eclipse_beams_remaining -= 1

		var candidates: Array = []
		if _distance(_hero_pos_index, boss["pos_index"]) <= _enemy_eternal_eclipse_radius:
			candidates.append({"kind": "player"})
		for guard in _guards:
			if _distance(guard["pos_index"], boss["pos_index"]) <= _enemy_eternal_eclipse_radius:
				candidates.append({"kind": "guard", "ref": guard})
		if _is_bear_alive() and _distance(_bear["pos_index"], boss["pos_index"]) <= _enemy_eternal_eclipse_radius:
			candidates.append({"kind": "bear"})

		if not candidates.is_empty():
			var picked: Dictionary = candidates[randi() % candidates.size()]
			# Same falling-moonlight visual the player-side copy's own
			# beams land with (see _tick_eternal_eclipse()'s own comment/
			# _play_eclipse_strike()) - each Dictionary branch just
			# needs whichever TextureRect that beam actually struck.
			match picked["kind"]:
				"player":
					apply_damage(_enemy_eternal_eclipse_damage_per_beam)
					_play_eclipse_strike(hero_image)
				"guard":
					var guard_damage: float = _apply_armor_reduction(_enemy_eternal_eclipse_damage_per_beam, _hero_armor())
					_deal_damage_to_guard(picked["ref"], guard_damage)
					_play_eclipse_strike(picked["ref"].get("node"))
				"bear":
					_deal_damage_to_bear(_enemy_eternal_eclipse_damage_per_beam)
					_play_eclipse_strike(_bear.get("node"))

		if _battle_over:
			return

	if _enemy_eternal_eclipse_beams_remaining <= 0:
		_end_enemy_eternal_eclipse()


func _end_enemy_eternal_eclipse() -> void:
	_enemy_eternal_eclipse_active = false
	_enemy_eternal_eclipse_damage_per_beam = 0.0
	_enemy_eternal_eclipse_radius = 0
	_enemy_eternal_eclipse_beams_remaining = 0
	_enemy_eternal_eclipse_duration_pending_start = false
	_refresh_eclipse_sky()


# ------------------------------------------------------------------
# Raze's ultimate, Kiss the Wastes, cast by the rival - mirrors the
# player's own _resolve_kiss_the_wastes_cast()/_fire_kiss_the_wastes_
# shot()/_end_kiss_the_wastes(). There's only one possible target in a
# hero fight (the player), tracked live via _hero_pos_index rather than
# a "marked enemy" reference the way the player's own copy needs for a
# creep that could die and leave a corpse behind - the player never
# does, so there's no "last known column" fallback to implement here.
# ------------------------------------------------------------------

## Marks the player, fires the FIRST of this level's own `hits` shots
## immediately, and arms _enemy_kiss_the_wastes_turns_left with however
## many are left (hits - 1) - _enemy_hero_turn()'s own top-of-function
## lockout auto-fires the rest, one per rival turn, with every other
## action locked out for as long as any remain.
func _cast_enemy_kiss_the_wastes(level_data: Dictionary) -> void:
	_enemy_kiss_the_wastes_level_data = level_data
	_enemy_kiss_the_wastes_active = true
	_enemy_kiss_the_wastes_turns_left = int(level_data.get("hits", 1)) - 1

	_play_kiss_blow(_get_hero_fight_boss().get("node"))
	_fire_enemy_kiss_the_wastes_shot(KissHeartsFX.BLOW_TIME)
	_show_message_over_hero("Kiss the Wastes!")


## Fires one Kiss the Wastes shot at the player: this level's own
## main_damage plus a refreshed burn DoT. Splash ("every OTHER enemy
## exactly 1 column away from the impact column") has nothing else to
## reach in a hero fight - the player is the only possible target - same
## "no cleave" simplification every other rival AoE cast already uses.
func _fire_enemy_kiss_the_wastes_shot(impact_delay: float = 0.0) -> void:
	var level_data: Dictionary = _enemy_kiss_the_wastes_level_data
	var main_damage: float = float(level_data.get("main_damage", 0))
	var burn_per_turn: float = float(level_data.get("burn_per_turn", 0))
	var burn_duration: int = int(level_data.get("burn_duration", 0))

	apply_damage(main_damage)
	if _recruited.get("current_hp", 0) > 0 and burn_per_turn > 0.0:
		_player_kiss_burn_dot_damage = burn_per_turn
		_player_kiss_burn_dot_turns_left = burn_duration

	# The splash itself isn't simplified away like every other rival
	# AoE's "no cleave" note above - guards and the Elderwild Companion are
	# real occupants of their own columns, and (unlike the enemy-side
	# skill functions elsewhere, which are always centered on some
	# OTHER point) the impact here is always the player's own position,
	# so either can end up sharing it outright (the bear especially -
	# it starts there) rather than merely being adjacent. Exactly on the
	# impact column takes main_damage, one column either side takes
	# splash_damage - same split _fire_kiss_the_wastes_shot()'s own
	# regular-enemy checks use for the player's copy, rather than the
	# single flat radius _deal_aoe_damage_to_guards()/_deal_aoe_
	# damage_to_bear() would give (which can't tell the two apart).
	var splash_damage: float = float(level_data.get("splash_damage", 0))
	for guard in _guards.duplicate():
		var guard_dist: int = _distance(guard["pos_index"], _hero_pos_index)
		if guard_dist == 0:
			_deal_damage_to_guard(guard, _apply_armor_reduction(main_damage, _hero_armor()))
		elif guard_dist == 1:
			_deal_damage_to_guard(guard, _apply_armor_reduction(splash_damage, _hero_armor()))
	if _is_bear_alive():
		var bear_dist: int = _distance(_bear["pos_index"], _hero_pos_index)
		if bear_dist == 0:
			_deal_damage_to_bear(main_damage)
		elif bear_dist == 1:
			_deal_damage_to_bear(splash_damage)

	# Same burning-lava-pool flare the player's own shots land with
	# (see _play_kiss_the_wastes_impact_effect()'s own comment) -
	# purely position-based, so it works the same regardless of which
	# side is casting.
	_play_kiss_the_wastes_impact_effect(_hero_pos_index, impact_delay, _get_hero_fight_boss().get("node"))


## Ends the rival's Kiss the Wastes channel - called once its last shot
## has fired (see _enemy_hero_turn()'s own top-of-function lockout).
func _end_enemy_kiss_the_wastes() -> void:
	_enemy_kiss_the_wastes_active = false
	_enemy_kiss_the_wastes_turns_left = 0
	_enemy_kiss_the_wastes_level_data = {}


## Moves an enemy to `new_pos` (clamped on-board) and syncs its node's
## screen position to match, flipping its art to face the direction it
## just moved in (same left/right art convention as _spawn_enemy()).
func _move_enemy(enemy: Dictionary, new_pos: int) -> void:
	var old_pos: int = enemy["pos_index"]
	var old_x: float = enemy["node"].position.x
	enemy["pos_index"] = clampi(new_pos, 0, GRID_COLUMNS - 1)
	enemy["node"].position = Vector2(_index_to_x(enemy["pos_index"]), _creature_top_y(enemy["node"].size.y))
	var animator := CreatureAnimator.of(enemy["node"])
	if animator != null and not is_equal_approx(old_x, enemy["node"].position.x):
		animator.play_move(old_x - enemy["node"].position.x)
	# A creep with no animation of its own (the Blackbloom's, so far) has no
	# animator to make its footsteps - it steps here instead.
	elif animator == null and not is_equal_approx(old_x, enemy["node"].position.x):
		AudioManager.play_event("steps", 0.0, 0.1)

	var direction: int = enemy["pos_index"] - old_pos
	if direction != 0:
		var native_faces_right: bool = enemy["static"].get("is_hero_fight", false)
		enemy["node"].flip_h = (direction < 0) if native_faces_right else (direction > 0)

	_refresh_enemy_overhead_labels()


const ATTACK_LUNGE_DISTANCE := 18.0
const ATTACK_LUNGE_OUT_DURATION := 0.09
const ATTACK_LUNGE_BACK_DURATION := 0.14


## A quick "slight shift" in the direction the attacker is currently
## facing, and back - every enemy attack's own visual tell, the enemy-
## side equivalent of the player clicking Attack (already an obvious,
## deliberate action he just took). Enemies otherwise act automatically
## with nothing on screen to show which one just hit something, so
## this plays at every creep/rival-hero attack call site (see
## _enemy_turn()/_resolve_enemy_hero_attack()) - purely cosmetic, the
## damage itself is already fully resolved by the time this starts.
##
## Deliberately keyed off the sprite's own facing (flip_h, same
## left/right art convention _move_enemy() already maintains) rather
## than the actual target's column: a melee attacker always shares its
## target's column outright (distance 0), so a direction-to-target
## computation would always come out to zero for exactly the case that
## needs this lunge the most.
##
## `target_pos` (a ranged attacker's target column) first turns the
## attacker to face it - a ranged creep that just fled from the hero
## would otherwise shoot with its back to him. Omitted (-1), or the same
## column, keeps the current facing.
func _play_enemy_attack_lunge(enemy: Dictionary, target_pos: int = -1) -> void:
	var node: Control = enemy.get("node")
	if node == null:
		return

	# A melee creep roars as it strikes - one of its two roars, at random.
	if enemy["static"].get("type", "") == "melee" and not enemy["static"].get("is_hero_fight", false):
		AudioManager.play_event_random(["melee_creep_roar", "melee_creep_roar_2"])

	if target_pos >= 0:
		_face_enemy_toward(enemy, target_pos)

	var native_faces_right: bool = enemy["static"].get("is_hero_fight", false)
	var facing_left: bool = node.flip_h if native_faces_right else not node.flip_h
	var direction: float = -1.0 if facing_left else 1.0

	# The node shift below is the lunge itself; the animator only adds
	# the wind-up/strike body motion on top.
	var animator := CreatureAnimator.of(node)
	if animator != null:
		animator.play_attack(direction, false)

	var base_x: float = node.position.x
	var tween := create_tween()
	tween.tween_property(node, "position:x", base_x + direction * ATTACK_LUNGE_DISTANCE, ATTACK_LUNGE_OUT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:x", base_x, ATTACK_LUNGE_BACK_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


## Mirrors an enemy's art to face column `target_pos` - same left/right
## art convention _move_enemy() uses. No-op for its own column.
func _face_enemy_toward(enemy: Dictionary, target_pos: int) -> void:
	var node: Control = enemy.get("node")
	var direction: int = target_pos - int(enemy["pos_index"])
	if node == null or direction == 0:
		return
	var native_faces_right: bool = enemy["static"].get("is_hero_fight", false)
	node.flip_h = (direction < 0) if native_faces_right else (direction > 0)


const PROJECTILE_RELEASE_DELAY := 0.08

## A creep whose "projectile" is this doesn't shoot anything: a thorned
## vine lashes out from BEHIND it to the target, then withers back and
## vanishes (see _fire_enemy_rear_vine()).
const REAR_VINE_STYLE := "rear_vine"

## A creep whose "projectile" is this fires a rifle: a muzzle flash and one
## fast round (see RifleShotFX and _fire_enemy_rifle_shot()).
const RIFLE_BULLET_STYLE := "rifle_bullet"

## A creep whose "projectile" is this fires a harpoon gun: a burst of brine
## and one heavy barbed bolt trailing its line (see HarpoonBoltFX).
const HARPOON_BOLT_STYLE := "harpoon_bolt"


## A ranged enemy's attack projectile - only for enemies whose
## GameManager definition names one ("projectile": a ProjectileFX style
## id), so adding arrows to another creep is just that one field. Flies
## from the attacker's front to `target_node`'s middle, released as the
## lunge snaps forward.
##
## Call right BEFORE the damage call and clear _deferred_hit_node right
## after it: that holds the target's CreatureAnimator hit reaction back
## until the projectile actually lands, instead of flinching the moment
## the shot leaves the bow.
func _fire_enemy_projectile(enemy: Dictionary, target_node: Control) -> void:
	var style_id: String = enemy["static"].get("projectile", "")
	var node: Control = enemy.get("node")
	if style_id == "" or node == null or not is_instance_valid(target_node):
		return
	if style_id == RIFLE_BULLET_STYLE:
		_fire_enemy_rifle_shot(enemy, target_node)
		return
	if style_id == REAR_VINE_STYLE:
		_fire_enemy_rear_vine(enemy, target_node)
		return
	if style_id == HARPOON_BOLT_STYLE:
		_fire_enemy_harpoon_bolt(enemy, target_node)
		return

	var native_faces_right: bool = enemy["static"].get("is_hero_fight", false)
	var facing_left: bool = node.flip_h if native_faces_right else not node.flip_h
	var facing: float = -1.0 if facing_left else 1.0
	var launch: Vector2 = ProjectileFX.launch_point(style_id)
	var from: Vector2 = node.global_position + node.size * Vector2(0.5 + launch.x * facing, launch.y)
	var to: Vector2 = target_node.global_position + target_node.size * 0.5

	_deferred_hit_node = target_node
	get_tree().create_timer(PROJECTILE_RELEASE_DELAY).timeout.connect(func() -> void:
		if not is_instance_valid(_fx_layer):
			return
		ProjectileFX.fire(_fx_layer, style_id, from, to, func() -> void:
			var animator := CreatureAnimator.of(target_node)
			if animator != null:
				animator.play_hit(signf(from.x - to.x))
		)
	)


## The Scorchlands rifleman's attack: a muzzle flash at the end of the
## rifle and one fast round to the target (see RifleShotFX). Same
## deferred-hit contract as _fire_enemy_projectile().
func _fire_enemy_rifle_shot(enemy: Dictionary, target_node: Control) -> void:
	var node: Control = enemy.get("node")
	var native_faces_right: bool = enemy["static"].get("is_hero_fight", false)
	var facing_left: bool = node.flip_h if native_faces_right else not node.flip_h
	var muzzle: Vector2 = RifleShotFX.MUZZLE_FACING_LEFT
	if not facing_left:
		muzzle.x = 1.0 - muzzle.x
	var from: Vector2 = node.global_position + node.size * muzzle
	var to: Vector2 = target_node.global_position + target_node.size * Vector2(0.5, 0.45)

	_deferred_hit_node = target_node
	get_tree().create_timer(PROJECTILE_RELEASE_DELAY).timeout.connect(func() -> void:
		if not is_instance_valid(_fx_layer):
			return
		RifleShotFX.play(_fx_layer, from, to, func() -> void:
			var animator := CreatureAnimator.of(target_node)
			if animator != null:
				animator.play_hit(signf(from.x - to.x))
		)
	)


## The Drowned Empire harpooner's attack: a spray off the harpoon gun and one
## barbed bolt trailing its line to the target (see HarpoonBoltFX). Same
## deferred-hit contract as _fire_enemy_projectile().
func _fire_enemy_harpoon_bolt(enemy: Dictionary, target_node: Control) -> void:
	var node: Control = enemy.get("node")
	var native_faces_right: bool = enemy["static"].get("is_hero_fight", false)
	var facing_left: bool = node.flip_h if native_faces_right else not node.flip_h
	var muzzle: Vector2 = HarpoonBoltFX.MUZZLE_FACING_LEFT
	if not facing_left:
		muzzle.x = 1.0 - muzzle.x
	var from: Vector2 = node.global_position + node.size * muzzle
	var to: Vector2 = target_node.global_position + target_node.size * Vector2(0.5, 0.45)

	_deferred_hit_node = target_node
	get_tree().create_timer(PROJECTILE_RELEASE_DELAY).timeout.connect(func() -> void:
		if not is_instance_valid(_fx_layer):
			return
		HarpoonBoltFX.play(_fx_layer, from, to, func() -> void:
			var animator := CreatureAnimator.of(target_node)
			if animator != null:
				animator.play_hit(signf(from.x - to.x))
		)
	)


## The Verdant Scar's ranged creep attack: a thorned vine rises from behind
## the creep, arcs over it to the target, strikes, then withers back and
## disappears. The vine lives in enemies_layer, placed just UNDER the
## creep's own sprite, so it really does come out from behind the creep
## (and still draws over the hero, who sits below that layer). Same
## deferred-hit contract as _fire_enemy_projectile().
func _fire_enemy_rear_vine(enemy: Dictionary, target_node: Control) -> void:
	var node: Control = enemy.get("node")
	var native_faces_right: bool = enemy["static"].get("is_hero_fight", false)
	var facing_left: bool = node.flip_h if native_faces_right else not node.flip_h
	var facing: float = -1.0 if facing_left else 1.0
	# Low on the creep's back - the side away from its target.
	var from: Vector2 = node.global_position + node.size * Vector2(0.5 - 0.3 * facing, 0.78)
	var to: Vector2 = target_node.global_position + target_node.size * Vector2(0.5, 0.45)
	var lift: float = clampf(from.distance_to(to) * 0.3, 50.0, 130.0)

	_deferred_hit_node = target_node
	get_tree().create_timer(PROJECTILE_RELEASE_DELAY).timeout.connect(func() -> void:
		if not is_instance_valid(node) or not is_instance_valid(enemies_layer):
			return
		var style: Dictionary = VineLashFX.CREEP_STYLE.duplicate()
		style["lift"] = lift
		var vine := VineLashFX.play(enemies_layer, from, to, func() -> void:
			var animator := CreatureAnimator.of(target_node)
			if animator != null:
				animator.play_hit(signf(from.x - to.x))
		, style)
		enemies_layer.move_child(vine, node.get_index())
	)


## A hero's own normal-attack visual, if its GameManager definition names
## one ("attack_effect") - played from `caster`'s "attack_origin" (a
## point on its art, mirrored when it faces left) to `target_node`'s
## chest. Used for the player's Attack and a rival hero's alike.
##
## Like _fire_enemy_projectile(), call right BEFORE the damage and clear
## _deferred_hit_node right after it, so the target flinches when the
## effect lands instead of the moment it starts. Skipped while
## `transformed` (Beast of the Elderwild): the bear fights in melee, so its
## attack is just its own lunge, no ranged effect.
func _play_hero_attack_effect(hero_static: Dictionary, caster: TextureRect, target_node: Control, transformed: bool) -> void:
	var effect: String = hero_static.get("attack_effect", "")
	if effect == "" or transformed or caster == null or not is_instance_valid(target_node):
		return

	var origin: Vector2 = hero_static.get("attack_origin", Vector2(0.5, 0.4))
	var origin_art: Vector2 = origin
	if caster.flip_h:
		origin.x = 1.0 - origin.x
	var from: Vector2 = caster.global_position + caster.size * origin
	var to: Vector2 = target_node.global_position + target_node.size * Vector2(0.5, 0.45)
	var on_hit := func() -> void:
		var animator := CreatureAnimator.of(target_node)
		if animator != null:
			animator.play_hit(signf(from.x - to.x))

	match effect:
		"vine_lash":
			_deferred_hit_node = target_node
			VineLashFX.play(_fx_layer, from, to, on_hit)
		"projectile":
			# A projectile from ProjectileFX named by the hero's own
			# "attack_projectile" (Solara's arrow).
			_deferred_hit_node = target_node
			ProjectileFX.fire(_fx_layer, hero_static.get("attack_projectile", "arrow"), from, to, on_hit)
		"chakram":
			_deferred_hit_node = target_node
			ChakramFX.play(_fx_layer, from, to, on_hit)
		"shotgun_blast":
			_deferred_hit_node = target_node
			ShotgunBlastFX.play(_fx_layer, from, to, on_hit)
		"flamethrower":
			_deferred_hit_node = target_node
			FlamethrowerFX.play(_fx_layer, from, to, on_hit)
		"bite":
			# Spectral jaws snapping shut on the target itself - `from` only
			# says which side the bite comes from.
			_deferred_hit_node = target_node
			BiteFX.play(_fx_layer, from, target_node, on_hit)
		"frost_raven":
			_deferred_hit_node = target_node
			FrostRavenFX.play(_fx_layer, from, to, on_hit)
		"ice_shard":
			# Launched from the shard hanging beside him (IceShardFX), not
			# from `from` - a fresh one starts forming as it leaves.
			var shard := IceShardFX.of(caster)
			if shard == null:
				shard = IceShardFX.attach(caster, origin_art)
			_deferred_hit_node = target_node
			shard.fire(_fx_layer, to, on_hit)


## Anything a hero's normal attack keeps on them between attacks - Nhal's
## ice shard (IceShardFX), hanging beside `node` from the start of the
## fight. Called when the player's hero and a rival hero are set up.
func _attach_hero_attack_prop(hero_static: Dictionary, node: Variant) -> void:
	if hero_static.get("attack_effect", "") == "ice_shard" and is_instance_valid(node) and node is TextureRect:
		IceShardFX.attach(node, hero_static.get("attack_origin", Vector2(0.66, -0.02)))


## Picks a flee direction once and sticks with it - only flipping to
## the opposite direction when it actually hits a wall. Recalculating
## "away from hero" fresh every turn is what caused the back-and-forth
## pacing at the edge before: the enemy would re-decide "flee left" as
## soon as it was possible again, then immediately get blocked again.
func _get_flee_position(enemy: Dictionary) -> int:
	var enemy_pos: int = enemy["pos_index"]

	if not enemy.has("flee_direction"):
		enemy["flee_direction"] = -1 if enemy_pos < _hero_pos_index else 1

	var direction: int = enemy["flee_direction"]
	var next_pos: int = enemy_pos + direction

	if next_pos < 0 or next_pos >= GRID_COLUMNS:
		# Hit the wall - commit to the other direction from now on,
		# not just for this one turn.
		direction = -direction
		enemy["flee_direction"] = direction
		next_pos = clampi(enemy_pos + direction, 0, GRID_COLUMNS - 1)

	return next_pos


## The hero gets exactly one action per turn - move, attack, skill, or
## item. Once any of them is used, all four lock until End Turn. The Test of
## Time locks all four too, same as a stun - see _the_test_of_time_active
## and _maybe_auto_skip_player_turn(), which auto-skips the turn entirely
## while either is still in effect rather than leaving these open with
## nothing the player can actually do with them.
func _update_action_buttons() -> void:
	_maybe_auto_skip_player_turn()
	var locked: bool = _battle_over or _has_acted_this_turn or _rival_fx_in_flight or _player_stun_turns_left > 0 or _the_test_of_time_active or _kiss_the_wastes_active
	move_left_button.disabled = locked
	move_right_button.disabled = locked
	attack_button.disabled = locked

	# Fleeing is free at any time in a real playthrough - never gated by
	# turn-lock/stun/cooldown here, so unlike the buttons above it never
	# gets a fresh baseline elsewhere in this function. _apply_tutorial_
	# gate() below only ever ADDS a disable on top of whatever's already
	# set (see its own comment) - without resetting this to false first,
	# a step that gates flee out (e.g. stage 2's "attack_while_low")
	# would leave it stuck disabled forever, even once a later step
	# (e.g. "must_flee") allows it again.
	flee_button.disabled = false

	for skill_id in _skill_buttons.keys():
		var on_cooldown: bool = _skill_cooldowns.get(skill_id, 0) > 0
		_skill_buttons[skill_id].disabled = locked or on_cooldown

	# Item buttons are rebuilt (not just toggled) since their count/
	# icon can also change from item use - _populate_item_grid() reads
	# _has_acted_this_turn itself to decide their disabled state.
	_populate_item_grid()

	# Progress checks BEFORE the gate: _apply_tutorial_gate() only ever
	# ADDS restrictions on top of whatever locked/cooldown state the
	# lines above just set - it never lifts one. A step transition
	# triggered by one of these checks (e.g. _advance_tutorial_stage1_
	# step()) calls the gate again itself with the NEW allowed list, but
	# that can't undo a disable the FIRST (stale-list) gate call already
	# applied to a button that just became allowed - it would get stuck
	# disabled with nothing left to ever re-enable it. Settling the step
	# (and its allowed-actions list) first means the one gate call at
	# the end always sees the final list for this pass.
	_check_tutorial_stage1_progress()
	_check_tutorial_stage2_progress()
	_apply_tutorial_gate()


# ------------------------------------------------------------------
# Tutorial support (TutorialManager's stage 1 script: recruit Kaelen Varr
# with Drowned Surge on Zone.tscn, then this file walks through using Drowned Surge
# on the ranged creep and closing in on the melee ones). Every function
# here is a no-op unless TutorialManager.is_active, so none of it
# affects a real playthrough.
# ------------------------------------------------------------------

# Which forced step stage 1's script is currently on - "" outside the
# tutorial. Driving state for _check_tutorial_stage1_progress() (polled
# after every action via _update_action_buttons()) and the explicit
# advance from _resolve_drowned_surge_cast() once the ranged creep is hit.
var _tutorial_stage1_step: String = ""

# One-shot flags so the reinforcements tip and the forced Pull of the Abyss/
# The Sunken One picks each only ever interrupt the player once - a second
# reinforcement wave, or a second level-up's skill point, are the
# player's own to handle freely from then on.
var _tutorial_shown_reinforcement_tip: bool = false
var _tutorial_shown_melee_in_range_tip: bool = false
var _tutorial_shown_recast_tip: bool = false
var _tutorial_taught_pull_of_the_abyss: bool = false
var _tutorial_taught_the_sunken_one: bool = false


## Which skill id (if any) the current tutorial stage is forcing the
## player's next skill point onto - "" once that stage's forced pick
## has already been made (or outside the tutorial entirely), meaning
## any further banked points are the player's own free choice again.
## Shared by _maybe_show_skill_choice_popup()/_refresh_skill_choice_
## popup(), so stage 1 (Pull of the Abyss) and stage 3 (The Sunken One) both force
## their pick through the same one code path.
func _tutorial_forced_skill_id() -> String:
	if not TutorialManager.is_active:
		return ""
	if TutorialManager.current_stage == 1 and not _tutorial_taught_pull_of_the_abyss:
		return "pull_of_the_abyss"
	if TutorialManager.current_stage == 3 and not _tutorial_taught_the_sunken_one:
		return "the_sunken_one"
	return ""


## Fully recomputes every action button's disabled state from scratch
## whenever the tutorial is active - deliberately NOT layered on top of
## whatever _update_action_buttons() happened to set earlier, since
## this can be (and often is) called well outside that function's own
## call chain: _advance_tutorial_stageN_step() calls this directly from
## spots like a failed skill cast (not enough mana) or a drowned_surge/
## the_sunken_one cast resolving, neither of which goes through
## _update_action_buttons() at all. An earlier version only ever ADDED
## disables on top of the current button state, which happened to work
## while every call site ran with a stable allowed-list, but broke the
## moment a button was disabled under an OLD allowed-list and needed to
## become enabled again under a NEW one from a call outside that flow -
## it had no way to undo a disable it hadn't just set (this hit Drowned Surge,
## then Flee, then the Mana Potion, before landing on this fix). See
## TutorialManager.is_action_allowed() for the action id scheme
## ("move_left", "move_right", "attack", "flee", "skill:<id>",
## "item:<item_id>").
func _apply_tutorial_gate() -> void:
	if not TutorialManager.is_active:
		return

	# Same "one action per turn" lock _update_action_buttons() computes -
	# duplicated here since this needs to be authoritative on its own,
	# not dependent on that function having just run. Flee is
	# deliberately excluded, same as _update_action_buttons() - it's
	# never turn-locked in a real playthrough either.
	var locked: bool = _battle_over or _has_acted_this_turn or _rival_fx_in_flight or _player_stun_turns_left > 0 or _the_test_of_time_active or _kiss_the_wastes_active

	move_left_button.disabled = locked or not TutorialManager.is_action_allowed("move_left")
	move_right_button.disabled = locked or not TutorialManager.is_action_allowed("move_right")
	attack_button.disabled = locked or not TutorialManager.is_action_allowed("attack")
	flee_button.disabled = not TutorialManager.is_action_allowed("flee")

	for skill_id in _skill_buttons.keys():
		var on_cooldown: bool = _skill_cooldowns.get(skill_id, 0) > 0
		_skill_buttons[skill_id].disabled = locked or on_cooldown or not TutorialManager.is_action_allowed("skill:" + skill_id)

	for btn in items_grid.get_children():
		var item_id: String = btn.get_meta("tutorial_item_id", "")
		if item_id != "":
			btn.disabled = locked or not TutorialManager.is_action_allowed("item:" + item_id)

	_tutorial_update_glow()


# Tracks whichever single button is currently glowing (see
# _tutorial_update_glow()) so repeated _apply_tutorial_gate() calls -
# there are many, every turn - don't restart the pulse animation from
# scratch each time; only a change of target tears down the old glow
# and starts a new one.
var _tutorial_glow_button: Button = null
var _tutorial_glow_style: StyleBoxFlat = null
var _tutorial_glow_tween: Tween = null


## Which single button (if any) the tutorial's CURRENT allowed-actions
## list is forcing the player toward - the counterpart TutorialManager.
## make_glow_style() gets applied to. Returns null when nothing is
## forced (allowed list empty, e.g. mid-checkpoint) or more than one
## thing is allowed at once (battle.gd's own steps only ever force
## exactly one action at a time; Shop.gd's simultaneous health+mana
## forcing is handled separately, in Shop.gd itself).
func _tutorial_current_forced_button() -> Button:
	if not TutorialManager.is_active:
		return null

	var allowed: Array = TutorialManager.get_allowed_actions()
	if allowed.size() != 1:
		return null

	var action_id: String = allowed[0]
	if action_id == "move_left":
		return move_left_button
	if action_id == "move_right":
		return move_right_button
	if action_id == "attack":
		return attack_button
	if action_id == "flee":
		return flee_button
	if action_id.begins_with("skill:"):
		return _skill_buttons.get(action_id.substr(6), null)
	if action_id.begins_with("item:"):
		var item_id: String = action_id.substr(5)
		for btn in items_grid.get_children():
			if btn.get_meta("tutorial_item_id", "") == item_id:
				return btn
	return null


## Moves the glow (see TutorialManager.make_glow_style()) onto whatever
## _tutorial_current_forced_button() currently returns, tearing down
## the previous one first - a no-op if the target hasn't changed since
## last time, so the breathing animation isn't constantly restarted.
func _tutorial_update_glow() -> void:
	var target: Button = _tutorial_current_forced_button()
	if target == _tutorial_glow_button:
		return

	if _tutorial_glow_button != null and is_instance_valid(_tutorial_glow_button):
		_tutorial_glow_button.remove_theme_stylebox_override("normal")
		_tutorial_glow_button.remove_theme_stylebox_override("hover")
	if _tutorial_glow_tween:
		_tutorial_glow_tween.kill()

	_tutorial_glow_button = target
	_tutorial_glow_style = null
	_tutorial_glow_tween = null

	if target == null:
		return

	_tutorial_glow_style = TutorialManager.make_glow_style()
	target.add_theme_stylebox_override("normal", _tutorial_glow_style)
	target.add_theme_stylebox_override("hover", _tutorial_glow_style)
	_tutorial_glow_tween = TutorialManager.start_glow_pulse(_tutorial_glow_style, self)


## Advances stage 1's script to `step_id`: sets which action(s)
## TutorialManager will now allow, shows the popup explaining that
## step, and re-applies the gate immediately so the newly-(dis)allowed
## buttons don't wait for the next _update_action_buttons() pass.
func _advance_tutorial_stage1_step(step_id: String) -> void:
	_tutorial_stage1_step = step_id

	match step_id:
		"move_to_drowned_surge_range":
			TutorialManager.set_allowed_actions(["move_right"])
			TutorialManager.show_popup(
				"The enemies are still out of range. Move toward them - Drowned Surge reaches few steps in front, "
				+ "so you'll be able to use it well before you're close enough to be attacked back."
			)
		"cast_drowned_surge_on_range":
			TutorialManager.set_allowed_actions(["skill:drowned_surge"])
			TutorialManager.show_popup(
				"Drowned Surge is in range now. Cast it on the ranged creep in the back - left alone, it'll "
				+ "keep its distance and shoot you from afar, or turn and flee if you close in on it "
				+ "instead."
			)
		"approach_melee":
			# Which direction actually closes the distance - a melee
			# creep always spawns at its own fixed column regardless of
			# wherever the hero currently is (see _spawn_enemy()), so on
			# a reinforcement recast the hero could just as easily have
			# drifted PAST that column already, needing "move_left"
			# instead of the "move_right" the very first approach in
			# stage 1 always needs.
			var melee_enemy: Dictionary = _tutorial_find_enemy_by_type("melee")
			var move_action: String = "move_right"
			if not melee_enemy.is_empty() and melee_enemy["pos_index"] < _hero_pos_index:
				move_action = "move_left"
			TutorialManager.set_allowed_actions([move_action])
			TutorialManager.show_popup(
				"That'll keep it stunned for a moment, but it's not dead yet. Close the distance on "
				+ "the melee creeps so you can start on them too."
			)
		"melee_in_range":
			# Re-entered every time a Drowned Surge cast finishes off a ranged
			# creep (see _resolve_drowned_surge_cast()) - the wording stays
			# generic enough to make sense on every visit, not just the
			# first.
			# The explanation only pops up on the first visit - after
			# that, the gate (Attack alone, glowing) says it on its own.
			TutorialManager.set_allowed_actions(["attack"])
			if not _tutorial_shown_melee_in_range_tip:
				_tutorial_shown_melee_in_range_tip = true
				TutorialManager.show_popup(
					"The melee creeps are in range - keep attacking them. Use Drowned Surge again the moment "
					+ "it's ready if another ranged creep is still up."
				)
		"recast_drowned_surge_on_range":
			# Same first-visit-only popup as "melee_in_range" above.
			TutorialManager.set_allowed_actions(["skill:drowned_surge"])
			if not _tutorial_shown_recast_tip:
				_tutorial_shown_recast_tip = true
				TutorialManager.show_popup(
					"Drowned Surge is ready again. Use it on the ranged creep to finish it off, so you can go "
					+ "back to focusing entirely on the melee creeps."
				)
		"stage_cleared":
			_battle_over = true
			TutorialManager.set_allowed_actions([])
			_update_action_buttons()
			TutorialManager.show_checkpoint(
				"Stage cleared! Remember: move into range, use skills the moment they're "
				+ "ready and attack in between. Spend skill points on whatever you think will benefit your "
				+ "hero the best.\n\nContinue with the next tutorial stage, or stop here?",
				TutorialManager.start_stage2
			)

	_apply_tutorial_gate()


## Polled from _update_action_buttons() (i.e. after every move/attack/
## skill this battle resolves) - advances stage 1's script once its
## current step's own condition is met. The "cast Drowned Surge on the ranged
## creep" step advances explicitly instead, from _resolve_drowned_surge_cast()
## right as that cast lands, not from here.
func _check_tutorial_stage1_progress() -> void:
	if not TutorialManager.is_active or TutorialManager.current_stage != 1:
		return

	match _tutorial_stage1_step:
		"move_to_drowned_surge_range":
			var range_enemy: Dictionary = _tutorial_find_enemy_by_type("range")
			if not range_enemy.is_empty() and _distance(range_enemy["pos_index"], _hero_pos_index) <= 3:
				_advance_tutorial_stage1_step("cast_drowned_surge_on_range")
		"approach_melee":
			if not _get_enemy_at(_hero_pos_index).is_empty():
				_advance_tutorial_stage1_step("melee_in_range")
		"melee_in_range":
			# Watches for Drowned Surge coming off cooldown with a ranged
			# creep actually WITHIN its cast range - true for the
			# original one (still alive after its first, non-lethal
			# cast) and again for whichever ranged creep reinforcements
			# bring in later. Checking range, not just "alive", matters:
			# a reinforcement spawns at a fixed column regardless of
			# where the hero is currently standing, so it can easily
			# start out too far away - forcing "skill:drowned_surge" only
			# with nothing valid to cast it on would hard-lock the
			# battle, since Attack/Move would be the only way to let a
			# turn pass at all for it to approach. Staying in this step
			# instead just keeps attacking melee - a real turn still
			# passes, so the ranged creep's own AI gets to close the
			# distance on its own.
			var range_enemy: Dictionary = _tutorial_find_enemy_by_type("range")
			if _skill_cooldowns.get("drowned_surge", 0) <= 0 and not range_enemy.is_empty() \
			and _distance(range_enemy["pos_index"], _hero_pos_index) <= 3:
				_advance_tutorial_stage1_step("recast_drowned_surge_on_range")


func _tutorial_find_enemy_by_type(type: String) -> Dictionary:
	for enemy in _enemies:
		if enemy["static"].get("type", "") == type:
			return enemy
	return {}


## Explains the reinforcement mechanic the first time it fires during
## the tutorial - called from _spawn_reinforcements() alongside its own
## normal "Reinforcements arrived!" banner. Doesn't touch the current
## step or its allowed actions; it's a side note, not a forced step.
func _tutorial_maybe_explain_reinforcements() -> void:
	if not TutorialManager.is_active or TutorialManager.current_stage != 1 or _tutorial_shown_reinforcement_tip:
		return
	_tutorial_shown_reinforcement_tip = true
	TutorialManager.show_popup(
		"Reinforcements! If you take too long to clear a stage more enemies will join the fight - so don't "
		+ "hold skills back waiting for a 'perfect' moment. Use them as soon as they're ready."
	)


## While stage 1's script calls for a specific target (Drowned Surge needs to
## land on the ranged creep specifically - by the time it's in range,
## the melee creeps usually are too, since they stand one column
## closer), rejects a click on anything else. The popup already says
## which one to click; this just stops a stray click from skipping past
## it. Every other step - and anything outside the tutorial - allows
## any valid target, same as a real playthrough.
func _tutorial_allows_enemy_click(enemy: Dictionary) -> bool:
	if TutorialManager.is_active and TutorialManager.current_stage == 1 \
	and (_tutorial_stage1_step == "cast_drowned_surge_on_range" or _tutorial_stage1_step == "recast_drowned_surge_on_range"):
		return enemy["static"].get("type", "") == "range"
	return true


# ------------------------------------------------------------------
# Tutorial support (TutorialManager's stage 2 script: a manufactured
# mid-run scenario - see TutorialManager.start_stage2() - where Kaelen Varr
# is already at level 5, deep into this zone's hardest stage, and
# critically low on HP/mana. Teaches attacking, taking a hit, and
# fleeing before it's too late; the Map/Shop side of the flee (forcing
# the shop open and buying potions) lives in Map.gd/Shop.gd instead.
# ------------------------------------------------------------------

var _tutorial_stage2_step: String = ""


## Called from _ready() once stage 2's manufactured state (level,
## HP/mana, stage 3 enemies) has already loaded normally - drops the
## hero straight onto the melee creeps' column instead of making them
## walk there again, since this scenario starts mid-fight, not fresh.
func _start_tutorial_stage2_battle() -> void:
	_hero_pos_index = 7
	_update_hero_position()
	_advance_tutorial_stage2_step("attack_while_low")


func _advance_tutorial_stage2_step(step_id: String) -> void:
	_tutorial_stage2_step = step_id

	match step_id:
		"attack_while_low":
			TutorialManager.set_allowed_actions(["attack"])
			TutorialManager.show_popup(
				"Kaelen Varr is level 5, but already taken a beating. He is deep into this zone's hardest stage, and "
				+ "critically low on HP and mana, with no potions in reserve. You're right on top of the "
				+ "melee creeps here - go ahead and attack, but keep an eye on that health bar."
			)
		"must_flee":
			TutorialManager.set_allowed_actions(["flee"])
			TutorialManager.show_popup(
				"That hit brings you dangerously close to death. Staying and keep fighting isn't worth "
				+ "the risk - flee back to the map and restock on potions before pushing any further."
			)

	_apply_tutorial_gate()


## Polled from _update_action_buttons(), same as stage 1's own check -
## advances past the forced Attack once a full turn (the attack itself,
## then the enemies' own retaliation) has actually played out.
func _check_tutorial_stage2_progress() -> void:
	if not TutorialManager.is_active or TutorialManager.current_stage != 2:
		return

	if _tutorial_stage2_step == "attack_while_low" and _turn_count >= 1:
		_advance_tutorial_stage2_step("must_flee")


# ------------------------------------------------------------------
# Tutorial support (TutorialManager's stage 3 script: the final
# scripted scenario - see TutorialManager.start_stage3() - same setup
# as stage 2 but with the potions bought there still in reserve.
# Teaches drinking a potion mid-fight, picking up an ultimate on
# level-up, discovering it costs more mana than you have, and using a
# second potion to actually cast it.
# ------------------------------------------------------------------

var _tutorial_stage3_step: String = ""


## Called from _ready() once stage 3's manufactured state has already
## loaded normally - same "drop straight onto the melee creeps' column"
## reasoning as _start_tutorial_stage2_battle().
func _start_tutorial_stage3_battle() -> void:
	_hero_pos_index = 7
	_update_hero_position()
	_advance_tutorial_stage3_step("heal_up")


func _advance_tutorial_stage3_step(step_id: String) -> void:
	_tutorial_stage3_step = step_id

	match step_id:
		"heal_up":
			TutorialManager.set_allowed_actions(["item:health"])
			TutorialManager.show_popup(
				"Same rough spot as before - but this time you've got a Health Potion. Drink it before "
				+ "doing anything else."
			)
		"attack_to_level_up":
			TutorialManager.set_allowed_actions(["attack"])
			TutorialManager.show_popup(
				"Better. Now attack the melee creeps - one more kill should push you to level 6."
			)
		"attack_before_reinforcements":
			TutorialManager.set_allowed_actions(["attack"])
			TutorialManager.show_popup(
				"The Sunken One is yours now - your single strongest hit. Keep attacking for the moment; "
				+ "you'll want it ready for when reinforcements show up."
			)
		"cast_ultimate":
			TutorialManager.set_allowed_actions(["skill:the_sunken_one"])
			TutorialManager.show_popup(
				"Reinforcements are here - exactly what The Sunken One is for. Your ship fires his "
				+ "cannons the way you're facing, hitting everything within its range - face the "
				+ "enemies and cast it now."
			)
		"need_mana_potion":
			TutorialManager.set_allowed_actions(["item:mana"])
			TutorialManager.show_popup(
				"Not enough mana to cast it yet - drink your Mana Potion first."
			)
		"cast_ultimate_ready":
			TutorialManager.set_allowed_actions(["skill:the_sunken_one"])
			TutorialManager.show_popup(
				"Mana's topped up - go ahead and cast The Sunken One."
			)
		"mop_up":
			TutorialManager.set_allowed_actions(["attack"])
			TutorialManager.show_popup(
				"That should have thinned the crowd out considerably - finish off whatever's still "
				+ "standing."
			)
		"zone_cleared":
			_battle_over = true
			TutorialManager.set_allowed_actions([])
			_update_action_buttons()
			TutorialManager.show_popup(
				"That's every stage of your home zone cleared. From here the world is yours to explore. "
				+ "Other lost souls wander its ruins, each carrying their own scars, secrets, and reasons to fight.\n"
				+ "Some may be looking for you already.\n"
				+ "The forgotten world is waiting.",
				TutorialManager.exit_tutorial
			)

	_apply_tutorial_gate()


## Explains reinforcements the first time they arrive during stage 3
## (see _tutorial_maybe_explain_reinforcements() for stage 1's own,
## separate one-shot flag) - called from _spawn_reinforcements()
## alongside its own normal banner. Unlike stage 1's version, this one
## DOES drive the script forward: reinforcements arriving is exactly
## the cue to force The Sunken One.
func _tutorial_maybe_advance_stage3_for_reinforcements() -> void:
	if not TutorialManager.is_active or TutorialManager.current_stage != 3 \
	or _tutorial_stage3_step != "attack_before_reinforcements":
		return
	_advance_tutorial_stage3_step("cast_ultimate")


func _handle_defeat() -> void:
	_play_log_stage_end("defeat")
	_battle_over = true
	_update_action_buttons()
	PlayerManager.record_high_score()

	# A rival hero that just won a duel restocks the potions it spent
	# surviving it, same as EnemyHeroManager's own simulated fights do
	# right after theirs (see npc_shop()) - otherwise a
	# player who keeps losing to the same rival would slowly bleed it
	# dry of potions it can never buy back.
	if _in_hero_fight:
		EnemyHeroManager.npc_shop(_enemy_hero_id)

	var hero_animator := CreatureAnimator.of(hero_image)
	if hero_animator != null:
		hero_animator.play_death(false)

	defeat_popup.visible = true
	print("Hero defeated.")


# ------------------------------------------------------------------
# The rival hero aiming single-target skills at the player's Spirit
# Bear (see ENEMY_BEAR_TARGETABLE_SKILLS). The player is still the
# default target; the bear is picked when the player can't be hit
# (out of range, hidden), isn't worth hitting (already carries that
# skill's DoT), or when the hit would likely finish the bear off - see
# _choose_enemy_skill_on_bear(). Everything a skill does to the player
# has a bear-side counterpart below, stored on the _bear Dictionary
# itself and ticked by _tick_bear_turn_start_effects()/_bear_turn().
# ------------------------------------------------------------------

## Whether `skill_id` would be worth casting on the player (`on_bear`
## false) or on his Elderwild Companion (`on_bear` true) right now - only the
## DoT skills have a "not worth restarting" rule (see
## _enemy_skill_worth_casting()'s own comments); everything else is
## always worth it.
func _enemy_skill_worth_on_target(skill_id: String, on_bear: bool) -> bool:
	var field: String = ""
	match skill_id:
		"mark_of_stillness":
			field = "mark_of_stillness_dot_turns_left"
			if not on_bear:
				return _player_mark_of_stillness_dot_turns_left <= 0
		"the_hollow_cold":
			field = "the_hollow_cold_dot_turns_left"
			if not on_bear:
				return _player_the_hollow_cold_dot_turns_left <= 0
		"winters_grip":
			field = "winters_grip_dot_turns_left"
			if not on_bear:
				return _player_winters_grip_dot_turns_left <= 0
		"sanguine_bloom":
			field = "sanguine_bloom_dot_turns_left"
			if not on_bear:
				return _player_sanguine_bloom_dot_turns_left <= 0
		_:
			return true
	return int(_bear.get(field, 0)) <= 0


## Which of the two possible targets `skill_id` could land on right
## now: {"hero": bool, "bear": bool}. The player needs to be visible
## (see _enemy_ai_hero_hidden) and in range; the bear needs to be out
## and in range - each also has to be worth hitting
## (_enemy_skill_worth_on_target()). `ignore_range` skips both range
## checks, same as _is_enemy_skill_ready()'s own flag.
func _enemy_skill_target_options(skill_id: String, enemy_type: String, hero_distance: int, enemy: Dictionary, ignore_range: bool = false) -> Dictionary:
	var hero_ok: bool = not _enemy_ai_hero_hidden \
		and (ignore_range or _enemy_skill_in_range(skill_id, enemy_type, hero_distance, enemy)) \
		and _enemy_skill_worth_on_target(skill_id, false)
	var bear_ok: bool = false
	if _is_bear_alive():
		var bear_distance: int = _distance(enemy["pos_index"], _bear["pos_index"])
		bear_ok = (ignore_range or _enemy_skill_reaches_distance(skill_id, enemy_type, bear_distance)) \
			and _enemy_skill_worth_on_target(skill_id, true)
	return {"hero": hero_ok, "bear": bear_ok}


## Decides, for one cast of a bear-targetable `skill_id`, whether the
## rival aims it at the player's Elderwild Companion. The player stays the
## default; the bear gets it when the player isn't a valid target at
## all, or when this hit would likely kill the bear outright (an
## estimate - see _estimate_enemy_skill_hit_on_bear()).
func _choose_enemy_skill_on_bear(enemy: Dictionary, skill_id: String) -> bool:
	var enemy_type: String = _enemy_hero_attack_type(enemy)
	var hero_distance: int = _distance(enemy["pos_index"], _hero_pos_index)
	var options: Dictionary = _enemy_skill_target_options(skill_id, enemy_type, hero_distance, enemy)
	if not options["bear"]:
		return false
	if not options["hero"]:
		return true
	var level_data: Dictionary = _get_enemy_skill_level_data(skill_id)
	var estimated_hit: float = _estimate_enemy_skill_hit_on_bear(enemy, skill_id, level_data)
	return estimated_hit > 0.0 and estimated_hit >= float(_bear.get("current_hp", 0.0))


## Roughly how much damage `skill_id`'s own immediate hit would do to
## the bear after its armor - only used to judge whether a cast would
## finish it off. DoT-only skills (Thornbind/Mark of Stillness/The Hollow Cold/
## Winter's Grip/Sanguine Bloom/Deathlight Lure/The Hunger Calls) return 0.
func _estimate_enemy_skill_hit_on_bear(enemy: Dictionary, skill_id: String, level_data: Dictionary) -> float:
	var raw: float = 0.0
	match skill_id:
		"whisper_of_the_veil", "drowned_surge", "shackles", "moonfall_lance", "return_to_the_void", "maddening_roar", "charge":
			raw = float(level_data.get("damage", 0))
		"hope_of_the_fallen":
			var distance: int = _distance(enemy["pos_index"], _bear["pos_index"])
			raw = float(level_data.get("base_damage", 0)) + float(level_data.get("bonus_per_column", 0)) * distance
		"touch_of_the_first_cold":
			raw = _roll_enemy_hero_damage(enemy) + float(level_data.get("bonus_damage", 0))
		"glacier_breaker":
			raw = _roll_enemy_hero_damage(enemy) * float(level_data.get("damage_multiplier", 1.0))
		"three_cheers":
			raw = _roll_enemy_hero_damage(enemy) * float(level_data.get("damage_pct", 0)) * int(level_data.get("shots", 3))
	if raw <= 0.0:
		return 0.0
	var bear_armor: float = float(_bear.get("armor", 0)) - float(_bear.get("armor_reduction", 0.0))
	return _apply_armor_reduction(raw * (1.0 + float(_bear.get("deathlight_lure_bonus_pct", 0.0))), bear_armor)


## Floating text over the bear (e.g. "Stunned!") - the bear-side
## counterpart of _show_message_over_hero().
func _show_message_over_bear(text: String) -> void:
	if _is_bear_alive() and is_instance_valid(_bear.get("node")):
		_show_message_over_enemy(_bear["node"], text)


## Every DoT/timed debuff a rival has put on the player's Elderwild Companion,
## ticked once per turn at the start of the player's own turn (from
## _tick_player_turn_start_effects(), right after the hero's own) - the
## bear-side mirror of that function's own entries for the same
## skills. Stops as soon as the bear dies. Stun/root tick in
## _bear_turn() instead, when they're actually consulted.
func _tick_bear_turn_start_effects() -> void:
	if not _is_bear_alive():
		return

	for key in ["thornbind", "mark_of_stillness", "the_hollow_cold", "winters_grip"]:
		var turns_key: String = key + "_dot_turns_left"
		if int(_bear.get(turns_key, 0)) > 0:
			_bear[turns_key] -= 1
			var dot: float = float(_bear.get(key + "_dot_damage", 0))
			if dot > 0.0:
				_deal_damage_to_bear(dot)
				if not _is_bear_alive():
					return

	if int(_bear.get("return_to_the_void_dot_turns_left", 0)) > 0:
		_bear["return_to_the_void_dot_turns_left"] -= 1
		var return_to_the_void_dot: float = float(_bear.get("return_to_the_void_dot_damage", 0))
		if return_to_the_void_dot > 0.0:
			_deal_damage_to_bear(return_to_the_void_dot)
			if not _is_bear_alive():
				return
		# Same execute rule the player's own Return to the Void tick uses.
		var execute_pct: float = float(_bear.get("return_to_the_void_execute_pct", 0.0))
		if execute_pct > 0.0 and float(_bear.get("current_hp", 0.0)) <= float(_bear.get("hp", 0.0)) * execute_pct:
			_show_message_over_bear("Claimed by the Void!")
			_kill_bear(true)
			return
		if int(_bear.get("return_to_the_void_dot_turns_left", 0)) <= 0:
			_bear["return_to_the_void_execute_pct"] = 0.0

	if int(_bear.get("sanguine_bloom_dot_turns_left", 0)) > 0:
		_bear["sanguine_bloom_dot_turns_left"] -= 1
		# Captured before the tick - a kill clears _bear and frees the node.
		var seeded_bear_node: Variant = _bear.get("node")
		var sanguine_bloom_dot: float = float(_bear.get("sanguine_bloom_dot_damage", 0))
		if sanguine_bloom_dot > 0.0:
			_deal_damage_to_bear(sanguine_bloom_dot)
		# The healing half goes to the caster (the rival), same as the
		# player-side tick.
		var heal_per_turn: float = float(_bear.get("sanguine_bloom_heal_per_turn", 0.0))
		if heal_per_turn > 0.0:
			var caster: Dictionary = _get_hero_fight_boss()
			if not caster.is_empty():
				var caster_max_hp: float = _enemy_hero_effective_max_hp(caster)
				caster["current_hp"] = minf(caster_max_hp, float(caster.get("current_hp", 0.0)) + heal_per_turn)
				_play_lifesteal_effect(seeded_bear_node, caster.get("node"))
		if not _is_bear_alive():
			return

	if int(_bear.get("armor_reduction_turns_left", 0)) > 0:
		_bear["armor_reduction_turns_left"] -= 1
		if int(_bear.get("armor_reduction_turns_left", 0)) <= 0:
			_bear["armor_reduction"] = 0.0
			_bear["deathlight_lure_bonus_pct"] = 0.0


## Stuns the bear for `turns` of its own turns (see _bear_turn()) - only
## if it survived whatever hit came with the stun.
func _stun_bear(turns: int) -> void:
	if _is_bear_alive() and turns > 0:
		_bear["stun_turns_left"] = turns
		# A fresh stun from anything else replaces The Hunger Calls's
		# freeze / Luring Gaze's sleep - _cast_enemy_the_hunger_calls_
		# on_bear()/_cast_enemy_luring_gaze() set theirs back right
		# after calling here.
		_bear["the_hunger_calls_active"] = false
		_bear["luring_gaze_entranced"] = false
		_bear["venom_paralyzed"] = false
		_show_message_over_bear("Stunned!")


## The hero caught by an AoE centered on the bear (Drowned Surge's splash,
## Return to the Void's radius, Maddening Roar's shards) - only while the
## rival can actually see him, the same visibility rule every other
## rival cast follows.
func _is_hero_in_bear_aoe(radius: int) -> bool:
	return not _enemy_ai_hero_hidden and _is_bear_alive() and _distance(_hero_pos_index, _bear["pos_index"]) <= radius


func _cast_enemy_thornbind_on_bear(level_data: Dictionary) -> void:
	_bear["root_turns_left"] = int(level_data.get("root_turns", 0))
	_bear["thornbind_dot_damage"] = float(level_data.get("dot_damage", 0))
	_bear["thornbind_dot_turns_left"] = int(level_data.get("dot_duration", 0))
	_show_message_over_bear("Thornbound!")
	_play_thornbind_effect(_bear["node"])
	_refresh_thornbind_vines()


func _cast_enemy_whisper_of_the_veil_on_bear(enemy: Dictionary, level_data: Dictionary) -> void:
	_play_whisper_of_the_veil_effect(enemy.get("node"), _bear["node"])
	_deal_damage_to_bear(float(level_data.get("damage", 0)))


func _cast_enemy_drowned_surge_on_bear(level_data: Dictionary) -> void:
	var damage: float = float(level_data.get("damage", 0))
	var radius: int = int(level_data.get("radius", 0))
	var bear_pos: int = _bear["pos_index"]
	_play_drowned_surge_splash(_bear["node"])
	# The splash is centered on the bear - the hero and his guards
	# standing close enough get caught too.
	if _is_hero_in_bear_aoe(radius):
		_play_drowned_surge_splash(hero_image)
		apply_damage(damage)
	_play_drowned_surge_splash_on_guards(_guards, bear_pos, radius)
	_deal_aoe_damage_to_guards(bear_pos, radius, damage)
	_deal_damage_to_bear(damage)
	_stun_bear(int(level_data.get("stun_turns", 1)))


func _cast_enemy_deathlight_lure_on_bear(level_data: Dictionary) -> void:
	_bear["armor_reduction"] = float(_bear.get("armor_reduction", 0.0)) + float(level_data.get("armor_reduction", 0))
	_bear["deathlight_lure_bonus_pct"] = float(level_data.get("bonus_damage_pct", 0.0))
	_bear["armor_reduction_turns_left"] = int(level_data.get("duration", 0))
	_play_deathlight_lure(_get_hero_fight_boss().get("node"), _bear["node"])
	_refresh_deathlight_lure()
	_show_message_over_bear("Deathlight Lure!")


func _cast_enemy_hope_of_the_fallen_on_bear(enemy: Dictionary, level_data: Dictionary) -> void:
	var distance: int = _distance(enemy["pos_index"], _bear["pos_index"])
	var damage: float = float(level_data.get("base_damage", 0)) + float(level_data.get("bonus_per_column", 0)) * distance
	# Played before the hit, which may kill (and free) the bear.
	_play_hope_of_the_fallen_flight(enemy["node"], _bear["node"], distance)
	_show_message_over_bear("Hope of the Fallen!")
	_deal_damage_to_bear(damage)
	_stun_bear(int(level_data.get("stun_turns", 0)))


func _cast_enemy_moonfall_lance_on_bear(level_data: Dictionary) -> void:
	_play_moonfall_lance_impact(_bear["node"])
	_show_message_over_bear("Moonfall Lance!")
	_deal_damage_to_bear(float(level_data.get("damage", 0)))
	_stun_bear(int(level_data.get("stun_turns", 0)))


func _cast_enemy_shackles_on_bear(level_data: Dictionary) -> void:
	_show_message_over_bear("Shackles!")
	_deal_damage_to_bear(float(level_data.get("damage", 0)))
	if _is_bear_alive():
		_bear["root_turns_left"] = int(level_data.get("root_turns", 0))
		_bear["shackled"] = true
		_refresh_shackles()


func _cast_enemy_mark_of_stillness_on_bear(level_data: Dictionary) -> void:
	_bear["mark_of_stillness_dot_damage"] = float(level_data.get("damage", 0))
	_bear["mark_of_stillness_dot_turns_left"] = int(level_data.get("duration", 0))
	_show_message_over_bear("Mark of Stillness!")
	_flash_bounce_hit(_bear["node"], MARK_OF_STILLNESS_FLASH_COLOR)
	_refresh_mark_of_stillness_frost()


func _cast_enemy_the_hollow_cold_on_bear(level_data: Dictionary) -> void:
	var damage: float = float(level_data.get("damage", 0))
	var duration: int = int(level_data.get("duration", 0))
	# Same default as the player's own copy (_resolve_the_hollow_cold_cast()).
	var radius: int = int(level_data.get("radius", 1))
	var bear_pos: int = _bear["pos_index"]

	_bear["the_hollow_cold_dot_damage"] = damage
	_bear["the_hollow_cold_dot_turns_left"] = duration
	_flash_bounce_hit(_bear["node"], MARK_OF_STILLNESS_FLASH_COLOR)
	_show_message_over_bear("The Hollow Cold!")

	# Centered on the bear - the hero and his guards nearby are
	# caught in it as well.
	if _is_hero_in_bear_aoe(radius):
		_player_the_hollow_cold_dot_damage = damage
		_player_the_hollow_cold_dot_turns_left = duration
		_flash_bounce_hit(hero_image, MARK_OF_STILLNESS_FLASH_COLOR)
	_mark_guards_the_hollow_cold(_guards, bear_pos, radius, damage, duration)

	_play_the_hollow_cold_swirl(_bear["node"], radius)
	_open_hollow_cold_tear(_bear["node"], bear_pos, radius, duration, true)
	_refresh_mark_of_stillness_frost()


func _cast_enemy_touch_of_the_first_cold_on_bear(enemy: Dictionary, level_data: Dictionary) -> void:
	var damage: float = _roll_enemy_hero_damage(enemy) + float(level_data.get("bonus_damage", 0))
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	_play_the_reaching_void(enemy.get("node"), _bear.get("node"), func() -> void:
		_rival_fx_in_flight = false
		if not _battle_over and _stage_generation == generation_before:
			_deal_damage_to_bear(damage)
		_update_action_buttons()
	)


func _cast_enemy_return_to_the_void_on_bear(level_data: Dictionary) -> void:
	var damage: float = float(level_data.get("damage", 0))
	var radius: int = int(level_data.get("radius", 0))
	var bear_pos: int = _bear["pos_index"]
	var struck: Array = [_bear.get("node")]
	if _is_hero_in_bear_aoe(radius):
		struck.append(hero_image)
	for guard in _guards:
		if _distance(guard["pos_index"], bear_pos) <= radius:
			struck.append(guard.get("node"))
	_show_message_over_bear("Return to the Void!")
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	_play_return_to_the_void(_bear.get("node"), radius, struck, func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		# The blast's radius is centered on the bear - the hero and his
		# guards nearby take its damage too (the DoT/execute/stun stay on
		# the bear, the one it was aimed at - same as the player-aimed copy
		# only arming them on the player).
		if _is_hero_in_bear_aoe(radius):
			apply_damage(damage)
		_deal_aoe_damage_to_guards(bear_pos, radius, damage)
		_deal_damage_to_bear(damage)
		if _is_bear_alive():
			_bear["return_to_the_void_dot_damage"] = float(level_data.get("dot_damage", 0))
			_bear["return_to_the_void_dot_turns_left"] = int(level_data.get("dot_duration", 0))
			_bear["return_to_the_void_execute_pct"] = float(level_data.get("execute_pct", 0.0))
			_stun_bear(int(level_data.get("stun_turns", 1)))
			_refresh_mark_of_stillness_frost()
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	)


func _cast_enemy_maddening_roar_on_bear(level_data: Dictionary) -> void:
	var damage: float = float(level_data.get("damage", 0))
	var shatter_range: int = int(level_data.get("shatter_range", 0))
	var shatter_damage: float = float(level_data.get("shatter_damage", 0))
	var bear_pos: int = _bear["pos_index"]
	var shatter_nodes: Array = []
	if _is_hero_in_bear_aoe(shatter_range):
		shatter_nodes.append(hero_image)
	for guard in _guards:
		if _distance(guard["pos_index"], bear_pos) <= shatter_range:
			shatter_nodes.append(guard.get("node"))
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var on_target_hit := func() -> void:
		if _battle_over or _stage_generation != generation_before:
			return
		_deal_damage_to_bear(damage)
	# The rings spread out from the bear - the hero and his guards
	# nearby take the shatter damage.
	var on_shatter := func() -> void:
		_rival_fx_in_flight = false
		if _battle_over or _stage_generation != generation_before:
			_update_action_buttons()
			return
		if _is_hero_in_bear_aoe(shatter_range):
			apply_damage(shatter_damage)
		_deal_aoe_damage_to_guards(bear_pos, shatter_range, shatter_damage)
		_refresh_bars()
		if _recruited.get("current_hp", 0) <= 0:
			_handle_defeat()
			return
		_update_action_buttons()
	_play_maddening_roar(_get_hero_fight_boss().get("node"), _enemy_hero_static, _bear.get("node"), shatter_nodes, on_target_hit, on_shatter)


func _cast_enemy_the_hunger_calls_on_bear(level_data: Dictionary) -> void:
	_show_message_over_bear("The Hunger Calls!")
	if _enemy_hunger_calls_fx != null:
		_enemy_hunger_calls_fx.end()
	_enemy_hunger_calls_fx = _play_the_hunger_calls(_get_hero_fight_boss().get("node"), _enemy_hero_static, _bear["node"], int(level_data.get("curse_range", 0)))
	_enemy_hunger_calls_fx_on_bear = true
	_stun_bear(int(level_data.get("duration", 0)))
	# Marks this stun as the curse's freeze (cleared by any other stun,
	# see _stun_bear()) - drives the bear's frost for as long as it holds.
	_bear["the_hunger_calls_active"] = true
	_refresh_mark_of_stillness_frost()


func _cast_enemy_winters_grip_on_bear(level_data: Dictionary) -> void:
	_bear["winters_grip_dot_damage"] = float(level_data.get("dot_damage", 0))
	_bear["winters_grip_dot_turns_left"] = int(level_data.get("dot_duration", 0))
	_show_message_over_bear("Winter's Grip!")
	_flash_bounce_hit(_bear["node"], MARK_OF_STILLNESS_FLASH_COLOR)
	_stun_bear(int(level_data.get("stun_turns", 1)))
	_bear["winters_grip_hold"] = true
	_refresh_mark_of_stillness_frost()
	_refresh_winters_grip_hands()


func _cast_enemy_charge_on_bear(enemy: Dictionary, level_data: Dictionary) -> void:
	var bear_pos: int = _bear["pos_index"]
	_show_message_over_bear("Charge!")

	# Same charge as the player-aimed copy, just ending on the bear's
	# column.
	var charge_direction: int = _step_toward(enemy["pos_index"], bear_pos)
	var landing_pos: int = enemy["pos_index"]
	while charge_direction != 0 and landing_pos != bear_pos:
		var next_pos: int = landing_pos + charge_direction
		if _is_column_frostbound_rupture_blocked(next_pos):
			break
		landing_pos = next_pos
	_rival_fx_in_flight = true
	_update_action_buttons()
	var generation_before: int = _stage_generation
	var damage: float = float(level_data.get("damage", 0))
	var stun: int = int(level_data.get("stun_turns", 1))
	_play_charge(enemy.get("node"), _bear.get("node"), func() -> float:
		var old_x: float = enemy["node"].position.x
		_move_enemy(enemy, landing_pos)
		return old_x - enemy["node"].position.x
	, func() -> void:
		_rival_fx_in_flight = false
		if not _battle_over and _stage_generation == generation_before and _is_bear_alive():
			_deal_damage_to_bear(damage)
			if _is_bear_alive():
				_stun_bear(stun)
			_refresh_bars()
		_update_action_buttons()
	)


func _cast_enemy_glacier_breaker_on_bear(enemy: Dictionary, level_data: Dictionary) -> void:
	var punch_damage: float = _roll_enemy_hero_damage(enemy) * float(level_data.get("damage_multiplier", 1.0))

	# Same knockback rules as the player-aimed copy, applied to the
	# bear: pushed the way the rival is facing, stopped by the board's
	# edge, an enemy's column or a Frostbound Rupture wall - hitting one of
	# those deals 50% extra.
	var knockback_columns: int = int(level_data.get("knockback", 0))
	var direction: int = -1 if enemy["node"].flip_h else 1
	var pos: int = _bear["pos_index"]
	var actual_distance: int = 0
	for i in range(knockback_columns):
		var next_pos: int = pos + direction
		if next_pos < 0 or next_pos >= GRID_COLUMNS:
			break
		if not _get_enemy_at(next_pos).is_empty():
			break
		if _is_column_enemy_frostbound_rupture_blocked(next_pos):
			break
		pos = next_pos
		actual_distance += 1

	var hit_wall: bool = actual_distance < knockback_columns
	if hit_wall:
		punch_damage *= 1.5
		_show_message_over_bear("Wall hit!")

	_deal_damage_to_bear(punch_damage)
	if not _is_bear_alive():
		return
	_bear["pos_index"] = pos
	_bear["node"].flip_h = direction < 0
	_place_bear_node(pos)
	_stun_bear(int(level_data.get("stun_turns", 1)))


func _cast_enemy_sanguine_bloom_on_bear(level_data: Dictionary) -> void:
	_bear["sanguine_bloom_dot_damage"] = float(level_data.get("dot_damage", 0))
	_bear["sanguine_bloom_heal_per_turn"] = float(level_data.get("heal_per_turn", 0))
	_bear["sanguine_bloom_dot_turns_left"] = int(level_data.get("duration", 0))
	_show_message_over_bear("Sanguine Bloom!")


func _cast_enemy_three_cheers_on_bear(enemy: Dictionary, level_data: Dictionary) -> void:
	var shots: int = int(level_data.get("shots", 3))
	var damage_pct: float = float(level_data.get("damage_pct", 0))
	var armor_reduction_per_shot: float = float(level_data.get("armor_reduction_per_shot", 0))
	var bear_pos: int = _bear["pos_index"]

	_show_message_over_bear("Three Cheers!")
	for i in range(shots):
		if not _is_bear_alive():
			break
		_play_three_cheers_shot_effect(bear_pos, i * 0.11, enemy["node"])
		_deal_damage_to_bear(_roll_enemy_hero_damage(enemy) * damage_pct)
		if not _is_bear_alive():
			break
		_bear["armor_reduction"] = float(_bear.get("armor_reduction", 0.0)) + armor_reduction_per_shot

	if _is_bear_alive():
		_bear["armor_reduction_turns_left"] = int(level_data.get("duration", 0))


## The rival's Whisper of the Veil on himself - the mirror of the player's own
## _resolve_whisper_of_the_veil_self_cast(): pays `level_data.hp_cost` straight
## off his current HP (no armor, no shield - it's a cost, not a hit),
## then heals `level_data.heal`, capped at his effective max HP. Only
## ever reached when _enemy_whisper_of_the_veil_self_ready() already confirmed he
## can afford the cost without dying.
func _cast_enemy_whisper_of_the_veil_on_self(enemy: Dictionary, level_data: Dictionary) -> void:
	var hp_before: float = float(enemy.get("current_hp", 0.0))
	var max_hp: float = _enemy_hero_effective_max_hp(enemy)
	var after_cost: float = maxf(1.0, hp_before - float(level_data.get("hp_cost", 0)))
	enemy["current_hp"] = minf(max_hp, after_cost + float(level_data.get("heal", 0)))

	_play_whisper_of_the_veil_effect(enemy.get("node"), enemy.get("node"))
	if is_instance_valid(enemy.get("node")):
		var gain: int = roundi(float(enemy["current_hp"]) - hp_before)
		_show_message_over_enemy(enemy["node"], "Whisper of the Veil +%d" % gain)
	_refresh_enemy_overhead_labels()
