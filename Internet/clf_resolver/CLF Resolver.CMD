/*
 * (E)CLF Host IP to Name Resolver V1.00 (REXX) - (C) Mads Orbesen Troest [SCC] 2000
 * อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
 * Cardware! If you use this tool for more than one month, please send the author
 * (me!) a local postcard with a comment! :-)
 *
 *  Address: Mads Orbesen Troest <mads@troest.dk>
 *           Valdemarsgade 6, 1.TV
 *           DK-9000 Aalborg
 *           Denmark
 *
 *  Usage: "CLF Resolver.CMD" <Input LOG File> <Output LOG File> [NoProgress]
*/

/* Nosy, eh? .-) Well, you really don't want to look at this mess... ;-) */

/* ------------------------------------------------------------------------- */

CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' /* System REXX Utilities */
CALL SysLoadFuncs

CALL RxFuncAdd 'SockLoadFuncs', 'rxSock', 'SockLoadFuncs' /* System REXX Sockets */
CALL SockLoadFuncs 'Quiet'

PARSE ARG Log.InFile Log.OutFile noProgress

SIGNAL ON HALT    NAME sigBreak
SIGNAL ON ERROR   NAME sigBreak
SIGNAL ON FAILURE NAME sigBreak

prg.Ver  = "1.00"       /* Release Version */
prg.Date = "2000-04-13" /* Release Date    */

progress.Count = 4 /* Progress Indicator Stuff */
progress.Array = "/ฤ\|"
progress.Index = 1

/* ------------------------------------------------------------------------- */

CALL prgSplash

IF Log.InFile = ""                                  THEN CALL prgError "You need to specify an Input (E)CLF log file!", 1
IF Log.OutFile = ""                                 THEN CALL prgError "You also need to specify an Output (E)CLF log file!", 2
IF Log.OutFile = Log.InFile                         THEN CALL prgError "Input and Output log files may /not/ be the same!", 3
IF STREAM( Log.InFile, 'C', 'QUERY EXISTS' ) = ""   THEN CALL prgError "Specified Input log file does not exist!", 4
IF STREAM( Log.OutFile, 'C', 'QUERY EXISTS' ) <> "" THEN SAY           "* INFO    : Output log file already exists; it will be appended..."

/* ------------------------------------------------------------------------- */

Log.Count = 0
Log.Changed = 0

RC = STREAM( Log.InFile, 'C', 'OPEN READ' )
IF RC <> 'READY:' THEN CALL prgError "Unable to open '"Log.InFile"' for input!", 5
RC = STREAM( Log.OutFile, 'C', 'OPEN WRITE' )
IF RC <> 'READY:' THEN CALL prgError "Unable to open '"Log.OutFile"' for output!", 6

Elapsed = TIME( 'R' ) /* Start Timer */
DO WHILE LINES( Log.InFile )
 IF noProgress = "" THEN CALL prgProgress Log.Count
 Log.Line = LINEIN( Log.InFile )
 Log.Count = Log.Count + 1
 CALL clfParseLine Log.Line
 IF clf.RemoteHost = "" THEN RC = LINEOUT( Log.OutFile, Log.Line ) /* Output line as it is if it is blank/unrecognised... */
 ELSE DO
  IF hostIsDotted( clf.RemoteHost ) THEN DO
   host = dnsLookup( clf.RemoteHost )
   IF host <> "" THEN DO
    Log.Changed = Log.Changed + 1
    clf.RemoteHost = host
    RC = LINEOUT( Log.OutFile, clfCreateLine() ) /* Output changed line with newly resolved host name */
   END /* IF */
   ELSE DO
    SAY "* INFO    : Unable to Resolve IP "clf.RemoteHost"..."
    RC = LINEOUT( Log.OutFile, Log.Line ) /* Output line as it is if it was not successfully resolved... */
   END /* ELSE */
  END /* IF */
  ELSE RC = LINEOUT( Log.OutFile, Log.Line ) /* Output line as it is if it does not contain dotted address to resolve... */
 END /* ELSE */
END /* WHILE */
Elapsed = TIME( 'E' ) /* Read Timer */

RC = STREAM( Log.InFile, 'C', 'CLOSE' )
IF RC <> 'READY:' THEN CALL prgError "Problems closing '"Log.InFile"'!", 7
RC = STREAM( Log.OutFile, 'C', 'CLOSE' )
IF RC <> 'READY:' THEN CALL prgError "Problems closing '"Log.OutFile"'!", 8

SAY "* INFO    : Done! Processed "Log.Count" Lines, Changed IP Address to Name of "Log.Changed"..."
SAY "            Time spent: "FORMAT(Elapsed,,1)" seconds; i.e. approx. "FORMAT(Log.Count/Elapsed,,1)" lines per second..."

EXIT 0 /* Done! */

/* ------------------------------------------------------------------------- */

prgSplash: PROCEDURE EXPOSE prg. /* Print Splash Screen */
 line = "(E)CLF Host IP->Name Resolver V"prg.Ver" (REXX) - (C) Mads Orbesen Troest [SCC] 2000"
 SAY ""
 SAY line
 SAY COPIES( 'ฤ', LENGTH( line ) )
RETURN

/* ------------------------------------------------------------------------- */

prgProgress: PROCEDURE EXPOSE progress. /* Progress Indicator (pass line # as argument) */
PARSE ARG line
 SAY SUBSTR( progress.Array, progress.Index, 1 )" "line||D2C( 27 )"[10D"D2C( 27 )"[A"
 progress.Index = progress.Index + 1
 IF progress.Index > progress.Count THEN progress.Index = 1
RETURN

/* ------------------------------------------------------------------------- */

prgError: PROCEDURE /* Error Indication/Termination Routine */
PARSE ARG msg, code
 SAY "* Error  : "msg||D2C( 7 )
EXIT code

/* ------------------------------------------------------------------------- */

clfParseLine: PROCEDURE EXPOSE clf. /* Parses CLF line (passes as argument) into global clf. stem... */
PARSE ARG logLine
 PARSE VAR logLine clf.RemoteHost clf.SystemUser clf.AuthUser '['clf.DateStamp']' '"'clf.Request'"' clf.Status clf.Bytes '"'clf.Referer'"' '"'clf.Agent'"'
 clf.RemoteHost = STRIP( clf.RemoteHost )
 clf.SystemUser = STRIP( clf.SystemUser )
 clf.AuthUser = STRIP( clf.AuthUser )
 clf.DateStamp = STRIP( clf.DateStamp )
 clf.Request = STRIP( clf.Request )
 clf.Status = STRIP( clf.Status )
 clf.Bytes = STRIP( clf.Bytes )
 clf.Referer = STRIP( clf.Referer )
 clf.Agent = STRIP( clf.Agent )
RETURN

/* ------------------------------------------------------------------------- */

clfCreateLine: PROCEDURE EXPOSE clf. /* Creates and returns CLF line from global clf. stem... */
RETURN clf.RemoteHost clf.SystemUser clf.AuthUser '['clf.DateStamp']' '"'clf.Request'"' clf.Status clf.Bytes '"'clf.Referer'"' '"'clf.Agent'"'

/* ------------------------------------------------------------------------- */

hostIsDotted: PROCEDURE /* Check if host address (passed as argument) is dotted IP. Return 1 if it is, otherwise 0... */
PARSE ARG hostAddr
 PARSE VAR hostAddr d1'.'d2'.'d3'.'d4
 IF( ( DATATYPE( d1, 'N' ) = 1 ) &  ( DATATYPE( d2, 'N' ) = 1 ) &  ( DATATYPE( d3, 'N' ) = 1 ) &  ( DATATYPE( d4, 'N' ) = 1 ) ) THEN RETURN 1 /* Numeric Address */
RETURN 0 /* Not Numeric Address */

/* ------------------------------------------------------------------------- */

dnsLookup: PROCEDURE /* Look up dotted address (passed as argument) and return name (if not resolved, return empty string)... */
PARSE ARG dotAddr
 host.!family = 'AF_INET'
 host.!port = -1
 host.!addr = dotAddr
 CALL SockGetHostByAddr host.!addr, "host.!"
 IF host.!name = "HOST.!NAME" THEN RETURN ""
RETURN host.!name

/* ------------------------------------------------------------------------- */

sigBreak: /* Unexpected Exit Handler */
 SAY "* Warning : Terminated Prematurely!"||D2C( 7 )
EXIT 10

/* ------------------------------------------------------------------------- */

/* And far off, in the distance, a dog barked... */

