/*
 *      CVSENV.CMD - NOSA Client - V1.06 C.Langanke for Netlabs 1999,2001
 *
 *     Syntax: cvsenv archive_name [action]
 *
 *       archive_name - name of the archive directory
 *
 *     Valid actions are (lowercase letters optional):
 *     (no option)|$Work   - brings you to the working directory of a project
 *     /Bin                - brings you back to the bin directory of NOSAC
 *     /Fixsnapshot        - fixes CVS management files to allow use
 *                           a snapshot being built on the server side
 *     /List               - show current available archives
 *     /Getlist            - get the current archives list via FTP
 *     /User               - switch the user id
 *     /Modules            - Show the modules of an archive
 *     /Report             - generates a change report form
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
 CrLf         = "0d0a"x;
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

 GlobalVars = 'Title CmdName env TRUE FALSE CrLf Redirection ERROR.';
 SAY;


 /* load RexxUtil */
 CALL RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';
 CALL SysLoadFuncs;

 /* Defaults */
 GlobalVars     = GlobalVars '';
 Action         = '';
 fFixSnapShot   = FALSE;
 fChangeReport  = FALSE;

 ValidSwichChars     = '/-$';
 ValidCvsenvCommands = '!LOGIN !LOGOUT /ADD /LOG /TAG /CHECKOUT /UPDATE /STATUS /COMMIT /REMOVE';

 Ftp._User      = 'nosac';
 Ftp._Passwd    = 'getarchiveslist';
 Ftp._File      = 'archives.lst';

 CallDir        = GetCalldir();
 ArchiveFile    = CallDir'\archives.lst';
 PrivateFile    = CallDir'\private.lst';

 IniAppName     = 'NOSAC';

 ArchiveVarname = 'NOSAC_ARCHIVE';

 rc = ERROR.NO_ERROR;

 /* show help */
 ARG Parm .
 IF ((Parm = '') | (POS('?', Parm) > 0)) THEN
 DO
    rc = SetCVSPath( ReadIniValue(, IniAppName, 'CVS_BINROOT'));
    rc = ShowHelp();
    EXIT(ERROR.INVALID_PARAMETER);
 END;

 DO UNTIL (TRUE)

    /* -------------------------------------------------------------- */

    /* init some messages */
    ShowListTitle    = 'Public Open Source Archives currently available:';
    EmptyListMessage = 'Currently no Open Source Archives. Update your archives list!';

    /* -------------------------------------------------------------- */

    /* read some vars*/
    CvsServer      = ReadIniValue(, IniAppName, 'CVS_SERVER');
    CvsWorkRoot    = ReadIniValue(, IniAppName, 'CVS_WORKROOT');
    CvsInitCommand = ReadIniValue(, IniAppName, 'CVS_INITCOMMAND');
    CvsHome        = ReadIniValue(, IniAppName, 'CVS_HOME');
    CvsUser        = ReadIniValue(, IniAppName, 'CVS_USER');
    CvsPager       = ReadIniValue(, IniAppName, 'CVS_PAGER');

    MissingVar = '';
    SELECT
       WHEN (CvsServer = '')      THEN MissingVar = 'Open Source CVS Archive Server';
       WHEN (CvsWorkRoot = '')    THEN MissingVar = 'root directory for working directories';
       WHEN (CvsHome = '')        THEN MissingVar = 'homedirectory';
       WHEN (CvsUser = '')        THEN MissingVar = 'user id';
       OTHERWISE NOP;
    END;

    IF (MissingVar \= '') THEN
    DO
       ErrorMsg = 'The' MissingVar 'is not defined.' CRLF||,
                  'Run INSTALL.CMD first.';
       rc = ERROR.ENVVAR_NOT_FOUND
       LEAVE;
    END;

    /* comamnd to be executed ? */
    IF (CvsInitCommand \= '') THEN
       'CALL' CvsInitCommand;

    /* make CVS binaries available */
    rc = SetCVSPath( ReadIniValue(, IniAppName, 'CVS_BINROOT'));
    IF (rc \= ERROR.NO_ERROR) THEN
       LEAVE;

    /* -------------------------------------------------------------- */

    /* check parms */
    ArchiveVar = VALUE( ArchiveVarname, '', env);
    PARSE ARG Archive Action Option;
    Archive = STRIP( Archive);
    SELECT
       WHEN (POS( LEFT(Archive, 1), ValidSwichChars) > 0) THEN
       DO
          PARSE ARG  Action Option;
          Archive = STRIP( ArchiveVar);
       END;

       OTHERWISE
     END;

     OptionValue = Option;
     Option      = STRIP(TRANSLATE( Option));
     Action      = TRANSLATE( Action);

    /* - set ARCHIVE */
    rcx = VALUE( ArchiveVarname, Archive, env);

    /* handle different switch characters */
    IF ( POS( LEFT( Action, 1), ValidSwichChars) > 0) THEN
       Action = OVERLAY( '/', Action);

    /* check option */
    SELECT
       WHEN (POS( Action, ValidSwichChars) > 0) THEN
       DO
          ErrorMsg = 'Invalid action specified';
          rc = ERROR.INVALID_PARAMETER;
       END;

       WHEN (POS(Action, '/BIN') = 1) THEN
       DO
          rcx = DIRECTORY( Calldir);
          rc = ERROR.NO_ERROR;
          LEAVE;
       END;

       WHEN (POS(Action, '/USER') = 1) THEN
       DO
          NewUser = STRIP( OptionValue);
          IF (NewUSer = '') THEN
          DO
             ErrorMsg = 'No user name specified';
             rc = ERROR.INVALID_PARAMETER;
          END;
          ELSE
          DO
             CvsUser = NewUser;
             CALL CHAROUT, 'switching user to' CvsUser '... ';
             rcx = SysIni(, IniAppName, 'CVS_USER', CvsUser);
             SAY 'Ok.';
             fFixSnapshot = TRUE;
          END;
       END;

       WHEN (POS(Action,'/GETLIST') = 1) THEN
       DO
          rc = GetArchiveList( CvsServer, Ftp._User, Ftp._Passwd, Ftp._File, ArchiveFile);
          'PAUSE';
          RETURN(rc);
       END;

       /* internal version of GETLIST for WPS object */
       WHEN (POS(Action,'/GETLIST$') = 1) THEN
       DO
          rc = GetArchiveList( CvsServer, Ftp._User, Ftp._Passwd, Ftp._File, ArchiveFile);
          IF ((rc \= ERROR.NO_ERROR) & (rc \= ERROR.INVALID_FUNCTION)) THEN
             'PAUSE';
          'CALL' CallDir'\CVSWPS';
          RETURN(rc);
       END;

       WHEN (POS(Action, '/LIST') = 1) THEN
          EXIT( ShowList( ArchiveFile, PrivateFile, ShowListTitle, EmptyListMessage));

       WHEN (POS(Action, '/SHOWLIST') = 1) THEN
       DO
          /* special treatment, when called by WPS icon */
          'CLS';
          SAY;
          rc = ShowList( ArchiveFile, PrivateFile, ShowListTitle, EmptyListMessage);
          'PAUSE';
          SAY;
          EXIT( rc);
       END;

       WHEN ((Archive = '') | (POS(LEFT(Archive, 1),'!$') > 0 )) THEN
       DO
          ErrorMsg = 'No archive name specified';
          rc = ERROR.INVALID_PARAMETER;
       END;

       WHEN (POS(Action, '/WORK') = 1) THEN
          Action = '';


       WHEN (POS( Action, '/FIXSNAPSHOT') = 1)  THEN
          fFixSnapshot = TRUE;

       WHEN (POS(Action,'/REPORT') = 1) THEN
          fChangeReport = TRUE;

       /* for all other options: make sure archive file exists */
       WHEN (\FileExist( ArchiveFile)) THEN
       DO
          SAY CmdName': The archive list file is required, but missing.';
          rc = GetArchiveList( CvsServer, Ftp._User, Ftp._Passwd, Ftp._File, ArchiveFile);
          IF (rc \= ERROR.NO_ERROR) THEN
          DO
             ErrorMsg = 'Cannot continue without archive list file.';
             rc =  ERROR.GEN_FAILURE;
             LEAVE;
          END;
       END;

       WHEN (POS(Action, '/MODULES') = 1) THEN
         EXIT(ShowModuleList( Archive, CvsWorkRoot'\'Archive'\CVSROOT\Modules'));

       WHEN (WORDPOS( Action, ValidCvsenvCommands) > 0) THEN NOP;

       WHEN (Action \= '') THEN
       DO
          ErrorMsg = 'invalid option' SUBSTR( Action, 2) 'specified.';
          rc = ERROR.INVALID_PARAMETER;
       END;

       OTHERWISE NOP;

    END;

    IF (rc \= ERROR.NO_ERROR) THEN
       LEAVE;

    /* -------------------------------------------------------------- */

    /* set envrionment var */
    CALL CHAROUT, 'Initialize environment for Archive' Archive '... ';

    /* extend path to this directory, making cvsenv available */
    AddToPath = CallDir';';
    CurrentPath = VALUE( 'PATH',,env);
    IF (POS( AddToPath, CurrentPath) = 0) THEN
       rcx = VALUE('PATH', AddToPath''CurrentPath,env);

    /* determine archive root for archive */
    CvsArchiveRoot = GetArchiveRoot( Archive, ArchiveFile);
    IF (CvsArchiveRoot = '') THEN
       CvsArchiveRoot = GetArchiveRoot( Archive, PrivateFile);

    IF (CvsArchiveRoot = '') THEN
    DO
       /* reset to old archive name */
       rcx = VALUE( ArchiveVarname, ArchiveVar, env);
       SAY;
       ErrorMsg = 'Archive' Archive 'could not be found in the archive list file.';
       rc = ERROR.INVALID_DATA;
       LEAVE;
    END;

    CvsRoot = unixslash( ':pserver:'CvsUser'@'CvsArchiveRoot);

    /* - set CVSROOT */
    rcx = VALUE( 'CVSROOT', CvsRoot, env);
    SAY 'Ok.';

    /* - set homedirectory */
    rcx = VALUE('HOME', dosslash(CvsHome), env);

    /* - set user id */
    rcx = VALUE('USER', CvsUser, env);

    /* -------------------------------------------------------------- */

    IF (fChangeReport) THEN
    DO
       rc = CvsReport();
       LEAVE;
    END;

    /* -------------------------------------------------------------- */

    IF (fFixSnapshot) THEN
    DO
       rc = FixArchiveSnapshot(CvsRoot);
       LEAVE;
    END;

    /* -------------------------------------------------------------- */

    /* change to working dir of archive */
    IF (CvsWorkRoot \= '') THEN
    DO
       WorkDir = CvsWorkRoot'\'Archive;
       IF (\DirExist( WorkDir)) THEN
          rcx = MakePath( WorkDir);
       rcx = DIRECTORY( WorkDir);
    END;

    /* -------------------------------------------------------------- */

    /* Perform action specified in Option */
    rc = ProcessArchive( CvsWorkRoot'\'Archive, Action, OptionValue);

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
FileExist: PROCEDURE
 PARSE ARG FileName

 RETURN(STREAM(Filename, 'C', 'QUERY EXISTS') > '');

/* ------------------------------------------------------------------------- */
LOWER: PROCEDURE

 Lower = 'abcdefghijklmnopqrstuvwxyz„”';
 Upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZŽ™š';

 PARSE ARG String
 RETURN(TRANSLATE(String, Lower, Upper));

/* ------------------------------------------------------------------------- */
GetDrivePath: PROCEDURE
 PARSE ARG FileName

 FullPath = FILESPEC('D', FileName)||FILESPEC('P', FileName);
 IF (FullPath \= '') THEN
    RETURN(LEFT(FullPath, LENGTH(FullPath) - 1));
 ELSE
    RETURN('');

/* ------------------------------------------------------------------------- */
GetCalldir: PROCEDURE
PARSE SOURCE . . CallName
 CallDir = FILESPEC('Drive', CallName)||FILESPEC('Path', CallName);
 RETURN(LEFT(CallDir, LENGTH(CallDir) - 1));

/* ------------------------------------------------------------------------- */
ProceedWith: PROCEDURE
 PARSE ARG Prompt

 ResponseKeys  = 'Y N A R I'; /* SysGetMessage(0); */
 Yes           = WORD(ResponseKeys, 1);
 No            = WORD(ResponseKeys, 2);
 ch            = ' ';
 ValidResponse = Yes||No;

 SAY;
 CALL CHAROUT ,Prompt '('Yes'/'No') '
 DO WHILE (POS(ch, ValidResponse) = 0)
    ch = SysGetKey('NOECHO');
    ch = TRANSLATE(ch);
    IF (POS(ch, ValidResponse) = 0) THEN BEEP(800, 200);
 END;
 SAY;
 SAY;
 RETURN(ch = Yes);

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
SetCVSPath: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG CvsBinRoot;

 rc = ERROR.NO_ERROR;

 DO UNTIL (TRUE)

    /* - search CVS binaries */
    fCvsFound = (SysSearchPath('PATH', 'CVS.EXE') \= '');

    IF (\fCvsFound) THEN
    DO
       IF (CvsBinRoot \= '') THEN
          fCvsFound = FileExist( CvsBinRoot'\bin\cvs.exe');
    END;

    IF (\fCvsFound) THEN
    DO
       ErrorMsg = 'CVS binaries could not be found!';
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;

    /* - extend path to CVS binaries */
    IF (SysSearchPath('PATH', 'CVS.EXE') = '') THEN
    DO
       AddToPath = CvsBinRoot'\bin;';
       CurrentPath = VALUE( 'PATH',,env);
       IF (POS( AddToPath, CurrentPath) = 0) THEN
          rcx = VALUE('PATH', AddToPath''CurrentPath,env);
    END;
 END;

 RETURN(rc);

/* ========================================================================= */
MakePath: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG PathName

 PARSE SOURCE . . CallName
 FileName = SUBSTR( CallName, LASTPOS( '\', CallName) + 1);
 'XCOPY' CallName PathName'\' Redirection;
 rcx = SysFileDelete( PathName'\'FileName);
 RETURN( rc);

/* ========================================================================= */
unixslash: PROCEDURE
 PARSE ARG string
 RETURN(TRANSLATE( string, '/', '\'));

/* ========================================================================= */
dosslash: PROCEDURE
 PARSE ARG string
 RETURN(TRANSLATE( string, '\', '/'));

/* ========================================================================= */
ReadIniValue: PROCEDURE
PARSE ARG IniFile, IniAppname, IniKeyName

 IniValue = SysIni(IniFile, IniAppname, IniKeyName);
 IF (IniValue = 'ERROR:') THEN
    IniValue = '';

 IF ((IniValue \= '') & (RIGHT(IniValue, 1) = "00"x)) THEN
    IniValue = LEFT( IniValue, LENGTH( IniValue) - 1);

 RETURN( IniValue);

/* ========================================================================= */
ShowList: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG ListFile, PrivateFile, Title, EmptyMsg;

 SAY Title;
 SAY COPIES('-', LENGTH( Title));
 Count = 0;

 /* process public list */
 DO WHILE (LINES( ListFile) > 0)
    ThisLine = LINEIN( ListFile);
    IF (LEFT( ThisLine, 1) = '#') THEN
       ITERATE;
    Count = Count + 1;
    SAY ThisLine
 END;
 rcx = STREAM( ListFile, 'C', 'CLOSE');

 /* process private list */
 IF (FileExist( PrivateFile)) THEN
 DO
    SAY;
    SAY 'Private Open Source Archives available for your personal use:';
    SAY '-------------------------------------------------------------';
    DO WHILE (LINES( PrivateFile) > 0)
       ThisLine = LINEIN( PrivateFile);
       IF (LEFT( ThisLine, 1) = '#') THEN
          ITERATE;
       Count = Count + 1;
       SAY ThisLine
    END;
    rcx = STREAM( PrivateFile, 'C', 'CLOSE');
 END;


 IF (Count = 0) THEN
 DO
    SAY;
    SAY EmptyMsg;
 END;
 SAY;

 RETURN(0);

/* ========================================================================= */
ShowModuleList: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG Archive, ListFile;

 rc         = ERROR.NO_ERROR;
 Module.0   = 0;
 NameMaxLen = 5;

 DO UNTIL (TRUE)
    /* archive exists ? */
    IF (\DirExist( ListFile'\..')) THEN
    DO
       SAY 'error: working directory for archive' Archive 'does not exist.';
       rc = ERROR.PATH_NOT_FOUND;
       LEAVE;
    END;

    IF(\FileExist( ListFile)) THEN
    DO
       SAY 'error: module list not found for archive' Archive;
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;

    /* determine Modules */
    DO WHILE (LINES( ListFile) > 0)
       ThisLine = LINEIN( ListFile);
       IF (LEFT( ThisLine, 1) = '#') THEN
          ITERATE;

       m        = Module.0 + 1;
       Module.0 = m;
       Module.m = ThisLine;
       NameLen = LENGTH( WORD( ThisLine, 1));
       IF (NameLen > NameMaxLen) THEN
          NameMaxLen = NameLen;
    END;
    rcx = STREAM( ListFile, 'C', 'CLOSE');

    /* show result */
    IF (Module.0 = 0) THEN
       SAY 'No modules defined for archive:' Archive;
    ELSE
    DO
       ModulesTitle = 'Modules defined for archive:' Archive;
       'CLS'
       SAY;
       SAY ModulesTitle;
       SAY COPIES('=', LENGTH( ModulesTitle));
       SAY LEFT( 'name:', NameMaxLen) '  files in module:';
       SAY COPIES('-', NameMaxLen) ' ' COPIES( '-', 30);

       DO m = 1 TO Module.0
          PARSE VAR ThisLine ModuleName Files;
          SAY LEFT( ModuleName, NameMaxLen) ' ' Files;
       END;
    END;
 END;

 SAY;
 'PAUSE';
 SAY;
 RETURN(rc);

/* ========================================================================= */
GetArchiveList: PROCEDURE  EXPOSE (GlobalVars)
 PARSE ARG HostList, User, Passwd, RemoteFile, LocalFile;

 rc       = ERROR.NO_ERROR;
 HostList = TRANSLATE( SPACE( HostList, 0), ' ', ',');
 fUpdated = FALSE;

 DO UNTIL (TRUE)

    SAY 'About to update the'
    SAY;
    SAY 'Open Source Archives List file';
    SAY '------------------------------';
    SAY;
    SAY 'Note:  An internet connection is required for this !';
    IF (\ProceedWith('Do you want to continue')) THEN
    DO
       SAY 'Update of list file aborted.';
       RETURN( ERROR.INVALID_FUNCTION);
    END;

    SAY 'Updating archive list from:';
    SuccessList = '';
    ErrorList = '';
    DO WHILE (HostList \= '')
       PARSE VAR HostList ThisHost HostList;
       CALL CHAROUT, '-' ThisHost;
       rc = GetArchiveListFromHost( ThisHost, User, Passwd, RemoteFile, LocalFile);
       IF (rc = ERROR.NO_ERROR) THEN
       DO
          SuccessList = SuccessList ThisHost;
          fUpdated = TRUE;
       END;
       ELSE
          ErrorList = ErrorList ThisHost;
       SAY;
    END;

    /* done */
    SAY 'The Open Source Archives List file'; 
    IF (SuccessList \= '') THEN
       SAY '- has been successfully updated from:'SuccessList;
    IF (ErrorList \= '') THEN
       SAY '- could not be updated from'ErrorList;

 END;

 RETURN( rc);


/* ========================================================================= */
GetArchiveListFromHost: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG Host, User, Passwd, RemoteFile, LocalFile;

 CmdFile = SysTempFilename( VALUE('TMP',,env)'\ftp.???');
 TmpFile = SysTempFilename( VALUE('TMP',,env)'\nosac.???');
 rc      = ERROR.NO_ERROR;
 DO UNTIL (TRUE)

    /* write command file */
    rcx = LINEOUT( CmdFile, 'open' Host);
    rcx = LINEOUT( CmdFile, 'quot user' User);
    rcx = LINEOUT( CmdFile, 'quot pass' Passwd);
    rcx = LINEOUT( CmdFile, 'get' RemoteFile TmpFile);
    rcx = LINEOUT( CmdFile);

    /* get the remote file */
    'ftp -n <' CmdFile Redirection;
    rcx = SysFileDelete( CmdFile);
    IF (\FileExist( TmpFile)) THEN
    DO
       rc = ERROR.ACCESS_DENIED;
       LEAVE;
    END;

    /* append all projects of other hosts to that file */
    DO WHILE (LINES( LocalFile) > 0)
       ThisProject = LINEIN( LocalFile);
       PARSE VAR ThisProject ThisHost':'.;
       IF (TRANSLATE(ThisHost) \= TRANSLATE( Host)) THEN
          rcx = LINEOUT( TmpFile, ThisProject);
    END;
    rcx = STREAM( LocalFile, 'C', 'CLOSE');
    rcx = STREAM( TmpFile, 'C', 'CLOSE');

    /* copy over the new file and cleanup */
    'COPY' TmpFile LocalFile Redirection;
    rcx = SysFileDelete( TmpFile);

 END;

 SAY;
 RETURN( rc);

/* ========================================================================= */
ProcessArchive: PROCEDURE EXPOSE (GlobalVars) CvsPager
 PARSE ARG WorkRoot, Action, Files;

 /* defaults */
 Tagname = '';

 /* check parms */
 IF (Files = '') THEN
    Files = '.';
 Action = LOWER( STRIP( Action));
 IF (Action = '') THEN
    RETURN( ERROR.NO_ERROR);
 ELSE
    PARSE VAR Action ActionType +1 Action;

 /* get cvsroot */
 CvsRoot = VALUE( 'CVSROOT',,env);

 /* perform command */
 IF (ActionType = '!') THEN
 DO
    CvsUser = VALUE( 'USER',,env);
    CvsRoot = VALUE( 'CVSROOT',,env);

    SAY;
    SELECT
       WHEN (Action = 'login') THEN
       DO
          IF (TRANSLATE(CvsUser) = 'GUEST') THEN
          DO
             SAY 'Specify "readonly" as password for access with the guest account !';
             SAY;
          END;
       END;

       OTHERWISE NOP;
    END;

    'CALL cvs -d' CvsRoot Action;
    'PAUSE';
 END;
 ELSE
 DO
    /* process files: convert all absolute pathnames to names relative to working root */
    FileList = ''
    DO i = 1 TO WORDS(Files)
       ThisFile = WORD( Files,i);

       IF (POS( ':\', ThisFile) > 1) THEN
       DO
          FileList = FileList DELSTR( ThisFile, 1, LENGTH( WorkRoot) + 1);
       END;
       ELSE
          FileList = FileList ThisFile;
    END;
    Files = STRIP(FileList);

    /* perform CVS operation */
    'CALL cvs' Action Files ' 2>&1 |' CvsPager;
    IF (TRANSLATE( CvsPager) = 'MORE') THEN 'PAUSE';
 END;
 RETURN(0);

/* ========================================================================= */
GetArchiveRoot: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG ArchiveName, ArchiveFile;

 ArchiveRoot = '';

 DO UNTIL (TRUE)

    /* search project within file */
    rc = SysFileSearch( ArchiveName, ArchiveFile, 'Line.');
    IF (rc \= 0) THEN
       LEAVE;

    DO i = 1 TO Line.0
       IF (LEFT(Line.i,1) = ';' ) THEN ITERATE;

       /* if description is missing, append last part of path */
       IF (WORDS( Line.i) < 2) THEN
       DO
          PathWords = TRANSLATE( Line, ' ', '/');
          Line.i = Line.i WORD( PathWords, WORDS( PathWords));
       END;
       IF (WORDS( Line.i) < 2) THEN ITERATE;

       PARSE VAR Line.i ThisRoot ThisName
       ThisName = STRIP(ThisName);
       PARSE VAR ThisRoot ThisServer':'ThisDirectory;
       ThisTag = FILESPEC('N', ThisDirectory);
       IF (TRANSLATE(ThisTag) = TRANSLATE(ArchiveName)) THEN
       DO
          ArchiveRoot = ThisRoot;
          LEAVE;
       END;
    END;
 END;

 RETURN(ArchiveRoot);

/* ========================================================================= */
FixArchiveSnapshot: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG CvsRoot;

 /* search all files within the working directory */
 Filename = '*';
 Options  = 'OFS';
 rc = SysFileTree(FileName, 'File.', Options);
 IF (rc \= 0) THEN
 DO
    SAY 'Error in SysFileTree';
    EXIT(8);
 END;

 IF (File.0 = 0) THEN
 DO
    SAY 'No files found to fix.';
    EXIT(ERROR.NO_MORE_FILES);
 END;

 RootFileName          = '\CVS\Root';
 RootFileNameLen       = LENGTH( RootFileName);
 RepositoryFileName    = '\CVS\Repository';
 RepositoryFileNameLen = LENGTH( RepositoryFileName);

 SAY;
 CALL CHAROUT, 'Fixing CVS files ';
 DO i = 1 TO File.0
    SELECT
       WHEN (RIGHT( File.i, RootFileNameLen) = RootFileName) THEN
       DO
          CALL CHAROUT, '.';
          rc = SysFileDelete( File.i);
          rc = LINEOUT( File.i, CvsRoot);
          rc = LINEOUT( File.i);
       END;

       WHEN (RIGHT( File.i, RepositoryFileNameLen) = RepositoryFileName) THEN
       DO
          CvsRepository = LINEIN( File.i);
          rc = LINEOUT( File.i);
          IF (POS('\', CvsRepository) > 0) THEN
          DO
             CALL CHAROUT, '.';
             rc = SysFileDelete( File.i);
             rc = LINEOUT( File.i, unixslash(CvsRepository));
             rc = LINEOUT( File.i);
          END;
       END;

       OTHERWISE NOP
    END;  /* select */
 END;

 SAY ' Done.'
 SAY;

 EXIT(rc);

