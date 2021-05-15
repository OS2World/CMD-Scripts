/* List open files on server */

call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
call LoadLsRxutFuncs

NETFILE  = 60

parse arg SrvName BasePath dummy
if dummy   <> '' then call Syntax
if BasePath = '' then call Syntax
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
	say fileInfo.i.username fileInfo.i.id fileInfo.i.permissions fileInfo.i.num_locks fileInfo.i.pathname
end

exit 0


Syntax: procedure
	say
	say 'File'
	say 'Show who has opened specified file'
	say
	say 'Usage:  FILE  \\server_name  full_path_and_file_name'
	exit 1
return
