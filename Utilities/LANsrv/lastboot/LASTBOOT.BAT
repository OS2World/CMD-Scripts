@ECHO OFF
:: Keep variables local
SETLOCAL

:: Check availability of WMIC.EXE
WMIC.EXE /? >NUL 2>&1 || GOTO Syntax

:: Check if help was requested
ECHO.%* | FIND "?" >NUL 2>&1 && GOTO Syntax

:: Default: local computer
SET Node=%ComputerName%

:: If specified, use remote computer name.
:: If remote computer cannot be reached, return a string of 0s.
IF NOT "%~1"=="" IF /I NOT "%~1"=="/Q" IF NOT "%~1"=="/?" (
	SET Node=%~1
	PING %1 -n 2 2>NUL | FIND "TTL=" >NUL
	IF ERRORLEVEL 1 (
		SET LastBoot=000000000000
		GOTO :Display
	)
)

:: Query the last boot time of the specified computer
FOR /F %%A IN ('ECHO exit^| WMIC.EXE /Node:%Node% /Output:STDOUT Path Win32_OperatingSystem Get LastBootUpTime /Format:TABLE') DO SET LastBoot=%%A

:: Strip off the fraction of seconds
SET LastBoot=%LastBoot:~0,12%

:: Display result in requested output format
:Display
ECHO.%* | FIND /I "/Q" >NUL
IF ERRORLEVEL 1 (
	ECHO Last boot time of %Node%: %LastBoot:~0,4%-%LastBoot:~4,2%-%LastBoot:~6,2% %LastBoot:~8,2%:%LastBoot:~10,2%
) ELSE (
	ECHO.%LastBoot%
)

:: Transfer LastBoot variable to parent environment
ENDLOCAL & SET LastBoot=%LastBoot%

:: Done
GOTO:EOF


:Syntax
ECHO.
ECHO LastBoot.bat,  Version 1.01 for Windows XP Professional and later
ECHO Display last boot time for any WMI enabled computer
ECHO.
ECHO Usage:  LASTBOOT.BAT  [ computer_name ]  [ /Q ]
ECHO.
ECHO Where:  "computer_name"  is an optional remote computer name
ECHO                          (default is the local computer name)
ECHO         /Q               outputs date/time only, in YYYYMMDDhhmm format
ECHO                          (default is message and DD-MM-YYYY, hh:mm format)
ECHO.
ECHO Notes:  Returns a string of 0s if the specified computer cannot be reached.
ECHO         Requires WMIC.EXE, native as of Windows XP Professional.
ECHO         The WMIC command line was generated using the WMI Code Generator,
ECHO         http://www.robvanderwoude.com/wmigen.html
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com

ENDLOCAL

:: Set return code 1
COLOR FF
