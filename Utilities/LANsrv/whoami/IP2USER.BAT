@ECHO OFF
:: Check Windows version
IF NOT "%OS%"=="Windows_NT" GOTO Syntax

:: Keep variables local
SETLOCAL

:: Check command line arguments
SET Host=%1
SET Test=%2
IF NOT DEFINED Host GOTO Syntax
IF     DEFINED Test GOTO Syntax

:: Check validity of command line argument -- uses FINDSTR if available
FINDSTR /? >NUL 2>&1
IF ERRORLEVEL 1 (
	ECHO.%Host% | FIND "/" >NUL
	IF NOT ERRORLEVEL 1 GOTO InvHost
	ECHO.%Host% | FIND "?" >NUL
	IF NOT ERRORLEVEL 1 GOTO InvHost
) ELSE (
	ECHO.%Host%| FINDSTR /R /I "^[a-z0-9][\-_a-z0-9@\.]*$" >NUL
	IF ERRORLEVEL 1 GOTO InvHost
)

:: Check if specified PC is on-line
PING %Host% -n 1 -w 1000 2>NUL | FIND "TTL=" >NUL
IF ERRORLEVEL 1 (
	ECHO.
	ECHO %Host% is off-line
	GOTO:EOF
)

:: Domain or workgroup?
SET Domain=
IF NOT "%UserDomain%"=="%ComputerName%" SET Domain=/Domain

:: Get remote IP address and host name
FOR /F "tokens=2,3" %%A IN ('PING -a %Host% -n 1 -w 500 2^>NUL ^| FIND "["') DO (
	FOR /F "tokens=1 delims=."  %%a IN ('ECHO.%%A') DO SET Host=%%a
	FOR /F "tokens=1 delims=[]" %%a IN ('ECHO.%%B') DO SET IP=%%a
)

:: Display remote computer info
ECHO Host name                    %Host%
ECHO IP address                   %IP%

:: Display remote MAC address
FOR /F "tokens=2 delims==" %%A IN ('NBTSTAT -a %Host%') DO IF NOT "%%A"=="" ECHO MAC Address                 %%A

:: Display remote user name
FOR /F "tokens=1,2 delims== " %%A IN ('NBTSTAT -a %Host% ^| FIND "<03>" ^| FIND /I /V "%Host%"') DO SET User=%%A
IF /I "%Host%"=="%ComputerName%" SET User=%UserName%
NET USER %User% %Domain% 2>NUL | FIND /I " name "

:: Done
GOTO End


:InvHost
ECHO.
ECHO Invalid host name or IP address: %Host%


:Syntax
ECHO.
ECHO IP2User.bat, Version 1.10 for Windows NT4/2000/XP
ECHO Display remote computer and user info
ECHO.
ECHO Usage:  IP2USER  IP_address
ECHO    or:  IP2USER  host_name
ECHO.
ECHO In workgroups the user info is valid only if the
ECHO user ID is identical on all workgroup member PCs.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com

:End
IF "%OS%"=="Windows_NT" ENDLOCAL
