@ECHO OFF
IF "%OS%"=="Windows_NT" (DSQUERY.EXE User -samid %1 2>&1 | DSGET.EXE User -samid -display 2>&1 | FIND.EXE /I "%~1" && GOTO:EOF)
:Syntax
CLS
ECHO.
ECHO WhoIsIt.bat,  Version 1.00 for Windows 2000 / XP / Server 2003
ECHO Display the full (display) name of the specified domain user ID
ECHO.
ECHO Usage:  WHOISIT  user_id
ECHO.
ECHO Where:  user_id  is the (SAM) user ID whose full name you want to display
ECHO.
ECHO Notes:  Will only work in an Active Directory domain or forest.
ECHO         Requires DSQUERY and DSGET, native tools in Windows Server 2003.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
