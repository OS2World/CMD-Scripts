/*  BBS add-on for the SRE-http http server: version 1.02
       This is the    new user registration  facility.
    See BBS.CMD for download,
    and BBSUP.CMD for upload support.

This uses the BBS.INI file. 
*/

parse arg  ddir, tempfile, reqstrg,list,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir 

if verb="" then do
   say " This is an add-on for the SRE-http web server. "
   say " It is NOT meant be run from the command line! "
   exit
end  /* Do */


basedir=strip(basedir,'t','\')
inifile=strip(basedir,'t','\')||'\bbs.ini'
isit=fileread(inifile,inilines,,'E')
if isit<0 then do
     say " ERROR: no BBS initialization file "
     foo=responsebbs('forbid','BBS new user registration is unavailable')
     return foo||' Error in BBS parameters file (bbsnewu) '
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
   bbsdir=basedir||'\'bbs_param||'\'
else
   bbsdir=strip(bbs_param,'t','\')'\'

userlog_dir=translate(userlog_dir,'\','/')
if abbrev(strip(userlog_dir,'l','\'),'\')=0 & pos(':',userlog_dir)=0 then /* must be relative dir*/
   userlog_dir=bbsdir||userlog_dir||'\'
else
   userlog_dir=strip(userlog_dir,'t','\')'\'

reqratio=default_ratio||' '||default_byte_ratio


/* check on own_download_dir and own_upload_dir */
if symbol('own_download_dir')<>'VAR' | own_download_dir=0 then do
   own_download_dir=' '
end
else do
 own_load_dir=translate(strip(own_download_dir),'\','/')
 own_download_dir=strip(own_download_dir,'t','\')
 if dosisdir(own_download_dir)=0 then do
     say " Could not find own_download_dir : " own_download_dir
     own_download_dir=' '
 end
end

if symbol('own_upload_dir')<>'VAR' | own_upload_dir=0 then do
   own_upload_dir=' '
end
else do
 own_upload_dir=translate(strip(own_upload_dir),'\','/')
 own_upload_dir=strip(own_upload_dir,'t','\')
 if dosisdir(own_upload_dir)=0 then  do
     say " Could not find own_upload_dir : " own_upload_dir
     own_upload_dir=' '
 end
end

if symbol('Own_flag')<>' ' then
    own_flag='PERSONAL'


/* parse the input list, but initialize values first */
reqargs='USER PWD PWD2 REALNAME EMAIL HELLO '
do mm=1 to words(reqargs)
   aw='!'||strip(word(reqargs,mm))
   arglist.aw=' '
end
/* note:there may be several other optional fields */
allargs=""

/* now pull out options */
do until list=""
       parse var list anarg '&' list
       parse var anarg avar '=' aval ; avar=upper(avar)
       foo1='!'||avar
       arglist.foo1=packur(translate(aval,' ','+'))
       if wordpos(avar,reqargs)=0 then
          allargs=allargs' 'avar
end /* do */

/* Check for errors */
  select 
    when arglist.!user=' ' then damess="You did not enter a username "
    when abbrev(arglist.!user,'!')=1 then damess="You can not use ! in a username" 
    when arglist.!pwd=' ' then damess="You did not enter a password "
    when arglist.!pwd2<>arglist.!pwd then damess="Password verification failed "
    when arglist.!realname=' ' then damess="You did not enter your real name"
    when arglist.!email=' ' then damess="You did not enter your e-mail address"
    when pos('@',arglist.!email)=0 then damess="Error in e-mail address (no @ found) "
    otherwise damess=' '
  end  /* Do */
  if damess<>' ' then do
    call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
    call lineout tempfile, "<html><head><title>Error in BBS Registration Form</title></head>"
    call lineout tempfile, "<body><h2>Error in BBS Registration</h2>"
    call lineout tempfile,damess
    call lineout tempfile, "</body></html>"
    call lineout tempfile  /* close */
    'FILE ERASE TYPE text/html NAME' tempfile
    return 'Bad BBS registration form '
  end

/* basic checks are done. See if this user exists */

tryit=userlog_dir||arglist.!user||'.IN'
wow=stream(tryit,'c','query exists')
if wow<>' ' | upper(arglist.!user)='USER' then do
    call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
    call lineout tempfile, "<html><head><title>Problem with BBS Registration</title></head>"
    call lineout tempfile, "<body><h2>Problem with BBS Registration</h2>"
    call lineout tempfile,' The user-name you selected, <b> ' arglist.!user ','
    call lineout tempfile,' </b> is not available. Please select a different user-name '
    call lineout tempfile, "</body></html>"
    call lineout tempfile  /* close */
    'FILE ERASE TYPE text/html NAME' tempfile
     return 'BBS Registration disallowed: existing username '
end


/* write the user stuff */
ll.1='; User file for : ' arglist.!user
ll.2='Status: 0 0 0 0 0 '
ll.3='User: ' arglist.!user ' ' arglist.!pwd
ll.4='Privileges:  NEWUSER '
ll.5='Name: ' arglist.!realname
ll.6='Email: ' arglist.!email
ll.7='Ratio : ' reqratio
i7=7
if own_download_dir<>' ' then do
  atmp=own_download_dir||'\'||arglist.!user
  foo=dosmakedir(atmp)
  if foo<>0 then do
     say " Created own_download_directory: " atmp
     i7=i7+1
     ll.i7='Download_dir: '||own_flag||' '||STRIP(own_download_dir)||'\'||STRIP(arglist.!user)
  end
  else do
     say " Could not create own_download_directory: " atmp
  end  /* Do */

end
if own_upload_dir<>' ' then do
  atmp=own_upload_dir||'\'||STRIP(arglist.!user)
  foo=dosmakedir(atmp)
  if foo<>0 then do
     say " Created own_upload_directory: " atmp
     i7=i7+1
     ll.i7='Upload_dir: '||own_flag||' '||STRIP(own_upload_dir)||'\'||arglist.!user
  end
  else do
     say " Could not create own_upload_directory: " atmp
  end  /* Do */
end


if allargs<>' ' then do
  do jj=1 to words(allargs)
     oop0=word(allargs,jj) ; oop='!'||oop0
     oop2=arglist.oop
     jj2=jj+i7
     ll.jj2=oop0':' oop2
  end
end
jj2=jj2+1
ll.jj2=';'
jj2=jj2+1
ll.jj2='Messages:'
ll.0=jj2

foo=filewrite(tryit,ll)
if foo=0  then do
     say " ERROR: problem initializing user file "
     foo=responsebbs('forbid','BBS new user registration is unavailable')
     return foo||' Error in BBS users file ' tryit
end  /* Do */

/* generic response if no response file given */
if arglist.!hello=' ' then do
    call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
    call lineout tempfile, "<html><head><title>BBS Registration</title></head>"
    call lineout tempfile, "<body><h2>BBS Registration was Successful </h2>"
    call lineout tempfile,' You have successfully registered. '
    call lineout tempfile, "</body></html>"
    call lineout tempfile  /* close */
end
else do
   serverport=extract('serverport')
   sel='http://'||servername
   if serverport<>80 then sel=sel||':'||serverport
    sel=sel||'/'||strip(arglist.!hello,'l','/')
   'RESPONSE HTTP/1.0 302 Moved Temporarily'  /* Set HTTP response line */
    call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 2.0//EN">'
    call lineout tempfile, "<html><head><title>Successful BBS Registration</title></head>"
   'HEADER ADD Location:' sel
    call lineout tempfile, "<body><h2>Successful BBS Registration<</h2>"
    call lineout tempfile, 'You can go to the BBS <a href="'sel'">now<a>.'
    call lineout tempfile, "</body></html>"
   call lineout tempfile  /* close */
end

'FILE ERASE TYPE text/html NAME' tempfile
 

return 'BBS  new user registration was successful '




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
    when request='forbid' then
      call lineout tempfile,' BBS is unavailable.'
    otherwise
       call lineout tempfile,' Request denied: ' stuff
  end
  call lineout tempfile, "</body></html>"
  call lineout tempfile  /* close */


  iia=dosdir(tempfile,'s')
  'FILE ERASE TYPE text/html NAME' tempfile
 


  return word(use,1)||' '||iia




