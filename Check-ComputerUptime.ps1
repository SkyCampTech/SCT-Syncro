Import-Module $env:SyncroModule

$DaysUp = (((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).Days).ToString()
$HoursUp = (((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).Hours).ToString()
$MinsUp = (((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).Minutes).ToString()

$TotalUp = $DaysUp + " days " + $HoursUp + " hours " + $MinsUp + " minutes"

Set-Asset-Field -Name "Uptime" -Value $TotalUp

$DaysUp = (((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).Days)

$result = $DaysUp -gt 30
Write-Output $result

Set-Asset-Field -Name "Up 30 Days" -Value $result