#disables Fast Startup so a shutdown is actually a shutdown
Import-Module $env:SyncroModule

$regPath = "HKLM:\SYstem\CurrentControlSet\Control\Session Manager\Power"
$regName = "HiberbootEnabled"
$currentStatus = (Get-ItemProperty -Path $regPath -Name $regName).HiberbootEnabled

if ($currentStatus -eq "0") {
    Write-Host "Fast Startup already disabled"
    exit 0
}
else {
    Set-ItemProperty -Path $regPath -Name $regName -Value "0"
    $currentStatus = (Get-ItemProperty -Path $regPath -Name $regName).HiberbootEnabled
    if ($currentStatus -eq "0") {
        Log-Activity -Message "Disabled Fast Startup via Script"
        exit 0
    }
    else {
        Write-Host "Unable to disable Fast Startup; investigate"
        Rmm-Alert -Cateogry "Troubleshooting" -Message "Unable to disable Fast Startup on $env:ComputerName"
        exit 1
    }
}