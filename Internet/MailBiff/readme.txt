 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³          MailBiff 1.01 copyright (c) 1995 by Terry Humphries             ³
 ³                            All Rights Reserved                           ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                READ.ME file -- read before installing                    ³
 ³        See end of document for contact info and license details          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


MailBiff is a shareware OS/2 Warp WPS aware mail notification utility.

This document explains how to install MailBiff. It explains command line
syntaxes and how to get the program(s) running. A separate document
(order.frm) tells you how to register MailBiff.

Caution you can not edit this Rexx command! If you do it will be disabled!

The license agreement and author contact info is at the bottom of the
file.


MailBiff 1.01 installation instructions:
==================================

   1. Unpack the MB*.ZIP archive in a private directory (UNZIP.EXE
      works nicely).  MB 1.0 requires its own home directory (FAT or
      HPFS, doesn't matter).

  2.  Run the provided MBCREATE.CMD (a simple REXX program) in that
      directory to build a WPS object for each POP3 mail server you have.

  3.  Double click on the new icon to start it.

Prerequisites
==============
You must have the rxsock.dll from the iak or Warp COnnect for this utility
to execute.

Command line Parms
==================
-server < name of pop3 server >
-user < your userid >
-pass < your password >
-refresh < how often to check for mail in seconds >
-wps will cause the wps icon to be changed to reflect the mail count
-detach will prevent the vio text window from displaying and will produce mb.log

Caution when you are testing your paramters from the command line do not include
the -wps switch if you do the wps icon for the command prompt will be changed!!

MailBiff isn't free, it's shareware:
===============================

To register MailBiff, fill out REGISTER.TXT and send to the mailing address
listed in it, together with the purchase price. Registration allows this program
to function more than 30 days after the initial installation. And provides a discount
on future registered versions.

Features for future versions include:
   - .wav file support
   - user specified icons
   - other mail protocols i.e. VIM, MAPI, SMTP, etc.
   - ...
I would appreciate any suggestions on these enhancements or any
other comments, concerns, etc you have about MailBiff.
Just email me with them!

                +----------------------------------------+
                |  IMPORTANT!  Read before distributing! |
                +----------------------------------------+

Simple license statement:
========================

You are granted a license to try this shareware program (MailBiff) for up to
thirty (30) days, after which you must register or discontinue its use.
Permission is granted to redistribute the unaltered shareware archive
for a reasonable (read nominal, small) copying charge (MailBiff may
specifically not be packaged with a commercial book without requesting
and obtaining permission (common courtesy -- remember, "copyright" means
literally "the right to control who copies the material").  If you write
a review on MailBiff, I'd certainly appreciate a courtesy copy of the
review.).  All rights are reserved by the author.  

There is NO warranty.  Support is NOT guaranteed to unregistered users.


Contact info:
============
  Terry Humphries ( thumphr@sky.net )
