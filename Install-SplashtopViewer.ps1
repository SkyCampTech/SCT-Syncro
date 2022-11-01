Import-Module $env:SyncroModule

function Install-SplashtopViewer {
    Start-Process -FilePath $installerPath -ArgumentList "prevercheck /s /i hidewindow=1" -Wait

    if ((Test-Path -Path $folderPath) -and (Test-Path -Path ($folderPath + "\clientoobe.exe"))) {
        $installedVersion = (Get-Item $viewerExe).VersionInfo.ProductVersion
        Write-Host "SplashtopViewer was installed properly."
        Log-Activity -Message "Installed Splashtop Viewer version $installedVersion"
    }
    else {
        Write-Host "ERROR: SplashtopViewer was NOT installed properly."
        
        remove-Item $installerPath -Force -Confirm:$false
        exit 1
    }
}

$installerPath = "$env:ProgramData\skycamptech\temp\splashtopviewer.exe"
$splashtopUri = "https://my.splashtop.com/rmm/win"
Invoke-WebRequest -Uri $splashtopUri -OutFile $installerPath

$folderPath = "C:\Program Files (x86)\Splashtop\Splashtop Remote\Client for RMM"
$viewerExe = Join-Path -Path $folderPath -ChildPath "clientoobe.exe"

try {
    
    Get-Item $viewerExe -ErrorAction Stop
    Write-Host "Splashtop Viewer already installed; compare versions"
    $installedVersion = (Get-Item $viewerExe).VersionInfo.ProductVersion
    $downloadedVersion = (Get-Item $installerPath).VersionInfo.ProductVersion

    if ($installedVersion -ne $downloadedVersion) {
        Write-Host "Installed Version: $installedVersion"
        Write-Host "Latest Version: $downloadedVersion"
        Write-Host "Installed version is not latest version; update it"
        Install-SplashtopViewer
    }
    else {
        Write-Host "Installed Version matches Current Version"
    }
}
catch {
    Write-Host "Splashtop Viewer not installed; Install it now"
    Install-SplashtopViewer
}

Write-Host "Removing installer"
remove-Item $installerPath -Force -Confirm:$false

