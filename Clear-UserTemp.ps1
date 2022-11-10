#run as logged in user
Import-Module $env:SyncroModule

Get-ChildItem -Path "$env:LOCALAPPDATA\TEMP" -Include * | Remove-Item -Recurse
Write-Host "Cleared User Temp (Local App Data Temp)"