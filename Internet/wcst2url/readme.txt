
   January, 9th 1997
   Warpcast New and Updated links => URL-create scripts
   First public release


   ___________________________________________________________________
   0 - Foreword

   These are simple rexx scripts which build URL objects (and a HTML
   index, if needed) out of Warpcast 'New and Updated' links messages.
   These scripts are completely useless if you do not receive Warpcast
   daily updates in your mailbox.

   To subscribe, unsubscribe, or for more information on WarpCast
   itself, visit: http://www.warpcast.com/

   These scripts were written for personal use and then cleaned up and
   released to the public domain: you can use them freely and you can
   modify the source to suit your needs, at your own risk.

   ___________________________________________________________________
   1 - CreateFolder, createURL and HTMLBuilder: hu?

   Since they answered a personal need, no real effort has been done
   to make the script themselves 'user-friendly'.
   No one-step installation routine is provided: you will actually
   have to read all this (and the .cmd files) to understand how (and
   if) these scripts may be useful for you.
   Each script performs a specialized function:

   createFolder builds the folders to store the URLs in
   createURL    reads your incoming mail to actually build URLs and
                data files
   HTMLBuilder  creates a HTML 'digest' out of the data files

   deleteOBJs   will let you quickly destroy folders and shadows

   ___________________________________________________________________
   2 - Quick and dirty installation and use notes

   Please check the scripts also, since they are quite commented.
   A couple of the scripts use the FILEREXX extensions: we've included
   the necessary DLL in the package for your convenience.
   All credits go to its author, Jeff Glatt.

   The License part of the FILEREXX documentation reads:

   ---snip----

   'FILEREXX.DLL and this document are copyright 1995 by the author,
   Jeff Glatt.  These items are freely distributable.
   There are no pagan user fees, surreptitious financial charges, or
   other devious capitalist trickery associated with the use of these
   files.  There are also no warranties of any kind with this software.
   If swallowed, induce vomiting immediately (by contemplating the
   aesthetics of Windows).  You can do anything you like with this
   archive, except reverse engineer or modify FILEREXX.DLL, nor can you
   poke it with a sharp stick.  But you can print it out on flimsy
   paper stock, wrap it around your privates, and go to work like that
   as long as you don't blame the author for your actions.
   You are not allowed to think nasty thoughts about the author, even
   if the software somehow causes the erasure of your collection of
   smutty picture files (...).

   I can be contacted at:

   6 Sycamore Drive East
   New Hartford, NY 13413
   (315) 735-5350

   Report bug fixes, or shut up.
   Whose says that writing software licenses is no fun?'

   ---snip----

   Thanks Jeff for creating FileRexx and for the clear and exahustive
   documentation (really).

   You are encouraged to download the complete package from Hobbes:

   at ftp-os2.nmsu.edu as filerx.zip


   Now, let's take a look at what needs to be done to use the scripts.

       a - unzip the archive (you already did it, don't you?)
       b - copy the filerexx.dll to your DLL path (or another known
           path) and place the scripts in any directory you like the
           best. The files which will be created at runtime, INIs and
           the HTML digest, will have a home here.
       c - run createFolder.cmd.
           It will ask you on which drive (default: boot drive) you
           want the two folders, NEW and UPDATED, to be created and
           how do they have to be called (default: [Warpcast New
           Links] and [Warpcast Updated links]). Then it will ask you
           if you want an object for HTMLBuilder on your WPS.

       d - open your mailer.
           You will need to tell it to use createURL.cmd as a rexx
           program while fetching mail.

           PMMail: you will need to tell PMMail to use createURL.cmd as
           a message receive exit under the account or utilities rexx
           settings, depending on your version of the program.
           Use the complete path.

           PostRoad Mailer: open 'file' => 'settings' and move to the
           'User Exits' page of the notebook.
           Use createURL.cmd as your receive message exit, and make it
           run 'Minimized' (createURL has no video output).

           Save your settings and you are ready to go.

       e - download your mail.
           If you chose to create URLs (see below), you will find that
           new folders have been created inside of the NEW and UPDATED
           ones (if NEW or UPDATED URLs have been broadcasted for that
           day). These day folders (if created) will have a full-date
           name, something like 'Thu, 18 Dec 1997'.
           You will find the URLs inside, ready to be double-clicked
           or dragged.

       f - run HTMLBuilder if you want the HTML digest.
           Keep in mind that the daily database is rewritten each time
           a message from Warpcast is received (e.g. once a day).
           If you want your digest solid and useful, run HTMLBuilder
           once a day too, or you won't be able to keep track of what
           is NEW, UPDATED or NORMAL (see below).

   ___________________________________________________________________
   4 - A closer look to the scripts

   There are four small rexx tools in the archive.

   createFolder.cmd => this script has to be run from a command prompt
                       if you want folders and URLs from your Warpcast
                       messages. You do not need to use it if you just
                       want the URLs HTML-ized. If you prefer to have
                       URL objects, this is the first script to run.
                       Mind you: URLs won't be created if you do not
                       run this script.

   createURL.cmd    => This is the script which does most of the work.
                       We tested it with PMMail and PostRoad Mailer,
                       but it should work with any rexx-enabled mailer:
                       you only need check that it uses rexx CMDs upon
                       receiving messages and that it passes the current
                       file name as an argument.
                       This script checks all of the incoming messages
                       and creates the URLs when it finds a Warpcast
                       message that contains them.
                       It does not create URLs referenced in messages
                       coming from sources other than Warpcast (although
                       you could easily adapt the script).
                       It also writes a data file used by HTMLBuilder in
                       order to give you a HTML version of the New and
                       Updated links.
                       Note that you can set from inside the script if
                       you want URLs to be created or not, and, if yes,
                       if you prefer normal folders or URLFolders.
                       The data file is always created at runtime and this
                       feature cannot be disabled.

                       Note that createURL.cmd can be run if necessary
                       from a command line, but you will need to pass
                       it a Warpcast URL message file as an argument:
                       using PMMail you will need to do something like

                       createURL EJ635X61.MSG

                       We heartily suggest you not to do so, if not for
                       testing purposes ;) )

   HTMLBuilder.cmd  => This is the script which reads the datafile and
                       creates the HTML code. It also writes the history
                       archive, so you can keep track of which URL is
                       NEW, UPDATED or NORMAL.
                       This script needs to be run each time a new
                       Warpcast URL message comes in, or you will lose
                       the links of the day in your HTML digest (the data
                       file gets rewritten each time by createURL.).
                       This is somewhat a mixed-bag feature, since the
                       HTML file tends to rapidly become quite huge.
                       An URL is NEW if it has never been broadcasted by
                       Warpcast, and is NORMAL if it has not been updated
                       in the last 7 days.
                       You can set the value for the UPDATED => NORMAL
                       transition from inside HTMLBuilder.cmd.

   deleteOBJS.cmd   => This script deletes the folders created by
                       createFolder.cmd with all of their contents.
                       Mainly for testing purposes.
                       Be warned that it won't ask you if you are sure
                       of what you are doing. ;)


   You will also find:

   jpg images       => Used by the HTML file



   Thanks for the interest.
   Please report bugs and/or improvements.
   We hope you find these small tools useful.

   G. Aprile
   P.Rossi
   A. Resmini   resmini@netsis.it

