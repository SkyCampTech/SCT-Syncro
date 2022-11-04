#use this script to unlock bitlocker on an external drive
#can be part of a remediation when Veeam backups fail because the drive is locked (after a reboot)
#this script doesn't work as-is because you're an idiot and you can't pull the recovery key of a locked volume
#committing to come back to later, but need the key to be an asset custom field, or pull from Hudu

$dataDrive = (Get-BitLockerVolume | Where-Object { $_.VolumeType -eq "Data" }).MountPoint

$dataKey = (Get-BitLockerVolume -MountPoint $dataDrive).KeyProtector.RecoveryPassword

Unlock-BitLocker -MountPoint $dataDrive -RecoveryPassword $dataKey

if ((Get-BitLockerVolume -MountPoint $dataDrive | Select-Object -ExpandProperty LockStatus) -eq "Unlocked") {
    Write-Host "Unlcoked Bitlcocker on $dataDrive"
    Log-Activity -Message "Unlocked Bitlocker on $dataDrive"
}
else {
    Rmm-Alert -Category "Alert" -Body "Unable to automatically unlock Bitlocker on $dataDrive."
    exit 1
}