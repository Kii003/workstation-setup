# Opinionated Windows settings for the current user (no admin needed).
# Every line is commented - delete what you don't want. All reversible in Settings.

function Set-Reg($path, $name, $value, $type = "DWord") {
  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  Set-ItemProperty -Path $path -Name $name -Value $value -Type $type
}
$adv = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# --- Explorer ------------------------------------------------
Set-Reg $adv "HideFileExt" 0                 # show file extensions (.env, .ps1 ...)
Set-Reg $adv "Hidden" 1                      # show hidden files
Set-Reg $adv "LaunchTo" 1                    # Explorer opens "This PC" instead of Home/Quick access
Set-Reg $adv "ShowSyncProviderNotifications" 0   # no OneDrive ads in Explorer

# --- Taskbar -------------------------------------------------
Set-Reg $adv "TaskbarAl" 0                   # Windows 11: align taskbar left
Set-Reg $adv "ShowTaskViewButton" 0          # hide Task View button
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 1   # search as icon, not a box

# --- Start / search ------------------------------------------
Set-Reg "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1   # no web/Bing results in Start search
Set-Reg $adv "Start_TrackDocs" 0             # no "recent files" in Start

# --- Theme ---------------------------------------------------
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" 0     # dark apps
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" 0  # dark taskbar

# --- Keyboard ------------------------------------------------
Set-Reg "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "0" String       # shortest delay before key repeat
Set-Reg "HKCU:\Control Panel\Keyboard" "KeyboardSpeed" "31" String      # fastest key repeat
Set-Reg "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" String   # no Sticky Keys popup on 5x Shift

# --- Clipboard -----------------------------------------------
Set-Reg "HKCU:\Software\Microsoft\Clipboard" "EnableClipboardHistory" 1   # Win+V clipboard history

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue   # restarts automatically
Write-Host "  [ok] Windows settings applied (some need sign-out to take effect)" -ForegroundColor Green
