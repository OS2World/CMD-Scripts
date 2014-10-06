/* unzip/arj/pac etc and open folder */
/* (c) Copyright 1994 Scott Maxwell. */

Drive    = 'E:'
DestPath = 'E:\DOWNLOAD\TEMP\'
IconPath = 'E:\MY_OS2\'

KeepCommandLineWindow = 1
WaitForUnzip = 1
UnzipInCommandLineWindow = 1	/* KeepCommandLineWindow must be 1 for this */
UsePKZip = 1

parse arg args

if args = '' then signal showUsage
if Left(args,1) = '"' then
  parse var args '"' Name '"' ExtractHere
else
  parse var args Name ExtractHere

ExtractHere = Strip( TransLate( ExtractHere ) )

CALL RxFuncAdd 'SysFileDelete','RexxUtil','SysFileDelete'
CALL RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'

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
if UsePKZip = 1 then do
    Extractor.ZIF = '@pkunzip -d -o -n'
    Extractor.ZIP = '@pkunzip -d -o'
    Update.ZIP    = '@pkzip -p -r -u -whs'
    UpdateP.ZIP   = '-xzclr.cmd -xzupdate.cmd -xzfresh.cmd'
    Fresh.ZIP     = '@pkzip -p -r -f -whs'
end
else do
    Extractor.ZIF = '@unzip -o -u'
    Extractor.ZIP = '@unzip -o'
    Update.ZIP    = '@zip -r -u'
    UpdateP.ZIP   = '-x zclr.cmd zupdate.cmd zfresh.cmd'
    Fresh.ZIP     = '@zip -r -f'
end
Extractor.ZOO = '@zoo x'
CopyTo.ZOO    = No

call GetDriveSpec Name
Ext = Translate(Ext)
if Ext="" then do
  Name=Name'\'NameOnly'.Zif'
  call GetDriveSpec Name
end

if Stream(Name, 'C', 'QUERY EXISTS') = '' then do
   say Name 'not found.'"0a"x
   '@pause'
   exit(1)
   END

if NameOnly="" | Ext="" then SIGNAL ShowUsage

if Extractor.Ext = '' then Ext="ZIP"

if ExtractHere = "HERE" then do
  Call ExtractArchive
  exit(0)
end

call RxFuncAdd 'SysSetObjectData','RexxUtil','SysSetObjectData'

if Translate(Ext)="ZIF" then do
  dir.1 = directory()
  dir.2 = directory(Left(FullPath,2))
  FullPath = Left(FullPath,Length(FullPath)-Length(FullName)-1)
  Call Directory FullPath
  Extractor.Ext '"'FullName'"'
  Call SysSetObjectData FullPath,"ICONFILE="IconPath"FldUnZip.Ico"
  Call Directory dir.2
  Call Directory dir.1
  exit(0)
end

Dest=DestPath||NameOnly

CALL RxFuncAdd 'SysMkDir','RexxUtil','SysMkDir'
CALL SysMkDir Dest

holdDir = DIRECTORY(Drive)
Call directory Dest

Call SysFileDelete 'zclr.cmd'

if KeepCommandLineWindow = 1 then do
  Call CHAROUT 'zclr.cmd',"@cd .."'0d0a'x
  if Check4OS2()=1 then do
    Call CHAROUT 'zclr.cmd',"@detach Kill-Dir """Dest""" > nul"'0d0a'x
    Call CHAROUT 'zclr.cmd',"@if '%1'=='-x' exit"'0d0a'x
    Call CHAROUT 'zclr.cmd'
    '@attrib +h zclr.cmd > nul'
  end
  else do
    Call CHAROUT 'zclr.cmd','@detach Kill-Dir "'Dest'"'"0d0a"x
    Call CHAROUT 'zclr.cmd',"@if '%1'=='-x' exit"'0d0a'x
    Call CHAROUT 'zclr.cmd'
  end
end

if Update.Ext \= '' then do
  Call SysFileDelete 'zupdate.cmd'
  Call CHAROUT 'zupdate.cmd','@call zipstrip "'FullPath'"'"0d0a"x
  Call CHAROUT 'zupdate.cmd',Update.Ext' "'FullPath'" *' UpdateP.Ext
  Call CHAROUT 'zupdate.cmd'
  if Check4OS2()=1 then
    '@attrib +h zupdate.cmd > nul'
  Call SysSetObjectData Dest,"menuitem=Update,"Dest"\zupdate.cmd"
end

if Fresh.Ext \= '' then do
  Call SysFileDelete 'zfresh.cmd'
  Call CHAROUT 'zfresh.cmd',Fresh.Ext' "'FullPath'" *'
  Call CHAROUT 'zfresh.cmd'
  if Check4OS2()=1 then
    '@attrib +h zfresh.cmd > nul'
  Call SysSetObjectData Dest,"menuitem=Refresh,"Dest"\zfresh.cmd"
end

if WaitForUnzip = 0 then do
  if KeepCommandLineWindow = 0 | UnzipInCommandLineWindow = 1 then
    Call 'Open-Dir'
  else
    if Check4OS2()=1 then
      '@start "'NameOnly'.'Ext'" /l /fg post-wuz.cmd "'DeferToPostWuz'"' Left(Fresh.Ext,1) Left(Update.Ext,1)
    else
      '@start "'NameOnly'.'Ext'" /f post-wuz.cmd "'DeferToPostWuz'"' Left(Fresh.Ext,1) Left(Update.Ext,1)
end

if KeepCommandLineWindow = 0 | UnzipInCommandLineWindow = 0 then
  Call ExtractArchive

if WaitForUnzip = 1 | UnzipInCommandLineWindow = 1 then do
  if KeepCommandLineWindow = 0 then
    Call 'Open-Dir'
  else do
    if UnzipInCommandLineWindow = 1 then
      DeferToPostWuz = FullPath
    if Check4OS2()=1 then
      '@start "'NameOnly'.'Ext'" /l /fg post-wuz.cmd "'DeferToPostWuz'"' Left(Fresh.Ext,1) Left(Update.Ext,1)
    else
      '@start "'NameOnly'.'Ext'" /f post-wuz.cmd "'DeferToPostWuz'"' Left(Fresh.Ext,1) Left(Update.Ext,1)
  end
end

Call Directory holdDir
Call Directory CurrentDir
exit(0)


ExtractArchive:
  if CopyTo.Ext = Yes then do
    '@copy "'FullPath'" "'FullName'" > nul'
    '@attrib -r -h -s "'FullName'" > nul'
    Param1 = FullName
  end
  else
    Param1 = FullPath
  Extractor.Ext '"'Param1'"'
  if CopyTo.Ext = Yes then do
    hold = FullPath
    call GetDriveSpec FullName
    if FullPath \= hold then
      Call SysFileDelete Param1
    FullPath = hold
    if Ext == 'Z' & Translate(Right(FullPath,6)) == ".TAR.Z" then do
	Ext = 'TAR'
	Param1 = NameOnly
	Extractor.Ext '"'Param1'"'
	Call SysFileDelete Param1
    end
  end
return

GetDriveSpec: procedure expose FullPath FullName NameOnly Ext
parse arg Name
Call SysFileTree Name, files, 'FO'
if files.0 > 0 then do
  FullPath = files.1
  fDrive = Left( FullPath, 2 )
  fPath = SubStr( FullPath, 3, LastPos( '\', FullPath) -2 )
  FullName  = SubStr( FullPath, Length(fPath)+3 )

  ExtPos = LASTPOS(".",FullName)
  if ExtPos=0 then do
    Ext = ''
    NameOnly = FullName
  end
  else do
    Ext = SUBSTR(FullName,ExtPos+1)
    NameOnly = LEFT(FullName,ExtPos-1)
  end
end
else do
  p = Pos( ':', Name )
  if p > 0 then do
    fDrive = Left( Name, p )
    Name = SubStr( Name, p+1 )
  end
  else
    fDrive = ''

  p = LastPos( '\', Name )
  if p > 0 then do
    fPath = Left( Name, p )
    Name = SubStr( Name, p+1 )
  end
  else
    fPath = ''

  FullName = Name
  p = LastPos( '.', Name )
  if p > 0 then do
    Ext = SubStr( Name, p+1 )
    NameOnly = Left( Name, p-1 )
  end
  else do
    Ext = ''
    NameOnly = Name
  end

  FullPath = fDrive||fPath||FullName
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
