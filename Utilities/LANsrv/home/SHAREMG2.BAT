@ECHO OFF
:: Check Windows version and command line arguments
IF "%OS%"=="Windows_NT" (SETLOCAL) ELSE (GOTO Syntax)
IF NOT "%~2"=="" IF /I NOT "%~2"=="/N" GOTO Syntax
ECHO.%* | FIND "?" >NUL && GOTO Syntax
IF "%~1"=="" (SET RemoteSrv=%ComputerName%) ELSE (SET RemoteSrv=%1)
ECHO.%RemoteSrv% | FIND "/" >NUL && GOTO Syntax
PING %RemoteSrv% -n 1 -w 2000 2>&1 | FIND "TTL=" >NUL || GOTO Syntax

:: Run the main script
CSCRIPT //NoLogo sharemg2.vbs %RemoteSrv%

:: For servers with lots of shares a sorted version of the batch file is created
ECHO.
ECHO @ECHO OFF> %RemoteSrv%_recreate_shares_sorted.bat
TYPE %RemoteSrv%_recreate_shares.bat | FIND /I /V "@ECHO OFF" | FIND /I /V "GOTO:EOF" | SORT >> %RemoteSrv%_recreate_shares_sorted.bat
ECHO GOTO:EOF>> %RemoteSrv%_recreate_shares_sorted.bat

:: Done
PAUSE
GOTO:EOF


:Syntax
ECHO.
ECHO ShareMg2.bat,  Version 2.00 for Windows Server 2003
ECHO Helper batch file for ShareMg2.vbs, a script to display and log
ECHO shares on the specified server, and create a batch file to recreate
ECHO these shares.
ECHO Written for migrations of file servers to Windows Server 2003.
ECHO.
ECHO Usage:  SHAREMG2.BAT  [ servername ]
ECHO.
ECHO Where:  "servername"  is the optional name of the server to be probed
ECHO                       (default is local computer name)
ECHO.
ECHO ShareMg2.bat requires ShareMg2.vbs. ShareMg2.vbs creates a batch file
ECHO named servername_recreate_shares.bat, and a text file listing the original
ECHO shares. ShareMg2.bat will also create a sorted version of
ECHO servername_recreate_shares.bat, named servername_recreate_shares_sorted.bat.
ECHO Use the latter to recreate the file shares on a new server. Remove the /GRANT
ECHO part in the batch files to use them with Windows 2000 servers.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
IF "%OS%"=="Windows_NT" ENDLOCAL
