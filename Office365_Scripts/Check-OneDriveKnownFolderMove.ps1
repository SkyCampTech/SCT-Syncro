#adapted for Syncro from here: https://www.cyberdrain.com/monitoring-with-powershell-monitoring-onedrive-known-folder-move/
#make sure to run via Current User in Syncro
Import-Module $env:SyncroModule

$Desktop = (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "Desktop").Desktop
$Pictures = (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "My Pictures").'My pictures'
$Documents = (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "Personal").Personal

if ($Desktop -notlike "$($ENV:OneDrive)*") { 
    $KFMDesktop = "Desktop is not set to Onedrive location." 
}
else {
    $KFMDesktop = "Desktop configured correctly." 
}
if ($Pictures -notlike "$($ENV:OneDrive)*") { 
    $KFMPictures = "Pictures is not set to Onedrive location." 
}
else {
    $KFMPictures = "Pictures configured correctly." 
}
if ($Documents -notlike "$($ENV:OneDrive)*") { 
    $KFMDocuments = "Documents is not set to Onedrive location." 
}
else {
    $KFMDocuments = "Documents configured correctly." 
}

if (($KFMDesktop -or $KFMPictures -or $KFMDocuments) -match "not set") {
    $rmmBody = @"
Known Folder Move not configured for $env:username.
Desktop: $KFMDesktop
Pictures: $KFMPictures
Documents: $KFMDocuments
"@

    Rmm-Alert -Category "Alert" -Body $rmmBody
}
else {
    Write-Host "Known Folder Move is configured correctly"
}