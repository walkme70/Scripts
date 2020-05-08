
$_datestring = "\\bagpuss\public\Magazines\_InProcess\Zoo UK 13.11.2019.pdf"

$regex = '(?<filedate>\d{2}(?:\.|-|_)?\d{2}(?:\.|-|_)?\d{4})[^0-9]'

    If($_datestring -match $regex) {
        Write-Host "1 - $_datestring"
        $date = $Matches['filedate'] -replace '(\.|-|_)',''
        $date = [datetime]::ParseExact($date,'ddMMyyyy',[cultureinfo]::InvariantCulture)
        write-host "2 - $date"
    
        Write-Host "Name"
        Write-Host "Folder" $_datestring.
        write-host "DD "  $date.Day
        write-host "MM "  $date.Month
        write-host "MM "  (Get-Culture).DateTimeFormat.GetMonthName($date.Month)
        write-host "YY "  $date.Year
    }