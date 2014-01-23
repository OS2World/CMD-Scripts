
OBJST version 1.0- Start Dos and Windows viewers from Web Explorer!
-------------------------------------------------------------------


Files included
---------------

MAKEFILE, MAKEFILE.DEP:   for IBM's C/Set++ (v2.0).
viewst.cmd:               REXX template for starting the viewer.
objst.exe:                program which starts the viewer
objst.c:                  code for objst.exe
readme.txt:               this file


Description and Instructions
----------------------------

   This program, objst.exe, can be used to start Windows and Dos based
viewers easily from Web Explorer.  It can also be used to start OS/2
viewers.  There are 2 problems it solves, the first is that WebEx won't
easily pass any command line arguments to the program, besides the filename.
You can use this method of starting viewers to do so.  Secondly, for
Windows and Dos programs, there hasn't been a way (AFAIK) to define
any DOS Settings, for example, how much memory, to start the Windows
program seamlessly, to start it in Enhanced Mode, etc.  To tackle these
problems, objst.exe will in fact open a program object you have created
on your desktop.

1) You should put objst.exe somewhere on your path (though not necessary,
   just change the REXX file, which you have to do anyway).

2) For each viewer you plan on starting this way, make a program object.
   If you already have a program object for a viewer, great, but you 
   should make a copy of it.  The Parameters field on the first page
   will be overwritten (and not erased), so it shouldn't be the same
   object you use for general purposes.  Make sure the Working Directoy
   field is empty.  don't use a shadow of an existing viewer either (and
   don't copy a shadow, this just make sanother shadow).

3) For each viewer you will need to make a REXX .cmd file.  I have included
   one, which you should make copies of and modify.  The REXX is documented,
   please read it.  WebEx will call this REXX .cmd file, and pass it the 
   filename for the viewer to view.  Basically, the REXX does the following:

   a) Copies the file passed to it (????????.tmp) to ????????.brl (brl
      are my initials).  Why does it do this?  Well, when the REXX script
      ends, WebEx will delete the .tmp file, and it will be gone before
      the viewer can view it.  So, we must copy it before WebEx deletes
      it.  However, this will litter your temp directory with .brl files,
      which must manually be deleted.  Make a .cmd file wich does something
      like "del %temp%\*.brl", and make a program object which calls it.
      Then, you can call it whenever WebEx isn't using a viewer, you can
      put it in your startup folder, etc.  In fact, I have my temp
      directory completely deleted everytime upon bootup.

   b) It then calls objst.exe.  The first argument passed is the "object
      handle" (more on this later) of the object to start.  After this, any
      command line arguments, and the filename to view, can be passed.
      My REXX script (viewst.cmd) documents this.  objst.exe is the
      executable which tells OS/2 to open up the program object.

   c) Object handles.  How to get them?  I only know of one way, a freeware
      program called FeelX.  Find it at:
         ftp://ftp-os2.nmsu.edu/os2/unix/feelx11a.zip.
      Install it (install the WPS object too!).  To get the object handle,
      just drag and drop the object in question onto the Feelx WPS object.
      The object handle will automatically be placed in the clipboard.  It
      is just a number (an integer, I think always 6 digits long).
      FeelX does many other things too, I find it one of my most
      indispensible OS/2 programs.

4)  Ok, so the REXX script is set up to open the program object.  You could
    try it out now from the command line if you'd like.  You should probably
    put it somewhere on your path, but again I don't think this is necessary,
    you can specify the full path in the Web Explorer.

5) Start Web Explorer.  Go to configure the viewers.  Have it call the
   REXX file you just created.  If you need to edit your extmap.ext and
   mailcap.cap files for this viewer, just call the REXX file followed by %s.
   Volia!  You should now be able to use the Dos or Windows based viewer.

I hope this isn't confusing.  Here's a more specific example.  Say you want
to view Quicktime movies.  You have Quicktime for Windows 2.0 installed,
and can use the Windows Media Player applet to watch them.  But, you want
Web Explorer to load them up also.  First, you'd go make a new program
object for the Windows Media Player, setting the Dos Settings as necessary.
Then you'd copy the sample REXX file to, say, qtw.cmd.  You've installed
FeelX, so you can get the object handle.  Edit qtw.cmd, and put the correct
object handle on the last line.  Finally, in Web Explorer, configure the
Quicktime viewer to call qtw.cmd.  Now, when WebEx gets a quicktime movie,
it will load it into the Windows media player applet.  You can give the
media player as much memory as you'd like, make it seamless, separate
session, or fullscreen as you please.  You have the full power of OS/2's
program objects at your disposal to define exactly how you want the viewer
to run.


Disclaimer
----------
Use at your own risk.


You are free to look at the code, see how it works, and use it for whatever.
It is actually quite trivial.  If you make any changes, email them to me,
and I will see about including them in an updated version.  Feel free to
email if you have any ideas for enhancements, or a bug report.  You are free
to redistribute this archive, but it must remain unchanged.  This program
is freeware.



Brian Landy
blandy@ucsd.edu