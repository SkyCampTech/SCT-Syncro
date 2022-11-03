Import-Module $env:SyncroModule

try {
    Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $Username } | Remove-CimInstance -ErrorAction Stop

    Log-Activity -Message "Removed $username profile" -EventName "SkyCamp Maintenance"
}
catch {
    Write-Host "Unable to remove profile for $username"
    exit 1
}