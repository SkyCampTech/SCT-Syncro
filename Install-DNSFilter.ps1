#use this script to install DNSFilter
#need the site secret key set as a Customer Custom Field
Import-Module $env:SyncroModule

if (!($siteSecretKey)) {
    Rmm-Alert -Category "DNSFilter" -Body "No DNSFilter Site Secret Key defined for $companyName; Update and re-run the script"
    exit 1
}

if ($ignoreDNSFilter -eq "yes") {
    Write-Host "DNSFilter set to Ignore for this device; exiting"
    exit
}

$dnsFilterInstaller = "C:\ProgramData\SkyCampTech\temp\DNSFilter_Agent_Setup.msi"
$dnsFilterAgent = "C:\Program Files\DNSFilter Agent\DNSFilter Agent.exe"

if (Test-Path $dnsFilterAgent) {
    Write-Host "DNSFilter already installed"
    exit
}
else {
    Write-Host "Installing DNSFilter"
    Invoke-WebRequest -Uri "https://download.dnsfilter.com/User_Agent/Windows/DNSFilter_Agent_Setup.msi" -OutFile $dnsFilterInstaller
    $argList = @"
/qn /i $dnsFilterInstaller NKEY="$siteSecretKey"
"@
    Start-Process "C:\Windows\system32\msiexec.exe" -ArgumentList $argList -Wait
}

Start-Sleep -Seconds 30

if (Test-Path $dnsFilterAgent) {
    Write-Host "DNSFilter Agent installed successfully"
}
else {
    Write-Host "DNSFilter Agent not detected; exiting with Failure"
    exit 1
}

Remove-Item -Path $dnsFilterInstaller -Confirm:$false

#throw an RMM alert that can trigger a notice to user?
if ((Get-Service -Name "DNSFilter Agent").Status -ne "Running") {
    Write-Host "DNSFilter Agent Not Running; create RMM alert to trigger Restart notice"
    Rmm-Alert -Category "Restart" -Body "Restart required. Display alert to user to restart"
}
else {
    Write-Host "DNSFilter Agent installed and running"
    exit
}