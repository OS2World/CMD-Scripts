/* Open een Object */

call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs

/* welk object */
parse arg object

call SysSetObjectData object, 'OPEN=ICON'

