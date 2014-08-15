/* fgrexx.cmd, v1.0 1999-05-28, A.Koos */ 
/* Makes himself(more exactly:the parent cmd.exe) to be the foreground process. */
/* Uses the 'go.exe' by Carsten Wimmer.The go.exe must be in the same dir as    */
/* fgrexx.cmd.Tested on Warp 4 in OREXX. Contact: akoos@mvm.hu                  */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

Arg sleep

if datatype(sleep,'W')=0 then sleep=10;

parse source . . progpath
gopath=translate(filespec('drive',progpath)||filespec('path',progpath)||'go.exe');

call SysFileTree gopath,files.,'F'
if files.0=0 then do
        say 'GO.EXE is not found in the startup directory!'
        '@pause'
        Exit;
end;


say 'Waiting.Now,you can make other program running in the foreground.';
say 'Switching in 'sleep' seconds.'
call SysSleep sleep

 rtcd= FGSwitching()

if rtcd then say 'Hello,I am here!';

EXIT;

/*----------------------------------------------------*/
/* You can copy this procedure source into your code  */
/* probably without any modification.                 */
FGSwitching: procedure

nul='>nul 2>&1'
parse source . . progpath
gopath=translate(filespec('drive',progpath)||filespec('path',progpath)||'go.exe');

call SysFileTree gopath,files.,'F'
if files.0=0 then return .false; /* 'GO.EXE is not found in the startup directory!'*/

'@'||gopath||' -lpl|rxqueue'

do while queued()>0
   str=translate(linein('QUEUE:'));
   if  pos(gopath,str)>0 then do
         parse var str PID PPID .
   end;
end /* do */
if var('PPID')=0 then return .false;

'@'||gopath||' -j '||PPID nul

return .true;
/*-------------------------------------*/

