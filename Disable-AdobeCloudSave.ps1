#use this script when users report that they get a white screen when trying to save a file in Adobe Reader

Import-Module $env:SyncroModule

reg add "HKCU\SOFTWARE\Adobe\Acrobat Reader\DC\AVGeneral" /v 'bToggleCustomSaveExperience' /t REG_DWORD /d 1 /f

Log-Activity -Message "Disabled Adobe Reader Cloud Save" -EventName "Maintenance"