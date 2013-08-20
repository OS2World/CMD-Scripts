/* Quick WPS-Object-Creator         */ 
/* written by Taki, 2001            */
/* This software is PUBLIC DOMAIN   */
pwd=DIRECTORY()                                                                               
CALL RxFuncAdd "SYSLoadFuncs","RexxUtil","SYSLoadFuncs"                         
CALL SYSLoadFuncs 
rc=SysCreateObject('WPProgram','Moritz','<WP_DESKTOP>',',PROGTYPE=WINDOWABLEVIO;EXENAME='pwd'\moritz.cmd;STARTUPDIR='pwd';NOAUTOCLOSE=YES;ICONFILE='pwd'\moritz.ico;OBJECTID='MORITZ_MADE_BY_TAKI'')
EXIT                                                 
