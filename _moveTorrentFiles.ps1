<#
.Synopsis
    Process torrent files into Directory Structure

.DESCRIPTION
    Author - Nick Walker
    Date   - 24 September 2019

    This script will move files ready for upload

.EXAMPLE
    Just run the powershell
    .\_moveTorrentFiles.ps1  
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>

function processTorrentFiles {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$_torrentFolder,
      [string]$_torrentExtention
    )
    
    foreach ($_torrentFile in Get-ChildItem -Path $_torrentFolder -Filter *.$_torrentExtention)
    {

        ## // Adult files
        if ( $_torrentFile.Name -match "XXX" )
        {
            $_folderDate = "$(Get-Date -format("yyyy"))\$(Get-Date -format("MMMM"))\$(Get-Date -format("dd"))" 
            moveTorrentFile "$_torrentFolder\$_torrentFile" "$_torrentFolder\Adult\$_folderDate"  
        }

        ## // TVShows
        if ( $_torrentFile.Name -match "S\d{1,2}E\d{1,2}|S\d{1,2}" )
            { moveTorrentFile "$_torrentFolder\$_torrentFile" "$_torrentFolder\TVShows" }

        ## // Movies
        if ( $_torrentFile.Name -match "DVDScr|720p|1080p|BDrip\BluRay|HDTS|WEB-DL|HDrip|TS Xvid|DVD|HDCAM" )
            { moveTorrentFile "$_torrentFolder\$_torrentFile" "$_torrentFolder\Movies" }

        ## // Music
        if ( $_torrentFile.Name -match "MP3|Discography|VBR|320kbps|FLAC|MutzNutz" )
        { moveTorrentFile "$_torrentFolder\$_torrentFile" "$_torrentFolder\Music" }

        ## // Software
        if ( $_torrentFile.Name -match "Keygen|KeyMaker|Keyfilemaker|portable|Apple|MACOSX|MacOS|X64|X86" )
        { moveTorrentFile "$_torrentFolder\$_torrentFile" "$_torrentFolder\Software" }

        ## // Movies 4K
        if ( $_torrentFile.Name -match "Lynda|Pluralsight|Packt" )
        { moveTorrentFile "$_torrentFolder\$_torrentFile" "$_torrentFolder\Education" }
        
    }
}

function moveTorrentFile {
    Param
    (
      [Parameter(Mandatory=$true)] 
      [string]$_torrentSource,
      [string]$_torrentTarget
    )
    
    ## // Make local path if not exist
    If(!(test-path $_torrentTarget))
        {New-Item -ItemType Directory -Force -Path $_torrentTarget | out-null}

    ## // Replace unwanted charaters in the filename
    $_torrentSourceName = $_torrentSource.replace("[", "``[").replace("]", "``]")
    
    ## // Move file to folder
    Move-Item -Path "$_torrentSourceName" -Destination "$_torrentTarget"
}
