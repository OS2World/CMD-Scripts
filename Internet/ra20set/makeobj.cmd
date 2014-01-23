/* */
call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
call RxFuncAdd 'SysSetObjectData', 'RexxUtil', 'SysSetObjectData'
parse arg exename

rc = SysCreateObject("WPProgram","Real Audio Player","<WP_DESKTOP>","OBJECTID=<RAPLAYER>")
rc = SysSetObjectData("<RAPLAYER>","EXENAME="exename)
