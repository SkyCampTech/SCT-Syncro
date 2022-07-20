Import-Module $env:SyncroModule;

$revoPath = "C:\ProgramData\SkyCampTech\bin\Revo\x64";

$ProgramLocation = Invoke-Expression -Command "$($revoPath+ "\RevoCmd.exe") /m '$Program' /i"
Write-Host "Program: $($ProgramLocation[0])"
Write-Host "Program Location: $($ProgramLocation[1])"

stop-process -Name "*$Program*" -Force

$ProgramLocation = start-process -FilePath "$($revoPath+"\RevoUnPro.exe")" -ArgumentList "/mu $($ProgramLocation[0]) /Path $($ProgramLocation[1]) /mode advanced /64" -Wait;
if ($ProgramLocation[0] -eq (Invoke-Expression -Command "$($revoPath+ "\RevoCmd.exe") /m '$Program' /i")[0]) {
    Write-Host "Program failed to delete."
    exit 1
}
else {
    Write-Host "Program was deleted"
}