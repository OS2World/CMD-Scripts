/* Remove all files from directory and remove directory */
/* (c) Copyright 1993 Scott Maxwell.			*/

parse arg Name

if (Left(Name,1) = '/') | (Left(Name,1) = '-') then
  parse var Name Options Name
else
  Options = ''

Name = Strip(Name,,'"')
Options = Translate(Options)

if (Options \= '') & (Options \= '/X') & (Options \= '-X') then signal ShowUsage
if Name = '' then signal ShowUsage

dir.1 = Directory()
if SubStr(Name,2,1) = ':' then do
  if (length(Name) = 2) | ((length(Name) = 3) & (Right(Name,1) = '\')) then do
    say "What?! I refuse to delete the root of any drive."
    exit(1)
  end
  if SubStr(Name,3,1) = '.' then do
    say "I refuse to kill relatives! It's too dangerous."
    exit(1)
  end
  dir.2 = Directory(Left(Name,2))
  if dir.2 = '\' then do
    say "No drive" Left(Name,2)
    exit(1)
  end
end
else do
  if Left(Name,1) = '.' then do
    say "I refuse to kill relatives! It's too dangerous."
    exit(1)
  end
  if Name = '\' then do
    say "What?! I refuse to delete the root of any drive."
    exit(1)
  end
  dir.2 = dir.1
end

fName = directory(Name)
if fName = '\' then do
  say Name": directory not found"
  exit(1)
end

Call Directory dir.2
Call Directory dir.1

Name = fName


CALL RxFuncAdd 'SysRmDir','RexxUtil','SysRmDir'
if Check4OS2()=1 THEN
  '@del /qsxyz "'Name'*" 2> nul'
else do
  CALL RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'
  CALL RxFuncAdd 'SysFileDelete','RexxUtil','SysFileDelete'
  Call SysFileTree Name'*.*','dir','FS','*****','-*---'

  do i=1 to dir.0
    parse VAR dir.i . . . . fname
    Call 'SysFileDelete' STRIP(fname)
  end

  Call SysFileTree Name,'dir','SD','*****','-*---'
  do i=1 to dir.0
    parse VAR dir.i . . . . fname
    Call 'SysRmDir' STRIP(fname)
  end
  Call SysRmDir Left(Name,LENGTH(Name)-1)
end

if Stream( Name, 'C', 'QUERY EXISTS' ) \= '' then do
  '@attrib -h' Name'zclr.cmd > nul 2> nul'
  '@del' Name'zclr.cmd > nul 2> nul'
  if SysRmDir(Left(Name,LENGTH(Name)-1)) \= 0 then do
    say "Can't remove" Name
    exit
  end
end

if Right(Options,1) = 'X' then
   '@exit'
exit(0)


Check4OS2: procedure
  '@set is4os2=%_4ver'
  return DATATYPE(VALUE(is4os2,,OS2ENVIRONMENT),'N')

ShowUsage:
  say "USAGE: Kill-Dir [-x] directory-name"
  say "  Deletes the specified directory and all of its contents"
  say "  If -x option is specified, the OS/2 window is closed"
  exit

Directory: procedure
  arg Name
  Name = Strip(Name,,'"')
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)
  n = 'DIRECTORY'(Name)
  if Right(n,1) \= '\' then
    n = n'\'
return n
