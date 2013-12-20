/* REXX Exit for Communigate mailer OS/2 (virus scanners)     */
/*  by Steve Richards (steve@aducredit.com) September 2002    */
/*  This code  is based on the Stalker API documentation      */

/*  This will invoke Norman Virus control in the command      */
/*  line mode. It should be coded as a helper app for CGpro   */
/*  rather than an external command for the rules. (just      */
/*  like their documentation for MCaFee(r) and the API)       */

/*  Single thread probably not necessary but this is still    */
/*  not overly efficient way to do things...                  */
/*  We have low volume and it has been working fine for over  */
/*   a month. Your results may vary, but at least it could    */
/*   be used as a template...                                 */

/*  This rexx code loops forever awaiting something to become */
/*  available on STDIN. If there is nothing there we sleep    */
/*  for a second and loop again. Probably one second is too   */
/*  long (but it works OK for us), and you should write a     */
/*  program that blocks on STDIN without consuming CPU...     */

/*                                                           */
/* requires REXX2EXE to make it an EXE file                  */
/* seems CGPro doesn't like *.cmd executables                */
/* use:  REXX2EXE cgspam.cmd cgspam.exe /C /2 /K             */

/* variable declarations */
CgateAPIversion = ' version 1'
cgatexitversion = 'Version 0.1'
cgateDate = '26 September 2002'

FALSE = 0
TRUE = 1

normparm = ' /C /CP /Q /N /U /B /W:2 '
normexec = 'c:\norman\nvc\bin\nvcc.exe  '

/* Set to 1 to enable debug output */
Debug = TRUE
/* Set to 1 to enable logging */
Log = TRUE
LogFile = 'cgatexit.log'


/* The external functions we need */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* start main function */
/* This program will probably run forever and will need to be
 * reentrant for each request.
 *
 * Input is via STDIN
 * Currently must handle commands of
 *
 *      INTF (server interface version)
 *      FILE (file to process)
 *
 * This programs supports interface version 1
 *
 * Output is via STDOUT
 *
 *   Responses are
 *      OK
 *      ERROR   [text]
 *      DISCARD
 *      REJECTED [text]
 *      FAILURE
 */

call on error name ErrHandler

Do While TRUE
  cmdin = Strip(translate( LINEIN(), " ", "09"x))
  parse var cmdin  seqnum  ' ' Command ' ' filename .
      select
        when Command = "INTF" then
          do
          call send_version
          end
        when Command = "FILE" then
          do
          call run_exit
          end
        otherwise nop
        call syssleep(1)
        end   /* select */

end /* end do while */

return TRUE
/* ================================================================== */


/* ------------------------------------------------------------------ */
SEND_VERSION:
   if filename  = 1  then
      do
      rc = LineOut("STDOUT" ,  seqnum ||  ' OK' )
        return
      end
   rc = LineOut("STDOUT" ,  seqnum ||  CgateAPIversion )
   return
/* ================================================================== */


/* ------------------------------------------------------------------ */
run_exit:
   fullfile = 'c:\cgate\' || filename

   callnorm = normexec  || fullfile || normparm
   "@cmd /c " callnorm
   norman_rc  = rc
   rc = LineOut("STDOUT" ,  '*  Norman said  ' || norman_rc || ' for ' || fullfile )


   if norman_rc = 0  then
      do
      rc = LineOut("STDOUT" ,  seqnum ||  ' OK' )
      return
      end
   if norman_rc = 1  then
      do
      rc = LineOut("STDOUT" ,  seqnum ||  ' ERROR Virus Found' )
      rc = LineOut("STDOUT" ,  '*  Virus Found in message file ' || filename)
      return
      end
   if norman_rc > 1   then
      do
      rc = LineOut("STDOUT" ,  seqnum ||  ' FAILURE' )
      end
   if norman_rc = 2   then
      do
      rc = LineOut("STDOUT" ,    '*  FAILURE  Virus in Memory' )
      return
      end
   if norman_rc = 3   then
      do
      rc = LineOut("STDOUT" ,     '* FAILURE  no scanning criteria' )
      return
      end
   if norman_rc = 4   then
      do
      rc = LineOut("STDOUT" ,    '* FAILURE  Hardware changed since install' )
      return
      end
   if norman_rc = 5   then
      do
      rc = LineOut("STDOUT" ,    '* FAILURE  No valid scan criteria' )
      return
      end
   if norman_rc = 6   then
      do
      rc = LineOut("STDOUT" ,    '* FAILURE  Disk I/O error      ' )
      return
      end
   if norman_rc = 8   then
      do
      rc = LineOut("STDOUT" ,    '* FAILURE  Scan logic error    ' )
      return
      end
   if norman_rc = 9   then
      do
      rc = LineOut("STDOUT" ,    '*  FAILURE  Scan incomplete ' )
      return
      end
   if norman_rc = 10  then
      do
      rc = LineOut("STDOUT" ,    '*  FAILURE  file not accessable' )
      return
      end
   if norman_rc = 12  then
      do
      rc = LineOut("STDOUT" ,    '*  FAILURE  file NVC32.cfg missing' )
      return
      end
   if norman_rc = 13  then
      do
      rc = LineOut("STDOUT" ,    '*  FAILURE  Norman license problem' )
      return
      end

/* if something goes wrong with norman return OK to let the mail go through */
   rc = LineOut("STDOUT" ,  seqnum ||  'OK' )
   return
/* ================================================================== */


/* ------------------------------------------------------------------ */
ErrHandler:
  return
/* ================================================================== */

