/* REXX installation script for Auto WGet Daemon
 * Copyright (C) 1998-2003 Dmitry A.Steklenev
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
 * $Id: install.cms,v 1.62 2003/05/25 12:28:44 glass Exp $
 */

globals = "cfg. local. msg. sys. color. dir. jobs. job. plugins."

if translate( value( "AWGET_TRACE",, "OS2ENVIRONMENT" )) == "YES" then do
   call  value "AWGET_TRACE", "", "OS2ENVIRONMENT"
   trace intermediate
   trace results
end

cls ; call AwInit

say color.bold  || "Auto WGet Daemon " || color.usual || "Version 1.8.2 Installation"
say color.usual || "Copyright (C) 1998-2003 Dmitry A.Steklenev"
say color.usual || ""

call MsgRead  "awgmsg"
call CfgRead
call OsDelete "install.log"

/* Customizing of installation process */

country  = MsgCountryID()
instpath = cfg.home

if instpath == "." | \DirExist(cfg.home) then
   instpath =  ""

do while instpath == ""
   call charout, color.usual || ">>> "msg.install_dir": "
   parse pull instpath
end

instpath    = DirCanonical( instpath )
found_count = 0

/* We search for all download utilities known to us */

do i = 1 to sys.utils.0
   found = SysSearchPath( "PATH", sys.utils.i.prog )

   if found \= "" then do
      found_count = found_count + 1
      found_utils.found_count.name = sys.utils.i.name
      found_utils.found_count.parm = sys.utils.i.parm
      found_utils.found_count.prog = sys.utils.i.prog
      found_utils.found_count.path = found
   end
end

/* It is necessary to check up contains the configuration file
 * any unknown download utility
 */

if cfg.downloads_utility \= "" &,
   cfg.downloads_utility \= sys.utils.default.prog then do

   do i = 1 to found_count until,
      translate(cfg.downloads_utility) == translate(found_utils.i.prog)
   end
   if i > found_count then do
      found_utils.i.name = filespec( "name", cfg.downloads_utility )
      found_utils.i.parm = cfg.downloads_parameters
      found_utils.i.prog = translate(cfg.downloads_utility)
      found_utils.i.path = translate(cfg.downloads_utility)
      found_count = i
   end
end

if found_count == 0 then do
   /* The download utility is necessary for us */
   call LogDo err, msg.not_found_utils
   /* But WGet is used by default */
   found_utils.1.name = sys.utils.1.name
   found_utils.1.parm = sys.utils.1.parm
   found_utils.1.prog = sys.utils.1.prog
   found_utils.1.path = ""
   found_count = 1
end

if found_count == 1 then
   select = 1
else do
   /* Let's enable the user to select the download utility */

   max_len = 0
   do i = 1 to found_count
      max_len = max( max_len, length( found_utils.i.name ))
   end

   say color.usual || ">>> "msg.select_util ; say

   do i = 1 to found_count
      say color.bold  || "    "i ||,
          color.usual || " - "substr( found_utils.i.name, 1, max_len )"  ("found_utils.i.path")"
   end

   say ; select = MsgGetNum( "    "msg.select_number, 0, found_count )
end

if select == 0 then exit 0

if translate(cfg.downloads_utility) \= found_utils.select.prog then do
   cfg.downloads_utility    = found_utils.select.prog
   cfg.downloads_parameters = found_utils.select.parm
end

if VerLessThan( instpath, "1.8.2" ) then do
   cfg.downloads_utility    = found_utils.select.prog
   cfg.downloads_parameters = found_utils.select.parm
end

if cfg.log_file == "nul"  | translate(cfg.log_file ),
                == translate(instpath"\ToDo\Info\awget.log") then
   cfg.log_file  = instpath"\awget.log"

if cfg.error_log == "nul" | translate(cfg.error_log),
                 == translate(instpath"\ToDo\Info\awget_error.log") then
   cfg.error_log = instpath"\awget.err"

if cfg.download == "." | \DirExist(cfg.download) then do
   call charout, color.usual || ">>> "msg.download": "
   parse pull cfg.download
end

cfg.use_desktop       = (MsgYesNo( ">>> "msg.use_desktop       ) == 1)
cfg.check_connection  = (MsgYesNo( ">>> "msg.check_connection  ) == 1)
cfg.clipboard_monitor = (MsgYesNo( ">>> "msg.clipboard_monitor ) == 1)
cfg.home              = instpath

if MsgYesNo( ">>> "msg.log_prune ) == 0 then
   cfg.log_keep = 0
else if cfg.log_keep == 0 then
   cfg.log_keep = 15

parse version version
compile = left( version, 7 ) == "OBJREXX" &,
          SysSearchPath( "path", "rexxc.exe" ) \= ""

/* The beginning of installation */

cls
say color.bold  || "Auto WGet Daemon " || color.usual || "Version 1.8.2 Installation"
say color.usual || "Copyright (C) 1998-2003 Dmitry A.Steklenev"
say color.usual || ""

say CfgShow()

if MsgYesNo( color.usual">>> "msg.install ) == 0 then
   exit 0

cls
say color.bold  || "Auto WGet Daemon " || color.usual || "Version 1.8.2 Installation"
say color.usual || "Copyright (C) 1998-2003 Dmitry A.Steklenev"
say color.usual || ""
say AwStop()

/* Create of installation directorys */

if \CreateDirectory( instpath           ) then call terminate
if \CreateDirectory( instpath"\NLS"     ) then call terminate
if \CreateDirectory( instpath"\Icons"   ) then call terminate
if \CreateDirectory( instpath"\Plugins" ) then call terminate
if \CreateDirectory( instpath"\Folders" ) then call terminate
if \CreateDirectory( cfg.download       ) then call terminate

/* Updating the configuration file */

call CfgSave
call LogDo inf, msg.config_updated": "sys.config_file

/* Copying files */

if \CopyFile( "Icons\awget.ico"  , instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgadd.ico" , instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awghome.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgfold.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgactv.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgdone.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgfail.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgtodo.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awglogs.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgstop.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgedit.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\uninstl.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgread.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgurls.ico", instpath"\Icons" ) then call terminate
if \CopyFile( "Icons\awgdnte.ico", instpath"\Icons" ) then call terminate

if compile then do
   if \CopyFile( "awgetd.cmd"    , instpath"\*.rex" ) then call terminate
   if \CopyFile( "awgadd.cmd"    , instpath"\*.rex" ) then call terminate
   if \CopyFile( "awgexec.cmd"   , instpath"\*.rex" ) then call terminate
   if \CopyFile( "awgstop.cmd"   , instpath"\*.rex" ) then call terminate
   if \CopyFile( "uninstl.cmd"   , instpath"\*.rex" ) then call terminate
   end
else do
   if \CopyFile( "awgetd.cmd"    , instpath         ) then call terminate
   if \CopyFile( "awgadd.cmd"    , instpath         ) then call terminate
   if \CopyFile( "awgexec.cmd"   , instpath         ) then call terminate
   if \CopyFile( "awgstop.cmd"   , instpath         ) then call terminate
   if \CopyFile( "uninstl.cmd"   , instpath         ) then call terminate
end

if \CopyFile( "traceit.cmd"      , instpath         ) then call terminate
if \CopyFile( "changes"          , instpath         ) then call terminate
if \CopyFile( "license"          , instpath         ) then call terminate
if \CopyFile( "pmpopup2.eng"     , instpath         ) then call terminate
if \CopyFile( "pmpopup2.ger"     , instpath         ) then call terminate
if \CopyFile( "pmpopup2.exe"     , instpath         ) then call terminate
if \CopyFile( "awgclp.exe"       , instpath         ) then call terminate
if \CopyFile( "NLS\readme.001"   , instpath         ) then call terminate
if \CopyFile( "NLS\donate.001"   , instpath"\NLS"   ) then call terminate

if \CopyFile( "Plugins\awpglob.cmd", instpath"\Plugins" ) then call terminate
if \CopyFile( "Plugins\awppriv.cmd", instpath"\Plugins" ) then call terminate

call SysFileTree "NLS\awgmsg.*", 'nls', 'FO'
do i = 1 to nls.0
   if \CopyFile( "NLS\"filespec( "name", nls.i ), instpath"\NLS" ) then
      call terminate
end

if stream( "NLS\readme."country, "c", "query exist" ) \= "" then
   if \CopyFile( "NLS\readme."country, instpath ) then
      call terminate

if stream( "NLS\donate."country, "c", "query exist" ) \= "" then
   if \CopyFile( "NLS\donate."country, instpath"\NLS" ) then
      call terminate

if stream( "NLS\license."country, "c", "query exist" ) \= "" then
   if \CopyFile( "NLS\license."country, instpath ) then
      call terminate

/* Wait for unlocking awget.dll */

if \RxFuncQuery('AwDropFuncs') then
   call AwDropFuncs
if \RxFuncQuery('AwLoadFuncs') then
   call RxFuncDrop 'AwLoadFuncs'

do 10 until stream( instpath"\awget.dll", "c", "query exists" ) == ""
   rc = stream( instpath"\awget.dll", "c", sys.open_write )
   if rc == "READY:" then do
      rc = stream( instpath"\awget.dll", "c", "close" )
      leave
   end
   call SysSleep 1
end

if \CopyFile( "awget.dll", instpath ) then call terminate

/* Remove of out-of-date files */

files = "vwin.eng  vwin.exe  awget.ico info.ico  awget.msg " ||,
        "awget.001 awget.033 awget.039 awget.049 awget.950 " ||,
        "awget.007 awget.046 awget.048 awget.eng awget.rus " ||,
        "awget.tw  awget.pl  "                               ||,
        "Icon\todo.ico   Icon\run.ico     Icon\done.ico    " ||,
        "Icon\failed.ico Icon\info.ico    Icon\add.ico     " ||,
        "Icon\awget.ico  Icon\uninstl.ico Icon\infoold.ico " ||,
        "awgets.cmd install.cmd"

do i = 1 to words(files)
   old_file = instpath"\"word(files,i)

   if stream( old_file, "c", "query exists" ) \= "" then do
      call OsDelete old_file
      call LogDo inf, msg.erase_done": "old_file
   end
end

/* Migration from pre 1.6.0 versions */

call SysDestroyObject "<AWG_LOCK>"
call SysDestroyObject "<AWG_TODO>"

if DirExist( instpath"\Icon" ) then
   call SysRmDir instpath"\Icon"

/* Migration from 1.6.0 version */

if DirExist( instpath"\ToDo" ) then do
   if \CreateDirectory( instpath"\Folders" ) then call terminate

   call SysMoveObject "<AWG2_TODO>"   , instpath"\Folders"
   call SysMoveObject "<AWG2_RUNNING>", instpath"\Folders"
   call SysMoveObject "<AWG2_DONE>"   , instpath"\Folders"
   call SysMoveObject "<AWG2_FAILED>" , instpath"\Folders"
   call SysMoveObject "<AWG2_JOBS>"   , instpath"\Folders"
end

/* Compile REXX files */

if compile then do
   if \CompileFile( instpath"\awgetd.rex" , instpath"\awgetd.cmd"  ) then call terminate
   if \CompileFile( instpath"\awgadd.rex" , instpath"\awgadd.cmd"  ) then call terminate
   if \CompileFile( instpath"\awgexec.rex", instpath"\awgexec.cmd" ) then call terminate
   if \CompileFile( instpath"\awgstop.rex", instpath"\awgstop.cmd" ) then call terminate
   if \CompileFile( instpath"\uninstl.rex", instpath"\uninstl.cmd" ) then call terminate
end

/* Create Folders and Objects */

if SysOs2Ver() > "2.30" then
   fld_class = "WPUrlFolder"
else
   fld_class = "WPFolder"

call CreateObject "U", "WPFolder", msg.obj_home,,
                  "<WP_DESKTOP>",,
                  "OBJECTID=<AWG2_HOME>;"                     ||,
                  "DEFAULTVIEW=TREE;"                         ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "ICONFILE="instpath"\Icons\awghome.ico;"

call CreateObject "U", "WPFolder", msg.obj_downloads,,
                  "<AWG2_HOME>",,
                  "OBJECTID=<AWG2_DOWNLOADS>;"                ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "DEFAULTVIEW=ICON;"                         ||,
                  "ICONFILE="instpath"\Icons\awgfold.ico;"

call CreateObject "U", "WPFolder", msg.obj_tools,,
                  "<AWG2_HOME>",,
                  "OBJECTID=<AWG2_TOOLS>;"                    ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "DEFAULTVIEW=ICON;"                         ||,
                  "ICONFILE="instpath"\Icons\awgfold.ico;"

call CreateObject "U", "WPFolder", msg.obj_info,,
                  "<AWG2_HOME>",,
                  "OBJECTID=<AWG2_INFO>;"                     ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "DEFAULTVIEW=ICON;"                         ||,
                  "ICONFILE="instpath"\Icons\awgfold.ico;"

call CreateObject "U", "WPFolder", msg.obj_jobs,,
                  instpath"\Folders",,
                  "OBJECTID=<AWG2_JOBS>;"                     ||,
                  "DEFAULTVIEW=DETAILS;"                      ||,
                  "NOTVISIBLE=YES"

call CreateObject "U", fld_class, msg.obj_todo,,
                  instpath"\Folders",,
                  "OBJECTID=<AWG2_TODO>;"                     ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "DEFAULTVIEW=DETAILS;"                      ||,
                  "DETAILSTODISPLAY=0,1,9,10,12;"             ||,
                  "ALWAYSSORT=YES;"                           ||,
                  "DEFAULTSORT=11;"                           ||,
                  "ICONFILE="instpath"\Icons\awgtodo.ico;"

call CreateObject "U", fld_class, msg.obj_running,,
                  instpath"\Folders",,
                  "OBJECTID=<AWG2_RUNNING>;"                  ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "DEFAULTVIEW=DETAILS;"                      ||,
                  "DETAILSTODISPLAY=0,1,9,10,12;"             ||,
                  "ALWAYSSORT=YES;"                           ||,
                  "DEFAULTSORT=11;"                           ||,
                  "ICONFILE="instpath"\Icons\awgactv.ico;"

call CreateObject "U", fld_class, msg.obj_done,,
                  instpath"\Folders",,
                  "OBJECTID=<AWG2_DONE>;"                     ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "DEFAULTVIEW=DETAILS;"                      ||,
                  "DETAILSTODISPLAY=0,1,9,10,12;"             ||,
                  "ALWAYSSORT=YES;"                           ||,
                  "DEFAULTSORT=11;"                           ||,
                  "ICONFILE="instpath"\Icons\awgdone.ico;"

call CreateObject "U", fld_class, msg.obj_failed,,
                  instpath"\Folders",,
                  "OBJECTID=<AWG2_FAILED>;"                   ||,
                  "SHOWALLINTREEVIEW=YES;"                    ||,
                  "DEFAULTVIEW=DETAILS;"                      ||,
                  "DETAILSTODISPLAY=0,1,9,10,12;"             ||,
                  "ALWAYSSORT=YES;"                           ||,
                  "DEFAULTSORT=11;"                           ||,
                  "ICONFILE="instpath"\Icons\awgfail.ico;"

call CreateObject "R", "WPShadow", msg.obj_todo,,
                  "<WP_DESKTOP>",,
                  "SHADOWID=<AWG2_TODO>"
call CreateObject "R", "WPShadow", msg.obj_todo,,
                  "<AWG2_DOWNLOADS>",,
                  "SHADOWID=<AWG2_TODO>"
call CreateObject "R", "WPShadow", msg.obj_running,,
                  "<AWG2_DOWNLOADS>",,
                  "SHADOWID=<AWG2_RUNNING>"
call CreateObject "R", "WPShadow", msg.obj_done,,
                  "<AWG2_DOWNLOADS>",,
                  "SHADOWID=<AWG2_DONE>"
call CreateObject "R", "WPShadow", msg.obj_failed,,
                  "<AWG2_DOWNLOADS>",,
                  "SHADOWID=<AWG2_FAILED>"

call CreateObject "U", "WPProgram", msg.obj_daemon,,
                  "<AWG2_TOOLS>",,
                  "OBJECTID=<AWG2_DAEMON>;"                   ||,
                  "EXENAME="instpath"\AWGETD.CMD;"            ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "MINIMIZED=YES;"                            ||,
                  "ICONFILE="instpath"\Icons\awget.ico;"

call CreateObject "R", "WPShadow", msg.obj_daemon,,
                  "<WP_START>",,
                  "SHADOWID=<AWG2_DAEMON>;"

call CreateObject "U", "WPProgram", msg.obj_uninstall,,
                  "<AWG2_TOOLS>",,
                  "OBJECTID=<AWG2_UNINSTALL>;"                ||,
                  "EXENAME=*;"                                ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PROGTYPE=WINDOWABLEVIO;"                   ||,
                  "ICONFILE="instpath"\Icons\uninstl.ico;"    ||,
                  'PARAMETERS=/C start "Uninstall Auto WGet Daemon" /C/F 'instpath'\UNINSTL.CMD;'

call CreateObject "U", "WPProgram", msg.obj_editcfg,,
                  "<AWG2_TOOLS>",,
                  "OBJECTID=<AWG2_EDITCFG>;"                  ||,
                  "EXENAME=E.EXE;"                            ||,
                  "PROGTYPE=PM;"                              ||,
                  "PARAMETERS="sys.config_file";"             ||,
                  "ICONFILE="instpath"\Icons\awgedit.ico;"

call CreateObject "U", "WPProgram", msg.obj_stop,,
                  "<AWG2_TOOLS>",,
                  "OBJECTID=<AWG2_STOP>;"                     ||,
                  "EXENAME="instpath"\AWGSTOP.CMD;"           ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "ICONFILE="instpath"\Icons\awgstop.ico;"

call CreateObject "U", "WPProgram", msg.obj_evtlog,,
                  "<AWG2_TOOLS>",,
                  "OBJECTID=<AWG2_EVTLOG>;"                   ||,
                  "EXENAME=E.EXE;"                            ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PARAMETERS="cfg.log_file";"                ||,
                  "ICONFILE="instpath"\Icons\awglogs.ico;"

call CreateObject "U", "WPProgram", msg.obj_errlog,,
                  "<AWG2_TOOLS>",,
                  "OBJECTID=<AWG2_ERRLOG>;"                   ||,
                  "EXENAME=E.EXE;"                            ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PARAMETERS="cfg.error_log";"               ||,
                  "ICONFILE="instpath"\Icons\awglogs.ico;"

call CreateObject "U", "WPProgram", msg.obj_add,,
                  "<AWG2_TOOLS>",,
                  "OBJECTID=<AWG2_ADD>;"                      ||,
                  "EXENAME=*;"                                ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PROGTYPE=PM;"                              ||,
                  "ICONFILE="instpath"\Icons\awgadd.ico;"     ||,
                  'PARAMETERS=/C awgadd.cmd'

call CreateObject "U", "WPProgram", msg.obj_readme_en,,
                  "<AWG2_INFO>",,
                  "EXENAME=E.EXE;"                            ||,
                  "OBJECTID=<AWG2_README_EN>;"                ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PARAMETERS="instpath"\readme.001;"         ||,
                  "ICONFILE="instpath"\Icons\awgread.ico;"

if stream( instpath"\readme."country, "c", "query exist" ) \= "" then do
   call CreateObject "R", "WPProgram", msg.obj_readme,,
                  "<AWG2_INFO>",,
                  "EXENAME=E.EXE;"                            ||,
                  "OBJECTID=<AWG2_README>;"                   ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PARAMETERS="instpath"\readme."country";"   ||,
                  "ICONFILE="instpath"\Icons\awgread.ico;"
   end
else
   call SysDestroyObject "<AWG2_README>"

call CreateObject "U", "WPProgram", msg.obj_changes_en,,
                  "<AWG2_INFO>",,
                  "EXENAME=E.EXE;"                            ||,
                  "OBJECTID=<AWG2_CHANGES_EN>;"               ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PARAMETERS="instpath"\changes;"            ||,
                  "ICONFILE="instpath"\Icons\awgread.ico;"

call CreateObject "R", "WPProgram", msg.obj_license_en,,
                  "<AWG2_INFO>",,
                  "EXENAME=E.EXE;"                            ||,
                  "OBJECTID=<AWG2_LICENSE_EN>;"               ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PARAMETERS="instpath"\license;"            ||,
                  "ICONFILE="instpath"\Icons\awgread.ico;"

if stream( instpath"\license."country, "c", "query exist" ) \= "" then do
   call CreateObject "R", "WPProgram", msg.obj_license,,
                  "<AWG2_INFO>",,
                  "EXENAME=E.EXE;"                            ||,
                  "OBJECTID=<AWG2_LICENSE>;"                  ||,
                  "STARTUPDIR="instpath";"                    ||,
                  "PARAMETERS="instpath"\license."country";"  ||,
                  "ICONFILE="instpath"\Icons\awgread.ico;"
   end
else
   call SysDestroyObject "<AWG2_LICENSE>"

if SysOs2Ver() > "2.30" then do
   call CreateObject "U", "WPUrl", msg.obj_url_ru,,
                  "<AWG2_INFO>",,
                  "OBJECTID=<AWG2_URL_RU>;"                   ||,
                  "ICONFILE="instpath"\Icons\awgurls.ico;"    ||,
                  "URL=http://glass.os2.spb.ru/software/awget.html"

   call CreateObject "U", "WPUrl", msg.obj_url_en,,
                  "<AWG2_INFO>",,
                  "OBJECTID=<AWG2_URL_EN>;"                   ||,
                  "ICONFILE="instpath"\Icons\awgurls.ico;"    ||,
                  "URL=http://glass.os2.spb.ru/software/english/awget.html"

   if stream( instpath"\NLS\donate."country, "c", "query exist" ) \= "" then
      donate_url = instpath"\NLS\donate."country
   else
      donate_url = instpath"\NLS\donate.001"

   call CreateObject "U", "WPUrl", msg.obj_donate,,
                  "<AWG2_INFO>",,
                  "OBJECTID=<AWG2_DONATE>;"                   ||,
                  "ICONFILE="instpath"\Icons\awgdnte.ico;"    ||,
                  "URL="donate_url
end

call lineout  instpath"\"sys.rebuild, "Fresh blood!"
call stream   instpath"\"sys.rebuild, 'c', 'close'
call OsDelete instpath"\version"
call lineout  instpath"\version", "1.8.2"
call stream   instpath"\version", 'c', 'close'

call SysSetObjectData "<AWG2_DAEMON>", "OPEN=DEFAULT"

say color.info || "þþþ "msg.started
say color.info || "þþþ Done!" || color.usual
exit 0

/*------------------------------------------------------------------
 * Create directory
 *------------------------------------------------------------------*/
CreateDirectory: procedure expose (globals)

 parse arg path
 rc = 0

 if \DirExist( path ) then do
    rc = DirCreate( path )

    if rc == 0 then
       call LogDo inf, msg.dir_done  || ": "path
    else
       call LogDo err, msg.dir_error || ": "path", rc="rc
 end
return rc == 0

/*------------------------------------------------------------------
 * Copy file
 *------------------------------------------------------------------*/
CopyFile: procedure expose (globals)

 parse arg from, to
 rc = OsCopy( from, to )

 if rc == 0 then
    call LogDo inf, msg.copy_done  || ": "from
 else
    call LogDo err, msg.copy_error || ": "from", rc="rc
return rc == 0

/*------------------------------------------------------------------
 * Compile REXX file
 *------------------------------------------------------------------*/
CompileFile: procedure expose (globals)

 parse arg from, to
 "rexxc "from to" 1> nul 2>nul"

 if rc == 0 then
    call LogDo inf, msg.compile_done  || ": "from
 else
    call LogDo err, msg.compile_error || ": "from", rc="rc
return rc == 0

/*------------------------------------------------------------------
 * Create WPS object
 *------------------------------------------------------------------*/
CreateObject: procedure expose (globals)

   parse arg action, class, objname, folder, prmstr

   rc = SysCreateObject( class, replace( objname, "\n", "0D0A"x ),,
                                         folder, prmstr, action )

   objname = replace( objname, "\n"   , " " )
   objname = replace( objname, '0D0A'x, " " )

   if rc then
      call LogDo inf, msg.object_done  || " "substr(class,1,12) || ": "objname
   else
      call LogDo err, msg.object_error || " "substr(class,1,12) || ": "objname
return rc

/*------------------------------------------------------------------
 * Terminate installation
 *------------------------------------------------------------------*/
terminate: procedure expose (globals)

  call beep 1000, 100
  call LogDo err, msg.install_aborted
  exit 1
return

/*------------------------------------------------------------------
 * Write Log Record
 *------------------------------------------------------------------*/
LogDo: procedure expose (globals)

  parse arg type, message
  type = translate(type)

  if type == "INF" then type = "INFO"
  if type == "ERR" then type = "ERROR"

  rc = stream( "install.log", "c", "open write" )
  call lineout "install.log", replace( message, '0D0A'x, '0D0A'x || copies( ' ', 21 ))
  rc = stream( "install.log", "c", "close" )

  say color.type"þþþ " ||,
      replace( message, '0D0A'x, '0D0A'x || copies( ' ', 4 )) || color.usual

return ""

/*------------------------------------------------------------------
 * Compare versions
 *------------------------------------------------------------------*/
VerLessThan: procedure expose (globals)

  parse arg instpath, version

  current = linein( instpath"\version" )
  rc = stream( instpath"\version", "c", "close" )

  parse value current with cur.major "." cur.minor "." cur.level
  parse value version with ver.major "." ver.minor "." ver.level

  if cur.major < ver.major then
     return 1
  if cur.major > ver.major then
     return 0
  if cur.minor < ver.minor then
     return 1
  if cur.minor > ver.minor then
     return 0
  if cur.level < ver.level then
     return 1

return 0

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

/*------------------------------------------------------------------
 * Get numeric value
 *------------------------------------------------------------------*/
MsgGetNum: procedure expose (globals)

  parse arg prompt, min, max
  ok = 0

  do until ok
     call charout, prompt"? "
     pull reply

     ok = datatype( reply, "NUMBER" ) & reply >= min & reply <= max
  end

return reply

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
 * Save Configuration
 *------------------------------------------------------------------*/
CfgSave: procedure expose (globals)

  rc = stream( sys.config_file, "C", sys.open_read )

  do i = 1 while lines(sys.config_file) > 0
     body.i = linein(sys.config_file)
  end
  body.0 = i - 1
  rc = stream( sys.config_file, "C", "CLOSE" )

  key_list = CfgKeys()

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

     if cfg.key \= "nul" then do
        if j > body.0 then do
           comment = "CFG_"  || key
           body.j  = "# "replace( msg.comment, "0D0A"x, "0D0A"x || "# " ) ||,
                     "0D0A"x || "0D0A"x || key "=" cfg.key || "0D0A"x
           end
        else
           body.j = key "=" cfg.key

        if j > body.0 then
          body.0 = j
     end
  end i

  rc = OsDelete( sys.config_file )
  rc = stream( sys.config_file, "C", sys.open_write )

  do j = 1 to body.0
     parse value body.j with keyword "="
     keyword  = translate(strip(keyword))

     /* remove out-date key values */
     if keyword \= "MAXIMUM_DOWNLOADS_SIMULTANEOUSLY" &,
        keyword \= "WGET_PARAMETERS" then
        call lineout sys.config_file, body.j
  end

  rc = stream( sys.config_file, "C", "CLOSE" )
return


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
