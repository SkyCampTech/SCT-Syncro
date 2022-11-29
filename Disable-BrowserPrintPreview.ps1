#use this script to disable print preview for Chrome and Edge so it defaults to the System Dialog
Import-Module $env:SyncroModule

function Disable-BrowserPrintPreview {
    param(
        [string]
        $regPath,
        [string]
        $regName
    )
    try {
        New-Item -Path $regPath -Force -ErrorAction Stop
        Write-Host "created $regPath"
    }
    catch {
        Write-Host "Unable to create $regPath"
        Write-Warning $error[0]
    }

    try {
        New-ItemProperty -Path $regPath -Name $regName -PropertyType DWORD -Value 1 -Force -ErrorAction Stop
        Write-Host "created $regName under $regPath"
        Log-Activity -Message "Disabled Browser Print Dialog for $browser"
    }
    catch {
        Write-Host "Unable to create $regName under $regPath"
        Write-Warning $error[0]
    }

}


if ($browser -match "edge") {
    Write-Host "Disabling Print Preview Dialog on Edge"
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    $regName = "UseSystemPrintDialog"
    Disable-BrowserPrintPreview -regPath $regPath -regName $regName
}
elseif ($browser -match "chrome") {
    Write-Host "Disabling Print Preview Dialog on Chrome"
    $regPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
    $regName = "DisablePrintPreview"
    Disable-BrowserPrintPreview -regPath $regPath -regName $regName
}
else {
    Write-Host "Disabling Print Preview Dialog on Chrome and Edge"
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    $regName = "UseSystemPrintDialog"
    Disable-BrowserPrintPreview -regPath $regPath -regName $regName

    $regPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
    $regName = "DisablePrintPreview"
    Disable-BrowserPrintPreview -regPath $regPath -regName $regName

}