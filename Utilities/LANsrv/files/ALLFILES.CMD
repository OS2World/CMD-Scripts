/* List open files on server */

call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
call LoadLsRxutFuncs

NETFILE  = 60
BasePath = 'D:\'

parse arg SrvName dummy
if dummy  <> '' then call Syntax
if SrvName = '' then call Syntax
if pos( '?', SrvName ) > 0 then call Syntax

myRc = NetEnumerate(NETFILE, 'fileInfo', SrvName, BasePath)
if myRc <> '0' then do
	say 'Got error from NetEnumerate() ' myRc
	exit 9
end

if fileInfo.count = 0 then do
	say 'No files open on the server'
	exit 0
end

say 'Number of open file entries: ' fileInfo.count
say

do i=1 to fileInfo.count
	say fileInfo.i.id fileInfo.i.permissions fileInfo.i.num_locks fileInfo.i.pathname fileInfo.i.username
end

exit 0


Syntax: procedure
	say
	say 'AllFiles'
	say 'Show all open files on specified server'
	say
	say 'Usage:  ALLFILES  \\server_name'
	exit 1
return
