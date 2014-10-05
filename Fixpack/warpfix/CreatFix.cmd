/* REXX Script to Create a Fix Object 
   by Peter Franken <peter@pool.informatik.rwth-aachen.de>
  
   Copyright 1997 by Peter Franken  */

call RxFuncAdd "SysLoadFuncs", "REXXutil", "SysLoadFuncs"
call SysLoadFuncs

say "Fix Object for OS/2 Fixpaks will be created"

parse arg os2serv

if (os2serv>"") then do
   call SysFileTree os2serv, 'files', 'F'
   if files.0 = 1 then do
      parse value files.1 with Date Time Size Attrib os2serv
      say 'Found: 'os2serv
      end  
   else do
      say 'Fatal error! File 'os2serv' does not exist!'
      exit 2
   end
end
else do
   say "Need program OS2Serv.exe from RSUCSF package."
   say "Please provide me with the name like:"
   say "  CreatFix x:\os2\install\rsucsf\os2serv.exe"
   exit 2
end

/* Create new or update old Fix OS/2 object in Install/Remove Folder */
WorkingDir = Filespec("drive",os2serv)||FileSpec("path",os2serv)
WorkingDir = strip(strip(WorkingDir,'T','\'))
Location = "<WP_INSTREMFOLDER>"
Title = "Fix OS/2"
Class = "WPProgram"
ObjectID="<WP_FIXOS2>"
SetupString =  "OBJECTID="ObjectID";"
SetupString =  SetupString || "PROGTYPE=PM;"
SetupString =  SetupString || "EXENAME="os2serv";"
SetupString =  SetupString || "STARTUPDIR="WorkingDir";"
SetupString =  SetupString || "PARAMETERS="WorkingDir"\CSF %**P;"
SetupString =  SetupString || "ASSOCFILTER=CSF_DISK*;"
ObjMode = "Update"

if SysCreateObject(Class,Title,Location,SetupString,ObjMode) = 1 then do
  say "The object "Title" was succesfully created."
  rc = SysCreateObject("WPShadow",Title,"<WP_DESKTOP>","SHADOWID="ObjectID,ObjMode)
  call SysOpenObject Location, "Default", TRUE
  call SysOpenObject Location, "Default", TRUE
  end
else
  say "Could not create the object "Title"."

exit 0