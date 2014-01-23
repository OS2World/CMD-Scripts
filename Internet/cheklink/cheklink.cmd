/* CheckLink ver 1.13b
   Check, and create a database of links
   See CHEKLINK.TXT for installation and useage details.
*/

cheklink:


/*********          BEGIN USER CONFIGURABLE PARAMETERS              ********/
/* these can be used to tune performance and modify the output.             */

/* used in <BODY back> element (back_1 for first part, back_2 for 2nd part) */ 
back_1='bgcolor="#668a78"'   
back_2='bgcolor="#bbbbdd"'   /* used for both if use_multi=0 */

/* If check_robot=1, then check starter-url site for a /robots.txt file, 
   and use it to  control extent of search.
   Proper netiquette STRONGLY suggests use of check_robot=1           */
check_robot=1

/* URL pointing to cheklink.htm (used for a "do it again" option 
   in CHEKLNK2). Set cheklink_htm='' to not include this option.      */
cheklink_htm='/cheklink.htm'

/* directory containing checklink procedures. These will be loaded into
  macrospace (assuming they have not already been loaded).
  If '', then use the current directory (the value of directory()).  */
cheklink_libdir=''

/*  Default value for starter-url (standalone mode only              */
starter_url='localhost'

/* default name of output file (standalone line mode only            */
default_outputfile='CHEK_RES.HTM'

/* Double check:
  0= do not 
  1= double check "n.a. servers" 
  2= double check "n.a. servers" AND "missing resources"             */
double_check=2

/* If get_query=0, then use HEAD request for querying. 
   Although more efficient, some servers do not support HEAD requests.
   If you are likely to encounter such sites, set get_query=1 and 
   short GET requests will be used                                   */
get_query=0

/* space delimited list of extensions of html (text/html) files.
  This is used only in standalone mode                               */
html_types='HTM HTML SHT SHTML HTML-SSI'

/* include links to "traverse the webtree with CHEKLNK2 (one for each URL)
  0 = No
  1 = Yes
  2 = Yes if run as SRE-http addon. No if run as standalone program */
include_cheklnk2=2

/* directory to store "linkages" file. If not specified,
   use the OS/2 TEMP directory                                       */
linkfile_dir=''   

maxatonce=4                  /* max threads active (in QUERY section */
maxatonce_get=2                /* max active threads (in GET section */
  
maxage=60                            /* maximum age of a HEAD thread */
maxage2=80                            /* maximum age of a GET thread */


/* maximum # of rows per  subtable in the HTML output file. 
   The list of all URLS will be composed of several subtables,
   each of (up to) MAX_TABLE_ROWS long. Shorter subtables
   will speed up display, and isolate overly wide tables (due to
   LOOOOONNGGG URLS) to a subset of the urls.  However, each
   subtable will have different column sizes, which may be 
   visually displeasing.
   To use just one big table, set MAX_TABLE_ROWS=10000000
*/
max_table_rows=250

/* The proxy server to send http requests through.
 Use a fully specified address, with optional port.
 For example:  proxy.mycompany.com:8080  (do NOT include the leading http://)
 If you are NOT using a proxy server, leave this blank (or set equal to 0)   */
proxy_server=0


/* Set to 1 to remove all <SCRIPT> ... </SCRIPT> and href="JAVASCRIPT: ... "
   elements.   */
remove_script=1

/* used to bgcolor (or background) the rows of the results TABLEs    */
row_color1='bgcolor="#bbcc66"'                  /* odd rows, on-site */
row_color2='bgcolor="#aaccdd"'                  /* even rows         */

row_color1a='bgcolor="#bbaa44"'                 /* odd rows, off-site */
row_color2a='bgcolor="#aaccdd"'                 /* even rows          */

/* # of characters of <TITLE> to display.  The <TITLE> is only available for 
   HTML documents that have been read -- that is, for html documents that are
   "parsed for links". 
   To suppress display of the title, set TITLE_CHARS=0 */
title_chars=50

/* standalone mode intermediate output
   1=none, 2=tiny bit  3 = just a little, 4=steady stream.
   This does NOT effect screen io, it does effect output
   to the PMPRINTIF window, and to the output (HTML) file
   Not: Use 1 if you do NOT want the output  file to contain
         any intermediate info.                                       */
standalone_verbose=1

/* if =1, then only SUPERUSERs can invoke CHEKLINK. Otherwise, anyone can
    (given other sre-http access rights are satisfied). 
    This is ignored in standalone mode                               */
superusers_only=0

/* space delimited list of extensions of plaintext (text/plain) files. 
   This is used only in standalone mode                               */
text_types='TXT FAQ ME LOG LST DOC '

/* A fully qualified file containing "header" information for each part.
  If ='', then a generic header is used 
  If specified, the file MUST contain at least:
       <HTML><HEAD>.... </HEAD> <BODY ...> <h1>... </h1> 
  Note: use of user_intro1a (or user_intro1b) means 
        that back_1 (back_2) are NOT used                             */
user_intro1a=''
user_intro1b=''

/* program string for displaying html output                          */
vu_prog='NETSCAPE -l en '    


/*** The remaining parameters control standalone mode screen output  
     You may need to change them (especially the "frame" characters")
     if you are using a non-english or non "latin 1" code page        */

/* display this "name of the program"     */
topmess="CheckLink ver 1.13b "

/* Vertical frame character */
vchar=d2c(179)

/* Horizontal frame character */
hchar=d2c(196)

/* upper left corner */
ulc=d2c(218)

/* upper right corner */
urc=d2c(191)

/* lower left corner */
llc=d2c(192)

/* lower right corner */
lrc=d2c(217)

/* message foreground and background color codes (defaults=37,46)*/
message_fore=37
message_back=46

/* border foreground and background color codes (defaults=34,42) */
border_fore=34
border_back=42

/* right side vertical panel colors */
vert_fore=42
vert_back=41

/* Note on colors: color combinations may depend on your installation.
   In general, the foreground colors are:
     30 = black     31 = red       32 = green  33 = gold  
     34 = blue      35 = magenta   36 = cyan   37 = white
  Background colors range from 40 to 48.

*/


/**************** END USER CONFIGURABLE PARAMETERS **********************/



/* note:
  get_url: get a url (calls cheklink_get_url as a proc)
  get_url_q: queue up one or several GETS, and retrieve GET results from a queue
  get_url_0: queue a HEAD url (call cheklink_get_url as a daemon)
  cheklink_get_url: macrospace proc. Uses non-blocking socket calls to
                    get a url. Also used as a daemon (returning results via  queue)
*/


parse arg  ddir, tempfile, reqstrg,list,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir,aparam,semqueue,prog_file

servername=strip(servername)

/* default values of parameters */
baseonly=0      /* 1=only GET url's relative to the base of the request (NOT to the root */
queryonly=0     /* 1=just query, do not GET, links (subsumes baseonly */
siteonly=0      /* 1=no query (HEAD check) on off-site urls */

lib_ver='1.13b'   /* used to compare to version in check1.srf */

aurl=''         /* the starter url */

exclusion_list='!*  *?* *MAPIMAGE/* */OLD* */ARCHIVE* CGI*'  /* space delimited list of wildcardable selectors to NOT check */
exclusion_list2=''                              /* the "robot.txt" exclusion list */
use_multi=1       /* use multi-part documents */
outtype='ALL'
linkfile=''
outfilel=''
treename=''  /* default descriptive name */
user_pwd=''      /* default username password */
make_descrip=2   /*1=non, 2=text/html, 3=text/html and text/plain */
result_file=''
ascgi=0         /* type of calls to cheklink2 */

call load               /* load dlls */

if linkfile_dir=0 | linkfile_dir='' then
    linkfile_dir=value('TEMP',,'os2environment')
linkfile_dir=strip(linkfile_dir,'t','\')'\'

foo=time('r')

instuff=' '

second_output=''
dscmax=300
crlf='0d0a'x
imgs.0=0 ; hrefs.0=0 ; hrefs.!start=1
totgot=0
doing_results=0
parse var semqueue mysem myqueue

iterx=0
get_opts:
iterx=iterx+1

if screens.!standalone=1 & include_cheklnk2=2 then include_cheklnk2=0
if screens.!standalone<>1 & include_cheklnk2=2 then include_cheklnk2=1

if verb=" " then do
   call ask_opts iterx
   privset='SUPERUSER'
   screens.!standalone=1
end  

if get_query<>1 then
  query_method='HEAD'
else
  query_method='HEADGET'

if screens.!standalone=1 & include_cheklnk2>1 then include_cheklnk2=0
if screens.!standalone<>1 & include_cheklnk2>1 then include_cheklnk2=1

if strip(proxy_server)=0 then proxy_server=' '
screens.!proxy=proxy_server
screens.!proxyaddr=''
if screens.!proxy<>'' then do
   stuff=cheklink_get_url(25,'DNS',screens.!proxy)
   errcode=substr(stuff,1,1)
   stuff=substr(stuff,22)
   if errcode<>0 then do
      if screens.!standalone=1 then do
         say "ERROR "ecodes.errcode": could not find proxy at "screens.!proxy
      end 
      call pmprintf2("ERROR "ecodes.errcode": could not find proxy at "screens.!proxy)
      call doEXIT
   end 
   SCREENS.!PROXYADDR=strip(stuff)
   IF SCREENS.!STANDALONE=1 THEN say "Using proxy at " screens.!proxyaddr
   if verbose>0 then call pmprintf2("Using proxy at " screens.!proxyaddr)

end

if screens.!standalone=0 then do
  if superusers_only=1 & wordpos('SUPERUSER',privset)=0 then do

      call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 3.0//EN">'
      call lineout tempfile, "<html><head><title>Not authorized </title>"
      call lineout tempfile, '</head><body> '
      call lineout tempfile,' </body> </html> '
      call lineout tempfile
      iia=dosdir(tempfile,'s')

      is13=value('SREF_PREFIX',,'os2environment')
      if is13='' then do
        'RESPONSE HTTP/1.0 401 Unauthorized '     /* Set HTTP response line */
        'header add WWW-Authenticate: Basic Realm=<CheckLink>'  /* challenge */
        call doexit 'FILE ERASE TYPE text/html NAME' tempfile
     end
     else do
        foo=sref_response('unauth CheckLink','You do not have privileges to use CheckLink',servername,1)
        call doexit foo
     end
  end
end
if screens.!standalone=0 then do
  isauth=reqfield('Authorization')
  isref=reqfield('Refered')
end

/* read parameters from request */

if verb='GET' then parse var uri . '?' list
list=strip(list)

do until list=''
   parse var list a1 '&' list
   parse var a1 avar '=' aval ; tavar=translate(avar)
   aaval=packur2(translate(aval,' ','+'))
   select
     when tavar='URL' then aurl=packur2(translate(aval,' ','+'))
     when abbrev(tavar,'BASE_QU')=1 then do
        aaval=strip(aaval)
        if wordpos(aaval,'0_0 1_0 0_1 1_1')>0 then
           parse var aaval baseonly '_' queryonly
     end 
     when abbrev(tavar,'BASE')=1 then baseonly=is_yes_no(aaval,baseonly)
     when abbrev(tavar,'QUERY')=1 then queryonly=is_yes_no(aaval,queryonly)
     when abbrev(tavar,'USEMULTI')=1 then do
            ag=wordpos(aaval,'0 1 2') 
            if ag>0 then use_multi=ag-1
     end /* do */
     when abbrev(tavar,'SITE')=1 then siteonly=is_yes_no(aaval,siteonly)
     when abbrev(tavar,'EXCLUS')=1 then  exclusion_list=aaval
     when abbrev(tavar,'OUTTYPE')=1 then do 
          if aaval<>'' & aaval<>0 then outtype=translate(aaval)
     end
     when abbrev(tavar,'LINKFILE')=1 then linkfile=translate(aaval)
     when abbrev(tavar,'NAME')=1 then treename=aaval
     when abbrev(tavar,'RESULT')=1 then result_file=aaval
     when abbrev(tavar,'DESCRIP')=1 then make_descrip=wordpos(aaval,'1 2 3')
     otherwise nop
  end
end /* do */

if make_descrip=0 then make_descrip=1  /* unknown option means "no desciprs */

if result_File=0 then result_file=''

/* if result_file<>'', then just send it */
if result_file<>'' then do
   outfilel=linkfile_dir||result_file
   call doexit 'FILE type text/html nocache name ' outfilel
end

outfilel=''
if linkfile<>0 & linkfile<>'' then do
   outfilel=linkfile
   if screens.!standalone=1 then do
     if pos(':',linkfile)+pos('\',linkfile)=0 then 
           outfilel=linkfile_dir||linkfile
   end
   if pos('.',outfilel)=0 then outfilel=outfilel'.STM'
end 
if pos('?',outfilel)>0 then do
    outfilel=dostempname(outfilel)
    eek=filespec('n',outfilel); parse var eek linkfile '.' .
end

hold_doing=do_doing(linkfile_dir,use_multi)  /* instructions for multi_send */

if exclusion_list=0 then exclusion_list=''
aurl=strip(aurl)

if screens.!standalone=1 then use_multi=0       /* simplify my life */

/* check to see if the browser understands multi-part documents */
if use_multi=1 then do 
  a=translate(strip(reqfield('Connection')))
  a2=translate(strip(reqfield('PROXY-Connection')))
  if a<>'KEEP-ALIVE' & a<>'MAINTAIN' & a2<>'KEEP-ALIVE' & a2<>'MAINTAIN' then do
     use_multi=2                       /* multi-part not supported by browser */
  end
end  /* Do */
if use_multi=0 then back_1=back_2

taurl=translate(aurl)
if abbrev(taurl,'FILE:///')=1 then do
   server=0
   parse var taurl . '///' request .
end 
else do
  if abbrev(taurl,'HTTP://')+abbrev(taurl,'HTTPS://')=0 then do
     request=aurl
     server=servername
  end 
  else do
    parse var aurl . '//' server '/' request
    if server='' then server=servername
  end
  server=strip(server)
  if request='' then request='/'
end
if screens.!standalone=0 then fixexpire=value(enmadd||'FIX_EXPIRE',,'os2environment')

stype='1S'
if use_multi=1 then stype='SS'

/* send start of part1 */
user_intro1=''
if user_intro1a<>'' then do
  afil=stream(user_intro1a,'c','query exists')
  if afil='' then do
     user_intro1=''
  end
  else do
     foo=stream(afil,'c','open read')
     user_intro1=charin(afil,1,chars(afil))
     foo=stream(afil,'c','close')
  end
end

if user_intro1='' then do       /* the generic intro */
  foo='<html><head><title> Running: CheckLink of ' server ' </title> ' crlf 
/* add "refresh" meta-http? */  
  if use_multi=2 then do
     parse var hold_doing . clm 
     second_output=filespec('n',clm)
     clm='http://'servername'/cheklink?result='||filespec('n',clm)
     foo=foo' <META HTTP-EQUIV="Refresh" Content="9 ; URL='clm'">'
  end /* do */

  foo=foo'</head> <body ' back_1'>'
  user_intro1=foo||crlf'<h2 align="center"> CheckLink: creating a web-tree ... </h2>' crlf 
end

screens.!noscreen=1
rcode=multi_send(user_intro1,'text/html',stype,0,verbose,fixexpire,'CheckLink')
screens.!noscreen=0

noyes.0='NO' ; noyes.1='YES'
is_descrip.1='None created' ; is_descrip.2='text/html only' ;is_descrip.3='text/html &amp; text/plain '
/* intro1 is also used in part2 */
if screens.!standalone=0 then
  intro2=' <br><h3>Parameters</h3>'crlf'<ul>' 
else
  intro2=' <br><b>You chose the following parameters:</b><ul>' 

sayw=''
if screens.!standalone=0 then sayw='(* are wildcards)'
intro2=intro2||,
    ' <li>Descriptive Name= 'treename || crlf ,
    ' <li>  BASEONLY  = ' noyes.baseonly '&nbsp; &nbsp; (YES= only GET text/htmls in/under <em>base-url</em>)'crlf ,
    ' <li>  QUERYONLY = ' noyes.queryonly '&nbsp; &nbsp; (YES= query, but do not GET, links)' crlf ,
    ' <li>  SITEONLY  = ' noyes.siteonly ' &nbsp; &nbsp;(YES= do <em>not </em> query off-site links)'crlf ,
    ' <li>DESCRIPTIONS= ' is_descrip.make_descrip || crlf ,
    ' <LI>EXCLUSION_LIST = <b>' exclusion_list '</b> &nbsp; &nbsp; '||sayw||crlf 
if screens.!standalone=0 then
  intro2=intro2||,
         ' <LI>     USE_MULTI = ' use_multi '&nbsp; &nbsp; (0=1 part doc, 1=2 part doc, 2=two docs 'crlf 
intro2=intro2||,
    ' <li>    OUTTYPE = <b>' outtype '</b>&nbsp; &nbsp; (types of results to report) 'crlf 
if screens.!standalone<>0 then do
        intro2=intro2'<li> OutputFile = 'outfilex ||crlf
        intro2=intro2'<li> Verbosity  = '||word('Quiet Normal Verbose VeryVerbose',verbose)||crlf
        if linkfile<>'' & linkfile<>0 then do
           intro2=intro2'<li>   LinkFile = '||filespec('n',outfilel)||crlf
           if include_cheklnk2=1 then do
             intro2=intro2'<li>   Include links to CHEKLNK2 = '||noyes.include_cheklnk2||crlf
             intro2=intro2'<br>                 call as CGI-BIN= '||noyes.ascgi||crlf
          end
        end
end
else do
    if linkfile<>0 & linkfile<>'' then intro2=intro2'<li> LinkFile= '||filespec('n',linkfile) ||crlf
end
if second_output<>'' then intro2=intro2'<li> Temporary Output to= 'second_output||crlf

intro2=intro2||'</ul>' crlf 
 
if screens.!Proxy<>'' then do
  intro2=intro2||'<p><b>Proxy Server: </b> Request are sent through the proxy server at <tt>'screens.!Proxy'</tt><p>'||crlf  
end


if screens.!standalone=1 then do
      intro2=intro2||'--> <b>CheckLink starts at: ' aurl' </b><br>' crlf 
end
else do
       intro2=intro2'    <b>Starter URL=</b> ' aurl
       intro2=intro2'<br>            &nbsp;&nbsp;&nbsp;&nbsp;<tt>server</tt>=<u>' server '</u>, <tt>selector</tt>=<u>' request '</u><br>'
end

rcode=multi_send(intro2)

if screens.!standalone<>0 then do

   do forever
   if use_infile=0 | use_infile2=1 then
        ay=yesno('   |Are these parameters okay ','No Yes Re-enter Save_Current')
   else
        ay=yesno('   |Are these parameters okay ','No Yes Re-enter')

   if ay=0 then do
      say " bye ... "
      call doexit
   end 
   if ay=3 then do
       call save_params
       iterate
   end
   leave
   end
   use_infile=0
   if ay=2 then signal get_opts
   starter_url=aurl
   call start_screen

end 

stuff=get_url(query_method,server,request,isauth,0)            /* get HEAD info */
if server<>0 then do
  if screens.!proxy<>'' then do 
     tt='!'||server
     ips.tt=ipaddress
  end
end



screens.!Noscreen=2             /* multi_send writes to "notes" area */

/* no such resource or no such server? */
if stuff="" | errcode<>0 then  do   
    vop='<B>No such resource:</b><tt> 'aurl' </tt><em>error ='ecodes.errcode', 'stuff'</em></body></html>'
    if screens.!standalone<>0 then call write_note 'No such resource ('ecodes.errcode
    if use_multi=1 then 
        rcode=multi_send(vop,,'E')
    else
        rcode=multi_send(vop,,'1E')
    call outdone 
    if screens.!standalone=1 then call doexit

    call doexit '200 '||extract2('bytessent')
end /* do */

call extracts                   /* create headers. and body variables */
parse var response ht num amess

/* error code (or redirect) */
if num<200 | num>399 then do
  if screens.!standalone<>0 then call write_note 'Resource not available: 'num ' 'amess
  vop='<p><B>Resource not available</b>: 'num ' 'amess
  if use_multi=1 then 
        rcode=multi_send(vop,,'E')
  else
        rcode=multi_send(vop,,'1E')
  call outdone 
  if screens.!standalone=1 then call doexit

  call doexit '200 '||extract2('bytessent')
end 

/* extract basic info */
type='text/html'
asize=''

if wordpos('!CONTENT-TYPE',headers.0)>0 then do
    foo='!CONTENT-TYPE'
    parse var headers.foo type ';' . ; type=strip(type)
    asize=0
end
if wordpos('!CONTENT-LENGTH',headers.0)>0 then do
        foo='!CONTENT-LENGTH'
        asize=headers.foo
end
if wordpos('!LAST-MODIFIED',headers.0)>0 then do
    foo='!LAST-MODIFIED'
    parse var headers.foo lastmod ';' . ; lastmod=strip(lastmod)
end

parse var type type ';' .       /* get rid of possible modifiers */
if translate(type)<>'TEXT/HTML' then do
   if screens.!standalone<>0 then 
     call write_note 'Not an HTML document. Nothing to check! '
   vop='<h3>Not an HTML document </h3> <em>Nothing to check! </em> </body></html>'
   if use_multi=1 then 
        rcode=multi_send(vop,,'E')
   else
        rcode=multi_send(vop,,'1E')
  call outdone 
  if screens.!standalone=1 then call doexit

  call doexit '200 '||extract2('bytessent')
end 


/* text/html: get the body and find links */
 stuff=get_url('GET',server,request,isauth,0)  /* get head and body */

if screens.!standalone<>0 then do
   say
   call write_note bold||request||normal" has been retrieved."
end


 call extracts                  /* get body (skip headers)  */
 call set_base_root
 screens.!noscreen=2
 rc=multi_send(intro3)

 if screens.!standalone<>0 then 
     call write_note 'For 'request', mime='type',size='||length(body)
 screens.!noscreen=1
 rc=multi_send('<p> &nbsp;&nbsp;&nbsp;&nbsp;For ' request': Mime type= ' type ', size='||length(body))

if use_multi=2 then do
   aa='<blockquote><b>Output note:</b> The <em>tables of results </em> will be written ' crlf ,
      ' to an output file. On most browsers, this file will be automatically retrieved ' crlf,
      ' about 10 seconds after CheckLink finishes processing. Alternatively, you can ' crlf ,
      ' manually click on a link to this output file.  This link <font color="RED">will</font> be ' ,
      ' placed at the <a href="#BOTTOM">bottom of this page</a> ' crlf ,
      ' (but wait until processing is complete and  all the status info has been written!) ' crlf ,
      ' </blockquote> ' crlf
      rcode=multi_send(aa)
end 


 if asize='' then asize=length(body)
 hrefs.0=1
 if server=0 then
    hrefs.1='file:///'||request
 else
    hrefs.1='http://'server'/'||strip(request,'l','/')
 hrefs.1.!type='text/html' ; hrefs.1.!size=asize ; hrefs.1.!refered='!starter-URL!'
 hrefs.1.!status=0 ; hrefs.1.!nrefs=0 ; hrefs.1.!queried=0
 hrefs.1.!nlinks=0
 hrefs.1.!reflist=''  ; hrefs.1.!appearin='' ; hrefs.1.!Imglist=''
 hrefs.1.!err=0
 hrefs.1.!title=' '

 hrefs.1.!lastmod=' '
 if wordpos('!LAST-MODIFIED',headers.0)>0 then do
      foo='!LAST-MODIFIED'
      parse var headers.foo lastmod ';' . ; lastmod=strip(lastmod)
      hrefs.1.!lastmod=lastmod
 end

 arf=strip(translate(hrefs.1))
 if length(arf)>40  then arf=left(arf,10)||stringcrc(arf)
 hrefs.!list.arf=1

/* check for robots.txt, and augment exclusion list */
if check_robot=1 & server<>0 then do
   stuff=get_url('GET',server,'ROBOTS.TXT',isauth,0) 
   if stuff<>'' then do
      call extracts 
      parse var response . hcode .
      if datatype(hcode)<>'NUM' then hcode=400
      if hcode>199 & hcode<300 then do             
         exclusion_list2=add_robot(exclusion_list,body)
         aa='<p><b>ROBOTS.TXT found.<br></b> Modified exclusion_list= <tt>' exclusion_list2 '</tt>'

         rc=multi_send(aa)
         if screens.!standalone<>0 then do
           call write_note 'ROBOTS.TXT found. New exclusion list='
           call write_note '  'exclusion_list2
         end
      end /* do */
   end
end /* do */

if screens.!standalone<>0 then do  /* suppress output of  status info (standalone mode) */
   if screens.!verbose<>0 then
       call lineout outfilex,' <br> <a href="#SUMMARY">Skip to Results </a> '
end

/* now recurse down list of links (in hrefs list ================ */
/* start with the "starter-url" */
screens.!noscreen=0

mustpre=rooturl
if baseonly=1 then mustpre=base
mustpre=strip(translate(mustpre))
screens.!Noscreen=1
if screens.!verbose<>0 then 
    rc=multi_send('<HR><H2>Traversing links  -- displaying status information ...</h2> <ul>')
if screens.!standalone=1 then
 call write_note_header 'Traversing links  -- displaying status information ...'

if rc<0  then call doexit '.'

/* Prepare for thread launchs -- open a queue */

myqueue2=rxqueue('c')
foy=rxqueue('s',myqueue2)

screens.!mysem='\SEM32\CHECKLINK_'||dospid()||'_'||dostid()||'_1'
mysem=eventsem_create(screens.!mysem,'P')
screens.!madesem=1

liminact=extract2('limittimeinactive')

/****** ====== Here is where the web-tree processing finally starts ======= */
/*             We start with a pointer to the starter-url, and then process
               a list of urls that are recursively built (from the contents of
               earlier entries in the list)
*/

isdone=0
do forever              /* end when no more urls to check. or on client closing connection */

   call get_Url_q        /* possibly launch a few GET daemons, and get top of queue */
   if result=-1 then call doexit '.'              /* client killed connection */
   if result=-2 then leave                   /* nothing more to do */

   if result=0 then do          /* nothing on queue, so wait */
      call syssleep 1
      screens.!keylist=get_key(screens.!Keylist)    
      if wordpos('1',screens.!keylist)>0 then call abort_job 'wait for contents'  /* will exit */
      if wordpos('2',screens.!keylist)>0 then call kill_transactions  /* timeout current transactions */
      if wordpos('3',screens.!keylist)>0 then do                /* user forced end */
           screens.!user_end=isdone+1
           screens.!nogetkey=1
           call kill_transactions 1 /* timeout current transactions */
           call write_note_header 'User forced End'
           call write_note 'No more link checking (user forced end)'
           call syssleep(2)
           leave
      end 
      iterate         /* nothing to do, loop */
   end

/* if here, stuff and anind have been set as globals */
   if stuff="" then do
     if screens.!user_end>0 then do      /* legit no body */
       if verbose>1 then do
           if screens.!standalone<>0 then call write_note 'No body! ' hrefs.anind
           screens.!noscreen=1
           rc=multi_send(crlf'<br> No body! ' hrefs.anind)
           if rc<0 then call doexit '.'
        end
     end
     iterate
  end
  
  call extracts                   /* get body variable  */
  isdone=isdone+1
  if screens.!standalone<>0  then do
     call write_get_contents '[' isdone " html documents read]"
  end 
  screens.!noscreen=1
  if screens.!verbose<>0 then
     rc=multi_send('<br><tt>'anind')</tt> Length ('hrefs.anind')=== '||length(body))
  if screens.!standalone=1 then do
        call write_finding_Header anind':' hrefs.anind||', bytes= '||length(body)
        call write_get 'X'||anind       /* zap anind display line */
  end
  if rc<0 then call doexit '.'
  nowimg=imgs.0 ; nowhref=hrefs.0
  if abbrev(translate(hrefs.anind),'FILE:///')=1 then do
     parse var hrefs.anind . '///' request
     base='FILE:///'||filespec('d',request)||filespec('p',request)
  end
  else do
     parse var hrefs.anind . '//' .'/' request 
     ijoe=lastpos('/',hrefs.anind)
     if anind>1 then
        base=delstr(hrefs.anind,ijoe+1)
     else
        base=baseurl
  end
  if screens.!standalone=1 then do
     call write_note_header 'Parsing 'hrefs.anind
     call syssleep 0.4
  end

  oo=findurls(body,base,rooturl,request,anind)   /* find links in this document */

  hrefs.anind.!nlinks=oo
  hrefs.anind.!queried=1
  if nowimg=imgs.0 & nowhref=hrefs.0 then iterate /* no new links */
  if screens.!standalone=1 then
       call write_note_header 'Query links in 'anind': 'hrefs.anind

  oo=query_types(rooturl,nowimg+1,nowhref+1,hrefs.anind,anind)         /* determine types of these links*/

  if queryonly=1 then leave                             /* finish after querying starter-url */

  if screens.!user_end=1 then do                /* userend signal occured? */
           screens.!user_end=isdone+1
           screens.!nogetkey=1
           call write_note_header 'User forced End'
           call write_note 'No more link checking (user forced end)'
           call syssleep(2)
           leave
  end

end 

screens.!noscreen=1
if screens.!verbose<>0 then
   rc=multi_send('</ul>')

if screens.!user_end=0 then do           /* check for user forced end */

  if screens.!standalone=1 then
     call write_note_header 'Double checking n.a. URLs'
  oy= double_check_it(double_check)        /* double check? */

/* get text/plain descriptions */
  if queryonly=0 & make_descrip=3 then call make_text_descrip
end

/* !!!!!  At this point, we start a new document (if use_multi=1 ) 
          If use_multi=2, save results to temporary file    */

screens.!noscreen=1
doing_results=hold_doing                /* created at top of program */
if use_multi=1 then do
   rc=multi_send('</body></html>',,'SE') /* close first part */
end
if use_Multi>0 then do
   user_intro1=''
/* send start of part2 */
   if user_intro1b<>'' then do
      afil=stream(user_intro1b,'c','query exists')
      if afil='' then do
         user_intro1=''
      end
      else do
         foo=stream(afil,'c','open read')
         user_intro1=charin(afil,1,chars(afil))
         foo=stream(afil,'c','close')
      end
    end
    if user_intro1='' then do
       foo='<html><head><title> Results: CheckLink of ' server ' </title></head><body 'back_2'>'
       if linfile<>0 & linkfile<>'' then foo=foo||'<A name="TOP">'jump_bar(linkfile,cheklink_htm)'</a>'
       user_intro1=foo||'<h1 align="center"> CheckLink results </h1>' crlf 
    end
    if use_multi=1 then
       rcode=multi_send(user_intro1,'text/html','ES')
    else
       rcode=multi_send(user_intro1)

/* repeat basic info */
   rc=multi_send(intro2)
   if rc<0 then do 
      call outdone
      if screens.!standalone=1 then call doexit
      call doexit '.'
   end /* do */

   rc=multi_send(intro3)

end             /* if not multi part, don't do any of the above */

/* ready to write tables of results */

screens.!noscreen=1

if screens.!standalone=1 then do
    call write_note_header "Processing complete. "normal"Now writing output file. "
end 

fop='<hr> '
if use_multi=0 then 
  fop=fop||'<center><h2>Anchors and Imgs</h2> </center>' crlf
rc=multi_send(fop)
if rc<0 then do 
    call outdone
    if screens.!standalone=1 then call doexit
    call doexit '.'
end /* do */


call write_summary
if result<0 then do
   call outdone
   if screens.!standalone=1 then call doexit
   call doexit '.'
end

/* do several sets of tables */
do ut=1 to words(outtype)
      aut=strip(word(outtype,ut))
      typedo=wordpos(aut,'OK NOSITE NOURL OFFSITE x EXCLUDED ALL')
      if typedo=0 then  do
         typedo=wordpos(aut,'0 1 2 3 4 5 6')
         if typedo=0 then iterate
      end
      tcode=strip(word('!OK 1 2 3 4 5 !ALL',typedo))
      foo=write_img_href(1,1,tcode)
      if foo<0 then do 
           call outdone       end /* do */
           if screens.!standalone=1 then call doexit
           call doexit '.'
      end
end /* do */

vop='<p><a href="#TOP">Top of document</a> 'crlf|| ,
     '&nbsp; &nbsp;<a href="javascript:showNotes()">Display descriptive info (in popup window)</a>'

oo=time('e')
vop=vop'<hr>Elapsed time= '||addcomma(oo,1) ' seconds.' crlf ,
    ' Total bytes downloaded='ADDCOMMA(totgot)||crlf

/* rcode=multi_send(vop,,'EE') */

if use_multi=2 then do
   parse var doing_results . dd1
   og=filespec('n',dd1)
   doing_results=1       /* 'VAR, but not lineout */
   vop=vop' <hr> <a name="BOTTOM"> View the </a> <a href="/CHEKLINK?result='og'"> results tables? </a>'crlf
end /* do */

if use_multi=1 then 
    rcode=multi_send(vop,,'EE')
else
    rcode=multi_send(vop,,'1E')


/* write column descriptions to small window.*/


vop='<script language="javascript">'
vop=vop||crlf||'function showNotes() {'
vop=vop||crlf||'daNOTES=window.open("","NOTES", "location=NO,MENUBAR=NO,RESIZABLE,DEPENDENT,SCROLLBARS=YES,STATUS=YES,TITLEBAR,TOOLBAR=NO,SCREENX=12,SCREENY=30,height=340,width=420");'
vop=vop||crlf||'daNOTES.document.writeln(''<html><head><title>CheckLink Description</title><head><body>'');'
vop=vop||crlf||'daNOTES.document.writeln(''<hr><a name="DESCRIBE"><h3>CheckLink Results</h3></a>'');'

vop=vop||crlf||'daNOTES.document.writeln(''<hr><a name="DESCRIBE"><h4>Description of Columns</h4></a>'');'
vop=vop||crlf||'daNOTES.document.writeln(''<dl>'');'
vop=vop||crlf||'daNOTES.document.writeln(''Note that each row of the tables describes a &quot; resource on the web-tree",   where "resources" can be documents, '');'
vop=vop||crlf||'daNOTES.document.writeln(''images, scripts, etc. <p>'');'
vop=vop||crlf||'daNOTES.document.writeln(''<dt><u>?</u> <dd> Examine links <b>to</b> and <u>from</u> this resource '');'
vop=vop||crlf||'daNOTES.document.writeln(''<dt> Image Location, or URL <dd> A link to the resource, as encounted while building   the web-tree. '');'
vop=vop||crlf||'daNOTES.document.writeln(''If the resource is inaccessible, it will   just be underlined; but the immediately preceding number '');'
vop=vop||crlf||'daNOTES.document.writeln(''will be linked   to the resource (so as you can double check) '');'
vop=vop||crlf||'daNOTES.document.writeln(''<dt><b>#</b><dd><em>for text/html documents...</em> Number of links contained in this html document  '');'
vop=vop||crlf||'daNOTES.document.writeln(''<dt>Mimetype <dd> The mime type of the resource (or, an error code if the URL could not be read) '');'
vop=vop||crlf||'daNOTES.document.writeln(''<dt>Size or error code <dd>The size (in bytes) of the resource (as reported  '');'
vop=vop||crlf||'daNOTES.document.writeln(''  by it`s server); or an error code indicating why the resource could not be accessed.  '');'
vop=vop||crlf||'daNOTES.document.writeln('' <br> Error codes include: <menu>  '');'
vop=vop||crlf||'daNOTES.document.writeln('' <li><tt>Server n.a.</tt> :  Server was inaccessible. Since this might be a   temporary condition '');'
vop=vop||crlf||'daNOTES.document.writeln(''(say, if the server was exceptionally busy), you probably should  '');'
vop=vop||crlf||'daNOTES.document.writeln(''  double-check these links (i.e.; click on the number immediately preceding the URL)   '');'
vop=vop||crlf||'daNOTES.document.writeln(''  <li><tt>Missing resource </tt> The server reports that this link is unavailable  '');'
vop=vop||crlf||'daNOTES.document.writeln(''  <br>Error codes (in the mimetype column) include:<menu> '');'
vop=vop||crlf||'daNOTES.document.writeln(''  <li> 400 = Bad Request  <li>401 = Unauthorized  <li>403 = Forbidden   '');'
vop=vop||crlf||'daNOTES.document.writeln(''  <li> 404 = Not Found    <li>406 = Not Acceptable  </menu> '');'
vop=vop||crlf||'daNOTES.document.writeln('' <li><tt>Off-site :</tt> This URL is off-site, and off-site URLs were not checked  '');'
vop=vop||crlf||'daNOTES.document.writeln('' <li><tt>Excluded </tt>: This is a CGI-BIN, or some other, "excluded" URL that are not checked  '');'
vop=vop||crlf||'daNOTES.document.writeln('' <li><tt>Not read :</tt> User ended program before this URL could be queried  '');'
vop=vop||crlf||'daNOTES.document.writeln('' </menu>  '');'
vop=vop||crlf||'daNOTES.document.writeln(''<dt>Number of references <dd>Number of times that links (URLs) pointing to <b>this resource</b> </u> appeared   '');'
vop=vop||crlf||'daNOTES.document.writeln('' in other html documents (on this web-tree)  '');'
vop=vop||crlf||'daNOTES.document.writeln(''<dt>First reference <dd>Link to an HTML document that contains a URL pointing to this resource '');'
vop=vop||crlf||'daNOTES.document.writeln(''  (the first one encountered when building the web-tree)'');'
vop=vop||crlf||'daNOTES.document.writeln('' </dl> '');'
vop=vop||crlf||'daNOTES.document.writeln('' </body></html> '');'

vop=vop||crlf||'}</script>'

vop=vop||crlf'</body></html>'

if use_multi=1 then 
        rcode=multi_send(vop,,'EE')
else
        rcode=multi_send(vop,,'1E')

call outdone 1

if screens.!standalone=1 then do
   if vu_prog<>0 & vu_prog<>' ' then do
      call write_note_header "Viewing results in "outfilex
      foo=vu_prog' file:///'||stream(outfilex,'c','query exists')
        '@start /f 'foo
       call write_note " >>> viewing "outfilex " with " vu_prog
       call write_note "       (it might take a few seconds)"
       say 
    end
    call write_note_header "Done."
    call write_bottom 'Done.'
    call doexit
end
   

call doexit '200 '||extract2('bytessent')


doexit:
parse arg amess
if screens.!madesem>0  then do
  foo=rxqueue('d',myqueue2)
  foo=eventsem_close(mysem)
end
if amess<>'' then do
   if strip(amess)='.' then amess=' '
   return amess
end 
exit

/********** END OF MAIN ***************/
/********** END OF MAIN ***************/
/********** END OF MAIN ***************/
/********** END OF MAIN ***************/
/********** END OF MAIN ***************/



/****/
outdone:
parse arg isdone
   if use_multi=2 then do
       parse var doing_results d1 d2 ; d2=strip(d2)
       call lineout d2
       if isdone<>1 then foo=sysfiledelete(d2)  /* premature error */
   end /* do */
   aout=screens.!outfilex
   if screens.!standalone=1 then do
      call lineout aout
      say 
      call write_note ' '
      call write_Note      bold" Results written to "||normal||stream(aout,'c','query exists')
    end

   aoutl=screens.!outfilel
   if aoutl<>'' & isdone=1 then do
        aa=stream(aoutl,'c','close')
        hh=cvtails(imgs,kins)          /* drop some superfulous stuff */
        if hh>0 then do
           do nz=1 to kins.0
               pup=translate(kins.nz)
               if abbrev(pup,'!LIST.')=1 | right(pup,7)='.!BIRTH' |  ,
                         right(pup,8)='.!STATUS' | right(pup,6)='.!DMNTID'  | ,
                         right(pup,9)='.!REFERED'    then 
                  drop imgs.pup
           end /* do */
        end /* do */
        a1=cvcopy(imgs,bbg.!imgs)

        hh=cvtails(hrefs,kins)          /* drop some superfulous stuff */
        if hh>0 then do
           do nz=1 to kins.0
               pup=translate(kins.nz)
               if abbrev(pup,'!LIST.')=1 | right(pup,7)='.!BIRTH' | ,
                       right(pup,8)='.!STATUS' | right(pup,6)='.!DMNTID' | ,
                       right(pup,9)='.!REFERED' then
                    drop hrefs.pup
           end /* do */
        end /* do */

/* add name */
        if name='' then do
            parse var hrefs.1 . '//' sname '/' rname
            treename='Starting at /'rname ' on ' sname 
        end /* do */
        hrefs.!name=treename
        
        a2=cvcopy(hrefs,bbg.!hrefs)
        if pos('.',aoutl)=0 then aoutl=outfilel'.stm'
        bbg.!version=lib_ver
        bbg.!treename=hrefs.!Name
        bbg.!creation=time('n')||' '||date('n')
        bbg.!baseurl=baseurl
        bbg.!rooturl=rooturl
        a3=cvwrite(aoutl,BBG)
        IF screens.!STANDALONE<>0 then DO
          if (a1*a2*a3)=0 then  do
            call write_Note bold||" Warning:"normal||" could not save Link file =" aoutl
          end
          else do
             call write_note bold||" Link file= " normal||aoutl
          end
        END
   end /* do */

   return 1


/*********************/
/* set up the doing_results variable -- perhaps with a temp file name
if use-multi=2 */
do_doing:procedure
parse arg ldir,bb

if bb<2 then return 1
lfile=dostempname(ldir||'LNKCH???.HTM')
return '2 'lfile



/****************/
/* make a jumpbar */
jump_bar:procedure expose crlf
parse arg aff,af2
foo='<a href="#SUMMARY">Summary</a> &nbsp; || &nbsp; ' crlf ,
    '<a href="#DESCRIBE">Description</a> &nbsp || &nbsp ' crlf  ,
    '<a href="/CHEKLNK2?linkfile='aff'&entrynum=1">Synopsis of starter-URL</a> || ' crlf ,
    '<a href="/CHEKLNK2?linkfile='aff'&entrynum=0">View all HTMLs in this web-tree </a> || ' crlf 
if af2<>'' then
    foo=foo'<a href="'af2'">Create another web-tree </a> &nbsp || ' 

return foo

/*******************/
/* write summayr info */
write_summary:
 
 ioki=0
 do jj=1 to imgs.0
    if imgs.jj.!size>=0 then ioki=ioki+1
 end /* do */

 iok.0=0;iok.1=0;iok.2=0;iok.3=0;iok.4=0;iok.5=0;iok.!html=0
 do mm=1 to hrefs.0
    select 
        when hrefs.mm.!size>=0 then do 
          iok.0=iok.0+1
          if translate(strip(hrefs.mm.!type))='TEXT/HTML' then iok.!html=iok.!html+1
        end /* do */
        otherwise do
          if datatype(hrefs.mm.!size)='NUM' then do
             ool=abs(hrefs.mm.!size)
             iok.ool=iok.ool+1
          end
        end             /* otherwise */
     end                /* select  */
  end                   /* hrefs. */


/* NOW display this summary */

codes.1='<u>Server not available</u> '
codes.2='<b>No such resource on server</b>'
codes.3='Off-site (did not check) '
codes.4=''
codes.5='Excluded selectors (did not check) '


anames.!OK='OKS'
anames.1='NOSITE'
anames.2='NOURL'
anames.3='OFFSITE'
anames.4=''
anames.5='EXCLUDED'
anames.!ALL='ALL'

vl1='OK NOSITE NOURL OFFSITE x EXCLUDED ALL'

fop=''
if screens.!user_end<>0 then do
   fop=intro2||'<blockquote><b>User forced end. </b> Link checking &amp; querying was discontinued after processing approximately 'screens.!user_end||' resources </blockquote>'crlf
end 


fop=fop||'<center><a name="SUMMARY"><h3>Summary of Results </h3></a></center>' crlf ,
    ' Starter-URL: <b> ' aurl '</b> <p>' crlf ,
     '<blockquote><tt><b>Title</b>:' hrefs.1.!title '</tt>'  crlf
     if symbol('HREFS.1.!DESCRIP')='VAR' then
        fop=fop'<br><b>Description</b>:' hrefs.1.!descrip '</tt>'  crlf
     fop=fop||'</blockquote><B>Images</b>: 'ioki', of ' imgs.0 ', images were readable.'  crlf 

if pos('ALL',outtype)+pos('6',outtype)>0 then
      fop2='<a href="#ALL">Anchors</a>:'
 else
      fop2='<B>Anchors</b>:'

fop=fop||' <p>'fop2' of ' hrefs.0' anchors:' crlf 

if pos('OK',outtype)+pos('0',outtype)>0 then
      fop2='<a href="#OKS">obtainable</a>'
 else
      fop2='obtainable'

fop=fop||'<ul> <li> 'iok.0 ' were 'fop2' ( text/html='iok.!html')' crlf

do mmk=1 to 5
      if mmk=4  then iterate
      aa2=word('OK NOSITE NOURL OFFSITE x EXCLUDED ALL',mmk+1)
      if wordpos(aa2,outtype)+wordpos(mmk,outtype)>0 then
           ttc='<a href="#'||anames.mmk'">'codes.mmk'</a>'
      else      
           ttc=codes.mmk
      fop=fop||'<li>' ttc ': ' iok.mmk
end
fop=fop'</ul>'
rc=multi_send(fop)
if rc<0 then return -1
return 1


/************/
/* ADD COMMAS TO A NUMBER */
addcomma:procedure
parse arg aval,ndec
parse var aval p1 '.' p2

if ndec='' then do
   p2=''
end
else do
   p2='.'||left(p2,ndec,'0')
end /* do */

plen=length(p1)
p1new=''
do i=1 to 10000 while plen>3
   p1new=','right(p1,3)||p1new
   p1=delstr(p1,plen-2)
   plen=plen-3
end /* do */

return p1||p1new||p2


/******************************/
/* parse a robots.txt file, and add appropriate disallows to the exclusion_list.
The algorithim:
1 ignore # lines (comments)
2a look for user-agent: checklink lines
2b if none, look for user-agent:*  lines
3 if 2a or 2b don't work, exit with no changes
4 otherwise, from the look for disallow lines going starting from 
  the user-agent line, until the first empty line (use 0a as line delimiter,
  and throw away the 0d)
5 take asel from each disallow: asel, add a * to the end, and append to
  exclusion_list

---------------
# samples robots.txt -- will add cgi-* to exclusion_list

user-agent: mozilla
Disallow: /samples
Disallow: /stuff/

#user-agent: checklink
user-agent:gizmo
disallow:fes/

user-agent:*
disallow:cgi-

---------------

*/
add_robot:procedure expose screens. verbose 
parse arg exlist,abody

cr='0a'x
nn=0
do forever
  if abody='' then leave
  parse var abody al1 (cr) abody
  al1=strip(al1,,'0d'x)
  if al1='#' then iterate
  parse var al1 al1a '#' .
  nn=nn+1
  lins.nn=al1a
end
if nn=0 then return exlist /* empty, so ignore */

lins.0=nn

/* look for CHECKLINK or *  user-agent */
iat=0
do mm=1 to lins.0
   al=strip(lins.mm)
   if abbrev(translate(al),'USER-AGENT')=0 then iterate
   parse var al . ':' dagent ; dagent=translate(strip(dagent))
   if abbrev(dagent,'CHECKLINK')=1 then do
       iat=mm
       leave
   end
   if dagent='*' then do
       iat=mm
   end /* do */
end /* do */

exlist2=''
if iat=0 then return exlist /* no matching user-agent */
do mm=iat+1 to lins.0
  al=translate(strip(lins.mm))
  if al='' then leave   /* blank line signals end of "record" */
  if abbrev(al,'DISALLOW')<>1 then iterate
  parse var al  . ':' dasel ; dasel=strip(dasel)
  if dasel<>'' then exlist2=exlist2||' '||dasel||'* '
end /* do */

do ik=1 to words(exlist2)
   aw=strip(word(exlist2,ik))
   aw=strip(aw,'l','/')
   exlist=exlist' 'aw
end /* do */

return exlist


/**************************************/
/* Do several gets from the hrefs list (of urls not-yet-retrieved)
  These gets are done by daemons, with results returned in a queue.
  After launching enough daemons (so as to achieve maxatonce active
  daemons), go check the queue for any results from previously
  launched daemons)
*/

get_url_q:

screens.!noscreen=1

if screens.!standalone=1 then
 call write_note_header 'GET (via daemons) next several HTMLs '

lastgoo=basesec
stuff=''
lastgoo=time('e')
ii1=hrefs.!start
dones=0 ; nowactive0=0

/* first, launch a few daemons? keep maxatonce_get threads busy */
do oj=1 to hrefs.0             /* sort of inefficient (should start at > 1, but so what */
     nowsec=time('e')
     if hrefs.oj.!status=2 then  dones=dones+1
     if hrefs.oj.!status=1 then  nowactive0=nowactive0+1
        
     if hrefs.oj.!status>0 then iterate /* either done, or being done */

     if nowactive0>maxatonce_get then iterate  /* doing enough already */

     iss=is_this1(oj)           /* shouldn't do ? */
     if iss<0 then return -1      /* client killed the connection */
     if iss=0 then do
        hrefs.oj.!status=2      /* can't be done */
        iterate 
     end 

/* launch a daemon to GET this url */
     tmp=get_url_0('GET',hrefs.oj,isauth,oj,myqueue2,screens.!Mysem)
     parse var tmp hrefs.!dmntid','.

     IF VERBOSE>2 THEN call pmprintf2(' CheckLink:GET 'hrefs.oj ' on thread.. ' hrefs.!dmntid)
     if screens.!standalone=1 then do
        call write_get oj') ' hrefs.oj
     end
     else do
       if screens.!verbose<>0 then do
            rc=multi_send('<li><b>  'oj')  checking:</b> ' hrefs.oj)
            if rc<0 then return -1                     /* <0 means client disconnected */
       end
     end

     hrefs.oj.!status=1                 /* mark as active */
     hrefs.oj.!birth=nowsec
     nowactive0=nowactive0+1              

end                  /* or leave when at end of hrefs. */

if dones=hrefs.0 then return -2         /* nothing more to do */

/* check "return queue" for results */
a=rxqueue('s',myqueue2)
nq=queued()     


if nq=0 then return 0  /* no results are ready */

/* something in queue */

if (nowsec-lastgoo)> min(15,(0.75*liminact)) then do   /* intermediate status report? */
    if screens.!standalone=1 then do
        call write_note '..('dones' URLS read of 'hrefs.0')'
    end
    else do
     if screens.!verbose<>0 then do
          rc=multi_send('<br>&nbsp;&nbsp;&nbsp;..('dones' of 'hrefs.0')')
          if rc<0 then return -1               /* client killed connection */
     end
    end
    lastgoo=nowsec
end 
     
parse pull yow
totgot=totgot+length(yow)

anid=left(yow,25)
parse var anid atrans','anind ; atrans=strip(atrans); anind=strip(anind)

/* check for nonsense */
if anind>hrefs.0 then return 0 /* ignore  -- impossible hrefs index */
if transaction<>atrans & atrans<>'FILE' then return 0 /* ignore -- bad transaction */

/* if here, legit item found in the queue */
hrefs.anind.!status=2              /* mark that this is done */

errcode=substr(yow,26,1)
ipaddress=substr(yow,27,20)
stuff=substr(yow,47)


if screens.!proxy='' then do
  tt='!'||server
  if ips.tt=' ' then ips.tt=ipaddress
end


return 1


/**************************************/
/* make descriptions for text files */
make_text_descrip:procedure  expose myqueue hrefs. stuff imgs. isauth siteonly  verbose ,
       query_method mustpre dscmax servername transaction ips. ,
       exclusion_list2 exclusion_list maxatonce maxage  totgot thread_string badsites. doing_results ,
       screens.


liminact=extract2('limittimeinactive')
tocheck.0=0
/* find all local text/plain hrefs to lookup; copy to the tocheck array */
drop tocheck.
tocheck.0=0
do mm=1 to hrefs.0
   att=space(translate(hrefs.mm.!type),0)
   if att<>'TEXT/PLAIN' then iterate
   if abbrev(translate(hrefs.mm),mustpre)<>1 then iterate  /* offsite or offdir */

/* check this href */
   uu=tocheck.0+1
   tocheck.uu=hrefs.mm
   tocheck.uu.!indx=mm
   tocheck.uu.!status=0  /* 0=not done,1=being done, 2=done */
   tocheck.0=uu
end
if tocheck.0=0 then return 1  

if verbose>2 then call pmprintf2('Checklink. ' tocheck.0 ' text/plain descriptions  ')
if screens.!verbose<>0 then do
  rc=multi_send('<br>Checklink. ' tocheck.0 ' text/plain descriptions  ')
  if rc<0 then return 0
end

/* check all of the "tochecks"  -- do atonce "threads" at a time */
basesec=time('e') ; lastgoo=basesec

/* Prepare for thread launchs... clean up quque */
foy=rxqueue('s',myqueue)
ii=queued()
do ii0=1 to ii ;   pull gg ; end 

do forever            /* until all tochecks are complete or timedout */

   nowsec=time('e')
   alldone=0
   nowactive=0

   do oj=1 to tocheck.0     /* keep maxatonce threads busy */
   
      astat=tocheck.oj.!status
      if astat=2 then alldone=alldone+1
      if astat=1 then nowactive=nowactive+1

      if astat<>0 then iterate    /* active or done, ignore */
      if nowactive>=maxatonce then iterate


      tmp=get_url_0('DSCGET',tocheck.oj,isauth,oj,myqueue,screens.!mysem)
      parse var tmp tocheck.oj.!dmntid','tocheck.oj.!trans','.

      IF VERBOSE>2 THEN 
        call pmprintf2(' CheckLink: text/plain description 'tocheck.oj ' on thread... ' tocheck.oj.!dmntid)

      tocheck.oj.!status=1
      tocheck.oj.!birth=nowsec
      nowactive=nowactive+1

   end                  /* or leave when at end of tocheck */
 
   if alldone=tocheck.0 then leave   /* all done with tocheck hrefs */

   if (nowsec-lastgoo)> min(15,(0.75*liminact)) then do   /* intermediate status report? */
      if screens.!verbose<>0 then do
         rc=multi_send('<br>&nbsp;&nbsp;&nbsp;...('alldone' of 'tocheck.0')')
         if rc<0 then return 0  /* client killed connection */
       end
       lastgoo=nowsec
   end /* do */


/* any new results? */
   nq=queued()          
   if nq=0 then do      /* nothing to do -- so check for old age */
      call syssleep 1           /* sleep for a second */
      screens.!keylist=get_key(screens.!Keylist)    
      if wordpos('1',screens.!keylist)>0 then call abort_job 'description' /* will exit */
      if wordpos('2',screens.!keylist)>0 then call kill_transactions   /* timeout current transactions */
      if wordpos('3',screens.!keylist)>0 then do               /* user forced end */
           call kill_transactions 1 /* timeout current transactions */
           leave
      end

      iterate                   /* and back to top of forever loop */
   end /* do  nq=0*/

/* if here, something in queue */
   parse pull yow
   totgot=totgot+length(yow)

   anid=left(yow,25)
   parse var anid atrans','anind ; atrans=strip(atrans); anind=strip(anind)
   if anind>tocheck.0 then iterate /* ignore  -- impossible tocheck index */
   if tocheck.anind.!trans<>atrans then iterate /* ignore -- bad transaction */

   tocheck.anind.!status=2              /* mark that this is done */

   errcode=substr(yow,26,1)
   ipaddress=substr(yow,27,20)
   stuff=substr(yow,47)
   if screens.!proxy='' then do
      tt='!'||server
      if ips.tt=' ' then ips.tt=ipaddress
   end
   mm=tocheck.anind.!indx

/* process stuff */
  if stuff="" then iterate

/* extract type and length */
   call extracts                   /* create headers. and body */
   parse var response ht num amess

  if num<200 | num>399 then iterate

  hrefs.mm.!descrip=translate(left(body,min(dscmax,length(body))),' ','0d0a0009'x)

end             /* OF TOCHECKS */
return 1



/*****************************/
/* a text/html that we should GET? */
is_this1:procedure expose hrefs. mustpre  verbose doing_results servername ips.  screens.
parse arg jj
if jj=1  then return 1  /* ALWAYS check starter-url */

if hrefs.jj.!size<0 then return 0       /* not on site */
if translate(hrefs.jj.!type)<>'TEXT/HTML' then do
       if screens.!verbose<>0 then do
         rc=multi_send('<li> <em>'jj') </em> Not text/html: ' hrefs.jj '=' hrefs.jj.!type)
         if rc<0 then return -1
       end
       return 0
end 
/* compare against root or base url */
if abbrev(translate(hrefs.jj),mustpre)=0 then do
       if screens.!verbose<>0 then do
          rc=multi_send('<li> <em> ' JJ ') </em> Not checking contents: ' hrefs.jj)
          if rc<0 then return -1
       end
       return 0
end 
return 1


/*******************/
/* head to find out types */
query_types:procedure expose myqueue hrefs. stuff imgs. isauth siteonly  verbose  query_method ,
            exclusion_list2 exclusion_list maxatonce maxage  totgot thread_string badsites. doing_results ,
            servername transaction ips. screens.

parse upper arg daroot,img1,href1,paurl,anind
tmpanind=anind
liminact=extract2('limittimeinactive')

if href1<=hrefs.0 then call query_types_a
if screens.!user_end=1 then return 1

anind=tmpanind
if img1<=imgs.0 then call query_types_i

return  1


/**************************************/
/* query types of anchors */

/* k.!appearin : ids of urls that url "contain"  K  (that K "appears in")
   k.!nrefs    : # of urls that contain  K          (= # words in k.!appearin)
   k.!reflist  : ids of urls that k contains  (!imglist is for images)
   k.!nlinks    : # of urls that K contains (= # words in k.!reflist
   k.!refered  : url of the first URL that contains K (this URL has the first id in k.!appearin)
   k.!queried  : -1=not queried,  0=queried,not parsed for links, 
                 1=parsed for links, X=html, but not parsed for links 

*/

query_types_a:

if screens.!standalone=1 then
    call write_query_header 'URLs ' href1 ' to ' hrefs.0  
if screens.!verbose<>0 then do
  rc=multi_send('<br> Getting header info (for anchors ' href1 ' to ' hrefs.0 ')' )
  IF RC<0 then call doEXIT
end

tocheck.0=0
/* find all hrefs to lookup; copy to the tocheck array */
do mm=href1 to hrefs.0
   hrefs.mm.!type='n.a.' ; hrefs.mm.!size=-1 ; hrefs.mm.!refered=paurl
   hrefs.mm.!lastmod=' '
   hrefs.mm.!status=0 ; hrefs.mm.!nrefs=1 ; hrefs.mm.!queried=-1
   hrefs.mm.!nlinks=0  
   hrefs.mm.!appearin=anind
   hrefs.mm.!imglist='' 
   hrefs.mm.!reflist='' 
   hrefs.mm.!err=0                      /* http code, if an error (<200 or > 399) */
   
/* special size codes:
 -1 : server not available 
 -2 : no such resource on sever
 -3 : siteonly violation
 -4 : reserved
 -5 : excluded
*/
/* suppress this link? */
   if siteonly=1 then do
      if abbrev(translate(hrefs.mm),daroot)=0 then do 
          hrefs.mm.!size=-3             
          hrefs.mm.!queried=0
          iterate
      end /* do */
   end
   if exclusion_list||exclusion_list2<>'' then do
       parse var hrefs.mm . '//' . '/' arr
       if exclude_me(arr,exclusion_list,exclusion_list2,hrefs.mm,daroot)=1 then do
           hrefs.mm.!size=-5
           hrefs.mm.!queried=0
           iterate 
       end
   end 

/******* no longer supported
  is this server known to be down?    
   isbad=add_badsites(hrefs.mm,0)
   if isbad>0 then do
       hrefs.mm.!size=-1
       iterate
   end 
******/

/* check this href */
   uu=tocheck.0+1
   tocheck.uu=hrefs.mm
   tocheck.uu.!indx=mm
   tocheck.uu.!status=0  /* 0=not done,1=being done, 2=done */
   tocheck.0=uu
end


/* check all of the "tochecks"  -- do atonce "threads" at a time */
basesec=time('e') ; lastgoo=basesec
nbad=0

/* Prepare for thread launchs... clean up quque */
foy=rxqueue('s',myqueue)
ii=queued()
do ii0=1 to ii ;   pull gg ; end 
ntocheck=0
do llo2=2            /* until all tochecks are complete or timedout */
   nq=queued()          
   nowsec=time('e')
   alldone=0
   nowactive=0 ; actives=''
   do oj=1 to tocheck.0     /* keep maxatonce threads busy */

      astat=tocheck.oj.!status
      if astat=2 then alldone=alldone+1
      if astat=1 then do
           nowactive=nowactive+1
           actives=actives||' '||tocheck.oj
      end
      if astat<>0 then iterate    /* active or done, ignore */
      if nowactive>maxatonce then iterate

      tmp=get_url_0(query_method,tocheck.oj,isauth,oj,myqueue,screens.!mysem)
      parse var tmp tocheck.oj.!dmntid','tocheck.oj.!trans','.
      IF VERBOSE>2 THEN call pmprintf2('   'tocheck.oj ' on thread 'tocheck.oj.!dmntid)
      if screens.!standalone=1 then call write_query tocheck.oj.!indx': 'tocheck.oj
      tocheck.oj.!status=1
      nowactive=nowactive+1
      tocheck.oj.!birth=nowsec

   end                  /* or leave when at end of tocheck */
 
   if alldone=tocheck.0 then leave   /* all done with tocheck hrefs */

   if (nowsec-lastgoo)> min(15,(0.75*liminact)) then do   /* intermediate status report? */
       if screens.!verbose<>0 then do
         rc=multi_send('<br>&nbsp;&nbsp;&nbsp;... .('alldone' of 'tocheck.0', active threads='nowactive)
         if rc<0 then return 0
       end
       if screens.!standalone=1 then
          call write_note ' ... completed 'alldone' of 'tocheck.0' queries, active threads='nowactive
       lastgoo=nowsec
   end 

/* any new results? */
   if nq=0 then do      /* nothing to do */
      call syssleep 1           /* sleep for a second */
      screens.!keylist=get_key(screens.!Keylist)    
      if wordpos('1',screens.!keylist)>0 then call abort_job 'query anchors' /* will exit */
      if wordpos('2',screens.!keylist)>0 then call kill_transactions  /* timeout current transactions */
      if wordpos('3',screens.!keylist)>0 then do
          screens.!user_end=1
          call kill_transactions 1
          leave llo2
      end
      iterate                   /* and back to top of forever loop */
   end /* do  nq=0*/

/* if here, something in queue */
   parse pull yow
   anid=left(yow,25)
   parse var anid atrans','anind ; atrans=strip(atrans); anind=strip(anind)

/* check for nonsense */
   isbad=0
   if anind>tocheck.0 then isbad=1 
   if isbad=0 then  do                /* ignore  -- impossible tocheck index */
      if tocheck.anind.!trans<>atrans & atrans<>'FILE' then isbad=1 /* ignore -- bad transaction */
   end
   if isbad=1 then do
      call pmprintf2("BAD entry in queue: "anid)
      iterate
   end 

   ntocheck=ntocheck+1
   totgot=totgot+length(yow)

   tocheck.anind.!status=2              /* mark that this is done */
   errcode=substr(yow,26,1)


   ipaddress=substr(yow,27,20)
   stuff=substr(yow,47)
   if screens.!proxy='' then do
      tt='!'||server
      if ips.tt=' ' then ips.tt=ipaddress
   end

   mm=tocheck.anind.!indx

   hrefs.mm.!queried=0          /* query occured (success is another story! */

   if screens.!standalone=1 then do 
       call write_query 'X'||mm||': '
   end 

/* site not responding at all? */
  if errcode>1 & errcode<5 then do
     nbad=nbad+1
      hrefs.mm.!size=-1
      foo=add_badsites(hrefs.mm,,errcode)
      hrefs.mm.!type='n.a.' 
      iterate
   end /* do */

/* process stuff */
/* extract type and length */
   call extracts                   /* create headers. (there should not be a body! */
   parse var response ht num amess

  if num<200 | num>399 then do
      nbad=nbad+1
      hrefs.mm.!size=-2
      hrefs.mm.!err=num
      iterate
  end
  hrefs.mm.!type='unknown'
  hrefs.mm.!size=0
  hrefs.mm.!err=0
  hrefs.mm.!queried=0           /* queried, but not parsed for links */

  if wordpos('!CONTENT-TYPE',headers.0)>0 then do
    foo='!CONTENT-TYPE'
    parse var headers.foo att ';' .
    hrefs.mm.!type=strip(att)
    hrefs.mm.!size=0
  end
  if wordpos('!CONTENT-LENGTH',headers.0)>0 then do
        foo='!CONTENT-LENGTH'
        hrefs.mm.!size=headers.foo
  end
  if wordpos('!LAST-MODIFIED',headers.0)>0 then do
        foo='!LAST-MODIFIED'
        hrefs.mm.!lastmod=headers.foo
  end

end             /* OF TOCHECKS */

if tocheck.0>0 & screens.!standalone=1 then call write_note ntocheck ' queries completed ('nbad 'errors)'


return 1


/**************************************/
/* query types of images */
query_types_i:

if screens.!verbose<>0 then do
   rc=multi_send('<br>   Getting header info (for in-line images ' img1 ' to ' imgs.0 ')' )
   IF RC<0 then call doEXIT 
end

if screens.!standalone=1 then
   call write_query_header 'IMGs ' img1 ' to ' imgs.0  

tocheck.0=0
nbad=0
/* find all hrefs to lookup; copy to the tocheck array */
do mm=img1 to imgs.0
   imgs.mm.!type='n.a.' ;  imgs.mm.!size=0 ;  imgs.mm.!refered=paurl
   imgs.mm.!nrefs=1 ; imgs.mm.!err=0
   imgs.mm.!appearin=anind
   imgs.mm.!lastmod=' '

/* special size codes:
 -1 : server not available 
 -2 : no such resource on sever
 -3 : siteonly violation
 -4 : reserved
 -5 : exclusion violate
*/

/* suppress this link? */
   if siteonly=1 then do
      if abbrev(translate(imgs.mm),daroot)=0 then do 
          imgs.mm.!size=-3             
          iterate
      end /* do */
   end

   if exclusion_list||exclusion_list2<>'' then do
       parse var imgs.mm . '//' . '/' arr
       if exclude_me(arr,exclusion_list,exclusion_list2,hrefs.mm,daroot)=1 then do
         imgs.mm.!size=-5
         iterate 
       end
   end /* do */

/********** NO LONGER SUPPORTED 
  is this server known to be down?    
   isbad=add_badsites(imgs.mm,0)
   if isbad>0 then do             /* check twice before marking as bad */
            imgs.mm.!size=-1
            iterate
   end 
************/

/* check this src */
   uu=tocheck.0+1
   tocheck.uu=imgs.mm
   tocheck.uu.!indx=mm
   tocheck.uu.!status=0  /* 0=not done,1=being done, 2=done */
   tocheck.0=uu
end

/* check all of the "tochecks"  -- do atonce "threads" at a time */
basesec=time('e') ; lastgoo=basesec

/* Prepare for thread launchs... clean up quque */
foy=rxqueue('s',myqueue)
ii=queued()
do ii0=1 to ii ;   pull gg ; end 
ntocheck=0
do llo2=3            /* until all tochecks are complete or timedout */

   nq=queued()          
   nowsec=time('e')
   alldone=0
   nowactive=0
   do oj=1 to tocheck.0     /* keep maxatonce threads busy */
      astat=tocheck.oj.!status
      if astat=2 then alldone=alldone+1
      if astat=1 then nowactive=nowactive+1
      if astat<>0 then iterate    /* active or done, ignore */
      if nowactive>maxatonce then iterate

      tmp=get_url_0(query_method,tocheck.oj,isauth,oj,myqueue,screens.!mysem)
      parse var tmp tocheck.oj.!dmntid','tocheck.oj.!trans','.
      IF VERBOSE>2 THEN call pmprintf2(' 'tocheck.oj ' on thread... .. ' tocheck.oj.!dmntid)
      if screens.!standalone=1 then do
        call write_query tocheck.oj.!indx' img: ' tocheck.oj
      end
      tocheck.oj.!status=1
      tocheck.oj.!birth=nowsec

      nowactive=nowactive+1
   end                  /* or leave when at end of tocheck */
 
   if alldone=tocheck.0 then leave   /* all done with tocheck imgss */

   if (nowsec-lastgoo)> min(15,(0.75*liminact)) then do   /* intermediate status report? */
       if screens.!verbose<>0 then do
          rc=multi_send('<br>&nbsp;&nbsp;&nbsp;... ..('alldone' of 'tocheck.0')')
          if rc<0 then return 0
       end
       if screens.!standalone=1 then do
         call write_note alldone' of 'tocheck.0' img queries'
       end
       lastgoo=nowsec
   end /* do */


/* any new results? */
   if nq=0 then do      /* nothing to do  */
      call syssleep 1           /* sleep for a second */
      screens.!keylist=get_key(screens.!Keylist)    
      if wordpos('1',screens.!keylist)>0 then call abort_job 'query images' /* will exit */
      if wordpos('2',screens.!keylist)>0 then call kill_transactions   /* timeout current transactions */
      if wordpos('3',screens.!keylist)>0 then do               /* user forced end */
         screens.!user_end=1
         call kill_transactions 1
         leave llo2
      end

      iterate                   /* and back to top of forever loop */
   end /* do  nq=0*/

/* if here, something in queue */
   parse pull yow
   totgot=totgot+length(yow)

   anid=left(yow,25)
   parse var anid atrans','anind ; atrans=strip(atrans); anind=strip(anind)

/* check for nonsense */
   if anind>tocheck.0 then iterate              /* ignore  -- impossible tocheck index */
   if tocheck.anind.!trans<>atrans & atrans<>'FILE' then iterate /* ignore -- bad transaction */

   tocheck.anind.!status=2              /* mark that this is done */

   errcode=substr(yow,26,1)
   ipaddress=substr(yow,27,20)
   stuff=substr(yow,47)
   if screens.!proxy='' then do
      tt='!'||server
      if ips.tt=' ' then ips.tt=ipaddress
   end

   mm=tocheck.anind.!indx
   if screens.!standalone=1 then do 
       call write_query 'X'||mm||' img: '
   end 

/* process stuff */

/* site not responding at all? */
  if errcode>1 & errcode<5 then do
      imgs.mm.!type='n.a.'  ; imgs.mm.!size=-1
      foo=add_badsites(imgs.mm,,errcode)
       nbad=nbad+1
      iterate
   end /* do */

  ntocheck=ntocheck+1

/* extract type and length */
   call extracts                   /* create headers. (there should not be a body( */
   parse var response ht num amess

  if num<200 | num>399 then do
     call pmprintf(mm" num "num ','hrefs.mm)

      imgs.mm.!size=-2
      imgs.mm.!err=num
       nbad=nbad+1
      iterate
  end

  imgs.mm.!type='unknown'
  imgs.mm.!size=0
  imgs.mm.!err=0

  if wordpos('!CONTENT-TYPE',headers.0)>0 then do
    foo='!CONTENT-TYPE'
     parse var headers.foo att ';' .
     imgs.mm.!type=strip(att)
     imgs.mm.!size=0
  end
  if wordpos('!CONTENT-LENGTH',headers.0)>0 then do
    foo='!CONTENT-LENGTH'
    imgs.mm.!size=headers.foo
  end
  if wordpos('!LAST-MODIFIED',headers.0)>0 then do
        foo='!LAST-MODIFIED'
        imgs.mm.!lastmod=headers.foo
  end


end             /* OF TOCHECKS */

if tocheck.0>0   & screens.!standalone=1 then call write_note ntocheck' img queries completed ('nbad 'errors)'

return 1


/**************************************/
/* double check n.a. servers */
double_check_it:procedure  expose myqueue hrefs. stuff imgs. isauth siteonly  verbose screens. ,
       query_method ips. ,
       exclusion_list2 exclusion_list maxatonce maxage  totgot thread_string badsites. doing_results ,
        servername transaction
parse arg howto

if howto=0 then return 1        /* do not double check */
liminact=extract2('limittimeinactive')

tocheck.0=0
/* find all hrefs to lookup; copy to the tocheck array */
drop tocheck.
tocheck.0=0
do mm=1 to hrefs.0
  if hrefs.mm.!size>0  then iterate /*no problem */
  if howto=1 & hrefs.mm.!size<>-1 then iterate /* not na server */
  if howto=2 & abs(hrefs.mm.!size)>2 then iterate /* not na or missing resource */
  if abbrev(translate(hrefs.mm),'FILE:///')=1 then iterate /* don't try doing file links */

/* check this href */
   uu=tocheck.0+1
   tocheck.uu=hrefs.mm
   tocheck.uu.!indx=mm
   tocheck.uu.!status=0  /* 0=not done,1=being done, 2=done */
   tocheck.0=uu
end
if tocheck.0=0 then return 1  

hfixed=0
if verbose>2 then call pmprintf2('Checklink. Double checking ' tocheck.0  ' unobtainable URLS.')
screens.!noscreen=1
if screens.!verbose<>0 then do
   rc=multi_send('<br>Double checking 'tocheck.0 ' links')
   if rc<0 then return 0
end
if screens.!standalone=1 then
  call write_note_header 'Double checking 'tocheck.0 ' links'
  call write_query_header 'Double checking  'tocheck.0' of 'hrefs.0'  URLS'  


/* check all of the "tochecks"  -- do atonce "threads" at a time */
basesec=time('e') ; lastgoo=basesec

/* Prepare for thread launchs... clean up quque */
foy=rxqueue('s',myqueue)
ii=queued()
do ii0=1 to ii ;   pull gg ; end 

do forever            /* until all tochecks are complete or timedout */

   nowsec=time('e')
   alldone=0
   nowactive=0

   do oj=1 to tocheck.0     /* keep maxatonce threads busy */
      astat=tocheck.oj.!status
      if astat=2 then alldone=alldone+1
      if astat=1 then nowactive=nowactive+1
      if nowactive>maxatonce then iterate

      if astat<>0 then iterate    /* active or done, ignore */

      tmp=get_url_0('HEADGET',tocheck.oj,isauth,oj,myqueue,screens.!mysem)
      parse var tmp tocheck.oj.!dmntid','tocheck.oj.!trans','.
      IF VERBOSE>2 THEN 
        call pmprintf2(' CheckLink: Double check 'tocheck.oj ' on thread ' tocheck.oj.!dmntid)
      if screens.!standalone=1 then
         call write_query tocheck.oj.!indx': Double check 'tocheck.oj
      tocheck.oj.!status=1
      tocheck.oj.!birth=nowsec
      nowactive=nowactive+1
   end                  /* or leave when at end of tocheck */
 

   if alldone=tocheck.0 then leave   /* all done with tocheck hrefs */
   if (nowsec-lastgoo)> min(15,(0.75*liminact)) then do   /* intermediate status report? */
       screens.!noscreen=2
       if screens.!verbose<>0 then do
          rc=multi_send('<br>&nbsp;&nbsp;&nbsp;... ...('alldone' of 'tocheck.0')')
          if rc<0 then return 0
        end
        if screens.!standalone=1 then do
          call write_note ' ... completed 'alldone' of 'tocheck.0
        end
       lastgoo=nowsec
   end /* do */


/* any new results? */
   foy=rxqueue('s',myqueue)
   nq=queued()          
   if nq=0 then do      /* nothing to do  */
      call syssleep 1           /* sleep for a second */
      screens.!keylist=get_key(screens.!Keylist)    
      if wordpos('1',screens.!keylist)>0 then call abort_job 'double check' /* will exit */
      if wordpos('2',screens.!keylist)>0 then call kill_transactions /* timeout current transactions */
      if wordpos('3',screens.!keylist)>0 then do               /* user forced end */
          screens.!user_end=1
         call kill_transactions 1
         leave             /* user forced end */
      end

      iterate                   /* and back to top of forever loop */
   end /* do  nq=0*/

/* if here, something in queue */
   parse pull yow
   totgot=totgot+length(yow)


   anid=left(yow,25)
   parse var anid atrans','anind ; atrans=strip(atrans); anind=strip(anind)
   if anind>tocheck.0 then iterate /* ignore  -- impossible tocheck index */
   if tocheck.anind.!trans<>atrans then iterate /* ignore -- bad transaction */

   tocheck.anind.!status=2              /* mark that this is done */
   if screens.!standalone=1 then call write_query 'X'||oj':'

   errcode=substr(yow,26,1)

   ipaddress=substr(yow,27,20)
   stuff=substr(yow,47)
   if screens.!proxy='' then do
      tt='!'||server
      if ips.tt=' ' then ips.tt=ipaddress
   end

   mm=tocheck.anind.!indx

  if errcode>1 & errcode<5 then do
      hrefs.mm.!type='n.a.'  ; hrefs.mm.!size=-1
      iterate
   end 


/* process stuff */
  if stuff="" then iterate

/* extract type and length */
   call extracts                   /* create headers.  */
   parse var response ht num amess

  if num<200 | num>399 then do
      hrefs.mm.!size=-2
      hrefs.mm.!err=num
      iterate
  end
  hrefs.mm.!type='unknown'
  hrefs.mm.!size=0
  hrefs.mm.!err=0

  hfixed=hfixed+1
  if wordpos('!CONTENT-TYPE',headers.0)>0 then do
    foo='!CONTENT-TYPE'
    parse var headers.foo att ';' .
    hrefs.mm.!type=strip(att)
    hrefs.mm.!size=0
  end
  if wordpos('!CONTENT-LENGTH',headers.0)>0 then do
        foo='!CONTENT-LENGTH'
        hrefs.mm.!size=headers.foo
  end
  if wordpos('!LAST-MODIFIED',headers.0)>0 then do
        foo='!LAST-MODIFIED'
        hrefs.mm.!lastmod=headers.foo
  end

  /* signal that this html doc was not looked at (contents were not processed) */
   if translate(hrefs.mm.!TYPE)<>'TEXT/HTML' then do
     if abbrev(translate(hrefs.mm),mustpre)=1 then do
        hrefs.mm.!queried='X'     
     end
   end 



end             /* OF TOCHECKS */

if screens.!standalone=1 then do
  call write_note "# of n.a. or missing resources  succesfully double checked= "hfixed
end

return 1



/************************/
/* write stuff */
write_img_href:procedure expose imgs. hrefs. crlf totgot baseonly  linkfile screens. ,
                row_color1 row_color2 row_color1a row_color2a verbose doing_results ascgi ,
                include_cheklnk2 rooturl server servername transaction ips. max_table_rows ,
                title_chars

parse arg i1,h1,outtype

acodes.!OK='Successfully checked links '
acodes.1='Problem links: Server not available '
acodes.2='Problem links: No such resource on server'
acodes.3='Not checked links: Off-site '
acodes.4=''
acodes.5='Not checked links: Excluded selectors '
acodes.!ALL='All the links '

anames.!OK='OKS'
anames.1='NOSITE'
anames.2='NOURL'
anames.3='OFFSITE'
anames.4=''
anames.5='EXCLUDED'
anames.!ALL='ALL'


codesb.0='<tt>size n.a.</tt>'
codesb.1='Server n.a.'
codesb.2='Missing resource'
codesb.3='Off-site '
codesb.4=''
codesb.5='Excluded '

chlink='/CHEKLNK2'
if ascgi=1 then chlink='/CGI-BIN/CHEKLNK2.CMD'

 aa='<P><hr width="66%"> ' crlf ,
     '<a name="'anames.outtype'"> <h3 align="center"> 'acodes.outtype '</h3> </a>' crlf ,
     '<b>IM</b>a<b>G</b>es: ' crlf

 rc=multi_send(aa)
 if rc<0 then return rc

stable0=' There are  <b>no</b> <em> 'acodes.outtype '</em> Image links.'
/* write this if not any matches */

stable='<table> '
if linkfile<>0 & linkfile<>'' & include_cheklnk2=1 then do
   stable='<table><th>? </th> '
end /* do */
stable=stable'<th>IMG Location</th><th>mimetype</th><th>size<br><em>or error code</em></th> ' crlf ,
           '<th><tt>number of references, <em>1st reference </em></th> ' crlf 

call sort_nhref 1  /* sort imgs */


iwrote=0
do mm0=i1 to imgs.0
 
   mm=sortlist.mm0

/* skip this one ? */
   ssiz=imgs.mm.!size
   if outtype<>'!ALL' then do          /* not an ALL links report */
      if ssiz>0  then do 
        if outtype<>'!OK' then iterate
      end /* do */
      else do
         if abs(ssiz)<>outtype then iterate
      end /* do */
   end /* do */

/* write stuff to table */
    if stable<>'' then do               /*write table header */
         rc=multi_send(stable); stable=''
         if rc<0 then return rc
    end

    iwrote=iwrote+1
    ismiss=0
     if imgs.mm.!size=-2 | imgs.mm.!size=-1 then ismiss=1

     ack=breakup(imgs.mm,36,rooturl)

     bgc=choose_row_color(iwrote,row_color1,row_color2,row_color1a,row_color2a,ack)

     aa=crlf'<TR ' bgc '> <td>'
     if linkfile<>0 & linkfile<>'' & include_cheklnk2=1 then do
         cl2=' <a href="'chlink'?linkfile='linkfile'&isimg=1&entrynum='mm'"> ? </a> &nbsp; '
         aa=aa||cl2 '</td><td> '
      end

     if imgs.mm.!size>=0 then do
       aa=aa||'<font size=-1>'mm'. </font> <a href="'imgs.mm'">'ack'</a></td>' crlf
     end
     else do
       iwrote2='<a href="'imgs.mm'">'mm'</a>'
       aa=aa||' <font size=-1>'iwrote2'. </font> <u>'ack'</u></td>' crlf
     end

     ack=imgs.mm.!type
     ackadd=''
     if pos('/',ack)=0  & imgs.mm.!err<>0 then ackadd='<br>('imgs.mm.!err')'
     if length(ack)>20 then do
        parse var ack a1 '/' a2 ; ack=a1'/<br>'a2
     end /* do */
     aa=aa||'<td> <tt>'ack||ackadd'</tt></td> ' crlf

     if imgs.mm.!size>0 then do
       aa=aa||'<td> <tt>'imgs.mm.!size '</tt> ' crlf
     end
     else do
       mam=abs(imgs.mm.!size)
       mamo=codesb.mam
       if ismiss=1 then 
          mamo='<b>'mamo'</b>'
       else
          mamo='<em>'mamo'</em>'
       aa=aa||'<td> 'mamo' </td>' crlf
     end

     nhh=addcomma(imgs.mm.!nrefs)                       /* the refered by stuff */
     lhh=lower(imgs.mm.!refered) ; lhh2=lhh
     lhh2=breakup(lhh,35,rooturl)
     aa=aa||'<td><tt>'nhh'</tt>, <em><a href="'lhh'">'lhh2'</a></em></td>'
     rc=multi_send(aa)
     if rc<0 then return rc
end /* do */

if stable='' then
  rc=multi_send('</table>')
else
  rc=multi_send(stable0)
if rc<0 then return rc

/* --------------- now do anchors */

ifc=''
/* if wordpos(outtype,'!ALL !OK 0 6')>0 then
  ifc=' (if checked, # <tt>&lt;A href</tt>s)' */

aa='<P><hr width="30%">' crlf
aa=aa||'<b>A</b>nchors:'
rc=multi_send(aa)
if rc<0 then return rc

stable0=' There are  <b>no</b> <em> 'acodes.outtype '</em>  Anchor links.'

stable='<table> '
if linkfile<>0 & linkfile<>'' & include_cheklnk2=1 then do
   stable='<table><th>? </th> '
end /* do */
stable=stable'<th>URL &nbsp; &nbsp; &nbsp;'ifc' </th><th><u>#</u></th> ' crlf ,
         ' <th>mimetype</th><th>size<br><em>or error code</em></th> ' crlf ,
           '<th><tt>number of references, <em>1st reference </em></th> ' crlf 

iwrote=0

/* sort 'em */
call sort_nhref 0

do mmn=h1 to hrefs.0
   mm=strip(sortlist.mmn)

/* skip this one ? */
   ssiz=hrefs.mm.!size
   if outtype<>'!ALL' then do          /* not an ALL links report */
      if ssiz>0  then do 
        if outtype<>'!OK' then iterate
      end /* do */
      else do
         if abs(ssiz)<>outtype then iterate
      end /* do */
   end /* do */

/* write stuff */
    if stable<>'' then do               /*write table header */
         rc=multi_send(stable); stable=''
         if rc<0 then return -1
    end
  
/* write this one */
    iwrote=iwrote+1  
    if iwrote>max_table_rows then do   /* start a new table */
       aa='</table><table>'
       rc=multi_send(aa)
       if rc<0 then return -1
       iwrote=1
    end 


     ack=breakup(hrefs.mm,36,rooturl)

     bgc=choose_row_color(iwrote,row_color1,row_color2,row_color1a,row_color2a,ack)

/* write a link to cheklnk2 ? */
     aa=crlf'<TR ' bgc '> <td>'         
     if linkfile<>0 & linkfile<>'' & include_cheklnk2=1 then do
         cl2=' <a href="'chlink'?linkfile='linkfile'&isimg=0&entrynum='mm'"> ? </a> &nbsp; '
         aa=aa||cl2 '</td><td> '
      end

/* idnumber and url, and possibly title */
     if hrefs.mm.!size>=0 then do               /* number, or linked number */
        ack2=''
        if hrefs.mm.!title<>'' & title_chars>0 then do
             jsz=min(title_chars,length(hrefs.mm.!title))
             ack2='<br><em>'||left(hrefs.mm.!title,jsz)||'</em>'
        end
        aa=aa||' <font size=-1>'mm'. </font> <a href="'hrefs.mm'">'ack'</a>'||ack2||'</td>' crlf
     end
     else do
        iwrote2=' <a href="'hrefs.mm'">'mm'</a>'
        aa=aa||' <font size=-1>'iwrote2'. </font> <u>'ack'</u></td>' crlf
     end

/* # of links in this document */
     xx='&nbsp; ' ;
     if hrefs.mm.!queried=1 then xx='<em>'hrefs.mm.!nlinks'</em>';  /* links in this document */
     if hrefs.mm.!queried='X' then xx='<em>n.a.</em>'           /* double checked, so not queried*/

     aa=aa||'<td>'xx'</td>'||crlf               

/* content type */
     ack=hrefs.mm.!type
     ackadd=''
     if pos('/',ack)=0 & hrefs.mm.!err<>0 then ackadd='<br>('hrefs.mm.!err')'
     if length(ack)>20 then do
        parse var ack a1 '/' a2 ; ack=a1'/<br>'a2
     end /* do */
     aa=aa||'<td> <tt>'ack||ackadd||'</tt></td> ' crlf


/* size or error code */
     if hrefs.mm.!queried=-1 & ackadd='' then do
        aa=aa||'<td> <tt>Not <br> read</tt> ' crlf
     end 
     else do
       if hrefs.mm.!size>0 then do
         aa=aa||'<td> <tt>'hrefs.mm.!size '</tt> ' crlf
       end
       else do
         mam=abs(hrefs.mm.!size)
         mamo=codesb.mam
         if hrefs.mm.!size=-2 | hrefs.mm.!size=-1 then
              mamo='<b>'mamo'</b>'
         else
              mamo='<em>'mamo'</em>'
         aa=aa||'<td> 'mamo' </td>' crlf
       end
     end


     nhh=addcomma(hrefs.mm.!nrefs)              /* the refered by column */
     lhh=lower(hrefs.mm.!refered);lhh2=lhh
     lhh2=breakup(lhh,36,rooturl)
     aa=aa||'<td> <tt>'nhh'</tt>, <em><a href="'lhh'">'lhh2'</a></em></td>'
     rc=multi_send(aa)
     if rc<0 then return rc

end /* do hrefs.mm */

if stable='' then
  rc=multi_send('</table>')
else
  rc=multi_send(stable0)
if rc<0 then return rc

rc=multi_send('<br><a href="#SUMMARY">... back to summary </a>')
if rc<0 then return rc
  
return 1

/* end of WRITE_IMG_HREF */

/***********/
/* choose color for this row, depending on  row# and type of lin (off or on site */
choose_row_color:procedure
parse arg nth,c1,c2,c3,c4,alink

if abbrev(alink,'/')=1 then do  /* on-site */
     bgc=c3
     if nth//2=0 then bgc=c4
end
else do
     bgc=c1
     if nth//2=0 then bgc=c2
end /* do */
return bgc
   


/*********************************/
/********************************/
/* sort nhrefs. list of urls --- subdirectory sensitive */
sort_nhref:procedure expose hrefs. sortlist. crlf imgs. server ips. screens.
parse arg iimg

if iimg<>1 then do
  do mn=1 to hrefs.0
     nhrefs.mn=hrefs.mn
  end /* do */
  nhrefs.0=hrefs.0 ;maxssn=0
end
else do
  do mn=1 to imgs.0
     nhrefs.mn=imgs.mn
  end /* do */
  nhrefs.0=imgs.0 ;maxssn=0
end /* do */

/* make an array with sortable elements in portions of each record */
elemsizes.0=0 ; maxfname=0
do jj=1 to 40
   elemsizes.jj=0
end /* do */
do is=1 to nhrefs.0
     aa1=strip(strip(nhrefs.is,'l','/'))
     parse var  aa1 . '//' ssn '/' a1
     if translate(ssn)=translate(server) then ssn=''
     biglist.is.!srv=ssn  
     maxssn=max(maxssn,length(ssn))
     h1=lastpos('/',a1)         /* pluck off "file name" */
     biglist.is.0=0
     if h1>0 then do
        biglist.is=substr(a1,h1+1)
        maxfname=max(maxfname,length(biglist.is))
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
do ipp=1 to elemsizes.0
   elemsizes.ipp=elemsizes.ipp+1
end /* do */
/* make the big elements array */
do ii=1 to NHREFS.0
  oo.ii=left(ii,6)' 'left(biglist.ii.!srv,maxssn+1)
  do mm=1 to ELEMSIZES.0
      if mm<=biglist.ii.0 then 
         oo.ii=oo.ii||left(biglist.ii.mm,elemsizes.mm)
     else
         oo.ii=oo.ii||left(' ',elemsizes.mm)
  end /* do */
  oo.ii=oo.ii||left(biglist.ii,maxfname)
end /* do */

OO.0=NHREFS.0
sortlist.0=0
if oo.0=0 then return 0

EEF=ARRAYSORT(OO,,,7,,'A','I')         /* sort the names */

DO MM=1 TO NHREFS.0
   sortlist.mm=strip(left(oo.mm,6))
end /* do */
sortlist.0=nhrefs.0
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


/*******************************/
/* get/head a url using a daemon (do not wait for response -- response is written to the "aqueue" queue) */
GET_URL_0:procedure expose verbose   totgot thread_string   doing_results , 
                        servername maxage transaction ips.  screens.
parse arg type,a1,isauth,indid,aqueue,asem

crlf='0d0a'x

/* file request */
if abbrev(translate(a1),'FILE:///')=1 then do
    parse upper var a1 . 'FILE:///' request
    server=0 ; isip=' '
    stuff=get_url(type,0,request)
    fp=rxqueue('s',aqueue)
    id=left('FILE,'||indid,25)||'0'
    queue left(id,47)||stuff
    foo=rxqueue('s',fp)
    if verbose>2 then call pmprintf2("File read of: "request)
    return 'file,file'
end

/* else, http request */
parse var a1 . '//' server '/' request
if datatype(MAXAGE)<>'NUM' then do
      call pmprintf2( "ERROR IN GET_URL_0 BAD MAXAGE: "maxage "; "a1)
      call doexit
end 

if screens.!proxyaddr<>'' then do
     pisip=screens.!proxyaddr
     isip=''
end 
else do
  tt='!'||server
  isip=ips.tt
  pisip=''
end
tt=transaction     /* used as a queue entry id */
iid=left(tt','indid,25,' ')

att=rexxthread('m','CHEKLINK_GET_URL',maxage,type,server','isip','pisip,request,,
                    isauth,verbose,aqueue||' '||asem,iid,servername)

return  att','iid               /*att is the thread */


/*******************************/
/* get/head a url (normal procedure call, NOT a daemon call) */ 
get_url:procedure expose verbose myqueue  totgot  thread_string maxage  doing_results , 
                                   servername transaction errcode ipaddress ips.  screens.

parse arg type,server,request,isauth,asproc
crlf='0d0a'x

if server=0 then do             /* it's a file */ 
   ipaddress=0
   errcode=0
   isize=stream(request,'c','query size')
   if isize=0 | isize='' then do                /*empty or missing */
       stuff='FILE 401 Missing file '||crlf||crlf
       errcode=100
       return stuff        
   end 
   stuff='FILE 200 Ok file '||crlf
   stuff=stuff||'Content-Length: 'isize||crlf
   atype=mediatype(request)
   stuff=stuff||'Content-Type: 'atype||crlf
   foo=sysfiletree(request,'o2.','FT')
   if o2.0>0 then do
       parse var o2.1 adate .
       stuff=stuff||'Last-Modified: '||adate||crlf
   end 
   stuff=stuff||crlf

   if type='HEAD' | type='HEADGET' then do
       return stuff
   end

/* a GET or DSCGET  request ... */
   aa=stream(request,'c','open read')
   if abbrev(translate(strip(aa)),'READY')<>1 then do
       stuff='FILE 401 Unreadable file '||aa||crlf||crlf
       errcode=101
       return stuff        
   end 
   if type='DSCGET' then isize=min(isize,1500)
   s2=charin(request,1,isize)
   foo=stream(request,'c','close')
   errcode=0
   return stuff||s2
end 


/* if here, http (not a file) request */
if amaxage<>'' & datatype(amaxage)='NUM' then 
  mxage=amaxage
else
  mxage=maxage

stuff=cheklink_get_url(mxage,type,server||',,'||screens.!proxyaddr,request,isauth,verbose,'', ,
                                   transaction,servername)

errcode=substr(stuff,1,1)
ipaddress=substr(stuff,2,20)
stuff=substr(stuff,22)
if screens.!proxy='' then do
   tt='!'||server
   if ips.tt=' ' then ips.tt=ipaddress
end


return stuff


/*************************************/
/* extract headers and body */
extracts:
parse arg noheaders

cr='0a'x
parse var stuff response (cr) stuff
response=strip(response,,'0d'x)
  headers.0=''
  do forever
    parse var stuff  ahead  (cr) stuff
    ahead=strip(ahead,,'0d'x)
    if ahead='' then leave
    parse var ahead name ':' aval
    nn=translate('!'||name)
    headers.0=headers.0' 'nn
    headers.nn=aval
  end /* do */

/* remove html comments */
body=""
stuff2x=stuff
do forever              /*no comments within comments are allowed */
   if stuff2x="" then leave
   parse var stuff2x t1 '<!-- ' t2 '-->' stuff2x
   body=body||t1
end /* do */
return 1


/*--- augment badsites array */
add_badsites:procedure expose badsites. ips.  screens.
parse arg aref,doadd,errcode
parse var aref . '//' aserv '/' 
aserv='!'||space(translate(aserv),0)
if doadd<>0 then do
    badsites.aserv.errcode=badsites.aserv.errcode+1
end
return badsites.aserv
      

/* --- Load the function library, if necessary --- */
load:
hrefs.=''
badsites.=0 
ips.=' '
screens.=''
screens.!standalone=0              /* set to 1 if standalone mode */
screens.!remove_script=remove_script
aesc='1B'x
screens.!keylist=''
screens.!nogetkey=0
screens.!user_end=0

/* error codes returned by cheklink_get_url */
ecodes.4 = 'sockgethostbyname error '
ecodes.1 = 'ioctl error'
ecodes.2 = 'connection error'
ecodes.3 = 'sockin problem '
ecodes.0 = 'ok'
ecodes.100='missing file'
ecodes.101='inaccessible file'

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
    call doexit
end /* do */


/* now load some macrospace procedures */
cheklink_dir=strip(strip(cheklink_dir),'t','\')
if cheklink_dir='' | dosisdir(cheklink_dir)=0 then
   cheklink_dir=directory()

/* this macrospaced procedure is used as the source for the "get a url"  threads */
a1=macroquery('CHEKLINK_GET_URL')
if a1<>'' then do
    foo=cheklink_get_url('VERSION')
    if foo<>lib_ver then a1=''                   /* force reload of proc */
end 

if a1='' then do                /* not available, so load it */
   a2=cheklink_libdir'\CHECK1.SRF'
   foo=macroadd('CHEKLINK_GET_URL',a2)
   if foo=0 then do
      if screens.!standalone<>0 then
         say 'ERROR LOADING CHEKLINK_GET_URL FROM 'a2
      else
        call pmprintf2('ERROR LOADING CHEKLINK_GET_URL FROM 'a2)
      call doexit
   end /* do */
end 

foo=cheklink_get_url('VERSION')
if foo<>lib_ver then  do
 say "ERROR: the procedure library (CHECK1.SRF) is version:" foo
 say "       the program is version: "lib_ver
 call doexit
end

/* fix "types" */
a=''
do until html_types=''
   parse upper var html_types a1 html_types ;a1=strip(a1)
   a=a||' .'||strip(a1,,'.')
end 
html_types=a

a=''
do until text_types=''
   parse upper var text_types a1 text_types ;a1=strip(a1)
   a=a||' .'||strip(a1,,'.')
end 
text_types=a


return 1


/***********************************/
/* search a file, find IMG SRC=, FRAME SRC=, and A HREF= urls. Add BASEURL if
   no / or http://.../ at beginning of URL 
   Return results in hrefs. and imgs. */

findurls:procedure expose  imgs. hrefs. totgot crlf  verbose doing_results dscmax make_descrip ,
                                     servername transaction ips.  screens.

parse arg stuff, baseurl,rooturl,burl,the_anind


base2=base_element(stuff)

if base2<>'' then do
  baseurl=base2
  baseurl=left(baseurl,lastpos('/',baseurl))
  parse var baseurl . '//' rooturl '/' .
  rooturl='http://'rooturl'/'
  if verbose>1 then call pmprintf2( " ... using <BASE element of "base2)
end

fileurls.=''
nf=0
liminact=extract2('limittimeinactive')

basegoo=time('e')
/* convert '< x' to '<x' */
stuff=translate(stuff,' ','0d0a0900'x)
do forever
 wow=pos('< ',stuff)
 if wow=0 then leave
 newstuff=''
 do forever
     parse var stuff a1 '< '  stuff
     newstuff=newstuff||a1
     if stuff<>""  then 
          newstuff=newstuff||'<'
     else
         leave
 end 
 stuff=newstuff
end

/* remove <SCRIPT> and "JAVASCRIPT: stuff */
if screens.!remove_script=1 then do
ss=''
do until stuff=''
   parse var stuff a1 '<' stuff
   ss=ss||a1
   parse var stuff a2a .
   a2a=strip(translate(a2a))
   if abbrev(a2a,'SCRIPT')=1 then do              /* remove to </script */
       do until stuff=''
          parse var stuff a3 '<' a4 '>' stuff
          parse upper var a4 a4a .
          if  strip(a4a)='/SCRIPT' then leave
       end 
       iterate
   end
 
   if a2a='A' then do
       parse upper var stuff . 'HREF=' a4
       parse var a4 a5 a6 ; a5=strip(a5)
       a5=strip(a5,'l','"')
       if abbrev(a5,'JAVASCRIPT:')=1 then do
          parse var a4 '"' . '"' stuff
          iterate
       end
   end
   if stuff<>"" then ss=ss'<'
end
stuff=ss
end

tstuff=translate(stuff)

/*call write_bottom 'x '
say stuff */


/* find TITLE element */
a1=pos('</HEAD',tstuff)
if a1>0 then do
   a2=pos('<TITLE',tstuff)
   if a2<a1 & a2<>0  then do            /* <TITLE in <HEAD */
      a3=pos('</TITLE',tstuff,a2)
      IF A3=0 then DO                   /* NOT </TITLE ! */
         HREFS.THE_ANIND.!TITLE='no_title'
      end /* do */
      else DO
        a4=substr(stuff,a2,1+a3-a2)
        parse var a4 . '>' atitle '<' .
        atitle=space(strip(atitle),1)
        hrefs.the_anind.!title=atitle
      END
   end /* do */
end /* do */

/* find description  */
if  make_descrip>1 then do
   goo=fig_descript(a1)
   if goo<>'' then hrefs.the_anind.!descrip=goo
end /* do */

/* find all  FRAME SRC=, IMG SRC= and A HREF=, throw away internal links */
lookfor.1='<BODY '
lookfor.2='<IMG '
lookfor.3='<A '
lookfor.4='<FRAME '
lookfor.5='<AREA '
lookfor.6='<EMBED '
lookfor.7='<LINK '
lookfor.8='<APPLET '
lookfor.9='<OBJECT '

do anctype=1 to 9
nowtarg=lookfor.anctype
strt=1

do forever
    s1a=pos(nowtarg,tstuff,strt)
    if s1a=0 then leave
    s2a=pos('>',tstuff,s1a)
    if s2a=0 then leave         /* error, give up on this one */
    anarg=substr(stuff,s1a+1,(s2a-s1a)-1)
    anarg=translate(anarg,' ','0d0a0900'x)
    strt=s2a+1

    select 

       when anctype=1 then do           /* body background */
         do forever
            if anarg=''  then leave
            parse var anarg a1 anarg ; a1=strip(a1)
            if abbrev(translate(a1),'BACKGROUND=')=0 then iterate
            parse var a1 . '=' gotimg . ; gotimg=strip(strip(gotimg),,'"')
            if left(gotimg,2)='//' then gotimg='http:'gotimg

            nf=nf+1
            fileurls.nf=fix_url(gotimg,baseurl,rooturl)
            fileurls.nf.!img=1
            leave
         end /* do */
       end                              /* i3>0 */
       when anctype=2 then do                /* img */
         do forever
            if anarg=''  then leave
            parse var anarg a1 anarg ; a1=strip(a1)
            if abbrev(translate(a1),'SRC=')=0 then iterate
            parse var a1 . '=' gotimg . ; gotimg=strip(strip(gotimg),,'"')
            if left(gotimg,2)='//' then gotimg='http:'gotimg

            nf=nf+1

            fileurls.nf=fix_url(gotimg,baseurl,rooturl)
            fileurls.nf.!img=1
            leave
         end /* do */
       end

       when anctype=3 | anctype=5  | anctype=7 then do /* A AREA LINK */
         do forever
            if anarg=''  then leave
            parse var anarg a1 anarg ; a1=strip(a1)
            if abbrev(translate(a1),'HREF=')=0 then iterate
            parse var a1 . '=' gothref . ; 

/***** This needs to be fixed up (To deal with Javascript! 
            tgot=translate(left(strip(gothref),20,' ')))
            if abbrev(tgot,'JAVASCRIPT:')+abbrev(tgot,'"JAVASCRIPT:')>0 then do
                if pos('"',strip(anarg),2)=0  then do    
                   s1a=pos('"',tstuff,strt)
                   if s1a=0 then 
                        strta=length(tstuff)
                   else
                        strt=s1a+1
                end 
                iterate
            end
******************************/

            gothref=strip(strip(gothref),,'"')

            parse var gothref gothref '#' .     /* toss out internal jumps */
            if gothref="" then iterate

            if left(gothref,2)='//' then gothref='http:'gothref
            parse upper var  gothref uaref ':' .        /* non -http are discarded */
            if wordpos(uaref,'MAILTO FTP FILE JAVASCRIPT ABOUT GOPHER TELNET')>0 then iterate
             
            nf=nf+1
            fileurls.nf=fix_url(gothref,baseurl,rooturl)
            fileurls.nf.!img=0

            foo=pos('</A',tstuff,strt)
            if foo>0 then do
               att=clear_elements(substr(stuff,strt,(foo-strt)))
               fileurls.nf.!title='{'||att||'}'
            end
            leave
         end /* do */
       end

       when anctype=4 | anctype=6 then do   /* FRAME EMBED */
         do forever
            if anarg=''  then leave
            parse var anarg a1 anarg ; a1=strip(a1)
            if abbrev(translate(a1),'SRC=')=0 then iterate
            parse var a1 . '=' gothref . ; gothref=strip(strip(gothref),,'"')
            if left(gothref,2)='//' then gothref='http://'gothref

            parse var gothref gothref '#' .     /* toss out internal jumps */
            if gothref="" then iterate

            nf=nf+1

            fileurls.nf=fix_url(gothref,baseurl,rooturl)
            fileurls.nf.!img=0
            leave
         end /* do */
       end

       when anctype=8 then do   /* APPLET */
         abase=''; aref=''
         do forever
            if anarg=''  then leave
            parse var anarg a1 anarg ; a1=strip(a1)
            if abbrev(translate(a1),'CODE=') + ,
               abbrev(translate(a1),'CODEBASE=')=0 then iterate
                
            if abbrev(translate(a1),'CODEBASE=')=1 then do
                    parse var a1 '"' abase '"' .
             end /* do */
             else do                  /* CODE */
                   parse var a1 '"' aref '"'
             end /* do */
             if aref<>'' & abase<>'' then leave

          end
          if aref='' then iterate       /* no CODE= found */
          if left(abase,2)='//' then abase='http:'abase
           

          if abase<>'' then
              tmp1=abase||strip(aref,'l','/')
          else
            tmp1=fix_url(aref,baseurl,rooturl)

          nf=nf+1
          fileurls.nf=tmp1
          fileurls.nf.!img=0

       end

       when anctype=9 then do   /* OBJECT */
         do forever
            if anarg=''  then leave
            parse var anarg a1 anarg ; a1=strip(a1)
            if abbrev(translate(a1),'CODEBASE=')=0 then iterate
            parse var a1 . '=' gothref . ; gothref=strip(strip(gothref),,'"')

            if left(gothref,2)='//' then gothref='http:'gothref

            parse var gothref gothref '#' .     /* toss out internal jumps */
            if gothref="" then iterate

            nf=nf+1

            fileurls.nf=fix_url(gothref,baseurl,rooturl)
            fileurls.nf.!img=0
            leave
         end /* do */
       end

        
       otherwise nop
   end                  /* select */
   goo=time('e')
   if (goo-basegoo)> min(15,(0.75*liminact)) then do
        rc=multi_send('<br> .... found 'nf)
        if rc<0 then return 0
        basegoo=goo
   end /* do */
end             /* search tstuff */

end             /* anctype */

iurls=nf

if iurls=0 then return 0        /* no links */

/* remove duplicates */
screens.!noscreen=1
if screens.!verbose<>0 then do
   rc=multi_send('<br> .... removing duplicates (in this document) from ' iurls ' links ')
   if rc<0 then return 0
end
if screens.!standalone=1 then do
   call write_finding 'removing duplicates from ' iurls ' links '
   call syssleep 0.2
end

okays=make_isdup(iurls)

if okays=0 then return 0

/* isdup=1 means "this is a duplicate of prior entry in this document" 
   use this, and list of prior hrefs and imgs, to remove duplicates */

iurls1=0 ; nimgs=imgs.0 ; nhrefs=hrefs.0
if screens.!verbose<>0 then do
   fop='<br> .... check 'okays' links against (' nimgs ' &amp; ' nhrefs ') prior links '
   rc=multi_send(fop)
end
if screens.!standalone=1 then
  call write_finding 'check 'okays' links against (' nimgs ' & ' nhrefs ') prior links '

oo=time('e')

/* if prior exists, don't add new entry, but do augment "!nrefs" field */
do mm=1 to iurls
   if isdup.mm=1 then iterate   /* this is duplicated in this document, so ignore it */

   if fileurls.mm.!img=1 then do               /* check image list */
     arf=strip(translate(fileurls.mm))
     if length(arf)>40  then arf=left(arf,10)||stringcrc(arf)
     if datatype(imgs.!list.arf)='NUM' then do    /* match, so don't add */
        nn=imgs.!list.arf
        imgs.nn.!nrefs=imgs.nn.!nrefs+1
        imgs.nn.!appearin=imgs.nn.!appearin' 'the_anind
        hrefs.the_anind.!imglist=hrefs.the_anind.!imglist' 'nn
        iterate               
     end /* do */
     nimgs=nimgs+1                /* no match, so add */
     imgs.nimgs=fileurls.mm
     imgs.!list.arf=nimgs
     hrefs.the_anind.!imglist=hrefs.the_anind.!imglist' 'nimgs

   end
   else do                      /* check hrefs list */
      arf=strip(translate(fileurls.mm))
      if length(arf)>40  then arf=left(arf,10)||stringcrc(arf)
      if datatype(hrefs.!list.arf)='NUM' then do    /* match, so don't add */
          nn=hrefs.!list.arf
          hrefs.nn.!nrefs=hrefs.nn.!nrefs+1    /* # of times this is referenced */
          if nn<>the_anind then hrefs.nn.!appearin=hrefs.nn.!appearin' 'the_anind        /* this appears in the_anind's */
          if nn<>the_anind then hrefs.the_anind.!reflist=hrefs.the_anind.!reflist' 'nn
          iterate               
      end 
      nhrefs=nhrefs+1                /* no match, so add */
      hrefs.nhrefs=fileurls.mm
      hrefs.!list.arf=nhrefs
      hrefs.the_anind.!reflist=hrefs.the_anind.!reflist' 'nhrefs
      hrefs.nhrefs.!title=fileurls.mm.!title
   end 
end             /* mm */

oo2=time('e')
imgs.0=nimgs ; hrefs.0=nhrefs
return okays

/* end of FINDURLS .. anind hrefs. */


/*****************/
/* extract descripiton from <head> */
fig_descript:procedure expose dscmax make_descrip stuff  screens.
parse arg a1

s2=stuff

dowrite=1
do until s2=""

    parse var s2  p1 '<' tag '>' s2

/* is it a  META HTTP-EQUIV or a META NAME ? */
    if translate(word(tag,1))="/HEAD" then leave

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
                url_content=LEFT(AVAL2,dscmax)
                return url_content
           end
        end             /* name or http-equiv */
    end         /* meta */
end             /* stuff */

/* look for <h1 and <h2 headers? */
if make_descrip<>3 then  return ''
if s2=''  then s2=stuff  /* no /head */
bb=look_Htag(s2)
return bb


/* ----------------------------------------------------------------------- */
/* Extract <hn> fields     */
/* ----------------------------------------------------------------------- */

look_htag: procedure expose dscmax  screens.
parse arg stuff

amessage=""
dowrite=0
do until stuff=""
    parse var stuff  p1 '<' tag '>' stuff
    ttag=translate(word(tag,1))
    if wordpos(ttag,' H1 H2 H3 H4 TITLE')>0 THEN DO   /* grab stuff */
        parse var stuff  amess '<' tag2 '>' stuff
        amessage=amessage||amess||'<b> | </b>'
        if length(amessage)>dscmax then leave
    end
end

if amessage="" then do  /* getting desperate -- grab any old words! */
   stuff0=left(stuff,1000)
   do until stuff0=""
      parse var stuff0 p1 '<' tag '>' stuff0
      amessage=amessage||' '||p1
      if length(amessage)>dscmax then leave
   end
end

return amessage






/************************/
/* make the isdup "duplicates" array */
make_isdup:procedure expose isdup. fileurls. verbose  screens.
parse arg iurls 

oo=time('e')
drop tmps.
okays=0
do mm=1 to iurls
   a1=space(translate(fileurls.mm.!img||'_'fileurls.mm),0)
   if length(a1)>40 then a1=left(a1,10)||stringcrc(a1)
   if tmps.a1=1 then do
      isdup.mm=1
   end
   else do
      isdup.mm=0
      tmps.a1=1
      okays=okays+1
   end
end
oo2=time('e')
return okays


/****************************/
/* add baseurl if needed */
fix_url:procedure
parse arg aref,baseurl,rooturl
taref=translate(aref)
if abbrev(taref,'HTTP://')+abbrev(taref,'HTTPS://')>0 then return aref
if abbrev(taref,'FILE:///')=1 then return aref
if abbrev(aref,'/')=0  then 
    aref1=baseurl||aref
else
    aref1=rooturl||strip(aref,'l','/')
return aref1


/********************************/
/* set base and root */
set_base_root:

if server=0 then do             /* it's "FILE" at the root */
   base=filespec('d',request)||filespec('p',request)
   base='FILE:///'||strip(base,,'\')||'\'
   rooturl=base
   baseurl=base
   intro3=' <br>&nbsp;&nbsp;&nbsp;&nbsp; <em>base-url </em> &nbsp; = ' base||'0d0a'x|| '  <em> (w/root= ' rooturl ')</em>'
   return 1
end

server=strip(server,,'/')   
ii=lastpos('/',request)
  if ii=0 then 
     base='http://'server'/'
  else
     base='http://'server'/'strip(delstr(request,ii+1),'l','/')
  base2=base_element(body)
  if base2<>'' then base=base2
  baseurl=base
  parse var base . '//' rooturl '/' .
  rooturl='http://'rooturl'/'
  intro3=' <br>&nbsp;&nbsp;&nbsp;&nbsp; <em>base-url </em> &nbsp; = ' base||'0d0a'x|| ' <em> (w/root= ' rooturl ')</em>'
return 1

/***************/
/* return 0 for no, 1 for yes, default otherwise */
is_yes_no:procedure
parse arg aval,def
tdef=strip(translate(aval))
if wordpos(tdef,'Y YES 1')>0 then return 1
if wordpos(tdef,'N NO 0')>0 then return 0
return def

/***************/
/* check selector for match to one of the exclusion lists */
exclude_me:procedure
parse upper arg asel,alist1,alist2,ahref,aroot

alist=alist1
if abbrev(translate(ahref),aroot)=1 & alist2<>'' then  
   alist=alist2

do mm=1 to words(alist)
   a1=strip(word(alist,mm)) 
   oo=wild_match(asel,a1)
   if oo<>0 then return 1
end
return 0



/**********************/
/* send to client, or to screen */
multi_send:procedure expose  verbose doing_results  screens.
parse arg a1,a2,a3,a4,a5,a6,a7
ss=screens.!standalone
ofile=screens.!outfilex 
ofile=strip(ofile) ; ss=strip(ss)

parse var doing_results doo1 doo2
if ss=0 then do
   doo2=strip(doo2)
   if doo1=2 then do
       call lineout doo2,a1
       return 1
   end
   else do
     if a2='' & a3='' & a4='' then
        rc=sref_multi_send(a1)
     else
        rc=sref_multi_send(a1,a2,a3,a4,a5,a6,a7)
     return rc
   end
end /* do */

/* if here, standalone mode... */
    call lineout ofile,a1          /* standalone output file*/

/* if verbose>0, write to screen.. but remove <elements> */
if screens.!noscreen=2 & screens.!standalone=1 then do
  aa=''
  a1=translate(a1,' ','0d0a09'x)
  a1=replacestrg(a1,'&nbsp;','','ALL')
  a1=replacestrg(a1,'&amp;','&','ALL')
 do until a1=''
   parse var a1 t1 '<' t2 '>' a1
   aa=aa||t1
 end /* do */
 call write_note aa
 return 1
end

if screens.!standalone=0 then return 1  /* not running from command prompt */
if  doo=1 |  screens.!noscreen=1 then return  1 /* suppress output */

aa=''
a1=translate(a1,' ','0d0a09'x)
aesc='1B'x
cy_ye=aesc||'[37;46;m'
normal=aesc||'[0;m'
bold=aesc||'[1;m'

do forever
    if a1='' then leave
    parse var a1 t1 '<' t2 '>' a1
    aa=aa||t1
    tt2=word(translate(strip(t2)),1)
    if wordpos(tt2,'H2 H3 H4 H5')>0  then aa=aa||'0d0a'x||cy_ye
    if wordpos(tt2,'/H1 /H2 /H3 /H4 /H5')>0  then aa=aa||normal||'0d0a'x
    if tt2='/B' then aa=aa||normal
    if  tt2='H1' then aa=aa||'0d0a'x||cy_ye||bold
    if  tt2='B' then aa=aa||bold

    if tt2='LI' then aa=aa||'0d0a'x||' * '
    if tt2='/UL' | tt2='/OL' | tt2='P' | tt2='BR' then aa=aa||'0d0a'x
    if abbrev(strip(translate(t2)),'A')=1 then aa=aa' >> '
end
aa=replacestrg(aa,'&nbsp;','','ALL')
aa=replacestrg(aa,'&amp;','&','ALL')

say aa

return 1

/*********************/
/* standalone mode 
defaults are in         
  starter_url:a url
  treename: descriptive name
  user_pwd: username password
  cheklink_htm: a selector (used with cheklnk2 )
  baseonly: 0 1 (no yes)
  siteonly:0 1
  queryonly: 0 1
  ascgi: 0 1
  make_descrip: 0 1 2  (no, html, text + html )
  exclusion_list: space delimited list
  outtype: list of OK NOSITE NOURL OFFSITE EXCLUDED (or ALL)
  default_outputfile: html filename
  standalone_verbose:1 2 3 4 (quite, normal, verbose, very verbose)
  linkfile: link file name, or 0 to suppress
*/


ask_opts:
parse arg iterx
SIGNAL OFF  ERROR ; SIGNAL OFF SYNTAX
SIGNAL ON ERROR NAME ASKV 
SIGNAL ON SYNTAX NAME ASKV 

ansion=checkansi()
if ansion=1 then do
  aesc='1B'x
  cy_ye=aesc||'[37;46;m'
  normal=aesc||'[0;m'
  bold=aesc||'[1;m'
  re_wh=aesc||'[31;47;m'
  reverse=aesc||'[7;m'
end
else do
  if iterx=1 then say " Warning: Could not detect ANSI....  output will look ugly ! "
  cy_ye="" ; normal="" ; bold="" ;re_wh="" ;
  reverse=""
end  
screens.!reverse= reverse ; screens.!Normal=normal ; screens.!bold=bold
screens.!cy_ye=cy_ye

cls
say  " " ; say

if iterx=1 then do
call lineout, bold cy_ye
call lineout, "CheckLink ver 1.13b: check & verify HTML links -- stand alone mode "
call lineout, normal
say " Although designed primarily as an SRE-http addon, you can use CheckLink "
say " in a stand-alone mode."
say
say "   "||cy_ye||"CheckLink's standalone-mode's final results are written to a "normal|| ,
           cy_ye||"HTML file."normal
call lineout, normal
say "  "
use_infile=0
use_infile2=0

do forever
  ii=yesno(" Are you ready to continue ",'No Yes Read_Documentation Load_Options','Y')
  if ii==0 then do
    say " See you later... "
    call doexit
  end

  if ii=3 then do 
    call get_infile
    iterate
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

/* parse a parameter file? */
if instuff<>'' then do
   use_infile=1
   cmdlist='STARTER_URL TREENAME USER_PWD INCLUDE_CHEKLNK2 BASEONLY SITEONLY QUERYONLY MAKE_DESCRIP '||,
        'EXCLUSION_LIST OUTTYPE DEFAULT_OUTPUTFILE STANDALONE_VERBOSE LINKFILE ASCGI'

/* add "user configurable parameters" */
   cmdlist=cmdlist||' GET_QUERY DOUBLE_CHECK HTML_TYPES TEXT_TYPES CHECK_ROBOT MAXAGE MAXAGE2 '||,
                    'MAXATONCE MAXATONCE_GET REMOVE_SCRIPT PROXY_SERVER CHEKLINK_HTM MAX_TABLE_ROWS '

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
end

end             /* iterx=1 */


say
getstarter: nop
if use_infile=0 then do
do forever
  say  "Enter a fully specified "bold "starter-URL " normal" (? for help):"
  call charout, bold "     ? "normal
  parse pull aurl
  taurl=strip(translate(aurl))

  if abbrev(taurl,'FILE:///')=1 then do      /* decode it & check */
     aurl=decodekeyval(translate(aurl,' ','+'))
     taurl=strip(translate(aurl))
     parse var aurl  . '///' afile .
     afile=translate(afile,'\','/')
     afile=translate(afile,':','|')
     afile2=stream(afile,'c','query exists')
     if afile2='' then do
        say "   "bold"No such file: "normal||afile
        iterate
     end 
     aurl='file:///'||afile2
  end
  
  if aurl='?' then do
     say
     say "The "bold" starter-URL " normal" is the base of the web tree."
     say "It will be retrieved and (depending on what other options you chose)"
     say "the URLS it contains links to will also be retrieved"
     say
     say "You should enter a complete URL (including the http://). "
     say "Alternatively, you can enter "reverse"file:///x:\dir1\..\file.ext"normal","
     say "which means 'start with the file (on this machine) named x:\dir1\...\file.ext' "
     say
     say "Note: to list a directory, enter "bold"?DIR dirname "normal
     say "       For example: "bold"?DIR f:\mywww"normal
     say "       Netscape will then be used to list the contents of   "bold"dirname"normal
     say "       You can then RMB-click on a desired file, select the 'copy the link "
     say "       location' option, and paste it here (CheckLink will clean up the ///,"
     say "       %7C, and other oddities)"
     iterate
  end 
  if abbrev(taurl,'?DIR')=1 then do
     parse var aurl . adir0 .
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
     say"       (it might take a few seconds)"
     iterate
  end
  aurl=strip(aurl)
  if aurl='' then do
     aurl=starter_url
     say " ... Using: "aurl
  end
  starter_url=aurl
  leave
end             /* forever */
end
else do
  aurl=starter_url
end


taurl=translate(strip(aurl))
if abbrev(taurl,'HTTP://')<>1 & abbrev(taurl,'FILE:///')<>1 then aurl='http://'||aurl

if use_infile=0 then do
  call charout,bold' Web-tree name (used for descriptive purposes):'normal
  parse pull atreename
  if atreename='' then atreename=treename
  treename=atreename
end


isauth=''
tt=user_pwd
if tt='' then tt='none'
if use_infile=0 then do
  call charout, " Space seperated"||bold "USERNAME PASSWORD "||normal||"(ENTER="tt"):"
  parse pull aupwd
end
if aupwd='' | use_infile=1 then aupwd=user_pwd
upwd=aupwd
user_pwd=aupwd
if upwd<>' ' then do
    upwd=space(strip(upwd))
    upwd=mk_base64(translate(upwd,':',' '))
   isauth='Authorization: Basic '||upwd
end


if use_infile=0 then do
do forever
  abaseonly=yesno("  |Only read documents in or under this starter-URL ",'No Yes Help',baseonly)
  if abaseonly=2 then do
      call help_baseonly
      iterate
  end
  baseonly=abaseonly
  leave
end
end


if use_infile=0 then do
if baseonly=1 then do
 do forever
   aqueryonly=yesno('  ...|'||"only look at starter-URL (query links, but do NOT recurse)",'No Yes Help',queryonly)
   if aqueryonly=2 then do
      call help_queryonly
      iterate
  end 
  queryonly=aqueryonly
  leave
 end
end
end

if use_infile=0 then do
do forever
  asiteonly=yesno('  |Only query resources on this site (N=do not)','No Yes Help',siteonly)
  if asiteonly=2 then do
     call help_siteonly
     iterate
  end /* do */
  siteonly=asiteonly
  leave
end 
end

if use_infile=0 then do
do forever
 maked=yesno('  |Generate descriptions','No Html_only PlainText&Html ?elp',make_descrip-1)
 if maked=3 then do
    call help_gen
    iterate
 end 
 make_descrip=maked+1
 leave
end
end

if use_infile=0 then do
say "  Exclusion list (ENTER="bold||exclusion_list||normal'): '
call  charout,'    ' reverse'   : 'normal
parse pull aexclus
if aexclus='' then aexclus=exclusion_list
exclusion_list=aexclus
end

if use_infile=0 then do
do forever
  call charout,'  Select output tables (?=Help,ENTER='bold||OUTTYPE||normal'): ' 
  pull aouttype
  if aouttype='' then aouttype=outtype
  outtype=aouttype
  if outtype='?' then do
      say cy_ye" Valid codes for output tables"normal' (you can use them in any combination): 'normal
say '        'bold'OK'normal' ) Display succesfully found links'
say '    'bold'NOSITE'normal' ) Display links to unreachable sites'
say '     'bold'NOURL'normal' ) Display links to missing resources'
say '   'bold'OFFSITE'normal' ) Display links to off-site URLs'
say '  'bold'EXCLUDED'normal' ) Display links to excluded URLs (specified in the EXCLUSION_LIST)'
say '       'bold'ALL'normal' ) Display all links'
      iterate
  end 
  leave
end
end

myqueue='CHEKLINK_STD1'
foo=rxqueue('C',myqueue)
if foo<>myqueue then aa=rxqueue('d',foo)
servername=get_hostname()

use_infile1=0
do forever
  if use_infile=0 | use_infile1=1 then do
     call charout,'  ' reverse'Output file (?=help):'normal' '
     pull outfileX
     use_infile2=1
  end 
  if strip(outfilex)='?' then do
      say "  The output file will be an HTML document containing the tables of results."
      say "  Leave this blank to use: "default_outputfile
      iterate
  end
  if outfilex='' | (use_infile=1 & use_infile1=0) then do
     outfilex=Default_outputfile
     if use_infile=0 & use_infile1=0 then say "   .... using: "outfilex
  end
  if pos('.',outfilex)=0 then outfilex=outfilex'.htm'
  if stream(outfileX,'c','query exists')<>' ' then do
        if use_infile=1 & use_infile1=0 then say " OutputFile= " outfilex
         goo=yesno('    |File exists. Overwrite? ',,'Y')
         if goo=1 then do
            goo=sysfiledelete(outfilex)
            leave
         end
         use_infile1=1
         iterate
  end  
  oo=stream(outfileX,'c','open write')
  if abbrev(translate(oo),'READY')=1 then leave
  say "Can't open file, try a different name"
  use_infile1=1
end
default_outputfile=outfilex

if use_infile=0 then do
  say
  standalone_verbose=yesno('  |Verbosity of intermediate output: ','Quiet Normal Verbose TooVerbose ',standalone_verbose-1)+1
end
verbose=standalone_verbose

use_infile1=0
say
linkfile0=linkfile
 do forever
  if use_infile=0 | use_infile1=1 then do
     call charout,'  'reverse'Links file (?=help, 0=suppress):'normal' '
     pull alinkfile
     use_infile2=1
  end
   if alinkfile='' | (use_infile=1 & use_infile1=0) then alinkfile=linkfile
   linkfile=alinkfile
   if linkfile='?' then do
      call help_links
      linkfile=linkfile0
      iterate
   end 
   if linkfile=0 then leave
   if linkfile='' then parse value filespec('n',outfilex) with linkfile '.' .
   if pos(':',linkfile)+pos('\',linkfile)=0 then 
        outfilel=linkfile_dir||linkfile
   else
        outfilel=linkfile
   if pos('.',outfilel)=0 then outfilel=outfilel'.STM'
   if stream(outfilel,'c','query exists')<>' ' then do
         if use_infile=1 & use_infile1=0 then say " LinkFile= " outfilel
         goo=yesno('    |LinkFile exists. Overwrite? ',,'Y')
         if goo=0 then  do
            use_infile1=1
            iterate
         end
         goo=sysfiledelete(outfilel)
   end  
   oo=stream(outfilel,'c','open write')

   if abbrev(translate(oo),'READY')=0 then do
      say "Can't open " outfilel ", try a different name"
      use_infile1=1
      iterate
   end

   if use_infile=0 then do
         say "  using: " outfilel
         oo=stream(outfilel,'c','close')
   end
   leave
end
use_infile1=0

if linkfile<>0 & use_infile=0 then do
  do forever
       aas=yesno("  |Include CHEKLNK2 (web traversal) links ",'No Yes Help',include_cheklnk2)
      if aas=2 then do
              call help_ch2
              iterate
       end 
       include_cheklnk2=aas
       leave
  end


  if include_cheklnk2=1 then do
      do forever
           aascgi=yesno(" ...|Use CGI-BIN to specify CHEKLNK2 (web traversal) links ",'No Yes Help',ascgi)
           if aascgi=2 then do
              call help_ascgi
              iterate
           end 
           ascgi=aascgi
           leave
       end 
  end



end

vtreename=translate(treename,'+',' ')
outtype2=translate(outtype,'+',' ')
list='url='aurl'&baseonly='baseonly'&siteonly='siteonly'&exclus='exclusion_list'&outtype='outtype2|| ,
             '&queryonly='queryonly'&linkfile='linkfile'&treename='vtreename'&make_descrip='maked

transaction=(10*dospid())+dostid()

screens.!outfilex=outfilex
screens.!outfilel=outfilel

screens.!standalone=1

return list



 /* ------------------------------------------------------------------ */
 /* function: Check if ANSI is activated                               */
 /*                                                                    */
 /* call:     CheckAnsi                                                */
 /*                                                                    */
 /* where:    -                                                        */
 /*                                                                    */
 /* returns:  1 - ANSI support detected                                */
 /*           0 - no ANSI support available                            */
 /*          -1 - error detecting ansi                                 */
 /*                                                                    */
 /* note:     Tested with the German and the US version of OS/2 3.0    */
 /*                                                                    */
 /*                                                                    */
 CheckAnsi: PROCEDURE
   thisRC = -1

   trace off
                         /* install a local error handler              */
   SIGNAL ON ERROR Name InitAnsiEnd

   "@ANSI 2>NUL | rxqueue 2>NUL"

   thisRC = 0

   do while queued() <> 0
     queueLine = lineIN( "QUEUE:" )
     if pos( " on.", queueLine ) <> 0 | ,                       /* USA */
        pos( " (ON).", queueLine ) <> 0 then                    /* GER */
       thisRC = 1
   end /* do while queued() <> 0 */

 InitAnsiEnd:
 signal off error
 RETURN thisRC


/* get the hostname (aa.bb.cc) for this machine */
get_hostname: procedure

    do queued(); pull .; end                   /* flush */
    address cmd '@hostname | rxqueue'

    parse pull hostname
    return hostname



/*********/
packur2:procedure  expose screens.
parse arg a1b0

if screens.!standalone=0 then
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
/* extract */
extract2:procedure expose screens.
parse upper arg aa
if  screens.!standalone=0 then do
   foo=extract(aa)
   return foo
end

select
   when aa='TRANSACTION' then return (10*dospid())+dostid()
   when aa='LIMITTIMEINACTIVE' then return 20
   otherwise return 0
end



/************************/
/* wild card match, with comparision against prior wild card match */
/* needle : what to look for 
   haytack : what to compare it to. Haystack may contain numerous * wildcard 
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
 



/************/
/* create a base64 packing of a message */
mk_base64:procedure

do mm=0 to 25           /* set base 64 encoding keys */
   a.mm=d2c(65+mm)
end /* do */
do mm=26 to 51
   a.mm=d2c(97+mm-26)
end /* do */
do mm=52 to 61
   a.mm=d2c(48+mm-52)
end /* do */
a.62='+'
a.63='/'

parse arg mess
s2=x2b(c2x(mess))
ith=0
do forever
   ith=ith+1
   a1=substr(s2,1,6,0)
   ms.ith=x2d(b2x(a1))
   if length(s2)<7 then leave
   s2=substr(s2,7)
end /* do */
pint=""
do kk=1 to ith
    oi=ms.kk ; pint=pint||a.oi
end /* do */
j1=length(pint)//4
if j1<>0 then pint=pint||copies('=',4-j1)
return pint


/************/
/* remove html elements from a "title" */
clear_elements:procedure
parse arg amess
a=''
do until amess=''
   parse var amess a1 '<' . '>' amess
   a=a||a1
end
return a

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


/*=============================================*/
/*=============================================*/


/* ----------------------------------------------------------------------- */
/* MEDIATYPE: Return the media type of a file, based on its extension.     */
/* ----------------------------------------------------------------------- */
mediatype:procedure expose text_types html_types
parse arg aa

  /* First get the extension; this assumes filenames have at least one '.' */
  ij=lastpos('.',aa)
  if ij=0 then do
      aext=''
   end
   else do
      aext=translate(substr(aa, ij+1))
   end
 
/* check user configurable  text_types and html_types */
  if wordpos('.'||aext,text_types)>0 then return 'text/plain'
  if wordpos('.'||aext,html_types)>0 then return 'text/html'


/* else, use defaults */
  
  /* Set up the table of all types that we are interested in */
  known.   ='application/octet-stream'  /* default type */
  known.ps ='application/postscript'
  known.pdf='application/pdf'
  known.zip='application/zip'
  known.au ='audio/basic'
  known.snd='audio/basic'
  known.wav='audio/x-wav'
  known.mid='audio/x-midi'
  known.gif='image/gif'
  known.bmp='image/bmp'
  known.png='image/png'
  known.jpg='image/jpeg';  known.jpeg='image/jpeg'
  known.tif='image/tiff';  known.tiff='image/tiff'
  known.htm='text/html' ;  known.html='text/html'
  known.sht='text/html' ;  known.shtml='text/html'
  tmp1='HTML-SSI'           
  known.tmp1='text/html'   
  
  known.txt='text/plain'
  known.lst='text/plain'
  known.me='text/plain'
  known.log='text/plain'
/*  known.doc='text/plain' */
  known.in='text/plain'
  known.faq='text/plain'
  known.mpg='video/mpeg';  known.mpeg='video/mpeg'
  known.mov='video/quicktime'
  known.avi='video/x-msvideo'
  known.js='appplication/x-javascript'

  return known.aext

/************* Various help snippets ****/
help_baseonly:
say
say bold'Help for:'normal" Only read documents in or under this starter-URL " 
say
say '    NO: Read & process URLS relative to the 'bold'root'normal' of the starter-URL '
say '   YES: Only read & process URLS relative to this starter-URL '
say ' '
say ' Example: if the 'bold'starter-url'normal' is: http://foo.bar.net/DOGS/foo.htm; then'
say '       NO: URLS in http://foo.bar.net/CATS/bar.htm 'bold'would'normal' be "recursively" '
say '           read (its links will be read and processed)'
say '      YES: URLS in http://foo.bar.net/CATS/bar.htm would'bold' NOT'normal' be "recursively"'
say '           read (its links will NOT be read and processed)'
say 
say ' Notes:'
say "  * The "bold"root"normal" is typically defined as the starter-url's server."
say "    In the above example, the root would be http://foo.bar.net/ "
say "       However, if the starter-url contains a <BASE > element, "
say "       its value will be used."
say '  * the 'bold'base'normal' is everything in the same "directory" as the starter-url'
return

help_siteonly:
say
say bold'Help for:'normal" Only query resources on this site " 
say
say '    NO: Query all URLS (even those on other sites)'
say '   YES: Query only URLS on this site  '
say 
return

help_queryonly:
say
say bold'Help for:'normal"  only look at starter-URL " 
say
say '   YES: Query, but do not retrieve, URLS contained in the starter-URL'
say '    NO: Retrieve & process URLS contained in the starter-URL'

return

help_gen:
say
say bold'Help for:'normal"   Generate descriptions " 
say

say ' Create & save descriptions for "on-site" documnents.'
say '              NO: do not create descriptions'
say '        HTML_only: create descriptions for text/html documents'
say '  PlainText&HTML: create descriptions for text/html and text/plain '
say '                       documents'
say ' '
say '  HTML_only is fairly costless (it uses information that''s already' 
say '  been read).  PlainText&HTML requires reading additional files.'
return

help_links:
say
say bold'Help for:'normal"   Links file " 
say

 say 'The "links" file stores information on what links appear in the HTML'
 say 'documents, and what HTML documents each resource "appears in"'
 say 'It is used by the CHEKLNK2 SRE-http addon. '
 say ' '
 say 'Notes:'
 say '  * if you don''t want to create a links file, enter 0 '
 ali=linkfile0
 if ali=''  & ali<>0 then do
    parse value filespec('n',outfilex) with ali '.' .
 end
 if ali<>0 then do 
   if pos('.',ali)=0 then   ali=ali||'.STM'
 end /* do */
 if ali=0 then
    say '  * the default is to NOT create a links file'
 else
    say '  * the default is to create 'ali
 say "  * the links file will be stored in: " linkfile_dir 

say
return

help_ascgi:
say
say bold'Help for:'normal"   Use CGI-BIN to specify CHEKLNK2 " 
say
say "  NO: CHEKLNK2 will be called as an SRE-http addon "
say " YES: CHEKLNK2 will be called as a CGI-BIN script "
say 
say 'This effects how links to CHEKLNK2 are written to the HTML output file (i.e.;'
say ' as /CHEKLNK2?xxx or as /CGI-BIN/CHEKLNK2.CMD?xxx )'
say
return


help_ch2:
say
say bold'Help for:'normal" Include CHEKLNK2 (web traversal) links"
say
say "  NO: Links to CHEKLNK2 will NOT be included  "
say " YES: Links to CHEKLNK2 will  be included  "
say 
say 'CHEKLNK2 is a script (runnable as either an SRE-http addon or as a CGI-BIN)'
say 'that will "traverse the web tree" -- for each resource, it shows all its  '
say 'links, and all HTML resources that contain links pointing to it.'
say
return


help_infile:
say
say bold'Help for:'normal" Using a parameters file " 
say
say "You can read the values of the various CheckLink parameters from a file."
say "Typically, you'll use a parameters file you saved from a prior run of "
say "CheckLink (ambitious users can create their own parameter files with any"
say "text editor)."
say
say "Notes: "
say " * you'll have a chance to change (and resave) these parameter values, "
say " * the default input file is CHEKLINK.IN "
say " * See CHEKLINK.SMP for a complete & well documented example "
say
return 1

/***************/
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

replacestrg:procedure

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


/***************/
/* initialize the screen */
start_screen:
parse arg sayactive

call charout, aesc||'[2J'             /* clear screen */
call charout, '1b5b'x||'1;1H'||aesc||'['border_fore';'border_back';m'||ulc||copies(hchar,78)||urc||normal

topmess=left(topmess,20,' ')||'[ started at '||time('n')||' '||date('n')
call charout, '1b5b'x||'1;23H'||cy_ye||topmess||normal

call charout, '1b5b'x||'2;2H'||reverse||'StartUrl: 'normal||cy_ye||left(starter_url,70,' ')||normal

call charout, '1b5b'x||'3;2H'||reverse||'Getting contents of 'normal

call charout, '1b5b'x||'6;2H'||reverse||'Parsing 'normal

call charout, '1b5b'x||'8;2H'||reverse||'Querying existence of 'normal

call charout, '1b5b'x||'15;2H'||reverse||'Status ... 'normal

call charout, '1b5b'x||'23;1H'||aesc||'['border_fore';'border_back';m'||llc||copies(hchar,78)||lrc||normal

call charout, '1b5b'x||'23;4H'||cy_ye||"Esc = Abort "||normal

call charout, '1b5b'x||'23;34H'||cy_ye||"S = SkipCurrent "||normal

call charout, '1b5b'x||'23;54H'||cy_ye||"E = End "||normal


do mm=2 to 22
  call charout, '1b5b'x||MM||';1H'||aesc||'['border_fore';'border_back';m'||vchar||normal
  call charout, '1b5b'x||MM||';80H'||aesc||'['border_Fore';'border_back';m'||vchar||normal
end

agold=aesc||'['vert_fore';m'
agreen=aesc||'['vert_back';m' 

agreen=aesc||'['42';m' 

call charout, '1b5b'x||'24;1H : '

SCREENS.!MESSAGES.!top=16
SCREENS.!MESSAGES.!bot=22
SCREENS.!MESSAGES.!NEXT=16
screens.!messsize=7

SCREENS.!GET.!top=4
SCREENS.!GET.!bot=5
SCREENS.!GET.!NEXT=4

SCREENS.!QUERY.!top=9
SCREENS.!QUERY.!bot=14
SCREENS.!QUERY.!NEXT=9

screens.!NOSCREEN=0

screens.!standalone=1
screens.!verbose=1
if verbose=1 then screens.!verbose=0

return 1

/**************/
write_note:
PARSE ARG AMESS 
amess=left(amess,78,' ')
screens.!messages.!next=screens.!messages.!next+1

aesc='1B'x
cy_ye=aesc||'[37;46;m'
normal=aesc||'[0;m'
call charout, '1b5b'x||'23;69H'||cy_ye||time('n')||normal

do jj= 1 to screens.!messsize-1 
     jj1=jj+1
     screens.!mess.jj=screens.!mess.jj1
end
jj=screens.!messsize
screens.!mess.jj=amess

do jj=1 to screens.!messsize
    oof=screens.!messages.!top-1+jj
    call charout, '1b5b'x||oof||';2H'||screens.!Mess.jj
end


/*look for keystroke, return list: 1=abort, 2=skip current, 3=endfor ESC (to abort) */
screens.!keylist=get_key(screens.!keylist)
if wordpos('1',screens.!keylist)>0 then call abort_job 'writing note' /* will exit */


return 1

/**************/
write_query:
PARSE ARG AMESS 
amess=left(amess,78,' ')
parse var amess zind ':' .
if abbrev(zind,'X')=1 then do           /* remove a message */
   parse var zind . 'X' zind 
   do kk2=screens.!query.!top to screens.!query.!bot
      if screens.!query.kk2.!id=zind then do
         amess=left(' ',78,' ')
         screens.!query.kk2.!id=' '
         call charout, '1b5b'x||kk2||';2H'||amess
         return 1
      end 
   end 
   return 0
end

/* else, write message */

kkl=random(screens.!query.!top,screens.!query.!bot)
do jh=screens.!query.!top to screens.!query.!bot
   if screens.!query.jh.!id=' ' then do
       kkl=jh
       leave
   end 
end 
call charout, '1b5b'x||kkl||';2H'||amess
screens.!query.kkl.!id=zind

return 1

/**************/
write_finding_header:
PARSE ARG AMESS

aesc='1B'x
normal=aesc||'[0;m'
bold=aesc||'[1;m'
cy_ye=aesc||'[37;46;m'
 
amess=left(amess,70,' ')
call charout, '1b5b'x||'6;10H'||bold||amess||normal

call charout, '1b5b'x||'23;69H'||cy_ye||time('n')||normal

return 1

/**************/
write_finding:
PARSE ARG AMESS 
amess=left(amess,75,' ')
call charout, '1b5b'x||'7;2H'||amess
return 1

/**************/
write_note_header:
PARSE ARG AMESS 

aesc='1B'x
cy_ye=aesc||'[37;46;m'
normal=aesc||'[0;m'

amess=left(amess,65,' ')
call charout, '1b5b'x||'15;13H'||cy_ye||amess||normal

call charout, '1b5b'x||'23;69H'||cy_ye||time('n')||normal

screens.!keylist=get_key(screens.!keylist)
if wordpos('1',screens.!keylist)>0 then call abort_job  'writing note'  /* will exit */

return 1


/**************/
write_query_header:
PARSE ARG AMESS 
aesc='1B'x
normal=aesc||'[0;m'
bold=aesc||'[1;m'
amess=left(amess,55,' ')
call charout, '1b5b'x||'8;24H'||bold||amess||normal
return 1


/**************/
write_get:
PARSE ARG AMESS 
parse var amess aaid ')' .
if abbrev(aaid,'X')=1 then do           /* zap a line? */
   parse var aaid . 'X' aaid .
   amess=left(' ',78,' ')
   do jjj=screens.!get.!top to screens.!get.!bot
       if screens.!get.jjj.!ID=aaid then do
         call charout, '1b5b'x||jjj||';2H'||amess
         return 1
       end /* do */
       return 0
   end /* do */
end /* do */

/* write new line */
amess=left(amess,78,' ')
kkl=screens.!get.!next
call charout, '1b5b'x||kkl||';2H'||amess
screens.!GET.kkl.!ID=aaid
screens.!GET.!next=screens.!GET.!next+1
if screens.!GET.!next>screens.!GET.!bot then screens.!GET.!next=screens.!GET.!top
return 1


/*****************/
write_get_contents:
PARSE ARG AMESS 
aesc='1B'x
normal=aesc||'[0;m'
bold=aesc||'[1;m'

amess=left(amess,55,' ')
call charout, '1b5b'x||'3;23H'||bold||amess||normal
return 1


/*****************/
write_bottom:
PARSE ARG AMESS 
amess=left(amess,80)
call charout, '1b5b'x||'24;2H'||amess
return 1



/***************************/
save_params:

cmdlist='STARTER_URL TREENAME USER_PWD CHEKLINK_HTM BASEONLY SITEONLY QUERYONLY MAKE_DESCRIP '||,
        'EXCLUSION_LIST OUTTYPE DEFAULT_OUTPUTFILE STANDALONE_VERBOSE LINKFILE ASCGI'

do forever
  call charout,'  ' reverse'Save parameters to (?=help):'normal' '
  pull nuinfile
  if strip(nuinfile)='?' then do
      say "  You can save the currently selected parameters to a file."
      say "  This file can be read with the Load_Parameters option"
      say "  The default name is CHEKLINK.IN "
      iterate
  end
  if nuinfile='' then nuinfile='CHEKLINK.IN'
  if stream(nuinfile,'c','query exists')<>' ' then do
         goo=yesno('    |File exists. Overwrite? ',,'Y')
         if goo=1 then do
            goo=sysfiledelete(nuinfile)
            leave
         end
         iterate
  end  
  oo=stream(nuinfile,'c','open write')
  if abbrev(translate(oo),'READY')=1 then leave
  say "Can't open file, try a different name"
end

call lineout nuinfile,'; CheckLink Parameters file created '||time('n')||'  '||date('n')
do mm=1 to words(cmdlist)
   avar=strip(word(cmdlist,mm))
  aval=value(avar)
   call lineout nuinfile,avar '=' aval
end 
call lineout nuinfile
say nuinfile " created. "
say
return 1


/***************************/
get_infile:

do forever

call lineout,bold " Enter parameters file (? for help, ?DIR for a directory, EXIT to quit) "normal
call charout,"  "reverse " :" normal
parse pull infile ; infile=strip(infile)

if strip(translate(infile))='EXIT' then do
   say "bye "
   call doexit
end

if abbrev(translate(infile),'?DIR')=1 then do
    parse var infile . thisdir
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
    infile=''
    iterate
end

if  strip(infile)='?' then do
   call help_infile
   infile=''
   iterate
end /* do */

if infile='' then infile='CHEKLINK.IN'

/* maybe it's actually a file name */

infile0=infile
if infile0='' then infile0='CHEKLINK.IN'
if pos('.',infile0)=0 then infile0=infile0||'.in'
infile1=stream(infile0,'c','query exists')              

if infile1='' then do
    Say "Sorry. could not find: " infile
    return 1
end /* do */

infilelen=stream(infile1,'c','query size')
if htmllen=0 then do
   say " Sorry -- " infile1 " is empty "
   stuff=''
   return 1
end /* do */
instuff=charin(infile1,1,infilelen)
Say "Reading " infilelen " characters from " filespec('n',infile1)
foo=stream(infile1,'c','close')
say 

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


/***************/
pmprintf2:procedure
parse arg amess
amess=decodekeyval(amess)
if length(amess)>120 then amess=left(amess,120)
call pmprintf(amess) 
return 1


/*******************/
/* return a code. Append to current list, as provided in keylist
  1=abort (ESC)
  2=Skip current (S)
  3=End     (E)
  4=Help    (F1 or H)
  5=other 
*/
get_key:procedure expose screens.
parse arg keylist
if screens.!nogetkey=1 then return ' '  /* no more keys accepted */


ba=inkey('n')
if ba='' then return keylist
xba=c2x(ba)
if xba='1B' then  return keylist' 1 '
if translate(ba)='S' then return  keylist' 2 '
if translate(ba)='E' then do
  call charout, '1b5b'x||'23;54H'||screens.!reverse||"E = End "||screens.!normal
  return  keylist' 3 '
end
if translate(ba)='H'| xba='003B' then return  keylist' 4 '
if ba<>'' then return   keylist' 5 '
return keylist



/**********/
/* abort! */
abort_job:
parse arg iii
screens.!nogetkey=1
call write_note_header 'Program terminated by user (at 'iii

call charout, '1b5b'x||'23;4H'||screens.!reverse||"Esc = Abort  "screens.!normal

/* call outdone */
call charout, '1b5b'x||'24;2H'||' '
exit


/*********/
/* timeout current transactions. Note that the semaphore changes, so that
   future transactions will not be effected */
kill_transactions:
parse  arg nonew
foo=eventsem_close(screens.!mysem)      /* kill all transactions current */
if nonew=1 then return 1

ii=screens.!madesem+1
screens.!mysem='\SEM32\CHECKLINK_'||dospid()||'_'||dostid()||'_'||ii
foo=eventsem_create(screens.!mysem,'P')
screens.!madesem=ii
call charout, '1b5b'x||'23;34H'||screens.!bold||"S = SkipCurrent "||screens.!normal
call syssleep 2
call charout, '1b5b'x||'23;34H'||screens.!cy_ye||"S = SkipCurrent "||screens.!normal

screens.!keylist=space(translate(screens.!keylist,' ','2'))

return 1



