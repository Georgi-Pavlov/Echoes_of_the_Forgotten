# Endgame design (agreed direction, not implemented yet)

Placeholder-level design for the end of the game; expected to change for the full release.

## Story spine
- The rulers of the old world opened a Gate seeking power. It fed on their thoughts and emotions, consumed them and corrupted everything, changing the world into the current one.
- The mist is only a recurring motif, not the antagonist.
- The Remembered are the heroes who still hold on to something of the old world (memories that feel like dreams; not all realise it). Some want to restore the old world, others like the power the corruption gave them and want to rule the new one.
- Echoes are those fragments of memory made solid.

## Echoes
- Clearing your own home zone unlocks your own echo.
- A rival that kills another rival takes its echo (so a rival can hold several).
- Killing a rival gives the player **all** of that rival's echoes, but they only add to the echo **count**. The attribute bonus from the kill stays the same as for killing a single rival, no matter how many echoes the rival held, so nobody becomes stronger than the rest by killing a rival who holds several.
- The player's echo count is shown on the Map, where his stats are.
- Each rival's echo count is shown in the World Status menu.
- The final stage unlocks after N collected echoes (start with 50%).

## Dreams and the choice
- After choosing a hero: a short dream sequence of a few scenes with fragments of the old world, then text saying you had one of those dreams again, don't know what it means, but it is strangely familiar and pulls you towards something.
- Clearing the home zone: the text becomes the realisation that this is your home - but is that true, or a trick meant to lure you?
- After killing some rivals (3-4): a second dream sequence showing the old world, the Gate, the shattering and the corruption. The realisation: you can bring the old world back, at a cost, or harness the power and rule the new one. The player makes the choice (Restore / Rule).
- Once the player has chosen, the remaining rivals split into Restore and Rule. The player can sense those with the opposite intent (marked in World Status).

## Rivals reaching the end
- A rival with enough echoes can attempt the end boss. If the rival wins, that is one of the game's endings. If the rival loses, its echoes are lost - so players chase such rivals on a rerun.

## Final stage
There is a warning before entering that there is no going back. No flee option in the final fight.

1. **Player killed every rival:** faces the boss alone, after a short scene where the boss says it looks like he wanted everything for himself and will not allow it. Win or lose. On a win: a choice of Restore or Rule (can switch the earlier choice). Three endings: lose, win-Restore, win-Rule.
2. **Player did not kill every rival** - a short scene shows him either coming to the boss's aid (Rule) or entering to end the corruption (Restore), then one of:
   - **a)** Both sides' remaining rivals fight each other with the player. The sides must be equal in number (the player gets only as many random allies as the opposing side has heroes, and vice versa). Win or lose; on a win a choice to keep or change the original choice.
   - **b)** The player killed all rivals of the opposite intent.
     - Rule: he enters promising to help and protect the boss, then stabs it in the back. No further choice. Pure evil ending, the easiest.
     - Restore: he fights the boss, win or lose. No choice afterwards. Pure good ending.
   - **c)** The player killed all rivals of his own intent: after entering he fights the remaining opposing rivals one by one, resetting the potions he entered with after each fight.

## Endings tracking
- Replace the "Highlights" button with **Achieved Endings**. Every ending has a name and the game tracks which ones the player has achieved, for replayability.

## Demo ending (temporary, replaced by the full design above)
- **Trigger:** the demo ends when every rival is dead.
- **Scenes:** a dream-style `StoryBanner` sequence showing the old world, the Gate and the corruption.
- **The choice:** the player picks Restore or Rule. It is stored, but only the epilogue text changes; a line says the choice will matter in the full game.
- **Closing card:** a thank-you for playing the demo with the name of the ending reached, then back to the menu.
- **Achieved Endings:** two entries, "Demo: the old world" and "Demo: the new world".
- Reuses the existing `StoryBanner`, hero-kill tracking and a flag in the player's save. No mini final fight.

## Open points
- The unlock threshold is 50% of all echoes in the game. A rival that reaches 50% attempts the boss and, if it loses, its echoes are lost, but the other 50% remain. Edge cases: with the same 50% for both, the player needs every remaining echo (no slack), and a rival can overshoot 50% in one kill (e.g. 40% + a 20% kill) and leave fewer than 50% available. Suggested fix to decide: a lower threshold for the player than for rivals (e.g. 40% vs 60%).
- Names for each ending.
