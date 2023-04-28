Import-Module $env:SyncroModule

$OScheck = (Get-CimInstance Win32_OperatingSystem).Caption
if ($OSCheck -match "Server") {
    Write-Host "Machine running a server version; exiting"
    exit;
}

$keyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'

$currentOS = (Get-ComputerInfo).OsName

if ($currentOS -match "10") {
    Write-Host "Current OS is 10; Set Approved OS to 10"
    $approvedOS = "Windows 10"
}
elseif ($currentOS -match "11") {
    Write-Host "Current OS is 11; Set Approved OS to 11"
    $approvedOS = "Windows 11"
}

#check if WindowsUpdate key exists and create it if not

if (!(Test-Path -Path $keyPath)) {
    Write-Host "$keyPath didn't exist. Creating"
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'WindowsUpdate'
    
    #enables the 'TargetReleaseVersion' setting
    New-ItemProperty -Path $keyPath -Name "TargetReleaseVersion" -PropertyType DWORD -Value 1

    #sets the Windows OS Version to what was defined at input. This will be Windows 10, Windows 11, etc
    New-ItemProperty -Path $keyPath -Name "ProductVersion" -Value $ApprovedOS

    #sets the Release Version to what was defined at input. This will be 20H2, 21H1, etc
    New-ItemProperty -Path $keyPath -Name "TargetReleaseVersionInfo" -Value $ApprovedVersion

    $CurrentApprovedOS = (Get-ItemProperty -Path $keyPath).ProductVersion
    $CurrentApprovedVersion = (Get-ItemProperty -Path $keyPath).TargetReleaseVersionInfo

    Log-Activity -Message "Set highest approved OS/Version to $CurrentApprovedOS $CurrentApprovedVersion"
   
}

else {
    Write-Host "$keyPath exists; Let's set the targets we want"
    Set-ItemProperty -Path $keyPath -Name "TargetReleaseVersion" -Value 1 -Force
    Set-ItemProperty -Path $keyPath -Name "ProductVersion" -Value $ApprovedOS -Force
    Set-ItemProperty -Path $keyPath -Name "TargetReleaseVersionInfo" -Value $ApprovedVersion -Force

    $CurrentApprovedOS = (Get-ItemProperty -Path $keyPath).ProductVersion
    $CurrentApprovedVersion = (Get-ItemProperty -Path $keyPath).TargetReleaseVersionInfo

    Log-Activity -Message "Set highest approved OS/Version to $CurrentApprovedOS $CurrentApprovedVersion"
}
