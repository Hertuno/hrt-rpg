## Is this mod finished?

No. **v0.2.x is an early public build.** Classes, roadmaps, subclasses, and world events work. Cross-save account, free battle pass, and automated season rotation are **still in progress**.

## What should I expect if I download now?

A playable RPG layer on Space Age (especially on the public server). Do **not** expect a finished battle pass, permanent cloud account, or polished season end/start flow yet.

## How do I get the mod when joining the server?

Install from this portal page (or use Factorio’s “Sync mods with server”). Soft dependencies (bobclasses, RPGsystem, …) sync the same way if the server has them enabled.

## Do I need Space Age / bobclasses / RPGsystem?

Space Age is strongly recommended (required for the public seasonal server). bobclasses and RPGsystem are optional: class select works in-mod; without RPGsystem you still get local XP feedback.

## Does my progress survive a map wipe?

**Not reliably yet.** Account data is currently local to the save. Cross-wipe / cloud account is on the roadmap.

## Is the free battle pass available?

**Not yet** as a full system. Class roadmaps and events are the current progression. Battle pass is planned.

## Can I change class mid-season?

Not by default (body lock). An admin can run `/hrt-reset-class [player]`.

## Where is the public server?

Promo: https://hrt-rpg.ru  
Game: `hrt-rpg.online:34197` (Factorio 2.0 + Space Age + this mod pack).

## Where do I tune balance?

In the mod zip: `scripts/balance.lua` (events, kits, XP, weapon/heal numbers). Quest targets stay in `scripts/roadmap_trees.lua`.
