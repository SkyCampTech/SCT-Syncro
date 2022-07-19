Import-Module $env:SyncroModule

<#used event log references here: https://helpcenter.veeam.com/docs/agentforwindows/userguide/appendix_events.html?ver=50

script checks for the presence of an Event ID 190 (Backup Job finished) within the last 24 hours.

If the event ID exists, it will check for success/fail and alert accordingly. If there's no log, entry in the last 24 hours, it also alerts
since it means the backup didn't run for some reason. 

We may also add checks for event ID 191, too, just for completeness, but event id 190 gets us by for now

After initial run, found that older versions of Veeam used "Veeam Endpoint Backup" for LogName/Source instead of "Veeam Agent" and upgrading still references old log.
Need to check for both
#>

#determine which Log/Source to use

try {
    Get-EventLog -LogName "Veeam Agent" | Select-Object -First 1 -ErrorAction Stop
    $logSource = "Veeam Agent"
    Write-Host "Found Logs under Veeam Agent"
}
catch [System.InvalidOperationException] {
    Write-Host "Didn't find Veeam Agent; let's look for Veeam Endpoint Backup"

    try {
        Get-EventLog -LogName "Veeam Endpoint Backup" | Select-Object -First 1 -ErrorAction Stop
        $logSource = "Veeam Endpoint Backup"
        Write-Host "Found Logs under Veeam Endpoint Backup"
    }
    catch [System.InvalidOperationException] {
        Write-Host "Didn't find Veeam Agent or Veeam Endpoint Backup"
        Rmm-Alert -Category "Veeam" -Body "Veeam doesn't appear to be installed or otherwise logging on $env:ComputerName; investigate"
        exit 1
    }
}
catch {
    Write-Host "Veeam event logs issues"
    Rmm-Alert -Category "Veeam" -Body "An unknown error prevented us from checking Veeam logs on $env:ComputerName; investigate"
    exit 1
}

$yesterday = ((Get-Date).AddDays(-1))
$eventId = "190"

#check for event logs since yesterday
if (Get-EventLog -LogName $logSource -Source $logSource -InstanceId $eventId -After $yesterday) {
    Write-Host "Event ID 190 (Backup Job Finished) found since yesterday; check for success"
    if ((Get-EventLog -LogName $logSource -Source $logSource -InstanceId $eventId -After $yesterday).Message -match "success") {
        Write-Host "Veeam Backups ran successfully on $env:ComputerName in last 24 hours"
        exit
    }
    else {
        Write-Host "Backup did not succeed; investigate"
        $message = (Get-EventLog -LogName $logSource -Source $logSource -InstanceId $eventId -After $yesterday).Message
        Rmm-Alert -Category "Veeam" -Body $message
        exit 1
    }
}
else {
    Rmm-Alert -Category "Veeam" -Body "No backup alerts found in last 24 hours on $env:ComputerName; investigate"
    exit 1
}
