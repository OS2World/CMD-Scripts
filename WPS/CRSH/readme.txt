Make Shadow Objects of recently used documents


Jan Stozek
jasio@polbox.pl


Have you ever envied the glassworkers (as Windows users are often called in
Poland), that they have direct access to the 15 most recently used
documents in the Start/Documents menu?  Well, I have.  So I wrote a set of
scripts to provide me with simillar functionality.  Please note, this is
_not_ a fully blown, automagic, GUI, self configuring, blinking and shining
solution.  Actually, it's not even a program.  It is rather an idea
accompanied by a tool and a few examples of its usage.  I made it as a
quick and dirty hack.  Since there is a non-zero probability that it might
be useful to someone else as well, I decided to distribute it.  So it's
definitely not fool-proof, actually it does not even check if all
parametres are correct.  Additionally, it will require some additional work
from you to adapt it to your particular configuration.  So, please, read
this readme thoroughly before running anything.  I know it's difficult and
boring.  I don't do it myself most of the time, unless something does not
work.  But please do, since most probably it _won't_ (WON'T!!!!  WON'T!!!!
WON'T!!!!)  work with your configuration right away.


0. Language Disclaimer

Although I made some efforts, that this readme file is written correctly,
and understandable, it's more than probable I made some - possibly many -
mistakes.  Please, excuse me if so.  English is not my native language and
it may happen, that the way I use it is disgusting for native speakers.


1. Legal stuff

Unless stated otherwise in specific cases, all pieces of code included in
the archive, wheather signed or not, have been written by me (Jan Stozek)
and are distributed under GNU Licence version 2, cited in a file named
"License".  The scripts are free for personal (home) and educational
(schools and universities of all types, _excluding_ commercial services
provided by them for third parties, such as industry) use, yet copyrighted.
All other users should contact with author before using on a regular basis.

The scripts are provided "as is", without any warranty, expressed or
implied.  I explicitly refuse to take any responsibilities for any results
- weather direct or indirect - resulting from executing them.  To make long
thing short:  whatever you do with those scripts - execute, rewrite or
trash - you and only you are responsible for the results.


2. Contents:

	fileid.diz	- obvious; short program description
	License		- obvious; GNU License version 2
	FindLatest.cmd	- 4OS2 script finding 15 latest files in directory trees given as parametres
	MakeLast20.cmd	- usage example: make shadows of 20 recently created files
	MakeShadow.cmd	- main workhorse in REXX
	MakeTodays.cmd	- usage example: make shadows of up to 50 files created
                          today (and, actually, yesterday)
	readme.txt      - this file


3. Prerequisits

MakeShadow requires OS/2 with Rexx support enabled.  I use it
with Warp 4 PL, but it should work with any other version as well,
unless there have been changes in Rexx influencing functions or structures
used in the script.

FindLatest, MakeLast20 and MakeTodays require 4OS2 command processor by JP
Software.  If you don't and don't want to use 4OS2, you can treat them as a
brief, demonstration of its capabilities and a source of inspiration. Since
their job is to feed MakeShadow, you can replace them with any other
scripting tools of your choice, such as Rexx or Perl, or even a high level
language program.  Actually, if someone makes a working Rexx replacement
for those files, I will be happy to include them in the archive.

Finally, FindLatest.cmd currently uses qsort, plain old DOS sorting
program.  This is because OS/2 SORT.EXE has a completely idiotic and
anachronic size limit of 64K per sorted file.  I noticed two OS/2 native
programs of this kind on Hobbes (bigsrt44.zip and jsort13.zip), but since I
have not used them yet, I didn't want to make dummy calls to them.  This
should not be a problem, though, since most probably you will have to write
your own control scripts anyway.


4. Installation

There is no specific installation automation routine. Installation consists
of four steps.

        a) copy all necessary files to a directory located in the path
        b) tailor the scripts (FindLatest, MakeLatest20 and MakeTodays) to
           your needs
        c) create necessary target directories
        d) create objects for running batch files, if needed


5. How does it work

The main powerhorse is MakeShadow.cmd.  It accepts three parameters:  fully
qualified name of the file you want to make shadow of (and /B or /S, which
is explained in detailes later on), the fully qualified name of the
directory you want the shadow object to be put in and the shadow object ID.
Theory says, you should be able to supply the respective object IDs instead
of their names, but this has not been tested.  One thing is for sure -
if you try, you have to quote angle brackets in the object IDs, since
they are interpreted as redirectors by the shell.  The script returns exit
code equal to the number of objects succesfully created (or 0 if for any
reason no objects have been created, which seems to be quite logical).  Be
aware, that shadow object IDs - as object IDs - are system wide, not
directory wide.  This means, it may happen, by creating shadows in one
folder, you can actually delete something - not necessarily a shadow - in
another folder.  So please, be _very_ _very_ _very_ careful in selecting
object names and make sure they are unique.

The script has three main modes of operation:  regular, batch and script,
distinguished by the first parameter. If it is a filename, script is run in
regular mode, /B means the batch mode and /S - the script processing mode.


Regular mode

In the regular mode the script creates a shadow of a single file, given by
the first parameter, in a directory given as the second parameter, using an
object ID provided as optional third parameter.  Both file name and
directory name should be fully qualified.  Watch out, the shadow object ID
passed as the third parameter MUST NOT contain angle brackets.  They are
appended internally, within the script.

The script tries to process two special cases, regarding file and directory
names:  filename without a path is treated as located in the current
directory and a target directory name beginning with a dot (including the
dot alone) is treated as a relative to the current directory.  This is
regular system convention.  No further name processing is done though -
MakeShadow was meant to be called from other scripts or programs rather
than from the command line, and then it's pretty easy to provide fully
qualified file names.

If no object ID is given, the default value is used, equal to the fully
qualified file name.  MakeShadow never makes an object with a random ID,
which is the system default.  This way you can easily delete the shadow
with another script or identify it with object managers, although - as a
side effect - you cannot create two shadows of the same file without
specifying object ID (you can do it in batch and script modes, when object
ID is processed differently).  Please note, object ID is an internal
object name, used by the Presentation Manager for managing objects.  This
is _not_ the name you see on the desktop.  In case of shadows, the latter
is _always_ the same as the title (equal to filename in case of files) of
the object pointed to by the shadow.

So:

MakeShadow C:\Autoexec.bat C:\Desktop Test

will create a shadow of the C:\Autoexec.bat in the directory C:\Desktop
(which in English OS/2 versions is a desktop directory) with the internal
object ID 'Test'.  While:

MakeShadow C:\Autoexec.bat C:\Desktop

will do the same, but the internal object ID will be 'C:\Autoexec.bat'.


Batch mode

Batch mode is recognised by the /B switch used as the first parameter, in
place of the file name.  In this mode names of files you want to make
shadows of are read from standard input, one in a row.  There is also a
significant change in a way object ID is interpreted.  It does not mean
actual object ID any more, but a "root" ID instead.  The actual ID for each
object is computed by appending an object number within the batch to the
"root" name.  The second change is that the default "root" object ID equals
to the target directory name (just the name, no path) rather than the path.
So:

dir /f C:\ | MakeShadow /B C:\Desktop Root

will make shadows of all non-hidden files and directories placed in the
root directory of C:  drive (usually autoexec.bat, config.sys, readme.os2,
several config.sys backups, popuplog) in the C:\Temp folder.  Newly created
objects will have the names of Root1, Root2, Root3 etc.  While:

dir /f C:\ | MakeShadow /B C:\Desktop

does the same, but shadows will have IDs Desktop1, Desktop2, Desktop3 etc.
Please note, whole C:  drive will not be scanned.  Rather whole directories
(with C:\Desktop included) will have their shadows created on desktop.  If
you want to make shadows of all the files on the C:  drive you should feed
MakeShadow with "dir /f /s".  This would end up with a big mess though,
since all the files on the C:  drive would have their shadows placed flat
on desktop, along with the shadows of all directories and subdirectories.
Also, since Presentation Manager has not been optimised for batch object
creation, you may have to wait until the Judgment Day until the command has
completed.


Script processing mode

Script processing mode is recognised by the /S switch as the first
parameter.  It is similar to the batch mode, but the data read from stdin
are treated as a sequence of commands rather than file names by themselves.
Both target directory and object ID should be defined by the script
commands.  Please note, although object ID still defaults to something
usable, target directory name must be defined explicitly.

MakeShadow recognises following script commands:

#               - every line with # as the first character is treated as a
                  comment

CD dirname      - defines the target directory name.  Please note, this
does not change the process current directory (in the OS terms), just
defines the name for the target directory.  This is exact equivalent of the
second MakeShadow command line parameter in other modes.  It can be
redefined multiple times - each name is valid until another CD command.

Please note, target directory is mandatory for DATA command, while it's not
required at all by the DEL command.

ROOTNAME name   - defines the root shadow object ID.  This is exact
equivalent of the third MakeShadow command line parameter in other modes.
It can be redefined multiple times within the script.  Each name is valid
until redefined.

DEL param       - deletes objects.  Please note, this is potentially
dangerous command, since you can delete _any_ object in the system.
Please, do it with care.  Please also note, DEL deletes objects by their
objects IDs, not by the file names.  This means, neither current nor target
directory influence this command.  Param defines object(s) to be deleted,
in the following way:

* <object_name>                 - named object is deleted
(including angle brackets!)

* number (for example 10)       - ROOTNAMEnumber (ROOTNAME10 in this case)
                                  object is deleted

* number+ (f.e. 10+)            - ROOTNAMEnumber (f.e. ROOTNAME10) is
                                  deleted, then the number is incremented
                                  in a loop and consecutive objects are
                                  deleted (ROOTNAME11, ROOTNAME12...),
                                  until failure.  So, if you have
                                  objects 1,2,3,4,5,10 and issue DEL 3+,
                                  objects 3, 4 and 5 will be deleted.
                                  Object 10 will be preserved, because DEL
                                  6 fails.

* number + (f.e. 10 +)          - same as the above

* ALL                           - ROOTNAME object is deleted, followed by
                                  DEL 1+. This may end up with the target
                                  directory deletion (if its object ID is
                                  equal to the ROOTNAME), so use it with
                                  care.

* number1 number2               - all objects with numbers between
(f.e.  5 1000000)                 number1 and number2 inclusive are deleted
                                  (ROOTNAME5, ROOTNAME6 ...
                                  ROOTNAME1000000).  No error codes are
                                  checked, so it won't stop on
                                  nonexistant objects. This way you
                                  can remove remainings after failed tests
                                  or make sure no spare objects are left.

DATA            - triggers object creation. This command is potentially
dangerous, since objects with conflicting names are silently replaced. This
should not mess up any system objects, since they usually do not contain
trailing digits, but may clear up shadows created earlier, even in
different directories.

All the following lines in the script contain names of the files you want
to have shadows of, one at a time.  Actually, this is equivalent to the
batch mode (and is even processed by the same code), with some values
predefined by the preciding script commands. File names are read until the
end of the file or a single dot character is encountered. In the latter
case MakeShadow returns to command processing, so that you can define new
target and rootname and create or delete some more objects.

After every DATA command, object counter is always reset to 1, with two
side effects:  if you define a ROOTNAME already used, you may replace some
shadows just created with new ones - even, if they have been created in
another folder - probably with different logic in mind.  Also, exit code
informs only about the number of the shadow objects resulting from the
last DATA command only.  This may be changed in future versions though.

. (dot)         - end of DATA and return to command processing

QUIT            - terminate MakeShadow immediately.  Since there is no
conditional logic implemented, this simply means, the following part of the
script will not be processed.  I included it purely to ease debugging.
Please note, QUIT is only recognised in the command state.  If you want to
terminate object creation (DATA command) prematurely, you should issue a
dot (.)  command to return to command processing state first.

That's all. As you see - no real magic.


6. What does it work for

As you might see from the above, MakeShadow is not especially clever by
itself.  It does not make much more than creating shadows of the files
given as parametres or piped to its stdin.  The real inteligence and
usefulness is included in a way MakeShadow data is created.  Using
MakeShadow I mimicked Start/Documents functionality in two ways:  finding
15 documents most recently updated and finding up to 50 documents updated
today or yesterday.  You can mimic some functionality of the Toronto
Virtual File System, creating shadows of selected directory trees on
different drives in a common directory (will work pretty well, unless you
need virtuality on a file system level rather than on WPS level).  You can
write a better file finder.  You can...  eh!  you can write almost
anything, as long as you can output a list of fully qualified file names,
matching certain conditions.

I included a couple of scripts as a kind of demonstration.  They require JP
Software's 4OS2 command processor to run (this is an enhancement and
replacement of CMD, compatible with 4DOS and 4NT command processors for
other OS-es).  You can implement those same ideas in a scripting language
of your choice.  I decided not to do it for you for two reasons:  CMD is
too poor for these tasks, I cannot bet, everybody is using Perl, while I
don't feel good enough in Rexx to use it for the file system tasks.
Besides, these scripts work for me, with my particular set of directories,
while you would have to modify them heavily anyway, to accomodate to your
configuration and needs.

a) FindLatest.  This is a simple script printing %FileLimit% (default = 15)
recently used files in directories (actually - filemasks) given as
parametres.  %Filelimit% variable should have already been defined in the
environment, if you need value other than default.  This script is actually
used by the following two, to make a dirty job of traversing through the
file systems.

All parametres (up to 127 in case of 4OS2) are passed in the original order
directly to the DIR command.  In my example DIR makes a list of fully
qualified filenames (/F) excluding dot and double dot directories (/B), and
backups (/[!*.ba?]) in whole trees (/S).  It will include regular
directories though.  Then, every entry is added a date and time of its
last modification (%@FileAge) in front of the file name and the whole list
is saved in a temp file.  The latter is only because I used DOS sorting
program - otherwise I could simply extend the pipe.  From the first
%FileLimit% lines of the sorted temporary file (meaning %FileLimit%
recently updated files) file names are extracted and echoed to the stdout.
Finally, empty lines are removed (I could do the same implementing some
conditional logic, but I'm rather lazy).  All error messages which would
possibly spoil the resulting list are sent to hell.

b) MakeLast20.  This one is pretty simple.  It uses FindLatest to create
the list of 20 most recently modified files in my primary working
directories, and feeds it to MakeShadow.  Before that, objects exceeding
the file limit are removed - just in case you have recently played with the
file limit, since normally it's not needed at all.

c) MakeTodays.  This one is simple as well and pretty simillar to the
above, but uses an additional trick.  The script lists up to 50 files
modified today or yesterday (/[d-1]) on disks D:\ and E:\ (they are my data
drives), _except_ for E:\Mail directory, where my email, news and a web
cache reside.  The trick with backquotes inserts and additional FIND
pipe right after the DIR statement in FindLatest, effectively making the
whole subtree remove, before any further processing is made, including time
stamping and sorting.  Since the number of modified files may be different
every day (ranging from 0 to 50 in this case), all existing shadows are
removed before new are created.


7. Sample installation (mine, actually)

On my system all of these scripts are placed in a directory listed in the
PATH environment variable.  Folders for shadow files have been created
somewhere in my data directories and their shadows are placed on desktop,
so that they are listed in the warpcenter menu.  Actually, since they do
not contain regular files, they could have been placed on the desktop right
away.  Directory names begin with the exclamation mark (!), so that they
are sorted out at the very beginning of the menu.  In both directories
there is a program object created, effectively calling respective
batchfile.  This way I can always easily recreate objects on demand.  Also,
the shadows of these objects are placed in the Autostart folder, so that
they are recreated during every system start.  I examined the need to call
any of the scripts in CRON or another task scheduler, but finally decided
it would be an overkill.  In my environment there is no need for that.


8. Known bugs, problems etc.

Due to the way Rexx parses the command line, MakeShadow parametres must not
contain spaces, even if the respective parameter is double quoted.  Piped
file names can contain spaces, since no Rexx parsing is ever done on them.


9. Contacting the Author

If you have any suggestions, comments or bug reports, please let me know.

Name:  Jan Stozek
Email: jasio@polbox.pl
