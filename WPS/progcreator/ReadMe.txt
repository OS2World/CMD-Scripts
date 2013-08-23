        Program Creator version 1.22 Documentation       January 26th 1997
        ------------------------------------------

1. ABOUT

Program Creator is a REXX-program which creates program objects on the
desktop from any program file giving it the program's name without the
path and extension.


2. WHAT'S NEW IN VERSION 1.22?

   - Support for JAVA-programs (*.htm(l) and *.class).

   - Adds the working directory to all program objects.

   - Minor bugfixes.

   NEW IN v 1.21:

   - Fixed support for long filenames (with blank spaces).

   - Added support for SYS files.


3. INSTALLATION

- Unpack the file PRCR122.ZIP to a temporary directory using either PKUNZIP-
  or UNZIP-program.
- Start the installation program by typing Install at the prompt or by
  double-clicking the Install.cmd object.
- After the installation you should add Program Creators path to the
  'SET PATH' line of CONFIG.SYS if you wish to use the program from
  command line.


4. USAGE

The easiest way to use the program is to drag and drop a supported file
on the Program Creator icon. You can also make a program object at the
command prompt by typing CrProg and as a parameter the name of the
program file. E.g. 'crprog c:\temp\t.exe'. If you start the program
without a parameter or by double clicking the icon, it will display the
correct usage.

Supported file types are:

     Extension     Program object created for
     ---------     --------------------------
	EXE			<---
	CMD			<---
	COM			<---
	BAT			<---
	INF			VIEW.EXE
	TXT			E.EXE
	ME 			E.EXE
	1ST			E.EXE
	NOW			E.EXE
	DOC			E.EXE
        SYS                     E.EXE (for easy editing of config.sys)
	HTM			APPLET.EXE
	HTML			APPLET.EXE
	CLASS			JAVAPM.EXE

FOLDER SUPPORT:

Folders are also supported! If you drag a folder on Program Creator, it
will create a new folder on the desktop with the original's name. In the
new folder program objects for program files and important data files
(TXT, INF, 1ST, DOC, ME) will be created. This is especially useful for
program collections like FM/2 utilities.


5. THANK YOU

I wish to thank Mike Prager for sending me his modifications to support
INF files. Thus giving me the idea to support also other file types than
just program files.

Thanks also to Duncan Sargeant and David Cougle for bug reports and
suggestions for improvements.


6. LICENCE

Program Creator is FREEWARE so you can freely copy and distribute it as
long as you keep all the included files with it unmodified.
All comments, suggestions for improvements and donations are welcome.
If you like Program Creator, send me a postcard!
__________________________________________________________________________
Anssi Blomqvist                                  abblomqv@rock.helsinki.fi
Haapasaarentie 5 A 145
FI-00960 Helsinki
FINLAND
