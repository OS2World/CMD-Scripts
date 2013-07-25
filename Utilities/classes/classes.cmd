/* A little ReXX tool to list WPS classes */

rc = rxFuncAdd( 'sysLoadFuncs', 'rexxUtil', 'SysLoadFuncs' )

if rc = 0 then do
  call sysLoadFuncs
  say 'RexxUtil.dll functions registered'
end

say 'WPS Classes: '
call SysQueryClassList "list."
do i = 1 to list.0
  say 'Class' i 'is' list.i
end

exit 0
