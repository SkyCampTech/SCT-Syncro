#script checks if the Target Release Version is set in registry and removes it
#should allow Feature Updates and next OS version (if supported) to show up in Windows Update

Import-Module $env:SyncroModule

try {
    $properties = Get-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ErrorAction Stop
    foreach ($prop in $properties) {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name $prop.Property
        Log-Activity -Message "Removed Target Release Version in registry" -EventName "Maintenance"
    }
}
catch {
    Write-Host "No Target Release Version set in HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    exit
}