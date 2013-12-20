/*  rexx script to make read PMMail mailbox information */
/*  expects a CGI GET with a single line  */
/*  consisting of the directory name to output */
say 'HTTP/1.0 200 Okay'
say 'Content-type: text/html'
say ''

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
PMMailDir = 'F:\App\SOUTHSDE\PMMAIL\'

booga = strip(arg(1))
parse value booga with crap 'folder-'URL

do while Pos("%2F",URL)<>0
   p=Pos("%2F",URL)
   URL= left(URL,p-1)'/'right( URL, length(URL)-p-2)
end /* do */
URL= Strip(URL)
if right(URL,1)\='\' then URL=URL'\'
    fldname=URL
    if lines(PMMailDir''URL'\folder.ini')>0 then
        parse value linein(PMMailDir''URL'\folder.ini') with fldname 'Þ' crap
say '<h1>AGD Ltd - WEBMAIL reader</h1><font size="-1" color=red>'fldname'</font>'
say '<hr><small>unauthorized access is prohibited!</small><p>'

/*  read directories below this one */

if length(URL)>1 then
  say '<li><a href="/bin/webmail.cmd?folder='left(URL, lastPos('\',URL,length(URL)-1))'">/..</a>'
call SysFileTree PMMailDir''URL, 'subdirs', 'DO'
do i=1 to subdirs.0
    dirlen = length(subdirs.i)-length(PMMailDir)
    if dirlen<=0 then interate
    whereami = strip(right( subdirs.i, dirlen ))
    fldname=whereami
    if lines(PMMailDir''whereami'\folder.ini')>0 then
        parse value linein(PMMailDir''whereami'\folder.ini') with fldname 'Þ' crap
    outgoing='<li><a href="/bin/webmail.cmd?folder='whereami'\">'fldname'</a>'
    say outgoing
end /* do */

say '<font size=-1><table border>'
do while lines(PMMailDir''URL'folder.bag')
 RC=linein( PMMailDir''URL'folder.bag')
 parse value RC with crap 'Þ' morecrap 'Þ' bagDate 'Þ' bagTime 'Þ' bagSubj 'Þ' bagToAd 'Þ' bagToNm 'Þ' bagFrAd 'Þ' bagFrNm 'Þ' bagSz 'Þ' bagFile 'Þ'
 say '<tr><td>'bagDate'<br>'bagTime'</td><td><font size="-1">'bagToNm'<br>'bagToAd'</font></td><td><font size="-1">'bagFrNm'<br>'bagFrAd'</font></td><td>'bagSz'</td><td>'
 say '<a href="/webmail/'translate(URL,'/','\')''bagFile'">'bagSubj'</a></td></tr>'
end /* do */
say '</table></font>'

say '</body></html>'

