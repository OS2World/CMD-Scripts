/* New-Lnch.cmd            Modify, Eliminate, or Restore the LaunchPad */
/* copyright Joe Gilvary, 1994 */

ARG action
call rxfuncadd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call sysloadfuncs
SELECT
   when (action='M' | action='E') then DO
      Call Aistriu
      exit
   end
   when action='R' then DO
      Call Deisiu
      exit
   end
   when action='H' then DO
      "Type new-lnch.txt | more"
       exit
   end
otherwise DO
       SAY
       SAY " This REXX program will (M)odify, (E)liminate, or (R)estore the LaunchPad,"
       SAY " but you must input one of the letters 'M, E, or R' at the command line."
       SAY " For example, to restore the LaunchPad as it existed when you installed Warp,"
       SAY " type 'NEW-LNCH R' and press enter. You can use upper or lower case letters."
       SAY " You don't need to (R)estore an original LaunchPad to install the modified"
       SAY " version. You can use (M)odify or (R)estore at any time. If you want to be rid"
       SAY " of the LaunchPad, or want to use the modified version, remove 'LAUNCHPAD'"
       SAY " from the 'AUTOSTART' line of your config.sys file."
       SAY
      exit
     end
end

/* The real work */
/* Aistri£ will optionally remove the LaunchPad, or remove the original and create a new */
/* LaunchPad that doesn't know about the double click of MB1 on the Desktop.               */

/* If you want to have only a modified LaunchPad, remove the "LAUNCHPAD" from the  */
/* "AUTOSTART" line in your config.sys. OS/2 will recreate the original LaunchPad itself */
/* at your next reboot, and then you'll have TWO LaunchPads, one of each flavor.            */

Aistriu:
call SysDestroyObject '<WP_LAUNCHPAD>'
call SysDestroyObject '<WP_LaunchPad>'
IF action='E' THEN exit
classresult=SysRegisterObjectClass('WPLaunchPad', PMWP)
objectresult=SysCreateObject('WPLaunchPad' ,  'LaunchPad' ,  '<WP_DESKTOP>', 'OBJECTID=<WP_LaunchPad>')
exit

/* Deisi£ will restore the LaunchPad with its installation time default settings. This means   */
/* using 'new-lnch r' will install a LaunchPad on your desktop which pops up when you      */
/* double-click MB1 on the Desktop, just as it did immediately after your Warp install.         */
/* You can accomplish the same thing by placing "LAUNCHPAD" in your "AUTOSTART" */
/* line of the config.sys file. That will NOT remove the modified LaunchPad, however.        */

Deisiu:
call SysDestroyObject '<WP_LaunchPad>'
objectresult=SysCreateObject('WPLaunchPad' ,  'LaunchPad' ,  '<WP_DESKTOP>', 'OBJECTID=<WP_LAUNCHPAD>')
exit
