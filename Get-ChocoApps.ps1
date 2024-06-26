Import-Module $env:SyncroModule

#get list of apps
$apps = Invoke-Expression -Command "choco list --local-only"

#do it a second time, just in case; first run can throw in some adds for Pro/Business that we'd have to filter out
[array]$apps = @()
$apps = Invoke-Expression -Command "choco list --local-only -r --idonly"
#filter out the chocolatey extensions and MS KBs that are installed by choco
#$apps = $apps | Where-Object { $_ -notlike "chocolatey*" -and $_ -notlike "KB*" }

#[array]$appList = @()

#remove version numbers and first/last lines
#for ($i = 0; $i -lt $apps.count - 1; $i++) {
#    $appList += $apps[$i].Split(" ")[0] + "`r`n"
#}

Write-Output $apps

#save output to Asset Field
Set-Asset-Field -Name "Choco Apps" -Value $apps