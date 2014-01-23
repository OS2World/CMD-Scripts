                          README file for QWIKLIST

This file may be freely distributed in accordance with the license agreement
at the end of these instructions.  (The lawyers made me include it).

Instructions:
-------------

The most often asked question about WebExtra is:  "Can I convert my
WebExplore QuickList to a bookmark file?  Yes -- in less than five minutes.
You can then organize your entries among different books within WebExtra
or, externally, with a text editor.

This is a simple REXX script for converting a WebExplorer QuickList to a
WebExtra bookmark file.  You do not need to know anything about REXX to use
this utility.  Just follow the instructions below.

Instructions for editing bookmark files and archive lists with any simple
text editor are included.


     1. Close WebExtra

     2. Copy this REXX Program (qwiklist.cmd) into your WebExtra books
        directory.  For example:

           COPY QWIKBOOK.CMD E:\WEBEXTRA\BOOKS\QWIKBOOK.CMD

     3. Find your EXPLORE.INI file.  You can use the directory search
        command to find the file.  For example, from the root directory of a
        drive enter:
      
           DIR EXPLORE.INI /S

     4. Run QWIKLIST as follows with the full path of EXPLORE.INI:

           QWIKLIST C:\MPTN\ETC\EXPLORE.INI

                   The result is a file called QWIKLIST.BM
                   ---------------------------------------

     5. Launch WebExtra. Open the Quick List Book and select a URL. The
        page will be loaded by the WebExplorer.


Editing WebExtra Book Files:
----------------------------

Entries in the bookmark files are a result of selecting a bookmark icon and 
double-clicking on it when viewing a page. You can also add a bookmark after
the fact from the jump list or from one of the monthly archive lists of 
URL's. You can also use WebExtra functions to move and copy entries between 
bookmark files.

Because the format of bookmark files is so simple, many people have 
discovered that they can edit and reorganize bookmark files with a text 
editor. Here is what you need to know.

     A. The first line is a very brief description of the book followed by a
        spade symbol and the name of an icon.  The spade symbol can be typed
        into a line by holding down the Alt key and typing in 0 0 6 on the
        numeric keypad.  The name of the icon for the book can be one of the
        icons in the WebExtra icons directory or it can a full path to any
        icon on your system.

     B. Entries for URL's are simply the name of a web page (or any text you
        prefer), a diamond symbol, the exact URL, another diamond, the date
        in MM/DD format, a third diamond, the time in HH:MMxm format, and a
        final diamond.  The diamond can be entered by holding down the Alt
        key and typing in 0 0 4 on the numberic keypad.

     C. Bookmark files can have any name but they must have a file extension
        of BM. For example: MYBOOK.BM

The following is an example of a WebExtra bookmark file.

Quick List  darkcyan.ico
InnoVal Systems Solutions  http://www.aescon.com/innoval  06/07  7:27pm 
Release 2.0 Beta  http://www.aescon.com/innoval/prodplan  06/07  7:27pm 
Indelible Blue  http://www.indelible-blue.com/ib  06/07  7:27pm 
OS/2 e-Zine!  http://www.haligonian.com/os2  06/07  7:27pm 

For more information about WebExtra see http://www.aescon.com/innoval
---------------------------------------------------------------------


                  InnoVal Software License Agreement
                  ----------------------------------

This License Agreement applies to an InnoVal computer program called
QWIKLIST.CMD (hereinafter referred to as Software).

This Software is licensed not sold.  InnoVal Systems Solutions, Inc.  grants
you a license for the Software in the country where you received the
Software.  You obtain no rights other than those granted under this license.

The term Software means the original and all whole or partial copies of it,
including modified copies or portions merged into other Software.  InnoVal
retains title to the Software.  InnoVal owns the copyright for the Software.

You are responsible for the selection of the Software and for the
installation of, use of, and results obtained from, the Software.

1.   License

     Under this license, you may:

     a.   use the Software on one machine at a time.

     b.   transfer the possession of the Software to
          another party by transferring a copy of the
          Software and a copy of this license. If you
          transfer the Software you must not retain any
          copies. Your license is then terminated.

     c.   provide a copy of the Software to another 
          party and/or place a copy in a software
          repository. If you do so you must include
          this license agreement and any documentation.
          This clause only pertains to the program for
          which this license applies. This clause does 
          not pertain to any other software required to
          use or to make use of the Software.
          

     You may not:

     a.   use, copy, modify, merge, or transfer copies of
          the Software except as provided in this license;

     b.   reverse assemble or reverse compile the
          Software; or

     c.   sublicense, rent, lease, loan or share your rights
          to the Software except that members of one
          family living together may share one copy of the
          software at one residence.


2.   Limitation of Remedies

     InnoVal will not be liable for any lost profits, lost
     savings, or any incidental damages or other economic
     consequential damages that may arise from the use of
     the Software even if InnoVal, or an authorized
     supplier, has been advised of the possibility of such
     damage. InnoVal will not be liable for any damages
     claimed by you based on any third party claim.


3.   General

     The license granted to you is effective until
     terminated. You may terminate this license at any
     time if you destroy all copies of the Software. 

     If you acquired this Software in the United States, this
     license is governed by the laws of the State of New
     York. Otherwise, this license is governed by the laws
     of the country in which you aquired the Software.

                            ###

