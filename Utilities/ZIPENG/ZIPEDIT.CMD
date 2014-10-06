/* The Zip Engine -- A shareware graphical approach to file zipping/unzipping */
/* Copyright 1992-93 Kari Jackson and Bart Toulouse */
/* Edit-the-INI-File Subroutine */
arg TEXT
if (right(TEXT,4)<>'.TEX')|(length(TEXT)<13) then do
   say 'Sorry, this is not a standalone program.  It should be'
   say 'used only as a subroutine of the Zip Engine program.'
   signal End
end
CFG = stream('ZIPENG.INI', 'c', 'query exists')
if CFG<>'' then CFGFILE = CFG
else do
   CFG = syssearchpath('PATH','ZIPENG.INI')
   if CFG<>'' then CFGFILE = CFG
end
MSG.0 = 3
call linein TEXT,1
do 151
   call linein TEXT
end
do y = 1 to 3
   MSG.y = linein(TEXT)
end
if CFGFILE = 'CFGFILE' then do
   MSG.0 = 9
   MSG.4 = ' '
   do y = 5 to 8
      MSG.y = linein(TEXT)
   end
   MSG.9 = "directory right now is" directory()"."
   ZIPORG = '' ; UNZIPORG = '' ; TEMPORG = '' ; EXTRACTORG = '' ; EXTENORG = '' ; AOPORG = ''
   ENDORG = '' ; DEFORG = '' ; MENUORG = '' ; VERORG = '' ; UOPORG = '' ; ZOPORG = '' ; SWITCHORG = ''
   BGORG = '' ; FGORG = ''
end
call vmsgbox "Edit the .INI File:", MSG, 1
drop MSG. CFG
if CFGFILE = 'CFGFILE' then CFGFILE = directory()'\ZIPENG.INI'
else do
   ZIPORG = sysini(CFGFILE, 'zipeng', 'zipper')
   if ZIPORG = 'ERROR:' then ZIPORG = ''
   UNZIPORG = sysini(CFGFILE, 'zipeng', 'unzipper')
   if UNZIPORG = 'ERROR:' then UNZIPORG = ''
   TEMPORG = sysini(CFGFILE, 'zipeng', 'temporary directory')
   if TEMPORG = 'ERROR:' then TEMPORG = ''
   EXTRACTORG = sysini(CFGFILE, 'zipeng', 'extract directory')
   if EXTRACTORG = 'ERROR:' then EXTRACTORG = ''
   EXTENORG = sysini(CFGFILE, 'zipeng', 'extension')
   if EXTENORG = 'ERROR:' then EXTENORG = ''
   ENDORG = sysini(CFGFILE, 'zipeng', 'exit action')
   if ENDORG = 'ERROR:' then ENDORG = ''
   DEFORG = sysini(CFGFILE, 'zipeng', 'default directory')
   if DEFORG = 'ERROR:' then DEFORG = ''
   MENUORG = sysini(CFGFILE, 'zipeng', 'menu default')
   if MENUORG = 'ERROR:' then MENUORG = ''
   VERORG = sysini(CFGFILE, 'zipeng', 'version')
   if VERORG = 'ERROR:' then VERORG = ''
   ZOPORG = sysini(CFGFILE, 'zipeng', 'zip options')
   if ZOPORG = 'ERROR:' then ZOPORG = ''
   UOPORG = sysini(CFGFILE, 'zipeng', 'unzip options')
   if UOPORG = 'ERROR:' then UOPORG = ''
   AOPORG = sysini(CFGFILE, 'zipeng', 'global options')
   if AOPORG = 'ERROR:' then AOPORG = ''
   SWITCHORG = sysini(CFGFILE, 'zipeng', 'start switch')
   if SWITCHORG = 'ERROR:' then SWITCHORG = ''
   BGORG = sysini(CFGFILE, 'zipeng', 'background')
   if BGORG = 'ERROR:' then BGORG = ''
   FGORG = sysini(CFGFILE, 'zipeng', 'foreground')
   if FGORG = 'ERROR:' then FGORG = ''
end
ZIPLINE = '' ; UNZIPLINE = '' ; TEMPLINE = '' ; EXTRACTLINE = '' ; EXTENLINE = ''
ENDLINE = '' ; DEFLINE = '' ; MENULINE = '' ; VERLINE = '' ; BGLINE = ''
ZOPLINE = '' ; UOPLINE = '' ; AOPLINE = '' ; SWITCHLINE = '' ; FGLINE = ''
ZIPCH = 'N' ; UNZIPCH = 'N' ; TEMPCH = 'N' ; EXTRACTCH = 'N' ; EXTENCH = 'N'
ENDCH = 'N' ; DEFCH = 'N' ; MENUCH = 'N' ; VERCH = 'N' ; BGCH = 'N'
ZOPCH = 'N' ; UOPCH = 'N' ; AOPCH = 'N' ; SWITCHCH = 'N' ; FGCH = 'N'
drop INI.
l = 1
INI.0 = 7
INI.1 = "Specify your Zip and Unzip programs"
INI.2 = "Specify three directory locations"
INI.3 = "Specify Zip Engine's exit action"
INI.4 = "Specify the Zip and Unzip window action      "
INI.5 = "Specify your default Main Menu selection"
INI.6 = "Specify your default switch options"
INI.7 = "Specify Zip Engine window colors"
do while BUTTON<>'CANCEL'
   INI.VSTRING = INI.l
   BUTTON = vradiobox('CANCEL when done changing .INI file:', INI, 3)
   if BUTTON<>'CANCEL' then select
      when INI.VSTRING = INI.1 then do
         call EditVer
         call EditZip
         call EditUnzip
      end
      when INI.VSTRING = INI.2 then call EditDir
      when INI.VSTRING = INI.3 then call EditEnd
      when INI.VSTRING = INI.4 then call EditSwitch
      when INI.VSTRING = INI.5 then call EditMenu
      when INI.VSTRING = INI.6 then call EditOptions
      when INI.VSTRING = INI.7 then call EditColors
      otherwise nop
   end
end
KEEP = 0
if ((MENULINE = '')&(MENUCH = 'Y'))|((MENUORG = '')&(MENUCH = 'N')) then KEEP = KEEP+1
if ((ZIPLINE = '')&(ZIPCH = 'Y'))|((ZIPORG = '')&(ZIPCH = 'N')) then KEEP = KEEP+1
if ((UNZIPLINE = '')&(UNZIPCH = 'Y'))|((UNZIPORG = '')&(UNZIPCH = 'N')) then KEEP = KEEP+1
if ((TEMPLINE = '')&(TEMPCH = 'Y'))|((TEMPORG = '')&(TEMPCH = 'N')) then KEEP = KEEP+1
if ((DEFLINE = '')&(DEFCH = 'Y'))|((DEFORG = '')&(DEFCH = 'N')) then KEEP = KEEP+1
if ((EXTRACTLINE = '')&(EXTRACTCH = 'Y'))|((EXTRACTORG = '')&(EXTRACTCH = 'N')) then KEEP = KEEP+1
if ((EXTENLINE = '')&(EXTENCH = 'Y'))|((EXTENORG = '')&(EXTENCH = 'N')) then KEEP = KEEP+1
if ((VERLINE = '')&(VERCH = 'Y'))|((VERORG = '')&(VERCH = 'N')) then KEEP = KEEP+1
if ((ENDLINE = '')&(ENDCH = 'Y'))|((ENDORG = '')&(ENDCH = 'N')) then KEEP = KEEP+1
if ((ZOPLINE = '')&(ZOPCH = 'Y'))|((ZOPORG = '')&(ZOPCH = 'N')) then KEEP = KEEP+1
if ((UOPLINE = '')&(UOPCH = 'Y'))|((UOPORG = '')&(UOPCH = 'N')) then KEEP = KEEP+1
if ((AOPLINE = '')&(AOPCH = 'Y'))|((AOPORG = '')&(AOPCH = 'N')) then KEEP = KEEP+1
if ((SWITCHLINE = '')&(SWITCHCH = 'Y'))|((SWITCHORG = '')&(SWITCHCH = 'N')) then KEEP = KEEP+1
if ((BGLINE = '')&(BGCH = 'Y'))|((BGORG = '')&(BGCH = 'N')) then KEEP = KEEP+1
if ((FGLINE = '')&(FGCH = 'Y'))|((FGORG = '')&(FGCH = 'N')) then KEEP = KEEP+1
if KEEP = 15 then call sysfiledelete CFGFILE
else do
   if ZIPCH = 'Y' then call sysini CFGFILE, 'zipeng', 'zipper', ZIPLINE
   if UNZIPCH = 'Y' then call sysini CFGFILE, 'zipeng', 'unzipper', UNZIPLINE
   if TEMPCH = 'Y' then call sysini CFGFILE, 'zipeng', 'temporary directory', TEMPLINE
   if EXTRACTCH = 'Y' then call sysini CFGFILE, 'zipeng', 'extract directory', EXTRACTLINE
   if EXTENCH = 'Y' then call sysini CFGFILE, 'zipeng', 'extension', EXTENLINE
   if VERCH = 'Y' then call sysini CFGFILE, 'zipeng', 'version', VERLINE
   if ZOPCH = 'Y' then call sysini CFGFILE, 'zipeng', 'zip options', ZOPLINE
   if UOPCH = 'Y' then call sysini CFGFILE, 'zipeng', 'unzip options', UOPLINE
   if AOPCH = 'Y' then call sysini CFGFILE, 'zipeng', 'global options', AOPLINE
   if ENDCH = 'Y' then call sysini CFGFILE, 'zipeng', 'exit action', ENDLINE
   if DEFCH = 'Y' then call sysini CFGFILE, 'zipeng', 'default directory', DEFLINE
   if MENUCH = 'Y' then call sysini CFGFILE, 'zipeng', 'menu default', MENULINE
   if SWITCHCH = 'Y' then call sysini CFGFILE, 'zipeng', 'start switch', SWITCHLINE
   if BGCH = 'Y' then call sysini CFGFILE, 'zipeng', 'background', BGLINE
   if FGCH = 'Y' then call sysini CFGFILE, 'zipeng', 'foreground', FGLINE
end
return
EditEnd:
   call linein TEXT,1
   do 159
      call linein TEXT
   end
   POS.left = 4 ; POS.right = 96 ; POS.top = 40 ; POS.bottom = 10
   WINDOW = vopenwindow('Exit Line:', 'BLUE', POS)
   call vsetfont WINDOW, 'SYSTEM', 10
   call vforecolor WINDOW, 'WHITE'
   do q = 925 to 25 by -100
      call vsay WINDOW, 15, q, linein(TEXT)
   end
   MSG.0 = 2
   MSG.1 = '(nothing) Returns you to the main menu      '
   MSG.2 = '(EXIT)   Exits Zip Engine'
   if ENDORG<>'' then MSG.VSTRING = MSG.2
   else MSG.VSTRING = MSG.1
   if (ENDCH = 'Y')&(ENDLINE = 'EXIT') then MSG.VSTRING = MSG.2
   if (ENDCH = 'Y')&(ENDLINE = '') then MSG.VSTRING = MSG.1
   call vradiobox 'Exit Line:', MSG, 1
   if MSG.VSTRING = MSG.2 then ENDLINE = 'EXIT'
   else ENDLINE = ''
   if ENDLINE<>ENDORG then ENDCH = 'Y'
   l = 4
   call vclosewindow WINDOW
return
EditSwitch:
   call linein TEXT,1
   do 275
      call linein TEXT
   end
   POS.left = 4 ; POS.right = 96 ; POS.top = 40 ; POS.bottom = 10
   WINDOW = vopenwindow('Window Line:', 'BLUE', POS)
   call vsetfont WINDOW, 'SYSTEM', 10
   call vforecolor WINDOW, 'WHITE'
   do q = 925 to 25 by -90
      call vsay WINDOW, 15, q, linein(TEXT)
   end
   MSG.0 = 2
   MSG.1 = '(nothing) Close window automatically     '
   MSG.2 = '(K)       Leave window open'
   if SWITCHORG<>'' then MSG.VSTRING = MSG.2
   else MSG.VSTRING = MSG.1
   if (SWITCHCH = 'Y')&(SWITCHLINE = 'K') then MSG.VSTRING = MSG.2
   if (SWITCHCH = 'Y')&(SWITCHLINE = '') then MSG.VSTRING = MSG.1
   call vradiobox 'Window Line:', MSG, 1
   if MSG.VSTRING = MSG.2 then SWITCHLINE = 'K'
   else SWITCHLINE = ''
   if SWITCHLINE<>SWITCHORG then SWITCHCH = 'Y'
   l = 5
   call vclosewindow WINDOW
return
EditZip:
   drop MSG.
   MSG.0 = 8
   call linein TEXT,1
   do 170
      call linein TEXT
   end
   do y = 1 to 8
      MSG.y = linein(TEXT)
   end
   if ZIPORG<>'' then MSG.VSTRING = ZIPORG
   if ZIPCH = 'Y' then MSG.VSTRING = ZIPLINE
   call vinputbox 'Zipper Line:', MSG, 66, 1
   ZIPLINE = MSG.VSTRING
   l = 2
   if ZIPLINE<>'' then do
      TEST = stream(ZIPLINE, 'c', 'query exists')
      if TEST<>'' then do
         if ZIPLINE<>ZIPORG then ZIPCH = 'Y'
         return
      end
      MSG.0 = 1
      MSG.1 = "You have no such file.  Let's try again."
      call vmsgbox "Sorry!", MSG, 1
      call EditZip
   end
   if ZIPLINE<>ZIPORG then ZIPCH = 'Y'
return
EditUnzip:
   drop MSG.
   MSG.0 = 8
   call linein TEXT
   do y = 1 to 8
      MSG.y = linein(TEXT)
   end
   if UNZIPORG<>'' then MSG.VSTRING = UNZIPORG
   if UNZIPCH = 'Y' then MSG.VSTRING = UNZIPLINE
   call vinputbox 'Unzipper Line:', MSG, 66, 1
   UNZIPLINE = MSG.VSTRING
   if UNZIPLINE<>'' then do
      TEST = stream(UNZIPLINE, 'c', 'query exists')
      if TEST<>'' then do
         if UNZIPLINE<>UNZIPORG then UNZIPCH = 'Y'
         return
      end
      MSG.0 = 1
      MSG.1 = "You have no such file.  Let's try again."
      call vmsgbox "Sorry!", MSG, 1
      call EditUnzip
   end
   if UNZIPLINE<>UNZIPORG then UNZIPCH = 'Y'
return
EditVer:
   MSG.0 = 4
   MSG.1 = "DOS program compatible with PKZip 1.XX"
   MSG.2 = "OS/2 program compatible with PKZip 1.XX"
   MSG.3 = "DOS program compatible with PKZip 2.XX"
   MSG.4 = "OS/2 program compatible with PKZip 2.XX        "
   select
      when VERCH = 'N' & VERORG = '' then VDEF = 1
      when VERCH = 'N' then VDEF = 2
      when VERCH = 'Y' & VERLINE = '' then VDEF = 1
      when VERLINE = 2 then VDEF = 2
   end
   select
      when EXTENCH = 'N' & EXTENORG = '' then OSDEF = 'BAT'
      when EXTENCH = 'N' then OSDEF = 'CMD'
      when EXTENCH = 'Y' & EXTENLINE = '' then OSDEF = 'BAT'
      when EXTENCH = 'Y' then OSDEF = 'CMD'
   end
   select
      when VDEF = 1 & OSDEF = 'BAT' then MSG.VSTRING = MSG.1
      when VDEF = 1 & OSDEF = 'CMD' then MSG.VSTRING = MSG.2
      when VDEF = 2 & OSDEF = 'BAT' then MSG.VSTRING = MSG.3
      when VDEF = 2 & OSDEF = 'CMD' then MSG.VSTRING = MSG.4
   end
   drop VDEF OSDEF
   call vradiobox 'Your Zipper/Unzipper is:', MSG, 1
   select
      when MSG.VSTRING = MSG.1 then do ; VERLINE = '' ; EXTENLINE = '' ; end
      when MSG.VSTRING = MSG.2 then do ; VERLINE = '' ; EXTENLINE = 'CMD' ; end
      when MSG.VSTRING = MSG.3 then do ; VERLINE = 2 ; EXTENLINE = '' ; end
      when MSG.VSTRING = MSG.4 then do ; VERLINE = 2 ; EXTENLINE = 'CMD' ; end
   end
   if VERLINE<>VERORG then VERCH = 'Y'
   if EXTENLINE<>EXTENORG then EXTENCH = 'Y'
return
EditMenu:
   MSG.0 = 3
   MSG.1 = 'Unzip a file'
   MSG.2 = 'Create a new .ZIP file'
   MSG.3 = 'Modify an existing .ZIP file         '
   if MENUORG = SELPGM.3 then MSG.VSTRING = MSG.3
   if MENUORG = SELPGM.2 then MSG.VSTRING = MSG.2
   if MENUORG = '' then MSG.VSTRING = MSG.1
   if (MENUCH = 'Y')&(MENULINE = SELPGM.3) then MSG.VSTRING = MSG.3
   if (MENUCH = 'Y')&(MENULINE = SELPGM.2) then MSG.VSTRING = MSG.2
   if (MENUCH = 'Y')&(MENULINE = '') then MSG.VSTRING = MSG.1
   call vradiobox 'Choose default Main Menu selection:', MSG, 1
   if MSG.VSTRING = MSG.2 then MENULINE = SELPGM.2
   if MSG.VSTRING = MSG.3 then MENULINE = SELPGM.3
   if MSG.VSTRING = MSG.1 then MENULINE = ''
   if MENULINE<>MENUORG then MENUCH = 'Y'
   l = 6
return
EditOptions:
   call linein TEXT,1
   do 211
      call linein TEXT
   end
   POS.left = 3 ; POS.right = 97 ; POS.top = 92 ; POS.bottom = 6
   WINDOW = vopenwindow('Default options information:', 'BLUE', POS)
   call vsetfont WINDOW, 'SYSTEM', 10
   call vforecolor WINDOW, 'WHITE'
   do q = 934 to 10 by -33
      call vsay WINDOW, 15, q, linein(TEXT)
   end
   drop Z1. Z2.
   Z1.0 = 3
   Z1.1 = 'Zip Options line'
   Z1.2 = 'Unzip Options line'
   Z1.3 = 'Global Options line'
   Z2.0 = 3
   Z2.1 = ZOPORG
   if ZOPCH = 'Y' then Z2.1 = ZOPLINE
   Z2.2 = UOPORG
   if UOPCH = 'Y' then Z2.2 = UOPLINE
   Z2.3 = AOPORG
   if AOPCH = 'Y' then Z2.3 = AOPLINE
   call vdialogpos 50,70
   call vmultbox 'Options lines:', Z1, 40, 0, Z2, 1
   call vdialogpos 50,50
   ZOPLINE = Z2.1
   UOPLINE = Z2.2
   AOPLINE = Z2.3
   if ZOPLINE<>ZOPORG then ZOPCH = 'Y'
   if UOPLINE<>UOPORG then UOPCH = 'Y'
   if AOPLINE<>AOPORG then AOPCH = 'Y'
   l = 7
   call vclosewindow WINDOW
return
EditDir:
   drop BAD
   call linein TEXT,1
   do 188
      call linein TEXT
   end
   POS.left = 3 ; POS.right = 97 ; POS.top = 92 ; POS.bottom = 6
   WINDOW = vopenwindow('Directory Lines information:', 'BLUE', POS)
   call vsetfont WINDOW, 'SYSTEM', 10
   call vforecolor WINDOW, 'WHITE'
   do q = 934 to 10 by -44
      call vsay WINDOW, 15, q, linein(TEXT)
   end
   drop Z1. Z2.
   Z1.0 = 3
   Z1.1 = 'Temporary directory line'
   Z1.2 = 'Extract directory line'
   Z1.3 = 'Default directory line'
   Z2.0 = 3
   Z2.1 = TEMPORG
   if TEMPCH = 'Y' then Z2.1 = TEMPLINE
   Z2.2 = EXTRACTORG
   if EXTRACTCH = 'Y' then Z2.2 = EXTRACTLINE
   Z2.3 = DEFORG
   if DEFCH = 'Y' then Z2.3 = DEFLINE
   call vdialogpos 50,70
   call vmultbox 'Directory Lines:', Z1, 40, 0, Z2, 1
   call vdialogpos 50,50
   l = 3
   call vclosewindow WINDOW
   TEMPLINE = Validate(Z2.1)
   EXTRACTLINE = Validate(Z2.2)
   DEFLINE = Validate(Z2.3)
   if TEMPLINE<>TEMPORG then TEMPCH = 'Y'
   if EXTRACTLINE<>EXTRACTORG then EXTRACTCH = 'Y'
   if DEFLINE<>DEFORG then DEFCH = 'Y'
   if TEMPLINE = 'NO WAY' | TEMPLINE = '\' then do
      BAD = 'yes'
      TEMPLINE = ''
   end
   if EXTRACTLINE = 'NO WAY' | EXTRACTLINE = '\' then do
      BAD = 'yes'
      EXTRACTLINE = ''
   end
   if DEFLINE = 'NO WAY' | DEFLINE = '\' then do
      BAD = 'yes'
      DEFLINE = ''
   end
   if BAD = 'yes' then do
      call EditDir
      return
   end
return
EditColors:
   call linein TEXT,1
   do 287
      call linein TEXT
   end
   POS.left = 13 ; POS.right = 87 ; POS.top = 34 ; POS.bottom = 4
   WINDOW = vopenwindow('Window Colors:', 'BLUE', POS)
   call vsetfont WINDOW, 'SYSTEM', 10
   call vforecolor WINDOW, 'WHITE'
   do q = 900 to 100 by -100
      call vsay WINDOW, 20, q, linein(TEXT)
   end
   if BGORG<>'' then COLOR.back = BGORG
   else COLOR.back = 'BLUE'
   if BGCH = 'Y' & BGLINE = '' then COLOR.back = 'BLUE'
   else if BGCH = 'Y' then COLOR.back = BGLINE
   if FGORG<>'' then COLOR.fore = FGORG
   else COLOR.fore = 'WHITE'
   if FGCH = 'Y' & FGLINE = '' then COLOR.fore = 'WHITE'
   else if FGCH = 'Y' then COLOR.fore = FGLINE
   call vcolorbox COLOR
   if COLOR.back = 'BLUE' then BGLINE = ''
   else BGLINE = COLOR.back
   if COLOR.fore = 'WHITE' then FGLINE = ''
   else FGLINE = COLOR.fore
   if BGLINE<>BGORG then BGCH = 'Y'
   if FGLINE<>FGORG then FGCH = 'Y'
   l = 1
   call vclosewindow WINDOW
return
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
End:
exit
