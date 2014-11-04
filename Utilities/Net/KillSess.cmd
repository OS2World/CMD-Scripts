/* */
/***************************************************
Deletes sessions that:
   - have no open files
   - less than 10 minute idle time
   - have no user ID show up with net sess
   - are windows NT or Win2000 client (OS/2 LS 3.0)

Requirement:
   - must have an ADMIN logged on the server that 
        this program runs on
****************************************************/


'@rxqueue /clear'
say date() time()
'call net sess | find /i " 00:0" | find /i "                         OS/2 LS 3.0" | find /i "  0  "'
'call net sess | find /i " 00:0" | find /i "                         OS/2 LS 3.0" | find /i "  0  " | rxqueue'
s=0
do queued()
	pull data
	if data<>'' then do
		s=s+1
		pcname.s=strip(word(data,1))
		end 
	end /* queued */
totalS=s

s=0
do totalS
	s=s+1
	'call net sess 'pcname.s' /delete'
	end /* totalS */

EXIT
