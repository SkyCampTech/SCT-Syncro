Import-Module $env:SyncroModule

$folderPath = "C:\Program Files (x86)\Splashtop\Splashtop Remote\Client for RMM"
if ((Test-Path -Path $folderPath) -and (Test-Path -Path ($folderPath + "\clientoobe.exe"))) {
    Write-Host "SplashtopViewer is already installed on device."
}
else {
    $installerPath = "$env:ProgramData\skycamptech\temp\splashtopviewer.exe"
    $splashtopUri = "https://my.splashtop.com/rmm/win"
    Invoke-WebRequest -Uri $splashtopUri -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "prevercheck /s /i hidewindow=1" -Wait

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