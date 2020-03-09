/*
program: showini.cmd
type:    REXXSAA-OS/2, OS/2 2.0
purpose: allow for viewing, editing, backing up & restoring of OS/2-INI-files
version: 2.0
date:    1992-06-01
changed: 1992-06-02, RGF, changed text appearing on key-value-menu
         1992-06-10, RGF, removed last debug-information from error-message
         1992-06-20, RGF, introduced ability to have fewer than the default of
                          10 generations for backups
         1992-07-01, RGF, introduced batch-file execution on entire filesystems
                          and on OS2.INI and OS2SYS.INI.

author:  Rony G. Flatscher
         RONY@AWIWUW11.BITNET
         rony@wu-wien.ac.at

usage:   
   SHOWINI: allow to view, edit, print, backup, restore OS/2-INI-files
  
   showini        ... allow to work interactively
  
   showini /switch[generations]  {filename | /modifier}  ... batch-mode execution

       switch:    B[T]   ... make a BACKUP of an OS/2-INI-file
                  U[T]   ... UPDATE original OS/2-INI using a backup
                  R[T]   ... RESTORE original OS/2-INI using a backup, i.e. delete
                             keys not found in backup
                    T    ... backup is a text-file (i.e. ASCII-file)

       generations: a number between 1-10, indicating how many backup-files you
                    want, respectively, which backup you wish to use

       filename: filename of OS/2-INI-file or the filename of the backup
       ---or---
       modifier: look for all OS/2-INI-files on the filesystem[s]:

                 L[OCAL]  ... only LOCAL filesystems are scanned
                 R[EMOTE] ... only REMOTE filesystems are scanned
                 A[LL] ...... both, LOCAL and REMOTE filesystems are scanned
                 D[RIVES]:letters ... only the given driveletters are scanned,
                                      where letters is e.g. ACDEH

                 process OS/2-system INI-files:

                 S[YSTEM] ... "OS2SYS.INI" only
                 U[SER] ..... "OS2.INI" only
                 B[OTH] ..... both, "OS2SYS.INI" and "OS2.INI"

needs:   all RxUtil-functions loaded, BOXEDIT.CMD




1) Working interactively with OS/2-INI-files
============================================

SHOWINI.CMD allows you to interactively
 
    a) view
    b) print to text-(ASCII)-file
    c) edit
    d) move/copy
    e) delete
    f) configure SHOWINI.CMD

Toplevel entries ("Application entries") and key-entries in OS/2-INI-files. Just
enter:

     showini

Initially you will **not** see the menu choices for editing, moving/copying and
deleting INI-entries for safety reasons. In addition there is an option to log 
backup/update/restore operations; if you set this option to no an existing 
logfile will be erased (it has a name of "SHOWINI.LOG" and resides in the same 
directory as SHOWINI.CMD itself).

Also, you will get a choice to work with OS2.INI (USER) and OS2SYS.INI (SYSTEM).  
With "s" for scan you can have SHOWINI.CMD to automatically scan for valid 
OS/2-INI-files on all local and/or remote drives or a specific drive, it will 
successfully ignore Winodows-INI-files.  

Once you configure one of the above manipulative functions the configuration 
choice will be shown, if you reset them, it will not be shown anymore.  
Therefore you could safely leave this program on a machine for end-users.

In order to activate the edit, move/copy and/or delete functions, you need to 
enter "c" (configure) on the main menu.  This option will allways be accessible 
from the INI- and TopLevel-menus, no matter whether it is displayed or not.  All 
these settings will be stored in OS2.INI under the TopLevel-entry called "RGF 
Showini.cmd".  Hint:  If there are many entries in an INI-file, use the 
MODE-command to get more lines or more columns and/or lines:

       e.g. "MODE co80,100" for 100 lines or
            "MODE co132,50" for 132 columns and 50 lines on an XGA-adapter

Hint: Wherever it is possible from the program logic, you may immeditiately end 
SHOWINI.CMD by typing "q" (quit). Attention: if quitting the program, changes to
the settings are not stored in OS2.INI.


2) Batchfile-commands
=====================

SHOWINI.CMD allows for

        backing up and ***restoring*** INI-files while the system is running ! 

This means that you can backup even OS2.INI and OS2SYS.INI while the system is 
up and restore them from a backup while the system is running. SHOWINI.CMD 
by default produces **10-generation** backups.


a) syntax:
----------

   showini /switch[generations]  {filename | /modifier}  

       switch:    B[T]   ... make a BACKUP of an OS/2-INI-file
                  U[T]   ... UPDATE original OS/2-INI using a backup
                  R[T]   ... RESTORE original OS/2-INI using a backup, i.e. 
                             delete keys not found in backup
                    T    ... backup is a text-file (i.e. ASCII-file), else 
                             backup is a valid OS/2-INI-file

       generations: an optional number between 1-10, indicating how many
                    backup-files you want, respectively, which backup you 
                    wish to use; please note: backups will be numbered from
                    0 (= 1. generation) thru 9 (= 10. generation), e.g. 
                    ".IN0", ".TX9"

       filename: filename of OS/2-INI-file or the filename of the backup
       --- or ---
       modifier: 
                look for all OS/2-INI-files on the filesystem[s]:

                 L[OCAL]  ... only LOCAL filesystems are scanned
                 R[EMOTE] ... only REMOTE filesystems are scanned
                 A[LL] ...... both, LOCAL and REMOTE filesystems are scanned
                 D[RIVES]:letters ... only the given driveletters are scanned,
                                      where letters is e.g. ACDEH

                 process OS/2-system INI-files:

                 S[YSTEM] ... "OS2SYS.INI" affected only
                 U[SER] ..... "OS2.INI" afftected only
                 B[OTH] ..... both, "OS2SYS.INI" and "OS2.INI" affected



b) examples (pertaining to single files):
-----------------------------------------

   showini /b d:\os2\os2.ini
        ... make a backup of OS2.INI, resulting backup will be in an 
            OS/2-INI-format ("/B") and will have an extension of ".IN0", 
            ".IN1", ".IN2", ".IN3", ".IN4", ".IN5", ".IN6", ".IN7", ".IN8",
            ".IN9" depending on how many backups exist already.

   showini /bt4 e:\os2\os2sys.ini
        ... make a backup of OS2SYS.INI, resulting backup will be in a
            TEXT-format ("/BT", i.e. ASCII, editable by any text-editor) and 
            will have an extension of ".TX0", ".TX1", ".TX2", ".TX3", depending
            on how many backups exist already.

            Note: There are four generations desired ("/BT4") only. In case
                  there are more generations present, because beforehand you
                  used the default of 10 generations, all superfluos backups
                  will be deleted (oldest first) !

   showini /u c:\mamma_mia\mutter.in9
        ... update "mutter.ini" according to the backup-values in "mutter.in9" 
            which is in an OS/2-INI-format ("/U"). 

            Note: If "mutter.ini" does not exist, SHOWINI.CMD prompts the user
                  whether to create it !

   showini /rt q:vater.tx5
        ... restore "vater.ini" according to the backup-values in "vater.tx5"
            which is in TEXT-format ("/RT", i.e. ASCII-format, editable by 
            any text-editor).

            Note: The "restore"-operation deletes all Toplevels and Keys in the 
                  original OS/2-INI-file, which are not found in the backup. If 
                  you do not want to delete those entries, use the "update"-mode
                  instead !

            Note: If "vater.ini" does not exist, SHOWINI.CMD prompts the user
                  whether to create it !

            Note: If the name of the original OS/2-INI-file in the backup 
                  "vater.tx5" is another name like "father.ini", SHOWINI.CMD 
                  will work on that INI-file.

The switches B, U, R pertain to OS/2-INI-backup-files, BT, UT, RT to 
TEXT-backup-files.



c) examples (pertaining to filesystems, or OS2.INI, OS2SYS.INI):
----------------------------------------------------------------

   showini /b /local
   --- same as:
   showini /b /l

        ... make a backup of all OS/2 INI-files on all local drives, resulting
            backups will be in an OS/2-INI-format ("/B") and will have an
            extension of ".IN0", ".IN1", ".IN2", ".IN3", ".IN4", ".IN5", 
            ".IN6", ".IN7", ".IN8", ".IN9" depending on how many backups exist
            already.

   showini /b5 /local
   --- same as:
   showini /b5 /l

        ... make a backup of all OS/2 INI-files on all local drives, resulting
            backups will be in an OS/2-INI-format ("/B") and will have an
            extension of ".IN0", ".IN1", ".IN2", ".IN3", ".IN4", depending on
            how many backups exist already.

            Note: There are five generations desired ("/BT5") only. In case
                  there are more generations present, because beforehand you
                  used the default of 10 generations, all superfluos backups
                  will be deleted (oldest first) !

   showini /bt /local
   --- same as:
   showini /bt /l

        ... make a backup of all OS/2 INI-files on all local drives, resulting
            backups will be in TEXT-format ("/BT") and will have an
            extension of ".TX0", ".TX1", ".TX2", ".TX3", ".TX4", ".TX5", 
            ".TX6", ".TX7", ".TX8", ".TX9" depending on how many backups exist
            already.

   showini /b /remote
   --- same as:
   showini /b /r

        ... make a backup of all OS/2 INI-files on all remote drives, resulting
            backups will be in an OS/2-INI-format ("/B") and will have an
            extension of ".IN0", ".IN1", ".IN2", ".IN3", ".IN4", ".IN5", 
            ".IN6", ".IN7", ".IN8", ".IN9" depending on how many backups exist
            already.

   showini /bt1 /all
   --- same as:
   showini /bt1 /a

        ... make a backup of all OS/2 INI-files on all drives, local and remote,
            resulting backups will be in TEXT-format ("/BT") and will have an
            extension of ".TX0".

            Note: There is one generation desired ("/BT1") only. In case there
                  are more generations present, because beforehand you used more
                  than one generation, all superfluos backups will be deleted
                  (oldest first) !

   showini /b /drives:adf
   --- same as:
   showini /b /d:adf

        ... make a backup of all OS/2 INI-files on drives "A", "D", "F",
            resulting backups will be in an OS/2-INI-format ("/B") and will have
            an extension of ".IN0", ".IN1", ".IN2", ".IN3", ".IN4", ".IN5",
            ".IN6", ".IN7", ".IN8", ".IN9" depending on how many backups exist
            already.


    showini /u /a

        ... update all OS/2-INI-files found on all drives, remote and local, 
            with backups in OS/2-INI-format. 

            Note: The latest backup will be used for updating the original 
                  OS/2-INI-files.

    showini /ut5 /a

        ... update all OS/2-INI-files found on all drives, remote and local, 
            with backups in TEXT-format. SHOWINI.CMD uses the 5th backup
            (i.e. extension ".TX4"), if not found any backup which is before the
            5th.


    showini /r /a

        ... update all OS/2-INI-files found on all drives, remote and local, 
            with backups in OS/2-INI-format.

            Note: The "restore"-operation deletes all Toplevels and Keys in the 
                  original OS/2-INI-file, which are not found in the backup. If 
                  you do not want to delete those entries, use the "update"-mode
                  instead !

            Note: The latest backup will be used for updating the original 
                  OS/2-INI-files.


   showini /b /user
   --- same as:
   showini /b /u

        ... backup "OS2.INI".

   showini /rt4 /system
   --- same as:
   showini /rt4 /s

        ... restore "OS2SYS.INI" from a TEXT-backup. Use the fourth, if not 
            found a younger, generation.

   showini /ut /both
   --- same as:
   showini /ut /b

        ... update both, "OS2.INI" and "OS2SYS.INI", with the latest 
            TEXT-backup.

3) EXIT-codes
=============

 0 ... everything went o.k.
-1 ... user aborted program
-2 ... wrong switch or invalid filename
-3 ... invalid backup-file


4) minimal layout of text-(ASCII)-backup-files
==============================================

        ; a line starting with a semi-column is a comment and is ignored
        ; blank lines are ignored as well

        ; the file entry must be included and be given before the TopLevel- and
        ; key-entries; it may span multiple lines (for long filenames) and has
        ; the principal layout
        ;
        ;          "File [file name]"
        ; delimiter for the value is allways an opening and ending square 
        ; bracket

        File  [D:\work\klondike.ini] 
        
        ; A TopLevel (application) entry starts with the keyword "Top"; is being
        ; followed by the datatype [A], [A0] or [H] for ASCII, ASCII-Z, resp.
        ; hexadecimal; the last entry is the value enclosed in square brackets.
        ; 
        ; The same syntax applies to the key-names ("Key") and finally to the
        ; values themselves ("Val").
        ;
        ; Any Value for TopLevel-names, Key-names and Key-values may span 
        ; multiple lines; if so, subsequent lines must not contain a key-word,
        ; but the data-type and the value.


        Top [A]  [PATIENCE]
            Key  [A]  [CardBack]

        ; the key-value is of ASCII-string, terminated by \0; note that the 
        ; terminating '00'x is not contained within the value part:

                 Val  [A0] [2]

        ; the following key-value spans two lines:

            Key  [A]  [ColorSet]
                 Val  [A0] [13]
                      [A0] [03]
        
        ; this is an example for hexadecimal values for all three, 
        ;TopLevel-name, key-name and key-value:

        Top [H]  [01020304050607]
            Key  [H]  [08091011]
                 Val  [H]  [12131415]

        ; note values enclosed in the square-bracket-delimiters may contain
        ; square brackets themselves:

        Top [A]  [This is another TopLevel-entry [yes, another]]
            Key  [A]  [This is another key-entry]
                 Val  [A]  [This is a plain ASCII-entry.]
            Key  [A]  [This is the second key-entry, within this TopLevel.]
                 Val  [A0] [This is an ASCII-Z entry.]

For further examples of the syntax of the text-(ASCII)-file see any printout or
text-(ASCII)-backup.
        
All rights reserved, copyrighted 1992, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything (money
etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

you may freely distribute this program, granted that no changes are made
to it

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.

*/

SIGNAL ON HALT
SIGNAL ON ERROR

global. = ""                    /* default to empty string */


/* place logfile into the same directory as this program */
PARSE SOURCE . . name_path      /* get full name & path of this program */
global.eLogFile = SUBSTR(name_path, 1, LASTPOS(".", name_path)) || "LOG"

CALL initialize                 /* initialize array "global."           */

IF ARG(1) <> "" THEN         /* arguments are given */
   CALL backup_restore_update ARG(1)

CALL show_inis                  /* show OS/2-INI-files                  */
CALL write_ini_settings         /* write settings for this program      */

EXIT 0                          /* normal exit */

/****************************************************************/

INITIALIZE: PROCEDURE EXPOSE global.
    /* check whether RxFuncs are loaded, if not, load them */
    IF RxFuncQuery('SysLoadFuncs') THEN
    DO
        /* load the load-function */
        CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'       

        /* load the Sys* utilities */
        CALL SysLoadFuncs                                                 
    END

    /* define some ANSI.SYS-colors */
    esc    = '1B'x          /* escape-char */
    
    
    /* define ANSI-colors */
    global.iRedWhite    = esc||"[31;47m"    /* ANSI.SYS-control for red foreground */
    global.iYellow = esc||"[33;40m"    /* ANSI.SYS-control for yellow foreground */
    global.iCyan   = esc||"[36;40m"    /* ANSI.SYS-control for cyan foreground */
    global.iNormal = esc||"[0;40m"     /* ANSI.SYS-control for resetting attributes to normal */
    global.iScrLength = LENGTH(global.iRedWhite)

    /* hint for options */
    global.defaultHint = global.iCyan || "(" || global.iYellow || "default" || global.iCyan || ")"
    /* hint for default yes or no */
    global.yesHint = global.iCyan || " (" || global.iYellow || "Y" || global.iCyan || "/N) " || global.iYellow
    global.noHint  = global.iCyan || " (Y/" || global.iYellow || "N" || global.iCyan || ") " || global.iYellow

    /* get screen dimensions */
    PARSE VALUE SysTextScreenSize() WITH row columns
    global.iRows = row
    global.iColumns = columns
    global.iBlankLine = global.iRedWhite || RIGHT("", columns - 1) || global.iCyan
    
    global.iNonPrintable = XRANGE("00"x, "1F"x) || D2C(255)
    global.iFilter       = COPIES("FA"x, 256)

    /* define leadin for menus */
    global.enterString = global.iCyan || "Enter:" global.iYellow || "1" || global.iCyan || "-" || global.iYellow

    /* define data-type strings */
    global.dType.H        = "[H]"
    global.dType.H.long   = "hexadecimal"
    global.dType.A        = "[A]"
    global.dType.A.long   = "ASCII"
    global.dType.A0       = "[A0]"
    global.dType.A0.long  = "ASCII delimited by \0"
    global.dType.F        = "[F]"
    global.dType.longest  = 4           /* length of "[A0]" */

    /* define leadins for printout */
    global.format.forTop        = "Top "
    global.format.forTop.Length = LENGTH(global.format.forTop)
    global.format.forTop.LeadIn = COPIES(" ", global.format.forTop.Length) 
    global.format.forKey        = "    Key  "
    global.format.forKey.Length = LENGTH(global.format.forKey)
    global.format.forKey.LeadIn = COPIES(" ", global.format.forKey.Length) 
    global.format.forVal        = "         Val  "
    global.format.forVal.Length = LENGTH(global.format.forVal)
    global.format.forVal.LeadIn = COPIES(" ", global.format.forVal.Length) 


    /* define information for Level of depth */
    global.depthOfOutput.T = "TopLevels only"
    global.depthOfOutput.K = "TopLevels + Keys"
    global.depthOfOutput.V = "TopLevels + Keys + Key-Values"

    /* define information for range of printout */
    global.rangeOfPrintout.AI   = "ALL OS/2-INI-files in hand"
    global.rangeOfPrintout.AT   = "ALL TopLevel-entries"
    global.rangeOfPrintout.AK   = "ONE TopLevel-entry, ALL keys"
    global.rangeOfPrintout.K    = "ONE Key"

    /* define information for output type, if hexadecimal value in hand */
    global.hextypeOfOutput.H = "hexadecimal-string only"
    global.hextypeOfOutput.F = "filtered ASCII-string only"
    global.hextypeOfOutput.B = "both, hexadecimal- and filtered ASCII-string"


    /* get defaults from previous settings of user from USER ("OS2.INI") */
    global.config.showTopLevel      = "RGF Showini.cmd"   /* TopLevel name for this application */
    global.config.add.indTopLevel   = 0         /* configuration defaults */
    global.config.add.indKey        = 0         /* configuration defaults */
    global.config.change.indKey     = 0         /* configuration defaults */
    global.config.delete.indAllKeys = 0         /* configuration defaults */
    global.config.delete.indKey     = 0         /* configuration defaults */
    global.config.move.indAllKeys   = 0         /* configuration defaults */
    global.config.move.indKey       = 0         /* configuration defaults */
    global.config.copy.indAllKeys   = 0         /* configuration defaults */
    global.config.copy.indKey       = 0         /* configuration defaults */
    CALL read_ini_settings                      /* read previous values from USER */
    CALL check_option_set                       /* show configuration option ? */

    /* Keys for backup-entries into USER resp. backup */
    global.bkp.iOName      = "backup.info1.origName"
    global.bkp.iBName      = "backup.info2.bkpName"
    global.bkp.iTLentries  = "backup.info3.# of TopLevels"
    global.bkp.iDTimeStart = "backup.info4.date/time.start"
    global.bkp.iDTimeEnd   = "backup.info5.date/time.end"

    /* batch-mode-switches */
    global.eMultipleFiles = 0                   /* batch mode with multiple files ? */

    RETURN

/*
   check whether configuration-option should be displayed
*/
CHECK_OPTION_SET: PROCEDURE EXPOSE global.
    /* if any of the options are set, show configuration option in first menu */
    global.showConfigure = global.config.add.indTopLevel | global.config.add.indKey | global.config.change.indKey |,
                           global.config.delete.indAllKeys | global.config.delete.indKey | global.config.move.indAllKeys |,
                           global.config.move.indKey | global.config.copy.indAllKeys | global.config.copy.indKey          
    RETURN


/* 
   read settings stored in OS2.INI and define default settings
*/
READ_INI_SETTINGS: PROCEDURE EXPOSE global.

    tmp = SysIni("USER", global.config.showTopLevel, "activateLog")     /* keep a LOG-file ? */
    IF tmp <>"ERROR:" THEN global.config.eLog = tmp
                      ELSE global.config.eLog = "1"                     /* default: log */

    tmp = SysIni("USER", global.config.showTopLevel,"add.TopLevel")
    IF tmp <>"ERROR:" THEN global.config.add.indTopLevel = tmp

    tmp = SysIni("USER", global.config.showTopLevel,"add.Key")
    IF tmp <>"ERROR:" THEN global.config.add.indKey = tmp

    tmp = SysIni("USER", global.config.showTopLevel,"change.Key")
    IF tmp <>"ERROR:" THEN global.config.change.indKey = tmp


    tmp = SysIni("USER", global.config.showTopLevel,"delete.AllKeys")
    IF tmp <>"ERROR:" THEN global.config.delete.indAllKeys  = tmp

    tmp = SysIni("USER", global.config.showTopLevel,"delete.Key")
    IF tmp <>"ERROR:" THEN global.config.delete.indKey  = tmp

    tmp = SysIni("USER", global.config.showTopLevel,"move.AllKeys")
    IF tmp <>"ERROR:" THEN global.config.move.indAllKeys = tmp

    tmp = SysIni("USER", global.config.showTopLevel,"move.Key")
    IF tmp <>"ERROR:" THEN global.config.move.indKey = tmp

    tmp = SysIni("USER", global.config.showTopLevel,"copy.AllKeys")
    IF tmp <>"ERROR:" THEN global.config.copy.indAllKeys = tmp

    tmp = SysIni("USER", global.config.showTopLevel,"copy.Key")
    IF tmp <>"ERROR:" THEN global.config.copy.indKey = tmp


    tmp = SysIni("USER", global.config.showTopLevel, "showDepth")
    IF tmp <> "ERROR:" THEN global.config.showDepth = tmp
                       ELSE global.config.showDepth = "K"      /* default: TopLevels + Keys to show in output */

    tmp = SysIni("USER", global.config.showTopLevel, "showHexAs")
    IF tmp <> "ERROR:" THEN global.config.showHexAs = tmp
                       ELSE global.config.showHexAs = "H"      /* default: show them as hexadecimal-string */

    tmp = SysIni("USER", global.config.showTopLevel, "showLineLength")
    IF tmp <> "ERROR:" THEN global.config.showLineLength = tmp

    IF tmp = "ERROR:" | tmp < "40" THEN
       global.config.showLineLength = 120

    global.old.config.eLog              = global.config.eLog 
    global.old.config.add.indTopLevel   = global.config.add.indTopLevel    
    global.old.config.add.indKey        = global.config.add.indKey         
    global.old.config.change.indKey     = global.config.change.indKey      
    global.old.config.delete.indAllKeys = global.config.delete.indAllKeys  
    global.old.config.delete.indKey     = global.config.delete.indKey      
    global.old.config.move.indAllKeys   = global.config.move.indAllKeys    
    global.old.config.move.indKey       = global.config.move.indKey        
    global.old.config.copy.indAllKeys   = global.config.copy.indAllKeys    
    global.old.config.copy.indKey       = global.config.copy.indKey        
    global.old.config.showDepth         = global.config.showDepth
    global.old.config.showHexAs         = global.config.showHexAs
    global.old.config.showLineLength    = global.config.showLineLength

    RETURN


/* 
   write settings into OS2.INI, if values were changed
*/
WRITE_INI_SETTINGS: PROCEDURE EXPOSE global.


    IF global.old.config.eLog <> global.config.eLog THEN
       CALL SysIni"USER", global.config.showTopLevel,"activateLog", global.config.eLog

    IF global.old.config.add.indTopLevel   <> global.config.add.indTopLevel    THEN
       CALL SysIni"USER", global.config.showTopLevel,"add.TopLevel", global.config.add.indTopLevel

    IF global.old.config.add.indKey        <> global.config.add.indKey         THEN
       CALL SysIni"USER", global.config.showTopLevel,"add.Key", global.config.add.indKey

    IF global.old.config.change.indKey     <> global.config.change.indKey      THEN
       CALL SysIni"USER", global.config.showTopLevel,"change.Key", global.config.change.indKey

    IF global.old.config.delete.indAllKeys <> global.config.delete.indAllKeys  THEN
       CALL SysIni"USER", global.config.showTopLevel,"delete.AllKeys", global.config.delete.indAllKeys

    IF global.old.config.delete.indKey     <> global.config.delete.indKey      THEN
       CALL SysIni"USER", global.config.showTopLevel,"delete.Key", global.config.delete.indKey

    IF global.old.config.move.indAllKeys   <> global.config.move.indAllKeys    THEN
       CALL SysIni"USER", global.config.showTopLevel,"move.AllKeys", global.config.move.indAllKeys

    IF global.old.config.move.indKey       <> global.config.move.indKey        THEN
       CALL SysIni"USER", global.config.showTopLevel,"move.Key", global.config.move.indKey

    IF global.old.config.copy.indAllKeys   <> global.config.copy.indAllKeys    THEN
       CALL SysIni"USER", global.config.showTopLevel,"copy.AllKeys", global.config.copy.indAllKeys

    IF global.old.config.copy.indKey       <> global.config.copy.indKey        THEN
       CALL SysIni"USER", global.config.showTopLevel,"copy.Key", global.config.copy.indKey


    IF global.old.config.showDepth <> global.config.showDepth THEN
       CALL SysIni "USER", global.config.showTopLevel, "showDepth", global.config.showDepth 

    IF global.old.config.showHexAs <> global.config.showHexAs THEN
       CALL SysIni "USER", global.config.showTopLevel, "showHexAs", global.config.showHexAs 

    IF global.old.config.showLineLength <> global.config.showLineLength THEN
       CALL SysIni "USER", global.config.showTopLevel, "showLineLength", global.config.showLineLength 
    RETURN



/*
   show argument, if any, &
   get yes/no answer
*/
GET_YES_NO: PROCEDURE EXPOSE global.
    IF ARG(1) <> "" THEN
       CALL CHAROUT , ARG(1)

    CALL CHAROUT , global.iYellow
    answer = get_answer("QYN")
    CALL CHAROUT , global.iCyan

    SELECT
       WHEN answer = "Q"   THEN SIGNAL halt
       WHEN answer = "1B"x THEN RETURN 0                /* abort module */
       WHEN answer = ""    THEN NOP                     /* do not change value */
       OTHERWISE 
            INTERPRET ARG(2) " = (answer = 'Y')"
    END  

    RETURN 1            /* everything went o.k. */

/*
   allow changing the settings for menus
*/
SETTINGS_MENU: PROCEDURE EXPOSE global.
    SAY
    SAY
    tmp = "Keep a logfile for backup/restore/update ?"
    IF global.config.eLog THEN tmp = tmp global.yesHint
                          ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.eLog") THEN
       RETURN
    /* try to delete the LOG-file */
    IF \global.config.eLog THEN '@ERASE "' || global.eLogFile ||'" 2>nul'


    SAY
    SAY
    SAY "Settings for menu abilities:"
    SAY

    tmp = "Allow adding a new TopLevel entry ?"
    IF global.config.add.indTopLevel THEN tmp = tmp global.yesHint
                                     ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.add.indTopLevel") THEN
       RETURN
    SAY

    tmp = "Allow deleting ALL Keys in a TopLevel (= deleting a TopLevel) ?"
    IF global.config.delete.indAllKeys THEN tmp = tmp global.yesHint
                                       ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.delete.indAllKeys") THEN
       RETURN

    tmp = "Allow moving ALL Keys to another TopLevel ?"
    IF global.config.move.indAllKeys THEN tmp = tmp global.yesHint
                                     ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.move.indAllKeys") THEN
       RETURN

    tmp = "Allow copying ALL Keys to another TopLevel ?"
    IF global.config.copy.indAllKeys THEN tmp = tmp global.yesHint
                                     ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.copy.indAllKeys") THEN
       RETURN

    SAY




    tmp = "Allow adding a new Key entry ?"
    IF global.config.add.indKey THEN tmp = tmp global.yesHint
                                ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.add.indKey") THEN
       RETURN

    tmp = "Allow deleting a single Key ?"
    IF global.config.delete.indKey THEN tmp = tmp global.yesHint
                                   ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.delete.indKey") THEN
       RETURN

    tmp = "Allow moving a single Key ?"
    IF global.config.move.indKey THEN tmp = tmp global.yesHint
                                 ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.move.indKey") THEN
       RETURN

    tmp = "Allow copying a single Key ?"
    IF global.config.copy.indKey THEN tmp = tmp global.yesHint
                                 ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.copy.indKey") THEN
       RETURN

    tmp = "Allow changing (editing) a Key value ?"
    IF global.config.change.indKey THEN tmp = tmp global.yesHint
                                   ELSE tmp = tmp global.noHint
    IF \get_yes_no(tmp, "global.config.change.indKey") THEN
       RETURN


    RETURN




/*
   allow changing the settings for printout
*/
SETTINGS_PRINTOUT: PROCEDURE EXPOSE global.
    SAY
    SAY "Settings for formatting the printout:"
    SAY

    /* how much information should be produced ? */
    SAY global.iCyan || "How much information to include in output:" global.iYellow
    SAY
    choice = ""

    tmp = "       " global.iYellow || "T" global.iCyan global.depthOfOutput.T
    IF global.config.showDepth = "T" THEN 
       tmp = tmp global.defaultHint
    SAY  tmp

    /* if no previous preferences, then this is the default */
    tmp = "       " global.iYellow || "K" global.iCyan global.depthOfOutput.K
    IF global.config.showDepth = "K" THEN 
       tmp = tmp global.defaultHint
    SAY tmp

    tmp = "       " global.iYellow || "V" global.iCyan global.depthOfOutput.V
    IF global.config.showDepth = "V" THEN 
       tmp = tmp global.defaultHint
    SAY tmp

    SAY "       " global.iCyan   || "   [Esc] to return"
 
    /* define choices and get answer from user */
    CALL CHAROUT , global.iYellow
    answer = get_answer(choice || "TKVQ")
    CALL CHAROUT , global.iCyan

    SELECT
       WHEN answer = "1B"x THEN RETURN    /* Escape was pressed */
       WHEN answer = "Q" THEN SIGNAL halt
       WHEN answer = "" THEN NOP          /* do not change present setting */
       OTHERWISE global.config.showDepth = answer
    END  

    /* should hex value be presented additionally with a filtered ASCII-string ? */

    SAY global.iCyan || "hexadecimal values should be showed as:"
    SAY
    tmp = "       " global.iYellow || "H" global.iCyan global.hextypeOfOutput.H
    IF global.config.showHexAs = "H" THEN
       tmp = tmp global.defaultHint
    SAY tmp

    tmp = "       " global.iYellow || "F" global.iCyan global.hextypeOfOutput.F
    IF global.config.showHexAs = "F" THEN
       tmp = tmp global.defaultHint
    SAY tmp

    tmp = "       " global.iYellow || "B" global.iCyan global.hextypeOfOutput.B
    IF global.config.showHexAs = "B" THEN
       tmp = tmp global.defaultHint
    SAY tmp

    SAY "       " global.iCyan   || "   [Esc] to return"

    /* define choices and get answer from user */
    CALL CHAROUT , global.iYellow
    answer = get_answer("HFBQ")
    CALL CHAROUT , global.iCyan
 
    SELECT
       WHEN answer = "1B"x THEN RETURN
       WHEN answer = ""    THEN NOP
       WHEN answer = "Q"   THEN SIGNAL halt
       OTHERWISE global.config.showHexAs = answer       /* assign new value */
    END


    /* get desired line-length */
    DO FOREVER
       SAY global.iCyan || "How many characters per line (" || global.iYellow || global.config.showLineLength || global.iCyan "default, 40 minimum) ? " global.iYellow
       /* define choices and get answer from user */
       CALL CHAROUT , global.iYellow
       answer = get_answer("Q", "999999")
       CALL CHAROUT , global.iCyan

       SELECT
          WHEN answer = "Q"   THEN SIGNAL halt
          WHEN answer = "1B"x THEN RETURN
          WHEN answer = ""    THEN LEAVE        /* do not change setting */
          OTHERWISE
               IF answer >= 40 THEN          /* minimum line-length >= 40 characters */
               DO
                  global.config.showLineLength = answer  /* new value */
                  LEAVE
               END
       END  

       SAY
       CALL error_msg "A minimum line-length of 40 characrters is required !", "come back"
       SAY
       SAY "please retry."
       SAY
    END

    RETURN




/* 
   determine largest entry
*/
LARGEST_GENERIC: PROCEDURE EXPOSE global. stemIni. stemTopLevel. stemKey.
    largest = 0
    dynCode =         "DO i = 1 TO" ARG(1) || ".0;"
    dynCode =         dynCode "largest = MAX(largest, LENGTH(" ARG(1) || ".i));"
    dynCode = dynCode "END;"
    dynCode = dynCode ARG(1) || ".iLargest = MIN(largest, (global.iColumns - (2+ LENGTH(" || ARG(1) || ".0))))"
    INTERPRET dynCode                /* execute REXX-code in variable dynCode */

    RETURN 


/* 
  display stem-contents on screen
*/
SHOW_GENERIC: PROCEDURE EXPOSE global. stemIni. stemTopLevel. stemKey.
    stemName = ARG(1)

    tmpANSILength = global.iScrLength * 2       /* length of the two ANSI-color control chars */

    dyncode =         "nrLength = LENGTH(" || stemName || ".0);"
    dyncode = dyncode "columns = global.iColumns % (" || stemName || ".iLargest + nrLength + 2);"

    dyncode = dyncode "IF columns < 1 THEN columns = 1;"

    dynCode = dyncode "j = (" || stemName || ".0 + columns - 1) % columns;"

    dynCode = dynCode "DO i = 1 TO j;"
    dynCode = dynCode "   tmp = '';" 
    dynCode = dynCode "   DO k = 1 TO columns;" /*  m = (i - 1) * columns + k    /* order in lines */ */
    dynCode = dynCode "       m = (k - 1) * j + i;"
    dynCode = dynCode "       IF " stemName || ".m <> '' THEN;"
    dynCode = dynCode "       tmp = tmp LEFT((global.iCyan || RIGHT(m, nrLength) global.iYellow || "stemName ||".m), (" stemName || ".iLargest + nrLength + 1 + tmpANSILength));"
    dynCode = dynCode "    END;" 
    dynCode = dynCode "    CALL CHAROUT , tmp;"
    dynCode = dyncode "    IF (LENGTH(tmp) - tmpANSILength * columns) < global.iColumns THEN SAY;"

    dynCode = dyncode "END"

    INTERPRET dynCode

    RETURN



/* 
   one of Knuth's algorithms to sort
   ARG(1) ... stemname of array to sort
   ARG(2) ... optional, if given, exact comparison (no forced uppercase), taking leading
              and trailing blanks into account
*/
SORT_GENERIC: PROCEDURE EXPOSE stemIni. stemTopLevel. stemKey. stemTargetTopLevel. stemTargetKey.

   /* define M for passes, build REXX-code */
   dynCode = "M = 1; DO WHILE (9 * M + 4) <" ARG(1) || ".0 ; M = M * 3 + 1; END"
   INTERPRET dynCode                /* execute REXX-code in variable dynCode */

   /* sort stem, build REXX-code */
   dynCode = "DO WHILE M > 0; K = " ARG(1) || ".0 - M; DO J = 1 TO K; Q = J;"
   dynCode = dynCode "DO WHILE Q > 0; L = Q + M;"

   IF ARG() < 2 THEN    /* uppercase comparison, ignore leading and trailing blanks */
      dynCode = dynCode "IF TRANSLATE(" || ARG(1) || ".Q) <= TRANSLATE(" || ARG(1) || ".L) THEN LEAVE;"
   ELSE                 /* exact comparison */ 
      dynCode = dynCode "IF" ARG(1) || ".Q <<=" ARG(1) || ".L THEN LEAVE;"

   dynCode = dynCode "tmp =" ARG(1) || ".Q; tmp.origValue =" ARG(1) || ".Q.origValue;"
   dynCode = dynCode "tmp.type =" ARG(1) || ".Q.type; tmp.filterValue =" ARG(1) || ".Q.filterValue;"

   dynCode = dynCode ARG(1) || ".Q =" ARG(1) || ".L;" ARG(1) || ".Q.origValue =" ARG(1) || ".L.origValue;"
   dynCode = dynCode ARG(1) || ".Q.type =" ARG(1) || ".L.type;" ARG(1) || ".Q.filterValue =" ARG(1) || ".L.filterValue;"

   dynCode = dynCode ARG(1) || ".L = tmp;" ARG(1) || ".L.origValue = tmp.origValue;"
   dynCode = dynCode ARG(1) || ".L.type = tmp.type;" ARG(1) || ".L.filterValue  = tmp.filterValue;"

   dynCode = dynCode "Q = Q - M; END; END; M = M % 3; END"

   INTERPRET dynCode                /* execute REXX-code in variable dynCode */

   RETURN


/*
    get answer from user, if a 3rd argument is supplied, then force an entry
    ARG(1) ... string of valid letters
    ARG(2) ... upper bound of an arithmetic value
    ARG(3) ... if given, force user to enter at least one character
*/
GET_ANSWER: PROCEDURE EXPOSE global.
    validLetters = ARG(1)
    upperBound   = ARG(2)       /* 0 - upperBound */

    i = 0
    answer = ""

    DO FOREVER
       tmp = TRANSLATE(SysGetKey("noecho"))

       IF tmp = "0D"x THEN                      /* CR-was pressed */
       DO
          IF ARG(3) = "" | i > 0 THEN LEAVE
          CALL BEEP 2000, 250
          ITERATE
       END

       IF tmp = "1B"x THEN                      /* Escape was pressed */
       DO
          answer = tmp
          LEAVE
       END

       IF tmp = "08"x THEN                      /* Backspace was pressed */
       DO
          IF i = 0 THEN                         /* already at first position */
          DO
             CALL BEEP 2000, 250
             ITERATE
          END

          CALL CHAROUT , tmp                    /* backspace */
          CALL CHAROUT , " "                    /* erase character */
          CALL CHAROUT , tmp
          i = i - 1

          IF i = 0 THEN answer = ""             /* adjust value of answer */
          ELSE answer = SUBSTR(answer, 1, i)

          ITERATE
       END

       IF POS(tmp, validLetters) > 0 THEN
       DO
          IF answer = "" THEN
          DO
             answer = tmp
             CALL CHAROUT , answer
             LEAVE
          END

          CALL BEEP 2000, 250
          ITERATE
       END

       IF upperBound <> "" THEN
       DO
          IF i = 0 THEN
          DO
             IF POS(tmp, "0123456789") > 0 & tmp <= upperBound THEN
             DO
                CALL CHAROUT , tmp
                answer = tmp
                i = i + 1
                IF answer = 0 | LENGTH(upperBound) = 1 | (answer || "0" > upperBound) THEN LEAVE
                ITERATE
             END
          END
          ELSE
          DO
             IF POS(tmp, "0123456789") > 0 THEN
             DO
                IF answer || tmp <= upperBound THEN
                DO
                   CALL CHAROUT , tmp 
                   answer = answer || tmp
                   i = i + 1
   
                   IF LENGTH(answer) = LENGTH(upperBound) | (answer || "0" > upperBound) THEN LEAVE
                   ITERATE
                END
             END
          END
       END

       CALL BEEP 2000, 250
    END
    SAY

    RETURN answer


/* supply defaults */
INI_DEFAULT: PROCEDURE EXPOSE stemIni. global.
    DROP stemIni.
    stemIni.   = ""

    IF ARG(1) = "1" THEN        /* show user INI-names themselves */
    DO
       stemIni.1 = "USER (OS2.INI)"   /* OS2.INI */
       stemIni.2 = "SYSTEM (OS2SYS.INI)"/* OS2SYS.INI */
    END
    ELSE
    DO
       stemIni.1 = "USER"               /* OS2.INI */
       stemIni.2 = "SYSTEM"             /* OS2SYS.INI */
    END

    stemIni.0 = 2                       /* number of elements in array */

    CALL largest_generic("stemIni")
    RETURN



SEARCH_INI: PROCEDURE EXPOSE global. stemIni.
    SAY
    SAY global.iCyan || "Enter:"
    SAY
    SAY "       " global.iYellow "1" global.iCyan " to scan all attached drives" global.defaultHint
    SAY "       " global.iYellow "2" global.iCyan " to scan all local drives"
    SAY "       " global.iYellow "3" global.iCyan " to scan remote drives"
    SAY "       " global.iYellow "->" global.iCyan 'or any valid drive letter from "' || global.iYellow || 'A' || global.iCyan || '"-"' || global.iYellow || 'Z' || global.iCyan || '"'

    /* allow for choices 1-3 and drive letters A-Z */
    CALL CHAROUT , global.iYellow
    answer = get_answer("123ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    CALL CHAROUT , global.iCyan

    SELECT
       WHEN answer = "1B"x THEN                 /* user aborted, return unchanged array */
            RETURN 
       WHEN answer = "1" | answer = "" THEN
             map = SysDriveMap(, "USED")        /* get a list of all used drives */
       WHEN answer = "2" THEN
             map = SysDriveMap(, "LOCAL")       /* get a list of all local drives */
       WHEN answer = "3" THEN
             map = SysDriveMap(, "REMOTE")      /* get a list of all remote drives */
       OTHERWISE
             map = answer || ":"                /* drive - letter */
    END  

    /* drop existing array */
    DROP stemIni.
    stemIni.  = ""
    stemIni.0 = 0

    DO WHILE map <> ""
       PARSE VAR map drive map

       SAY global.iCyan || "scanning drive" global.iYellow ||drive||global.iCyan "for accessible INI-files..."
       CALL SysFileTree drive || "\*.ini", "file", "FSO"

       DO i = 1 TO file.0
          /* check whether accessible from OS/2, i.e. an OS/2 INI-file */
          ok = SysIni(file.i, 'ALL:', 'TopLevel')
          IF ok <> "ERROR:" & TopLevel.0 > 0 THEN
          DO
             SAY global.iCyan || "     file" global.iYellow || file.i || global.iCyan "found..."
             stemIni.0 = stemIni.0 + 1
             j = stemIni.0
             stemIni.j = file.i
          END
       END
       SAY 
    END

    CALL largest_generic("stemIni")
    RETURN 


/* 
        Display INI-files which are accessible
*/
SHOW_INIS: PROCEDURE EXPOSE global. stemIni. stemTopLevel. stemKey.

   stemIni.0 = 0        /* no INI-files initially, setup */

   DO FOREVER
      IF WORD(stemIni.1, 1) = "USER" | stemIni.0 = 0 THEN
         CALL ini_default("1")     /* show file-names of system-INIs */

      SAY
      SAY global.iRedWhite || CENTER("accessible OS/2-INI-files", global.iColumns) || global.iCyan
      SAY 
      SAY global.iCyan'The following' global.iYellow || stemIni.0 global.iCyan'OS/2 INI-files are accessible:'
      SAY

      CALL show_generic "stemIni"      /* show stem contents */

      IF WORD(stemIni.1, 1) = "USER" THEN       /* if initial settings, then */
         CALL ini_default                       /* get symbolic-names only for RxUtils-functions */

      SAY
      tmp = global.enterString || stemIni.0 global.iCyan || 'to view INI-file,',
            global.iYellow || '0' || global.iCyan 'to end;',
            global.iYellow || 's' || global.iCyan || 'can drive[s] for INI-files,',
            global.iYellow || 'p' || global.iCyan || 'rint all INI-files'

      IF global.showConfigure THEN              /* show configuration option ? */
          tmp = tmp || ", " ||  global.iYellow || 'c' || global.iCyan || 'onfigure'

      SAY tmp

      /* define choices and upper numeric boundary and get answer from user */
      CALL CHAROUT , global.iYellow
      answer = get_answer("PQCS", stemIni.0)
      CALL CHAROUT , global.iCyan
      SAY

      SELECT
         WHEN answer = "" | answer = 0 | answer = "1B"x THEN LEAVE

         WHEN answer = "Q" THEN SIGNAL halt
   
         WHEN answer = "C" THEN         /* configure program */
              DO
                 CALL settings_printout
                 CALL settings_menu
                 CALL check_option_set  /* show configuration option ? */
              END
   
         WHEN answer = 'S' THEN         /* search for all OS/2-INI-files */
               CALL search_ini
                                       
         WHEN answer = 'P' THEN         /* print all OS/2-INI-files */
              CALL print

         OTHERWISE                      /* display top-levels of chosen INI-file */
              DO
                 CALL show_toplevel answer
                 SAY
              END
      END  
      SAY
      SAY
   END
   SAY global.iNormal
   RETURN


/*
        read TopLevel-entries
*/
READ_TOPLEVEL: PROCEDURE EXPOSE stemIni. stemTopLevel. stemKey. global. 
    DROP stemTopLevel.
    stemTopLevel. = ""

    iIni = ARG(1)
    ok = SysIni(stemIni.iIni, 'ALL:', 'stemTopLevel')
    IF ok = "ERROR:" THEN
    DO
       stemTopLevel.0 = 0
    END
    ELSE
    DO i = 1 TO stemTopLevel.0
       CALL check_value stemTopLevel.i  /* determine and prepare value in hand */
       stemTopLevel.i.origValue   = stemTopLevel.i
       stemTopLevel.i             = strings.displayValue
       stemTopLevel.i.type        = strings.type
       stemTopLevel.i.filterValue = strings.filterValue
    END

    CALL largest_generic("stemTopLevel")
    RETURN 


/*
   ask for new TopLevel-name,
   return name, if it does not exist, NULL-string if it exists
*/
CREATE_NEW_TOPLEVEL: PROCEDURE EXPOSE global. stemIni.
    iniName = VALUE("stemIni." || ARG(1))

    PARSE VALUE edit_value("A", "new Top-Level-name ('Application'):", , "H A", "Enter new Top-Level-Name") WITH tmpState tmpResult

    IF tmpState = "NOK" THEN RETURN ""          /* user aborted entry */

    /* check whether Top-Level exists already */
    ok = SysIni(iniName, tmpResult, 'ALL:', 'stemKey')

    IF ok <> "ERROR:" THEN
    DO
       CALL check_value tmpResult
       CALL error_msg "TopLevel:" || global.iCyan "[" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iRedWhite || "exists already !"
       RETURN ""
    END

    RETURN tmpResult


/*
   ask for new Key-name,
   return name, if it does not exist, NULL-string if it exists
*/
CREATE_NEW_KEY: PROCEDURE EXPOSE global. stemIni. stemTopLevel.
    iniName = ARG(1)                            /* INI-name */
    topName = ARG(2)                            /* Top Level name */

    PARSE VALUE edit_value("A", "new Key-name:", , "H A", "Enter new Key-Name") WITH tmpState tmpResult

    IF tmpState = "NOK" THEN RETURN ""          /* user aborted entry */

    /* check whether Key exists already */
    ok = SysIni(iniName, topName, tmpResult)

    IF ok <> "ERROR:" THEN
    DO
       CALL check_value tmpResult
       CALL error_msg "Key:" || global.iCyan "[" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iRedWhite || "exists already !"
       RETURN ""
    END

    RETURN tmpResult



/* 
        Display TOPLEVEL-entries of chosen INI-file
*/
SHOW_TOPLEVEL: PROCEDURE EXPOSE global. stemIni. stemTopLevel. stemKey. 
   iIni     = ARG(1)
   filename = stemIni.iIni

   CALL read_toplevel(iIni)               /* read all toplevel-entries */
   global.TopLSortState = "U"                  /* unsorted */

   DO FOREVER
      IF stemTopLevel.0 = 0 THEN
      DO
        
      END

      SAY
      SAY global.iRedWhite || CENTER("available TopLevel-entries (Application entries)", global.iColumns) || global.iCyan
      SAY
      SAY global.iCyan'INI-file:' global.iYellow ||filename
      SAY
      SAY global.iCyan'The following' global.iYellow||stemTopLevel.0 global.iCyan'TopLevel entries are available:'
      SAY
      CALL show_generic "stemTopLevel"      /* show stem contents */

      SAY

      choices = "CPSUQ"                  /* define choices */

      tmp = global.enterString || stemTopLevel.0 global.iCyan || 'to view TopLevel-entries,',
            global.iYellow || '0' || global.iCyan 'to return;'

      IF global.config.add.indTopLevel THEN
      DO
         tmp = tmp global.iYellow || 'a' || global.iCyan || 'dd,'
         choices = choices || "A"         /* add the adding choice */
      END

      tmp = tmp global.iYellow || 's' || global.iCyan || 'ort,',
            global.iYellow || 'u' || global.iCyan || 'nsort,',
            global.iYellow || 'p' || global.iCyan || 'rint'

      SAY tmp

      /* define choices and upper numeric boundary and get answer from user */
      CALL CHAROUT , global.iYellow
      answer = get_answer(choices, stemTopLevel.0)
      CALL CHAROUT , global.iCyan
      SAY

      SELECT
         WHEN answer = "" | answer = 0 | answer = "1B"x THEN LEAVE

         WHEN answer = "Q" THEN SIGNAL halt

         WHEN answer = 'P' THEN    /* print all TopLevel-entries */
              DO
                 CALL print iIni                        /* all TopLevel-entries will be sorted */
                 IF global.TopLSortState = "U" THEN
                    CALL read_toplevel(iIni)       /* reread all toplevel-entries */

              END
   
         WHEN answer = "C" THEN         /* configure program */
              DO
                 CALL settings_printout
                 CALL settings_menu
                 CALL check_option_set  /* show configuration option ? */
              END

         WHEN answer = 'S' THEN    /* sort TopLevel-entries */
              DO
                 CALL sort_generic "stemTopLevel"
                 global.TopLSortState = "S"
              END
    
         WHEN answer = 'U' THEN    /* unsort TopLevel-entries, i.e. reread */
              DO
                 CALL read_toplevel(iIni)          /* read all toplevel-entries */
                 global.TopLSortState = "U"  
              END
   
         WHEN answer = "A" THEN      /* add a new key-entry */
              DO
                 newTopLevel = create_new_toplevel(iIni)
                 IF newTopLevel = "" THEN ITERATE       /* no entry, or exists already */
        
                 CALL check_value newTopLevel
                 newTopLevel.displayValue = strings.displayValue
                 SAY
                 SAY "new Top-Level:" global.iRedWhite || newTopLevel.displayValue || global.iCyan
                 SAY
        
                 newKey = create_new_key(stemIni.iIni, newTopLevel)
                 IF newKey = "" THEN ITERATE            /* no entry, or exists already */

                 SAY
                 SAY "new Top-Level:" global.iRedWhite || newTopLevel.displayValue || global.iCyan
                 SAY
                 CALL check_value newKey
                 newKey.displayValue = strings.displayValue
        
                 PARSE VALUE edit_value("A", "new value for Key:" global.iRedWhite || newKey.displayValue || global.iCyan, , , "Enter new Key-Value") WITH tmpState tmpResult
                 IF tmpState = "NOK" THEN ITERATE

                 newKeyValue = tmpResult
        
                 val = SysIni(stemIni.iIni, newTopLevel, newKey, newKeyValue)
        
                 CALL read_toplevel(iIni)               /* read all toplevel-entries */
        
                 IF global.TopLSortState = "S" THEN
                    CALL sort_generic "stemTopLevel"
              END
    
         OTHERWISE              /* show keys of chosen TopLevel */
              DO
                 IF show_key(ARG(1), answer) THEN
                 DO
                    CALL read_toplevel(iIni)               /* read all toplevel-entries */
           
                    IF global.TopLSortState = "S" THEN
                       CALL sort_generic "stemTopLevel"
                 END
           
                 SAY
              END
      END  
      SAY
   END
   SAY global.iNormal
   RETURN


/*
     copy keys to another TopLevel
*/
COPY_KEYS: PROCEDURE EXPOSE global. stemIni. stemTopLevel. stemKey.
    iIni     = ARG(1)           /* OS/2-ini file */
    iTopL    = ARG(2)           /* index into stemTopLevel */
    all_keys = ARG(3)           /* true if all keys to be copied, else false */
    iKey     = ARG(4)           /* index into stemKey., if only one key is to be copied */

    dirty = 0                   /* reread TopLevel entries, if one was added as a target */

    SAY

    DO FOREVER
       tmp = "copy" 
   
       IF all_keys THEN
          tmp = tmp "ALL keys ... "
       ELSE
          tmp = tmp "key ... "
   
       SAY global.iRedWhite 
       SAY tmp
       SAY global.iRedWhite || CENTER("available TopLevel-entries (Application entries)", global.iColumns) || global.iCyan
       SAY
   
       SAY global.iCyan'INI-file:' global.iYellow || stemIni.iIni
       SAY global.iCyan'TopLevel:' global.iYellow || stemTopLevel.iTopL
   
       IF \all_keys THEN        /* single key, show it */
       DO
          SAY global.iCyan'     Key:' global.iYellow || stemKey.iKey
       END
   
       SAY
       SAY global.iCyan'The following' global.iYellow||stemTopLevel.0 global.iCyan'TopLevel entries are available:'
       SAY
       CALL show_generic "stemTopLevel"      /* show stem contents */
       SAY
   
       tmp = global.iCyan || "Enter the TopLevel you wish to" global.iYellow|| "copy" || global.iCyan "to:",
             global.iYellow || "1" || global.iCyan || "-" ||,
             global.iYellow|| stemTopLevel.0 global.iCyan || 'to identify target TopLevel,',
             global.iYellow || '0' || global.iCyan 'to return;',
             global.iYellow || 'c' || global.iCyan || 'reate new TopLevel'
   
       SAY tmp
   
       /* define choices and upper numeric boundary and get answer from user */
       CALL CHAROUT , global.iYellow
       answer = get_answer("CQ", stemTopLevel.0)
       CALL CHAROUT , global.iCyan
   
       SAY
       SELECT
          WHEN answer = "" | answer = 0 | answer = "1B"x THEN LEAVE
   
          WHEN answer = "Q" THEN SIGNAL halt
   
          WHEN answer = "C" THEN              /* create new TopLevel */
               DO
                  newTopLevel = create_new_toplevel(iIni)
                  IF newTopLevel = "" THEN ITERATE    /* no entry, or exists already */
         
                  CALL check_value newTopLevel
                  SAY
                  SAY "new Top-Level:" global.iRedWhite || strings.displayValue || global.iCyan
                  SAY
   
                  targetTopLevel = newTopLevel
                  dirty = 1                   /* reread TopLevels */
               END
   
          WHEN answer = iTopL THEN    /* target same as source ? */
               DO
                  CALL error_msg "Target TopLevel:" || global.iCyan "[" || global.iYellow || stemTopLevel.iTopL || global.iCyan || "]" global.iRedWhite || "same as source TopLevel !"
                  ITERATE
               END
   
          OTHERWISE targetTopLevel = stemTopLevel.answer.origValue
       END
   
       /* copy keys to TopLevel */
       SAY global.iCyan || "Copying keys into TopLevel [" || global.iYellow || stemTopLevel.answer || global.iCyan || "] ..."
       DO i = 1 TO stemKey.0
          IF \all_keys THEN i = iKey       /* assign key-index */
   
          val = SysIni(stemIni.iIni, stemTopLevel.iTopL.origValue, stemKey.i.origValue)
          CALL SysIni stemIni.iIni, targetTopLevel, stemKey.i.origValue, val

          SAY global.iCyan"Key: [" || global.iYellow || stemKey.i || global.iCyan || "] copied."
   
          IF \all_keys THEN LEAVE          /* leave loop prematurely */
       END
       LEAVE
    END

    RETURN dirty



/*
        move keys to another TopLevel, if only one key, then allow for renaming it
*/
MOVE_KEYS: PROCEDURE EXPOSE global. stemIni. stemTopLevel. stemKey.
    iIni     = ARG(1)           /* OS/2-ini file */
    iTopL    = ARG(2)           /* index into stemTopLevel */
    all_keys = ARG(3)           /* true if all keys to be moved, else false */
    iKey     = ARG(4)           /* index into stemKey., if only one key is to be moved */

    TopLevelCreated = 0         /* was a new TopLevel created ? */
    KeyMoved = 0                /* was a key moved ? */

    SAY
    DO FOREVER
       tmp = "move"
   
       IF all_keys THEN
          tmp = tmp "ALL keys ... "
       ELSE
          tmp = tmp "key ... "

       SAY global.iRedWhite 
       SAY tmp
       SAY global.iRedWhite || CENTER("available TopLevel-entries (Application entries)", global.iColumns) || global.iCyan

       SAY
       SAY global.iCyan'INI-file:' global.iYellow || stemIni.iIni
       SAY global.iCyan'TopLevel:' global.iYellow || stemTopLevel.iTopL

       IF \all_keys THEN        /* single key, show it */
       DO
          SAY global.iCyan'     Key:' global.iYellow || stemKey.iKey
       END


       SAY
       SAY global.iCyan'The following' global.iYellow||stemTopLevel.0 global.iCyan'TopLevel entries are available:'
       SAY
       CALL show_generic "stemTopLevel"      /* show stem contents */
       SAY
       choices = "CQ"
   
       tmp = global.iCyan || "Enter the TopLevel you wish to" global.iYellow|| "move" 
   
       IF all_keys THEN
          tmp = tmp || global.iCyan "these keys to:"
       ELSE
          tmp = tmp || global.iCyan "the key to:"
   
       tmp = tmp  global.iYellow || "1" || global.iCyan || "-" ||,
             global.iYellow|| stemTopLevel.0 global.iCyan || 'to identify target TopLevel,',
             global.iYellow || '0' || global.iCyan 'to return;'
   
       IF \all_keys THEN
       DO
          tmp = tmp global.iYellow || 'r' || global.iCyan || 'ename key,'
          choices = choices || "R"
       END
          tmp = tmp global.iYellow || 'c' || global.iCyan || 'reate new TopLevel'
   
       SAY tmp
   
       /* define choices and upper numeric boundary and get answer from user */
       CALL CHAROUT , global.iYellow
       answer = get_answer(choices, stemTopLevel.0)
       CALL CHAROUT , global.iCyan
   
       SAY
       SELECT
          WHEN answer = "" | answer = 0 | answer = "1B"x THEN LEAVE
   
          WHEN answer = "Q" THEN SIGNAL halt
   
          WHEN answer = "R" THEN              /* just rename present key */
               DO
                  PARSE VALUE edit_value("E", stemKey.iKey, , "H A", "Enter new Key-Name") WITH tmpState tmpResult
                  IF tmpState = "NOK" | tmpResult = "" THEN RETURN TopLevelCreated
                  newKey = tmpResult
                  CALL check_value newKey
               END
   
          WHEN answer = "C" THEN              /* create new TopLevel */
               DO
                  newTopLevel = create_new_toplevel(iIni)
                  IF newTopLevel = "" THEN ITERATE    /* no entry, or exists already */
         
                  CALL check_value newTopLevel
                  SAY
                  SAY "new Top-Level:" global.iRedWhite || strings.displayValue || global.iCyan
                  SAY
   
                  targetTopLevel = newTopLevel
                  targetTopLevel.displayValue = strings.displayValue
                  TopLevelCreated = 1
               END
   
          WHEN answer = iTopL THEN    /* target same as source ? */
               DO
                  CALL error_msg "Target TopLevel:" || global.iCyan "[" || global.iYellow || stemTopLevel.iTopL || global.iCyan || "]" global.iRedWhite || "same as source TopLevel !"
                  ITERATE
               END
   
          OTHERWISE 
               DO
                  targetTopLevel = stemTopLevel.answer.origValue
                  targetTopLevel.displayValue = stemTopLevel.answer
               END
       END
   
       /* move keys to target TopLevel */
   
       IF answer <> "R" THEN       /* regular move */
       DO
          SAY global.iCyan || "Moving keys into TopLevel [" || global.iYellow || targetTopLevel.displayValue || global.iCyan || "] ..."
          DO i = 1 TO stemKey.0
             IF \all_keys THEN i = iKey

             /* move key in hand */
             PARSE VALUE call_move_keys(stemIni.iIni, stemTopLevel.iTopL.origValue, targetTopLevel,,
                                        stemKey.i.origValue, stemKey.i),
                         WITH TopSuccess keySuccess
             TopLevelCreated = TopLevelCreated | TopSuccess
             KeyMoved =        KeyMoved | keySuccess
   
             IF \all_keys THEN LEAVE
          END
       END
       ELSE                        /* rename single key */
       DO
          /* move key in hand */
          i = iKey
          PARSE VALUE call_move_keys(stemIni.iIni,,
                                     stemTopLevel.iTopl.origValue, stemTopLevel.iTopl.origValue,,
                                     stemKey.i.origValue, strings.displayValue, newKey),
                      WITH TopLevelCreated keySuccess
       END
   
       IF KeyMoved THEN    /* at least one key was moved, reread keys into stemKey. */
       DO
          CALL read_key iIni, iTopL
          IF global.KeySortState = "S" THEN        /* resort */
             CALL sort_generic "stemKey"

          RETURN TopLevelCreated
       END
       LEAVE
    END

    RETURN 0            /* no move took place, therefore no new TopLevel was created */


/*
   do the actual move-operation
*/
CALL_MOVE_KEYS: PROCEDURE EXPOSE global.
    iniFile          = ARG(1)   /* OS/2-INI-file */
    sourceTopLevel   = ARG(2)   /* source */
    targetTopLevel   = ARG(3)   /* target */
    sourceKey        = ARG(4)   /* key */
    sourceKeyDisplay = ARG(5)   /* displayable string for key-name */

    TopLevelCreated = 0

    IF ARG() = 6 THEN   /* only given, if a single key-move within the same target (rename of a key) */
        targetKey = ARG(6)
    ELSE
    DO
        targetKey = sourceKey   /* move to a different place, but leave key-name unchanged */
        TopLevelCreated = 1     /* expect a succesful move into a new directory */
    END

    KeyMoved = 1                /* expect a successful move */

    /* present value of key */
    val1 = SysIni(iniFile, sourceTopLevel, sourceKey)

    /* value of key in target, if it exists */
    val2 = SysIni(iniFile, targetTopLevel, targetKey)

    IF val2 <> "ERROR:" THEN    /* key exists in target ! */
    DO
       CALL error_msg "Key:" || global.iCyan "[" || global.iYellow || sourceKeyDisplay || global.iCyan || "]" global.iRedWhite || "exists already, not moved.", "no wait"
       TopLevelCreated = 0
       KeyMoved = 0
    END
    ELSE
    DO
       /* create new key */
       CALL SysIni iniFile, targetTopLevel, targetKey, val1
       /* delete original key */
       CALL SysIni iniFile, sourceTopLevel, sourceKey, "DELETE:"
       SAY global.iCyan"Key: [" || global.iYellow || sourceKeyDisplay || global.iCyan || "] moved."
    END

    RETURN TopLevelCreated KeyMoved







/*
        read KEY-entries
*/
READ_KEY: PROCEDURE EXPOSE stemIni. stemTopLevel. stemKey. global. strings.
    DROP stemKey.
    stemKey. = ""

    iIni     = ARG(1)
    iTopL    = ARG(2)

    ok = SysIni(stemIni.iIni, stemTopLevel.iTopL.origValue, 'ALL:', 'stemKey')
    IF ok = "ERROR:" THEN
    DO
       stemKey.0 = 0
    END
    ELSE
    DO i = 1 TO stemKey.0
       CALL check_value stemKey.i  /* determine and prepare value in hand */
       stemKey.i.origValue   = stemKey.i
       stemKey.i             = strings.displayValue
       stemKey.i.type        = strings.type
       stemKey.i.filterValue = strings.filterValue
    END

    CALL largest_generic("stemKey")
    RETURN 


/* 
        Display KEY-entries of chosen INI-file
*/
SHOW_KEY: PROCEDURE EXPOSE global. stemIni. stemTopLevel. stemKey.
   iIni     = ARG(1)
   iTopL    = ARG(2)
   filename = stemIni.iIni
   TopLevel = stemTopLevel.iTopL

   CALL read_key iIni, iTopL
   global.KeySortState = "U"            /* unsorted */
   dirty   = 0                          /* everything o.k., no need to reread TopLevel */

   DO FOREVER
      IF stemKey.0 = 0 THEN RETURN "1"       /* no keys left, reread Top-Level entries */

      SAY
      SAY global.iRedWhite || CENTER("available keys", global.iColumns) || global.iCyan
      SAY
      SAY global.iCyan'INI-file:' global.iYellow filename
      SAY global.iCyan'TopLevel:' global.iYellow TopLevel
      SAY
      SAY global.iCyan'The following' global.iYellow||stemKey.0 global.iCyan'Key entries are available:'
      SAY
      CALL show_generic "stemKey"      /* show stem contents */
      SAY


      choices = "PSUQ"          /* define choices */

      tmp = global.enterString || stemKey.0 global.iCyan || 'to view Key-value,',
            global.iYellow || '0' || global.iCyan 'to return;'

      IF global.config.add.indKey THEN
      DO
         tmp = tmp global.iYellow || 'a' || global.iCyan || 'dd,'
         choices = choices || "A"
      END

      IF global.config.delete.indAllKeys THEN
      DO
         tmp = tmp global.iYellow || 'd' || global.iCyan || 'elete ALL,'
         choices = choices || "D"
      END

      IF global.config.move.indAllKeys THEN
      DO
         tmp = tmp global.iYellow || 'm' || global.iCyan || 'ove ALL,'
         choices = choices || "M"
      END

      IF global.config.copy.indAllKeys THEN
      DO
         tmp = tmp global.iYellow || 'c' || global.iCyan || 'opy ALL,'
         choices = choices || "C"
      END

      tmp = tmp global.iYellow || 's' || global.iCyan || 'ort,',
          global.iYellow || 'u' || global.iCyan || 'nsort,',
          global.iYellow || 'p' || global.iCyan || 'rint'

      SAY tmp

      /* define choices and upper numeric boundary and get answer from user */
      CALL CHAROUT , global.iYellow
      answer = get_answer(choices, stemKey.0)
      CALL CHAROUT , global.iCyan
      SAY

      SELECT
         WHEN answer = "" | answer = 0 | answer = "1B"x THEN LEAVE

         WHEN answer = "Q" THEN SIGNAL halt

         WHEN answer = 'P' THEN         /* print all Key-entries of TopLevel */
              DO
                 CALL print iIni, iTopL
                 IF global.KeySortState = "U" THEN      /* reread all key-entries */
                    CALL read_key iIni, iTopL
              END
   
         WHEN answer = 'S' THEN         /* sort key-entries */
              DO
                 CALL sort_generic "stemKey"
                 global.KeySortState = "S"
              END
    
         WHEN answer = 'U' THEN         /* unsort key-entries, i.e. reread them */
              DO
                 CALL read_key iIni, iTopL
                 global.KeySortState = "U"
              END
   
         WHEN answer = "D" THEN         /* delete all keys and TopLevel-entry */
              DO
                 CALL BEEP 2000, 250
                 CALL CHAROUT , global.iRedWhite || "Do you really wish to delete ALL KEYs ???" || global.noHint 
                 answer = get_answer("QYN")
                 CALL CHAROUT , global.iCyan
        
                 IF answer = "Q" THEN SIGNAL halt
        
                 IF answer = "Y" THEN
                 DO
                    SAY global.iCyan || "Deleting ALL keys from TopLevel [" || global.iYellow || stemTopLevel.iTopL || global.iCyan || "] ..."
                    val = SysIni(stemIni.iIni, stemTopLevel.iTopL.origValue, "DELETE:")
                    SAY global.iCyan"done."
        
                    RETURN "1"                          /* return to TopLevel-entries */
                 END
              END
   
         WHEN answer = "C" THEN         /* copy all key entries to another TopLevel */
              DO
                dirty = dirty | copy_keys(iIni, iTopL, "1")
              END

         WHEN answer = "M" THEN         /* move all key entries to another TopLevel */
              DO
                dirty = dirty | move_keys(iIni, iTopL, "1")
              END


         WHEN answer = "A" THEN         /* add a new key-entry */
              DO
                 newKey = create_new_key(stemIni.iIni, stemTopLevel.iTopL.origValue)
                 IF newKey = "" THEN ITERATE
        
                 CALL check_value newKey
                 newKey.displayValue = strings.displayValue
        
                 PARSE VALUE edit_value("A", "new value for Key:" global.iRedWhite || newKey.displayValue || global.iCyan, , , "Enter new Key-Value") WITH tmpState tmpResult
                 IF tmpState = "NOK" THEN ITERATE
                 newKeyValue = tmpResult

                 /* create new key */
                 val = SysIni(stemIni.iIni, stemTopLevel.iTopL.origValue, newKey, newKeyValue)
        
                 CALL read_key iIni, iTopL              /* reread keys */
        
                 IF global.KeySortState = "S" THEN
                    CALL sort_generic "stemKey"
              END

         OTHERWISE      /* display value of chosen key */
              dirty = dirty | show_keyvalue(iIni, iTopL, answer)        /* TopLevel created ? */
              SAY
      END  
      SAY
   END
   SAY global.iNormal
   RETURN dirty


/*
        display value and allow for editing
*/
SHOW_KEYVALUE: PROCEDURE EXPOSE global. strings. stemIni. stemTopLevel. stemKey.
    iIni     = ARG(1)
    iTopL    = ARG(2)
    iKey     = ARG(3)
    dirty    = 0                /* change in key-names ? */
    TopLevelCreated = 0         /* was a TopLevel created using copy, move ? */

    filename = stemIni.iIni
    TopLevel = stemTopLevel.iTopL
    Key      = stemKey.iKey

    val = SysIni(stemIni.iIni, stemTopLevel.iTopL.origValue, stemKey.iKey.origValue)

    CALL check_value val
    iType = strings.type        /* type could be A, A0 or H */

    value2show = strings.displayValue


    DO FOREVER
       SAY
       SAY global.iRedWhite || CENTER("key-value", global.iColumns) || global.iCyan
       SAY
       SAY global.iCyan'INI-file:' global.iYellow || filename
       SAY global.iCyan'TopLevel:' global.iYellow || TopLevel
       SAY global.iCyan'     Key:' global.iYellow || Key global.iCyan
       SAY
   
   
       SAY "data type:" global.iYellow || global.dType.iType global.iCyan "(" ||,
           global.iYellow || global.dType.iType.long || global.iCyan || ")"
       SAY "    value:" global.iNormal
       SAY global.iCyan || "[" || global.iYellow || value2show || global.iCyan || "]"
       SAY

       choices = ""

       SAY global.iCyan || "Enter:"
       SAY

       IF iType = "H" THEN
       DO
          choices = choices || "FH"
          SAY "       " global.iYellow || "H" global.iCyan "to show value in hex-digits"
          SAY "       " global.iYellow || "F" global.iCyan "to show filtered value"
       END

       IF global.config.change.indKey THEN
       DO
          SAY "       " global.iYellow || "E" global.iCyan "to edit (change) key-value"
          choices = choices || "E"
       END

       IF global.config.delete.indKey THEN
       DO
          SAY "       " global.iYellow || "D" global.iCyan "to delete key"
          choices = choices || "D"
       END

       IF global.config.move.indKey THEN
       DO
          SAY "       " global.iYellow || "M" global.iCyan "to move/rename key"
          choices = choices || "M"
       END

       IF global.config.copy.indKey THEN
       DO
          SAY "       " global.iYellow || "C" global.iCyan "to copy key"
          choices = choices || "C"
       END

       SAY "       " global.iYellow || "P" global.iCyan "to print key-value"
       SAY "       " global.iCyan   || "   [Esc] to return"
       /* define choices and get answer from user */
       CALL CHAROUT , global.iYellow
       answer = get_answer(choices || "PQ")
       CALL CHAROUT , global.iCyan

       SELECT
          WHEN answer = "Q" THEN SIGNAL halt

          WHEN answer = "H" THEN value2show = strings.displayValue

          WHEN answer = 'P' THEN    /* print the Key-value */
               CALL print iIni, iTopL, iKey

          WHEN answer = "F" THEN value2show = strings.filterValue




         WHEN answer = "C" THEN         /* copy key to another TopLevel */
              DO
                TopLevelCreated = TopLevelCreated | copy_keys(iIni, iTopL, "0", iKey)
              END

         WHEN answer = "M" THEN         /* move key to another TopLevel or rename it */
              DO
                TopLevelCreated = TopLevelCreated | move_keys(iIni, iTopL, "0", iKey)
                dirty = 1
                LEAVE
              END

          WHEN answer = "D" THEN                        /* delete key */
               DO
                  CALL BEEP 2000, 250
                  CALL CHAROUT , global.iRedWhite || "Do you really wish to delete this KEY ?" || global.noHint 
                  answer = get_answer("QYN")
                  CALL CHAROUT , global.iCyan

                  IF answer = "Q" THEN SIGNAL halt

                  IF answer = "Y" THEN
                  DO
                     val = SysIni(stemIni.iIni, stemTopLevel.iTopL.origValue, stemKey.iKey.origValue, "DELETE:")
                     dirty = 1
                     LEAVE
                  END
               END

          WHEN answer = "E" THEN                        /* change key-value */
               DO
                  PARSE VALUE edit_value("E", val, , , "Enter new Key-Value") WITH tmpState tmpResult
                  IF tmpState = "OK" THEN
                  DO
                     val = SysIni(stemIni.iIni, stemTopLevel.iTopL.origValue, stemKey.iKey.origValue, tmpResult)
                     val = tmpResult
                  END

                  CALL check_value val
                  iType = strings.type        /* type could be A, A0 or H */
                  value2show = strings.displayValue
              
                  choice = ""
               END
 
          OTHERWISE LEAVE
       END  
   
       SAY
    END

    SAY
    IF dirty THEN               /* was a key added, renamed/moved, deleted ? */
    DO                          /* if so, reread keys */
       CALL read_key iIni, iTopL
       IF global.KeySortState = "S" THEN              /* resort keys */
          CALL sort_generic "stemKey"
    END
    RETURN TopLevelCreated


/* 
   check data-type of argument and set up a structure containing different representations
   of it
*/
CHECK_VALUE: PROCEDURE EXPOSE global. strings.
   DROP strings.
   strings. = ""

   length_arg1 = LENGTH(ARG(1))         /* length of ARG(1) */

   IF length_arg1 = 0 THEN              /* unknown key-value, key-value not set. */
   DO
      strings.type = "H"
      strings.displayValue = "x''"
      strings.filterValue = ""
      RETURN
   END

   /* last character \0 ? */

   IF SUBSTR(ARG(1), length_arg1, 1) = "00"x THEN    /* ASCIIZ ? */
   DO
      work = SUBSTR(ARG(1), 1, length_arg1 - 1)
      asciiz = "0"
   END
   ELSE                                                 
   DO
      work = ARG(1)
      asciiz = ""
   END

   ascii = (VERIFY(work, global.iNonPrintable, "Match") = 0)    /* plain ASCII ? */

   IF ascii THEN                                        /* ASCII-type value in hand */
   DO
      IF asciiz = "0" THEN strings.type = "A0"
                      ELSE strings.type = "A"
      strings.displayValue = work
   END
   ELSE                                                 /* hexadecimal value in hand */
   DO
      strings.type = "H"
      strings.displayValue = "x'" || C2X(ARG(1)) || "'"
      strings.filterValue = TRANSLATE(ARG(1), global.iFilter, global.iNonPrintable)
   END
   RETURN



/*
   allow for adding or editing a value
   ARG(1) ... A to add, E to edit
   ARG(2) ... title
   ARG(3) ... optional, if given, then only ASCII-values allowed
   ARG(4) ... optional, if given, then only HEX- or ASCII-editing allowed (for TopLevels and
              keynames
   ARG(5) ... optional, if given, then the prompt for BOXEDIT
*/
EDIT_VALUE: PROCEDURE EXPOSE global. strings.
   editType = ARG(1)    /* A add new, E edit existing */
   editName = ARG(2)    /* if adding new: TopLevel-entry or Key-entry 
                           if editing: value to be added */
   editDataType = ARG(3) /* optional, determines data-type "A", "A0", "H" */


   IF editType = "A" THEN
   DO
      DROP strings.
      strings. = ""
      tmpValue = ""

      IF ARG() = 3 THEN strings.type = editDataType
      ELSE
         choices = "12"
         SAY global.iCyan || "Defining:" global.iYellow || editName || global.iCyan
         SAY
         SAY "choose data type:" 
         SAY
         SAY "       " global.iYellow || "1" global.iCyan global.dtype.H.long
         SAY "       " global.iYellow || "2" global.iCyan global.dtype.A.long global.defaultHint

         IF ARG() < 4 THEN      /* ASCIIZ (A0) allowed ? */
         DO
           SAY "       " global.iYellow || "3" global.iCyan global.dtype.A0.long
           choices = choices || "3"
         END

         SAY "       " global.iCyan   || "   [Esc] to return"
         /* define choices and get answer from user */
         CALL CHAROUT , global.iYellow
         answer = get_answer("123Q")
         CALL CHAROUT , global.iCyan
   
         SELECT
            WHEN answer = "Q" THEN SIGNAL halt
            WHEN answer = "1" THEN strings.type = "H"
            WHEN answer = "2" | answer = "" THEN strings.type = "A"
            WHEN answer = "3" THEN strings.type = "A0"
   
            OTHERWISE RETURN "NOK"
         END  
      DO
      END


    END
    ELSE        /* editing mode */
    DO
       val = editName
       CALL CHECK_VALUE val

       IF strings.type = "A" | strings.type = "A0" THEN
       DO
           IF ARG() = 3 THEN answer = SUBSTR(editDataType, 1, 1)
           ELSE
           DO
              SAY global.iCyan || "choose data type for editing:"
              SAY
              SAY "       " global.iYellow || "H" global.iCyan global.dtype.H.long
              SAY "       " global.iYellow || "A" global.iCyan global.dtype.A.long global.defaultHint
              SAY "       " global.iCyan   || "   [Esc] to return"
   
              /* define choices and get answer from user */
              CALL CHAROUT , global.iYellow
              answer = get_answer("HAQ")
              CALL CHAROUT , global.iCyan
   
              IF answer = "Q" THEN SIGNAL halt    
   
              IF answer = "1B"x THEN RETURN "NOK"  /* Escape was pressed */
           END
                                                
           IF answer = "" | answer = "A" THEN   /* edit as ASCII */
           DO
              tmpValue = strings.displayValue
           END
           ELSE
           DO
              strings.type = "H"
              tmpValue = C2X(val)
           END

       END
       ELSE tmpValue = C2X(val)
    END


    tmpLength = LENGTH(tmpValue)

    neededRows = TRUNC(tmpLength / (global.iColumns - 2) + 0.9999) + 2

    IF neededRows > global.iRows THEN
    DO
       SAY
       CALL error_msg "screen-size not large enough to edit value !"
       val = "NOK"
    END
    ELSE  /* try to add four more empty lines */
    DO
       DO 4
          IF (neededRows + 1) < global.iRows THEN neededRows = neededRows + 1
                                             ELSE LEAVE
       END
       /* get present position */
       PARSE VALUE SysCurPos() WITH cursor_row cursor_col

       startingRow = cursor_row - neededRows 

       IF startingRow < 0 THEN startingRow = 0

       tmpType = ""       /* ASCII-edit for default */
       IF strings.type = "H" THEN tmptype = "H"
       editResult = boxedit((startingRow 0 (startingRow + neededRows - 1) (global.iColumns - 1)),,
                             tmpValue, tmpType, ARG(5))
       editResult = STRIP(editResult, "T")        /* remove trailing blanks */

       val = "NOK"
       IF editResult <> tmpValue THEN
       DO
          SELECT
             WHEN strings.type = "H" THEN val = "OK" X2C(editResult)
             WHEN strings.type = "A0" THEN val = "OK" editResult || "00"x
             OTHERWISE val = "OK" editResult
          END  
       END
    END
    RETURN val



/***********************************************************************************************/
/*
    print to file
*/
PRINT: PROCEDURE EXPOSE global. strings. stemIni. stemTopLevel. stemKey.
    iIni  = ARG(1)      /* INI-file to be printed */
    iTopL = ARG(2)      /* TopLevel to be printed */
    iKey  = ARG(3)      /* Key to be printed */

    IF global.iBackupMode = "" THEN    /* prompt user */
    DO
       SAY
       SAY "Following settings are active:"
       SAY
       SAY global.iCyan || "Level of information to produce:" global.iYellow || VALUE("global.depthOfOutput." || global.config.showDepth)
       SAY global.iCyan || "Hexadecimal values shown as:    " global.iYellow || VALUE("global.hextypeOfOutput." || global.config.showHexAs)
       SAY global.iCyan || "Line length in characters:      " global.iYellow || global.config.showLineLength
       SAY
       CALL CHAROUT , global.iCyan || "Do you wish to change these settings ?" global.noHint
   
       /* define choices and get answer from user */
       CALL CHAROUT , global.iYellow
       answer = get_answer("YNQ")
       CALL CHAROUT , global.iCyan
   
       IF answer = "1B"x THEN RETURN 0
       ELSE IF answer = "Q" THEN SIGNAL halt
   
       IF answer = "Y" THEN                /* Yes, change the settings in effect */
       DO
         CALL settings_printout
       END
   
       answer = ""
       /* output file exists, shall we append to it ? */
       IF global.outFile <> "" THEN
       DO
          SAY
          SAY global.iCyan || "You printed already to file" global.iYellow || global.outFile || global.iCyan || "."
          SAY
          SAY global.iCyan || "Do you wish to append to it?" global.yesHint
          /* define choices and get answer from user */
          CALL CHAROUT , global.iYellow
          answer = get_answer("YNQ")
          CALL CHAROUT , global.iCyan
   
          IF answer = "1B"x THEN RETURN 0
          ELSE IF answer = "Q" THEN SIGNAL halt
      
       END
   
       IF answer = "N" | global.outFile = "" THEN  /* get file name to print to */
          IF \get_filename() THEN RETURN           /* user aborted print-operation ? */
    END

    /* o.k., now let us start producing the output ! */

    SELECT
       WHEN ARG() = 0 THEN      /* all INI-files to be printed */
            DO
               DO i = 1 TO stemIni.0
                  CALL output_filename i, "AI"          /* print file-name */
                                                        
                  CALL read_toplevel i                  /* read top-levels */
                  CALL sort_generic "stemTopLevel"      /* sort them */
                  DO j = 1 TO stemTopLevel.0
                     CALL output_topic j                /* print topic-name */
                     IF POS(global.config.showDepth, "KV") > 0 THEN             /* show more than TopLevel ? */
                     DO
                        CALL read_key i, j              /* read keys */
                        CALL sort_generic "stemKey"     /* sort them */
                        DO k = 1 TO stemKey.0
                           CALL output_key k            /* print key-name */
   
                           IF POS(global.config.showDepth, "V") > 0 THEN      /* show key-values too ? */
                           DO
                              /* get key-value */
                              val = SysIni(stemIni.i, stemTopLevel.j.origValue, stemKey.k.origValue)
                              CALL output_val val       /* print value */
                           END
                        END
                        CALL LINEOUT global.outFile, "" /* write empty line */
                     END
                  END
               CALL LINEOUT global.outFile, ""          /* write empty line */
               END
            END

       WHEN ARG() = 1 THEN      /* one INI-file, all TopLevels to be printed */
            DO
               i = iIni
               CALL output_filename i, "AT"             /* print file-name */
               CALL sort_generic "stemTopLevel"         /* sort them */
                                                       
               DO j = 1 TO stemTopLevel.0              
                  CALL output_topic j                   /* print topic-name */
                  IF POS(global.config.showDepth, "KV") > 0 THEN    /* show more than TopLevel ? */
                  DO
                     CALL read_key i, j                 /* read keys */
                     CALL sort_generic "stemKey"        /* sort them */
                     DO k = 1 TO stemKey.0
                        CALL output_key k               /* print key-name */

                        IF POS(global.config.showDepth, "V") > 0 THEN      /* show key-values too ? */
                        DO
                           /* get key-value */
                           val = SysIni(stemIni.i, stemTopLevel.j.origValue, stemKey.k.origValue)
                           CALL output_val val          /* print value */
                        END
                     END
                     CALL LINEOUT global.outFile, ""    /* write empty line */
                  END
               END
               CALL LINEOUT global.outFile, ""          /* write empty line */
            END

       WHEN ARG() = 2 THEN      /* one INI-file, one TopLevel, all keys to be printed */
            DO
               i = iIni
               j = iTopL
               CALL output_filename i, "AK"             /* print file-name */
               CALL output_topic j                      /* print topic-name */
                                                        
               CALL read_key i, j                       /* read keys */
               CALL sort_generic "stemKey"              /* sort them */
                                                        
               DO k = 1 TO stemKey.0                    
                  CALL output_key k                     /* print key-name */

                  IF POS(global.config.showDepth, "V") > 0 THEN      /* show key-values too ? */
                  DO
                     /* get key-value */
                     val = SysIni(stemIni.i, stemTopLevel.j.origValue, stemKey.k.origValue)
                     CALL output_val val                /* print value */
                  END
               END
               CALL LINEOUT global.outFile, ""          /* write empty line */
            END

       WHEN ARG() = 3 THEN      /* one INI-file, one TopLevel, one key and its value to be printed */
            DO
               i = iIni
               j = iTopL
               k = iKey

               CALL output_filename i, "K"              /* print file-name */
               CALL output_topic j                      /* print topic-name */
               CALL output_key k                        /* print key-name */

               /* get key-value */
               val = SysIni(stemIni.i, stemTopLevel.j.origValue, stemKey.k.origValue)
               CALL output_val val                      /* print value */
               CALL LINEOUT global.outFile, ""          /* write empty line */
            END

       OTHERWISE NOP
    END  

    SAY
    CALL STREAM global.outFile, "C", "CLOSE"            /* close output file */

    RETURN


/*
   write Filename into File, argument: index of INI-file to be processed
*/
OUTPUT_FILENAME: PROCEDURE EXPOSE global. stemIni. stemTopLevel.
    range = ARG(2)      /* range of printout (all INIs, all TopLevels, all Keys, one Key) */
    /* show date/time of printout */
    tmp = LEFT("Date  [" || DATE("S") TIME() || "] ", global.config.showLineLength, "=")
    CALL LINEOUT global.outFile, tmp

    CALL LINEOUT global.outFile, ""

    /* show range of printout */
    tmp = LEFT("Range [" || VALUE("global.rangeOfPrintout." || range) || "] ", global.config.showLineLength, "=")
    CALL LINEOUT global.outFile, tmp

    /* show depth of information */
    tmp = LEFT("Depth [" || VALUE("global.depthOfOutput." || global.config.showDepth) || "] ", global.config.showLineLength, "=")
    CALL LINEOUT global.outFile, tmp

    CALL LINEOUT global.outFile, ""

    /* show filename, no matter how long it is */
    filename = "File  [" || VALUE("stemIni." || ARG(1))
    filler   = "      ["

    SAY filename || "]"

    tmp = ""

    /* filename can be arbitrarily long */
    DO WHILE filename <> ''     
       IF LENGTH(filename) >= global.config.showLineLength THEN
       DO
          tmp = SUBSTR(filename, 1, global.config.showLineLength - 1) || "]"
          filename = filler || SUBSTR(filename, global.config.showLineLength)
       END
       ELSE
       DO
          tmp = filename || "] "
          tmp = LEFT(tmp, global.config.showLineLength, "=")
          filename = ""
       END

       CALL LINEOUT global.outFile, tmp 
    END

    /* show # of TopLevel entries */
    tmp = LEFT("TopL# [" || stemTopLevel.0 "TopLevel(s)] ", global.config.showLineLength, "=")
    CALL LINEOUT global.outFile, tmp


    CALL LINEOUT global.outFile, ""     /* empty line */
    RETURN

/*
   write TopLevel entry
*/
OUTPUT_TOPIC: PROCEDURE EXPOSE global. stemTopLevel.
    iInd = ARG(1)

    tmpDisplay = stemTopLevel.iInd
    tmpFiltered = ""

    SAY LEFT(global.format.forTop || "[" || tmpDisplay || "]", global.iColumns - 1)

    IF stemTopLevel.iInd.type = "H" THEN
    DO
       IF global.config.showHexAs = "H" | global.config.showHexAs = "B" THEN
          tmpDisplay = SUBSTR(tmpDISPLAY, 3, LENGTH(tmpDisplay) - 3)
       ELSE
          tmpDisplay = ""

       IF global.config.showHexAs = "F" | global.config.showHexAs = "B" THEN
           tmpFiltered = stemTopLevel.iInd.FilterValue
    END

    global.config.showDataLength = global.config.showLineLength - (global.format.forTop.Length + 7)   /* "[A0] [" ..."]" longest append */
    CALL print_go_do_it_finally_god_damn_it global.format.forTop, global.format.forTop.LeadIn, stemTopLevel.iInd.type, tmpDisplay, tmpFiltered
    RETURN


/*
   write Key entry
*/
OUTPUT_KEY: PROCEDURE EXPOSE global. stemKey.
    iInd = ARG(1)

    tmpDisplay = stemKey.iInd
    tmpFiltered = ""

    SAY LEFT(global.format.forKey || "[" || tmpDisplay || "]", global.iColumns - 1)

    IF stemKey.iInd.type = "H" THEN
    DO
       IF global.config.showHexAs = "H" | global.config.showHexAs = "B" THEN
          tmpDisplay = SUBSTR(tmpDISPLAY, 3, LENGTH(tmpDisplay) - 3)
       ELSE
          tmpDisplay = ""

       IF global.config.showHexAs = "F" | global.config.showHexAs = "B" THEN
           tmpFiltered = stemKey.iInd.FilterValue
    END

    global.config.showDataLength = global.config.showLineLength - (global.format.forKey.Length + 7)   /* "[A0] [" ..."]" longest append */
    CALL print_go_do_it_finally_god_damn_it global.format.forKey, global.format.forKey.LeadIn, stemKey.iInd.type, tmpDisplay, tmpFiltered
    RETURN


/*
   write Key value
*/
OUTPUT_VAL: PROCEDURE EXPOSE global.
    CALL check_value ARG(1)

    tmpDisplay = strings.DisplayValue
    tmpFiltered = ""

    IF strings.type = "H" THEN
    DO
       IF global.config.showHexAs = "H" | global.config.showHexAs = "B" THEN
          tmpDisplay = SUBSTR(tmpDISPLAY, 3, LENGTH(tmpDisplay) - 3)
       ELSE
          tmpDisplay = ""

       IF global.config.showHexAs = "F" | global.config.showHexAs = "B" THEN
           tmpFiltered = strings.FilterValue
    END

    global.config.showDataLength = global.config.showLineLength - (global.format.forVal.Length + 7)   /* "[A0] [" ..."]" longest append */
    CALL print_go_do_it_finally_god_damn_it global.format.forVal, global.format.forVal.LeadIn, strings.type, tmpDisplay, tmpFiltered
    RETURN



PRINT_GO_DO_IT_FINALLY_GOD_DAMN_IT: PROCEDURE EXPOSE global.
    title    = ARG(1)
    leadin   = ARG(2)
    type     = ARG(3)
    display  = ARG(4)
    filtered = ARG(5)     

    tmp1 = title
    type_name = LEFT(VALUE("global.dtype." || type), 4) || " ["

    DO WHILE display <> ""
       IF LENGTH(display) > global.config.showDataLength THEN
       DO
          tmp = SUBSTR(display, 1, global.config.showDataLength)
          display = SUBSTR(display, global.config.showDataLength + 1)
       END
       ELSE
       DO
          tmp = display
          display = ""
       END

       CALL LINEOUT global.outFile, tmp1 || type_name || tmp || "]"
       tmp1 = leadin
    END

    IF type = "H" & filtered <> "" THEN
    DO
       type_name = LEFT(VALUE("global.dtype." || "F"), 4)  || " ["   /* for ASCII-filtered strings */
   
       DO WHILE filtered <> ""
          IF LENGTH(filtered) > global.config.showDataLength THEN
          DO
             tmp = SUBSTR(filtered, 1, global.config.showDataLength)
             filtered = SUBSTR(filtered, global.config.showDataLength + 1)
          END
          ELSE
          DO
             tmp = filtered
             filtered = ""
          END
   
          CALL LINEOUT global.outFile, tmp1 || type_name || tmp || "]"
          tmp1 = leadin
       END
    END

    RETURN



/* ask user for the filename into which output should be printed */
GET_FILENAME: PROCEDURE EXPOSE global.
    IF global.outFile = "" THEN
       tmpResult = DIRECTORY() || "\"   /* supply current directory as default */
    ELSE
       tmpResult = global.outFile

    DO FOREVER
       SAY
       SAY "Enter file name:"
       SAY
       PARSE VALUE edit_value("E", tmpResult, "A", , "Enter new File-name") WITH tmpState tmpResult

       IF tmpState = "OK" THEN          /* check whether file exists already */
       DO
          IF STREAM(tmpResult, "C", "QUERY EXISTS") <> "" THEN
          DO
             CALL BEEP 2000, 250
             SAY
             SAY global.iYellow || tmpResult || global.iCyan "exists already !"

             SAY
             SAY "       " global.iYellow || "D" global.iCyan "delete existing file"
             SAY "       " global.iYellow || "A" global.iCyan "append to existing file"
             SAY "       " global.iCyan   || "   [Esc] to return"
          
             /* define choices and get answer from user */
             CALL CHAROUT , global.iYellow
             answer = get_answer("DAQ", , "NO-CR")   /* force an entry */
             CALL CHAROUT , global.iCyan
      
             SELECT
                WHEN answer = "1B"x THEN RETURN 0     /* Escape was pressed */
                WHEN answer = "Q" THEN SIGNAL halt
                WHEN answer = "D" THEN                /* delete existing file */
                     DO
                        ADDRESS CMD "@DEL" tmpResult /* let OS/2 erase it */
                        IF RC <> 0 THEN
                        DO
                           SAY
                           CALL error_msg tmpResult || global.iCyan "could not be deleted, aborting..."
                           RETURN 0
                        END
                     END
      
                OTHERWISE NOP
             END  
             LEAVE
          END
          ELSE       /* file does not exist yet, create it */
          DO
             IF STREAM(tmpResult, "C", "Open Write") <> "READY:" THEN        /* error while creating file */
             DO
                SAY
                CALL error_msg global.iYellow || tmpResult global.iRedWhite || "could not be created !"

                CALL CHAROUT , "Try another filename ?" global.yesHint
                answer = get_answer("YNQ")
                CALL CHAROUT , global.iCyan
         
                SELECT
                   WHEN answer = "1B"x THEN RETURN 0     /* Escape was pressed */
                   WHEN answer = "Q" THEN SIGNAL halt
                   WHEN answer = "Y" || answer = "" THEN ITERATE
                   OTHERWISE RETURN 0
                END
             END
          END
       END
       ELSE RETURN 0

       LEAVE
    END
    global.outFile = tmpResult

    RETURN 1

/***********************************************************************************************/

/*
   display error message passed in ARG(1)
   if ARG(2) given, then do not prompt user for keyboard-input, return immediately
*/
ERROR_MSG: PROCEDURE EXPOSE global.
    SAY global.iRedWhite || ARG(1)  global.iCyan
    IF ARG() = 1 THEN
    DO
       CALL BEEP 2000, 250
       SAY "press any key to continue..."
       tmp = SysGetKey("NOECHO")
/*
       IF TRANSLATE(tmp) = "Q" THEN SIGNAL halt         /* quit immediately */
*/
       SAY
    END
    RETURN


HALT:
   IF global.outFile <> "" THEN         /* interrupted while writing to file */
   DO
      CALL STREAM global.outFile, "C", "CLOSE"  /* close file */
   END

   IF global.eMultipleFiles & global.config.eLog THEN
   DO
      CALL LINEOUT global.eLogFile, DATE("S") TIME() "*** User interrupted application ! ***"
      CALL LINEOUT global.eLogFile, COPIES("*", 80)
      CALL STREAM  global.eLogFile, "C", "CLOSE"
   END

   SAY 
   SAY global.iNormal || "User interrupted application."
   EXIT -1                              /* user interrupt       */


/* ********************** ********************** *********************** ****************** */

BACKUP_RESTORE_UPDATE: PROCEDURE EXPOSE global.

command_line = ARG(1)

IF command_line = "?" | TRANSLATE(command_line) = "H" THEN SIGNAL usage

PARSE ARG WITH '/'switch filename

/* defaults */
stemFiles. = ""                 /* set default to empty */
stemFiles.0 = 0                 /* no element in array  */

/* defaults for ASCII-backup */
IF global.config.showDepth <> "V" THEN       /* show everything ? */
   global.config.showDepth = "V"     /* set switch to show everything */

IF global.config.showHexAs = "F" THEN        /* show filtered ASCII-string only ? */               
   global.config.showHexAs = "B"             /* show both, hexadecimal and filtered value */


/* check  arguments */
switch = TRANSLATE(switch)

/* extract number of generations */
generations = ""
DO i = LENGTH(switch) TO 1 BY -1
   tmp = SUBSTR(switch, i, 1)
   IF DATATYPE(tmp, "N") THEN generations = generations || tmp
   ELSE LEAVE
END


IF generations = "" THEN generations = 10               /* 10 generations, numbered from 0 thru 9 by default */
ELSE IF generations < 1 | generations > 10 THEN
DO
   SAY global.iYellow || "Invalid number of generations (minimum = 1, maximum = 10):" global.iYellow || generations || global.iNormal
   EXIT -2
END

switch = SUBSTR(switch, 1, i)           /* remaining switch */

/* check whether switch is valid */
IF switch <> "B" & switch <> "U" & switch <> "R" & switch <> "BT" & switch <> "UT" & switch <> "RT" THEN
DO
   SAY global.iYellow || "Invalid switch !" global.iYellow || switch || global.iNormal
   EXIT -2
END


IF global.config.eLog THEN
DO
   CALL log2file COPIES("-", 79), "no-indention"  /* insert empty line */
   CALL log2file "Processing of [" || command_line || "] started."
END

filename = STRIP(filename)              /* get rid of blanks */

global.eMultipleFiles = 1               /* default: multiple files to process */


IF LEFT(filename, 1) = "/" THEN         /* another switch is active */
DO
   tmp = TRANSLATE(filename)            /* force to uppercase */
   tmp = SUBSTR(tmp, 2, 1)              /* get first letter */

   SELECT
      WHEN tmp =  "A" THEN              /* scan ALL drives */
           map = SysDriveMap(, "USED")  /* get a list of all used drives */

      WHEN tmp =  "L" THEN              /* scan all LOCAL drives */
           map = SysDriveMap(, "LOCAL") /* get a list of all used drives */

      WHEN tmp =  "R" THEN              /* scan all REMOTE drives */
           map = SysDriveMap(, "REMOTE")/* get a list of all used drives */

      WHEN tmp = "D" THEN               /* scan defined DRIVES */
           DO
              PARSE UPPER VAR filename ":" map

              IF VERIFY(map, XRANGE("41"x, "5A"x)) > 0 THEN     /* range: "A" ... "Z" */
              DO
                 SAY "Error in argument: Illegal drive-letters !"
                 EXIT -2
              END

              tmp = ""                  /* build "A: B: C:" from ABC */
              DO WHILE map <> ""
                 PARSE VAR map 1 drive 2 map
                 tmp = tmp drive ||":"
              END
              map = STRIP(tmp)
           END

      OTHERWISE                         /* USER (OS2.INI), SYSTEM (OS2SYS.INI), or BOTH */
           DO
              map = ""                  /* indicate no checking on drives */
              tmp_user   = VALUE("USER_INI", , "OS2ENVIRONMENT")
              tmp_system = VALUE("SYSTEM_INI", , "OS2ENVIRONMENT")

              IF tmp_user = "" | tmp_system = "" THEN
              DO
                 CALL log2file COPIES("-", 79), "no-indention"  /* insert empty line */
                 SAY "Error: environment variables USER_INI or SYSTEM_INI not set !"
                 EXIT -2
              END

              stemFiles.0 = 1           /* default, one entry only     */

              IF tmp = "U" THEN         /* backup USER-ini   = OS2.INI */
                 stemFiles.1 = tmp_user
              ELSE IF tmp = "S" THEN    /* backup SYSTEM-ini = OS2SYS.INI */
                 stemFiles.1 = tmp_system
              ELSE IF tmp = "B" THEN    /* backup both, OS2.INI and OS2SYS.INI */
              DO
                 stemFiles.0 = 2        /* two files to backup */
                 stemFiles.1 = tmp_user
                 stemFiles.2 = tmp_system
              END
              ELSE
              DO
                 SAY "Error: wrong command-line switch !"
                 EXIT -2
              END

           END
   END

   DO WHILE map <> ""                /* search drives for valid INI-files */
      PARSE VAR map drive map
      drive = drive || "\*.ini"

      SAY global.iCyan || "scanning drive" global.iYellow ||drive||global.iCyan "for accessible INI-files..." global.iNormal
      CALL SysFileTree drive, "file", "FSO"

      DO i = 1 TO file.0
         /* check whether accessible from OS/2, i.e. an OS/2 INI-file */
         ok = SysIni(file.i, 'ALL:', 'TopLevel')
         IF ok <> "ERROR:" & TopLevel.0 > 0 THEN
         DO
            SAY global.iCyan || "     file" global.iYellow || file.i || global.iCyan "found..." global.iNormal
            stemFiles.0 = stemFiles.0 + 1
            j = stemFiles.0
            stemFiles.j = file.i
         END
      END
      SAY 
   END
END
ELSE                    /* single, specific file */
DO
   /* check whether file exists */
   IF filename = "" THEN sourceFile = ""
   ELSE sourceFile = STREAM(filename, "C", "QUERY EXISTS")

   IF sourceFile = "" THEN
   DO
      CALL log2file, "***Error: file does not exist !***", "no-date"
      SAY "Error: file does not exist !"
      EXIT -3
   END

   stemFiles.0 = 1              /* default, one entry only     */
   stemFiles.1 = sourceFile
   global.eMultipleFiles = 0    /* one distinct file to process */
END



global.iBackupMode = "Quiet !"

DO  iI = 1 TO stemFiles.0               /* cycle thru all given files */
   sourceFile = stemFiles.iI            /* assign file to work-variable */
   SAY COPIES("=", 79)

   global.iBackupMode.iDrive = FILESPEC("drive", sourceFile)
   global.iBackupMode.iPath  = FILESPEC("path",  sourceFile)

   
   SELECT
      WHEN switch = "B" THEN       /* backup to an OS2-INI-file */
           DO
              tmp = "BACKUP-MODE: produced backup wil be an OS/2-INI-file."
              SAY global.iCyan || tmp || global.iNormal
              SAY

              IF global.config.eLog THEN
              DO
                 CALL log2file tmp
                 CALL log2file "SOURCE:" sourceFile, "no-date"
              END

              IF check_if_ini(sourceFile) < 0 THEN
              DO
                 SAY global.iRedWhite || "***Error: [" || sourcefile || "] is not an OS/2-INI-file !" global.iNormal

                 IF global.config.eLog THEN
                     CALL log2file "***Error: not an OS/2-INI-file !***", "no-date"
              END
              ELSE
              DO
                 global.bkpFileName = get_next_file(sourceFile, generations)  /* get name of the new backup-file */
   
                 IF global.config.eLog THEN
                    CALL log2file "TARGET:" global.bkpFileName, "no-date"
   
                 CALL make_backup sourceFile, global.bkpFileName              /* backup the INI-file */
              END
   
           END
   
      WHEN switch = "BT" THEN      /* backup to an ASCII-file */
           DO
              tmp = "BACKUP-MODE: produced backup will be an ASCII-file."
              SAY global.iCyan || tmp || global.iNormal
              SAY

              IF global.config.eLog THEN
              DO
                 CALL log2file tmp
                 CALL log2file "SOURCE:" sourceFile, "no-date"
              END

              IF \global.eMultipleFiles & check_if_ini(sourceFile) < 0 THEN
              DO
                 SAY global.iRedWhite || "***Error: not an OS/2-INI-file !" global.iNormal
                 IF global.config.eLog THEN
                     CALL log2file "***Error: source file is not an OS/2-INI-file !***", "no-date"
              END
              ELSE      /* single file */
              DO
                 /* backup-ASCII-file gets a file extension of "TXT", hence 10 backups from "TX0" thru "TX9" */
                 tmpName  = FILESPEC("name",  sourceFile)
      
                 pointPos = LASTPOS(".", tmpName)
                 IF pointPos = 0 THEN tmpName = tmpName || ".TXT"
                                 ELSE tmpName = SUBSTR(tmpName, 1, pointPos) || "txt"
      
                 /* build name of the new backup-file */
                 global.outFile = get_next_file(global.iBackupMode.iDrive ||, /* get name of the new backup-file */
                                                global.iBackupMode.iPath ||,
                                                tmpName, generations)
   
                 IF global.config.eLog THEN
                    CALL log2file "TARGET:" global.outFile, "no-date"
      
                 stemIni.0 = 1                  /* number of entries */
                 stemIni.1 = sourceFile         /* assign OS/2-INI-file-name to be printed into an ASCII-file */
      
                 SAY
                 SAY global.iCyan || "Source (OS/2-INI-file):" global.iYellow || sourceFile
                 SAY global.iCyan || "Target (backup-file):  " global.iYellow || global.outFile || global.iNormal
                 SAY
      
                 CALL read_toplevel 1           /* read & prepare TopLevel entries, do not sort them */
      
                 CALL print 1                   /* call print-procedure, have all TopLevels printed */
              END
   
              CALL STREAM global.outFile, "C", "CLOSE"     /* close output file */
           END
   
      WHEN switch = "R" | switch = "U" THEN     /* restore or update from an OS/2-INI-file */
           DO
              IF switch = "R" THEN tmp = "RESTORE-MODE:"
                              ELSE tmp = "UPDATE-MODE:"
   
              tmp = tmp "backup is in OS/2-INI-file-format."
              SAY global.iCyan || tmp || global.iNormal
              SAY

              IF global.config.eLog THEN
                 CALL log2file tmp 

              IF global.eMultipleFiles THEN     /* if multiple files, get the true backup */
              DO
                 tmp = get_backup_to_use(sourceFile, generations, "INI")

                 IF tmp = "" THEN
                 DO
                    SAY global.iRedWhite || "***Error: No backup found for [" || sourcefile || "] !" global.iNormal
                    IF global.config.eLog THEN
                       CALL log2file "***Error: no backup file found for [" || sourceFile || "] ***", "no-date"
                    ITERATE
                 END

                 sourceFile = tmp
              END

              IF global.config.eLog THEN
                 CALL log2file "SOURCE:" sourceFile, "no_date"

              targetIni = getBkpData_Ini(sourceFile)       /* get target INI-name from INI-bkp */

              IF targetIni <> "" THEN
              DO
                 IF global.config.eLog THEN
                    CALL log2file "TARGET:" targetIni, "no_date"
   
                 CALL ini_restore_from_ini sourceFile, targetIni, switch     /* restore/update original */
              END

              CALL STREAM sourceFile, "C", "CLOSE"         /* close input file */
           END
   
      WHEN switch = "RT" | switch = "UT" THEN      /* restore or update from an ASCII-file */
           DO
              IF switch = "RT" THEN tmp = "RESTORE-MODE:"
                               ELSE tmp = "UPDATE-MODE:"
   
              tmp = tmp "backup is in ASCII-file-format."
              SAY global.iCyan || tmp  || global.iNormal
              SAY
   
              IF global.config.eLog THEN
                 CALL log2file tmp 

              IF global.eMultipleFiles THEN     /* if multiple files, get the true backup  */
              DO
                 tmp = get_backup_to_use(sourceFile, generations, "TXT")

                 IF tmp = "" THEN
                 DO
                    SAY global.iRedWhite || "***Error: No backup found for [" || sourcefile || "] !" global.iNormal
                    IF global.config.eLog THEN
                       CALL log2file "***Error: no backup file found for [" || sourceFile || "] ***", "no-date"
                    ITERATE
                 END
                 sourceFile = tmp
              END

              IF global.config.eLog THEN
                 CALL log2file "SOURCE:" sourceFile, "no_date" 

              CALL ini_restore_from_txt sourceFile, switch /* use ASCII-file for restore */
              CALL STREAM sourceFile, "C", "CLOSE"         /* close input file */
           END
   
   
      OTHERWISE NOP
   END  
END 


IF global.config.eLog THEN
   CALL log2file "Processing of [" || command_line || "] ended."

EXIT 0          /* finished batch-mode */





/*************************************************************************************/


/*
        find the backup according to the given generation
        if no backup with the given generation was found, try to locate a "younger" backup
        if no backup was found return an empty string
*/
GET_BACKUP_TO_USE: PROCEDURE EXPOSE global.
   sourceFile = ARG(1)
   generations = ARG(2)
   extension = ARG(3)

   tmp = SUBSTR(sourceFile, 1, LASTPOS(".", sourceFile)) || SUBSTR(extension, 1, 2)

   DO i = generations - 1 TO 0 BY -1
      sourceFile = STREAM(tmp || i, "C", "QUERY EXISTS")
      IF sourceFile <> "" THEN LEAVE            /* found ! */
   END

   RETURN sourceFile




/*
   restores/updates from an INI-file
   if restore, then delete TopLevels and Keys in original which are not found in the backup
*/
INI_RESTORE_FROM_TXT: PROCEDURE EXPOSE global. 
    bkpIniFile  = ARG(1)
    switch      = ARG(2)
    done        = 0
    line        = ""

    /* get target filename */
    DO WHILE LINES(bkpIniFile) > 0
       IF line = "" & done THEN LEAVE
       line = LINEIN(bkpIniFile)
       PARSE VAR line key "[" value "]" rest

       IF SUBSTR(STRIP(key), 1, 1) = ";" THEN ITERATE   /* ignore comments */

       key = TRANSLATE(key)             /* translate key into uppercase */

       IF key = "FILE" THEN
       DO
          done = 1
          IF rest <> "" THEN            /* right square bracket part of filename ? */
          DO
             right_bracket = LASTPOS("]", rest)
             IF right_bracket > 0 THEN
             DO
                value = value || "]"
                IF right_bracket > 1 THEN
                   value = value || SUBSTR(rest, 1, right_bracket-1)
             END

          END

          targetIniFile = value

          /* now check, whether file spans multiple lines */
          DO WHILE LINES(bkpIniFile) > 0
             line = LINEIN(bkpIniFile)
                            /* comment-line ? */
             IF line = "" | SUBSTR(STRIP(line), 1, 1) = ";" THEN LEAVE          /* finished reading filename */

             PARSE VAR line key "[" value
             IF key <> "" THEN LEAVE            /* TopL# - key comes along */

             targetIniFile = targetIniFile || SUBSTR(value, 1, LASTPOS("]", value) - 1)
          END
          LEAVE
       END
    END 


    IF \done THEN
    DO
       IF global.config.eLog THEN
          CALL log2file "***Error: ASCII-file does not contain a valid backup ! ***", "no-date"

       IF global.eMultipleFiles THEN
       DO
          SAY global.iRedWhite || "***Error: ASCII-file [" || bkpIniFile || "] does not contain a valid Backup !" global.iNormal
          RETURN
       END

       CALL BEEP 2500, 250
       SAY global.iCyan || "ASCII-file" global.iYellow || bkpIniFile global.iRedWhite ||   "does not contain a valid INI-backup !" || global.iNormal
       EXIT -3
    END


    /******************************/
    /* check validity of INI-file */
    century = SUBSTR(DATE("S"), 1, 2)    /* get century information */

    /* file to restore must be in the same directory as backup */
    tmpFile = global.iBackupMode.iDrive ||,
              global.iBackupMode.iPath ||,
              FILESPEC("name", targetIniFile)

    tmpResult = STREAM(tmpFile, "C", "QUERY EXISTS")

    IF tmpResult = "" THEN              /* does not exist in backup directory */
    DO
       IF global.eMultipleFiles THEN
       DO
          origIniFile = tmpFile
       END
       ELSE
       DO
          CALL BEEP 2000, 250
          SAY global.iCyan || "Target-INI-file:" global.iYellow || tmpFile global.iCyan || "not found!" || global.iNormal
          SAY
   
          tmp = global.iCyan || "Create it ?" global.yesHint
          global.eAnswer = 1                              /* default to yes */
   
          IF \get_yes_no(tmp, "global.eAnswer") | \global.eAnswer THEN
          DO
             IF global.config.eLog THEN
                CALL log2file "Message: original INI-file does not exist, user aborted.", "no-date"
             CALL CHAROUT , global.iNormal
             EXIT -1    /* user aborted backup */
          END

          CALL CHAROUT , global.iNormal

          origIniFile = tmpFile
       END

       IF global.config.eLog THEN
          CALL log2file "Message: original INI-file does not exist, will be created.", "no-date"
    END
    ELSE
       origIniFile = tmpResult
   
    /* get date/time of target, i.e. INI-file */
    tmpDateTime = STREAM(origIniFile, "C", "QUERY DATETIME")
   
    IF tmpDateTime <> '' THEN
    DO
        /* make a sorted day from the American bound date-format  ! */
        PARSE VAR tmpDateTime month"-"day"-"year time
        tmpOrigDateTime = century || year || month || day time
    END
    ELSE
       tmpOrigDateTime = RIGHT("-", 8) || "  " || RIGHT("-", 8)
   
    /* get date/time of backup */
    tmpDateTime = STREAM(bkpIniFile, "C", "QUERY DATETIME")
   
    IF tmpDateTime <> '' THEN
    DO
        /* make a sorted day from the American bound date-format  ! */
        PARSE VAR tmpDateTime month"-"day"-"year time
        tmpBkpDateTime = century || year || month || day time
    END
   
    IF global.config.eLog THEN
       CALL log2file "TARGET:" origIniFile, "no-date"

    SAY global.iCyan || "Backup:   (" || global.iYellow || tmpBkpDateTime  || global.iCyan || ")" global.iYellow || bkpIniFile
    SAY global.iCyan || "Original: (" || global.iYellow || tmpOrigDateTime || global.iCyan || ")" global.iYellow || origIniFile || global.iNormal


    /***********/
    /* restore */

    DROP stemTopLevel.
    stemTopLevel. = ""
    stemTopLevel.0 = 0          /* no entries into this array */

    DROP stemKey.
    stemKey. = ""
    stemKey.0 = 0               /* no entries into this array */

    DROP tmp.
    tmp. = ""

    iTop = 0
    iKey = 0
    iVal = 0

    global.eTmp = 0

    DO WHILE LINES(bkpIniFile) > 0
       line = LINEIN(bkpIniFile)                /* read next line */

                      /* comment ? */
       IF line = "" | SUBSTR(STRIP(line), 1, 1) = ";" THEN ITERATE      /* iterate on empty line */

       PARSE VAR line key "[" type "]" "[" value "]" rest

       type = TRANSLATE(type)                   /* translate types into uppercase */
       IF type = "F" THEN ITERATE               /* hexadecimal representation with filtered ASCII-strings is ignored */

       key = TRANSLATE(key)                     /* translate keys into uppercase */

       IF SUBSTR(type, 1, 1) = "A" THEN         /* is value an ASCII-string ? */
          IF rest <> "" THEN                    /* right square bracket is part of ASCII-string ! */
          DO
             right_bracket = LASTPOS("]", rest)
             IF right_bracket > 0 THEN
             DO
                value = value || "]"
                IF right_bracket > 1 THEN
                   value = value || SUBSTR(rest, 1, right_bracket-1)
             END

          END


       SELECT
          WHEN key <> ""  THEN                  /* new Key */
               DO
                  SELECT
                     WHEN key = "TOP" THEN
                          DO
                             IF iVal THEN 
                             DO
                                IF iTop THEN    /* same as previous TopLevel */
                                   CALL update_ini origIniFile   /* set value in hand */
                                ELSE
                                   CALL update_ini origIniFile, "new Top"   /* set value in hand */
                             END
/*
                             SAY global.iCyan || "Toplevel #" global.iYellow || stemTopLevel.0 + 1 || global.iNormal
*/

                             IF stemKey.0 > 0 & switch = "RT" THEN      /* restore mode, delete all keys not in backup of present TopLevel */
                                   CALL delete_non_backedup_keys origIniFile, VALUE("stemTopLevel." || stemTopLevel.0)

                             DROP stemKey.
                             stemKey. = ""
                             stemKey.0 = 0               /* no entries into this array */

                             tmp.toppy               = value
                             tmp.toppy.typeIndicator = type
                             iTop = 0
                             iKey = 0
                             iVal = 0
                          END

                     WHEN key = "KEY" THEN
                          DO
                             IF iVal THEN 
                             DO
                                IF iTop THEN    /* same as previous TopLevel */
                                   CALL update_ini origIniFile   /* set value in hand */
                                ELSE
                                DO
                                   CALL update_ini origIniFile, "new Top"   /* set value in hand */
                                   iTop = 1
                                END
                             END
/*
                             SAY global.iCyan || "             Key #" global.iYellow || stemKey.0 + 1 || global.iNormal
*/

                             tmp.keyiy               = value
                             tmp.keyiy.typeIndicator = type
                             iKey = 1
                             iVal = 0
                          END

                     WHEN key = "VAL" THEN
                          DO
                             tmp.valuly               = value
                             tmp.valuly.typeIndicator = type
                             iVal = 1
                          END
                     OTHERWISE NOP
                  END 
               END

          OTHERWISE     /* add the next piece to the value */
               DO
                  SELECT
                     WHEN iVal THEN
                          tmp.valuly = tmp.valuly || value

                     WHEN iKey THEN
                          tmp.keyiy = tmp.keyiy || value

                     OTHERWISE 
                          tmp.toppy = tmp.toppy || value
                  END  
               END
       END  
    END


    IF iVal THEN 
    DO
       IF iTop THEN    /* same as previous TopLevel */
          CALL update_ini origIniFile   /* set value in hand */
       ELSE
          CALL update_ini origIniFile, "new Top"   /* set value in hand */
    END

    IF switch = "RT" THEN               /* restore mode, delete all keys not in backup */
    DO
       /* TopLevel in hand */
       CALL delete_non_backedup_keys origIniFile, VALUE("stemTopLevel." || stemTopLevel.0)
       CALL delete_non_backedup_toplevels origIniFile
    END

    IF switch = "RT" THEN tmp = "Restoring"
                     ELSE tmp = "Updating"

    SAY
    SAY global.iCyan || tmp "finished." global.iNormal

    RETURN



/*
   transform values, update stemTopLevel., stemKey., update target INI-file with new key
   if a second argument is given, then we have a new TopLevel being built, if there is an
   old one it has to be stored in the array
*/
UPDATE_INI: PROCEDURE EXPOSE global. stemTopLevel. stemKey. tmp.
    origIniFile = ARG(1)
    iTop = stemTopLevel.0

    IF ARG() = 2 | iTop = 0 THEN        /* build a new TopLevel ? */
    DO
       iTop = iTop + 1
       SELECT
          WHEN tmp.toppy.typeIndicator = "H" THEN  /* hexadecimal value */
               stemTopLevel.iTop = X2C(tmp.toppy)
          WHEN tmp.toppy.typeIndicator = "A" THEN
               stemTopLevel.iTop = tmp.toppy
          WHEN tmp.toppy.typeIndicator = "A0" THEN
               stemTopLevel.iTop = tmp.toppy || "00"x
          OTHERWISE             /* illegal data-type */
                  RETURN
       END
       stemTopLevel.0 = iTop
    END

    iKey = stemKey.0
    iKey = iKey + 1
    stemKey.0 = iKey

    SELECT
       WHEN tmp.keyiy.typeIndicator = "H" THEN  /* hexadecimal value */
            stemKey.iKey = X2C(tmp.keyiy)
       WHEN tmp.keyiy.typeIndicator = "A" THEN
            stemKey.iKey = tmp.keyiy
       WHEN tmp.keyiy.typeIndicator = "A0" THEN
            stemKey.iKey = tmp.keyiy || "00"x
       OTHERWISE             /* illegal data-type */
               RETURN
    END

    SELECT
       WHEN tmp.valuly.typeIndicator = "H" THEN  /* hexadecimal value */
            value = X2C(tmp.valuly)
       WHEN tmp.valuly.typeIndicator = "A" THEN
            value = tmp.valuly
       WHEN tmp.valuly.typeIndicator = "A0" THEN
            value = tmp.valuly || "00"x
       OTHERWISE             /* illegal data-type */
               RETURN
    END



    CALL SysIni origIniFile, stemTopLevel.iTop, stemKey.iKey, value     /* set new value */

    IF global.eTmp <> iTop THEN         /* was this Toplevel printed already ? */
    DO
       CALL check_value stemTopLevel.iTop
       SAY
       SAY global.iCyan || "Toplevel #" global.iYellow || iTop global.iCyan || "[" || strings.type || "] [" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iNormal
       global.eTmp = iTop
    END

    CALL check_value stemKey.iKey
    SAY global.iCyan || "        Key #" global.iYellow || iKey global.iCyan || "[" || strings.type || "] [" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iNormal


    RETURN




/*
   restores/updates from an INI-file
   if restore, then delete TopLevels and Keys in original which are not found in the backup
*/
INI_RESTORE_FROM_INI: PROCEDURE EXPOSE global.
    sourceFile = ARG(1)         /* backup-INI-file */
    targetFile = ARG(2)         
    switch     = ARG(3)         /* if "R", then delete superfluous TopLevels and Keys in the original */

    CALL SysIni sourceFile, 'ALL:', 'stemTopLevel'

    DO i = 1 TO stemTopLevel.0          /* cycle thru all TopLevels */
       DROP stemKey.
       stemKey. = ""

       CALL check_value stemTopLevel.i

       SAY
       SAY global.iCyan || "Toplevel #" global.iYellow || i global.iCyan || "of" global.iYellow || stemTopLevel.0,
           global.iCyan ||"[" || strings.type || "] [" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iNormal

       CALL SysIni sourceFile, stemTopLevel.i, 'ALL:', 'stemKey'

       DO j = 1 TO stemKey.0            /* cycle thru all Keys */
          CALL check_value stemKey.j

          SAY global.iCyan || "             Key #" global.iYellow || j global.iCyan || "of" global.iYellow || stemKey.0,
              global.iCyan ||"[" || strings.type || "] [" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iNormal

          value = SysIni(sourceFile, stemTopLevel.i, stemKey.j)         /* get value */
          tmp =   SysIni(targetFile, stemTopLevel.i, stemKey.j, value)  /* set value */
       END 

       IF switch = "R" THEN             /* restore mode, delete all keys not in backup */
          CALL delete_non_backedup_keys targetFile, stemTopLevel.i
    END

    IF switch = "R" THEN             /* restore mode, delete all targets not in backup */
       CALL delete_non_backedup_toplevels targetFile

    RETURN






/*
   for restore-mode only: delete keys in target which are not in backup
*/
DELETE_NON_BACKEDUP_KEYS: PROCEDURE EXPOSE stemKey. stemTargetKey. global.
   targetFile = ARG(1)
   TopLevel   = ARG(2)

   stemTargetKey. = ""

   CALL SysIni targetFile, TopLevel, "ALL:", "stemTargetKey"
   CALL sort_generic "stemKey", "EXACT"          /* sort backup-keys */
   CALL sort_generic "stemTargetKey", "EXACT"    /* sort target-keys */

   i = 1
   j = 1
   DO FOREVER                    /* delete keys, which cannot be found in the backup */
      SELECT
         WHEN stemKey.i << stemTargetKey.j THEN          /* delete superfluous keys */
              DO
                 IF i > stemKey.0 THEN
                 DO
                    DO k = j to stemTargetKey.0
                       SAY global.iCyan || "deleting key:" global.iYellow || stemTargetKey.k global.iNormal || global.iNormal
                       CALL SysIni targetFile, TopLevel, stemTargetKey.k, "DELETE:"
                       CALL log_deletions TopLevel, stemTargetKey.k
                    END
                    LEAVE
                 END
                 ELSE                   /* duplicate in bkp-keys, if so it comes from TXT-file */
                   i = i + 1
              END

         WHEN stemKey.i == stemTargetKey.j THEN          /* identical, o.k. */
              DO
                 i = i + 1
                 j = j + 1
                 IF j > stemTargetKey.0 THEN LEAVE       /* finished */
              END

         OTHERWISE /* stemKey.i >> stemTargetKey.j THEN  ... delete superfluous key */
              DO
                 SAY global.iCyan || "deleting key:" global.iYellow || stemTargetKey.j global.iNormal || global.iNormal

                 CALL SysIni targetFile, TopLevel, stemTargetKey.j, "DELETE:"
                 CALL log_deletions TopLevel, stemTargetKey.k
                 j = j + 1
              END
      END
   END
   RETURN


/*
   for restore-mode only: delete TopLevels in target which are not in backup
*/
DELETE_NON_BACKEDUP_TOPLEVELS: PROCEDURE EXPOSE stemTopLevel. global.
   targetFile = ARG(1)

   stemTargetTopLevel. = ""

   CALL SysIni targetFile, "ALL:", "stemTargetTopLevel"
   CALL sort_generic "stemTopLevel", "EXACT"          /* sort backup-TopLevels */
   CALL sort_generic "stemTargetTopLevel", "EXACT"    /* sort target-TopLevels */

   i = 1
   j = 1
   DO FOREVER                    /* delete TopLevels, which cannot be found in the backup */
      SELECT
         WHEN stemTopLevel.i << stemTargetTopLevel.j THEN          /* delete superfluos TopLevels */
              DO
                 IF i > stemTopLevel.0 THEN
                 DO
                    DO k = j TO stemTargetTopLevel.0
                       SAY global.iCyan || "deleting topLevel:" global.iYellow || stemTargetTopLevel.k || global.iNormal || global.iNormal
                       CALL SysIni targetFile, stemTargetTopLevel.k, "DELETE:"

                       CALL log_deletions TopLevel
                    END
                    LEAVE
                 END
                 ELSE                   /* duplicate in bkp-toplevels, if so it comes from TXT-file */
                   i = i + 1
              END

         WHEN stemTopLevel.i == stemTargetTopLevel.j THEN          /* identical, o.k. */
              DO
                 i = i + 1
                 j = j + 1
                 IF j > stemTargetTopLevel.0 THEN LEAVE       /* finished */
              END

         OTHERWISE /* stemTopLevel.i >> stemTargetTopLevel.j THEN  ... delete superfluous key */
              DO
                 SAY global.iCyan || "deleting topLevel:" global.iYellow || stemTargetTopLevel.j global.iNormal || global.iNormal
                 CALL SysIni targetFile, stemTargetTopLevel.j, "DELETE:"
                 CALL log_deletions TopLevel
                 j = j + 1
              END
      END
   END
   RETURN






/*
   check whether backup-file is a valid OS/2-INI-file, containing entries
*/
GETBKPDATA_INI: PROCEDURE EXPOSE global. bkpTopLevel.
   bkpIniFile = ARG(1)                  /* INI-file containing the backup-data */

   IF check_if_ini(bkpIniFile) < 0 THEN /* check whether INI-file */
   DO
      SAY global.iRedWhite || "***Error: Backup file [" || bkpIniFile || "] is not an OS/2-INI-file !" global.iNormal

      IF global.config.eLog THEN
         CALL log2file "***Error: not an OS/2-INI-file !***", "no-date"

      RETURN ""
   END

   century = SUBSTR(DATE("S"), 1, 2)    /* get century information */
   tmpDateTime = STREAM(bkpIniFile, "C", "QUERY DATETIME")

   /* make a sorted day from the American bound date-format  ! */
   PARSE VAR tmpDateTime month"-"day"-"year time
   tmpBkpDateTime = century || year || month || day time

   origIniFile = SysIni(bkpIniFile, global.config.showTopLevel, global.bkp.iOName)

   IF origIniFile <> "ERROR:" THEN      /* target must be in same directory as backup */
   DO
      origIniFile = global.iBackupMode.iDrive ||,
                    global.iBackupMode.iPath ||,
                    FILESPEC("name", origIniFile)
   END
   ELSE         /* backup was not created by this program, maybe a true copy */
   DO
      tmpFile  = FILESPEC("name", bkpIniFile)
      
      position = LASTPOS(".", tmpFile)                  /* get last dot in string */
      IF position < 1 THEN tmpTargetFile = tmpFile || ".INI"
                      ELSE tmpTargetFile = SUBSTR(tmpFile, 1, position) || "INI"

      origIniFile = global.iBackupMode.iDrive ||,
                    global.iBackupMode.iPath ||,
                    tmpTargetFile        /* put target INI in backup-directory */
   END


   tmpResult = STREAM(origIniFile, "C", "QUERY EXISTS") /* check whether INI-file exists */

   IF tmpResult = "" THEN                               /* not found */
   DO

      IF \global.eMultipleFiles THEN
      DO
         CALL BEEP 2000, 250
         SAY global.iCyan  "Target-INI-file:" global.iYellow || origIniFile global.iCyan || "not found!" || global.iNormal
         SAY
   
         tmp = global.iCyan || "Create it ?" global.yesHint
         global.eAnswer = 1                              /* default to yes */
         CALL CHAROUT , global.iNormal
   
         IF \get_yes_no(tmp, "global.eAnswer") | \global.eAnswer THEN 
         DO
            IF global.config.eLog THEN
               CALL log2file "Message: original INI-file does not exist, user aborted.", "no-date"

            CALL CHAROUT , global.iNormal
            EXIT -1      /* user aborted backup */
         END
      END

      IF global.config.eLog THEN
         CALL log2file "Message: original INI-file does not exist, will be created.", "no-date"
   END
   ELSE
      origIniFile = tmpResult


   tmpDateTime = STREAM(origIniFile, "C", "QUERY DATETIME")
 
   IF tmpDateTime <> '' THEN
   DO
       /* make a sorted day from the American bound date-format  ! */
       PARSE VAR tmpDateTime month"-"day"-"year time
       tmpOrigDateTime = century || year || month || day time
   END
   ELSE
      tmpOrigDateTime = RIGHT("-", 8) || "  " || RIGHT("-", 8)
 
   SAY global.iCyan || "Backup:   (" || global.iYellow || tmpBkpDateTime  || global.iCyan || ")" global.iYellow || bkpIniFile
   SAY global.iCyan || "Original: (" || global.iYellow || tmpOrigDateTime || global.iCyan || ")" global.iYellow || origIniFile || global.iNormal

   RETURN origIniFile


/*
        check whether file in hand is an INI-file
*/
CHECK_IF_INI: PROCEDURE EXPOSE bkpTopLevel. global.
    iniFile = ARG(1)
    /* not an OS/2-INI-file or empty ? */
    val = 0

    IF SysIni(iniFile, "ALL:", "bkpTopLevel") = "ERROR:" THEN val = -3
    ELSE
       IF bkpTopLevel.0 = 0 THEN val = -3

    IF val < 0 & \global.eMultipleFiles THEN    /* not an OS/2 INI-file */
    DO
       IF global.config.eLog THEN
           CALL log2file "***Error: not an OS/2-INI-file !***", "no-date"

       CALL BEEP 2000, 250
       SAY global.iYellow || iniFile || global.iCyan || ":" global.iRedWhite || "not an OS/2-INI-file !" || global.iNormal
       EXIT val
    END
 
    RETURN val


/*
        produce an OS/2-INI-backup-file
*/
MAKE_BACKUP: PROCEDURE EXPOSE global. bkpTopLevel.
   origIniFile = ARG(1)                 /* INI-file to be backed up */
   bkpIniFile = ARG(2)                  /* name of backup-INI-file */

   SAY
   SAY global.iCyan || "Source (OS/2-INI-file):" global.iYellow || origIniFile
   SAY global.iCyan || "Target (backup-file):  " global.iYellow || bkpIniFile || global.iNormal

   /* write information about backup-process and original file-name into INI-file */
   CALL SysIni bkpIniFile, global.config.showTopLevel, global.bkp.iOName, origIniFile
   CALL SysIni bkpIniFile, global.config.showTopLevel, global.bkp.iBName, bkpIniFile
   CALL SysIni bkpIniFile, global.config.showTopLevel, global.bkp.iDTimeStart, DATE("S") TIME()
   CALL SysIni bkpIniFile, global.config.showTopLevel, global.bkp.iTLentries, bkpTopLevel.0

   /* cycle thru TopLevel-entries */
   DO i = 1 TO bkpTopLevel.0               
      IF SysIni(origIniFile, bkpTopLevel.i, "ALL:", "keys") <> "ERROR:"        /* TopLevel not available anymore */
      THEN
      DO
          CALL check_value bkpTopLevel.i
   
          SAY
          SAY global.iCyan || "Toplevel #" global.iYellow || i global.iCyan || "of" global.iYellow || bkpTopLevel.0,
              global.iCyan ||"[" || strings.type || "] [" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iNormal

          DO j = 1 TO keys.0            /* cycle thru Key-entries */
             val = SysIni(origIniFile, bkpTopLevel.i, keys.j)
             IF val <> "ERROR:" THEN                                            /* key not available anymore */
             DO
                CALL check_value keys.j

                SAY global.iCyan || "             Key #" global.iYellow || j global.iCyan || "of" global.iYellow || Keys.0,
                    global.iCyan ||"[" || strings.type || "] [" || global.iYellow || strings.displayValue || global.iCyan || "]" global.iNormal

                CALL SysIni bkpIniFile, bkpTopLevel.i, keys.j, val
             END
             ELSE
                SAY global.iYellow || " ** error reading TopLevel #" global.iCyan || i || ", Key #" j || global.iNormal
          END
       END
       ELSE
          SAY global.iYellow || "*** error reading TopLevel #" global.iCyan || i || global.iNormal
   END

   CALL SysIni bkpIniFile, global.config.showTopLevel, global.bkp.iDTimeEnd, DATE("S") TIME()

   SAY global.iCyan || "finished backup." || global.iNormal
   RETURN
   





/*
        Backup-files contain at the last character position a number ranging
        from 0 (oldest) to 9 (youngest backup) == total of 10 generations

        ARG(1): filename with full path, e.g. "D:\OS2\OS2.INI" or "D:\OS2\OS2.TXT"
        ARG(2): number of maximum generations (1-10, expressed in filetype as 0-9)

*/
GET_NEXT_FILE: PROCEDURE EXPOSE global.
     file        = ARG(1)
     generations = ARG(2)

     testname    = SUBSTR(file, 1, LENGTH(file)-1)

     /* find number of backups already present */
     DO last_backup = 9 TO 0 BY -1
        new_name = testname || last_backup
        IF STREAM(new_name, "C", "QUERY EXISTS") <> "" THEN LEAVE       /* last backup found ! */
     END

     to_delete = (last_backup + 1) - generations 
     IF to_delete >= 0 THEN                                             /* erase superfluos backups */
     DO
        DO i = 0 TO to_delete
           ADDRESS CMD "@erase" '"' || testname || i || '" 2>nul'       /* erase oldest file */

           IF global.config.eLog THEN
              CALL log2file "Message:" generations "backup generation(s) only, therefore erasing superfluos [" || testname || i || "]", "no-date"
        END

        /* move youngest backups down */
        j = 0
        DO i = i TO last_backup
           old_name = testname || i
           new_name = testname || j
           ADDRESS CMD "@ren" '"' || old_name || '" "' || FILESPEC("Name",new_name) || '"'
           j = j + 1
        END
        new_name = testname || (generations - 1)
     END
     ELSE new_name = testname || (last_backup + 1)

     RETURN new_name


/*
        write log-entry to file
        ARG(1) ... text to write
        ARG(2) ... if present, supply date & time
*/
LOG2FILE: PROCEDURE EXPOSE global.
   IF ARG() = 1 THEN tmp = DATE("S") TIME() ARG(1)
                ELSE IF ARG(2) = "no-indention" THEN tmp = ARG(1)
                ELSE tmp = RIGHT("", 17) ARG(1)         /* indent */

   CALL LINEOUT global.eLogFile, tmp
   RETURN

/*
        log deletions of keys or of toplevels
*/
LOG_DELETIONS: PROCEDURE EXPOSE global.
   IF \global.config.eLog THEN RETURN

   TopLevel = ARG(1)
   KeyName  = ARG(2)

   CALL check_value TopLevel
   CALL log2file "Message: Deleting Toplevel [" || strings.type || "] [" || strings.displayValue || "],", "no-date"

   tmp = "                  "

   IF KeyName = "" THEN         /* all keys were deleted */
   DO
      tmp = tmp || "all KEYS of this Toplevel were deleted !"
   END
   ELSE
   DO
      CALL check_value KeyName
      tmp = tmp || "     Key [" || strings.type || "] [" || strings.displayValue || "]."
   END

   CALL log2file tmp, "no-date"

   RETURN


USAGE:
   SAY "SHOWINI: allow to view, edit, print, backup, restore OS/2-INI-files"
   SAY
   SAY "showini        ... allow to work interactively"
   SAY
   SAY "showini /switch[generations]  {filename | /modifier}  ... batch-mode execution"
   SAY '    switch:    B[T]   ... make a BACKUP of an OS/2-INI-file'
   SAY '               U[T]   ... UPDATE original OS/2-INI using a backup'
   SAY '               R[T]   ... RESTORE original OS/2-INI using a backup, i.e. delete'
   SAY '                          keys not found in backup'
   SAY '                 T    ... backup is a text-file (i.e. ASCII-file)'
   SAY '    generations: a number between 1-10, indicating how many backup-files you'
   SAY '                 want, respectively, which backup you wish to use'
   SAY '    filename: filename of OS/2-INI-file or the filename of the backup'
   SAY '    modifier: look for all OS/2-INI-files on the filesystem[s]:'
   SAY '              L[OCAL]  ... only LOCAL filesystems are scanned'
   SAY '              R[EMOTE] ... only REMOTE filesystems are scanned'
   SAY '              A[LL] ...... both, LOCAL and REMOTE filesystems are scanned'
   SAY '              D[RIVES]:letters ... only the given driveletters are scanned,'
   SAY '                                   where letters is e.g. ACDEH'
   SAY '              process OS/2-system INI-files:'
   SAY '              S[YSTEM] ... "OS2SYS.INI" only'
   SAY '              U[SER] ..... "OS2.INI" only'
   CALL CHAROUT , '              B[OTH] ..... both, "OS2SYS.INI" and "OS2.INI"'


   EXIT 0

ERROR:        
   myrc = RC
   SAY 'SHOWINI.CMD: error occurred !'
   SAY
   SAY 'REXX error' myrc 'in line' SIGL':' ERRORTEXT(myrc)
   SAY Substr('     ',1,6-Length(SIGL))(SIGL)' *-*   'Sourceline(sigl)
   SAY
   SAY 'Please contact the author with a description of the error.'

   EXIT -99
