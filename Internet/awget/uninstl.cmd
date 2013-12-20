/* REXX deinstallation script for Auto WGet Daemon
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
 * $Id: uninstl.cms,v 1.27 2003/01/15 09:51:31 glass Exp $
 */

globals = "cfg. local. msg. sys. color. dir. jobs. job. plugins."

if translate( value( "AWGET_TRACE",, "OS2ENVIRONMENT" )) == "YES" then do
   call  value "AWGET_TRACE", "", "OS2ENVIRONMENT"
   trace intermediate
   trace results
end

cls ; call AwInit

say color.bold  || "Auto WGet Daemon " || color.usual || "Version 1.8.2 Deinstallation"
say color.usual || "Copyright (C) 1998-2003 Dmitry A.Steklenev"
say color.usual || ""

call MsgRead "awgmsg"
call CfgRead

call LogDo err, msg.uninstal_warning
say  ""

if MsgYesNo( ">>> "msg.uninstal ) == 0 then
   exit 0

remove_config = MsgYesNo( ">>> "msg.remove_config" "sys.config_file )

say ""
say AwStop()

call DeleteObject "<AWG2_JOBS>"
call DeleteObject "<AWG2_RUNNING>"
call DeleteObject "<AWG2_DONE>"
call DeleteObject "<AWG2_FAILED>"
call DeleteObject "<AWG2_TODO>"
call DeleteObject "<AWG2_DAEMON>"

if remove_config then
   call DeleteFile sys.config_file

call DeleteObject "<AWG2_HOME>"

if filespec( "p", directory()) == "\" then do
   call LogDo err, replace( msg.uninstal_error, "%s", directory())
   say; pause
   exit 1
end

call SysFileTree "NLS\*", 'erase', 'FO'
do i = 1 to erase.0
   call DeleteFile "NLS\"filespec( "name", erase.i )
end
call SysFileTree "Plugins\*", 'erase', 'FO'
do i = 1 to erase.0
   call DeleteFile "Plugins\"filespec( "name", erase.i )
end
call SysFileTree "Icons\*", 'erase', 'FO'
do i = 1 to erase.0
   call DeleteFile "Icons\"filespec( "name", erase.i )
end
call SysFileTree "*", 'erase', 'FO'
do i = 1 to erase.0
   call DeleteFile filespec( "name", erase.i )
end

call DeleteDirectory "NLS"
call DeleteDirectory "Icons"
call DeleteDirectory "Plugins"
call DeleteDirectory "Folders"
call directory ".."
call DeleteDirectory cfg.home

call LogDo inf, "Done!"
say; pause
exit 0

/*------------------------------------------------------------------
 * Delete file
 *------------------------------------------------------------------*/
DeleteFile: procedure expose (globals)

 parse arg file
 rc = OsDelete( file )

 if rc == 0 then
    call LogDo inf, msg.erase_done  || ": "file
 else
    call LogDo err, msg.erase_error || ": "file", rc="rc
return rc == 0

/*------------------------------------------------------------------
 * Remove directory
 *------------------------------------------------------------------*/
DeleteDirectory: procedure expose (globals)

 parse arg path
 rc = SysRmDir(path)

 if rc == 0 then
    call LogDo inf, msg.erase_done  || ": "path
 else
    call LogDo err, msg.erase_error || ": "path", rc="rc
return rc == 0

/*------------------------------------------------------------------
 * Delete WPS object
 *------------------------------------------------------------------*/
DeleteObject: procedure expose (globals)

 parse arg id
 rc = SysDestroyObject( id )

 if rc then
    call LogDo inf, msg.erase_done  || ": "id
 else
    call LogDo err, msg.erase_error || ": "id
return rc

/*------------------------------------------------------------------
 * Display Log Record
 *------------------------------------------------------------------*/
LogDo: procedure expose (globals)

  parse arg type, message
  type = translate(type)

  if type == "INF" then type = "INFO"
  if type == "ERR" then type = "ERROR"

  if type == "ERROR" then
     call beep 1000, 100

  say color.type"þþþ " ||,
      replace( message, '0D0A'x, '0D0A'x || copies( ' ', 4 )) || color.usual

return ""

/* $Id: init.cms,v 1.36 2003/04/22 13:49:26 glass Exp $ */

/*------------------------------------------------------------------
 * Initialization
 *------------------------------------------------------------------*/
AwInit: procedure expose (globals)

  if RxFuncQuery('SysLoadFuncs') then do
     call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
     call SysLoadFuncs
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

/*------------------------------------------------------------------
 * Get Yes or No
 *------------------------------------------------------------------*/
MsgYesNo: procedure expose (globals)

  parse arg prompt
  ok = 0

  do until ok
     call charout, prompt"? "
     pull reply
     reply = left(reply,1)

     ok = (reply == "Y") |,
          (reply == "N") |,
          (pos( reply, msg.yes ) > 0 ) |,
          (pos( reply, msg.no  ) > 0 )

     if \ok then do
        say msg.bad_yesno
     end
  end

return (reply = "Y") | ( pos( reply, msg.yes ) > 0 )


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

/* $Id: stop.cms,v 1.16 2001/09/03 19:20:44 glass Exp $ */

/*------------------------------------------------------------------
 * Stop Auto WGet Daemon
 *------------------------------------------------------------------*/
AwStop: procedure expose (globals)

  sys_running  = cfg.home'\'sys.running
  sys_killing  = cfg.home'\'sys.killing

  call OsDelete sys_running
  call lineout  sys_killing, "Must die!"
  call charout, color.info || "þþþ "msg.wait_stopped"..."

  do 20 while stream( sys_running, 'c', 'query exist' ) \= ""
     call SysSleep  2
     call charout, "."
     call OsDelete sys_running
  end
  say ; say color.info || "þþþ "msg.stopped || color.usual

  call stream   sys_killing, 'c', 'close'
  call OsDelete sys_killing

return ""

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

