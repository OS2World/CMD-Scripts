------------------------------------------------------
Magic Draw UML 8.0 files for OS/2 Warp and eComStation
------------------------------------------------------



-------------------------
1. What is this good for?
-------------------------

These files allow you to start Magic Draw UML 8.0 Community Edition directly
from Workplace Shell. You don't need to open a command line window and type the
necessary commands. Just click on an icon. You can also start Magic Draw
directly from your command line.

Magic Draw UML is a Java program for drawing UML diagrams. Magic Draw UML
is a product of No Magic, Inc. See "http://www.nomagic.com" and
"http://www.magicdraw.com" for more details.


------------------
2. What do I need?
------------------

You need:
 - OS/2 Warp 4.x or eComStation with Rexx installed
 - Java 1.4 properly installed (either Golden Code or Innotek Java 1.4.x)
 - Magic Draw UML version 8.0 properly installed (= unpacked)


----------------------------
3. How do I use these files?
----------------------------

Follow these steps in order to successfully run Magic Draw UML 8.0
under your OS/2 (eCS) system:

1. Make sure you have Java 1.4 installed. You must have either ...\bin or
   ...\jre\bin directory in your PATH. Tested with Golden Code Java 1.4.1.

2. Go to "http://www.magicdraw.com" and download file
   "MD_UML_80_CE_no_install.zip". Unzip the file in an arbitrary directory.
   Several subdirectories will be created.

3. Move all *.CMD and *.ICO files from this archive to the "bin" subdirectory.

4. Run CreateWPSObjects.CMD. This script will make a folder on your desktop,
   containing a program object for Magic Draw.

5. You can use the alternate icon (MagicDrawUML2_OS2.ICO) if you don't like
   the default one.

6. Click on the program object to run its respective program.


-------------------------------------------------------------
4. Are there any differencies from the Unix/Windows versions?
-------------------------------------------------------------

Yes.

The Unix and Windows startup programs load JVM settings from an external file:
"mduml.properties". In the OS/2 version, these settings are hard-wired in the
startup script. So if you want to change the default settings, you must edit
"MagicDraw.CMD". But I don't think it will be necessary. Do NOT delete the file
"mduml.properties"!

Also, the OS/2 version implicitly does not use the X arguments. Since I was not
able to start Magic Draw with the MD-default value of X arguments (nor any
other value) I tried not to specify it and it worked very well.


---------------------
5. Who is the author?
---------------------

Jarda KACER, Czech OS/2 User Group
mailto:jkacer@kiv.zcu.cz
http://home.zcu.cz/~jkacer
