Import-Module $env:SyncroModule

$MachineModel = Get-WMIObject -class Win32_ComputerSystem
if ($MachineModel["Manufacturer"] -eq "Dell inc.") {
    #If check for dell-commmand
    $choco = "$env:ProgramData\chocolatey\choco.exe"

    #Try to upgrade but if that fails do an install
    try {
        Start-Process $choco -ArgumentList "upgrade DellCommandUpdate -y" -Wait
        Write-Host "Dell Command was updated"
    }
    catch {
        Start-Process $choco -ArgumentList "install DellCommandUpdate -y" -Wait -ErrorAction SilentlyContinue
        Write-Host "Dell Command was installed"
    }

    $executablePath = "$env:Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
    $tempFolder = "C:\temp"

    Invoke-Expression -Command "C:\'Program Files (x86)'\Dell\CommandUpdate\dcu-cli.exe /scan -report=$tempFolder"
    # Start-Process -FilePath "dcu-cli.exe" -WorkingDirectory "C:\Program Files (x86)\Dell\CommandUpdate" -ArgumentList "/scan -report=$tempFolder" -Wait
    write-host "Checking for results."

    if (Test-Path -path "$tempFolder\DCUApplicableUpdates.xml") {
        [xml]$XMLReport = get-content "$tempFolder\DCUApplicableUpdates.xml"
        $availableUpdates = $XMLReport.updates.update
     
        $BIOSUpdates = ($availableUpdates | Where-Object { $_.type -eq "BIOS" }).name.Count
        $ApplicationUpdates = ($availableUpdates | Where-Object { $_.type -eq "Application" }).name.Count
        $DriverUpdates = ($availableUpdates | Where-Object { $_.type -eq "Driver" }).name.Count
        $FirmwareUpdates = ($availableUpdates | Where-Object { $_.type -eq "Firmware" }).name.Count
        $OtherUpdates = ($availableUpdates | Where-Object { $_.type -eq "Other" }).name.Count
        $PatchUpdates = ($availableUpdates | Where-Object { $_.type -eq "Patch" }).name.Count
        $UtilityUpdates = ($availableUpdates | Where-Object { $_.type -eq "Utility" }).name.Count
        $UrgentUpdates = ($availableUpdates | Where-Object { $_.Urgency -eq "Urgent" }).name.Count
    
        #Print Results
        write-host "Bios Updates: $BIOSUpdates"
        write-host "Application Updates: $ApplicationUpdates"
        write-host "Driver Updates: $DriverUpdates"
        write-host "Firmware Updates: $FirmwareUpdates"
        write-host "Other Updates: $OtherUpdates"
        write-host "Patch Updates: $PatchUpdates"
        write-host "Utility Updates: $UtilityUpdates"
        write-host "Urgent Updates: $UrgentUpdates"
    }

    $Result = $BIOSUpdates + $ApplicationUpdates + $DriverUpdates + $FirmwareUpdates + $OtherUpdates + $PatchUpdates + $UtilityUpdates + $UrgentUpdates
    write-host "Total Updates Available: $Result"
    if ($Result -gt 0) {

        
        remove-item "$tempFolder\DCUApplicableUpdates.xml" -Force #Remove XML file
        write-host "Updating Drivers! This may take a while..."
        Invoke-Expression -Command "C:\'Program Files (x86)'\Dell\CommandUpdate\dcu-cli.exe /applyUpdates -autoSuspendBitLocker=enable -reboot=$($Reboot) -outputLog=$tempFolder\updateOutput.log"
        Start-Sleep -s 60
        Get-Content -Path '$tempFolder\updateOutput.log'
        Log-Activity -Message "Dell Command Updates ran."
        $OPLogExists = Test-Path "$tempFolder\updateOutput.log"
        if ($OPLogExists -eq $true) {
            remove-item "$tempFolder\updateOutput.log" -Force
        }
        write-host "Done."
    }
    else {
        Write-Host "No updates are available to install."
    }
}
else {
    Write-Host $MachineModel " is not a dell product and can't install Dell Command."
    exit 1
}