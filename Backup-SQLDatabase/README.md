## Assumptions
1. SQL Authentication is turned on, in addition to Windows Authentication, on your SQL Instance
2. You've created a SQL user with the default database set: https://screenshots.skycamptech.com/i/14baf167-cbcd-4d0f-95fd-759a0145787f.png
3. You've given it "public" Server Roles: https://screenshots.skycamptech.com/i/7b553354-83ca-42a1-a27b-7858886d9c22.png
4. On the database(s) you want to back up, you've assigned the appropriate User Mapping: https://screenshots.skycamptech.com/i/a3e78c0f-26c0-4079-9334-d201bc238f4d.png

## Required Parameters
1. serverInstance - the full name (server and instance name) of the SQL Instance you're connecting to
2. sqlUsername - the SQL (not Windows) authentication name of the username you want to use for the backup
3. sqlPassword - the password for that user
4. databaseName - the name of the database to back up
5. outputPath - where the file should be saved

## Optional Parameters
1. purgeBackups - purge old versions of the backup in the output folder
2. purgeAge - age of files to delete in days (defaults to 30 days)