#adapted for Syncro from https://www.cyberdrain.com/monitoring-with-powershell-monitoring-onedrive-known-folder-move/
#run this as System in Syncro. This script is setting the HKLM settings
Import-Module $env:SyncroModule

#corresponds to "Ignore OneDrive KFM Status asset custom field"
if ($noKFM -eq "yes") {
    Write-Host "Known Folder Move not required on this machine. Exiting"
    exit
}

#check to make sure we are able to pull a tenant ID from the Customer's Custom Fields; must be pre set. We do this by API
if (!($tenantID)) {
    Write-Host "No Office 365 TEnant ID set for $companyName"
    Rmm-Alert -Category "Alert" -Body "No Office 365 Tenant ID set for $companyName"
    exit 1;
}

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"

if (!(Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force
}

Write-Host "Enabling Known Folder Move on $env:ComputerName with Tenant ID: $tenantID for $companyName"

New-ItemProperty -Path $regPath -Name "KFMSilentOptIn" -Value $tenantID -Force
New-ItemProperty -Path $regPath -Name "KFMSilentOptInWithNotification" -Value "1" -Force