#use this script to set a default file association
#uses SetUserFTA: http://kolbi.cz/blog/2017/10/25/setuserfta-userchoice-hash-defeated-set-file-type-associations-per-user/
#must run as current user

Import-Module $env:SyncroModule

$FTAexe = "c:\temp\setuserfta.exe"

$programList = @{
    "Adobe Reader" = "AcroExch.Document.DC"
    "Edge PDF"     = "MSEdgePDF"
    "VLC Mov"      = "VLC.mov"
    "Photos"       = "AppX43hnxtbyyps62jhe9sqpdzxn1790zetc"
}

if ($fileExtension -notcontains ".") {
    $fileExtension = "." + $fileExtension
}

$programID = $programList[$programName]

$current = & $FTAexe get | findstr $fileExtension

Write-Host "Current Config: $current"
Write-Host "Changing $fileExtension to use $programName with $programID"

Start-Process -FilePath $FTAexe -ArgumentList "$fileExtension $programID" -Wait

$current = & $FTAexe get | findstr $fileExtension

Write-Host "New Config: $current"