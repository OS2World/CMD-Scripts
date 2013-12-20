webautoz.cmd - Web Browser Auto-UnZip
Written by Timur Tabi
timur@io.com
http://www.io.com/~timur/index.html

This REXX script will take any file you download, create a directory
of the same name, and if it's an archive file (zip, gz, tar, etc),
it extracts the contents into that directory.  Then it opens a window of
the directory on the desktop. In other words, you can download a
zip file via a web browser, unzip it, and examine or use the contents
without ever using the command line.

Sorry, but there's no fancy installation - you'll have to do it by
hand.  I guess it's ironic that you need to use the command-line
to install a program whose sole purpose is to avoid the command-line.

WHAT'S NEW:

It now handles files of any type.  Files that can be extracted are
extracted, other files are simply copied as-is.  This works great
for .EXE files.

Also, this version doesn't copy the file to the download directory
anymore - it just uses whatever copy is in the TEMP directory.
This means you no longer have the option to not delete the downloaded
file, but it is now faster and uses less disk space.

PROGRAM INSTALLATION

1. Copy the program to where you normally keep REXX .CMD files or
other utilities.  It can be on the root drive (C:\), in the Netscape
directory (\NETSCAPE), in a directory where you keep utilities,
such as H:\UTIL2 in my case, or anywhere else.  It does NOT have to be
in a directory specified in your PATH variable.

2. Using a text editor, edit webautoz.cmd.  Go to line #5, it looks
like this:

        /* call directory 'h:\dl' */

Generally speaking, you probably want to keep all your download files
into a directory set aside for this purpose.  In my case, that directory
is H:\DL.  If you don't have such a directory, I recommend you create
one - it keeps your hard drive less cluttered.

3. So if you don't have such a directory, create it now.  Give it
whatever name you like.

4. Change the 'h:\dl' to whatever your directory is called.  For instance,
if you created a directory called "STUFF" on the D: drive, it would
now read:

        /* call directory 'd:\stuff' */

5. Remove the /* and the */.  It should now read something like:

        call directory 'd:\stuff'

6. Now, follow the instructions for whichever web browser you use.
I apologize for the instructions, they're not exactly that clear
when it comes to specifying which MIME types to update.


NETSCAPE NAVIGATOR FOR OS/2 SETUP

1. Start Netscape Navigator for OS/2.  Under the Options menu, select
"General Preferences"

2. Click on the "Helpers" tab.

3. Here is where you make an association between the *.ZIP files you
download and webautoz.cmd.  Unfortunately, there are two ways a ZIP
file can be identified, so you need to change two entries.  First,
look for an file type labelled "application/zip".  If there isn't
one, make one by pressing the "Create New Type" button, and entering
"application" for the Mime Type and "zip" for the Mime Sub Type. Then
press Okay

4. Now you have created and/or located the application/zip type.
Under the "Action" section, select "Launch the Application".  The
press the "Browse" button and look for webautoz.cmd.  Select it,
and then press Ok.

5. Now do the same thing for File type "application/x-zip-compressed".
This is the preferred MIME type for zip files, so in addition to
configuring to launch webautoz.cmd, it should also have the word
"zip" specified for the "File Extensions".

6. Repeat this for other file types, like application/x-gzip and
application/octet-stream.

7. You're all done setting up the File types.  Press the button labeled
"Ok".

WEB EXPLORER SETUP

1. From the Configure menu, select "Viewers..."

2. Click on the small arrow to the right of "Type" and locate the type
called "Zip PkZip format".

3. Press the "Browse..." button.  Locate and select webautoz.cmd.  Once
it's selected, press the button labelled "OK".

4. Do the same for other file types, especially "BIN binary file".

5. You're back in the Configure Viewers dialog box.  Press the "OK"
button.

USAGE

Now, whenever you download a file, it will be handled via webautoz.cmd.
If, for some reason there is a particular file you just want to download
and not have extracted, then you can hold down the Shift key while clicking
on the file (Shift-Click instead of just Click).  Unfortunately, this trick
only works in Navigator.  In WebExplorer, it's all or nothing.

Also, WebExplorer does not retain the name of the zip file - it creates
a temporary name.  So if you download PMN100.ZIP, instead of getting
a directory called D:\STUFF\PMN100 (for example), you'll get something
like D:\STUFF\0A00031.  Navigator does not have this problem.

And be careful that you don't download a file that you already have,
or that a directory doesn't exist that has the same name as the file
you're downloading.  For instance, if you already have D:\STUFF\PMN100,
and you download PMN100.ZIP, you might get junk in D:\STUFF\PMN100.

A great companion utility would be those WPS add-ons that give open
a command line window, set the corresponding directory, right from the
desktop.  These can be found in the /pub/os2/util/shell directory
on hobbes.  An example is cmdhr112.zip.  Between these two apps,
you'll never need to use the "CD" command again!
