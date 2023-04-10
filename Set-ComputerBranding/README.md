# Setting Computer Branding (Screensaver, Lock Screen, Wallpaper)

This is required for clients that want any of these items set by policy but don't have an Enterprise or Education license (so, most of our clients). Microsoft only exposes the ability to set these settings to users on Enterprise/Education licenses, not Pro/Business.

## Requirements

1. Wallpaper/Lock Screen (.png or .jpg) and Screenscaver (.scr) must be uploaded to a public web URL (we're using a B2 bucket)
2. Customer Custom Fields for each URL. The script will only try to apply if the fields are defined, so you don't have to define all the values if you don't want to set those items. We used customer custom fields so this script can be client-agnostic, but you could substitute the platform variables later for Required Files. Field Names we used are:
    1. Wallpaper
    2. LockScreen
    3. Screensaver
3. A place to download the files and store them (persistent). We already have a folder we dump important stuff into under ProgramData, so we refernce that, but you can put it anywhere you want
4. The values set for each of the Customer Custom Fields for a given customer
5. Apply the script to the desired policy for that customer