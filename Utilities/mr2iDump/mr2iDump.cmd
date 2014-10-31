@echo off
:: mr2idump - Prepare for mr2/ice process dump
::	      Run as mr2idump ? for usage help

:: Copyright (c) 2004, 2005 Steven Levine and Associates, Inc.
:: All rights reserved.

:: This program is free software licensed under the terms of the GNU
:: General Public License.  The GPL Software License can be found in
:: gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

rem $TLIB$: $ &(#) %n - Ver %v, %f $
rem TLIB: $ $

:: 01 Apr 04 SHL Baseline
:: 12 Apr 04 SHL Add sysvm
:: 12 Apr 04 SHL Add sysldr

:: Version 0.1

setlocal

:: Edit this to point to existing directory on drive with sufficient free space
set D=j:\tmp\dumps

:: Try to validate
dir %D%\nul >nul 2>&1
if errorlevel 1 goto BadDir

:: Edit this to name process to be dumped
set P=mr2i

if not "%2" == "" goto Help
if "%1" == "o" goto TurnOff
if "%1" == "O" goto TurnOff
if "%1" == "p" goto Configure
if "%1" == "P" goto Configure
if "%1" == "" goto Reset
goto Help

:: Reset and set dump directory

:Reset
echo on
:: Reset to defaults
procdump reset /f /l
@if errorlevel 1 pause

:: Configure dump settings for mr/2 ice

:Configure

:: Turn on dump facility - set dump directory
procdump on /l:%D%
@if errorlevel 1 pause
:: Configure mr/2 ice dump
procdump set /proc:%P% /pd:instance,private,sem,shared,summ,sysfs,sysio,sysldr,sysvm /pc:0
@if errorlevel 1 pause
:: Check
procdump query
@if errorlevel 1 pause
@echo off
echo Dump facility configured to dump %P% to %D%

goto end

:TurnOff

echo on
:: Reset to defaults
procdump reset /l
@if errorlevel 1 pause
procdump reset /pid:all
@if errorlevel 1 pause
:: Turn off
procdump off
@if errorlevel 1 pause
procdump query
@if errorlevel 1 pause
@echo off
echo Dump facility turned off
goto end

:BadDir
  echo %D% does not exist - check set D= statement
  goto end

::=== Help: Show usage help ===

:Help
  echo.
  echo Usage: mr2idump [o] [p]
  echo.
  echo   o     Turn off dump facility
  echo   p     Retain personal dump settings
  echo   ?     This message`
  echo.
  echo   Only one arg alllowed
  echo   Default is to clear personal settings and configure mr/2 ice specfic settings

:end
