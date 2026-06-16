## Publish UIFlow Lite — sync free content to public repo.
## Usage: .\tools\publish_uiflow.ps1 [-PushChanges]
[CmdletBinding()]
param(
    [string]$TargetRepoPath = ".worktrees\uiflow-public",
    [string]$TargetRepository = "Zoroiscrying/uiflow",
    [string]$TargetBranch = "main",
    [switch]$PushChanges
)

$ErrorActionPreference = "Stop"

$workspaceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$targetRepoRoot = [System.IO.Path]::GetFullPath((Join-Path $workspaceRoot $TargetRepoPath))

# Files/directories to sync to public repo
$syncEntries = @(
    ".gitattributes",
    ".gitignore",
    ".editorconfig",
    "README.md",
    "LICENSE",
    "icon.svg",
    "icon.svg.import",
    "project.godot",
    "addons/ui_flow",
    "addons/gdUnit4",
    "tests/unit/core",
    "tests/unit/components",
    "docs"
)

$preservedRootNames = @(".git")

function Assert-TargetRepoAvailable {
    if (-not (Test-Path -LiteralPath $targetRepoRoot)) {
        throw "TargetRepoPath does not exist: $targetRepoRoot"
    }
    & git -C $targetRepoRoot rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "TargetRepoPath is not a git repository: $targetRepoRoot"
    }
}

function Assert-TargetRepoClean {
    $status = @(& git -C $targetRepoRoot status --porcelain)
    if ($status.Count -gt 0) {
        throw "Target repository has uncommitted changes: $targetRepoRoot"
    }
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Ensure-ParentDirectory {
    param([string]$Path)
    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory -Path $parent
    }
}

function Write-UIFlowProjectFile {
    param([string]$Path)
    Ensure-ParentDirectory -Path $Path
    $content = @'
; Engine configuration file.
config_version=5

[application]
config/name="Godot-Plugin-UI-Flow"
run/main_scene="res://addons/ui_flow/examples/main.tscn"
config/features=PackedStringArray("4.6", "GL Compatibility")
config/icon="res://icon.svg"

[autoload]
UIFlow="*res://addons/ui_flow/core/ui_flow_autoload.tscn"
UIFlowUI="*res://addons/ui_flow/core/ui_flow_ui_autoload.tscn"

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="viewport"

[dotnet]
project/assembly_name="Godot-Plugin-UI-Flow"

[editor_plugins]
enabled=PackedStringArray("res://addons/ui_flow/plugin.cfg")

[physics]
3d/physics_engine="Jolt Physics"

[rendering]
rendering_device/driver.windows="d3d12"
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
'@
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $content + [Environment]::NewLine, $encoding)
}

function Copy-WorkspaceEntry {
    param([string]$RelativePath)
    
    if ($RelativePath -eq "project.godot") {
        Write-UIFlowProjectFile -Path (Join-Path $targetRepoRoot $RelativePath)
        return
    }
    
    $sourcePath = Join-Path $workspaceRoot $RelativePath
    $targetPath = Join-Path $targetRepoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        Write-Host "Warning: Workspace path not found, skipping: $RelativePath"
        return
    }
    
    Ensure-ParentDirectory -Path $targetPath
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Recurse -Force
}

function Reset-TargetRepoContent {
    Get-ChildItem -LiteralPath $targetRepoRoot -Force | ForEach-Object {
        if ($preservedRootNames -contains $_.Name) {
            return
        }
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }
}

function Sync-TargetRepo {
    Reset-TargetRepoContent
    foreach ($entry in $syncEntries) {
        Write-Host "Syncing: $entry"
        Copy-WorkspaceEntry -RelativePath $entry
    }
}

function Push-TargetChanges {
    & git -C $targetRepoRoot config user.name "uiflow-sync-bot"
    & git -C $targetRepoRoot config user.email "uiflow-sync-bot@users.noreply.github.com"
    & git -C $targetRepoRoot add -A
    
    & git -C $targetRepoRoot diff --cached --quiet
    $hasChanges = $LASTEXITCODE -ne 0
    
    if (-not $hasChanges) {
        Write-Host "No changes to push."
        return
    }
    
    & git -C $targetRepoRoot commit -m "chore(sync): mirror UIFlow from workspace"
    if ($PushChanges) {
        & git -C $targetRepoRoot push origin $TargetBranch
        Write-Host "Pushed to $TargetRepository/$TargetBranch"
    } else {
        Write-Host "Changes committed. Use -PushChanges to push to remote."
    }
}

# Main
Assert-TargetRepoAvailable
Assert-TargetRepoClean
Sync-TargetRepo
Push-TargetChanges
Write-Host "UIFlow Lite sync complete."
