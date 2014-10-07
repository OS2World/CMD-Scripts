README.TXT for SHUTKILL.CMD (v1.02)


WHAT IS IT?

SHUTKILL is a REXX program which allows you to manipulate the eStyler
shutdown "kill list" from the command line.


EXPLANATION

The enhanced eComStation shutdown (part of eStyler) includes a undocumented
process-killer.  Any executable program whose file name matches an entry in
the "kill list" (a list of programs which resides in ESTYLER.INI) will be
automatically killed by eStyler during shutdown, if it is running.

This is primarily useful for dealing with programs that may not terminate
normally during a system shutdown.  Some background processes may hang (like
Desktop On-Call's chat daemon), or pop up irritating confirmation dialogs (like
the CAD Handler console), thereby preventing a smooth shutdown.  The kill list
was designed to solve this problem.  However, this feature was introduced into
eStyler after the configuration program was designed, so it lacks a user
interface.

Two programs are listed in the kill list by default: CHAT.EXE (part of Desktop
On-Call) and CLKBASIC.EXE (part of the eClock package).  Other programs can be
added, but up until now this has required editing the binary data in ESTYLER.INI
by hand.  SHUTKILL makes manipulating the kill list much easier by allowing you
to add or delete programs, or view the list.


USAGE

Run 'SHUTKILL' or 'SHUTKILL /?' for syntax information.  Basically, there are
three types of invocation:

    SHUTKILL /A <program name>      Add <program name> to the kill list.
    SHUTKILL /D <program name>      Remove <program name> from the kill list.
    SHUTKILL /L                     Display the current kill list.


REQUIREMENTS

You must have REXX support enabled, and eStyler (also known as eCSStylerLite) must
be installed.  (Both of these are installed by default on eComStation 1.0 and 1.1.)


HISTORY

v1.02 (2003-10-28)
 * Fixed incorrect action message when removing a program from the kill list.

v1.01 (2003-08-30)
 * Fixed minor syntax error in rarely-reached code which caused failure when
   using Object REXX.

v1.0 (2003-08-26)
 * Initial release


CREDITS

SHUTKILL.CMD is (C) 2003 Alex Taylor.  eStyler and the eComStation enhanced
shutdown are (C) 2001 Alessandro Cantatore.  eComStation is a product of
Serenity Systems International.

