@ECHO OFF
:: Check Windows version -- Windows 2000 or later
IF NOT "%OS%"=="Windows_NT" GOTO Syntax
VER | FIND.EXE "Windows NT" >NUL
IF NOT ERRORLEVEL 1 GOTO Syntax

:: Check command line arguments -- none required
IF NOT "%~1"=="" GOTO Syntax

:: Save a list of ALL shares found on the source server
NET.EXE SHARE > "%~dp0%ComputerName%_originalshares.txt" 2>&1

:: List only the shares that should be recreated on the target server
:: Note: Remove the FINDSTR filters for VPHOME and VPLOGON
::       if Norton AntiVirus is not installed on the servers
NET.EXE SHARE | FIND.EXE /I /V " Spooled " | FINDSTR.EXE /I /V /R /B /C:"PRINT\$" | FINDSTR.EXE /I /V /R /B /C:"IPC\$" | FINDSTR.EXE /I /V /R /B /C:"ADMIN\$" | FINDSTR.EXE /I /V /R /B /C:"[A-Z]\$" | FINDSTR.EXE /I /V /R /B /C:"VPHOME" | FINDSTR.EXE /I /V /R /B /C:"VPLOGON" > "%~dp0%ComputerName%_netshares.txt"

:: Add a prompt for confirmation to the automatically generated batch files
>  "%~dp0%ComputerName%_recreate_shares.bat" ECHO @ECHO OFF
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO CLS
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO ECHO.
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO ECHO You are about to recreate %ComputerName%'s shares.
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO IF /I NOT "%%ComputerName%%"=="%ComputerName%" ECHO This server is NOT the one that generated this batch file.
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO PAUSE
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO VER ^| FIND.EXE "Windows 2000" ^>NUL
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO IF ERRORLEVEL 1 (SET Grant=/GRANT:Everyone,FULL) ELSE (SET Grant=)
>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO ECHO ON

>  "%~dp0%ComputerName%_delete_shares.bat" ECHO @ECHO OFF
>> "%~dp0%ComputerName%_delete_shares.bat" ECHO CLS
>> "%~dp0%ComputerName%_delete_shares.bat" ECHO ECHO.
>> "%~dp0%ComputerName%_delete_shares.bat" ECHO ECHO You are about to delete all shares migrated from %ComputerName%.
>> "%~dp0%ComputerName%_delete_shares.bat" ECHO IF /I NOT "%%ComputerName%%"=="%ComputerName%" ECHO This server is NOT the one that generated this batch file.
>> "%~dp0%ComputerName%_delete_shares.bat" ECHO PAUSE
>> "%~dp0%ComputerName%_delete_shares.bat" ECHO ECHO ON

:: Read the list of shares to be migrated and generate the required batch files
FOR /F "skip=4 tokens=1" %%A IN ('TYPE "%~dp0%ComputerName%_netshares.txt" 2^>NUL ^| FINDSTR.EXE /R /B /I /V /C:"The command completed successfully\." ^| FINDSTR.EXE /R /B /V /C:" " ^| SORT') DO CALL :ReadShare %%A

:: Done
TITLE Ready
GOTO:EOF


:ReadShare
:: Display progress.
TITLE %~1
:: Retrieve the path associated with the share name and add the share to both batch files
FOR /F "tokens=1*" %%a IN ('NET.EXE SHARE %1 2^>NUL ^| FINDSTR.EXE /R /B /I /C:"Path"') DO (
	>> "%~dp0%ComputerName%_recreate_shares.bat" ECHO NET.EXE SHARE %1="%%~b" %%Grant%%
	>> "%~dp0%ComputerName%_delete_shares.bat"   ECHO VER ^| NET.EXE SHARE %1 /DELETE
)
GOTO:EOF


:Syntax
ECHO.
ECHO ShareMig.bat,  Version 1.00 for Windows 2000 / Windows Server 2003
ECHO Prepare a migration of all shares from the current server to a new one.
ECHO.
ECHO Usage:  SHAREMIG.BAT
ECHO.
ECHO When run on a server, this batch file will generate 4 files:
ECHO.
ECHO   %%COMPUTERNAME%%_ORIGINALSHARES.TXT         text file listing ALL shares;
ECHO   %%COMPUTERNAME%%_NETSHARES.TXT              list of shares to be migrated;
ECHO   %%COMPUTERNAME%%_RECREATE_SHARES.BAT        use this batch file to recreate
ECHO                                             the shares on the new server;
ECHO   %%COMPUTERNAME%%_DELETE_SHARES.BAT          undo and test batch file to delete
ECHO                                             the migrated shares again;
ECHO.
ECHO where %%COMPUTERNAME%% is the name of the server this batch file was executed on.
ECHO Usually %%COMPUTERNAME%%_RECREATE_SHARES.BAT is the only file you'll need on the
ECHO new server; %%COMPUTERNAME%%_DELETE_SHARES.BAT is for testing purposes only.
ECHO If all else fails, use the generated text files as a reference for manual
ECHO (re)creation of the shares.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
