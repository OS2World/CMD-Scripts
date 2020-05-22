/* BOOTD211.CMD for OS/2 2.11 by James K. Beard CIS 71675,566        */
/* Two-disk OS/2 2.11 boot; packs 1.2 MB in A:, 1.1 MB in B:
   Supported on floppy are CHKDSK, FORMAT, FDISK, BACKUP, RESTORE
   Sufficient room remains on B: (if 1.44 MB) for HPFS, your SCSI
   drivers, the IBM Tiny Editor, etc.  Use the procedure in Appendix C
   of the OS/2 manual to backup and restore the worplace shell, or use
   the shareware WPSBACKUP.

   Origially inspired by MAKEBOOT.CMD version 1.00 by Donald L. Meyer,
   internet:   dlmeyer@uiuc.edu

NOTE:  Version 1.00 was BOOTDISK.CMD; BOOTD210 replaced it.

     This program accepts one parameter:
     "RECONFIGURE" tells program to skip main install, and only do optional
       installation of things like SCSI support, etc.
    Credit due to Morton Kaplon  (73457,437 @ Compuserve) for
    doing the legwork determining which files/drivers were/weren't
    necessary for Donald L. Meyer's 2.0 version, and David Moskowitz's
    article in "OS/2 2.1 Unleashed" (Sams, 1993) pp 57-59. */

'@ECHO OFF' /* Don't echo system commands to screen */

version=1.10 /*  For 2.11, fixes line wrap problems, avoids loading DOS FORMAT.COM  */

/*  Initializations */

CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' /* Install the RexxUtil functions */
CALL SysLoadFuncs /*  Get them all; call SysDropFuncs on EXIT  */

CALL SysCls  /* Clear screen; "dots" won't work if screen scrolls */

IF (\(SysOS2Ver()='2.11')) THEN DO /* Verify OS/2 2.11 */
   SAY 'Installed OS/2 version is 'SysOS2Ver()
   SAY 'BOOTDISK/CMD 'version' is tested only for OS/2 2.11'
   SAY 'Continue?'
   IF y_or_n()='N' THEN DO
      CALL SysDropFuncs
      exit
      END  /* DO */
   END /* DO */

/* Parse arguments */
/* Copy command line argument string to "all_args" & convert to upper case */
PARSE UPPER ARG all_args
CALL parse_all_args(all_args)

CALL find_os2 /* Find OS/2 (define "instfrom," usually 'C:' */

SAY 'BOOT211.CMD 'version' for OS/2 2.11'
SAY 'Utility to create two OS/2 2.11 Boot Diskettes for drives A: and B:'

/* Echo usage instructions to screen */
SAY 'Syntax:   BOOTD211 [RECONFIGURE]'
SAY '        Optional parameter RECONFIGURE => Reconfigure existing boot disk.'

CALL find_config /* Determine type: ISA - EISA, or MCA - PS/2; HPFS;CD_ROM=Y or N */

/* Begin creating the two boot disks */
/* Files from Disk 1, copied to A:\*.* */
Disk1_to_temp = 'SYSINSTX.COM' /* Disk 1 to temp. dir*/
boot_files='OS2KRNL' 'OS2LDR' 'OS2LDR.MSG' /* Root. dir to A: */
Disk2_to_A='KEYBOARD.DCP' /* Smaller KEYBOARD.DCP than on HD */
/* IF (type='1') THEN Disk2_to_A=Disk2_to_A' IBM1S506.ADD' */

IF (ReConfig='N') THEN DO /* No "RECONFIG" command line option */
  temp_dir=instfrom'\OS2\INSTALL\BOOTDISK'
  CALL SysFileTree temp_dir'\SYSINSTX.COM', 'file', 'FO'
/*****************************************************************/
/*** Copy necessary files from Service Pack DISK 0 and DISK 1 ****/
   if file.0='0' THEN DO /* If SYSINSTX.COM isn't on C:, use Service Pack disks*/
      CALL SysFileTree temp_dir, 'file', 'DO'  /* If not alread there ... */
      if file.0=0 THEN CALL SysMkDir temp_dir /* Create scratch subdirectory */

/* Copy files from Service Pack Disk 1 into temporary subdirectory */
      CALL copy_from_a temp_dir 'SP_DISK_1' 'SYSINSTX.COM' Disk1_to_temp

/* Copy specific files from Disk 2 into temporary subdirectory */
      CALL copy_from_a temp_dir 'SP_DISK_2' 'KEYBOARD.DCP' Disk2_to_A
      CALL evict_disk /* Make sure OS/2 2.11 Service Pack disks are out of A: */
   END /* DO */
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

   CALL root_to_A boot_files /* Copy boot files to A: */

   source=temp_dir
   extension='' /* Null strings disrupt argument transfer--use globals */
   CALL copy_to_boot 'A:' Disk2_to_A ; /* Copy boot files to A: */

/* Copy the DLL's to B:\DLL */

/* Begin by making the directory B:\DLL */
   CALL SysFileTree 'B:\DLL', 'file', 'DO' /* If not alread there ... */
   IF file.0=0 THEN CALL SysMkDir 'B:\DLL' /* Create B:\DLL */

   dll_list='ANSICALL BKSCALLS BMSCALLS BVHINIT BVSCALLS DOSCALL1 KBDCALLS MOUCALLS MSG NAMPIPES NLS OS2CHAR QUECALLS SESMGR VIOCALLS'
   IF hpfs='Y' THEN dll_list=dll_list UHPFS
   IF cd_rom='Y' then dll_list=dll_list UCDFS


   source=instfrom'\OS2\DLL'
   extension='.DLL'
   CALL copy_to_boot 'B:\DLL' dll_list

   CALL getconfig /* Get the *.ADD and *.IFS files from user's C:\CONFIG.SYS */
/* Output of "getconfig" is lists A_nfiles B_nfiles, stem variable C_files */

/* Copy SP installation disk files from temporary directory to A: */
   source=temp_dir
   extension=''
   CALL copy_to_boot 'A:' Disk2_to_A

/* Set up file lists for A: and B: */
   A_list='IBM'type'FLPY.ADD IBM1S506.ADD OS2DASD.DMD CLOCK0'type'.SYS COUNTRY.SYS IBMINT13.I13 KBD0'type'.SYS PRINT0'type'.SYS SCREEN0'type'.SYS'
   B_list='OSO001H.MSG OSO001.MSG'
   AB_list='CMD.EXE CHKDSK.COM FDISK.COM FORMAT.COM BACKUP.EXE RESTORE.EXE'
   size_A=WORD(SysDriveInfo('A:'),3) /* Drive A: a 1.44 MB? */
   if size_A>1400000 then DO
      A_list=A_list AB_list /* Concatenate the file lists */
      big_drive='A'
      END /* DO */
   else DO
      B_list=B_list AB_list /* The B: drive better be 1.44MB if A: isn't */
      big_drive='B'
   END /* DO */

/* Copy files from "instfrom" drive to A: */
   IF cd_rom='Y' THEN A_list=A_list OS2CDROM.DMD /* Add Microsoft CD-ROM extensions */
   A_list=A_list A_nfiles /* Concatenate the lists */

   source='' /* Source is various subdirectories in \OS2 */
   extension='' /* Extensions are supplied in file list */
   CALL copy_to_boot 'A:' A_list

/* Copy files from "instfrom" drive to B: */
   B_list=B_list B_nfiles

   CALL copy_to_boot 'B:' B_list /* "source" and "extension" are null strings */

/**********************/
   CALL saywrap('Do you want to LEAVE the temporary directory 'temp_dir' for future')
   CALL saywrap('runs of BOOTDISK/CMD without the OS/2 2.11 Service Pack diskettes?')
   IF y_or_n()='N' THEN DO
      SAY 'Delete the temporary directory 'temp_dir
      SAY 'Are you sure?'
      IF y_or_n()='N' THEN LEAVE
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
DriveInfo=SysDriveInfo('A:') /* Give space on A:, too */
disk_space_A=WORD(DriveInfo,2)
DriveInfo=SysDriveInfo('B:')
disk_space_B=WORD(DriveInfo,2)

/* Get co-processor emulator size */
CALL SysFileTree instfrom'\OS2\DLL\NPXEMLTR.DLL', 'file_c', 'F'
math_size=WORD(file_c.1,3)

/* Get SCSI driver data */
CALL SysFileTree instfrom'OS2SCSI.DMD', 'file_s', 'FS'
scsi_size=WORD(file_s.1,3)
scsi_filespec=WORD(file_s.1,5)

/* Check for Tiny Editor */
CALL saywrap('Looking for Tiny Editor IBM freeware ...')
DriveMap=SysDriveMap('C:', 'LOCAL') /* Find all attached hard drives */

DO i=1 to WORDS(DriveMap) /* Loop over the number of drives */
  ed_from=WORD(DriveMap,i)
  CALL SysFileTree ed_from'\THELP.HLP', 'file_e', 'FS' /* Locate TinyEd */
  IF (file_e.0>0) THEN LEAVE /* Define "instfrom" */
  END
IF file_e.0>0 THEN DO
  editor='Y'
  t_hlpsize=WORD(file_e.1,3) /* HELP file size */
  t_hlpspec=WORD(file_e.1,5) /* HELP file pathname */
  sp=LASTPOS('\',t_hlpspec) /* Find pathname for T2.EXE */
  t_exespec=SUBSTR(t_hlpspec,1,sp)'T2.EXE'
  CALL SysFileTree t_exespec, 'file_e', 'F' /* Find executable */
  t_exesize=WORD(file_e.1,3) /* T2.EXE file size */
  t_size=t_hlpsize+t_exesize
  END
ELSE
  editor='N'

/* Start interactive configuration process */
CALL saywrap('Drive A: space is             'disk_space_A' bytes.')
CALL saywrap('SCSI driver size is           'scsi_size' bytes.')
CALL saywrap('Drive B: space is             'disk_space_B' bytes.')
CALL saywrap('Co-processor emulator size is 'math_size' bytes.')
IF editor='Y' THEN
  CALL saywrap('Editor size is                't_size' bytes.')

IF (disk_space_B<math_size) & (file_c.0=1) THEN DO
  CALL saywrap(' There isn''t enough space to install coprocessor emulator.')
  ismath='N'
END
ELSE DO
  CALL saywrap('Will this disk be used on machines without math coprocessors?')
  ismath=y_or_n()
  END

IF ismath='Y' THEN DO /* Install emulator; keep track of disk space */
  'COPY 'instfrom'\OS2\DLL\NPXEMLTR.DLL B:\DLL\*.* /B /V >NUL'
  DriveInfo=SysDriveInfo('B:')
  disk_space_B=WORD(DriveInfo,2)
  CALL saywrap('Remaining disk space on B: is 'disk_space_B' bytes.')
  END

IF (disk_space_A < scsi_size) & (file_s.0='0') THEN DO
  CALL saywrap('There isn''t enough space to install the SCSI Driver...')
  scsi='N'
  END
ELSE DO
  CALL saywrap('Will you need the SCSI Driver installed?')
  scsi=y_or_n()
  END

IF scsi='Y' THEN DO /* Add on SCSI driver size */
  'COPY 'instfrom'\OS2\OS2SCSI.DMD A:\*.* /B /V >NUL' /* Copy the SCSI driver */
  DriveInfo=SysDriveInfo('A:')
  disk_space_A=WORD(DriveInfo,2)
  CALL saywrap('Remaining disk space on A: is 'disk_space_A' bytes.')
  END

IF big_drive='A' THEN
   space_ed=disk_space_A
else
   space_ed=disk_space_B

IF editor='Y' THEN DO
  IF (space_ed < t_size) THEN DO
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
  'COPY 't_exespec big_drive':\edit.exe /B /V >NUL' /* Rename it EDIT.EXE */
  'COPY 't_hlpspec big_drive':\*.* /B /V >NUL'
  END

CALL create_config_sys big_drive hpfs type scsi cd_rom /* Create A:\CONFIG.SYS dynamically */

CALL saywrap('Boot Diskettes have been created.')

DriveInfo=SysDriveInfo('A:') /* Give space on A:, too */
disk_space_A=WORD(DriveInfo,2)
CALL saywrap('Remaining disk space on A: is 'disk_space_A' bytes.')

DriveInfo=SysDriveInfo('B:') /* Give remaining space on B: */
disk_space_B=WORD(DriveInfo,2)
CALL saywrap('Remaining disk space on B: is 'disk_space_B' bytes.')

The_End:
CALL SysDropFuncs
EXIT
/************************************************************/
/************* Utility functions and procedures *************/
/************************************************************/
parse_all_args: PROCEDURE EXPOSE ReConfig; ARG arg_string

IF (WORD(arg_string,1)='RECONFIGURE') THEN
  ReConfig='Y'
ELSE
  ReConfig='N'

RETURN
/************************************************************/
find_os2: PROCEDURE EXPOSE instfrom /*Find the drive where OS/2 is installed */
DriveMap=SysDriveMap('C:', 'LOCAL') /* Find all attached hard drives */
DO i=1 TO WORDS(DriveMap) /* Loop over the number of drives */
  CALL SysFileTree WORD(DriveMap,i)'\OS2\HELP.CMD', 'file' /*Locate OS/2 */
  IF (file.0='1') THEN instfrom=WORD(DriveMap,i) /* Define "instfrom" */
  END
RETURN
/************************************************************/
find_config: PROCEDURE EXPOSE instfrom type hpfs cd_rom /* Determine configuration */
call SysFileTree instfrom'\OS2\KBD01.SYS', 'file', 'FO' /* Check: [E]ISA or MCA? */
IF (file.0='1') THEN
  type=1 /* ISA or EISA */
ELSE
  type=2 /* MCA or PS/2 */

call SysFileTree instfrom'\OS2\HPFS.IFS', 'file', 'FO' /* Check: HPFS? */
IF file.0=1 THEN
  hpfs='Y'
ELSE
  hpfs='N'

call SysFileTree instfrom'\OS2\CDFS.IFS', 'file', 'FO' /* Check:  CD-ROM? */
IF file.0>0 then
   cd_rom='Y'
ELSE
   cd_rom='N'

/* SAY 'Type' type', HPFS =' hpfs', CD_ROM =' cd_rom */
RETURN
/************************************************************/
copy_from_a: PROCEDURE; ARG temp_dir id filename file_list /* Copy files from A: */
/* temp_dir  Temporary directory to which files are copied */
/* id         Disk ID; 'SP_DISK_1' or 'SP_DISK_2' */
/* filename   File on OS/2 disk whose existence identifies it */
/* file_list  List of files to copy */
CALL get_inst_disk id filename /* Get the OS/2 2.11 disk */
CALL get_files_a temp_dir id file_list /* Copy the files to the temp subdir */
RETURN
/************************************************************/
get_inst_disk: PROCEDURE; ARG id filename /* Get OS/2 disk in A: */
/* id         Disk ID; 'SP_DISK_1' or 'SP_DISK_2' */
/* filename   File on OS/2 disk whose existence identifies it */
k=0
DO WHILE k=0
  CALL BEEP 392, 250 /* Beep 392 Hz for 250 milliseconds */
  if(id='SP_DISK_1') THEN
    SAY 'Insert OS/2 2.1 Service Pack Disk 1 in drive A:.'
  ELSE
    SAY 'Insert OS/2 2.1 Service Pack Disk 2 in drive A:.'
  'PAUSE'
  CALL SysFileTree 'A:\'filename, 'file', 'FO' /* Check for filename */
  k=file.0 /* Try again until filename is found */
  END
RETURN
/************************************************************/
get_files_a: PROCEDURE; ARG temp_dir id file_list
/* Copy files from OS/2 disk in A: */
/* temp_dir  Temporary directory to which files are copied */
/* id         Disk ID; 'SP_DISK_1' or 'SP_DISK_2' */
/* file_list  List of files to copy */
CALL SysFileTree temp_dir, 'file', 'DO' /* Make sure directory exists */
IF file.0=0 THEN DO
   SAY 'Error in "get_files," directory 'temp_dir' does not exist.'
   CALL SysDropFuncs
   EXIT
   END /* DO */
k=SysCurPos() /* Find row of cursor on screen */
k=WORD(k,1)
IF id='SP_DISK_1' THEN
  message='Copying files from OS/2 2.1 Service Pack Disk 1'
ELSE
  message='Copying files from OS/2 2.1 Service Pack Disk 2'
SAY message
dot_pos=LENGTH(message)
n=WORDS(file_list)
DO i=1 TO n /* Loop over file names in "file_list" */
  'COPY A:\'WORD( file_list, i) temp_dir' /B /V >NUL'
  CALL SysCurPos k, dot_pos+i /* Echo a dot for each file */
  SAY '.'
END
RETURN
/************************************************************/
evict_disk: PROCEDURE
/* Evicts OS/2 2.11 Service Pack disk from A: before writing to A: */
/* filename  File name that identifies an Service Pack disk */
k=1
DO FOREVER /* Get the OS/2 2.11 Service Pack disks out of A: */
   sdi=SysDriveInfo('A:')
   IF sdi='' THEN LEAVE /* Disk not ready */
   IF \(WORD(sdi,4)='SP') THEN LEAVE /* OS/2 SP disk label is "SP DISK <n>' */
   CALL BEEP 392, 250
   SAY 'Please remove OS/2 2.1 Service Pack Disk from Drive A:,'
   SAY 'Then insert OS/2 2.11 BOOT DISKS [To Be Created] in drives A: and B:.'
   'PAUSE'
   END /* DO */
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
/* Begin by cleaning off A:\ and B:\ */

tempfile=SysTempFileName('TEMP????') /* Write response file for DEL */
CALL LINEOUT tempfile, '', 1 /* Open the file, write blank line */
CALL LINEOUT tempfile, 'Y'
CALL LINEOUT tempfile /* Close the file */

CALL SysFileTree 'A:\*.', 'file', FO
IF file.0>0 THEN DO
   'ATTRIB -h -s -r A:\*' /* Remove pesky hidden, system, read-only attributes */
   'DEL A:\*. > NUL <' tempfile /* Delete kernel and loader files */
   END /* DO */

CALL SysFileTree 'A:\*.MSG', 'file', FO
IF file.0>0 THEN
   'DEL A:\*.MSG > NUL <' tempfile /* Delete OS2LDR.MSG */

CALL SysFileTree 'A:\CONFIG.SYS', 'file', FO
IF file.0>0 THEN
   'DEL A:\CONFIG.SYS > NUL <' tempfile /* Delete CONFIG.SYS */

CALL SysFileTree 'B:\*.EXE', 'file', FO
IF file.0>0 THEN
   'DEL B:\*.EXE'

CALL SysFileTree 'B:\*.COM', 'file', FO
IF file.0>0 THEN
   'DEL B:\*.COM'

CALL SysFileTree 'B:\*.IFS', 'file', FO
IF file.0>0 THEN
   'DEL B:\*.IFS'

CALL SysFileDelete tempfile
'LABEL A:OS210BOOT_A'
'LABEL B:OS210BOOT_B'
RETURN
/************************************************************/
root_to_a: PROCEDURE EXPOSE instfrom temp_dir; ARG file_list
/* Copies HSR files on C:\ to A:\, removes HSR attributes
NOTE:  EAs are stripped from files before copying to A: */
/* file_list  List of files to copy */
/****Argument passed as variable****/
/* instfrom   Hard drive where OS/2 2.11 is installed */

k=SysCurPos() /* Move the cursor to column dot_pos */
k=WORD(k,1)
IF k>21 THEN k=0 /* End-around, don't scroll */

message='Installing Boot Files on new BOOT DISKETTE A'
dot_pos=LENGTH(message)
CALL saywrap(message)
n=WORDS(file_list)
DO i=1 TO n
   CALL SysCurPos k+1, 0 /* Echo file names to screen */
   SAY '                                                     ' /* Erase line */
   CALL SysCurPos k+1, 0 /* Echo file names to screen */
   file_name=WORD(file_list,i)
   CALL saywrap(file_name)

   'XCOPY 'instfrom'\'file_name 'A:\  /V /H /T >NUL' /* System files to A: */
   'ATTRIB -h -s -r A:\*' /* Remove attributes */
   CALL SysCurPos k, dot_pos+i /* Echo dots */
   SAY '.'
   END
CALL SysCurPos k+1, 0 /* Clear last file name */
SAY COPIES(' ',53)
CALL SysCurPos k+1, 0 /* Leave cursor on beginning of blank line */
DROP file_list /* Retrieve memory used by file_list */
RETURN
/************************************************************/
copy_to_boot: PROCEDURE EXPOSE source extension instfrom; ARG ab file_list
/* ab         Destination drive, 'A:' or 'B:' */
/* file_list  List of files to copy */
/****Arguments passed as variables to allow null strings****/
/* source     Source path, or blank string '' */
/* extension  Extension, such as '.DLL' to be applied to all file names */
/* instfrom   Hard drive where OS/2 2.11 is installed */

k=SysCurPos() /* Move the cursor to column dot_pos */
k=WORD(k,1)
IF k>21 THEN k=0 /* End-around, don't scroll */

message='Installing Files on new BOOT DISKETTE 'ab
dot_pos=LENGTH(message)
CALL saywrap(message)
n=WORDS(file_list)
DO i=1 TO n
   CALL SysCurPos k+1, 0 /* Echo file names to screen */
   SAY COPIES(' ',53) /* Erase line */
   CALL SysCurPos k+1, 0 /* Echo file names to screen */
   file_name=WORD(file_list,i)extension
   CALL saywrap(file_name)

   CALL get_filespec(file_name)

   'COPY 'filespec ab'\*.* /B /V >NUL' /* System files to ab: */
   CALL SysCurPos k, dot_pos+i /* Echo dots */
   SAY '.'
   END
CALL SysCurPos k+1, 0 /* Clear last file name */
SAY COPIES(' ',53)
CALL SysCurPos k+1, 0 /* Leave cursor on beginning of blank line */
DROP file_list /* Retrieve memory used by file_list */
RETURN
/************************************************************/
get_filespec:  PROCEDURE EXPOSE instfrom source filespec; ARG filename
IF source='' THEN DO
   rc=SysFileTree(instfrom'\OS2\'filename,'file','FSO')
   IF (rc>0 | file.0=0) THEN DO
      SAY 'File 'filename' not found in' instfrom'\OS2'
      CALL SysDropFuncs
      EXIT
      END /* IF */
   filespec=file.1
   END /* DO */
ELSE
   filespec=source'\'filename
RETURN
/************************************************************/
getconfig: PROCEDURE EXPOSE A_nfiles B_nfiles C_files.;
/* Get the *.ADD and *.IFS files from user's C:\CONFIG.SYS */
'TYPE C:\CONFIG.SYS | RXQUEUE' /* Put CONFIG.SYS in current queue */
C_files.0=0 /* Initialize stem variable */
A_nfiles=''
B_nfiles=''
do ii=1 to Queued() /* Process the lines */
   Parse Pull OneLine
   call parseit(OneLine)
   IF \(Drive='') THEN DO
      i=C_files.0+1 /* Increment the count */
      C_files.i=NewLine  /* Save a line for CONFIG.SYS */
      C_files.0=i /* Save the count in stem variable */

      IF Drive='A' THEN /* New file, line for CONFIG.SYS */
         A_nfiles=A_nfiles FileName /* Add the file name to the list */
      else
         B_nfiles=B_nfiles FileName
   END /* DO */
end /* do */
RETURN
/************************************************************/
parseit: PROCEDURE EXPOSE NewLine FileName Drive; ARG aline
/* Parse lines from C:\CONFIG.SYS, make new boot disk CONFIG.SYS line,
return file name and drive to which file is to be copied */
loc_line=STRIP(aline) /* Remove leading and trailing blanks */
select
   when ABBREV(loc_line,'BASEDEV=') then DO /* BASEDEV drivers on A: */
   PARSE VALUE SUBSTR(loc_line,9) WITH loc_file options /* <filespec> <options> */
   FileName=FILESPEC('Name',loc_file) /* File name from command */
   NewLine='BASEDEV='FileName options /* reformatted line */
   Drive=A
   END /* DO */

   when ABBREV(loc_line,'IFS=') then DO /* IFS drivers on B: */
   PARSE VALUE SUBSTR(loc_line,5) WITH loc_file options
   FileName=FILESPEC('Name',loc_file)
   NewLine='IFS=B:\'FileName options
   Drive=B
   END /* DO */

otherwise DO /* All other lines */
   NewLine=''
   FileName=''
   Drive=''
   END /* DO */
end  /* select */

RETURN
/************************************************************/
saywrap: PROCEDURE; PARSE ARG msg /* Erase line, then write to screen */
k=WORD(SysCurPos(), 1) /* Find line number */
IF k>21 THEN DO
  k=0 /* End-around, don't scroll */
  CALL SysCurPos 0, 0
  END
CALL SysCurPos k,0 /* Reposition cursor */
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
create_config_sys: PROCEDURE EXPOSE C_files.; ARG big_drive hpfs type scsi cd_rom
/* Create the CONFIG.SYS dynamically...   */
CALL saywrap('Creating CONFIG.SYS on drive A: ...')
config_file='A:\CONFIG.SYS'
CALL lineout config_file, 'PROTSHELL='big_drive':\CMD.EXE' /* Opens the file */
CALL lineout config_file, 'SET OS2_SHELL='big_drive':\CMD.EXE'
CALL lineout config_file, 'SET RUNWORKPLACE='big_drive':\CMD.EXE'
CALL lineout config_file, 'SET COMSPEC='big_drive':\CMD.EXE'
CALL lineout config_file, 'LIBPATH=.;\;B:\DLL;'
CALL lineout config_file, 'SET PATH=A:\;B:\;B:\DLL;C:\OS2'
CALL lineout config_file, 'SET DPATH=A:\;B:\;B:\DLL'
CALL lineout config_file, 'SET PROMPT=$I[$P]'
CALL lineout config_file, 'BUFFERS=32'
CALL lineout config_file, 'IOPL=YES'
CALL lineout config_file, 'DISKCACHE=64,LW'
CALL lineout config_file, 'MEMMAN=NOSWAP'
CALL lineout config_file, 'PROTECTONLY=YES'
CALL lineout config_file, 'PAUSEONERROR=YES'
CALL lineout config_file, 'CODEPAGE=437,850'
CALL lineout config_file, 'DEVINFO=KBD,US,KEYBOARD.DCP'
CALL lineout config_file, 'SET KEYS=ON'
IF cd_rom='Y' THEN
   CALL lineout config_file, 'DEVICE=OS2CDROM.DMD /Q' /* The one & only DEVICE driver */
CALL lineout config_file, 'rem DEVICE=\TESTCFG.SYS' /*Add if you need it; I don't */
do i=1 to C_files.0 /* Add the BASEDEV drivers & IFSs from C:\CONFIG.SYS, but loaded from A: */
   CALL lineout config_file, C_files.i
end /* do */
CALL lineout config_file  /* Close the file */
RETURN
/************************************************************/
