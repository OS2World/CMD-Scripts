/* htmlconv.cmd - A HTML to/from Text Converter                950823 */
/* (c) Copyright Martin Lafaix, 1995.  All rights reserved.           */

version = '0.11.000'

call header

/* default values */
nl = '0d'x; last = ''; token = nl; toc = '123'; curlevel = 0; tocf = 'toc.html'; toca = 1; split=''; debug=0
toctagline = '<hr>Converted by <b>htmlconv</b> v'version', (c) Martin Lafaix 1995'nl'</body>'nl'</html>'
doctagline = toctagline
toclabel = 'Contents'
doclabel = ''
doctype = '<!doctype html public "-//IETF//DTD HTML 3.0//EN">'
ipftags =  ':p. :li. :dt. :dd. :ul. :eul. :ol. :eol. :dl. :edl. :hp1. :ehp1. :hp2. :ehp2. :hp3.  :ehp3.   :hp4.    :ehp4.    :hp5. :ehp5. :xmp. :exmp.',
           ':note.                          :hp7.  :ehp7.   :userdoc. :elink. :c.  :row. :etable.'
htmltags = '<p> <li> <dt> <dd> <ul> </ul> <ol> </ol> <dl> </dl> <i>   </i>   <b>   </b>   <b><i> </i></b> <strong> </strong> <u>   </u>   <pre> </pre>',
           '<p><strong>Note:&nbsp;</strong> <u><b> </b></u> <html>    </a>    <td> <tr>  </table>'

/* checking command line arguments */
parse arg args

if wordpos('/?', args) + wordpos('-h', args) + wordpos('-H', args) > 0 | args = '' then do
   call usage
   exit
   end

call profile

call getsymdef

/* Find requested conversion mode, if any... */
parse value args with option src dest
if option = '-T' | option = '-t' then
   type = 'TEXT'
else
if option = '-I' | option = '-i' then
   type = 'IPF'
else
if dest = '' then do
   type = 'HTML'
   dest = src; src = option
   end
else
   call error 'Invalid option:' option

/* Initialization */
say 'Reading symbols definitions...'
call readsymdef '_', '__'
if type = 'IPF' then do
   symdef = SysSearchPath('EPMPATH','IPFTAGS.'cp)
   call readsymdef '!', '!!'
   end
'@del' dest '>nul'
say 'Converting...'

/* Convert file */
call charin src,1,0

if type = 'HTML' then
   call h2t
else
if type = 'TEXT' then
   call t2h
else
   call i2h

exit

/*--------------------------------------------------------------------*/

i2h: /* convert from IPF to HTML, changing tags and symbols */
   '@del' tocf '>nul'

   if split \= '' then do
      destf = dest; destl = 0; dest = buildname(destf,destl)
      end

   call charout dest,doctype||nl||,
                     '<! --'nl'Source file:' src||nl'Destination file:' dest||nl||,
                     'Conversion date:' date()nl||,
                     'Converter: htmlconv v'version', (c) Martin Lafaix 1995'nl'   -->'
   call charout tocf,doctype||nl'<html>'nl

   tocvalues = 'toc toca toclabel curlevel toctagline'
   docvalues = 'destf destl title doclabel doctagline doctype title'
   call scan src, dest, tocf

   do while curlevel > 0
      call charout tocf, '</ul>'; curlevel = curlevel - 1
   end /* do */

   interpret 'tagline = 'doctagline
   call charout tocf, nl||tagline

   if split \= '' then do
      say 'Consolidating forwarded links...'
      do while queued() > 0
         parse pull file n offset
         if symbol('link.'n) = 'VAR' then
            call charout file,value('link.'n),offset+10
         else
            call charout ,'['n']'
         call charout ,'.'
      end /* do */
      do while destl > 0
         call stream buildname(destf,destl),'c','close'
         destl = destl-1
      end /* do */
      end

   return

scan: /* converting data from arg(1) to arg(2) [main] and arg(3) [toc] */
   procedure expose nl ipftags htmltags symbol. (tocvalues) (docvalues) bmpconverter bmpext split dest version link. debug
   src = arg(1); dest = arg(2); tocf = arg(3); last = ''; token = nl
   low = xrange('a','z'); high = xrange('A','Z')
   if debug then
      say '{scan called with 'arg(1) arg(2) arg(3) '}'
   do while chars(src) > 0
      token = readtoken(); len = length(token); char1 = left(token,1)
      if char1 = ':' then do
         ttoken = translate(token,low,high); wp = wordpos(ttoken,ipftags)
         char2 = substr(ttoken,2,1); char3 = substr(ttoken,3,1)
         select
            when wp > 0 then
               call charout dest,word(htmltags, wp)
            when left(ttoken, 5) = ':link' then do
               parse value ttoken with _ 'res=' n _ '.'
               if verify(n,0123456789) > 1 then
                  n = substr(n,1,verify(n,0123456789)-1)
               if symbol('link.'n) = 'VAR' then
                  call charout dest,'<a href="'value('link.'n)'#'n'">'
               else do
                  queue dest n stream(dest,'c','query size')
                  call charout dest,'<a href="'destf'#'n'">'
                  end
               end
            when pos(char2,'uod') > 0 & char3 = 'l' then
               if wordpos(ttoken, 'compact') > 0 then
                  call charout dest,'<'char2||char3' compact>'
               else
                  call charout dest,'<'char2||char3'>'
            when char2 = 'h' & pos(char3,'123456') > 0 then do
               parse value ttoken with  _ 'res=' n _ '.'
               header = linein(src); token = nl
               if pos(char3,split) > 0 then do
                  interpret 'tagline = 'doctagline
                  call charout dest,nl||tagline||nl'</body></html>'
                  call stream dest, 'c', 'close'
                  destl = destl + 1
                  dest = buildname(destf,destl)
                  say '['dest']'
                  call charout dest,doctype||nl||,
                                    '<! --'nl'Source file:' src||nl'Destination file:' dest||nl||,
                                    'Conversion date:' date()nl||,
                                    'Converter: htmlconv v'version', (c) Martin Lafaix 1995'nl'   -->'
                  call charout dest,'<head>'nl'<title>'header'</title>'nl'</head>'nl'<body>'nl
                  interpret 'label = 'doclabel
                  call charout dest,label
                  end
               if pos(char3,toc) > 0 then do
                  do while char3 > curlevel
                     call charout tocf, '<ul>'; curlevel = curlevel + 1
                  end /* do */
                  do while char3 < curlevel
                     call charout tocf, '</ul>'; curlevel = curlevel - 1
                  end /* do */
                  if n \= '' then
                     call charout tocf, '<li><a href="'dest'#'n'">'header'</a></li>'nl
                  else do
                     toca = toca + 1
                     call charout tocf, '<li><a href="'dest'#toc'toca'">'header'</a></li>'nl
                     end
                  end
               if n \= '' then do
                  call charout dest,'<h'char3'><a name='n'>'header'</a></h'char3'>'nl
                  link.n = dest
                  end
               else
               if pos(char3,toc) > 0 then
                  call charout dest,'<h'char3'><a name=toc'toca'>'header'</a></h'char3'>'nl
               else
                  call charout dest,'<h'char3'>'header'</h'char3'>'nl
               end
            when len = 1 then call charout dest,token
            when left(ttoken,6) = ':table' then
               call charout dest,'<table border=1 cellpadding=2 units=pixels>'
            when left(ttoken,8) = ':artwork' then do
               parse value ttoken with _ "name='" name "'" _ "."
               name = strip(name)
               if verify(name,'\','M') = 0 then
                  name = filespec('drive',src)filespec('path',src)name
               if bmpconverter \= '' then
                  'call' bmpconverter name newname(name)
               else
               call charout dest, '<p><img src="'newname(name)'">'
               end
            when ttoken = ':title.' then do
               title = linein(src); token = nl
               call charout dest,'<head>'nl'<title>'title'</title>'nl'</head>'nl'<body>'nl
               call charout tocf,'<head>'nl'<title>'title'</title>'nl'</head>'nl'<body>'nl'<h1>'toclabel'</h1>'nl
               call charout dest,doclabel
               end
            when left(ttoken,8) = ':docprof' then do
               parse value ttoken with _ 'toc=' newtoc _ "."
               if newtoc \= '' then toc = newtoc
               end
            when ttoken = ':euserdoc.' then
               call charout dest,nl||doctagline||nl'</body></html>'
         otherwise
            if debug then call charout ,token
         end  /* select */
         end
      else
      if len > 1 & char1 = '&' then do
         xtoken = 'symbol.!!'c2x(substr(token,2,len-2))
         if symbol(xtoken) = 'VAR' then
            if symbol('symbol._'value(xtoken)) = 'VAR' then
               call charout dest,value('symbol._'value(xtoken))
            else
               call charout dest,x2c(value(xtoken))
         else
            call charout dest, '&'token'.'
         end
      else
      if len = 3 & char1 = '.' then do
         if translate(token) = '.IM' then do
            newsrc = strip(linein(src))
            if verify(newsrc,'\','M') = 0 then
               newsrc = filespec('drive',src)filespec('path',src)newsrc
            say 'Imbeding 'newsrc'...'
            call charin newsrc,1,0
            call scan newsrc, dest, tocf
            token = nl
            end
         else
         if translate(token) = '.BR' then
            call charout dest, '<br>'
         else
            call charout dest,token
         end
      else
         call charout dest,token
   end /* do */
   call stream src, 'c', 'close'
   return

readtoken: /* read a token from src */
   procedure expose token last src
   old = token
   if last \== '' then
      token = last
   else
      token = charin(src,,1)
   last = ''

   if (old = '0d'x | old = '0a'x) & token = '.' then do
      last = charin(src,,1)
      if last = '*' then do                  /* a comment */
         call linein(src)
         token = '0a'x; last=''
         end
      else
      if last = 'b' | last = 'B' then do     /* a .br ??? */
         token = '.'last||charin(src,,1)
         last = ''
         return token
         end
      else
      if last = 'i' | last = 'I' then do     /* a .im ??? */
         token = '.'last||charin(src,,1)
         last = ''
         return token
         end
      end

   if token = ':' then do                    /* an IPF tag */
      last = charin(src,,1)
      if last >= 'a' & last <= 'z'  then do
         token = token||last; last = ''; quote = 0
         do until right(token,1) = '.' & quote = 0
            token = token||charin(src,,1)
            if right(token,1) = '''' then quote = quote && 1
         end /* do */
         end
      end
   else
   if token = '&' then do                    /* an IPF symbol */
      last = charin(src,,1)
      if (last >= 'a' & last <= 'z') | (last >= 'A' & last <= 'Z') then do
         do until last = '.'
            token = token||last
            last = charin(src,,1)
         end /* do */
         token = token||last; last = ''
         end
      end
   else
   if token = '<' then
      token = '&lt;'
   else
   if pos(right(token,1), '&:<'||'1a0d0a'x) = 0 then do
      last = charin(src,,1)
      do while pos(last, '&:<'||'1a0d0a'x) = 0
         token = token||last
         last = charin(src,,1)
      end /* do */
      end

   return token

error: /* report an error to the user */
   say arg(1)
   exit 1

getsymdef: /* get symbol definition file name */
   procedure expose symdef args cp
   cp = getcp()
   if wordpos('-s', args) > 0 then do
      symdef = word(args, wordpos('-s', args)+1)
      args = delword(args, wordpos('-s', args), 2)
      end
   else
      symdef = 'htmltags.'cp
   symdef2 = SysSearchPath('EPMPATH', symdef)
   if symdef2 = '' then
      call error 'Cannot find symbol file:' symdef
   symdef = symdef2
   return

getcp: /* get current codepage */
   msg = SysGetMessage(1766)
   '@chcp | rxqueue'
   queue '***'
   res = ''; r = ''
   do while r \= '***'
      parse pull r
      if res = '' then
         res = r
      else
         res = res||'0d0a'x||r
   end /* do */
   msg = translate(msg, '  ', '0d0a'x)
   res = translate(res, '  ', '0d0a'x)
   return word(res,wordpos('%1', msg))

h2t: /* convert from html to text, removing tags */
   do while chars(src) \= 0
      c = charin(src,,1)
      if c = '&' then do
         sym = ''
         c = charin(src,,1)
         do while c \= ';'
            sym = sym||c
            c = charin(src,,1)
         end /* do */
         if symbol('symbol.__'c2x(sym)) = 'VAR' then
            call charout dest, x2c(value('symbol.__'c2x(sym)))
         else
            call charout dest, '&'sym';'
         end
      else
      if c = '<' then
         do while c \= '>'
            c = charin(src,,1)
         end /* do */
      else
         call charout dest, c
   end /* do */
   return

t2h: /* convert from text to html */
   do while chars(src) \= 0
      c = charin(src,,1)
      if symbol('symbol._'c2x(c)) = 'VAR' then
         call charout dest, value('symbol._'c2x(c))
      else
         call charout dest, c
   end /* do */
   return

readsymdef: /* read a symbol definition file (EBOOKIE format) */
   say symdef
   literals = linein(symdef)
   do while lines(symdef)
      parse value linein(symdef) with code symbole .
      synlen = length(symbole)-2
      if symbole \= '--' & synlen > 0 then do
         call value 'symbol.'arg(1)c2x(code), symbole
         call value 'symbol.'arg(2)c2x(substr(symbole,2,synlen)), c2x(code)
         end
   end /* do */
   call stream symdef, 'c', 'close'
   return

header: /* display product header */
   say 'Operating System/2  HTML Converter'
   say 'Version 'version' Aug 23 1995'
   say '(C) Copyright Martin Lafaix 1995'
   say 'All rights reserved.'
   say
   return

usage: /* display product usage */
   say 'Usage:  htmlconv [<options>] <input file> [<output file>]'
   say '        -h              - Access help'
   say '        -i              - Convert from IPF to HTML'
   say '        -p profile      - Use profile file profile'
   say '        -s symbolfile   - Read symbols from symbolfile'
   say '        -t              - Convert from text to HTML'
   say
   say 'Environment variable:'
   say '        EPMPATH=where to search for symbolfile'
   say '        DPATH=where to search for profile file'
   say
   say 'By default, symbolfile HTMLTAGS.nnn is used, where nnn is the'
   say 'current codepage, profile file is PROFILE.CNV and conversion'
   say 'is from HTML to text.'
   return

newname: /* remove file extension, and replace it with bmpext */
   procedure expose bmpconverter bmpext
   if bmpconverter = '' then
      return arg(1)
   else
      return substr(arg(1),1,lastpos('.',arg(1)))bmpext

buildname: /* replace '?'s in arg(1) by value of arg(2) */
   procedure
   pos1 = pos('?',arg(1)); pos2 = lastpos('?',arg(1))
   if pos1 = 0 then
      call error 'Invalid destination file name (must contains ''?''s):' arg(1)
   val = right(arg(2),pos2-pos1+1,0)
   return substr(arg(1),1,pos1-1)val||substr(arg(1),pos2+1)

profile: /* finding and reading profile file */
   if RxFuncQuery('SysLoadFuncs') then do
      call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
      call SysLoadFuncs
      end
   if wordpos('-p', args) > 0 then do
      profileName = word(args, wordpos('-p', args)+1)
      args = delword(args, wordpos('-p', args), 2)
      end
   else
      profileName = 'profile.cnv'
   profileFile = SysSearchPath('DPATH',profileName)
   if profileFile \= '' then do
      do while lines(profileFile)
         line = linein(profileFile)
         do while lines(profileFile) & right(line,1) = ','
            line = left(line,length(line)-1) linein(profileFile)
         end /* do */
         interpret line
      end /* do */
      call stream profileFile, 'c', 'close'
      end
   return
