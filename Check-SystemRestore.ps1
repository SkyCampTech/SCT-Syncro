Import-Module $env:SyncroModule
#use this script to enable System Restore

if (!($maxsize)) {
    $maxsize = "2%"
}

$result = Get-ComputerRestorePoint

if (!($result)) {
    Write-Host "System Restore not enabled yet; enabling"
    Enable-ComputerRestore -Drive $env:SystemDrive
    Write-Host "Setting System Restore settings and creating a checkpoint"
    $vssadminSettings = "vssadmin resize shadowstorage /for=$env:SystemDrive /on=$env:SystemDrive /maxsize=$maxsize"

    Write-Host "Running: $vssadminSettings"

    Invoke-Expression $vssadminSettings

    $today = Get-Date -Format yyyy-MM-DD

    $description = "Checkpoint via RMM Script - $today"

    Checkpoint-Computer -Description $description -RestorePointType MODIFY_SETTINGS

    $result = Get-ComputerRestorePoint
}
else {
    Write-Host "System Restore already enabled with checkpoints"
    exit 0
}

$result = Get-ComputerRestorePoint

if (!($result)) {
    Write-Host "No checkpoints detected"
    Rmm-alert -Category "System Restore" -Body "System Restore failed to be enabled via script"
    exit 1
}
else {
    Write-Host "Most Recent checkpoint at $($result.CreationTime[0]) with sequence ID $($result.SequenceNumber[0])"
}
