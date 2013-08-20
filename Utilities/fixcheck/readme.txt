The fixcheck package is intended to help the user determine 2 things.
First, before service is applied, a check can be made to determine if the
fixpack will cause possible regression to installed code.  Second, after
the application of service, a check can be run to determine if all
maintenance was actually applied.

There are 2 REXX programs in the package.

     FIXBUILD.CMD reads the readme.1st file on CSD disk #1 and builds a
     data file for the use of the FIXCHECK.CMD.  Note that significant
     changes to the readme.1st file would mean that changes would
     probably be needed to FIXBUILD.CMD.

     FIXCHECK.CMD uses the data file built by the FIXBUILD.CMD to analyze
     the system for maintenance updates.  It is self prompting, but read 
     the questions carefully .

FIXCHECK.CMD, like the SERVICE.EXE, will search for all occurrences of
the syslevel files and/or directories to be serviced and ask the user to
select only one of each to be checked.

These programs may be freely used by any licensed user of OS/2.  I retain
copyright and reserve all rights.  There is NO warranty expressed or
implied.  Suggestions and/or modifications are welcomed, but I may or may
not choose to adapt them.

Because of REXX limitations on returning 4 digit year dates for files,
FIXCHECK.CMD requires Fixpack 35 for Warp 3 or Fixpack 6 for Warp 4.

Since I don't quite understand the logic involved in applying fixes to
Classic REXX and Object REXX, the results returned on updating these
components may not be correct.

You may also get an indication of multiple occurences when a fixpack moves
a file from one subdirectory to another and contains more than one occurence
of the file to provide for updates to the old and new locations.

Chuck McKinnis, mckinnis@ibm.net
