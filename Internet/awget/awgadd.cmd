/* Auto WGet URL Add Utility
 * Copyright (C) 1999-2003 Dmitry A.Steklenev
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
 * $Id: awgadd.cms,v 1.20 2003/04/22 13:49:25 glass Exp $
 */

globals = "cfg. local. msg. sys. color. dir. jobs. job. plugins."

if translate( value( "AWGET_TRACE",, "OS2ENVIRONMENT" )) == "YES" then do
   call  value "AWGET_TRACE", "", "OS2ENVIRONMENT"
   trace intermediate
   trace results
end

call AwInit

say color.bold  || "Auto WGet URL Add Utility " || color.usual || "Version 1.8.2"
say color.usual || "Copyright (C) 1998-2003 Dmitry A.Steklenev"
say color.usual || ""

call MsgRead "awgmsg"
call CfgRead
call DirRead

signal on syntax
sys_pushing = cfg.home'\'sys.pushing

parse source . what .

if what == 'COMMAND' then
   do
      "SET AWGADDURL=%1"
      "SET AWGFOLDER=%2"
   end /* do */
else
   do
      "SET AWGADDURL="arg(1)
      "SET AWGFOLDER="arg(2)
   end /* do */

url  = strip( value( "AWGADDURL",, "OS2ENVIRONMENT" ))
home = strip( value( "AWGFOLDER",, "OS2ENVIRONMENT" ))

if home == "" then do
   home = directory()
   if translate( dir.todo ) \= ,
      translate( left( home, length( dir.todo ))) then do
      home = dir.todo
   end
end

call SysFileTree home"\*", "home_dirs", "DSO"
do i = 1 to home_dirs.0
   j = i + 1
   file_long = WpsGetEA( home_dirs.i, ".LONGNAME" )
   if file_long == "" then
      home_menu.j = filespec( "name", home_dirs.i )
   else
      home_menu.j = file_long
end

home_menu.1      = "ToDo"
home_menu.0      = home_dirs.0 + 1
home_menu.select = 0

if url == "" then
   url = AwQueryURL( msg.enter_url, msg.enter_add, msg.enter_cancel, "home_menu" )

if left(url,1) == '"' & right(url,1) == '"' then
   url = substr( url, 2, length(url) - 2 )

if url == "" then do
   say "Usage: awgadd {<url>|<list_filename>} [<todo_folder>]"
   exit 1
end

if home_menu.select \= 0 then do
   i = home_menu.select
   home = home_dirs.i
end

if stream( url, "c", "query exists" ) \= "" then do
   do while lines(url) > 0
      next = strip(linein(url))
      if next \= "" then
         call WpsCreateURL next, home
   end
   call stream url, "c", "close"
   end
else
   call WpsCreateURL url, home

call lineout sys_pushing, "It is demand."
call stream  sys_pushing, 'c', 'close'
exit 0

syntax:

  parse source . . program .

  if sourceline() >= SIGL then
     sourceline = strip(sourceline(SIGL))
  else
     sourceline = ""

  call LogPut err, condition('C') rc "running" filespec( "name", program )", line " ||,
                   SIGL errortext(rc) condition('D'),, sourceline
  exit 256

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


/* $Id: dirs.cms,v 1.26 2001/09/03 19:20:44 glass Exp $ */

/*------------------------------------------------------------------
 * Get Directorys
 *------------------------------------------------------------------*/
DirRead: procedure expose (globals)

  dir.todo    = AwGetObjectPath( "<AWG2_TODO>"    )
  dir.running = AwGetObjectPath( "<AWG2_RUNNING>" )
  dir.done    = AwGetObjectPath( "<AWG2_DONE>"    )
  dir.failed  = AwGetObjectPath( "<AWG2_FAILED>"  )
  dir.jobs    = AwGetObjectPath( "<AWG2_JOBS>"    )
  dir.desktop = AwGetObjectPath( "<WP_DESKTOP>"   )

  /* check it */
  dir_list = "ToDo Running Done Failed Jobs Desktop"
  do i = 1 to words(dir_list)
     name = translate( word( dir_list,i ))
     if dir.name == "" then do
        call LogPut err, msg.not_found, word( dir_list,i )
        exit 1
     end
  end
return


/* $Id: wps.cms,v 1.26 2003/04/22 13:49:26 glass Exp $ */

/*------------------------------------------------------------------
 * Creates WPS URL object
 *------------------------------------------------------------------*/
WpsCreateURL: procedure expose (globals)

  parse arg url, home

  if left(url,1) == '"' & right(url,1) == '"' then
     url = substr( url, 2, length(url) - 2 )

  object = SysTempFileName( home"\add!????" )
  title  = GetFileFromURL(url)
  url    = replace( url, ";", "%3B" )

  if SysOs2Ver() > "2.30" then
     rc = SysCreateObject( "WPUrl", object, home, 'TITLE='title';URL='url, "R" )
  else do
     call lineout  object, url
     call stream   object, "c", "close"
     call WpsPutEA object, ".LONGNAME", title
     call SysSaveObject object, 0
  end
return

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

/* $Id: url.cms,v 1.18 2003/04/07 09:02:34 glass Exp $ */

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
