/*  This REXX CMD File will copy the original versions of
    the five (5) major configuration files to the holding
    adirectory, D:\OS2\HOLDINI for safekeeping.  Only the
    most current version is retained.  However, an alter-
    nate FileNameExtension may be given upon prompting in
    order that multiple copies are saved.

    FileName:  SAVEINI.CMD
    Date:      August 1, 1993
    Author:    Chris Hascall
               49 McKinley Street
               South Portland ME 04106   USA
               1 (207) 799-8679

    Usage:  SAVEINI <switches>

         Switches:    (preceded by a '/' or '-')

                  ? - to produce a help "screen"

                  A - when present, indicates that prompting is
                      required for alternate file extension

                  O - automatically overwrite existing copies
                      without prompting

         Example:    SAVEINI /A /O


    Changes:    change default names of files/directories within
                the 'sin_init' procedure

    -------------------------------------------------------------------
*/

/* trace all */

/* ----------------------------------------------------------------------- */
/*      Globals                                                            */
/* ----------------------------------------------------------------------- */

'@ECHO OFF'                       /* do not display any SHELL commands */
global. = ""                      /* initialization                    */

/* ----------------------------------------------------------------------- */
/*      Main                                                               */
/* ----------------------------------------------------------------------- */

main:

     parse arg switches

     say " "
     say " " switches " switches selected"

     CALL sin_init

     IF Substr(switches, 1, 1) <> "-" & Substr(switches, 1, 1) <> "/",
      & Substr(switches, 1, 1) <> "?" THEN
     DO
        switches = ""
     END
     ELSE
     DO
        if Pos("?", switches) > 0 THEN
        DO
           CALL sin_help
           CALL sin_exit
        END
        global.prompt    = Pos("A", switches)
        global.overwrite = Pos("O", switches)
     END

     if global.prompt <> 0 THEN
     DO
        CALL sin_prompt
     END

     if global.overwrite = 0 THEN
     DO
        global.filespec = global.save_dir || "*." || global.f_extension
        CALL sin_copy_chek
     END

     if global.do_copy = 0 THEN
     DO
        copy global.auto_exec global.save_dir || "*." || global.f_extension
        copy global.config_s  global.save_dir || "*." || global.f_extension
        copy global.start_up global.save_dir || "*." || global.f_extension
        copy global.win_ini global.save_dir || "*." || global.f_extension
        copy global.win_sys_ini global.save_dir || "*." || global.f_extension
     END
     ELSE
     DO
        say " "
        say "       Files exist in target directory"
     END
     CALL sin_exit

  EXIT

/* ----------------------------------------------------------------------- */
/*      sin_init                                                           */
/* ----------------------------------------------------------------------- */

sin_init : PROCEDURE EXPOSE global.
/***************************************************************
**     initializes all global data                            **
**                                                            **
**     a. check whether RxFuncs are loaded, if not, load them **
**     b. set default values                                  **
**     c. create global file names with default (save) ext.   **
***************************************************************/

        if RxFuncQuery('SysLoadFuncs') THEN
        DO
           CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
           CALL SysLoadFuncs
        END

        global.prompt        = 0
        global.overwrite     = 0
        global.do_copy       = 0

        /********************************************
        ** Change the following defaults as neces- **
        ** sary.                                   **
        ********************************************/

        global.save_dir      = "D:\OS2\HOLDINI\"
        global.f_extension   = "SAV"
        global.auto_exec     = "D:\4DOS\AUTOEXEC.BAT"
        global.config_s      = "D:\CONFIG.SYS"
        global.start_up      = "D:\STARTUP.CMD"
        global.win_ini       = "F:\OS2\MDOS\WINOS2\WIN.INI"
        global.win_sys_ini   = "F:\OS2\MDOS\WINOS2\SYSTEM.INI"

        RETURN

/* sin_init */

/* ----------------------------------------------------------------------- */
/*      sin_prompt                                                         */
/* ----------------------------------------------------------------------- */

sin_prompt : PROCEDURE EXPOSE global.
/***************************************************************
**     gets the (save) filename extension from the user       **
***************************************************************/

        CALL SysCls

        say "Type extension to use for this Archive."
        say "For HPFS drive, this may exceed three "
        say "characters."
        say " "
        say " "
        pull user_ext
        say "Selected " user_ext " as global extension"
        say " "
        pause

        if user_ext <> " " THEN
        DO
           global.f_extension = user_ext
        END
        ELSE
        DO
           CALL SysCls
           say " "
           say " "
           say "Using global extension - " global.f_extension
           say " "
        END

        RETURN

/*  sin_prompt  */

/* ----------------------------------------------------------------------- */
/*      sin_copy_chek                                                      */
/* ----------------------------------------------------------------------- */

sin_copy_chek : PROCEDURE EXPOSE global.
/***************************************************************
**      the auto-overwrite flag is checked first to ensure    **
**      that previously saved files are not overwritten.      **
***************************************************************/

        CALL SysCls
        say " "
        say " "
        say "       Checking files in "global.save_dir

        call SysFileTree global.filespec, files, F

        global.do_copy = files.0

        say " "

        if files.0 > 0 THEN
        DO j = 1 to files.0
           say files.j
        END

        RETURN

/*  sin_copy_chek  */

/* ----------------------------------------------------------------------- **
**      sin_help                                                           **
** ----------------------------------------------------------------------- */

sin_help:    PROCEDURE EXPOSE global.
/***************************************************************
**                                                            **
**     prints a help message in response to request           **
**                                                            **
***************************************************************/

        CALL SysCls

        Say " "
        Say " Usage:  SAVEINI [{/|-}switches]"
        Say " "
        Say "     Possible switches are:"
        Say " "
        Say "        ?      this help"
        Say "        A      prompt for extensions to create"
        Say "        O      automatic overwrite of existing files"
        Say " "

        Say " "
        Say "     Created by Chris Hascall - 49 McKinley Street  "
        Say "                                South Portland ME  04106"
        Say "                                USA "

        RETURN

/* sin_help */

/* ----------------------------------------------------------------------- **
**      sin_exit                                                           **
** ----------------------------------------------------------------------- */

sin_exit:    PROCEDURE EXPOSE global.

        say " "
        say " "
        say " "
        say " "
        say "       SAVEINI has finished ...."
        say " "

        EXIT
