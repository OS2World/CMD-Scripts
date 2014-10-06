/* The Zip Engine -- A shareware graphical approach to file zipping/unzipping */
/* Copyright 1992-93 Kari Jackson and Bart Toulouse */
/* View-Text-Files-Within-a-.ZIP Subroutine, and a couple others */
parse arg ARGS
if (lastpos('/',ARGS)<25)&(ARGS<>'Date2')&(ARGS<>'List')&(left(ARGS,5)<>'About')&(left(ARGS,4)<>'Sure') then do
   say 'Sorry, this is not a standalone program.  It should be'
   say 'used only as a subroutine of the Zip Engine program.'
   signal End
end
if ARGS = 'Date2' then do
   drop ARGS
   call Date2
   return RESULT
end
if left(ARGS,4) = 'Sure' then do
   parse var ARGS . PAR2.q OPTIONS
   drop ARGS
   call Sure
   return RESULT
end
if ARGS = 'List' then do
   drop ARGS
   call ListFile
   return RESULT
end
if left(ARGS,5) = 'About' then do
   parse var ARGS . TEXT '/' BG '/' FG
   drop ARGS
   call About
   return
end
parse var ARGS TEXT '/' EXECUTABLE '/' OPTIONS '/' SOURCE '/' DIRNAME '/' EXT '/' BG '/' FG
drop ARGS
if right(DIRNAME,1) = '\' then DIRNAME2 = systempfilename(DIRNAME'ZIP?????')
else DIRNAME2 = systempfilename(DIRNAME'\ZIP?????')
rc = sysmkdir(DIRNAME2)
if rc<>0 then do
   MSG.0 = 3
   call linein TEXT,1
   do 138
      call linein TEXT
   end
   do y = 1 to 3
      MSG.y = linein(TEXT)
   end
   call vmsgbox "Oops!", MSG, 1
   return
end
drop rc
POS.left = 10 ; POS.right = 90 ; POS.top = 25 ; POS.bottom = 10
WINDOW = vopenwindow('(Zip Engine) Working.....', BG, POS)
call vsetfont WINDOW, 'SYSTEM', 10
call vforecolor WINDOW, FG
drop POS.
call vsay WINDOW, 200, 700, 'Please wait..........'
call vsay WINDOW, 50, 500, 'We are unzipping the' SOURCE
call vsay WINDOW, 50, 300, 'file into a temporary directory named'
call vsay WINDOW, 50, 100, DIRNAME2"."
if right(DIRNAME,1)='\' then TEMPAFILE = systempfilename(DIRNAME'1?????.'EXT)
else TEMPAFILE = systempfilename(DIRNAME'\1?????.'EXT)
call lineout TEMPAFILE,'@ECHO OFF'
if RESULT = 1 then do
   call sysrmdir DIRNAME2
   call vclosewindow WINDOW
   return 'error'
end
call lineout TEMPAFILE,EXECUTABLE OPTIONS SOURCE DIRNAME2
call lineout TEMPAFILE,"ATTRIB -R" TEMPAFILE
call lineout TEMPAFILE,"REM If Zip Engine isn't running at this moment, delete this file."
call lineout TEMPAFILE
'ATTRIB +R' TEMPAFILE
if wordpos('-s',OPTIONS)>0 then 'start /win /b /c' TEMPAFILE
else 'start /b /c' TEMPAFILE
do until rc = 0
   rc = sysfiledelete(TEMPAFILE)
   if rc<>0 then call syssleep 1
end
drop TEMPAFILE
DIRNAME2 = DIRNAME2'\'
call DiskFiles
if (DISKFILES<>'')&(DISKFILES<>'DISKFILES') then do
   POS.left = 2 ; POS.right = 98 ; POS.top = 25 ; POS.bottom = 10
   call vclearwindow WINDOW
   call vresize WINDOW, POS
   drop POS.
   do until DISKFILES = 'DISKFILES'
      call ViewDiskFiles
      call DiskFiles
   end
end
else if EXIST<>'yes' then do
   MSG.0 = 3
   MSG.1 = 'A strange occurrence......no files came out of'
   MSG.2 = 'this .ZIP file for some reason.  Returning'
   MSG.3 = 'you to the main menu now.'
   call vmsgbox 'Sorry!', MSG, 1
end
call vclosewindow WINDOW
do x = 1 to VAR.0
   call sysfiledelete VAR.x
end
call sysrmdir left(DIRNAME2,length(DIRNAME2)-1)
return
ViewDiskFiles:
   drop BUTTON2
   do b = 1 while DISKFILES<>''
      select
         when left(DISKFILES,1) = '"' then do
            parse var DISKFILES . '"' NAME.b '"' DISKFILES
            NAME.b = '"'||NAME.b||'"'
         end
         when left(DISKFILES,1) = "'" then do
            parse var DISKFILES . "'" NAME.b "'" DISKFILES
            NAME.b = "'"||NAME.b||"'"
         end
         otherwise parse var DISKFILES NAME.b DISKFILES
      end
      DISKFILES = strip(DISKFILES)
      NAME.0 = b
   end
   if symbol('NAME.0') = 'VAR' then do b = 1 to NAME.0 while BUTTON2<>'CANCEL'
      VIEWER = NAME.b
      if translate(right(VIEWER,4)) = '.INF' then do
         FIN.0 = 5
         FIN.1 = "You've chosen" VIEWER'.'
         FIN.2 = 'If' SOURCE
         FIN.3 = "contains an OS/2 program, its .INF file is probably"
         FIN.4 = 'meant to be read with the VIEW command.  Click on YES'
         FIN.5 = 'for VIEW or NO for plain text.'
         BUTINF = vmsgbox(".INF File", FIN, 6)
         if BUTINF = 'YES' then do
            'VIEW.EXE' VIEWER
            OUT.0 = 8
            call linein TEXT,1
            do 142
               call linein TEXT
            end
            do y = 1 to 8
               OUT.y = linein(TEXT)
            end
            call vmsgbox "WAIT!  Warning:", OUT, 1
         end
         else call ViewThis
         drop FIN. BUTINF OUT.
      end
      else call ViewThis
   end
   drop VIEWER NAME.
return
ViewThis:
   call vclearwindow WINDOW
   call vsay WINDOW, 200, 700, 'Please wait..............Retrieving text from the file.'
   call vsay WINDOW, 5, 500, 'Only the first 80 characters of each line (which is all there is in'
   call vsay WINDOW, 5, 300, 'most text files), and only the first 630 lines of the file, will be'
   call vsay WINDOW, 5, 100, "displayed."
   drop MSG.
   THATNUM = 1
   do while (lines(VIEWER))&(THATNUM<631)
      MSG.THATNUM = left(linein(VIEWER),80)
      THATNUM = THATNUM+1
   end
   if lines(VIEWER) then MSG.THATNUM = '                       <<<Those were the first 630 lines of your file>>>'
   else do
      MSG.THATNUM = ' '
      THATNUM = THATNUM+1
      MSG.THATNUM = '                                       <<<End of File>>>'
   end
   call lineout VIEWER
   MSG.0 = THATNUM
   BUTTON2 = vlistbox("View the" VIEWER "file:", MSG, 100, 10, 3)
   call vclearwindow WINDOW
   drop MSG. THATNUM
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
   EXIST = 'yes'
   MSG.0 = 10
   NEWNUM = NUMBER
   do y = 1 to 10
      NEWNUM = NEWNUM+1
      MSG.y = value('VAR.'NEWNUM)'                  '
   end
   NUMBER = NUMBER+10
   DATA = 'files'NUMBER'.0'
   interpret DATA "= 0"
   drop DATA NEWNUM
   BUTTON = vcheckbox("Choose the files to view:", MSG, value('files'||NUMBER), 3)
   if BUTTON = 'OK' then do e = 1 to value('files'||NUMBER'.0')
      DISKFILES = strip(DISKFILES value('files'||NUMBER'.'e))
   end
   call SubDiskFiles
   if DISKFILES = '' then drop DISKFILES
   DATA = 'files'||NUMBER'.'
   drop MSG. value(DATA) DATA
return
Date2:
   PAR.i = ''
   T1.0 = 2
   T1.1 = 'On or after MMDDYY: (-t)      '
   T1.2 = 'Before MMDDYY: (-T)      '
   T2.0 = 2
   T2.1 = ''
   T2.2 = ''
   do until (OK1 = 'ok')&(OK2 = 'ok')
      DATEBUT = vmultbox('Enter the Date(s) in MMDDYY format:', T1, 6, 0, T2, 3)
      if DATEBUT = 'CANCEL' then do
         OK1 = 'ok' ; OK2 = 'ok'
      end
      if T2.1 = '' then OK1 = 'ok' ; if T2.2 = '' then OK2 = 'ok'
      if (length(T2.1) = 6)&(datatype(T2.1,'W') = 1) then OK1 = 'ok'
      if (length(T2.2) = 6)&(datatype(T2.2,'W') = 1) then OK2 = 'ok'
   end
   select
      when (T2.1 = '')&(T2.2 = '')&(DATEBUT = 'OK') then PAR.i = '-t'
      when (T2.1<>'')&(T2.2<>'') then PAR.i = '-t'T2.1 '-T'T2.2
      when T2.1 = '' then PAR.i = '-T'T2.2
      when T2.1<>'' then PAR.i = '-t'T2.1
      otherwise nop
   end
return PAR.i
ListFile:
   LST.0 = 2
   LST.1 = 'Specify the complete drive:\path\filename.ext   '
   LST.2 = 'of the list file you want to create.'
   LST.VSTRING = ''
   do until RESULT<>'NO WAY'
      BUTLIST = vinputbox("List File:", LST, 40, 3)
      drop SLASH FILEN RESULT
      if LST.VSTRING<>'' then do
         SLASH = lastpos('\',LST.VSTRING)
         if SLASH>1 then do
            DIRN = left(LST.VSTRING,SLASH-1)
            FILEN = substr(LST.VSTRING,SLASH+1)
            call Validate DIRN
         end
      end
      else if BUTLIST='OK' then RESULT='NO WAY'
   end
   if RESULT<>'RESULT' then do
      if right(RESULT,1) = '\' then LST.VSTRING = RESULT''FILEN
      else LST.VSTRING = RESULT'\'FILEN
   end
   if (SLASH = 0)&(substr(LST.VSTRING,2,1)<>':') then LST.VSTRING = directory()'\'LST.VSTRING
   else if SLASH = 0 then do
      CURDIR = directory()
      call directory left(LST.VSTRING,2)
      THAT = directory()
      call directory(CURDIR)
      if right(THAT,1)<>'\' then LST.VSTRING = THAT'\'substr(LST.VSTRING,3)
      else LST.VSTRING = THAT''substr(LST.VSTRING,3)
   end
   if LST.VSTRING<>'' then PAR2.q = '-@'LST.VSTRING
   else PAR2.q = ''
return PAR2.q
Validate:
   procedure
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
   MSG.0 = 3
   MSG.1 = 'Please specify a directory name that exists.'
   MSG.2 = VALID
   MSG.3 = 'does not exist.'
   call vmsgbox 'Sorry!', MSG, 1
return 'NO WAY'
About:
   MSG.0 = 8
   call linein TEXT,1
   do 241
      call linein TEXT
   end
   do y = 1 to 8
      if y = 6 then MSG.6 = ''
      else MSG.y = linein(TEXT)
   end
   ABOUT = vmsgbox("About.....", MSG, 3)
   drop MSG.
   if ABOUT = 'CANCEL' then return
   rc = stream('ZIPENG.DOC', 'c', 'query exists')
   if rc<>'' then DOCFILE = rc
   else do
      rc = syssearchpath('PATH','ZIPENG.DOC')
      if rc<>'' then DOCFILE = rc
   end
   if DOCFILE<>'DOCFILE' then do
      POS.left = 35 ; POS.right = 65 ; POS.top = 50 ; POS.bottom = 35
      WINDOW = vopenwindow('Zip Engine', BG, POS)
      call vsetfont WINDOW, 'SYSTEM', 10
      call vforecolor WINDOW, FG
      call vsay WINDOW, 150, 500, 'Working.....'
      call vsay WINDOW, 150, 300, 'Please wait.....'
      do THATNUM = 1 while lines(DOCFILE) = 1
         MSG.THATNUM = left(linein(DOCFILE),75)
      end
      call lineout DOCFILE
      MSG.THATNUM = ' '
      MSG.0 = THATNUM-1
      call vlistbox "View the ZIPENG.DOC file:", MSG, 90, 10, 1
      call vclosewindow WINDOW
   end
   else do
      MSG.0 = 3
      call linein TEXT
      do y = 1 to 3
         MSG.y = linein(TEXT)
      end
      call vmsgbox "Sorry!", MSG, 1
   end
return
Sure:
   if PAR2.q = '-c' then do
      ITEM = 'screen'
      THAT = '-p'
   end
   if PAR2.q = '-p' then do
      ITEM = 'printer'
      THAT = '-c'
   end
   MSG.0 = 8
   MSG.1 = "You can't extract to" ITEM "and to disk at the same time.  Plus,"
   MSG.2 = "if you're extracting any non-text files, your" ITEM "is going"
   MSG.3 = "to go nuts!  Furthermore, you can't use the" THAT", -$, -@, -d,"
   MSG.4 = "-J, -o, -f, or -n switches with the" PAR2.q "switch.  So....are"
   MSG.5 = "you sure you want to use the" PAR2.q "switch now?  (If you say"
   MSG.6 = "yes, we'll get rid of all those illegal switches for you.)  Do"
   MSG.7 = "you really want to extract to" ITEM "instead of to disk?  Click"
   MSG.8 = "on NO to drop the" PAR2.q "switch."
   BUTTON = vmsgbox("Really?", MSG, 6)
   if BUTTON = 'NO' then return ' /'OPTIONS
   COUNT = words(OPTIONS)
   do g = 1 to COUNT
      TRIAL = left(word(OPTIONS,g),2)
      select
         when (ITEM = 'printer')&(TRIAL = '-c') then do
            OPTIONS = delword(OPTIONS,g,1)
            g = g-1
         end
         when TRIAL = '-$' then do
            OPTIONS = delword(OPTIONS,g,1)
            g = g-1
         end
         when TRIAL = '-@' then do
            select
               when pos('"',word(OPTIONS,g))>0 then do
                  OPTIONS = delword(OPTIONS,g,1)
                  do while pos('"',word(OPTIONS,g)) = 0
                     OPTIONS = delword(OPTIONS,g,1)
                  end
                  OPTIONS = delword(OPTIONS,g,1)
               end
               when pos("'",word(OPTIONS,g))>0 then do
                  OPTIONS = delword(OPTIONS,g,1)
                  do while pos("'",word(OPTIONS,g)) = 0
                     OPTIONS = delword(OPTIONS,g,1)
                  end
                  OPTIONS = delword(OPTIONS,g,1)
               end
               otherwise OPTIONS = delword(OPTIONS,g,1)
            end
            g = g-1
         end
         when TRIAL = '-d' then do
            OPTIONS = delword(OPTIONS,g,1)
            g = g-1
         end
         when TRIAL = '-J' then do
            OPTIONS = delword(OPTIONS,g,1)
            g = g-1
         end
         when TRIAL = '-o' then do
            OPTIONS = delword(OPTIONS,g,1)
            g = g-1
         end
         when TRIAL = '-f' then do
            OPTIONS = delword(OPTIONS,g,1)
            g = g-1
         end
         when TRIAL = '-n' then do
            OPTIONS = delword(OPTIONS,g,1)
            g = g-1
         end
         otherwise nop
      end
   end
return PAR2.q'/'OPTIONS
End:
exit
