/* WORKSRV.CMD
Handles SLIP login and routing
Put this file in \TCPIP\BIN on the work machine.
This file is called from WORKSRV.CFG, which is called from WORKSRVD.CMD

Configuration: set the Rexx variables below:
*/
/* Serial Port Configuration and modem strings */
comport   = 'COM1'
comparms  = '57600,n,8,1'    /* com port mode command parameters   */
initcmd   = 'ATZ'	     /* modem reset string		   */
anscmd	  = 'ATS0=1'	     /* set modem into autoanswer mode	   */
connectstring='CONNECT'      /* Adjust this to your brand of modem.*/



/* Internet addresses, machine names */
ipaddress  = '199.99.99.88'	 /* Work PC's IP address for sl0 interface */
ipdest	   = '199.99.99.99'	 /* Home PC's IP address for sl0 interface */
netmask    = '255.255.255.0'
/* The parms below are only used if the Work machine is on Ethernet	   */
desthostname = 'homemachine'		   /* Home PC's name. Must be known to DNS */
macaddress   = '00:00:c0:55:66:77:88' /* Work PC's hardware MAC address       */

/* Users */
username = 'yourname'	    /* ID for logging into home machine       */
password = 'secret'	    /* Password for logging into home machine */

/* If the Work machine is not on Ethernet, change Ethercard='T' to Ethercard='F'.*/
Ethercard = 'T'







/****************************************************************************/

/* Define routines for errorhandling */
signal on error name errorhandler
signal on failure name errorhandler
signal on halt name errorhandler
/* signal on novalue name errorhandler */
signal on syntax name errorhandler
signal on notready name errorhandler

/* Load RexxUtility functions */
call RxFuncAdd 'SysSleep', 'RexxUtil', 'SysSleep'


parse arg interface

/*--------------------------------------------------------------------------*/
/*                   Initialization and Main Script Code                    */
/*--------------------------------------------------------------------------*/

/* Set some definitions for easier COM strings */
cr='0d'x
crlf='0d0a'x
timeout = 0

say ''
say ' OS/2 Slip Server (interface 'interface')'

/* Initialize com port:     mode com2 57600,n,8,1,buffer=on  */
'mode 'comport comparms

/* Do this until SLIP command was sent */
do until connect

   /* Flush any stuff left over from previous COM activity */
   call flush_receive

   /* Init modem */
   call lineout , 'Reset modem...'
   call send initcmd || cr
   call waitfor 'OK', 5 ; call flush_receive 'echo'
     if RC = 1 then do
       call lineout , 'Modem not resetting... Try again'
       call send '+++'
       exit 1
     end

   /* Set modem into auto-answer mode */
   call lineout , 'Set auto answer...'
   call send anscmd || cr
   call waitfor 'OK', 40 ; call waitfor crlf , 2
    if RC = 1 then do
       call lineout , ' Modem not responding... Try again '
       exit 2
     end

   /* Flush anything else */
   call flush_receive 'echo'

   /* Wait for call */
   say 'Waiting for connection started on' date() 'at' time()'.'
   do while waitfor(connectstring,1)\=0
      call SysSleep 3
   end
   call waitfor crlf , 2
   say 'Login process started on' date() 'at' time()'.'

   call waitfor crlf , 2

   /* Send login */
   call send 'OS/2 Slip Server '||cr
   do 2
      call send crlf
   end

/* Prompt for User and wait for username */
   call send 'User:'
   call waitfor username, 30, 1
   if rc\=1 then call waitfor cr, 30
   if rc=1 then do
      say 'Unsuccessfull login on' date() 'at' time()'.'
      call SysSleep 1
      call send '+++'
      call SysSleep 2
      call send 'ATH'||cr
      connect = 0
   end

/* If User OK, prompt for Password: and wait for PW */
   call send crlf
   call send 'Password:'
   call waitfor password, 30, 1

   if rc\=1 then call waitfor cr, 30

   if rc=1 then do
      say 'Unsuccessfull login on' date() 'at' time()'.'
      call SysSleep 1
      call send '+++'
      call SysSleep 2
      call send 'ATH'||cr
      connect = 0
   end
   else do
      say 'Successfull login on' date() 'at' time()'.'
      connect = 1
   end

   call flush_receive 'echo'
end

/* Now configure this machine for the appropriate address, */
'ifconfig sl0 'ipaddress ipdest' netmask 'netmask
'route add host 'ipdest ipaddress' 1'

/* If Work machine is on Ethernet, proxy arp handles packets going to Home machine */
if Ethercard='T' then
   'arp -s 'desthostname macaddress 'pub'

/* Tell client what to do */
call send crlf
call send 'Entering SLIP mode.'||crlf
call send 'Your IP address is 'ipdest'.  MTU is 1500 bytes'||crlf
call send "VJ Header compression is active."||crlf

call flush_receive 'echo'

/* Wait to avoid sending of garbage while client is in command mode */
call SysSleep 5

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
/* up on the COM port (in seconds).                                       */
/*                                                                          */
/*--------------------------------------------------------------------------*/

waitfor:

   parse arg waitstring , timeout, doecho .                /* Changed by MW */

   if doecho\=1 then doecho=0                              /* Changed by MW */

   if timeout = '' then
     timeout = 5000    /* L O N G   delay if not specified */
   waitfor_buffer = '' ; done = -1; curpos = 1
   ORI_TIME=TIME('R')                                      /* Changed by MW */

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
         if doecho=1 then call send line                   /* Changed by MW */
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
/*        call lineout , ' WAITFOR: timed out ' */         /* Changed by MW */
        done = 1
       end
   end
/*   timeout=0 */                                          /* Changed by MW */
   RC=done
   drop timeout doecho                                     /* Changed by MW */
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
