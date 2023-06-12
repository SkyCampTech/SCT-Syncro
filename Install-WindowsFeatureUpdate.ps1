#use this script to install a Windows Feature Update using the PSWindowsUpdate module
#https://www.powershellgallery.com/packages/PSWindowsUpdate/2.2.0.3
Import-Module $env:SyncroModule

if (!(Get-InstalledModule -Name "pswindowsupdate")) {
    Write-Host "PSWindowsUpdate Module not installed"
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
}

function Get-LatestFeatureUpdate {
    Write-Host "Getting Latest Feature Update"
    $results = Get-WindowsUpdate

    $featureUpdateKB = ($results | Where-Object { $_.Title -match "Feature Update" }).KB

    if (!$featureUpdateKB) {
        #check for Windows 11 since it no longer includes "Feature Update" in the Title
        Write-Host "Didn't find a feature update for Windows 10; check for new naming for Windows 11"
        $featureUpdateKB = ($results | Where-Object { $_.Title -match "Windows 11, version" }).KB
    }

    if (!($featureUpdateKB)) {
        Write-Host "No Feature Updates needed; exiting"
        exit
    }

    Write-Host "Latest Feature Update KB: $featureUpdateKB"

    return $featureUpdateKB
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
    Send-UserRebootNotice

    #build this out more to prompt the user at the end to reboot. Look into Burnt Toast Notifications and RunAsUser Module
}

function Send-UserRebootNotice {
    $emailBody = @"
    Hi $userName,
    <br />
    <br />
    We have installed an important update on your computer that requires a restart. Please restart your computer (name: $env:ComputerName) at your earliest convenience. 
    <br />
    <br />
    If you have any questions, please let us know by replying to this email to update the ticket.
    <br />
    <br />
    Thank you, 
    <br />
    SkyCamp Tech
"@
    $ticketSubject = "$env:ComputerName - Windows Feature Update Notice"
    $issueType = "Computer - Software"
    $status = "New"

    $ticket = (Create-Syncro-Ticket -Subject $ticketSubject -IssueType $issueType -Status $status).ticket

    $id = $ticket.id

    Write-Host "Created Ticket with ID $id"

    Create-Syncro-Ticket-Comment -TicketIdOrNumber $id -Subject "Contacted" -Body $emailBody -Hidden "false" -DoNotEmail "false"

    Write-Host "Closing Ticket with ID $id"
    Update-Syncro-Ticket -TicketIdOrNumber $id -Status "Resolved"
}


$kb = Get-LatestFeatureUpdate

switch ($rebootComputer) {
    "yes" { Install-LatestFeatureUpdateForcedReboot -kbArticleID $kb }
    "no" { Install-LatestFeatureUpdateNoReboot -kbArticleID $kb }
    Default {
        Install-LatestFeatureUpdateNoReboot -kbArticleID $kb
    }
}
