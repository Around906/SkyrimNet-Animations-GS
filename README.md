# SkyrimNet Animations — GS Poser

A **SkyrimNet integration** for the **GSPoses** animation pack: a PrismaUI panel lets you browse
and trigger poses on the player from a clickable, scrollable grid, tells the SkyrimNet LLM what
you're doing, and lets the LLM drive nearby **female NPCs** into mood-fitting poses of their own.

> ⚠️ Adult-adjacent posing content. For adult roleplay.

See [CHANGELOG.md](CHANGELOG.md) for release history. Current version: **v1.0.3**.

## Credits — animations by Gunslicer
All poses/animations are the work of **Gunslicer** and are **NOT redistributed here**. You must
install the GSPoses pack yourself. Please support the author:

- **Gunslicer — https://www.patreon.com/Gunslicer**

This mod is only the integration layer (PrismaUI selector + SkyrimNet actions + scripts). It ships
**no animation files** — it references Gunslicer's `GS#` animation events.

## What it does
**Player side**
- A **lesser power** opens a **PrismaUI pose selector** — the game pauses, you pick a category from
  the scrollable list, then click a pose; the panel closes and the pose plays on the player.
- The selection (with a short description) is reported to **SkyrimNet** so the LLM — and nearby
  NPCs — know what the player is doing.
- The pose holds in place; **pressing any movement key (WASD / jump / sprint / sneak) ends it**.
- In-panel **size control** (scale the window up/down), like the Baka integration.

**NPC side (LLM-driven)**
- SkyrimNet can put a nearby **female** NPC into a mood-fitting pose (seductive, dancing, workout,
  submission, etc.) — the LLM picks the vibe, the mod picks a random matching GS pose.
- Posing NPCs **hold in place** and are pacified while posed; **starting combat frees them**
  immediately, and every pose **auto-ends after ~30s** as a safety cap.
- The LLM (or another character, via dialogue) can tell a posing NPC to **stop**.

## Requirements
- **GSPoses by Gunslicer** (the animation pack — required; not included). Build with **FNIS / Nemesis / Pandora**.
  **`poses.js`'s labels/groupings were curated against exactly this release: [Pose Mod 02.06](https://www.patreon.com/Gunslicer/posts/pose-mod-02-06-159933025)
  (Patreon, mirrored to Nexus as "GSPoses SE 02 06.7z", dated 2026-06-02).** Gunslicer's pack is
  actively developed and has been renumbered/reordered between releases before — if a UI label and
  the animation that actually plays don't match, the most likely cause is a GSPoses version newer
  or older than the one linked above, not a bug in this mod. Re-curating `poses.js` against your
  installed version (or installing exactly the release linked above) fixes it either way.
- **SkyrimNet** (+ SKSE, Address Library)
- **PrismaUI**
- **PapyrusUtil**, **powerofthree's Papyrus Extender**

## Status
Work in progress. The pose grid currently shows **pose numbers** (e.g. `GS123`); image thumbnails
will be added category-by-category as screenshots become available.

## Compatibility
Skyrim **SE 1.5.97 / AE / VR**. The SKSE plugin is built on CommonLibSSE-NG, so the one DLL
loads on all three runtimes.
- **NPC poses** (LLM-driven) work fully in VR.
- The **player pose grid** is a PrismaUI overlay — usable in VR only as far as PrismaUI itself
  supports VR menus/cursor.
- The "movement ends the pose" key-watch listens for WASD/jump, which VR doesn't use for
  locomotion; in VR a pose simply ends on its ~30s safety timeout (or via a stop action) instead.
