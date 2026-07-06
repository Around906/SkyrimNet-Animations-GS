# Changelog

## v1.0.2

**Fixed:** poses could still fire on an actor who was mid-scene elsewhere — breaking sex scenes,
downed/bleedout states, and Baka Integration struggles.

The `is_busy` eligibility gate added in v1.0.1 only checks state at the moment the LLM *decides* to
pose someone; it can't see the actor becoming busy in the gap between that decision and the pose
actually executing. That gap was the actual cause of the reported breakage.

Added an exec-side backstop (`_IsBusyElsewhere`), checked immediately before every pose fires — for
both the player's manual pose and LLM-driven NPC vibes — covering:
- A Baka Integration paired animation, struggle, or downed/ground-window state
- An Acheron Integration hold, even with no Baka involved
- Any vanilla bleedout, regardless of what caused it (SeverActions, plain combat, Acheron, Baka)
- A SexLab or OStim scene that didn't go through Baka at all

All checks are soft (plain StorageUtil keys or factions resolved by FormID) — nothing here requires
Baka or Acheron to be installed; this mod keeps working standalone with all of it defaulting to "not
busy."

## v1.0.1

Added `is_busy == false` to every pose action's eligibility gate (already blocked posing in combat
or in the SexLab/OStim animating factions), so the LLM stops offering a pose to an NPC who's mid-scene,
in furniture, in dialogue, or otherwise occupied — at decision time.

## v1.0.0

Per-category NPC pose hard-stop timing: 45s for workout/stretch/dance, 25s for everything else
(previously a single flat timeout for every vibe).
