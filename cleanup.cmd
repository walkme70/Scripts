rem @echo off
setlocal

set "_server=\\bagpuss"
set "_torrentShare=%_server%\torrents"
set "_downloadShare=%_server%\download"
set "_workareaShare=%_server%\workarea"
set "_logfile=%_server%\Logs\Robocopy\%date:~6%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%.log"
set "_logfileError=%_server%\Logs\Robocopy\%date:~6%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%-Error.log"

echo ..Cleaning up the Movies
Call :CleanUpFolder %_downloadShare%\Movies
pause
echo ..Transferring Movies
Call :TransferFiles "%userprofile%\Downloads" "%_downloadShare%\Movies" "*.mp4 *.avi *.mkv"
pause
echo ..Cleaning up the Images
Call :TransferFiles "%userprofile%\Downloads" "%_downloadShare%\Images" "*.jpg *.png" move
pause
echo ..Checking/cleaning up for any Magazines in downloaded areas
Call :TransferFiles "%userprofile%\Documents" "%_workareaShare%\Magazines" "*downmagaz.com*" move
Call :TransferFiles "%userprofile%\Downloads" "%_workareaShare%\Magazines" "*downmagaz.com*" move
Call :TransferFiles "%userprofile%\OneDrive\Documents" "%_workareaShare%\Magazines" "*downmagaz.com*" move
Call :TransferFiles "%_downloadShare%" "%_workareaShare%\Magazines" "*downmagaz.com*"
pause
echo ..Checking for new torrents in downloaded areas
robocopy "%userprofile%\Documents" "%_downloadShare%\Torrents *.torrent /move >nul:
robocopy "%userprofile%\Downloads" "%_downloadShare%\Torrents *.torrent /move >nul:
robocopy "%userprofile%\OneDrive\Documents" %_downloadShare%\torrents *.torrent /move >nul:
pause
echo .. Completed..

goto :endscript

:TransferFiles 
setlocal

    if "%~1" neq "" set "_sourceFolder=%~1"
    if "%~2" neq "" set "_targetFolder=%~2" 
    if "%~3" neq "" set "_extensionSet=%~3" 
    set "_movefile="
    if "%~4" NEQ "" set "_movefile=/move"

if not exist "%~1" exit /b 0

Title "Moving Files: %_sourceFolder% to %_targetFolder%"

pushd "%_sourceFolder%"

if "%_targetFolder%" neq "" set "_logText=with extentions %_extensionSet%"

echo Transfer Files from %_sourceFolder% to %_targetFolder% %_logText% >> %_logFile%
echo -------------------------------------------------------------------------------------------------- >> %_logFile%

robocopy %_sourceFolder% %_targetFolder% "%_extensionSet%" %_movefile% /r:1 /w:1 /dcopy:t /fft /tee /njh /xf thumbs.db /xd "%_sourceFolder%" /log+:%_logFile% 2>> %_logfileError%


:CleanUpFolder 
robocopy "%~1" "%~1" /e /move /log+:%_logFile% 2>> %_logfileError%
if not exist "%~1" md "%~1" >nul:
endlocal
popd
exit /b 0

:RemoveFiles
pushd "%~1"
del "%~2" /s >nul:
popd
endlocal
exit /b 0


:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

::Reference

$source= 'd:\1'
$destination= 'd:\2'
$today = (Get-Date).Date
$yesterday = $today.AddDays(-1)
get-childitem $source -Recurse | where-object { $_.CreationTime -gt $yesterday -and $_.CreationTime -lt $today } | Foreach-Object { robocopy (Split-Path $_.FullName) $destination $_.Name }

:Showerror
  echo "ERROR::::"

:: --------------------------------------------------------------------------------
:endscript
  endlocal
  color a
  title Command Prompt

:eof  

