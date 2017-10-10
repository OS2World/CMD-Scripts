/* DUPSGONE        CMD by Gord Snider  2008/08/20  v03.01.00  2016/08/23     */
/* PURPOSE:  To clean out of a "target" folder duplicate files that also exist
in current folder. To be considered for deletion, by default, files must
be the same in name, size, date and time. This action may be varied with
optional switches.

    SYNTAX:  DUPSGONE  target_folder [/L] [/S] [/V]
        or   DUPSGONE /?

target_folder is the path to the folder from which files will be deleted.
/?   displays this help screen and exits;
/L   "LOOSE" compare, i.e. only the filename needs to match;
/S   search includes SUBDIRECTORIES;
/V   requires a user VERIFY for deletion of EACH deletable file.

This CMD is used when, in the "target" folder, there are non-matching files
that you want to keep, and so can't just "DEL *" them.
DUPSGONE uses a "reference" folder i.e. the current folder, and a "target"
folder, as specified on the command line.  Any file found in both the
"reference" folder and the "target" folder will be deleted from the "target"
folder.

NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
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

IF opt.S THEN S = "S"                                      /* Include subdirectories SysFileTree option. */
   ELSE S = ""

dir_ref = Directory()                                      /* We will come back here at the end. */
SAY "The REFERENCE FOLDER (i.e. the current folder) is:" dir_ref     /* REFERENCE FOLDER */

PARSE ARG targ "/" . +0                                    /* Get TARGET FOLDER */

dir_tgt = Directory( targ)                                 /* TARGET FOLDER Existence check & expand to FQP */
IF dir_tgt = "" THEN DO
      SAY "TARGET FOLDER" targ "not found."
      EXIT
      END
   ELSE SAY "The TARGET    FOLDER (i.e. the specified folder) is:" dir_tgt     /* TARGET FOLDER */
dir_ref = Directory( dir_ref)                              /* Return to current directory */

SAY
dir_ref = Strip( dir_ref, "T", "\")||"\"                   /* Add missing backslash for SysFileTree. */

CALL SysFileTree dir_ref||"*", "files_r.", "F"S            /* To get TOTAL number of files in REFERENCE FOLDER. */

SAY files_r.0 "Files in REFERENCE FOLDER" dir_ref          /* Number of files in REFERENCE FOLDER. */

dir_tgt = Strip( dir_tgt, "T", "\")||"\"                   /* Add missing backslash for SysFileTree. */

CALL SysFileTree dir_tgt||"*", "files_t.", "F"S            /* To get TOTAL number of files in TARGET directory. */

SAY files_t.0 "files in TARGET    FOLDER" dir_tgt          /* Number of files in TARGET    directory. */

SAY
IF Translate( dir_ref) = Translate( dir_tgt) THEN DO       /* Check for 'path equality' error. */
      SAY "Reference folder = Target folder."
      EXIT
END

/* Now check tgt names against ref names for matches */
hits = 0                                                   /* number of file matches */
DO i2 = 1 to files_t.0
   PARSE VAR files_t.i2 1 tdata 29 . (dir_tgt) tfqfn +0 (dir_tgt) tfn  /* Get tgt file's data, FQFN -> tdata tfn */
   CALL SysFileTree dir_ref|| tfn, "hit.", "F"
   IF hit.0 = 1 THEN DO
         PARSE VAR hit.1 1 rdata 29 .
         IF opt.L | rdata = tdata THEN hits = hits + hit.0
         END
END i2
SAY hits "matches between REFERENCE and TARGET."
DROP hit.

SAY
SAY "ALL OK?   'Y' to continue, anything else to EXIT"
ans = Translate( SysGetKey( "NOECHO"))
IF ans \= "Y" THEN EXIT
SAY

/* At this point you have the FQFNs of TARGET in an array, files. */
/* ************************************************************************************************
* Now loop with each filename in the TARGET folder by parsing off the filename from the           *
* TARGET FQFN and adding the TARGET filename to the REFERENCE path.                               *
* Query that newly built filename (and data) in REFERENCE folder with SysFileTree().              *
************************************************************************************************ */
xx = 0                                                     /* Number of deleted files. */
yy = 0                                                     /* Number of ineligible files. */
zz = 0                                                     /* Number of declined files. */

IF opt.V THEN SAY "Matches are:"

DO i3 = 1 TO files_t.0                                       /* Loop thru TARGET drive array. */
   PARSE VAR files_t.i3 1 tdata 29 . (dir_tgt) tfqfn +0 (dir_tgt) tfn  /* Get tgt file's data, FQFN -> tdata tfn */
   CALL SysFileTree dir_ref || tfn, "hit.", "F"            /* Query ref folder for tgt filename. */
   IF hit.0 = 1 THEN DO                                    /* Is a matching filename in ref folder? */
         PARSE VAR hit.1 1 rdata 29 . 38 rfqfn             /* Get ref file's data and FQFN -> rdata rfqfn */
         IF rdata == tdata | opt.L THEN DO                 /* Eligible for deletion. */
               IF opt.V THEN DO                            /* The verify option is set. */
                     SAY
                     SAY "Ref" rdata rfqfn
                     SAY "Tgt" tdata tfqfn
                     SAY "Press '-' to delete:" tfqfn
                     IF SysGetKey("NoEcho") \= "-" THEN DO /* Deletion permission granted? */
                           zz = zz + 1
                           SAY zz". Deletion declined."
                           ITERATE i3
                           END     /* if SysGetKey() then do ... */
                     END       /* if opt.V THEN DO */
                  ELSE yy = yy + 1     /* rdata \== tdata */  /* ELSE opt.V  */
               CALL SysFileTree tfqfn, "stem.", "F","*****","-*---"   /* Prepare for deletion. */

               IF SysFileDelete( tfqfn) = 0 THEN DO
                     xx = xx + 1
                     SAY xx". Deleted ->" tfqfn
                     END
                  ELSE SAY "Deletion failed ->" tfqfn
            END   /* if rdata == tdata  then do */
   END   /* if hit.0 = 1 then  do */
END i3

SAY
SAY xx "files deleted."
IF opt.V THEN SAY zz "file deletions declined."

EXIT 0
