#use this script to change whether a user is able to log into a computer
#helpful for locking a user out on termination if you don't want to wipe the computer to remove the TPM key protector
Import-Module $env:SyncroModule

$ntrightsPath = "$env:ProgramData\SkyCampTech\bin\ntrights.exe"

Write-Host "Setting $username to $loginStatus"

switch ($loginStatus) {
    "Enabled" { Start-Process -FilePath $ntrightsPath -ArgumentList "-u $username -r SeDenyInteractiveLogonRight"; Log-Activity -Message "Set $username Login to Enabled" }
    "Disabled" { Start-Process -FilePath $ntrightsPath -ArgumentList "-u $username +r SeDenyInteractiveLogonRight"; Log-Activity -Message "Set $username Login to Disabled" }
}

switch ($reboot) {
    "yes" { shutdown /r /f /t 0 }
    "no" { break }
}