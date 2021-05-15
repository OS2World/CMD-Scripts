/* What is the host name for this IP address? */

trace off
say

parse arg ipaddress dummy
ipaddress = strip( ipaddress )
if ipaddress =  "" then call Syntax
if dummy     <> "" then call Syntax
if pos( "?", ipaddress ) > 0 then call Syntax
parse value ipaddress with digit.1"."digit.2"."digit.3"."digit.4
do i = 4 to 1 by -1
	if digit.i                  =  "" then call Syntax
	if datatype( digit.i, "W" ) <>  1 then call Syntax
	if digit.i                  <   0 then call Syntax
	if digit.i                  > 255 then call Syntax
end

qname = rxqueue( "CREATE" )
address CMD "@TRACERTE "||ipaddress||" 2>&1 | RXQUEUE /FIFO"
do until queued( ) = 0
	parse pull line
	if pos( "(", line ) > 0 then do
		if word( line, 3 ) = "("||ipaddress||")" then do
			say word( line, 2 )
		end
	end
end
call rxqueue "DELETE", qname
EXIT 0


Syntax: procedure
	say "HostName,  Version 1.02 for OS/2"
	say "Retrieves the host name for a specified IP address"
	say "Written by Rob van der Woude"
	say "http://www.robvanderwoude.com"
	say
	say "Usage:  HOSTNAME  <IP_address>"
	EXIT 1
return
