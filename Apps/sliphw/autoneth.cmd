/* Log on with SLIP, doing something, and log off                 */
/* by Bruce Clarke, (Bruce.Clarke@UAlberta.ca)                  */
/* Chem Dept. UofA, April 1995                                  */

/*--------------------------------------------------------------*/
/* Parameters to be set by user                                 */
DNSIP=129.128.5.233     /* any convenient machine to ping       */
/*--------------------------------------------------------------*/
say 'This is AUTONETH.CMD'

file='c:\junk01.tmp'    /* temporary file, will be destroyed  */

/* parse arg '"' command1 '"' command2 '"' command3 '"'  command4 '"' command5 '"' */
parse arg command1 ')' command2 ')' command3 ')'  command4 ')' command5 ')'


if command1='' then do
   say 'Give the Internet program and its parameters on command line.'
   say 'Several programs with parameters may be given. Put each one'
   say 'and its parameters in parentheses.'
   say 'Example: autonet (nistime -s1) (call umailget)'
   exit 0
end
 
if command1<>'' then do
   parse var command1 '(' command1
   say 'First program: 'command1
end 
if command2<>'' then do
   parse var command2 '(' command2
   say 'Next program: 'command2
end 
if command3<>'' then do
   parse var command3 '(' command3
   say 'Next program: 'command3
end 
if command4<>'' then do
   parse var command4 '(' command4
   say 'Next program: 'command4
end 
if command5<>'' then do
   parse var command5 '(' command5
   say 'Next program: 'command5
end 

/* Is SLIP is running? If so, we won't log on or hangup. 
We'll just execute the commands */

tcpipwasup=checkfortcpip()
if tcpipwasup=1 then do
   say 'TCPIP is already running'
end
else do
   say 'Starting TCPIP...'
   'start /C/min home2wrk'
   /*'start /C/min slip -f homecli.cfg'*/
   say 'Waiting for SLIP to connect'
   if waitfortcpip()=0 then do
      say 'Slip dialer failed. Quitting.'
      exit 1
   end  /* Do */
end 

say 'Beginning Internet Jobs.'
call syssleep 5
command1               /* Do command given on command line */

if command2<>'' then do
  call syssleep 5
  command2
end
if command3<>'' then do
  call syssleep 5
  command3
end
if command4<>'' then do
  call syssleep 5
  command4
end
if command5<>'' then do
  call syssleep 5
  command5
end

call syssleep 5

/* Kill tcpip only if it we got it running */
if tcpipwasup=0 then
  'slipkill'

say 'Internet Jobs Finished.'
exit 0

/*------------------------------------------------------------*/
/*                    waitfortcpip()                          */
/*............................................................*/
/*                                                            */
/* Waits for TCP/IP to get working. Determines whether it is  */
/* functioning by pinging the UofA Domain Name Server.        */
/* Attemps to ping every 20 seconds forever until it succeeds */
/*                                                            */
/* Checks to make sure SLIP.EXE has not encountered an error  */
/* and quit. For example, ZOC may have COM port and SLIP will */
/* then quit. Returns 1 if successful, 0 if SLIP quit         */
/*                                                            */
/*------------------------------------------------------------*/

waitfortcpip:

  do forever
    /* Send one ping packet to the DNSIP. Redirect error
    messages to nul. Put the line of output with the number of
    received and transmitted packets in file.
    */
    '@ping 'DNSIP' 56 1 2> nul | find "transmitted" > 'file
    do while LINES(file) > 0
      line=LINEIN(file)
      /* say 'line is 'line */
      parse var line aa bb cc dd .
      /* say 'Packets received 'dd */
      if dd=1 then do
         call SysFileDelete file
         return 1
      end  /* Do */
    end /* do */
    call STREAM file,'C','CLOSE'

    /* Make sure SLIP.EXE is still operating. If this runs
    when another program has control of the com port (ZOC)
    then SLIP will terminate with an error. We detect this
    situation here
    */
    '@pstat | find "SLIP.EXE" > 'file
    numlines=0
    do while LINES(file) > 0
      line=LINEIN(file)
      /* say 'PStat ouput 'line */
      numlines=numlines+1
    end /* do */
    call STREAM file,'C','CLOSE'
    if numlines=0 then do
       return 0
    end
    call syssleep 20
  end

/*--------------------------------------------------------*/
/*                    checkfortcpip()                     */
/*........................................................*/
/*                                                        */
/* Checks if TCP/IP is working by pinging the DNS         */
/* Returns 0 if down, 1 if up.                            */
/*                                                        */
/*--------------------------------------------------------*/

checkfortcpip:

  '@ping 'DNSIP' 56 1 2> nul | find "transmitted" > 'file
  line=LINEIN(file)
  parse var line aa bb cc dd .
  call STREAM file,'C','CLOSE'
  call SysFileDelete file
return dd

