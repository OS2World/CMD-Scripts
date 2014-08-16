/* mailproc.cmd, written by Zsolt Kadar, 03.05.2000 *************************/

/* Account settings , you must change it! ***********************************/
pop 	= 'your.pop.server.org'			/* pop server name 	      */
smtp	= 'your.smtp.server.org'		/* smtp server name 	    */
user	= 'your.user.id'			      /* pop user id 		        */
pwd 	= '6BA064A072207A736F6C74'	/* converted password	    */

/* Work day settings, you may change it. ************************************/
begin_hour1 	= 18			/* begin hour polling email */
end_hour1 	= 22				/* end hour polling email   */
period1 	= 3600				/* pause between polls in s */

/* Weekend settings, you may change it. *************************************/
begin_hour2 	= 8				/* begin hour polling email */
end_hour2 	= 22				/* end hour polling email   */
period2 	= 7200				/* pause between polls in s */

/* Logfile name, you may change it. *****************************************/
logfile 	= 'MAILPROC.LOG'		/* main log file name       */

/* Dialer commands, you may change it. **************************************/
dialeron	= ''				/* command to dial your isp */
dialeroff	= ''				/* comm. to stop the dialer */

/****************************************************************************/
/* Do not change anything under this line!!! ********************************/
/****************************************************************************/
'@cls'
'@echo off'
'md LOGS >NUL 2>>&1'
'md WAIT >NUL 2>>&1'
'md DONE >NUL 2>>&1'

/* backing up previous log */
'copy LOGS\'||logfile 'LOGS\'||substr(logfile, 1, lastpos('.', logfile))||'BAK >NUL 2>>&1'
'del  LOGS\'logfile' >NUL 2>>&1'

/* loading rexxutil */
call RxFuncAdd 'SysLoadFuncs',  'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* initializing */
call psetup
call display 'MailProc 1.0 is started with parameters: 'begin_hour end_hour period pop smtp user
sleepy = 0

/* handle emails */
do forever

	/* set parameters */
	call psetup

	/* check time */
	current_hour = substr(time(), 1, 2)
	
	/* should we do something? */
	if current_hour+1 > begin_hour & current_hour < end_hour then
		do
			/* process emails */
			if sleepy <> 0 then 
				do
					call display 'It is time to wake up!'
					sleepy = 0
				end
			call processjobs
		end
	else
		do
			/* sleep */
			say 
			if sleepy <> 1 then
				do
					call display "It is time to sleep!"
					sleepy = 1
				end
			say 'Waiting 'period' seconds. Press CTRL-C to exit.'
			call syssleep period
		end
end

exit


/* read mail, execute jobs and send reply ***********************************/
processjobs:
	say 
	call display 'Checking for command email.'
	if length(dialeron) > 0 then dialeron
	'call getcmail 'pop user convert(pwd)
	if Rc <> 0 then call error 1

	/* find new commands */
	Rc = SysFileTree('WAIT\*.CMD', 'cmdfile', 'FO')
	If cmdfile.0 > 0 then
		do i = 1 to cmdfile.0
			 job = substr(cmdfile.i, 1, lastpos('.', cmdfile.i)-1)
			 if stream(job||'.BSY', 'c', 'query exists') = '' then
				do
					call display 'Processing command: 'job
					'echo BUSY > 'job||'.BSY'
					'start /min /c 'cmdfile.i' > 'job||'.LOG 2>>&1'
			 		if Rc <> 0 then call error 2
			 		call lineout 'LOGS\mailproc.log', Date() Time()': Command file 'cmdfile.i' executed.'
				end
		end
	else
		say 'No new commands to process.'

	/* waiting for the commands to be processed */
	call syssleep 60*cmdfile.0

	/* find new completed jobs */
	Rc = SysFileTree('WAIT\*.LOG', 'logfile', 'FO')
	If logfile.0 > 0 then
		do i = 1 to logfile.0
			 job = substr(logfile.i, 1, lastpos('.', logfile.i)-1)
			 if stream(job||'.RDY', 'c', 'query exists') <> '' then
				do
					call display 'Sending reply to command: 'job
					'call sndcmail 'smtp job
			 		if Rc <> 0 then 
						call error 3
					else do
			 			call lineout 'LOGS\mailproc.log', Date() Time()': Response for 'cmdfile.i' sent.'
						'del 'job||'.BSY >NUL'
						'del 'job||'.RDY >NUL '
						'del DONE\'substr(job, lastpos('\', job)+1)'.* >NUL 2>>&1'
						'move 'job'.* DONE >NUL'
			 			if Rc <> 0 then call error 4
					end
				end
		end
	else
		say 'No new results to send.'

	if length(dialeroff) > 0 then dialeroff
	say 'Waiting 'period' seconds. Press CTRL-C to exit.'
	call syssleep period
return


/* logs errors **************************************************************/
error: procedure
	code = arg(1)
	call lineout 'LOGS\mailproc.log', Date() Time()': Error occured. Code:'code'.'	
return


/* converts pwd *************************************************************/
convert: procedure
	pwd = arg(1)
	pwd = x2c(pwd)
return pwd


/* sets up checking periods *************************************************/
psetup:
datum = date('U')
parse var datum honap '/' nap '/' ev
if Zeller() > 4 then /* 5, 6 = weekend, 0, 1, 2, 3, 4 = work day */ 
	do
		begin_hour = begin_hour2
		end_hour   = end_hour2
		period     = period2
	end
else
	do
		begin_hour = begin_hour1
		end_hour   = end_hour1
		period     = period1
	end
return


/* what day is it (Hungarian, enjoy!) ***************************************/
Zeller:
	IF honap > 2 THEN
	        DO
	                kepzett_honap = honap - 2
	                kepzett_ev    = ev
	        END
	ELSE
	        DO
	                kepzett_honap = honap + 10
	                kepzett_ev    = ev - 1
	        END

	evszazad       = kepzett_ev % 100
	ev_a_szazadban = kepzett_ev - 100 * evszazad
	a_het_napja    = ((13 * kepzett_honap - 1) % 5 + nap +,
        	         ev_a_szazadban + ev_a_szazadban % 4 - evszazad -,
                	 - evszazad + 77) // 7
RETURN a_het_napja


/* shows and logs information ***********************************************/
display: 
	string = arg(1)
	call lineout 'LOGS\'logfile, Date() Time()': 'string
	say string
return

