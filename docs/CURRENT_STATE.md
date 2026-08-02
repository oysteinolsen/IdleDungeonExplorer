# Current State

Last updated: 2026-08-02

## Completed

- Completed the initial research and ten-round design interview, then recorded the agreed direction in `docs/GAME_DESIGN.md`, `docs/DECISIONS.md`, and `docs/ROADMAP.md`.
- Completed **P1.1** in `docs/TECHNICAL_DESIGN.md`: selected the Rojo filesystem-first workflow, pinned tool/package policy, client/shared/server boundaries, deterministic domain model, server transaction flow, versioned persistence design, test strategy, exact validation commands, and implementation order.
- Completed **P1.2** on `chore/p1.2-project-scaffold` with production/test Rojo mappings, strict configuration, client/server bootstraps, planned source/test boundaries, ignore rules, and a minimal repository-owned `place/world.rbxm`.
- Pinned and verified Rojo 7.7.0, Wally 0.3.2, StyLua 2.5.2, Selene 0.31.0, and Luau Language Server 1.69.0 through Rokit.
- Added the committed Wally lockfile for the development-only `jsdotlua/jest` and `jsdotlua/jest-globals` 3.10.0 packages. The graph contains 48 restored packages and is excluded from production builds.
- Added `tests/jest.config.luau`, a strict smoke spec, and `scripts/run-tests.luau` with explicit rejected/failure handling and a unique success sentinel.
- Added `scripts/validate.ps1`, which verifies exact tool versions, protects the Wally lockfile by hash, checks formatting/lint/types, checks production/test boundaries, builds both places, locates the current Studio installation, enforces a timeout, and requires both a zero exit code and the Jest success sentinel.
- Proved the one-command validator against Roblox Studio `0.732.0.7321040`: all stages pass, including one Jest suite and one test through Studio CLI.
- Installed the matching Rojo Studio plugin, connected Studio to `localhost:34872`, and completed an F5 start/stop smoke test without errors.
- Updated the technical/setup documentation for Wally 0.3.2 lockfile behavior, the approved Jest 3.10.0 fallback, and the binary `.rbxl` test-place requirement.
- Added repository guidance to explain Roblox-specific decisions in plain language with .NET/backend analogies before requesting approval.

## Unfinished

- **P1.3** has not started. No content registry, player-data model, modifier implementation, or gameplay system exists yet.
- The P1.2 world model is intentionally empty, so a playtest avatar spawns without ground and falls. World construction remains P2.3.
- The final public name and detailed prototype balance remain deferred and do not block implementation.

## Relevant files

- `AGENTS.md` — repository working rules and developer-context guidance.
- `docs/GAME_DESIGN.md` — complete living design and research record.
- `docs/DECISIONS.md` — accepted-decision index, including the P1.2 implementation amendment to D-016.
- `docs/ROADMAP.md` — ordered milestones; P1.3 is the only selected next item.
- `docs/TECHNICAL_DESIGN.md` — accepted private-prototype architecture, toolchain, test strategy, and implementation order.
- `docs/LOCAL_DEV_SETUP.md` — beginner-oriented Windows development workflow and troubleshooting guide.
- `rokit.toml` — exact project CLI tool pins.
- `wally.toml` and `wally.lock` — exact development dependency declaration and resolution.
- `default.project.json` and `test.project.json` — production and test-only Rojo DataModel mappings.
- `scripts/validate.ps1` and `scripts/run-tests.luau` — one-command validation and Studio Jest entry point.
- `tests/jest.config.luau` and `tests/unit/TestHarness.spec.luau` — Jest discovery configuration and foundation smoke test.

## Decisions made

- Keep D-016's Rojo/Rokit/Wally/Studio architecture unchanged.
- Use the currently published development-only Jest Roblox 3.10.0 Wally packages until Roblox's 3.20.0 packages reach the live Wally index.
- Build the Wally-backed test place as binary `.rbxl`, because Jest 3.10.0 contains a source `]]>` sequence that is truncated in an XML `.rbxlx` place. Keep the dependency-free production build as `.rbxlx`.
- Treat `wally.lock` like a NuGet `packages.lock.json`: commit it, restore from it, and make validation fail if restore changes it.

## Known issues

- `roblox/jest@3.20.0` and `roblox/jest-globals@3.20.0` exist in Roblox's source manifests but are not published in the live Wally index. Upgrade only after publication and a complete validation run.
- Wally 0.3.2 has no `--locked` option. The validator enforces locked behavior by requiring the lockfile and comparing its SHA-256 hash before and after restore.
- Shells and applications opened before Rokit installation may not see the persistent `.rokit\bin` `PATH` entry until restarted.

## Exact recommended next task

Create a new branch from `main` for **P1.3 — Implement and test stable-ID content registries, shared action definitions, modifier composition, and versioned player-data types using representative test data only**. Follow the P1.3 boundary in `docs/TECHNICAL_DESIGN.md`; do not implement a gameplay loop or begin P2.1.
