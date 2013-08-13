/*
 * Generator   : PPWIZARD version 99.276
 *             : FREE tool for OS/2, Windows, DOS and UNIX by Dennis Bareis (db0@anz.com)
 *             : http://www.labyrinth.net.au/~dbareis/ppwizard.htm
 * Time        : Sunday, 3 Oct 1999 8:34:37am
 * Input File  : E:\DB\PROJECTS\OS2\archive\ARCHIVE.x
 * Output File : .\OUT\ARCHIVE.CMD
 */

if arg(1)="!CheckSyntax!" then exit(21924)

/*
*$Header:E:/DB/PVCS.IT/OS2/ARCHIVE/ARCHIVE.X_V 1.9 03 Mar 1999 11:41:46 Dennis_Bareis $
*/
PgmVersion="99.276"
PgmParameters=translate(strip(arg(1)))
parse var PgmParameters Command Parameters
address cmd '@echo off'
EscapeChar=d2c(27)
NlChar=d2c(10)
Reset=EscapeChar|| '[0m'
HighlightColor=EscapeChar|| '[1;33m'
TitleColor=EscapeChar|| '[0;32m'
ErrorColor=EscapeChar|| '[1;31m'
NormalColor=EscapeChar|| '[0;32m'
call DisplayCopyright
call RxFuncAdd 'SysIni',           'RexxUtil', 'SysIni'
call RxFuncAdd 'SysOs2Ver',        'RexxUtil', 'SysOs2Ver'
call RxFuncAdd 'SysCreateObject',  'RexxUtil', 'SysCreateObject'
call RxFuncAdd 'SysSetObjectData', 'RexxUtil', 'SysSetObjectData'
call RxFuncAdd 'SysSearchPath',    'RexxUtil', 'SysSearchPath'
call RxFuncAdd 'RxMessageBox',     'RexxUtil', 'RxMessageBox'
call RxFuncAdd 'SysFileDelete',    'RexxUtil', 'SysFileDelete'
call RxFuncAdd 'SysFileTree',      'RexxUtil', 'SysFileTree'
/*
*BASEDATE.XH Version 99.034 by Dennis Bareis
*http://www.labyrinth.net.au/~dbareis/index.htm(db0@anz.com)
*/
signal EndBASEDATEXh

BaseDate:procedure
TheDate=translate(arg(1), ' ', '/-')
if TheDate='' then
TheDate=date('Sorted')
parse var TheDate Year MM DD
if length(Year)>=8 then
do
DD=substr(Year,7,2)
MM=substr(Year,5,2)
Year=left(Year,4)
end
DaysInMonth='31  28  31  30  31  30  31  31  30  31  30  31'
if datatype(Year, 'WholeNumber')<>1 then
return(-10)
if datatype(MM, 'WholeNumber')<>1 then
return(-20)
if datatype(DD, 'WholeNumber')<>1 then
return(-30)
if MM<0|MM>12 then
return(-21)
DaysThisMonth=word(DaysInMonth,MM)
if MM=2 then
DaysThisMonth=DaysThisMonth+1
if DD<0|DD>DaysThisMonth then
return(-31)
if length(strip(Year))=2 then
do
if Year>=80 then
Year='19' ||Year
else
Year='20' ||Year
end
y=Year-0001
b=y*365
b=b+y%4
b=b-y%100
b=b+y%400
m=mm-01
do i=1 to m
b=b+word(DaysInMonth,i)
end
if mm>2 then
do
if 0=Year//4 then
do
if 0=Year//100 then
do
if 0=Year//400 then
b=b+1
end
else
b=b+1
end
end
d=dd-01
b=b+d
return(b)

EndBASEDATEXh:
parse source . . RexxCmdName
ArchivePgmDir=filespec('drive', RexxCmdName) || filespec('Path',RexxCmdName)
LogFile=ArchivePgmDir|| "ARCHIVE.LOG"
ArchiveIniFile=ArchivePgmDir|| "ARCHIVE.INI"
signal on NOVALUE name RexxTrapUninitializedVariable
signal on SYNTAX name RexxTrapSyntaxError
signal on HALT name RexxCtrlC
signal EndINSTALLXh

ProcessInstallCommand:
call Normal 'Archive software is installed at "' || ArchivePgmDir || '".'
CmdExe=SysSearchPath('PATH', 'CMD.EXE')
if CmdExe='' then
Error("Can't find OS/2 directory.")
Os2Path=filespec('drive', CmdExe) || filespec('path',CmdExe)
ArchiveFile=Os2Path|| 'BOOT\ARCHBASE.$$$'
call Normal 'The OS/2 archive file is "' || ArchiveFile || '".'
if PatchDetails='' then
do
ArchiveFileBu=Os2Path|| 'BOOT\ARCHBASE.ORG'
if stream(ArchiveFileBu, 'c', 'query exists') = '' then
do
call Normal 'Backing it up to "' || ArchiveFileBu || '".'
address cmd 'copy ' || ArchiveFile || ' ' || ArchiveFileBu || ' >nul'
if Rc<>0 then
Error("Copy failed (RC=" || RC || ')')
end
call OpenDesktopProperties
call Highlight 'Select "ARCHIVE" tab, Ensure "Create archive at system startup" is OFF.'
call Pause
call Normal 'Recording current state (OFF)...'
WhenOff=GetFileContents(ArchiveFile)
do until WhenOff<>WhenOn
call OpenDesktopProperties
call Highlight 'Set the "Create archive at system startup" option to ON.'
call Pause
call Normal 'Recording current state (ON)...'
WhenOn=GetFileContents(ArchiveFile)
end
if length(WhenOn)<>length(WhenOff)then
Error("File sizes appear to differ (not expected)")
DiffPos=compare(WhenOff,WhenOn)
if DiffPos=0 then
Error("Can't find difference (unexpected)")
HexOffset=d2x(DiffPos-1)
HexValueOff=c2x(substr(WhenOff,DiffPos,1))
HexValueOn=c2x(substr(WhenOn,DiffPos,1))
NewValue=HexValueOff|| ' ' || HexValueOn || ' ' || HexOffset  || ' ' ||ArchiveFile
call SysIniWrite "Configuration", "PatchDetails",NewValue
call SysIniWrite "Configuration", "InstalledOnOs2Version",Os2VerNow
end
call Normal 'Patch offset is x' || HexOffset || ' (OFF=x' || HexValueOff || ', ON=x' || HexValueOn || ').'
call charout,NormalColor|| "Days between automatic archives (0=OFF) : " ||Reset
NumberOfDays=strip(linein())
if NumberOfDays='' then
NumberOfDays=0
if datatype(NumberOfDays, 'W')=0 then
NumberOfDays=7
call _HowManyArchives
KeyFileRc=InstallHandleOs2KeyFile()
if KeyFileRc<>0 then
call SayAndLogErrorLine 'THIS ARCHIVE PROGRAM CAN NOT MANAGE YOUR "OS2.KEY" FILE'
Title="Turn on Archiving"
Location="<WP_DESKTOP>"
Class="WPProgram"
ObjMode="ReplaceIfExists"
SetupString="EXENAME=*;"
SetupString=SetupString|| 'EXENAME=CMD.EXE;'
SetupString=SetupString|| 'PARAMETERS=/c ' || RexxCmdName || ' ON;'
SetupString=SetupString|| "ICONFILE=" || ArchivePgmDir || 'ON.ICO;'
SetupString=SetupString|| "MINIMIZED=YES;"
SetupString=SetupString|| "PROGTYPE=PM;"
SetupString=SetupString|| "OBJECTID=<TurnArchiveOn>;"
Rc=SysCreateObject(Class,Title,Location,SetupString,ObjMode)
call Normal 'Creating icon - ' ||Title
if Rc=0 then
Error("Could not create the icon")
Title="Turn off Archiving"
Location="<WP_DESKTOP>"
Class="WPProgram"
SetupString="EXENAME=*;"
SetupString=SetupString|| 'EXENAME=CMD.EXE;'
SetupString=SetupString|| 'PARAMETERS=/c ' || RexxCmdName || ' OFF;'
SetupString=SetupString|| "ICONFILE="   || ArchivePgmDir || 'OFF.ICO;'
SetupString=SetupString|| "MINIMIZED=YES;"
SetupString=SetupString|| "PROGTYPE=PM;"
SetupString=SetupString|| "OBJECTID=<TurnArchiveOff>;"
Rc=SysCreateObject(Class,Title,Location,SetupString,ObjMode)
call Normal 'Creating icon - ' ||Title
if Rc=0 then
Error("Could not create the icon")
if NumberOfDays=0 then
Title="Turn off Archiving"
else
Title="Turn off Archiving (turn on every " || NumberOfDays || ' days)'
Location="<WP_START>"
Class="WPProgram"
SetupString="EXENAME=*;"
SetupString=SetupString|| 'EXENAME=CMD.EXE;'
SetupString=SetupString|| 'PARAMETERS=/c ' || RexxCmdName || ' OFF ' || NumberOfDays || ';'
SetupString=SetupString|| "ICONFILE="   || ArchivePgmDir || 'OFF.ICO;'
SetupString=SetupString|| "MINIMIZED=YES;"
SetupString=SetupString|| "PROGTYPE=PM;"
SetupString=SetupString|| "OBJECTID=<TurnArchiveOffInStartupFolder>;"
Rc=SysCreateObject(Class,Title,Location,SetupString,ObjMode)
call Normal 'Creating icon - ' ||Title
if Rc=0 then
Error("Could not create the icon")
say ''
call Highlight 'STARTUP FOLDER updated so that archiving is automatically'
call Highlight 'turned off/on after boot.  Delete this icon icon if you wish.'
say ''
call Normal 'Setup Completed'
call LogLine ''
return(0)

InstallHandleOs2KeyFile:
ArchiveFileContents=GetFileContents(ArchiveFile)
PathPos=pos(Os2Path,ArchiveFileContents)
if PathPos=0 then
do
call LogLine 'Looks like you are not using the default archive path (or any under "' || Os2Path || '")'
if substr(ArchiveFileContents,8,1)=':' then
PathPos=7
else
do
call SayAndLogErrorLine 'Could not determine where archive path is...'
return(1)
end
end
parse value substr(ArchiveFileContents,PathPos)with ArchivePath '00'x
Os2KeyFile=ArchivePath|| '\OS2.KEY'
Os2KeyFileBu=ArchivePath|| '\OS2.ORG'
call Normal '"OS2.KEY" file should be located in the "' || ArchivePath || '" directory.'
address cmd 'attrib -r -s -h ' || Os2KeyFile || ' >nul 2>&1'
if stream(Os2KeyFile, 'c', 'query exists') = '' then
do
call SayAndLogErrorLine 'The key file "' || Os2KeyFile || '" does not exist!'
return(2)
end
call SysIniWrite "Configuration", "KeyFileNamePosn",PathPos
if stream(Os2KeyFileBu, 'c', 'query exists') = '' then
do
call Normal 'Backing it up to "' || Os2KeyFileBu || '".'
address cmd 'copy ' || Os2KeyFile || ' ' || Os2KeyFileBu || ' >nul'
if Rc<>0 then
Error("Copy failed (RC=" || RC || ')')
end
Os2KeyDetails=SysIniRead("Configuration", "KeyFilesToArchive", '')
if Os2KeyDetails='' then
do
call Normal 'Importing details from "' || Os2KeyFile || '".'
ImportLine=0
CloseRc=stream(Os2KeyFile, 'c', 'close')
do while lines(Os2KeyFile)<>0
CurrentLine=strip(linein(Os2KeyFile))
ImportLine=ImportLine+1
if CurrentLine='' then
iterate
if left(CurrentLine,length('KEYFILE:')) <> 'KEYFILE:' then
Error('Line #' || ImportLine || ' of file does not begin with "' || 'KEYFILE:' || '"!')
CurrentFile=substr(CurrentLine,length('KEYFILE:')+1)
call Normal '    * FOUND: ' ||CurrentFile
if Os2KeyDetails='' then
Os2KeyDetails=CurrentFile
else
Os2KeyDetails=Os2KeyDetails|| ';' ||CurrentFile
end
CloseRc=stream(Os2KeyFile, 'c', 'close')
call SysIniWrite "Configuration", "KeyFilesToArchive",Os2KeyDetails
end
Os2KeyDetailsBefore=Os2KeyDetails
TmpFile=ArchivePgmDir|| "KEYFILES.LST"
CloseRc=stream(TmpFile, 'c', 'close')
DosDelRc=SysFileDelete(TmpFile)
if stream(TmpFile, 'c', 'query exists') <> '' then
Error('Could not delete "' || TmpFile || '" - do you have it in use?')
call lineout TmpFile, ';******************************'
call lineout TmpFile, ';**** PRESS ALT+F4 TO EXIT ****'
call lineout TmpFile, ';******************************'
call lineout TmpFile, ''
call lineout TmpFile, ';Every time OS/2 archives the desktop it also backs up'
call lineout TmpFile, ';a list of "KEY" files.  You may now update this list'
call lineout TmpFile, ';if you have some very important files.'
call lineout TmpFile, ''
call lineout TmpFile, ';You may use wildcards to specify a range of files, in'
call lineout TmpFile, ';which case the actual filenames to be archived are'
call lineout TmpFile, ';worked out every time archiving is turned on. As an'
call lineout TmpFile, ';example you could specify "C:\OS2\MDOS\WINOS2\*.INI"'
call lineout TmpFile, ''
call lineout TmpFile, ';If you preceed the filenames with "+" as in "+C:\*.INI"'
call lineout TmpFile, ';then all subdirectories are searched.'
call lineout TmpFile, ''
call lineout TmpFile, ''
call lineout TmpFile, ';WARNING'
call lineout TmpFile, ';~~~~~~~'
call lineout TmpFile, ';The files that you specify are restored when you choose'
call lineout TmpFile, ';to restore an older archive.  You MUST remember this fact'
call lineout TmpFile, ';if all you wish to do is restore the workplace shell.'
call lineout TmpFile, ''
call lineout TmpFile, ''
do while Os2KeyDetails<> ''
parse var Os2KeyDetails FileMask ';' Os2KeyDetails
call lineout TmpFile,FileMask
end
CloseRc=stream(TmpFile, 'c', 'close')
call Normal 'You may now MODIFY the list of files to ARCHIVE'
address cmd 'E.EXE ' ||TmpFile
Os2KeyDetails=''
CloseRc=stream(TmpFile, 'c', 'close')
do while lines(TmpFile)<>0
CurrentFile=strip(linein(TmpFile))
if CurrentFile='' then
iterate
if left(CurrentFile,1)=';' then
iterate
if Os2KeyDetails='' then
Os2KeyDetails=CurrentFile
else
Os2KeyDetails=Os2KeyDetails|| ';' ||CurrentFile
end
CloseRc=stream(TmpFile, 'c', 'close')
DosDelRc=SysFileDelete(TmpFile)
if Os2KeyDetailsBefore=Os2KeyDetails then
call Normal '    * List unmodified'
else
do
call Normal '    * List was changed'
call SysIniWrite "Configuration", "KeyFilesToArchive",Os2KeyDetails
end
call CreateOs2KeyFile
return(0)

_HowManyArchives:
ArchiveFileContents=GetFileContents(ArchiveFile)
ThreePos=SysIniRead("Configuration", "NumberOfArchivesPosn", '')
if ThreePos='' then
do
call LogLine "Need to determine where OS/2 stores the archive count."
Three=d2c(3)
ThreePos=pos(Three,ArchiveFileContents)
if ThreePos=0|pos(Three,ArchiveFileContents,ThreePos+1)<>0 then
do
call SayAndLogErrorLine "Can't determine archive count posn (can't change count)"
return
end
call SysIniWrite "Configuration", "NumberOfArchivesPosn",ThreePos
end
call LogLine 'Warning user to use 3 archives unless they test themselves'
say ''
call HighLight "*******************************************************************"
call HighLight "*** I have some evidence that while you can increase the number ***"
call HighLight "*** of archives, when you go to restore it won't let you choose ***"
call HighLight "*** the lower numbers...  I am warning you that at this stage   ***"
call HighLight "*** I do not have time to work it out. I RECOMMEND you press    ***"
call HighLight "*** SELECT 3 for the question below unless you have tested this ***"
call HighLight "*** on a machine without important information.  If you do test ***"
call HighLight '*** then please SEND RESULTS to "dbareis@labyrinth.net.at"!     ***'
call HighLight "*******************************************************************"
say ''
CurrentCount=c2d(substr(ArchiveFileContents,ThreePos,1))
do forever
call charout,NormalColor|| "Number of archives to keep (ENTER=" || CurrentCount || " or 1-9) : " ||Reset
NewCount=strip(linein())
if NewCount='' then
return
if datatype(NewCount, 'W')then
do
if NewCount>=1&NewCount<=9 then
leave
end
end
if NewCount<>CurrentCount then
PatchRc=PatchFile(ArchiveFile,d2x(ThreePos-1),d2x(NewCount))
call LogLine "Now keeping " || NewCount || " archives."
return

CreateOs2KeyFile:
ArchiveFileContents=GetFileContents(ArchiveFile)
PathPos=SysIniRead("Configuration", "KeyFileNamePosn", '')
if PathPos='' then
do
call LogLine "Can't process 'OS2.KEY' until reinstalled."
return
end
parse value substr(ArchiveFileContents,PathPos)with ArchivePath '00'x
Os2KeyFile=ArchivePath|| '\OS2.KEY'
call Normal 'Creating "' || Os2KeyFile || '"'
Os2KeyDetails=SysIniRead("Configuration", "KeyFilesToArchive", '')
if Os2KeyDetails='' then
do
call LogLine "Can't find list of KEY Files (need to reinstall)."
address cmd 'start "*** ARCHIVE REINSTALL ***" /WIN /F ' || RexxCmdName || ' install'
exit(GetLineNumber())
end
CloseRc=stream(Os2KeyFile, 'c', 'close')
address cmd 'attrib -r -s -h ' || Os2KeyFile || ' >nul 2>&1'
DosDelRc=SysFileDelete(Os2KeyFile)
do while Os2KeyDetails<> ''
parse var Os2KeyDetails FileMask ';' Os2KeyDetails
if left(FileMask,1)<> '+' then
DoSubDir=''
else
do
DoSubDir='S'
FileMask=substr(FileMask,2)
end
File.0=0
call SysFileTree FileMask, 'File', 'FO' ||DoSubDir
if File.0=0 then
do
if substr(FileMask,2,1)=':' then
call Normal '    * No files match "' || FileMask || '"'
if DoSubDir='' & verify(FileMask, "*?", "M")=0 then
call lineout Os2KeyFile, 'KEYFILE:' ||FileMask
end
else
do
do FileIndex=1 to File.0
call lineout Os2KeyFile, 'KEYFILE:' ||File.FileIndex
end
end
end
CloseRc=stream(Os2KeyFile, 'c', 'close')
return

EndINSTALLXh:
Os2VerNow=SysOs2Ver()
PatchDetails=SysIniRead("Configuration", "PatchDetails", '')
if PatchDetails<> '' then
do
Os2VerInstall=SysIniRead("Configuration", "InstalledOnOs2Version", '')
if Os2VerInstall='' then
do
call SysIniWrite "Configuration", "InstalledOnOs2Version",Os2VerNow
Os2VerInstall=Os2VerNow
end
if Os2VerInstall<>Os2VerNow then
do
if Command<> "INSTALL" then
do
call LogLine 'Archive installed on OS/2 version ' || Os2VerInstall || ', version is now ' || Os2VerNow || ', must reinstall'
call SayAndLogErrorLine 'We need to reinstall ARCHIVE as the OS/2 version has changed since it was installed.'
address cmd 'start "*** ARCHIVE REINSTALL ***" /WIN /F ' || RexxCmdName || ' install'
exit(GetLineNumber())
end
end
end
if PatchDetails='' then
do
if Command<> "INSTALL" then
do
call Error "We can't access the configuration details stored in '" || ArchiveIniFile || "'."
exit(GetLineNumber())
end
end
parse var PatchDetails HexValueOff HexValueOn HexOffset ArchiveFile
ExitRc=0
select
when Command="INSTALL" then
ExitRc=ProcessInstallCommand()
when Command="ON" then
do
call CreateOs2KeyFile
if PatchFile(ArchiveFile,HexOffset,HexValueOn)=0 then
do
Msg="Archiving will take place on following boot."
Icon="INFORMATION"
end
else
do
Msg="Archiving was already turned on!"
Icon="EXCLAMATION"
end
call LogLine Msg
call DisplayPmMessage Icon,Msg||GetLastArchiveTime()
end
when Command="OFF" then
do
PatchRc=PatchFile(ArchiveFile,HexOffset,HexValueOff)
TurnOnPeriod=Parameters
if TurnOnPeriod='' then
do
if PatchRc=0 then
do
Msg="Archiving turned off."
Icon="INFORMATION"
end
else
do
Msg="Archiving was already turned off!"
Icon="EXCLAMATION"
end
call LogLine Msg
call DisplayPmMessage Icon,Msg||GetLastArchiveTime()
end
else
do
BaseDateToday=BaseDate()
if PatchRc=0 then
do
call LogLine 'Just completed archive - archiving turned off'
call SysIniWrite "LastArchive", "BaseDate",BaseDateToday
call SysIniWrite "LastArchive", "FormattedTime",GetPrettyTime()
end
if TurnOnPeriod<>0 then
do
LastArchiveBaseDate=SysIniRead("LastArchive", "BaseDate", '0')
DaysDiff=BaseDateToday-LastArchiveBaseDate
if DaysDiff>=TurnOnPeriod|DaysDiff<0 then
do
call CreateOs2KeyFile
call PatchFile ArchiveFile,HexOffset,HexValueOn
LastArchiveTime=GetLastArchiveTime()
Line2Log='Archive automatically turned on as it is every ' || TurnOnPeriod || ' days'
if LastArchiveTime<> '' then
Line2Log=Line2Log|| ' (last archive completed ' || LastArchiveTime || ')'
call LogLine Line2Log|| '.'
if TurnOnPeriod=1 then
PeriodText='day'
else
PeriodText=TurnOnPeriod|| ' days'
TheMsg='Archiving will take place on following boot.' ||NlChar||NlChar
TheMsg=TheMsg|| 'You have requested that archiving occur every ' || PeriodText || '.'
TheMsg=TheMsg||LastArchiveTime
call DisplayPmMessage "INFORMATION",TheMsg
end
end
end
end
otherwise
Error('Unknown command of "' || Command || '" specified!')
end
exit(ExitRc)

GetLastArchiveTime:
FormattedTime=SysIniRead("LastArchive", "FormattedTime", '')
if FormattedTime<> '' then
FormattedTime=NlChar||NlChar|| 'The last archive occurred ' || FormattedTime || '.'
return(FormattedTime)

GetPrettyTime:
TheTime=time('C')
TheDay=date('WeekDay')
TheDate=date()
if arg(1)='PAD' then
do
TheTime=right(TheTime,7)
TheDay=left(TheDay,8)
TheDate=left(TheDate,11)
end
return(TheTime|| ' ' || TheDay || ' ' ||TheDate)

LogLine:
if arg(1)='' then
call lineout LogFile, ''
else
call lineout LogFile,GetPrettyTime('PAD') || ' : ' ||arg(1)
CloseRc=stream(LogFile, 'c', 'close')
return

PatchFile:
Os2ArchiveFileName=arg(1)
PatchLocation=x2d(arg(2))+1
PatchValue=x2c(arg(3))
if stream(Os2ArchiveFileName, 'c', 'query exists') = '' then
Error('The file "' || Os2ArchiveFileName || '" does not exist!')
address cmd 'attrib.exe -r ' || Os2ArchiveFileName || ' >nul'
OriginalByte=charin(Os2ArchiveFileName,PatchLocation,1)
if OriginalByte=PatchValue then
do
PatchRc=1
CloseRc=stream(Os2ArchiveFileName, 'c', 'close')
end
else
do
PatchRc=0
WriteRc=charout(Os2ArchiveFileName,PatchValue,PatchLocation)
CloseRc=stream(Os2ArchiveFileName, 'c', 'close')
if WriteRc<>0 then
Error('Patch of archive file failed.')
end
address cmd 'attrib.exe +r ' || Os2ArchiveFileName || ' >nul'
say 'Patching successful.'
return(PatchRc)

SysIniRead:
IniApp=arg(1)
IniKey=arg(2)
IniDefault=arg(3)
IniValue=SysIni(ArchiveIniFile,IniApp,IniKey)
if IniValue='ERROR:' then
IniValue=IniDefault
return(IniValue)

SysIniWrite:
IniApp=arg(1)
IniKey=arg(2)
IniValue=arg(3)
WriteRc=SysIni(ArchiveIniFile,IniApp,IniKey,IniValue)
if WriteRc='ERROR:' then
do
call Error "We couldn't update the configuration details stored in '" || ArchiveIniFile || "'."
exit(GetLineNumber())
end
return

GetFileContents:
Contents=charin(arg(1),1,9999)
CloseRc=stream(arg(1), 'c', 'close')
if length(Contents)<512 then
Error("Only read " || length(Contents) " bytes from file")
return(Contents)

OpenDesktopProperties:
call Normal 'Opening Desktop Properties...'
call SysSetObjectData "<WP_DESKTOP>", "OPEN=SETTINGS"
return

Pause:
address cmd '@pause'
return

SayAndLogErrorLine:
say ErrorColor||arg(1)||Reset|| ''
call LogLine arg(1)
return

Error:
ErrorRc=SIGL
call SayAndLogErrorLine arg(1)
call DisplayPmMessage "ERROR", "An error occurred." ||NlChar||NlChar||arg(1)
exit(ErrorRc)

Normal:
call LogLine arg(1)
say NormalColor||arg(1)||Reset
return

HighLight:
call LogLine arg(1)
say HighlightColor||arg(1)||Reset
return

GetLineNumber:
return(SIGL)

DisplayCopyright:
call charout,HighlightColor
say '[]-------------------------------------------------------------[]'
say '| ARCHIVE.CMD: Version ' || PgmVersion || ' (C)opyright Dennis Bareis 1997    |'
say '| http://www.labyrinth.net.au/~dbareis/index.htm (db0@anz.com)  |'
say '[]-------------------------------------------------------------[]'
say Reset
return

CommonTrapHandler:
FailingLine=arg(1)
TrapHeading='BUG: ' ||arg(2)
TextDescription=arg(3)
Text=arg(4)
parse source . . RexxCmdName
call SayAndLogErrorLine copies('=+',39)
call SayAndLogErrorLine TrapHeading
call SayAndLogErrorLine copies('~',length(TrapHeading))
call SayAndLogErrorLine substr(TextDescription,1,16)|| ': ' ||Text
call SayAndLogErrorLine 'Failing Module  : ' ||RexxCmdName
call SayAndLogErrorLine 'Failing Line #  : ' ||FailingLine
call SayAndLogErrorLine 'Failing Command : ' ||strip(SourceLine(FailingLine))
call SayAndLogErrorLine copies('=+',39)
call DisplayPmMessage "ERROR", "Line #" || FailingLine || " failed." || NlChar || NlChar || TextDescription || ' : ' ||Text
exit(FailingLine)

RexxTrapUninitializedVariable:
call CommonTrapHandler SIGL, 'NoValue Abort!', 'Unknown Variable', condition('D')

RexxTrapSyntaxError:
call CommonTrapHandler SIGL, 'Syntax Error!', 'Reason',errortext(Rc)

RexxCtrlC:
LineCtrlC=SIGL
say ''
say ErrorColor||copies('=+',39)
say "Come on, you pressed Ctrl+C or Break didn't you!"
say copies('=+', 39) || Reset || ''
exit(LineCtrlC)

DisplayPmMessage:
Icon=arg(1)
Text=arg(2)
Title="ARCHIVE.CMD v" || PgmVersion || " ¸ Dennis Bareis 1998"
if Icon='ERROR' then
Button="ENTER"
else
Button="OK"
AddText=NlChar||NlChar|| 'Please report any suggestions or '
AddText=AddText|| 'bugs to "db0@anz.com". The latest version '
AddText=AddText|| 'of this program and many other FREE '
AddText=AddText|| 'programs are available at "http://www.labyrinth.net.au/~dbareis/index.htm".'
signal ON SYNTAX NAME RxBoxCantBeUsed
call RxMessageBox NlChar||Text||AddText,Title,Button,Icon

RxBoxCantBeUsed:
return
