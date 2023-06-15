Import-Module $env:SyncroModule

$currentBuild = (Get-ComputerInfo).OsBuildNumber

if (($win10Build -eq $currentBuild) -or ($win11Build -eq $currentBuild)) {
    Write-Host "$pcName is running a current build: $currentBuild. Exiting"
    exit 0;
}

$emailBody = @"
Hi $contactName,
<br />
<br />
The computer named $pcName with a serial number of $serialNumber is currently out of date and needs to be updated. Please reply to this ticket so we can schedule a time to update your computer.
<br />
<br />
You received this alert because this machine was recently turned on.
<br />
Thank you,
<br />
SkyCamp Tech
"@

$ticket = (Create-Syncro-Ticket -Subject "$pcName - Update Required" -IssueType "Computer - Software" -Status "New").ticket

$ticketId = $ticket.id

Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketId -Subject "Contacted" -Body $emailBody -Hidden "false" -DoNotEmail "false"
Update-Syncro-Ticket -TicketIdOrNumber $ticketId -Status "Waiting on Customer"

Broadcast-Message -Title "[SkyCamp Tech] Update Required" -Message "This computer needs to be updated. Please reach out to support@skycamptech.com to schedule the update." -LogActivity "true"