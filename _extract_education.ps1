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
$_sourceDrive = "T:"
$_scriptFolder = "$_sourceDrive\scripts"
$_locationEducation = "Education"
$_locationBooks = "Books"
$_sourceFolder = "$_sourceDrive\Cloud_Sync\$_locationEducation"
$_destinationFolder ="$_sourceDrive\Transfer\$_locationEducation\_Sort"
$_targetBooks = "$_sourceDrive\Cloud_Sync\$_locationBooks"

# Use the files module
. "$_scriptFolder\_files_functions.ps1"
. "$_scriptFolder\_extract_functions.ps1"

# Starting clean up
write-host "[Extracting Cmpressed Files]"

# Check to see if the destination folder exists
If(!(test-path $_destinationFolder))
{ 
    Write-Host "Creating Target folder '$_destinationFolder'"  -ForegroundColor Red
    New-Item -ItemType Directory -Force -Path $_destinationFolder | Out-Null
}
  
# Extract any RAR files
    Extract-Files "zip"
    Extract-Files "rar"
    
# Move files
    #Move-DownloadeFiles "avi"           # AVI files
    #Remove-DownloadeFiles "png"         # PNG files

# Transfer Books
    Write-Host "Transferring books to folder" -Foregroundcolor Blue
    $_books = Get-ChildItem -Path $_sourceFolder -filter "*.epub" -Recurse | Where-Object {$_.PSIsContainer -eq $false}
    foreach ($_book in $_books) {
        Write-Host -NoNewline "Transferring Book : " -ForegroundColor Blue 
        Write-host  "$($_book.FullName)" -ForegroundColor Green
        Move-Item -Path $_book.FullName -Destination $_targetBooks\$($_book.Name)
    }
    #robocopy.exe $_sourceFolder $_targetBooks *.epub /e | Out-Null
    
# Transfer file structure
    Write-Host "Transferring Educational Files to Transfer folder" -ForegroundColor Blue
    robocopy.exe $_sourceFolder $_destinationFolder /e /xf *.rar /xf *.zip /xf *.r?? /xf *.sfv /xf *.nfo /xf *.diz /move | Out-Null   

# Clean up file target structure
    Write-Host "Cleaning up Educational Folder" -ForegroundColor Blue
    robocopy.exe $_destinationFolder $_destinationFolder /e /move | Out-Null   

# Finished
    Write-Host "Completed" -ForegroundColor Green