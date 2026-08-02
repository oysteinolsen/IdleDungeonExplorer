# Roadmap

Status legend: **DONE**, **NEXT**, **PLANNED**, **DEFERRED**. Only one item may be **NEXT** or in progress at a time.

## M0 — Product discovery

- **DONE P0.1:** Research Melvor Idle, Roblox conventions, comparable games, monetization, assets, and technical constraints.
- **DONE P0.2:** Complete the design interview and record the agreed direction in `docs/GAME_DESIGN.md`.
- **DONE P0.3:** Establish the decision index, roadmap, and concise session handoff.

## M1 — Private-prototype technical foundation

- **DONE P1.1:** Define the private-prototype technical architecture and toolchain in `docs/TECHNICAL_DESIGN.md`. Selected a Rojo/Rokit/Wally workflow; specified client/shared/server boundaries, data registries, save/versioning, server-authoritative transactions, testing, exact commands, and the smallest end-to-end implementation order. No gameplay implementation was included.
- **NEXT P1.2:** Scaffold the selected Roblox project structure and automated test harness, with a documented one-command validation workflow.
- **PLANNED P1.3:** Implement and test stable-ID content registries, shared action definitions, modifier composition, and versioned player-data types using representative test data only.

## M2 — Mining and economy slice

- **PLANNED P2.1:** Implement server-authoritative continuous Mining with one ore, Mining XP, a visible starter pickaxe, progress feedback, and tests.
- **PLANNED P2.2:** Add the shared bank, full-bank overflow warning/telemetry, selling, Gold, and a level-gated pickaxe upgrade.
- **PLANNED P2.3:** Build the minimal village and distinct underground mine entrance using audited free assets or primitives.

## M3 — Forging and equipment slice

- **PLANNED P3.1:** Implement atomic repeating Forging with cancellation refunds and tests.
- **PLANNED P3.2:** Add the representative bar, weapon, armour item, equipment slots, stats, and visible weapon/helmet attachments.

## M4 — Dungeon slice

- **PLANNED P4.1:** Implement one-monster-at-a-time combat, Power Strike, supplies, and the shared deterministic simulator.
- **PLANNED P4.2:** Build the rat-and-snake dungeon, Rat King lunge, active first-clear gate, configurable loot, manual banking, and repeat toggle.
- **PLANNED P4.3:** Add death handling, unsecured-loot loss, eligible equipment loss, and transaction tests.

## M5 — Persistence and offline slice

- **PLANNED P5.1:** Implement versioned save/load with explicit DataStore failure handling and Studio-safe adapters.
- **PLANNED P5.2:** Implement timestamp-based offline Mining, Forging, and dungeon simulation with the 24-hour cap and return report.
- **PLANNED P5.3:** Add the versioned EventRecorder boundary and prototype statistics projections.

## M6 — Private prototype validation

- **PLANNED P6.1:** Connect the complete Mining → Forging → equipment → dungeon → loot/sell/tool-upgrade loop with only representative items.
- **PLANNED P6.2:** Test on desktop and a small phone layout; fix correctness, usability, save-safety, and performance issues.
- **PLANNED P6.3:** Conduct repeated solo playtests and decide whether the loop is fun and understandable enough to continue toward public-version content.

## Later public-version work

- **DEFERRED:** Final naming and availability checks, full Bronze/Iron/Steel content, second dungeon, leaderboards, pets, supporter pass, public testing, launch art/marketing, and live operations.
