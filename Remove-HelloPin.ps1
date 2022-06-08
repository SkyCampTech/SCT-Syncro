Import-Module $env:SyncroModule

$pinLocation = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\NGC"

takeown /f $pinLocation /r /d y
icacls $pinLocation /grant administrators:F /t

$childItems = Get-ChildItem $pinLocation

Write-Host "Pins before removal: $childItems"

Remove-Item $pinLocation\* -Force -Recurse -Confirm:$false
$childItems = Get-ChildItem $pinLocation

Write-Host "Pins after removal: $childItems"