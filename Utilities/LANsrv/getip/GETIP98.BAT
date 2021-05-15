@ECHO OFF
REM GetIP98.bat,  Version 1.00 for Windows 98
REM Display IP address of local machine
REM Written by Rob van der Woude
REM http://www.robvanderwoude.com

NBTSTAT -n | FIND "IpAddress:" > TEMP.BAT
> NODE.BAT ECHO SET IPaddr=%%2
CALL TEMP.BAT
ECHO IP Address: %IPaddr%
DEL TEMP.BAT
DEL NODE.BAT
