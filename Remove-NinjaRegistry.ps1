Import-Module $env:SyncroModule

do {
    # Grab the registry uninstall keys to search against (x86 and x64)
    $software = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" | Get-ItemProperty
    if ([Environment]::Is64BitOperatingSystem) {
        $software += Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" | Get-ItemProperty
    }

    $regPath = ($software | Where-Object { $_.DisplayName -Contains "NinjaRMMAgent" }).PSPath

    Write-Host "Path: $regPath"

    if ($regPath) {
        Write-Host "Removing NinjaRMM Registry Path: $regPath"
        Remove-Item -Path $regPath -Force
        $regPath = "Ninja"
    }
    else {
        Write-Host "NinjaRMM Registry Path Not Found"
        $regPath = $null
        exit
    }
} while ($regPath)
 