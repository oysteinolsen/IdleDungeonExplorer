# Current State

Last updated: 2026-08-02

## Completed

- Completed product discovery and recorded the accepted game direction in `docs/GAME_DESIGN.md`, `docs/DECISIONS.md`, and `docs/ROADMAP.md`.
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

## Unfinished

- **P2.3** remains the only in-progress item until its desktop and small-phone visual playtest is recorded. Its implementation and automated Studio checks pass.
- **P2.2** intentionally follows P2.3: bank capacity/overflow, selling, Gold balances, and the real tool purchase/upgrade transaction. P2.1 temporarily stacks committed ore without enforcing capacity.
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
- `scripts/run-tests.luau` and `scripts/validate.ps1` — hardened Studio test entry point and complete validator.
- `.github/workflows/ci.yml` — read-only hosted validation with pinned checkout and checksum-verified Rokit bootstrap.
- `.gitattributes` — checkout-stable LF rules for validated/hash-protected files.
- `docs/ROADMAP.md` — P2.1 is complete and P2.2 is the only selected next item.

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

## Known issues

- Jest Roblox 3.10 is still the Wally-backed development dependency until Roblox's 3.20 packages are published. Its aggregate `success` field is not trusted; zero failed-suite and failed-test counters plus the runtime-only sentinel define success.
- The current content schema supports the profession/tool/action fields and three modifier targets needed by P2.1. Later roadmap items must extend it deliberately with matching validation and tests.
- The P2.1 bank write intentionally has no capacity/overflow behavior. Do not treat it as the reusable bank transaction; P2.2 owns that implementation and its idempotency/failure tests.
- The P2.3 copper nodes are representative visual fixtures. The P2.1 Mining HUD still starts the authoritative action globally rather than through spatial node interaction; connecting scene interaction to the existing command remains later vertical-slice integration work.
- P2.3 still requires a recorded desktop and small-phone visual playtest before its roadmap status changes to DONE.
- `roblox/jest@3.20.0` and `roblox/jest-globals@3.20.0` are not yet available through the live Wally index.
- GitHub-hosted runners do not include Roblox Studio, so they cannot execute the Jest Roblox runtime suite. The hosted check covers deterministic static/build stages, while the default local validator covers those stages plus Studio/Jest.

## Exact recommended next task

Open the P2.3 production build in Roblox Studio and verify the village-to-mine route, collision, spawn, tunnel/chamber readability, lighting, Mining HUD, and small-phone presentation. Record the result, mark P2.3 DONE, then create a new branch for **P2.2 — Bank and economy path**.
