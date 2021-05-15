/* List shared netnames on a server */

call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
call LoadLsRxutFuncs

NETSERVER = 160
NETSHARE  = 190
SrvType   = -1  /* All servers */

parse upper arg SrvName DomainName dummy "/"pause
if SrvName = '' then call Syntax
if left( SrvName, 2 ) <> '\\' then do
	DomainName = SrvName
	SrvName    = ''
end
if left( pause, 1 ) = "P" then do
	pause = 1
	parse value SysTextScreenSize( ) with rows cols
end
else do
	pause = 0
end

myRc = NetEnumerate(NETSERVER, 'serverList', SrvName, SrvType, DomainName)
if myRc <> '0' then do
	say 'Got error from NetEnumerate() ' myRc
	exit 9
end

if serverList.0 = 0 then do
	say 'Domain controller was not found'
	exit 0
end

call SysCls
say
say 'Number of servers found: ' serverList.0

k = 0
do i=1 to serverList.0
	say
	say
	say serverList.i
	myRc = NetEnumerate(NETSHARE, 'shareInfo', '\\'serverList.i)
	if myRc <> '0' then do
		say 'Got error from NetEnumerate() ' myRc
		exit 9
	end
	if shareInfo.1 = 0 then do
		say 'Server does not share a resource'
		exit 0
	end
	say 'Number of shared netnames: ' shareInfo.0
	say
	do j=1 to shareInfo.0
		myRc = NetGetInfo(NETSHARE, 'shareInfoX', '\\'serverList.i, shareInfo.j)
/*
		myRc = NetGetInfo(NETSHARE, 'shareInfoX', SrvName, shareInfo.j)
*/
		if myRc <> '0' then do
			say 'Got error from NetGetInfo() ' myRc
			exit 9
		end
		say
		say '    Network name        :  ' shareInfoX.netname
		say '    Share type          :  ' shareInfoX.type
		say '    Comment             :  ' shareInfoX.remark
		say '    Local resource path :  ' shareInfoX.path
		if pause = 1 then call PauseIfNeeded
	end
end
if k > 0 then call PauseIfNeeded 'Exit'
EXIT 0


PauseIfNeeded:
	param = strip( translate( arg( 1 ) ) )
	parse value SysCurPos( ) with x y
	k = k + 1
	if x > rows - 8 | param = 'EXIT' then do
		call SysCurPos rows - 3, 0
		say 'Press any key . . .'
		call SysCurState 'OFF'
		call SysGetKey 'NOECHO'
		if param <> "EXIT" then do
			call SysCls
			say
			say 'Number of servers found: ' serverList.0
			say
			say
			say serverList.i
			say 'Number of shared netnames: ' shareInfo.0
			say
		end
		k = 0
	end
return


Syntax: procedure
	say
	say 'Usage: NETSHARE [ \\server_name ] [ domain_name ] [ /Pause ]'
	say
	exit 1
return
