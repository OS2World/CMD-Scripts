/***********************************************************************\
 *                                 PC2.c                               *
 *                 Copyright (C) by Stangl Roman, 1993                 *
 * This Code may be freely distributed, provided the Copyright isn't   *
 * removed.                                                            *
 *                                                                     *
 *  Copyright (C) by Pflanz Ingo, 1993 for enhancements for use via    *
 *  commandline parameters or filetype association (use for *.cmd,     *
 *  *.bat, *.com, *.exe). For distribution, see above.                 *
 *                                                                     *
 * MakeObj.cmd  Installation batch file.                               *
 *                                                                     *
 *              MakeObj <<<Drive:\>Path\>Executable>                   *
 *              e.g. MakeObj C:\PMAPPS\PC2                             *
 *                                                                     *
\***********************************************************************/

                                        /* Register REXX APIs */
Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs
Signal On Halt Name SignalHandler       /* Exception handler */

Filename=" "
Arg Filename
if Filename \= " " then
do
   if SysFileTree(Filename,tempvar,'FO') \=0 then
   do
     say "Could not get enough memory: Panik exit!!!"
     Pull IgnoreInput
     Say "PC/2 abnormal error - exiting..."
     Say
     Say " Press Enter to continue!..."
     EXIT
   end /* do */
   if tempvar.0 \=1 then
     Filename = " "
   else
     Filename = tempvar.1
end /* do */

Do While Filename=" " | tempvar.0 \=1
    Call SysCls
    Say "                         WPS Objects Installer"
    Say
    Say " To install any Object with an registered Object ID (Idendity) onto the"
    Say " WPS, you must provide the  file name to be registered as an Object. You may"
    Say " then use PC/2 to launch this object, after you have configured this Object"
    Say " with any needed modifications via the settings notebook. e.g.you may want to"
    Say " create an Object for an Windows application and then reconfigure it as an "
    Say " seamless WIN-OS2 session, allowing you to launch this seamless WIN-OS2"
    Say " session from PC/2."
    Say
    Say " Brackets will automatically added to the ObjectID (typing MyExeFile will"
    Say " result in an ObjectID of <MyExeFile>). The last extension will be removed"
    Say " bevor (PC2.EXE will result in an Object named PC2 with an ObjectID of <PC2>)."
    Say " But dont forget to type in the extension, it is needed."
    Say
    Say " Syntax:       MakeObject <Exefile.EXE>"
    Say
    Say " Press Ctrl-C to end"
    Say
    Parse Value SysCurPos() with Row Col
    Say " Please input: "
    Col=Col+15
    Call SysCurPos Row, Col
    Pull Filename
    if Filename \= " " then
    do
      if SysFileTree(Filename,tempvar,'FO') \=0 then
      do
          say "Could not get enough memory: Panik exit!!!"
          Say "PC/2 abnormal error - exiting..."
          Say
          Say " Press Enter to continue!..."
          Pull IgnoreInput
          EXIT
      end /* do */
      if tempvar.0 \=1 then
          Filename = " "
      else
          Filename = tempvar.1
    end /* do */
End /* do while */
Say

exedir = Filename /*SysSearchPath('.',Filename)*/

NewObjectName=LEFT(FILESPEC("name",Filename),LASTPOS('.',FILESPEC("name",Filename))-1)
SetupString='OBJECTID=<'||NewObjectName||'>;WORKDIR='FILESPEC("drive",exedir)||FILESPEC("path",exedir)';EXENAME='||exedir||';'
                      /*'PROGTYPE='exetype';'||,'OPEN=DEFAULT;'||,*//* could be added or not */
                                        /* Now create the WPS Object on the Desktop */
rc=SysCreateObject("WPProgram",,
                   NewObjectName,,
                   "<WP_DESKTOP>",,
                   SetupString)
If rc=0 Then Do
    Say " Sorry, WPS Object couldn't be created..."
    Say
    Say " Press Enter to continue!..."
    Pull IgnoreInput
End /* do */
Else Do
    Say " WPS Object sucessfully created..."
    Say
    Say " You may now want to open the Settings of the newly created  WP Object to"
    Say " reconfigure it's setting, e.g. an fullscreen, windows or seamless WIN-OS2"
    Say " session. Don't forget to add the enclosing brackets '<' and '>' on the"
    Say " second line if you drag the object to the PC/2 Programm Installation page."
    Say
End /* do */
Exit

/*--------------------------------------------------------------------------------------*\
 * The signal handler to exit after an exception                                        *
 * Req:                                                                                 *
 *      none                                                                            *
 * Returns:                                                                             *
 *      none                                                                            *
\*--------------------------------------------------------------------------------------*/
SignalHandler:
Say
Say
Say "PC/2 abnormal error - exiting..."
Say
Say " Press Enter to continue!..."
Pull IgnoreInput
Exit

