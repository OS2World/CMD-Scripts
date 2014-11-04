/* eComStation Peer Services End */
/*             www.os2irc.org          */

IF RxFuncQuery('SockLoadFuncs') THEN
	DO
	 rc = RxFuncAdd("SockLoadFuncs","rxSock","SockLoadFuncs")
	 rc = SockLoadFuncs()
	END
IP = SockGetHostId()
SAY 'IP= 'IP

SELECT 
	WHEN IP = '255.255.255.255' THEN 
	DO
	 Say "No Network Interface Present"
	 EXIT    
	END
	WHEN IP = '0.0.0.0' THEN
	DO
	 Say "No Network Connection Present"
	 EXIT
	END

OTHERWISE 'START /C /MIN LOGOFF /L'
END
EXIT
