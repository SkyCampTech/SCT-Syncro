Import-Module $env:SyncroModule

if ($pcManufacturer -notmatch "dell*") {
    Write-Host "$env:ComputerName is not a Dell; exiting"
    exit
}

function Get-dcuPath {
    #get dcu-cli patch
    $x64Path = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
    $x86Path = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"

    if (Test-Path $x64Path) {
        Write-Host "dcu-cli at $x64Path"
        $dcuPath = $x64Path
    }
    elseif (Test-Path $x86Path) {
        Write-Host "dcu-cli at $x86Path"
        $dcuPath = $x86Path
    }
    else {
        Write-Host "dcu-cli.exe not found; exiting"
        exit 1
    }
    
    return $dcuPath
}

function Set-dcuSettings {
    param (
        [string]$dcuPath,
        [string]$settingName,
        [string]$settingValue
    )

    $process = Start-Process -FilePath $dcuPath -ArgumentList "/configure -$($settingName)=$($settingValue)" -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -eq 0) {
        Write-Host "Updated $settingName to $settingValue"
    }
    else {
        Write-host "Failed to update $settingName. Exit Code: $($process.ExitCode)"
        exit 1
    }
    
}

function Update-DellCommandUpdate {
    #try to upgrade via chocolatey
    $choco = 'C:\Program Files\RepairTech\Syncro\kabuto_app_manager\kabuto_patch_manager.exe'
    
    $results = Invoke-Expression -Command "choco list dellcommandupdate --local-only -r --idonly"

    if ($NULL -eq $results) {
        Write-Host "Dell Command Update not installed via Chocolatey; download latest from Dell"
        $dcuInstaller = "$env:ProgramData\SkyCampTech\temp\dcuinstaller.exe"
        Start-BitsTransfer -Source "https://dl.dell.com/FOLDER09523714M/1/Dell-Command-Update-Windows-Universal-Application_6GMR6_WIN_4.8.0_A00.EXE" -Destination $dcuInstaller
        Start-Process -FilePath $dcuInstaller -ArgumentList "/s" -NoNewWindow -PassThru -Wait
        Remove-Item $dcuInstaller
    }
    else {
        Write-Host "Dell Command Update noinstalled via Chocolatey; upgrading"
        Start-Process -FilePath $choco -ArgumentList "upgrade dellcommandupdate -y" -NoNewWindow -PassThru -Wait
    }
}


$dcuPath = Get-dcuPath

Update-DellCommandUpdate

if ($setNotifications) {
    Set-dcuSettings -dcuPath $dcuPath -settingName "updatesNotification" -settingValue $setNotifications
}

