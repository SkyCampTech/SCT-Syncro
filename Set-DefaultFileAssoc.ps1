#use this script to set a default file association
#uses SetUserFTA: http://kolbi.cz/blog/2017/10/25/setuserfta-userchoice-hash-defeated-set-file-type-associations-per-user/
#must run as current user

Import-Module $env:SyncroModule

$FTAexe = "c:\programdata\skycamptech\bin\SetUserFTA.exe"

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
    "AdobeReader" = "AcroExchDocument.DC"
}

$mailProgIds = @{
    "Outlook"     = "Outlook.URL.mailto.15"
    "WindowsMail" = "AppXydk58wgm44se4b399557yyyj1w7mbmvd"
    "Edge"        = "MSEdgeHTM"
    "Chrome"      = "ChromeHTML"
    "Firefox"     = "FirefoxURL-308046B0AF4A39CB"
}

#hashtable of extensions/protocols to target when adjusting something
$extOrProtocol = @{
    "Browser"  = @{
        "HTTP"  = "http"
        "HTTPS" = "https"
    }
    "PDF"      = ".pdf"
    "Mail"     = "mailto"
    "MOV"      = ".mov"
    "MP4"      = ".mp4"
    "FLV"      = ".flv"
    "AVI"      = ".avi"
    "M4A"      = ".m4a"
    "M4V"      = ".m4v"
    "WAV"      = ".wav"
    "FTP"      = "ftp"
    "WebCal"   = "webcal"
    "Telepone" = "tel"
    "Zoom"     = "ZoomPhoneCall"
}

$programList = @{
    "Adobe Reader"   = "AcroExch.Document.DC"
    "Edge PDF"       = "MSEdgePDF"
    "VLC Mov"        = "VLC.mov"
    "Chrome Browser" = "ChromeHTML"
    "Edge Browser"   = "MSEdgeHTM"
}

#everything from here down should be refactored to account for the hashtables above
#pull current settings and log it
#update to the above; assume it's passed by dropdown (Browser, PDF, Mail are the ones we want to start with)

#if($fileExtension -notcontains "."){
#    $fileExtension = "." + $fileExtension
#}

$programID = $programList[$programName]

$current = & $FTAexe get | findstr $fileExtension

Write-Host "Current Config: $current"
Write-Host "Changing $fileExtension to use $programName with $programID"

#If statement for http or https in the file extension
if ($fileExtension -eq "http" -or $fileExtension -eq "https") { 
    Start-Process -FilePath $FTAexe -ArgumentList "http $programID" -Wait;
    Start-Process -FilePath $FTAexe -ArgumentList "https $programID" -Wait;
    $httpflag = $true; #flag so we don't do the "if" process again.
}

if ($httpflag) {
    #try-catch block to process missing period before extension
    try {
        Start-Process -FilePath $FTAexe -ArgumentList "$fileExtension $programID" -Wait;
    }
    catch {
        $fileExtension = "." + $fileExtension;
        Start-Process -FilePath $FTAexe -ArgumentList "$fileExtension $programID" -Wait;
        Write-Host $_; #error reporting
    }
}

$current = & $FTAexe get | findstr $fileExtension

Write-Host "New Config: $current"