/* File FTPPM_VISUAL_REXX_FRONT_END.CMD
 *
 * Synopsis:    Presentation Manager front end (through Visual REXX)
 *              for the TCP/IP file transfer program FTPPM.
 *
 * Author:      Michele Marziani
 *              Dipartimento di Fisica
 *              Universita' di Ferrara, ITALY
 *              e-mail: marziani@ferrara.infn.it
 *
 * Requirements:IBM OS/2 2.x with REXX installed
 *              IBM TCP/IP version 1.2.1 or higher (only tested with 1.2.1)
 *              IBM EWS VREXX 1.0 or higher
 *                (available via anonymous ftp from any major OS/2 archive,
 *                 e.g. ftp.cdrom.com or software.watson.ibm.com)
 *
 * Description: Are you tired of re-typing the same information at all
 *              times when FTPing to a remote host?
 *              The TCP/IP FTPPM "Remote Logon" procedure reads your
 *              NETRC file searching for "User" and "Password" for any
 *              defined host name. However you are supposed to type in
 *              the "Host" information anyway.
 *              I think this is a very annoying feature of FTPPM.
 *              This REXX procedure tries to remedy this behaviour.
 *
 *              This REXX cmd file is used to start the FTPPM program
 *              through a Presentation Manager front end. This allows
 *              the choice of a remote host entry in the TCP/IP NETRC
 *              file via a PM listbox, without any user typing.
 *
 *              One more entry is added to the listbox: "UNLISTED HOST".
 *              This allows the user to specify the name, user id (optional)
 *              and password (optional) for an host not yet defined in the
 *              NETRC file, by means of a standard PM dialog box (the
 *              password is not echoed to the screen). This behaviour is
 *              quite similar to the "Remote Logon" feature of FTPPM.
 *              If you leave the user and password fields empty, however,
 *              an anonymous ftp connection is tried with the specified
 *              host, using "os2user@host.subdomain.domain" as a password.
 *              The TCP/IP definition of "host.subdomain.domain" is
 *              automatically retrieved from information returned by the
 *              OS/2 TCP/IP command 'hostname'.
 *              
 *              This procedure expects a NETRC file in the standard format
 *              as stated in an appendix of the TCP/IP 1.2.1 manual, i.e.
 *                      machine NAME [login USER] [password PASS]
 *              I think at least both NAME and USER have to specified in
 *              order to have a reasonably automated login procedure.
 *
 * License:     This program is FREEWARE. It is donated to the public domain
 *              granted that you are not charging anything (money etc.) for
 *              it and derivates based upon it. You may freely distribute this
 *              program, provided that no changes are made to it and that the
 *              accompanying doc file FTPMRXFE.DOC is being distributed
 *              together with FTPMRXFE.CMD in the unmodified archive
 *              file FTPRXFE1.ZIP.
 *
 * Disclaimer:  The same standard disclaimers apply as for any piece of
 *              shareware/freeware software. Therefore there is no guarantee
 *              that it works without errors, etc. etc.
 *
 *              In fact this is my second REXX program in my life! All the
 *              code below was partly inspired by very useful pieces of code
 *              I've found at ftp.cdrom.com or software.watson.ibm.com
 *              (e.g. VARC10B3, ZIPENG10, VREXX TESTDLGS.CMD, etc...).
 *              Many thanks to their respective authors.
 *
 *              This program has only been tested with an 800x600 PM screen
 *              mode. So there is a chance that the program windows are not
 *              correctly positioned/displayed with different screen
 *              resolutions. However window screen positioning shouldn't be
 *              dependent on PM screen resolution. Furthermore, error checking
 *              is far from extensive. So don't blame me too much.
 *
 *              Please, if you find an error, post me a message describing it.
 *              I will try to fix and rerelease it to the net.
 *              If you can improve it, please do so. All I ask is that you
 *              drop me a note with a copy of the improvements.
 *
 *              You can contact me with suggestions or bug reports via e-mail
 *              on the Internet at 'marziani@ferrara.infn.it' or on DECnet
 *              at '39967::MARZIANI'.  Thank you.
 *
 * Revision history:
 *   v1.00: 11/11/93    Initial version (not released)
 *   v1.01: 15/11/93    Fixed bug in the NETRC file search mechanism
 *                      Improved NETRC file opening logic
 *                      Modified sign-on window font size
******************************************************************************/

'@echo off'

versionStr='v1.01'
seconds = 3                     /* Number of seconds to wait */

/*---------------------------------------------------------------------------*/
/* Load REXXUTIL and VREXX                                                   */
/*---------------------------------------------------------------------------*/
If RxFuncQuery('SysLoadFuncs') \= 0 Then
  If RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs') <>0 Then Do
    Say 'Unable to init REXX Utility function loader.'
    Exit
  End
Call SysLoadFuncs
/* register VREXX procedures as necessary */
Call RxFuncAdd 'VInit', 'VREXX', 'VINIT'
If VInit()='ERROR' Then Do
  Say 'This script requires VREXX running under OS/2 v2.x'
  Say 'If VREXX is installed on this machine, then it is likely that a prior'
  Say 'VREXX process has terminated uncleanly. Restart your computer or kill'
  Say 'the process named "VREXX" to fix this problem.'
  signal CLEANUP
End

signal on failure name CLEANUP
signal on halt name CLEANUP
signal on syntax name CLEANUP


/* open a window and draw some text */

win.left   = 25
win.right  = 75
win.top    = 60
win.bottom = 40
id = VOpenWindow('FTPMRXFE '||versionStr, 'WHITE', win)

text.1 = '       FTPPM VREXX Front End' versionStr
text.2 = ''
text.3 = ''
text.4 = '       Copyright (c) 1993 by Michele Marziani'
text.5 = '              e-mail: marziani@ferrara.infn.it'

call VForeColor id, 'BLACK'
call VSetFont id, 'TIME', 24

x = 50
y = 650
call VSay id, x, y, text.1

call VSetFont id, 'TIME', 20
do i = 2 to 5
   call VSay id, x, y, text.i
   y = y - 150
end

Call SysSleep seconds           /* allow some time for display */
Call VCloseWindow id            /* close window */


do while queued()>0             /* Clean up process queue */
  parse pull .
end

'hostname | rxqueue /fifo'      /* Query nameserver for host name */
if rc <> 0 then signal CLEANUP

do queued()                     /* Should be = 1 */
  parse pull my_host
end

my_e_mail = "os2user"||"@"||my_host

netrc_file = value('NETRC',,'os2environment')   /* Find user NETRC file */
if netrc_file = "" then
  do
    etc_dir = value('ETC',,'os2environment')    /* Find NETRC file */
    if etc_dir = "" then etc_dir="C:\TCPIP\ETC" /+ TCP/IP default  */
    netrc_file = etc_dir||"\NETRC"
  end

/* Read and parse NETRC file */

if stream(netrc_file, "c", "query exists") == "" then
  do
    say ''
    say "Can't find/open" netrc_file
    signal CLEANUP
  end

l      = 0                      /* initialize counters */
host.0 = 0
hstlen = 0

do until lines(netrc_file) = 0  /* repeat this loop until no lines   */
                                /* remain in the selected file...    */
   l = l + 1                    /* increment the line-number counter */
   line = linein(netrc_file)
   parse var line . host.l .
   hl = length(host.l)          /* find maximum host name length */
   if hl > hstlen then hstlen=hl  
end
Call LINEOUT netrc_file         /* Close the file */

/* VListBox */
l=l+1
host.l = 'UNLISTED HOST'
host.0 = l
call VDialogPos 50, 40
if VListBox('Select host name and Press OK', host, hstlen+5, 8, 3) = "CANCEL"
  then signal CLEANUP

if host.vstring = "UNLISTED HOST" then
do
  /* VMultBox */
  
  prompt.0 = 3   /* 3 prompt lines */
  prompt.1 = 'Host name'
  prompt.2 = 'User ID'
  prompt.3 = 'Password'
  
  width.0 = 3
  width.1 = 35   /* widths in character units */
  width.2 = 15   /* for entryfields */
  width.3 = 15
  
  hide.0 = 3
  hide.1 = 0     /* echo the Host name input */
  hide.2 = 0     /* echo the User ID input */
  hide.3 = 1     /* don't echo the Password */
  
  answer.0 = 3
  answer.1 = ''  /* these are the default strings */
  answer.2 = ''  /* which will contain the input */
  answer.3 = ''
  
  do while answer.1 = ''
    button = VMultBox('Input relevant data', prompt, width, hide, answer, 3)
    if button = 'CANCEL' then signal CLEANUP
    if answer.1 = '' then
    do
      msg.0 = 2
      msg.1 = ''
      msg.2 = '     Host name field cannot be empty!'
      call VMsgBox 'Warning message', msg, 1
    end
  end

  tail = answer.1

  if answer.2 <> '' then
    tail = tail || ' ' || answer.2
  else
    tail = tail || ' anonymous'

  if answer.3 <> '' then
    tail = tail || ' ' || answer.3
  else
    tail = tail || ' ' || my_e_mail
end
else    /* An existing host name has been selected from VListBox */
  tail = host.vstring

/* Now run FTPPM with proper command line*/
'start ftppm ' tail

/* end of CMD file */

CLEANUP:
   call VExit

exit
