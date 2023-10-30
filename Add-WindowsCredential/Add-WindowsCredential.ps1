Import-Module $env:SyncroModule

if ($removeExisting -eq "yes") {
    Write-Host "Removing existing entry for $server"
    Start-Process -FilePath "cmdkey.exe" -ArgumentList "/delete:$($server)"
}

if ($username -notcontains "\") {
    Write-Host "Username didn't include server name; adding server so it will work for Azure AD users"
    $username = "$server\$username"
}

Write-Host "Adding credentials for $server for user $username"

Start-Process -filepath "cmdkey.exe" -ArgumentList "/add:$($Server) /user:$($Username) /pass:$($pwd)"