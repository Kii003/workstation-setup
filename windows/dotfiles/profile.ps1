# =============================================================
# PowerShell profile - linked from workstation-setup\windows\dotfiles\profile.ps1
# Used by PowerShell 7 and Windows PowerShell 5.1.
# Machine-specific or private stuff goes in ~\.config\workstation-setup\local.ps1
# =============================================================

$cfg = "$HOME\.config\workstation-setup"
if (Test-Path "$cfg\env.ps1") { . "$cfg\env.ps1" }
if (-not $env:PROJECTS_ROOT) { $env:PROJECTS_ROOT = "$HOME\code" }
if ($env:Path -notlike "*$HOME\.local\bin*") { $env:Path = "$HOME\.local\bin;$env:Path" }   # Claude Code

function Test-Cmd($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# --- Editing & history (PSReadLine) --------------------------
if (Get-Module -ListAvailable PSReadLine) {
  Set-PSReadLineOption -EditMode Windows -HistoryNoDuplicates -MaximumHistoryCount 100000
  try { Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView } catch {}   # autosuggestions (PS 7)
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
  Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# --- Tools (each line is skipped if the tool isn't installed) -
if (Test-Cmd mise)     { mise activate pwsh | Out-String | Invoke-Expression }
if (Test-Cmd zoxide)   { zoxide init powershell | Out-String | Invoke-Expression }
if (Test-Cmd starship) { Invoke-Expression (& starship init powershell) }
if ((Test-Cmd fzf) -and (Get-Module -ListAvailable PSFzf)) {
  Import-Module PSFzf
  Set-PsFzfOption -PSReadlineChordReverseHistory "Ctrl+r" -PSReadlineChordProvider "Ctrl+t"
}
if (Test-Cmd code) { $env:EDITOR = "code --wait" }

# --- Aliases -------------------------------------------------
if (Test-Cmd eza) {
  Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
  function ls { eza --group-directories-first @args }
  function ll { eza -la --git --group-directories-first @args }
  function lt { eza --tree --level=2 --git-ignore @args }
}
function reload { . $PROFILE }
function p  { Set-Location $env:PROJECTS_ROOT }          # jump to your projects folder
function dl { Set-Location "$HOME\Downloads" }
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source }

# git
function g   { git @args }
function gs  { git status -sb @args }
function gl  { git log --oneline --graph --decorate -20 @args }
function gp  { git push @args }
function gpl { git pull --rebase @args }
function gco { git checkout @args }
function gcm { git commit -m @args }

# Claude Code
function c  { claude @args }
function cc { claude --continue @args }      # continue last session
function cr { claude --resume @args }        # pick a session

# dev
function ports { Get-NetTCPConnection -State Listen | Sort-Object LocalPort | Select-Object LocalAddress, LocalPort, OwningProcess, @{n="Process";e={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} }

# --- Functions -----------------------------------------------
function mkcd($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null; Set-Location $dir }

# Generate .env from a 1Password template:  envgen [template] [output]
function envgen($tpl = ".env.tpl", $out = ".env") {
  if (-not (Test-Path $tpl)) { Write-Host "No $tpl in this folder"; return }
  op inject -i $tpl -o $out
  if ($LASTEXITCODE -eq 0) { Write-Host "[ok] $out generated from 1Password" -ForegroundColor Green }
}

# Pull new apps/skills/extensions from this machine back into the setup repo
function setup-snapshot { & "$env:WORKSTATION_SETUP_DIR\windows\scripts\snapshot.ps1" }

# --- Local overrides -----------------------------------------
if (Test-Path "$cfg\local.ps1") { . "$cfg\local.ps1" }
