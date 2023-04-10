Import-Module $env:SyncroModule

<#
Assumptions:
-you're using Customer Custom Fields for everything
-Platform Variables correspond to your Customer Custom Fields for: $wallpaper, $lockscreen, $screensaver
#>

#still need to update to prevent user from changing wallpaper: https://www.makeuseof.com/stop-others-change-windows-desktop-background/ and screensaver: https://www.thewindowsclub.com/prevent-users-changing-screensaver-windows

#folder where files are saved:
$brandingFolder = "$env:ProgramData\SkyCampTech\bin\Branding"

#policies path in HKCU
$currentUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username
$userSid = (New-Object System.Security.Principal.NTAccount($currentUser)).Translate([System.Security.Principal.SecurityIdentifier]).value
Write-Host "Setting branding for $currentUser with SID: $userSid"
$policiesPath = "Registry::HKEY_USERS\$userSid\Software\Microsoft\Windows\CurrentVersion\Policies"
$systemPath = Join-Path $policiesPath -ChildPath "System"


try {
    New-Item -Path $brandingFolder -ItemType Directory -ErrorAction Stop
}
catch {
    Write-Warning $error[0]
}

function Get-BrandingAsset {
    Param(
        [Parameter(Mandatory)]
        [string]$assetType
    )
    switch ($assetType) {
        wallpaper { $url = $wallpaperUrl }
        lockscreen { $url = $lockscreenUrl }
        screensaver { $url = $screensaverUrl }
    }

    Write-Host "Download $assetType from $url"
    Start-BitsTransfer -Source $url -Destination $brandingFolder
}

function Set-Wallpaper {
    #download the wallpaper based on the customer custom field
    Get-BrandingAsset -assetType "wallpaper"

    #get the wallpaper path
    $wallpaperPath = (Get-ChildItem -Path $brandingFolder | Where-Object { $_.Name -match "wallpaper" }).FullName
        
    if (!(Test-Path $systemPath)) {
        Write-Host "creating System under $policiesPath and setting Wallpaper to $wallpaperPath"
        New-Item -Path $policiesPath -Name "System"
        New-ItemProperty -Path $systemPath -Name "Wallpaper" -Value $wallpaperPath
    }
    else {
        Write-Host "System Path already exists; attemtping to set Wallpaper"   

        if (!(Get-ItemProperty -Path $systemPath -Name "Wallpaper")) {
            New-ItemProperty -Path $systemPath -Name "Wallpaper" -Value $wallpaperPath
        }
        else {
            Write-Host "Wallpaper setting already exists in $systemPath; updating value to $wallpaperPath"
            Set-ItemProperty -Path $systemPath -Name "Wallpaper" -Value $wallpaperPath
        }
    }
}

function Set-LockScreen {
    #download the lockscreen image based on the customer custom field
    Get-BrandingAsset -assetType "lockscreen"

    $lockscreenPath = (Get-ChildItem -Path $brandingFolder | Where-Object { $_.Name -match "lockscreen" }).FullName

    $windowsRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $personalizationPath = Join-Path -Path $windowsRegPath -ChildPath "Personalization"

    if (!(Test-Path $personalizationPath)) {
        Write-Host "Creating Personalization under $windowsRegPath and setting LockScreen to $lockscreenPath"
        New-Item -Path $windowsRegPath -Name "Personalization"
        New-ItemProperty -Path $personalizationPath -Name "LockScreenImage" -Value $lockscreenPath
        New-ItemProperty -Path $personalizationPath -Name "LockScreenOverlaysDisabled" -Value 1
        New-ItemProperty -Path $personalizationPath -Name "NoChangingLockScreen" -Value 1 -PropertyType String
    }
    else {
        Write-Host "Personlization already exists"
        if (!(Get-ItemProperty -Path $personalizationPath -Name "LockScreenImage")) {
            New-ItemProperty -Path $personalizationPath -Name "LockScreenImage" -Value $lockscreenPath
            New-ItemProperty -Path $personalizationPath -Name "LockScreenOverlaysDisabled" -Value 1
            New-ItemProperty -Path $personalizationPath -Name "NoChangingLockScreen" -Value 1
        }
        else {
            Write-Host "Lock screen setting already exists; updating to $lockscreenPath"
            Set-ItemProperty -Path $personalizationPath -Name "LockScreenImage" -Value $lockscreenPath
            Set-ItemProperty -Path $personalizationPath -Name "LockScreenOverlaysDisabled" -Value 1
            Set-ItemProperty -Path $personalizationPath -Name "NoChangingLockScreen" -Value 1
        }
    }
}

function Set-Screensaver {

    Get-BrandingAsset -assetType "screensaver"
    $screensaverPath = (Get-ChildItem -Path $brandingFolder | Where-Object { $_.Name -match "screensaver" }).FullName
    if (!($timeoutMins)) {
        $timeoutMins = 10
    }
    [int]$timeoutSecs = [convert]::ToInt32($timeoutMins, 10) * 60

    $screensaverRegPath = "Registry::HKEY_USERS\$userSid\Control Panel\Desktop"
    $timeoutName = "ScreenSaveTimeOut"
    $timeoutValue = $timeoutSecs

    if (!(Get-ItemProperty -Path $screensaverRegPath -Name 'ScreenSaveActive')) {
        New-ItemProperty -Path $screensaverRegPath -Name 'ScreenSaveActive' -Value 1 -PropertyType String -Value 1 -Force
    }
    else {
        #enable the screensaver
        Set-ItemProperty -Path $screensaverRegPath -Name 'ScreenSaveActive' -Value 1 -Force
    }

    if (!(Get-ItemProperty -Path $screensaverRegPath -Name 'ScreenSaverIsSecure')) {
        #force Logon on resume
        New-ItemProperty -Path $screensaverRegPath -Name 'ScreenSaverIsSecure' -PropertyType String -Value 1 -Force
    }
    else {
        Set-ItemProperty -Path $screensaverRegPath -Name 'ScreenSaverIsSecure' -Value 1 -Force
    }

    if (!(Get-ItemProperty -Path $screensaverRegPath -Name 'SCRNSAVE.exe')) {
        #set SCRNSAVE.EXE
        New-ItemProperty -Path $screensaverRegPath -Name 'SCRNSAVE.EXE' -PropertyType String -Value $screensaverPath -Force
    }
    else {
        Set-ItemProperty -Path $screensaverRegPath -Name 'SCRNSAVE.EXE' -Value $screensaverPath -Force
    }

    if (!(Get-ItemProperty -Path $screensaverRegPath -Name $timeoutName)) {
        #set timeout
        New-ItemProperty -path $screensaverRegPath -Name $timeoutName -PropertyType String -Value $timeoutValue -Force
    }
    else {
        #set timeout
        Set-ItemProperty -path $screensaverRegPath -Name $timeoutName -Value $timeoutValue -Force
    }
    
}


if ($wallpaperUrl) {
    Set-Wallpaper
}
if ($lockscreenUrl) {
    Set-LockScreen
}
if ($screensaverUrl) {
    Set-Screensaver
}