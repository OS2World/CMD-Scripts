/**********  Rexx file to make an OS/2 2.11 BOOT diskette *******/
/*           MakeBoot.cmd                                       */
/* trace all */
/* signal on halt  name errorcleanup */
/****************************************************************/
/*                                                              */
/* 94-03-03 RJ O'Reilly  Converted to 2.11  Version 2.11.00     */
/* 94-03-10 RJ O'Reilly  Refined            Version 2.11.01     */
/*                                                              */
/*      Copyright 1993,1994,  R. J. O'Reilly                    */
/*      OS/2 is a Trademark of IBM Corp.                        */
/*                                                              */
/****************************************************************/

'@echo off'

'cls'
say ""
say ""
say ""
say ""
say "      MakeBoot 2.11.01   1994-03-10 "
say "      RJ O'Reilly"
say "      Sherwood Park, Canada"
say ""
say "      OS/2 2.11 Boot Diskette creation utility."
say "      This program will create a bootable 3.5 inch High Density floppy"
say "      for OS/2 2.11."
say ""


cfg = "A:\config.sys"
/* Load Rexx System Utility Functions  */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs                 /* RexxUtil function */

if RxFuncQuery('RexxUtil') then do
    say "RexxUtil Loaded."    
end
else do
    say "Error Loading RexxUtil Functions. Can't continue."
    signal ErrorCleanup
end



/*  First we have to sys the floppy disk */

/*  Find out if sysinstx.com is in the system directory */
SysinstxOK="NO"
rc=SysFileTree("c:\os2\sysinstx.com",'file','S')
if rc = 0 then
  if file.0<>0 then
	SysinstxOK="YES"

if SysinstxOK="NO" then /* Get sysinstx.com from the installation disks */
do
	say "Sysinstx.com was not found! It must be loaded from the OS/2 disks."
	say "Insert the 2.11 Service Pack Disk #1 into drive A:"
	say "Press <enter> when ready"
    rc=beep(1200,300)
	pull enterkey
	say "Copying sysinstx.com into the os2 install directory"
	"copy  a:\sysinstx.com c:\os2\install\*.*"
	if rc = 0 then do
       'cls'
       say ""
       say ""
	   say "The file sysinstx.com has been copied to the install directory."
       say ""
       say ""
       say "Remove the Service Pack Diskette form Drive A: and press <enter>"
       rc=beep(1200,500)
       denter=linein()
    end
	else
	do
	   say "An error occurred copying sysinstx.com. Cannot continue."
       say "Be sure this is the correct diskette!"
	   signal ErrorCleanup
	end
end

/* Now, is it formatted?	*/
say  "Is the new diskette formatted? Yes or No ?"
pull formatted

if Left(formatted,1) = "N" then	/* Format the new BOOT diskette */
do
   say "Insert the unformatted disk into drive A:"
   say "Press <enter> when ready"
   pull enterkey
   say "Formatting diskette in drive A:"
   'format A: /ONCE'
   if rc=0 then
      say "Diskette in drive A: has been formatted."
   else
   do
	  say "An error occurred formatting diskette. Cannot continue."
      say "It may be bad diskette."
      signal ErrorCleanup
   end

end
else	/* They have a formatted diskette so do a quick format	*/
do
   say "Insert the formatted disk into drive A:"
   say "Press <enter> when ready"
   pull enterkey
   '@attrib -s -r -h a:\*.*'
   '@attrib +s +r +h "a:\ea data. sf"'
   say "About to delete any files on the diskette in Drive A:"
   say "Verify the deletion by pressing 'Y' and then <enter>"
   rc=Beep(800,500)
   'ERASE A:\*.*'
end

/*  Now SYS the diskette. */
say "Performing a SYS to the diskette in drive A:"

'c:\os2\install\sysinstx a:'
if rc = 0 then
	say "SYS complete!"
else do
    say "Cannot SYS the diskette in drive A:"
    signal ErrorCleanup
end

/* Now copy the system files to drive A:  */
/**** first do the SYSTEM FILES ****/
"@attrib c:\os2krnl -S -H"
"copy c:\os2krnl a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   "@attrib c:\os2krnl +S +H"
   signal errorcopy
end
"@attrib c:\os2krnl +S +H"
"@attrib a:\os2krnl +S +H"

"@attrib c:\os2ldr -S -H"
"copy c:\os2ldr  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   "@attrib c:\os2ldr +S +H"
   signal errorcopy
end
"@attrib c:\os2ldr +S +H"
"@attrib a:\os2ldr +S +H"

"@attrib c:\os2ldr.msg -S -H"
"copy c:\os2ldr.msg  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   "@attrib c:\os2ldr.msg +S +H"
   signal errorcopy
end
"@attrib c:\os2ldr.msg +S +H"
"@attrib a:\os2ldr.msg +S +H"

"copy c:\os2\ibm1flpy.add  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
/*
"copy c:\os2\ibm1s506.add  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
*/
"copy c:\os2\chkdsk.com  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\keyboard.dcp  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\os2dasd.dmd  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\cmd.exe  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\clock01.sys  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\kbd01.sys  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\print01.sys  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\screen01.sys  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\ansicall.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\bkscalls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\bmscalls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\bvhinit.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\bvscalls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\doscall1.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\kbdcalls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\moucalls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\msg.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\nampipes.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\nls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\os2char.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\quecalls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\sesmgr.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\dll\viocalls.dll  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\system\harderr.exe  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
"copy c:\os2\system\country.sys  a:\"
if rc <> 0 then do
   say " Error copying file. A BOOT disk was NOT created!"
   signal errorcopy
end
say "Creating the config.sys file."
configstat="OK"
rc = lineout(cfg,"buffers=32")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"iopl=yes")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"memman=noswap")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"protshell=cmd.exe")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"set os2_shell=cmd.exe")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"diskcache=64,LW")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"protectonly=yes")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"libpath=.;a:\;")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"pauseonerror=no")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"codepage=850")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"devinfo=kbd,us,keyboard.dcp")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"rem devinfo=scr,ega,vtbl850.dcp")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"rem device=\mouse.sys")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"set path=.;a:\")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"set dpath=a:\;")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"set keys=on")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"basedev=print01.sys")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"basedev=ibm1flpy.add")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"basedev=ibm1s506.add")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"basedev=os2dasd.dmd")
if rc <>0 then configstat="NQ"
rc = lineout(cfg,"rem device=\testcfg.sys")
if rc <>0 then configstat="NQ"
if configstat<>"OK" then
do
	say "A valid config.sys file was not created. The disk will not be a"
	say "valid BOOT DISK."
	signal errorcopy
end
else say "Config.sys file created!"
say ""

signal cleanup

ErrorCopy:
say "Check the diskette to be sure there were no sub-directories"
say "with files in them. Also be sure you are using a High Density"
say "diskette."
say "If all else fails, use a new HD diskette and use the format "
say "feature to  be sure the diskette is empty."

ErrorCleanup:
say ""
say "A valid BOOT DISKETTE was not created."
signal out

Cleanup:

say ""
say ""
say "The OS/2 2.11 BOOT Diskette has been successfully created!"
say "Enjoy!  RJ O'Reilly"
say ""
say "At this time it would be wise to shut down the system and attempt"
say "to boot from the new BOOT diskette."
say "Leave the BOOT diskette in the A: drive. Shutdown and press CTRL-ALT-DEL"
say "The system should boot from the BOOT diskette."
say "Press <enter> to continue."
rc=Beep(1000,400)


out:
Denter=Linein()

exit
 

