<#
-use this script to dismount a mapped drive
-script must run as Current User
-takes drive letter as input
-alternatively, can dismount all drives 
#>

Import-Module $env:SyncroModule

$drive = $drive.ToUpper() + ":"

$currentUser = $env:USERDOMAIN + "\" + $env:USERNAME



if ($removeAllDrives -match "yes") {
    Write-Host "Removing all mapped drives for $currentUser"
    net use * /delete /yes
    Display-Alert "We have removed all your mapped drives. Please reboot your computer to finish this update."
    Log-Activity -Message "Removed all mapped drives for $currentUser"
}
else {
    Write-Host "Removing Drive $drive for $currentUser"
    net use $drive /delete /yes
    Display-Alert "We have removed the mapped drive $drive. Please reboot your computer to finish this update."
    Log-Activity -Message "Removed Drive $drive for $currentUser"
}
