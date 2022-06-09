Import-Module $env:SyncroModule

$FontFolder = "$env:ProgramData\skycamptech\temp\"
Remove-Item ($FontFolder + "*.ttf", "*.otf", "*.fon", "*.fnt") -Force

$FontPackage = "Fonts.zip" #Remove for final version
$FontPackage = ($FontFolder + $FontPackage)


#Set Font Reg Key Path
$FontRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

Expand-Archive -LiteralPath $FontPackage -DestinationPath $FontFolder
#Grab the Font from the Current Directory
try {
    foreach ($Font in $(Get-ChildItem -Path $FontFolder -Include *.ttf, *.otf, *.fon, *.fnt -Recurse)) {
 
        #Copy Font to the Windows Font Directory
        Copy-Item $Font "C:\Windows\Fonts" -Force
        
        #Set the Registry Key to indicate the Font has been installed
        New-ItemProperty -Path $FontRegPath -Name $Font.Name -Value $Font.Name -PropertyType String | Out-Null
        Write-Host $Font.name " Font was added to the device"
    }    
    Log-Activity "Successfully added font package containing: " $Font.Name
}
catch {
    Write-Host "ERROR: " $Font.Name " font failed to install properly." -ForegroundColor Red
    remove-Item ($FontFolder + "*")
    exit 1
}
