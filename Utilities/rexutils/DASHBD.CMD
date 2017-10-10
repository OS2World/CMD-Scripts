/* DASHBD          CMD by Gord Snider  0000/00/00  v00.01.00  2010/10/28     */
/* PURPOSE: Shows coloured lights like an instrument panel on a dashboard.

    SYNTAX: DASHBD
        or  DASHBD /?

   OPTIONS:
/?  shows a help screen and exits.

NOTE: This cmd takes about 10 seconds to run each time it is executed.
NOTE: This cmd assumes that RexxUtil DLL has already been loaded.
NOTE: Because of RexxUtil use this cmd is likely to run only on OS/2 compatible
      systems.
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
      end ll                                               /* end of list-a-help-line loop */
      exit 0
end   /* help */

do i = 1 to 5
   call SysCls
   a = word( red grn ylw blu mga cyn wht blk, random( 1, 8))
   b = word( red grn ylw blu mga cyn wht blk, random( 1, 8))
   c = word( red grn ylw blu mga cyn wht blk, random( 1, 8))
   d = word( red grn ylw blu mga cyn wht blk, random( 1, 8))

   do 5
      say
   end

   say '         ' d2c( 201) || copies( d2c( 205), 30) || d2c( 187)       /* …ÕÕÕª */
   say '         ' d2c( 186) || copies(       ' ', 30) || d2c( 186)
   do 2
      say '         ' d2c( 186) ' ',
          _color( d2c( 219) || d2c( 219),a) '   ' _color( d2c( 219) || d2c( 219),b) '   ',
          _color( d2c( 219) || d2c( 219),c) '   ' _color( d2c( 219) || d2c( 219),d) ,
                 '  ' d2c( 186)
   end
      say '         ' d2c( 186) ' Gas    Oil    Doors  Trunk '  d2c( 186)
   say '         ' d2c( 186) || copies(       ' ', 30) || d2c( 186)
   say '         ' d2c( 200) || copies( d2c( 205), 30) || d2c( 188)       /* »ÕÕÕº */
   call SysSleep 2
end i

exit 0
