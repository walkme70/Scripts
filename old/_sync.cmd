@echo off
:: --------------------------------------------------------------------------------
::   Title:         FileSync
::
::   Commandname:   _Sync.cmd
::
::   Description:   Sync folder for a backup perpose
::
::   Dependances:   
::
::   By:            Nick Walker 
::   Date:          27th October 2019
::   Updated:       
::                  
::   Example:       _Sync.cmd
:: --------------------------------------------------------------------------------

  setlocal EnableDelayedExpansion

:: --------------------------------------------------------------------------------

  title SyncBackup - In progress

  set "_folder=%~1"
  if /i "%_folder%" == "Task" goto :TaskUpdate

  :: // hostnames
  set "_localLocation=%COMPUTERNAME%"
  set "_serverLocation=bagpuss"
  set "_backupLocation=yaffle"

:: --------------------------------------------------------------------------------

  :: // robocopy settings 
  set "_rc_ext=*.mkv *.avi *.mp4 *.m4v"
  set "_rc_opt=/s /r:1 /w:1 /dcopy:t /fft /tee /njh"
  set "_rc_xf=/xf thumbs.db /xf .*"
  ::set "_rc=xd=/xd"
  ::set "_rc_mir=/mir"

:: --------------------------------------------------------------------------------

  :: // source & target volumes
  set "_deviceName=Media_Volume"
  set "_source=\\%_serverLocation%\media"
  set "_target=\\%_backupLocation%\media"

:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

  call :FolderDuplicate "TV" 
  call :FolderDuplicate "Music"

  call :FolderDuplicate "Movies\Animations"
  call :FolderDuplicate "Movies\Movies (Archive)"
  call :FolderDuplicate "Movies\Disney"
  call :FolderDuplicate "Movies\Childrens"

  goto :endscript

:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

:FolderDuplicate
  setlocal
    Title Media-Sync: %~1 to %_deviceName%
  
    set "_sourceFolder=%_source%\%~1"
    set "_targetFolder=%_target%\%~1"
    
    if exist "%_sourceFolder%" (
      if exist "%_targetFolder%" (
        
        robocopy "%_sourceFolder%" "%_targetFolder%" %_rc_ext% %_rc_opt% %_rc_mir% %_rc_mir% %_rc_xf% /log+:%_target%\log.txt 2>> %_target%\error.txt
  
      ) else (
        echo ERROR: Target folder not available...
      )
    
    ) else (
      echo ERROR: Source folder not available...
    )

  
  endlocal & exit /b 0


:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------


:: --------------------------------------------------------------------------------
:endscript
  endlocal
  color a
  title Command Prompt

:eof  