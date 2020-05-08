@echo off
:: --------------------------------------------------------------------------------
::   Title:         Magazine Collection
::
::   Commandname:   magCollection.cmd
::
::   Description:   Collect all Magazines to a location
::
::   Dependances:   
::
::   By:            Nick Walker 
::   Date:          28th October 2019
::   Updated:       
::                  
::   Example:       magCollection.cmd
:: --------------------------------------------------------------------------------

  setlocal EnableDelayedExpansion

:: --------------------------------------------------------------------------------

  title Magazine Collection - In progress

  :: // Files and Folders
  set "_folder=%USERPROFILE%\Downloads"
  set "_target=\\bagpuss\public\Magazines\_InProcess\New"
  set "_file=*_downmag*.*"

  :: // Check to see if exist and if not create
  if not exist "%_target%" (
    echo ..Creating Target Folder
    md "%_target%" >> nul: 
  )

  :: // Get the list of files to move
  for /f "tokens=*" %%a in ('dir /b "%_folder%\%_file%"') do (
    echo File: %%a
    move "%_folder%\%%a"  "%_target%" >nul: 2>nul:
    if not exist "%_target%\%%a" (
      echo File: %_target%\%%a - missing
    )
  )

  :: // Delete any duplicates
  for /f "tokens=*" %%a in ('dir /b "%_target%\*(?)*.*"') do (
    echo Delete File: %%a
    del "%_target%\%%a" >nul: 2>nul:
  )



:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

:: --------------------------------------------------------------------------------
:endscript
  endlocal
  color a
  title Command Prompt

:eof  