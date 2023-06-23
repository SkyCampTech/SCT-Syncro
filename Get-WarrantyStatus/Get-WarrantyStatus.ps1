#use this script to get a computer's warranty status
#only checking Dell right now
Import-Module $env:SyncroModule

function Get-DellWarranty {
    #this is a list of Service Level Codes that may be returned that are not related to hardware warranties
    #taken from https://github.com/KelvinTegelaar/PowerShellWarrantyReports/blob/master/private/Get-DellWarranty.ps1
    #added KK since that's the "Keep your Hard Drive" one and was throwing off results
    $slcIgnoreList = @("D", "DL", "PJ", "PR", "KK")

    $today = Get-Date -Format yyyy-MM-dd
    
    $token = Get-DellAccessToken

    $uri = "https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements?servicetags=$serviceTag"

    $headers = @{
        Authorization = "Bearer $token"  
    }

    $warrantyInfo = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

    if ($warrantyInfo.invalid -eq $true) {
        Write-Host "Unable to get warranty info for $serviceTag; invalid service tag"
        exit 1
    }

    $entitlements = $warrantyInfo.entitlements | Where-Object { $_.serviceLevelCode -notin $slcIgnoreList }
    
    $shipDate = ($warrantyInfo.shipDate).Split("T")[0]
    Set-Asset-Field -Name "ShipDate" -Value $shipDate

    #downside to this method is that it's going to pick the latest warranty, even if there's an active ProSupport with a nearer end date
    $latest = $entitlements | Sort-Object endDate | Select-Object -Last 1

    $endDate = ($latest.endDate).Split("T")[0]
    $serviceLevel = $latest.serviceLevelGroup
    $serviceDescription = $latest.serviceLevelDescription
    $status = if ($endDate -lt $today) { "Expired" } else { $endDate }

    Write-Host "Warranty Info for $serviceTag"
    Write-Host "Service Level: $serviceLevel"
    Write-Host "Service Description: $ServiceDescription"
    Write-Host "Ship Date: $shipDate"
    Write-Host "End Date: $endDate"

    $warrantyType = switch ($serviceLevel) {
        5 { "Onsite After Remote Diag" }
        8 { "ProSupport" }
        Default { "Unknown" }
    }

    if ($warrantyType -eq "Unknown") {
        $body = @"
Unknown Warranty Type
Service Level: $serviceLevel
Description: $serviceDescription
Update the Get-WarrantyStatus script to include this warranty type and re-run
"@
        Rmm-Alert -Category "Warranty" -Body $body
    }

    
    Set-Asset-Field -Name "Warranty" -Value $warrantyType
    Set-Asset-Field -Name "WarrantyDate" -Value $status
        
   
}

function Get-DellAccessToken {
    #client_id and client_secret must be passed as Syncro variables in current implementation
    $body = @{
        client_id     = $clientId
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    $uri = "https://apigtwb2c.us.dell.com/auth/oauth/v2/token"

    $contentType = "application/x-www-form-urlencoded"

    $accessToken = (Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType $contentType).access_token

    if (!($accessToken)) {
        Write-Host "Unable to get Access Token"
        exit 1
    }

    return $accessToken
}

#exit program if computer is not a Dell
if ($pcMfg -notmatch "Dell") {
    Write-Host "Computer is not a Dell; exiting"
    exit 0
}

Get-DellWarranty