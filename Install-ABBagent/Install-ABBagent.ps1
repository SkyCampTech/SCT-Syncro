#use this script to install the Synology Active Backup for Business agent
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

$abbArgs = @"
install synology-activebackup-for-business-agent -y --params="'/Address:$serverAddress /Username:$username /Password:$password /RemoveShortcut'"
"@

Write-Host "Installing Active Backup for Business Agent with these parameters"
Write-Host "Server Address: $serverAddress"
Write-Host "Username: $username"
Write-Host "Password: $password"

Start-Process -FilePath $choco -ArgumentList $abbArgs -Wait