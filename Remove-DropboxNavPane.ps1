Import-Module $env:SyncroModule


#get current user SID
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

$hkcrFolders = @("Registry::HKEY_CLASSES_ROOT\CLSID\{E31EA727-12ED-4702-820C-4B6445F28E1A}\ShellFolder", "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{E31EA727-12ED-4702-820C-4B6445F28E1A}\ShellFolder")
$hkcuFolders = @("HKU:\$($userSID)_Classes\CLSID\{E31EA727-12ED-4702-820C-4B6445F28E1A}\ShellFolder", "HKU:\$($userSid)_Classes\Wow6432Node\CLSID\{E31EA727-12ED-4702-820C-4B6445F28E1A}\ShellFolder")

#adjust HKCR folders
foreach ($item in $hkcrFolders) {
    Write-Host "Adjusting Attributes in $item"
    Set-ItemProperty -Path $item -Name "Attributes" -Value "0xf090004d"
}

#adjust hkcu folders

foreach ($item in $hkcuFolders) {
    Write-Host "Adjusting Attributes in $item"
    Set-ItemProperty -Path $item -Name "Attributes" -Value "0xf090004d"
}