/*------------------------------------------------------------------
 * miniftp.cmd :
 *------------------------------------------------------------------
 * 03-16-93 originally by Patrick J. Mueller & Cliff Nadler
 *------------------------------------------------------------------
 * maxiftp.cmd:
 *------------------------------------------------------------------
 *   by Albert L. Crosby <acrosby@comp.uark.edu> with
 *       suggestions by many people on the internet.
 *   This work is freely redistributeable,  Please forward any
 *    suggestions or enhancements to me and I'll incorporate them
 *    in a future release.
 *------------------------------------------------------------------ */

/*------------------------------------------------------------------
 * set up call
 *------------------------------------------------------------------*/
call on halt
call on error

parse arg xargs

/* Add anything in the environment variable MAXIFTP */
xargs=strip(value('MAXIFTP',,'OS2ENVIRONMENT')||" "||xargs)

/* Build a blank delimited list of command line options */

args=" "

if pos(left(xargs,1),"/-")<>0 then
   do
   rest=xargs
   do until pos(left(rest,1),"/-")=0
      parse var rest argument rest
      if pos('"',argument)<>0 & right(argument,1)\='"' then
         do
         parse var rest remainder'"' rest
         argument=argument||' '||remainder||'"'
         end
      args=args||" "||substr(argument,2)
      rest=strip(rest)
   end
   parse var rest host rest
   if pos('"',host)<>0 then
      do
      parse var rest rest'"' user pass .
      host=host||" "||rest||'"'
      end
   else parse var rest user pass .
   end
else
   do
   parse var xargs host rest
   if pos('"',host)<>0 & right(host,1)\='"' then
      do
      parse var rest rest'"' user pass .
      host=host||" "||rest||'"'
      end
   else parse var rest user pass .
   end

call LoadFunctions

parse value SysTextScreenSize() with rows cols

debug=0

"@echo off"
"ansi on > nul"

trace off

version="MaxiFTP version 3 BETA revision 191"
credits.0=3
credits.1="by Albert Crosby, 02/18/94"
credits.2="(based on original code by Patrick J. Mueller & Cliff Nadler of IBM"
credits.3="    and additional suggestions from Al Dhir's sFTP)"
/* List of filetypes currently assumed to be binary for get and put */
binaries=value("BINARIES",,"OS2ENVIRONMENT")
if binaries="" then
   binaries="EXE COM ZIP SYS DLL DEV ARJ ARC Z TAR GZ BIN DSK LZH ARK LBR JPG JPEG GIF PCX "
asciis=value("ASCIIS",,"OS2ENVIRONMENT")
if asciis="" then
   asciis="TXT"

!history.0=0
hostname=""
run.extensions=""
phost=""
origdir=directory()
mode="ASCII"
delay=20
clobber=0
hostlist.0=0
prompt=1
display=0
unique=0
quiet=0
ask=0
touch=0
netrc=1
visual=0
macros=1
retries=1
longname=1
comment=1
bell=1
remember=1
dircmd="dir"
viscmd="get"
greenonblack=d2c(27)||"[1;32m"
normvideo=d2c(27)||"[0m"
inversevideo=d2c(27)||"[7m"
boldvideo=d2c(27)||"[1m"
promptstr='progname||" ["||boldvideo||phost||":"||dirname||normvideo"] "'

stem.0=1
stem.1="No directory has been transferred - issue a ls or dir command."

pager=value('pager',,'os2environment')
if pager="" then pager=more

parse source . . name
parse value filespec('name',name) with progname".".

call ProcessINI filespec('drive',name)||filespec('path',name)||progname||'.ini' 
memoryfile=value("ETC",,"OS2ENVIRONMENT")||"\MAXIFTP.DIR"

if translate(progname)=="VISFTP" then visual=1

if hostname="" | hostname="HOST.!NAME" then hostname=value("HOSTNAME",,"OS2ENVIRONMENT")

anonpass="os2user"||"@"||hostname

netrcfile=stream('netrc','c','query exists')
if netrcfile="" then
   netrcfile=value("ETC",,"OS2ENVIRONMENT")||"\NETRC"

if (pos(" N-",args)=0) & (pos(" M-",args)=0) then Call ProcessNETRC

call ProcessArgs args

if \quiet then call Credits

if (host="?") then
   do
   call Usage "INTRO"
   exitcode=0
   signal done
   end

oq=quiet; 
quiet=1
call Mode mode
quiet=oq

if pos("@",host)<>0 then
   do
   pass=user
   parse var host user"@"host
   end

request=""

if pos(":",host)<>0 then parse var host host":"request
if pos('"',request)<>0 then parse var request '"'request'"'

if visual & (request="") then 
   do
   visual=visinit()
   if visual then signal visftp
   end

if host = "" then
   do
   say "Welcome to "version
   say
   say "Type HELP for more information and HELP NEWS for an overview"
   say
   call Usage "CONNECT"
   say
   end

if (host <> "") then
   call Connect

if request<>"" then
   do
   if host="" then exit -1;
   prompt=0
   clobber=1
   /* Reprocess args to handle different defaults for colon-mode */
   oquiet=quiet
   quiet=1
   call ProcessArgs args
   quiet=oquiet

   if display then call QueryStatus

   /* If request contains wildcards, do an mget */
   if verify(request,"*?","MATCH")<>0 then
      err=mget(request)
   else err=get(request)
   exitcode=err
   signal done
   end

do while (cmd <> "QUIT") & (cmd <> "EXIT") & (cmd <> "BYE")


/* Modified so default directory is not queried if not connected to
   a host.  This seemed rather pointless to me... */


   if (host = "") then
      do
         status = "not connected to a host"
         dir = ""
         phost="not connected"
      end
   else status = "connected to" user"@"host

if display then Call DisplayStatus

/* Moved displaying the prompt until AFTER the status is displayed. */

   /*---------------------------------------------------------------
    * print prompt
    *---------------------------------------------------------------*/
   Call SysCurState("ON")
   if pos('"',dir)<>0 then parse var dir '"'dirname'"'.
   else dirname=dir

   /*---------------------------------------------------------------
    * get command
    *---------------------------------------------------------------*/
   if queued()=0 then 
      do
      interpret "Call Charout," promptstr
      parse value CmdLine() with cmd cmdargs
      end
   else parse pull cmd cmdargs

   err=ProcessCMD(cmd, cmdargs)

   if (cmd="CD") | (cmd="CDUP") then
      err = FtpPwd('dir')

   /*------------------------------------------------------------------
    * check error
    *------------------------------------------------------------------*/
   /* Appears to be an error in error handling....  err may be -1 with
      FTPERRNO of 0 */
   if (err <> 0) & (ftperrno <>0) then
      do
      say "Error from FTP:" english(FTPERRNO) "["err"]"
      if ftperrno="FTPCONNECT" then
         do
         say "Remote server closed connection."
         host=""
         phost=""
         dir=""
         end
      end

end

/*------------------------------------------------------------------
 * quit
 *------------------------------------------------------------------*/

exitcode=0

done:
rc = FtpSetUser("X","X","X")
rc = FtpLogoff()
call directory origdir
/* Empty the queue in case any macro commands are pending. */
do queued()
   parse pull .
end
exit exitcode

/*****
 * External error condition
******/

Error:
   return

/*------------------------------------------------------------------
 * break condition
 *------------------------------------------------------------------*/
halt:
   say
   if cmdline("T=Do you really want to quit (yes|no)? ","U","V=YN","R")="N" 
      then return;
   say "Terminating ..."
   exitcode=-1
   signal done

get: procedure expose debug binaries file2 clobber quiet touch dir longname comment host user bell visual asciis run.

parse arg remotefile, localfile, mode

curdir=dir
globbed=0
pipe=0

if remotefile=localfile then localfile=""

if translate(localfile)="CON" | translate(localfile)="CON:" then
   localfile="-"

if verify(remotefile,"*?","MATCH")<>0 then /* It's a wildcard request */
   do
   err=FtpLS(remotefile,'files.')
   if files.0=0 then
      do
      if \quiet then say "No files matching "remotefile" can be found."
      return -2
      end
   remotefile=files.1
   end

if wordpos(extension(remotefile),binaries)\=0 then
   if mode="" then mode="BINARY"

if wordpos(extension(remotefile),asciis)\=0 then
   if mode="" then mode="ASCII"

if remotefile="." then
   do
   remotefile=CmdLine("T=Remote file: ","No History")
   if remotefile="" then return -1
   localfile=CmdLine("T=Local file: ","No History")
   end

if left(localfile,1)="|" then 
   do 
   pipe=1
   destination=substr(localfile,2)
   localfile=systempfilename("tmp?????")
   end

if left(localfile,1)=">" then
   do
   say "Redirection not supported.  Use GET remotefile localfile instead."
   return -2
   end

ndir = filespec('drive',remotefile)||filespec('path',remotefile)
if ndir<>"" then
   do
   err=FtpPWD('olddir')
   err=FtpChDir(ndir)
   err=FtpPWD('curdir')
   if pos('"',olddir)<>"" then parse var olddir '"'olddir'"'.
   if pos('"',curdir)<>"" then parse var curdir '"'curdir'"'.
   end
request=remotefile
remotefile=filespec('name',remotefile)

err=FtpDir(remotefile,'files.')
if files.0=0 then
   do
   if dir<>"" then junk=FtpChDir(olddir)
   say "Remote file "request" does not exist."
   return -2
   end

if localfile="" then localfile=remotefile

if \pipe then
do
"dir "localfile" 1>nul 2>nul"
if (rc=123) | (rc=206) then /* File name isn't valid... */
   do
   if left(localfile,1)="." then localfile="_"||substr(localfile,2)
   if pos('.',localfile)<>0 then
      localfile=translate(translate(strip(left(left(localfile,lastpos('.',localfile)-1),8)),'__','. ')||"."||strip(left(extension(localfile),3)))
   else localfile=translate(translate(strip(left(localfile,8)),'__','. '))
   if stream(localfile,'c','query exists')<>"" then
      do
      say "Unable to generate a unique local name for the transfer."
      say "Specify a local name on the get command and try again."
      return -1
      end
   globbed=1
   end

if \quiet & localfile\="-" then say "Transferring "request" as "localfile" ..."
else if \quiet then say "Contents of "request":"
end
else if \quiet then say "Piping "request" to "destination" ..."

file2=localfile

if (\clobber) & (stream(localfile,"C","QUERY EXISTS")<>"") then
   if \visual then
      do
      call Charout, localfile || " already exists.  Replace (yes|no)? "
      do until pos(translate(key),"YN")<>0
         key=SysGetKey("NoECHO")
      end
      say key
      if translate(key)="N" then return 1;
      end
   else if vmsg("File Exists",localfile || " already exists.  Replace?  ",6)=="NO" then return 1;

call time "r"

if mode\="" then
   err=FtpGet(localfile,remotefile,mode)
else err=FtpGet(localfile,remotefile)

elapsed = strip(format(time("e"),10,2))
bytes = stream(localfile,"C","QUERY SIZE")
if \quiet & (elapsed<>0) & (datatype(bytes)="NUM") then
   say "Recieved" bytes "bytes in" elapsed "seconds:" strip(format(bytes/elapsed,10,2))  "bytes/second."
if \quiet & bell then call beep 278,200

if ndir<>"" then junk=FtpChDir(olddir)

if \pipe then
   do
   if stream(localfile,"C","QUERY EXISTS")="" then return -2
   if touch then
      call touch files.1, localfile
   
   if globbed & longname then
       call PutLong localfile, remotefile
   
   if comment then
      call PutComment localfile, user, host, curdir, remotefile

   if localfile="" then localfile=remotefile
   !ext!=extension(localfile)
   if wordpos(translate(!ext!),translate(run.extensions))\=0 then
      do
      oldfn=value('fn',localfile,'OS2ENVIRONMENT')
      oldrn=value('rn',remotefile,'OS2ENVIRONMENT')
      oldext=value('ext',!ext!,'OS2ENVIRONMENT')
      !ext!=extension(localfile)
      "call "run.!ext!
      call value 'fn',oldfn,'OS2ENVIRONMENT'
      call value 'rn',oldrn,'OS2ENVIRONMENT'
      call value 'ext',oldext,'OS2ENVIRONMENT'
      end

   end
else /* It's a pipe */
   do
   call stream localfile,'C','CLOSE'
   destination||"<"||localfile
   call SysFileDelete localfile
   end

return err

put: procedure expose debug binaries unique quiet bell visual

parse arg localfile, remotefile, lunique

if remotefile="" then remotefile=localfile
if remotefile="" | remotefile="." then
   do
   say "You must specify a file name!"
   return
   end
remotefile=filespec('name',remotefile)
if \quiet then say "Transferring "localfile" as "remotefile" ..."

call time "r"

if (unique) | (lunique=1) then
   if wordpos(extension(localfile),binaries)=0 then
      err = FtpPutUnique(localfile,remotefile)
   else err=FtpPutUnique(localfile,remotefile,"BINARY")
else if wordpos(extension(localfile),binaries)=0 then
      err = FtpPut(localfile,remotefile)
   else err=FtpPut(localfile,remotefile,"BINARY")

elapsed = strip(format(time("e"),10,2))
bytes = stream(localfile,"C","QUERY SIZE")
if \quiet & (elapsed<>0) & (datatype(bytes)="NUM") then
   say "Transmitted" bytes "bytes in" elapsed "seconds:" strip(format(bytes/elapsed,10,2))  "bytes/second."

if \quiet & bell then call beep 278,200

return err

extension: procedure

arg filename
/* If no period or only period is first char, then return "" */
if lastpos(".",filename)<2 then return ""
return substr(right(filename,pos(".",reverse(filename))),2)

mget: procedure expose debug binaries file2 clobber quiet touch dir longname comment host user prompt bell visual run.

parse arg spec, dest

if dest\="" then 
   if left(dest,1)\="|" & (dest\="-") then
   do
   say "Destination for MGET can only be a pipe."
   return -1
   end

if \quiet then say "Transferring file list..."
if spec="" then spec="."
err=FtpLS(spec,'files.')
if \quiet then say files.0 "files requested."
all=\prompt
do i=1 to files.0
   if prompt & \all then
      do
      if \visual then
      do
         Call Charout, "Get "files.i" (yes|no|all|quit)? "
         do until pos(translate(key),"YNAQ")<>0
            key=SysGetKey("NoEcho")
         end
         say key
         key=translate(key)
         select
            when key="Y" | key="A" then
               do
               err=get(files.i,dest)
               if key="A" then all=\all
               end
            when key="Q" then leave
            otherwise nop;
         end
      end
      else if vmsg("Multiple File Request","Get "||files.i||"? ",6)=="YES" then err=get(files.i)
      end
   else err=get(files.i,dest)
end
if \quiet then say "Transfer complete."
return 0

mput: procedure expose debug prompt clobber unique quiet bell visual

parse arg spec

if \quiet then say "Obtaining file list..."
if spec="" then spec="."
if spec="." then spec="*"
rc=SysFileTree(spec, "files.", "FO")
if \quiet then say files.0 "files to be transferred."
all=\prompt
do i=1 to files.0
   if prompt & \all then
      do
      if \visual then
         do
         Call Charout, "Put "files.i" (yes|no|all|quit)? "
         do until pos(translate(key),"YNAQ")<>0
            key=SysGetKey("NoEcho")
         end
         say key
         key=translate(key)
         select
            when key="Y" | key="A" then
               do
               err=put(files.i)
               if key="A" then all=\all
               end
            when key="Q" then leave
            otherwise nop;
         end
         end
      else if vmsg("Multiple File Request","Put "||files.i||"? ",6)=="YES" then err=get(files.i)
      end
   else err=put(files.i)
end
if \quiet then say "Transfer complete."
return 0

english: procedure

arg code

select
   when code="FTPSERVICE"     then phrase="unknown service"
   when code="FTPHOST"        then phrase="unknown host"
   when code="FTPSOCKET"      then phrase="unable to obtain socket"
   when code="FTPCONNECT"     then phrase="unable to connect to server"
   when code="FTPLOGIN"       then phrase="login failed"
   when code="FTPABORT"       then phrase="transfer aborted"
   when code="FTPLOCALFILE"   then phrase="problem openning local file"
   when code="FTPDATACONN"    then phrase="problem initializing data connection"
   when code="FTPCOMMAND"     then phrase="command failed"
   when code="FTPPROXYTHIRD"  then phrase="proxy server does not support third party transfers"
   when code="FTPNOPRIMARY"   then phrase="no primary connection for proxy transfer"
   when code="0"              then phrase="no error (possibly unknown error)"
otherwise
   phrase="unknown error condition "||code||" - contact author"
end

return phrase

/*------------------------------------------------------------------
 * some help
 *------------------------------------------------------------------*/
Usage: procedure expose debug binaries version credits. pager

arg cmd .

select
   when cmd="!" then say "!     issue a command to OS/2"
   when cmd="CONNECT" | cmd="OPEN" then
      do
      say "connect host [user [password]]"
      say "connect user@host [password]"
      say "open host [user [password]]"
      say "open user@host [password]"
      say
      say "Connect to a remote host.  If user is not specified, anonymous"
      say "is selected as the default."
      end
   when cmd="USER"  then say "user      Open connection to current host for a [new] user"
   when cmd="CLOSE" then say "close     Close the remote session"
   when cmd="LCD"   then say "lcd       Change the local working directory"
   when cmd="SITE"  then say "site command      Issue a site specific command to the remote host"
   when cmd="VERSION"  then say "version      Display information about the version of MaxiFTP"
   when cmd="QUOTE"  then say "quote command      execute the command on the remote host"
   when cmd="REDIR" then say "redir     redisplay the last dir or ls results"
   when cmd="PREDIR" then say "predir     redisplay the last dir or ls results through the pager"
   when cmd="PAGER" then
      do
      say "By default, MaxiFTP uses MORE as the pager.  If you prefer a different pager, put it's"
      say "name (and path information) in the PAGER environment variable."
      end
   when cmd="VISUAL" then
      do
      say "VISUAL"
      say
      say "Enter MaxiFTP's VISUAL FTP mode."
      say
      say "In visual mode, MaxiFTP presents a scrollable list of files and directories from the"
      say "remote host in a PM dialog box.  You can choose a file to transfer or a directory to"
      say "enter by clicking with your mouse.  Choosing CANCEL will exit MaxiFTP.  You can also"
      say "issue any MaxiFTP command, and output will be displayed in the window where MaxiFTP"
      say "started."
      say
      say "VISUAL mode may be selected by typing the command VISUAL at the MaxiFTP prompt, or"
      say "starting MaxiFTP with the /V option.  If you rename MaxiFTP to VisFTP, VISUAL mode"
      say "will be the default."
      end
   when (cmd="DIR") | (cmd="LS")  | (cmd="PDIR") then
      do
      say "dir [pattern] [|command]"
      say "pdir [pattern]"
      say "ls [pattern] [|command]"
      say
      say "  Display a directory listing for the remote host"
      say "  The output can be piped into another program."
      say "  ls displays a short listing, dir displays a long format listing"
      say "  pdir displays a directory using the more command."
      say "Examples:"
      say "  dir"
      say "  ls *.exe"
      say '  dir "|head -20"'
      end
   when (cmd="TYPE") | (cmd="PAGE") | (cmd="MORE") then
      do
      say "type filename [|command]"
      say "page filename"
      say
      say "Display a remote file on the screen."
      say "The page command uses MORE as a pager.  The output from type can"
      say "optionally be piped to another program."
      end
  when (cmd="GET") | (cmd="PUT") then
      do
      say "get remotefile [localfile]"
      say "aget remotefile [localfile]"
      say "bget remotefile [localfile]"
      say "put localfile [remotefile]"
      say "uput localfile [remotefile]"
      say
      say "GET transfers a file from a remote host to the PC."
      say "AGET transfers a file from a remote host to the PC in ASCII mode."
      say "BGET transfers a file from a remote host to the PC in BINARY mode."
      say "PUT transfers a file from the PC to a remote host."
      say "UPUT transfers a file from the PC to a remote host, ensuring a unique name."
      say
      say "There are two transfer modes - ASCII and BINARY.  You can set the"
      say "default mode with the ASCII and BINARY commands.  This client will"
      say "assume binary mode for the following extensions: "binaries
      say
      say "GET also ensures that the file transferred has a valid local name.  It creates"
      say "a valid local name from the remote name if necessary."
      end
  when (cmd="RENAME") then  say "rename oldname newname       rename a remote file"
  when (cmd="DELETE") then  say "delete filename     delete a remote file"
  when (cmd="SYS") then  say "sys       Display information about remote host"
  when (cmd="QUIT") | (cmd="BYE") | (cmd="EXIT") then say "quit      Leave MaxiFTP"
  when (cmd="ASCII") then say "ascii     set default transfer mode to 7-bit ASCII"
  when (cmd="BINARY") then say "binary    set default transfer mode to 8-bit BINARY"
  when (cmd="PWD") then say "pwd       display remote working directory"
  when (cmd="MD") then say "md       create a new directory on the remote host"
  when (cmd="CDUP") then say "cdup       change to a the parent of the current remote working directory"
  when (cmd="RD") then say "rd       remove an existing directory on the remote host"
  when (cmd="APPEND") then say "append      transfer an ASCII file and append to an existing local file"
  when (cmd="SHOW") | (cmd="QUERY") then say "show       display information about the current connection"
  when (cmd="CREATE") then say "create      create an empty file on the remote host"
  when (cmd="CD") then
     do
     say "cd directory"
     say "directory"
     say
     say "Change to the specified directory on the remote host.  If you type a"
     say "directory name by itself that does not match a MaxiFtp command,"
     say "MaxiFtp assumes the CD command."
     end
  when (cmd="MGET")|(cmd="MPUT") then
     do
     say "mget filespec"
     say "mput filespec"
     say
     say "Transfer a group of files at once."
     say "If PROMPT is set (default), you will be asked to confirm each transfer."
     say "The values of CLOBBER and UNIQUE will affect local and remote filenames."
     end
  when (cmd="NETRC") then
     do
     say "MaxiFTP will use the TCP/IP NETRC file to obtain information about a host"
     say "and connections.  MaxiFTP uses the hostname, username, and password fields."
     say "At present, it ignores any other values."
     say
     say "By default, when you issue a connection command, MaxiFTP will look for an"
     say "entry in your NETRC file and use those values, unless you have specified"
     say "different values at the command line or MaxiFTP prompt."
     say
     say "MaxiFTP looks for a NETRC file first in your current directory and then"
     say "in the directory pointed to by the %etc% variable."
     say
     say "If you wish MaxiFTP to ignore the NETRC file, you can issue the"
     say "TOGGLE NETRC command or place the -n- option on the command line or in the"
     say "MAXIFTP environment variable."
     end
  when (cmd="TOGGLE") then
     do
     say "toggle [setting]"
     say
     say "where setting is one of the following:"
     say
     say "CLOBBER  controls whether or not MaxiFTP will automatically overwrite existing"
     say "         files."
     say "PROMPT   determines whether or not MaxiFTP will prompt during mget and mput."
     say "DISPLAY  toggles displaying a status bar at the top of the screen."
     say "UNIQUE   determines whether or not remote file targets during put will be"
     say "         forced to be unique."
     say "QUIET    determines whether messages will be displayed about command success"
     say "         and failure."
     say "TOUCH    make the timestamp on files transferred with get/mget match the remote"
     say "         filesystem."
     say "NETRC    use the NETRC file for information about a connection."
     say "LONGNAME store the real name in the .LONGNAME extended attribute on a FAT"
     say "         partition if the name is globbed."
     say "COMMENT  store information in the .COMMENT extended attribute."
     say "BELL     ring a bell after connecting and after a transfer."
     end
  when (cmd="COLON-MODE") then
     do
     say "MaxiFTP implements a simple, automated FTP transfer.  You can invoke MaxiFTP"
     say "with a colon in the host name, followed by the name of the file to transfer."
     say "MaxiFTP will attempt (one time) to connect to the remote host, transfer the "
     say "file, and close the connection."
     say "The filename can include a wildcard.  CLOBBER and NOPROMPT are assumed"
     say "for automated transfers."
     say "You can also specify a user name with or without a password to identify the"
     say "user account on the remote host."
     end
  when (cmd="TOUCH") then
     do
     say "MaxiFTP has a special option called TOUCH that is not included in most FTP"
     say "clients.  In TOUCH mode, MaxiFTP will attempt to make the timestamp on a"
     say "transferred file match the timestamp on the remote system."
     say
     say "This requires having a TOUCH program compatible with the Unix TOUCH command"
     say "installed on your system.  One source for such a program is the GNU File"
     say "Utilities for OS/2 available from ftp-os2.cdrom.com and other anonymous"
     say "FTP sites."
     say
     end
  when (cmd="NEWS") then
     do
     parse source . . name
     news=filespec('drive',name)||filespec('path',name)||"maxiftp.new"
     if stream(news,"C","QUERY EXISTS")<>"" then
        pager " <"news
     else say "No news available."
     end
  when (cmd="CREDITS") then
     do
     say version credits.1
     say
     say "MaxiFTP is based on the MiniFTP client included with the RxFTP package"
     say "from the IBM Employee Written Software Program (EWS)."
     say
     say "Special thanks to Al Dhir for suggesting several features."
     say
     say "My warmest thanks go to Micheal Gleason, author of the NcFTP program"
     say "for Unix.  His program is the inspiration for many of the features found"
     say "in MaxiFTP, and, with his permission, the manual for MaxiFTP is based upon"
     say "the NcFTP manual."
     say
     say "Other ideas for MaxiFTP features have came from the OS/2 internet community."
     say "If you have any suggestions, please mail them to me!"
     say
     say "Albert Crosby - acrosby@comp.uark.edu"
     end
  when (cmd="PROMPT") then
     do
     say "The MaxiFTP prompt can be customized.  The command to use is:"
     say "    set prompt=promptstring"
     say
     say "Special information can be inserted in the prompt using the following"
     say "codes:"
     say "@D         Inserts the current remote directory."
     say "@L         Inserts the current local directory."
     say "@H         Inserts the name of the remote host."
     say "@0         Inserts the name of the calling program."
     say "@B         Turns on boldface mode."
     say "@Cfb       Set color to foreground f on background b"
     say "@I or @R   Turns on inverse (reverse) video mode."
     say "@N         Inserts a newline character."
     say "@P         Turns off any video modes you might have set with @B, @I, or @R"
     say "@T         Inserts the current time."
     say '@S         Inserts the current connection status.'
     say "@_         Inserts a blank."
     say "@@         Inserts an at sign."
     say "@E         Inserts the most recent FTP Error code."
     say
     say "The default prompt is  set prompt=@0@S[@B@H:@D@P]@S"
     say
     say "See MaxiFTP.MAN for more information."
     end
  when (cmd="COLORS") then
     do
     say "The @C code in the SET PROMPT command uses colors in the following"
     say "fashion:"
     say
     say " @Cfb Set color to foreground f on background b; where f and b"
     say "      are numbers between 0 and 7.  0 is black; 1 is red; 2 is green; 3"
     say "      is yellow; 4 is blue; 5 is magenta; 6 is cyan; 7 is white."
     end
  when (cmd="OPTIONS") then
     do
     say "MaxiFTP has several command line options which can be specified when starting"
     say "the program, preceeded by a dash ('-') or in the environment variable MAXIFTP."
     say "These are:"
     say
     say " option  type     desc"
     say " ------  -------  -----------------------------------------"
     say " b                default to binary file transfer mode"
     say " i                ignore prompts (assumes you know what you're doing)"
     say " a       string   anonymous ftp password"
     say " h       string   display help on a topic"
     say " q       t/f      quiet mode"
     say " d       t/f      display the status banner"
     say " c       t/f      set CLOBBER mode"
     say " p       t/f      set PROMPT mode"
     say " u       t/f      set UNIQUE mode"
     say " t       t/f      set TOUCH mode"
     say " n       t/f      use/do not use NETRC for connection info"
     say " l       string   set the default local directory"
     say ' m       t/f      use "#macros" from netrc file'
     say ' x       t/f      use rxSock to determine hostname'
     say " r       n:s      Retry N times with S second pause between tries"
     say
     say "The t/f (true/false) options default to true.  If followed by a '-',"
     say "they set the value to false.  The string options must be followed"
     say "immeadiately by a string (with no blanks) that sets the value."
     end
otherwise
   say version credits.1
   say
   say "   Commands available are:"
   say "       !       cdup     dir   mget    put    redir   toggle   set"
   say "       ?       close    get   open    pwd    rename  type     echo"
   say "       append  connect  help  page    quit   show    uput     aget"
   say "       ascii   create   ls    pdir    quote  site    version  bget"
   say "       cd      delete   md    predir  rd     sys     lcd      addhost"
   say
   say "Additional topics:  colon-mode  intro  options  touch  netrc credits"
   say "                    prompt"
   say
   say "Enter HELP COMMAND for more information or HELP NEWS for news."
   say "Refer to MaxiFTP.MAN for additionl information on MaxiFTP."
   if cmd="INTRO" then
      do
      say
      say "MaxiFTP may be called with [user@]host:filename to transfer a file and exit."
      say
      say "See MaxiFTP.NEW for additional information or the online help."
      say
      say "Syntax: "
      say "   MaxiFTP [-options] [host[:filename] [user [password]]]"
      say "   MaxiFTP [-options] [user@host[:filename] [password]]"
      end
end

   return 0

displaystatus: procedure expose debug host dir rows cols mode clobber prompt status unique quiet touch bell

   /*---------------------------------------------------------------
    * print status
    *---------------------------------------------------------------*/
   say
   say
   say
   parse value SysCurPos(0,0) with row col

   do i = 1 to 5
      call SysCurPos i-1, 0
      say copies(" ",cols)
   end
   call SysCurPos 0,0


   say d2c(218) || copies(d2c(196),cols-3) || d2c(191)
   say d2c(179) || left(" MaxiFtp: "||time()||" "||status,cols-3) || d2c(179)
   say d2c(179) || left(" directory: "||dir,cols-3) || d2c(179)
   line=" " || left(mode,7)
   if clobber then line=line||"CLOBBER   "
   else line=line||"NOCLOBBER "
   if prompt then line=line||"PROMPT   "
   else line=line||"NOPROMPT "
   if quiet then line=line||"QUIET   "
   if touch then line=line||"TOUCH   "
   if unique then line=line||"UNIQUE"
   say d2c(179) || left(line,cols-3) || d2c(179)
   say d2c(192) || copies(d2c(196),cols-3) || d2c(217)

if row>6 then call SysCurPos row-2, col
else Call SysCurPos 5, col

return

querystatus:
arg varname

if varname\="" then
  do
  if left(varname,1)\="|" then
     do i=1 to words(varname)
     say "Value of "word(varname,i)":"
     interpret 'say "   "'word(varname,i)
     end
  return
  end

say version credits.1
vsn="Junk"
junk=FtpVersion('vsn')
say "rxFTP version "vsn
if host<>"" then
   do
   say "Remote host: "host
   say "Remote directory: "dir
   say "Remote system type: "sys
   end
else say "Not connected to a remote host."
say "Default transfer mode: "mode
say "Local directory: "directory()
say "Anonymous password: "anonpass
say "Pager: "pager
say "Prompt: "promptstr
say "NETRC file: "netrcfile
if clobber then
   say "CLOBBER is ON (local files are overwritten)"
else say "CLOBBER is OFF (local files are not overwritten)"
if prompt then
   say "MPROMPT is ON (you will be prompted during mget and mput"
else say "MPROMPT is OFF (you will not be prompted during mget and mput"
if display then
   say "DISPLAY is ON (status bar is displayed)"
else say "DISPLAY is OFF (status bar is not displayed)"
if unique then
   say "UNIQUE is ON (remote files during put will be forced to unique names)"
else say "UNIQUE is OFF (remote files during put will not be forced to unique names)"
if quiet then
   say "QUIET is ON (messages will not be displayed)"
else say "QUIET is OFF (messages will be displayed)"
if touch then
   say "TOUCH is ON (files received will be stamped with the remote timestamp)"
else say "TOUCH is OFF (files received will not be stamped with the remote timestamp)"
if netrc then
   say "NETRC is ON (the NETRC file will be searched for connection info)"
else say "NETRC is OFF (the NETRC file will not be searched for connection info)"
if macros then
   say "MACROS is ON (NETRC macros will be processed for hosts in the NETRC)"
else say "MACROS is OFF (NETRC macros will not be processed for hosts in the NETRC)"
if visual then
   say "VISUAL mode is ON (VREXX will be used for directory lists & dialogs)"
else say "VISUAL mode is OFF (VREXX will not be used.)"
if remember then
   say "REMEMBER is ON (Last directory for this host will be kept for next connect.)"
else say "REMEMBER is OFF (Last directory for this host will not be kept for next connect.)"
say "File types automatically transferred in binary mode:"
say "   "binaries
say "File types automatically transferred in ASCII mode:"
say "   "asciis

return

connect: procedure expose debug host user pass phost anonpass quiet netrc sys dir retries delay bell visual needdir netrcfile hostlist. hostnetrcline memoryfile remember ask

if visual then needdir=1
if (host="") then
   if visual then 
      do
      host=VListNETRC()
      if host="" | (ask) then if GetHost()="CANCEL" then return -2
      end
   else
      do
      call Usage "CONNECT"
      return -1
      end
if netrc then Call LookUpNETRC hostnetrcline
do attempt=1 to retries
         if pos("@",host)<>0 then
            do
            pass=user
            parse var host user"@"host
            end
         if pos(":",host)<>0 then
            do
            end
         if netrc & (newhost<>"") then host=newhost
         if netrc & (user="") & (newuser<>"") then
            do
            user=newuser
            pass=newpass
            end
         if (user="") then user="anonymous"
         if (translate(user)="#ASK") | ((ask) & (\visual)) then
            do
            newuser=cmdline("T=Enter the username: ","D="||user,"No History")
            if newuser\="" then
               do
               pass=""
               user=newuser
               end
            end
         if (translate(user)="ANONYMOUS") & (pass="") then pass=anonpass
         if (translate(user)<>"ANONYMOUS") & (pass="") then
            if visual then call GetHost
            else
               do
               call charout ,"Enter the password: "
               pass=CmdLine("hidden")
               end
         if pos(".",host)="" then phost=host
         else parse var host phost".".
         if \quiet then say "Connecting to "user"@"host"..."
         call FtpSetUser host, user, pass
         sys=""
         err = FtpSYS('sys')
         if err<>0 & FTPERRNO<>0 & FTPERRNO<>"FTPCOMMAND" then
            do
            if attempt=retries then
               do;
               if \quiet then say "Connection failed: "english(FTPERRNO)
               host=""
               phost=""
               user=""
               do queued()
                  parse pull .
               end
               leave
               end
            else
               do
               if \quiet then say "Connection failed: "english(FTPERRNO) "retrying... (try "attempt")"
               call SysSleep Delay
               iterate
               end
            end
         if word(sys,1)="VM" then
            do
            if visual then
               do
               say "Prompting for ACCOUNT"
               p.0=1
               p.1="Enter the account password:"
               w.0=1
               w.1=30
               h.0=1
               h.1=1
               r.0=0
               r.1=''
               button=VMultBox("Remote system is VM",'p','w','h','r',2)
               if button='OK' then account=r.1
               end
            else
            do;
            say "Remote system is VM/CMS.  Please enter the minidisk password:"
            account=CmdLine("hidden")
            end
            call FtpSetUser host, user, pass, account
            end
         err = FtpPWD('dir')
         if err<>0 & FTPERRNO<>0 then
            do
            if attempt=retries then
               do;
               say "Connection failed: "english(FTPERRNO)
               host=""
               phost=""
               user=""
               do queued()
                  parse pull .
               end
               end
            else
               do
               if \quiet then say "Connection failed: "english(FTPERRNO) "retrying... (try "attempt")"
               call SysSleep Delay
               end
            end
         else 
            do
            if \quiet & bell then call beep 278,200
            Call Remember_Dir
            leave;
            end
end
return  err

toggle: procedure expose debug prompt clobber display unique quiet touch netrc longname comment bell remember ask macros
arg toggles

do i=1 to words(toggles)
toggle=word(toggles,i)
select
   when (toggle="PROMPT") | (toggle="MPROMPT") then prompt=\prompt
   when toggle="CLOBBER" then clobber=\clobber
   when toggle="STATUS" | toggle="DISPLAY" then display=\display
   when toggle="UNIQUE" then unique=\unique
   when toggle="QUIET" then quiet=\quiet
   when toggle="TOUCH" then touch=\touch
   when toggle="NETRC" then netrc=\netrc
   when toggle="COMMENT" then comment=\comment
   when toggle="LONGNAME" then longname=\longname
   when toggle="BELL" then bell=\bell
   when toggle="REMEMBER" then remember=\remember
   when toggle="ASK" then ask=\ask
otherwise
   say "Unknown option: "toggle
   return
end
end
return

processargs:

parse arg args

do until length(args)=0
   tf=1
   key=translate(left(args,1))
   args=substr(args,2)
   if key=" " then iterate
   if key='"' then
      do
      parse var args '"'.'"'args
      iterate
      end
   if left(args,1)="-" then
      do
      tf=0
      args=substr(args,2)
      end
   select
      when key="B" then if tf then mode="BINARY" else mode="ASCII"
      when key="I" then /* Know what you're doing... */
         do
         prompt=0
         clobber=1
         end
      when key="A" then /* Anonymous password */
         if left(args,1)<>" " then
            do
            if left(args,1)='"' then
               parse var args '"'anonpass'"'args
            else
               do
               anonpass=subword(args,1,1)
               args=subword(args,2)
               end
            end
      when key="R" then /* speficy retries[:delay] */
         do
         time=subword(args,1,1)
         args=subword(args,2)
         parse var time retries":"delay
         if \datatype(delay,"W") then delay=60
         if \datatype(retries,"W") then retries=1
         end
      when key="L" then /* change local directory */
         if left(args,1)<>" " then
            do
            if left(args,1)='"' then
               parse var args '"'ldir'"'args
            else
               do
               ldir=subword(args,1,1)
               args=subword(args,2)
               end
            call directory ldir
            end
      when key="H" |key="?" then /* Help */
         do
         if \quiet then call Credits
         if left(args,1)<>" " then
            do
            if left(args,1)='"' then
               parse var args '"'topic'"'args
            else
               do
               topic=subword(args,1,1)
               args=subword(args,2)
               end
            Call Usage topic
            end
         else if host<>"" then call Usage host
         else Call Usage "INTRO"
         exitcode=0
         signal done
         end
      when key="U" then unique=tf
      when key="C" then clobber=tf
      when key="P" then prompt=tf
      when key="D" then display=tf
      when key="Q" then quiet=tf
      when key="T" then touch=tf
      when key="N" then netrc=tf
      when key="X" then nop;
      when key="K" then ask=tf
      when key="M" then macros=tf;
      when key="V" then 
         do
         visual=tf
         if visual then visual=1
         end
   otherwise
      if \quiet then say "Invalid option: "key
   end
end

return

Credits:

do
   call charout, greenonblack

   if translate(progname)<>"MAXIFTP" then say name "is ..."
   say version
   do i=1 to credits.0
   say credits.i
   end
   junk=FtpVersion('vsn')
   say "Using RxFTP version "vsn normvideo
end
return

LoadFunctions:

/*------------------------------------------------------------------
 * load functions, if needed
 *------------------------------------------------------------------*/
if RxFuncQuery("FtpLoadFuncs") then
   do
   rc = RxFuncAdd("FtpLoadFuncs","RxFtp","FtpLoadFuncs")
   if rc\=0 then
      do
      say "Error loading the rxFtp package.  rxFtp is an extension to REXX"
      say "that allows it to utilize the FTP protocol and API. You can"
      say "obtain rxFTP via anonymous FTP from software.watson.ibm.com or"
      say "ftp-os2.cdrom.com."
      end
   rc = FtpLoadFuncs()
   end

if RxFuncQuery("SysLoadFuncs") then
   do
   rc = RxFuncAdd("SysLoadFuncs","RexxUtil","SysLoadFuncs")
   rc = SysLoadFuncs()
   end

if pos(" X-",translate(args))=0 & RxFuncQuery("SockLoadFuncs") then
   do
   rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
   if rc\=0 then
      hostname=value("HOSTNAME",,"OS2ENVIRONMENT")
   else 
      do
       rc = SockLoadFuncs()
       if rc=0 then
          do
          addr = SockGetHostId()
          rc= SockGetHostByAddr(addr,"host.!")
          hostname=host.!name
          end
       else hostname=value("HOSTNAME",,"OS2ENVIRONMENT")
       end
   end
else hostname=value("HOSTNAME",,"OS2ENVIRONMENT")

return

touch: procedure

parse arg direntry, file

sys=""
err=FtpSYS('sys')
sys=word(sys,1)

if right(file,1)=":" then return 0
if wordpos(translate(file),"NUL CON LPT1 LPT2 LPT3 LPT4 PRN -") then return 0

select
   when sys="Netware" then
      do
      parse var direntry . 42 time 57 .
      time=subword(time,1,2)||", "||subword(time,3)
      end
   when sys="Windows_NT" | sys="UNIX" | left(direntry,1)="-" then
      do
      time=subword(direntry,words(direntry)-3,3)
      if pos(":",time)=0 then
         time=subword(time,1,2)||", "||subword(time,3)
      end
   when sys="OS/2" then
      do;
      parse var direntry . 36 time 52 .
      months="Jan Feb Mar Apr May June July Aug Sep Oct Nov Dec"
      parse var time month"-"day"-"year time
      time=word(months,month)||" "||day||", "||year||" "||time
      end
   when sys="Windows_NT" then parse var direntry . 45 time 57 .
   when sys="VM" then parse var direntry . 54 time 71 .
otherwise
   say "Cannot determine timestamp for operating system "SYS
   say "If you would like to have TOUCH updated for this OS, contact the author"
   say "with the OS information and the contents of the next line."
   say direntry
   say file
   return -1
end

'touch -d "'strip(time)'"' file
if rc=1041 then say "The TOUCH mode requires a TOUCH program compatible with the UNIX touch command."
if rc<>0 then say "TOUCH appears to have failed.  You may want to contact the author for assistance."

return 0

create: procedure expose debug quiet bell

parse arg fn

if \quiet then say "Creating message "fn
tempfile=systempfilename("tmp?????")
call lineout tempfile
call stream tempfile,'C','CLOSE'
oq=quiet
quiet=1
unique=0
binaries=""
err=put(tempfile,fn)
quiet=oq
call SysFileDelete tempfile
return 1

lookupnetrc: procedure expose debug host newhost newuser newpass netrcfile hostlist.

newhost=""
newuser=""
newpass=""

if host="" then return 0

do i=1 to hostlist.0
   if pos(translate(host),translate(word(hostlist.i,1)))=0 then iterate
   host=word(hostlist.i,1)
   leave
end

if SysFileSearch(host, netrcfile,'hits.','N')<>0 then
   return -1
if hits.0=0 then return 0
if datatype(arg(1),'W') then hits.1=arg(1)
do i=1 to word(hits.1,1)-1
   call linein netrcfile
end

found=0
do while (stream(netrcfile,'s')="READY")
   line=linein(netrcfile)
   if \found & (left(line,1)="#") | (left(line,1)=";") | (length(line)=0) then iterate
   if (substr(line,2,1)="#") | (substr(line,2,1)=";") then iterate
   tline=translate(line)
   if \found & pos('MACHINE',tline)=0 then iterate;
   if pos("MACHINE",tline)<>0 then
      if found then leave
      else machinename=word(line,wordpos("MACHINE",tline)+1)
   if pos(translate(host),translate(machinename))=0 then iterate
   found=1
   if (left(line,1)<>"#") & (left(line,1)<>";") then
      do
      if pos("LOGIN",tline)<>0 then newuser=word(line,wordpos("LOGIN",tline)+1)
      if pos("PASSWORD",tline)<>0 then newpass=word(line,wordpos("PASSWORD",tline)+1)
      end
   else
      do
      parse var line 2 cmd cmdargs
      Queue cmd cmdargs
      end
end
call Stream netrcfile, 'c', 'close'
if found then newhost=machinename
return found

dir: procedure expose stem. pager sys host dir phost status quiet bell visual dircmd

parse arg cmd, mask, dest

   if cmd="" then cmd="DIR"
   if mask="" then mask="."

   if ((cmd="DIR")|(cmd="PDIR")) & left(mask,1)<>"-" then
      do
      if cmd="PDIR" then cmd="P"||translate(word(dircmd,1))
      else cmd=translate(word(dircmd,1))
      mask=subword(dircmd,2) mask

      end

   err=0
   select
   when (cmd="LS") | (cmd="PLS") then
      if (mask=".") & (pos("UNIX",translate(sys))<>0)
         then err=FtpLS("-CF",'stem.')
         else err=FtpLS(mask,'stem.')
   when (cmd="DIR")| (cmd="PDIR") then err=FtpDIR(mask,'stem.')
   when (cmd='ls') then err=FtpLS(mask,'stem.')
   when (cmd="REDIR") | (cmd="PREDIR") then nop;
   otherwise return -1
   end

   if (left(cmd,1)<>"P") & (left(dest,1)<>'|') & (left(dest,1)<>'>') then
      do i = 1 to stem.0
         say stem.i
      end
   else
      do
      if left(cmd,1)="P" then dest="|"||pager
      tempfile=systempfilename("ftp?????")
      if left(dest,2)='>>' then tempfile=substr(dest,3)
      else if left(dest,1)='>' then
         do;
         tempfile=substr(dest,2)
         call SysFileDelete tempfile
         end;
      do i = 1 to stem.0
         call lineout tempfile, stem.i
      end
      if left(dest,1)="|" then substr(dest,2) "<" tempfile
      call stream tempfile,'C','CLOSE'
      if left(dest,1)<>'>' then call SysFileDelete tempfile
      end
   if (err <> 0) & (ftperrno <>0) then
      do
      say "Error from FTP:" english(FTPERRNO)
      if ftperrno="FTPCONNECT" then
         do
         say "Remote server closed connection."
         host=""
         phost=""
         dir=""
         end
      end
return err

ProcessCMD:

parse arg cmd, cmdargs

   if cmd="" then return 0

   if left(cmdargs,1)='"' then
      parse var cmdargs '"'file1'"' rest
   else parse var cmdargs file1 rest
   if left(cmdargs,1)='"' then
      parse var rest '"'file2'"' rest
   else parse var rest file2 rest

   if (left(file1,1)="|") then
      do
      rest=file2||" "||rest
      file2=file1
      file1=""
      end
   if (left(file1,1)=">") then
      do
      rest=file2||" "||rest
      file2=file1
      file1=""
      end
   if (left(file2,1)="|") then
      file2=file2||" "||rest
   if (left(file2,1)=">") then
      file2=file2||" "||rest
   if (file1 = "") then file1 = "."
   if (file2 = "") then file2 = file1

   /*------------------------------------------------------------------
    * sanity check
    *------------------------------------------------------------------*/
   origcmd=cmd
   cmd = translate(cmd)

   if (host="") & (left(cmd,1)<>"!") & (wordpos(cmd,"CONNECT FTP OPEN VERSION ? HELP QUIT TOGGLE SHOW QUERY ASCII LCD SET BINARY VISUAL ECHO CREDITS ADDHOST")=0) then
      do
      say "You have not provided host, userid, and password information."
      say "Use the CONNECT command to provide this information."
      return 0
      end

   /*---------------------------------------------------------------
    * run command
    *---------------------------------------------------------------*/
   err = 0
   select
      when left(cmd,1)="!"   then
         do
         if cmd="!" then value("COMSPEC",,"OS2ENVIRONMENT")
         else "call "substr(origcmd,2) cmdargs
         end
      when (cmd = "MGET")    then  err=mget(file1)
      when (cmd = "ECHO")    then say cmdargs
      when (cmd = "MPUT")    then err=mput(file1)
      when (cmd = "QUIT") | (cmd="BYE") | (cmd="EXIT") then
         do
         call Update_Memory
         return 0
         end
      when (cmd = "SET")     then Call Set cmdargs
      when (cmd = "BINARY")  then err = Mode("BINARY")
      when (cmd = "ASCII")   then err = Mode("ASCII")
      when (cmd = "GET")     then err = Get(file1,file2)
      when (cmd = "AGET")     then err = Get(file1,file2,"ASCII")
      when (cmd = "BGET")     then err = Get(file1,file2,"BINARY")
      when (cmd = "PUT")     then err = Put(file1,file2)
      when (cmd = "UPUT")    then err = Put(file1,file2,1)
      when (cmd = "CREATE")  then err = Create(file1)
      when (cmd = "DELETE")  then err = FtpDelete(file1)
      when (cmd = "RENAME")  then err = FtpRename(file1,file2)
      when (cmd = "APPEND")  then err = FtpAppend(file1,file2,"ASCII")
      when (cmd = "MODE")    then err = Mode(file1)
      when (cmd = "QUOTE")   then err = FtpQuote(cmdargs)
      when (cmd = "SITE")    then err = FtpSite(cmdargs)
      when (cmd = "CD")      then err = FtpChDir(file1)
      when (cmd = "CDUP")    then err = FtpChDir('..')
      when (cmd = "MD")      then err = FtpMkDir(file1)
      when (cmd = "RD")      then err = FtpRmDir(file1)
      when (cmd = "CREDITS") then call Credits
      when (cmd = "ADDHOST") then
         do
         hostlist.0=hostlist.0+1
         i=hostlist.0
         hostlist.i=cmdargs
         end
      when (cmd = "VISUAL")  then 
         if \visual then 
            do; 
            visual=visinit(); 
            if visual then call visftp; 
            end
      when (cmd = "TOGGLE")  then Call toggle cmdargs
      when (cmd = "VERSION") then say version credits.1
      when (cmd = "SHOW") | (cmd="QUERY")    then Call QueryStatus cmdargs
      when (cmd="DIR") | (cmd="PDIR") | (cmd="REDIR") | (cmd="PREDIR") | (cmd="LS") | (cmd="PLS")
                             then err = Dir(cmd,file1,file2)
      when (cmd = "?") | (cmd="HELP")
                             then call Usage file1

      when (cmd = "TYPE")|(cmd = "PAGE")|(cmd="MORE")    then
         if file2==file1 then
            do
            if cmd="TYPE" then err=get(file1,"-")
            else err=get(file1,"|"||pager)
            end
         else err=get(file1,file2)

      when (cmd = "MTYPE")|(cmd="MPAGE") then
         if cmd="MTYPE" then err=mget(file1,"-")
         else err=mget(file1,"|"||pager)

      when (cmd = "CONNECT") | (cmd="OPEN") | (cmd="FTP") then
         do
         if remember then call Update_Memory
         if left(cmdargs,1)='"' then
            parse var cmdargs '"'host'"' rest
         else parse var cmdargs host rest
         if left(cmdargs,1)='"' then
            parse var rest '"'user'"' rest
         else parse var rest user rest
         parse var rest pass
         err=Connect()
         end

      when (cmd = "USER") then
         do
         oask=ask
         ask=0
         if cmdargs="" then ask=1
         if left(cmdargs,1)='"' then
            parse var cmdargs '"'user'"' rest
         else user=cmdargs
         pass=""
         err=Connect()
         ask=oask
         end

      when (cmd = "LCD") then
         do
         ldir=directory(file1)
         if \quiet then say "Local working directory is now "ldir
         end

      when (cmd = "CLOSE")   then
         do
         if host="" then return
         if remember then call Update_Memory
         rc = FtpLogoff()
         host = ""
         user = ""
         pass = ""
         end

      when (cmd = "PWD")     then
         do
         junk = FtpPwd('dir')
         say "Current Remote Directory :" dir
         end

      when (cmd = "SYS")     then
         do
         sys=""
         junk = FtpSys('sys')
         say "Remote operating system is:" sys
         end

      otherwise /* Try changing to a directory with the name of command. */
         err = FtpChDir(origcmd)
         if (err<>0) then
            do
            say "Invalid command. Use ? for help."
            return 0
            end
         else 
            do
            err=FtpPWD('dir')
            if visual then needdir=1
            end
         return err
   end

if debug then say sourceline() "Error code is "err "/ftp error no. "ftperrno "["english(FTPERRNO)"]"

return err

ProcessNETRC:

call stream netrcfile, 'c', 'open read'
do while (stream(netrcfile,'s')="READY")
   line=linein(netrcfile)
   if (left(line,1)<>"#") & (left(line,1)<>";") then leave
   if (substr(line,2,1)="#") | (substr(line,2,1)=";") then iterate
   parse var line 2 cmd cmdargs
   if (translate(cmd)="VISUAL") then visual=1
   else Call ProcessCMD cmd, cmdargs
end
call Stream netrcfile, 'c', 'close'
return

ProcessINI:

arg inifile

call stream inifile, 'c', 'open read'
do while (stream(inifile,'s')="READY")
   line=linein(inifile)
   if (left(line,1)="#") | (left(line,1)=";") then iterate
   parse var line cmd cmdargs
   if (translate(cmd)="VISUAL") then visual=1
   else Call ProcessCMD cmd, cmdargs
end
call Stream inifile, 'c', 'close'
return

set:
parse arg command

if (pos('=',command)<>0) then parse var command var"="parm
else parse var command var parm
var=translate(var)
if left(parm,1)='"' then parse var parm '"'parm'"'

select
   when (var='BINARIES') then binaries=parm
   when (var='ASCIIS') then asciis=parm
   when (var='ANONPASS') then anonpass=parm
   when (var='VISCMD') then viscmd=parm
   when (var='PAGER') then pager=parm
   when (var='DIRCMD') then dircmd=parm
   when (var='LDIR') then ldir=directory(parm)
   when (var='MODE') then Call Mode(parm)
   when (var='NETRCFILE') then
      do
      oldnetrc=netrcfile
      netrcfile=stream(parm,'c','query exists')
      if netrcfile="" then netrcfile=oldnetrcfile
      end
   when (var='MPROMPT') then
      do
      if parm=1 then prompt=1
      if parm=0 then prompt=0
      end
   when wordpos(var,"TOUCH UNIQUE CLOBBER DISPLAY QUIET NETRC MACROS REMEMBER COMMENT LONGNAME ASK BELL")<>0 then
      do
      if (parm=1) | translate(parm)="ON" then interpret var||'=1'
      if (parm=0) | translate(parm)="OFF" then interpret var||'=0'
      end
   when (var='PROMPT') then
      do
      promptstr='""'
      do while (length(parm)>0)
         char=left(parm,1)
         parm=substr(parm,2)
         if char='@' then
            do
            var=translate(left(parm,1))
            parm=substr(parm,2)
            select
               when var="B" then promptstr=promptstr||'||boldvideo'
               when var="0" then promptstr=promptstr||'||progname'
               when var="D" then promptstr=promptstr||'||dirname'
               when var="U" then promptstr=promptstr||'||user'
               when var="L" then promptstr=promptstr||'||directory()'
               when var="H" then 
                  do
                  t=left(parm,1)
                  if (verify(t,"0123456789*")=0) then
                     do
                     parm=substr(parm,2)
                     if t=0 then
                        promptstr=promptstr||'||host'
                     if t="*" then
                        promptstr=promptstr||'||word(translate(host," ","."),words(translate(host," ",".")))'
                     else promptstr=promptstr||'||word(translate(host," ","."),'t')'
                     end
                  else promptstr=promptstr||'||phost'
                  end
               when (var="I") | (var="R")
                            then promptstr=promptstr||'||inversevideo'
               when var="N" then promptstr=promptstr||'||d2c(13)||d2c(10)'
               when var="P" then promptstr=promptstr||'||normvideo'
               when var="%" then promptstr=promptstr||'||!history.0+1'
               when var="T" then promptstr=promptstr||'||time()'
               when var="S" then promptstr=promptstr||'||status'
               when var="E" then promptstr=promptstr||'||FTPERRNO'
               when var="_" then promptstr=promptstr||'||" "'
               when var="@" then promptstr=promptstr||'||"@"'
               when var="C" then
                  do
                  colors=left(parm,2)
                  if (length(colors)=2) & (verify(colors,"01234567")=0) then
                     do
                     parm=substr(parm,3)
                     promptstr=promptstr||'||d2c(27)||"['||left(colors,1)+30||';'||right(colors,1)+40||'m"'
                     end
                  end
            otherwise nop
            end
            end
         else if char='"' then promptstr=promptstr||'||""""'
         else promptstr=promptstr||'||"'char'"'
      end
      end
   when left(var,1)="." then /* Executable extensions */
      do
      ext=substr(var,2)
      run.extensions=run.extensions||" "||ext
      run.ext=parm
      end

   when (var="") then nop
   otherwise
      do
      say "You cannot set the value of "var
      return 0
      end
end
return 1

mode: procedure expose mode quiet

parse upper arg modename

err=0
if modename="ASCII" then
    err = FtpSetBinary("ASCII")
else if modename="BINARY" then err= FtpSetBinary("BINARY")
else
   do
   if \quiet then say "Invalid value for mode: "modename
   return 0
   end
mode=modename
if \quiet then say "File transfer mode set to "mode "("err")"

return 0

PutComment: procedure

parse arg file, user, remotehost, remotedir, remotename

if pos('"',remotedir)<>0 then parse var remotedir '"'remotedir'"'.

message="Transferred from "user"@"remotehost":"remotedir

if pos(right(message,1),"/\")=0 then message=message||'/'

message=translate(message,'/','\')||remotename||" at "||time()||" on "||date()"."

RetCode = SysPutEA(File, '.COMMENT','FDFF'x||D2C(LENGTH(Message))||'00'x||Message)
return RetCode

putlong: procedure
parse arg FileName, LongName

if FileName = '' | LongName= '' then DO
   return 0
   end  /* Do */

Return SysPutEA(FileName, '.LONGNAME','FDFF'x||D2C(LENGTH(LongName))||'00'x||LongName)

visinit: procedure expose origdir

if RxFuncQuery("VInit") then
   do
   rc = RxFuncAdd("VInit","VREXX","VINIT")
   if rc\=0 then
      do
      say "Error loading the VRexx/2 package.  VRexx/2 is an extension to REXX"
      say "that allows it to create PM list boxes and dialogs.  It is necessary"
      say "to use MaxiFTP's VISUAL mode.  You can obtain VRexx/2 via anonymous"
      say "FTP from software.watson.ibm.com or ftp-os2.cdrom.com."
      say
      say "Unable to switch to Visual mode."
      visual=0
      return 0
      end
   end

initcode = Vinit()
if initcode = 'ERROR' then 
   do
   say "Unable to switch to Visual mode."
   visual=0
   return 0
   end

signal on halt name CLEANUP2
signal on error name CLEANUP2
signal on syntax name CLEANUP2

call VdialogPos 50,50

return 1

visftp:

say "MaxiFTP is entering Visual mode."

needdir=1
do forever
   if connect()=0 then leave
   host=""
   user=""
   pass=""
end

do queued()
   parse pull cmd cmdargs
   call processcmd cmd, cmdargs
end

request=""
do forever                                    
   request=visdir()
   if request="**CANCEL**" then 
      do
      if vmsg("Leave MaxiFTP?","Do you wish to leave MaxiFTP? ",6)=="YES" then 
         do
         call Update_Memory
         signal cleanup
         end
      iterate
      end
   if left(request,1)='<' then
      do
      cmd=word(request,1)
      select
         when cmd="<MODE>" then call toggle 'MODE'
         when cmd="<DIR>" then call dir
         when cmd="<HOST>" then
            do
               oldhost=host
               olduser=user
               oldpass=pass
               host=""
               user=""
               pass=""
               if connect()<>0 then
                  do
                     host=oldhost
                     user=olduser
                     pass=oldpass
                     if connect<>-2 then
                     do forever
                        if connect()=0 then leave
                        host=""
                        user=""
                        pass=""
                     end
                  end
               do queued()
                  parse pull cmd cmdargs
                  call processcmd cmd, cmdargs
               end
            end
         when cmd="<LCD>" then
            do
            prompt.0=1
            prompt.1="Enter the new local directory "
            prompt.vstring=directory()
            button=VInputBox("Change Local Directory",'prompt',60,3)
            if button<>"CANCEL" then call directory prompt.vstring
            list.2="<LCD> Current local dir: "directory()
            end
         when cmd="<VISCMD>" then
            do
            if translate(viscmd)="GET" then viscmd="TYPE"
            else viscmd="GET"
            list.5="<VISCMD> Visual selection action is "translate(viscmd)
            end
         when cmd="<PUT>" then
            do
            filespec=directory()
            if right(filespec,1)="\" then filespec=filespec||"*.*"
            else filespec=filespec||"\*.*"
            button=VFileBox("Choose the file to send.",filespec,'file')
            if button="OK" then put(file.vstring)
            end
         when cmd="<CMD>" then
            do
            prompt.0=2
            prompt.1="Enter a MaxiFTP command          "
            prompt.2="(Output will go the window where MaxiFTP started.)          "
            prompt.vstring="dir"
            button=VInputBox("MaxiFTP Command Line",'prompt',75,3)
            if button<>"CANCEL" then 
               do
               parse var prompt.vstring cmd cmdargs
               call processcmd cmd, cmdargs
               end
            say "MaxiFTP is in Visual mode."
            end
         otherwise say "Unimplemented: "cmd
      end
      end
   else do
      if pos(right(request,1),'/@*')<>0 then request=left(request,length(request)-1)
      err = FtpChDir(request)
      if err<>0 then call ProcessCMD VisCMD, request
      else needdir=1
      if err<>0 then
         if word(request,1)<>request then 
            do
            err=FtpChDir(word(request,1))
            if err<>0 then err=Get(word(request,1))
            end
      end
end

signal cleanup

visdir:
if needdir then
   do
   err=dir('LS','-F','>nul')
   if err<>0 then err=dir('ls','.','>nul')
   if err<>0 then 
      do
      stem.0=1
      stem.1="<NO FILES AVAILABLE>"
      end
   list.0=7
   list.1="<HOST> "||user||"@"||host
   list.2="<LCD> Current local dir: "directory()
   list.3="<CMD> Issue a MaxiFTP command"
   list.4="<DIR> Show long information about this listing in the text window"
   list.5="<VISCMD> Visual selection action is "translate(viscmd)
   list.6="<PUT> Transfer a file TO "host
   list.7=".."
   do i=1 to stem.0
      j=list.0+1
      list.j=stem.i
      list.0=j
   end
   needdir=0
   end
err = FtpPwd('dir')
if pos('"',dir)<>0 then parse var dir '"'dirname'"'.
else dirname=dir
button=VlistBox('Directory Listing: 'dirname,list,80,8,3)
if button="CANCEL" then return "**CANCEL**"
return list.vstring

GetHost: procedure expose host user pass netrcfile hostnetrcline
cancel=0
p.0=3
p.1="Remote host: "
p.2="Username: "
p.3="Password: "
w.0=3
w.1=40
w.2=40
w.3=40
h.0=3
h.1=0
h.2=0
h.3=1
r.=""
r.0=3
if host<>"" then r.1=host
if user<>"" then r.2=user
else r.2="anonymous"
if pass<>"" then r.3=pass
do until host<>""
button=VMultBox('Specify a host',p,w,h,r,3)
if button="CANCEL" then 
   do
   if vmsg("Leave MaxiFTP?","Do you wish to leave MaxiFTP? ",6)=="YES" then signal cleanup
   else cancel=1
   host=""
   user=""
   pass=""
   end
else
   do
   host=r.1
   user=r.2
   pass=r.3
   end
if host<>"" then
   if (vmsg("Update NETRC file","Add this entry to the end of the NETRC file? ",6)=="YES") then
   do
   p.0=1
   p.1="Alias: "
   w.0=1
   w.1=50
   h.0=1
   h.1=0
   r.=""
   r.0=1
   alias=""
   button=VMultBox('Alias for host 'host,p,w,h,r,3)
   if button<>"CANCEL" then alias="#alias "r.1
   say "Updating "netrcfile
   call lineout netrcfile, "##Following entry added by MaxiFTP on "date()
   call lineout netrcfile, "machine "host alias
   if user<>"" then call lineout netrcfile, "     login "user
   if pass<>"" then call lineout netrcfile, "     password "pass
   call lineout netrcfile
   end
if cancel then leave
if host="" then host=VListNETRC()
end
return button

vmsg: procedure expose origdir

n=0
do i=2 to arg()-1
   n=n+1
   prompt.n=arg(i)
end
prompt.0=n

return VMsgBox(arg(1),'prompt',arg(arg()))

VListNETRC: procedure expose visual origdir netrcfile hostnetrcline hostlist.

say "Presenting a visual list of hosts..."

if SysFileSearch('machine', netrcfile,'hits.','N')\=0 then hits.0=0

hostnetrcline=""

n=1
do i=1 to hostlist.0
   n=n+1
   hosts.0=n
   if words(hostlist.i)=1 then hosts.n=hostlist.i
   else hosts.n=left(subword(hostlist.i,2),100," ")||"@"||word(hostlist.i,1)
end

do i=1 to hits.0
   if left(word(hits.i,2),1)="#" then iterate
   n=n+1
   hosts.0=n
   parse var hits.i "#alias "alias
   if alias<>"" then
      hosts.n=left(alias,100," ")||"@"||word(hits.i,1+wordpos('MACHINE',translate(hits.i)))||" <"||word(hits.i,1)||">"
   else hosts.n=left(word(hits.i,1+wordpos('MACHINE',translate(hits.i))),100," ")||"<"||word(hits.i,1)||">"
end
if n=1 then return ""

hosts.1="<Enter a different host>"

button=VlistBox('Host Selection: ','hosts',45,8,3)
if button="CANCEL" | hosts.vstring="<Enter a different host>" then return ""
parse var hosts.vstring host "<"hostnetrcline">"
if pos("@",host)<>0 then parse var host with " @"host
return strip(host)

addslash: procedure

parse arg path
if right(path,1)="\" then return path
else return path||"\"

Remember_Dir: procedure expose host memoryfile dir remember
if \remember | host="" then return 0
if SysFileSearch(host, memoryfile, "hits.")\=0 then hits.0=0
call Stream memoryfile, 'c', 'close'
if hits.0=0 then return 0
do i=1 to hits.0
   parse var hits.1 nhost ndir
   if translate(host)==translate(nhost) then err=FtpChDir(ndir)
end
err=FtpPwd('dir')
return 1

Update_Memory: procedure expose host memoryfile dir remember
if \remember | host="" | dir="" then return 0
tempfile=systempfilename("tmp?????")

if pos('"',dir)<>0 then parse var dir '"'dirname'"'.
else dirname=dir

written=0
call stream tempfile, 'c', 'open write'
if stream(memoryfile, 'c', 'open read') ="READY:" then
do while (stream(memoryfile,'s')="READY")
   line=linein(memoryfile)
   parse var line ohost odir
   if translate(host)==translate(ohost) then
      do
      call lineout tempfile, host dirname
      written=1
      end
   else if line\="" then call lineout tempfile, line
end
if \written then call lineout tempfile, host dirname
call Stream memoryfile, 'c', 'close'
call Stream tempfile, 'c', 'close'
"@copy "tempfile memoryfile "1>nul 2>nul"
Call SysFileDelete tempfile
return 1

CLEANUP2:

CLEANUP:          
   call VExit
signal done

/* BEGINNING OF CmdLine CODE BY ALBERT CROSBY */
/*
       CmdLine.CMD Version 1.1
       (c) 1994 by Albert Crosby <acrosby@comp.uark.edu>

       This code may be distributed freely and used in other programs.
       Please give credit where credit is due.

       CmdLine.CMD is REXX code that creates a full featured version
       of the OS/2 command line parser that may be called from your
       programs.
*/

/* This is a CmdLine function for REXX.  It supports:
       *       OS/2 style command history. (1)
       *       Keeps insert state. (1)
       *       Command line _can_ include control chars.
       *       Allows for "hidden" input, for passwords.
       *       A call can be restricted from accessing the history.
       *       A call can be restricted from updating the history.
       *       A predefined value can be given to extended keys. (1) (2)

   NOTE:
       (1) These functions work ONLY if CmdLine is included in the source
           file for your program. 
       (2) Format: !history.nn="string" where nn is the DECIMAL value for
           the second character returned when the extended key is pressed.
*/

/* The following two lines are used in case CmdLine is called as an 
   external function */

parse source . . name
if translate(filespec("name",name))="CMDLINE.CMD" then signal extproc

CmdLine: procedure expose !history.
extproc: /* CmdLine called as an external proc or command line */

/* Parameters can be any combination of:
   Hidden : Characters are displayed as "*", no history, not kept.
   Forget : Do not add the result of this call to the history list.
   No History : Do not allow access to the history list.
   Clear : Clear the history list with this call (no input action made.)
           Also clears any predefined keys!
   Insert : Set insert mode ON.
   Overwrite : Set overwrite mode OFF.
   SameLine : Keep cursor on sameline after input. (Default: off)
   Required : null values are not accepted. (Default: off)
   Default : an initial value.
   Position: position for cursor (Default: end of input)
   Valid : Next parameter specifies the valid charachters (no translation)
           unless specified elsewhere. (1)
   Upper : Translate input to upper case. (1)
   Lower : Translate input to lower case. (1)
   Width : Next parameter specifies the maximum width. (1)
   Autoskip : Do not wait for enter after last char on a field with a width.
   X : Next parameter specifies the initial X (column) position.
   Y : Next parameter specifies the initial Y (row) position.
   Tag : Displays the next parameter as a prompt in front of the
            entry field.
   

   Only the first letter matters.  Enter each desired parameter seperated
   by commas.

   NOTES:
      (1)  Upper, Lower, Width, and VALID preclude access to the history 
           list.
*/

word=""
pos=0
hidden=0
history=1
keep=1
sameline=0
required=0
reset=0
valid=xrange()
upper=0
lower=0
width=0
autoskip=0
parse value SysCurPos() with x y
do i=1 to arg()
   cmd=translate(left(arg(i),1))
   parm=""
   if pos("=",arg(i))\=0 then
      parse value arg(i) with ."="parm
   select
      when cmd="D" then /* Default result */
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         word=parm
         if pos=0 then pos=length(word)
         end
      when cmd="P" then /* Initial Position */
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         if datatype(parm,"W") then
            pos=parm
         else if parm="*" then
            pos=length(word)
         end
      when cmd="X" then
         do
         parse value SysCurPos() with x y
         if parm="" then
            do;i=i+1;parm=arg(i);end
         if datatype(parm,"W") then
            Call SysCurPos parm,y
         end
      when cmd="Y" then
         do
         parse value SysCurPos() with x y
         if parm="" then
            do;i=i+1;parm=arg(i);end
         if datatype(parm,"W") then
            Call SysCurPos x,parm
         end
      when cmd="T" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         call charout, parm
         end
      when cmd="H" then
         do
         hidden=1
         keep=0
         history=0
         end
      when cmd="C" then
         reset=1
      when cmd="O" then
         !history.insert=0
      when cmd="I" then
         !history.insert=1
      when cmd="F" then
         keep=0
      when cmd="S" then
         sameline=1
      when cmd="R" then
         required=1
      when cmd="V" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         valid=parm
         history=0
         keep=0
         end
      when cmd="U" then
         do; upper=1; lower=0; history=0; keep=0; end
      when cmd="L" then
         do; upper=0; lower=1; history=0; keep=0; end
      when cmd="A" then
         autoskip=1
      when cmd="W" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         width=parm
         if \datatype(width,"Whole") then width=0
         if width<0 then width=0
         history=0
         keep=0
         end
    otherwise nop
    end
end

if width=0 then autoskip=0

if reset then
   do
   drop !history.
   return ""
   end

if symbol("!history.0")="LIT" then
   !history.0=0
if symbol("!history.insert")="LIT" then
   !history.insert=1

if width<>0 then
   if length(word)>width then
      word=left(word,width)

if pos>length(word)
   then pos=length(word)

if word\=="" then
   do
   if \hidden then call Charout, word
   else call Charout, copies("*",length(word))
   call Charout, copies(d2c(8),length(word)-pos)
   end

historical=-1
key=SysGetKey("NoEcho")
do forever /* while key\=d2c(13)*/
   if key=d2c(13) then /* Enter key */
      if required & word="" then nop;
      else leave
   else if (key=d2c(8)) then /* Backspace */
      do
      if length(word)>0 then
      do
      word=delstr(word,pos,1)
      call rubout 1
      pos=pos-1
      if pos<length(word) then
         do
         if \hidden then call charout, substr(word,pos+1)||" "
         else call charout, copies("*",length(substr(word,pos+1)))||" "
         call charout, copies(d2c(8),length(word)-pos+1)
         end
      end
      end
   else if key=d2c(27) then /* Escape */
      do
      if pos<length(word) then
         if \hidden then call charout, substr(word,pos+1)
         else call charout, copies("*",length(substr(word,pos+1)))
      call rubout length(word)
      word=""
      pos=0
      end
   else if key=d2c(10) | key=d2c(9) then /* Ctrl-Enter and TAB */
      nop; /* Ignored */
   else if key=d2c(224) | key=d2c(0) then /* Extended key handler */
      do
      key2=SysGetKey("NoEcho")
      select
         when key2=d2c(59) then /* F1 */
            if (history) & (!history.0<>0) then
               do
               if symbol('search')='LIT' then
                  search=word
               if symbol('LastFind')='LIT' then
                  search=word
               else if LastFind\=word
                  then search=word
               if historical=-1 then
                  start=!history.0
               else start=historical-1
               if start=0 then start=!history.0
               found=0
               do i=start to 1 by -1
                  if abbrev(!history.i,search) then
                     do
                     found=1
                     historical=i
                     LastFind=!history.i
                     leave
                     end
               end
               if found then
                  do
                  if pos<length(word) then
                     if \hidden then call charout, substr(word,pos+1)
                     else call charout, copies("*",length(substr(word,pos+1)))
                  call rubout length(word)
                  word=!history.historical
                  pos=length(word)
                  if \hidden then call charout, word
                  else call charout, copies("*",length(word))
                  end
               end
         when key2=d2c(72) then /* Up arrow */
            if (history) & (!history.0<>0) then
               do
               if historical=-1 then
                  historical=!history.0
               else historical=historical-1
               if historical=0 then
                  historical=!history.0
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=!history.historical
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
               end
         when key2=d2c(80) then /* Down arrow */
            if (history) & (!history.0<>0) then
               do
               if historical=-1 then
                  historical=1
               else historical=historical+1
               if historical>!history.0 then
                  historical=1
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=!history.historical
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
               end
         when key2=d2c(75) then /* Left arrow */
            if pos>0 then
               do
               call Charout, d2c(8)
               pos=pos-1
               end
         when key2=d2c(77) then /* Right arrow */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1,1)
               else call charout, "*"
               pos=pos+1
               end
         when key2=d2c(115) then /* Ctrl-Left arrow */
            if pos>0 then
               do
               call charout, d2c(8)
               pos=pos-1
               do forever
                  if pos=0 then leave
                  if substr(word,pos+1,1)\==" " & substr(word,pos,1)==" " then
                        leave
                  else
                     do
                     call charout, d2c(8)
                     pos=pos-1
                     end
               end
               end
         when key2=d2c(116) then /* Ctrl-Right arrow */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1,1)
               else call charout, "*"
               pos=pos+1
               do forever
                  if pos=length(word) then
                     leave
                  if substr(word,pos,1)==" " & substr(word,pos+1,1)\==" " then
                     leave
                  else
                     do
                     if \hidden then call Charout, substr(word,pos+1,1)
                     else call charout, "*"
                     pos=pos+1
                     end
               end
               end
         when key2=d2c(83) then /* Delete key */
            if pos<length(word) then
               do
               word=delstr(word,pos+1,1)
               if \hidden then call Charout, substr(word,pos+1)||" "
               else call Charout, copies("*",length(substr(word,pos+1)))||" "
               call charout, copies(d2c(8),length(word)-pos+1)
               end
         when key2=d2c(82) then /* Insert key */
            !history.insert=\!history.insert
         when key2=d2c(79) then /* End key */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1)
               else call Charout, copies("*",length(substr(word,pos+1)))
               pos=length(word)
               end
         when key2=d2c(71) then /* Home key */
            if pos\=0 then
               do
               call Charout, copies(d2c(8),pos)
               pos=0
               end
         when key2=d2c(117) then /* Control-End key */
            if pos<length(word) then
               do
               call Charout, copies(" ",length(word)-pos)
               call Charout, copies(d2c(8),length(word)-pos)
               word=left(word,pos)
               end
         when key2=d2c(119) then /* Control-Home key */
            if pos>0 then
               do
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=substr(word,pos+1)
               if \hidden then call Charout, word
               else call Charout, copies("*",length(word))
               call Charout, copies(d2c(8),length(word))
               pos=0
               end
      otherwise 
         if history & symbol('!history.key.'||c2d(key2))\='LIT' then /* Is there a defined string? */
            do
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               i=c2d(key2)
               word=!history.key.i
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
            end
      end
      end
   else if width=0 | length(word)<width then /* The key is a normal key & within width */
      do
      if upper then key=translate(key);
      if lower then key=translate(key,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
      if pos(key,valid)\=0 then
         do;
         if \hidden then call Charout, key;
         else call charout, "*"
         if !history.insert then
            word=insert(key,word,pos);
         else word=overlay(key,word,pos+1)
         pos=pos+1; 
         if pos<length(word) then
            do
            if \hidden then 
               call Charout, substr(word,pos+1)
            else call Charout, copies("*", length(substr(word,pos+1)))
            call Charout, copies(d2c(8),length(word)-pos)
            end
         end
      else beep(400,4)
      end
   if autoskip & length(word)=width then leave
   key=SysGetKey("NoEcho")
end
if \sameline then say
if (keep) & (word\=="") then
   do
   historical=!history.0
   if word\=!history.historical then
      do
      !history.0=!history.0+1
      historical=!history.0
      !history.historical=word
      end
   end
return word

rubout: procedure
arg n
do i=1 to n
   call Charout, d2c(8)||" "||d2c(8)
end
return
/* END OF CmdLine CODE BY ALBERT CROSBY */
