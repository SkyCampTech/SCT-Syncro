Import-Module $env:SyncroModule

[string]$now = Get-Date -Format "yyyy-MM-dd_HHmmss"

$resultFile = "$env:ProgramData\SkyCampTech\temp\speedtest-results_$now.txt"
$speedtestExe = "$env:ProgramData\SkyCampTech\bin\speedtest.exe"

#run speedtest, accept the license, output as json
Start-Process -FilePath $speedtestExe -ArgumentList "--accept-license -f json-pretty" -NoNewWindow -RedirectStandardOutput $resultFile -Wait

$result = Get-Content -Path $resultFile | ConvertFrom-Json

if ($result.type -ne "result") {
    Write-Host "No speedtest result; exiting"
    exit 1
}

$downloadMbps = [math]::Round([int]$result.download.bandwidth / 125000, 2)
$downloadLatency = [math]::Round($result.download.latency.iqm)
$uploadMbps = [math]::Round([int]$result.upload.bandwidth / 125000, 2)
$uploadLatency = [math]::Round($result.upload.latency.iqm)



$resultUrl = $result.result.url

Write-Host "Result URL: $resultURL"

Log-Activity -Message "Speedtest Result - $downloadMbps mbps ($downloadLatency ms) / $uploadMbps mbps ($uploadLatency ms)"

if ($uploadResults -match "yes") {
    Write-Host "Uploading Speedtest Results"
    Upload-File -FilePath $resultFile
}
