Import-Module $env:SyncroModule

$path = "HKLM:\SOFTWARE\Policies\Google\Chrome\NotificationsBlockedForUrls"


$number = get-item -path $path | Select-Object Property;
$number = $number.Property.Count

Get-ItemProperty -path $path -Name $number
New-ItemProperty -Path $path -Name $number -PropertyType String -Value $link -Force