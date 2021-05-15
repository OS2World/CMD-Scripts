@ECHO OFF
ECHO.

REM Check command line
IF NOT [%1]==[] GOTO Syntax

REM Check OS version
IF "%OS%"=="Windows_NT" GOTO NT
VER | FIND "/2" >NUL
IF NOT ERRORLEVEL 1 GOTO OS2

:Syntax
ECHO GetIP.cmd, Version 3.00 for Windows NT 4/2000/XP and OS/2 Warp/eCS
ECHO Display this computer's IP address
ECHO.
ECHO Usage:  GETIP.CMD
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
GOTO End

REM Note: write access in the current directory is
REM       required to create temporary batch files!
:OS2
REM Create temporary batch file to get IP address
IFCONFIG lan0 | FIND /I " INET " >TEMP.CMD
REM Create secondary batch file to retrieve IP address from first one
> INET.CMD ECHO @ECHO OFF
>>INET.CMD ECHO SET IPADDR=%%1
>>INET.CMD ECHO ECHO IP address: %%IPADDR%%
REM Call temporary batch files to display IP address
REM and store it in environment variable
CALL TEMP.CMD
REM Clean up
DEL  TEMP.CMD
DEL  INET.CMD
GOTO End

:NT
:: Note: the following code will extract only the last IP address from the list
FOR /F "TOKENS=2* DELIMS=:" %%A IN ('IPCONFIG /ALL ^| FIND "IP Address"') DO FOR %%B IN (%%A) DO SET IPADDR=%%B
ECHO IP address: %IPADDR%

:End
