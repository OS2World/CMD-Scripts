/* MCD             CMD by Gord Snider  2005/11/25  v02.20.01  2017/02/22     */
/* PURPOSE: To assist in CDing between levels in a directory tree.
Additional functions:
- assist in moving between between drives
- moving between any directories
- displaying the rest of the current directory tree
- displaying files in the current directory
- displaying a subdirectory
- creating and/or removing directories
- creating and/or deleting temporary files

    SYNTAX:  MCD [/?]

   OPTIONS:
/?          is an optional switch to show a simple help screen and exit.

MCD presents subdirectories of the current directory in a numbered menu and
then asks for an instruction.
An Instruction may be:
a number   from the menu, representing the associated subdirectory;
           That subdirectory will become the current directory, and the
           new display will be of that directory;
(null)     will go to the next screenfull of subdirectories, if any, or
           at the end of a display will exit MCD;
 .  (dot) will re-display the current directory from the beginning;
..[.[.]]   will move to the [great[grand]]parent, etc., directory;
 \         will move to the root directory;
 x:        drive letter with colon, to change drives;

or any of the following commands;
DIR [xx]   to show the files in the current directory, by default, or
           optionally, a named subdirectory, xx;
MD xxx     Make a New Directory xxx;
RD xxx     Remove an Empty Subdirectory xxx;
DEL xxxx   To DELETE a file;
MF         Make a temporary File

if any of these REXX scripts of mine are installed, they may be invoked;
TRE [opt]  to 'look ahead' at the subdirectories available in the current
           branch
J [opt]    JUMP command to go to another directory
VOLS       shows a listing of all local drives with free and used space
           followed by <Enter>
MF [opt]   to Make a Dummy file

NOTE: This script works with my J.CMD, TRE.CMD, MF.CMD and VOLS.CMD,
      if they are installed.
NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
NOTE: Since RexxUtil.DLL is specific to OS/2 it is likely that this cmd will
      work only with OS/2 compatible systems.
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

clr.wht = '1B'x || '[37;1;m'                               /* white, high intensity  */
clr.nrm = '1B'x || '[0;m'                                  /* normal        */

map = SysDriveMap( ,'LOCAL')                               /* To qualify drive selections. */

/* k1 loop keeps the whole show rolling until done. */
do k1 = 1                                                  /* Loop once per directory selected. */
   call SysCls                                             /* Clear the screen. */
   directory = strip( directory(), 'T', '\') || '\'        /* Current dir with one and only one trailing \. */

   drop subdir.                                            /* Clear last subdir. */
   say                                                     /* Blank line at top of output window. */

   call SysFileTree '*', 'subdir.', 'DO'                   /* Get list of all subdirs in current directory. */
                                                           /* These are FPDNs. */
   if subdir.0 = 0 then do                                 /* Handling for NO subdirs. */
         say right( 'No subdirectories in', 22) clr.wht||directory||clr.nrm
         say
         say "  \  to go to root; or  ..[.]  to go to [grand]parent; or  .  to repeat; <Enter>"
         say "or  DIR  ,  MD  ,  DEL  ,  J  ,  TRE  ,  VOLS  ,  MF, <Enter>"
         say "or a drive letter with colon, <Enter>"
         say "or <Enter> to exit."
         parse pull choice                                 /* Get input - \, .., command, drive or null. */
         select
            when choice = '\' | choice = '..' then         /* .. or \, go left in tree. */
                  call directory choice                    /* Go to Root or Parent directory! */
            when wordpos( translate( choice), map) > 0 then      /* New existing Drive! */
                  call directory choice                    /* Iterate k1 from here. */
            when translate( left( choice, 4)) = 'DIR ' then do
                  parse var choice . parm                  /* parm optional subdirectory name. */
                  call SysCls
                  'DIR' parm '/A:-D'
                  say
                  say "<Enter> to continue ..."
                  pull
                  end                                      /* Iterate k1 from here. */
            when translate( left( choice, 3)) = 'MD '  then do
                  parse var choice . parm
                  if parm = '' then do
                        say 'No new directory name specified.'
                        pull
                        iterate k1
                        end
                  "MD" parm
                  say "<Enter> to continue ..."
                  pull
                  end
            when translate( left( choice, 4)) = 'DEL ' then do
                  parse var choice . parm
                  if parm = '' then do
                        say 'No filename or filename mask specified.'
                        pull
                        iterate k1
                        end
                 "DEL" parm
                 say "<Enter> to continue ..."
                 pull
                 end
            when translate( left( choice, 3)) = 'MF '  then do
                  parse var choice . parm
                  "MF" parm                                /* Make file */
                  say "<Enter> to continue ..."
                  pull
                  end
            when translate( left( choice, 4)) = 'TRE ' then do
                  parse var choice . parms
                  call TRE parms
                  say "<Enter> to continue ..."
                  pull
                  end                                      /* Iterate k1 from here. */
            when translate( left( choice, 2)) = 'J ' then do
                  parse var choice . parm                  /* parm optional J parameter. */
                  say
                  call J parm
                  if result \= 0 then do
                        say "<Enter> to continue ..."
                        pull
                        end
                  end                                      /* Iterate k1 from here. */
            when translate( left( choice, 5)) = 'VOLS ' then do
                  call VOLS
                  say
                  say "<Enter> to continue ..."
                  pull
                  call Syscls
                  end                                      /* Iterate k1 from here. */
            when choice = '' then leave k1                 /* null input */
            when verify( choice, '.') = 0 & length( choice) > 2 then
                  do length( choice) - 1
                     call directory ..
                  end                                      /* Iterate k1 from here. */
            otherwise nop
         end   /* select */
      end   /* if subdir.0 = 0 then do.  Iterate k1 from here. */

      else do                                    /* Executed on new directories if THERE ARE SO subdirs ... */
         trip = 1                                /* Executed before first subdir is written in window. */
         say right( subdir.0 'subdirectories in', 22) clr.wht||directory||clr.nrm
         say

         do dir = 1 to subdir.0                            /* Loop thru available directories. */
            if trip then do                                /* Tripwire to spring trap. */
                  trap = dir                               /* Save number of first directory ... */
                  trip = 0                                 /* in the window. */
            end
                                                           /* Say a windowful of dirs. */
            parse var subdir.dir (directory) spot          /* Pick off the last directory of FQN. */

            say right( dir, 4) || '.' spot                 /* List number & subdir in window. */

            parse value SysCurPos() with row .             /* Is the window full? */
            if (row > (rows - 8)) | (dir = subdir.0) then do   /* Window is full or dir list is done ... */
                  trip = 1
                  say                                      /* so ask for instructions. */
                  say "Subdirectory number, <Enter>"
                  say "or  \  to go to root, or  ..[.]  to go to [grand]parent, or  .  to repeat, <Enter>"
                  say "or   DIR  ,  MD  ,  RD  ,  DEL  ,  J  ,  TRE  ,  VOLS  ,  MF, <Enter>"
                  say "or a drive letter with colon, <Enter>"
                  if dir < subdir.0 then say "or <Enter> to see more directories, or '0' <Enter> to exit"
                  if dir = subdir.0 then say "or <Enter> to exit."   /* Display is finished. */
                  parse pull choice                        /* Input = number,  ..,  \,  command,  or null. */
                  select
                     when (choice > 0) & (choice <= subdir.0) & datatype( choice, 'W') then do
                           call directory subdir.choice    /* A subdirectory number is chosen. */
                           iterate k1                      /* Display new directory from dir #1. */
                           end
                     when choice = '\' | choice = '..' then do    /* Move left in directory tree. */
                           call directory choice
                           iterate k1                      /* Display new directory from #1. */
                           end
                     when wordpos( translate( choice), map) > 0 then do    /* New Drive! */
                           call directory choice
                           iterate k1
                           end
                     when translate( left( choice, 4)) = 'DIR ' then do
                           call SysCls
                           parse var choice . parm
                           'DIR' parm '/A:-D'              /* Files only, no directories.  */
                           say
                           say "<Enter> to continue ..."
                           pull
                           call SysCls
                           dir = trap - 1                  /* Reshow last directories page. */
                           say
                           say right( "... Continuing to" subdir.0 "in", 22) clr.wht||directory||clr.nrm
                           say
                           end                             /* Continue in dir loop. */
                     when translate( left( choice, 3)) = 'MD '  then do
                           parse var choice . parm
                           if parm = '' then do
                                 say 'No new directory name specified.'
                                 pull
                                 iterate k1
                                 end
                           "MD" parm
                           say "<Enter> to continue ..."
                           pull
                           end
                     when translate( left( choice, 3)) = 'RD '  then do
                           parse var choice . parm
                           if parm = '' then do
                                 say 'No directory name specified.'
                                 pull
                                 iterate k1
                                 end
                           "RD" parm
                           say "<Enter> to continue ..."
                           pull
                           end
                     when translate( left( choice, 4)) = 'DEL ' then do
                           parse var choice . parm
                           if parm = '' then do
                                 say 'No filename or filename mask specified.'
                                 pull
                                 iterate k1
                                 end
                           "DEL" parm
                           say "<Enter> to continue ..."
                           pull
                           end
                     when translate( left( choice, 3)) = 'MF '  then do
                           parse var choice . parm
                           "MF" parm
                           say "<Enter> to continue ..."
                           pull
                           end
                     when translate( left( choice, 4)) = 'TRE ' then do
                           parse var choice . parms
                           call tre parms                  /* TRE.CMD */
                           say "<Enter> to continue ..."
                           pull
                           call SysCls
                           dir = trap - 1                  /* Reshow last directories page. */
                           say
                           say right( "... Continuing to" subdir.0 "in", 22) clr.wht||directory||clr.nrm
                           say
                           end                             /* Continue in dir loop. */
                     when translate( left( choice, 2)) = 'J ' then do
                           parse var choice . parm
                           say
                           call j parm                     /* J.CMD */
                           if result \= 0 then do
                                 say
                                 say "<Enter> to continue ..."
                                 pull
                                 call SysCls
                                 dir = trap - 1            /* Reshow last directories page. */
                                 say
                                 say right( "... Continuing to" subdir.0 "in", 22) clr.wht||directory||clr.nrm
                                 say
                                 end
                              else iterate k1
                           end                             /* Continue in dir loop. */
                     when translate( left( choice, 5)) = 'VOLS ' then do
                           call VOLS                       /* VOLS.CMD */
                           say
                           say "<Enter> to continue ..."
                           pull
                           call SysCls
                           dir = trap - 1
                           say
                           say right( "... Continuing to" subdir.0 "in", 22) clr.wht||directory||clr.nrm
                           say
                           end
                     when (choice = '')  &  (dir < subdir.0) then do  /* See more sub-directories. */
                           call SysCls
                           say
                           say right( "... Continuing to" subdir.0 "in", 22) clr.wht||directory||clr.nrm
                           say
                           end                             /* Back to top of dir loop and next number. */
                     when (choice = '')  &  (dir = subdir.0) then leave k1      /* EXIT */
                     when verify( choice, '.') = 0 & length( choice) > 2 then do
                           do length( choice) - 1
                              call directory ..
                           end
                           iterate k1
                           end                             /* when ... then ... */
                     when choice = '0' then exit
                     otherwise
                           do while length( choice) > 0              /* For dotted numbers ... */
                              parse var choice num "." choice        /* like output of TRE /N. */
                              if \(datatype( num, 'N')) then leave
                              if num < 1 | num > subdir.0 then leave
                              call directory subdir.num
                              call SysFileTree '*', 'subdir.', 'DO'  /* Directories only !! */
                           end
                           iterate k1
                  end   /* select */
            end   /* if row >  ... else  */
         end dir
      end   /* if subdir.0 = 0 ... else do */            /* ELSE Handling for NO subdirs. */
end k1

exit 0
