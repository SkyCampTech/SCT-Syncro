#applied based on: https://support.huntress.io/hc/en-us/articles/11378138145555
Import-Module $env:SyncroModule

$adminSharePath = "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters"

if (((Get-WMIObject win32_operatingsystem).Name) -match "Server") {
    Write-Host "Server OS Detected"
    $adminShareReg = "AutoShareServer"
}
else {
    Write-Host "Non-Server OS Detected"
    $adminShareReg = "AutoShareWks"
}

try {
    New-ItemProperty -Path $adminSharePath -Name $adminShareReg -PropertyType DWORD -Value 0 -Force -ErrorAction Stop
    Log-Activity -Message "Disabled Admin Share Access; reboot required"
}
catch {
    Write-Host "Unable to update Admin Share Registry Entry"
    exit 1
}