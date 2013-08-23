/*
   Random folder background by DmiG
	works with any folder
	  by its Object ID.

Syntax: SetBackGround [Folder ObjectID]

Images are taken from current directory (all files).

Best way to use:
 Create WPS object of this program, with working directory set
 to dir with images, and, optionally, ObjectID of some folder (e.g. <WP_GAMES>) 
 set as parameter. As default, Desktop background will be changed.
 Run program object using any scheduler (I use EBCSheduler) or place
 object in your startup folder.
 
Contact author at: DmiG@nm.ru


You can change this to something else, e.g. '*.jpg' or '*.bmp'.
*/

mask = '*';

/******************************************************************/
ObjectID = "<WP_DESKTOP>";
if  arg(1)<>'' then ObjectID = arg(1);
path = Directory()||'\'||mask;

Call rxFuncAdd "SysLoadFuncs" , "RexxUtil" , "SysLoadFuncs";
Call SysLoadFuncs;
Call RxFuncAdd "SysQueryObject", "WPTOOLS", "WPToolsQueryObject";

RC = SysQueryObject(ObjectID, , , "szSetupString");
if RC Then do
  parse upper value szSetupString with shit "BACKGROUND=" bkgndImage "," temp ";" shit;
  shit = Left(temp,1);
  CurrentTileMode = "," || shit;
  if Translate(shit) = "S" then do 
    parse value temp with "S," TileNum "," shit;
    CurrentTileMode = CurrentTileMode ||","|| TileNum;
  end;
  RC=SysPutEA(bkgndImage, ".TileMode", CurrentTileMode);
end
else do
  say "Suxx!!!"||d2c(10)||d2c(13)||"Unable to return object settings for "||ObjectID||"!";
  Return 1;
end;

Call sysFileTree path, "Files","FO"
do until Files.i<>bkgndImage
  i=RANDOM(1,Files.0);
end;

Call RxFuncDrop "SysQueryObject"

if SysGetEA(Files.i, ".TileMode", "Mode")>0 then Mode=",S,1";
if Mode='' then Mode=",S,1";		/*SysGetEA ALWAYS return 0 - ????*/

RC=SysSetObjectData(ObjectID,"Background="||Files.i||Mode);
