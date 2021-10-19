<#
Use this script to create new assets in Hudu. Run it from Syncro as a setup script on the device

Required Variables in Syncro:
$HuduKey - Password variable. This is your Hudu API key authorized to create new assets
$serial - Platform Variable - asset_serial_v2
$operatingSystem - Platform Variable - asset_custom_field_os
$pcModel - Platform Variable - asset_custom_field_model
$pcMake - Platform Variable - asset_custom_field_manufacturer
$pcName - Platform Variable - asset_name
$HuduCompanyID - Platform Variable - create a customer custom field and assign their Hudu Company ID. We populate this automatically from our Master Client List\
  which we use to push any changes out from one central location. We maintain this in SharePoint and it populates Name, Phone, Address, etc into Syncro and Hudu\
  and maintains Syncro and Hudu company IDs, Office 365 tenant IDs, etc for larger management. But you could easily populate this manually for your companies.\
  This can be updated to return the Hudu Company ID and write it to an RMM alert or elsewhere, but right now, we can't write to Customer Custom Fields from Syncro.\
  The Update-HuduAsset.ps1 file will throw an RMM alert if a device is missing an associated Customer Custom Field for the Hudu Company ID.
  
 Screenshot of script variables in Syncro: https://i.imgur.com/Wq0juez.png
 
 You'll need to swap out <HuduDomain> below or set up a script variable for it
 #>

Import-Module $env:SyncroModule

$HuduURI = "https://<HuduDomain>/api/v1/companies/$HuduCompanyID/assets"
$headers = @{
    "x-api-key" = $HuduKey
}

$searchURI = "https://<HuduDomain>/api/v1/assets?primary_serial=$serial"

#get a list of assets that match the current device's serial number
$assets = (Invoke-RestMethod -Uri $searchURI -Method Get -Headers $headers).assets
$ids = $assets.id

Write-Host $ids.count

#this will give you an RMM alert with conflicting IDs. This may occur if you're refreshing a machine or a machine got moved to a different company
if ($ids.count -gt 1) {
    Rmm-Alert -Category "Hudu-Alert" -Body "Duplicate IDs in Hudu for $pcName - $ids"
    exit;
}

#if there is an existing ID, it will just exit since it doesn't need to create a new one
elseif ($ids.count -gt 0) {
    Write-Host "Device already exists with Asset ID $ids; exiting"
    exit;
}

#assuming no existing matching assets exist, create it
elseif (!($assets)) {
#collect any info here that you want to submit. Make sure you have a corresponding field in your Hudu asset and you define it in the body below
    [int]$driveSize = (Get-Volume -DriveLetter 'C').size / 1GB
    [int]$ram = (Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $osDrive = $env:SystemDrive
    $key = (Get-BitLockerVolume -MountPoint $osDrive).KeyProtector.RecoveryPassword

#this is what gets submitted to Hudu. Adjust the asset_layout_id as appropriate. If you create any additional custom fields associated with this asset in Hudu,
#those would all go down under Custom_Fields. All spaces in your Hudu asset need to be replaced with underscores
    $body = @"
    {
        "asset": {
            "asset_layout_id": 1,
            "primary_serial": "$serial",
            "name": "$pcName",
            "custom_fields": [{
                "manufacturer": "$pcMake",
                "model":"$pcModel",
                "operating_system":"$operatingSystem",
                "memory":"$ram",
                "hard_drive_size":"$driveSize",
                "service_tag":"$serial",
                "bitlocker_recovery_key":"$key"
            }]
        }
    }
"@

#this is where the data gets sent to Hudu. Data will be sent back in $response, which we can use to populate custom fields in Syncro
    $response = (Invoke-RestMethod -Uri $HuduURI -Method Post -Headers $headers -Body $body -ContentType 'application/json').asset

#The Hudu asset ID returned from Hudu
    $HuduAssetID = $response.id

#The direct URL to the asset in Hudu
    $HuduAssetLink = $response.url

#Set the Asset fields in Hudu
    Set-Asset-Field -Name "Hudu Asset ID" -Value $HuduAssetID
    Set-Asset-Field -Name "Hudu Asset Link" -Value $HuduAssetLink
}
