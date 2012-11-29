/* ------------------------------------------------------------------ */
/* TEMPLATE.CMD - Template for a REXX program                         */
/*                                                                    */
/* (c) Copyright Bernd Schemmer 1994,1995,1996                        */
/*                                                                    */
/*-Author:                                                            */
/*   Bernd Schemmer                                                   */
/*   Baeckerweg 48                                                    */
/*   D-60316 Frankfurt am Main                                        */
/*   Germany                                                          */
/*   Compuserve: 100104,613                                           */
/*   Internet:   100104.613@compuserve.com                            */
/*                                                                    */
/*-History:                                                           */
/*   01.07.1994 /bs v1.00                                             */
/*     - initial release                                              */
/*                                                                    */
/*   09.12.1994 /bs v2.51                                             */
/*     - first public release                                         */
/*                                                                    */
/*   01.01.1995 /bs v2.52 (Size of token image: 34.959)               */
/*     - corrected a bug in the logfile routine                       */
/*       (no message was written to the logfile)                      */
/*     - added some more comments (requested by some users)           */
/*     - converted all esc chars to '1B'x                             */
/*     - added the environment variable 'SOUND'                       */
/*     - changed the error handler:                                   */
/*       Only the error handler for the trapped condition is now      */
/*       reinstalled. The runtime system does now never change        */
/*       the error handling if it was changed in MAIN.                */
/*     - made some optimisations to shrink the needed memory for the  */
/*       token image                                                  */
/*                                                                    */
/*   31.03.1995 /bs v2.53 (Size of token image: 34.508)               */
/*     - corrected a bug in the error handler                         */
/*     - added code to turn ANSI word wrap on                         */
/*     - added the environment variable SILENT                        */
/*     - added code to save the contents of prog.__STDOUT and         */
/*       prog.__STDERR before initialising the stem prog.             */
/*     - corrected a minor bug in the routine INCLUDE                 */
/*     - added the parameter NOSOUND                                  */
/*     - added the parameter NOANSI                                   */
/*     - added code to reset the timer at program start               */
/*     - corrected some grammatical errors in the comments            */
/*     - removed the length restriction for the parameter             */
/*     - now you can also use unbalanced quotes or double quotes in   */
/*       the parameter                                                */
/*                                                                    */
/*   28.04.1995 /bs v2.54 (Size of token image: 34.536)               */
/*     - changed the internal routine I!.__CallUserProc and changed   */
/*       the 6th parameter of the LOADDLL call for loading REXXUTIL   */
/*                                                                    */
/*   23.05.1995 /bs v2.55 (Size of token image: 34.467)               */
/*     - corrected a bug in the ShowString routine                    */
/*     - changed code to be compatible with the new COMPRESS mode     */
/*       of REXXCC v3.00 (**)                                         */
/*     - added the program name to the error messages in ShowError    */
/*     - added some optimizations for size                            */
/*                                                                    */
/*   16.07.1995 /bs v3.00 (Size of token image: 36.892)               */
/*     - added support for an internal or external routine for the    */
/*       message handling (exception: The messages in case of an      */
/*       unexpected error are always in English)                      */
/*     - added the variable prog.__DefParms                           */
/*                                                                    */
/*   31.09.1995 /bs v3.01 (Size of token image: 36.879)               */
/*     - added RxFuncDrop call to LoadDLL routine                     */
/*     - added the routine GetLineNo                                  */
/*     - added the debugging routine ShowDefinedVariables             */
/*     - added the parameter /TRACE, the environment variable         */
/*       RXTTRACE and the variable PROG.__TRACE                       */
/*     - added sample code to load the DLL YDBAUTIL (in comments)     */
/*     - added code to make TEMPLATE OO REXX compatible               */
/*       (see lines marked with OOREXX)                               */
/*                                                                    */
/*   02.12.1995 /bs v3.02 (Size of token image: 37.142)               */
/*     - added code to use additional defaults values for EXPOSELIST  */
/*     - the user abort routine displayed the wrong line number.      */
/*     - added code to use the DLL RXU instead of YDBAUTIL if         */
/*       YDBAUTIL does not exist (RXU is the new name of YDBAUTIL)    */
/*                                                                    */
/*   28.05.1996 /bs v3.03 (Size of token image: 37.142)               */
/*     - corrected some minor bugs                                    */
/*                                                                    */
/*   01.09.1996 /bs v3.04 (Size of token image: 36.652)               */
/*     - did some optimizations                                       */
/*                                                                    */
/*-Distribution:                                                      */
/*   This code may be distributed freely and used in other programs.  */
/*   Please give credit where credit is due.                          */
/*   If you need further help, feel free to contact me at the address */
/*   noted above.                                                     */
/*                                                                    */
/*-Description:                                                       */
/*   TEMPLATE.CMD is a template for a REXX program containing a       */
/*   "runtime system" for the REXX program.                           */
/*   TEMPLATE.CMD ...                                                 */
/*   - supports INCLUDE() and TRYINCLUDE() (see source)               */
/*   - contains an extended error handler (much better than the       */
/*     default error handler, see routine 'I!.__ErrorAbort')          */
/*   - supports patched version                                       */
/*   - supports CID conventions                                       */
/*   - supports colored messages                                      */
/*   - supports internal and external routines for message handling   */
/*   - supports execution in the REXX macro space                     */
/*   - supports executions as "compiled" REXX program (**)            */
/*   - supports logging of program messages, STDOUT messages and/or   */
/*     STDERR messages of OS/2 programs                               */
/*   - contains a debugging mechanism                                 */
/*   - contains an exit routine handler                               */
/*   - contains many predefined variables (for example the program    */
/*     name, drive and path)                                          */
/*   - contains very useful predefined routines, for example          */
/*       LoadDll - load a DLL, for example REXXUTIL or VREXX          */
/*       ShowString - show a string with prefix and word wrapping     */
/*       Include - execute an include file                            */
/*       TryInclude - execute an include file only if it exists       */
/*   and much more.                                                   */
/*                                                                    */
/* (**) You may use my program REXXCC to "compile" or "compress" your */
/*      REXX programs. You can get REXXCC at the same source as this  */
/*      file. The name of the archiv with REXXCC is "RCnnn.EXE"       */
/*      where nnn is the version of REXXCC. REXXCC is freeware.       */
/*                                                                    */
/*-CAUTION: READ THESE COMMENTS CAREFULLY BEFORE (!) USING THIS CODE! */
/*                                                                    */
/*-Usage:                                                             */
/*   Copy this file to a new file, example:                           */
/*     => COPY TEMPLATE.CMD MYPROG.CMD <=                             */
/*   Change the variables after these comments to your need.          */
/*   Insert your main code after the label                            */
/*     => MAIN: <=                                                    */
/*   in the new file MYPROG.CMD.                                      */
/*   Insert your subroutines behind the line saying                   */
/*     => INSERT FURTHER SUBROUTINES HERE <=                          */
/*   in the new file MYPROG.CMD.                                      */
/* That's all - but do not forget to read the comments below!!!       */
/*                                                                    */
/*-Predefined parameter:                                              */
/*   TEMPLATE {/L:logfile} {/H} {/Silent} {/NoSound} {/NoAnsi}        */
/*            {/Trace}                                                */
/*                                                                    */
/*-where:                                                             */
/*                                                                    */
/*   /L:logFile - logfile is the name of the logfile :-)              */
/*                This parameter is case-sensitive!                   */
/*                def.: do not use a logfile                          */
/*                                                                    */
/*   /H         - show usage, you may also use                        */
/*                /h, /?, /HELP, -h, -H, -HELP or -?                  */
/*                (MAIN is not called!)                               */
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
/*   /Trace     - turn TRACE on before calling MAIN. You may also     */
/*                set the environment variable RXTTRACE to ON to      */
/*                turn the TRACE mode for MAIN on.                    */
/*                                                                    */
/* NOTE:                                                              */
/*   You must use at least one blank to separate the parameter.       */
/*   The predefined parameters are interpreted by the runtime system. */
/*   The procedure MAIN will never see them!                          */
/*                                                                    */
/* HINT:                                                              */
/*   Do not define a parameter beginning with '/Q'! The string '/Q'   */
/*   in the parameters is always interpreted by the CMD - your        */
/*   program will never see that part of the parameter!               */
/*   Do not use parameter beginning with two slashes '//'. These      */
/*   parameters are reserved for the REXX interpreter.                */
/*                                                                    */
/*-predefined returncodes:                                            */
/*      0 - execution okay                                            */
/*    240 ... 252                                                     */
/*          reserved for the runtime system                           */
/*    253 - syntax help called (parameter /h)                         */
/*    254 - user break (CTRL-C)                                       */
/*    255 - internal runtime system error                             */
/*   else - program specific errors                                   */
/*                                                                    */
/*-Notes:                                                             */
/*                                                                    */
/* #======================== !!! IMPORTANT !!! =====================# */
/* # Do NOT define variables for the stem 'I!.'!                    # */
/* # Do NOT use any of the variables beginning with 'I!.' in your   # */
/* # code!                                                          # */
/* # Do NOT use any of the routines beginning with 'I!.' in your    # */
/* # code!                                                          # */
/* # Do NOT define variables which names begin with two underscores # */
/* # ('__') in your code!                                           # */
/* #================================================================# */
/*                                                                    */
/* #======================== !!! IMPORTANT !!! =====================# */
/* # Do NOT change, add or delete code between the lines            # */
/* #                                                                # */
/* # ...********** DO NOT CHANGE THE FOLLOWING LINES ***********... # */
/* #                                                                # */
/* # and                                                            # */
/* #                                                                # */
/* # ...********************************************************... # */
/* #                                                                # */
/* #================================================================# */
/*                                                                    */
/* #======================== !!!   HINT    !!! =====================# */
/* # Do NOT change, add or delete the lines                         # */
/* #                                                                # */
/* # ... start of part n of the source code of TEMPLATE.CMD     ... # */
/* #                                                                # */
/* # and                                                            # */
/* #                                                                # */
/* # ... end of part n of the source code of TEMPLATE.CMD       ... # */
/* #                                                                # */
/* # (where n =1,2,3 or 4) if you want to use MAKECMD.CMD to update # */
/* # the runtime system of your programs if you get a new version   # */
/* # of TEMPLATE.CMD.                                               # */
/* #                                                                # */
/* #================================================================# */
/*                                                                    */
/* predefined variables (All values are in uppercase. IMPORTANT:      */
/* DO NOT CHANGE THESE VARIABLES!)                                    */
/*                                                                    */
/* prog.__drive        = Drive of the program (e.g. "D:").            */
/*                       This variable is '' if the program is in the */
/*                       macro space.                                 */
/* prog.__path         = path of the program (e.g. "\CODESERV\CMD")   */
/*                       This variable is '' if the program is in the */
/*                       macro space.                                 */
/* prog.__name         = name of the program (e.g. "MYPROG.CMD")      */
/* prog.__FullName     = fully qualified name of the program          */
/*                       (e.g. "D:\CODESERV\CMD\MYPROG.CMD")          */
/*                       This variable contains only the program name */
/*                       if the program is in the macro space         */
/* prog.__env          = OS/2 environment (use for VALUE() commands!) */
/* prog.__Version      = version of TEMPLATE.CMD (e.g. "V1.00")       */
/* prog.__QuietMode    = suppress all messages if not 1               */
/*                       This variable is set to 1, if the parameter  */
/*                       /SILENT was entered or if the environment    */
/*                       variable SILENT is set to "1" or "ON".       */
/* prog.__Trace        = This variable contains 1 if the trace mode   */
/*                       for the function MAIN is turned on (either   */
/*                       with the parameter "/TRACE" or if the        */
/*                       environment variable RXTTRACE is set to      */
/*                       "MAIN")                                      */
/* prog.__DefParms     = This variable contains the syntax for the    */
/*                       default parameters for TEMPLATE.CMD.         */
/*                       This can be useful for usage routines.       */
/*                                                                    */
/* prog.__Logfile      = name of the logfile (or "" if none)          */
/* prog.__LogSTDERR    = string to direct STDERR into the logfile     */
/* prog.__LogSTDOUT    = string to direct STDOUT into the logfile     */
/* prog.__LogALL       = String to direct STDOUT and STDERR into the  */
/*                       logfile.                                     */
/* prog.__LogFileParm  = log-Parameter for child cmds ("" if no       */
/*                       logfile is defined), usage:                  */
/*                       => call child.cmd {...} prog.__LogFileParm <=*/
/*                                                                    */
/*-NOTE: If no log file is defined, the output goes to the NUL-Device */
/*       See below for examples using the logfile variables.          */
/*                                                                    */
/* global.__ErrorExitCode                                             */
/*                     = return code for unknown errors (255)         */
/* global.__OKExitCode = return code if the execution was ok (0)      */
/*                                                                    */
/* CIDRC.              = return codes for the CID process (only       */
/*                       defined if global.__NeedCID is 1, see        */
/*                       the procedure I!.__InitCIDVars)              */
/*                                                                    */
/*-predefined variables (may be changed):                             */
/*                                                                    */
/* exposeList          = Name(s) of the the global variables ALL      */
/*                       procedures must know!                        */
/*                       You may add further variable names to this   */
/*                       string but you must NOT delete any name from */
/*                       this variable! IMPORTANT:                    */
/*                       DO ONLY ADD STEM VARIABLES TO THIS VARIABLE! */
/*                                                                    */
/* prog.__NoSound      = 1 - turn sounds off                          */
/*                       else: turn sounds on (default)               */
/*                       TEMPLATE use sounds only in case of an error */
/*                       You may also set the environment variable    */
/*                       SOUND to "NO" if you don't want sounds.      */
/*                                                                    */
/* prog.__LogExcludeWords =                                           */
/*                       This variable contains strings, which you    */
/*                       want to output on the screen but not in      */
/*                       the logfile (via the procedure LOG). You     */
/*                       may use this variable for example for color  */
/*                       codes which you might use in your messages.  */
/*                       The default for prog.__LogExcludeWords is '' */
/*                                                                    */
/* prog.__UserAbort    = 0 - do not permit CTRL-BREAK                 */
/*                       1 - permit CTRL-BREAK (default)              */
/*                                                                    */
/* prog.__ExitCode     = return code of the program                   */
/*                       Note that 'prog.__ExitCode' should be a      */
/*                       whole number. (def.: 0)                      */
/*                       Do not define the return codes 0 and 240     */
/*                       to 255. These return codes are used by the   */
/*                       runtime system.                              */
/*                                                                    */
/* prog.__ExitRoutines = routines, which should be executed at        */
/*                       program end (def.: NONE)                     */
/*                       Usage example: see below                     */
/*                                                                    */
/* prog.__STDOUT       = output device for messages (def.: "STDOUT")  */
/* prog.__STDERR       = output device for error messages             */
/*                       (def.: "STDOUT")                             */
/* prog.__CurDir       = working directory at program start           */
/*                       Note that the working directory at program   */
/*                       start is restored at program end automaticly */
/*                       To avoid this use 'drop prog.__CurDir'.      */
/*                                                                    */
/* prog.__ScreenCols   = number of screen columns                     */
/*                       (default: 80, or the real number of colums   */
/*                       if REXXUTIL is loaded before the program     */
/*                       starts)                                      */
/*                                                                    */
/* prog.__ScreenRows   = number of screen rows                        */
/*                       (default: 25, or the real number of rows     */
/*                       if REXXUTIL is loaded before the program     */
/*                       starts)                                      */
/*                                                                    */
/* screen.             = stem variables for foreground and background */
/*                       colors, some examples:                       */
/*                                                                    */
/* screen.__CurColor   = current color for messages                   */
/* screen.__ErrorColor = color for error and warning messages         */
/* screen.__NormalColor= color for normal messages                    */
/* screen.__DebugColor = color for debug messages                     */
/* screen.__PromptColor= color for input prompts                      */
/*                       (see also the procedure                      */
/*                       I!.__InitColorVars for further vars.)        */
/*                                                                    */
/* global.__verbose    = show debug messages if this variable is not  */
/*                       equal ''. You may set the environment        */
/*                       variable VERBOSE to the value for this       */
/*                       variable before running the program.         */
/*                       Note: There is no debug code in the runtime  */
/*                             system.                                */
/*                                                                    */
/* variables for conditional addons (may only be changed in the first */
/* part of the program!):                                             */
/*                                                                    */
/* global.__SignOnMsg  = set to 0 if you do not want a program        */
/*                       start and end message (def.: 1)              */
/* global.__Version    = version of the program (e.g. "V1.00")        */
/* global.__NeedCID    = set to 1 if you need CID support (def.: 0)   */
/* global.__NeedColors = set to 0 if you do not want colored          */
/*                       messages (def.: 1)                           */
/*                       You may also set the environment variable    */
/*                       ANSI to "NO" or use the parameter /NOANSI    */
/*                       if you don't want colors.                    */
/*                       The environment variable ANSI and the        */
/*                       parameter /NOANSI overwrite the variable     */
/*                       global.__NeedColors while running the        */
/*                       program.                                     */
/*                       CAUTION: OS/2 ANSI support must be ON to use */
/*                                colors!                             */
/* global.__NeedPatchCheck                                            */
/*                     = set to 0 if you do not want to search        */
/*                       the program for a patched version of the     */
/*                       program (def.: 1)                            */
/*                                                                    */
/* global.__GetMsg     = set to the name of the routine for           */
/*                       the message handling if any (see below,      */
/*                       def.: use hardcoded messages)                */
/* global.__BaseMsgNo  = base number for the message numbers          */
/*                       (def.: 1000)                                 */
/*                                                                    */
/* Routines called by the runtime system                              */
/*                                                                    */
/* þ Main                                                             */
/*-function:                                                          */
/*   This is the main routine of the program.                         */
/*-parameter:                                                         */
/*   The parameter for this routine are the program parameter         */
/*   without the parameter handled by the runtime system.             */
/*-returns:                                                           */
/*   nothing                                                          */
/* YOU MUST FILL THIS ROUTINE WITH CODE!                              */
/*                                                                    */
/* þ ShowUsage                                                        */
/*-function:                                                          */
/*   This routine is called, if the program is invoked with one of    */
/*   the parameters /H, /h, /?, /HELP, -h, -H, -HELP or -?.           */
/*-parameter:                                                         */
/*   none                                                             */
/*-returns:                                                           */
/*   nothing                                                          */
/* YOU SHOULD FILL THIS ROUTINE WITH CODE!                            */
/*                                                                    */
/* Predefined routines (you may use this routines in your code. See   */
/* the source for the invocation parameters and the return codes):    */
/*                                                                    */
/* þ LoadDll parameter                                                */
/*   - load a dll                                                     */
/*                                                                    */
/* þ ConvertNameToOS {fileName|dirName}                               */
/*   - convert the name of a file or directory to the format of OS/2  */
/*     by adding a leading and a trailing quote or double quote to    */
/*     the name.                                                      */
/*     Example:                                                       */
/*        => my1stFileName="This is a 'valid' HPFS filename"  <=      */
/*        => say convertNameToOS( my1stFileName )             <=      */
/*      Output:                                                       */
/*        "This is a 'valid' HPFS filename"                           */
/*     Hint: You should always save the names of files and directorys */
/*           without leading and trailing quotes or double quotes     */
/*           because the REXX functions don't like quotes or double   */
/*           quotes surrounding file and directory names.             */
/*                                                                    */
/* þ ShowString prefix, string                                        */
/*   - show a string with word wrapping and write it also to the      */
/*     logfile (if a logfile is defined)                              */
/*     'prefix' is the prefix for the first line. This can be a       */
/*     string like '*-* ' or a number. If 'prefix' is a number,       */
/*     ShowString uses this number of blanks as prefix.               */
/*     Note: Do not use ShowString for strings with color codes!      */
/*                                                                    */
/* þ ShowWarning message                                              */
/*   - show the warning message 'message' and write it also to the    */
/*     logfile if defined                                             */
/*     Note: Do not use color codes in the message!                   */
/*                                                                    */
/* þ ShowError exitCode, errorMessage                                 */
/*   - show the error message 'errorMessage', write it also to the    */
/*     logfile if defined and exit the program with the return code   */
/*     'exitCode'                                                     */
/*     Note: Do not use color codes in the errorMessage!              */
/*                                                                    */
/* þ Log message                                                      */
/*   - show the message 'message' and write the message also to the   */
/*     logfile if defined                                             */
/*     You may use colors in the message.                             */
/*                                                                    */
/* þ LogDebugMsg message                                              */
/*   - show the message 'message' in the color for debug messages and */
/*     write the message also to the logfile if defined (only if the  */
/*     variable 'global.__verbose' is not equal '')                   */
/*                                                                    */
/* þ FlushQueue                                                       */
/*   - flush the current REXX queue                                   */
/*                                                                    */
/* þ GetLineNo                                                        */
/*   - get the number of a line in the REXX program at runtime        */
/*     Usage:                                                         */
/*       => thisLine = GetLineNo() <=                                 */
/*                                                                    */
/* þ Include fileName                                                 */
/*   - execute the include file 'fileName'                            */
/*     Usage:                                                         */
/*       => Include( fileName ) <=                                    */
/*                                                                    */
/* þ TryInclude fileName                                              */
/*   - execute the include file 'fileName' if it exists               */
/*     Usage:                                                         */
/*       => TryInclude( fileName ) <=                                 */
/*                                                                    */
/* #======================= !!! CAUTION: !!! =======================# */
/* # Read the part about the 'INTERPRET' command in the Online help # */
/* # of REXX carefully before writing and using include files!!!    # */
/* # Hint: You can use multi line statements in include files.      # */
/* #       (Exception: Multi line comments are not possible.)       # */
/* # Note: You can NOT define subroutines in an include file        # */
/* #       because the statements in the include file are executed  # */
/* #       immediately!                                             # */
/* #================================================================# */
/*                                                                    */
/* Debugging routines                                                 */
/*                                                                    */
/* #======================= !!! CAUTION: !!! =======================# */
/* # Note: You must delete the lines marked with                    # */
/* #          **DEBUG**                                             # */
/* #       before using the debugging routines!                     # */
/* #================================================================# */
/*                                                                    */
/* þ ShowDefinedVariables                                             */
/*   - shows some or all variables defined in a scope                 */
/*     (This routine needs the DLL YDBAUTIL or RXU!)                  */
/*                                                                    */
/* #================================================================# */
/*                                                                    */
/* Do NOT use the following names for functions or routines:          */
/*                                                                    */
/*   ShowString     ShowWarning       ShowError     Log               */
/*   LogDebugMsg    include           TryInclude    LoadDll           */
/*   FlushQueue     ConvertNameToOS                                   */
/*                                                                    */
/* Environment variables used while running the program               */
/*                                                                    */
/* þ ANSI                                                             */
/*   - Set the environment variable 'ANSI' to "0" or "OFF" if you     */
/*     don't want colors.                                             */
/*                                                                    */
/* þ PATCHDRIVE                                                       */
/*   - Set the environment variable 'PATCHDRIVE' to the drive with    */
/*     a patched version of your program (if any exist, see routine   */
/*     'I!.__CheckPatch').                                            */
/*                                                                    */
/* þ SILENT                                                           */
/*   - Set the environment variable 'SILENT' to "1" or "ON" to        */
/*     suppress all messages.                                         */
/*                                                                    */
/* þ SOUND                                                            */
/*   - Set the environment variable 'SOUND' to "0" or "OFF" if you    */
/*     don't want sounds.                                             */
/*                                                                    */
/* þ RXTTRACE                                                         */
/*   - Set the environment variable 'RXTTRACE' to "MAIN" to turn the  */
/*     trace mode for the function MAIN on.                           */
/*                                                                    */
/* þ VERBOSE                                                          */
/*   - Set the environment variable 'VERBOSE' to any value not equal  */
/*     '' if you want debug information. If the value of the variable */
/*     is 'DEBUG', the error handler turns interactive trace on if an */
/*     error occured.                                                 */
/*     Note that the error handler also turns interactive trace on if */
/*     the environment variable RXTTRACE is set to 'MAIN' or if the   */
/*     parameter '/TRACE' is specified.                               */
/*                                                                    */
/*-Message handling                                                   */
/*                                                                    */
/* TEMPLATE can use an internal or external routine for the message   */
/* handling.  To activate this feature, you must add the statement    */
/*                                                                    */
/*   => global.__GetMsg = 'GETMSG' <=                                 */
/*                                                                    */
/* to the first part of your program. Replace GETMSG with the name    */
/* of your message handling routine.                                  */
/* Note that you can't use a path for the name of the routine. So the */
/* routine must be an internal routine in your program, an external   */
/* routine available through the environment variable PATH, a routine */
/* within a loaded DLL or a routine in the macro space.               */
/*                                                                    */
/* The routine is called by TEMPLATE.CMD with:                        */
/*                                                                    */
/*   => call global.__GetMsg  msgNo,, {mP1, mP2, mP3, mP4, ,    <=    */
/*   =>                                mP5, mP6, mP7, mP8, mP9} <=    */
/*                                                                    */
/* msgNo is the message number and mP1 to mP9 are the parameter for   */
/* the message. The parameter for the message are optional and depend */
/* on the message number.                                             */
/* For example there are messages with 0, 1 or more parameter.        */
/* The routine must return the message or an empty string.            */
/*                                                                    */
/* Note that there is an empty parameter between msgNo and the first  */
/* message parameter!!!                                               */
/*                                                                    */
/* The following message numbers are used by TEMPLATE.CMD:            */
/*                                                                    */
/*  MsgNo  example message text                                       */
/* ------------------------------------------------------------------ */
/*  b+1    Routine "%1" not found                                     */
/*  b+2    Can not write to the logfile "%1", the status of the       */
/*         logfile is "%2". Now using the NUL device for logging      */
/*  b+3    Include file "%1" not found                                */
/*  b+4    Unexpected EOF detected while reading the include          */
/*         file "%1"                                                  */
/*  b+5    Error loading the DLL "%1"                                 */
/*  b+6    Invalid call to LOADDLL                                    */
/*  b+7    Warning:                                                   */
/*  b+8    %1 - Error %2 detected! The error message is               */
/*  b+9    Calling the patched version %1 ...                         */
/*  b+10   ... the patched version endet with RC = %1                 */
/*  b+11   Program aborted by the user (sigl=%1)                      */
/*  b+12   %1 %2 started on %3 at %4 ...                              */
/*  b+13   %1 %2 ended on %3 at %4 with RC = %5 (='%6'x)              */
/*  b+14   Usage:                                                     */
/*                                                                    */
/* The message numbers b+15 to b+50 are reserved for future use.      */
/* b is the current value of the variable global.__BaseMsgNo.         */
/* So, if you use the default value for global.__BaseMsgNo, 1000,     */
/* TEMPLATE uses the message numbers 1001 to 1014 (and 1015 to 1050   */
/* are reserved for future use).                                      */
/*                                                                    */
/* Parameter for the messages:                                        */
/*                                                                    */
/*  MsgNo  parameter description                Parameter             */
/* ------------------------------------------------------------------ */
/*  b+1    name of the not found routine           mP1                */
/*  b+2    name of the log file/device             mP1                */
/*         status of the logfile/device            mP2                */
/*  b+3    name of the not found include file      mP1                */
/*  b+4    name of the include file                mP1                */
/*  b+5    name of the dll                         mP1                */
/*  b+6    *** no parameter ***                                       */
/*  b+7    *** no parameter ***                                       */
/*  b+8    program name                            mP1                */
/*         error number                            mP2                */
/*  b+9    name of the patched version             mP1                */
/*  b+10   RC of the patched version               mP1                */
/*  b+11   line number                             mP1                */
/*  b+12   program name                            mP1                */
/*         program version                         mP2                */
/*         start date                              mP3                */
/*         start time                              mP4                */
/*  b+13   program name                            mP1                */
/*         program version                         mP2                */
/*         end date                                mP3                */
/*         end time                                mP4                */
/*         return code                             mP5                */
/*         return code in hexadecimal format       mP6                */
/*  b+14   *** no parameter ***                                       */
/*                                                                    */
/*-Hints:                                                             */
/*                                                                    */
/* In the default TEMPLATE catches ALL error conditions (SYNTAX,      */
/* NOVALUE, HALT, FAILURE, NOTREADY and ERROR). To change this        */
/* behaviour add one or more 'SIGNAL OFF condition' - statements      */
/* at the begin of the procedure MAIN.                                */
/*                                                                    */
/* All routines declared with 'PROCEDURE' must have an 'EXPOSE' list! */
/* You MUST add the string '(EXPOSELIST)' to the expose lists of ALL  */
/* procedures!                                                        */
/* If you get an internal error in the error routine, check if        */
/* '(EXPOSELIST)' is included in the expose lists of ALL routines!    */
/*                                                                    */
/* Use only                                                           */
/*   => call Log message <=                                           */
/* to print messages on the screen.                                   */
/*                                                                    */
/* Use only                                                           */
/*   => call LogDebugMsg message <=                                   */
/* to print debugging messages on the screen.                         */
/*                                                                    */
/* Define all global variables as 'GLOBAL.__varName'.                 */
/* Note: If you want to define another stem with global variables     */
/*       you should add the name of the stem to the expose list of    */
/*       the routine 'MAIN' or define a  default for the variable     */
/*       'EXPOSELIST' in the first part of your program!              */
/*                                                                    */
/* Append the names of all routines, which should be executed at      */
/* program end to the variable 'PROG.__EXITROUTINES'.                 */
/*-Example:                                                           */
/*                                                                    */
/*   If the program should execute the routine 'DelTempFile'          */
/*   at program end use the following statement:                      */
/*                                                                    */
/*   => prog.__ExitRoutines = prog.__ExitRoutines ' DelTempFile' <=   */
/*                                                                    */
/*   Note that you can't use parameters for the routines saved in     */
/*   the variable 'PROG.__EXITROUTINES'!                              */
/*   Note further that the routines are executed in the order they    */
/*   are saved in the variable 'PROG.__EXITROUTINES'.                 */
/*   And last but not least:                                          */
/*   You can add new entrys to this variable in an exit routine. You  */
/*   can also change or delete any entry from the variable in an      */
/*   exit routine.                                                    */
/*   You may check the variable 'PROG.__EXITCODE' in an exit routine  */
/*   to determine what caused the program end (see predefined         */
/*   return codes above)                                              */
/*                                                                    */
/* Use the following code sequence to inherit a log file to a         */
/* child cmd file:                                                    */
/*                                                                    */
/*   => 'cmd /c ' ChildName ChildParameter prog.__logFileParm  <=     */
/*                                                                    */
/* Use the variable 'prog.__LogALL' to direct STDOUT and STDERR       */
/* of an OS/2 program into the logfile.                               */
/*-Example:                                                           */
/*                                                                    */
/*   => '@attrib ' thisFile  prog.__LogALL <=                         */
/*                                                                    */
/* Use the variable 'prog.__LogSTDERR' to direct only STDERR of an    */
/* OS/2 program into the logfile.                                     */
/* Example:                                                           */
/*                                                                    */
/*   => '@attrib ' thisFile  prog.__LogSTDERR <=                      */
/*                                                                    */
/* Use the variable 'PROG.__LogSTDOUT' to direct only STDOUT of an    */
/* OS/2 program into the logfile.                                     */
/*-Example:                                                           */
/*                                                                    */
/*   => '@attrib ' thisFile  prog.__LogSTDOUT <=                      */
/*                                                                    */
/* Do NOT use 'PROG.__LogSTDERR' and 'PROG.__LogSTDOUT' in the same   */
/* command (use 'PROG.__LogALL' instead)                              */
/*                                                                    */
/* Use the variable 'global.__verbose' if you want to add debug code  */
/* to your program.                                                   */
/*-Example:                                                           */
/*                                                                    */
/*   => if global.__verbose <> '' then  <=                            */
/*   => do                              <=                            */
/*   =>    {debug code}                 <=                            */
/*   => end                             <=                            */
/*                                                                    */
/* Use the variable 'PROG.__ENV' if you want to set or get an         */
/* environment variable.                                              */
/*-Example:                                                           */
/*                                                                    */
/*   => MaintDrive = value( 'MaintDrive',, prog.__env ) <=            */
/*                                                                    */
/* REPORT ANY ERRORS and SUGGESTIONS to the author of this code.      */
/*                                                                    */
/* DELETE THE COMMENTS ABOVE THIS LINE IN YOUR FILES!                 */
/*                                                                    */
/* Based on TEMPLATE.CMD v3.04, TEMPLATE is (c) 1996 Bernd Schemmer,  */
/* Baeckerweg 48, D-60316 Frankfurt, Germany, Compuserve: 100104,613  */
/* ------------------------------------------------------------------ */

  call trace 'off'      /* turn interactive trace off                 */

                  global. = ''  /* init the stem global. with ''      */

/*** change the following values to your need                       ***/

         global.__Version = 1.0          /* Version of YOUR program   */

       global.__SignOnMsg = 1   /* set to 0 if you do not want the    */
                                /* program start and end messages     */

         global.__NeedCID = 0   /* set to 1 if you need CID support   */

      global.__NeedColors = 1   /* set to 1 if you want colored msgs  */

  global.__NeedPatchCheck = 1   /* set to 1 if you want the program   */
                                /* to search for a patched version of */
                                /* this program                       */

              /* set default values for EXPOSELIST if necessary       */
/*             exposeList = ''                                        */

              /* name of the routine for the message handling         */
              /* Note: Use '' for hardcoded messages                  */
/*          global.__GetMsg = ''                                      */

             /* base number for the message numbers (def.: 1000)      */
/*          global.__BaseMsgNo = 1000                                 */

             /* note: set the variable prog.__STDOUT to "STDERR:"     */
             /*       or "NUL" if your program is a filter program!   */

  prog.__STDOUT = 'STDOUT'        /* necessary for Object REXX        */
  prog.__STDERR = 'STDOUT'        /* necessary for Object REXX        */

                                                                   /*!*/
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
                                                                   /*!*/

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
/*-Note:     YOU MUST FILL THIS ROUTINE WITH CODE.                    */
/*           If you want to add further global variables you SHOULD   */
/*           add them to the expose list of the procedure MAIN!       */
/*                                                                    */
Main: PROCEDURE expose (exposeList)

                        /* get the parameter of the program           */
                        /*** SUBSTITUTE template WITH THE TEMPLATE  ***/
                        /*** FOR THE PROGRAM PARAMETERS             ***/
  parse arg template

                        /* ------------------------------------------ */
                        /* you may turn some error handling off here  */
                        /* with the statement                         */
                        /*     SIGNAL OFF condition                   */
                        /* where condition is one off ERROR, SYNTAX,  */
                        /* FAILURE, NOTREADY or NOVALUE.              */
                        /* Example:                                   */
                        /* To handle returncodes not equal zero of OS */
                        /* commands in your program yourself you MUST */
                        /* use the statement                          */
                        /*     => SIGNAL OFF ERROR <=                 */
                        /* Use                                        */
                        /*     => prog.__UserAbort = 0 <=             */
                        /* to suppress CTRL-BREAK.                    */

                        /* ------------------------------------------ */
                        /* Use the function LoadDll to load all       */
                        /* necessary dlls                             */
                        /* Examples:                                  */

/*
                        /* load the dll REXXUTIL                      */
  global.__rexxUtilLoaded = LoadDll(,
     'SysLoadFuncs', ,  /* dll init function                          */
     'REXXUTIL',     ,  /* dll name                                   */
     'SysLoadFuncs', ,  /* dll init entry point                       */
     'SysDropFuncs', ,  /* dll exit function                          */
     'SysDropFuncs', ,  /* check function                             */
     1,              ,  /* 1: ignore rc of rxfuncadd (for WARP)       */
     '',             ,  /* errorcode of the init function             */
     1 )                /* 1: abort if loading failed                 */
                        /* 0: do not abort if loading failed          */
*/


/*
                        /* load the dll RXWIN30 (Quercus System)      */
  global.__rxwin30Loaded = LoadDll(  ,
                           'w_register', 'rxwin30', 'rxwindow', ,
                           'w_deRegister', 'w_open', 0, '', 0 )
*/

/*
                        /* load the dll VREXX (IBM EWS)               */
  global.__vrexxLoaded = LoadDll( 'VINIT', 'VREXX', 'VINIT', ,
                                'VEXIT', '', 1 ,'ERROR' , 0 )
*/

/*
                        /* load the dll YDBAUTIL                      */
  global.__ydbaUtilLoaded = LoadDll( 'rxydbautilinit', 'ydbautil',,
                                     'rxydbautilinit' , 'rxydbaUtilTerm' ,,
                                     'rxYdbaUtilQuery' ,1 ,'' ,1 )

*/

/*
                        /* load the dll RXU                           */
                        /* (RXU is the new name of YDBAUTIL since     */
                        /*  version 1.9)                              */
  global.__ydbaUtilLoaded = LoadDll( 'rxuinit', 'rxu',,
                                     'rxinit' , 'rxuTerm' ,,
                                     'rxuQuery' ,1 ,'' ,1 )

*/

/* ------------------------------ */


/*** INSERT THE MAIN PROGRAM CODE HERE ***/

/* ------------------------------ */

                        /* exit the program                           */
                        /* Note: The program exit code is the return  */
                        /*       code of the routine MAIN             */
                        /*       If MAIN returns nothing, the program */
                        /*       exit code is the current value of    */
                        /*       the variable "prog.__ExitCode" after */
                        /*       executing MAIN.                      */
RETURN

/* ------------------------------------------------------------------ */

/*** INSERT FURTHER SUBROUTINES HERE ***/

/*** Note: Do not forget the string 'EXPOSELIST' in the exposeList  ***/
/***       of ALL procedures!                                       ***/

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
/*-Note:     YOU SHOULD FILL THIS ROUTINE WITH CODE.                  */
/*           You may change the return code for your program in this  */
/*           routine. The default for the return code is 253.         */
/*           (The variable for the return code is prog.__ExitCode)    */
/*                                                                    */
/*                                                                    */
ShowUsage: PROCEDURE expose (exposeList)
  /*** INSERT THE CODE TO SHOW THE INVOCATION SYNTAX HERE ***/
  call log I!.__GetMsg( 14 ) || ' ' || prog.__name || prog.__DefParms
RETURN ' '                                                   /* v3.03 */

/* ------------------------------------------------------------------ */
/* NOTE: You must uncomment this routines before using them!!!        */

/*** DEBUGGING SUBROUTINES ***/

/**DEBUG** Delete this line before using the debugging routines!!!

/* ------------------------------------------------------------------ */
/* function: show all variables defined for the routine calling       */
/*           this routine.                                            */
/*                                                                    */
/* call:     ShowDefinedVariables {N}, {varMask}                      */
/*                                                                    */
/* where:    N - no pause if the screen is full                       */
/*           varMask - mask for the variables                         */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
/* note:     This routine needs the DLL YDBAUTIL or RXU.              */
/*           Be aware that the special REXX variables SIGL, RC and    */
/*           RESULT are changed if you call this routine!             */
/*                                                                    */
/*           This routine uses Dave Bolls excellent DLL YDBAUTIL      */
/*                                                                    */
/*                                                                    */
ShowDefinedVariables:
  parse upper arg SDV.__pauseMode, SDV.__varMask

                            /* test, if RXU or YDBAUTIL is accessible */
  call rxFuncDrop 'rxuQuery'
  call RxFuncAdd 'rxuQuery', 'YDBAUTIL', 'rxydbautilQuery'

  SDV.__RXUDLL = ''

                    /* install a local error handler for the DLL test */
  signal on syntax name SDV.__TryRXU
  call rxuQuery
  SDV.__RXUDLL = 'YDBAUTIL'

SDV.__TryRXU:
  if SDV.__RXUDLL = '' then
    SDV.__RXUDll = 'RXU'

                                /* install a local error handler      */
  signal on syntax name SDV.__RXUNotFound

                                /* load the necessary DLL function    */
  if RxFuncQuery( 'RxVList' ) then
    call rxFuncAdd 'RxVlist', SDV.__RXUDLL, 'RxVList'

  if RxFuncQuery( 'RxPullQueue' ) then
    call rxFuncAdd 'RxPullQueue', SDV.__RXUDLL, 'RxPullQueue'

                                /* create a queue for the variables   */
  SDV.__newQueue = rxqueue( 'create' )

                                /* the 'D' parameter of the RxVList   */
                                /* functions won't pause if the       */
                                /* screen is full                     */
  SDV.__thisRC = RxVList( SDV.__varMask, 'V' , SDV.__newQueue )

                                /* ignore local variables of this     */
                                /* routine                            */
  SDV.__thisRC = SDV.__thisRC

  call log '  ' || copies( 'Ä',76 )

  if SDV.__thisRC <> 0 then
  do

    call log '  Defined variable(s) and their values:'
    SDV.__i = 0

    do SDV.__n = 1 to SDV.__ThisRC
      if SDV.__i >= prog.__ScreenRows-2 & ,
         SDV.__pauseMode <> 'N' then
      do
        ADDRESS 'CMD' 'PAUSE'
        SDV.__i = 0
      end /* if */
      SDV.__varName = RxPullQueue( SDV.__newQueue, 'Nowait', 'SDV.__dummy' )
      SDV.__varValue = RxPullQueue( SDV.__newQueue, 'Nowait', 'SDV.__dummy' )

                                /* ignore local variables of this     */
                                /* routine                            */
      if left( SDV.__varName, 6 ) <> 'SDV.__' then
      do
        call log '     ' || SDV.__varName || ' = "' || SDV.__varValue ||,
                 '"' || screen.__AttrOff || screen.__DelEOL
        SDV.__i = SDV.__i+1
      end /* if right( ... */

    end /* do */

                        /* delete the queue for the variables         */
    call rxqueue 'Delete', SDV.__newQueue
  end
  else
    call log '  No variables defined.'
  call log '  ' || copies( 'Ä',76 )

                        /* delete local variables                     */
  drop SDV.
RETURN ' '                                                   /* v3.03 */

                        /* error exit for ShowDefinedVariables        */
SDV.__RXUNotFound:
  call ShowError global.__ErrorExitCode ,,
                 'ShowDefinedVariables: RXU and YDBAUTIL not found'
return

   Delete this line before using the debugging routines!!!    **DEBUG**/

/***        End of Part 4 of the source code of TEMPLATE.CMD        ***/
/**********************************************************************/
   
