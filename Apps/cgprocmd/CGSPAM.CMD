/* REXX Exit for Communigate mailer OS/2 (spam scanners)     */
/*  by Steve Richards (steve@aducredit.com) October 2002     */

/*  -----------------------------------------------------------------------  */
/* This script is based on original work by                                  */
/*                                                                           */
/* Script to call Spam Assassin from CommuniGate Pro Rules  v1.1  Ed Fang    */
/*    If you have any improvements, drop me a line at edfang@visi.net        */
/*        Thanks for Stefan Seiz for the original template                   */
/*                                                                           */
/* see SpamAssAssin CONTRIB subdirectory for shell script...                 */
/*     and CGPro rules to invoke...                                          */
/*                                                                           */
/*  -----------------------------------------------------------------------  */

/* Uses CG external progam interface rather than filter helper*/
/*                                                           */
/* requires REXX2EXE to make it an EXE file                  */
/* seems CGPro doesn't like *.cmd executables                */
/* use:  REXX2EXE cgspam.cmd cgspam.exe /C /2 /K             */
/*                                                           */
/* Also requires GNU GAWK                                    */
/* and of course SpamASSASSIN                                */
/*                                                           */

/* You also might want to single thread this                 */
/* Also Spamassassin is set to NOT go to external RBL (-L)   */


/* variable declarations */


CgateAPIversion = ' version 1'
cgatexitversion = 'Version 0.1'
cgateDate = '07 October   2002'
cgateroot = 'c:\cgate\'

/* '@set home=c:/mptn/etc/mail' */
'@set home= '

FALSE = 0
TRUE = 1
lt="<"
gt=">"
space=" "
comma=","

spamparm = '-x -e -L -a -D '  /* with spamassassin debugging */
spamparm = '-x -e -L -a  '    /* no debugging (switch order to implememt)  */
spamexec = 'c:\perllib\bin\spamassassin.cmd '

/*  headers to add to email... */
C_returnpath = 'Return-Path: '
C_envelope =   'Envelope-To: '
C_xspam   =    'X-Spam-Status: Scanner Called by ADU'

/* Set to 1/TRUE to enable debug output */
Debug = FALSE

/* Set to 1/TRUE to enable logging */
Log = TRUE
LogFile = 'c:\cgate\temp\cgspam.log'


/* The external functions we need */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* start main function */
/* This program will probably be started for each request
 *
 * Nothing  via STDIN, STDOUT
 *
 *  Command line argumemts
 *      STDERR indicator, -f filename, -p return-path, -r recipients (multiple ?)
 *      FILE (file to process)
 *
 * Output is via STDERR can be error message or spam message
 *        as it gets logged only
 *
 *   Return Code of 0 if spam  or not spam
 *                  not zero if some error
 */


   if (Log = TRUE) then do
      xx = Lineout(LogFile,"Debug display started")
       end

/* Get full passed values          */
parse arg all_args

   if (Log = TRUE) then do
      xx = lineout(LogFile, "all args is " ||  all_args)
     end

/* Parse to individual fields      */
/* spaces in literals is important */
parse var all_args std_err '-f ' filename '-p ' return_path '-r ' recipients


   if (Log = TRUE) then do
      xx = Lineout(LogFile,"Split args Follow")
      xx = lineout(LogFile, "std err  is " ||  std_err )
      xx = lineout(LogFile, "filename is " ||  filename)
      xx = lineout(LogFile, "return_path is " ||  return_path)
      xx = lineout(LogFile, "recipients are " ||  recipients)
     end



/* add meta escape characters to redirection chars in email addresses */
/* needed because we use echo command                                 */
/* we could omit ^ if we used LINEOUT                                 */
/* but we still want to go through routines because sometimes addresses */
/*  don't have the angle (<>) brackets. This way we can fix em up...    */

/* multiple return paths... */
/* handle multiple entries with or without angle brackets <> */

 temp1 = ""
  return_path=TRANSLATE(strip(return_path), space, lt )
  return_path=TRANSLATE(strip(return_path), space, gt )

 do while return_path > ""
    parse var return_path temp " "  return_path
    temp1 = temp1 || " ^<" || Temp || "^> "
  return_path=strip(return_path)
  end
 return_path = temp1


/* multiple recipients.... */
/* handle multiple entries with or without angle brackets <> */


 temp1 = ""
  recipients=TRANSLATE(strip(recipients), comma , space )
  recipients=TRANSLATE(strip(recipients), space, lt   )
  recipients=TRANSLATE(strip(recipients), space, gt   )

 do while recipients > ""
    parse var recipients  temp " "  recipients
    temp1 = temp1 || " ^<" || Temp || "^> "
    recipients=strip(recipients)
  end
 recipients = temp1



   if (Log = TRUE) then do
      xx = Lineout(LogFile,"Modified args Follow")
      xx = lineout(LogFile, "return_path is " ||  return_path)
      xx = lineout(LogFile, "recipients are " ||  recipients)
     end
/* ------------------------------------------------------------------ */

   fullfile = strip(cgateroot || strip(filename))

/* strip off the ".msg" in filename to make new file name */
   parse var filename newfile ".msg"

/* strip off the "Queue\" in filename to make new file name */
   parse var newfile junkfile "Queue\" tmpfile

/* create the new file name and the temp work file name     */
   newfile = strip(cgateroot || "Submitted\" || tmpfile || ".sub")
   wrkfile = strip(cgateroot || "Submitted\" || tmpfile || ".wrk")

   if (Log = TRUE) then do
      xx = Lineout(LogFile,"Modified filename Follow")
      xx = lineout(LogFile, "Newfile     is " ||  newfile)
      xx = lineout(LogFile, "Wrkfile     is " ||  wrkfile)
      xx = lineout(LogFile, "Filename    is " ||  filename)
     end

   rpath =  C_returnpath  ||  return_path
   envel =  C_envelope    ||  recipients

 /* For output of headers                   */
 /* we could use @del wrkfile >NUL          */
 /*           xx=LINEOUT(wrkfile, rpath)    */
 /*           xx=LINEOUT(wrkfile, envel)    */
 /*           xx=LINEOUT(wrkfile, C_xspam)  */
 /*           xx=LINEOUT(wrkfile)  (close file)  */
 /*           xx=LINEOUT(wrkfile)  (close file)  */
 /*                                              */
 /*  we choose to use echo because that is what the */
 /*  original script author used...                 */
 /*                                              */
   '@echo ' || rpath       || '   1>' || wrkfile
   '@echo ' || envel       || '  1>>' || wrkfile
   '@echo ' || C_xspam     || '  1>>' || wrkfile

 /* build first part of command string           */
   spamcmd  = '  | ' || spamexec  || spamparm

 /* gawk '/Received/, /\n/' $myCgate/$QueuePath | $spamcCommand >> /var/CommuniGate/Submitted/$NewFile  */
 /* CALLSPAM = spamexec  || spamparm || '<' || fullfile || ' >>' || wrkfile || ' 2>NUL'   */


 /* build actual command using also GNU gawk command */
   CALLSPAM = 'gawk ' || '"/Received/, /\n/ "  '  fullfile   spamcmd || ' >>' || wrkfile || ' 2>NUL'

   if (Log = TRUE) then do
     xx=lineout(LogFile)   /* *** IMPORTANT close LogFile  else sys0032 */
     CALLSPAM = 'gawk ' || '"/Received/, /\n/ "  '  fullfile   spamcmd || ' >>' || wrkfile || ' 2>>' || LogFile
     end

 /* Execute command and save return code             */
   "@call cmd /c " || CALLSPAM
   spamassassin_rc = rc

   if (Debug = TRUE) then do
       orgfile = strip(cgateroot || "Temp\" || tmpfile || ".org")
       modfile = strip(cgateroot || "Temp\" || tmpfile || ".mod")
       "@copy " || wrkfile  || " " || modfile || " >NUL"
       "@copy " || fullfile || " " || orgfile || " >NUL"
       end


 /* Rename output to filename that CGpro will pickup in the submitted subdirectory */
 /* IE. rename file from *.wrk to *.sub                                            */
   if (Log = TRUE) then do
      xx=lineout(LogFile,"@move " || substr(wrkfile,3) || " " || substr(newfile,3) || " 1>NUL 2>NUL")
      xx=lineout(LogFile)   /* *** IMPORTANT close LogFile  else sys0032 */
     "@move " || substr(wrkfile,3) || " " || substr(newfile,3) || " 1>>" || LogFile " 2>>c:\cgate\spamerr.log"
    end
        else do
     "@move " || substr(wrkfile,3) || " " || substr(newfile,3) || " 1>NUL 2>NUL"
    end


 /* Return info to CGPRO log (must set enqueuer log level to at least [low_level]) */
   if (spamassassin_rc > 0) then do
     rc = LineOut("STDOUT" ,  '*  Spam  Found in message file ' || filename)
    end
        else do
     rc = LineOut("STDOUT" ,  '*  Spam RC:' || spamassassin_rc || ' for ' || fullfile  )
     rc = LineOut("STDOUT" ,  ' with '   || wrkfile || ' to ' || newfile )
    end

 /* always return zero  */
   rc = 0
   exit 0

/* ================================================================== */

