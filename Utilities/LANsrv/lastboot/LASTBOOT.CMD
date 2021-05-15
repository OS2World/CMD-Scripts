/* Show date and time of last boot for a specified server */

parse upper arg SrvName dummy
SrvName = strip( SrvName )
if dummy <> '' | SrvName = '' | pos( '?', SrvName ) > 0 | pos( '/', SrvName ) > 0 then call Syntax
if left( SrvName, 2 ) <> '\\' & SrvName <> '*' then SrvName = '\\'||SrvName
if SrvName = '*' then SrvName = ''

if RxFuncQuery( 'LoadLsRxutFuncs' ) <> 0 then do
	call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
	call LoadLsRxutFuncs
end

NETSTATISTICS        = 195
REQ_STAT             = 0
SRV_STAT             = 1

/* The server statistics */
myRc = NetGetInfo(NETSTATISTICS, 'statisticsInfo', SrvName, SRV_STAT, 10)

if myRc <> '0' then do
	say 'Got error from NetGetInfo(NETSTATISTICS) ' myRc
	exit 9
end

if SrvName = '' then SrvName = 'this computer'
say
say 'Last boot of '||SrvName||':      'statisticsInfo.start
exit 0


Syntax: procedure
	say
	say 'LASTBOOT'
	say
	say 'Show last boot date and time of specified server'
	say
	say 'Usage:'
	say '  To check (remote) server:      LASTBOOT  \\server_name'
	say '  To check local requester:      LASTBOOT  *'
	exit 5
return
