#use this file to set the Unimus Properties file
Import-Module $env:SyncroModule

$configFile = "c:\programdata\unimus-core\unimus-core.properties"

if (!($unimusPort)) {
    #default port is 5509
    $unimusPort = "5509"
}

if (!($unimusAccessKey)) {
    Write-Host "No Access Key defined; exiting"
    exit 1
}

$unimusConfig = @"
# Core config file
# Unimus server IP or hostname
unimus.address=$unimusAddress

# Unimus server port
unimus.port=$unimusPort

# Access key used for connection authentication
unimus.access.key=$unimusAccessKey

# Defines each logging file size in MB, valid values are 1 ~ 2047
logging.file.size =

# Defines the number of maximum logging files, valid values are 2 ~ 2147483647
logging.file.count =
"@

try {
    Set-Content -Path $configFile -Value $unimusConfig -ErrorAction Stop
    Write-Host "Successfully Updated Config Unimus Config File"
    Restart-Service -Name "Unimus Core"
}
catch {
    Write-Host "Unable to update config file"
    Write-Warning $Error[0]
    exit 1
}