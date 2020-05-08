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
if "%_folder%" == "" goto:endscript
set "_cloudSync=T:\Cloud_Sync"

:: --------------------------------------------------------------------------------

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

:: --------------------------------------------------------------------------------
title Processing Torrent for %_folder%
:: -------------------------------------------------------------=-------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

:filebot

  echo ...Processing Filebot
  set "_inputFolder=%_cloudSync%\%_folder%"
  set "_location=//bagpuss/Media"
  set "_outputFolder=%_location%"
  set "_filebot=filebot.exe"
  set "_filebotLog=%_logFile%\%_day%_amc.log"
  set "_processType=copy"

  
  if /i "%_folder%" == "TVShows_New"    set "_TVfolder=Shows (New)"
  if /i "%_folder:~0,2%" == "TV"        set "_TVfolder=%_folder:~2%"
  if "%_TVfolder%" == ""                set "_TVfolder=%_folder%"
 

:RunProcess 
  set "_filebotOptions=%_pushbullet% %_excludeList% %_xmbcUpdate% reportError=y artwork=y backdrops=y deleteAfterExtract=n clean=y music=n extras=y"
  set "_seriesFormat=TV/%_TVfolder%/{n}/Season {s.pad(2)} ({airdate.year})/{n} - {s00e00} - {t.replace(':',' -').replace('?','').replacePart (' (Part $1)')} ({vf})"
  set "_movieFormat=Movies/Movies (New)/{y}/{n.replace('?','')} ({y})/{fn} ({vf})"
  set "_animeFormat=Animations/{n.replace(':',' -').replace('?','')}/{fn} ({y})"

  call %_fileBot% -script fn:amc --output "%_outputFolder%" --log-file "%_filebotLog%" --action %_processType%  --conflict auto -non-strict  --def %_filebotOptions% "seriesFormat=%_seriesFormat%" "animeFormat=%_animeFormat%" "movieFormat=%_movieFormat%" "%_inputFolder%"

:: --------------------------------------------------------------------------------
:endscript
  popd

  endlocal
  rem rem color a
  title Command Prompt

:eof  