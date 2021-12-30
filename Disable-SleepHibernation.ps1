Import-Module $env:SyncroModule

Start-Process 'c:\windows\system32\powercfg.exe' -ArgumentList "/x standby-timeout-ac 0"
Start-Process 'c:\windows\system32\powercfg.exe' -ArgumentList "/x hibernate-timeout-ac 0"

Log-Activity -Message "Disabled Auto Sleep and Hibernation" -EventName "SkyCamp-Mgmt"