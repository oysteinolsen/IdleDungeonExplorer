# Local Development Setup

> Audience: a Windows developer who is new to Roblox Studio, Rojo, Rokit, Wally, Luau tooling, and this repository.
>
> Last verified: 2026-08-02. The project architecture and pinned versions are defined in [`TECHNICAL_DESIGN.md`](TECHNICAL_DESIGN.md).

## What you are setting up

Roblox Studio is the application that runs and visually edits the game. This project does not store all code only inside Studio, because Studio files are difficult to review and merge in Git. Instead, the project uses a filesystem-first workflow:

```text
VS Code / Codex edits files
            │
            ▼
    Rojo synchronizes them
            │
            ▼
 Roblox Studio runs the game
```

The tools have separate jobs:

| Tool | What it does | How often you interact with it |
|---|---|---|
| Git | Tracks file history, branches, commits, and GitHub synchronization. | Every work session. |
| PowerShell 7 | Runs the repository's Windows setup and validation commands. | Every work session. |
| VS Code | Edits Luau, JSON, TOML, Markdown, and PowerShell files. | Most coding sessions. |
| Roblox Studio | Builds the 3D world and runs Roblox playtests. | Most gameplay sessions. |
| Rokit | Installs the exact command-line tool versions selected by the repository. | Initial setup and after tool-version changes. |
| Rojo | Builds Roblox place files and live-syncs filesystem changes into Studio. | Every coding/playtest session. |
| Wally | Installs pinned Luau libraries such as the test framework. | Initial setup and after dependency changes. |
| StyLua | Formats Luau consistently. | Usually through validation or format-on-save. |
| Selene | Finds suspicious or non-idiomatic Luau. | Usually through validation. |
| Luau Language Server | Provides completion and type checking in VS Code and validation. | Runs in the editor and validation. |
| Jest Roblox | Runs automated tests inside the Roblox runtime. | Through the validation script. |

You do not need Node.js, npm, Python, .NET, Java, Maven, Cargo, or a separate Lua installation for this project.

## Current repository state

Roadmap item P1.1 has selected and documented the toolchain. P1.2 is responsible for adding these executable project files:

- `rokit.toml`;
- `wally.toml` and `wally.lock`;
- `default.project.json` and `test.project.json`;
- the `src/` and `tests/` trees;
- `scripts/validate.ps1` and the Studio test entry point.

Until P1.2 exists on your branch, you can complete the machine-level installation, clone/open the repository, and install the editor extensions. Commands that use the files above will correctly fail because those files have not been created yet. Do not create substitute manifests by hand; pull the completed P1.2 change when it is available.

## Before you begin

You need:

- Windows 10 or Windows 11; Windows 11 is recommended by Roblox;
- a Roblox account;
- a GitHub account if you need to push branches;
- an internet connection for installation and dependency restore;
- permission to install applications for your Windows user;
- at least 8 GB RAM recommended for Studio;
- a repository location that is not managed by OneDrive or another live file-sync service, if practical.

This guide uses **PowerShell 7**, whose executable is named `pwsh`. Windows PowerShell 5.1, whose executable is `powershell.exe`, is a different older application.

When a code block contains commands, run them one line at a time. Do not type the prompt text such as `PS C:\>` if your terminal displays it.

## Step 1 — Open a terminal and check WinGet

1. Open the Windows Start menu.
2. Search for **Terminal** or **Windows PowerShell**.
3. Open it normally. Administrator mode is usually unnecessary because the recommended installers are per-user.
4. Run:

```powershell
winget --version
```

If this prints a version, continue.

If Windows says `winget` is not recognized:

1. Open Microsoft Store.
2. Search for **App Installer** from Microsoft.
3. Install or update it.
4. Close and reopen the terminal.
5. Run `winget --version` again.

## Step 2 — Install Git

Git stores the repository history and communicates with GitHub.

Run:

```powershell
winget install --id Git.Git --exact --source winget
```

Accept the package agreement if WinGet asks. When installation finishes, close every terminal window and open a new one so Windows reloads `PATH`.

Verify Git:

```powershell
git --version
```

You should see `git version` followed by a version number.

Configure the identity that Git writes into future commits. Replace the example values with your real name and the email associated with GitHub:

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Verify the values:

```powershell
git config --global user.name
git config --global user.email
```

Do not put passwords, access tokens, or other secrets into Git configuration files in this repository.

## Step 3 — Install PowerShell 7

The repository validation script targets modern PowerShell.

Run:

```powershell
winget install --id Microsoft.PowerShell --exact --source winget
```

Close the current terminal, then open **PowerShell 7** from the Start menu. From this point onward, run the guide in that window.

Verify it:

```powershell
pwsh --version
```

The output should start with `PowerShell 7`. PowerShell 7 installs beside Windows PowerShell 5.1; it does not remove the older version.

## Step 4 — Install Visual Studio Code

VS Code is the recommended text editor for this workflow.

Run:

```powershell
winget install --id Microsoft.VisualStudioCode --exact --source winget
```

Close and reopen PowerShell 7, then verify:

```powershell
code --version
```

If `code` is not recognized, restart Windows or rerun the VS Code installer and make sure its option to add VS Code to `PATH` is enabled.

## Step 5 — Install Roblox Studio

Roblox Studio should be installed from Roblox's official Creator Hub rather than from an unofficial download site.

1. Open [Roblox Studio setup](https://create.roblox.com/docs/studio/setup).
2. Select **Download Studio**.
3. Run the downloaded `RobloxStudio.exe` installer.
4. Select **Launch Studio** when installation finishes.
5. Sign in with your Roblox account.
6. Let Studio finish any update it requests.
7. Open a Baseplate once, wait for it to load, and close Studio.

Opening Studio once creates the user directories that the Rojo plugin installer needs.

Confirm that PowerShell can find the installed Studio executable:

```powershell
$studioRoot = Join-Path $env:LOCALAPPDATA "Roblox\Versions"
$studio = Get-ChildItem -Path $studioRoot -Filter RobloxStudioBeta.exe -File -Recurse |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($null -eq $studio) {
    throw "Roblox Studio was not found. Launch Studio once, close it, and retry."
}

$studio.FullName
$studio.VersionInfo.FileVersion
```

The path usually contains a generated `version-...` directory. Roblox updates can replace that directory, so do not hard-code its full path in personal scripts.

## Step 6 — Install Rokit

Rokit is installed once for your Windows user. It then reads this repository's `rokit.toml` and installs the project's exact versions of Rojo, Wally, StyLua, Selene, and Luau Language Server.

The official automated installer command is:

```powershell
Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 |
    Invoke-Expression
```

This command downloads and executes the official Rokit installation script. If you prefer to inspect installers before execution, download `rokit.exe` from the [official Rokit release page](https://github.com/rojo-rbx/rokit/releases), then run this from the directory containing it:

```powershell
.\rokit.exe self-install
```

After either method:

1. Close all terminal windows.
2. Open a new PowerShell 7 window.
3. Verify Rokit:

```powershell
rokit --version
```

The machine-level Rokit version selected for this project is documented in [`TECHNICAL_DESIGN.md`](TECHNICAL_DESIGN.md). Project tool versions are separately pinned in `rokit.toml` once P1.2 adds it.

## Step 7 — Get the repository

### If you do not have a local clone

Choose a parent directory. The following commands use `Documents\source\github`:

```powershell
$projectParent = Join-Path $env:USERPROFILE "Documents\source\github"
New-Item -ItemType Directory -Force -Path $projectParent | Out-Null
Set-Location -LiteralPath $projectParent
git clone https://github.com/oysteinolsen/IdleDungeonExplorer.git
Set-Location -LiteralPath (Join-Path $projectParent "IdleDungeonExplorer")
```

### If you already have this repository

Change to its directory. For the current developer machine:

```powershell
Set-Location -LiteralPath "C:\Users\oyste\Documents\source\github\IdleDungeonExplorer"
```

### Confirm that you are in the correct place

Run:

```powershell
git status --short --branch
git remote -v
```

The remote should be `https://github.com/oysteinolsen/IdleDungeonExplorer.git`. Git status should name the branch and should not say `not a git repository`.

For a fresh setup after the work has merged, update `main` without creating an automatic merge commit:

```powershell
git switch main
git pull --ff-only
```

Do not run those two commands if you intentionally need an existing feature branch with uncommitted work. Commit, stash, or otherwise account for that work first.

## Step 8 — Open the repository in VS Code

From the repository root, run:

```powershell
code .
```

VS Code may ask whether you trust the folder. Confirm trust only after verifying that the Git remote is the expected repository.

Install the two required editor extensions from PowerShell:

```powershell
code --install-extension JohnnyMorganz.luau-lsp
code --install-extension JohnnyMorganz.stylua
```

Restart VS Code after installation.

The optional **Rojo for VS Code** extension is not required. Its automatic setup currently offers a different tool manager and may create `aftman.toml`. This project uses Rokit, so use `rojo serve` from PowerShell and do not accept prompts that add Aftman or replace the repository's tool configuration.

Once P1.2 adds workspace settings, VS Code should use the Rokit-managed `luau-lsp` and `stylua` executables. Until then, the extensions may use their bundled defaults for editor assistance; the repository validation command remains authoritative.

## Step 9 — Install the project-pinned tools

This step requires the committed `rokit.toml` from P1.2.

From the repository root, confirm the file exists:

```powershell
Test-Path -LiteralPath ".\rokit.toml"
```

If the output is `False`, P1.2 is not on your branch yet. Pull or switch to a branch containing it. Do not run `rokit init` or `rokit add`, because those commands would create or modify the project's reviewed manifest.

If the output is `True`, install the exact tools:

```powershell
rokit install
```

Verify every command:

```powershell
rojo --version
wally --version
stylua --version
selene --version
luau-lsp --version
```

The versions should match `rokit.toml`. If a different global installation appears first, inspect resolution with PowerShell:

```powershell
Get-Command rojo
Get-Command wally
Get-Command stylua
Get-Command selene
Get-Command luau-lsp
```

Do not use `where` or `where.exe` in PowerShell for this repository.

## Step 10 — Install the Rojo Studio plugin

Rojo has two halves: the `rojo` command-line server and a Roblox Studio plugin. They communicate only on your local computer.

1. Close Roblox Studio.
2. From the repository root, run:

```powershell
rojo plugin install
```

3. Open Roblox Studio again.
4. Look for **Rojo** in the Plugins toolbar.

The plugin major version must match Rojo 7. Running `rojo plugin install` again safely updates the plugin when required.

## Step 11 — Restore Luau dependencies

This step requires `wally.toml` and the committed `wally.lock` from P1.2.

Check both:

```powershell
Test-Path -LiteralPath ".\wally.toml"
Test-Path -LiteralPath ".\wally.lock"
```

When both results are `True`, run:

```powershell
wally install
```

Wally 0.3.2 does not provide a `--locked` switch. It uses the committed `wally.lock` during installation. The repository validator adds a stricter guard by hashing the lockfile before and after `wally install` and failing if it changes. This is comparable to restoring NuGet packages from a committed `packages.lock.json` and then verifying that restore did not rewrite it. Generated package directories are local build inputs and should remain Git-ignored.

If Wally reports that the lockfile is outdated or changes it, do not delete or commit the changed lockfile as a local workaround. Pull the latest branch or ask whether a dependency update is intentional.

## Step 12 — Run the complete validation

This step requires `scripts/validate.ps1` from P1.2.

Run from the repository root:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate.ps1
```

The first run can take longer because it downloads tools/packages and starts Roblox Studio for automated tests. Studio may briefly appear and close by itself. Do not interact with that automated Studio window.

The script is expected to:

1. install/verify project tools;
2. restore only locked Wally dependencies;
3. verify StyLua formatting;
4. run Selene linting;
5. generate a Rojo sourcemap;
6. perform strict Luau analysis;
7. build the production place;
8. build the test place as binary `.rbxl` so development-package source is preserved safely;
9. locate the current Roblox Studio installation;
10. run Jest Roblox inside Studio;
11. fail unless the test-success marker appears.

A successful command returns exit code `0` and prints a success summary. If it fails, start with the first reported failing stage rather than later secondary errors.

## Step 13 — Start a live development session

This step requires `default.project.json` from P1.2.

### Terminal 1: start Rojo

From the repository root:

```powershell
rojo serve default.project.json
```

Leave this terminal running. Rojo normally serves on `localhost` port `34872`. Press `Ctrl+C` in that terminal when you want to stop it.

### Create/open a local development place

On the first run, or when you want a clean place generated from files, open a second PowerShell 7 window in the repository and run:

```powershell
New-Item -ItemType Directory -Force -Path ".\build" | Out-Null
rojo build default.project.json --output ".\build\IdleDungeonExplorer.rbxlx"
```

Then open `build\IdleDungeonExplorer.rbxlx` in Roblox Studio. You can double-click the file in File Explorer or use Studio's **File → Open from File**.

### Connect Studio to Rojo

1. In Studio, open the **Plugins** toolbar.
2. Open the **Rojo** plugin.
3. Select the running project/server at `localhost:34872`.
4. Select **Connect**.
5. Watch Studio's Output window for sync errors.

After connection, changes saved under `src/` appear in the mapped DataModel services. Rojo must keep running for live synchronization.

### Playtest

Use Studio's **Test** button or press `F5`. Studio starts separate server and client simulations even for a solo test. Use the client/server selector during the playtest when you need to inspect each side. Stop with `Shift+F5`.

For UI or input work, also use Studio's Device Emulator at a small phone resolution before declaring the change complete.

## Where changes belong

Use this rule to avoid losing work:

| Change | Authoritative location | Editing tool |
|---|---|---|
| Luau scripts and modules | `src/` | VS Code/Codex |
| Automated tests | `tests/` | VS Code/Codex |
| Rojo/tool/package configuration | Repository root files | VS Code/Codex |
| Documentation | `docs/` | VS Code/Codex |
| Validation automation | `scripts/` | VS Code/Codex |
| 3D world, imported models, lighting, attachments | Repository-owned place/model under `place/` | Roblox Studio |
| Generated builds and logs | `build/` | Tools; do not edit or commit |
| Wally-installed packages | Generated package directories | Wally; do not edit or commit |

Do not make lasting script changes only in Studio. Rojo can replace those changes the next time it synchronizes.

For intentional world edits, follow the export workflow established by the current Rojo project mapping. With the planned `Workspace/World` model, select the repository-owned `World` model in Studio Explorer and use **Save to File** to update `place/world.rbxm`. Verify the Git diff/status afterward. Never export unrelated runtime instances, player characters, test debris, or scripts into that model.

## A normal work session

At the start:

```powershell
Set-Location -LiteralPath "C:\Users\oyste\Documents\source\github\IdleDungeonExplorer"
git status --short --branch
git switch main
git pull --ff-only
git switch -c "type/short-description"
rokit install
wally install
```

Use a conventional branch prefix such as `docs/`, `feat/`, `fix/`, or `test/`. Do not switch branches while you have unaccounted-for local changes.

During development:

1. Keep `rojo serve default.project.json` running.
2. Edit source files outside Studio.
3. Add tests in the same change as implementation.
4. Playtest the smallest behavior frequently.
5. Check `git status --short` so generated files do not slip into the change.

Before committing:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate.ps1
git diff --check
git diff
git status --short --branch
```

Review the actual diff; a passing test suite does not prove that every edited file was intended.

Use a Conventional Commits message, for example:

```powershell
git add docs src tests scripts
git commit -m "feat: add mining action registry"
git push -u origin HEAD
```

Adjust the `git add` paths to the exact files that belong to the change. Do not stage unrelated user work.

## Updating an existing environment

When you pull repository changes:

```powershell
git pull --ff-only
rokit install
wally install
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate.ps1
```

`rokit install` follows reviewed pins. Do not run `rokit update` unless a roadmap item intentionally updates `rokit.toml` and validates the result.

Keep Roblox Studio updated when it prompts. Studio is evergreen and is not pinned by the repository. You can update the machine-level applications with:

```powershell
winget upgrade --id Git.Git --exact
winget upgrade --id Microsoft.PowerShell --exact
winget upgrade --id Microsoft.VisualStudioCode --exact
```

After any installation or upgrade that changes `PATH`, close and reopen terminals and VS Code.

## Troubleshooting

### A command is not recognized

Close and reopen PowerShell 7, then inspect the command:

```powershell
Get-Command git
Get-Command pwsh
Get-Command code
Get-Command rokit
```

For project tools, first change to the repository and rerun `rokit install`. If `Get-Command` resolves an unexpected older executable, remove that conflicting installation or correct `PATH`; do not copy random executables into the repository.

### `rokit install` cannot find a manifest

Confirm your location and file:

```powershell
git status --short --branch
Test-Path -LiteralPath ".\rokit.toml"
```

If the file is absent, you are on a revision before P1.2. Pull/switch to the intended branch. Do not generate a replacement manifest.

### Rokit reports GitHub rate limiting

Run:

```powershell
rokit authenticate
```

Follow Rokit's prompts. Never commit the resulting credentials or paste an access token into a tracked file.

### `wally install` says the lockfile is stale or changes it

Make sure you pulled the latest commit. If the manifest changed without a matching lockfile change, stop and report it. Updating package resolution is a reviewed repository change, not a local setup repair.

### The Rojo plugin is missing

1. Launch Studio once and close it.
2. Run `rojo plugin install` again.
3. Reopen Studio.
4. Confirm that the installed CLI is Rojo 7 with `rojo --version`.

### The Rojo plugin cannot connect

Check that the terminal running `rojo serve default.project.json` is still open and has no error. Use the displayed localhost address/port. Reinstall the plugin if its major version differs. If Windows Firewall prompts for local network access, allow the private/local connection for Rojo; Rojo should not need to be exposed publicly.

### Files do not appear in Studio

Check, in order:

1. the correct repository and branch are open;
2. `default.project.json` exists;
3. Rojo started without a project-mapping error;
4. Studio says the plugin is connected;
5. the file is under a mapped directory such as `src/shared`, `src/server`, or `src/client`;
6. Studio Output has no sync error.

### Roblox Studio is not found by validation

Launch Studio manually, allow it to update, then close it. Confirm the executable with:

```powershell
$studioRoot = Join-Path $env:LOCALAPPDATA "Roblox\Versions"
Get-ChildItem -Path $studioRoot -Filter RobloxStudioBeta.exe -File -Recurse |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 5 FullName, LastWriteTime
```

Do not hard-code a generated Roblox version directory; it changes after updates.

### Automated Studio tests hang

Close other Studio windows and retry validation. If a previous Studio test process remains, inspect it before stopping anything:

```powershell
Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue
```

Do not repeatedly start validation while an earlier test run is active. Capture `build/test-output.log` and the first failing validation message when reporting the problem.

### Formatting fails

See which files differ without modifying them:

```powershell
stylua --check src tests
```

Format the tracked Luau source/test trees:

```powershell
stylua src tests
```

Review the resulting diff before committing.

### Type analysis or Selene fails

Read the first error, including its file and line. Fix source rather than disabling a rule globally. If generated packages are being analyzed, confirm that project configuration excludes the generated package directories and that you used the committed test project/sourcemap.

## Safety and project rules

- Never put Roblox cookies, API keys, GitHub tokens, or purchase secrets in the repository.
- Never trust the Roblox client with inventory, currency, rewards, elapsed time, damage, or purchases.
- Do not enable live production DataStore access for ordinary Studio validation.
- Do not delete `wally.lock` or change tool pins to make a local error disappear.
- Do not edit generated packages or generated place files as source.
- Do not add Creator Store models without inspecting their scripts and license.
- Do not start a second roadmap item before the current one is complete.
- Update `docs/CURRENT_STATE.md`, run relevant tests, and review the diff before ending work.

## First-time setup checklist

Machine-level setup:

- [ ] `winget --version` works.
- [ ] `git --version` works and Git name/email are configured.
- [ ] `pwsh --version` reports PowerShell 7.
- [ ] `code --version` works.
- [ ] Roblox Studio launches, updates, and is signed in.
- [ ] `rokit --version` works.
- [ ] VS Code has Luau Language Server and StyLua extensions.

Project setup after P1.2:

- [ ] `rokit.toml`, `wally.toml`, `wally.lock`, and both Rojo project files exist.
- [ ] `rokit install` succeeds.
- [ ] `rojo`, `wally`, `stylua`, `selene`, and `luau-lsp` report pinned versions.
- [ ] `rojo plugin install` completes and Studio shows the Rojo plugin.
- [ ] `wally install` succeeds without changing `wally.lock`.
- [ ] `scripts/validate.ps1` passes.
- [ ] `rojo serve default.project.json` connects to Studio.
- [ ] An F5 playtest starts and stops successfully.

## Glossary

- **CLI:** Command-line interface; a tool you run by typing a command in a terminal.
- **Dependency:** Reusable code this project consumes, such as Jest Roblox.
- **DataModel:** Roblox's tree of services and Instances, visible in Studio Explorer.
- **Luau:** Roblox's programming language, derived from Lua.
- **Manifest:** A tracked configuration file listing tools or dependencies.
- **PATH:** The Windows list of directories searched when you type a command name.
- **Place:** A Roblox world/data file, usually `.rbxl` or `.rbxlx`.
- **Plugin:** An extension that runs inside Roblox Studio; Rojo's plugin receives filesystem changes.
- **Repository:** The Git-tracked project directory and its history.
- **Sourcemap:** Rojo-generated mapping between filesystem files and Roblox DataModel Instances, used for type analysis.
- **Tool pin:** An exact selected tool version stored in project configuration.
- **Workspace:** The Roblox service containing visible 3D world Instances; also sometimes used to mean the folder open in VS Code.

## Official references

- [Roblox Studio installation and requirements](https://create.roblox.com/docs/studio/setup)
- [Roblox Studio testing modes](https://create.roblox.com/docs/studio/testing-modes)
- [Roblox Studio command-line interface](https://create.roblox.com/docs/studio/command-line-interface)
- [Roblox third-party tool workflow](https://create.roblox.com/docs/projects/external-tools)
- [Git for Windows](https://git-scm.com/install/windows.html)
- [PowerShell 7 installation on Windows](https://learn.microsoft.com/powershell/scripting/install/install-powershell-on-windows)
- [VS Code installation on Windows](https://code.visualstudio.com/docs/setup/windows)
- [Rokit installation and usage](https://github.com/rojo-rbx/rokit)
- [Rojo installation and Studio plugin](https://rojo.space/docs/v7/getting-started/installation/)
- [Luau Language Server extension](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp)
- [StyLua extension](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua)
- [Wally package manager](https://github.com/UpliftGames/wally)
- [Jest Roblox](https://github.com/Roblox/jest-roblox)
