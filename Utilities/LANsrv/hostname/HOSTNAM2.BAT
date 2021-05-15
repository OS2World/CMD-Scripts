@ECHO OFF
:: Save initial environment
SETLOCAL

ECHO.

:: ============================================
::       check command line parameters
:: ============================================
IF [%1]==[] GOTO Syntax
ECHO.%1 | FIND "?" >NUL
IF NOT ERRORLEVEL 1 GOTO Syntax

:: ============================================
::         check Windows version
:: ============================================
VER | FIND "Windows NT" >NUL
IF ERRORLEVEL 1 GOTO Syntax

:: ============================================
::       set variables to default values
:: ============================================
SET netbiosname=not available
SET domain=not available
SET macaddr=

:: ============================================
::     checking availability of the ip
:: ============================================
PING %1 | FIND "TTL" >NUL
IF ERRORLEVEL 1 GOTO IsNotUp

:: ============================================
::  finding hostname & mac (only on local lan)
:: ============================================
FOR /F "tokens=2 delims= " %%A IN ('PING -a %1 -n 1 ^| FIND "%1" ^| FIND /V "TTL="') DO SET hostname=%%A
FOR /F "tokens=2 delims= " %%A IN ('ARP -a %1 ^| FIND "%1"') DO SET macaddr=%%A
IF [%macaddr%]==[] FOR /F "TOKENS=4" %%A IN ('NBTSTAT -a %1 ^| FIND "="') DO SET macaddr=%%A
IF [%macaddr%]==[] SET macaddr=not available

:: ============================================
::       checking if netbios infos exist
:: ============================================
NBTSTAT -a %1 | FIND "NetBIOS" >NUL
IF ERRORLEVEL 1 GOTO OtherDomain

:: ============================================
::           finding netbios infos
:: ============================================
FOR /F "tokens=1* delims= " %%A IN ('NBTSTAT -a %1 ^| FIND "<20>"')        DO IF NOT [%%A]==[] SET netbiosname=%%A
FOR /F "tokens=1* delims= " %%A IN ('NBTSTAT -a %1 ^| FIND "<00>  GROUP"') DO IF NOT [%%A]==[] SET domain=%%A
GOTO Display

:OtherDomain
IF [%hostname%]==[%1] GOTO Display
ECHO.%hostname% | FIND "." >NUL
IF ERRORLEVEL 1 GOTO Display
CALL :ParseDomain %hostname:.= %

:: ============================================
::              displaying infos
:: ============================================
:Display
ECHO IP Address          = %1
ECHO Mac Address         = %macaddr%
ECHO Host name           = %hostname%
ECHO NetBIOS name        = %netbiosname%
ECHO Domain or workgroup = %domain%

::==============================================
:: saving infos in a txt file for large scanning
:: ECHOed text is TAB delimited
::==============================================
IF NOT EXIST HostDB.txt (ECHO IP	MacAddress	Hostname	NetBIOS	Domain>HostDB.txt)
(ECHO %1	%macaddr%	%hostname%	%netbiosname%	%domain%) >>HostDB.txt

GOTO End

:ParseDomain
IF [%3]==[] (
	SET domain=%1.%2
	GOTO:EOF
) ELSE (
	SHIFT
	GOTO ParseDomain
)
GOTO:EOF

::==============================================
:: ERRORS
::==============================================

:IsNotUp
(ECHO The IP you tried seems to be unreachable) 1>&2
GOTO End

:Syntax
ECHO HostName, Version 2.00 for Windows NT 4
ECHO.
ECHO Displays host name, Mac address, NetBIOS name and
ECHO domain or workgroup name for a specified IP address.
ECHO Writes the results to a file named HostDB.txt as well.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
ECHO Idea by Marcel van der Wal
ECHO http://www.xs4all.nl/~mwal/
ECHO Improvements by Guazzo J-Jacques
ECHO http://www.chez.com/wiz/
ECHO.
ECHO Usage:  HOSTNAME  ^<IP_address^>

:End
:: Restore initial environnement
ENDLOCAL
