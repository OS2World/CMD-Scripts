@ECHO OFF
:: RestHome,  Version 1.20 for Windows NT 4
:: Written by Rob van der Woude
:: http://www.robvanderwoude.com
:: Locally restore shares of all home directories
:: Modify drive and path if necesary

CD /D D:\USERS\HOME
FOR /D %%A IN (*) DO NET SHARE %%A=D:\USERS\HOME\%%A
FOR /D %%A IN (*) DO NET USER %%A /HOMEDIR:\\SERVER\%%A /PROFILEPATH:\\SERVER\D$\USERS\PROFILES\%%A /DOMAIN
:: FOR /D %%A IN (*) DO CACLS D:\USERS\HOME\%%A /T /C /P /G Administrators:F
FOR /D %%A IN (*) DO CACLS D:\USERS\HOME\%%A /T /C /E /G %%A:C
