/* CheckLink standalone utility to "fix" html documents. 
   This will simply place notes in HTML documents that indicate where
   this is a bad link. */


/*********          BEGIN USER CONFIGURABLE PARAMETERS              ********/
/* these can be used to tune performance and modify the output.             */

/* default to use when linkfile not specified */
default_linkfile='chek_res.stm'

/* default output file name */
default_outputfile='chek_fix.htm'

/* directory to store "link" files. If not specified, use the current dir */
linkfile_dir=' '   

/* used to bgcolor (or background) the rows of the results TABLEs    */
row_color.0='bgcolor="#bbcc66"'     
row_color.1='bgcolor="#0accdd"'             

row_colora.0='bgcolor="#bbc000"'                
row_colora.1='bgcolor="#aac000"'                 

row_color.0='bgcolor="#ccbbaa"'     
row_color.1='bgcolor="#aabbcc"'             

row_colora.0='bgcolor="#ddccbb"'                
row_colora.1='bgcolor="#bbccdd"'                 


/* program string for displaying html output                          */
vu_prog='NETSCAPE -l en '    


/**************** END USER CONFIGURABLE PARAMETERS **********************/      

call load               /* load libs, etc */

say bold cy_ye
say "CheckLink Busted Links Utility, ver 1.13a "normal
say
gotopt=0
do forever
  ii=yesno(" Are you ready to continue ",'No Yes Help ','Y')
  if ii==0 then do
    say " See you later... "
    exit
  end

  if ii=1 then leave

  afoo=stream('CHEKLINK.TXT','c','query exists')
  if afoo='' then do
      say "Sorry, the documentation file (CHEKLINK.TXT) is not available."
      iterate
  end 
  foo=vu_prog' file:///'||afoo
  '@start /f 'foo
   say " >>> view CHEKLINK.TXT with " vu_prog
   say"       (it might take a few seconds)"
   say 
   iterate
end

call get_opts 

if symbol('BG.!version')<>'VAR' then do             /* name of this webtree */
  say bold "Sorry. "normal
  say "   This utility requires link files produced by Checklink Ver 1.13 (or above) "
  exit
end
if bg.!libver<'1.13a' then do
  say bold "Sorry. "normal
  say "   This utility requires link files produced by Checklink Ver 1.13 (or above) "
  exit
end

say
say bold"Web Tree Name: "normal||bg.!treename
say bold"     Created: "normal||bg.!creation
say bold'# of Anchors: 'normal||hrefs.0||bold||'    # of Images: '||normal||imgs.0

call write_head

/* find FILES with busted links */

call outit '<table>'
call outit '<table><tr><th>&nbsp</th><th>URL <th>Type, size <br><em>or error code</em><br>last-modified'
call outit ' <th># of busted links, # of busted image links </th>'

ngot=0
ifoo=1
do mm=1 to hrefs.0

  hname=translate(strip(hrefs.mm))
  if abbrev(hname,'FILE:///')=0 then iterate  /* not local file, so we can't change it */
  if words(hrefs.mm.!reflist)=0 then iterate /* no links known about, so nothing to note as bad */

  ngot=ngot+1
  ikeep=' '
  do mm0=1 to words(hrefs.mm.!reflist)
     imm=strip(word(Hrefs.mm.!reflist,mm0))
     jss=hrefs.imm.!size
     if jss=-1 | jss=-2 then do
             ikeep=ikeep' 'imm
      end 
  end 

  imgkeep=' '
  do mm0=1 to words(hrefs.mm.!imglist)
     imm=strip(word(Hrefs.mm.!imglist,mm0))
     jss=imgs.imm.!size
     if jss=-1 | jss=-2 then do
             imgkeep=imgkeep' 'imm
      end 
  end 

  if ikeep||imgkeep=' ' then iterate

  ifoo=1-ifoo
  ac1=row_color.ifoo
  ac2=row_colora.ifoo

  call outit '<tr 'ac1'>'
  ah=breakup(hname,34,rooturl)
  bh0='<a name="J'||mm'">'||mm||'. </a> '
  bh='<a href="'||hname||'">'||ah||'</a>'
  if hrefs.mm.!title<>'' then bh=bh||'<br><em>'||hrefs.mm.!title||'</em>'
  call outit '<td> ' bh0 '</td>'

  call outit '<td> ' bh '</td>'

  asi=hrefs.mm.!size
  if asi<0 then do
     iasi=abs(asi) ; asi='<b>'codes.iasi'</b>'
  end
  call outit '<td> 'hrefs.mm.!type', 'asi||'<br>'hrefs.mm.!lastmod'</td>'
  call outit '<td> '||words(ikeep)||', '||words(imgkeep)||'</td>'

/* now read in this file */
  parse var hname . '///' afile 
  afile=translate(afile,'\:','/}')
  foo=stream(afile,'c','open read')
  if abbrev(translate(foo),'READY')<>1 then do
       call outit '<tr><td> &nbsp; </td><td colspan=3>Can not open file:<tt>'afile'</tt></td>'
       iterate
  end
  iaa=stream(afile,'c','query size')
  if iaa=0 | iaa='' then do
       call outit '<tr><td> &nbsp; </td><td colspan=3>Empty or missing file:<tt>'afile'</tt></td>'
       iterate
  end
  stuff=charin(afile,1,iaa)
  foo=stream(afile,'c','close')

  call outit '<tr><td> &nbsp; </td><td colspan=3>Read 'iaa' bytes from:<tt>'afile'</tt></td>'

  if stuff=0 | stuff="" then do
     call outit '<tr><td> &nbsp; </td><td colspan=3>Empty file:<tt>'afile'</tt></td>'
     iterate
  end
  aa=sysfiletree(afile,'f2.','FT')
  parse var f2.1 fdate .
   if strip(fdate)<>hrefs.mm.!lastmod then do
     call outit '<tr><td> &nbsp; </td><td colspan=3><b>Warning</b>: file date ('fdate') does not match recorded date of 'hrefs.mm.!lastmod
   end 

   base=filespec('d',afile)||filespec('p',afile)
   base='FILE:///'||strip(base,,'\')||'\'
   baseurl=base
   rooturl=filespec('d',base)||'\'
   goo=base_element(stuff)  
   if goo<>'' then base=goo
   call outit '<tr><td> &nbsp; </td><td colspan=3>Base is: <tt>'base'</tt></td>'

   IF MKNOTE>1 THEN CALL LOOK_LINKS  /* ADD COMMENTS INTERNALLY */

   if mknote>0 then do

     call add_info                 /* add comment to end of stuff */

/* replace, or rename, old file. */
   
    if dodisp=0 then do          /* delete */
      foo=sysfiledelete(afile)
      if foo<>0 then do
        call outit '<tr><td> &nbsp; </td><td colspan=3>Problem 'foo'erasing 'afile
        iterate
      end
    end 
    else do               /* rename */
      ioo=lastpos('.',afile)
      if ioo=0 then ioo=length(afile)+1
      ttfile=left(afile,ioo-1)||'.???'
      ttfile=dostempname(ttfile)
      foo=dosrename(afile,ttfile)
      if foo=0 then do
        call outit '<tr><td> &nbsp; </td><td colspan=3>Unable to rename 'afile' to 'ttfile
        iterate
      end
      call outit '<tr><td> &nbsp; </td><td colspan=3>Rename 'afile' to 'ttfile
    end
/* now write the results */
    ifoo=charout(afile,stuff,1)
    if ifoo<>0 then do
       call outit '<tr><td> &nbsp; </td><td colspan=3>Problem writing 'ifoo'bytes to 'afile
    end 
    call outit '<tr><td> &nbsp; </td><td colspan=3>List of busted links added to 'afile

    oo=stream(afile,'c','close') 
  end                   /* MKNOTE > 0 */

  
end 

if ngot=0 then call outit '<tr><td colspan=3>Did not find any FILE:/// URLS with busted links'
call outit '</table>'

call outit '</body></html>'
call lineout outfile

say bold"Done writing "normal||outfile
say "   Viewing results in "outfile
foo=vu_prog' file:///'||stream(outfile,'c','query exists')
say "       (it might take a few seconds)"

'@start /f 'foo


exit


/********/
/* add comment on bad links to end of stuff */
add_info:

crlf='0d0a'x
if ikeep<>'' then do
addit='<!-- List of busted links found by CheckLink on 'bg.!creation ||crlf
alist=ikeep
do until alist=''
  parse var alist alink alist ; alink=strip(alink)
  aref=hrefs.alink
  jss=abs(hrefs.alink.!size)
  amess=left(codes.jss,23,' ')
  addit=addit||amess||aref||'   '||crlf
end 
addit=addit' -->'||crlf
end

if imgkeep<>'' then do
addit=addit||'<!-- List of busted image links found by CheckLink on 'bg.!creation ||crlf
alist=imgkeep
do until alist=''
  parse var alist alink alist ; alink=strip(alink)
  aref=imgs.alink
  jss=abs(imgs.alink.!size)
  amess=left(codes.jss,23,' ')
  addit=addit||amess||aref||'   '||crlf
end 
addit=addit' -->'||crlf
end

stuff=stuff||crlf||addit
return 1



/*********************************/
/* search for a <BASE element in the HEAD */
base_element:procedure expose  verbose screens.
parse arg stuff
crlf='0d0a'x

if stuff=0 | stuff="" then return ""

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

    if (translate(word(tag,1)))='BASE' then do
         parse var tag . '=' . '"' ee '"'
         return ee
    end

end
return ""


/* ====================  END OF MAIN PROGRAM  ===================== */

/**************/
/* ask and read an input file */
getin:

do forever

call lineout,bold " Enter a CheckLink 'links' file (?=help) "normal
call charout,"  "reverse " :" normal
parse pull linkfile  
if linkfile='' then linkfile=default_linkfile

linkfile=strip(linkfile) ;tlinkfile=translate(linkfile)

if tlinkfile='EXIT' then do
   say "bye "
   exit
end

if abbrev(tlinkfile,'?DIR')=1 then do
    parse var linkfile . thisdir

    if thisdir="" then do
       thisdir=strip(directory(),'t','\')||'\*.*'
    end
    say
    say reverse ' List of files in: ' normal bold thisdir normal
    do while queued()>0
            pull .
    end 
    toget=thisdir
   '@DIR /b  '||toget||' | rxqueue'

    foo=show_dir_queue('*')
    say
    linkfile=''
    iterate
end

if abbrev(tlinkfile,'?NETDIR')=1 then do
     parse var tlinkfile . adir0 .
     if adir0='' then adir0=directory()
     if pos(':',adir0)=0 then do
          adrive=filespec('d',directory())
          adir0=adrive||adir0
     end 
     adir0=strip(adir0)
     if right(adir0,1)=':' then adir0=adir0||'\'
     adir=translate(adir0,'/','\')
     adir=translate(adir,'|',':')
     foo=vu_prog' "file:///'||adir||'"'
     '@start /f 'foo
     say " >>> listing "adir0" with " vu_prog
     say "       (it might take a few seconds)"
     iterate
end

if linkfile=' ' | linkfile='?' then do
   call sayhelp
   linkfile=''
   iterate
end 

/* maybe it's actually a file name */

/* is it from a netscape "copy link location" */
if abbrev(tlinkfile,'FILE:///')=1 then do         /* convert to normal format */
   parse var tlinkfile . 'FILE:///' tlinkfile
   tlinkfile=decodekeyval(tlinkfile)
   linkfile=translate(tlinkfile,'\: ','/|+')
end 

linkfile0=linkfile
if pos('.',linkfile)=0 then linkfile=linkfile||'.stm'
if pos(':',linkfile)=0 & left(linkfile,1)<>'/' & linkfile_dir<>'' then do
   linkfile=strip(linkfile_dir,,'\')||'\'||linkfile
end

stmfile=stream(linkfile,'c','query exists')      
if stmfile='' & pos('.',linkfile0)=0 then stmfile=stream(linkfile0,'c','query exists')
if stmfile='' then stmfile=stream(linkfile0||'.html','c','query exists')

if stmfile='' then do
    Say "Sorry. could not find: " linkfile
   iterate
end 

klen=stream(stmfile,'c','query size')
if klen=0 then do
   say " Sorry -- " stmfile " is empty "
   linkfile=''
   signal getin
end 

Say "   Reading " klen " characters from " linkfile
oo=cvread(linkfile,bg)
if oo=0 then do
    say 'No such link-file: ' linkfile
end

yow2=cvcopy(bg.!hrefs,hrefs)
yow2=cvcopy(bg.!imgs,imgs)

default_linkfile=linkfile

return 1

/*********/
/* help ... */
sayhelp:
sayhelp:
say
say cy_ye' Welcome to the CheckLink 'ChekFix' Utility'normal
say 
say "ChekFix is used to place notes in files that contain 'busted' links."
say "ChekFix uses a CheckLink 'link' file to determine which files have busted"
say "links, and to determine which links in these files are busted."
say "ChekFix will places notes in these files, notes which you can use later"
say "to help fix these files."
say
say "Please enter the name of a links file. Or, you can enter one of the "
say "following options: "
say "  "bold"?DIR"normal" : DIR listing of current directory "
say "  "bold"?DIR adir "normal" : DIR listing of the 'adir' directory "
say "  "bold"EXIT"normal" : EXIT the program "
say "  "bold"?NETDIR"normal" : Use "vu_prog" to list & select a  file "
say
say "Notes:"
say "   * this utility will NOT verify, or otherwise check, URLS -- it "
say "     ONLY uses the information in the link file. "
say "   * ChekFix ONLY works on FILE:/// URLS -- it makes NO attempt to "
say "     retrieve files using TCP/IP."
say "   * The default input file= "default_linkfile
return 1


/*********/
/* show stuff in queue as a list */
show_dir_queue:procedure expose qlist.
parse arg lookfor
    ibs=0 ;mxlen=0
    if lookfor<>1 then
       nq=queued()
     else
        nq=qlist.0
    do ii=1 to nq
       if lookfor=1 then do
          aa=qlist.ii
          ii2=lastpos('\',aa) ; anam=substr(aa,ii2+1)
       end /* do */
       else do
          parse pull aa
          if pos(lookfor,aa)=0 & lookfor<>'*' then iterate
          parse var aa anam (lookfor) .
          if strip(anam)='.' | strip(anam)='..' then iterate
       end
       ibs=ibs+1
       blist.ibs=anam
       mxlen=max(length(anam),mxlen)
    end /* do */
arf=""
do il=1 to ibs
   anam=blist.il
   arf=arf||left(anam,mxlen+2)
   if length(arf)+mxlen+2>75  then do
        say arf
        arf=""
   end /* do */
end /* do */
if length(arf)>1 then say arf
say
return 1


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


/**********/
/* get output file */
getout:
do forever
 call charout,'  'reverse'Output file (?=help):'normal' '
 pull outfile
 if strip(outfile)='?' then do
      say "  The output file will be an HTML document containing the report."
      say "  Leave this blank to use: "default_outputfile
      iterate
  end
  if outfile='' then do
     outfile=Default_outputfile
     say "  Using: " outfile
  end
  if pos('.',outfile)=0 then outfile=outfile'.htm'
  if stream(outfile,'c','query exists')<>' ' then do
         goo=yesno('    |File exists. Overwrite? ',,'Y')
         if goo=1 then do
            goo=sysfiledelete(outfile)
            return 1
         end
         iterate
  end  
  oo=stream(outfile,'c','open write')
  if abbrev(translate(oo),'READY')=1 then do
     default_outputfile=outfile
     return 1
  end
  say "Can't open file, try a different name"
end


/**********/
/* get options */
get_opts:

do forever

call getin
call getout

say
do forever
  mknote=yesno('Record in original files ','No Comments Busted_links All_links Help ','C')
  if mknote=4 then do
     call help_mknote
     iterate
  end
  leave
end

say_something=0
if mknote=3 then say_something=1

say
do forever
  if mknote=0 then leave                /* not relevant */
   dodisp=yesno("  |Disposition of old files ",'Delete Rename Help','R')
  if dodisp=2 then do
     call help_disp  
     iterate
  end
  leave
end


askok:
noyes.0='No' ; noyes.1='Yes'
redel.0='Delete' ; redel.1='Rename'

mkn.0='No'
mkn.1='In comment at end of file'
mkn.2='In comment at end of file, and in busted link elements'
mkn.3='In comment at end of file, and in ALL link elements'

say
say reverse"Selected options: "normal
say " Link file: " linkfile
say " Output file: "outfile
say " Record results: "mkn.mknote
if mknote>0 then say " Rename or delete old files: "redel.dodisp

oo=yesno('Use these parameters? ')
gotopt=0
if oo=1 then return 1

end             /* do it again */


/**********/
help_disp:

say
say bold'Help for:'bold"Disposition of old files "normal
say
say "ChekFix will add notes to each file that has busted links."
say "ChekFix can then do either delete or rename the old file:"
say "Delete : delete the old version, and replace it with this new one "
say "Rename:  rename the old version (using a .1, .2, etc. sequence) "
say
return 1


/*********/
help_mknote:
say
say bold'Help for:'normal"Record in original files" normal
say
say "In each file that contains busted links, ChekFIX can write information."
say "You can select just what to record, and where to record it."
say bold" No "normal
say "     Do not record information. Files will NOT be modified)"
say bold" Comments"normal
say "     Add a long HTML comment at the end of the file, that lists"
say "     the busted links (and what type of error was encountered)"
say bold" Busted_links"normal
say '     In addition to writing comments, place a special "tag"'
say '     in the busted link elements. For example, if '
say '        <a href="http://foo.bar.net/hello.htm"> '
say '     points to a missing resource, then change this to '
say '        <a href="http://foo.bar.net/hello.htm" CheckLink="missing resource">'
say bold" All_links "normal
say '     In addition to Comments and Busted_link, add an informative "tag" '
say "     to okay links. This tag either lists the reported size of the"
say "     resource, or indicates that the link was not checked"
say
say 'Note: in all cases, ChekFIX will write an overall report that summarizes'
say "      what FILES have busted links."
return
say

return 1

/*********/
/* write top of output file */
write_head:

call outit '<html><head><title>CheckLink Busted Links Utility </title></head>'
call outit '<body>'
call outit '<h3>CheckLink Busted Links Utility </h3>'
call outit '<ul>'
call outit '<li><b>   Link file</b>: ' linkfile
call outit '<li><b>WebTree Name</b>: ' bg.!treename
call outit '<br><b>     Created</b>: 'bg.!creation
call outit '<li><b>Starter-URL</b>: 'hrefs.1
call outit'<br><b>Base-URL</b>: 'bg.!baseurl
call outit'<br><b>Root-URL</b>: 'bg.!rooturl
call outit '<li><b># of Anchors</b>: ' hrefs.0||'<br><b># of Images</b>: 'imgs.0

call outit '<li> Record results: 'mkn.mknote
if mknote>0 then call outit '<br> Rename or delete old files: 'redel.dodisp

call outit '</ul>'

return 1


/***********/
/* write line to putput file */
outit:
parse arg aa
call lineout outfile,aa
return 1


/* -------------------- */
/* choose between 3 alternatives (by default,a yes or no ),
return 1 if yes (or 0,1,2 for chosen altenative ) */

yesno:procedure
parse arg amessage , altans,def,arrowok
ahdr=''
if pos('|',amessage)>0 then parse var amessage ahdr '|' amessage
aesc='1B'x
cy_ye=aesc||'[37;46;m'
cyanon=cy_ye
normal=aesc||'[0;m'
bold=aesc||'[1;m'
re_wh=aesc||'[31;47;m'
reverse=aesc||'[7;m'

if altans='' then altans='No Yes'

aynn=' '
if def='' then do
 defans=''
end
else do
 if datatype(def)='NUM' then do
    dd=def+1
    dd2=word(altans,dd)
    defans=translate(left(strip(dd2),1))
 end
 else do
    defans=translate(left(strip(def),1))
 end
end

w.0=words(altans)
do iw0=1 to w.0
     w.iw0=strip(word(altans,iw0))
     a.iw0=translate(left(w.iw0,1))
     aa.iw0=substr(w.iw0,2)
     aynn=aynn||bold
     if  a.iw0=defans then aynn=aynn||cy_ye
     aynn=aynn||a.iw0||normal||aa.iw0
     if iw0<w.0 then aynn=aynn'|'
end
if arrowok=1 then aynn=aynn||' [UP]'
do forever
 foo1=normal||ahdr||reverse||amessage||normal||aynn||' 'normal
 if length(amessage)+length(altans)<78 then
    foo1=normal||ahdr||reverse||amessage||normal||aynn||' 'normal
 else
    foo1=normal||ahdr||reverse||amessage||normal||'0d0a'x||'    '||aynn||' 'normal
 call charout, foo1
 anans=translate(sysgetkey('echo'))
 ianans=c2d(anans)
 if ianans=27 then return defans
 if anans='' | ianans=13 | ianans=10 then  anans=defans

 if arrowok=1 & ianans=0 then do
     ians=c2d(sysgetkey('noecho'))
     if ians=72 then  do
           say ;say
           return -1  /* -1 : up key */
     end
 end /* do */

 do ijj=1 to w.0
    if abbrev(anans,a.ijj)=1 then do
        say
        return Ijj-1
    end
 end /* do */
 call charout,'0d'x
end



/************/
/* <BR>eak a long url (for use in cell of table as target of link)
   alen -- max width (between <BR>
   nosn -- strip out http://xxx.yy/ portion 
*/

breakup:procedure
parse arg aword,alen,homesite

if abbrev(translate(aword),'FILE:///')=1 then do
   parse upper var aword . 'FILE:///' oof
   if length(oof)>alen then do
      parse var oof oof '?' junk
      oof=filespec('d',oof)||filespec('p',oof)||'<br>'||filespec('n',oof)
      if junk<>'' then oof=oof'<br>?'||junk
  end
  return oof
end

if pos('//',homesite)>0 then 
   parse upper var homesite . '//' homesite '/' .

homesite=translate(homesite)
parse var aword . '//' aword
nosn=0
if homesite<>'' then do
   if abbrev(translate(aword),homesite)=1 then nosn=1
end /* do */

if nosn=1 then do
   parse var aword '/' aword
   if length(aword)<=alen then return '/'aword
   asn='' ; req='/'aword
end /* do */
else do
   if length(aword)<=alen then return aword
   parse var aword asn '/'  req ; asn=asn'/<br>'
end   

parse var req  rq '?' opts

if length(rq)>alen then rq=left(rq,alen)||'...<br>'
if length(opts)>alen then opts=left(opts,alen)'...'
if opts<>'' then rq=rq'?'

return asn||rq||opts


/***************/
/* load libraries, etc */
load:
if \RxFuncQuery("SockLoadFuncs") then do
 nop      /* already there */
end
else do
   call RxFuncAdd "SockLoadFuncs","rxSock","SockLoadFuncs"
   call SockLoadFuncs
   foo=rxfuncquery('sysloadfuncs')
   if foo=1 then do
     call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
     call SysLoadFuncs
   end
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
end

aesc='1B'x
cy_ye=aesc||'[37;46;m'
normal=aesc||'[0;m'
bold=aesc||'[1;m'
re_wh=aesc||'[31;47;m'
reverse=aesc||'[7;m'

codes.0='size unknown'
codes.1='Server not available '
codes.2='Missing resource '
codes.3='Off-site '
codes.4=''
codes.5='Excluded selector  '

return 1


/************************/
/* wild card match, with comparision against prior wild card match */
/* needle : what to look for 
   haystack : what to compare it to. Haystack may contain numerous * wildcard 
             characters
   oldresu : prior return from sref_wild_match; or empty.
Return (depends on oldresu):
  If needle is exact match to haystack: return -1
  If needle does not match haystack (even with wild card checking) : return 0
  If needle wildcard matches haystack, and oldresu='': returns match information
  If needle wildcard matches haystack, and if oldresu<>'' (is a prior 
   return from sref_wild_match), then the current match is compared to
   this oldresu.  If the current match is "better" (has more matching 
   characters early in the string), then : return match info
   If it's worse (or the same): return 0

Basically, -1 means "exact match", 0 means "no match" or "not better match"
(if oldresu not specified, 0 always means "no match"), and everything else
means "wild card match".
*/

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

/*************/
/* parse document, looking for links */
look_links:

taglist.=''
taglist.!BODY=1 ; taglist.!IMG=1
taglist.!A=1  ; taglist.!FRAME=1
taglist.!AREA=1  ; taglist.!EMBED=1
taglist.!link=1  ; taglist.!APPLET=1
taglist.!OBJECT=1

newstuff=''
do until stuff=''
   if stuff='' then leave
   ifoo=pos('<',stuff)
   if ifoo=0 then do            /*no more elements */
      newstuff=newstuff||stuff
      leave
   end 
   newstuff=newstuff||left(stuff,ifoo)
   stuff=substr(stuff,ifoo+1)

   parse var stuff  a2a  .              /* look for anchor or img tag */
   a2b=word(translate(a2a,' ','0d0a0901'x),1)
   a2b=strip(translate(a2b))
   a2bb='!'||a2b
   if pos('>',a2bb)>0 then iterate
   if length(a2bb)>30 then iterate
   if taglist.a2bb<>1 then iterate

   parse var stuff anarg '>' stuff
   anarg0=anarg
   anarg=space(translate(anarg,' ','0d0a09'x))
    abase=''; aref=''

   do forever          
   if anarg=''  then leave
   parse var anarg a1 anarg ; a1=strip(a1)

   isitx=''
   select
      when a2b='BODY' then do
            if abbrev(translate(a1),'BACKGROUND=')=0 then iterate
            parse var a1 . '=' gotimg .
            isitx=check_it(gotimg,1)
     end

     when a2b='IMG' then do
            if abbrev(translate(a1),'SRC=')=0 then iterate
            parse var a1 . '=' gotimg . ; gotimg=strip(strip(gotimg),,'"')
            isitx=check_it(gotimg,1)
     end
 
     when a2b='A' | a2b='AREA' | a2b='LINK' then do
            if abbrev(translate(a1),'HREF=')=0 then iterate
            parse var a1 . '=' gothref . ; 

            gothref=strip(strip(gothref),,'"')

            parse var gothref gothref '#' .     /* toss out internal jumps */
            if gothref="" then  iterate
            isitx=check_it(gothref,0)
     end 

     when a2b='FRAME' | a2b='EMBED'  then do
            if abbrev(translate(a1),'SRC=')=0 then iterate
            parse var a1 . '=' gothref . ; 

            gothref=strip(strip(gothref),,'"')

            parse var gothref gothref '#' .     /* toss out internal jumps */
            if gothref="" then  iterate
            isitx=check_it(gothref,0)
     end 

    when a2b='OBJECT'  then do
            if abbrev(translate(a1),'CODEBASE=')=0 then iterate
            parse var a1 . '=' gothref . ; 

            gothref=strip(strip(gothref),,'"')

            parse var gothref gothref '#' .     /* toss out internal jumps */
            if gothref="" then  iterate
            isitx=check_it(gothref,0)
     end 


       when a2b='APPLET' then do
          if abbrev(translate(a1),'CODE=') + ,
              abbrev(translate(a1),'CODEBASE=')=0 then iterate
                
          if abbrev(translate(a1),'CODEBASE=')=1 then do
                    parse var a1 '"' abase '"' .
          end 
          else do                  /* CODE */
                   parse var a1 '"' aref '"'
          end 
          if aref='' then iterate       /* no CODE= found */
          if left(abase,2)='//'  then abase='http:'abase
     
          if abase<>'' then aref=abase||strip(aref,'l','/')
          isitx=check_it(aref,0)
          leave
       end



    otherwise do
       leave
    end
   end  /* select */
   end                          /* forever loop (look at tags within element */
   if isitx<>'' then anarg0=anarg0||' '||isitx
   newstuff=newstuff||anarg0||'>'

end             /* all elements */

STUFF=NEWSTUFF
return 1


/****************************/
/* add baseurl if needed */
fix_url:procedure
parse arg aref,baseurl,rooturl
aref=strip(strip(aref),,'"')
if left(aref,2)='//' then aref='http:'aref
taref=translate(aref)
if abbrev(taref,'HTTP://')+abbrev(taref,'HTTPS://')>0 then return aref
if abbrev(taref,'FILE:///')=1 then return aref
if abbrev(aref,'/')=0  then 
    aref1=baseurl||aref
else
    aref1=rooturl||strip(aref,'l','/')
return aref1


/********/
/check_a -- check to see if this url has a problem, teturns 'Server not available '
or 'Missing resource ' or ' ' */

check_it:procedure expose hrefs.  baseurl rooturl say_something codes. imgs. 

parse arg aurl,isimg
gothref=fix_url(aurl,baseurl,rooturl)


parse upper var  gothref uaref ':' .        /* non -http are discarded */
if wordpos(uaref,'MAILTO FTP JAVASCRIPT ABOUT GOPHER TELNET')>0 then do
  if say_something=1 then return 'CheckLink="not examined"'
  return " "
end

if isimg=1 then do
do m=1 to hrefs.0
   if gothref=imgs.m then do
     iasi=strip(abs(imgs.m.!size))
     if  imgs.m.!size<0 then do
        if iasi<3 | say_something=1 then  return 'CheckLink="'||codes.iasi||'"'
     end
     if say_something=1 then do 
        if iasi=0 then return 'CheckLink="Length: unknown"'
        return 'CheckLink="Length: '||iasi||'"'
     end 
     return ' '
   end
end
return ' '
end

/* not image ... anchor ! */
do m=1 to hrefs.0
   if gothref=hrefs.m then do
     iasi=strip(abs(hrefs.m.!size))
     if hrefs.m.!size<0 then do
        if iasi<3 | say_something=1 then  return 'CheckLink="'||codes.iasi||'"'
     end
     if say_something=1 then do
        if iasi=0 then return 'CheckLink="Length: unknown"'
        return 'CheckLink="Length: '||iasi||'"'
     end

     return ' '
   end
end
return ' '




