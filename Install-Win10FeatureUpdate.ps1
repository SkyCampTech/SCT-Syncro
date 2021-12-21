#credit to drhodes: https://community.syncromsp.com/t/script-to-update-windows-to-version-20h2/127/8

Import-Module $env:SyncroModule

# Set Variables:
$targetVersion = "10.0.19044"   #Windows 10 21h2
$minimumSpace = 10          # Minimum drive space in GB
$downloadPath = "C:\temp"     # Folder for the download
$logPath = "C:\temp\logs"     # Folder for the Windows setup logs
$updateAssistantURL = "https://go.microsoft.com/fwlink/?LinkID=799445" # URL of the update assistant
$upgradeArguments = "/quietinstall /skipeula /auto upgrade /copylogs " + $logPath
$fileName = "Windows10Upgrade.exe"

Write-Host $fileName
<#
  Prevent updates during working hours
  - if $workingHoursEnabled is set to true, if the script is run between the specified hours it will terminate
  - prevents accidental in-hours upgrades
#>
$workingHoursEnabled = $false 
$workingHoursStart = 0900
$workingHoursEnd = 1730

<#
  Show pop up to logged in user
  - if true, this will display a pop up to any logged in user
  - if timeout is set to 0, script will *need* user to click OK before script continues
  - so if you want this to be unattended, either set a time for the pop up greater than 0 seconds, or set $popupShow to $false
#>

#$popupShow = $true
$popupMessage = "A  Windows Feature Update is scheduled for your device. This will take 2-4 hours depending on the speed of your machine and your Internet. Please save all documents and close your work, leaving your PC turned on and connected to power"
$popupTitle = "Message from SkyCamp Tech Support"
#$popupTimeout = 20

function Get-RunAsUserStatus {
    #check for RunAsUser module
    $runAsUser = Get-InstalledModule -Name "RunAsUser"
    if (!($runAsUser)) {
        Install-Module -Name "RunAsUser" -Force
        Start-Sleep -Seconds 60
    }
    else {
        Write-Output "RunAsUser already installed on $env:ComputerName"
    }
}

function Get-CurrentUser {
    try {
        $user = Get-WMIObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Username
        return $user
    }
    catch {
        Write-Output "No one logged on. Don't display message"
        return
    }
}

function Get-CurrentVersion {
    $OS = (Get-CimInstance Win32_OperatingSystem).caption
    $currentVersion = (Get-CimInstance Win32_OperatingSystem).version
    if (-Not ($OS -like "Microsoft Windows 10*")) {
        Write-Output "This machine does not have Windows 10 installed. Exiting."
        exit
    }
    if ($currentVersion -eq $targetVersion) {
        Write-Output "OS is up-to-date - no action required. Exiting"
        exit
    }
    else {
        Write-Output "OS is out of date, continuing"
    }
}

function Test-DiskSpace ($minimumSpace) {
    $drive = Get-PSDrive $env:SystemDrive.Split(':')[0]
    $freeSpace = $drive.free / 1GB
    if ($minimumSpace -gt $freeSpace) {
        Write-Output "Not enough space for the upgrade to continue. Exiting script."
        exit
    }
    else {
        Write-Output "There is enough free disk space. Continuing."
    }
}


function Test-WorkingHours($enabled, $startTime, $endTime) {
    if ($enabled -eq $true) {
        [int]$time = Get-Date -format HHMM
        if ($time -gt $startTime -And $time -lt $endTime) {
            Write-Output "Script has been executed within working hours. Exiting script."
            exit
        }
        else {
            Write-Output "Confirmed script has been run outside working hours. Continuing."
        }
    }
    else {
        Write-Output "Working hours flag disabled. Continuing."
    }
}

function Get-UpdateAssistant($URL, $path, $log, $file) {
    # Download File
    If (!(test-path $path)) {
        New-Item -ItemType Directory -Force -Path $path
        Write-Output "Created download path."
    }
    If (!(test-path $log)) {
        New-Item -ItemType Directory -Force -Path $log
        Write-Output "Created log path."
    }
    Invoke-WebRequest -Uri $URL -OutFile $path\$file
    Write-Output "Downloaded Update Assistant"
}

function Show-Message($title, $message) {
    if ($enabled -eq $true) {
        $scriptblock = {
            Display-Alert -Message "$title `n $message"
        } 
        Invoke-AsCurrentUser -ScriptBlock $scriptblock
    }
    else {
        Write-Output "Pop up has been disabled. Continuing."
    }
}

function Start-Upgrade($path, $file, $arguments) {
    Write-Output "Starting upgrade process..."
    Start-Process -FilePath $path\$file -ArgumentList $arguments
    Write-Output "Upgrade process has been started"
    $startAt = (Get-Date)
    #Set-Asset-Field -Subdomain "YOUR-DOMAIN" -Name "Script Upgrade Started" -Value $startAt
    Start-Sleep -s 120 # Pause a little, to make sure the process is started
    Log-Activity -Message "Initiated Win10 Feature Update at $startAt"
}

#check if RunAsUser is installed so we can display an alert to the current user
Get-RunAsUserStatus

Get-CurrentVersion

Test-DiskSpace $minimumSpace

Test-WorkingHours $workingHoursEnabled $workingHoursStart $workingHoursEnd

Get-UpdateAssistant $updateAssistantURL $downloadPath $logPath $fileName

$currentUser = Get-CurrentUser
if ($currentUser) {
    Show-Message -title $popupTitle -message $popupMessage
}

Start-Upgrade $downloadPath $fileName $upgradeArguments