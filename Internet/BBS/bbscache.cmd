/*The  BBS add-on for the SRE-http http server: version 1.02
    This is the "caching" daemon.
    It is meant to be run as a standalond program
    (typically, from the os/2 prompt)

Written by:
  Primary author: Daniel Hellerstein (danielh@econ.ag.gov)
  Primary collaborator: Juho Risku (jrisku@paju.oulu.fi)


                 **** IMPORTANT INSTALLATION NOTE ***

1) A BBS.INI file MUST exist in the same directory BBS.CMD is installed
   to. 

                --- END OF INSTALLATION NOTE --------

*/

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




/*A few User changeable non bbs.ini  parameters ... */

imagesize="width=24 height=24"   /* size of icons */


/** End of user changeable  "non-BBS.INI parameters " *****************************/

foo=rxfuncquery('UZLoadFuncs')
if foo=1 then do
  call RxFuncAdd 'UZLoadFuncs', 'UNZIPAPI', 'UZLoadFuncs'
  call UZLoadFuncs
end
foo=rxfuncquery('UZLoadFuncs')
if foo=1 then do
     say " Can not find UNZIP procedure library: UNZIPAPI.DLL"
     exit
end  /* Do */

basedir=directory()
basedir=strip(basedir,'t','\')||'\'


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


option_list='USER PWD DIR FILE SHORT NOSORT NOTABLE NOICONS SORTBY ZIPFILE '
option_list=option_list||' FORCETEXT NODIR NOTIME NODESC NODATE NOSIZE OLDSTUFF '
option_list=option_list||' SIZEFMT DATEFMT TIMEFMT  ROOTDIR  DIRCOLS NOCACHE '


/* the "directory" icons */
dirgif='<img src="'ImagePath'menu.gif"' imagesize 'align=top alt="[dir] ">'
/* the "back to parent" icon */
backgif='<img src="'ImagePath'back.gif"' imagesize 'align=top alt="[..] ">'
/* The "expand this .ZIP file" icone */
unzipme='<img src="'ImagePath'expand.gif"' imagesize ' align=top alt="[unzip]"></a>'

bbscache_dir=translate(bbscache_dir,'\','/')
if abbrev(strip(bbscache_dir,'l','\'),'\')=0 & pos(':',bbscache_dir)=0 then /* must be relative dir*/
   bbscache_dir=bbsdir||bbscache_dir||'\'
else
   bbscache_dir=strip(bbscache_dir,'t,','\')'\'

cache.!dir=bbscache_dir
cache.!files=cache_files

action="BBS"

yani=strip(bbscache_dir,'t','\')
foo=dosisdir(yani)
if foo=0 then do
   say ' The cache directory, ' bbscache_dir ' could not be found.'
   exit
end  /* Do */

if datatype(must_wait)<>'NUM' then must_wait=1
if wordpos(default_datefmt,'B C D E M N O S U W')=0 then default_datefmt='N'
imagepath='/'||strip(imagepath,,'/')||'/'

tempfile=dostempname(bbscache_dir||'TMP?????.HT')
def_cache_file=bbsdir||'bbscache.idx'

if symbol('USE_SERVERNAME')<>'VAR' then do
   servername=get_hostname()
end
else do
  if  use_servername="" | use_servername=0 then 
      servername=get_hostname()
  else
     servername=use_servername
end


/* a time  date stamp */
 d1=date('b')
 t1=time('m')/(24*60)
 nowtime=d1+t1

 user='USER' ; pwd='PWD'

cache_file=cache.!dir'bbscache.idx'

/* fix up the icons list */
 if icons.1=0 then do
      icons.0=0
 end
 else do
     nn=0
     do forever
         nn=nn+1
         if symbol('ICONS.'||nn)<>'VAR' then leave
         if icons.nn=0 then  leave
    end /* do */
    icons.0=nn-1
 end


/* if inclusion_mode_file, then modify some others */
if inclusion_mode_file=' ' then inclusion_mode_file=0
if inclusion_mode_file<>0 then do
   description_file=inclusion_mode_file
   auto_describe=0
end  /* Do */


/* ------- End of parameter initializations ------------ */



say "          " cy_ye " This is the BBS cache daemon." normal
say bold  " It will update the BBS cache on a scheduled basis." normal
say " "
say " Note-- the base directory is: "  bold basedir normal
say "        the bbs parameters directory is: " bold bbsdir normal
say "        the bbs cache directory is: " bold bbscache_dir normal
say "        the BBS program is: " bold  action normal
SAY "        using servername: " bold  servername normal
say " "
if stream(cache_file,'c','query exists')<>' ' then do
  ayes=yesno('Do you want to save a copy of the current "cache index file"')
  if ayes=1 then do
      ty=stream(def_cache_file,'c','query exists')
      ayes=1 
      if ty<>' ' then do
           ayes=yesno(def_cache_file||' exists.  Overwrite?')
      end  /* Do */
      if ayes=1 then do
         foo=doscopy(cache_file,def_cache_file,'R')
         if foo<>0 then do
             say " Problem copying cache file ("cache_file"): " foo
            exit
         end  /* Do */
         else do
          say "Current working index: " bold cache_file normal
          say "            copied to: " bold  def_cache_file normal
        end  /* Do */
      end
  end  /* Do */
end
/* get  the reference cache index file */
saY " "
say bold " ----------             --------------- " normal
 say " This caching daemon requires a 'cache-index' "
 say " For example, you can use the cache-index you (might have) just saved."
 say ' Note: the default "cache index" is:  ' bold def_cache_file normal
 call charout, reverse " Enter the cache-index (ENTER=default): " normal
 parse pull ref_cache_file
 if ref_cache_file="" then ref_cache_file=def_cache_file
 if stream(ref_cache_File,'c','query exists')=' ' then do
      say "ERROR: The cache index, " ref_cache_file " could not be found "
      exit
 end

 do forever
   foo=cvread(ref_cache_file,clines)
   if foo=1 then leave
   say ref_cache_file " cache index is busy (^C to exit).. "
   call syssleep(2)
 end
  say "   (the # of entries in " ref_cache_file " is " clines.0 ")"

/*NOTE cache file entries: 
                        clines.0 = # of entries:
                        clines.hi = simple comment
                        clines.m.time = date of creation
                        clines.m.cookie= 1 if a "cookie" version
                        clines.m.uri = request string this is caching (capitalized)
                        clines.m.name = name of file containing cache
                        clines.m.thetype=DIR or ZIP
                        clines.m.thedir=the dir, or zipfile, this deals with
*/


say " "
call charout, reverse " What port is your web server running on (ENTER=80) " normal
parse pull sport
if datatype(sport)<>'NUM' | sport="" then  sport=80


say " "
call charout, reverse " How many minutes to wait between cache-refreshes (0=just do once):" normal
parse pull nmin
if datatype(nmin)<>'NUM' then nmin=0

if nmin>0 then do
   say " "
   say   bold "          -------- " normal
   say cy_ye "  Starting BBS cache daemon .... " normal
   say " "
   say " The BBS cache will be refreshed immediately."
   say " (you might want to minimize this session)"
end

 
/**** --- For all entries in ref_cache_lines --
   extract the associated url, call bbs.cmd
*/

icache=0
loopstart:    /* signal here to get next ref_cache_lines */

icache=icache+1
list=clines.icache.uri
cache.!cookver=clines.icache.cookie
thisuri=list
if cache.!cookver=1 then
  say icache" of " clines.0 ") Cookie Caching: " list
else
  say icache" of " clines.0 ") Non-cookie Caching: " list

list0=translate(list,' ','&')
arf=bbs(0,tempfile,cache.!cookver,list0,'CACHE',list0,'USER', ,
         basedir,0,'*',0,0,1, ,
         servername,0,0)
say "  ::: status: " arf
/*parse arg  ddir, tempfile, reqstrg,list0,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir */

if icache < clines.0 then signal loopstart  /* next entry */

if nmin=0 then do
   say " all done .. "
   exit
end


/* else, sleep nmin minutes */
say " "
say " It is now " bold time('n') normal ". BBS cache daemon will reactivate in  " bold nmin normal " minutes. "
ww=trunc(nmin*60)
if datatype(ww)<>'NUM' then ww=3600
call syssleep(ww)
say ".... BBS CACHE daemon activated "
say " "
icache=0
signal loopstart

/* ----------  end of main portion of bbscache  ----------- */



  
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
parse arg fooa , allopt
ayn='  '||bold||'Y'||normal||'es\'||bold||'N'||normal||'o'
if allopt=1 then
   ayn=ayn||'\'||bold||'A'||normal||'ll'
do forever
 foo1=normal||reverse||fooa||normal||ayn
 call charout,  foo1 normal ':'
 pull anans
 if abbrev(anans,'Y')=1 then return 1
 if abbrev(anans,'N')=1 then return 0
 if allopt=1 & abbrev(anans,'A')=1 then return 2

end



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



/* get the hostname (aa.bb.cc) for this machine */
get_hostname: procedure
    do queued(); pull .; end                   /* flush */
    address cmd '@hostname'  '| rxqueue'    
    parse pull hostname                        
    return hostname



