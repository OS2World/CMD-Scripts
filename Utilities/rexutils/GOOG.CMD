/* GOOG            CMD by Gord Snider  0000/00/00  v01.10.00  2017/01/02     */
/* PURPOSE: To produce the names of files containing specified text strings.
The files selected are determined by a Boolean expression relating the text
strings, and the files' names are stored in a file.

    SYNTAX:
 GOOG "[op] 'string1'[ op 'string2'[ ...]]"  [/T.xxx [...]] [/Dz:xx] [/S] [/A]

of which only string1 is required.  The rest, up to 6 strings, and the options,
may be used as needed.  The default search area is all available local drives.

Single quotes MUST surround each string to be searched for, as shown, even if
there is only one string.

Double quotes MUST surround the WHOLE Boolean expression, as shown, even if
there is only one string in the expression.

Each string is a literal string, CASE SENSITIVE, surrounded by required single
quotes, that is to be searched for in each file.

'op' is a REXX Boolean operator,
| = OR,    & = AND,    && = EXCLUSIVE OR .
\ = NOT, may precede a string to flip TRUE to FALSE, or FALSE to TRUE,
before a leading single quote, or before a left parenthesis.
Parentheses may be used to group strings around an operator(s).

   OPTIONS:
/T  restricts the search to list of 1 or more filetypes to be searched, each of
    which is preceded by a dot and followed by a space, e.g.
    /T.doc .txt .msg
/D  restricts the search to a vol:\directory specification to be used as a
    one-directory-branch search startpoint, e.g.
    /DD:\PMMail
/S  also sends the output (filenames) to the screen.
/A  searches files of all sizes, overriding the default 70 MB file size limit.

   EXAMPLE:  To find emails, in PMMail accounts, that have these strings,
   'Christmas present' and 'Shetland pony', but not 'Santa Claus'
   use the following (all on one line)
   GOOG "'Christmas present' & 'Shetland pony' & \'Santa Claus'"
   /T.msg  /DD:\PMMail


NOTE: This cmd MUST run under Classic Rexx.  It runs out of resources under
      Object Rexx.
NOTE: This cmd has a CUSTOMIZATION SECTION below which MUST be updated to
      suit YOUR system BEFORE the first execution.
NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
NOTE: This cmd requires my Rexx External Function _commas()
NOTE: Because this cmd uses RexxUtil.DLL it is likely to run only on OS/2
      compatible systems.
*/


parse value date('S')time() with . =7 p1':'p2':'p3
/* **********   CUSTOMIZATION   ********** */
opf  =  "G:\googs\G" || p1 || p2 || p3                /* FQN of YOUR output file */
nosearch = 'H: P: S: V: W: X: Y:'                     /* List of drives NOT to search on YOUR system */
your_editor = "EPM.EXE"
/* *************************************** */

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

/* help     as of 2013/10/25 */
parse value SysTextScreenSize() with rows cols             /* used to check for window full */
opdel = '/'||'*'||'FF'x                                    /* This line needed by LN.CMD */
cldel = 'FF'x||'*'||'/'                                    /* This line needed by LN.CMD */
if opt.? then do                                           /* Help screen */
      do ll = 1 to sourceline() while left( sourceline( ll), 2) \= '*'||'/'    /* get next help line */
         sl = sourceline( ll)                              /* to shorten next REXX lines */
         if pos( cldel, sl) - pos( opdel, sl) = 7 then     /* both delims present, 7 chars apart */
               sl = delstr( sl, pos( opdel, sl) , 10)      /* remove line #, if any, anywhere in line */
         say strip( left( sl, cols - 1), 'T')              /* say the stripped help line */
         if (ll // (rows - 2)) = 0 & ,
            left( sourceline( ll + 1), 2) \= '*'||'/' then do
               say '<Enter> to continue ...'
               pull .
         end
      end ll                                               /* end of list a help line */
      exit 0
end   /* help */

time = time( 'E')
numeric digits 15

parse arg '"' myarg'"' .                                   /* Remove double quotes. */

if myarg = '' then do
      say 'No Search string specified.'
      exit
end

say

call Stream opf, 'C', 'OPEN WRITE'                         /* open output file */
if result = 'READY:' then
      say 'Output file is' opf
   else do
      say 'Problem opening oputput file' rc
      exit
end

if opt.T then do                                           /* get list of filetypes */
      types = mod.T
      say 'Searching for strings:' myarg 'in filetypes' types
      if opt.D then say 'on' mod.D
      end
   else do
      types = '*'
      say 'Searching for:' myarg
      end

s.   = ''                                                  /* s. = string stem */
o.   = ''                                                  /* o. = operator stem */
r.   = ''                                                  /* logical result stem */
hits = 0                                                   /* file hits */
b    = 0                                                   /* b = total # files searched */
c    = 0                                                   /* c = # bytes searched */
sz   = 0                                                   /* size of this file */
tsz  = 0                                                   /* total size of files searched */
max  = 0                                                   /* size of largest file yet */

/* o.0, if it exists, may be a \ or ( */
/* o.6, if it exists, may be a )      */

parse var myarg  o.0 "'"s.1"'" o.1 "'"s.2"'" o.2 "'"s.3"'" o.3 "'"s.4"'" o.4 "'"s.5"'" o.5 "'"s.6"'" o.6

vols = SysDriveMap( ,LOCAL)                                /* list of local drives to be searched */
if opt.D then do
      vols = left( mod.D, 2)                               /* optional vol:\directory specification */
      if pos( vols, SysDriveMap( ,LOCAL)) = 0 then do
            say 'Invalid drive specified.'
            exit
      end
end

do v = 1 to words( vols)                                   /* per disk volume (or directory) loop */
   vol = word( vols, v)                                    /* next volume */
   if pos( vol, nosearch) > 0 then iterate                 /* List of volumes NOT to be searched. */
   if pos( vol, vols) = 0 then iterate                     /* non-existent volume */
   say
   say 'Searching volume' vol
   hit = 0                                                 /* hits this volume */

   do t = 1 to words( types)                               /* per filetype loop */
      type = word( types, t)                               /* select next filetype */
      if type = '*' then type = ''

      if opt.D then vol = strip( mod.D, 'T')               /* vol:\directory specification */

      call SysFileTree vol'\*'type, 'files.', 'FS'         /* all files on volume with .FT */

      b = b + files.0                                      /* total of files searched */
      width = length( _commas( files.0))
      say 'Searching' _commas( files.0) type 'files.'

      do f = 1 to files.0                                  /* do for each file */
         parse var files.f . . sz . files.f .
         if \(opt.A) & (sz > 70000000) then iterate f      /* Skip files over 70,000,000 Bytes */
         tsz = tsz + sz                                    /* Total of bytes searched */
         if sz > max then do
               max = sz
               files.maxsz = files.f                       /* largest file yet read */
         end

         if time( 'E') - time > 5 then do                  /* 5 seconds later than last time */
             time = time( 'E')
             call CharOut 'STDOUT', copies( ' ', 78) '0D'x
             call CharOut 'STDOUT', 'Searching' right( _commas( f), width) '0D'x
             yup = 1                                       /* flag */
             end

         call Stream files.f, 'C', 'OPEN READ'             /* open the next file */

         file = CharIn( files.f, 1, Chars( files.f))       /* pull whole file into a variable */

         call Stream files.f, 'C', 'CLOSE'                 /* close the file */

         do j = 1 while s.j \= ''                          /* Do for each search string */
            r.j = pos( s.j, file) > 0                      /* Search for strings, save flag */
         end j

         interpret 'z =' o.0 r.1 o.1 r.2 o.2 r.3 o.3 r.4 o.4 r.5 o.5 r.6 o.6

         if z then do                                      /* if file is selected ... */
            call LineOut opf, files.f                      /* send file name to output disk file */
            if opt.S then say files.f                      /* also send to screen? */
            hits = hits + 1                                /* total number of files found */
            hit = hit + 1                                  /* files found on this volume */
         end
         drop file
      end f                                                /* end of per file processing */
   end t                                                   /* end of filetype processing */

   if yup = 1 then do                                      /* flag */
      call CharOut 'STDOUT', copies( ' ', 60) '0D'x        /* blank out the line */
      yup = 0                                              /* reset flag */
   end
end v                                                      /* go to next volume */

call Stream opf, 'C', 'CLOSE'                              /* close the output file */

time = trunc( time( 'E'))
say
say right( _commas( hit),9) 'files met the conditions.'
say 'Searched:' _commas( tsz) 'bytes, in' _commas( b) 'files, in' time % 60 'minutes' time // 60 'seconds.'
say 'Found' _commas( hits) 'files with search string' myarg'.'
say 'Largest file searched:  ' _commas( max) 'bytes  ' files.maxsz

say
say 'View the list?   Y/n'
pull resp
if resp = 'N' then exit                                    /* default is yes */

your_editor opf                                            /* Use your editor to open the list of files. */
/*
call Stream opf, 'C', 'OPEN READ'

do while Lines( opf)
   file = LineIn( opf)
   "EPM" file
   if SysGetKey('NOECHO') = '1B'x then exit                /* 'Esc' key exits from here. */
end

call Stream opf, 'C', 'CLOSE'
*/
exit 0
