#use this script to set a particular wifi SSID priority
Import-Module $env:SyncroModule

if (!($ssid)) {
    Write-Host "SSID not specified; exiting"
    exit 1
}

if (!($priority)) {
    $priority = 1
}

$wifiProfiles = Invoke-Expression -Command "netsh wlan show profiles"

if (!($wifiProfiles -match $ssid)) {
    Write-Host "Wifi profile for $ssid doesn't exist yet"
    exit 1
}

Write-Host "Setting SSID $ssid with Priority $priority"

Invoke-Expression -Command "netsh wlan set profileorder name=$ssid interface='Wi-Fi' priority=$priority"

$wifiProfiles = Invoke-Expression -Command "netsh wlan show profiles"

if ($wifiProfiles[$priority + 8] -match $ssid) {
    Write-Host "Applied SSID priority successfully"
}
else {
    Write-Host "SSID $ssid not set to Priority $priority `n"
    Write-Host $wifiProfiles
    exit 1
}