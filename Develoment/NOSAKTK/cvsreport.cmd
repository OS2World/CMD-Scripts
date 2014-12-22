/*
 *      CVSREPORT.CMD - NOSA Client - V1.06 C.Langanke for Netlabs 1999,2001
 *
 *     Syntax: cvsreport
 *
 *     This program egnerates a HTML form for reporting changes to the
 *     change report database via email.
 *
 *     The archivename is read out of the environment variable %NOSAC_ARCHIVE%
 *     The username is read out of the environment variable %USER%
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

 /* load FTP util */
 CALL RxFuncAdd    'FtpLoadFuncs', 'rxFtp', 'FtpLoadFuncs';
 CALL FtpLoadFuncs 'QUIET';

 /* Defaults */
 GlobalVars = GlobalVars 'Var. OptionDelimiter';
 OptionDelimiter    = ';'
 ErrorMsg           = '';
 rc                 = ERROR.NO_ERROR;
 CallDir            = GetCallDir();
 DefaultEmailAdress = 'NOSA-change-report@netlabs.org';

 ArchiveVarname     = 'NOSAC_ARCHIVE';


 DO UNTIL (TRUE)

    /* check parameters */
    Archive = VALUE(ArchiveVarname,, env);
    IF (Archive = '') THEN
    DO
       ErrorMsg = 'enrionment variable' ArchiveVarname 'not found. Execute cvsenv first.';

       rc = ERROR.ENVVAR_NOT_FOUND;
       LEAVE;
    END;

    PARSE ARG EmailAdress .;
    User = VALUE('USER',,env);
    IF (User = '') THEN
    DO
       ErrorMsg = 'environment variable user not defined.';
       rc = ERROR.INVALID_PARAMETER;
       LEAVE;
    END;

    EmailAdress = STRIP(EmailAdress);
    IF (EmailAdress = '') THEN
       EmailAdress = DefaultEmailAdress;

    /* var exists ? */
    VarFile  = CallDir'\html\report.var';
    IF (\FileExist( VarFile)) THEN
    DO
       ErrorMsg = 'variable file' VarFile 'not found.';
       rc = ERROR.FILE_NOT_FOUND;
       LEAVE;
    END;

    /* -------------------------------------------------------------- */

    /* read all variables */
    ErrorMsg = '';
    rc = ReadVariables( VarFile);
    IF (rc \= ERROR.NO_ERROR) THEN
       LEAVE;

    /* write html file */
    HtmlFile   = CallDir'\html\'Archive'.html';
    rc = WriteHtmlFile( HtmlFile, Archive, User, EmailAdress);
    IF (rc \= ERROR.NO_ERROR) THEN
       LEAVE;

    /* start netscape with the resulting file */
    CALL CHAROUT, 'Starting browser ... ';
    'START NETSCAPE' HtmlFile;
    SAY 'Ok.';

 END;

 /* exit */
 IF (rc \= ERROR.NO_ERROR) THEN
 DO
    IF (ErrorMsg \= '') THEN
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
GetCalldir: PROCEDURE
PARSE SOURCE . . CallName
 CallDir = FILESPEC('Drive', CallName)||FILESPEC('Path', CallName);
 RETURN(LEFT(CallDir, LENGTH(CallDir) - 1));

/* ------------------------------------------------------------------------- */
ParseLine: PROCEDURE EXPOSE env
 PARSE ARG ThisLine

 Delimiter = '%';

 ThisLineCopy = '';
 CurrentPos   = 1;

 /* search variable */
 VarStart = POS(Delimiter, ThisLine);
 DO WHILE (VarStart > 0)

    VarEnd       = Pos(Delimiter, ThisLine, VarStart + 1);
    ThisVar      = SUBSTR(ThisLine, VarStart + 1, VarEnd - VarStart - 1);
    ThisVarValue = VALUE(ThisVar,,env);

    /* extend copy */
    ThisLineCopy = ThisLineCopy||,
                   SUBSTR(ThisLine, CurrentPos, VarStart - CurrentPos)||,
                   ThisVarValue;
    CurrentPos   = VarEnd + 1;

    /* search next var */
    VarStart = POS(Delimiter, ThisLine, CurrentPos);
 END;

 /* take ofer rest of line */
 ThisLineCopy = ThisLineCopy||SUBSTR(ThisLine, CurrentPos);

 RETURN(ThisLineCopy);

/* ========================================================================= */
ReadVariables: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG VarFile;

 rc             = ERROR.NO_ERROR;
 LineCount      = 0;
 CommentChars   = ';:#';
 GlobalOptions  = 'TARGET SUBJECT SUBMIT RESET';
 Controls       = 'HIDDEN INPUT SELECT TEXTAREA';
 ControlOptions = 'CONTROL PROMPT NAME TYPE VALUE ATTRIBUTES INFO OPTIONS VALIDATE';

 ErrorMsg       = '';
 ErrorLine      = 0;

 DO UNTIL (TRUE)

    /* reset variable stem */
    Drop(Var.);
    Var.  = '';
    Var.0 = 0;

    /* read in vars */
    DO WHILE (LINES( VarFile) > 0)

       /* read a line */
       LineCount = LineCount + 1;
       ThisLine = STRIP( LINEIN( VarFile));

       /* ignore empty lines and comments */
       IF (ThisLine = '') THEN ITERATE;
       IF (WORDS( ThisLine) < 2) THEN ITERATE;
       IF (POS( LEFT( ThisLine, 1), CommentChars) > 0) THEN ITERATE;

       PARSE VAR ThisLine OptionName OptionValue;
       OptionName  = TRANSLATE( STRIP( OptionName));
       OptionValue = STRIP( OptionValue);

       /* is it a valid option ? */
       SELECT
          WHEN (WORDPOS( OptionName, GlobalOptions) > 0) THEN
          DO
             Var.OptionName = ParseLine( OptionValue);
             ITERATE;
          END;

          WHEN (OptionName = 'CONTROL') THEN
          DO
             /* open a new control definition */
             i     = Var.0 + 1;
             Var.i = OptionValue;
             Var.0 = i;
             ITERATE;
          END;

          WHEN (WORDPOS( OptionName, ControlOptions) > 0) THEN
          DO
             /* check if a control definition is already open */
             IF (Var.0 = 0) THEN
             DO
                ErrorMsg  = 'invalid: usage of control option outside of a control definition';
                rc = ERROR.INVALID_DATA;
                LEAVE;
             END;


             /* save value */
             /* Values are to be checked for environment variables */
             i                = Var.0;
             Var.i.OptionName = ParseLine( OptionValue);

          END;

          OTHERWISE
          DO
             /* give an error */
             ErrorMsg  = 'Invalid option:' OptionName;
             ErrorLine = LineCount;
             rc = ERROR.INVALID_DATA;
          END;

       END; /* SELECT */

       /* break out in case of error */
       IF (rc \= ERROR.NO_ERROR) THEN
          LEAVE;

    END; /* DO WHILE (LINES( VarFile) > 0) */

 END; /* DO UNTIL (TRUE) */

 /* report error */
 IF (rc \= ERROR.NO_ERROR) THEN
    SAY 'error in line' LineCount':' ErrorMsg;
 RETURN(rc);

/* ========================================================================= */
WriteHtmlFile: PROCEDURE EXPOSE (GlobalVars)
 PARSE ARG HtmlFile, Archive, User, EmailAdress;

 rc          = ERROR.NO_ERROR;
 YellowColor = '#ffffe8';
 GreenColor  = '#f7fff7';

 DO UNTIL (TRUE)

    /* delete old file */
    rc = SysFileDelete( HtmlFile);
    IF (WORDPOS( rc, '0 2') = 0) THEN
    DO
       ErrorMsg = 'Cannot write change report form.';
       LEAVE;
    END;
    rc = ERROR.NO_ERROR;

    CALL CHAROUT, 'Generating change report form for archive' Archive '... ';

    /* --------------------------------------------------------------- */

    /* write header */
    rc = LINEOUT( HtmlFile, '<html>');
    rc = LINEOUT( HtmlFile, '<head>');
    rc = LINEOUT( HtmlFile, '<title>OS/2 Netlabs Open Source Archive Change Report</title>');
    rc = LINEOUT( HtmlFile, '<meta http-equiv="content-type" content="text/html;CHARSET=iso8859-1">');

    /* --------------------------------------------------------------- */

    /* write start of JavaScript */
    rc = LINEOUT( HtmlFile, '<script language="JavaScript">');
    rc = LINEOUT( HtmlFile, '  <!--');
    rc = LINEOUT( HtmlFile, '');

    /* --------------------------------------------------------------- */

    /* commands for preloading bitmaps */
    rc = LINEOUT( HtmlFile, '  RequiredBitmap     = new Image();');
    rc = LINEOUT( HtmlFile, '  RequiredBitmap.src = "image/required.gif";');
    rc = LINEOUT( HtmlFile, '  ErrorBitmap        = new Image();');
    rc = LINEOUT( HtmlFile, '  ErrorBitmap.src    = "image/error.gif";');
    rc = LINEOUT( HtmlFile, '');

    /* start of CheckInput */
    rc = LINEOUT( HtmlFile, '  function CheckInput()');
    rc = LINEOUT( HtmlFile, '  {');

    /* write JavaScript commands for input validation for each mandandotry object */
    DO i = 1 TO Var.0
       Var.i.Validate =  TRANSLATE(Var.i.Validate);

       /* select if clause first */
       SELECT

          WHEN (Var.i.Validate = 'EMPTY') THEN
             CheckClause = '(document.ChangeReport.'Var.i.Name'.value == "")';

          WHEN (Var.i.Validate = 'VALUE') THEN
             CheckClause = '((document.ChangeReport.'Var.i.Name'.value == "") ||',
                            '(document.ChangeReport.'Var.i.Name'.value == "'Var.i.Value'"))';

          WHEN (Var.i.Validate = 'FIRSTOPTION') THEN
          DO
             /* get first option */
             EndOfFirstOption = POS( OptionDelimiter, Var.i.Options);
             IF (EndOfFirstOption = 0) THEN
                EndOfFirstOption =LENGTH( Var.i.Options) + 1;
             FirstOption = LEFT( Var.i.Options, EndOfFirstOption - 1);

             CheckClause = '(document.ChangeReport.'Var.i.Name'.options.selectedIndex == "undefined")';
          END;

          WHEN (Var.i.Validate = '') THEN ITERATE;

          /* should we warn or interrupt here ? */
          OTHERWISE ITERATE;

       END;

       /* write commands now */
       rc = LINEOUT( HtmlFile, '   if' CheckClause);
       rc = LINEOUT( HtmlFile, '    {');
       rc = LINEOUT( HtmlFile, '     alert("'Var.i.Info'");');
       rc = LINEOUT( HtmlFile, '     document.ChangeReport.'Var.i.Name'.focus();');
       rc = LINEOUT( HtmlFile, '     document.'Var.i.Name'_BITMAP.src = ErrorBitmap.src');
       rc = LINEOUT( HtmlFile, '     return false;');
       rc = LINEOUT( HtmlFile, '    }');
       rc = LINEOUT( HtmlFile, '   else');
       rc = LINEOUT( HtmlFile, '     document.'Var.i.Name'_BITMAP.src = RequiredBitmap.src');
    END;

    /* end of CheckInput */
    rc = LINEOUT( HtmlFile, '  return true;');
    rc = LINEOUT( HtmlFile, '  }');

    /* --------------------------------------------------------------- */

    /* start of ResetBitmaps */
    rc = LINEOUT( HtmlFile, '  function ResetBitmaps()');
    rc = LINEOUT( HtmlFile, '  {');
    DO i = 1 TO Var.0
       IF (Var.i.Validate \= '') THEN
          rc = LINEOUT( HtmlFile, '   document.'Var.i.Name'_BITMAP.src = RequiredBitmap.src');
    END;

    /* end of ResetBitmaps */
    rc = LINEOUT( HtmlFile, '  }');


    /* --------------------------------------------------------------- */

    /* write end of of JavaScript and end of header */
    rc = LINEOUT( HtmlFile, '  // -->');
    rc = LINEOUT( HtmlFile, '');
    rc = LINEOUT( HtmlFile, '  </script>');
    rc = LINEOUT( HtmlFile, '</head>');

    /* --------------------------------------------------------------- */

    /* write body start */
    rc = LINEOUT( HtmlFile, '<body bgcolor='GreenColor'>');
    rc = LINEOUT( HtmlFile, '');
    rc = LINEOUT( HtmlFile, '<center>');
    rc = LINEOUT( HtmlFile, '<img src="image/nllogo.gif">');
    rc = LINEOUT( HtmlFile, '<br>');
    rc = LINEOUT( HtmlFile, '<font size=+2><b>Open Source Archive Change Report</b></font>');
    rc = LINEOUT( HtmlFile, '</center>');
    rc = LINEOUT( HtmlFile, '');
    rc = LINEOUT( HtmlFile, '<form action="mailto:'EmailAdress'?subject='Var.subject'" name="ChangeReport" method=post enctype="text/plain">');
    rc = LINEOUT( HtmlFile, '');
    rc = LINEOUT( HtmlFile, '   <table cellpadding=2 cellspacing=2 bgcolor='YellowColor' bordercolor='YellowColor' bordercolordark='YellowColor' bordercolorlight='YellowColor'>');

    /* write JavaScript commands for table entries here */
    DO i = 1 TO Var.0

       /* prepare for selection */
       ControlType = TRANSLATE( Var.i);
       SetValue    = Var.i.Value;
       IF (SetValue \= '') THEN
          SetValue = 'value="'SetValue'" ';

       /* write table row start */
       rc = LINEOUT( HtmlFile, '      <tr>');

       /* select controltype */
       SELECT

          WHEN (ControlType = 'HIDDEN') THEN
          DO
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            <input type=hidden name="'Var.i.Name'" value="'Var.i.value'">');
             rc = LINEOUT( HtmlFile, '            'Var.i.Prompt);
             rc = LINEOUT( HtmlFile, '         </td>');
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            <b>'Var.i.Value'</b>');
             rc = LINEOUT( HtmlFile, '         </td>');
          END;

          WHEN (ControlType = 'SELECT') THEN
          DO
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            'Var.i.Prompt);
             rc = LINEOUT( HtmlFile, '         </td>');
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');

             rc = CHAROUT( HtmlFile, '            <select name="'Var.i.Name'" size=1>');
             OptionList = Var.i.Options;
             PARSE VAR OptionList FirstOption';'OptionList;
             rc = CHAROUT( HtmlFile, '<option selected>'FirstOption);
             DO WHILE (OptionList \= '')
                PARSE VAR OptionList NextOption';'OptionList;
                rc = CHAROUT( HtmlFile, '<option>'NextOption);
             END;
             rc = LINEOUT( HtmlFile, '</select>');
             rc = LINEOUT( HtmlFile, '         </td>');
          END;

          WHEN (ControlType = 'TEXT') THEN
          DO
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            'Var.i.Prompt);
             rc = LINEOUT( HtmlFile, '         </td>');
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            <input type=text name="'Var.i.Name'" 'Var.i.attributes' 'SetValue'>');
             rc = LINEOUT( HtmlFile, '         </td>');
          END;

          WHEN (ControlType = 'TEXTAREA') THEN
          DO
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            'Var.i.Prompt);
             rc = LINEOUT( HtmlFile, '         </td>');
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            <textarea name="'Var.i.Name'" 'Var.i.attributes' 'SetValue'></textarea>');
             rc = LINEOUT( HtmlFile, '         </td>');
          END;

          /* should we warn or interrupt here ? */
          OTHERWISE NOP;

       END;
       /* need validate mark ? */
       SELECT

          WHEN (ControlType = 'HIDDEN') THEN
          DO
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            <img src="image/blank.gif">');
             rc = LINEOUT( HtmlFile, '         </td>');
          END;

          WHEN (Var.i.Validate \= '') THEN
          DO
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            <img name="'Var.i.Name'_BITMAP" src="image/required.gif">');
             rc = LINEOUT( HtmlFile, '         </td>');
          END;
          OTHERWISE
          DO
             rc = LINEOUT( HtmlFile, '         <td bgcolor='YellowColor'>');
             rc = LINEOUT( HtmlFile, '            <img src="image/blank.gif">');
             rc = LINEOUT( HtmlFile, '         </td>');
          END;

       END;

       /* write table row end */
       rc = LINEOUT( HtmlFile, '      </tr>');
    END;

    /* write body end */
    rc = LINEOUT( HtmlFile, '</table>');
    rc = LINEOUT( HtmlFile, '<p>');
    rc = LINEOUT( HtmlFile, '<input type=submit value="'Var.submit'" onClick="return CheckInput();">');
    rc = LINEOUT( HtmlFile, '<input type=reset value="'Var.reset'" onClick="ResetBitmaps()">');
    rc = LINEOUT( HtmlFile, '');
    rc = LINEOUT( HtmlFile, '</form>');
    rc = LINEOUT( HtmlFile, '</html>');

    /* --------------------------------------------------------------- */

    SAY 'Ok.'

 END; /* DO UNTIL (TRUE) */

 rcx = STREAM( HtmlFile, 'C', 'CLOSE');

 /* report error */
 IF (rc \= ERROR.NO_ERROR) THEN
 DO
    SAY 'error:' ErrorMsg;
    IF (ErrorMsg \= '') THEN
       SAY CmdName': Error:' ErrorMsg;
 END;
 RETURN(rc);

