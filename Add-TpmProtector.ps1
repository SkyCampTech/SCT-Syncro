#adds a TPM protector to a bitlocker-encrypted machine

Import-Module $env:SyncroModule

Add-BitLockerKeyProtector -MountPoint C: -TpmProtector
Log-Activity -Message "Added TPM Protector" -EventName "SkyCamp-Mgmt"