Import-Module $env:SyncroModule

if (!($newHelloStatus)) {
    Rmm-Alert -Category "Maintenance" -Body "No Status Selected for Windows Hello change on $env:ComputerName"
    exit 1;
}

if ($newHelloStatus -contains "enabled") {
    $helloValue = 1
}
elseif ($newHelloStatus -contains "disabled") {
    $helloValue = 0
}
else {
    Rmm-Alert -Category "Maintenance" -Body "No Status Selected for Windows Hello change on $env:ComputerName"
    exit 1;
}

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions" -Name "value" -Value $helloValue -Force

Log-Activity -Message "Set Windoww Hello Status: $newHelloStatus"