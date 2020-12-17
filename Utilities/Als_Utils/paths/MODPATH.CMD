/* Automatically invoking REXX for Windows NT...  displays as an error
@ECHO OFF

SET REXXPROG_NAME=%0
SET REXXPROG_PARMS=
:GET_PARMS
SET REXXPROG_PARMS=%REXXPROG_PARMS% %1 %2 %3 %4 %5 %6 %7 %8 %9
FOR %%A IN ( 1 2 3 4 5 6 7 8 9 ) DO SHIFT
IF NOT '.%1' == '.' GOTO GET_PARMS

@REM As Rexx under NT runs as a child, any environment variables it sets
@REM are lost.  So it will work around that by creating a special BAT
@REM file that will do the sets after we return from Rexx.
SET NTSET_ENV=%tmp%\MODPATH@.BAT
@ECHO @REM Temporary exec for the NT Environment > %NTSET_ENV%

REXX %REXXPROG_NAME% %REXXPROG_PARMS%

SET REXXPROG_PARMS=
SET REXXPROG_NAME=

@REM Now set the environment variables in THIS command shell
@CALL %NTSET_ENV%
@ERASE %NTSET_ENV%
SET NTSET_ENV=
@ECHO ON

@GOTO EndNT */

/*****************************************************************************
 * ModPath - Modify Path Information in Environment Statements
 * Author:   Tom Heald (Heald at Almaden)
 * Change History:
 * 04/19/90 - ATH - Original version written.
 * 02/05/91 - ATH - Placed on the ALTools Disk.
 * 05/07/91 - ATH - Add the "BOTH" option to set both Path and DPath.
 * 06/12/91 - ATH - Fix trailing ";" & defaulting "First" with an option.
 * 01/23/92 - TEB - Bug fix for null path entries (C:\XXX;;C:\YYY)
 * 02/17/92 - ATH - Add '@ECHO OFF' in Quiet mode.
 * 03/19/92 - ATH - Change Quiet to Silent make Dupcheck the default.
 * 04/24/92 - TEB - Add (undocumented) /Force option to force changes
 *                  even if the path is not currently defined.
 * 04/30/92 - TJM - Checked for C: and corrected some misspellings.
 * 05/27/92 - ATH - Add /Force and default to /Silent if called from Rexx
 * 08/18/92 - TEB - Find_Path would not lowercase path entries.
 *  2/05/93 - ATH - Add New "Help" information.
 * 04/02/11 - AWH - Make /Force the default
 **********************************************************************/

Trace 'e'
'@ECHO OFF'                                           /*  ATH 02/17/92 */
/* Default Option Settings can be changed for individual preferences.  */
Quiet = 0             /* Show all messages                             */
DupCk = 1             /* Check for duplicate paths.       ATH  3/19/92 */
Force = 1             /* Make mods even if path not def.  TEB  4/24/92 */

Parse       Source Env Type Command                    /* ATH  5/27/92 */
If Type = "COMMAND"                                    /* ATH  5/27/92 */
   Then Echo  = 1     /* Show new path                    ATH  5/27/92 */
   Else Echo  = 0     /* Don't Echo the Path              ATH  5/27/92 */

environment = "OS2ENVIRONMENT"
If left(Env,7) == "Windows" Then Do
   say ' '
   say 'Please ignore the above error.  It is a feature of NT!'
   say ' '
   environment = "environment"
   NTSET_ENV = Value("NTSET_ENV",,environment)
End
Else NTSET_ENV = ''

parse upper arg Operands "/" Option etc               /*  ATH 02/17/92 */
  Do while Option <> ""
    Select
      When Abbrev("QUIET",   Option,1) Then Quiet = 1; /* ATH  3/19/92 */
      When Abbrev("NOQUIET", Option,3) Then Quiet = 0; /* ATH  3/19/92 */
      When Abbrev("SILENT",  Option,1) Then Quiet = 1; /* ATH  3/19/92 */
      When Abbrev("NOSILENT",Option,3) Then Quiet = 0; /* ATH  3/19/92 */
      When Abbrev("ECHO",    Option,1) Then Echo  = 1; /* ATH  3/19/92 */
      When Abbrev("NOECHO",  Option,3) Then Echo  = 0; /* ATH  3/19/92 */
      When Abbrev("DUPCHECK",Option,1) Then DupCk = 1; /* ATH  3/19/92 */
      When Abbrev("NODUPCHECK",Option,3) Then DupCk=0; /* ATH  3/19/92 */
      When abbrev('FORCE',   Option,1) then Force = 1  /* TEB  4/24/92 */
      When abbrev('NOFORCE', Option,3) then Force = 0  /* ATH  5/27/92 */
      Otherwise Do;
        If \Quiet then Say 'Invalid Option:' Option
        Exit 1;
        End
      End
    Parse var etc junk "/" Option etc
    End

parse upper var Operands Set_Target Word_1 Path_1 Word_2 Path_2 etc
if Word_1 = "" then do
  Select
    When Set_Target = ""             Then signal Help;
    When Set_Target = "?"            Then signal Help;
    When Abbrev("HELP",Set_Target,1)   /* Show the Book    ATH  2/05/93 */
      Then Call View_Help "DirTools.Inf ModPath BookShelf Path DPath"
    Otherwise Do;
      If Quiet then Exit 1;
      Say 'Missing keywords.'
      Exit 1;
      End
    End
  End

/* OS/2 requires Double Quotes around strings containing ";=," etc.     */
/* Remove any "" from the path strings.                                 */
   If left(Path_1,1) = '"' & right(Path_1,1) = '"'
      then Path_1 = substr(Path_1,2,length(Path_1)-2)
   If left(Path_2,1) = '"' & right(Path_2,1) = '"'
      then Path_2 = substr(Path_2,2,length(Path_2)-2)
/* Remove any trailing ";" from the path strings.          ATH 06/12/91 */
   If right(Path_1,1) = ';' then Path_1 = Left(Path_1,length(Path_1)-1)
   If right(Path_2,1) = ';' then Path_2 = Left(Path_2,length(Path_2)-1)


/* If "BOTH" then do "Path" and "DPath" */
If Set_Target = "BOTH"
   Then Do
     Set_Target = "PATH";  Call Do_Path
     Set_Target = "DPATH"; Call Do_Path
   end;
   Else Call Do_Path

Exit 0;

Do_Path:
Path_Data = Value(Set_Target,,environment)
If (translate(Set_Target) = 'BEGINLIBPATH') Then Do
   tmp_path = value("TEMP",,environment)
   if tmp_path = '' Then tmp_path = value("TMP",,environment)

   if tmp_path \= '' & right(tmp_path,1) \= '\' & right(tmp_path,1) \= '/'
      Then tmp_path = tmp_path || '\'

   tmp_fn = tmp_path||'$SET_???.CMD'
   tmp_fn = SysTempFileName(tmp_fn)

   '@set' Set_Target '>'tmp_fn
   Path_Data = linein(tmp_fn, 1,1)
   parse var Path_Data . '=' Path_Data
End
else tmp_fn = ''

If Path_Data = ''
  then if Force       /* teb */
    then Path_I = 0
    else do
      If \Quiet then Say 'No path information set for the Environment Statement "'Set_Target'".'
      if tmp_fn \= '' then '@erase' tmp_fn
      Exit 2
    end
  else do Path_I = 1 until Path_Data = ''     /* teb */
      parse var Path_Data Path.Path_I ";" Path_Data
      if Path.Path_I = '' & Path_Data <> ''   /* teb - Remove null entry */
        then Path_I = Path_I - 1              /* teb */
    end

  Select
    When Abbrev("ADD",Word_1,1) Then Do
         If Word_2 = "" Then Word_2 = "FIRST"    /* Default to first */
         If DupCk then Call Del_Path Path_1   /* Delete the New Path */
         Select
           When Abbrev("FIRST", Word_2,1) Then Do
                  Call Move_Path 1 Path_I
                  Path.1 = Path_1
                End
           When Abbrev("LAST",  Word_2,1) Then Do
                  Path_I = Path_I + 1
                  Path.Path_I = Path_1
                End
           When Abbrev("BEFORE",Word_2,1) Then Do
                  I1 = Find_Path(Path_2)
                  Call Move_Path I1 Path_I;
                  Path.I1 = Path_1
                End
           When Abbrev("AFTER", Word_2,1) Then Do
                  I1 = Find_Path(Path_2)
                  I1 = I1 + 1
                  Call Move_Path I1 Path_I;
                  Path.I1 = Path_1
                End
           Otherwise Do;
             If \Quiet then do
               If Word_2 <> ""
                 then Say '"'Word_2'" is not a valid keyword.'
                 else Say "Missing keyword."
               Say "  Use First, Last, Before or After."
             End
             if tmp_fn \= '' then '@erase' tmp_fn
             Exit 1
           End
         End
         End
    When Abbrev("DELETE",Word_1,1) Then Do
           I1 = Find_Path(Path_1)
           Path_I = Path_I - 1
           Do I = I1 to Path_I
              I2 = I + 1
              Path.I = Path.I2
           End
         End
    When Abbrev("REPLACE",Word_1,1) Then Do
           If \Abbrev("WITH",Word_2,1) Then Do
              If \Quiet then do
                If Word_2 <> ""
                  then Say '"'Word_2'" is not a valid keyword.  Use "With".'
                  else Say 'Missing the "With" keyword.'
              End
              if tmp_fn \= '' then '@erase' tmp_fn
              Exit 1
            End
           If DupCk then Call Del_Path Path_2  /* Delete the New Path */
           I1 = Find_Path(Path_1)
           Path.I1 = Path_2
         End
    When Abbrev("TEST",Word_1,1) Then Do
           I1 = Find_Path(Path_1)
           Exit 0;  /* If control returns from Find_Path the dir. was found */
         End
    Otherwise Do;
      If \Quiet then Say '"'Word_1'" is not a valid function.  Use Add, Delete, Replace or Test.'
      if tmp_fn \= '' then '@erase' tmp_fn
      Exit 1
      End
    End

  New_Path = ""
  Do I = 1 to Path_I
    New_Path = New_Path || Path.I";"
  End
  If Path_I > 0 Then Do
     New_Path = left(New_Path,length(New_Path)-1)
  End

  /* Set the Path in the Rexx environment and the OS/2 parent environment. */
  If tmp_fn = '' Then Do
     Path_Data = Value(Set_Target,New_Path,environment)   /* The parent. */
     If \Quiet & Echo Then Do
        Say Set_Target" = "New_Path
     End

     If NTSET_ENV \= ''
        Then RC = lineout(NTSET_ENV,"@SET "Set_Target"="New_Path)
  End

  Else Do
     New_Path = '@SET' Set_Target '=' New_Path
     rc = lineout(tmp_fn,New_Path,1)
     rc = stream(tmp_fn,'c','close')
     'call' tmp_fn
     nop
     '@erase' tmp_fn
  End
Return

Move_Path: Procedure Expose Path. Path_I;
  Parse arg I1 I2 etc
  Do I3 = I2 to I1 by -1
    I4 = I3 + 1
    Path.I4 = Path.I3  /* Move everything down 1 */
  End
  Path_I = Path_I + 1
Return;

Find_Path: Procedure Expose Path. Path_I Quiet;
  Parse arg Path_1 etc
  Found = 0
  Do I = 1 to Path_I
    If translate(Path.I) = translate(Path_1) then Do    /* teb */
       Found = 1
       Leave
       End
    End
  If \Found then Do
       If \Quiet then Say 'Target path "'Path_1'" not found.'
       Exit 3
     End
Return I;

Del_Path: Procedure Expose Path. Path_I Quiet;
  Parse arg Path_1 ";" etc
  Do while Path_1 <> ""
     Do I1 = 1 to Path_I
       If translate(Path.I1) = translate(Path_1) & I1 <= Path_I
          then do
             Path_I = Path_I - 1
             Do I2 = I1 to Path_I
                I3 = I2 + 1
                Path.I2 = Path.I3  /* Move everything up 1 */
             End
          End
     End
     Parse var etc Path_1 ";" etc
   End
Return;

/*----------------------------------------------------------------------*/
View_Help: Procedure  /* View the Help for this command    ATH  2/05/93 */
  Parse Arg Help_Book Subject Paths
  /* Load the RxUtils if not already loaded               */
  Call RxFuncAdd 'RxFileExist', 'RXUTILS', 'RxFileExist'
  Call RxFuncAdd 'RxSearchPath', 'RXUTILS', 'RxSearchPath'
  Book_Spec = Help_Book
  Parse Var Paths Path Etc
  If \RxFileExist(Help_Book) /* Is the file in the current directory? */
     Then Do until Path = "" /* No - look for it.  */
       Book_Spec = RxSearchPath(Path, Help_Book)
       If Book_Spec <> "" Then leave   /* Found it */
       Parse Var Etc Path Etc          /* Next */
     End
  If Book_Spec <> ""  /* Did we find the Book? */
     Then Do
       Say "View" Book_Spec Subject
       "View" Book_Spec Subject
       Exit RC
  End
  Else Do
       Say '"'Help_Book'" not found in the "'paths'" paths.'
       Exit 1
  End
Return

Help:
  "@ECHO OFF"
  Opt.1 = ''; Opt.0 = 'NO'  /* Used to display defaults ATH  3/19/92 */
  "CLS"
  Say
  Say ' ModPath (Modify Path) will change an OS/2 Environment variable containing'
  Say ' "Path" information by modifying a single path element within the variable.  A'
  Say ' single path element is any valid path statement separated by a semicolon (;).'
  Say ''
  Say ' M ÄÂÄ PATH ÄÂÂ Delete ÄÄ old_path ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÂÄÄÄÄÄÄÄÄÄÄÄÂÂ'
  Say ' O  ÃÄ DPATH ´Ã Replace Ä old_path ÄÄÄÄ With ÄÄÄ new_path ÄÄÄ´Ã /Dupcheck ´³'
  Say ' D  ÃÄ BOTH Ä´Ã Test ÄÄÄÄ target_path ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Ã /Silent ÄÄ´³'
  Say ' P  ÃÄ ... ÄÄÙÀ Add ÄÄÄÄÄ new_path ÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ´Ã /Echo ÄÄÄÄ´³'
  Say ' A  ³                                 Ã First Ä´             ³Ã /Force ÄÄÄ´³'
  Say ' T  ³                                 Ã Last ÄÄÙ             ³Ã /NO...ÄÄÄÄ´³'
  Say ' H  ³                                 Ã Before Ä target_path ´ÀÄÄÄÄÄÄÄÄÄÄÙ³' /* TJM 04/30/92 */
  Say '    ÃÄ ? ÄÄÄ¿                         À After ÄÄ target_path Ù             ³' /* TJM 04/30/92 */
  Say '    ÀÄ Help ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
  Say ''
  Say ' Where: PATH or DPATH can be any valid environment statement using the same'
  Say '                    data format set by the OS/2 "PATH" command.  BOTH will '
  Say '                    modify both the PATH and DPATH environment statements.'
  Say '        new_path    one or more paths to be set in the environment statement.'
  Say '        old_path    a path to be modified in the environment statement.'
  Say '        target_path a path to be searched for in the environment statement.'
  Say ''
  Say ' Defaults Options = /'opt.DupCk'Dupcheck, /'opt.Quiet'Silent, /'opt.Echo'Echo, /'opt.Force'Force.'
Exit;

/* This is where execution ends for Windows NT.  It's dead code for OS/2
:EndNT */
