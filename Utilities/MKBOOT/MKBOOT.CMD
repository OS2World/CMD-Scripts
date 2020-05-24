/*      MAKEBOOT.CMD     version 1.00           Donald L. Meyer */

/* This REXX program is designed to create a bootable OS/2 floppy disk */
/* using both the installation disks and, if possible, files from your OS/2      */
/* directory on the installing machine.  (This speeds things up a bit.) */

/*   This program accepts up to four parameters, which must be in the */
/* following order:         */
/*      * type of machine for the boot disk     2=PS/2    1=IBM Compat. */
/*      * Drive to install on       (A:, B:, ..)     ***Reqd parameter  */
/*      * Drive to look for OS/2 drivers, etc. besides INSTALLATION disks.*/
/*      * "RECON" tells program to skip main install, and only do optional */
/*              installation of things like HPFS.IFS, SCSI support, etc. */
/*              (One limitation is HPFS.IFS will not fit on 1.2mb
disks)        */

/*  Thanks go out to Morton Kaplon  (73457,437 @ Compuserve) for */
/*  doing the legwork determining which files/drivers were/weren't necessary.*/

/* Please send any bug reports or suggestions to:         */
/*  internet:   dlmeyer@uiuc.edu         */

version=1.00
'@ECHO OFF'
PARSE Arg all_args
/*  Initializations */
i=1
type=''
ReConfig=0

/*   Check for special boot disk mode; PS/2 or Non-PS/2  (2,1) */
IF (word(all_args,i)=='1') |  (word(all_args,i)=='2') THEN DO 1
   type=word(all_args,i)
   i = i + 1
END
ELSE NOP

/* If not Target drive specified, exit with Syntax description. */
IF word(all_args,i)=='' THEN DO 1
   SAY 'Syntax:   MAKEBOOT {m} d1: {d2:} {RECON}'
   SAY '        [m:  = Machine type: PS/2=2   Non-PS/2=1   *Optional]'
   SAY '        [d1: = floppy drive to make bootdisk in.    *Required]'
   SAY '        [d2: = hard drive with OS/2 installed.  *Optional]'
   SAY '        [RECON = Reconfigure existing boot disk.  *Optional]'
   SAY '                (Optional Parameters are assumed to match '
   SAY '                 current system configuration if not specified.)'
   EXIT
END
ELSE NOP
        /* Load some advanced functions... */
CALL RxFuncAdd 'SysCurPos', 'RexxUtil', 'SysCurPos'
CALL RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
CALL RxFuncAdd 'SysDriveMap', 'RexxUtil', 'SysDriveMap'
CALL RxFuncAdd 'SysDriveInfo', 'RexxUtil', 'SysDriveInfo'
CALL RxFuncAdd 'SysTextScreenRead', 'RexxUtil', 'SysTextScreenRead'

        /* Finish setting up operating parameters...  */
instto=word(all_args,i)
i=i+1
instfrom=word(all_args,i)
IF (instfrom=='RECON') | (instfrom=='recon') THEN DO 1
   ReConfig=1
   instfrom=''
END
ELSE IF (word(all_args,i+1)=='RECON') | (word(all_args,i+1)=='recon')
THEN ReConfig=1
IF instfrom=='' THEN DO 1
   DriveMap=SysDriveMap('C:', 'LOCAL')
   DO i=1 to Words(DriveMap)
      k=SysFileTree(Word(DriveMap,i)'\OS2\HELP.CMD', 'file',,)
      IF (file.0==1) THEN instfrom=Word(DriveMap,i)
   END
END
ELSE NOP
IF type=='' THEN DO 1
   type=2               /* Assume PS/2 unless proven incorrect. */
   /*   Check if above assumption correct... */
   i=SysFileTree(instfrom'\OS2\KBD01.SYS', 'file',,)
   IF (file.0==1) THEN type=1
   DROP file
END
ELSE NOP

        /* Here we go ..... */
'CLS'
SAY 'Creating an OS/2 v2.0 Boot Diskette on drive 'instto', from drive 'instfrom'.'
SAY '(v'version')'

/* Establish File Lists now that install type has been established.  */
dll_list='ANSICALL BKSCALLS BMSCALLS BVSCALLS BVHINIT DOSCALL1 KBDCALLS MOUCALLS MSG NAMPIPES NLS OS2CHAR QUECALLS SESMGR VIOCALLS'
sys_list='PRINT0'type' KBD0'type' DOS CLOCK0'type' SCREEN0'type
misclist='IBM'type'FLPY.ADD IBMINT13.I13 OS2DASD.DMD INSTALL\SYSLEVEL.OS2 CMD.EXE'
filelist2 = 'HARDERR.EXE SYSINST1.EXE KEYBOARD.DCP COUNTRY.SYS'

IF (ReConfig==0) THEN DO 1
  'MD 'instfrom'\OS2\INSTALL\TEMP'
  SAY
  k=0
  DO WHILE k==0
     CALL BEEP 392, 250
     SAY 'Insert OS/2 INSTALLATION DISK in drive 'instto'.'
     'PAUSE'
     SAY
     k=SysFileTree(instto'\SYSINSTX.COM', 'file',,)
     k=file.0
  END
  filelist1 = 'OS2KRNL* OS2LDR SYSINSTX.COM'

  k=SysCurPos()
  SAY 'Copying necessary files from drive 'instto' .'
  DO i=1 TO WORDS(filelist1)
     CALL SysCurPos word(k,1), 38+i
     COPY instto'\'WORD( filelist1, i)' 'instfrom'\OS2\INSTALL\TEMP >nul'
     SAY '.'
  END
  'REN 'instfrom'\OS2\INSTALL\TEMP\OS2KRNL* OS2KRNL'
  k=1
  DO WHILE k==1
     SAY
     CALL BEEP 392, 250
     SAY 'Insert OS/2 BOOT DISK [To Be Created] in drive 'instto'.'
     'PAUSE'
     k=SysFileTree(instto'\SYSINSTX.COM', 'file',,)
     k=file.0
  END
  filelist1 = 'OS2\INSTALL\TEMP\OS2KRNL OS2\INSTALL\TEMP\OS2LDR OS2LDR.MSG'
  SAY
  k=SysCurPos()
  SAY 'Installing Files on new BOOT DISKETTE .'
  CALL SysCurPos word(k,1), 39
  instfrom'\OS2\INSTALL\TEMP\SYSINSTX 'instto' >nul'
  SAY '.'
  DO i=1 TO WORDS(filelist1)
     CALL SysCurPos word(k,1), 39+i
     COPY instfrom'\'WORD( filelist1,i)' 'instto'\ >nul'
     SAY '.'
  END
  'ECHO Y | DEL 'instfrom'\OS2\INSTALL\TEMP >nul'

  k=SysCurPos()
  SAY 'Installing DLLs .'
  DO i=1 TO WORDS(dll_list)
     COPY instfrom'\OS2\DLL\'WORD(dll_list,i)'.DLL 'instto'\ >nul'
     ERR = SysTextScreenRead(word(k,1)+1,0,7)
     CALL SysCurPos word(k,1)+1, 0
     SAY '                                                      '
        /* If not found, then install is cross-type -- add to files to
get from DISK 1.  */
     IF (ERR=='SYS0002') THEN DO 1
        filelist2=filelist2' 'WORD(dll_list,i)'.DLL'
     END
     CALL SysCurPos word(k,1), 16+i
     SAY .
  END
  k=SysCurPos()
  SAY 'Installing SYSs .'
  DO i=1 TO WORDS(sys_list)
     COPY instfrom'\OS2\'WORD(sys_list,i)'.SYS 'instto'\ >nul'
     ERR = SysTextScreenRead(word(k,1)+1,0,7)
     CALL SysCurPos word(k,1)+1, 0
     SAY '                                                      '
     IF (ERR=='SYS0002') THEN DO 1
        filelist2=filelist2' 'WORD(sys_list,i)'.SYS'
     END
     CALL SysCurPos word(k,1), 16+i
     SAY .
  END
  k=SysCurPos()
  SAY 'Installing misc .'
  DO i=1 TO WORDS(misclist)
     COPY instfrom'\OS2\'WORD( misclist, i)' 'instto'\ >nul'
     ERR = SysTextScreenRead(word(k,1)+1,0,7)
     CALL SysCurPos word(k,1)+1, 0
     SAY '                                                      '
     IF (ERR=='SYS0002') THEN DO 1
        filelist2=filelist2' 'WORD(misclist,i)
     END
     CALL SysCurPos word(k,1), 16+i
     SAY .
  END

  DROP dll_list
  DROP sys_list
  DROP misclist
  k=0
  DO WHILE k==0
     SAY
     SAY 'Insert OS/2 DISKETTE 1 in drive 'instto'.'
     CALL BEEP 392, 250
     'PAUSE'
     k=SysFileTree(instto'\FDISK.COM', 'file',,)
     k=file.0
  END
  SAY
  k=SysCurPos()
  SAY 'Copying Files from OS/2 DISKETTE 1.'
  IF (type==1) THEN filelist2=filelist2' IBM'type'S506.ADD'
  DO i=1 TO WORDS(filelist2)
     CALL SysCurPos word(k,1), 34+i
     COPY instto'\'WORD(filelist2,i)' 'instfrom'\OS2\INSTALL\TEMP >nul'
     SAY .
  END
  k=1
  j=0
  DO WHILE (k>0) | (j==0)
     SAY
     SAY 'Re-Insert the new OS/2 BOOT DISK in drive 'instto'.'
     CALL BEEP 392, 250
     'PAUSE'
     j=SysFileTree(instto'\CMD.EXE', 'file',,)  /* Check presence of
files to verify correct disk.  */
     j=file.0
     k=SysFileTree(instto'\*.BIO', 'file',,)
     k=file.0
  END
  SAY
  SAY 'Copying Files to new BOOT DISKETTE .'
  k=SysCurPos()
  DO i=1 TO WORDS(filelist2)
     CALL SysCurPos word(k,1)-1, 35+i
     COPY instfrom'\OS2\INSTALL\TEMP\'WORD(filelist2,i)' 'instto'\ >nul'
     SAY .
  END
  'ECHO Y | DEL 'instfrom'\OS2\INSTALL\TEMP >nul'
  'RD 'instfrom'\OS2\INSTALL\TEMP'
  IF type==2 THEN DO 1  /* Create ABIOS.SYS if a PS/2 boot disk.  */
     abios_file=instto'\ABIOS.SYS'
     CALL lineout abios_file, '', 1
     k=lineout(abios_file)
     DROP abios_file
     SAY 'ABIOS.SYS Created on drive 'instto'.'
     SAY
  END
END
/*   The Optionals Area  */
'CLS'
SAY
k=SysCurPos()
DriveInfo=SysDriveInfo(instto)
file = SysFileTree(instto'\NPXEMLTR.DLL', 'file',,)
IF (word(DriveInfo,2)<25280) & (file.0==0) THEN DO 1
   SAY ' There isn''t enough space to install coprocessor emulator...'
   SAY
END
ELSE DO 1
   SAY ' Will this disk be used on machines without math coprocessors? [Y/N]'
   i=SysCurPos(word(k,1),72)
   PULL nomath
END
k=SysCurPos()
file = SysFileTree(instto'\OS2SCSI.DMD', 'file',,)
IF (word(DriveInfo,2) < 10462 + ((nomath=='Y')*25280)) & (file.0==0)
THEN DO 1
   SAY ' There isn''t enough space to install the SCSI Driver...'
   SAY
END
ELSE DO 1
   SAY ' Will you need the SCSI Driver installed?  [Y/N]'
   i=SysCurPos(word(k,1),50)
   PULL scsi
END
k=SysCurPos()
file = SysFileTree(instto'\HPFS.IFS', 'file',,)
IF (word(DriveInfo,2)<125466 + ((nomath=='Y') * 25280) + ((scsi=='Y') * 10462)) & (file.0==0) THEN DO 1
   SAY ' There isn''t enough space to install the HPFS File System...'
   SAY
END
ELSE DO 1
   SAY ' Will you need the HPFS File System?  [Y/N]'
   i=SysCurPos(word(k,1),50)
   PULL hpfs
END
SAY
k=SysCurPos()
SAY 'Copying Optional Files.'
CALL SysCurPos word(k,1), 22+(scsi=='Y')
IF (scsi=='Y') THEN COPY instfrom'\OS2\OS2SCSI.DMD 'instto'\ >nul'
SAY '.'
CALL SysCurPos word(k,1), 22+(scsi=='Y')+(hpfs=='Y')
IF (hpfs=='Y') THEN COPY instfrom'\OS2\HPFS.IFS 'instto'\ >nul'
SAY '.'
CALL SysCurPos word(k,1), 22+(scsi=='Y')+(hpfs=='Y')+(nomath=='Y')
IF (nomath=='Y') THEN COPY instfrom'\OS2\DLL\NPXEMLTR.DLL 'instto'\ >nul'
SAY '.'

/* Create the Config.Sys dynamically...   */
SAY 'Creating CONFIG.SYS on drive 'instto'...'
config_file=instto'\CONFIG.SYS'
CALL lineout config_file, 'IFS=HPFS.IFS /CACHE:64', 1
CALL lineout config_file, 'BUFFERS=32'
CALL lineout config_file, 'IOPL=YES'
CALL lineout config_file, 'MEMMAN=NOSWAP'
CALL lineout config_file, 'PROTSHELL=SYSINST1.EXE'
CALL lineout config_file, 'SET OS2_SHELL=CMD.EXE'
CALL lineout config_file, 'DISKCACHE=64,LW'
CALL lineout config_file, 'PROTECTONLY=YES'
CALL lineout config_file, 'LIBPATH=.;\;'
CALL lineout config_file, 'PAUSEONERROR=NO'
CALL lineout config_file, 'CODEPAGE=850'
CALL lineout config_file, 'DEVINFO=KBD,US,KEYBOARD.DCP'
CALL lineout config_file, 'REM DEVINFO=SCR,EGA,VTBL850.DCP'
CALL lineout config_file, 'DEVICE=\DOS.SYS'
CALL lineout config_file, 'REM DEVICE=\MOUSE.SYS'
CALL lineout config_file, 'SET PATH=.;\'
CALL lineout config_file, 'SET DPATH=\;'
CALL lineout config_file, 'SET KEYS=ON'
CALL lineout config_file, 'BASEDEV=PRINT0'type'.SYS'
CALL lineout config_file, 'BASEDEV=IBM'type'FLPY.ADD'
IF (type==1) THEN CALL lineout config_file, 'BASEDEV=IBM1S506.ADD'
IF (scsi=='Y') THEN CALL lineout config_file, 'BASEDEV=IBMSCSI.ADD'
CALL lineout config_file, 'BASEDEV=IBMINT13.I13'
CALL lineout config_file, 'BASEDEV=OS2DASD.DMD'
CALL lineout config_file, 'REM DEVICE=\TESTCFG.SYS'
k=lineout(config_file)
DROP config_file
SAY
SAY 'Boot Diskette has been created.'
EXIT
