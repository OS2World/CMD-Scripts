/* moritz.cmd -  a kernel installer*/ 
/* Copyright (c) 2001,2002 by Dimitrios Bogiatzoules 
   info at bogiatzoules dot de */
/* This Program is released under the Gnu Public Licence (GPL).
   See the file COPYING for further information. */
   
/*   New in Version 0.12, 28. June 2002:

   - Now supports undo! Just call the moritz_undo.cmd on the root
     directory.

*/


/*   New in Version 0.11, 12. May 2002:

   - Allow the update of any type of kernel (usefull for updates
     over eCS Fixpak 2

*/

/*   New in Version 0.10, 06. May 2002:

   - Removed some bugs... (thanks to Michel Goyette)
   - Changed the wps-object attribut, to NOT close the window
   - Added some new bugs ;-)
*/


/*   New in Version 0.9, 05. May 2002:

   - Removed some bugs...
   - Only reupload it on Hobbes
   - Added some new bugs ;-)
*/

/*   New in Version 0.8, 04. May 2002:

   - Removed some bugs...
   - Changed the backip directories
   - Did some new code to create better names for the backups
   - Now using bldlevel to find out, which kernel ist installed
   - Added more errorchecking 
   - Support for SMP and UNI provided (?)
   - Check for kernel mismatch W4 -> SMP etc.
   - Added color support, for our eyes only ...
   - Added some new bugs ;-)
*/

/*   New in Version 0.7, 20. January 2002:

   - Removed some bugs...
   - Optimized a little bit
   - Added some new bugs ;-)
*/

/*   New in Version 0.6, 20. July 2001:

   - Removed some bugs...
   - When lxlite is installed, the kernel will be compressed
   - Added some new bugs ;-)
*/

/*   New in Version 0.5, 02. July 2001:

   - Removed some bugs...
   - Now all backups go in to a directory
   - Prepared for backup fuction in future
   - Added some new bugs ;-)
*/

'@ECHO OFF'
CALL RxFuncAdd "SYSLoadFuncs","RexxUtil","SYSLoadFuncs"
CALL SYSLoadFuncs
/* Find some informations out */
pwd=DIRECTORY()                /* directory where we are */
my_drive=FILESPEC(D,pwd)       /* drive where we are */
boot_drv=SysBootDrive()        /* find the bootdrive out */
lxlite_path=SysSearchPath('PATH', 'LXLITE.EXE')
unzip_path=SysSearchPath('PATH', 'UNZIP.EXE')
/* Set some colors, thanx to Dmitry A.Steklenev an awgetd.cmd ;-) */
/* enable ANSI extended screen and keyboard control */
'@ansi on > nul'
color.brown   = "1B"x"[0;33m"
color.red     = "1B"x"[1;31m"
color.green   = "1B"x"[1;32m"
color.yellow  = "1B"x"[1;33m"
color.blue    = "1B"x"[1;34m"
color.magenta = "1B"x"[1;35m"
color.cyan    = "1B"x"[1;36m"
color.white   = "1B"x"[1;37m"
color.gray    = "1B"x"[0m"

PARSE ARG kernelfile           /* parse the arguments */
'@ECHO OFF'
SAY color.gray  || "Thank you for using "|| color.magenta || "Moritz" || color.gray || ", the OS/2 and eCS kernel installer, " || color.cyan || "version 0.12" || color.gray || ""
SAY 'This Program is released under the Gnu Public Licence (GPL).'
SAY 'See the file COPYING for further information.'
SAY color.gray  || "Copyright (c) 2001, 2002 by "|| color.white || "Dimitrios Bogiatzoules" color.gray || ""
SAY ' '

IF kernelfile="" THEN
   DO
   SAY ' '
   SAY color.red || " ERROR:" || color.gray || ' Kernelfile missing. Please try ''moritz.cmd xxxx.zip'' or drop ''xxxx.zip'''
   SAY '        on the ''Moritz'' WPS Object.'
   EXIT 1 /* Exit with error */
   END
IF  unzip_path='' THEN
  DO
    SAY ' '
    SAY color.red || " ERROR:" || color.gray || ' UNZIP.EXE missing. Please install somewhere in PATH.'
    EXIT 1 /* Exit with error */
  END
file_name=FILESPEC(N,kernelfile)
space=" "
kernel=TRANSLATE(file_name,space,".")
PARSE VAR kernel kernel_filename ext
extension=TRANSLATE(ext)
/* check the extension */
IF extension <>"ZIP" THEN
  DO
    SAY ' '
    SAY color.red || " ERROR:" || color.gray || ' Kernelfile missing. The argument was not a zip file.'
    EXIT 1 /* Exit with error */
  END


SAY ' Analyzing the installed and the new kernel'
/* extract the os2krnl file in pwd */
'unzip -o' kernelfile 'os2krnl 2>nul >nul' 
IF rc <>"0" THEN
  DO
    SAY ' '
    SAY color.red || " ERROR:" || color.gray || ' Wrong zip file. This file does not include a kernel.'
    EXIT 1 /* Exit with error */
  END

/* find the build level of the new kernel out */
'bldlevel os2krnl > kernel.bldl'
rc=STREAM('kernel.bldl','C','OPEN')
dummy=LINEIN('kernel.bldl')
dummy=LINEIN('kernel.bldl')
newsignature=LINEIN('kernel.bldl')
rc=STREAM('kernel.bldl','C','CLOSE')
/*
new_version=SUBSTR(newsignature,24,7)
new_type=SUBSTR(newsignature,34,3)
 */
parse var newsignature . '@#IBM:' new_version '#@_' new_type .
/* find the build level of the system kernel out */
'bldlevel 'boot_drv'\os2krnl > system_kernel.bldl'
rc=STREAM('system_kernel.bldl','C','OPEN')
dummy=LINEIN('system_kernel.bldl')
dummy=LINEIN('system_kernel.bldl')
systemsignature=LINEIN('system_kernel.bldl')
rc=STREAM('system_kernel.bldl','C','CLOSE')
/*
system_version=SUBSTR(systemsignature,24,7)
system_type=SUBSTR(systemsignature,34,3)
 */
parse var systemsignature . '@#IBM:' system_version '#@_' system_type .
'DEL kernel.bldl 2>nul'
'DEL system_kernel.bldl 2>nul'
'DEL os2krnl 2>nul'
say ' The installed kernel is: 'system_version', 'system_type
say ' The new kernel is:       'new_version', 'new_type
IF system_type <> new_type THEN
  DO
    SAY ' '
    SAY color.red || " ERROR:" || color.gray || ' This seems to be a wrong kernel! Please apply this kernel only if you'
    SAY '        know what you are doing!'
    SAY ' '
    END
IF system_version = new_version THEN
  DO
    SAY color.yellow || " WARNING:  " || color.gray || ' You already got the same kernel. Please apply only if the'
    SAY '            existing one was corrupted!'
    SAY ' '
  END
IF system_version > new_version THEN
  DO
    SAY color.yellow || " WARNING:  " || color.gray || ' You already got a newer kernel, but you can downgrade if you want!.'
    SAY ' '
  END
SAY ' Shall I realy install? Press any key to continue or ctrl-c to stop!'
PAUSE

/* If the Kernel_Backup directory does not exist, then just create it! */
CALL sysfiletree boot_drv'\OS2\ARCHIVES\Kernel_Backup',Kernel_Backup_exists
IF Kernel_Backup_exists.0=0 THEN 
DO
SAY ' Creating the backup directory in 'boot_drv'\OS2\ARCHIVES\Kernel_Backup'
'MKDIR 'boot_drv'\OS2\ARCHIVES\Kernel_Backup 2>nul >nul'
END
/* And now for something completely different! */
'@ECHO OFF'
SAY ' Creating the kernel backup directories ...'
'MKDIR 'boot_drv'\OS2\ARCHIVES\Kernel_Backup\'system_version '2>nul >nul'
'MKDIR 'boot_drv'\OS2\ARCHIVES\Kernel_Backup\'system_version'\trace  2>nul >nul'
SAY ' Archiving the system files ...'
'ATTRIB -r -s -h 'boot_drv'\os2krnl  >nul'
'ATTRIB -r -s -h 'boot_drv'\os2ldr  >nul'
'COPY 'boot_drv'\os2krnl' boot_drv'\OS2\ARCHIVES\Kernel_Backup\'system_version ' 2>nul >nul'
'COPY 'boot_drv'\os2ldr' boot_drv'\OS2\ARCHIVES\Kernel_Backup\'system_version ' 2>nul  >nul'
SAY ' Unziping the kernel files ...'
'unzip.exe -o 'kernelfile ' 2>nul  >nul'
SAY ' Trying to pack the kernel (only if lxlite is found!)'
IF \(lxlite_path ='') THEN 'lxlite.exe os2krnl '
SAY ' Now copying the new files ...'
'COPY os2krnl' boot_drv'\ 2>nul  >nul'
'COPY os2ldr' boot_drv'\ 2>nul  >nul'
'DEL os2krnl  >nul'
'DEL os2ldr  >nul'
'ATTRIB +r +s +h 'boot_drv'\os2krnl  >nul'
'ATTRIB +r +s +h 'boot_drv'\os2ldr  >nul'
/* create the undo batch file  */
mo_undo=boot_drv'\moritz_undo.cmd'
rc=STREAM(mo_undo,"C","OPEN")
call lineout mo_undo,'@REM ****************************************************************'
call lineout mo_undo,'@REM * Restore batch file created by moritz.cmd                     *'
call lineout mo_undo,'@REM * Copyright (c) 2001,2002 by Dimitrios Bogiatzoules            *'
call lineout mo_undo,'@REM * info at bogiatzoules dot de                                  *'
call lineout mo_undo,'@REM * This Program is released under the Gnu Public Licence (GPL). *'
call lineout mo_undo,'@REM * See the file COPYING for further information.                *'
call lineout mo_undo,'@REM ****************************************************************'
call lineout mo_undo,'@REM * Be carefull: This file will restore the kernel               *'
call lineout mo_undo,'@REM * to buildlevel: 'system_version'.                                      *'
call lineout mo_undo,'@REM ****************************************************************'
call lineout mo_undo,'@ECHO Restoring the kernel 'system_version'!'
call lineout mo_undo,'ATTRIB -r -s -h 'boot_drv'\os2krnl'
call lineout mo_undo,'ATTRIB -r -s -h 'boot_drv'\os2ldr'
call lineout mo_undo,'COPY 'boot_drv'\OS2\ARCHIVES\Kernel_Backup\'system_version'\os2krnl' boot_drv'\'
call lineout mo_undo,'COPY 'boot_drv'\OS2\ARCHIVES\Kernel_Backup\'system_version'\os2ldr' boot_drv'\'
call lineout mo_undo,'ATTRIB +r +s +h 'boot_drv'\os2krnl'
call lineout mo_undo,'ATTRIB +r +s +h 'boot_drv'\os2ldr'
call lineout mo_undo,'@ECHO Done! Please reboot!'
rc=stream(mo_undo,"C","CLOSE")
SAY ' '
SAY color.yellow || " ATTENTION:" || color.gray || ' You will find the original files saved in:'
SAY '            'boot_drv'\OS2\ARCHIVES\Kernel_Backup\'system_version 
SAY '            Please have also a look in 'pwd', because there are other'
SAY '            files (sym- an tracefiles) and important informations!'
SAY ' '
SAY color.magenta || " REMEMBER: " || color.gray || ' You can restore the old kernel by calling 'mo_undo'!'
SAY ' '
SAY color.red || " Done!" || color.gray ||' Reboot to apply the changes!'


EXIT
