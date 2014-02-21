/*

  LameStream
  ----------

  Solid reencoded mp3-stream to stdout

  Switches:
    -r:<yes|no>		Shuffle playlist (random play)
    -f:<yes|no>		Go on forever (loop)
    -p:<file>		Use specified file as a playlist
    -c:<SIZE|DATETIME>	Reload playlist when size or date/time of file changed
    -l:<file>		Logfile
    -b:<N>		Output bitrate
    -w:<file>		Web-file, history of last played songs in XML-format

  The procedure "SplitParameter" from "REXX Tips & Tricks" book used.

						Vasilkin Andrey, 2007y.
*/

opt.__random = 1
opt.__forever = 1
opt.__playlist = 'playlist.txt'
opt.__pl_ch_by = 'DATETIME'
opt.__logfile = 'LameStream.log'
opt.__bitrate = 128
opt.__webfile = 'LameStream.xml'

history.__len = 10 /* history length */
history.__pos = 0
history.0 = 0

cp.1251 = '¸éöóêåíãøùçõúôûâàïðîëäæýÿ÷ñìèòüáþ¨ÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀÏÐÎËÄÆÝß×ÑÌÈÒÜÁÞ'
cp.866  = 'ñ©æãª¥­£èé§åêäë¢ ¯à®«¤¦íïçá¬¨âì¡îð‰–“Š…ƒ˜™‡•š”›‚€Ž‹„†Ÿ—‘Œˆ’œž'

parse arg Parms
call SplitParameter Parms, ':'

do i = 1 to argv.0
  select
    when argv.i.__keyWord = '-R' then
      opt.__random = abbrev( 'YES', translate(argv.i.__keyValue) )
    when argv.i.__keyWord = '-F' then
      opt.__forever = abbrev( 'YES', translate(argv.i.__keyValue) )
    when argv.i.__keyWord = '-P' then
      PlaylistFile = argv.i.__keyValue
    when argv.i.__keyWord = '-C' then
      opt.__pl_ch_by = translate(argv.i.__keyValue)
    when argv.i.__keyWord = '-L' then
      opt.__logfile = argv.i.__keyValue
    when argv.i.__keyWord = '-B' then
      opt.__bitrate = argv.i.__keyValue
    when argv.i.__keyWord = '-W' then
      opt.__webfile = argv.i.__keyValue
    otherwise
      do
        call err 'unknown switch: "'argv.i.__keyWord'"'
        exit 2
      end
  end
end

call SysFileDelete opt.__logfile

parse SOURCE i i ScriptPath
ScriptPath = filespec('drive',ScriptPath) || filespec('path',ScriptPath)
call Directory strip(ScriptPath,'T','\')


if stream(opt.__playlist,'c','query exists') = '' then
  call err 'File "'opt.__playlist'" does not exist'

if \abbrev( 'SIZE', opt.__pl_ch_by ) & \abbrev( 'DATETIME', opt.__pl_ch_by ) then
  call err 'Ivalid switch -C. Must be SIZE or DATETIME'

bitrates = '8 16 24 32 40 48 56 64 80 96 112 128 160 192 224 256 320'
if wordpos(opt.__bitrate, bitrates) = 0 then
  call err 'Ivalid switch -B. Allowed values:' || '0D'x || '0A'x || '  'bitrates

if stream(opt.__webfile, 'c', 'open write') = '' then
  call err 'Cannot open/create web-file "'opt.__webfile'"'
call stream opt.__webfile, 'c', 'close'

if stream(opt.__playlist, 'c', 'open read') = '' then
  call err 'Cannot open playlist "'opt.__playlist'"'
call stream opt.__playlist, 'c', 'close'



if RxFuncQuery('SysLoadFuncs') then
do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
end

if stream('lame.exe','c','query exists') = '' then
  if SysSearchPath('path', 'lame.exe') = '' then
    call err 'The file LAME.EXE was not found'


do forever

  /* Load playlist */

  i = 0
  do while lines(opt.__playlist)
    line = strip(linein(opt.__playlist))

    if line \= '' then
    do
      i = i+1
      playlist.i = line
      playlist.i.__done = 0
    end
  end
  call stream opt.__playlist, 'c', 'close'
  playlist.0 = i

  if playlist.0 = 0 then
  do
    if \opt.__forever then leave
      call err 'Nothing to play'

    call log 'Nothing to play, wait 5 sec.'
    call SysSleep 5

    iterate
  end

  call log 'Playlist loaded...' || playlist.0 || ' total songs...';

  opt.__playlist.__status = FileStatus( opt.__playlist, opt.__pl_ch_by )

  /* Play */

  count = 0
  do forever
    count = count+1

    if opt.__random then
      i = RndItem()
    else
      i = count

    if stream(playlist.i,'c','query exists') = '' then
      call log 'not exist: 'playlist.i
    do
      call HistoryStore playlist.i
      call Lame playlist.i
    end

    if opt.__forever then
    do
      status = FileStatus( opt.__playlist, opt.__pl_ch_by )
      if opt.__playlist.__status \= status then
        leave
    end

    if count = playlist.0 then
      if opt.__forever then count = 0
      else leave
  end

  if \opt.__forever then
  do
    call log 'End of playlist.'
    leave
  end

  drop playlist.

end

EXIT


FileStatus: procedure /* FileName, [S/D] */
  status = translate(left(arg(2),1))
  if status = '' then
    return 0

  status = translate(left(status,1))
  if translate(left(arg(2),1)) = 'S' then status = 'size'
  else status = 'datetime'
return stream(arg(1), 'c', 'query 'status)


RndItem: procedure expose playlist.
  do 2
    idx = random(1,playlist.0)
    do playlist.0
      if \playlist.idx.__done then
      do
        playlist.idx.__done = 1
        return idx
      end

      if idx = playlist.0 then idx = 1
      else idx = idx + 1
    end

    do j = 1 to playlist.0
      playlist.idx.__done = 0
    end
  end
return

Lame: procedure expose opt. cp.
  file = arg(1)

  hdr = charin(file, 1, 3)
  if hdr \= 'ID3' & bitand(hdr, 'FFF000'x) \= 'FFF000'x then
  do
    call log 'not mp3-file: 'file
    return
  end
  call stream file, 'c', 'close'

  cmd = 'lame --mp3input -S --quiet -b ' || opt.__bitrate || ' -t "'file'" - 2>>'opt.__logfile
    
  call time 'R'
  cmd
  if time('E') < 1 then
    call err 'lime.exe runned too fast. Invalid lame''s switches or stdout is dead.'
return

HistoryStore: procedure expose history. opt.__webfile cp.
  file = arg(1)

  hpos = history.__pos + 1
  if hpos > history.__len then hpos = 1
  history.__pos = hpos
  if history.0 < history.__len then history.0 = history.0 + 1

  history.hpos.__file = filespec('name',file)
  history.hpos.__file = xml_str(translate(history.hpos.__file, cp.1251, cp.866))
  history.hpos.__time = time()

  /* Read TAG */

  file_size = stream(file, 'c', 'query size')
  if file_size >= 1024 then
  do
    tag = charin(file, file_size-127, 128)
    if left(tag, 3) = 'TAG' then
    do
      history.hpos.__tag = 1
      history.hpos.__tag.__title	= xml_str( substr(tag, 4, 30) )
      history.hpos.__tag.__artist	= xml_str( substr(tag, 34, 30) )
      history.hpos.__tag.__album	= xml_str( substr(tag, 64, 30) )
      history.hpos.__tag.__year		= xml_str( substr(tag, 94, 4) )
      history.hpos.__tag.__comment	= xml_str( substr(tag, 98, 29) )
    end
    else
      history.hpos.__tag = 0
  end
  call stream file, 'c', 'close'

  /* Update webfile */

  call SysFileDelete opt.__webfile
  j = hpos

  call lineout opt.__webfile, '<?xml version="1.0" encoding="windows-1251"?>'
  call lineout opt.__webfile, '<?xml-stylesheet type="text/xsl" href="LameStream.xsl"?>'
  call lineout opt.__webfile, '<lameStream>'

  do i = 1 to history.0
    call lineout opt.__webfile, '  <item id="'i'" time="'history.j.__time'">'
    call lineout opt.__webfile, '    <file>'history.j.__file'</file>'

    if history.j.__tag then
    do
      call lineout opt.__webfile, '    <title>'history.j.__tag.__title'</title>'
      call lineout opt.__webfile, '    <artist>'history.j.__tag.__artist'</artist>'
      call lineout opt.__webfile, '    <album>'history.j.__tag.__album'</album>'
      call lineout opt.__webfile, '    <year>'history.j.__tag.__year'</year>'
    end

    call lineout opt.__webfile, '  </item>'
    j = j - 1
    if j = 0 then j = history.__len
  end

  call lineout opt.__webfile, '</lameStream>'
  call stream opt.__webfile, 'c', 'close'

return

xml_str: procedure
  str = strip(arg(1), 'T', '00'x)
  str = strip(str, , ' ')
  str = subset(str, '&', '&amp;')
  str = subset(str, '<', '&lt;')
  str = subset(str, '>', '&gt;')
return str

subset: procedure
  str = arg(1)
  s1 = arg(2)
  s2 = arg(3)

  s1_len = length(s1)
  s2_len = length(s2)

  p = 1
  do forever
    p = pos(s1,str,p)
    if p \= 0 then
    do
      str = left(str,p-1) || s2 || substr(str, p+s1_len)
      p = p+s2_len
    end
    else leave
  end
return str

log:
  call lineout opt.__logfile, '[' || date() || ' ' || time() || ']: ' || arg(1)
  call lineout opt.__logfile
return

err:
  call log arg(1)
  say 'Error, see "'opt.__logfile'"'
  exit 1

/* ------------------------------------------------------------------ */
/* function: split a string into separate arguments                   */
/*                                                                    */
/* call:     call SplitParameter Parameter_string {, separator }      */
/*                                                                    */
/* where:    parameter_string - string to split                       */
/*           separator - separator character to split a parameter     */
/*                       into keyword and keyvalue                    */
/*                       (Def.: Don't split the parameter into        */
/*                              keyword and keyvalue)                 */
/*                                                                    */
/* returns:  the number of arguments                                  */
/*           The arguments are returned in the stem argv.:            */
/*                                                                    */
/*             argv.0 = number of arguments                           */
/*                                                                    */
/*             argv.n.__keyword = keyword                             */
/*             argv.n.__keyValue = keyValue                           */
/*             argv.n.__original = original_parameter                 */
/*                                                                    */
/*           The variables 'argv.n.__keyvalue' are only used if       */
/*           the parameter 'separator' is not omitted.                */
/*                                                                    */
/* note:     This routine handles arguments in quotes and double      */
/*           quotes also. You can use either the format               */
/*                                                                    */
/*             keyword:'k e y v a l u e'                              */
/*                                                                    */
/*           or                                                       */
/*                                                                    */
/*             'keyword:k e y v a l u e'                              */
/*                                                                    */
/*           (':' is the separator in this example).                  */
/*                                                                    */
SplitParameter: PROCEDURE EXPOSE (exposeList) argv.

                    /* get the parameter                              */
  parse arg thisArgs, thisSeparator

                    /* init the result stem                           */
  argv. = ''
  argv.0 = 0

  do while thisargs <> ''

    parse value strip( thisArgs, "B" ) with curArg thisArgs

    parse var curArg tc1 +1 .
    if tc1 = '"' | tc1 = "'" then
      parse value curArg thisArgs with (tc1) curArg (tc1) ThisArgs

    if thisSeparator <> '' then
    do
                    /* split the parameter into keyword and keyvalue  */
      parse var curArg argType (thisSeparator) argValue

      parse var argValue tc2 +1 .
      if tc2 = '"' | tc2 = "'" then
        parse value argValue thisArgs with (tc2) argValue (tc2) ThisArgs

      if tc1 <> '"' & tc1 <> "'" & tc2 <> '"' & tc2 <> "'" then
      do
        argtype  = strip( argType  )
        argValue = strip( argValue )
      end /* if */
      else                                                   /* v3.20 */
         if argValue <> '' then                              /* v3.20 */
           curArg = argtype || thisSeparator || argValue     /* v3.20 */

      i = argv.0 + 1
      argv.i.__keyword = translate( argType )
      argv.i.__KeyValue = argValue
      argv.i.__original = strip( curArg )                    /* v3.20 */
      argv.0 = i

   end /* if thisSeparator <> '' then */
   else
   do
     i = argv.0 + 1
     argv.i.__keyword = strip( curArg )
     argv.i.__original = strip( curArg )                     /* v3.20 */
     argv.0 = i
   end /* else */

  end /* do while thisArgs <> '' */

RETURN argv.0