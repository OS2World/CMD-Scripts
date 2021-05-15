@ECHO OFF
REM ListPRN,  Version 3.00 for Windows NT and OS/2 Warp
REM Lists either specified or all network printers' UNC path
REM Written by Rob van der Woude
REM http://www.robvanderwoude.com

REM Keep all variables local:
SETLOCAL
ECHO.

REM Check command line parameters for question mark, show syntax when found:
IF NOT [%1]==[] (ECHO.%1 | FIND "?" >NUL && GOTO Syntax)

REM OS/2 check:
VER | FIND "/2" >NUL
IF NOT ERRORLEVEL 1 GOTO OS2

:: NT check:
VER | FIND "Windows NT" >NUL
IF ERRORLEVEL 1 GOTO Syntax

:: NT
:: Show all printer's UNC path, or specified printer's only:
FOR /F "skip=3 eol=D tokens=1 delims=\ " %%A IN ('NET VIEW') DO FOR /F %%a IN ('NET VIEW \\%%A ^| FIND " Printer "') DO IF [%1]==[] (ECHO \\%%A\%%a) ELSE (IF /I [%1]==[%%a] ECHO \\%%A\%%a)
GOTO End

:OS2
REM Create temporary batch files:
ECHO SET SRV=%%6>VOER.CMD
ECHO SET SRV=%%4>TYP.CMD
ECHO SET SRV=%%3>CURRENT.CMD
ECHO SET SRV=%%5>ENTER.CMD

REM Create empty temporary file:
TYPE NUL >%TEMP%.\NETPRN.LST

REM List all servers and store the list in a temporary server list:
NET VIEW | FIND "\\\\" >%TEMP%.\NETVIEW.LST
:Loop1
REM Store the first word of the first line from the temporary
REM server list in an environment variable by using the DATE trick:
TYPE %TEMP%.\NETVIEW.LST | DATE | FIND "\\\\" >%TEMP%.\NETVIEW.CMD
CALL %TEMP%.\NETVIEW.CMD

REM Ignore empty lines in the temporary server list:
ECHO [%SRV%] | FIND "[\\\\" >NUL
IF ERRORLEVEL 1 GOTO End

REM List all printers for each server to a temporary
REM printer list (English as well as Dutch):
NET VIEW %SRV% | FIND " Print" >>%TEMP%.\NETPRN.LST
NET VIEW %SRV% | FIND " Afdrukken" >>%TEMP%.\NETPRN.LST

REM Remove the first line from the temporary server list:
TYPE %TEMP%.\NETVIEW.LST | FIND /V "%SRV%" >%TEMP%.\NETVIEW2.LST
DEL %TEMP%.\NETVIEW.LST
REN %TEMP%.\NETVIEW2.LST NETVIEW.LST

REM Check if the temporary server list is empty; loop if not,
REM otherwise go on processing the temporary printer list:
TYPE %TEMP%.\NETVIEW.LST | FIND "\\\\" >NUL
IF ERRORLEVEL 1 GOTO ListUNCs
GOTO Loop1

:ListUNCs
REM Adapt temporary batch files:
ECHO SET NETPRN=%%6>VOER.CMD
ECHO SET NETPRN=%%4>TYP.CMD
ECHO SET NETPRN=%%3>CURRENT.CMD
ECHO SET NETPRN=%%5>ENTER.CMD

REM Remove empty lines from temporary printer list:
TYPE %TEMP%.\NETPRN.LST | FIND " " >%TEMP%.\NETPRN2.LST
DEL %TEMP%.\NETPRN.LST
REN %TEMP%.\NETPRN2.LST NETPRN.LST
:Loop2
REM Store the first word of the first line from the temporary
REM printer list in an environment variable by using the DATE trick:
TYPE %TEMP%.\NETPRN.LST | FIND " " | DATE | FIND ")" >%TEMP%.\NETPRN.CMD
CALL %TEMP%.\NETPRN.CMD

REM Remove leading and trailing spaces from the environment variable:
FOR %%A IN (%NETPRN%) DO SET TEST=%%A

REM Stop if there are no more lines left:
IF [%TEST%]==[] GOTO Cleanup

REM Display UNC path:
ECHO %SRV%\%NETPRN%

REM Remove the first line from the temporary printer list:
TYPE %TEMP%.\NETPRN.LST | FIND /V "%NETPRN%" >%TEMP%.\NETPRN2.LST
DEL %TEMP%.\NETPRN.LST
REN %TEMP%.\NETPRN2.LST NETPRN.LST

REM Stop if there are no more lines left:
TYPE %TEMP%.\NETPRN.LST | FIND " " >NUL
IF ERRORLEVEL 1 GOTO Cleanup
GOTO Loop2

:Cleanup
REM Delete OS/2's temporary files
FOR %%A IN (CURRENT ENTER TYP VOER) DO IF EXIST %%A.CMD DEL %%A.CMD
FOR %%A IN (NETVIEW NETPRN) DO FOR %%B IN (CMD LST) DO IF EXIST %TEMP%.\%%A?.%%B DEL %TEMP%.\%%A?.%%B
GOTO End

:Syntax
ECHO ListPRN,  Version 3.00 for OS/2 Warp and Windows NT
ECHO Displays full UNC path of specified or all network printer(s)
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
ECHO.
ECHO Usage:  LISTPRN  [ ^<printer_share_name^> ]

:End
ENDLOCAL
