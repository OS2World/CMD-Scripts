/* Program Creator v1.22 */
/* Copyright (c) 1995, 1997 Anssi Blomqvist */

Call rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

text.1='                   Program Creator version 1.22'
text.2='                   ----------------------------'
text.3='(c) 1995, 1997 Anssi Blomqvist, abblomqv@rock.helsinki.fi'
text.4='Creating program object...'
text.5='Object was successfully created.'
text.6='Error creating program object!'
text.7="- Check that there aren't already an object with the same name on the desktop."
text.8='Usage:'
text.9='Drag and drop a program file on the Program Creator icon.'
text.10='From command line:'
text.11='CrProg filename (must be a valid file type)'
text.12='Invalid filename!'
text.13='Creating folder...'
text.14='Error creating folder!'
tfile='\PRCRTEMP'
type.1='EXE'
type.2='CMD'
type.3='COM'
type.4='BAT'
type.5='INF'    ; exec.5='VIEW.EXE'
type.6='TXT'    ; exec.6='E.EXE'
type.7='ME'     ; exec.7='E.EXE'
type.8='1ST'    ; exec.8='E.EXE'
type.9='NOW'    ; exec.9='E.EXE'
type.10='DOC'    ; exec.10='E.EXE'
type.11='SYS'    ; exec.11='E.EXE'
type.12='HTM'    ; exec.12='APPLET.EXE'
type.13='HTML'   ; exec.13='APPLET.EXE'
type.14='CLASS'  ; exec.14='JAVAPM.EXE'  ; extension.14='NO'
first=5
last=14

Say
Say text.1
Say text.2
Say
Say text.3
Say
Say

'@echo off'
n=setlocal()
parse arg Ar
If Ar = '' Then signal Usage
Ar=strip(Ar,,'"')
ndir=directory(Ar)
If filespec('name',ndir)=filespec('name',Ar) then call makefol
else do
   interactive='y'
   call makeprog Ar
end /* do */
if interactive<>'y' then do
   say
   say 'Completed succesfully!'
end  /* Do */
call ending

makefol:
   say text.13
   say
   fname=capitalize(filespec('name', Ar))
   objid='<PRCR_'||translate(fname)||'>'
   string='OBJECTID='||objid
   rc=SysCreateObject("WPFolder", fname, "<WP_DESKTOP>", string, "f")
   If rc <> 1 Then call failed
   Else do
      Say text.5
      rc=SysSetObjectData(objid, 'OPEN=DEFAULT')
      call makefile
   end
return

failed:
   Beep(440,400)
   Say text.14
   Say
   'Pause'
Exit

makefile:
   lastline=0
   'DIR /F *.EXE *.CMD *.INF *.TXT *.1ST *.DOC *.ME 1>'||tfile||' 2>nul'
   rc=stream(tfile,'C','OPEN')
   i=0
   eof=0
   do until eof
      l=linein(tfile)
      if l='' then eof=1
      else do
         i=i+1
         line.i=l
      end  /* Do */
   end /* do */
   rc=stream(tfile,'C','CLOSE')
   lastline=i
   if lastline>0 then do i=1 to lastline
      interactive='n'
      call makeprog line.i
   end /* do */
return

makeprog:
   parse arg Argu
   Pnam=filespec('name',Argu)
   pplace=lastpos('.',Pnam)
   Prog = Translate(Argu, ' ', '.')
   Wcount = Words(Prog)
   Ext = Translate(Word(Prog, Wcount))
   hit=0
   do n=1 to last until hit
      if ext=type.n then hit=1
   end
   If hit=0 Then signal Usage
   Pname = substr(Pnam,1,pplace-1)
   Progname=capitalize(Pname)
   drive = filespec('d',Argu)
   path = filespec('p',Argu)
   If path<>'' Then path = Substr(path,1,length(path)-1)
   cdir = Directory(drive||path)
   If cdir ='' then signal error
   If Substr(cdir,length(cdir)) <> '\' then cdir=Insert(cdir,'\')
   prog=cdir||pnam
   if n < first then do
     dstring='STARTUPDIR=' || cdir
     Program = 'EXENAME=' || Prog || ';' || dstring
   end /* do */
   else Program=progn(n)
   if interactive='y' then do
      Say text.4
      Say
   end
   if interactive='y' then loc='<WP_DESKTOP>'
   else loc=objid
   result=SysCreateObject("WPProgram", Progname, loc, Program, "f")
   If result = 1 Then Say text.5
   Else if interactive='y' then Do
      Beep(440,400)
      Say text.6
      Say
      Say text.7
      Say
      'pause'
   End
return

capitalize:
parse arg Pname
   Caps = (verify(Pname,Xrange('A','Z'))=0)
   Small = (verify(Pname,Xrange('a','z'))=0)
   If Caps | Small then Progname = Insert(Translate(Substr(Pname,1,1)),Translate(Substr(Pname,2),Xrange('a','z'),Xrange('A','Z')))
   Else Progname = Pname
return Progname


progn:
   parse arg lin
   pstring='EXENAME=' || exec.lin
   if extension.lin='NO' then par=pname
   else par=filespec('n',Argu)
   if words(par)>1 then par='"'||par||'"'
   vstring='PARAMETERS=' ||par 
   cdir=substr(cdir,1,length(cdir)-1)
   dstring='STARTUPDIR=' || cdir
   pstring=pstring || ';' || vstring || ';' || dstring
return pstring


Usage:
   Say text.8
   Say
   Say text.9
   Say
   say
   Say text.10
   Say
   say text.11
   say
   say
   'Pause'
Exit

Error:
   Beep(440,400)
   Say text.12
   '@pause'
Exit

Ending:
   'del '||tfile||' 2>nul'
exit 0
