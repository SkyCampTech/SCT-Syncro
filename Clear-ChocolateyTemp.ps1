Import-Module $env:SyncroModule

$chocoTempPath = "C:\Windows\Temp\chocolatey"

Get-ChildItem -Path $chocoTempPath -Recurse | Remove-Item -Force -Confirm:$false

Log-Activity -Message "Cleared Chocolatey temp folder"