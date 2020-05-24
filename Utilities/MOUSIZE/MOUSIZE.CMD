/* MOUSIZE.CMD Set VGA pointers to small             */
/* REXX Command program; must be run from OS/2       */
/* prompt.  Reboot after running.                    */
/*                                                   */
/*       This program will decrease the size of the  */
/*       cursor.  To force a large size pointer,     */
/*       replace the "2" in the program with a "1".  */
/*       To let the system select the size of the    */
/*       pointer, replace the "2" in the program     */
/*       with a "0".                                 */
/*                                                   */
call RxFuncAdd "SysIni", "RexxUtil", "SysIni"
call SysIni "USER", "PM_IBMVGA", "CURSOR_SIZE", "2",
say Result
exit