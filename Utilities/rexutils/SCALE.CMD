/* SCALE           CMD by Gord Snider  2016/05/13  v00.05.00  2016/10/27     */
/* PURPOSE: By default draws a column scale across a command line window on
the same line as the prompt, after erasing the prompt.  This may be varied by
arguments to set the beginning column of the scale and/or the length of the
scale.  The arguments are separated by a comma.

    SYNTAX: SCALE [[start],length]
        or  SCALE /?

     WHERE:
start    is an optional positive integer to set the beginning column of the
         scale.
length   is an optional positive integer to set the length of the scale (to
         less than the default length).
There MUST be a comma between start and length and if length is used alone
it must have a leading comma.

   OPTIONS:
/?  optional switch to show a small help screen and then exit.

Default action is for the command to draw a column scale across the window,
starting in column 1.  The starting integer, if used, specifies a beginning
column other than 1.  The length integer specifies how long the scale will be
(less than the default length).  So this cmd can take zero, one (either one),
or two arguments.

NOTE: This script assumes that RexxUtil DLL has already been loaded.
NOTE: This script uses extended RexxUtil features that make it likely to work
      only on OS/2-compatible systems.
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

/* Next lines overwrite the prompt line to prepare that line for the scale. */

PARSE VALUE SysTextScreenSize() WITH . cols                /* Find window size. */
PARSE VALUE SysCurPos() WITH row col                       /* Find cursor pos, (line below prompt). */
PARSE VALUE SysCurPos( row - 1, 0) WITH row1 col1         /* Set cursor pos for new scale. */
prompt_line = SysTextScreenRead( row - 1, 0, cols - 2)    /* Read what's on current line. */
CALL CharOut "STDOUT", "0D"x Copies( "20"x, Length( prompt_line) - 1) "0D"x    /* Overwrite current. */

PARSE ARG arguments "/" . +0                               /* Split off option, if present. */
PARSE VAR arguments start","length

IF start  = "" | start  < 1 | start  > cols - 2 THEN  start = 1          /* Default scale start column */
IF length = "" | length < 1 | length > cols - 2 THEN length = cols - 2   /* Default scale length */

/* No going beyond window width. */
IF start + length > cols - 2 THEN length = cols - start - 1

/* Set the scale starting column, if not 1. */
CALL CharOut "STDOUT", Copies( " ", start - 1)

/* Set number of times to issue 10 block. */
DO i2 = 1 FOR (length % 10)
   CALL CharOut "STDOUT", "----+----"Right( i2, 1)         /* Draw most of the scale. */
END i2

/* Fill in final characters */
CALL CharOut "STDOUT", substr( "----+----" , 1, length // 10)

EXIT 0
