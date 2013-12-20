/* Auto WGet Download Utility
 *
 * Great idea and first release (C) 1998 Steve Trubachev
 * Final release (C) 1998-2003 Dmitry A.Steklenev
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgment:
 *    "This product includes software developed by Dmitry A.Steklenev".
 *
 * 4. Redistributions of any form whatsoever must retain the following
 *    acknowledgment:
 *    "This product includes software developed by Dmitry A.Steklenev".
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR OR CONTRIBUTORS "AS IS"
 * AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR OR THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: awgexec.cms,v 1.41 2003/02/06 08:16:48 glass Exp $
 */

globals = "cfg. local. msg. sys. color. dir. jobs. job. plugins."

if translate( value( "AWGET_TRACE",, "OS2ENVIRONMENT" )) == "YES" then do
   call  value "AWGET_TRACE", "", "OS2ENVIRONMENT"
   trace intermediate
   trace results
end

call AwInit
call MsgRead "awgmsg"
call CfgRead
call PlgRead "private"

parse upper value cfg.downloads_window with show","rows","cols

'@mode 'rows','cols

if abbrev( "VISIBLE", show ) then
   call AwShow 1

say color.bold  || "Auto WGet Download Utility " || color.usual || "Version 1.8.2"
say color.usual || "Copyright (C) 1998-2003 Dmitry A.Steklenev"
say color.usual || ""

/* activate plugins before opening any file */
call PlgStart

signal on syntax
parse arg job_file

if job_file == "" then
   exit 257

if \PlgBroadcast( "INIT "job_file ) then
   exit 257

if \JobRead( job_file ) then
   exit 257

parameters = job.downloads_parameters
url        = job.url
file       = GetFileFromURL(url)
host       = GetHostFromURL(url)
parameters = replace( parameters, "%d", job.download )
parameters = replace( parameters, "%p", translate(job.download, "/", "\" ))
parameters = replace( parameters, "%f", file )
parameters = replace( parameters, "%h", host )
parameters = replace( parameters, "%u", EncodeURL(url))
logs       = ""

rc = AwPOpen( job.downloads_utility, parameters, "phandle" )

if rc == 0 then do
   call PlgBroadcast "DATA"
   do until line == ""
      line = AwPRead( phandle )
      call charout , line
      logs = logs || line

      if length(logs) > 4096 then
         logs = right( logs, 2048 )

      call PlgWrite translate( line, ' ', '00'x )
   end
   rc = AwPClose( phandle )
   call PlgWrite '00'x

   job.downloads_rc   = rc
   job.downloads_info = AwExtract( logs )
   end
else do
   job.downloads_rc   = rc
   job.downloads_info = SysGetMessage(rc)
end

if job.downloads_rc == 0 then do
   call WpsPutEA job.download"\"file, ".SUBJECT" , url
   object_title   = space( WpsGetEA( job.object, ".LONGNAME" ))
   object_comment = object_title || '00'x || date()" "time() || '00'x
   call WpsPutEA job.download"\"file, ".COMMENTS", object_comment
end

call JobSave job_file
call PlgBroadcast "STOP" job_file
exit job.downloads_rc

syntax:

  parse source . . program .

  if sourceline() >= SIGL then
     sourceline = strip(sourceline(SIGL))
  else
     sourceline = ""

  call LogPut err, condition('C') rc "running" filespec( "name", program )", line " ||,
                   SIGL errortext(rc) condition('D'),, sourceline

  exit 256

/*------------------------------------------------------------------
 * Extracts the last not empty message of the download utility
 *------------------------------------------------------------------*/
AwExtract: procedure

  parse arg logs

  logs = strip(logs)
  do i = length(logs) to 1 by -1
     c = substr(logs,i,1)
     if c \= '0A'x & c \='0D'x then
        leave
  end

  logs = substr(logs,1,i)
  do i = length(logs) to 1 by -1
     c = substr(logs,i,1)
     if c == '0A'x | c =='0D'x then
        leave
  end

return substr(logs,i+1)

/* $Id: init.cms,v 1.36 2003/04/22 13:49:26 glass Exp $ */

/*------------------------------------------------------------------
 * Initialization
 *------------------------------------------------------------------*/
AwInit: procedure expose (globals)

  if RxFuncQuery('SysLoadFuncs') then do
     call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
     call SysLoadFuncs
  end

  parse source os what program tail
  lpath = substr( program, 1, lastpos( "\", program )) ||,
          value( "BEGINLIBPATH",, "OS2ENVIRONMENT"  )

  "@SET BEGINLIBPATH="lpath

  if RxFuncQuery('AwLoadFuncs') then do
     call RxFuncAdd  'AwLoadFuncs', 'awget.dll', 'AwLoadFuncs'
     call AwLoadFuncs
  end

  "@ECHO OFF"

  sys.config_file   = value( "ETC",, "OS2ENVIRONMENT" )"\awget.cfg"
  sys.connected     = 1
  sys.active_time   = 0
  sys.clpmon_handle = ""

  /* enable ANSI extended screen and keyboard control */
  '@ansi on > nul'

  color.brown   = "1B"x"[0;33m"
  color.red     = "1B"x"[1;31m"
  color.green   = "1B"x"[1;32m"
  color.yellow  = "1B"x"[1;33m"
  color.blue    = "1B"x"[1;34m"
  color.magenta = "1B"x"[1;35m"
  color.cyan    = "1B"x"[1;36m"
  color.white   = "1B"x"[1;37m"
  color.gray    = "1B"x"[0m"

  color.usual   = color.gray
  color.bold    = color.white
  color.error   = color.red
  color.info    = color.green
  color.debug   = color.brown

  /* known download utilites */

  sys.utils.0      = 2
  sys.utils.1.prog = wget.exe
  sys.utils.1.name = "GNU WGet"
  sys.utils.1.parm = '-c -t 10 -w 30 --referer=%h --progress=bar:force -P "%p" "%u"'
  sys.utils.2.prog = curl.exe
  sys.utils.2.name = "cURL"
  sys.utils.2.parm = '-y 300 -Y 1 -v -C - -o "%p/%f" "%u"'

  sys.utils.default.prog = sys.utils.1.prog
  sys.utils.default.name = sys.utils.1.name
  sys.utils.default.parm = sys.utils.1.parm

  /* service semaphores */

  sys.running = "$live$"
  sys.killing = "$stop$"
  sys.pushing = "$push$"
  sys.rebuild = "$init$"
  sys.tqueue  = "$term$"

  /* stream's open modes */

  parse version version .
  if version = "OBJREXX" then do
     sys.open_read  = "OPEN READ  SHAREREAD"
     sys.open_write = "OPEN WRITE SHAREREAD"
     end
  else do
     sys.open_read  = "OPEN READ"
     sys.open_write = "OPEN WRITE"
  end

  /* determine a command prefix for use */

  sys.shell = value( "OS2_SHELL",, "OS2ENVIRONMENT" )
  if sys.shell == "" then sys.shell = "cmd.exe"

  shellname = translate( filespec( "n", sys.shell  ))

  select
    when shellname == "CMD.EXE"  then
         sys.command = ""
    when shellname == "4OS2.EXE" then
         sys.command = "*"
    otherwise
         sys.command = "cmd.exe /c "
  end
return

/* $Id: nls.cms,v 1.13 2001/05/11 08:54:34 glass Exp $ */

/*------------------------------------------------------------------
 * Read messages
 *------------------------------------------------------------------*/
MsgRead: procedure expose (globals)

  parse arg msgfile
  parse source OS2 what msgpath

  msgfile = filespec( "disk", msgpath ) ||,
            filespec( "path", msgpath ) || "NLS\" || msgfile

  country = MsgCountryID()

  if stream( msgfile"."country, "c", "query exists" ) == "" then
     country = "001"

  msgfile = msgfile"."country
  rc = stream( msgfile, "C", sys.open_read )

  if rc \= "READY:" then do
     say  color.error || "þþþ Error on open NLS file: "msgfile
     exit 1
  end

  do while lines(msgfile) > 0
     line = strip(linein(msgfile))

     do while right(line,1) == "\"
        line = left( line, length(line)-1 )
        line = line || strip(linein(msgfile))
     end

     if line \= "" & left(line,1) \= "#" then do
        parse value line with id "=" msg

        id  = strip(id )
        msg = strip(msg)

        i = pos( "\n", msg )
        do while i > 0
           msg = substr( msg, 1, i-1 ) || '0D0A'x || substr( msg, i+2 )
           i = pos( "\n", msg )
        end

        msg.id = msg
     end
  end

  rc = stream( msgfile, "C", "CLOSE" )
return

/*------------------------------------------------------------------
 * Returns Country Identifier
 *------------------------------------------------------------------*/
MsgCountryID: procedure expose (globals)

  country = strip( SysIni( "BOTH", "PM_National", "iCountry" ),, '0'x )

  if country == "ERROR:" then
     country =  "001"
  else
     country =  right( country, 3, "0" )

return country


/* $Id: config.cms,v 1.38 2003/04/22 13:49:26 glass Exp $ */

/*------------------------------------------------------------------
 * Get Configuration
 *------------------------------------------------------------------*/
CfgRead: procedure expose (globals)

  cfg.home                     = "."
  cfg.download                 = "."
  cfg.downloads_simultaneously = 3
  cfg.downloads_from_same_host = 0
  cfg.downloads_window         = "hidden,80,12"
  cfg.downloads_attempts       = 15
  cfg.downloads_utility        = sys.utils.default.prog
  cfg.downloads_parameters     = sys.utils.default.parm
  cfg.clipboard_monitor        = 0
  cfg.clipboard_exclude        = "HTML HTM SHTML PHTML PHP STML ASP GIF JPG JPEG " ||,
                                 "PNG MNG CAB JAVA CLASS"
  cfg.scan_interval            = 30
  cfg.log_file                 = "nul"
  cfg.error_log                = "nul"
  cfg.log_keep                 = 15
  cfg.message_done             = 'start /n pmpopup2.exe "%m:~~%u" "Auto WGet Daemon" /BELL /B1:"OK" /T:900 /F:"8.Helv"'
  cfg.message_error            = 'start /n pmpopup2.exe "%m:~~%u~%i" "Auto WGet Daemon" /BELL /B1:"OK" /T:900 /F:"8.Helv"'
  cfg.messages                 = 1
  cfg.check_connection         = 0
  cfg.use_desktop              = 0
  cfg.keep_failed_url          = 1
  cfg.keep_done_url            = 0

  rc = stream( sys.config_file, "C", sys.open_read )

  do while lines(sys.config_file) > 0
     parse value linein(sys.config_file) with keyword "=" argument

     keyword  = translate(strip(keyword))
     argument = strip(argument)

     select
        when keyword == "HOME",
           | keyword == "DOWNLOAD",
           | keyword == "DOWNLOADS_SIMULTANEOUSLY",
           | keyword == "DOWNLOADS_WINDOW",
           | keyword == "DOWNLOADS_FROM_SAME_HOST",
           | keyword == "DOWNLOADS_ATTEMPTS",
           | keyword == "DOWNLOADS_UTILITY",
           | keyword == "DOWNLOADS_PARAMETERS",
           | keyword == "CLIPBOARD_MONITOR",
           | keyword == "CLIPBOARD_EXCLUDE",
           | keyword == "SCAN_INTERVAL",
           | keyword == "LOG_FILE",
           | keyword == "ERROR_LOG",
           | keyword == "LOG_KEEP",
           | keyword == "MESSAGE_DONE",
           | keyword == "MESSAGE_ERROR" then

             cfg.keyword = argument

        when keyword == "MESSAGES",
           | keyword == "CHECK_CONNECTION",
           | keyword == "USE_DESKTOP",
           | keyword == "KEEP_FAILED_URL",
           | keyword == "KEEP_DONE_URL" then

             cfg.keyword = (argument == "1")
        otherwise
     end
  end

  rc = stream( sys.config_file, "C", "CLOSE" )
  cfg.file_date = stream( sys.config_file, "C", "QUERY DATETIME" )
return


/* $Id: logs.cms,v 1.21 2001/05/11 08:54:34 glass Exp $ */

/*------------------------------------------------------------------
 * Open log file
 *------------------------------------------------------------------*/
LogOpen: procedure expose (globals)

  parse arg logfile

  if logfile == "" | translate(logfile) == "NUL" then
     return 0

  do 5
     rc = stream( logfile, "c", sys.open_write )
     if rc == "READY:" then leave
     call SysSleep 1
  end

return (rc == "READY:")

/*------------------------------------------------------------------
 * Write Log Record
 *------------------------------------------------------------------*/
LogPut: procedure expose (globals)

  parse arg type, message, file_or_url, information
  type = translate(type)

  if type == "INF" then type = "INFO"
  if type == "ERR" then type = "ERROR"
  if type == "BLD" then type = "BOLD"

  select
    when type == "BOLD" | type == "INFO" then do
      logfile  = cfg.log_file
      end

    when type == "ERROR" then do
      logfile  = cfg.error_log
      end

    otherwise do
      type     = "USUAL"
      logfile  = cfg.log_file
      end
  end

  /* Output to file */
  if LogOpen(logfile) then do

     if arg( 3, "exists" ) then
        call lineout logfile, date('e')" "time()" "message": "file_or_url
     else
        call lineout logfile, date('e')" "time()" "message

     if arg( 4, "exists" ) & information \= "" then
        call lineout logfile, copies( ' ', 18 ) || information

     rc = stream( logfile, "c", "close" )
  end

  /* Sound's alert */
  if type == "ERROR" then
     call beep 1000, 100

  /* Display message */
  if arg( 3, "exists" ) then do
     if length(file_or_url) + length(message) < 73 then
        say color.type"þþþ "message": "file_or_url
     else do
        say color.type"þþþ "message": "
        say color.type"    "ShortenURL( file_or_url, 75 )
     end
     end
  else
     say color.type"þþþ "message

  if arg( 4, "exist" ) & information \= "" then
     say color.type"    "information

  call charout, color.usual
return

/* $Id: shorten.cms,v 1.4 2001/10/10 16:04:24 glass Exp $ */

/*------------------------------------------------------------------
 * Reduces URL length
 *------------------------------------------------------------------*/
ShortenURL: procedure expose (globals)

  parse arg url, max

  if length(url) > max then
     do
       if translate( left( url, 6 )) == "FTP://" then
          shorten = left( url, 6 )
       else if translate( left( url, 7 )) == "HTTP://" then
          shorten = left( url, 7 )
       else if translate( left( url, 8 )) == "HTTPS://" then
          shorten = left( url, 8 )
       else if substr( url, 3, 1 ) == "\" then
          shorten = left( url, 3 )
       else
          shorten = ""

       shorten = shorten || "..." ||,
                 right( url, max - length(shorten) - 3 )
     end
  else
     shorten = url

return shorten

/* $Id: wps.cms,v 1.26 2003/04/22 13:49:26 glass Exp $ */

/*------------------------------------------------------------------
 * Write a named ascii extended attribute to a file
 *------------------------------------------------------------------*/
WpsPutEA: procedure expose (globals)

  parse arg file, name, ea_string
  ea = ""

  if pos( '00'x, ea_string ) > 0 then do
     do ea_count = 0 while length( ea_string ) > 0
       parse value ea_string with string '00'x ea_string
       ea = ea || 'FDFF'x ||,
            substr( reverse( d2c(length(string))), 1, 2, '00'x ) ||,
            string
     end
     ea = 'DFFF'x || '0000'x ||,
          substr( reverse( d2c(ea_count)), 1, 2, '00'x ) || ea
     end
  else
     ea = 'FDFF'x ||,
          substr( reverse( d2c(length(ea_string))), 1, 2, '00'x ) ||,
          ea_string

return SysPutEA( file, name, ea )

/*------------------------------------------------------------------
 * Read a named ascii extended attribute from a file
 *------------------------------------------------------------------*/
WpsGetEA: procedure expose (globals)

  parse arg file, name
  if file == "" then return ""

  if SysGetEA( file, name, "ea" ) \= 0 then
     return ""

  ea_type   = substr( ea, 1, 2 )
  ea_string = ""

  select
    when ea_type == 'FDFF'x then
      ea_string = substr( ea, 5 )

    when ea_type == 'DFFF'x then do
      ea_count = c2d( reverse( substr( ea, 5, 2 )))
      say "count: "ea_count
      ea_pos   = 7
      do ea_count while substr( ea, ea_pos, 2 ) == 'FDFF'x
         ea_length = c2d( reverse( substr( ea, ea_pos+2, 2 )))
         ea_string = ea_string || substr( ea, ea_pos+4, ea_length ) || '00'x
         ea_pos    = ea_pos + 4 + ea_length
      end
      end

    otherwise
  end

return ea_string

/* $Id: url.cms,v 1.18 2003/04/07 09:02:34 glass Exp $ */

/*------------------------------------------------------------------
 * Encode URL
 *------------------------------------------------------------------*/
EncodeURL: procedure expose (globals)

  parse arg url
return replace( url, " ", "%20" )

/*------------------------------------------------------------------
 * Decode URL
 *------------------------------------------------------------------*/
DecodeURL: procedure expose (globals)

  parse arg url

  parse arg url
  i = pos( "%", url )

  do while i > 0
     url = substr( url, 1, i-1      ) ||,
           x2c(substr( url, i+1, 2 )) ||,
           substr( url, i+3         )

     i = pos( "%", url, i+1 )
  end
return url

/*------------------------------------------------------------------
 * Get filename from URL
 *------------------------------------------------------------------*/
GetFileFromURL: procedure expose (globals)

  /* generic-URL syntax consists of six components:          */
  /* <scheme>://<net_loc>/<path>;<params>?<query>#<fragment> */

  parse arg url
  url = strip(url)

  i = lastpos( "#", url )
  if i > 0 then url = substr( url, 1, i-1 )

  i = pos( ":", url )
  if i > 0 then url = substr( url, i+1 )

  if left(url,2) == "//" then do
     i = pos( "/", url, 3 )
     if i > 0 then
        url = substr( url, i )
     else
        url = ""
  end

  i = lastpos( "?", url )
  if i > 0 then url = substr( url, 1, i-1 )

  i = lastpos( ";", url )
  if i > 0 then url = substr( url, 1, i-1 )

  i = lastpos( "/", url )
  if i > 0 then url = substr( url, i+1 )

  if url == "" then url = "index.html"
return DecodeURL(url)

/*------------------------------------------------------------------
 * Get host from URL
 *------------------------------------------------------------------*/
GetHostFromURL: procedure expose (globals)

  /* generic-URL syntax consists of six components:          */
  /* <scheme>://<net_loc>/<path>;<params>?<query>#<fragment> */

  parse arg url
  url  = strip(url)
  host = ""

  i = lastpos( "#", url )
  if i > 0 then url = substr( url, 1, i-1 )

  i = pos( ":", url )
  if i > 0 then url = substr( url, i+1 )

  if left(url,2) == "//" then do
     i = pos( "/", url, 3 )
     if i > 0 then
        host = substr( url, 3, i-3 )
  end

return DecodeURL(host)


/* $Id: replace.cms,v 1.5 2001/05/11 08:54:34 glass Exp $ */

/*------------------------------------------------------------------
 * Search and replace string
 *------------------------------------------------------------------*/
replace: procedure expose (globals)

  parse arg source, string, substitute
  string = translate(string)

  i = pos( string, translate(source))

  do while i \= 0
     source = substr( source, 1, i-1 ) || substitute ||,
              substr( source, i+length(string))

     i = pos( string, translate(source), i + length(substitute))
  end

return source

/* $Id: jobs.cms,v 1.16 2001/10/08 17:56:34 glass Exp $ */

/*------------------------------------------------------------------
 * Read Job from file
 *------------------------------------------------------------------*/
JobRead: procedure expose (globals)

  parse arg pathname

  job.object               = ""
  job.url                  = ""
  job.download             = ""
  job.message_done         = ""
  job.message_error        = ""
  job.downloads_utility    = ""
  job.downloads_parameters = ""
  job.downloads_rc         = 0
  job.downloads_info       = ""

  rc = stream( pathname, "C", sys.open_read )

  if rc \= "READY:" then do
     call LogPut err, msg.read_error, pathname
     return 0
  end

  do while lines(pathname) > 0
     parse value linein(pathname) with keyword "=" argument

     keyword  = translate(strip(keyword))
     argument = strip(argument)

     select
        when keyword == "OBJECT",
           | keyword == "URL",
           | keyword == "DOWNLOAD",
           | keyword == "DOWNLOADS_UTILITY",
           | keyword == "DOWNLOADS_PARAMETERS",
           | keyword == "DOWNLOADS_RC",
           | keyword == "DOWNLOADS_INFO",
           | keyword == "MESSAGE_DONE",
           | keyword == "MESSAGE_ERROR" then

             job.keyword = argument
        otherwise
     end
  end

  rc = stream( pathname, "C", "CLOSE" )
return 1

/*------------------------------------------------------------------
 * Save Job to file
 *------------------------------------------------------------------*/
JobSave: procedure expose (globals)

  parse arg pathname

  if arg( 1, "omitted" ) | pathname == "" then do
     pathname = SysTempFileName( dir.jobs"\?????.job" )
     body.0   = 0
     end
  else do
     rc = stream( pathname, "C", sys.open_read )

     do i = 1 while lines(pathname) > 0
        body.i = linein(pathname)
     end
     body.0 = i - 1
     rc = stream( pathname, "C", "CLOSE" )
  end

  key_list = "OBJECT "               ||,
             "URL "                  ||,
             "DOWNLOAD "             ||,
             "MESSAGE_DONE "         ||,
             "MESSAGE_ERROR "        ||,
             "DOWNLOADS_UTILITY "    ||,
             "DOWNLOADS_PARAMETERS " ||,
             "DOWNLOADS_RC "         ||,
             "DOWNLOADS_INFO "

  do i = 1 to words(key_list)
     key = word(key_list,i)

     do j = 1 to body.0
        if left( strip( body.j ), 1 ) == "#" then
           iterate

        parse value body.j with keyword "="
        keyword = translate(strip(keyword))

        if key == keyword then
           leave
     end j

     body.j = key "=" job.key

     if j > body.0 then
        body.0 = j
  end i

  rc = OsDelete( pathname )
  rc = stream( pathname, "C", sys.open_write )

  if rc \= "READY:" then do
     call LogPut err, msg.write_error, pathname
     return ""
  end

  do j = 1 to body.0
     call lineout pathname, body.j
  end

  rc = stream( pathname, "C", "CLOSE" )
return pathname

/* $Id: os2.cms,v 1.2 2001/09/06 06:41:53 glass Exp $ */

/*------------------------------------------------------------------
 * Delete file
 *------------------------------------------------------------------*/
OsDelete: procedure expose (globals)

  parse arg file

  if stream( file, "C", "QUERY EXISTS" ) \= "" then do
     sys.command'del "'file'" /F 1>nul 2>nul'
     return rc
     end
  else
     return 1


/* $Id: plugins.cms,v 1.15 2001/07/20 10:54:47 glass Exp $ */

/*------------------------------------------------------------------
 * Get Plugins List
 *------------------------------------------------------------------*/
PlgRead: procedure expose (globals)

  parse arg type

  type  = translate(type"_plugin")
  rc    = stream( sys.config_file, "C", sys.open_read )
  count = 0

  do while lines(sys.config_file) > 0
     parse value linein(sys.config_file) with keyword "=" argument

     if translate(strip(keyword)) == type then do
        count = count + 1
        plugins.count.module = strip(argument)
        plugins.count.handle = ""
        plugins.count.buffer = ""
     end
  end

  rc = stream( sys.config_file, "C", "CLOSE" )
  plugins.0 = count
return

/*------------------------------------------------------------------
 * Activate Plugins
 *------------------------------------------------------------------*/
PlgStart: procedure expose (globals)

  do i = 1 to plugins.0
     rc = AwPOpen( sys.shell, "/c "plugins.i.module,,
                              "plugins."i".handle", "detach" )
     if rc \= 0 then
        call LogPut err, msg.error_in "AwPOpen, rc="rc,, SysGetMessage(rc)
  end
return

/*------------------------------------------------------------------
 * Deactivate Plugins
 *------------------------------------------------------------------*/
PlgStop: procedure expose (globals)

  do i = 1 to plugins.0
     if plugins.i.handle \= "" then
        AwPWrite( plugins.id.handle, "STOP" || "0D0A"x )
  end
return

/*------------------------------------------------------------------
 * Send Event
 *------------------------------------------------------------------*/
PlgSend: procedure expose (globals)

  parse arg id, event
  event = event || "0D0A"x

  if AwPWrite( plugins.id.handle, event ) != length(event) then do
     call LogPut err, msg.error_in "AwPWrite",, plugins.id.module
     return 0
  end

  do forever
     readed = AwPRead( plugins.id.handle )
     if readed == "" then do
        call LogPut err, msg.plugin_dead, plugins.id.module
        plugins.id.handle = ""
        return 1
     end

     plugins.id.buffer = plugins.id.buffer || readed

     i = pos( '0D0A'x,  plugins.id.buffer )
     do while i > 0
        event = substr( plugins.id.buffer, 1, i - 1 )
        plugins.id.buffer = substr( plugins.id.buffer, i + 2 )

        message = substr( event, 6    )
        event   = substr( event, 1, 4 )

        select
          when event == "INFO" then
               say color.info || "*** "message || color.usual
          when event == "EVNT" then
               call LogPut bld, message
          when event == "ALRM" then
               call LogPut err, message

          when event == "DONE" then do
               if message \= "" then
                  say color.info || "*** "message || color.usual

               plugins.id.buffer = ""
               return 1
               end

          when event == "FAIL" then do
               if message \= "" then
                  call LogPut err, message

               plugins.id.buffer = ""
               return 0
               end

          otherwise
        end
        i = pos( '0D0A'x,  plugins.id.buffer )
     end
  end
return 0

/*------------------------------------------------------------------
 * Broadcast Event
 *------------------------------------------------------------------*/
PlgBroadcast: procedure expose (globals)

  parse arg event
  done = 1

  do i = 1 to plugins.0
     if plugins.i.handle \= "" then
        done = PlgSend( i, event ) & done
  end
return done

/*------------------------------------------------------------------
 * Write Byte Stream
 *------------------------------------------------------------------*/
PlgWrite: procedure expose (globals)

  parse arg stream

  do i = 1 to plugins.0
     if plugins.i.handle \= "" then
        call AwPWrite plugins.i.handle, stream
  end
return
