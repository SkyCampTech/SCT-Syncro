Import-Module $env:SyncroModule

$extensionList = @{
    "Windows 10 Account"                    = "ppnbnpeolgkicgegkbkbjmhlideopiji"
    "Microsoft Defender Browser Protection" = "bkbeeeffjjeopflfhgeknacdieedcoml"
}
if ($manualExtensionId) {
    $extension = $manualExtensionId
}
else {
    $extension = $extensionList[$extensionName]
}

Write-Host "Forcing Extension $extension"

if (!($extension)) {
    Write-Host "Extension not found in list and no manual extension ID specified; exiting"
    exit 1;
}
else {
    $string = (Get-Item -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist").Property[-1]
    [int]$value = [convert]::ToInt32($string) + 1
    Write-Host "Adding Extension ($extension) to ExtensionInstallForceList in registry with value $value"
    reg add HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForceList /v $value /t REG_SZ /d $extension /f
}


