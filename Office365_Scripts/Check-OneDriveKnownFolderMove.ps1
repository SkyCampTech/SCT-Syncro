#adapted for Syncro from here: https://www.cyberdrain.com/monitoring-with-powershell-monitoring-onedrive-known-folder-move/
#make sure to run via Current User in Syncro
Import-Module $env:SyncroModule

#corresponds to "Ignore OneDrive KFM Status asset custom field"
if ($noKFM -eq "yes") {
    Write-Host "Known Folder Move not required on this machine. Exiting"
    exit
}

$Desktop = (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "Desktop").Desktop
$Pictures = (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "My Pictures").'My pictures'
$Documents = (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "Personal").Personal


#this whole check section doesn't appear to be working properly; commmitting for now, but need to revisit this
if ($Desktop -notlike "$($ENV:OneDrive)*") { 
    $KFMDesktop = "Desktop is not set to Onedrive location." 
}
if ($Pictures -notlike "$($ENV:OneDrive)*") { 
    $KFMPictures = "Pictures is not set to Onedrive location." 
}
if ($Documents -notlike "$($ENV:OneDrive)*") { 
    $KFMDocuments = "Documents is not set to Onedrive location." 
}

if ($KFMDesktop -or $KFMPictures -or $KFMDocuments) {
    $rmmBody = @"
Known Folder Move not configured for $env:username.
Desktop: $Desktop
Pictures: $Pictures
Documents: $Documents
"@

    Rmm-Alert -Category "Alert" -Body $rmmBody
}
else {
    Write-Host "Known Folder Move is configured correctly"
}