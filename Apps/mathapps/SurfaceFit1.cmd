/* Typing "SurfaceFit1" without parameters will provide a help screen.       */
/*                                                                           */
/* Read a file of X1, X2, X3, ..., Y values and obtain a least squares       */
/* estimate of a first degree surface fit to the data.                       */
/*                                                                           */
/* If this routine is called as an external routine a normal termination     */
/* will return a value of 1.  A 0 is an error return.                        */
/*                                                                           */
/* The program makes use of the REXXLIB routines.  It is left to the user to */
/* obtain and install this shareware package.  It is readily availble at     */
/* Hobbes and other ftp sites, as well as from Quercus.                      */
/*                                                                           */
/* I wish to thank Mike Montenegro for his criticisms and assistance!        */
/*                                                                           */
/* This program may be copied and modified as desired provided appropriate   */
/* credit is given.  Hopefully others will see fit to improve on it.         */
/*                                                                           */
/* Doug Rickman April 13, 1998 Marshall Space Flight Center, NASA.           */
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
/* I have written this using abundant comments and white space.  In fact     */
/* approximately 1/3 of the total lines are "waste."  I hope this will help  */
/* others who wish to edit the code.                                         */
/*                                                                           */

signal on Halt
signal on NotReady

Numeric Digits 9       /* This may be changed to increase/decrease precision */

if rxfuncquery('rexxlibregister') then do         /* this will start rexxlib */
	call rxfuncadd 'rexxlibregister', 'rexxlib', 'rexxlibregister'  
	call rexxlibregister
	end

if rxfuncquery('sysloadfuncs') then do           /* this will start rexxutil */
	CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' 
	CALL SysLoadFuncs
	end

arg in print
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
/* Data are assumed to be x1, x2, x3, ..., y pairs, one per line, with or    */
/* without delimiting commas.                                                */
rc=stream(in,'c','open read')
data=linein(in)
NIndependents=words(data)-1
Xs=''
do i=1 to NIndependents
   Xs=Xs 'x.'i'.n'
   end i
rc=stream(in,'C','seek =' 1)

n=0
do while lines(in)\=0
   n=n+1
   data=linein(in)
   data=translate(data,' ',',')
   interpret 'parse var data 'Xs' y.n'
   x.0.n=1 /* Used in the Sums subroutine */
   end
x.0=n
rc=lineout(in)

/* Compute the individual sums */
call Sums

/* Build the two matrices */
do i=0 to NIndependents
   ii=i+1
   do j=0 to NIndependents
      jj=j+1
      A.ii.jj=SumX.i.j
      end j
   end i
NRowsA=NIndependents+1
NColsA=NIndependents+1

do i=0 to NIndependents
   ii=i+1
   b.ii.1=SumYX.i
   end i
NColsB=1
NRowsB=NIndependents+1

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
Solution=b.1.1
do i=2 to NIndependents+1
   Solution=Solution' + 'b.i.1'*x.'i-1
   end i
say 'y = 'Solution

/* Determine the standard error */
call StandardError

/* To print the table or not to print! That is the question. */

select
   when print='Y' then call ScreenPrint
   when print='N' then nop
   when validname(print) then do
      if dosisfile(print) then do
         say 'The file ' print' already exists, do you want it overwritten?'
   	   say 'Enter a "y" for yes, "h" will give help,'
         say 'any other response will abort processing.'
         key=translate(sysgetkey())
         say
         select
            when key='Y' then do
					rc=dosdel(print)
					if rc=1 then nop
					else do
 		      		say 'The file 'print' could not be deleted.  Goodbye, Sweet Prince.'
						exit
						end /* else do */
				   end /* when key='Y' then ... */

				when key='H' then call Help
				otherwise exit
				end /* select */

			end /* if dosisfile(print) */
      call FilePrint
      end /* when validname(print) ... */
   otherwise do
      say
      say 'Do you wish to see a table of x, y, y estimate, delta, delta^2?'
      say 'Enter a "y" for yes, any other response will exit the program.'
      key=translate(sysgetkey())
      say
      if key='Y' then call ScreenPrint
      end
   end /* select */

return 1

/* --- end MAIN                                                 -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Help:                                 -------------*/
Help:
rc= charout(,'1b'x||'[31;7m'||'SurfaceFit1:'||'1b'x||'[0m')
say ' Fit a 1st degree polynomial (a plane) to x1, x2, x3, ..., y data '
say '       by the method of least squares.'

rc= charout(,'1b'x||'[33;1m'||'usage:'||'1b'x||'[0m')
say ' SurfaceFit1 in print'

rc= charout(,'1b'x||'[33;1m'||'where:'||'1b'x||'[0m')
say ' in     = the file holding x1, x2, x3, ..., y pairs, one set per line,'
say '                comma or blank delimited.'
say '       print  = if "y" a table of x, y, y estimate, delta, delta^2 is printed'
say '                to the screen.'
say '              = if "n" then the table will not be printed.'
say '              = if a syntactically correct file name, print to this file.'
say ''

rc= charout(,'1b'x||'[33;1m'||'Exam: '||'1b'x||'[0m')
say ' "surfacefit1 Surface.data surface.out"  or "surfacefit1 Surface.data y"'

rc= charout(,'1b'x||'[33;1m'||'notes:'||'1b'x||'[0m')
say ' If the parameter "print" is not given on the command line the user will'
say 'be asked if the table is to be printed.  Output will go to the screen.'
say 'If a file is specified only syntax is checked.  It is assumed the directory'
say 'exists.  When printing to a file the full precision of the data are retained'
say 'This can make for rather wide lines.  :-)  Precision is increased by changing'
say 'the value NUMERIC DIGITS (a min. of 9 is assumed in the FilePrint subroutine).'
say 'WARNINGS: There are no checks on user input.  For example, if the input '
say 'file has a blank line SurfaceFit1 will probably go Boom.  There is a check of'
say 'the inverse matrix computed (an essential step).  If quality is not very'
say 'high the user is notified and suggestions made to address the problem.'

say 'Doug Rickman  April 20, 1998'
exit
return

/* --- end  subroutine - Help:                                  -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Sums:                                 -------------*/
/* Computes the sum of X, Y, X^2, Y^2, .....                                 */
Sums:

/* Initiallize */
do i=0 to NIndependents
   do j=0 to NIndependents
      SumX.i.j=0
      end j
   SumYX.i=0
   end i

/* Sum of X and X1*X2 ... */
do i=0 to NIndependents
   do n=1 to x.0
      do j=0 to NIndependents
         SumX.i.j=SumX.i.j+x.i.n*x.j.n
         end j
      SumYX.i=SumYX.i+x.i.n*y.n
      end n
   end i

/* To list the sums, remove the comment marks. */
/*
do i=0 to NIndependents
   do j=0 to NIndependents
      say 'SumX.'i'.'j'='SumX.i.j
      end j
   say 'SumYX.'i'='SumYX.i
   end i
*/
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
   do i=2 to NIndependents+1
      ii=i-1
      yHat=yHat + b.i.1*x.ii.n
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
/* --- begin subroutine - ScreenPrint:                           -------------*/
ScreenPrint:
Header1=''
Header2=''
Table=''
do i=1 to NIndependents
   Header1=Header1'    x.'i' '
   Header2=Header2'_______ '
   Table=  Table'left(x.'i'.n,7) '
   end i

say
say Header1 '     y y estimate    delta    delta^2'
say Header2 '______ __________ __________ __________'

do n=1 to x.0
   yHat=b.1.1
   do i= 1 to NIndependents
      ii=i+1
      yHat=yHat + b.ii.1*x.i.n
      end i
  
   interpret 'say ' Table ,
                ||'right(y.n,7)',
                ||' right(yHat,10)',
                ||' right(format(y.n-yHat,,3,3,3),10)',
                ||' right(format(pow(y.n-yHat,2),,3,3,3),10)'
   end n

return
/* --- end  subroutine  - ScreenPrint:                          -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FilePrint:                            -------------*/
FilePrint:

rc=lineout(print,'Input file: 'in)
rc=lineout(print,'Date:       'date())
rc=lineout(print,'Time:       'time())
Solution=b.1.1
do i=2 to NIndependents+1
   Solution=Solution' + 'b.i.1'*x.'i-1
   end i
rc=lineout(print,'y = 'Solution)
rc=lineout(print,'Standard Error of Estimate: 'SE)
rc=lineout(print,'')

Precision=digits()+3
Header1=''
Header2=''
Table=''

Header1=right('n',Precision,' ')
Header2=right('',Precision,'_')

do i=1 to NIndependents

   Header1=Header1 right('x.'i,Precision,' ')
   Header2=Header2 right('',Precision,'_')
   Table=  Table 'right(x.'i'.n,Precision) '
   end i

say
rc=lineout(print,Header1 right('y',Precision) right('y estimate',Precision),
           right('delta',Precision) right('delta^2',Precision))
rc=lineout(print,Header2 right('',Precision,'_') right('',Precision,'_') ,
           right('',Precision,'_') right('',Precision,'_'))

do n=1 to x.0
   yHat=b.1.1
   do i= 1 to NIndependents
      ii=i+1
      yHat=yHat + b.ii.1*x.i.n
      end i
  
   interpret 'rc=lineout(print,right(n,Precision)' Table ,
                ||' right(y.n,Precision)',
                ||' right(yHat,Precision)',
                ||' right(format(y.n-yHat,,3,3,3),Precision)',
                ||' right(format(pow(y.n-yHat,2),,3,3,3),Precision))'
   end n

return
/* --- end  subroutine  - FilePrint:                            -------------*/
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
