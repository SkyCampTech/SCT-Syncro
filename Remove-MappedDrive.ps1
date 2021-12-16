<#
-use this script to dismount a mapped drive
-script must run as Current User
-takes drive letter as input
-alternatively, can dismount all drives 
#>

Import-Module $env:SyncroModule

$drive = $drive.ToUpper() + ":"

$currentUser = $env:USERDOMAIN + "\" + $env:USERNAME
#$currentDrives = Get-PSDrive | Where-Object { $_.Provider -match "FileSystem" -and $_.Name -ne "C" }

if ($removeAllDrives -match "yes") {
    Write-Host "Removing all mapped drives for $currentUser"
    net use * /delete /y
    Log-Activity -Message "Removed all mapped drives for $currentUser"
}
else {
    Write-Host "Removing Drive $drive for $currentUser"
    Remove-SmbMapping -LocalPath $drive -Force
    Log-Activity -Message "Removed Drive $drive for $currentUser"
}