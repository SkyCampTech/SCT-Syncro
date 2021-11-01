Import-Module $env:SyncroModule

reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PCHC /f /v PreviousUninstall /t REG_DWORD /d 1
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PCHealthCheck /f /v installed /t REG_DWORD /d 1

Log-Activity -Message "Disabled PC Health Check" -EventName "Mgmt"