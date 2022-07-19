Import-Module $env:SyncroModule;

choco install revouninstallerpro -a;
$revoPath = "C:\Program Files\VS Revo Group\Revo Uninstaller Pro\RevoCmd.exe";


start-process -FilePath $revoPath -ArgumentList "/m $Program /u" -Wait;
