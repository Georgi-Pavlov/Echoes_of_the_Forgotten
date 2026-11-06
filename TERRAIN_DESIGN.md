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
2. **Mist timing:** the mist appears before the player acts on turn 4 and disappears when the creeps or the rival hero take their action. A hero exposed on turn 4 is poisoned on turn 5.
3. **Passing through:** crossing a mist column in one move counts as exposure even if the move ends past it. Exceptions will be flagged per skill.
4. **What poisoned affects:** all basic attacks, and every skill that targets an enemy. Unaffected: AoE damage, skills that do not target, and skills that hit enemies in a path or around the caster.
5. **Rival heroes in the mist** are exposed under the same rules; `EnemySkillAI` should avoid ending its move in a visible hint or mist column when it is not immune.
6. **Background simulation:** to be brainstormed after the in-battle effect is finished (rivals in the background do not play a lane, so they need an abstract version, e.g. a small power penalty in a hostile zone).

## Implementation status (first slice, untested in play)
Built in `scripts/battle.gd` (`_hazard_*`, `_player_poison_*`, `_rival_poison_*`) and `scripts/BloomHazardFX.gd` (a dark purple lotus that opens into a purple mist; the mist is always shown, whether or not anyone is in the column).
- Cycle runs off `_turn_count + 1` (hint on turns 3, 7, 11, bloom on 4, 8, 12); it restarts for every stage and hero fight.
- The hazard only runs in The Blackbloom, and only if someone in the fight can be affected (the player away from home, or a rival away from home).
- Exposure: standing in the column as it blooms, or any hero movement that crosses or ends in it (hooked into `_update_hero_position`, so lunges and teleports count too).
- Poisoned: set at the start of the next turn (`Poisoned!` message over the hero and a green raindrop badge next to the health bar), cleared at the end of that turn. Basic attacks and click-targeted skills (`POISON_MISSABLE_SKILLS`) miss 40% of the time; a missed skill still spends mana, cooldown and the turn.
- Rival: exposed only if standing in the column at the bloom (the mist is gone before it acts); its basic attack and its `POISON_MISSABLE_SKILLS` can miss while poisoned.

### Not done yet
- (done) Rival skills in `POISON_MISSABLE_SKILLS` also miss while poisoned, in `_cast_enemy_skill`: mana and cooldown are spent, the effect is skipped.
- `EnemySkillAI` does not yet steer the rival away from a hint or mist column.
- Skills that act on an enemy without a click (e.g. Barbed Lunge) are treated as path skills and are unaffected; review `POISON_MISSABLE_SKILLS` against the hero list.
- (done, untested in play) Abstract version for the background simulation, see below.
- No sound for the bloom.

## Background simulation version
Shared numbers live in `GameManager.ZONE_HAZARDS` (per zone: `interval`, `miss_chance`, `sim_exposure_chance`) and `GameManager.POISON_MISSABLE_SKILLS`; both `battle.gd` and `EnemyHeroManager` read them.
- In `EnemyHeroManager._run_stage_fight` the sim has no columns, so on every bloom turn (4, 8, 12, ...) a hero away from home is exposed with `sim_exposure_chance` (25% for the Blackbloom) and poisoned on the next turn only.
- Poisoned hero: basic attack and `POISON_MISSABLE_SKILLS` miss at `miss_chance`. A missed skill still spends mana and cooldown; a missed attack deals no damage and has no on-hit effects.
- Heroes at home in the zone, and creeps, are unaffected.
- Poison-caused failed attempts are not surfaced in "While you were away" for now.
