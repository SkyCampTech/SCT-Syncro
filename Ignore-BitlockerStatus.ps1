Import-Module $env:SyncroModule

$ComputerEdition = (Get-ComputerInfo).WindowsProductName
if ($ComputerEdition -contains "home") {
    Write-Host "$env:COMPUTERNAME is a windows home device"
}
else {
    try {
        $status = (Get-BitLockerVolume -MountPoint $env:SystemDrive).ProtectionStatus
        Set-Asset-Field -Name "Bitlocker OS Status" -Value $status
        if ($status -eq "Off") {
            Write-Host "Bitlocker is OFF"
            rmm-alert -Category "BitLocker" -Body "Bitlocker is off on $env:COMPUTERNAME"
            exit;
        }
        else {
            Write-Host "Bitlocker is ON"
        }
    }
    catch {
        Write-Host "[Error] Could not determine Bitlocker status on $env:COMPUTERNAME"
        exit;
    }
}