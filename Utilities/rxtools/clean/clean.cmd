/* Cleaner with REXX bye cygnus, 2:463/62.32 */
call RxFuncAdd 'SysLoadFuncs', 'Rexxutil', 'SysLoadFuncs'
call SysLoadFuncs
call SysCls

signal on halt name break

if SysIni('User','Cleaner','Target') \= 'ERROR:' then 
do
 target = SysIni('User','Cleaner','Target')
 timer =  SysIni('User','Cleaner','Timer')/1000
end
else
 target = 'Nothing to delete!'
say 'RxCleaner. Processing ...' target
say

if SysIni('User','Cleaner','Autoclean') = 1 then
do forever
 '@DEL' target '/n 2>nul' 
 call SysSleep timer
end
exit

break:
'@cls'
say 'Execution terminated!'
