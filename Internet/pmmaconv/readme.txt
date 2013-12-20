-----------------------------------------------------------------------------
What PmmaConv does
-----------------------------------------------------------------------------

If you want to print the PMMail address book, or put your address lists into a internet or intranet page, PmmaConv is the tool you are looking for.

PmmaConv reads the PMMail address database and converts it to one of several possible output formats. Enter "pmmaconv /h" to find out which formats these are.

-----------------------------------------------------------------------------
This is important!
-----------------------------------------------------------------------------

PmmaConv is freeware. You pay for nothing, and I don't guarantee anything!

Please distribute only the complete and unmodified PmmaConv package. Otherwise add a note to this file, that explains what you modified, and why you did it.

Anyway, I'll appreciate any suggestions for improvements of PmmaConv. I'd also appreciate a short note, if you actually use this program. ;-)

PmmaConv accesses your PMMail addressbook files. It just reads these files, but before you actually use PmmaConv, you should make backup copies of the files ADDR.DB and BOOKS.DB in the TOOLS directory of your PMMail installation. Just in case...

-----------------------------------------------------------------------------
Files in this distribution
-----------------------------------------------------------------------------

In the pmmaconv directory:

pmmaconv.cmd - The source code and executable
readme       - This file
todo         - List of not yet implemented features, unfixed bugs, etc.

In the pmmaconv\pgp directory:

pmmaconv.sig - My PGP signature for pmmaconv.cmd
readme.sig   - My PGP signature for readme
todo.sig     - My PGP signature for todo

-----------------------------------------------------------------------------
How to use PmmaConv
-----------------------------------------------------------------------------

The output of "pmmaconv /h" should tell you everything you need.

-----------------------------------------------------------------------------
The author
-----------------------------------------------------------------------------

Enter "pmmaconv /h" to get my email address. 

To get my PGP public key, send me an empty email with "send pgp key" in the subject line.

-----------------------------------------------------------------------------
Miscellaneous
-----------------------------------------------------------------------------

I haven't found a way to determine the location of the Pmmail addressbook files automatically. If you have any ideas, I'd like to hear from you. If your TOOLS directory is not E:\SOUTHSDE\TOOLS, which is the default setting of PmmaConv, you can do one of the following things:
(1) Always specify the correct directory with the -TOOLS command line option of PmmaConv.
(2) Write a script that has just the following single line in it: "\path\to\pmmaconv -tools \the\actual\tools\directory %1 %2 %3" and name it somename.cmd. Then use somename.cmd instead of pmmaconv.cmd to call PmmaConv.
(3) Change the PmmaConv script itself (look for the variable DEFAULT_TOOLS).
Like with other programs, number 2 is always the recommended way. Number 3 is ok, if you don't plan to install any PmmaConv updates.





Rolf Lochbuehler
Vermont, USA
--
$Id: readme,v 1.4 1998-10-16 00:16:44-04 rl Exp $
