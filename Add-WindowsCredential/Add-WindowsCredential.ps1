Import-Module $env:SyncroModule

$securePwd = $pwd | ConvertTo-SecureString -AsPlainText -Force

Start-Process -filepath "cmdkey.exe" -ArgumentList "/add:$($Server) /user:$($Username) /pass:$($securePwd)"