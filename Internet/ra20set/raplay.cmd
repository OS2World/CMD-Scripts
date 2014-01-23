/* */
call RxFuncAdd 'SysSetObjectData', 'RexxUtil', 'SysSetObjectData'
parse arg fullfilename

drive = filespec("drive",fullfilename)
path = filespec("path",fullfilename)
filename = filespec("name",fullfilename)
periodpos=pos(".",filename)
exten=right(filename,length(filename)+1-periodpos)
'echo off'
'cls'
drive
'cd' delstr(path,length(path))
'del -random-.* > nul'
'ren ' filename ' -random-' || exten
rc = SysSetObjectData("<RAPLAYER>","PARAMETERS="|| drive || path || "-random-"|| exten)
rc = SysSetObjectData("<RAPLAYER>","OPEN=DEFAULT")
