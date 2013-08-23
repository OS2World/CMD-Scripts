/* MakeDoc v.1.0 by XmbSoft [CIS ID 100031,2136] */

CompStr="HSP›"
CompNum=5

call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'

arg Opt Par

if Par='' then signal Format
if Opt\='/D' & Opt\='/F' & Opt\='/I' then signal Format

File = strip(translate(Par,' ','"'))

FileName = FileSpec('N', File)
FileDir  = FileSpec('D', File)||FileSpec('P', File)
FileDir  = DelStr(FileDir, length(FileDir))
Pos      = LastPos('.INF', FileName)

if Pos  = 0 then signal Bye
if CharIn(File, 1, CompNum) \= CompStr then signal Bye
Call Stream File, 'c', 'close'

FileName = DelStr(FileName, Pos)

Class='WPProgram'
Title=FileName' Guide'

Select 
   when Opt='/D' then Loc='<WP_DESKTOP>'
   when Opt='/F' then Loc=FileDir
   when Opt='/I' then Loc='<WP_INFO>'
end

Setup='EXENAME=VIEW.EXE;'||,
      'PARAMETERS='Par';'

result=SysCreateObject(Class, Title, Loc, Setup)
if result\=1 then
do
   say 'Object not created!!! Return code='result
   say
   '@pause'
end

Exit

Bye:
   say '---- MakeDoc v.1.0 by XmbSoft [CIS ID 100031,2136] ----'
   say
   say
   say 'The file is not a Documentation File!!!'
   say
   say 'Try another file (*.INF).'
   say 
   '@pause'
Exit

Format:
   say '---- MakeDoc v.1.0 by XmbSoft [CIS ID 100031,2136] ----'
   say
   say
   say 'Syntax:'
   say 
   say '   MAKEDOC /x filename'
   say
   say 'where /x can be:'
   say '      /D   Place result in the Desktop'
   say '      /F   Place result in the original folder'
   say '      /I   Place result in the Information folder'
   say
   say 'From the WorkPlace Shell, you should drag a file icon'
   say 'onto the MakeDoc v.1.0 by XmbSoft icon.'
   say
   say
   say
   '@pause'
Exit