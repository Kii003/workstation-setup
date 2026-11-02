# Windows: run the digest every Monday 08:00 via Task Scheduler (catches up if the PC was off).
#   .\install-weekly.ps1            install / update
#   .\install-weekly.ps1 -Remove    uninstall
param([switch]$Remove)
$Name = "workstation-setup ai-digest"
if ($Remove) { Unregister-ScheduledTask -TaskName $Name -Confirm:$false -ErrorAction SilentlyContinue; Write-Host "[ok] removed"; return }

$shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) { (Get-Command pwsh).Source } else { "powershell.exe" }
$action   = New-ScheduledTaskAction -Execute $shell -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\run.ps1`"" -WorkingDirectory $PSScriptRoot
$trigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 8am
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Write-Host "[ok] weekly digest scheduled (Mondays 08:00). Run now once: Start-ScheduledTask -TaskName '$Name'" -ForegroundColor Green
