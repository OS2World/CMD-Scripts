@echo off
:: ClassicRexx - Set up session to run Classic REXX

:: Copyright (c) 2008, 2010 Steven Levine and Associates, Inc.
:: All rights reserved.

:: This program is free software licensed under the terms of the GNU
:: General Public License.  The GPL Software License can be found in
:: gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

:: 11 Mar 08 SHL Baseline
:: 23 Jun 08 SHL Support switching for any default REXX
:: 05 Sep 08 SHL Correct 4OS2 check
:: 24 May 10 SHL Tweak history

if "%@eval[0]" == "0" goto is4xxx
  echo Must run with 4OS2
  pause
  goto eof
:is4xxx

on errormsg pause
setlocal

if "%1" == "-h" .or. "%1" == "-?" goto UsageHelp
if "%@substr[%1,0,1]" == "-" goto UsageError

if "%@search[rexxtry.cmd]" == "" ( echo Can not find rexxtry.cmd %+ beep %+ cancel )

set X=%@execstr[rexxtry parse version v . ; say v]
if "%X" == "REXXSAA" ( echo Already running %X %+ beep %+ cancel )

set REXXDIR=%TMP\CREXX

echo Preparing Classic REXX environment
if not isdir %REXXDIR mkdir %REXXDIR

set DLLDIR=%_BOOT:\os2\dll
set EXEDIR=%_BOOT:\os2
set MSGDIR=%_BOOT:\os2\system
set BOOKDIR=%_BOOT:\os2\book

iff exist %DLLDIR\crexx.dll then
  copy /qu %DLLDIR\crexutil.dll %REXXDIR\rexxutil.dll
  copy /qu %DLLDIR\crexx.dll %REXXDIR\rexx.dll
  copy /qu %MSGDIR\crex.msg %REXXDIR\rex.msg
  copy /qu %MSGDIR\crexh.msg %REXXDIR\rexh.msg
  copy /qu %BOOKDIR\crexx.inf %REXXDIR\rexx.inf
else
  :: Assume default REXX is Classic REXX
  copy /qu %DLLDIR\rexxutil.dll %REXXDIR
  copy /qu %DLLDIR\rexx.dll %REXXDIR
  copy /qu %MSGDIR\rex.msg %REXXDIR
  copy /qu %MSGDIR\rexh.msg %REXXDIR
  copy /qu %BOOKDIR\rexx.inf %REXXDIR
endiff

set OBLP=%BEGINLIBPATH
set OLPS=%LIBPATHSTRICT

set BEGINLIBPATH=%REXXDIR;%BEGINLIBPATH
set LIBPATHSTRICT=T

set PATH=%REXXDIR;%PATH
set DPATH=%REXXDIR;%DPATH
set HELP=%REXXDIR;%HELP
set BOOKSHELF=%REXXDIR;%BOOKSHELF

set DLLDIR=
set EXEDIR=
set MSGDIR=
set BOOKDIR=
set REXXDIR=

history /a rexxtry parse version v ; say 'Running' v

iff %# != 0 then
  %COMSPEC /c %$
else
  echo Classic REXX selected for this session
  echo Type exit to restore
  %COMSPEC prompt %%@execstr[rexxtry parse version v . ; say v] $p$g
endiff

set LIBPATHSTRICT=%OLPS
set BEGINLIBPATH=%OBLP

quit

:: end main

::=== UsageError() Report usage error ===

:UsageError
  beep
  echo Usage: %@lower[%0] `[-h]`
  cancel

::=== UsageHelp() Display usage help ===

:UsageHelp
  echo.
  echo Set up session to run Classic REXX
  echo Requires rexxtry.cmd
  echo Requires TMP defined in environment
  echo Copies Classic REXX files to %TMP\CREXX
  echo.
  echo Usage: %@lower[%0] `[-h] [args...]`
  echo.
  echo `  -h      Display this message`
  echo.
  echo `  arg...  Args passed to Classic REXX session`
  cancel

:eof
