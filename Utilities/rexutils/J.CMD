/* J  (Jump)       CMD by Gord Snider  2011/02/18  v01.13.00  2017/07/09     */
/*  PURPOSE: To assist in moving between directories in a command line session.
A Nickname is a one word symbol (i. e. mnemonic or alias, max 10 characters, no
spaces, first character may not be "+" "-" "/") that stands for a directory.
A Shortcut is a nickname for a directory, plus the full path to that directory,
i.e. a Shortcut is one full line from the Databank.
J.cmd uses a small file (Databank) to record commonly used directories, each
with a nickname.  When you ask for a nickname the associated directory is made
current.

    SYNTAX: J nickname
     or     J +nickname
     or     J -nickname
     or     J
     or     J /l
     or     J /?

     WHERE:
nickname    Jumps to a directory with this nickname, (max 10 characters,
            no spaces, first character may not be "+" "-" "/"), as defined in
            the Databank
+nickname   Adds nickname with current directory path to the Databank.
-nickname   Removes nickname and its directory path from the Databank.
(null)      Jumps to previous current directory.  Repeated use of the J
            command will jump back and forth between 2 directories.

   OPTIONS:
/L          Lists shortcuts defined in the Databank, and exits.
/?          Displays a help screen, and exits.

NOTE: This script has a CUSTOMIZATION section, below, that MUST be updated to
      your situation BEFORE your first use of this script.  This script builds
      and maintains a small database on your HD.
NOTE: This script creates an OS/2 Environment variable, JPREVDIR.
NOTE: This script will work with my MCD.CMD if MCD is installed on your HD.
NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
NOTE: Because the cmd uses RexxUtil.DLL it is likely that it will run only in
      OS/2 compatible systems.
*/
/* Your first action, after you have copied this script into your REXX folder, is to edit the Customization
section of the script below to put in the FQFN for your Databank.  This can be an existing Databank from an
earlier version of J.CMD, or a new Databank.  Save J.CMD to your folder of REXX cmds.

If it is an existing Databank it must have the layout of nickname at the left margin, a single space,
and then the full path to that directory.  For an existing Databank, that is all the action
that is necessary.

J.CMD will create its own Databank from scratch if none exists at the Databank location. To add new
shortcuts to a Databank, CD to a directory that you want to add to the Databank.  While in that
directory use the J command with the +nickname option.  That will add the directory, with its nickname,
to the Databank, and it may be jumped to from that point on.  Each time you add a shortcut to the
Databank the entire Databank is sorted to maintain it in alphabetical order by nickname.  Use the
-nickname option to remove a shortcut from the Databank.  It is NOT necessary to have that directory
current to do a removal.

The "jump to the previous directory" feature works by storing the path to the current directory as an
environment variable, JPREVDIR, just before jumping away to the next directory.  Using "J" without a parameter
reads the environment variable and switches back to there.
*/

/* **********   CUSTOMIZATION   ********** */
Databank = "D:\jbank.db"                              /* Put YOUR Databank where YOU want it. */
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

arg nn                                                     /* Command line argument */
arg switches

clr.wht = '1B'x || '[37;1;m'                               /* white         */
clr.nrm = '1B'x || '[0;m'                                  /* normal        */
clr.mga = '1B'x || '[35;1;m'                               /* magenta, high */
clr.cyn = '1B'x || '[36;1;m'                               /* cyan, high    */

env = 'OS2ENVIRONMENT'
CurDir = Directory()                                       /* Save the current directory */
say

if Stream( Databank, "C", "QUERY EXISTS") = "" then do     /* If no databank, then create one. */
      call Stream Databank, "C", "OPEN"
      call Stream Databank, "C", "CLOSE"
end

select
   when opt.L then do                                      /* List shortcuts in Databank. */
      offset = rows - 6                                    /* Allow lines for headings, msgs, etc. */
      call Stream Databank, 'C', 'OPEN READ'               /* Open Databank, no read. */
      do x = 1 while Lines( Databank)                      /* To find number of lines in Databank. */
         shortcut.x = LineIn( Databank)                    /* Read a line from Databank. */
      end x
      shortcut.0 = x - 1                                   /* DO adds 1 too many to x. */
      call Stream Databank. 'C', 'CLOSE'                   /* Close Databank. */
      lncnt = 1                                            /* Line Count */

      say ' Databank located at' clr.wht||databank||clr.nrm
      say ' List of' shortcut.0 'defined shortcuts:'
      say right( '  Nickname     Directory', 25 + length( shortcut.0), ' ')

      do y = 1 to shortcut.0                               /* List all the shortcuts. */
         parse var shortcut.y nick path

         say format( y, 3) left( clr.cyn||nick, 15) "    " clr.mga||path||clr.nrm
         lncnt = lncnt + 1                                 /* Window Line Count */
         if (lncnt >= offset) then do                      /* Window full but more data ... */
            say
            say '<ENTER> to continue ...'
            pull num                                       /* num = dir number from the menu. */
            if num \= '' then do
                  call value 'JPREVDIR', CurDir, env       /* SET current directory in env var. */
                  parse var shortcut.num nick path
                  call directory path                      /* Swich to new directory. */
                  exit
            end
            lncnt = 1                                      /* Line Count */
            offset = rows - 2                              /* Allow for headings, trailers, etc. */
         end  /* if (lncnt  offset) */
      end y
      jrc = 2                                              /* Jump return code works with MCD.cmd */
   end  /* when opt.L */

   when nn = "" then do                                    /* Switch back to previous directory */
      prevdir = value( 'JPREVDIR', CurDir, env)            /* Switch env var value and CurDir */
      if prevdir \= '' then do
            call directory prevdir                         /* Jump! back. */
            jrc = 0                                        /* Jump return code works with MCD.cmd */
         end
         else do
            say 'Environment Variable JPREVDIR set to' Directory()
            jrc = 2                                        /* Jump return code works with */
      end  /* if then else */
   end  /* when nn = "" */

   when abbrev( nn, '+') then do                           /* Add new shortcut to Databank. */
      nn = delstr( nn, 1, 1)                               /* Strip '+' off nickname */
      if nn \= '' then do
            shortcut.1 = nn CurDir                         /* Build new shortcut, put into array.1. */
            call Stream Databank, 'C', 'OPEN READ'         /* Sort the Databank. */
            do i = 2 while Lines( Databank)                /* For each line in Databank, */
               shortcut.i = LineIn( Databank)              /* read the shortcut into an array. */
               k = i - 1                                   /* Index to one earlier array entry for bubble up. */
               do j = i to 2 by -1 while shortcut.j < shortcut.k   /* Bubble next shortcut up to its location. */
                   shortcut = shortcut.j;                          /* Swap k and j. */
                   shortcut.j = shortcut.k;
                   shortcut.k = shortcut
                   k = k - 1
               end j
            end i
            call Stream Databank, 'C', 'CLOSE'             /* Close Databank. */
            shortcut.0 = i - 1                             /* Set number of array entries. */

            call SysFileDelete Databank                    /* Delete whole Databank. */
            if result \= 0 then signal nodelete

            call Stream Databank, 'C', 'OPEN WRITE'        /* Open Databank, no write. */
            do m = 1 to shortcut.0
              call LineOut Databank, shortcut.m            /* Write out all array entries. */
            end m
            call Stream Databank, 'C', 'CLOSE'             /* Close Databank. */
            say 'Shortcut added to Databank:' clr.cyn||nn  clr.mga||CurDir||clr.nrm
         end
         else say 'No nickname supplied.'
      jrc = 2                                              /* jump return code works with */
   end  /* when abbrev( nn, '+') */

   when abbrev( nn, '-') then do                           /* Remove shortcut from Databank. */
      nn = delstr( nn, 1, 1)                               /* Remove '-'. Isolate nickname. */
      if nn \= '' then do
            found = 0                                      /* Flag for nickname validity. */
            call Stream Databank, 'C', 'OPEN READ'         /* Open Databank, no read */
            do i = 1 while Lines( Databank)                /* For each shortcut in Databank, */
               shortcut.i = LineIn( Databank)              /* Read the Databank entries into an array. */
            end i
            call Stream Databank, 'C', 'CLOSE'             /* Close Databank */
            shortcut.0 = i - 1                             /* Set number of lines */

            call SysFileDelete Databank
            if result \= 0 then signal nodelete

            call Stream Databank, 'C', 'OPEN WRITE'        /* Re-open Databank for new data output. */
            do j = 1 to shortcut.0
               parse var shortcut.j nick .
               if translate( nn) = translate( nick) then do
                     found = 1                             /* nn found. */
                     iterate j                             /* Skip target shortcut. */
               end
               call LineOut Databank, shortcut.j           /* Write out next shortcut. */
            end j
            call Stream Databank, 'C', 'CLOSE'             /* Close Databank. */
            if found then
                  say 'Nickname and path' shortcut.i ' removed from the Databank.'
               else say 'Nickname ' nn ' not found in the Databank.'
         end
         else say 'No nickname supplied.'
      jrc = 2                                              /* jump return code works with MCD.cmd. */
   end  /* when abbrev( nn, '-') */

   otherwise                                               /* Switch to nicknamed directory. */
      found = 0                                            /* Flag to track nickname validity. */
      call Stream Databank, 'C', 'OPEN READ'               /* Open Databank, no read. */
      do while Lines( Databank)                            /* For each line in Databank, */
         parse value LineIn( Databank) with nick path      /* get nickname and path. */
         If nn = nick then do                              /* If this nickname = argument, */
               found = 1                                   /* set validity flag, */
               call value 'JPREVDIR', CurDir, env          /* Store current directory in env var, and  */
               call directory path                         /* switch to chosen directory. */
               if result = '' then                         /* Directory does not exist. */
                     say 'Directory ' path ' does not exist.'
               leave      /* do while Lines() */
         end
      end /* do while Lines() */
      call Stream Databank, 'C', 'CLOSE'                   /* Close Databank */
      jrc = 0                                              /* jump return code works with MCD.cmd. */
      if \found then do
            say 'Nickname ' nn ' not in the Databank.'
            jrc = 2                                        /* jump return code works with MCD.cmd. */
            end
end  /* select */

exit jrc

nodelete:
say 'Databank not properly deleted at line' sigl
exit 8
