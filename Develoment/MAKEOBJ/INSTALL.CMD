/****************************************************************************************\
   MakeObj Installation
   (C) 1993 Ingo Pflanz, Regensburg              e-mail c4284@rrzc1.rz.uni-regensburg.de

   inspired by:
   (C) 1993 Thomas Christinck, Braunschweig      Compuserve 100031,41
   (C) by Stangl Roman, 1993 and his PC/2
\****************************************************************************************/


Call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
Call SysLoadFuncs;
InsDir =""
arg line

if line = " " then
do
  InstDir=Filespec("Drive",Value("OS2_SHELL",,"OS2ENVIRONMENT"))||"\OS2"
  say "Enter the Directory for MakeObj.cmd  (Press <ENTER> for "InstDir")"
  pull line
end /* do */

if line <> "" then 
 do
   InstDir = line
   if Instdir \= "." then
     do
       say "copying MakeObj.cmd to "Instdir" ..."
       "@COPY MakeObj.cmd "InstDir" >NUL"
     end /* do */
   say "creating Object on WPS ..."
   RetCode = SysCreateObject( "WPProgram", "MakeObj", "<WP_DESKTOP>", "EXENAME="InstDir"\MakeObj.cmd;ASSOCFILTER=*.EXE,*.CMD,*.COM,*.BAT;ICON=MakeObj.ico;OBJECTID=<MakeObj>")
  if RetCode = 0 then
   do
    say "The programobject <MakeObj> could not be created"
    say ""
    say "Please delete old objects named MKPRG, MakeObj or MKOBJ !"
    say "Otherwise the association may be corrupted"
   end /* do */
 end /* do */
else
 do
  say "give existing install directory or '.' for current directory"
  exit
 end /* do */

