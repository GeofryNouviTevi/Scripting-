@echo off
setlocal EnableDelayedExpansion

REM Eviter les problemes d'encodage
chcp 1252 >nul
REM ================= INITIALISATION =================
set BASEPATH=%~dp0
set OUTFILE=%BASEPATH%Etat_Info.txt

REM Nettoyage ancien fichier
if exist "%OUTFILE%" del "%OUTFILE%"

REM ================= DETECTION ADMIN =================
net session >nul 2>&1
if %errorlevel%==0 (
    set ISADMIN=TRUE
) else (
    set ISADMIN=FALSE
)

REM ================= HEADER =================
echo ===================================== >> "%OUTFILE%"
echo  FORENSIC NETWORK SNAPSHOT             >> "%OUTFILE%"
echo  Date        : %DATE% %TIME%           >> "%OUTFILE%"
echo  Computer    : %COMPUTERNAME%           >> "%OUTFILE%"
echo  User        : %USERNAME%               >> "%OUTFILE%"
echo  Domain      : %USERDOMAIN%             >> "%OUTFILE%"
echo  Admin       : %ISADMIN%                >> "%OUTFILE%"
echo ===================================== >> "%OUTFILE%"

REM Fonction section (simulation)
echo. >> "%OUTFILE%"

REM ================= SYSTEM =================

REM ================= USER / MACHINE =================
echo. >> "%OUTFILE%"
echo ========== USER & MACHINE ========== >> "%OUTFILE%"
echo Utilisateur : %USERNAME% >> "%OUTFILE%"
echo Machine     : %COMPUTERNAME% >> "%OUTFILE%"
echo Domaine     : %USERDOMAIN% >> "%OUTFILE%"

REM ================= LOCAL USERS =================
echo. >> "%OUTFILE%"
echo ========== LOCAL USERS ========== >> "%OUTFILE%"
net user >> "%OUTFILE%"

REM ================= SECURITY =================
if "%ISADMIN%"=="TRUE" (
    echo. >> "%OUTFILE%"
    echo ========== WINDOWS DEFENDER ========== >> "%OUTFILE%"
    sc query WinDefend >> "%OUTFILE%"
)

REM ================= NETWORK PROFILE =================
echo. >> "%OUTFILE%"
echo ========== NETWORK PROFILE ========== >> "%OUTFILE%"
netsh lan show interfaces >> "%OUTFILE%"
netsh wlan show interfaces >> "%OUTFILE%"

REM ================= NETWORK INTERFACES =================
echo. >> "%OUTFILE%"
echo ========== NETWORK INTERFACES ========== >> "%OUTFILE%"
ipconfig /all >> "%OUTFILE%"

REM ================= DHCP =================
echo. >> "%OUTFILE%"
echo ========== DHCP CONFIGURATION ========== >> "%OUTFILE%"
netsh interface ip show config >> "%OUTFILE%"

REM ================= ROUTES =================
echo. >> "%OUTFILE%"
echo ========== DEFAULT ROUTE ========== >> "%OUTFILE%"
route print 0.0.0.0 >> "%OUTFILE%"

REM ================= ACTIVE CONNECTIONS =================
echo. >> "%OUTFILE%"
echo ========== ACTIVE TCP CONNECTIONS ========== >> "%OUTFILE%"
netstat -ano | find "ESTABLISHED" >> "%OUTFILE%"

REM ================= VPN / TUNNEL DETECTION =================
echo. >> "%OUTFILE%"
echo ========== VPN / TUNNEL SUSPICION ========== >> "%OUTFILE%"
ipconfig | findstr /I "VPN Tunnel TAP WireGuard Virtual" >> "%OUTFILE%"

echo.
echo === COLLECTE FORENSIQUE TERMINEE ===
pause
