# Accepted Decisions

This file is the concise index of significant accepted decisions and their reasoning. [`docs/design/README.md`](design/README.md) maps roadmap items to the authoritative detailed briefs. The original discovery record is archived for provenance and is not a required session read.

## D-001 — Product and prototype scope

**Decision:** Build a mobile-first Roblox idle/incremental dungeon RPG inspired by Melvor Idle, without copying its content or presentation. The first milestone is a private solo-tested vertical slice, not a public launch.

**Reasoning:** The prototype must first prove that the interconnected loop is fun and manageable for one spare-time developer.

## D-002 — Extensible content architecture

**Decision:** Professions, items, equipment slots, recipes, loot tables, modifiers, dungeons, and entitlements use stable IDs and data-defined registries backed by shared services.

**Reasoning:** New content should normally require configuration and assets rather than new save, inventory, offline, or UI frameworks.

## D-003 — Initial professions and loop

**Decision:** Start with Combat, Mining, and Forging. Forging includes smelting; separate Crafting arrives only with the professions that supply its materials.

**Reasoning:** Mining → Forging → equipment → dungeon progress is the smallest complete dependency loop while leaving room for many later professions.

## D-004 — World structure

**Decision:** Use a compact classic-fantasy village above ground, with separate and visually distinctive underground mine and dungeon entrances. Dungeon runs are private/instanced.

**Reasoning:** The village provides Roblox social visibility and simple navigation while instances prevent interference with solo combat.

## D-005 — Mining and profession tools

**Decision:** One interaction begins continuous visible Mining. Ore enters the shared bank when it fits; Mining and XP continue while overflow rewards are discarded with clear warnings. Mining requires a pickaxe, and level-gated upgrades are bought with Gold through a reusable profession-tool system.

**Reasoning:** This combines familiar Roblox simulator feedback with idle behavior and creates understandable progression and a recurring currency sink.

## D-006 — Forging

**Decision:** Players select a recipe and quantity, then production repeats automatically. Aborting discards unfinished progress but returns the ingredients reserved for that item.

**Reasoning:** Forging supports the idle focus without a mandatory minigame, while atomic reservation protects inventory consistency.

## D-007 — Combat and dungeons

**Decision:** Fight one predetermined monster at a time. First clears are active; successful clears unlock automatic and offline repetition. Prototype combat uses automatic basic attacks, Power Strike, supplies, movement, and simple telegraphed dodging. The first dungeon contains rats and snakes and ends with a Rat King using a two-claw lunge.

**Reasoning:** Active first clears provide a Roblox-native adventure while later simulation preserves the idle core.

## D-008 — Combat styles and equipment

**Decision:** The model supports Melee, Ranged, and Magic plus data-defined equipment slots and future affixes. The first version exposes only Melee players and enemies; Ranged, Magic, and Ammo remain future content.

**Reasoning:** The complete model avoids a later rewrite without exposing styles whose supporting professions do not yet exist.

## D-009 — Offline risk, loot, and death

**Decision:** Offline actions run at 50% efficiency for up to 24 hours, with earned upgrades eventually reaching 75%. Dungeon loot remains unsecured until manually banked; death loses all unsecured loot and one random eligible equipped item. The game never guarantees that a build is safe to idle.

**Reasoning:** Offline progress stays valuable while preparation, banking decisions, and real risk sustain the dungeon game.

## D-010 — Inventory and Gold economy

**Decision:** Use one 40-slot secured bank with five category tabs and a separate 16-entry dungeon-loot container. Gold buys incrementally priced bank slots, consumables, profession tools, and other earned progression upgrades.

**Reasoning:** Shared storage is expandable, understandable, and a useful non-punitive currency sink.

## D-011 — Social and competition

**Decision:** The first iteration has no cooperation or trading. Players share the village, display progress, and compete through server-authoritative daily and weekly leaderboards.

**Reasoning:** Visible players provide Roblox social value without the implementation and economy risks of multiplayer cooperation or trading.

## D-012 — Pets and automatic loot

**Decision:** Activities can award rare permanent pets with minor related buffs, and all unlocked pet types may be visible followers. A losable dungeon Auto-Loot Ring is the earned automatic-loot route; a permanent loot pet may later be sold directly for Robux.

**Reasoning:** Pets and repeatable rare loot create long-term collection goals while the paid convenience has an earnable alternative.

## D-013 — Monetization

**Decision:** Monetization must be non-aggressive and clearly described. Begin with a supporter pass only after the prototype; support later direct entitlements such as paid professions. Do not launch paid random loot, paid pet rolls, or paid luck.

**Reasoning:** Revenue is a project goal, but the free experience must remain enjoyable and purchases understandable, especially to younger players.

## D-014 — Visual direction and assets

**Decision:** Use free, licensed, stylized low-poly heroic-fantasy assets with blocky readability. Prototype visible pickaxes, weapons, shields, and helmets before attempting complete fitted armour.

**Reasoning:** This is achievable for a solo developer without art experience and remains readable on mobile Roblox devices.

## D-015 — Naming and analytics

**Decision:** The final invented classic-fantasy brand will use the subtitle **Idle RPG**; the exact name is deferred. Record meaningful server-authoritative state transitions through a versioned event boundary from the first playable build.

**Reasoning:** The subtitle preserves discoverability without constraining future professions, while early analytics enables evidence-based balance and leaderboard decisions.

## D-016 — Technical architecture and toolchain

**Decision:** Use a Rojo filesystem-first Roblox workflow with Rokit-pinned tools, Wally-locked dependencies, strict Luau plus StyLua/Selene/Luau Language Server validation, and Jest Roblox tests run in a locally built place through the documented Studio CLI. Separate client presentation, shared safe contracts/pure logic, and server authority/adapters; persist versioned stable-ID data through explicit server transactions.

**Reasoning:** This keeps source reviewable in Git, exercises tests in the real Roblox runtime, supports deterministic online/offline rules, and remains small enough for one developer without sacrificing save safety or future profession extensibility.

**P1.2 implementation amendment (2026-08-02):** Use the published development-only `jsdotlua/jest` and `jsdotlua/jest-globals` 3.10.0 Wally packages until Roblox's 3.20.0 packages reach the live Wally index. Build the Wally-backed test place as binary `.rbxl`, because Jest 3.10.0 source contains an XML CDATA terminator that is truncated in `.rbxlx`; the production place remains `.rbxlx`. This changes package/build details without changing the selected architecture or production runtime.

## D-017 — Profession progression, unlocks, and balance controls

**Decision:** Profession leveling is a major long-term grind with a shared, rising curve paced like Melvor Idle's journey toward level 99 without copying its exact balance. The first public-content cap is level 30 and expands only with meaningful content. Resources, recipes, zones, and Gold-bought profession-tool qualities use configured level requirements; gathering requires the correct owned tool, and better qualities primarily shorten action intervals. XP awards and global, profession, action, and test-only multipliers are versioned server balance configuration, separate from player-earned modifiers.

**Reasoning:** Early level 30 content can validate the loop without turning level 30 into the entire progression game. Stable requirements and adjustable multipliers let later content extend the grind safely, while tool upgrades connect profession progress to the Gold economy and provide visible, measurable throughput improvements during balancing.

**P1.4 sequencing amendment (2026-08-02):** Defer per-action mastery levels and the shared mastery pool until after the core profession loop is implemented and playtested. The private prototype awards profession XP only. Save/content extensibility for future mastery may remain, but no placeholder mastery runtime or UI is required.

**P1.4 cap amendment (2026-08-02):** Profession XP continues accumulating after the effective level reaches the current content cap. Unlock checks use the effective capped level, while total XP is preserved. Raising the cap later immediately applies previously earned XP and may unlock new levels without requiring veterans to repeat that training.

**P1.4 curve/save amendment (2026-08-02):** Use the versioned, explicit `profession_curve.v1` threshold table from level 1 to 99, reaching 15,000,000 cumulative XP. Its original exponential calibration places level 30 at about 0.1% and level 92 near halfway. Persist cumulative XP as authority and derive effective level through the saved curve version plus the current content cap. Freeze published curves; any later replacement uses an explicit migration preserving level and fractional progress.

**P1.4 unlock-ladder amendment (2026-08-02):** The representative level-30 spine unlocks Copper/Tin and Bronze Bars at level 1; Bronze weapon and armour representatives at levels 5 and 8; pickaxe upgrades at levels 10 and 20; Iron Ore/Bars at level 15; Coal and representative Iron equipment at level 20; and Steel Bars/equipment at levels 25 and 30. New accounts start with 100 Gold and buy the 50-Gold starter pickaxe. Profession tools are permanent account unlocks that cannot be sold, consumed, or lost on dungeon death.
