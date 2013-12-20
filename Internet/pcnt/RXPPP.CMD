/* Scaffold for PPP termination handling (setting red light) */

   Parse Arg stopstate appl cmdpath rest

      Call rxfuncadd sysloadfuncs, rexxutil, sysloadfuncs
      Call sysloadfuncs

      Signal ON Error   Name SETRED
/*    Signal ON Halt    Name SETRED
      Signal ON Failure Name SETRED
*/
/* Invoke PPP with passed parms and no console displayed */

     "@ppp" rest
Say result
      Exit

/* On completion, set light back to red. <control-C> has been hit. */
/* Also restore resolv.org if it was saved prior */

     SETRED:

      Call SysCreateObject "WPProgram", appl,"<WP_DESKTOP>","OBJECTID=<"Substr(appl,1,8,'_')">;EXENAME="cmdpath"\pppcnt.cmd;PARAMETERS=" appl ";ICONFILE="cmdpath"\"stopstate,"U"

     '@erase resolv'              /* if was a temp resolv we created */
     '@rename resolv.org resolv'  /* if org did prev exist */

