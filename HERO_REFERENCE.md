# Hero reference (snapshot)

Generated from the live hero data in `GameManager.gd` - a snapshot to compare against while rebalancing. Edit `GameManager.gd` for real changes; this file is not read by the game.

## Global stat rules

- +1 Strength = +22 max HP (and +0.25 HP regen per turn in battle)
- +1 Agility = +0.167 armor
- +1 Intelligence = +12 max mana (and +0.1 mana regen per turn in battle)
- +1 of the hero's main stat = +1 damage
- Max hero level: 30

---

## Veyrik

- id: `veyrik`   zone: `the_iron_abyss`
- type: Melee   main stat: Agility
- base attributes: Strength 20 / Agility 21 / Intelligence 16
- base combat: HP 560, Mana 260, Armor 1.5, Damage 55-61, Range 150, Speed 1
- growth per level: Strength +2.2 / Agility +1.3 / Intelligence +1.6

### Skills

**Leeching Hunger** (`leeching_hunger`, standard)

Veyrik awakens a ravenous hunger within himself. For several turns, his next melee attacks tear a fragment of the target's main attribute from them, weakening the victim and feeding Veyrik's strength.

- L1: attacks=2, steal_per_hit=1, duration=4, mana_cost=30, cooldown=3
- L2: attacks=3, steal_per_hit=1, duration=4, mana_cost=35, cooldown=3
- L3: attacks=3, steal_per_hit=1, duration=5, mana_cost=40, cooldown=3
- L4: attacks=4, steal_per_hit=1, duration=6, mana_cost=45, cooldown=3

**Abyssal Spasm** (`abyssal_spasm`, standard)

Veyrik violently convulses, releasing a burst of unnatural force around himself. Enemies caught within it suffer damage and are silenced.

- L1: damage_multiplier=0.75, radius=0, mana_cost=65, cooldown=4
- L2: damage_multiplier=1, radius=0, mana_cost=70, cooldown=4
- L3: damage_multiplier=1.25, radius=0, mana_cost=75, cooldown=3
- L4: damage_multiplier=1.5, radius=1, mana_cost=80, cooldown=3

**Barbed Lunge** (`barbed_lunge`, standard)

Veyrik launches himself forward with violent speed, impaling the first enemy hero he reaches and leaving them stunned.

- L1: distance=2, stun_turns=1, mana_cost=75, cooldown=5
- L2: distance=3, stun_turns=1, mana_cost=80, cooldown=5
- L3: distance=3, stun_turns=2, mana_cost=90, cooldown=4
- L4: distance=4, stun_turns=2, mana_cost=100, cooldown=4

**Depthsveil** (`depthsveil`, ultimate)

Ultimate: Veyrik slips beneath a veil of unnatural darkness, becoming invisible and untouchable. His next attack while concealed tears into his victim with increased force and ends the veil early. If he does not attack, the effect eventually fades.

- L1: duration=2, bonus_damage=20, mana_cost=80, cooldown=8
- L2: duration=3, bonus_damage=35, mana_cost=90, cooldown=7
- L3: duration=4, bonus_damage=50, mana_cost=100, cooldown=6

---

## Erynd

- id: `erynd`   zone: `the_elderwild`
- type: Range   main stat: Agility
- base attributes: Strength 17 / Agility 24 / Intelligence 13
- base combat: HP 473, Mana 169, Armor 3.4, Damage 38-42, Range 550, Speed 1
- growth per level: Strength +2.2 / Agility +1.6 / Intelligence +1.6

### Skills

**Elderwild Companion** (`elderwild_companion`, standard)

Erynd calls upon the ancient spirit of the Elderwild, taking shape as a massive spectral bear that fights at his side until slain. The beast acts on its own each turn, attacking enemies in its column or moving toward the nearest foe when none are within reach. When the companion is slain, the bond tears violently, causing Erynd to lose 20% of his maximum HP, though the backlash can never kill him. Calling the spirit again replaces the existing companion with a new one at the skill's current level.

- L1: hp=300, damage_min=25, damage_max=30, armor=3, speed=1, mana_cost=80, cooldown=8
- L2: hp=400, damage_min=32, damage_max=38, armor=4, speed=1, mana_cost=90, cooldown=7
- L3: hp=525, damage_min=40, damage_max=47, armor=5.5, speed=1, mana_cost=100, cooldown=6
- L4: hp=675, damage_min=50, damage_max=58, armor=7, speed=2, mana_cost=110, cooldown=5

**Thornbind** (`thornbind`, standard)

Erynd awakens the roots beneath a targeted enemy, binding it to the earth. The victim cannot move and is silenced while bound, though it can still attack if an enemy is within range. Ancient thorns continue to tear into the trapped foe, dealing damage over time for the duration of the binding.

- L1: root_turns=1, silence_turns=1, dot_damage=15, dot_duration=2, mana_cost=50, cooldown=3
- L2: root_turns=1, silence_turns=1, dot_damage=25, dot_duration=2, mana_cost=55, cooldown=3
- L3: root_turns=2, silence_turns=2, dot_damage=30, dot_duration=3, mana_cost=60, cooldown=4
- L4: root_turns=2, silence_turns=2, dot_damage=50, dot_duration=3, mana_cost=65, cooldown=4

**Wildbond** (`wildbond`, standard)

Erynd strengthens his bond with the living wilderness, hardening his body and drawing vitality from those he strikes. He gains bonus armor and restores a portion of his health whenever one of his Attacks deals damage. The Wildbond feeds only on physical attacks; skill damage cannot trigger its healing.

- L1: lifesteal_pct=0.05, bonus_armor=2, duration=3, mana_cost=50, cooldown=5
- L2: lifesteal_pct=0.08, bonus_armor=3, duration=3, mana_cost=55, cooldown=5
- L3: lifesteal_pct=0.11, bonus_armor=4, duration=4, mana_cost=60, cooldown=4
- L4: lifesteal_pct=0.14, bonus_armor=5, duration=4, mana_cost=65, cooldown=4

**Blood of the Wild** (`blood_of_the_wild`, passive)

Passive: when Erynd is brought below half of his maximum HP, the ancient beast within him awakens. Erynd and his Elderwild Companion move faster and suffer reduced damage while he remains wounded. The effect fades only after Erynd recovers to 80% of his maximum HP or higher.

- L1: bonus_movement=1, damage_reduction_pct=0.05
- L2: bonus_movement=1, damage_reduction_pct=0.1
- L3: bonus_movement=2, damage_reduction_pct=0.15
- L4: bonus_movement=2, damage_reduction_pct=0.2

**Beast of the Elderwild** (`beast_of_the_elderwild`, ultimate)

Ultimate: Erynd surrenders himself to the ancient spirit bound within his blood, transforming into a monstrous bear-like beast. The transformation grants bonus HP and increased damage, with the additional HP granted immediately and removed when the transformation ends. While transformed, Erynd fights only at melee range, regardless of his normal attack range.

- L1: bonus_hp=150, bonus_damage=15, duration=4, mana_cost=100, cooldown=10
- L2: bonus_hp=250, bonus_damage=25, duration=5, mana_cost=110, cooldown=9
- L3: bonus_hp=350, bonus_damage=35, duration=6, mana_cost=120, cooldown=8

---

## Morvael, the Mistborn

- id: `morvael`   zone: `kingdom_of_morvain`
- type: Melee   main stat: Strength
- base attributes: Strength 22 / Agility 23 / Intelligence 19
- base combat: HP 604, Mana 303, Armor 3.8, Damage 40-50, Range 150, Speed 1
- growth per level: Strength +2.2 / Agility +1.3 / Intelligence +1.6

### Skills

**Whisper of the Veil** (`whisper_of_the_veil`, standard)

Morvael sends a tendril of living mist toward a target. Against an enemy, the mist tears away at its life force, dealing damage. When directed into Morvael himself (double tap the skill button), the mist consumes a portion of his physical essence before knitting his form back together, costing HP but restoring more in return.

- L1: heal=80, damage=80, hp_cost=30, mana_cost=35, cooldown=3
- L2: heal=120, damage=120, hp_cost=40, mana_cost=40, cooldown=3
- L3: heal=160, damage=160, hp_cost=50, mana_cost=45, cooldown=2
- L4: heal=200, damage=200, hp_cost=60, mana_cost=50, cooldown=2

**Veil of the Forgotten** (`veil_of_the_forgotten`, standard)

Morvael surrounds himself with a dense veil of living mist that absorbs incoming damage and strips away all negative effects upon its formation. If the veil is broken by force, the imprisoned mist erupts outward, lashing nearby enemies with the echoes of those lost within Morvain.

- L1: shield_hp=100, aoe_damage=50, radius=0, duration=3, mana_cost=50, cooldown=5
- L2: shield_hp=150, aoe_damage=75, radius=0, duration=3, mana_cost=55, cooldown=5
- L3: shield_hp=200, aoe_damage=100, radius=1, duration=4, mana_cost=60, cooldown=4
- L4: shield_hp=250, aoe_damage=125, radius=1, duration=4, mana_cost=65, cooldown=4

**Mark of the Mist** (`mark_of_the_mist`, passive)

Passive: every attack leaves a fragment of Morvael's mist clinging to the target. The fragments accumulate with each successive strike. When enough mist has gathered, it consumes the victim's voice and vitality, silencing them and dealing damage over time. The fragments dissipate if the target remains untouched for 3 turns.

- L1: hits_to_activate=3, silence_turns=1, dot_damage=15, dot_duration=2
- L2: hits_to_activate=3, silence_turns=1, dot_damage=25, dot_duration=2
- L3: hits_to_activate=2, silence_turns=2, dot_damage=30, dot_duration=3
- L4: hits_to_activate=2, silence_turns=2, dot_damage=35, dot_duration=3

**The Mist Remembers** (`the_mist_remembers`, ultimate)

Ultimate: Not cast - automatically activates when Morvael's HP falls to this level's threshold. For the duration, the mist refuses to let its creation disperse. Every attack that would harm Morvael is instead consumed by the mist and transformed into healing. While the effect lasts, Morvael cannot be brought closer to death by incoming attacks.

- L1: auto_activate_hp_pct=0.3, duration=3, heal_conversion_pct=1, cooldown=10
- L2: auto_activate_hp_pct=0.3, duration=4, heal_conversion_pct=1, cooldown=9
- L3: auto_activate_hp_pct=0.3, duration=5, heal_conversion_pct=1, cooldown=8

---

## Kaelen Varr, the Drowned Captain

- id: `kaelen_varr`   zone: `the_ironbound_isles`
- type: Melee   main stat: Strength
- base attributes: Strength 24 / Agility 14 / Intelligence 18
- base combat: HP 648, Mana 291, Armor 4.3, Damage 50-60, Range 150, Speed 1
- growth per level: Strength +3.6 / Agility +1.6 / Intelligence +1.8

### Skills

**Drowned Surge** (`drowned_surge`, standard)

Kaelen calls a violent surge from the depths beneath his target. The water erupts upward without warning, damaging and stunning the enemy. At maximum strength, the surge spills outward and catches nearby enemies as well.

- L1: damage=60, stun_turns=1, range=3, radius=0, mana_cost=50, cooldown=5
- L2: damage=90, stun_turns=1, range=3, radius=0, mana_cost=55, cooldown=5
- L3: damage=120, stun_turns=2, range=3, radius=0, mana_cost=65, cooldown=4
- L4: damage=150, stun_turns=2, range=3, radius=1, mana_cost=75, cooldown=4

**Pull of the Abyss** (`pull_of_the_abyss`, passive)

Passive: every few attacks, Kaelen's blade carries the crushing pull of the deep, empowering the strike and tearing through nearby enemies with a portion of its force.

- L1: hits_to_activate=3, bonus_damage=15, cleave_columns=1, cleave_damage_pct=0.5
- L2: hits_to_activate=3, bonus_damage=25, cleave_columns=1, cleave_damage_pct=0.6
- L3: hits_to_activate=2, bonus_damage=35, cleave_columns=1, cleave_damage_pct=0.7
- L4: hits_to_activate=2, bonus_damage=45, cleave_columns=2, cleave_damage_pct=0.75

**Undertow** (`undertow`, standard)

Kaelen marks an enemy with a strange nautical sigil. On his next turn, the mark pulls him instantly to the enemy's current position, regardless of where the target has moved. The movement costs no turn and deals no damage.

- L1: range=2, mana_cost=40, cooldown=5
- L2: range=3, mana_cost=45, cooldown=5
- L3: range=4, mana_cost=50, cooldown=4
- L4: range=5, mana_cost=55, cooldown=4

**The Sunken One** (`the_sunken_one`, ultimate)

Ultimate: Kaelen summons the ship that carried him to the bottom of the sea. The Sunken One rises from behind him and unleashes a devastating broadside in the direction Kaelen is facing, damaging every enemy caught in its path.

- L1: damage=200, range=4, mana_cost=100, cooldown=10
- L2: damage=300, range=5, mana_cost=110, cooldown=9
- L3: damage=400, range=6, mana_cost=120, cooldown=8

---

## Nhal

- id: `nhal`   zone: `frostspire`
- type: Range   main stat: Intelligence
- base attributes: Strength 20 / Agility 20 / Intelligence 23
- base combat: HP 530, Mana 299, Armor 2, Damage 44-54, Range 675, Speed 1
- growth per level: Strength +1.9 / Agility +2.2 / Intelligence +3.1

### Skills

**Mark of Stillness** (`mark_of_stillness`, standard)

Nhal marks an enemy with the cold that existed before motion itself. The afflicted creature slowly loses the warmth and movement that keep it alive, suffering damage for the duration of the curse.

- L1: damage=15, duration=3, range=2, mana_cost=40, cooldown=4
- L2: damage=25, duration=3, range=3, mana_cost=45, cooldown=4
- L3: damage=35, duration=4, range=3, mana_cost=50, cooldown=3
- L4: damage=45, duration=4, range=4, mana_cost=55, cooldown=3

**The Hollow Cold** (`the_hollow_cold`, standard)

Nhal opens a small wound in the air, releasing the cold of the emptiness that existed before the world. A freezing vortex lingers at the target location, slowly consuming the warmth of every enemy caught within it.

- L1: damage=15, radius=1, duration=3, mana_cost=40, cooldown=5
- L2: damage=25, radius=1, duration=3, mana_cost=45, cooldown=5
- L3: damage=35, radius=1, duration=4, mana_cost=50, cooldown=4
- L4: damage=45, radius=2, duration=4, mana_cost=55, cooldown=4

**Touch of the First Cold** (`touch_of_the_first_cold`, standard)

Nhal reaches into an enemy with a fragment of the cold that existed before stars, flesh, and fire. His attack carries this primordial chill, striking the target with unnatural force.

- L1: bonus_damage=40, mana_cost=50, cooldown=6
- L2: bonus_damage=70, mana_cost=55, cooldown=6
- L3: bonus_damage=110, mana_cost=60, cooldown=5
- L4: bonus_damage=150, mana_cost=65, cooldown=5

**Return to the Void** (`return_to_the_void`, ultimate)

Ultimate: Nhal marks an enemy and erases part of the material plane around it. Returning the world to the empty void before the creation of the matter. Everyone caught in its radius is struck with a primordial cold that continues to consume the heat of their bodies over time and they are prevented from retaining the life they once possessed. Any enemy whose health falls beneath a marked threshold is claimed by the cold void and dies instantly.

- L1: damage=150, dot_damage=20, dot_duration=3, stun_turns=1, execute_pct=0.2, radius=1, mana_cost=100, cooldown=10
- L2: damage=225, dot_damage=30, dot_duration=3, stun_turns=1, execute_pct=0.25, radius=1, mana_cost=110, cooldown=9
- L3: damage=300, dot_damage=40, dot_duration=4, stun_turns=2, execute_pct=0.3, radius=2, mana_cost=120, cooldown=8

---

## The Primordial Hunger

- id: `the_primordial_hunger`   zone: `frostspire`
- type: Range   main stat: Intelligence
- base attributes: Strength 22 / Agility 16 / Intelligence 26
- base combat: HP 560, Mana 387, Armor 3.24, Damage 42-49, Range 450, Speed 1
- growth per level: Strength +2.2 / Agility +1.5 / Intelligence +2.8
- battle_scale: 1.7

### Skills

**Frostbound Fangs** (`frostbound_fangs`, standard)

The Primordial Hunger's claws and fangs become coated in ancient frost, extending its reach and empowering its next attacks with the killing cold of Frostspire.

- L1: bonus_damage=30, bonus_range=2, attacks=2, duration=3, mana_cost=40, cooldown=5
- L2: bonus_damage=50, bonus_range=2, attacks=3, duration=3, mana_cost=50, cooldown=5
- L3: bonus_damage=70, bonus_range=3, attacks=3, duration=4, mana_cost=60, cooldown=4
- L4: bonus_damage=90, bonus_range=3, attacks=4, duration=4, mana_cost=70, cooldown=4

**Maddening Roar** (`maddening_roar`, standard)

The Primordial Hunger release a terrifying roar against a marked target, causing it to loose its will to live.  The minds of all other enemies around the target are shattered.

- L1: damage=100, shatter_damage=60, shatter_range=1, mana_cost=50, cooldown=5
- L2: damage=150, shatter_damage=90, shatter_range=1, mana_cost=55, cooldown=5
- L3: damage=200, shatter_damage=120, shatter_range=1, mana_cost=60, cooldown=4
- L4: damage=250, shatter_damage=150, shatter_range=2, mana_cost=65, cooldown=4

**The Test of Time** (`the_test_of_time`, standard)

The Primordial Hunger slips into a state of absolute stillness, becoming untouchable by all attacks while its ancient form slowly restores itself. During this state it cannot move or attack.

- L1: heal=75, duration=2, mana_cost=50, cooldown=6
- L2: heal=110, duration=2, mana_cost=55, cooldown=6
- L3: heal=135, duration=3, mana_cost=60, cooldown=5
- L4: heal=180, duration=3, mana_cost=65, cooldown=5

**The Hunger Calls** (`the_hunger_calls`, ultimate)

Ultimate: The Primordial Hunger freezes an enemy in place and awakens an unnatural hunger for living flesh in every creature nearby. Enemies within the Hunger's reach become driven to tear into the marked victim, moving toward it or attacking it for increased damage. Creatures beyond its reach remain focused on the Primordial Hunger as normal.

- L1: duration=2, curse_range=2, bonus_damage_pct=0.1, mana_cost=100, cooldown=10
- L2: duration=3, curse_range=2, bonus_damage_pct=0.15, mana_cost=110, cooldown=9
- L3: duration=4, curse_range=3, bonus_damage_pct=0.2, mana_cost=120, cooldown=8

---

## Frost Daughter

- id: `frost_daughter`   zone: `the_everfrost`
- type: Range   main stat: Intelligence
- base attributes: Strength 17 / Agility 16 / Intelligence 17
- base combat: HP 494, Mana 291, Armor 4.3, Damage 48-54, Range 600, Speed 1
- growth per level: Strength +2.2 / Agility +1.6 / Intelligence +3.3

### Skills

**Rimecleaver** (`rimecleaver`, standard)

Frost Daughter summons a massive axe of solid ice above an enemy and brings it crashing down upon them. At higher levels, the frozen blade cleaves through nearby enemies with the force of the impact.

- L1: damage=85, radius=0, mana_cost=70, cooldown=3
- L2: damage=110, radius=0, mana_cost=100, cooldown=3
- L3: damage=150, radius=1, mana_cost=135, cooldown=4
- L4: damage=200, radius=2, mana_cost=170, cooldown=4

**Winter's Grip** (`winters_grip`, standard)

Frost Daughter calls the frozen earth beneath an enemy to life. Spectral hands of ice burst from the ground and seize the victim, holding them in place while the freezing grip slowly tears away their strength.

- L1: stun_turns=1, dot_damage=25, dot_duration=2, mana_cost=80, cooldown=4
- L2: stun_turns=1, dot_damage=45, dot_duration=2, mana_cost=110, cooldown=4
- L3: stun_turns=2, dot_damage=60, dot_duration=3, mana_cost=145, cooldown=5
- L4: stun_turns=2, dot_damage=85, dot_duration=4, mana_cost=180, cooldown=5

**Frostborn** (`frostborn`, passive)

Passive: Frost Daughter draws strength from the Everfrost itself. The unnatural cold flowing through her body restores a portion of her magical energy every turn.

- L1: bonus_mana_regen=1.5
- L2: bonus_mana_regen=2.7
- L3: bonus_mana_regen=4
- L4: bonus_mana_regen=5.3

**The Frost Tempest** (`the_frost_tempest`, ultimate)

Ultimate: Frost Daughter rises above the ground and becomes the still center of a violent winter storm. A massive vortex of snow, ice, and freezing wind tears through everything around her, damaging every enemy caught within its reach.

- L1: damage=90, duration=3, radius=2, mana_cost=200, cooldown=8
- L2: damage=130, duration=3, radius=2, mana_cost=260, cooldown=9
- L3: damage=185, duration=4, radius=3, mana_cost=330, cooldown=10

---

## Skarn

- id: `skarn`   zone: `the_everfrost`
- type: Melee   main stat: Strength
- base attributes: Strength 23 / Agility 21 / Intelligence 18
- base combat: HP 640, Mana 267, Armor 3.83, Damage 50-54, Range 150, Speed 1
- growth per level: Strength +3.9 / Agility +2.1 / Intelligence +1.7

### Skills

**Frostbound Rupture** (`frostbound_rupture`, standard)

Unleashes a surge of frozen force toward an enemy, dealing damage and freezing a line of columns from Skarn's position toward the target. Enemies caught within the frozen ground cannot move, and no enemy can enter the frozen columns for the duration. Attacks, skills, and items can still be used normally.

- L1: damage=70, blocked_columns=2, duration=2, range=4, mana_cost=70, cooldown=4
- L2: damage=110, blocked_columns=3, duration=2, range=4, mana_cost=95, cooldown=4
- L3: damage=150, blocked_columns=3, duration=3, range=4, mana_cost=120, cooldown=5
- L4: damage=200, blocked_columns=4, duration=3, range=4, mana_cost=150, cooldown=5

**Charge** (`charge`, standard)

Skarn locks onto an enemy within range, becoming completely focused on his prey before charging directly at it. He crashes into the target, dealing damage and stunning it on impact.

- L1: damage=85, stun_turns=1, range=2, mana_cost=90, cooldown=5
- L2: damage=130, stun_turns=1, range=3, mana_cost=115, cooldown=5
- L3: damage=175, stun_turns=2, range=3, mana_cost=145, cooldown=6
- L4: damage=230, stun_turns=2, range=4, mana_cost=175, cooldown=6

**Bestial Rage** (`bestial_rage`, standard)

Skarn succumbs to his primal fury, entering a savage rage that empowers his Attacks with increased damage for the duration.

- L1: bonus_damage=30, duration=3, mana_cost=60, cooldown=5
- L2: bonus_damage=50, duration=3, mana_cost=80, cooldown=5
- L3: bonus_damage=75, duration=4, mana_cost=105, cooldown=6
- L4: bonus_damage=105, duration=4, mana_cost=130, cooldown=6

**Glacier Breaker** (`glacier_breaker`, ultimate)

Ultimate: Skarn delivers a devastating melee strike, dealing a multiple of his own Attack damage and violently knocking the enemy backward. If the enemy's movement is stopped by the edge of the battlefield or another enemy, it suffers additional impact damage and is stunned. The enemy is stunned after the knockback either way.

- L1: damage_multiplier=2, knockback=2, stun_turns=1, mana_cost=150, cooldown=8
- L2: damage_multiplier=2.5, knockback=3, stun_turns=1, mana_cost=200, cooldown=9
- L3: damage_multiplier=3, knockback=4, stun_turns=2, mana_cost=250, cooldown=10

---

## The Rootmother

- id: `the_rootmother`   zone: `the_verdant_scar`
- type: Melee   main stat: Strength
- base attributes: Strength 25 / Agility 15 / Intelligence 20
- base combat: HP 670, Mana 315, Armor 3.5, Damage 85-93, Range 150, Speed 1
- growth per level: Strength +3.4 / Agility +1.8 / Intelligence +1.8

### Skills

**Rootveil** (`rootveil`, standard)

The Rootmother sinks into the living root network beneath her, becoming nearly indistinguishable from the growth around her. While concealed, enemies cannot target or chase her, and she moves 2 columns per move instead of 1. The veil breaks the moment she attacks or casts another skill. An attack from concealment lashes the target with roots, rooting it in place while leaving it free to attack and cast skills.

- L1: duration=3, root_turns=1, mana_cost=60, cooldown=5
- L2: duration=3, root_turns=1, mana_cost=75, cooldown=5
- L3: duration=4, root_turns=2, mana_cost=95, cooldown=6
- L4: duration=4, root_turns=2, mana_cost=115, cooldown=6

**Sanguine Bloom** (`sanguine_bloom`, standard)

The Rootmother plants a parasitic bloom within an enemy. The unnatural growth feeds on the victim's life force for several turns, dealing damage over time while transferring a portion of that stolen vitality back to the Rootmother.

- L1: dot_damage=25, heal_per_turn=15, duration=3, range=2, mana_cost=70, cooldown=5
- L2: dot_damage=40, heal_per_turn=25, duration=3, range=2, mana_cost=90, cooldown=5
- L3: dot_damage=55, heal_per_turn=35, duration=4, range=2, mana_cost=115, cooldown=6
- L4: dot_damage=75, heal_per_turn=50, duration=4, range=2, mana_cost=145, cooldown=6

**Woven Flesh** (`woven_flesh`, standard)

The Rootmother draws living roots beneath her skin, weaving bark, flesh and plant matter into a regenerative shell. The growth hardens her body against attacks and continuously repairs her wounds for the duration.

- L1: bonus_armor=3, bonus_hp_regen=2, duration=4, mana_cost=60, cooldown=5
- L2: bonus_armor=5, bonus_hp_regen=3, duration=5, mana_cost=80, cooldown=5
- L3: bonus_armor=7, bonus_hp_regen=4, duration=6, mana_cost=100, cooldown=6
- L4: bonus_armor=9, bonus_hp_regen=5, duration=7, mana_cost=120, cooldown=6

**Mother's Grasp** (`mother's_grasp`, ultimate)

Ultimate: The Rootmother awakens the roots beneath her and sends them violently through the ground. Every enemy within range is seized and bound in place, unable to move while remaining free to attack and cast skills. The roots continue to tear into their victims for the duration.

- L1: dot_damage=65, root_duration=2, radius=1, mana_cost=180, cooldown=9
- L2: dot_damage=100, root_duration=3, radius=2, mana_cost=240, cooldown=10
- L3: dot_damage=150, root_duration=3, radius=2, mana_cost=300, cooldown=11

---

## Cinder

- id: `cinder`   zone: `the_verdant_scar`
- type: Range   main stat: Strength
- base attributes: Strength 27 / Agility 16 / Intelligence 24
- base combat: HP 714, Mana 351, Armor 2.67, Damage 48-52, Range 250, Speed 1
- growth per level: Strength +3.5 / Agility +1.3 / Intelligence +2.7
- attack_range: 1

### Skills

**Sweep** (`sweep`, standard)

Cinder swings his flamethrower in a wide arc, unleashing a torrent of fire around himself. Every enemy caught within the flames suffers damage as the burning fuel scorches flesh.

- L1: damage=100, radius=1, mana_cost=70, cooldown=4
- L2: damage=150, radius=1, mana_cost=90, cooldown=4
- L3: damage=200, radius=2, mana_cost=115, cooldown=5
- L4: damage=260, radius=2, mana_cost=140, cooldown=5

**Chainfire** (`chainfire`, standard)

Cinder fires a hooked chain that anchors above the marked enemy. He swings toward the target, dragging his flamethrower beneath him and leaving a trail of fire along his path.

- L1: damage=70, range=3, mana_cost=60, cooldown=4
- L2: damage=95, range=3, mana_cost=80, cooldown=4
- L3: damage=130, range=4, mana_cost=105, cooldown=5
- L4: damage=185, range=5, mana_cost=130, cooldown=5

**Kindled Resolve** (`kindled_resolve`, passive)

Passive: each time Cinder is struck, sparks erupt from his battered armor and ragged clothing, feeding the flames that cling to his body. Every hit increases his armor and health regeneration for a limited duration, as the growing heat hardens his defenses and fuels his determination to survive.

- L1: bonus_armor_per_stack=0.8, bonus_hp_regen_per_stack=3, max_stacks=5, duration=4
- L2: bonus_armor_per_stack=1.1, bonus_hp_regen_per_stack=4, max_stacks=6, duration=4
- L3: bonus_armor_per_stack=1.4, bonus_hp_regen_per_stack=5, max_stacks=7, duration=5
- L4: bonus_armor_per_stack=1.7, bonus_hp_regen_per_stack=6, max_stacks=8, duration=5

**Cinderbomb** (`cinderbomb`, ultimate)

Ultimate: Cinder hurls an improvised incendiary barrel toward the target location. On impact, the barrel bursts apart, spreading burning fuel across the surrounding ground. The resulting blaze damages enemies caught in the blast and continues to burn at the impact site.

- L1: cast_damage=150, damage_per_turn=80, duration=2, radius=1, range=5, mana_cost=200, cooldown=10
- L2: cast_damage=225, damage_per_turn=120, duration=3, radius=1, range=6, mana_cost=275, cooldown=11
- L3: cast_damage=325, damage_per_turn=170, duration=3, radius=2, range=7, mana_cost=350, cooldown=12

---

## The Last Empress

- id: `the_last_empress`   zone: `drowned_empire`
- type: Melee   main stat: Agility
- base attributes: Strength 21 / Agility 22 / Intelligence 19
- base combat: HP 582, Mana 303, Armor 4.7, Damage 45-47, Range 150, Speed 1
- growth per level: Strength +2.4 / Agility +3.4 / Intelligence +2

### Skills

**Imperial Guard** (`imperial_guard`, standard)

The Last Empress summons her personal guard, ancient drowned warriors who emerge around the nearest enemy. The guards protect their sovereign by drawing attacks away from her, while striking nearby enemies whenever they find an opening. Their decayed forms can be destroyed, but their loyalty endures beyond death.

- L1: guards=3, hp_pct=0.35, damage_pct=0.4, hit_chance_pct=0.2, duration=3, mana_cost=70, cooldown=5
- L2: guards=3, hp_pct=0.4, damage_pct=0.45, hit_chance_pct=0.25, duration=3, mana_cost=90, cooldown=5
- L3: guards=3, hp_pct=0.45, damage_pct=0.5, hit_chance_pct=0.35, duration=4, mana_cost=115, cooldown=6
- L4: guards=3, hp_pct=0.5, damage_pct=0.55, hit_chance_pct=0.45, duration=4, mana_cost=140, cooldown=6

**Shackles** (`shackles`, standard)

The Last Empress commands spectral chains to erupt from the depths and bind an enemy within range. The shackles tear into their victim and hold it firmly in place, preventing movement and jumping while leaving it able to attack and cast skills.

- L1: damage=60, range=3, root_turns=1, mana_cost=60, cooldown=4
- L2: damage=100, range=4, root_turns=2, mana_cost=80, cooldown=4
- L3: damage=145, range=5, root_turns=2, mana_cost=105, cooldown=5
- L4: damage=200, range=6, root_turns=3, mana_cost=130, cooldown=5

**Empress's Will** (`empress's_will`, passive)

Passive: The Last Empress's will flows through every strike, releasing a crushing surge that damages nearby enemies. Her authority also strengthens her Imperial Guard, increasing their damage and duration as her power grows. At its peak, her command summons an additional guardian.

- L1: aoe_damage_pct=0.15, radius=1, guardians_damage_bonus_pct=0.02, guard_duration_bonus=0, extra_guard=0
- L2: aoe_damage_pct=0.2, radius=1, guardians_damage_bonus_pct=0.03, guard_duration_bonus=0, extra_guard=0
- L3: aoe_damage_pct=0.25, radius=1, guardians_damage_bonus_pct=0.04, guard_duration_bonus=1, extra_guard=0
- L4: aoe_damage_pct=0.3, radius=1, guardians_damage_bonus_pct=0.05, guard_duration_bonus=1, extra_guard=1

**Luring Gaze** (`luring_gaze`, ultimate)

Ultimate: The Last Empress fixes her gaze upon every enemy within range, revealing the haunting beauty that conceals her monstrous nature. Mesmerized by her presence, they become unable to act as their defenses weaken beneath her influence. The Empress and her Imperial Guard remain free to move and attack while her victims stand helpless before her.

- L1: stun_turns=3, radius=3, armor_reduction=5, mana_cost=200, cooldown=9
- L2: stun_turns=3, radius=3, armor_reduction=8, mana_cost=260, cooldown=10
- L3: stun_turns=4, radius=4, armor_reduction=12, mana_cost=330, cooldown=11

---

## Dreadlure

- id: `dreadlure`   zone: `drowned_empire`
- type: Melee   main stat: Strength
- base attributes: Strength 21 / Agility 17 / Intelligence 15
- base combat: HP 582, Mana 255, Armor 5.83, Damage 51-59, Range 150, Speed 1
- growth per level: Strength +3.4 / Agility +2.1 / Intelligence +1.5

### Skills

**Hunting Instinct** (`hunting_instinct`, standard)

Dreadlure senses its prey and surges forward with terrifying speed. If an enemy stands in its path, Dreadlure stops upon reaching it and delivers a devastating strike.

- L1: bonus_movement=1, duration=1, charge_damage_pct=0.4, mana_cost=50, cooldown=4
- L2: bonus_movement=2, duration=2, charge_damage_pct=0.55, mana_cost=70, cooldown=4
- L3: bonus_movement=2, duration=2, charge_damage_pct=0.7, mana_cost=90, cooldown=5
- L4: bonus_movement=3, duration=3, charge_damage_pct=0.9, mana_cost=110, cooldown=5

**Paralytic Venom** (`paralytic_venom`, standard)

Dreadlure releases paralytic toxins into the surrounding area, damaging nearby enemies and immobilizing them as the venom overwhelms their bodies.

- L1: damage=90, radius=1, stun_turns=1, mana_cost=70, cooldown=4
- L2: damage=140, radius=1, stun_turns=1, mana_cost=95, cooldown=4
- L3: damage=200, radius=1, stun_turns=2, mana_cost=125, cooldown=5
- L4: damage=270, radius=1, stun_turns=2, mana_cost=155, cooldown=5

**Might of the Deep** (`might_of_the_deep`, passive)

With each attack, Dreadlure gathers primal strength. After a set number of strikes, its next attack unleashes devastating force, dealing bonus damage and knocking the target back.

- L1: attacks_required=3, bonus_damage_pct=0.4, knockback=1
- L2: attacks_required=3, bonus_damage_pct=0.6, knockback=1
- L3: attacks_required=2, bonus_damage_pct=0.8, knockback=1
- L4: attacks_required=2, bonus_damage_pct=1, knockback=1

**Deathlight Lure** (`deathlight_lure`, ultimate)

Ultimate: Dreadlure focuses the eerie glow of its bioluminescent lure on a single target, marking it as prey. Drawn to the unnatural light, the target can no longer hide from Dreadlure. The mark weakens its defenses and increases the damage it takes from Dreadlure's attacks and skills for the duration.

- L1: armor_reduction=6, bonus_damage_pct=0.1, duration=4, range=4, mana_cost=150, cooldown=8
- L2: armor_reduction=9, bonus_damage_pct=0.15, duration=5, range=5, mana_cost=200, cooldown=9
- L3: armor_reduction=12, bonus_damage_pct=0.2, duration=6, range=6, mana_cost=250, cooldown=10

---

## Solara

- id: `solara`   zone: `the_blackbloom`
- type: Range   main stat: Agility
- base attributes: Strength 20 / Agility 26 / Intelligence 22
- base combat: HP 560, Mana 339, Armor 2, Damage 19-23, Range 630, Speed 1
- growth per level: Strength +2.2 / Agility +3.1 / Intelligence +1.9

### Skills

**Fallen Grace** (`fallen_grace`, standard)

Unleashes a volley of arrows that rains down upon every enemy within radius of Solara, dealing damage.

- L1: damage=90, radius=1, mana_cost=65, cooldown=4
- L2: damage=140, radius=1, mana_cost=90, cooldown=4
- L3: damage=200, radius=2, mana_cost=120, cooldown=5
- L4: damage=270, radius=2, mana_cost=150, cooldown=5

**Hope of the Fallen** (`hope_of_the_fallen`, standard)

Solara pours all she got left of her lost world into a mighty arrow at a distant target, dealing greater damage the farther it travels and stunning the target on impact.

- L1: base_damage=80, bonus_per_column=20, range=4, stun_turns=1, mana_cost=70, cooldown=5
- L2: base_damage=120, bonus_per_column=30, range=5, stun_turns=2, mana_cost=100, cooldown=5
- L3: base_damage=170, bonus_per_column=40, range=6, stun_turns=2, mana_cost=135, cooldown=6
- L4: base_damage=230, bonus_per_column=50, range=7, stun_turns=3, mana_cost=170, cooldown=6

**Withering Pursuit** (`withering_pursuit`, standard)

Surges forward with fading determination, leaping over any enemies in her path.

- L1: move_distance=1, jump_distance=1, dash=false, mana_cost=50, cooldown=4
- L2: move_distance=2, jump_distance=1, dash=false, mana_cost=65, cooldown=4
- L3: move_distance=2, jump_distance=2, dash=true, mana_cost=80, cooldown=5
- L4: move_distance=2, jump_distance=3, dash=true, mana_cost=100, cooldown=5

**Ambush Strike** (`ambush_strike`, ultimate)

Ultimate: Conceals herself for the duration, preventing enemies from attacking or pursuing her. Her next Attack from stealth deals bonus damage and reveals her.

- L1: duration=2, bonus_damage_pct=1, mana_cost=180, cooldown=9
- L2: duration=3, bonus_damage_pct=1.5, mana_cost=240, cooldown=10
- L3: duration=4, bonus_damage_pct=2, mana_cost=300, cooldown=11

---

## Lunara, the Crimson Thorn

- id: `lunara`   zone: `the_blackbloom`
- type: Range   main stat: Agility
- base attributes: Strength 21 / Agility 24 / Intelligence 23
- base combat: HP 582, Mana 351, Armor 5.83, Damage 50-56, Range 330, Speed 1
- growth per level: Strength +2.2 / Agility +3.4 / Intelligence +1.9

### Skills

**Moonfall Lance** (`moonfall_lance`, standard)

Lunara unleashes a concentrated lance of lunar energy at an enemy within range, dealing damage and stunning the target.

- L1: damage=100, stun_turns=1, range=4, mana_cost=60, cooldown=4
- L2: damage=160, stun_turns=1, range=5, mana_cost=85, cooldown=4
- L3: damage=230, stun_turns=2, range=6, mana_cost=115, cooldown=5
- L4: damage=310, stun_turns=2, range=7, mana_cost=145, cooldown=5

**Lunar Ricochet** (`lunar_ricochet`, passive)

Passive: Lunara's attacks carry lunar energy, causing their projectiles to ricochet between nearby enemies, dealing reduced damage with each successive hit.

- L1: bounces=2, bounce_damage_pct=0.75, bounce_range=0
- L2: bounces=3, bounce_damage_pct=0.65, bounce_range=1
- L3: bounces=4, bounce_damage_pct=0.55, bounce_range=1
- L4: bounces=5, bounce_damage_pct=0.45, bounce_range=2

**Moonbound Might** (`moonbound_might`, passive)

Passive: Bound to the power of the eternal night, Lunara channels lunar energy into her attacks, increasing her Attack damage.

- L1: bonus_damage_pct=0.15
- L2: bonus_damage_pct=0.25
- L3: bonus_damage_pct=0.35
- L4: bonus_damage_pct=0.5

**Eternal Eclipse** (`eternal_eclipse`, ultimate)

Ultimate: Lunara plunges the battlefield into a supernatural eclipse. For the duration, lunar beams rain down upon random enemies within a radius around her, following her movements until every beam has struck.

- L1: beams=4, damage=130, radius=2, mana_cost=200, cooldown=9
- L2: beams=6, damage=175, radius=3, mana_cost=275, cooldown=10
- L3: beams=8, damage=230, radius=4, mana_cost=350, cooldown=11

---

## Raze

- id: `raze`   zone: `scorchlands`
- type: Range   main stat: Strength
- base attributes: Strength 21 / Agility 16 / Intelligence 21
- base combat: HP 582, Mana 327, Armor 3.7, Damage 67-73, Range 500, Speed 1
- growth per level: Strength +3.2 / Agility +1.2 / Intelligence +2.1

### Skills

**Double Trouble** (`double_trouble`, standard)

Raze unleashes both barrels of her battered shotgun in the direction she's facing, blasting every enemy caught within range. She calls it a warning shot. Nobody believes her.

- L1: damage=70, range=2, mana_cost=80, cooldown=6
- L2: damage=100, range=2, mana_cost=105, cooldown=6
- L3: damage=170, range=3, mana_cost=135, cooldown=7
- L4: damage=230, range=3, mana_cost=160, cooldown=7

**Blast Hopper** (`blast_hopper`, standard)

Raze detonates an explosive beneath her feet, launching herself toward the direction she's facing. While in the air she fires both barrels of her shotgun down at her enemies, damaging and blinding them with a deafening blast. Blinded enemies are stunned and unable to act for the duration.

- L1: jump_distance=2, damage=60, radius=1, stun_turns=1, mana_cost=70, cooldown=5
- L2: jump_distance=2, damage=90, radius=1, stun_turns=1, mana_cost=90, cooldown=5
- L3: jump_distance=3, damage=120, radius=1, stun_turns=2, mana_cost=115, cooldown=6
- L4: jump_distance=3, damage=160, radius=1, stun_turns=2, mana_cost=140, cooldown=6

**Three Cheers** (`three_cheers`, standard)

Raze marks an enemy and unleashes three rapid shots from her modified firearm. Each hit deals a portion of her attack damage and tears away at the target's armor, leaving it increasingly exposed. The armor damage fades after a short duration.

- L1: shots=3, damage_pct=0.45, armor_reduction_per_shot=1, duration=1, mana_cost=80, cooldown=5
- L2: shots=3, damage_pct=0.55, armor_reduction_per_shot=2, duration=1, mana_cost=105, cooldown=5
- L3: shots=3, damage_pct=0.65, armor_reduction_per_shot=3.5, duration=2, mana_cost=130, cooldown=6
- L4: shots=3, damage_pct=0.75, armor_reduction_per_shot=5, duration=2, mana_cost=155, cooldown=6

**Kiss the Wastes** (`kiss_the_wastes`, ultimate)

Ultimate: Raze blows her target a kiss before unleashing a barrage of three incendiary shots. She becomes completely committed to the attack, unable to move, act, or use items while firing one shot per turn. Each shot tracks the target, or its last known position if it dies, dealing heavy damage and setting its victim ablaze. The impact also scatters burning fragments across adjacent columns, catching nearby enemies in the inferno.

- L1: hits=3, main_damage=180, splash_damage=90, burn_per_turn=35, burn_duration=5, mana_cost=200, cooldown=10
- L2: hits=3, main_damage=260, splash_damage=130, burn_per_turn=50, burn_duration=5, mana_cost=270, cooldown=11
- L3: hits=3, main_damage=350, splash_damage=175, burn_per_turn=70, burn_duration=6, mana_cost=350, cooldown=12
