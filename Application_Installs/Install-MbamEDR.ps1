#built based on request from Syncro FB group: https://www.facebook.com/groups/syncromspusers/posts/1461289441009695/
<#Assumptions:
-$customerGroup is a Custom Customer Field
-$manualGroup is provided at runtime if you wish to override the Customer's Group ID
-installer is .exe and provided as a required file in the syncro script and will be saved under c:\tools; adjust accordingly
#>
Import-Module $env:SyncroModule

#check if a group ID is provided
if (!($customerGroup -or $manualGroup)) {
    Write-Host "No group ID provided; exiting"
    exit 1
}

#if $manualGroup is defined, use that for the Group ID
if ($manualGroup) {
    $installGroup = $manualGroup
}

#check for services - can build this out a little more if needed to check them independently
if ((Get-Service -Name "MBAMService") -and (Get-Service -Name "MBEndpointAgent")) {
    Write-Host "Services already installed; exiting"
    exit
}
else {
    Write-Host "Services not found; proceeding with install"

    #define variables
    $installPath = "c:\tools\mbamEDR.msi"

    $mbamArgs = "/i $installPath /quiet GROUP=$installGroup"

    Write-Host "Installing $installPath with $mbamArgs"

    Start-Process -FilePath "C:\Windows\system32\msiexec.exe" -ArgumentList $mbamArgs -Wait

    Start-Sleep -Seconds 60

    #check if services exist now
    if ((Get-Service -Name "MBAMService") -and (Get-Service -Name "MBEndpointAgent")) {
        Write-Host "MBAM Services detected"
        Log-Activity -Message "MBAM Installed Successfully"

        #remove installer?
        Remove-Item -Path $installPath -Confirm:$false

        exit
    }
    else {
        Write-Host "Services still not found; investigate"
        exit 1
    }

}