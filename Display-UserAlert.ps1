#use this script to display an alert to the user, using Syncro's built-in alert functionality
#can be triggered from an RMM alert; build out canned messages that can be paired with RMM alerts to trigger the right message

#Script must run as Current User to work properly

Import-Module $env:SyncroModule

function Display-SyncroBroadcast {
    param (
        [string]$title,
        [string]$message
    )
    Broadcast-Message -Title $title -Message $message -LogActivity "true"
}

$messages = @{
    "Restart" = "In order to keep your system healthy and secure, it needs to be restarted. Please save your work and restart as soon as possible. `n`nThis is just an alert, and clicking OK below will not restart your computer automatically.`n`nThank you,`nSkyCamp Tech`nsupport@skycamptech.com"
    "custom"  = $customMessage
}

switch ($messageType) {
    restart { Display-SyncroBroadcast -title "Restart Required" -message $messages.Restart }
    custom { Display-SyncroBroadcast -title "SkyCamp Tech Update" -message $messages.custom }
}