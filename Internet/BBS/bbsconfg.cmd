/* configure the BBS.INI file */


parse arg  ddir, tempfile, reqstrg,list,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir

/*if verb="" then do
   say " This SRE-http add-on is NOT meant to be run from the command line."
   exit
end  /* Do */
*/

/* chekc for needed_privs superuser */
if wordpos('SUPERUSER',upper(privset))=0 then do
    'header add WWW-Authenticate: Basic Realm=<BBS>'  /* challenge */
     return sref_response('unauth', "You do not have Superuser privileges ",tempfile,servername)
end

if list<>"" then do
    call setme
   return 0
end  /* Do */


knowns='FILE_DIR BBS_LOGON_FILE '
knowns=knowns||' BBS_PARAM_DIR USERLOG_DIR INCOMING_DIR BBSCACHE_DIR  IMAGEPATH '
KNOWNS=KNOWNS||' HEADER_FILE FOOTER_FILE ZIP_HEADER_FILE DESCRIPTION_FILE EXCLUSION_FILE '
knowns=knowns||' INCLUSION_MODE_FILE  '
KNOWNS=KNOWNS||' CACHE_FILES CACHE_DURATION CACHE_CHECK UPLOAD_MAXSIZE UPLOAD_MINFREE '
KNOWNS=KNOWNS||' HEADER_TEXT FOOTER_TEXT DESCRIPTION_TEXT DESCRIPTION_TEXT_LENGTH '
KNOWNS=KNOWNS||' DESCRIPTION_TEXT_LENGTH_1LINE AUTO_DESCRIBE ZIP_DESCRIPTOR_FILE '
knowns=knowns||' GET_Z_ZIP_DESCRIPTION '
knowns=knowns||' OWN_UPLOAD_DIR OWN_DOWNLOAD_DIR OWN_DOWNLOAD_FLAG '
KNOWNS=KNOWNS||' TABLE_BORDER DEF_BIN_TEXT_LINKS CELL_SPACING USE_COOKIES DEFAULT_DESCRIPTION DEFAULT_DESCRIPTION_DIR '
KNOWNS=KNOWNS||' DEFAULT_DATEFMT DEFAULT_SORT_BY CONTINUATION_FLAG WRITE_DETAILS UPLOAD_QUICK_CHECK '
KNOWNS=KNOWNS||' DEFAULT_RATIO DEFAULT_BYTE_RATIO BYTES_NEWUSER FILES_NEWUSER MUST_WAIT '
KNOWNS=KNOWNS||' OWN_NAME_PRIVILEGE USE_SERVERNAME BBS_SMTP_GATEWAY ADMIN_EMAIL SEND_ALERT '

oldwas=knowns

nochangers=' '
lastmod=' '


/* sets */
set.1='FILE_DIR BBS_PARAM_DIR USERLOG_DIR INCOMING_DIR BBSCACHE_DIR IMAGEPATH '
setmess.1='BBS Directories '

set.2='BBS_LOGON_FILE HEADER_FILE FOOTER_FILE ZIP_HEADER_FILE DESCRIPTION_FILE EXCLUSION_FILE INCLUSION_MODE_FILE ZIP_DESCRIPTOR_FILE'
setmess.2='BBS Files (generic and/or directory specific) '

/* cache stuff */
set.3='CACHE_FILES CACHE_DURATION CACHE_CHECK '
setmess.3=' BBS Cache Parameters '

/* descrription modifiers */
set.4='HEADER_TEXT FOOTER_TEXT DESCRIPTION_TEXT DESCRIPTION_TEXT_LENGTH  DESCRIPTION_TEXT_LENGTH_1LINE '
set.4=set.4||' AUTO_DESCRIBE  GET_Z_ZIP_DESCRIPTION DEFAULT_DESCRIPTION DEFAULT_DESCRIPTION_DIR '
setmess.4=' File Description Modifiers '

/* other display modifiers */
set.5='DEFAULT_DATEFMT DEFAULT_SORT_BY USE_SERVERNAME TABLE_BORDER CELL_SPACING DEF_BIN_TEXT_LINKS '
setmess.5=' Other display modifiers '
/* upload stuff */
set.6='UPLOAD_MAXSIZE UPLOAD_MINFREE UPLOAD_QUICK_CHECK  OWN_UPLOAD_DIR OWN_DOWNLOAD_DIR OWN_DOWNLOAD_FLAG '
setmess.6=' Upload/Download Parameters '

/* privileges and ratios */
set.7='DEFAULT_RATIO DEFAULT_BYTE_RATIO BYTES_NEWUSER FILES_NEWUSER MUST_WAIT OWN_NAME_PRIVILEGE '
setmess.7='BBS Privileges and Ratios '

/* email alert stuff */
set.8='BBS_SMTP_GATEWAY ADMIN_EMAIL SEND_ALERT '
setmess.8=' E-mail Parameters '

/* miscellaneious */
/* 'USE_COOKIES WRITE_DETAILS CONTINUATION_FLAG  ' */
setmess.9='Miscellaneous '

do io=1 to 9
   set.io.!list=' '
end /* do */

 call lineout tempfile, "<html><head><title>SRE-http: Configure BBS  </title>"
 call lineout tempfile, "</head><body>"
 call lineout tempfile,' <h1>Configure BBS </h1> <hr>'


 bbsini=strip(basedir,'t','\')'\bbs.ini'
 getem=fileread(bbsini,blines,,'E')
 if blines.0=0 then do
      call lineout tempfile,' <h2>Error in BBS configurator </h2> <hr>'
      call lineout tempfile, ' BBS initialization file (' bbsini ') could not be found '
      call lineout tempfile,'</body></html>'
      call lineout tempfile
     'FILE ERASE TYPE text/html NAME' tempfile
      return 'Error in BBS configurator '
 end  /* Do */

/* rules:
start with /* or empty line -- is a comment line
end with */ --- strip out ending comment (and retain)
otherwise, check variable name. If not in "to do list", treat as a comment
*/

do mm=1 to BLINES.0
   aline=strip(blines.mm)
   ALINE=REPLACESTRG(ALINE,'<','&lt;','ALL')
   ALINE=REPLACESTRG(ALINE,'>','&gt;','ALL')

   todo.mm.!extra=' '
   if abbrev(aline,'/*')=1 | aline=' ' then do
        t2a=REPLACESTRG(aline,'"','&quot;','ALL')
        todo.mm.!value=t2a
        todo.mm.!var=0
        iterate
    end

/* not a comment. Read the variable, and it's own comment at end of line */
    itis=aline
    if right(aline,2)='*/' then do              /* strip out ending comment */
       foo2=lastpos('/*',aline)
       if foo2>0 then do             /* found comment start */
               itis=left(aline,foo2-1)
               t2a=substr(aline,foo2)
               t2a=REPLACESTRG(t2a,'"','&quot;','ALL')
               todo.mm.!extra=t2a
       end  /* Do */
     end
     parse var itis t1 '=' t2
     t1=upper(strip(t1))

/* is it the LAST_MODIFIED parameter */
    if t1="LAST_MODIFIED" then do
        todo.mm.!var=-1
        todo.mm.!value=' '
        lastmod=translate(t2,' ','2227'x)
        iterate   /*then skip it */
     end

/* is it one of the known parameters? */
     IT1=WORDPOS(T1,KNOWNS)
     IF IT1=0 then DO
       nochangers=nochangers' 't1
       t2a=REPLACESTRG(aline,'"','&quot;','ALL')
       todo.mm.!value=t2a
       todo.mm.!var=0
       iterate
     end  /* Do */

     it1=wordpos(t1,oldwas)
     oldwas=delword(oldwas,it1,1)
     t2=strip(t2) ; t2a=t2
     if abbrev(t2,'"')=1 then 
        t2a=strip(t2,,'"')
      if abbrev(t2,"'")=1 then
        t2a=strip(t2,,"'")
     t1=strip(upper(t1))
     todo.mm.!var=t1
     t2a=REPLACESTRG(T2A,'"','&quot;','ALL')
     todo.mm.!value=t2a

/* assign to a set ? */
     iu2=0
     do iu=1 to 8
          iu2=wordpos(t1,set.iu)
          if iu2>0 then do
             set.iu.!list=set.iu.!list||' '||mm
             leave
          end  /* Do */
     end /* do */
     if iu2=0 then set.9.!list=set.9.!list||' '||mm

 end /* do */

call lineout tempfile,' <h3> Modifying parameters in ' bbsini ' </h3>'
call lineout tempfile,' With this FORM you can change most of the parameters in the  BBS initialization file. <br>'
call lineout tempfile,' For a detailed description of these parameters, see <a href="/bbs.doc">BBS.DOC </a><p>'
if lastmod<>' ' then
  call lineout tempfile,' <p> Note: BBS.INI last modified on ' lastmod
call lineout tempfile,' <FORM ACTION="/bbsconfg" METHOD="POST"> '


do ii=1 to blines.0             /* dump comments */
   if todo.ii.!var=0 | todo.ii.!var=-1 then do
       call lineout tempfile,' <INPUT TYPE="hidden" NAME="var.'ii'" value='todo.ii.!var' >'
       call lineout tempfile,' <INPUT TYPE="hidden" NAME="value.'ii'"  VALUE="'todo.ii.!value'"  >'
       call lineout tempfile,' <INPUT TYPE="hidden" NAME="extra.'ii'"  VALUE=""  >'
   end
end

do iset=1 to 9
  islist=strip(set.iset.!list)
  call lineout tempfile,'<h3> ' setmess.iset ' </h3> '
  call lineout tempfile,' <dl> '
  do inset=1 to words(islist)
    ii=strip(word(islist,inset))
    call lineout tempfile,' <INPUT TYPE="hidden" NAME="var.'ii'" value="'todo.ii.!var'" >'
    call lineout tempfile,' <dt> ' todo.ii.!var  ' =  '
    call lineout tempfile,'  <INPUT TYPE="text" NAME="value.'ii'"  VALUE="'todo.ii.!value'" SIZE=30 MAXLENGTH=80 >'
    adesc=strip(todo.ii.!extra)
    if pos('/*',adesc) >0 then
           adesc=substr(delstr(adesc,length(adesc)-1),3)
     call lineout tempfile,' <dd> ' adesc ' <br>'
     call lineout tempfile,' <INPUT TYPE="hidden" NAME="extra.'ii'"  VALUE="'todo.ii.!extra'"  >'
   end
   call lineout tempfile,' </dl> '
end /* do */
call lineout tempfile,' <INPUT TYPE="submit" VALUE="submit">  '
call lineout tempfile,' <INPUT TYPE="hidden" NAME="SETME" value='blines.0' >'
call lineout tempfile,' </form>'

call lineout tempfile,' <p>'
call lineout tempfile,' Notes: <ul> '
call lineout tempfile,'<li> The following parameters were <b>not</b> set: <blockquote>' nochangers
call lineout tempfile,' </blockquote> To change them, you will have to edit 'bbsini '<br>'

if oldwas<>' ' then do
  call lineout tempfile,' <li> The following parameters should have been, but were <b>not</b>, found in ' bbsini ' <blockquote>'
  call lineout tempfile, oldwas
  call lineout tempfile,'</blockquote>'
end
call lineout tempfile,' </ul>'
call lineout tempfile,'</body></html>'
call lineout tempfile
'FILE ERASE TYPE text/html NAME' tempfile
return 'BBS configurator sent form'


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


/***********************/
/* Jump here to write results */
setme:
if pos('SETME',list)=0 then do
 call lineout tempfile, "<html><head><title>SRE-http: Configure BBS  </title>"
 call lineout tempfile, "</head><body>"
 call lineout tempfile,' <h2>Configure BBS </h2>'
 call lineout tempfile,' Error: incorrect information. ' 
 call lineout tempfile,'</body></html>'
 call lineout tempfile
 'FILE ERASE TYPE text/html NAME' tempfile
 return 0
end

 call lineout tempfile, "<html><head><title>SRE-http: Configure BBS  </title>"
 call lineout tempfile, "</head><body>"
 call lineout tempfile,' <h2>Configure BBS </h2>'

do until list=""
   parse var list a1 '&' list
   parse var  a1 avar '=' aval
   if avar='SETME' then do
        ndo=aval
        iterate
   end  /* Do */
   avar=strip(upper(avar))
   aval=translate(aval,' ','+')
   aval=packur(aval)
   ack='!'||avar
   stuff.ack=aval
end /* do */

call lineout tempfile,' <h3> BBS initialization file has been modified </h3>'

/* rename old bbs.ini file */
 bbsini=strip(basedir,'t','\')'\bbs.ini'
 aa=stream(bbsini,'c','query exists')
 if aa<>"" then do
      newn=dostempname(strip(basedir,'t','\')'\bbsINI.???')
      foo=dosrename(bbsini,newn)
      if foo=1 then
         call lineout tempfile,' Old BBS.INI file has been moved to ' newn
      else
         call lineout tempfile,' Old BBS.INI could <b>not</b> be renamed '
 end  /* Do */
 else do
         call lineout tempfile,' Creating BBS.INI '
 end  /* Do */
 getem=fileread(bbsini,blines,,'E')    
 
mm2=0
do mm=1 to ndo
   if stuff.!var.mm=-1  then iterate
   mm2=mm2+1
   if stuff.!var.mm=0 then do
      newl.mm2=stuff.!value.mm
      iterate
   end
   if datatype(stuff.!value.mm)="NUM"then
      newl.mm2=stuff.!var.mm '=' stuff.!value.mm' ' stuff.!extra.mm
  else
      newl.mm2=stuff.!var.mm "='"||stuff.!value.mm||"' " stuff.!extra.mm

end /* do */
mm2=mm2+1
newl.mm2="LAST_MODIFIED='" time('n')' ' date('n') "'"

newl.0=mm2
foo=filewrite(bbsini,newl)
call lineout tempfile
'FILE ERASE TYPE text/html NAME' tempfile

return 0

