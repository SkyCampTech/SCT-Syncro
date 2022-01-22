Import-Module $env:SyncroModule

Import-Module -Name "PSWindowsUpdate"

if ((Get-WURebootStatus).RebootRequired -eq "True") {
    Write-Host "Reboot Required; Exiting and Rebooting"
    Invoke-Command -ScriptBlock { shutdown /r /f /t 15 }
    exit 1;
}

$updates = Get-WindowsUpdate -AcceptAll -Download

#check if updates
if ($updates) {
    Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot
}

#check if reboot required
if ((Get-WURebootStatus).RebootRequired -eq "True") {
    #Set-Asset-Field -Name "Setup Status" -Value "Windows Updates - Rebooting"
    Invoke-Command -ScriptBlock { shutdown /r /f /t 15 }
}
else {
    Write-Host "No updates required"
    #Set-Asset-Field -Name "Setup Status" -Value "Windows Updates - Complete"
    #RMM-Alert -Category "PC Setup" -Body "PC Setup Status - Windows Updates Complete"
    Log-Activity -Message "Windows Updates Complete"
}