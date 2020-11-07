/*    */	
/*   REXXSTRT  is a sample STARTUP.CMD that does different
things depending on the way the system was started. The file
STARTUP.STT contains the startup flags. The REXX command
CHGSTT alters that flag.

In the lines LOAD etc, notice that the entire string is enclosed in 	
single quotes. This is to keep REXX from trying to interpret
the non-national language characters ( /,:,\,etc) as commands
*/	

DOBACKUP = 'MONDAY'
STATUSFILE = 'STARTUP.STT'


/* set up my COMM port  */
  say 'Setting the communications port parameters '
'@mode com1:9600,n,8,1,octs=off,odsr=off,idsr=off'

/* always load the PAGEPRINTER Program */

say 'Loading the Pageprinter emulator'
'@load "PPMON"  /PM c:\pp\ppmon.exe C: LPT1'

/*  now the conditional processing starts  */

/* If it's Monday, do the backup  */
if date(WEEKDAY) = DOBACKUP
   then  do
             say 'Backup program will be initiated "
/*            '@load "PS2BACK" /PM D:\PS2TAPE\OS2TAPE.EXE'   */		
             end
   else say 'No Backups today , 'date(weekday)
if linein(STATUSFILE) = 'NORMAL'
then do
        /* load the monitor program  */
        say 'Normal environment loaded'
        say 'Monitor Program'
        '@load "Monitor" /PM D:\os2util\monitor.exe' 			
        /* load random rectangles  */
        say 'Rectangle program'
        '@load "Random" /PM D:\os2util\randrect.exe'
        end
   else do
        /* load trace facility  */
       say 'Test environment loaded '
       say 'WWDWATCH loading'
/*        '@load "WWDWATCH" /PM D:\OS2UTIL\WWDWATCH.EXE' */		
         end

say 'STARTUP complete'
exit
