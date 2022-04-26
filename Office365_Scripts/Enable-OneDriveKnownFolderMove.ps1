#adapted for Syncro from https://www.cyberdrain.com/monitoring-with-powershell-monitoring-onedrive-known-folder-move/
#run this as Current User in Syncro. This script does not do impersonation
Import-Module $env:SyncroModule

#check to make sure we are able to pull a tenant ID from the Customer's Custom Fields; must be pre set. We do this by API
if (!($tenantID)) {
    Rmm-Alert -Category "Alert" -Body "No Office 365 Tenant ID set for $companyName"
    exit 1;
}

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"

if (!(Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force
}

New-ItemProperty -Path $regPath -Name "KFMSilentOptIn" -Value $tenantID -Force
New-ItemProperty -Path $regPath -Name "KFMSilentOptInWithNotification" -Value "1" -Force

