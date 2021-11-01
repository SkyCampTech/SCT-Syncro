#checks to see if Make Me Admin is installed. then adds the current user to the "Allowed Entities" registry entry (users allowed to request admin on that machine)
#https://github.com/pseymour/MakeMeAdmin/wiki/
#use's the current user; optionally pass a timeout value if you want it different than 15 mins

Import-Module $env:SyncroModule

$MMAPath = 'C:\Program Files\Make Me Admin\MakeMeAdminUI.exe'

#set default timeout to 15 minutes
if (!($timeoutMins)) {
    $timeoutMins = 15
}

#check to see if it's installed
if (!(Test-Path $MMAPath)) {
    #if it's not installed, install via chocolatey
    choco install makemeadmin -y
    Log-Activity -Message "Installed MakeMeAdmin via Chocolatey" -EventName "Mgmt"
}

#get the current user's SID
try {
    New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
    $userSID = (Get-ChildItem HKU: | where { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName
}
catch {
    Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
    $false
}


if (!($userSID)) {
    Write-Host "couldn't locate SID for current user; exiting"
    exit 1
}

$userName = (New-Object System.Security.Principal.SecurityIdentifier($userSID)).Translate([System.Security.Principal.NTAccount]).value

#configure the registry
$MMARegPath = "HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin"

#check if registry path already exists
if (!(Test-Path $MMARegPath)) {
    Write-Host "creating registry keys for Make Me Admin"
    New-Item -Path "HKLM:\SOFTWARE" -Name "Sinclair Community College"
    New-Item -Path  "HKLM:\SOFTWARE\Sinclair Community College" -Name "Make Me Admin"
    New-ItemProperty -Path $MMARegPath -Name "Allowed Entities" -PropertyType MultiString -Value $userSID
    New-ItemProperty -Path $MMARegPath -Name "Admin Rights Timeout" -PropertyType DWORD -Value $timeoutMins
    New-ItemProperty -Path $MMARegPath -Name "Remove Admin Rights On Logout" -PropertyType DWORD -Value 1
    Write-Host "$userName now has Make Me Admin rights on $env:COMPUTERNAME"
    Log-Activity -Message "$userName now has Make Me Admin rights" -EventName "Mgmt"
}
else {
    Set-ItemProperty -Path $MMARegPath -Name "Admin Rights Timeout" -Value $timeoutMins
    Set-ItemProperty -Path $MMARegPath -Name "Remove Admin Rights On Logout" -Value 1

    #get current admins in case this has already been set
    [array]$currentAdmins = Get-ItemPropertyValue -Path $MMARegPath -Name "Allowed Entities"

    #add user's SID to the array
    $SIDList = $currentAdmins + $userSID

    #set the Allowed Entities entry with our array
    Set-ItemProperty -Path $MMARegPath -Name "Allowed Entities" -Value $SIDList

    Write-Host "$userName now has Make Me Admin rights on $env:COMPUTERNAME"
    Log-Activity -Message "$userName now has Make Me Admin rights" -EventName "Mgmt"
}

