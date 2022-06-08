Import-Module $env:SyncroModule

<#Path of microsoft store popups#>
$path = "Computer\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App"
if ($MicrosoftStore) {
    New-item -Path $path
    New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType DWord
    Write-Host "Microsoft Store ads removed!"
}

<#Path of System Settings popups#>
$path = "Computer\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"
if ($Settings) {
    New-item -Path $path
    New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType DWord
    Write-Host "System Settings popups removed!"
}