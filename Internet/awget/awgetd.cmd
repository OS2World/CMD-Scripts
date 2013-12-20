/* Auto WGet Daemon
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
 * $Id: awgetd.cms,v 1.92 2003/04/22 13:49:26 glass Exp $
 */

globals = "cfg. local. msg. sys. color. dir. jobs. job. plugins."

if translate( value( "AWGET_TRACE",, "OS2ENVIRONMENT" )) == "YES" then do
   call  value "AWGET_TRACE", "", "OS2ENVIRONMENT"
   trace intermediate
   trace results
end

call AwInit

cls
say color.bold  || "Auto WGet Daemon " || color.usual || "Version 1.8.2"
say color.usual || "Great idea and first release (C) 1998 Steve Trubachev"
say color.usual || "Final release (C) 1998-2003 Dmitry A.Steklenev"
say color.usual || ""

/* wait while 'TCP/IP Startup' running */
'inetwait 30000'

call MsgRead "awgmsg"
call CfgRead
cfg.download = CfgCheckDownload( cfg.download )
call CfgShow ; say
call DirRead
call DirShow ; say
call PlgRead "global"

sys_running  = cfg.home'\'sys.running
sys_killing  = cfg.home'\'sys.killing
sys_pushing  = cfg.home'\'sys.pushing
sys_rebuild  = cfg.home'\'sys.rebuild
jobs.0       = 0

/* activate plugins before opening any file */
call PlgStart

/* check up absence of the second copy of a daemon */
call OsDelete sys_running
call OsDelete sys_killing

if stream( sys_running, 'c', 'query exist' ) \= "" then do
   call LogPut err, msg.already_running
   exit 1
end
call lineout sys_running, "I'm alive!"

/* create termination queue */
rc = AwTQCreate( sys.tqueue, "sys.tqueue_handle" )

if rc \= 0 then do
   call LogPut err, msg.error_in "AwTQCreate, rc="rc,, SysGetMessage(rc)
   exit 1
end

signal on syntax
signal on halt


call AwUpdateWPS (OsDelete( sys_rebuild ) == 0)
call AwPrune
call OsDelete dir.jobs'\*.job'
drop running.

call PlgBroadcast "INIT "cfg.home

/*------------------------------------------------------------------
 * Sheduling of downloading
 *------------------------------------------------------------------*/
do while stream( sys_killing, 'c', 'query exist' ) == ""

  /* check up changes of the configuration file */
  if CfgCheckChanges() then do
     call AwUpdateWPS 0
     call PlgBroadcast "CONF "sys.config_file
  end

  /* recover interrupted downloads */
  call AwRescueLonely

  if PlgBroadcast( "SCAN "dir.todo ) then do

     /* scan DeskTop's objects */
     if cfg.use_desktop then do
        rc = SysFileTree( dir.desktop"\*" ,'desktop','FO' )
        do i = 1 to desktop.0
          if IsURLFile( desktop.i ) then
             call AwRecover desktop.i
        end
     end

     /* check up internet connection */
     call pppCheck

     /* build objects todo list */
     if sys.connected & jobs.0 < cfg.downloads_simultaneously then
        do
          call AwBuildToDo
        end
     else
        todo.0 = 0

     /* scheduling... */
     do scheduled = 1 to todo.0,
        while jobs.0 < cfg.downloads_simultaneously

        if \IsURLFile(todo.scheduled) then do
           call LogPut err, msg.bad_url, todo.scheduled
           call AwFailed todo.scheduled, 1
           iterate
        end

        call AwSchedule todo.scheduled
     end
  end

  /* analyzing termination queue */
  do cfg.scan_interval,
     while stream( sys_killing, 'c', 'query exist' ) == ""

     rc = AwTQRead( sys.tqueue_handle, "term" )
     if rc \= 0 then
        call LogPut err, msg.error_in "AwTQRead, rc="rc,, SysGetMessage(rc)

     have_errors = 0
     do i = 1 to term.0
        call AwComplete term.i.ses_id, term.i.ses_rc
        have_errors = have_errors | term.i.ses_rc \= 0
     end

     /* check up running objects */
     if jobs.0 > 0 then call AwCheckRunning

     call SysSleep 1
     sys.active_time = sys.active_time + 1

     /* Fast restart after succesfull download */
     if term.0 > 0 & \have_errors then
        leave

     /* Fast restart on demand */
     if OsDelete( sys_pushing ) == 0 then
        leave
  end

  drop todo.

  if jobs.0 == 0 & sys.active_time > 10800 then do /* 3 hours */
     call AwPrune
     sys.active_time = 0
  end
end

halt:

  /* close termination queue */
  rc = AwTQClose( sys.tqueue_handle )
  if rc \= 0 then
     call LogPut err, msg.error_in "AwTQClose, rc="rc,, SysGetMessage(rc)

  /* close clipboard monitor */
  if sys.clpmon_handle \= "" then do
     rc = AwPKill( sys.clpmon_handle )
     sys.clpmon_handle = ""
  end

  rc = stream( sys_running, 'c', 'close' )
  call OsDelete sys_running
  exit 0

syntax:

  parse source . . program .

  if sourceline() >= SIGL then
     sourceline = strip(sourceline(SIGL))
  else
     sourceline = ""

  call LogPut err, condition('C') rc "running" filespec( "name", program )", line " ||,
                   SIGL errortext(rc) condition('D'),, sourceline

  /* close clipboard monitor */
  if sys.clpmon_handle \= "" then do
     rc = AwPKill( sys.clpmon_handle )
     sys.clpmon_handle = ""
  end

  exit 256

/*------------------------------------------------------------------
 * Update WPS objects
 *------------------------------------------------------------------*/
AwUpdateWPS: procedure expose (globals)

  parse arg force

  if \SysSetObjectData( "<AWG2_EVTLOG>", "PARAMETERS="cfg.log_file  ) then
     call LogPut err, msg.error_in "SysSetObjectData <AWG2_EVTLOG>"
  if \SysSetObjectData( "<AWG2_ERRLOG>", "PARAMETERS="cfg.error_log ) then
     call LogPut err, msg.error_in "SysSetObjectData <AWG2_ERRLOG>"

  tools = AwGetObjectPath( "<AWG2_TOOLS>" )
  if tools \= "" &,
    (force | stream( tools"\awget.cfg", "c", "query exists" ) == "" ) then do

     call CfgCreateLocal tools
     call SysSetObjectData tools"\awget.cfg",,
          "ICONFILE="cfg.home"\Icons\awgedit.ico;" ||,
          "TEMPLATE=YES;"
  end

  if cfg.clipboard_monitor & sys.clpmon_handle == "" then do

     rc = AwPOpen( "awgclp.exe", '"'cfg.home'"' cfg.clipboard_exclude,,
                   "sys.clpmon_handle" )

     if rc \= 0 then
        call LogPut err, msg.error_in "AwPOpen( AWGCLP.EXE ), rc="rc,, SysGetMessage(rc)
  end

  if \cfg.clipboard_monitor & sys.clpmon_handle \= "" then do

     rc = AwPKill( sys.clpmon_handle )
     sys.clpmon_handle = ""
  end
return

/*------------------------------------------------------------------
 * Builds todo List
 *------------------------------------------------------------------*/
AwBuildToDo: procedure expose (globals) todo.

   rc = SysFileTree( dir.todo"\*", 'todo', 'FTS' )
   call AwSortToDo

   /* Remove file's attributes and reserved file names */
   j = 0; do i = 1 to todo.0

      parse value todo.i with . . . object
      name = translate( filespec( "name", object ))

      if name \= "AWGET.CFG"    &,
         name \= "WP SHARE. SF" &,
         name \= "WP ROOT. SF"  then do
         j = j + 1
         todo.j = strip(object)
      end
   end
   todo.0 = j
return

/*------------------------------------------------------------------
 * Sorts todo list
 *------------------------------------------------------------------*/
AwSortToDo: procedure expose (globals) todo.

  if todo.0 == 0 then return

  /* Used QUICKSORT implementation from "Album of Algorithms and
   * Techniques for Standard Rexx" of Vladimir Zabrodsky.
   * The original version of this source code can be found at
   * http://www.geocities.com/zabrodskyvlada/aat/index.html
   */

  N = todo.0
  S = 1; StackL.1 = 1; StackR.1 = N
  do until S = 0
    L = StackL.S; R = StackR.S; S = S - 1
    do until L >= R
      I = L; J = R; P = (L + R) % 2
      if todo.L > todo.P
        then do; W = todo.L; todo.L = todo.P; todo.P = W; end
      if todo.L > todo.R
        then do; W = todo.L; todo.L = todo.R; todo.R = W; end
      if todo.P > todo.R
        then do; W = todo.P; todo.P = todo.R; todo.R = W; end
      X = todo.P
      do until I > J
        do I = I while todo.I < X; end
        do J = J by -1 while X < todo.J; end
        if I <= J
          then do
            W = todo.I; todo.I = todo.J; todo.J = W
            I = I + 1; J = J - 1
          end
      end
      if J - L < R - I
        then do
          if I < R
            then do
              S = S + 1; StackL.S = I; StackR.S = R
            end
          R = J
        end
        else do
          if L < J
            then do
              S = S + 1; StackL.S = L; StackR.S = J
            end
          L = I
        end
    end /* until L >= R */
  end /* until S = 0 */
return

/*------------------------------------------------------------------
 * Check up running objects
 *------------------------------------------------------------------*/
AwCheckRunning: procedure expose (globals)

   do i = 1 to jobs.0
      if stream( jobs.i.object, "c", "query exist" ) == "" then do
         if JobRead( jobs.i.file ) then do
            job.object = ""
            call JobSave jobs.i.file
         end
         rc = AwStopSession( jobs.i.sid )
         if rc \= 0 then
            call LogPut err, msg.error_in "AwStopSession, rc="rc,, SysGetMessage(rc)
         iterate
      end
      if \sys.connected then do
         rc = AwStopSession( jobs.i.sid )
         if rc \= 0 then
            call LogPut err, msg.error_in "AwStopSession, rc="rc,, SysGetMessage(rc)
      end
   end
return

/*------------------------------------------------------------------
 * Returns nobody serviced objects back in download queue
 *------------------------------------------------------------------*/
AwRescueLonely: procedure expose (globals)

  rc = SysFileTree( dir.running"\*", 'running', 'FO'  )
  do i = 1 to running.0
     serviced = 0
     do j = 1 to jobs.0
        if translate( filespec( "name", jobs.j.object )) ==,
           translate( filespec( "name", running.i     )) then do
           serviced = 1
           leave
        end
     end
     if \serviced then call AwRecover running.i
  end
return

/*------------------------------------------------------------------
 * Recover interrupted file
 *------------------------------------------------------------------*/
AwRecover: procedure expose (globals)

  parse arg object, touch
  object_name = filespec( "name", object )
  object_home = WpsGetEA( object, "AWG_FOLDER" )

  if object_home == "" | \DirExist(object_home) then do
     object_home = dir.todo
     call WpsPutEA object, "AWG_FOLDER", object_home
  end

  call WpsMove object, object_home"\"object_name, touch
return

/*------------------------------------------------------------------
 * Move file to "Failed" or delete it
 *------------------------------------------------------------------*/
AwFailed: procedure expose (globals)

  parse arg object, keep
  object_name = filespec( "name" , object )

  if keep == 0 then
     call WpsDestroy object
  else do
     call WpsPutEA object, "AWG_ATTEMPTS", ""
     call WpsMove object, dir.failed"\"object_name
  end
return

/*------------------------------------------------------------------
 * Move file to "Done" or delete it
 *------------------------------------------------------------------*/
AwDone: procedure expose (globals)

  parse arg object, keep

  object_name = filespec( "name" , object )

  if keep == 0 then
     call WpsDestroy object
  else do
     call WpsPutEA object, "AWG_ATTEMPTS", ""
     call WpsMove object, dir.done"\"object_name
  end
return

/*------------------------------------------------------------------
 * Returns the downloads from same host
 *------------------------------------------------------------------*/
AwSameDownloads: procedure expose (globals)

  parse arg url
  url_host = translate( GetHostFromURL(url))
  url_same = 0

  do i = 1 to jobs.0
     if jobs.i.host == url_host then do
        url_same = url_same + 1
     end
  end
return url_same

/*------------------------------------------------------------------
 * Schedule file
 *------------------------------------------------------------------*/
AwSchedule: procedure expose (globals)

  parse arg object

  object_home = DirPath( object )
  call CfgReadLocal object_home
  schedule_it = (local.schedule == "")

  if \schedule_it then do
     schedule_plan = local.schedule
     curtime       = substr( time(), 1, 2 ) || substr( time(), 4, 2 )

     do while schedule_plan \= ""
        parse value schedule_plan with hb":"mb"-"he":"me","schedule_plan
        begtime = strip(hb)||strip(mb)
        endtime = strip(he)||strip(me)

        if ( curtime >= begtime & curtime <= endtime ) |,
           ( curtime >= begtime & begtime >= endtime ) |,
           ( curtime <= endtime & begtime >= endtime ) then do

           schedule_it = 1
           leave
        end
     end
  end

  if local.redirect_to \= "" then
     do
       if schedule_it then do
          run = WpsMove( object, local.redirect_to"\"filespec( "name", object ))
          if run \= "" then
             call LogPut msg, msg.download_redir, DecodeURL(GetURLFromFile(run))
       end
     end
  else
     do
       if local.downloads_from_same_host \= 0 then
          same = AwSameDownloads( GetURLFromFile( object ))
       else
          same = 0


       if schedule_it & ( local.downloads_from_same_host == 0 |,
                          local.downloads_from_same_host > same ) then do

          call WpsPutEA object, "AWG_FOLDER", object_home
          run = WpsMove( object, dir.running"\"filespec( "name", object ))

          if run \= "" then
             call AwDownload run
       end
     end
return

/*------------------------------------------------------------------
 * Starts download session
 *------------------------------------------------------------------*/
AwDownload: procedure expose (globals)

  parse arg job.object

  job.url                  = GetURLFromFile(job.object)
  job.download             = local.download
  job.downloads_utility    = local.downloads_utility
  job.downloads_parameters = local.downloads_parameters
  job.downloads_rc         = 0
  job.downloads_info       = ""
  job.message_done         = local.message_done
  job.message_error        = local.message_error

  new_job = JobSave()

  if PlgBroadcast( "SEXE "new_job ) then do

     rc = AwStartSession( ShortenURL( job.url, 57 ), sys.shell,,
                          '/c awgexec.cmd 'new_job, "bh", sys.tqueue,,
                          "ses_id" )
     if rc \= 0 then
        call LogPut err, msg.error_in "AwStartSession, rc="rc,,
                                                       SysGetMessage(rc)
     end
  else
     rc = 1

  if rc \= 0 then do
     call AwRecover job.object, "touch"
     if OsDelete( new_job ) \= 0 then
        call LogPut err, msg.erase_error, new_job
  end
  else do
     i = jobs.0 + 1
     jobs.i.file   = new_job
     jobs.i.object = job.object
     jobs.i.host   = translate( GetHostFromURL( job.url ))
     jobs.i.sid    = ses_id
     jobs.0 = i

     attempts = WpsGetEA( job.object, "AWG_ATTEMPTS" )
     if attempts \= "" then
        call LogPut msg, msg.download_start" (#"attempts+1")", DecodeURL(job.url)
     else
        call LogPut msg, msg.download_start, DecodeURL(job.url)

     if local.messages then
        call beep 5000, 50
  end
return

/*------------------------------------------------------------------
 * Completes download session
 *------------------------------------------------------------------*/
AwComplete: procedure expose (globals)

  parse arg ses_id, ses_rc

  /* find job in jobs list */
  do pos = 1 to jobs.0 while jobs.pos.sid \= ses_id ; end
  if pos > jobs.0 then do
     call LogPut err, msg.unknown_sid",sid="rc
     return
  end

  call PlgBroadcast "SEND "jobs.pos.file

  /* remove job from jobs list */
  job_rc = JobRead( jobs.pos.file )
  if OsDelete( jobs.pos.file ) \= 0 then
     call LogPut err, msg.erase_error, jobs.pos.file

  if pos <= jobs.0 then do
     do i = pos to jobs.0
        j = i + 1
        jobs.i.sid    = jobs.j.sid
        jobs.i.object = jobs.j.object
        jobs.i.host   = jobs.j.host
        jobs.i.file   = jobs.j.file
     end

     drop jobs.pos
     jobs.0 = jobs.0 - 1
  end

  if \job_rc then return

  /* read local configuration file */
  object_home = WpsGetEA( job.object, "AWG_FOLDER" )

  if object_home == "" | \DirExist(object_home) then
     object_home = dir.todo

  call CfgReadLocal object_home

  /* if download completed succesfully */
  if ses_rc == 0 then do
     call AwDone job.object, local.keep_done_url
     call LogPut msg, msg.download_done, DecodeURL(job.url)
     end
  /* if download interrupted */
  else do
     attempts = WpsGetEA( job.object, "AWG_ATTEMPTS" )

     if attempts == "" then
        attempts = 0
     if ses_rc \= 255 then
        attempts = attempts + 1

     if ses_rc == 256 & job.downloads_info == "" then
        job.downloads_info = "Syntax error in AWGet module. See errors log."

     /* fatal conditions */
     if (local.downloads_attempts \= 0 & attempts >= local.downloads_attempts) |,
                                                           ses_rc = 256 then do
        call AwFailed job.object, local.keep_failed_url
        call LogPut err, msg.download_error, DecodeURL(job.url),,
                                             job.downloads_info
        end
     else do
     /* go to next attempt */
        if job.object == "" then
           call AwRescueLonely
        else do
           call WpsPutEA  job.object, "AWG_ATTEMPTS", attempts
           if ses_rc \= 255 then
              call AwRecover job.object, "touch"
           else
              call AwRecover job.object
        end
        call LogPut msg, msg.download_stop, DecodeURL(job.url),,
                                            job.downloads_info
        return
     end
  end

  if local.messages then do
     if ses_rc == 0 then do
        message = msg.download_done
        execute = job.message_done
        end
     else do
        message = msg.download_error
        execute = job.message_error
     end

     execute = replace( execute, "%m", message )
     execute = replace( execute, "%u", DecodeURL(job.url))
     execute = replace( execute, "%r", job.downloads_rc )
     execute = replace( execute, "%i", job.downloads_info )
     execute = replace( execute, "%d", job.download )
     execute = replace( execute, "%p", translate(job.download, "/", "\" ))
     execute = replace( execute, "%f", GetFileFromURL(job.url))

     '@'execute
  end

return

/*------------------------------------------------------------------
 * Prunes log files
 *------------------------------------------------------------------*/
AwPrune: procedure expose (globals)

  if cfg.log_keep <= 0 then
     return

  logs.1 = cfg.log_file
  logs.2 = cfg.error_log
  logs.0 = 2
  pruned = 0
  today  = date("B")

  do i = 1 to logs.0
     if stream( logs.i, "c", sys.open_read ) \= "READY:" then
        iterate

     do prune = 0 while lines(logs.i) > 0
        entry = linein( logs.i )
        if today - DateBase(entry) <= cfg.log_keep then do
           entrys.1 = entry
           entrys.0 = 1
           leave
        end
     end

     if prune > 0 then do
        if pruned == 0 then
           say color.info || "*** "msg.prune_start || color.usual

        do keep = 2 while lines(logs.i) > 0
           entrys.keep = linein(logs.i)
        end
        entrys.0 = keep - 1

        call stream logs.i, "c", "close"
        call OsDelete logs.i

        if stream( logs.i, "c", sys.open_write ) == "READY:" then do
           do keep = 1 to entrys.0
              call lineout logs.i, entrys.keep
           end
           call stream logs.i, "c", "close"
        end
        pruned = pruned + prune
        end
     else
        call stream logs.i, "c", "close"
  end

  if pruned > 0 then
     call LogPut inf, replace(msg.prune_done,"%u",pruned)
return

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
 * Returns Confguration Keys
 *------------------------------------------------------------------*/
CfgKeys: procedure expose (globals)

return "HOME "                      ||,
       "DOWNLOAD "                  ||,
       "DOWNLOADS_SIMULTANEOUSLY "  ||,
       "DOWNLOADS_FROM_SAME_HOST "  ||,
       "DOWNLOADS_ATTEMPTS "        ||,
       "DOWNLOADS_UTILITY "         ||,
       "DOWNLOADS_PARAMETERS "      ||,
       "DOWNLOADS_WINDOW "          ||,
       "CLIPBOARD_MONITOR "         ||,
       "CLIPBOARD_EXCLUDE "         ||,
       "SCAN_INTERVAL "             ||,
       "LOG_FILE "                  ||,
       "ERROR_LOG "                 ||,
       "LOG_KEEP "                  ||,
       "MESSAGE_DONE "              ||,
       "MESSAGE_ERROR "             ||,
       "MESSAGES "                  ||,
       "CHECK_CONNECTION "          ||,
       "USE_DESKTOP "               ||,
       "KEEP_FAILED_URL "           ||,
       "KEEP_DONE_URL "

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

/*------------------------------------------------------------------
 * Show Configuration
 *------------------------------------------------------------------*/
CfgShow: procedure expose (globals)

  key_list = CfgKeys()
  do i = 1 to words(key_list)

     key = word(key_list,i)

     if (key \= "LOG_FILE"                ) &,
        (key \= "ERROR_LOG"               ) &,
        (key \= "MESSAGE_DONE"            ) &,
        (key \= "MESSAGE_ERROR"           ) &,
        (key \= "CLIPBOARD_EXCLUDE"       ) &,
        (key \= "DOWNLOADS_PARAMETERS"    ) &,
        (key \= "LOG_KEEP" | cfg.key \= 0 ) &,
        (cfg.key \= ""                    ) &,
        (cfg.key \= "nul"                 ) then do

         say color.usual || "*** "msg.key  || ": " || color.bold || cfg.key
     end
  end

  call charout , color.usual
return ""

/*------------------------------------------------------------------
 * Check Configuration Changes
 *------------------------------------------------------------------*/
CfgCheckChanges: procedure expose (globals)

  changed = (cfg.file_date \= stream( sys.config_file, "C", "QUERY DATETIME" ))

  if changed then do
     call LogPut inf, msg.config_changed
     call CfgRead
     cfg.download = CfgCheckDownload( cfg.download )
     call CfgShow
     changed = 1
  end

return changed

/*------------------------------------------------------------------
 * Check Download Directory
 *------------------------------------------------------------------*/
CfgCheckDownload: procedure expose (globals)

  parse arg download
  download = translate( download, "\", "/" )

  if right( download, 1 ) = "\" then
     download = left( download, length(download) - 1 )

  if download \= "." then do
     call setlocal
     download = directory( download )
     call endlocal
  end

  if download == "" then do
     call LogPut err, msg.bad_downldir
     download = "."
  end

return download

/*------------------------------------------------------------------
 * Read Local Configuration
 *------------------------------------------------------------------*/
CfgReadLocal: procedure expose (globals)

  parse arg home

  if right( home, 1 ) \= "\" then
     home = home"\"

  cfg_file = home"awget.cfg"
  cfg_date = stream( cfg_file, "C", "QUERY DATETIME" )

  if local.config_home \= home |,
     local.file_date   \=  cfg.file_date" "cfg_date then do

     key_list = CfgKeys()
     do i = 1 to words(key_list)
        key = word(key_list,i)
        local.key = cfg.key
     end

     local.schedule    = ""
     local.config_home = home
     local.file_date   = ""
     local.redirect_to = ""

     rc = stream( cfg_file, "C", sys.open_read )

     do while lines(cfg_file) > 0
        parse value linein(cfg_file) with keyword "=" argument

        keyword  = translate(strip(keyword))
        argument = strip(argument)

        select
           when keyword == "DOWNLOAD",
              | keyword == "DOWNLOADS_ATTEMPTS",
              | keyword == "DOWNLOADS_FROM_SAME_HOST",
              | keyword == "SCHEDULE",
              | keyword == "REDIRECT_TO",
              | keyword == "MESSAGE_DONE",
              | keyword == "MESSAGE_ERROR" then

                local.keyword = argument

           when keyword == "MESSAGES",
              | keyword == "KEEP_FAILED_URL",
              | keyword == "KEEP_DONE_URL" then

                local.keyword = (argument == "1")
           otherwise
        end
     end

     rc = stream( cfg_file, "C", "CLOSE" )
     local.file_date = cfg.file_date" "cfg_date
  end
return

/*------------------------------------------------------------------
 * Create Local Configuration
 *------------------------------------------------------------------*/
CfgCreateLocal: procedure expose (globals)

  parse arg home

  if right( home, 1 ) \= "\" then
     home = home"\"

  cfg_file = home"awget.cfg"

  rc = OsDelete( cfg_file )
  rc = stream( cfg_file, "C", sys.open_write )

  key_list =  "DOWNLOAD "                 ||,
              "DOWNLOADS_ATTEMPTS "       ||,
              "DOWNLOADS_FROM_SAME_HOST " ||,
              "SCHEDULE "                 ||,
              "REDIRECT_TO "              ||,
              "MESSAGE_DONE "             ||,
              "MESSAGE_ERROR "            ||,
              "MESSAGES "                 ||,
              "KEEP_FAILED_URL "          ||,
              "KEEP_DONE_URL "

  do i = 1 to words(key_list)
     key     = word(key_list,i)
     comment = "CFG_"  || key
     body    = "# "replace( msg.comment, "0D0A"x, "0D0A"x || "# " ) ||,
               "0D0A"x || "0D0A"x || "#" key "=" || "0D0A"x

     call lineout cfg_file, body
  end

  rc = stream( cfg_file, "C", "CLOSE" )
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

/*------------------------------------------------------------------
 * Copy file
 *------------------------------------------------------------------*/
OsCopy: procedure expose (globals)

  parse arg file_from, file_to, touch

  file_from = replace(file_from,"%","%%")
  file_to   = replace(file_to  ,"%","%%")

  if abbrev( "touch", touch, 1 ) then
     sys.command'copy /b "'file_from'" + ,, "'file_to'" 1> nul 2> nul'
  else
     sys.command'copy /b "'file_from'" "'file_to'" 1> nul 2> nul'

return rc

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

/*------------------------------------------------------------------
 * Show Directorys
 *------------------------------------------------------------------*/
DirShow: procedure expose (globals)

  say color.usual"*** "left( "Desktop"  ,10 )": "color.bold || ShortenURL( dir.desktop, 63 )
  say color.usual"*** "left( "Active"   ,10 )": "color.bold || ShortenURL( dir.running, 60 )
  say color.usual"*** "left( "Completed",10 )": "color.bold || ShortenURL( dir.done   , 63 )
  say color.usual"*** "left( "Failed"   ,10 )": "color.bold || ShortenURL( dir.failed , 60 )
  say color.usual"*** "left( "ToDo"     ,10 )": "color.bold || ShortenURL( dir.todo   , 63 )
  call charout , color.usual
return

/*------------------------------------------------------------------
 * Converts directory to canonical form
 *------------------------------------------------------------------*/
DirCanonical: procedure expose (globals)

  parse arg path
  path = translate( path, "\", "/" )

  if right( path, 1 ) == "\" & pos( ":", path ) \= length(path)-1 then
     path = left( path, length(path)-1 )

return path

/*------------------------------------------------------------------
 * Returns path to file
 *------------------------------------------------------------------*/
DirPath: procedure expose (globals)

  parse arg pathname

return DirCanonical( filespec( "drive", pathname ) ||,
                     filespec( "path" , pathname ))

/*------------------------------------------------------------------
 * Create directory
 *------------------------------------------------------------------*/
DirCreate: procedure expose (globals)

  parse arg path

  path = DirCanonical( path )
  rc   = SysMkDir( path )

  if rc == 3 & pos( "\", path ) \= 0 then do

     parent = left( path, length(path) - pos( "\", reverse(path)))
     rc = DirCreate( parent )

     if rc == 0 then
        rc = SysMkDir( path )
  end
return rc

/*------------------------------------------------------------------
 * Checks existence of the directory
 *------------------------------------------------------------------*/
DirExist: procedure expose (globals)

  parse arg path
  if path == "" then return 0
  path = DirCanonical( path )

  call setlocal
  path = directory( path )
  call endlocal

return path \= ""


/* $Id: wps.cms,v 1.26 2003/04/22 13:49:26 glass Exp $ */

/*------------------------------------------------------------------
 * Moves the WPS object
 *------------------------------------------------------------------*/
WpsMove: procedure expose (globals)

  parse arg file_from, file_to, touch

  file_long = WpsGetEA( file_from, ".LONGNAME" )

  if file_long == "" then
     rc = WpsPutEA( file_from, ".LONGNAME", filespec( "name", file_from ))

  if stream( file_to, "c", "query exists" ) \= "" then do

     path = filespec( "drive", file_to ) || filespec( "path", file_to )
     name = filespec( "name" , file_to )
     dot  = lastpos( ".", name )
     ext  = ""

     if dot > 0 then do
        ext  = substr( name, dot      )
        name = substr( name, 1, dot-1 )
     end

     if length( name ) > 8 then
        name = name"???"
     else do
        if length( name ) < 3 then
           name = substr( name, 1, 3, "!" )

        name = substr( name, 1, 5, "?" )
        name = substr( name, 1, 8, "?" )
     end

     file_to = SysTempFileName( path || name || ext )
  end

  rc = OsCopy( file_from, file_to, touch )

  if rc == 0 then do
     call WpsDestroy file_from
     call SysSaveObject file_to, 1
     end
  else do
     call LogPut err, msg.not_move", "file_from" -> "file_to
     file_to = ""
  end

return file_to

/*------------------------------------------------------------------
 * Destroys the WPS object
 *------------------------------------------------------------------*/
WpsDestroy: procedure expose (globals)

  parse arg file

  if stream( file, "C", "QUERY EXISTS" ) \= "" then
     return SysDestroyObject( file )

return 1

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
 * Get URL from file
 *------------------------------------------------------------------*/
GetURLFromFile: procedure expose (globals)

  parse arg filename

  rc  = stream(filename, "c", sys.open_read )
  url = linein(filename)

  if translate( strip( url )) == "[INTERNETSHORTCUT]" then
     parse value linein(filename) with 'URL='url

  rc  = stream(filename, "c", "close" )
return strip(url)

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

/*------------------------------------------------------------------
 * Check valid URL file
 *------------------------------------------------------------------*/
IsURLFile: procedure expose (globals)

  parse arg filename

  rc  = stream(filename, "c", "open read" )
  url = translate( strip( charin(filename,1,18)))
  rc  = stream(filename, "c", "close" )

return substr( url, 1,  7 ) == "HTTP://"  |,
       substr( url, 1,  8 ) == "HTTPS://" |,
       substr( url, 1,  6 ) == "FTP://"   |,
       substr( url, 1, 18 ) == "[INTERNETSHORTCUT]"


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

/* $Id: ppp.cms,v 1.14 2002/12/13 15:23:46 glass Exp $ */

/*------------------------------------------------------------------
 * Check PPP connection
 *------------------------------------------------------------------*/
pppCheck: procedure expose (globals)

  if \cfg.check_connection then

    sys.connected = 1

  else do

    new_queue = RxQueue( 'create' )
    old_queue = RxQueue( 'set', new_queue )
    active    = 0

    'netstat -a | RXQUEUE' new_queue

    do while queued() > 0
       parse pull P IP1 . interface . . . IP2
       if translate(P) == "ADDR" then do
            if interface >= '10' then do
               active = 1
            end
       end
    end

    call RxQueue 'delete', new_queue
    call RxQueue 'set'   , old_queue

    if active \= sys.connected then do
       sys.connected = active

       if active then
          call LogPut bld, msg.connection_established
       else
          call LogPut bld, msg.connection_broken
    end
  end

return sys.connected

/* $Id: date.cms,v 1.5 2001/05/11 08:54:34 glass Exp $ */

/*------------------------------------------------------------------
 * Convert a date in the format dd/mm/yy into the base date
 *------------------------------------------------------------------*/
DateBase: procedure expose (globals)

  /* initialize routine */
  NonLeap.   = 31
  NonLeap.0  = 12
  NonLeap.2  = 28
  NonLeap.4  = 30
  NonLeap.6  = 30
  NonLeap.9  = 30
  NonLeap.11 = 30

  /* grab parameter and store it in cyear cmonth cdate  */
  parse arg cdate +2 +1 cmonth +2 +1 cyear .

  if datatype(cdate ) \= "NUM" |,
     datatype(cmonth) \= "NUM" |,
     datatype(cyear ) \= "NUM" then
     return 0

  /* grab year and convert it to YYYY                   */
  /* simulate the behaviour of the REXX function date() */
  if length( cyear ) <= 2 then
     if cyear < 80 then
        fullyear = "20" || cyear
     else
        fullyear = "19" || cyear
  else
     fullyear = cyear

  numyears    = fullyear - 1
  basedays    = numyears * 365
  QuadCentury = numyears % 400
  Century     = numyears % 100
  LeapYears   = numyears % 4
  basedays    = basedays + (((LeapYears - Century) + QuadCentury) - 1)

  do i = 1 to (cmonth -1)
     if i <> "2" then
        basedays = basedays + NonLeap.i
     else /* find if it's a leap year or not */
        if (fullyear // 4) > 0 then
           basedays = basedays + 28
        else
           if ((fullyear // 100) = 0) & ((fullyear // 400) > 0) then
              do
                /* century not divisble by 400       */
                basedays = basedays + 28
              end /* if */
           else
              do
                /* quad century or regular leap year */
                basedays = basedays + 29
              end /* else */
  end /* do */

  basedays = basedays + cdate
return basedays
