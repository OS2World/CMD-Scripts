/*------------------------------------------------------------------
 * RexxNews 
 *------------------------------------------------------------------
 * 04-27-93 by Albert L. Crosby
 *------------------------------------------------------------------
 * Portions of this package are based on rnr.cmd :
 *------------------------------------------------------------------
 * 08-09-92 by Patrick J. Mueller
 *------------------------------------------------------------------*/

"@echo off"

settings.version="RexxNews v. 1.1a by Albert Crosby"

/* Settings.varnames includes the variables that can be set and displayed
   with the RexxNews SET command.  The format is "variablename      type".
   The types can be any valid REXX datatype name.  The 'S' datatype is
   redefined as any String.  */

settings.varnames="",
                  "server               S",    /* Name of the current/default NNTP server                    */
                  "rows                 W",    /* Number of rows on the screen                               */
                  "cols                 W",    /* Number of columns on the screen                            */
                  "overlap              W",    /* Number of lines to overlap when displaying an list         */
                  "username             S",    /* Email name for the OS/2 user (at the os/2 workstation)     */
                  "hostname             S",    /* Host name for the OS/2 workstation                         */
                  "fullname             S",    /* Full name for the OS/2 user                                */
                  "organization         S",    /* Organization header field value                            */
                  "disclaimer           S",    /* Disclaimer header field value                              */
                  "replyto              S",    /* Reply-To header field value                                */
                  "timezone             S",    /* Time Zone abbreviation                                     */
                  "quotechar            S",    /* Character(s) to be used when quoting articles              */
                  "signature            S",    /* Name of signature file to include in posts/mail            */
                  "displayatgroup       B",    /* Display the first article after the group command?         */
                  "nextgroupafterlast   B",    /* Issue NEXTGROUP after the last article in a group?         */
                  "nextgroupatconnect   B",    /* Issue NEXTGROUP immeadiately on connecting to server?      */
                  "newarticlesatgroup   B",    /* List SUBJECTS for new articles after the group command?    */
                  "newgroupsatconnect   B",    /* List NEWGROUPS immeadiately on connecting to server?       */
                  "displayheaders       B",    /* Display headers when listing articles?                     */
                  "editor               S",    /* Name of the editor to use for composing posts              */
                  "rexxnewsdir          S",    /* Location of the REXXNEWS executeables and help files       */
                  "etcdir               S",    /* Location for ETC files (NEWSRC and alternate server CFG)   */
                  "tempdir              S",    /* Location for placing temporary files                       */
                  "groupname            S",    /* Name of the current group                                  */
                  "groupstat            S",    /* Subscription status of the current group                   */
                  "groupnewsrcline      W",    /* Line of the current group within the NEWSRC file           */
                  "grouphighest         W",    /* Highest article that has been seen in current group        */
                  "newsrcdate           W",    /* Date the NEWSRC file was last saved                        */
                  "newsrctime           W",    /* Time the NEWSRC file was last saved                        */
                  "newsrcname           S",    /* Name of the current NEWSRC file                            */
                  "newuser              B",    /* Is this the first time the user has ran RexxNews?          */
                  "askifsubmore         W",    /* Max groups to subscribe to automatically w/o prompting     */
                  "postingok            B",    /* Does the current server allow posting?                     */
                  "usexhdr              B",    /* Can the XHDR command be used with the current server?      */
                  "shellescapechar      S",    /* Charachter used to shell to OS/2 at the command prompt     */
                  "savenewsrcatexit     B",    /* Save the NEWSRC file in case of an abnormal exit           */
                  "sortcommand          S",    /* Name of the command to use when sorting                    */
                  "sortmaxbytes         W",    /* Maximum number of bytes the sort program can handle        */
                  ""

parse source . . name
settings.rexxnewsdir=filespec('drive',name)||filespec('path',name)

settings.etcdir=value('etc',,'OS2ENVIRONMENT')
settings.tempdir=value('tmp',,'OS2ENVIRONMENT')
if settings.tempdir="" then settings.tempdir=value('temp',,'OS2ENVIRONMENT')
if settings.tempdir="" then settings.tempdir=settings.etcdir

/*USER DEFINEABLE CONSTANTS & DEFAULT VALUES */
settings.newsrcname='newsrc' 
settings.newgroupsatconnect=1
settings.overlap=2           
settings.displayheaders=1    
settings.displayatgroup=1    
settings.savenewsrcatexit=1
settings.newarticlesatgroup=1
settings.editor="epm"
settings.username="os2user"
settings.fullname="unknown"
settings.replyto=""
settings.organization=""
settings.disclaimer=""
settings.signature=""
settings.timezone="CST"
settings.quotechar=">"
settings.askifsubmore=50
settings.nextgroupafterlast=1
settings.nextgroupatconnect=1
settings.shellescapechar="!"
settings.sortcommand="sort"
settings.sortmaxbytes=64512
/****************************/
/*Variables that shouldn't be changed by the user... */
settings.groupnewsrcline=0
settings.current=0
settings.unread=0
settings.groupname=""
first=0
last=0
remain=0
articleavailable=0

signal on halt name shutdown

parse arg serverarg .

call opening

/*------------------------------------------------------------------
 * initialize system function package
 *------------------------------------------------------------------*/
if RxFuncQuery("SysLoadFuncs") then
   do
   rc = RxFuncAdd("SysLoadFuncs","RexxUtil","SysLoadFuncs")
   if rc\=0 then
      do
      say "Error loading the RexxUtil package.  There is a problem with your"
      say "OS/2 installation."
      exit -1
      end
   rc = SysLoadFuncs()
   end

/*------------------------------------------------------------------
 * initialize socket function package
 *------------------------------------------------------------------*/
if RxFuncQuery("SockLoadFuncs") then
   do
   rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
   if rc\=0 then
      do
      say "Error loading the rxSock package.  rxSock is an extension to REXX"
      say "that allows it to utilize TCPIP and BSD-style Sockets.  You can"
      say "obtain rxSock via anonymous FTP from software.watson.ibm.com or"
      say "ftp-os2.nmsu.edu."
      exit -1
      end
   rc = SockLoadFuncs()
   end

/* Get info about this machine */
addr = SockGetHostId()
rc   = SockGetHostByAddr(addr,"host.!")
settings.hostname=host.!name
settings.realhostname=host.!name

parse value SysTextScreenSize() with settings.rows settings.cols
settings.originalrows=settings.rows
settings.originalcols=settings.cols

call opening

call loadsettings addslash(settings.rexxnewsdir)||'REXXNEWS.CFG'
call loadsettings addslash(settings.etcdir)||'REXXNEWS.CFG'
call loadsettings 'REXXNEWS.CFG'

altserver=0

if serverarg\="" then 
   do
   if settings.server\="" & translate(serverarg)\=translate(settings.server) then
      do
      altserver=1
      settings.newsrcname=addslash(settings.etcdir)||left(translate(serverarg,'-','.'),8,'_')||'.NRC'
      call loadsettings addslash(settings.etcdir)||left(translate(serverarg,'-','.'),8,'_')||'.CFG'
      end
   settings.server=serverarg
   end

if settings.newsrcname="newsrc" then settings.newsrcname=addslash(settings.etcdir)||settings.newsrcname

settings.newuser=0
if \loadnewsrc() then settings.newuser=\altserver

if (settings.server = "") then
   do
   say "Expecting a news server name to be passed as a parameter or in the the"
   say "configuration file."
   exit 1
   end

say
say 'Connecting to server...'

call ConnectServer settings.server

/* Don't show new users all of the groups that exist (unless they ask)... */
if settings.newuser then 
   call help 'intro'
else 
   do
   if settings.newgroupsatconnect then
      do
      call newgroups
      say
      end
   if settings.nextgroupatconnect then
      do 
      trc=nextgroup()
      if trc\=0 & settings.displayatgroup & settings.unread then settings.current=article(settings.current)
      end
   end

rc = Interact(sock)

/*------------------------------------------------------------------
 * quittin' time!
 *------------------------------------------------------------------*/

Shutdown:

trc = SendMessage(sock,"quit")

shutdownerr:

trc = SockSoclose(sock)

if settings.savenewsrcatexit\=0 then call fileout 'newsrc.',settings.newsrcname, 1, 1

if settings.rows\=settings.originalrows | settings.cols\=settings.originalcols then 
   "mode "settings.originalcols","settings.originalrows" 1>NUL 2>NUL"

exit

/*------------------------------------------------------------------
 * get command and execute in a loop
 *------------------------------------------------------------------*/
Interact:        procedure expose !. settings. newsrc. first last remain articleavailable sock
   sock = arg(1)

   /*------------------------------------------------------------------
    * commands is the commands currently implemented in rnr.cmd 
    *------------------------------------------------------------------*/
   rawcommands = "STAT BODY HEAD NEWNEWS RAW"

   group=settings.groupname

   do forever
      commandline=prompt()

      parse var commandline command args 

      if commandline="" then iterate

      if left(commandline,length(settings.shellescapechar))=settings.shellescapechar then
         do
         left(commandline,length(settings.shellescapechar)+1)
         iterate
         end

      if command=="DEBUG" then
         do
         say "Entering debug mode... (hopefully)"
         trace '?A'
         iterate
         end

      if abbrev("QUIT",translate(command)) then
         do
         settings.savenewsrcatexit=1
         leave
         end

      if ("EXIT"==translate(command)) then
         do
         call charout ,"Are you sure (newsrc will not be updated!)? "
         if translate(SysGetKey("Echo"))="Y" then 
            do
            settings.savenewsrcatexit=0
            leave
            end
         say
         iterate
         end

      if ("?" == command) | abbrev("HELP",translate(command)) then
         do
         rc = Help(args)
         iterate
         end

      if ("SET" == translate(command)) then
         do
         call set args
         iterate
         end

      if abbrev("QUERY",translate(command)) then
         do
         parse args args .
         call set args
         iterate
         end

      if ("SHOW" == translate(command)) then
         do
         call display 'newsrc.',1
         iterate
         end

      if abbrev("POST",translate(command)) then
         do
         call post group,"post"
         iterate
         end

      if abbrev("FOLLOWUP",translate(command)) then
         do
         if \articleavailable then
            do
            say "No article available to follow-up!"
            iterate
            end
         call post group,'followup'
         iterate
         end

      if abbrev("REPLY",translate(command)) then
         do
         if \articleavailable then
            do
            say "No article available to reply to!"
            iterate
            end
         call post group,'reply'
         iterate
         end

      if abbrev("MAIL",translate(command)) then
         do
         if \articleavailable then
            do
            say "No article available to mail!"
            iterate
            end
         call post group,'mail'
         iterate
         end

     if abbrev("MARK",translate(command)) then
        do
        call mark
        if settings.nextgroupafterlast then call nextgroup
        iterate
        end

      if abbrev("DETAILS",translate(command),2) then
         do
         call details
         iterate
         end

      if abbrev("OS2",translate(command)) then
         do
         args
         iterate
         end

      if abbrev("TIME",translate(command)) then
         do
         say 'Current time is:' time() 'on' date()
         say
         iterate
         end

      if abbrev("GROUP",translate(command)) then
         do
         if args=="" then
            do
            say 'Expecting a group name.'
            iterate
            end
         articleavailable=0
         call group args
         if settings.displayatgroup & settings.unread then settings.current=article(settings.current)
         iterate
         end

      if abbrev("NEXT",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         call next
         iterate
         end                                                    

      if abbrev("NEXTGROUP",translate(command)) then
         do
         trc=nextgroup(args)
         if trc\=0 & settings.displayatgroup & settings.unread then settings.current=article(settings.current)
         iterate
         end

      if abbrev("LAST",translate(command)) | abbrev("BACK",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         call last
         iterate
         end

      if abbrev("LISTGROUPS",translate(command)) then
         do
         call listgroups args
         iterate
         end

      if abbrev("ARTICLE",translate(command)) | abbrev("DISPLAY",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         settings.current=article(args)
         iterate
         end

      if abbrev("NEWGROUPS",translate(command)) then
         do
         call newgroups args
         iterate
         end

      if abbrev("AUTHORS",translate(command)) | abbrev("FROM",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         num=headers('from',args)
         if num\=0 then settings.current=article(num)
         iterate
         end

      if abbrev("SAVE",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         if \articleavailable then
            do
            say "No article available to be saved.  Display an article first."
            iterate
            end
         if args="" then
            do
            call charout , "Write article to file: "
            parse pull args
            if args="" then iterate
            end
         call fileout 'line.',args
         iterate
         end

      if abbrev("SAVENEWSRC",translate(command)) then
         do
         call fileout 'newsrc.',settings.newsrcname, 1, 1
         iterate
         end

      if abbrev("SUBJECTS",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         num=headers('subject',args)
         if num\=0 then settings.current=article(num)
         iterate
         end

      if abbrev("SUBSCRIBE",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         settings.groupstat=':'
         call updatenewsrc group
         say "Marked group "settings.groupname" as subscribed."
         iterate
         end

      if abbrev("UNSUBSCRIBE",translate(command)) then
         do
         if group="" then
            do
            say "You must select a group first."
            iterate
            end
         settings.groupstat='!'
         call updatenewsrc group
         say "Marked group "settings.groupname" as unsubscribed."
         iterate
         end

      if abbrev("SEARCH",translate(command)) then
         do
         call search(args)
         iterate
         end

      if abbrev("EDITNEWSRC",translate(command)) then
         do
         call editnewsrc
         iterate
         end

      if wordpos(translate(command),rawcommands)=0 then
         do
         say 'Unknown command: 'command
         iterate
         end

      if "RAW"==translate(command) then commandline=args

      articleavailable=0
      trc = SendCommand(sock,commandline)

      call display 'line.',1

   end

   return ""

/*------------------------------------------------------------------
 * display
 *------------------------------------------------------------------*/
Display: 
   parse arg list, n, string, skip, keylist, firstword, lastword
   if list="" then return ""
   if \datatype(n,"W") then n=2
   if \datatype(skip,"W") then skip=0
   if \datatype(firstword,"W") then firstword=0
   if lastword\="" & \datatype(lastword,"W") then lastword=""
   _r=skip+1
   _cls=0;
   _rot13=0;
   say

   interpret "do _i = n to "list"0+1;",
      "if pos(d2c(12),"list"_i,1)\=0 then do; _cls=1;_r=_r+((settings.rows-settings.overlap)-_r//(settings.rows-settings.overlap));end;",
      "if _r//(settings.rows-settings.overlap)=0 | _i>"list"0 then",
         "do;",
         'call charout ,"---MORE'string'---";',
         "if _i>"list"0 then call charout ,'<END>';",
         'key=SysGetKey('NOECHO');',
         'call charout ,d2c(13)||copies(" ",settings.cols-1)||d2c(13);',
         'if pos(translate(key),translate(keylist))\=0 then return translate(key);',
         'if "="==key then do;call charout , "Move to line: ";parse pull _line;if _line>0 & _line<="list"0 then _i=_line;else _i=_i-1;call SysCls;_r=1;end;',
         'if "Q"==translate(key) then return "";',
         'if d2c(13)==key then _r=_r-1;',
         'if "U"==translate(key) & _i>2*(settings.rows-settings.overlap) then _i=_i-2*(settings.rows-settings.overlap);',
         'if "T"==translate(key) then do;call SysCls;_i=n;_r=1;end;',
         'if "^"==translate(key) then do;call SysCls;_i=n;_r=1;end;',
         'if "B"==translate(key) then do;call SysCls;_i='list'0-(settings.rows-settings.overlap);_r=1;end;',
         'if "$"==translate(key) then do;call SysCls;_i='list'0-(settings.rows-settings.overlap);_r=1;end;',
         'if "?"==translate(key) then do;call help("more");_i=_i-(settings.rows-settings.overlap);end;',
         'if "D"==translate(key) then do;_rot13=\_rot13;call SysCls;_i=n;_r=1;end;',
         'if _cls then do; Call SysCls; _cls=0; end;',
         'if length('list'_i)>settings.cols',
            'then _r=_r+(length('list'_i)%settings.cols);',
         'if _i<1 then _i=1;',
         'end;',
      "_line="list"_i;",                                                                            
      "if _rot13 then _line=translate(_line,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz','NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm');",
      "if _i<="list"0 then ",
         "if firstword=0 then say _line;",
         "else say subword(_line,firstword,lastword);",
      "_r=_r+1;",
   "end"
   return ""

/* An Alternate display function that limits displayed lines with a 'needle' */

DisplayN:
   parse arg list, n, string, needle, keylist
   if list="" then return
   if n="" then n=2
   _r=1
   say

   interpret "do _i = n to "list"0+1;",
      "if _r//(settings.rows-settings.overlap)=0 | _i>"list"0 then",
         "do;",
         'call charout ,"---MORE'string'---";',
         "if _i>"list"0 then call charout ,'<END>';",
         'key=SysGetKey('NOECHO');',
         'call charout ,d2c(13)||copies(" ",settings.cols-1)||d2c(13);',
         'if pos(translate(key),translate(keylist))\=0 then return translate(key);',
         'if "Q"==translate(key) then return;',
         'if d2c(13)==key then _r=_r-1;',
         'if "U"==translate(key) & _i>2*(settings.rows-settings.overlap) then _i=_i-2*(settings.rows-settings.overlap);',
         'if "T"==translate(key) then do;call SysCls;_i=n;_r=1;end;',
         'if "^"==translate(key) then do;call SysCls;_i=n;_r=1;end;',
         'if "B"==translate(key) then do;call SysCls;_i='list'0-(settings.rows-settings.overlap);_r=1;end;',
         'if "$"==translate(key) then do;call SysCls;_i='list'0-(settings.rows-settings.overlap);_r=1;end;',
         'if "?"==translate(key) then do;call help("more");_i=_i-(settings.rows-settings.overlap);end;',
         'if length('list'_i)>settings.cols',
            'then _r=_r+(length('list'_i)%settings.cols);',
         'if _i<1 then _i=1;',
         'end;',
      "if _i=1 | pos(translate(needle),translate("list"_i))\=0 then",
         "do;",
         "if _i<="list"0 then say "list"_i;",
         "_r=_r+1;",
         "end;",
   "end"
   return ""

/*------------------------------------------------------------------
 * help
 *------------------------------------------------------------------*/
Help: procedure expose settings. newsrc. sock
   arg topic
   if topic="" then topic="general"
   if "TOPICS"==translate(topic) then
      do
      call SysFileTree addslash(settings.rexxnewsdir)||'*.rxn','topics','FO'
      do i=topics.0 to 1 by -1
         n=i+2
         topics.n=linein(topics.i)
         call stream topics.i,'c','CLOSE'
      end
      n=topics.0+3
      topics.n='topics'
      topics.0=n
      topics.1=settings.version
      topics.2="Help is available for the following topics:"
      call SysCls
      call Display 'topics.',1,' (RexxNews Help Topics)'
      return 1
      end
   if filein('help.',addslash(settings.rexxnewsdir)||topic||'.rxn')=0 then
      if filein('help.',addslash(settings.rexxnewsdir)||strip(left(topic,8))||'.rxn')=0 then
         do
         say "No help available for '"topic"'."
         say "Type HELP for general information or HELP INTRO for an introduction to RexxNews"
         return 0
         end
   call SysCls
   call Display 'help.',1,' ('||topic||' help)'
   return 1

/*------------------------------------------------------------------
 * Issue a command to the server that expects a response
 *------------------------------------------------------------------*/

SendCommand: procedure expose !. line. settings. newsrc. sock
   sock = arg(1)
   data = arg(2) || d2c(13) || d2c(10)

   trc = SendMessage(sock,data)
   if trc\=-1 then 
      do
      trc = GetResponse(sock)
      parse var line.1 code msg
      end
   if trc=-1 | (code=503 & pos('TIME',translate(msg))\=0 and pos('OUT',translate(MSG))\=0) then
      do
      rc = SockSoClose(sock)
      call ConnectServer settings.server
      trc=SendMessage(sock,'group '||settings.groupname)
      trc=GetResponse(sock)
      trc=SendMessage(sock,'stat '||settings.current)
      trc=GetResponse(sock)
      trc=SendMessage(sock,data)
      trc=GetResponse(sock)
      end

   return trc

/*------------------------------------------------------------------
 * get a response from the server
 *------------------------------------------------------------------*/
GetResponse:     procedure expose !. line. settings. newsrc. sock
   sock = arg(1)

   moreids = "100 215 220 221 222 230 231"

   progress="\|/-"

   line.0 = 1
   line.1 = GetResponseLine(sock)

   parse var line.1 rid msg

   if rid=400 then 
      do
      say 'The server has closed the connection with the following message:'
      say msg
      signal shutdownerr
      end

   if (wordpos(rid,moreids) = 0) then
      return ""

   o=0

   do forever
      call charout , substr(progress,1+o//length(progress),1)||d2c(13)
      o = line.0 + 1

      line.o = GetResponseLine(sock)

      if (line.o = ".") then
         do
         call charout , " "||d2c(13)
         return ""
         end

      line.0 = o
   end
   call charout " "||d2c(13)

   return ""

/*------------------------------------------------------------------
 * get a line from the server
 *------------------------------------------------------------------*/
GetResponseLine: procedure expose !. settings. newsrc. sock
   sock = arg(1)

   crlf = d2c(13) || d2c(10)

   if (symbol('!.buff') = "LIT") then
      !.buff = ""

   do while (pos(crlf,!.buff) = 0)
      rc = SockRecv(sock,"data",8000)
      !.buff = !.buff || data
   end

   p = pos(crlf,!.buff)

   line = substr(!.buff,1,p-1)
   !.buff = substr(!.buff,p+2)

   return line

/*------------------------------------------------------------------
 * send a string to the server
 *------------------------------------------------------------------*/
SendMessage:     procedure expose !. settings. newsrc. sock
   sock = arg(1)
   data = arg(2) || d2c(13) || d2c(10)

   len = length(data)
   do while (len > 0)
      i = SockSend(sock,data);

      if (errno \= 0) then
         return Error(-1,rc,"Error sending data to server.")

      if (i <= 0) then
         return Error(sock,100,"Server closed the connection.")

      data = substr(data,len+1)
      len  = length(data)
   end

   return 0

/*------------------------------------------------------------------
 * exit with a message and return code
 *------------------------------------------------------------------*/
Error: procedure expose settings. newsrc. sock
   sock = arg(1)
   retc = arg(2)
   msg  = arg(3)

   if (sock \= -1) then
      rc = SockSoClose(sock)

   say msg

   return retc

opening:
   /*------------------------------------------------------------------
    * initialize system function package
    *------------------------------------------------------------------*/
   if RxFuncQuery("SysLoadFuncs") then
      do
      rc = RxFuncAdd("SysLoadFuncs","RexxUtil","SysLoadFuncs")
      rc = SysLoadFuncs()
      end
   
   /*------------------------------------------------------------------
    * initialize socket function package
    *------------------------------------------------------------------*/
   if RxFuncQuery("SockLoadFuncs") then
      do
      rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
      rc = SockLoadFuncs()
      end

   call SysCls
   say settings.version 
   say 
   say "A NNTP NewsReader Client in REXX and rxSock for OS/2 2.x"
   say
   return

filein:
   arg stem, filename
   if arg()<2 then return 0
   if stem="" | filename="" then 
      do
      say "Error reading file "filename" into stem "stem
      return 0
      end
   _i=0
   if stream(filename,'c','OPEN READ')=='READY:' then
      do
      interpret 'do while stream(filename,"S")="READY";',
         "_i=_i+1;",
         stem"_i=linein(filename);",
      'end;',
      stem"0=_i"
      end
   call stream filename,'c','CLOSE'
   interpret '_n='stem'0;if 'stem'_n="" then do;'stem'0=_n-1;_i=_n;end'
   return _i

loadsettings: procedure expose settings. newsrc. sock
   parse arg settingfile
   if settingfile="" then return 0;
   else if filein('set.',settingfile)=0 then return 0
   do i=1 to set.0
      if set.i\="" & left(set.i,1)\=';' then call set(set.i)
   end
   if settings.rows\=settings.originalrows | settings.cols\=settings.originalcols then 
      "mode "settings.cols","settings.rows" 1>NUL 2>NUL"
   parse value SysTextScreenSize() with settings.rows settings.cols
   return 1

loadnewsrc:
   say 'Processing newsrc file...'
   say settings.newsrcname
   drop newsrc.
   if stream(settings.newsrcname,'c','query exists')\="" then
      do
      datetime=stream(settings.newsrcname ,'c','query datetime')
      parse var datetime mo'-'dd'-'yy hh':'mm':'ss
      settings.newsrcdate=strip(yy||mo||dd)
      settings.newsrctime=strip(hh||mm||ss)
      call filein 'newsrc.',settings.newsrcname
      return 1
      end
   else
      do
      settings.newsrcdate=""
      settings.newsrctime=""
      newsrc.0=0
      return 0
      end

updatenewsrc: procedure expose settings. newsrc. sock
   parse arg group, article
   if translate(group)\=translate(settings.groupname) then
      do
      say "Error updating newsrc: wrong group."
      return
      end
   i=settings.groupnewsrcline
   if article>settings.grouphighest then 
      newsrc.i=group||settings.groupstat||' 1-'||article
   return ""

prompt: procedure expose sock group first last settings. !. newsrc. sock
   say
   if group\="" then 
      do
      trc = SendCommand(sock,'stat')
      parse var line.1 code settings.current msgid .
      call charout , 'Group: 'group '('
      if settings.groupstat\=':' then call charout , 'un'
      say "subscribed)"
      Say  "Articles available: "first"-"last" --- Current article "settings.current" ["last-settings.current" remaining]"
      end
   if settings.newuser then
      do
      say "Enter HELP INTRO to review the introduction to RexxNews."
      say "Use the LISTGROUPS command to find groups. (See HELP LISTGROUPS)"
      if newsrc.0>0 then
         say "Use the NEXTGROUP command to see the next group with unread articles."
      if group="" then
         say "Enter Group <groupname> to move to a group."
      else say "Enter Display to see the current article or Next for the next article."
      end
   say "Enter RexxNews command (or help or quit)"
   parse pull commandline
   return commandline

fileout:
   parse arg stem, filename, compress, overwrite, quiet, _needle
   if overwrite\="1" then overwrite=0
   if compress\="1" then compress=0
   if \datatype(quiet,'B') then quiet=0
   if stem="" then return 0;
   interpret "if "stem"0 = 0 then return 0"
   append=0
   exists=0
   if stream(filename,'c','query exists')\="" then exists=1
   if \overwrite & exists then
      do
      if promptkey("File "filename" already exists.  Append? ","YN")="Y" then 
         append=1
      else if promptkey("Replace it? ","YN")="N" then return 0
      say
      end
   call stream filename,'c','open write'
   if \append & exists then call lineout filename,,1
   if stream(filename,'s')\="READY" then
      do
      say "Error writing to file "filename": "_state
      call stream filename,'c','CLOSE'
      return 0
      end
   _n=0
   interpret 'do _i=1 to 'stem'0;',
      'if (\compress) | strip('stem'_i)\="" then',
         'do;',
         'if _needle="" | pos(translate(needle),translate('stem'_i))\=0 then',
            'do;',
            '_n=_n+1;',
            'call lineout filename, 'stem'_i;',
            'end;',
         'end;',
   'end'
   call stream filename,'c','CLOSE'
   if \quiet then say _n' line(s) written to 'filename
   return _n

checknewsrc: procedure expose settings. newsrc. sock
   parse arg group subscribe
   if group="" then return 0
   subscribe=translate(left(subscribe,1))
   do i= 1 to newsrc.0
      parse var newsrc.i name pointer
      if name="" then iterate
      stat=right(name,1)
      if pos(stat,':!')=0 then
         do
         stat=" "
         end
      else
         do
         name=left(name,length(name)-1)
         end
      if translate(name)=translate(group) then
         do
         settings.groupstat=stat
         settings.groupname=name
         settings.groupnewsrcline=i
         n=translate(pointer,"  ","-,")
         n=word(n,words(n))
         if \datatype(n,'w') then n=0
         settings.grouphighest=n
         if pos(settings.groupstat,':!')=0 then
            do
            if pos(subscribe,"YN")\=0 then
               key=promptkey(group' is currently neither subscribed nor unsubscribed.  Subscribe (Y/N)? ','YN','Y')
            else key=subscribe
            if key='Y' then settings.groupstat=':'
            else settings.groupstat='!'
            newsrc.i=group||settings.groupstat||' '||pointer
            end
         return n
         end
   end
   settings.groupnewsrcline=i
   settings.grouphighest=0
   if pos(subscribe,"YN")=0 then
     do
     call charout , "Subscribe to "group"? "
     do until pos(key,"YN")\=0
        key=translate(SysGetKey('NoEcho'))
     end
     say key
     end
   else key=subscribe
   if key='Y' then settings.groupstat=':'
   else settings.groupstat='!'
   settings.groupname=group
   newsrc.0=i
   newsrc.i=group||settings.groupstat||' 0'
   return i

newgroups: procedure expose sock settings. !. newsrc.
   arg _datetime
   parse var _datetime _date _time

   if _time="" then _time="000000"
   if _date="" then
      do
      _date=settings.newsrcdate
      _time=settings.newsrctime
      end
   trc = SendCommand(sock,'newgroups'||' '||_date||' '||_time)
   parse var line.1 code number id  .
   if line.0=1 then
      do
      say 'No new groups since '_date _time'.'
      return
      end
   line.1='New groups since '_date _time'.'
   type='L'
   signal _listgroups
   return
   
xhdr: procedure  expose sock settings. !. newsrc.
   parse arg tag, article
   if \datatype(article,'W') then article=""
   if tag="" then tag="subject"
   if settings.usexhdr then 
      do
      trc = SendCommand(sock,'xhdr '||tag||' '||article)
      value=""
      if line.0>1 then parse var line.2 article value
      if value='(none)' then value=""
      return value
      end
   trc = SendCommand(sock,'head '||article)
   parse var line.1 code .
   if code\=221 then return ""
   value=""
   do i=2 to line.0
      parse var line.i ln":"value
      if translate(tag)=translate(ln) then leave
      value=""
   end
   trc = SendCommand(sock,'stat '||settings.current)
   return value

article:
   arg num
_article:
   if num="$" then num=last
   else if num="^" then num=first
   else if \datatype(num,'W') then num=settings.current
   if \articleavailable | num\=settings.current then
      do
      if settings.displayheaders=1
         then command='ARTICLE'
         else command='BODY'
      trc = SendCommand(sock,command||' '||num)
      parse var line.1 code number id .
      if code\=220 then
         do
         say "Error retrieving article:  Code "code
         articleavailable=0
         return 0
         end
      articleavailable=1
      call updatenewsrc settings.groupname, number
      end
   else number=settings.current
   call SysCLS
   settings.current=number
   key=Display('line.', ,' (line "_i-1" of "'line.0'" article "settings.current" of "last")', ,'NLWRFM?HGPAS*')
   if key='N' then signal next
   else if key='L' then signal last
   else if key='*' then
      do
      call mark
      num=settings.current
      if settings.nextgroupafterlast then
         do
         num=nextgroup(subscribedonly)
         if num=0 then return settings.current
         articleavailable=0
         signal _article
         end
      else return settings.current
      end
   else if key='S' then
      do
      _num=headers('subject')
      if _num=0 then signal _article
      articleavailable=0
      trc=SendCommand(sock,'stat '||_num)
      parse var line.1 code _num .
      if code\=223 then 
         do
         say "No such article"
         signal _article
         end
      num=_num
      settings.current=num
      signal _article
      end
   else if key='W' then
      do
      call charout , "Write article to file: "
      parse pull fn
      if fn\="" then call fileout 'line.',fn
      signal _article
      end
   else if key='A' then
      do
      call charout , "Skip to article (available articles:"first"-"last"): "
      parse pull _num
      if \datatype(_num,'W') | pos(_num,'^$')\=0 then signal _article
      articleavailable=0
      trc=SendCommand(sock,'stat '||_num)
      parse var line.1 code _num .
      if code\=223 then 
         do
         say "No such article"
         signal _article
         end
      num=_num
      settings.current=num
      signal _article
      end
   else if key='R'|key='F'|key='M'|key='P' then
      do 
      call post group,key
      signal _article
      end
   else if key='?'|key='H' then
      do
      call help 'reading'
      signal _article
      end
   else if key='G' then
      do
      call charout , 'Group: '
      parse pull gn
      articleavailable=0
      if gn="" then signal _article
      number=group(gn)
      num=settings.current
      signal _article
      end
   return settings.current

headers: procedure expose settings. sock first last !. newsrc.
   parse arg tag, range, needle
   if range="" then range=settings.current||'-'||last
   if range="*" then range=first||'-'||last
   if tag="" then tag='subject'
   if (translate(tag)\="GROUPS") then 
      do
      say "Retreiving the "tag" field for article(s) "range"..."
      msg=tag||' fields for article(s) 'range
      if needle\="" then msg=msg||' containing 'needle':'
      else msg=msg||':'
      if settings.usexhdr then
         do
         trc = SendCommand(sock,'xhdr '||tag||' '||range)
         parse var line.1 code number id .
         end
      else
         do
         parse var range begin'-'end
         n=2
         do i=begin to end
            line.n=i||' '||xhdr(tag,i)
         end
         code=221
         end
      end
   else 
      do
      say "Retrieving a list of all groups... This may take a few moments."
      msg='List of groups containing '||needle||' in their names:'
      trc = SendCommand(sock,'list')
      parse var line.1 code number id .
      end
   if code\=221 & code\=215 then
      do
      say "Error retrieving list:  Code "code
      return 0
      end
   if line.0=1 then
      do
      call charout ,"No articles in "range
      if needle="" then say "."
      else say " matching "needle"."
      return 0
      end
   line.1=msg
   call SysCLS
   if needle="" then call Display 'line.',1 
   else call DisplayN 'line.',1,,needle
   if promptkey("Move to one of these articles now? ","YN","Y")="N" then return 0
   call charout , "Article number: "
   parse pull number
   if \datatype(number,'W') then number=0
   return number

set: procedure expose settings. newsrc. sock
   parse arg command
   if command\="" then
      do
      parse var command variable value 
      i=wordpos(translate(variable),translate(settings.varnames))
      if i//2=0 then
         do
         say "Unknown variable: "variable
         return 0
         end
      else
         if value="" then
            do
            say left("Variable",25)||left("Value",35)||" Type"
            say left("========",25)||left("=====",35)||" ===="
            interpret "say left(word(settings.varnames,i),25)||left(settings."word(settings.varnames,i)",35)||' '||word(settings.varnames,i+1)"
            return 1
            end
         else
         do
         if word(settings.varnames,i+1)="S" | datatype(value,word(settings.varnames,i+1)) then
            interpret "settings."variable"=value"
         else say "Improper argument type for "variable"."
         return 1
         end
      end
   set.0=words(settings.varnames)/2+4
   set.1=settings.version "Settings"
   set.2=""
   set.3=left("Variable",25)||left("Value",35)||" Type"
   set.4=left("========",25)||left("=====",35)||" ===="
   n=4
   do i=1 to words(settings.varnames) by 2
      n=n+1
      interpret "set.n=left(word(settings.varnames,i),25)||left(settings."word(settings.varnames,i)",35)||' '||word(settings.varnames,i+1)"
   end
   call Display 'set.',1,' (RexxNews SET values)'
   return

details:
   say
   say "Current group: "group
   say "Available articles: "remain
   say "First article: "first
   say "Last article: "last
   say "Current article: "settings.current
   if group\="" then 
      do
      say "Article can be saved:" articleavailable
      say "Subject: "xhdr(subject)
      say "From:    "xhdr(from)
      say "Lines:   "xhdr(lines)
      _i=settings.groupnewsrcline
      say "newsrc line #"_i
      say "newsrc line: "newsrc._i
      end
   return

search: procedure expose settings. sock first last !. newsrc.
   arg args
   if args="" then return 0
   !field=""
   parse var args field rest 1 "RANGE " range . 1 "FOR " needle
   if field='RANGE' | field='FOR' | (needle="" & rest="") then !field='SUBJECT'
   if (needle="" & rest="") then needle=field
   if range="" then range=settings.current||'-'||last
   else if range="*" then range=first||'-'||last
   if !field\="" then field=!field
   if settings.groupname="" & "GROUPS"\=translate(field) then
      do
      say "You must select a group first."
      return 0
      end
   if needle="" then
      do
      say "The syntax of the SEARCH command is:"
      say "  SEarch [<field>] [RANGE <range>] [FOR] <string>"
      say "  See HELP SEARCH for more information."
      return 0
      end
   call headers field, range, needle
   return 1

next: 
   if settings.current=last then
      do 
      say "No more articles."
      if settings.nextgroupafterlast then
         do
         num=nextgroup(subscribedonly)
         if num=0 then return settings.current
         articleavailable=0
         signal _article
         end
      return settings.current
      end
   trc = SendCommand(sock,'next')
   parse var line.1 . settings.current .
   num=settings.current
   articleavailable=0
   signal _article

last: 
   if settings.current=first then
      do 
      say "No previous article."
      return settings.current
      end
   trc = SendCommand(sock,'LAST')
   parse var line.1 . settings.current .
   num=settings.current
   articleavailable=0
   signal _article

nextgroup:
   parse arg type
   type=translate(left(type,1))
   if type='S'|type=''|type='1' then subscribedonly=1
   else subscribedonly=0
   __gn=-99
_nextgroup:
   articleavailable=0
   if settings.groupnewsrcline>=newsrc.0 then
      do
      _gn=1
      settings.groupnewsrcline=1
      end
   else _gn=settings.groupnewsrcline+1
   if __gn=-99 then __gn=_gn
   else if __gn=_gn then
      do
      say "There are no newsgroups left with unread articles."
      return 0
      end
   parse var newsrc._gn name .
   stat=right(name,1)
   if pos(stat,':!')=0 then
      do
      stat=" "
      end
   else
      do
      name=left(name,length(name)-1)
      end
   _grc=group(name)
   if _grc=0 then signal _nextgroup
   if _grc<0 then
      do
      settings.groupnewsrcline=settings.groupnewsrcline+1
      signal _nextgroup
      end
   if settings.groupstat='!' & subscribedonly then signal _nextgroup
   say "Advancing to group "settings.groupname
   return _grc

group: procedure expose sock !. settings. group newsrc. articleavailable first last
   parse arg args

   if args="" then return -2
   trc=SendCommand(sock,'group '||args)
   parse var line.1 code .
   if code=411 then 
      do
      say 'No active group named 'args'.'
      group=settings.groupname
      return -1
      end
   if code\=211 then
      do
      say 'An error occured while issuing the command: group '||args
      say line.1
      group=settings.groupname
      return -1
      end
   parse var line.1 code remain first last group .
   if remain>0 then
      do
      settings.unread=1
      settings.current=checknewsrc(group)
      if settings.current=0 then 
         do
         settings.groupname=group
         return -1
         end
      if first>settings.current then settings.current=first
      else 
         do
         if settings.current>=last then 
            do
            say "No unread articles in "group
            settings.unread=0
            settings.current=last
            trc = SendCommand(sock,'stat '||settings.current)
            return 0
            end
         else
            do
            trc = SendCommand(sock,'stat '||settings.current)
            parse var line.1 code .
            if code\=223 then settings.current=first
            else
               do
               trc = SendCommand(sock,'next')
               parse var line.1 code .
               if code=223 then parse var line.1 . settings.current .
               end
            end
         end
      if settings.newarticlesatgroup then call headers 'subject'
      end
   else
      do
      say "No articles in group "group
      group=""
      articleavailable=0
      settings.unread=0
      settings.current=0
      return -1
      end
   return settings.current

ConnectServer: procedure expose sock settings. !. newsrc.
   arg servername

   /*------------------------------------------------------------------
    * get address of server
    *------------------------------------------------------------------*/
   rc = SockGetHostByName(settings.server,"host.!")
   if (rc = 0) then
      do
      say "Unable to resolve server name" settings.server
      exit
      end
   
   server = host.!addr
   
   /*------------------------------------------------------------------
    * open socket
    *------------------------------------------------------------------*/
   sock = SockSocket("AF_INET","SOCK_STREAM",0)
   if (sock = -1) then
      do
      say "Error opening socket:" errno
      exit
      end
   
   /*------------------------------------------------------------------
    * connect socket
    *------------------------------------------------------------------*/
   server.!family = "AF_INET"
   server.!port   = 119
   server.!addr   = server
   
   trc = SockConnect(sock,"server.!")
   if (trc = -1) then
      do
      trc=Error(sock,rc,"Error connecting to newsserver :" errno)
      signal shutdownerr
      end
   
   trc = GetResponse(sock)
   do i = 1 to line.0
      say line.i
   end
   
   parse var line.1 code .
   if code=200 then
      settings.postingok=1
   else settings.postingok=0
   
   if code\=200 & code\=201 then
      do
      settings.savenewsrcatexit=0
      signal shutdown
      end
   
   trc = SendCommand(sock,"xhdr")
   
   parse var line.1 code .
   if code=501 then settings.usexhdr=1
   else settings.usexhdr=0
   
   trc = SendCommand(sock,"MODE READER")
   parse var line.1 code msg 
   if code\=500 then say "Server supports the INN extensions."
   return ""

post: procedure expose settings. sock !. newsrc.
   parse arg group, type, recipient

   type=left(translate(type),1)

   if type="F" then followup=1
   if type="R" | type="M" then mail=1

   if type="M" & recipient="" then
      do
      call charout , "Forward article to: "
      parse pull recipient
      if recipient="" then return 0
      end

   if followup\=1 then followup=0
   if mail\=1 then mail=0

   tempfile=SysTempFileName(addslash(settings.tempdir)||'POST????.RXN')
   messageid='<'||date('B')||'.'||time('S')||'@'||settings.hostname||'>'

   validgroups=0
   if mail then 
      do
      newsgroups=group
      validgroups=1
      end
   if followup then 
      do
      validgroups=1
      newsgroups=xhdr('Newsgroups',settings.current)
      followupto=xhdr('Followup-to',settings.current)
      if translate(followupto)='SENDER' | translate(followupto)='POSTER' | pos('@',followupto)\=0 then
         do
         mail=1
         if pos('@',followupto)\=0 then
            recipient=followupto
         else recipient=""
         end
      else if followupto\="" then newsgroups=followupto
      end

   if \settings.postingok & \mail then
      do
      say "This server does not allow posting."
      return 0
      end

   if \validgroups then
      do
      say
      say "Enter the name of the newsgroup(s) to post to (or '.' to abort)."
      if group\="" then say "Press enter by itself to choose the group "group":"
      end
   do while \validgroups
      say
      call charout , 'Newsgroups: '
      parse pull newsgroups
      if newsgroups=="." then return 0
      if newsgroups="" then newsgroups=group
      if newsgroups\="" & pos(" ",strip(newsgroups))=0 then validgroups=1
   end
   if followup | mail then
      do
      subject=xhdr('subject',settings.current)
      keywords=xhdr('keywords',settings.current)
      summary=xhdr('summary',settings.current)
      distribution=xhdr('distribution',settings.current)
      end
   else 
      do
      call charout , "Subject: "
      parse pull subject
      if subject="" then 
         do
         say "No subject... posting aborted."
         return 0
         end
      call charout , "Keywords: "
      parse pull keywords
      call charout , "Summary: "
      parse pull summary
      call charout , "Distribution: "
      parse pull distribution
      end

   if mail & recipient="" then
      do
      from=xhdr('from',settings.current)
      _replyto=xhdr('reply-to',settings.current)
      if _replyto="" then recipient=from
      else recipient=_replyto
      end

   n=0
   if newsgroups\="" then
      do
      n=n+1
      posting.1="Newsgroups: "||newsgroups
      end
   if mail then
      do
      n=n+1
      posting.n="To: "recipient
      end
   n=n+1
   if translate(settings.username)="UNKNOWN" then 
      call queryfield 'username', 'your user name'
   posting.n="From: "||settings.username||"@"||settings.hostname
   if translate(settings.fullname)="UNKNOWN" then
      call queryfield 'fullname', 'your full name'
   if settings.fullname\="" then posting.n=posting.n||' ('||settings.fullname||')'
   n=n+1
   posting.n="Subject: "
   if (mail|followup) & translate(left(subject,3))\="RE:" then posting.n=posting.n||"Re: "
   posting.n=posting.n||subject
   if translate(settings.organization)="UNKNOWN" then
      call queryfield 'organization', 'your organization'
   if settings.organization\="" then
      do
      n=n+1
      posting.n="Organization: "||settings.organization
      end
   n=n+1
   posting.n="Message-ID: "||messageid
   if summary\="" then
      do
      n=n+1
      posting.n="Summary: "||summary
      end
   if keywords\="" then
      do
      n=n+1
      posting.n="Keywords: "||keywords
      end
   if translate(settings.replyto)="UNKNOWN" then
      call queryfield 'replyto', 'the address for replies'
   if settings.replyto\="" then
      do
      n=n+1
      posting.n="Reply-to: "||settings.replyto
      end
   if translate(settings.disclaimer)="UNKNOWN" then
      call queryfield 'disclaimer', 'a disclaimer'
   if settings.disclaimer\="" then
      do
      n=n+1
      posting.n="Disclaimer: "||settings.disclaimer
      end
   n=n+1
   posting.n="X-Newsreader: "||settings.version
   if distribution\="" then
      do
      n=n+1
      posting.n="Distribution: "||distribution
      end
   n=n+1
   posting.n="Date: "||date('W')||', '||date()||' '||time()||' '||settings.timezone
   if followup | mail then
      do
      n=n+1
      posting.n="References: "||xhdr('references',settings.current)||" "||xhdr('Message-ID',settings.current)
      trc=SendCommand(sock,'body')
      if line.0>1 then
         do
         n=n+1
         posting.n=""
         n=n+1
         refline="In article "||xhdr('message-id',settings.current)||',  '||xhdr('From',settings.current)||" writes:"
         if length(refline)<79 then
            posting.n=refline
         else
            do
            i=words(refline)
            do while wordindex(refline,i)>79
               i=i-1
               if i=0 then leave
            end
            if i=0 then posting.n=refline
            else
               do
               posting.n=subword(refline,1,i-1)
               n=n+1
               posting.n='  '||subword(refline,i)
               end
            end
         do i=2 to line.0
            n=n+1
            posting.n=settings.quotechar||line.i
         end
         end
      end
   n=n+1
   posting.n=""
   n=n+1
   posting.n=""
   if settings.signature\="" then
      do
      sig.0=0
      n=n+1
      posting.n="--"
      if filein('sig.',settings.signature)=0 then
         if pos('/',settings.signature)\=0 then
            if filein('sig.',addslash(settings.etcdir)||settings.signature)=0 then
               if filein('sig.',addslash(settings.rexxnewsdir)||settings.signature)=0 then
                  say "Unable to load signature file "settings.signature
      do i=1 to sig.0
         n=n+1
         posting.n=sig.i
      end
      end
   posting.0=n

   call fileout 'posting.',tempfile,0,1,1
   edit=1
   if type='M' then
      if promptkey("Edit before mailing? ","YN","Y")="N" then edit=0
   if edit then
      do
      datestamp=stream(tempfile,'c','query datetime')
      settings.editor tempfile
      if datestamp==stream(tempfile,'c','query datetime') then
         do
         say "File was not changed... Aborting."
         "erase "tempfile
         return 0
         end
      end
   if mail then
      do
      do while verify(recipient,'()<>','M')\=0 
         if pos('(',recipient)>0 then recipient=word(recipient,1)
         if pos('<',recipient)>0 then parse var recipient "<"recipient">"
      end
      "start "settings.rexxnewsdir||"rxnewsml " tempfile settings.username||"@"||settings.hostname recipient
      return 1
      end
   if filein('posting.',tempfile)=0 then
      do
      say "Error retrieving file from editor.  Aborting...."
      "erase "tempfile
      return 0
      end
   trc=SendCommand(sock,"post")
   parse var line.1 code .
   say line.1
   if code\=340 then 
      do
      say "Server is not allowing posting for some reason....  Aborting..."
      "erase "tempfile
      return 0
      end
   say "Sending your post to the NNTP server..."
   do i=1 to posting.0
      trc=SendMessage(sock,posting.i)
   end
   trc=SendCommand(sock,'.')
   parse var line.1 code msg
   if code=240 then
      do
      say "Posting succeeded."
      "erase "tempfile
      return 1
      end
   say "Posting message failed with error code "code":"
   say msg
   return 0

addslash: procedure expose settings. newsrc. sock
   parse arg dirname
   if right(dirname,1)='\' then return dirname
   else return dirname||'\'

queryfield: procedure expose settings. newsrc. sock
   parse arg field description
   if description="" then description=field
   call charout , "Please enter "description":"
   interpret "parse pull settings."field";",
   "return settings."field

listgroups: procedure expose sock !. settings. newsrc.
   parse arg needle, type
   type=translate(left(type,1))
   if pos(type,'SUPL')=0 then type='L'
   if settings.newuser & needle="" then
      do
      say
      say "The LISTGROUP command without an operand will list all the groups"
      say "known at your NNTP server.  This may be over 1800 groups."
      say
      say "Rather than list all of these groups, you can enter a string to"
      say "search for in the groups' names.  For example, if you are interested"
      say "in newsgroups discussing OS/2, you might enter the string 'os2'."
      say
      say "Press enter if you really wish to list ALL of the newsgroups."
      say 
      call charout , "Enter the search string: "
      parse pull needle
      end
   say "Preparing a sorted list of all known newsgroups..."
   trc=SendCommand(sock,'list')
   line.1=""
   call sortstem 'line.',needle
   if needle\="" then line.1="All newsgroups containing "needle":"
   else line.1="All newsgroups:"

_listgroups:
   if type='L' then 
      do
      call Display 'line.',2,' ('||line.1||' "_i-1" of '||line.0||')', , ,1,1
      key=promptkey("Do wish to subscribe to any of these groups (Yes/No/All)? ","YNA","Y")
      if key="Y" then type="P"
      else if key="A" then 
         do
         if settings.newuser | line.0>settings.askifsubmore then
            do
            if promptkey("Are you sure you want to subscribe to all "||line.0" groups? ","YN","N")="N" then type='P'
            else type="S"
            end
         else type="S"
         end
      else return 1
      end

   if type='P' then
      do
      say
      say "You are about to be presented with each of the "line.0" groups and be given"
      say "a chance to subscribe or unsubscribe to each one."
      say
      say "Answering Yes to the question will add that group to your NEWSRC file as"
      say "   subscribed."
      say "Answering No will not add the group to your NEWSRC file."
      say "Answering U for Unsubscribe will add the group to your NEWSRC file as an"
      say "   unsubscribed group."
      say "Choosing Q will return you to the RexxNews prompt."
      say
      do _i=2 to line.0
      key=promptkey("Subscribe to" subword(line._i,1,1) "("_i-1 "of" line.0-1"): "||d2c(10)||d2c(13)||" (Yes/No/Unsubscribe/Quit)? ","YNUQ","N")
      say
      if key="Q" then leave
      else if key="N" then iterate
      else if key="Y" | key="U" then call checknewsrc subword(line._i,1,1), key
      else say "Internal error in promptkey. "sourceline()
      end
      end

   if type='S' then
      do
      if settings.newuser | line.0>settings.askifsubmore then
         if promptkey("Are you sure you want to subscribe to all "||line.0" groups? ","YN","N")="N" then return 0
      do _i=2 to line.0
      call checknewsrc subword(line._i,1,1), 'Y'
      end
      end

   if type='U' then
      do
      if settings.newuser | line.0>settings.askifsubmore then
         if promptkey("Are you sure you want to mark all "||line.0" groups as unsubscribed? ","YN","N")="N" then return 0
      do _i=2 to line.0
      call checknewsrc subword(line._i,1,1), 'N'
      end
      end
   group=""
   settings.groupname=""
   return 1

mark: procedure expose sock !. settings. last newsrc.
   articleavailable=0
   settings.current=last
   call updatenewsrc settings.groupname, settings.current
   trc = SendCommand(sock,'stat '||last)
   return 1

editnewsrc: procedure expose sock !. settings. newsrc. articleavailable group
   tempnewsrc=SysTempFileName(addslash(settings.tempdir)||'TEMP????.NRC')
   articleavailable=0
   group=""
   call fileout "newsrc.",tempnewsrc,1,1,1
   deleted=1
   call SysCls
   say "You are about to edit your NEWSRC file "settings.newsrcname
   say
   say "You can:"
   say 
   say "   Mark a group as Subscribed"
   say "   Mark a group as Unsubscribed"
   say "   Delete an entry"
   say "   Reset the highest article read back to 1"
   say "   Order groups by a 'key' value"
   say "     (Assign a 1 to 6 digit key that will be used to sort the newsgroups."
   say "     Groups without a key will be assigned 999999 to place them at"
   say "     the end of your newsrc file.  See HELP EDITNEWSRC for details.)"
   say
   if promptkey("Would you like to have the newsrc file sorted alphabetically before continuing? ","YN","N")="Y" then call sortstem 'newsrc.'
   sortbykey=0
_editnewsrc:
   say

   key.=999999
   tempnum=0
   templine=""
   do i=1 to newsrc.0
    if tempnum<>i then do;templine=newsrc.i;tempnum=i;end
    if temmpline="" and newsrc.0="" then iterate
    call SysCls
    say "There are "newsrc.0" entries in your NEWSRC file."
    say
    if newsrc.i="" then parse var templine gn range
    else parse var newsrc.i gn range
    subscribed=pos(right(gn,1),'!:')
    if subscribed\=0 then gn=left(gn,length(gn)-1)
    subscribed=word("Unknown Unsubscribed Subscribed",subscribed+1)
    say "Entry "i" is group" '"'gn'"'
    say "Status is "subscribed";  Articles read are "range
    if sortbykey then say "Current key: "key.i
    if newsrc.i="" then say "*DELETED*"
    key=promptkey("Do you wish to change it (Yes/No/Quit/Abort/Backup/List)? ","YNQABL","N")
    if key="B" then
      do
      if i>1 then i=i-2
      iterate
      end
    if key="L" then
       do
       i=i-1
       call Display 'newsrc.',1,' (NEWSRC file)'
       end
    if key="N" then iterate
    else if key="Q" then leave
    else if key="A" then
       do
       if promptkey("Really lose your changes? ","YN","N")="N" then
          do
          i=i-1
          iterate
          end
       else
         do
          call filein 'newsrc.',tempnewsrc
          "erase "tempnewsrc
          return 0
          end
       end
   else
      do
      say
      if subscribed="Subscribed" then 
         say "Unsubscribe from "gn"/"
      else say "Subscribe to "gn"/"
      say "Delete "gn" from your NEWSRC/"
      say "Reset the highest article read for "gn"/"
      say "Order "gn" within your NEWSRC by a key/"
      say "Abort changes to "gn"/"
      say
      if subscribed="Subscribed" then 
         key=promptkey("(U/D/R/O/A)? ","UDRAO","A")
      else key=promptkey("(S/D/R/O/A)? ","SDRAO","A")
      if key="A" then 
        do
        newscr.i=templine
        i=i-1
        iterate
        end
      else if key="S" then
         do
         parse var newsrc.i gn range
         stat=right(gn,1)
         if pos(stat,":!")\=0 then
            gn=left(gn,length(gn)-1)
         stat=":"
         newsrc.i=gn||": "||range
         i=i-1
         iterate
         end
      else if key="U" then
         do
         parse var newsrc.i gn range
         stat=right(gn,1)
         if pos(stat,":!")\=0 then
            gn=left(gn,length(gn)-1)
         newsrc.i=gn||"! "||range
         i=i-1
         iterate
         end
      else if key="D" then
         do
         if promptkey("Really delete the entry? ","YN")="N" then iterate
         deleted=1
         newsrc.i=""
         i=i-1
         iterate
         end
      else if key="R" then
         do
         if promptkey("Really clear the highest article read? ","YN")="N" then iterate
         parse var newsrc.i gn range
         newsrc.i=gn||" 1-1"
         i=i-1
         iterate
         end
      else if key="O" then
         do
         say
         say "Enter a 1 to 6 digit key for the group (use small numbers for groups"
         say "  that you would like near or at the beginning of your NEWSRC file."
         say "  Groups with the same key will sort alphabetically.)"
         say
         call charout , 'Key value for "'gn'": '
         parse pull key.i
         if key.i="" then key.i=999999
         do while length(key.i)>6 | \datatype(key.i,'W')
            call charout , 'Please re-enter the key for "'gn'": '
            parse pull key.i
            if key.i="" then key.i=999999
         end
         sortbykey=1
         i=i-1
         iterate
         end
      end
   end
   if deleted then
      do
      tempnewsrc2=SysTempFileName(addslash(settings.tempdir)||'TEMP????.NRC')
      call fileout 'newsrc.', tempnewsrc2, 1, 1, 1
      call filein 'newsrc.', tempnewsrc2
      "erase "tempnewsrc2
      end
   if sortbykey then
      do
      do i=1 to newsrc.0
         newsrc.i=format(key.i,7)||' '||newsrc.i
      end
      do 
      call sortstem 'newsrc.'
      do i=1 to newsrc.0
         newsrc.i=subword(newsrc.i,2)
      end
      end
      end
   Call SysCLS
   say
   if promptkey("Review your modified newsrc file before saving? ","YN")="Y" then call Display 'newsrc.',1,' (Modified NEWSRC file)'
   say
   if promptkey("Keep the changes you have made? ","YN")="N" then
      do
      call filein 'newsrc.',tempnewsrc
      "erase "tempnewsrc
      return 0
      end
   call fileout 'newsrc.',settings.newsrcname, 1, 1, 1
   "erase "tempnewsrc
   return 1

sortstem: 
   parse arg stem,_needle
   sortinfile=SysTempFileName(addslash(settings.tempdir)||'SORT????.IN')
   sortoutfile=SysTempFileName(addslash(settings.tempdir)||'SORT????.OUT')
   call fileout stem,sortinfile,,,1,_needle
   if stream(sortinfile,'C','QUERY SIZE')<settings.sortmaxbytes then
      do
      say "Sorting the list..."
      settings.sortcommand "<"sortinfile" >"sortoutfile "2> nul"
      trc=filein(stem,sortoutfile)
      "erase "sortoutfile
      return 0
      end
   else 
      do
      if _needle\="" then trc=filein(stem,sortinfile)
      say "The file was too big to sort..."
      say "It was "stream(sortinfile,'C','QUERY SIZE')" bytes long."
      say "The command "settings.sortcommand" can only handle "settings.sortmaxbytes" bytes."
      say "You can replace the this sort command with another sort program"
      say "to be able to sort larger files."
      say "Press enter to continue..."
      parse pull
      end
   "erase "sortinfile
   return 1

promptkey: procedure expose settings. newsrc. sock
   parse arg message, keys, default
   call charout , message
   if default\="" then keys=keys||d2c(13)
   do until pos(key,keys)\=0
      key=translate(SysGetKey('NoEcho'))
   end
   if key=d2c(13) then key=translate(default)
   say key
   return key

/*

The 'Simplified' newsrc file:

The date of the file is used to find 'new' newsgroups.

newsgroup.name[:|!] [currentarticle]

Where:  ':' indicates a 'subscribed' group
        '!' indicates an 'unsubscribed' group

The 'currentarticle' is the number of the last article read in the group.

NO USE OF THE SUBSCRIBED/UNSUBSCRIBED STATUS IS MADE AT PRESENT!!

Note:  This reader *is* capable of using a Unix .newsrc file.
       Unimplemented features are ignored.

*/
