#use this script to get a computer's warranty status
#only checking Dell right now
Import-Module $env:SyncroModule

if ($warrantyStatus -eq "Expired") {
    Write-Host "Warranty already expired ($warrantyEnd); exiting"
    exit 0
}

[datetime]$today = Get-Date -Format "yyyy-MM-dd"

if ($today -lt [datetime]$warrantyEnd) {
    Write-Host "Warranty still active ($warrantyEnd); exiting"
    exit 0
}

function Set-DateFormat {
    param(
        [Parameter()]
        [string]$fixDate
    )

    #Write-Host "Received $fixDate"
   
    $splitDate = $fixDate.Split("/")
    $year = $splitDate[2]
    #Write-Host $year
    $month = $splitDate[0]
    #Write-Host $month
    $day = $splitDate[1]
    #Write-Host $day

    if ([int]$month -lt 10) {
        [string]$stringMonth = "0" + $month
    }
    else {
        [string]$stringMonth = $month
    }

    if ([int]$day -lt 10) {
        [string]$stringDay = "0" + $day
    }
    else {
        [string]$stringDay = $day
    }

    $fixedDate = "$year-$stringMonth-$stringDay"

    Write-Host $fixedDate

    return $fixedDate

}

function Get-CarbonSystemsWarranty {
    $headers = @{
        "Ocp-Apim-Subscription-Key" = $carbonSystemsKey
        "Cache-Control"             = "no-cache"
    }

    $delay = Get-Random -Minimum 12 -Maximum 30

    Write-Host "Sleeping for $delay seconds for Carbon Systems query limit"
    Start-Sleep -Seconds $delay

    $uri = "https://apim.carbonsys.com/warranty/check?serialNumbers=$serviceTag"

    $result = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

    if ($($result.documentType) -match "not found") {
        $status = "NOT FOUND"
        $startDate = "1900-01-01"
        $endDate = "1900-01-01"
        Rmm-Alert -Category "Warranty" -Body "No warranty found for $env:ComputerName"
    }
    else {
        $endDate = Set-DateFormat -fixDate $($result.endDate)
        $startDate = Set-DateFormat -fixDate $($result.startDate)

        if ($result.status -eq "Active") {
            $status = $result.description
        }
        else {
            $status = $result.status
        }
    }

    Set-Asset-Field -Name "ShipDate" -Value $startDate
    Set-Asset-Field -Name "Warranty" -Value $status
    Set-Asset-Field -Name "WarrantyDate" -Value $endDate

    Write-Host "Ship Date: $startDate"
    Write-Host "End Date: $endDate"
    Write-Host "Warranty: $status"

}

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

    if (!($entitlements)) {
        #apparently some machines have no warranty
        $warrantyType = "No Warranty"
        Write-Host "This machine does not have any warranty entitlements"
    }
    else {

        #downside to this method is that it's going to pick the latest warranty, even if there's an active ProSupport with a nearer end date
        $latest = $entitlements | Sort-Object endDate | Select-Object -Last 1

        $endDate = ($latest.endDate).Split("T")[0]
        $serviceLevel = $latest.serviceLevelGroup
        $serviceDescription = $latest.serviceLevelDescription

        Write-Host "Warranty Info for $serviceTag"
        Write-Host "Service Level: $serviceLevel"
        Write-Host "Service Description: $ServiceDescription"
        Write-Host "Ship Date: $shipDate"
        Write-Host "End Date: $endDate"

        $warrantyType = switch ($serviceLevel) {
            5 { "Onsite After Remote Diag" }
            8 { "ProSupport" }
            11 { "Complete Care" }
            Default { "Unknown" }
        }

        if ($endDate -lt $today) {
            $warrantyType = "Expired"
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
    }
    
    Set-Asset-Field -Name "Warranty" -Value $warrantyType
    Set-Asset-Field -Name "WarrantyDate" -Value $endDate
        
   
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


if ($pcMfg -match "Dell Inc.") {
    Get-DellWarranty
}
elseif ($pcMfg -match "Carbon Systems") {
    Get-CarbonSystemsWarranty
}
else {
    Write-Host "Machine is not a Dell or Carbon Systems computer"
    exit 0
}