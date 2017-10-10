/* ESFS            CMD by Gord Snider  2011/02/14  v01.09.00  2017/01/30     */
/* PURPOSE: By default, using the SysFileSearch() function, searches line by
line for the string entered as the first argument, in the single filename
entered as the second argument.

    SYNTAX:   ESFS string,filename[,'CN'] [/S] [/1]
        or    ESFS /?

     WHERE:
The script name, ESFS, (Extended SysFileSearch) is
followed by a single space,
followed by the string to search for (including leading and trailing spaces, if
      they are part of the search string), NOT IN QUOTES (unless the quotes
      are part of the search string),
      the string is taken literally, CASE INSENSITIVE by default, and
      searched for;
followed by a comma, with no surrounding spaces, as shown;
followed by the filename (or mask) of the file(s) to search;
followed, optionally, by a comma, with no surrounding spaces
      and any combination of 'C'  and/or  'N'.

filename   may be a single fn.ft if it is in the current directory.  If not
      in the current directory the filename must be qualified enough to be
      found.
      To specify searching ALL files in a directory specify  *  (asterisk) as
      the filename.
      A mask may also be used to specify a subset of files in one directory.

If the string is found the line containing the string is output to the screen
preceded by a vertical bar, '|', in column zero of the output line.  If the
line number has been asked for it will appear to the left of the vertical bar.

The third (optional) argument is any combination of the following characters:
C     conducts a case-sensitive search
N     returns file line numbers of the found string

   OPTIONS:
/?    switch that shows this help screen, and exits
/1    switch that shows a column scale line in each file to enable
      easily finding character columns in the output
/S    switch that turns on search into subdirectories of the tree which has
      the current (or specified) directory as the root

NOTE: This script assumes that RexxUtil.DLL has already been loaded.
NOTE: This script uses RexxUtil.DLL so it is likely to work only on OS/2
      compatible systems.
NOTE: This script uses my Rexx External function _color().
NOTE  This script uses my Rexx External function _scale().
NOTE: The natural scope of the SysFileSearch() function is one (named) file.
      This script can, using SysFileTree(), optionally, extend the scope to
      all the files in one named directory, or all the files in a whole tree
      branch from one (named) directory, or all the files covered by a
      filename mask.
*/

/* opts     as of 2013/10/25 */
parse arg . '/'switches +0                            /* split off any switches from the rest */
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

parse arg arguments '/' .                                        /* Capture the arguments */
parse var arguments string ',' sft_filespec ',' sfs_opts   /* Capture the search string */
if string = '' then do
      say 'First argument of string to search for not specified.'
      exit
      end
if sft_filespec = '' then do
      say 'Second argument of file spec or mask not specified.'
      exit
      end

sfs_opts = Translate(sfs_opts)

if Pos( 'N', Translate( sfs_opts)) > 0 then                /* Allow for line number field */
      x = 9                                                /* Set beginning column of scale */
   else x = 3

if opt.S then                                              /* Turn on full tree 'recursive' search ... */
      S = 'S'                                              /* in SysFileTree */
   else S = ''

scrn_lines = 2                                             /* Count Screen lines used */

cum_hits = 0                                               /* Flag for cumulative hits. */

call SysFileTree sft_filespec, 'sfs_filespec.', 'FO'S      /* Gather ONLY FQFNs of all files to be searched. */
                                                           /* Can be fn.ft, *, path, mask. */
if sfs_filespec.0 = 0 then
      say 'No files to search.'

do ii = 1 to sfs_filespec.0                                /* For each filename found to be searched ... */

   fqfn = Stream( sfs_filespec.ii, 'C', 'QUERY EXISTS')    /* fully qualify the filename to be searched and ... */

   call SysFileSearch string,sfs_filespec.ii,'line_hit.',sfs_opts     /* search each FQFN file for string hits ... */

   if line_hit.0 > 0 then do                               /* if any, output fqfn for file... */
         dr_path = FileSpec( 'D', sfs_filespec.ii) || FileSpec( 'P', sfs_filespec.ii)
         say
         say _color( fqfn, green)
         scrn_lines = scrn_lines + 2                       /* add 2 lines here. */
         cum_hits = max( cum_hits, 1)
         if opt.1 then do                                  /* show a column scale */
               call _scale x
               scrn_lines = scrn_lines + 1                 /* add 1 line here */
         end
   end   /* if line_hit.0 */

   do jj = 1 to line_hit.0                                 /* list each line_hit with its ... */
      if pos( 'N', sfs_opts) > 0 then do                   /* line number, if it has been called for ... */
            parse var line_hit.jj ln_num line_hit.jj
            ln_num = right( ln_num, 6)
            end
         else ln_num = ''
      parse var sfs_filespec.jj (dr_path) fn

      say ln_num '|' || line_hit.jj                        /* and show hit. */

      scrn_lines = scrn_lines + 1                          /* add 1 line here */
      if scrn_lines / (rows - 4) > 1 then do               /* check for window full */
            say _color( "<Enter> to continue ...", mga)
            pull .
            scrn_lines = 3                                 /* add 3 lines here */
      end   /* if pos() */
   end jj
end ii

if cum_hits = 0 then say 'No hits found.'

exit 0
