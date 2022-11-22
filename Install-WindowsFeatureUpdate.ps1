#use this script to install a Windows Feature Update using the PSWindowsUpdate module
#https://www.powershellgallery.com/packages/PSWindowsUpdate/2.2.0.3
Import-Module $env:SyncroModule

#prep work
#make sure NuGet is installed
try {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop
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

function Get-LatestFeatureUpdate {
    Write-Host "Getting Latest Feature Update"
    $results = Get-WindowsUpdate

    $featureUpdateKB = ($results | Where-Object { $_.Title -match "Feature Update" }).KB

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

    Write-Host "Installing latest Feature Update with a Forced Reboot"

    Install-WindowsUpdate -KBArticleID $kbArticleID -AcceptAll -AutoReboot

}

function Install-LatestFeatureUpdateNoReboot {
    param(
        [Parameter()]
        [string]
        $kbArticleID
    )

    Write-Host "installing latest Feature Update with No Reboot"
    Install-WindowsUpdate -KBArticleID $kbArticleID -AcceptAll -IgnoreReboot
}

$kb = Get-LatestFeatureUpdate

switch ($rebootComputer) {
    "yes" { Install-LatestFeatureUpdateForcedReboot -kbArticleID $kb }
    "no" { Install-LatestFeatureUpdateNoReboot -kbArticleID $kb }
    Default {
        Install-LatestFeatureUpdateNoReboot -kbArticleID $kb
    }
}
