@echo off
pushd T:\Scripts
powershell /nop /nol -executionpolicy bypass -file T:\Scripts\cleanup_completed_torrents.ps1 
popd