function moveAdultFiles {
    Param
    (
        [Parameter(Mandatory)] 
        [String]$_sourcePath,
        [String]$_fileExtension
    )
    
    # // Store Folder contents into a List
    $_adultStars = @(Get-ChildItem -path ($_sourcePath + "\Stars"))
    Write-Host $_adultStars
    
    foreach ($files in Get-ChildItem -Path ($_sourcePath + "\_Sort") -Filter "*.$_fileExtension") {

    ## // show the file to be processed
    writeToScreen "processing file" "$($files.Name)"

    }

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

moveAdultFiles "z:\Adult" "avi"
