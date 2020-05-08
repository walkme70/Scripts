<#
.Synopsis
   Functions used for file structures 
.DESCRIPTION
    Author - Nick Walker
    Date   - 10 August 2019

   This script will iterate through the clean up the users adult torrent folder and move the files 
   into the correct places

.EXAMPLE
    Just run the powershell
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>

function Extract-Files([string]$FileExtention) 
{

$GetFiles = get-Childitem -Path "$_sourceFolder" -recurse |  
    Where-Object {$_.Extension -eq ".$FileExtention"}     

    foreach ($Getfile in $GetFiles){ 
        #if none are foung an empty object is returned filter these by checking if the object exists
        if ($Getfile.Exists -eq $true)
        {
            write-host -NoNewline "extracting file : " -ForegroundColor Blue 
            Write-host  "$($Getfile.Name)" -ForegroundColor Green

            # Extract file to destination
            $fileBaseName = [System.IO.Path]::GetDirectoryName("$($Getfile.FullName)")
            & "C:\Program Files\7-Zip\7z.exe" "x" "-y" "$($Getfile.FullName)" "-o$($fileBaseName)" | Out-Null
        }
    }
} 