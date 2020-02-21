/* *****************************************************************************

        File:   BACK2FAT.CMD

        Author: Ralf Hauser (c≥o)
                e-mail:  affie@frege.sns.neuphilologie.uni-tuebingen.de

        Date:   22-07-92

        Ver:    1.00

        Desc:   Backs Up specified fileset on FAT drive
                using EABACKUP and ZOO.
                Resulting file may be further processed using a
                tape streamer running under DOS.

        Usage:  BACK2FAT  [{/|-}switches]  <fileset>  [target_path]

        Note:   Refer to the "b2f_init" function to setup
                user specific constants

        Requirements:

                OS/2 2.0 (V1.3 not tested, but should do)
                EABACKUP.EXE V2.x in PATH
                ZOO.EXE V2.x in PATH

                for restoring the backuped data:
                EARESTOR.EXE V2.x in PATH
                ZOO.EXE V2.x in PATH

--------------------------------------------------------------------------
History:
22-07-92 co     Created
-------------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*      Globals                                                            */
/* ----------------------------------------------------------------------- */

'@ECHO OFF'                       /* do not display any SHELL commands */
global. = ""                      /* init */

/* ----------------------------------------------------------------------- */
/*      Main                                                               */
/* ----------------------------------------------------------------------- */

Main :
        CALL b2f_init             /* initialize global data structures */

        /*
         *    handle arguments
         */

        Parse Arg switches fileset target

        IF Arg() = 0 THEN
           CALL b2f_help

        /* header */
        Say " "
        Say global.title || "   V" || global.version,
            "       a c≥o tool - 4 use if u like it"
        Say " "

        /* look whether switches are specified */
        IF Substr(switches, 1, 1) <> "-" & Substr(switches, 1, 1) <> "/" THEN DO
           /* no, so shift arguments */
           target   = fileset
           fileset  = switches
           switches = ""
           END
        ELSE DO /* handle switches */
           IF Pos("?", switches) > 0 THEN
              CALL b2f_help
           global.log       = Pos("l", switches)
           global.debug     = Pos("d", switches)
           global.overwrite = Pos("k", switches)
           END

        /*
         *    determine filespec in fileset
         */

        source = b2f_get_filespec(fileset)
        Say global.title || ": Creating backup of '" || source || "\" || global.filespec || "' ..."

        /*
         *    create target directory
         */

        IF target = "" THEN
           target = global.target_drive || global.target_path

        /* test for absolute path specification */
        IF Substr(target, 2, 1) <> ":" | Substr(target, 3, 1) <> "\" THEN
           CALL b2f_error "A full targetpath must be specified - ", "'" || target || "' is not a full targetpath."

        Say global.title || ": Creating target directory '" || target || "' ..."

        IF b2f_dir_exist(target) THEN DO
           IF global.overwrite = 0 THEN DO
              Say global.title || ": Target directory '" || target "' already exists! Clear? [Y/N]"
              Pull answer
              IF answer <> "y" & answer <> "Y" THEN
                 CALL b2f_error "Cannot work on '" || target || "' as it contains files."
              END
           Say global.title || ": Deleting contents of target directory ..."
           CALL b2f_kill_dir target
           END
        ELSE
           CALL b2f_make_dir target

        /*
         *    create a filelist
         */

        CALL b2f_filelist source target

        /*
         *    create a backup of extended attributes
         */

        CALL b2f_ea_backup source target

        /*
         *    create a backup of files
         */

        CALL b2f_backup source target

        /*
         *    create a backup of fileslisting of all errors
         */

        IF global.log <> 0 THEN
           CALL b2f_list_errors target

        /*
         *    create an info file
         */

        CALL b2f_info source target fileset

        /*
         *    close
         */

        IF global.debug <> 0 THEN DO
           Say global.title || ": DEBUG: All files in " || target
           DIR "/P /N" target
           END

        /* that's it */
        Say global.title || ": Successfully terminated!"
        /* jippeeh */
        Call beep 2000, 200
        Call beep 1600, 200
EXIT

/* ----------------------------------------------------------------------- */
/*      b2f_init                                                           */
/* ----------------------------------------------------------------------- */

b2f_init : PROCEDURE EXPOSE global.
/*
 *      initializes all global data
 */
        /* check whether RxFuncs are loaded, if not, load them */
        IF RxFuncQuery('SysLoadFuncs') THEN DO
           /* load the load-function */
           CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
           /* load the Sys* utilities */
           CALL SysLoadFuncs
           END
        /* set default values */
        global.title         = "BACK2FAT"
        global.version       = "1.00"
        global.fnam_infofile = "BACKUP.DOC"
        global.fnam_listfile = "BACKUP.LST"
        global.fnam_errfile  = "BACKUP.ERR"
        global.fnam_backup   = "BACKUP.ZOO"
        global.fnam_eabkup1  = "EA@BDATA.EAB"
        global.fnam_eabkup2  = "EA@INDEX.EAB"
        global.sepline       = "-------------------------------------------------------------------------"
        global.log           = 0
        global.debug         = 0
        global.overwrite     = 0

        /*****************************************************************
         *    USER-SPECIFIC section
         */

        /* EA Backup service */
        global.eabckup_pgm   = "EABACKUP.EXE"    /* must be executable; you may add a path */
        global.eabckup_add   = " "     /* additional switches for EABACKUP program */
        /* Backup service */
        global.bckup_pgm     = "ZOO.EXE"         /* must be executable; you may add a path */
        global.bckup_add     = " "     /* additional switches for BACKUP program */

        global.target_drive  = "D:"         /* FAT drive */
        global.target_path   = "\_BACKUP_"  /* default directory on FAT drive */
        global.filespec      = "*"          /* wildcard for files to be backuped */

        /*
         *      fileset: not only a name but a subdirectory in the root directory;
         *               all files in the subdirectory are backuped
         *
         *      A fileset must be a string of the form "set --> drive/path spec"
         */

        global.fileset.1     = "OS2  -->   C:\OS2"    /* OS2 system files */
        global.fileset.2     = "APP  -->   C:\APP"    /* applications */
        global.fileset.3     = "BIN  -->   C:\BIN"    /* 'binaries', tools */
        global.fileset.4     = "ETC  -->   C:\ETC"    /* other system files */
        global.fileset.5     = "LIB  -->   C:\LIB"    /* libraries */
        /* ... more ... */
        global.fileset_num   = 5       /* must contain number of filesets! */

        /*
         *    END OF USER-SPECIFIC section
         *****************************************************************/

        /* check user defined section */
        /* because there are always some guys wanting to see the program fail */
        DO i = 1 TO global.fileset_num
           IF Words(global.fileset.i) <> 3 THEN
              CALL b2f_error "Syntax error in user section:", "'" || global.fileset.i "' is invalid."
           IF Word(global.fileset.i, 2) <> "-->" THEN
              CALL b2f_error "Syntax error in user section:", "'-->' missing in: '" || global.fileset.i "'"
        END

        RETURN

/* b2f_init */

/* ----------------------------------------------------------------------- */
/*      b2f_error                                                          */
/* ----------------------------------------------------------------------- */

b2f_error : PROCEDURE EXPOSE global.
Parse Arg msg, msg1, msg2

        Say global.title || ": An error occured:"
        CALL Beep 500, 200
        CALL Beep 900, 200
        CALL Beep 500, 200
        Say " "
        Say "   Error: " || msg
        IF msg1 <> "" THEN
           Say "          " || msg1
        IF msg2 <> "" THEN
           Say "          " || msg2

        EXIT

/* b2f_error */

/* ----------------------------------------------------------------------- */
/*      b2f_help                                                           */
/* ----------------------------------------------------------------------- */

b2f_help : PROCEDURE EXPOSE global.
/*
 *      Prints a help
 */
        Say " "
        Say " Usage: " || global.title || " [{/|-}switches]  <fileset>  [targetpath]"
        Say " "
        Say "     Possible switches are:"
        Say " "
        Say "        ?      this help"
        Say "        l      create log files"
        Say "        d      display additional debug info"
        Say "        k      kill files in target directory"
        Say " "
        Say "     Possible filesets are: "
        Say " "

        DO i = 1 TO global.fileset_num
           Say "        " || global.fileset.i
        END

        Say " "
        Say "     Manually generated by Ralf Hauser (c≥o), 7400 TÅbingen"
        Say "     e-mail: affie@frege.sns.neuphilologie.uni-tuebingen.de"

        EXIT

/* b2f_help */

/* ----------------------------------------------------------------------- */
/*      b2f_get_filespec                                                   */
/* ----------------------------------------------------------------------- */

b2f_get_filespec : PROCEDURE EXPOSE global.
/*
 *      return the filespec of the corresponding fileset
 */
Arg fset
        DO i = 1 TO global.fileset_num
           IF Word(global.fileset.i, 1) = fset THEN
              RETURN Word(global.fileset.i, 3)
        END
        CALL b2f_error "The specified set '" || fset || "' does not exist."
        RETURN " "          /* shutup compiler */

/* b2f_get_filespec */

/* ----------------------------------------------------------------------- */
/*      b2f_dir_exist                                                      */
/* ----------------------------------------------------------------------- */

b2f_dir_exist : PROCEDURE
/*
 *      return TRUE if specified directory exists
 */
Arg dirname

        CALL SysFileTree dirname, "file", "D"

        RETURN file.0

/* b2f_dir_exist */

/* ----------------------------------------------------------------------- */
/*      b2f_kill_dir                                                       */
/* ----------------------------------------------------------------------- */

b2f_kill_dir : PROCEDURE
/*
 *      kill the contents of the spec directory
 *      return TRUE if successfull
 */
Arg dirname

        CALL SysFileTree dirname || "\*", "file", "F"

        DO i = 1 TO file.0
           filename = word(file.i, 5)
           /* Say "     (Deleting '" || filename || "')" */
           CALL SysFileDelete filename
        END

        RETURN

/* b2f_kill_dir  */

/* ----------------------------------------------------------------------- */
/*      b2f_make_dir                                                       */
/* ----------------------------------------------------------------------- */

b2f_make_dir : PROCEDURE
/*
 *      create a new directory
 */
Arg dirname

        IF SysMkDir(dirname) <> 0 THEN
           CALL b2f_error "Could not create '" || dirname || "' as a directory."

        RETURN

/* b2f_make_dir  */

/* ----------------------------------------------------------------------- */
/*      b2f_info                                                         */
/* ----------------------------------------------------------------------- */

b2f_info : PROCEDURE EXPOSE global.
Arg source target fileset

        filename = target || "\" || global.fnam_infofile
        rc = 0

        Say global.title || ": Creating infofile '" || filename || "' ..."

        CALL Lineout filename, "BACKUP INFO"
        CALL Lineout filename, global.sepline
        CALL Lineout filename, "Programname......:" global.title
        CALL Lineout filename, "Date.............:" Date("L")
        CALL Lineout filename, "Time.............:" Time("N")
        CALL Lineout filename, " "
        CALL Lineout filename, "Fileset..........:" fileset
        CALL Lineout filename, "Sourcepath.......:" source
        CALL Lineout filename, "Filespec.........:" global.filespec
        CALL Lineout filename, "Targetpath.......:" target
        CALL Lineout filename, " "
        CALL Lineout filename, "Infofile.........:" global.fnam_infofile "(This file)"
        CALL Lineout filename, "Listfile.........:" global.fnam_listfile
        CALL Lineout filename, "Backupfile.......:" global.fnam_backup
        CALL Lineout filename, "EA Backupfile 1..:" global.fnam_eabkup1
        CALL Lineout filename, "EA Backupfile 2..:" global.fnam_eabkup2
        CALL Lineout filename, "Error listing....:" global.fnam_errfile
        IF global.log <> 0 THEN DO
           CALL Lineout filename, " "
           CALL Lineout filename, "Log files........: *.LOG"
           END
        CALL Lineout filename, global.sepline
        CALL Lineout filename

        IF rc > 0 THEN
           CALL b2f_error "Could not create '" || filename || "' as an infofile.", "RC: " || rc

        IF global.debug <> 0 THEN DO
           Say global.title || ": DEBUG: INFOFILE"
           TYPE filename " | more "
           END

        RETURN

/* b2f_info */

/* ----------------------------------------------------------------------- */
/*      b2f_filelist                                                       */
/* ----------------------------------------------------------------------- */

b2f_filelist : PROCEDURE EXPOSE global.
Arg source target

        filename = target || "\" || global.fnam_listfile
        rc = 0

        Say global.title || ": Creating filelist '" || filename || "' ..."

        CALL Lineout filename, "FILELIST"
        CALL Lineout filename, global.sepline

        CALL SysFileTree source || "\" || global.filespec, "file", "FS"

        DO i=1 to file.0
           CALL Lineout filename, file.i
        END

        CALL Lineout filename, global.sepline
        CALL Lineout filename, " " || file.0 || " files."
        CALL Lineout filename, global.sepline
        CALL Lineout filename

        IF rc > 0 THEN
           CALL b2f_error "Could not create '" || filename || "' as a filelist.", "RC: " || rc

        IF global.debug <> 0 THEN DO
           Say global.title || ": DEBUG: FILELIST"
           TYPE filename " | more "
           END

        RETURN

/* b2f_filelist */

/* ----------------------------------------------------------------------- */
/*      b2f_ea_backup                                                      */
/* ----------------------------------------------------------------------- */

b2f_ea_backup : PROCEDURE EXPOSE global.
Arg source target

        IF SysSearchPath("PATH", global.eabckup_pgm) = "" THEN
           CALL b2f_error "Could not find EABACKUP service:", "'" || global.eabckup_pgm "' must exist in Environment PATH"

        Say global.title || ": Spawning '" || global.eabckup_pgm || "' ..."
        rc = 0

        IF global.log <> 0 THEN
           global.eabckup_pgm source target,
                    "/S /Q /I" global.eabckup_add,
                    " > " target || "\EABACKUP.LOG"
        ELSE
           global.eabckup_pgm source target,
                    "/S /Q /I" global.eabckup_add

        IF rc > 0 THEN
           CALL b2f_error "Could not run EABACKUP service:", "'" || global.eabckup_pgm || "' terminated abnormally!", "RC: " || rc

        RETURN

/* b2f_ea_backup */

/* ----------------------------------------------------------------------- */
/*      b2f_backup                                                         */
/* ----------------------------------------------------------------------- */

b2f_backup : PROCEDURE EXPOSE global.
Arg source target

        IF SysSearchPath("PATH", global.bckup_pgm) = "" THEN
           CALL b2f_error "Could not find BACKUP service in path", "'" || global.bckup_pgm "' must exist in Environment PATH"

        tmpfile = target || "\" || "_list_.tmp"

        /* create a tmp file containg all filenames to be backuped */
        CALL SysFileTree source || "\" || global.filespec, "file", "FS"
        /* (I know that this "tree walking job" is done twice, but I prefered
           an encapsulation of procedures. If you use another backup service
           as ZOO you must use another way of specifying files either...) */

        offset = 38   /* column where filename starts in output of FileTree */
        DO i=1 to file.0
           filename = Substr(file.i, offset)
           /* Say "filename: " filename */
           CALL Lineout tmpfile, filename
        END
        CALL Lineout tmpfile

        IF global.debug <> 0 THEN DO
           Say global.title || ": DEBUG: FILELIST FOR ZOO.EXE"
           TYPE tmpfile " | more "
           END

        Say global.title || ": Spawning '" || global.bckup_pgm || "' ..."
        rc = 0

        IF global.log <> 0 THEN
          TYPE tmpfile " | " ,
               global.bckup_pgm "aPI" global.bckup_add,
               target || "\" || global.fnam_backup,
               " > " target || "\ZOO.LOG"
        ELSE
          TYPE tmpfile " | " ,
               global.bckup_pgm "aPI" global.bckup_add,
               target || "\" || global.fnam_backup

        /* it seems that something is wrong with ZOO.EXE
           since it returns with an exitcode of "1"
           although no errors occur... */
        IF rc > 1 THEN
           CALL b2f_error "Could not run BACKUP service:", "'" || global.bckup_pgm || "' terminated abnormally!", "RC: " || rc

        /* remove tmp file */
        CALL SysFileDelete tmpfile

        RETURN

/* b2f_backup */

/* ----------------------------------------------------------------------- */
/*      b2f_list_errors                                                    */
/* ----------------------------------------------------------------------- */

b2f_list_errors : PROCEDURE EXPOSE global.
Arg target

        /* examine all .LOG files */
        CALL SysFileTree target || "\*.LOG", "file", "F"
        offset = 38   /* column where filename starts in output of FileTree */
        DO i=1 to file.0
           filename = Substr(file.i, offset)
           CALL b2f_list_errors_in_file filename
        END
        RETURN

/* b2f_list_errors target */

/* ----------------------------------------------------------------------- */
/*      b2f_list_errors_in_file                                            */
/* ----------------------------------------------------------------------- */

b2f_list_errors_in_file : PROCEDURE EXPOSE global.
Arg filename

        Say global.title || ": Checking '" || filename || "' for errors ..."
        linenum = 0;

        DO FOREVER
           buffer = Linein(filename)
           linenum = linenum + 1
           IF Pos("error", buffer) > 0 THEN DO
              Say "   #" || Format(linenum, 4) || ":  " Strip(buffer, "B")
              END
           IF lines(filename) = 0 THEN
              LEAVE
        END

        RETURN

/* b2f_list_errors_in_file */

/* <EOF> */

