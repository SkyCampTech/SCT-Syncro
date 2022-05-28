Import-Module $env:SyncroModule

$tempPath = "C:\ProgramData\SkyCampTech\temp"
$installerPath = Join-Path $tempPath -ChildPath "FortiClientVPN.exe"
$fortiClientPath = "C:\Program Files\Fortinet\FortiClient\FortiClient.exe"

Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart" -Wait

if (!(Test-Path $fortiClientPath)) {
    Write-Host "FortiClient Not installed; Removing installer from temp and exiting"
    Remove-Item -Path $installerPath -Force
    exit 1
}
else {
    #check FortiClient version number
    $fortiClientVersion = (Get-ItemProperty -Path $fortiClientPath | Select-Object -ExpandProperty VersionInfo).FileVersion
    Write-Host "Installed FortiClient Version: $fortiClientVersion"
}

#remove the installer
Remove-Item -Path $installerPath -Force