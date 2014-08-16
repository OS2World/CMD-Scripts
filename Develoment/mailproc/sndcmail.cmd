/* sndcmail.cmd, written by Zsolt Kadar, 05.28.1999 *********************/
/* Special thanks to P.J. Mueller en C. Lechleitner *********************/
/* for publishing rnr.cmd and getpop.cmd.	    *********************/

/* you must configure these parameters **********************************/
mail_from	= 'user.from@server1.org'	/* mail from setting 	*/
def_mail_to	= 'user.to@server2.org'		/* default recipient 	*/

/* you may configure these parameters ***********************************/
mailerstring 	= 'MAILPROC 1.0 for OS/2 Warp'	/* mailer string     	*/
def_subj	= 'Your mail'			/* def. reply subject  	*/
tracing 	= 'OFF'				/* tracing ON/OFF    	*/
tracefile	= 'logs\sndcmail.trc'		/* name of trace file	*/

/************************************************************************/
/* Do not change anything under this line!!! ****************************/
/************************************************************************/
trace off

/* get parameters */
parse arg server job

/* check parameters */
if server = "" | job = "" then
   	do
   		say "Expecting a smtp server name and job as parameters."
   		exit 1
   	end

/* define files needed */
sendfile	= job||'.LOG'
msgfile		= job||'.MSG'

/* find reply address and date in message */
mail_to = ''
datum   = ''
subj	= ''
do while lines(msgfile)
	line = linein(msgfile)
	parse var line word1 word2
	if translate(word1) = 'RETURN-PATH:' then
		mail_to = word2
	if translate(word1) = 'DATE:' then
		datum = word2
	if translate(word1) = 'SUBJECT:' then
		subj = word2
end
call lineout msgfile

/* if not found, use defaults */
if mail_to = '' then 
	mail_to = '<'||def_mail_to||'>'
if datum = '' then 
	datum   = date() '-' time()
if subj  = '' then 
	subj    = def_subj


/* initialize socket and rexxutil function package */
call RxFuncAdd 'SysLoadFuncs',  'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
call RxFuncAdd 'SockLoadFuncs', 'RxSock',   'SockLoadFuncs'
call SockLoadFuncs 'quiet'

/* get address of server */
servername = server
rc = SockGetHostByName(server,"host.!")
if (rc = 0) then
   	do
   		say "Unable to resolve server name" server
   		exit 1
   	end
server = host.!addr

/* open socket */
sock = SockSocket("AF_INET", "SOCK_STREAM", "IPPROTO_TCP")
if (sock = -1) then
   	do
   		say "Error opening socket:" errno
   		exit 1
   	end

/* connect socket */
server.!family = "AF_INET"
server.!port   = 25
server.!addr   = server
rc = SockConnect(sock,"server.!")
if (rc = -1) then 
	Error(sock, rc, "Error connecting to smtp server :" errno)
else 
	say 'Connected to SMTP server.'

/* send message */
say 'Sending data.'
trc = GetResponse(sock)
trc = SendMessage(sock, 'EHLO 'servername)
trc = GetResponse(sock)
trc = SendMessage(sock,'MAIL FROM:<'mail_from'>')
trc = GetResponse(sock)
trc = SendMessage(sock,'RCPT TO:'mail_to)
trc = GetResponse(sock)
trc = SendMessage(sock,'DATA')
trc = GetResponse(sock)
trc = SendMessage(sock,'From: "'mailerstring'" <'mail_from'>')
trc = SendMessage(sock,'To: 'mail_to)
trc = SendMessage(sock,'Subject: Re: 'subj' ('datum')')
trc = SendMessage(sock,'X-Mailer: 'mailerstring)
do while lines(sendfile)
	line = linein(sendfile)
	trc = SendMessage(sock, line)
end
rc = lineout(sendfile)
trc = SendMessage(sock,'.'||d2c(13)||d2c(10))
trc = GetResponse(sock)

/* close connection */
trc = SendMessage(sock,'QUIT')
trc = GetResponse(sock)
rc = SockSoclose(sock)

Say 'Done!'
exit


/* get a response from the server */
GetResponse: procedure expose !. line. tracing tracefile
	sock = arg(1)

   	crlf = d2c(13) || d2c(10)
   	line.0 = 1
   	line.1 = GetResponseLine(sock)
	if tracing = 'ON' then 
		call lineout tracefile, 'line='line.1

   	do while length(!.buff) > 0
      		o = line.0 + 1
	   	p = pos(crlf, !.buff)
   		line.o = substr(!.buff, 1, p-1)
   		!.buff = substr(!.buff, p+2)
      		line.0 = o
   	end

return ""


/* get a line from the server */
GetResponseLine: procedure expose !. tracing tracefile
   	sock = arg(1)

   	crlf = d2c(13) || d2c(10)
   	if (symbol('!.buff') = "LIT") then !.buff = ""

   	do while (pos(crlf, !.buff) = 0)
      		rc = SockRecv(sock, "data", 8000)
      		!.buff = !.buff || data
   	end

	if tracing = 'ON' then 
		do
			call lineout tracefile, ' got data "' data '"' 
			call lineout tracefile, ' buff = "' !.buff '"'  
		end

   	p = pos(crlf, !.buff)
   	line = substr(!.buff, 1, p-1)
   	!.buff = substr(!.buff, p+2)

return line


/* send a string to the server */
SendMessage: procedure expose !. tracing tracefile
   	sock = arg(1)
   	data = arg(2) || d2c(13) || d2c(10)

	if tracing = 'ON' then 
		call lineout tracefile, 'Sending "'data'" to server.' 
   	len = length(data)
   	do while (len > 0)

      		len = SockSend(sock, data);
		if tracing = 'ON' then 
			do
				call lineout tracefile, 'Returncode: ' len   
				call lineout tracefile, 'Errorcode:  ' errno 
			end
	      	
	      	if (errno <> 0) then
	         	Error(-1,rc,"Error sending data to server.")
	      	
	      	if (len <= 0) then 
			Error(sock,100,"Server closed the connection.")
     
	      	data = substr(data, len+1)
      		len  = length(data)
   	end

return i


/* halting ... */
Halting:
   Error(sock,1,"error on line" sigl)


/* exit with a message and return code */
Error: procedure
	sock = arg(1)
   	retc = arg(2)
   	msg  = arg(3)

   	if (sock <> -1) then rc = SockSoClose(sock)
   	say msg
exit retc

