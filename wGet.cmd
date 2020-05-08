@echo off
:: --------------------------------------------------------------------------------
::   Title:         wGet
::
::   Commandname:   wGet.cmd
::
::   Description:   Downloads a file from a URL
::
::   Dependances:   
::
::   By:            Nick Walker 
::   Date:          01st January 2020
::   Updated:       
::                  
::   Example:       magCollection.cmd
:: --------------------------------------------------------------------------------

  setlocal EnableDelayedExpansion

:: --------------------------------------------------------------------------------

  :: // Get variables
  set "_url=%~1"
  set "_outfile=%~2"

  if "%_url%" == "" goto ShowError
  if "%_outfile%" == "" goto ShowError

  :: // Get the list of files to move
  powershell Invoke-WebRequest "%_url%" -OutFile "%_outfile%"

  goto :endscript

:: Error
:ShowError
  echo Required:   URL
  echo             OutFile
  echo.
  echo       eg:  wGet http://URLfile T:\temp\filename.txt
  echo.
:: --------------------------------------------------------------------------------
:: --------------------------------------------------------------------------------

:: --------------------------------------------------------------------------------
:endscript
  endlocal
  color a
  title Command Prompt

:eof  