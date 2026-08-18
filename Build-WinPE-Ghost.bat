@echo off
title Build WinPE Ghost FR
color 0A
setlocal EnableDelayedExpansion

REM ==================================================
REM Configuration
REM ==================================================

set ARCH=amd64

REM Repertoire du script
set SCRIPT_DIR=%~dp0

REM Suppression du "\" final
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

REM Repertoire de travail temporaire
set WINPE_DIR=C:\GhostPE
set MOUNT_DIR=%WINPE_DIR%\mount

REM Sources Ghost
set GHOST_SOURCE=%SCRIPT_DIR%\Ghost

REM ISO finale
set ISO_FILE=%SCRIPT_DIR%\WinPE_Ghost_FR.iso

REM ==================================================
REM Detection automatique de l'ADK
REM ==================================================

echo.
echo ===== Detection de l'ADK =====

set KITSROOT=

for /f "tokens=2,*" %%A in ('
    reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots" /v KitsRoot10 2^>nul
') do set KITSROOT=%%B

if not defined KITSROOT (
    for /f "tokens=2,*" %%A in ('
        reg query "HKLM\SOFTWARE\Microsoft\Windows Kits\Installed Roots" /v KitsRoot10 2^>nul
    ') do set KITSROOT=%%B
)

if not defined KITSROOT (
    echo [ERREUR] Windows ADK non detecte.
    echo Installer Windows ADK et WinPE Add-on.
    goto :error
)

set ADK_PE=%KITSROOT%Assessment and Deployment Kit\Windows Preinstallation Environment
set DEPLOYTOOLS=%KITSROOT%Assessment and Deployment Kit\Deployment Tools

set DANDI=%DEPLOYTOOLS%\DandISetEnv.bat
set COPYPE=%ADK_PE%\copype.cmd
set MAKEWINPE=%ADK_PE%\MakeWinPEMedia.cmd
set LP_PATH=%ADK_PE%\%ARCH%\WinPE_OCs\fr-FR\lp.cab

echo [OK] ADK detecte :
echo      %KITSROOT%

echo.
echo ==========================================
echo       Construction WinPE Ghost FR
echo ==========================================
echo.
echo Dossier du script : %SCRIPT_DIR%
echo.

REM ==================================================
REM Verification Administrateur
REM ==================================================

net session >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Ce script doit etre lance en Administrateur.
    goto :error
)

echo [OK] Droits administrateur

REM ==================================================
REM Verification prerequis
REM ==================================================

echo.
echo ===== Verification des prerequis =====

if not exist "%DANDI%" (
    echo [ERREUR] DandISetEnv.bat introuvable.
    goto :error
)
echo [OK] DandISetEnv detecte

if not exist "%COPYPE%" (
    echo [ERREUR] Copype.cmd introuvable.
    goto :error
)
echo [OK] Copype detecte

if not exist "%MAKEWINPE%" (
    echo [ERREUR] MakeWinPEMedia.cmd introuvable.
    goto :error
)
echo [OK] MakeWinPEMedia detecte

if not exist "%LP_PATH%" (
    echo [ERREUR] Pack langue fr-FR introuvable.
    goto :error
)
echo [OK] Pack langue FR detecte

if not exist "%GHOST_SOURCE%\Ghost64.exe" (
    echo [ERREUR] Ghost64.exe introuvable.
    echo Verifier : %GHOST_SOURCE%
    goto :error
)
echo [OK] Ghost detecte

REM ==================================================
REM Initialisation environnement ADK
REM ==================================================

echo.
echo ===== Initialisation environnement ADK =====

call "%DANDI%"

if errorlevel 1 (
    echo [ERREUR] Initialisation de l'environnement ADK impossible.
    goto :error
)

echo [OK] Environnement ADK initialise

REM ==================================================
REM Nettoyage anciens montages DISM
REM ==================================================

echo.
echo ===== Nettoyage DISM =====

dism /Cleanup-Mountpoints >nul 2>&1

REM ==================================================
REM Nettoyage dossier de travail
REM ==================================================

echo.
echo ===== Nettoyage =====

if exist "%WINPE_DIR%" (
    rd /s /q "%WINPE_DIR%"
)

echo [OK] Nettoyage termine

REM ==================================================
REM Creation WinPE
REM ==================================================

echo.
echo ===== Creation WinPE =====

call copype %ARCH% "%WINPE_DIR%"

if errorlevel 1 goto :error

REM ==================================================
REM Montage boot.wim
REM ==================================================

echo.
echo ===== Montage du WIM =====

dism /Mount-Image ^
 /ImageFile:"%WINPE_DIR%\media\sources\boot.wim" ^
 /Index:1 ^
 /MountDir:"%MOUNT_DIR%"

if errorlevel 1 goto :error

REM ==================================================
REM Installation du pack FR
REM ==================================================

echo.
echo ===== Installation du pack FR =====

dism /Image:"%MOUNT_DIR%" ^
 /Add-Package ^
 /PackagePath:"%LP_PATH%"

if errorlevel 1 goto :error

dism /Image:"%MOUNT_DIR%" /Set-AllIntl:fr-FR

if errorlevel 1 goto :error

REM ==================================================
REM Suppression du pack EN-US
REM ==================================================

echo.
echo ===== Suppression du pack EN-US =====

set PKG=

for /f "tokens=2 delims=:" %%A in ('
    dism /English /Image:"%MOUNT_DIR%" /Get-Packages ^
    ^| findstr /i "Microsoft-Windows-WinPE-LanguagePack-Package" ^
    ^| findstr /i "en-US"
') do (
    set PKG=%%A
)

set PKG=!PKG: =!

if defined PKG (
    echo Package trouve : !PKG!
    dism /Image:"%MOUNT_DIR%" /Remove-Package /PackageName:!PKG!
)

echo [OK] Langue FR installee

REM ==================================================
REM Installation Ghost
REM ==================================================

echo.
echo ===== Installation Ghost =====

if not exist "%MOUNT_DIR%\Windows\Ghost" (
    md "%MOUNT_DIR%\Windows\Ghost"
)

xcopy "%GHOST_SOURCE%\*" ^
      "%MOUNT_DIR%\Windows\Ghost\" ^
      /E /H /I /Y /Q >nul

if errorlevel 1 goto :error

echo [OK] Fichiers Ghost copies

REM ==================================================
REM Creation winpeshl.ini
REM ==================================================

echo.
echo ===== Configuration WinPE =====

(
echo [LaunchApp]
echo AppPath = %%SYSTEMDRIVE%%\Windows\Ghost\Ghost64.exe
) > "%MOUNT_DIR%\Windows\System32\winpeshl.ini"

REM ==================================================
REM Demontage et sauvegarde
REM ==================================================

echo.
echo ===== Sauvegarde du WIM =====

dism /Unmount-Image ^
 /MountDir:"%MOUNT_DIR%" ^
 /Commit

if errorlevel 1 goto :error

REM ==================================================
REM Compression du WIM
REM ==================================================

echo.
echo ===== Compression du WIM =====

dism /Export-Image ^
 /SourceImageFile:"%WINPE_DIR%\media\sources\boot.wim" ^
 /SourceIndex:1 ^
 /DestinationImageFile:"%WINPE_DIR%\media\sources\boot_new.wim" ^
 /Compress:max

if errorlevel 1 goto :error

del "%WINPE_DIR%\media\sources\boot.wim"

ren "%WINPE_DIR%\media\sources\boot_new.wim" boot.wim

REM ==================================================
REM Creation ISO
REM ==================================================

echo.
echo ===== Creation ISO =====

if exist "%ISO_FILE%" (
    del /f /q "%ISO_FILE%"
)

call MakeWinPEMedia /ISO ^
 "%WINPE_DIR%" ^
 "%ISO_FILE%"

if errorlevel 1 goto :error

echo.
echo ===== Nettoyage du dossier de travail =====

if exist "%WINPE_DIR%" (
    rd /s /q "%WINPE_DIR%"
)

echo [OK] Dossier temporaire supprime

echo.
echo ==========================================
echo               SUCCES
echo ==========================================
echo.
echo ISO creee :
echo %ISO_FILE%
echo.
pause
exit /b 0

:error

echo.
echo ==========================================
echo               ERREUR
echo ==========================================
echo.

dism /Unmount-Image /MountDir:"%MOUNT_DIR%" /Discard >nul 2>&1
dism /Cleanup-Mountpoints >nul 2>&1

pause
exit /b 1