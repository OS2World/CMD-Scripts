/*  BBS add-on for the SRE-http WWW server, ver 1.02e
    This is the Directory listing, and download component.
    See BBSUP.CMD for upload,
    and BBSNEWU.CMD for new user registration.

Written by:
  Primary author: Daniel Hellerstein (danielh@econ.ag.gov)
  Primary collaborator: Juho Risku (jrisku@paju.oulu.fi)


                 **** IMPORTANT INSTALLATION NOTE ***

1)  For BBS downloads to work, you MUST add the following entries to your
    SRE-http "alias" file (they may already be there..)
         bbs/download/ *  bbs?download=*
         bbs/zipdownload/ *  bbs?zipdownload=*

  (do NOT include a space between the / and *,, but I needed to put it
   in do prevent a REXX comment!)

  To do this, you can either run the SRE-http configurator 
  or edit ALIASES.IN in the /DATA subdirectory of the GoServe working
  directory.

2) A BBS.INI file MUST exist in the same directory BBS.CMD is installed
   to.

                --- END OF INSTALLATION NOTE --------

*/


/*A few User changeable non bbs.ini  parameters ... */

authorization_mode=0  /* if  =1, check authorization field for username/password,
                         and use SRE-http privileges. If 0, use users.in files
                        THIS SHOULD AGREE WITH THE VALUE IN BBSUP.CMD  */


send_piece=1         /* if =1, then "send pieces" as they become available.
                        if=0, then send the entire file when it's ready 
                        Note: send_pieces is used in the make_dirlist procedure */


imagesize="width=24 height=24"   /* size of icons */


not_tvfs=0      /* if you are NOT running the TVFS (toronto virtual file system)
                    you can set this to 1 (tvfs has an odd bug that requires
                    some extra file checking to fix) */

/** End of user changeable  "non-BBS.INI parameters " *****************************/

/* from bbscache.cmd -- this is called as 
call bbs(0,tempfile,cache.!cookver,list0,'CACHE',list0,'USER', ,
         basedir,0,'*',0,0,1, ,
         servername,0,0)
*/

/* get the list of values sent from SRE-http, or bbscache.cmd */
parse arg  ddir, tempfile, reqstrg,list0,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir

if verb="" then do
   say " This is an add-on for the SRE-http web server. "
   say " It is NOT meant be run from the command line! "
   exit
end  /* Do */

/* special stuff if bbscache.cmd caller */
cache_mode=0
if verb="CACHE" then do
    cache_mode=1
    cache_mode_cookver=reqstrg
    send_piece=0
end  /* Do */


if verbose>3 then say " BBS URI: " uri

foo=rxfuncquery('UZLoadFuncs')   /* load UNZIP dll */
if foo=1 then do
  call RxFuncAdd 'UZLoadFuncs', 'UNZIPAPI', 'UZLoadFuncs'
  call UZLoadFuncs
end
foo=rxfuncquery('UZLoadFuncs')
if foo=1 then do
     say " Can not find UNZIP procedure library: UNZIPAPI.DLL"
     foo=responsebbs('forbid','BBS is unavailable (no UNZIPAPI)')
     return foo||' No UNZIPAPI.DLL '
end  /* Do */

basedir=strip(basedir,'t','\')||'\'

/* Now readin bbs.ini file  */

inifile=basedir||'bbs.ini'

isit=fileread(inifile,inilines,,'E')

if isit<0 then do
     say " ERROR: no BBS initialization file:" inifile
     foo=responsebbs('forbid','BBS is unavailable (no ' inifile ')')
     return foo||' Error in BBS parameters file '
end  /* Do */

signal on syntax name bad1
signal on error name bad1
mm=0

gobot:                  /* process each line of bbs.ini */
mm=mm+1
if mm > inilines.0 then signal good1
aline=inilines.mm
interpret aline
signal gobot

bad1:
signal off error ; signal off syntax ;
say " ERROR: error in BBS initialization file: " aline
foo=responsebbs('forbid','error in BBS initialization file:<br>' aline)
return foo||' Error in BBS parameters file '

/* ------  bbs_ini okay.  Check, various values, directories */
good1:
signal off error ; signal off syntax ;

call check_params
if amess<>"" then return amess

/* get options list */
if cache_mode=1 then do
   action='BBS'
   list=list0
end
else do
   parse var uri action '?' list   /* parameters are pulled from list */
   action=upper(action)
end
if verb='POST' then list=list0

/* 1) check for "initialization" command: bbs?INIT=1*/
if cache_mode=0 then do
  if  do_init(list)=1 then  return ' '
end

/* 2) initializae client set options  */
do mm=1 to words(option_list)           /*initialize all options to 0 */
   foo='!'||word(option_list,mm)
   arglist.foo=0
end
arglist.!bin_text_links=def_bin_text_links  /* default "binary and text links */
arglist.!oldstuff=''            /* and olstuff to blank */
arglist.!index_list=0        /* index_list is a special case */
arglist.!index_days=0
arglist.!altstart=0
index_mode=0
thisuri=' '

/* 3) get the user's options -- but check for special cases: ZIPDOWNLOAD and DOWNLOAD */
/* should never happen if bbscache call */

select
   when  abbrev(upper(list0),'DOWNLOAD=')=1 then do    /* 3.01 --- a download */
 
       istext=0 ; isbinary=0
       eek=translate(uri,' ','=/\') 
       action=strip(word(eek,1))
       eek=subword(eek,3)
       t1=word(eek,1)
       if pos(':',t1)>0 then do  /* look for username:password */
               parse upper var t1 arglist.!user ':' arglist.!pwd ;
               eek=delword(eek,1,1)
       end  /* Do */
       leek=words(eek)
       arglist.!file=word(eek,leek) ; eek=delword(eek,leek)
       gdir='/' ; 
       if eek<>' ' then do  /* remainder is probably directory */
         if strip(upper(word(eek,1)))='_FORCE_TEXT_' then do /* check for directive */
            istext=1 ; eek=delword(eek,1,1)
         end
         if strip(upper(word(eek,1)))='_FORCE_BINARY_' then do /* check for directive */
            isbinary=1 ; eek=delword(eek,1,1)
         end
         if eek<>' ' then gdir=translate(strip(eek),'/',' ')
       end
       arglist.!dir=gdir
       arglist.!forcetext=istext
       arglist.!forcebinary=isbinary
   end  /* Do */

   when abbrev(upper(list0),'ZIPDOWNLOAD=')>0  then do /* 3.02 --  a zip extraction download */
       istext=0 ; isbinary=0
         eek=translate(uri,' ','=/\') /* list is list from uri */
         action=strip(word(eek,1))
         eek=subword(eek,3)

        t1=word(eek,1)
        if pos(':',t1)>0 then do /* look for username:password */
             parse upper var t1 arglist.!user ':' arglist.!pwd
             eek=delword(eek,1,1)
        end  /* Do */
        leek=words(eek)
        arglist.!file=word(eek,leek) ; eek=delword(eek,leek)
        arglist.!zipfile=word(eek,leek-1)||'.ZIP' ; eek=delword(eek,leek-1)
        gdir='/' 
        if eek<>' ' then do
          if strip(upper(word(eek,1)))='_FORCE_TEXT_' then do
              istext=1 ; eek=delword(eek,1,1)
           end
          if strip(upper(word(eek,1)))='_FORCE_BINARY_' then do /* check for directive */
             isbinary=1 ; eek=delword(eek,1,1)
          end
          if eek<>' ' then gdir=translate(strip(eek),'/',' ')
       end
       arglist.!dir=gdir
       arglist.!forcetext=istext
       arglist.!forcebinary=isbinary
   end

   otherwise do                 /*3.03 ---  a directory  or index_list request */
       do until list=""                /* get the options -- from UN-modified url  */
          parse var list a0 '&' list
          parse var a0 a1 '=' a2  ; a1=upper(a1)
          if wordpos(a1,option_list)=0 then iterate  /* unknown option */
          foo='!'||a1
          if cache_mode=0 then
              arglist.foo=upper(strip(packur(translate(a2,' ','+'))))
          else
              arglist.foo=upper(strip(translate(a2,' ','+')))
          arglist.foo=strip(arglist.foo,,'"')
       end
   end                  /*otherwise */
end                     /* select */


/* 3a) set dir and rootdir */
arglist.!dir=translate(arglist.!dir,'/','\')
if arglist.!dir='' | arglist.!dir=0 then arglist.!dir='/'
arglist.!dir='/'||strip(arglist.!dir,'l','/')
arglist.!dir=strip(arglist.!dir,'t','/')||'/'

if arglist.!rootdir=1 then arglist.!rootdir=arglist.!dir


/* 4: Check for "eariler calls" options (used if user:pwd were requestd
      (should never happen if cache_mode */
if arglist.!oldstuff<>' ' then do  /* oldstuff contains more option, space delimited */
   oo=arglist.!oldstuff
   do until oo=""
      parse var oo a0 oo   /* oldstuff is space delimited */
      parse var a0 a1 '=' a2  ; a1=upper(a1)
      if wordpos(a1,option_list)=0 then iterate  /* unknown option */
      foo='!'||a1
      if cache_mode=0 then
         arglist.foo=upper(strip(packur(translate(a2,' ','+'))))
       else
         arglist.foo=upper(strip(translate(a2,' ','+')))
      arglist.foo=strip(arglist.foo,,'"')
   end
end


/* 5) double check options for goofinesses */
if datatype(arglist.!dircols)<>'NUM' then arglist.!dircols=0
arglist.!short=wordpos(upper(arglist.!short),'Y YES 1')>0
arglist.!notable=wordpos(upper(arglist.!notable),'Y YES 1')>0
arglist.!nosort=wordpos(upper(arglist.!nosort),'Y YES 1')>0
arglist.!noicons=wordpos(upper(arglist.!noicons),'Y YES 1')>0
arglist.!forcetext=wordpos(upper(arglist.!forcetext),'Y YES 1')>0
arglist.!forcebinary=wordpos(upper(arglist.!forcebinary),'Y YES 1')>0
arglist.!bin_text_links=wordpos(upper(arglist.!bin_text_links),'Y YES 1')>0

arglist.!nodir=wordpos(upper(arglist.!nodir),'Y YES 1')>0

arglist.!notime=wordpos(upper(arglist.!notime),'Y YES 1')>0
arglist.!natime=wordpos(upper(arglist.!natime),'Y YES 1')>0
arglist.!notime=max(arglist.!notime,arglist.!natime)
arglist.!natime=arglist.!notime
arglist.!nosize=wordpos(upper(arglist.!nosize),'Y YES 1')>0
arglist.!nodate=wordpos(upper(arglist.!nodate),'Y YES 1')>0
arglist.!nodesc=wordpos(upper(arglist.!nodesc),'Y YES 1')>0

if arglist.!short<>0 then arglist.!notable=1

arglist.!user=strip(UPPER(ARGLIST.!user)) 
arglist.!pwd=strip(UPPER(ARGLIST.!pwd))


header_file.!abs=0
footer_file.!abs=0

/* is this a request for a "recent files list"  (should never happen if cache_mode)*/
if arglist.!index_list<>" " & arglist.!index_list<>0 then do
  afoo=cvread(basedir||arglist.!index_list,index_list)
  if afoo=" " then do
     foo=responsebbs('notfound','No such recent files list',arglist.!index_list)
     return foo||' No such recent files list ' arglist.!index_list
  end
  arglist.!nocache=1
  index_mode=1
  if symbol('index_list.!hdrfile')='VAR' then do
     header_file.!abs=1
     header_file=index_list.!hdrfile
  end
  if symbol('index_list.!ftrfile')='VAR' then do
       footer_file.!abs=1
       footer_file=index_list.!ftrfile
  end
  if datatype(arglist.!index_days)<>"NUM" then arglist.!index_days=0
end  /* Do */

/* if explicitly no caching, then reset the appropriate flag */
if arglist.!nocache=1 then do   /* but are we explicitily told not to use cache */
  cache.!files=0 
end
else do
   thisuri=make_a_url(cache_opts,' ')
/* vars transfered to cache procedure  -- depends on cookie status */
  cache.!uri=thisuri
end

if cache_mode=1 then do
   cache.!cookver=cache_mode_cookver
   is_cookies=cache_mode_cookver
end  /* Do */
else do
  cache.!cookver=0
  if is_cookies=1 then cache.!cookver=1
end

if verbose>3  then Say "BBS vars: User pwd dir zipfile file: " arglist.!user ', ' arglist.!pwd  ', ' ,
  arglist.!dir ', ' arglist.!zipfile ', ' arglist.!file

/* at this point, arglist contains the true values of the options --
  with decoding done and corrections made */

/* 6) Check for user and pwd in the cookie, and possibly add a cookie */
/* Check for username/password cookie -- but only if not explicitly set in url*/

if cache_mode=1 then do
    arglist.!user='USER' ; arglist.!pwd='PWD'
end  /* Do */

if cache_mode=0 & is_cookies=1 & arglist.!user=0 then do
    t1=sref_get_cookie('BBS_USER_PWD',1)
    if t1<>' ' then do
       parse upper var t1 user ':' pwd ;user=strip(user); pwd=strip(pwd)
       if pwd<>'' then do
          arglist.!user=upper(strip(user))
          arglist.!pwd=upper(strip(pwd))
       END
    end
end
if cache_mode=0 &  is_cookies=1 then do         /* reset the cookie */
     boo=upper('BBS_USER_PWD='||arglist.!user||':'||arglist.!pwd)
     'header add set-cookie: '|| boo
end
/* if authorization mode, also check the username/password field */
if cache_mode=0 & authorization_mode=1 & (arglist.!user=0 | arglist.!user='' | arglist.!user='USER' ) then do
  goo=reqfield('AUTHORIZATION:')
  if goo<>" " then do
       parse var goo . m64 .              /* get the encoded cookie */
       dec=pack64(m64)                       /* and decode it */
       parse upper var dec user ':' pwd      /* split to userid and password */
       arglist.!user=strip(upper(user)) ; arglist.!pwd=strip(upper(pwd))
  end
end


/*7) check for valid username/pasword.
 If none, check_user will send a prompt file; or will create a
 users.in file (only if authenticate_mode=1).
 Also, will check ctlfile, if one exists.
 And check for download_dir, with possible changes to arglist.!dir.
 Check_user will also return several "globals" (user_header.,
 userlog_lines, privset, file_dir,  reqratio
 Note that file_dir may ALSO contain "strip prefix" flag.
Alternatively: if index_MODE=1, then fix up index_list */

wimpy=check_user(arglist.!user,arglist.!pwd,thisuri,ctlfile,defratio,index_mode,cache_mode)
if wimpy=0 then  return '401 0  BBS: Logon problem '
if wimpy=-1  then       return '302 0  Redirect to logon file '

if verbose > 2 & index_mode=0 then say arglist.!user  " download/upload ratios & weight = " reqratio ',' download_weight

if arglist.!nocache=1 then cache.!files=0

/* 8) Access allowed,so now do something useful (ratio check are still required.. */
select

/* -- an alternate "screeen" (i.e.; a personallized start screen) */
  when arglist.!altstart<>0 then do
      'RESPONSE HTTP/1.0 302 Moved Temporarily'  /* Set HTTP response line */
      call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
      call lineout tempfile, "<html><head><title>BBS redirected to alternate  document</title></head>"
      'HEADER ADD Location:' arglist.!altstart
      call lineout tempfile, "<body><h2>BBS redirected to alternate  document/h2>"
      call lineout tempfile, '<a href="'arglist.!altstart'"></a>.'
      call lineout tempfile, "</body></html>"
      call lineout tempfile  /* close */
      'FILE ERASE TYPE text/html NAME ' tempfile
      return '302 0  Redirect to alternate start '
  end  /* Do */


/* ---- send an "inclusion mode preview"  */
   when index_mode=0 & inclusion_mode_file<>0 & arglist.!preview<>0 then do   /* preview inclusion file */
      a=send_preview(uri)
      return a
   end  /* Do */

/* ---- Transfer a file */
   when index_mode=0 & arglist.!file<>0 & arglist.!zipfile=0 & arglist.!dir<>0 then do
     foo=send_file(reqratio,download_weight)          /* expose arglist. tempfile */
     return 'BBS file request '
   end  /* Do */

/* -- Show contents of a .ZIP archive */
   when index_mode=0 & arglist.!zipfile<>0  & arglist.!file=0 &  arglist.!dir<>0 then do
      foo=show_zipdir(arglist.!zipfile,arglist.!dir,arglist.!forcetext,arglist.!forcebinary,arglist.!bin_text_links)
      if foo=0 then
         return 'BBS filelist sent '
      else
         return 'BBS filelist sent from cache '

   end

/* --- extract and send a file from a .ZIP  */
   when index_mode=0 & arglist.!zipfile<>0  & arglist.!file<>0 &  arglist.!dir<>0 then do
      foo=send_zipfile(arglist.!zipfile,arglist.!dir,arglist.!file, ,
                      arglist.!forcetext,arglist.!forcebinary,reqratio,download_weight)
      return ' BBS zip extraction '
   end

/* --- send a directory listing */
   when arglist.!dir<>0 | index_mode=1 then do

    if send_piece=1 & fixexpire>0 then do  /* do fix expire now or never*/
          fpp=sref_expire_response(fixexpire)
     end

     foo=make_dirlist(diropts)          /* expose arglist. tempfile */
 
     if foo=0 then do           /* 0 means not sent from cache */
       if send_piece=0 then do          /* send entire file */
          if cache_mode=0 & fixexpire>0 then do   /* do fix expire */
             ncc=chars(tempfile)
             aa=stream(tempfile,'c','close')
            fpp=sref_expire_response(fixexpire,ncc) 
          end 
          foo=stream(tempfile,'c','close')
          if cache_mode=0 then
             'FILE ERASE TYPE text/html nocache NAME ' tempfile
          else
             foo=sysfiledelete(tempfile)
          return 'BBS filelist sent '
       end
       else do                  /* close of send in piecs */
           'send complete '
            return 'BBS filelist sent in pieces '
        end  /* Do */
     end
     else do
        return 'BBS filelist sent from cache '
     end
  end

/* --- error */
  otherwise do
     foo=responsebbs('notfound','No such BBS command',' No BBS command ')
     return foo||' Unknown BBS command '

  end
end  /* Do */



return ' '

/* ----------  end of main portion of bbs  ----------- */


/* -------------------------------- */
/* Check parameters. call as subroutine (many globals */
check_params:


bbs_param=translate(bbs_param_dir,'\','/')
if abbrev(strip(bbs_param,'l','\'),'\') =0 & pos(':',bbs_param)=0 then /* must be relative dir*/
   bbsdir=basedir||strip(bbs_param,'t','\')||'\'
else
   bbsdir=strip(bbs_param,'t','\')'\'

/* the "directory" icon */
dirgif='<img src="'ImagePath'menu.gif"' imagesize '  align=top alt="[dir] ">'
/* the "back to parent" icon */
backgif='<img src="'ImagePath'back.gif"' imagesize ' align=top alt="[..] ">'
/* The "expand this .ZIP file" icone */
unzipme='<img src="'ImagePath'expand.gif"' imagesize '  align=top alt="[unzip]"></a>'

userlog_dir=translate(userlog_dir,'\','/')
if abbrev(strip(userlog_dir,'l','\'),'\')=0 & pos(':',userlog_dir)=0 then /* must be relative dir*/
   userlog_dir=bbsdir||strip(userlog_dir,'t','\')||'\'
else
   userlog_dir=strip(userlog_dir,'t','\')||'\'

bbscache_dir=translate(bbscache_dir,'\','/')
if abbrev(strip(bbscache_dir,'l','\'),'\')=0 & pos(':',bbscache_dir)=0 then /* must be relative dir*/
   bbscache_dir=bbsdir||strip(bbscache_dir,'t','\')||'\'
else
   bbscache_dir=strip(bbscache_dir,'t','\')'\'

cache.!dir=bbscache_dir
cache.!duration=cache_duration
cache.!files=cache_files

if datatype(must_wait)<>'NUM' then must_wait=1

defratio=default_ratio||' '||default_byte_ratio
DEFAULT_DATEFMT=UPPER(DEFAULT_DATEFMT)
if wordpos(default_datefmt,'B C D E M N O S U W')=0 then default_datefmt='N'

DEFAULT_SORT_BY=UPPER(DEFAULT_SORT_BY)                                           
if wordpos(default_sort_by,'DATE EXT NAME SIZE NOSORT')=0 then default_sort_by='NAME'     

imagepath='/'||strip(imagepath,,'/')||'/'

if cache_mode=0 then fixexpire=value(enmadd||'FIX_EXPIRE',,'os2environment')

privset=upper(privset)
user_header.0=' '

/* a time  date stamp */
 d1=date('b')
 t1=time('m')/(24*60)
 nowtime=d1+t1

 user='USER' ; pwd='PWD'

if dosisdir(strip(bbsdir,'t','\'))=0 then do
     say " ERROR: no BBS parameters directory:" bbsdir
     foo=responsebbs('forbid','BBS is unavailable (no ' bbsdir ')')
     amess=' BBS unavailable '
     return foo||amess
end

if dosisdir(strip(userlog_dir,'t','\'))=0 then do
     say " ERROR: no BBS user log directory:" userlog_dir
     foo=responsebbs('forbid','BBS is unavailable (no ' userlog_dir ')')
     amess=' BBS unavailable '
     return foo||amess
end

if dosisdir(strip(bbscache_dir,'t','\'))=0 then do
     say " ERROR: no BBS user log directory:" bbscache_dir
     foo=responsebbs('forbid','BBS is unavailable (no ' bbscache_dir ')')
     amess=' BBS unavailable '
     return foo||amess
end




/* check on counter file */
counter_file=bbsdir||'BBS.CNT'
if stream(counter_file,'c','query exists')=" " then do  /* doesn't exist, create it */
    call lineout counter_file,'; BBS counter file -- all downloads '
    call lineout counter_file
end

ctlfile=stream(bbsdir||'BBS.CTL','c','query exists') /* blank means none */

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


if symbol('USE_SERVERNAME')='VAR' then do
  if  use_servername="" | use_servername=0 then do
     use_servername=servername
  end
end
else do
       use_servername=servername
end


if cache_mode=0 then is_cookies=0
if cache_mode=0 & use_cookies=1 then do
   ook=reqfield('cookie')
   if ook<>""  then    is_cookies=1
end

option_list='USER PWD DIR FILE SHORT NOSORT NOTABLE NOICONS SORTBY ZIPFILE '
option_list=option_list||' FORCETEXT FORCEBINARY BIN_TEXT_LINKS NODIR NOTIME NODATE NOSIZE NODESC OLDSTUFF PREVIEW PREVIEWDIRS '
option_list=option_list||' SIZEFMT DATEFMT TIMEFMT  ROOTDIR NATIME DIRCOLS NOCACHE '
option_list=option_list||' INDEX_LIST INDEX_DAYS  ALTSTART '

cache_opts='DIR ZIPFILE ROOTDIR NOSORT NOTABLE NOICONS NODIR NOTIME NODATE NODESC NOSIZE '
CACHE_OPTS=CACHE_OPTS||' SHORT SORTBY FORCETEXT BIN_TEXT_LINKS FORCEBINARY SIZEFMT DATEFMT TIMEFMT DIRCOLS PREVIEWDIRS '

if is_cookies=0 & authorization_mode<>1 then do
   dd='USER PWD DIR ZIPFILE  ROOTDIR NOSORT NOTABLE NOICONS NODIR NATIME NODATE NODESC NOSIZE '
   dd=dd||' SHORT SORTBY FORCETEXT BIN_TEXT_LINKS FORCEBINARY SIZEFMT DATEFMT TIMEFMT DIRCOLS NOCACHE '
end 
else do
   dd='DIR ROOTDIR ZIPFILE NOSORT NOTABLE NOICONS NODIR NATIME NODATE NODESC NOSIZE '
   dd=dd||' SHORT SORTBY FORCETEXT BIN_TEXT_LINKS FORCEBINARY SIZEFMT DATEFMT TIMEFMT DIRCOLS NOCACHE INDEX_LIST INDEX_DAYS '
end
diropts=dd
/* if inclusion_mode_file, then modify some others */
if inclusion_mode_file=' ' then inclusion_mode_file=0
if inclusion_mode_file<>0 then do
   description_file=inclusion_mode_file
   auto_describe=0
end  /* Do */


amess=""
return amess

/*********************/
/* create a url, from arglist. and a cache_opts */
make_a_url:procedure expose arglist.
parse arg theopts,thesep
thisuri=""
do mm=1 to words(theopts)
     a0=strip(word(theopts,mm)) ;aa='!'||a0
     if arglist.aa=0 then iterate         /* ignore if default value is used */
     bc=a0||'='||arglist.aa
     if thisuri="" then
        thisuri=bc
     else
       thisuri=thisuri||thesep||bc   /* use thesep as seperator */
end /* do */
return thisuri



/********************/
/* perform an initialization */
do_init:procedure expose bbscache_dir
parse arg list
if abbrev(upper(list),'INIT=')=1 then do   /* reset time ! */
 wow=sysfiletree(bbscache_dir||'$*.HTM',boys,'F')
 dels=0
 do mm=1 to boys.0
     parse var boys.mm a b c d e
     foo=sysfiledelete(strip(e))
     if foo=0 then dels=dels+1
 end
 foo=sysfiledelete(bbscache_dir||'BBSCACHE.IDX')
 if foo=0 then dels=dels+1
 string ' BBS cache has been initialized (' dels ' old entries were deleted) '
 return 1
end  /* ?INIT= command */
return 0





/********************************************/
@ display file list.  Use a table, unless NOTABLE=YES appears.
Show time, date, size; unless SHORT=YES appears.
Note use of header file, and descrpiption file */

send_file:procedure expose arglist. send_piece tempfile  bbsdir  servername footer_file ,
                             header_file footer_text header_text file_dir ,
                               description_file userlog_dir,
                             imagepath imagesize dirgif backgif must_wait write_details ,
                             exclusion_file counter_file bytes_newuser files_newuser ,
                             nowtime userlog_lines. user_header. userfile use_servername
parse arg aratio,aweight

thedir=strip(translate(arglist.!dir,'\','/'),'l','\')

gets=make_adir(file_dir,thedir)
/*gets=strip(file_dir,'t','\')||'\'||thedir*/

if dosisdir(gets)=0 then do
  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>Can not find directory</title></head>"
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' Could not find directory: ' arglist.!dir
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 0
end

dofile=translate(arglist.!file,' ','\/')
dofile=strip(word(dofile,1))

absfile=strip(gets||'\'||dofile)
yip=stream(absfile,'c','query exists')=' '
if yip=' 'then do
  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>Can not find file</title></head>"
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' Could not find file: ' arglist.!file
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 0
end

if download_okay(must_wait,aratio)=0 then return 0

/* if here, file transfer is allowed ! */
select
   when  arglist.!forcetext<>0 then
      atype='text/plain'
   when arglist.!forcebinary<>0 then
     atype='application/octet-stream'  
   otherwise
     atype=sref_mediatype(absfile)
end


'FILE TYPE ' atype ' NOCACHE NAME ' ABSFILE

foo=add_userinfo(aweight,chars(absfile),' ')
return 0



/****************/
/* is user allowed to download? */
download_okay:procedure expose send_piece tempfile user_header. bytes_newuser files_newuser ,
        nowtime user_header.


parse arg must_wait,aratio
if wordpos('STATUS',user_header.0)=0 then
   statline='0 0 0 0 0 '
else
  statline=user_header.!status

parse var aratio ratiof ratiob
parse var statline  downloads uploads downloadb uploadb index_Time

/* check ratio */
if (ratiof<>0 | ratiob<>0) & downloads+downloadb>0 then do
   tupl=uploads
   if tupl=0 then tupl=max(1,files_newuser)  /* give him one to start */
   tuplb=uploadb
   if tuplb=0 then tuplb=max(bytes_newuser,1)
   myratio=downloads/tupl
   myratiob=downloadb/tuplb
   if index_time+must_wait > nowtime then do /* he's out of his gracep period */
      if (ratiof<>0 & myratio>ratiof) | (ratiob<>0  & myratiob>ratiob) then do
         call lineout tempfile, "<body><h2>Sorry...</h2>"
         call lineout tempfile,'<b> Your download to upload ratio is too high! </b> <br>'
         towait=(index_time+must_wait)-nowtime
         if towait<1  then do
             towait=format(towait*24,2,1)
             call lineout tempfile,' <blockquote> You can download 1 file in ' towait ' hours , <br>'
         end
         else do
            towait=format(towait,,1)
            call lineout tempfile,' <blockquote> You can download 1 file in ' towait 'days, <br>'
         end
         call lineout tempfile,' ... or you can upload some files! </blockquote> '
         call lineout tempfile,' <!-- Files (req. ratio,download upload: ' ratiof ', ' downloads uploads  ' -->'
         call lineout tempfile,' <!-- Bytes (req. ratio,download uploadd: ' ratiob ', ' downloadb uploadb  ' -->'
         call lineout tempfile, "</body></html>"
         call lineout tempfile  /* close */
         'FILE ERASE TYPE text/html NAME  ' tempfile
         return 0
      end
   end  /* Do */
end
return 1



/**********************/
/* add info to user file */

add_userinfo:procedure expose user_header. userlog_lines. userfile ,
            write_details arglist. counter_file nowtime

parse arg aweight,thesize,extrainfo,isfile2


isdir=arglist.!dir
isfile=arglist.!file

if wordpos('STATUS',user_header.0)=0 then
  infoat='0 0 0 0 0 '
else
  infoat=user_header.!status

parse var infoat dl ul dlb ulb .

dl=dl+aweight ; dlb=dlb+(aweight*thesize)

ii=userlog_lines.statusat
userlog_lines.ii='Status: 'dl' 'ul' 'dlb' 'ulb' 'nowtime

if write_details=1 then do
    vv=userlog_lines.0+1
    userlog_lines.0=vv
    isdir2=upper(strip(translate(isdir,'/','\'),,'/')||'/')
    if isfile2<>' ' then
        userlog_lines.vv=isfile2 ' ' extrainfo ' ' time('n') date('n')
    else
       userlog_lines.vv=isdir2 ' ' extrainfo ' ' isfile ' ' time('n') date('n')
    userlog_lines.0=vv
end  /* Do */

/* save userlog file */
aa=filewrite(userfile,userlog_lines)
if aa=0 & verbose>0 then
  call pmprintf( " Could not augment&update BBS userfile: " userfile)


/* augment counter file */
if extrainfo=' ' then
   putme=strip(isdir,'t','/')||'/'||isfile
else
   putme=strip(isdir,'t','/')||'/'extrainfo||':'||isfile
putme=strip(putme,'l','\')
putme=strip(putme,'l','/')
stuff=sref_lookup_count(counter_file,putme,'ADD','*',2)

return ' '


/***********************************/
/* send a preview, using the inclusion_mode_file "as is" */
send_preview:procedure expose arglist. inclusion_mode_file file_dir send_piece tempfile
parse arg theuri

thedir=strip(translate(arglist.!dir,'\','/'),'l','\')
gets=make_adir(file_dir,thedir)
/*gets=strip(file_dir,'t','\')||'\'||thedir*/

/* if here, either no caching, or no matching $dircach file */
fungo='/'strip(translate(arglist.!dir,'/','\'),'l','/')
call lineout tempfile, "<html><head><title> BBS: Preview of " fungo"</title></head>"

if dosisdir(gets)=0 then do             /* no such directory */
  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title> BBS: Can not find  " fungo"</title></head>"
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' * Could not find the directory: ' arglist.!dir
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 'BBS: No directory to preview '
end

doit=gets||'\'||inclusion_mode_file
if stream(doit,'c','query exist')=' ' then do
  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>No preview file</title></head>"
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' Could not find preview file.'
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 'BBS: No INCLUSION_MODE_FILE: '||inclusion_mode_file
end

/* got the file.  Read it in, add a "return link", and ship it */
  call lineout tempfile, "<html><head><title>Previewing: " fungo "</title></head>"

aa=fileread(doit,dolines,,'E')
if dolines.0=0 then do
  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>Incorrect preview file</title></head>"
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' Could not read preview file.'
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 'BBS: bad inclusion mode file: ' inclusion_mode_file
end

/* send this file */
  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>Incorrect preview file</title></head>"

call lineout tempfile,'<pre>'
do mm=1 to dolines.0
   call lineout tempfile,dolines.mm
end /* do */

call lineout tempfile,'</pre><hr>'

/* add a link back */
if wordpos(upper(arglist.!preview),'NOLINK 2')=0 then do
   theuri=sref_replacestrg(theuri,'PREVIEW=','PREVIEWDIRS=','ALL')
   ali='<hr> Do you want to <a href="'
   ali=ali||theuri
   ali=ali||'">download files from '||fungo||'</a>'
   call lineout tempfile,ali
end
call lineout tempfile, "</body></html>"
call lineout tempfile  /* close */

'FILE ERASE TYPE text/html NAME ' tempfile
return 'BBS: previewing: ' fungo


/********************************************/
/* display file list.  Use a table, unless NOTABLE=YES appears.
Show time, date, size; unless SHORT=YES, (or vaious Noxxx options selected)
Note use of header file, and descrpiption file
Also, send pieces as available if send_piece=1
First, see if a cache file is present and useable for this request */

make_dirlist:procedure expose arglist. send_piece tempfile  bbsdir  servername footer_file,
                       header_file footer_text header_text file_dir description_file ,
                       imagepath imagesize dirgif backgif exclusion_file table_border cell_spacing ,
                       continuation_flag default_description_dir  nowtime ,
                       default_description description_text action icons. ,
                       unzipme cache.  uri authorization_mode fixexpire verbose use_servername ,
                       cache_check  option_list description_text_length auto_describe ,
                       zip_descriptor_file default_dateFMT default_sort_by inclusion_mode_file ,
                       description_text_length_1LINE index_list. index_mode ,
                       header_File.!abs footer_file.!abs cache_mode

parse arg diropts

crlf='0d0a'x
udircols=arglist.!dircols
if udircols=0 then udircols=3
if datatype(table_border)<>"NUM" then table_border=0
if datatype(cell_spacing)<>"NUM" then cell_spacing=0



if index_mode=0 then do                /* skip if "use recent list */
   thedir=strip(translate(arglist.!dir,'\','/'),'l','\')
   gets=make_adir(file_dir,thedir)
/*   gets=strip(file_dir,'t','\')||'\'||thedir*/

  /* check cache? */
  if cache.!files>0 then do
     okay=send_from_cache(gets||'\*.*',cache_check)  /* cache_check controls if check timedate crc */
     if okay=1 then return -1
  end  /*  otherwise, create it */
end

if cache_mode=1 then say "   -- processing: " gets

/* if here, index_mode, or no caching, or no matching $dircach file */

if send_piece=1 then do         /* set up "sending pieces" mode */
          'SET NETBUFFER OFF '
          'SEND TYPE text/html as INDXSRCH '
end

if index_mode=0 then do    /* check existence of this directory */
  fungo='/'strip(translate(arglist.!dir,'/','\'),'l','/')
  call dumpit("<html><head><title> BBS: Listing " fungo"</title></head>")
  if dosisdir(gets)=0 then do
     aa="<body><h2>Sorry...</h2>"crlf
     aa=aa||' ** Could not find the directory: ' arglist.!dir||crlf
     aa=aa||"</body></html>"
     call dumpit(aa)
     if send_piece=0  then call lineout tempfile
     return 0
   end
end
else do         /* use preset title */
  call dumpit("<html><head><title> " index_list.!title"</title></head>")
end  /* Do */



call write_the_header  /* write out header now (reassure impatient clients ) */

if index_mode=0 then do                /* standard mode, get the file lsit */
/* read descriptions from .dsc files */
   foo=make_dsc_descriptions(gets)

/* create an array containing file info, and descritions */

  auto_describe.!alen=0           /*first, fix up auto_describe parameter */
  if auto_describe>0 then do
    if auto_describe=1 then auto_describe=120
    auto_describe.!alen=auto_describe
  end
end             /* else, use description stored in the index_list */

/* get_filelist will call find_description */
wow=get_filelist(gets,arglist.!nosort,arglist.!sortby,arglist.!dir,arglist.!forcetext,arglist.!forcebinary,arglist.!bin_text_links, ,
                arglist.!sizefmt,arglist.!datefmt,arglist.!timefmt,cache.!cookver,index_mode,arglist.!Noicons)

excludes=get_exclusions(exclusion_file,gets,bbsdir)
excludes=translate(excludes,'\','/')

/* Inclusions_mode_file? Then redo filelist. */
if index_mode=0 & inclusion_mode_file<>0 then do
     foo=inclusions_redo(gets,inclusion_mode_file)
end  /* Do */

wewrote=0               /* used to signal when to write header */
if index_mode=1 then do
   call write_table_header
   wewrote=1
end

do yy=1 to filelist.0  /* ---------- LOOP THROUGH FILE/CMT ENTRIES ---- */
   tname=filelist.yy.name
   if tname=' '  then do    /* comment line */
       if arglist.!notable<>0 | wewrote=0 then do    /* use  <PRE> for names/date/etc */
            call dumpit(filelist.yy.dastuff '<br>')
       end
       else do
           call dumpit('<td valign=top colspan='ntds'> ' filelist.yy.dastuff '</td><tr valign=top>')
       end  /* Do */
       iterate
   end  /* Do */

/* if tname is in exclusion list, skip */
    if index_mode=0 then do
      if is_excluded(tname,excludes)=1 then do
         iterate
      end
    end
    if tname<>' ' then do
      tdate=left(filelist.yy.date,12)
      ttime=right(filelist.yy.time,7)
      tsize=right(filelist.yy.size,14)
      if arglist.!nosize<>0 then tsize=' '
      if arglist.!nodate<>0 then tdate=' '
      if arglist.!notime<>0 | arglist.!nodate<>0 then ttime=' '
   end

   wewrote=wewrote+1
   if wewrote=1 then  call write_table_header

/* create the link, etc for this file */
   if filelist.yy.aurl<>' ' then do
       if arglist.!noicons=0 then do
          if filelist.yy.aurl.0<>0 then DO
             APIC='<a href="'||filelist.yy.aurl.1||'">'||IMAGETYPE('FOO.TXT')||'</a>'
             APIC=APIC||'  <a href="'||filelist.yy.aurl.2||'">'||IMAGETYPE('FOO.BIN')||'</a>  '
          END
          ELSE DO
             select
                when arglist.!forcetext=1 then
                    APIC='<a href="'||filelist.yy.aurl.!inner||'">'||IMAGETYPE('foo.txt')||'</a>'
                when arglist.!forcebinary=1 then
                    APIC='<a href="'||filelist.yy.aurl.!inner||'">'||IMAGETYPE('foo.bin')||'</a>'
                 otherwise
                    APIC='<a href="'||filelist.yy.aurl.!inner||'">'||IMAGETYPE(tname)||'</a>'
             end
          END
       end
       else do          /* no icons */
          if filelist.yy.aurl.0<>0 then DO
             APIC='<a href="'||filelist.yy.aurl.1||'">'||'[text]'||'</a>'
             APIC=APIC||'  <a href="'||filelist.yy.aurl.2||'">'||'[bin]'||'</a>  '
          END
          else do
             apic=' '
          end  /* Do */
       end  /* Do */
       booger='<a href="'||filelist.yy.aurl||'">'||tname||'</a>'
    end
    else do                     /* no url for this name */
        booger='<code><u>'||tname||'</u></code>'
        apic='xx'
    end

    ae=extension(tname)
    if ae='ZIP' & filelist.yy.aurl<>' 'then do         /* CREATE A ZIP EXPANSION LINK */
      ezip=arglist.!zipfile
      arglist.!zipfile=tname
      if index_mode=1 then arglist.!dir=filespec('p',filelist.yy)
      dirlink=make_a_url(diropts,' ')
      if pos('&',dirlink)>0 then do  /* prevent & in filename bug */
           frog3=sref_replacestrg(dirlink,'%','%25','ALL')
           dirlink=sref_replacestrg(frog3,'&','%26','ALL')
      end  /* Do */
      dirlink=translate(dirlink,'&',' ')
      arglist.!zipfile=ezip
      ahref='<a href="'||action||'?'||dirlink||'">'
      ahref=ahref||unzipme
    end
    else do
       ahref=" "
    end

/* write it out, in one of 3 forms */
   if arglist.!short<>0 then do                 /* simple mode */
       call dumpit(booger)
       iterate
   end

   if arglist.!notable<>0 then do            /* notable mode */
         zblanks=' '
         if length(tname)<18 then zblanks=copies(' ',19-length(tname))
         if notes.0>0 & arglist.!nodesc<>1 then do           /* do descriptions too */
            if description_text=1 then do  /* pre text */
               aa=ahref' 'apic' 'booger' 'zblanks' 'tdate' 'ttime' 'tsize||crlf
               useme=format_desc(filelist.yy.dastuff,description_text_length,description_text_length_1line,1)
               USEME=AA||ADD_SPACE_TO_LINE(USEME)
            end
            else do             /* html text */
               useme='<pre>'ahref' 'apic' 'booger' 'zblanks' 'tdate' 'ttime' 'tsize'</pre>'
               useme=useme||'<MENU><LI>'||filelist.yy.dastuff||'</MENU>'
            end
            call dumpit(useme)
         end
         else do                /* no descriptoins */
              call dumpit(ahref' 'apic' 'booger' 'zblanks' 'tdate' 'ttime' 'tsize)
         end
        iterate
   end

  if arglist.!notable=0 then do            /*TABLE mode */
         aa='<td valign=top> '  ahref  '</td> 'crlf
         aa=aa||'<td nowrap valign=top> '   apic booger '</td> 'crlf
         if arglist.!nodate=0 then
              aa=aa||'<td valign=top> '  tdate ttime '</td> 'crlf
         if arglist.!nosize=0 then
              aa=aa||'<td valign=top > '  tsize '</td> 'crlf
         if notes.0>0 & arglist.!nodesc<>1 then do
            useme=filelist.yy.dastuff
            if description_text=1 then do
                useme=format_desc(filelist.yy.dastuff,description_text_length,description_text_length_1line,0)
                aa=aa||'<td valign=top><pre>' useme '</pre></td> 'crlf
            end
            else do
               aa=aa||'<td valign=top> ' useme '</td> 'crlf
            end
         end
         if yy< filelist.0 then aa=aa||'<tr valign=top> 'crlf
         call dumpit(aa)

   end  /* table */

end /* all the files */

if usingpre<>0  then    call dumpit('</pre>')
if usingtable<>0 then   call dumpit('</table>')
if index_mode=1 then do
   call dumpit("<br><em> # entries= " index_list.!okay '</em>')
end  /* Do */

if arglist.!nodir<>0 then signal dofooter

aa='<hr>'

call dumpit(aa)

/* skip dirs if recent mode=1 */
if index_mode=1 then signal dofooter

/* -=--------  now display directories */
wow=sysfiletree(gets||'\*.*','dirlist','OD')
if not_tvfs<>1 then do           /* check for tvfs bug unless explicitliy told not to */
  iok=0
   do nn=1 to dirlist.0
       arf=dosisdir(strip(word(dirlist.nn,words(dirlist.nn))))
       if arf=1 then do
           iok=iok+1
           dirlist.iok=dirlist.nn
        end
  end
  dirlist.0=iok
end

frogdir=translate(arglist.!dir,'/','\')

if arglist.!notable=0 then do
   fpp='/'strip(translate(arglist.!dir,'/','\'),'l','/')
   call dumpit('<Table width=80% ><th nowrap colspan='udircols '> Directories of ' fpp  ' </th><tr valign=top>')
end  /* Do */

twrote=0 ; adesc=' '
olddir=arglist.!dir; olddir1=strip(olddir,'t','/')||'/'

/* Inclusions_mode_file? Then redo dirlist. */

if inclusion_mode_file<>0 then do
   foo=inclusions_redo_dir(gets,inclusion_mode_file)
end  /* Do */

dirlist.0.iscmt=0
do yy=0 to dirlist.0                    /* write directory info */
   if inclusion_mode_file=0 then dirlist.yy.iscmt=0 
 
   if yy=0  then do             /* linkt to parent */
      isroot=strip(translate(arglist.!dir,' ','\/'))
      adesc=' '
/* but see if arglist.!rootdir is binding */
      aroot=translate(arglist.!rootdir,' ','/\')
      if aroot<>0 then do
           if abbrev(upper(strip(isroot)),upper(strip(aroot)))<>1 then iterate  /* rootdir violated*/
           if words(isroot) = words(aroot) then iterate
      end  /* Do */
      if isroot='' then iterate  /* no parent of root */
      frogdir=arglist.!dir
      adir0=subword(isroot,1,words(isroot)-1)
      if adir0="" then adir0='/'
      arglist.!dir=translate(adir0,'/',' ')
      dirlink=make_a_url(diropts,' ')
      if pos('&',dirlink)>0 then do  /* prevent & in filename bug */
           frog3=sref_replacestrg(dirlink,'%','%25','ALL')
           dirlink=sref_replacestrg(frog3,'&','%26','ALL')
      end  /* Do */
      dirlink=translate(dirlink,'&',' ')
      adir1='parent directory '
      agif=backgif
   end
   else do                      /* link to subdirectory */
      adir=dirlist.yy
      tmp=translate(adir,' ','/\:')
      adir1=word(tmp,words(tmp))

      if is_excluded('/'||adir1,excludes)=1 then
          iterate

      adesc=find_description('/'||adir1)
      if dirlist.yy.iscmt<>1 then do
         agif=imagetype('/'||adir1)
         arglist.!dir=olddir1||adir1
         dirlink=make_a_url(diropts,' ')
      end
      else do
           dirlink='<u>'adir1'</u>'
       end  /* Do */
      if pos('&',dirlink)>0 then do  /* prevent & in filename bug */
           frog3=sref_replacestrg(dirlink,'%','%25','ALL')
           dirlink=sref_replacestrg(frog3,'&','%26','ALL')
      end  /* Do */
      dirlink=translate(dirlink,'&',' ')
      if dirlist.yy.iscmt<>1 & (arglist.!PREVIEWDIRS=1 | arglist.!preview=1) then
           dirlink=dirlink||'&preview=1'

   end

   if dirlist.yy.iscmt<>1 then do
      uri2=action||'?'||dirlink
      aurl='<a href="'||uri2'">'||adir1||'</a>'
   end
   else do
      aurl='<code><u>'dirlink'</u></code>'
      agif='[xx]'
   end
 
   if arglist.!notable=0 then do        /*write link in a table */
      if arglist.!noicons=0 then
         call dumpit('<td valign=top>' agif' 'aurl' 'adesc ' </td>')
     else
         call dumpit('<td valign=top>' aurl' 'adesc '  </td>')

     twrote=twrote+1
     uy=yy//max(1,udircols)
     if  ((twrote)//udircols)=0 | udircols=1 then
          call dumpit("<tr valign=top>")
   end  /* table */
   else do              /* non table */
      if adesc<>' ' then adesc='  : 'adesc
      if arglist.!short=0 & arglist.!noicons=0 then
        call dumpit(agif' 'aurl' 'adesc' <br>')
     else
         call dumpit(aurl' 'adesc)
  end
end
if arglist.!notable=0 then do
   call dumpit('</Table>')
end  /* Do */
arglist.!dir=olddir

dofooter:  /* here if arglist.!nodir<>0 */
/* get footer info file */
if footer_file<>' ' then do
    call dumpit('<p>')
   if footer_file.!abs=0 then do
      t1=stream(gets||'\'||footer_file,'c','query exists')
      if t1=' ' then
          t1=stream(bbsdir||footer_file,'c','query exists')
   end
   else do
       t1=stream(footer_file,'c','query exists')
   end  /* Do */
   if t1<>' ' then do
         eeko=fileread(t1,'eek',,'E')
   end
    else do
       eek.0=1
       eek.1='  '
   end
   if footer_text<>0 then
      aa='<pre>'crlf
      do  mm=1 to eek.0
         aline=eek.mm
         aline=sref_replacestrg(aline,'$DIR',upper(arglist.!dir),'ALL')
         aline=sref_replacestrg(aline,'$SERVERNAME',use_servername,'ALL')
/* no longer supported -- messes up caching
         aline=sref_replacestrg(aline,'$USER',arglist.!user,'ALL')
         aline=sref_replacestrg(aline,'$PWD',arglist.!pwd,'ALL')
*/
         aa=aa||aline||crlf
     end /* do */
     if footer_text<>0 then do
         aa=aa||'</pre>'||crlf
     end
     else do
        aa=aa||'<br>'||crlf
     end
     call dumpit(aa)
end


call dumpit("</body></html>")
if send_piece=0 | CACHE.!FILES>0 then
   call lineout tempfile  /* close */

/* if do_cache, copy to cache_file */
if index_mode=0 & cache.!files>0  then do
   pig=write_to_cache(tempfile,gets||'\*.*',cache_check)
end  /* Do */

return 0


/* ---------------- */
/* write table header (call as routine */
write_table_header:  /* use globals */
usingpre=0; usingtable=0

if arglist.!notable<>0  then DO
       select
         when arglist.!NODATE=0 & arglist.!Notime=0 then
                 kitten='<U>Last Modified</U>      '
          when arglist.!nodate=0 & arglist.!Notime<>0 then
                 kitten='<U>Last Modified</U>   '
          otherwise
             kitten='    '
       end
       puppy='   <u>Size</u>'
       if arglist.!nosize<>0 then puppy=''
       if arglist.!nodate=0 then icky=14
       if arglist.!notime<>0 then icky=icky-6
       if description_text=1 | arglist.!nodesc<>0 then do
          if arglist.!bin_text_links=1 then
              call dumpit('<PRE><b> <i>(text,bin)</i>   <u>Name</U>            'kitten' 'puppy'</b>')
          else
              call dumpit('<PRE>            <b> <u>Name</U>            'kitten' 'puppy'</b>')
           useingpre=1
       end
       else do
          if arglist.!bin_text_links=1 then
             call dumpit('<pre><b> <i>(text, bin)</i>  <u>Name</U>            'kitten' 'puppy'</b></pre>')
          else
             call dumpit('<pre>            <b> <u>Name</U>            'kitten' 'puppy'</b></pre>')
       end  /* Do */
     return 0
end                        /* no table */

/* else, a table */
aa="<table border="table_border"  cellspacing=" cell_spacing "> "crlf
usingtable=1
aa=aa||' <th nowrap align="center"> </th> 'crlf

  if arglist.!bin_text_links=1 then 
    aa=aa||' <th  nowrap align="left" >(text bin) File name  </th>'crlf
  else
    aa=aa||' <th  nowrap align="center" >  File name .. </th>'crlf
  ntds=2
  dots='..';if arglist.!notime<>0 then dots=''
  if arglist.!nodate=0 then do
          ntds=ntds+1
          aa=aa||' <th nowrap  align="center">  Last Modified'dots' </th> '
  end
  if arglist.!nosize=0 then do
          ntds=ntds+1
          aa=aa||' <th nowrap align="center">  Size   </th>'
  end
  if notes.0>0 & arglist.!nodesc<>1 then do
          ntds=ntds+1
          aa=aa||' <th nowrap align="center">  Description  </th> '
  end
  aa=aa||'<tr valign=top>'

  call dumpit(aa)

  return 0


/*******************/
/* write to tempfile, or VAR it */
dumpit:
parse arg aa
crlf='0d0a'x

if send_piece=0  | cache.!files>0 then do

  call lineout tempfile,aa
end
if send_piece=1 then do
    aa=aa||crlf
   'VAR NAME AA '
end
return 0


/***************/
/* write the header (might be a index_list header file  */
write_the_header:
/* get header info file */
 IF HEADER_FILE<>' ' then DO
    if header_file.!abs=0 then do
        t1=stream(gets||'\'||header_file,'c','query exists')
        if t1=' ' then t1=stream(bbsdir||header_file,'c','query exists')
    end
    else do
        t1=stream(header_file,'c','query exists')
    end  /* Do */
    if t1<>' ' then eeko=fileread(t1,'eek',,'E')
  end
  else do               /* no header file */
     eek.0=1
     if index_mode=0 then do
        eek.1=' <body> <h2> List of files for: 'arglist.!dir '</h2>'
     end
     else do
        if symbol('index_list.!header')="VAR" then
           eek.1=index_list.!header
        else
           eek.1=' <body> <h2> Files from: ' index_list.!filedir '</h2>'
     end
  end
  if header_text<>0 then do
     eek.1=sref_insert_block(eek.1,'body','<pre> ',1,'<','>')
  end
  aa="" ; crlf='0d0a'x
  do  mm=1 to eek.0
     aline=eek.mm
     aline=sref_replacestrg(aline,'$DIR',upper(arglist.!dir),'ALL')
     aline=sref_replacestrg(aline,'$SERVERNAME',use_servername,'ALL')
/* no longer supported --messes up caching
     aline=sref_replacestrg(aline,'$USER',arglist.!user,'ALL')
     aline=sref_replacestrg(aline,'$PWD',arglist.!pwd,'ALL')
*/
     aa=aa||aline||crlf
  end /* do */
  if header_text<>0 then
     aa=aa||' </pre>'
  else
     aa=aa||' <br>'
  call dumpit(aa)

return 0

/*********/
/* perhaps break up overlong lines? */
format_desc:procedure
parse arg todo,nlen,for1,notable
crlf='0d0a'x

todo=translate(todo,' ','1a'x)
if nlen=0 then return todo   /* do NOT breakup  long lines */

if nlen=1 then nlen=40
if nlen<50 & notable=1 then nlen=nlen+35   /* pre mode gets 35 extra characters */

if length(TODO)<nlen then return todo

/* special case: if for1=1 and is multi line (embedded crlfs), then
  return as is (for1=1 signals "only break up long 1 line descriptions */

if for1=1 then do       /* check for special "break up 1 liners only " condition */
   aa=todo ;ills=0 
   do until aa=""
       parse var aa aa1 (crlf) aa
       if aa1=""  then iterate 
       ills=ills+1 
       if ills>1 then return todo /* more then one line, leave it be */
   end /* do */
end

/* candidate for break up. So do it (retain preexisting crlfs ) */
aa=clip_line(todo,NLEN,1)
RETURN AA


/********************************/
ADD_SPACE_TO_LINE:PROCEDURE
PARSE ARG AA
CRLF='0D0A'X
/* ADD SPACES TO A LINE? */
 ills=0;TLL.1=''
 notemp=0
 do until aa=""
    parse var aa aa1 (crlf) aa
    if aa1="" & ILLS=0  then iterate
    ills=ills+1 
    TLL.ILLS='      '||AA1
    IF AA1<>"" then NOTEMP=ILLS
  end /* do */

  AA2=TLL.1
  DO MM=2 TO NOTEMP
     AA2=AA2||CRLF||TLL.MM
  end /* do */
return aa2


/************************/
/* inclusions_mode_file processing-- sort filelist to match
entries in inclusions_mode_file, dropping entries that do
not appear in inclusions_mode_file. In addition, add "n.a."
entries for files that are in inclusions_mode_file, but not
in filelist.
The variables to set are:
filelist.0
filelist.n.name. filelist.n.date, filelist.n.time filelist.n.size
filelist.n.aurl  filelist.n.dastuff
(We might create some additional listings with:
  name=filename, aurl=' ',time =' ', date ='n.a.', and size='n.a.'
if a file appears in the inclusion_mode_file but does not
exist.
*/


inclusions_redo:procedure expose filelist. verbose continuation_flag

parse arg gets, incfile,isdir
if filelist.0=0 then return 0           /* nothing to do */

/* 1) read in inclusions_mode_file (in this directory only!)
Only retain file name (first word) from lines NOT beginning with
a space! */
jfile=gets||'\'||strip(incfile,'l','\')
foo2=fileread(jfile,tmp1,,'E')
ninc=0
do ii=1 to tmp1.0
   if translate(left(tmp1.ii,1),' ','\/')<>' '  then do  /* leading space means "comment", ,/\ means dir */
      ninc=ninc+1
      parse var tmp1.ii inclines.ninc inclines.ninc.cmt
      inclines.ninc.iscmt=0
      iterate
   end  /* Do */
   if left(tmp1.ii,1)=' ' & left(strip(tmp1.ii),1)<>strip(continuation_flag) then do
      ninc=ninc+1
      inclines.ninc.cmt=tmp1.ii
      inclines.ninc.iscmt=1
   end  /* Do */
end /* do */
if ninc=0 then do       /* no files, or no valid entries */
   filelist.0=0         /* so show nothing */
   if verbose>2 then say " Missing or empty inclusion mode file: " jfile
   return 0
end  /* Do */
inclines.0=ninc
drop tmp1.

/* 2) create reference list */
do mm=1 to filelist.0
    fnames.mm=filelist.mm.name
end /* do */
fnames.0=filelist.0
foo=arraysort(fnames)

/* scan through inclines, match to fnames. If match,
copy line from filelist to tmplist. If no match, create
a n.a. entry. Entries in filelist but not inclines will
not be includee in tmplist */

ntmp=0
do mm=1 to inclines.0
  tryit=inclines.mm
  ntmp=ntmp+1

  if inclines.mm.iscmt=1 then do                /* full comment line */
      tmplist.ntmp.dastuff=strip(inclines.mm.cmt)
      tmplist.ntmp.name=' '
      iterate
  end
  foo=arraysearch(fnames,founds,tryit,'S')
  if foo=0 then do  /* no match, create a n.a. entry */
      tmplist.ntmp.name=''tryit''
      tmplist.ntmp.aurl=' '
      tmplist.ntmp.size='<em>n.a.</em>'
      tmplist.ntmp.date=' '
      tmplist.ntmp.time=' '
      tmplist.ntmp.dastuff='<code>'||strip(inclines.mm.cmt)||'</code>'
      iterate
  end  /* Do */
/* it's a file match */
   is1=founds.1
   tmplist.ntmp.name=filelist.is1.name
   tmplist.ntmp.aurl=filelist.is1.aurl
   tmplist.ntmp.time=filelist.is1.time
   tmplist.ntmp.date=filelist.is1.date
   tmplist.ntmp.size=filelist.is1.size
   tmplist.ntmp.dastuff=filelist.is1.dastuff
 end /* do */

/* now copy tmplist to filelist, and we are done */
drop filelist.
filelist.0=ntmp
do mm=1 to ntmp
   filelist.mm.name=tmplist.mm.name
   filelist.mm.aurl=tmplist.mm.aurl
   filelist.mm.time=tmplist.mm.time
   filelist.mm.date=tmplist.mm.date
   filelist.mm.size=tmplist.mm.size
   filelist.mm.dastuff=tmplist.mm.dastuff
end /* do */
return ntmp



/************************/
/* dirlist version of inclusions_redo
*/


inclusions_redo_dir:procedure expose dirlist. continuation_flag

parse arg gets, incfile
if dirlist.0=0 then return 0           /* nothing to do */

/* 1) read in inclusions_mode_file (in this directory only!)
Only retain file name (first word) from lines NOT beginning with
a space! */
jfile=gets||'\'||strip(incfile,'l','\')
foo2=fileread(jfile,tmp1,,'E')
ninc=0

do ii=1 to tmp1.0
   a1=translate(left(tmp1.ii,1),'/','\')
   if a1<>'/' then iterate
   ninc=ninc+1
   parse var tmp1.ii inclines.ninc inclines.ninc.cmt
end /* do */

if ninc=0 then do       /* no files, or no valid entries */
   dirlist.0=0         /* so show nothing */
   if verbose>2 then say " Missing or empty inclusion mode file: " jfile
   return 0
end  /* Do */
inclines.0=ninc
drop tmp1.

/* 2) create reference list */
do mm=1 to dirlist.0
      adir=dirlist.mm
      tmp=translate(adir,' ','/\:')
      adir1=word(tmp,words(tmp))
    fnames.mm='/'||strip(adir1)
end /* do */
fnames.0=dirlist.0
foo=arraysort(fnames)
/* scan through inclines, match to fnames. If match,
copy line from dirlist to tmplist. If no match, create
a n.a. entry. Entries in dirlist but not inclines will
not be includee in tmplist */

ntmp=0
do mm=1 to inclines.0
  tryit=inclines.mm
  ntmp=ntmp+1
  foo=arraysearch(fnames,founds,tryit,'S')
  if foo=0 then do  /* no match, create a n.a. entry */
      tmplist.ntmp=tryit
      tmplist.ntmp.iscmt=1
      iterate
  end  /* Do */
/* it's a match */
   is1=founds.1
   tmplist.ntmp=tryit
   tmplist.ntmp.iscmt=0
 end /* do */

/* now copy tmplist to dirlist, and we are done */
drop dirlist.
dirlist.0=ntmp
do mm=1 to ntmp
   dirlist.mm=tmplist.mm
   dirlist.mm.iscmt=tmplist.mm.iscmt
end /* do */
return ntmp


/*******************************/
/* see if current request has been cached, and is not "out of date " */

send_from_cache:procedure expose  cache. nowtime verbose arglist. authorization_mode ,
                        fixexpire   cache_mode


if cache_mode=1 then return 0
else

parse arg mama,docheck

astamp=0
if docheck=1 then do        /* check file/dir crc stamp */
    booboo=sysfiletree(mama,yeepers,'BT')
    if yeepers.0>0 then do
        oo=arraysort(yeepers,1,,1,15,'A','I')  /* avoid arbitrary order problem)*/
        as1=""
        do jou=1 to yeepers.0
             as1=as1||space(yeepers.jou,1)
        end /* do */
        astamp=stringcrc(upper(as1))            /* save crc, not entire string */
    end
end  /* Do */

 cache_file=cache.!dir'bbscache.idx'
 if stream(cache_File,'c','query exists')=' ' then return 0 /* no indesx, nocache */

 foo=cvread(cache_file,clines)
 if foo=0 | clines.0=0 then return 0               /* problem with cache file */

/* cache file entries:  clines.0 = # of entries:
                        clines.hi = simple comment
                        clines.m.time = date of creation
                        clines.m.cookie= 1 if a "cookie" version
                        clines.m.uri = request string this is caching (capitalized)
                        clines.m.name = name of file containing cache
                        clines.m.filedir = string invoking file/dir of this listing
                        clines.m.stamp = crc stamp from sysfiletree of .filedir
*/

   if clines.0=0 then return 0  /* should never happen, but .. */

if verbose>3 then say " Looking for: " cache.!uri ' ,  cookie=' cache.!cookver authorization_mode

/* search 1 to clines.1 for matching uri */
do mm=1 to min(cache.!files,clines.0)
     if clines.mm.time+cache.!duration<nowtime then iterate /* too old */
     if cache.!uri<>clines.mm.uri then iterate     /* not a match */
     grodie=max(authorization_mode,cache.!cookver)
     if grodie<>clines.mm.cookie then iterate  /* wrong cookie type */
     if docheck=1 then do
        if clines.mm.stamp<>astamp then iterate
     end  /* Do */
     if stream(clines.mm.name,'c','query exists')=' '  then return 0 /* missing*/
     foo=sref_open_read(clines.mm.name,30)
     if foo<0 then return 0   /* problem */
     mostuff=charin(clines.mm.name,1,chars(clines.mm.name))
     fpp=stream(clines.mm.name,'c','close')

/* if non-cookie version, fix up username/password stuff */
    if cache.!cookver=0  & authorization_mode<>1 then do
           userpwd='/'||arglist.!user||':'||arglist.!pwd||'/'
           mostuff=sref_replacestrg(mostuff,'/USER:PWD/',userpwd,'ALL')
           bubba1='USER='||arglist.!user
           mostuff=sref_replacestrg(mostuff,'USER=USER',bubba1,'ALL')
           bubba2='PWD='||arglist.!PWD
           mostuff=sref_replacestrg(mostuff,'PWD=PWD',bubba2,'ALL')
    end
    if fixexpire>0 then do
          ncc=chars(mostuff)
          fpp=sref_expire_response(fixexpire,ncc)
     end
    'VAR TYPE text/html  Name  MOSTUFF '
    if verbose>2 then say " Using cached file: " clines.mm.name
    return 1
end /* do */
return 0                /* if here, no match */



/* --------------------------- */
/* write a cache file, and update index */
write_to_cache:procedure expose do_cache cache. nowtime verbose ARGLIST. AUTHORIZATION_MODE verbose  send_piece


 parse upper arg tempfile,mama,docheck
 astamp=0
 if docheck=1 then do     /* save a "date" stamp */
    booboo=sysfiletree(mama,yeepers,'BT')
    if yeepers.0>0 then do
        oo=arraysort(yeepers,1,,1,15,'A','I')  /* avoid arbitrary order problem)*/
        as1=""
        do jou=1 to yeepers.0
             as1=as1||space(yeepers.jou,1)
        end /* do */
        astamp=stringcrc(upper(as1))            /* save crc, not entire string */
    end
 end  /* Do */

 
 if verbose>3 then say " Saving to cache: " cache.!uri

 cache_file=cache.!dir'bbscache.idx'
 foo=sref_open_read(cache_file,30,'BOTH')

 if foo= -2 then do
      if verbose>2 then say " writetocache error open read " foo
     return 0               /* problem, give up */
 end
 if foo=-1 then do
    clines.0=0
 end
 else do
    foo=stream(cache_file,'c','close')
    foo=cvread(cache_file,clines)
    if foo=0 then do
          if verbose>2 then say " write cache cvread error "
          else
          return 0              /* problem, give up */
    end  /* Do */
 end

 foo=sref_open_read(cache_file,30,'BOTH')  /* lock it */
 if foo=-2 then do
   if verbose>2 then say " write to cache open read both error "
    return 0                /* give up */
 end

grodie=max(cache.!cookver,authorization_mode)

/* check for older version (if it matches, it's older) */
do ido=1 to min(cache.!files,clines.0)
   if clines.ido.uri<>cache.!uri then iterate
   if grodie<>clines.ido.cookie then iterate  /* wrong cookie type */

   foo=set_cache_file(tempfile,clines.ido.name)
   if foo=0 then do
       if verbose>2 then say " Write cache error, set cache file "
       return 0
   end
   clines.ido.time=nowtime
   clines.ido.uri=cache.!uri
   clines.ido.filedir=mama
   clines.ido.stamp=astamp
   clines.ido.cookie=max(authorization_mode,cache.!cookver)

   foo=stream(cache_file,'c','close') /* unlock */
   foo=cvwrite(cache_file,clines)
   if verbose>2 then say  ido " Rewrite old entry, to cache: " clines.ido.name
   return clines.ido.name
end /* do */

/* no preexising, but cache not full -- then just add an entry */
 if clines.0<cache.!files then do

     aa=dostempname(cache.!dir||'$?????.HTM') /* use this file as the cache */
     foo=set_cache_file(tempfile,aa)
     if foo=0 then return 0        /* error, give up */

     ido=clines.0+1
     clines.0=ido
     clines.ido.uri=cache.!uri
     clines.ido.time=nowtime
     clines.ido.name=AA
     clines.ido.filedir=mama
     clines.ido.stamp=astamp
     clines.ido.cookie=max(authorization_mode,cache.!cookver)

     foo=stream(cache_file,'c','close') /* unlock */
     foo=cvwrite(cache_file,clines)
     if verbose>2 then say " New entry, results to cache: " aa
     return aa
 end

/* otherwise, remove oldest entry */
 useme=1 ; usetime=clines.1.time ; oldname=clines.1.name
 do mm=2 to min(cache.!files,clines.0)
    if clines.mm.time<usetime then do
        useme=mm
        usetime=clines.mm.time
        oldname=clines.mm.name
    end  /* Do */
 end /* do */

 foo=doscopy(tempfile,OLDNAME,'R')   /* copy results to it */
 foo=set_cache_file(tempfile,oldname)
 if foo=0 then return 0        /* error, give up */

 clines.useme.time=nowtime
 clines.useme.name=OLDNAME
 clines.useme.uri=cache.!uri
 clines.ido.filedir=mama
 clines.ido.stamp=astamp
 clines.ido.cookie=cache.!cookver
 clines.ido.cookie=max(authorization_mode,cache.!cookver)

 foo=stream(cache_file,'c','close') /* unlock */
 foo=cvwrite(cache_file,clines)
 foo=sysfiledelete(oldname)
 if verbose>2 then say " Oldest removed, BBS results to cache: " oldname

 return aa

/* -------------- */
/* write to a cached file (with possible changes of user:pwd */
set_cache_file:procedure expose arglist. authorization_mode verbose cache. send_piece
parse arg tempfile,youfile
   if Authorization_mode=1 | cache.!cookver=1 then do
         foo=doscopy(tempfile,youfile,'R')   /* copy results to it */
         if foo<>0 then return 0        /* error, give up */
   end
   else do            /* gotta change user:pwd to GENERIC values */
        mostuff=charin(tempfile,1,chars(tempfile))
        userpwd='/'||arglist.!user||':'||arglist.!pwd||'/'
        mostuff=sref_replacestrg(mostuff,userpwd,'/USER:PWD/','ALL')
        bubba='USER='||arglist.!user
        mostuff=sref_replacestrg(mostuff,bubba,'USER=USER','ALL')
        bubba='PWD='||arglist.!PWD
        mostuff=sref_replacestrg(mostuff,bubba,'PWD=PWD','ALL')
        foo=sysfiledelete(youfile)
        if stream(youfile,'c','query exists')<>' ' then do
             if verbose>2 then say " SYSFILEDELETE problem in BBS set_cache file "
             return 0
        end
        foo=charout(youfile,mostuff,1)
        if foo>0 then do
           if verbose>2 then say " CHAROUT problem in bbs set cache file "
           return 0
        end
        foo=stream(youfile,'c','close')
   end  /* Do */
   return 1

/*****************/
is_excluded:procedure
parse upper arg aname, exnames
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



/***************/
@ get list of exclusions. Use own directory version if available,
or bbs_param_dir if not (they are NOT cumulative)*/
get_exclusions:procedure
parse arg thefile,gets,bbsdir
t1=stream(gets||'\'||thefile,'c','query exists')
if t1=' ' then
    t1=stream(bbsdir||thefile,'c','query exists')

if t1=' ' then
   return ' '
oo=linein(t1,1,0)
exlist=""
/* else, read the list */
do while lines(t1)=1
   oo=strip(linein(t1))
   if abbrev(oo,';')=1 then iterate
   exlist=exlist||' '||oo
end /* do */
tt=translate(exlist,' ',','||'1a090a0d'x)
return tt


/**********/
/* return file list in filelist. stem variable */
get_filelist:procedure expose filelist. notes. action wildnotes. DEFAULT_DATEFMT default_sort_by ,
                        arglist. authorization_mode auto_describe. zip_descriptor_file index_list. default_description
parse upper arg gets,nosort,sortby,thedir,forcet,forceb,links2,sizefmt,datefmt,timefmt,is_cookie,index_mode,noicons

if index_mode=0 then do                /* not recent mode */
  if wordpos(sortby,'DATE NAME EXT SIZE NOSORT')=0 then sortby=default_sort_by
  if wordpos(datefmt,'B C D E M N O S U W')=0 then datefmt=DEFAULT_DATEFMT
  if timefmt=0 then timefmt=24
  if sizefmt=0 then sizefmt=3
  juy=gets||"\*.*"
  wow=sysfiletree(juy,'alist','FT')

  if alist.0=0 then  do
    filelist.0=0
    return 0
  end

/* Convert to universal, and absolute date, date/time format
12/14/95   1:12a         160  A----  c:\DOERS.BAT
91/04/09/05/00       33430  A-HRS  c:\IO.SYS
*/
  ponies=30
  do iff=1 to alist.0
     parse var alist.iff ddd sss aaa fff
     ddd1=left(ddd,8); ddd2=substr(ddd,10)
     juldate=dateconv(ddd1,'o','b')
     parse var ddd2 ahr '/' amin
     juldate=juldate+ (((ahr*60)+amin)/(24*60))
     usedate=dateconv(ddd1,'O',datefmt)
     if timefmt=24 then
        usetime=ahr':'amin
     else do
        if ahr<12 then
              usetime=ahr':'amin'a'
        if ahr=12 then
             usetime=ahr':'amin'p'
        if ahr>12  then do
           ahr=ahr-12
           usetime=ahr':'amin'p'
        end  /* Do */
     end
     USEDATE=TRANSLATE(USEDATE,'~',' ')
     sss2=fixup_size(sizefmt,sss)
     alist.iff=usedate' 'usetime' 'sss2' 'aaa' 'fff
   if  nosort=1   then iterate
   select               /* create a "sorters" array */
      WHEN SORTBY='NAME' | sortby=0 then
          sorters=filespec('n',fff)
      when sortby='DATE' then
          sorters=juldate
      when sortby='SIZE' then
          sorters=sss
      when sortby='EXT' then do
           ape=lastpos('.',fff)
           if ape=0 | ape=length(fff) then
              sorters=' '
           else
              sorters=substr(fff,ape+1)
      end  /* Do */
      otherwise
          sorters=filespec('n',fff)
     end  /* select */
     alist.iff=left(sorters,ponies)' 'alist.iff   /* prepend sort criteria */
  end /* do */

  if nosort=0 then do     /* sort, using sorters modified array */
    select
      when sortby='SIZE' then
         wow=arraysort('alist',1,,,20,'A','N')  /* sort on criteria */
      when sortby='DATE' then
         wow=arraysort('alist',1,,,20,'D','I')  /* sort on criteria */
      otherwise
         wow=arraysort('alist',1,,,20,'A','I')  /* sort on criteria */
    end
    do iff=1 to alist.0
       alist.iff=substr(alist.iff,ponies+1)   /* strip out criteria */
    END
  end           /* nosort=0 */
end                     /* recent mode=0 */


/* Set up filelist variable */
if index_mode=1 then do
   iir=0
   do ii=1 to index_list.0
      if index_list.ii=-1 then iterate
      iir=iir+1
      filelist.iir=index_list.ii
      filelist.iir.name=filespec('n',index_list.ii)
      filelist.iir.date=index_list.ii.!ndate
      filelist.iir.size=index_list.ii.!size
      filelist.iir.time=index_list.ii.!time
      filelist.iir.dastuff=' '
      if symbol('index_list.ii.!desc')="VAR" then
         filelist.iir.dastuff=index_list.ii.!desc

      snoopy='/'||strip(index_list.ii,,'/')
      call make_aurl iir,snoopy

   end /* do */
   filelist.0=iir
   return iir
end  /* Do */


/* if here, not recent list */
thedir2='/'strip(translate(thedir,'/','\'),'l','/')
if right(thedir2,1)<>'/' then thedir2=thedir2'/'
do mm= 1 to alist.0
    parse var alist.mm fOOdate filelist.mm.time asize aaaa ,
                filelist.mm.name .
    FILELIST.MM.DATE=TRANSLATE(FOODATE,' ','~')
/* convert to xxx,yyy,zzz */
   filelist.mm.size=asize
   filelist.mm.absname=filelist.mm.name
   filelist.mm.name=filespec('N',filelist.mm.name)
   filelist.mm=filelist.mm.name
   itis0=thedir2||filelist.mm.name
   call make_aurl mm ,itis0           /* arglist.mm.aurl etc. */

end /* do */
filelist.0=alist.0

if notes.0=0 | arglist.!nodesc<>0 then
   return alist.0

/* add descriptions */
do ifi=1 to alist.0
   chkme=upper(filelist.ifi.name) ; filelist.ifi.dastuff=' '
   filelist.ifi.dastuff=find_description(chkme,filelist.ifi.absname)
end /* do */

return alist.0


/*********/
/* make the url, with possible "multiple links */
make_aurl:           /* routine, many globals */
 parse arg mm0,itis
 dw='/download'
 if authorization_mode<>1 & is_cookie=0 then
    dw=dw||'/'||arglist.!user||':'||arglist.!pwd

 filelist.mm0.aurl.0=0
 if links2=1 then do                  /* optional binary/text links */
       dw1=dw||'/_force_text_'
       dw2=dw||'/_force_binary_'
       FILELIST.MM0.AURL.0=2
       filelist.mm0.aurl.1='/'action||dw1||itis
       filelist.mm0.aurl.2='/'action||dw2||itis
  end  /* Do */
  filelist.mm0.aurl='/'action||dw||itis
  select                      /* the file link */
     when forcet>0  then  do
       dw=dw||'/_force_text_'
       filelist.mm0.aurl.!inner='/'action||dw||itis
     end
     when forceb>0 then do
       dw=dw||'/_force_binary_'
       filelist.mm0.aurl.!inner='/'action||dw||itis
     end  /* Do */
     otherwise do
       filelist.mm0.aurl.!inner='/'action||dw||itis
     end
  end   /* select */
  if arglist.!Noicons=1 then filelist.mm0.aurl=filelist.mm0.aurl.!inner



  return 1              /* useful stuff in globals */



/**********/
@ fix up notes. info */
fix_notes:procedure expose notes. description_text_length_1LINE arglist.
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


/********************************************/
responsebbs:procedure expose cache_Mode
 parse arg  request,atext,stuff


if cache_mode=1 then do
    say " BBS-cache-mode ERROR: " request " ," atext ", " stuff
    exit
end  /* Do */

  select
    when request='badreq'   then use='400 Bad request syntax'
    when request='notfound' then use='404 Not found'
    when request='forbid'   then use='403 Forbidden'
    when request='unauth'   then use='401 Unauthorized'
    when request='notallowed' then use='405 Method not allowed'
    when request='notimplemented' then use='501 Not implemented'
    otherwise do
        use='406 Not acceptable'
        call pmprintf('weird response '|| request||' '|| message)
      end
    end  /* Add others to this list as needed */


  /* Now set the response and build the response file */
  'RESPONSE HTTP/1.0' use     /* Set HTTP response line */
  parse var use code text
  if request='notallowed' then do
     'HEADER ADD Allow:HEAD '
  end

  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>"text"</title></head>"
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  select
    when request='unauth' then do
        'header add WWW-Authenticate: Basic Realm=<'atext'>'  /* challenge */
       if stuff=' ' then
         call lineout tempfile,' You are not authorized to visit this area of the bulletin board '
       else
         call lineout tempfile,' You must supply a Username if you wish to use this BBS '
    end
    when request='notfound' then
      call lineout tempfile,' File is unavailable: ' stuff
    when request='forbid' then
      call lineout tempfile,' BBS is unavailable :' atext
    otherwise
       call lineout tempfile,' Request denied: ' stuff
  end
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */


  iia=dosdir(tempfile,'s')
  'FILE ERASE TYPE text/html NAME ' tempfile



  return word(use,1)||' '||iia


end  /* Do */

return ' '


/*******/
/* IMAGETYPE: Return the name of the image file to use based on file type */
/*******/

imagetype: procedure expose imagepath ImageSize icons. dirgif

parse arg chkme
chkme=translate(chkme,'\','/')
size = ImageSize

/* if blank, return dummypic */
if chkme=' ' then 
    return '<img src="'ImagePath'dummypic.gif"' size '  align=top alt="[n.a.]">'

/* first, check custom list icons. */
 useline=''
 starat=0 ;  afterstar=0
 do mm=1 to icons.0
    aline=strip(icons.mm)
    if aline='' | abbrev(aline,';')=1  then iterate
    parse upper var aline aurl .
    aurl=translate(aurl,'\','/')
    ares=sref_wildcard(chkme,aurl||' '||aurl,0)
    parse var ares astat "," . ;  astat=strip(astat)
    if astat=0 then iterate   /* no match */
    if astat=1 then do
        gotit=1
        useline=aline
        leave
    end
    else  do
       parse var aurl ma1a ma1b
       t1=pos('*',ma1a)
       t33=length(ma1a)-t1
       if t1 >= starat  then do
          if t1 > starat | t33>afterstar then do
             starat=t1 ; afterstar=t33
             gotit=mm ; useline=aline
          end
       end
    end         /* wildcard match */
 end            /* do loop */
if useline<>' ' then do         /* got a match */
   parse var useline foo theimage
   return theimage
end  /* Do */
/* try generic -- (check if a dir entry first) */
if abbrev(chkme,'\')=1  then
 return dirgif

/* try generic entries */

  e=extension(chkme)
  select
    when e='TXT' | e='CMD' | e='DOC' | e='FAQ' | e='SAS'
      then return '<img src="'ImagePath'text.gif"' size ' align=top alt="[text]">'
    when e='HTM' | e='HTML'
      then return '<img src="'ImagePath'text.gif"' size '  align=top alt="[html]">'
    when e='PS'
      then return '<img src="'ImagePath'text.gif"' size '  align=top alt="[ps]  ">'
    when e='EXE' | e='ZIP' | e='ARC' | e='ARJ' | E='BIN'
      then return '<img src="'ImagePath'binary.gif"' size '  align=top alt="[bin] ">'
    when e="AU" | e="WAV" | e="MID"  | e="SND"
      then return '<img src="'ImagePath'sound.gif"' size '  align=top alt="[snd] ">'
    when e="GIF" | e="JPG" | e="JPEG" | e="TIF" | e="TIFF" | e="BMP"
      then return '<img src="'ImagePath'image.gif"' size '  align=top alt="[img] ">'
    when e="MPG" | e="MPEG" | e="AVI"
      then return '<img src="'ImagePath'movie.gif"' size '  align=top alt="[mov] ">'
    otherwise
      return '<img src="'ImagePath'unknown.gif"' size ' align=top alt="[file]">'
  end


extension: procedure
arg filename
/* If no period or only period is first char, then return "" */
if lastpos(".",filename)<2 then return ""
return translate(substr(filename, lastpos('.',filename)+1))



/**************/
/* Show contents of zip file.  Make use of the unzipapi.dll
(ftp://quest.jpl.nasa.gov/pub/os2/unz520d2.zip)

zipfile: The "local" file to be unzipped
zipdir: url- directory of the zipfile

Note: 3 types of headers may be displayed:
1) ZIP_HEADER_FILE -- if specified, MUST contain <BODY> element
        (it's always intererpted as html )
2) -z comments in the .ZIP file -- not displayed if get_z_zip_description=0
3) ZIP_DESCRIPTOR_FILE
*/
show_zipdir:procedure expose  send_piece tempfile imagesize imagepath file_dir ,
                    action icons. fixexpire cache. nowtime ,
                   arglist. authorization_mode  zip_descriptor_file ,
                 get_z_zip_description zip_header_file bbsdir servername use_servername ,
                 cache_check diropts cache_mode



parse arg  zipfile ,zipdir,forcet,forceb,links2

gets=translate(file_dir,'\','/')
zipdir=translate(zipdir,'\','/')

gets=make_adir(file_dir,zipdir)
/*gets=strip(file_dir,'t','\')||'\'||strip(zipdir,'l','\')*/

zipfile=strip(zipfile)
mkit=gets||'\'||zipfile

if cache_mode=1 then say "    -- processing: " mkit


/* check cache? */
if cache.!files>0 then do
   okay=send_from_cache(mkit,cache_check)
   if okay=1 then return -1
end  /*  otherwise, create it */


if dosisdir(gets)=0 then do

  if cache_Mode=1 then do
       say " BBS-cache-mode error : could not find dir : " arglist.!dir
       exit
  end  /* Do */
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' *** Could not find directory: ' arglist.!dir
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 0
end


/* get header info file */
 boi=bbsdir||zip_header_file
IF ZIP_HEADER_FILE<>' ' then DO
  t1=stream(gets||'\'||ZIP_header_file,'c','query exists')
  if t1=' ' then
      t1=stream(bbsdir||ZIP_header_file,'c','query exists')
  if t1<>' ' then do
     eeko=fileread(t1,'zhf',,'E')
  end
  else do
     zhf.0=1
     zhf.1='<BODY> <H2>Contents of 'zipfile'</H2>'
  end
END             /* HEADER */

if arglist.!noicons=1 then do
        txtimg='text';binimg='bin'
end  /* Do */
else do
  txtimg=imagetype('foo.txt')
  binimg=imagetype('foo.bin')
end


/* get -z comments */
zipcmts.0=0
if get_z_zip_description=1 then do
  /* get zipfile comment, if it exists */
  rc=uzunzip(' -z '||mkit,'zipcmts.')
  if rc<>0 then zipcmts.0=0
end

/* get zip file list and info */
rc=uzfiletree(mkit,getem,,,'Z')


/* get "file_id.diz" file */
ziphdr.0=0

/* get "file_id.diz" file */
if getem.0>0 & zip_descriptor_file<>0 & zip_descriptor_file<>' ' then do
  nww=words(getem.1)
  do km=1 to getem.0
     af3=strip(word(getem.km,nww))

      if upper(af3)=upper(zip_descriptor_file) then do
         rc=uzunziptovar(mkit,strip(af3),ziphdr)
         if rc<>0 then ziphdr.0=0
         leave
      end  /* found zipdescriptor */
  end   /* look at getems */
end  /* look for zip descriptor */

/* no longer used 
rc=uzunziptovar(mkit,zip_descriptor_file,ziphdr)
if rc<>0 then ziphdr.0=0
*/

lineno=1
anzfiles=0

call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
call lineout tempfile, "<HTML>"
call lineout tempfile, "<HEAD>"
call lineout tempfile, "<TITLE>BBS: Contents of "zipfile"</TITLE>"
call lineout tempfile, "</HEAD>"

/* display header (generic or from file) -- must contain <BODY> */
do pp=1 to zhf.0
    aline=sref_replacestrg(zhf.pp,'$DIR',upper(arglist.!dir),'ALL')
    aline=sref_replacestrg(aline,'$SERVERNAME',use_servername,'ALL')
    aline=sref_replacestrg(aline,'$ZIPFILE',zipfile,'ALL')
    call lineout tempfile,aline
end /* do */

/* display -z */
if zipcmts.0>1 then do
    call lineout tempfile,'<blockquote> <H4> Comment from .ZIP file:</h4> <code>'
    do mi=2 to zipcmts.0
        call lineout tempfile,zipcmts.mi'  <br>'
    end
    call lineout tempfile,' </code> </blockquote>'
end

/* display file_id */
if ziphdr.0>0  then do
  call lineout tempfile,' <pre>'
  do mm=1 to ziphdr.0
     call lineout tempfile,ziphdr.mm
  end
  call lineout tempfile,' </pre>'
end

if links2=0 then
  call lineout tempfile, '<pre><img src="'imagepath'dummypic.gif"  align=top alt="      " ' imagesize ' align=middle> <b>'left("Name",19)||left("Last Modified",17)||right("Size",8)'</b></pre>'
else
  call lineout tempfile, '<pre> ' txtimg || binimg ' <b>'left(" Name",19)||left("Last Modified",17)||right("Size",8)'</b></pre>'

call lineout tempfile, '<hr>'
   tt=arglist.!zipfile
    arglist.!zipfile=0
     dirlink=make_a_url(diropts,' ')
     if pos('&',dirlink)>0 then do  /* prevent & in filename bug */
           frog3=sref_replacestrg(dirlink,'%','%25','ALL')
           dirlink=sref_replacestrg(frog3,'&','%26','ALL')
     end  /* Do */
     dirlink=translate(dirlink,'&',' ')
     arglist.!zipfile=tt
call lineout tempfile, '<dt><pre><a href="'action||'?'||dirlink'"><img src="'imagepath'/back.gif" alt="[back]" width=32 height=32 align=middle>Back</a></pre>'
call lineout tempfile, '<HR>'


do mm=1 to getem.0
    aline=getem.mm
    Fname=word(aline,8)
    Ftime=word(aline,6)
    Fdate=word(aline,5)
    fdate=dateconv(translate(fdate,'/','-'),'U','N')
    Fsize=word(aline,1)
    if links2=1 then do
                nop
    end  /* Do */
   zw='zipdownload/'
   if authorization_mode<>1 & cache.!cookver<>1 then
       zw=zw||arglist.!user||':'||arglist.!pwd||'/'

    zw0=zw              /* if forcebinary or text, text link is to mime type */

    if links2=1 then do                 /* include text/binary links ?*/
       zw1=zw||'_force_text_/'
       zw2=zw||'_force_binary_/'
    end
   
    select                      /* check on force text/binary directives */
       when forcet>0 then zw=zw||'_force_text_/'
       when forceb>0 then zw=zw||'_force_binary_/'
       otherwise nop
    end

    if arglist.!Noicons=1 then zw0=zw  /* no icons -- text link is forcebinary/text */

    z2='/'||action||'/'||zw
    z20='/'||action||'/'||zw0

    z2a=strip(translate(zipdir,'/','\'),,'/')
    if z2a<>"" then do
       z3=z2||z2a||'/'
       z30=z20||z2a||'/'
    end
    else do
        z3=z2;z30=z20
    end

    if links2=1 then do
       z21='/'||action||'/'||zw1
       z22='/'||action||'/'||zw2
       if z2a<>"" then do
          z31=z21||z2a||'/'
          z32=z22||z2a||'/'
       end
       else do
          z31=z21 ; z3s=z22
       end
    end  /* Do */

    eef=delstr(strip(zipfile),length(strip(zipfile))-3)
    eef=strip(eef,,'/')
    feeb2=z3||eef||'/'||fname
    feeb20=z30||eef||'/'||fname
 
    feeb3='<a href="'feeb2'">'||fname||'</a>'
    feeb30='<a href="'feeb20'">'||fname||'</a>'

     if arglist.!noicons=1 then
         myimg=' '
     else
        myimg=imagetype(fname)

     feebpic=' '
     if arglist.!noicons=0 then do
        select
           when forcet=1 then
              feebpic='<a href="'feeb2'">'||txtimg||'</a>'
           when forceb=1 then
              feebpic='<a href="'feeb2'">'||binimg||'</a>'
           otherwise
              feebpic='<a href="'feeb2'">'||myimg||'</a>'
         end  /* select */
      end

      if links2=1 then do
           feeb21=z31||eef||'/'||fname
           feebpic1='<a href="'feeb21'">'||txtimg||'</a>'
           feeb22=z32||eef||'/'||fname
            feebpic2='<a href="'feeb22'">'||binimg||'</a>'
           feebpic=feebpic1||' '||feebpic2
      end
      if forcet+forceb>0 then
        call lineout tempfile, '<dt><pre>' feebpic' 'feeb30''copies(' ',max(0,20-length(Fname)))''right(Fdate,10)''right(Ftime,6)' 'right(Fsize,10)'</pre></dt>'
      else
        call lineout tempfile, '<dt><pre>' feebpic' 'feeb3''copies(' ',max(0,20-length(Fname)))''right(Fdate,10)''right(Ftime,6)' 'right(Fsize,10)'</pre></dt>'
end

/* call rxqueue 'DELETE', queue_name */
call lineout tempfile, "</BODY>"
call lineout tempfile, "</HTML>"
call lineout tempfile


/*  copy to cache_file? */
if cache.!files>0  then do
   pig=write_to_cache(tempfile,mkit,cache_check)
end  /* Do */

if cache_mode=0 & fixexpire>0 then do
         ncc=chars(tempfile)
         fpp=sref_expire_response(fixexpire)
 end

aa=stream(tempfile,'c','close')

if cache_mode=0 then
   'FILE ERASE TYPE text/html NAME ' tempfile
else
  foo=sysfiledelete(tempfile)

return 0



/**************/
/* Extract and send a zip file.
zipfile: The "local" file to be unzipped
zipdir:  url-directory of the zipfile
*/
send_zipfile:procedure expose send_piece tempfile imagesize imagepath file_dir bbsdir ,
                must_wait arglist. write_details counter_file userlog_dir ,
                bytes_newuser files_newuser nowtime ,
                user_header. userlog_lines. userfile

parse upper arg  zipfile ,zipdir,getfile,forcetext,forcebinary,aratio,aweight
zipdir='\'||strip(translate(zipdir,'\','/'),'l','\')

gets=make_adir(file_Dir,zipdir)
/*gets=strip(file_dir,'t','\')||zipdir*/

if dosisdir(gets)=0 then do
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' **** Could not find directory: ' zipdir
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 0
end

if download_okay(must_wait,aratio)=0 then return 0


zipfile=strip(zipfile)

mkit=gets||'\'||zipfile
/* make sure it exists */
if stream(mkit,'c','query exists')=' ' then  do
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' Could not find .ZIP file: ' zipfile
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
  return 0
end
rc=uzunziptostem(mkit,'sook.',getfile)
if sook.0=1 then do
  arf=strip(sook.1)
  thesize=length(sook.arf)
  if thesize=0 then do  /* hack to get around unzip.dll ?bug? */
     sook.arf=uzunziptovar(mkit,getfile)
     thesize=length(sook.arf)
  end

  select
     when forcetext<>0 then
         atype='text/plain'
     when forcebinary<>0 then
         atype='appplication/octet-stream'
     otherwise
         atype=sref_mediatype(getfile)
  end
  'VAR TYPE ' atype ' as ' getfile ' name sook.arf '
  foo=add_userinfo(aweight,thesize,' Extract from '||zipfile)
end
else do
  call lineout tempfile, "<body><h2>Sorry...</h2>"
  call lineout tempfile,' Could not find Zipped file: ' getfile
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME ' tempfile
end


return 0


/* fix up size, given format */
fixup_size:procedure
parse upper arg sizefmt,asize
 if translate(sizefmt)="ABBREV" then do
               if asize>=1000000 then
                       return format(asize/1000000,,0)||'M'
               if asize>=1000 then
                      return format(asize/1000,,0)||'K'
 end
/* convert to xxx,yyy,zzz */
 il=length(asize)
 if il>3 then do
           oop=""
           do mm=il to 3 by -3
               tt=substr(asize,mm-2,3)
               if mm=il then
                  oop=tt
               else
                 oop=tt||','||oop
           end /* do */
           if mm<>0 then oop=substr(asize,1,mm)||','||oop
           asize=oop
        end
        return asize    /* not abbrev, or < 1000 */
 end


/*****************************//
/* get file descriptions from .dsc files (does NOT do auto descriptions) */
make_dsc_descriptions:procedure expose continuation_flag default_description ,
        default_description_dir description_text_length  description_text_length_1LINE ,
        description_text notes. wildnotes. bbsdir description_file arglist.
parse arg gets
notes1.0=0
notes.0=0

if description_file<>' ' then do
  t1=stream(gets||'\'||description_file,'c','query exists')
  if t1<>' ' then do
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
if description_file<>' ' then do
  yipper=bbsdir||description_File
  t1=stream(bbsdir||description_file,'c','query exists')
  if t1<>' ' then do
     eek=fileread(t1,'notes',,'E')
     ekk=fix_notes(continuation_flag)
  end
end
/* add this set to notes1 */
if notes.0>0 then do
  obie=notes1.0
  do mm=1 to notes.0
    obie2=obie+mm
    notes1.obie2.daname=translate(notes.mm.daname,'/','\')
    notes1.obie2.dastuff=notes.mm.dastuff
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
   notes.ii.daname='/*'
   notes.ii.dastuff=default_description_dir
   notes.ii=default_description_dir
   ii=ii+1

   notes.ii=default_description
   notes.ii.daname='*'
   notes.ii.dastuff=default_description

   notes.0=ii
end  /* Do */
/* create the "wildcarded" notes list */
/* create wildcarded list */
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


/******************/
/* find a description -- either from .dsc file, or auto describe */
find_description:procedure expose notes. wildnotes. auto_describe. zip_descriptor_file

parse arg chkme,absname

if notes.0=0 then return ' '
tt=arraysearch(notes.,yikes,chkme,'X')
if tt>0 then do
       poop=yikes.1
       return notes.poop.dastuff
 end  /* Do */

if auto_describe.!alen>0 then do
  oo=do_auto_describe(absname)
  if oo<>' ' then return oo
end

/* else, try wildcard match */
 do ini=1 to wildnotes.0
       oo=sref_wildcard(chkme,wildnotes.ini.daname,0)
       parse var oo stat ',' . ; stat=strip(stat)
       if stat<>0 then return wildnotes.ini.dastuff
 end

 return ' '


/* ------------------------------- */
/* check for username/password.
IF none, or incorrect, (username=USER or username=" "),
then redirect to LOGON_FILE, with the Arglist.!uri as an ? option.
Note that the LOGON_FILE can be customized, but should contain some
basic structure.

Note the use of .in files to store information "by user", rather then
central registry

If not authorization mode, then reqratio, download_weight, user_header. 
  file_dir userlog_lines. privset   are also "returned"
If authorization mode, then a www-authenticate, or a "redirect to logon file"
  have already occured.

*/

check_user:procedure expose userlog_dir userlog_lines. bbs_logon_file ,
        servername serverport send_piece tempfile verbose arglist.  user_header. ,
        privset reqratio file_dir userfile verbose own_name_privilege option_list ,
        priv_weight. priv_ratio. authorization_mode use_servername index_list. nowtime download_weight

parse arg auser,apwd,thisuri,ctlfile,defratio,isindex,cache_mode

/* special cache mode action */
if cache_mode=1  then do
  ok0=fig_access(ctlfile,arglist.!dir,'SUPERUSER')   /* if ctlfile=' ', then fig_access does not check */
  parse upper var ok0 ok  reqprivs  ','  avirtual
  if avirtual<>0 & avirtual<>' ' then file_dir=strip(avirtual)
  return 1
end


if upper(auser)="USER" | auser=0 | auser="" then do
    mess2='You did not specify a username and password'
    signal nonesuch
end

/* check for .in file */
userfile=userlog_dir||auser||'.in'
shtread=0

newread:
if arglist.!file=' ' & shtread=0 then do
   ww=fileread(userfile,userlog_lines,40,'E')   /*assume header within 40 lines*/
   shtread=1
end
else do
   ww=fileread(userfile,userlog_lines,,'E')
end
mess2='Access denied.  '

if userlog_lines.0>500 & verbose>1 then
 say "BBS Warning: the user-log for " auser " is getting large. "

/* if no user file, then either redirect to registration form,
 or if authorizationmode, create a basic file */
if userlog_lines.0=0 then do
  if authorization_mode=1 then do
     foo=create_user_log(userfile,auser,apwd,privset,defratio)
  end  /* Do */
  else do
     if auser=0 then
        mess2= " Username and password were not specified "
     else
        mess2= " No such user:" auser
     if verbose>2 then say  mess2
     signal nonesuch
  end
end

/* if here, got userlog lines-- either from file, or just created
 So extract headers from userlog_lines. */

 daheaders=get_user_header(userfile)
 if wordpos('MESSAGES',daheaders)=0 and shtread=1 then do /* gotta read all of file*/
     signal newread
 end

/* check username password */

 if wordpos('USER',daheaders)=0 then do  /* no user/pwd info */
      mess2=" Missing username/password info for:" auser
     if verbose>2 then say  mess2
     signal nonesuch
 end  /* Do */
 else do
    parse upper var user_header.!user  buser bpwd
    if strip(auser)<>strip(buser) | strip(apwd)<>strip(bpwd) then  do
         mess2=" Password mismatch for:" auser
        if verbose>2 then say  mess2
        signal nonesuch
    end  /* pwd and user match */
 end

/* what are the user privileges ? */
if authentication_mode<>1 then do  /* =1, then use SRE-http privset */
  if wordpos('PRIVILEGES',user_header.0)=0 then do
     privset='NEWUSER'
  end
  else do
      privset=user_header.!privileges
      if own_name_privilege=1 then privset=privset||' !'||auser
  end
end

/*what are the personal_download_directories */
 if wordpos('DOWNLOAD_DIR',user_header.0)=0 then do
     own_download_dirs=' '
  end
  else do
      own_download_dirs=user_header.!download_dir
  end


/* if recent files list, then go through index_list, remove files
for which privileges are not available, and then return.
Also, remove "too old" files (jdate + index_days < nowtime), if
index_days>0 */

if isindex=1 then do
  nogood=0
  if verbose>2 then say " Examining  index_list entries=" index_list.0
  ppset.0=words(privset)
  do jj=1 to ppset.0
     ppset.jj=upper(strip(word(privset,jj)))
  end /* do */
  do ll=1 to index_list.0
     if index_list.ll=' ' then iterate /* leave comment as is */
     else
     if arglist.!index_days>0 then do  /* check for expiration info */
        sink=index_list.ll.!jdate +arglist.!index_days
        if sink<nowtime then do
            index_list.ll=-1 ; nogood=nogood+1; iterate
        end  /* Do */
     end  /* Do */
     pset=upper(index_list.ll.!privs)
     if wordpos('*',pset)>0  | pset=" " then iterate /* okay */
     do ll2 =1 to ppset.0       /* check for a privilege */
          if wordpos(ppset.ll2,pset)>0 then iterate ll
     end /* do */
     nogood=nogood+1            /* no priv, so no good */
     index_list.ll=-1          /* if here, no matching priv */
  end /* do */
  index_list.!okay=index_list.0-nogood
  if verbose > 2 then say " BBS Index mode, Useable entries:: " index_list.!okay
  return 1              /* it's now fixed up */
end

/* else, regular mode--- get bbs.ctl entry (request-specific) or
download_dir from user.in.  These also contain "privileges" which
are used to extract ratios and weights */

ok=0 
if own_download_dirs<>' ' then do   /* is this a personal directory */
   ok0=check_personal_dir(arglist.!dir,own_download_Dirs)
   parse upper var ok0 ok  avirtual reqprivs /* avirtual will contain "strip prefix" flag */
end /* do */

if ok=1 then do                 /* do NOT cache personal directories */
     arglist.!nocache=1
end  /* Do */
 
if ok=0 then do           /* not a personal -- perhaps a bbs.ctl */
  ok0=fig_access(ctlfile,arglist.!dir,privset)   /* if ctlfile=' ', then fig_access does not check */
  parse upper var ok0 ok  reqprivs  ','  avirtual
  if ok=0 then do
     if verbose>2 then say arglist.!user " does not have rights to " arglist.!dir
     if authentication_mode=1 then do
       foo=responsebbs('unauth',arglist.!dir,'Authorization required for 'arglist.!dir)
       return 0
     end  /* Do */
     else do
        mess2=auser||' does not have access rights to:' arglist.!dir
        signal nonesuch
     end
  end
end

/* change  file_dir */
if avirtual<>0 & avirtual<>' ' then file_dir=strip(avirtual)
if verbose>3 then say " Using file_dir = " file_dir 

/* Now determine download/upload ratios required for this file's directory */
if wordpos('RATIO',user_header.0)=0 then
   aratio=defratio
else
  aratio=user_header.!ratio
parse var aratio fratio bratio
if datatype(fratio)<>'NUM'  then fratio=0
if datatype(bratio)<>'NUM'  then bratio=0
aweight=1

/* See if a "privilege" specific ratio & weight applies (compare user's privset
to the  reqprivs, and if a match, extract (if one exists)
 the values of an associated priv_ratio.! and priv_weight.! variables  */
if reqprivs<>' ' then do
  do gn=1 to words(privset)
    ap1=upper(strip(word(privset,gn)))
    if wordpos(ap1,reqprivs)=0 then iterate
    wow='!'||ap1
    if symbol('PRIV_RATIO.'||wow)='VAR' then do   /*check for ratios */
       parse var priv_ratio.wow r1 r2
       if datatype(r1)='NUM' & datatype(r2)='NUM' then do
          fratio=max(fratio,r1)
          bratio=max(bratio,r2)
       end
    end
    if symbol('PRIV_WEIGHT.'||wow)='VAR' then do   /* check for a download weight */
       if datatype(priv_weight.wow)='NUM' then do
           aweight=min(priv_weight.wow,aweight)
       end
    end

  end
end /* do */
reqratio=fratio' 'bratio
download_weight=aweight



return 1                /* 1 signals success */


nonesuch:  /* jump here to redirect to logon file */

if authorization_mode=1 then do   /* if it is authorization mode ... */
   foo=responsebbs('unauth','BBS@'||use_servername,'Username/password required')
   return 0
end  /* Do */

/* set up stuff for redirection to logon_file */
 serverport=extract('serverport')
 sel='http://'||servername
 if serverport<>80 then sel=sel||':'||serverport
 if thisuri=' ' then
    thisuri=make_a_url(option_list,' ')
 tname=sref_replacestrg(thisuri,'%','%25','ALL')
 tname=sref_replacestrg(tname,'&','%26','ALL')
 tname=translate(tname,'+',' ')

  sel=sel||'/'||bbs_logon_file||'?'||tname
  if mess2<>' ' then sel=sel'&'translate(mess2,'+',' ')

 'RESPONSE HTTP/1.0 302 Moved Temporarily'  /* Set HTTP response line */
  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>Username/password required</title></head>"
 'HEADER ADD Location:' sel
  call lineout tempfile, "<body><h2>You must provide username and password ...</h2>"
   call lineout tempfile, '<a href="'sel'">here<a>.'
   call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */

 'FILE ERASE TYPE text/html NAME ' tempfile
if verbose>2 then say " redirecting to " sel

 return -1




/* ---------- */
/* check bbs.ctl AND look for a matching download_dir (in the user.in file) */
check_personal_dir:procedure expose arglist.
parse upper arg thedir,own_dirs


t1=translate(thedir,' ','\/')
if t1="" then
  prefix=''
else
  prefix=strip(upper(word(t1,1)))


/* look for download_dir entries in user.in */
 parse upper var own_dirs own_dirs_sel ',' own_dirs_dir ',' own_dirs_info

/* look for match to thedir in own_dirs_sel */
 igot=0; igotlen=0 ;igotd=0
 do ij=1 to words(own_dirs_sel)
      asel=strip(word(own_dirs_sel,ij))
      if prefix=asel then do
            igot=ij
            leave
      end  /* Do */
      if asel="DEFAULT" then igotd=ij
 end

 if igotd<>0 & igot=0 then do
    adir=strip(word(own_dirs_dir,igotd))   
    ainfo=strip(word(own_dirs_info,igotd)) 
    return '1 '||adir||' '|| ainfo
 end
 if igot=0 then return 0

 adir=strip(word(own_dirs_dir,igot))
 ainfo=strip(word(own_dirs_info,igot))

 return '1 *'||adir||' '|| ainfo




/* ---------- */
/* check bbs.ctl AND look for a matching download_dir (in the user.in file) */
fig_access:procedure expose arglist.
parse upper arg thefile,thedir,cprivs

thedir=upper(translate(thedir,'\','/'))
if thedir=' ' then thedir='\'
if thedir<>'\' then
   thedir='\'||strip(thedir,,'\')||'\'

if thefile=' ' then return ' '   /* nothing to do */

wow=fileread(thefile,'acclines',,'E')
if wow=0  then return 0        /* empty -- do not allow access */


/* got a request -- look for a match */
 gotit=0
 starat=0 ;  afterstar=0
 do mm=1 to acclines.0
    aline=strip(acclines.mm)
    if aline='' | abbrev(aline,';')=1  then iterate
    parse upper var aline aurl .
    aurl=translate(aurl,'\','/')
    aurl='\'||strip(aurl,,'\')
    if pos('*',aurl)=0 then aurl=aurl||'\'
    ares=sref_wildcard(thedir,aurl||' '||aurl,0)
    parse var ares astat "," aurl2 ;  astat=strip(astat)
    if astat=0 then iterate   /* no match */
    if astat=1 then do
        gotit=1
        useline=aline
        leave
    end
    else  do
       parse var aurl ma1a ma1b
       t1=pos('*',ma1a)
       t33=length(ma1a)-t1
       if t1 >= starat  then do
          if t1 > starat | t33>afterstar then do
             starat=t1 ; afterstar=t33
             gotit=mm ; useline=aline
          end
       end
    end
 end

if gotit=0 then   return 0  /* no match, no access */
parse upper var useline foo aprivs ','  avirt

if wordpos('*',aprivs)>0 | aprivs=""  | wordpos('SUPERUSER',cprivs)>0 then
       return 1 aprivs ','  avirt
do ii=1 to words(cprivs)
   if wordpos(word(cprivs,ii),aprivs)>0 then return 1  aprivs ',' avirt
end

return 0




/*************/
/* extract user header from userlog_lines. */
get_user_header:procedure expose userlog_lines. user_header.

/* get header info. ; lines are ignored. User_header.0 contains list of
   .extensions found (i.e.; user_header.!status, user_header.!privileges
   yield user_header.0='STATUS PRIVILEGES '
*/
user_header.0=' '
dsels=" " ; ddirs=" " ; dinfos=' '
do mm=1 to userlog_lines.0
     aline=strip(userlog_lines.mm)
     if abbrev(aline,';')=1 | aline=' ' then iterate
     parse var aline atype ':' aval ; uatype=upper(strip(atype))
     user_header.0=user_header.0||' '||uatype
     if uatype='MESSAGES' then leave
     if uatype="DOWNLOAD_DIR" then do
          aval=translate(aval,'\','/')
          parse upper var aval d1 d2 d3
          dsels=dsels||' '||d1
          ddirs=ddirs||' '||d2
          dinfos=dinfos||' '||d3
     end  /* Do */
     else do
        fo='!'||uatype
        user_header.fo=aval
        if uatype='STATUS' then userlog_lines.statusat=mm
    end
 end /* do */

 if dsels<>" " then
    user_header.!DOWNLOAD_DIR=dsels||' , '||ddirs||', '||dinfos

 return user_header.0


/***** Create a very basic userlog file */
create_user_log:procedure expose userlog_lines.
parse arg userfile,user,pwd,privs.defratio

drop userlog_lines.
 userlog_lines.1='; BBS user file: ' user
        userlog_lines.2='User: ' user pwd
        userlog_lines.3='Status: 0 0 0 0 0 '
        userlog_lines.4='Privileges:  NEWUSER '||privs
        userlog_lines.5='Name: Unknown '
        userlog_lines.6='Email: Unknown '
        userlog_lines.7='Ratio:  ' defratio
        userlog_lines.8='; '
        userlog_lines.9='Messages: '
   userlog_lines.0=8
   userlog_lines.statusat=3
  aa=filewrite(userfile,userlog_lines)
  if aa=0 & verbose>0 then say " Warning: error creating BBS userfile: " userfile

return 0


/****************/
do_auto_describe:procedure expose auto_describe. zip_descriptor_file
parse arg athing
ALINE0=DO_auto_describe2(ATHING,zip_descriptor_file)
aline0=sref_replacestrg(aline0,'<','&lt;','ALL')
aline0=sref_replacestrg(aline0,'>','&gt;','ALL')
aline0=strip(left(aline0,min(length(aline0),auto_describe.!alen)))
aa=aline0 ;ills=0 ;notemp=0 
crlf='0d0a'x
do until aa=""
  parse var aa aa1 (crlf) aa
  if aa1="" & ills=0 then iterate /* skip leading blank lines */
  ills=ills+1 ;  tlls.ills=aa1
  if aa1<>"" then notemp=ills   /* the last non-blank line */
end /* do */
if notemp=0 then return ' '

/* clip into max of 80 character lines */
aa=clip_line(tlls.1,80)

do mm=2 to notemp
   aa=aa||crlf||clip_line(tlls.mm,80)
end /* do */
return aa




/***************/
/* clip todo to lines of maximum nll chars */
clip_line:procedure
parse arg todo,nll,keepcrlf
crlf='0d0a'x
if length(todo)<nll then return todo
if keepcrlf<>1 then todo=translate(todo,' ','000d0a09'x)
t1=""; aa=""
do wwi=1 to words(todo)
   t1=t1||' '||word(todo,wwi)
   if length(t1)>nll then do
      if aa="" then
          aa=t1
       else
          aa=aa||crlf||t1
       t1=' '
   end  /* Do */
end
if t1<>" " & aa<>"" then  aa=aa||crlf||t1
if t1<>" " & aa="" then aa=t1
return aa


/**********************************/
/* Construct a description of a file.
  Requires the unzipapi.dll 
  Note that a maximum of about 1000 characters (or 15 lines)
  is returned in a string:

 header_string=sref_auto_describe(filename.ext)

Note: if a badly formatted html file is investigated (no
<HEAD>, or no <TITLE>, then it will be treated as a plain
text file.

----------- */
do_AUTO_DESCRIBE2:procedure 
/* construct a description from html, text, or .zip files */
crlf='0d0a'x
parse arg thefile,zdf

thefile=strip(thefile)
/* is it a .zip file? */
if right(upper(thefile),4)='.ZIP'   then do
   zipcmts.0=0     /* is there a file_id.diz file */
   rc=uzfiletree(thefile,getem)
   do km=1 to getem.0
      if upper(getem.km)=zdf then do
         rc=uzunziptovar(thefile,getem.km,zipcmts)
         if rc<>0 then zipcmts.0=0
         leave
      end
   end
   if zipcmts.0>0 then do   /* use first 15 lines of file_id.diz */
      oof=zipcmts.1
      do te=2 to min(15,zipcmts.0)
         oof=oof||crlf||zipcmts.te
      end /* do */
      return oof
   end

   zipcmts.0=0              /* no file_id.zip file, try to get -z comments */
   rc=uzunzip(' -z '||thefile,'zipcmts.')
   if rc<>0 then zipcmts.0=0
   if zipcmts.0>1 then do   /* use -z comments if available, skip generic line */
      oof=zipcmts.2
      do te=3 to zipcmts.0
         oof=oof||crlf||zipcmts.te
      end /* do */
      return oof
   end

   return ' '           /* no -z, and no file_id.diz */
end  /* .ZIP file */


/* TEXT plain file ?*/
atype=upper(sref_mediatype(thefile))
if atype='TEXT/PLAIN' then do  /*grab first 15 lines */
    oof=""
    if lines(thefile)=1 then 
          oof=linein(tempfile)
    do mm=1 to 14   /* read first 15 lines */
        if lines(thefile)=0 then leave
        tt=linein(thefile)
        oof=oof||crlf||tt
    end
    foo=stream(thefile,'c','close')
    return oof
end  /* Do */

if atype='TEXT/HTML' then do  /* parse html, look for title or description */
   oof=get_html_descript(thefile)
   if oof="" then do  /* must be badly formatted, treat as text file */
     oof=""
     aa=stream(thefile,'c','close')
     if lines(thefile)=1 then
          oof=linein(tempfile)
     do mm=1 to 14   /* read first 15 lines */
        if lines(thefile)=0 then leave
        tt=linein(thefile)
        oof=oof||crlf||tt
     end
     foo=stream(thefile,'c','close')
   end
   return oof
end

return ' '   /* other type, give up */


/**************************************/
/* Extract description from text/html file */
get_html_descript:procedure
parse arg filename

alen=min(chars(filename),2000)
stuff=charin(filename,1,alen)

stuff=space(translate(stuff,' ','00090a0d1a1b'x))

wow=look_header(filename)
astring=""
if url_title<>' ' then
   astring=strip(strip(url_title),'t','.')||'.  '
if url_content<>' ' then
   astring=astring||'0d0a'x||url_content
return astring||'0d0a'x




/* ----------------------------------------------------------------------- */
/* Look for "desc" field in header  
sets url_title and url_content exposed variables  */
/* ----------------------------------------------------------------------- */

look_header: procedure expose stuff url_title url_content
parse arg afile

url_title=""
url_content=""
dowrite=0

do until stuff=""

    parse var stuff  p1 '<' tag '>' stuff
    if  translate(word(tag,1))="HEAD" then do   /* now in head !*/
            dowrite=1
            iterate
    end
    if dowrite=0 then iterate    /* wait till we get into head .. */

    if  translate(word(tag,1))="/HEAD" then  /* out of head, all done ! */
        leave

/* IT IS A TITLE TAG?  */
     if translate(word(tag,1))="TITLE" then do
        parse var stuff url_title '<' footag '>' stuff
        if url_content<>' ' then return 0
     end

/* is it a  META HTTP-EQUIV or a META NAME ? */
    if translate(word(tag,1))="META" then do
        parse var tag ameta atype '=' rest
        tatype=translate(atype)
        if tatype="HTTP-EQUIV" | tatype="NAME" then do
           parse var rest aval1 rest
           REST=STRIP(REST)

           aval1=strip(aval1) ;
           aval1=strip(aval1,,'"')
           if abbrev(translate(aval1),'DESC')<>1 then iterate

           aval2=" "
           foo1=ABBREV(translate(rest),'CONTENT')
           if foo1>0 then do
                PARSE VAR REST FOO '=' AVAL2
                aval2=strip(aval2)
                aval2=strip(aval2,'b','"')
                url_content=LEFT(AVAL2,1000)
                if url_title<>' ' then return 0
                iterate
           end
        end             /* name or http-equiv */
    end         /* meta */
end             /* stuff */


return 0


/******************/
/* combine root directory with user directory, perhaps recognizing
"personal directory" prefix removal */

make_adir:procedure
parse arg dir1,fil1 ;dir1=strip(dir1); fil1=strip(fil1)

fil1=strip(translate(fil1,'\','/'),,'\')
dir1=strip(translate(dir1,'\','/'),,'\')

if abbrev(dir1,'*')=1 then do
    dir1=strip(substr(dir1,2))
    ii=pos('\',fil1)
    if ii>0 then 
      fil1=substr(fil1,ii+1)
    else
      fil1='\'
end
aa=strip(dir1||'\'||fil1,,'\')
return aa

