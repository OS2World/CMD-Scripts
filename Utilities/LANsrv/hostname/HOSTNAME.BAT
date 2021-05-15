@ECHO OFF
ECHO.
IF [%1]==[] GOTO Syntax
ECHO.%1 | FIND "?" >NUL
IF NOT ERRORLEVEL 1 GOTO Syntax
FOR /F "tokens=2 delims= " %%A IN ('PING -a %1 -n 1 ^| FIND "[%1]"') DO ECHO.%%A
GOTO:EOF

:Syntax
ECHO HostName, Version 1.10 for Windows NT
ECHO Find host name for specified IP address
ECHO.
ECHO Usage:  HOSTNAME  ^<IP_address^>
ECHO.
ECHO Idea by Marcel van der Wal
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
