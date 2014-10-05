/* REXX Install RSUCSF 
   by Peter Franken <peter@pool.informatik.rwth-aachen.de>
  
   Copyright 1997 by Peter Franken  */

call RxFuncAdd "SysLoadFuncs", "REXXutil", "SysLoadFuncs"
call SysLoadFuncs

say "Install RSUCSF"

RSUCSFZIP="RSUCSF.ZIP"

call SysFileTree RSUCSFZIP, 'files', 'F'
if files.0 = 1 then do
   parse value files.1 with Date Time Size Attrib RSUCSFZIP
   RSUCSFZIP = strip(RSUCSFZIP)
   say 'Found: 'RSUCSFZIP
   end  
else do
   say "Need package RSUCSF.ZIP from eg. ftp://ftp.boulder.ibm.com/ps/products/os2/rsu"
   say "Please provide me with the name like:"
   say "  InstRSUC RSUCSF.ZIP"
   exit 2
end

call InstRSUC RSUCSFZIP
