@echo off
set "file=t:\cloud_sync\tvshows"

for /F "delims=" %%i IN ("%file%") DO (
echo filepath=%%~pi
echo filename=%%~ni
)