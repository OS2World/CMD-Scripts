/* Rexx program to set object data */
/* (c) Copyright 1993 Scott Maxwell. */

arg args
split = LastPos(" ",args)
where = Left(args,split-1)
data = SubStr(args,split+1)
if Left(where,1) = '"' then
  where = SubStr(where,2,Length(where)-2)

if where = '' | data = '' then do
  say "Usage: WPSet object-name object-data"
  say "       Use this to set object data.  For instance, to open a folder use:"
  say "       WPSet c:\os2 open=default"
  exit(0)
end

call RxFuncAdd 'SysSetObjectData','RexxUtil','SysSetObjectData'
if SysSetObjectData(where,data) = 0 then do
  say 'Error creating object'
  exit(1)
  end

exit(0)

Directory: procedure
  arg Name
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)
  n = 'DIRECTORY'(Name)
  if Right(n,1) \= '\' then
    n = n'\'
  return n
