/***************************************************************/
/*                                                             */
/*                              ULTIMATE.CMD                   */
/*                                                             */
/*      This Rexx file recreates the Welcome Folder, the       */
/*      Extended Services Program Icon, the Lan Services       */
/*      Program Icon ... back onto any system that previously  */
/*      had these features on the Desktop.                     */
/*                                                             */
/*      NOTE:  ULTIMATE.CMD merely calls the EXE files that    */
/*             are already located on the hard drive in the    */
/*             default path.  The default path would be the    */
/*             path in which OS/2 installed these files.       */
/*             These EXE files must be on the hard drive in    */
/*             the default path for this Utility to work       */
/*             properly.                                       */
/*                                                             */
/*                      Shawn McAlhany                         */
/*                     December, 06 1992                       */
/*                 Completed:                                  */
/***************************************************************/

call rxfuncadd 'sysloadfuncs', 'rexxutil', 'sysloadfuncs'
call sysloadfuncs                /* register system functions */
address cmd '@echo off'          /* echo is turned off */

'c:'
'cd\'
'md c:\ultimate'
'cd ultimate'
'xcopy a:'

rc=SysCreateObject('WPProgram','Ultimate','<WP_DESKTOP>','EXENAME=C:\ULTIMATE\ULTIMATE.CMD;PROGTYPE=PM;ICONFILE=A:\ULT.ICO')
