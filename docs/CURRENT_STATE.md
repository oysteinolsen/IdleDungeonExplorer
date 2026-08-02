# Current State

Last updated: 2026-08-02

## Completed

- Completed the initial research and ten-round design interview.
- Documented the agreed Roblox idle-RPG design, prototype boundary, extensible profession model, economy, combat, offline progression, monetization guardrails, and asset strategy.
- Moved the authoritative design to `docs/GAME_DESIGN.md`.
- Created `docs/DECISIONS.md` and `docs/ROADMAP.md`.
- Corrected `AGENTS.md` to identify the project as a Roblox incremental idle RPG.
- Completed **P1.1** in `docs/TECHNICAL_DESIGN.md`: selected the Rojo filesystem-first workflow, pinned-tool/package policy, client/shared/server boundaries, deterministic domain model, server transaction flow, versioned persistence design, test strategy, exact validation commands, and implementation order.
- Recorded technical decision **D-016** and advanced **P1.2** to the only selected next item.
- Added `docs/LOCAL_DEV_SETUP.md`, a beginner-oriented Windows guide covering machine prerequisites, repository bootstrap, project tools, Studio/Rojo connection, validation, daily work, updates, and troubleshooting.
- Began the local environment setup. Rokit is installed at `C:\Users\oyste\.rokit`, `rokit.exe` exists under `.rokit\bin`, and the persistent user `PATH` includes that bin directory.

## Unfinished

- No Roblox game code, Studio place, project scaffold, automated tests, or assets have been created.
- Rokit has no project tools to install yet: the repository does not contain the P1.2 `rokit.toml`, the global Rokit manifest has an empty `[tools]` table, and `.rokit\tool-storage` currently contains only its cache metadata.
- Rojo, Wally, StyLua, Selene, and Luau Language Server therefore remain uninstalled until P1.2 scaffolds and verifies the pinned project manifest.
- The documented build and test commands have not yet been exercised against the installed Roblox Studio version.
- The final public name and detailed prototype balance remain deferred and do not block implementation.

## Relevant files

- `AGENTS.md` — repository working rules; added by the user.
- `docs/GAME_DESIGN.md` — complete living design and research record; moved and updated.
- `docs/DECISIONS.md` — concise accepted-decision index; created.
- `docs/ROADMAP.md` — ordered milestones and selected work item; created.
- `docs/CURRENT_STATE.md` — this session handoff; updated.
- `docs/TECHNICAL_DESIGN.md` — accepted private-prototype architecture, toolchain, commands, test strategy, and implementation order; created.
- `docs/LOCAL_DEV_SETUP.md` — detailed first-time and daily Windows development-environment guide; created.

## Decisions made

- Build a private, mobile-first Roblox idle-RPG vertical slice before public-release content.
- Begin with Mining, Forging, and simple Melee dungeon combat, using data-defined systems that can accept future professions and combat styles.
- Use a classic village, separate underground mine and dungeon entrances, one-monster encounters, and a Rat King boss.
- Use a shared bank, Gold-funded tool/storage progression, reduced offline progress, risky unsecured dungeon loot, and non-aggressive monetization.
- Use free, licensed, stylized low-poly assets and stage visible equipment complexity.
- Use Rojo with Rokit-pinned Rojo/Wally/StyLua/Selene/Luau Language Server tools and Wally-locked Jest Roblox packages.
- Keep valuable state server-authoritative; isolate deterministic domain logic from Roblox adapters and run automated tests in a locally built place through the documented Studio CLI.

## Known issues

- No executable test or validation workflow exists yet; the commands in `docs/TECHNICAL_DESIGN.md` are the specification that P1.2 must scaffold and verify.
- Roblox Studio is evergreen, so P1.2 must locate the installed executable, record its version, and prove the documented `RunScript` invocation on this machine.
- Shells and applications opened before Rokit installation do not see the new `.rokit\bin` `PATH` entry. Restart PowerShell, VS Code, and Codex before verifying `Get-Command rokit` and `rokit --version`.

## Exact recommended next task

Complete roadmap item **P1.2 — Scaffold the selected Roblox project structure and automated test harness**. Start by adding the reviewed `rokit.toml`, restart the shell, run `rokit install`, and verify the five pinned project-tool commands. Then add the Wally manifests, Rojo production/test mappings, strict lint/format/type configurations, empty bootstraps, a minimal Jest Roblox smoke test, and `scripts/validate.ps1`. Run the one-command validation successfully against the installed Roblox Studio CLI. Do not implement content registries or gameplay during P1.2.
