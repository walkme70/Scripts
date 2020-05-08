<#
.Synopsis
    Process torrent files into Directory Structure

.DESCRIPTION
    Author - Nick Walker
    Date   - 30 April 2020

    This script will move files ready for upload

.EXAMPLE
    Just run the powershell
    .\processTorrentFiles.ps1  
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>

$ErrorActionPreference = 'SilentlyContinue'

$_educationFolder = "T:\Transfer\Education"

function sortEducationalFiles {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$_sourceFolder,
      [string]$_sourceExtention
    )
    
    foreach ($_folders in Get-ChildItem -Path $_sourceFolder -Directory)
    {

        Write-Host -NoNewline "processing folder : " -ForegroundColor Blue 
        Write-Host  "$($_folders.Name)" -ForegroundColor Green

         ## // TVShows
         if ( $_folders.Name -match "A.Cloud.Guru" )
             { moveEducationalFolder "$_folders" "Cloud Guru" }

        ## // Cloud Academy
        if ( $_folders.Name -match "CLOUD.ACADEMY" )
        { moveEducationalFolder "$_folders" "Cloud Academy" }

        ## // Lynda
        if ( $_folders.Name -match "Lynda" )
            { moveEducationalFolder "$_folders" "Lynda"}

        ## // Pluralsight
        if ( $_folders.Name -match "Pluralsight" )
            { moveEducationalFolder "$_folders" "Pluralsight" }

        ## // Packt
        if ( $_folders.Name -match "Packt" )
            { moveEducationalFolder "$_folders" "Packt" }
        
        ## // LinkedIn
        if ( $_folders.Name -match "LinkedIn" )
        { moveEducationalFolder "$_folders" "LinkedIn" }

        ## // Linux
        if ( $_folders.Name -match "Linux" )
            { moveEducationalFolder "$_folders" "Linux" }
            
        ## // Linux
        if ( $_folders.Name -match "Udemy" )
            { moveEducationalFolder "$_folders" "Udemy" }


    } else {
        Write-Host -NoNewline "INFO : " -ForegroundColor Red 
        Write-Host  "No Folders found to process" -ForegroundColor Green
    }
}

function moveEducationalFolder {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$_sourceFolder,
      [string]$_targetSubFolder
    )

    ## //  Build torrent Target Folder
    [string]$_targetFolder = $null
    [string]$_targetFolder = "$_educationFolder\$_targetSubFolder"

    ## // Make local path if not exist
    If(!(Test-Path "$_targetFolder"))
        {New-Item -ItemType Directory -Force -Path "$_targetFolder" | Out-Null}

    ## // Replace unwanted charaters in the filename
    $_targetNewFolder = $_targetFolder.replace("[", "``[").replace("]", "``]")

    ## // Check to see if file exists
    if (Test-Path "$_targetNewFolder")
    {
        ## // Show where moving file too
        Write-Host -NoNewline "Relocating file to subfolder: " -ForegroundColor Blue 
        Write-Host "$_targetFolder" -ForegroundColor Yellow

        ## // Move file to folder
        Move-Item -Path "$_educationFolder\_Sort\$_sourceFolder" -Destination "$_targetNewFolder"
    }
}

sortEducationalFiles "T:\Transfer\Education\_Sort"