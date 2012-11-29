/* ------------------------------------------------------------------ */
/* MAKECMD.CMD - update the runtime system for REXX programs based on */
/*               TEMPLATE v2.+                                        */
/*               or delete all comments from 'normal' OS/2 CMD files  */
/*                                                                    */
/* (c) Copyright Bernd Schemmer 1994,1995,1996                        */
/*                                                                    */
/* Author:                                                            */
/*   Bernd Schemmer                                                   */
/*   Baeckerweg 48                                                    */
/*   D-60316 Frankfurt am Main                                        */
/*   Germany                                                          */
/*   Compuserve: 100104,613                                           */
/*                                                                    */
/* Usage:                                                             */
/*   MAKECMD {sourceFiles} {targetDir} {TEMPLATEFile}                 */
/*                                                                    */
/* where:                                                             */
/*   sourceFiles                                                      */
/*     - source files (jokers are ok, def.: .\*.SRC)                  */
/*       MAKECMD assumes that files with the extension .SRC           */
/*       are files created with MAKESRC.CMD but you can also use      */
/*       MAKECMD for full functional .CMD-files based on              */
/*       TEMPLATE v2.+. This files must have the extension .CMD.      */
/*                                                                    */
/*       Files with the extension '.CMD' were the first chars are not */
/*       a REXX comment are considered to be normal OS/2 cmd files.   */
/*       In this case MAKECMD only deletes all comment lines          */
/*       (lines beginning with 'REM') and all empty lines from the    */
/*       source files.                                                */
/*                                                                    */
/*   targetDir                                                        */
/*     - directory for the target files (def.: parent dir ..)         */
/*                                                                    */
/*   templateFile                                                     */
/*     - file with the runtime system for the cmds                    */
/*       (def.: .\TEMPLATE.CMD)                                       */
/*                                                                    */
/* returns:                                                           */
/*   0 - okay                                                         */
/*  else error                                                        */
/*                                                                    */
/* IMPORTANT:                                                         */
/*   MAKECMD updates only those files, from which the targetfile      */
/*   is out of date compared to the date of the sourcefile or the     */
/*   date of the templatefile.                                        */
/*   Not existing targetfiles are created. To force an update in any  */
/*   case delete the targetfiles.                                     */
/*                                                                    */
/*   To use this program for REXX cmds you MUST LEAVE the lines       */
/*                                                                    */
/*      ... Start of Part n of the source code of TEMPLATE.CMD ...    */
/*                                                                    */
/*   and                                                              */
/*                                                                    */
/*      ...  End of Part n of the source code of TEMPLATE.CMD ...     */
/*                                                                    */
/*   (where n is 1,2,3 or 4) in your programs!!!                      */
/*   You may only change the lines prior to the line                  */
/*                                                                    */
/*      ...  End of Part n of the source code of TEMPLATE ...         */
/*                                                                    */
/*   (with n=1) and the lines after the line                          */
/*                                                                    */
/*      ... Start of Part n of the source code of TEMPLATE ...        */
/*                                                                    */
/*   (with n=4) in your programs!                                     */
/*                                                                    */
/* Notes:                                                             */
/*   This cmd needs the programs RXQUEUE and ATTRIB to be in the PATH.*/
/*   Sourcefiles with an extension not equal .SRC or .CMD are only    */
/*   copied.                                                          */
/*   You may use the file MAKECMD.INI in the source directory to      */
/*   exclude some files from the update process.                      */
/*   This is helpful if you're using a filemask for the parameter     */
/*   sourcefile.                                                      */
/*   The format of MAKECMD.INI is:                                    */
/*                                                                    */

/*------------------ Start of example --------------------------------*\
;
; this is an example ini file for makecmd.cmd
; (lines beginning with a semicolon are comment lines)
;
; files to copy (no further action):
COPY: CID.INC DEFAULT.CMD 
;
; files to exclude (no action at all):
;
EXCLUDE: __GEFM__ MAKECMD.INI MAKECMD.CMD MAKE.CMD
EXCLUDE: MAKESRC.CMD
EXCLUDE: MAKELOG.BAK MAKELOG.LOG
;
\*-------------------- End of example --------------------------------*/

/*                                                                    */
/* History:                                                           */
/*   02.12.1994 /bs v1.00                                             */
/*   03.12.1994 /bs                                                   */
/*   14.12.1994 /bs v1.10                                             */
/*     - changed messages for one file compiles                       */
/*   18.12.1994 /bs v1.15                                             */
/*     - added code to create the tokenimage of the target files      */
/*   08.01.1995 /bs v1.20                                             */
/*     - first public release                                         */
/*   26.02.1995 /bs v1.21                                             */
/*     - suppress output from the OS/2 commands used                  */
/*   02.03.1995 /bs v1.50                                             */
/*     - added support for OS/2 CMD files (no REXX)                   */
/*   30.07.1995 /bs v1.51                                             */
/*     - corrected a minor bug                                        */
/*   08.08.1996 /bs v1.52                                             */
/*     - corrected a bug in the file date compare routine             */
/*       (this routine didn't compare the time correct)               */
/*                                                                    */
/*                                                                    */
/* Distribution:                                                      */
/*   This program is part of the TEMPLATE package. See the file       */
/*   README.DOC from this package or the file TEMPLATE.CMD for my     */
/*   distribution and using policy.                                   */
/*   If you need further help, you may write me a message.            */
/*                                                                    */
/*                                                                    */
/* Based on TEMPLATE.CMD v3.04, TEMPLATE is (c) 1996 Bernd Schemmer,  */
/* Baeckerweg 48, D-60316 Frankfurt, Germany, Compuserve: 100104,613  */
/*                                                                    */
/* ------------------------------------------------------------------ */

                        /* init all global stems                      */
  parse value '' with prog. global. screen. I!.

/* ------------------------------------------------------------------ */
/*** change the following values to your need                       ***/

         global.__Version = 1.52         /* Version of MAKECMD.CMD    */

       global.__SignOnMsg = 1   /* set to 0 if you do not want the    */
                                /* program start and end messages     */

         global.__NeedCID = 0   /* set to 1 if you need CID support   */

      global.__NeedColors = 1   /* set to 1 if you want colored msgs  */

  global.__NeedPatchCheck = 1   /* set to 1 if you want the program   */
                                /* to search for a patched version of */
                                /* this program                       */

/***                End of variables to change                      ***/
/*      HINT: The further program code is in the function MAIN        */

/***        End of Part 1 of the source code of TEMPLATE.CMD        ***/


/***       Start of Part 2 of the source code of TEMPLATE.CMD       ***/

/*************** DO NOT CHANGE THE FOLLOWING LINES ********************/

                        /* names of the global variables, which all   */
                        /* procedures must know                       */
  exposeList = 'prog. screen. I!. global. exposeList ' exposeList

                        /* check the type of the base message number  */
                        /* SIGNAL on VALUE is off at this time!       */
  if datatype( global.__BaseMsgNo, 'W' ) <> 1 then
    global.__BaseMsgNo = 1000

                        /* init internal variables                    */
  I!. = ''
                        /* save default STDOUT and STDERR             */
  if symbol( 'prog.__STDOUT' ) = 'VAR' then
    I!.__2 = prog.__STDOUT
  if symbol( 'prog.__STDERR' ) = 'VAR' then
    I!.__3 = prog.__STDERR

                        /* init the stems prog. & screen.             */
  parse value '' with prog. screen.

                        /* reset the timer                            */
  call time 'R'

                        /* restore default STDOUT and STDERR          */
  prog.__STDOUT = I!.__2;    prog.__STDERR = I!.__3


                        /* get the number of the first line with      */
                        /* user code                                  */
  call I!.__GetUserCode

/* ------------------------------------------------------------------ */
/* install the error handler                                          */

                        /* break errors (CTRL-C)                      */
  CALL ON HALT        NAME I!.__UserAbort
                        /* syntax errors                              */
  SIGNAL ON SYNTAX    NAME I!.__ErrorAbort
                        /* using of not initialisized variables       */
  SIGNAL ON NOVALUE   NAME I!.__ErrorAbort
                        /* failure condition                          */
  SIGNAL ON FAILURE   NAME I!.__ErrorAbort
                        /* error condition                            */
  SIGNAL ON ERROR     NAME I!.__ErrorAbort
                        /* disk not ready condition                   */
  SIGNAL ON NOTREADY  NAME I!.__ErrorAbort

/* ------------------------------------------------------------------ */
/* init the variables                                                 */

                        /* get & save the parameter                   */
  parse arg I!.__RealParam 1 prog.__Param

                        /* init the variables                         */

                        /* define exit code values                    */
  global.__ErrorExitCode = 255
     global.__OKExitCode = 0

                        /* init the compound variable prog.           */
  call I!.__InitProgStem

                        /* define the variables for CID programs      */
  call I!.__InitCIDVars

                        /* init the program exit code                 */
  prog.__ExitCode = global.__OKExitCode

                        /* check the parameter and env. variables     */
                        /* This must run before I!.__InitColorVars!   */
  call I!.__chkPandE

                        /* define the color variables                 */
  call I!.__InitColorVars

                        /* check if there is a logfile parameter      */
  call I!.__SetLogVars

/* ------------------------------------------------------------------ */
/* show program start message                                         */

  call I!.__SignMsg

/* ------------------------------------------------------------------ */

                        /* check if there is a patched version of     */
                        /* this program                               */
  call I!.__CheckPatch

/* ------------------------------------------------------------------ */
                        /* check for a help parameter                 */
  if pos( translate( word( prog.__Param,1 ) ), ,
          '/?/H/HELP/-?-H-HELP' ) <> 0 then
  do
    prog.__exitCode = 253

    call I!.__CallUserProc 1, 'ShowUsage'

    SIGNAL I!.__programEnd

  end /* pos( translate( ... */

/* ------------------------------------------------------------------ */

                        /* call the main procedure                    */
  call I!.__CallUserProc 2, 'main' strip( prog.__Param )

                        /* set prog.__ExitCode to the return          */
                        /* code of the function main, if any          */
                        /* returncode was returned                    */
  if symbol( 'I!.__UserProcRC' ) == 'VAR' then
    prog.__ExitCode = I!.__UserProcRC

/* ------------------------------------------------------------------ */
/* house keeping                                                      */

I!.__ProgramEnd:

                                /* call the exit routines             */
  do while prog.__exitRoutines <> ''

                        /* delete the name of the routine from the    */
                        /* list to avoid endless loops!               */
    parse var prog.__ExitRoutines I!.__cer prog.__ExitRoutines

    call I!.__CallUserProc 1, I!.__cer

  end /* do while prog.__ExitRoutines <> '' */

                                /* restore the current directory      */
  if symbol( 'prog.__CurDir' ) == 'VAR' then
    call directory prog.__CurDir

                                /* show sign off message              */
  call I!.__SignMsg 'E'

EXIT prog.__ExitCode

/* ------------------------------------------------------------------ */
/*-function: show the sign on or sign off message                     */
/*                                                                    */
/*-call:     I!.__SignMsg which                                       */
/*                                                                    */
/*-where:    which - 'E' - show the sign off message                  */
/*                         else show the sign on message              */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
I!.__SignMsg: PROCEDURE expose (exposeList)
  if 1 == global.__SignOnMsg then
  do

                        /* default: program start message             */
    i = 12

    if arg(1) = 'E' then
    do
      i = 13
                        /* program end message                        */
      i!.__rc1 = prog.__ExitCode

                                /* check if the exit code is decimal  */
                                /* and convert it to hexadecimal if   */
                                /* possible                           */
      if dataType( prog.__ExitCode, 'W' ) then
      do
        if prog.__ExitCode < 0 then
          prog.__ExitCode = 65536 + prog.__ExitCode
        i!.__rc2 = D2X( prog.__ExitCode )
      end /* if .. */

    end /* if arg(1) = 'E' then */

    screen.__CurColor = screen.__SignOnColor
    call Log I!.__GetMsg( i, prog.__Name, global.__Version, date(),,
                          time(), i!.__rc1, i!.__rc2 )
    screen.__CurColor = screen.__NormalColor
  end /* if 1 == global.__SignOnMsg then */
RETURN

/* ------------------------------------------------------------------ */
/*-function: call a user defined routine                              */
/*           (avoid errors if the routine is not defined)             */
/*                                                                    */
/*-call:     I!.__CallUserProc errorAction, procName {procParameter}  */
/*                                                                    */
/*-where:    errorAction - action, if procName is not defined         */
/*                         0: do nothing (only set the RC)            */
/*                         1: show a warning and set the RC           */
/*                         2: abort the program                       */
/*           procName - name of the procedure                         */
/*           procParameter - parameter for the procedure              */
/*                                                                    */
/*-returns:  1 - ok                                                   */
/*           0 - procname not found                                   */
/*                                                                    */
/*-output:   I!.__UserProcRC - Returncode of the called procedure     */
/*                             (dropped if the proedure don't         */
/*                             return a value)                        */
/*                                                                    */
I!.__CallUserProc: PROCEDURE expose (exposeList) result rc sigl
  parse arg I!.__ErrorAction , I!.__ProcN I!.__ProcP

  I!.__thisRC = 0
  drop I!.__UserProcRC

  iLine = 'call ' I!.__ProcN
  if prog.__Trace = 1 & I!.__ProcN = 'main' then
    iLine = 'trace ?a;'|| iLine

/** DO NOT CHANGE, ADD OR DELETE ONE OF THE FOLLOWING SEVEN LINES!!! **/
  I!.__ICmdLine = GetLineNo()+2+(I!.__ProcP <> '')*2               /*!*/
  if I!.__ProcP = '' then                                          /*!*/
    interpret iLine                                                /*!*/
  else                                                             /*!*/
    interpret iLine "I!.__ProcP"                                   /*!*/
/** DO NOT CHANGE, ADD OR DELETE ONE OF THE PRECEEDING SEVEN LINES!! **/

/* Caution: The CALL statement changes the variable RESULT!           */
  I!.__0 = trace( 'off' )

  I!.__thisRC = 1
  if symbol( 'RESULT' ) == 'VAR' then
    I!.__UserProcRC = value( 'RESULT' )
    
                    /* this label is used if the interpret command    */
                    /* ends with an error                             */
I!.__CallUserProc2:

  if 0 == I!.__ThisRC then
    select

      when 1 == I!.__ErrorAction then
        call ShowWarning I!.__GetMsg( 1 , I!.__ProcN )

      when 2 == I!.__ErrorAction then
        call ShowError global.__ErrorExitCode , ,
                       I!.__GetMsg( 1, I!.__ProcN )
      otherwise
        nop

    end /* select */

RETURN I!.__thisRC

/* ------------------------------------------------------------------ */
/*-function: set the variables for the logfile handling               */
/*                                                                    */
/*-call:     I!.__SetLogVars                                          */
/*                                                                    */
/*-input:    prog.__Param - parameter for the program                 */
/*                                                                    */
/*-output:   prog.__LogFile     - name of the logfile (or NUL)        */
/*           prog.__LogSTDERR   - string to direct STDERR into the    */
/*                                logfile                             */
/*           prog.__LogSTDOUT   - string to direct STDOUT into the    */
/*                                logfile                             */
/*           prog.__LogAll      - string to direct STDOUT and STDERR  */
/*                                into the logfile                    */
/*           prog.__LogFileParm - string to inherit the logfile       */
/*                                parameter to a child CMD            */
/*           prog.__Param       - program parameter without the       */
/*                                logfile parameter                   */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
I!.__SetLogVars: PROCEDURE expose (exposeList)
  parse var prog.__Param prog.__param '/L:' logFileName ' ' rest

  prog.__param = prog.__Param rest

                        /* avoid an error if the drive is not ready   */
  SIGNAL OFF NOTREADY

                        /* default log device is the NUL device       */
  prog.__LogFile = 'NUL'

  if logFileName <> '' then
  do
                        /* check if we can write to the logfile       */
    logStatus = stream( logFileName, 'c', 'OPEN WRITE')
    if logStatus <> 'READY:' then
    do
      prog.__LogFileParm = ''

      call ShowWarning I!.__GetMsg( 2, logFileName, logStatus )

    end /* if logStatus <> 'READY:' then */
    else
    do
                        /* close the logfile                          */
      call stream logFileName, 'c', 'CLOSE'

                        /* get the fully qualified name of the        */
                        /* logfile                                    */
                        /*                                      v3.04 */
      parse upper value stream( logFileName, 'c', 'QUERY EXIST' ) WITH prog.__LogFile

      prog.__LogFileParm = '/L:' || prog.__LogFile
    end /* else */
  end /* if prog.__LogFile <> '' then */

                        /* variable to direct STDOUT of an OS/2       */
                        /* program into the logfile                   */
  prog.__LogSTDOUT = ' 1>>' || prog.__LogFile

                        /* variable to direct STDERR of an OS/2       */
                        /* program into the logfile                   */
  prog.__LogSTDERR = ' 2>>' || prog.__LogFile

                        /* variable to direct STDOUT and STDERR of    */
                        /* an OS/2 program into the log file          */
  prog.__LogALL = prog.__LogSTDERR || ' 1>>&2'

RETURN

/* ------------------------------------------------------------------ */
/*-function: check the parameter and the environment variables for    */
/*           the runtime system                                       */
/*                                                                    */
/*-call:     I!.__chkPandE                                            */
/*                                                                    */
/*-input:    prog.__Param - parameter for the program                 */
/*           prog.__env - name of the environment                     */
/*                                                                    */
/*-output:   prog.__QuietMode - 1 if parameter '/Silent' found        */
/*                              or environment variable SILENT set    */
/*           prog.__NoSound   - 1 if parameter '/NoSound' found       */
/*                              or environment variable SOUND set     */
/*           screen.          - "" if parameter '/NoANSI' found       */
/*                              or environment variable ANSI set      */
/*           prog.__Param     - remaining parameter for the procedure */
/*                              MAIN.                                 */
/*           prog.__Trace     - 1 if parameter '/Trace' found         */
/*                              or if the environment variable        */
/*                              RXTTRACE is set to MAIN               */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
I!.__chkPandE: PROCEDURE expose (exposeList)

  global.__verbose = value( 'VERBOSE' ,, prog.__env )

  o!.0 = 4                              /* no. of known parameters    */
                                        /* and environment variables  */

  o!.1.parm = '/SILENT'                 /* parameter name             */
  o!.1.env  = 'SILENT'                  /* name of the env. var       */
  o!.1.vals = 'ON 1'                    /* possible values for the    */
                                        /* environment variable       */
  o!.1.stmt = 'prog.__QuietMode=1'      /* statement to execute       */
                                        /* if this parameter was      */
                                        /* entered or the environment */
                                        /* variable is set            */

  o!.2.parm = '/NOSOUND'                /* turn sound off             */
  o!.2.env  = 'SOUND'
  o!.2.vals = 'OFF 0'
  o!.2.stmt = 'prog.__NoSound=1'

  o!.3.parm = '/NOANSI'                 /* turn ANSI support off      */
  o!.3.env  = 'ANSI'
  o!.3.vals = 'OFF 0'
  o!.3.stmt = 'global.__NeedColors=0'

  o!.4.parm = '/TRACE'          /* exeucte MAIN in single step mode   */
  o!.4.env  = 'RXTTRACE'
  o!.4.vals = 'MAIN'
  o!.4.stmt = 'prog.__Trace=1'

  do i = 1 to o!.0
                        /* check the parameter                        */
    j = wordPos( o!.i.parm, translate( prog.__Param ) )
    if j = 0 then       /* no parameter found, check the env. var     */
      j = wordPos( translate( value( o!.i.env ,, prog.__env ) ) ,,
                    o!.i.vals )
    else                /* parameter found, delete the parameter      */
      prog.__Param = strip( delWord( prog.__Param, j,1 ) )

                        /* if j is not zero either the parameter was  */
                        /* found or the environment variable is set   */
    if j <> 0 then
      interpret o!.i.stmt
  end /* do i = 1 to o!.0 */

RETURN

/* ------------------------------------------------------------------ */
/*-function:  convert a file or directory name to OS conventions      */
/*            by adding a leading and trailing quote or double quote  */
/*                                                                    */
/*-call:      convertNameToOS dir_or_file_name                        */
/*                                                                    */
/*-where:     dir_or_file_name = name to convert                      */
/*                                                                    */
/*-returns:   converted file or directory name                        */
/*                                                                    */
ConvertNameToOS: PROCEDURE expose (exposeList)
  parse arg fn

  if pos( '"', fn ) == 0 then
    fn = '"' || fn || '"'
  else if pos( "'", fn ) == 0 then
    fn = "'" || fn || "'"

RETURN fn

/* ------------------------------------------------------------------ */
/*-function: flush the default REXX queue                             */
/*                                                                    */
/*-call:     FlushQueue                                               */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
FlushQueue: /* PROCEDURE expose (exposeList) */
  do while QUEUED() <> 0
    parse pull
  end /* do while QUEUED() <> 0 */
RETURN ' '                                                   /* v3.03 */

/* ------------------------------------------------------------------ */
/*-function: include a file if it exists                              */
/*                                                                    */
/*-call:     TryInclude( IncludeFile )                                */
/*                                                                    */
/*-where:    IncludeFile = name of the file to include                */
/*                                                                    */
/*-output:   prog.__rc = 0 - include file executed                    */
/*           else: file not found                                     */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
TryInclude:
  parse upper arg I!.__IncFileName
  prog.__rc = 1

  if I!.__IncFileName = '' then
    RETURN ' '                                               /* v3.03 */

  if stream( I!.__IncFileName,'c','QUERY EXIST' ) = '' then
    RETURN ' '                                               /* v3.03 */

  prog.__rc = 0

  /* execute INCLUDE */

/* ------------------------------------------------------------------ */
/*-function: include a file                                           */
/*                                                                    */
/*-call:     Include( IncludeFile )                                   */
/*                                                                    */
/*-where:    IncludeFile = name of the file to include                */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
Include:
  parse upper arg I!.__IncFileName

                        /* check if the include file exists           */
  if stream( I!.__IncFileName, 'c', 'QUERY EXIST' ) == '' then
    call ShowError global.__ErrorExitCode, ,
                   I!.__GetMsg( 3, I!.__IncFileName )

                        /* read and interpret the include file        */
  do I!.__IncLineNO = 1 while lines( I!.__IncFileName ) <> 0
    I!.__IncCurLine = ''
                        /* save the absolute position of the start of */
                        /* this line for the error handler            */
    I!.__IncCurLinePos = stream(I!.__IncFileName,'c','SEEK +0')

                        /* handle multi line statements               */
    do forever
      I!.__IncCurLine = I!.__IncCurLine ,
                        strip( lineIn( I!.__IncFileName ) )

      if right( I!.__IncCurLine,1 ) <> ',' then
        leave

                        /* statement continues on the next line       */
      if lines( I!.__IncFileName ) == 0 then
        call ShowError global.__ErrorExitCode ,,
             I!.__GetMsg( 4, I!.__IncFileName )

                        /* the next lines is only executed if the IF */
                        /* statement above is FALSE                  */
      I!.__IncCurLine = substr( I!.__IncCurLine,1, ,
                                length( I!.__IncCurLine )-1 )

    end /* do forever */

    I!.__IncActive = 1
    interpret I!.__IncCurLine
    I!.__IncActive = 0

  end /* do I!.__IncLineNO = 1 while lines( I!.__IncFileName ) <> 0 ) */

                        /* close the include file!                    */
  call stream I!.__IncFileName, 'c', 'CLOSE'

                    /* do NOT return a NULL string ('')!        v3.03 */
                    /* Due to a bug in the CMD.EXE this will    v3.03 */
                    /* cause the error SYS0008 after the 32nd   v3.03 */
                    /* call of this function!                   v3.03 */
RETURN ' '

/* ------------------------------------------------------------------ */
/*-function: init color variables                                     */
/*                                                                    */
/*-call:     I!.__InitColorVars                                       */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
I!.__InitColorVars: /* PROCEDURE expose (exposeList) */

  if 1 == global.__NeedColors then
  do
    escC = '1B'x || '['                                      /* v3.04 */

                        /* delete rest of the line                    */
    screen.__DelEOL      = escC || 'K'

                        /* save the cursor position                   */
    screen.__SavePos     = escC || 's'

                        /* restore the cursor position                */
    screen.__RestPos     = escC || 'u'

                        /* define color attributes                    */
    screen.__AttrOff     = escC || '0;m'
    screen.__Highlight   = escC || '1;m'
    screen.__normal      = escC || '2;m'
    screen.__blink       = escC || '5;m'
    screen.__invers      = escC || '7;m'
    screen.__invisible   = escC || '8;m'

                        /* define foreground color variables          */
    screen.__fgBlack     = escC || '30;m'
    screen.__fgRed       = escC || '31;m'
    screen.__fgGreen     = escC || '32;m'
    screen.__fgYellow    = escC || '33;m'
    screen.__fgBlue      = escC || '34;m'
    screen.__fgMagnenta  = escC || '35;m'
    screen.__fgCyan      = escC || '36;m'
    screen.__fgWhite     = escC || '37;m'

                        /* define background color variables          */
    screen.__bgBlack     = escC || '40;m'
    screen.__bgRed       = escC || '41;m'
    screen.__bgGreen     = escC || '42;m'
    screen.__bgYellow    = escC || '43;m'
    screen.__bgBlue      = escC || '44;m'
    screen.__bgMagnenta  = escC || '45;m'
    screen.__bgCyan      = escC || '46;m'
    screen.__bgWhite     = escC || '47;m'

                        /* define color variables                     */
    screen.__ErrorColor  = screen.__AttrOff || screen.__Highlight || ,
                           screen.__FGYellow || screen.__bgRed
    screen.__NormalColor = screen.__AttrOff ||                       ,
                           screen.__fgWhite || screen.__bgBlack
    screen.__DebugColor  = screen.__AttrOff || screen.__Highlight || ,
                           screen.__fgBlue || screen.__bgWhite
    screen.__PromptColor = screen.__AttrOff || screen.__Highlight || ,
                           screen.__fgYellow || screen.__bgMagnenta

/* +++++++++++++++ DO NOT USE THE FOLLOWING COLORS! +++++++++++++++++ */
    screen.__SignOnColor = screen.__AttrOff || screen.__Highlight || ,
                           screen.__fggreen || screen.__bgBlack
    screen.__PatchColor  = screen.__AttrOff || screen.__Highlight || ,
                           screen.__fgcyan || screen.__bgRed
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

                            /* set the default color                  */
    screen.__CurColor    = screen.__NormalColor

                            /* turn ANSI word wrapping on             */
    if prog.__QuietMode <> 1 then
      call CharOut prog.__STDOUT, '1B'x || '[7h'

  end /* if 1 == global.__NeedColors then */

RETURN

/* ------------------------------------------------------------------ */
/*-function: init the stem prog.                                      */
/*                                                                    */
/*-call:     I!.__InitProgStem                                        */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*-Note:     DO NOT ADD ANY CODE TO THIS ROUTINE!                     */
/*                                                                    */
I!.__InitProgStem: /* PROCEDURE expose (exposeList) */
  prog.__Defparms = ' {/L:logfile} {/H} {/Silent} {/NoAnsi} {/NoSound} {/Trace}'

                        /* get the current directory in uppercase     */
  parse upper value directory() with prog.__CurDir           /* v3.04 */

                        /* get drive, path and name of this program   */
  parse upper source . . prog.__FullName
        prog.__Drive = filespec( 'D', prog.__FullName )
         prog.__Path = filespec( 'P',  prog.__FullName )
         prog.__Name = filespec( 'N',  prog.__FullName )
          prog.__Env = 'OS2ENVIRONMENT'

                        /* version of TEMPLATE.CMD                    */
      prog.__Version = 'V3.04'
    prog.__UserAbort = 1        /* allow user aborts                  */
 prog.__ExitRoutines = ''       /* list of routines to execute at     */
                                /* program end                        */

                                /* init the variables for cols and    */
                                /* rows                               */
  prog.__ScreenCols = 80
  prog.__ScreenRows = 25

                                /* install a local error handler      */
  SIGNAL ON SYNTAX Name I!.__InitProgStem1
                                /* try to call SysTextScreenSize()    */
  parse value SysTextScreenSize() with prog.__ScreenRows prog.__ScreenCols

I!.__InitProgStem1:

RETURN

/* ------------------------------------------------------------------ */
/*-function: init the variables for CID programs (only if the value   */
/*           of the variable global.__NeedCID is 1)                   */
/*                                                                    */
/*-call:     I!.__InitCIDVars                                         */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*-Note:     DO NOT ADD ANY CODE TO THIS ROUTINE!                     */
/*           Returncodes as defined by LCU 2.0                        */
/*                                                                    */
I!.__InitCIDVars: /* PROCEDURE expose (exposeList) exposeList CIDRC. */

  if 1 == global.__NeedCID then
  do
                        /* define return codes for CID programs       */
    CIDRC.__successful_program_termination  = C2D('0000'x, 2);
    CIDRC.__successful_log_warning_message  = C2D('0004'x, 2);
    CIDRC.__successful_log_error_Message    = C2D('0008'x, 2);
    CIDRC.__successful_log_severe_error     = C2D('0012'x, 2);

    CIDRC.__data_resource_not_found         = C2D('0800'x, 2);
    CIDRC.__data_resource_already_in_use    = C2D('0804'x, 2);
    CIDRC.__data_resource_Noauthorization   = C2D('0808'x, 2);
    CIDRC.__data_path_not_found             = C2D('0812'x, 2);
    CIDRC.__product_not_configured          = C2D('0816'x, 2);

    CIDRC.__storage_medium_exception        = C2D('1200'x, 2);
    CIDRC.__device_Not_Ready                = C2D('1204'x, 2);
    CIDRC.__not_enough_diskspace            = C2D('1208'x, 2);

    CIDRC.__incorrect_program_invocation    = C2D('1600'x, 2);
    CIDRC.__unexpected_condition            = C2D('1604'x, 2);
    CIDRC.__successfull_reboot              = C2D('FE00'x, 2);
    CIDRC.__successfull_reboot_with_warning = C2D('FE04'x, 2);
    CIDRC.__successfull_reboot_with_errmsg  = C2D('FE08'x, 2);
    CIDRC.__successfull_reboot_with_server_errMsg = C2D('FE12'x, 2);


                        /* xx = next state of the program             */
/*    CIDRC.__successfull_reboot_with_callback = C2D('FFxx'x, 2);     */

                        /* define exit code values                    */
    global.__ErrorExitCode = CIDRC.__unexpected_condition
       global.__OKExitCode = CIDRC.__successful_program_termination

                        /* add the stem CIDRC. to the exposeList      */
    exposeList = exposeList || ' CIDRC. '
  end /* if 1 == global.__NeedCID then */

RETURN


/***        End of Part 2 of the source code of TEMPLATE.CMD        ***/

/***       Start of Part 3 of the source code of TEMPLATE.CMD       ***/

/* ------------------------------------------------------------------ */
/*-function:  load a dll                                              */
/*                                                                    */
/*-call:                                                              */
/*   thisRC = LoadDll( registerFunction, dllName, entryPoint,         */
/*                     ,{deRegisterFunction},{checkFunction}          */
/*                     ,{IgnoreRxFuncAddRC},{RegisterErrorRC}         */
/*                     ,{errorAction}                                 */
/*                                                                    */
/*-where:                                                             */
/*         registerFunc = name of the dll init function               */
/*                        (e.g. "SysLoadFuncs")                       */
/*              dllName = name of the dll                             */
/*                        (e.g. "REXXUTIL")                           */
/*           entryPoint = entryPoint for the dll init function        */
/*                        (e.g. "SysLoadFuncs")                       */
/*       deRegisterFunc = name of the dll exit function               */
/*                        (e.g. "SysDropFuncs")                       */
/*                        If this parameter is entered, the           */
/*                        deRegisterFunction is automaticly called    */
/*                        at program end if the loading of the dll    */
/*                        was successfull.                            */
/*            checkFunc = function which must be loaded if the dll is */
/*                        loaded (def.: none -> always load the dll)  */
/*                        Note:                                       */
/*                        Do not use the registerFunction for this    */
/*                        parameter! A good candidate for this        */
/*                        parameter is the deRegisterFunction.        */
/*    IgnoreRxFuncAddRC = 1: ignore the rc from rxFuncAdd             */
/*                        0: do not ignore the rc from rxFuncAdd      */
/*                        (def.: 0)                                   */
/*                        Note: Always set this parameter to 1 if     */
/*                              using the program under WARP.         */
/*       RegisterErroRC = returncode of the dll init function         */
/*                        indicating a load error                     */
/*                        (def. none, -> ignore the returncode of the */
/*                         dll init function)                         */
/*           actionCode = 1: abort program if loading failed          */
/*                        0: do not abort program if loading failed   */
/*                        (def.: 1)                                   */
/*                                                                    */
/*-returns:                                                           */
/*   0 - loading failed                                               */
/*   1 - dll loaded                                                   */
/*   2 - dll already loaded                                           */
/*                                                                    */
/*-Note:                                                              */
/*   See the routine MAIN for some examples for using LoadDLL.        */
/*   LoadDLL can only handle dlls with an init function to register   */
/*   the further routines in the dll (like the function SysLoadFuncs  */
/*   in the dll REXXUTIL).                                            */
/*                                                                    */
LoadDll:  PROCEDURE expose (exposeList)
  parse arg regFunc , ,
            dllName , ,
            entryPoint , ,
            deregFunc , ,
            checkFunc , ,
            ignoreRXFuncAddRC, ,
            registerErrorRC, ,
            errorAction

                        /* check the necessary parameters             */
  if '' == entryPoint | '' == dllName | '' == regFunc then
    call ShowError global.__ErrorExitCode, I!.__GetMsg( 6 )

  if '' == ignoreRXFuncAddRC then
    ignoreRXFuncAddRc = 0

  if '' == errorAction then
    errorAction = 1

  I!.__LoadDLLRc = 0
                        /* if the 'checkFunc' is missing, we          */
                        /* assume that the dll is not loaded          */
  dllNotLoaded = 1
  if ( checkFunc <> '' ) then
    dllNotLoaded = rxFuncQuery( checkFunc )

  if dllNotLoaded then
  do
                        /* first deRegister the function        v3.01 */
    call rxFuncDrop regFunc                                  /* v3.01 */

                        /* load the dll and register the init         */
                        /* function of the dll                        */
    rxFuncAddRC = rxFuncAdd( regFunc, dllName, entryPoint )

    if \ rxFuncAddRC | ignoreRxFuncAddRC then
    do

      I!.__DllInitRC = 0
      if I!.__CallUserProc( 0, regFunc ) == 0 then
        I!.__DllInitRC = 'ERROR'

      if ( registerErrorRC <> '' & I!.__DLLInitRC == registerErrorRC ) | ,
         ( I!.__DllInitRC == 'ERROR' ) then
        nop
      else
      do
                        /* add the dll deregister function to the     */
                        /* program exit routine list                  */
        if DeregFunc <> '' then
          if \ rxFuncQuery( DeregFunc ) then
            prog.__ExitRoutines = prog.__ExitRoutines || ' ' || ,
                                  DeregFunc

        I!.__LoadDLLRc = 1
      end /* else */
    end /* if \ rxFuncAddRC | ignoreRxFuncAddRC then */
  end /* if dllNotLoaded then */
  else
    I!.__LoadDLLRc = 2  /* dll is already loaded                      */

  if 1 == errorAction & 0 == I!.__LoadDLLRC then
    call ShowError global.__ErrorExitCode,,
                   I!.__GetMsg( 5, dllName )

RETURN I!.__LoadDLLRc

/* ------------------------------------------------------------------ */
/*-function: show a string with word wrapping                         */
/*                                                                    */
/*-call:     showString Prefix, thisString                            */
/*                                                                    */
/*-where:                                                             */
/*           Prefix = prefix for the first line (e.g. "*-*" or "#" to */
/*                    use # leading blanks, # = 1 ... n )             */
/*           thisString - string to print                             */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
ShowString: PROCEDURE EXPOSE (exposeList)
  parse arg Prefix, thisStr

  maxLineL = prog.__ScreenCols-4

  if datatype( prefix, 'W' ) == 1 then
    prefix = copies( ' ' , prefix )

  maxWordL = maxLineL - length( prefix )

  thisRC = 0
  curStr = ''

  do i = 1 to words( thisStr)
    pStr = 0

    curStr = curStr || word( thisStr, i ) || ' '

    if length( curStr || prefix ||  word( thisStr, i+1 ) ) > maxLineL then
      pStr = 1

    if 1 == pStr | i == words( thisStr ) then
    do
      if length( prefix || curStr ) > prog.__ScreenCols then
      do until curStr = ''
        parse var curStr curStr1 =(maxWordL) ,
                                  curStr
        call log left( prefix || curStr1, prog.__ScreenCols )
        prefix = copies( ' ', length( prefix ) )
      end /* if length( ... then do until */
      else
        call Log left( prefix || curStr, prog.__ScreenCols )

      curStr = ''
      prefix = copies( ' ', length( prefix ) )
    end /* if 1 == pStr | ... */

  end /* do i = 1 to words( thisStr */

RETURN ' '                                                   /* v3.03 */

/* ------------------------------------------------------------------ */
/*-function: show a warning message                                   */
/*                                                                    */
/*-call:     showWarning message                                      */
/*                                                                    */
/*-where:    warningMessage - warning Message                         */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
ShowWarning: PROCEDURE expose (exposeList)
  parse arg wMsg

  screen.__CurColor = screen.__ErrorColor

  call I!.__LogStart

  call ShowString I!.__GetMsg( 7 ) || ' ', wMsg || '!'
  call I!.__LogSeparator

  screen.__CurColor = screen.__NormalColor
  call Log

RETURN ' '                                                   /* v3.03 */

/* ------------------------------------------------------------------ */
/*-function: show an error message and end the program                */
/*                                                                    */
/*-call:     ShowError exitCode, errorMessage                         */
/*                                                                    */
/*-where:    ExitCode - no of the error (= program exit code)         */
/*           errorMessage - error Message                             */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*-Note:     THIS ROUTINE WILL NOT COME BACK!!!                       */
/*                                                                    */
ShowError: PROCEDURE expose (exposeList)
  parse arg prog.__ExitCode, I!.__errMsg

  I!.__QM = prog.__QuietMode
                        /* turn quiet mode off                        */
  prog.__QuietMode = ''

  screen.__CurColor = screen.__ErrorColor

  call I!.__LogStart

  call Log left( I!.__GetMsg( 8, prog.__Name , prog.__ExitCode ) ,,
                 prog.__ScreenCols )
  call ShowString 1, I!.__errMsg || '!'

  call I!.__LogSeparator
  call Log
                        /* restore quiet mode status                  */
  prog.__QuietMode = I!.__QM

  if prog.__NoSound <> 1 then
  do
    call beep 537,300
    call beep 237,300
    call beep 537,300
  end /* if prog.__NoSound <> 1 then */

SIGNAL I!.__ProgramEnd

RETURN

/* ------------------------------------------------------------------ */
/*-function: log a debug message and clear the rest of the line       */
/*                                                                    */
/*-call:     logDebugMsg message                                      */
/*                                                                    */
/*-where:    message - message to show                                */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
/*-Note:     You do not need the 'call' keyword to use this routine.  */
/*                                                                    */
LogDebugMsg: PROCEDURE expose (exposeList)
  if global.__verbose <> '' then
  do
    parse arg dMsg
    screen.__CurColor = screen.__DebugColor
    call Log '+++' dMsg
    screen.__CurColor = screen.__NormalColor
  end /* if global.__verbose <> '' then */
RETURN ' '                                                   /* v3.03 */

/* ------------------------------------------------------------------ */
/*-function: write a CR/LF and a separator line to the screen and to  */
/*           the logfile                                              */
/*                                                                    */
/*-call:     I!.__LogStart                                            */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */

/* ------------------------------------------------------------------ */
/*-function: write a separator line to the screen and to the logfile  */
/*                                                                    */
/*-call:     I!.__LogSeparator                                        */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
I!.__LogStart:
  call log
I!.__LogSeparator:
  call Log ' ' || left('-', prog.__ScreenCols-2, '-' ) || ' '
RETURN

/* ------------------------------------------------------------------ */
/*-function: log a message and clear the rest of the line             */
/*                                                                    */
/*-call:     log message                                              */
/*                                                                    */
/*-where:    message - message to show                                */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
/*-Note:     You do not need the 'call' keyword to use this routine.  */
/*                                                                    */
Log: PROCEDURE expose (exposeList)
  parse arg msg

  logmsg = msg
  do i = 1 to words( prog.__LogExcludeWords )
    curWord = word( prog.__LogExcludeWords, i )
   
    do until j = 0
      j = Pos( curWord, logmsg )
      if j <> 0 then
        logmsg = delstr( logmsg, j, length( curWord ) )
    end /* do until j = 0 */
  end /* do i = 1 to words( prog.__LogExcludeWords ) */

  if prog.__QuietMode <> 1 then
  do
    if length( logmsg ) == prog.__ScreenCols  then
      call charout prog.__STDOUT, screen.__CurColor || ,
                                  msg || screen.__AttrOff
    else
      call lineOut prog.__STDOUT, screen.__CurColor || ,
                                  msg || screen.__AttrOff ||,
                                  screen.__DelEOL
  end /* if prog.__Quietmode <> 1 then */

  if symbol( 'prog.__LogFile' ) == 'VAR' then
    if prog.__LogFile <> '' then
    do
      call lineout prog.__LogFile, logmsg

                                /* close the logfile                  */
      call stream prog.__LogFile, 'c', 'CLOSE'
    end /* if prog.__LogFile <> '' then */

RETURN ' '                                                   /* v3.03 */

/* ------------------------------------------------------------------ */
/*-function: check if there is a patched version of this program      */
/*                                                                    */
/*-call:     I!.__CheckPatch                                          */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*-Note:     I!.__RealParam must contain the parameters for           */
/*           this program.                                            */
/*           The variables prog.__Path and prog.__Name must be set!   */
/*           This procedure ends the program with an EXIT command!    */
/*                                                                    */
I!.__CheckPatch: PROCEDURE expose (exposeList)

                        /* get the drive with patch cmd files         */
                        /*                                      v3.04 */
  parse upper value value( 'PATCHDRIVE',, prog.__env ) with pLW

  if global.__NeedPatchCheck <> 0 & ( pLW <> '' & pLW <> prog.__Drive ) then
  do

    pVer = pLW || prog.__Path || prog.__Name

                        /* check if a patched program version exists  */
    if stream( pVer, 'c', 'QUERY EXIST' ) <> '' then
    do
      pCmd = pVer || ' ' || I!.__RealParam

      screen.__CurColor = screen.__PatchColor
      call Log left( I!.__GetMsg( 9, pver ), prog.__ScreenCols )
      screen.__CurColor = screen.__AttrOff
      call I!.__LogSeparator

      '@cmd /c ' pCmd

      screen.__CurColor = screen.__AttrOff
      call I!.__LogSeparator
      screen.__CurColor = screen.__PatchColor
      call Log left( I!.__GetMsg( 10, rc ), prog.__ScreenCols )

      exit rc
    end /* if stream( ... */
  end /* if pLW <> '' */
RETURN

/* ------------------------------------------------------------------ */
/*-function: error handler for unexpected errors                      */
/*                                                                    */
/*-call:     DO NOT CALL THIS ROUTINE BY HAND!!!                      */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*-input:    I!.__IncActive:                                          */
/*             if 1 the error occured while executing an include file */
/*             statement. In this case the following variables are    */
/*             also used (Note that this variables are automaticly    */
/*             set by the routine INCLUDE()):                         */
/*               I!.__IncLineNo                                       */
/*                 Line no. of the include file                       */
/*               I!.__IncFileName:                                    */
/*                 Name of the include file                           */
/*               I!.__IncCurLinePos:                                  */
/*                 Fileposition of the first char of the line causing */
/*                 the error                                          */
/*                                                                    */
/*-Note:     THIS FUNCTION ABORTS THE PROGRAM WITH A JUMP TO THE      */
/*           LABEL I!.__PROGRAMEND!!!                                 */
/*                                                                    */
I!.__ErrorAbort:

                            /* turn ANSI word wrap on                 */   
  if screen.__CurColor <> '' then
    call CharOut prog.__STDOUT, '1B'x || '[7h'

                        /* check if the error occured in the error    */
                        /* handler                                    */
  if I!.__errorLineNo == sigl then
  do
    call charout 'STDERR:',,
                                                            '0D0A'x  ,
       'Fatal Error: Error in the error handler detected!'  '0D0A'x  ,
                                                            '0D0A'x  ,
       'Linenumber:       ' || sigl                         '0D0A'x  ,
       'Errorname:        ' || condition('C')               '0D0A'x  ,
       'Errordescription: ' || condition('D')               '0D0A'x  ,
                                                            '0D0A'x  ,
       'The program exit routines were not called!'         '0D0A'x  ,
       'Check if "(EXPOSELIST)" is included in the ' || ,
       'expose lists of all procedures!'                    '0D0A'x

    call beep 637,300 ; call beep 437,300 ; call beep 637,300
    exit 255

  end /* if I!.__errorLineNo == sigl then */

                        /* get the number of the line causing the     */
                        /* error                                      */
  I!.__errorLineNo = sigl

                        /* get the name of this error                 */
  I!.__ErrorName = condition('C')

                        /* get further information for this error     */
                        /* if available                               */
  I!.__ErrorCondition = condition('D')
  if I!.__ErrorCondition <> '' then
    I!.__ErrorCondition = ' (Desc.: "' || I!.__ErrorCondition || '")'

  if datatype( prog.__ScreenCols, 'W' ) <> 1 then
    prog.__ScreenCols = 80

  if SYMBOL( 'prog.__Name' ) <> 'VAR' | value( 'prog.__Name' ) == '' then
    if I!.__errorLineNO < I!.__FirstUserCodeLine then
      I!.__pName = '**Runtime**'
    else
      I!.__pName = '***???***'
  else
    i!.__pName = prog.__Name

                        /* reInstall the error handler                */
  INTERPRET  'SIGNAL ON ' value(condition('C')) ' NAME I!.__ErrorAbort'

                        /* check, if we should ignore the error       */
  if value( 'sigl' ) == value( 'I!.__ICmdLine' ) then
  do
    I!.__errorLineNo = 0
    SIGNAL I!.__CallUserProc2
  end /* if value( ... */

  screen.__CurColor = screen.__ErrorColor

  I!.__QM = prog.__QuietMode
                        /* turn quiet mode off                        */
  prog.__QuietMode = ''

                        /* init variables for printing the line       */
                        /* causing the error to the screen            */
  I!.__ThisSRCLine = ''
  I!.__ThisPrefix = ' *-* '

  call I!.__LogStart

  call ShowString ' ' || I!.__pName || ' - ', I!.__ErrorName || ,
                  I!.__ErrorCondition || ' error detected!'

                        /* check, if the RC is meaningfull for this   */
                        /* error                                      */
  if pos( I!.__ErrorName, 'ERROR FAILURE SYNTAX' ) <> 0 then
  do
    if datatype(rc, 'W' ) == 1 then
      if 'SYNTAX' == I!.__ErrorName then
         if rc > 0 & rc < 100 then
            call Log left( ' The error code is ' || rc || ,
                           ', the REXX error message is: ' || ,
                           errorText( rc ), ,
                           prog.__ScreenCols )
         else
           call log left( ' The error code is ' || rc || ,
                          ', this error code is unknown.',,
                          prog.__ScreenCols )
      else
        call Log left( ' The RC is ' || rc || '.', prog.__ScreenCols )
  end /* if pos( ... */

  if value( 'I!.__IncActive' ) == 1 then
  do
                /* error occured while interpreting an include file   */
    call ShowString 1, 'The error occured while executing the line ' || ,
                       I!.__IncLineNo || ' of the include file "' || ,
                       I!.__IncFileName || '".'

                        /* reset the file pointer of the include file */
                        /* to the start of the line causing the error */
    call stream I!.__IncFileName, 'c', 'SEEK =' || ,
                                                   I!.__IncCurLinePos

    I!.__SrcAvailable = stream( I!.__IncFileName, ,
                                   'c', 'QUERY EXIST' ) <> ''
  end
  else
  do
    call ShowString 1, 'The error occured in line ' ||,
                       I!.__errorLineNo || '.'

    I!.__thisLineNo = I!.__errorLineNo

                /* error occured in this file                         */
                /* check if the sourcecode is available               */
    SIGNAL ON SYNTAX   NAME I!.__NoSourceCode
    I!.__inMacroSpace = 1
    I!.__SrcAvailable = 0
    if sourceLine( I!.__errorLineNo ) <> '' then
      I!.__SrcAvailable = 1

    SIGNAL ON SYNTAX NAME I!.__ErrorAbort
    I!.__inMacroSpace = 0

  end /* else */

                        /* print the statement causing the error to   */
                        /* the screen                                 */
  if 1 == I!.__SrcAvailable then
  do
    call Log left( ' The line reads: ', prog.__ScreenCols )
    I!.__InterpretVar = 0

                /* read the line causing the error                    */
    call I!.__GetSourceLine

    I!.__FirstToken = strip(word( I!.__ThisSRCLine,1))
    if translate( I!.__FirstToken ) == 'INTERPRET' then
    do
      parse var I!.__ThisSRCLine (I!.__FirstToken) ,
                I!.__interpretValue
      I!.__InterpretVar = 1
    end /* if I!.__thisLineNo = I!.__errorLineNo */

                        /* handle multi line statements               */
    do forever
      call ShowString I!.__ThisPrefix, I!.__ThisSRCLine

      if right( strip( I!.__ThisSRCLine),1 ) <> ',' then
        leave

      I!.__ThisPrefix = 5

      call I!.__GetSourceLine
    end /* do forever */

    if 1 == I!.__InterpretVar then
    do
      I!.__interpretValue = strip( word(I!.__interpretValue,1) )

      if symbol( I!.__interpretValue ) == 'VAR' then
      do
        call Log left( '', prog.__ScreenCols )
        call Log left( ' The value of "' || I!.__interpretValue || ,
                       '" is:', prog.__ScreenCols )
        call ShowString ' >V> ', value( I!.__interpretValue )
      end /* if symbol( I!.__interpretValue ) = 'VAR' then */

    end /* if 1 == I!.__InterpretVar */

  end /* if 1 == I!.__SrcAvailable  then do */
  else
    call Log left( ' The sourcecode for this line is not available',,
                   prog.__ScreenCols )

I!.__NoSourceCode:
  SIGNAL ON SYNTAX NAME I!.__ErrorAbort

  if 1 == I!.__inMacroSpace then
  do
    parse source . . I!.__thisProgName

    if fileSpec( 'D', I!.__thisProgName ) == '' then
      call ShowString 1, ' The sourcecode for this line is not' || ,
                         ' available because the program is in' || ,
                         ' the macro space.'
    else
      call ShowString 1, ' The sourcecode for this line is not' || ,
                         ' available because the program is unreadable.'
  end /* if 1 == I!.__inMacroSpace then */

  call I!.__LogSeparator
  call Log

  prog.__ExitCode = global.__ErrorExitCode

  if prog.__NoSound <> 1 then
  do
    call beep 137,300;  call beep 337,300;  call beep 137,300
  end /* if prog.__NoSound <> 1 then */

  if 'DEBUG' == global.__verbose | prog.__Trace = 1 then
  do
                        /* enter interactive debug mode               */
    trace ?a
    nop
  end /* if 'DEBUG' == global.__verbose | ... */

                        /* restore quiet mode status                  */
  prog.__QuietMode = I!.__QM

SIGNAL I!.__programEnd

/* ------------------------------------------------------------------ */
/*-function: get the sourceline causing an error (subroutine of       */
/*           I!.__ErrorAbort)                                         */
/*                                                                    */
/*-call:     DO NOT CALL THIS IN YOUR CODE!!!                         */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*-Note:     -                                                        */
/*                                                                    */
I!.__GetSourceLine:
  if 1 == I!.__IncActive then
    I!.__ThisSRCLine = lineIn( I!.__IncFileName )
  else
  do
    I!.__ThisSRCLine = sourceLine( I!.__ThisLineNo )
    I!.__ThisLineNo = I!.__ThisLineNo + 1
  end /* else */
RETURN

/* ------------------------------------------------------------------ */
/*-function: error handler for user breaks                            */
/*                                                                    */
/*-call:     DO NOT CALL THIS ROUTINE BY HAND!!!                      */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*-Note:     THIS FUNCTION ABORTS THE PROGRAM WITH A JUMP TO THE      */
/*           LABEL I!.__PROGRAMEND IF prog.__UserAbort IS NOT 0!!!    */
/*                                                                    */
/*           In exit routines you may test if the variable            */
/*           prog.__ExitCode is 254 to check if the program           */
/*           was aborted by the user.                                 */
/*                                                                    */
I!.__UserAbort:
  I!.__sSigl = sigl

                        /* reinstall the error handler                */
  CALL ON HALT NAME I!.__UserAbort

                        /* check if user aborts are allowed           */
  if 0 == prog.__UserAbort then
    RETURN              /* CTRL-BREAK not allowed                     */

  I!.__QM = prog.__QuietMode

                        /* turn quiet mode off                        */
  prog.__QuietMode = ''

  call Log

  screen.__CurColor = screen.__ErrorColor
  call I!.__LogSeparator
  call Log left( I!.__GetMsg( 11, I!.__sSigl ), prog.__ScreenCols )
  call I!.__LogSeparator
  screen.__CurColor = screen.__NormalColor

  prog.__ExitCode = 254

                        /* restore quiet mode status                  */
  prog.__QuietMode = I!.__QM

SIGNAL I!.__ProgramEnd

/* ------------------------------------------------------------------ */
/*-function: get a message                                            */
/*                                                                    */
/*-call:     I!.__GetMsg msgNo {,msgP1} {...,msgP9}                   */
/*                                                                    */
/*-returns:  the message or an empty string                           */
/*                                                                    */
/*-note:     This routines calls the external routine which name is   */
/*           saved in the variable 'global.__GetMsg' if this variable */
/*           is not equal ''.                                         */
/*                                                                    */
/*           I!.__GetMsg adds global.__BaseMsgNo to the msgNo.        */
/*                                                                    */
I!.__GetMsg: PROCEDURE expose (exposeList)
  parse arg msgNo, mP1 , mP2 , mP3, mP4, mP5, mP6, mP7, mP8, mP9

  f = 0
  t = ''

  if symbol( 'global.__GetMsg' ) = 'VAR' then
    if global.__GetMsg <> '' then
    do
            /* first check if there's a user defined GetMsg routine   */

                        /* install a local error handler              */
      SIGNAL ON SYNTAX Name I!.__GetMsg1

                    /* try to call the user defined GetMsg routine    */
      interpret 'call ' global.__GetMsg ' msgNo+global.__BaseMsgNo,,' ,
                ' mP1, mP2, mP3, mP4, mP5, mP6, mP7, mP8, mP9 '
      f = 1
    end /* if global.__GetMsg <> '' then */

I!.__GetMsg1:

  if f = 1 then
  do
                        /* user defined GetMsg routine found -- use   */
                        /* the result                                 */
    if symbol( 'RESULT' ) == 'VAR' then
      t = result
  end /* if result = 0 then */
  else
  do
                        /* user defined GetMsg routine not found --   */
                        /* use the hardcoded message strings          */
      msgString =  ,
/* 1001 */      'Routine_"@1"_not_found ',
/* 1002 */      'Can_not_write_to_the_logfile_"@1",_the_status_of_the_logfile_is_"@2"._Now_using_the_NUL_device_for_logging ',
/* 1003 */      'Include_file_"@1"_not_found ' ||,
/* 1004 */      'Unexpected_EOF_detected_while_reading_the_include_file_"@1" ' || ,
/* 1005 */      'Error_loading_the_DLL_"@1" ' ||,
/* 1006 */      'Invalid_call_to_LOADDLL ' ||,
/* 1007 */      '_Warning: ' ||,
/* 1008 */      '_@1_-_Error_@2_detected!_The_error_message_is_ ' ||,
/* 1009 */      '_Calling_the_patched_version_@1_... ' ||,
/* 1010 */      '_..._the_patched_version_endet_with_RC_=_@1 ' ||,
/* 1011 */      '_Program_aborted_by_the_user_(sigl=@1) ' ||,
/* 1012 */      '@1_@2_started_on_@3_at_@4_... ' ||,
/* 1013 */      '@1_@2_ended_on_@3_at_@4_with_RC_=_@5_(=''@6''x) ' || ,
/* 1014 */      '_Usage: '

                    /* get the message and translate all underscores  */
                    /* to blanks                                      */
    t = translate( word( msgString, msgNo ), ' ', '_'  )

                    /* replace place holder                           */
    i = 1
    do until i > 9
     j = pos( '@' || i, t )
     if j <> 0 then
       t = insert( arg( i+1 ), delStr(t, j, 2) , j-1 )
     else
       i = i +1
    end /* do until i > 9 */
  end /* else */
return t

/* ------------------------------------------------------------------ */
/*-function: get the line no of the call statement of this routine    */
/*                                                                    */
/*-call:     GetLineNo                                                */
/*                                                                    */
/*-returns:  the line number                                          */
/*                                                                    */
/*                                                                    */
GetLineNo:
  RETURN sigl

/* ------------------------------------------------------------------ */
/*-function: get the no. of the first line with the user code         */
/*                                                                    */
/*-call:     DO NOT CALL THIS ROUTINE BY HAND!!!                      */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
/*                                                                    */
I!.__GetUserCode:
  I!.__FirstUserCodeLine = GetLineNo()+2
RETURN

/********************** End of Runtime Routines ***********************/
/**********************************************************************/

/***        End of Part 3 of the source code of TEMPLATE.CMD        ***/


/***       Start of Part 4 of the source code of TEMPLATE.CMD       ***/

/* ------------------------------------------------------------------ */
/*-function: main procedure of the program                            */
/*                                                                    */
/*-call:     called by the runtime system with:                       */
/*           => call main parameter_of_the_program <=                 */
/*                                                                    */
/*-returns:  nothing                                                  */
/*                                                                    */
Main: PROCEDURE expose (exposeList)

/* ----------------------------- */
                        /* extend the numeric digits            v1.52 */
  NUMERIC DIGITS 15

/* ----------------------------- */
                        /* turn some error checking off               */
  SIGNAL off ERROR

/* ----------------------------- */

                        /* strings which should not be written into   */
                        /* the log file                               */
  prog.__LogExcludeWords = screen.__fgYellow screen.__highlight ,
                           screen.__fgRed screen.__AttrOff

                        /* get the parameter of the program           */
  parse arg sourceFiles TargetDir templateFile .

                        /* check the parameter                        */
  if sourceFiles = '' then
    sourceFiles = '.\*.SRC'     /* use default value                  */

  curDir = directory()

  if directory( sourceFiles ) <> '' then
    sourceFiles = directory() || '\*.SRC'
  else
    if stream( sourceFiles, 'c', 'QUERY EXIST' ) = '' then
      call ShowError global.__ErrorExitCode ,,
           'No source files found'
    else
      sourceFiles = stream( sourceFiles, 'c', 'QUERY EXIST' )

  if stream( sourceFiles, 'c', 'QUERY EXIST' ) = '' then
    call ShowError global.__ErrorExitCode ,,
         'No source files found'

  sourceDir =  dbrright( fileSpec( "drive", sourceFiles ) || ,
                         fileSpec( "path", sourceFiles ) , 1 )

  if length( sourceDir ) > 3 & right( sourceDir, 1 ) = '\' then
    sourceDir = dbrright( sourceDir, 1 )

  call directory curDir

  if targetDir = '' then
    targetDir = '..'            /* use default value                  */
  else
    if right( targetDir, 1 ) = '\' then
      targetDir = dbrright( targetDir,1 )

  if directory( targetDir ) = '' then
    call ShowError global.__ErrorExitCode ,,
         'The target directory "' || targetDir || '" does not exist'
  else
    targetDir = directory()

  call directory curDir

  if sourceDir = targetDir then
    call ShowError global.__ErrorExitCode ,,
                   'Source directory = target directory is not allowed'

  if templateFile = '' then
    templateFile = '.\TEMPLATE.CMD'     /* use default value          */

  testFile = stream( templateFile, 'c', 'QUERY EXIST' )
  if testFile = '' then
    call ShowError global.__ErrorExitCode ,,
                   'Can not find the template file "' || ,
                   templateFile || '"'

                        /* get the date of the template file          */
  templateDateString = GetDateString( templateFile )

                        /* string with the names of the files to      */
                        /* exclude                                    */
  global.__FilesToExclude = templateFile
  global.__FilesToCopy = ''

  if pos( '*', sourceFiles ) = 0 & pos( '?', sourceFiles ) = 0 then
    oneFileCompile = 1
  else
    oneFileCompile = 0

  if oneFileCompile = 0 then
  do
    call log ' The source directory is '
    call log '  ' || AddColor1( '"', sourceDir )
    call log ' The target directory is '
    call log '  ' || AddColor1( '"', targetDir )
    call log ' Using the template file '
    call log '  ' || AddColor1( '"', templateFile )
  end /* if oneFileCompile = 0 then */

/* ------------------------------ */
                        /* read the ini file if any exist             */
  call ReadIniFile sourceDir

/* ------------------------------ */

  call flushQueue
  prog.__ExitRoutines =  prog.__ExitRoutines || ' flushQueue '

  if oneFileCompile = 0 then
    call log '  Detecting the source files ' || ,
                AddColor1( '"', convertName( SourceFiles ) ) || ' ...'

                        /* put a list of all files in the queue       */
  '@dir /b /A-d ' SourceFiles ' 2>NUL | rxqueue '

  CmdFiles.0 = 0

                        /* put the names of all cmd files to convert  */
                        /* in a stem                                  */
  do while queued() <> 0
    j = CmdFiles.0 + 1
    curCmdFile = strip( translate( lineIn( 'QUEUE:' ) ) )

                        /* check the filename                         */
    if curCmdFile <> '' then
      if pos( curCmdFile, global.__FilesToExclude ) = 0 then
      do
        CmdFiles.j = curCmdFile
        CmdFiles.0 = j
      end /* if  curCmdFile <> ... */
  end /* do while queued <> 0 */

  if CmdFiles.0 = 0 then
    call ShowError global.__ErrorExitCode ,,
                   'No sourcefiles found'

  if oneFileCompile = 0 then
  do
    call log ' ' || AddColor1( , CmdFiles.0 ) || ' files found.'
    call log ' Now checking and creating the target files ...'
  end /* if oneFileCompile = 0 then */

                        /* no of updated files                        */
  CMDFilesUpdated = 0         /* no. of files based on TEMPLATE       */
  CMDFilesCompressed = 0      /* no. of OS/2 cmd files                */
  FilesCopied = 0             /* no. of files copied                  */

                        /* read the template file if neccessary       */
  if ReadTemplateFile( templateFile ) <> 1 then
    call ShowError global.__ErrorExitCode ,,
         'The format of the template file "' || templateFile || '" is invalid'

  do j=1 to CmdFiles.0

    doCompressFile = 0
    doCopyFile = 0
                        /* name of the current file in the source dir */
    curFileName = cmdFiles.j

    sourceFile = sourceDir || '\' || curFileName

                        /* name of the current file without path and  */
                        /* extension                                  */
    if ( right( curFileName, 4) <> '.SRC' & right( curFileName, 4) <> '.CMD' ) |  ,
       pos( curFileName, global.__FilesToCopy ) <> 0 then
    do
      doCopyFile = 1
      targetFile = targetDir || '\' || curFileName
    end /* if right( ... */
    else
    do
      doCopyFile = 0
      targetFile = targetDir || '\' || dbrright( curFileName, 4 ) || '.CMD'
    end /* else */

    parse value stream( sourceFile, 'c' , 'QUERY DATETIME' ) WITH orgDate
    call log '  Checking the file ' || ,
                       AddColor1( '"',  convertName( curFileName ) ) || ,
                       ' (Date: ' || AddColor1( '"', orgDate ) || ') ...'

                    /* check the file format                          */
    firstMacroLine = lineIn( sourceFile )
    call stream sourceFile, 'c', 'CLOSE'

    if left( firstMacroLine, 2 ) <> '/* ' & doCopyFile = 0 then
    do
      DoCompressFile = 1
    end /* if left( ... */

                        /* test the target file                       */
    if stream( targetFile, 'c', 'QUERY EXIST' ) <> '' then
    do
      updateText = screen.__fgRed || screen.__Highlight  || ,
                   'File is out of date. Now updateing the file ...' || ,
                   screen.__AttrOff

      parse value stream( targetFile, 'c', 'QUERY DATETIME' ) WITH comDate

      sourceDateString = GetDateString( sourceFile )
      targetDateString = GetDateString( targetFile )

      if DoCompressFile = 0 & DoCopyFile = 0 then
        fileOutOfDate = ( targetDateString < sourceDateString ) | ,
                        ( targetDateString < templateDateString )
      else
        fileOutOfDate = ( targetDateString < sourceDateString )

    end /* if stream( ... */
    else
    do
      fileOutOfDate = 1

      updateText = screen.__fgRed || screen.__Highlight  || ,
                   'File does not exist. Now creating the file ...' || ,
                   screen.__AttrOff
    end /* else */

    if fileOutOfDate = 1 then
    do

                                  /* delete the old file if it exists   */
      if stream( targetFile, 'c', 'QUERY EXIST' ) <> '' then
      do
        '@attrib -r ' targetFile prog.__LogAll
        '@del ' targetFile prog.__LogAll
        if rc <> 0 then
          call ShowError global.__ErrorExitCode ,,
               'OS Error ' || rc || ' deleting the old file "' || ,
               targetfile || '"'
      end /* if stream( targetFile ... */

      select

        when doCopyFile = 1 then
        do
          call log screen.__fgRed || screen.__highlight || ,
                   '   Copying the file ' || screen.__AttrOff || ,
                   AddColor1( '"', ConvertName( sourceFile ) ) || ,
                   ' ...'
          '@copy ' convertNameToOS( sourceFile ) convertNameToOS( targetFile ) prog.__LogAll
          if rc <> 0 then
            call ShowError global.__ErrorExitCode, ,
                 'Error ' || rc || ' copying the file "' || sourceFile || ,
                 ' to "' || targetFile || '"'
          FilesCopied = FilesCopied + 1
        end /* when doCopyFile = 1 then */

        when doCompressFile = 1 then
        do
          call log '   ' || updateText || '(OS/2 cmd)'
          if CompressTargetFile( sourceFile, targetFile ) <> 1 then
            call ShowError global.__ErrorExitCode ,,
                 'Error creating the targetFile "' || targetFile || '"'

          cmdFilesCompressed = cmdFilesCompressed + 1
        end /* when */

        otherwise
        do
          call log '   ' || updateText

                                /* create the target file             */
          crTargetFileRC = CreateTargetFile( sourceFile , targetFile )

          select

            when crTargetFileRC = 1 then
            do
                        /* create the token image of the target file  */
              '@cmd /c ' targetFile '//t'

/*            '@attrib +r ' targetFile prog.__LogAll */

              CMDFilesUpdated = CMDFilesUpdated + 1
            end /* when */

            when crTargetFileRC = 2 then
            do
              call ShowWarning 'This file is NOT a REXX cmd based on TEMPLATE. File ignored!'
            end /* when */

            otherwise
            do
              call ShowError global.__ErrorExitCode ,,
                   'Error creating the targetFile "' || targetFile || '"'
            end /* otherwise */

          end /* select */
        end /* otherwise */

      end /* select */

    end /* if fileOutOfDate = 1 then */
  end /* do j=1 to CmdFiles.0 */

  if oneFileCompile = 0 then
  do
    call log ' ' || AddColor1( , FilesCopied )        || ' file(s) copied.'
    call log ' ' || AddColor1( , CMDFilesCompressed ) || ' file(s) compressed.'
    call log ' ' || AddColor1( , CMDFilesUpdated )    || ' file(s) updated.'
  end /* if oneFileCompile = 0 then */

  prog.__ExitCode = global.__OKExitCode

/* ------------------------------ */

RETURN

/* ------------------------------------------------------------------ */

/*** INSERT FURTHER SUBROUTINES HERE ***/

/* ------------------------------------------------------------------ */
/* Function: add quote chars and color codes to a string              */
/*                                                                    */
/* call:     AddColor1( quoteChar ,myString )                         */
/*                                                                    */
/* where:    quoteChar - leading and trailing character for the       */
/*                       converted string (may be ommited)            */
/*           myString - string to convert                             */
/*                                                                    */
/* returns:  converted string                                         */
/*                                                                    */
AddColor1: PROCEDURE expose (exposeList)
  parse arg quoteChar, myString

return quoteChar || screen.__fgYellow || screen.__highlight || ,
       myString || ,
       screen.__AttrOff || quoteChar


/* ------------------------------------------------------------------ */
/* function: get the date of a file as string                         */
/*                                                                    */
/* call:     GetDateString thisFile                                   */
/*                                                                    */
/* where:    thisFile - file to get the date of                       */
/*                                                                    */
/* returns:  date of the file (as string) or '' if not detectable     */
/*                                                                    */
GetDateString: PROCEDURE expose (exposeList)
  parse arg thisFile

  fileDate = stream( thisFile, 'c', 'QUERY DATETIME' )
  parse var fileDate thisMonth '-' thisDay '-' thisYear thisHour ':' thisMinute ':' thisSecond
  fileDate = thisYear  || thisMonth || thisDay || thisHour || thisMinute || thisSecond
RETURN fileDate

/* ------------------------------------------------------------------ */
/* function: read an ini file if it exists                            */
/*                                                                    */
/* call:     ReadIniFile iniFileDir                                   */
/*                                                                    */
/* where:    iniFileDir - directory with the inifile                  */
/*                                                                    */
/* returns:  ''                                                       */
/*                                                                    */
ReadIniFile: PROCEDURE expose (exposeList)
  parse arg iniFileDir .

  myInIFile = iniFileDir || '\MAKECMD.INI'

  if stream( myIniFile, 'c', 'QUERY EXIST') <> '' then
  do
    call log ' Reading the ini file '
    call log '  ' || AddColor1( '"', myIniFile )

    do curLineNo = 1 while lines( myIniFile ) <> 0
      curLine = translate( strip( lineIn( myIniFile ) ) )
      if curLine = '' | left( curLine,1 ) = ';' then
        iterate

      parse upper var curLine curKeyWord ':' curKeyValue
      curKeyWord = strip( curKeyWord )

      select
        when curKeyWord = 'COPY' then
          global.__FilesToCopy = global.__FilesToCopy curKeyValue
        when curKeyWord = 'EXCLUDE' then
          global.__FilesToExclude = global.__FilesToExclude curKeyValue
        otherwise
          call ShowError global.__errorExitCode ,,
               'The line ' || curLineNo || ' of the file MAKECMD.INI is invalid'
      end /* select */
    end /* do while lines( myIniFile ) <> 0 */

                        /* close the ini file                         */
    call stream myIniFile, 'c', 'CLOSE'
  end /* if stream( ... */
RETURN ''

/* ------------------------------------------------------------------ */
/* function: convert the file/dirname for a message                   */
/*                                                                    */
/* call:     ConvertName name                                         */
/*                                                                    */
/* where:    name - name of the file or directory                     */
/*                                                                    */
/* returns:  converted file or directory name                         */
/*                                                                    */
ConvertName: PROCEDURE expose (exposeList)
  parse arg thisName
  thisName = strip( thisName )
  i = length( thisName )
  if i > 30 then
  do
    thisName = substr( thisName, i - 27 )
    i = pos( '\', thisName )
    if i <> 0 then
      thisName = substr( thisName, i+1 )
    thisName = '...' || thisName
  end /* if i > 30 then */
RETURN thisName

/* ------------------------------------------------------------------ */
/*-function: read the template file                                   */
/*                                                                    */
/*-call:     ReadTemplateFile templateFile                            */
/*                                                                    */
/*-where:    templateFile - fully qualified name of the source file   */
/*                                                                    */
/*-returns:  1 - okay                                                 */
/*           0 - error reading the template file                      */
/*                                                                    */
/*-output:   global.__template - runtime system for the REXX programs */
/*                                                                    */
ReadTemplateFile: PROCEDURE expose (exposeList)
  parse arg templateFile .

  thisRC = 0
                        /* read the source file                       */
  call stream templateFile, 'c', 'OPEN READ'
  i0 = chars( templateFile )
  tempFile = charIn( templateFile, 1, i0 )
  call stream templateFile, 'c', 'CLOSE'

  if i0 <> 0 then
  do
    i1 = pos( 'End ' || 'of' || ' Part 1', tempFile )
    if i1 <> 0 then
    do
      i1 = pos( '***' || '/', tempFile, i1 ) +4

      i2 = pos( 'End ' || 'of' || ' Part 3', tempFile )
      if i2 <> 0 then
      do
        i2 = pos( '***' || '/', tempFile, i2 ) +5

        i3 = pos( '/* Based on TEMPLATE.CMD', tempFile )
        if i3 <> 0 then
        do
          i4 = pos( '*/', tempFile, i3 )
          if i1 <> 0 & i2 <> 0 & i3 <> 0 & i4 <> 0 then
          do
            global.__TemplateVersionLine = substr( tempFile, i3, i4-i3+2 )

            global.__template = substr( tempFile, i1, i2-i1+1 )

            thisRC = 1
          end /* if i1 <> 0 ... */
        end /* if i3 <> 0 then */
      end /* if i2 <> 0 then */
    end /* if i1 <> 0 then */
  end /* if i0 <> 0 then */

RETURN thisRC

/* ------------------------------------------------------------------ */
/*-function: CompressTargetFile                                       */
/*                                                                    */
/*-call:     CompressTargetFile sourceFile targetFile                 */
/*                                                                    */
/*-where:    sourceFile - fully qualified name of the source file     */
/*           targetFile - fully qualified name of the target file     */
/*                                                                    */
/*-returns:  1 - target file created                                  */
/*           0 - error creating the targetfile                        */
/*                                                                    */
/*                                                                    */
CompressTargetFile: PROCEDURE expose (exposeList)
  parse arg sourceFile , targetFile .
  thisRC = 0

  do while lines( sourceFile ) <> 0
    curLine = strip( lineIn( sourceFile ) )

                        /* ignore empty lines                         */
    if curLine = '' then
      iterate

                        /* ignore comment lines                       */
    if left( curLine, 4 ) = 'REM ' then
      iterate
                        /* write the line to the target file          */
    call LineOut targetFile, curLine

  end /* do while lines( sourceFile ) <> 0 */

                        /* close the source and target files          */
  call stream sourceFile, 'c', 'CLOSE'
  call stream targetFile, 'c', 'CLOSE'
  thisRC = 1
RETURN thisRC

/* ------------------------------------------------------------------ */
/*-function: CreateTargetFile                                         */
/*                                                                    */
/*-call:     CreateTargetFile sourceFile , targetFile                 */
/*                                                                    */
/*-where:    sourceFile - fully qualified name of the source file     */
/*           targetFile - fully qualified name of the target file     */
/*                                                                    */
/*-returns:  1 - target file created                                  */
/*           2 - file is not a REXX cmd based on TEMPLATE             */
/*           0 - error creating the targetfile                        */
/*                                                                    */
/*                                                                    */
CreateTargetFile: PROCEDURE expose (exposeList)
  parse arg sourceFile , targetFile .
  thisRC = 0

  call stream sourceFile, 'c', 'OPEN READ'
  i0 = chars( sourceFile )
  tempFile = charIn( sourceFile, 1, i0 )
  call stream sourceFile, 'c', 'CLOSE'

  if i0 <> 0 then
  do
    thisRC = 2

    i1 = pos( 'End ' || 'of' || ' Part 1', tempFile )
    if i1 <> 0 then
    do
      i1 = pos( '***' || '/', tempFile, i1 ) +6

      i2 = pos( 'End ' || 'of' || ' Part 3', tempFile )
      if i2 <> 0 then
        i2 = pos( '***' || '/', tempFile, i2 ) +6
      else
        i2 = i1

      i3 = pos( '/' || '* Based on TEMPLATE.CMD', tempFile )
      if i3 <> 0 then
      do
        if i1 <> 0 & i2 <> 0 then
        do
          tempFile = overlay( global.__TemplateVersionLine, tempFile, i3 )

                        /* write the first part of the targetfile     */
          thisRC = charOut( targetFile, substr( tempFile, 1, i1 ) )

                        /* write the second part of the targetfile    */
          if thisRC = 0 then
            thisRC = CharOut( targetFile, global.__template )

                        /* write the third part of the targetfile     */
          if thisRC = 0 then
            thisRC =  CharOut( targetFile, substr( tempFile, i2 ) )

          call stream targetFile, 'c', 'CLOSE'

          if thisRC = 0 then
            thisRC = 1
          else
            thisRC = 0
        end /* if i1 <> 0 & i2 <> 0 then */
      end /* if i3 <> 0 then */
    end /* if i1 <> 0 then */
  end /* if i0 <> 0 then */

RETURN thisRC

/* ------------------------------------------------------------------ */
/*-function: Show the invocation syntax                               */
/*                                                                    */
/*-call:     called by the runtime system with                        */
/*           => call ShowUsage <=                                     */
/*                                                                    */
/*-where:    -                                                        */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
/*                                                                    */
ShowUsage:
  call ShowString 'Usage: ', 'MakeCmd {sourceFiles} {targetDir} {templateFile}' ,
                             prog.__DefParms

RETURN ''

/***        End of Part 4 of the source code of TEMPLATE.CMD        ***/

/**********************************************************************/   


