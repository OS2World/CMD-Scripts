@echo off
if not x%1==x set color=%1
if not x%color%==x goto parm
echo No color specified
echo Syntax: %0 foreground background
echo Color options are WYMRCGBwymrcgbx. Uppercase=intense color.
goto end
:parm
rem ---------------------------------------------------------------------
rem You must explicitly set up the colors you want to use.
rem This CMD file must branch to code that sets an ANSI code in the prompt
rem which matches the color set by COLOR.EXE.
rem
rem How to set up colors
rem
rem Background values. Set b to one of these:
rem 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=gray
rem Forground values. Set f to one of these for normal intensity:
rem 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=gray
rem High intensity forground colors: Precede the number above with "1;"
rem ---------------------------------------------------------------------
if x%color%==xbw goto bw
if x%color%==xYb goto Yb
if x%color%==xbc goto bc
rem The color will be set but prompt will not be set.
goto doit
rem --------------------------------------------------------------------
rem Settings for each color combination you want to use.
:bc
rem blue on cyan. Was f=34 b=36. Got cyan on black
set f=34
set b=46
goto doit
:bw
rem blue on white.
set f=34
set b=47
goto doit
:Yb
rem Yellow on blue.
set f=1;33
set b=44
goto doit
:doit
rem Put ANSI sequence in prompt
prompt $e[0;%f%;%b%m$p]
set f=
set b=
color %color% & cls
:end
