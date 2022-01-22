Import-Module $env:SyncroModule

#look up extension IDs in the Chrome webstore if you want to supply them manually

#if there are extensions we're deploying frequently, add them to hashtable AND the name to the dropdown in the syncro script
$extensionList = @{
    "Windows 10 Account"                    = "ppnbnpeolgkicgegkbkbjmhlideopiji"
    "Microsoft Defender Browser Protection" = "bkbeeeffjjeopflfhgeknacdieedcoml"
}

#if an extension ID was provided, set that as extension
if ($manualExtensionId) {
    $extension = $manualExtensionId
}
#set extension to the extension ID from the associated name in the hashtable
else {
    $extension = $extensionList[$extensionName]
}

Write-Host "Forcing Extension $extension"

#check if no extension was provided
if (!($extension)) {
    Write-Host "Extension not found in list and no manual extension ID specified; exiting"
    exit 1;
}
else {
    #get current extension highest value
    $string = (Get-Item -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist").Property[-1]
    
    #convert to string and add 1
    [int]$value = [convert]::ToInt32($string) + 1

    #add extension ID with the value above
    Write-Host "Adding Extension ($extension) to ExtensionInstallForceList in registry with value $value"
    reg add HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForceList /v $value /t REG_SZ /d $extension /f
}


