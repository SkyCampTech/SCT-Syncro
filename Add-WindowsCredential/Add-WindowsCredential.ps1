Import-Module $env:SyncroModule

if ($username -notcontains "\") {
    Write-Host "Username didn't include server name; adding server so it will work for Azure AD users"
    $username = "$server\$username"
}

Write-Host "Adding credentials for $server for user $username"

Start-Process -filepath "cmdkey.exe" -ArgumentList "/add:$($Server) /user:$($Username) /pass:$($pwd)"