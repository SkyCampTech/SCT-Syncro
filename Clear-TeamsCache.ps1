#use this script to clear the Teams cache
#it will quit the Teams app, so proceed with caution
Import-Module $env:SyncroModule

Get-Process | Where-Object { $_.ProcessName -match "teams" } | Stop-Process -Confirm:$false

Get-ChildItem -Path "$env:AppData\Microsoft\Teams" -Include * | Remove-Item -Recurse
Write-Host "Cleared Teams Cache"
