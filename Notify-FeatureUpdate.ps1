Import-Module $env:SyncroModule

<#
*This script will be run against machines that have not been online in a while or are otherwise difficult to catch online to run a feature update. Obviously won't run until they actually do come online
*It will open a ticket and email the user letting them know they can reply to the ticket to schedule a time to do the install
*Ticket number will be noted as an Asset Custom Field so we can create a Saved Search to find machines that have had notices sent
#>

#check if Windows 10; exit if not
$OS = (Get-CimInstance Win32_OperatingSystem).caption
if (-Not ($OS -like "Microsoft Windows 10*")) {
    Write-Output "This machine does not have Windows 10 installed. Exiting."
    exit
}

#check to see if the Asset Contact Email is set; if not, set to POC (Customer Email and First)
if (!($contactEmail)) {
    $contactEmail = $primarycontactEmail
    $contactFirstName = $primaryContactFirstName
}

#get the last user so we can incldue that in the email body; helpful if no Contact is assigned to the asset in syncro
$lastUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username

$ticketSubject = "$env:ComputerName - Windows Feature Update"
$ticketBody = "Alert $contactEmail. We need to schedule a Windows 10 Feature Update on $env:ComputerName since we have not been able to catch it online overnight."

$emailBody = @"
Hi $contactFirstName,

There is an important update we need to install on your computer. We can schedule this install during the day, or we can schedule it to run overnight as long as your computer is connected to the internet and power. Please note, the download for this update is large, so we'll want to run this update when you're connected to fast internet, and ideally not on a mobile hotspot that may have metered usage.

The download and install can take up to 2 hours and your computer will reboot. Please make sure to save any open work.

Please reply to this ticket and let us know when we are able to run this update on your machine.

Computer Name: $env:ComputerName
Serial Number: $assetSerial
Last Logged In User: $lastUser

Thank you for your help in completing this important update.

Have a great day!
"@

#create the ticket
$newTicket = Create-Syncro-Ticket -Subject $ticketSubject -IssueType "Windows Feature Update" -Status "Waiting on Customer"

#set the ticket number variable so it's easier to work with moving forward
$ticketNumber = $newTicket.ticket.number

#add initial comment to ticket
Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketNumber -Subject "Issue" -Body $ticketBody -Hidden "False" -DoNotEmail "True"

#add comment that emails the user
Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketNumber -Subject "Update" -Body $emailBody -Hidden "False" -DoNotEmail "False"

Log-Activity -Message "Alerted $contactEmail. Feature Update Required. Ticket #$ticketNumber"

#log the ticket number to the asset. helpful for creating an Asset Search based on devices that have received this contact. We clear this field in the Install-FeatureUpdate script
Set-Asset-Field -Name "Feature Update Ticket" -Value $ticketNumber