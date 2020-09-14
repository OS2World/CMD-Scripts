/* DIRC.CMD  (c) 2020 Dariusz Piatkowski                            */
/*                                                                  */
/* This implements the OS/2 DIR command using the unix stat command */
/* and specifically listing the CREATE DATE/TIME stamp              */
/*                                                                  */
/* Based on OS2 World forum conversation listed below:              */
/* https://www.os2world.com/forum/index.php/topic,2568.0.html       */


call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

arg path

/* check to see what CLI arguments are passed */
if path = "" then 
   path = '*'
else if path = "-?" then
   call helpmsg

/* if the last character in the PATH argument is '\' then consider */
/* this to be a request to list the contents of the directory */
/* therefore the same behaviour as native OS/2 DIR command */
if right(path,1)="\" then
   path=path||'*'

/* define the STAT output format */
parms = '"%%.16w %%20F %%10s %%n"'

'@stat -c' parms path
exit

helpmsg:
   say
   say " DIRC.CMD - show directory listing using CREATE date/time stamp!"
   say
   say " Usage:   DIRC directory"
   say 
   say " Example: DIRC G:\TMP"
   say
exit
