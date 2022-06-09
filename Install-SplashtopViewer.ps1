<#
 want to sleep for a bit, 
 check to make sure it got installed,
 add a Logged activity, 
 then delete the installer form temp
 #>
<#
 that is already installed on your computer, so you can look at 
 C:\Program Files (x86)\Splashtop\Splashtop Remote\Client for RMM
 #>
<#
clientoobe.exe
#>

Import-Module $env:SyncroModule

$installerPath = "$env:ProgramData\skycamptech\temp\splashtopviewer.exe"

Start-Process -FilePath $installerPath -ArgumentList "prevercheck /s"