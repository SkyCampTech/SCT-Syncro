#use this script to install an app via chocolatey
#assumes the app is being passed by a dropdown field of common apps in your environment
#also takes a manual input if your desired app isn't in the dropdown
#let Service Delivery Team know to add your desired app to the dropdown if you use it regularly

#need to fix "office365business"

Import-Module $env:SyncroModule

#using kabuto patch manager.exe in the syncro folder in case choco alias doesn't exist yet
$choco = 'C:\Program Files\RepairTech\Syncro\kabuto_app_manager\kabuto_patch_manager.exe'

if (($dropdownApp -eq "office365business") -or ($manualApp -eq "office365business")){
    Write-Host "Office 365 Business isn't working through choco right now"
    exit 1
}

if ($dropdownApp) {
    Start-Process $choco -ArgumentList "install $dropdownApp -y" -Wait
    Log-Activity -Message "Installed $dropdownApp via chocolatey" -EventName "Mgmt"
    Write-Host "installed $dropdownApp on $env:ComputerName"
}

if ($manualApp) {
    Start-Process $choco -ArgumentList "install $manualApp -y" -Wait
    Log-Activity -Message "Installed $manualApp via chocolatey" -EventName "Mgmt"
    Write-Host "installed $manualApp on $env:ComputerName"
}
