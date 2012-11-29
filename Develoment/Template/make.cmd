@ECHO OFF
REM
REM *** cmd to create BIN\TESTTMP.CMD
REM
SET testFile=TESTTMP.SRC
IF NOT EXIST %testFile% GOTO FileMissing
SET testFile=TEMPLATE.CMD
IF NOT EXIST %testFile% GOTO FileMissing

IF NOT EXIST bin\. md bin
makecmd TESTTMP.SRC .\bin
GOTO Ende

:FileMissing
ECHO.
ECHO. Error: Can not find the file %testFile%!
ECHO.

:Ende