
rem Modify this to your java13 path....
SET JAVA_PATH=c:\java13

rem Unrem these if your default Java is 1.1.x
rem SET PATH=%JAVA_PATH%\JRE\BIN;%JAVA_PATH%\BIN;%PATH%
rem SET BEGINLIBPATH=%JAVA_PATH%\JRE\BIN;%JAVA_PATH%\JRE\DLL;%JAVA_PATH%\BIN;%beginlibpath%
rem SET CLASSPATH=

SET socket=8888
SET INCLUDE=%INCLUDE%../lib/ext;
SET CLASSPATH=%CLASSPATH%;%JAVA_PATH%\lib\tools.jar

for %%f in ( ..\lib\*.jar ) do call addenv CLASSPATH %%f
for %%f in ( ..\lib\ext\*.jar ) do call addenv CLASSPATH %%f

java -Xverify:none -Xms8m -Xmx128m -Dsun.java2d.noddraw -Dfile.encoding=ISO8859_1 com.borland.jbuilder.JBuilder
