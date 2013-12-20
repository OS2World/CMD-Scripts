/* ============================================================================ 

Send Email Message to a Mailing List Via SMTP, Using the REXX Socket Interface
Written by a novice REXX programmer

Dave Briccetti, November 1995
daveb@davebsoft.com, http://www.davebsoft.com

May be used for any purpose
Thanks to REXX expert <a href=http://www.quercus-sys.com>Charles Daney</a> 
and internet expert David Singer for looking over the code

============================================================================ */

parse arg MailingList           /* The name of the file containing one 
                                   email address per line */
MailingList = strip(MailingList)

call SetConstants

/* Load the REXX Socket interface */
call RxFuncAdd 'SockLoadFuncs', 'rxSock', 'SockLoadFuncs'
call SockLoadFuncs

 
if EstablishProtocol() = FALSE then
    exit

/* The protocol initiated, we'll now send the message to each
   recipient */

call SendMsgToEachRecipient

/* QUIT ends the protocol */
    
CmdReply = TransactSmtpCommand(socket, 'QUIT', 1)

/* Close the socket */
    
call SockSoClose socket

exit


/* ========================================================================= */
SetConstants:
/* ========================================================================= */

MessageFile = 'msg'             /* The name of the file containing the 
                                   message to send */
SendingHost = 'yourhost.com'    /* Host of the sender */
SendingUser = 'yourid'          /* User name of the sender */
MailServer  = 'mailserver.com'  /* Mail server */

CRLF                    = '0d0a'x
TRUE                    = 1
FALSE                   = 0

REPLYTYPE_OK            = '2'   /* SMTP reply code first byte */
REPLY_START_MAIL_INPUT  = '354' /* SMTP reply code */

return


/* ========================================================================= */
EstablishProtocol:
/* ========================================================================= */

socket = ConnectToMailServer(MailServer)    
if socket <= 0 then 
do
    say 'Could not connect to mail server'
    return FALSE
end

CmdReply = GetCmdReply(socket)

if left(CmdReply, 1) \= REPLYTYPE_OK then 
do
    say 'Could not establish protocol'
    return FALSE
end

/* Send the extended hello, in case this SMTP server supports
   SMTP extensions */
        
CmdReply = TransactSmtpCommand(socket, 'EHLO', 1)
        
if left(CmdReply, 1) = REPLYTYPE_OK then 
do
    /* That worked, so enable extended SMTP processing.  If
       the response to the EHLO indicates support for SIZE,
       enable our use of that feature */
              
    SmtpExtensionsSupported = TRUE
    if pos('250 SIZE', CmdReply) > 0 | pos('250-SIZE', CmdReply) > 0 then
        SizeExtensionSupported = 1
end
else
do
    /* The server didn't recognize the EHLO so we'll go with
       the regular HELO */
              
    SmtpExtensionsSupported = FALSE
    SizeExtensionSupported  = FALSE
    CmdReply = TransactSmtpCommand(socket, 'HELO', 1)
end

if left(CmdReply, 1) = REPLYTYPE_OK then 
    return TRUE
else
    return FALSE


/* ========================================================================= */
SendMsgBody: 
/* ========================================================================= */

/* DATA tells the server that the body of the message is coming.  It
   should reply with a code meaning "go ahead." */

CmdReply = TransactSmtpCommand(socket, 'DATA', 1)
if substr(CmdReply, 1, 3) = REPLY_START_MAIL_INPUT then 
do
    /* Send the data, followed by a '.' on a line by itself to 
       indicate the end of the message */
       
    CmdReply = TransactSmtpCommand(socket, MsgFileContents || CRLF || '.', 0)
end

return


/* ========================================================================= */
SendMsgToEachRecipient:
/* ========================================================================= */

MsgFileContents = charin(MessageFile, 1, chars(MessageFile))
call stream MessageFile, 'c', 'close'
MsgFileContents = strip(MsgFileContents, 't', '1a'x)  /* Strip EOF */
        
/* MAIL FROM identifies the sender.  The SIZE= extension
   provides the size of the message, to allow the 
   server to quickly refuse messages bigger than it wants. */
           
MailFromCmd = 'MAIL FROM:' || SendingUser || '@' || SendingHost

if SizeExtensionSupported then
    MailFromCmd = MailFromCmd 'SIZE=' || length(MsgFileContents)
    
CmdReply = TransactSmtpCommand(socket, MailFromCmd, 1)

if left(CmdReply, 1) = REPLYTYPE_OK then        
do while lines(MailingList) 

    /* Read the recipient's email address from the mailing list file */
    
    RecipientEmailAddress = linein(MailingList)
    
    if RecipientEmailAddress \= '' then 
        /* RCPT identifies the intended recipient of the message */
            
        CmdReply = TransactSmtpCommand(socket,, 
            "RCPT TO:" || RecipientEmailAddress, 1)
end

call SendMsgBody

return


/* ========================================================================= */
ConnectToMailServer: procedure
/* ========================================================================= */

parse arg MailServer
socket = 0

/* Open a socket to the mail server.  (The Sock* functions are
   documented in the REXX Socket book in the Information folder
   in the OS/2 System folder */

call SockInit
if SockGetHostByName(MailServer, 'host.!') = 0 then
    say 'Could not get host by name' errno h_errno
else
do
    socket = SockSocket('AF_INET','SOCK_STREAM',0)
    address.!family = 'AF_INET'
    address.!port = 25          /* the standard SMTP port */
    address.!addr = host.!addr
    if SockConnect(socket, 'address.!') = -1 then 
        say 'Could not connect socket' errno h_errno
end
return socket


/* ========================================================================= */
GetCmdReply: procedure
/* ========================================================================= */

parse arg socket

CRLF = '0d0a'x

/* Receive the response to the SMTP command into a variable.  Use
   more than one socket read if necessary to collect the whole 
   response. */
   
if SockRecv(socket, 'CmdReply', 200) < 0 then do
    say 'Error reading from socket' errno h_errno
    exit
end

ReadCount = 1
MaxParts = 10

do while ReadCount < MaxParts & right(CmdReply, 2) \= CRLF  
    if SockRecv(socket, 'CmdReplyExtra', 200) < 0 then do
        say 'Error reading from socket'
        exit
    end
    CmdReply = CmdReply || CmdReplyExtra
    ReadCount = ReadCount + 1
end

say CmdReply    
return CmdReply


/* ========================================================================= */
TransactSmtpCommand: 
/* ========================================================================= */

parse arg socket, Cmd, SayCmd

/* Send a command to the SMTP server, echoing it to the display
   if requested */

if SayCmd then 
    say Cmd
rc = SockSend(socket, Cmd || CRLF)
return GetCmdReply(socket)
