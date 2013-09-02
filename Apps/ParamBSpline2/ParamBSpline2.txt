ParamBSpline2:  A program to generate a smooth curve from sequential points 
in n-dimensional data. 

ParamBSplin2e is based on the FORTRAN library FITPACK by Paul Dierckx.  This
library may be obtained from www.netlib.org.  Not all functionality in the 
parent library is made available in ParamBSpline2. cmd.  For those 
interested read the comments in subroutines mnparc and parcuv of 
ParamBSpline2.  For a treatment of the mathmematics and considerations of 
using this type of tool I recommend "Curve and Surface Fitting with 
Splines", by P. Dierckx, Monographs on Numerical Analysis, Oxford 
University Press, 1993, ISBN 0-19-853441-8.



Installation:
If you already have REXX you place the program, ParamBSpline2.cmd where ever
you like, usually in your path, and away you go.  Complex, right?  For more
information read the documentation.  If you are running under MicroSoft you 
may wish to change the program's name to ParamBSpline2.rex.  MicroSoft 
typically has the extension ".cmd" reserved for other purposes.

Note, MicroSoft has included a defective version of REXX with the NT 
Resource Kit without the required attribution of sources.  It is my
understanding that this version should not be used.

If you do not have a REXX interpreter the Regina interpreter is free and 
widely used.  Go to http://www.lightlink.com/hessling/Regina/ for general 
statements.  The binaries and source can be obtained from 
   http://www.lightlink.com/hessling/downloads.html

Under MicroSoft you will need to place Regina.DLL and Regina.EXE along your
path.  Its simple.  I've done it.

There are other interpreters.  For example IMB provides a free one with OS/2 
and they also make it available under Linux for free.  They sell the NT 
version. Information about this version is available at   
   http://www-4.ibm.com/software/ad/obj-rexx/

If you want to learn more about REXX got to
   http://www.rexxla.org/


Documentation:
HTML and OS/2 .inf files are included under the doc/ subdirectory.  If you 
are using html please start with ParamBSpline2_Main.html.

Examples: 
There example input and output files are included under the examples/ sudirectory.


Operation:
As currently configured ParamBSpline2 is a command line program only.  Please
read the provided documentation for instructions on use.  Example input and 
output files are given in the documentation.


License:
All that I ask is that if you find the program useful and helps you produce 
results for publication, please give credit where credit is due.  

Cheap enough?



Doug Rickman
GHCC
MSFC/NASA/GOV
doug@hotrocks.msfc.nasa.gov