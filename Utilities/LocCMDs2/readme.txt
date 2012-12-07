
 Package: loccmds2 -- locate commands

 Creator: Rick Curry, trindflo@fishnet.net

 Purpose: To locate "collisions" among DLLs, locate DLLs, locate EXEs.

  To use: LocL      FileName
          LocP      FileName
          lpdupes  [FileName]

     This package contains 3 REXX scripts.  The filename argument in all
cases is a partial filename to be searched for.  The scripts add a '*'
to the end of the filename, so there is no need for the user to.  In the
case of lpdupes it is important that you do not use either a wildcard or
the '.dll' extension of the FileName argument as they are supplied.

     LocL and LocP work similarly.  LocL will search along the LIBPATH
list and find every DLL which matches the partial filename given as an
argument.  Similarly, LocP will search along the PATH environment
variable and find every file in these directories which matches the
partial filename argument.

     lpdupes searches for "collisions" among the DLLs: the same DLL name
in 2 or more directories.  With no arguments, lpdupes will locate all
DLLs in your LIBPATH which do not have unique names.  lpdupes identifies
all the copies of the DLL and the size and date of the files.  If an
argument is given, then only files which match the argument are scanned
for collisions.

     I wrote this because I had a problem with my libpath and could not
find a utility which does what lpdupes does.  The other 2 scripts are
trivializations of lpdupes which seemed useful.

     This version fixes problems lpdupes had with paths which began with
'\' and '..'.
