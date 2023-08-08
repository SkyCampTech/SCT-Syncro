Import-Module $env:SyncroModule

#check to see if reboot is required OR machine uptime greater than 30 days
function Test-RebootPending {
    $syncroPath = "HKLM:SOFTWARE\WOW6432Node\RepairTech\Syncro"

    $regValue = (Get-ItemProperty -Path $syncroPath -Name "RebootPending").RebootPending

    #Write-Host "Pending Reboot: $regValue"

    return $regValue
}

function Test-Uptime {
    $daysUp = (((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).Days)

    $result = $daysUp -gt 30

    #Write-Host "Uptime Greater than 30 days: $result"

    return $result
}

$uptimeResult = Test-Uptime
$rebootPendingResult = Test-RebootPending


if (($uptimeResult -eq $true) -Or ($rebootPendingResult -eq $true)) {
    Write-Host "Posting reboot notice"

    #make sure BurntToast Module is installed
    if ($NULL -eq (Get-InstalledModule -Name "BurntToast")) {
        Write-Host "BurntToast not found; installing"
        Install-Module -Name "BurntToast" -Force -Confirm:$false
    }

    #make sure RunAsUser Module is installed
    if ($NULL -eq (Get-InstalledModule -Name "RunAsUser")) {
        Write-Host "RunAsUser Module not found; installing"
        Install-Module -Name "RunAsUser" -Force -Confirm:$false
    }



    #Checking if ToastReboot:// protocol handler is present
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
    $ProtocolHandler = get-item 'HKCR:\ToastReboot' -erroraction 'silentlycontinue'
    if (!$ProtocolHandler) {
        #create handler for reboot
        New-item 'HKCR:\ToastReboot' -force
        set-itemproperty 'HKCR:\ToastReboot' -name '(DEFAULT)' -value 'url:ToastReboot' -force
        set-itemproperty 'HKCR:\ToastReboot' -name 'URL Protocol' -value '' -force
        new-itemproperty -path 'HKCR:\ToastReboot' -propertytype dword -name 'EditFlags' -value 2162688
        New-item 'HKCR:\ToastReboot\Shell\Open\command' -force
        set-itemproperty 'HKCR:\ToastReboot\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\System32\shutdown.exe -r -t 00' -force
    }




    # Install-module -Name RunAsUser -Confirm:$false
    invoke-ascurrentuser -scriptblock {

        $heroimage = New-BTImage -Source 'https://skycamptech.com/wp-content/uploads/2015/12/skycamp-logo-header.png' -HeroImage
        $Text1 = New-BTText -Content  "Message from Sky Camp"
        $Text2 = New-BTText -Content "Your computer requires a reboot. Please select if you'd like to reboot now, or snooze this message."
        $Button = New-BTButton -Content "Snooze" -snooze -id 'SnoozeTime'
        $Button2 = New-BTButton -Content "Reboot now" -Arguments "ToastReboot:" -ActivationType Protocol
        $5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minutes'
        $10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minutes'
        $1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 hour'
        $4Hour = New-BTSelectionBoxItem -Id 240 -Content '4 hours'
        $8Hour = New-BTSelectionBoxItem -Id 480 -Content '8 hours'
        $1Day = New-BTSelectionBoxItem -Id 1440 -Content '1 day'
        $Items = $5Min, $10Min, $1Hour, $4Hour, $8Hour, $1Day
        $SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
        $action = New-BTAction -Buttons $Button, $Button2 -inputs $SelectionBox
        $Binding = New-BTBinding -Children $text1, $text2 -HeroImage $heroimage
        $Visual = New-BTVisual -BindingGeneric $Binding
        $Content = New-BTContent -Visual $Visual -Actions $action
        Submit-BTNotification -Content $Content

    }

    Log-Activity -Message "Prompted User with Reboot Notification"
}
else {
    Write-Host "Reboot Not Required, uptime lower than 30 days; exiting"
    exit 0
}


