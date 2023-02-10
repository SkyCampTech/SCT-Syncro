Import-Module $env:SyncroModule

$workingPath = "$env:ProgramData\SkyCampTech\temp"
$heifPackage = Join-Path -Path $workingPath -ChildPath "Microsoft.HEIFImageExtension_1.0.50272.0_x64__8wekyb3d8bbwe.Appx"

function Clear-SkyCampTemp {
    Get-ChildItem -Path $workingPath -Include * | Remove-Item -Recurse    
}

Add-AppxPackage $heifPackage

$result = Get-AppxPackage | Where-Object { $_.Name -like "*heif*" }

if ($result.name -eq "Microsoft.HEIFImageExtension" -and $result.Status -eq "OK") {
    Log-Activity -Message "Installed Microsoft HEIF Image Extension"
    Clear-SkyCampTemp
    exit 0
}
else {
    RMM-Alert -Category "Applications" -Body "Unable to install Microsoft HEIF Image Extension Automatically; Send user Store Link to install manually: https://apps.microsoft.com/store/detail/heif-image-extensions/9PMMSR1CGPWG?hl=en-us&gl=us&activetab=pivot%3Aoverviewtab"
    Clear-SkyCampTemp
    exit 1
}
