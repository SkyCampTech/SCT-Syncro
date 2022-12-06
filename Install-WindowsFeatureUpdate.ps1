#use this script to install a Windows Feature Update using the PSWindowsUpdate module
#https://www.powershellgallery.com/packages/PSWindowsUpdate/2.2.0.3
Import-Module $env:SyncroModule

#prep work
#make sure NuGet is installed
try {
    $null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop
}
catch {
    Write-Host "Unable to install NuGet; exiting"
    exit 1
}

#install PSWindowsUpdate Module
try {
    Install-Module -Name PSWindowsUpdate -Force -ErrorAction Stop
}
catch {
    Write-Host "Unable to install PSWindowsUpdate Module; exiting"
    exit 1
}

#install RunAsUser Module
try {
    Install-Module -Name RunAsUser -Force -ErrorAction Stop
}
catch {
    Write-Host "Unable to install RunAsUserModule; exiting"
    exit 1
}

function Get-LatestFeatureUpdate {
    Write-Host "Getting Latest Feature Update"
    $results = Get-WindowsUpdate

    $featureUpdateKB = ($results | Where-Object { $_.Title -match "Feature Update" }).KB

    if (!($featureUpdateKB)) {
        Write-Host "No Feature Updates needed; exiting"
        exit
    }

    Write-Host "Latest Feature Update KB: $featureUpdateKB"

    return $featureUpdateKB
}

function Show-UserNotice {
    Write-Host "Displaying Notice to User"
    Invoke-AsCurrentUser -ScriptBlock {
        $message = "Update In Progress. Please save all open work. Your machine will reboot as soon as the update has finished installing. No further action is necessary. Clicking OK will not reboot your computer."
        $title = "Message from SkyCamp"
        $wsh.Popup($message, 0, $title)
    }
}

function Install-LatestFeatureUpdateForcedReboot {
    # Parameter help description
    param(
        [Parameter()]
        [string]
        $kbArticleID
    )

    #use Burnt Toast/RunAsUser to put a message up on the screen informing them that the update is in progress and they should save anything open

    Write-Host "Installing latest Feature Update with a Forced Reboot"

    #inform user
    #Show-UserNotice

    #start update
    Install-WindowsUpdate -KBArticleID $kbArticleID -AcceptAll -AutoReboot

}

function Install-LatestFeatureUpdateNoReboot {
    param(
        [Parameter()]
        [string]
        $kbArticleID
    )

    Write-Host "installing latest Feature Update with No Reboot"
    #Show-UserNotice
    Install-WindowsUpdate -KBArticleID $kbArticleID -AcceptAll -IgnoreReboot

    #build this out more to prompt the user at the end to reboot. Look into Burnt Toast Notifications and RunAsUser Module
}


$kb = Get-LatestFeatureUpdate

switch ($rebootComputer) {
    "yes" { Install-LatestFeatureUpdateForcedReboot -kbArticleID $kb }
    "no" { Install-LatestFeatureUpdateNoReboot -kbArticleID $kb }
    Default {
        Install-LatestFeatureUpdateNoReboot -kbArticleID $kb
    }
}
