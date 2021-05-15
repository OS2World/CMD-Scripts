@ECHO OFF
ECHO.

:: No command line parameters required
IF NOT [%1]==[] GOTO Syntax
:: Tested in Windows 2000 only
VER | FIND "Windows 2000" >NUL
IF ERRORLEVEL 1 GOTO Syntax

:: Read default printer from registry and store in temporary file
REGEDIT /E %TEMP%.\DefPRN.dat "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Windows"
:: Read default printer from temporary file
FOR /F "tokens=2 delims=,=" %%A IN ('TYPE %TEMP%.\DefPRN.dat ^| FIND "Device"') DO SET DefPRN=%%A
:: Remove temporary file
DEL %TEMP%.\DefPRN.dat
:: Remove quotes from variable and display its value
SET DefPRN=%DefPRN:"=%
SET DefPRN

:: Done
GOTO End

:Syntax
ECHO DefPRN2K.bat,  Version 1.00 for Windows 2000
ECHO Display default printer
ECHO.
ECHO Usage:  %~n0
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com

:End
