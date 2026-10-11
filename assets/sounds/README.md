# Sound effects

Every sound effect in the game is generated in code (`scripts/SfxSynth.gd`)
unless a file is dropped in this folder. To replace one, add a file named
after the event - `.ogg`, `.wav` or `.mp3` - and it is used automatically
the next time the game starts. Delete the file to go back to the generated
sound. Short clips (under ~3 s) work best; trim silence at the start so
the sound lines up with the visual.

| Event name              | When it plays                                              |
|-------------------------|------------------------------------------------------------|
| `button`                | any button pressed (falls back to the generated `ui_click`) |
| `ui_click`              | any button pressed                                         |
| `hit`                   | any creature/hero is hit                                   |
| `death`                 | any creature/hero dies                                     |
| `shotgun`               | Raze's normal attack                                       |
| `double_trouble`        | Double Trouble (both barrels)                              |
| `blast_hopper_launch`   | Blast Hopper's charge under her feet                       |
| `explosion`             | Blast Hopper's slam where she lands                        |
| `land_thud`             | Blast Hopper's landing                                     |
| `three_cheers_shot`     | each of Three Cheers' three shots                          |
| `bullet_impact`         | each Three Cheers shot landing                             |
| `creep_shoot`           | a Scorchlands rifleman firing (generated rifle crack if no file) |
| `kiss`                  | the blown kiss that opens Kiss the Wastes                  |
| `napalm_shot`           | each Kiss the Wastes shell leaving the gun                 |
| `napalm_impact`         | the shell landing                                          |
| `napalm_burn`           | the napalm burning on the ground (about 3 s)               |
| `shop_transaction`     | buying or selling an item in the shop - file only          |
| `chain`                 | the hooked chain shot out by Cinder's Chainfire - file only    |
| `steps`                 | any movement - hero, creep or summon (pitch varies a little) - file only |
| `Cinderbomb_explosion`  | the blast of Cinder's Cinderbomb - file only (name is case-sensitive) |
| `vine_tentacle`         | any vine or tentacle attack: vine lashes, mist tendrils, Mother's Grasp roots - file only |
| `fire_attack`           | Cinder's normal attack and Sweep (one shot), Chainfire's swing and the Cinderbomb's burning ground (looped while it lasts) - file only |
| `reload`                | Raze's normal attack: a reload, then the shot follows at once (the attack waits for it) - file only |
| `raze_shoot`            | every Raze shot: normal attack, Double Trouble, the shot at the peak of Blast Hopper, each Three Cheers shot |
| `kiss_the_wastes`       | each Kiss the Wastes shell leaving her gun |
| `bear_attack`           | Erynd's bear (and a rival's) attacking - file only        |
| `bear_summon`           | the bear being summoned - file only; uses `bear_attack` if absent |

Per-event volume lives in `SfxSynth.EVENTS` (it applies to files too).
To add a new sound: add its name to `SfxSynth.EVENTS` (with a volume), then
call `AudioManager.play_event("name")` wherever it should play - with no
file and no generator for it, nothing plays.

## Music

`menu_music.mp3` (or `.ogg` / `.wav`) is the menu music: it fades in 40% of the way
through the loading screen, keeps playing across every menu screen without
restarting, and fades out when New Game or Continue is chosen (and when
registering leads into the intro). It loops. Replace the file to change the
track.
