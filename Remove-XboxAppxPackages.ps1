Import-Module $env:SyncroModule

Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -match "xbox" } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }

$xboxPackages = Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -match "xbox" }

if ($xboxPackages) {
    Rmm-Alert -Category "Maintenance" - Body "Xbox packages still installed on $env:ComputerName"
    exit 1
}
else {
    Log-Activity -Message "Removed Xbox AppX packages" - EventName "Maintenance"
}