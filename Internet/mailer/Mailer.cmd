/*----------------------------------------------------------------------------
  File:    Mailer.cmd                               Administrator: DFX Systems
                                                    Creation date:    05/09/97

  Project: <None>                                   Last update:      05/13/97
    ------------------------------------------------------------------------
    Purpose:
      This file allows PmMail to be used when replying or forwarding through
      mail in Slrn.

    ------------------------------------------------------------------------
    Notes:
      PmMail provides a utility, PmMSend.exe, that can be used to send
      e-mail messages from the command line.  It takes as parameters:

        The address of the recipient of the e-mail.
        The subject of the message.
        The name of a text file containing only the text of the message.

      The logic of this command file is simple.  It parses the first two
      header lines of the e-mail file produced by Slrn to get the recipient
      address, and the subject.  Then it skips down to the body of the
      message and writes every line of the message to a temporary file.
      Once it has these items, it uses them to call PmMSend.exe to send the
      e-mail.

    Usage:
      In the Slrn.rc file, set the sendmail_command to read as follows,
      (substituting the proper path for your system.) :

        set sendmail_command "I:/Comm/Slrn/Home/Mailer.cmd"

      In the first few lines of this program is a set up section.  Change
      the values of the variables in that section to match your system.

      That should be all you need to do.  If you have any problems or
      comments you can e-mail me at the address below:

        Mark Miesfeld
        DFX Systems
        5110 E Bellevue St #109
        Tucson AZ 85712

        miesfeld@acm.org

  ----------------------------------------------------------------------------*/

  /* - - - - - - - - - - Set up section:  - - - - - - - - - - - - - - - - - - */
  /* Drive and directory where PmMail.exe and PmMSend.exe reside.             */
  PmMailDrive = 'I:'
  PmMailDir   = '\Comm\SouthSide\PmMail'

  /* The name of the PmMail account from which the message is to be sent.     */
  MailAccount = 'MIESFEL1.ACT'
  /* - - - - - - - - End of set up section: - - - - - - - - - - - - - - - - - */

  arg FileName

  /* Do not write messages to the screen. */
  '@echo off'
  StdOut = '> nul'

  /*
   *  For some reason when Slrn passes the name of the e-mail message file,
   *  it has a leading space.  If this is not stripped off, linein() fails.
   */
  MailFile = strip( FileName )
  TempFile = GetTempFileName()

  /*
   *  Read and parse the first 2 lines to get the e-mail recipient and the
   *  message subject.
   */
  SendToLine  = linein( MailFile )
  SendTo      = strip( substr( SendToLine, 4 ) )
  SubjectLine = linein( MailFile )
  Subject     = strip( substr( SubjectLine, 9 ) )

  /*
   *  PmMSend expects only the message text in the file it is sent, it then
   *  adds its own headers.
   *
   *  Here we want to skip through the rest of the header lines and then copy
   *  only the message text to the temporary file.  A blank line separates the
   *  headers from the message text.
   */
  Line = linein( MailFile )
  do while lines( MailFile ) & Line <> ""
    Line = linein( MailFile )
  end

  do while lines( MailFile )
    rc = lineout( TempFile, linein( MailFile ) )
  end

  /* Close the files. */
  rc = lineout( MailFile )
  rc = lineout( TempFile )

  /*
   *  Save the local environment, change to the PmMail directory, use PmMSend
   *  to mail the message, then restore the environment.
   */
  rc = setlocal()
    PmMailDrive
    'cd' PmMailDir
    'pmmsend /m' TempFile '"'SendTo'"' '"'Subject'"' MailAccount StdOut
  rc = endlocal()

  /* Delete our temporary file and we are done. */
  'del' TempFile

  exit

/* End of program entry routine. */


/* - - - - - - - - - - - - - - Subroutines: - - - - - - - - - - - - - - - - - */

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*
 |  GetTempFileName()                                                         |
 |    Generates an unique, fully qualifed file name.  This is intended to be  |
 |    used as a temporary file.  If a TEMP directory is specified in the      |
 |    environment this is used for the directory.  If not, the current        |
 |    directory is used.                                                      |
 |                                                                            |
 |  Parameters on entry:                                                      |
 |    No parameters.                                                          |
 |                                                                            |
 |  Returns:                                                                  |
 |    An unique fully qualified file name.                                    |
 |                                                                            |
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
GetTempFileName:  procedure

  /* Look for one of these common environment values. */
  TEMPVAR.1 = 'TEMP'
  TEMPVAR.2 = 'TMP'
  TEMPVAR.3 = 'TMPDIR'
  TEMPVAR.4 = 'TEMPDIR'

  rc = rxfuncadd( 'SysTempFileName', 'RexxUtil', 'SysTempFileName' )

  TempDir = ''
  do i = 1 to 4 while TempDir == ''
    TempDir = value( TEMPVAR.i,, 'OS2ENVIRONMENT' )
  end

  if TempDir = '' then
    TempDir = directory()

  FileName = SysTempFileName( 'Mail??.???' )

  if right( TempDir, 1, ) = '\' then
    TempFile = TempDir ||  FileName
  else
    TempFile = TempDir || '\' || FileName

  rc = rxfuncdrop( 'SysTempFileName' )

  return TempFile

/* End GetTempFileName() */

/* - - - End Of File: Mailer.cmd  - - - - - - - - - - - - - - - - - - - - - - */
