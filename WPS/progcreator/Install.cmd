/* Script to install Program Creator */
/* Copyright (c) 1995, 1997 Anssi Blomqvist */

Call rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

/* Variables */
valid = 0
Name = 'Program Creator'
Filecount = 3
File = 'CrProg.cmd CrProg.ico ReadMe.txt'

Say '           Installation program for Program Creator'
Say '           ----------------------------------------'
Say
Say '(c) 1995, 1997 Anssi Blomqvist, abblomqv@rock.helsinki.fi'
Say

Invalid = 'Invalid path!'
GetPath:
Do until valid
   Say 'Give the full path where to install the program.'
   Say 'e.g. "D:\UTILS\PrCr":'
   Pull Dest
   valid = Pos(':', Dest)=2 & Pos('\', Dest)=3 & Lastpos('\', Dest)<>Length(Dest)
   If \valid Then Say Invalid
End

rc = SysMkDir(Dest)
If rc <> 0 & rc <> 5 then 
Do
   Say Invalid
   call GetPath
End
Say 'Installation in progress...'
Do i=1 to filecount
   '@copy 'Word(File, i) Dest
   If rc <> 0 then signal error
end /* do */
Say

Program = Dest||"\CrProg.cmd"
Program = 'EXENAME='||Program||';OBJECTID=<PRCR>'
result=SysCreateObject("WPProgram", Name, "<WP_DESKTOP>", Program, "r")
If result = 1 Then Say 'Installation was successfull.'
   Else Signal Error
If \SysSetIcon('CrProg.cmd', 'CrProg.ico') then signal error
rc=SysFileDelete(insert(Dest,'\CrProbj.cmd'))
rc=SysFileDelete(insert(Dest,'\CrProbj.ico'))
Exit

Error:
   Beep(440,400)
   Say 'Installation failed!'
   '@Pause'
Exit
