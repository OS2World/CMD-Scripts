/* REMOTREE        CMD by Gord Snider  2013/06/24  v01.08.00  2015/03/07     */
/* PURPOSE: Default action is to show a whole branch of a tree based on the
(required) root subdirectory that you specify.  No other action is taken if no
switches are specified.  The root specified must be a direct, next-level child
directory of the current directory.  That is the branch that will be silently
removed if you specify the /E switch.  The directories and files will be shown,
as they are removed, if you also specify the /S switch.

    SYNTAX: REMOTREE root [/A]
        or  REMOTREE root [/E [/S] [/F]]
        or  REMOTREE /?

     WHERE:
root  is a required, next-level subdirectory of the current directory to
      be used as the base of the tree to be removed/shown.
/?    shows a help screen and exits.
/A    Not with /E.  Shows the ATTRIBUTES of the files that are shown.
/E    EXECUTE.  Deletes the files and removes the directories in the tree,
       including the specified root subdirectory.  No files are deleted in
       the current directory.
/S    SHOW.  Only with /E.  Shows the files and directories that are being
       removed.
/F    FILES.  Only with /E. Only FILES are deleted.  Directory structure is
       retained.

NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
NOTE: Because RexxUtil.DLL is used this is likely to work only with OS/2
      compatible systems.
NOTE: This cmd requires my Rexx External Function _color().
NOTE: Since the output line can be wider than 80 columns you may wish to enter
      a command, like MODE 132 40, first to preclude wrapping.
*/

/* opts     as of 2013/10/25 */
arg . '/'switches +0                                  /* split off the switches from the rest */
opt. = 0                                              /* unset options will be FALSE */
mod. = ''                                             /* unset option mods will be NULL */
do while pos( '/', switches) > 0                      /* each option must have leading slash */
   parse var switches '/'opt'/'switches +0            /* parse next option/modification set */
   parse upper var opt opt 2 mod                      /* split option from any modification */
   opt.opt = 1                                        /* capture option name, option value = TRUE */
   mod.opt = mod                                      /* capture option's modification, if any */
end   /* opts */

/* help     as of 2013/10/26 */
parse value SysTextScreenSize() with rows cols             /* used to check for window full */
opdel = '/'||'*'||'FF'x                                    /* This line needed by LN.CMD */
cldel = 'FF'x||'*'||'/'                                    /* This line needed by LN.CMD */
if opt.? then do                                           /* Help screen */
      do ll = 1 to sourceline() while left( sourceline( ll), 2) \= '*'||'/'    /* get next help line */
         sl = sourceline( ll)                              /* to shorten next REXX lines */
         if pos( cldel, sl) - pos( opdel, sl) = 7 then     /* both delims present, 7 chars apart */
               sl = delstr( sl, pos( opdel, sl) , 10)      /* remove line #, if any, anywhere in line */
         say strip( left( sl, cols - 1), 'T')              /* say the stripped help line */
         if (ll // (rows - 2)) = 0 & ,                     /* 2 lines short of full screen and */
            left( sourceline( ll + 1), 2) \= '*'||'/' then do  /* next line NOT end of comments */
               say '<Enter> to continue ...'
               pull .
         end
      end ll                                               /* end of list-a-help line loop */
      exit 0
end   /* help */

SAY                                                        /* Even before error msgs. */
lines = 1                                                  /* Initialize window lines as numeric. */

PARSE ARG root '/' . +0                                    /* Get the passed child root. */
root = STRIP( root, 'T')                                   /* For possible trailing space. */

IF root = '' THEN DO
      SAY 'Root not specified.'
      EXIT                                                 /* 'Lines' not needed in this case. */
END

curdir = Directory()                                       /* Because use of Directory() changes directory. */
IF Directory( STRIP( Directory(), 'T', '\')'\'root) = '' THEN DO  /* Verify passed root is child of current. */
      SAY 'Base of tree to be deleted not direct child or not found.'
      EXIT
      END
   ELSE root = Directory()                                 /* Set root to full path. */
CALL Directory curdir                                      /* Return to 'current directory'. */

IF opt.E THEN DO                                           /* Verify EXECUTion. */
      IF opt.F
         THEN SAY 'Remove only files from tree on root' root'.  Are you sure? y/N <Enter>'  /* <Enter> = NO = EXIT. */
         ELSE SAY 'Remove tree on root' root'.  Are you sure?  y/N <Enter>'                 /* <Enter> = NO = EXIT. */
      PULL ans
      IF ans = 'Y' THEN DO                                 /* I'm sure! */
            lines = lines + 1
            CALL scrfull
         END
         ELSE EXIT
END   /* if opt.E */


CALL next root       /* <==== Recursion Pivot Point */     /* Pass the root directory name. */

                                                           /* When done the whole branch come here. */
IF (\opt.E & \opt.S) | (opt.E & opt.S) THEN DO             /* None or both. */
      SAY _color('..' root, wht)                           /* Display final root. */
      CALL scrfull
END

IF opt.E & ª(opt.F) THEN DO
      CALL SysRmDir root                                   /* Remove 'root' directory here. */
      SAY
      IF RESULT > 0
         THEN SAY 'SysRmDir RC' RESULT 'on' root           /* Can't REMOVE root. */
         ELSE SAY 'Tree based on' root 'is gone.'
END   /* if opt.E & ªopt.F then */

IF opt.E & opt.F THEN SAY 'All files based on' root 'are gone.'

EXIT 0


NEXT: PROCEDURE EXPOSE opt. rows cols lines
PARSE ARG thisdir                                          /* Pick up this directory name */

CALL SysFileTree thisdir||'\'||'*', 'dir.', 'DO',, '-*---' /* List Subdirectories of this directory. */

DO dir = 1 TO dir.0                                        /* Loop through all subdirectories. */
                                                           /* - head recursion - */
   CALL next dir.dir    /* <======= Recursive */           /* Use lowest directory number left. */
                                                           /* - tail recursion - */
   IF (\opt.E & \opt.S) | (opt.E & opt.S) THEN DO          /* Show directory while executing. */
         SAY _color( '..' dir.dir, wht)
         CALL scrfull
   END

   IF opt.E & ª(opt.F) THEN DO
         CALL SysRmDir dir.dir                             /* Remove Directory. */
         IF RESULT > 0 THEN DO
               SAY 'SysRmDir RC' RESULT 'on' dir.dir
               EXIT
         END   /* if result > 0 */
   END    /* if opt.E & ªopt.F */
END dir

CALL SysFileTree thisdir||'\'||'*', 'file.', 'F',, '-*---' /* Work on current leaf directory files. */

DO file = 1 TO file.0

   PARSE VAR file.file data 38 file.file                   /* Parse out the file names and attributes. */

   IF (\opt.E & \opt.S) | (opt.E & opt.S) THEN DO          /* Show files. */
         IF opt.A THEN CALL CharOut , data
         CALL CharOut , file.file '0D0A'x
         CALL scrfull
   END

   IF opt.E THEN DO
         CALL ON ERROR
         CALL SysFileDelete file.file                      /* Delete Each filename in this directory. */
         CALL OFF ERROR
/*       IF RESULT > 0 THEN DO
               SAY 'SysFileDelete RC' RESULT 'on' file.file
               EXIT
         END        */
   END
END file
RETURN                                                     /* A Directory in previous level of directories. */


SCRFULL:
   lines = lines + 1
   IF lines / (rows - 2) > 1 THEN DO
         SAY '<Enter> to continue ...'
         PULL
         SAY                                               /* Blank line at top of screen. */
         lines = 1
      END   /* if lines  */
RETURN


ERROR:

RETURN
