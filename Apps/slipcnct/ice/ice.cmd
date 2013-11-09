/* ICEonline Logon Script for OS/2 Warp Version 3 */
/* Created: October 18, 1994                            */
/* Tested: December 5, 1994                             */

/* ****************************************** */
/* IMPORTANT: This script was tested using the dialer */
/* settings outlined in ICE.TXT. You should read that */
/* file (should be in this zip) before attempting to */
/* connect. */
/* ****************************************** */

parse arg interface , dialcmd username password

/*--------------------------------------------------------------------------*/
/*                   Initialization and Main Script Code                    */
/*--------------------------------------------------------------------------*/

reset_modem='ATZ'
init_modem='AT&F1'    /* This init string works with 99% of modems...only change if neccessary */
hangup_modem='ATH'


cr='0d'x
crlf='0d0a'x


'route -fh'



/* Set ICE SLIP Router Address On Next Line! */
ice_route = '198.231.65.3'


say 'ICEonline OS/2 Warp SLIP Login Script ',
    '(interface' interface')'


/* Flush any stuff left over from previous COM activity */
call flush_receive

/* Reset the modem here */

call lineout , 'Reset modem...'
call send init_modem || cr
call waitfor 'OK', 5 ; call flush_receive 'echo'
 if RC = 1 then do
    call lineout , 'Modem not resetting... Trying again'
    call send '+++'
    call waitfor 'OK'
    call send hangup_modem || cr
    call waitfor 'OK', 3
  end

/* Dial the remote server */
call charout , 'Now Dialing...'

/* Wait for connection */
call send dialcmd || cr
call waitfor 'CONNECT' ; call waitfor crlf
call flush_receive 'echo'

/* Handle login.  We wait for standard strings, and then flush anything */
/* else to take care of trailing spaces, etc..                          */
/* call send cr */

call send cr
call waitfor 'login:' ; call flush_receive 'echo'
call send username ||'%slip'|| cr
call waitfor 'Password:' ; call flush_receive 'echo'
call send password || cr


/* Parse the results of the SLIP command to determine our address. */
/* We use the "waitfor_buffer" variable from the waitfor routine   */
/* to parse the stuff we get from the Annex after waiting for an   */
/* appropriate point in the data stream.                           */
call waitfor 'Nameserver is' 
parse var waitfor_buffer . 'Your IP address is' a '.' b '.' c '.' d '.' .
os2_address = a||'.'||b||'.'||c||'.'||d


annex_address = ice_route


/* Flush anything else */
call flush_receive 'echo'

/* Now configure this host for the appropriate address, */
/* and for a default route through the Annex.           */

say 'SLIP Connection Established'
say 'Configuring local address =' os2_address ', Annex =' annex_address


'ifconfig sl0' os2_address' 'annex_address ' netmask 255.255.255.0'
'route add default 'annex_address' 0'


/* All done */
exit 0


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
/* up on the COM port (in seconds).                                                         */
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