/*
       SHOWCODE.CMD

       Written by: Albert Crosby <acrosby@comp.uark.edu>
       Date: Feb 11, 1994

       Purpose: Companion program to CmdLine.CMD, a full featured
                implentation of the OS/2 command line parser in REXX.
*/

say "Press the key desired: "
key=SysGetKey("NoEcho")
if key=d2c(0)|key=d2c(224) then
   do
   key2=SysGetKey("NoEcho")
   say "Key pressed was an extended key."
   say "Codes were: "c2d(key) c2d(key2)
   say "The variable to define this key for CmdLine would be:"
   say    "history.key."c2d(key2)
   end
else
   do
   say "The key pressed was not an extended key."
   say "Code was: "c2d(key)
   end
