#use this script to test ping against an input IP or hostname
Import-Module $env:SyncroModule

#check if IP/Hostname was passed
if (!($ipHostname)) {
    Write-Host "No IP or Hostname passed; exiting"
    exit 1
}

#do a basic ping test
$result = Test-NetConnection -ComputerName $ipHostname -InformationLevel "Detailed"

if ($result.PingSucceeded -eq $false) {
    Write-Host "Ping from $env:ComputerName to $ipHostname failed with PingSucceeded: $($result.PingSucceeded)"
    Rmm-Alert -Category "Connectivity" -Body "Ping from $env:ComputerName to $ipHostname failed with PingSucceeded: $($result.PingSucceeded)"
    exit 1
}
else {
    Write-Host "Ping to $ipHostname succeeded with a time of $($result.PingReplyDetails.RoundtripTime) ms"
}