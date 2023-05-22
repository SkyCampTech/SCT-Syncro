#use this script to remove default Windows apps
#this will get a default list from github, but if you set a link to a text file in the Customer Custom Field "Windows App Removal List", it will reference that instead
Import-Module $env:SyncroModule

if (!($customerAppRemovalList)) {
    Write-Host "No Customer App Removal List defined; using default list"
}

