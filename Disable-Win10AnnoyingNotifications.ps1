Import-Module $env:SyncroModule


if ($MicrosoftStore -eq "True") {
    <#Path of microsoft store popups#>
    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App"
    try {
        New-ItemProperty -Path $path -Name "Enabled" -Value 0 -PropertyType DWord -Force 
        Write-Host "Microsoft Store notifications removed!"
    }
    catch {
        Write-Host "FAILED: Couldn't remove Microsoft Store Notifications"
    }
}


if ($Settings -eq "True") {
    <#Path of System Settings popups#>
    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"
    try {
        New-ItemProperty -Path $path -Name "Enabled" -Value 0 -PropertyType DWord -Force 
        Write-Host "System Settings notifications removed!"
    }
    catch {
        Write-Host "FAILED: Couldn't remove System Settings Notifications"
    }
}

if ($NewStuffUpdates -eq "True") {
    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    try {
        New-ItemProperty -Path $path -Name "SubscribedContent-338389Enabled" -Value 0 -PropertyType DWord -Force 
        Write-Host "New stuff from update notifications removed!"
    }
    catch {
        Write-Host "FAILED: Couldn't remove New stuff from update Notifications"
    }   
}

if ($TipsAndTricks -eq "True") {
    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    try {
        New-ItemProperty -Path $path -Name "SubscribedContent-310093Enabled" -Value 0 -PropertyType DWord -Force 
        Write-Host "Tips, Tricks, and Suggestions notifications removed!"
    }
    catch {
        Write-Host "FAILED: Couldn't remove Tips, Tricks, and Suggestions Notifications"
    }   
}
