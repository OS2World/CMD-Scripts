/* MakeDoc v.1.0 Installer (Install.CMD) (c) 1993 by XmbSoft */


'@cls'
say '--- MakeDoc v.1.0 Installer by XmbSoft [CIS ID 100031,2136] ---'
say
say
say 'With MakeDoc, the creation of Book objects (hipertext documentation)'
say 'from an .INF file is easy. Once MakeDoc has been installed, drag'
say 'the icon of the *.INF file that contains the documentation of the'
say 'new program: MakeDoc will automatically create the Book object.'
say
say 'MakeDoc can create the Book object in three different places. You'
say 'must pick one of those now, although you can change your selection'
say 'later.'
say
say '   1 - Create the Book object in the Desktop.                    [/D]'
say '   2 - Create the Book object in the folder of the *.INF file.   [/F]'
say '   3 - Create the Book object in the Information folder of OS/2. [/I]'
say
say 'Press 1, 2 or 3 (0 will abort installation):'

pull Opt .

if Opt\='1' & Opt\='2' & Opt\='3' then call final

Select 
   when Opt='1' then Param='/D'
   when Opt='2' then Param='/F'
   when Opt='3' then Param='/I'
end

DrSys=FileSpec('D',Value('SYSTEM_INI',,'OS2ENVIRONMENT'))

say 'Now, enter the drive and full path of the directory where you want'
say "to install MakeDoc (for exemple, C:\MAKEDOC). If it doesn't exist"
say 'it will be created:'
say

pull DirMD .

if DirMD='' then call final

say
say '> Creating/verifying the directory' DirMD'...'

DirOld=directory()

if directory(DirMD)='' then
do
   call RxFuncAdd 'SysMkDir','RexxUtil','SysMkDir'
   if SysMkDir(DirMD)>0 then
   do
      say
      say 'Error creating directory' DirMD'.'
      call final
   end
end

call directory(DirOld)

say '> Copying files...'

'@copy MakeDoc.CMD' DirMD '> nul'
'@copy MakeDoc.DOC' DirMD '> nul'
'@copy CMD.EA' DirMD '> nul'
'@copy DOC.EA' DirMD '> nul'

say '> Adding EAs to files...'

'@'FileSpec('D', DirMD)
call directory DirMD

'@eautil MakeDoc.CMD CMD.EA /m /j'
'@eautil MakeDoc.DOC DOC.EA /m /j'

say '> Creating objects...'

call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'

if SysCreateObject("WPShadow", "MakeDir.DOC", "<WP_DESKTOP>", "SHADOWID="DirMD"\MakeDoc.DOC;ICONPOS=40 25;OBJECTID=<WP_MDDOC>")
then say '...MakeDoc.DOC (Shadow) has been installed successfully.'
else say 'Problem creating shadow!!!'

Setup='EXENAME='DirMD'\MakeDoc.CMD;'||,
      'MINIMIZED=YES;ICONPOS=25 25;NORENAME=YES;'||,
      'OBJECTID=<WP_MDPrg>;'||,
      'PARAMETERS='Param';'

if SysCreateObject("WPProgram", "MakeDoc v.1.0^by XmbSoft", "<WP_DESKTOP>", Setup)
then say '...MakeDoc (Program) has been installed successfully.'
else say 'Problem creating program object!!!'

if SysCreateObject("WPShadow", "REXX.INF", "<WP_DESKTOP>", "SHADOWID="DrSys"\OS2\BOOK\REXX.INF;ICONPOS=40 10")
then say '...REXX.INF (Shadow) has been installed successfully.'
else say 'Problem creating REXX.INF shadow!!!'
say
say
'@pause'
'@cls'
say 'Try me NOW!!!'
say 
say 'Drag the icon of REXX.INF onto the MakeDoc v.1.0 by XmbSoft icon.'
say "A Book Object called 'REXX Guide' will be created. Depending on"
say 'the option you chose, this object will be placed in the Desktop,'
say 'in the Information folder or in the folder of the original file'
say '(\OS2\BOOK).'
say
say
say 'Double-click onto the MakeDoc.Doc icon to view documentation.'
say 'No, I want no money for MakeDoc but any feedback is welcome!'
say
say 'The Author:             Xavier M. Badosa, CIS ID 100031,2136.'
say
say
say '********************* End of Installation *********************'
say
say
say
'@pause'

call RxFuncAdd 'SysDropFuncs', 'RexxUtil', 'SysDropFuncs'
call SysDropFuncs

exit

final:
   say
   say 'Installation aborted!'
   say
   '@pause'
   exit
