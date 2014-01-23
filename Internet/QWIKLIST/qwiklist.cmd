/* QWIKLIST.CMD Tested with WebExplorer 1.03B */

  parse arg infile                     /* The EXPLORE.INI path and name   */
  outfile = 'qwiklist.bm'              /* The resulting bookmark file     */
  eqsign = x2c('3D')
  
  topline = "Quick List" d2c(6) "darkcyan.ico"
  call lineout outfile, topline
  
  do while lines(infile) > 0           /* EXPLORE.INI is plain text       */
     ln = linein(infile)
        if left(strip(translate(ln)),10) = "QUICKLIST=" then do    
           title = strip(substr(ln,11))
           url = linein(infile)
           outline = strip(title) d2c(4) ,
                     url d2c(4) ,
                     left(date('U'),5) d2c(4) ,
                     time('C') d2c(4)
           call lineout outfile, outline
        end  /* Do */
  end /* do */
  
  return
  exit

/* Instructions:
----------------

The most often asked question about WebExtra is:  "Can I convert my
WebExplore QuickList to a bookmark file?  Yes -- in less than five minutes.
You can then organize your entries among different books within WebExtra
or, externally, with a text editor.

This is a simple REXX script for converting a WebExplorer
QuickList to a WebExtra bookmark file.  You do not need to know anything
about REXX to use this utility.  Just follow the instructions below.

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

Dan Porter
InnoVal Systems Solutions, Inc.
innoval@tiac.net or innoval@ibm.net
(914) 835-3838

---------------------------------------------------------------------

*/
