/*rexx*/

/*  WebExplorer_URL folder -> html converter       MAXsoft Lab. (C) 1996  */
/*  converts dragged and stored urls to single html file                  */

progName = 'urltree v0.30'

/* page settings */

uTitle  = 'Sample Title'
ico.LOGO= '<img src="globe.gif" align=bottom width=64 height=64 hspace=24>'
ico.GRP = '<img src="b0.gif"    width=15 height=15 hspace=4>'
ico.URL = '<img src="b1.gif"    width=14 height=14 hspace=4>'
ico.EOP = '<img src="eop.gif"   width=20 height=10 hspace=4>'

call rxFuncAdd 'sysLoadFuncs', 'REXXUTIL', 'sysLoadFuncs'; call sysLoadFuncs;

parse arg root html

ucnt = 0
rlen = length( root ) + 2

say progName

if root = '' then do; call usage; exit 1; end;

call sysFileDelete html

call lineout html, '<html><head><title>' uTitle '</title></head>'
call lineout html, '<body background=backg.gif>'
call lineout html, ico.LOGO'<font size=+4><b>' uTitle '</b></font><hr>'

call recurs 1 root

call lineout html, '<hr>'ico.EOP'</body></html>'

call lineout html, '<center><font size=-1>Generated <b>'date('E')'</b> by <b>' progName '-- </b>'
call lineout html, '<a href="http://www.irk.ru/~maxp"> MAXsoft Lab. </a> (C) 1996'
call lineout html, '</center><br>'

call stream html, 'C', 'CLOSE'

say ucnt 'urls processed.'

exit

/*end*/

recurs: procedure expose rlen ucnt html ico.;
 parse arg lev dir

 call lineout html, '<p><dl><dt>'
 if sysGetEA( dir, '.LONGNAME', 'ea' ) = 0 
  then d = substr( ea, 5 )
  else d = fname( dir )
 call lineout html, ico.GRP'<b>' || d || '</b><dd>'

 fls. = ''
 rc = sysFileTree( dir'\*', fls, 'FO' )
 do i = 1 to fls.0
  f = fname( fls.i )
  if left( f, 1 ) <> '.' then do; ucnt = ucnt + 1;
   if sysGetEA( fls.i, '.LONGNAME', 'ea' ) = 0 then f = substr( ea, 5 )
   u = linein( fls.i )
   call lineout html, '<br>'ico.URL'<a href="'u'">' || f || '</a>'
   call stream fls.i, 'C', 'CLOSE'
  end
 end
 fls. = ''
 rc = sysFileTree( dir'\*', fls, 'DO' )
 do i = 1 to fls.0; d = fname( fls.i )
  if left( d, 1 ) <> '.' then call recurs lev+1 fls.i
 end
 call lineout html, '</dl></p>'

return

fname: procedure
 parse arg fn
 p = lastpos( '\', fn );
 if p > 0 then fn = substr( fn, p+1 )
return fn

usage: procedure
 say 
 say 'Usage: urltree.cmd  d:\path\to\url\root\dir  outFile.html'
 say
return

/*eof*/
