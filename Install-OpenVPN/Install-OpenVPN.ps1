#use this script to install OpenVPN, optionally with Config files imported
#make sure to have script upload config files to "c:\programdata\skycamptech\temp"
Import-Module $env:SyncroModule

#see if OpenVPN is already installed
$ovpnPath = "C:\Program Files\OpenVPN\bin\openvpn-gui.exe"

if (!(Test-Path $ovpnPath)) {
    Write-Host "OpenVPN Not Detected; installing via chocolatey"
    $choco = 'C:\Program Files\RepairTech\Syncro\kabuto_app_manager\kabuto_patch_manager.exe'
    Start-Process -FilePath $choco -ArgumentList "install openvpn -y" -Wait
    #Start-Sleep -Seconds 30
}

#import config files if in temp
$tempConfigPath = "$env:ProgramData\SkyCampTech\Temp"
$configPath = "C:\Program Files\OpenVPN\config"

Get-ChildItem -Path $tempConfigPath | Where-Object { $_.Name -match "ovpn" } | Move-Item -Destination $configPath

Write-Host "Imported Config Files"
Get-ChildItem -Path $configPath | Where-Object { $_.Name -match "ovpn" }