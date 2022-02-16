Import-Module $env:SyncroModule

$portalInstaller = 'c:\temp\portal.exe'
$portalExe = "C:\Program Files (x86)\SkyCamp Tech Support Portal\ClientPortal.exe"

if (Test-Path -Path $portalExe) {
    Write-Host "SkyCamp Support Portal already installed; exiting"
    exit
}

if (!($portalInstaller)) {
    Write-Host "Portal isn't here yet; sleep for 60 seconds in case it's still downloading"
    Start-Sleep -Seconds 60
}

try {
    Start-Process -FilePath $portalInstaller -ArgumentList "/silent" -Wait
}
catch {
    Write-Host "Portal Installer not found; exiting"
    exit 1
}

if (Test-Path -Path $portalExe) {
    Write-Host "Installed SkyCamp Support Portal"
    Remove-Item -Path $portalInstaller -Force
    Write-Host "Removed Portal Installer from Temp"
}
else {
    Write-Host "Portal executable not found; exiting"
    exit 1
}

