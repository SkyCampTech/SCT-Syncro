#use this script to install Cricut Design Space: https://design.cricut.com/
Import-Module $env:SyncroModule


#download installer
Start-BitsTransfer -Source "https://s3.us-west-001.backblazeb2.com/SCT-INSTALLERS/CricutDesignSpace-Install-v8.35.48.exe" -Destination "$env:ProgramData\SkycampTech\temp\cricut.exe"

#install Cricut
Start-Process -FilePath "$env:ProgramData\SkyCampTech\temp\cricut.exe" -ArgumentList "/S" -Wait

#Check if Cricut is installed
