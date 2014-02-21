/*
 *      MCI.CMD - V1.0 C.Langanke 1998
 *
 *      Syntax: mci <mcifile>
 *
 *      mci is nan external batch processor for OS/2.
 *      Call mci.cmd with a mci fila as only parameter
 *      or put the line EXTPROC into the first line
 *      of a cmd file in order to be able to use
 *      the mci command language within that cmd file
 *      (nothing else !).
 *      Allowed comment characters are ; : and #
 *
 *      See sample MCI cmd files for additional commands, that
 *      MCI.CMD implements. You can also use environment variables
 *      like in conventional batch programming, just enclose them in
 *      percent signs like %VAR%.
 *
 *      MCI sets the following environment variables:
 *
 *      %MCI_CALLDRIVE%  - drive of MCI source file
 *      %MCI_CALLDIR%    - directory of MCI source file
 *      %MCI_BOOTDRIVE%  - drive of OS/2 installation / bootdrive
 *      %MCI_MMPMDRIVE%  - drive of MMPM installation
 *      %MCI_MMPMDIR%    - directory of MMPM installation
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

 GlobalVars = 'Title CmdName env TRUE FALSE Redirection ERROR.';

 /* show help */
 ARG Parm .
 IF ((Parm = '') | (POS('?', Parm) > 0)) THEN
 DO
    rc = ShowHelp();
    EXIT(ERROR.INVALID_PARAMETER);
 END;

 /* Defaults */
 GlobalVars=GlobalVars 'LineCount MCIFile fTrace';
 rc         = 0;
 rcInit     = -1;
 LineCount  = 0;
 fTrace     = FALSE;

 SilentMCICommands = 'OPEN';     /* don't display values returned of those commands */

 CommentChars = ';:;';


 DO UNTIL (1)

    /* read filename and check file */
    PARSE ARG MCIFile
    MCIFile = STRIP(MCIFile);
    IF (\FileExist(MCIFile)) THEN
    DO
       SAY CmdNAme': error: file' MCIFile 'not found.';
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;
    MCIFile = STREAM(MCIFile, 'C', 'QUERY EXISTS');

    /* set environment vars */
    rc = SETLOCAL();
    BootDrive = GetInstDrive();
    CallDir   = GetDrivePath( MCIFile);
    CallDrive = FILESPEC('D', MCIFile);
    IF (LENGTH(CallDir) = 2) THEN
       CallDir = CallDir'\';
    MmpmDrive = GetInstDrive('\MMOS2');
    MmpmDir  = MmpmDrive'\MMOS2';

    rc = VALUE('MCI_CALLDRIVE', CallDrive, env);
    rc = VALUE('MCI_CALLDIR',   CallDir,   env);
    rc = VALUE('MCI_BOOTDRIVE', BootDrive, env);
    rc = VALUE('MCI_MMPMDRIVE', MmpmDrive, env);
    rc = VALUE('MCI_MMPMDIR',   MmpmDir,   env);

    /* initialise */
    rc = RXFUNCADD('mciRxInit','MCIAPI','mciRxInit')
    rcInit = mciRxInit();
    IF ((rcInit \= 0)  & (rcInit \= 30)) then
    DO
       SAY 'error: MCI Interface could not be initialized. rc='rcInit;
       LEAVE;
    END;

    /* read file */
    DO WHILE (LINES(MCIFile) > 0)

       ThisLine = LINEIN( MCIFile);
       ThisLine = STRIP(ThisLine);
       LineCount = LineCount + 1;

       /* ignore extproc command on first line */
       IF ((LineCount = 1) & ( TRANSLATE(WORD(ThisLine, 1)) = 'EXTPROC')) THEN
          ITERATE;

       /* skip empty lines */
       IF (ThisLine = '') THEN ITERATE;

       /* skip comment lines */
       IF (POS( LEFT(ThisLine, 1), CommentChars) > 0) THEN
          ITERATE;

       /* trace enabled ? */
       IF (fTrace) THEN
          SAY ThisLine;

       /* replace environment vars */
       ThisLine = ParseLine(ThisLine);

       /* check own commands */
       Command = TRANSLATE(WORD(ThisLine, 1));

       SELECT

          /* --------------------------------------------------- */

          /* debug turns on display of commands */
          WHEN (Command = 'TRACE') THEN
             fTrace = TRUE;

          /* --------------------------------------------------- */

          /* echos a string */
          WHEN (Command = 'ECHO') THEN
          DO
             PARSE VAR ThisLine . Message;
             IF (RIGHT(Message, 1) = '^') THEN
                CALL CHAROUT, LEFT(Message, LENGTH(Message) - 1)' ';
             ELSE
                SAY Message;
          END;

          /* --------------------------------------------------- */

          /* pause option for asynchronous play mode */
          WHEN (Command = 'PAUSE') THEN
          DO
             PARSE VAR ThisLine . Prompt;
             IF (Prompt \= '') THEN
             DO
                CALL CHAROUT, Prompt;
                'PAUSE' Redirection;
             END;
             ELSE
                'PAUSE';
          END;

          /* --------------------------------------------------- */

          /* goto specified label */
          WHEN (Command = 'GOTO') THEN
          DO
             PARSE VAR ThisLine . Label;
             IF (Label  = '') THEN
             DO
                SAY MCIFile'('LineCount'): error: no label specified for GOTO.';
                rc = ERROR.INVALID_DATA;
                LEAVE;
             END;

             LineCountGoto = LineCount;
             fLabelFound = FALSE;
             LineCount = 0;

             /* jump to begin of file by closing and reopening it */
             /* do not seek, because call is incompatible between classic and OO REXX */
             rc = STREAM(MCIFile, 'C', 'CLOSE');

             DO WHILE (LINES(MCIFile) > 0)
                LineCount = LineCount + 1;
                ThisLine = LINEIN( MCIFile);
                ThisLine = TRANSLATE(STRIP(ThisLine));
                IF (ThisLine = '') THEN ITERATE;
                IF (WORD(ThisLine, 1) = ':'TRANSLATE(Label)) THEN
                DO
                   fLabelFound = TRUE;
                   LEAVE;
                END;
             END;
             IF (\fLabelFound) THEN
             DO
                SAY MCIFile'('LineCountGoto'): error: label' Label 'not found.';
                rc = ERROR.INVALID_DATA;
                LEAVE;
             END;
          END;

          /* --------------------------------------------------- */

          /* play a track */
          WHEN (Command = 'PLAYTRACK') THEN
          DO
             PARSE VAR ThisLine . ThisDevice ThisTrack ThisOptions;
             ThisOptions = TRANSLATE(ThisOptions);

             /* check for repeat option */
             fRepeatTrack = FALSE;
             RepeatPos = WORDPOS('REPEAT', ThisOptions);
             IF (RepeatPos \= 0) THEN
             DO
                fRepeatTrack = TRUE;

                /* remove repeat option */
                ThisOptions = DELWORD(ThisOptions, RepeatPos, 1);

                /* add wait option */
                IF (WORDPOS('WAIT', ThisOptions) = 0) THEN
                   ThisOptions = ThisOptions 'WAIT';
             END;

             /* determine start and stop positions */
             TrackPosStart = ProcessCommand( FALSE, TRUE, 'status' ThisDevice 'position track' ThisTrack 'wait');
             TrackPosEnd = ProcessCommand( FALSE, FALSE, 'status' ThisDevice 'position track' ThisTrack + 1 'wait');
             IF (TrackPosEnd \= '') THEN
                TrackPosEnd = 'to' TrackPosEnd;

             /* play the track */
             DO UNTIL (\fRepeatTrack)
                rc = ProcessCommand( FALSE, TRUE, 'play' ThisDevice 'from' TrackPosStart TrackPosEnd ThisOptions);
             END;
          END;

          /* --------------------------------------------------- */

          /* execute MCI command */
          OTHERWISE
          DO
             fDisplayCommand = (WORDPOS(Command, SilentMCICommands) = 0);
             rc = ProcessCommand( fDisplayCommand, TRUE, ThisLine);
          END;

       END; /* SELECT */

    END; /* DO WHILE (LINES(MCIFile) > 0) */

 END; /* DO UNTIL (1) */

 /* cleanup */
 CALL mciRxExit;

 EXIT(rc)

/* ------------------------------------------------------------------------- */
HALT:
 SAY 'Interrupted by user.';
 EXIT(ERROR.GEN_FAILURE);

SYNTAX:
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
ParseLine: PROCEDURE EXPOSE env
 PARSE ARG ThisLine

 Delimiter = '%';

 ThisLineCopy = '';
 CurrentPos   = 1;

 /* search var */
 VarStart = POS(Delimiter, ThisLine);
 DO WHILE (VarStart > 0)

    VarEnd       = Pos(Delimiter, ThisLine, VarStart + 1);
    ThisVar      = SUBSTR(ThisLine, VarStart + 1, VarEnd - VarStart - 1);
    ThisVarValue = VALUE(ThisVar,,env);

    /* extend copy with value */
    ThisLineCopy = ThisLineCopy||,
                   SUBSTR(ThisLine, CurrentPos, VarStart - CurrentPos)||,
                   ThisVarValue;
    CurrentPos   = VarEnd + 1;

    /* search next occurrence of var */
    VarStart = POS(Delimiter, ThisLine, CurrentPos);
 END;

 /* take also rest of line */
 ThisLineCopy = ThisLineCopy||SUBSTR(ThisLine, CurrentPos);

 RETURN(ThisLineCopy);
/* ========================================================================= */
ProcessCommand: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG fDisplayResult, fDisplayError, Command

 /* send comments */
 SIGNAL ON SYNTAX;     /* let REXX handle double Ctrl-Break more properly */
 rc = mciRxSendString( Command, 'ResultString', 0, 0);
 SIGNAL OFF SYNTAX;
 IF (rc \= 0) THEN
 DO
    IF (fDisplayError) THEN
    DO
       rcGetString = mciRxGetErrorString( rc, 'ErrorString');
       SAY MCIFile'('LineCount'): error: ' Command;
       SAY '-->' ErrorString;
    END;
 END;
 ELSE
 DO
    IF ((ResultString \= '') & (fDisplayResult)) THEN
       SAY ResultString;
 END;

 RETURN(ResultString);

