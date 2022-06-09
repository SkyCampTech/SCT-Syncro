Import-Module $env:SyncroModule

$installerPath = "$env:ProgramData\skycamptech\temp\*"
try {
    remove-Item -Path $installerPath -Force -Recurse -Confirm:$false
    Write-Host "The Items in the temp folder were deleted"
    Log-Activity -Message "The Items in the temp folder were deleted"
}
catch {
    Write-Host "ERROR: The temp folder items were not deleted" -ForegroundColor red
}
