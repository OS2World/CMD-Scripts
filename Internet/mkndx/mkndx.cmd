/* REXX ****************************************************************/
/*  This program produces a set of html pages from a netscape 4.xx     */
/*  bookmark file. Use the generated myindex.htm as the default        */
/*  browser homepage and you always have quick access to               */
/*  your bookmarks.                                                    */
/*                                                                     */
/*  (c) 1997-2002 by Jens M Schlatter, Jens.Schlatter@ePost.de         */
/*  Version 2.1                                                        */
/*                                                                     */
/***********************************************************************/
infile='bookmark.htm'
sub_page_no = 0
mainpage = 'myindex.htm'

'@del ndx*.htm'
'@del' mainpage

call stream infile,'C','OPEN READ'

call doFolder '',mainpage,'',''

call stream infile,'C','CLOSE'

exit

doFolder: procedure expose infile sub_page_no
parse arg parent,f,firstLine,title
say f title
call stream f,'C','OPEN WRITE'
call lineout f,'<html>'
call lineout f,'<head>'
if parent>'' then do
  call lineout f,'  <link rel="start" href="myindex.htm">'
  call lineout f,'  <link rel="parent" href="'||parent||'">'
end
if title>'' then call lineout f,'<title>'||title||'</title>'
call lineout f,'</head>'
call lineout f,'<body>'
fini=0


/* if parent>'' then call lineout f,'<font size="-2"><span style="background-color:yellow">&laquo;</span> <a href="'||parent||'">Up to higher level</a></font>' */
/*call lineout f,firstLine*/

do while (fini=0)
  line = strip(linein(infile),'B')
  uline = translate(line) /* uppercase */
  if uline='<DL><P>' then line='<dl>'   /* avoid extra space */

  if substr(uline,1,7)='<DT><H3' then do
      sub_page_no = sub_page_no + 1
      subfile = 'ndx'||sub_page_no||'.htm'
      pos1 = pos('>',line,7);
      pos2 = pos('</H3>',uline);
      subtitle = strip( substr(line,pos1+1,pos2-pos1-1) )
      subtitle2  = strip(subtitle,'B','-')
      call lineout f,'<dt><a href="'||subfile||'"><IMG ALIGN=absbottom BORDER=0 SRC="internal-gopher-menu"> '||subtitle2||'</a>'
      call doFolder f,subfile,line,subtitle
  end
  else call lineout f,line

  if substr(uline,1,5)='</DL>' then do
    fini=1
  end
end /* while */

call lineout f,'</html>'
call stream f,'C','CLOSE'
return

