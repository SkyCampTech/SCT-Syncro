Import-Module $env:SyncroModule

$tempPath = "$env:ProgramData\skycamptech\temp\*"
try {
    remove-Item -Path $tempPath -Force -Recurse -Confirm:$false
    Write-Host "The Items in the temp folder were deleted"
    Log-Activity -Message "The Items in the temp folder were deleted"
}
catch {
    Write-Host "ERROR: The temp folder items were not deleted" -ForegroundColor red
}
