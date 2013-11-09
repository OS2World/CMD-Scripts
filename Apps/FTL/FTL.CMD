/* FTPD trace/log decoder
// Version 0.8
// Copyright (C) 1994 Justin H. Dolske, All Rights Reserved
// Questions? Contact jdolske@mail.bgsu.edu
// Version History:
// 0.5b - Initial public release
// 0.51b - fixed stupid bug that caused logging to die after login
// 0.6b - more commands, SITE/HELP correctly handled, ABOR handled
// 0.7 - CWD logging, handles user timeout, ABOR really works now, note
//       sync errors in log
// 0.8 - log failure to set login directory, CDUP logged as "CWD ..", log
//       deleted files
// projected - new Sort, USER command, document, cache IPs.
*/

/* TO DO*/
/* Create an example ftpd.trc showing what it can do*/
/* do a REAL sort*/
/* RNTO existingfile*/
/* convert parse upper to parse + translate() where needed*/
/* more robust IP logging */
/* Support APPE for STOR and ABOR*/

/* DEFAULTS */
ver = '0.8'
TraceFile = 'FTPD.TRC'  /* Default tracefile */
ReportFile = ''         /* '' defaults to screen only*/
ReportFileOnly = ''     /* '' defaults to always write log to screen */
ReportingLevel = 1      /* Reporting Level if not specified on command line*/
LookupHostname = 'NO'   /* Translate IP to Hostname via nslookup*/
XferLevel = 1           /* Determines Reporting Level for uploads & downloads*/
CWDLevel = 3            /* Reporting level for CWD logging, 4 to disable*/
MaxArgs = 8

/* IMPORTANT VARIABLES */
Connects = 0; Logins = 0; FailedLogins = 0
FilesTotal = 0; FilesUp = 0; FilesDown = 0
FilesUpAbor = 0; FilesDownAbor = 0; BytesDown = 0
Sync_Errors = 0; DeletedFiles = 0


parse upper arg args.1 args.2 args.3 args.4 args.5 args.6 args.8


i = 1
do while ((Args.i \= '') & (i <= MaxArgs))
  select
    when Args.i = '-?' then call HelpScreen
    when Args.i = '-3' then ReportingLevel = 3
    when Args.i = '-2' then ReportingLevel = 2
    when Args.i = '-1' then ReportingLevel = 1
    when Args.i = '-0' then ReportingLevel = 0
    when Args.i = '-Q' then ReportFileOnly = 'YES'
    when Args.i = '-H' then LookupHostname = 'YES'
    when Args.i = '-T' then do
                              i = i + 1          /*checks for vaild filename*/
                              TraceFile = Args.i  /*  after LoadTrace call   */
                              end
    when Args.i = '-L' then do
                              i = i + 1
                              ReportFile = Args.i /*checks on-the-fly*/
                              end
    otherwise do
        say 'Invalid argument:' Args.i
        MaxArgs = 0
        end
  end /*select*/
  i = i + 1
end /*while*/
if MaxArgs = 0 then exit /*if invalid argument*/

call Report 3, 'Beginning Execution'
call Report 1, 'FTL version' ver
call Report 0, 'OS/2 FTPD Tracefile report generated' date('W')',' date() 'at' time()
call Report 0, ''

call LoadTrace     /*Read in the FTPD tracing file*/
if MaxLine = 0 then do
  call Report 0, 'ERROR: Tracefile' TraceFile 'was not found or was empty'
  exit
  end
call SortLog          /*Sort by port user used*/
call GetIPsForSockets /*associate an IP to each socket*/

LastSocket = LogLine.1.Socket
LogStart = 1;
index = 1;

do until index > MaxLine
  if LogLine.index.Socket \= LastSocket then do
    LogStop = index - 1
    call ParseLog LogStart, LogStop
    LogStart = index
    LastSocket = LogLine.index.Socket
    end
  else index = index + 1
end /*do until*/
LogStop = MaxLine
call ParseLog LogStart, LogStop

call GenStats
call Report 3, 'Logging finished'
exit





/* BEGIN PROCEDURES */





/* Procedure: HelpScreen
// Purpose  : Display command line help
// Args     : none
*/

HelpScreen:

say 'FTL - FTPD Tracefile Log utility, version' ver
say '(C) 1994 by Justin H. Dolske. All Rights Reserved.'
say ''
say 'Usage:'
say 'ftl [-0|1|2|3] [-h] [-t tracefile] [-l logfile] [-q]'
say ''
say '-0 -- Output statistics only'
say '-1 -- Output statistics and some logging (DEFAULT)'
say '-2 -- Output statistics and full logging'
say '-3 -- Output statistics and full logging and debugging info'
say '-t tracefile -- Specify a tracefile other than the default (FTPD.TRC)'
say '-l logfile   -- Output logging info to logfile'
say '-q -- Do not write log to screen, useful only with -l.'
say '-h -- Perform a nslookup on IPs found'
say ''
say 'This is NOT a security scanner, it is only a tool for summarizing data!'
exit

return


/* Procedure: LoadTrace
// Purpose  : Read in the FTPD Trace file
// Args     : none
*/

LoadTrace:

index = 0                                   /*index for an array*/
do while lines(TraceFile) <> 0              /*check for EOF*/
  index = index + 1                         /*step up in array*/
  LogLine.index = linein(TraceFile,,1)      /*Read in one line*/
  if LogLine.index == '' then               /*if empty line, discard it*/
    index = index - 1
  else                                   /*what socket is this line from?*/
    parse var LogLine.index 'Socket: ' LogLine.index.Socket ',' .
end
MaxLine = index
CloseResult = stream(TraceFile, 'C', 'CLOSE') /*be nice and close the file*/
if CloseResult \= 'READY:' then do
  say 'ERROR: Error ('CloseResult') closing file' TraceFile
  exit
  end
call Report 3, 'TraceFile successfully read' MaxLine 'lines.'
return

/* Procedure: SortLog
// Purpose  : Sort array LogLine.index by socket number (LogLine.index.Socket)
// Args     : none
*/

SortLog:

call Report 3, 'TraceFile sorting started'
Sorted = 'NO'
do until Sorted = 'YES'
  Sorted = 'YES'
  index = 1
  do while index <= (MaxLine - 1)
    index2 = index + 1
    if LogLine.index.Socket > LogLine.index2.Socket then
      do 
        Temp = LogLine.index; Temp.Socket = LogLine.index.Socket
        LogLine.index = LogLine.index2
        LogLine.index.Socket = LogLine.index2.Socket
        LogLine.index2 = Temp
        LogLine.index2.Socket = Temp.Socket
        Sorted = 'NO'
      end /*if*/
    index = index + 1          
  end /*do while*/
end /*do until*/
call Report 3, 'TraceLog sucessfully sorted'
return

/* Procedure: Report
// Purpose  : Given a message and it's "level", output to the right place
// Args     : #1 - Level of message according to:
//                 0 = Just statistics
//                 1 = General Logging
//                 2 = Detailed Logging
//                 3 = Debugging
//            #2 - Message
*/

Report:

RepLevel = arg(1)
RepMessage = arg(2)
if RepLevel <= ReportingLevel then do
  if ReportFile \= '' then do
      WriteStatus = lineout(ReportFile, RepMessage)
      if WriteStatus \= 0 then do
        say 'ERROR: Error ('WriteStatus') occured when attempting to write to' ReportFile
        exit
        end /*if WriteStatus*/
      end
  if ReportFileOnly \= 'YES' then
      say RepMessage 
  end
return

/* Procedure: GenStats
// Purpose  : Display general usage statistics
// Args     : none
*/

GenStats:

call Report 0, '*******************************************************************************'
call Report 0, 'Usage Report:'
call Report 0, 'Total Connects:' Connects
call Report 0, 'Successful Logins:' Logins '    Failed Login Attempts:' FailedLogins
call Report 0, ''
call Report 0, 'Files Transfered:' FilesTotal '  ('FilesUp 'uploaded,' FilesDown 'downloaded)'
call Report 0, 'Bytes Downloaded:' BytesDown
call Report 0, ''
if Sync_Errors \= 0 then
call Report 0, 'Synching Errors while parsing tracefile:' Sync_Errors
if DeletedFiles \= 0 then
call Report 0, 'Files Deleted:' DeletedFiles
call Report 0, 'Aborted  uploads :' FilesUpAbor
call Report 0, 'Aborted downloads:' FilesDownAbor
call Report 0, '*******************************************************************************'
call Report 0, ''
return


/* Procedure: GetIPsForSockets
// Purpose  : Scan through the tracefile and try to match an IP to each socket
// Args     : none
*/

GetIPsForSockets:

LastSocket = LogLine.1.Socket; i = 1; LastIP = ''
do while i <= MaxLine                          /*don't overrun*/
    IPlookup.LastSocket = ''
    do while LogLine.i.Socket = LastSocket     /*isolate each socket*/
        parse var LogLine.i . . 'Command:' Command Parm .
        Sock = LogLine.i.Socket

        if Command = 'PORT' then do
            parse var Parm aa','bb','cc','dd',' .
            IP = aa||'.'||bb'.'||cc'.'||dd
            if ((LastIP \= '') & (IP \= LastIP)) then
              call Report 1, 'WARNING: Multiple IPs recieved for Socket' Sock ', may be using proxy mode!'
            if LastIP = '' then do
                IPlookup.Sock = IP   /*only assign first IP found*/
                if LookupHostname = 'YES' then
                  HOSTlookup.Sock = NslookupHack(IP)
                else HOSTlookup.Sock = IP
                call Report 3, 'IP:' IP '('HOSTlookup.Sock')'
                end
            LastIP = IP
            end /*if*/

        LastSocket = LogLine.i.Socket
        i = i + 1
        end /*while*/

    /*done parsing a socket*/
    if IPlookup.Sock = '' then do  /*No PORT commands found*/
        IPlookup.Sock = 'Unknown'
        HOSTlookup.Sock = 'Unknown'
        end
    LastIP = ''
    LastSocket = LogLine.i.Socket
    end /*while, do next socket*/

return


/* Procedure: NslookupHack
// Purpose  : get hostname for an ip
// Args     : IP - Numeric IP to get hostname for
*/

NslookupHack:

HostIP = arg(1); Hostname = ''

call Report 3, 'Attempting to resolve' HostIP
'@nslookup' HostIP '| RxQueue 2> NUL:'
do while Hostname = ''
  parse pull Reply Parm       /*we want "Name: host.domain.xxx" */
  if Reply = 'Name:' then 
        Hostname = strip(Parm)      /*remove leading spaces*/
  end /*while*/

if Hostname = '' then do
    Hostname = HostIP
    call Report 3, 'NOTICE: Unable to resolve' HostIP
    end

return Hostname

/* Procedure: ParseLog
// Purpose  : Figure out what was done on one socket
// Args     : i     : first line of log related to this socket
//            i_max : last line of log related to this socket
*/

ParseLog:

i = arg(1); i_max = arg(2)
Sock = LogLine.i.Socket

call Report 1, ''
call Report 3, 'Beginning ParseLog for Socket' Sock
call Report 1, 'Connect from' IPlookup.Sock '('HOSTlookup.Sock')'
Connects = Connects + 1
i = i + 1  /*Skip the FTPD intro, no useful info*/

call ParseLogin
call Report 3, 'Returned from ParseLogin, i=' i
if i_max = 0 then do /*user failed to login*/
  call Report 3, 'Done with ParseLog for Socket' Sock '(did not login)'
  return
  end
call ParsePostLogin
call Report 3, 'Done with ParseLog for Socket' Sock
if i_max \= 0 then
  call Report 0, 'ERROR: Unexpected end of tracing for Socket' Sock


return

/* Procedure: ParseLogin
// Purpose  : Parse tracefile until a user has loged in with a vaile
//            USERname and PASSword, or disconnects
// Args     : none
*/

ParseLogin:

/* at this point the user must login with USER&PASS or QUIT*/

call Report 3, 'Beginning ParseLogin for Socket' Sock
do while i <= i_max 
  parse upper var LogLine.i . . . Command Username Parm2 .
  i = i + 1

  if Command = 'QUIT' then do
        call Report 2, 'Socket' Sock 'user QUIT before loging in.' 
        i_max = 0
        return
        end /*QUIT*/

  else if Command = 'USER' then do
        parse var LogLine.i . . 'Reply:'  NumericCode .
        i = i + 1
        if NumericCode = 230 then do  /*logged in w/o a password*/
            Logins = Logins + 1
            call Report 1, 'Socket' Sock 'logged in as' Username '(no password req)'
            return
            end
        else if NumericCode = 550 then do
            call Report 0, 'ERROR: Could not set default directory for user' Username
            FailedLogins = FailedLogins + 1
            i_max = 0
            return
            end
        /*At this point NumericCode should thus be 331 - Password required*/

        parse var LogLine.i . .'Command:' Command .
        i = i + 1
        if Command \= 'PASS' then do  /*I don't think any clients would allow this*/
            call Report 0, 'ERROR: User on Socket' Socket 'didnt follow USER with PASS. Skipping Socket.'
            FailedLogins = FailedLogins + 1
            i_max = 0
            return
            end

        parse var LogLine.i . .'Reply:' NumericCode .
        i = i + 1
        if NumericCode = 230 then do  /*230 - User username logged in*/
            call Report 1, 'Socket' Sock 'user logged in as ' Username
            Logins = Logins + 1
            return
            end
        else if ((NumericCode = 530) | (NumericCode = 550)) then do
            /*530 - Login incorrect, 550 - Invalid Syntax for PASS*/
            call Report 2, 'Socket' Sock 'user failed login as' Username
            FailedLogins = FailedLogins + 1
            end
         else if NumericCode = 550 then do
            /*couldn't set a directory for the user*/
            call Report 0, 'ERROR: Could not set default directory for user' Username
            FailedLogins = FailedLogins + 1
            i_max = 0
            return
            end

        else do
            call Report 0, 'ERROR: Unknown PASS reply on Socket' Sock 'during login, skipping Socket'
            FailedLogins = FailedLogins + 1
            i_max = 0
            return
            end
        end /*USER*/

  else do  /*user did not do USER or QUIT*/
        i = i + 1     /*skip reply, jump to users next command*/
        if Command = 'HELP' then do
            if Username = '' then i = i + 1  /*Username used as a Parm*/
            else if ((Username = 'SITE') & (Parm2 = '')) then i = i + 1
            else nop
            end
        if ((Command = 'SITE') & (Username = 'HELP')) then i = i + 1
        call Report 3, 'Socket' Sock 'login - entered illegal command ('Command')'
        end  
  parse var LogLine.i . . . NumericCode Word1 .
  if ((NumericCode = 221) & (Word1 \= 'Goodbye.')) then do
        call Report 2, 'Socket' Sock 'unexpectedly logged out before logging in (no QUIT).'
        i_max = 0
        return
        end

  end /*while*/  

/* check here for overflow into next socket area!*/

/*user has a valid login at this point*/

return

/* Procedure: ParsePostLogin
// Purpose  : after user logs in, parse what he has done
// Args     : none
*/

ParsePostLogin:

call Report 3, 'Beginning ParsePostLogin for Socket' Sock
do while i <= i_max
  parse var LogLine.i . . 'Command:' Command Parm Parm2 .
  Command = translate(Command) /*make sure its uppercase*/
  /*say 'I:' i ' ' LogLine.i*/
  /*say 'Line:' i 'Command:' Command 'Parm:' parm*/
  i = i + 1
  select
   when Command = 'RETR' then do /*user is downloading*/
        Filename = Parm
        parse var LogLine.i . . 'Reply:' NumericCode Word1 . . . . . . PreSize .
        i = i + 1
        if NumericCode = 150 then do /*successful*/
            parse var LogLine.i . . . NumericCode .
            if NumericCode = 226 then /*skip resultline only if successful*/
                i = i + 1
            parse var Presize '(' Filesize .
            call Report XferLevel, 'Socket' Sock' retrieved' Filename '('Filesize 'bytes)'
            BytesDown = BytesDown + Filesize
            FilesTotal = FilesTotal + 1
            FilesDown = FilesDown + 1
            end /*150*/
        else if NumericCode = 550 then do  /*bad attempt*/
            if Word1 = 'You' then
              call Report 1, 'Socket' Sock 'tried to illegaly retrieve' Filename
              end
        else do
            call Report 0, 'ERROR: Unknown result code ('NumericCode') from RETR on socket' Sock
            i_max = 0
            return
            end
        end /*RETR*/

   when Command = 'STOR' then do /*user is uploading*/
        Filename = Parm
        parse var LogLine.i . . 'Reply:' NumericCode Word1 .
        i = i + 1
        if NumericCode = 150 then do /*successful*/
            parse var LogLine.i . . . NumericCode .
            if NumericCode = 226 then
                i = i + 1 /*skip resultline only if successful*/
            call Report XferLevel, 'Socket' Sock' uploaded' Filename
            FilesTotal = FilesTotal + 1
            FilesUp = FilesUp + 1
            end /*150*/
        else if NumericCode = 550 then do  /*bad attempt*/
            if Word1= 'You' then 
              call Report 1, 'Socket' Sock 'tried to illegaly upload' Filename
            end
        else do
            call Report 0, 'ERROR: Unknown result code ('NumericCode') from SEND on socket' Sock
            i_max = 0
            return
            end
        end /*STOR*/

   when Command = 'ABOR' then do
        select
            when LastCommand = 'STOR' then do
                    FilesUpAbor = FilesUpAbor + 1
                    FilesUp = FilesUp - 1
                    call Report XferLevel, 'Socket' Sock 'aborted upload of' Filename
                    i = i + 1
                    end /*ABOR STOR*/
            when LastCommand = 'RETR' then do
                    FilesDownAbor = FilesDownAbor + 1
                    FilesDown = FilesDown - 1
                    BytesDown = BytesDown - Filesize
                    call Report XferLevel, 'Socket' Sock 'aborted download of' Filename
                    i = i + 1
                    end /*ABOR STOR*/
            otherwise i = i + 1
            end /*select*/

        /*handle ABOR closing a data connection*/
        parse var LogLine.i . . . NumericCode .
        if NumericCode = 226 then i = i + 1
        end /*ABOR*/
   
   when Command = 'HELP' then do
        if Parm = '' then i = i + 2 /*Display avail commands*/
        else if ((Parm = 'SITE') & (Parm2 = '')) then i = i + 2
        else i = i + 1 /*HELP for 1 command*/ 
        end /*HELP*/

   when Command = 'SITE' then do
        if Parm = 'IDLE' then do
             call Report 2, 'Socket' Sock 'reset idle time to' Parm2 'seconds.'
             i = i + 1
             end
        else if ((Parm = 'HELP') & (Parm2 = '')) then i = i + 2
        else i = i + 1  /*no other SITE commands are implemented*/
        end

   when Command = 'RNFR' then do /*see also RNTO*/
        Filename = Parm
        parse var LogLine.i . . 'Reply:' NumericCode Word1 .
        i = i + 1
        if ((NumericCode = 550) & (Word1 = 'You')) then
          call Report 1, 'Socket' Sock 'tried to illegally rename' Filename
        end /*RNFR*/

   when Command = 'DELE' then do
        Filename = Parm
        parse var LogLine.i . . 'Reply:' NumericCode Word1 .
        i = i + 1
        if NumericCode = 250 then do
            DeletedFiles = DeletedFiles + 1
            call Report 1, 'Socket' Sock 'deleted' Filename
            end
        else if Word1 = 'You' then call Report 1, 'Socket' Sock 'attemted to illegally delete' Filename     
        end /*DELE*/

   when Command = 'LIST' then do
        parse var LogLine.i . . 'Reply:' NumericCode .
        i = i + 1
        if NumericCode = 150 then i = i + 1 /*gives 2 Replys: for ok LIST*/
        end /*LIST*/

   when Command = 'NLST' then do
        parse var LogLine.i . . 'Reply:' NumericCode .
        i = i + 1
        if NumericCode = 150 then i = i + 1 /*gives 2 Replys: for ok LIST*/
        end /*NLST*/

   when Command = 'QUIT' then do
        call Report 2, 'Socket' Sock 'user logged out normally.'
        i_max = 0
        return
        end /*QUIT*/

   when ((Command = 'CWD') | (Command = 'XCWD'))  then do
        parse var LogLine.i . . 'Reply:' NumericCode .
        i = i + 1
        if NumericCode = 250 then
            call Report CWDLevel, 'Socket' Sock 'did a CWD to' Parm
        else
            call Report CWDLevel, 'Socket' Sock 'failed a CWD to' Parm
        end
        
   when ((Command = 'CDUP') | (Command = 'XCUP')) then do
        parse var LogLine.i . . 'Reply:' NumericCode .
        i = i + 1
        /*log CDUP as a "CWD .."*/
        if NumericCode = 250 then
            call Report CWDLevel, 'Socket' Sock 'did a CWD to ..'
        else
            call Report CWDLevel, 'Socket' Sock 'failed a CWD to ..'
        end
        
   when Command = 'PORT' then
        i = i + 1 /*Can these be anything but successful?!*/

   when Command = 'RNTO' then i = i + 1
   when Command = 'ACCT' then i = i + 1 /*Not Implemented by ftpd*/
   when Command = 'SMNT' then i = i + 1 /*Not Implemented "   "  */
   when Command = 'REIN' then i = i + 1 /*Not Implemented*/
   when Command = 'MLFL' then i = i + 1 /*Not Implemented*/
   when Command = 'MAIL' then i = i + 1 /*Not Implemented*/
   when Command = 'MSND' then i = i + 1 /*Not Implemented*/
   when Command = 'MSOM' then i = i + 1 /*Not Implemented*/
   when Command = 'MSAM' then i = i + 1 /*Not Implemented*/
   when Command = 'MRSQ' then i = i + 1 /*Not Implemented*/
   when Command = 'MRCP' then i = i + 1 /*Not Implemented*/
   when Command = 'REST' then i = i + 1 /*Not Implemented*/
   when Command = 'ALLO' then i = i + 1 /*ALLO is ignored by FTPD*/
   when Command = 'SYST' then i = i + 1 /*gives system type*/
   when Command = 'STAT' then i = i + 2 /*gives server status*/
   when Command = 'NOOP' then i = i + 1
   when Command = 'MODE' then i = i + 1
   when Command = 'SIZE' then i = i + 1
   when Command = 'MDTM' then i = i + 1 /*gives time/date info on file*/
   when Command = 'TYPE' then i = i + 1
   when ((Command = 'MKD') | (Command = 'XMKD'))  then i = i + 1
   when ((Command = 'RMD') | (Command = 'XRMD'))  then i = i + 1 /*can only RMD empty dirs anyway*/
   when ((Command = 'PWD') | (Command = 'XPWD'))  then i = i + 1
   otherwise do
        call Report 2, 'Socket' Sock 'entered a command ('Command') not currently parsed.'
        if Command = '' then do
            call Report 0, 'ERROR: Parsing out of sync on line' i', skipping rest of Socket' Sock
            Sync_Errors = Sync_Errors + 1
            return
            end
        i = i + 1
        end
  end /*select*/
  LastCommand = Command
  parse var LogLine.i . . . NumericCode Word1 Junk .
  if ((NumericCode = 221) & (Word1 \= 'Goodbye.')) then do
        call Report 2, 'Socket' Sock 'unexpectedly logged out (no QUIT).'
        i_max = 0
        return
        end
  if ((NumericCode = 421) & (Word1 = 'Timeout')) then do
        parse var Junk '('Time 'seconds' .
        call Report 2, 'Socket' Sock 'timed out after' Time 'seconds.'
        i_max = 0
        return
        end
end /*while*/

return
