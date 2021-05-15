@ECHO OFF
:: Check Windows version and command line arguments
IF NOT "%1"=="" GOTO Syntax
VER | FIND "Windows 2000" >NUL
IF ERRORLEVEL 1 GOTO Syntax

:: Use local environment
SETLOCAL

:: Export list of printers from the registry
START /WAIT REGEDIT.EXE /E %Temp%.\_MyPrn.dat "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Printers"

:: Display header
ECHO.
ECHO Printers installed on this PC:
ECHO.
:: Name is followed by 14 spaces, Port is followed by 2 tabs
ECHO Name             Port		Driver
ECHO ----             ----		------
:: Write header to output file
> %~n0.dat ECHO Name	Share	Port	Driver	Comment	Location

:: List properties for each printer from the list
FOR /F "tokens=7 delims=\" %%a IN ('TYPE %Temp%.\_MyPrn.dat ^| FIND "["') DO FOR /F "tokens=1 delims=]" %%A IN ('ECHO.%%a ^| FIND "]"') DO CALL :Enum "%%A"

:: Remove temporary file
IF EXIST %Temp%.\_MyPrn.dat DEL %Temp%.\_MyPrn.dat

:: Done
ENDLOCAL
GOTO:EOF


:Enum
:: Export list of printer properties to temporary file
START /WAIT RUNDLL32 PRINTUI.DLL,PrintUIEntry /f "%Temp%.\_MyPrn.txt" /Xg /n "%~1"
:: Abort if export failed
IF NOT EXIST "%Temp%.\_MyPrn.txt" GOTO:EOF
:: Initialize variables
SET Name=
SET Share=
SET Port=
SET Driver=
SET Comment=
SET Location=
:: Read single properties from file and store in variables
FOR /F "tokens=1*" %%A IN ('TYPE "%Temp%.\_MyPrn.txt" ^| FIND "PrinterName:"') DO SET Name=%%B
FOR /F "tokens=1*" %%A IN ('TYPE "%Temp%.\_MyPrn.txt" ^| FIND "ShareName:"')   DO SET Share=%%B
FOR /F "tokens=1*" %%A IN ('TYPE "%Temp%.\_MyPrn.txt" ^| FIND "PortName:"')    DO SET Port=%%B
FOR /F "tokens=1*" %%A IN ('TYPE "%Temp%.\_MyPrn.txt" ^| FIND "DriverName:"')  DO SET Driver=%%B
FOR /F "tokens=1*" %%A IN ('TYPE "%Temp%.\_MyPrn.txt" ^| FIND "Comment:"')     DO SET Comment=%%B
FOR /F "tokens=1*" %%A IN ('TYPE "%Temp%.\_MyPrn.txt" ^| FIND "Location:"')    DO SET Location=%%B
:: Set display name Sname to printer name Name plus 16 spaces
SET Sname=%Name%                
:: Use first 16 characters of Sname only
SET Sname=%Sname:~0,16%
:: Display printer name, port and driver name
ECHO.%Sname% %Port%		%Driver%
:: Write printer properties to output file
>> %~n0.dat ECHO.%Name%	%Share%	%Port%	%Driver%	%Comment%	%Location%
:: Remove temporary file
DEL "%Temp%.\_MyPrn.txt"
GOTO:EOF


:Syntax
ECHO.
ECHO MyPRN2K.bat,  Version 1.00 for Windows 2000 / XP
ECHO Display a list of all printers installed on this PC
ECHO.
ECHO Usage:  MYPRN2K
ECHO.
ECHO The result is stored in a tab delimited file named
ECHO MYPRN2K.DAT, located in the current directory.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
