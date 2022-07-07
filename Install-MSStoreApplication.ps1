function DownloadAppxPackage {
  [CmdletBinding()]
  param (
    [string]$Uri,
    [string]$Path = "."
  )
   
  process {
    Write-Output ""
    $StopWatch = [system.diagnostics.stopwatch]::startnew()
    $Path = (Resolve-Path $Path).Path
    #Get Urls to download
    Write-Host -ForegroundColor Yellow "Processing $Uri"
    $WebResponse = Invoke-WebRequest -UseBasicParsing -Method 'POST' -Uri 'https://store.rg-adguard.net/api/GetFiles' -Body "type=url&url=$Uri&ring=Retail" -ContentType 'application/x-www-form-urlencoded'
    $LinksMatch = ($WebResponse.Links | Where-Object { $_ -like '*.appx*' } | Where-Object { $_ -like '*_neutral_*' -or $_ -like "*_" + $env:PROCESSOR_ARCHITECTURE.Replace("AMD", "X").Replace("IA", "X") + "_*" } | Select-String -Pattern '(?<=a href=").+(?=" r)').matches.value
    $Files = ($WebResponse.Links | Where-Object { $_ -like '*.appx*' } | Where-Object { $_ -like '*_neutral_*' -or $_ -like "*_" + $env:PROCESSOR_ARCHITECTURE.Replace("AMD", "X").Replace("IA", "X") + "_*" } | Where-Object { $_ } | Select-String -Pattern '(?<=noreferrer">).+(?=</a>)').matches.value
    #Create array of links and filenames
    # $DownloadLinks = @()
    for ($i = 0; $i -lt $LinksMatch.Count; $i++) {
      $Array += , @($LinksMatch[$i], $Files[$i])
    }
    #Sort by filename descending
    $Array = $Array | sort-object @{Expression = { $_[1] }; Descending = $True }
    $LastFile = "temp123"
    for ($i = 0; $i -lt $LinksMatch.Count; $i++) {
      $CurrentFile = $Array[$i][1]
      $CurrentUrl = $Array[$i][0]
      #Find first number index of current and last processed filename
      if ($CurrentFile -match "(?<number>\d)") {}
      $FileIndex = $CurrentFile.indexof($Matches.number)
      if ($LastFile -match "(?<number>\d)") {}
      $LastFileIndex = $LastFile.indexof($Matches.number)

      #If current filename product not equal to last filename product
      if (($CurrentFile.SubString(0, $FileIndex - 1)) -ne ($LastFile.SubString(0, $LastFileIndex - 1))) {
        #If file not already downloaded, add to the download queue
        if (-Not (Test-Path "$Path\$CurrentFile")) {
          "Downloading $Path\$CurrentFile"
          $FilePath = "$Path\$CurrentFile"
          $FileRequest = Invoke-WebRequest -Uri $CurrentUrl -UseBasicParsing #-Method Head
          [System.IO.File]::WriteAllBytes($FilePath, $FileRequest.content)
        }
        #Delete file outdated and already exist
      }
      elseif ((Test-Path "$Path\$CurrentFile")) {
        Remove-Item "$Path\$CurrentFile"
        "Removing $Path\$CurrentFile"
      }
      $LastFile = $CurrentFile
    }
    "Time to process: " + $StopWatch.ElapsedMilliseconds
  }
}

DownloadAppxPackage $MSStoreURL "C:\ProgramData\SkyCampTech\temp"

Start-Sleep -Seconds 5
Add-AppxPackage -path C:\ProgramData\SkyCampTech\temp\*.APPX* -ForceApplicationShutdown

Start-Sleep -Seconds 5
Remove-Item -path C:\ProgramData\SkyCampTech\temp\*.APPX* -Force