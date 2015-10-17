/* BOOTDISK.CMD for OS/2 2.1 GA by James K. Beard CIS 71675,566        */
/* Two-disk OS/2 2.1 GA boot; packs 1.2 MB in A:, 1.1 MB in B:
   Supported on floppy are CHKDSK, FORMAT, FDISK, BACKUP, RESTORE
   Sufficient room remains on B: (if 1.44 MB) for HPFS, your SCSI
   drivers, the IBM Tiny Editor, etc.  Use the procedure in Appendix C
   of the OS/2 manual to backup and restore the worplace shell, or use
   the shareware WPSBACKUP.

   Modified from MAKEBOOT.CMD version 1.00 by Donald L. Meyer,
   internet:   dlmeyer@uiuc.edu

     This program accepts one parameter:
     * "RECON" tells program to skip main install, and only do optional
       installation of things like SCSI support, etc.
    Thanks go out to Morton Kaplon  (73457,437 @ Compuserve) for
    doing the legwork determining which files/drivers were/weren't
    necessary for Donald L. Meyer's 2.0 version, and David Moskowitz's
    article in "OS/2 2.1 Unleashed" (Sams, 1993) pp 57-59. */

'@ECHO OFF' /* Don't echo system commands to screen */

version=1.00

/*  Initializations */

call get_utils /* Install the RexxUtil functions */

IF (\(SysOS2Ver()='2.10')) THEN DO /* Verify OS/2 2.10 */
  SAY 'Installed OS/2 version is 'SysOS2Ver()
  SAY 'BOOTDISK/CMD 'version' is tested only for OS/2 2.10'
  SAY 'Continue?'
  IF y_or_n()='N' THEN EXIT
  END

/* Parse arguments */
/* Copy command line argument string to "all_args" & convert to upper case */
PARSE UPPER ARG all_args
CALL parse_all_args(all_args)

CALL find_os2 /* Find OS/2 (define "instfrom," ususaly 'C:' */

CALL SysCls  /* Clear screen; "dots" won't work if screen scrolls */
SAY 'BOOTDISK/CMD 'version' for OS/2 2.1'
SAY 'Utility to create two OS/2 2.1 Boot Diskettes for drives A: and B:'

/* Echo instructions on use to screen */
SAY 'Syntax:   BOOTDISK {RECON}'
SAY '        [RECON = Reconfigure existing boot disk.   *Optional]'
SAY

CALL find_config /* Determine type: ISA - EISA, or MCA - PS/2; HPFS=Y or N */

/* Begin creating the two boot disks */
/* Files from Disk 1, copied to A:\*.* */
inst_files = 'OS2KRNL* OS2LDR OS2LDR.MSG SYSINSTX.COM' /* Disk 0 to temp. dir*/
boot_files='OS2KRNL' 'OS2LDR' 'OS2LDR.MSG' /* Temp. dir to A: */
disk1_to_A='KEYBOARD.DCP SYSINST1.EXE COUNTRY.SYS MOUSE.SYS'
/* IF (type='1') THEN disk1_to_A=disk1_to_A' IBM1S506.ADD' */

IF (ReConfig='N') THEN DO
  temp_dir=instfrom'\OS2\INSTALL\BOOTDISK'
  k=SysFileTree(temp_dir'\SYSINSTX.COM', 'file', 'FO')
/*****************************************************************/
/*** Copy necessary files from installation DISK 0 and DISK 1 ****/
  if file.0='0' THEN DO /* If SYSINSTX.COM isn't on C:, use installation disks*/
    k=SysFileTree(temp_dir, 'file', 'DO') /* If not alread there ... */
    if file.0=0 THEN CALL SysMkDir temp_dir /* Create scratch subdirectory */

/* Copy files from installation disk into temporary subdirectory */
    CALL copy_from_a temp_dir 'inst' 'SYSINSTX.COM' inst_files
    'RENAME 'temp_dir'\OS2KRNL* OS2KRNL' /* Correct this file name */

/* Copy specific files from Disk 1 into temporary subdirectory */
    CALL copy_from_a temp_dir '1' 'FDISK.COM' disk1_to_A
    call evict_disk /* Make sure OS/2 2.1 disks are out of A: */
    END
/*****************************************************************/
/******************* Create the boot disks ***********************/

  CALL saywrap('Do you want to format the floppy disks before copying files?')
  IF y_or_n()='Y' THEN
    CALL format_a_b
  ELSE
    CALL label_a_b

/* Install boot track, kernal, loader */
  CALL saywrap('Installing boot track ...')
  temp_dir'\SYSINSTX A: >NUL' /* Boot track */

  k=WORDS(disk1_to_A) /* Add Disk 1 files to boot file list */
  DO i=1 TO k
    boot_files=boot_files WORD(disk1_to_A,i)
    END
  DROP disk1_to_A

  source=temp_dir
  extension='' /* Null strings disrupt argument transfer--use globals */
  CALL copy_to_boot 'A:' boot_files ; /* Copy boot files to A: */

/* Copy the DLL's to B:\DLL */

/* Begin by making the directory B:\DLL */
  i=SysFileTree('B:\DLL', 'file', 'DO') /* If not alread there ... */
  IF file.0=0 THEN CALL SysMkDir 'B:\DLL' /* Create B:\DLL */

  dll_list='ANSICALL DOSCALL1 NLS BKSCALLS BMSCALLS BVHINIT BVSCALLS KBDCALLS MOUCALLS MSG NAMPIPES OS2CHAR QUECALLS SESMGR VIOCALLS'
  IF hpfs='Y' THEN dll_list=dll_list UHPFS

  source=instfrom'\OS2\DLL'
  extension='.DLL' 
  CALL copy_to_boot 'B:\DLL' dll_list

/* Copy files from "instfrom" drive to A: */
  A_list='CMD.EXE OS2DASD.DMD HARDERR.EXE SYSLEVEL.OS2 IBMINT13.I13 IBM'type'FLPY.ADD CLOCK0'type'.SYS KBD0'type'.SYS PRINT0'type'.SYS SCREEN0'type'.SYS IBM1S506.ADD'
  IF hpfs='Y' THEN A_list=A_list HPFS.IFS

  source='' /* Source is various subdirectories in \os2 */
  extension='' /* Extensions are supplied in file list */
  CALL copy_to_boot 'A:' A_list

/* Copy files from "instfrom" drive to B: */
  B_list='CHKDSK.COM FDISK.COM FORMAT.COM DOS.SYS OSO001H.MSG OSO001.MSG' 'BACKUP.EXE' 'RESTORE.EXE'

  CALL copy_to_boot 'B:' B_list /* "source" and "extension" are null strings */

/**********************/
  CALL saywrap('Do you want to leave the temporary directory 'temp_dir' for future')
  CALL saywrap('runs of BOOTDISK/CMD without the OS/2 2.1 installation diskettes?')
  IF y_or_n()='N' THEN DO
/* Erase the temporary files and remove the temporary directory */
    'ECHO Y | DEL 'temp_dir' >NUL' /* Delete files; echo "Y" to prompt */
    CALL SysRmDir temp_dir /* Delete the subdirectory */
    END
/**********************/

  IF type='2' THEN DO  /* Create ABIOS.SYS if a PS/2 boot disk.  */
    abios_file='A:\ABIOS.SYS'
    CALL lineout abios_file, '', 1
    k=lineout(abios_file)
    DROP abios_file
    CALL saywrap('ABIOS.SYS Created on drive A:.')
    END
  END

/*   The Optionals Area  */
/* CALL SysCls */

/* Get drive space */
DriveInfo=SysDriveInfo('B:')
disk_space=WORD(DriveInfo,2)

/* Get co-processor emulator size */
rc = SysFileTree(instfrom'\OS2\DLL\NPXEMLTR.DLL', 'file_c',,)
math_size=WORD(file_c.1,3)

/* Get SCSI driver data */
rc = SysFileTree(instfrom'OS2SCSI.DMD', 'file_s', 'FS')
scsi_size=WORD(file_s.1,3)
scsi_filespec=WORD(file_s.1,5)

/* Check for Tiny Editor */
CALL saywrap('Looking for Tiny Editor IBM freeware ...')
DriveMap=SysDriveMap('C:', 'LOCAL') /* Find all attached hard drives */

DO i=1 to WORDS(DriveMap) /* Loop over the number of drives */
  ed_from=WORD(DriveMap,i)
  rc=SysFileTree(ed_from'THELP.HLP', 'file_e', 'FS') /* Locate TinyEd */
  IF (file_e.0>0) THEN LEAVE /* Define "instfrom" */
  END
IF file_e.0>0 THEN DO
  editor='Y'
  t_hlpsize=WORD(file_e.1,3) /* HELP file size */
  t_hlpspec=WORD(file_e.1,5) /* HELP file pathname */
  sp=LASTPOS('\',t_hlpspec) /* Find pathname for T2.EXE */
  t_exespec=SUBSTR(t_hlpspec,1,sp)'T2.EXE'
  k=SysFileTree(t_exespec, 'file_e', 'F') /* Find executable */
  t_exesize=WORD(file_e.1,3) /* T2.EXE file size */
  t_size=t_hlpsize+t_exesize
  END
ELSE
  editor='N'

/* Start interactive configuration process */
CALL saywrap('Drive B: space is             'disk_space' bytes.')
CALL saywrap('Co-processor emulator size is 'math_size' bytes.')
CALL saywrap('SCSI driver size is           'scsi_size' bytes.')
IF editor='Y' THEN
  CALL saywrap('Editor size is                't_size' bytes.')

IF (disk_space<math_size) & (file_c.0=1) THEN DO
  CALL saywrap(' There isn''t enough space to install coprocessor emulator.')
  ismath='N'
END
ELSE DO
  CALL saywrap('Will this disk be used on machines without math coprocessors?')
  ismath=y_or_n()
  END

IF ismath='Y' THEN DO /* Install emulator; keep track of disk space */
  'COPY 'instfrom'\OS2\DLL\NPXEMLTR.DLL B:\DLL\*.* /B >NUL'
  DriveInfo=SysDriveInfo('B:')
  disk_space=WORD(DriveInfo,2)
  CALL saywrap('Remaining disk space on B: is 'disk_space' bytes.')
  END

IF (disk_space < scsi_size) & (file_s.0='0') THEN DO
  CALL saywrap('There isn''t enough space to install the SCSI Driver...')
  scsi='N'
  END
ELSE DO
  CALL saywrap('Will you need the SCSI Driver installed?')
  scsi=y_or_n()
  END

IF scsi='Y' THEN DO /* Add on SCSI driver size */
  'COPY 'instfrom'\OS2\OS2SCSI.DMD B:\*.* /B >NUL' /* Copy the SCSI driver */
  DriveInfo=SysDriveInfo('B:')
  disk_space=WORD(DriveInfo,2)
  CALL saywrap('Remaining disk space on B: is 'disk_space' bytes.')
  END

IF editor='Y' THEN DO
  IF (disk_space < t_size) THEN DO
    CALL saywrap('There isn''t enough space to install the Tiny Editor.')
    edits='N'
    END
  ELSE DO
    CALL saywrap('Will you need the Tiny Editor installed?')
    edits=y_or_n()
    END
  END
ELSE
  edits='N'

IF edits='Y' THEN DO
  'COPY 't_exespec' B:\edit.exe /B >NUL' /* Rename it EDIT.EXE */
  'COPY 't_hlpspec' B:\*.* /B >NUL'
  END

CALL create_config_sys hpfs type scsi /* Create A:\CONFIG.SYS dynamically */

CALL saywrap('Boot Diskettes have been created.')

DriveInfo=SysDriveInfo('B:') /* Give remaining space on B: */
disk_space=WORD(DriveInfo,2)
CALL saywrap('Remaining disk space on B: is 'disk_space' bytes.')

DriveInfo=SysDriveInfo('A:') /* Give space on A:, too */
disk_space=WORD(DriveInfo,2)
CALL saywrap('Remaining disk space on A: is 'disk_space' bytes.')

EXIT
/************************************************************/
/************* Utility functions and procedures *************/
/************************************************************/
get_utils: PROCEDURE/* Add the RexxUtil functions */
CALL addit 'SysOS2Ver'
CALL addit 'SysCls'
CALL addit 'SysCurPos'
CALL addit 'SysFileTree'
CALL addit 'SysDriveMap'
CALL addit 'SysDriveInfo'
CALL addit 'SysTextScreenRead'
CALL addit 'SysMkDir'
CALL addit 'SysRmDir'
CALL addit 'SysTempFileName'
CALL addit 'SysFileDelete'
RETURN
/*****/
addit: PROCEDURE; ARG funcname
CALL RxFuncAdd funcname, 'RexxUtil', funcname
RETURN
/************************************************************/
parse_all_args: PROCEDURE EXPOSE ReConfig; ARG arg_string

IF (WORD(arg_string,1)='RECON') THEN
  ReConfig='Y'
ELSE
  ReConfig='N'

RETURN
/************************************************************/
find_os2: PROCEDURE EXPOSE instfrom /*Find the drive where OS/2 is installed */
DriveMap=SysDriveMap('C:', 'LOCAL') /* Find all attached hard drives */
DO i=1 TO WORDS(DriveMap) /* Loop over the number of drives */
  k=SysFileTree(WORD(DriveMap,i)'\OS2\HELP.CMD', 'file',,) /*Locate OS/2 */
  IF (file.0='1') THEN instfrom=WORD(DriveMap,i) /* Define "instfrom" */
  END
RETURN
/************************************************************/
find_config: PROCEDURE EXPOSE instfrom type hpfs /* Determine configuration */
rc=SysFileTree(instfrom'\OS2\KBD01.SYS', 'file',,) /* Check: ISA or MCA? */
IF (file.0='1') THEN
  type=1 /* ISA or EISA */
ELSE
  type=2 /* MCA or PS/2 */

rc=SysFileTree(instfrom'\OS2\HPFS.IFS', 'file', 'FO') /* Check: HPFS? */
IF file.0=1 THEN
  hpfs='Y'
ELSE
  hpfs='N'
RETURN
/************************************************************/
copy_from_a: PROCEDURE; ARG temp_dir id filename file_list /* Copy files from A: */
/* temp_dir  Temporary directory to which files are copied */
/* id         Disk ID; 'INST', '1', or '2' */
/* filename   File on OS/2 disk whose existence identifies it */
/* file_list  List of files to copy */
CALL get_inst_disk id filename /* Get the OS/2 2.1 disk */
CALL get_files_a temp_dir id file_list /* Copy the files to the temp subdir */
RETURN
/************************************************************/
get_inst_disk: PROCEDURE; ARG id filename /* Get OS/2 disk in A: */
/* id         Disk ID; 'INST', '1', or '2' */
/* filename   File on OS/2 disk whose existence identifies it */
k=0
DO WHILE k='0'
  CALL BEEP 392, 250 /* Beep 392 Hz for 250 milliseconds */
  if(id='INST') THEN
    SAY 'Insert OS/2 INSTALLATION DISK in drive A:.'
  ELSE
    SAY 'Insert OS/2 Disk 'id' in drive A:.'
  'PAUSE'
  k=SysFileTree('A:\'filename, 'file',,) /* Check for filename */
  k=file.0 /* Try again until filename is found */
  END
RETURN
/************************************************************/
get_files_a: PROCEDURE; ARG temp_dir id file_list
/* Copy files from OS/2 disk in A: */
/* temp_dir  Temporary directory to which files are copied */
/* id         Disk ID; 'INST', '1', or '2' */
/* file_list  List of files to copy */
k=SysFileTree(temp_dir, 'file', 'DO') /* Make sure directory exists */
IF file.0=0 THEN DO
  SAY 'Error in "get_files," directory 'temp_dir' does not exist.'
  EXIT
  END
k=SysCurPos() /* Find row of cursor on screen */
k=WORD(k,1)
IF id='INST' THEN
  message='Copying files from OS/2 2.1 installation disk'
ELSE
  message='Copying files from OS/2 2.1 Disk 'id
SAY message
dot_pos=LENGTH(message)
n=WORDS(file_list)
DO i=1 TO n /* Loop over file names in "file_list" */
  'COPY A:\'WORD( file_list, i) temp_dir' /B >NUL'
  CALL SysCurPos k, dot_pos+i /* Echo a dot for each file */
  SAY '.'
END
RETURN
/************************************************************/
evict_disk: PROCEDURE
/* Evicts OS/2 2.1 installation disk from A: before writing to A: */
/* filename  File name that identifies an installation disk */
k=1
DO FOREVER /* Get the OS/2 2.1 installation disks out of A: */
  sdi=SysDriveInfo('A:')
  IF sdi='' THEN LEAVE /* Disk not ready */
  IF \(WORD(sdi,4)='DISK') THEN LEAVE /* OS/2 disk label is "DISK <n>' */
  CALL BEEP 392, 250
  SAY 'Insert OS/2 2.1 BOOT DISKS [To Be Created] in drives A: and B:.'
  'PAUSE'
  END
RETURN
/************************************************************/
format_a_b: PROCEDURE /* Format A: and B: */

SAY 'FORMATting the boot disks ...'

tempfile=SysTempFileName('TEMP????') /* Write response file for FORMAT */
CALL LINEOUT tempfile, '', 1 /* Open the file, write blank line */
CALL LINEOUT tempfile, 'N'
CALL LINEOUT tempfile /* Close the file */

'FORMAT A: /V:OS21_BOOT_A <'tempfile' >NUL' /* Format and label the disks */
'FORMAT B: /V:OS21_BOOT_B <'tempfile' >NUL'

CALL SysFileDelete tempfile

RETURN
/************************************************************/
label_a_b: PROCEDURE /* Label A: and B: */
'LABEL A:OS21_BOOT_A'
'LABEL B:OS21_BOOT_B'
RETURN
/************************************************************/
copy_to_boot: PROCEDURE EXPOSE source extension instfrom; ARG ab file_list
/* ab         Destination drive, 'A:' or 'B:' */
/* file_list  List of files to copy */
/****Arguments passed as variables to allow null strings****/
/* source     Source path, or blank string '' */
/* extension  Extension, such as '.DLL' to be applied to all file names */
/* instfrom   Hard drive where OS/2 2.1 is installed */

k=SysCurPos() /* Move the cursor to column dot_pos */
k=WORD(k,1)
IF k>21 THEN k=0 /* End-around, don't scroll */

message='Installing Files on new BOOT DISKETTE 'ab
dot_pos=LENGTH(message)
CALL saywrap(message)
/* CALL SysCurPos k, dot_pos qqqq */
n=WORDS(file_list)
DO i=1 TO n
  CALL SysCurPos k+1, 0 /* Echo file names to screen */
  SAY '                                                     ' /* Erase line */
  CALL SysCurPos k+1, 0 /* Echo file names to screen */
  call saywrap(WORD(file_list,i)extension)

  IF source='' THEN DO
    rc=SysFileTree(instfrom'\'WORD(file_list,i)extension,'file','FSO')
    IF (rc>0 | file.0='0') THEN DO
      SAY 'File 'WORD(file_list,i)extension' not found on C:'
      EXIT
      END
    filespec=file.1
    END
  ELSE
    filespec=source'\'WORD(file_list,i)extension
  'COPY 'filespec ab'\*.* /B >NUL' /* System files to ab: */
  CALL SysCurPos k, dot_pos+i /* Echo dots */
  SAY '.'
  END
CALL SysCurPos k+1, 0 /* Clear last file name */
SAY '                                                     '
CALL SysCurPos k+1, 0 /* Leave cursor on beginning of blank line */
DROP file_list
RETURN
/************************************************************/
saywrap: PROCEDURE; PARSE ARG msg /* Erase line, then write to screen */
k=WORD(SysCurPos(), 1) /* Find line number */
IF k>21 THEN DO
  k=0 /* End-around, don't scroll */
  CALL SysCurPos 0, 0
  END
call syscurpos k,0 /*qqqq*/
DO 3
  SAY COPIES(' ', 75) /* Erase lines */
  END
CALL SysCurPos k, 0 /* Back up and write on blank line */
SAY msg
RETURN
/************************************************************/
y_or_n: PROCEDURE /* Get 'Y' or 'N' from console */
/* Syntax:  response=y_or_n()  */
resp='X'
DO UNTIL (resp='Y' | resp='N')
  CALL saywrap('Y or N?')
  PULL resp
  resp=WORD(resp,1) /* Eliminate leading & trailing blanks, etc. */
  END
RETURN resp
/************************************************************/
create_config_sys: PROCEDURE; ARG hpfs type scsi
/* Create the Config.Sys dynamically...   */
CALL saywrap('Creating CONFIG.SYS on drive A: ...')
config_file='A:\CONFIG.SYS'
IF hpfs='Y' THEN DO
  CALL lineout config_file, 'ifs=a:\hpfs.ifs /c:64', 1 /* Opens the file */
  CALL lineout config_file, 'protshell=sysinst1.exe'
  END
ELSE
  CALL lineout config_file, 'protshell=sysinst1.exe', 1
CALL lineout config_file, 'set os2_shell=a:\cmd.exe'
CALL lineout config_file, 'libpath=.;\;b:\dll;'
CALL lineout config_file, 'set path=a:\;b:\;b:\dll;c:\os2'
CALL lineout config_file, 'set dpath=a:\;b:\;b:\dll'
CALL lineout config_file, 'set prompt=$i[$p]'
CALL lineout config_file, 'buffers=32'
CALL lineout config_file, 'iopl=yes'
CALL lineout config_file, 'diskcache=64,LW'
CALL lineout config_file, 'memman=noswap'
CALL lineout config_file, 'basedev=print01.sys'
CALL lineout config_file, 'basedev=ibm1flpy.add'
IF (type='1') THEN CALL lineout config_file, 'BASEDEV=IBM1S506.ADD'
IF (scsi='Y') THEN CALL lineout config_file, 'BASEDEV=B:\IBMSCSI.DMD'
CALL lineout config_file, 'basedev=ibmint13.i13'
CALL lineout config_file, 'basedev=os2dasd.dmd'
CALL lineout config_file, 'protectonly=yes'
CALL lineout config_file, 'pauseonerror=yes'
CALL lineout config_file, 'codepage=437,850'
CALL lineout config_file, 'devinfo=kbd,us,keyboard.dcp'
CALL lineout config_file, 'device=b:\dos.sys'
CALL lineout config_file, 'device=mouse.sys'
CALL lineout config_file, 'set keys=on'
CALL lineout config_file, 'rem device=b:\os2scsi.sys'
CALL lineout config_file, 'rem device=\testcfg.sys'
CALL lineout config_file  /* Close the file */
RETURN
/************************************************************/
