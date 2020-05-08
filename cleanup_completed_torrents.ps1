<#
.Name
   Clean up Script for Adult Folders
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
$_sourceFolder = "T:\Temp\Adult"
$_destinationFolder ="T:\Temp\_Sort"

# Use the files module
. "T:\Scripts\_files_functions.ps1"
. "T:\Scripts\_extract_functions.ps1"

# Starting clean up
write-host "[Cleanup folder]"

# Check to see if the destination folder exists
If(!(test-path $_destinationFolder))
{ 
    Write-Host "..Creating Target folder '$_destinationFolder'"  -ForegroundColor Red
    New-Item -ItemType Directory -Force -Path $_destinationFolder | Out-Null
}
  
# Extract any RAR files
    Extract-Files "rar"
    
# Move files
    Move-DownloadeFiles "avi"           # AVI files
    Move-DownloadeFiles "mkv"           # MKV files
    Move-DownloadeFiles "mp4"           # MKV files
    Remove-DownloadeFiles "png"         # PNG files
    Remove-DownloadeFiles "r??"         # R?? files
    Remove-DownloadeFiles "sfv"         # SFV files
    Remove-DownloadeFiles "nfo"         # NFO files

# Clean up file structure
    robocopy.exe $_sourceFolder $_sourceFolder /e /move | Out-Null   

# Finished
    Write-Host "..Completed" -ForegroundColor Green