Import-Module $env:SyncroModule

$securePwd = $pwd | ConvertTo-SecureString -AsPlainText -Force

cmdkey.exe /add:$($Server) /user:$($Username) /pass:$($securePwd)