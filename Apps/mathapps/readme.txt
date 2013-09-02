__________________________
Installation:
Place the .cmd files where ever you wish.  Make sure the DLL is in your LIBPATH or the directory in which you try to execute the programs.  Type the program name without any parameters will provide help.

REXX must be installed on your system.

__________________________
Program descriptions:

1. Convolution.cmd convolves a square kernel with a rectangular array of data.

2. CurveFit2.cmd computes an nth order polynomial for a table of x,y values.

3. SurfaceFit1.cmd computes a polynomial of degree 1 for n dimensions, given x1, x2, x3, ... y.

Both CurveFit2 and SurfaceFit1 use the Gauss-Jordan algorithm to perform least squares fits as outlined in Numerical Recipes.  The implementations were done in an attempt to make generic subroutines,  Therefore they work, but are relatively slow.  For my purposes though they are still plenty fast enough.  The approach is also rather brute force.  Numeric stability is potential problem, especially with surface fitting.  This can be greatly improved by increasing the numeric precision, for which see the comments internal to the code.  I am aware that there are also several techniques and approaches which are generally superior to the Gauss-Jordan, but I didn't code them (yet).  If anyone would like to share such implementations, please let me know.

I cannot warrant these programs in anyway.  They serve my needs.  They are not intended to be "industrial strength" tools.  If you have comments please feel free to send them.  As far as changing the format of the output, I am not likely to do this.  I assume someone who needs such changes can spend a little time and modify the formating statements, which is why I provide these as .cmd files rather than as .exe.  (After all, I've done the lion's share of the work, now it is your turn.  :-)  )

I note that often the output of these programs can be lengthy and wide.  Therefore running them under PMRexx may be very useful.

__________________________
Copyrights:

Copyright by Doug Rickman, GHCC/MSFC/NASA  1998.

REXXLIB is copyrighted software belonging to Quercus Systems and is included with this software by permission of Quercus Systems.   Users of these programs are not permitted to use REXXLIB except in conjunction with your product. Any further use by an end user (except for evaluation) requires purchase of at least a basic registration.   

__________________________
Example runs:
   
__________ Convolution.cmd ________________

[G:\source\MathApplications]convolution Conv.data Conv.kernel Conv.out

The file  CONV.OUT already exists, do you want it overwritten?
Enter a "y" for yes, "h" will give help,
any other response will abort processing.

Kernel weights:
   0,   -1,    0, 
  -1,    4,   -1, 
   0,   -1,    0, 
Number of weights: 5   Sum of weights: 0

Data values:
   1.000,    1.000,    1.000,    1.000,   10.000,   10.000,   10.000,   10.000, 
   1.000,    1.000,    1.000,    1.000,   10.000,   10.000,   10.000,   10.000, 
   1.000,    1.000,    1.000,    1.000,   10.000,   10.000,   10.000,   10.000, 
   1.000,    1.000,    1.000,    1.000,   10.000,   10.000,   10.000,   10.000, 
  20.000,   20.000,   20.000,   20.000,   40.000,   40.000,   40.000,   40.000, 
  20.000,   20.000,   20.000,   20.000,   40.000,   40.000,   40.000,   40.000, 
  20.000,   20.000,   20.000,   20.000,   40.000,   40.000,   40.000,   40.000, 
  20.000,   20.000,   20.000,   20.000,   40.000,   40.000,   40.000,   40.000, 

Filtered array:
   0.000,    0.000,    0.000,   -9.000,    9.000,    0.000,    0.000,    0.000, 
   0.000,    0.000,    0.000,   -9.000,    9.000,    0.000,    0.000,    0.000, 
   0.000,    0.000,    0.000,   -9.000,    9.000,    0.000,    0.000,    0.000, 
 -19.000,  -19.000,  -19.000,  -28.000,  -21.000,  -30.000,  -30.000,  -30.000, 
  19.000,   19.000,   19.000,   -1.000,   50.000,   30.000,   30.000,   30.000, 
   0.000,    0.000,    0.000,  -20.000,   20.000,    0.000,    0.000,    0.000, 
   0.000,    0.000,    0.000,  -20.000,   20.000,    0.000,    0.000,    0.000, 
   0.000,    0.000,    0.000,  -20.000,   20.000,    0.000,    0.000,    0.000, 

[G:\source\MathApplications]

__________ CurveFit2.cmd ________________

[G:\source\MathApplications]CurveFit2.cmd Curve.data 2 y

Solution:
y =  0.182900419*x^2 + -1.84653670*x^1 + 12.1848484

Standard Error of Estimate = 4.21922114850597e-01

         x          y y estimate    delta    delta^2
__________ __________ __________ __________ __________
         0       12.0 12.1848484 1.848E-001 3.417E-002
         1       10.5 10.5212121 2.121E-002 4.500E-004
         2         10 9.22337668 7.766E-001 6.031E-001
         3          8 8.29134207 2.913E-001 8.488E-002
         4          7 7.72510830 7.251E-001 5.258E-001
         5          8 7.52467538 4.753E-001 2.259E-001
         6        7.5 7.69004328 1.900E-001 3.612E-002
         7        8.5 8.22121203 2.788E-001 7.772E-002
         8          9  9.1181816 1.182E-001 1.397E-002

[G:\source\MathApplications]



__________ SurfaceFit1.cmd ________________

[G:\source\MathApplications]SurfaceFit1.cmd surface.data surface.out

Solution:
y = 48.1875002 + 7.8250000*x.1 + -1.75500002*x.2

Standard Error of Estimate = 9.85460720171027e+00
The file  SURFACE.OUT already exists, do you want it overwritten?
Enter a "y" for yes, "h" will give help,
any other response will abort processing.
y


[G:\source\MathApplications]





Doug Rickman
doug@hotrocks.msfc.nasa.gov