/*
  Convert fixpack readme to a data file for checking against system.
  Copyright 1996, Charles H. McKinnis, all rights reserved.
  An unrestricted license is hereby granted to all who
  wish to use this program on an AS IS basis.
*/
Trace 'N'
read_search = 'Pre-requisite CSD Level:'
os2_levels = ''
csdline. = ''

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

Say 'Enter the fully qualified name of the readme file to be converted'
Parse Upper Pull read_file
If Substr(read_file,2,1) <> ':' Then Do
   Say 'Use the fully qualified name of the readme file to be converted'
   Call Clean_up
   End
If \ Filefind(read_file) Then Do
   Say read_file 'not found'
   Call Clean_up
   End

Say 'Enter the fully qualified name of the output data file'
Parse Upper Pull dat_file
If Substr(dat_file,2,1) <> ':' Then Do
   Say 'Use the fully qualified name of the output data file'
   Call Clean_up
   End
If Stream(dat_file,'C','QUERY EXISTS') <> '' Then Do
   Say dat_file 'exists and will be replaced'
   '@DEL' dat_file
   End

return_code = SysFileSearch(read_search,read_file,'csdline.','N')
If csdline.0 = 0 Then Do
   Say read_file 'does not appear to be a proper file'
   Call Clean_up
   End

Say 'Processing readme file' read_file
Parse Value Space(csdline.1) With first_line .
Do i = 1 To first_line
   line = Linein(read_file)
   End

Do i = 1 To csdline.0
   Parse Value Space(csdline.i) With fix_line . ':' fix_level .
   fix_level = Left(fix_level,Lastpos('_',fix_level) - 1)
   os2_levels = Space(os2_levels fix_level)
   j = i + 1
   Parse Value Space(csdline.j) With next_csd .
   If next_csd = '' Then next_csd = 999999
   Do j = fix_line + 1 To next_csd While Lines(read_file) > 0
      line = Linein(read_file)
      If Pos('/',line) > 0,
         & Pos('OS/2',line) = 0,
         & Pos('Manager/2',line) = 0 Then Do
         Say os2_levels
         rc = Lineout(dat_file,Space(line os2_levels))
         Do k = j + 1 To next_csd While Lines(read_file) > 0
            line = Linein(read_file)
            If Pos('/',line) > 0,
               & Pos('OS/2',line) = 0,
               & Pos('Manager/2',line) = 0 Then rc = Lineout(dat_file,Space(line os2_levels))
            End
         os2_levels = ''
         Iterate i
         End
      End
   End
rc = Stream(read_file,'C','CLOSE')
rc = Stream(dat_file,'C','CLOSE')
Say 'Finished converting readme file' read_file 'to data file' dat_file

Clean_up:
   If \ RxFuncQuery('SysDropFuncs') Then Call SysDropFuncs
   Exit

Filefind: Procedure
   Parse Upper Arg file type .
   If type = '' | type = 'F' Then type = 'F'
   return_code = SysFileTree(file,'file',type)
   If return_code = 0 Then Do
      If file.0 = 1 Then status = 1
      Else status = 0
      End
   Else status = 0
   Return status
