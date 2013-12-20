/*
 *      2HOBBES.CMD - V1.04 C.Langanke 2001-2004
 *
 *      Syntax: 2hobbes [<zipfile> [[<zipfile]...]]
 *
 *      zipfile - specifies a zipfilename or file mask. If ommitted,
 *                all zipfiles within the current directory are pocessed.
 *
 *      For anonymous upload to hobbes your email address is required.
 *      Set this as value of the the environment variable 2HOBBES_UPLOAD_PASSWD
 *      or include the line "uploadpasswd=<your_email_address>" into the
 *      file %HOME%\.2hobbesrc
 *
 *      In order to check the file file_id.diz for a certain contents of the
 *      last line (should contain the Author name and/or email address), set
 *      set this as value of the environment variable 2HOBBES_DIZ_LASTLINE
 *      or include the line "dizlastline=<contents of lastline>" into the
 *      file %HOME%\.2hobbesrc
 *
 *      This program uploads program packages and their description .txt file
 *      to the /pub/incoming directory of the Hobbes File Archive
 *      (hobbes.nmsu.edu). The description file must reside in the same
 *      directory as the ZIP file. The zip file and the description text are
 *      checked for certain restrictions, see the online documentation for
 *      details. The names are converted to all lowercase characters during upload.
 *
 *      Required:
 *       - REXX, TCP/IP and RXFTP.DLL installed
 *       - THE LATEST UPLOAD DESCRIPTION TEMPLATE FROM HOBBES !
 *       - UNZIP.EXE of Info.Zip (http://www.info-zip.org)
 *       - a working internet connection
 */
/* first comment is used as online help text */

 SIGNAL ON HALT

 TitleLine = STRIP(SUBSTR(SourceLine(2), 3));
 PARSE VAR TitleLine CmdName'.CMD 'Info
 Title     = CmdName Info

 env          = 'OS2ENVIRONMENT';
 TRUE         = (1 = 1);
 FALSE        = (0 = 1);
 Redirection  = '> NUL 2>&1';
 '@ECHO OFF'

 /* OS/2 Errorcodes */
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
 ERROR.ENVVAR_NOT_FOUND   = 204;

 GlobalVars = 'Title CmdName env TRUE FALSE Redirection ERROR.';

 /* show help */
 ARG Parm .
 IF (POS('?', Parm) > 0) THEN
 DO
    rc = ShowHelp();
    EXIT(ERROR.INVALID_PARAMETER);
 END;

 /* Defaults */
 GlobalVars = GlobalVars 'Upload. Ftp. ZipExec TmpDir Diz.';
 rc         = ERROR.NO_ERROR;

 FilesProcessed = 0;

 TmpDir     = VALUE('TMP',,env);
 TmpOutFile = SysTempFilename( TmpDir'\2hobbes.???');

 ConfigFile = VALUE( 'HOME',,env)'\.2hobbesrc';

 ZipExec    = SysSearchPath( 'PATH', 'UNZIP.EXE');

 Ftp._Host      = 'hobbes.nmsu.edu';
 Ftp._Userid    = 'anonymous';
 Ftp._Passwd    = '';                 /* is determined below ! */
 Ftp._Directory = '/pub/incoming';

 Diz.LastLine   = '';


 /* load DLLS */
 CALL RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 CALL SysLoadFuncs
 CALL RxFuncAdd    'FtpLoadFuncs', 'RXFTP',    'FtpLoadFuncs'
 CALL FtpLoadFuncs 'QUIET'

 SAY;
 DO UNTIL (TRUE)

    /* everything there */
    IF (ZipExec = '') THEN
    DO
       SAY CmdName': error: UNZIP.EXE of Info-ZIP not found.';
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;

    /* get upload password */
    Ftp._Passwd = GetConfigValue( ConfigFile, 'uploadpasswd', '2HOBBES_UPLOAD_PASSWD');
    IF (Ftp._Passwd = '') THEN
    DO
       SAY CmdName': error: upload password is not configured.'
       rc = ERROR.ENVVAR_NOT_FOUND;
       LEAVE;
    END;

    /* use alternative settings for testing purposes (not documented elsewhere) */
    TestHost = GetConfigValue( ConfigFile, 'uploadhost', '2HOBBES_UPLOAD_HOST');
    IF (TestHost \= '') THEN
       Ftp._Host = TestHost;
    TestDir = GetConfigValue( ConfigFile, 'uploaddir', '2HOBBES_UPLOAD_DIR');
    IF (TestDir \= '') THEN
       Ftp._Directory = TestDir;

    /* check for desired contents of last line of file_id.diz */
    Diz.LastLine = GetConfigValue( ConfigFile, 'dizlastline', '2HOBBES_DIZ_LASTLINE');

    /* check parms */
    PARSE ARG ZipList;
    IF (STRIP( ZipList) = '') THEN
       ZipList = '*.zip';

    /* process list */
    DO WHILE (ZipList \= '')

       PARSE VAR ZipList ThisMask ZipList;

       /* read fileanmes */
       DROP( Zip.);
       rc = SysFileTree( ThisMask, 'Zip.', 'FO');
       IF (rc \= ERROR.NO_ERROR) THEN
       DO
          SAY CmdName': error in SysFileTree, rc='rc;
          LEAVE;
       END;

       /* process files */
       DO z = 1 TO Zip.0
          rcx = ProcessZipFile( TmpOutFile, Zip.z);
          FilesProcessed = FilesProcessed + 1;
       END;

    END;

    SAY;
    SAY FilesProcessed 'files processed.';

 END;

 EXIT(rc)

/* ------------------------------------------------------------------------- */
HALT:
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

/* ------------------------------------------------------------------------- */
GetInstDrive: PROCEDURE EXPOSE env
 ARG DirName, EnvVarName

 /* Default: get OS2 directory: this is also the boot drive */
 IF (DirName = '') THEN DirName = '\OS2';

 /* Default: search in PATH  */
 IF (EnvVarName = '') THEN EnvVarName = 'PATH';
 PathValue = VALUE(EnvVarName,,env);

 /* search entry and return drive letter */
 DirName = ':'DirName';';
 EntryPos = POS(DirName, PathValue) - 1;
 IF (EntryPos = -1) THEN
    RETURN('');
 InstDrive = SUBSTR(PathValue, EntryPos, 2);
 RETURN(InstDrive);

/* ------------------------------------------------------------------------- */
GetDrivePath: PROCEDURE
 PARSE ARG FileName

 FullPath = FILESPEC('D', FileName)||FILESPEC('P', FileName);
 IF (FullPath \= '') THEN
    RETURN(LEFT(FullPath, LENGTH(FullPath) - 1));
 ELSE
    RETURN('');

/* ------------------------------------------------------------------------- */
LOWER: PROCEDURE

 Lower = 'abcdefghijklmnopqrstuvwxyz„”';
 Upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZŽ™š';

 PARSE ARG String
 RETURN(TRANSLATE(String, Lower, Upper));

/* ========================================================================= */
UploadFile: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG LocalFile, RemoteFile, FileType;

 CALL CHAROUT, 'Uploading' RemoteFile '... ';
 rc = FtpPut( LocalFile, RemoteFile, FileType);
 IF (rc \= ERROR.NO_ERROR) THEN
    SAY 'Error! Reason is' FTPERRNO;
 ELSE
    SAY 'Ok.';

 RETURN( rc);

/* ========================================================================= */
GetConfigValue: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG File, Key, Envvar;

 KeyValue = '';

 DO UNTIL (TRUE)
    IF (\FileExist( File)) THEN
       LEAVE;

    rc = SysFileSearch( Key, File, 'Line.', 'C');
    IF (rc \= ERROR.NO_ERROR) THEN
    DO
       SAY CmdName': error in SysFileSearch, rc='rc;
       EXIT( rc);
    END;
    IF (Line.0 > 0) THEN
    DO
       ThisLine = STRIP( Line.1);
       IF (LEFT( ThisLine, 1) \= ';') THEN
       DO
          PARSE VAR Line.1 .'='KeyValue;
          KeyValue = STRIP( KeyValue);
       END;
    END;
 END;

 /* fallback to environment */
 IF ((KeyValue = '') & (Envvar \='')) THEN
    KeyValue = STRIP( VALUE( Envvar,,env));
 RETURN( KeyValue);

/* ========================================================================= */
StripVersionNumber: PROCEDURE
 PARSE ARG Version;

 NewVersion = '';

 DO WHILE (LENGTH( Version) > 0)
    PARSE VAR Version c +1 Version;
    IF (POS( c, '1234567890') > 0) THEN
       NewVersion = NewVersion''c;
 END;

 RETURN( NewVersion);

/* ========================================================================= */
CompareVersions: PROCEDURE
 PARSE ARG Version1, Version2;

 fMatch = FALSE;
 Version1 = StripVersionNumber( Version1);
 Version2 = StripVersionNumber( Version2);
 RETURN( Version1 = Version2);

/* ========================================================================= */
GetVersionNumberFromName: PROCEDURE
 PARSE ARG File;

 VersionNumber = '';
 ValidChars = '1234567890-._';

 /* isolate version number */
 Filename = FILESPEC( 'N', File);
 Filename = REVERSE( LEFT( Filename, LASTPOS( '.', FileName) - 1));

 /* read up to first valid char */
 DO WHILE (POS( LEFT( Filename, 1), ValidChars) = 0)
    PARSE VAR Filename c +1 Filename;
    VersionNumber = VersionNumber''c;
 END;
 /* read up to first nonvalid char */
 DO WHILE (POS( LEFT( Filename, 1), ValidChars) > 0)
    PARSE VAR Filename c +1 Filename;
    VersionNumber = VersionNumber''c;
 END;

 VersionNumber = REVERSE( VersionNumber);

 RETURN( VersionNumber);

/* ========================================================================= */
GetDescriptionValue: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG File, Key, Description;
 DescValue = '';

 rc = SysFileSearch( Key, File, 'Line.', 'C');
 IF (rc \= ERROR.NO_ERROR) THEN
 DO
    SAY CmdName': error in SysFileSearch, rc='rc;
    EXIT( rc);
 END;
 IF (Line.0 > 0) THEN
 DO
    PARSE VAR Line.1 .':'DescValue;
    DescValue = STRIP( DescValue);
    CALL CHAROUT, '.';
 END;

 RETURN( DescValue);

/* ========================================================================= */
VerifyDescriptionFile: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG File, ZipFile;

 rc = ERROR.NO_ERROR;

 DO UNTIL (TRUE)

    /* check values */
    CALL CHAROUT, 'checking description file' File '' ;
    ArchiveName  = GetDescriptionValue( File, 'Archive Filename:',  'archive filename');
    ShortDesc    = GetDescriptionValue( File, 'Short Description:', 'short description');
    LongDesc     = GetDescriptionValue( File, 'Long Description:',  'long description');
    ProposedDir  = GetDescriptionValue( File, 'for placement:',     'proposed directory');
    SenderName   = GetDescriptionValue( File, 'Your name:',         'archivers name');
    EmailAddress = GetDescriptionValue( File, 'Email address:',     'archivers email address');

    SELECT
       WHEN (TRANSLATE( ArchiveName) \= TRANSLATE( FILESPEC( 'N', ZipFile))) THEN
          ErrorMsg = 'archive name does not match';
       WHEN (ShortDesc = '') THEN
          ErrorMsg = 'short description not set';
       WHEN (LongDesc = '') THEN
          ErrorMsg = 'long description not set';
       WHEN (ProposedDir = '') THEN
          ErrorMsg = 'proposed directory not set';
       WHEN (SenderName = '') THEN
          ErrorMsg = 'Name of sender not set';
       WHEN (EmailAddress = '') THEN
          ErrorMsg = 'email address of sender not set';
       OTHERWISE
          ErrorMsg = '';
    END;
    IF (ErrorMsg \= '') THEN
    DO
       SAY ' error !';
       SAY 'Invalid description file:' ErrorMsg;
       rc = ERROR.INVALID_DATA;
       LEAVE;
    END;
    ELSE
      SAY ' Ok.';

 END;

 RETURN( rc);

/* ========================================================================= */
VerifyDizFile: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG ZipFile, VersionNumber;

 rc       = ERROR.NO_ERROR;
 Dizfile  = TmpDir'\file_id.diz';
 ErrorMsg = '';

 LineNo   = 0;
 Line.    = '';

 DO UNTIL (TRUE)

    CALL CHAROUT, 'checking file_id.diz in  ' ZipFile '';
    rcx = SysFileDelete( DizFile);
    /* unpack file, ignore rc = 1 of newer UNZIP versions */
    'unzip -o' ZipFile '-d' TmpDir 'file_id.diz'  Redirection
    IF (rc > 1) THEN
    DO
       ErrorMsg = 'file_id.diz not found';
       LEAVE;
    END;
    rc = ERROR.NO_ERROR;

    /* read in all lines of file */
    rcx = STREAM( DizFile, 'C', 'OPEN READ');
    DO WHILE (LINES( DizFile) > 0)

       CALL CHAROUT, '.';

       /* check maximum number of lines */
       LineNo = LineNo + 1;
       IF( LineNo > 10) THEN
       DO
          ErrorMsg = 'file_id.diz exceeds 10 lines of text.';
          LEAVE;
       END;

       /* check line length */
       Line.LineNo = LINEIN( DizFile);
       IF (LENGTH( Line.LineNo) > 45) THEN
       DO
          ErrorMsg = 'Line' LineNo 'of file_id.diz exceeds 45 characters';
          LEAVE;
       END;

       /* check first line */
       IF (LineNo = 1) THEN
       DO
          CALL CHAROUT, '.';
          DizVersion = TRANSLATE(WORD( Line.LineNo, 1));
       END;

    END;
    rcx = STREAM( DizFile, 'C', 'CLOSE');
    IF (ErrorMsg \= '') THEN
       LEAVE;

    /* compare versions */
    CALL CHAROUT, '.';
    IF (\CompareVersions( VersionNumber, DizVersion)) THEN
    DO
       ErrorMsg = 'Version number in file_id.diz does not match with filenames.';
       LEAVE;
    END;

    /* check lastline if requested */
    IF (Diz.LastLine \= '') THEN
    DO
       IF (Diz.LastLine \= Line.LineNo) THEN
       DO
          ErrorMsg = 'Last line of file_id.diz does not match requested value.';
          LEAVE;
       END;
    END;

 END;

 /* cleanup */
 IF (ErrorMsg \= '') THEN
 DO
    SAY ' error !';
    SAY '-' ErrorMsg;
    rc = ERROR.INVALID_DATA;
 END;
 ELSE
    SAY ' Ok.';
 rcx = SysFileDelete( DizFile);
 RETURN( rc);

/* ========================================================================= */
ProcessZipFile: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG TmpOutFile, ZipName;

 rc = ERROR.NO_ERROR;

 DO UNTIL (TRUE)

    SAY COPIES( '-', 50);

    /* determine name of description file */
    TxtName = OVERLAY( '.txt', ZipName, LASTPOS( '.', ZipName));
    IF (\FileExist( TxtName)) THEN
    DO
       SAY TxtName 'not found, zipfile' FILESPEC( 'N', ZipName) 'skipped.';
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;

    /* verify description file */
    rc = VerifyDescriptionFile( TxtName, ZipName);
    IF (rc \= ERROR.NO_ERROR) THEN
    DO
       rc = ERROR.INVALID_FORMAT;
       LEAVE;
    END;

    /* determine version number of package */
    VersionNumber = GetVersionNumberFromName( ZipName);
    IF (VersionNumber = '') THEN
    DO
       SAY 'The name' ZipName 'contains an invalid version number.';
       rc = ERROR.INVALID_PARAMETER;
       LEAVE;
    END;

    /* verify file_id.diz file */
    rc = VerifyDizFile( ZipName, VersionNumber);
    IF (rc \= ERROR.NO_ERROR) THEN
    DO
       rc = ERROR.INVALID_FORMAT;
       LEAVE;
    END;

    /* log on */
    CALL CHAROUT, 'Connect to               ' Ftp._Host '... ';
    IF (\FtpSetUser( Ftp._Host, Ftp._Userid, Ftp._Passwd)) THEN
    DO
       SAY;
       SAY CmdName': fatal error: cannot connect to' Ftp._Host;
       EXIT( ERROR.INVALID_FUNCTION);
    END;
    SAY 'Ok.';

    /* upload files */
    rc = UploadFile( ZipName, Ftp._Directory'/'LOWER( FILESPEC( 'N', ZipName)), 'BINARY');
    IF (rc = ERROR.NO_ERROR) THEN
       rc = UploadFile( TxtName, Ftp._Directory'/'LOWER( FILESPEC( 'N', TxtName)), 'ASCII');

 END;

 RETURN( rc);

