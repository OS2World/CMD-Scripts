@echo off
REM *************************
REM NewDlg v1.1a Patch script
REM  (C)opyright Tomas ™gren
REM   stric@freenet.hut.fi
REM *************************

if .%1.==.. goto NoParams
if .%2.==.. goto NoParams
if not exist %1 goto FileNotFound
set res=NONE
if .%2.==.SMALL. set res=256.4S
if .%2.==.LARGE. set res=256.4L
if .%res%.==.NONE. goto WrongParams

call resmgr -a %1 %res%
echo Patch applied!
goto TheEnd

:FileNotFound
echo Error: %1: File not found!
goto Usage

:WrongParams
echo Error: Second parameter should be LARGE or SMALL, nothing else.
goto Usage

:NoParams
echo Error: Not enough parameters!
goto Usage

:Usage
echo.
echo Usage: PATCH.CMD dll_filename LARGE/SMALL
echo.
echo See file Readme for more information

:TheEnd
