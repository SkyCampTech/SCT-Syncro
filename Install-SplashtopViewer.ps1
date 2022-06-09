Import-Module $env:SyncroModule

$installerPath = "$env:ProgramData\skycamptech\temp\splashtopviewer.exe"
$folderPath = "C:\Program Files (x86)\Splashtop\Splashtop Remote\Client for RMM"
if ((Test-Path -Path $folderPath) -and (Test-Path -Path ($folderPath + "\clientoobe.exe"))) {
    Write-Host "SplashtopViewer is already installed on device."
}
else {
    Start-Process -FilePath $installerPath -ArgumentList "prevercheck /s" -Wait

    if ((Test-Path -Path $folderPath) -and (Test-Path -Path ($folderPath + "\clientoobe.exe"))) {
        Write-Host "SplashtopViewer was installed properly."
        Log-Activity -Message "Installed Splashtop Viewer"
    }
    else {
        Write-Host "ERROR: SplashtopViewer was NOT installed properly."
        
        remove-Item $installerPath -Force -Confirm:$false
        exit 1
    }
}

remove-Item $installerPath -Force -Confirm:$false