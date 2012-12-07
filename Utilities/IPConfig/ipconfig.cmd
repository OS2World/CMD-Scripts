/* REXX routine to emulate the Windows "ipconfig" command */

/* This routine only handles interfaces which are up */
/* You may contact me via email to jlemay@njmc.com */
/* Revision 1.3 */

'@echo off'

parse arg iFace

didit = 0  /* For display of "OS/2 IP Configuration" line */

/* If no parm, give usage */

IF iFace = '' THEN
		DO
			CALL usage
			EXIT
		END

IF iFace = 'all' 
	THEN
		DO
			CALL sublan0
			CALL subppp0
	  		EXIT
	  	END

IF iFace = 'lan0' 
	THEN 
		Do
			CALL sublan0
			EXIT
		End

IF iFace = 'PPP0' 
	THEN 
		Do
			CALL subppp0
			EXIT
		End

IF iFace = 'ppp0' 	/* Dirty way to handle case sensitivity */
	THEN 
		Do
			CALL subppp0
			EXIT
		End

/* Handle improper arg passed */

usage:

SAY
SAY '          OS/2 IP Configuration Display Utility version 1.3'
SAY '          -------------------------------------------------'
SAY
SAY 'Usage: IPCONFIG <interface>'
SAY
SAY 'Supported Interfaces in this version are PPP0 and lan0.'
SAY
SAY '''IPCONFIG all'' may also be used to display info for all'
SAY 'active interfaces. (currently limited to PPP0 and lan0)'
SAY
EXIT

/* Begin sublan0 */
sublan0:
	
	ActiFace = 'lan0'
	'ifconfig lan0 > lan0.txt'
	'netstat -r > route.txt'
	ip = 1
			Do WHILE lines(lan0.txt)
				line = LineIn(lan0.txt)
				IF Pos('inet', line) >< 0 THEN
					PARSE VAR line 'inet ' ip ' netmask ' mask ' broadcast '
				mask = RIGHT(mask, 8) /* Cleanup mask - chop x or 0x */
			END
	router = ''
			Do WHILE lines(route.txt)
				line = LineIn(route.txt)
					DO
						PARSE VAR line net gw garbage
						IF net='default' THEN
							router = gw
					END		
			END	

	IF ip >< 1 THEN	
		CALL DISPLAY
	ELSE
		CALL CLEANUP

RETURN

/* Begin subppp0 */
subppp0:

	ActiFace = 'PPP0'
	'ifconfig PPP0 > PPP0.txt'
	'netstat -r > route.txt'
	ip=1
			Do WHILE lines(PPP0.txt)
				line = LineIn(PPP0.txt)
				IF Pos('inet', line) >< 0 THEN
					PARSE VAR line 'inet ' ip ' netmask ' mask ' broadcast '
				mask = RIGHT(mask, 8) /* Cleanup mask, chop 0x or x */
			END
			
			Do WHILE lines(route.txt)
				line = LineIn(route.txt)
				IF Pos('default', line) >< 0 THEN
					PARSE VAR line 'default ' router ' ' garbage
					
			END			
	IF ip >< 1 THEN
		CALL DISPLAY
	ELSE
		CALL CLEANUP
		
RETURN

/* Begin display sub */
display:

	oct1 = Substr(mask, 1, 2)
	oct2 = Substr(mask, 3, 2)
	oct3 = Substr(mask, 5, 2)
	oct4 = Substr(mask, 7, 2)

	/* This line courtesy of Undernet's NewOrder - Thanks Jason! */

	decMask = x2D(oct1)||.||x2D(oct2)||.||x2D(oct3)||.||x2D(oct4) 


	/* Display Results */

	If didit >< 1   /* Did we print the initial output to the screen? */
		THEN
			DO
				SAY
				SAY
				SAY 'OS/2 IP Configuration'
			didit = 1
			END
		
	SAY
	SAY 'Interface: 'ActiFace
	SAY 
	SAY '		IP Address   .   .   .   .   :  'ip
	SAY '		Subnet Mask  .   .   .   .   :  'decmask
	SAY '		Default Gateway  .   .   .   :  'router
	SAY ''
	
/*	Cleanup! 	*/
/* Begin cleanup sub   */

cleanup:

ip = ''
mask = ''
router = ''
decmask = ''

	CALL LineOut PPP0.txt
	'del PPP0.txt'

	CALL LineOut lan0.txt
	'del lan0.txt'

	CALL LineOut route.txt
	'del route.txt'


RETURN
