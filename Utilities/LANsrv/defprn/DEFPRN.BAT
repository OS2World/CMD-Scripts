@ECHO OFF
:: DefPrn, Version 1.01 for Windows NT
:: Store default printer name in environment variable
::
:: Written by Rob van der Woude
:: http://www.robvanderwoude.com
::
REGEDIT /E %TEMP%.\DEFPRINT.REG HKEY_CURRENT_USER\Printers\Settings
FOR /F "TOKENS=1,2* DELIMS==" %%A IN (%TEMP%.\DEFPRINT.REG) DO CALL :Display %%A
DEL %TEMP%.\DEFPRINT.REG
ECHO.
ECHO Default Printer: %DEFPRINT:\\=\%
GOTO:EOF

:Display
SET LINE=%1
FOR %%A IN (%LINE:"= %) DO IF NOT %LINE%==%%A SET DEFPRINT=%%A
GOTO:EOF
