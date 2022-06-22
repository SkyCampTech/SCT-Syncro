#installs the Foxit PDF Editor (version 11)
#msi switches: https://kb.foxitsoftware.com/hc/en-us/articles/360040660271--Command-line-Deployments-of-Foxit-PDF-Editor
Import-Module $env:SyncroModule

$downloadURL = "https://f001.backblazeb2.com/file/SCT-INSTALLERS/Foxit11.msi"
$tempPath = "$env:ProgramData\SkyCampTech\Temp"
$foxitInstaller = Join-Path $tempPath -ChildPath "Foxit11.msi"
$msiexecPath = "C:\Windows\System32\msiexec.exe"

#download installer
Write-Host "Downloading Installer"
Start-BitsTransfer -Source $downloadURL -Destination $foxitInstaller

function Install-FoxitWithKeycode {
    Write-Host "Keycode included; Installing Foxit with Activation Keycode"
    $installArgs = "/i $foxitInstaller keycode='$($keycode)' /quiet"
    Start-Process $msiexecPath -ArgumentList $installArgs -Wait

    $activationPath = "C:\Program Files (x86)\Foxit Software\Foxit PDF Editor\Activation.exe"

    if (Test-Path $activationPath) {
        Write-Host "Activation Path found; attempting activation"
        Start-Process -FilePath $activationPath -ArgumentList "-cmdquietinteractive $keycode"
    }
    else {
        Write-Host "Activation Executable Not Found; will require manual activation"
    }
    
}

function Install-FoxitNoKeycode {
    Write-Host "Installing Foxit with no keycode; will need to manually be activated"
    $installArgs = "/i $foxitInstaller /quiet"  #msiexec /i "Foxit PDF Editor.msi" /quiet INSTALLLOCATION="C:\Program Files\ Foxit Software "
    Write-Host "Argument sent $isntallArgs"
    Start-Process msiexec.exe -Wait -ArgumentList $installArgs
    
}

if ($keycode) {
    Install-FoxitWithKeycode
}
else {
    Install-FoxitNoKeycode
}

Write-Host "Sleeping for 30 seconds, then deleting installer"
Start-Sleep -Seconds 60
remove-Item -Path $foxitInstaller -Force -Confirm:$false