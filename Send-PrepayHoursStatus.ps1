Import-Module $env:SyncroModule

#can comment out the next 4 lines once it's running properly, but this will show you what platfor variables it's pulling at runtime
Write-Host "Platform Variables Pulled on this run: `n"
Write-Host "customerName: $customerName `n"
Write-Host "customerEmail: $customerEmail `n"
Write-Host "prepayHours: $prepayHours"

$mspName = "Your MSP Name Here"

#edit the subject to whatever you want it to be
$ticketSubject = "$mspName - Prepaid Hours Balance"


#if no customer Name is detected, replace with "there" so greeting reads "Hi there,"
if (!$($customerName)) {
    $customerName = "there"
}

#edit the body to be whatever you want to send to the client. Leave the @" in place to preserve formatting and only edit the content in between
$ticketBody = @"
Hi $customerName,

Your Prepaid Hours balance with $mspName is currently: $prepayHours hours. Please reply to this email or reach out to your account manager if you'd like to add any hours to your account.

Have a great day!
$mspName
"@

#create the new ticket and get the ticket ID
$newTicket = Create-Syncro-Ticket -Subject $ticketSubject -IssueType "Account Management" -Status "New"
$ticketId = $newTicket.ticket.id

#send the email to the client
Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketId -Subject "Update" -Body $ticketBody -Hidden "false" -DoNotEmail "False"

#close the ticket
Update-Syncro-Ticket -TicketIdOrNumber $ticketId -Status "Resolved"