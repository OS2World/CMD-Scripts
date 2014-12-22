/*
 *      INSTALL.CMD - NOSA Client - V1.06 C.Langanke 1999,2001
 *
 *     Syntax: install [/Reset]
 *
 *       /Reset - resets all values to default
 *
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

 GlobalVars = 'Title CmdName env TRUE FALSE Redirection ERROR. CrLf';
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
 GlobalVars          = GlobalVars '';
 IniAppName          = 'NOSAC';
 rc                  = ERROR.NO_ERROR;

 BootDrive           = GetInstDrive();
 CallDir             = GetCallDir();

 CvsZip              = 'CVS???.ZIP';
 CvsNewlyInstalled   = FALSE;

 PromptServer        = 'Netlabs Open Source Archive Server' CRLF;
 PromptArchiveRoot   = 'root directory of the Netlabs Open Source Archive'CRLF;
 PromptWorkRoot      = 'root directory for working directories on your computer'CRLF;
 PromptInitCommand   = 'Init Command for project windows (optional)'CRLF;
 PromptUser          = 'CVS User Id (specify guest for readonly access)'CRLF;
 PromptHome          = 'CVS home directory'CRLF;
 PromptPager         = 'pager executable'CRLF;

 DO UNTIL (TRUE)

    /* reset to default ? */
    ARG Option .
    IF (POS( Option, '/RESET') = 1) THEN
    DO
       'CLS'
       SAY;
       SAY Title
       SAY;
       SAY;
       SAY 'Restored to default values !';
       SAY;
       rcx = SysIni(, IniAppName, 'DELETE:');
       'PAUSE';
    END;

    /* get init vars */
    CvsExe         = ReadIniValue(, IniAppName, 'CVS_EXE');
    CvsServer      = ReadIniValue(, IniAppName, 'CVS_SERVER', 'www.netlabs.org');
    CvsBinRoot     = ReadIniValue(, IniAppName, 'CVS_BINROOT');
    CvsWorkRoot    = ReadIniValue(, IniAppName, 'CVS_WORKROOT');
    CvsInitCommand = ReadIniValue(, IniAppName, 'CVS_INITCOMMAND');
    CvsUser        = ReadIniValue(, IniAppName, 'CVS_USER', VALUE('USER',,env));
    CvsHome        = ReadIniValue(, IniAppName, 'CVS_HOME', VALUE('HOME',,env));
    CvsPager       = ReadIniValue(, IniAppName, 'CVS_PAGER', 'more');
    fCvsInPath = (SysSearchPath('PATH', 'CVS.EXE') \= '');

    /* install CVS ? */
    IF ((\fCvsInPath) & (CvsExe = '')) THEN
    DO
       'CLS'
       SAY;
       SAY Title
       SAY;
       SAY 'CVS could not be found in your executable PATH.';
       SAY;
       SAY '- If it is not already installed on your system, you can install it now.';
       SAY '- If it is installed, but the cvs\bin directory is not included in your PATH,'
       SAY '  you can instead specify the location, where you installed it.';


       /* search cvs???.zip */
       Options  = 'OF';
       rc = SysFileTree( CvsZip, 'File.', Options);
       IF (rc \= ERROR.NO_ERROR) THEN
       DO
          SAY CmdName': error in SysFileTree: not enough memory.';
          rc = ERROR.NOT_ENOUGH_MEMORY;
          LEAVE;
       END;

       IF (ProceedWith('Do you want to install CVS now')) THEN
       DO
          /* search unzip.exe */
          IF (SysSearchPath('PATH', 'UNZIP.EXE') = '') THEN
          DO
             SAY;
             SAY CmdName': error : CVS could not be unpacked, because unzip.exe is missing.';
             rc = ERROR.FILE_NOT_FOUND;
             LEAVE;
          END;

          /* how many packages available */
          IF (File.0 = 0) THEN
          DO
             SAY 'Please provide the current CVS???.ZIP in' CallDir 'or install';
             SAY 'CVS manually. In the latter case it is not mandantory to add the'
             SAY 'cvs\bin directory to your PATH, as this is not required by the'
             SAY 'Netlabs Open Source Archive Client.';
             rc = ERROR.FILE_NOT_FOUND;
             LEAVE;
          END;

          IF (File.0 = 1) THEN
             CvsZip = File.1;
          ELSE
          DO
             DO WHILE (TRUE)
                SAY;
                SAY 'Multiple CVS package zip files have been found.';
                DO i = 1 TO File.0
                   SAY RIGHT( i, 3) '-' File.i;
                END;
                Choice = PullVariable( '1', 'Please select one to install');
                SAY;

                /* check selection */
                IF (DATATYPE( Choice) \= 'NUM') THEN
                   SAY 'error: selection not numeric.';

                Choice = Choice + 0; /* string to number */
                IF ((Choice < 1) | (Choice > File.0)) THEN
                   SAY 'error: invalid selection.';
                ELSE
                DO
                   CvsZip = File.Choice;
                   LEAVE;
                END;


                SAY 'Please try again.';
                'PAUSE';
             END;
          END;

          /* ask for directory */
          DO WHILE (TRUE)
             CvsBinRoot  = STRIP(PullVariable( BootDrive'\cvs', 'Where should CVS be installed'));
             IF (ProceedWith('Is this correct')) THEN
                LEAVE;
          END;

          /* install cvs */
          'call unzip -o' CvsZip '-d' CvsBinRoot;

          CvsInstalled = FileExist( CvsBinRoot'\BIN\CVS.EXE');

          IF ((rc = ERROR.NO_ERROR) & (CvsInstalled)) THEN
          DO
             CvsNewlyInstalled = TRUE;
             SAY;
             SAY 'CVS has been installed successfully.';
             SAY 'NOTE:';
             SAY ' The cvs\bin directory has not been added to your PATH, as this is';
             SAY ' not neccessary for the Netlabs Open Source Archive Client.';
             SAY;
             'PAUSE';
          END;
          ELSE
          DO
             SAY;
             SAY CmdName': error: CVS was not properly installed.'
             SAY 'Please try again. Install aborted.';
             LEAVE;
          END;
       END;
    END;

    /* set some defaults */
    IF (CvsWorkRoot = '') THEN CvsWorkRoot = 'c:\work';
    IF (Cvshome     = '') THEN CvsHome     = 'c:\home';

    DO WHILE (TRUE)
       'CLS';
       SAY;
       SAY Title
       SAY;
       SAY 'Please enter/modify the following values:';
       SAY '- press Enter if the default value in brackets applies';
       SAY '- press Ctrl-Break and Enter to abort';
       CvsServer      = STRIP(PullVariable( CvsServer,      PromptServer));
       CvsServer      = SPACE( CvsServer, 0);

       CvsWorkRoot    = STRIP(PullVariable( CvsWorkRoot,    PromptWorkRoot));
       rcx            = CreateCvsDir( CvsWorkRoot);
       CvsHome        = STRIP(PullVariable( CvsHome,        PromptHome));
       rcx            = CreateCvsDir( CvsHome);

       IF (\FileExist( CvsHome)) THEN
          'COPY' CallDir'\samples\.cvsrc' CvsHome'\' Redirection;

       CvsInitCommand = STRIP(PullVariable( CvsInitCommand, PromptInitCommand));
       CvsUser        = STRIP(PullVariable( CvsUser,        PromptUser));
       CvsPager       = STRIP(PullVariable( CvsPager,       PromptPager));

       IF (\CvsNewlyInstalled) THEN
       DO
          /* check for CVS.EXE */
          CvsExe = SysSearchPath('PATH', 'CVS.EXE');
          fCvsInPath = (CvsExe \= '');
          IF (\fCvsInPath) THEN
          DO
             CvsBinRoot  = STRIP(PullVariable( CvsBinRoot, 'Directory of CVS installation'CRLF));
             CvsExe      = CvsBinRoot'\bin\cvs.exe';
          END;
       END;

       IF (ProceedWith('Are these values correct')) THEN
       DO

          MissingVar = '';
          SELECT
             WHEN (CvsServer = '')      THEN MissingVar = PromptServer;
             WHEN (CvsWorkRoot = '')    THEN MissingVar = PromptWorkRoot;
             WHEN (CvsUser = '')        THEN MissingVar = PromptUser
             WHEN (CvsHome = '')        THEN MissingVar = PromptHome;
             OTHERWISE NOP;
          END;

          IF (MissingVar \= '') THEN
          DO
             SAY CmdName': Error: The value for the';
             SAY ' "'MissingVar'"';
             SAY 'may not be empty.';
             'PAUSE'
             ITERATE;
          END;

          /* check Cvs bin */
          IF (\fCvsInPath) THEN
             IF (\FileExist( CvsBinRoot'\BIN\CVS.EXE')) THEN
             DO
                SAY CmdName': Error: CVS.EXE not found in' CvsBinRoot'\bin';
                'PAUSE'
                ITERATE;
             END;

          /* all values ok */
          LEAVE;
       END;
    END;

    /* write new values */
    rcx = SysIni(, IniAppName,   'CVS_SERVER',      CvsServer);
    rcx = SysIni(, IniAppName,   'CVS_WORKROOT',    CvsWorkRoot);
    rcx = SysIni(, IniAppName,   'CVS_INITCOMMAND', CvsInitCommand);
    rcx = SysIni(, IniAppName,   'CVS_USER',        CvsUser);
    rcx = SysIni(, IniAppName,   'CVS_HOME',        CvsHome);
    IF (STRIP(CvsPager) = '') THEN
       CvsPager = 'more';
    rcx = SysIni(, IniAppName,   'CVS_PAGER',       CvsPager);
    IF (\fCvsInPath) THEN
       rcx = SysIni(, IniAppName, 'CVS_BINROOT',     CvsBinRoot);
    rcx = SysIni(, IniAppName, 'CVS_EXE',           CvsExe);

    /* install folder now ? */
    IF (\SysSetObjectData( '<NETLABS_NOSAC_FOLDER>', ';')) THEN
       'CALL' CallDir'\cvswps';

 END;

 EXIT( rc);

/* ------------------------------------------------------------------------- */
HALT:
 SAY;
 SAY 'Interrupted by user.';
 EXIT(ERROR.GEN_FAILURE);

/* ------------------------------------------------------------------------- */
ShowHelp: PROCEDURE EXPOSE (GlobalVars)

 SAY;
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

/* ========================================================================= */
ReadIniValue: PROCEDURE
PARSE ARG IniFile, IniAppname, IniKeyName, Default

 IniValue = SysIni(IniFile, IniAppname, IniKeyName);
 IF (IniValue = 'ERROR:') THEN
    IniValue = '';

 IF ((IniValue \= '') & (RIGHT(IniValue, 1) = "00"x)) THEN
    IniValue = LEFT( IniValue, LENGTH( IniValue) - 1);

 IF (IniValue = '') THEN
    IniValue = Default;

 RETURN( IniValue);

/* ------------------------------------------------------------------------- */
PullVariable: PROCEDURE
 PARSE ARG Default, Message

 SAY;
 CALL CHAROUT, Message '['Default'] : ';
 PARSE PULL PullVar;
 IF (LENGTH(PullVar) > 0) THEN
    RETURN(PullVar);
 ELSE
    RETURN(Default);

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
GetInstDrive: PROCEDURE EXPOSE env
 ARG DirName, EnvVarName

 /* Default: OS2-Verzeichnis -> ermittelt BootDrive */
 IF (DirName = '') THEN DirName = '\OS2';

 /* Default: PATH  */
 IF (EnvVarName = '') THEN EnvVarName = 'PATH';

 /* Wert holen */
 PathValue = VALUE(EnvVarName,,env);

 /* Eintrag suchen und Laufwerk zurÅckgeben */
 DirName = ':'DirName';';
 EntryPos = POS(DirName, PathValue) - 1;
 IF (EntryPos = -1) THEN
    RETURN('');
 InstDrive = SUBSTR(PathValue, EntryPos, 2);
 RETURN(InstDrive);

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

/* ------------------------------------------------------------------------- */
GetCalldir: PROCEDURE
PARSE SOURCE . . CallName
 CallDir = FILESPEC('Drive', CallName)||FILESPEC('Path', CallName);
 RETURN(LEFT(CallDir, LENGTH(CallDir) - 1));

/* ========================================================================= */
MakePath: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG PathName

 PARSE SOURCE . . CallName
 FileName = SUBSTR( CallName, LASTPOS( '\', CallName) + 1);
 'XCOPY' CallName PathName'\' Redirection;
 rcx = SysFileDelete( PathName'\'FileName);
 RETURN( rc);

/* ========================================================================= */
CreateCvsDir: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG Dirname;

 Dirname =STRIP( Dirname);
 IF (Dirname = '') THEN
    RETURN('');

 IF (\DirExist( DirName)) THEN
 DO
    IF (ProceedWith( 'The directory' Dirname' does not yes exist.'CrLf'Should it be created now')) THEN
       rcx = MakePath( DirName);
 END;

 RETURN(DirName);

