/* ns2htm.cmd */
/* by Jerry L. Rowe Copyright 1997 */
/* jlrowe@iquest.net */
/* Thursday - 09/04/97 10:55pm */

/* reads the Netscape/2 Bookmark.htm file and generates an HTML page */
/* Suitable for cut and paste to your own web page */
/*  */
Call RxFuncAdd 'SysLoadFuncs','REXXUTIL','SysLoadFuncs';
Call SysLoadFuncs;

book = 'bookmark.htm'
html = 'ns2htm.htm'

html_top.0=12
html_top.1='<!DOCTYPE HTML PUBLIC "-//W3 Organization//DTD W3 HTML 2.0//EN">'
html_top.2='<html>'
html_top.3='<head>'
html_top.4='<title>Netscape Bookmark to HTML Conversion'
html_top.5='</title>'
html_top.6='</head>'
html_top.7='<body>'
html_top.8='<h1><center>'
html_top.9='Netscape Bookmark to HTML Conversion'
html_top.10='</center></h1>'
html_top.11='<hr>Generated: '||date('N') ||' -- ' || time('C')|| '<hr>' 
html_top.12='<UL>'

html_bot.0=4
html_bot.1='</UL>'
html_bot.2='<hr><ADDRESS>Program by: <A HREF="mailto:jlrowe@iquest.net"><I>Jerry L. Rowe</I></A></address><hr>'
html_bot.3='</body>'
html_bot.4='</html>'


/* Locate bookmark.htm file */

env = 'OS2ENVIRONMENT'
path = value('PATH',,env)

do until path=''
   parse upper var path nspath ';' path
   parse var nspath drive ':' dir
   say nspath
   if dir='\NETSCAPE' then leave
end /* do */


if nspath = '' then
do
  say 'Error: Could not find Netscape.'
  exit
end
bookfile = nspath || '\' || book
html_file = nspath || '\' || html

SAY 'bookfile='BOOKFILE
do forever
  dump = linein(bookfile);
  if strip(left(dump,4)) = "<DL>" then
    leave
end

part.1='<LI>'
part.2='>'
part.3='</A>'

cmd='@del ' || html_file
cmd
rc=lineout(html_file,,1)

do n=1 to html_top.0
   rc=lineout(html_file,html_top.n)
end /* do */

/* trace all */
cnt=1
do forever
  ns.title.cnt = ""
  ns_line = linein(bookfile);
/*   say ns_line */

  if strip(left(ns_line,5)) = "</DL>" then do
     cnt=cnt-1
     leave
  end /* do */

  if strip(left(strip(ns_line),4)) \= "<DT>" then do
      iterate
  end /* do */


  if strip(ns_line)\='' then do
  parse var ns_line '<DT>' ns.url.cnt 'ADD_' dump '>' ns.title.cnt
/*   say ns.url.cnt || d2c(13) || ns.title.cnt */
  cnt=cnt+1

  end

end /* do */


/* write unsorted list to file */

rc=lineout(html_file,'<A NAME="unsort"><h2>Unsorted Listing</h2>')
rc=lineout(html_file,'<A HREF="ns2htm.htm#unsort">[Unsorted]-</a><A HREF="ns2htm.htm#urlsort">[URL sorted]-</a><A HREF="ns2htm.htm#titlesort">[Title sorted]</a>')
rc=lineout(html_file,'<p>')

do nn=1 to cnt
  url_line=part.1||strip(ns.url.nn)||part.2||strip(ns.title.nn)
  say url_line
  rc=lineout(html_file,url_line)
end /* do */


rc=lineout(html_file,'<p>')
rc=lineout(html_file,'<A NAME="urlsort"><h2>Sorted by URL</h2>')
rc=lineout(html_file,'<A HREF="ns2htm.htm#unsort">[Unsorted]-</a><A HREF="ns2htm.htm#urlsort">[URL sorted]-</a><A HREF="ns2htm.htm#titlesort">[Title sorted]</a>')
rc=lineout(html_file,'<p>')


/* Sort by URL */
Do i = 1 to cnt
        var1.i=ns.url.i
        var2.i=ns.title.i
        End


Say
Say 'Sorting ...'
Call BubbleSort 
/* and display the sorted array */

Do i = 1 to cnt
        ns.url.i=var1.i
        ns.title.i=var2.i
        url_line=part.1||ns.url.i||part.2||ns.title.i
        say url_line
        rc=lineout(html_file,url_line)
        parse var ns.url.i '<A HREF="' tmp '"'
        url_line='<br>___'||tmp||''
        rc=lineout(html_file,url_line)
        End

rc=lineout(html_file,'<p>')
rc=lineout(html_file,'<A NAME="titlesort"><h2>Sorted by Title</h2>')
rc=lineout(html_file,'<A HREF="ns2htm.htm#unsort">[Unsorted]-</a><A HREF="ns2htm.htm#urlsort">[URL sorted]-</a><A HREF="ns2htm.htm#titlesort">[Title sorted]</a>')
rc=lineout(html_file,'<p>')


/* Sort by Title */

Do i = 1 to cnt
        var2.i=ns.url.i
        var1.i=ns.title.i
        End

Say
Say 'Sorting ...'
Call BubbleSort 

Do i = 1 to cnt
        ns.url.i=var2.i
        ns.title.i=var1.i
        url_line=part.1||ns.url.i||part.2||ns.title.i
        say url_line
        rc=lineout(html_file,url_line)
        End


rc=lineout(html_file,'<p>')
rc=lineout(html_file,'<A HREF="ns2htm.htm#unsort">[Unsorted]-</a><A HREF="ns2htm.htm#urlsort">[URL sorted]-</a><A HREF="ns2htm.htm#titlesort">[Title sorted]</a>')

do n=1 to html_bot.0
   rc=lineout(html_file,html_bot.n)
end /* do */

rc=lineout(html_file)
rc=lineout(bookfile)
say
say 'Wrote ' cnt ' URLs to ' html_file

return   /*    the program        */

do n=1 to html_bot.0
   rc=lineout(html_file,html_bot.n)
end /* do */

rc=lineout(html_file)
rc=lineout(we_inifile)

say
say 'Wrote ' cnt ' URLs to ' html_file

return   /*    the program        */

/* ==================================================================== */

/* ========================================== */
BubbleSort: procedure expose cnt var1. var2.

say cnt var1.1 var2.1
Do i = 1 to cnt
        Do j = i+1 to cnt
                IF var1.i > var1.j Then Call Swap i j var1. var2.
                
        End
end
Return

Swap: procedure expose i j var1. var2.

/* Say 'Swapping var1.'i '('var1.i') and var1.'j '('var1.j')' */
tmp = var1.i
tmp2= var2.i
var1.i = var1.j
var2.i=var2.j
var1.j = tmp
var2.j=tmp2
Return

