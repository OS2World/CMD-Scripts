/* Maak een Drives Object */

call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs

call SysCreateObject 'WPDrives', '<WP_CONNECTIONSFOLDER>', 'Drives', 'ALWAYSSORT=YES;NOMOVE=YES;NODELETE=YES;DEFAULTVIEW=ICON;OBJECTID=<WP_DRIVES>;', 'F'
