@ECHO OFF
:: Check Windows version
IF NOT "%OS%"=="Windows_NT" GOTO Syntax
:: Check command line arguments
IF      "%~1"==""           GOTO Syntax
IF NOT  "%~2"==""           GOTO Syntax
DSGET.EXE   /? >NUL 2>&1 || GOTO Syntax
DSQUERY.EXE /? >NUL 2>&1 || GOTO Syntax
FINDSTR.EXE /? >NUL 2>&1 || GOTO Syntax
ECHO.%~1 | FINDSTR.EXE /R /I /V /C:"[*?&\|\\/:;, ]" >NUL 2>&1 && GOTO Syntax
ECHO.%~1 | FINDSTR.EXE /R /I /C:"[A-Z0-9_-]"        >NUL 2>&1 || GOTO Syntax

:: Use local variables
SETLOCAL

:: Check if remote PC is on-line
PING %~1 -n 1 -w 2000 2>NUL | FIND "TTL=" >NUL
IF ERRORLEVEL 1 (
	ECHO Computer %1 is off-line
	GOTO End
)

:: Check logged on user and retrieve display name from Active Directory
SET Descr=
FOR /F %%A IN ('NBTSTAT.EXE -a %~1 ^| FIND.EXE "<03>" ^| FIND.EXE /V /I "%~1"') DO (
	FOR /F "tokens=*" %%B IN ('DSQUERY.EXE User -samid %%A 2^>NUL ^| DSGET.EXE User -samid -display 2^>NUL ^| FIND.EXE /I "%%A"') DO SET Descr=%%B
)
IF DEFINED Descr (
	ECHO.%~1	%Descr%
	GOTO End
)

:Syntax
ECHO.
ECHO WhoHasIt.bat,  Version 1.00 for Winows 2000 / XP / Server 2003
ECHO Display the (SAM) user ID and display name for the domain user
ECHO logged on to the specified computer
ECHO.
ECHO Usage:  WHOHASIT  computer_name
ECHO.
ECHO Where:  computer_name  is the host name of the remote
ECHO                        computer to be investigated
ECHO.
ECHO Notes:  Will only work in an Active Directory domain or forest.
ECHO         Requires DSQUERY and DSGET, native tools in Windows Server 2003.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com

:End
IF "%OS%"=="Windows_NT" ENDLOCAL
