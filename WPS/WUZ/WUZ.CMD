/* unzip/arj/pac etc and open folder */
/* (c) Copyright 1994 Scott Maxwell. */

Drive    = 'E:'
DestPath = 'E:\Download\temp\'
IconPath = 'E:\Download'

KeepCommandLineWindow = 0
WaitForUnzip = 1
UnzipInCommandLineWindow = 1	/* KeepCommandLineWindow must be 1 for this */

arg Name ExtractHere
if Name = '' then SIGNAL ShowUsage
CurrentDir = Directory()
DeferToPostWuz = 0

if KeepCommandLineWindow = 1 & UnzipInCommandLineWindow = 1 & ExtractHere \= "HERE" then
  stub="preparing to extract"
else
  stub="extracting"
Say '0a'x"WPS Unzip -" stub Name
Say "(c) Copyright 1994 Scott Maxwell"'0a'x

Yes    = 1
No     = 0

Extractor.    = ''
CopyTo.       = No
Update.	      = ''
UpdateP.      = ''
Fresh.        = ''

Extractor.ARC = '@arc xo'
Fresh.ARC     = '@arc f'
Extractor.ARJ = '@unarj x'
Extractor.LZH = '@lh x /s /o'
Extractor.Z   = '@compress -d'
CopyTo.Z      = Yes
Extractor.TAR = '@tar xf'
CopyTo.TAR    = Yes
Extractor.EXE = '@'
CopyTo.EXE    = Yes
Extractor.COM = '@'
CopyTo.COM    = Yes
Extractor.CMD = '@'
CopyTo.CMD    = Yes
Extractor.BAT = '@'
CopyTo.BAT    = Yes
Extractor.ZIF = '@unzip -o -d'
Extractor.ZIP = '@unzip -o -d'
Update.ZIP    = '@zip -r -u'
UpdateP.ZIP   = '-x zclr.cmd zupdate.cmd zfresh.cmd'
Fresh.ZIP     = '@zip -r -f'

Extractor.ZOO = '@zoo x'
CopyTo.ZOO    = No

call GetDriveSpec Name
if Ext="" then do
  Name=Name'\'NameOnly'.Zif'
  call GetDriveSpec Name
end

if Length(CHARIN(Name,1,1)) \= 1 then do
   say Name 'not found.'"0a"x
   '@pause'
   exit(1)
   END
Call CHAROUT(Name)

if NameOnly="" | Ext="" then SIGNAL ShowUsage

if Extractor.Ext = '' then Ext="ZIP"

if ExtractHere = "HERE" then do
  if CopyTo.Ext = Yes then do
    '@copy' FullPath FullName'> nul'
    '@attrib -r -h -s' FullName '> nul'
    Param1 = FullName
  end
  else
    Param1 = FullPath
  Extractor.Ext Param1
  if CopyTo.Ext = Yes then do
    hold = FullPath
    call GetDriveSpec FullName
    if FullPath \= hold then
      Call SysFileDelete Param1
  end
  exit(0)
end

if Ext="ZIF" then do
  dir.1 = directory()
  dir.2 = directory(Left(FullPath,2))
  FullPath = Left(FullPath,Length(FullPath)-Length(FullName)-1)
  Call Directory FullPath
  Extractor.Ext FullName
  call RxFuncAdd 'SysSetObjectData','RexxUtil','SysSetObjectData'
  Call SysSetObjectData FullPath,"ICONFILE="IconPath"FldUnZip.Ico"
  Call Directory dir.2
  Call Directory dir.1
  exit(0)
end

Dest=DestPath||NameOnly

CALL RxFuncAdd 'SysMkDir','RexxUtil','SysMkDir'
CALL SysMkDir Dest

CALL RxFuncAdd 'SysFileDelete','RexxUtil','SysFileDelete'
Call SysFileDelete Dest'\zclr.cmd'

Call CHAROUT Dest'\zclr.cmd',"@cd .."'0d'x'0a'x
Call CHAROUT Dest'\zclr.cmd',"@detach Kill-Dir" Dest "> nul"'0d'x'0a'x
Call CHAROUT Dest'\zclr.cmd',"@if '%1'=='-x' exit"'0d'x'0a'x
Call CHAROUT Dest'\zclr.cmd'
'@attrib +h' Dest'\zclr.cmd > nul'

if Update.Ext \= '' then do
  Call SysFileDelete Dest'\zupdate.cmd'
  Call CHAROUT Dest'\zupdate.cmd','@zipstrip' FullPath'0d'x'0a'x
  Call CHAROUT Dest'\zupdate.cmd',Update.Ext FullPath '*' UpdateP.Ext
  Call CHAROUT Dest'\zupdate.cmd'
  '@attrib +h' Dest'\zupdate.cmd > nul'
end

if Fresh.Ext \= '' then do
  Call SysFileDelete Dest'\zfresh.cmd'
  Call CHAROUT Dest'\zfresh.cmd',Fresh.Ext FullPath '*'
  Call CHAROUT Dest'\zfresh.cmd'
  '@attrib +h' Dest'\zfresh.cmd > nul'
end

if WaitForUnzip = 0 then do
  if KeepCommandLineWindow = 0 | UnzipInCommandLineWindow = 1 then
    Call 'Open-Dir' Dest
  else
    if Check4OS2()=1 then
      '@start "'NameOnly'.'Ext'" /l /fg post-wuz.cmd' Dest DeferToPostWuz Left(Fresh.Ext,1) Left(Update.Ext,1)
    else
      '@start "'NameOnly'.'Ext'" /f post-wuz.cmd' Dest DeferToPostWuz Left(Fresh.Ext,1) Left(Update.Ext,1)
end


holdDir = DIRECTORY(Drive)
Call Directory(Dest)

if KeepCommandLineWindow = 0 | UnzipInCommandLineWindow = 0 then do
  if CopyTo.Ext = Yes then do
    '@copy' FullPath Dest '> nul'
    '@attrib -r -h -s' FullName '> nul'
    Param1 = FullName
    end
  else
     Param1 = FullPath
  Extractor.Ext Param1
  if CopyTo.Ext = Yes then
    Call SysFileDelete Param1
end

if WaitForUnzip = 1 | UnzipInCommandLineWindow = 1 then do
  if KeepCommandLineWindow = 0 then
    Call 'Open-Dir' Dest
  else do
    if UnzipInCommandLineWindow = 1 then
      DeferToPostWuz = FullPath
    if Check4OS2()=1 then
      '@start "'NameOnly'.'Ext'" /l /fg post-wuz.cmd' Dest DeferToPostWuz Left(Fresh.Ext,1) Left(Update.Ext,1)
    else
      '@start "'NameOnly'.'Ext'" /f post-wuz.cmd' Dest DeferToPostWuz Left(Fresh.Ext,1) Left(Update.Ext,1)
  end
end

Call Directory holdDir
Call Directory CurrentDir
exit(0)



GetDriveSpec: procedure expose FullPath FullName NameOnly Ext
arg Name
fDrive = FILESPEC('Drive',Name)
fPath  = FILESPEC('Path',Name)
fName  = FILESPEC('Name',Name)

Dir.1 = 'DIRECTORY'()
if fDrive = '' then
   fDrive = FILESPEC('Drive',Dir.1)

Dir.2 = DIRECTORY(fDrive)
if fPath  = '' then
   fPath  = FILESPEC('Path', Dir.2)

if Left(fPath,1) \= '\' then do
   Dir.3 = directory(fPath)
   fPath = FILESPEC('Path', Dir.3)
   Call Directory Dir.2
   end
Call Directory Dir.1

FullPath = fDrive||fPath||fName
FullName = fName

ExtPos = LASTPOS(".",fName)
if ExtPos=0 then do
   Ext = ''
   NameOnly = fName
   end
else do
   Ext = SUBSTR(fName,ExtPos+1)
   NameOnly = LEFT(fName,ExtPos-1)
   end
return


Directory: procedure
  arg Name
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)
  n = 'DIRECTORY'(Name)
  if Right(n,1) \= '\' then
    n = n'\'
  return n


Check4OS2: procedure
  '@set is4os2=%_4ver'
  return DATATYPE(VALUE(is4os2,,OS2ENVIRONMENT),'N')


ShowUsage:
  say "USAGE: wuz filename.[ARJ|LZH|TAR|Z|ZIP|ZOO] here"
  say "If you add 'here' after the filename, the archive will be expanded in place."'0a'x
  '@pause'
  exit
