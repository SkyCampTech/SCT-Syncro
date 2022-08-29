#used to upgrade Unimus Core to the latest version
#keeps existing settings

Import-Module $env:SyncroModule

$installerUrl = "https://download.unimus.net/unimus-core/-%20Latest/Installer-Core.exe"
$installerPath = "$env:ProgramData\SKyCampTech\temp\installer-core.exe"

Start-BitsTransfer -Source $installerUrl -Destination $installerPath

Start-Process $installerPath -ArgumentList "-u" -Wait

Log-Activity -Message "Installed latest version of Unimus Core"

Remove-Item -Path $installerPath -Force