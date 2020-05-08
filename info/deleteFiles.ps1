$Temp = @(“C:\Windows\Temp\*”, “C:\Users\*\Appdata\Local\Temp\*”)
Remove-Item $Temp -force -recurse -erroraction "silently"
Clear-Host