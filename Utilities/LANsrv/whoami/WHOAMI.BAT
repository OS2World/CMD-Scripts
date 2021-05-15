@ECHO OFF
:: WhoAmI
:: NT clone of WhoAmI.cmd for OS/2
:: Written by Rob van der Woude
:: http://www.robvanderwoude.com
::
VER | FIND "Windows" >NUL
IF ERRORLEVEL 1 GOTO:EOF
::
FOR /F "tokens=1* delims=." %%A IN ('VER ^| FIND "."') DO (SET MajorVer=%%A&SET MinorVer=%%B)
FOR %%A IN (%majorver%) DO SET MajorVer=%%A
FOR /F "tokens=1* delims=." %%A IN ('ECHO.%minorver%') DO SET MinorVer=%%A
::
ECHO.
ECHO Computer Name        :  \\%computername%
ECHO User Id logged on    :  %username%
ECHO LAN Group            :  %userdomain%
ECHO Major version number :  %majorver%
ECHO Minor version number :  %minorver%
ECHO Logon domain         :  %userdomain%
ECHO Other domains        :  -none-
