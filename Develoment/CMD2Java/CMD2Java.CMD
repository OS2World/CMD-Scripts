/* CMD2Java v2.0.0 */

CALL RxFuncAdd 'SysIni','RexxUtil','SysIni'

file='Rexx2Nrx.jar'
IF Stream(file,'C','QUERY EXISTS')='' THEN DO
   SAY 'Error: execute CMD2Java.CMD in the Rexx2Nrx-directory'
   EXIT
END

cp=Translate(Value('CLASSPATH',,'ENVIRONMENT'))
errors=0
jar.0=2
IF jar.0<1 THEN EXIT
jar.1='NetRexxC.jar'
jar.2='Rexx2Nrx.jar'
DO WHILE cp<>''
   PARSE VAR cp jar ';' cp
   jarfile=Translate(Strip(FileSpec('N',jar)))
   DO i=1 TO jar.0
      IF Translate(jar.i)==jarfile THEN DO
         IF Stream(jar,'C','QUERY EXISTS')='' THEN DO 
            errors=errors+1
            SAY 'Error: file' jar.i 'not found in' FileSpec('D',jar)||FileSpec('P',jar)
         END
         jar.i=''                             
      END
   END i
END
IF errors>0 THEN EXIT
DO i=1 TO jar.0
   IF jar.i<>'' THEN DO
      errors=errors+1
      SAY 'Error: add the full file specification of' jar.i 'to the CLASSPATH'
   END
END i
IF errors>0 THEN EXIT

ver=SysIni('USER','OS2 Kit for Java','CurrentVersion')
IF ver<'1.2' THEN DO
   SAY 'Error: Java-version is not at least 1.2' 
   EXIT
END
dir=SysIni('USER','OS2 Kit for Java',ver)
IF Right(dir,1)==D2C(0) THEN dir=SubStr(dir,1,Length(dir)-1)
IF Pos(':\',dir,2)<>2 THEN DO
   SAY
   SAY 'Enter the base directory of a Java-version which is newer than, or equal'
   SAY 'to, version 1.2. For example: C:\PROGRAMS\JAVA142'
   CALL CharOut '','What is the base directory of Java >= v1.2? '
   PARSE PULL dir
END
dir=Strip(dir)
IF dir='' THEN DO
   SAY 'Error: no directory entered'
   EXIT
END
IF Pos(':\',dir,2)<>2 THEN DO
   SAY 'Error:' dir 'is not a valid full path of a directory'
   EXIT
END
IF Right(dir,1)<>'\' THEN dir=dir||'\'
dir=dir||'BIN'
java=Translate(dir)||'\JAVA.EXE'
IF Stream(java,'C','QUERY EXISTS')='' THEN DO
   SAY 'Error: file JAVA.EXE not found in' dir
   EXIT
END

file='Rexx2Nrx.CMD'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY 'Error: file' file 'already exists'
   EXIT
END

CALL LineOut file,'@echo off'
CALL LineOut file,'rem Rexx2Nrx: The classic REXX to NetRexx converter'
CALL LineOut file,'rem copyright (c) Thomas Schneider, 2000-2002, all rights reserved'
CALL LineOut file,'rem 29.09.2002 : default NetRexx and Java compilation added'
CALL LineOut file,''
CALL LineOut file,java '-ms32M rex_pars %1 %2 %3 %4 %5 %6 %7 %8 %9'
CALL LineOut file,'if errorlevel 99 go to finis' 
CALL LineOut file,'if errorlevel 2 goto finis'
CALL LineOut file,java '-ms32M rex_type %1 %2 %3 %4 %5 %6 %7 %8 %9'
CALL LineOut file,'if errorlevel 99 goto finis'
CALL LineOut file,'if errorlevel 2 goto finis' 
CALL Lineout file,java '-ms32M rex_nrx  %1 %2 %3 %4 %5 %6 %7 %8 %9' 
CALL LineOut file,''
CALL LineOut file,'if errorlevel 99 goto finis'
CALL LineOut file,'if errorlevel 2 goto finis' 
CALL LineOut file,''
CALL LineOut file,'rem ============================================================================='
CALL LineOut file,'rem invoking NetRexx and Java Compiler for translated program' 
CALL LineOut file,'rem ============================================================================='
CALL LineOut file,'nrc %1 -verbose1 -time -nocrossref %2 %3 %4 %5 %6 %7 %8 %9'
CALL LineOut file,'if errorlevel 99 goto fatal'
CALL LineOut file,'if errorlevel 4 goto fatal'
CALL LineOut file,''
CALL LineOut file,'rem NetRexx and Java Compilation finished'
CALL LineOut file,'goto finis'
CALL LineOut file,':fatal'
CALL LineOut file,'rem Fatal error, Java compilation NOT finished'
CALL LineOut file,':finis'
CALL LineOut file
SAY 'Customized eComStation file' file 'created.'

file='rex_nrx.cmd'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY 'Error: file' file 'already exists'
   EXIT
END

CALL LineOut file,java '-ms32M rex_nrx %1 %2 %3 %4 %5 %6 %7 %8 %9' 
CALL LineOut file
SAY 'Customized eComStation file' file 'created.'

file='rex_pars.cmd'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY 'Error: file' file 'already exists'
   EXIT
END

CALL LineOut file,java '-ms32M rex_pars %1 %2 %3 %4 %5 %6 %7 %8 %9' 
CALL LineOut file
SAY 'Customized eComStation file' file 'created.'

file='rex_type.cmd'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY 'Error: file' file 'already exists'
   EXIT
END

CALL LineOut file,java '-ms32M rex_type %1 %2 %3 %4 %5 %6 %7 %8 %9' 
CALL LineOut file
SAY 'Customized eComStation file' file 'created.'

file='nrc.cmd'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY 'Error: file' file 'already exists'
   EXIT
END

CALL LineOut file,'@rem Alias for NetRexxC.cmd'
CALL LineOut file,'@rem own version with preferred options'
CALL LineOut file,'@rem 13.10.2001, Th. Schneider'
CALL LineOut file,'@echo off'
CALL LineOut file,'call netrexxc.cmd %1 -replace -savelog %2 %3 %4 %5 %6 %7 %8 %9'
CALL LineOut file
SAY 'Customized eComStation file' file 'created.'

file='NetRexxC.cmd'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY 'Error: file' file 'already exists'
   EXIT
END

CALL LineOut file,'@REM : Batch file to translate and compile a NetRexx program, and'
CALL LineOut file,'@REM : optionally run the resulting class file'
CALL LineOut file,'@REM :-----------------------------------------------------------------'
CALL LineOut file,'@REM : use as:  NetRexxC hello'
CALL LineOut file,'@REM :'
CALL LineOut file,'@REM :   which will use the NetRexx translator to translate the'
CALL LineOut file,'@REM :   source file hello.nrx to hello.java'
CALL LineOut file,'@REM :   then will use javac to compile hello.java'
CALL LineOut file,'@REM :'
CALL LineOut file,'@REM : Up to eight OPTIONS keywords may be added (with a -) before or'
CALL LineOut file,'@REM : after the file specification, along with the extra flags known'
CALL LineOut file,'@REM : to NetRexxC (such as -keep).   For example:'
CALL LineOut file,'@REM :'
CALL LineOut file,'@REM :    NetRexxC -keep -format -comments hello'
CALL LineOut file,'@REM :'
CALL LineOut file,'@REM : Invoke with no parameters for a full list of flags.'
CALL LineOut file,'@REM :'
CALL LineOut file,'@REM : To run the class after compilation, specify -run as the'
CALL LineOut file,'@REM : first word of the command arguments and the name of the'
CALL LineOut file,'@REM : class as the second word.  Note that the case of the'
CALL LineOut file,'@REM : letters must be exactly correct for this to work, and do not'
CALL LineOut file,'@REM : specify the .nrx extension.  For example:'
CALL LineOut file,'@REM :'
CALL LineOut file,'@REM :    NetRexxC -run hello'
CALL LineOut file,'@REM :'
CALL LineOut file,'@REM : For a more flexible script for this, see NetRexxC.cmd'
CALL LineOut file,'@REM :-----------------------------------------------------------------'
CALL LineOut file,'@REM : 1996.12.28 -- initial version derived from NetRexxC.cmd'
CALL LineOut file,'@REM : 1998.05.25 -- use NETREXX_JAVA as options to java.exe'
CALL LineOut file,'@echo off'
CALL LineOut file,'set netrexxc.cmd_run=no'
CALL LineOut file,"if not '%1'=='-run' goto compile"
CALL LineOut file,'set netrexxc.bat_run=yes'
CALL LineOut file,'shift'
CALL LineOut file,':compile'
CALL LineOut file,java '-ms4M %netrexx_java% COM.ibm.netrexx.process.NetRexxC %1 %2 %3 %4 %5 %6 %7 %8 %9'
CALL LineOut file,'if errorlevel 2 goto quit'
CALL LineOut file,'if %netrexxc.cmd_run%==no goto quit'
CALL LineOut file,'echo Running %1...'
CALL LineOut file,'java %1'
CALL LineOut file,':quit'
CALL LineOut file
SAY 'Customized eComStation file' file 'created.'

prefix='TestFile'
file='TestFile.CMD'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY
   SAY 'The file' file 'exists. You can test your installation by executing ...'
   SAY
   SAY '   Rexx2Nrx' prefix 
   SAY
   SAY '... in the Rexx2Nrx directory. If the file' prefix||'.class is created by'
   SAY 'Rexx2Nrx, then you can test it by executing:'
   SAY
   SAY '   java' prefix
   SAY
END

EXIT
