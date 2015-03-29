/* Open een object: variant 2 */

call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs

parse arg params
parse var params object 'VIEW='view

if view='' then view='DEFAULT'

say 'Open: 'object
say 'View: 'view
call SysOpenObject object, view, 'TRUE'

