/* Open folder on desktop from command-line */
/* (c) Copyright 1994 Scott Maxwell.	    */

/* Note: If you installed this with WUZ, this file */
/*       may have also been created as OD.CMD      */
/*       In that case, you can easily open folders */
/*       on your desktop by typing something like  */
/*       'od c:\os2'				   */


arg Name Options

if (Left(Name,1) = '/') | (Left(Name,1) = '-') then do
  swap = Name
  Name = Options
  Options = swap
  end

if Options \= '' then
  if (Options \= '/C') & (Options \= '-C') then do
    say "USAGE: Open-Dir [-c] [directory-name]"
    say "  Opens the specified directory as a folder on the desktop"
    say "  If no directory-name is specified, the current directory is opened"
    say "  If -c option is specified, the current directory is changed"
    exit(0)
    end

Dir.1 = DIRECTORY()
Dir.2 = ''
if Name \= '' then
  if SubStr(Name,2,1) = ':' then do
    Dir.2 = DIRECTORY(Left(Name,2))
    Name = SubStr(Name,3)
    end

Name = Directory(Name)

CALL RxFuncAdd 'SysSetObjectData','RexxUtil','SysSetObjectData'
CALL SysSetObjectData Name,"OPEN=ICON"
if Options = '' then do
  if Dir.2 \= '' then call Directory(Dir.2)
  call Directory(Dir.1)
  end

exit(0)


Directory: procedure
  arg Name
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)

  n = 'DIRECTORY'(Name)
  return n
