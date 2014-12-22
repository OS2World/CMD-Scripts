/*
 *      CVSWPS.CMD - NOSA Client - V1.06 C.Langanke for Netlabs 1999,2001
 *
 *      Syntax: CVSWPS [/Reset]
 *
 *      /Reset - deletes old folder before rebuilding
 *
 *      Creates WPS folder with program objects for access
 *      to the Netlabs Open Source Archive with CVS.
 *
 *      The created program objects require cvsenv.cmd!
 */
/* First comment is used as help text */

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
 ERROR.ENVVAR_NOT_FOUND   = 203;

 GlobalVars = 'Title CmdName env TRUE FALSE Redirection ERROR.';
 SAY;

 /* show help */
 ARG Parm .
 IF (POS('?', Parm) > 0) THEN
 DO
    rc = ShowHelp();
    EXIT(ERROR.INVALID_PARAMETER);
 END;

 /* load RexxUtil */
 CALL RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';
 CALL SysLoadFuncs;

 /* Defaults */
 GlobalVars  = GlobalVars 'ErrorMsg IniAppName CallDir ArchiveFile PrivateFile Archive.',
                          'IconDir BitmapDir fIsWarp4 FolderIcons HelpPage IdBase',
                          'CvsExe CvsServer CvsWorkRoot CvsHome';
 rc = ERROR.NO_ERROR;

 IniAppName  = 'NOSAC';
 ErrorMsg    = '';
 CallDir     = GetCalldir();

 Archive.    = '';
 Archive.0   = 0;

 IconDir     = CallDir'\ico';
 BitmapDir   = CallDir'\bmp';
 fIsWarp4    = (SysOS2Ver() >= 2.40);

 IF (fIsWarp4) THEN
    FolderIcons = 'ICONFILE='IconDir'\FOLDER4.ICO;ICONNFILE=1,'IconDir'\FOLDER4O.ICO'
 ELSE
    FolderIcons = 'ICONFILE='IconDir'\FOLDER3.ICO;ICONNFILE=1,'IconDir'\FOLDER3O.ICO'
 HelpPage = 'HELPLIBRARY='CallDir'\NOSAC.HLP;HELPPANEL';
 IdBase = '<NETLABS_NOSAC_#';

 ArchiveName  = '';
 ArchiveDescr = '';
 fReset       = FALSE;


 DO UNTIL (TRUE)
    /* read environment */
    CvsExe         = ReadIniValue(, IniAppName, 'CVS_EXE');
    CvsServer      = ReadIniValue(, IniAppName, 'CVS_SERVER');
    CvsWorkRoot    = ReadIniValue(, IniAppName, 'CVS_WORKROOT');
    CvsHome        = ReadIniValue(, IniAppName, 'CVS_HOME');
    IF (CvsWorkRoot = '') THEN
    DO
       ErrorMsg = 'the root directory for working directories on your computer is not defined.';
       rc = ERROR.ENVVAR_NOT_FOUND
       LEAVE;
    END;

    /* get commandline parms */
     PARSE ARG Parms
     DO i = 1 TO WORDS( Parms);
        ThisParm = WORD( Parms, i);
        CheckParm = TRANSLATE( ThisParm);

        SELECT
           WHEN (POS( CheckParm, '/RESET') = 1) THEN
              fReset = TRUE;
    
           OTHERWISE
           DO
              
              IF (ArchiveName = '') THEN
                 ArchiveName = ThisParm;
              ELSE
                 ArchiveDescr = ArchiveDescr ThisParm;
           END;
        END;
     END;
     IF (rc \= ERROR.NO_ERROR) THEN
        LEAVE;

    /* read in public archives */
    rcx = ReadArchiveList( CallDir'\archives.lst', 'PUBLIC');

    /* read in private archives - ignore error */
    rcx = ReadArchiveList( CallDir'\private.lst', 'PRIVATE');

    /* select what to do */
    SELECT

       WHEN (ArchiveName = '') THEN
          /* create main folder, if no archive specified */
          rc = CreateMainFolder( fReset);

       OTHERWISE
       DO
          p = WORDPOS( ArchiveName, Archive._List);
          /* archive tag valid ? */
          IF (p = 0) THEN
          DO
             ErrorMsg = 'specified archive' ArchiveName ' is invalid.';
             rc = ERROR.INVALID_PARAMETER;
             LEAVE;
          END;

          /* create archive folder */
          rc = CreateArchiveFolder( Archive.p, Archive.p.Name, fReset);
       END;

    END;

 END;

 /* exit */
 IF (rc \= ERROR.NO_ERROR) THEN
 DO
    SAY CmdName': Error:' ErrorMsg;
    'PAUSE'
 END;
 EXIT( rc);

/* ------------------------------------------------------------------------- */
HALT:
 SAY 'Interrupted by user.';
 EXIT(ERROR.GEN_FAILURE);

/* ------------------------------------------------------------------------- */
ShowHelp: PROCEDURE EXPOSE (GlobalVars)

 SAY Title;
 SAY;

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

/* ------------------------------------------------------------------------- */
GetCalldir: PROCEDURE
PARSE SOURCE . . CallName
 CallDir = FILESPEC('Drive', CallName)||FILESPEC('Path', CallName);
 RETURN(LEFT(CallDir, LENGTH(CallDir) - 1));

/* ------------------------------------------------------------------------- */
FileExist: PROCEDURE
 PARSE ARG FileName

 RETURN(STREAM(Filename, 'C', 'QUERY EXISTS') > '');
     
/* ------------------------------------------------------------------------- */
GetDrivePath: PROCEDURE
 PARSE ARG FileName

 FullPath = FILESPEC('D', FileName)||FILESPEC('P', FileName);
 IF (FullPath \= '') THEN
    RETURN(LEFT(FullPath, LENGTH(FullPath) - 1));
 ELSE
    RETURN('');

/* ========================================================================= */
ReadIniValue: PROCEDURE
PARSE ARG IniFile, IniAppname, IniKeyName

 IniValue = SysIni(IniFile, IniAppname, IniKeyName);
 IF (IniValue = 'ERROR:') THEN
    IniValue = '';

 IF ((IniValue \= '') & (RIGHT(IniValue, 1) = "00"x)) THEN
    IniValue = LEFT( IniValue, LENGTH( IniValue) - 1);

 RETURN( IniValue);

/* ------------------------------------------------------------------------- */
DirExist: PROCEDURE
 PARSE ARG Dirname

 IF (Dirname = '') THEN
    RETURN(0);

 /* use 'QUERY EXISTS' with root directories (???) */
 IF (RIGHT(DirName, 2) = ':\') THEN
   RETURN(STREAM(Dirname, 'C', 'QUERY EXISTS') \= '');

 /* query other directories this way */
 IF ((STREAM(Dirname, 'C', 'QUERY EXISTS') = '') &,
     (STREAM(Dirname, 'C', 'QUERY DATETIME') \= '')) THEN
    RETURN(1);
 ELSE
    RETURN(0);

/* ========================================================================= */
OpenInForeground: PROCEDURE
 PARSE ARG Id;
 DO i = 1 TO 2
    rc = SysOpenObject( Id, 'DEFAULT', 1);
 END;
 RETURN( rc);

/* ========================================================================= */
MakePath: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG PathName

 PARSE SOURCE . . CallName
 FileName = SUBSTR( CallName, LASTPOS( '\', CallName) + 1);
 'XCOPY' CallName PathName'\' Redirection;
 rcx = SysFileDelete( PathName'\'FileName);
 RETURN( rc);

/* ========================================================================= */
GetInfTitle: PROCEDURE
 ARG File

 Title = '';

 DO UNTIL (1)
    /* Titel lesen */
    Title = CHARIN( File, 108, 64);
    rcx = STREAM(File, 'C', 'CLOSE');

    /* Nullbytes abschneiden */
    zeroPos = POS("00"x, Title);
    IF (zeroPos \= 0) THEN
       Title = LEFT(Title, zeroPos - 1);
 END;

 RETURN(Title);


/* ========================================================================= */
ReadArchiveList: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG ListFile, ListType;

 rc          = ERROR.NO_ERROR;

 DO UNTIL (TRUE)
    /* des file exist */ 
    IF (\FileExist( ListFile)) THEN
    DO
       ErrorMsg = 'cannot find the file' ListFile; 
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;

    /* read in all archives */
    OldValue = Archive.0;
    /* CALL CHAROUT, 'Reading' ListFile '...'; */
    rcx = STREAM( ListFile, 'C', 'OPEN READ');
    DO WHILE (LINES( ListFile))
       ThisLine = STRIP( LINEIN(ListFile));
       IF (ThisLine = '' ) THEN ITERATE;
       IF (LEFT(ThisLine,1) = ';' ) THEN ITERATE;

       /* if description is missing, append last part of path */
       IF (WORDS( ThisLine) < 2) THEN
       DO
          PathWords = TRANSLATE( ThisLine, ' ', '/');
          ThisLine = ThisLine WORD( PathWords, WORDS( PathWords));
       END;
       IF (WORDS( ThisLine) < 2) THEN ITERATE;

       /* store data */
       p         = Archive.0 + 1;
       Archive.0 = p;
       PARSE VAR ThisLine ThisRoot ThisName
       ThisName = STRIP(ThisName);
       PARSE VAR ThisRoot ThisServer':'ThisDirectory;
       ThisTag = FILESPEC('N', ThisDirectory);
       Archive.p      = STRIP( ThisTag);
       Archive.p.Name = STRIP( ThisName);

       Archive._List           = Archive._List ThisTag;
       Archive.ListType._List  = Archive.ListType._List ThisTag;
    END;
    rcx = STREAM( ListFile, 'C', 'CLOSE');

    /* SAY 'Ok.' Archive.0  - OldValue 'archives found.'; */
 END;

 RETURN( rc);

/* ========================================================================= */
CreateMainFolder: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG fReset;

 rc          = ERROR.NO_ERROR;
 fShowHelp   = FALSE;


 DO UNTIL (TRUE)


    /* get cvs books */
    CvsBook.  = '';
    CvsBook.  = 0;
    IF (CvsExe \= '') THEN
    DO

       Filename = GetDrivePath( CvsExe)'\..\book\*.INF';
       Options  = 'OF';
       rc = SysFileTree(FileName, 'File.', Options);
       IF (rc \= ERROR.NO_ERROR) THEN
       DO
          SAY CmdName': Fehler in SysFileTree: Nicht genþgend Hauptspeicher.';
          EXIT(ERROR.NOT_ENOUGH_MEMORY);
       END;

       DO i = 1 TO File.0
          b = CvsBook.0 + 1;
          CvsBook.0 = b;
          CvsBook.b = STREAM( File.i, 'C', 'QUERY EXISTS');
       END;
    END;

    /* delete old folder ? */
    IF (fReset) THEN
    DO
       rcx = SysDestroyObject( '<NETLABS_NOSAC_INFO_NET_FOLDER>');
       rcx = SysDestroyObject( '<NETLABS_NOSAC_ARCHIVES_FOLDER>');
       rcx = SysDestroyObject( '<NETLABS_NOSAC_FOLDER>');
    END;

    IF (SysSetObjectData( '<NETLABS_NOSAC_FOLDER>', ';')) THEN
    DO
       CALL CHAROUT, 'Updating folder for Netlabs Open Source Archive Client ... ';
       fShowHelp = FALSE;
    END;
    ELSE
    DO
       CALL CHAROUT, 'Creating folder for Netlabs Open Source Archive Client ... ';
       fShowHelp = TRUE;
    END;

    /* create main folder and main objects */
    StaticIconSetup = 'LOCKEDINPLACE=YES;NOCOPY=YES;NOLINK=YES;NOSHADOW=YES;NOMOVE=YES;'
    SELECT
       WHEN (fIsWarp4) THEN
       DO
          TreeFolderSetup = 'DEFAULTSORT=0;DEFAULTVIEW=TREE;SHOWALLINTREEVIEW=YES;';
          y1stRow   = '34';
          y2ndRow   = '10';
       END;
       OTHERWISE
       DO
          TreeFolderSetup = '';
       y1stRow   = '37'
       y2ndRow   = '10';
       END;
    END;

    rcx = SysCreateObject( 'WPFolder',    'OS/2 Netlabs^Open Source Archive^Client',                 '<WP_DESKTOP>',                       HelpPage'=8;CCVIEW=NO;ICONFONT=8.Helv;ICONVIEWPOS=8 10 60 50;BACKGROUND='BitmapDir'\nllogo.bmp,N;'FolderIcons';OBJECTID=<NETLABS_NOSAC_FOLDER>;', 'U');
    rcx = SysCreateObject( 'WPProgram',   'Edit^CVS configuration',                                  '<NETLABS_NOSAC_FOLDER>',             StaticIconSetup';'HelpPage'=7;ICONPOS=51,'y2ndRow';PROGTYPE=PM;MAXIMIZED=YES;EXENAME=E.EXE;PARAMETERS='CvsHome'\.cvsrc;OBJECTID=<NETLABS_NOSAC_CONFIG_CVS>;', 'U');
    rcx = SysCreateObject( 'WPFolder',    'Select from available^OS/2 Netlabs^Open Source Archives', '<NETLABS_NOSAC_FOLDER>',             StaticIconSetup';'HelpPage'=6;ICONPOS=38,'y2ndRow';ICONVIEWPOS=73 25 26 50;ICONVIEW=MINI,NONFLOWED;CCVIEW=NO;MENUBAR=NO;STATUSBAR=NO;ALWAYSSORT=YES;DEFAULTSORT=0;ICONFILE='IconDir'\REBUILD.ICO;OBJECTID=<NETLABS_NOSAC_SELECT_FOLDER>;', 'U');
    rcx = SysCreateObject( 'WPProgram',   'View the^OS/2 Netlabs^Open Source Archive list' ,         '<NETLABS_NOSAC_FOLDER>',             StaticIconSetup';'HelpPage'=5;ICONPOS=23,'y2ndRow';PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\cvsenv.cmd * $SHOWLIST;ICONFILE='IconDir'\VIEW.ICO;OBJECTID=<NETLABS_NOSAC_VIEWLIST>;', 'U');
    rcx = SysCreateObject( 'WPProgram',   'Update the^Open Source Archive list^from OS/2 Netlabs',   '<NETLABS_NOSAC_FOLDER>',             StaticIconSetup';'HelpPage'=4;ICONPOS=07,'y2ndRow';PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\cvsenv.cmd * $GETLIST$;ICONFILE='IconDir'\UPDATE.ICO;OBJECTID=<NETLABS_NOSAC_UPDATELIST>;', 'U');
    rcx = SysCreateObject( 'WPFolder',    'OS/2 Netlabs^Open Source Archive^Information',            '<NETLABS_NOSAC_FOLDER>',             StaticIconSetup';'HelpPage'=3;ICONPOS=48,'y1stRow';'TreeFolderSetup'ALWAYSSORT=YES;MENUBAR=NO;STATUSBAR=NO;ICONRESOURCE=60,PMWP;OBJECTID=<NETLABS_NOSAC_INFO_FOLDER>;', 'U');
    rcx = SysCreateObject( 'WPFolder',    'OS/2 Netlabs^Open Source Archive^Connections',            '<NETLABS_NOSAC_FOLDER>',             StaticIconSetup';'HelpPage'=2;ICONPOS=27,'y1stRow';'TreeFolderSetup'ALWAYSSORT=YES;MENUBAR=NO;STATUSBAR=NO;ICONRESOURCE=87,PMWP;OBJECTID=<NETLABS_NOSAC_CONNECT_FOLDER>;', 'U');
    rcx = SysCreateObject( 'WPFolder',    'Selected^OS/2 Netlabs^Open Source Archives',              '<NETLABS_NOSAC_FOLDER>',             StaticIconSetup';'HelpPage'=1;ICONPOS=07,'y1stRow';CCVIEW=NO;ALWAYSSORT=YES;DEFAULTSORT=NAME;'FolderIcons';ICONVIEWPOS=5 70 78 22;OBJECTID=<NETLABS_NOSAC_ARCHIVES_FOLDER>;', 'U');

    IF (fIsWarp4) THEN
    DO
       /* fill information folder with subfolders and objects, plus shadows in system information folder and subfolders */
       rcx = SysCreateObject( 'WPUrlFolder', 'Development',                                          '<NETLABS_NOSAC_CONNECT_FOLDER>',     'SHOWALLINTREEVIEW=YES;OBJECTID=<NETLABS_NOSAC_CONNECT_DEV_FOLDER>;', 'U');
       rcx = SysCreateObject( 'WPUrl',       'Netlabs Homepage',                                     '<NETLABS_NOSAC_CONNECT_DEV_FOLDER>', 'LOCATOR=http://www.netlabs.org;OBJECTID=<NETLABS_HOMEPAGE>;', 'U');
       rcx = SysCreateObject( 'WPUrl',       'Netlabs Open Source Archive Homepage',                 '<NETLABS_NOSAC_CONNECT_DEV_FOLDER>', 'LOCATOR=http://www.netlabs.org/nosa;OBJECTID=<NETLABS_NOSA_HOMEPAGE>;', 'U');

       /* create own URL folder for development under main URL Folder */
       rcx = SysCreateObject( 'WPUrlFolder', 'Development',                                           '<WP_COOLURLSFOLDER>',                'SHOWALLINTREEVIEW=YES;OBJECTID=<URLF_DEV>', 'U');
       rcx = SysCreateObject( 'WPShadow',    '.',                                                     '<URLF_DEV>',                         'SHADOWID=<NETLABS_HOMEPAGE>;OBJECTID=<NETLABS_HOMEPAGE_SHADOW>;', 'U');
       rcx = SysCreateObject( 'WPShadow',    '.',                                                     '<URLF_DEV>',                         'SHADOWID=<NETLABS_NOSA_HOMEPAGE>;OBJECTID=<NETLABS_NOSA_HOMEPAGE_SHADOW>;', 'U');

       rcx = SysCreateObject( 'WPFolder',    'Read Me',                                               '<NETLABS_NOSAC_INFO_FOLDER>'   ,     'SHOWALLINTREEVIEW=YES;OBJECTID=<NETLABS_NOSAC_INFO_README_FOLDER>;', 'U');
       rcx = SysCreateObject( 'WPProgram',   'OS/2 Netlabs^Open Source Archive Client',               '<NETLABS_NOSAC_INFO_README_FOLDER>', 'PROGTYPE=PM;EXENAME=VIEW.EXE;PARAMETERS='CallDir'\nosac.inf "OS/2 Netlabs Open Source";ICONFILE='IconDir'\HELP.ICO;OBJECTID=<NETLABS_NOSAC_INFO_README>;', 'U');
       rcx = SysCreateObject( 'WPShadow',    '.',                                                     '<WP_READMEFOLDER>',                  'SHADOWID=<NETLABS_NOSAC_INFO_README>;OBJECTID=<NETLABS_NOSAC_INFO_README_SHADOW>;', 'U');
    END;
    ELSE
    DO
       /* put URLs directly in NOSAC connection folder */
       rcx = SysCreateObject( 'WPProgram',   'Netlabs Homepage',                                   '<NETLABS_NOSAC_CONNECT_FOLDER>',  'PROGTYPE=PM;EXENAME=NETSCAPE.EXE;PARAMETERS=http://www.netlabs.org;OBJECTID=<NETLABS_HOMEPAGE>;', 'U');
       rcx = SysCreateObject( 'WPProgram',   'Netlabs Open Source Archive Homepage',               '<NETLABS_NOSAC_CONNECT_FOLDER>',  'PROGTYPE=PM;EXENAME=NETSCAPE.EXE;PARAMETERS=http://www.netlabs.org/nosa;OBJECTID=<NETLABS_NOSA_HOMEPAGE>;', 'U');

       /* put NOSAC INF directly in NOSAC info folder and shadow in system info folder */
       rcx = SysCreateObject( 'WPProgram',   'OS/2 Netlabs^Open Source Archive Client',            '<NETLABS_NOSAC_INFO_FOLDER>',     'PROGTYPE=PM;EXENAME=VIEW.EXE;PARAMETERS='CallDir'\nosac.inf "OS/2 Netlabs Open Source";ICONFILE='IconDir'\HELP.ICO;OBJECTID=<NETLABS_NOSAC_INFO_README>;', 'U');
       rcx = SysCreateObject( 'WPShadow',    '.',                                                  '<WP_INFO',                        'SHADOWID=<NETLABS_NOSAC_INFO_README>;OBJECTID=<NETLABS_NOSAC_INFO_README_SHADOW>;', 'U');
    END;

    IF (CvsBook.0 > 0)  THEN
    DO
       rcx = SysCreateObject( 'WPFolder',    'Reference and Commands',                             '<NETLABS_NOSAC_INFO_FOLDER>'   ,     'SHOWALLINTREEVIEW=YES;OBJECTID=<NETLABS_NOSAC_INFO_CMDREF_FOLDER>;', 'U');
       DO b = 1 TO CvsBook.0
          BookName  = FILESPEC( 'N', CvsBook.b);
          IdName    = TRANSLATE( LEFT( BookName, LENGTH( BookName) - 4));
          BookTitle = GetInfTitle( CvsBook.b);
          IF (BookTitle = '') THEN
             BookTitle = 'CVS Client/Server Protocol';
          rcx = SysCreateObject( 'WPProgram', BookTitle,                                           '<NETLABS_NOSAC_INFO_CMDREF_FOLDER>', 'PROGTYPE=PM;EXENAME=VIEW.EXE;PARAMETERS='CvsBook.b';OBJECTID=<NETLABS_NOSAC_INFO_CMDREF_'IdName'>;', 'U');
          rcx = SysCreateObject( 'WPShadow',  '.',                                                 '<WP_REFCMDFOLDER>',                  'SHADOWID=<NETLABS_NOSAC_INFO_CMDREF_'IdName'>;OBJECTID=<NETLABS_NOSAC_INFO_CMDREF_'IdName'_SHADOW>;', 'U');
       END;
    END;

    /* create select icon per archive */
    DO i = 1 TO Archive.0;
       ThisProjectId = TRANSLATE( Archive.i);

       TypePrivate = 'PRIVATE';
       IF (WORDPOS( Archive.i, Archive.TypePrivate._List) > 0) THEN
          IconName = 'REBUILDP.ICO'
       ELSE
          IconName = 'REBUILD.ICO'
       rcx = SysCreateObject( 'WPProgram',  'select:' Archive.i.Name , '<NETLABS_NOSAC_SELECT_FOLDER>', 'PROGTYPE=WINDOWABLEVIO;EXENAME='CallDir'\cvswps.cmd;PARAMETERS='Archive.i Archive.i.Name';ICONFILE='IconDir'\'IconName';OBJECTID=<NETLABS_NOSAC_SELECT_#'ThisProjectId';', 'R');
    END;

    /* open folder to foreground */
    rcx = SysOpenObject( '<NETLABS_NOSAC_FOLDER>', 'DEFAULT', 1);
    rcx = SysOpenObject( '<NETLABS_NOSAC_FOLDER>', 'DEFAULT', 1);

    /* folders for selection */
    IF (Archive.0 > 0) THEN
    DO
       rcx = OpenInForeground( '<NETLABS_NOSAC_ARCHIVES_FOLDER>');
       rcx = OpenInForeground( '<NETLABS_NOSAC_SELECT_FOLDER>');

       /* resort select folder */
       rcx = SysSetObjectData( '<NETLABS_NOSAC_SELECT_FOLDER>', 'ALWAYSSORT=NO;');
       rcx = SysSetObjectData( '<NETLABS_NOSAC_SELECT_FOLDER>', 'ALWAYSSORT=YES;');
    END;

    /* open help to foreground on install */
    IF (fShowHelp) THEN
    DO
       rcx = OpenInForeground( '<NETLABS_NOSAC_INFO_README>');
    END;

    /* done */
    rc = ERROR.NO_ERROR;
    SAY 'Ok.';

 END;

 RETURN( rc);

/* ========================================================================= */
CreateArchiveFolder: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG Archive, ArchiveName, fReset;

 rc = ERROR.NO_ERROR;

 DO UNTIL (TRUE)

    /* create folder per archive */
    Archive.iBase = IdBase''TRANSLATE( Archive);
    ThisFolderId    = Archive.iBase'_FOLDER>';

    IF (SysSetObjectData( ThisFolderId, ';')) THEN
       CALL CHAROUT, 'Updating';
    ELSE
       CALL CHAROUT, 'Creating';
    CALL CHAROUT, ' folder for Netlabs Open Source Archive' ArchiveName '... ';

    /* create program objects for archive */
    Option = 'U';
    Archive.iBase = IdBase''TRANSLATE( Archive);
    rcx = SysCreateObject( 'WPFolder',  'Netlabs Archive^'ArchiveName ,       '<NETLABS_NOSAC_ARCHIVES_FOLDER>',    HelpPage'=10;DEFAULTSORT=2;ALWAYSSORT=YES;ICONVIEWPOS=13 42 78 36;'FolderIcons';OBJECTID='ThisFolderId';', 'U');
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^OS/2 Window',            ThisFolderId ,                        HelpPage'=23;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/K 'CallDir'\CVSENV.CMD' Archive';STARTUPDIR='CvsWorkRoot'\'Archive';OBJECTID='ArchiveBase'_WINDOW>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Fix Snapshot',           ThisFolderId ,                        HelpPage'=25;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $FIXSNAPSHOT & PAUSE;STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\FIXSNAP.ICO;OBJECTID='ArchiveBase'_FIXSNAPSHOT>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Generate Change Report', ThisFolderId ,                        HelpPage'=24;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $REPORT;STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\REPORT.ICO;OBJECTID='ArchiveBase'_REPORT>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^View modules',           ThisFolderId ,                        HelpPage'=22;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $MODULES;STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\VIEW.ICO;OBJECTID='ArchiveBase'_MODULES>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Remove file',            ThisFolderId ,                        HelpPage'=21;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $REMOVE;STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\REMOVE.ICO;OBJECTID='ArchiveBase'_REMOVE>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Tag file',               ThisFolderId ,                        HelpPage'=20;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $TAG [Enter tag name] [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\TAG.ICO;OBJECTID='ArchiveBase'_TAG>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Commit file changes',    ThisFolderId ,                        HelpPage'=19;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $COMMIT [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\COMMIT.ICO;OBJECTID='ArchiveBase'_COMMIT>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Merge to local files',   ThisFolderId ,                        HelpPage'=18;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $UPDATE [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\MERGE.ICO;OBJECTID='ArchiveBase'_MERGE>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Update local files',     ThisFolderId ,                        HelpPage'=17;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $UPDATE [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\UPDATE.ICO;OBJECTID='ArchiveBase'_UPDATE>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Add new file',           ThisFolderId ,                        HelpPage'=16;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $ADD [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\ADD.ICO;OBJECTID='ArchiveBase'_ADD>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Query file status',      ThisFolderId ,                        HelpPage'=15;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $STATUS [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\STATUS.ICO;OBJECTID='ArchiveBase'_STATUS>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^View file log' ,         ThisFolderId ,                        HelpPage'=14;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $LOG [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\LOG.ICO;OBJECTID='ArchiveBase'_LOG>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Checkout file' ,         ThisFolderId ,                        HelpPage'=13;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' $CHECKOUT [Enter filename(s)/module(s)];STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\CHECKOUT.ICO;OBJECTID='ArchiveBase'_CHECKOUT>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Logout',                 ThisFolderId ,                        HelpPage'=12;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' !LOGOUT;STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\LOGOUT.ICO;OBJECTID='ArchiveBase'_LOGOUT>;', Option);
    rcx = SysCreateObject( 'WPProgram', ArchiveName'^Login',                  ThisFolderId ,                        HelpPage'=11;PROGTYPE=WINDOWABLEVIO;MAXIMIZED=YES;EXENAME=cmd.exe;PARAMETERS=/C 'CallDir'\CVSENV.CMD' Archive' !LOGIN;STARTUPDIR='CvsWorkRoot'\'Archive';ICONFILE='IconDir'\LOGIN.ICO;OBJECTID='ArchiveBase'_LOGIN>;', Option);

    /* create working dir for archive */
    IF (CvsWorkRoot \= '') THEN
    DO
       WorkDir = CvsWorkRoot'\'Archive;
       IF (\DirExist( WorkDir)) THEN
          rcx = MakePath( WorkDir);
       rcx = SysCreateObject( 'WPShadow', '.',   ThisFolderId , 'SHADOWID='WorkDir';OBJECTID='Archive.iBase'_WORKDIR_SHADOW>;', 'U');
    END;

    /* done */
    rc = ERROR.NO_ERROR;
    SAY 'Ok.';

 END;

 RETURN( rc);

