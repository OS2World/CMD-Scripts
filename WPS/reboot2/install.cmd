/*
 *      INSTALL.CMD - Installation program for Reboot/2 V1.0 - C.Langanke 1999
 *
 *      Syntax: WPSINST [/Batch]
 *
 *      installs a WPS folder for instant reboot of your
 *      bootable partitions.
 *
 *      OS/2 Bootmanager is required !
 *      Only bootable partitions are processed.
 *
 *      /Batch  - batch install, neither folder or readme is opened.
 */
/* first comment is online help text */

 SIGNAL ON HALT

 TitleLine = STRIP(SUBSTR(SourceLine(2), 3));
 PARSE VAR TitleLine CmdName'.CMD 'Info
 Title     = CmdName Info

 env          = 'OS2ENVIRONMENT';
 TRUE         = (1 = 1);
 FALSE        = (0 = 1);
 Redirection  = '> NUL 2>&1';
 '@ECHO OFF'

 /* OS/2 errorcodes */
 ERROR.NO_ERROR           =  0;
 ERROR.INVALID_FUNCTION   =  1;
 ERROR.FILE_NOT_FOUND     =  2;
 ERROR.PATH_NOT_FOUND     =  3;
 ERROR.ACCESS_DENIED      =  5;
 ERROR.NOT_ENOUGH_MEMORY  =  8;
 ERROR.INVALID_FORMAT     = 11;
 ERROR.INVALID_DATA       = 13;
 ERROR.NO_MORE_FILES      = 18;
 ERROR.WRITE_FAULT        = 29;
 ERROR.READ_FAULT         = 30;
 ERROR.GEN_FAILURE        = 31;
 ERROR.INVALID_PARAMETER  = 87;

 GlobalVars = 'Title CmdName env TRUE FALSE Redirection ERROR.';
 SAY;
 SAY Title;
 SAY;

 /* show help */
 ARG Parm .
 IF (POS('?', Parm) > 0) THEN
 DO
    rc = ShowHelp();
    EXIT(ERROR.INVALID_PARAMETER);
 END;

 /* defaults */
 GlobalVars = GlobalVars 'Partition.';
 fOpenObjects = (POS(Parm, '/BATCH') \= 1);

 /* load rexxutils */
 Call RxFuncAdd 'SysLoadFuncs','REXXUTIL','SysLoadFuncs';
 Call SysLoadFuncs;

 PARSE SOURCE . . CallName
 CallPath = LEFT( CallName, LASTPOS( '\', CallName) - 1);
 IconPath = CallPath;

 /* query system version */
 IF (SysOs2Ver() < 2.40) THEN
    FolderIconBase = IconPath'\folder3';
 ELSE
    FolderIconBase = IconPath'\folder4';

 /* determine bartitions from fdisk */
 rc = QueryPartitions();

 /* create objects */
 CALL CHAROUT, 'Creating folder for reboot objects ... ';
 rc = SysCreateObject( 'WPFolder', 'Reboot/2', '<WP_OS2SYS>',  'CCVIEW=NO;OBJECTID=<WP_REBOOT_FOLDER>;ICONFILE='FolderIconBase'.ICO;ICONNFILE=1,'FolderIconBase'O.ICO;', 'U');
 rc = SysCreateObject( 'WPShadow', 'Reboot/2', '<WP_DESKTOP>', 'SHADOWID=<WP_REBOOT_FOLDER>;OBJECTID=<WP_REBOOT_FOLDER_SHADOW>;', 'U');
 SAY 'Ok.';

 CALL CHAROUT, 'Creating program icons ... ';
 rc = SysCreateObject( 'WPProgram',  'Recreate Reboot Icons ', '<WP_REBOOT_FOLDER>',  'OBJECTID=<WP_REBOOT_RECREATE>;EXENAME='CallName';PARAMETERS=/BATCH;PROGRAMTYPE=WINDOWABLEVIO;MAXIMIZED=YES;NOAUTOCLOSE=YES;', 'U');
 rc = SysCreateObject( 'WPProgram',  'Reboot/2 Readme',        '<WP_REBOOT_FOLDER>',  'OBJECTID=<WP_REBOOT_VIEW_README>;CCVIEW=NO;EXENAME=E.EXE;PARAMETERS='CallPath'\Readme;PROGRAMTYPE=PM;', 'U');
 SAY 'Ok.';

 /* collect ids from old reboot icons */
 OldRebootIcons = '';
 IdList = SysIni(, 'PM_Workplace:Location', 'ALL:', 'Id.');
 DO i = 1 TO Id.0
    IF (POS( '<WP_REBOOT_PART_', Id.i) = 1) THEN
       OldRebootIcons = OldRebootIcons Id.i;
 END;


 /* select partition icon */
 /* first check name */
 /* second, check partition type */
 DO i = 1 TO Partition.0
    ThisPartition = TRANSLATE(Partition.i);
    SELECT

       WHEN (Partition.i.type = '83') THEN
          PartitionIcon = IconPath'\linux.ico';

       WHEN (POS('OS2', ThisPartition) > 0) THEN
          PartitionIcon = IconPath'\os2.ico';

       WHEN (POS('WARP', ThisPartition) > 0) THEN
          PartitionIcon = IconPath'\os2.ico';

       WHEN (POS('WIN', ThisPartition) > 0) THEN
          PartitionIcon = IconPath'\win.ico';

       WHEN (POS('NT', ThisPartition) > 0) THEN
          PartitionIcon = IconPath'\win.ico';

       /* assume type 7 is HPFS and not NTFS ;-) */
       WHEN (Partition.i.type = '07') THEN
          PartitionIcon = IconPath'\os2.ico';

       OTHERWISE
          PartitionIcon = IconPath'\dos.ico';

    END;

    CALL CHAROUT, 'Creating reboot object for partition' Partition.i '... ';
    Id = '<WP_REBOOT_PART_'TRANSLATE(TRANSLATE(Partition.i, '_', ' '))'>';
    rc = SysCreateObject( 'WPProgram',  'Reboot' Partition.i, '<WP_REBOOT_FOLDER>',  'OBJECTID='Id';EXENAME=*;PARAMETERS=/C setboot /IBA:"'Partition.i'" & REM [Reboot' Partition.i '?];PROGTYPE=WINDOWABLEVIO;MINIMIZED=YES;ICONFILE='PartitionIcon';', 'U');
    SAY 'Ok.';

    /* don't delete that one later */
    IdPos = WORDPOS( Id, OldRebootIcons);
    IF (IdPos > 0) THEN
    DO
       OldRebootIcons = DELWORD( OldRebootIcons, IdPos, 1);
    END;


 END;

 /* delete old reboot icons */
 IF (WORDS( OldRebootIcons) > 0) THEN
 DO

    CALL CHAROUT, 'Deleting obsolete program icons ... ';
    DO i = 1 TO WORDS( OldRebootIcons)
       rc = SysDestroyObject( WORD( OldRebootIcons, i));
    END;
    SAY 'Ok.';
 END;

 IF (fOpenObjects) THEN
 DO
    rc = SysOpenObject( '<WP_REBOOT_FOLDER>', 'DEFAULT', 1);
    rc = SysOpenObject( '<WP_REBOOT_FOLDER>', 'DEFAULT', 1);
    rc = SysOpenObject( '<WP_REBOOT_VIEW_README>', 'DEFAULT', 1);
    rc = SysOpenObject( '<WP_REBOOT_VIEW_README>', 'DEFAULT', 1);
 END;

 EXIT(ERROR.NO_ERROR);

/* ------------------------------------------------------------------------- */
HALT:
 SAY 'Abbruch durch Benutzer.';
 EXIT(ERROR.GEN_FAILURE);

/* ------------------------------------------------------------------------- */
ShowHelp: PROCEDURE EXPOSE (GlobalVars)


 PARSE SOURCE . . ThisFile

 DO i = 1 TO 3
    rc = LINEIN(ThisFile);
 END;

 ThisLine = LINEIN(Thisfile);
 DO WHILE (ThisLine \= ' */')
    SAY SUBSTR(ThisLine, 7);
    ThisLine = LINEIN(Thisfile);
 END;

 rc = LINEOUT(Thisfile);

 RETURN('');


/* ========================================================================= */
QueryPartitions: PROCEDURE EXPOSE (GlobalVars)

 /* initialize */
 DROP(Partition.);
 Partition.  = '';
 Partition.0 = 0;
 i = 0;

 /* create private rexx queue */
 QueueName = RXQUEUE('CREATE');
 rc        = RXQUEUE('SET', QueueName);

 /* read fdisk data and determine bootable partitions */
 'fdisk /query | rxqueue' Queuename
 DO WHILE (QUEUED() > 0)
    PARSE PULL Line;
    IF (DATATYPE( SUBSTR(Line, 38, 1)) = 'NUM') THEN
    DO
       PARSE VAR Line . +6 PartitionName +8 . . PartitionType PartitionStatus .
       IF ((PartitionStatus = 1) | (PartitionStatus = 3)) THEN
       DO
          i                = Partition.0 + 1;
          Partition.i      = STRIP(PartitionName);
          Partition.i.type = PartitionType;
          Partition.0      = i;
       END;
    END;
 END;

 /* reset to default queue */
 rc = RXQUEUE('DELETE', QueueName);
 rc = RXQUEUE('SET', 'SESSION');

 RETURN('');

