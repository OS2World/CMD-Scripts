/*------------------------------------------------------------------
 * getpop.cmd :
 *------------------------------------------------------------------
 * 08-09-92 rnr.cmd published originally by Patrick J. Mueller
 * 24-01-95 adapted as chkpop.cmd by Christoph Lechleitner
 * 15-06-96 fixed for more RFC-compatibility by C. Lechleitner
 * 15-06-96 adapted to getpop.cmd by Christoph Lechleitner
 * 12-16-00 Modified to create message files formatted for NS4
 *          by Dennis Peterson (who is amazed at how this code morphs)
 *------------------------------------------------------------------*/

trace off

/* 
   Modify the following variables to suit your needs or
   uncomment the next section to use command line arguments
*/

server = "mail.earthlink.net"
user = "zippy.pinhead"
password = "abc123"
newMailFileName = "c:\ns4\users\zippy.pinhead\mail\Earthlin"
keep = "N"

/* Uncomment this section to use command line arguments
parse arg server user password newMailFileName keep .

if (server = "") | (user='') | (password='') | (newMailFileName='') | (keep='') then
   do
   say "Expecting a pop server name, username, password, a Filename," 
   say "and Y|N (keep file on server yes or no) as parameters."
   exit 1
   end
*/
 
/* 
say 'Server:   '  server
say 'User:     '  user
say 'Password: '  password
say 'Filemask: '  filemask
*/
say ' '

/*------------------------------------------------------------------
 * initialize socket function package
 *------------------------------------------------------------------*/
parse source os .

call RxFuncAdd 'SysTempFileName', 'RexxUtil', 'SysTempFileName'
if (os = "OS/2") then
   do
   if RxFuncQuery("SockLoadFuncs") then
      do
      rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
      rc = SockLoadFuncs()
      rc = RxFuncAdd("SysTempFileName","RexxUtil","SysTempFileName")
      end
   end

if (os = "AIX/6000") then
   do
   rc = SysAddFuncPkg("rxsock.dll")
   end

/*------------------------------------------------------------------
 * get address of server
 *------------------------------------------------------------------*/
rc = SockGetHostByName(server,"host.!")
if (rc = 0) then
   do
   say "Unable to resolve server name" server
   exit
   end

server = host.!addr

/*------------------------------------------------------------------
 * open socket
 *------------------------------------------------------------------*/
sock = SockSocket("AF_INET","SOCK_STREAM","IPPROTO_TCP")
if (sock = -1) then
   do
   say "Error opening socket:" errno
   exit
   end

/*------------------------------------------------------------------
 * connect socket
 *------------------------------------------------------------------*/
server.!family = "AF_INET"
server.!port   = 110
server.!addr   = server

rc = SockConnect(sock,"server.!")
if (rc = -1) then
   Error(sock,rc,"Error connecting to popserver :" errno)

/* 
rc = SockRecv(sock, "data", 8000)
testline = GetResponseLine(sock)
say ' "'testline'"' 
*/

   trc = GetResponse(sock)
   /* 
   say 'Welcome Message with' line.0 'lines:' 
   do i = 1 to line.0
      say line.i
   end
   */

   trc = SendMessage(sock,'USER ' user)
   trc = GetResponse(sock)
   /* 
   say ' Response to identifiing USER with' line.0 'lines:'
   do i = 1 to line.0
      say line.i
   end
   */

   trc = SendMessage(sock,'PASS 'password)
   trc = GetResponse(sock)
   /* 
   say ' Response to sending password with' line.0 'lines:'
   do i = 1 to line.0
      say line.i
   end
   */
   if status = '-ERR' then
     do
       say ' '
       say ' ERROR: Illegal Identification '
       exit
     end
   else
     do 
       trc = SendMessage(sock,'LIST')
       trc = GetResponse(sock)
       parse var line.1 status messages rest
       if messages = 0 
       then say ' No messages'
       else 
         do 
           say ' You have' messages 'messages.'
           /* trc = GetResponse(sock)
           say ' line.* has ' line.0 ' lines.' */
           do i = 1 to messages
             msginfo = GetResponseLine(sock)
             parse var msginfo number size
             say ' Message' number 'has' size 'bytes.'
           end
           dummy = GetResponseLine(sock)
         end
         
         /* Get Mail */
         do i = 1 to messages
           say ' Getting Message ' i
           trc = SendMessage(sock,'RETR ' i)
           trc = GetResponse(sock)
           parse var line.1 status rest
           
           /* set date line for Netscape */
           parse value date() with today month year
           Day = Left(date('W'),3)
           parse value time('L') with hour':'minutes':'seconds'.'hundredths
           call lineout newMailFileName,'From -' Day month today hour':'minutes':'seconds  year

           oneline = GetResponseLine(sock)
           do while oneline <> '.'
             call lineout newMailFileName, oneline
             oneline = GetResponseLine(sock)
           end
           call lineout newMailFileName
           
           /* delete file from server */
           if translate(keep) = 'N' then
           do
             trc = SendMessage(sock,'DELE ' i)
             trc = GetResponse(sock)
           end
           
           parse var line.1 status rest
         end  
       end

   trc = SendMessage(sock,'QUIT')
   trc = GetResponse(sock)
   /* 
   say ' Response to sending QUIT command with' line.0 'lines:'
   do i = 1 to line.0
      say line.i
   end
   */

/*------------------------------------------------------------------
 * quittin' time!
 *------------------------------------------------------------------*/
/* rc = SendMessage(sock,"quit") */
rc = SockSoclose(sock)
exit


/*------------------------------------------------------------------
 * help
 *------------------------------------------------------------------*/
Help: procedure
   say "commands:"
   say
   say "quit    - to quit"
   say "group   - to change to a particular group"
   say "article - to see an article"
   say
   return ""

/*------------------------------------------------------------------
 * get a response from the server
 *------------------------------------------------------------------*/
GetResponse:     procedure expose !. line.
   sock = arg(1)

   moreids = "100 215 220 221 222 223 230 231"

   line.0 = 1
   line.1 = GetResponseLine(sock)

   parse var line.1 rid .

   if (wordpos(rid,moreids) = 0) then
      return ""

   say ' getting further lines '

   do forever
      o = line.0 + 1

      line.o = GetResponseLine(sock)

      if (line.o = ".") then
         return ""

      line.0 = o
   end

   return ""

/*------------------------------------------------------------------
 * get a line from the server
 *------------------------------------------------------------------*/
GetResponseLine: procedure expose !.
   sock = arg(1)

   crlf = d2c(13) || d2c(10)

   if (symbol('!.buff') = "LIT") then
      !.buff = ""

   do while (pos(crlf,!.buff) = 0)
      rc = SockRecv(sock,"data",8000)
      !.buff = !.buff || data
   end

   /* say ' got data "' data '"' */
   /* say ' buff = "' !.buff '"' */


   p = pos(crlf,!.buff)

   line = substr(!.buff,1,p-1)
   !.buff = substr(!.buff,p+2)

   return line

/*------------------------------------------------------------------
 * send a string to the server
 *------------------------------------------------------------------*/
SendMessage:     procedure expose !.
   sock = arg(1)
   data = arg(2) || d2c(13) || d2c(10)

   /* say 'Sending "'data'" to server.' */
   len = length(data)
   do while (len > 0)

      len = SockSend(sock,data);
      /* say 'Returncode: ' len   */
      /* say 'Errorcode:  ' errno */
      /*
      if (errno <> 0) then
         Error(-1,rc,"Error sending data to server.")
      */
      if (len <= 0) then
         Error(sock,100,"Server closed the connection.")
      
      data = substr(data,len+1)
      len  = length(data)
   end

   return i

/*------------------------------------------------------------------
 * halting ...
 *------------------------------------------------------------------*/
Halting:
   Error(sock,1,"error on line" sigl)

/*------------------------------------------------------------------
 * exit with a message and return code
 *------------------------------------------------------------------*/
Error: procedure
   sock = arg(1)
   retc = arg(2)
   msg  = arg(3)

   if (sock <> -1) then
      rc = SockSoClose(sock)

   say msg

   exit retc

