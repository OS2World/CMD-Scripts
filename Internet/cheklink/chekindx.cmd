/*Make a site index, using a CheckLink linkage file.
  This site index is meant for public display -- it does not
  contain the back and forward links contained in cheklnk2  output.
*/
chekindx:

/***  BEGIN USER CONFIGURABLE PARAMETERS     */

/* used in <BODY back_1> element */
back_1='bgcolor="#aabb99"  '

/*  Directory containing link file(s)  */
linkfile_dir=''


/* A fully qualified file containing "header" information.
  If ='', then a generic header is used 
  If specified, the file MUST contain at least:
       <HTML><HEAD>.... </HEAD> <BODY ...>
   and should contain a replacment for
          <h2>Index of Servername </h2> 
  Note: use of user_intro1  means that back_1 is NOT used 
*/
user_intro1=''


/* list of links to "pictures" that will be displayed alongside the
"titles". 
Syntax is:  pix.n= mimetype1  selector
            pix.0 is the number of pix. entries, (if 0, no pictures included
        and pix.!text is included in the <IMG element
Note that the first (possibly wildcarded) match is used */
pix.0=0
pix.1='text/plain  /imgs/text.gif '
pix.2='image/* /imgs/image.gif '
pix.3='text/html '
pix.!include=' height=18 width=18 ALT="*" align="center" '

/* string to use to indent rows of a table. I.e; td_indent='<td> _ </td> '
  Special value: td_indent=integer_value' means: 
    <IMG src="\imgs\1 Pixel.gif" width=iss>
  where iss=td_indent * #_levels
*/
td_indent='<td bgcolor="#789966"> <font color="#789966">__</font></td>'
td_indent=25

/* <TD modifier when writing title and link; descrip_td='valign="TOP" ' */
td_title='valign="TOP" bgcolor="#a2a9a9" '

/* <TD modifier when writing descriptions. I.e.; descrip_td='valign="TOP" ' */
td_descrip='valign="TOP"'

/* <TR modifiers: odd and even rows. I.e.; descrip_tr1='Bgcolor="#559988"' */
tr_mod1=''
tr_mod2=''

/***  END USER CONFIGURABLE PARAMETERS     */


parse arg  ddir, tempfile, reqstrg,list,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir,aparam,semqueue,prog_file

crlf='0d0a'x


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
   chlink='/CGI-BIN/CHEKINDX'
   say 'Content-Type: text/html'
   say ""
end
else do
   if verb='GET' then parse var uri . '?' list
   chlink='/CHEKINDX'
   fixexpire=value(enmadd||'FIX_EXPIRE',,'os2environment')
   if fixexpire>0 then  fpp=sref_expire_response(fixexpire,0)
end

/* get request line info */
linkfile=''
daurl=''
typelist='text/html'
siteonly=1
multishow=0
exclusions=' '
drops=''
cleanup=0
showdesc=0
outtype=1
header=''
doshowul=0

do ii=1 to pix.0
   if symbol('PIX.'ii)<>'VAR' then
        pix.ii=''
    else
      parse upper var pix.ii pix.ii pix.ii.!sel 
end /* do */
if symbol('PIX.!INCLUDE')<>'VAR' then pix.!include='ALT="* "'
list00=list
do until list=''
   parse var list a1 '&' list
   parse var a1 avar '=' aval ; avar=translate(avar)
   aaval=packur2(translate(aval,' ','+'))
   select
     when avar='LINKFILE' then linkfile=aaval
     when avar='URL' | avar='SEL' then daurl=translate(aaval)
     when avar='MIME' then typelist=translate(strip(aaval))
     when avar='MULTI' then multishow=strip(aaval)
     when abbrev(avar,'SITE')=1 then siteonly=is_yes_no(aaval,siteonly)
     when abbrev(avar,'EXCLU')=1 then exclusions=translate(aaval)
     when abbrev(avar,'DROP')=1 then drops=translate(aaval)
     when abbrev(avar,'CLEAN')=1 then cleanup=is_yes_no(aaval,cleanup)
     when abbrev(avar,'DESCRIP')=1 then showdesc=is_yes_No(aaval,showdesc)
     when abbrev(avar,'TYPE')=1 then outtype=aaval
     when abbrev(avar,'CUSTOM')=1 then do
        if aaval<>1 then iterate
        if is_cgi=1 then do
               say   ' Indexing customization mode not available when CheckLink is run as a cgi-bin script.'
               return ''
         end /* do */
         call doing_custom
         signal all_done
     end /* do */
     otherwise nop
   end
end
drop list00

if linkfile='' | linkfile=0 then do
   if is_cgi=0 then do
     'String   CheckLink Error:  LInkfile not specified '
   end 
   else do 
        say   '  CheckLink Error:  Linkfile not specified '
   end
   return ' '
end /* do */

if linkfile_dir=0 then linkfile_dir=''
if linkfile_dir='' then linkfile_dir=value('TEMP',,'os2environment')
lfile=strip(linkfile_dir,'t','\')||'\'||strip(linkfile,'l','\')
if pos('.',lfile)=0 then lfile=lfile'.STM'
if multishow=0 & cleanup=1 then cleanup=0  


/* else, read/display the requested linkfile */

oo=cvread(lfile,bg)

if oo=0 then do
    if is_cgi=0 then
       'string  CheckLink Error:  No such link-file: ' lfile
    else
       say  '  CheckLink Error: No such link-file: ' lfile
   return 0
end

yow2=cvcopy(bg.!hrefs,hrefs)
yow2=cvcopy(bg.!imgs,imgs)
drop bg.

/* we now have the link file. Determine root */

parse  var hrefs.1 . '//' onsite '/' rooturl
onsite=translate(onsite)

istart=0
tellurl.0=0
if  daurl='' | daurl=0 then do          /* use "starter-url */
  istart.1=1
  tellurl.1=rooturl
  tellurl.0=1
end /* do */
else do                 /* for each of possibly several entries, search for a match to daurl */
   do mmm=1 to words(daurl)
    daurl1=strip(word(daurl,mmm))
    if pos('//',daurl1)>0 then  
              parse var daurl1 . '//' . '/' tt1 /* strip site */
    else
          tt1=strip(daurl1,'l','/')
    tt='/'translate(tt1)                
    do aw=1 to hrefs.0          /* search anchors */
       tt2=is_useable(aw,onsite)    /* only on-site, text/htmls ! */
       if tt2='' then iterate
       if tt<>translate(tt2) then iterate
       iarf=tellurl.0+1 ; tellurl.0=iarf
       istart.iarf=aw ; tellurl.iarf=tt2 ;leave
    end /* do */
  end /* do */
end

if tellurl.0=0 then do
    if is_cgi=0 then
       'string CheckLink Error: No such selector:'tt1
    else
       say ' CheckLink Error:  No such selector: ' tt1
   return 0
end /* do */

/* we got something.. set up top of file */
outind=''
call ini_outit

/* create "thelist." -- contains outputable info */
do igoof=1 to tellurl.0          /* extract from each entry (several indices */
       call write_a_table igoof
end
if cleanup=1 then do                /* cleanup entries */
      thelist.0=0 ; thelist.!levels=0
      call do_cleanup 
end

if drops<>'' then do            /* remove "dropped" entries */
  call drop_thelist drops
end

select
   when  outtype=3 | outtype="CUSTOM"  then do  /* CUSTOMizer */
       call write_as_custom
   end

   when outtype=2 | outtype='TABLE' then do  /* a table */
      call write_as_table
   end /* do */

   otherwise do                 /* ul list */
     call write_as_ul
   end   /* otherwise */

end     /* select */


all_done:               /* jump here when done */
   outit=outit||outind||crlf||'</body></html>'crlf
   if is_cgi=1 then do
       call charout,outit
       return ''
   end
   else
      foo=value('SREF_PREFIX',,'os2environment')
      if foo='' then
          'VAR type text/html name outit '
      else
          fooo=sref_gos('VAR type text/html name outit ',outit)
      return '200 '||length(outit)
   end


/*****************/
/* cleanup? */
do_cleanup:
if cleanup=1 then do
 select
   when multishow=2 then do
     do arc=1 to tellurl.0
        foo=add_thelist(istart.arc,1)
        wow=do_uls2(istart.arc,2)    /* remove higher levels, but allow ties */
     end
   end
   when multishow=1 then do
      do mmx=1 to hrefs.0  /* special hack: allow first tie only */
         hrefs.mmx.!tie=0
      end /* do */
      do mmx=1 to imgs.0
         imgs.mmx.!tie=0
      end /* do */
      multishow=3             /* remove higher levels */
      do arc=1 to tellurl.0
         foo=add_thelist(istart.arc,1)
         wow=do_uls2(istart.arc,2)    /* remove higher levels, but allow ties */
      end /* do */
   end
   otherwise nop
 end
end

return 1

/*****************************/
/* write thelist to a form */
write_as_custom:procedure expose thelist. outind crlf  showdesc servername header doshowul

outind=outind||'<a name="top"><form action="/CHEKINDX" method="POST"></a>' crlf

outind=outind||'<input type="HIDDEN" name="CUSTOM" value=1>' crlf
outind=outind||'Header: <TEXTAREA NAME="HEADER" ROWS=2 COLS=50>'header' </TEXTAREA><p>'  crlf
outind=outind||'<TABLE cellspacing=1 cellpadding=1>' crlf
oog=thelist.!levels+2
outind=outind||'<tr><th colspan='oog'><a href="#position">Position  &amp; Level</a></th>'  ,
               '<th><a href="#title">Title</a></th><th><a href="#description">Description</a></th>' crlf

do mm=1 to thelist.0

   al='<tr> '
   vbase='V'||strip(mm)
   al=al||'<td> <input type="text" size=5 maxlength=12 name="'VBASE'_POS" value="'mm'"></td>'
   foo3=''

   ident=copies('__',thelist.mm.!level-1)   /* indentation spacer */
   do nn=1 to thelist.!levels+1                 /* radio buttons to change indentation */
      ischeck=''
      if nn=thelist.mm.!level then  ischeck='CHECKED'
      foo3=foo3'<td><input type="radio" name="'VBASE'_LVL" value="'nn'" 'ischeck '></td> '
   end /* do */
   al=al||crlf||foo3||crlf

   alink=strip(thelist.mm.!link)                /* add title */
   goo2=thelist.mm.!title
   i39=39
   if alink='' then i39=60

   goo3='<input type="text" size='i39' maxlength=120 name="'VBASE'_TIT" value="'goo2'">'

   if alink<>'' then
      al=al||'<td nowrap>'ident' <a href="'alink'">?</a> 'goo3'</td>'
   else
      al=al||'<td nowrap>'ident' <b>:::</b> 'goo3'</td>'


   if showdesc=1 & alink<>' 'then do            /* description, non comment entry */
        bdesc=strip(space(thelist.mm.!desc))
/* break it up into lines of 35 */
        cdesc='';ddesc='';kr=0
        do forever
            if bdesc='' then leave
            parse var bdesc cw bdesc
            cdesc=cdesc' 'cw
            if length(cdesc)>32 then do
                ddesc=ddesc||crlf||cdesc
                cdesc=''
                kr=kr+1
            end /* do */
        end /* do */
        if cdesc<>'' then  do
             ddesc=ddesc||crlf||cdesc ; kr=kr+1
        end
        al=al||crlf'<td> <TEXTAREA NAME="'VBASE'_DSC" ROWS='kr' COLS=36>'ddesc'</TEXTAREA></td>'
   end /* do */

   outind=outind||al||crlf
   outind=outind'<input type="hidden" name="'VBASE'_HREF"  value="'alink'"> 'crlf
   outind=outind'<input type="hidden" name="'VBASE'_PIX"  value="'thelist.mm.!img'">' crlf
  
  
end /* do */

outind=outind'</table>'crlf
outind=outind'<h3>Additional  lines  </h3> You can add <em>comment and seperator </em> lines (HTML ' ,
                 ' elements allowed!)<table>'crlf

do ll=1 to 2
  outind=outind'<tr><td> <input type="text" size=5 maxlength=12 name="COMMENT_'ll'_POS" value=""></td>' crlf 
   do nn=1 to thelist.!levels+1                 /* radio buttons to change indentation */
      ischeck=''
      if nn=2 then  ischeck='CHECKED'
      outind=outind'<td><input type="radio" name="COMMENT_'ll'_LVL" value="'nn'" 'ischeck '></td> '
   end /* do */
   outind=outind'<td><textarea name="COMMENT_'ll'" rows=1 cols=50></textarea></td> ' crlf
end
outind=outind'</table>' crlf

outind=outind'<input type="HIDDEN" name="SERVERNAME" value="'servername'">' crlf


outind=outind'<p>' crlf ,
  ' <INPUT TYPE="radio" NAME="TYPE" VALUE="3" checked > Re-Edit  &nbsp; ' crlf ,
  ' <em>( <INPUT TYPE="checkbox" NAME="ULSHOW" VALUE="1">also show current index as unordered list) </em> ' crlf ,
  ' <em> or .... </em> <br><b> finalize</b> index as an 'crlf ,
  ' <INPUT TYPE="radio" NAME="TYPE" VALUE="1">unordered List (&lt;UL&gt;), <em> or as a </em>  ' crlf ,
  ' <INPUT TYPE="radio" NAME="TYPE" VALUE="2"> table ' crlf 


outind=outind'<br><INPUT type="SUBMIT" value="Re-edit, or finalize">' crlf

outind=outind || crlf ,
       '<hr><h3>Description of options </h3> ' crlf ,
       '<dl> <dt><a name="position">Position</a> <dd> The row of the index, with 1 the top. To delete ' crlf ,         
       ' an entry, set this either to blank or 0. To insert between existing entries,' crlf ,
       ' use a fraction (i.e.; 10.5 is between current entries 10 and 11) ' crlf ,
       '<dt> Level <dd> Indentation level, with the furthest left button the "least" indentation' crlf ,
       '<dt> <a name="title">Title</a><dd> The title of resource. Should be less then 50 characters. ' crlf ,
       '<dt><a name="description">Description </a> <dd>Optional description. 'crlf ,
       ' Can include HTML elements, and can be up to 300 characters long. 'crlf,
        '</dl> <a href="#top">Top of form</a>'

if doshowul=1 then do
  outind=outind'<hr><h3> Current Index (as Unordered List) </h3>'
  call write_as_ul
end

return 1



/*****************************/
/* write thelist to a table */
write_as_table:procedure expose thelist. outind crlf table_mod td_title td_descrip td_indent ,
                        tr_mod1 tr_mod2 

outind=outind||'<TABLE cellspacing=0 cellpadding=0>' crlf

do mm=1 to thelist.0
   if mm//2=0 then 
        oof=tr_mod2
   else
        oof=tr_mod1
   arf=crlf'<tr><table cellpadding=0 cellspacing=0><tr 'oof'>'
   if thelist.mm.!level=1 then arf='<tr> <td> <br> </td>'arf
   if datatype(td_indent)='NUM' then do
      iss=td_indent*(thelist.mm.!level-1)
      arf=arf||'<td><img src="\imgs\1_pixel.gif" height=5 width='iss'> </td>'
   end
   else do
     do mmm=1 to thelist.mm.!level-1
         arf=arf||td_indent
     end /* do */
   end
   if thelist.mm.!Link='' then
      outind=outind||arf' <td nowrap 'td_title'> 'thelist.mm.!title'</td>' crlf
   else
      outind=outind||arf' <td nowrap 'td_title'>'|| ,
           thelist.mm.!img'<a href="'thelist.mm.!link '">'thelist.mm.!title'</a></td>' crlf

   if thelist.mm.!desc<>'' then 
          outind=outind'<td 'td_descrip'>'||strip(thelist.mm.!desc)||'</td>'
   outind=outind'</table>' crlf
end /* do */

outind=outind'</table>'
return 1

/*****************************/
/* write thelist to a ul */
write_as_ul:procedure expose thelist. outind crlf 

wasul=0

do mm=1 to thelist.0
   newul=thelist.mm.!level
   select 
      when newul=1 then do
         if wasul>1 then do
           do mt=newul+1 to wasul
              outind=outind'</ul>'
           end /* do */
         end
         if thelist.mm.!link='' then
            outind=outind'<br>'thelist.mm.!title||crlf
         else
            outind=outind'<br>'thelist.mm.!img' <a href="'thelist.mm.!link'">'|| ,
                thelist.mm.!title||'</a>'thelist.mm.!desc||crlf
      end /* do */

      when newul=wasul then do
         if thelist.mm.!link='' then
            outind=outind'<li>'thelist.mm.!title||crlf
         else
            outind=outind'<li>'thelist.mm.!img' <a href="'thelist.mm.!link'">'|| ,
                thelist.mm.!title||'</a>'thelist.mm.!desc||crlf
      end /* do */

      when newul>wasul then do
         do mt=wasul+1 to newul
             outind=outind'<ul>'
         end /* do */
         if thelist.mm.!link='' then
            outind=outind' 'crlf'<li>'thelist.mm.!title||crlf
         else
            outind=outind' 'crlf'<li>'thelist.mm.!img' <a href="'thelist.mm.!link'">'|| ,
                thelist.mm.!title||'</a>'thelist.mm.!desc||crlf
      end

      when newul<wasul then do
         do mt=newul+1 to wasul
             outind=outind'</ul>'
         end /* do */
         if thelist.mm.!link='' then
            outind=outind||crlf'<li>'thelist.mm.!title||crlf
         else
            outind=outind||crlf'<li>'thelist.mm.!img' <a href="'thelist.mm.!link'">'|| ,
                  thelist.mm.!title||'</a>'thelist.mm.!desc||crlf
      end

      otherwise nop

   end  /* select */
   wasul=newul
 
end /* do */
do ii=1 to wasul-1
  outind=outind'</ul>'
end /* do */
return 1




/*****************************/
/* create an IMG element, based on pix. and mimetype */
make_pix:procedure expose pix.
parse upper arg atype
if pix.0=0 then return ""

do mm=1 to pix.0
  if wild_match(atype,pix.mm)=0 then iterate
  if pix.mm.!sel='' then iterate
  aa='<img src="'pix.mm.!sel'" 'pix.!include '>'
  return aa
end /* do */
return ""


/*************************/
/* return hrefs.aw if hrefs.aw is "onsite" and ?text/html */
is_useable:procedure expose hrefs. imgs. pix.
parse upper arg aw,onsite,amime,siteonly,isimg

parse  var hrefs.aw . '//' acsite '/' acref
if siteonly='' | siteonly=1 then
      if translate(acsite)<>onsite then return ""

/* else, allow off siters */ 
   if isimg=1 then
        ac2=strip(translate(imgs.aw.!type))
   else
        ac2=strip(translate(hrefs.aw.!type))
   if amime="" then do
       if ac2<>'TEXT/HTML' then 
           return ""            /* non-html, ignore */
        else
           return  '/'acref
   end

/* else compare ac2 to amime */
   ioky=0
   do aw2=1 to words(amime)        /* if found, then we are okay */
      goof=strip(word(amime,aw2))
      if wild_match(ac2,goof)<>0 then ioky=1
      if ioky=1 then leave
   end /* do */
  if ioky=0 then return ""          /* no match */
   return  '/'acref


/***************/
/* return 0 for no, 1 for yes, default otherwise */
is_yes_no:procedure
parse arg aval,def
tdef=strip(translate(aval))
if wordpos(tdef,'Y YES 1')>0 then return 1
if wordpos(tdef,'N NO 0')>0 then return 0
return def


/**********************/
/* make top of return file, and initialize some parameters */
ini_outit:
outit=''
if user_intro1<>'' then do
  afil=stream(user_intro1,'c','query exists')
  if afil<>'' then do
     foo=stream(afil,'c','open read')
     outit=charin(afil,1,chars(afil))
     foo=stream(afil,'c','close')
  end
end
if outit='' then do       /* the generic intro */
  outit='<html><head><title>CheckLink: Create An Index </title></head><body ' back_1'> 'crlf 
  outit=outit||'<h2 align=center> Index of 'servername' </h2>' crlf 
end

thelist.0=0; thelist.!levels=0
do mm=1 to hrefs.0
       hrefs.mm.!done=0
end /* do */
do mm=1 to imgs.0
       imgs.mm.!done=0
end /* do */


return 1

/************************/
/* extract or create title */
get_title:procedure expose hrefs. onsite imgs. pix.
parse arg ii,isimg

if isimg=1 then do
     parse var imgs.ii . '//' bsite '/' aa
     bsite=translate(bsite)
     if bsite<>onsite then
       return '/'aa' <em> on 'bsite '</em>'
     else
        return '/'aa
end

if  symbol('HREFS.'ii'.!TITLE')<>'VAR' then do
     parse var hrefs.ii . '//' bsite '/' aa
     bsite=translate(bsite)
     if bsite<>onsite then
       return '/'aa' <em> on 'bsite '</em>'
     else
        return '/'aa
end /* do */
return hrefs.ii.!title

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




/************************/
/* wild card match, with comparision against prior wild card match */
*/

wild_match:procedure
parse upper arg needle, haystack,oldresu


 aresu=awild_match(needle,haystack)
 if strip(aresu)=0 then return 0     /* no match */
 return 1

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
 

/**********************/
/* write a table */
write_a_table:
parse arg igoof
istart=istart.igoof ; tellurl=tellurl.igoof
foo=add_thelist(istart,1)
hrefs.istart.!done=1                /* in "level 1" */

wow=do_uls2(istart,2)    /* the recursive procedure */
return 1

/*****************************************/
/* drop from  thelist */
drop_thelist:procedure expose thelist. 

parse arg drops

oof=0
thelist2.!Levels=0

aexs.0=words(drops)
do ii=1 to aexs.0
     aex=strip(word(drops,ii)) ; aexs.ii=strip(aex,'l','/')
end /* do */

do mm=1 to thelist.0
   aref0=thelist.mm.!link
   parse var aref0 . '//' . '/' aref
   aref=strip(aref,'l','/')
   do ii=1 to aexs.0
     pp= wild_match(aref,aexs.ii)
     if pp<>0 then do                 /* matched == so exclude from recursion */
         iterate mm
     end /* do */
   end

/* else, retain it */

  oof=oof+1
  thelist2.oof.!Img=''
  if symbol('THELIST.'mm'.!IMG')='VAR' then do
      thelist2.oof.!img=thelist.mm.!img
  end
  thelist2.oof.!title=thelist.mm.!title
  thelist2.oof.!desc=thelist.mm.!desc
  thelist2.oof.!link=thelist.mm.!link
  llvel=thelist.mm.!level
  thelist2.oof.!level=llvel
  thelist2.!levels=max(thelist2.!levels,llvel)
end

thelist2.0=oof

drop thelist.
oo=cvcopy(thelist2,thelist)
drop thelist2.
return 1



/*****************************************/
/* add to thelist */
add_thelist:procedure expose thelist. showdesc hrefs. pix.
parse arg ifoo,llvel

title1=get_title(ifoo)

adesc1=''
  
if showdesc=1 &  symbol('HREFS.'ifoo'.!DESCRIP')='VAR' then 
    adesc1=hrefs.ifoo.!descrip

/* we have start of this web index. Create root url */

piximg=make_pix(hrefs.ifoo.!type)

oof=thelist.0+1
thelist.oof.!img=piximg
thelist.oof.!title=title1
thelist.oof.!desc=adesc1
thelist.oof.!link=hrefs.ifoo
thelist.oof.!level=llvel
thelist.!levels=max(thelist.!levels,llvel)
thelist.0=oof
return 1

/*****************************************/
/* for all text/htmls in reflist, display title */
do_uls2:procedure expose onsite hrefs. imgs. pix. showdesc ,
                    crlf multishow typelist siteonly exclusions thelist.
parse arg hii,level


reflist=hrefs.hii.!reflist
if reflist='' then return 0

/* mark the !done field for each entry in this reflist */

lvlist=''
do ii=1 to words(reflist)               /* keep all these on this lvel */
   aw=strip(word(reflist,ii))
   alevel=hrefs.aw.!done
   lvlist=lvlist' 'alevel
   if alevel>level | alevel=0 then hrefs.aw.!done=level
end 

do mm=1 to words(reflist)               /* for each entry in the reflist */
   aw=strip(word(reflist,mm))
   eek=is_useable(aw,onsite,typelist,siteonly)
   if eek='' then iterate
   bdone=strip(word(lvlist,mm))      /* level BEFORE being "kept on this level */

   if bdone<>0 then do                 /* been indexed, do it again? */
        if multishow=0 then iterate     /* no, one appearance per url */
        if multishow=1 then do
           if bdone<=level then iterate /* indexed at a lower or same level-- suppress */
        end
        if multishow=2 then do
          if bdone<level then iterate   /* indexed at a lower level-- suppress */
        end
        if multishow=3 then do          /* used with multi=1, cleanup*/
             if bdone<level  then iterate
             if bdone=level & hrefs.aw.!tie>0 then iterate  /* not first tie */
             hrefs.aw.!tie=1
        end  /* Do */
   end

   foo=add_thelist(aw,level)

/* recurse! -- but check "exclusions" first */
   if exclusions<>'' then do
      parse var hrefs.aw . '//' . '/' aref
      aref=strip(aref,'l','/')
      do ii=1 to words(exclusions)
           aex=strip(word(exclusions,ii)) ; aex=strip(aex,'l','/')
           pp= wild_match(aref,aex)
           if pp<>0 then do    /* matched == so exclude from recursion */
               iterate mm
           end /* do */
      end
   end
   foo=do_Uls2(aw,level+1)

/* do images at end of ul list */

end /* do */

foo=do_imgs2(hii,level+1)

return 1

/*****************************************/
/* for all text/htmls in reflist, display title */
do_imgs2:procedure expose onsite hrefs. imgs. pix. thelist. ,
                         crlf multishow typelist siteonly exclusions
parse arg ii,level

imglist=hrefs.ii.!imglist
if imglist='' then return 0

do mm=1 to words(imglist)               /* for each entry in the reflist */
   aw=strip(word(imglist,mm))
   eek=is_useable(aw,onsite,typelist,siteonly,1) 
   if eek='' then iterate
   bdone=imgs.aw.!done

   if bdone<>0 then do                 /* been indexed, do it again? */
        if multishow=0 then iterate     /* no, one appearance per url */
        if multishow=1 then do
           if bdone<=level then iterate /* indexed at a lower or same level-- suppress */
        end
        if multishow=2 then do
          if bdone<level then iterate   /* indexed at a lower level-- suppress */
        end
        if multishow=3 then do          /* used with multi=1, cleanup*/
             if bdone<level  then iterate
             if bdone=level & imgs.aw.!tie>0 then iterate  /* not first tie */
             imgs.aw.!tie=1
        end  /* Do */
   end

   piximg=make_pix(imgs.aw.!type)
   if showdesc=1 & symbol('HREFS.'aw'.!DESCRIP')='VAR' then adesc=hrefs.aw.!descrip

   oof=thelist.0+1
   thelist.oof.!img=piximg
   thelist.oof.!title=' '
   thelist.oof.!link=imgs.aw
   thelist.oof.!desc=' '
   thelist.oof.!level=level 
   thelist.0=oof
   thelist.!levels=max(thelist.!levels,level)

   imgs.aw.!done=level

end /* do */
return 1

/*******************************/
/* index customization */
doing_custom:
outtype=1
thelist.0=0 ; doshowul=0
header=''
drop cmts.

do forever              /* parse out list */
   if list00='' then leave
   parse var list00 a1 '&' list00

   parse var a1 a1a '=' a1b
   a1a=strip(translate(a1a))

   if a1a='CUSTOM' then iterate

   if a1a='SERVERNAME' then do
      servername=a1b
      iterate
   end /* do */
   if a1a='ULSHOW' then do
     doshowul=a1b
     iterate
   end
   if a1a='HEADER' then do
      header=strip(packur2(translate(a1b,' ','+'||'00090d0a'x)))
      iterate
   end /* do */

   if a1a='TYPE' then do
      outtype=a1b
      iterate
   end /* do */

   if abbrev(a1a,'COMMENT')=1 then do
      parse var a1a  . '_' nth '_' avar
      avar=strip(upper(avar)); nth=strip(nth) 
      if wordpos(nth,'1 2 3 4 5 ')=0 then iterate
      if avar='LVL' then    cmts.nth.!lvl=strip(a1b)
      if avar='POS' then   cmts.nth.!pos=strip(a1b)
      if avar='' then    cmts.nth.!tit=strip(packur2(translate(a1b,' ','+'||'00090d0a'x)))
      iterate
   end /* do */

   parse var a1a  a1a1 '_' a1a2
   iv=substr(a1a1,2)
   ua='!'a1a2
   aaval=strip(packur2(translate(a1b,' ','+'||'00090d0a'x)))
   thelist.iv.ua=aaval
   thelist.0=max(thelist.0,iv)
end /* do */

inm=0
do mm=1 to thelist.0
   yeek=thelist.mm.!pos
   if yeek=0 | yeek=' ' then iterate
   if datatype(yeek)<>'NUM' then iterate
   inm=inm+1
   goob.inm=left(yeek,8)' 'mm
end /* do */

/* add comments? */
do ll=1 to 5
    if symbol('CMTS.'ll'.!POS')<>'VAR' then iterate
    if cmts.ll.!Pos='' then iterate
    else
    inm=inm+1
    goob.inm=left(cmts.ll.!POS,8)' -'ll
end /* do */

goob.0=inm
hoy=arraysort(goob,1,goob.0,1,8,'A','N')

thelist2.0=goob.0; thelist2.!levels=0

do kk=1 to goob.0
   parse var goob.kk . newkk ; newkk=strip(newkk)

   if newkk<0 then do           /* a comment */
       newkk=-newkk
       thelist2.kk.!level=cmts.newkk.!lvl
       thelist2.kk.!title=cmts.newkk.!tit
       thelist2.kk.!img='' ; thelist2.kk.!link='' ; thelist2.kk.!desc=''
   end
   else do        
     thelist2.kk.!LEVEL=thelist.newkk.!LVL
     thelist2.!levels=max(thelist2.!levels,thelist2.kk.!level)
     thelist2.kk.!TITLE=thelist.newkk.!TIT
     thelist2.kk.!DESC=''
     if symbol('THELIST.'newkk'.!DSC')='VAR' then
         thelist2.kk.!DESC=thelist.newkk.!DSC
     thelist2.kk.!IMG=thelist.newkk.!PIX
     thelist2.kk.!LINK=thelist.newkk.!HREF
   end
end /* do */
drop thelist.
foo=cvcopy(thelist2,thelist)

/* write it out */
outind=''
outit='<html><head><title>CheckLink: Create An Index </title></head><body ' back_1'> 'crlf 
if header='' then
  header="Index of " servername
outit=outit||'<h2 align=center>'header' </h2>' crlf 

select
   when  outtype=3 | outtype="CUSTOM"  then do  /* CUSTOMizer */
       call write_as_custom
   end

   when outtype=2 | outtype='TABLE' then do  /* a table */
      call write_as_table
   end /* do */

   otherwise do                 /* ul list */
     call write_as_ul
   end   /* otherwise */
end
return 1

