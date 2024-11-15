#gets the BIOS version and adds it to a Asset Custom Field in Syncro
#planning to add a "desired version" hashtable for common models we have so it can alert on older versions
Import-Module $env:SyncroModule

$biosVersion = (Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion

Set-Asset-Field -Name "BIOS Version" -Value $biosVersion

$desiredVersion = @{
    "Iridium 14"        = "N.1.10CAR01"
    "Iridium 16"        = "N.1.10CAR01"
    "OptiPlex 3080"     = "2.26.0"
    "OptiPlex 7080"     = "1.29.0"
    "OptiPlex 9030 AIO" = "A21"    
}