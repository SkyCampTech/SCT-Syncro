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

$uninstalledApps = @()

foreach ($app in $appsToRemove) {
    Write-Host "Trying to remove $app"

    if (!(Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app })) {
        Write-Host "$app not provisioned on this system. Checking to see if it's installed"
        try {
            Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction Stop
            Write-Host "Removed $app"
            $uninstalledApps += $app
        }
        catch {
            Write-Host "$app not installed for any users"
        }
    }

    else {
        try {
            Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        }
        catch {
            #nothing
        }

        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } | Remove-AppxProvisionedPackage -Online

        $uninstalledApps += $app
    }
}

Write-Host "`n"
Write-Host "Uninstalled Apps `n"
foreach ($app in $uninstalledApps) {
    Write-Host $app
}