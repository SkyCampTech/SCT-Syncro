Import-Module $env:SyncroModule

# Application list arrays, you can add more if you want
$security = @("ahnlab", "avast", "avg", "avira", "bitdefender", "checkpoint", "clamwin", "comodo", "dr.web", "eset ", "fortinet", "f-prot", "f-secure", "g data", "immunet", "kaspersky", "mcafee", "nano", "norton", "panda", "qihoo 360", "segurazo", "sentinel", "sophos", "symantec", "trend micro", "trustport", "webroot", "zonealarm")
$remoteaccess = @("aeroadmin", "alpemix", "ammyy", "anydesk", "asg-remote", "aspia", "bomgar", "chrome remote", "cloudberry remote", "dameware", "dayon", "deskroll", "dualmon", "dwservice", "ehorus", "fixme.it", "gosupportnow", "gotoassist", "gotomypc", "guacamole", "impcremote", "instant housecall", "instatech", "isl alwayson", "isl light", "join.me", "jump desktop", "kaseya", "lite manager", "logmein", "mikogo", "meshcentral", "mremoteng", "nomachine", "opennx", "optitune", "pilixo", "radmin", "remotetopc", "remotepc", "remote utilities", "rescueassist", "screenconnect", "showmypc", "simplehelp", "splashtop", "supremo", "take control", "teamviewer", "thinfinity", "ultraviewer", "vnc", "wayk now", "x2go", "zoho assist")
$rmm = @("atera", "connectwise", "continuum", "datto", "GFI", "itsplatform", "itsupport247", "kaseya", "ninja", "optitune", "pulseway", "solarwinds")

 
# Combine our lists, if you create more lists be sure to add them here
$apps = $security + $remoteaccess + $rmm
 
# Allowlist array, you must use the full name for the matching to work!
$allowlist = @("Core", "Splashtop for RMM", "Splashtop Software Updater", "Splashtop Streamer", "Webroot SecureAnywhere", "Samsung Data Migration")
Write-Output "Allowed Apps at Root Level:" ($allowlist -join ", ")
$allowlist += ($orgallowlist -split ",").Trim()
Write-Output "Allowed Apps at Organization Level: $orgallowlist"
$allowlist += ($AssetAllowList -split ",").Trim()
Write-Output "Allowed Apps at Asset Level: $assetallowlist"

Write-Output "All Allowed Apps: $allowList"
 
# Grab the registry uninstall keys to search against (x86 and x64)
$software = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" | Get-ItemProperty
if ([Environment]::Is64BitOperatingSystem) {
    $software += Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" | Get-ItemProperty
}
 
# Clear the output variable so we don't get confused while testing
$output = ''
 
# Cycle through each app in the apps array searching for matches and store them
$output = foreach ($app in $apps) {
    @($software | Where-Object { $_.DisplayName -match "$app" -and $allowlist -notcontains $_.DisplayName } | Select-Object -ExpandProperty DisplayName)
}
 
# If we found something, report it
if ($output) {
    Write-Output "Apps Found:"
    $report = ($output | Select-Object -Unique) -join "`n"
    $report
    Rmm-Alert -Category 'Potentially Unwanted Applications' -Body "Apps Found: $report"
    exit 1
}
else {
    Write-Host "No Apps Found."
    Close-Rmm-Alert -Category "Potentially Unwanted Applications"
}