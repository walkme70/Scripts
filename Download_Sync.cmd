@echo off
:: --------------------------------------------------------------------------------
::   Title:         Run Sync from Timberland
::
::   Commandname:   Download_Sync.cmd
::
::   Description:   Depending on the time run a sync download
::
::   Dependances:   
::
::   By:            Nick Walker 
::   Date:          06th Sept 2019
::   Updated:       30th Oct 2019
::                  
::   Example:       Download_Sync.cmd
:: --------------------------------------------------------------------------------

  setlocal EnableDelayedExpansion

:: --------------------------------------------------------------------------------

  echo Torrent Sync
  title TorrentSync - In progress

  set "_folder=%~1"
  if /i "%_folder%" EQU "Task" goto :TaskUpdate

  :: // hostnames
  set "_localLocation=%COMPUTERNAME%"
  set "_serverLocation=bagpuss"

  :: // Set the locations
  set "_torrentDrive=T:"
  if not exist "%_torrentDrive%"   set "_torrentDrive=\\%hostname%\Torrent"
  set "_torrentScripts=%_torrentDrive%\Scripts"
  set "_torrentLocation=%_torrentDrive%\Torrents"
  set "_torrentCloudSync=%_torrentDrive%\Cloud_Sync"
  set "_torrentTemp=%_torrentDrive%\Temp"
 
  set "_localLogLocation=%_torrentDrive%\Logs"

  set "_winSCP=%OneDrive%\Portable\WinSCP-5"
  set "_winSCP=\\%_serverLocation%\software\Utilites\Portable\WinSCP-5"
  if not exist "%_winSCP%" (set "_winSCP=D:\Apps\WinSCP-5")

  set "_username=walkme70_4111"
  set "_password=zutaboha40"
  :: set "_username=walkme70"
  :: set "_password=hbnTswiVqscc"
  set "_url=watson.myseedbox.site"
  :: set "_url=walkme70-rutorrent38.cp09.cloudboxes.io"
  :: set "_port=63109"
  set "_ftpString=%_username%:%_password%@%_url%/"

:: --------------------------------------------------------------------------------

  set "_logLocation=\\%_serverLocation%\logs"
  if not exist "%_logLocation%\WinSCP" (
    echo INFO: Log location set to local
    set "_logLocation=%_localLogLocation%"
  ) else (
    if exist "%_localLogLocation%" (
      echo INFO: Transfer local logs to NAS
      robocopy "%_localLogLocation%" "%_logLocation%" /e /move >nul: 2>nul:
    )
  )

:: --------------------------------------------------------------------------------
  set "_excludeTorrentLogs=%_logLocation%\FileBot\ExcludeTorrentFolder.log"
:: --------------------------------------------------------------------------------

  set "_logFile=%_logLocation%\WinSCP\%_url%"
  set "_fileMaskExclusion=*.cmd; *.meta; *.exe; *.nfo; *.txt; *.png; Screen/; Freeleach/"
  set "_fileMask=*>=1D; *>1k | %_fileMaskExclusion%"
  set "_processFilebot=Yes"

:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

  :: // Set default variables
  set _year=%DATE:~6,4%
  set _month=%DATE:~3,2%
  set _day=%DATE:~0,2%
  set _hour=%TIME:~0,2%
  set _min=%TIME:~3,2%

  :: echo Current time is %_hour% and Minute is %_min%
  :: echo Current date is %_year%, %_month% and %_day%

  :: // Work out the Month Name
  set "m=100"
  for %%m in (January February March April May June July August September October November December) do (
    set /A m+=1
    set month[!m:~-2!]=%%m
  )
  set _monthName=!month[%_month%]!

:: --------------------------------------------------------------------------------
  :: // check to see if it still running
  set "_processFile=%_torrentDrive%\__downloadRunning.inf"
  set "_processLogFile=%_logFile%\%_year%\%_month% - %_monthName%\%_monthName%_processes_%_day%.log"

  if not exist "%_processFile%" ( 	
    echo Running Download Script on %USERNAME% from %COMPUTERNAME% at %_year%-%_month%-%_day% - %_hour%-%_min% > "%_processFile%"
  ) else (    
    call :processLog "Already Running"
    goto :EndScript
  )

:: --------------------------------------------------------------------------------

:: --------------------------------------------------------------------------------
  call :processLog "%USERNAME% from %COMPUTERNAME% Started downloading"
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

  if /i "%_folder%" EQU ""          ( goto :default_sync )
  if /i "%_folder%" EQU "AUTO"      ( goto :default_sync )
  if /i "%_folder%" EQU "Movies"    ( goto :MovieRun )
  if /i "%_folder%" NEQ ""          ( call :RunCommand "%_folder%" )
  if /i "%_folder%" EQU "E"         ( call :RunCommand "Education" )

  goto :EndScript
 
:: --------------------------------------------------------------------------------

:default_sync

  :: // default sync
  call :RunCommand "Education"
  call :RunCommand "TVShows"
  call :RunCommand "TVShows_New"
  call :RunCommand "TVPrograms"
  call :RunCommand "Adult"

  :: // Run the command depending on the time
  if "%_min%" == "15"        call :MovieRun

  call :RunCommand "Watch"

 :Upload
  echo ..Uploading..
  call :RunCommand "Upload"
  del "%_torrentLocation%\*.torrent" /s >nul: 2>nul:
  call :cleanPath "%_torrentLocation%" ADD
 
  goto :endScript

  :MovieRun
  call :RunCommand "Movies"
  call :RunCommand "Movies 4K"
  call :RunCommand "Movies4K"
  exit /b 0

  :: // Run the sync script
  :RunCommand 
    setlocal
    set "_folder=%~1"
    title Downloading from %_folder%
    echo Processing section folder %_folder% >> "%_processFile%"

    :: // set the default Win_SCP settings
    set "_remotePath=/downloads/completed/%_folder%"
    set "_localPath=%_torrentCloudSync%\%_folder%"
    set "_direction=local"

    :: // if not upload folder 
    if /i "%_folder%" EQU "upload" (
      set "_remotePath=/downloads/watch"
      set "_localPath=%_torrentLocation%"
      set "_direction=remote"
      set "_delete="
      ::set "_fileMask=*.torrent | %_fileMaskExclusion%"
      %comspec% /c "%_torrentLocation%\proccessTorrentFiles.cmd"
      Call :CleanPath "%_localPath%"
    )

    if /i "%_folder%" EQU "Watch" (
      echo ..Cleaning up watch folder..
      Call :makeFolder "%_torrentCloudSync%\Watch"
      set "_remotePath=/downloads/watch"
      set "_localPath=%_torrentCloudSync%\Watch"
      set "_direction=remote"
      set "_delete=-delete"
      ::set "_fileMask=*.torrent | *.cmd; %_fileMaskExclusion%"
      Call :CleanPath "%_localPath%"
    )

    :: // if not upload folder 
    if /i "%_folder%" EQU "Adult" (
      set "_localPath=%_torrentTemp%\%_folder%"
      set "_fileMask=*>=1D; *>1k | %_fileMaskExclusion%"
      set "_processFilebot=No"
      set "_delete=-delete"
    )

    :: // if not upload folder 
    :: if /i "%_folder%" EQU "TVPrograms" (
    ::  set "_processFilebot=Yes"
    :: )
	
    :: // if not upload folder 
    :;if /i "%_folder%" EQU "Movies" (
    ::  set "_fileMask=*>=1D; *>1k | %_fileMaskExclusion%"
    ::)

    :: // if not upload TVShows
    if /i "%_folder%" EQU "TVShows" (
    ::  set "_fileMask=*>=1D; *>1k | %_fileMaskExclusion%"
      set "_delete=-delete"
    )
      
    :: // if not upload Education 
    if /i "%_folder%" EQU "Software" (
      set "_delete=-delete"
      set "_processFilebot=No"
    )
    :: // if not upload Education 
    if /i "%_folder%" EQU "Education" (
      set "_delete=-delete"
      set "_processFilebot=No"
    )

    :: // Create the logfolder (if not created)
    set "_logFile=%_logFile%\%_year%\%_month% - %_monthName%\%_folder%"
    Call :makeFolder "%_logFile%"

    :: // Create local folder if not exist
    Call :makeFolder "%_localPath%"

    :: // update logfile
    call :processLog "Processing %_folder%"

    :: // Run the sync command
    title Downloading from %_folder%
    %comspec% /c %_winscp%\winscp.com /log="%_logFile%\%_folder% - %_day%-%_month%-%_year%.log" /synchronize /command ^
      "open sftp://%_ftpString%" ^
      "synchronize -filemask=""%_fileMask%"" %_direction% %_delete% -neweronly ""%_localPath%"" ""%_remotePath%""" ^
      "exit" ^
      "Downloading from %_folder%"

    :: // run a clean up on the local folder
    Call :CleanPath "%_localPath%"
    Call :removeFolder "%_localPath%"

    :: // Log which folders / files downloaded
    if exist "%_localPath%" (
      if /i "%_folder%" EQU "upload" (
        for /f "tokens=*" %%a in ('dir /b "%_localPath%\*.torrents"') do ( Call :processLog "- Uploading: %%a" )
      ) else (
        for /f "tokens=*" %%a in ('dir /b "%_localPath%"') do ( Call :processLog "- Downloaded: %%a" )
      ) 
    )

    :: // if TVShows or Movies then run FileBot
    if /i "%_processFilebot%" EQU "Yes" (
      if exist "%_torrentCloudSync%\%_folder%" (
        if exist "\\%_serverLocation%\media" (
      	  %comspec% /c "%_torrentScripts%\process_filebot.cmd %_torrentCloudSync%\%_folder% AUTO
          Echo %_folder% >> "%_excludeTorrentLogs%"
        )
      )	
    )
    endlocal & exit /b 0

:removeFolder
  setlocal
  set "_folderToRemove=%~1"
  if  exist "%_folderToRemove%" (rd "%_folderToRemove%" >nul: 2>nul:)
  endlocal & exit /b 0

:makeFolder
  setlocal
  set "_folderToMake=%~1"
  if not exist "%_folderToMake%" (md "%_folderToMake%" >nul: 2>nul:)
  endlocal & exit /b 0

:cleanPath
  setlocal
  set "_folderToClean=%~1"
  set "_tooADD=%~2"
  if exist "%_folderToClean%" (%comspec% /c robocopy "%_folderToClean%" "%_folderToClean%" /e /move >nul: 2>nul:)
  if "%_tooADD%" EQU "ADD" (%comspec% /c md "%_folderToClean%" >nul: 2>nul:)
  endlocal & exit /b 0

:processLog
  setlocal
  set "_hour=%TIME:~0,2%"
  set "_min=%TIME:~3,2%"
  echo [%_year%-%_month%-%_day% - %_hour%-%_min%] :: %~1 >>"%_processLogfile%"
  endlocal & exit /b 0

:endScript
  if exist "%_processFile%" ( del "%_processFile%" >nul: 2>nul: )
  call :processLog "%USERNAME% from %COMPUTERNAME% Completed..."
  title Command Prompt

:TaskUpdate
  set "_nextTaskRun=%_torrentDrive%\downloadTaskInfo.inf"
  if /i "%COMPUTERNAME%" EQU "vm-emily" (
    echo Fetching next task info..
    powershell.exe "(Get-ScheduledTask -taskname 'Process Download') | Get-ScheduledTaskInfo | Out-File %_nextTaskRun%"
    type "%_nextTaskRun%" | find "RunTime"
  ) else (
    echo ERROR:  Need to run from emily
  )
  
 :eof
  endlocal

::  Next steps
::
::   Filebot 
::    -  create a list of each folder and check to see if it's in the list and if not then process
::
::
::    Upload
::    - Clean the local folders
::    - create a list of visiable and create an exclude list in filemask
::    - WinSCP remote to clear out the torrentbox
