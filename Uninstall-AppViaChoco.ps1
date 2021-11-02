#use this script to uninstall an app via chocolatey
#assumes the app is being passed by a dropdown field of common apps in your environment
#also takes a manual input if your desired app isn't in the dropdown
#let Service Delivery Team know to add your desired app to the dropdown if you use it regularly

Import-Module $env:SyncroModule

#using Kabuto Patch Manager since it's chocolatey anyway and already installed with all Syncro deployments
$choco = 'C:\Program Files\RepairTech\Syncro\kabuto_app_manager\kabuto_patch_manager.exe'

if ($dropdownApp) {
    Start-Process $choco -ArgumentList "uninstall $dropdownApp -y" -Wait
    Log-Activity -Message "Uninstalled $dropdownApp via chocolatey" -EventName "Mgmt"
    Write-Host "Uninstalled $dropdownApp on $env:ComputerName"
}

if ($manualApp) {
    Start-Process $choco -ArgumentList "uninstall $manualApp -y" -Wait
    Log-Activity -Message "Uninstalled $manualApp via chocolatey" -EventName "Mgmt"
    Write-Host "Uninstalled $manualApp on $env:ComputerName"
}