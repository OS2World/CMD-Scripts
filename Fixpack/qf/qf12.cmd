/* ------------------------------------------------------------------------
        QuickFix.cmd            (originally DiskFP.cmd)

        A fast and safe way to apply OS/2 fixpacks.

        Jon Saxton
        August 1998


        External utilities which may be required by this program:

                dskxtrct.exe    dskxtr12.zip
                                Alan Arnett

                unzip.exe       unzip531.zip    (Not required by current
                                Info-Zip         fixpack methods)

-----------------------------------------------------------------------------

        DISKFP.CMD to loaddskf and xcopy fixpack disks.

        This command file written by Trevor Hemsley 1st March 1997.

        All responsibility for the use of this command file lies with
        the user.  No guarantee is made that it will work correctly.
        I am not responsible for any damage that may be caused to your
        system by use of this command file nor by any fixpack you may
        apply to your system using it.

-----------------------------------------------------------------------------

        Amended 5th September 1997 by Jon Saxton

        1.  Allow use of a floppy drive other than A: (very handy if
            you have a "virtual" floppy drive installed, e.g. SVDISK
            or VFDISK)

        2.  Don't complain if user types D: instead of just D for the
            name of the drive to be serviced.

        3.  Allow re-use of an archive directory so long as it is
            empty.

        4.  Allow for non-US fixpack editions.

        5.  Changed all the "@echo" commands to lineout() calls to save
            invoking cmd.exe repeatedly.

-----------------------------------------------------------------------------

        Amended 14th December 1997 by Jon Saxton

        1.  Cater for recent diskette images in the patch set which have
            EA DATA. SF files causing spurious XCOPY failures.

        2.  Took a "guess" at the partition to be serviced.

-----------------------------------------------------------------------------

        Amended 11th June 1998 by Jon Saxton

        1.  Allow . or other partial specification for source and
            destination directories.

-----------------------------------------------------------------------------

        Amended 7th July 1998 by Jon Saxton

        Trevor had a strong objection to the use of programs other than
        loaddskf to unpack diskette images because none of those programs
        did any error checking.  Now, Alan Arnett has released a new
        edition of his extractor program (dskxtrct) which performs CRC
        validation of the diskette image files so Trevor's objections are
        satisfied.

        diskfp has now been amended so that if you do NOT specify a floppy
        drive then it will use dskxtrct to unpack the diskette images.
        This means that if you really want to use loaddskf via the A: drive
        then you must specify it.

-----------------------------------------------------------------------------

        Amended 4th September 1998 by Jon Saxton

        1.  At Trevor Hemsley's suggestion, this program has been renamed
            and is now supported by me, leaving Trevor's original alone.

        2.  Beginning with fixpack 7 for OS/2 4.0 and whatever the corres-
            ponding fixpack is for OS/2 3.0, the fixpack application software
            changed.  Earlier versions supplied FSERVICE.EXE as part of a
            bootable pair of "kicker" diskettes but now the user is expected
            to provide his own boot facilities and the service tools are being
            distributed as a self-extracting archive.  I have now modified the
            routine which does the image unpacking to handle .EXE and .ZIP
            files.

-----------------------------------------------------------------------------

        Amended 10th September 1998 by Jon Saxton

        1.  It is no longer necessary to specify the destination fixpack
            directory.  If you don't specify it then this program will use
            qfos2 on some local drive.  There is a semi-smart algorithm to
            decide which drive to use.  (Remember that the source directory
            doesn't have to be fully specified; a dot is sufficient if you
            are running this program from the fixpack source directory.)

        2.  The program will now construct archive directories as deeply-
            nested as you wish.

-----------------------------------------------------------------------------

        Amended 11th September 1998 by Jon Saxton

        Previous versions wrote the disk extraction log file to the source
        directory.  That wasn't such a good idea because the source might
        well be a CD or other read-only drive.  This version writes the log
        file to the destination directory.

-----------------------------------------------------------------------------

        Amended 21st September 1998 by Jon Saxton

        During beta testing one user reported problems when the fixpack
        was applied from a partition with a large amount of free space.
        I don't really know why this should cause a problem but I have
        changed the drive free space calculation to ignore drives with
        more than 2 gigabytes of free space unless no other drive has
        sufficient space.

-----------------------------------------------------------------------------

        Amended 23rd September 1998 by Jon Saxton

        Look for artefacts of a prior fixpack application and warn the
        user that there may be a problem.

-----------------------------------------------------------------------------

        Amended 6th October 1998 by Jon Saxton

        1.  Added commentary to the generated "apply.cmd" in the hope
            of reducing confusion.

        2.  Tried to accommodate OS/2 3.x fixpack application.

-----------------------------------------------------------------------------

        Jon Saxton, latter part of November 1998

        Allowed extraction and script preparation in spite of uncommitted
        fixpacks.  This relaxes a restriction introduced on 23/9/98.

        Allowed re-use of archive directory (with appropriate warning.)

        Included w.cmd by Peter Flass to handle quoted arguments.

-----------------------------------------------------------------------------

        7 Dec 98 Jon Saxton

        Tried to keep my sights on the ever-moving "fix tools" target.

-----------------------------------------------------------------------------

        10 Dec 98 Jon Saxton

        Yet more improvements to the user interface.  Default answers to
        prompts are now pre-filled on the screen and editing is allowed.
        With this mechanism in place I was able to simplify the prompts
        and explanations considerably.

        (All this with thanks to Albert Crosby <acrosby@comp.upark.edu>
        for his "CmdLine" editing code.)

-----------------------------------------------------------------------------

	Ultima modifica fatta -->  Luned 2 Marzo 1999, alle 23:20.   a.s.

	Added -o (overwrite) flag to unzip command.
	Added cs*.zip to the fixpack tools search list.
	Changed fixtools version number from 139 to 140.  (This is a
		cosmetic change only - the program will find the fixtools
		regardless of the version number.)

-----------------------------------------------------------------------------

	7 April 99 Jon Saxton

	1.  Changed the processing sequence so that all tests are done before
	    any directories or files are created or destroyed.  The idea is
	    that if you abort the fixpack installation then there should be
	    nothing to clean up.

	2.  Allow the use of SERVICE.EXE for controlled application.  That
	    program allows you to choose whether or not to overlay files
	    which are newer than those being applied from the fixpack
	    distribution on a file-by-file basis.

	3.  Added the option to keep newer files during unattended fixpack
	    application.  Note that in unattended mode this choice cannot
	    be offered for individual files.

-----------------------------------------------------------------------------

	1.2 preview release - 12 July 1999 Jon Saxton

	Congratulations to the US & Chinese Women's Soccer Teams.  Tough,
	exciting final game.  Pity there could only be one winner.

	1.  This is an incomplete release of version 1.2 which fixes a
	    bug in 1.1 where the archive directory name is not filled in
	    correctly when you run this program twice.

-----------------------------------------------------------------------------

	1.2 General Release - 10 November 1999 Jon Saxton

	1.  Option to use GUI fix tool (SERVICE) instead of the text mode
	    tool (FSERVICE).

	2.  Option to selectively specify whether newer files should be
	    overwritten by the corresponding fixpack files.  (This only
	    applies to text mode application as the GUI tool always prompts
	    for permission.)

	3.  Option to invoke FSERVICE automatically if booted from a
	    partition other than the one to be serviced.

-----------------------------------------------------------------------------

	1.2.1 Bug fix - 17 November 1999 Jon Saxton

	A space was missing in the UNZIP command which was issued if you
	used csf141.zip rather than cs_141.exe.

--------------------------------------------------------------------------- */

dull = 0
bright = 1
black = 0
red = 31
green = 32
yellow = 33
blue = 34
magenta = 35
cyan = 36
white = 37

/* Get the name of the command file which was just invoked.  (Allows for
   renaming this program to "qf" or something like that.  */

parse source . . program
here = lastpos(".", program) - 1
program = left(program, here)
here = lastpos("\", program) + 1
program = substr(program, here)

do while queued() > 0
  pull .
end
/* ....................................................................
   This code may not work on non-English systems so I'll leave it out
   for now on the assumption that most people leave ANSI controls on.
"@ansi | rxqueue /fifo"
parse pull . . . . . . . ansiState "."
if translate(ansiState) ช= "on" then
  "@ansi on >nul"
  ................................................................... */

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

here = directory()

/* 24-11-98 */
parse arg cmdLine     /* Get source and target dirs and optional floppy for
                         intermediate storage */
src  = w(cmdLine, 1)
dest = w(cmdLine, 2)
if compound(src) | compound(dest) then
  do
    call error "Please use simple directory names."
    call syntax
    exit
  end

flop = w(cmdLine,3)

if src = "" then                /* If no source specified */
  do
    call error "No source directory specified."
    call syntax                 /* then complain, explain and exit. */
    exit
  end

say "      "colour(bright,cyan,bg(blue))"ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"colour(dull)
say "      "colour(bright,cyan,bg(blue))"บ QuickFix 1.2.1 by Jon Saxton <triton@attglobal.net> 17 Nov 99 บ"colour(dull)
say "      "colour(bright,cyan,bg(blue))"บ           Derived from diskfp.cmd by Trevor Hemsley           บ"colour(dull)
say "      "colour(bright,cyan,bg(blue))"บ               Uses dskxtrct.exe by Alan Arnett                บ"colour(dull)
say "      "colour(bright,cyan,bg(blue))"ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"colour(dull)
say

/* Expand source directory */
there = directory(src)
if there = "" then              /* source directory doesn't exist */
  do
    call directory here
    call error "The specified source directory does not exist."
    exit
  end
else
  src = there

/* Normal use of this program would be for a user to specify a source
   directory only.  Less frequently the user might specify a destination
   directory.  Even more rarely, a floppy drive might be specified.  It
   is conceivable that the user could specify a floppy drive but not a
   destination directory.  It costs little to check ... */

if (flop = "") & (dest ช= "") then
  if (length(dest) = 2) & datatype(left(dest,1),"Mixed case"),
                          & right(dest,1) = ":" then
    do
      flop = dest
      dest = ""
    end

if dest = "" then               /* if no destination specified */
  do
    /* Find the drive with the most free space */
    drives = SysDriveMap("c:", "local")
    maxDrive = ""
    MaxSpace = 0
    bigSpace = 0
    do while drives <> ""
      parse var drives drive drives
      info = SysDriveInfo(drive)
      parse var info . freeSpace .
/*    say drive freespace    */
      if freeSpace > maxSpace then
        if freeSpace < 1024*1024*1024*2 then
          do
            maxDrive = drive
            maxSpace = freeSpace
          end
        else
          do
            bigDrive = drive
            bigSpace = freeSpace
          end
    end
    if (maxSpace < 30*1025*1024) & (bigSpace > 0) then
      maxDrive = bigDrive
    dest = maxDrive"\qfos2"
    say colour(bright,yellow)
    say "This program unpacks the diskette images and writes a set of patch files and"
    say "scripts for applying the patches.  Where should the patch files be put?"
    say
    drive = gets(dest, 73)
    dest = drive
  end

/* New code added 9-Oct-99 to allow SERVICE instead of FSERVICE */

serviceMethod = 1
answer = "."
do while answer = "."
  say colour(bright,cyan)
  say "Please read this carefully ..."
  say colour(yellow)
  say "Sometimes fixpacks contain files which are older than the corresponding files"
  say "on your system.  This can happen if you have applied device drivers or other"
  say "system software since OS/2 was installed.  Anyway there are two ways to deal"
  say "with them: you may allow all such files to be overwritten unconditionally or"
  say "or for each file you may specify whether or not it should be overwritten."
  say "Please select one of the following ..."
  say
  say "  1   Automatic fixpack application, overwriting newer files"
  say "  2   Interactive fixpack application with full control (text mode)"
  say "  3   Interactive fixpack application with full control (GUI)"
  say
  answer = gets(serviceMethod, 1)
  if answer = "" then
    exit
  if (answer = '1') | (answer = '2') | (answer = '3') then
    serviceMethod = answer
  else
    answer = "."

  if (serviceMethod = 3) then
    do
      uv = value("csfUtilPath",dest,"os2environment")
      uv = value("csfCdromDir",dest,"os2environment")
      uv = unpacker()
      if uv then
        do
          uv = "'"dest"\service'"
          interpret uv
        end
      exit
    end
end

bootDrive = left(value("system_ini",,"os2environment"), 1)

say colour(bright,yellow)
say "Enter the drive letter of the OS/2 boot partition you want serviced."
say
answer = gets(bootDrive,1)

if length(answer) = 0 then
  exit
if answer = "" then
  exit

map = SysDriveMap(answer, "LOCAL")  /* and check it exists */
if substr(map, 1, 1) ช= answer then /* if not first character of return */
  do
    say
    call error "Invalid drive specified"
    exit
  end

syslevelfile = answer":\os2\install\syslevel.os2" /* set up filename */
driveletter = answer                  /* save the drive letter for later */

/*
   If the boot drive and the drive to be serviced are different then we can
   offer the user the option of running the fixpack application automatically
   if everything else goes according to plan.
*/

if translate(driveLetter) = translate(bootDrive) then
  autoApply = 0
else
  autoApply = 1

rrc = SysFileTree(syslevelfile, syslf., "FO")   /* check syslevel exists */
if syslf.0 = 0 then                             /* if not */
  do
    call error "File" syslevelfile "does not exist"
    exit
  end

arc = artefacts(driveletter)
if arc = "" then
  arc = driveletter":\ArchOS2"

say colour(bright,yellow)
say "The fixpack applicator will want to make an archive of those system files"
say "which it replaces with new versions."
say
say "In which directory should the archived files be placed?"
say

do until arcOK = "Y"
  answer = gets(arc,73)
  if answer = "" then
    return
  arc = answer

  rrc = SysFileTree(arc, arcdir., "D")   /* See if directory exists */
  /* say "Existence test:- arcdir.0="arcdir.0 */
  if arcdir.0 > 0 then                   /* It exists but may contain files */
    rrc = SysFileTree(arc"\*", arcdir., "FO")
  /* say "Occupancy test:- arcdir.0="arcdir.0 */
  if arcdir.0 = 0 then                   /* Doesn't exist or is empty */
    do
      rc = makeDirectory(arc)
      if rc = 0 then
        do
          call directory here
          dir = directory(arc)
          arc = dir
          call directory left(dir,3)
          call directory here
          drive = left(dir, 2)
          driveinfo = SysDriveInfo(drive)
          freespace = word(driveinfo, 2)
          if freespace < 20000000 then
            do
              say colour(bright,yellow)
              say "There may not be enough free space on drive"colour(cyan) drive colour(yellow)"for archive files."
              rrc = SysRmDir(arc)
              say colour(bright,yellow)"Please respecify"
            end
          else
            arcOK = "Y"
        end
      else
        do
          call error "Error" rc "making directory" arc
          say colour(bright,yellow)"Please respecify"
        end
    end
  else
    do
      say
      call warning "Archive directory isn't empty."
      say colour(bright,yellow)
      say "You've specified"colour(cyan) arc colour(yellow)"as the archive directory but it"
      say "contains files, presumably from an earlier fixpack application."
      say
      say "This might be OK if you are re-applying a current fixpack.  For example, you"
      say "may have added a new component and want to bring it up to the same fixpack"
      say "level as the rest of your system.  Under other circumstances you should not"
      say "re-use the same archive directory."
      say
      say "Do you really want to use"colour(cyan) arc||colour(yellow)"? (Y/N)"
      arcOK=gets(,-1)
      if arcOK ช= "Y" then
        do
          say colour(bright, yellow)
          say "Please specify a different archive directory. (Empty to quit)"
        end
    end
end

rc = unpacker()
if rc = 0 then
  exit

/* Set up the response file to apply the fixpack to drive given */

ff = dest"\apply.fil"
call lineout ff, ":LOGFILE "driveletter":\OS2\INSTALL\SERVICE.LOG", 1
if serviceMethod = 1 then
  replacement = "REPLACE_NEWER"
else
  replacement = ""

call lineout ff, ":FLAGS REPLACE_PROTECTED" replacement
call lineout ff, ":SOURCE" dest
call lineout ff, ":SERVICE"
call lineout ff, ":SYSLEVEL" syslevelfile
call lineout ff, ":ARCHIVE" arc
call lineout ff

/* Set up response file to back out fixpack from the drive specified */

ff = dest"\backout.fil"
call lineout ff, ":LOGFILE" driveletter":\OS2\INSTALL\SERVICE.LOG", 1
call lineout ff, ":TARGET ARCHIVE"
call lineout ff, ":BACKOUT"
call lineout ff, ":SYSLEVEL" driveletter":\OS2\INSTALL\SYSLEVEL.OS2"
call lineout ff

/* Set up command files to apply and backout fixpack */

ff = dest"\apply.cmd"

call lineout ff, "@echo Hit Ctrl-Break when you see the prompt to hit Ctrl-Alt-Del", 1
call lineout ff, "@echo then shut down and reboot if you're running from a maintenance"
call lineout ff, "@echo partition or type 'exit' if you're working from an Alt-F2 full-screen"
call lineout ff, "@echo session."
call lineout ff, "@pause"
call lineout ff, "fservice /s:"dest "/r:"dest"\apply.fil /L1:"driveletter":\os2\install\service.log"
call lineout ff

ff = dest"\backout.cmd"
call lineout ff, "@echo Hit Ctrl-Break when you see the prompt to hit Ctrl-Alt-Del", 1
call lineout ff, "@pause"
call lineout ff, "fservice /s:"dest" /r:"dest"\backout.fil /L1:"driveletter":\os2\install\service.log"
call lineout ff

say
call banner "Fixpack preparation is complete."
say colour(bright,yellow)

if autoApply then
  do
    say
    say "Since you are running on a different partition from the one to be serviced"
    say "you can apply the fixpack right now.  Is that what you'd like to do? (Y/N)"
    answer=gets(,-1)
    say colour(bright,yellow)
    if answer ช= "Y" then
      do
        say "OK, you can apply the fixpack yourself.  Change to directory" colour(cyan)dest||colour(yellow)
        say "and issue the command"colour(cyan) "APPLY" colour(yellow)"to apply the fixpack or"colour(cyan) "BACKOUT" colour(yellow)"to back it out."
        exit
      end
    else
      do
        say "The fixpack application program will run in full-screen mode.  When it is"
        say "finished it'll tell you to reboot with Ctrl-Alt-Del.  Don't do that.  Press"
        say "Ctrl-C or Ctrl-Break instead to get back to this session."
        say
        say "Continue? (Y/N)"
        answer = gets(,-1)
        if answer ช= "Y" then
          exit
        call directory dest
        "fservice /s:"dest" /r:"dest"\apply.fil /L1:"bootDrive":\os2\install\service.log"
        call banner "Done"
        exit
      end
  end

say "Now reboot to a command line using Alt+F1 option F2 (or boot from a main-"
say "tenance partition if you have one), change to the directory"colour(cyan) dest||colour(yellow)
say "and issue the command"colour(cyan) "APPLY" colour(yellow)"to apply the fixpack or"colour(cyan) "BACKOUT" colour(yellow)"to back it out."
say
say "Please make sure that you have previously read the various"colour(white) "README" colour(yellow)"files that"
say "are now in the directory" dest "as these may contain important information"
say "from IBM about problems that you may encounter after applying this fixpack."

exit

/* ----------------------------------------------------------------------------

				unpacker

	This subroutine unpacks the fixpack and the service tools.

 --------------------------------------------------------------------------- */

unpacker:

if flop ช= "" then
  do
    say
    say "Please make sure there is a 1.44Mb diskette in drive" flop
    say "This diskette will be overwritten, is this OK? - Y/N"
    say
    answer = gets(,-1)
    if answer ช= "Y" then
      return 0
  end

rrc = SysFileTree(dest, files., "D")
if files.0 = 0 then
  do
    say colour(bright,yellow)
    say "Destination directory"colour(cyan) dest colour(yellow)"does not exist.  Should I create it?"
    answer = gets(,-1)
    if answer ช= "Y" then
      return 0
    rrc = makeDirectory(dest)
    if rrc ช= 0 then /* directory creation failure */
      do
        say
        call error "Error" rrc "creating fixpack directory" dest
        return 0
      end
  end
else
  do
    rrc = SysFileTree(dest"\*", files.)
    if files.0 > 0 then
      do
        say
        call warning "Patch directory isn't empty"
        say colour(bright,yellow)
        say "Directory"colour(cyan) dest colour(yellow)"exists and contains files."
        say
        say "It is likely that some of those files will be overwritten.  There is no real"
        say "problem with that unless you have something in there that you really want to"
        say "keep."
        say
        say "Continue, using" colour(cyan)dest colour(yellow)"? (Y/N)"
        answer = gets(,-1)
        if answer ช= "Y" then
          return 0
      end
  end

/* 11-Jun-98: Expand source and destination directory to full specification */
call directory here
call directory dest
dest = directory()
call directory here

filemask = src || "\xr?m*.?dk"  /* file mask for fixpack diskette images */
rrc = SysFileTree(filemask, srcdisk., "FO")   /* check in source dir for them */

if srcdisk.0 = 0 then
  do
    /* Perhaps this is an OS/2 3.0 update.  There's no point checking the
       OS/2 version number because the preparation run could be executing
       under OS/2 4.0 */
    filemask = src || "\xr?w*.?dk" /* Mask for OS/2 3.x fixpack files */
    rrc = SysFileTree(filemask, srcdisk., "FO")
  end

/* (There might be a more generic way to do the foregoing tests, perhaps
    by using a mask of src || "\xr*.?dk" and testing what comes back.) */

if srcdisk.0 = 0 then                         /* if none there */
  do
    call error "Source directory contains no fixpack diskette images"
    return 0
  end

logfile = dest"\dskxtrct.log"
if stream(logfile, 'C', "query exists") ช= "" then
  call SysFileDelete logfile

/*
   unpackImage can tell whether it is extracting to floppy or not but
   we need to check here to determine what we need to pass in as a source
   parameter, i.e., whether to loop through the individual files or just
   pass the file mask ...
*/
if (flop = "") then                  /* all at once */
  call unpackImage filemask logfile flop dest
else
  do i = 1 to srcdisk.0 by 1         /* otherwise loop for # of files */
    call unpackImage srcdisk.i logfile flop dest
  end

fixtool = fixtools(src, maskTable)
call unpackImage fixtool logfile flop dest /* just one file this time */
return 1

/* --------------------------------------------------------------------------

        Get user input.

  -------------------------------------------------------------------------- */
gets: procedure expose dull bright black red green yellow blue magenta cyan,
                      white
  parse arg prefill, width
  if width = "" then
    width = 0
  if width < 0 then
    do
      auto = "Auto"
      width=-width
    end
  else
    auto = ""
  if width = 1 then
    upper="U"
  else
    upper = ""
  if prefill ช= "" then
    prefill="P="prefill
  call charout ,colour(dull,bright,green)d2c(16)d2c(16)d2c(16)
  parse value SysCurPos() with y x
  a = cmdline("Tag="colour(white,bg(blue)),prefill,"Same","Off","W="width,auto,upper)
  call SysCurPos y,x
  say colour(dull,bright,white)d2c(27)"[K"a
  return a

/*-----------------------------------------------------------------------------

        Display a brief description of how to use this program.

-----------------------------------------------------------------------------*/

syntax:
say colour(bright, yellow)
say "Command syntax is:"
say
say "    "colour(cyan)program" source_dir "colour(yellow)"["colour(cyan)"destination_dir"colour(yellow)"] ["colour(cyan)"floppy_drive"colour(yellow)"]"
say
say "where"
say
say "    "colour(cyan)"source_dir"colour(yellow)" is a directory containing the diskette image files for the fix-"
say "        pack.  This should contain all of the fixpack diskette images and the"
say "        fix tools distribution (e.g. "colour(white)"fixt139.exe"colour(yellow)" or later)."
say "        A dot (.) will suffice if you're running from the source directory."
say
say "    "colour(cyan)"destination_dir"colour(yellow)" is the directory where the fixpack files will be copied,"
say "        ready to be applied to the system.  This parameter is optional and if"
say "        you omit it then the program will offer a default which you can accept"
say "        or override."
say
say "    "colour(cyan)"floppy_drive"colour(yellow)" is optional and can be a real or virtual floppy.  If you don't"
say "        specify it then a fast unpack program ("colour(white)"dskxtrct"colour(yellow)") will be used."colour(dull)
return

/*-----------------------------------------------------------------------------

        Display a string in a coloured box.  Used for short messages.

-----------------------------------------------------------------------------*/

warning: procedure expose dull bright red green yellow blue magenta cyan,
                      white
  parse arg string
  call box yellow string
  return

error: procedure expose dull bright red green yellow blue magenta cyan,
                      white
  parse arg string
  call box red string
  return

banner: procedure expose dull bright red green yellow blue magenta cyan,
                      white
  parse arg string
  call box green string
  return

box: procedure expose dull bright red green yellow blue magenta cyan white
  parse arg bed string
  blanks = left("                                     ", 38-(length(string)+1)%2)
  say blanks||colour(bright,bed,bg(bed))space("ฺ ฟ", length(string)+2, "ฤ")colour(dull)
  say blanks||colour(bright,bed,bg(bed))"ณ"colour(white) string colour(bed)"ณ"colour(dull)
  say blanks||colour(bright,bed,bg(bed))space("ภ ู", length(string)+2, "ฤ")colour(dull)
  return

/*---------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------

        unpackImage

        To present a uniform calling sequence to the main program, this
        routine is intended to handle all types of source diskette images
        and unpacking methods but at the moment only the following are
        handled:

            Image type                      Unpacking method
            ----------                      ----------------
                .DSK (and variants)             DSKXTRCT or LOADDSKF
                .EXE                            run program
                .ZIP                            UNZIP

        New methods will be added should the need arise.

        DSKXTRCT and UNZIP are the only extractors which can handle wildcards.

-----------------------------------------------------------------------------*/

unpackImage: procedure expose dull bright red green yellow blue magenta cyan,
                              white

  parse arg imageFile logFile flop dest

  if dest = "" then
    do
      dest = flop
      flop = ""
    end

  /* Look at the file extension. */
  ext = translate(right(imageFile,3))   /* good enough for our purposes */
  select
    when ext = "ZIP" then
      do
       'unzip -uo' imageFile '-d' dest      /* a.s. 02/Mar/1999 */
        return
      end
    when ext = "EXE" then
      do
        imageFile dest
        return
      end
    otherwise
      nop
  end

  program = "LOADDSKF"

  if flop = "" then
    do
      program = "DSKXTRCT"

      /* First pass, do CRC validation only. */
      say
      say colour(bright,cyan,bg(blue))"Performing checksum validation"colour(dull)
      "dskxtrct /s:"imageFile "/l:"logFile "/crc /la"
      if rc ช= 0 then
        do
          call error "CRC error(s) detected."
          say colour(dull,bright,yellow)
          say "Continue anyway?  (Not recommended)"
          answer = gets(, -1)
          if answer ช= "Y" then
            exit
        end
      say
      say colour(bright,cyan,bg(blue))"Extracting files from diskette images"colour(dull)
      "dskxtrct /s:"imageFile "/t:"dest "/l:"logFile "/la /ra"
    end
  else
    "loaddskf" imageFile flop "/F /Y"
  if rc ช= 0 then
    do
      call error program "returned a non-zero result ("rc")."
      say colour(dull,bright,yellow)
      say "Continue anyway?  (Not recommended)"
      answer = gets(, -1)
      if answer ช= "Y" then
        exit
    end
  say
  if flop ช= "" then
    do
      say colour(bright,white,bg(blue))
      say "XCOPY contents of" imageFile "in progress"colour(dull)

      "@xcopy" flop dest "/h/o/t/s/e/r/v 2>&1 | rxqueue /fifo"

      realError = 0
      second = 0

      if rc = 0 then
        do while queued() > 0
          pull .
        end
      else
        do while queued() > 0
          parse pull v
          if second then
            do
              if right(v, 11) ช= "EA DATA. SF" then
                realError = 1
              second = 0
            end
          else
            if left(v, 8) = "SYS1186:" then
              second = 1
        end

      if realError then
        do
          call error "XCOPY returned a non-zero result ("rc")."
          say colour(dull,bright,yellow)
          say "Continue anyway?  (Not recommended)"
          answer = gets(, -1)
          if answer ช= "Y" then
            exit
        end
    end
  return

/*-----------------------------------------------------------------------------

        artefacts()

        Poke around and see if there is anything left over from a previous
        fixpack application and if so then let the user know.

-----------------------------------------------------------------------------*/

artefacts: procedure expose dull bright red green yellow blue magenta cyan,
                              white
  parse arg drive .
  logMask = drive":\os2\install\log*.os2"
  call SysFileTree logMask, files., "FO"
  if files.0 = 0 then /* nothing to report */
    return ""
  /*
     At least one log file was left over from a previous fixpack.  See if
     we can find the archive directory.

     As far as I can tell:-
	LOGF0000.OS2 and LOGSTART.OS2 are identical,
	Archive directory is stored at offset 1A7 (423),
	Backup directory is not recorded.
  */
  arcDir = ""
  c = charin(files.1, 424, 1)
  do while c2d(c) ช= 0
    arcDir = arcDir||c
    c = charin(files.1,,1)
  end
  call stream files.1, 'C', "close"

  /* Now see if the archive directory exists. */
  here = directory()
  there = directory(arcDir)
  call directory here

  arcKilled = 0
  if there = "" then /* archive directory has been deleted */
    arcKilled = 1
  else               /* directory exists but may be empty */
    call SysFileTree arcDir"\*", files., "FO"
    if files.0 = 0 then
      arcKilled = 1

  call warning "Artefacts found from a previous fixpack."

  if arcKilled then
    do
      say colour(bright,yellow)
      say "You have log files left over from a previous fixpack but I cannot find the"
      say "archive files.  This will cause problems when you apply the current fixpack"
      say "and you need to delete the log files beforehand.  You can do it yourself or"
      say "I can do it for you now.  Should I delete the old log files? (Y/N)"
      answer = gets(,-1)
      if left(answer,1) = 'Y' then
        call deleteFiles logMask
      else
        do
          say colour(yellow)
          say "OK, I left the log files there for you to delete.  Look for files matching"
          say colour(cyan)||logMask||colour(yellow)".  One or more may be marked read-only."
          say
          say "You'll need to dispose of these files before applying the fixpack."
          say
          say "Press the Enter key ..."
          answer = gets()
        end
    end
  else
    do
      say colour(bright,yellow)
      say "You seem to have an uncommitted fixpack from a prior update with archives in"
      say "directory" colour(cyan)||there||colour(yellow)"."
      say
      say "I can clean everything up for you but if I do so then there'll be no way for"
      say "you to back out of that old fixpack.  (You'll still be able to back out of"
      say "the new fixpack and revert to your current system.)"
      say
      say "Do you want me to get rid of the old fixpack archives? (Y/N)"
      answer = gets(,-1)
      if answer = 'Y' then
        do
          call deleteFiles there"\*"
          call deleteFiles logMask
        end
      else
        do
          say colour(bright,yellow)
          say "At this point the normal procedure for me would be to stop.  You'd then take"
          say "the steps necessary to clean up your system before re-running this program."
          say
          say "However I can go ahead and prepare the patch files if you like.  It isn't"
          say "usually recommended, but if you know what you are doing then it might be"
          say "worthwhile.  For example, you might want the" colour(white)"BACKOUT"colour(yellow) "script which is generated"
          say "as a side-effect of the fixpack preparation, or you might be regenerating the"
          say "patch files to reapply a fixpack to a newly-installed component."
          say
          say "So, do you want me to go ahead and prepare for the new fixpack application"
          say "even though there's something of a mess left over from the last one? (Y/N)"
          answer = gets(,-1)
          if answer ช= 'Y' then
            do
              call error "Commit the old fixpack and re-run this program."
              exit
            end
        end
    end
  return there

/*--------------------------------------------------------------------------*\

        Check for existence of files conforming to a variety of patterns.
        Return the (first) pattern which matches any extant files.

\*--------------------------------------------------------------------------*/

fixtools: procedure expose dull bright red green yellow blue magenta cyan,
                              white

parse arg src .

i = 0
maskTable.0 = 0
i = i+1; maskTable.0 = i; maskTable.i = "fixt*.exe"; fn.i = "fixt140.exe"
i = i+1; maskTable.0 = i; maskTable.i = "cs*.exe";   fn.i = "cs_140.exe"  /* a.s. 02/Mar/1999 */
i = i+1; maskTable.0 = i; maskTable.i = "cs*.dsk";   fn.i = "cs_140.dsk"  /* a.s. 02/Mar/1999 */
i = i+1; maskTable.0 = i; maskTable.i = "cs*.zip";   fn.i = "cs_140.zip"  /* a.s. 02/Mar/1999 */

repeat = 0
fixt = ""

do while fixt = ""
  do i = 1 to maskTable.0
    filemask = src"\"maskTable.i        /* Filemask for service diskette image */
    rrc = SysFileTree(filemask, srcdisk., "FO")
    if srcdisk.0 > 0 then
      do
        fixt = srcdisk.1
        leave
      end
  end
  if fixt = "" then
    do
      if repeat then
        call error "No, you still didn't get it right."
      else
        call error "A fix tools distribution image was not found in the source directory."
      repeat = 1
      say colour(bright,yellow)
      say "Copy a fixtools image file to directory" colour(cyan)src||colour(yellow)"."
      say "The exact name of the fixtools file is subject to the build level, your"
      say "national language and IBM's whim but should be something like:"
      do i = 1 to maskTable.0
        say colour(cyan)"        "fn.i colour(yellow)"    ("maskTable.i")"
      end
      say "Press"colour(white) "Enter" colour(yellow)"to continue ("colour(white)"Q"colour(yellow) "to quit)..."
      answer = gets(,-1)
      if answer = "Q" then
        exit
   end
end
return fixt

/*-----------------------------------------------------------------------------

        deleteFiles()

        Removes all files matching a specified pattern.  Does files only,
        no recursion.

-----------------------------------------------------------------------------*/

deleteFiles: procedure
  parse arg pattern

/* I'd like to use "FO" as the options parameter but then the
   attribute change doesn't seem to work.  Very strange.  */

  rc = SysFileTree(pattern, files., "FT", "*****", "***-*")
  do f = 1 to files.0
    fn = substr(files.f,36)
    rc = SysFileDelete(fn)
    if rc ช= 0 then
      do
        call box "Error" rc "deleting" fn
        exit
      end
  end
  return

/*-----------------------------------------------------------------------------

        compound()

        Takes a directory name and returns true if any component thereof
        fails to conform to boring old DOS conventions.

        This is used to avoid problems with tools such as SERVICE and
        FSERVICE which may not be able to handle them.

-----------------------------------------------------------------------------*/

compound: procedure
  parse arg args
  if words(args) > 1 then
    return 1
  args = translate(args, "\", "/")
  if substr(args,2,1) = ":" then
    do
      drive = left(args,1)
      args = substr(args,3)
      if ชdatatype(drive, "Mixed case") then
        return 1;
    end
  do until args = ""
    parse var args segment "\" args
    if ชsimple_8_3(segment) then
      return 1
  end
  return 0

simple_8_3: procedure
  parse arg eight "." three
  if length(three) > 3 then
    return 0
  if length(eight) > 8 then
    return 0
  return 1

/*-----------------------------------------------------------------------------

        makeDirectory()

        Creates a (possibly nested) directory.

-----------------------------------------------------------------------------*/

makeDirectory: Procedure
  parse arg dest .
  dest = translate(dest, "\", "/")
  here = directory()
  if substr(dest,2,1) = ":" then
    do
      drive = left(dest,2)
      dest = substr(dest,3)
    end
  else
    drive = left(here,2)
  if left(dest,1) = "\" then
    do
      drive = drive"\"
      dest = substr(dest,2)
    end
  /* Get onto the right disk */
  there = directory(drive)
  if there = "" then
    do
      call directory here
      return 3
    end
  do until dest = ""
    parse var dest segment "\" dest
    there = directory(segment)
    if there = "" then /* directory doesn't exist, try to create it. */
      do
        rrc = SysMkDir(segment)
        if rrc > 0 then
          return rrc
        there = directory(segment)
      end
  end
  return 0

/*-----------------------------------------------
   ANSI sequence for setting colour attributes
 -----------------------------------------------*/

colour: procedure
  n = arg()
  csi = d2c(27)"["
  do x = 1 to n
    csi = csi || arg(x)
    if x ช= "" then
      csi = csi || ";"
  end
  return csi"m"

/*------------------------------------------------
   A "convenience" function to avoid declaring
   separate foreground and background attributes
 ------------------------------------------------*/

bg: procedure
  return arg(1)+10

/*-w.cmd----------------------------------------*/
/* Word()-like Function (handles quoted strings)*/
/* Peter Flass <Flass@LBDC.Senate.State.NY.US>  */
/* May, 1998                                    */
/* Usage: result = W(string,word#)              */
/*----------------------------------------------*/

  /* Uncomment the following line if embedding  */
/* --- */
W:Procedure
/* ---*/
  Signal On Novalue
  Parse Arg str,num
  word     = 0
  i=1

  Do While(i<=Length(str))
     HaveWord  = ''
     ThisWord  = ''
     quote     = ''
     c1        = ''

     /* Find Start of String */
     Do While(i<=Length(str))
        c1 = Substr(str,i,1)
        If c1<>' ' Then Leave
        i=i+1
        End /* do i */
     If i>Length(str) Then Return '' /*052798*/

     If c1="'" | c1='"' Then Do
        quote=c1
        i=i+1
        if i>Length(str) Then Return ''/* Single quote only */
        c1 = Substr(str,i,1)
        End /* quote */

     /* Scan string */
     Do Forever
        i=i+1
        if i>Length(str) Then Do
           If c1=quote Then Do
              HaveWord='Y'
              Leave /* Forever */
              End
           If quote<>'' Then Return '' /* No closing quote */
           ThisWord = ThisWord || c1
           HaveWord='Y'
           End /* i>Length(str) */
        If HaveWord<>'' Then Leave /* Forever */
        c2 = Substr(str,i,1)

        /* Not a quoted string */
        If quote='' Then Do
           If c2=' ' Then Do
              ThisWord = ThisWord || c1
              HaveWord='Y'
              End /* c2=' ' */
           Else Do
              ThisWord = ThisWord || c1
              c1=c2
              Iterate
              End /* else */
           End /* quote='' */

        /* Quoted string */
        Else Do
           Select
              /* Quote-Quote -> Quote */
              When c1=quote & c2=quote Then Do
                 ThisWord = ThisWord || c1
                 i=i+1
                 If i>Length(str) Then Return '' /* ends with '' */
                 c1=Substr(str,i,1)
                 Iterate
                 End /* quote-quote */
              /* Quote-x: end of string */
              When c1=quote & c2<>quote Then Do
                 HaveWord='Y'
                 End
              /* Quote-<EOS> */
              When c1=quote & i>=Length(str) Then Do
                 HaveWord='Y'
                 End
              /* x-Anything */
              Otherwise Do
                 ThisWord = ThisWord || c1
                 c1=c2
                 Iterate
                 End /* otherwise */
              End /* Select */
           End /* Quoted string */

         If HaveWord<>'' Then Leave /* scan */

         End /* scan */

      word=word+1
      If word=num Then Return ThisWord

      End /* Do While(i) */

   Return ''

/*------------ End of 'W' --------------*/

/*
       CmdLine.CMD
       (c) 1994 by Albert Crosby <acrosby@comp.uark.edu>

       This code may be distributed freely and used in other programs.
       Please give credit where credit is due.

       CmdLine.CMD is REXX code that creates a full featured version
       of the OS/2 command line parser that may be called from your
       programs.
*/

/* BEGINNING OF CmdLine CODE BY ALBERT CROSBY */
/*
       CmdLine.CMD Version 1.0
       (c) 1994 by Albert Crosby <acrosby@comp.uark.edu>

       This code may be distributed freely and used in other programs.
       Please give credit where credit is due.

       CmdLine.CMD is REXX code that creates a full featured version
       of the OS/2 command line parser that may be called from your
       programs.
*/

/* This is a CmdLine function for REXX.  It supports:
       *       OS/2 style command history. (1)
       *       Keeps insert state. (1)
       *       Command line _can_ include control chars.
       *       Allows for "hidden" input, for passwords.
       *       A call can be restricted from accessing the history.
       *       A call can be restricted from updating the history.
       *       A predefined value can be given to extended keys. (1) (2)

   NOTE:
       (1) These functions work ONLY if CmdLine is included in the source
           file for your program.
       (2) Format: !history.nn="string" where nn is the DECIMAL value for
           the second character returned when the extended key is pressed.
*/

/* The following two lines are used in case CmdLine is called as an
   external function */

parse source . . name
if translate(filespec("name",name))="CMDLINE.CMD" then signal extproc

CmdLine: procedure expose !history.
extproc: /* CmdLine called as an external proc or command line */

/* Parameters can be any combination of:
   Hidden:      Characters are displayed as "*", no history, not kept.
   Forget:      Do not add the result of this call to the history list.
   No History:  Do not allow access to the history list.
   Clear:       Clear the history list with this call (no input action made.)
                Also clears any predefined keys!
   Insert:      Set insert mode ON.
   Overwrite:   Set overwrite mode OFF.
   SameLine:    Keep cursor on sameline after input. (Default: off)
   Required:    Null values are not accepted. (Default: off)
   Valid:       Next parameter specifies the valid characters (no translation)
                unless specified elsewhere. (1)
   Upper:       Translate input to upper case. (1)
   Lower:       Translate input to lower case. (1)
   Width:       Next parameter specifies the maximum width. (1)
   Autoskip:    Do not wait for enter after last char on a field with a width.
   X:           Next parameter specifies the initial X (column) position.
   Y:           Next parameter specifies the initial Y (row) position.
   Tag:         Displays the next parameter as a prompt in front of the
                entry field.
   Prefill:     Preloads the entry field with the next parameter.

   Only the first letter matters.  Enter each desired parameter seperated
   by commas.

   NOTES:
      (1)  Upper, Lower, Width, and Valid preclude access to the history
           list.
*/

hidden=0
history=1
keep=1
sameline=0
required=0
reset=0
valid=xrange()
upper=0
lower=0
width=0
autoskip=0
prefill=""
/* Bug fix 10-Dec-98.  According to intro above, X and Y represent cartesian
   coordinates; x=col, y=row.  However SysCurPos() deals with row, col.
parse value SysCurPos() with x y
*/
parse value SysCurPos() with y x

do i=1 to arg()
   cmd=translate(left(arg(i),1))
   parm=""
   if pos("=",arg(i))\=0 then
      parse value arg(i) with ."="parm
   select
      when cmd="X" then
         do
/*       parse value SysCurPos() with x y       */
         parse value SysCurPos() with y x
         if parm="" then
            do;i=i+1;parm=arg(i);end
         if datatype(parm,"W") then
/*          Call SysCurPos parm,y       */
            Call SysCurPos y, parm
         end
      when cmd="Y" then
         do
         parse value SysCurPos() with x y
         if parm="" then
            do;i=i+1;parm=arg(i);end
         if datatype(parm,"W") then
/*          Call SysCurPos x,parm       */
            Call SysCurPos parm, y
         end
      when cmd="T" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         call charout, parm
         end
      when cmd="H" then
         do
         hidden=1
         keep=0
         history=0
         end
      when cmd="C" then
         reset=1
      when cmd="O" then
         !history.insert=0
      when cmd="I" then
         !history.insert=1
      when cmd="F" then
         keep=0
      when cmd="S" then
         sameline=1
      when cmd="R" then
         required=1
      when cmd="V" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         valid=parm
         history=0
         keep=0
         end
      when cmd="U" then
         do; upper=1; lower=0; history=0; keep=0; end
      when cmd="L" then
         do; upper=0; lower=1; history=0; keep=0; end
      when cmd="A" then
         autoskip=1
      /* "Prefill" extension added by Jon Saxton 10-Dec-98 */
      when cmd="P" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         prefill = parm
         end
      when cmd="W" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         width=parm
         if \datatype(width,"Whole") then width=0
         if width<0 then width=0
         history=0
         keep=0
         end
    otherwise nop
    end
end

if width=0 then autoskip=0

/* ----- Last bit of "Prefill" extension, jrs 10 Dec 98 ----- */
if prefill<>"" then
  do
    parse value SysCurPos() with y0 x0
    call charout, prefill
    parse value SysCurPos() with y x
    if (x - x0) < width then
      do i=x to x0+width
        call charout, ' '
      end
    call SysCurPos y, x
    word = prefill
    pos = length(prefill)
  end
else
  do
    word=""
    pos=0
  end

if reset then
   do
   drop !history.
   return ""
   end

if symbol("!history.0")="LIT" then
   !history.0=0
if symbol("!history.insert")="LIT" then
   !history.insert=1

historical=-1
key=SysGetKey("NoEcho")
do forever /* while key\=d2c(13)*/
   if key=d2c(13) then /* Enter key */
      if required & word="" then nop;
      else leave
   else if (key=d2c(8)) then /* Backspace */
      do
      if length(word)>0 then
      do
      word=delstr(word,pos,1)
      call rubout 1
      pos=pos-1
      if pos<length(word) then
         do
         if \hidden then call charout, substr(word,pos+1)||" "
         else call charout, copies("*",length(substr(word,pos+1)))||" "
         call charout, copies(d2c(8),length(word)-pos+1)
         end
      end
      end
   else if key=d2c(27) then /* Escape */
      do
      if pos<length(word) then
         if \hidden then call charout, substr(word,pos+1)
         else call charout, copies("*",length(substr(word,pos+1)))
      call rubout length(word)
      word=""
      pos=0
      end
   else if key=d2c(10) | key=d2c(9) then /* Ctrl-Enter and TAB */
      nop; /* Ignored */
   else if key=d2c(224) | key=d2c(0) then /* Extended key handler */
      do
      key2=SysGetKey("NoEcho")
      select
         when key2=d2c(59) then /* F1 */
            if (history) & (!history.0<>0) then
               do
               if symbol('search')='LIT' then
                  search=word
               if symbol('LastFind')='LIT' then
                  search=word
               else if LastFind\=word
                  then search=word
               if historical=-1 then
                  start=!history.0
               else start=historical-1
               if start=0 then start=!history.0
               found=0
               do i=start to 1 by -1
                  if abbrev(!history.i,search) then
                     do
                     found=1
                     historical=i
                     LastFind=!history.i
                     leave
                     end
               end
               if found then
                  do
                  if pos<length(word) then
                     if \hidden then call charout, substr(word,pos+1)
                     else call charout, copies("*",length(substr(word,pos+1)))
                  call rubout length(word)
                  word=!history.historical
                  pos=length(word)
                  if \hidden then call charout, word
                  else call charout, copies("*",length(word))
                  end
               end
         when key2=d2c(72) then /* Up arrow */
            if (history) & (!history.0<>0) then
               do
               if historical=-1 then
                  historical=!history.0
               else historical=historical-1
               if historical=0 then
                  historical=!history.0
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=!history.historical
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
               end
         when key2=d2c(80) then /* Down arrow */
            if (history) & (!history.0<>0) then
               do
               if historical=-1 then
                  historical=1
               else historical=historical+1
               if historical>!history.0 then
                  historical=1
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=!history.historical
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
               end
         when key2=d2c(75) then /* Left arrow */
            if pos>0 then
               do
               call Charout, d2c(8)
               pos=pos-1
               end
         when key2=d2c(77) then /* Right arrow */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1,1)
               else call charout, "*"
               pos=pos+1
               end
         when key2=d2c(115) then /* Ctrl-Left arrow */
            if pos>0 then
               do
               call charout, d2c(8)
               pos=pos-1
               do forever
                  if pos=0 then leave
                  if substr(word,pos+1,1)\==" " & substr(word,pos,1)==" " then
                        leave
                  else
                     do
                     call charout, d2c(8)
                     pos=pos-1
                     end
               end
               end
         when key2=d2c(116) then /* Ctrl-Right arrow */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1,1)
               else call charout, "*"
               pos=pos+1
               do forever
                  if pos=length(word) then
                     leave
                  if substr(word,pos,1)==" " & substr(word,pos+1,1)\==" " then
                     leave
                  else
                     do
                     if \hidden then call Charout, substr(word,pos+1,1)
                     else call charout, "*"
                     pos=pos+1
                     end
               end
               end
         when key2=d2c(83) then /* Delete key */
            if pos<length(word) then
               do
               word=delstr(word,pos+1,1)
               if \hidden then call Charout, substr(word,pos+1)||" "
               else call Charout, copies("*",length(substr(word,pos+1)))||" "
               call charout, copies(d2c(8),length(word)-pos+1)
               end
         when key2=d2c(82) then /* Insert key */
            !history.insert=\!history.insert
         when key2=d2c(79) then /* End key */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1)
               else call Charout, copies("*",length(substr(word,pos+1)))
               pos=length(word)
               end
         when key2=d2c(71) then /* Home key */
            if pos\=0 then
               do
               call Charout, copies(d2c(8),pos)
               pos=0
               end
         when key2=d2c(117) then /* Control-End key */
            if pos<length(word) then
               do
               call Charout, copies(" ",length(word)-pos)
               call Charout, copies(d2c(8),length(word)-pos)
               word=left(word,pos)
               end
         when key2=d2c(119) then /* Control-Home key */
            if pos>0 then
               do
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=substr(word,pos+1)
               if \hidden then call Charout, word
               else call Charout, copies("*",length(word))
               call Charout, copies(d2c(8),length(word))
               pos=0
               end
      otherwise
         if history & symbol('!history.key.'||c2d(key2))\='LIT' then /* Is there a defined string? */
            do
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               i=c2d(key2)
               word=!history.key.i
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
            end
      end
      end
/* Bug fix 10 Dec 98 jrs:  As coded, this next line won't allow a keystroke
   if the buffer is full, even if the cursor is within the input field and
   insert mode is off.  It should.
   else if width=0 | length(word)<width then \* The key is a normal key & within width */
   else if width=0 | length(word)<width | (pos < length(word) & \!history.insert) then
      do
      if upper then key=translate(key);
      if lower then key=translate(key,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
      if pos(key,valid)\=0 then
         do;
         if \hidden then call Charout, key;
         else call charout, "*"
         if !history.insert then
            word=insert(key,word,pos);
         else word=overlay(key,word,pos+1)
         pos=pos+1;
         if pos<length(word) then
            do
            if \hidden then
               call Charout, substr(word,pos+1)
            else call Charout, copies("*", length(substr(word,pos+1)))
            call Charout, copies(d2c(8),length(word)-pos)
            end
         end
      else beep(400,4)
      end
   if autoskip & length(word)=width then leave
   key=SysGetKey("NoEcho")
end
if \sameline then say
if (keep) & (word\=="") then
   do
   historical=!history.0
   if word\=!history.historical then
      do
      !history.0=!history.0+1
      historical=!history.0
      !history.historical=word
      end
   end
return word

rubout: procedure
arg n
do i=1 to n
   call Charout, d2c(8)||" "||d2c(8)
end
return
/* END OF CmdLine CODE BY ALBERT CROSBY */
