/*

  rxShout
  -------

  Type "rxshout -h" for help.

  The procedure "SplitParameter" from "REXX Tips & Tricks" book used.

						Vasilkin Andrey, 2007y.
*/

Server.__port = 8001
password = 'Thedefault'
icy.__name = 'Radio AP!'
icy.__genre = 'Monkey Music'
icy.__url = 'http://irc.snc.ru/'
icy.__public = 1
icy.__bitrate = 128
opt.__random = 0
opt.__forever = 0
opt.__verbose = 0
PlaylistFile = 'playlist.txt'
ReadFromStdin = 0

parse arg Server.__addr' 'Parms
call SplitParameter Parms, ':'

show_settings = 0
do i = 1 to argv.0
  select
    when argv.i.__keyWord = '-P' then
      password = argv.i.__keyValue
    when argv.i.__keyWord = '-e' then
      Server.__port = argv.i.__keyValue
    when argv.i.__keyWord = '-g' then
      icy.__genre = argv.i.__keyValue
    when argv.i.__keyWord = '-l' then
      opt.__forever = 1
    when argv.i.__keyWord = '-n' then
      icy.__name = argv.i.__keyValue
    when argv.i.__keyWord = '-p' then
      PlaylistFile = argv.i.__keyValue
    when argv.i.__keyWord = '-r' then
      opt.__random = 1
    when argv.i.__keyWord = '-u' then
      icy.__url = translate(argv.i.__keyValue,'/','\')
    when argv.i.__keyWord = '-b' then
      icy.__bitrate = argv.i.__keyValue
    when argv.i.__keyWord = '-S' then
      show_settings = 1
    when argv.i.__keyWord = '-V' then
      opt.__verbose = 1
    when argv.i.__keyWord = '-stdin' then
      PlaylistFile = '<stdin>'
    otherwise
      do
        say 'unknown switch: "'argv.i.__keyWord'"'
        exit 2
      end
  end
end

if Server.__addr = '' | Server.__addr = '-?' | translate(Server.__addr) = '-H' then
do
  say 'Usage: rxshout <host> [options]...'
  say 'Options:'
  say '09'x || '-P:<password>	- Use specified password'
  say '09'x || '-S		- Display all settings and exit'
  say '09'x || '-V		- Use verbose output'
  say '09'x || '-b:<bitrate>	- Start using specified bitrate'
  say '09'x || '-e:<port>	- Connect to port on server.'
  say '09'x || '-g:<genre>	- Use specified genre'
  say '09'x || '-l		- Go on forever (loop)'
  say '09'x || '-n:<name>	- Use specified name'
  say '09'x || '-p:<playlist>	- Use specified file as a playlist'
  say '09'x || '-r		- Shuffle playlist (random play)'
  say '09'x || '-u:<url>	- Use specified url'
  say '09'x || '-stdin		- Read stream from stdin'
  exit 0
end

if \datatype(Server.__port,W) | (Server.__port < 1 | Server.__port > 65534) then
  call err_param '-e','port'
if \datatype(icy.__bitrate,'W') | (icy.__bitrate < 32 | icy.__bitrate > 320) then
  call err_param '-b','bitrate'
if opt.__random \= 0 & opt.__random \= 1 then
  call err_param '-r','random play'
if opt.__forever \= 0 & opt.__forever \= 1 then
  call err_param '-r','play forever'
if PlaylistFile \= '<stdin>' then
  if stream(PlaylistFile,'c','query exists') = '' then
  do
    say 'File "'PlaylistFile'" does not exist'
    exit 2
  end

if show_settings then
do
  say 'Current settings:'
  say '        Port to connect to: 'Server.__port
  say '        Shuffle playlist: 'OnOffVal(opt.__random)
  say '        Loop forever: 'OnOffVal(opt.__forever)
  say '        Verbose mode: 'OnOffVal(opt.__verbose)
  say '        Default bitrate: 'icy.__bitrate'000'
  say '        Internal playlist: 'PlaylistFile
  say '        Password: 'password
  say '        URL: 'icy.__url
  say '        Genre: 'icy.__genre
  say '        Name: 'icy.__name
  exit 0
end

sock = -1

if RxFuncQuery('SysLoadFuncs') then
do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
end

if RxFuncQuery('SockLoadFuncs') then
do
  call RxFuncAdd 'SockLoadFuncs','rxSock','SockLoadFuncs' 
  call SockLoadFuncs
end


/* Connecting */

if SockGetHostByName(Server.__addr,"host.!") = 0 then
  call err 'Could not resolve hostname: ' || Server.__addr

sock = SockSocket('AF_INET','SOCK_STREAM',0)
if sock < 0 then
  call err 'Error creating socket: ' || errno

serv.!family = "AF_INET"
serv.!port   = Server.__port
serv.!addr   = host.!addr

do i = 1 to 3
  rc = SockConnect(sock, "serv.!")
  if rc < 0 then
  do
    call log i'/3 Error on connecting ('serv.!addr':'serv.!port'): 'errno', wait 2 sec.'
    call SysSleep 2
  end
  else
    leave
end

if rc < 0 then exit 1

/* Login on server */

call log 'Logging in...';

rc = sock_send(sock, password);
if rc = -1 then
  exit 1

rc = SockRecv(sock, 'line', 128)
if rc = 0 then
  call err 'Connection refused. Wrong password?'
if rc < 0 then
  call err 'recv(), rc='rc

if translate(left(line,1)) \= 'O' then
do
  call err 'Wrong password'
end

/* Send icy */

rc = sock_send(sock, 'icy-name:' || icy.__name);
rc = sock_send(sock, 'icy-genre:' || icy.__genre);
rc = sock_send(sock, 'icy-url:' || icy.__url);
rc = sock_send(sock, 'icy-pub:' || icy.__public);
rc = sock_send(sock, 'icy-br:' || icy.__bitrate);
rc = sock_send(sock, '');
if rc = -1 then
  exit 2

say 'Connected to server...'

/* CONSTANTS (tables) */

s_freq.0 = '44100 48000 32000 0'
s_freq.1 = '22050 24000 16000 0'
s_freq.2 = '11025 8000 8000 0'
bitrates.0.1 = '0 32 64 96 128 160 192 224 256 288 320 352 384 416 448'
bitrates.0.2 = '0 32 48 56 64 80 96 112 128 160 192 224 256 320 384'
bitrates.0.3 = '0 32 40 48 56 64 80 96 112 128 160 192 224 256 320'
bitrates.1.1 = '0 32 48 56 64 80 96 112 128 144 160 176 192 224 256'
bitrates.1.2 = '0 8 16 24 32 40 48 56 64 80 96 112 128 144 160'
bitrates.1.3 = '0 8 16 24 32 40 48 56 64 80 96 112 128 144 160'
bitrates.2.1 = '0 32 48 56 64 80 96 112 128 144 160 176 192 224 256'
bitrates.2.2 = '0 8 16 24 32 40 48 56 64 80 96 112 128 144 160'
bitrates.2.3 = '0 8 16 24 32 40 48 56 64 80 96 112 128 144 160'
slotsf.1 = 384
slotsf.2 = 1152
slotsf.3 = 1152
consts_tables = 's_freq. bitrates. slotsf.'

call time 'R'
/*StartSyncTime = time('S')*/
st = 0

if PlaylistFile = '<stdin>' then
do

  say 'Translate stream from stdin...';

  call PlayItem

end
else do

  /* Load playlist */

  i = 0
  do while lines(PlaylistFile)
    line = strip(linein(PlaylistFile))

    if line \= '' then
    do
      i = i+1
      playlist.i = line
      playlist.i.__done = 0
    end
  end
  call stream PlaylistFile, 'c', 'close'
  playlist.0 = i

  if playlist.0 = 0 then
    call err "Nothing to play"

  call log 'Playlist loaded...' || playlist.0 || ' total songs...';

  /* Play */

  count = 0
  do forever
    count = count+1

    if opt.__random then
      i = RndItem()
    else
      i = count

    line = 'Playing from "'PlaylistFile'" line 'i
    call log line

    call PlayItem playlist.i

    if count = playlist.0 then
      if opt.__forever then count = 0
      else leave
  end

end

EXIT


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

PlayItem: procedure expose playlist. sock timetosleep PlaylistFile icy. opt.__verbose st (consts_tables) /*StartSyncTime*/
  file.__name = arg(1)

  if file.__name = '' then
    file.__size = 0
  else do
    file.__size = stream(file.__name,'c','query size')
    if file.__size = '' then
    do
      call log 'Cannot open 'file.__name
      return
    end
  end

  dwait = 0
  wait_sec = 0.250

  buf.size = 1024*8
  new_ptr = buf.size+1
  buf.ptr = 1
  file.__pos = 0
  progress = 1
  do forever

    buf.data = substr(buf.data, new_ptr)
    rc = length(buf.data)
    buf.data = buf.data || charin(file.__name, , new_ptr-1)
    if file.__size \= 0 then
      file.__pos = file.__pos + ( length(buf.data) - rc )
    buf.ptr = 1

    do forever			/* will try find mpeg header 8 times */
      new_ptr = get_bitrate()
      if new_ptr = -1 then	/* EOF */
      do
        if opt.__verbose then
          call charout ,copies(' ',79) || '0D'x
        if st = 0 then
        do			/* no one of frames was processed */
          mp3_bitrate = 0
          leave
        end
        else do
          if file.__name \= '' then
            call stream file.__name, 'c', 'close'
          return
        end
      end
      if mp3_bitrate = 0 then	/* bad mpeg header */
      do
        buf.ptr = new_ptr
        iterate
      end
      else
        leave
    end

    if mp3_bitrate = 0 then leave

/*    if new_ptr \= buf.ptr then*/
    do
      block_len = new_ptr - buf.ptr

      rc = SockSend( sock, substr(buf.data, buf.ptr, block_len) )
      if rc = -1 then
        call err 'send(), rc='rc

      st = st + trunc( (rc*8) / (mp3_bitrate * 1000), 3 )
/*      if st - (time('S')-StartSyncTime) > 1 then*/
      if st-time('E') > 0.5 then
      do
        if opt.__verbose then
        do
          line = info.__version_name' Layer 'info.__layer_name' ('info.__bitrate' kbit/s)'
          if file.__size \= 0 then
            line = line', Position 'file.__pos' (' || (file.__pos*100 % file.__size) || '%)'
          else do
            line = line' 'substr('\|/-',progress,1)
            progress = progress+1
            if progress = 5 then progress = 1
          end
          call charout ,line || '   ' || '0D'x
        end

/*        call SysSleep trunc(st-(time('S')-StartSyncTime),2)*/
        call SysSleep trunc(st-time('E'),1)

        if st > 3600 then
        do
          call time 'R'
/* StartSyncTime = time('S') */
          st = 0
        end
      end
    end
  end

  if file.__name \= '' then
    call stream file.__name, 'c', 'close'
  say left('Invalid file format.',79)
return

sock_send: procedure
  sock = arg(1)
  rc = SockSend(sock,arg(2) || '0D'x || '0A'x)
  if rc <= 0 then
  do
    call log 'send(), rc='rc
    rc = -1
  end
return rc

log:
  say arg(1)
  return

err:
  call log '0D'x || '0A'x || arg(1)
  if sock \= -1 then
    call SockClose sock
  exit 1

OnOffVal:
  if arg(1) then return 'on'
  else return 'off'

err_param:
  call log 'Ivalid option: 'arg(2)' (switch 'arg(1)')'
  return

get_bitrate: procedure expose buf. mp3_bitrate (consts_tables) info.
  mp3_bitrate = 0
  if length(buf.data) - buf.ptr < 0 then return -1;

  do i = buf.ptr by 1 while i <= length(buf.data)-4
    t1 = bitand( d2c(c2d(substr(buf.data,i,1)) * 16), '0FF0'x )
    if t1 = '0FF0'x then
    do
      ch = c2d( substr(buf.data,i+1,1) )
      t2 = bitand( d2c(ch % 16), '0E'x )
      if t2 = '0E'x then
      do
        ch2 = c2d( substr(buf.data,i+2,1) )
        ch3 = c2d( substr(buf.data,i+3,1) )
        temp = bitor(t1,'00'x || t2)
        leave
      end
    end
  end
  i = i+1

  if temp \= '0FFE'x then
    return i

  s = c2d( bitand(d2c(3),d2c(ch % 8)) )
  select
    when s=3 then mh.__version = 0
    when s=2 then mh.__version = 1
    when s=0 then mh.__version = 2
    otherwise
      return i
  end

  mh.__lay = 4 - c2d( bitand( d2c(ch % 2), '03'x ) )
  if mh.__lay = 4 then
    return i
  mh.__sampling_frequency = c2d( bitand( d2c(ch2 % 4), '03'x ) )
  mh.__bitrate_index = c2d( bitand( d2c(ch2 % 16), '0F'x ) )
  mh.__padding = c2d( bitand( d2c(ch2 % 2), '01'x ) )

  mp3_bitrate = word(value('bitrates.' || mh.__version || '.' || mh.__lay), mh.__bitrate_index+1)
  info.__freq = word(value('s_freq.' || mh.__version) ,mh.__sampling_frequency+1);

  if info.__freq = 0 | mp3_bitrate = '' | mp3_bitrate = 0 then
  do
    mp3_bitrate = 0
    return i
  end
  else do
    datasize = ( value('slotsf.' || mh.__lay) % 8 ) * mp3_bitrate * 1000
    datasize = datasize % info.__freq
    datasize = datasize + mh.__padding;
  end

  info.__bitrate = mp3_bitrate
  info.__layer_name = word('I II III',mh.__lay);
  info.__version_name = word('MPEG-1 MPEG-2 LSF MPEG-2.5',mh.__version+1);
return buf.ptr + datasize

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
SplitParameter: PROCEDURE EXPOSE argv.

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
      argv.i.__keyword = argType
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
