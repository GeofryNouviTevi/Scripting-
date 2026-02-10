@echo off
setlocal
REM Eviter les problemes d'encodage ( les caractère bizzare , accent , symbole)
chcp 65001>nul 

REM Recupere le chemin du dossier où se trouve le script et y définit le dossier results a cet emplacement 
set BASEPATH=%~dp0
set RESULTDIR=%BASEPATH%results

REM Vérifie l'existance du dossier results a l'emplacement cherhce, dans le cas contraire le crée 
if not exist "%RESULTDIR%" mkdir "%RESULTDIR%"

REM Récupère le nom de la machine  et la date actuel 
set HOST=%COMPUTERNAME%
set DATE=%DATE:/=-%

REM Definit le chemin où générer le fichier et du script powershell a executer
set LOGFILE=%RESULTDIR%\forensic_%HOST%.log
set PSSCRIPT=%BASEPATH%forensic_snapshot.ps1

REM lance PS depuis son chemein absolu, sans aucun profile utilisateur , en  surpassant la politique d'execution pour lancer les sript 
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

