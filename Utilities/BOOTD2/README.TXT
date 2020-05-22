README.TXT for BOOTDISK.ZIP

COPYRIGHT
All files in this archive are copyright 1994 by James K. Beard,
CIS 71675,566 or GENIE J.K.BEARD.  Portions of some of the
REXXfiles may be subject to prior copyright.  These files
may not be sold.

LICENSE
You may distribute freely all files in this archive as a
single unit.  Except as given below, you may not distribute
any material separately.  You may incorporate all or part
of the REXX files in your own programs if you credit the
authors and release them from all liability from any use
of your programs by anyone.  All PROCEDURE modules are
copyright by James K. Beard only.  If you wish to
incorporate this material in your own work for sale or
other distribution, please contact James K. Beard and/or
the other contributors of this materialas mentioned in the
comments for written permission; the terms will probably
include a release of all liability by you and not much
else.

WARRANTY
There is absolutely no warranty whatsoever on any of these
files, specifically the REXX programs BOOTD210.CMD and
BOOT211.CMD.  These programs have seen limited testing on
the personal property of James K. Beard.  Any suitibility
for any purpose is determined solely by the user.  The user
bears sole responsibility for any losses incurred due to
his use of these programs or any part of these programs.
You are advised to test these programs on your own
equipment thoroughly before relying on the results.

THE PROGRAMS
BOOTD210.CMD is a bug fix on BOOTDISK.CMD.  On dual boot
systems, the older program would use the DOS FORMAT.COM
and other utilities.  Cosmetic improvements are also
included.  I did limited testing of this program, since I
have applied the Service Pack to my machines.  Please
test this program thoroughly on your 2.10 system before
you rely on it.

BOOTD211.CMD is a major revision.  The files in OS/2 2.11
are fewer but bigger than those in 2.10, so the mapping
of the files onto the disks was revised.  Support was
added for CD-ROM.  The BASEDEV drivers are now taken
from your CONFIG.SYS file on your boot partition and
modified to load the drivers from A:.  Ther is also
improved supportfor systems with a 3.5" A: drive, and
which use third-party driver support.  On my system,
(5.25 A:, 3.5" B:) this program generates a two-disk boot
which supports SCSI, HPFS, third-party drivers for my
Always IN-2000 SCSI card, and my Toshiba 3301E CD-ROM.
There is about 250K of space left.

The secret of BOOTD211.CMD is the use of a very small
KEYBOARD.DCP file on the Service Pack Disk 2.  Without
it, there would not be enough room.  That file, and
SYSINSTX.COM are the only files obtained from the
Service Pack diskettes.  Everything else is taken from
your OS/2 boot partition.  The program stores these two
files in \OS2\INSTALL\BOOTDISK and gives you the option
to leave this directory instead of erasing it on exit; if
you leave it, you can run BOOTD211.CMD without the
Service Pack disks.

With OS/2 2.11, do NOT issue the command "EXIT" from the
command line.  Unlike earlier versions, CMD.EXE will exit
with no reentry to another call to CMD.EXE, and you are
left with a dead keyboard.

If you want REXX support, sound card support, or other
things you may have room for, you can copy files from
your OS/2 partition and edit the CONFIG.SYS file.  If you
have two 3.5" drives, you may want to do this.  If you have
2.88 MB floppy drives, you may even want to get a WPS on
boot.  Let me know what your experiences are if you choose
to experiment beyond what is provided in these programs.
EMAIL, CIS:OS2USER, CIS:OS2SUPPORT, and the GENIE OS/2
Roundtable are good places to contact me.  Others,
mentioned in the comments and in general, will also be
interested in your experiences.
---Jim Beard---
