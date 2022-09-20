You'll need the ntrights.exe file found on the Windows Server 2003 Resource Kit Tools. We found it on the Internet Archive: https://web.archive.org/web/20200804140756/https://www.microsoft.com/en-us/download/details.aspx?id=17657. This file can be used with other scripts to change settings. More documentation here: https://ss64.com/nt/ntrights.html

Use this script to Enable or Disable a login on a machine. You can pass usernames as:
* _username_
* _domain\username_
* _azuread\username_

In Syncro, you'll need three fields:
* loginStatus (Dropdown - set default based on your preference)
1. Disabled
2. Enabled
* username (text field where you enter the username, including DOMAIN\ or AzureAD\ )
* reboot (Dropdown - set default based on your preference)
1. yes
2. no

We use this to quickly enable or disable a user that might have some issues but we aren't ready to wipe the machine or remove a TPM key protector
