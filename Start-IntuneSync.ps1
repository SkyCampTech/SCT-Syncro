#use this script to sync a device with intune
Import-Module $env:SyncroModule

$now = Get-Date -Format 'yyyy-MM-dd HH:mm'

Get-ScheduledTask | Where-Object { $_.TaskName -eq 'PushLaunch' } | Start-ScheduledTask

Log-Activity -Message "Initiated Intune sync via script at $now"