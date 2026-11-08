# Terrain and battlefield effects (agreed direction, not implemented yet)

The battlefield is a single lane of `GRID_COLUMNS` (10) columns, so a terrain effect always targets one column.

## Core rules
- A **zone hazard** picks one random column every 4 turns and acts on it in two stages.
  - **Stage 1 (hint, visual only):** on turn 3, then 7, 11, ... a marker shows which column will be hit. No gameplay effect.
  - **Stage 2 (effect):** on turn 4, then 8, 12, ... the effect takes place in that column.
  - The effect lasts until the end of the player's next turn, then disappears. The next cycle starts counting from there (hint on 7, effect on 8, ...).
- Effects are always **penalties that are not damage**: miss chance, stopped movement, reduced range or visibility, and so on. Never HP loss.
- **Who is affected:** the player and invading rival heroes, only in a zone that is not their home zone.
- **Who is immune:**
  - Creeps, always and completely.
  - The player and rivals in their own home zone.
  - If the player fights a rival in a zone that is home to both (a zone with two available heroes), both are immune.
  - The zone's own hero in a duel is immune (home zone); an invading player or rival is not.

## First slice: The Blackbloom
Zone: `the_blackbloom`. One hazard: the **bloom**.

- **Stage 1:** a dark blue-purple flower appears in the chosen column.
- **Stage 2:** the flower blooms and releases a purple mist that fills the column.
- **Exposure:** an affected hero is exposed if they are in the column when the mist appears, or if they pass through the column during their turn while the mist is active.
- **Poisoned:** in the exposed hero's next turn they get the "poisoned" status: **40% chance to miss their attack**. The status is removed at the end of that turn.
- Creeps in the mist are unaffected.

## Confirmed details
1. **Turn** = one full round (hero action, then enemies), numbered from 1, counter reset at the start of each battle.
2. **Mist timing:** the mist appears before the player acts on turn 4 and stays until the creeps and the rival hero have finished their turn. A hero exposed on turn 4 is poisoned on turn 5.
3. **Passing through:** crossing a mist column in one move counts as exposure even if the move ends past it, for the player and the rival alike, including skill moves (lunges, charges, pushes). The only exception is Undertow's teleport (`_hazard_move_ignored`); more exceptions will be flagged per skill.
4. **What poisoned affects:** all basic attacks, and every skill that targets an enemy. Unaffected: AoE damage, skills that do not target, and skills that hit enemies in a path or around the caster.
5. **Rival heroes in the mist** are exposed under the same rules; `EnemySkillAI` should avoid ending its move in a visible hint or mist column when it is not immune.
6. **Background simulation:** to be brainstormed after the in-battle effect is finished (rivals in the background do not play a lane, so they need an abstract version, e.g. a small power penalty in a hostile zone).

## Implementation status (first slice, untested in play)
Built in `scripts/battle.gd` (`_hazard_*`, `_player_poison_*`, `_rival_poison_*`) and `scripts/BloomHazardFX.gd` (a dark purple lotus that opens into a purple mist; the mist is always shown, whether or not anyone is in the column).
- Cycle runs off `_turn_count + 1` (hint on turns 3, 7, 11, bloom on 4, 8, 12); it restarts for every stage and hero fight.
- The hazard only runs in zones listed in `GameManager.ZONE_HAZARDS` (The Blackbloom, The Verdant Scar, The Scorchlands, Kingdom of Morvain, The Drowned Empire), and only if someone in the fight can be affected (the player away from home, or a rival away from home).
- Exposure: standing in the column as it blooms, or any hero movement that crosses or ends in it (hooked into `_update_hero_position`, so lunges and teleports count too).
- Poisoned: set at the start of the next turn (`Poisoned!` message over the hero and a green raindrop badge next to the health bar), cleared at the end of that turn. Basic attacks and click-targeted skills (`POISON_MISSABLE_SKILLS`) miss 40% of the time; a missed skill still spends mana, cooldown and the turn.
- Rival: exposed if standing in the column at the bloom, or if any of its moves (`_move_enemy()`) crosses or ends in the mist while it is up; its basic attack and its `POISON_MISSABLE_SKILLS` can miss while poisoned.

### Not done yet
- (done) Rival skills in `POISON_MISSABLE_SKILLS` also miss while poisoned, in `_cast_enemy_skill`: mana and cooldown are spent, the effect is skipped.
- (done, untested in play) Rival avoids the hazard on its plain moves: `_rival_avoids_hazard_column()` in `battle.gd` stops its walk, flee and Hunting Instinct moves from ending in the hinted column, or from crossing or ending in the mist. Not handled: a rival standing in the hinted column does not sidestep if it attacks or casts instead of moving, and its skill moves do not avoid the hint or mist (they do count as exposure).
- Skills that act on an enemy without a click (e.g. Barbed Lunge) are treated as path skills and are unaffected; review `POISON_MISSABLE_SKILLS` against the hero list.
- (done, untested in play) Abstract version for the background simulation, see below.
- No sound for the bloom.

## Background simulation version
Shared numbers live in `GameManager.ZONE_HAZARDS` (per zone: `interval`, `miss_chance`, `sim_exposure_chance`) and `GameManager.POISON_MISSABLE_SKILLS`; both `battle.gd` and `EnemyHeroManager` read them.
- In `EnemyHeroManager._run_stage_fight` the sim has no columns, so on every bloom turn (4, 8, 12, ...) a hero away from home is exposed with `sim_exposure_chance` (25% in both zones) and poisoned on the next turn only.
- Poisoned hero: basic attack and `POISON_MISSABLE_SKILLS` miss at `miss_chance`. A missed skill still spends mana and cooldown; a missed attack deals no damage and has no on-hit effects.
- Heroes at home in the zone, and creeps, are unaffected.
- Poison-caused failed attempts are not surfaced in "While you were away" for now.

## Second zone: The Verdant Scar
Zone: `the_verdant_scar`. Same rules and numbers as the Blackbloom (interval 4, 40% miss, 25% sim exposure), only the look differs. Per-zone look lives in `GameManager.ZONE_HAZARDS` (`flower`, `text_color`) and `BloomHazardFX.STYLES`.
- **Stage 1:** a blood red bell flower rises on an arching stalk in the chosen column, bell hanging mouth-down.
- **Stage 2:** the bell opens (rim flares, glowing clapper) and releases a blood red mist.
- "Poisoned!" and "Missed! (poisoned)" text is red here. The poison badge next to the health bar is still the green raindrop (untested in play).

## Third zone: The Scorchlands (blind)
Zone: `scorchlands`. Same cycle, exposure and mist-timing rules as the Blackbloom (hint on turn 3, 7, ...; effect on 4, 8, ...; the storm stays until the enemies are done; passing through counts, Undertow excepted), but the affliction is **blind** instead of poison (`effect: "blind"` in `GameManager.ZONE_HAZARDS`; `_player_poisoned` / `_rival_poisoned` mean "afflicted" for either effect).
- **Stage 1:** a small dust cloud boils up right above the ground in the chosen column (`BloomHazardFX` style `"sand"`).
- **Stage 2:** a sandstorm fills the column: tan wash, rolling dust billows, wind-blown grains.
- **Blind** (the hero's next turn, same timing as poison; the badge is a closed eye, the message "Blinded!"): the hero only sees its own and the adjacent columns (`BLIND_VISION = 1`). Attacks and targeted skills can only pick enemies there; with none, the message is "No target" (`_no_target_message()`).
  - Implemented in the `_start_*targeting()` functions and `_player_attack_can_reach()` via `_is_target_blinded()`. AoE and path skills (Sweep, Barbed Lunge, ...) ignore sight, same as they ignore poison.
  - Rival: a blind rival more than 1 column from the player cannot attack or cast on him, but keeps walking toward him (`hero_unseen` in `_enemy_hero_turn()`). Creeps are immune.
- **Background simulation:** no columns, so on every effect turn (4, 8, 12, ...) an invading rival (away from home) skips its whole turn with `sim_skip_chance` (30%). No poison-style exposure or misses in this zone.
- Untested in play. Tuning numbers: `sim_skip_chance`, `BLIND_VISION`.
- **Vision view:** while the player is blind, `BlindVisionFX` (shader `shaders/blind_vision.gdshader`) covers the battlefield in a soft, slowly shifting shadow with an elliptical window of clear sight around the hero (about 1.5 columns wide each way, a little over a hero-height tall), so the tops and bottoms of the adjacent columns fade out too. It sits above the fighters and below the battle UI, glides with the hero and fades away when the blindness ends (`_refresh_blind_vision()`). Look is tuned by the ellipse radii in `battle.gd` and `clear_until` / `dark_from` / `darkness` in the shader.
- The Scorchlands arena's background wind (`ScorchlandsBattleAtmosphere.gd`) keeps its yellow blown-sand streaks and gusts, but has no dust banks.

## Fourth zone: Kingdom of Morvain (mist wall)
Zone: `kingdom_of_morvain`. Same cycle (hint on turn 3, 7, ...; wall on 4, 8, ...; the wall stays until the enemies are done). Unlike the other zones nobody is poisoned or blinded: `effect: "mist_wall"` only changes who can see whom, so there is no exposure, no badge and no avoidance by the rival (`_hazard_afflicts()` is false). Heroes at home in Morvain are not hindered; if the player is at home the wall is still drawn but they see normally.
- **Stage 1:** pale mist gathers low along the floor of the chosen column (`BloomHazardFX` style `"mist"`).
- **Stage 2:** the mist shoots up (`_mist` tween, expo ease-out) into a tall wall (`column_height` 0.55 of the screen height).
- **Sight rules** (`_vision_between(viewer, target)` in `battle.gd`, used for the player in `_is_target_blinded()` and for the rival in `hero_unseen`):
  - Viewer outside the wall: sees its own side clearly; the wall's column and the one column right behind it through **fog** (visible, targetable); everything further behind is **in shadow** (not targetable; message "No target").
  - Viewer inside the wall column: like blind, only the adjacent columns are visible, but through fog instead of clear.
  - AoE and path skills ignore sight, as with blind.
- **Vision view:** `MistVisionFX` + `shaders/mist_vision.gdshader` over the fighters. Fog = the scene blurred (screen texture mip) and washed toward grey-white with drifting thin/thick patches; shadow = the same colour as the blind shadow. Inside the wall it reuses the blind ellipse with the adjacent columns fogged and the hero's own column sharp. Tuning: `fog_strength`, `fog_blur`, `feather` in the shader.
- **Rival:** a rival the wall hides the player from can't attack or cast on him but keeps walking toward him.
- **Background simulation:** `sim_skip_chance` 20% - an invading rival loses its turn on effect turns (4, 8, ...).
- Untested in play. Creeps ignore the wall's sight limits.

## Rival avoidance (general rule for every hazard)
`_rival_avoids_hazard_column()` is not tied to one zone: it reads the hazard's `avoid` rule from `GameManager.HAZARD_EFFECT_RULES` (per `effect`, overridable per zone in `ZONE_HAZARDS`; unlisted effects behave like poison). Modes: `"cross"` (poison, blind) - never end in the hinted column, never cross or end in the column while it is up; `"end"` (mist wall) - never end a move in the hinted/active column, passing through is fine; `"none"`. `afflicts` (same table) says whether standing in / crossing it afflicts a hero. To add a hazard: add its zone to `ZONE_HAZARDS`, and if it has a new `effect`, one line in `HAZARD_EFFECT_RULES`. The rival's walk, flee and Hunting Instinct moves already ask this function. Still not handled: a rival already standing in the hinted column doesn't sidestep if it attacks or casts instead of moving, and its skill moves aren't steered.

## Fifth zone: The Drowned Empire (blind, octopus + ink)
Zone: `drowned_empire`. Uses the blind effect exactly as in the Scorchlands (`effect: "blind"`, 30% `sim_skip_chance`, same exposure / timing / avoidance rules); only the look differs (`flower: "ink"`, `BloomHazardFX` style `"ink"`).
- **Stage 1:** a dark teal octopus rises out of the floor of the chosen column and rests there, arms spread (mottled skin, amber slit-pupil eyes, tapering arms with suckers, faint glowing spots).
- **Stage 2:** it jets up the column (arms streaming behind it) leaving a black ink cloud that fills the column below it; at the top the octopus fades out, the ink stays until the enemies are done.
- Drawn entirely in code (`_draw_octopus()`, `_draw_ink()`), untested in play. Tuning: `OCTO_*` colours, `_octo_scale()`, swim time (1.3 s) in `bloom()`.
