#use this script to enable remote desktop on a computer
Import-Module $env:SyncroModule

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Log-Activity -Message "Enabled Remote Desktop via script"