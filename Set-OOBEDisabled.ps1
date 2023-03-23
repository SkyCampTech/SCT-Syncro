#use this script to disable OOBE on startup
Import-Module $env:SyncroModule

$setupPath = "HKLM:\SYSTEM\Setup"
$systemPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"


Set-ItemProperty -Path $setupPath -Name "CmdLine" -Value ""
Set-ItemProperty -Path $setupPath -Name "RespecializeCmd" -Value ""
Set-ItemProperty -Path $setupPath -Name "OOBEInProgress" -Value 0
Set-ItemProperty -Path $setupPath -Name "SetupPhase" -Value 0
Set-ItemProperty -Path $setupPath -Name "SetupType" -Value 0
Set-ItemProperty -Path $systemPath -Name "EnableCursorSupression" -Value 0

Log-Activity -Message "Disabled OOBE and rebooting"

Start-Process -FilePath "C:\windows\system32\shutdown.exe" -ArgumentList '/r /f /t 30 /c "This machine will reboot in 30 seconds and will bypass OOBE"'