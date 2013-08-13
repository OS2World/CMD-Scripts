/* Cleaner setup */
call RxFuncAdd 'SysLoadFuncs', 'Rexxutil', 'SysLoadFuncs'
call SysLoadFuncs

signal on halt name break

call SysCls

arg del_
if del_ = '/D' then
do
 call SysIni 'User', 'Cleaner', 'DELETE:'
 say 'Cleaner entries deleted'
 exit
end

if SysIni('User','Cleaner','Target') \= 'ERROR:' then 
do
 say 'Cleaner setup'
 say
 say 'Target -' SysIni('User','Cleaner','Target')
 say 'Timeout is' SysIni('User','Cleaner','Timer')/1000 'seconds'
 if SysIni('User','Cleaner','Autoclean') = 1 
 then
  say 'Autoclean is ON'
 else say 'Autoclean is OFF'
end
else say 'Cleaner not installed'

say
call CharOut ,'Do you wish to set parameters? [Y/N] '
pull answer
If answer = 'Y' then
do
 call CHarOut ,'Input target [c:\temp\*.*]: '
 pull target
 if target \= '' then
  SysIni('User','Cleaner','Target',target)
 call CharOut , 'Input timeout from 3 up to 12 seconds: '
 pull timer
 if timer < 3 | timer > 12 | timer = '' then timer = 9
 SysIni('User','Cleaner','Timer',timer*1000)
 call CharOut , 'Do you wish to use autoclean? [Y/N] '
 pull autoclean
 if autoclean = 'Y' then 
  SysIni('User','Cleaner','Autoclean',1)
 else
  SysIni('User','Cleaner','Autoclean',0)
end
exit

break:
'@cls'
say 'Setup not completed, you have to restart it again!'
