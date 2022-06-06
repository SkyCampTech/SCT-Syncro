#use this script to set a default file association
#uses SetUserFTA: http://kolbi.cz/blog/2017/10/25/setuserfta-userchoice-hash-defeated-set-file-type-associations-per-user/
#must run as current user

Import-Module $env:SyncroModule

$FTAexe = "c:\programdata\skycamptech\bin\SetUserFTA.exe"

$programList = @{
    "Adobe Reader"   = "AcroExch.Document.DC"
    "Edge PDF"       = "MSEdgePDF"
    "VLC Mov"        = "VLC.mov"
    "Chrome Browser" = "ChromeHTML"
    "Edge Browser"   = "MSEdgeHTM"
}

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