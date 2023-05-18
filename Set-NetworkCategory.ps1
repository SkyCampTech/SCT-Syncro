#use this script to set a network connection profile to a specific category (Public, Private, DomainAuthenticated)
Import-Module $env:SyncroModule

if ($netProfileName) {
    Set-NetConnectionProfile -Name $netProfileName -NetworkCategory $netCategory
    
    if ((Get-NetConnectionProfile -Name $netProfileName).NetworkCategory -eq $netCategory) {
        Write-Host "Successfully changed $netProfileName to $netCategory"
        exit
    }
    else {
        Write-Host "Unable to change $netProfileName"
        exit 1
    }
}
else {
    $netProfiles = Get-NetConnectionProfile

    if ($netProfiles.Count -eq 1) {
        Set-NetConnectionProfile -Name $netProfiles.Name -NetworkCategory $netCategory
        if ((Get-NetConnectionProfile -name $netProfiles.Name).NetworkCategory -eq $netCategory) {
            Write-Host "Successfully changed $netProfileName to $netCategory"
            exit
        }
        else {
            Write-Host "Unable to change $netProfileName"
            exit 1
        }
    }
    else {
        Write-Host "Multiple Net Profiles. Rerun script with Desired netProfileName `n"
        foreach ($id in $netProfiles) {
            Write-Host "Name: " $id.Name
            Write-Host "Alias: " $id.InterfaceAlias
            Write-Host "Category: " $id.NetworkCategory
            Write-Host "`n"
        }
        exit 1
    }
}