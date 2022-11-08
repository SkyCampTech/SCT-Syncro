# Background
Croc is a cross-platform CLI file transfer tool to send files or folders between two computers. Read more here: https://github.com/schollz/croc. We deploy this via Syncro as a method to send files or folders from a technician machine to a managed machine without needing to use Syncro Background Tools (100MB file limit; slow and inconsistent anyway) and without needing to initiate a Splashtop session just to transfer a file (since Splashtop for RMM can't do file transfers without Remote Takeover)

# Using with Syncro
This script is for receiving a file or folder from a technician machine. In the first release, it assumes croc is already installed on the receiving computer, but we'll build it out to also check for croc and install it if needed via chocolatey

## Assumptions
* If you enter no value for *manualOutputPath* it will save to our default temp folder ($env:APPDATA\SkyCampTech\temp)
* *manualOutputPath* needs to be an absolute path
* uses a public relay; script can be adapted to use a private relay based on the docs on github
* you already have the code-phrase from the technician machine (required at runtime)