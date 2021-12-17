<#
-use this script to get disk usage for a device
-scans root and Current User profile based on dropdown selection at runtime
-optionally takes a specific path
#>

<#
TODO:
-scan c:\temp for wiztree PNG files and delete before starting
-cleanup wiztree3 config file after completion
#>

Import-Module $env:SyncroModule

$wiztreePath = 'C:\temp\WizTree64.exe'

function New-WiztreeScan {
    param (
        [Parameter(Mandatory)]
        [string]$scanPath
    )
    Write-Host "Scanning $scanPath with WizTree"
    $outFile = "c:\temp\wiztree-scan_%d%t.png"
    $scanArgs = @"
"$scanPath" /treemapimagefile="$outfile"
"@
    #Log-Activity -Message "Scanning $scanPath with WizTree"
    Write-Host "$scanArgs"
    #Scan the path received
    Start-Process -FilePath $wiztreePath -ArgumentList $scanArgs

    $imageFile = (Get-ChildItem -Path "c:\temp\" | Where-Object { $_.Name -like "wiztree-scan*" }).Name
    Write-Host "Image File: $imageFile"
    $imagePath = Join-Path -Path "c:\temp" -ChildPath $imageFile
    Write-Host "Image Path: $imagePath"

    #upload the file to the syncro Asset
    Write-Host "Uploading $imagePath to Syncro Asset"
    Upload-File -FilePath $imagePath

    #delete the file
    Write-Host "Deleting $imagePath"
    Remove-Item -Path $imagePath
}

if ($scanRoot -contains "yes") {
    New-WiztreeScan -scanPath "$env:SystemDrive"
}

if ($scanUserFolder -contains "yes") {
    $currentUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username
    $userFolder = Join-Path -Path "C:\Users\" -ChildPath $currentUser.Split("\")[1]
    New-WiztreeScan -scanPath $userFolder
}

if ($scanCustomFolder) {
    New-WiztreeScan -scanPath $scanCustomFolder
}

#remove WizTree now that we're done
#Remove-Item $wiztreePath -Force