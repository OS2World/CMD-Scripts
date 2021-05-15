/* Get wksta information */

call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
call LoadLsRxutFuncs

NETWKSTA = 350
parse upper arg SrvName dummy
if dummy <> '' then call Syntax
SrvName = strip( SrvName )
if pos( '?', SrvName ) > 0 then call Syntax
if pos( '*', SrvName ) > 0 then SrvName = ''
if left( SrvName, 2 ) <> '\\' & SrvName <> '' then SrvName = '\\'||SrvName

myRc = NetGetInfo(NETWKSTA, 'wkstaInfo', SrvName)

if myRc <> '0' then do
	say 'Got error from NetGetInfo(NETWKSTA) ' myRc
	exit 9
end

say
say 'Computer Name        : ' wkstaInfo.computername
say 'User Id logged on    : ' wkstaInfo.username
say 'LAN Group            : ' wkstaInfo.langroup
say 'Major version number : ' wkstaInfo.ver_major
say 'Minor version number : ' wkstaInfo.ver_minor
say 'Logon domain         : ' wkstaInfo.logon_domain
say 'Other domains        : ' wkstaInfo.oth_domains

exit 0


Syntax: procedure
	say
	say "WhoAmI"
	say
	say "Usage:  WHOAMI  [ { \\server | * } ]"
	exit 1
return
