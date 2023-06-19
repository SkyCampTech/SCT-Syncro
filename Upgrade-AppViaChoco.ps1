Import-Module $env:SyncroModule

$choco = 'C:\Program Files\RepairTech\Syncro\kabuto_app_manager\kabuto_patch_manager.exe'

if (!(Test-Path $choco)) {
    $choco = "C:\ProgramData\Chocolatey\choco.exe"
    
    if (!(Test-Path $choco)) {

        Write-Host "Chocolatey not installed via Syncro. Installing"
        $command = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        Invoke-Expression -Command $command
    }
    
}

Write-Host "Using chocolatey at $choco"

if ($dropdownApp) {
    Start-Process $choco -ArgumentList "upgrade $dropdownApp -y --limitoutput" -Wait
    Log-Activity -Message "Upgraded $dropdownApp via chocolatey" -EventName "Mgmt"
    Write-Host "Upgraded $dropdownApp on $env:ComputerName"
}

if ($manualApp) {
    Start-Process $choco -ArgumentList "upgrade $manualApp -y" -Wait
    Log-Activity -Message "Upgraded $manualApp via chocolatey" -EventName "Mgmt"
    Write-Host "upgraded $manualApp on $env:ComputerName"
}