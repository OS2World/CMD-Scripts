/*  BBS add-on for the SRE-http http server: version 1.02
    This is the UPLOAD component. See BBS.CMD for download,
    and BBSNEWU.CMD for new user registration.

                 **** IMPORTANT INSTALLATION NOTE ***

1) A BBS.INI file MUST exist in the same directory BBSUP.CMD is installed
   to.

                --- END OF INSTALLATION NOTE --------

--------------------------------------------
       User Configurable Parameters:
******************************************/

authorization_mode=0  /* if  =1, check authorization field for username/password,
                         and use SRE-http privileges. If 0, use users.in files
                          THIS SHOULD AGREE WITH THE VALUE IN BBS.CMD*/




/*     ------------ End of User-Configurable Paramters =======*/


/* get the list of values sent from SRE-http */
parse arg  ddir, tempfile, reqstrg,list0,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir 

if verb="" then do
   say " This is an add-on for the SRE-http web server. "
   say " It is NOT meant be run from the command line! "
   exit
end  /* Do */

/*
wow=charout('g:\goserv\dump.me',list0,1)
say " wrote " length(list0) */

basedir=strip(basedir,'t','\')||'\'

upload_quick_check=1   /* if 1, the filename= component is check for preexting file */

 
inifile=basedir||'bbs.ini'


isit=fileread(inifile,inilines,,'E')

if isit<0 then do
     say " ERROR: no BBS initialization file "
     foo=responsebbs('forbid','BBS is unavailable')
     return foo||' Error in BBS parameters file '
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
foo=responsebbs('forbid','error in BBS initialization file')
return foo||' Error in BBS parameters file '

/* bbs_ini okay, or skipped.  Check, etc. various values, directories */
good1:

signal off error ; signal off syntax ;
bbs_param=translate(bbs_param_dir,'\','/')
if abbrev(strip(bbs_param,'l','\'),'\') =0 & pos(':',bbs_param)=0 then /* must be relative dir*/
   bbsdir=basedir||strip(bbs_param,'t','\')||'\'
else
  bbsdir=strip(bbs_param,'t','\')'\'


if dosisdir(strip(bbsdir,'t','\'))=0 then do
     say " ERROR: no BBS parameters directory "
     foo=responsebbs('forbid','BBS is unavailable')
     return foo||' BBS unavailable '
end

incoming_dir=translate(incoming_dir,'\','/')
if abbrev(strip(incoming_dir,'l','\'),'\')=0 & pos(':',incoming_dir)=0 then /* must be relative dir*/
   incoming_dir=bbsdir||strip(incoming_dir,'t','\')||'\'
else
  incoming_dir=strip(incoming_dir,'t','\')'\'

if dosisdir(strip(incoming_dir,'t','\'))=0 then do
     say " ERROR: no BBS incoming directory "
     foo=responsebbs('forbid','BBS is unavailable')
     return foo||' BBS unavailable '
end

userlog_dir=translate(userlog_dir,'\','/')
if abbrev(strip(userlog_dir,'l','\'),'\')=0 & pos(':',userlog_dir)=0 then /* must be relative dir*/
   userlog_dir=bbsdir||strip(userlog_dir,'t','\')||'\'
else
   userlog_dir=strip(userlog_dir,'t','\')'\'

if dosisdir(strip(userlog_dir,'t','\'))=0 then do
     say " ERROR: no BBS user log directory "
     foo=responsebbs('forbid','BBS is unavailable')
     return foo||' BBS unavailable '
end


if symbol('admin_email')<>'VAR' | symbol('bbs_smtp_gateway')<>'VAR' then do
   send_alert=0
end
else do
   if admin_email=0 | bbs_smtp_gateway=0 then send_alert=0
   if admin_email='' | bbs_smtp_gateway='' then send_alert=0
end  /* Do */


fixexpire=value(enmadd||'FIX_EXPIRE',,'os2environment')

/* a time  date stamp */
 d1=date('b')
 t1=time('m')/(24*60)
 nowtime=d1+t1

 user='USER' ; pwd='PWD'

/* check on upload log */
  upload_log=bbsdir||'UPLOAD.LOG'
  if stream(upload_log,'c','query exists')=" " then do  /* doesn't exist, create it */
       call lineout upload_log,'; BBS upload log file '
       call lineout upload_log
  end


/*in "authorization mode" 
    BBS REQUIRES that a USERNAME/password be available (except for superusers)
   otherwise, username/pwd is pulled from request (string or body) */

if authorization_mode=1 then do
  goo=reqfield('AUTHORIZATION:')
  if goo=' '  then do
      foo=responsebbs('unauth','BBS_Authorization','Username and password required to access this BBS ')
      return foo||' BBS: No user name given '
  end
end

/*is this an upload? Determine by checking for a multipart/form-data  header. */

conttype=reqfield('content-type')
if POS("MULTIPART/FORM-DATA",upper(contTYPE))>0 THEN DO
   call BBS_upload    /* USES LOTS OF globals */
   if upload_stat='-1' then return 'BBS file: username required '
   parse var upload_stat foil foilen
/* note in users transaction log */
   if foil<>0 then do
      foo=add_userinfo(foilen,aweight,tryname)
      RETURN 'BBS file uploaded '
   end
   else do
       RETURN 'BBS file upload failure '
   end  /* Do */
end  /* Do */

  
/* if here, not file upload syntax. Perhaps check file? */

checkfile1=0 ; checkfile2=0; theuser=0 ; thepwd=0
do until list0=""
    parse var list0 a1 '&' list0
    parse var a1 b1 '=' b2
    b2=packur(translate(b2,' ','+'))
    if strip(upper(b1))='CHECKFILE1' then checkfile1=strip(upper(b2))
    if strip(upper(b1))='CHECKFILE2' then checkfile2=strip(upper(b2))
    if strip(upper(b1))="USER" then theuser=strip(upper(b2))
    if strip(upper(b1))="PWD" then thepwd=strip(upper(b2))
end
if checkfile1=0 & checkfile2=0 then do
     foo=responsebbs('badreq','Bad File upload syntax',' Bad file upload syntax ')
     return foo||' Unknown BBS command '
end  /* Do */

upload_dir=strip(incoming_dir,'t','\')||'\'

/* gonna need his user.in file */
if authorization_mode<>1 then do     
  if check_user(theuser,thepwd)=0 then do     /* (user_header. , userlog_lines, */
       upload_stat='-1'  /*check_user exit with a 'FILE '*/
       return 0
  end
end
/* is there a "personal upload directory" listed */

aa1=fig_upload_dir(upload_dir,checkfile1,checkfile2)  /* expose user_header */
parse var aa1 upload_dir .
aa1=strip(aa1)

tr=strip(translate(checkfile2,'\','/'))
if right(tr,1)='\' then do
   checkfile1=translate(checkfile1,'\','/')
   checkfile2=tr||strip(checkfile1,'l','\')
end

if checkfile2=' ' | checkfile2=0   then do  /* use checkfile1 -- the own name */
   checkfile=translate(checkfile1,' ','\/')
   look1=word(checkfile,words(checkfile))
end  /* Do */
else do
    look1=checkfile2
end  /* Do */

call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'

look2=make_afile(upload_dir,look1)

lookd=filespec('d',look2)||filespec('p',look2)

/* first check for directory */
if dosisdir(strip(lookd,'t','\'))=0 then do
  if verbose>2  then say " BBSUP file check: No such directory = " lookd
  call lineout tempfile, "<html><head><title>UPLOAD File Check: Bad Directory</title></head>"
  call lineout tempfile, "<body><h2>The sub-directory you selected does exist</h2>"
  call lineout tempfile,' The sub directory you selected, <b> 'look1 ',</b> does not exist.'
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME' tempfile
  return "BBS check for upload file existence "
end

if stream(look2,'c','query exists')<>' ' then do  /* does exist */
  if verbose>2  then say " BBSUP file check: File Exists = " look2
  call lineout tempfile, "<html><head><title>UPLOAD File Check: Found</title></head>"
  call lineout tempfile, "<body><h2>The file you selected does exist</h2>"
  call lineout tempfile,' The file you selected, <b> 'look1 ',</b> already '
  call lineout tempfile,' exists in the incoming directory '.
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME' tempfile
end  /* Do */
else do
  if verbose>2  then say " BBSUP file check: File Does NOT Exist = " look2
  call lineout tempfile, "<html><head><title>UPLOAD File Check: Not Found</title></head>"
  call lineout tempfile, "<body><h2>The file you selected does not exist</h2>"
  call lineout tempfile,' The file you selected, <b> 'look1 ',</b> does <b>not</b> '
  call lineout tempfile,' exist in the incoming directory '.
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */
  'FILE ERASE TYPE text/html NAME' tempfile
end
return "BBS check for upload file existence "


/******************************************************************/
/* this is called ONLY if the content-type request header contains
   "multipart/form-data". We do NOT check
    here for that condition (we assume that the caller has checked)  */

bbs_upload:

/* procedure expose incoming_dir upload_minfree upload_maxsize  ,
   upload_log user verbose  enmadd transaction host_nickname homedir  list0  ,
   verbose userlog_lines. user_header. */
  

atype=conttype
crlf='0d0a'x
upload_dir=strip(incoming_dir,'t','\')||'\'

theuser=user ; thepwd=' '
nwritten=0

/* 1)look for content type request header */
atype2=reqfield('content-length')

/*atype="multipart/form-data; boundary=---------------------------309151678928465"*/

rept=""

parse var atype thetype ";" boog 'boundary=' abound    /* get the boundary */

if abound="" then do
   upload_stat=bbsupload_status( "0 , No boundary ")
   return
end

/* check for space constraints -- WE ASSUME ONLY 1 FILE AT A TIME!   */
adri=filespec('D',upload_dir)
tmp1=sysdriveinfo(adri)
spacefree=word(tmp1,2)
lenblock=length(list0)
if lenblock> (upload_maxsize*1000) then do /*asssume bulk of body is the file */
          upload_stat= bbsupload_status("0, File exceeds maximum allowable size of"||upload_maxsize)
          return 0
end
if lenblock> (spacefree-(1000*upload_minfree)) then do
         upload_stat=bbsupload_status("0, Not enough disk space available. ")
         return 0
end

/* if here, enough room! */
abound="--"||abound   /* since boundaries always start with -- */

abd2=abound||crlf

/* loop through message, pulling out blocks and storing in stem var bigstuff. */

/* we have parsed the blocks..
  There are 3 types of header info (in ablock.var.i.j)
       Content-Type: mime type; if missing assume text/plain
       name: the variable name (standard form stuff)
      filename: name of local file (added by browser, on type=file elements)
                This is used as default file name, if need be.
Not retained:       Content-Disposition:  should be form-data
*/
/*abody=list0*/

parse var list0 foo1 (abd2) list0    /* move beyond first boundary and it's crlf */
/* check for netscape 2.0 incorrect format */
if pos(abound,list0)=0 then do   /* no ending boundary, so add one */
   list0=list0||crlf||abound||" -- "
end

mm=0
do until list0=""
  parse var list0 thestuff (abound) list0        /* get a  boundary defined block */

  if strip(left(thestuff,4))="--" then leave        /* -- signals no more */
  if list0="" then leave
  mm=mm+1
  ablock.varname.mm=0 ; ablock.filename.mm=0
  ablock.ct.mm=0
  do forever            /* get block headers.  Stop when hit a blank line */
     parse var thestuff anarg (crlf) thestuff

     if anarg="" then do
           leave
     end
     else do                    /* extract the arguments on this line */
         do until anarg=""
              parse var anarg anarg1 ";" anarg
              boob1=pos(':',anarg1) ; boob2=pos('=',anarg1)
              if boob1=0 then nixon=boob2
              if boob2=0 then nixon=boob1
              if boob1>0 & boob2>0 then nixon=min(boob1,boob2)
              t1=translate(strip(strip(substr(anarg1,1,nixon-1)),,'"'))
              t2=strip(strip(substr(anarg1,nixon+1)),,'"')
              if t1="NAME" then ablock.varname.mm=t2

/* do quick check? */
              if t1="FILENAME" then do
                  if upload_quick_check=1 & user_header.!uploads=0 then do
                      oo0=translate(t2,' ','/\')
                      oo1=strip(word(oo0,words(oo0)))
                      oo2=stream(upload_dir||oo1,'c','query exists')
                      if oo2<>' ' then do
                          upload_stat=bbsupload_status("0, Can not upload, file already exists: "||oo1)
                          return 1
                      end
                  end  /* upload_quick_check */
                  ablock.filename.mm=t2
              end               /* filename */
              if t1="CONTENT-TYPE" then ablock.ct.mm=t2
/* don't bother storing content-disposition */
          end     /* exract arguments */
     end        /* extract args on this line */
  end                    /* get a line */
  if thestuff<>"" then do
    ablock.body.mm=left(thestuff,length(thestuff)-2)  /* strip off ending crlf */
    parse var list0 foo (crlf) list0
  end
  else do
     ablock.body.mm=""
  end
end

nblocks=mm

if nblocks=0 then do
      upload_stat= bbsupload_status( " 0 , ERROR: No data recieved. ")
      return 0
end


/* look for USER and PWD ablock.name.n elements */
if authorization_mode<>1 then do
  do arf=1 to nblocks
   if upper(ablock.varname.arf)='PWD' then thepwd=upper(strip(ablock.body.arf))
   if upper(ablock.varname.arf)='USER' then theuser=upper(strip(ablock.body.arf))
  end /* do */

/* (user_header. , userlog_lines, */


  if check_user(theuser,thepwd)=0 then do
      upload_stat='-1'  /*check_user exit with a 'FILE '*/
       return 0
  end
end


if verbose>2 then say " Upload of " lenblock " from " theuser ' : ' thepwd

/* prepare a "report" on this upload */
rept="      ====================== ====================="||crlf
rept=rept||date()|| " " ||time()|| " :: Upload from " || theuser||crlf


/* look for non 0 .filename. */
def_upload=upload_dir
do jj=1 to nblocks
   if ablock.body.jj="" then iterate /* empty block */
   if ablock.filename.jj<>0     then do   /* got a file block */
      if symbol('ablock.filename.'||jj)<>'VAR' then
          origfile='UNKNOWN'
      else
           origfile=ablock.filename.jj
      amatch=jj
      namekey=ablock.varname.jj
      tryname=" "
      ctval=ablock.ct.jj
      do ll=1 to nblocks
          if ll=amatch then iterate         /* don't check self */
          if ablock.varname.ll=namekey then do    /* this is the naming bar */
                tryname=ablock.body.ll
                ablock.varname.ll=0     /* don't need anymore */
                ablock.varname.amatch=0
                leave
          end
      end        /* scan for match */
 
  tryname=translate(tryname,'\','/')

/* determine the directory */
 
   if filespec('n',tryname)=" " then do
        tryname0=filespec('n',origfile)

        if tryname=' ' then
             tryname=tryname0
        else
             tryname=strip(tryname,,'\')||'\'||strip(tryname0,,'\')
   end
   if tryname=" " then          /* use a default name */
        tryname='FILE????.UPL'

   /* is there a "personal upload directory" listed */
   aa1=fig_upload_dir(def_upload,tryname,tryname)  /* expose user_header */
   parse var aa1 pupdir aweight 
   
   usefile=make_afile(pupdir,tryname)

   chkf=strip(filespec('d',usefile)||filespec('p',usefile),'t','\')
   if dosisdir(chkf)=0 then do
      a=lastpos('\',translate(tryname,'\','/'))
      if a>1 then
         tt=delstr(tryname,a+1)
      else
          tt=tryname
      upload_stat=bbsupload_status("0, Upload directory does not exist: "||tt)
      return 1
   end

/* if ? in file, then try making a temporary file */
   if pos('?',usefile)>0 then do
          usefile=bbsmake_temp_F(usefile)
   end

/* error if it exists */
    foo=stream(usefile,'c','query exists')
    if foo<>"" then do
       if VERBOSE>0 then say " Can not overwrite " usefile
       upload_stat= bbsupload_status(" 0 , Can not overwrite  pre-existing file: "||tryname)
       return 0
    end

/* will it fit? */
     clen=length(ablock.body.amatch)
     if clen> (upload_maxsize*1000) then do
          upload_stat= bbsupload_status("0, File exceeds maximum allowable size of "||upload_maxsize)
          return 0
     end
     adri=filespec('D',usefile)
     tmp1=sysdriveinfo(adri)
     spacefree=word(tmp1,2)
     if clen> (spacefree-(1000*upload_minfree)) then do
         down_okay=0
         upload_stat=bbsupload_status("0, Not enough disk space available on our server. ")
         return 0
     end

/* it fits! */
      nwritten=nwritten+1
      foo=charout(usefile,ablock.body.amatch,1)  /* write her out! */
      if foo<>0 then do
           upload_stat=bbsupload_status(" 0 , Error occured while writing file: "|| tryname)
      end
/* else, write stuff to upload_log */
      if VERBOSE>2 then say " BBS upload: " usefile
      dalen=length(ablock.body.amatch)
      rept=rept||dalen||" bytes to  " || usefile||crlf
      rept=rept||"Client-side name="||origfile||crlf
      if ctval<>0 then rept=rept||" Content-Type: "|| ctval||crlf
       foo=bbswrite_uplog(upload_log,rept)
   end   /* got a filename block */
end                     /* look for a filename block */

/* write generic comments */
rept= ""
do mm=1 to nblocks      /* look for misc comments */
  if ablock.varname.mm<>0 & ablock.filename.mm=0 then do
       if wordpos(upper(ablock.varname.mm),'USER PWD')>0 then iterate
       rept=rept||ablock.varname.mm ||" =  "|| ablock.body.mm||crlf
  end
end
if rept<>"" then do
  foo=bbswrite_uplog(upload_log,rept)
end

if nwritten>0 then do
   yip=bbsupload_status(" 1  , Upload completed as:  "||tryname,tryname)
   upload_stat=yip' 'dalen

/* send email alert? */
    if send_alert=1 then  foo=mail_alert(theuser,yip,dalen)

    return 0
end

upload_stat=bbsupload_status(" 0  ,  Your request did not include a file to upload. ")
return 0


/***********************************************************/
/* Write record to upload log */
/********************************************************/
bbswrite_uplog: procedure expose verbose
parse arg uplog,rept
AFOO=sref_open_read(UPLOG,20,'WRITE')
IF AFOO<0 THEN do
  audit ' could not write upload record '
  foo=stream(uplog,'c','close')
end
else do
  foo=charout(uplog,rept)
  foo=stream(uplog,'c','close')
end

return 0


/******************************************************/
/* Used by put_file     */
/******************************************************/
bbsupload_status:procedure expose verbose
parse arg ok "," amess,afile
foo=sref_expire_response(1000)
if ok=0 then do
    doc = '<!doctype html public "-//IETF//DTD HTML 2.0//EN"> <html><head><title>'
    doc=doc||" Unsuccessful upload to BBS </title></head><body> "
    doc=doc||" <h3> Unsuccessful upload to BBS </h3> "
    doc=doc||" Sorry, the file could not be uploaded.  <p> <b> Error: </b>"||amess
    doc=doc||"</body></html>"
    'var type text/html name doc '  /* tell goserve to send status message */
    return 0
end
else do
    doc = '<!doctype html public "-//IETF//DTD HTML 2.0//EN"> <html><head><title>'
    doc=doc||" Successful upload to BBS </title></head><body> "
    doc=doc||" <h3> Successful upload to BBS </h3> "
    doc=doc||" Your uploded file was succesfully recieved, and saved as:<b>"|| afile ||' </b>'
    doc=doc||"</body></html>"
    'var type text/html name doc '  /* tell goserve to send status message */
    return 1
end  /* Do */



/******************************************/
/* dostempname, with excess ? check */
/****************************************/
bbsmake_temp_F: procedure expose verbose
parse arg usefile
 if usefile="" | usefile=0 then usefile="DOWN????.UPL"
          nqs=0
          do mm=1 to length(usefile)   /* Rexx bombs with > 5 ?s */
               if substr(usefile,mm,1)="?" then do
                   nqs=nqs+1
                   if nqs>5 then
                      usefile=overlay('_',usefile,mm)
                end
           end
   return dostempname(usefile)

/* -----------------------------------------------------------------------*/


/* ------------------------------- */
/* check for username/password. 
IF none, or incorrect, (username=USER or username=" "),
the issue an "incorrect username/password" response .

Note the use of .in files to store information "by user", rather then
central registry 

*/

check_user:procedure expose userlog_dir userlog_lines.  ,
        servername serverport tempfile verbose  user_header. ,
        userfile verbose 

parse arg auser,apwd


if upper(auser)="USER" then do
  mess2='You did not specify a username and password'
  signal nonesuch
end

/* check for .in file */
userfile=userlog_dir||auser||'.in'
if verbose>2 then say " looking for bbs-user file: " userfile
shtread=0

newread:
if shtread=0 then do
   ww=fileread(userfile,userlog_lines,40,'E')   /*assume header within 40 lines*/
   shtread=1
end
else do
   ww=fileread(userfile,userlog_lines,,'E')
end
mess2='Access denied.  '

if userlog_lines.0>500 & verbose>1 then 
 say "BBS Warning: the user-log for " auser " is getting large. "

/* if no user file, tell the client */
if userlog_lines.0=0 then do
     mess2= " No such user:" auser
     if verbose>2 then say  mess2
     signal nonesuch
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

return 1                /* 1 signals success */


nonesuch:  /* jump here to  issue an error message */

  call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
  call lineout tempfile, "<html><head><title>BBS: Upload Error </title></head>"
  call lineout tempfile, "<body><h2>Problem with BBS Upload</h2>"
  call lineout tempfile,' Sorry, there was a problem processing your file upload.'
  call lineout tempfile,' <br> <B>Problem description:</b><em>'mess2'</em>'
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */

 'FILE ERASE TYPE text/html NAME' tempfile
 if verbose>2 then say " BBS Upload error: " mess2

 return 0


/*************/
/* extract user header from userlog_lines. */
get_user_header:procedure expose userlog_lines. user_header.

/* get header info. ; lines are ignored. User_header.0 contains list of
   .extensions found (i.e.; user_header.!status, user_header.!privileges
   yield user_header.0='STATUS PRIVILEGES '
*/
user_header.0=' '; nups=0
do mm=1 to userlog_lines.0
     aline=strip(userlog_lines.mm)
     if abbrev(aline,';')=1 | aline=' ' then iterate
     parse var aline atype ':' aval ; uatype=upper(strip(atype))
     user_header.0=user_header.0||' '||uatype
     if uatype='MESSAGES' then leave
     if uatype="UPLOAD_DIR" then do
          nups=nups+1
          parse upper var aval user_header.!upload_prefix.nups ,
                               user_Header.!upload_dir.nups ,
                               user_header.!upload_weight.nups .
     end /* do */
     else do
        fo='!'||uatype
        user_header.fo=aval
        if uatype='STATUS' then userlog_lines.statusat=mm
     end
 end /* do */
 user_header.!uploads=nups

 return user_header.0




/********************************************/
responsebbs:procedure
 parse arg  request,text,stuff


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
        'header add WWW-Authenticate: Basic Realm=<'text'>'  /* challenge */
       if stuff=' ' then
         call lineout tempfile,' You are not authorized to visit this area of the bulletin board '
       else
         call lineout tempfile,' You must supply a Username if you wish to use this BBS '
    end
    when request='notfound' then
      call lineout tempfile,' File is unavailable: ' stuff
    when requeset='forbid' then
      call lineout tempfile,' BBS is unavailable.'
    otherwise
       call lineout tempfile,' Request denied: ' stuff
  end
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */

  iia=dosdir(tempfile,'s')
  'FILE ERASE TYPE text/html NAME' tempfile
 


  return word(use,1)||' '||iia


end  /* Do */

return ' '



/**********************/
/* add info to user file */

add_userinfo:procedure expose user_header. userlog_lines. userfile ,
            write_details counter_file nowtime 

parse arg thesize,aweight,ufile


if wordpos('STATUS',user_header.0)=0 then 
  infoat='0 0 0 0 0 '
else
  infoat=user_header.!status

parse var infoat dl ul dlb ulb .
IF AWEIGHT=' ' then AWEIGHT=1
ul=ul+aweight ; ulb=ulb+(aweight*thesize)

ii=userlog_lines.statusat
userlog_lines.ii='Status: 'dl' 'ul' 'dlb' 'ulb' 'nowtime

if write_details=1 then do
    vv=userlog_lines.0+1
    userlog_lines.0=vv
    isdir2=upper(strip(translate(isdir,'/','\'),,'/')||'/')
    userlog_lines.vv='Upload ' thesize ' bytes to ' ufile ' '  time('n') date('n')
    userlog_lines.0=vv
end  /* Do */

/* save userlog file */
aa=filewrite(userfile,userlog_lines)
if aa=0 & verbose>0 then
  call pmprintf( " Could not augment&update BBS userfile: " userfile)


return ' '              
 


/* -------------------- */
/* Mail an alert to the administrator */
/* if here, a match occurred */
mail_alert:procedure expose servername admin_email verbose bbs_smtp_gateway
parse arg user,thefile,filelen

   adate=date('N') ;atime=time('N')
   CRLF = '0d0a'x
 

   asubject ='Subject: Notification of BBS Upload '

   themessage="Date: " || adate || ' ' ||atime
   themessage=themessage||crlf||'From: WebServer@'||servername
   themessage=themessage||crlf||asubject
   themessage=themessage||crlf||'To: '||admin_email||crlf

   themessage=themessage||crlf||'A file has been uploaded to the BBS at '||servername
   themessage=themessage||crlf||"    Date of occurrence: " || adate || ' ' ||atime
   themessage=themessage||crlf||'            From user: '|| user
   themessage=themessage||crlf||' Uploaded File saved to: '|| thefile
   themessage=themessage||crlf||'            File length: '||filelen
   themessage=themessage||crlf||crlf||'Optional message: '||themessage
 
   foo=sref_mailit(admin_email,themessage,bbs_smtp_gateway)
   if verbose>2 then call pmprintf(" BBS alert E-mail status: "foo)

   return foo

/*******************************************/
/* determine the upload directory */
fig_upload_dir:procedure expose user_header.
parse arg defup,origname,username

username=strip(strip(translate(username,'\','/'),'l','\'))

if user_header.!uploads=0 then do  /* just use defup */
    return defup||' '||1.0
end
/* check upload_dirs. First, if username=0 or ' ', then JUST CHECK
 DEFAULT "prefix" (we only use the "name" part of the "own file name" --
 so no point in looking for any other prefix */
 if username=0 | username=' ' then do
     prefix=''
 end
 else do
    im=pos('\',username)
    if im=0 then
         prefix=''
    else
         prefix=substr(username,1,im-1)
 end /* do */

 prefix=upper(Prefix)

/* search for a matching prefix */
 do iu=1 to user_header.!uploads
    if user_header.!upload_prefix.iu=prefix then do /* note use of * as flag */
           return '*'||user_header.!upload_dir.iu||' '||user_header.!upload_weight.iu
    end /* do */
    if user_header.!upload_prefix.iu='DEFAULT' then DO
          defup=user_header.!upload_Dir.iu||' '||user_header.!upload_weight.iu
    end /* do */
 end /* do */
 return defup||' '||1.0


/***********************************/
/* create a filename, check for * alias flag */
make_afile:procedure
parse arg pupdir,tryname

pupdir=strip(strip(translate(strip(pupdir),'\','/'),'t','\'))
tryname=strip(translate(strip(tryname),'\','/'))
if abbrev(pupdir,'*')=1 then do
   pupdir=substr(pupdir,2)
   im=pos('\',tryname) 
   if im>0 then
      tryname=substr(tryname,im+1)
end /* do */
usefile=strip(pupdir,'t','\')||'\'||strip(tryname,'l','\')
return usefile
