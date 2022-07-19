Import-Module $env:SyncroModule -WarningAction SilentlyContinue

$uvPath = "c:\programdata\skycamptech\bin\UninstallView.exe"

#  Uses https://www.nirsoft.net/utils/uninstall_view.html
#  Nirsoft UninstallView utitilty

Start-Process -FilePath $uvPath -ArgumentList "/quninstallwildcard '$UninstallProgram' 1"

#  Quietly uninstall the specified software (Without displaying user interface). 
#  You can specify wildcard in the display name, in order to use the same command to uninstall different versions of a software, for example: 
#       UninstallView.exe /quninstallwildcard "Mozilla Firefox*"

#  By default, this command can uninstall multiple items that match the wildcard. 
#       You can specify the maximum number of items to uninstall in the {Max Items} parameter, Currenlty set to 5
#  for example: Below would uninstall Mozilla Firefox and possibly up to 5 versions that start with the same name.
#    UninstallView.exe /quninstallwildcard "Mozilla Firefox*" 5

Start-Sleep 60
