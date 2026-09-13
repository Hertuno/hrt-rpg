# HRT RPG — early public build

> **Status: work in progress (v0.2.x).**  
> Playable core is online; several season systems from the vision doc / promo site are **not finished yet**. Download if you want to try classes + roadmaps on the public server — not if you expect a finished battle-pass MMO layer.

**Public server / promo:** [https://hrt-rpg.ru](https://hrt-rpg.ru)  
**Join game:** `hrt-rpg.online:34197`

---

## What works now

- **5 classes** with starter kits and character bonuses (Fighter, Miner, Engineer, Support, Explorer)
- **~27 quests per class** — Early / Mid / Late personal roadmap
- **Dual subclasses** — common Mid pick + specialized Late pick
- **World events** — night raids, biter waves, ore caches, boss hive (full hive reward wants a class mix nearby)
- **Local account level** in the current save (unlocks + Paragon hooks)
- Class gear: armor, fighter SMG, demolition cannon, area medkit
- Tunables in `scripts/balance.lua`

---

## Still in progress (not ready / incomplete)

- **Cross-save / cloud account** — progress does **not** yet reliably carry between map wipes or different saves
- **Season battle pass** (free track UI, shared season missions, cosmetics) — **not shipped**
- **Automated seasons** — planet rotation, wipe schedule, season start/end flow — **manual / planned**, not automated
- **Paragon “legacy” loop** — data model exists; full end-of-season grant UX is unfinished
- **Balance polish** — numbers will change; expect rough edges
- Some class bonuses (e.g. fighter damage_bonus) are reserved / not fully wired

If a feature is advertised only on the promo landing as “season vision”, treat it as **roadmap**, not as current gameplay.

---

## Soft dependencies (optional)

| Mod | Role |
|---|---|
| Space Age | intended baseline for the public server |
| bobclasses / boblibrary | alternate starter bodies |
| RPGsystem | XP / skills bridge |
| flib | reserved (not required by current GUI) |

Works without bobclasses (in-mod class GUI) and without RPGsystem (local XP messages).

---

## Commands

- `/hrt-roadmap` — open roadmap
- `/hrt-account` — account level / XP
- `/hrt-paragon` — list paragons
- `/hrt-reset-class` — admin: reset class
- `/hrt-force-event [night|hive]` — admin: force an event

---

## Notes

- Designed for **session / seasonal** co-op; the long-term model is wipe map → keep account rewards — **account persistence is still WIP**.
- Migrating from 0.1.x resets the short roadmap (`roadmap_v2`); use `/hrt-reset-class` or a new character.
- Feedback welcome via the homepage / server community.
