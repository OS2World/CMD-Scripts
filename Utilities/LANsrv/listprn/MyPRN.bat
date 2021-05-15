@ECHO OFF
IF NOT "%1"=="" IF /I NOT "%1"=="/Q" IF /I NOT "%1"=="/V" GOTO Syntax

SETLOCAL
IF /I "%1"=="/V" (SET ViewCmd=CALL :Driver) ELSE (SET ViewCmd=ECHO)

REGEDIT /E %Temp%.\_ListPrn.reg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Printers"

IF /I "%1"=="/Q" GOTO List
ECHO. 1>&2
ECHO Printers installed on this PC: 1>&2
ECHO. 1>&2
IF /I NOT "%1"=="/V" GOTO List
ECHO.Printer:	Driver: 1>&2
ECHO. 1>&2

:List
FOR /F "tokens=7 delims=\" %%a IN ('TYPE %Temp%.\_ListPrn.reg ^| FIND "["') DO FOR /F "tokens=1 delims=]" %%A IN ('ECHO.%%a ^| FIND "]"') DO %ViewCmd% %%A
IF EXIST %Temp%.\_ListPrn.reg DEL %Temp%.\_ListPrn.reg

ENDLOCAL
GOTO:EOF


:Driver
SET Prn=%*
SET Search=%Prn:"=%
IF "%Search:~0,1%"==" " SET Search=%Search:~1%
REGEDIT /E %Temp%.\_ListDrv.reg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Printers\%Search%"
FOR /F "tokens=1* delims==" %%X IN ('TYPE %Temp%.\_ListDrv.reg ^| FIND /I "Printer Driver"') DO SET Driver=%%Y
SET Driver=%Driver:"=%
ECHO.%Prn%	:	%Driver%
GOTO:EOF


:Syntax
ECHO.
ECHO MyPRN.bat,  Version 1.00 for Windows NT 4 / 2000
ECHO Display a list of all printers installed on this PC
ECHO.
ECHO Usage:  %~n0  [ /Q ^| /V ]
ECHO         /Q skip header
ECHO         /V display drivers too ^(tab delimited^)
ECHO.
ECHO Note:   Header is displayed in standard error, so it
ECHO         can be discarded using 2^>NUL
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
