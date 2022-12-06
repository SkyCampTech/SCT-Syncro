#use this script to get display info on a machine
#helpful for determining what video adapter and monitor(s) in use
Import-Module $env:SyncroModule

$outputFile = "$env:ProgramData\SkyCampTech\temp\dxoutput.xml"

dxdiag /x $outputFile | Out-Null

[xml]$xmldata = get-content $outputFile

$xmldata.DxDiag.DisplayDevices.DisplayDevice | ForEach-Object {
    #$name = $_.CardName
    #$manu = $_.Manufacturer
    #$chip = $_.ChipType
    $type = $_.OutputType
    $model = $_.MonitorModel
    #$version = $_.DriverVersion
    #$outputDetails = "Detected Monitor - $model; Output - $type; Chip - $chip"
    $outputDetails = $_
    Write-Host $outputDetails
    #Log-Activity -Message $outputDetails
}

#Upload-File -FilePath $outputFile
Remove-Item -Path $outputFile -Force -Confirm:$false