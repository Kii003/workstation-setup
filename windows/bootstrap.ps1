# =============================================================
# bootstrap.ps1 - one command on a fresh Windows PC
#
# Paste into PowerShell (normal, not "Run as administrator"):
#
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Kii003/workstation-setup/main/windows/bootstrap.ps1))) -Repo https://github.com/<you>/<your-repo>
#
# It installs Git (if missing), clones your repo and runs windows\setup.ps1.
# Without -Repo it clones the public template (useful to try it out).
# =============================================================
param(
  [string]$Repo   = "https://github.com/Kii003/workstation-setup",
  [string]$Dir    = "$HOME\code\workstation-setup",
  [string]$Branch = "main",
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"

function Update-SessionPath {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host "==> workstation-setup bootstrap" -ForegroundColor Cyan

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "winget is missing. Install 'App Installer' from the Microsoft Store, then run this again." -ForegroundColor Red
  Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
  return
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "  installing Git..."
  winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
  Update-SessionPath
}

if (Test-Path "$Dir\.git") {
  Write-Host "  repo exists at $Dir - pulling latest"
  git -C $Dir pull --ff-only
} else {
  Write-Host "  cloning $Repo -> $Dir"
  Write-Host "  (private repo: a GitHub sign-in window may open)" -ForegroundColor DarkGray
  New-Item -ItemType Directory -Force -Path (Split-Path $Dir) | Out-Null
  git clone --branch $Branch $Repo $Dir
}
if (-not (Test-Path "$Dir\windows\setup.ps1")) { throw "Clone failed or repo has no windows\setup.ps1" }

Write-Host ""
Write-Host "  Edit $Dir\windows\config.ps1 first? (Git name/email, modules)" -ForegroundColor Yellow
$answer = Read-Host "  Press Enter to start setup, or type 'edit' to open config in Notepad first"
if ($answer -eq "edit") { Start-Process notepad "$Dir\windows\config.ps1" -Wait }

$psArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "$Dir\windows\setup.ps1")
if ($DryRun) { $psArgs += "-DryRun" }
& powershell.exe @psArgs
