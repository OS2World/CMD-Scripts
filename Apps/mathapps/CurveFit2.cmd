/* Typing "CurveFit2" without parameters will provide a help screen.         */
/*                                                                           */
/* Read a file of X,Y values and obtain a least squares estimate of          */
/* nth degree polynomial fit to the data.  I have not extensively tested the */
/* program so I don't know how high a degree it will take or how long it will*/
/* take to compute higher degree fits.  I've left the max matrix size in the */
/* Gauss-Jordan routine at 50.  This gives a 49th degree fits.               */
/* It is left as an exercise for the student to evaluate the regression      */
/* at different values of x, compute residuals, or determine the             */
/* appropriate degree to use in the fit.                                     */
/*                                                                           */
/* The format of the printed solution lists coefficients in descending       */
/* powers of x, i.e.  d*x^3 + c*x^2 + b*x + a                                */
/* The user may reverse this by appropriate moving of the comments in the    */
/* section of code starting "/* Print the solution matrix */"                */
/*                                                                           */
/* If the format of the output table is not satisfactory, changing it is left*/
/* as an exercise for the student.                                           */
/*                                                                           */
/* If this routine is called as an external routine a normal termination     */
/* will return a value of 1.  A 0 is an error return.                        */
/*                                                                           */
/* I wish to thank Mike Montenegro for his criticisms and assistance!        */
/*                                                                           */
/* The program makes use of the REXXLIB routines.  It is left to the user to */
/* obtain and install this shareware package.  It is readily availble at     */
/* Hobbes and other ftp sites, as well as from Quercus.                      */
/* The package is referenced in more than 4 places in this code, for example:*/
/*    "if rxfuncquery('rexxlibregister') ...."                               */
/*    "if dosisfile(in)<>1 then do ..."                                      */
/*    "SumX.i=SumX.i+pow(x.n,i) ..."                                         */
/*    "SumYX.i=SumYX.i+(y.n*pow(x.n,i)) ..."                                 */
/* Such lines would need to be modified or replaced in REXXLIB is not used.  */
/*                                                                           */
/* This program may be copied and modified as desired provided appropriate   */
/* credit is given.  Hopefully others will see fit to improve on it.         */
/*                                                                           */
/* Doug Rickman March 31, 1998 Marshall Space Flight Center, NASA.           */
/*                                                                           */
/* Programmer's notes:                                                       */
/* I have done only one thing that is at all tricky, the rest is very ho-hum.*/
/* I wanted the linear algebra routines to be generic subroutines, so they   */
/* could be called and used in other programs.  To do this they must be able */
/* to accept arrays of any name.  Since a subroutine in REXX can not return  */
/* an array or even a compound variable the array must be created by the     */
/* calling routine and the subroutine must work with it.  The Gauss-Jordan   */
/* routine does its matrix operations in place!  In other words it writes    */
/* the solution into the original, source matrices.  The two facts caused me */
/* to set up the subroutines as follows -                                    */
/*       The calling routine sets a variable called "elist" (for "edit list")*/
/*    prior to calling the subroutine.  elist will contain the names of all  */
/*    the matrices and other parameters needed by the subroutine.   The      */
/*    subroutine is then called using only elist as a parameter.             */
/*       In the subroutine elist is opened and the external variable names   */
/*    are set to internal variable names.  The routine then uses the         */
/*    "interpret" instruction to get the name of and work with the external  */
/*    variable name.                                                         */
/*                                                                           */
/* This is decidedly a pain.  I could have also accomplished the objective   */
/* using queues but I thought this might be quicker.  There is a decided     */
/* performance penalty, but at this time it is not a real issue.             */
/*                                                                           */

signal on Halt
signal on NotReady

Numeric Digits 9

if rxfuncquery('rexxlibregister') then do         /* this will start rexxlib */
	call rxfuncadd 'rexxlibregister', 'rexxlib', 'rexxlibregister'  
	call rexxlibregister
	end

if rxfuncquery('sysloadfuncs') then do           /* this will start rexxutil */
	CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' 
	CALL SysLoadFuncs
	end

arg in degree print
in    =strip(in)
degree=strip(degree)
print =strip(print)

if in='' | in='?' | in='-?' | in='/?' then call Help
if dosisfile(in)<>1 then do
   say 'The input file: ' in' is not a valid file.'
	exit
	end /* do */

/* --------------------------------------------------------------------------*/
/* --- begin MAIN                                               -------------*/
/* Read the data                                                             */
/* Data are assumed to be x y pairs, one per line, with or without delimiting*/
/* commas.                                                                   */
rc=stream(in,'c','open read')
n=0
do while lines(in)\=0
   n=n+1
   data=linein(in)
   data=translate(data,' ',',')
   parse var data x.n y.n
   end
x.0=n
rc=lineout(in)

/* What degree polynomial? */
if degree='' then do
   say 'What degree polynomial should be fit to the data?'
   pull degree
   end

/* Compute the individual sums */
call Sums

/* Build the two matrices */
do i=1 to degree+1 /*row */
   do j=1 to degree+1 /* column */
      m=(j-1)+(i-1)
      A.i.j=SumX.m
      end j
   end i
NRowsA=i-1
NColsA=NRowsA

do i=1 to degree+1
   ii=i-1
   b.i.1=SumYX.ii
   end i
NColsB=1
NRowsB=NRowsA

/* Backup the original A array. */
do i=1 to NRowsA
   do j=1 to NRowsA
      AA.i.j=A.i.j
      end j
   end i

/* now call the Gauss-Jordan routine */
elist= 'A. NRowsA NColsA B. NRowsB NColsB'
call GaussJordan elist

/* Critical quality check!!!!!                                               */
/* Multiply original A. by A inverse to check for identity.                  */
elist= 'A. NRowsA NRowsB AA. NRowsA NColsA C. NRowsC NColsC'
call MatrixMultiply	elist

elist= 'C. NRowsC NColsC'
rc=IndentityCheck()
if rc=1 then do
   /* say 'The result is close to the identity matrix.  All is well.'  */
   end
else do
   say 
   say 'Checking A x A(inverse):  Oh Oh!!'
   say 
   say 'The inverse of A. may not be numerically precise enough.  You should '
   say 'examine the values in A. x A.inverse, in theory this should be the '
   say 'identity matrix.  You may need to either increase the precision of '
   say 'Numeric Digits (set at the beginning of the program) or increase the '
   say 'amount of Numeric Fuzz set in the subroutine IndentityCheck:.  Of '
   say 'course you might also consider putting in better data.  :-)   You can'
   say 'also change the value of the variable "QualityChecks" internally in '
   say 'the code to have the software dump additional information.'
   say
   end

/* Optional quality checks.  Set "QualityChecks=YES" to use.                 */
QualityChecks='NO'
if QualityChecks=YES then call QualityChecks


/* Print the solution matrix */ /* There are two formats available */
say
say 'Solution: '

/* This format will print the solution with ascending exponents */
/*
Solution=b.1.1
do i=2 to Degree+1
   Solution=Solution' + 'b.i.1'*x^'i-1
   end i
say 'y = 'Solution
*/

/* This format will print the solution with descending exponents */
solution=''
do i= Degree+1 to 2 by -1
   Solution=Solution b.i.1'*x^'i-1 '+'
   end i
Solution=solution  b.1.1
say 'y = 'Solution

/* Determine the standard error */
call StandardError

/* To print the table or not to print! That is the question. */
select
   when print='Y' then call PrintTable
   when print='N' then nop
   otherwise do
      say
      say 'Do you wish to see a table of x, y, y estimate, delta, delta^2?'
      say 'Enter a "y" for yes, any other response will exit the program.'
      key=translate(sysgetkey())
      say
      if key='Y' then call PrintTable
      end
   end /* select */

return 1


/* --- end MAIN                                                 -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Help:                                 -------------*/
Help:
rc= charout(,'1b'x||'[31;7m'||'CurveFit2:'||'1b'x||'[0m'||'0d0a'x)
say 'Fit an nth degree polynomial to x,y data by the method of least squares.'

rc= charout(,'1b'x||'[33;1m'||'usage:'||'1b'x||'[0m')
say ' CurveFit2 in degree print'
say ''

rc= charout(,'1b'x||'[33;1m'||'where:'||'1b'x||'[0m')
say ' in     = the file holding x,y pairs, one pair per line, comma or blank '
say '                delimited.'
say '       degree = degree of polynomial to fit to data.'
say '       print  = if "y" a table of x, y, y estimate, delta, delta^2 is printed.'
say '              = if "n" then the table will not be printed.'
say ''

rc= charout(,'1b'x||'[33;1m'||'Exam: '||'1b'x||'[0m')
say ' convolution Conv.data Conv.kernel Conv.out '
say ' CurveFit2.cmd Curve.data 2 y'

rc= charout(,'1b'x||'[33;1m'||'notes:'||'1b'x||'[0m')
say ' If the parameters "degree" and "print" are not given on the command line'
say ' the user will be prompted for the polynomial degree to fit to the data'
say ' and then will be asked if the table is to be printed.'
say ' WARNINGS: There are relatively few checks on user input.  For example, if one'
say ' attempts a 2nd degree polynomial with only 2 points, or if the input '
say ' file has a blank line CurveFit will probably go Boom.  There is a check of'
say ' the inverse matrix computed (an essential step).  If quality is not very'
say ' high the user is notified and suggestions made to address the problem.'
say ''

say 'Doug Rickman  March 21, 1998'
exit
return

/* --- end  subroutine - Help:                                  -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Sums:                                 -------------*/
/* Computes the sum of X, Y, X^2, Y^2, .....                                 */
Sums:
do i=1 to degree*2
   SumX.i=0
   do n=1 to x.0
      SumX.i=SumX.i+pow(x.n,i) 
      end n
   end i
SumX.0=n-1

SumY=0
do n=1 to x.0
   SumY=SumY+y.n
   end n
SumYX.0=SumY

do i=1 to degree
   SumYX.i=0
   do n=1 to x.0
      SumYX.i=SumYX.i+(y.n*pow(x.n,i))
      end n
   end i
return
/* --- end subroutine   - Sums:                                 -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - GaussJordan:                          -------------*/
/* Solve a square array using the Gauss-Jordan algorithm as outlined in      */
/* numerical recipes.                                                        */
/* Implemented by Doug Rickman March 13, 1998                                */
/* elist holds:                                                              */
/*      name of the first array,                                             */
/*      the variable holding the number of rows in the first array,          */
/*      the variable holding the number columns in the first array.          */
/*      name of the second array,                                            */
/*      the variable holding the number of rows in the second array,         */
/*      the variable holding the number columns in the second array.         */
/*                                                                           */
/*      A. NRowsA NColsA B. NRowsB NColsB                                    */
GaussJordan:
procedure expose (elist)

parse var elist VArrayName1 VNRows1 VNCols1 VArrayName2 VNRows2 VNCols2 

NRows1=value(VNRows1)
NCols1=value(VNCols1)
ArrayName1=strip(VArrayName1,'t','.')

NRows2=value(VNRows2)
NCols2=value(VNCols2)
ArrayName2=strip(VArrayName2,'t','.')

N=NRows1     /* number of elements and rows */
M=NCols2     /* right hand vactors is an array N by M */

NMax=50
do j=1 to N
   IPIV.j=0
   end j

do i=1 to N
   BIG=0
   do j=1 to N
      if IPIV.j <> 1 then do k=1 to N
         interpret 'Temp='Arrayname1'.j.k'
         if IPIV.k=0 & abs(Temp)>=BIG then do
            interpret 'BIG=abs('Arrayname1'.j.k)'
            irow=j
            icol=k
            end 
         else if IPIV.k > 1 then do
            say 'Singular matrix! Stop 1'
            exit
            end
         end k
      end j

   IPIV.icol=IPIV.icol+1

   if irow<>icol then do
      do /*14*/ L=1 to N
         interpret 'DUM='Arrayname1'.irow.L'
         interpret Arrayname1'.irow.L='Arrayname1'.icol.L'
         interpret Arrayname1'.icol.L=DUM'
         end L
      do L=1 to M
         interpret 'DUM='Arrayname2'.irow.L'
         interpret Arrayname2'.irow.L='Arrayname2'.icol.L'
         interpret Arrayname2'.icol.L=DUM'
         end L
      end /* if irow<>icol then do ... */

   INDXR.i=irow
   INDXC.i=icol
   interpret 'Temp='Arrayname1'.icol.icol'
   if Temp=0 then do
      say 'Singular matrix! Stop 2.'
      exit
      end
   
   interpret 'PIVINV=1/'Arrayname1'.icol.icol'
   interpret Arrayname1'.icol.icol=1'
   do L=1 to N
      interpret Arrayname1'.icol.L='Arrayname1'.icol.L*PIVINV'
      end L
   do L=1 to M
      interpret Arrayname2'.icol.L='Arrayname2'.icol.L*PIVINV'
      end L
   do LL=1 to N
      if LL \= icol then do
         interpret 'DUM='Arrayname1'.LL.icol'
         interpret Arrayname1'.LL.icol=0'
         do L=1 to N
            interpret Arrayname1'.LL.L='Arrayname1'.LL.L-'Arrayname1'.icol.L*DUM'
            end L
         do L=1 to M
            interpret Arrayname2'.LL.L='Arrayname2'.LL.L-'Arrayname2'.icol.L*DUM'
            end L
         end /* if LL \= icol then do ... */      
      end LL

   end i

/* Unscramble */
do L=N to 1 by -1
   if INDXR.L \= INDXC.L then do K=1 to N
      INDXRL=INDXR.L
      INDXCL=INDXC.L
      interpret 'DUM='Arrayname1'.K.INDXRL'
      interpret Arrayname1'.K.INDXRL='Arrayname1'.K.INDXCL'
      interpret Arrayname1'.K.INDXCL=DUM'
      end K
   end L

return
/* --- end subroutine   - GaussJordan:                          -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - MatrixMultiply:                       -------------*/
/* Returns a 1 if successful, result is in C.                                */
/* Returns a 2 if the matrices are not the correct size.                     */
/* elist holds:                                                              */
/*      name of the first array,                                             */
/*      the variable holding the number of rows in the first array,          */
/*      the variable holding the number columns in the first array.          */
/*      name of the second array,                                            */
/*      the variable holding the number of rows in the second array,         */
/*      the variable holding the number columns in the second array.         */
/*      name of the result array,                                            */
/*      the variable holding the number of rows in the result array,         */
/*      the variable holding the number columns in the result array.         */
/*                                                                           */
/*      A. NRowsA NColsA B. NRowsB NColsB C. NColsC NRowsC                   */

MatrixMultiply:
procedure expose (elist)

parse var elist VArrayName1 VNRows1 VNCols1 ,
                VArrayName2 VNRows2 VNCols2 ,
                VArrayNameR VNRowsR VNColsR

NRows1=value(VNRows1)
NCols1=value(VNCols1)
ArrayName1=strip(VArrayName1,'t','.')

NRows2=value(VNRows2)
NCols2=value(VNCols2)
ArrayName2=strip(VArrayName2,'t','.')

ArrayNameR=strip(VArrayNameR,'t','.')

if NCols1=NRows2 then do
   NRowsR=Nrows1
   NColsR=NCols2
   do i=1 to NRowsR
      do j=1 to NColsR
         interpret ArrayNameR'.i.j=0'
         do k=1 to NCols1
            interpret ArrayNameR'.i.j='ArraynameR'.i.j+('ArrayName1'.i.k*'ArrayName2'.k.j)'
            end k
         end j
      end i
   end /* if ... */

   interpret VNRowsR'=NRowsR'
   interpret VNColsR'=NColsR'

   return 1
   end
else return 2

/* --- end subroutine   - MatrixMultiply:                       -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - IndentityCheck:                       -------------*/
/* Check to see if matrix is an identity matrix (diagonal=1, other=0).       */
/* 1 is returned for and identity matrix, a 0 otherwise.                     */
/* Precision can be increased by increasing NUMERIC DIGITS for the Gauss-    */
/* Jordan subroutine.  Also the tolerance for error can be increased by      */
/* changing the NUMERIC FUZZ value in this routine.                          */
/* elist holds:                                                              */
/*          name of the array,                                               */
/*          the variable holding the number of rows,                         */
/*          the variable holding the number columns.                         */
IndentityCheck: procedure expose (elist)

parse var elist ArrayName1 VNRows1 VNCols1

NRows=value(VNRows1)
NCols=value(VNCols1)
Arrayname=strip(Arrayname1,'t','.')

n=digits()
numeric fuzz n-3
do i=1 to NRows
   do j=1 to NCols
      interpret 'test=1+'Arrayname'.i.j'
      if i=j & test=2 then iterate
      if test=1 then iterate
      else do
         numeric fuzz 0
         return 0
         end 
      end j
   end i
numeric fuzz 0
return 1
/* --- end subroutine   - IndentityCheck:                       -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - ShowMatrix:                           -------------*/
/* elist holds:                                                              */
/*          name of the array,                                               */
/*          the variable holding the number of rows,                         */
/*          the variable holding the number columns.                         */

ShowMatrix: procedure expose (elist)

parse var elist ArrayName1 VNRows1 VNCols1

NRows=value(VNRows1)
NCols=value(VNCols1)
Arrayname=strip(Arrayname1,'t','.')
/* say 'Array: 'ArrayName */
do i=1 to NRows
   row=''
   do j=1 to NCols
      interpret 'row=row 'ArrayName'.i.j'
      end j
   say row
   end i
return

/* --- end subroutine   - ShowMatrix:                           -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine -                                       -------------*/
QualityChecks:

say
/* Print the inverse of A. */
say 'Inverse of A is '
elist= 'A. NRowsA NColsA'
call ShowMatrix elist

say
/* Multiply A inverse times the solution vector.  The result should equal the*/
/* original B. matrix.                                                       */
elist= 'AA. NRowsA NRowsB B. NRowsB NColsB C. NRowsC NColsC'
say 'Inverse of A times the solution B: (should equal the original matrix B.)'
call MatrixMultiply	elist
elist= 'C. NRowsC NColsC'
call ShowMatrix elist

say
/* Multiply original by inverse to check for identity.                       */
elist= 'A. NRowsA NRowsB AA. NRowsA NColsA C. NRowsC NColsC'
say 'Original A times the inverse of A: (should equal identity matrix)'
call MatrixMultiply	elist
elist= 'C. NRowsC NColsC'
call ShowMatrix elist

return

/* --- end subroutine   -                                       -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - StandardError:                        -------------*/
StandardError:

SE=0
do n=1 to x.0
   yHat=b.1.1
   do i=2 to Degree+1
      exponent=i-1
      yHat=yHat + b.i.1*pow(x.n,exponent)
      end i
   SE=SE+(y.n-yHat)*(y.n-yHat)
   end n
SE=sqrt(SE/x.0)

say
say 'Standard Error of Estimate = 'SE

return
/* --- end  subroutine  - StandardError:                        -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - PrintTable:                           -------------*/
PrintTable:
say
say '         x          y y estimate    delta    delta^2'
say '__________ __________ __________ __________ __________'

do n=1 to x.0
   yHat=b.1.1
   do i=2 to Degree+1
      exponent=i-1
      yHat=yHat + b.i.1*pow(x.n,exponent)
      end i
   say right(x.n,10) right(y.n,10) right(yHat,10) right(format(y.n-yHat,,3,3,3),10) right(format(pow(y.n-yHat,2),,3,3,3),10)
   end n

return
/* --- end  subroutine  - PrintTable:                           -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Halt:                                 -------------*/
Halt:
say 'This is a graceful exit from a Cntl-C'
return 0
/* --- end  subroutine - Halt:                                  -------------*/
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - NotReady:                             -------------*/
NotReady:
say 'It would seem that you are pointing at non-existant data.  Oops.  Bye!'
return 0
/* --- end  subroutine - NotReady:                              -------------*/
/* --------------------------------------------------------------------------*/
