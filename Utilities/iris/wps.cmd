/* Quick WPS-Object-Creator         */ 
/* written by Taki, 2001            */
/* This software is PUBLIC DOMAIN   */
pwd=DIRECTORY()                                                                               
CALL RxFuncAdd "SYSLoadFuncs","RexxUtil","SYSLoadFuncs"                         
CALL SYSLoadFuncs 
rc=SysCreateObject('WPProgram','Iris','<WP_DESKTOP>',',PROGTYPE=WINDOWABLEVIO;EXENAME='pwd'\iris.cmd;STARTUPDIR='pwd';ICONFILE='pwd'\iris.ico;OBJECTID='IRIS_MADE_BY_TAKI'')
EXIT                                                 
