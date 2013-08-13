My small REXX utilities

cr.cmd
Was made for gathering information from Master of Magic save games.
Usage: cr.cmd <savegame>.
If savegame was not set it uses save1.gam and outputs information to stdout.
You can rename it to .bat file and use it with PC DOS 7.0 REXX

dbf2txt.cmd
Converts .dbf files to plain text. Incorrectly works with files containing
records number more than 64K.
Usage: dbf2txt <DBFname.dbf>
Creates text file with database fields description and with all records up to
record number 65535 :) You can rename dbf2txt.cmd to dbf2txt.bat and run it
using PC DOS 7.0 REXX

df.cmd
Simply run it and you will receive information about your non-floppy drives :)
Something like this:
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄ cygni ¿
³ Disk ³ Volume label ³ Total space ³  Used space ³  Free space ³
ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³  C:  ³ SYSTEM       ³   261.90 Mb ³   115.23 Mb ³   146.67 Mb ³
³  D:  ³ OS2          ³   188.86 Mb ³   103.66 Mb ³    85.20 Mb ³
³  G:  ³ OS2VDISK     ³     0.71 Mb ³     0.10 Mb ³     0.61 Mb ³
ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

l2s.cmd
When started is looking for long file names. It means non-8.3 names.
Converts additional . to _, wide extentions to 3 characters...
Long file name is stored at EA .LONGNAME and can be seen at OS/2 DOS session
with Volkov commander 4.99 alphas - http://come.to/volkov

check\check.cmd
Due to slow I-net connection sometime I'm downloading one file several days,
72Mb of StarOffice, for example :) So, I'm running ftp from out HPUX server
and can't see progress of downloading from my OS/2 computer. This utility -
uses rxFTP.dll to connect to UNIX machine and to get current size of file.
Usage: check <host> <userid> <filename> [password]
host - is UNIX machine where is stored file you want to monitor
userid - is your login
filename - the name of file you want to check. You can use * at any place
of filename, but be attentive, otherwise you can choose wrong file.
password - you can set password at command line, but you also can skip it,
in this case script will prompt for password when starts.
In the same directory is stored icon file for check.cmd and ICONTALK.EXE - An
OS/2 utility that allows .CMD files to display messages on the title bar or
icon text.  THANKS A LOT, Doug Azzarito. - because I'm not sure you will find
it somewhere else. check.cmd uses it to output it's information to titlebar.
If you don't want this, simply delete lines with icontalk from check.cmd. 

clean\clean.cmd
clean\setup.cmd
Sometime it's necessary to clean TMP directory very often. clean.cmd do this,
but before using it you have to run setup.cmd to set directory and files for
cleaning, cleaning interval and AutoClean. AutoClean must be set ON! it's
used by PM version of this utility written by VX REXX, but PM clean also
requires vrobj.dll and I don't included it to this package. Maybe it's still
somewhere at hobbes as clean.zip :) If you want to remove all cleaner entries
from os2.ini, run setup.cmd /d.

crk\crkcat.cmd
.crk is file which is used to make small changes to binary files. Some files
are included to package. crkcat.cmd creates one file with description of all
.crk files, found in current directory

mp3list\names.cmd
mp3list\names.bat
It's something like crkcat.cmd, but for .mp3 files. It takes information from
.mp3 files and puts it to file. Requires list_file_name and correct directory
for this file. Please, set this directory right in script - out='g:\t\' you
have to replace with correct directory like c:\temp\. Don't forget backslash
at end! Output directory is important because very often .mp3 files are stored
at CD or network drive in read only mode, etc.
names.bat is the same program made for PC DOS 7.0 REXX. It requires additional
information - TEMP directory for it's files. You have to set it like out
directory right in program. Also there is small grep utility - I don't know
nothing about copyrights on it. This program or another grep is necessary for
work of names.bat. If you will use another grep, please change names.bat
according to your grep.

Common requirements: all .cmd files requires OS/2 REXX, .bat files can be run
with PC DOS 7.0 REXX.
df.cmd, l2s.cmd, clean.cmd + setup.cmd, crkcat,cmd, names.cmd -
requires rexxutil.dll
check.cmd requires rexxutil.dll and rxFTP.dll

Please, send bugreports and suggestions to cygnus@erriu.ukrpack.net