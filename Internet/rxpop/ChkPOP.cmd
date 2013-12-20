/*------------------------------------------------------------------
 * chkpop.cmd :
 *------------------------------------------------------------------
 * 08-09-92 rnr.cmd published originally by Patrick J. Mueller
 * 24-01-95 adapted as chkpop.cmd by Christoph Lechleitner
 * 15-12-96 fixed for more RFC-compatibility by C. Lechleitner
 *------------------------------------------------------------------*/

trace off

parse arg server user password

if (server = "") | (user='') | (password='') then
   do
   say " Error: Expecting a pop server name, a user and a password as parameters."
   exit 1
   end
say ' '

/*------------------------------------------------------------------
 * initialize socket function package
 *------------------------------------------------------------------*/
parse source os .

if (os = "OS/2") then
   do
   if RxFuncQuery("SockLoadFuncs") then
      do
      rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
      rc = SockLoadFuncs()
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
   say "Error: Unable to resolve server name" server
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

   trc = GetResponse(sock)

   trc = SendMessage(sock,'USER 'user)
   trc = GetResponse(sock)
   parse var line.1 status rest
   if status <> '+OK' then
     do
       say ' Error: User' user 'unknown on' server '.'
       qrc = SendMessage(sock,'QUIT')
       qrc = SockSoclose(sock)
       exit
     end

   trc = SendMessage(sock,'PASS 'password)
   trc = GetResponse(sock)
   parse var line.1 status rest
   if status <> '+OK' then
     do
       say ' Error: Password wrong for' user ' on 'server'.'
       qrc = SendMessage(sock,'QUIT')
       qrc = SockSoclose(sock)
       exit
     end
   else
     do 
       trc = SendMessage(sock,'LIST')
       trc = GetResponse(sock)
       messages = 0
       do 
         msginfo = GetResponseLine(sock)
         do while msginfo <> '.'
           messages = messages + 1
           msginfo = GetResponseLine(sock)
         end
         if messages = 0 
         then say ' There is no message waiting for you.'
         else
           do 
             say ' There are' messages 'messages waiting for you.'
             trc = SendMessage(sock,'LIST')
             trc = GetResponse(sock)
             do 
               msginfo = GetResponseLine(sock)
               do while msginfo <> '.'
                 parse var msginfo number size
                 say ' Message' number 'has' size 'bytes.'
                 msginfo = GetResponseLine(sock)
               end
             end /* do */
       end
     end /* do */

   trc = SendMessage(sock,'QUIT')
   trc = GetResponse(sock)

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