<#
.Synopsis
    Move all Adult star downloads
.DESCRIPTION
    Author - Nick Walker
    Date   - 02 February 2019

    This script will move Adult Star into the right folders depending on the filename

.EXAMPLE
    Just run the powershell
    .\sort_adult_files.ps1  
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>

#$regex = '(?<filedate>\d{2}(?:\.|-|_)?\d{2}(?:\.|-|_)?\d{4})[^0-9]'

function moveAdultFiles {
    Param
    (
        [Parameter(Mandatory)] 
        [System.IO.FileInfo]$_sourceFolder,
        [String]$_fileExtension
    )
    
    foreach ($files in Get-ChildItem -Path $_sourceFolder -Filter "*.$_fileExtension") {

        # // Store Folder contents into a List
        #$_AdultStars = @(Get-ChildItem -path (Split-Path $_sourceFolder) + "\Stars")

        ## // show the file to be processed
        writeToScreen "processing file" "$($files.Name)"

<#         ## // Remove the downmagaz from filename
        #       $_magFilename = $_magFilename -replace "_downmagaz.com", ""

        # ## // Workout the date in the filename
        # If($_magFilename -match $regex) {
        #     $_magDate = $Matches['filedate'] -replace '(\.|-|_)',''
        #     $_magDate = [datetime]::ParseExact($_magDate,'ddMMyyyy',[cultureinfo]::InvariantCulture)
        
        #     $_magDay = $_magDate.Day
        #     $_magMonth = $_magDate.Month
        #     $_magMonthName = (Get-Culture).DateTimeFormat.GetMonthName($_magDate.Month)
        #     $_magYear = $_magDate.Year

        # }
        
        
        #Write-Host "Day {0}, Month {1}, Year {2}, MonthName {3}"; $_magDay, $_magMonth, $_magYear, $_magMonthName
        
        ## writeToScreen "       new file" "$($_magFilename)"
        ## writeToScreen "      date file" "$filedateTime" #>

    }
}
<##
        ## // Adult files
        if ( $_torrentFile.Name -match "XXX" )
        {
            $_folderDate = "$(Get-Date -format("yyyy"))\$(Get-Date -format("MMMM"))\$(Get-Date -format("dd"))" 
            moveTorrentFile "$_torrentFile" "$_torrentFolder\Adult\$_folderDate"  
        }

        ## // TVShows
        if ( $_torrentFile.Name -match "S\d{1,2}E\d{1,2}" )
            { moveTorrentFile "$_torrentFile" "$_torrentFolder\TVShows" }

        ## // Movies
        if ( $_torrentFile.Name -match "DVDScr|720p|1080p|BDrip\BluRay|HDTS|WEB-DL|HDrip|TS Xvid|DVD|HDCAM" )
            { moveTorrentFile "$_torrentFile" "$_torrentFolder\Movies" }

        ## // Movies 4K
        if ( $_torrentFile.Name -match "2160p" )
            { moveTorrentFile "$_torrentFile" "$_torrentFolder\Movies 4K" }

        ## // Music
        if ( $_torrentFile.Name -match "MP3|Discography|VBR|320kbps|FLAC|MutzNutz" )
        { moveTorrentFile "$_torrentFile" "$_torrentFolder\Music" }

        ## // Software
        if ( $_torrentFile.Name -match "Keygen|KeyMaker|Keyfilemaker|portable|Apple|MACOSX|MacOS|X64|X86" )
        { moveTorrentFile "$_torrentFile" "$_torrentFolder\Software" }

        ## // Education
        if ( $_torrentFile.Name -match "Lynda|Pluralsight|Packt" )
        { moveTorrentFile "$_torrentFile" "$_torrentFolder\Education" }
        #>
    

function writeToScreen {
    Param
    (
        [Parameter(Mandatory)] 
        [string]$_textInfo,
        [string]$_textOutput
    )
    write-host -NoNewline "$_textInfo : " -ForegroundColor Blue 
    Write-host  "$_textOutput" -ForegroundColor Green

}

# function moveFile {
#     Param
#     (
#         [Parameter(Mandatory)] 
#         [string]$_torrentSource,
#         [string]$_torrentTarget
#     )
    
#     ## // Make local path if not exist
#     If (!(test-path $_torrentTarget))
#     { New-Item -ItemType Directory -Force -Path $_torrentTarget | out-null }

#     ## // Replace unwanted charaters in the filename
#     ## $_torrentSourceName = $_torrentSource.replace("[", "``[").replace("]", "``]")
    
#     ## // Move file to folder
#     ## Move-Item -Path "$_torrentSourceName" -Destination "$_torrentTarget"
# }    

moveAdultFiles "\\bagpuss\storage\Adult\_sort" "avi"
