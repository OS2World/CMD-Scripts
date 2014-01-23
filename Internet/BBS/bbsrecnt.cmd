/* Create an "index list" of files recently added to the bbs files area
(during the last n days).  This index will contain the "url" to
the file, the size and date, an optional description, and the required privileges.
BBS can read, and display, these "index lists".

The following information is saved to the "stem" file (i.e. BBSRECNT.IDX):
          .0 = # entries (N)
          .!hdrfile = Optional header file
          .!header = Generic header, used if hdrfile not specified
          .!ftrfile = Optional footer file
          .!title = Optional title
          .!filedir = Root directory
          .!days = oldest file parameter
          .n = file name (relative to .!filedir).
               Or, if =' ', then "it's a comment".
          .n.!Ndate =normal date
          .n.!time = 24hr time
          .n.!size = size in bytes
          .n.!jdate = julian date
          .n.!privs= privileges required (* means "open access")
          .n.!desc = description
If you are ambitious, you can write your own routines. As long as they
generate the above information, everything else is up to you. Note
that you'll need to use the CVWRITE function to write the "stem" file.



                 **** IMPORTANT INSTALLATION NOTE ***

   A BBS.INI file MUST exist in the same directory BBS.CMD is installed to. 


 */

/*A few User changeable non bbs.ini  parameters ... */

imagesize="width=24 height=24"   /* size of icons */


verbose=1                       /* verbose=1  for verbose reporting */


/*--------------   Load REXX libraries ----- */
/* Load up advanced REXX functions */
foo=rxfuncquery('sysloadfuncs')
if foo=1 then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
end
foo=rxfuncquery('rexxlibregister')
if foo=1 then do
 call rxfuncadd 'rexxlibregister','rexxlib', 'rexxlibregister'
 call rexxlibregister
end


/* some color stuff */
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
  cy_ye="" ; normal="" ; bold="" ;re_wh="" ; 
  reverse=""
end  /* Do */

/* current directory is base directory */
basedir=directory()
basedir=strip(basedir,'t','\')||'\'

crlf='0d0a'x


call load_rxl

inifile=basedir||'bbs.ini'
isit=fileread(inifile,inilines,,'E')
if isit<0 then do
     say " ERROR: no BBS initialization file:" inifile
     exit
end  /* Do */

signal on syntax name bad1
signal on error name bad1
mm=0

gobot:
mm=mm+1
if mm > inilines.0 then signal good1
aline=inilines.mm
interpret aline
signal gobot

bad1:
signal off error ; signal off syntax ;
say " ERROR: error in BBS initialization file: " aline
exit

/* ------  bbs_ini okay, or skipped.  Check, various values, directories */
/* this is a shortened version of what's in bbs.cmd */
good1:

signal off error ; signal off syntax ;
bbs_param=translate(bbs_param_dir,'\','/')
if abbrev(strip(bbs_param,'l','\'),'\') =0 & pos(':',bbs_param)=0 then /* must be relative dir*/
   bbsdir=basedir||bbs_param||'\'
else
   bbsdir=strip(bbs_param,'t','\')'\'

if dosisdir(strip(bbsdir,'t','\'))=0 then do
     say " ERROR: no BBS parameters directory:" bbsdir
    exit
end

file_dir=strip(file_dir,'t','\')||'\'

ctlfile=stream(bbsdir||'BBS.CTL','c','query exists') /* blank means none */
inctl=0
if ctlfile<>' ' then inctl=get_ctlfile(ctlfile,verbose) /*returns ctls. global */

/* a time  date stamp */
 d1=date('b')
 t1=time('m')/(24*60)
 nowtime=d1+t1

if symbol('USE_SERVERNAME')<>'VAR' then do
   servername=get_hostname()
end
else do
  if  use_servername="" | use_servername=0 then 
      servername=get_hostname()
  else
     servername=use_servername
end

say " "

/* ------- End of parameter initializations ------------ */



say "          " cy_ye " This is the BBS recent-files-index creator." normal
say  " The recent-files-index is used to generate a list of recent uploads "
say " "
say " Note-- base directory is: "  bold basedir normal
say "        parameters directory is: " bold bbsdir normal
say "        access control file is: " bold ctlfile normal "(" inctl " entries )"
SAY "        using servername: " bold  servername normal

gunky1:
say " "
call charout,  bold " Enter the directory  to find new files in (and under) " normal crlf
call charout,"  ENTER= " file_dir  " ? "
parse pull afile_dir
if afile_dir="" then afile_dir=file_dir
foo=dosisdir(strip(afile_dir,'t','\'))
if foo=0 then do
    say " Could not find directory: " afile_dir
    signal gunky1
end
idxlist.!filedir=afile_dir
say " "

boof:
say " "
call charout, reverse " Enter time span  (in days) of files to add to the index " normal crlf
call charout,          '     (files older then this will not be included): '
parse pull daysback
if datatype(daysback)<>'NUM' | daysback="" then  signal boof
idxlist.!days=daysback

getidx:
say " "
call charout, reverse " Enter name to use for the recent-files index " normal crlf
call charout,          '  ENTER = BBSRECNT.IDX ? '
parse pull idxfile
if idxfile="" then idxfile="BBSRECNT.IDX"
foos=stream(idxfile,'c','query exists')
if foos<>' ' then
   if yesno('     ' idxfile' exists. Overwrite? ')= 0 then signal getidx


say " "
sortbydate=yesno(" Sort by date (with most recent first)")
dir_seps=0
if sortbydate=0 then do
   dir_seps=yesno("       ... include directory labels in the listing")
end
say " "

gethdr:
foos="";aheader=""
say " "
call charout, reverse " Enter name of a header file (default is a generic header) " normal crlf
call charout,          ' ? '
parse pull  hdrfile
if hdrfile<>" " then do
   foos=stream(hdrfile,'c','query exists')
   if foos=' ' then do
      say " File does not exist " hdrfile ". Please re-enter "
      signal gethdr
  end  /* Do */
end
else do
   say "You can modify the " reverse " generic " normal " header."
   say "The header is currently (note the use of HTML elements): "
   eek.1=' <body> <h2> Recent Files from: ' afile_dir '</h2>'
   d2=date('n')
   d1=date('b'); d1=d1-daysback ; d1=dateconv(d1,'b','n')
   eek.2= "<em> Includes files created from " d1 "to" d2  " </em><br>"
   say cy_ye "--> " normal eek.1
   say cy_ye "--> " normal eek.2
   say " You can modify or add to this header. Just hit " bold " ESC " normal " when done"
   say  bold "   ... and be sure to start with a <BODY  > element! " normal
   ili=0
   do forever
    ili=ili+1
    cdo=' '
    if ili<3 then cdo=eek.ili
    call charout, cy_ye"  " normal
    eek.ili=stringin(,6,cdo,74)
    say " "
    if eek.ili="" then leave
   end /* do */
   do mm=1 to ili
      aheader=aheader||eek.mm||crlf
   end /* do */
end  /* Do */
idxlist.!hdrfile=foos
idxlist.!header=aheader
say " "

getftr:
foos=""
say " "
call charout, reverse " Enter name of a footer file (default is no footer) " normal crlf
call charout,          ' ? '
parse pull  ftrfile
if ftrfile<>" " then do
   foos=stream(ftrfile,'c','query exists')
   if foos=' ' then do
     say " File does not exist " ftrfile ". Please re-enter "
     signal getftr
   end  /* Do */
end
idxlist.!ftrfile=foos
say " "

say " "
call charout, reverse " Enter a title (it will be used in the <TITLE> ):  " normal crlf
atitle="BBS: Latest files "
call charout, cy_ye"  " normal
atitle=stringin(,6,atitle,74)
idxlist.!title=atitle
say " "

say " "

foo=sysfiletree(afile_dir'*.*',gots,'FST')
exlist=" " ; was_dir=" "
isin=0 ; nexcluded=0
notesgen.!did=0

snobal=0
kfiles=0
do mm=1 to gots.0
   snobal=snobal+1
   if (snobal)//101=100 then say " reading line " mm
   parse var gots.mm tim siz . nam
   parse var tim yr '/' mo '/' da '/' hr '/' min .
   jdate=dateconv(yr'/'mo'/'da,'O','B')
   if jdate+daysback < nowtime then iterate

/* if new directory, then get exclusion_file list and get description file */
   gets=strip(filespec('d',nam)||filespec('p',nam),'t','\')
   if was_dir <> gets then do
        say " Examining files in: " gets
        reldir='/'||translate(substr(gets,length(afile_dir)+2),'/','\')
        was_dir=gets
        exlist=get_exclusion(gets,verbose)
        exlist=translate(exlist,'\','/')
        oo=make_dsc_descriptions(gets,verbose)
        if dir_seps=1 then do
             isin=isin+1; 
             idxlist.isin=' ';idxlist.isin.!desc='<u>'reldir'</u>'
             idxlist.isin.!jdate=18888888
        end  /* Do */
        snobal=1
   end

    nam0=filespec('n',nam)
/* if matches exlist, then skip */
    if is_excluded(nam0,exlist) then do
      nexcluded=nexcluded+1
      if verbose>0 then say "    :: Excluding: " nam0
      iterate
    end
   isin=isin+1 ; kfiles=kfiles+1
   idxlist.isin=translate(substr(nam,length(afile_dir)+2),'/','\')
   idxlist.isin.!privs=fig_access(idxlist.isin)
   idxlist.isin.!jdate=jdate
   idxlist.isin.!size=siz
   idxlist.isin.!ndate=dateconv(yr'/'mo'/'da,'O','N')
   idxlist.isin.!time=hr':'min
   idxlist.isin.!desc=find_description(nam0)
/* information saved: .n = file name (relative to afile_dir
                      .n.!Ndate =normal date
                      .n.!time = 24hr time
                      .n.!size = size in bytes
                      .n.!jdate = julian date
                      .n.!privs= privileges required
*/
end /* do */
idxlist.0=isin

say " # excluded files= " nexcluded
say " # retained files = " kfiles
say " # entries (including comments)= " isin
/* now sort it ?*/
if sortbydate=1 then do  /* by date */
   booger.0=isin
   do jj=1 to isin
        booger.jj=left(idxlist.jj.!jdate,30) ','  idxlist.jj ',' ,
                      idxlist.jj.!ndate  ',' idxlist.jj.!time  ',' ,
                      idxlist.jj.!size  ',' idxlist.jj.!privs
   end
   foo=arraysort(booger,1,,1,30,'D','N')
   do jj=1 to isin
        parse var booger.jj idxlist.jj.!jdate ',' idxlist.jj ',' ,
                      idxlist.jj.!ndate  ',' idxlist.jj.!time  ',' ,
                      idxlist.jj.!size  ',' idxlist.jj.!privs
        idxlist.jj=strip(idxlist.jj) 
        idxlist.jj.!jdate=strip(idxlist.jj.!jdate)
        idxlist.jj.!ndate=strip(idxlist.jj.!ndate)
        idxlist.jj.!time=strip(idxlist.jj.!time)
        idxlist.jj.!privs=strip(idxlist.jj.!privs)
        idxlist.jj.!size=strip(idxlist.jj.!size)
   end /* do */
end  /* Do */

say " Number of entries saved to " idxfile " =  " isin
foo=cvwrite(idxfile,idxlist)
if aa=0 then say " Error: could not write " idxfile

exit

/*********************************************************/
/* Load srefilter macro libary, if not already loaded */
load_rxl:procedure expose basedir

if macroquery('SREF_VERSION')<>"" then return 1

tt=strip(basedir,'t','\')||'\SREFPRC1.RXL'
aa=macroload(tt)
 if aa=0 then do
    say " ERROR: Could not load macrospace library: " tt
   exit
end

RETURN 1



/***********************/
/* get the hostname (aa.bb.cc) for this machine */
get_hostname: procedure
    do queued(); pull .; end                   /* flush */
    address cmd '@hostname'  '| rxqueue'    
    parse pull hostname                        
    return hostname


  
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




/* ----------------------------------- */
/* match a file with the control access files (ctls.), and extract neededp privs
 If no match, return emtpy string */
fig_access:procedure expose ctls.

parse upper arg theurl0
 nnn=lastpos('/',theurl0)
 if nnn=0 then
    theurl='/'
 else
     theurl=left(theurl0,nnn)
 gotit=0
 starat=0 ;  afterstar=0 ;useprivs=' '
 do mm=1 to ctls.0
    aurl=ctls.mm
    ares=sref_wildcard(theurl,aurl||' '||aurl,0)
    parse var ares astat "," aurl2 ;  astat=strip(astat)
    if astat=0 then iterate   /* no match */
    if astat=1 then do
        gotit=mm
        leave
    end
    else  do
       t1=pos('*',aurl)
       t33=length(aurl)-t1
       if t1 >= starat  then do
          if t1 > starat | t33>afterstar then do
             starat=t1 ; afterstar=t33
             gotit=mm 
          end
       end
    end
 end
 if gotit>0  then useprivs=ctls.gotit.!Privs
 return useprivs


/***********************************************************/
/* check for, and read, the access control file */
get_ctlfile:procedure expose ctls.
parse arg ctlfile,verbose

aa=fileread(ctlfile,tmps,,'E')
if aa=0 then return 0

/*if verbose>0 then say "  .... using control file: " ctlfile*/

inctl=0
do mm=1 to tmps.0
    aline=strip(tmps.mm)
    if aline='' | abbrev(aline,';')=1  then iterate
    parse upper var aline aurl aprivs ',' .
    aurl=translate(aurl,'/','\')
    aurl=strip(aurl,,'/')
    if pos('*',aurl)=0 then aurl=aurl||'/'
    inctl=inctl+1
    ctls.inctl=strip(aurl)
    ctls.inctl.!privs=aprivs
end /* do */
ctls.0=inctl
return inctl



/***************/
@ get list of exclusions. Use own directory version if available,
or bbs_param_dir if not (they are NOT cumulative)*/
get_exclusion:procedure expose bbsdir exclusion_file
parse arg gets,verbose
arf=strip(gets||'\'||exclusion_file)
t1=stream(arf,'c','query exists')
if t1=' ' then
    t1=stream(bbsdir||exclusion_file,'c','query exists')

if t1=' ' then
   return ' '
oo=linein(t1,1,0)
exlist=""
if verbose=1 then say "    ... Using exclusion list: " t1
/* else, read the list */
do while lines(t1)=1
   oo=strip(linein(t1))
   if abbrev(oo,';')=1 then iterate
   exlist=exlist||' '||oo
end /* do */
tt=translate(exlist,' ',','||'1a090a0d'x)
return tt



/*****************************//
/* get file descriptions from .dsc files (does NOT do auto descriptions) */
make_dsc_descriptions:procedure expose continuation_flag default_description ,
         NOTES. bbsdir description_file arglist. notesgen. wildnotes.
parse arg gets,verbose
notes1.0=0
notes.0=0
if description_file<>' ' then do
  yuba=strip(gets||'\'||description_file)
  t1=stream(yuba,'c','query exists')
  if t1<>' ' then do
     if verbose>0  then say  "    ... using description file: " t1
     eek=fileread(t1,'notes',,'E')
     ekk=fix_notes(continuation_flag)
  end
end

/* copy to a temporary array, and do it again below */
do arf=1 to notes.0
   notes1.arf.dastuff=notes.arf.dastuff
   notes1.arf.daname=translate(notes.arf.daname,'/','\')
end /* do */
notes1.0=notes.0

notes.0=0               /* get next set */


/* get a generic description file? */
if notesgen.!did=0 & description_file<>' ' then do
  yipper=strip(bbsdir||description_File)
  if verbose=1 then say " Storing generic descriptions: " yipper
  t1=stream(yipper,'c','query exists')
  if t1<>' ' then do
     eek=fileread(t1,'notes',,'E')
     ekk=fix_notes(continuation_flag)
  end
  do jk=1 to notes.0
     notesgen.jk.daname=notes.jk.daname
     notesgen.jk.dastuff=translate(notes.jk.dastuff,'/','\')
  end /* do */
  notesgen.0=notes.0
  notesgen.!did=1
  if verbose>0 then say "  .... # of generic descriptions= " notesgen.0
end
/* add this set to notes1 */
if notesgen.0>0 then do
  obie=notes1.0
  do mm=1 to notesGEN.0
    obie2=obie+mm
    notes1.obie2.daname=translate(notesgen.mm.daname,'/','\')
    notes1.obie2.dastuff=notesgen.mm.dastuff
  end
  notes1.0=obie2
end
drop notes.     /* copy to notes. */
do pp=1 to notes1.0
  notes.pp.daname=notes1.pp.daname
  notes.pp.dastuff=notes1.pp.dastuff
  notes.pp=notes1.pp.daname  /* used for searching */
end /* do */
notes.0=notes1.0
drop notes1.
if default_description<>' ' then do
   ii=notes.0+1
   notes.ii=default_description
   notes.ii.daname='*'
   notes.ii.dastuff=default_description
   notes.0=ii
end  /* Do */

/* create the "wildcarded" notes list (used in find_description)*/
nwilds=0
do mm=1 to notes.0
   if pos('*',notes.mm.daname)>0 then do
       nwilds=nwilds+1
       wildnotes.nwilds.daname=notes.mm.daname
       wildnotes.nwilds.dastuff=notes.mm.dastuff
   end  /* Do */
end /* do */
wildnotes.0=nwilds
return 0



return 0


/**********/
@ fix up notes. info */
fix_notes:procedure expose notes. arglist.
parse arg daflag
if notes.0=0 | arglist.!nodesc=1 then return 0
isnew=1
crlf='0d0a'x

stripme=0
if left(daflag,1)=' ' & left(daflag,2)<>' ' then do
   stripme=1
   daflag=strip(daflag)
end
tmps.1=notes.1
tmps.1.!nlines=1
do mm=2 to notes.0
   iscont=0
   if stripme=0 then do   /* not a ' x' continution flag, so must be exact match */
      iscont=abbrev(notes.mm,daflag)
   end
   else do              /* strip spaces from 2..n, then match the "stripped" flag*/
      if left(notes.mm,1)=' ' then   /* if not first space, not a match */
         iscont=abbrev(strip(notes.mm),daflag)
   end
   if iscont=0 then do     /* not a continuation line */
        isnew=isnew+1
        tmps.isnew.!nlines=1
        tmps.isnew=notes.mm
    end
    else do
        milk=pos(daflag,notes.mm)
        tmps.isnew=tmps.isnew||crlf||substr(notes.mm,milk+length(daflag))
        tmps.isnew.!nlines=tmps.isnew.!nlines+1
    end
end
do mm=1 to isnew        /* pull out filename and it's comment */
    parse var tmps.mm  notes.mm.DANAME  notes.mm.daSTUFF
    notes.mm.DANAME=upper(notes.mm.daname)
    notes.mm.!nlines=tmps.mm.!nlines
end


notes.0=isnew

return 0


/*****************/
/* if aname (or wildcard match) is in exnames, then return 1 */
is_excluded:procedure
parse upper arg aname, exnames
if exnames=' ' then return 0

aname=translate(aname,'\','/')
/* check exacts */
  if  wordpos(aname,exnames)>0 then return 1
/* check for wildcards */
if pos('*',exnames)=0 then return 0

/* got some, check them */
do mm=1 to words(exnames)
   bword=word(exnames,mm)
   if pos('*',bword)=0 then iterate
   ares=sref_wildcard(aname,bword||' '||bword,0)
   parse var ares astat "," . ; astat=strip(astat)
   if astat<>0 then  return 1
end
return 0




/******************/
/* find a description --  .dsc files */
find_description:procedure expose notes. wildnotes. 

parse arg chkme

if notes.0=0 then return ' '
tt=arraysearch(notes.,yikes,chkme,'X')
if tt>0 then do
       poop=yikes.1
       return notes.poop.dastuff
 end  /* Do */

/* else, try wildcard match */
 do ini=1 to wildnotes.0
       oo=sref_wildcard(chkme,wildnotes.ini.daname,0)
       parse var oo stat ',' . ; stat=strip(stat)
       if stat<>0 then return wildnotes.ini.dastuff
 end

 return ' '



