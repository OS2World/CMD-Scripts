/* REXX */
/* CCT, Inc. / POB 3350 / Sedona, AZ 86340 / 520-646-0331 */
/* Rewritten by Pat Martini */
/* send questions/comments to cct@sedona.net */
/* CCTDIAL.CMD - An adaptation of the original OS/2 Warp Rexx file which was */
/*      Written by: Don Russell (c) April 1995 */
/*      send email to drussell@direct.ca */
/* Portions Copyright (c)June 1995 - CCT, Inc. */
 
/* v1.1 */

/* NOTE: All text-type user parameters are to be entered between */
/*   two single quotes: '' (do not use double quotes: ") */

/* ------------------------------------Change the next (3) entries ------------------------------------- */
/* k1 - Fill-in your provider's phone number, after the atdt (add area code if nec.) */
/* k2 - Fill-in your user ID name (and any provider-required prefix if necessary) */
/* k3 - Fill-in your password */
/*       ---or---       */
/* Remove all but the quote marks and send the info via the Login		     */
/* Sequence on Page 1 of the Modify Entries Settings Notebook as follows:   */
/*	cctdial.cmd ATDTxxx-xxxx userid password			     */
/* substitute you provider's phone number and your userid and password       */
/* The latter method is used when more than one provider is configured	      */

k1 = 'ATDTxxx-xxxx'	/* dial command/number to call your PPP provider */
k2 = 'myuserid'		/* your userid. (include 'special' chars like %p) */
k3 = 'mypassword'	/* your case-sensitive password */

/* -------------------Change the Script Parameters Only if Necessary---------------------- */

timeout = 45		/* # seconds to wait for host userid request */
pause = 10		/* # seconds to wait between redials */
maxtry = 5		/* # tries to connect before program abort */

/* -------------------Change Modem Startup Codes Only if Necessary--------------------- */

ModemResetCommand = 'ATH0Z'	/* modem hangup and reset */

/* --------------------------------------Custom Access Variables------------------------------------ */

k4 = ''	/* secondary access number (alternates if busy) */
prompt3 = ''	/* Additional prompt sent by provider (3rd) */
response3 = ''	/* Your response for above prompt */
/* NOTE: You may enter crlf WITHOUT SINGLE QUOTES if above is Enter key */

/* ================================================================= */
/* =========DO NOT CHANGE ANYTHING AFTER THIS POINT=========== */
/* ================================================================= */

LoginPrompt = 'ogin:'			/* look for part of login */
PasswordPrompt = 'ssword:'		/* look for part of password */

if k4 \='' then do				/* set altcall flag if second number */
    altcall=1
    numflip=0				/* set numflip flag for first number flip */
end
else do
    altcall=0
end
if prompt3 \='' then do			/* set addprompt flag if 3rd prompt */
    addprompt=1
end
else do
    addprompt=0
end

call rxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* check that PPP connection is selected */

if RxFuncQuery( 'ppp_com_input' ) = 1 then do
   if RxFuncQuery( 'slip_com_input' ) = 0 then do
      call lineout ,'This script is for PPP only.'
      call lineout ,'Your dialer is set for SLIP.'
      call lineout ,'Change your dialer and try again.'
      call sysSleep 60
      exit 0
   end  /* Do */
   
   call NotFromDialer
   exit 0
end  /* Do */

parse arg interface , port , . , dialcmd , username , password

/*--------------------------------------------------------------------------*/
/*                   Initialization and Main Script Code                    */
/*--------------------------------------------------------------------------*/

/* Set some definitions for easier COM strings */
cr='0d'x
crlf='0d0a'x

/* Fill in missing information */
if dialcmd = '' | dialcmd = '*' then do
   dialcmd = k1
end
if username = '' | username = '*' then do
   username = k2
end
if password = '' | password = '*' then do
   password = k3
end  /* Do */

/* Begin active code / show header */

call charout,crlf
call lineout ,'CCT, Inc. CCTDIAL.CMD REXX Script for OS/2'
call lineout, '            cct@sedona.net'
call lineout,' ConnTimeout='timeout' RedialPause='pause' MaxTries='maxtry
call sysSleep 2

call charout,'Dial Attempt #1 - '
call flush_receive	/* Flush any stuff left over from previous COM activity */

call ResetModem	/* Issue the ModemResetCommand */

FirstTime = 1		/* First dial attempt */
connected = 0		/* Not yet connected */
do count = 1 by 1 until connected		/* Increment count variable on each try */
    if count = maxtry+1 then do	/* Abort if max try setting reached (+initial try) */
       call lineout,'Maximum of' maxtry 'Tries Reached - Aborting...'
       exit 1
    end
    if \FirstTime then do
       call charout,crlf
       call lineout ,'CCT, Inc. CCTDIAL.CMD REXX Script for OS/2'
       call lineout , 'Waiting' pause 'seconds before try #'count crlf
       call sysSleep pause			/* wait for redial attempt */
    end  /* Do */
    FirstTime = 0				/* reset flag */

    /* Dial the remote server */
    call charout , 'Dialing...'

    /* Wait for connection */
    if ((altcall=1) & (numflip=1)) then do	/* test for and use secondary number */
      call send k4 || cr
      numflip=0				/* reset flag */
    end
    else do
      call send dialcmd || cr		/* use primary number */
      if altcall=1 then do			/* flip flag if necessary */
        numflip=1
      end
    end

    ringing:
    ResultCode = getresult( 30 )
    if left( ResultCode, 4 ) = 'RING' then
       signal ringing
    if left( ResultCode, 4 ) = 'BUSY' then
       iterate
    if left( ResultCode, 5 ) = 'ERROR' then
       exit 0
    if left( ResultCode, 7 ) \= 'CONNECT' then do
       call recycle				/* clean up and restart */
       iterate
    end
   
    /* prompt for a login id/password... :-(                   */

   call waitfor LoginPrompt, timeout	/* # seconds to wait for connection */
   if result = 1 then do
      call lineout , 'Host is not responding.'
      call recycle
      iterate
   end  /* Do */
   
   call send username || cr		/* send userid to server */

   call waitfor PasswordPrompt, 30	/* wait for Password: prompt */
   if result = 1 then do
      call lineout , 'Host is not asking for password.'
      call recycle
      iterate
   end  /* Do */
   
   call send password || cr		/* send password to server */

   if addprompt = 1 then do		/* check if we look for third prompt */
     call waitfor prompt3, 30		/* go wait for it to come */
     if result = 1 then do
       call lineout, 'Host has not sent third prompt.'
       call recycle
       iterate
     end
     call send response3 || cr		/* send third prompt response to server */
   end

   connected = 1				/* we are successfully connected  */
end					/* end main loop */

call beep 262, 250			/* Audible connect confirmation */
call beep 294, 250

exit 0					/* goodbye - our humble job is done */

ResetModem:
    call lineout , 'Resetting modem...'
    call send ModemResetCommand || cr
    ResultCode = getresult( 10 )
    if left(ResultCode , 2) \= 'OK' then do
        call lineout , 'Modem not resetting... Trying again'
        call sysSleep 2
        call send '+++'
        call waitfor crlf, 5
        call send ModemResetCommand || cr
        call getresult 10
    end
    /* call flush_receive 'echo' */
return

/* Routine to clear buffer, reset modem and flags for restart */

recycle:
     call flush_receive
     call ResetModem
     connected = 0
return

/* Routine to send a modem command. */

send:

   parse arg AtCmd
   call flush_receive
   call ppp_com_output interface , AtCmd

   return


/*--------------------------------------------------------------------------*/
/*                    getresult( [timeout] )                                */
/*                                                                          */
/* Waits for any modem response, and returns the string.    */

/* If timeout is specified, it says how long to wait if data stops showing  */
/* up on the COM port (in seconds).                                                         */
/*                                                                          */
/*--------------------------------------------------------------------------*/

getresult:

   parse arg timeout

   call waitfor crlf, timeout
   if result = 0 then
      call waitfor crlf, timeout

   if result = 1 then /* timed out */
      return '*timedout*'
   else
      return waitfor_buffer


/*--------------------------------------------------------------------------*/
/*                    waitfor ( waitstring , [timeout] )                    */
/*                                                                          */
/* Waits for a specific string from the modem. */
/* Timeout is specified in seconds.  */

waitfor:

   parse arg waitstring , timeout

   if timeout = '' then do
      timeout = 90    /* 1.5 minutes if delay not specified */
   end

   waitfor_buffer = ''
   done = -1
   curpos = 1

   if (remain_buffer = 'REMAIN_BUFFER') then do
      remain_buffer = ''
   end

   call time 'E'
   do while (done = -1)
      if (remain_buffer \= '') then do
         line = remain_buffer
         remain_buffer = ''
       end
       else do
         line = ppp_com_input(interface,,10)
      end
      waitfor_buffer = waitfor_buffer || line
      index = pos(waitstring,waitfor_buffer)
      if (index > 0) then do
         remain_buffer = substr(waitfor_buffer,index+length(waitstring))
         waitfor_buffer = delstr(waitfor_buffer,index+length(waitstring))
         done = 0
      end
      call charout , substr(waitfor_buffer,curpos)
      curpos = length(waitfor_buffer)+1
      if ((done \= 0) & (time('E')>timeout)) then do
        call lineout , ' WAITFOR: timed out '
        done = 1
       end
   end

 return done

/*--------------------------------------------------------------------------*/
/*                             flush_receive()                             */
/*                                                                          */
/* Routine to flush any pending characters to be read from the COM port.    */
/* Reads everything it can until nothing new shows up for 100ms, at which   */
/* point it returns.                                                        */
/*                                                                          */
/*--------------------------------------------------------------------------*/

flush_receive:

   parse arg echo

   /* If echoing the flush - take care of waitfor remaining buffer */
   if (echo \= '') & (length(remain_buffer) > 0) then do
      call charout , remain_buffer
      remain_buffer = ''
   end

   /* Read anything left in the modem or COM buffers */
   /* Stop when nothing new appears for 100ms.      */

   do until line = ''
     line = ppp_com_input(interface,,100)
     if echo \= '' then
        call charout , line
   end

   return

NotFromDialer:
    parse upper source . . MyDrivePathName
    MyDrive = filespec( 'D', MyDrivePathName )
    MyPath = filespec( 'P', MyDrivePathName )
    MyDrivePath = MyDrive || MyPath

    etcDrivePath = translate( value( 'etc',,'OS2ENVIRONMENT') )
    binDrive = filespec( 'D', etcDrivePath )
    binPath = filespec( 'P', etcDrivePath ) || 'BIN\'
    binDrivePath = binDrive || binPath

    EraseFile = 0
    if binDrivePath \= MyDrivePath then do
        say 'This script will be moved to' binDrivePath
        say 'Do you wish to continue? (y/n)'
        say '(Saying no will still show help)'
        answer = translate( sysGetKey( 'ECHO' ) )
        if answer = 'Y' then do
            'COPY' MyDrivePathName binDrivePath
            if rc = 0 then do
               say MyDrivePathName 'will be erased after displaying help'
               EraseFile = 1
            end
           '@PAUSE'
           call sysCls
        end /* Do */
    end  /* Do */

    call sysCls
    stop = 0
    do i = 3 by 1 until stop
       x = sourceline( i )
       if left( x, 5 ) = 'pause' then do
          '@PAUSE'
          call sysCls
          iterate
       end  /* Do */
       
       if left( x, 4 ) \= 'stop'  then
          say x
       else
          stop = 1
    end /* do */
    '@PAUSE'
    if EraseFile then
        'ERASE' MyDrivePathName
return
