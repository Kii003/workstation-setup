# Run one digest track headlessly and file the result in the knowledge-base inbox.
#   .\run.ps1 mechanics      (track B)
#   .\run.ps1 news           (track A)
#   .\run.ps1                (both)
# Needs: Claude Code signed in (run `claude` once interactively). Read-only web tools only.
param([ValidateSet("mechanics", "news", "all")][string]$Track = "all")
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
if ($env:Path -notlike "*$HOME\.local\bin*") { $env:Path = "$HOME\.local\bin;$env:Path" }

$Inbox = Resolve-Path (Join-Path $PSScriptRoot "../../../00_Knowledge-Base/01-inbox") -ErrorAction SilentlyContinue
if (-not $Inbox) { throw "knowledge-base inbox not found" }
$Today = Get-Date -Format "yyyy-MM-dd"
$State = Join-Path $PSScriptRoot "state"
$Log   = Join-Path (Join-Path $PSScriptRoot "docs") "log.md"
New-Item -ItemType Directory -Force -Path $State | Out-Null

function Invoke-Track($t) {
  $out = Join-Path $Inbox.Path "$Today-digest-$t.md"
  if (Test-Path $out) { Write-Host "exists, skipping: $out"; return }
  $prev = Get-ChildItem $Inbox -Filter "*-digest-$t.md" | Sort-Object Name | Select-Object -Last 1
  $prevPath = if ($prev) { $prev.FullName } else { "none" }
  $prompt = ([IO.File]::ReadAllText((Join-Path (Join-Path $PSScriptRoot "prompts") "$t.md"))).Replace("{{DATE}}", $Today) + "`n`nToday is $Today. Previous digest: $prevPath."
  $result = & claude -p $prompt --allowedTools "WebSearch,WebFetch,Read" --output-format text 2> (Join-Path $State "last-error-$t.log")
  if ($LASTEXITCODE -ne 0) { Write-Host "[x] ${t}: claude failed - see state\last-error-$t.log" -ForegroundColor Red; return }
  $text = ($result -join "`n")
  # keep only the file content: drop anything the model wrote before the frontmatter
  $m = [regex]::Match($text, "(?m)^---\s*$")
  if ($m.Success) { $text = $text.Substring($m.Index) }
  if ($text -notmatch "(?m)^# ") { [IO.File]::WriteAllText((Join-Path $State "last-bad-output-$t.md"), $text); Write-Host "[x] ${t}: output had no digest heading - see state\" -ForegroundColor Red; return }
  [IO.File]::WriteAllText($out, $text)
  Add-Content $Log "## [$Today] digest | $t track`nFiled $(Split-Path $out -Leaf)`n"
  Write-Host "[ok] $out" -ForegroundColor Green
}

if ($Track -eq "all") { Invoke-Track "mechanics"; Invoke-Track "news" } else { Invoke-Track $Track }
