/* REXX Script to Install RSUCSF in x:\OS2\INSTALL
   by Peter Franken <peter@pool.informatik.rwth-aachen.de>
  
   Copyright 1997 by Peter Franken  */

call RxFuncAdd "SysLoadFuncs", "REXXutil", "SysLoadFuncs"
call SysLoadFuncs

say "Install RSUCSF in x:\OS2\INSTALL"

parse arg RSUCSFZIP

if (RSUCSFZIP>"") then do
   call SysFileTree RSUCSFZIP, 'files', 'F'
   if files.0 = 1 then do
      parse value files.1 with Date Time Size Attrib RSUCSFZIP
      say 'Found: 'RSUCSFZIP
      end  
   else do
      say 'Fatal error! File 'RSUCSFZIP' does not exist!'
      exit 2
   end
end
else do
   say "Need package RSUCSF.ZIP from eg. ftp://ftp.boulder.ibm.com/ps/products/os2/rsu"
   say "Please provide me with the name like:"
   say "  InstRSUC RSUCSF.ZIP"
   exit 2
end

/* Find OS/2 Install directory x:\OS2\INSTALL */
ENVIRPATH = value('path',,'OS2ENVIRONMENT')
parse upper var ENVIRPATH BootDriv':\OS2\INSTALL'Dummy
InstDir = right(BootDriv,1)':\OS2\INSTALL'
call SysFileTree InstDir, 'dirs', 'D'
if dirs.0 = 1 then do
   parse value dirs.1 with Date Time Size Attrib InstDir
   InstDir = strip(InstDir)
   say 'Installation Directory found: 'InstDir
   end  
else do
   say 'Fatal error! OS2\INSTALL can not be found (Searched for 'InstDir')'
   exit 2
end

/* Goto Installation directory and unpack RSUCSF.ZIP */
CurrentDir = directory()
rc = SysMkDir(InstDir'\RSUCSF')
NewDir = directory(InstDir'\RSUCSF')
if \(NewDir = InstDir'\RSUCSF') then do
  say "Fatal Error: New directory RSUCSF could not be created and used."
  exit 5
end 

'PKUNZIP2 -d -o'RSUCSFZIP
if RC > 0 then do
  say "Fatal Error: Package "RSUCSF" could not be unpacked succesfully!"
  exit 8
end

rc = directory(CurrentDir)
call 'CreatFix' InstDir'\RSUCSF\OS2Serv.exe'

exit 0
