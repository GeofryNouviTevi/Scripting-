@echo off
setlocal
REM Eviter les problemes d'encodage
chcp 65001>nul 

set BASEPATH=%~dp0
set RESULTDIR=%BASEPATH%results

if not exist "%RESULTDIR%" mkdir "%RESULTDIR%"

set HOST=%COMPUTERNAME%
set DATE=%DATE:/=-%

set LOGFILE=%RESULTDIR%\forensic_%HOST%.log
set PSSCRIPT=%BASEPATH%forensic_snapshot.ps1

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" ^
-NoProfile ^
 -ExecutionPolicy Bypass ^
 -File "%PSSCRIPT%" ^
 -ResultPath "%RESULTDIR%" ^
 -HostName "%HOST%" ^
 >> "%LOGFILE%" 2>&1

echo.
echo === COLLECTE FORENSIQUE TERMINEE ===
pause
