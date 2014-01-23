/* CheckLink standalone utility to produce reports -- for each HTML resource in a 
   web tree, report on its links, or only on its "bad" links */


/*********          BEGIN USER CONFIGURABLE PARAMETERS              ********/
/* these can be used to tune performance and modify the output.             */

/* default to use when linkfile not specified */
default_linkfile='chek_res.stm'

/* default output file name */
default_outputfile='chek_rpt.htm'

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


/* A fully qualified file containing "header" information for each part.
  If ='', then a generic header is used 
  If specified, the file MUST contain at least:
       <HTML><HEAD>.... </HEAD> <BODY ...> <h1>... </h1>                */
user_intro1a=''
user_intro1b=''



/* program string for displaying html output                          */
vu_prog='NETSCAPE -l en '    


/**************** END USER CONFIGURABLE PARAMETERS **********************/      

call load               /* load libs, etc */

toshow='A'
showreflist='S'
showtolist='Y'
exclusion_list=0
inclusion_list='*'

say bold cy_ye
say "CheckLink Report Utility, ver 1.13a "normal
say
gotopt=0
do forever
  ii=yesno(" Are you ready to continue ",'No Yes Load_Options Help ','Y')
  if ii==0 then do
    say " See you later... "
    exit
  end

  if ii=1 then leave

  if ii=2 then do 
    call get_optfile 
    gotopt=1
    iterate
  end
  
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


call get_opts gotopt
gotopt=0

/*toshow = 0=all, 1=anchors, 2=htmls, 3=read htmls, 4=busted htmls */

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

rooturl=bg.!rooturl

itt=max(toshow,1)
call outit '<hr width="50%"><h3 align="center">'toshow_mess.itt' </h3>'

call outit '<table><tr><th>URL <th>Type &amp; size <br><em>or error code</em><br>Last-Modified Date'
call outit ' <th># of resources<br> that contain <br>this URL <th> # of links in this URL <br> (unique <em>total</em> ,  images) '
ifoo=0

do mm=1 to hrefs.0

  hname=hrefs.mm
  if inclusion_list<>''  & strip(inclusion_list)<>'*' then do
     ii=check_inclusion(hname,inclusion_list)
     if ii=0 then iterate
  end 

  if exclusion_list<>'' & strip(exclusion_list)<>'0' then do
     ii=check_exclusion(hname,exclusion_list)
     if ii=1 then iterate
  end 

  htype=strip(hrefs.mm.!type)
  if toshow>1 then do      /* check if is html */
      if translate(htype)<>'TEXT/HTML' then iterate
  end 
  if toshow>2 then do           /* read htmls */
     if hrefs.mm.!queried<>1 then iterate
  end 
  if toshow>3 then do           /* contain busted htmls */
     ikeep=0
     do mm0=1 to words(hrefs.mm.!reflist)
         imm=strip(word(Hrefs.mm.!reflist,mm0))
         jss=hrefs.imm.!size
         if jss=-1 | jss=-2 then do
             ikeep=1
             leave
         end 
     end 
     if ikeep=0 then iterate
  end 

  ifoo=1-ifoo
  ac1=row_color.ifoo
  ac2=row_colora.ifoo

  call outit '<tr 'ac1'>'
  ah=breakup(hname,34,rooturl)
  bh='<a name="J'||mm'">'||mm||'. </a> <a href="'||hname||'">'||ah||'</a>'
  if hrefs.mm.!title<>'' then bh=bh||'<br><em>'||hrefs.mm.!title||'</em>'
  call outit '<td> ' bh '</td>'

  asi=hrefs.mm.!size
  if asi<0 then do
     iasi=abs(asi) ; asi='<b>'codes.iasi'</b>'
  end
  lmod=hrefs.mm.!lastmod
  if lmod='HREFS.'MM'.!LASTMOD' then lmod=' '
  if lmod<>''  then lmod=' <br>'lmod
  call outit '<td> 'htype', '||asi||lmod||'</td>'
  call outit '<td> 'hrefs.mm.!nrefs'</td>'
  call outit '<td> '||words(hrefs.mm.!reflist)||' <em> '||hrefs.mm.!nlinks||' </em> , '||words(hrefs.mm.!Imglist)||'</td></tr>'

/* display jumps to documents that this "appears in * */
 apin=words(hrefs.mm.!appearin)

 if hrefs.mm.!Nlinks=0  & apin=0 then iterate     /* no links (available) in this url */
 if showreflist+showtolist=0 then iterate

  ifoo2=0
  call outit '<tr >'
  call outit '<td colspan=4 align="left">'
  call outit '<table cellpadding=3 'ac1'>'

 if apin>0 & toshow<4 & showtolist=1 then do
     call outit '<tr><td bgcolor="#ffffff"> &nbsp </td>'
     call outit '<td 'ac1' colspan=3><em>Resources w/links to here:</em> &nbsp; &nbsp;'
     arr='' ; arr2=hrefs.mm.!appearin
     do until arr2=''
        parse var arr2 iarr2 arr2 ; iarr2=strip(iarr2)
        arr=arr' <a href="#J'||iarr2||'">'||iarr2||'</a> '
     end 
     call outit ' ' arr '</td></tr>'
 end 

 if hrefs.mm.!Nlinks=0 | showreflist=0 then do     /* no links (available) in this url */
     CAll outit '</table>'
     iterate
 end 
  
 if showreflist=1 then do               /* short list */
     call outit '<tr><td bgcolor="#ffffff"> &nbsp </td>'
     call outit '<td 'ac1' colspan=3><em>Links in this HTML document:</em> &nbsp; &nbsp;'
     arr='' ; arr2=hrefs.mm.!reflist
     do until arr2=''
        parse var arr2 iarr2 arr2 ; iarr2=strip(iarr2)
        tt=hrefs.iarr2.!size
        iarr2b=iarr2
        if hrefs.iarr2.!queried=1 then iarr2b='@'||iarr2

        arr0='<a href="#J'||iarr2||'">'||iarr2b||'</a>'
        if tt=-1 | tt=-2 then     arr0='<em>['||arr0||']</em>'
        if tt=-5 | tt=-3 then     arr0='<eM>'||arr0||'</em>'
        arr=arr||'&nbsp; '||arr0||'&nbsp;  '
     end 
     call outit ' ' arr '</td></tr>'

/* imglist also? */
     if hrefs.mm.!imglist<>'' & toshow<1 then do
        call outit '<tr><td bgcolor="#ffffff"> &nbsp </td>'
        call outit '<td 'ac1' colspan=3><em>Image Links in this HTML document:</em> &nbsp; &nbsp;'
        arr='' ; arr2=hrefs.mm.!imglist
        do until arr2=''
          parse var arr2 iarr2 arr2 ; iarr2=strip(iarr2)
          arr0='<a href="#I'||iarr2||'">'||iarr2||'</a>'
          tt=imgs.imm2.!size
          if tt=-1 | tt=-2 then  arr0='<em>['||arr0||']</em>'
          if tt=-3 | tt=-5 then arr0='<em>'||arr0||'</em>)'
           arr=arr||' '||arr0
        end 
        call outit ' ' arr '</td></tr>'
     end
     CAll outit '</table>'
     iterate
 end

/* if here, long list */
  hah=hrefs.mm
  if length(hah)>20 then hah='...'||right(hrefs.mm,20)
  call outit '<tr 'ac1'>'
  call outit '<th bgcolor="#ffffff">&nbsp</th>'
  call outit '<th colspan=2>links in 'hah' </th>'
  call outit '<th>Type <em>Size</em> </th></tr>'

  do mm2=1 to words(hrefs.mm.!reflist)         /* display links in this html document (if any */
       ifoo2=1-ifoo2
       imm2=strip(word(hrefs.mm.!reflist,mm2))
       if ifoo2=0 then
           ac3=ac1
       else
           ac3=ac2  
       call outit '<tr 'ac3'>'
       call outit '<td bgcolor="#ffffff"> &nbsp; </td> '
       jlink='q'
       tt=hrefs.imm2.!size
       if tt=-1 | tt=-2 then jlink='X'
       if tt=-3 | tt=-5 then jlink='e'
       if hrefs.imm2.!queried=1 then jlink='R' 

       jlink='<a href="#J'||imm2||'">'jlink'</a>'
       call outit '<td 'ac1'>'jlink'</td> '

       ah=breakup(hrefs.imm2,34,rooturl)
       bh='<a href="'||hrefs.imm2||'">'||ah||'</a>'
       call outit '<td > 'bh '</td>'
       asi=hrefs.imm2.!size
       if asi<0 then do
          iasi=abs(asi) ; asi='<B>'codes.iasi'</b>'
       end
       call outit '<td> 'hrefs.imm2.!type'&nbsp;&nbsp;<em>'asi '</em></td> </tr>'
  end 

/*  display images in this doc, if any */
  if toshow=0 then do
  mu=words(hrefs.mm.!Imglist)
  if mu>0 then do
     call outit '<tr 'ac1'>'
     call outit '<th bgcolor="#ffffff">&nbsp</th>'
     call outit '<th colspan=3>image links  </th></tr>'
  end

  do mm2=1 to mu      /* display links in this html document (if any */
       ifoo2=1-ifoo2
       if ifoo2=0 then
           ac3=ac1
       else
           ac3=ac2  
       imm2=strip(word(hrefs.mm.!imglist,mm2))
       call outit '<tr 'ac3'>'
       call outit '<td bgcolor="#ffffff"> &nbsp; </td> '

       jlink='q'
       tt=imgs.imm2.!size
       if tt=-1 | tt=-2 then jlink='<b>X</b>'
       if tt=-3 | tt=-5 then jlink='<b>e</b>'

       jlink='<a href="#I'||imm2||'">'jlink'</a>'
       call outit '<td 'ac1'>'jlink'</td> '

       ah=breakup(imgs.imm2,34,rooturl)
       bh='<a href="'||imgs.imm2||'">'||ah||'</a>'
       call outit '<td> 'bh '</td>'
       asi=imgs.imm2.!size
       if asi<0 then do
          iasi=abs(asi) ; asi=codes.iasi
       end
       call outit '<td> 'imgs.imm2.!type'&nbsp;&nbsp;<em>'asi '</em></td> </tr>'
  end 
  end           /* show image links in this document */

  call outit '</table></td></tr>'
end 
call outit '</table>'

/* image links also? */
if toshow=0 then do
   call outit '<hr width="50%"><h3 align="center">Image URLS </h3>'
  call outit '<table><tr><th>Image URL <th>Type &amp; size <em>or error code</em><br>Last-modified date'
  call outit '<th>Resources with links<br> to this image'
  ifoo=0
  do mm=1 to imgs.0
    ifoo=1-ifoo
    ac1=row_color.ifoo
    call outit '<tr 'ac1'>'
    ah=breakup(imgs.mm,34,rooturl)


    bh='<a name="I'||mm'">'||mm||'. </a><a href="'||imgs.mm||'">'||ah||'</a>'
    call outit '<td> 'bh '</td>'
    asi=imgs.mm.!size
    if asi<0 then do
     iasi=abs(asi) ; asi=codes.iasi
    end

    lmod=imgs.mm.!lastmod
    if lmod<>'' then lmod=' <br>'lmod

    call outit '<td> 'imgs.mm.!type', '||asi||lmod||'</td>'

    arr='' ; arr2=imgs.mm.!appearin
    do until arr2=''
        parse var arr2 iarr2 arr2 ; iarr2=strip(iarr2)
        arr=arr' <a href="#J'||iarr2||'">'||iarr2||'</a> '
     end 
     call outit '<td> ' arr '</td></tr>'

  end 
  call outit '</table>'
end



call outit '</body></html>'
call lineout outfile

say bold"Done writing "normal||outfile
say "   Viewing results in "outfile
foo=vu_prog' file:///'||stream(outfile,'c','query exists')
say "       (it might take a few seconds)"

'@start /f 'foo



exit


/* NOTE on strucure of link file

  img fields
.n and .n.!  APPEARIN NREFS SIZE TYPE 
  
  anchor fields
.n and .n.! APPEARIN  IMGLIST   NLINKS   NREFS
             QUERIED   SIZE      TYPE     REFLIST


.!appearin : ids of urls that "contain"  n  (that n "appears in")
.!nrefs    : # of urls that contain  n          (= # words in n.!appearin)
.!reflist  : ids of urls that n contains  (!imglist is for images)
.!nlinks    : # of urls that n contains (= # words in n.!reflist
.!refered  : url of the first URL that contains n (this URL has the first id in n.!appearin)
.!queried  : -1=not queried,  0=queried,not parsed for links, 
              1=parsed for links, X=html, but not parsed for links 

*/


exit

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
say cy_ye' Welcome to the CheckLink Report Utility'normal
say 
say "This utility will extract information about a web tree, as contained "
say "in a CheckLink 'links' file. It wil use this info to create a report "
say "for each HTML resource in the web tree. "
say "This report lists all the links in the HTML resource, with information  "
say "on the status of the link (at the time the link file was created)."
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
say "   * Hint: URL-encoded filenames (such as FILE:///G%7C/TEMP/CHEK_RES.STM ) "
say "           are automatically converted to normal OS/2 filenames"
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
/* get options file */
get_opts:
parse arg gotopt

do forever

if gotopt=1  then signal askok

call getin
call getout

say
do forever
  atoshow=yesno("  |Show which URLS ",'Everything Anchors Htmls Read_Htmls Busted_Htmls ?elp',toshow)

  if atoshow=5 then do
     call help_toshow
     iterate
  end
  toshow=atoshow
  leave
end

say
do forever
   ashowreflist=yesno('  |Display list of "links in this URL"' ,'No Short Long Help ',showreflist)
   if ashowreflist=3 then do
     call help_reflist
     iterate
   end 
   showreflist=ashowreflist
   leave
end 

do forever
   ashowtolist=yesno('  |Display short list of "URLS that link to this URL"' ,'No Yes Help ',showtolist)
   if ashowtolist=2 then do
     call help_tolist
     iterate
   end 
   showtolist=ashowtolist
   leave
end 

say

say "  Exclusion list. 0=No exclusions. * can be used as wildcard"
call  charout,'    ' reverse'   : 'normal
parse pull aexclusion_list
if aexclusion_list='' then do  /* no change from current value */
   say '  Exclusion list= 'inclusion_list
end
else do
   exclusion_list=aexclusion_list
end 

say
say "  Inclusion list. *=Include all. * can be used as wildcard"
call  charout,'    ' reverse'   : 'normal
parse pull ainclusion_list
if ainclusion_list='' then do  /* no change from current value */
   say '  Inclusion list= 'inclusion_list
end
else do
   inclusion_list=ainclusion_list
end 

askok:
say
say reverse"Selected options: "normal
say " Link file: " linkfile
say " Output file: "outfile
say ' Displaying: 'toshow_mess.toshow
say ' 'messreflist.showreflist
say ' 'messtolist.showtolist
say ' Using inclusion list: 'inclusion_list
say ' Using exclusion list: 'exclusion_list

oo=yesno('Use these parameters? ')
gotopt=0
if oo=1 then return 1

end             /* do it again */


/***************************/
get_optfile:

do forever

call lineout,bold " Enter parameters file (? for help, ?DIR for a directory, EXIT to quit) "normal
call charout,"  "reverse " :" normal
parse pull optfile ; optfile=strip(optfile)

if strip(translate(optfile))='EXIT' then do
   say "bye "
   exit
end

if abbrev(translate(optfile),'?DIR')=1 then do
    parse var optfile . thisdir
    if thisdir="" then do
        thisdir=strip(directory(),'t','\')||'\*.*'
    end
    say
    say reverse ' List of files in: ' normal bold thisdir normal
    do while queued()>0
            pull .
    end /* do */
    toget=thisdir
    '@DIR /b  '||toget||' | rxqueue'
    foo=show_dir_queue('*')
    say
    optfile=''
    iterate
end

if  strip(optfile)='?' then do
   call help_optfile
   optfile=''
   iterate
end /* do */

if optfile='' then optfile='CHEK_RPT.IN'

/* maybe it's actually a file name */

if pos('.',optfile)=0 then optfile=optfile||'.in'
optfile1=stream(optfile,'c','query exists')              

if optfile1='' then do
    Say "Sorry. could not find: " optfile
    return 1
end /* do */

optfilelen=stream(optfile1,'c','query size')
if optfilelen=0 then do
   say " Sorry -- " optfile " is empty "
   stuff=''
   return 1
end 
instuff=charin(optfile1,1,optfilelen)
Say "Reading " optfilelen " characters from " filespec('n',optfile1)
foo=stream(optfile1,'c','close')
say 

/* now set defaults */


toshow='N'
showreflist='S'
showtolist='Y'
exclusion_list=0
inclusion_list='*'

if instuff<>'' then do
   use_linkfile=1
   cmdlist='LINKFILE OUTFILE TOSHOW SHOWREFLIST SHOWTOLIST EXCLUSION_LIST INCLUSION_LIST '
    do until instuff=''
       parse var instuff aline '0d0a'x instuff
       aline=strip(aline)
       if abbrev(aline,';')=1 | aline='' then iterate
       parse var aline avar '=' aval 
       avar=strip(translate(avar)) ;aval=strip(aval)
       if wordpos(avar,cmdlist)>0 then do
          foo=value(avar,aval)
       end 
       else do
            say "Bad command: "aline
       end
    end
    default_linkfile=linkfile
    if stream(linkfile,'c','query exists')='' then do
         say "Error: missing  "linkfile 
         exit
    end 
    default_outputfile=outfile
    if stream(outfile,'c','query exists')='' then do
         say "Deleting pre-existing " outfile
         foo=sysfiledelete(outfile)
    end 
  
    toshow=max(0,pos(toshow,'EAHRB')-1)
    showreflist=max(0,pos(showreflist,'NSL')-1)
    showtolist=max(0,pos(showreflist,'NY')-1)

end


return 1


help_optfile:
say
say bold'Help for:'normal" Using a parameters file " 
say
say "You can read the values of the various ChekRPT parameters from a file."
say
say "Notes: "
say " * the default input file is CHEKRPT.IN "
say " * See CHEKRPT.SMP for a complete & well documented example "
say
return 1


/**********/
help_toshow:
say
say bold'Help for:'normal" Show which URLS " normal
say
say "Select which set of links (to URLS) should be displayed "
say " "bold"Everything"normal": All links (Images and Anchors)"
say " "bold"Anchors"normal": Links to anchors (do not display image links)"
say " "bold"Htmls"normal":  Links to HTML documents"
say " "bold"Read_Htmls"normal":  Links to all retrieved (i.e.; on site) HTML documents"
say " "bold"Busted_Htmls"normal":  Links to all retrieved HTML documents with busted links"
say 
say "Notes: "
say "  * the number of displayed links decreases as you go from ALL to Busted_Htmls "
say "  * retrieved documents are those whose contents were read. Typically, these "
say "    are html/documents on the same server as the starter-URL "
say
return 1

/**********/
help_reflist:
say
say bold'Display list of links in this URL'normal
say
say 'You can display a list of the links found in each "read" html document.'
say 'The short list is just a sequence of numbers, with each number linked to'
say 'an entry in this report.'
say 'The long list contains a hot link to the URL, content-type, and content-size '
say 'information for each of these links (as well as flags for missing '
say 'resources, etc.)"'

say
return 1

/**********/
help_tolist:
say
say bold'Display list of URL that contain links to this URL'normal
say
say 'For all URLS, you can display a simple list of the "read HTML documents" that '
say 'contain links to this URL.  The list consists of a set of numbers, where each'
say 'number corresponds to (and is linked to) one of the "read documents" listed '
say 'in this report.'
say
return 1


/**********/
/* write top of output file */
write_head:

call outit '<html><head><title>CheckLink Report Utility </title></head>'
call outit '<body>'
call outit '<h3>CheckLink Report Utility </h3>'
call outit '<ul>'
call outit '<li><b>   Link file</b>: ' linkfile
call outit '<li><b>WebTree Name</b>: ' bg.!treename
call outit '<br><b>     Created</b>: 'bg.!creation
call outit '<li><b>Starter-URL</b>: 'hrefs.1
call outit'<br><b>Base-URL</b>: 'bg.!baseurl
call outit'<br><b>Root-URL</b>: 'bg.!rooturl
call outit '<li><b># of Anchors</b>: ' hrefs.0||'<br><b># of Images</b>: 'imgs.0

call outit '<li><em>'showtype.toshow '</em>'
call outit '<br><em>'messreflist.showreflist'</em>'
call outit '<br><em>'messtolist.showtolist'</em>'
if inclusion_list<>'' then call outit '<br><em>Using inclusion list:<tt> 'inclusion_list'</tt></eM>'
if exclusion_list<>'' then call outit '<br><em>Using exclusion list:<tt> 'exclusion_list'</tt></eM>'

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

messreflist.0='Not showing links contained in each resource'
messreflist.1='Showing short list of links contained in each resource'
messreflist.2='Showing expanded list of links contained in each resources'

messtolist.0='Do not show a list of resources that have links to each URL'
messtolist.1='Show a list of resources that have links to  each URL'

codes.1='Server not available '
codes.2='Missing resource '
codes.3='Off-site '
codes.4=''
codes.5='Excluded selector  '

showtype.0='Display all links (<a href="#ANCHORS">anchors</a> and <a href="#IMGS">Images</a>)'
showtype.1='Displaying all anchor links '
showtype.2='DIsplaying all anchor links of type text/html '
showtype.3='DIsplaying all anchor links of type text/html that were read (that are on the starter-url''s site) '
showtype.4='DIsplaying all anchor links of type text/html that were read, and that have busted links '

toshow_mess.0='All links '
toshow_mess.1='Anchor links (don''t display image links)'
toshow_mess.2='HTML Resources'
toshow_mess.3='HTML Resource that were read '
toshow_mess.4='HTML Resource with busted links '

return 1


/***************/
/* check selector for match to one of the exclusion lists */
check_exclusion:procedure
parse upper arg asel,alist

do mm=1 to words(alist)
   a1=strip(word(alist,mm)) 
   oo=wild_match(asel,a1)
   if oo<>0 then return 1
end
return 0

/* check selector for match to one of the inclusion lists */
check_inclusion:procedure
parse upper arg asel,alist

do mm=1 to words(alist)
   a1=strip(word(alist,mm)) 
   oo=wild_match(asel,a1)
   if oo<>0 then return 1
end
return 0


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

