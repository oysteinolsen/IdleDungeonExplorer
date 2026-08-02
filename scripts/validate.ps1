[CmdletBinding()]
param(
    [ValidateRange(30, 900)]
    [int]$StudioTimeoutSeconds = 180
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

$SuccessSentinel = "IDLE_DUNGEON_EXPLORER_TESTS_OK"
$ExpectedVersions = [ordered]@{
    "rojo.exe"     = "Rojo 7.7.0"
    "wally.exe"    = "wally 0.3.2"
    "stylua.exe"   = "stylua 2.5.2"
    "selene.exe"   = "selene 0.31.0"
    "luau-lsp.exe" = "1.69.0"
}

$RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$BuildDirectory = Join-Path $RepositoryRoot "build"
$TestSourcemapPath = Join-Path $BuildDirectory "test-sourcemap.json"
$DefinitionsPath = Join-Path $BuildDirectory "globalTypes.None.d.luau"
$ProductionPlacePath = Join-Path $BuildDirectory "IdleDungeonExplorer.rbxlx"
$TestPlacePath = Join-Path $BuildDirectory "IdleDungeonExplorerTests.rbxl"
$TestOutputPath = Join-Path $BuildDirectory "test-output.log"
$TestRunnerPath = Join-Path $RepositoryRoot "scripts\run-tests.luau"
$LockfilePath = Join-Path $RepositoryRoot "wally.lock"

function Invoke-Stage {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "==> $Name"

    try {
        & $Action
        Write-Host "[PASS] $Name"
    }
    catch {
        Write-Host "[FAIL] $Name"
        Write-Host $_.Exception.Message
        throw
    }
}

function Invoke-NativeCommand {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [switch]$CaptureOutput
    )

    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        throw "Executable not found: $FilePath"
    }

    $displayArguments = $Arguments -join " "
    Write-Host "  > $FilePath $displayArguments"

    $commandOutput = @(& $FilePath @Arguments 2>&1)
    $exitCode = $LASTEXITCODE

    foreach ($line in $commandOutput) {
        Write-Host $line
    }

    if ($exitCode -ne 0) {
        throw "Command exited with code ${exitCode}: $FilePath $displayArguments"
    }

    if ($CaptureOutput) {
        return ($commandOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    }
}

function Resolve-RokitExecutable {
    $rokitCommand = Get-Command rokit -CommandType Application -ErrorAction SilentlyContinue
    if ($null -ne $rokitCommand) {
        return $rokitCommand.Source
    }

    $userRokit = Join-Path ([Environment]::GetFolderPath("UserProfile")) ".rokit\bin\rokit.exe"
    if (Test-Path -LiteralPath $userRokit -PathType Leaf) {
        return $userRokit
    }

    throw "Rokit was not found on PATH or under the current user's .rokit\bin directory."
}

function Resolve-ManagedTool {
    param(
        [Parameter(Mandatory)]
        [string]$ToolName
    )

    $candidate = Join-Path $script:RokitBinDirectory $ToolName
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Rokit did not expose the expected tool: $candidate"
    }

    return $candidate
}

function Assert-ExactVersion {
    param(
        [Parameter(Mandatory)]
        [string]$ToolName,

        [Parameter(Mandatory)]
        [string]$ExpectedVersion
    )

    $toolPath = Resolve-ManagedTool -ToolName $ToolName
    $actualVersion = Invoke-NativeCommand -FilePath $toolPath -Arguments @("--version") -CaptureOutput

    if ($actualVersion.Trim() -ne $ExpectedVersion) {
        throw "Unexpected $ToolName version. Expected '$ExpectedVersion', received '$($actualVersion.Trim())'."
    }
}

function Assert-SourcemapBoundary {
    param(
        [Parameter(Mandatory)]
        [string]$SourcemapPath,

        [Parameter(Mandatory)]
        [bool]$ExpectTestContent
    )

    $sourcemapText = Get-Content -Raw -LiteralPath $SourcemapPath
    $containsTests = $sourcemapText -match '"name"\s*:\s*"Tests"'
    $containsDevPackages = $sourcemapText -match '"name"\s*:\s*"DevPackages"'

    if ($ExpectTestContent -and (-not $containsTests -or -not $containsDevPackages)) {
        throw "Test sourcemap does not contain both Tests and DevPackages."
    }

    if (-not $ExpectTestContent -and ($containsTests -or $containsDevPackages)) {
        throw "Production sourcemap contains test-only content."
    }
}

Set-Location -LiteralPath $RepositoryRoot
New-Item -ItemType Directory -Force -Path $BuildDirectory | Out-Null

$RokitExecutable = Resolve-RokitExecutable
$script:RokitBinDirectory = Split-Path -Parent $RokitExecutable
$env:PATH = "$script:RokitBinDirectory;$env:PATH"

Invoke-Stage -Name "Install and verify pinned tools" -Action {
    # The manifest is reviewed and committed; validation must remain non-interactive.
    Invoke-NativeCommand -FilePath $RokitExecutable -Arguments @("install", "--no-trust-check")

    foreach ($versionEntry in $ExpectedVersions.GetEnumerator()) {
        Assert-ExactVersion -ToolName $versionEntry.Key -ExpectedVersion $versionEntry.Value
    }
}

$WallyExecutable = Resolve-ManagedTool -ToolName "wally.exe"
$StyLuaExecutable = Resolve-ManagedTool -ToolName "stylua.exe"
$SeleneExecutable = Resolve-ManagedTool -ToolName "selene.exe"
$RojoExecutable = Resolve-ManagedTool -ToolName "rojo.exe"
$LuauLspExecutable = Resolve-ManagedTool -ToolName "luau-lsp.exe"

Invoke-Stage -Name "Install locked Wally dependencies" -Action {
    if (-not (Test-Path -LiteralPath $LockfilePath -PathType Leaf)) {
        throw "The committed wally.lock file is missing. Resolve dependencies as a reviewed change before validation."
    }

    $hashBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath $LockfilePath).Hash
    Invoke-NativeCommand -FilePath $WallyExecutable -Arguments @("install")
    $hashAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $LockfilePath).Hash

    if ($hashBefore -ne $hashAfter) {
        throw "wally install changed wally.lock. Restore and review the dependency resolution."
    }
}

Invoke-Stage -Name "Check Luau formatting" -Action {
    Invoke-NativeCommand -FilePath $StyLuaExecutable -Arguments @(
        "--check",
        "src",
        "tests",
        "scripts\run-tests.luau"
    )
}

Invoke-Stage -Name "Lint first-party Luau" -Action {
    Invoke-NativeCommand -FilePath $SeleneExecutable -Arguments @(
        "src",
        "tests",
        "scripts\run-tests.luau"
    )
}

Invoke-Stage -Name "Generate test sourcemap" -Action {
    Invoke-NativeCommand -FilePath $RojoExecutable -Arguments @(
        "sourcemap",
        "test.project.json",
        "--output",
        $TestSourcemapPath
    )

    Assert-SourcemapBoundary -SourcemapPath $TestSourcemapPath -ExpectTestContent $true
}

Invoke-Stage -Name "Analyze strict Luau types" -Action {
    $definitionsUri = "https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau"
    Write-Host "  > Download Roblox definitions from $definitionsUri"
    Invoke-WebRequest -Uri $definitionsUri -OutFile $DefinitionsPath

    if ((Get-Item -LiteralPath $DefinitionsPath).Length -eq 0) {
        throw "The downloaded Roblox definitions file is empty."
    }

    Invoke-NativeCommand -FilePath $LuauLspExecutable -Arguments @(
        "analyze",
        "--platform=roblox",
        "--definitions=@roblox=$DefinitionsPath",
        "--sourcemap=$TestSourcemapPath",
        "--ignore=DevPackages/**",
        "src",
        "tests"
    )
}

Invoke-Stage -Name "Build production place" -Action {
    $productionSourcemapPath = Join-Path $BuildDirectory "production-sourcemap.json"
    Invoke-NativeCommand -FilePath $RojoExecutable -Arguments @(
        "sourcemap",
        "default.project.json",
        "--output",
        $productionSourcemapPath
    )
    Assert-SourcemapBoundary -SourcemapPath $productionSourcemapPath -ExpectTestContent $false

    Invoke-NativeCommand -FilePath $RojoExecutable -Arguments @(
        "build",
        "default.project.json",
        "--output",
        $ProductionPlacePath
    )
}

Invoke-Stage -Name "Build test place" -Action {
    Invoke-NativeCommand -FilePath $RojoExecutable -Arguments @(
        "build",
        "test.project.json",
        "--output",
        $TestPlacePath
    )
}

Invoke-Stage -Name "Run Jest through Roblox Studio CLI" -Action {
    $studioRoot = Join-Path $env:LOCALAPPDATA "Roblox\Versions"
    $studio = Get-ChildItem -Path $studioRoot -Filter "RobloxStudioBeta.exe" -File -Recurse |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $studio) {
        throw "Roblox Studio was not found under $studioRoot."
    }

    Write-Host "  Studio path: $($studio.FullName)"
    Write-Host "  Studio version: $($studio.VersionInfo.ProductVersion)"

    if (Test-Path -LiteralPath $TestOutputPath) {
        Remove-Item -Force -LiteralPath $TestOutputPath
    }

    $processStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $processStartInfo.FileName = $studio.FullName
    $processStartInfo.UseShellExecute = $false

    foreach ($argument in @(
        "--task",
        "RunScript",
        "--localPlaceFile",
        $TestPlacePath,
        "--runScriptFile",
        $TestRunnerPath,
        "--outputFile",
        $TestOutputPath,
        "--quitAfterExecution"
    )) {
        $processStartInfo.ArgumentList.Add($argument)
    }

    $studioProcess = [System.Diagnostics.Process]::Start($processStartInfo)
    if ($null -eq $studioProcess) {
        throw "Failed to start Roblox Studio."
    }

    $finished = $studioProcess.WaitForExit($StudioTimeoutSeconds * 1000)
    if (-not $finished) {
        $studioProcess.Kill($true)
        $studioProcess.WaitForExit()
        throw "Roblox Studio exceeded the ${StudioTimeoutSeconds}-second test timeout."
    }

    if (-not (Test-Path -LiteralPath $TestOutputPath -PathType Leaf)) {
        throw "Roblox Studio did not create the expected test log: $TestOutputPath"
    }

    $testOutput = Get-Content -Raw -LiteralPath $TestOutputPath
    if ($studioProcess.ExitCode -ne 0 -or -not $testOutput.Contains($SuccessSentinel)) {
        Write-Host "--- Roblox Studio test output ---"
        Write-Host $testOutput
        Write-Host "--- End Roblox Studio test output ---"

        if ($studioProcess.ExitCode -ne 0) {
            throw "Roblox Studio exited with code $($studioProcess.ExitCode)."
        }

        throw "Roblox Studio output did not contain the success sentinel '$SuccessSentinel'."
    }

    Write-Host $testOutput
}

Write-Host ""
Write-Host "Validation completed successfully."
