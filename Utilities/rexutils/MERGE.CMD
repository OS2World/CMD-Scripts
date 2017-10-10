/* MERGE           CMD by Gord Snider  0000/00/00  v01.07.00  2007/07/04     */
/* PURPOSE: To combine two preordered (sorted) ASCII text files with identical
record layouts and fixed length fields, into one ordered file.  The input
files must be ordered on the same key field(s). The default merge is ascending
keys, case sensitive which may be changed per key field at the time of key
specification.

    SYNTAX: MERGE [/?]

Optional switch:
/?   shows this help screen and exits.

The script will ask for:
1. the name of the merged output file.
2. the description of the key, (as described below).
3. the name of input file 1, which must be sorted on the key field(s);
4. the name of input file 2, which must be sorted on the key field(s).

Key Description
The key field(s) must be at the same location in both input files.
Enter the key fields thus, with commas between the entries, (and a semicolon
between the key fields, if more than one field).
1. the first column of the key field,
2, the first column of the next field,
3. 'a' for an ascending key or 'd' for descending key,
4. 's' for case sensitive key or 'i' for case insensitive key.

The fully qualified name of the output file must NOT be the same as
the fully qualified name of either input file.

To have a properly merged output file you must merge on the same set of fields
you sorted the inputs on.

NOTE: This script assumes that RexxUtil.DLL has already been loaded.
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

parse arg myargs '/'switches +0

trace ?i
say	
say 'What is to be the fully-qualified name of the merged output file?'
parse pull file.0
if Stream( file.0, 'C', 'QUERY EXISTS') = '' then do       /* Output file does not exist ... */
   call Stream file.0, 'C', 'OPEN WRITE'                   /* so create it ... */
   say Stream( file.0, 'C', 'QUERY EXISTS') result         /* and announce the fact. */
   end
else do                                                    /* output file already exists */
   say 'File' file.0 'already exists.'
   exit
   end

say
say 'What is the key?  col1,col2,a|d,i|s[;col3,col4,a|d,i|s[...]]'
parse upper pull 1 keyarg1

say
do i = 1 to 2
   say 'What is the name of input file' i 'to merge?'
   parse pull file.i
   if Stream( file.i, 'C', 'OPEN READ') = 'READY:' then
      say Stream( file.i, 'C', 'QUERY EXISTS') result
   else do
      say 'Problem opening' file.i '   RC =' result
      exit
      end
say
end i

/* This loop executes once per output record while both input files have records remaining , and a
record will be taken only from one input file, per loop.  When all the records have been used from
one file then this loop will complete and all the remaining records from the other file will be used. */
/* Do the grossest comparison first, i.e. is there a record from each file to be compared? */

do while Lines( file.1) & Lines( file.2)                   /* Do while there are more input records */
                                                           /* in both input files.   */
   /* At this point records must remain in BOTH input files.  'Pre-read' a record from each file.  */
   spot1 = Stream( file.1, 'C', 'SEEK +0')                 /* Save the current read position of file.1. */
   line1 = LineIn( file.1)                                 /* Pre-read record from file.1 for testing key(s). */
   call    Stream  file.1, 'C', 'SEEK ='spot1              /* Reset read position to beginning of record. */

   spot2 = Stream( file.2, 'C', 'SEEK +0')                 /* Save the current read position of file.2. */
   line2 = LineIn( file.2)                                 /* Pre-read record from file.2 for testing key(s). */
   call    Stream  file.2, 'C', 'SEEK ='spot2              /* Reset read position to beginning of record. */

   /* The keys must be compared to see which input record to put in the output next. */
   /* Starting with the major key, check as many key fields as necessary to make the decision. */
   keyarg = keyarg1                                        /* Refresh the keys for each comparison */
   do while length( keyarg) > 0
      parse var keyarg keycol1 ',' keycol2 ',' ad ',' si ';' keyarg

      if si = 'I' then do                                  /* Case insensitive. */
         parse upper var line1 =(keycol1) key1 =(keycol2)  /* Get next key field of record in file.1 */
         parse upper var line2 =(keycol1) key2 =(keycol2)  /* Get next key field of record in file.2 */
      end
      else do                                              /* Case sensitive. */
         parse       var line1 =(keycol1) key1 =(keycol2)
         parse       var line2 =(keycol1) key2 =(keycol2)
      end

      /* Now check this key field to see if the tie is broken. */
      if ad = 'D' then                                     /* Keys descending. */
         if key1 > key2 then                               /* Compare the keys. */
            call LineOut file.0, LineIn( file.1)           /* Feed the output the next record from file 1 */
         else if key1 < key2 then
            call LineOut file.0, LineIn( file.2)           /* Take record with higher key. */
         else if length( keyarg) > 0 then                  /* This key has not broken the tie. */
            iterate                                        /* Check the next key field. */
         else call LineOut file.0, LineIn( file.1)         /* It's a tie!  Arbitrary choice. */
      else                                                 /* Keys ascending. */
         if key1 < key2 then                               /* Compare the keys. */
            call LineOut file.0, LineIn( file.1)           /* Feed the output the next record from file 1 */
         else if key1 > key2 then
            call LineOut file.0, LineIn( file.2)           /* Take record with lower key. */
         else if length( keyarg) > 0 then                  /* This key has not broken the tie. */
            iterate                                        /* Another key field? */
         else call LineOut file.0, LineIn( file.1)         /* It's a tie!  Arbitrary choice. */

      leave                                                /* Keys exhausted, record chosen */
   end  /* do while length( keyarg) > 0 */
end   /* do while records */

do while Lines( file.1)
   call LineOut file.0, LineIn( file.1)                    /* take the remaining records from file.1. */
end

do while Lines( file.2)
   call LineOut file.0, LineIn( file.2)                    /* take the remaining records from file.2. */
end

call Stream file.0, 'C', 'CLOSE'
call Stream file.1, 'C', 'CLOSE'
call Stream file.2, 'C', 'CLOSE'

exit 0
