@echo off
rem                   TC.CMD - John Wunderlin  11-20-1991
rem
rem  - This is an unsupported, unguaranteed, public-domain file.  So there.
rem
rem  this bat will compare two different versions of tlib files
rem  format of command: tc filename oldver newver (deltalist) Optional-Commands
rem                 ex: tc eed.def  3      6      eed.cmp     -t
rem
rem    deltalist is optional, if not specified will display on screen
rem      if a '*' is used for newver, will use the latest version

rem    First parameter will be renamed to 'oldver', second param will be
rem    used so the file name appears somewhere in the delta.

rem    this file may be used as a .bat file with no changes
rem

if exist %1       del %1       >nul
if exist tmp.ver  del tmp.ver  >nul
if exist tmp2.ver del tmp2.ver >nul
if exist oldver   del oldver   >nul

tlib l %1 >tmp.ver
tlib r %1 %2 >nul
ren %1 oldver
tlib r %1 %3 >nul

rem  check if param 4 is blank
if %4. == . goto showdelt

rem otherwise redirect into param 4
compare oldver %1 -w -m4 %5 -l tmp2.ver
copy q:\eis\compress.hp + tmp.cmp + tmp.ver + tmp2.ver %4 >nul
del tmp2.ver >nul
goto end

:showdelt
compare oldver %1 -w -m4 %5

:end
del oldver  >nul
del %1      >nul
del tmp.ver >nul
