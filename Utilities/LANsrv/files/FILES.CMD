/* List open files on server */

call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
call LoadLsRxutFuncs

NETFILE  = 60
BasePath = 'D:\'

parse arg SrvName UserId dummy
if dummy <> '' then call Syntax
if UserId = '' then call Syntax
if pos( '?', SrvName ) > 0 then call Syntax

myRc = NetEnumerate(NETFILE, 'fileInfo', SrvName, BasePath, UserId)
if myRc <> '0' then do
	say 'Got error from NetEnumerate() ' myRc
	exit 9
end

if fileInfo.count = 0 then do
	say 'No files open on the server'
	call DropLsRxutFuncs
end

say 'Number of open file entries: ' fileInfo.count
say

do i=1 to fileInfo.count
	say fileInfo.i.id fileInfo.i.permissions fileInfo.i.num_locks fileInfo.i.pathname
end
exit 0


Syntax: procedure
	say
	say 'Files'
	say "Show all open files on server's D: drive for specified user ID"
	say
	say 'Usage:  FILES  \\server_name  user_id'
	exit 1
return
