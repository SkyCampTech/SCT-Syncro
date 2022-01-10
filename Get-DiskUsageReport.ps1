<#
-use this script to get disk usage for a device
-scans root and Current User profile based on dropdown selection at runtime
-optionally takes a specific path
#>

<#
TODO:
-update the $outfile check to see if wiztree process is running. if so, sleep a little longer
#>

Import-Module $env:SyncroModule

#determine if user is logged in
$currentUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username
if (!($currentUser)) {
    Write-Host "No user logged in; scan root folder instead"
    $scanRoot = "yes"
    $scanUserFolder = "no"
}


$wiztreePath = 'C:\temp\WizTree64.exe'
#$wiztreeINI = 'C:\temp\WizTree3.ini'
function New-WiztreeScan {
    param (
        [Parameter(Mandatory)]
        [string]$scanPath
    )

    #check for existing wiztree scan PNGs and delete them
    $existingPNGs = (Get-ChildItem -Path 'C:\temp' | Where-Object { $_.Name -like "wiztree-scan*" }).FullName
    foreach ($item in $existingPNGs) {
        Remove-Item -Path $item -Force
    }


    Write-Host "Scanning $scanPath with WizTree"
    $outFile = "c:\temp\wiztree-scan_%d%t.png"
    $scanArgs = @"
"$scanPath" /treemapimagefile="$outfile"
"@
    #Log-Activity -Message "Scanning $scanPath with WizTree"
    Write-Host "$scanArgs"
    #Scan the path received
    Start-Process -FilePath $wiztreePath -ArgumentList $scanArgs
    
    #sleep for 30 seonds while the scan runs
    Start-Sleep -Seconds 30

    $outFile = (Get-ChildItem -Path 'C:\temp' | Where-Object { $_.Name -like "wiztree-scan*" }).FullName

    if (!($outFile)) {
        #scan may still be running; sleep for another 30 secods
        Start-Sleep -Seconds 30
    }

    $outFile = (Get-ChildItem -Path 'C:\temp' | Where-Object { $_.Name -like "wiztree-scan*" }).FullName

    if (!($outFile)) {
        Write-Host "FIle not found; exiting"
        exit 1;
    }

    #upload the file to the syncro Asset
    Write-Host "Uploading $outFile to Syncro Asset"
    Upload-File -FilePath $outFile

    #delete the file
    Write-Host "Deleting $outFile"
    Remove-Item -Path $outFile
}

if ($scanUserFolder -contains "yes") {
    $userFolder = Join-Path -Path "C:\Users\" -ChildPath $currentUser.Split("\")[1]
    New-WiztreeScan -scanPath $userFolder

}

if ($scanRoot -contains "yes") {
    New-WiztreeScan -scanPath "$env:SystemDrive"
}

if ($scanCustomFolder) {
    New-WiztreeScan -scanPath $scanCustomFolder
}

#remove WizTree now that we're done
Remove-Item $wiztreePath -Force
#Remove-Item $wiztreeINI -Force