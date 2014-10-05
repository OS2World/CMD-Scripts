/* A program to apply all Visual Age C++ CSDs to the installed base. */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
call SysFileTree "ct*.zip", "zip", "FO"
if zip.0 = 0 then
  do
    say "No ct*.zip files present"
    return
  end
else
  say "Patch files to apply:" zip.0

/* Find the drive with the most free space */

drives = SysDriveMap("c:", "local")
maxDrive = ""
MaxSpace = 0
do while drives <> ""
  parse var drives drive drives
  info = SysDriveInfo(drive)
  parse var info . freeSpace .
  if freeSpace > maxSpace then
    do
      maxDrive = drive
      maxSpace = freeSpace
    end
end

here = directory()
call directory maxDrive"\"
call SysMkDir "vacsd.tmp"
call directory "vacsd.tmp"

/*
   The order in which to apply these patches is documented by IBM as
   follows:-
	 1. reboot
	 2. CTC308 *
	 3. CTO308
	 4. CTW308
	 5. reboot
	 6. CTV308
	 7. CTD308 *
	 8. CTU308
	 9. reboot
	10. If you have the OpenClass source code, apply CTS308 at any time.
   Now the first reboot is probably spurious but the ordering itself causes
   some difficulty for this program.
*/

sequence.0 = 9
sequence.1 = "ctc"
sequence.2 = "cto"
sequence.3 = "cts"
sequence.4 = "ctw"
sequence.5 = "reboot"
sequence.6 = "ctv"
sequence.7 = "ctd"
sequence.8 = "ctu"
sequence.9 = "reboot"

/*
   Scan the list of files actually present and construct a list of patches
   ordered according to the foregoing sequence.
*/

y = 0
csd.y = 0
do x = 1 to sequence.0
  if sequence.x = "reboot" then
    do
      y = y + 1
      csd.y = sequence.x
      csd.0 = y
    end
  else
    do z = 1 to zip.0
      fnpos = lastpos("\", zip.z) + 1
      fnseg = translate(substr(zip.z, fnpos, 3))
      if fnseg = translate(sequence.x) then
        do
          y = y + 1
          csd.y = zip.z
          csd.0 = y
        end
    end
end

/*
   Now we have the list of files built.  It may be that we have reentered
   this program on a reboot.
*/

if stream("csdone", 'C', "query exists") <> "" then
  do
    lyne = linein("csdone", 1, 1)
    call lineout "csdone"
  end
else
  lyne = 1

do x = lyne to csd.0
  if csd.x = "reboot" then
    do
      call charout ,"A reboot is now in order.  Press 'Y' to do it now. "
      answer = SysGetKey("echo")
      call lineout "csdone", x+1, 1
      call lineout "csdone"
      if translate(answer) = "Y" then
        "setboot /b"
      exit
    end
  else
    do
      "unzip" csd.x
      "service"
      "rm -r *"
      call lineout "csdone", x, 1
      call lineout "csdone"
    end
end
"rm -r *"
call directory "\"
call SysRmDir "vacsd.tmp"
call directory here
