/* OS2JOBJ.CMD - CREATE OS/2 program objects on desktop for various Java
                 applications.  Copyright 1998, Charles H. McKinnis */
Trace('N')

/* check for OBJREXX */
Parse Version objrexx .
If objrexx = 'OBJREXX' Then orexx = 1
Else orexx = 0

/* load REXXUTIL functions */
Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

Parse Upper Source . . our_name .
Parse Value Getpaths(our_name) With our_drive our_base our_path
appl_file = Left(our_name, Lastpos('.', our_name) - 1) || '.ini'
ini_info = SysIni(appl_file, 'ALL:', 'appl.')
appl_ini.0 = 0
Do i = 1 To appl.0
   appl_ini.i = appl.i
   appl_class = Strip(SysIni(appl_file, appl.i, 'applclass'), 'T', '00'x)
   If appl_class <> 'ERROR:' Then Do
      rc = SysFileTree(our_base || '\' || appl_class, 'applclass.', 'FSO')
      If rc = 0 & applclass.0 > 0 Then Do
         j = appl_ini.0
         j = j + 1
         appl_ini.0 = j
         appl_ini.j = appl.i
         appl_class.j = applclass.1
         appl.j = Strip(SysIni(appl_file, appl_ini.j, 'objtitle'), 'T', '00'x)
         appl.j = Translate(appl.j, ' ', '^')
      End
   End
End
If appl_ini.0 > 0 Then Do
   Say 'Select the application to be installed from the following list'
   Do i = 1 To appl_ini.0
      Say i || '. ' appl.i
   End
End
Else Do
   Say 'No applications were found to install'
   Call Exit
End
Do Until 0 < answer <= appl_ini.0
   Parse Upper Pull answer
End

appl = appl.answer
appl_ini = appl_ini.answer
appl_class = appl_class.answer
Say 'Do you wish to install' appl '(y,N)?'
Parse Upper Pull answer
If \Abbrev(answer, 'Y') Then call Exit

classes.0 = 0
ini_info = Strip(SysIni(appl_file, appl_ini, 'classes'), 'T', '00'x)
Do i = 1 To Words(ini_info) By 2
   j = classes.0
   j = j + 1
   classes.0 = j
   classes.j = Subword(ini_info, i, 2)
   rc = SysFileTree(our_base || '\' || Word(classes.j, 2), 'class.', 'FSO')
   If Word(classes.j, 1) = 1 Then Do
      If rc <> 0 | class.0 = 0 Then Do
         class.1 = SysSearchPath('PATH', Word(classes.j, 2))
         If class.1 <> '' Then classes.j = 1 class.1
         Else Do 
            Say 'Required class' Word(classes.j, 2) 'not found'
            Call Exit
         End
      End
      Else classes.j = 1 class.1
   End
   Else Do
      If rc = 0 & class.0 > 0 Then classes.j = 1 class.1
      Else Do
         class.1 = SysSearchPath('PATH', Word(classes.j, 2))
         If class.1 <> '' Then classes.j = 1 class.1
         Else classes.j = 0 Word(classes.j, 2)
      End
   End
End

If orexx Then Do
   file_sys = SysFileSystemType(our_drive)
   If file_sys = 'HPFS' | file_sys = 'FAT' Then Say 'Found' our_path 'on an' file_sys 'drive'
   Else Do
      Say appl 'needs to run from an HPFS or FAT drive'
      Say 'Found' our_path 'on a' file_sys 'drive'
      Call Exit
   End
   boot_drive = SysBootDrive()
End
Else Do
   Say 'Unable to check the file system for' appl
   Say 'If' our_path 'is on an HPFS drive,'
   Say 'enter "HPFS" or "FAT" to continue, or any other answer to quit'
   Parse Upper Pull file_sys .
   If \Abbrev(file_sys, 'HPFS') & \Abbrev(file_sys, 'FAT') Then Call Exit
   boot_drive = Filespec('D', SysSearchPath('PATH', 'PMSHELL.EXE'))
End
ini_info = Strip(SysIni(appl_file, appl_ini, 'hpfs'), 'T', '00'x)
If ini_info & file_sys <> 'HPFS' Then Do
   Say appl 'must run from an HPFS drive'
   Call Exit
End

new_queue = Rxqueue('Create')
old_queue = Rxqueue('Set', new_queue)
'@JAVA -fullversion 2>&1|RXQUEUE' new_queue
Parse Pull . 'JDK' java_lvl 'IBM build' java_build .
java_lvl = Space(java_lvl)
java_build = Strip(Space(java_build), , '"')
new_queue = Rxqueue('Set', old_queue)
new_queue = Rxqueue('Delete', new_queue)
If java_lvl < '1.1.4' Then Do 
   Say 'You must be at Java level 1.1.4 or above'
   Call Exit
End
Else Say 'OS/2 Java' java_lvl 'at level' java_build 'detected'

ini_info = Strip(SysIni(appl_file, appl_ini, 'objicon'), 'T', '00'x)
obj_icon = our_path || '\' || Word(ini_info, 1)
obj_icon_pos = Subword(ini_info, 2)
startpath = our_path

java_name = SysSearchPath('PATH', 'JAVA.EXE')
Parse Value Getpaths(java_name) with java_drive java_base java_path
java_class = 'classes.zip'
rc = SysFileTree(java_base || '\' || java_class, 'class.', 'FSO')
If rc = 0 & class.0 > 0 Then Do
   java_class = class.1
   Say 'Using JAVA class -' java_class
End
Else Do
   Say java_class 'not found under' java_base
   Call Exit
End

config = boot_drive || '\CONFIG.SYS'
rc = SysFileSearch('SET CLASSPATH=', config, 'cp.')
If rc = 0 & cp.0 > 0 Then Do i = 1 To cp.0
   testcp = Translate(cp.i)
   If Abbrev(testcp, 'REM') Then Iterate
   Else config_classpath = cp.i
End
Else Do
   Say 'Unable to locate SET CLASSPATH= in' config
   Call Exit
End

ini_info = Strip(SysIni(appl_file, appl_ini, 'hotjava'), 'T', '00'x)
If Word(ini_info, 1) Then Do
   Say 'Do you want to use the Hot Java Browser (y,N)?'
   Parse Upper Pull answer .
   If Abbrev(answer, 'Y') Then Do
      hot_java = 1
      If file_sys = 'HPFS' Then hot_java_jar = our_path || '\' || Word(ini_info, 2)
      Else Do
         'RENAME' Word(ini_info, 2) Word(ini_info, 3) 
         hot_java_jar = our_path || '\' || Word(ini_info, 3)
      End
   End
   Else hot_java = 0
End
Else hot_java = 0

classpath = ''
If Pos(appl_class, config_classpath) = 0 Then Do
   classpath = appl_class || '^;'
   Say 'Setting class -' appl_class
End
Else Say 'Found' appl_class 'in' config 'CLASSPATH'
Do i = 1 To classes.0
   If Word(classes.i, 1) Then Do
      Say 'Using' appl 'class -' Word(classes.i, 2)
      If Pos(Word(classes.i, 2), config_classpath) = 0 Then Do
         Say 'Setting class -' Word(classes.i, 2)
         classpath = classpath || Word(classes.i, 2) || '^;'
      End
      Else Say 'Found' Word(classes.i, 2) 'in' config 'CLASSPATH'
   End
End
If hot_java Then Do
   If Pos(hot_java_jar, config_classpath) = 0 Then Do
      Say 'Setting class -' hot_java_jar
      classpath = classpath || hot_java_jar || '^;'
   End
   Else Say 'Found' hot_java_jar 'in' config 'CLASSPATH'
End
If Pos(java_class, config_classpath) = 0 Then Do
   Say 'Setting class -' java_class
   classpath = classpath || java_class || '^;'
End
Else Say 'Found' java_class 'in' config 'CLASSPATH'
If classpath <> '' Then classpath = '-classpath' classpath

parameters = ''
appl_name = Strip(SysIni(appl_file, appl_ini, 'applname'), 'T', '00'x)
obj_parm = Strip(SysIni(appl_file, appl_ini, 'objparm'), 'T', '00'x)
If Word(obj_parm, 1) Then Do
   obj_parm = Subword(obj_parm, 2)
   our_home_pos = Pos('&ourhome', obj_parm)
   If our_home_pos > 0 Then Do
      Parse Var obj_parm part_1 '&ourhome' part_2
      obj_parm = part_1 || our_base || part_2
   End
   java_home_pos = Pos('&javahome', obj_parm)
   If java_home_pos > 0 Then Do
      Parse Var obj_parm part_1 '&javahome' part_2
      obj_parm = part_1 || java_base || part_2
   End
   appl_name = obj_parm appl_name
End
If classpath <> '' Then parameters = classpath appl_name
Else parameters = appl_name
ini_info = Strip(SysIni(appl_file, appl_ini, 'jit'), 'T', '00'x)
If ini_info Then Do
   Say 'Do you want to disable the JIT compiler (y,N)?'
   Parse Upper Pull answer .
   If Abbrev(answer, 'Y') Then Do 
      If java_lvl >= '1.1.6' Then parameters = '-nojit' parameters
      Else parameters = '-Djava.compiler=xxx' parameters
   End
End

obj_class = Strip(SysIni(appl_file, appl_ini, 'objclass'), 'T', '00'x)
obj_title = Strip(SysIni(appl_file, appl_ini, 'objtitle'), 'T', '00'x)
obj_loc = Strip(SysIni(appl_file, appl_ini, 'objloc'), 'T', '00'x)
obj_id = Strip(SysIni(appl_file, appl_ini, 'objid'), 'T', '00'x)
obj_id = 'OBJECTID=<' || obj_id || '>;'
exec = 'EXENAME=' || java_name || ';'
parm = 'PARAMETERS=' || parameters || ';'
startdir = 'STARTUPDIR=' || startpath || ';'
window = 'PROGTYPE=WINDOWABLEVIO;CCVIEW=NO;'

Say 'Do you want to run with the Java console window minimized (Y,n)?'
Parse Upper Pull answer .
If Abbrev(answer, 'N') Then window = window || 'MINIMIZED=NO;'
Else window = window || 'MINIMIZED=YES;'

Say 'Do you want to close the Java window when' appl 'ends (Y,n)?'
Parse Upper Pull answer .
If Abbrev(answer, 'N') Then window = window || 'NOAUTOCLOSE=YES;'
icon = 'ICONFILE=' || obj_icon || ';ICONPOS=' || obj_icon_pos || ';'
setup = obj_id || exec || parm || startdir || window || icon

If SysCreateObject(obj_class, obj_title, obj_loc, setup, 'U') Then
   Say appl 'program object created or updated'
Else Say 'Failed to create or update' appl 'program object'
Call Exit

Exit:
   Procedure
   Call SysDropFuncs
   Exit
Return

Getpaths:  /* Get drive, base, and path */
   Procedure
   Parse Arg path
   drive = Filespec('D', path)
   path = Filespec('P', path) 
   path = Strip(Filespec('P', drive || path), 'T', '\')
   base = path
   Do While Lastpos('\', base) > 1
      base = Strip(Filespec('P', base), 'T', '\')
   End
   base = drive || base
   path = drive || path
   Return drive base path