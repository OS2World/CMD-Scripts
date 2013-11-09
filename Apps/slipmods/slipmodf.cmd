/* file created on 13-03-94                     */
/* slipmods.txt                                 */
/* by Harold Roussel, roussel@physics.mcgill.ca */
/*--------------------------------------------------------------------------*/
/*    waitfor3 ( waitstring1 , waitstring2 , waitstring3)		    */
/*..........................................................................*/
/*									    */
/* Waits for the supplied strings to show up in the COM input.  All input   */
/* from the time this function is called until the string shows up in the   */
/* input is accumulated in the "waitfor_buffer" variable.		    */
/*									    */
/*--------------------------------------------------------------------------*/
/* modified to accomodate three strings				    	    */
/* this functions returns 1, 2, or 3 depending on which string was received */
/* first								    */

waitfor3:

   parse arg waitstring1 , waitstring2 , waitstring3 , timeout

   waitfor_buffer = '' ; done = 0 ; curpos = 1

   if (remain_buffer = 'REMAIN_BUFFER') then do
      remain_buffer = ''
   end

   do while done = 0
      if (remain_buffer \= '') then do
         line = remain_buffer
	 remain_buffer = ''
      end
      else do
         line = slip_com_input(interface)
      end
      waitfor_buffer = waitfor_buffer || line
      index1 = pos(waitstring1,waitfor_buffer)
      index2 = pos(waitstring2,waitfor_buffer)
      index3 = pos(waitstring3,waitfor_buffer)
      if (index1 > 0) then do
         remain_buffer = substr(waitfor_buffer,index1+length(waitstring1))
	 waitfor_buffer = delstr(waitfor_buffer,index1+length(waitstring1))
         stringchosen = 1
         done = 1
      end
      else do
	if (index2 > 0) then do
		remain_buffer = substr(waitfor_buffer,index2+length(waitstring2))
		waitfor_buffer = delstr(waitfor_buffer,index2+length(waitstring2))
		stringchosen = 2
		done = 1
	end
	else do
		if (index3 > 0) then do
		remain_buffer = substr(waitfor_buffer,index3+length(waitstring3))
		waitfor_buffer = delstr(waitfor_buffer,index3+length(waitstring3))
		stringchosen = 3
		done = 1	
		end
	end
      end

      call charout , substr(waitfor_buffer,curpos)
      curpos = length(waitfor_buffer)+1
    end

  return

/*--------------------------------------------------------------------------*/
/*    waitfor2 ( waitstring1 , waitstring2 )				    */
/*..........................................................................*/
/*									    */
/* Waits for the supplied strings to show up in the COM input.  All input   */
/* from the time this function is called until the string shows up in the   */
/* input is accumulated in the "waitfor_buffer" variable.		    */
/*									    */
/*--------------------------------------------------------------------------*/
/* modified to accomodate a second string				    */
/* this functions returns 1 or 2 depending on which string was received     */
/* first								    */

waitfor2:

   parse arg waitstring1 , waitstring2 , timeout

   waitfor_buffer = '' ; done = 0 ; curpos = 1

   if (remain_buffer = 'REMAIN_BUFFER') then do
      remain_buffer = ''
   end

   do while done = 0
      if (remain_buffer \= '') then do
         line = remain_buffer
	 remain_buffer = ''
      end
      else do
         line = slip_com_input(interface)
      end
      waitfor_buffer = waitfor_buffer || line
      index1 = pos(waitstring1,waitfor_buffer)
      index2 = pos(waitstring2,waitfor_buffer)
      if (index1 > 0) then do
         remain_buffer = substr(waitfor_buffer,index1+length(waitstring1))
	 waitfor_buffer = delstr(waitfor_buffer,index1+length(waitstring1))
         stringchosen = 1
         done = 1
      end
      else do
	if (index2 > 0) then do
		remain_buffer = substr(waitfor_buffer,index2+length(waitstring2))
		waitfor_buffer = delstr(waitfor_buffer,index2+length(waitstring2))
		stringchosen = 2
		done = 1
	end
      end

      call charout , substr(waitfor_buffer,curpos)
      curpos = length(waitfor_buffer)+1
    end

  return

The result is returned in the variable stringchosen.
Extension to "waitfor4", etc should be obvious.


Part II - Examples

The first example is for redialing.  There are three
possible answers here so I chose the waifor3 subroutine.

/* Make the call */
phoneresult = 2
do while phoneresult > 1
	call SysSleep 1
	call send 'atdt1234567'
	call send cr
	call waitfor3 'CONNECT 2400', 'BUSY' , 'NO CARRIER' ; call waitfor crlf
	phoneresult = stringchosen
	call flush_receive 'echo'
end
/* Now connected */

As long as phoneresult is 2 (BUSY) or 3 (NO CARRIER),
the modem will pause for 1 second and then redial.  When
the result is 1 (CONNECT 2400) further processing can
continue.

The second example uses waitfor2.  The script specifies
a class for logging into a terminal server.  If everything
is ok then the string "start" is received.  But if it is
busy it will ask me if I want to "wait?".  In that case I
must say yes "y" and waitfor the string are you "ready?".

/* Enter class */
call waitfor 'class' ; call flush_receive 'echo'
call send 'ts' || cr
call waitfor2 'start' , 'WAIT?'
phoneresult = stringchosen
call flush_receive 'echo'

if (phoneresult = 2) then do
	call send 'y'
	call send cr
	call waitfor 'READY?'
	call send 'y'
	call send cr
end
/* Can proceed to start the slip server */

This example should be self-explanatory.
