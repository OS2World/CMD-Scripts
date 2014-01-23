@echo off
if /%1/ == // goto Usage

set TMP=.
ipfc %1 /inf /d:1 /c:850 /s
goto end

:Usage
echo [37;1m
echo Use this command file to compile a IPF file into a OS/2 INF book
echo If you want to use a codepage different from 850, you should change
echo the /c: switch in the IPFC command line below.
echo [36;1m
echo Note that the /s switch is used to get some size gain vs search speed.
echo However, I didn`t observe a difference of search performance when compiling
echo with and without this option (on my P5/200), so I prefer to use /s.

:end
