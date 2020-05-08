<#
.Synopsis
   Functions used for file structures 
.DESCRIPTION
    Author - Nick Walker
    Date   - 10 August 2019
    Update - 01 May 2020

   This script will iterate through the clean up the users adult torrent folder and move the files 
   into the correct places

.EXAMPLE
    Just run the powershell
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>

<#

$dpath = "T:\Cloud_Sync\TVShows\"
PS T:\Scripts> Write-Host $dpath.Split('\')[2]
TVShows
PS T:\Scripts> Write-Host $dpath.Split('\')[1]
Cloud_Sync
PS T:\Scripts> Write-Host $dpath.Split('\')[0]
T:
#>

function Move-DownloadeFiles([string]$FileExtention) 
{

$GetFiles = get-Childitem -Path "$_sourceFolder" -recurse |  
    Where-Object {$_.Extension -eq ".$FileExtention"}     

    foreach ($Getfile in $GetFiles){ 
        #if none are foung an empty object is returned filter these by checking if the object exists
        if ($Getfile.Exists -eq $true)
        {
            write-host -NoNewline "processing file : " -ForegroundColor Blue 
            Write-host  "$($Getfile.Name)" -ForegroundColor Green

            # Move file to destination
            Move-Item $Getfile.FullName -Destination $_destinationFolder -Force
    
        }
    }
} 

function Remove-DownloadeFiles([string]$FileExtention) 
{

$GetFiles = get-Childitem -Path "$_sourceFolder" -recurse | Where-Object {$_.Extension -eq ".$FileExtention"}     

    foreach ($Getfile in $GetFiles){ 
        #if none are foung an empty object is returned filter these by checking if the object exists
        if ($Getfile.Exists -eq $true)
        {
            write-host -NoNewline "removing files : " -ForegroundColor Blue 
            Write-host  "$($Getfile.Name)" -ForegroundColor Green

            # Move file to destination
            Remove-Item $GetFile.FullName | Out-Null
    
        }
    }
} 

function Extract-FilesTo([string]$FileExtention,[string]$_destinationFolder) 
{
    $GetFiles = get-Childitem -Path "$_sourceFolder" -recurse | Where-Object {$_.Extension -eq ".$FileExtention"}     

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

function Transfer-FilesTo {
    param(
        [Parameter(Mandatory)]
        [string]$_sourceFolder,
 
        [Parameter(Mandatory)]
        [string]$_targetFolder

        [Parameter(Mandatory)]
        [string]$_targetFolder
    )
    try {

        $Job = Start-BitsTransfer -Source https://Server1.TrustedDomain.com/File1.zip -Destination d:\temp\downloads\ -Asynchronous

        # Poll for status, sleep for 5 seconds, or perform an action.
        while (($Job.JobState -eq "Transferring") -or ($Job.JobState -eq "Connecting")) { Start-Sleep 5; } 

        Switch ($Job.JobState) {
            "Transferred" { Complete-BitsTransfer -BitsJob $Job }
            "Error" { $Job | Format-List } # List the errors.
            default { "Other action" } #  Perform corrective action.
        }

    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    } finally {
        ## Cleanup
        #Invoke-Command -Session $session -ScriptBlock { Remove-Item "$using:localFolderPath\$localZipFilePath" -ErrorAction Ignore }
        #Remove-Item -Path $zipFile.FullName -ErrorAction Ignore
        #Remove-PSSession -Session $session -ErrorAction Ignore
    }
}


function Move-Stuff {
     param(
         [Parameter(Mandatory)]
         [string]$Path,
 
         [Parameter(Mandatory)]
         [string]$DestinationPath
     )
     try {
         ## Zip up the folder
         $zipFile = Compress-Archive -Path $Path -DestinationPath "$Path\($(New-Guid).Guid).zip" -CompressionLevel Optimal -PassThru
 
         ## Create the before hash
         $beforeHash = (Get-FileHash -Path $zipFile.FullName).Hash
 
         ## Transfer to a temp folder
         $destComputer = $DestinationPath.Split('\')[2]
         $remoteZipFilePath = "\\$destComputer\c$\Temp"
         Start-BitsTransfer -Source $zipFile.FullName -Destination $remoteZipFilePath
 
         ## Create a PowerShell remoting session
         $destComputer = $DestinationPath.Split('\')[2]
         $session = New-PSSession -ComputerName $destComputer
 
         ## Compare the before and after hashes
         ## Assuming we're using the c$ admin share
         $localFolderPath = $DestinationPath.Replace("\\$destComputer\c$\",'C:\')
         $localZipFilePath = $remoteZipFilePath.Replace("\\$destComputer\c$\",'C:\')
         $afterHash = Invoke-Command -Session $session -ScriptBlock { (Get-FileHash -Path "$using:localFolderPath\$localZipFilePath").Hash }
         if ($beforeHash -ne $afterHash) {
             throw 'File modified in transit!'
         }
 
         ## Decompress the zip file
         Invoke-Command -Session $session -ScriptBlock { Expand-Archive -Path "$using:localFolderPath\$localZipFilePath" -DestinationPath $using:localFolderPath }
     } catch {
         $PSCmdlet.ThrowTerminatingError($_)
     } finally {
         ## Cleanup
         Invoke-Command -Session $session -ScriptBlock { Remove-Item "$using:localFolderPath\$localZipFilePath" -ErrorAction Ignore }
         Remove-Item -Path $zipFile.FullName -ErrorAction Ignore
         Remove-PSSession -Session $session -ErrorAction Ignore
     }
 }

function TransferFolderWithBits {
    param(
        [Parameter(Mandatory)]
        [string]$_sourceFolder,
 
        [Parameter(Mandatory)]
        [string]$_targetFolder
    )
    try {
        #$Source = "\\lond-rep01\share\"
        #$Destination = "c:\tmp\"
        if ( -Not (Test-Path $Destination)) { $null = New-Item -Path $Destination -ItemType Directory }

        $folders = Get-ChildItem -Name -Path $source -Directory -Recurse
        $bitsjob = Start-BitsTransfer -Source $Source\*.* -Destination $Destination -asynchronous -Priority low
        while ( ($bitsjob.JobState.ToString() -eq 'Transferring') -or ($bitsjob.JobState.ToString() -eq 'Connecting') ) {
            Start-Sleep 4
        }
        Complete-BitsTransfer -BitsJob $bitsjob
        foreach ($i in $folders) {
            $exists = Test-Path $Destination\$i
            if ($exists -eq $false) { New-Item $Destination\$i -ItemType Directory }
            $bitsjob = Start-BitsTransfer -Source $Source\$i\*.* -Destination $Destination\$i -asynchronous -Priority low
            while ( ($bitsjob.JobState.ToString() -eq 'Transferring') -or ($bitsjob.JobState.ToString() -eq 'Connecting') ) {
                Start-Sleep 4
            }
            Complete-BitsTransfer -BitsJob $bitsjob
        }

        $bitsJob | ForEach-Object {
            while ($_.JobState -eq “Transferring”) {
                $pctComplete = [int](($_.BytesTransferred * 100) / $_.BytesTotal);
                clear-host;
                write-progress -activity “File Transfer in Progress” -status “% Complete: $pctComplete” -percentcomplete $pctComplete
                Start-Sleep 10;
            }
        }
 }