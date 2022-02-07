#attempt to uninstall an application via powershell
Import-Module $env:SyncroModule

$removeApp = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $uninstallProg }

Write-Host "Attempting to uninstall $uninstallProg from based on WMI info:`n $removeApp"

$removeApp.Uninstall()