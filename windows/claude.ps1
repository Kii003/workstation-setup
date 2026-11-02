# Claude Code on Windows: install the CLI, link shared config + your own skills, install plugins.
# Called by setup.ps1 - or run it alone: .\claude.ps1
param(
  [string]$SharedDir = (Join-Path (Split-Path $PSScriptRoot -Parent) "shared"),
  [string]$BackupDir = "$HOME\.workstation-setup-backup\" + (Get-Date -Format "yyyyMMdd-HHmmss"),
  [switch]$DryRun
)
$Src  = Join-Path $SharedDir "claude"
$Dest = "$HOME\.claude"
if ($env:Path -notlike "*$HOME\.local\bin*") { $env:Path = "$HOME\.local\bin;$env:Path" }

function Ok($t)  { Write-Host "  [ok] $t" -ForegroundColor Green }
function Warn($t){ Write-Host "  [!]  $t" -ForegroundColor Yellow }
function Dry($t) { Write-Host "  [dry-run] $t" -ForegroundColor DarkGray }

function Set-Link($src, $dst) {
  $item = Get-Item $dst -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -and $item.Target -eq $src) { Ok "$dst (already linked)"; return }
  if ($DryRun) { Dry "link $dst -> $src"; return }
  if ($item) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null; Move-Item $dst $BackupDir -Force; Warn "backed up $dst" }
  New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
  $isDir = (Get-Item $src).PSIsContainer
  if ($isDir) { cmd /c mklink /D "`"$dst`"" "`"$src`"" *> $null } else { cmd /c mklink "`"$dst`"" "`"$src`"" *> $null }
  if (Test-Path $dst) { Ok $dst }
  else { Copy-Item $src $dst -Recurse -Force; Warn "$dst copied (enable Developer Mode and re-run to link instead)" }
}

# 1) CLI via the official native installer (npm install is deprecated)
if (Get-Command claude -ErrorAction SilentlyContinue) {
  Ok (claude --version 2>$null | Select-Object -First 1)
} elseif ($DryRun) {
  Dry "irm https://claude.ai/install.ps1 | iex"
} else {
  Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($userPath -notlike "*$HOME\.local\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$HOME\.local\bin;$userPath", "User")
    Ok "added ~\.local\bin to your PATH"
  }
}

# 2) Global config
Set-Link "$Src\CLAUDE.md"     "$Dest\CLAUDE.md"
Set-Link "$Src\settings.json" "$Dest\settings.json"

# 3) Your own skills / agents / commands, linked one by one
foreach ($kind in @("skills", "agents", "commands", "hooks")) {
  if (-not (Test-Path "$Src\$kind")) { continue }
  Get-ChildItem "$Src\$kind" | Where-Object { $_.Name -notin @("README.md", ".gitkeep") } | ForEach-Object {
    Set-Link $_.FullName "$Dest\$kind\$($_.Name)"
  }
}

# 4) Plugins from plugins.txt
Get-Content "$Src\plugins.txt" | ForEach-Object { ($_ -replace "#.*$", "").Trim() } | Where-Object { $_ } | ForEach-Object {
  if ($_ -like "marketplace:*") {
    $repo = $_.Substring(12)
    if ($DryRun) { Dry "claude plugin marketplace add $repo"; return }
    claude plugin marketplace add $repo *> $null
    if ($LASTEXITCODE -eq 0) { Ok "marketplace $repo" } else { Warn "marketplace $repo - inside Claude Code run: /plugin marketplace add $repo" }
  } else {
    if ($DryRun) { Dry "claude plugin install $_"; return }
    claude plugin install $_ *> $null
    if ($LASTEXITCODE -eq 0) { Ok "plugin $_" } else { Warn "$_ not installed automatically - inside Claude Code run: /plugin install $_" }
  }
}
