/* 24 March 1999. Daniel Hellerstein (Danielh@econ.ag.gov)
   This is hereby released to the public domain.

  SImple OS/2 REXX Cgi-bin script to process
  HTML uploads (a "multi-part/form" submission"). 
  It will echo back the "parts" submitted (i.e.; the
  file that was uploaded)

  The heart of this is the READ_MULTIPART_DATA procedure.
  Use it in your own cgi-bin scripts.
 
  For an example of an HTML document that will invoke this
  form, see the bottom of this file

*/

/* get the request method */
method = value("REQUEST_METHOD",,'os2environment')
if method='GET' then do
    list=value("QUERY_STRING",,'os2environment')
end
else do
   tlen = value("CONTENT_LENGTH",,'os2environment')
   list=charin(,,tlen)
end /* do */


/* Note: Multi-part form submissions MUST be POST */
notmulti=0
if method="GET" then do         /* so this is just the normal request line */
    notmulti=1
end 
else do
    conttype=value("CONTENT_TYPE",,'os2environment')     /* Is this a multipart/form-data */
    if abbrev(translate(conttype),'MULTIPART/FORM-DATA')=0 then notmulti=1
end


say "Content-type: text/html "
say 
say "<html><head><title>The parts </title></head><body>"
say "<PRE>"
say " Length of submission: " length(list)
say " Content-type: " ||word(conttype,1)
say 

/* not a multipart form */
if notmult=1  then do
   do forever 
       parse var list a1 '&' list
       parse var a1 a1a '=' a1b
       say "Variable "a1a " === " a1b
       exit
   end /* do */
end /* do */

/* if here, a multi part form */ 

n=read_multipart_data(list,conttype)    /* this does the work . */
say "# of parts= " n
say "</pre> <ol>"

/* now just echo the "parts" back to the client */
say 
do mm=1 to n
   elist=translate(strip(form_data.!list.mm))
   say "<li> Vars in part "mm' = ' elist
   say "<menu>"
   do until elist=''
       parse var elist aword elist
       aword2='!'||aword
       avalue=form_data.aword2.mm
       say "<li>  " aword " == <tt> " avalue '</tt>'
   end
   say "</menu><b><br>Part Value: </b><blockquote><pre>"
   call charout, form_data.mm
   say "</pre></blockquote>"
end
say "</ol></body></html>"

exit


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


/******************************************************************/
/* --- Example of FORM that will upload a file to this script */

/* 
<html>
 <head>
    <title>Demo of CGI-bin read of uploaded data </title>
</head>
<body>

This demonstrates the UPCGI.CMD cgi-bin script. <p>

<FORM enctype="multipart/form-data" ACTION="/cgi-bin/upcgi" METHOD="post">
    What do you want to call the serve to call this file:
       <input type="text" name="callit" size=20>

   <p><input type="checkbox" name="OPTION1" value="YES">Say YES to option1? 

   <p>Select the file to upload:<INPUT TYPE="file"  name="upload_file">

   <p><INPUT TYPE="submit" VALUE="send file">
</form>
</body></html>

*/


