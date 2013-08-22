/* SYSFONT - Program to Change OS2's default system font */
/* Ripped from the README file from OS2 2.1 */

call RxFuncAdd "SysIni", "RexxUtil", "SysIni"
AppName = "PM_SystemFonts"
KeyName = "DefaultFont"

'cls'
say 'System Font Modifier Utility 1.0'
say 'Allows changing of the default "10.System Proportional"'
say ''
say 'Font Names must be typed *exactly* as in the Font Palette.'
say 'Do not make the font too big or you will experience text clipping.'
say ''
call charout , 'Enter the font name: '
pull font
say ''
call charout , 'Enter the font size: '
pull size
say ''

FontName=size||'.'||font

call SysIni "USER", AppName, KeyName, FontName||"0"x
say 'Done'
