Import-Module $env:SyncroModule

#can comment out the next 4 lines once it's running properly, but this will show you what platfor variables it's pulling at runtime
Write-Host "Platform Variables Pulled on this run: `n"
Write-Host "customerName: $customerName `n"
Write-Host "customerEmail: $customerEmail `n"
Write-Host "prepayHours: $prepayHours"

#edit the subject to whatever you want it to be
$ticketSubject = "$mspName - Prepaid Hours Balance"


#if no customer Name is detected, replace with "there" so greeting reads "Hi there,"
if (!$($customerName)) {
    $customerName = "there"
}

#check for no hours defined and replace with 0
if (!($prepayHours)) {
    $prepayHours = 0
    Write-Host "Client has no hours left. Prepaid hours: $prepayHours"
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
$ticketNum = $newTicket.ticket.number

Write-Host "All updates posted to Ticket Number: $ticketNum"

#update the ticket with a public notice with prepaid hours; this does not email the client
#change DoNotEmail to False if you don't have "Resolved" emails going out
Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketId -Subject "Update" -Body $ticketBody -Hidden "false" -DoNotEmail "true"
Write-Host "Added public comment to ticket $ticketNum"

#close the ticket; if you have "Resolved" emails going out, this should show the last Public Comment, which would be the comment submitted previously
Update-Syncro-Ticket -TicketIdOrNumber $ticketId -Status "Resolved"
Write-Host "Resolved ticket $ticketNum"

exit