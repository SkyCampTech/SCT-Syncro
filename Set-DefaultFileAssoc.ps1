#use this script to set a default file association
#uses SetUserFTA: http://kolbi.cz/blog/2017/10/25/setuserfta-userchoice-hash-defeated-set-file-type-associations-per-user/
#must run as current user

Import-Module $env:SyncroModule

$FTAexe = "c:\programdata\skycamptech\bin\SetUserFTA.exe"

<#SYNCRO: needs to send two variables. 
$setDefault = the type ex: video, pdf, etc
$programName = the desired program ex: firefox, adobe, chrome, etc.#>
#hashtable for each target
$browserProgIds = @{
    "Firefox" = "FirefoxURL-308046B0AF4A39CB"
    "Chrome"  = "ChromeHTML"
    "Edge"    = "MSEdgeHTM"
}

$pdfProgIds = @{
    "Firefox"     = "FirefoxPDF-308046B0AF4A39CB"
    "Chrome"      = "ChromePDF"
    "Edge"        = "MSEdgePDF"
    "AdobeReader" = "AcroExch.Document.DC"
}

$mailProgIds = @{
    "Outlook"     = "Outlook.URL.mailto.15"
    "WindowsMail" = "AppXydk58wgm44se4b399557yyyj1w7mbmvd"
    "Edge"        = "MSEdgeHTM"
    "Chrome"      = "ChromeHTML"
    "Firefox"     = "FirefoxURL-308046B0AF4A39CB"
}

$videoProgIds = @{
    "VLC" = "VlC"
}

#hashtable of extensions/protocols to target when adjusting something
#CHANGED: added Video for all video format extensions
$extOrProtocol = @{
    "Browser"  = @{
        "HTTP"  = "http"
        "HTTPS" = "https"
        "HTM"   = ".htm"
        "HTML"  = ".html"
    }
    "PDF"      = ".pdf"
    "Mail"     = "mailto"
    "Video"    = @{
        "MOV" = ".mov"
        "MP4" = ".mp4"
        "FLV" = ".flv"
        "AVI" = ".avi"
        "M4A" = ".m4a"
        "M4V" = ".m4v"
        "WAV" = ".wav"
    }
    "FTP"      = "ftp"
    "WebCal"   = "webcal"
    "Telepone" = "tel"
    "Zoom"     = "ZoomPhoneCall"
}

#CHANGED: programList is unnecessary in this format
# $programList = @{
#     "Adobe Reader"   = "AcroExch.Document.DC"
#     "Edge PDF"       = "MSEdgePDF"
#     "VLC Mov"        = "VLC.mov"
#     "Chrome Browser" = "ChromeHTML"
#     "Edge Browser"   = "MSEdgeHTM"
# }

# everything from here down should be refactored to account for the hashtables above
# pull current settings and log it
# update to the above; assume it's passed by dropdown (Browser, PDF, Mail are the ones we want to start with)

#if($fileExtension -notcontains "."){
#    $fileExtension = "." + $fileExtension
#}

#Sets extensions to change
$fileExtension = $extOrProtocol[$setDefault];

# Sets program type
switch ($setDefault) {
    "Browser" {
        $programList = $browserProgIds;
    }
    "PDF" {
        $programList = $pdfProgIds
    }
    "Mail" {
        $programList = $mailProgIds
    }
    "Video" {
        $programList = $videoProgIds
    }
}
$programID = $programList[$programName] #programID is the targeted application

Write-Host "file extension or protocol: $fileExtension.Keys"

foreach ($this in $fileExtension.Keys) {
    <# $this is the current item #>
    $current = & $FTAexe get | findstr $this

    Write-Host "Current Config: $current"
    Write-Host "Changing $this to use $programName with $programID"
    if ($setDefault -eq "Video") {
        
        Start-Process -FilePath $FTAexe -ArgumentList "$fileExtension $programID$fileExtension" -Wait;
    }
    else {
        Start-Process -FilePath $FTAexe -ArgumentList "$fileExtension $programID" -Wait;
    }
    $current = & $FTAexe get | findstr $fileExtension

    Write-Host "New Config: $current"
}


