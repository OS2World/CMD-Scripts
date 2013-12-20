The os2jobj.zip file contain some routines, icons, and text to make 
life a little easier on OS/2 and Windows 95 with the J Street Mailer
and to install Innoval's anyClient, the Hot Java Browser from Sun, and
a shareware program called Family Tree for Java.  You need to copy
os2jobj.cmd, os2jobj.ini, and the appropriate icon to the base directory
of the product you want to install.

spam.txt
   This is a copy of the Post Road Mailer prmblams.cfg that can be used
   to build a "list" filter for filtering spam messages.

jsmicons.zip
   A collection of gifs and icons contributed by the users.

OS/2:

   These little REXX programs are designed to install a program object 
   for running J Street Mailer on your OS/2 system, and converting address
   books for importing into J Street Mailer.

   os2jobj.cmd

      Note that the default icons can be replaced with icons of your
      choice.

      You will be prompted on whether or not you want to disable the JAVA 
      JIT compiler.  The default is no, but yes is recommended for 
      testing.

      Updates to your CONFIG.SYS are not required, but if you have placed 
      the necessary definitions in your SET CLASSPATH= statement, they 
      will be honored.

      If you should remove change any in the SET CLASSPATH= parm in your
      CONFIG.SYS, you will need to run the os2jobj.cmd again to update 
      the program object.

   prm2jsm.cmd

      This is a hack of the adr2asc.cmd that produces a CSV file that can 
      be imported into a J Street Mailer address book without making any 
      manual changes.  The first line of the output file contains the 
      field definitions for J Street Mailer address books.  Start the
      import, line up the field names, skip the current record (the
      header), and then import all.

   pmm2jsm.cmd

      Converts a PM Mail address book to a J Street Mailer address book.

   nsdde11.zip

      Netscape DDE interface by Ulrich Mouller.

   sndnotes.zip

      A routine for converting Post Road Mailer folders to J Street
      folders (from http://www.innoval.com/archive.htm).

Windows 95:

   Windows 95 Installation:

      Download and install the latest Java Runtime for Windows 95:

         Go to http://java.sun.com/ and navigate to the latest Windows 95 
         JRE (minimum installation works fine).  Install to its own 
         directory (C:\JRE11).

      Unzip the jstreet.zip file into its own directory (C:\JSTREET
      recommended).  Be certain to ask that all of the sub-directories be
      created.

      Create a shortcut to J Street Mailer:

         Naviagate to the JRE directory and create a shortcut to JRE.EXE 
         on your desktop.

      RMB the shortcut and "Rename" it to "J Street Mailer".

      RMB the shortcut and select "Properties".  Select the "Shortcut" 
      tab. Update "Target" to add the following after the 
      C:\JRE11\JRE.EXE:

-cp c:\jstreet\innoval.jar;c:\jre11\lib\classes.zip; innoval.mailer.jstreet

      Update "Start in:" to read:  C:\JSTREET.

      Select "Change Icon" and navigate to the w95instl.ico.

      Hit OK to save.

      You should be ready to run.
