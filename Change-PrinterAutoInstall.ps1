Import-Module $env:SyncroModule

Function Stop-PrinterAutoInstall {

    New-Item "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Force | New-ItemProperty -Name "AutoSetup" -Value 0 -Force | Out-Null

    $PrinterInstall = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup"

    if ($PrinterInstall.AutoSetup -eq 0) {
        Write-Host "Printer AutoSetup Disabled"
    }

    Else { Write-Host "Printer AutoSetup still enabled, please setup manually" }
}


Function Start-PrinterAutoInstall {
    $PrinterInstall = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup"
    if ($PrinterInstall.AutoSetup -ne 1) {
        Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -Value 1
        Write-Host "Printer AutoSetup enabled"
    }
    Else { Write-Host "Printer AutoSetup already Enabled" }
}

if ($printerAutoInstall -contains "enabled") {
    Start-PrinterAutoInstall
}
elseif ($printerAutoInstall -contains "disabled") {
    Stop-PrinterAutoInstall
}
else {
    Write-Host "No Printer Auto Install selection made; exiting"
    exit 1;
}

Log-Activity -Message "Set Printer Auto Install: $printerAutoInstall"