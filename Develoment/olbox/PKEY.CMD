/* pkey.cmd */
 Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'; 
 Call SysLoadFuncs; 

keyF1= key=d2c(0)||d2c(59);

say 'Press a key!'
key=SysGetKey('NOECHO');
if key=d2c(0) | key=d2c(224) then key=key||SysGetKey('NOECHO');

if length(key)=1 then say c2d(key)' key=d2c('c2d(key)')'
 else say c2d( left(key,1))' 'c2d( right(key,1))' key=d2c('c2d(left(key,1))')||d2c('c2d(right(key,1))')';

/* If F1 pressed. */
if  keyF1=key then say 'Yes, F1!'

exit;

