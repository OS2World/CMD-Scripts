/* 14 Jan 2000. Daniel Hellerstein (Danielh@econ.ag.gov)
   This is hereby released to the public domain.
  
  This is a simpele OS/2 REXX Cgi-bin script to process
  HTML uploads (a "multi-part/form" submission"). 
  It will save the file to an "upload" directory,
  and send a simple confirmation back to the client.

  The heart of this is the READ_MULTIPART_DATA procedure.
  You can use it in your own cgi-bin scripts.
 
  For an example of an HTML document that will invoke this
  form, see UPLOAD.HTM

  Note: You MUST set the UPLOAD_DIR parameter !!

*/

/***** Begin user configurable parameters ***/

/* Root of the upload directory -- use a fully qualified directory name */
upload_dir=''

/* Overwrite file it exists (1=yes,0=no) */
overwrite_allowed=1


/* a response file, used if succesful upload occured.
   Must be a fully qualified file name
   Leave this empty, or set it to 0, and a generic response will be used
   
  Notes:
     * the response file SHOULD be an html document.
     * all occurences of the string 
             <!-- UPLOAD_SIZE --> 
      will be replaced by the size of the file uploaded,
     * all occurences of the string
            <!-- UPLOAD_NAME --> 
       will be replaced by the name give to the uploaded file
*/
response_file=''

/***** End user configurable parameters ***/

foo=rxfuncquery('sysloadfuncs')
if foo=1 then do
  foo=RxFuncAdd( 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs')
  if foo=0 then do
     call SysLoadFuncs
  end
  else do
    say "Content-type: text/plain"
    say 
    say "Server error: rexxutil.dll was not found "
    exit
  end 
end
/* get the request method */
method = value("REQUEST_METHOD",,'os2environment')

if method='GET' then do
    list=value("QUERY_STRING",,'os2environment')
end
else do
   tlen = value("CONTENT_LENGTH",,'os2environment')
   list=charin(,,tlen) 
end 

/* Note: Multi-part form submissions MUST be POST */
notmulti=0
if method="GET" then do         /* so this is just the normal request line */
    notmulti=1
end 
else do
    conttype=value("CONTENT_TYPE",,'os2environment')     /* Is this a multipart/form-data */
    if abbrev(translate(conttype),'MULTIPART/FORM-DATA')=0 then notmulti=1
end


/* if not a multi-part form, return an error message */
if notmulti=1 then do
  say "Content-type: text/html "
  say 
  say "<html><head><title>Unable to upload file </title></head><body>"
  say "<h2>Unable to upload file</h2>"
  say "Sorry, your browser does not seem to support FORM based file upload "
  say "</body></html>"
  exit
end 


/* if here, a multi part form */ 
ndo=read_multipart_data(list,conttype)    /* this does the work . */
origname=''
callit=''
useentry=0


/* find the CALLIT and FILENAME variables -- 
   CALLIT contains the desired name
   FILENAME contains the original name */
do mm=1 to ndo
   elist=translate(strip(form_data.!list.mm))
   do until elist=''
       parse var elist aword elist
       select
          when aword='FILENAME' then do
            aword2='!'||aword
            avalue=strip(form_data.aword2.mm)
            origname=filespec('n',avalue)          
            useentry=mm
          end /* do */
          when aword="NAME" then do
            aword2='!'||aword
            avalue=strip(form_data.aword2.mm)
            if translate(value)='UPLOAD_FILE' then useentry=mm
            if translate(avalue)<>'CALLIT' then iterate
            callit=strip(form_data.mm)   /* get it's value from the "part" */
            if pos('\',callit)>0 then 
               callit=filespec('p',callit)||filespec('n',callit)
            else
               callit=filespec('n',callit)
          end
          otherwise nop
        end
   end                   /*elist */
end 


if callit<>'' then
  usename=callit
else
  usename=origname
usename=translate(usename,'\','/')
usename=strip(usename,,'\')

/* watch out for sneakys */
if pos('..',usename)<>0 then do
  say "<html><head><title>Bad filename </title></head><body>"
  say "The filename is unacceptable: "usename
  exit
end


if useentry=0 then do
  say "<html><head><title>No contents </title></head><body>"
  say "There are no contents in your upload request (nothing to save)"
  exit
end

say "Content-type: text/html "
say 

upload_dir=strip(upload_dir)
upload_dir=strip(upload_dir,,'\')

usename2=upload_dir'\'usename

usedir=filespec('d',usename2)||filespec('p',usename2)
if ais_dir(usedir)=0 then do
  say "<html><head><title>No such directory </title></head><body>"
  say "No such directory: "usedir
  exit
end

foo=stream(usename2,'c','query exists')
if foo<>'' then do
   if overwrite_allowed=0 then do
      say "<html><head><title>File exists</title></head><body>"
      say "A file with this name already exists: "usename2
      exit
   end
   else do
      foo=sysfiledelete(usename2)
  end 
end 


foo=stream(usename2,'c','open write')
if abbrev(translate(strip(foo)),'READY')<>1 then do
  say "<html><head><title>Unable to open file </title></head><body>"
  say "Unable to open file: "usename2
  exit
end
foo=charout(usename2,form_data.useentry,1)
if foo<>0 then do
  say "<html><head><title>Unable to write file </title></head><body>"
  say "Unable to write file: "usename2
  exit
end

foo=stream(usename2,'c','close')
ssize=stream(usename2,'c','query size')

/* use a response file? */
if response_file='' | response_file=0 then do      /*use generic response */
  say "<html><head><title>The parts </title></head><body>"
  say " Saving uploaded file to: "usename2
  say "<bR> # of bytes saved: "ssize
  say "</body></html>"
  exit
end

oldr=response_file
/* else, use a response file */
response_file=stream(response_file,'c','query exists')
if response_file=''  then do      /*use generic response */
  say "<html><head><title>The parts </title></head><body>"
  say " Saving uploaded file to: "usename2
  say "<bR> # of bytes saved: "ssize
  say "<hr><em>Note: response file was not found = "oldr
  say "</body></html>"
  exit
end

foo=stream(response_file,'c','open read')
if abbrev(translate(strip(foo)),'READY')<>1 then do    /* problem with response file */
  say "<html><head><title>The parts </title></head><body>"
  say " Saving uploaded file to: "usename2
  say "<bR> # of bytes saved: "ssize
  say "<hr><em>Note: response file could not be opened = "response_file
  say "</body></html>"
  exit
end

rsize=stream(response_file,'c','query size')
if rsize=0 | rsize='' then do
  say "<html><head><title>The parts </title></head><body>"
  say " Saving uploaded file to: "usename2
  say "<bR> # of bytes saved: "ssize
  say "<hr><em>Note: problem reading response file = "response_file
  say "</body></html>"
  exit
end

aresp=charin(response_file,1,rsize)
foo=stream(response_File,'c','close')
anew=''
do forever
   if aresp='' then leave
   parse var aresp a1 '<!-- ' ain '-->' aresp
   goo=strip(translate(ain))
   anew=anew||a1
   select
      when goo='UPLOAD_SIZE' then
          anew=anew||ssize
      when goo='UPLOAD_NAME' then
          anew=anew||usename2
      otherwise
          anew=anew||'<!--'||ain||'-->'
    end
end

call charout,anew
exit


exit


/* ---------------------------------- */
/* return 1 if adir is an existing (possibly empty) directory , 0 if not */
ais_dir:procedure 
parse arg adir
adir=strip(adir)
adir=strip(adir,'t','\')
nowdir=directory()
nowdrive=filespec('d',nowdir'\')
nowpath=filespec('p',nowdir'\')
adr=filespec('d',adir)
if adr='' then do
   if abbrev(adir,'\')=0 then 
       adir=nowdrive||nowpath||adir
   else
       adir=nowdrive||adir
end /* do */
foo=sysfiletree(adir,goo,'D')
if  goo.0>0  then return 1
return 0




/*************************************/
/* read data sent back by an html FORM declared with:
   enctype="multipart/form-data" method="POST"

Calling syntax:
   form_data.=''
   nentries=read_multipart(stuff,content_type)
where:
          stuff == the body of a POST request 
       nentries == the number of entries found. If error, nentries=0
and 
     form_data. == an "exposed" stem variable which will contain
                   variables extracted from the several parts of this
                   POSTed body.

The structure of FORM_DATA is:
 i) FORM_DATA.0 = # of parts (in this multipart submission)

ii) FORM_DATA.!list.j = space delimited list of "variable names" in part
                       j (j=1.. FORM_DATA.0)

iii) FORM_DATA.!avar.j = value of the "avar" variable from the jth part;
                         where avar is one of the "variable names" contained
                         in FORM_DATA.!list.j

iv)  FORM_DATA.j       = the value of the part

That is:
   *  For each word in FORM_DATA.!list.j, there is a FORM_DATA. tail.
     Thus, 
        if FORM_DATA.!list.2='FILENAME  NAME'
     then
         FORM_DATA.!FILENAME.2 = the value of the  "FILENAME" variable from the
                               "2nd" part of this requeset
         FORM_DATA.!NAME.2 = the value of the  "NAME" variable from the
                               "2nd" part of this request
      and
         FORM_DATA.2   = the value of this "part"


I almost all cases, the only "word" will "NAME", which will be
the "xxx" from a name="xxx" attribute of an <INPUT > element in
an HTML form.

You may also see a FILENAME word, which is the filename (on the
client's machine) of a file uploaded using a
   <INPUT TYPE="file"  name="a_filename">
element.


Notes:
    * if an error occurs, a 0 is returmed, and FORM_DATA.!ERROR
      will contain an error message
    * a content-disposition entry, if found, is NOT included in FORM_DATA


*/
read_multipart_data:procedure expose form_data.
parse arg abody,atype

drop form_data.

crlf='0d0a'x

/* is there a content-type request header ? */
if atype="" then do
   form_data.!error=" No  content-type  request header"
   return 0
end

parse var atype thetype ";" boog 'boundary=' abound    /* get the type */

if translate(thetype)<>"MULTIPART/FORM-DATA" then do
  form_data.!error="No  multipart/form-data in Content-type "
  return 0
end

if translate(thetype)<>"MULTIPART/FORM-DATA" then do
  form_data.!error=" BlendGif upload error: No boundary in multipart/form-data header "
  return 0
end

abound="--"||abound   /* since boundaries always start with -- */

abd2=abound||crlf
/* loop through message, pulling out blocks and storing in stem var bigstuff. */

/* Now parse the various parts.*/

parse var abody foo1 (abd2) abody    /* move beyond first boundary and it's crlf */
/* check for netscape 2.0 incorrect format */
if pos(abound,abody)=0 then do   /* no ending boundary, so add one */
   abody=abody||crlf||abound||" -- "
end

mm=0
do until abody=""
  parse var abody thestuff (abound) abody        /* get a  boundary defined block */
  if strip(left(thestuff,4))="--" then leave        /* -- signals no more */
  if abody="" then leave
  mm=mm+1
  form_data.!list.mm='' ; form_data.mm=''
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
              if t1="CONTENT-DISPOSITION" then iterate /* don't bother retaining this */
              form_data.!list.mm=form_data.!list.mm' 't1
              nm1='!'||t1
              form_data.nm1.mm=t2
          end     /* exract arguments */
     end        /* extract args on this line */
  end                    /* get a line */
  if thestuff<>"" then do
    form_data.mm=left(thestuff,length(thestuff)-2)  /* strip off ending crlf */
    parse var abody foo (crlf) abody   /* jump past extra crlf */
  end
  else do
     form_data.body.mm=""
  end
end

return mm


