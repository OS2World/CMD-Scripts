/***********************************************************************/
/* iris_01.cmd, a script to backup the eCS or OS/2 bootdrive           */
/* Copyright (c) 2003 by Dimitrios Bogiatzoules                        */
/* info at bogiatzoules dot de                                         */
/* This Program is released under the Gnu Public Licence (GPL).        */
/* See the file COPYING for further information.                       */
/*                                                                     */
/*                                                                     */
/* Please change the following values to your needs!                   */
/***********************************************************************/

/***********************************************************************/
/* Where should the backup be saved? This directory must exist!!       */
/***********************************************************************/
backup_dir='E:\backup\zip'

/***********************************************************************/
/* You might change this value to 0 to prevent loging the saved files  */
/* The logfile will be placed into the backup_dir above.               */
/***********************************************************************/
verbose=1

/***********************************************************************/
/* ATTENTION:                                                          */
/* In some cases this script may not find the right bootdrive!         */
/* Please insert the right value below.                                */ 
/***********************************************************************/
bootdrive=''

/***********************************************************************/
/* End of user data                                                    */
/*                                                                     */
/*                                                                     */
/* Do some basics ...                                                  */
/***********************************************************************/
'@ECHO OFF'
CALL RxFuncAdd "SYSLoadFuncs","RexxUtil","SYSLoadFuncs"
CALL SYSLoadFuncs
pgm_version='0.1'

/***********************************************************************/
/* Set some colors, thanx to Dmitry A.Steklenev for the inspiration    */
/* enable ANSI extended screen and keyboard control                    */
/***********************************************************************/
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

/***********************************************************************/
/* Start message                                                       */
/***********************************************************************/
SAY color.gray  || 'Thank you for using '|| color.magenta || 'Iris' ||,
color.gray || ', a backup tool for your eCS ord OS/2 bootdrive.'
SAY color.cyan || 'Version 'pgm_version || color.gray || ', 15.08.2003.'
SAY color.gray || 'This Program is released under the Gnu Public Licence',
|| '(GPL).'
SAY 'See the file COPYING for further information.'
SAY color.gray  || 'Copyright (c) 2003 by '|| color.white ||,
'Dimitrios Bogiatzoules'

/***********************************************************************/
/* create the name of the backup file, using the date                  */
/* File name format: backup_YYYY_MM_DD.zip                             */
/***********************************************************************/
td=DATE(S)
bu_name='backup_'SUBSTR(td,1,4)'_'SUBSTR(td,5,2)'_'SUBSTR(td,7,2)'.zip'

/***********************************************************************/
/* check if that files already exists; if so exit emediatly.           */
/* This is done to prevent overwriting old backups.                    */
/***********************************************************************/
cmpl_bu_name=backup_dir'\'bu_name
rc=SysFileTree(cmpl_bu_name,'result.')
if result.0=1 THEN
  DO
  SAY
  SAY color.red || 'ATTENTION:'
  SAY color.gray ||'A backup file with the name 'bu_name' exists already.' 
  SAY 'Please remove it and re-execute iris.cmd!'
  SAY
  CALL BEEP 500,50
  CALL BEEP 1000,50
  CALL BEEP 500,50
  CALL BEEP 1000,50
  CALL BEEP 500,50
  CALL BEEP 1000,50
  CALL BEEP 500,50
  CALL BEEP 1000,50
  PAUSE
  EXIT
  END

/***********************************************************************/
/* query the bootdrive  (didn't use SysBootdrive 'cause of OREXX)      */
/***********************************************************************/
IF bootdrive='' THEN 
  DO
  path_to_os2_ini=VALUE(USER_INI,,"OS2ENVIRONMENT")
  bootdrive=FILESPEC(D,path_to_os2_ini)
  END

/***********************************************************************/
/* check if the swapper.dat is placed on the bootdrive and exclude it  */
/***********************************************************************/
config_sys=bootdrive'\config.sys'
call=SysFileSearch('SWAPPATH',config_sys,'result.')
IF SUBSTR(result.1,10,2)=bootdrive THEN
  DO 
  PARSE VALUE result.1 WITH crap1'='swap_path crap1 crap2
  excl_swap=' -x 'swap_path'\swapper.dat'
  END
ELSE excl_swap=''

/***********************************************************************/
/* create the comman line for zip.exe                                  */
/***********************************************************************/
zip_cmd='zip.exe -9rS 'backup_dir'\'bu_name' 'bootdrive'\*.*'
IF verbose=1 THEN 
  DO
  logging=' 2>'backup_dir'\backup_error.log >'backup_dir'\backup.log'
  END
ELSE logging=' 2>nul >nul'
cmd=zip_cmd||excl_swap||logging 

/***********************************************************************/
/* execute the comman line for zip.exe                                 */
/***********************************************************************/
cmd 

/***********************************************************************/
/* say bye!                                                            */
/***********************************************************************/
CALL BEEP 1000,100
SAY ' '
SAY color.red || "Done!" 
EXIT