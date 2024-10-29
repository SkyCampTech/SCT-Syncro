Import-Module $env:SyncroModule
Import-Module -Name "sqlps"

function Remove-OldBackups {
    param (
        $purgeAge = 30
    )
    Write-Host "Removing backup files older than $((Get-Date).AddDays(-$purgeAge))"
    Get-ChildItem -Path $outputPath -File | Where-Object CreationTime -lt (Get-Date).AddDays(-$purgeAge) | Remove-Item -Force

}

function Get-BackupFile {
    If (Test-Path $outputFile) {
        Write-Host "Backup saved successfully at $outputFile"
    }
    else {
        RMM-Alert -Category "Backups" -AlertBody "SQL Database Backup not found at $outputFile; investigate"
        exit 1
    }
}

#convert the provided password from Syncro runtime to a secure string
$securePassword = ConvertTo-SecureString -AsPlainText $sqlPassword -Force

#create the Credential Object for the backups
$sqlCredentials = New-Object System.Management.Automation.PSCredential ($sqlUsername, $securePassword)

[string]$date = Get-Date -Format "yyyy-MM-dd"

$outputFile = $outputPath + "\" + $databaseName + "_" + $date + ".bak"

Backup-SqlDatabase -ServerInstance $serverInstance -Database $databaseName -BackupFile $outputFile -Credential $sqlCredentials

Start-Sleep -Seconds 10

Get-BackupFile

if ($purgeBackups -match "yes") {
    Remove-OldBackups -purgeAge $purgeAge
}