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

title FileBot - In progress

set "_folder=%~1"
set "_label=%~1"
set "_processType=%~2"
set "_newOutputLocation=%~3"

:: // hostnames
set "_localLocation=%COMPUTERNAME%"
set "_serverLocation=bagpuss"

:: // Set the enviroment
set "_cloudSync=\\%computername%\torrent\Cloud_Sync"
set "_TVLocation=Shows"
set "_localLogLocation=%Temp%\Logs"

if not exist "%_cloudSync%" (
  echo ERROR: Missing Cloud_Sync folder
  goto :EndScript
)
:: --------------------------------------------------------------------------------

  set "_logLocation=\\%_serverLocation%\logs"
  if not exist "%_logLocation%\FileBot" (
    echo INFO: Log location set to local
    set "_logLocation=%_localLogLocation%"
  ) else (
    if exist "%"_localLogLocation%" (
      echo INFO: Transfer local logs to NAS
      robocopy "%_localLogLocation%" "%_logLocation%" /e /move >nul: 2>nul:
    )
  )

:: --------------------------------------------------------------------------------

:: // work out folders if known as set default
if "%_folder%" == "" 		          set "_folder=%_cloudSync%\TVShows"
if "%_folder%" == "movie" 	      set "_folder=%_cloudSync%\Movies"
if "%_folder%" == "movies" 	      set "_folder=%_cloudSync%\Movies"
if "%_folder%" == "4k" 		        set "_folder=%_cloudSync%\Movies (4K)"
if "%_folder%" == "TVPrograms" 	  set "_folder=%_cloudSync%\TVPrograms"

:: --------------------------------------------------------------------------------
  :: // Set default variables
  set "_year=%DATE:~6,4%"
  set "_month=%DATE:~3,2%"
  set "_day=%DATE:~0,2%"
  set "_hour=%TIME:~0,2%"
  set "_min=%TIME:~3,2%"

  :: // Work out the Month Name
  set "m=100"
  for %%m in (January February March April May June July August September October November December) do (
    set /A m+=1
    set month[!m:~-2!]=%%m
  )
  set _monthName=!month[%_month%]!


  :: // Create the logfolder (if not created)
  set "_logFile=%_logLocation%\FileBot\%_year%\%_month% - %_monthName%"
  if not exist "%_logFile%" (md "%_logFile%")

  :: // TVPrograms
  if "%_folder%" == "TVPrograms" ( 
    set "_TVLocation=Programs/New" 
    set "_folder=%_cloudSync%\TVPrograms"
  )

  :: // TVPrograms
  if "%_folder%" == "TVShows_New" ( 
    set "_TVLocation=Shows (New)" 
    set "_folder=%_cloudSync%\TVShows_New"
  )

    if /i "%_processType%" EQU "override" ( set "_excludeList=" )
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
  for /F "delims=" %%i IN ("%_folder%") DO (
    set "_excludeList=%_logLocation%\FileBot\ExcludeList_%%~ni_amc.log"
  )
  echo INFO: ExcludeList is set to '%_excludeList%'

  if not exist "%userprofile%\AppData\Local\Microsoft\WindowsApps\%_filebot%" (
     echo ....ERROR...filebot missing
     goto :EndScript
  )

:processType
  if /i "%_processType%" EQU "OLD" (
    set "_processType=AUTO"
    set "_newOutputLocation=m:\_InProcess\TVShows"
    set "_excludeList="
  )
  if /i "%_processType%" EQU "AUTO" ( goto :filestoprocess )
  if /i "%_processType%" NEQ "move" ( set "_processType=copy" )


:filestoprocess
  echo.
  echo Folders to process:
  dir /b /ad "%_folder%"
  echo.
  echo Location: %_location%
  echo     Type: %_processType%
  echo   Output: %_outputFolder%
  echo.
  if /i "%_processType%" NEQ "Auto" (
    echo ....press any key to continue....
    pause > nul:
  )
  call :RunProcess %_inputFolder%
  goto :EndScript


:RunProcess 
Title FileBot: %~1
  set "_replaceString=replace(':',' -').replace('?','')"
  set "_filebotOptions=%_pushbullet% %_xmbcUpdate% reportError=y artwork=y backdrops=y deleteAfterExtract=n clean=y music=n extras=y excludeList=%_excludeList%"
  set "_seriesFormat=TV/%_TVLocation%/{n}/Season {s.pad(2)} ({airdate.year})/{n} - {s00e00} - {t.%_replaceString%.replacePart (' (Part $1)')} ({vf})"
  set "_movieFormat=Movies/Movies (New)/{y}/{n.%_replaceString%} ({y})/{fn} ({vf})"
  set "_animeFormat=Animations/{n.%_replaceString%}/{fn} ({y})"

  if /i "%_processType%" EQU "AUTO" ( set "_processType=copy" )

  if /i "%_newOutputLocation%" NEQ "" ( set "_outputFolder=%_newOutputLocation%" )

  call %_fileBot% -script fn:amc --output "%_outputFolder%" --log-file "%_filebotLog%" --action %_processType%  --conflict auto -non-strict  --def %_filebotOptions% "seriesFormat=%_seriesFormat%" "animeFormat=%_animeFormat%" "movieFormat=%_movieFormat%" "%_inputFolder%"


exit /b 0


:: --------------------------------------------------------------------------------
:EndScript
  popd
  endlocal
  rem rem color a
  title Command Prompt

:eof  