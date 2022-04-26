Import-Module $env:SyncroModule

$tempPath = "$env:ProgramData\SkyCampTech\temp"
$installerPath = Join-Path -Path $tempPath -ChildPath "nextiva.msi"
$nextivaPath = "$env:LOCALAPPDATA\Programs\Nextiva, Inc\Nextiva App"

#install Nextiva
Write-Host "Beginning Install"
Start-Process -FilePath "C:\windows\system32\msiexec.exe" -ArgumentList "/log $tempPath\nextiva.txt /i $installerPath /qn NOSTART=1 MSIINSTALLPERUSER=1 INSTALLDIR=%localappdata%\Programs\NextivaInc\NextivaApp\"

Write-Host "Starting Sleep"
Start-Sleep -Seconds 30

#check if Nextiva is installed
if (Test-Path -Path $nextivaPath) {
    Write-Host "Nextiva Desktop Installed"
    Log-Activity -Message "Installed Nextiva Desktop App"
    exit 0
}
else {
    Write-Host "Nextiva Desktop could not be found"
    exit 1
}