<#
Use this script to perform the initial computer setup. 

This is a work-in-progress.

To-Dos:
-function for each step
#>

Import-Module $env:SyncroModule

Display-Alert -Message "Computer Setup in Progress. Please do not reboot"

#Step 1 - Disable Bitlocker; needed for bios updates
Disable-BitLocker -MountPoint $env:SystemDrive

#Step 2 - Install all 