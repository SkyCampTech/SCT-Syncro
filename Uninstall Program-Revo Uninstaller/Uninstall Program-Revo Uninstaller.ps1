Import-Module $env:SyncroModule;

choco install revouninstallerpro -a;
$revoPath = "C:\ProgramData\SkyCampTech\bin\Revo\x64";

$ProgramLocation = Invoke-Expression -Command "($revoPath)\RevoCmd.exe /m 'Mozilla*' /i"
Write-Host "Program: $ProgramLocation[0]"
Write-Host "Program Location: $ProgramLocation[1]"
$ProgramLocation = start-process -FilePath "($revoPath)\RevoUnPro.exe" -ArgumentList "/mu $ProgramLocation[0] /Path $ProgramLocation[1] /mode advanced /64" -Wait;
Write-Host "Program was deleted"