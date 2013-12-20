/* Creates YARN WPS program object */

CALL RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
CALL SysLoadFuncs

CALL SysCls
SAY
SAY
SAY 'This creates a WPS program object for YARN using the right HOME-setting,'
SAY "if you don't already use a *.CMD file to make sure the right environment" 
SAY 'is used by YARN.'
SAY
SAY

oldhome=Value('HOME',,'ENVIRONMENT')
SAY 'Current HOME in use: "'||oldhome||'"'
SAY
SAY 'Press <ENTER> to use this setting. Or enter the right setting now, for'
SAY 'example: C:\Internet Apps\SOUPER' 
SAY
CALL CharOut '',"What's the HOME directory setting for YARN? "
PARSE PULL home  
home=Strip(home)
IF home='' THEN home=oldhome
IF Left(home,1)='"' THEN PARSE VAR home '"' home '"' .
IF Right(home,1)<>'\' THEN home=home||'\'
config=home||'YARN\config'
IF Stream(config,'C','QUERY EXISTS')='' THEN DO
   SAY
   SAY "Error: file" config "not found in YARN's HOME directory" 
   SAY
   EXIT
END
home=Reverse(home)
PARSE VAR home 1 . 2 home
home=Reverse(home)
home=Translate(home)

CALL SysCls
SAY
SAY
oldexe=Value('YARN',,'ENVIRONMENT')
IF oldexe='' THEN oldexe=Directory()
SAY 'Current directory: "'||oldexe||'"'
SAY
SAY 'Press <ENTER> to use this setting. Or enter the directory where YARN.EXE'
SAY 'now, for example: C:\Internet Apps\Bin' 
SAY
CALL CharOut '',"What's the directory where YARN.EXE is? "
PARSE PULL exe  
exe=Strip(exe)
IF exe='' THEN exe=oldexe
IF Left(exe,1)='"' THEN PARSE VAR exe '"' exe '"' .
IF Right(exe,1)<>'\' THEN exe=exe||'\'
exefile=exe||'YARN.EXE'
IF Stream(exefile,'C','QUERY EXISTS')='' THEN DO
   SAY
   SAY "Error: file" exefile "not found" 
   SAY
   EXIT
END
exefile=Translate(exefile)

CALL SysCls
SAY
SAY
olddir=Word(SysDriveMap('C:','USED'),1)||'\'
SAY 'Current working directory: "'||olddir||'"'
SAY
SAY "Typically this setting isn't important because YARN shouldn't leave files"
SAY "in this directory. Suggestion: use a directory in which you'ld notice any"
SAY 'unexpected new file, or a directory where you may want to UNDELETE files.'
SAY
SAY "Press <ENTER> to use this setting. Or enter the directory where YARN's"
SAY 'file(s) accidently may be created, for example: C:\Internet Apps\Temp' 
SAY
CALL CharOut '',"What's the working directory? "
PARSE PULL dir  
dir=Strip(dir)
IF dir='' THEN dir=olddir
IF Left(dir,1)='"' THEN PARSE VAR dir '"' dir '"' .
dir=Translate(dir)

CALL SysCls
SAY
SAY
tries=0
DO WHILE tries<2
   rc=SysMkDir(dir)
   IF rc=0 THEN tries=tries+2
   IF rc=5 THEN tries=tries+2
   IF rc=3 THEN DO
      dir=Reverse(dir)
      PARSE VAR dir 1 . 2 dir
      dir=Reverse(dir)
      tries=tries+1
   END   
   IF tries=0 THEN DO
      SAY 'Error: cannot create directory' dir
      SAY
      EXIT
   END
END
SAY 'HOME environment setting:' home
SAY 'Executable:' exefile
SAY 'Working directory:' dir
SAY
SAY
setup='OBJECTID=<YARNEXE>;EXENAME='||exefile||';STARTUPDIR='||dir||';SET HOME='||home
rc=SysCreateObject('WPProgram','YARN','<WP_DESKTOP>',setup,'U')
IF rc>0 THEN SAY 'WPS Program object for YARN is created.'
IF rc=0 THEN SAY 'Error: WPS Program object for YARN not created'
SAY
SAY 'Press <ENTER>...'
PULL .
EXIT
