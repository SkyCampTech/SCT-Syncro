Import-Module $env:SyncroModule

Import-Module -Name "PowerShellGet"
Install-Module -Name "PSWindowsUpdate" -Force

Start-Sleep -Seconds 30

if (!(Get-InstalledModule -Name "PSWindowsUpdate")) {
    Write-Host "PSWindowsUpdate Not Installed"
    exit 1;
}
else {
    Log-Activity -Message "Installed PSWindowsUpdate Module"
}
