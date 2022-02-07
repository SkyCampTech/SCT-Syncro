#must run as current user
Import-Module $env:SyncroModule


[int]$timeoutSecs = [convert]::ToInt32($timeoutMins, 10) * 60

$regPath = "HKEY_CURRENT_USER\Control Panel\Desktop"
$timeoutName = "ScreenSaveTimeOut"
$timeoutValue = $timeoutSecs

#enable the screensaver
reg add $regPath /v 'ScreenSaveActive' /t REG_SZ /d 1 /f
#force Logon on resume
reg add $regPath /v 'ScreenSaverIsSecure' /t REG_SZ /d 1 /f
#set SCRNSAVE.EXE
reg add $regPath /v 'SCRNSAVE.EXE' /t REG_SZ /d 'C:\Windows\system32\scrnsave.scr' /f
#set timeout
reg add $regPath /v $timeoutName /t REG_SZ /d $timeoutValue /f