/* Rexx program to set object data */
/* (c) Copyright 1993 Scott Maxwell. */

parse arg args
if args = '' then signal showUsage
if Left(args,1) = '"' then do
  parse var args '"' where '"' data
  data = Strip( data )
end
else
  parse var args where data


if where = '' | data = '' then do
showUsage:
  say "Usage: WPSet object-name object-data"
  say "       Use this to set object data.  For instance, to open a folder use:"
  say "       WPSet c:\os2 open=default"
  exit(0)
end

call RxFuncAdd 'SysSetObjectData','RexxUtil','SysSetObjectData'
if SysSetObjectData(where,data) = 0 then do
  say 'Error setting object data'
  exit(1)
  end

exit(0)
