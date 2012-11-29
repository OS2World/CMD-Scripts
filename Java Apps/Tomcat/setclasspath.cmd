REM ----------------- BEGIN CONFIG BLOCK -----------------
SET JAVA_BASE=c:\JAVA16
SET JAVA_PATH=c:\JAVA16
SET JAVA_HOME=c:\JAVA16
REM -----------------  END CONFIG BLOCK  -----------------

SET PATH=%JAVA_BASE%\JRE\BIN;%JAVA_BASE%\BIN;%PATH%
SET CLASSPATH=%JAVA_BASE%\lib\tools.jar;%JAVA_BASE%\JRE\LIB\RT.JAR;%JAVA_BASE%\LIB\DT.JAR;%CLASSPATH%
SET INCLUDE=%JAVA_BASE%\INCLUDE;%INCLUDE%
SET LIB=%JAVA_BASE%\LIB;%LIB%
SET LIBRARY_PATH=%JAVA_BASE%\LIB;%LIBRARY_PATH%
SET BEGINLIBPATH=%JAVA_BASE%\JRE\DLL;%BEGINLIBPATH%

rem ---------------------------------------------------------------------------
rem Set CLASSPATH and Java options
rem
rem $Id: setclasspath.bat,v 1.7 2002/04/01 19:51:31 patrickl Exp $
rem ---------------------------------------------------------------------------

rem Make sure prerequisite environment variables are set
if not "%JAVA_HOME%" == "" goto gotJavaHome
echo The JAVA_HOME environment variable is not defined
echo This environment variable is needed to run this program
goto end
:gotJavaHome
if not exist "%JAVA_HOME%\bin\java.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\javaw.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\jdb.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\javac.exe" goto noJavaHome
goto okJavaHome
:noJavaHome
echo The JAVA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end
:okJavaHome

if not "%BASEDIR%" == "" goto gotBasedir
echo The BASEDIR environment variable is not defined
echo This environment variable is needed to run this program
goto end
:gotBasedir
if exist "%BASEDIR%\bin\setclasspath.cmd" goto okBasedir
echo The BASEDIR environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end
:okBasedir

rem Set the default -Djava.endorsed.dirs argument
set JAVA_ENDORSED_DIRS=%BASEDIR%\bin;%BASEDIR%\common\endorsed

rem Set standard CLASSPATH
rem Note that there are no quotes as we do not want to introduce random
rem quotes into the CLASSPATH
set CLASSPATH=%JAVA_HOME%\lib\tools.jar

rem Set standard command for invoking Java.
rem Note that NT requires a window name argument when using start.
rem Also note the quoting as JAVA_HOME may contain spaces.
set _RUNJAVA="%JAVA_HOME%\bin\java"
set _RUNJAVAW="%JAVA_HOME%\bin\javaw"
set _RUNJDB="%JAVA_HOME%\bin\jdb"
set _RUNJAVAC="%JAVA_HOME%\bin\javac"

:end
