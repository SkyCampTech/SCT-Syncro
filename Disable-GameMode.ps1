Import-Module $env:SyncroModule

$gameModePath = "HKCU:\Software\Microsoft\GameBar"

try {
    New-ItemProperty -Path $gameModePath -Name "AllowAutoGameMode" -PropertyType DWORD -Value 0 -ErrorAction Stop
}
catch {
    Write-Host "AllowAutoGameMode already exists; updating value"
    Set-ItemProperty -Path $gameModePath -Name "AllowAutoGameMode" -Value 0 -Force
}

if ((Get-ItemProperty -Path $gameModePath -Name "AllowAutoGameMode").AllowAutoGameMode -eq 0) {
    Write-Host "Disabled Game Mode successfully; computer needs to be restarted"
}