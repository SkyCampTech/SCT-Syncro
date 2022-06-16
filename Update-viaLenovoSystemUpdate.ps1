Import-Module $env:SyncroModule -DisableNameChecking
Set-ExecutionPolicy Unrestricted -Force
# Requires Windows 10 and Chocolatey
# Documentation for update module: https://github.com/jantari/LSUClient

$lsu = "${env:ProgramFiles(x86)}\Lenovo\System Update"
$choco = "$env:allusersprofile\chocolatey\choco.exe"

# Trap errors but skip Lenovo's bad URLs
trap {
    if (-Not $_ -match "(404) Not Found") {
        $_; exit 2
    }
}

if ((Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer -notlike 'Lenovo*') {
    Write-Host "System Manufacturer is not Lenovo, exiting"
    exit 0
}

$model = (Get-CimInstance -ClassName CIM_ComputerSystem).Model
$notsupportedmodels = @("H420", "10181", "20309")
foreach ($notsupportedmodel in $notsupportedmodels) {
    if ($model -like "*$notsupportedmodel*") {
        Write-Host "Model is not supported, exiting"
        exit 0
    }
}

# Uninstall Lenovo Vantage
if (Test-Path "C:\Program Files (x86)\Lenovo\VantageService") {
    Write-Host "Uninstalling Lenovo Vantage..."
    $vantage = (Get-Item "C:\Program Files (x86)\Lenovo\VantageService\*\Unins*.exe").FullName
    Start-Process "$vantage" -ArgumentList "/SILENT" -Wait
}

# Install/Upgrade LSU (if already present choco will reinstall it as its own)
&$choco upgrade lenovo-thinkvantage-system-update -y --no-progress
Write-Host "`n"

# Verify Install
if (!(Test-Path "${env:ProgramFiles(x86)}\Lenovo\System Update\tvsu.exe")) {
    Write-Host "LSU not found, install must have failed"
    exit 2
}

# Check for LSUClient module and install/update it
if (!(Get-Module -ListAvailable -Name LSUClient)) {
    Write-Host "LSUClient module not found, installing...`n"
    Install-PackageProvider NuGet -Force
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module -Name 'LSUClient'
} 
else {
    Write-Host "Checking LSUClient module version...`n"
    if (((Get-Module -ListAvailable -Name LSUClient).Version | Select-Object -first 1) -lt ((Find-Module -Name LSUClient).Version)) {
        Write-Host "Updating LSUClient module..."
        Update-Module -Name 'LSUClient' -Force
    }
}

# Find and Apply Updates capable of unattended install
[array]$updates = Get-LSUpdate | Where-Object { $_.Installer.Unattended }

if ($updates) {
    Write-Host "Downloading updates...`n"
    $updates | Save-LSUpdate -Verbose
    [array]$results = Install-LSUpdate -Package $updates
    Write-Host "`nUnattended Updates Results:"
    foreach ($item in $results) {
        $item.PSObject.Properties | Where-Object { $_.Value -ne $null } | Format-Table Name, Value
    }
    
    # Determine Action Needed
    if ($results.PendingAction -contains 'REBOOT_SUGGESTED') {
        Write-Host 'Reboot suggested, restarting...'
        shutdown /g /f
    }
    if ($results.PendingAction -contains 'REBOOT_MANDATORY') {
        Write-Host 'Reboot needed, restarting...'
        shutdown /g /f
    }
    if ($results.PendingAction -contains 'SHUTDOWN') {
        Write-Host 'Shutdown needed, shutting down...'
        shutdown /f
    }
}
else {
    Write-Host "`nNo unattended updates found`n"
}

# Check for any remaining updates
$attended = Get-LSUpdate | Where-Object { $_.Installer.Unattended -eq $false } | Out-String
if ($attended) {
    Write-Host "`nAttended Updates Found:"
    $attended
    Rmm-Alert -Category 'Task - Lenovo System Update' -Body "Unsupported installer detected, needs manual update<br>$attended"
}
else { Write-Host "`nNo attended updates found" }
