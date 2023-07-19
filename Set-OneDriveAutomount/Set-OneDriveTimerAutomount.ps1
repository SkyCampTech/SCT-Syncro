#adapted from here: https://call4cloud.nl/2020/07/once-upon-a-time-in-the-automount-of-onedrive-team-sites/
#needs to run as Current User
Import-Module $env:SyncroModule

$regPath = "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"
$regName = "Timerautomount"
$regType = "QWORD"
$regValue = 1

try {
    $currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop | Select-Object -ExpandProperty $regName
    if ($currentValue -eq $regValue) {
        Write-Host "Timer Automount set to 0"
        exit 0
    }
    else {
        Write-Host "Timer Automount not set to 0; updating"
        Set-ItemProperty -Path $regPath -Name $regName -Type $regType -Value $regValue

        $currentValue = Get-ItemProperty -Path $regPath -Name $regName | Select-Object -ExpandProperty $regName
        if ($currentValue -eq $regValue) {
            Write-Host "Timer Automount now set to 0"
            exit 0
        }
        else {
            Write-Host "Timer Automount not set properly"
            exit 1
        }
    }
}
catch {
    Write-Host "Timer Automount not set to 0; updating"
    Set-ItemProperty -Path $regPath -Name $regName -Type $regType -Value $regValue

    $currentValue = Get-ItemProperty -Path $regPath -Name $regName | Select-Object -ExpandProperty $regName
    if ($currentValue -eq $regValue) {
        Write-Host "Timer Automount now set to 0"
        exit 0
    }
    else {
        Write-Host "Timer Automount not set properly"
        exit 1
    }
}
