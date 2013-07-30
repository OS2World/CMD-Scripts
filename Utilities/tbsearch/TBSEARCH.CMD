/* TBSEARCH.CMD - Search for file(s) on all available drives */

/* (c) Torus Brokers 1997 */

SIGNAL ON Error
SIGNAL ON Halt

IF LoadRexxUtil() THEN EXIT

CALL SysCls
SAY
SAY

IF Address()<>'CMD' THEN DO
   SAY 'This is not an OS/2 PM application. Nevertheless, it may be used'
   SAY 'within a windowed OS/2 session (CMD.EXE, VIO).'
   SAY
   EXIT
END

ARG args

IF args='' THEN wanted=''

IF args<>'' THEN DO
   PARSE VAR args wanted args
   IF Left(wanted,1)='"' THEN DO
      args=wanted args
      PARSE VAR args '"' wanted '"' args
   END
END

IF args<>'' THEN DO
   SAY 'Too many arguments specified.'
   SAY
   wanted='/?'
END

IF wanted='' | FileSpec('Name',wanted)='' | wanted='/?' | wanted='-?' THEN DO
   SAY 'This program searchs on all available drives for all files that'
   SAY 'match the given specification.'
   SAY
   SAY '   Syntax :'
   SAY
   SAY '   TBSEARCH <file>'
   SAY
   SAY 'Where <file> represents the file(s) to search for. The use of'
   SAY 'wildcards (both * and ?) is allowed. All directories on all'
   SAY 'local and remote drives are scanned, so a specified drive'
   SAY 'or directory will be ignored.'
   SAY
   EXIT
END

drives=SysDriveMap('A:')

IF drives='' THEN DO
   SAY 'There are no drives found. Searching interrupted.'
   SAY
   EXIT
END

drive.0=Words(drives)
k.0=0
k=0
count=0

DO i=1 TO drive.0
   good.i=0
   IF SysDriveInfo(Word(drives,i))<>'' THEN good.i=1
END i

wanted=FileSpec('Name',wanted)

DO i=1 TO drive.0
   IF good.i=0 THEN ITERATE i
   count=count+1
   SAY 'Scanning drive' Word(drives,i)
   profile=Word(drives,i)||'\'||wanted
   rc=SysFileTree(profile,'hit','FOS')
   CALL SysCurPos count+1,17
   hits=Format(hit.0,7)
   IF hit.0>1000 THEN hits=Format((hit.0)/1000,3,3)
   SAY hits 'file(s) found'
   k.0=k.0+hit.0
   IF hit.0>0 THEN DO
      DO j=1 TO hit.0
         k=k+1
         found.k=hit.j
      END j
   END
END i
SAY

IF k=0 THEN DO
   SAY 'No files found.'
   SAY
   EXIT
END

IF k=1 THEN DO
   SAY'One file found :'
   SAY
END

kk=k
IF kk>1 THEN DO
   IF kk>999 THEN kk=Format(kk/1000,,3)
   SAY'There are' kk 'files found :'
   SAY
END

linenrs=count+5

DO i=1 TO k
   addto=0
   IF Length(found.i)>799 THEN addto=addto+1
   IF Length(found.i)>719 THEN addto=addto+1
   IF Length(found.i)>639 THEN addto=addto+1
   IF Length(found.i)>559 THEN addto=addto+1
   IF Length(found.i)>479 THEN addto=addto+1
   IF Length(found.i)>399 THEN addto=addto+1
   IF Length(found.i)>319 THEN addto=addto+1
   IF Length(found.i)>239 THEN addto=addto+1
   IF Length(found.i)>159 THEN addto=addto+1
   IF Length(found.i)>79 THEN addto=addto+1
   addto=addto+1
   IF linenrs+addto>23 THEN DO
      IF linenrs<23 THEN
         DO j=linenrs TO 23
            SAY
         END j
      SAY'--More--'
      pressed=SysGetKey('NOECHO')
      linenrs=0
   END
   SAY found.i
   linenrs=linenrs+addto
END i

EXIT

LoadRexxUtil: PROCEDURE
   IF RxFuncQuery('SysLoadFuncs') THEN DO
      IF RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs') THEN DO
         SAY
         SAY
         SAY 'The RexxUtil library (REXXUTIL.DLL), a part of OS/2, cannot be'
         SAY 'loaded. Possible causes can be :'
         SAY
         SAY '  - REXXUTIL.DLL not in the LIBPATH'
         SAY '  - REXXUTIL.DLL not installed'
         SAY '  - Not enough memory available'
         SAY
         SAY 'Program interrupted.'
         SAY
         RETURN 1
      END
   CALL SysLoadFuncs
   END
RETURN 0

Error:
Halt:
SAY
SAY 'Program interrupted.'
SAY
EXIT

