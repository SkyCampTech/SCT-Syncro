<#
-use this script to get disk usage for a device
-scans root and Current User profile based on dropdown selection at runtime
-optionally takes a specific path
#>

Import-Module $env:SyncroModule

$wiztreePath = 'C:\temp\WizTree64.exe'

function New-WiztreeScan {
    param (
        [Parameter(Mandatory)]
        [string]$scanPath
    )
    Write-Host "Scanning $scanPath with WizTree"
    $dateTime = (Get-Date -Format "yyyy-MM-dd_HH:mm").ToString()
    $outFile = "c::\temp\WizTree_" + $dateTime + ".png"
    $scanArgs = "$scanPath /treemapimagefile=$outfile"

    Log-Activity -Message "Scanning $scanPath with WizTree"
    
    #Scan the path received
    Start-Process -FilePath $wiztreePath -ArgumentList $scanArgs

    #upload the file to the syncro Asset
    Upload-File -FilePath $outFile

    #delete the file
    Remove-Item -Path $outFile
}

if ($scanRoot -contains "yes") {
    New-WiztreeScan -scanPath "$env:SystemDrive"
}

if ($scanUserFolder -contains "yes") {
    $currentUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username
    $userFolder = $currentUser.Split("\")[1]
    New-WiztreeScan -scanPath $userFolder
}

if ($scanCustomFolder) {
    New-WiztreeScan -scanPath $scanCustomFolder
}

#remove WizTree now that we're done
Remove-Item $wiztreePath -Force