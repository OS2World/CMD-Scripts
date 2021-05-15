@ECHO OFF
:: Check Windows version
IF NOT "%OS%"=="Windows_NT" GOTO Syntax
:: Check command line arguments
IF NOT  "%~1"==""           GOTO Syntax
:: Check if WGET is available
WGET.EXE -V >NUL 2>&1 ||    GOTO Syntax

:: Display a header
ECHO My WAN Connection:
ECHO.==================
:: Use WGET to retrieve your own WAN IP address from a
:: web page, and NSLOOPKUP to get the host name as well
FOR /F %%A IN ('WGET.EXE -q -O- http://www.robvanderwoude.com/wanip.php') DO (
	NSLOOKUP.EXE %%A 2>NUL | MORE /E +3
)

:: Terminate
GOTO:EOF


:Syntax
ECHO.
ECHO WANIP.bat,  Version 4.00 for Windows NT 4 and later
ECHO Display your WAN connection's IP address and host name
ECHO.
ECHO Usage:  WANIP
ECHO.
ECHO Note:   This batch file uses WGET, available at
ECHO         http://www.gnu.org/software/wget/wget.html
ECHO.
ECHO Idea: Gregg Dotoli
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
