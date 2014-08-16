/* getcmail.cmd, written by Zsolt Kadar, 03.05.2000 *********************/
/* Special thanks to P.J. Mueller en C. Lechleitner *********************/
/* for publishing rnr.cmd and getpop.cmd.	    *********************/

/* you must change this parameter ***************************************/
cmail_subject   = 'Your secret subject'	/* subject command email  	*/

/* you may change these parameters **************************************/
NewMailFileMask = 'MPRC????'     	/* filetempl for commands 	*/
max_mail_size   = 1500		 	      /* max size command email 	*/
tracing		= 'OFF'		 	            /* extra logging ON/OFF   	*/
tracefile	= 'logs\getcmail.trc' 	/* trace file name       	  */

/************************************************************************/
/* Do not change anything under this line!!! ****************************/
/************************************************************************/
trace off

/* find parameters */
parse arg server user password

/* parameter check */
if (server = "") | (user='') | (password='') then
   	do
   		say "Expecting a pop server name, a user, a password and a filemask as parameters."
   		exit 1
   	end

homedir	= directory()

/* initialize socket and rexxutil function package */
call RxFuncAdd 'SysLoadFuncs',  'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
call RxFuncAdd 'SockLoadFuncs', 'RxSock',   'SockLoadFuncs'
call SockLoadFuncs 'quiet'

/* get address of server */
rc = SockGetHostByName(server,"host.!")
if (rc = 0) then
   	do
   		say "Unable to resolve server name" server
   		exit 1
   	end
server = host.!addr

/* open socket */
sock = SockSocket("AF_INET","SOCK_STREAM","IPPROTO_TCP")
if (sock = -1) then
   	do
   		say "Error opening socket:" errno
   		exit 1
   	end

/* connect socket */
server.!family = "AF_INET"
server.!port   = 110
server.!addr   = server
rc = SockConnect(sock,"server.!")
if (rc = -1) then Error(sock, rc, "Error connecting to popserver :" errno)

/* send user name */
trc = GetResponse(sock)
trc = SendMessage(sock, 'USER 'user)
trc = GetResponse(sock)
parse var line.1 status rest
if status <> '+OK' then
	do
       		say ' Error: User' user 'unknown on' server '.'
       		qrc = SendMessage(sock,'QUIT')
       		qrc = SockSoclose(sock)
       		exit 1
     	end

/* send password */
trc = SendMessage(sock,'PASS 'password)
trc = GetResponse(sock)
parse var line.1 status rest
if status <> '+OK' then
     	do
       		say ' Error: Password wrong for' user ' on 'server'.'
       		qrc = SendMessage(sock,'QUIT')
       		qrc = SockSoclose(sock)
       		exit 1
     	end
else
     	do 
		      /* get list of emails */
       		trc = SendMessage(sock,'LIST')
       		trc = GetResponse(sock)
       		messages = 0
       		do 
         		msginfo = GetResponseLine(sock)
         		do while msginfo <> '.'
           			messages = messages + 1
           			msginfo = GetResponseLine(sock)
         		end
         		if messages = 0 then
         			say 'There is no command email.'
         		else
           			do 
             				say 'There is(are)' messages 'possible command email(s).'
             				trc = SendMessage(sock,'LIST')
             				trc = GetResponse(sock)
             				do 
               					msginfo = GetResponseLine(sock)
						            w = 1
               					do while msginfo <> '.'
                 					parse var msginfo number.w size.w
                 					say 'Message' number.w 'has' size.w 'bytes.'
							            w = w + 1
                 					msginfo = GetResponseLine(sock)
               					end
             				end /* do */

             				/* get possible command mails */
             				do i = 1 to messages
						if size.i < max_mail_size then
							do
               							say 'Getting Message' i
               							trc = SendMessage(sock,'RETR ' i)
               							trc = GetResponse(sock)
               							parse var line.1 status rest

								/* define files needed */
               	NewMailFile = 'WAIT\' || SysTempFileName(NewMailFileMask)
								NewFlagFile = homedir || '\' || NewMailFile || '.RDY'
								NewCmdFile  = NewMailFile || '.CMD'
								NewMailFile = NewMailFile || '.MSG'

                /* convert subject to upper case */
                cmail_subject = translate(cmail_subject)

								/* find out subject email */
								oneline. = ''
								l = 1
								write = 0
               	oneline.l = GetResponseLine(sock)
               	do while oneline.l <> '.'
									parse var oneline.l sub text
									if translate(sub) = 'SUBJECT:' then 
										subject = translate(text)
									if subject = cmail_subject & write = 1 & oneline.l <> '' then 
                 								call lineout newCmdFile, oneline.l 
									if subject = cmail_subject & oneline.l = '' then 
										write = 1
									l = l + 1
     							oneline.l = GetResponseLine(sock)
									oneline.0 = l - 1
               	end

								/* write command file */
								if subject = cmail_subject then
									do
										call lineout NewCmdFile, '@echo READY > 'NewFlagFile
		               							call lineout NewCmdFile
										do j = 1 to oneline.0
											call lineout NewMailFile, oneline.j
										end
										call lineout NewMailFile
               									trc = SendMessage(sock,'DELE ' i)
               									trc = GetResponse(sock)
               									parse var line.1 status rest
               									say 'Got and deleted Message' i
									end
							end
             				end  
       				end
		end
	end

/* close connection */
trc = SendMessage(sock,'QUIT')
trc = GetResponse(sock)
rc  = SockSoclose(sock)
exit


/* get a response from the server */
GetResponse: procedure expose !. line.
	sock = arg(1)

   	moreids = "100 215 220 221 222 223 230 231"
   	line.0 = 1
   	line.1 = GetResponseLine(sock)

   	parse var line.1 rid .
   	if (wordpos(rid, moreids) = 0) then return ""

   	do forever
      		o = line.0 + 1
      		line.o = GetResponseLine(sock)
      		if (line.o = ".") then return ""
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

   	p = pos(crlf,!.buff)
   	line = substr(!.buff,1,p-1)
   	!.buff = substr(!.buff,p+2)

return line


/* send a string to the server */
SendMessage: procedure expose !. tracing tracefile
   	sock = arg(1)
   	data = arg(2) || d2c(13) || d2c(10)

	if tracing = 'ON' then
   		call lineout tracefile, 'Sending "'data'" to server.'  
   	len = length(data)
   	do while (len > 0)

      		len = SockSend(sock,data);
		if tracing = 'ON' then 
			do
	      	 		call lineout tracefile, 'Returncode: ' len   
	      	 		call lineout tracefile, 'Errorcode:  ' errno 
	      	
	      			if (errno <> 0) then
	         			Error(-1,rc,"Error sending data to server.")
			end
	      	
	      	if (len <= 0) then 
			Error(sock,100,"Server closed the connection.")
     
	      	data = substr(data,len+1)
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
