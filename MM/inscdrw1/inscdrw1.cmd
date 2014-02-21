/*************************************************************/
/* Run this script to copy files to the target directory and */
/* create a new desktop CDRWSEL object eCS1.1                */
/*************************************************************/

/* Prerequisites for the desktop object     */
/* and this cmd file                        */
/* Load RexxUtil DLL                        */
call RxFuncAdd 'SysLoadFuncs' , RexxUtil, 'SysLoadFuncs'
call SysLoadFuncs

env = 'OS2ENVIRONMENT'
Insdir = value('programs',,env)
pgm_dir=Directory()
If insdir='' then insdir = Directory()
   else do
      nop
   end /* do */

crlf	='0d0a'x
exe	='cdrwsel.exe'
Title	='CDRWSel'

Call SysCls
say crlf crlf
say ' This script sets up the desktop object for '||Title
say ' Be sure you are running this from the '||Title||' directory.'||crlf crlf

say ' Press [Y] to continue or [Enter] to quit'||crlf
pull approval
if approval <> 'Y' then exit
say ''

/* Are we in the right program directory?   */
say ' Locating '||exe||'...'||crlf
TestFor=directory()||'\'||exe
CALL SysFileTree TestFor,'List','FO'
if List.0 = 0 then do
   say ' Please run this program from the same directory as the '||exe||' file'||crlf
   say ' Exiting...'||crlf
   exit
end

/* Should we put the program under the correct path? */
Call SysCls
say crlf crlf
say ' This is the recommended installation path : '
say ' ['||insdir||']'crlf crlf

say ' Press [Y] to Accept default directory, [N] to end or give a new path'||crlf
pull approval1
if approval1 = 'N' then exit
if approval1 \= 'Y' then insdir=approval1 
say ''

If substr(insdir,1,1) <> substr(Directory(),1,1) then substr(approval1,1,2) 
'md 'insdir
'copy' pgm_dir||'\*.* '||insdir||'\*.*'   

Setup   ='OBJECTID=<CDRWSel>;'||,
	 'EXENAME=' || Insdir || '\' || exe || ';' ||,
	 'STARTUPDIR=' || Insdir || ';' ||,
         'ICONFILE=' || Insdir || '\cdrwsel.ico;' ||,
         'PROGTYPE=PM;' ||,
         'PARAMETERS=-i -s -vol;' 

rc=' '
call SysCreateObject "WPProgram", Title, "<WP_DESKTOP>", Setup, 'Update'
/* Check if the WPS object was created      */
if rc = 0 then
   say 'Object creation for 'Title ' failed!  rc='||crlf
else
   say 'Object created for' Title||crlf
