#use this script to install Adobe Creative Cloud apps
Import-Module $env:SyncroModule

if (Test-Path "$env:ProgramFiles\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe") {
    Write-Host " Creative Cloud already installed; exiting"
    Rmm-Alert -Category "Software" -Body "Creative Cloud already installed; advise user to manually install their needed apps from Creative Cloud"
    exit 1
}

#installType and baseUrl passed by Syncro runtime/dropdown
#if you're not using syncro, you'll want a param block defining these
switch ($installType) {
    "Creative Cloud Only" { $installerUrl = "$baseUrl/Creative-Cloud-Desktop-Only_Win64.zip" }
    "Acrobat" { $installerUrl = "$baseUrl/Acrobat-and-CC-Desktop_Win64.zip" }
    Default { $installerUrl = "$baseUrl/Creative-Cloud-Desktop-Only_Win64.zip" }
}

$outputPath = "$env:ProgramData\SkyCampTech\temp"
$fileName = $installerUrl.Split("/")[-1]
$outputFile = Join-Path -Path $outputPath -ChildPath $fileName

Write-Host "Downloading $installType from $installerUrl"

Start-BitsTransfer -Source $installerUrl -Destination $outputFile

Expand-Archive $outputFile -DestinationPath $outputPath

$installFile = Join-Path $outputPath -ChildPath "Build\Setup.exe"

Write-Host "Installing from $installFile"

Start-Process $installFile -ArgumentList "--silent" -Wait

if ($installType -ne "Creative Cloud Only") {
    Start-Sleep -Seconds 60
    Write-Host "Sleeping for 60 seconds to give it time to finish up"
}

#do a test here to see if anything got installed, then output to Syncro Activity Log
if (Test-Path "$env:ProgramFiles\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe") {
    Write-Host " Creative Cloud Installed Successfully"
    #log activity requires Syncro
    Log-Activity -Message "Installed Adobe Creative Cloud Desktop"
    Get-ChildItem -Path $outputPath -Recurse | Remove-Item -Recurse -Confirm:$false   
}
else {
    Rmm-Alert -Category "Software" -Body "Failed to detect Adobe Creative Cloud Desktop"
    Get-ChildItem -Path $outputPath -Recurse | Remove-Item -Recurse -Confirm:$false
    exit 1
}
