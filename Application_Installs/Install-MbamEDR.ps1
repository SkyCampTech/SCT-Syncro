#built based on request from Syncro FB group: https://www.facebook.com/groups/syncromspusers/posts/1461289441009695/
#MBAM documentation: https://service.malwarebytes.com/hc/en-us/articles/4413802291603
<#Assumptions:
-$customerGroup is a Custom Customer Field
-$manualGroup is provided at runtime if you wish to override the Customer's Group ID
-installer is .msi and provided as a required file in the syncro script and will be saved under c:\tools; adjust accordingly
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
try {
    Write-Host "Checking for MBAMService"
    if (Get-Service -Name "MBAMService" -ErrorAction Stop) {
        Write-Host "MBAMService already found; indicates Malwarebytes EDR may already be installed; investigate"
        Rmm-Alert -Category "MBAM EDR" -Body "MBAM EDR Service detected on $env:ComputerName. Not installing"
        exit 1
    }
}
catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
    try {
        Write-Host "Checking for MBEndpointAgent"
        if (Get-Service -Name "MBEndpointAgent" -ErrorAction Stop) {
            Write-Host "MBEndpointAgent already found; indicates there may be a competing Malwarebytes application installed; investigate"
            Rmm-Alert -Category "MBAM EDR" -Body "MBEndpointAgent already found on $envComputerName; indicates there may be a competing Malwarebytes application installed; investigate"
            exit 1
        }
    }
    catch {
        Write-Host "Services not found; proceeding with install"

        #define variables
        $installPath = "c:\tools\mbamEDR.msi"

        $mbamArgs = "/i $installPath /quiet NEBULA_ACCOUNTTOKEN=$installGroup"

        Write-Host "Installing using msiexec with arguments: $mbamArgs"

        Start-Process -FilePath "C:\Windows\system32\msiexec.exe" -ArgumentList $mbamArgs -Wait

        Write-Host "Sleeping for 30 seconds to verify install"
        Start-Sleep -Seconds 30

        try {
            Write-Host "Checking for MBEndpointAgent"
            if (Get-Service -Name "MBEndpointAgent" -ErrorAction Stop) {
                Write-Host "MBEndpointAgent Found; installed successfully"
                Log-Activity -Message "Installed MBAM EDR"
                exit 0
            }
        }
        catch {
            Write-Host "MBAMService not yet found. Let's wait another 60 seconds and check again"
            Start-Sleep -Seconds 60
            if (Get-Service -Name "MBEndpointAgent") {
                Write-Host "MBAMService Found; installed successfully"
                exit 0
            }
            else {
                Write-Host "MBEndpointAgent not found after 90 seconds; install probably failed"
                RMM-Alert -Category "MBAM EDR" -Body "MBEndpointAgent not found after 90 seconds; install probably failed"
                exit 1
            }
        }
    }
}
