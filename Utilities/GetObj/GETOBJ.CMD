/* ------------------------------------------------------------------ */
/* GETOBJ.CMD - create a list of all WPS objects                      */
/*                                                                    */
/* (c) Copyright Bernd Schemmer 1994 - 1997                           */
/*                                                                    */
/* Author                                                             */
/*   Bernd Schemmer                                                   */
/*   Baeckerweg 48                                                    */
/*   D-60316 Frankfurt am Main                                        */
/*   Germany                                                          */
/*   Compuserve: 100104,613                                           */
/*                                                                    */
/* Description                                                        */
/*   GETOBJ creates a list containing the data for all objects in a   */
/*   folder (and it's sub folder). For each object the title, the     */
/*   class, the setup string and the location is shown.               */
/*   GETOBJ can also create a REXX program with SysCreateObject calls */
/*   to recreate the objects.                                         */
/*                                                                    */
/* Limitations                                                        */
/*   GETOBJ "knows" only the settings known by the current version of */
/*   the DLL WPTOOLS.DLL. So, before using this program you should    */
/*   carefully read the documentation for the DLL WPTOOLS.DLL in the  */
/*   file WPTOOLS.TXT!                                                */
/*                                                                    */
/*                          IMPORTANT                                 */
/*                                                                    */
/*   If you use GETOBJ to create a REXX program to recreate the       */
/*   objects you MUST manually check the created REXX program before  */
/*   using it!!!                                                      */
/*   The REXX program created by GETOBJ creates the objects in the    */
/*   following order:                                                 */
/*     1. the folders & sub folders                                   */
/*     2. the objects                                                 */
/*   and                                                              */
/*     3. the shadows.                                                */
/*                                                                    */
/*   GETOBJ won't check further dependencies! GETOBJ also won't       */
/*   insert code to register the WPS classes possibly necessary       */
/*   for the objects into the created REXX program!                   */
/*                                                                    */
/*   GETOBJ IS NOT INTENDED TO SAVE OR RESTORE YOUR DESKTOP!!!        */
/*                                                                    */
/* History                                                            */
/*   28.04.1995 /bs v1.00                                             */
/*     - initial release                                              */
/*   10.07.1995 /bs v1.10                                             */
/*     - now you can also use single quotes around the starting       */
/*       folder                                                       */
/*     - added code to check the object definitions for the created   */
/*       REXX program                                                 */
/*   25.01.1997 /bs v1.11                                             */
/*     - corrected some bugs                                          */
/*     - added a work around for a bug in the lineout function in     */
/*       Object REXX                                                  */
/*     - replaced WPTOOLS.DLL with the new DLL necessary for WARP 4   */
/*       (from WPTOOLS v1.9)                                          */
/*                                                                    */
/* Notes                                                              */
/*   This program needs the OS/2 DLL REXXUTIL.                        */
/*   This program also needs Henk Kelders famous DLL WPTOOLS.DLL      */
/*   (included in this package).                                      */
/*   THESE DLLs MUST BE IN A DIRECTORY IN THE LIBPATH OR IN THE       */
/*   CURRENT DIRECTORY!!!                                             */
/*                                                                    */
/* Credits                                                            */
/*   The procedure to detect the desktop directory                    */
/*    "GetDesktopDirectory"                                           */
/*   was written by                                                   */
/*     Georg Haschek (haschek at vnet.ibm.com).                       */
/*   The SHELL sort routine                                           */
/*      "ShellSort"                                                   */
/*   was written by                                                   */
/*     Steve Pitts (CompuServe: 100331,1134).                         */
/*   Thanks to both.                                                  */
/*                                                                    */
/*   The DLL WPTOOLS.DLL needed by this program is from               */
/*     Henk Kelder (CompuServe: 100321,3650                           */
/*                  Fido: 2:280/801.339@fidonet.org)                  */
/*   Thanks to him for the permission to distribute WPTOOLS.DLL with  */
/*   this program.                                                    */
/*                                                                    */
/*   Also thanks to all, who send me hints & bug reports for GETOBJ.  */
/*                                                                    */
/* Usage                                                              */
/*   GETOBJ {!|{!}startFolder} {/L:logfile}                           */
/*          {/REXX=file} {/NOREXX}                                    */
/*          {/STAT} {/NOSTAT}                                         */
/*          {/LIST} {/NOLIST}                                         */
/*          {/H} {/Silent} {/NoSound} {/NoAnsi}                       */
/*                                                                    */
/* where:                                                             */
/*   startFolder - fully qualified name of the start folder           */
/*                 If the name of the folder is preceeded with a '!'  */
/*                 GETOBJ won't process the sub folders.              */
/*                 The default start folder is the desktop folder.    */
/*                 Note:                                              */
/*                 Enclose the foldername with single or double       */
/*                 quotes if it contains blanks or special chars.     */
/*                                                                    */
/*   !           - process the desktop folder without sub folders     */
/*                                                                    */
/*   /L:logFile - logfile is the name of the logfile :-)              */
/*                This parameter is case-sensitive!                   */
/*                default: do not use a logfile                       */
/*                                                                    */
/* /REXX{=file} - create a REXX program to reCreate the objects.      */
/*                File is the fully qualified name for the REXX       */
/*                program (def.: CROBJ.CMD in the current directory). */
/*                If the file already exists, GETOBJ creates a backup */
/*                before rewriting it.                                */
/*                This Parameter suppresses the creation of an object */
/*                list and the statistics. To create the REXX program */
/*                AND the object list and/or the statistics use the   */
/*                the parameter in the following sequence:            */
/*                /REXX{=file} /LIST /STAT                            */
/*   /NOREXX    - do not create a REXX program (default)              */
/*                                                                    */
/*   /LIST      - create an object list and write it to the screen.   */
/*                (Default)                                           */
/*                Use the parameter /L:logfile to redirect the list   */
/*                to a file.                                          */
/*                                                                    */
/*   /NOLIST    - do not create an object list.                       */
/*                                                                    */
/*   /STAT      - create the statistics and write them to the screen. */
/*                (Default)                                           */
/*                Use the parameter /L:logfile to redirect the        */
/*                statistics to a file.                               */
/*                                                                    */
/*   /NOLIST    - do not create the statistics.                       */
/*                                                                    */
/*   /H         - show usage, you may also use                        */
/*                /h, /?, /HELP, -h, -H, -HELP or -?                  */
/*                                                                    */
/*   /Silent    - suppress all messages (except error messages)       */
/*                You should also use the parameter /L:logfile if you */
/*                use this parameter!                                 */
/*                You may also set the environment variable SILENT to */
/*                "1" to suppress all messages.                       */
/*                                                                    */
/*   /NoSound   - suppress all sounds. You may also set the           */
/*                environment variable SOUND to "0" to suppress the   */
/*                sounds.                                             */
/*                                                                    */
/*   /NoAnsi    - do not use ANSI codes. You may also set the         */
/*                environment variable ANSI to "0" to suppress the    */
/*                use of ANSI codes.                                  */
/*                                                                    */
/* Note:                                                              */
/*   You must use at least one blank to separate the parameter.       */
/*                                                                    */
/* examples:                                                          */
/*                                                                    */
/*   GETOBJ /L:C:\DESKTOP.LST                                         */
/*     - write a list of all objects on your desktop and in the sub   */
/*       folders of the desktop to the file C:\DESKTOP.LST            */
/*                                                                    */
/*   GETOBJ ! /L:C:\DESKTOP.LST                                       */
/*     - write a list of all objects on the desktop to the file       */
/*       C:\DESKTOP.LST. Do not process the sub folders.              */
/*                                                                    */
/*   GETOBJ "C:\DESKTOP\My Folder" /L:C:\MyFolder.LST                 */
/*     - write a list of all objects in the folder C:\DESKTOP\SYSTEM  */
/*       and in the sub folders of ths folders to the file            */
/*       C:\SYSTEM.LST.                                               */
/*                                                                    */
/*   GETOBJ "!C:\DESKTOP\My Folder" /L:C:\MyFolder.LST                */
/*     - write a list of all objects in the folder C:\DESKTOP\SYSTEM  */
/*       to the file C:\SYSTEM.LST. Do not process sub folders.       */
/*                                                                    */
/*                                                                    */
/* Distribution                                                       */
/*   This version of GETOBJ is Freeware. You can use and share it as  */
/*   long as you neither delete nor change any file or program in the */
/*   archiv!                                                          */
/*   Please direct your inquiries, complaints, suggestions, bug lists */
/*   etc. to the address noted above.                                 */
/*                                                                    */
/*   Contact Henk Kelder if you want to distribute the DLL            */
/*   WPTOOLS.DLL with your program.                                   */
/*                                                                    */ 
/*                                                                    */
/*                                                                    */
/* Based on TEMPLATE.CMD v3.05, TEMPLATE is (c) 1996 Bernd Schemmer,  */
/* Baeckerweg 48, D-60316 Frankfurt, Germany, Compuserve: 100104,613  */
/*                                                                    */
/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
/*** change the following values to your need                       ***/

                  global. = ''  /* init the stem global. with ''      */

         global.__Version = '1.11'      /* Version of YOUR program    */

       global.__SignOnMsg = 1   /* set to 0 if you do not want the    */
                                /* program start and end messages     */

         global.__NeedCID = 0   /* set to 1 if you need CID support   */

      global.__NeedColors = 1   /* set to 1 if you want colored msgs  */

  global.__NeedPatchCheck = 0   /* set to 1 if you want the program   */
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
/* check if there is a patched version of this program                */

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

                        /* use the return code of 'main' as exitcode  */
                        /* if a returncode was returned               */
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
  if global.__SignOnMsg <> 1 then
    RETURN

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

  if I!.__ThisRC = 0 then
  do
    if I!.__ErrorAction = 2 then
      call ShowError global.__ErrorExitCode , ,
                   I!.__GetMsg( 1, I!.__ProcN )

    if I!.__ErrorAction = 1 then
      call ShowWarning I!.__GetMsg( 1 , I!.__ProcN )
  end /* if I!.__thisRC = 0 then */

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
/*            by adding a leading and trailing double quote           */
/*                                                                    */
/*-call:      convertNameToOS dir_or_file_name                        */
/*                                                                    */
/*-where:     dir_or_file_name = name to convert                      */
/*                                                                    */
/*-returns:   converted file or directory name                        */
/*                                                                    */
ConvertNameToOS: PROCEDURE expose (exposeList)
  parse arg fn
RETURN '"' || fn || '"'                                      /* v3.06 */

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

    t1 = 'SAVEPOS RESTPOS ATTROFF' ,                         /* v3.05 */
         'HIGHLIGHT NORMAL BLINK INVERS INVISIBLE'           /* v3.05 */

    t2 = 's u 0;m 1;m 2;m 5;m 7;m 8;m'                       /* v3.05 */

    screen.__DELEOL = escC || 'K'                            /* v3.05 */

    do i = 1 to 8                                            /* v3.05 */

      call value 'SCREEN.__' || word( t1, i ) ,,             /* v3.05 */
                 escC || word( t2,i )                        /* v3.05 */

                                                             /* v3.05 */
      s = word( 'BLACK RED GREEN YELLOW BLUE MAGNENTA CYAN WHITE', i )
      call value 'SCREEN.__FG' || s,,                        /* v3.05 */
                 escC || 29+i || ';m'                        /* v3.05 */
      call value 'SCREEN.__BG' || s,,                        /* v3.05 */
                 escC || 39+i || ';m'                        /* v3.05 */
    end /* do i = 1 to 8 */                                  /* v3.05 */

    drop t1 t2 s i                                           /* v3.05 */

/* --------------------------- */
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

                        /* get drive, path and name of this program   */
  parse upper source . . prog.__FullName
        prog.__Drive = filespec( 'D', prog.__FullName )
         prog.__Path = filespec( 'P',  prog.__FullName )
         prog.__Name = filespec( 'N',  prog.__FullName )

                                                             /* v3.05 */
 parse upper value 'V3.06 1 80 25 OS2ENVIRONMENT' directory() with ,
             prog.__Version ,         /* version of template    v3.05 */
             prog.__UserAbort ,       /* allow useraborts       v3.05 */
             prog.__ScreenCols ,      /* def. screen cols       v3.05 */
             prog.__ScreenRows ,      /* def. screen rows       v3.05 */
             prog.__env ,             /* def. environment       v3.05 */
             prog.__CurDir            /* current directory      v3.05 */

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

    I!.__cidRCValues = ,                                     /* v3.05 */
      '0000'x 'SUCCESSFUL_PROGRAM_TERMINATION',              /* v3.05 */
      '0004'x 'SUCCESSFUL_LOG_WARNING_MESSAGE',              /* v3.05 */
      '0008'x 'SUCCESSFUL_LOG_ERROR_MESSAGE',                /* v3.05 */
      '0012'x 'SUCCESSFUL_LOG_SEVERE_ERROR',                 /* v3.05 */
      '0800'x 'DATA_RESOURCE_NOT_FOUND',                     /* v3.05 */
      '0804'x 'DATA_RESOURCE_ALREADY_IN_USE',                /* v3.05 */
      '0808'x 'DATA_RESOURCE_NOAUTHORIZATION',               /* v3.05 */
      '0812'x 'DATA_PATH_NOT_FOUND',                         /* v3.05 */
      '0816'x 'PRODUCT_NOT_CONFIGURED',                      /* v3.05 */
      '1200'x 'STORAGE_MEDIUM_EXCEPTION',                    /* v3.05 */
      '1204'x 'DEVICE_NOT_READY',                            /* v3.05 */
      '1208'x 'NOT_ENOUGH_DISKSPACE',                        /* v3.05 */
      '1600'x 'INCORRECT_PROGRAM_INVOCATION',                /* v3.05 */
      '1604'x 'UNEXPECTED_CONDITION',                        /* v3.05 */
      'FE00'x 'SUCCESSFULL_REBOOT',                          /* v3.05 */
      'FE04'x 'SUCCESSFULL_REBOOT_WITH_WARNING',             /* v3.05 */
      'FE08'x 'SUCCESSFULL_REBOOT_WITH_ERRMSG',              /* v3.05 */
      'FE12'x 'SUCCESSFULL_REBOOT_WITH_SERVER_ERRMSG',       /* v3.05 */
                                                             /* v3.05 */
    do i = 1 to words( I!.__cidRCValues ) by 2               /* v3.05 */
      call value 'CIDRC.__' || word( I!.__cidRCValues,i+1 ),,
                 c2d( word( I!.__cidRCValues,i ),2 )         /* v3.05 */
                                                             /* v3.05 */
    end /* do i = 1 to words( I!.__cidRCValues ) by 2 */     /* v3.05 */
                                                             /* v3.05 */
    drop I!.__cidRCValues                                    /* v3.05 */


                        /* xx = next state of the program             */
/*    CIDRC.__successfull_reboot_with_callback = C2D('FFxx'x, 2);     */

                        /* define exit code values                    */
    global.__ErrorExitCode = CIDRC.__unexpected_condition
       global.__OKExitCode = CIDRC.__successful_program_termination

                        /* add the stem CIDRC. to the exposeList      */
    exposeList = exposeList 'CIDRC. '
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
/* 1001 */      'Routine_"@1"_not_found',
/* 1002 */      'Can_not_write_to_the_logfile_"@1",_the_status_of_the_logfile_is_"@2"._Now_using_the_NUL_device_for_logging',
/* 1003 */      'Include_file_"@1"_not_found' ,
/* 1004 */      'Unexpected_EOF_detected_while_reading_the_include_file_"@1"' ,
/* 1005 */      'Error_loading_the_DLL_"@1"' ,
/* 1006 */      'Invalid_call_to_LOADDLL' ,
/* 1007 */      '_Warning:' ,
/* 1008 */      '_@1_-_Error_@2_detected!_The_error_message_is_',
/* 1009 */      '_Calling_the_patched_version_@1_...' ,
/* 1010 */      '_..._the_patched_version_endet_with_RC_=_@1' ,
/* 1011 */      '_Program_aborted_by_the_user_(sigl=@1)' ,
/* 1012 */      '@1_@2_started_on_@3_at_@4_...' ,
/* 1013 */      '@1_@2_ended_on_@3_at_@4_with_RC_=_@5_(=''@6''x)' ,
/* 1014 */      '_Usage:'

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
/*-returns:  program return code                                      */
/*           If no return code is returned, the value of the variable */
/*           prog.__ExitCode is returned to the calling program.      */
/*                                                                    */
Main: PROCEDURE expose (exposeList)
                        /* get the parameter of the program           */
  parse arg thisArgs

/* ------------------------------ */
                        /* strings which should not be written in the */
                        /* log file                                   */
  prog.__LogExcludeWords = screen.__fgYellow screen.__highlight ,
                           screen.__AttrOff

/* ------------------------------ */
                        /* load the dll REXXUTIL                      */
  global.__rexxUtilLoaded = LoadDll(,
     'SysLoadFuncs', ,  /* dll init function                          */
     'REXXUTIL',     ,  /* dll name                                   */
     'SysLoadFuncs', ,  /* dll init entry point                       */
     'SysDropFuncs', ,  /* dll exit function                          */
     'SysDropFuncs', ,  /* check function                             */
     1,              ,  /* 1: ignore rc of rxfuncadd                  */
     '',             ,  /* errorcode of the init function             */
     1 )                /* 1: abort if loading failed                 */
                        /* 0: do not abort if loading failed          */

                        /* load the dll WPTOOLS                       */
  global.__wptoolsLoaded = LoadDll(,
     'WPToolsLoadFuncs', ,  /* dll init function                      */
     'WPTOOLS',          ,  /* dll name                               */
     'WPToolsLoadFuncs', ,  /* dll init entry point                   */
     '',                 ,  /* dll exit function                      */
     'WPToolsQueryObject',, /* check function                         */
     1,                  ,  /* 1: ignore rc of rxfuncadd              */
     '',                 ,  /* errorcode of the init function         */
     1 )                    /* 1: abort if loading failed             */
                            /* 0: do not abort if loading failed      */

                            /* deRegister the DLL at program end      */
  prog.__ExitRoutines = prog.__ExitRoutines ' DeRegisterWPTools '

/* ------------------------------ */

                            /* get the real screen size               */
  parse value SysTextScreenSize() with prog.__screenRows prog.__ScreenCols

/* ------------------------------ */
                            /* add the necessary stems to the         */
                            /* expose list                            */
  exposeList = exposeList ' objectStem. objectCountStem. ' ,
                          ' statistics. progTypes. SetupStrStem. ' ,
                          ' classList. '

  objectStem. = ''          /* stem with the object data              */
  objectStem.0 = 0          /* no. of objects found                   */


  objectCountStem. = 0      /* stem with the object counters          */

                            /* variable with the class names          */
  objectCountStem.__ClassNames = ''

  progTypes. = 0            /* stem with the progtype counters        */

                            /* variable with the progtype names       */
  progTypes.__UsedTypes = ''


  statistics. = 0           /* stem for the statistic data            */

                            /* default name for the REXX program to   */
                            /* reCreate the objects                   */
  defREXXProgram = directory() || '\crobj.cmd'

                            /* current name for the REXX program to   */
                            /* reCreate the objects                   */
  curREXXProgram = defREXXProgram

  processSubFolders = 1     /* 1 : process sub folders                */
                            /* else: do not process sub folders       */

  global.__ShowList = 1         /* 1 : show the object list           */
  global.__ShowStatistics = 1   /* 1 : show the statistics            */
  global.__CreateREXXProg = 0   /* 1 : create the REXX program        */

/* ------------------------------ */
                            /* check the parameter                    */

  parameterError = 0        /* 1: error in the parameter              */

  startFolder = ''

                            /* check for quotes or double quotes      */
                            /* around the parameter                   */
  quoteChar = '"'
  i = pos( quoteChar , thisArgs )
  if i = 0 then
  do
    quoteChar = "'"
    i = pos( quoteChar, thisArgs ) 
  end /* if i = 0 then */
             
  if i <> 0 then
  do
                        /* There _are_ quotes or double quotes around */
                        /* the parameter                              */
    i1 = pos( quoteChar, thisArgs, i+1)
    parse var thisArgs part1 (quoteChar) startFolder (quoteChar) part2

    if startFolder = '' | i1 = 0 then
      call ShowError global.__ErrorExitCode ,,
           'Invalid parameter found. Use /H for help'
    else
      startFolder = quoteChar || startFolder || quoteChar

    thisArgs = part1 part2
    drop part1 part2
  end /* if i <> 0 then */

                            /* process the parameter                  */
  do i = 1 to words( thisArgs ) while parameterError = 0
    curParm = translate( word( thisArgs, i ) )
    if left( curParm, 1 ) = '/' then
    do
      curSwitch = substr( curParm,2 )

      select
        when curSwitch = 'STAT' then
          global.__ShowStatistics = 1

        when curSwitch = 'NOSTAT' then
          global.__ShowStatistics = 0

        when curSwitch = 'LIST' then
          global.__ShowList = 1

        when curSwitch = 'NOLIST' then
          global.__ShowList = 0

        when curSwitch = 'NOREXX' then
          global.__CreateREXXProg = 0

        when left( curSwitch,4 ) = 'REXX' then
        do
          global.__CreateREXXProg = 1
          global.__ShowList = 0
          global.__ShowStatistics = 0
          
          testStr = substr( curSwitch, 5 )

          if testStr <> '' then          
            if left( testStr, 1,1 ) = '=' then
              curREXXProgram = substr( testStr,2 ) 
            else
              parameterError = 1
            
          if curREXXProgram = '' then
            parameterError = 1
          else
            if fileSpec('P', curREXXProgram ) = '' then
              curREXXProgram = directory() || '\' || curREXXProgram
        end /* when left( ... */

        otherwise
          parameterError = 1

      end /* select */
    end /* if left( curParm, 1 ) = '/' then */
    else
    do
      if startFolder <> '' then
        call ShowError global.__ErrorExitCode,,
             'Duplicate foldernames are not possible (' ||,
             curParm || ')'
      else
        startFolder = curParm
    end /* else */
  end /* do i = 1 to words( thisArgs ) while ... */

  if parameterError = 1 then
    call ShowError global.__ErrorExitCode ,,
         'Invalid parameter found (' || curParm || ')'

  startFolder = strip( strip( startFolder ,'B' , quoteChar ) )

  if left( startFolder, 1 ) = '!' then
  do
                        /* startup folder is preceded with a '!' --   */
                        /* do not process sub folders                 */
    processSubFolders = 0
    startFolder = substr( startFolder,2 )
  end /* if left( startFolder,1 ) = '!' then */

  if startFolder = '' then
  do
                            /* no startup folder entered --           */
                            /* use the desktop folder as startup      */
                            /* folder                                 */
    startFolder = GetDesktopDirectory()
    if startFolder = '' then
      call ShowError 2,,
           'Can not find the desktop directory!'
  end /* if startFolder = '' then */

  if right( startFolder, 1 ) = '\' then
    startFolder = dbrright( startFolder,1 )

                            /* check if the startup folder exist      */
  if directory( startFolder ) = '' then
    call ShowError 1,,
          'Can not find the folder "' || startFolder || '"'

                            /* restore the working directory          */
  call directory prog.__curDir

/* ------------------------------ */

                        /* force the saving of the base folder object */
  global.__OS2Ver = SysOS2Ver()
  parse var global.__OS2Ver main '.' min
  if main || min >= 230 then
  do
                        /* this function is only possible for         */
                        /* OS/2 v3.0 and above                        */
    call SysSaveObject startFolder,0
  end /* if main || min >= 230 then */

/* ------------------------------ */
                        /* init the folder structure                  */

						/* Note:                                      */
                        /* We don't use a recurisve algorithm,        */
                        /* becauste the maximum depth of nested       */
                        /* control structs in REXX is limited to 100. */
  folderStruc.0 = 1
  folderStruc.1 = startFolder

  if processSubFolders = 1 then
  do
    if prog.__QuietMode <> 1 then
      call CharOut prog.__STDOUT, ' Detecting the folder structure ... '

                        /* get the folder structure                   */
    rc = SysFileTree( startFolder || '\*.*', 'key.', 'DSO' )
    if rc <> 0 then
      call ShowWarning ,
        'Error ' || rc || ' detecting the subfolder(s) in the folder "' || ,
        startFolder || '"'
    else
    do
    if prog.__QuietMode <> 1 then
      call LineOut prog.__STDOUT, 'done. ' || ,
                   AddColor1( , key.0 ) || ,
                   ' folder(s) found.'

                        /* prepare the arrays for the shell sort      */
      do i = 1 to key.0
        ind.i = i
      end /* do i = 1 to key.0 */

                        /* sort the sub folders                       */
      call ShellSort 2, key.0

                        /* add the sub folders to the folder stem     */
      j = folderStruc.0
      do i = 1 to key.0
        j = j + 1
        FolderStruc.j = value( 'key.' || ind.i )
      end /* do i = 1 to key.0 */
      folderStruc.0 = j

    end /* else */
  end /* if processSubFolders = 1 then */


                        /* get the object data                        */
  if prog.__QuietMode <> 1 then
    call CharOut prog.__STDOUT, ' Detecting the object data ...'

  do i = 1 to folderStruc.0
    call ProcessFolder '"' || folderStruc.i || '"' , \processSubFolders
  end /* do i = 1 to folderStruc.0 */

  if prog.__QuietMode <> 1 then
    call LineOut prog.__STDOUT, 'done. ' || ,
         AddColor1( , objectStem.0 ) || ,
         ' object(s) found.'

  if objectStem.0 <> 0 then
  do
                        /* show the object data                       */
    if global.__ShowList = 1 then
      call ShowObjectData

                        /* show the statistic data                    */
    if global.__ShowStatistics = 1 then
      call ShowStatisticData

                        /* create the REXX program to reCreate the    */
                        /* objects                                    */
    if global.__CreateREXXProg = 1 then
      call CreateREXXProgram curREXXProgram

    call log ''
  end /* if objectStem.0 <> 0 then */

/* ------------------------------ */

                        /* exit the program                           */
  prog.__ExitCode = 0

RETURN prog.__ExitCode

/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
/* function: CreateREXXProgram                                        */
/*                                                                    */
/* call:     CreateREXXProgram fileName                               */
/*                                                                    */
/* where:    fileName - fully qualified name for the REXX program     */
/*                                                                    */
/* returns:  1 - okay                                                 */
/*           else error                                               */
/*                                                                    */
/*                                                                    */
CreateREXXProgram: PROCEDURE expose (exposeList) startFolder
  parse arg outputFile

                        /* init the return code                       */
  thisRC = 1

  crLF = '0D0A'x
  
  if prog.__QuietMode <> 1 then
    call CharOut prog.__STDOUT ,,
             ' Creating the REXX program ' || crLF || ,
             '     ' || AddColor1( '"', outputFile ) || crLF  || ,
             ' to recreate the objects ...'

                        /* check if the REXX program already exist    */
  if stream( outputFile, 'c', 'QUERY EXIST' ) <> '' then
  do
                        /* create a backup of the existing program    */
    call CreateBackupFile outputFile

                        /* delete the existing program                */
    '@del ' outputFile '2>NUL 1>NUL'
    if rc <> 0 then
      call ShowError 3,,
           'OS Error ' || rc || ' deleting the file "' || outputFile || '"'
  end /* if stream( ... */

                        /* write the header for the REXX program      */
  call LineOut outputFile ,,
   '/* ------------------------------------------------------------------ */' crLF ||,
   '/* REXX program to recreate the objects from the folder               */' crLF ||,
   '/* ' || left( startFolder, 66 ) ||                                  ' */' crLF ||,
   '/* ' || left( 'Created on ' || date() || ,
                  ' at ' || time() || ,
                  ' with ' || prog.__Name || ,
                  ' v'  || global.__Version , 66 ) ||                   ' */' crLF ||,
   '/* ' || left( 'This files contains the data for ' || ,
                  objectStem.0 || ' objects.', 66 ) ||                  ' */' crLF ||,
   '/*                                                                    */' crLF ||,
   '/* ' || left( 'Usage: ' || fileSpec( 'N', outputFile ) , 66 ) ||    ' */' crLF ||,
   '/*                                                                    */' crLF ||,
   '/* ------------------------------------------------------------------ */' crLF ||,
   '                                                                        ' crLF ||,
   '                                                                        ' crLF ||,
   '                        /* load the dll REXXUTIL                      */' crLF ||,
   '  call rxFuncAdd "SysLoadFuncs", "REXXUTIL", "SysLoadFuncs"             ' crLF ||,
   '  call SysLoadFuncs                                                     ' crLF ||,
   '                                                                        ' crLF ||,
   '                        /* ask the user if we should continue         */' crLF ||,
   '  say "REXX program to recreate the ' || ,
          objectStem.0 || ,
          ' saved objects from the folder"                                  ' crLF ||,
   '  say "  ' || startFolder ||                                          '"' crLF ||,
   '  say "Saved on ' || date() || ' at ' || time() || ,
        ' with ' || prog.__Name || ' v' || global.__Version ||            '"' crLF ||,
   '  say ""                                                                ' crLF ||,
   '  say "Caution: Check this file carefully before using it!!!"           ' crLF ||,        
   '  say ""                                                                ' crLF ||,
   '  call CharOut , "Press Y to recreate the saved objects ... "           ' crLF ||,
   '  if translate( SysGetKey( "NOECHO" ) ) <> "Y" then exit                ' crLF ||,
   '  say ""                                                                ' crLF ||,
   '                                                                        ' crLF ||,
   '  i = 0                                                                 ' crLF ||,
   '  objects.0 = i                                                         ' crLF ||,
   '                        /* stem elements for the folder               */'

                        /* this variable holds the indices of the     */
                        /* normal objects (no folders and no shadows) */
  objectIndizes = ''

                        /* this variable holds the indices of the     */
                        /* shadow objects                             */
  shadowIndizes = ''

                        /* write the object definitions for the       */
                        /* folder objects and save the indices for    */
                        /* the other objects in the variables         */
                        /* objectIndizes and shadowInidzes            */
  do i = 1 to objectStem.0
    if objectStem.i.__FolderName <> '' then
    do
                        /* this is a folder object                    */
      call WriteObjectData i, outputFile
    end
    else
    do
      if objectStem.i.__class = 'WPShadow' then
        shadowIndizes = shadowIndizes i             /* normal object  */
      else
        objectIndizes = objectIndizes i             /* shadow object  */
    end /* else */
  end /* do k = 1 to objectStem.0 */

  call lineOut outputFile, ''
  call LineOut outputFile , '                        /* stem elements for the objects              */'

                        /* write the object definitions for the       */
                        /* normal objects                             */
  do i = 1 to words( objectIndizes )
    call WriteObjectData word( objectIndizes, i ), outputFile
  end /* do i = 1 to words( objectIndizes ) */

  call lineOut outputFile, ''
  call LineOut outputFile , '                        /* stem elements for the shadows              */'

                        /* write the object definitions for the       */
                        /* shadow objects                             */
  do i = 1 to words( shadowIndizes )
    call WriteObjectData word( shadowIndizes, i ), outputFile
  end /* do i = 1 to words( shadowIndizes )  */

                        /* write the code to recreate the objects     */
  call lineOut OutputFile , ,
   '                                                                        ' crLF ||,
   '  objects.0 = i                                                         ' crLF ||,
   '                                                                        ' crLF ||,
   '                                                                        ' crLF ||,
   '                        /* now create the objects                     */' crLF ||,
   '  errorCounter = 0                                                      ' crLF ||,
   '  okCounter = 0                                                         ' crLF ||,
   '                                                                        ' crLF ||,
   '  do i = 1 to objects.0                                                 ' crLF ||,
   '    say " Creating the object """ || objects.i.__title || """ ..."      ' crLF ||,
   '    if SysCreateObject( objects.i.__class       ,,                      ' crLF ||,
   '                        objects.i.__title       ,,                      ' crLF ||,
   '                        objects.i.__location    ,,                      ' crLF ||,
   '                        objects.i.__setup       ,,                      ' crLF ||,
   '                        "UPDATE" ) <> 1 then                            ' crLF ||,
   '    do                                                                  ' crLF ||,
   '      errorCounter = errorCounter + 1                                   ' crLF ||,
   '      say "  *** Warning: Can not create the object """ || ,            ' crLF ||,
   '          objects.i.__title || """ (Index=" || i || ")!"               ' crLF ||,
   '    end /* if SysCreateObject( ... */                                   ' crLF ||,
   '    else                                                                ' crLF ||,
   '      okCounter = okCounter + 1                                         ' crLF ||,
   '  end /* do i = 1 to objects.0 */                                       ' crLF ||,
   '                                                                        ' crLF ||,
   '  say okCounter || " object(s) created, " || ,                          ' crLF ||,
   '      errorCounter || " object creation(s) failed."                     ' crLF ||,
   '                                                                        ' crLF ||,
   'exit                                                                    ' crLF

  call stream outputFile, 'c', 'CLOSE'

  if prog.__QuietMode <> 1 then
  do
    call lineOut prog.__STDOUT, 'done.'
    call LineOUt prog.__STDOUT, '' 
	call CharOut prog.__STDOUT,  screen.__promptColor || ,
                                'Ú' || center( 'Ä', prog.__screenCols-2 , 'Ä' ) || '¿'
	call CharOut prog.__STDOUT, '³ ' || center( 'Check the program ', prog.__screenCols-4 ) || ' ³'
	call CharOut prog.__STDOUT, '³ ' || center(  outputFile , prog.__screenCols-4 ) || ' ³'
	call CharOut prog.__STDOUT, '³ ' || center( 'carefully before using it!', prog.__screenCols-4 ) || ' ³'
	call CharOut prog.__STDOUT, '³ ' || center( '(see WPTOOLS.TXT)', prog.__screenCols-4 ) || ' ³'
	call CharOut prog.__STDOUT, 'À' || center( 'Ä', prog.__screenCols-2 , 'Ä' ) || 'Ù' || ,
                                screen.__AttrOff || screen.__normalColor
    call LineOUt prog.__STDOUT, center( ' ' , prog.__screenCols )
  end /* if prog.__QuietMode <> 1 then */
  
RETURN thisRC

/* ------------------------------------------------------------------ */
/* function: write the object data to the REXX program file           */
/*                                                                    */
/* call:     WriteObjectData i, outputFile                            */
/*                                                                    */
/* where:    i = index in the stem objectStem.                        */
/*           outputFile = name of the output file                     */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
/*                                                                    */
WriteObjectData: PROCEDURE expose (exposeList)
  parse arg i, outputFile .

  call lineOut outputFile, ''
  call LineOut outputFile, '  i=i+1;'
  call LineOut outputFile, '  objects.i.__Title    = "' || ,
                           CheckString( objectStem.i.__title ) || '"'
  call LineOut outputFile, '  objects.i.__Class    = "' ||,
                           CheckString( objectStem.i.__Class ) || '"'

  call SplitSetupString 50 , objectStem.i.__SetupString

  if SetupStrStem.0 <> 1 then
    call LineOut outputFile, '  objects.i.__Setup    = "' ||,
                             CheckString( SetupStrStem.1 ) || '" ||,'
  else
    call LineOut outputFile, '  objects.i.__Setup    = "' || ,
                             CheckString( SetupStrStem.1 ) || '"'

  do n = 2 to SetupStrStem.0
    if n <> SetupStrStem.0 then
      call LineOut outputFile, '                         "' ||,
                               CheckString( SetupStrStem.n ) || '" ||,'
    else
      call LineOut outputFile, '                         "' || ,
                               CheckString( SetupStrStem.n ) || '" '
  end /* do n = 2 to SetupStrStem.0 */

  call LineOut outputFile, '  objects.i.__location = "' || ,
                           CheckString( objectStem.i.__location ) || '"'

RETURN

/* ------------------------------------------------------------------ */
/* function: replace all " with "" in a string                        */
/*                                                                    */
/* call:     CheckString stringToTest                                 */
/*                                                                    */
/* where:    stringToTest - string to test                            */
/*                                                                    */
/* returns:  the converted string                                     */
/*                                                                    */
/*                                                                    */
CheckString: PROCEDURE expose (exposeList)
  parse arg stringToTest

  i = pos( '"', stringToTest )

  do while i <> 0

    stringToTest = insert( '"', stringToTest, i )
    i = pos( '"', stringToTest, i+2 )
  end /* do while i <> 0 */

RETURN stringToTest

/* ------------------------------------------------------------------ */
/* function: show the object data                                     */
/*                                                                    */
/* call:     ShowObjectData                                           */
/*                                                                    */
/* where:    -                                                        */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
/*                                                                    */
ShowObjectData: PROCEDURE expose (exposeList)

 if prog.__QuietMode <> 1 then
   call CharOut prog.__STDOUT , ' Creating the object list ...'

  prog.__tQuietMode = prog.__QuietMode

  if prog.__LogFile <> 'NUL' then
  do
                        /* do not write the data to the screen if     */
                        /* the logfile parameter was entered          */
    prog.__QuietMode = 1
  end /* if prog.__LogFile <> 'NUL' then */

  call log 'Data of the objects found'
  call log '-------------------------'
  call log ''

  indentValue = 0

/* ??? DEBUG ??? debug code to test the routine SplitSetupString

  do i = 1 to objectStem.0
    SetupStringPrefix = copies( ' ', indentValue ) || 'SetupString: '
    SetupStringPartLength = prog.__ScreenCols - length( SetupStringPrefix ) -2

    call SplitSetupString SetupStringPartLength , objectStem.i.__SetupString
    testString = ''
    do k = 1 to SetupStrStem.0
      testString = testString || SetupStrStem.k
    end
    if testString = objectStem.i.__SetupString  then
      call log 'ok'
    else
    do
      call log 'error: ' || objectStem.i.__Title
      call log '       ' || objectStem.i.__SetupString
      call log '       ' || testString
    end
  end
??? DEBUG end of debug code */

  do i = 1 to objectStem.0
                        /* calculate the indent for the description   */
                        /* of this object                             */
    if objectStem.i.__FolderName <> '' then
      indentValue = CalculateIndentValue( objectStem.i.__FolderName )

    call log ''

    call log copies( ' ', indentValue ) || 'Title:       ' || ,
             objectStem.i.__Title
    call log copies( ' ', indentValue ) || 'Class:       ' || ,
             objectStem.i.__Class

    SetupStringPrefix = copies( ' ', indentValue ) || 'SetupString: '
    SetupStringPartLength = prog.__ScreenCols - length( SetupStringPrefix ) -2

    call SplitSetupString SetupStringPartLength , objectStem.i.__SetupString
    call log SetupStringPrefix || SetupStrStem.1
    do k = 2 to SetupStrStem.0
      call log copies( ' ', length( SetupStringPrefix ) ) || SetupStrStem.k
    end /* do k = 2 to SetupStrStem.0 */

    call log copies( ' ', indentValue ) ||   'Location:    ' || ,
             objectStem.i.__location

    if objectStem.i.__FileName <> '' then
      call log copies( ' ', indentValue ) || 'Filename:    ' || ,
             objectStem.i.__FileName

    if objectStem.i.__FolderName <> '' then
    do
      call log copies( ' ', indentValue ) || 'DirName:     ' || ,
             objectStem.i.__FolderName

                        /* calculate the indent for the description   */
                        /* of the next objects                        */
      indentValue = CalculateIndentValue( objectStem.i.__FolderName ) +2
    end /* if */

  end /* do i = 1 to objectStem.0 */

  prog.__QuietMode = prog.__tQuietMode

  if prog.__QuietMode <> 1 then
    call LineOut prog.__STDOUT , 'done.'

RETURN

/* ------------------------------------------------------------------ */
/* function: show the statistic data                                  */
/*                                                                    */
/* call:     ShowStatisticData                                        */
/*                                                                    */
/* where:    -                                                        */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
/*                                                                    */
ShowStatisticData:

  if prog.__QuietMode <> 1 then
    call CharOut prog.__STDOUT , ' Creating the statistics ...'

  prog.__tQuietMode = prog.__QuietMode

  if prog.__LogFile <> 'NUL' then
  do
                        /* do not write the data to the screen if     */
                        /* the logfile parameter was entered          */
    prog.__QuietMode = 1
  end /* if prog.__LogFile <> 'NUL' then */

  call log ''
  call log 'And now some statistics ...'
  call log ''

  if processSubFolders = 1 then
  do
    call log 'There are ' || ,
             AddColor1( , folderStruc.0-1 ) || ,
             ' sub folder(s) in the folder ' || ,
             AddColor1( '"', folderStruc.1 ) || ,
             ' and its sub folders.'
    call log 'The max. folder depth is ' || ,
             AddColor1( , statistics.__MaxFolderDepth ) || ,
             '.'
  end /* if processSubFolders = 1 then */

  call log 'There are (at least) ' || ,
           AddColor1( , objectStem.0-1 ) || ,
           ' object(s) in the folder(s) (incl. ' || ,
           AddColor1( , statistics.__NotVisibleObjects ) || ,
           ' not visible object(s)).'

  call log AddColor1( , statistics.__TemplateObjects ) || ,
           ' object(s) are templates.'

  call log AddColor1( , statistics.__ObjectsWithID ) ||,
           ' object(s) have an object ID, ' || ,
           AddColor1( , statistics.__ObjectsWithOutID ) ||,
           ' object(s) have no object ID.'

  call log ''

  call log '                        No. of                                          '
  call log 'ObjectClass          objects found     DLL                              '
  call log '------------------------------------------------------------------------'

  do i = 1 to words( objectCountStem.__ClassNames )
    curClassName = strip( word( objectCountStem.__ClassNames, i ) )
    call log left( curClassName, 25 ) ||,
         right( value( 'objectCountStem.' || curClassName ), 4 ) || ,
         '          ' || ,
         GetDllName( curClassName )
  end /* do i = 1 to ... */

  call log ''

  call log 'progType                      No. of objects found'
  call log '--------------------------------------------------'

  do i = 1 to words( progTypes.__UsedTypes )
    curProgType = strip( word( progTypes.__UsedTypes, i ) )
    call log left( curProgType, 30 ) || ,
             right( value( 'progTypes.' || curProgType ), 10 )
  end /* do i = 1 to ... */

  thisRC = 0

                        /* maximum length of an object ID             */
  maxObjectIDLength = 0

                        /* prepare the arrays for the shell sort      */
                        /* and get the maximum length of the object   */
                        /* IDs                                        */
  do i = 1 to statistics.__ObjectIDs.0
    key.i = statistics.__ObjectIDs.i
    ind.i = i
    maxObjectIDLength = max( maxObjectIDLength, length( statistics.__ObjectIDs.i ) )
  end /* do i = 1 to key.0 */
  key.0 = statistics.__ObjectIDs.0

                        /* sort the stem with the object IDs          */
  call ShellSort 2, key.0

                        /* calculate the number of object IDs per     */
                        /* line for the output                        */
  objectIDsPerLine = trunc( (prog.__ScreenCols-1) / (maxObjectIDLength+2) )
  if objectIDsPerLine = 0 then
    objectIDsPerLine = 1

                        /* calculate the field length for one object  */
                        /* ID in the output                           */
  fieldLength = trunc( (prog.__ScreenCols-1) / (objectIDsPerLine) )

  call log ''
  call log 'Used object IDs:'
  call log '----------------'


  fieldCount = 0        /* number of object IDs already in the        */
                        /* current line                               */

  thisIDLine = ''       /* variable for the output                    */

  do i = 1 to key.0
    curIndex = ind.i

    fieldCount = fieldCount + 1
    if fieldCount >= objectIDsPerLine then
    do
      call log thisIDLine
      fieldCount = 0
      thisIDLIne = ''
    end /* if */

    thisIDLine = thisIDLIne || left( value( 'key.' || curIndex ), fieldLength )

  end /* do i = 1 to key.0 */

  if thisIDLine <> '' then
    call log thisIDLine

  prog.__QuietMode = prog.__tQuietMode

  if prog.__QuietMode <> 1 then
    call LineOut prog.__STDOUT , 'done.'

RETURN

/* ------------------------------------------------------------------ */
/* function: get the name of the dll containing a WPS class           */
/*                                                                    */
/* call:     GetDLLName thisClassName                                 */
/*                                                                    */
/* where:    thisClassName     - name of the WPS class                */
/*                                                                    */
/* returns:  name of the DLL or '' if not found                       */
/*                                                                    */
/*                                                                    */
GetDLLName: PROCEDURE expose (exposeList)
  parse arg thisClassName .

  thisDLLName = ''

  if symbol( 'classList.0' ) <> 'VAR' then
  do
                        /* get the list of all registered WPS classes */
                        /* do this only once!                         */
    call sysQueryClassList 'tempClassList.'

    do i = 1 to tempClassList.0
      parse var tempClassList.i curClassName curDllName

      classList.i.__ClassName = strip( curClassName )
      classList.i.__DLLName = strip( curDllName )

    end /* do i = 1 to tempClassList.0 */

    classList.0 = tempClassList.0

  end /* if symbol( 'classList.0' ) <> 'VAR' then */

  do i = 1 to classList.0 until thisDLLName <> ''
    if classList.i.__ClassName = thisClassName then
      thisDLLName = classList.i.__DLLName
  end /* do i = 1 to classList.0 */

RETURN thisDllName

/* ------------------------------------------------------------------ */
/* function: get the data of all objects in a folder                  */
/*                                                                    */
/* call:     ProcessFolder thisFolder                                 */
/*                                                                    */
/* where:    thisFolder        - fully qualified name of the folder   */
/*           IncludeSubFolders - 1: also get the object data for      */
/*                               sub folders                          */
/*                                                                    */
/* returns:  1 - okay                                                 */
/*           else error                                               */
/*                                                                    */
/* note:     the object data is saved in the stem objectStem., the    */
/*           data of the stem objectCountStem. is also updated.       */
/*                                                                    */
ProcessFolder: PROCEDURE expose (exposeList)
  parse arg '"' thisFolder '"' , IncludeSubFolders
  thisRC = 0

                        /* first get the object data of the folder    */
  folderIndex = GetObjectSettings( '"' || thisFolder || '"' )
  if folderIndex = 0 then
    call ShowWarning ,
         'Error detecting the data of the folder "' || ,
          thisFolder || '"'
  else
  do
                        /* save the folder name                       */
    objectStem.folderIndex.__FolderName = thisFolder

                     /* get the data for all objects in the folder    */
    call WPToolsFolderContent thisFolder, "localList."

    if datatype( localList.0, 'NUM' ) = 1 then
    do k = 1 to localList.0
      if GetObjectSettings( '"' || localList.k || '"' ) = 0 then
        call ShowWarning ,
             'Error detecting the data of the object "' || localList.k || '"'
    end /* do k = 1 to localList.0 */

                        /* get the files in this folder               */
    rc = SysFileTree( thisFolder || '\*.*', 'fileObjects.', 'FO' )
    if rc <> 0 then
      call ShowWarning ,
        'Error ' || rc || ' detecting the files in the folder "' || ,
        thisFolder || '"'
    else
    do
      do k = 1 to fileObjects.0
        j = GetObjectSettings( '"' || fileObjects.k || '"' )
        if j = 0 then
          call ShowWarning ,
               'Error detecting the data of the object "' || ,
               fileObjects.k || '"'
        else
          objectStem.j.__FileName = fileObjects.k
      end /* do k = 1 to fileObjects.0 */
    end /* end */

                        /* get the sub folder in this folder          */
    if IncludeSubFolders = 1 then
    do
      rc = SysFileTree( thisFolder || '\*.*', 'dirObjects.', 'DO' )
      if rc <> 0 then
        call ShowWarning ,
          'Error ' || rc || ' detecting the files in the folder "' || ,
          thisFolder || '"'
      else
      do
        do k = 1 to dirObjects.0
          j = GetObjectSettings( '"' || dirObjects.k || '"' )
          if j = 0 then
            call ShowWarning ,
                 'Error detecting the data of the folder "' || ,
                 dirObjects.k || '"'
          else
            objectStem.j.__FolderName = dirObjects.k
        end /* do k = 1 to dirObjects.0 */
      end /* end */
    end /* if IncludeSubFolders = 1 then */

  end /* else */

  thisRC = 1
RETURN thisRC

/* ------------------------------------------------------------------ */
/* function: get the data of an object                                */
/*                                                                    */
/* call:     GetObjectSettings "thisObject"                           */
/*                                                                    */
/* where:    thisObject = id of the object                            */
/*                                                                    */
/* returns:  0 - error,                                               */
/*           n - okay, object data saved in the stem objectStem.      */
/*               n is the index number for the stem objectStem.       */
/*           the data of the stem objectCountStem. is also updated.   */
/*                                                                    */
GetObjectSettings: PROCEDURE expose  (exposeList)
  parse arg '"' thisObjectID '"'

  thisRC = WPToolsQueryObject( thisObjectID, "szClass",,
      									     "szTitle",,
                                             "szSetupString",,
                                             "szLocation" )
  if thisRC = 1 then
  do
    j = objectStem.0+1
    objectStem.j.__class = szClass
    objectStem.j.__title = szTitle
    objectStem.j.__SetupString = szSetupString
    objectStem.j.__Location = szLocation
    objectStem.0 = j

    thisRC = j

    if value( 'objectCountStem.' || szClass ) = 0 then
      objectCountStem.__ClassNames = objectCountStem.__ClassNames szClass

    interpret 'objectCountStem.' || szClass || ' = objectCountStem.' || szClass || '+1'

                        /* collect the statistic data                 */
    testString = ';' || translate( szSetupString ) || ';'

    i1 = pos( ';PROGTYPE=', testString )
    if i1 <> 0 then
    do
      i2 = pos( ';', testString, i1+1 )
      curProgType = substr( szSetupString, i1+9, i2-i1-10 )

      if value( 'progTypes.' || curProgType ) = 0 then
        progTypes.__UsedTypes = progTypes.__UsedTypes curProgType

      interpret 'progTypes.' || curProgType || ' = progTypes.' || curProgType || '+1'

    end /* if i1 <> 0 then */

    if pos( ';NOTVISIBLE=YES', testString ) <> 0 then
      statistics.__NotVisibleObjects = statistics.__NotVisibleObjects + 1

    if pos( 'TEMPLATE=YES', testString ) <> 0 then
      statistics.__templateObjects = statistics.__templateObjects + 1

    i1 = pos( ';OBJECTID=', testString )
    if i1 <> 0 then
    do
      i2 = pos( ';', testString, i1+1 )
      curObjectID = substr( szSetupString, i1+9, i2-i1-10 )

      j = statistics.__ObjectIDs.0 +1
      statistics.__ObjectIDs.j = curObjectID
      statistics.__ObjectIDS.0 = j

      statistics.__ObjectsWithID = statistics.__ObjectsWithID + 1
    end /* if i1 <> 0 then */
    else
      statistics.__ObjectsWithOutID = statistics.__ObjectsWithOutID + 1

  end /* if thisRC = 1 */

RETURN thisRC

/* ------------------------------------------------------------------ */
/* function: calculate the value for the indent                       */
/*                                                                    */
/* call:     CalculateIndentValue thisFolder                          */
/*                                                                    */
/* where:    thisFolder        - fully qualified name of the folder   */
/*                                                                    */
/* returns:  no. of cols for the indent (= number of '\' in the       */
/*           folder name -1 *2 )                                      */
/*                                                                    */
/*                                                                    */
CalculateIndentValue: PROCEDURE expose (exposeList)
  parse arg thisFolder

  IndentValue = 0

  startPosition = 0

  do forever
    startPosition = pos( '\', thisFolder, startPosition+1 )
    if startPosition = 0 then
      leave
    else
      IndentValue = IndentValue + 1
  end /* do forever */

  statistics.__MaxFolderDepth = max( statistics.__MaxFolderDepth, indentValue )

  IndentValue = ( IndentValue -1 ) * 2

  if IndentValue < 0 then
    IndentValue = 0

RETURN IndentValue

/* ------------------------------------------------------------------ */
/* function: get the desktop directory                                */
/*                                                                    */
/* call:     GetDesktopDirectory                                      */
/*                                                                    */
/* where:    -                                                        */
/*                                                                    */
/* returns:  the fully qualified name of the desktop directory        */
/*           or '' in case of an error                                */
/*                                                                    */

/**********************************************************************/
/*                                                                    */
/* GETDESK.CMD                                                        */
/*                                                                    */
/* Version: 1.2                                                       */
/*                                                                    */
/* Written by:  Georg Haschek (haschek at vnet.ibm.com)               */
/*                                                                    */
/* Description: Return the desktop's directory name to the caller.    */
/*                                                                    */
/* captured from a message in a public CompuServe forum               */
/**********************************************************************/

/**************/
/* Initialize */
/**************/

GetDesktopDirectory: PROCEDURE expose (exposeList)
  Return Getpath( Substr( SysIni( "USER",,
                  "PM_Workplace:Location", "<WP_DESKTOP>" ),1,2 ) )

/***********************************************/
/* Loop through the nodes to get the path info */
/***********************************************/
Getpath: Procedure Expose nodes. (exposeList)
  If Getnodes( ) <> 0 Then
    Return ""

  gpinode = Arg( 1 )

  If nodes.gpinode = "" Then
    Return ""

  gp = Substr( nodes.gpinode,33,Length( nodes.gpinode )-33 )
  gpparent = Substr( nodes.gpinode,9,2 )

  If gpparent <> "0000"x Then
  Do
    Do Until gpparent = "0000"x
      gp = Substr( nodes.gpparent,33,Length( nodes.gpparent )-33 ) || ,
           "\" || gp
      gpparent = Substr( nodes.gpparent,9,2 )
    End
  End
Return gp

/*****************/
/* Get the nodes */
/*****************/
Getnodes: Procedure Expose nodes. (exposeList)
  handlesapp = SysIni( "SYSTEM","PM_Workplace:ActiveHandles",,
                       "HandlesAppName" )

  If handlesapp = "ERROR:" Then
    handlesapp = "PM_Workplace:Handles"

  block1 = ""
  Do i = 1 to 999
    block = SysIni( "SYSTEM", handlesapp, "BLOCK" || i )
    If block = "ERROR:" Then
    Do
      If i = 1 Then
      Do
        call ShowWarning ,
               "Unable to locate the NODE table, you are probably",
               "using OS/2 2.0 without the Service Pack."
        Return 1
      End
      Leave
    End
    block1 = block1 || block
  End

  l = 0
  nodes. = ""
  Do Until l >= Length( block1 )
    If Substr( block1,l+5,4 ) = "DRIV" Then
    Do
      xl = Pos( "00"x || "NODE" || "01"x, block1,l+5 )-l
      If xl <= 0 Then
        Leave
      l = l + xl
      Iterate
    End
    Else
    Do
      If Substr( block1,l+1,4 ) = "DRIV" Then
      Do
        xl = Pos( "00"x || "NODE" || "01"x, block1,l+1 )-l
        If xl <= 0 Then
          Leave
        l = l + xl
        Iterate
      End
      Else
      Do
        data = Substr( block1,l+1,32 )
        xl = C2D( Substr( block1,l+31,1 ) )
        If xl <= 0 Then
          Leave
        data = data || Substr( block1,l+33,xl+1 )
        l = l + Length( data )
      End
    End
    xnode = Substr( data,7,2 )
    nodes.xnode = data
  End
Return 0

/* ------------------------------------------------------------------ */
/*-function: sort a stem                                              */
/*                                                                    */
/*-call:     ShellSort low, high                                      */
/*                                                                    */
/*-where:    see below                                                */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
/*                                                                    */
/* Routine SHELLSORT.                                                 */
/*                                                                    */
/* This REXX subroutine can be used to perform a generic sort. It has */
/* been written in a generic fashion to make it as easy as possible   */
/* to plug it into the EXEC of your choice. The algorithm used is the */
/* fastest non-recursive one that I know of for lists in random       */
/* sequence, but if you've got one that's faster, then I challenge    */
/* you to produce an equivalent of this routine using your algorithm. */
/*                                                                    */
/* Before calling this procedure you need to have set up two arrays,  */
/* key. and ind., containing, respectively, the key field for         */
/* comparison purposes, and an index (or pointer) to each element.    */
/*                                                                    */
/* The subroutine takes two numeric arguments representing the first  */
/* and last elements to be sorted, and returns ind. as a pointer list */
/* in ascending order. To change it to sort into descending order all */
/* you need do is change the line that compares key.kind to tempdat   */
/* so that the test is inverted (ie. > becomes <). Alternatively you  */
/* could process the index in reverse order (see below).              */
/*                                                                    */
/* Thus if you had done a CP QUERY RDR ALL into a variable RDRLIST.   */
/* you would code the following to sort it into file name order:      */
/*                                                                    */
/* do i=1 to rdrlist.0                                                */
/*    key.i=substr(rdrlist.i,54,8)                                    */
/*    ind.i=i                                                         */
/* end                                                                */
/*                                                                    */
/* call shellsort 2,rdrlist.0                                         */
/*                                                                    */
/* Note that the first index is 2 because rdrlist.1 is a header line. */
/*                                                                    */
/* To print the list in sorted order you would then code:             */
/*                                                                    */
/* do i=1 to rdrlist.0                                                */
/*    rind=ind.i                                                      */
/*    say rdrlist.rind                                                */
/* end                                                                */
/*                                                                    */
/* Note the use of the pointer. Unfortunately it is not possible to   */
/* code rdrlist.(ind.i) to get the same effect in a single statement. */
/* To display items in descending order you simply reverse the loop,  */
/* do i=rdrlist.0 to 1 by -1, although this would display the header  */
/* at the end, in this instance!                                      */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*  VER   TIME   DATE    BY   NARRATIVE                               */
/*  1.0  15:22 90/02/20 SJP - Original version. Generic sort routine  */
/*                            using Shell algorithm.                  */
/*  1.1  10:13 90/12/07 SJP - Added check for first element number    */
/*                            not being less than last element        */
/*                            number.                                 */
/*  1.2  09:49 92/02/19 SJP - Moved procedure statement for VM/ESA.   */
/*  1.3  10:51 93/08/27 SJP - Tidied up and corrected documentation.  */
/*                                                                    */
/**********************************************************************/
shellsort: PROCEDURE expose (exposeList) key. ind.
  trace o

              /* Check that there are at least two elements to sort   */
  parse arg low, high
  if low >= high then
    return

              /* Calculate an optimal initial gap size                */
  gap = 1
  do while gap < (high-low)+1
     gap = gap*3
  end

              /* Basically we sort the elements 'gap' elements        */
              /* apart, gradually reducing 'gap' until it is one,     */
              /* at which point the list will be fully sorted.        */
  do until gap = 1
     gap=gap/3
     do i=(gap+low) to high
        j=i
        tempind=ind.j
        tempdat=key.tempind
        k=j-gap
        kind=ind.k
        do while key.kind > tempdat
           ind.j=ind.k
           j=k
           k=j-gap
           if k < low then leave
           kind=ind.k
        end
        ind.j=tempind
     end
  end
RETURN

/* ------------------------------------------------------------------ */
/*-function: DeRegister the functions from the DLL WPTOOLS            */
/*                                                                    */
/*-call:     called by the runtime system                             */
/*                                                                    */
/*-where:    -                                                        */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
/*                                                                    */
DeRegisterWPTools: PROCEDURE expose (exposeList)
  call rxFuncDrop 'WPToolsLoadFunc'
  call rxFuncDrop 'WPToolsQueryObject'
  call rxFuncDrop 'WPToolsFolderContent'
RETURN ''

/* ------------------------------------------------------------------ */
/* Function: split a setup string into parts with a maximum length    */
/*                                                                    */
/* call:     SplitSetupString length , setupString                    */
/*                                                                    */
/* where:    length - max. length for the parts                       */
/*           setupString - setup String                               */
/*                                                                    */
/* returns:  1                                                        */
/*                                                                    */
/*           SetupStrStem.0 - no. of parts                            */
/*           SetupStrStem.# - part 1 to n                             */
/*                                                                    */
/* Note:     The setup string is splitted at semicolons (;). If a     */
/*           part of the setup string is to long, it is splitted at   */
/*           commas (,).                                              */
/*           Setupstrings (and parts of them) without a semikolon and */
/*           a comma are not splitted.                                */
/*                                                                    */
SplitSetupString: PROCEDURE expose (exposeList)
  parse arg thisLength, setupString

  SetupStrStem. = ''
  SetupStrStem.0 = 0
  j = 1

  do until setupString = ''

    parse var setupString curPart ';' setupString

    select
      when length( curPart ) >= thisLength then
      do

        if length( SetupStrStem.j ) <> 0 then
          j = j + 1

        curPart = curPart || ';'

        do until curPart = ''
          parse var curPart curTPart ',' curPart

          if ( length( SetupStrStem.j ) + length( curTPart ) + 1 >= thisLength ) & ,
             length( SetupStrStem.j ) <> 0 then
            j = j +1

          if curPart = '' then
            SetupStrStem.j = SetupStrStem.j || curTPart
          else
            SetupStrStem.j = SetupStrStem.j || curTPart || ','

        end /* until curPart = '' */

      end /* when */

      when length( SetupStrStem.j ) + 1 + length( curPart ) > thisLength then
      do
        j = j + 1
        SetupStrStem.j = curPart || ';'
      end /* when */

      otherwise
      do
        SetupStrStem.j = SetupStrStem.j || curPart || ';'
      end /* otherwise */

    end /* select */
  end /* do until setupString = '' */

  setupStrStem.0 = j

RETURN 1

/* ------------------------------------------------------------------ */
/* Function: create a backup of a file                                */
/*                                                                    */
/* call:     CreateBackupFile fileToBackup                            */
/*                                                                    */
/* where:    fileToBackup = name of the file to backup                */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
CreateBackupFile: PROCEDURE EXPOSE (exposeList)
  parse arg cbf.oldfileName

  cbf.i = lastpos( '.', cbf.oldFileName )
  if cbf.i <> 0 then
    cbf.testFileName = substr( cbf.oldFileName, 1, cbf.i-1 )
  else
    cbf.testFileName = cbf.oldFileName

  do cbf.index=0 to 999
    cbf.newFileName = cbf.testFileName || '.' || copies( '0', 3 - LENGTH( cbf.index ) ) || cbf.index
    if stream( cbf.newFileName,'c', 'QUERY EXISTS' ) = '' then
      leave
    cbf.newFileName = ''
  end /* do cbf.index=0 to 999 */

  if cbf.newFilename = '' then
  do
                                /* no possible file name found        */
    call ShowError 3,,
         'Can not find a name for the backup of the file "' || ,
         cbf.oldfilename || '"'

  end /* if cbf.newFilename then */
  else
  do
                                /* create the backup                  */
    '@copy ' cbf.oldFileName cbf.newFileName '/V 2>NUL 1>NUL'
    if rc <> 0 & rc <> "RC" then
      call ShowError 3 ,,
           'OS Error ' || rc || ' copying the file "' || ,
           cbf.oldfilename ||,
           '" to "' || ,
           cbf.NewFileName || ,
           '"'
  end /* else */

  drop cbf.
RETURN


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
/*-function: Show the invocation syntax                               */
/*                                                                    */
/*-call:     called by the runtime system with                        */
/*           => call ShowUsage <=                                     */
/*                                                                    */
/*-where:    -                                                        */
/*                                                                    */
/*-returns:  ''                                                       */
/*                                                                    */
ShowUsage: PROCEDURE expose (exposeList)
  crLF = '0D0A'x
  
  call log ' Usage: ' || prog.__name || ' {!|{!}startFolder}'   crLF ,
           '       {/L:logfile}'                                crLF ,
           '       {/REXX{=file}} {/NOREXX} '                   crLF ,
           '       {/STAT} {/NOSTAT}'                           crLF ,
           '       {/LIST} {/NOLIST}'                           crLF ,
           '       {/Silent} {/NoAnsi} {/NoSound}'              crLF ,
           '       {/H}'
RETURN ''

/***        End of Part 4 of the source code of TEMPLATE.CMD        ***/

/**********************************************************************/

