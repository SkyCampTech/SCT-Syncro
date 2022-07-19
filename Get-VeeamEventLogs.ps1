Import-Module $env:SyncroModule

<#used event log references here: https://helpcenter.veeam.com/docs/agentforwindows/userguide/appendix_events.html?ver=50

script checks for the presence of an Event ID 190 (Backup Job finished) within the last 24 hours.

If the event ID exists, it will check for success/fail and alert accordingly. If there's no log, entry in the last 24 hours, it also alerts
since it means the backup didn't run for some reason. 

We may also add checks for event ID 191, too, just for completeness, but event id 190 gets us by for now
#>

$yesterday = ((Get-Date).AddDays(-1))
$eventLog = "Veeam Agent"
$eventSource = "Veeam Agent"
$eventId = "190"

try {
    Get-EventLog -LogName $eventLog | Select-Object -First 1 -ErrorAction Stop
}
catch [System.InvalidOperationException] {
    Write-Host "Veeam event logs issues"
    Rmm-Alert -Category "Veeam" -Body "Veeam doesn't appear to be installed or otherwise logging on $env:ComputerName; investigate"
    exit 1
}
catch {
    Write-Host "Veeam event logs issues"
    Rmm-Alert -Category "Veeam" -Body "An unknown error prevented us from checking Veeam logs on $env:ComputerName; investigate"
    exit 1
}

#check for event logs since yesterday
if (Get-EventLog -LogName $eventLog -Source $eventSource -InstanceId $eventId -After $yesterday) {
    Write-Host "Event ID 190 (Backup Job Finished) found since yesterday; check for success"
    if ((Get-EventLog -LogName $eventLog -Source $eventSource -InstanceId $eventId -After $yesterday).Message -match "success") {
        Write-Host "Veeam Backups ran successfully on $env:ComputerName in last 24 hours"
        exit
    }
    else {
        Write-Host "Backup did not succeed; investigate"
        $message = (Get-EventLog -LogName $eventLog -Source $eventSource -InstanceId $eventId -After $yesterday).Message
        Rmm-Alert -Category "Veeam" -Body $message
        exit 1
    }
}
else {
    Rmm-Alert -Category "Veeam" -Body "No backup alerts found in last 24 hours on $env:ComputerName; investigate"
    exit 1
}
