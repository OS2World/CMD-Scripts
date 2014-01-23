/* Examine and traverse the links to URLs in a web tree.
  Uses "linkage" files created by CHEKLINK
*/

/***  BEGIN USER CONFIGURABLE PARAMETERS     */

/* used in <BODY back_1> element */
back_1='bgcolor="#ddaaff"  '

/*  Directory containing link file -- MUST be the same as in CHEKLINK.CMD */
linkfile_dir=' '

/* URL pointing to cheklink.htm (used for a "do it again" option)
   set cheklink_htm='' to not include this option.
   Should be fully qualified */
cheklink_htm='/cheklink.htm'


/* A fully qualified file containing "header" information.
  If ='', then a generic header is used 
  If specified, the file MUST contain at least:
       <HTML><HEAD>.... </HEAD> <BODY ...> <h1>... </h1> 
  Note: use of user_intro1  means that back_1 is NOT used 
*/
user_intro1=''

/***  END USER CONFIGURABLE PARAMETERS     */


parse arg  ddir, tempfile, reqstrg,list,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir,aparam,semqueue,prog_file

crlf='0d0a'x
ny.0='NO' ; ny.1='YES'
nas.1=' no -- server not available '
nas.2=' no -- no such resource on server'
nas.3='unknown -- siteonly violation'
nas.4='reserved'
nas.5='unknown -- excluded URL '

call load       /* some dlls */

/* check for CGI-BIN call */
is_cgi=0
if verb="" then do    /* is it cgi-bin? */
   method = value("REQUEST_METHOD",,'os2environment')
   if method="" then do
     say "This WWW oriented program is not meant to be run in standalone mode "
     exit
   end  /* Not addon, not cgi check */

   is_cgi=1                     /* cgi-bin! */
   if method='GET' then do
          list=value("QUERY_STRING",,'os2environment')
   end
   else do
         tlen = value("CONTENT_LENGTH",,'os2environment')
         list=charin(,,tlen)
   end /* do */                         
   servername=value("SERVER_NAME",,'os2environment')
   chlink='/CGI-BIN/CHEKLNK2.CMD'
   say 'Content-Type: text/html'
   say ""
end
else do
   if verb='GET' then parse var uri . '?' list
   chlink='/CHEKLNK2'
   fixexpire=value(enmadd||'FIX_EXPIRE',,'os2environment')
   if fixexpire>0 then  fpp=sref_expire_response(fixexpire,0)
end

listori=list

linkfile='*'
entrynum=1
isimg=0
listmode=0
via=''
checkmime='*'

do until list=''
   parse var list a1 '&' list
   parse var a1 avar '=' aval ; avar=translate(avar)
   aaval=packur2(translate(aval,' ','+'))
   select
     when avar='LINKFILE' then linkfile=aaval
     when avar='ENTRYNUM' then entrynum=aaval
     when avar='ISIMG' then isimg=aaval
     when avar='VIA' then via=aaval
     when avar='LIST' then listmode=aaval
     when avar='MIME' then checkmime=strip(aaval)
     otherwise nop
   end
end


if entrynum='' then entrynum=1

if datatype(entrynum)<>'NUM'   then do
    return ' String Bad Entry number ' entrynum
end 

if linkfile_dir=0 then linkfile_dir=''
if linkfile_dir='' then linkfile_dir=value('TEMP',,'os2environment')
lfile=strip(linkfile_dir,'t','\')||'\'||strip(linkfile,'l','\')
if pos('.',lfile)=0 then lfile=lfile'.STM'

if pos('*',lfile)>0 then do  
   call list_linkfiles
   return 2
end /* do */


/* else, read/display the requested linkfile */

oo=cvread(lfile,bg)

if oo=0 then do
    if is_cgi=0 then
       'string No such link-file: ' lfile
    else
       say 'No such link-file: ' lfile
   return 0
end

yow2=cvcopy(bg.!hrefs,hrefs)
yow2=cvcopy(bg.!imgs,imgs)

/* Make an index ? */
if entrynum=0 | listmode>0 then do
    if listmode=3 then
        call list_all
    else
        call make_index entrynum
    return 1
end 


/* not an index -- examine one url in this web tree */
if isimg=1 then do
   if entrynum>imgs.0 then do
         if is_cgi=0 then
            'string Image entry number 'entrynum ' > # of entries  ('imgs.0 ')'
         else
            say 'Image entry number 'entrynum ' > # of entries  ('imgs.0 ')'
        return 0
   end /* do */
end
else do
  if entrynum>hrefs.0 then do
     if is_cgi=0 then
        'string Anchor entry number ' entrynum ' > # of entries (' hrefs.0 ')'
     else
        say 'Anchor entry number ' entrynum ' > # of entries (' hrefs.0 ')'
     return 0
  end /* do */
end /* do */


outit=''
if user_intro1<>'' then do
  afil=stream(user_intro1,'c','query exists')
  if afil<>'' then do
     foo=stream(afil,'c','open read')
     outit=charin(afil,1,chars(afil))
     foo=stream(afil,'c','close')
  end
end

if outit='' then        /* the generic intro */
  outit='<html><head><title>CheckLink: Links Report </title></head><body ' back_1'> 'crlf 

outit=outit||make_topbar(entrynum,chlink,linkfile,listmode)'<p>'

outit=outit||'<h2 align=center> CheckLink: Examine and Traverse a Web-Tree </h2>' crlf 
if via<>'' then do
    if via<0 then do 
        via=abs(via)
        iimg=1; yoiks=imgs.via
    end /* do */
    else do
        iimg=0 ; yoiks=hrefs.via
    end
    via='<a href="'chlink'?linkfile='linkfile'&isimg='iimg'&entrynum='via'">'yoiks'</a>'
    outit=outit||'<font size=-1><center>... via 'via'</center></font> ' crlf
end /* do */


if symbol('HREFS.!NAME')<>'VAR' then do             /* name of this webtree */
   a1=hrefs.1
   parse var a1 . '//' sname '/' rname
   treename='Starting at /'rname ' on  ' sname
end /* do */
else do
   treename=hrefs.!name     
end
outit=outit||' <b>Name of webtree:</b> <tt>' treename '</tt>' crlf
if entrynum=1  then outit=outit'<br>This URL is the <em>starter-URL</em> (the root) of the <b>web-tree</b>!'

if isimg=0 then do
   call as_anchor
end                         /* not an image */
else  do               /* an image */
  call as_image
end

outit=outit||crlf||make_bottombar(entrynum,chlink,linkfile,listmode)'<p>'

outit=outit||'</body></html> 'crlf

call govar is_cgi

return 1


/* img fields
.n and .n.!  APPEARIN NREFS SIZE TYPE */

/* .n and .n.! APPEARIN  IMGLIST   NLINKS   NREFS
               QUERIED   SIZE      TYPE     REFLIST
*/


/******************/
/* make a link bar for top of document */
make_topbar:procedure expose cheklink_htm is_cgi
parse arg entrynum,chlink,linkfile,lmode,other
crlf='0d0a'x
 
 /*  lmode=2 : doing= from links
   lmode=0, entrynum>0 :  doing=synopsis 
   lmode=1  : doing=to links
   lmode=0, entrynum=1 :  Root url
   lmode=1 or 2 , entrynum=0 : doing=all htmls
   lmode=3 : doing = all urls
*/

select
   when lmode=0 & entrynum>0 then doing=2
   when (lmode>0 & lmode<3) & entrynum=0 then doing=4
   when lmode=1 then doing=3 
   when lmode=2 then doing=1
   when lmode=3 then doing=5
   otherwise doing=0
end  /* select */


outit=crlf

if doing<>1 & doing<>4 & doing<>5 then
  outit=outit||'<a href="'chlink'?list=2&linkfile='linkfile'&entrynum='entrynum'"> ',
              'HTML Documents that point here </a> || ' crlf
else 
  outit=outit||'HTML Documents that point here || ' crlf


if doing<>2 & doing<>4 & doing <> 5 then
  outit=outit||'<a href="'chlink'?linkfile='linkfile'&entrynum='entrynum'"> ',
              'Synopsis </a> || ' crlf
else
  outit=outit||' Synopsis ||'crlf

if doing<>3 & doing<>4 & doing<>5 then
  outit=outit||'<a href="'chlink'?list=1&linkfile='linkfile'&entrynum='entrynum'"> ',
              'Links contained in this document </a>   ' crlf
else
  outit=outit||' Links contained in this document ' crlf


outit=outit||'&nbsp; || &nbsp; <a href="#more">more...</a>'

return outit||other

/*****************/
/* make a link bar for bottom of document */
make_bottombar:procedure expose cheklink_htm hrefs.  is_cgi
parse arg entrynum,chlink,linkfile,lmode,other
crlf='0d0a'x

outit=''
if lmode=1 | lmode=2 then do
  outit='<hr width=50%>'
  if symbol('HREFS.'entrynum'.!TITLE')<>'VAR'  then
         atit=''
   else
        atit=hrefs.entrynum.!title

   if symbol('HREFS.'entrynum'.!DESCRIP')<>'VAR' then
         adescrip=' '
   else
        adescrip=hrefs.entrynum.!descrip

   if atit<>'' | adescrip<>'' then do
     outit=outit||'<menu>For <u>' hrefs.entrynum'</u><br>' crlf
     if atit<>'' then outit=outit||'<li><b>Title:</b> 'atit || crlf 
     if adescrip<>'' then outit=outit||'<li><b>Description:</b> ' adescrip
     outit=outit'</menu>' crlf
  end
end

outit=outit||'<hr><a name="more"><h3>More options</h3> </a><menu>' crlf
if doing<>4 then
  outit=outit'<li> View all <a href="'chlink'?linkfile='linkfile'&list=1&entrynum=0"> ' , 
      ' <b>HTML</b> links </a> in web-tree ' crlf
else
  outit=outit||'<li> HTMLs in web-tree ' crlf

if doing<>5 then
  outit=outit'<li> View <b></b> <a href="'chlink'?linkfile='linkfile'&list=3"> ' , 
        '  all links </a> in the web-tree ' crlf
else 
  outit=outit||'<li> URLs in web-tree  ' crlf

if \(entrynum=1 & lmode=1) then
  outit=outit||'<li> Links in  <a href="'chlink'?list=1&linkfile='linkfile'&entrynum=1"> ',
              'web-tree root </a> &nbsp; <tt>('hrefs.1'</tt>)   ' crlf
else 
   outit=outit'<li> &nbsp;Links in web-tree root ' crlf

outit=outit'<li><a href="'cheklink_htm'">Create another web-tree </a> (or hierarchical index) ' crlf
outit=outit||'</menu>'crlf
return outit||other


/******************************************/
/* return a list of linkfiles */
list_linkfiles:

outit='<html><head><title>CheckLink: List of Linkage Files </title></head><body ' back_1'> 'crlf 
outit=outit'<h2>List of Linkage Files</h2> The following <em> linkage files </em> were found: 'crlf
outit=outit||'<ul>' crlf
oo=sysfiletree(lfile,alist,'FO')
do mm=1 to alist.0
   crea=stream(alist.mm,'c','query datetime')
   a1=filespec('n',alist.mm)
   parse var a1 a2 '.' .
   outit=outit||'<li> <a href="'chlink'?linkfile='a2'&entrynum=1">'a2'</a> ('crea ')'crlf
end /* do */

call govar is_cgi


return 1


/************/
as_anchor:
     daurl=hrefs.entrynum

/* scan hrefs and label: 1=own site text/html, 2=off site text/html, 3=other */
    if translate(hrefs.1.!type)<>'TEXT/HTML' then call pmprintf(' ERROR: entry#1 not text/html ')
    aa=upper(hrefs.1)    
    parse var aa a1 '//' onsite '/' .
    onsite='HTTP://'onsite'/'
    nonsites=0 ;noffsites=0 ; nothtmls=0

    do mm=1 to words(hrefs.entrynum.!reflist)       /* identify types of urls */
       aw=strip(word(hrefs.entrynum.!reflist,mm))
       ac=translate(hrefs.aw)
       ac2=strip(translate(hrefs.aw.!type))
       if ac2='TEXT/HTML' then do
          if abbrev(ac,onsite)=1 then do
              nonsites=nonsites+1
              hrefs.aw.!ttype=1
          end /* do */
          else do
              hrefs.aw.!ttype=2
              noffsites=noffsites+1
          end
       end /* do */
       else do
          if abbrev(ac,onsite)=1 then do
              hrefs.aw.!ttype=3
          end /* do */
          else do
              hrefs.aw.!ttype=4
          end
          nothtmls=nothtmls+1
       end
    end /* do */
    do mm=1 to words(hrefs.entrynum.!imglist)
       aw=strip(word(hrefs.entrynum.!imglist,mm))
       ac=translate(imgs.aw)
       if abbrev(ac,onsite)=1 then 
              imgs.aw.!ttype=3
       else 
              imgs.aw.!ttype=4
    end                         /* identifying types of urls */

    
    qq=hrefs.entrynum.!queried
    ss=hrefs.entrynum.!size
    avail='yes'
    if ss<0 then do
          ipy=abs(ss) ; avail=nas.ipy
          ss='unknown' 
    end
    
    if symbol('HREFS.'entrynum'.!TITLE')<>'VAR' then
         atit=''
    else
        atit=hrefs.entrynum.!title

    if symbol('HREFS.'entrynum'.!DESCRIP')<>'VAR' then
         adescrip=' '
    else
        adescrip=hrefs.entrynum.!descrip
   

    if qq=1 then
        outit=outit||'<center><h3> For text/html document at 'daurl '</h3></center>' crlf 
    else
        outit=outit||'<h2> For 'daurl '</h2>' crlf 
    outit=outit||'Basic Information on <a href="'daurl'">' daurl'</a><ul>' crlf 
    if atit<>' ' then outit=outit'<li><b>Title:</b> ' atit||crlf   
    if adescrip<>' ' then outit=outit'<li><b>Description:</b> ' adescrip||crlf   

    outit=outit'<li> Accessible: ' avail ||crlf 

     outit=outit||'<li> Size=' ss ',  and MimeType=' hrefs.entrynum.!type ||crlf ,
       '<li> referenced 'hrefs.entrynum.!nrefs' times  ' crlf 
      if qq=1 then do
         outit=outit||'<li>' crlf 
         outit=outit||' Contains '||words(hrefs.entrynum.!reflist)' <u>anchors</u>: '  crlf 
         outit=outit|| nonsites '<a href="#ONSITES">on-site HTMLs</a> , ' crlf 
         outit=outit||noffsites ' <a href="#OFFSITES">off-site HTMLs</a>, ' crlf 
         outit=outit|| nothtmls ' <a href="#NOTHTMLS">non-HTMLs</a>; ' crlf
     
        outit=outit||' &nbsp; <em>and </em> &nbsp; '||words(hrefs.entrynum.!imglist)||' <a href="#IMAGES"> Images </a>. '
      end
      outit=outit'</ul> 'crlf


/* seperate list of "references to " */
 outit=outit|| ,
     '<hr width=30%><h3>References to: 'daurl '</h3>'|| crlf ,
     'The following HTML documents contain links to <u> 'daurl'</u>'||crlf||'<ol>'
     sortlist=sort_list(hrefs.entrynum.!appearin)
     do i8=1 to words(sortlist)
         aw=word(sortlist,i8)
         if symbol('HREFS.'aw'.!TITLE')<>'VAR' then
             atit=''
         else
             atit=hrefs.aw.!title
         outit=outit'<li><a href="'hrefs.aw'">'hrefs.aw'</a>&nbsp;&nbsp;'
         yv=chlink'?LINKFILE='linkfile'&isimg=0&ENTRYNUM='aw
         yv=yv||'&via='entrynum
         outit=outit||' <a href="'yv'">&nbsp;?</a> &nbsp; &nbsp;<em>('atit')</em>'||crlf
     end /* do */

     outit=outit||'</ol>'crlf


if qq=0 then return 1

anrefs=words(hrefs.entrynum.!reflist)
animgs=words(imgs.entrynum.!imglist)
if anrefs+animgs=0 then return 1

outit=outit'<hr width=30%><a name="LINKS"><h3>Links apppearing in 'daurl '</h3></a>' crlf ,
    'The following links appear in  <u>' daurl '</u>'||crlf

outit=outit'<p><table border=1> <tr>' crlf

outit=outit'<td><center><a name="ONSITES"><b>On-site HTMLs</b></a><br></center> <ol> ' crlf

sortlist=sort_list(hrefs.entrynum.!reflist)

do i8=1 to words(sortlist)
    aw=strip(word(sortlist,i8))
    if hrefs.aw.!ttype<>1 then iterate   /* On site htmls */
    if symbol('HREFS.'aw'.!TITLE')<>'VAR' then
       atit=''
    else
       atit=hrefs.aw.!title
    outit=outit'<li><a href="'hrefs.aw'">'||breakup(hrefs.aw,45,1)||'</a>&nbsp;&nbsp; '
    yv=chlink'?LINKFILE='linkfile'&isimg=0&ENTRYNUM='aw'&via='entrynum
    outit=outit||' <a href="'yv'"> &nbsp;?</a> <em>&nbsp;&nbsp;('atit')</em>'||crlf
end /* do */
outit=outit||crlf'</ol></td> 'crlf

outit=outit' <td valign="top"> ' crlf 
outit=outit'<center><a name="OFFSITES"><b>Off-site HTMLs</b></a><br></center><ol>'crlf
do i8=1 to words(sortlist)              /* use same sortlist (derived from same !reflist */
    aw=word(sortlist,i8)
    if hrefs.aw.!ttype<>2 then iterate   /* Off site htmls */
    outit=outit'<li><a href="'hrefs.aw'">'||breakup(hrefs.aw,45)'</a>&nbsp;&nbsp;'
    yv=chlink'?LINKFILE='linkfile'&isimg=0&ENTRYNUM='aw'&via='entrynum
    outit=outit||' <a href="'yv'"> &nbsp;?</a>'||crlf
end /* do */
outit=outit||crlf'</ol></td> '

outit=outit'<tr> 'crlf

outit=outit' <td valign="top"> ' crlf 
outit=outit'<center><a name="NOTHTMLS"><b>Non-HTMLs</b></a><br></center><ol>'crlf
outit=outit||'<em>on-site</em><br>'crlf
do i8=1 to words(sortlist)              /* use same sortlist (derived from same !reflist */
    aw=word(sortlist,i8)
    if hrefs.aw.!ttype<>3 then iterate   /* non htmls */
    outit=outit'<li><a href="'hrefs.aw'">'||breakup(hrefs.aw,45,1)'</a>&nbsp;&nbsp;'
    yv=chlink'?LINKFILE='linkfile'&isimg=0&ENTRYNUM='aw'&via='entrynum
    outit=outit||' <a href="'yv'"> &nbsp;?</a>'||crlf
end /* do */

outit=outit||'</ol><p><ol><em>off-site</em><br>'crlf
do i8=1 to words(sortlist)              /* use same sortlist (derived from same !reflist */
    aw=word(sortlist,i8)
    if hrefs.aw.!ttype<>4 then iterate   /* non htmls */
    outit=outit'<li><a href="'hrefs.aw'">'||breakup(hrefs.aw,45)||'</a>&nbsp;&nbsp;'
    yv=chlink'?LINKFILE='linkfile'&isimg=0&ENTRYNUM='aw'&via='entrynum
    outit=outit||' <a href="'yv'"> &nbsp;?</a>'||crlf
end /* do */


outit=outit||crlf'</ol></td> '

outit=outit'<td valign="top"> ' crlf 
outit=outit'<center><a name="IMAGES"><b>Images</b></a><br></center><ol><em>on-site</em>'crlf
sortlist=sort_list(hrefs.entrynum.!imglist,1)
do i8=1 to words(sortlist)              
    aw=word(sortlist,i8)
    if imgs.aw.!ttype<>3 then iterate                /* onsite imagse */
    outit=outit'<li><a href="'imgs.aw'">'||breakup(imgs.aw,45,1)||'</a>&nbsp;&nbsp;'
    yv=chlink'?LINKFILE='linkfile'&isimg=1&ENTRYNUM='aw
    yv=yv||'&via='entrynum
    outit=outit||' <a href="'yv'"> &nbsp;?</a>'||crlf
end /* do */

outit=outit||'</ol><p><ol><em>off-site</em><br>'crlf
do i8=1 to words(sortlist)              
    aw=word(sortlist,i8)
    if imgs.aw.!ttype<>4 then iterate               /* off site images */
    outit=outit'<li><a href="'imgs.aw'">'||breakup(imgs.aw,45)||'</a>&nbsp;&nbsp;'
    yv=chlink'?LINKFILE='linkfile'&isimg=1&ENTRYNUM='aw
    yv=yv||'&via='entrynum
    outit=outit||' <a href="'yv'"> &nbsp;?</a>'||crlf
end /* do */

outit=outit||crlf||'</ol></td>'

outit=outit'</table>'crlf

return 1

/************/
breakup:procedure
parse arg aword,alen,nosn

parse var aword . '//' aword

if nosn=1 then do
   parse var aword '/' aword
   if length(aword)<=alen then return '/'aword
   asn='' ; req='/'aword
end /* do */
else do
   if length(aword)<=alen then do
      if pos('/',aword)=0 then aword=aword'/'
      return aword
   end
   parse var aword asn '/'  req ; req='/'req ;  asn=asn'/<br>'
end   

if length(req)<alen then return asn||req

parse var req  rq '?' opts
aq='?'; if pos("?",req)=0 then aq=''
if length(rq)>alen then 
   rq=left(rq,alen)||'...'aq'<br>'
else
   rq=rq||aq'<br>'
if length(opts)>alen then opts=left(opts,alen)'...'

return asn||rq||opts

/************/
/* image links are fairly simple (not much info to be displayed */
as_image:

 daurl=imgs.entrynum

 ss=imgs.entrynum.!size
 if ss<0 then ss='unknown'
 nr=imgs.entrynum.!nrefs
 outit=outit||'<h2> For image: 'imgs.entrynum '</h2>' crlf 
          outit=outit||'Basic Information on <a href="'daurl'">' daurl'</a>' crlf ,
          '<ul><li> Size='ss ',  and MimeType=' imgs.entrynum.!type|| crlf ,
          '<li> referenced 'nr' times ' crlf 
 outit=outit||'</ul> '

/* seperate list of "references to " */
 outit=outit|| ,
     '<hr width=30%><h3>References to: 'daurl '</h3>'|| crlf ,
     'The following HTML documents contain in-line image references to <u> 'daurl'</u>'||crlf||'<ol>'
     do i8=1 to words(imgs.entrynum.!appearin)
         aw=word(imgs.entrynum.!appearin,i8)
         outit=outit'<li><a href="'hrefs.aw'">'hrefs.aw'</a>&nbsp;&nbsp;'
         yv=chlink'?LINKFILE='linkfile'&isimg=0&ENTRYNUM='aw
         yv=yv||'&via=-'entrynum
         outit=outit||' <a href="'yv'">&nbsp;?</a>'||crlf
     end /* do */
     outit=outit||'</ol>'crlf

 return 1


/*********/
packur2:procedure expose standalone 
parse arg a1b0

if standalone=0 then
   return packur(translate(a1b0,' ','+'))
else
   return decodekeyval(translate(a1b0,' ','+'))


/************************************************/
/* procedure from TEST-CGI.CMD by  Frankie Fan <kfan@netcom.com>  7/11/94 */
DecodeKeyVal: procedure
  parse arg Code
  Text=''
  Code=translate(Code, ' ', '+')
  rest='%'
  do while (rest\='')
     Parse var Code T '%' rest
     Text=Text || T
     if (rest\='' ) then
      do
        ch = left( rest,2)
        if verify(ch,'01234567890ABCDEF')=0 then
           c=X2C(ch)
        else
           c=ch
        Text=Text || c
        Code=substr( rest, 3)
      end
  end
  return Text


/***********/
/* load some dlls */
load:

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
foo=rxfuncquery('rexxlibregister')
if foo=1 then do
    say " Could not find REXXLIB "
    exit
end /* do */
return 1


/***********************************/
/* LIST ALL urls, possibly matching checkmime variable
  Make_index will list only on-site text/htmls */

list_all:
parse arg jat
jat=strip(jat)
outit=''
if user_intro1<>'' then do
  afil=stream(user_intro1,'c','query exists')
  if afil<>'' then do
     foo=stream(afil,'c','open read')
     outit=charin(afil,1,chars(afil))
     foo=stream(afil,'c','close')
  end
end
if outit='' then        /* the generic intro */
  outit='<html><head><title>CheckLink: Display Web Index </title></head><body ' back_1'> 'crlf 

goo3=' || <a href="#urlspec">By mime</a>'
outit=outit||'<A name="TOP1">|</a>'||make_topbar(jat,chlink,linkfile,listmode,goo3)'<p>'

outit=outit||'<h2 align=center> CheckLink: Index of Web Tree </h2>' crlf 


if is_cgi=0  then do            /* srehttp -- send first part */
   rcode=sref_multi_send(outit,'text/html','1S',0,verbose,fixexpire,'CheckLink2')
   outit=''
end

if symbol('HREFS.!NAME')<>'VAR' then do             /* name of this webtree */
   a1=hrefs.1
   parse var a1 . '//' sname '/' rname
   treename='Starting at /'rname ' on  ' sname
end /* do */
else do
   treename=hrefs.!name     
end
outit=outit||'<b>Name of webtree:</b> <tt>' treename '</tt>' crlf

if translate(hrefs.1.!type)<>'TEXT/HTML' then call pmprintf(' ERROR: entry#1 not text/html ')
aa=upper(hrefs.1)    
parse var aa a1 '//' thesite '/' .
onsite='HTTP://'thesite'/'

/* list all on-site urls first, interminngling sorted anchors and images.
Then include links off-site (also sorted */

hoffsites='' ; honsites='' ; ioffsites='' ; ionsites=''
ccm=checkmime
checkmime=translate(checkmime)

if is_cgi=0 then do
   maxwait=extract('limittimeinactive')/2
   outit=outit||'<br> <em> Processing time required ...</em>'crlf
   rc=sref_multi_send(outit)
   outit=''
end
else do
  maxwait=1111111111
end
aa=time('r'); aa0=aa ; bb=aa
do aw=1 to hrefs.0                      /* create on and offsite anchors lists */
    ac=translate(hrefs.aw)
    ty=strip(translate(hrefs.aw.!type))  /* look for wildcard match in checkmime */
    if checkmime<>'*' then do
      ioky=0
      do aw2=1 to words(checkmime)        /* if found, then we are okay */
           goof=strip(word(checkmime,aw2))
           if wild_match(ty,goof)<>0 then ioky=1
           if ioky=1 then leave
      end /* do */
      if ioky=0 then iterate
    end
    if abbrev(ac,onsite)=1 then 
         honsites=honsites' 'aw
    else
         hoffsites=hoffsites' 'aw
    if (aw//10)=1 then bb=time('e')
    if bb-aa>maxwait then do                  /* only will happen in sre mode */
        foo=sref_multi_send('.'crlf)
        aa=bb
    end /* do */
end
honsites=sort_list(honsites)            /* sort them */
hoffsites=sort_list(hoffsites)
do aw=1 to imgs.0                               /* on and off site image list */
    ac=translate(imgs.aw)
    if checkmime<>'*' then do
       ty=strip(translate(imgs.aw.!type))
       if wordpos(ty,checkmime)=0 then iterate  /* not in "checkmime" list, so skip */
    end /* do */
    if abbrev(ac,onsite)=1 then 
         ionsites=ionsites' 'aw
    else
         ioffsites=ioffsites' 'aw
    if (aw//10)=1 then bb=time('e')
    if bb-aa>maxwait then do                  /* only will happen in sre mode */
        foo=sref_multi_send('.'crlf)
        aa=bb
    end /* do */

end

ionsites=sort_list(ionsites,1)          /* sort them */
ioffsites=sort_list(ioffsites,1)

tt=hrefs.0+imgs.0
outit=outit'<center><h3>URLs in the web-tree </h3></center> 'crlf

if checkmime='*' then          /* constrainted url display ? */
   outit=outit'Total of 'tt ' URLs( 'hrefs.0' <em>anchors</em> and 'imgs.0 '<em>images </em>) 'crlf
else 
  outit=outit' Extracting URLS with mimetype of 'ccm ', from a total of ' ,
   tt ' URLs  ( 'hrefs.0' <em>anchors</em> and 'imgs.0 '<em>images </em>) 'crlf
 
outit=outit'<hr width=35%>'crlf
outit=outit||  ,
      '<table> ' crlf ,
      ' <th nowrap> More info </th> ' crlf ,
      ' <th> / </th> ' crlf ,
      ' <th> _._ </th> ' crlf  ,
      ' <th> <em>Size or<br>status</em> </th> ' crlf  ,
      ' <th> <tt>Mimetype</tt>  &amp; <em>Title</em> </th> 'crlf
call disp_interleave honsites,ionsites,1

outit=outit'<tr> <td colspan=5> <center> <b>____________ </b> </center></td> 'crlf
call disp_interleave hoffsites,ioffsites /* now do it again for offsite */
outit=outit'</table>' crlf

outit=outit'<hr><a name="urlspec">Display</a> URLs of a particular mimetype: <menu> ' crlf ,
  '<li> <a href="'chlink'?linkfile='linkfile'&list=3&mime=text/plain">text/plain</a> ' ,
  '<li> <a href="'chlink'?linkfile='linkfile'&list=3&mime=text/html">text/html</a> ' ,
  '<li> <a href="'chlink'?linkfile='linkfile'&list=3&mime=image/*">image/* files</a> ' ,
  '<li> <a href="'chlink'?linkfile='linkfile'&list=3&mime=application/*">application/*</a> ' ,
  '<li> <a href="'chlink'?linkfile='linkfile'&list=3&mime=*">all URLs</a> ' ,
  '</menu><bR> <a href="#TOP1">Top of file </a> 'crlf


outit=outit||crlf||make_bottombar(entrynum,chlink,linkfile,listmode)'<p>'


outit=outit||'</body></html> 'crlf
if is_cgi=0 then do

teps=time('e')-aa0
   if is_cgi=0 then foo=sref_multi_send('<em>'||format(teps,6,2)||' seconds </em><br>')
   foo=sref_multi_send(outit)
   foo=sref_multi_send(' ',,'1E')
end /* do */
else do
  call charout, outit
end



/**************/
/* interleave display of two lists of urls -- anchors and images 
   hlist == pointers to hrefs (internally sorted
   ilist == pointers to images (interanlly sorted0
   ison  == 1 if "thsee are onsites" (hence strip http://xx.yy/ portion */
disp_interleave:
parse arg hlist,ilist,ison

codesb.0='not reported '
codesb.1='Server n.a. '
codesb.2='Resource n.a. '
codesb.3='Off-site '
codesb.4=''
codesb.5='Excluded &nbsp;'

hdo=words(hlist)
ido=words(ilist)
ath=1                  /* currently avaiable for comparision (prior ones written */
ati=1

oof=1
amy=0
do forever              /* interleave anchor and images, and display */
    amy=amy+1
    if (amy//10)=1 then bb=time('e')
    if bb-aa>maxwait then do                  /* only will happen in sre mode */
        foo=sref_multi_send('.'crlf)
        aa=bb
    end /* do */

  
  select
      when ath>hdo & ati>ido then leave       /* got'em all */
      when ati>ido then  do
           doh=1            /* doh=1 -- use anchor */
           iath=word(hlist,ath) ; iat=iath
      end
      when ath>hdo then do   
          doh=0  
          iati=word(ilist,ati)
          iat=iati
      end
      otherwise do                      /* compare */   
        iath=word(hlist,ath)
        iati=word(ilist,ati)
        hurl=lower(hrefs.iath)
        iurl=lower(imgs.iati)
        if hurl>iurl then do
            iat=iati ;    doh=0
        end
        else do
            doh=1 ; iat=iath
        end
      end
  end

/* using doh, decide what to write */
  inf1=0
  if doh=1 then do                              /* anchor is next one to show */
      writeme=hrefs.iath ; writeme2='<tt>'hrefs.iath.!type'</tt>' ; writeme3=hrefs.iath.!size
      ath=ath+1 ; 
      if ison=1 then inf1=hrefs.iath.!queried
   end
   else do                      /* image is */
      writeme=imgs.iati ; writeme2='<tt>'imgs.iati.!type'</tt>' ; writeme3=imgs.iati.!size
      ati=ati+1 
   end
   burl=writeme
   writeme=lower(breakup(writeme,36,ison))
   ugl=lastpos('/',writeme)     /* empty line at subdirectory change? */
   ugly=left(writeme,ugl)
   if oof=1 then oldugly=ugly
   oof=0
   if ugly<>oldugly then do
        ncc=compare(ugly,oldugly)
        outit=outit'<tr><td colspan=5> &nbsp; </td>'
        oldugly=ugly
   end /* do */

   ill=lastpos('/',writeme) ; if ill=0 then ill=1
   pt1=substr(writeme,1,ill)
   pt2=substr(writeme,ill+1) ; if pt2='' then pt2='/'
   hh='<a href="'||burl||'">'pt2'</a>'
   if datatype(writeme3)='NUM' then do
       kc=abs(writeme3)
       if writeme3<=0 then writeme3=codesb.kc
   end /* do */
   hod=1-doh

   inf2='<a href="'chlink'?linkfile='linkfile'&isimg='hod'&entrynum='iat'">?</a>&nbsp;&nbsp; '
   if inf1=1 then do
     inf2='<a href="'chlink'?linkfile='linkfile'&list=2&entrynum='iat'">&lt;-</a>&nbsp; 'inf2
     inf2=inf2'<a href="'chlink'?linkfile='linkfile'&list=1&entrynum='iat'">-&gt;</a>&nbsp '
     if symbol('HREFS.'iath'.!TITLE')<>'VAR' | doh=0 then
         atit=''
     else
        atit=hrefs.iath.!title
     writeme2=writeme2'<br><em>'atit'</em>'
   end
   else do
      inf2='&nbsp;&nbsp;&nbsp;&nbsp;'inf2'&nbsp;&nbsp;&nbsp;&nbsp;'
   end /* do */

   outit=outit||'<tr><td valign=top><b>'inf2'</b>  </td> ' ,
                   '<td valign=top> 'pt1'</td> ',
                   '<td valign=top>' hh '</td> ',
                   '<td valign=top> <em>'writeme3'</em> </td> ' , 
                   '<td valign=top align=center> 'writeme2' </td>  ' crlf

end /* do */

return 1

/***********************************/
/* make an index (text/html document pointed to by this entry */
make_index:
parse arg jat
jat=strip(jat)

outit=''
if user_intro1<>'' then do
  afil=stream(user_intro1,'c','query exists')
  if afil<>'' then do
     foo=stream(afil,'c','open read')
     outit=charin(afil,1,chars(afil))
     foo=stream(afil,'c','close')
  end
end
if outit='' then        /* the generic intro */
  outit='<html><head><title>CheckLink: Traverse Web Tree </title></head><body ' back_1'> 'crlf 

outit=outit||make_topbar(jat,chlink,linkfile,listmode)'<p>'

outit=outit||'<h2 align=center> CheckLink: Traversing Web Tree </h2>' crlf 

if symbol('HREFS.!NAME')<>'VAR' then do             /* name of this webtree */
   a1=hrefs.1
   parse var a1 . '//' sname '/' rname
   treename='Starting at /'rname ' on  ' sname
end /* do */
else do
   treename=hrefs.!name     
end
outit=outit||'<b>Name of webtree:</b> <tt>' treename '</tt>' crlf

if translate(hrefs.1.!type)<>'TEXT/HTML' then call pmprintf(' ERROR: entry#1 not text/html ')
aa=upper(hrefs.1)    
parse var aa a1 '//' thesite '/' .
onsite='HTTP://'thesite'/'


/* display on-site resources only.  For now, just to htmls */
ndo=0
tmplist=''
if jat=0 then do                 /* all htmls */
  do aw=1 to hrefs.0
    ac=translate(hrefs.aw)

    if abbrev(ac,onsite)<>1 then iterate /* off-site resource, ignore */
    ac2=strip(translate(hrefs.aw.!type))
    if ac2<>'TEXT/HTML' then iterate            /* non-html, ignore */
    tmplist=tmplist' 'aw
  end
end
else do                 /* this entrynum  -- either from or to*/
   if listmode=2 then 
        dalist=hrefs.jat.!appearin
   else
       dalist=hrefs.jat.!reflist

   do nn=1 to words(dalist)
       aw=strip(word(dalist,nn))
       ac=translate(hrefs.aw)
       if abbrev(ac,onsite)<>1 then iterate /* off-site resource, ignore */
       ac2=strip(translate(hrefs.aw.!type))
       if ac2<>'TEXT/HTML' then iterate            /* non-html, ignore */
       tmplist=tmplist' 'aw
   end
end /* do */

sortlist=sort_list(tmplist)
ndo=words(sortlist)

if jat=0 then do                   /* all on-site htmls in web tree */
     outit=outit||'<center><h3>text/html documents</h3></center> '
     outit=outit||'<b>' ndo ' </B> text/html documents on <u>'thesite'</u> ' crlf ,
      ' <em>(out of 'hrefs.0 ' anchors &amp; 'imgs.0 ' images) </em> ' crlf 
end
else do
  melink='<a href="'chlink'?linkfile='linkfile'&entrynum='jat'">?</a>'
  backlink='<a href="'chlink'?list=2&linkfile='linkfile'&entrynum='||jat ,
           '">&lt;-- </a> &nbsp;'
  forwardlink='&nbsp;<a href="'chlink'?list=1&linkfile='linkfile'&entrynum='||jat ,
           '">--&gt; </a>'

  gourl='<a href="'hrefs.jat'">'hrefs.jat'</a>'

  if listmode=2 then do
    outit=outit||'<center><h3>URLs with links to 'hrefs.jat '</h3></center>' crlf
    outit=outit||'<b> ' ndo ' </B> links <b>from</b> text/html documents to 'gourl ,
                '('melink||'&nbsp;'forwardlink')&nbsp;' crlf
  end /* do */
  else do
    outit=outit||'<center><h3>text/html links in 'hrefs.jat '</h3></center>' crlf
    outit=outit||'('backlink' &nbsp; 'melink')&nbsp; ' gourl ||' contains <b> ' ndo ,
                 ' </B> links <em>to </em> &nbsp; text/html documents ' crlf 
    outit=outit||' <Em> (out of '||words(hrefs.jat.!reflist)|| ,
             ' anchors and '||words(hrefs.jat.!imglist) ' images ) </em>' crlf  
  end
end
if jat=1 
    then outit=outit'<br>This is the <em>starter-URL </em> (the root) of the <B>web-tree</b><br>'crlf
outit=outit'<hr width=35%>'crlf
if ndo>0 then do
       outit=outit||  ,
      '<table> ' crlf ,
      ' <th> More info </th> ' crlf ,
      ' <th> / </th> ' crlf ,
      ' <th> _._ </th> ' crlf  ,
      ' <th> <em>size</em> </th> ' crlf  ,
      ' <th> Title </th> 'crlf
end

oldugly='/'
do mm=1 to ndo
   mm0=strip(word(sortlist,mm)) ;mm1=mm0
   mickey=breakup(lower(hrefs.mm0),70,1)

   ugl=lastpos('/',mickey)     /* empty line at subdirectory change? */
   ugly=left(mickey,ugl)
   if mm=1 then oldugly=ugly
   if ugly<>oldugly then do
        ncc=compare(ugly,oldugly)
        outit=outit'<tr><td colspan=5> &nbsp; </td>'
        oldugly=ugly
   end /* do */

   ill=lastpos('/',mickey) ; if ill=0 then ill=1
   pt1=substr(mickey,1,ill)
   pt2=substr(mickey,ill+1) ; if pt2='' then pt2='/'
   hh='<a href="'||hrefs.mm0||'">'pt2'</a>'

   if symbol('HREFS.'mm0'.!TITLE')<>'VAR' then
     atit=''
   else
     atit=hrefs.mm0.!title
   if mm1=1 then atit='<u>'atit'</u>'

   ll0='<a href="'chlink'?linkfile='linkfile'&list=2&entrynum='mm1'">&lt;-- </a>&nbsp;&nbsp; '
   ll='<a href="'chlink'?linkfile='linkfile'&entrynum='mm1'">?</a>&nbsp;&nbsp; '
   ll2='<a href="'chlink'?linkfile='linkfile'&list=1&entrynum='mm1'">-- &gt;</a>&nbsp;&nbsp; '
   
   outit=outit'<tr> <td>' ll0 ' &nbsp; ' ll ' &nbsp; 'll2 '</td> ' crlf , 
              '<td> <u> ' pt1 '</u> </td> ' crlf ,  
              '<td>'hh'</td>  ' crlf , 
              '<td><em>('hrefs.mm0.!size') </td> ' crlf ,
              '<td></em>&nbsp;&nbsp; &nbsp; 'atit' </td> ' crlf 


end /* do */
if ndo>0 then outit=outit||'</table>'

outit=outit||crlf||make_bottombar(entrynum,chlink,linkfile,listmode)'<p>'

outit=outit||'</body></html> 'crlf

call govar is_cgi

return 1

/******************/
/* VAR outit, or charout */
govar:
parse arg iscg
if iscg==1 then do
   call charout,outit
end 
else do
  foox=value('SREF_PREFIX',,'os2environment')
  if foox='' then
     'VAR type text/html name outit '
  else
    fooo=sref_gos('VAR type text/html name outit ',outit)
end
return 0

/******************/
/* given list of pointers to hrefs., rearrange it to be sorted on
  hrefs, and return. Thus, same set of pointers, but rearranged */
sort_list:procedure expose hrefs. imgs.  is_cgi
parse arg alist,isimg

if words(alist)<2 then return alist

nhrefs.0=words(alist)

if isimg=1 then do
 do mm=1 to nhrefs.0
    aw=strip(word(alist,mm))
    nhrefs.mm=imgs.aw
 end
end /* do */
else do
 do mm=1 to nhrefs.0
    aw=strip(word(alist,mm))
    nhrefs.mm=hrefs.aw
 end
end

call sort_nhref

bb=''
do mm=1 to nhrefs.0
  gurney=sortlist.mm
  bb=bb' 'word(alist,gurney)
end /* do */
return strip(bb)


/********************************/
/* sort nhrefs. list of urls --- subdirectory sensitive */
sort_nhref:procedure expose nhrefs. sortlist.   is_cgi
parse arg alist

/* make an array with sortable elements in portions of each record
   the idea: arraysort works on portions of  record -- set up fixed length
   portion of records, padded with spaces, for each of the severeal directories
   that may occur in a url  */

elemsizes.0=0 ; maxfname=0 ; maxssn=0
do jj=1 to 40           /* elemsizes is the max size dir1 dir2 ... dir_elemsizes.0 */
   elemsizes.jj=0
end /* do */

do is=1 to nhrefs.0                             /* break into dir1 dir2 name */
     aa1=strip(strip(nhrefs.is,'l','/'))
     parse var  aa1 . '//' ssn '/' a1
     biglist.is.!srv=ssn ; maxssn=max(maxssn,length(ssn))
     h1=lastpos('/',a1)                   /* pluck off "file name" */
     biglist.is.0=0
     if h1>0 then do
        biglist.is=substr(a1,h1+1)
        maxfname=max(maxfname,length(biglist.is))   /* size of filename portion of record */
     end
     else do
        biglist.is=a1
        maxfname=max(maxfname,length(biglist.is))
        iterate         /* no dirs, get net entry */
     end
     a1=delstr(a1,h1)           /* the remainder is the path */
     idirs=0
     do forever                 /* pluck out directories in path */
       if a1='' then leave      /* got all directories */
       parse var a1 dx '/' a1
       idirs=idirs+1
       biglist.is.idirs=dx
       elemsizes.idirs=max(length(dx),elemsizes.idirs)
     end /* do */
     biglist.is.0=idirs
     elemsizes.0=max(elemsizes.0,idirs)
end
do ipp=1 to elemsizes.0         /* increase by one (prevent runons */
   elemsizes.ipp=elemsizes.ipp+1
end /* do */

/* make oo -- which will be arraysorted */
do ii=1 to NHREFS.0
  oo.ii=left(ii,6)' 'left(biglist.ii.!srv,maxssn+1)   /* first 6chars point to original record # */
  do mm=1 to ELEMSIZES.0
      if mm<=biglist.ii.0 then 
         oo.ii=oo.ii||left(biglist.ii.mm,elemsizes.mm)
     else
         oo.ii=oo.ii||left(' ',elemsizes.mm)
  end /* do */
  oo.ii=oo.ii||left(biglist.ii,maxfname)
end /* do */

OO.0=NHREFS.0           
EEF=ARRAYSORT(OO,,,7,,'A','I')         /* sort the names (offset past pointer */

DO MM=1 TO NHREFS.0                  /* split out pointers to original records */
   sortlist.mm=strip(left(oo.mm,6))     /* save these pointers in a new array */
end /* do */
sortlist.0=nhrefs.0
return 1



/************************/
/* wild card match, with comparision against prior wild card match */


wild_match:procedure 
parse upper arg needle, haystack,oldresu


 aresu=awild_match(needle,haystack)
 if aresu=0 then return aresu     /* no match */
 if aresu=-1 | oldresu=' ' then return aresu  /* exact match, or first wildcard match */

/* Is this a better WILDCARD MATCH */
   wrdsnew=words(ARESU);wrdsold=words(oldRESU)
   useold=1
   do Nmm=1 to max(wrdsold,wrdsnew)
       if Nmm>wrdsnew then leave
       if Nmm>wrdsold then do
             useold=0; leave
       end  
       a1=strip(word(oldresu,Nmm))
       a2=strip(word(aresu,Nmm))
       if a1=a2  then iterate
       if a2>a1 then leave  /* new matching element > old matching element, thus new is worse match */
       useold=0           /* found a matching element in new < then corresponding element in old*/
       leave            /* thus, new is better match */
    end

    IF USEold=0 THEN return aresu
     return 0           /* non superior match (might be same, in which case old is used*/




awild_match:procedure
parse upper arg needle, haystack ; haystack=strip(haystack)
needle=strip(needle)

if needle=haystack then return -1        /* -1 signals exact match */
ast1=pos('*',haystack)
if ast1=0 then return 0                 /* 0 means no match */
if haystack='*' then  do
   if length(needle)=0 then 
       return 100000
    else 
        return length(needle)
end
ff=haystack
ii=0
do until ff=""
  ii=ii+1
  parse var ff hw.ii '*'  ff
  hw.ii=strip(hw.ii)
end
if hw.ii='' then ii=ii-1
hw.0=ii


/* check each component of haystackw against needle -- all components
must be there */

resu=' '
istart=1 ; ido=2
if ast1>1 then do       /* first check abbrev */
  if abbrev(needle,hw.1)=0 then return 0
  aresu=length(hw.1)
  if hw.0=1 then do
     do nm=1 to aresu
        resu=resu||' '||nm
     end /* do */
     return resu         /* if haystacy of form abc*, we have a match */
  end
  ido=2 ; istart=aresu+1
  do mm=1 to aresu
        resu=resu||' '||mm
  end /* do */
end
/* if here, then first part (a non wildcard) of haystack matches first
part of needle
Now check sequentially that each remaining part also exists
*/
do mm=ido to hw.0
  igoo=pos(hw.mm,needle,istart)
  if igoo=0 then return 0
  tres=length(hw.mm)
  istart=igoo+tres
  do nn=igoo to (istart-1)
     resu=resu||' '||nn
  end /* do */
end
if istart >= length(needle) | right(haystack,1)='*' then
   return resu
return 0
 




/* Example of  use of sref_wild_match */
/* ==================
a.1='This is *'
a.2='This is a *'
a.3='This is a funny * story'
a.4='* is * '
a.5='Th* fun*'
a.6='This is funny *'

say "Enter string : "
parse pull ans
oldresu=''; isit=0
do mm=1 to 6
  resu=sref_wild_match(ans,a.mm,oldresu)
  if resu=-1 then do
    isit=mm
    leave
  end
  if resu=0 then iterate
  isit=mm
  oldresu=resu
end
if isit=0 then
 say " no match "
else say
 say " match= "a.isit
exit
===================== */
