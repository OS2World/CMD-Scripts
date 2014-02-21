
                         MCI Processor V1.00 Readme
                         ==========================

Contents
========
1. What is the MCIP package for ?
2. Install and usage of MCIP
3. Prerequisites/Restrictions/Limitations
4. Freeware license
5. Disclaimer
6. Check the archive integrity with
   Pretty Good Privacy (PGP)
7. Author




1. What is the MCIP package for ?
=================================

The MCI Processor (MCIP) provides a simple and easy to use way
of writing batch files to control multimedia devices via the
Media Control Interface (MCI).

Without this program, you would have either to write C program
s or REXX scripts, in which you would send string commands  to
the MCI. Instead, this package saves you from programming C or
REXX for this task, but instead lets you deal with the MCI
commands only.



2. Install and configure MCI Processor
======================================

The package comes with the following files

readme               - you are reading this file
file_id.diz          - package description file
mci.cmd              - The MCI Processor
                       -> place in a directory included in your
                          PATH statement
mcipm.cmd            - The "PM version" of MCI. It simply calls
                       MCI.CMD from PM REXX. This is needed for
                       playing video files.

samples\cd\*.cmd     - MCI sample files for playing audio CDs

samples\video\*.cmd  - MCI sample files for playing video files.
                       In the current version PM REXX is used to
                       display video files. This opens the PM
                       REXX console window, which currently
                       cannot be hidden. A forthcoming version
                       will include a PM interface, that does
                       not require to open an extra PM window,
                       as PM REXX does.


Copy MCI*.CMD to a directory within your PATH statement. Place
the MCI sample CMD files to a directory of your choice. Then
change to this directory (important !) and you can execute them.

  Note:
  -----

   - MCI Command Documentation
     -------------------------
     The section "Command List" of the online book MCIREXX give
     s a detailed list of the commands that you can use in MCI
     command files.
     All other programming topics (functions etc.) of this
     online book are already covered by the MCI Processor
     (MCI.CMD), so that you do not have to deal with them.

     Execute
        start view MCIREXX "Command List"
     to view this section. More, see the comments within the
     sample MCI cmd files for explanations.


   - special MCI processor commands
     ------------------------------
     Beside the MCI commands, MCI Processor implements the
     following additional commands:

     ECHO           - works like in conventional batch
                      programming except that a ^ character as
                      the last character of a line lets MCI.CM
                      D not append a CRLF, but a single space
                      character (see getvol.cmd etc)
     GOTO <label>   - works like in conventional batch
                      programming
     PAUSE          - works like PAUSE in conventional batch
                      programming except that a different prompt
                      can be specified:
                      Syntax:
                        prompt [message]

     PLAYTRACK      - plays a track.
                      Syntax:
                        playtrack <device> trackno [wait] [repeat]
     TRACE          - lets MCI.CMD display all commands on
                      execution


   - environment variables support
     -----------------------------
     More, MCI Processor also supports environment variables.
     Just enclose them with percent characters, like you do in
     conventional batch programming. In addition to the existing
     environment variables.

     MCI sets the following environment variables:

      %MCI_CALLDRIVE%  - drive of MCI source file
      %MCI_CALLDIR%    - directory of MCI source file
      %MCI_BOOTDRIVE%  - drive of OS/2 installation / bootdrive
      %MCI_MMPMDRIVE%  - drive of MMPM installation
      %MCI_MMPMDIR%    - directory of MMPM installation


   - Hints on asynchronous play
     --------------------------

     No access across session boundaries
     - - - - - - - - - - - - - - - - - -
     A multimedia device opened within one session (process)
     cannot be accessed in a separate session. So you cannot
     start play in one OS/2 window and try to stop it in anothe
     r OS/2 window. The command file being executed to stop pla
     y will report, that you are using an invalid alias, becaus
     e it is known only to the session, that the play has been
     started in.

     No asynchronous play in child processes
     - - - - - - - - - - - - - - - - - - - -
     Multimedia play requires the session to stay open, where
     the play started. This is most important if you call MCI
     command files from within WPS folders or file commander
     programs. Here batch files, which start play
     asynchronously, will do that, but after that the batch is
     finished and the session will close - and so the play will
     stop.

     If you want to start MCI command files from WPS icons or
     file commander sort of programs, you have to code these
     command files that way, that they play synchronously, that
     is, that they wait for the end of the play. The only
     drawback is, that you have no access from a program
     outside e the session anymore, and that the program in that
     session is blocked by the multimedia play. For CD play you
     can play without "wait" option and use the special MCIP
     command PAUSE, so that the session playing the CD is not
     blocked by the play, but by the keyboard, then at least the
     user can stop the play by pressing a key.

     Special Note: It seems not to be possible to play a video
     file without the "wait" option. This means that you cannot
     play video files asynchronously at all. Instead, you can
     use the OS/2 command START to start the play in a separate
     session. The only drawback is, that you cannot stop the
     play anymore, because you don't have access to a multimedia
     device opened within another session.

   - the first line of MCI cmd files must look like this
       extproc mci
     or
       extproc mcipm
     where the latter is required for playing video files.
     This tells CMD.EXE not to execute the cmd file itself, but
     instead to call an external batch processor named MCI or
     MCIPM with the name of the MCD cmd file, so that MCI.CMD
     can execute it.

   - if you do not want to use the extproc feature, you can also
     execute an mci script file with the following command
       mci <scriptfile>
     or
       mcipm <scriptfile>

     In this case you can use another filename extension than
     .CMD, and for that the file extension .MCI is recommended.

   - Due to a bug in the extproc command, an MCI command file
     executed as a .CMD file must reside in the current
     directory.

     The problem is, that EXTPROC does not report the fully
     quallified name of the .CMD file to an external batch
     processor, but only the filename without drive and path
     specification. This way MCI.CMD/MCIPM.CMD cannot find the
     script file, if it is not located in the current directory.



3. Prerequisites/Restrictions/Limitations
=========================================

This package requires the Multimedia Presentation Manager
(MMPM/2) and REXX being installed.

Note:
-----
- This package has not been tested with Object Rexx,
  but only with classic REXX. If problems occur, please
  send me a report.
- MCI scripts must reside in the current directory (EXTPROC bug)
- if you want to interrupt syncronous play, hit Ctrl-Break
  twice. This is an implementation bug in REXX, that does not
  handle Ctrl-Break properly, when an external routine (here:
  mciRxSendString) is being called. Normally one Ctrl-Break should
  be sufficient.
- Video files are being played using PM REXX.
  This opens the PM REXX console window, which currently cannot
  be hidden. A forthcoming version will include a PM interface,
  that does not require to open an extra PM window, as PM REXX
  does.



4. Freeware license
===================

This software package is freeware.
It can be used wherever you use OS/2 WARP Version 3 or later.

You are allowed to freely use and distribute MCI Processor as
long as

 -  MCI Processor is not sold as a part of another program
    package;
 -  no fee is charged for the program other than for cost of
    media;
 -  the complete package is distributed unmodified in the
    original and unmodified zip file;
 -  you send me some e-mail telling me how you liked it (or
    didn't like it), and/or your suggestions for enhancements.



5. Disclaimer
=============

Since this program is free, it is supplied with no warranty,
either expressed or implied.

I disclaim all warranties for any damages, including, but not
limited to, incidental or consequential damage caused directly
or indirectly by this software.

All software is supplied AS IS. You may use the MCI Processor
package only at your own risk.

MCI Processor must not be used in states that do not allow the
above limitation of liability.



6. Check the archive integrity with
   Pretty Good Privacy (PGP)
===================================

On my homepage I provide a detached signature certificate,
with which you can verify, that you downloaded an unmodified
version of this archive.

See my web pages also
- for links to PGP sites, where you can obtain further
  information on what PGP is and how you can install and use it
  under OS/2
- a manual for how to use PGP for the usage of such signature
  certificates.

See section "Author" for the location of my homepage.



7. Author
=========

This program is written by Christian Langanke.

You can contact the author via internet e-mail.

Send your email to C.Langanke@TeamOS2.de

You can also visit my home page and download more free OS/2
utilities at:

     http://www.online-club.de/m1/clanganke

