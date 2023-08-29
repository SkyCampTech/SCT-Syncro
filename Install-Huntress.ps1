#installs the Huntress agent
#expects the Account Key and Organization Key to be passed as variables

if (!($orgKey)) {
    Rmm-Alert -Category "Huntress" -Body "No Huntress Organization Key specified for $companyName; set the Customer Custom Field and run the script again"
    exit 1
}

$huntressDownload = "https://huntress.io/download/" + $accountKey
$huntressInstaller = "$env:ProgramData\SkyCampTech\Temp\huntress.exe"

Invoke-RestMethod -Uri $huntressDownload -OutFile $huntressInstaller

Start-Process -FilePath $huntressInstaller -ArgumentList "/ACCT_KEY=$accountKey /ORG_KEY=$orgKey /S" -Wait

$huntressExe = "C:\Program Files\Huntress\HuntressAgent.exe"

if (Test-Path -path $huntressExe) {
    Write-Host "Huntress Installed Successfully"
    Remove-Item $huntressInstaller
    exit 0
}
else {
    Write-Host "Huntress not detected"
    exit 1
}