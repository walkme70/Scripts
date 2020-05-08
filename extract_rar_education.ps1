<#
.Name
   Clean up Script for education Folders
.Synopsis
   Clean up completed torrents in Adult Folder
.DESCRIPTION
    Author - Nick Walker
    Date   - 05 July 2019

   This script will iterate through the clean up the users adult torrent folder and move the files 
   into the correct places

.EXAMPLE
    Just run the powershell
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>

$ErrorActionPreference = "SilentlyContinue"

# Set variables
$_sourceFolder = "T:\Cloud_Sync\Education"
$_destinationFolder ="T:\Transfer\Education\_Sort"

# Use the files module
. "T:\Scripts\_files_functions.ps1"
. "T:\Scripts\_extract_functions.ps1"

# Starting clean up
write-host "[Extracting Cmpressed Files]"

# Check to see if the destination folder exists
If(!(test-path $_destinationFolder))
{ 
    Write-Host "..Creating Target folder '$_destinationFolder'"  -ForegroundColor Red
    New-Item -ItemType Directory -Force -Path $_destinationFolder | Out-Null
}
  
# Extract any RAR files
    Extract-Files "zip"
    Extract-Files "rar"
    
# Move files
    #Move-DownloadeFiles "avi"           # AVI files
    #Remove-DownloadeFiles "png"         # PNG files

# Transfer file structure
    Write-Host "..Transferring files to folder" -ForegroundColor Blue
    robocopy.exe $_sourceFolder $_destinationFolder /e /xf *.rar /xf *.zip /xf *.r?? /xf *.sfv /xf *.nfo /xf *.diz /move | Out-Null   

# Clean up file target structure
    robocopy.exe $_destinationFolder $_destinationFolder /e /move | Out-Null   

# Finished
    Write-Host "..Completed" -ForegroundColor Green