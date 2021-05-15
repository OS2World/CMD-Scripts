@ECHO OFF
ECHO.
:: Keep variables local
SETLOCAL

:: Check for exactly one single command line parameter
IF [%1]==[] GOTO Syntax
IF NOT [%2]==[] GOTO Syntax
:: The command line parameter should not contain a question mark
ECHO.%* | FIND "?" >NUL
IF NOT ERRORLEVEL 1 GOTO Syntax
:: The command line parameter should either
:: be a valid user ID or a valid host name
SET ERROR=0
PING %1 -n 1 | FIND " TTL=" >NUL 2>NUL
IF ERRORLEVEL 1 SET ERROR=1
NET USER %1 /DOMAIN >NUL 2>NUL
IF ERRORLEVEL 1 SET /A ERROR = %ERROR% + 1
IF %ERROR%==2 GOTO Syntax

:: Find the primary WINS server
:: * * *  US NT version   * * * ::
FOR /F "tokens=2* delims=:" %%A IN ('IPCONFIG /ALL ^| FIND "Primary WINS Server"') DO SET WINSSRV=%%A
:: * * * Dutch NT version * * * ::
:: FOR /F "tokens=2* delims=:" %%A IN ('IPCONFIG /ALL ^| FIND "Primaire WINS-server"') DO SET WINSSRV=%%A
SET WINSSRV=%WINSSRV:~1%

:: Find the command line parameter in the
:: WINS database and resolve its IP address
FOR /F "tokens=12-13* delims=," %%A IN ('WINSDMP %WINSSRV% 2^>NUL ^| FIND /I "%1 "') DO SET IPADDR=%%A

:: If not found, then exit
IF "%IPADDR%"=="" ECHO No WINS entry found for %1
IF "%IPADDR%"=="" GOTO:EOF

:: Find the host name for the IP address found in WINS
FOR /F "tokens=2* delims= " %%A IN ('PING -a %IPADDR% -n 1 ^| FIND "[%IPADDR%]"') DO SET HOSTNAME=%%A
:: "Escape" ampersands in variable
IF NOT "%HOSTNAME%"=="" SET USERID=%HOSTNAME:&=^&%

:: Find the user ID for the IP address found in WINS
:: * * *  US NT version   * * * ::
FOR /F "tokens=1* delims= " %%A IN ('NBTSTAT -A %IPADDR% ^| FIND "UNIQUE" ^| FIND /I /V "%HOSTNAME% " ^| FIND "<0"') DO SET USERID=%%A
:: * * * Dutch NT version * * * ::
:: FOR /F "tokens=1* delims= " %%A IN ('NBTSTAT -A %IPADDR% ^| FIND "UNIQUE" ^| FIND /I /V "%HOSTNAME%" ^| FIND "<0"') DO SET USERID=%%A
:: "Escape" ampersands in variable
IF NOT "%USERID%"=="" SET USERID=%USERID:&=^&%
:: Display user ID
ECHO User ID            %USERID%

:: Find the full name for this user ID
:: * * *  US NT version   * * * ::
IF NOT "%USERID%"=="" FOR /F "tokens=2* delims=	 " %%A IN ('NET USER %USERID% /DOMAIN ^| FIND "Full Name"') DO SET FULLNAME=%%B
:: * * * Dutch NT version * * * ::
:: IF NOT "%USERID%"=="" FOR /F "tokens=2* delims=	 " %%A IN ('NET USER %USERID% /DOMAIN ^| FIND "Volledige naam"') DO SET FULLNAME=%%B
:: "Escape" ampersands in variable
IF NOT "%FULLNAME%"=="" SET FULLNAME=%FULLNAME:&=^&%
:: Display full name
ECHO Full name          %FULLNAME%

:: Find the user comment
:: * * *  US NT version   * * * ::
IF NOT "%USERID%"=="" FOR /F "tokens=2* delims=	 " %%A IN ('NET USER %USERID% /DOMAIN ^| FIND "User comment"') DO SET COMMENT=%%B
:: * * * Dutch NT version * * * ::
:: IF NOT "%USERID%"=="" FOR /F "tokens=1* delims=	 " %%A IN ('NET USER %USERID% /DOMAIN ^| FIND "Opmerking  "') DO SET COMMENT=%%B
:: "Escape" ampersands in variable
IF NOT "%COMMENT%"=="" SET USERID=%COMMENT:&=^&%
:: Display comment
ECHO Comment            %COMMENT%

:: Find the SID for this user ID (useful when you need
:: to remotely edit the CURRENT_USER registry tree)
FOR /F "skip=2 tokens=6* delims= " %%A IN ('GETSID \\%WINSSRV% %USERID% \\%HOSTNAME% %USERID%') DO SET SID=%%B
:: Display SID
ECHO Security ID        %SID%

:: Display host name and IP address
ECHO Host name          %HOSTNAME%
ECHO IP address         %IPADDR%

:: Find the MAC address for the IP address found in WINS
:: * * *  US NT version   * * * ::
FOR /F "tokens=4* delims= " %%A IN ('NBTSTAT -A %IPADDR% ^| FIND "MAC Address"') DO SET MACADDR=%%A
:: * * * Dutch NT version * * * ::
:: FOR /F "tokens=3* delims= " %%A IN ('NBTSTAT -A %IPADDR% ^| FIND "MAC-adres"') DO SET MACADDR=%%A
:: Display MAC address
ECHO MAC address        %MACADDR%

:: Find the network adapter type
IF NOT "%HOSTNAME%"=="" FOR /F "tokens=1* delims=_" %%A IN ('GETMAC.EXE \\%HOSTNAME% ^| FIND "\Device\"') DO SET ADAPTER=%%B
:: Display adapter type
ECHO Network adapter    %ADAPTER%

:: Find the up-time for this host
FOR /F "Tokens=1* delims=:" %%A IN ('SRVINFO -ns \\%HOSTNAME% ^| FIND /I "System Up Time:"') DO SET UPTIME=%%B
IF NOT "%UPTIME%"=="" SET UPTIME=%UPTIME:~1%
:: Display uptime
ECHO Uptime             %UPTIME%

:: End program
GOTO End

:Syntax
:: Display online help
ECHO.
ECHO WhoRU,  Version 3.11 for Windows NT
ECHO Remote WHOAMI command
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
ECHO Idea by Rob van der Woude and Adriaan Westra
ECHO http://www.westra.speedlinq.nl/
ECHO.
ECHO Usage:  WHORU  ^<user_id^>
ECHO    or:  WHORU  ^<hostname^>
ECHO.
ECHO Returns user ID, full name, comment, security ID
ECHO (SID), hostname, IP address, Mac address, network
ECHO adapter type and up-time
ECHO.
ECHO When a user account is used on more than one
ECHO computer simultaneously, WhoRU will only find
ECHO the first logon (the one that has the messenger
ECHO name).
ECHO.
ECHO Requires GETMAC, GETSID, SRVINFO and WINSDMP from
ECHO the Microsoft Windows NT 4 Server Resource Kit

:End
:: Clear local environment
ENDLOCAL
:: End program
GOTO:EOF
