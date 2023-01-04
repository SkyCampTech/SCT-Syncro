#use this script to get a Crystal Disk Info report and upload it to the asset record
Import-Module $env:SyncroModule

$crystalDiskPath = "C:\Program Files\RepairTech\Syncro\kabuto_app_manager\lib\crystaldiskinfo.portable\tools"
$crystalDiskExe = Join-Path -Path $crystalDiskPath -ChildPath "DiskInfo64.exe"

if (!(Test-Path -Path $crystalDiskExe)) {
    Write-Host "Crystal Disk Info Not installed; attempt install via Chocolatey"
    Start-Process -FilePath "C:\Program Files\RepairTech\Syncro\kabuto_app_manager\choco.exe" -ArgumentList "crystaldiskinfo -y" -Wait
}

if (Test-Path -Path $crystalDiskExe) {
    Write-Host "Crystal Disk Info is installed; getting output"
    Start-Process -FilePath $crystalDiskExe -ArgumentList "/copyexit" -Wait
    $outputFile = "C:\Program Files\RepairTech\Syncro\kabuto_app_manager\lib\crystaldiskinfo.portable\tools\DiskInfo.txt"
    $today = $today = (Get-Date -Format 'yyyy-MM-dd_HHmm')
    Rename-Item -Path $outputFile -NewName "DiskInfo_$today.txt"
    $uploadFile = Join-Path $crystalDiskPath -ChildPath "DiskInfo_$today.txt"
    Upload-File -FilePath $uploadFile
}