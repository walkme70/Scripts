<#
.Synopsis
    Process torrent files into Directory Structure

.DESCRIPTION
    Author - Nick Walker
    Date   - 24 September 2019

    This script will move files ready for upload

.EXAMPLE
    Just run the powershell
    .\processTorrentFiles.ps1  
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>

$ErrorActionPreference = 'SilentlyContinue'

function processTorrentFiles {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$_torrentFolder,
      [string]$_torrentExtention
    )
    
    foreach ($_torrentFile in Get-ChildItem -Path $_torrentFolder -Filter *.$_torrentExtention)
    {

        Write-Host -NoNewline "processing file : " -ForegroundColor Blue 
        Write-Host  "$($_torrentFile.Name)" -ForegroundColor Green

        ## // Adult files
        if ( $_torrentFile.Name -match "XXX" )
        {
            $_folderDate = "$(Get-Date -format("yyyy"))\$(Get-Date -format("MMMM"))\$(Get-Date -format("dd"))" 
            moveTorrentFile "$_torrentFile" "$_torrentFolder\Adult\$_folderDate"  
        }

        ## // TVShows
        if ( $_torrentFile.Name -match "S\d{1,2}E\d{1,2}|S\d{1,2}-S\d{1,2}|S\d{1,2}" )
            { moveTorrentFile "$_torrentFile" "TVShows" }

        ## // TVPrograms
        ##if ( $_torrentFile.Name -match "S\d{1,2}-S\d{1,2}" )
       ##   { moveTorrentFile "$_torrentFile" "TVPrograms"}

        ## // Movies
        if ( $_torrentFile.Name -match "DVDScr|720p|1080p|BDrip\BluRay|HDTS|WEB-DL|HDrip|TS Xvid|DVD|HDCAM" )
            { moveTorrentFile "$_torrentFile" "Movies" }

        ## // Movies 4K
        if ( $_torrentFile.Name -match "2160p|UHD" )
            { moveTorrentFile "$_torrentFile" "Movies4K" }

        ## // Music
        if ( $_torrentFile.Name -match "MP3|Discography|VBR|320kbps|FLAC|MutzNutz" )
            { moveTorrentFile "$_torrentFile" "Music" }

        ## // Software
        if ( $_torrentFile.Name -match "Keygen|KeyMaker|Keyfilemaker|portable|Apple|MACOSX|MacOS|X64|X86" )
            { moveTorrentFile "$_torrentFile" "Software" }

        ## // Education
        if ( $_torrentFile.Name -match "Lynda|Pluralsight|Packt|Exam|Technics|Microsoft|Cloud.Academy" )
            { moveTorrentFile "$_torrentFile" "Education" }
        
    } else {
        Write-Host -NoNewline "INFO : " -ForegroundColor Red 
        Write-Host  "No Files found to process" -ForegroundColor Green
    }
}

function moveTorrentFile {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$_torrentSource,
      [string]$_torrentSubFolder
    )
    
    ## //  Build torrent Target Folder
    [string]$_torrentTarget = $null
    [string]$_torrentTarget = "$_torrentSubFolder"

    ## // Make local path if not exist
    If(!(Test-Path $_torrentTarget))
        {New-Item -ItemType Directory -Force -Path $_torrentTarget | Out-Null}

    ## // Replace unwanted charaters in the filename
    $_torrentSourceName = $_torrentSource.replace("[", "``[").replace("]", "``]")

    ## // Check to see if file exists
    if (Test-Path "$_torrentSourceName")
    {
        ## // Show where moving file too
        Write-Host -NoNewline "Relocating file to subfolder: " -ForegroundColor Blue 
        Write-Host "$_torrentTarget" -ForegroundColor Yellow

        ## // Move file to folder
        Move-Item -Path "$_torrentSourceName" -Destination "$_torrentTarget"
    }
}

processTorrentFiles "T:\Torrents" "torrent"