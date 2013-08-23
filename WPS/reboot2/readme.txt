
                           Reboot/2 V1.01 Readme
                           =====================

Contents
========
1. What is the Reboot/2 package for ?
2. Install and usage of Reboot/2
3. Prerequisites/Restrictions/Limitations
4. Freeware license
5. Disclaimer
6. Check the archive integrity with
   Pretty Good Privacy (PGP)
7. Author




1. What is the Reboot/2 package for ?
=====================================
This package creates a WPS folder, from from which you can
directly reboot to all bootable partitions directly, without
invoking the Bootmanager Menu.

IMPORTANT ! IMPORTANT ! IMPORTANT ! IMPORTANT ! IMPORTANT !
----------------------------------------------------------------
OS/2 Bootmanager/SETBOOT.EXE do the real work, thus no
application shutdown is made, but file-system shutdown only !

Before invoking such a reboot, all applications should be closed
or at least all unsaved data should be saved,

  OTHERWISE UNSAVED DATA IS LOST !!!!




2. Install and configure Reboot/2
======================================

The package comes with the following files

readme               - you are reading this file
history              - release history
file_id.diz          - package description file
wpsinst.cmd          - generates the reboot folder
*.ico                - some icons for the generated reboot
                       objects

Unpack the files of this package to a separate directory on your
hardisk. Then run INSTALL.CMD to query all bootable partitions
on your system.
It creates a WPS folder with one icon for each bootable
partition. If you execute one of these icons and press enter,
SETBOOT.EXE is executed to OS/2 shutdown *IMMEDIATELY*
(no application shutdown, only file-system shuttdown) and the
appropriate partition is booted directly by bypassing the boot
manager menu.

Note:
   - Before executing a reboot, close all applications or at least
     save all unsaved data, OTHERWISE UNSAVED DATA IS LOST !!!!


The Reboot/2 folder is created in the OS/2 System folder and a
shadow of it is placed onto the desktop.

Whenever you change the names ot the partitions or add to or
delete partitons from the Bootmanager menu, run the program icon
to let Reboot/2 recreate the reboot icons and to delete obsolete ones.



3. Prerequisites/Restrictions/Limitations
=========================================

This package requires the OS/2 Bootmanager being installed.



4. Freeware license
===================

This software package is freeware.
It can be used wherever you use OS/2 2.x or later.

You are allowed to freely use and distribute Reboot/2 as
long as

 -  Reboot/2 is not sold as a part of another program
    package;
 -  no fee is charged for the program other than for cost of
    media;
 -  the complete package is distributed unmodified in the
    original and unmodified zip file;
 -  you send me some e-mail telling me how you liked it (or
    didn't like it), and/or your suggestions for enhancements.



5. Disclaimer
=============

Since this program is free, it is supplied with no warranty,
either expressed or implied.

I disclaim all warranties for any damages, including, but not
limited to, incidental or consequential damage caused directly
or indirectly by this software.

All software is supplied AS IS. You may use the Reboot/2
package only at your own risk.

Reboot/2 must not be used in states that do not allow the
above limitation of liability.



6. Check the archive integrity with
   Pretty Good Privacy (PGP)
===================================

On my homepage I provide a detached signature certificate,
with which you can verify, that you downloaded an unmodified
version of this archive.

See my web pages also
- for links to PGP sites, where you can obtain further
  information on what PGP is and how you can install and use it
  under OS/2
- a manual for how to use PGP for the usage of such signature
  certificates.

See section "Author" for the location of my homepage.



7. Author
=========

This program is written by Christian Langanke.

You can contact the author via internet e-mail.

Send your email to C.Langanke@TeamOS2.de

You can also visit my home page and download more free OS/2
utilities at:

     http://www.online-club.de/m1/clanganke

