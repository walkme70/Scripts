<#
.Synopsis
   Run the process filebot 
.DESCRIPTION
    Author - Nick Walker
    Date   - 10 August 2019

    Run the process filebot on a file or folder

.EXAMPLE
    Just run the powershell
    ./processFileBot.ps1 -path {folder} -action Move
    
.NOTES

   The script will log to the file located at $LogFile location which will be deleted

#>


<#
@echo off
:: --------------------------------------------------------------------------------
::   Title:         Process Filebot
::
::   Commandname:   process_filebot.cmd
::
::   Description:   Run the process filebot
::
::   Dependances:   
::
::   By:            Nick Walker 
::   Date:          06th Sept 2019
::   Updated:       
::                  
::   Example:       process_filebot.cmd %folder%
:: --------------------------------------------------------------------------------

setlocal EnableDelayedExpansion

:: --------------------------------------------------------------------------------

set "_folder=%~1"
set "_processType=%~2"

:: // Set the enviroment
set "_localLocation=emily"
set "_serverLocation=bagpuss"
set "_cloudSync=\\%_localLocation%\torrents\Cloud_Sync"
set "_TVLocation=Shows"

:: --------------------------------------------------------------------------------

:: // work out folders if known as set default
if "%_folder%" == "" 		set "_folder=%_cloudSync%\TVShows"
if "%_folder%" == "movie" 	set "_folder=%_cloudSync%\Movies"
if "%_folder%" == "movies" 	set "_folder=%_cloudSync%\Movies"
if "%_folder%" == "4k" 		set "_folder=%_cloudSync%\Movies (4K)"
if "%_folder%" == "TVPrograms" 	set "_folder=%_cloudSync%\TVPrograms"

:: --------------------------------------------------------------------------------
  :: // Set default variables
  set _year=%DATE:~6,4%
  set _month=%DATE:~3,2%
  set _day=%DATE:~0,2%
  set _hour=%TIME:~0,2%
  set _min=%TIME:~3,2%

  :: // Work out the Month Name
  set "m=100"
  for %%m in (January February March April May June July August September October November December) do (
    set /A m+=1
    set month[!m:~-2!]=%%m
  )
  set _monthName=!month[%_month%]!


  :: // Create the logfolder (if not created)
  set "_logFile=\\bagpuss\logs\FileBot\%_year%\%_month% - %_monthName%"
  if not exist "%_logFile%" (md "%_logFile%")


  :: // Transfer local logs to NAS
  if exist "T:\Logs\FileBot" (
    echo "Transfer local logs to NAS"
    robocopy "T:\Logs" "\\bagpuss\logs\FileBot" /e /move >nul: 2>nul: 
  )

  :: // TVPrograms
  if "%_folder%" == "TVPrograms" ( 
    set "_TVLocation=Programs/New" 
    set "_folder=%_cloudSync%\TVPrograms"
  )
:: --------------------------------------------------------------------------------
title Processing Torrent for %_folder%
:: -------------------------------------------------------------=-------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

:filebot
  echo ...Processing Filebot
  set "_inputFolder=%_folder%"
  set "_location=//%_serverLocation%/Media"
  set "_outputFolder=%_location%"
  ::set "_filebot=c:\progra~1\filebot\filebot.exe"
  set "_filebot=filebot.exe"
  set "_filebotLog=%_logFile%\%_day%_amc.log"
  set "_excludeList=%_localLocation%\Torrents\Logs\FileBot\%_year%\%_monthName%_amc.log"

  if not exist "%userprofile%\AppData\Local\Microsoft\WindowsApps\%_filebot%" (
     echo ....ERROR...filebot missing
     goto :EndScript
  )

:processType
  if /i "%_processType%" NEQ "move" ( set "_processType=copy" )

:filestoprocess
  echo.
  echo Folders to process:
  dir /b /ad "%_folder%"
  echo.
  echo Location: %_location%
  echo     Type: %_processType%
  echo.
  echo ....press any key to continue....
  if /i "%_processType%" NEQ "Auto" (pause > nul:)
  call :RunProcess %_inputFolder%
  goto :EndScript


:RunProcess 
Title FileBot: %~1
  set "_filebotOptions=%_pushbullet% %_xmbcUpdate% reportError=y artwork=y backdrops=y deleteAfterExtract=n clean=y music=n extras=y excludeList=%_excludeList%"
  set "_seriesFormat=TV/%_TVLocation%/{n}/Season {s.pad(2)} ({airdate.year})/{n} - {s00e00} - {t.replace(':',' -').replace('?','').replacePart (' (Part $1)')} [{vf}]"
  set "_movieFormat=Movies/Movies (New)/{y}/{n.replace('?','')} ({y})/{fn} [{vf}]"
  set "_animeFormat=Animations/{n.replace(':',' -').replace('?','')}/{fn} ({y})"

  call %_fileBot% -script fn:amc --output "%_outputFolder%" --log-file "%_filebotLog%" --action %_processType%  --conflict auto -non-strict  --def %_filebotOptions% "seriesFormat=%_seriesFormat%" "animeFormat=%_animeFormat%" "movieFormat=%_movieFormat%" "%_inputFolder%"


exit /b 0


:: --------------------------------------------------------------------------------
:endscript
  popd
  endlocal
  rem rem color a
  title Command Prompt

:eof  

#>


