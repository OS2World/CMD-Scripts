/* WORKCLI.CMD
Connects to home SLIP server. Handles login and routing.
Put this file in \TCPIP\BIN on the work machine.
This file is called from WORKCLI.CFG, which is called from WORKCLID.CMD

Configuration: set the Rexx variables below:
*/
/* Serial Port Configuration and modem strings */
modeminit     = 'AT&F2' 	   /* modem init command */
modemsetparms = 'ATL1M' 	   /* speaker low volume */
modemreset    = 'ATZ'		   /* modem reset string */
phonenumber   = '9,4992222'	   /* number of home SLIP server */

/* Internet addresses, machine names */
ipaddress  = '199.99.99.88'	 /* Work PC's IP address for sl0 interface */
gateway    = '199.99.99.99'	 /* Home PC's IP address for sl0 interface */
netmask    = '255.255.255.0'
/* The parms below are only used if the Work machine is on Ethernet	   */
desthostname = 'homemachine'		   /* Home PC's name. Must be known to DNS */
macaddress   = '00:00:c0:55:66:77:88' /* Work PC's hardware MAC address       */

/* Users */
username = 'yourname'	    /* ID for logging into home machine */
password = 'secret'	    /* PW for logging into home machine */

/* If Work machine is not on Ethernet, change Ethercard='T' to Ethercard='F'.*/
Ethercard = 'T' 	    /* Ethernet at work */

/* Sounds play when connect */
playsounds = '0'		   /* set to '0' if no sound card      */
wavdir	   = 'k:\mm\wav\'          /* where *.WAV files are kept       */
wavconnect = wavdir'wild4.wav'	   /* wave file to play when connected */
wavinit    = wavdir'drumroll.wav'  /* wave file to play when starting  */

/****************************************************************************/

/* Define routines for errorhandling */
signal on error name errorhandler
signal on failure name errorhandler
signal on halt name errorhandler
/* signal on novalue name errorhandler */
signal on syntax name errorhandler
signal on notready name errorhandler

/* Load RexxUtility functions */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

parse arg interface 

/*--------------------------------------------------------------------------*/
/*                   Initialization and Main Script Code                    */
/*--------------------------------------------------------------------------*/

dialcmd = 'atdt'phonenumber
say 'Dial command is:' dialcmd
try=0

/* Set some definitions for easier COM strings */
cr='0d'x
crlf='0d0a'x

say ''
say 'OS/2 SLIP Client (interface' interface')'

goback:

/* Flush any stuff left over from previous COM activity */
call flush_receive
if playsounds='1' then 'start /min/c play file='wavinit


/* Reset the modem here */
/* You may need to customize this for your modem make and model */
call lineout , 'Resetting modem...'
call send modeminit || cr
call waitfor 'OK', 5 ; call flush_receive 'echo'
call send modemsetparms || cr
call waitfor 'OK', 5 ; call flush_receive 'echo'
 if RC = 1 then do
    call lineout , 'Modem not resetting... Trying again'
    call send '+++'
    call waitfor 'OK',3
    call send modemreset || cr
    call waitfor 'OK', 3
  end

tryagain:

/* Dial the remote server */
try=try+1
call charout , try' Dialing...   '

call send dialcmd || cr
call waitfor 'BUSY', 12

if(RC > 0) then do
   say 'Possible Connection' || cr
   signal GoOn
end
call SysSleep(3)
say cr
signal TryAgain

GoOn:
/* Handle login.  We wait for standard strings, and then flush anything */
/* else to take care of trailing spaces, etc..                          */
/* call send cr */
call waitfor 'User:',70 ; call flush_receive 'echo'
 if RC = 1 then do
    call lineout , 'Server not responding... Trying again'
    signal TryAgain
  end
call send username || cr
call waitfor 'Password:' ; call flush_receive 'echo'
call send password || cr
say ''

/* Now configure this machine for the appropriate address, */
'ifconfig sl0 'ipaddress gateway' netmask 'netmask
'route add host 'gateway' 1'

/* If Work machine is on Ethernet, proxy arp handles packets going to Home machine */
if Ethercard='T' then
   'arp -s 'desthostname macaddress 'pub'

say 'IP address: 'ipaddress
say 'gateway: 'gateway

/* Play a tune to indicate connection is established */
if playsounds='1' then 'start /min/c play file='wavconnect

/* All done */
exit 0

/*--------------------------------------------------------------------------*/

/* Errorhandler */
errorhandler:
say copies('=',79)
say 'ERROR OCCURED:'
say '   Condition:' condition('c')
say '   Instruction:' condition('i')
say '   Description:' condition('d')
say '   Status:' condition('s')
say '   Line:' sigl
say copies('=',79)
return 0

/*--------------------------------------------------------------------------*/
/*                            send ( sendstring)                            */
/*..........................................................................*/
/*                                                                          */
/* Routine to send a character string off to the modem.                     */
/*                                                                          */
/*--------------------------------------------------------------------------*/

send:

   parse arg sendstring
   call slip_com_output interface , sendstring

   return


/*--------------------------------------------------------------------------*/
/*                    waitfor ( waitstring , [timeout] )                    */
/*..........................................................................*/
/*                                                                          */
/* Waits for the supplied string to show up in the COM input.  All input    */
/* from the time this function is called until the string shows up in the   */
/* input is accumulated in the "waitfor_buffer" variable.                   */
/*                                                                          */
/* If timeout is specified, it says how long to wait if data stops showing  */
/* up on the COM port (in seconds).                                         */
/*                                                                          */
/*--------------------------------------------------------------------------*/

waitfor:

   parse arg waitstring , timeout

   if timeout = '' then
     timeout = 5000    /* L O N G   delay if not specified */
   waitfor_buffer = '' ; done = -1; curpos = 1
   ORI_TIME=TIME('E')

   if (remain_buffer = 'REMAIN_BUFFER') then do
      remain_buffer = ''
   end

   do while (done = -1)
      if (remain_buffer \= '') then do
         line = remain_buffer
         remain_buffer = ''
       end
       else do
         line = slip_com_input(interface,,10)
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
      if ((done \= 0) & (TIME('E')>timeout)) then do
        call lineout , ' WAITFOR: timed out '
        done = 1
       end
   end
   timeout=0
   RC=done
 return RC



/*--------------------------------------------------------------------------*/
/*                               readpass ()                                */
/*..........................................................................*/
/*                                                                          */
/* Routine used to read a password from the user without echoing the        */
/* password to the screen.                                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

readpass:

  answer = ''
  do until key = cr
    key = slip_getch()
    if key \= cr then do
      answer = answer || key
    end
  end
  say ''
  return answer


/*--------------------------------------------------------------------------*/
/*                             flush_receive ()                             */
/*..........................................................................*/
/*                                                                          */
/* Routine to flush any pending characters to be read from the COM port.    */
/* Reads everything it can until nothing new shows up for 100ms, at which   */
/* point it returns.                                                        */
/*                                                                          */
/* The optional echo argument, if 1, says to echo flushed information.      */
/*                                                                          */
/*--------------------------------------------------------------------------*/

flush_receive:

   parse arg echo

   /* If echoing the flush - take care of waitfor remaining buffer */
   if (echo \= '') & (length(remain_buffer) > 0) then do
      call charout , remain_buffer
      remain_buffer = ''
   end

   /* Eat anything left in the modem or COM buffers */
   /* Stop when nothing new appears for 100ms.      */

   do until line = ''
     line = slip_com_input(interface,,100)
     if echo \= '' then
        call charout , line
   end

   return

