#use this script to remove default Windows apps
#this will get a default list from github, but if you set a link to a text file in the Customer Custom Field "Windows App Removal List", it will reference that instead
Import-Module $env:SyncroModule

$appsToRemove = (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/SkyCampTech/SCT-Syncro/main/Remove-WindowsApps/Default-Apps.txt").Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)

if (!($customerAppRemovalList)) {
    Write-Host "No Customer App Removal List defined; using default list"
}
else {
    $appsToRemove = (Invoke-RestMethod -Uri $customerAppRemovalList).Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)
}

foreach ($app in $appsToRemove) {
    Write-Host "Trying to remove $app"

    if (!(Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app })) {
        Write-Host "$app not installed on this system. Skipping"
    }

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } | Remove-AppxProvisionedPackage -Online
}