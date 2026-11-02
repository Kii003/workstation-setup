# =============================================================
# Windows workstation setup
#
#   .\setup.ps1                        run everything
#   .\setup.ps1 -Steps apps,claude     run only these steps
#   .\setup.ps1 -Steps check           verify every winget ID in your modules exists
#   .\setup.ps1 -DryRun                show what would happen, change nothing
#
# Run from a NORMAL PowerShell window. It asks for admin rights once
# (one UAC prompt) for the parts that need it.
# Idempotent: safe to run as often as you like.
# Never deletes anything: files replaced by links are moved to
# ~\.workstation-setup-backup\<timestamp>\
# Compatible with Windows PowerShell 5.1 (what a fresh PC has).
# =============================================================
param(
  [string[]]$Steps,
  [switch]$DryRun,
  [switch]$Help,
  [switch]$Elevated     # internal: set when the script re-launches itself as admin
)

$WinDir    = $PSScriptRoot
$RepoDir   = Split-Path $WinDir -Parent
$SharedDir = Join-Path $RepoDir "shared"
. "$WinDir\config.ps1"
if (Test-Path "$WinDir\config.local.ps1") { . "$WinDir\config.local.ps1" }

$Stamp     = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupDir = "$HOME\.workstation-setup-backup\$Stamp"
$AdminLog  = "$env:TEMP\workstation-setup-admin.log"
$AdminFail = "$env:TEMP\workstation-setup-admin.failed"
$script:Failed = @()
$AllSteps = @("preflight", "admin", "apps", "vscode", "runtimes", "folders", "workspace", "dotfiles", "terminal", "claude", "tweaks", "summary")

# --- Helpers -------------------------------------------------
function Step($t) { Write-Host ""; Write-Host "==> $t" -ForegroundColor Cyan }
function Ok($t)   { Write-Host "  [ok] $t" -ForegroundColor Green }
function Warn($t) { Write-Host "  [!]  $t" -ForegroundColor Yellow }
function Fail($t) { Write-Host "  [x]  $t" -ForegroundColor Red; $script:Failed += $t }
function Dry($t)  { Write-Host "  [dry-run] $t" -ForegroundColor DarkGray }
function Has($c)  { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Update-SessionPath {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
  $local = "$HOME\.local\bin"
  if ($env:Path -notlike "*$local*") { $env:Path = "$local;$env:Path" }
}

# Read a module file -> list of @{ Id; User } (comments and blank lines ignored)
function Get-ModuleEntries($file) {
  Get-Content $file | ForEach-Object {
    $line = ($_ -replace "#.*$", "").Trim()
    if ($line) {
      $user = $line.StartsWith("user:")
      [pscustomobject]@{ Id = ($line -replace "^user:", "").Trim(); User = $user }
    }
  }
}

function Install-WingetPackage($id) {
  winget list --id $id --exact --accept-source-agreements *> $null
  if ($LASTEXITCODE -eq 0) { Ok "$id (installed)"; return }
  if ($DryRun) { Dry "winget install $id"; return }
  winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
  if ($LASTEXITCODE -eq 0) { Ok $id } else { Fail "winget: $id (exit $LASTEXITCODE)" }
}

# Link target -> source. Uses a symlink (works without admin once Developer Mode is on),
# falls back to copying. An existing real file is moved to the backup folder, never deleted.
function Set-Link($src, $dst) {
  $item = Get-Item $dst -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq "SymbolicLink" -and $item.Target -eq $src) { Ok "$dst (already linked)"; return }
  if ($DryRun) { Dry "link $dst -> $src"; return }
  if ($item) {
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    Move-Item $dst $BackupDir -Force
    Warn "backed up $dst -> $BackupDir"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
  cmd /c mklink "`"$dst`"" "`"$src`"" *> $null
  if (Test-Path $dst) { Ok "$dst -> $src" }
  else { Copy-Item $src $dst -Force; Warn "$dst copied (symlink not allowed - enable Developer Mode and re-run to link)" }
}

function Write-TextFile($path, $content) {
  if ($DryRun) { Dry "write $path"; return }
  New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
  [IO.File]::WriteAllText($path, $content)    # UTF-8 without BOM (git dislikes a BOM)
}

function Get-Modules { $AppModules | Where-Object { $_ -ne "vscode" } }

# --- Steps ---------------------------------------------------
function Do-Preflight {
  Step "Preflight"
  if ($env:OS -ne "Windows_NT") { Write-Host "This script is for Windows."; exit 1 }
  Ok ("Windows " + [Environment]::OSVersion.Version + ", PowerShell " + $PSVersionTable.PSVersion)
  if (-not (Has winget)) { Fail "winget missing - install 'App Installer' from the Microsoft Store"; exit 1 }
  if ($GitEmail -eq "you@example.com") { Warn "config.ps1 still has the example Git identity - edit it (or config.local.ps1)" }
  if ($DryRun) { Warn "DRY RUN - nothing will be changed" }
  if (Test-Admin) { Warn "running as admin: apps marked 'user:' can't be installed - re-run '.\setup.ps1 -Steps apps' from a normal window afterwards" }
  if (-not $DryRun) { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force -ErrorAction SilentlyContinue }
}

# Everything that needs admin, in one elevated run (one UAC prompt)
function Do-Admin {
  if (-not $Elevated -and -not (Test-Admin)) {
    Step "Admin tasks (one UAC prompt)"
    if ($DryRun) { Dry "re-launch elevated: Developer Mode, long paths, machine-wide apps"; Invoke-AdminTasks; return }
    Remove-Item $AdminFail -ErrorAction SilentlyContinue
    $a = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated -Steps admin"
    try { Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList $a }
    catch { Fail "admin step cancelled (UAC declined)"; return }
    if (Test-Path $AdminLog) { Get-Content $AdminLog | Where-Object { $_ -match "\[(ok|!|x)\]" } | ForEach-Object { Write-Host $_ } }
    if (Test-Path $AdminFail) { Get-Content $AdminFail | ForEach-Object { $script:Failed += $_ } }
    Update-SessionPath
    return
  }
  Start-Transcript -Path $AdminLog -Force | Out-Null
  Step "Admin tasks"
  Invoke-AdminTasks
  Stop-Transcript | Out-Null
  if ($Elevated -and $script:Failed.Count) { Set-Content $AdminFail $script:Failed }
}

function Invoke-AdminTasks {
  # Developer Mode: lets the setup create symlinks without admin
  $k = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
  if ($DryRun) { Dry "enable Developer Mode" } else {
    New-Item -Path $k -Force | Out-Null
    Set-ItemProperty -Path $k -Name AllowDevelopmentWithoutDevLicense -Value 1 -Type DWord
    Ok "Developer Mode on"
  }
  # Long paths: node_modules and deep repos otherwise break
  if ($DryRun) { Dry "enable long paths" } else {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled -Value 1 -Type DWord
    Ok "long paths on"
  }
  if ($AppModules -contains "containers") {
    if ($DryRun) { Dry "wsl --install --no-distribution" }
    else { wsl --install --no-distribution | Out-Null; Ok "WSL2 enabled (reboot needed before Docker works)" }
  }
  # Machine-wide apps
  if (-not $DryRun) { winget source update *> $null }
  foreach ($m in Get-Modules) {
    $f = "$WinDir\apps\$m.txt"
    if (-not (Test-Path $f)) { Fail "module '$m' not found"; continue }
    Write-Host "  -- $m --" -ForegroundColor Cyan
    foreach ($e in Get-ModuleEntries $f) {
      if (-not $e.User) { Install-WingetPackage $e.Id }
    }
  }
}

function Do-Apps {
  Step "Apps for your user account"
  $any = $false
  foreach ($m in Get-Modules) {
    $f = "$WinDir\apps\$m.txt"
    if (-not (Test-Path $f)) { continue }
    foreach ($e in Get-ModuleEntries $f) {
      if ($e.User) {
        $any = $true
        if (Test-Admin) { Warn "$($e.Id) skipped (needs a non-admin window)" } else { Install-WingetPackage $e.Id }
      }
    }
  }
  if (-not $any) { Ok "none" }
  Update-SessionPath
}

function Do-Vscode {
  if ($AppModules -notcontains "vscode") { return }
  Step "VS Code extensions"
  Update-SessionPath
  if (-not (Has code)) { Fail "VS Code CLI 'code' not found - is Microsoft.VisualStudioCode in the dev module?"; return }
  $installed = (code --list-extensions) | ForEach-Object { $_.ToLower() }
  foreach ($e in Get-ModuleEntries "$WinDir\apps\vscode.txt") {
    if ($installed -contains $e.Id.ToLower()) { Ok "$($e.Id) (installed)"; continue }
    if ($DryRun) { Dry "code --install-extension $($e.Id)"; continue }
    code --install-extension $e.Id *> $null
    if ($LASTEXITCODE -eq 0) { Ok $e.Id } else { Fail "vscode extension $($e.Id)" }
  }
}

function Do-Runtimes {
  Step "Runtimes via mise"
  if (-not $MiseGlobals.Count) { Ok "skipped"; return }
  Update-SessionPath
  if (-not (Has mise)) { Fail "mise not found (core module)"; return }
  if ($DryRun) { Dry ("mise use -g " + ($MiseGlobals -join " ")); return }
  mise use -g @MiseGlobals
  if ($LASTEXITCODE -eq 0) { Ok ($MiseGlobals -join ", ") } else { Fail "mise runtimes" }
}

function Do-Folders {
  Step "Folders"
  if (-not $ExtraDirs.Count) { Ok "no extra folders"; return }
  foreach ($d in $ExtraDirs) {
    if ($DryRun) { Dry "mkdir $d" } else { New-Item -ItemType Directory -Force -Path $d | Out-Null; Ok $d }
  }
}

function Do-Workspace {
  if (-not $InstallWorkspace) { return }
  Step "Claude workspace -> $WorkspaceRoot"
  $src = Join-Path $SharedDir "workspace"
  $added = 0; $kept = 0
  Get-ChildItem $src -Recurse -File -Force | ForEach-Object {
    $rel = $_.FullName.Substring($src.Length).TrimStart("\", "/")
    $dst = Join-Path $WorkspaceRoot $rel
    if (Test-Path $dst) { $kept++; return }
    if ($DryRun) { $added++; return }
    New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
    Copy-Item $_.FullName $dst
    $added++
  }
  if ($DryRun) { Dry "copy $added files into $WorkspaceRoot" }
  Ok "$added files added, $kept already there (kept as they are)"
}

function Do-Dotfiles {
  if (-not $LinkDotfiles) { return }
  Step "Dotfiles"
  $docs = [Environment]::GetFolderPath("MyDocuments")    # follows OneDrive redirection
  $profileSrc = "$WinDir\dotfiles\profile.ps1"
  Set-Link $profileSrc "$docs\PowerShell\Microsoft.PowerShell_profile.ps1"          # PowerShell 7
  Set-Link $profileSrc "$docs\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"   # Windows PowerShell 5.1
  Set-Link "$WinDir\dotfiles\gitconfig"             "$HOME\.gitconfig"
  Set-Link "$SharedDir\dotfiles\gitignore_global"   "$HOME\.gitignore_global"
  Set-Link "$SharedDir\dotfiles\starship.toml"      "$HOME\.config\starship.toml"
  if (Test-Path "$WinDir\autohotkey\main.ahk") {
    $startup = [Environment]::GetFolderPath("Startup")
    Set-Link "$WinDir\autohotkey\main.ahk" "$startup\main.ahk"
  }

  # Machine-specific values: generated, never committed
  $gl = "# generated by workstation-setup - edit config.ps1 and re-run .\setup.ps1 -Steps dotfiles`n[user]`n`tname = $GitName`n`temail = $GitEmail`n"
  if ($GitAltEmail) {
    $altDir = ($GitAltDir.TrimEnd("\") -replace "\\", "/") + "/"
    $gl += "[includeIf `"gitdir/i:$altDir`"]`n`tpath = ~/.gitconfig-alt`n"
    Write-TextFile "$HOME\.gitconfig-alt" "[user]`n`temail = $GitAltEmail`n"
    Ok "Git: $GitEmail (default), $GitAltEmail inside $GitAltDir"
  } else { Ok "Git: $GitEmail" }
  Write-TextFile "$HOME\.gitconfig.local" $gl

  Write-TextFile "$HOME\.config\workstation-setup\env.ps1" "# generated by workstation-setup`n`$env:WORKSTATION_SETUP_DIR = `"$RepoDir`"`n`$env:WORKSPACE_ROOT = `"$WorkspaceRoot`"`n"
  if (-not (Test-Path "$HOME\.config\workstation-setup\local.ps1")) {
    Write-TextFile "$HOME\.config\workstation-setup\local.ps1" "# machine-specific PowerShell config, not in the repo`n"
  }

  # Ctrl+R fuzzy history in PowerShell
  Update-SessionPath
  if (Has pwsh) {
    if ($DryRun) { Dry "Install-Module PSFzf (PowerShell 7)" }
    else {
      pwsh -NoProfile -Command "if (-not (Get-Module -ListAvailable PSFzf)) { Install-Module PSFzf -Scope CurrentUser -Force -AcceptLicense -ErrorAction Stop }" *> $null
      if ($LASTEXITCODE -eq 0) { Ok "PSFzf module" } else { Warn "PSFzf not installed - run in pwsh: Install-Module PSFzf -Scope CurrentUser" }
    }
  }
}

function Do-Terminal {
  if (-not $ConfigureTerminal) { return }
  Step "Windows Terminal"
  $dir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
  $file = "$dir\settings.json"
  $pwsh7 = "{574e775e-4f2a-5b96-ac1e-a2962a402336}"
  if ($DryRun) { Dry "default profile PowerShell 7, font JetBrainsMono Nerd Font"; return }
  if (-not (Test-Path $file)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $json = '{ "$schema": "https://aka.ms/terminal-profiles-schema", "defaultProfile": "' + $pwsh7 + '", "profiles": { "defaults": { "font": { "face": "JetBrainsMono Nerd Font" } }, "list": [] } }'
    [IO.File]::WriteAllText($file, $json)
    Ok "settings created"
    return
  }
  Update-SessionPath
  if (-not (Has pwsh)) { Warn "PowerShell 7 not found - set the default profile in Terminal settings manually"; return }
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
  Copy-Item $file "$BackupDir\terminal-settings.json"
  $cmd = @"
`$f = '$file'
`$s = Get-Content `$f -Raw | ConvertFrom-Json
`$s | Add-Member -NotePropertyName defaultProfile -NotePropertyValue '$pwsh7' -Force
if (-not `$s.profiles.defaults) { `$s.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) -Force }
`$s.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{ face = 'JetBrainsMono Nerd Font' }) -Force
`$s | ConvertTo-Json -Depth 20 | Set-Content `$f -Encoding UTF8
"@
  pwsh -NoProfile -Command $cmd
  if ($LASTEXITCODE -eq 0) { Ok "PowerShell 7 default, Nerd Font (backup in $BackupDir)" } else { Fail "Windows Terminal settings" }
}

function Do-Claude {
  if (-not $InstallClaudeCode) { return }
  Step "Claude Code"
  Update-SessionPath
  & "$WinDir\claude.ps1" -SharedDir $SharedDir -BackupDir $BackupDir -DryRun:$DryRun
  if (-not $?) { Fail "Claude Code setup" }
}

function Do-Tweaks {
  if (-not $ApplyWindowsTweaks) { return }
  Step "Windows settings"
  if ($DryRun) { Dry "run windows\tweaks.ps1"; return }
  & "$WinDir\tweaks.ps1"
}

function Do-Check {
  Step "Checking winget IDs in all modules"
  foreach ($f in Get-ChildItem "$WinDir\apps\*.txt" | Where-Object { $_.BaseName -ne "vscode" }) {
    foreach ($e in Get-ModuleEntries $f.FullName) {
      winget show --id $e.Id --exact --accept-source-agreements *> $null
      if ($LASTEXITCODE -eq 0) { Ok "$($f.BaseName): $($e.Id)" } else { Fail "$($f.BaseName): $($e.Id) not found in winget" }
    }
  }
}

function Do-Summary {
  Step "Done"
  if ($script:Failed.Count) { Write-Host "Failed:" -ForegroundColor Red; $script:Failed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red } }
  else { Ok "all automated steps finished" }
  Write-Host ""
  Write-Host "Next (manual, see windows\README.md -> 'After the script'):" -ForegroundColor Yellow
  Write-Host "  1. Close this window, open Windows Terminal (PowerShell 7 is now the default)"
  Write-Host "  2. Sign in to your password manager; for 1Password CLI: op signin"
  Write-Host "  3. gh auth login"
  Write-Host "  4. claude   -> sign in, then /plugin to check installed plugins"
  Write-Host "  5. In Git Bash: bash ~/.claude/hooks/test-protect-files.sh   -> secret protection works?"
  Write-Host "  6. cd $WorkspaceRoot -> fill in CLAUDE.md (router) and the two world files"
  Write-Host "  7. Sign in to your apps"
  if ($AppModules -contains "containers") { Write-Host "  8. Reboot once so WSL2 / Docker work" }
}

# --- Main ----------------------------------------------------
if ($Help) { Get-Content $PSCommandPath | Select-Object -Skip 1 -First 14 | ForEach-Object { $_ -replace "^# ?", "" }; "Steps: " + ($AllSteps -join ", ") + ", check"; return }

$run = if ($Steps) { $Steps | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim() } } else { $AllSteps }
foreach ($s in $run) {
  if (($AllSteps + "check") -notcontains $s) { Fail "unknown step '$s'"; continue }
  & "Do-$s"
}
