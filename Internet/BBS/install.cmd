/* this is the BBS-addon for  SRE-http installation program */

/* Load up advanced REXX functions */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/*---- load the rexxlib library */
droprxlib=0 ; gotrxlib=1
foo=rxfuncquery('rexxlibregister')
if foo=1 then do
 droprxlib=1 ; gotrxlib=0
 call rxfuncadd 'rexxlibregister','rexxlib', 'rexxlibregister'
 call rexxlibregister
end
foo=rxfuncquery('rexxlibregister')
if foo=1 then do
    say " Could not find the REXXLIB procedure library (REXXLIB.DLL). "
    say "  Did you download it? "
    exit
end  /* Do */

crlf='0d0a'x

ansion=checkansi()
if ansion=1 then do
  aesc='1B'x
  cy_ye=aesc||'[37;46;m'
  normal=aesc||'[0;m'
  bold=aesc||'[1;m'
  re_wh=aesc||'[31;47;m'
  reverse=aesc||'[7;m'
end
else do
  say " Warning: Could not detect ANSI....  Install will look ugly ! "
  parse pull .
  cy_ye="" ; normal="" ; bold="" ;re_wh="" ;
  reverse=""
end  /* Do */

cls
say  " " ; say

call lineout, bold cy_ye
call lineout, "This is the BBS addon for SRE-http  installation program (11/97).     "
call lineout, normal

say " This program will ask for the names of a few directories,"
say " and will copy a number of files to these directories."
say "  "

if yesno(" Are you ready to continue ")=1 then
 nop
else do
 say " See you later?.. "
 exit
end


nowdir=directory()
deffil=filespec('d',nowdir)||'\BBSFILES'

godir=filespec('d',deffil)||'\GOSERVE'
webdir=filespec('d',deffil)||'\WWW'
addondir=godir||'\ADDON'


gunky1:
say " "
call charout,  bold " Enter the  root of your BBS-Files directory " normal crlf
call charout,"  ENTER= " deffil  " ? "
parse pull afile_dir
if afile_dir="" then afile_Dir=deffil
afile_dir=strip(afile_dir,'t','\')
foo=dosisdir(afile_dir)
if foo=0 then do
    say " Could not find directory: " afile_dir
    signal gunky1
end

gunky2:
say " "
call charout,  bold " Enter the GoServe working directory (that contains SREFILTR.80)" normal crlf
call charout,"  ENTER= " godir  " ? "
parse pull work_dir
if work_dir="" then work_Dir=godir
work_dir=strip(work_dir,'t','\')
foo=dosisdir(work_dir)
if foo=0 then do
    say " Could not find directory: " work_dir
    signal gunky2
end
foo=work_dir||'\SREFILTR.80'
if stream(foo,'c','query exists')=' ' then do
   say " Could not find SREFILTR.80.  Please reenter "
   signal gunky2
end  /* Do */

gunky2a:
say " "
call charout,  bold " Enter the SRE-http " normal reverse " addon " normal bold " directory " normal crlf
call charout,"  ENTER= " addondir  " ? "
parse pull addon_dir
if addon_dir="" then addon_Dir=addondir
addon_dir=strip(addon_dir,'t','\')
foo=dosisdir(addon_dir)
if foo=0 then do
    say " Could not find directory: " addon_dir
    signal gunky2a
end



gunky3:
say " "
call charout,  bold " Enter the  GoServe data directory (that contains your home page)" normal crlf
call charout,"  ENTER= " webdir  " ? "
parse pull web_dir
if web_dir="" then web_Dir=webdir
web_dir=strip(web_dir,'t','\')
foo=dosisdir(web_dir)
if foo=0 then do
    say " Could not find directory: " web_dir
    signal gunky3
end

gunky4:
say " "
/* check /imgs */
imgdir=web_dir||'\IMGS'
foo=dosisdir(imgdir)
if foo=0 then do
   say " Could not find " imgdir
   call charout,  bold " Enter the  SRE-http /IMGS directory" normal crlf
   call charout,"   ? "
   parse pull imgdir
   imgdir=strip(imgdir,'t','\')
   foo=dosisdir(imgdir)
   if foo=0 then do
    say " Could not find directory: " imgdir
    signal gunky4
  end
  say "Note: you will have to set IMAGEPATH='"|| imgdir ||"'(in BBS.INI) "
end


bbdir=work_dir||'\bbsdata'

say " --------------- "
say " This installation program will install files to " bbdir
say " and to several subdirectories under BBSDATA\.  You can change this by "
say " editing BBS.INI (but I'm  not sure why you'ld want to). "
say " It will also copy a few .HTM (HTML) files to " web_dir
say " "

if yesno(" Are you ready to copy the files ")=0 then do
   say " Okay, you can try again later "
   exit
end  /* Do */
    
say "Modifying the BBS.INI file "
goo=charin("BBS.INI",1,chars('bbs.ini'))
aa=stream("BBS.INI",'c','close')

todo="file_dir='"||afile_dir||"' "
agoo=pos("file_dir='\BBSFILES'",goo)

goo=replacestrg(goo,"file_dir='\BBSFILES'",todo,'ALL')

lm="LAST_MODIFIED='"||time('n')' 'date('n')"'"
goo=replacestrg(goo,"LAST_MODIFIED=' '",lm)

say " Copying BBS.INI"
t=stream(work_dir||'\BBS.INI','c','query exists')
bbsinifile=t
if t<>" " then do
SAY  REVERSE " -------------------- " NORMAL
 Say " A copy of BBS.INI exists in " work_dir
say " "
say bold "Note to upgraders:" normal " If you are upgrading BBS, we recommend "
say      "                      that you do" bold "not" normal " overwrite BBS.INI. "
say " "
 oo=yesno(" Are you sure you want to overwrite this BBS parameters file ?")
 if oo=1 then do
      arf=dostempname(work_dir||"\BBSINI.???")
      foo=dosrename(t,arf)
      if foo=0 then do
          say " Error renaming " t " to " arf
          exit
      end  /* Do */
      else do
           say " Old copy of BBS.INI moved to " arf
      end  /* Do */
      foo=charout(t,goo,1)
      if foo>0 then do
          say " error writing BBS.INI " foo
          exit
      end  /* Do */
   end  /* Do */
   else do
      say " Old BBS.INI is retained "
   end
SAY  REVERSE " -------------------- " NORMAL

end
else do
      foo=charout(work_dir||'\BBS.INI',goo,1)
      bbsinifile=work_dir'\bbs.ini'
end
say " "
say " Copying  BBS.CMD and other stuff to " work_dir ' & ' addon_dir
foo=check_copy('BBS.CMD',addon_dir,' Are you sure (this is the main BBS program file)')
foo=check_copy('BBSCACHE.CMD',work_dir,,1)
foo=check_copy('BBSCONFG.CMD',addon_dir,,1)
foo=check_copy('BBSRECNT.CMD',work_dir,' Are you sure (this is the BBS  recent file lister)',1)
foo=check_copy('BBSUP.CMD',addon_dir,,1)
foo=check_copy('BBSNEWU.CMD',addon_dir,,1)

foo=check_copy('BBSHELLO.HTM',web_dir,' Are you sure (this is the BBS "welcome" screen)')
foo=check_copy('BBSLOGON.HTM',web_dir,'Are you sure (this is the BBS "prompt for username/password screen)')
foo=check_copy('BBSUP.HTM',web_dir,'Are you sure (this is the BBS "upload instructions" screen)')
foo=check_copy('BBSNEWU.HTM',web_dir,'Are you sure (this is the BBS "new user registration" screen)')
foo=check_copy('BBSPLAY.HTM',web_dir,' Are you sure (this is the BBS "play with options" front-end)')
foo=check_copy('BBS1A.HTM',web_dir,' Are you sure (this is the first part of the "alternative BBS welcome" screen)')
foo=check_copy('BBS1B.HTM',web_dir,' Are you sure (this is the last  part of the "alternative BBS welcome" screen)')


say " " ; say " Copy BBS manual (BBS.DOC) to " web_dir
foo=check_copy('BBS.DOC',web_dir,,1)

foo=check_copy('*.gif',imgdir,,1)

/* create bbsdata directories */
isnew=directory(bbdir)
if isnew="" then do
   say " Creating: " bbdir
   oo=sysmkdir(bbdir)
  if oo=0  then do
          say "      Directory created: " bbdir
  end
  else do
           say "      Could not create " bbdir "(error = " oo
           exit
  end
end
foo=directory(nowdir)
say " "
say " copying generic header, footer, etc. files "
foo=check_copy('BBS.HDR',bbdir,' Are you sure (this is the generic header)')
foo=check_copy('BBS.FTR',bbdir,' Are you sure (this is the generic footer)')
foo=check_copy('BBSZIP.HDR',bbdir,' Are you sure (this is the generic  .ZIP header)')
foo=check_copy('BBS.CTL',bbdir,' Are you sure (this is the access control file)')
foo=check_copy('BBS.EXC',bbdir,' Are you sure (this is the generic exclusion file)')
foo=check_copy('BBS.DSC',bbdir,' Are you sure (this is the generic file-descriptions file)')
foo=check_copy('FILES.BBS',bbdir,' Are you sure (this is the sample inclusion mode file)')



/* create bbsdata directories */
udir=bbdir"\USERLOG"
isnew=directory(udir)
if isnew="" then do
   say " Creating: " udir
   oo=sysmkdir(udir)
  if oo=0  then
          say "      Directory created: " udir
  else do
           say "      Could not create " udir "(error = " oo
           exit
  end
end

say " Copying bbsstat.cmd to  " udir
foo=check_copy('BBSSTAT.CMD',strip(udir,'t','\')'\',,1)

say " .......... "
/* create bbsdata directories */
udir=bbdir"\UPLOAD"
isnew=directory(udir)
if isnew="" then do
   say " Creating: " udir
   oo=sysmkdir(udir)
  if oo=0  then
          say "      Directory created: " udir
  else do
           say "      Could not create " udir "(error = " oo
           exit
  end
end


/* create bbsdata directories */
udir=bbdir"\CACHE"
isnew=directory(udir)
if isnew="" then do
   say " Creating: " udir
   oo=sysmkdir(udir)
  if oo=0  then
          say "      Directory created: " udir
  else do
           say "      Could not create " udir "(error = " oo
           exit
  end
end

foo=directory(nowdir)

say reverse " ------------------------------------------------- "normal
say bold " The BBS files and directories have been created. " normal
say" "
say bold "*" normal " You should now edit " bbsinifile
say      "    -- or read the documentation file (" web_dir||"\BBS.DOC) "
say      "    -- or run the BBS Configurator (/BBSCONFG?) "

say " "
say bold "*" normal " The following lines "bold"must"normal" be in your ALIASES.IN file:"
say "         bbs/download/*  bbs?download=* "
say "         bbs/zipdownload/*  bbs?zipdownload=* "
say "     (if they aren't in ALIASES.IN,, you" bold "must"normal" add them) "
say "     (ALIASES.IN is in your SRE-http WORKDATA_DIR; i.e.  D:\GOSERVE\DATA)"








exit

/* ------------------------------------------------------------------ */
 /* function: Check if ANSI is activated                               */
 /*                                                                    */
 /* call:     CheckAnsi                                                */
 /*                                                                    */
 /* where:    -                                                        */
 /*                                                                    */
 /* returns:  1 - ANSI support detected                                */
 /*           0 - no ANSI support available                            */
 /*          -1 - error detecting ansi                                 */
 /*                                                                    */
 /* note:     Tested with the German and the US version of OS/2 3.0    */
 /*                                                                    */
 /*                                                                    */
 CheckAnsi: PROCEDURE
   thisRC = -1
 
   trace off
                         /* install a local error handler              */
   SIGNAL ON ERROR Name InitAnsiEnd
 
   "@ANSI 2>NUL | rxqueue 2>NUL"
 
   thisRC = 0
 
   do while queued() <> 0
     queueLine = lineIN( "QUEUE:" )
     if pos( " on.", queueLine ) <> 0 | ,                       /* USA */
        pos( " (ON).", queueLine ) <> 0 then                    /* GER */
       thisRC = 1
   end /* do while queued() <> 0 */
 
 InitAnsiEnd:
 signal off error
 RETURN thisRC


/* -------------------- */
/* get a yes or no , return 1 if yes */
yesno:procedure expose normal reverse bold
parse arg fooa , allopt,altans
if altans<>" " & words(altans)>1 then do
   w1=strip(word(altans,1))
   w2=strip(word(altans,2))
   a1=left(w1,1) ; a2=left(w2,1)
   a1a=substr(w1,2) ; a2a=substr(w2,2)
end
else do
    a1='Y' ; a1a='es'
    a2='N' ; a2a='o'
end  /* Do */
ayn='  '||bold||a1||normal||a1a||'\'||bold||a2||normal||a2a
if allopt=1 then  ayn=ayn||'\'||bold||'A'||normal||'ll'

do forever
 foo1=normal||reverse||fooa||normal||ayn
 call charout,  foo1 normal ':'
 pull anans
 if abbrev(anans,a1)=1 then return 1
 if abbrev(anans,a2)=1 then return 0
 if allopt=1 & abbrev(anans,'A')=1 then return 2
end


/* ------------- */
/* ----------------------------------------------------------------------- */
/* REPLACESTRG: In string astring, find first occurence substring target and
.   replace it with substring putme
.      if no target, return unchanged astring
.      if no putme, then remove target
.      if type=backward, then find/change LAST occurence
.      if type=all, find/change all occurences
.      if exactmatch=yes, then do not capitalize during search (exact match only */
/* ----------------------------------------------------------------------- */

replacestrg: procedure

exactmatch=0
backward=0 ; doall=0

parse arg astring ,  target   , putme , type , exactmatch

type = translate(type)
if type="BACKWARD" then backward="YES"
if type="ALL" then doall="YES"

iat=1
joelen=length(target)
joelen2=length(putme)

doagain:                /* here if doall=yes */
 if exactmatch="YES" then do
    if   backward="YES" then
        joe= lastpos(target,astring)
    else
        joe= pos(target,astring,iat)
 end
 else do
   if   backward="YES" then
        joe= lastpos(translate(target),translate(astring))
    else
        joe= pos(translate(target),translate(astring),iat)
 end
 if joe=0 then
         return astring

 astring=delstr(astring,joe,joelen)
 if putme<>' ' then
    astring=insert(putme,astring,joe-1)

 if doall="YES" then do
     iat=joe+joelen2
     signal doagain
 end
/* else, all done */
 return astring

/*******************************************/
/* check for existence of file, then ask user to copy or not */
/* note that for X.* type copies, it only checks once
   (not for each file, but just for any one of them */
/********************************************/
check_copy: procedure expose copyall reverse bold normal
parse arg file1, dest1 , amess , noask

dest2=strip(dest1,'t','\')||'\'

filename=dest2||file1


if copyall=1 then signal doit3


aa=sysfiletree(filename,isit,'F')

ok=1
if aa<>0 then do
   say " Warning: error when looking for pre-existing copy of: " filename
   ok=yesno(" Do you want to copy this file (or files) anyways? ")
   if ok=1 & amess<>""  then
      ok=yesno(amess)
end

if noask=1 then signal doit3

if isit.0>0 then do
  if pos('*',file1)=0 then do
      say " "
      say " A file exists with the name: " filename
      ok=yesno(" Do you want to overwrite this file? ",1)
      if ok=1 & amess<>""  then
           ok=yesno(amess)
  end
  else do
    say " "
      say " There is at least one file that matches: " filename
      say "  (this match may " bold " not " normal " be one of the files that will be copied!) "
      ok=yesno(" Do you want to copy these files? ",1)
      if ok=1 & amess<>""  then
           ok=yesno(amess)
  end  /* Do */

end

if ok=2 then do
  say " "
  say "SRE-http will overwrite all files (not just these) "
  copyall=yesno(" Are you sure you want to do this?")
  if copyall=0 then
      ok=yesno(" Do you want to overwrite the current file (or files)? ")
end

if ok=0  then return 0

doit3:          /* jump here if copyall is on, or noask=1 */
'@COPY ' file1 dest1 ' > NUL '

return 1




