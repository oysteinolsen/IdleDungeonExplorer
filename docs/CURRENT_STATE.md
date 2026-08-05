# Current State

Last updated: 2026-08-05

## Completed

- Completed product discovery and recorded the accepted game direction in the roadmap-aligned briefs under `docs/design/`, `docs/DECISIONS.md`, and `docs/ROADMAP.md`.
- Completed **P1.1**: selected the Rojo filesystem-first architecture, client/shared/server boundaries, deterministic domain model, versioned persistence direction, and implementation order.
- Completed **P1.2**: scaffolded the pinned Rojo/Rokit/Wally project, strict static checks, production/test mappings, Studio-hosted Jest harness, one-command validator, and beginner-oriented local setup guide.
- Completed **P1.3** on `codex/p1.3-domain-seed` with stable lowercase namespaced-ID validation and typed item, equipment-slot, action, and modifier definitions.
- Added a validated immutable content registry. Startup construction rejects malformed/duplicate IDs, unsupported schemas, invalid numeric values, missing references, incompatible equipment tags, duplicate list values, and circular modifier dependencies.
- Added one representative content set: Bronze Ore, Weapon slot, Mine Bronze action, and Mining Speed modifier. The registry exposes typed lookup, deterministic ordered iteration, and dependency-expanded action modifiers without exposing mutable backing tables.
- Added pure deterministic modifier composition with explicit results, stable priority/ID ordering, target validation, and invalid-result protection.
- Added the first versioned Roblox-serializable player-data DTOs and default factory: Gold, 40-slot bank, equipment/profession/unlock maps, optional active-action snapshot, 16-entry unsecured loot, 50% offline efficiency, collections, and bounded statistic counters.
- Added schema compatibility reporting for current, migratable, future, and invalid versions. Full save loading/migrations remain P5.1.
- Added unit coverage for stable IDs, registry success/failures, modifier ordering/failures, default isolation/serializability, and schema compatibility. The complete Studio run passes 5 suites and 19 tests.
- Hardened the P1.2 validator after a red-path proof exposed Jest 3.10 aggregate-result quirks: failure counters are authoritative, and the success sentinel is assembled at runtime so echoed source cannot create a false positive.
- Added `.gitattributes` LF rules for Luau and `wally.lock`, keeping StyLua checks and lockfile byte hashing reproducible after Windows checkouts.
- Added a security-hardened GitHub Actions workflow that runs the non-Studio validation stages on pull requests, pushes to `main`, and manual dispatches. The normal local validator still runs Studio/Jest by default.
- Completed **P1.4** on `codex/p1.4-profession-progression`: accepted the versioned Melvor-paced profession curve, continued XP above content caps, level-gated content, permanent Gold-bought tools, configurable XP multipliers, save/rebalancing rules, and the representative level-30 Mining/Forging ladder; deferred mastery.
- Implemented the P2.1 runtime path on `codex/p2.1-continuous-mining`: an in-memory player-profile repository, server-authoritative start/stop commands, deterministic continuous-action simulation, atomic Copper Ore and Mining XP commits, effective-level calculation through `profession_curve.v1`, and post-commit event recording.
- Extended the immutable content model and registry with profession and tool definitions, explicit action requirements, content caps, and separate profession/action XP multipliers. The representative `prototype.v2` set contains Copper Ore, Mining, a starter pickaxe, and the level-1 Copper Mining action.
- Added strict versioned Mining command/snapshot contracts. The client sends intent only; it renders server-owned XP, level, ore, and action state while predicting only the progress bar from server timestamps.
- Added a minimal desktop/small-phone-sized Mining HUD and a primitive visible starter-pickaxe fixture. The temporary P2.1 profile owns the tool directly; Gold purchase behavior remains explicitly deferred to P2.2.
- Full validation passes formatting, lint, strict Luau analysis, production/test Rojo builds, and 9 Studio/Jest suites with 32 tests. Coverage includes curve checkpoints/caps, action timing/remainders/bounds, network rejection, registry cross-references, requirements, XP configuration, recorder failure, and authoritative start/advance/stop behavior.
- Completed the required P2.1 manual Roblox Studio playtest on desktop and a small-phone layout. Start/Stop Mining, repeating progress, Copper Ore/XP rewards, the visible starter pickaxe, respawn replacement, and HUD usability passed.
- Implemented the P2.3 repository-owned world scene on `codex/p2.3-minimal-village` after explicitly reordering it ahead of P2.2: a grounded village square, spawn, blacksmith, supply shop, town hall, road, landmarked mine portal, descending enclosed tunnel, and underground copper chamber.
- Replaced the empty binary world placeholder with a reviewable Rojo JSON model built entirely from Roblox primitives and built-in materials. No third-party models, textures, meshes, packages, or asset IDs were introduced.
- Added P2.3 Studio integration coverage for the required scene hierarchy, anchored geometry, asset-free boundary, and three representative copper nodes. Full validation passes 10 suites and 35 tests.
- Split the monolithic game design into focused roadmap-item briefs under `docs/design/`; replaced `docs/GAME_DESIGN.md` with a small reading index, moved P1.1 technical design to its roadmap-aligned path, updated repository guidance, and retained the original discovery brief as a non-required archive.
- Addressed the first P2.3 visual-playtest failures: removed collision from the square brazier, extended and re-angled the mine shaft to overlap both endpoints, sealed the chamber front around the shaft, and added explicit seam regression checks.
- Replaced the always-visible bottom Mining controls with per-node Roblox proximity prompts and a compact top HUD shown only while active or reporting an error. The server independently enforces a 10-stud distance from the ore surface and automatically stops Mining when the avatar walks away.
- Refined Mining UI under accepted decision D-018 and current Roblox guidance: default single-visible proximity prompts provide platform input hints; the core-UI-safe responsive HUD separates activity from stats, hides while idle, uses a selectable 48-pixel Stop target, and reports out-of-range stopping without showing an invalid action.
- Added deterministic Mining-location and adaptive-HUD coverage. Full validation passes formatting, lint, strict analysis, both Rojo builds, and 12 Studio/Jest suites with 39 tests.
- Completed **P2.3** after the developer smoke-tested the corrected build successfully. The primitive village/mine, route collision, sealed shaft/chamber geometry, ore proximity interaction, automatic out-of-range stopping, and compact adaptive HUD are accepted for the prototype.
- Implemented the P2.2 bank/economy path on `codex/p2.2-bank-economy`: a reusable 40-slot stack bank with safe overflow, five category views, favorites, Copper selling, 100 starting Gold, permanent tool purchases, increasing bank-slot purchases, and strict server-authoritative economy commands.
- Replaced the P2.1 owned-tool fixture with the real 50-Gold Starter Pickaxe purchase. Added the level-10 250-Gold Copper Pickaxe, category-based Mining tool selection, and the upgraded 2.25-second Copper action interval.
- Added bounded persisted idempotency receipts for successful economy transactions. Exact recent retries do not double-apply, transaction-ID conflicts fail explicitly, and failed preconditions leave the profile unchanged.
- Mining now commits rewards through the shared bank boundary. When a new stack cannot fit, only ore is discarded; profession XP, timing, revision, overflow statistics, client warning, and banked/overflow event fields continue correctly.
- Added a core-UI-safe responsive Bank & Economy panel with touch/gamepad-selectable actions. Full validation passes formatting, lint, strict analysis, both Rojo builds, and 16 Studio/Jest suites with 52 tests.
- Addressed the first P2.2 mobile playtest failure: the fixed top offset and 300-pixel minimum height could push half the bank window below a short landscape viewport. The bank is now a safe-area-centered modal with responsive margins, no overflowing minimum, a desktop maximum, a blocking/dismissible scrim, scaled button text, and vertically scrolling content; automated layout regression coverage passes.
- Addressed the follow-up empty-bank-modal report by replacing implicit sibling rendering with an explicit global Z-order: backdrop, panel, static controls/content, dynamic rows, and labels/buttons each occupy a guaranteed higher layer. Regression coverage now asserts that categories and inventory rows render above the panel background.
- Added a repository-owned, vibrant 512-pixel transparent icon set for Copper Ore, the Starter Pickaxe, and the Copper Pickaxe. The art is Roblox-ready, but an authorized Studio/Creator Dashboard import is still required to obtain runtime `rbxassetid://` values.

## Unfinished

- **P2.2** implementation and automated coverage are complete. A desktop and small-phone Studio smoke test is still required before changing its roadmap status to DONE.
- P2.2 presentation still needs the three generated item/tool icons imported to Roblox and their moderated asset IDs wired into icon-led bank and tool rows; essential text must remain beside the icons for accessibility.
- Queue a focused P2.3 environment-art expansion immediately after P2.2 is accepted: replace the box-room mine with an irregular rock silhouette; add substantial timber portal, wall, and roof supports; run rails down the shaft; place a detailed mine cart and dressing outside; embed one distinct ore node per available ore type partially into rock walls; and apply a vibrant layered-material/lighting pass rather than final-facing primitive placeholders. Keep this separate from the active bank milestone.
- Durable persistence, migrations, and offline simulation remain later roadmap work; P2.1 state intentionally lasts only for the current server session.
- The final public name and detailed prototype balance remain deferred.

## Relevant files

- `src/shared/content/StableId.luau` — stable namespaced-ID syntax and namespace checks.
- `src/shared/content/ContentTypes.luau` — typed definition contracts.
- `src/shared/content/ContentRegistry.luau` — immutable registry construction and cross-reference validation.
- `src/shared/content/RepresentativeContent.luau` — the four representative P1.3 definitions.
- `src/shared/domain/ModifierComposer.luau` — pure ordered modifier application.
- `src/shared/domain/ProfessionCurve.luau` — accepted explicit level 1–99 thresholds and effective content-cap calculation.
- `src/shared/domain/MiningActionSimulator.luau` — pure timestamp-based continuous-cycle proposal.
- `src/shared/net/MiningContracts.luau` — strict versioned client command and server snapshot contracts.
- `src/server/application/MiningService.luau` — requirement checks, authoritative commits, snapshots, and event recording.
- `src/server/infrastructure/InMemoryPlayerProfileRepository.luau` — isolated session-only profile adapter.
- `src/client/controllers/MiningController.luau` and `src/client/ui/MiningHud.luau` — intent transport and timestamp-reconciled progress presentation.
- `src/shared/types/PlayerDataTypes.luau` — save-envelope and player-data DTO types.
- `src/shared/domain/PlayerDataSchema.luau` — schema compatibility and fresh default factory.
- `src/shared/types/Result.luau` — shared explicit result/failure contract.
- `tests/unit/*.spec.luau` and `tests/integration/MiningService.spec.luau` — deterministic domain, contract, content, and application coverage.
- `place/world.model.json` — reviewable primitive village, mine entrance/tunnel, underground chamber, lighting fixtures, and copper-node scene source.
- `tests/integration/WorldModel.spec.luau` — Studio checks for required world structure, anchoring, asset-free construction, and copper fixtures.
- `src/server/services/MiningLocationService.luau` — server-side distance-from-ore enforcement used for start validation and automatic stop-on-leave behavior.
- `tests/unit/MiningLocationService.spec.luau` — surface-distance and missing-character coverage for spatial Mining authority.
- `src/shared/domain/BankTransactions.luau` — reusable stacked-bank add/remove/favorite transactions and safe overflow outcomes.
- `src/server/application/EconomyService.luau` and `src/shared/net/EconomyContracts.luau` — atomic idempotent selling, tool and slot purchases, snapshots, and strict client intent validation.
- `src/client/controllers/EconomyController.luau` and `src/client/ui/EconomyHud.luau` — responsive bank/category, selling, favorite, Gold, and upgrade presentation.
- `tests/integration/EconomyService.spec.luau`, `tests/unit/BankTransactions.spec.luau`, and `tests/unit/EconomyContracts.spec.luau` — bank safety, prerequisite, atomicity, conflict, and idempotency coverage.
- `scripts/run-tests.luau` and `scripts/validate.ps1` — hardened Studio test entry point and complete validator.
- `.github/workflows/ci.yml` — read-only hosted validation with pinned checkout and checksum-verified Rokit bootstrap.
- `.gitattributes` — checkout-stable LF rules for validated/hash-protected files.
- `docs/GAME_DESIGN.md` and `docs/design/README.md` — small session entry point and roadmap-to-brief map.
- `docs/design/P2.3-village-and-mine.md` — completed world-slice design and playtest record.
- `docs/ROADMAP.md` — P2.3 is complete and P2.2 is the selected next item.

## Decisions made

- P1.3 implements accepted decisions D-002 and D-016 without changing them.
- Definitions are copied and recursively frozen at registry construction; player save defaults remain fresh mutable tables because gameplay transactions will replace their affected branches.
- Modifier execution order is deterministic: ascending priority, then stable ID as the tie-breaker.
- Persisted schema compatibility is reported now, while actual migration execution remains P5.1.
- Hosted CI reuses the repository validator with an explicit `-SkipStudioTests` switch; full local validation remains required for Roblox-runtime behavior.
- P1.4 adopts Melvor-like long-tail profession pacing without copying its exact XP table. Level 30 is the first content cap and later levels are added alongside meaningful unlocks toward an eventual level-99 journey.
- Profession content and Gold-bought tool qualities are level-gated. Higher tool quality primarily increases throughput by reducing action intervals through the shared modifier pipeline.
- XP balance uses versioned server configuration with global, profession, action, and test-only multipliers kept separate from earned player modifiers.
- The roadmap now contains a separate cross-cutting track to explore and build balance simulation and gameplay-testing tools.
- Per-action mastery and the shared mastery pool are deferred until after the core profession loop is implemented and playtested. The private prototype awards profession XP only.
- Profession XP continues accumulating above the current content cap. Effective levels and unlocks remain capped, but a later cap increase immediately applies stored XP and may unlock newly released levels.
- The accepted `profession_curve.v1` is an explicit level 1–99 table reaching 15,000,000 XP, calibrated to place level 30 at about 0.1% and level 92 near halfway. Cumulative XP is save authority; published curve changes require explicit progress-preserving migrations.
- The representative ladder unlocks Copper/Tin and Bronze Bars at level 1, Bronze representatives at 5/8, pickaxe upgrades at 10/20, Iron at 15/20, and Steel at 25/30. New accounts start with 100 Gold and buy the permanent 50-Gold starter pickaxe.
- The P2.1 owned starter pickaxe is an explicit runtime fixture, not an economy exception. P2.2 replaces that shortcut with the accepted Gold purchase flow and upgrade transaction.
- Continuous action progress is derived from server timestamps. The server alone commits completed cycles, ore, and XP; the client prediction is visual and reconciles whenever a snapshot arrives.
- Event recording occurs after the authoritative profile replacement. Recorder failure is returned for observability but does not roll back a valid gameplay commit.
- P2.3 was explicitly moved ahead of P2.2 at the developer's request. It remains isolated to world construction; accepted bank, Gold, selling, and tool-purchase behavior remains unchanged and belongs to P2.2.
- The P2.3 prototype environment uses only repository-declared Roblox primitive parts, built-in materials, and lights. This satisfies the accepted free-asset constraint while keeping later art replacement straightforward.
- D-018 establishes an adaptive Roblox-native interface baseline: use familiar cross-platform affordances, core/device safe areas, responsive constraints, clear hierarchy and contrast, contextual visibility, selectable controls, and mobile-first targets while retaining the game's fantasy tone.
- P2.2 uses `prototype.v3` and player-data schema v2. Copper Ore sells for 2 Gold; the Starter and Copper Pickaxes cost 50 and 250 Gold; bank-slot costs begin at 200 Gold and rise by 50 per slot under `economy_balance.v1`. These prototype tuning details are recorded in the active P2.2 brief rather than as cross-cutting accepted decisions.
- Recent successful economy transaction receipts are retained in player data with a 128-entry bound. This covers normal network retries without allowing save data to grow indefinitely; durable persistence and migration handling remain P5.1.

## Known issues

- Jest Roblox 3.10 is still the Wally-backed development dependency until Roblox's 3.20 packages are published. Its aggregate `success` field is not trusted; zero failed-suite and failed-test counters plus the runtime-only sentinel define success.
- The current content schema supports the profession/tool/action fields and three modifier targets needed by P2.1. Later roadmap items must extend it deliberately with matching validation and tests.
- The representative prototype currently has only one bankable item, so full-bank overflow is covered deterministically in service tests but cannot yet be reached through ordinary solo play. Later content will exercise it naturally.
- `roblox/jest@3.20.0` and `roblox/jest-globals@3.20.0` are not yet available through the live Wally index.
- GitHub-hosted runners do not include Roblox Studio, so they cannot execute the Jest Roblox runtime suite. The hosted check covers deterministic static/build stages, while the default local validator covers those stages plus Studio/Jest.

## Exact recommended next task

Import the three PNGs under `assets/icons/`, wire their moderated Roblox image asset IDs into icon-led bank/tool rows, and re-test **P2.2 — Bank and economy path** in Roblox Studio on desktop and a small-phone emulator. Verify that the complete modal, Close button, tabs, icons, and scrollable rows stay inside the safe viewport, then exercise the full purchase/mining/selling/favorite flow. After P2.2 is accepted, select the queued P2.3 environment-art expansion before advancing to P3.1.
