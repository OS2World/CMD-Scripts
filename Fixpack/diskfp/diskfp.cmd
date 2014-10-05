/* diskfp.CMD to loaddskf and xcopy fixpack disks */
/*                                                */
/* This command file written by Trevor Hemsley    */
/* 1st March 1997. All responsibility for the     */
/* use of this command file lies with the user    */
/* of it. No guarantee is made that it will work  */
/* correctly. I am not responsible for any damage */
/* that may be caused to your system by use of    */
/* this command file nor by any fixpack you may   */
/* apply to your system using it.                 */
/*                                                */
/*                                                */
 Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 Call SysLoadFuncs
 parse upper arg src dest        /* get source and target dirs passed */

 if src = "" then                /* if no source specified */ 
    do
    say "No source specified"    /* say so */
    call syntax                  /* then get out */ 
    end

 if dest = "" then               /* if no destination specified */
    do
    say "No destination specifed" /* say so */
    call syntax                   /* get out */
    end

 say "Enter the drive letter of the OS/2 boot partition you want serviced"
 pull answer
 if length(answer) ª= 1 then      /* validity check the drive letter given */
    do
    say "Drive letter invalid"
    exit
    end
 else
    do
    map = SysDriveMap(answer, "LOCAL") /* and check it exists */
    if substr(map, 1, 1) ª= answer then /* if not first character of return */
       do
       say "Invalid drive specified"
       exit
       end
    syslevelfile = answer || ":\os2\install\syslevel.os2" /* set up filename */
    driveletter = answer                  /* save the drive letter for later */
    rrc = SysFileTree(syslevelfile, syslf., "FO")   /* check syslevel exists */
    if syslf.0 = 0 then                             /* if not */
       do
       say "File "syslevelfile" does not exist"
       exit
       end
    end

 say "Enter the directory name where the archive files will be placed"
 say "Example - C:\ARCHOS2 (this will be the default). There must be"
 say "enough space on this drive to contain all the files that are to"
 say "to be updated. A fatal error could occur if there is not enough"
 say "space."
 arcgiven = "N"
 do until arcOK = "Y"
 pull answer
 if answer = "" then
    do
    answer = "C:\ARCHOS2"
    end
 arc = answer
 rrc = SysFileTree(arc, arcdir., "D")   /* check directory exists */
 if arcdir.0 = 0 then                             /* if not */
    do
    rc = SysMkDir(arc)
    if rc = 0 then
       do
       curdir = DIRECTORY()
       dir = DIRECTORY(arc)
       "@CD .."
       newdir = DIRECTORY(curdir)
       drive = substr(dir, 1, 2)
       driveinfo = SysDriveInfo(drive)
       freespace = WORD(driveinfo, 2)
       if freespace < 20000000 then
          do
          say "Not enough freespace on drive "drive" for archive files"
          rrc = SysRmDir(arc)
          say "Please respecify"
          end
       else
          do
          arcOK = "Y"
          end
       end
    else
       do
       say "Error "rc" making directory "arc
       say "Please respecify"
       end
    end
 else
    do /* if directory already exists */
    say "Sorry, that directory already exists"
    end
 end
    
 say "Please make sure there is a 1.44Mb diskette in drive A:"
 say "This diskette will be overwritten, is this OK - Y/N"
 pull answer
 if answer ª= "Y" then exit

 rrc = SysFileTree(dest, files., "D")
 if files.0 = 0 then
    do
    say "Destination directory "dest" does not exist, create it?"
    pull answer
    if answer ª= "Y" then exit
    "@MD "dest
    end
 else
    do
    say "Directory "dest" exists already, use it anyway?"
    pull answer
    if answer ª= "Y" then exit
    end

 filemask = src || "\xr_m*.?DK"         /* set up filemask for fixpack diskette images */
 rrc = SysFileTree(filemask, srcdisk., "FO")   /* check in source dir for them */
 if srcdisk.0 = 0 then                         /* if none there */
    do
    say "Source directory is empty"
    exit
    end
 else
    do i = 1 to srcdisk.0 by 1         /* otherwise loop for # of files */
    "@loaddskf "srcdisk.i" A: /F /Y"    /* loading them up */
    if RC ª= 0 then
       do
       say "LOADDSKF returned a non-zero return code. Continue Y/N?"
       pull answer
       if answer ª= "Y" then exit
       end
    say ""
    say "XCOPY contents of "srcdisk.i" in progress"
    "@XCOPY A:\ "dest" /h/o/t/s/e/r/v 1>nul"
    if RC ª= 0 then
       do
       say "XCOPY returned a non-zero return code. Continue Y/N?"
       pull answer
       if answer ª= "Y" then exit
       end   
    end

 filemask = src || "\csf*.2DK"         /* set up filemask for kicker diskette image */
 rrc = SysFileTree(filemask, srcdisk., "FO")   /* check in source dir for them */
 if srcdisk.0 = 0 then                         /* if none there */
    do until answer = "N"
    say ""
    say "Kicker diskette 2 was not found in source directory"
    say "Copy the file CSFBOOT.2DK to "src" then press enter"
    pull answer
    rrc = SysFileTree(filemask, srcdisk., "FO")   /* check in source dir for them */
    if srcdisk.0 = 0 then                         /* if none there */
       do
       say "Sorry, you still didn't get it right"
       end
    else
       do
       answer = "N"
       end
    end
 do i = 1 to srcdisk.0 by 1         /* otherwise loop for # of files */
 "@loaddskf "srcdisk.i" A: /F /Y"    /* loading them up */
 if RC ª= 0 then
    do
    say "LOADDSKF returned a non-zero return code. Continue Y/N?"
    pull answer
    if answer ª= "Y" then exit
    end
 say ""
 say "XCOPY contents of "srcdisk.i" in progress" 
 say "Expect a SYS1186 error for EA DATA. SF on this copy. This is OK"
 "@XCOPY A:\ "dest" /h/o/t/s/e/r/v 1>nul"
 /* no error checking on this one as CSF disk has an EA DATA. SF on it */
 /* and this causes XCOPY to give a non-zero RC */
 end

/* set up the response file to apply the fixpack to drive given */
 "@echo :LOGFILE "driveletter":\OS2\INSTALL\SERVICE.LOG >"dest"\apply.fil"
 "@echo :FLAGS REPLACE_PROTECTED REPLACE_NEWER >>"dest"\apply.fil"
 "@echo :SOURCE "dest" >>"dest"\apply.fil"
 "@echo :SERVICE >>"dest"\apply.fil"
 "@echo :SYSLEVEL "syslevelfile" >>"dest"\apply.fil"
 "@echo :ARCHIVE "dir" >>"dest"\apply.fil"

/* set up response file to back out fixpack from the drive specified */
 "@echo :LOGFILE "driveletter":\OS2\INSTALL\SERVICE.LOG >"dest"\backout.fil"
 "@echo :TARGET ARCHIVE >>"dest"\backout.fil"
 "@echo :BACKOUT >>"dest"\backout.fil"
 "@echo :SYSLEVEL "driveletter":\OS2\INSTALL\SYSLEVEL.OS2 >>"dest"\backout.fil"

/* set up command files to apply and backout fixpack */
 "@echo @echo Hit Ctrl-Break when you see the prompt to hit Ctrl-Alt-Del >"dest"\apply.cmd"
 "@echo @pause>>"dest"\apply.cmd"
 "@echo fservice /s:"dest" /r:"dest"\apply.fil /L1:"driveletter":\os2\install\service.log >>"dest"\apply.cmd"
 "@echo @echo Hit Ctrl-Break when you see the prompt to hit Ctrl-Alt-Del>"dest"\backout.cmd"
 "@echo @pause>>"dest"\backout.cmd"
 "@echo fservice /s:"dest" /r:"dest"\backout.fil /L1:"driveletter":\os2\install\service.log >>"dest"\backout.cmd"

 say " "
 say "Now reboot to a command line using Alt+F1 option F2 and change to the directory "dest
 say 'and issue the command "APPLY" to apply the fixpack or "BACKOUT" to back it out.'
 say " "
 say "Please make sure that you have previously read the various README files that"
 say "are now in the directory "dest" as these may contain important information"
 say "from IBM about problems that you may encounter after applying this fixpack."
exit

syntax: say ""
say "Syntax of command is:"
say ""
say "DISKFP source_dir destination_dir"
say " "
say "where source_dir is a directory containing the diskette image files"
say "             for the fixpack this should contain all of the fixpack"
say "             diskette images and the second diskette image of the"
say "             kicker diskettes (usually csfboot.2dk). No other files"
say "             should be present in this directory."
say ""
say "and"
say "      destination_dir is the directory name where the fixpack files"
say "             ready to be applied to the system will be copied. This"
say "             should be a new directory name not one that presently"
say "             exists."
exit
