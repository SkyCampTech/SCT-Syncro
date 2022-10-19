#settings taken from here: https://support-splashtopbusiness.splashtop.com/hc/en-us/articles/360030993692-What-are-the-Windows-Streamer-registry-settings-
Import-Module $env:SyncroModule

$regPath = "HKLM:\SOFTWARE\WOW6432Node\Splashtop Inc.\Splashtop Remote Server"


<#
Values
0 = Output sound both over the remote connection and on the local computer (Windows streamer only)
1 = Output sound over the remote connection only.
2 = Output sound on the local computer only.
#>
Write-Host "Setting Splashtop Audio to Local Only"
New-ItemProperty -Path $regPath -Name "Automute" -PropertyType DWORD -Value 2 -Force

Write-Host "Restarting Splashtop Streaming Service"
Restart-Service -Name "SplashtopRemoteService" -Force