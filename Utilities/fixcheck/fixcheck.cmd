/*
  Check fixpack for regression and missing fixes.
  Copyright 1996, 1999 Charles H. McKinnis, all rights reserved.
  An unrestricted license is hereby granted to all who
  wish to use this program on an AS IS basis.
*/
Trace 'N'
os2_mrm = 'SYSLEVEL.OS2'
mmpm_dir = 'MMOS2'
speech_dir = 'VT'
font_dir = 'PSFONTS'
lang_dir = 'LANGUAGE'
open_dir = 'OPENDOC'
user_dir = 'OS2\INSTALL\USERDIRS.OS2'
user_dir. = ''
user_dir.0 = 0
lvl_list. = ''
lvl_list.1 = '3000 - Warp for Windows'
lvl_list.2 = '3001 - Warp with WIN-OS/2'
lvl_list.3 = '3002 - Warp for Windows Manufacturing Refresh'
lvl_list.4 = '3003 - Warp with WIN-OS/2 Connect'
lvl_list.5 = '3004 - Warp for Windows Manufacturing Refresh Connect'
lvl_list.6 = '3005 - Warp Preload/Warp Server'
lvl_list.7 = '3006 - Warp Server SMP'
lvl_list.8 = '4000 - Warp 4'
lvl_list.9 = '4010 - Workspace On Demand'
lvl_list.0 = 9
crexx_list = 'REXX.DLL REXXUTIL.DLL NONE       NONE        NONE        REX.MSG REXH.MSG REXX.INF' 
orexx_list = 'REXX.DLL REXXUTIL.DLL REXXSC.DLL REXXSOM.DLL REXXWPS.DLL REX.MSG REXH.MSG REXX.INF'
update_detail = 0

Parse Upper Arg mods

Call Initialize

If Wordpos('-UD', mods) <> 0 Then update_detail = 1

Say 'Enter the fully qualified name of the fixpack data file to be checked'
Parse Upper Pull fix_name
If Substr(fix_name,2,1) <> ':' Then Do
   Say 'Use the fully qualified name of the fixpack data file to be checked'
   Call Clean_up
   End
If \ Filefind(fix_name) Then Do
   Say fix_name 'not found'
   Call Clean_up
   End

Say ''
Do i = 1 To lvl_list.0
   Say i lvl_list.i
   End
Say 'Select the level of your OS/2 system'
Parse Upper Pull fix_level
If fix_level >= 1 & fix_level <= lvl_list.0 Then Do
   fix_level = Word(lvl_list.fix_level, 1)
   End
Else Do
   Say 'Selection' fix_level 'is not valid'
   Call Clean_up
   End


fix_level = 'XR_' || fix_level

return_code = SysFileSearch(fix_level, fix_name, 'fixfiles.')
return_code = Stream(fix_name, 'C', 'CLOSE')
If fixfiles.0 = 0 Then Do
   Say fix_name 'does not contain any files for OS/2 level' fix_level
   Call Clean_up
   End

os2_install = Findmrm(os2_mrm)
If os2_install = '' Then Call Clean_up
root_drive = Findroot(os2_install, fix_level)
os2_base = Findbase(os2_install, fix_level)
mmpm_base = Findaux(root_drive, mmpm_dir, fix_level, 'MMPM/2')
speech_base = Findaux(root_drive, speech_dir, fix_level, 'Voice Type')
font_base = Findaux(root_drive, font_dir, fix_level, 'System Fonts')
lang_base = Findaux(root_drive, lang_dir, fix_level, 'Languages')
open_base = Findaux(root_drive, open_dir, fix_level, 'Open Doc')
user_base = Finduser(root_drive, user_dir, fix_level, 'Relocated Components')

If root_drive = '' os2_base = '' & mmpm_base = '' & ,
   speech_base = '' & font_base = '' & lang_base = '' & ,
   open_base = '' & user_dir.0 = 0 Then Do
   Say 'No directories were selected for checking'
   Call Clean_up
   End

Parse Value Findout(fix_name) with out_level out_file .

Say ''
check_line = 'Checking fix pack files in' fix_name || crlf || '   against' os2_base || '*'
If mmpm_base <> '' Then check_line = check_line || ',' mmpm_base || '*'
If speech_base <> '' Then check_line = check_line || ',' speech_base || '*'
If font_base <> '' Then check_line = check_line || ',' font_base || '*'
If lang_base <> '' Then check_line = check_line || ',' lang_base || '*'
If open_base <> '' Then check_line = check_line || ',' open_base || '*' 
If user_base <> '' Then Do i = 1 To user_dir.0
   check_line = check_line || ',' user_dir.i || '*'
   End
check_line = check_line || ', and' root_drive
If out_level Then check_line = check_line || crlf || '   with output to' out_file
Say check_line
Say 'Enter to continue or Enter 'a' to abort'
Parse Upper Pull ans
ans = Left(ans, 1)
If ans = 'A' Then Do
   Say 'Fixcheck aborted by user'
   Call Clean_up
   End
trace 'n'
Do i = 1 To fixfiles.0
   Parse Value Space(fixfiles.i) With file_name pack_name . fix_date fix_time fix_size .
   orexx = Wordpos(file_name, orexx_list)
   If orexx > 0 Then Do
      crexx = Wordpos(file_name, crexx_list)
      If orexx = crexx Then Do
         If objrexx Then Do
            If \Abbrev(pack_name, 'OR') Then Iterate i
            End
         Else Do
            If \Abbrev(pack_name, 'CR') Then Iterate i
            End
         End
      End
   fix_date = Substr(fix_date, 7, 4)||'/'||Substr(fix_date, 1, 5)||'/'Substr(fix_time, 1, 2)||'/'||Substr(fix_time, 4, 2)
   fixfiles.i = file_name fix_date fix_size
   found.0 = 0
   Call Searchit os2_base, file_name, 'FSL'
   Call Searchit mmpm_base, file_name, 'FSL'
   Call Searchit speech_base, file_name, 'FSL'
   Call Searchit font_base, file_name, 'FSL'
   Call Searchit lang_base, file_name, 'FSL'
   Call Searchit open_base, file_name, 'FSL'
   If user_base <> '' Then Do k = 1 To user_dir.0
      Call Searchit user_dir.k, file_name, 'FSL'
      End
   Call Searchit root_drive, file_name, 'FL'
   If found.0 > 0 Then Do j = 1 To found.0
      Parse Value Space(found.j) With updated_date updated_time updated_size . updated_name
      updated_date = Translate(updated_date, '/', '-')
      updated_time = Translate(updated_time, '/', ':')
      updated_time = Left(updated_time, Lastpos('/', updated_time) -1)
      updated_date = updated_date || '/' || updated_time
      If Pos('\OS2\INSTALL\IBMINST\', Translate(updated_name)) > 0 Then Iterate j 
      If j > 1 Then multiples = multiples + 1
      Select
         When (updated_date = fix_date) & (updated_size = fix_size) Then Do
            equaled = equaled + 1
            equaled.equaled = fixfiles.i 'Equal -' updated_name
            updated = updated + 1
            updated.updated = equaled.equaled
            End
         When updated_date > fix_date Then Do
            regressions = regressions + 1
            regressions.regressions = fixfiles.i 'Date Regression -' updated_date updated_name 
            updated = updated + 1
            updated.updated = regressions.regressions
            End
         When updated_date < fix_date Then Do
            backlevel = backlevel + 1
            backlevel.backlevel = fixfiles.i 'Backdated -' updated_date updated_size updated_name
            updated = updated + 1
            updated.updated = backlevel.backlevel
            End
         When (updated_date = fix_date) & (updated_size <> fix_size) Then Do
            regressions = regressions + 1
            regressions.regressions = fixfiles.i 'Size Regression -' updated_size updated_name 
            updated = updated + 1
            updated.updated = regressions.regressions
            End
         Otherwise Nop
         End
      End
   Else Do
      notfound = notfound + 1
      notfound.notfound = fixfiles.i 'No file to update found'
      End
   End

Call Outtitle check_line
Call Outline 'Number of fix files found for OS/2 level' fix_level '=' fixfiles.0
Call Outline 'Number of fix files found without files to update =' notfound
fixfiles = fixfiles.0 - notfound
Call Outline 'Number of fix files elgible for application found =' fixfiles
Call Outline 'Number of multiple file occurrences found =' multiples
Call Outline ''
Call Outline 'Number of system files elgible for updating found =' updated
Call Outline 'Number of possible regressions found =' regressions
Call Outline 'Number of backdated files found =' backlevel
Call Outline 'Number of equal files found =' equaled

If updated > 0 & update_detail Then Do
   Call Outtitle 'Number of system files elgible for updating found =' updated
   Do i = 1 to updated
      Call Outline updated.i
      End
   End

If regressions > 0 Then Do
   Call Outtitle 'Number of possible regressions found =' regressions
   Do i = 1 To regressions
      Call Outline regressions.i
      End
   End

If backlevel > 0 Then Do
   Call Outtitle 'Number of backdated files found =' backlevel
   Do i = 1 To backlevel
      Call Outline backlevel.i
      End
   End

If equaled > 0 Then Do
   Call Outtitle 'Number of equal files found =' equaled
   Do i = 1 To equaled
      Call Outline equaled.i
      End
   End

If notfound > 0 Then Do
   Call Outtitle 'Number of fix files found without files to update =' notfound
   Do i = 1 to notfound
      Call Outline notfound.i
      End
   End
If out_level Then Do
   rc = Stream(out_file, 'C', 'CLOSE')
   Say 'The output has been written to' out_file
   End
Call Outtitle 'End of fix check run'
Call Clean_up

Clean_up:
   Call SysDropFuncs
   Exit

Outtitle: Procedure Expose out_level out_file
   Parse Arg title
   Call Outline ''
   Call Outline title
   Call Outline ''
   Return

Outline: Procedure Expose out_level out_file
   Parse Arg out_line
   If out_level Then Call Lineout out_file, out_line
   Else Say out_line
   Return 0

Searchit: Procedure Expose locate. found. trace
   Parse Arg base, file_name, option
   If base <> '' Then Do
      return_code = SysFileTree(base || file_name, 'locate.', option)
      Call Copyfound return_code
      End
   Return

Copyfound: Procedure Expose locate. found. trace
   base = ''
   Parse Arg return_code, junk
   If return_code = 0 & locate.0 > 0 Then Do i = 1 To locate.0
      j = found.0
      j = j + 1
      found.j = locate.i
      found.0 = j
      End
   Return

Filefind: Procedure
   Parse Upper Arg file, type, junk
   If type = '' | type = 'F' Then type = 'F'
   return_code = SysFileTree(file, 'file', type)
   If return_code = 0 Then Do
      If file.0 = 1 Then status = 1
      Else status = 0
      End
   Else status = 0
   Return status

Findmrm: Procedure Expose trace drive_map
   install = ''
   mrm_index = 0
   mrm_found. = ''
   found. = ''
   Parse Arg mrm, dir, junk
   Say ''
   Say 'Checking all drives for' mrm
   Do i = 1 to Words(drive_map)
      drive = Word(drive_map, i)
      search = drive || '\' || mrm
      return_code = SysFileTree(search, 'found.', 'FSO')
      If return_code = 0 & found.0 > 0 Then Do j = 1 to found.0
         mrm_index = mrm_index + 1
         mrm_found.mrm_index = found.j
         End
      End
   If mrm_index > 0 Then Do
      Say 'The following' mrm 'files were found'
      Say 'Please select one by number from the following list'
      Say '   or press ENTER to bypass checking'
      Do i = 1 to mrm_index
         Say i '-' mrm_found.i
         End
      Parse Upper Pull ans .
      If Datatype(ans, 'W') & (0 < ans < (mrm_index + 1)) Then
         install = mrm_found.ans
      Else Do
         Say 'Invalid selection, terminating run'
         End
      End
   Else Do
      Say 'Could not find' mrm 'on any local drive'
      Say 'Terminating run'
      End
   If install <> '' Then Do
      install = Filespec('DRIVE', install) || Filespec('PATH', install)
      install = Strip(install, 'T', '\')
      End
   Return install

Findaux: Procedure Expose user_dir
   aux = ''
   Parse Arg root, dir, fix, title, junk
   Say ''
   rc = SysFileTree(root || dir, 'dirs.', 'DO')
   If rc = 0 & dirs.0 > 0 Then Do
      Say 'Found the following directory for' title
      Say 'Please select its number from the following list'
      Say '   or press ENTER to bypass checking'
      Do i = 1 To dirs.0
         Say i dirs.i
         End
      Parse Upper Pull ans .
      If Datatype(ans, 'W') & ans = 1 Then Do
         aux = dirs.1
         aux = Strip(aux, 'T', '*')
         If Lastpos('\', aux) <> Length(aux) Then aux = aux || '\'
         Say 'Fixes in' fix 'for' title 'will be checked against' aux || '*'
         End
      Else Do
         Say 'Fixes in' fix 'for' title 'will not be checked'
         End
      End
   Else Do
      Say 'No directory for' root || dir 'was found' 
      Say 'Fixes in' fix 'for' title 'will not be checked'
      Say 'unless the directory is specified in' root || user_dir
      End
   Return aux

Finduser: Procedure Expose user_dir.
   user = ''
   Parse Arg root, dir, fix, title, junk
   Say ''
   rc = SysFileTree(root || dir, 'dirs.', 'DO')
   If rc = 0 & dirs.0 > 0 Then Do
      Say 'Found the following file for' title
      Say 'Please select its number from the following list'
      Say '   or press ENTER to bypass checking'
      Do i = 1 To dirs.0
         Say i dirs.i
         End
      Parse Upper Pull ans .
      If Datatype(ans, 'W') & ans = 1 Then Do
         user = dirs.1
         Do i = 1 Until Lines(user) = 0
            user_dir.0 = user_dir.0 + 1
            user_dir.i = Linein(user)
            user_dir.i = Strip(user_dir.i, 'T', '*')
            If Lastpos('\', user_dir.i) <> Length(user_dir.i) Then user_dir.i = user_dir.i || '\'
            End
         Say 'Relocated components will be checked in the following directory(ies)'
         Do i = 1 To user_dir.0
            Say user_dir.i || '*'
            End         
         End
      Else Do
         Say 'Fixes in' fix 'for' title 'will not be checked'
         End
      End
   Else Do
      Say 'No file' root || dir 'was found' 
      Say 'Fixes in' fix 'for' title 'will not be checked'
      End
   Return user

Selectroot: Procedure
   base = ''
   Parse Upper Arg comp, dir, junk
   Say '   You may enter a root drive to be checked for' comp 'fixes'
   Say '   or press ENTER to bypass checking'
   Parse Upper Pull ans .
   ans = Left(ans, 1)
   If Datatype(ans, 'U') Then base = ans || dir
   Return base

Findroot: Procedure Expose trace
   root = ''
   Parse Arg install, fix, junk
   root = install
   root = Left(root, Lastpos('\', root) -1)
   root = Left(root, Lastpos('\', root))
   Say ''
   Say 'Will check fixpack files for' fix 'against root drive' root
   Return root

Findbase: Procedure Expose trace
   base = ''
   Parse Arg install, fix, junk
   base = install
   base = Left(base, Lastpos('\', base))
   base = base
   Say ''
   Say 'Will check fixpack files for' fix 'against base directory' base || '*'
   Return base

Findout: Procedure
   Parse Upper Arg fix, junk
   new_file = ''
   Say ''
   Say 'Would you like your output to a file (Y|n)?'
   Parse Upper Pull ans
   out_level = \ Abbrev(ans, 'N')
   If out_level Then Do
      Parse Upper Source . . source_path .
      source_path = Left(source_path, Lastpos('\', source_path))
      lst = Substr(fix, Lastpos('\', fix) + 1)
      Parse Upper Var lst lst '.' .
      def_file = source_path || lst || '.LST'
      Do Until new_file = ''
         If Stream(def_file, 'C', 'QUERY EXISTS') <> '' Then Do
            Say def_file 'exists and will be replaced'
            Say '   unless you enter a new fully qualified name now'
            Parse Upper Pull new_file
            If new_file <> '' Then def_file = new_file
            End
         Else new_file = ''
         End
      If Stream(def_file, 'C', 'QUERY EXISTS') <> '' Then '@DEL' def_file
      out_file = def_file
      Say 'Your output will be placed in the file' out_file
      End
   Return out_level out_file

Initialize:
   fix_name = ''
   root_drive = ''
   os2_base = ''
   mmpm_base = ''
   regressions. = ''
   regressions = 0
   backlevel. = ''
   backlevel = 0
   notfound. = ''
   notfound = 0
   updated. = ''
   updated = 0
   equaled. = ''
   equaled = 0
   multiples = 0
   esc = D2c(27)              /* Escape character */
   crlf = D2c(13) || D2c(10)  /* carriage return + linefeed */
   Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
   Call SysLoadFuncs
   Parse Version . rx_level .
   If rx_level > 4.00 Then objrexx = 1
   Else objrexx = 0
   drive_map = ''
   drive_list = SysDriveMap(,'LOCAL')
   Do i = 1 to Words(drive_list)
      drive = Word(drive_list, i)
      driveinfo = SysDriveInfo(drive)
      If driveinfo = '' | Word(driveinfo, 2) = 0 Then Iterate
      drive_map = drive_map drive
      End
   drive_map = Strip(drive_map)
   Return
