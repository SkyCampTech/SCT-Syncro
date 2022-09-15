#syncro fields: https://i.imgur.com/P9RhzkL.png

Import-Module $env:SyncroModule

$ip = invoke-restmethod -uri https://ifconfig.me
$url = "https://skycamptech.syncromsp.com/customer_assets/$($AssetId)"
$body = "$Hostname is online. Access the device here: $url. Public IP address: $ip. Reminder Reason: $reason"

Send-Email -To $NotifyUser -Subject "$HostName is Online" -Body $body

$CurrentDate = Get-Date

Log-Activity -Message "Online on $CurrentDate; Public IP address of: $ip"
