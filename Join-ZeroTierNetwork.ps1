#use this script to join a ZeroTier network
#expects network ID to be passed at runtime
Import-Module $env:SyncroModule

if (!($networkId)) {
    Write-Host "No network ID specified"
    exit 1
}

$ztPath = "C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat"

if (!(Test-Path $ztPath)) {
    Write-Host "ZeroTier Not Installed; Installing via Choco"
    $choco = 'C:\Program Files\RepairTech\Syncro\kabuto_app_manager\kabuto_patch_manager.exe'
    Start-Process -FilePath $choco -ArgumentList "install zerotier-one -y" -Wait
    Write-Host "Sleeping to wait for install"
    Start-Sleep -Seconds 15
}

if (!(Test-Path $ztPath)) {
    Write-Host "ZeroTier CLI still not detected; exiting"
    exit 1
}
else {
    $infoCommand = "& 'C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat' status"
    $clientId = (Invoke-Expression -Command $infoCommand).Split(" ")[2]

    Write-Host "Client ID: $clientId"
    
    $joinCommand = "& 'C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat' join $networkId"
    Invoke-Expression -Command $joinCommand

    Rmm-Alert -Category "ZeroTier" -Body "Submitted request from $env:ComputerName to join Network $networkId with Client ID: $clientId"
}
