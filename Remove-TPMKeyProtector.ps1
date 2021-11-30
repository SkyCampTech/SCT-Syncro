#use this script to remove the TPM as a key protector
#useful when a user is being fired and you want to prevent the laptop from booting without the recovery key
#this assumes you have the recovery key documented already; this script does not handle backing up the recovery key, so proceed accordingly

Import-Module $env:SyncroModule

#use some type of confirmation mechanism. enter a password here so users have to type something in at runtime
$confPwd = 'EnterSomethingUniqueHere'

if ($enteredConfPwd -match $confPwd) {
    Write-Host "Confirmation matches; removing TPM key protector from $env:COMPUTERNAME"
    $TpmKeyProtector = ((Get-BitLockerVolume -MountPoint C:).KeyProtector | Where-Object { $_.KeyProtectorType -eq "Tpm" }).KeyProtectorId
    Remove-BitLockerKeyProtector -MountPoint C: -KeyProtectorId $TpmKeyProtector
    Restart-Computer -Force
}
else {
    Rmm-Alert -Category "Security" -Body "Incorrect confirmation entered to remove the Bitlocker Key Protector. You entered $enteredConfPwd. Run again and enter $confPwd"
}