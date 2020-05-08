<#
.Name
   Clean up Script for Log Folders
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

# Set variables
$_logsFolder = "\\bagpuss\logs"
$_recordingFolder = "\\bagpuss\recordings"

# Use the files module
## . "T:\Scripts\_files_functions.ps1"

function writeLog {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$textString,
      [Parameter(Mandatory=$true)] 
      [string]$logtextString
      
    )

    write-host -NoNewline "...$textString : " -ForegroundColor Blue 
    Write-host  "$logtextString" -ForegroundColor Green

}
function removeEmptyFolder {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$sourceFolder
    )

    writeLog "removing empty folder" "$SourceFolder"

    # Clean up file structure
    robocopy.exe $sourceFolder $sourceFolder /e /move | Out-Null   
}

function deleteFilesFromFolder {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$sourceFolder,
      [string]$days
    )

    ## // Checking files
    writeLog "Checking folder" $SourceFolder

    ## // Remove the files
    Get-ChildItem $sourceFolder -Recurse -Directory | 
        Where-Object { (get-date) - $_.LastWriteTime -gt 28 } | 
        writeLog "filename" $_.fullName | 
        Remove-Item -Force -Verbose -WhatIf

    ## // Remove empty directories
    removeEmptyFolder -sourceFolder $sourceFolder
}

## ----------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------

## Check the recordings folder
deleteFilesFromFolder -sourceFolder "$_recordingFolder\record_nvr" -days 28

# delete files

# Finished
Write-Host "..Completed" -ForegroundColor Green