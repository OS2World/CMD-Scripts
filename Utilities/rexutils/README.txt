REXUTILS README FOR Version 4                                2017/01/02
This is the README file that goes with the package of disk utilities,
REXUTILS4.ZIP   2017/09/13
by Gordon Snider
Send communication regarding these to
gsnider@look.ca

You may adopt or adapt for your own use any code I wrote in this package.
These scripts show working techniques you can use to get things done in REXX.
I am not calling them full scripts because they lack, among other things,
much error handling.  However, they do work as is. They do show techniques.

This README is best read with an editor, like NEPMD or THE or TSPF
that can show a page at least 112 columns wide.

The latest version of these utilities can be found at Hobbes, in the directory
hobbes.nmsu.edu/pub/os2/util/disk/

The explanations of the code are aimed at the beginner-intermediate level
REXX programmer who is learning REXX as his first programming language.

If you have read a version of this readme for an earlier version of
the utilities (then named REXUTILS11.ZIP) you should re-read this readme as
changes have been made throughout and are not marked.

The files in this package are:
   . README.004      This file
   . COMPDIRS.CMD    Compare Contents of 2 Directories
   . DASHBD.CMD      DashBoard - Using Colors as Indicator lights
   . DUPSGONE.CMD    Duplicate Files in Another Directory Gone
   . ESFS.CMD        Use SysFileSearch to search line-by-line for text
   . FD.CMD          Find a Directory Using a (Partial) Name
   . FUNCTEST.CMD    Function Tester
   . GOOG.CMD        Search your hard drive for text in a file
   . HELP            Show a Help Screen (snippet)
   . J.CMD           Jump To Another Directory
   . KERNEL.CMD      Code to Walk a Directory Tree
   . LN.CMD          Add Line Numbers to a Program
   . MCD.CMD         Menu CD
   . MF.CMD          Make File
   . OPTS            Switch Handling (snippet)
   . PATHS.CMD       Breaks PATH statement into Parts
   . SCALE.CMD       Draw a Column Scale in a Window
   . TOUCH.CMD       Change a File's Last-Write Date
   . TRE.CMD         Tree Display
   . TZ.CMD          Decodes the TZ Environment variable
   . VOLS.CMD        Disk Volumes Space Usage Display
   . WHEREIS.CMD     Find a File or Directory
   . WINSIZE.CMD     Find a window size
   . _COLOR          Add color to text and background
   . _COMMAS         Put commas in a large number
   . _COUNT          Counts of substrings in a string
   . _DTS            Date Time Stamp
   . _SCALE          Adds a column ruler across a window
   . _SORT           Simple Sort
   . _STRETCH        Add chars into a string




INSTALLATION
============
This package assumes:
1. you have a directory reserved for REXX scripts and
2. the directory is listed in your PATH statement in your CONFIG.SYS file.
3. the RexxUtil.DLL is already loaded.  (I load mine at boot time.)
This will allow you to run your REXX scripts from a command line in any
current directory and use the RexxUtil.DLL functions as easily as internal
functions.

This package also assumes that RexxUtil.DLL is loaded at boot time (or at
least before you execute any of these scripts).

I don't want any of these to over-write any of your current REXX code, so
review the above list of files in this package, to see if you already have
any files of the same names in your REXX directory.  If you have no name
conflicts, unzip REXUTILS4.ZIP into your REXX script directory.
If you do have name conflicts, you can unzip this package into a temporary
directory until you resolve the name conflicts.

Any REXX script here whose name does NOT begin with an underline, except
J.CMD and TRE.CMD, may be renamed to a name of your choice.
J.CMD and TRE.CMD are full scripts whose names have been hardcoded into other
scripts and are called by those other scripts.

The names beginning with underlines are REXX External Functions and should NOT
be renamed because the names are hardcoded into, and called by, many of these
scripts.  If you do choose to rename any of these REXX External Functions you
will have to go through each of the other scripts given here and update any
calls to that External Function to the new name you have chosen.
(Note that there really is no filetype in those file names; none is necessary.)




CUSTOMIZATION
=============
Several of these scripts have a section in them, like this,  right after the
opening comments:

/* **********   CUSTOMIZATION   ********** */
       (a line or two of code or data here)
/* *************************************** */

BEFORE THE FIRST EXECUTION you will need to make changes to that line or two
of code or data to allow for your unique computer system.  Usually, it will be
a file name location to be put where YOU want it, or a list of drive letters
to be skipped on YOUR computer.
So look for this section in any script BEFORE you run it for the first time.




GENERAL NOTES
=============

I wrote these scripts in REXX just because I like working in it.  REXX is
well integrated into OS/2-eCS and can pass commands to an external environment.
Using REXX also makes the source code available to the user so the user can see
what is happening; and the user has the chance to modify the code for his own
use.

Version 1 of these scripts was first developed and used on a Pentium Pro
200MHz computer with 64MB RAM running Classic REXX under Convenience Pack 1.
These scripts have NOT been well-used under Object REXX.
(Under Object REXX GOOG.CMD bogs down and often does not run to completion.
It runs fine under Classic REXX.)
However, except for TOUCH.CMD, they only use REXX features that were available
in Classic REXX, so they should run just fine on Warp 3 and Warp 4 and eCS.
TOUCH uses the SysSetFileDateTime() function which was available but not
documented in Convenience Pack 1.

To determine which REXX interpreter you are using, Classic or Object Oriented,
use the SWITCHRX OS/2 command on a command line and follow the prompt.

Of course, there are many programs that you could run from the desktop to do
many of the things these scripts do, and there is some overlap with functions
of 4OS2, but some scripts here provide some extensions beyond basic and some
people just like working from the command line.
(And sometimes, if something goes wrong with OS/2, you just can't get to the
desktop.)


ARGUMENTS
---------
In the comments section of each script there is a section labelled SYNTAX:
that shows how to execute the script.  Many of these scripts use required
arguments that are specified on the command line after the script name.  A
few of these scripts need only the script name, some need the script name and
arguments, and some scripts, with or without arguments, can take optional
switches. THE ARGUMENTS ARE REQUIRED unless they are enclosed in square
brackets  [...] .
The required arguments are described, in a section labelled WHERE: in each
script.


SWITCHES
--------
Switches are used to modify the operation of some scripts.  You have some
flexibility in the way you may enter switches. My standard way of entering
switches here is: space-slash-capital letter, e.g.  /D /F /S.
The script parses the command you enter, splitting the command at the first
'/'.  Anything before that first '/' is used as an argument, everything after
that is used as switches and switch modifiers.
However, as long as you use a slash as the first character the following would
also work:  /D/F/S would invoke the /D /F and /S switches.  Lower case letters
may also be used.  (However, /DFS or /D F S would NOT work.)

In the syntax diagrams for each script some arguments and switches may be
enclosed in square brackets [ ].  This means that those arguments and switches
are optional.  If there is a vertical bar  |  between options it means only
one of those options may be used per execution.
The syntax diagrams are in the comments at the beginning of the code in each
script.


COMMAND WINDOWS
---------------
The default command line window in OS/2 is 80 columns by 25 lines.
The command window can be made larger (or smaller) with the MODE command
making the window able to hold more (or less) output.  Changing the window
size is done with a MODE command, for example  'MODE 120 40'.  The MODE
command needs COLUMNS number first, then the ROWS number, as arguments when
setting a window size. However, the screen-reading functions in RexxUtil.DLL
(like SysTextScreenSize() ) and cursor functions (like SysCurPos() )
give (or require) the ROWS number first, then the COLUMNS.  Watch out for that.
All my scripts will work with larger windows, (not so much with smaller).
For example, my own monitor is physically wide enough, and runs at a
resolution of 1920 x 1080, that my command-line windows are
160 columns wide by 47 rows high, all visible without scroll bars.  Nice!


NOTES
-----
The notes for each script and function are divided into two parts, usually.
The first part is here in this file. I talk about the script in general.
The second part is in the help screen for the script, in the comments at the
beginning of each script.



--------
The scripts above are listed in alphabetical order.  Below, they are
discussed in a different order because some of the earlier mentioned scripts
are used by later mentioned scripts.  Also the simpler scripts are
mentioned before the more complex ones.


USING REXXUTIL.DLL
------------------
These scripts use functions from the REXX Utilities Dynamic Link Library
(RexxUtil.DLL) which contains extra REXX functions specific to OS/2.  Some
of the functions are useful by themselves with just a little extra REXX code
needed to call them and use their output.


All of my REXX scripts use the RexxUtil.DLL library so I always load it at boot
time.  This makes the RexxUtil functions available just like 'Built In
Functions' (BIFs).
To load RexxUtil.DLL at boot time:

At the end of your STARTUP.CMD file add this code used to load RexxUtil.DLL.


CALL RxFuncAdd('SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs')
CALL SysLoadFuncs


The RexxUtil.DLL will load at each following boot and remain
available until you shut down.
(This may be unnecessary in eCS 2.2 as the RexxUtil.DLL seems to be loaded
even without this preparation.)




EXTERNAL FUNCTIONS
==================
Several of these scripts have names that start with an underline, and
NO filetype. These are EXTERNAL FUNCTIONS and can only be used when called
from another REXX script.  Many of my scripts call them so they are
required in your REXX directory, and should not be renamed because then the
calling scripts can't find them.

In OS/2 REXX the filetype of an external function does not have to
be  .cmd, so I have named my external functions with no filetype.
I used an underline as the first character to try and minimize file name
clashes with your existing code.



     _COMMAS
     -------
When displaying a large number it often is easier to read if it has commas in
it.  This is a short external function for putting those commas in.  It allows
for unsigned numbers, positive and negative signed numbers, and decimal
fractions, but not for exponential notation, nor numbers in the European
standard (using dots or spaces instead of commas).  After the commas have been
added to a number it may only be displayed or printed.  REXX will not be able
to use the number for more computing.



     _COLOR
     ------
Working with colored text in OS/2 REXX means working with ANSI escaped codes.
I decided to civilize and simplify using those escaped codes by putting
them into this function.  It lets you specify the color you want by name
and it translates the color name into the right ANSI code.

The text data to be colored may be a quoted literal or a variable name.
You may set the foreground and/or background colors and some text attributes,
like 'invisible' and 'reverse' video, although all ANSI attributes don't work
on all systems.  I don't know why not.

The RETURN statement concatenates the text attribute, the foreground and
background color ANSI codes, the data to be colored,
and the ANSI code to turn off the color so text following the
function is not affected.



     _COUNT
     ------
This is a function to count the instances of one substring in another string.



     _DTS
     ----
Sometimes I need a full Date-Time Stamp in the form
yyyy/mm/dd-hh:mm:ss
so I wrote this function.  Built this way, the stamp is suitable for sorting.



     _SCALE
     ------
This function draws a character scale across a window.  I use it when
I want to quickly find the exact columns of text screen output.



     _SORT
    -----
This function takes a list of items, alphabetic or numeric, separated
by a blank and returns the list in order, e.g.
_SORT( 10 35 6 20 2 7 42)
and returns
2 6 7 10 20 35 42
The strength of this function is its simplicity.  Its weakness is its
slow speed on long lists.  You probably wouldn't want to use it on lists
longer than about 50 items.



     _STRETCH
     --------
This function takes 2 arguments, the first being the string to stretch
and the second being the padding to stretch it with.  It inserts the
padding between each pair of characters of the string, e.g.
_stretch( 'wow', '*-*')
returns
w*-*o*-*w




IN MOST SCRIPTS
===============
There are two small sections of code, OPTS and HELP, that I put at the
beginning, in almost every REXX script I write.
If you want to use them in your own REXX code you can just import them
(cut and paste) straight into your code.
These sections handle
1. switches for the optional code and switch modifiers
2. displaying a help screen

It might be helpful to explain how those sections work because they
are unlike any similar-purposed code I have seen before.



     OPTS
     ----
I use switches, a lot, to vary the basic operation of a script.
Some features need an on-off switch so blocks of code can be executed
at one execution and not another, under switch control.
Here is the code I use to handle switches.  Its features are:
- handles any reasonable number of switches with no increase in code;
- switches may be specified in any order;
- switches may be upper or lower case, with or without spaces between,
- each switch may have a modifier

(Line numbers are in comments at the right.)

parse arg . '/'switches +0                         /* capture and set the switches */                /*ÿ0001ÿ*/
opt. = 0                                           /* unset options will be FALSE */                 /*ÿ0002ÿ*/
mod. = ''                                          /* unset modifications will be NULL  */           /*ÿ0003ÿ*/
do while pos( '/', switches) > 0                   /* each option must be bounded by spaces */       /*ÿ0004ÿ*/
   parse var switches '/'opt'/' switches +0        /* parse out the next option/modification set */  /*ÿ0005ÿ*/
   parse upper var opt opt 2 mod                   /* split the option from any modification */      /*ÿ0006ÿ*/
   opt.opt = 1                                     /* capture option name, set option value TRUE */  /*ÿ0007ÿ*/
   mod.opt = mod                                   /* capture the option's modification, if any */   /*ÿ0008ÿ*/
end                                                                                                  /*ÿ0009ÿ*/

To make use of this code, on the command line just specify a space, a slash '/'
anda letter.  (I try to pick a letter that is mnemonic for the feature, like
/C  for 'color', or /F for 'folders'.)   Let's use /C in the following example.

All switch values are stored in the stem ' opt. '.

Line 1 PARSEs the whole command line dividing it at the first '/' thus
separating any and all arguments in the command from any switches.  The  ' +0 '
at the end of line 1 causes that first slash to remain with the string of
switches.  The +0 causes no data from the source string to be omitted.

Line 2  sets the value of all possible compound variables beginning with   opt.
to zero or FALSE, meaning 'the switch was not specified'.

Line 3 sets sets the stem ' mod. ' to NULL.  I use ' Mod. ' only rarely to set
a modifier on an option.  See MF.CMD for an example.

Line 4 opens a DO WHILE loop that loops once for each option specified on
the command line.  The presence of an option is found by the POS() function.

Line 5 PARSEs the string of switches, assigning the next option, plus any
modifiers to the variable 'opt', (which is NOT the same thing as the stem
opt.).

Line 6 PARSEs that one option and splits it into the option itself and any
modifiers, i.e.  opt 2 mod

Line 7 builds the compound variable opt.opt  by upper casing the stem  OPT.
adding the value of the variable   opt  , (C in this case), to get OPT.C and
assigns that a value of  1 , which is the Boolean value for TRUE.
The tail of the symbol is the same uppercase letter as the switch.

Line 8 builds the compound variable mod.opt, in this case, MOD.C and assigns
it a value, (in this case NULL).

With this setup any switch that is not specified on the command line
is set to '0' or FALSE, any switch specified will be set to '1' or
TRUE.

(By the way, when you are writing your own REXX scripts don't use the option
/Q.  /Q will NOT work.  /Q is reserved by REXX and acts to suppress
the echoing of OS/2 commands from within a script.)

When it comes time, in your code, to execute the optional feature
just write an 'IF' statement in front of the feature's code;

if opt.C then do       /* opt.C evaluates to '1', which is TRUE. */
      ...              (switch specified, so feature turned on)
      end
   else do
      .....            (switch not specified, so feature turned off, default action)
      end



     HELP
     ----
All my scripts use the same system for showing a help screen.  The
help data is written as one comment on the first line and a long
multi-line comment next, showing the purpose, syntax and features of the
program.  The lines have a maximum length of 79 columns to prevent
wrapping in an 80 column command window.
The end of the long comment is always a closing comment delimiter, '*/'
in columns 1 and 2.
The help code just sends those two comments to the screen using the
SOURCELINE() function until it finds that closing delimiter in columns 1 and 2.
It saves having to write special help messages.


parse value SysTextScreenSize() with rows cols                                                       /*ÿ0001ÿ*/
if opt.? then do                                           /* Help screen */                         /*ÿ0002ÿ*/
   rows = rows - 2                          /* Leaves room for the 'Hit <Enter>' message */          /*ÿ0003ÿ*/
   opdel = '/'||'*'||'FF'x ; cldel = 'FF'x||'*'||'/'       /* opening and closing delims */          /*ÿ0004ÿ*/
   do l = 1 to sourceline() until left( sl, 2) = '*' || '/'                                          /*ÿ0005ÿ*/
      sl = sourceline( l)                                                                            /*ÿ0006ÿ*/
      if pos( cldel, sl) - pos( opdel, sl) = 7 then        /* both delims present */                 /*ÿ0007ÿ*/
         sl = delstr( sl, pos( opdel, sl) , 10)                                                      /*ÿ0008ÿ*/
      say strip( left( sl, 79), 'T')                                                                 /*ÿ0009ÿ*/
      if l // rows = 0 then do                             /* when the screen is full */             /*ÿ0010ÿ*/
         say '  Hit <Enter> to continue ...'                                                         /*ÿ0011ÿ*/
         pull .                                                                                      /*ÿ0012ÿ*/
         end                                                                                         /*ÿ0013ÿ*/
   end l                                                                                             /*ÿ0014ÿ*/
   exit                                                                                              /*ÿ0015ÿ*/
end    /* if opt.? */                                                                                /*ÿ0016ÿ*/

Line 1. The window height, 'rows', is used with lines 3 and 10.  I
often use the MODE command to open a larger window and when I do
I want the output to the window to use all the lines available.
(I have made NO provision for MODE settings smaller than 80 columns
in any of my scripts.)

Line 2 checks to see if the Help switch was set, or TRUE.
The command window is usually 80 columns wide, which is how wide the text for
my help screen is.  My programs usually have line numbers, most often in
columns 102 to 111 so I have to truncate the line numbers before I put the help
data in the window, which may be only 80 characters wide.  However, the line
numbers may be on the left, so I must allow for that as well by removing those
line numbers.

Line 4 specifies the special comment delimiters used by my line numbers.

Line 5 reads sourcelines from disk until it finds the closing
comment delimiter on a line in columns 1 and 2.

Line 7 is a safety feature - both comment delimiters around the
line number must be present, 7 characters apart.  This is to prevent
line 8 from deleting other comments.

Line 8 deletes the line number, if any,

line 9 sends the help line to the screen.

Lines 10 through 13 pause the output if the help text takes more
than one screen.



THE SCRIPTS
===========


     LN.CMD
     ------
This script is a working example of the use of a queue in REXX.

I am beginning with the notes for this command because some people don't like
line numbers.  All the line numbers in these cmds were produced with LN.CMD
and may be removed with LN.CMD, too.

LN stands for Line Numbering.  This is a utility that produces (or removes)
line numbers.
I often like to email my code to friends and discuss some of the programming
techniques with them.  When the code is line-numbered I can just mention the
line number I'm talking about instead of cutting-and-pasting sections of
code into the email.  If you don't like the line numbers you can use this
utility to remove them, but it will only remove line numbers it has created.

Features:
- line numbers can go up to 9,999 lines.
- under switch control line numbers may be placed at
  the left end of a line or
  at column 80 for portrait printing, or
  at column 102 for landscape printing, on letter-size paper (the default),
- program lines with data where the line number would go are counted but left
  unnumbered.  (The line number never overwrites existing code.)
- blank lines may be counted and numbered, or not, under switch control.
- program can add or remove its own numbers, under switch control.
- line re-numbering can be done in one step.
- the default line number interval is '1', changeable under switch control.

On my screen and my printer with my choice of MONOSPACED font, without line wrapping or clipping,
line widths of 111 characters will print in landscape orientation, and line widths of 90 characters
will print in portrait orientation.
I picked columns 102 - 111 for the line numbers because I edit with EPM, maximized, and column 102
puts the line numbers at the far right.  So all code lines should be less than 102 characters.
YMMV.

What sets this program apart from other line numbering programs is the format of the comment
containing the line number.  The apparently-blank spaces separating the comment delimiters from
the line number are not true blanks.  They are hex FF (decimal 255) characters that appear blank.
The line number removal process searches for comment delimiters plus hex FF (decimal 255) characters
that are 7 spaces apart anywhere in a line.  This pattern was considered UNLIKELY BUT NOT IMPOSSIBLE
to appear elsewhere in a program. If this pattern DOES appear elsewhere THAT DATA WILL BE
INCORRECTLY REMOVED.  BE WARNED.



     DASHBD.CMD
     ----------
This is a strange one so I'll deal with this one now.
If you have a long-running script in which values change over a range that
may be represented in a scale of colours this is one way you might display
the output in a dashboard-like display.   All it does is flash blocks of color
but it is a working snippet of how to program a dashboard of indicator lights.



     WINSIZE.CMD
     -----------
This is a short simple script to show how to make one use of a RexxUtil.DLL
function, SysTextScreenSize() in this case.  The function is used with just
enough REXX code around it to make it do something.



     TZ.CMD
     ------
This is a simple script to decode your TZ environment variable.



     SCALE.CMD
     ---------
This is a simple script that draws a column scale across a window.  I wrote
it when I wanted to discover what character position(s) on the screen contained
output I was looking at.



     TOUCH.CMD
     ---------
This makes use of the SetSysFileDateTime() function.
Updates the last-write date and time stamp of a file or all files in a
directory to the current date and time.



     FD.CMD
     ------
Use this script if you forget where a directory is but you remember the name or
even just part of the name.
Put the name (or partial name) as the argument and let the script find the
directory.  In the output each 'find' is numberd.  To change to a numbered
directory just enter the number.



     VOLS.CMD
     --------
If you have multiple drives defined this is another way to see, from
the command line, where the used and free space is on your system.
The default is to count both LOCAL and REMOTE, i.e. USED space.
Those computers not on a network will show only LOCAL space, of course.
LOCAL or REMOTE space alone can be selected by switch.

Also shown is the bootdrive, the RESERVEDRIVELETTER, any inaccessible
drives, and the free drives.

This also uses colors in the output to show which drives have the most
(blue numbers) and least (red numbers) free space.

SAMPLE OUTPUT

[D:\CMD]vols
Bootdrive is C:

RESERVEDRIVELETTER=R

.. Drive S: is not accessible.

These are the free LOCAL drive letters.
J: K: M: O:

   Label             Free MiBytes   %       Used MiBytes   %      Total MiBytes

C: ECS12R                   6,961  70              3,055  30             10,017
D: APPS0                   17,170  86              2,832  14             20,002
E: MAINT                    1,187  79                318  21              1,506
H: DOWNLOAD                 3,240  65              1,764  35              5,004
X: BACKUPS                 12,081  60              7,921  40             20,002

   Totals                  40,642  72             15,890  28             56,533



     PATHS.CMD
     ---------
The basic action of this script is to break down a PATH statement from either
the Environment or the CONFIG.SYS file into its individual paths, making it
easier to read.  Additionally, it checks each path to see if that path still
exists on the hard drive, and, if it does exist, are there files in that
directory.  It can also check other Environment variables like LIBPATH or
HELP.
Also it can check in each directory for the presence of a file,
e.g. if you were having DLL conflicts you could enter a command like

PATHS LIBPATH,nspr4.dll

and the display would show you which libraries in the libpath had that DLL in
them.



     MF.CMD
     ------
MF.CMD (MF stands for Make a File) is a script that, by default,
creates a named, zero-byte file and a directory entry for that file.
Under switch control you make the file any legal size, full of binary
zeros.  You can give the file a name or let the program give it one.
You can put the file anywhere by giving it a path.
I use this script when I'm testing another script that needs a lot of
file names.



     WHEREIS.CMD
     -----------
This uses the SysDriveInfo() and SysFileTree() RexxUtil functions.
Searches local-system wide for all copies of a named file, and
optionally, shows the attributes of each file found.



     COMPDIRS.CMD
     ------------
The basic action of COMPDIRS.CMD is to compare the filenames in 2 directories
and report on the files that are in each directory but not in the other.  Under
switch control it will also report on the files that are common to both
directories.  Also under switch control it can report all the same information
for subdirectory names.



     ESFS.CMD
     --------
ESFS.CMD is used to do searches, LINE BY LINE, through files for a text string.
THIS SEARCH IS CASE INSENSITITVE.
It contains REXX code to make use of the SysFileSearch() function in the
RexxUtil.DLL.   The SysFileSearch() function searches one named file per
execution. The main added feature of this script is that enough REXX code is
added to allow groups of files to be checked in one execution.
This script differs from GOOG.CMD because this search is case insensitive, by
default, only searches for one string at a time, and can't do negative
searches.


     BYTES.CMD
     ---------
BYTES.CMD can help you get a picture of where your disk space is
being used up. It will total up the file space of one entire
branch in the current directory, (not including the files in the current
directory) or the file space of all the files and subdirectories in the
current directory (this time including the files in the current directory).

There is a slight difference in those two descriptions.

If BYTES.CMD is given an unqualified subdirectory name from the
current directory it will walk into that subdirectory, and
that whole branch, and total up the bytes used by all the files, NOT
including the files in the current directory.

If  .  is supplied instead of a subdirectory name, all files in the current
directory plus all files in all subdirectories will be included in the
total.

It will NOT add up any bytes in Extended Attributes.

The /D switch produces an output line showing the fully qualified
name for each directory.

The /F switch produces an output line for each file showing the
ADHRS attributes, size, date, time and fully qualified name of
the file.


SAMPLE OUTPUT

[D:\]bytes \ae /d
.... D:\ae
.... D:\ae\test1
.... D:\ae\test2

Totals for branch based on D:\ae
Directories: 3    Files: 14    Bytes: 453,542



     DUPSGONE.CMD
     ------------
Have you ever installed an app in a 'wrong' folder that already had some other
files there you wanted to keep, leaving you with the job of re-installing the
app in its own 'right' folder and then picking out the wrongly installed app
files one file at a time?  After you install the app in the 'right' folder this
script will help you clean up the 'wrong' folder.  It will compare the files
in a reference (right) folder with the files in a target (wrong) folder
and if a duplicate file is found, the file in the target 'wrong' folder will
be deleted.



     FUNCTEST.CMD
     ------------
When I am creating a new REXX function I need to test it.  This script lets
me do that easily by calling the new function, passing arguments to it, and
receiving any return string.  That way I don't have to have a fully
functioning calling script before I can write a called function.
It is also possible to test nested functions with this script.  For example,
if I want to take the number  1000000  and put commas in it and then display
it in a colour, say 'red',  I would use the two External functions _COMMAS()
and  _COLOR()  with FUNCTEST like this:
FUNCTEST _COLOR _COMMAS( 1000000), RED



     J.CMD
     -----
This idea came from a script JJ.CMD by Joerg Tiemann.
If you use the command line heavily and jump around between directories by
typing CD and a lot of directory names, this might help.  J builds a small
databank of folder nicknames and paths.  Typing   J nickname   will jump
straight to the associated directory.  J +nickname   will add the current
directory to the databank under that nickname.  J -nickname   will remove a
nickname/path combination.  J   will jump to the previous directory, whether
that directory is in the databank or not, if you have executed   j   while in
the previous directory.  Repeated use of   J   will jump back and forth
between two directories.



     MCD.CMD
     -------
This script saves me a lot of typing when I am using the CD command
to move between directories.  When I execute it, it lists
all the subdirectories in the current directory, each with a number,
and asks for the number of the directory to CD to.  Just give it a
number to go to that directory.

The basic mode of operation is to move one directory level at a time
by directory number, not directory name; but I extended it to do more
than this.

MCD will also accept drive letters to change drives, and can work with the
J.CMD to make bigger jumps.
MCD works with the TRE.CMD or the DIR command.  When MCD asks for instruction
and there are subdirectories on the screen enter  DIR  if you want a list of
files in the CURRENT directory, or enter   DIR subdirname   if you want a list
of files in that subdirectory.  Same for TRE: enter   TRE   if you want to see
the tree out from the current directory, or   TRE subdirname   if you want to
see the tree out from that subdirectory.  All the switches are available so
you could enter something like
TRE subdirname /c/b/f/d/t
if you really wanted to see what is 'up ahead' in the tree.

Also it will accept a drive letter to go to the root of another drive.
Also if you find yourself in a directory you know you
are going to come back to often you can issue a   J +nickname   command
to put a shortcut in the J.CMD databank.  You can also issue   J nickname
to jump to any nicknamed directory on any drive.



     MERGE.CMD
     ---------
This script takes 2 input files that have been already sorted on a
field and merges them into one file, also sorted on that field.
It is a working script that shows a way to use REXX Stream() function
with the SEEK argument to move around in a file right on the disk.



     KERNEL.CMD
     ----------
Several of these scripts use recursion to 'walk through' a directory tree,
that is, visit every directory in the tree (or branch).
The code to do this does not seem to be widely known, but it should be.  The
kernel (it works!) for walking through a directory tree is in KERNEL.CMD.  It
is a combination of a loop and recursion, that starts at the current directory
and visit each directory, in order, out to the 'leaf' directories.

This 17 line kernel will start in the current directory and
'visit' each and every directory in the tree of which the current directory
is the root.  This code can be adapted (as in the following TRE.CMD) to do
some work in each directory while it is there.
The TRE.CMD, below, takes this kernel and tucks features into its nooks and
crannies.



     TRE.CMD
     -------
Draws a directory tree structure.

This script has more switches than most of my scripts.
If you want to see the total number of bytes in each folder passed
through try the /B switch, the /D switch to see the number of sub-
directories in each directory, and/or the /F switch to see the
number of files in each directory.  And if trying to pick out all
those numbers off the screen gives you a headache, like it did me,
try the /C switch to get the numbers in color.

If you are using this to find a certain directory, and after you
find it you wonder what the path to it is, the /P switch, or
maybe the /N switch, will tell you what you want to know.
(The colors used for the /P and /N switch are red and green.)

By default, TRE.CMD expects to use a codepage that provides
some line drawing characters.  These are '³', at decimal 179,
'À', at decimal 192, and 'Ã', at decimal 195.
Codepage 437, (United States), is one codepage that does this.  If you
are using a codepage that doesn't have these characters, you can still
get most of the benefits of TRE.CMD by using the /A switch.  This
will use ASCII characters instead of the graphics characters
and preserve the indenting of the directories.


SAMPLE OUTPUT

[D:\]tre bluecad

D:\bluecad\
 Ã ACROREAD
 Ã BLOCKS
 ³ Ã ARCH
 ³ Ã CIVIL
 ³ Ã COMPUTER
 ³ Ã ELECTRIC
 ³ Ã ELECTRON
 ³ Ã FURNIT
 ³ Ã GUIDE
 ³ Ã HYD
 ³ Ã LOGIC
 ³ Ã MECH
 ³ À PIPING
 Ã DLL
 Ã DRAWINGS
 Ã MACRO
 Ã MSG
 Ã PRGM
 À TMP



     GOOG.CMD
     --------
THIS SCRIPT MUST BE RUN UNDER CLASSIC REXX.  Under OREXX it bogs down and
crashes with an OREXX 'Out of Resources' message.  I have heard this is due to
a memory leak in the OREXX file I/O routines.

This is a (working!) kernel of a search utility.  With it, you can search your
hard drive for files containing (or not containing) one or more (up to six)
specified strings.

This search differs from ESFS because:
IT SEARCHES A WHOLE FILE AT A TIME, NOT LINE BY LINE.
IT IS CASE SENSITIVE,
IT CAN SEARCH FOR MORE THAN ONE STRING AT A TIME,
IT CAN DO NEGATIVE SEARCHES, I.E. FILES NOT CONTAINING A STRING.

You may use parentheses to group the strings and combine them with logical
AND, OR, EXCLUSIVE OR, and/or NOT operators.  The output is a file containing
the fully-qualified name(s) of files that contain the strings you are looking
for.

It uses no indexing of the data on your hard drive so it takes a few minutes
to run.  On my system it can search through almost a gigabyte of files a
minute.

IT STRICTLY RESPECTS THE CASE OF CHARACTERS IN THE SPECIFIED STRINGS.

There are lots of ways this could be speeded up.  Since one is searching
(usually) for plain text one could skip those file types not containing plain
text;  e.g. .exe .zip .wav .bmp .jpg .wmv ...  etc.  One could add code to skip
certain whole drives, etc.

This script is still in early stages of development but is useful nonetheless.

SAMPLE OUTPUT
I got these numbers on a computer with 1GB ram and a 3 GHz CPU.

[D:\CMD]goog "'toad' & 'frog' & 'newt' & 'salamander'"

Search parms 'toad' & 'frog' & 'newt' & 'salamander'

Searching 13,055 files on drive C:
     1 hits

Searching 101,755 files on drive D:
     23 hits

Searching 5,184 files on drive E:
     0 hits

Searching 5,397 files on drive H:
     0 hits

Searching 0 files on drive S:
     0 hits

Searched: 8,192,894,820 bytes, in 125,391 files, in 13 minutes 6 seconds.
Found 24 files with search string(s) 'toad' & 'frog' & 'newt' & 'salamander'.
Largest file searched: 74,145,762



NOTE:  Before you use this script for the first time:
       go to line  4  and fill in the fully qualified name of the output file.

NOTE:  I'm sure there is a limit on the size of file that can be searched.  I have no idea
       what it is nor do I know what will happen when it is exceeded.   I DO know that
       I have successfully searched a file with more than 74,000,000 bytes in it.

NOTE:  This script assumes that the RexxUtil library is already loaded.

To use this script from the command line, build up the command this way:
first type the program name;

GOOG

There MUST BE DOUBLE QUOTES around the whole argument set.

GOOG  " "

If you forget them the script will APPEAR to run but will, in fact, be
truncated before the first Boolean operator and the OS/2 command processor
will use the rest of the argument string as system commands.
Really weird things can happen to your system depending on what strings
are in your search string, and you don't want  *ANY*  of them to happen
to your system, so
DON'T FORGET THE DOUBLE QUOTES.
If you do forget them it is best to cancel the run immediately, using CTRL+C.

Inside the double quotes each individual search string MUST ALSO be
enclosed in single quotes.

GOOG "'ginger'"
will find all files containing 'ginger'.

A string may have spaces in it.

GOOG "'bread and butter'"
will find all files containing the string 'bread and butter'.

You may have up to 6 search strings with operators between them.
You must use REXX's Boolean operators between the strings.  You may
use:

|   (for   OR)
&   (for   AND)
&&  (for   EXCLUSIVE OR)
\   (for   NOT)

GOOG  "'ginger' | 'bread and butter'"
finds all files with either or both 'ginger' and 'bread and butter'
in them.

GOOG  "'silver'  &  'gold'"
will find all files that have both 'silver' and 'gold' in them.

GOOG  "'silver'  &&  'gold'"
will find all files that have either but not both 'silver' or 'gold' in them.

You may also use the logical NOT operator:   It is a PREFIX or UNARY operator  and acts
on the following term to reverse its value (TRUE to FALSE) or (FALSE to TRUE).

GOOG  "'computer'  &  \'analog computer'"
will find all files that have 'computer' in them except for files that also have
'analog computer' in them.

The AND operator (  &  )  takes precedence over the  OR (  |  )  and exclusive or (  &&  )
operators.

GOOG  "'frog'  |  'toad'   &  'newt'  |  'salamander'"
will find all files with
'frog'  or
'toad' AND 'newt'  or
'salamander'
in them.

You may use parentheses to modify the operator evaluation order.

GOOG  "('frog'  | 'toad')  &  ('newt'  |  'salamander')"
will find all files with 'toad' OR 'frog'   AND   'newt' OR 'salamander'


___________
END OF FILE
