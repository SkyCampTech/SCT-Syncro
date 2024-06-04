#use this script to update Dell drivers on a computer
Import-Module $env:SyncroModule

$dcu = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
$choco = 'C:\Program Files\RepairTech\Syncro\kabuto_app_manager\kabuto_patch_manager.exe'
[string]$today = Get-Date -Format "yyyy-MM-dd"

function Install-DellCommmandUpdate {
    Start-Process $choco -ArgumentList "install dellcommandupdate -y" -Wait
}


function Get-DellCommandUpdate {
    if (!(Test-Path $dcu)) {
        Write-Host "Dell Command Update not installed; attempting install"
        Install-DellCommmandUpdate
        if (!(Test-Path $dcu)) {
            Write-Host "Dell Command Update still not found; exiting"
            Exit 1
        }
        else {
            Write-Host "Dell Command Update found; check for DCU updates"
            Start-Process $choco -ArgumentList "update dellcommandupdate -y" -Wait
        }
 
    }
}

function Get-DellDrivers {
    Write-Host "Getting Dell Drivers"
    Start-Process $dcu -ArgumentList "/scan -outputLog=c:\temp\dcuScan_$today.log" -Wait
    Move-Item -Path "c:\temp\dcuScan_$today.log" -Destination "C:\ProgramData\SkyCampTech\logs\dcuScan_$today.log" -Force
}

function Install-DellDrivers {
    if ($rebootPC -match "yes") {
        Write-Host "Installing drivers and forcing reboot"
        Start-Process $dcu -ArgumentList "/applyUpdates -reboot=enable -forceUpdate=enable -outputLog=c:\Temp\dcuInstall_$today.log" -Wait
    }
    else {
        Write-Host "Installing drivers with no reboot"
        Start-Process $dcu -ArgumentList "/applyUpdates -reboot=disable -forceUpdate=disable -outputLog=C:\Temp\dcuInstall_$today.log" -Wait
    }
    Write-Host "Logs will be written to C:\ProgramData\SkyCampTech\Logs\"
    Move-Item -Path "C:\Temp\dcuInstall_$today.log" -Destination "C:\ProgramData\SkyCampTech\logs\dcuInstall_$today.log" -Force
}

#don't run on non-Dell computers
if ($pcMake -notmatch "dell") {
    Write-Host "$env:ComputerName is not a Dell. The manufacturer is $pcMake. Exiting"
    exit 1
}
else {
    Write-Host "Computer is a Dell; check to see if DCU is installed"
    Get-DellCommandUpdate

    Write-Host "Checking for Dell Driver Updates; logs will be written to C:\ProgramData\SkyCampTech\Logs\"
    Get-DellDrivers
    Install-DellDrivers
}

