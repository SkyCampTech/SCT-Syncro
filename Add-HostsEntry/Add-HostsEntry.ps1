Import-Module $env:SyncroModule

if (($hostname -eq "") -or ($ipAddress -eq "")) {
    Write-Host "Empty values supplied; exiting"
    exit 1
}

Write-Host "Adding $hostname with $ipAddress to Hosts file"

$hostsPath = "C:\windows\system32\drivers\etc\hosts"
$today = Get-Date -Format "yyyy-MM-dd"

$hostsUpdate = @"
`r`n#added via Syncro script on $today
$ipAddress $hostname
"@

Add-Content -Path $hostsPath -Value $hostsUpdate

$hostsContent = Get-Content -Path $hostsPath

if ($hostsContent -match "$ipAddress $hostname") {
    Log-Activity -Message "Updated Hosts File: $ipAddress $hostname"
    Write-Host "Updated Hosts file successfully"
}
else {
    Write-Host "Failed to update Hosts file successfully"
    exit 1
}