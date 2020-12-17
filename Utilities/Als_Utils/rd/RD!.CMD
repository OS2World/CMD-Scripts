/* Automatically invoking REXX for Windows NT.
@ECHO OFF
CLS
SET REXXPROG_NAME=%0
SET REXXPROG_PARMS=
:GET_PARMS
SET REXXPROG_PARMS=%REXXPROG_PARMS% %1 %2 %3 %4 %5 %6 %7 %8 %9
FOR %%A IN ( 1 2 3 4 5 6 7 8 9 ) DO SHIFT
IF NOT '.%1' == '.' GOTO GET_PARMS

REXX %REXXPROG_NAME% %REXXPROG_PARMS%

SET REXXPROG_PARMS=
SET REXXPROG_NAME=
@GOTO EndNT */

/*-----------------------------------------------------------------------+
|                                                                        |
| RD!.CMD - Removes entire HPFS or FAT directory structures.             |
|           Nothing stands in it's way.                                  |
|                                                                        |
+-----------------------------------------------------------------------*/
parse source OS . exname .
parse upper arg target_dir rest '(' opts
rest = strip(rest)
ourRc = 0

if left(target_dir,1) = '"' & right(rest,1) = '"'
   then parse upper arg . '"' target_dir '"' .
target_dir = strip(target_dir,'B','"')

If left(OS,7) == "Windows"
   then delete_opt = "/Q"
   else delete_opt = "/N"

say
if queued()>0 then call drainq
old_location = directory()
parse var old_location target_drive '\' .

if target_dir\='' then do
   if pos(":\",target_dir) > 0 then do
      parse var target_dir target_drive '\' .
      target_drive = strip(target_drive,'B','"')
      target_drive
   end
   call wipeout
end
else do
   say 'RD! - Remove a directory, and all subdirectories.'
   say '      Supports FAT and HPFS.  Exercise Caution...'
   say
   say '    -> SYNTAX: RD! UTILITY'
   say '               RD! OS!2 2.0 Desktop'
end
complete:
parse var old_location old_drive '\' .
old_drive
old_location = directory(old_location)
exit ourRc

bailout:
   ourRc = 8
   signal complete

Wipeout:
/* Under NT we use the REXX command to change directories instead of CD */
newdir = directory(target_dir)

if right(newdir,length(target_dir)) \= target_dir | left(newdir,2) \= target_drive then do
   say '->' time()", Target directory doesn't exist."
   say '->          we ended up in "'||newdir||'" instead of "'||target_dir||'"'
   signal bailout
end
if translate(opts) \= 'OK' then do
   '@DIR *.'
   say directory()
   say 'Are you sure!  (Y or N)'
   parse pull response .
   response = translate(response)
   if left(response,1) \= 'Y'
      then signal bailout
end

say '->' time()', Resetting attributes.'
'@ATTRIB *.* -R -S -H /S 1>NUL 2>NUL'
if rc\=0 then do
   say '  ' time()', Global attribute change failed.'
end
say '  ' time()', Processing directory structure.'
call load_structure
say '  ' time()', Removing files and subdirectories.'
i=1
if words(dir_list)>0 then do i=i+1 until dir_list=''
   parse value dir_list with '"'data'"' dir_list

   /* every so many seconds (30) put out a short progress message */
   busy = time('E')
   if busy > 30 then do
      say '     ' time()', working on' data
      busy = time('R')
   end

   '@ATTRIB "'data'\*.*" -r -h -s 1>NUL 2>NUL'
   '@DEL "'data'\*.*"' delete_opt '1>NUL 2>NUL'  /* delete files */
   '@ATTRIB "'data'" -r -h -s'
   '@RD  "'data'"        1>NUL 2>NUL'  /* remove dir   */
   if rc\=0 then do
      say '  ' time()', Could not remove:('data').'
   end
end
rc = SysFileTree('*',whatsThere,'B')
if whatsThere.0 <> 0
   then '@DEL *.*' delete_opt '1>NUL 2>NUL'           /* delete files in 1st level */
if rc\=0 then do
   say '  ' time()', Some files in 'target_dir' not removed.'
end
newdir = directory("..")            /* surface to base level     */
toRemove = filespec('NAME',target_dir)
'@RD "'toRemove'" 1>NUL 2>NUL'    /* remove 1st level          */
if rc=0 then do
   say '  ' time()', Task complete,' i 'directories removed.'
end
else do
   say '  ' time()', Unable to completely remove' target_dir'.'
end
return

Load_Structure:
file_list='';dir_list=''
/*----------------------------------------------------------+
| /S      - All subdirectories.                             |
| /A:D    - Only show directory names.                      |
| /B      - Don't include directory header or trailer info. |
| 2>NUL   - Send error output (if any) to null.             |
| SORTM   - Sort /R (reverse order) the directory output.   |
| RXQUEUE - Pump it onto the stack for REXX to read.        |
+----------------------------------------------------------*/
'@DIR /S /A:D /B 2>NUL | SORTM /R | RXQUEUE'
do i=1 to queued()
   parse pull data
   if data\='' then dir_list=dir_list '"'data'"'
end
return

drainq:
do queued()
   parse pull .
end
return

/* This is where execution ends for Windows NT.  It's dead code for OS/2
:EndNT */
