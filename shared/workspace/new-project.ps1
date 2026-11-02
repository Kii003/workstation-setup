# Create a project from _templates\project\ and register it in the router.
#
#   .\new-project.ps1 <container> <name> ["one-line description"]
#   .\new-project.ps1 20_Private/80_Labs weather-bot "Telegram bot for rain alerts"
#
# Never overwrites: refuses if the project folder already exists.
param(
  [Parameter(Mandatory = $true)][string]$Container,
  [Parameter(Mandatory = $true)][string]$Name,
  [string]$Description = "<what it is>"
)
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$Container = $Container.TrimEnd("/", "\") -replace "\\", "/"

if ($Name -notmatch "^[a-z0-9][a-z0-9-]*$") { throw "Name must be lowercase-with-dashes (like the GitHub repo): $Name" }
if (-not (Test-Path (Join-Path $Root $Container))) { throw "Container not found: $Root\$Container" }
$dest = Join-Path (Join-Path $Root $Container) $Name
if (Test-Path $dest) { throw "Already exists, not touching it: $dest" }

Copy-Item (Join-Path $Root "_templates\project") $dest -Recurse
$today = Get-Date -Format "yyyy-MM-dd"
Get-ChildItem $dest -Recurse -File -Filter *.md | ForEach-Object {
  $t = [IO.File]::ReadAllText($_.FullName).Replace("{{PROJECT}}", $Name).Replace("{{DATE}}", $today)
  [IO.File]::WriteAllText($_.FullName, $t)
}
git -C $dest init -q
git -C $dest add -A
git -C $dest -c commit.gpgsign=false commit -q -m "Initial project scaffold"

# Register in the router, just above "## Conventions"
$router = Join-Path $Root "CLAUDE.md"
if (Test-Path $router) {
  $lines = [IO.File]::ReadAllLines($router)
  $i = [Array]::IndexOf($lines, "## Conventions")
  if ($i -ge 0) {
    if ($i -gt 0 -and $lines[$i - 1] -eq "") { $i-- }   # before the blank line, so entries stay one block
    $entry = "- ``$Container/$Name`` - $Description (local git only)"
    $new = @($lines[0..($i - 1)]) + $entry + @($lines[$i..($lines.Length - 1)])
    [IO.File]::WriteAllLines($router, $new)
  }
}

Write-Host "[ok] $dest" -ForegroundColor Green
Write-Host "  registered in CLAUDE.md (router) - edit the description there if needed"
Write-Host "  next: cd `"$dest`"; claude"
Write-Host "        then fill in CLAUDE.md; with Matt Pocock's skills run /setup-matt-pocock-skills once"
