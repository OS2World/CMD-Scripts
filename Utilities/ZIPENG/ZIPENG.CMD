/* The Zip Engine -- A shareware graphical approach to file zipping/unzipping */
/* Copyright 1992-93 Kari Jackson and Bart Toulouse */
'@ECHO OFF'
signal on halt ; signal on syntax ; signal on error
if rxfuncquery('vinit') then call rxfuncadd 'VInit', 'VREXX', 'VINIT'
if VInit() = 'ERROR' then signal Error
if rxfuncquery('sysloadfuncs') then call rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call sysloadfuncs

ReStart:
drop ZIP UNZIP TEMPOLD DIROLD EXT ENDING DEFDIR MENUDEF SELPGM. VER ZOP UOP AOP TEXT SWITCH BG FG
call vdialogpos 50,50
rc = stream('ZIPENG.TEX', 'c', 'query exists')
if rc<>'' then TEXT = rc
else do
   rc = syssearchpath('PATH','ZIPENG.TEX')
   if rc<>'' then TEXT = rc
end
if TEXT = 'TEXT' then do
   MSG.0 = 2
   MSG.1 = 'ZIPENG.TEX message file not found.  Zip Engine cannot run  '
   MSG.2 = 'unless this file is in the current directory or on the PATH.  '
   call vmsgbox "Sorry!", MSG, 1
   signal CleanUp
end
rc = stream('ZIPENG.INI', 'c', 'query exists')
if rc<>'' then do
   CFGFILE = rc
   call ConfigFile
end
else do
   rc = syssearchpath('PATH','ZIPENG.INI')
   if rc<>'' then do
      CFGFILE = rc
      call ConfigFile
   end
end
if (ZIP = 'ZIP')|(ZIP = '') then ZIP = syssearchpath('PATH','PKZip.EXE')
if (UNZIP = 'UNZIP')|(UNZIP = '') then UNZIP = syssearchpath('PATH','PKUnzip.EXE')
if (ZIP = '')|(UNZIP = '') then do
   call ZipEdit.CMD TEXT
   signal ReStart
end
if BG = 'BG' | BG = '' then BG = 'BLUE'
if FG = 'FG' | FG = '' then FG = 'WHITE'
if SWITCH = 'SWITCH' | SWITCH = '' then SWITCH = 'c'
if TEMPOLD = 'TEMPOLD' then TEMPOLD = ''
if DIROLD = 'DIROLD' then DIROLD = ''
if EXT<>'CMD' then EXT = 'BAT'
if ENDING<>'EXIT' then ENDING = 'Main' ; else ENDING = 'CleanUp'
if DEFDIR = 'DEFDIR' then DEFDIR = '' ; else DEFDIR = DEFDIR'\'
if (MENUDEF = 'MENUDEF')|(MENUDEF = '') then MENUDEF = SELPGM.1
if (VER = 'VER')|(VER = '') then VER = 1
if ZOP = 'ZOP' then ZOP = '' ; if UOP = 'UOP' then UOP = '' ; if AOP = 'AOP' then AOP = ''
arg SOURCE
Main:
drop WINORG ABOUT BUTTON OPER DISKFILES MSG. ACTION LINE LEN DIRNAME2 VAR. NUMBER TEST. SELPGM. CHECK. NEWZIP
if (AGAIN = 'YES')|(SOURCE = 'SOURCE') then SOURCE = ''
EXECUTABLE = '' ; OPTIONS = '' ; DIRNAME = '' ; FILENAMES = ''
SELPGM.0 = 10
SELPGM.1 = 'Unzip a file'
SELPGM.2 = 'Create a new .ZIP file'
SELPGM.3 = 'Modify an existing .ZIP file'
SELPGM.4 = 'View text files within a .ZIP'
SELPGM.5 = 'View names of files inside a .ZIP'
SELPGM.6 = 'Delete files within a .ZIP'
SELPGM.7 = 'Test integrity of files inside a .ZIP'
SELPGM.8 = 'Add a file as a comment to an existing .ZIP      '
SELPGM.9 = 'Edit the ZIPENG configuration file'
SELPGM.10 = 'About The Zip Engine'
SELPGM.VSTRING = value(MENUDEF)
BUTTON = vradiobox('Main Menu (CANCEL to exit Zip Engine)', SELPGM, 3)
if BUTTON = 'CANCEL' then signal CleanUp
drop BUTTON
select
   when SELPGM.VSTRING = SELPGM.1 then do
      drop SELPGM.
      EXECUTABLE = UNZIP
      call WinBox
      call UnZOpt
      AGAIN = 'YES'
      if (SOURCE = '')&(READY<>'YES') then call Source
      drop READY
      call WinBox
      if DONT<>'NO' then do
         DIRNAME = Target(DIROLD)
         if DIRNAME = 'quit' then signal Main
         if DIROLD = '' then DIROLD = DIRNAME
         call WinBox
      end
      drop DONT
      call Finally
      if WINDOW=WINORG then call vclosewindow WINDOW
      'start /win /b /'SWITCH COMMANDDONE
      if ENDING = 'Main' then signal Main
      if ENDING = 'CleanUp' then signal CleanUp
   end
   when SELPGM.VSTRING = SELPGM.2 then do
      drop SELPGM.
      EXECUTABLE = ZIP ; AGAIN = 'YES' ; NEWZIP = 'yes'
      call WinBox
      if SOURCE = '' then do until SOURCE<>'NoNe'
         SOURCE = Source2()
         if SOURCE = 'quit' then signal Main
      end
      call WinBox
      call Target2
      drop BUTTON MSG.
      call WinBox
      call ZOpt
      call Finally
      if WINDOW=WINORG then call vclosewindow WINDOW
      'start /win /b /'SWITCH COMMANDDONE
      if ENDING = 'Main' then signal Main
      if ENDING = 'CleanUp' then signal CleanUp
   end
   when SELPGM.VSTRING = SELPGM.3 then do
      drop SELPGM.
      EXECUTABLE = ZIP ; AGAIN = 'YES'
      call WinBox
      if SOURCE = '' then do
         call Source
         call WinBox
      end
      call Target2
      drop BUTTON MSG.
      call WinBox
      call ZOpt
      call Finally
      if WINDOW=WINORG then call vclosewindow WINDOW
      'start /win /b /'SWITCH COMMANDDONE
      if ENDING = 'Main' then signal Main
      if ENDING = 'CleanUp' then signal CleanUp
   end
   when SELPGM.VSTRING = SELPGM.4 then do
      drop SELPGM.
      EXECUTABLE = UNZIP ; OPTIONS = strip(AOP)
      call Password
      if PS<>'PS' then OPTIONS = strip(OPTIONS PS)
      drop PS
      AGAIN = 'YES' ; WIN = 'NO'
      if SOURCE = '' then call Source
      if TEMPOLD<>'' then TEMPOLD = Validate(TEMPOLD)
      drop DIR. WIN
      if (TEMPOLD = '')|(TEMPOLD = 'NO WAY') then do
         DIR.0 = 3
         call linein TEXT,1
         do 134
            call linein TEXT
         end
         do y = 1 to 3
            DIR.y = linein(TEXT)
         end
      end
      do while (TEMPOLD = '')|(TEMPOLD = 'NO WAY')
         call vinputbox 'Temporary directory:', DIR, 66, 1
         TEMPOLD = Validate(DIR.VSTRING)
      end
      drop DIR.
      DIRNAME = TEMPOLD
      call ZipView.CMD TEXT'/'EXECUTABLE'/'OPTIONS'/'SOURCE'/'DIRNAME'/'EXT'/'BG'/'FG
      if RESULT = 'error' then call CreateError
      signal Main
   end
   when SELPGM.VSTRING = SELPGM.5 then do
      drop SELPGM.
      EXECUTABLE = ZIP ; OPTIONS = strip(AOP '-v')
      call Order
      AGAIN = 'YES'
      if SOURCE = '' then call Source
      call ViewOnly
      call vclosewindow WINDOW
      signal Main
   end
   when SELPGM.VSTRING = SELPGM.6 then do
      drop SELPGM.
      EXECUTABLE = ZIP ; OPTIONS = strip(AOP '-d')
      call Temp
      drop TEMPLEN
      if TEMPOLD<>'' then OPTIONS = OPTIONS '-b'TEMPOLD
      AGAIN = 'YES'
      if SOURCE = '' then call Source
      drop FILES.
      if EXT = 'BAT' then FILES.0 = 10
      if EXT = 'CMD' then FILES.0 = 7
      call linein TEXT,1
      call linein TEXT
      do y = 1 to FILES.0
         FILES.y = linein(TEXT)
      end
      BUTDEL = vinputbox("Files to Delete from the .ZIP File:", FILES, 40, 3)
      drop DISKFILES
      select
         when BUTDEL = 'CANCEL' then do
            OPER = 'delete'
            call View
            if DISKFILES = 'DISKFILES' then do
               drop FILES. BUTDEL
               signal Main
            end
            FILENAMES = DISKFILES
            drop DISKFILES VAR. MSG. NUMBER
         end
         when (FILES.VSTRING = '')|(FILES.VSTRING = 'FILES.VSTRING') then do
            if WINORG = WINDOW then call vclosewindow WINDOW
            drop FILES. BUTDEL
            signal Main
         end
         otherwise FILENAMES = FILES.VSTRING
      end
      drop BUTTON FILES. BUTDEL
      LINE = strip(EXECUTABLE OPTIONS SOURCE FILENAMES) ; LEN = length(LINE)
      call Finally
      if WINDOW=WINORG then call vclosewindow WINDOW
      'start /win /b /'SWITCH COMMANDDONE
      if ENDING = 'Main' then signal Main
      if ENDING = 'CleanUp' then signal CleanUp
   end
   when SELPGM.VSTRING = SELPGM.7 then do
      drop SELPGM.
      EXECUTABLE = UNZIP ; OPTIONS = strip(AOP '-t')
      call Password
      if PS<>'PS' then OPTIONS = OPTIONS PS
      drop PS
      AGAIN = 'YES'
      if SOURCE = '' then call Source
      call ViewOnly
      call vclosewindow WINDOW
      signal Main
   end
   when SELPGM.VSTRING = SELPGM.8 then do
      drop SELPGM.
      BUTTON = VFileBox('Select the comment file you want to add:', '*.*', COMMENT)
      if BUTTON = 'CANCEL' then signal Main
      AGAIN = 'YES'
      if SOURCE = '' then call Source
      LINE = ZIP strip(AOP '-z -x*.*') SOURCE '<' COMMENT.VSTRING ; LEN = length(LINE)
      drop BUTTON COMMENT.
      call Finally
      if TEMPXFILE<>'TEMPXFILE' then do until rc = 0
         rc = sysfiledelete(TEMPXFILE)
         if rc<>0 then call syssleep 1
      end
      if right(TEMPOLD,1)='\' then TEMPXFILE = systempfilename(TEMPOLD'1?????.'EXT)
      else TEMPXFILE = systempfilename(TEMPOLD'\1?????.'EXT)
      call lineout TEMPXFILE,'@ECHO OFF'
      if RESULT = 1 then call CreateError
      call lineout TEMPXFILE,COMMANDDONE
      call lineout TEMPXFILE,'ATTRIB -R' TEMPXFILE
      call lineout TEMPXFILE,"REM If Zip Engine isn't running at this moment, delete this file."
      call lineout TEMPXFILE
      'ATTRIB +R' TEMPXFILE
      'start /win /b /'SWITCH TEMPXFILE
      if ENDING = 'Main' then signal Main
      if ENDING = 'CleanUp' then signal CleanUp
   end
   when SELPGM.VSTRING = SELPGM.9 then do
      drop SELPGM.
      call ZipEdit.CMD TEXT
      signal ReStart
   end
   when SELPGM.VSTRING = SELPGM.10 then do
      drop SELPGM.
      call ZipView.CMD 'About' TEXT'/'BG'/'FG
      signal Main
   end
   otherwise nop
end
Error:
Failure:
Halt:
Syntax:
   MSG.0 = 4
   MSG.1 = "I'm terribly sorry to report that there's been an"
   MSG.2 = "error.  This Program is going to abort now.  Please"
   MSG.3 = "write to the author and let me know what happened,"
   MSG.4 = "and that the problem occurred in line number" SIGL"."
   call vmsgbox "Uh-oh!", MSG, 1
CleanUp:
   if TEMPXFILE<>'TEMPXFILE' then do until rc = 0
      rc = sysfiledelete(TEMPXFILE)
      if rc<>0 then call syssleep 1
   end
   call vexit
   say 'Thank you for using The Zip Engine.'
exit
ConfigFile:
   rc = sysini(CFGFILE, 'zipeng', 'zipper')
   if rc<>'ERROR:' then ZIP = rc
   rc = sysini(CFGFILE, 'zipeng', 'unzipper')
   if rc<>'ERROR:' then UNZIP = rc
   rc = sysini(CFGFILE, 'zipeng', 'temporary directory')
   if rc<>'ERROR:' then TEMPOLD = rc
   rc = sysini(CFGFILE, 'zipeng', 'extract directory')
   if rc<>'ERROR:' then DIROLD = rc
   rc = sysini(CFGFILE, 'zipeng', 'extension')
   if rc<>'ERROR:' then EXT = rc
   rc = sysini(CFGFILE, 'zipeng', 'exit action')
   if rc<>'ERROR:' then ENDING = rc
   rc = sysini(CFGFILE, 'zipeng', 'default directory')
   if rc<>'ERROR:' then DEFDIR = rc
   rc = sysini(CFGFILE, 'zipeng', 'menu default')
   if rc<>'ERROR:' then MENUDEF = rc
   rc = sysini(CFGFILE, 'zipeng', 'version')
   if rc<>'ERROR:' then VER = rc
   rc = sysini(CFGFILE, 'zipeng', 'zip options')
   if rc<>'ERROR:' then ZOP = rc
   rc = sysini(CFGFILE, 'zipeng', 'unzip options')
   if rc<>'ERROR:' then UOP = rc
   rc = sysini(CFGFILE, 'zipeng', 'global options')
   if rc<>'ERROR:' then AOP = rc
   rc = sysini(CFGFILE, 'zipeng', 'start switch')
   if rc<>'ERROR:' then SWITCH = rc
   rc = sysini(CFGFILE, 'zipeng', 'background')
   if rc<>'ERROR:' then BG = rc
   rc = sysini(CFGFILE, 'zipeng', 'foreground')
   if rc<>'ERROR:' then FG = rc
   drop CFGFILE rc
return
WinBox:
   if WINORG<>WINDOW then do
      POS.left = 2 ; POS.right = 98 ; POS.top = 25 ; POS.bottom = 10
      WINDOW = vopenwindow('(Zip Engine) Watch the Command Line Being Built:', BG, POS)
      call vsetfont WINDOW, 'SYSTEM', 10
      call vforecolor WINDOW, FG
      drop POS.
      WINORG = WINDOW
   end
   LINE = strip(EXECUTABLE OPTIONS SOURCE DIRNAME FILENAMES) ; LEN = length(LINE)
   call vclearwindow WINDOW
   select
      when LEN<73 then do
         call vsay WINDOW, 5, 600, LINE
         call vsay WINDOW, 950, 200, LEN
      end
      when LEN<145 then do
         call vsay WINDOW, 5, 600, left(LINE,72)
         call vsay WINDOW, 5, 400, substr(LINE,73)
         call vsay WINDOW, 950, 200, LEN
      end
      otherwise do
         call vsay WINDOW, 5, 600, left(LINE,72)
         call vsay WINDOW, 5, 400, substr(LINE,73,72)
         call vsay WINDOW, 5, 200, substr(LINE,145)
         if LEN<216 then call vsay WINDOW, 950, 200, LEN
      end
   end
return
Validate:
   procedure expose ROUTINE
   arg VALID
   if (VALID = '')|(VALID = '\') then return VALID
   if (VALID = '.')|(VALID = '.\') then return directory()
   if (VALID = '..')|(VALID = '..\') then do
      SLASH = lastpos('\',directory())
      VALID = left(directory(),SLASH-1)
      if substr(VALID,2) = ':' then VALID = VALID'\'
      return VALID
   end
   VALIDLEN = length(VALID)
   if (substr(VALID,2) = ':')&(datatype(left(VALID,1),'M') = 1) then return VALID
   if (substr(VALID,2) = ':\')&(datatype(left(VALID,1),'M') = 1) then return VALID
   if right(VALID,1) = '\' then VALID = left(VALID,VALIDLEN-1)
   call sysfiletree VALID, 'TEST'
   if TEST.0 = 1 then return VALID
   if (ROUTINE<>'Target')&(WIN<>'NO') then do
      MSG.0 = 3
      MSG.1 = 'Please specify a directory name that exists.'
      MSG.2 = VALID
      MSG.3 = 'does not exist.'
      call vmsgbox 'Sorry!', MSG, 1
   end
return 'NO WAY'
Source:
   drop FNAME.
   BUTTON = vfilebox('Select a .ZIP File to Act Upon:', DEFDIR'*.zip', FNAME)
   if BUTTON = 'CANCEL' then do
      if WINORG = WINDOW then call vclosewindow WINDOW
      drop FNAME.
      signal Main
   end
   SOURCE = FNAME.VSTRING
   drop BUTTON FNAME.
return
Source2:
   procedure expose WINDOW DEFDIR TEXT
   DIR.0 = 9
   call linein TEXT,1
   do 12
      call linein TEXT
   end
   do y = 1 to 9
      DIR.y = linein(TEXT)
   end
   DIR.VSTRING = DEFDIR
   BUTTON = vinputbox('.ZIP File to Create:', DIR, 50, 3)
   if BUTTON = 'CANCEL' then do
      call vclosewindow WINDOW
      drop DIR.
      return 'quit'
   end
   SOURCE = DIR.VSTRING
   if (SOURCE = '')|(SOURCE = 'DIR.VSTRING') then return 'NoNe'
   SLASH = lastpos('\',SOURCE)
   if SLASH>1 then do
      DIRN = left(SOURCE,SLASH-1)
      FILEN = substr(SOURCE,SLASH+1)
      if FILEN = '' then return 'NoNe'
      DIRN = Validate(DIRN)
      if DIRN = 'NO WAY' then return 'NoNe'
      if right(DIRN,1) = '\' then SOURCE = DIRN''FILEN
      else SOURCE = DIRN'\'FILEN
   end
   if (SLASH = 0)&(substr(SOURCE,2,1)<>':') then SOURCE = directory()'\'SOURCE
   else if SLASH = 0 then do
      if right(SOURCE,1) = ':' then return 'NoNe'
      CURDIR = directory()
      call directory left(SOURCE,2)
      THAT = directory()
      call directory(CURDIR)
      if right(THAT,1)<>'\' then SOURCE = THAT'\'substr(SOURCE,3)
      else SOURCE = THAT''substr(SOURCE,3)
      drop THAT
   end
return SOURCE
Target:
   procedure expose SOURCE WINDOW TEXT
   arg DIROLD
   DIR.0 = 10
   call linein TEXT,1
   do 22
      call linein TEXT
   end
   do y = 1 to 10
      DIR.y = linein(TEXT)
   end
   DIR.VSTRING = DIROLD
   BUTTON = vinputbox('Target Directory Name:', DIR, 66, 3)
   if BUTTON = 'CANCEL' then do
      call vclosewindow WINDOW
      return 'quit'
   end
   if DIR.VSTRING = '' then do
      call Target DIROLD
      return RESULT
   end
   if (right(DIR.VSTRING,2) = '\$')|(DIR.VSTRING = '$')|(right(DIR.VSTRING,2) = ':$') then do
      ABC = lastpos('\',SOURCE)
      DEF = lastpos('.',SOURCE)
      if DEF>0 then NEWDIR = substr(SOURCE,ABC+1, DEF-ABC-1)
      else NEWDIR = substr(SOURCE,ABC+1)
      if length(DIR.VSTRING)>1 then DIR.VSTRING = left(DIR.VSTRING,length(DIR.VSTRING)-1)''NEWDIR
      else DIR.VSTRING = NEWDIR
   end
   ROUTINE = 'Target'
   DIRNAME = Validate(DIR.VSTRING)
   drop ROUTINE
   if DIRNAME = 'NO WAY' then do
      DIRNAME = DIR.VSTRING
      SLASH = lastpos('\',DIRNAME)
      select
         when (SLASH = 0)&(substr(DIRNAME,2,1) = ':') then do
            CURDIR = directory()
            call directory left(DIRNAME,2)
            PARENT = directory()
            call directory(CURDIR)
            NEWDIR = substr(DIRNAME,3)
         end
         when SLASH = 0 then do
            PARENT = directory()
            NEWDIR = DIRNAME
         end
         when SLASH = 1 then do
            PARENT = '\'
            NEWDIR = substr(DIRNAME,2)
         end
         when (SLASH = 3)&(substr(DIRNAME,2,1) = ':') then do
            PARENT = left(DIRNAME,3)
            NEWDIR = substr(DIRNAME,4)
         end
         otherwise do
            PARENT = left(DIRNAME,SLASH-1)
            NEWDIR = substr(DIRNAME,SLASH+1)
            ROUTINE = 'Target'
            THIS = Validate(PARENT)
            drop ROUTINE
            if THIS = 'NO WAY' then do
               MSG.0 = 2
               MSG.1 = DIRNAME "does not exist, nor can we create"
               MSG.2 = "it since" PARENT "doesn't exist either."
               call vmsgbox 'Sorry!', MSG, 1
               call Target DIROLD
               return RESULT
            end
            PARENT = THIS
         end
      end
      MSG.0 = 3
      if PARENT='\' then MSG.1 = '\'NEWDIR "does not exist, but" PARENT "does.         "
      else MSG.1 = PARENT'\'NEWDIR "does not exist, but" PARENT "does.         "
      MSG.2 = "Do you want to create" NEWDIR "under the" PARENT
      MSG.3 = "directory?  If not, choose NO to return to the input box."
      BUT = vmsgbox("Create Directory?", MSG, 6)
      if BUT = 'NO' then do
         call Target DIROLD
         return RESULT
      end
      else do
         if (right(PARENT,1) = '\')|(right(PARENT,1) = ':') then DIRNAME = PARENT''NEWDIR
         else DIRNAME = PARENT'\'NEWDIR
         rc = sysmkdir(DIRNAME)
         if rc<>0 then do
            MSG.0 = 2
            MSG.1 = "Sorry, we were not able to create" DIRNAME
            MSG.2 = "Let's go back to the input box."
            call vmsgbox "Oops!", MSG, 1
            call Target DIROLD
            return RESULT
         end
      end
   end
return DIRNAME
Target2:
   drop MSG.
   if NEWZIP<>'yes' then MSG.0 = 9
   else MSG.0 = 3
   call linein TEXT,1
   do 33
      call linein TEXT
   end
   do y = 1 to MSG.0
      if y = 4 then MSG.4 = ''
      else MSG.y = linein(TEXT)
   end
   BUTTON = vinputbox("Directory of Files to Zip:", MSG, 40, 3)
   if (NEWZIP<>'yes')&(BUTTON = 'CANCEL') then do
      DIRNAME = '-x*.*'
      return
   end
   if (BUTTON = 'CANCEL')&(NEWZIP = 'yes') then do
      call vclosewindow WINDOW
      signal Main
   end
   drop BUTTON
   if (MSG.VSTRING = '')|(MSG.VSTRING = 'MSG.VSTRING') then do
      call Target2
      return
   end
   DIRNAME = Validate(MSG.VSTRING)
   drop MSG.
   if DIRNAME = 'NO WAY' then do
      call Target2
      return
   end
   if (right(DIRNAME,1)<>'\')&(right(DIRNAME,1)<>':') then DIRNAME = DIRNAME'\'
   DIRNAME2 = DIRNAME
   if EXT = 'BAT' then MSG.0 = 10
   if EXT = 'CMD' then MSG.0 = 7
   call linein TEXT,1
   do 42
      call linein TEXT
   end
   do y = 1 to MSG.0
      MSG.y = linein(TEXT)
   end
   MSG.VSTRING = '*.*'
   BUTTON = vinputbox('Files to Zip:', MSG, 55, 3)
   if BUTTON = 'CANCEL' then do
      ACTION = 'zip'
      drop DISKFILES BUTTON MSG.
      call DiskFiles
      if (DISKFILES<>'DISKFILES')&(DISKFILES<>'') then DIRNAME = DISKFILES
      else do
         call Target2
         return
      end
      drop DISKFILES VAR. MSG. NUMBER
   end
   else do
      if MSG.VSTRING = '' then do
         call Target2
         return
      end
      do t = 1 while MSG.VSTRING<>''
         select
            when left(MSG.VSTRING,1) = '"' then do
               parse var MSG.VSTRING . '"' NAME.t '"' MSG.VSTRING
               NAME.t = '"'||NAME.t||'"'
            end
            when left(MSG.VSTRING,1) = "'" then do
               parse var MSG.VSTRING . "'" NAME.t "'" MSG.VSTRING
               NAME.t = "'"||NAME.t||"'"
            end
            otherwise parse var MSG.VSTRING NAME.t MSG.VSTRING
         end
         MSG.VSTRING = strip(MSG.VSTRING)
         NAME.0 = t
      end
      if symbol('NAME.0') = 'VAR' then do t = 1 to NAME.0
         MSG.VSTRING = strip(MSG.VSTRING DIRNAME||NAME.t)
      end
      DIRNAME = MSG.VSTRING
      drop NAME. BUTTON MSG.
   end
return
Order:
   ORDER.0 = 6
   ORDER.1 = 'd = date'
   ORDER.2 = 'e = extension'
   ORDER.3 = 'n = name'
   ORDER.4 = 'o = original'
   ORDER.5 = 'p = percentage'
   ORDER.6 = 's = size'
   ORDER.VSTRING = ORDER.4
   call vradiobox 'Show files in order of:', ORDER, 1
   OPTIONS = OPTIONS||left(ORDER.VSTRING,1)
   drop ORDER.
   EXTRA.0 = 4
   EXTRA.1 = 'b = brief'
   EXTRA.2 = 'c = comments'
   EXTRA.3 = 'r = reverse'
   EXTRA.4 = 't = technical'
   call vcheckbox 'Optional:', EXTRA, OP2, 1
   do r = 1 to OP2.0
      OPTIONS = OPTIONS||left(OP2.r,1)
   end
   drop EXTRA. OP2.
return
Password:
   call vdialogpos 25,35
   PASS.0 = 1
   PASS.1 = 'Asterisks will echo for security reasons:'
   PASSWORD.0 = 1
   PASSWORD.1 = ''
   PASSBUT = vmultbox("Enter the file's password, if it's encrypted:", PASS, 25, 1, PASSWORD, 3)
   if (VER = 2)&(PASSBUT = 'OK') then PS = '-s'PASSWORD.1
   if (VER = 1)&(PASSWORD.1<>'') then PS = '-s'PASSWORD.1
   drop PASS. PASSWORD. PASSBUT
   call vdialogpos 50,50
return
Finally:
   if (EXT = 'BAT')&(LEN>100) then do
      MSG.0 = 10
      call linein TEXT,1
      do 53
         call linein TEXT
      end
      do y = 1 to 10
         MSG.y = linein(TEXT)
      end
      call vmsgbox "Careful!", MSG, 1
      drop MSG.
   end
   call linein TEXT,1
   do 64
      call linein TEXT
   end
   POS.left = 3 ; POS.right = 97 ; POS.top = 95 ; POS.bottom = 60
   WINDOW2 = vopenwindow('(Zip Engine) Finished building command line....', BG, POS)
   call vsetfont WINDOW2, 'SYSTEM', 10
   call vforecolor WINDOW2, FG
   do q = 930 to 30 by -100
      call vsay WINDOW2, 15, q, linein(TEXT)
   end
   drop F1. F2.
   F1.0 = 7 ; F2.0 = 7
   F1. = ' ' ; F2. = ' '
   F1.0 = 1 ; F2.0 = 1
   F2.1 = left(LINE,60)
   if LEN>60 then do
      F2.2 = substr(LINE,61,60)
      F1.0 = 2 ; F2.0 = 2
   end
   if LEN>120 then do
      F2.3 = substr(LINE,121,60)
      F1.0 = 3 ; F2.0 = 3
   end
   if LEN>180 then do
      F2.4 = substr(LINE,181,60)
      F1.0 = 4 ; F2.0 = 4
   end
   if LEN>240 then do
      F2.5 = substr(LINE,241,60)
      F1.0 = 5 ; F2.0 = 5
   end
   if LEN>300 then do
      F2.6 = substr(LINE,301,60)
      F1.0 = 6 ; F2.0 = 6
   end
   if LEN>360 then do
      F2.7 = substr(LINE,361,60)
      F1.0 = 7 ; F2.0 = 7
   end
   call vdialogpos 50,40
   BUTTON = vmultbox('Edit your Command Line, if desired:', F1, 80, 0, F2, 3)
   call vdialogpos 50,50
   call vclosewindow WINDOW2
   if BUTTON = 'OK' then do
      COMMANDDONE = strip(F2.1''F2.2''F2.3''F2.4''F2.5''F2.6''F2.7)
      drop BUTTON F1. F2.
      return
   end
   MSG.0 = 3
   call linein TEXT
   do y = 1 to 3
      MSG.y = linein(TEXT)
   end
   BUTTON = vmsgbox('Cancel?', MSG, 3)
   if BUTTON = 'OK' then do
      COMMANDDONE = strip(F2.1''F2.2''F2.3''F2.4''F2.5''F2.6''F2.7)
      drop BUTTON MSG. F1. F2.
      return
   end
   drop BUTTON MSG. F1. F2.
   if WINORG = WINDOW then call vclosewindow WINDOW
   signal Main
return
ZOpt:
   OPTIONS = strip(AOP ZOP)
   if OPTIONS<>'' then call WinBox
   if VER = 2 then do
      ZIPOP.0 = 10
      ZIPOP.1 = '-& = span new .ZIP file across disks if necessary ....'
      ZIPOP.2 = '-a+= turn off Archive attributes of zipped files'
      ZIPOP.3 = '-b = put temp files somewhere other than current drive ....      '
      ZIPOP.4 = '-c = comments ....'
      ZIPOP.5 = '-m = move files into .ZIP (delete from source) ....'
      ZIPOP.6 = '-x = exclude certain files ....'
      ZIPOP.7 = '     pathnames and subdirectories ....'
      ZIPOP.8 = '     specify date stamp for .ZIP file ....'
      ZIPOP.9 = '     zip only files that have changed ....'
      ZIPOP.10 = '     further options ....'
   end
   if VER = 1 then do
      ZIPOP.0 = 8
      ZIPOP.1 = '-b = put temp files somewhere other than current drive ....      '
      ZIPOP.2 = '-c = comments ....'
      ZIPOP.3 = '-m = move files into .ZIP (delete from source) ....'
      ZIPOP.4 = '-x = exclude certain files ....'
      ZIPOP.5 = '     pathnames and subdirectories ....'
      ZIPOP.6 = '     specify date stamp for .ZIP file ....'
      ZIPOP.7 = '     zip only files that have changed ....'
      ZIPOP.8 = '     further options ....'
   end
   drop PAR.
   BUTTON = vcheckbox('Zip Special OPTIONAL Switches:', ZIPOP, PAR, 3)
   if BUTTON = 'CANCEL' then do
      call vclosewindow WINDOW
      signal Main
   end
   drop BUTTON
   do i = 1 to PAR.0
      if left(PAR.i,1) = '-' then PAR.i = left(PAR.i,2)
      else select
         when substr(PAR.i,6,1) = 'p' then PAR.i = 'paths'
         when substr(PAR.i,6,1) = 's' then PAR.i = 'date'
         when substr(PAR.i,6,1) = 'z' then PAR.i = 'only'
         when substr(PAR.i,6,1) = 'f' then PAR.i = 'further'
         otherwise nop
      end
   end
   drop ZIPOP.
   do i = 1 to PAR.0
      select
         when PAR.i = '-&' then do
            if NEWZIP<>'yes' then call CantUse
            else do
               SPAN2.0 = 9
               SPAN2.1 = "f  = quick format target disk first"
               SPAN2.2 = "fl = quick format double density in HD drive"
               SPAN2.3 = "u  = full format target disk first"
               SPAN2.4 = "ul = full format double density in HD drive"
               SPAN2.5 = "w  = wipe all files from target disk first"
               SPAN2.6 = "  Do NOT choose more than one of the above!       "
               SPAN2.7 = " "
               SPAN2.8 = "v  = verify that target disk is readable"
               SPAN2.9 = "s  = zip all files on entire drive"
               SPAN4.0 = 1
               SPAN4.1 = SPAN2.8
               BUTTON = vcheckbox('Additional OPTIONAL parameters:', SPAN2, SPAN4, 3)
               if BUTTON = 'OK' then do r = 1 to SPAN4.0
                  PAR.i = PAR.i||strip(left(SPAN4.r,2))
               end
               else PAR.i = ' '
               drop SPAN2. SPAN4. BUTTON
               if right(PAR.i,1) = 's' then do
                  SPAN3.0 = 3
                  SPAN3.1 = "Specify the drive letter of the drive you want   "
                  SPAN3.2 = "to zip.  You may leave this line blank if you   "
                  SPAN3.3 = "want to zip the" left(directory(),2) "drive."
                  SPAN3.VSTRING = ''
                  do until (datatype(left(SPAN3.VSTRING,1),'M'))|(SBUT = 'CANCEL')|(SPAN3.VSTRING = '')
                     SBUT = vinputbox("Drive to Zip:", SPAN3, 2, 3)
                  end
                  if SBUT = 'CANCEL' then PAR.i = left(PAR.i,length(PAR.i)-1)
                  else PAR.i = PAR.i''left(SPAN3.VSTRING,1)
                  PATHS = wordpos('paths',PAR.1 PAR.2 PAR.3 PAR.4 PAR.5 PAR.6 PAR.7 PAR.8)
                  if (SBUT = 'OK')&(PATHS>0) then do
                     PAR.PATHS = ' '
                     MSG.0 = 5
                     call linein TEXT,1
                     do 79
                        call linein TEXT
                     end
                     do y = 1 to 5
                        MSG.y = linein(TEXT)
                     end
                     call vmsgbox "Sorry!", MSG, 1
                  end
                  drop PATHS MSG.
               end
               drop BUTTON SPAN3. SBUT
               OPTIONS = strip(OPTIONS PAR.i)
               call WinBox
            end
         end
         when PAR.i = '-a' then do
            OPTIONS = strip(OPTIONS '-a+')
            call WinBox
         end
         when PAR.i = 'paths' then do
            PATHS.0 = 4
            PATHS.1 = '-r = recurse subdirectories but do not include pathnames'
            PATHS.2 = '-rp= recurse and include pathnames recursed into'
            PATHS.3 = '-rP= recurse and include pathnames specified and recursed into'
            PATHS.4 = '-P = include pathnames specified but do not recurse subdirectories       '
            PATHS.VSTRING = PATHS.2
            BUTTON = vradiobox('Select:', PATHS, 3)
            PAR.i = strip(left(PATHS.VSTRING,3))
            if BUTTON = 'CANCEL' then PAR.i = ''
            drop BUTTON PATHS.
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = '-b' then do
            if NEWZIP = 'yes' then call CantUse
            else do
               call Temp
               drop TEMPLEN
               if TEMPOLD<>'' then OPTIONS = strip(OPTIONS '-b'TEMPOLD)
               call WinBox
            end
         end
         when PAR.i = '-c' then do
            PAR.i = ''
            drop COMMENTS3. COMMENTS.
            COMMENTS3.0 = 5
            COMMENTS3.1 = '-c = Comments for all files in .ZIP'
            COMMENTS3.2 = '-C = Comments for newly-added files in .ZIP'
            COMMENTS3.3 = '  Do NOT choose more than one of the above!       '
            COMMENTS3.4 = ' '
            COMMENTS3.5 = '-z = Comment for the .ZIP file itself'
            BUTTON = vcheckbox('Comments:', COMMENTS3, COMMENTS, 3)
            if BUTTON = 'OK' then do y = 1 to COMMENTS.0
               PAR.i = strip(PAR.i left(COMMENTS.y,2))
            end
            drop BUTTON COMMENTS. COMMENTS3.
            if (DIRNAME<>'')&(PAR.i<>'') then do
               drop OK
               do x = 1 to 10
                  if wordpos('-a+',PAR.x)>0 then OK = 'YES'
                  if wordpos('-m',PAR.x)>0 then OK = 'YES'
                  if wordpos('only',PAR.x)>0 then OK = 'YES'
               end
               if OK<>'YES' then PAR.i = PAR.i '-a'
               drop OK
            end
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = '-m' then do
            MOVE.0 = 3
            MOVE.1 = '  = Move all files'
            MOVE.2 = 'f = Move only later copies of existing files   '
            MOVE.3 = 'u = Move only later copies and new files'
            MOVE.VSTRING = MOVE.1
            if VER = 2 then do
               MOVE.0 = 6
               MOVE.4 = "- = Move all but don't remove directories"
               MOVE.5 = "-f= Freshen but don't remove directories"
               MOVE.6 = "-u= Update but don't remove directories"
               MOVE.VSTRING = MOVE.4
            end
            BUTTON = vradiobox('Move which files?', MOVE, 3)
            select
               when BUTTON = 'CANCEL' then PAR.i = ''
               when MOVE.VSTRING = MOVE.2 then PAR.i = '-mf'
               when MOVE.VSTRING = MOVE.3 then PAR.i = '-mu'
               when MOVE.VSTRING = MOVE.4 then PAR.i = '-m-'
               when MOVE.VSTRING = MOVE.5 then PAR.i = '-m-f'
               when MOVE.VSTRING = MOVE.6 then PAR.i = '-m-u'
               otherwise nop
            end
            drop BUTTON MOVE.
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = '-x' then do
            PAR.i = ''
            drop FILES.
            if EXT = 'BAT' then FILES.0 = 10
            if EXT = 'CMD' then FILES.0 = 7
            call linein TEXT,1
            do 85
               call linein TEXT
            end
            do y = 1 to FILES.0
               FILES.y = linein(TEXT)
            end
            BUTEX = vinputbox("Files to Exclude from the .ZIP File:", FILES, 40, 3)
            if BUTEX = 'CANCEL' then do
               ACTION = 'exclude'
               drop DISKFILES
               call DiskFiles
               if DISKFILES = 'DISKFILES' then DISKFILES = ''
               FILES.VSTRING = DISKFILES
               drop VAR. MSG. NUMBER DISKFILES
            end
            do t = 1 while FILES.VSTRING<>''
               select
                  when left(FILES.VSTRING,1) = '"' then do
                     parse var FILES.VSTRING . '"' NAME.t '"' FILES.VSTRING
                     NAME.t = '"'||NAME.t||'"'
                  end
                  when left(FILES.VSTRING,1) = "'" then do
                     parse var FILES.VSTRING . "'" NAME.t "'" FILES.VSTRING
                     NAME.t = "'"||NAME.t||"'"
                  end
                  otherwise parse var FILES.VSTRING NAME.t FILES.VSTRING
               end
               FILES.VSTRING = strip(FILES.VSTRING)
               NAME.0 = t
            end
            select
               when (symbol('NAME.0') = 'VAR')&(BUTEX = 'OK') then do t = 1 to NAME.0
                  PAR.i = strip(PAR.i '-x'||DIRNAME2||NAME.t)
               end
               when symbol('NAME.0') = 'VAR' then do t = 1 to NAME.0
                  PAR.i = strip(PAR.i '-x'||DIRNAME2||filespec('name',NAME.t))
               end
               otherwise nop
            end
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
            drop BUTEX FILES. DISKFILES NAME.
         end
         when PAR.i = 'date' then do
            DATE.0 = 2
            DATE.1 = '-k = keep date stamp of existing .ZIP file'
            DATE.2 = '-o = use date stamp of latest file inside .ZIP    '
            DATE.VSTRING = DATE.2
            THAT = vradiobox('Which Date?', DATE, 3)
            if THAT = 'OK' then PAR.i = left(DATE.VSTRING,2)
            if (PAR.i = '-k')&(NEWZIP = 'yes') then call CantUse
            drop DATE. THAT
            if (PAR.i<>'')&(PAR.i<>'date') then do
               OPTIONS = strip(OPTIONS PAR.i)
               call WinBox
            end
         end
         when PAR.i = 'only' then do
            ONLY.1 = '-f = freshen files already in .ZIP file'
            ONLY.2 = '-i = backup files by archive attributes (turn them off)   '
            if VER = 1 then do
               ONLY.0 = 4
               ONLY.3 = '-t = zip only files modified on or after date ....'
               ONLY.4 = '-u = update existing .ZIP with new and modified files          '
            end
            else do
               ONLY.0 = 5
               ONLY.3 = '-i-= backup files by archive attributes (leave them on)'
               ONLY.4 = '-t = zip files according to their last modification date ....  '
               ONLY.5 = '-u = update existing .ZIP with new and modified files'
            end
            ONLY.VSTRING = ONLY.2
            THAT = vradiobox('Which Files?', ONLY, 3)
            PAR.i = left(ONLY.VSTRING,2)
            if THAT = 'CANCEL' then PAR.i = ''
            select
               when (VER = 1)&(PAR.i = '-t') then do
                  drop DAT. BUTTON
                  DAT.0 = 3
                  call linein TEXT,1
                  do 122
                     call linein TEXT
                  end
                  do y = 1 to 3
                     DAT.y = linein(TEXT)
                  end
                  do until (BUTTON = 'CANCEL')|((TEST = 1)&(length(DAT.VSTRING) = 6))|(DAT.VSTRING = '')
                     BUTTON = vinputbox('Input the Date:', DAT, 10, 3)
                     TEST = datatype(DAT.VSTRING,'W')
                  end
                  drop TEST
                  PAR.i = '-t'DAT.VSTRING
                  if BUTTON = 'CANCEL' then PAR.i = ''
               end
               when PAR.i = '-t' then PAR.i = ZipView.CMD('Date2')
               when (VER = 2)&(PAR.i = ONLY.3) then PAR.i = '-i-'
               when (NEWZIP = 'yes')&((PAR.i = '-u')|(PAR.i = '-f')) then call CantUse
               otherwise nop
            end
            drop BUTTON ONLY. THAT DAT.
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = 'further' then do
            drop PAR2.
            if VER = 2 then do
               OTHER.0 = 8
               OTHER.1 = '-@ = generate list file instead of zipping'
               OTHER.2 = '-! = include authenticity validation info'
               OTHER.3 = '-$ = store volume label in .ZIP file ....'
               OTHER.4 = '-e = choose compression method ....'
               OTHER.5 = '-q = enable ANSI support for comments'
               OTHER.6 = '-s = password ....'
               OTHER.7 = '     attributes ....'
               OTHER.8 = '     troubleshooting and compatibility options ....   '
            end
            if VER = 1 then do
               OTHER.0 = 7
               OTHER.1 = '-! = include authenticity validation info'
               OTHER.2 = '-$ = store volume label in .ZIP file ....'
               OTHER.3 = '-e = choose compression method ....'
               OTHER.4 = '-q = enable ANSI support for comments'
               OTHER.5 = '-s = password ....'
               OTHER.6 = '     attributes ....'
               OTHER.7 = '     troubleshooting and compatibility options ....   '
            end
            call vcheckbox 'Further Options:', OTHER, PAR2, 1
            drop OTHER.
            do p = 1 to PAR2.0
               if left(PAR2.p,1) = '-' then PAR2.p = left(PAR2.p,2)
               else do
                  if substr(PAR2.p,6,1) = 'a' then PAR2.p = 'attributes'
                  if substr(PAR2.p,6,1) = 't' then PAR2.p = 'trouble'
               end
            end
            do q = 1 to PAR2.0
               select
                  when PAR2.q = '-@' then do
                     OPTIONS = strip(OPTIONS ZipView.CMD('List'))
                     call WinBox
                  end
                  when PAR2.q = '-!' then do
                     OPTIONS = strip(OPTIONS PAR2.q)
                     call WinBox
                  end
                  when PAR2.q = '-$' then do
                     drop MSG.
                     MSG.0 = 2
                     MSG.1 = 'Type the letter for the drive whose volume label   '
                     MSG.2 = 'you want to include in the .ZIP file:   '
                     do until (BUTTON = 'CANCEL')|(datatype(left(MSG.VSTRING,1),'M') = 1)
                        BUTTON = vinputbox('Drive Letter:', MSG, 3, 3)
                     end
                     if BUTTON = 'OK' then OPTIONS = strip(OPTIONS '-$'left(MSG.VSTRING,1))
                     drop BUTTON MSG.
                     call WinBox
                  end
                  when PAR2.q = 'trouble' then do
                     TRBL.0 = 2
                     TRBL.1 = '-^ = echo the command line before executing      '
                     TRBL.2 = '-3 = disable 32-bit instructions (386 or up)     '
                     if VER = 2 then do
                        TRBL.0 = 8
                        TRBL.3 = '-+ = disable EMS usage'
                        TRBL.4 = '-- = disable XMS/UMB usage'
                        TRBL.5 = '-) = disable DPMI usage'
                        TRBL.6 = '-( = disable RAM cache usage (486 or up)   '
                        TRBL.7 = '-~ = disable Network detection'
                        TRBL.8 = '-= = ignore Share and other file lockers   '
                     end
                     call vcheckbox 'Troubleshooting Options:', TRBL, TRBL2, 1
                     do x = 1 to TRBL2.0
                        OPTIONS = strip(OPTIONS left(TRBL2.x,2))
                     end
                     call WinBox
                     drop TRBL. TRBL2.
                  end
                  when PAR2.q = '-e' then do
                     COMPR.0 = 5
                     if VER = 1 then do
                        COMPR.1 = 'a = Implode ASCII files, Shrink Binary files    '
                        COMPR.2 = 'b = Implode Binary files, Shrink ASCII files'
                        COMPR.3 = 'i = Implode only'
                        COMPR.4 = 's = Shrink all'
                        COMPR.5 = 'x = Implode all (default)'
                        COMPR.VSTRING = COMPR.5
                     end
                     if VER = 2 then do
                        COMPR.1 = '0 = Store all (no compression)   '
                        COMPR.2 = 'f = Fast'
                        COMPR.3 = 'n = Default'
                        COMPR.4 = 's = Super Fast'
                        COMPR.5 = 'x = Smallest'
                        COMPR.VSTRING = COMPR.3
                     end
                     call vradiobox 'Which Compression Method?', COMPR, 1
                     OPTIONS = strip(OPTIONS '-e'left(COMPR.VSTRING,1))
                     drop COMPR.
                     call WinBox
                  end
                  when PAR2.q = '-q' then do
                     OPTIONS = strip(OPTIONS PAR2.q)
                     call WinBox
                  end
                  when PAR2.q = '-s' then do
                     if DIRNAME = '-x*.*' then do
                        MSG.0 = 5
                        call linein TEXT,1
                        do 253
                           call linein TEXT
                        end
                        do y = 1 to 5
                           MSG.y = linein(TEXT)
                        end
                        call vmsgbox 'Sorry!', MSG, 1
                        drop MSG.
                        PAR2.q = ''
                     end
                     else do
                        call Password
                        if PS<>'PS' then PAR2.q = PS
                        else PAR2.q = ''
                        drop PS
                     end
                     OPTIONS = strip(OPTIONS PAR2.q)
                     call WinBox
                  end
                  when PAR2.q = 'attributes' then do
                     PAR2.q = ''
                     drop ATT1. ATT.
                     ATT.0 = 2
                     ATT.1 = '-j = do not give attributes to the compressed files ....   '
                     ATT.2 = '-w = compress files that have H/S attributes ....  '
                     BUTTON = vcheckbox('Attributes', ATT, ATT1, 3)
                     if BUTTON = 'OK' then do
                        do s = 1 to ATT1.0
                           ATT1.s = left(ATT1.s,2)
                        end
                        do s = 1 to ATT1.0
                           drop U3.
                           if ATT1.s = '-j' then MASK.0 = 3
                           if ATT1.s = '-w' then MASK.0 = 2
                           MASK.1 = 'Hidden'
                           MASK.2 = 'System'
                           if ATT1.s = '-j' then MASK.3 = 'Read-only'
                           if ATT1.s = '-j' then BUT = vcheckbox('Which to Mask?', MASK, U3, 3)
                           if ATT1.s = '-w' then BUT = vcheckbox('Which to Compress?', MASK, U3, 3)
                           if BUT = 'OK' then do k = 1 to U3.0
                              ATT1.s = ATT1.s||left(U3.k,1)
                           end
                           if length(ATT1.s) = 2 then ATT1.s = ''
                           PAR2.q = strip(PAR2.q ATT1.s)
                        end
                     end
                     drop BUTTON ATT1. MASK. ATT. U3.
                     OPTIONS = strip(OPTIONS PAR2.q)
                     call WinBox
                  end
                  otherwise nop
               end
            end
         end
         otherwise nop
      end
   end
   drop PAR. PAR2.
return
UnzOpt:
   OPTIONS = strip(AOP UOP)
   if OPTIONS<>'' then call WinBox
   drop PAR.
   ULIST1.1 = '-$ = extract volume label'
   ULIST1.2 = '-d = create directories'
   ULIST1.3 = '-e = extract files in a certain order ....'
   ULIST1.4 = "-J = keep attributes of the extracted files .... "
   ULIST1.6 = '-s = unscramble with password ....'
   if VER = 1 then do
      ULIST1.0 = 9
      ULIST1.5 = '-o = overwrite existing files'
      ULIST1.7 = '     extract only newer files ....'
      ULIST1.8 = '     extract only specified filenames ....'
      ULIST1.9 = '     further options ....'
   end
   if VER = 2 then do
      ULIST1.0 = 10
      ULIST1.5 = '-o = extract without prompting for overwrite ....'
      ULIST1.7 = '-x = exclude certain files ....'
      ULIST1.8 = '     extract only newer files ....'
      ULIST1.9 = '     extract only specified filenames ....'
      ULIST1.10 = '     further options ....'
   end
   BUTTON = vcheckbox('Unzip Special OPTIONAL Switches:', ULIST1, PAR, 3)
   if BUTTON = 'CANCEL' then do
      call vclosewindow WINDOW
      signal Main
   end
   drop BUTTON
   do i = 1 to PAR.0
      if left(PAR.i,1) = '-' then PAR.i = left(PAR.i,2)
      else select
         when (substr(PAR.i,6,1) = 'e')&(substr(PAR.i,19,1) = 'n') then PAR.i = 'newer'
         when substr(PAR.i,6,1) = 'e' then PAR.i = 'specified'
         when substr(PAR.i,6,1) = 'f' then PAR.i = 'further'
         otherwise nop
      end
   end
   drop ULIST1.
   do i = 1 to PAR.0
      select
         when PAR.i = '-x' then do
            PAR.i = ''
            drop FILES.
            if EXT = 'BAT' then FILES.0 = 10
            if EXT = 'CMD' then FILES.0 = 7
            call linein TEXT,1
            do 96
               call linein TEXT
            end
            do y = 1 to FILES.0
               FILES.y = linein(TEXT)
            end
            BUTEX = vinputbox("Files to Exclude from Extraction:", FILES, 40, 3)
            if BUTEX = 'CANCEL' then do
               OPER = 'exclude'
               call View
               if DISKFILES = 'DISKFILES' then DISKFILES = ''
               FILES.VSTRING = DISKFILES
               drop OPER DISKFILES VAR. MSG. NUMBER
            end
            do t = 1 while FILES.VSTRING<>''
               select
                  when left(FILES.VSTRING,1) = '"' then do
                     parse var FILES.VSTRING . '"' NAME.t '"' FILES.VSTRING
                     NAME.t = '"'||NAME.t||'"'
                  end
                  when left(FILES.VSTRING,1) = "'" then do
                     parse var FILES.VSTRING . "'" NAME.t "'" FILES.VSTRING
                     NAME.t = "'"||NAME.t||"'"
                  end
                  otherwise parse var FILES.VSTRING NAME.t FILES.VSTRING
               end
               FILES.VSTRING = strip(FILES.VSTRING)
               NAME.0 = t
            end
            if symbol('NAME.0') = 'VAR' then do t = 1 to NAME.0
               PAR.i = strip(PAR.i '-x'||NAME.t)
            end
            OPTIONS = strip(OPTIONS PAR.i)
            drop FILES. BUTEX NAME.
            call WinBox
         end
         when PAR.i = '-$' then do
            MSG.0 = 3
            call linein TEXT,1
            do 107
               call linein TEXT
            end
            do y = 1 to 3
               MSG.y = linein(TEXT)
            end
            BUTTON = vmsgbox("Really?", MSG, 6)
            if BUTTON = 'YES' then OPTIONS = strip(OPTIONS PAR.i)
            drop BUTTON MSG.
            call WinBox
         end
         when PAR.i = '-d' then do
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = '-e' then do
            ORDER.0 = 6
            ORDER.1 = 'c = CRC'
            ORDER.2 = 'd = date'
            ORDER.3 = 'e = extension'
            ORDER.4 = 'n = name'
            ORDER.5 = 'p = percentage'
            ORDER.6 = 's = size'
            ORDER.VSTRING = ORDER.4
            if VER = 2 then do
               ORDER.0 = 12
               ORDER.7 = 'cr = CRC reverse'
               ORDER.8 = 'dr = date reverse'
               ORDER.9 = 'er = extension reverse'
               ORDER.10 = 'nr = name reverse'
               ORDER.11 = 'pr = percentage reverse'
               ORDER.12 = 'sr = size reverse'
               call vlistbox "What order?", ORDER, 25, 9, 1
            end
            else call vradiobox 'What order?', ORDER, 1
            OPTIONS = strip(OPTIONS '-e'left(ORDER.VSTRING,2))
            drop ORDER.
            call WinBox
         end
         when PAR.i = '-J' then do
            drop U3.
            MASK.0 = 3
            MASK.1 = 'Hidden'
            MASK.2 = 'System'
            MASK.3 = 'Read-only'
            BUTTON = vcheckbox('Which Attributes?', MASK, U3, 3)
            if BUTTON = 'OK' then do k = 1 to U3.0
               PAR.i = PAR.i||left(U3.k,1)
            end
            if length(PAR.i) = 2 then PAR.i = ''
            drop BUTTON MASK. U3.
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = '-o' then do
            if VER = 2 then do
               NEWO.0 = 2
               NEWO.1 = '-o = overwrite any matching files    '
               NEWO.2 = '-o-= do not overwrite any files '
               call vradiobox 'Overwrite or not?', NEWO, 1
               if NEWO.VSTRING = NEWO.2 then PAR.i = '-o-'
               drop NEWO.
            end
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = '-s' then do
            call Password
            if PS<>'PS' then PAR.i = PS
            else PAR.i = ''
            drop PS
            OPTIONS = strip(OPTIONS PAR.i)
            call WinBox
         end
         when PAR.i = 'newer' then do
            WHICH.0 = 2
            WHICH.1 = 'Newer Files Only'
            WHICH.2 = 'Newer Existing Files Only      '
            WHICH.VSTRING = WHICH.1
            call vradiobox 'Specify:', WHICH, 1
            if WHICH.VSTRING = WHICH.2 then OPTIONS = strip(OPTIONS '-f')
            else OPTIONS = strip(OPTIONS '-n')
            drop WHICH.
            call WinBox
         end
         when PAR.i = 'specified' then do
            drop FILES.
            if EXT = 'BAT' then FILES.0 = 10
            if EXT = 'CMD' then FILES.0 = 7
            call linein TEXT,1
            do 111
               call linein TEXT
            end
            do y = 1 to FILES.0
               FILES.y = linein(TEXT)
            end
            BUTTON = vinputbox("Files to Extract from the .ZIP File:", FILES, 40, 3)
            drop DISKFILES
            if BUTTON = 'CANCEL' then do
               OPER = 'extract'
               call View
            end
            drop BUTTON VAR. MSG. NUMBER
            if FILES.VSTRING = 'FILES.VSTRING' then FILES.VSTRING = ''
            if DISKFILES = 'DISKFILES' then DISKFILES = ''
            FILENAMES = strip(DISKFILES FILES.VSTRING)
            drop DISKFILES FILES.
            call WinBox
         end
         when PAR.i = 'further' then do
            drop PAR2.
            if VER = 2 then do
               OTHER.0 = 5
               OTHER.1 = "-@ = generate list file instead of unzipping ....  "
               OTHER.2 = "-c = extract to screen ...."
               OTHER.3 = "-p = extract to printer ...."
               OTHER.4 = "-q = enable ANSI support for comments"
               OTHER.5 = '     troubleshooting and compatibility options ....'
            end
            if VER = 1 then do
               OTHER.0 = 4
               OTHER.1 = "-c = extract to screen ...."
               OTHER.2 = "-p = extract to printer ...."
               OTHER.3 = "-q = enable ANSI support for comments"
               OTHER.4 = '     troubleshooting and compatibility options ....  '
            end
            call vcheckbox 'Additional Options:', OTHER, PAR2, 1
            drop OTHER.
            do p = 1 to PAR2.0
               if left(PAR2.p,1) = '-' then PAR2.p = left(PAR2.p,2)
               else PAR2.p = 'trouble'
            end
            do q = 1 to PAR2.0
               select
                  when PAR2.q = '-@' then do
                     OPTIONS = strip(OPTIONS ZipView.CMD('List'))
                     call WinBox
                  end
                  when PAR2.q = 'trouble' then do
                     TRBL.0 = 2
                     TRBL.1 = '-^ = echo the command line before executing      '
                     TRBL.2 = '-3 = disable 32-bit instructions (386 or up)     '
                     if VER = 2 then do
                        TRBL.0 = 5
                        TRBL.3 = '-+ = disable EMS usage'
                        TRBL.4 = '-- = disable XMS/UMB usage'
                        TRBL.5 = '-) = disable DPMI usage'
                     end
                     call vcheckbox 'Troubleshooting Options:', TRBL, TRBL2, 1
                     do x = 1 to TRBL2.0
                        OPTIONS = strip(OPTIONS left(TRBL2.x,2))
                     end
                     call WinBox
                     drop TRBL. TRBL2.
                  end
                  when PAR2.q = '-c' then do
                     call ZipView.CMD 'Sure -c' OPTIONS
                     parse var RESULT PAR2.q '/' OPTIONS
                     if PAR2.q = '-c' then do
                        DONT = 'NO'
                        PEE = wordpos('-p',PAR2.1 PAR2.2 PAR2.3 PAR2.4 PAR2.5)
                        if PEE>0 then PAR2.PEE = ' '
                        drop PEE
                        PAUSE.0 = 2
                        PAUSE.1 = 'pause on each screen'
                        PAUSE.2 = 'no pause'
                        PAUSE.VSTRING = PAUSE.1
                        call vradiobox 'Pause?', PAUSE, 1
                        if PAUSE.VSTRING = PAUSE.1 then PAR2.q = '-cm'
                        drop PAUSE.
                        OPTIONS = strip(OPTIONS PAR2.q)
                     end
                     call WinBox
                  end
                  when PAR2.q = '-p' then do
                     call ZipView.CMD 'Sure -p' OPTIONS
                     parse var RESULT PAR2.q '/' OPTIONS
                     if PAR2.q = '-p' then do
                        DONT = 'NO'
                        PRINT.0 = 6
                        PRINT.1 = 'a = ASCII mode (and form feed)'
                        PRINT.2 = 'b = Binary mode (and no form feed)'
                        PRINT.3 = '  Do NOT choose more than one of the above!       '
                        PRINT.4 = ' '
                        PRINT.5 = 'c = COM port instead of LPT port'
                        PRINT.6 = '# = Port number if not 1 ....'
                        call vcheckbox 'Optional:', PRINT, UA, 1
                        do n = 1 to UA.0
                           select
                              when left(UA.n,1) = 'a' then PAR2.q = PAR2.q'a'
                              when left(UA.n,1) = 'b' then PAR2.q = PAR2.q'b'
                              when left(UA.n,1) = 'c' then PAR2.q = PAR2.q'c'
                              when left(UA.n,1) = '#' then do
                                 PORT.0 = 3
                                 PORT.1 = '2'
                                 PORT.2 = '3'
                                 PORT.3 = '4'
                                 PORT.VSTRING = PORT.1
                                 call vradiobox 'Select Port Number:', PORT, 1
                                 PAR2.q = PAR2.q||PORT.VSTRING
                                 drop PORT.
                              end
                              otherwise nop
                           end
                        end
                        OPTIONS = strip(OPTIONS PAR2.q)
                        call WinBox
                        MSG.0 = 1
                        MSG.1 = 'Turn the printer on and make sure it has paper!'
                        call vmsgbox "Notice:", MSG, 1
                        drop MSG. PRINT. UA.
                     end
                     else call WinBox
                  end
                  when PAR2.q = '-q' then do
                     OPTIONS = strip(OPTIONS PAR2.q)
                     call WinBox
                  end
                  otherwise nop
               end
            end
         end
         otherwise nop
      end
   end
   drop PAR. PAR2.
return
Temp:
   drop DIR.
   DIR.0 = 9
   call linein TEXT,1
   do 126
      call linein TEXT
   end
   do y = 1 to 9
      if (y = 4)|(y = 7) then DIR.y = ''
      else DIR.y = linein(TEXT)
   end
   if TEMPOLD<>'' then DIR.VSTRING = TEMPOLD
   call vinputbox 'OPTIONAL Temporary directory:', DIR, 40, 1
   TEMPOLD = Validate(DIR.VSTRING)
   if TEMPOLD = 'NO WAY' then do
      TEMPOLD = DIR.VSTRING
      call Temp
      return
   end
   drop DIR.
return
DiskFiles:
   DISKFILES = ''
   drop VAR. NUMBER MSG. BUTTON
   call sysfiletree DIRNAME2'*.*', 'VAR', 'OF'
   SubDiskFiles:
   if BUTTON = 'CANCEL' then return
   if NUMBER = 'NUMBER' then NUMBER = 0
   do a = NUMBER+1 to NUMBER+10
      if VAR.a = 'VAR.'a then VAR.a = ' '
   end
   if value('VAR.'NUMBER+1) = ' ' then return
   MSG.0 = 10
   NEWNUM = NUMBER
   do y = 1 to 10
      NEWNUM = NEWNUM+1
      MSG.y = value('VAR.'NEWNUM)'                  '
   end
   NUMBER = NUMBER+10
   DATA = ACTION'files'NUMBER'.0'
   interpret DATA "= 0"
   drop DATA NEWNUM
   BUTTON = vcheckbox("Choose the files to" ACTION':', MSG, value(ACTION'files'||NUMBER), 3)
   if BUTTON = 'OK' then do e = 1 to value(ACTION'files'||NUMBER'.0')
      DISKFILES = strip(DISKFILES value(ACTION'files'||NUMBER'.'e))
   end
   call SubDiskFiles
   if DISKFILES = '' then drop DISKFILES
   DATA = ACTION'files'||NUMBER'.'
   drop MSG. value(DATA) DATA BUTTON VAR.
return
View:
   AB123 = EXECUTABLE ; AB456 = OPTIONS ; DISKFILES = '' ; EXECUTABLE = ZIP ; OPTIONS = strip(AOP '-v')
   call Order
   if (SOURCE = '')&((OPER = 'extract')|(OPER = 'exclude')) then call Source
   if OPER = 'delete' then do
      POS.left = 37 ; POS.right = 63 ; POS.top = 50 ; POS.bottom = 35
      WINDOW = vopenwindow('Zip Engine', BG, POS)
      call vsetfont WINDOW, 'SYSTEM', 10
      call vforecolor WINDOW, FG
      drop POS.
      WINORG = WINDOW
      call vsay WINDOW, 150, 500, 'Working.....'
      call vsay WINDOW, 150, 300, 'Please wait.....'
   end
   else do
      call vclearwindow WINDOW
      call vsay WINDOW, 200, 400, 'Working.....Please Wait........'
   end
   if right(TEMPOLD,1)='\' then do
      TEMPBFILE = systempfilename(TEMPOLD'1?????.'EXT)
      TEMPBFILE2 = systempfilename(TEMPOLD'2?????.tmp')
   end
   else do
      TEMPBFILE = systempfilename(TEMPOLD'\1?????.'EXT)
      TEMPBFILE2 = systempfilename(TEMPOLD'\2?????.tmp')
   end
   call lineout TEMPBFILE,'@ECHO OFF'
   call lineout TEMPBFILE2
   if RESULT = 1 then do
      call vclosewindow WINDOW
      call CreateError
   end
   call lineout TEMPBFILE,EXECUTABLE OPTIONS SOURCE " >> " TEMPBFILE2
   call lineout TEMPBFILE,"ATTRIB -R" TEMPBFILE
   call lineout TEMPBFILE,"REM If Zip Engine isn't running at this moment, delete this file."
   call lineout TEMPBFILE
   'ATTRIB +R' TEMPBFILE
   'start /b /c' TEMPBFILE
   do until rc = 0
      rc = sysfiledelete(TEMPBFILE)
      if rc<>0 then call syssleep 1
   end
   drop THATNUM MSG. VAR. NUMBER TEMPBFILE BUTTON
   do until word(THISLINE,1) = 'Length'
      if \ lines(TEMPBFILE2) then do
         MSG.0 = 3
         MSG.1 = 'A strange occurrence......there are no'
         MSG.2 = 'files inside this .ZIP file.  Returning'
         MSG.3 = 'you to the main menu now.'
         call vmsgbox 'Sorry!', MSG, 1
         if OPER = 'delete' then do
            call vclosewindow WINDOW
            drop WINORG
         end
         call lineout TEMPBFILE2
         call sysfiledelete TEMPBFILE2
         signal Main
      end
      THISLINE = linein(TEMPBFILE2)
   end
   call linein TEMPBFILE2
   if THATNUM = 'THATNUM' then THATNUM = 1
   do while lines(TEMPBFILE2) = 1
      VAR.THATNUM = substr(linein(TEMPBFILE2),62)
      THATNUM = THATNUM+1
   end
   call lineout TEMPBFILE2
   call sysfiledelete TEMPBFILE2
   VAR.0 = THATNUM-3
   call vclearwindow WINDOW
   call SubView
   EXECUTABLE = AB123 ; OPTIONS = AB456
   drop AB123 AB456 VAR. MSG. TEMPBFILE2 THISLINE THATNUM
   if (OPER = 'extract')|(OPER = 'exclude') then READY = 'YES'
   DATA = OPER'files'||NUMBER'.'
   drop value(DATA) DATA
   if OPER = 'delete' then do
      call vclosewindow WINDOW
      drop WINORG
   end
return
SubView:
   if BUTTON = 'CANCEL' then return
   if NUMBER = 'NUMBER' then NUMBER = 0
   do a = NUMBER+1 to NUMBER+10
      if a>VAR.0 then VAR.a = ' '
   end
   if value('VAR.'NUMBER+1) = ' ' then return
   MSG.0 = 10
   NEWNUM = NUMBER
   do y = 1 to 10
      NEWNUM = NEWNUM+1
      MSG.y = value('VAR.'NEWNUM)'                  '
   end
   NUMBER = NUMBER+10
   DATA = OPER'files'NUMBER'.0'
   interpret DATA "= 0"
   drop DATA NEWNUM
   BUTTON = vcheckbox("Choose the files to" OPER':', MSG, value(OPER'files'||NUMBER), 3)
   if BUTTON = 'OK' then do e = 1 to value(OPER'files'||NUMBER'.0')
      DISKFILES = strip(DISKFILES value(OPER'files'||NUMBER'.'e))
   end
   call SubView
   if DISKFILES = '' then drop DISKFILES
return
ViewOnly:
   if wordpos('-s',OPTIONS)>0 then do
      POS.left = 2 ; POS.right = 98 ; POS.top = 25 ; POS.bottom = 10
      WINDOW = vopenwindow('(Zip Engine) Working.....', BG, POS)
      call vsetfont WINDOW, 'SYSTEM', 10
      call vforecolor WINDOW, FG
      call linein TEXT,1
      do 270
         call linein TEXT
      end
      do k = 700 to 100 by -200
         call vsay WINDOW, 5, k, linein(TEXT)
      end
   end
   else do
      POS.left = 35 ; POS.right = 65 ; POS.top = 50 ; POS.bottom = 35
      WINDOW = vopenwindow('Zip Engine', BG, POS)
      call vsetfont WINDOW, 'SYSTEM', 10
      call vforecolor WINDOW, FG
      call vsay WINDOW, 150, 500, 'Working.....'
      call vsay WINDOW, 150, 300, 'Please wait.....'
   end
   drop POS.
   WINORG = WINDOW
   drop THATNUM
   if right(TEMPOLD,1)='\' then do
      TEMPCFILE = systempfilename(TEMPOLD'1?????.'EXT)
      TEMPCFILE2 = systempfilename(TEMPOLD'2?????.tmp')
   end
   else do
      TEMPCFILE = systempfilename(TEMPOLD'\1?????.'EXT)
      TEMPCFILE2 = systempfilename(TEMPOLD'\2?????.tmp')
   end
   call lineout TEMPCFILE,'@ECHO OFF'
   call lineout TEMPCFILE2
   if RESULT = 1 then do
      call vclosewindow WINDOW
      call CreateError
   end
   call lineout TEMPCFILE,EXECUTABLE OPTIONS SOURCE " >> " TEMPCFILE2
   call lineout TEMPCFILE,'ATTRIB -R' TEMPCFILE
   call lineout TEMPCFILE,"echo If Zip Engine isn't running at this moment, delete this file."
   call lineout TEMPCFILE
   'ATTRIB +R' TEMPCFILE
   if wordpos('-s',OPTIONS)>0 then 'start /win /b /c' TEMPCFILE
   else 'start /b /c' TEMPCFILE
   do until rc = 0
      rc = sysfiledelete(TEMPCFILE)
      if rc<>0 then call syssleep 1
   end
   if wordpos('-s',OPTIONS)>0 then do
      POS.left = 35 ; POS.right = 65 ; POS.top = 50 ; POS.bottom = 35
      call vclearwindow WINDOW
      call vsettitle WINDOW, 'Zip Engine'
      call vresize WINDOW, POS
      call vsay WINDOW, 150, 500, 'Working.....'
      call vsay WINDOW, 150, 300, 'Please wait.....'
      drop POS.
   end
   drop MSG. TEMPCFILE
   if THATNUM = 'THATNUM' then THATNUM = 1
   do while lines(TEMPCFILE2) = 1
      MSG.THATNUM = left(linein(TEMPCFILE2),80)
      THATNUM = THATNUM+1
   end
   call lineout TEMPCFILE2
   MSG.0 = THATNUM-1
   call vlistbox "Here's what you wanted to see:", MSG, 100, 10, 1
   call sysfiledelete TEMPCFILE2
   drop MSG. TEMPCFILE2 THATNUM
return
CreateError:
   MSG.0 = 10
   call linein TEXT,1
   do 259
      call linein TEXT
   end
   do y = 1 to 10
      MSG.y = linein(TEXT)
   end
   call vmsgbox "Sorry!", MSG, 1
   signal Main
return
CantUse:
   MSG.0 = 3
   MSG.1 = 'You cannot use the' PAR.i 'switch when'
   if NEWZIP<>'yes' then MSG.2 = 'you modify an existing .ZIP file.'
   else MSG.2 = 'you create a new .ZIP file.'
   MSG.3 = 'Dropping the' PAR.i 'switch now.'
   call vmsgbox "Sorry!", MSG, 1
   PAR.i = ''
   drop MSG.
return
