Import-Module $env:SyncroModule

$FontFolder = "$env:ProgramData\skycamptech\temp\"
$FontPackage = $FontFolder + $FontPackage + ".zip"
Remove-Item ($FontFolder + "*.ttf", "*.otf", "*.fon", "*.fnt") -Force


#Set Font Reg Key Path
$FontRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

Expand-Archive -LiteralPath $FontPackage -DestinationPath $FontFolder -Force
#Grab the Font from the Current Directory
try {
    $FontList = (Get-ChildItem -Path $FontFolder -Include *.ttf, *.otf, *.fon, *.fnt -Recurse)
    foreach ($Font in $FontList) {
 
        
        if (Test-Path -Path ("C:\Windows\Fonts\" + $Font.Name)) {
            Write-Host $Font.name " Font is already on the device." -ForegroundColor Green
        }
        else {
            #Copy Font to the Windows Font Directory
            Copy-Item $Font "C:\Windows\Fonts" -Force
        
            #Set the Registry Key to indicate the Font has been installed
            New-ItemProperty -Path $FontRegPath -Name $Font.Name -Value $Font.Name -PropertyType String | Out-Null
            Write-Host $Font.name " Font was installed on the device" -ForegroundColor Green
        }   
    } 
    Log-Activity -message ("Successfully installed font package containing: " + ($FontList.Name -split ', ', 1))
}
catch {
    Write-Host "ERROR: " $Font.Name " font failed to install properly." -ForegroundColor Red
    remove-Item ($FontFolder + "*")
    exit 1
}
