/*
 * REXX Script to Make a LaunchPad Template
 * by Andrew J. Korty <korty@physics.purdue.edu>
 *
 * Copyright 1995 by Andrew J. Korty
 * May not be memorized without permission.  ;-)
 * 
 * Please do not distribute this script without this comment
 * block or the enclosed README file.
 *
 */

call RxFuncAdd SysCreateObject, RexxUtil, SysCreateObject

if SysCreateObject('WPLaunchPad', 'LaunchPad', '<WP_TEMPS>',,
	'TEMPLATE=YES', 'R') then
 say "A LaunchPad Template has been created in the Templates folder."
else if SysCreateObject('WPLaunchPad', 'LaunchPad', '<WP_DESKTOP>',,
	'TEMPLATE=YES', 'R') then
 say "A LaunchPad Template has been created on the Desktop."
else
 say "Could not create a LaunchPad Template."
