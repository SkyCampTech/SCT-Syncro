Import-Module $env:SyncroModule
#to do: check for croc already installed; if not, install via chocolatey

$croc = "$env:ProgramFiles\RepairTech\Syncro\kabuto_app_manager\bin\croc.exe"

$outputPath = "C:\ProgramData\SkyCampTech\Temp"

Set-Location $outputPath

Start-Process -FilePath $croc -ArgumentList "--yes $codePhrase"