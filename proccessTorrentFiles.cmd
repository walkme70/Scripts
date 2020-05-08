@echo off
move "%USERPROFILE%\Downloads\*.torrent"   T:\Torrents >nul:
PowerShell.exe -ExecutionPolicy Bypass -File T:\Scripts\processTorrentFiles.ps1
