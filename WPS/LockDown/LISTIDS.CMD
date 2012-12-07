/* From REXX Tips & Tricks v.2.5 (INF file)
   by Bernd Schemmer
*/

   call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
   call SysLoadFuncs

/* get the list of the known object IDs           */
   call SysIni "USER", "PM_Workplace:Location", "All:", "ids."
 
/* and print them to the screen                   */
   say ids.0 || " known object IDs found."
   do i = 1 to ids.0
     say ids.i
   end /* do i = 1 to ids.0 */
 exit

return

