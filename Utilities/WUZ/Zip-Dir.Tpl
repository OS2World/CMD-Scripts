/* Move entire folder into a ZIP file of the same name */
/* (c) Copyright 1993 Scott Maxwell.*/

IconPath = 'E:\My_OS2\'
UsePKZip = 1

parse arg Name

OriginalName = Name

if Name = '' then do
Usage:
  say "USAGE: Zip-Dir directory-name"
  say "  Moves the contents of the specified directory into a ZIF file in"
  say "  the same directory.  The purpose of this command is to compress"
  say "  entire directories that you are not currently using.  To restore"
  say "  the directory, simply double-click on the ZIF file or drag-and-"
  say "  drop the ZIF file or the directory onto your WPS Unzip icon."
  '@pause'
  exit(0)
  end

Dir.1 = DIRECTORY()
Dir.2 = ''
if SubStr(Name,2,1) = ':' then do
  Dir.2 = DIRECTORY(Left(Name,2))
  Name = SubStr(Name,3)
  end

Name = Directory(Name)
if Name = '' then do
  say "Can't find a directory called" OriginalName
  signal Usage
end

fName = FILESPEC('Name', Name)

Say "Moving" Name "directory ->" Name"\"fName".Zif"
Say "Use 'WUZ" Name"' to restore or double click on" fName".Zif"

'@ren "'fName'.Zif" "'fName'.Zip" 2> nul > nul'
if UsePKZip = 1 then
   '@pkzip -p -r -m -u "'fName'" *'
else
   '@zip -r -m -u "'fName'" *'
'@ren "'fName'.zip" "'fName'.zif" > nul'
call RxFuncAdd 'SysSetObjectData','RexxUtil','SysSetObjectData'
Call SysSetObjectData Name,"ICONFILE="IconPath"FldZip.Ico"

if Dir.2 \= '' then call Directory(Dir.2)
call Directory(Dir.1)


exit(0)


Directory: procedure
  arg Name
  Name = Strip(Name,,'"')
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)

  n = 'DIRECTORY'(Name)
return n
