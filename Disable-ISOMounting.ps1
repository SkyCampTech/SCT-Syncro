#applying based on https://support.huntress.io/hc/en-us/articles/11477430445587-How-to-disable-ISO-mounting
Import-Module $env:SyncroModule

$isoMountPath = "HKCR:\Windows.IsoFile\shell\mount"
$isoMountReg = "ProgrammaticAccessOnly"

try {
    New-ItemProperty -Path $isoMountPath -Name $isoMountReg -PropertyType String -Value "" -Force -ErrorAction Stop
    Log-Activity -Message "Disabled ISO Mounting"
}
catch {
    Write-Host "error disabling ISO mounting; exiting"
    exit 1
}