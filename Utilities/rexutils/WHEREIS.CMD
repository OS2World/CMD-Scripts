/* WHEREIS         CMD by Gord Snider  0000/00/00  v01.15.00  2016/12/27     */
/* PURPOSE: Default action is to find all files, on all local drives, matching
a file name or mask.  This action may be varied by switches.

    SYNTAX:  WHEREIS name [options]
        or   WHEREIS /?

     WHERE:
name   is the required name, or mask, of the file(s) to find.

   OPTIONS:
/?     shows a help screen and then exits
/A     suppresses output of the attributes, size, date and time
/D     turns it into a search for a named directory or directories
/Lx    list of drives to search as drive letter, colon, space; e.g.  C: D:
/S     includes search of the otherwise excluded S: (CD/DVD) drive
/x     x is a drive letter from the list of excluded drives in the
       CUSTOMIZATION section below.  Use of this drive letter
       includes search of the otherwise excluded x: drive per the list of
       excluded drives in the CUSTOMIZATION section below
/1     adds a column scale at the end

The '*' and '+' wildcards are allowed by SysFileTree.  The search is local-
system wide, i.e. on all local drives (except for the S:, P:, J: and K:
drives: On my system, by default, search on S: is skipped because it is the
CD drive, and P: is the total backup of my old system , J: and K: are skipped
because they are the new backup drives but you can include them in the search
with switches).

NOTE: This script has a CUSTOMIZATION section, below, that must be updated to
      suit your system BEFORE its first use.
NOTE: This script uses my REXX External function _scale().
NOTE: This script assumes that RexxUtil.DLL has already been loaded.
NOTE: Because this script uses RexxUtil.DLL it is likely to run only on OS/2
      compatible systems.
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

PARSE ARG name '/' . +0                                    /* Name of file to find */

map = SysDriveMap( , 'LOCAL')                              /* Scope of map is of all local drives */

IF SysDriveInfo( 'A:') ª= '' THEN                          /* Is Drive A: available? */
      map = 'A: '||map

/* ***********   CUSTOMIZATION   ********** */
/* List of drives NOT to search on YOUR hard drive. */
IF \(opt.J) & Wordpos( 'J:', map) > 0 THEN map = Delword( map, Wordpos( 'J:', map), 1)
IF \(opt.K) & Wordpos( 'K:', map) > 0 THEN map = Delword( map, Wordpos( 'K:', map), 1)
IF \(opt.P) & Wordpos( 'P:', map) > 0 THEN map = Delword( map, Wordpos( 'P:', map), 1)
IF \(opt.S) & Wordpos( 'S:', map) > 0 THEN map = Delword( map, Wordpos( 'S:', map), 1)
IF \(opt.V) & Wordpos( 'V:', map) > 0 THEN map = Delword( map, Wordpos( 'V:', map), 1)
IF \(opt.W) & Wordpos( 'W:', map) > 0 THEN map = Delword( map, Wordpos( 'W:', map), 1)
IF \(opt.X) & Wordpos( 'X:', map) > 0 THEN map = Delword( map, Wordpos( 'X:', map), 1)
IF \(opt.Y) & Wordpos( 'Y:', map) > 0 THEN map = Delword( map, Wordpos( 'Y:', map), 1)
/* **************************************** */

IF opt.L THEN map = mod.L                                  /* Specified drive list overrides all. */

IF opt.D THEN DO
      obj = 'D'                                            /* Search for directories instead of files */
      target = 'directories'
   END
   ELSE DO
      obj = 'F'                                            /* Search for files */
      target = 'files'
END

SAY
SAY 'Map =' map
SAY 'Scanning map drives for' target '=' name
SAY
lines = 4                                                  /* Window lines already used. */

DO ii = 1 TO Words( map)                                   /* Loop once for each drive. */
   drive = Word( map, ii)                                  /* Pick the next drive. */
   IF SysDriveInfo( drive) = '' THEN DO                    /* If this drive is not ready ... */
         CALL CharOut 'STDOUT', Left( 'Drive' drive 'not ready.', 78) '0D'x
         CALL SysSleep 3
         ITERATE ii                                        /* Try the next drive. */
   END  /* if SysDriveInfo() */

   CALL CharOut 'STDOUT', Left( 'Scanning drive:' drive , 78) '0D'x    /* Drive being scanned. */
   CALL CharOut 'STDOUT', Left( ' ', 78) '0D'x             /* Prepare for hit.1 on new drive. */

   CALL SysFileTree drive'\'name, 'hit.', obj'SL'          /* Search for matching files/drives. */

   DO jj = 1 TO hit.0                                      /* Loop through all the paths ... */
      PARSE VAR hit.jj . 41 fqfn                           /* Asking for attributes? */
      IF \(opt.A = 0) THEN
            SAY fqfn                                       /* Output hit to window. */
         ELSE
            SAY hit.jj
      lines = lines + 1

      IF opt.V THEN DO
            CALL Stream fqfn, 'C', 'OPEN READ'
            SAY '    ' LineIn( fqfn)
            lines = lines + 1
            CALL Stream fqfn, 'C', 'CLOSE'
      END
      IF lines > (rows - 2) THEN DO                        /* Window full? */
            CALL CharOut 'STDOUT', Left( '<Enter> to continue ...', 78) '0D'x
            CALL SysGetKey( 'NOECHO')
            SAY
            lines = 1                                      /* Was 1 */
      end   /* if lines // */
   end jj

   IF hit.0 > 0 THEN DO
         SAY
         lines = lines + 1
         END
   DROP hit.
END ii                                                     /* Drives in map. */

CALL CharOut 'STDOUT', copies( ' ', 78) '0D'x
IF opt.1 THEN CALL _scale

EXIT 0
