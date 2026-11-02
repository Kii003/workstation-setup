# =============================================================
# Run on a machine that's already set up, to keep the repo current.
# Only changes files inside the repo. Never deletes anything.
#   1. lists winget packages / VS Code extensions not yet in any module
#   2. copies your own (non-linked) Claude skills/agents/commands into shared\claude\
#   3. copies your AutoHotkey script
# Then review, commit and push.
# =============================================================
$WinDir  = Split-Path $PSScriptRoot -Parent
$RepoDir = Split-Path $WinDir -Parent

function Get-Ids($file) { Get-Content $file | ForEach-Object { (($_ -replace "#.*$", "").Trim() -replace "^user:", "").ToLower() } | Where-Object { $_ } }
$known = Get-ChildItem "$WinDir\apps\*.txt" | Where-Object { $_.BaseName -ne "vscode" } | ForEach-Object { Get-Ids $_.FullName }

Write-Host "==> winget packages installed but not in any module" -ForegroundColor Cyan
$tmp = Join-Path $env:TEMP "winget-export.json"
winget export -o $tmp --accept-source-agreements *> $null
if (Test-Path $tmp) {
  $ids = (Get-Content $tmp -Raw | ConvertFrom-Json).Sources | ForEach-Object { $_.Packages } | ForEach-Object { $_.PackageIdentifier }
  $new = $ids | Where-Object { $known -notcontains $_.ToLower() } | Sort-Object -Unique
  if ($new) { $new | ForEach-Object { "   $_" }; "   -> copy the ones you want into a module in windows\apps\" } else { "   [ok] nothing new" }
  Remove-Item $tmp
}

Write-Host "==> VS Code extensions not in vscode.txt" -ForegroundColor Cyan
if (Get-Command code -ErrorAction SilentlyContinue) {
  $knownExt = Get-Ids "$WinDir\apps\vscode.txt"
  $newExt = code --list-extensions | Where-Object { $knownExt -notcontains $_.ToLower() }
  if ($newExt) { $newExt | ForEach-Object { "   $_" } } else { "   [ok] nothing new" }
}

Write-Host "==> Your own Claude skills / agents / commands" -ForegroundColor Cyan
foreach ($kind in @("skills", "agents", "commands")) {
  if (-not (Test-Path "$HOME\.claude\$kind")) { continue }
  Get-ChildItem "$HOME\.claude\$kind" -Force | Where-Object { -not $_.LinkType } | ForEach-Object {
    $target = "$RepoDir\shared\claude\$kind\$($_.Name)"
    if (Test-Path $target) { "   [!] $kind\$($_.Name) already in repo - not overwritten" }
    else { New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null; Copy-Item $_.FullName $target -Recurse; "   + $kind\$($_.Name)" }
  }
}

Write-Host "==> AutoHotkey" -ForegroundColor Cyan
$ahk = Join-Path ([Environment]::GetFolderPath("Startup")) "main.ahk"
$item = Get-Item $ahk -ErrorAction SilentlyContinue
if ($item -and -not $item.LinkType) { Copy-Item $ahk "$WinDir\autohotkey\main.ahk"; "   + autohotkey\main.ahk" } else { "   [ok] already linked or not present" }

""
"==> Manual: PowerToys -> Settings -> General -> Backup -> copy the backup into windows\powertoys\"
""
git -C $RepoDir status --short
