/* REXX * OS2 * setup.cmd *****************************************************/
/* Purpous...:  Setup the URLObjectTools                                      */
/*              This routine creates the objekts for the WPS-use of the URLOT */
/* Parameters:  -                                                             */
/* Defaults..:  -                                                             */
/*                                                                            */
/* Created...:  07.10.98, Norbert Kohl                                        */
/* Version...:  0.1                                                           */
/******************************************************************************/
'@ECHO OFF'
'ECHO [47;31m'
'CLS'

IF RxFuncQuery('SysLoadFuncs') THEN DO
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    CALL SysLoadFuncs
END

progdir = DIRECTORY()

/******************************************************************************/
help:
/******************************************************************************/
'@CLS'
SAY ""
SAY "ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
SAY "บ The URLObjectTool will enhance the 'open'-menu of URL-Objects   บ"
SAY "บ                                                                 บ"
SAY "บ You will be able to start programs by the usual OS/2-way:       บ"
SAY "บ right MB -> open -> additional program                          บ"
SAY "บ                                                                 บ"
SAY "บ This setup-routine will create a folder with a program-object   บ"
SAY "บ in the Systemconfiguration-folder.                              บ"
SAY "บ                                                                 บ"
SAY "บ This has to be done for to use URLObjectTool                    บ"
SAY "บ                                                                 บ"
SAY "บ ATTENTION: the programfiles will NOT be moved; do it manually   บ"
SAY "ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
SAY ""
call CharOut , "Press Y to create the Objects"
if translate( SysGetKey( "NOECHO" ) ) <> "Y" then exit
say ""

  i = 0
  objects.0 = i
                        /* stem elements for the folder               */

  i=i+1;
  objects.i.__Title    = "URL-Objekt"
  objects.i.__Class    = "WPFolder"
  objects.i.__Setup    = "ICONVIEW=NONGRID,NORMAL;" ||,
                         "TREEVIEW=LINES,VISIBLE,MINI;DEFAULTSORT=-2;" ||,
                         "ALWAYSSORT=NO;MENUBAR=YES;SHOWALLINTREEVIEW=YES;" ||,
                         "TITLE=URL-Objekt;ICONVIEWPOS=14,82,80,12;" ||,
                         "NOPRINT=YES;MENUS=LONG;HIDEBUTTON=YES;" ||,
                         "MINWIN=VIEWER;CCVIEW=DEFAULT;DEFAULTVIEW=DEFAULT;" ||,
                         "OBJECTID=<WP_CFG-URLOT>;"
  objects.i.__location = "<WP_CONFIG>"

                        /* stem elements for the objects              */
  i=i+1;
  objects.i.__Title    = " Create new"
  objects.i.__Class    = "WPProgram"
  objects.i.__Setup    = "EXENAME=" || progdir || "\URLOT.CMD;" ||,
                         "STARTUPDIR=" || progdir || ";" ||,
                         "PROGTYPE=WINDOWABLEVIO;TITLE= Create new;" ||,
                         "NOPRINT=YES;MENUS=DEFAULT;HIDEBUTTON=DEFAULT;" ||,
                         "MINWIN=DESKTOP;CCVIEW=DEFAULT;DEFAULTVIEW=DEFAULT;" ||,
                         "OBJECTID=<URLOT_NEW>;"
  objects.i.__location = "<WP_CFG-URLOT>"

                        /* stem elements for the shadows              */
  i=i+1;
  objects.i.__Title    = "URL-Objekt"
  objects.i.__Class    = "WPShadow"
  objects.i.__Setup    = "SHADOWID=<WP_CFG-URLOT>;TITLE=URL-Objekt;" ||,
                         "NOPRINT=YES;MENUS=DEFAULT;HIDEBUTTON=DEFAULT;" ||,
                         "MINWIN=DEFAULT;CCVIEW=DEFAULT;DEFAULTVIEW=DEFAULT;"
  objects.i.__location = "<WP_DESKTOP>"

  objects.0 = i



                        /* now create the objects                     */
  errorCounter = 0
  okCounter = 0

  do i = 1 to objects.0
    say " Creating the object """ || objects.i.__title || """ ..."
    if SysCreateObject( objects.i.__class       ,,
                        objects.i.__title       ,,
                        objects.i.__location    ,,
                        objects.i.__setup       ,,
                        "UPDATE" ) <> 1 then
    do
      errorCounter = errorCounter + 1
      say "  *** Warning: Can not create the object """ || ,
          objects.i.__title || """ (Index=" || i || ")!"
    end /* if SysCreateObject( ... */
    else
      okCounter = okCounter + 1
  end /* do i = 1 to objects.0 */

  say okCounter || " object(s) created, " || ,
      errorCounter || " object creation(s) failed."

exit

