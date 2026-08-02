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

## Unfinished

- **P1.4** has not started. Profession progression still needs the newly scheduled focused design interview before runtime Mining work.
- **P2.1** remains planned. No player profile is created at runtime, no Mining command/tick exists, and the client/server bootstraps remain intentionally empty.
- The world model is still empty, so a normal playtest avatar has no ground. World construction remains P2.3.
- Persistence repositories, migrations, offline simulation, and live gameplay remain later roadmap work.
- The final public name and detailed prototype balance remain deferred.

## Relevant files

- `src/shared/content/StableId.luau` — stable namespaced-ID syntax and namespace checks.
- `src/shared/content/ContentTypes.luau` — typed definition contracts.
- `src/shared/content/ContentRegistry.luau` — immutable registry construction and cross-reference validation.
- `src/shared/content/RepresentativeContent.luau` — the four representative P1.3 definitions.
- `src/shared/domain/ModifierComposer.luau` — pure ordered modifier application.
- `src/shared/types/PlayerDataTypes.luau` — save-envelope and player-data DTO types.
- `src/shared/domain/PlayerDataSchema.luau` — schema compatibility and fresh default factory.
- `src/shared/types/Result.luau` — shared explicit result/failure contract.
- `tests/unit/*.spec.luau` — P1.2 harness test plus P1.3 unit coverage.
- `scripts/run-tests.luau` and `scripts/validate.ps1` — hardened Studio test entry point and complete validator.
- `.github/workflows/ci.yml` — read-only hosted validation with pinned checkout and checksum-verified Rokit bootstrap.
- `.gitattributes` — checkout-stable LF rules for validated/hash-protected files.
- `docs/ROADMAP.md` — P1.4 is the only selected next item; P2.1 follows after the interview decisions are recorded.

## Decisions made

- P1.3 implements accepted decisions D-002 and D-016 without changing them.
- Definitions are copied and recursively frozen at registry construction; player save defaults remain fresh mutable tables because gameplay transactions will replace their affected branches.
- Modifier execution order is deterministic: ascending priority, then stable ID as the tie-breaker.
- Persisted schema compatibility is reported now, while actual migration execution remains P5.1.
- Hosted CI reuses the repository validator with an explicit `-SkipStudioTests` switch; full local validation remains required for Roblox-runtime behavior.

## Known issues

- Jest Roblox 3.10 is still the Wally-backed development dependency until Roblox's 3.20 packages are published. Its aggregate `success` field is not trusted; zero failed-suite and failed-test counters plus the runtime-only sentinel define success.
- The current content schema supports only the P1.3 definition fields and modifier targets needed by the representative seed. Later roadmap items must extend the schema deliberately with matching validation and tests.
- `roblox/jest@3.20.0` and `roblox/jest-globals@3.20.0` are not yet available through the live Wally index.
- GitHub-hosted runners do not include Roblox Studio, so they cannot execute the Jest Roblox runtime suite. The hosted check covers deterministic static/build stages, while the default local validator covers those stages plus Studio/Jest.

## Exact recommended next task

Create a new branch for **P1.4 — Conduct a focused profession-progression design interview**. Decide and document profession level curves, action mastery, XP/offline rules, unlock cadence, tool/recipe/zone requirements, prototype pacing/caps, shared versus profession-specific behavior, and save/rebalancing implications. Do not start P2.1 until those accepted outcomes are recorded in the authoritative design documents.
