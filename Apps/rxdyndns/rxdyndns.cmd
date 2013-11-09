/*------------------------------------------------------------------
 * rxdyndns.cmd
 *------------------------------------------------------------------
 * Dennis Peterson
 * 7-27-97
 *
 * Archive includes b64rx.dll which encodes the userid:password string
 * The b64rx.dll code was created by Teet Kõnnussaar (teet@aetec.estnet.ee)
 * 
 * Requires rxsock.dll
 * Requires registation with www.ml.org which is free for now
 *
 * This code is free to everyone.
 *------------------------------------------------------------------*/

/*-------------------
Basic Info from www.ml.org:

The host to connect to is: monolith2.ml.org.
The protocol to use is HTTP or HTTPS.
The port number is 80 (HTTP) or 443 (HTTPS).
The path is /mis-bin/ms3/nic/dyndns
Both PUT and GET methods can be used.
The arguments are (these are examples, but they're reasonable defaults):

command=Update+Host
do=mod
domain=HOST

This is an example of a line that could be sent to the ML server to
update a host artur.dyn.ml.org:

GET /mis-bin/ms3/nic/dyndns?command=Update+Host&domain=artur&act=act&wildcard=on&do=mod&agree=agree HTTP/1.0

That line should be followed by the authorization data on one line, and an
empty line.

Authorization
The authorization line mentioned above is:
Authorization: Basic ENCODED_MID_AND_PASSWORD
Eg if artur1 is the MID and password is the password, then it is
formatted as "artur1:password" (w/o the qoutes) and encoded using
base64 (Authorization: Basic YXJ0dXIxOnBhc3N3b3Jk).
 
When successful action is 'activate' returns:
<!-- MS3V STATUS:OK HOSTNAME:dkp ACT:1 IP:206.63.32.92 MX: -->

When successful action is 'deactivate' returns:
<!-- MS3V STATUS:OK HOSTNAME:dkp ACT:0 IP: MX: -->
---------------------*/

parse arg action domain userid password .

if (action = "?") then
   Usage()
if (action = "") then
   Usage()

/*------------------------------------------------------------------
 * initialize md5rx API package
 *------------------------------------------------------------------*/

call rxfuncadd 'B64encode','md5rx','B64encode'
call rxfuncadd 'B64decode','md5rx','B64decode'

/*------------------------------------------------------------------
 * initialize socket package
 *------------------------------------------------------------------*/
if RxFuncQuery("SockLoadFuncs") then
   do
      rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
      rc = SockLoadFuncs()
end

crlf = "0d0a"x
activation = 'unsuccessful'

/*------------------------------------------------------------------
 * Get IP from PPP log file in %etc%\ppp0.log
 *------------------------------------------------------------------*/
In_File = VALUE('etc',,OS2ENVIRONMENT) || '\ppp0.log'
Do While lines(In_File) > 0
   Line_In = Linein(In_File)
   If Wordpos('local', Line_In) > 0 Then
   IP = Word(Line_In, Words(Line_In))
End

/*------------------------------------------------------------------
 * Initialize http variables - Yes -- rexx can to HTML!
 *------------------------------------------------------------------*/
server = "monolith2.ml.org"
security = "Authorization: Basic" B64Encode(userid || ":" || password) || crlf || crlf

URL = "GET /mis-bin/ms3/nic/dyndns?"
URL = URL || "command=Update+Host"
URL = URL || "&domain=" || domain
URL = URL || "&act=" || action
URL = URL || "&wildcard=on"
URL = URL || "&do=mod"
URL = URL || "&agree=agree HTTP/1.0" || crlf

/*------------------------------------------------------------------
 * choose port number - http port is normally 80
 *------------------------------------------------------------------*/
port = 80

/*------------------------------------------------------------------
 * get server name
 *------------------------------------------------------------------*/
rc = SockGetHostByName(server,"host.!")
if (rc = 0) then
   do
      say "Error" h_errno "calling SockGetHostByName("server")"
      exit
   end

server = host.!addr;

/*---------------------------------------------------------------
 * open socket
 *---------------------------------------------------------------*/
socket  = SockSocket("AF_INET","SOCK_STREAM",0)
if (socket = -1) then
   do
      say "Error on SockSocket:" errno
      exit
   end

/*------------------------------------------------------------------
 * catch breaks
 *------------------------------------------------------------------*/
signal on halt

/*---------------------------------------------------------------
 * connect socket
 *---------------------------------------------------------------*/
server.!family = "AF_INET"
server.!port   = port
server.!addr   = server

rc = SockConnect(socket,"server.!")
if (rc = -1) then
   do
      say "Error on SockConnect:" errno
      exit
   end

rc = SockSend(socket, URL)
if (rc = -1) then
   do
      say "Error on SockSend URL:" errno
      exit
   end

rc = SockSend(socket, security)
if (rc = -1) then
   do
      say "Error on SockSen security:" errno
      exit
   end
   
/*------------------------------------------------------------------
 * receive the result from the server
 *------------------------------------------------------------------*/

do until rc = 0
   rc = SockRecv(socket,"newData",512)
   returnData = returnData || newData
end

/*------------------------------------------------------------------
 * check results
 *------------------------------------------------------------------*/

select
   when translate(action) = 'ACT' then do
      if wordpos("ACT:1",returnData) > 0 then
         activation = 'successful'
      say 'Activation was' activation
   end

   when translate(action) = 'DEC' then do
      if wordpos("ACT:0",returnData) > 0 then
         activation = 'successful'
      say 'Deactivation was' activation
   end

   otherwise
      nop
end

/*------------------------------------------------------------------
 * close socket (and catch signals)
 *------------------------------------------------------------------*/
halt:

rc = SockSoClose(socket)
if (rc = -1) then
   do
   say "Error on SockSoClose:" errno
   exit
   end

exit

/*------------------------------------------------------------------
 * some simple help
 *------------------------------------------------------------------*/
Usage: procedure
   parse source . . me .

   say "usage:"
   say "   " me "action domain userid password"
   say "    is used to activate (act) or deactivate (dec) the dynamin DNS"
   say "    domain becomes 'domain.dyn.ml.org'"
   say
   exit
