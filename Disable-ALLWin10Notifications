# Dismiss Windows Defender alerts about Windows Hello/Microsoft account
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State" -Name "AccountProtection_WindowsHello_Available" -Value 0 -PropertyType DWord -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State" -Name "AccountProtection_MicrosoftAccount_Disconnected" -Value 0 -PropertyType DWord -Force

# Disable non-critical Windows Defender notifications
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Reporting" -Name "DisableEnhancedNotifications" -Value 1 -PropertyType DWord -Force

# Disable Sync Provider notifications (OneDrive Ads in Explorer)
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications' -Value 0 -PropertyType DWord -Force

# Disable Start Menu/Settings suggestions & other ads
$Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
Set-ItemProperty -Path $Path -Name 'ContentDeliveryAllowed' -Type DWord -Value 0
Set-ItemProperty -Path $Path -Name 'OemPreInstalledAppsEnabled' -Type DWord -Value 0
Set-ItemProperty -Path $Path -Name 'PreInstalledAppsEnabled' -Type DWord -Value 0
Set-ItemProperty -Path $Path -Name 'PreInstalledAppsEverEnabled' -Type DWord -Value 0
Set-ItemProperty -Path $Path -Name 'SilentInstalledAppsEnabled' -Type DWord -Value 0
Set-ItemProperty -Path $Path -Name 'SystemPaneSuggestionsEnabled' -Type DWord -Value 0 
# Disable App Suggestions in Start menu
Set-ItemProperty -Path $Path -Name 'SoftLandingEnabled' -Type DWord -Value 0 
# Disable popup "tips" about Windows
Set-ItemProperty -Path $Path -Name 'SubscribedContentEnabled' -Type DWord -Value 0
# "Show me the Windows welcome experience after updates and occasionally when I sign in to highlight what's new and suggested"
Set-ItemProperty -Path $Path -Name 'SubscribedContent-310093Enabled' -Type DWord -Value 0 
# "Get fun facts, tips and more from Windows and Cortana on your lock screen"
Set-ItemProperty -Path $Path -Name 'SubscribedContent-338387Enabled' -Type DWord -Value 0
# "Occasionally show suggestions in Start" 
Set-ItemProperty -Path $Path -Name 'SubscribedContent-338388Enabled' -Type DWord -Value 0
# "Get tips, tricks, and suggestions as you use Windows"
Set-ItemProperty -Path $Path -Name 'SubscribedContent-338389Enabled' -Type DWord -Value 0 
# "Show me suggested content in the Settings app"
Set-ItemProperty -Path $Path -Name 'SubscribedContent-338393Enabled' -Type DWord -Value 0 
# "Show me suggested content in the Settings app"
Set-ItemProperty -Path $Path -Name 'SubscribedContent-353694Enabled' -Type DWord -Value 0 
# "Show me suggested content in the Settings app"
Set-ItemProperty -Path $Path -Name 'SubscribedContent-353696Enabled' -Type DWord -Value 0 
Set-ItemProperty -Path $Path -Name 'SubscribedContent-358398Enabled' -Type DWord -Value 0

If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
$key = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $key.Data[0..15]
# Disable "Suggest ways I can finish setting up my device to get the most out of Windows"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f