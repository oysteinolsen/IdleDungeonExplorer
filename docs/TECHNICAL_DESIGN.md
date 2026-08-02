# Technical Design

> Status: accepted private-prototype architecture for roadmap item P1.1. This document selects the development workflow and establishes boundaries for later implementation. It does not add gameplay code.
>
> Tool versions were checked on 2026-08-02. All project tools and packages are pinned; upgrades are deliberate changes followed by the full validation workflow.

## Goals and constraints

The technical foundation must let one developer build and safely change a server-authoritative Roblox vertical slice while learning Roblox development. It must support the confirmed Mining → Forging → equipment → dungeon loop, offline simulation, versioned saves, and later professions without building a general-purpose framework before a real feature needs it.

The architecture optimizes for:

- plain-text source in Git and small, reviewable diffs;
- fast local iteration with Roblox Studio still responsible for playtesting, scene authoring, and device emulation;
- deterministic domain logic that is easy to test;
- server ownership of every valuable state transition;
- explicit errors and recoverable persistence failures;
- stable IDs and data-defined content;
- a single-command local validation path on Windows;
- the smallest useful number of external dependencies.

The private prototype remains one Roblox experience with one place. Shared services must not depend on that choice, so a later dungeon place can use the same modules and persistent data.

## Selected workflow and toolchain

### Source and Studio workflow

Use **Rojo's filesystem-first workflow**. Git files are authoritative for scripts, configuration, tests, and data definitions. Roblox Studio is authoritative only for interactive scene construction, imported assets, animation setup, and visual/device testing.

The normal loop is:

1. Run `rojo serve default.project.json` in the repository.
2. Open the development place in Studio and connect the Rojo plugin.
3. Edit Luau and configuration in VS Code or Codex; Rojo syncs those changes into Studio.
4. Build world content in Studio. Export intentional non-script world changes to the repository-owned place/model file before committing.
5. Never treat a script edited only inside Studio as saved work. Move the change to its source file immediately.

Rojo 7.7 has a new syncback feature, but the prototype will not depend on it while its documentation and operating conventions are still maturing. This avoids an ambiguous two-way source of truth. We can reassess syncback after the base workflow is proven.

Generated place files under `build/`, installed Wally packages, and generated sourcemaps are not committed. Repository-owned source place/model files under `place/` are committed even though they are binary.

### Pinned tools

P1.2 will add a project `rokit.toml` containing these stable versions:

| Tool | Version | Purpose |
|---|---:|---|
| Rokit | 1.2.0 | Install and expose the project-pinned CLI tools. |
| Rojo | 7.7.0 | Map filesystem files into the Roblox DataModel, serve Studio, build places, and generate sourcemaps. |
| Wally | 0.3.2 | Resolve Luau dependencies and enforce the committed lockfile. |
| StyLua | 2.5.2 | Deterministic Luau formatting. |
| Selene | 0.31.0 | Roblox-aware linting and common-error detection. |
| Luau Language Server | 1.69.0 | Editor support and standalone strict type analysis with the Rojo sourcemap. |

The expected tool declarations are:

```toml
[tools]
rojo = "rojo-rbx/rojo@7.7.0"
wally = "upliftgames/wally@0.3.2"
stylua = "johnnymorganz/stylua@2.5.2"
selene = "kampfkarren/selene@0.31.0"
luau-lsp = "johnnymorganz/luau-lsp@1.69.0"
```

Rokit itself is the one machine-level prerequisite and is installed once. `rokit install` then installs the repository's exact tool versions. Roblox Studio remains evergreen because Roblox controls its update channel; validation records the executable version it actually used.

Use the VS Code **Luau Language Server** and **StyLua** extensions, configured to use the Rokit-managed binaries. The Rojo Studio plugin is the only required Studio plugin.

### Dependencies

Use Wally only for libraries that materially reduce risk or maintenance. Every dependency must be pinned in `wally.toml`, resolved in committed `wally.lock`, license-compatible, and reviewed before introduction. Production code should prefer small first-party modules over broad frameworks.

The initial automated test dependency is current Jest Roblox:

```toml
[dev-dependencies]
Jest = "roblox/jest@=3.20.0"
JestGlobals = "roblox/jest-globals@=3.20.0"
```

Do not introduce a client framework, networking framework, persistence library, dependency injection container, or promise library during the foundation milestone. Add one only when a concrete roadmap item demonstrates that the small first-party boundary is inadequate.

## Repository and DataModel layout

P1.2 will scaffold this logical layout:

```text
IdleDungeonExplorer/
├── default.project.json
├── test.project.json
├── rokit.toml
├── wally.toml
├── wally.lock
├── stylua.toml
├── selene.toml
├── .luaurc
├── place/
│   └── world.rbxm
├── scripts/
│   ├── validate.ps1
│   └── run-tests.luau
├── src/
│   ├── client/
│   │   ├── bootstrap.client.luau
│   │   ├── controllers/
│   │   └── ui/
│   ├── server/
│   │   ├── bootstrap.server.luau
│   │   ├── application/
│   │   ├── content/
│   │   ├── infrastructure/
│   │   └── services/
│   └── shared/
│       ├── content/
│       ├── domain/
│       ├── net/
│       └── types/
└── tests/
    ├── integration/
    ├── support/
    └── unit/
```

`default.project.json` maps the directories as follows:

| Filesystem | Roblox DataModel | Visibility |
|---|---|---|
| `src/shared` | `ReplicatedStorage/Shared` | Server and client |
| Wally production packages | `ReplicatedStorage/Packages` | Server and client as required |
| `src/server` | `ServerScriptService/Server` | Server only |
| `src/client` | `StarterPlayer/StarterPlayerScripts/Client` | Client only |
| `place/world.rbxm` | `Workspace/World` | Replicated world |

`test.project.json` adds `tests` and Wally development packages to a test-only place. Tests and Jest packages must never appear in the production build.

### Boundary responsibilities

#### Shared

Shared code contains immutable value types, public content metadata, deterministic domain functions used by both presentation and authority, remote message schemas, and constants safe for clients to inspect.

Shared code must not access `DataStoreService`, `MarketplaceService`, `MemoryStoreService`, server-only content, or mutable player profiles. It must not contain future random rolls, secret drop configuration, or authority decisions.

#### Server

Server code owns player profiles, commands, transactions, action scheduling, reward rolls, bank and equipment mutation, combat and offline simulation, persistence, entitlements, analytics, rate limiting, and all Roblox service adapters.

Server-only content contains authoritative recipes, loot tables, requirements, economy values, and other information that a client does not need. Public display data can be projected into the shared registry; the projection is not itself authoritative.

#### Client

Client code owns input, cameras, animation requests, effects, local UI state, and rendering server-provided snapshots. It sends intent such as `StartMining` or `UseFood`; it never sends a reward, elapsed duration, damage result, price, inventory balance, or level as truth.

The client may predict harmless presentation such as a progress bar. Every predicted value must reconcile to a server timestamped snapshot and must never grant state.

#### Infrastructure

Roblox APIs and nondeterministic facilities sit behind narrow server-side adapters: clock, ID generator, random source, player-data repository, entitlement reader, analytics sink, and remote transport. Domain and application modules receive these collaborators through constructor tables rather than calling global services directly.

This is composition, not a container or inheritance hierarchy. Introduce an interface only when there is both a real adapter and a test fake, or two real consumers.

## Content and stable IDs

All expandable content is registered by stable lowercase namespaced strings such as `item.bronze_ore`, `profession.mining`, `action.mine_bronze`, and `equipment_slot.weapon`. Display names, asset IDs, balance numbers, and ordering are fields, never identity.

Each definition is a validated immutable table. Registry construction must reject:

- duplicate or malformed IDs;
- missing referenced IDs;
- circular nested loot tables or modifier references;
- negative durations, quantities, weights, prices, or requirements;
- invalid equipment-slot/tag combinations;
- client-visible definitions that contain server-only reward rules;
- definitions whose schema version is unsupported.

Registries expose lookup and ordered iteration, not their mutable backing tables. They are built once during server startup; startup fails explicitly if validation fails. P1.3 uses representative test definitions only.

Every published balance set has a `contentVersion`. An active or offline action stores the version that started it. When balance changes could alter already-started simulation, retain the required prior definitions or provide an explicit action migration. Never silently finish an old action under incompatible new rules.

## Domain and application design

### Deterministic core

Reward calculation, modifiers, action advancement, combat resolution, migrations, and inventory planning should be pure functions wherever practical. Inputs include state, definitions, an explicit clock value, and an injected seeded random source; outputs include the proposed next state, rewards, emitted domain events, and a typed stop reason.

Pure modules do not yield, access Roblox services, read global time, or create random generators internally. This makes online and offline actions use the same rules and makes failures reproducible from a seed and input snapshot.

Use `--!strict` in every first-party Luau source and test file. Export explicit types at module boundaries. Prefer records represented as typed tables and plain functions over deep class hierarchies. Use metatable-based objects only where identity and lifecycle materially improve the design.

### Results and errors

Expected failures return a discriminated result:

```luau
export type Result<T> =
    { ok: true, value: T }
    | { ok: false, code: string, retryable: boolean, detail: string? }
```

Stable error codes drive UI and telemetry. Free-form detail is diagnostic and is not sent directly to players. Unexpected programmer errors may throw and fail tests or startup. `pcall` belongs at Roblox/network infrastructure boundaries; catches must log context or return an explicit error and must never be empty.

### Player command transaction

All valuable mutations pass through one server-side command executor:

1. Decode a versioned command and reject unknown fields or excessive payloads.
2. Validate the authenticated player, stable IDs, types, ranges, ownership, unlocks, cooldown/rate limit, and current state.
3. Serialize commands for that player's profile. Only one command may mutate a profile at a time.
4. Calculate a complete proposed result without yielding or mutating the live profile.
5. Recheck invariants, then replace the affected live-state branches as one in-memory commit.
6. Send a sanitized result/snapshot to the client.
7. Publish the successful domain event through `EventRecorder`.
8. Mark the profile dirty for persistence according to the save policy.

Analytics failure does not roll back valid gameplay, but it is reported and counted. A rejected transaction does not emit a success event. Commands that can be retried or duplicated carry a bounded request ID; the server retains recent results and returns the same outcome rather than applying the mutation twice.

No transaction yields while holding the per-player mutation queue. External calls required before a commit, such as an entitlement lookup, occur before entering the critical section and their result is revalidated inside it. Purchase receipts use Roblox's receipt ID as a durable idempotency key.

### Network contract

Use a small explicit set of `RemoteEvent` objects created by the server. Mutation requests are commands; server replies and state changes are events. Avoid `RemoteFunction` for valuable mutations because synchronous client waits couple UI responsiveness to server work.

Every message has a schema version and maximum size. Validate tables recursively, reject NaN/infinity, cap strings and arrays, and never dynamically select a server module or method from client text. Rate limits are per player and command category. The server uses its own time, random rolls, prices, and content definitions.

## Player data and persistence

### Save envelope

Only Roblox-serializable primitives are persisted. The top-level record is:

```luau
export type SaveEnvelope = {
    schemaVersion: number,
    revision: number,
    updatedAt: number,
    contentVersion: string,
    sessionLease: SessionLease?,
    data: PlayerData,
}
```

`PlayerData` owns currencies, the secured bank, equipment by slot ID, profession progression, unlocks, active action snapshot, unsecured dungeon loot, settings, collection discoveries, and bounded statistics. Item templates use stable content IDs. Non-fungible or future-affixed items additionally have server-generated unique instance IDs.

Do not persist Instances, metatables, functions, unbounded logs, or display names. Defaults are created by one versioned factory. Saved records are copied before mutation so a failed transformation cannot partially corrupt the live value.

### Migrations

Migrations are pure, sequential functions from version N to N+1. Loading rejects future schema versions. Every migration has fixtures for the oldest supported input, repeated execution behavior where relevant, removed/renamed IDs, and invalid data.

A migration never drops an item merely because content changed. Removed bank items move through an explicit replacement/refund rule; removed equipment slots return their items to the bank or a bounded recovery area. Migration failure stops the load and preserves the original stored record.

### Load, lease, and save policy

The production repository uses `DataStoreService:UpdateAsync()` and a time-limited session lease stored in the envelope. Load atomically acquires the lease; heartbeat saves refresh it; normal shutdown releases it. A stale lease expires after a configured interval so a crashed server cannot lock a profile forever. A second server that cannot acquire the lease rejects the load with a retryable error instead of creating a new writable profile.

One save coordinator per profile ensures only one save is in flight. It snapshots the current revision, uses bounded exponential backoff with jitter for retryable failures, and never lets an older completion overwrite a newer revision. Autosave cadence, retry count, lease length, and shutdown budget are configuration values and are covered by fake-clock tests.

If initial load fails, gameplay that can mutate persistent state remains disabled. Never substitute default data and later overwrite an existing record. If a save exhausts retries, keep the profile dirty, surface a player-safe warning, record diagnostics, and retry at the next bounded opportunity. `BindToClose` performs a final bounded flush but is not the only save path.

Studio and unit tests use an in-memory repository by default. Access to live Studio DataStores requires an explicit opt-in test configuration and a separate test universe; normal validation never touches production data.

### Active and offline action snapshot

An active action snapshot contains at least the stable action ID, content version, start/latest-simulated server timestamps, selected quantity or repeat mode, reserved ingredients, deterministic random state/seed where applicable, and accumulated state needed to resume exactly.

On load, calculate real elapsed time from trusted server time, clamp it to the confirmed 24-hour cap, apply the account's configured 50–75% efficiency, and pass effective time through the normal simulator. Simulation has explicit iteration/work limits and returns a stop reason such as death, insufficient inputs, full loot, completed quantity, or invalid migrated action. It never awards progress after the stop time.

## Analytics boundary

Gameplay services publish versioned domain events to a server-only `EventRecorder` after a transaction commits. The recorder composes zero or more sinks: test capture, development diagnostics, statistics projections, Roblox AnalyticsService mapping, and a later external adapter.

Event IDs, user/session IDs, content version, stable content IDs, server time, numeric value, and a small validated property map are supplied explicitly. High-frequency activity is summarized at action batch, encounter, run, or offline-session boundaries. Sink errors are explicit and bounded; raw events are not appended indefinitely to player saves.

P1.3 defines the event types needed by its representative registries but does not implement analytics export. The complete recorder and statistics projections remain roadmap item P5.3.

## Testing strategy

### Automated layers

1. **Static validation:** StyLua check, Selene, strict Luau analysis using a generated Rojo sourcemap, registry validation, and production/test Rojo builds.
2. **Unit tests:** Jest Roblox specs for pure registries, modifiers, transactions, migrations, inventory rules, deterministic simulators, and stop conditions. Use fake clock, random source, ID generator, repository, entitlement reader, and event recorder.
3. **Server integration tests:** Build a test-only place and run Jest in Roblox Studio through the documented `RunScript` CLI task. Exercise the real DataModel, module mapping, remotes, serialization edges, and Roblox adapters with safe fakes.
4. **Manual Studio playtests:** F5 client/server tests, Start Server with multiple clients where replication matters, Device Emulator at a small phone resolution, touch controls, disconnect/reconnect, and deliberately injected service failures.
5. **Published test-universe checks:** Only when a Roblox API cannot be represented locally, run an explicit smoke checklist in a private test universe with isolated DataStores and analytics.

Tests are written in the same change as the behavior they protect. A domain/application module is not complete without success, rejection, boundary, and invariant tests. Persistence changes require migration and failure-path tests. Random behavior uses fixed seeds and verifies invariants in addition to selected outcomes.

### One-command validation

P1.2 will create this repository command:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate.ps1
```

The script fails on the first failed stage and performs, in order:

```powershell
rokit install
wally install --locked
stylua --check src tests
selene src tests
rojo sourcemap test.project.json --output build/sourcemap.json
luau-lsp analyze --sourcemap=build/sourcemap.json src tests
rojo build default.project.json --output build/IdleDungeonExplorer.rbxlx
rojo build test.project.json --output build/IdleDungeonExplorerTests.rbxlx
```

It then finds the newest installed `%LOCALAPPDATA%\Roblox\Versions\*\RobloxStudioBeta.exe` using PowerShell file enumeration (never `where.exe`) and invokes:

```powershell
RobloxStudioBeta.exe `
    --task RunScript `
    --localPlaceFile build/IdleDungeonExplorerTests.rbxlx `
    --runScriptFile scripts/run-tests.luau `
    --outputFile build/test-output.log `
    --quitAfterExecution
```

The test entry point prints a unique success sentinel only after Jest reports success. Validation checks both the Studio exit code and that sentinel, and prints the captured log on failure. Paths passed to Studio are resolved to absolute paths by the script. P1.2 verifies the exact command against the installed Studio version before declaring the harness complete.

Useful focused commands are:

```powershell
rojo serve default.project.json
stylua src tests
rojo build default.project.json --output build/IdleDungeonExplorer.rbxlx
```

The full validation command remains the definition of done before a commit or handoff.

## Smallest end-to-end implementation order

Do not work ahead of the roadmap. Within each selected item, implement the thinnest tested path in this order:

1. **P1.2 foundation:** pinned tools, Rojo mappings, Jest test place, strict analysis, formatting/linting, one-command validation, and empty server/client bootstraps.
2. **P1.3 domain seed:** stable-ID types and validator; one representative item, slot, action, and modifier; versioned player-data/default factory; pure modifier composition; tests for invalid registries and compatibility. No gameplay loop.
3. **P2.1 first runtime path:** one in-memory player profile, one Mining command, one deterministic action tick, XP and ore proposal, authoritative commit, one event captured by a test sink, and a minimal client progress display. Persistence still uses the in-memory adapter.
4. **P2.2 economy path:** shared bank transaction, overflow outcome, selling/Gold, one tool upgrade, and their failure/idempotency tests.
5. **P3 forging/equipment path:** ingredient reservation, repeat/abort transaction, equipment loadout, and visible representative equipment.
6. **P4 dungeon path:** shared deterministic combat simulator first, then active presentation, unsecured loot, banking/repeat, and death transactions.
7. **P5 durable path:** DataStore repository and migrations, offline replay through the existing simulators, then EventRecorder sinks/statistics projections.
8. **P6 connected slice:** replace temporary screens and glue with the complete representative loop, then mobile and repeated solo playtests.

At every step, prefer one real vertical behavior with tests over a collection of unused abstractions. A later profession should extend definitions and shared services; if it requires a new save engine, bank, scheduler, or UI framework, treat that as an architecture defect to resolve explicitly.

## Definition of done for technical changes

A technical roadmap item is complete only when:

- its implementation and tests are in the same diff;
- every expected failure is explicit and no catch is silent;
- server authority and client-visible data boundaries remain intact;
- new data has stable IDs and a migration/default strategy;
- new packages use the latest stable reviewed version and their lockfile is committed;
- the one-command validation passes;
- a relevant Studio/mobile playtest is recorded when presentation or Roblox runtime behavior changed;
- the Git diff has been reviewed; and
- `docs/CURRENT_STATE.md` and roadmap status are updated.

## Sources

- [Roblox third-party tools and Rojo/Rokit workflow](https://create.roblox.com/docs/projects/external-tools)
- [Roblox Studio command-line interface](https://create.roblox.com/docs/studio/command-line-interface)
- [Roblox Studio testing modes](https://create.roblox.com/docs/studio/testing-modes)
- [Roblox Luau type checking](https://create.roblox.com/docs/luau/type-checking)
- [Rojo releases](https://github.com/rojo-rbx/rojo/releases)
- [Rokit releases](https://github.com/rojo-rbx/rokit/releases)
- [Wally documentation and lockfile behavior](https://github.com/UpliftGames/wally)
- [StyLua documentation](https://github.com/JohnnyMorganz/StyLua)
- [Selene releases](https://github.com/Kampfkarren/selene/releases)
- [Luau Language Server and Rojo sourcemaps](https://github.com/JohnnyMorganz/luau-lsp)
- [Jest Roblox Wally packages and usage](https://github.com/Roblox/jest-roblox)
- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
