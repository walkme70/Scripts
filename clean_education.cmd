@echo off
pushd T:\Scripts
powershell /nop /nol -executionpolicy bypass -file T:\Scripts\_extract_education.ps1 
powershell /nop /nol -executionpolicy bypass -file T:\Scripts\_sort_educational.ps1 
Robocopy T:\Transfer\Education T:\Transfer\Education /e /move >nul: 2>nul:
popd