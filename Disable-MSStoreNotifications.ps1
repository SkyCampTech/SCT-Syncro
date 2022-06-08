Import-Module $env:SyncroModule

<#Path of microsoft store popups#>
$path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App"
if ($MicrosoftStore) {
    try {
        New-ItemProperty -Path $path -Name "Enabled" -Value 0 -PropertyType DWord -Force 
        Write-Host "Microsoft Store notifications removed!"
    }
    catch {
        Write-Host "FAILED: Couldn't remove Microsoft Store Notifications"
    }
    
}

# <#Path of System Settings popups#>
# $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"
# if ($Settings) {
#     If (!(Test-Path $path)) {
#         New-Item -Path $path -Force | Out-Null
#     }  
#     New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType DWord -Force 
#     Write-Host "System Settings popups removed!"
# }