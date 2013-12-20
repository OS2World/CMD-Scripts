/*
 *      MZPIPINST.CMD - Mozilla Plug-In Pack Installer - V1.01 C.Langanke 2003
 *
 *      Syntax: MZPIPINST <exename>
 *
 *       exename - full pathname of the Netscape PluginPak archive file
 *                 (Default: nspip30.exe)
 *
 *      This script allows the installation of the
 *      OS/2 Plug-In Pack v3.0 for Netscape Communicator
 *      top of Netscape and/or Mozilla.
 *
 *      For this Netscape Communicator may be, but does
 *      not have to be installed.
 */
/* The first comment is used as online help text */

 SIGNAL ON HALT

 TitleLine = STRIP(SUBSTR(SourceLine(2), 3));
 PARSE VAR TitleLine CmdName'.CMD 'Info
 Title     = CmdName Info

 env          = 'OS2ENVIRONMENT';
 TRUE         = (1 = 1);
 FALSE        = (0 = 1);
 CrLf         = '0d0a'x;
 Redirection  = '> NUL 2>&1';
 '@ECHO OFF'

 /* OS/2 Error codes */
 ERROR.NO_ERROR           =   0;
 ERROR.INVALID_FUNCTION   =   1;
 ERROR.FILE_NOT_FOUND     =   2;
 ERROR.PATH_NOT_FOUND     =   3;
 ERROR.ACCESS_DENIED      =   5;
 ERROR.NOT_ENOUGH_MEMORY  =   8;
 ERROR.INVALID_FORMAT     =  11;
 ERROR.INVALID_DATA       =  13;
 ERROR.NO_MORE_FILES      =  18;
 ERROR.WRITE_FAULT        =  29;
 ERROR.READ_FAULT         =  30;
 ERROR.GEN_FAILURE        =  31;
 ERROR.INVALID_PARAMETER  =  87;
 ERROR.ENVVAR_NOT_FOUND   = 203;

 GlobalVars = 'Title CmdName CrLf env TRUE FALSE Redirection ERROR.';
 SAY;

 /* eventually show help */
 ARG Parm .
 IF (POS('?', Parm) > 0) THEN
 DO
    rc = ShowHelp();
    EXIT(ERROR.INVALID_PARAMETER);
 END;

 call RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 call SysLoadFuncs

 /* defaults */
 GlobalVars = GlobalVars 'TmpDir';

 NsPipExec = 'nspip30.exe';
 PkgFile = 'OS2PIP30.PKG';
 CatFile = 'OS2PIP3.ICF';
 SiPkgFile = 'install.in_';
 NsPkgFile = 'nsplugs.in_';

 IniAppName     = 'Netscape';
 IniKeyNetscape = '4.6';
 IniKeyMozilla  = '6.0';

 fNetscapeFaked = FALSE;

 PlugDllList = 'PWS=program/plugins/npos2aud.dll PWS=program/plugins/npos2vid.dll PWS=program/plugins/npos2mid.dll';

 TmpDir = VALUE( 'TMP',,env);

 UnpackDir = '';
 NsFakeDir = '';


 DO 1
    SAY Title;
    SAY;

    /* read file from command line */
    PARSE ARG Parm .;
    Parm = STRIP( Parm);
    IF (Parm \= '') THEN
       NsPipExec = Parm;

    /* check for executable */
    IF (\FileExist( NsPipExec)) THEN
    DO
       SAY 'error: Netscape PluginPak executable' FILESPEC( 'N', NsPipExec) 'not found.';
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;
    NsPipExec = STREAM( NsPipExec, 'C','QUERY EXISTS');

    /* check for Netscape and Mozilla installation */
    SAY '- detecting internet browser installations';
    NetscapeDir  = GetBrowserDir( IniAppName, IniKeyNetscape, 'program\netscape.exe', '');
    MozillaDir   = GetBrowserDir( IniAppName, IniKeyMozilla, 'mozilla.exe', '');

    /* abort if no browser installed */
    IF ((NetscapeDir = '') & (MozillaDir = '')) THEN
    DO
       SAY 'error: nether Netscape nor Mozilla is installed.';
       rc = ERROR.PATH_NOT_FOUND;
       LEAVE;
    END;

    IF (NetscapeDir \= '') THEN SAY '    Netscape installation found at' NetscapeDir;
    IF (MozillaDir  \= '') THEN SAY '    Mozilla installation found at' MozillaDir;

    /* create temporary directory */
    UnpackDir = SysTempFilename( TmpDir'\nspip.???');
    rcx = SysMkDir( UnpackDir);
    rcx = DIRECTORY( UnpackDir);
    SAY '- unpack Netscape PluginPak executable';
    '' NsPipExec Redirection;

    /* if Netscape is not available, fake installation data */
    IF (NetscapeDir = '') THEN
    DO

       fNetscapeFaked = TRUE;

       /* write installation path for Netscape, set it to Mozilla */
       SAY '- temporarily enable installation Netscape PluginPak to Mozilla directory';
       NsFakeDir = MozillaDir;
       rcx = SysIni(, IniAppName, IniKeyNetscape, NsFakeDir'0'x);
       rcx = SysMkDir( NsFakeDir);

       /* copy SI executables to fake dir, so that the deinstallation program is available */
       SAY '- unpack deinstallation program to Mozilla directory';
       NsSinstDir = NsFakeDir'\siutil';
       rc = CopySiFiles( UnpackDir'\'SiPkgFile, NsSinstDir);

       /* modify package file */
       SAY '- prepare installation of Plugins for Mozilla';
       rcx = ModifyNsPipFile( PkgFile);

       /* create folder within Mozilla folder */
       IF (\SysSetObjectData( '<MOZILLAFLDR>', ';')) THEN
          rcx = SysCreateObject( 'WPFolder', 'Mozilla>', '<WP_DESKTOP>', 'OBJECTID=<MOZILLAFLDR>;');

       SAY '- creating Plugin Folder in Mozilla folder';
       ObjectTitle = DetermineFolderTitle( CatFile, 'OS/2 PluginPak');
       rcx = SysCreateObject( 'WPFolder', ObjectTitle, '<MOZILLAFLDR>', 'OBJECTID=<MZPIP_FOLDER>;');
    END;
    ELSE
    DO
       /* create Netscape folder, if it does not exist */
       IF (\SysSetObjectData( '<NS46_FOLDER>', ';')) THEN
       DO
          SAY '- Netscape folder is missing, creating folder';
          rcx = SysCreateObject( 'WPFolder', 'Netscape Communicator 4.61', '<WP_DESKTOP>', 'OBJECTID=<NS46_FOLDER>;');
       END;

       /* copy SI executables to Netscape installation, if not there */
       NsSinstDir = NetscapeDir'\siutil';
       rc = CopySiFiles( UnpackDir'\'SiPkgFile, NsSinstDir);

       IF (MozillaDir \= '') THEN
       DO
          SAY '- prepare additional installation of Plugins also for Mozilla';

          /* if mozilla is installed, copy plugin DLLs also to Mozilla */
          FileList = PlugDllList;
          DO WHILE (FileList \= '')
             PARSE VAR FileList ThisKey'='ThisFile FileList;
             'unpack' NsPkgFile '/N:'FILESPEC( 'N', ThisFile) Redirection;
          END;

          /* duplicate entries for plugin DLLs to */
          /* copy them also to Mozilla directory  */
          rcx = ExtendNsPipFile( PkgFile, PlugDllList, MozillaDir, 'plugins');
       END;

    END;

    /* call installation */
    SAY '- launch Netscape PluginPak installation program';
    'install' Redirection;

    /* remove fake setting again, it is not required for deinstallation or upgrade */
    IF (fNetscapeFaked) THEN
    DO
       SAY '- cleanup, disable installation Netscape PluginPak to Mozilla directory';
       rcx = SysIni(, IniAppName, IniKeyNetscape, 'DELETE:');
    END;

 END;

 IF (UnpackDir \= '') THEN
 DO
    /* cleanup unpack dir */
    SAY '- remove temporary files';
    'CD ..';
    rc = RemoveDirTree( UnpackDir);
 END;
 SAY 'Done.';

 RETURN( rc);

/* ------------------------------------------------------------------------- */
ShowHelp: PROCEDURE EXPOSE (GlobalVars)

 /* show title */
 SAY Title;
 SAY;

 PARSE SOURCE . . ThisFile

 /* skip header */
 DO i = 1 TO 3
    rc = LINEIN(ThisFile);
 END;

 /* show help text */
 ThisLine = LINEIN(Thisfile);
 DO WHILE (ThisLine \= ' */')
    SAY SUBSTR(ThisLine, 7);
    ThisLine = LINEIN(Thisfile);
 END;

 /* close file */
 rc = LINEOUT(Thisfile);

 RETURN('');

/* ------------------------------------------------------------------------- */
FileExist: PROCEDURE
 PARSE ARG FileName

 RETURN(STREAM(Filename, 'C', 'QUERY EXISTS') > '');

/* ========================================================================= */
GetBrowserDir: PROCEDURE
 PARSE ARG IniAppName, IniKeyName, ExecSubPath, SubPath;

 InstallDir = '';

 PARSE VALUE SysIni(, IniAppName, IniKeyName) WITH InstallDir'0'x;
 IF (InstallDir = 'ERROR:') THEN
    InstallDir = '';
 ELSE
 DO
    /* check for executable */
    IF (\FileExist( InstallDir'\'ExecSubPath)) THEN
       InstallDir = '';

    /* add subpath */
    IF ((InstallDir \= '') & (SubPath \= '')) THEN
       InstallDir = InstallDir'\'SubPath;

 END;

 RETURN( InstallDir);

/* ========================================================================= */
FileReplaceStr: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG File, SearchStr, ReplaceStr;

 rc = ERROR.NO_ERROR;

 TmpFile = SysTempFilename( DIRECTORY()'\nspip???');

 DO 1
    IF (STREAM( File, 'C', 'OPEN READ') \= 'READY:') THEN
       LEAVE;
    IF (STREAM( TmpFile, 'C', 'OPEN WRITE') \= 'READY:') THEN
       LEAVE;

    DO WHILE (LINES( File))

       ThisLine = LINEIN( File);

       StrPos = POS( SearchStr, ThisLine);
       IF (StrPos > 0) THEN
       DO

          ThisLine = DELSTR( ThisLine, StrPos, LENGTH( SearchStr));
          IF (ReplaceStr \= '') THEN
             ThisLine = INSERT( ReplaceStr, ThisLine, StrPos - 1);
       END;

       rcx = LINEOUT( TmpFile, ThisLine);
    END;

    /* close file and copy over */
    rcx = STREAM( File, 'C', 'CLOSE');
    rcx = STREAM( TmpFile, 'C', 'CLOSE');
    'COPY' TmpFile File Redirection;
    'DEL' TmpFile Redirection;
 END;


 /* cleanup */
 rcx = STREAM( File, 'C', 'CLOSE');
 rcx = STREAM( TmpFile, 'C', 'CLOSE');

 RETURN( rc);

/* ========================================================================= */
RemoveDirTree: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG Dir;

 rcx = SysFileTree( Dir'\*', 'File.', 'FOS');
 DO i = File.0 TO 1 BY -1
    rcx = SysFileDelete( File.i);
 END;
 rcx = SysFileTree( Dir'\*', 'Dir.', 'DOS');
 DO i = Dir.0 TO 1 BY -1
    rcx = SysRmDir( Dir.i);
 END;
 rc = SysRmDir( Dir);

 RETURN( rc);


/* ========================================================================= */
QueryComponentFromId: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG File, ComponentName;

 rc = ERROR.NO_ERROR;

 fComponentFound     = FALSE;
 StartPos            = 0;
 EndPos              = 0;
 LastNonEmptyLinePos = 0;

 DO 1
    IF (STREAM( File, 'C', 'OPEN READ') \= 'READY:') THEN
       LEAVE;

    DO WHILE (LINES( File))

       LineFilePos = STREAM( File, 'C', 'SEEK +0');
       ThisLine = LINEIN( File);
       CheckLine = TRANSLATE( STRIP( ThisLine));

       /* ignore comment lines */
       IF (LEFT( ThisLine, 1) = '*') THEN
          CheckLine = '';

       /* Check for a component */
       IF (CheckLine = 'COMPONENT') THEN
       DO
          /* check for start of searched component */
          IF (\fComponentFound) THEN
          DO
             fContinue = TRUE;
             DO WHILE ((LINES( File)) & (fContinue))

                /* tokenize following lines */
                ThisLine = LINEIN( File);
                fContinue = (RIGHT( STRIP( ThisLine), 1) = ',');
                IF (fContinue) THEN
                   ThisLine = LEFT( ThisLine, LENGTH( ThisLine) - 1);
                PARSE VAR ThisLine ThisKey'='ThisValue;


                ThisKey = TRANSLATE( STRIP( ThisKey));
                ThisValue = STRIP( ThisValue);
                IF (LEFT( ThisValue, 1) = "'") THEN
                   PARSE VAR ThisValue "'"ThisValue"'";
                IF ((ThisKey = 'ID') & (ComponentName = ThisValue)) THEN
                DO
                   fComponentFound = TRUE;
                   StartPos  = LineFilePos;
                END;
             END;
          END;
          ELSE
          /* check for end of searched component */
          DO
             EndPos = LastNonEmptyLinePos;
             LEAVE;
          END;

       END; /* IF (CheckLine = 'COMPONENT') THEN */

       /* save end pos of last nonempty line */
       IF (CheckLine \= '') THEN
          LastNonEmptyLinePos = LineFilePos + LENGTH( ThisLine);

    END;

    /* if searched component was last, save end of last non-empty line */
    IF ((fComponentFound) & (EndPos = 0)) THEN
       EndPos = LastNonEmptyLinePos;

    /* close file */
    rcx = STREAM( File, 'C', 'CLOSE');
 END;

 RETURN( StartPos EndPos);

/* ========================================================================= */
DetermineFolderTitle: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG PackageFile, DefaultObjectTitle;

 ObjectTitle = DefaultObjectTitle;
 SearchTag   = 'NAME';

 DO 1
    /* search package file for title */
    rc = SysFileSearch( SearchTag, PackageFile, 'Line.');
    IF (rc \= ERROR.NO_ERROR) THEN
       LEAVE;
    IF (Line.0 = 0) THEN
       LEAVE;

     PARSE VAR Line.1 WITH (SearchTag) "'"ThisTitle"'";
     IF (ThisTitle \= '') THEN
        ObjectTitle = ThisTitle;

 END;

 RETURN( ObjectTitle);

/* ========================================================================= */
QueryPkgEntry: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG File, Type, SearchEntry;

 rc = ERROR.NO_ERROR;

 CheckSearchEntry = TRANSLATE( STRIP( SearchEntry));
 CheckSearchType = TRANSLATE( STRIP( Type));

 fPkgEntryFound = FALSE;
 StartPos       = 0;
 EndPos         = 0;
 FoundStatement = '';

 DO 1
    IF (STREAM( File, 'C', 'OPEN READ') \= 'READY:') THEN
       LEAVE;

    CurrentType      = '';
    CurrentStatement = '';
    CurrentStartPos  = 0;
    fAppend = FALSE;

    DO WHILE ((LINES( File)) & (\fPkgEntryFound))

       LineFilePos = STREAM( File, 'C', 'SEEK +0');
       ThisLine = LINEIN( File);

       /* append all  lines belonging to a given statement */
       IF ((STRIP( ThisLine) \= '') & (LEFT( ThisLine,1) \= '*')) THEN
       DO
          IF (fAppend) THEN
             CurrentStatement = CurrentStatement''CrLf''ThisLine;
          ELSE
          DO
             CurrentType      = TRANSLATE( STRIP( ThisLine));
             CurrentStatement = ThisLine;
             CurrentStartPos  = LineFilePos;
          END;

          /* append next line if this line began with a keyword in the first */
          /* column or if a comma at the end indicates to commence on next line */
          fAppend = ((LEFT( ThisLine, 1) \= ' ') | (RIGHT( STRIP( ThisLine), 1) = ','));
       END;

       /* statement complete, check if it matches */
       fAddStatement = FALSE;
       NewStatement = '';
       IF ((\fAppend) & (CurrentStatement \= '') & (CheckSearchType = CurrentType)) THEN
       DO
          IF (CheckSearchEntry = '') THEN
             fPkgEntryFound = TRUE;
          ELSE
          DO
             /* process statement here */
             ThisStatement = CurrentStatement;
             AddEntry = '';
             RemoveEntry = '';
             DO WHILE (ThisStatement \= '')
                PARSE VAR ThisStatement ThisEntry(CrLf) ThisStatement;
                PARSE VAR ThisEntry ThisKey'='ThisValue;

                /* process key lines only */
                IF (ThisValue \ ='') THEN
                DO
                   /* check for keyword and searched values */
                   CheckEntry = TRANSLATE( STRIP( ThisKey)'='STRIP(ThisValue));
                   IF (RIGHT( CheckEntry, 1) = ',') THEN
                      CheckEntry = LEFT( CheckEntry, LENGTH( CheckEntry) - 1);

                   IF (CheckEntry = CheckSearchEntry) THEN
                      fPkgEntryFound = TRUE;
                END;
             END;
          END;

          IF (fPkgEntryFound) THEN
          DO
             StartPos       = CurrentStartPos;
             EndPos         = STREAM( File, 'C', 'SEEK +0');
             FoundStatement = CurrentStatement;
          END;

          /* reset var */
          CurrentStatement = '';
       END;

    END;

    /* close file */
    rcx = STREAM( File, 'C', 'CLOSE');
 END;

 RETURN( StartPos EndPos FoundStatement);

/* ========================================================================= */
QueryPkgEntryValue: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG EntryStatement, KeyName;

 EntryValue = '';
 EntryStart = 0;
 EntryEnd   = 0;
 CheckKey   = TRANSLATE( STRIP( KeyName));

 EntryPos = 1;
 DO WHILE (EntryStatement \= '')
    PARSE VAR EntryStatement ThisEntry(CrLf) EntryStatement;
    PARSE VAR ThisEntry ThisKey'='ThisValue;
    IF (TRANSLATE( STRIP( ThisKey)) = CheckKey) THEN
    DO
       EntryStart = EntryPos;
       EntryEnd   = EntryPos + LENGTH( ThisEntry) + 2;
       EntryValue = STRIP( ThisValue);
       LEAVE;
    END;
    EntryPos = EntryPos + LENGTH( ThisEntry) + 2;
 END;

 /* remove comma */
 IF ((EntryValue \= '') & (RIGHT( EntryValue, 1) = ',')) THEN
    EntryValue = LEFT( EntryValue, LENGTH( EntryValue) - 1);

 RETURN( EntryStart EntryEnd EntryValue);

/* ========================================================================= */
ExtendNsPipFile: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG PkgFile, DllList, BasePath, NewPath;

 rc = ERROR.NO_ERROR;

 FileList = DllList;
 Modify.  = '';
 Modify.0 = 0;

 KeyPos       = 0;
 DelimiterPos = 0;

 /* add these before duplicating file entries */
 Object.1._compname = 'INSFIRST';
 Object.1._insert   = "FILE"CrLf||,
                      "   EXITWHEN      = '(INSTALL || UPDATE || RESTORE) && (""%NAV_PRESENT%"" == ""TRUE"")',"CrLf||,
                      "   EXITIGNOREERR = YES,"CrLf||,
                      "   EXIT          = 'CREATEWPSOBJECT WPShadow ""."" <MOZILLAFLDR> U   ""SHADOWID=<%FOLDERID%NSTS_PIP>;OBJECTID=<%FOLDERID%NSTS_PIP_SHADOW>;""'";

 /* add these after duplicating file entries */
 Object.2._compname = 'OS2NP';
 Object.2._insert   = "FILE"CrLf||,
                      "   EXITWHEN      = '(INSTALL || UPDATE || RESTORE) && ""%NAV_PRESENT%""==""TRUE""',"CrLf||,
                      "   EXITIGNOREERR = YES,"CrLf||,
                      "   EXIT          = 'CREATEWPSOBJECT WPShadow ""."" <MOZILLAFLDR> U ""SHADOWID=<%READMEID%>;OBJECTID=<%READMEID%_SHADOW>;""'";
 Object.3._compname = 'PROXY';
 Object.3._insert   = Object.2._insert;

 DO 1

    /* add new path as additional auxilliary path */
    PathInfo = QueryPkgEntry( PkgFile, 'PATH');
    PARSE VAR PathInfo PathStart PathEnd PathStatement;
    AuxNum = 1;
    DO i = 9 TO 1 BY -1
       IF (WORDPOS( 'AUX'i'LABEL', PathStatement) > 0) THEN
          AuxNum = i + 1;
    END;
    ReplaceStatement = PathStatement','CrLf||,
                       '   AUX'AuxNum'        =' BasePath','CrLf||,
                       "   AUX"AuxNum"LABEL   = 'Mozilla directory:'";

    /* store modification request */
    m                   = Modify.0 + 1;
    Mofify.m._InsertAt  = PathStart;
    Mofify.m._SkipLen   = PathEnd - PathStart;
    Mofify.m._Statement = ReplaceStatement;
    Modify.0            = m;

    /* -------------------------------------------- */

    /* add calls to create shadows of WPS objects in Mozilla folder */
    DO o = 1 TO 1
       ComponentInfo = QueryComponentFromId( PkgFile, Object.o._compname);
       PARSE VAR ComponentInfo ComponentStart ComponentEnd;
       IF ((ComponentStart > 0) & (ComponentEnd > 0)) THEN
       DO
          /* store modification request */
          m                   = Modify.0 + 1;
          Mofify.m._InsertAt  = ComponentEnd;
          Mofify.m._SkipLen   = 0;
          Mofify.m._Statement = CrLf''CrLf''Object.o._insert;
          Modify.0            = m;
       END;
    END;

    /* -------------------------------------------- */

    /* duplicate file entries with appropriate values */
    DO WHILE (FileList \= '')
       PARSE VAR FileList ThisSearchTag FileList;
       PARSE VAR ThissearchTag ThisKey'='ThisFile;
       Filename = FILESPEC('N', ThisFile);

       EntryInfo = QueryPkgEntry( PkgFile, 'FILE', ThisSearchTag);
       PARSE VAR EntryInfo EntryStart EntryEnd EntryStatement;

       /* determine layout of first key entry */
       PARSE VAR EntryStatement FirstLine(CrLf)FirstEntry(CrLf).;
       KeyIndentLen  = WORDINDEX( FirstEntry, 1) - 1;
       KeyIndent = COPIES( ' ', KeyIndentLen);
       DelimiterPos = POS( '=', FirstEntry);
       DelimiterIndentLen = DelimiterPos - KeyIndentLen - 2;

       /* modify PWS for the new statement */
       KeyInfo = QueryPkgEntryValue( EntryStatement, 'PWS');
       PARSE VAR KeyInfo KeyStart KeyEnd KeyValue;
       IF ((KeyStart > 0) & (KeyEnd > 0)) THEN
       DO
          NewStatement = DELSTR( EntryStatement, KeyStart, KeyEnd - KeyStart);
          NewStatement = INSERT( KeyIndent''LEFT( 'PWS', DelimiterIndentLen) '=' NewPath'/'FileName','CrLf, NewStatement, KeyStart - 1);
       END;

       /* add PWSPATH entry to use AUX2 value */
       KeyInfo = QueryPkgEntryValue( NewStatement, 'PWS');
       PARSE VAR KeyInfo KeyStart KeyEnd KeyValue;
       IF ((KeyStart > 0) & (KeyEnd > 0)) THEN
          NewStatement = INSERT( KeyIndent''LEFT( 'PWSPATH', DelimiterIndentLen) '= AUX'AuxNum','CrLf, NewStatement, KeyEnd - 1);

       /* remove PACKID of the new statement */
       KeyInfo = QueryPkgEntryValue( NewStatement, 'PACKID');
       PARSE VAR KeyInfo KeyStart KeyEnd KeyValue;
       IF ((KeyStart > 0) & (KeyEnd > 0)) THEN
          NewStatement = DELSTR( NewStatement, KeyStart, KeyEnd - KeyStart);

       /* remove existing SOURCE statement the new statement */
       KeyInfo = QueryPkgEntryValue( NewStatement, 'SOURCE');
       PARSE VAR KeyInfo KeyStart KeyEnd KeyValue;
       IF ((KeyStart > 0) & (KeyEnd > 0)) THEN
          NewStatement = DELSTR( NewStatement, KeyStart, KeyEnd - KeyStart);

       /* add SOURCE statement after UNPACK statement */
       KeyInfo = QueryPkgEntryValue( NewStatement, 'UNPACK');
       PARSE VAR KeyInfo KeyStart KeyEnd KeyValue;
       IF ((KeyStart > 0) & (KeyEnd > 0)) THEN
          NewStatement = INSERT( KeyIndent''LEFT( 'SOURCE', DelimiterIndentLen) "= ' DRIVE:" Filename "',"CrLf, NewStatement, KeyEnd - 1);

       /* store modification request */
       m                   = Modify.0 + 1;
       Mofify.m._InsertAt  = EntryEnd;
       Mofify.m._SkipLen   = 0;
       Mofify.m._Statement = CrLf''NewStatement;
       Modify.0            = m;
    END;

    /* -------------------------------------------- */

    /* add calls to create shadows of WPS objects in Mozilla folder */
    DO o = 2 TO 3
       ComponentInfo = QueryComponentFromId( PkgFile, Object.o._compname);
       PARSE VAR ComponentInfo ComponentStart ComponentEnd;
       IF ((ComponentStart > 0) & (ComponentEnd > 0)) THEN
       DO
          /* store modification request */
          m                   = Modify.0 + 1;
          Mofify.m._InsertAt  = ComponentEnd;
          Mofify.m._SkipLen   = 0;
          Mofify.m._Statement = CrLf''CrLf''Object.o._insert;
          Modify.0            = m;
       END;
    END;

    /* -------------------------------------------- */

    /*open files */
    IF (STREAM( PkgFile, 'C', 'OPEN READ') \= 'READY:') THEN
       LEAVE;
    TmpFile = SysTempFilename( TmpDir'\nspip.???');
    IF (STREAM( TmpFile, 'C', 'OPEN WRITE') \= 'READY:') THEN
       LEAVE;

    /* transfer from original data and insert new data */
    BytesRead = 0;
    FileSize = STREAM( PkgFile, 'C', 'QUERY SIZE');

    DO m = 1 TO Modify.0

       /* write data from original file */
       ReadLen = Mofify.m._InsertAt - BytesRead - 1;
       Data = CHARIN( PkgFile, , ReadLen);
       rcx = CHAROUT( TmpFile, Data);
       BytesRead = BytesRead + ReadLen;

       /* skip data from original file */
       IF (Mofify.m._SkipLen > 0) THEN
       DO
          Data = CHARIN( PkgFile, , Mofify.m._SkipLen);
          BytesRead = BytesRead + Mofify.m._SkipLen;
       END;

       /* write extension data */
       rcx = LINEOUT( TmpFile, Mofify.m._Statement);

    END;

    /* write end of original data */
    Data = CHARIN( PkgFile, , FileSize - BytesRead);
    rcx = CHAROUT( TmpFile, Data);

    /* close file and copy over */
    rcx = STREAM( PkgFile, 'C', 'CLOSE');
    rcx = STREAM( TmpFile, 'C', 'CLOSE');

    'COPY' TmpFile PkgFile Redirection;
    'DEL' TmpFile Redirection;
 END;


 /* cleanup */
 rcx = STREAM( PkgFile, 'C', 'CLOSE');
 rcx = STREAM( TmpFile, 'C', 'CLOSE');

 RETURN (rc);

/* ========================================================================= */
ModifyNsPipFile: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG PkgFile;

 /* -- don't use PROGRAM subdirectory */
 rcx = FileReplaceStr( PkgFile, 'PROGRAM//', '');
 rcx = FileReplaceStr( PkgFile, 'PROGRAM/', '');
 rcx = FileReplaceStr( PkgFile, 'PROGRAM\', '');
 rcx = FileReplaceStr( PkgFile, 'Netscape directory:', 'Mozilla directory');

 /* -- use our fake Mozilla folder */
 rcx = FileReplaceStr( PkgFile, 'NS46_FOLDER', 'MZPIP_FOLDER');
 rcx = FileReplaceStr( PkgFile, 'READMEID=OS2PIP30_README', 'READMEID=OS2PIP30_README_MOZILLA');

 /* -- make sure that Software installer gets deleted on deinstall */
 rcx = FileReplaceStr( PkgFile, 'DELETEFILES %EPFIFILEDIR%//PLUGINS//', 'DELETEFILES %SIUTILDIR%//');
 rcx = FileReplaceStr( PkgFile, 'PLUGINS/EPFI', '%SIUTILDIR%/EPFI');

 RETURN( 0);

/* ========================================================================= */
CopySiFiles: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG ArchiveFile, TargetDir;

 EpfiFiles = 'epfiexts.dll epfihplb.hlp epfiicis.ico epfirsbk.dll epfiupk2.exe',
             'epfimsg.msg epfinsts.exe epfipii.dll epfiprcs.exe';

 CurrentDir = DIRECTORY();
 rcx = SysMkDir( TargetDir);

 /* unpack files to temporary directory */
 EpfiTmpDir = SysTempFilename( TmpDir'\nspip.???');
 rcx = SysMkDir( EpfiTmpDir);
 rc = DIRECTORY( EpfiTmpDir);
 'unpack' ArchiveFile Redirection;

 /* copy files over, if missing in Netscape directory */
 FileList = EpfiFiles;
 DO WHILE (FileList \= '')
    PARSE VAR FileList ThisFile FileList;
    TargetFile = TargetDir'\'ThisFile;
    IF (\FileExist( TargetFile)) THEN
       'COPY' ThisFile TargetDir'\' Redirection;
 END;

 /* cleanup */
 'DEL * /N' Redirection;
 rcx = DIRECTORY( '..');
 rcx = SysRmDir( EpfiTmpDir);
 rcx = DIRECTORY( CurrentDir);

 RETURN( 0);

