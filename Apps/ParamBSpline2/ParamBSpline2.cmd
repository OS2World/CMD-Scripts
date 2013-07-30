/* Compute Bspline curve in n dimensions against a parametric variable.      */
/*    If needed parameterization is done by computing the square root of the */
/*    sum of distances in n dimensions between subsequent points.  See       */
/*    subroutine Fillu().                                                    */
/* Based on FORTRAN library FITPACK by Paul Dierckx.  The library may be     */
/* obtained from www.netlib.org                                              */
/*                                                                           */
/* Doug Rickman Sept. 5, 2000                                                */
/*    doug@hotrocks.msfc.nasa.gov                                            */
/*    Global Hydrology and Climate Center                                    */
/*    MSFC/NASA                                                              */
/*    Huntsville, AL 35812                                                   */
/*                                                                           */
/* Design notes:                                                             */
/*                                                                           */
/* The code uses only ANSI standard functions!  (At least as far as I know.) */
/*    Therefore it should run on virtually any REXX interpreter.             */
/* Error messages are given to the user via the "SAY" instruction.  The      */
/*    is generated in the subroutine which detects the error.                */
/* The first subroutine after the main program provides a brief help page.   */
/*    The routines to read input, fill arrays used by the bspline routine,   */
/*    and write the output data follow.  They are in alphabetic order. The   */
/*    bspline routines are last.                                             */
/*                                                                           */
/* Change History:                                                           */
/* Oct. 2, 2000 Redefined input. Rearranged main program into subroutines.   */
/*              Added ability to specify a variable to be used as u.         */
/*              Added multiple options for specifying output point locations.*/
/*                                                                           */
/* License:                                                                  */
/* You are free to use the program as desired.  No warranty is provided.     */
/* The basic concepts are extremely powerful and like any sharp tool misuse  */
/* and ignorance can cause problems.                                         */
/*                                                                           */
/* If you use this program to produce publications, professional reports or  */
/* technical presentations please give credit where credit is due.  I also   */
/* live in a "publish or perish" environment.  A **LOT** of creative hours   */
/* went into this code.  Could you have done your job with out it?           */
/* Fair enough?                                                              */
/*                                                                           */
/* I also would find it interesting to learn about your work and how you use */
/* the program.  I have publications in fields ranging from several          */
/* unrelated disciplines in geology, two unrelated fields of medicine (MRI   */
/* and low vision), archaeology, forestry, image processing, remote sensing, */
/* precision agriculture, systems engineering and software design.  In other */
/* words, I am curious and happy to learn.                                   */   
/*                                                                           */
/* You are free to modify the code.  I presume copyright is retained by NASA.*/
/*                                                                           */

arg in ControlMode
in          = strip(in)
ControlMode = strip(translate(ControlMode))

/* Sanity checks first. */
if in='' | in='?' | in='-?' | in='/?' then call Help

in=stream(in,'c','query exists')
if in = '' then do
   say 'The input file: 'in' is not a valid file.  Stopping!'   
   return 0
   end
/* We now have the full name, including drive and path in the variable "in". */

rc=stream(in,'c','open read')
if rc \= 'READY:' then do
   say 'The input file: 'in' could not be opened for reading.'
   say 'Is it locked by another program?  Stopping!'
   return 0
   end 

rc = ReadData(in)
if rc \= 1 then return 0

ExposeList = 'Mode Knots Degree Smooth NewPoints UParam WParam OutputMode OutputFile idim'
rc = ReadValues()
if rc \= 1 then return 0

rc = FillWeight(idim,WParam)
if rc \= 1 then return 0

rc = Fillx()
if rc \= 1 then return 0

rc = Fillu(UParam,idim)
if word(rc,1) \= 1 then return 0
parse var rc . ub ue UParam

if Mode = -1 then do
   TotalKnots = FillKnots(Knots,Degree,ub,ue)
   /* Maybe I should call this subroutine "WoodPutty".        */
   if TotalKnots < 0 then return 0
   end

rc = FillEvaluationPoints(OutputMode,NewPoints)
if rc \= 1 then return 0

/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */
/* Fix certain variables as used by the BSpline routines.                    */
ipar   = 1          
iopt   = Mode
k      = Degree

if Smooth = '' then 
   Smooth = Variable.0
s      = Smooth

m      = Variable.0
n      = TotalKnots
mx     = m * idim
nest   = m + k + 1
nc     = nest*idim

sp.0   = mx
wrk.0  = m*(k+1)+nest*(6+idim+3*k)
c.0    = nc
t.0    = nest
u.0    = Variable.0
w.0    = Variable.0
x.0    = Variable.0 * idim
iwrk.0 = nest

lwrk   = wrk.0
iwrk   = nest

If ControlMode \= 'P' then do
   rc = WriteConfiguration(OutputFile,Mode,Degree,Knots,Variable.0,Smooth,ub,ue,idim,UParam,WParam,OutputMode)
   if rc \= 1 then return 0
   end


/* And it is "Katie, "Bar the door!"" */
call parcur


if ier = 10 then do
   say 'Fatal error returned by BSpline algorithm.  You probably have messed'
   say 'up the input.  Stopping!'
   return 0
   end

If ControlMode \= 'P' then do
   rc = WriteProcessStatus(OutputFile,UParam,WParam)
   if rc = 0  then 
      say 'Warning: BSpline algorithm has complained.  Processing continues.'
   if rc = -1 then
      return 0
   end


/* Evaluate the spline curve at the requested points.                        */
/* First copy the u2. array (points to be evaluated) into u.                 */
m    = u2.0      /* m  is the total number of points to process. */
mx   = m * idim  /* mx is the size of the sp array.              */
do copyindex = 1 to u2.0
   u.copyindex = u2.copyindex
   end copyindex
u.0 = u2.0

call curevstarter

rc =  WriteEvaluationPoints(OutputFile,UParam)

say 'ParamBSpline2 is done.'

/* We done.  Bye Bye.   */
/* End of main routine. */
return 1 


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Help:                                 -------------*/
Help:
rc= charout(,'ParamBSpline2:'||'0d0a'x)
say '   Generate values along a smoothed curve from sequential points in'
say '   n-dimensional data.'

say ''
rc= charout(,'usage:')
say ' ParamBSpline in'
say ''

rc= charout(,'where:')
say ' in   = ASCII file containing control data and input values.'
say '       mode = if mode = "p" only interpolated points are written.'

rc= charout(,'exam: ')
say ' ParamBSpline data.txt '
say ''

rc= charout(,'notes:')
say ' The "in" file contains control and data. The format is self explanatory.'
say ' Error messages are written to standard out.'
say ' Based on FORTRAN library FITPACK by Paul Dierckx.  Not all functionality'
say ' in the parent library is made available in ParamBSpline.cmd.'
say ' Read the comments in subroutines mnparc and parcuv.  Also see "Curve and'
say ' Surface Fitting with Splines", by P. Dierckx, Monographs on Numerical'
say ' Analysis, Oxford University Press, 1993, ISBN 0-19-853441-8.'

say ''
say 'Doug Rickman  Sept. 5, 2000; Oct. 1, 2000'
exit
return

/* --- end  subroutine - Help:                                  -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FillEvaluationPoints:                 -------------*/
/* Determine number of sample points that will be output.                    */
/* Store the points to be used in output in the u2. array.                   */
FillEvaluationPoints:
procedure expose Variable. u. u2.

OutputMode  = arg(1)
NewPoints   = arg(2)

ub          = u.1
Last = u.0
ue   = u.Last

select
   when translate(OutputMode) = 'INTERPOLATE' then do
      kk = 0
      do j = 1 to Variable.0-1
         jp1   = j+1
         kk    = kk+1
         u2.kk = u.j
         /* say right(kk,3) '  ' u2.kk */
         Du  = u.jp1 - u.j
         Dui = Du / (NewPoints+1)
         do kkk = 1 to NewPoints
            kk    = kk+1
            u2.kk = u.j + kkk*Dui
            /* say right(kk,6) u2.kk */
            end kkk
         end j
      /* Last point */
      kk    = kk+1
      u2.kk = u.j
      /* say right(kk,3) '  ' u2.kk */
      u2.0 = kk
      end

   when translate(OutputMode) = 'RESAMPLE' then do 
      /* First Point. */
      kk = 1
      u2.kk = u.kk
   
      /* Distance between points. */
      Dui = (ue-ub) / (NewPoints+1)
      do j = 1 to NewPoints
         kk    = kk+1
         u2.kk = ub + Dui*j
         end j

      /* Last point */
      kk    = kk+1
      u2.kk = ue
      u2.0 = kk
      end

   when translate(OutputMode) = 'FIXED' then do 
      kk = 0 
      if ub>= 0 then 
         Start  = ub%NewPoints
      else
         Start  = (ub%NewPoints) - NewPoints
      /* First Point. */
      if Start <= ub then do
         kk = 1
         u2.kk = u.kk
         end

      do i = Start to ue by NewPoints
         if i <= ub then iterate i
         if i >= ue then leave i
         kk = kk+1
         u2.kk = i
         end i

      /* Last point */
      kk    = kk+1
      u2.kk = ue
      u2.0 = kk
      end

   when translate(OutputMode) = 'SPECIFIED' then do 
      k    = 0
      do i = 1 to words(NewPoints)
         parse var NewPoints v NewPoints
         if v < ub | v > ue then iterate i
         k = k + 1
         u2.k = v
         end i
      if k = 0 then do 
         say 'Warning:  None of the points specified for output are within'
         say 'the range of the input data.  Processing continues.'
         end
      u2.0 = k
      end

   when translate(OutputMode) = 'DOLOOP' then do 
      parse var NewPoints Loop equal Start to Stop by Step .
      /* Sanity checks. */
      if equal         = '='  &,
         translate(to) = 'TO' &,
         translate(by) = 'BY' &,
         datatype(Start,'N')  &,
         datatype(Stop ,'N')  &,
         datatype(Step ,'N')  then nop
      else do
         say 'The OutputMode parameter is not correctly formated.  Stopping!'
         return 0
         end

      if Start < ub | Stop > ue then do
         say 'Warning: The DO loop specified in the OutputMode parameter will'
         say 'create points outside of the input data range.  Do you know what'
         say 'you are doing?  Processing continues.'
         end

      if Step = 0 then do 
         say 'The value of "p" in the OutputMode parameter can not be 0.'
         return 0
         end

      if Step > 0 & Stop < Start then do
         say 'In the OutputMode parameter the value of "p" is positive but'
         say 'n is less than m.  Stopping!'
         return 0
         end

      if Step < 0 & Stop > Start then do
         say 'In the OutputMode parameter the value of "p" is negative but'
         say 'n is greater than m.  Stopping!'
         return 0
         end

      /* Now build u2. array. */
      kk = 0
      do i = Start to Stop by Step
         kk = kk+1
         u2.kk = i
         end
      ub = u2.1
      ue = u2.kk
      u2.0 = kk  
      end

   otherwise do
      say 'You have an invalid output mode:' Outputmode
      say 'Stopping!'
      return 0
      end
   end

return 1
/* --- end  subroutine - FillEvaluationPoints:                  -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FillKNots:                            -------------*/
/* Position knots over range of input.                                       */  
/* Set up the knot locations if we are using a  weighted least-squares spline*/
/* curve.  Create evenly spaced knots between ends, ub and ue                */
FillKnots:
procedure expose Variable. t. 

Knots  = arg(1)
Degree = arg(2)
ub     = arg(3)
ue     = arg(4)

/* Has Knots been set to a positive integer and of proper size?           */
if datatype(Knots ,'W') &,
 Knots <= Variable.0-Degree-1 then 
   nop
else do
   say 'When doing a least squares spline (Mode=-1) the parameter "Knots" must'
   say 'be set to an integer >= 0 and <= NInputPoints-Degree-1. You have 'Variable.0
   say 'points and degree 'Degree'.  Therefore Knots must be <= 'Variable.0-Degree-1
   say 'Reread instructions.  Stopping!'
   return -1
   end

n   = Knots+2+(2*Degree)
j   = Degree+2
dui = 1/(Knots+1)
do i=1 to Knots
   t.j  = (ue-ub)*i*dui
   j = j+1
   end i
return n
/* --- end  subroutine - FillKNots:                             -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Fillu:                                -------------*/
/* Load the u(i).                                                            */
/* u.i is the parameter against which all the other variables are ordered.   */
/* In the simple case of an X,Y graph they are the x values.                 */
/* Remember, u.i-1 < u.i < u.i+1 must be satisfied.                          */
Fillu:
procedure expose  Variable. AllVariable. UseVariable. x. u.

UParam = arg(1)
idim   = arg(2)

m      = Variable.0

if UParam \= '' then do
   /* Use an input variable as the u.i.  First do a series of checks.        */
   /* Is UParam in the list of All Variables?                                */
   do i = 1 to AllVariable.0
      if UParam = AllVariable.i then leave i
      end i
   if i = AllVariable.0+1 then do
      say 'Your UParam, "'UParam'" is not in the list of all variables.  Stopping!'
      return 0
      end

   /* Is UParam in the list of Use Variables?                                */
   do i = 1 to UseVariable.0
      if UParam = UseVariable.i then leave i
      end i
   if i \= UseVariable.0+1 then do
      say 'Your UParam, "'UParam'" is also in the Use Variable list.  Stopping!'
      return 0
      end

  /* Copy the values to u.i and check if the values in ascending order?      */
   u.1 = Variable.UParam.1
   do i = 2 to Variable.0
      u.i = Variable.UParam.i
      im1 = i - 1
      if u.i <= u.im1 then do
         say 'The u parameter values are not in increasing order at point 'i'.'
         say 'Stopping!'
         return 0
         end
      end i
   im1 = i - 1
   ub = u.1
   ue = u.im1
   end 

/* Not using an existing parameter.  Therefore setup the default u.i         */
else do /* This loop copied from parcur */
   i1   = 0
   i2   = idim
   u.1  = 0
   do i=2 to Variable.0
      dist = 0.
      do j=1 to idim
         i1 = i1+1
         i2 = i2+1
         dist = dist+(x.i2 -x.i1 )**2
         end j
   
      im1 = i-1
      u.i  = u.im1 + SQRT(dist,9)
      end i   
   if(u.m  <= 0.) then return 0
   /* Scale from 0 to 1. */   
   do i=2 to m
      u.i  = u.i /u.m
      end i
   
   ub   = 0
   ue   = 1
   u.m  = ue
   UParam = 'u(i)'
   end /* else do ... */

u.0 = Variable.0

return 1 ub ue UParam
/* --- end  subroutine - Fillu:                                 -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FillWeight:                           -------------*/
/* Fill the weight array.  The logic permits a variable to be used as both a */
/* weight and a dimension.                                                   */
FillWeight:
procedure expose Variable. AllVariable. w. 

idim   = arg(1)
WParam = arg(2)

/* Defaults */
do i = 1 to Variable.0
   w.i = 1
   end i


if WParam = '' then 
   return 1
else do
   /* Use an input variable as the w.i.  First do a series of checks.        */
   /* Is WParam in the list of All Variables?                                */
   do i = 1 to AllVariable.0
      if WParam = AllVariable.i then leave i
      end i
   if i = AllVariable.0+1 then do
      say 'Your Weights, "'WParam'" is not in the list of all variables.  Stopping!'
      return 0
      end
   end

/* Are we using a weight factor?  If so replace the weight array.            */
name = WParam
do j = 1 to Variable.0
   w.j = Variable.name.j
   if w.j <= 0 then do
      say 'Weight for point 'j' is less than or equal to zero.  Stopping!'
      return 0
      end
   end j

return 1

/* --- end  subroutine - FillWeight:                            -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Fillx:                                -------------*/
/* Load the x. variable with properly indexed values.  This is what allows   */
/* the user to select and suffle the variables to use.                       */
Fillx:
procedure expose Variable. UseVariable. x.

do i = 1 to UseVariable.0
   Name = UseVariable.i
   do j = 1 to Variable.0
      index   = (j-1)*UseVariable.0 + i
      x.index = Variable.name.j
      end j
   end i
return 1
/* --- end  subroutine - Fillx:                                 -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - ReadData:                             -------------*/
/*    Read the entire input file, dropping comments and blanks.              */
ReadData:
procedure expose data.

in = arg(1)

j=0
do i = 1
   data = linein(in)
   parse var data data '/*' .
   data = strip(data)
   if words(data) = 0 then nop
   else do
      j      = j+1
      data.j = data
      end
   if lines(in) = 0 then leave i
   end i
data.0 = j
rc=stream(in,'c','close')
return 1
/* --- end  subroutine - ReadData:                              -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - ReadValues:                           -------------*/
/* Data are assumed to follow the Use Variables list.                        */
/* First Identify parameters and variables.                                  */
ReadValues:
procedure expose (ExposeList) data. Variable. AllVariable. UseVariable. 

do i = 1 to data.0
   parse var data.i v1 '=' v2
   select 
      when translate(v1) = 'MODE'      then Mode   = strip(v2)
      when translate(v1) = 'KNOTS'     then Knots  = strip(v2)
      when translate(v1) = 'DEGREE'    then Degree = strip(v2)
      when translate(v1) = 'SMOOTH'    then Smooth = strip(v2)
      when translate(v1) = 'NEWPOINTS' then 
         NewPoints = strip(v2)
      when translate(v1) = 'UPARAM'    then UParam = strip(v2)
      when translate(v1) = 'WEIGHTS'   then WParam = strip(v2)
      when translate(v1) = 'OUTPUTMODE'    then do
         parse var v2 OutputMode NewPoints
         NewPoints = strip(NewPoints)
         end
      when translate(v1) = 'OUTPUTFILE'    then OutputFile    = strip(v2)
      when translate(v1) = 'ALL VARIABLES' then do
         v2 = strip(v2)
         do j = 1 to words(v2)
            parse var v2 AllVariable.j v2
            end j
         AllVariable.0 = j-1
         end /* do */
      when translate(v1) = 'USE VARIABLES' then do
         v2 = strip(v2)
         do j = 1 to words(v2)
            parse var v2 UseVariable.j v2
            end j
         UseVariable.0 = j-1
         idim          = j-1         
         end
      when translate(v1) = 'DATA'      then leave i
      otherwise do
         say 'What is this stuff you give me? - 'data.i
         say 'You have messed up the input file.  I refuse to work.  Stopping!'
         return 0
         end
      end  /* select */
   end i

/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */
/* Are all of the Use Variables in the list of All Variables?                */
do k = 1 to UseVariable.0
   do j = 1 to AllVariable.0
      if UseVariable.k = AllVariable.j then leave j
      end j
   if j = AllVariable.0+1 then do
      say 'You have a variable to use, "'UseVariable.k'" which is not in the'
      say 'list of all variables.  Stopping!'
      return 0
      end
   end k

/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */
/* Now convert all remaining data records as a table of data.                */
do j= 1 to data.0-i
   i = i+1
   data.i = translate(data.i,'20'x,'09'x)
   /* Check to see that the correct number of columns are present.           */
   if AllVariable.0 \= words(data.i) then do
      say 'Row 'j' of the input data table does not have 'AllVariable.0' columns.'
      say 'Stopping!'
      return 0
      end

   do kk = 1 to AllVariable.0
      name = AllVariable.kk
      Variable.name.j = word(data.i,kk)
      end kk
   end j
Variable.0 = j-1 /* The number of points. */

return 1
/* --- end  subroutine - ReadValues:                            -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - WriteConfiguration:                   -------------*/
/* Record what is about to happen.                                           */
WriteConfiguration:
procedure expose UseVariable. u2.

OutputFile = arg(1)
iopt       = arg(2)
k          = arg(3)
Knots      = arg(4)
m          = arg(5)
s          = arg(6)
ub         = arg(7)
ue         = arg(8)
idim       = arg(9)
UParam     = arg(10)
WParam     = arg(11)
OutputMode = arg(12)

rc = lineout(OutputFile,'Started at 'date() ' ' time('C'))

if iopt = 0 then do
   rc = lineout(OutputFile,'Computing a smoothing spline of degree 'k' in 'idim' dimensional space.')
   rc = lineout(OutputFile,'The smoothing factor is 's'.')
   end
else do
   rc = lineout(OutputFile,'Computing a weighted least squares spline with 'Knots' internal knots,')
   rc = lineout(OutputFile,'   of degree 'k' in 'idim' dimensional space.')
   end
rc = lineout(OutputFile,)
rc = lineout(OutputFile, m 'points were read.')
if WParam \= '' then 
   rc = lineout(OutputFile, 'Sample weights from variable 'WParam' will be used in the analysis.')
rc = lineout(OutputFile, 'Analysis will be done against the parameter 'UParam)
rc = lineout(OutputFile, u2.0 OutputMode' points will be output over the range 'ub' to 'ue'.')

/* Build list of variables that will be used. */   
txt1 = ''
txt2 = ''
do i = 1 to UseVariable.0
   if UseVariable.i = 'W' then do
      iterate i
      end
   txt1 = txt1 UseVariable.i
   end i
rc = lineout(OutputFile,'Variables to use are 'txt1 txt2)

rc = lineout(OutputFile,' ')
rc = lineout(OutputFile,' ')

/* This way the file can be read while processing continues. */
rc = stream(OutputFile,'c','close') 

return 1
/* --- end  subroutine - WriteConfiguration:                    -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - WriteEvaluationPoints:                -------------*/
WriteEvaluationPoints:
procedure expose UseVariable. Variable. NewPoints idim m u. sp. w.

OutputFile = arg(1)
UParam     = arg(2)
WParam     = arg(3)

/* Build the header line. */
txt1 = center(UParam,12)

do i = 1 to UseVariable.0
   if UseVariable.i = 'W' then iterate i
   txt1 = txt1 center(strip(left(UseVariable.i,13)),13)
   end i
rc = lineout(OutputFile,txt1)
rc = lineout(OutputFile,' ')

do i = 1 to u.0
   txt = format(u.i,3,4,2,0)
   do j=1 to idim
      index = (i-1)*idim +j
      txt = txt format(sp.index,3,4,2,0) 
      end j
   rc = lineout(OutputFile,txt)
   end i

return 1
/* --- end  subroutine - WriteEvaluationPoints:                 -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - WriteInputValues:                     -------------*/
WriteInputValues:
procedure expose UseVariable. idim u. m x. sp. w.

OutputFile = arg(1)
UParam     = arg(2)
WParam     = arg(3)

txt1 = 'Echo of input with fitted estimates:'
txt2 = '----------------------------------- '
rc = lineout(OutputFile,txt1)
rc = lineout(OutputFile,txt2)

/* Set up the header lines. */
if WParam \= '' then do
   txt1 = 'Sample' center(UParam,13) center('Weight',13)
   txt2 = '                                  '
   end

else do
   txt1 = 'Sample' center(UParam,13)
   txt2 = '                    '
   end

do i = 1 to UseVariable.0
   txt1 = txt1 center(strip(left(UseVariable.i,13)),13)
   txt2 = txt2 center('Observed',13)
   end i
do i = 1 to UseVariable.0
   txt1 = txt1 center(strip(left(UseVariable.i,13)),13)
   txt2 = txt2 center('Computed',13)
   end i
rc = lineout(OutputFile,txt1)
rc = lineout(OutputFile,txt2)

/* Print the values. */
do i = 1 to m
   if WParam \= '' then 
      txt = right(i,6) format(u.i,3,4,2,0) format(w.i,3,4,2,0)
   else 
      txt = right(i,6) format(u.i,3,4,2,0)

   do j=1 to idim
      index = (i-1)*idim +j
      txt = txt format(x.index,3,5,2,0)
      end j
   do j=1 to idim
      index = (i-1)*idim +j
      txt = txt format(sp.index,3,4,2,0) 
      end j
   rc = lineout(OutputFile,txt)
   end i

rc = lineout(OutputFile,' ')
rc = lineout(OutputFile,' ')
txt1 = 'Estimates at requested locations: '
txt2 = '--------------------------------  '
rc = lineout(OutputFile,txt1)
rc = lineout(OutputFile,txt2)

return 1
/* --- end  subroutine - WriteInputValues:                      -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - WriteProcessStatus:                   -------------*/
WriteProcessStatus:
procedure expose idim t. n c. nc k u. m sp. mx ier x. UseVariable. fp w.

OutputFile = arg(1)
UParam     = arg(2)
WParam     = arg(3)

ReturnCode = 1
if ier >  0 then ReturnCode = 0

rc = lineout(OutputFile,'sum squared residuals =' format(fp,4,6,,0) )
select
   when ier=0  then 
      txt = 'Normal return. The curve returned has a residual sum of squares',
            'that is within tolerance.'
   when ier=-1 then 
      txt = 'Normal return. The curve returned is an interpolating spline',
            'curve.'
   when ier=-2 then 
     txt = 'Normal return. The curve returned is the weighted least squares',
           'polynomial curve of degree k.  In this extreme case fp gives',
           'the upper bound for the smoothing factor s.'
   when ier=1 then
      txt = 'error. Either s is too small or Doug messed up. The',
            'approximation returned is the least-squares spline curve',
            'and fp gives the corresponding weighted sum of squared residuals.'
   when ier=2 then 
      txt = 'error. A theoretically impossible result was found. s may be too',
            'small.  An approximation is given but the corresponding tolerance',
            'is not acceptable.'
   when ier=3 then
      txt = 'error. The number of iterations is too great. Probably s is too',
            'small.  An approximation is given but the corresponding tolerance',
            'is not acceptable.'
   when ier=10 then 
      txt = 'The input data are not valid.  Either format of input is bad',
            'or data distribution with respect to the knots is defective.',
            'Reread instructions and check data format and/or decrease the',
            'value of Knot or add more data to even out the spatial distribution',
            'of points.'
   otherwise say 'Huh?  What kind of an error is this in WriteProcessStatus?'
   end  /* select */
rc = lineout(OutputFile,txt)
rc = lineout(OutputFile,' ')
rc = lineout(OutputFile,'Total number of all knots =' format(n,3,0))
rc = lineout(OutputFile,'Position of the knots in u(i)')
txt = '    '
do i = 1 to n   
   txt = txt||format(t.i,8,4)
   end i
rc = lineout(OutputFile,txt)
rc = lineout(OutputFile,' ')

/*  We evaluate the spline curve at the original points.                     */
call curevstarter

rc = lineout(OutputFile,' ')
rc = lineout(OutputFile,' ')

rc = WriteInputValues(OutputFile,UParam,WParam)
if rc \= 1 then return -1

return ReturnCode
/* --- end  subroutine - WriteProcessStatus:                    -------------*/
/* --------------------------------------------------------------------------*/



/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */
/* Bspline software follows.                                                 */
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

parcur:
procedure expose  iopt ipar idim m u. mx x. w. ub ue k s nest n t. nc c. fp wrk. lwrk iwrk. ier

/*  given the ordered set of m points x(i) in the idim-dimensional space     */
/*  and given also a corresponding set of strictly increasing values u(i)    */
/*  and the set of positive numbers w(i),i=1,2,...,m, subroutine parcur      */
/*  determines a smooth approximating spline curve s(u), i.e.                */
/*      x1 = s1(u)                                                           */
/*      x2 = s2(u)       ub <= u <= ue                                       */
/*      .........                                                            */
/*      xidim = sidim(u)                                                     */
/*  with sj(u),j=1,2,...,idim spline functions of degree k with common       */
/*  knots t(j),j=1,2,...,n.                                                  */
/*  if ipar=1 the values ub,ue and u(i),i=1,2,...,m must be supplied by      */
/*  the user. if ipar=0 these values are chosen automatically by parcur      */
/*  as  u(1) = 0                                                             */
/*      u(i) = u(i-1) + dist(x(i),x(i-1)) ,i=2,3,...,m                       */
/*      u(i) = u(i)/u(m) ,i=1,2,...,m                                        */
/*      ub = u(1) = 0, ue = u(m) = 1.                                        */
/*  if iopt=-1 parcur calculates the weighted least-squares spline curve     */
/*  according to a given set of knots.                                       */
/*  if iopt>=0 the number of knots of the splines sj(u) and the position     */
/*  t(j),j=1,2,...,n is chosen automatically by the routine. the smooth-     */
/*  ness of s(u) is then achieved by minimalizing the discontinuity          */
/*  jumps of the k-th derivative of s(u) at the knots t(j),j=k+2,k+3,...,    */
/*  n-k-1. the amount of smoothness is determined by the condition that      */
/*  f(p)=sum((w(i)*dist(x(i),s(u(i))))**2) be <= s, with s a given non-      */
/*  negative constant, called the smoothing factor.                          */
/*  the fit s(u) is given in the b-spline representation and can be          */
/*  evaluated by means of subroutine curev.                                  */
/*                                                                           */
/*  calling sequence:                                                        */
/*     call parcur(iopt,ipar,idim,m,u,mx,x,w,ub,ue,k,s,nest,n,t,nc,c,        */
/*    * fp,wrk,lwrk,iwrk,ier)                                                */
/*                                                                           */
/*  parameters:                                                              */
/*   iopt  : integer flag. on entry iopt must specify whether a weighted     */
/*           least-squares spline curve (iopt=-1) or a smoothing spline      */
/*           curve (iopt=0 or 1) must be determined.if iopt=0 the routine    */
/*           will start with an initial set of knots t(i)=ub,t(i+k+1)=ue,    */
/*           i=1,2,...,k+1. if iopt=1 the routine will continue with the     */
/*           knots found at the last call of the routine.                    */
/*           attention: a call with iopt=1 must always be immediately        */
/*           preceded by another call with iopt=1 or iopt=0.                 */
/*           unchanged on exit.                                              */
/*   ipar  : integer flag. on entry ipar must specify whether (ipar=1)       */
/*           the user will supply the parameter values u(i),ub and ue        */
/*           or whether (ipar=0) these values are to be calculated by        */
/*           parcur. unchanged on exit.                                      */
/*   idim  : integer. on entry idim must specify the dimension of the        */
/*           curve. 0 < idim < 11.                                           */
/*           unchanged on exit.                                              */
/*   m     : integer. on entry m must specify the number of data points.     */
/*           m > k. unchanged on exit.                                       */
/*   u     : real array of dimension at least (m). in case ipar=1,before     */
/*           entry, u(i) must be set to the i-th value of the parameter      */
/*           variable u for i=1,2,...,m. these values must then be           */
/*           supplied in strictly ascending order and will be unchanged      */
/*           on exit. in case ipar=0, on exit,array u will contain the       */
/*           values u(i) as determined by parcur.                            */
/*   mx    : integer. on entry mx must specify the actual dimension of       */
/*           the array x as declared in the calling (sub)program. mx must    */
/*           not be too small (see x). unchanged on exit.                    */
/*   x     : real array of dimension at least idim*m.                        */
/*           before entry, x(idim*(i-1)+j) must contain the j-th coord-      */
/*           inate of the i-th data point for i=1,2,...,m and j=1,2,...,     */
/*           idim. unchanged on exit.                                        */
/*   w     : real array of dimension at least (m). before entry, w(i)        */
/*           must be set to the i-th value in the set of weights. the        */
/*           w(i) must be strictly positive. unchanged on exit.              */
/*           see also further comments.                                      */
/*   ub,ue : real values. on entry (in case ipar=1) ub and ue must           */
/*           contain the lower and upper bound for the parameter u.          */
/*           ub <=u(1), ue>= u(m). if ipar = 0 these values will             */
/*           automatically be set to 0 and 1 by parcur.                      */
/*   k     : integer. on entry k must specify the degree of the splines.     */
/*           1<=k<=5. it is recommended to use cubic splines (k=3).          */
/*           the user is strongly dissuaded from choosing k even,together    */
/*           with a small s-value. unchanged on exit.                        */
/*   s     : real.on entry (in case iopt>=0) s must specify the smoothing    */
/*           factor. s >=0. unchanged on exit.                               */
/*           for advice on the choice of s see further comments.             */
/*   nest  : integer. on entry nest must contain an over-estimate of the     */
/*           total number of knots of the splines returned, to indicate      */
/*           the storage space available to the routine. nest >=2*k+2.       */
/*           in most practical situation nest=m/2 will be sufficient.        */
/*           always large enough is nest=m+k+1, the number of knots          */
/*           needed for interpolation (s=0). unchanged on exit.              */
/*   n     : integer.                                                        */
/*           unless ier = 10 (in case iopt >=0), n will contain the          */
/*           total number of knots of the smoothing spline curve returned.   */
/*           If the computation mode iopt=1 is used this value of n          */
/*           should be left unchanged between subsequent calls.              */
/*           In case iopt=-1, the value of n must be specified on entry.     */
/*           n = k*2 + (Number of internal knots + 2) DLR                    */
/*   t     : real array of dimension at least (nest).                        */
/*           on succesful exit, this array will contain the knots of the     */
/*           spline curve, i.e. the position of the interior knots t(k+2),   */
/*           t(k+3),..,t(n-k-1) as well as the position of the additional    */
/*           t(1)=t(2)=...=t(k+1)=ub and t(n-k)=...=t(n)=ue needed for       */
/*           the b-spline representation.                                    */
/*           if the computation mode iopt=1 is used, the values of t(1),     */
/*           t(2),...,t(n) should be left unchanged between subsequent       */
/*           calls. If the computation mode iopt=-1 is used, the values      */
/*           t(k+2),...,t(n-k-1) must be supplied by the user, before        */
/*           entry. See also the restrictions (ier=10).                      */
/*   nc    : integer. on entry nc must specify the actual dimension of       */
/*           the array c as declared in the calling (sub)program. nc         */
/*           must not be too small (see c). unchanged on exit.               */
/*   c     : real array of dimension at least (nest*idim).                   */
/*           on succesful exit, this array will contain the coefficients     */
/*           in the b-spline representation of the spline curve s(u),i.e.    */
/*           the b-spline coefficients of the spline sj(u) will be given     */
/*           in c(n*(j-1)+i),i=1,2,...,n-k-1 for j=1,2,...,idim.             */
/*   fp    : real. unless ier = 10, fp contains the weighted sum of          */
/*           squared residuals of the spline curve returned.                 */
/*   wrk   : real array of dimension at least m*(k+1)+nest*(6+idim+3*k).     */
/*           used as working space. if the computation mode iopt=1 is        */
/*           used, the values wrk(1),...,wrk(n) should be left unchanged     */
/*           between subsequent calls.                                       */
/*   lwrk  : integer. on entry,lwrk must specify the actual dimension of     */
/*           the array wrk as declared in the calling (sub)program. lwrk     */
/*           must not be too small (see wrk). unchanged on exit.             */
/*   iwrk  : integer array of dimension at least (nest).                     */
/*           used as working space. if the computation mode iopt=1 is        */
/*           used,the values iwrk(1),...,iwrk(n) should be left unchanged    */
/*           between subsequent calls.                                       */
/*   ier   : integer. unless the routine detects an error, ier contains a    */
/*           non-positive value on exit, i.e.                                */
/*    ier=0  : normal return. the curve returned has a residual sum of       */
/*             squares fp such that abs(fp-s)/s <= tol with tol a relat-     */
/*             ive tolerance set to 0.001 by the program.                    */
/*    ier=-1 : normal return. the curve returned is an interpolating         */
/*             spline curve (fp=0).                                          */
/*    ier=-2 : normal return. the curve returned is the weighted least-      */
/*             squares polynomial curve of degree k.in this extreme case     */
/*             fp gives the upper bound fp0 for the smoothing factor s.      */
/*    ier=1  : error. the required storage space exceeds the available       */
/*             storage space, as specified by the parameter nest.            */
/*             probably causes : nest too small. if nest is already          */
/*             large (say nest > m/2), it may also indicate that s is        */
/*             too small                                                     */
/*             the approximation returned is the least-squares spline        */
/*             curve according to the knots t(1),t(2),...,t(n). (n=nest)     */
/*             the parameter fp gives the corresponding weighted sum of      */
/*             squared residuals (fp>s).                                     */
/*    ier=2  : error. a theoretically impossible result was found during     */
/*             the iteration proces for finding a smoothing spline curve     */
/*             with fp = s. probably causes : s too small.                   */
/*             there is an approximation returned but the corresponding      */
/*             weighted sum of squared residuals does not satisfy the        */
/*             condition abs(fp-s)/s < tol.                                  */
/*    ier=3  : error. the maximal number of iterations maxit (set to 20      */
/*             by the program) allowed for finding a smoothing curve         */
/*             with fp=s has been reached. probably causes : s too small     */
/*             there is an approximation returned but the corresponding      */
/*             weighted sum of squared residuals does not satisfy the        */
/*             condition abs(fp-s)/s < tol.                                  */
/*    ier=10 : error. on entry, the input data are controlled on validity    */
/*             the following restrictions must be satisfied.                 */
/*             -1<=iopt<=1, 1<=k<=5, m>k, nest>2*k+2, w(i)>0,i=1,2,...,m     */
/*             0<=ipar<=1, 0<idim<=10, lwrk>=(k+1)*m+nest*(6+idim+3*k),      */
/*             nc>=nest*idim                                                 */
/*             if ipar=0: sum j=1,idim (x(idim*i+j)-x(idim*(i-1)+j))**2>0    */
/*                        i=1,2,...,m-1.                                     */
/*             if ipar=1: ub<=u(1)<u(2)<...<u(m)<=ue                         */
/*             if iopt=-1: 2*k+2<=n<=min(nest,m+k+1)                         */
/*                         ub<t(k+2)<t(k+3)<...<t(n-k-1)<ue                  */
/*                            (ub=0 and ue=1 in case ipar=0)                 */
/*                       the schoenberg-whitney conditions, i.e. there       */
/*                       must be a subset of data points uu(j) such that     */
/*                         t(j) < uu(j) < t(j+k+1), j=1,2,...,n-k-1          */
/*             if iopt>=0: s>=0                                              */
/*                         if s=0 : nest >= m+k+1                            */
/*             if one of these conditions is found to be violated,control    */
/*             is immediately repassed to the calling program. in that       */
/*             case there is no approximation returned.                      */
/*                                                                           */
/*  further comments:                                                        */
/*   by means of the parameter s, the user can control the tradeoff          */
/*   between closeness of fit and smoothness of fit of the approximation.    */
/*   if s is too large, the curve will be too smooth and signal will be      */
/*   lost ; if s is too small the curve will pick up too much noise. in      */
/*   the extreme cases the program will return an interpolating curve if     */
/*   s=0 and the least-squares polynomial curve of degree k if s is          */
/*   very large. between these extremes, a properly chosen s will result     */
/*   in a good compromise between closeness of fit and smoothness of fit.    */
/*   to decide whether an approximation, corresponding to a certain s is     */
/*   satisfactory the user is highly recommended to inspect the fits         */
/*   graphically.                                                            */
/*   recommended values for s depend on the weights w(i). if these are       */
/*   taken as 1/d(i) with d(i) an estimate of the standard deviation of      */
/*   x(i), a good s-value should be found in the range (m-sqrt(2*m),m+       */
/*   sqrt(2*m)). if nothing is known about the statistical error in x(i)     */
/*   each w(i) can be set equal to one and s determined by trial and         */
/*   error, taking account of the comments above. the best is then to        */
/*   start with a very large value of s ( to determine the least-squares     */
/*   polynomial curve and the upper bound fp0 for s) and then to             */
/*   progressively decrease the value of s ( say by a factor 10 in the       */
/*   beginning, i.e. s=fp0/10, fp0/100,...and more carefully as the          */
/*   approximating curve shows more detail) to obtain closer fits.           */
/*   to economize the search for a good s-value the program provides with    */
/*   different modes of computation. at the first call of the routine, or    */
/*   whenever he wants to restart with the initial set of knots the user     */
/*   must set iopt=0.                                                        */
/*   if iopt=1 the program will continue with the set of knots found at      */
/*   the last call of the routine. this will save a lot of computation       */
/*   time if parcur is called repeatedly for different values of s.          */
/*   the number of knots of the spline returned and their location will      */
/*   depend on the value of s and on the complexity of the shape of the      */
/*   curve underlying the data. but, if the computation mode iopt=1 is       */
/*   used, the knots returned may also depend on the s-values at previous    */
/*   calls (if these were smaller). therefore, if after a number of          */
/*   trials with different s-values and iopt=1, the user can finally         */
/*   accept a fit as satisfactory, it may be worthwhile for him to call      */
/*   parcur once more with the selected value for s but now with iopt=0.     */
/*   indeed, parcur may then return an approximation of the same quality     */
/*   of fit but with fewer knots and therefore better if data reduction      */
/*   is also an important objective for the user.                            */
/*                                                                           */
/*   the form of the approximating curve can strongly be affected by         */
/*   the choice of the parameter values u(i). if there is no physical        */
/*   reason for choosing a particular parameter u, often good results        */
/*   will be obtained with the choice of parcur (in case ipar=0), i.e.       */
/*        v(1)=0, v(i)=v(i-1)+q(i), i=2,...,m, u(i)=v(i)/v(m), i=1,..,m      */
/*   where                                                                   */
/*        q(i)= sqrt(sum j=1,idim (xj(i)-xj(i-1))**2 )                       */
/*   other possibilities for q(i) are                                        */
/*        q(i)= sum j=1,idim (xj(i)-xj(i-1))**2                              */
/*        q(i)= sum j=1,idim abs(xj(i)-xj(i-1))                              */
/*        q(i)= max j=1,idim abs(xj(i)-xj(i-1))                              */
/*        q(i)= 1                                                            */
/*                                                                           */
/*  other subroutines required:                                              */
/*    fpback,fpbspl,fpchec,fppara,fpdisc,fpgivs,fpknot,fprati,fprota         */
/*                                                                           */
/*  references:                                                              */
/*   dierckx p. : algorithms for smoothing data with periodic and            */
/*                parametric splines, computer graphics and image            */
/*                processing 20 (1982) 171-184.                              */
/*   dierckx p. : algorithms for smoothing data with periodic and param-     */
/*                etric splines, report tw55, dept. computer science,        */
/*                k.u.leuven, 1981.                                          */
/*   dierckx p. : curve and surface fitting with splines, monographs on      */
/*                numerical analysis, oxford university press, 1993.         */
/*                                                                           */
/*  author:                                                                  */
/*    p.dierckx                                                              */
/*    dept. computer science, k.u. leuven                                    */
/*    celestijnenlaan 200a, b-3001 heverlee, belgium.                        */
/*    e-mail : Paul.Dierckx@cs.kuleuven.ac.be                                */
/*                                                                           */
/*  creation date : may 1979                                                 */
/*  latest update : march 1987                                               */
/*                                                                           */
/*  ..                                                                       */
/*  ..scalar arguments..                                                     */
/*      real ub,ue,s,fp                                                       */
/*      integer iopt,ipar,idim,m,mx,k,nest,n,nc,lwrk,ier                      */
/*  ..array arguments..                                                      */
/*      real u(m),x(mx),w(m),t(nest),c(nc),wrk(lwrk)                          */

wrk.0  = lwrk
c.0    = nc
t.0    = nest
w.0    = m
x.0    = mx
u.0    = m
iwrk.0 = nest

/*      integer iwrk(nest)                                                    */
/*  ..local scalars..                                                        */
/*      real tol,dist                                                         */
/*      integer i,ia,ib,ifp,ig,iq,iz,i1,i2,j,k1,k2,lwest,maxit,nmin,ncc       */
/* ..function references                                                     */
/*      real sqrt                                                             */
/*  ..                                                                       */

/*  we set up the parameters tol and maxit                                   */
maxit = 20
tol   = 0.1e-02

/*  before starting computations a data check is made. if the input data     */
/*  are invalid, control is immediately repassed to the calling program.     */
ier = 10
if(iopt < (-1) ) |  (iopt > 1)  then return
if(ipar < 0 )    |  (ipar > 1)  then return
if(idim <= 0 )   |  (idim > 10) then return
if(k <= 0 )      |  (k > 5)     then return
k1   = k+1
k2   = k1+1
nmin = 2*k1
if(m < k1 ) |  (nest < nmin) then return
ncc = nest*idim
if(mx < m*idim ) |  (nc < ncc) then return
lwest = m*k1+nest*(6+idim+3*k)
if(lwrk < lwest) then return
if ipar = 0 then do 
   /* Compute the geometric distance between points and scale from 0 - 1.    */
   i1   = 0
   i2   = idim
   u.1  = 0.
   do i=2 to m /* do 20 */
      dist = 0.
      do j=1 to idim /* do 10 */
         i1 = i1+1
         i2 = i2+1
         dist = dist+(x.i2 -x.i1 )**2
         end j /* 10 */
   
      im1 = i-1
      u.i  = u.im1 + SQRT(dist,9)
      end i /* 20 */
   
   if(u.m  <= 0.) then return
   
   do i=2 to m /* do 30 */
      u.i  = u.i /u.m
      end i /* 30 */
   
   ub   = 0.
   ue   = 1.
   u.m  = ue
   end 

if(ub > u.1  ) |  (ue < u.m  ) |  (w.1  <= 0.) then return /* Line Number 40 */

do i=2 to m /* do 50 */
   im1 = i-1
   if(u.im1  >= u.i  ) |  (w.i  <= 0.) then return
   end i /* 50 */

if(iopt >= 0) then do /* go to 70 */
   if(s < 0.) then return /* Line Number 70 */
   if(s = 0. ) &  (nest < (m+k1)) then return
   ier = 0
   end

else do
   if(n < nmin ) |  (n > nest) then return
   /* Set the positions of the "external" knots. */
   j = n
   do i=1 to k1 /* do 60 */
      t.i  = ub
      t.j  = ue
      j    = j-1
      end i /* 60 */
   
   call fpchecstarter /* u,m,t,n,k,ier */
   
   if(ier <> 0) then return
   if(s < 0.)   then return /* Line Number 70 */
   if(s = 0. ) &  (nest < (m+k1)) then return
   ier = 0
   end /* else do ... */

/* we partition the working space and determine the spline curve.            */
ifp = 1 /* Line Number 80 */
iz  = ifp+nest
ia  = iz+ncc
ib  = ia+nest*k1
ig  = ib+nest*k2
iq  = ig+nest*k2

call fpparaStarter /* iopt,idim,m,u,mx,x,w,ub,ue,k,s,nest,tol,maxit,k1,k2, n,t,ncc,c,fp,wrk.ifp ,wrk.iz ,wrk.ia ,wrk.ib ,wrk.ig ,wrk.iq , iwrk,ier */
return /* Line Number 90 */
 
/* Converted from BSPLINE\SOURCE\PARCUR.F                                     */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 22 August 2000 4:31pm                                                      */


CurevStarter:
procedure expose idim t.  n c. nc k u. m sp. mx ier
do copyindex = 1 to sp.0
   x.copyindex = sp.copyindex
   end copyindex
call curev
do copyindex = 1 to x.0
   sp.copyindex = x.copyindex
   end copyindex
return


curev:
procedure expose  idim t. n c. nc k u. m x. mx ier

/* call example:
call CurevStarter /* idim,t, n,c, nc,k,u, m,sp,mx,ier */
*/

/*  subroutine curev evaluates in a number of points u(i),i=1,2,...,m        */
/*  a spline curve s(u) of degree k and dimension idim, given in its         */
/*  b-spline representation.                                                 */
/*                                                                           */
/*  calling sequence:                                                        */
/*     call curev(idim,t,n,c,nc,k,u,m,x,mx,ier)                              */
/*                                                                           */
/*  input parameters:                                                        */
/*    idim : integer, giving the dimension of the spline curve.              */
/*    t    : array,length n, which contains the position of the knots.       */
/*    n    : integer, giving the total number of knots of s(u).              */
/*    c    : array,length nc, which contains the b-spline coefficients.      */
/*    nc   : integer, giving the total number of coefficients of s(u).       */
/*    k    : integer, giving the degree of s(u).                             */
/*    u    : array,length m, which contains the points where s(u) must       */
/*           be evaluated.                                                   */
/*    m    : integer, giving the number of points where s(u) must be         */
/*           evaluated.                                                      */
/*    mx   : integer, giving the dimension of the array x. mx >= m*idim      */
/*                                                                           */
/*  output parameters:                                                       */
/*    x    : array,length mx,giving the value of s(u) at the different       */
/*           points. x(idim*(i-1)+j) will contain the j-th coordinate        */
/*           of the i-th point on the curve.                                 */
/*    ier  : error flag                                                      */
/*      ier = 0 : normal return                                              */
/*      ier =10 : invalid input data (see restrictions)                      */
/*                                                                           */
/*  restrictions:                                                            */
/*    m >= 1                                                                 */
/*    mx >= m*idim                                                           */
/*    t(k+1) <= u(i) <= u(i+1) <= t(n-k) , i=1,2,...,m-1.                    */
/*                                                                           */
/*  other subroutines required: fpbspl.                                      */
/*                                                                           */
/*  references :                                                             */
/*    de boor c : on calculating with b-splines, j. approximation theory     */
/*                6 (1972) 50-62.                                            */
/*    cox m.g.  : the numerical evaluation of b-splines, j. inst. maths      */
/*                applics 10 (1972) 134-149.                                 */
/*    dierckx p. : curve and surface fitting with splines, monographs on     */
/*                 numerical analysis, oxford university press, 1993.        */
/*                                                                           */
/*  author :                                                                 */
/*    p.dierckx                                                              */
/*    dept. computer science, k.u.leuven                                     */
/*    celestijnenlaan 200a, b-3001 heverlee, belgium.                        */
/*    e-mail : Paul.Dierckx@cs.kuleuven.ac.be                                */
/*                                                                           */
/*  latest update : march 1987                                               */
/*                                                                           */
/*  ..scalar arguments..                                                     */
/*      integer idim,n,nc,k,m,mx,ier                                         */
/*  ..array arguments..                                                      */
/*      real t(n),c(nc),u(m),x(mx)                                           */
x.0 = mx
u.0 = m
c.0 = nc
t.0 = n
h.0 = 6

/*  ..local scalars..                                                        */
/*      integer i,j,jj,j1,k1,l,ll,l1,mm,nk1                                  */
/*      real arg,sp,tb,te                                                    */
/*  ..local array..                                                          */
/*      real h(6)                                                            */

/*  ..                                                                       */
/*  before starting computations a data check is made. if the input data     */
/*  are invalid control is immediately repassed to the calling program.      */

ier = 10
select
   when (m-1) < 0 then return
   when (m-1) = 0 then nop 
   when (m-1) > 0 then do
      do i=2 to m
         im1 = i-1
         if(u.i  < u.im1 ) then return
         end i
      end
   end /* select */

if(mx < (m*idim)) then return /* Line Number 30 */
ier = 0
/*  fetch tb and te, the boundaries of the approximation interval.           */
k1    = k+1
nk1   = n-k1
tb    = t.k1
nk1p1 = nk1+1
te    = t.nk1p1
l     = k1
l1    = l+1
/*  main loop for the different points.                                      */
mm    = 0
do i=1 to m /* do 80 */
   /*  fetch a new u-value arg.                                              */
   arg = u.i
   if(arg < tb) then arg = tb
   if(arg > te) then arg = te
   /*  search for knot interval t(l) <= arg < t(l+1)                         */
   do Loop2Line40 = 1
      if(arg < t.l1  ) |  (l = nk1) then leave Loop2Line40
      l  = l1
      l1 = l+1
      end Loop2Line40

   /*  evaluate the non-zero b-splines at arg.                               */
   arg = fpbspl(arg) /* t,n,k,arg,l,h */ /* Line Number 50 */

   /*  find the value of s(u) at u=arg.                                      */
   ll = l-k1
   do j1=1 to idim
      jj = ll
      sp = 0.
      do j=1 to k1
         jj = jj+1
         sp = sp+c.jj *h.j
         end j

      mm    = mm+1
      x.mm  = sp
      ll    = ll+n
      end j1
   end i

return /* Line Number 100 */
 
/* Converted from PARCUR\CUREV.F                                             */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.        */
/* 22 August 2000 6:09pm                                                     */



fpbackstarter:
procedure expose a. z. c. nest j1
n = arg(1)
k = arg(2)

/* example call:
rc = fpbackstarter(nk1,k1) /* a,z.j1 ,nk1,k1,c.j1 ,nest */
parse var rc nk1 k1
*/

/* Backup the array sizes and copy the data. */
/* These are reset in the fpback subroutine. */
aSizeIn = a.0
do copyindex = 1 to z.0
   zBackup.copyindex = z.copyindex
   end copyindex
zBackup.0 = z.0
do copyindex = 1 to c.0
   cBackup.copyindex = c.copyindex
   end copyindex
cBackup.0 = c.0

/* You have to know the size of the array in the subroutine being started.   */
j = 0
do i = j1 to j1+n-1  
   j   = j+1
   z.j = z.i
   end i
j = 0
do i = j1 to j1+n-1
   j   = j+1
   c.j = c.i
   end i
fpbackReturn = fpback(n,k)
j = j1-1
do i = 1 to z.0
   j   = j+1
   zBackup.j = z.i
   end i
j = j1-1
do i = 1 to c.0
   j   = j+1
   cBackup.j = c.i
   end i

a.0 = aSizeIn
do copyindex = 1 to zBackup.0
   z.copyindex = zBackup.copyindex
   end copyindex
z.0 = zBackup.0
do copyindex = 1 to cBackup.0
   c.copyindex = cBackup.copyindex
   end copyindex
c.0 = cBackup.0
return fpbackReturn


fpback2starter:
procedure expose g. c. nest k2 j1
n = arg(1)
k = arg(2)

/* example call:
rc = fpback2starter(nk1,k1) /* g, c.j1 ,nk1,k1,c.j1 ,nest */
parse var rc nk1 k1
*/

/* Backup the array sizes and copy the data. */
/* These are reset in the fpback subroutine. */
do copyindex = 1 to c.0
   cBackup.copyindex = c.copyindex
   end copyindex
cBackup.0 = c.0

do i = 1 to nest
   do j = 1 to k
      a.i.j = g.i.j
      end j
   end i

/* You have to know the size of the array in the subroutine being started.   */
j = 0
do i = j1 to j1+n-1  
   j   = j+1
   z.j = c.i
   end i
j = 0
do i = j1 to j1+n-1
   j   = j+1
   c.j = c.i
   end i
fpbackReturn = fpback(n,k)
j = j1-1
do i = 1 to c.0
   j   = j+1
   cBackup.j = c.i
   end i

do i = 1 to nest
   do j = 1 to k
      g.i.j = a.i.j
      end j
   end i

do copyindex = 1 to cBackup.0
   c.copyindex = cBackup.copyindex
   end copyindex
c.0 = cBackup.0
return fpbackReturn



fpback:
procedure expose  a. z. c. nest
n   = arg(1)
k   = arg(2)

/*  FORTRAN code:      subroutine fpback(a,z,n,k,c,nest)                     */
 
/* Example call:
rc = fpback(nk1,k1) /* a,z,nk1,k1,c,nest*/
parse var rc nk1 k1
*/

/*  subroutine fpback calculates the solution of the system of                */
/*  equations a*c = z with a a n x n upper triangular matrix                  */
/*  of bandwidth k.                                                           */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  ..                                                                        */
/*  ..scalar arguments..                                                      */
/*      integer n,k,nest                                                      */
/*  ..array arguments..                                                       */
/*      real a(nest,k),z(n),c(n)                                              */
/*  ..local scalars..                                                         */
/*      real store                                                            */
/*      integer i,i1,j,k1,l,m                                                 */
/*  ..                                                                        */

c.0    = n
z.0    = n
a.nest.0 = k       /* Compound variable  <<<<<-----  */
a.0    = nest    /* Compound variable  <<<<<-----  */

k1   = k-1
c.n  = z.n /a.n.1
i    = n-1
if(i = 0) then return
do j=2 to n /* do 20 */
   store = z.i
   i1 = k1
   if(j <= k1) then i1 = j-1
   m = i
   do l=1 to i1
      m = m+1
      lp1 = l+1
      store = store-c.m * a.i.lp1
      end l

   c.i  = store/a.i.1   
   i = i-1
   end j /* 20 */

return n k
 
/* Converted from D:\SOURCE\BSPLINE\CURFIT\FPBACK.F                           */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 17 August 2000 5:13pm                                                      */


fpbspl:
procedure expose  t. n k l h.
x = arg(1)

/* Example call:
xi = fpbspl(xi) /* t,n,k,xi,l,h */ /* Line Number 90 */
*/

/*  subroutine fpbspl evaluates the (k+1) non-zero b-splines of               */
/*  degree k at t(l) <= x < t(l+1) using the stable recurrence                */
/*  relation of de boor and cox.                                              */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  ..                                                                        */
/*  ..scalar arguments..                                                      */
/*      real x                                                                */
/*      integer n,k,l                                                         */
/*  ..array arguments..                                                       */
/*      real t(n),h(6)                                                        */
/*  ..local scalars..                                                         */
/*      real f,one                                                            */
/*      integer i,j,li,lj                                                     */
/*  ..local arrays..                                                          */
/*      real hh(5)                                                            */
/*  ..                                                                        */

h.0  = 6
t.0  = n
hh.0 = 5

one = 0.1e+01
h.1 = one
do j=1 to k 
   do i=1 to j
      hh.i  = h.i
      end i

   h.1  = 0.
   do i=1 to j
      li    = l+i
      lj    = li-j
      f     = hh.i /(t.li -t.lj )
      h.i   = h.i +f*(t.li -x)
      ip1   = i+1
      h.ip1 = f*(x-t.lj )
      end i
   end j

return x
 
/* Converted from D:\SOURCE\BSPLINE\CURFIT\FPBSPL.F                           */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 17 August 2000 3:47pm                                                      */
/* Array index variable ip1 created.  Approx. output line 35                  */
/*           h(i+1) = f*(x-t(lj))                                             */



fpchecstarter:
procedure expose u. m t. n k ier
do copyindex = 1 to u.0
   x.copyindex = u.copyindex
   end copyindex
x.0 = u.0
call fpchec
do copyindex = 1 to x.0
   u.copyindex = x.copyindex
   end copyindex
u.0 = x.0
return


fpchec:
procedure expose  x. m t. n k ier

/* Example call:
call fpchec /* x,m,t,n,k,ier */
*/

/*  subroutine fpchec verifies the number and the position of the knots       */
/*  t(j),j=1,2,...,n of a spline of degree k, in relation to the number       */
/*  and the position of the data points x(i),i=1,2,...,m. if all of the       */
/*  following conditions are fulfilled, the error parameter ier is set        */
/*  to zero. if one of the conditions is violated ier is set to ten.          */
/*      1) k+1 <= n-k-1 <= m                                                  */
/*      2) t(1) <= t(2) <= ... <= t(k+1)                                      */
/*         t(n-k) <= t(n-k+1) <= ... <= t(n)                                  */
/*      3) t(k+1) < t(k+2) < ... < t(n-k)                                     */
/*      4) t(k+1) <= x(i) <= t(n-k)                                           */
/*      5) the conditions specified by schoenberg and whitney must hold       */
/*         for at least one subset of data points, i.e. there must be a       */
/*         subset of data points y(j) such that                               */
/*             t(j) < y(j) < t(j+k+1), j=1,2,...,n-k-1                        */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  ..                                                                        */
/*  ..scalar arguments..                                                      */
/*      integer m,n,k,ier                                                     */
/*  ..array arguments..                                                       */
/*      real x(m),t(n)                                                        */
/*  ..local scalars..                                                         */
/*      integer i,j,k1,k2,l,nk1,nk2,nk3                                       */
/*      real tj,tl                                                            */
/*  ..                                                                        */

t.0 = n
x.0 = m

k1 = k+1
k2 = k1+1
nk1 = n-k1
nk2 = nk1+1
ier = 10

/*  check condition no 1                                                      */
if(nk1 < k1 ) | (nk1 > m) then return

/*  check condition no 2                                                      */
j = n
do i=1 to k
   ip1 = i+1
   jm1 = j-1
   if(t.i  > t.ip1 ) then return
   if(t.j  < t.jm1 ) then return
   j = j-1
   end i

/*  check condition no 3                                                      */
do i=k2 to nk2
   im1 = i-1
   if(t.i  <= t.im1 ) then return
   end i

/*  check condition no 4                                                      */
if(x.1  < t.k1  ) | (x.m  > t.nk2 ) then return

/*  check condition no 5                                                      */
if(x.1  >= t.k2  ) | (x.m  <= t.nk1 ) then return
i = 1
l = k2
nk3 = nk1-1
if(nk3 < 2) then do
   ier = 0
   return
   end
do j=2 to nk3
   tj = t.j
   l = l+1
   tl = t.l
   do ThisIsLoopTo40 = 1
      i = i+1
      if(i >= m) then  return
      if(x.i  <= tj) then 
         iterate ThisIsLoopTo40
      else
         leave ThisIsLoopTo40
      end ThisIsLoopTo40
   if(x.i  >= tl) then return
   end j

ier = 0 /* Line Number 70 */
return /* Line Number 80 */
/* Converted from D:\SOURCE\BSPLINE\CURFIT\FPCHEC.F                           */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 15 August 2000 5:01pm                                                      */


fpdisc:
procedure expose  t. n k2 b. nest

/* Example call:
call fpdisc /* t,n,k2,b,nest */
*/

/*  subroutine fpdisc calculates the discontinuity jumps of the kth           */
/*  derivative of the b-splines of degree k at the knots t(k+2)..t(n-k-1)     */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  ..scalar arguments..                                                      */
/*      integer n,k2,nest                                                     */
/*  ..array arguments..                                                       */
/*      real t(n),b(nest,k2)                                                  */
/*  ..local scalars..                                                         */
/*      real an,fac,prod                                                      */
/*      integer i,ik,j,jk,k,k1,l,lj,lk,lmk,lp,nk1,nrint                       */
/*  ..local array..                                                           */
/*      real h(12)                                                            */
/*  ..                                                                        */

b.nest.0 = k2
b.0 = nest   
t.0 = n
h.0 = 12

k1 = k2-1
k = k1-1
nk1 = n-k1
nrint = nk1-k
an = nrint
nk1p1 = nk1+1
fac = an/(t.nk1p1 -t.k1 )
do l=k2 to nk1 /* do 40 */
   lmk = l-k1
   do j=1 to k1 /* do 10 */
      ik = j+k1
      lj = l+j
      lk = lj-k2
      h.j  = t.l -t.lk
      h.ik  = t.l -t.lj
      end j /* 10 */

   lp = lmk
   do j=1 to k2 /* do 30 */
      jk = j
      prod = h.j
      do i=1 to k
         jk = jk+1
         prod = prod*h.jk *fac
         end i

      lk = lp+k1
      b.lmk.j = (t.lk -t.lp )/prod
      lp = lp+1
      end j /* 30 */
   end l /* 40 */
return
 
/* Converted from D:\SOURCE\BSPLINE\CURFIT\FPDISC.F                           */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 17 August 2000 2:09pm                                                      */



fpgivs:
procedure expose  piv cos sin
ww = arg(1)

/* Example call
a.j.1 =  fpgivs(a.j.1) /* piv,a.j.1, cos, sin */
*/

/*  subroutine fpgivs calculates the parameters of a givens                   */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  transformation .                                                          */
/*  ..                                                                        */
/*  ..scalar arguments..                                                      */
/*      real piv,ww,cos,sin                                                   */
/*  ..local scalars..                                                         */
/*      real dd,one,store                                                     */
/*  ..function references..                                                   */
/*      real abs,sqrt                                                         */
/*  ..                                                                        */
one   = 0.1e+01
store = abs(piv)
if(store >= ww) then dd = store*sqrt(one+(ww/piv)**2)
if(store < ww)  then dd = ww*sqrt(one+(piv/ww)**2)
cos = ww/dd
sin = piv/dd
ww  = dd
return ww
/* Converted from D:\SOURCE\BSPLINE\CURFIT\FPGIVS.F                           */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 15 August 2000 5:01pm                                                      */




      call fpknot(u,m,t,n,fpint,nrdata,nrint,nest,1)
subroutine fpknot(x,m,t,n,fpint,nrdata,nrint,nest,istart)


fpknotstarter:
procedure expose u. m t. n fpint. nrdata. nrint nest
istart = arg(1)
do copyindex = 1 to u.0
   x.copyindex = u.copyindex
   end copyindex
x.0 = u.0
call fpknot(istart)
do copyindex = 1 to x.0
   u.copyindex = x.copyindex
   end copyindex
u.0 = x.0
return


fpknot:
procedure expose  x. m t. n fpint. nrdata. nrint nest

istart = arg(1)

/* Example call:
call fpknot(1) 
*/

/*  subroutine fpknot locates an additional knot for a spline of degree       */
/*  k and adjusts the corresponding parameters,i.e.                           */
/*    t     : the position of the knots.                                      */
/*    n     : the number of knots.                                            */
/*    nrint : the number of knotintervals.                                    */
/*    fpint : the sum of squares of residual right hand sides                 */
/*            for each knot interval.                                         */
/*    nrdata: the number of data points inside each knot interval.            */
/*  istart indicates that the smallest data point at which the new knot       */
/*  may be added is x(istart+1)                                               */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  ..                                                                        */
/*  ..scalar arguments..                                                      */
/*      integer m,n,nrint,nest,istart                                         */
/*  ..array arguments..                                                       */
/*      real x(m),t(nest),fpint(nest)                                         */
/*      integer nrdata(nest)                                                  */
/*  ..local scalars..                                                         */
/*      real an,am,fpmax                                                      */
/*      integer ihalf,j,jbegin,jj,jk,jpoint,k,maxbeg,maxpt, next,nrx,number   */
/*  ..                                                                        */

fpint.0  = nest
t.0      = nest
x.0      = m
nrdata.0 = nest

k = (n-nrint-1)/2

/*  search for knot interval t(number+k) <= x <= t(number+k+1) where          */
/*  fpint(number) is maximal on the condition that nrdata(number)             */
/*  not equals zero.                                                          */
fpmax = 0.
jbegin = istart
do j=1 to nrint /* do 20 */
   jpoint = nrdata.j
   if(fpmax >= fpint.j) | (jpoint = 0) then nop
   else do
      fpmax  = fpint.j
      number = j
      maxpt  = jpoint
      maxbeg = jbegin
      end
   jbegin = jbegin+jpoint+1 /* Line Number 10 */
   end j /* 20 */

/*  let coincide the new knot t(number+k+1) with a data point x(nrx)          */
/*  inside the old knot interval t(number+k) <= x <= t(number+k+1).           */
ihalf = trunc(maxpt/2+1)
nrx   = maxbeg+ihalf
next  = number+1
if(next > nrint) then nop
else do 
   /*  adjust the different parameters.                                       */
   do j=next to nrint /* do 30 */
      jj          = next+nrint-j
      jjp1        = jj + 1
      fpint.jjp1  = fpint.jj
      nrdata.jjp1 = nrdata.jj
      jk     = jj+k
      jkp1   = jk + 1
      t.jkp1 = t.jk
      end j /* 30 */
   end

nrdata.number = ihalf-1 /* Line Number 40 */
nrdata.next   = maxpt-ihalf
am = maxpt
an = nrdata.number
fpint.number = fpmax*an/am
an           = nrdata.next
fpint.next   = fpmax*an/am
jk    = next+k
t.jk  = x.nrx
n     = n+1
nrint = nrint+1
return

/* Converted from CURFIT\FPKNOT.F                                             */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 16 August 2000 1:26pm                                                      */




fpparastarter:
/* This allow translation of variables between the calling and fppara.cmd    */
/* The calling routine should call this rather than fppara directly.         */

procedure expose iopt idim m u. mx x. w. ub ue k s nest tol maxit k1 k2  n t.,
                 ncc c. fp wrk. iwrk. ier ifp iz ia ib ig iq

nc = ncc 

j = 0
do i = ifp to ifp+nest-1
   j       = j+1
   fpint.j = wrk.i
   end i
j = 0
do i = iz to iz+nc-1
   j   = j+1
   z.j = wrk.i
   end i

iindex = ia
do kindex = 1 to k1
   do jindex = 1 to nest
      a.jindex.kindex = wrk.iindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

iindex = ib
do kindex = 1 to k2
   do jindex = 1 to nest
      b.jindex.kindex = wrk.iindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

iindex = ig
do kindex = 1 to k1
   do jindex = 1 to nest
      g.jindex.kindex = wrk.iindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

iindex = iq
do kindex = 1 to k1
   do jindex = 1 to nest
      q.jindex.kindex = wrk.iindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

do copyindex = 1 to iwrk.0
   nrdata.copyindex = iwrk.copyindex
   end copyindex
nrdata.0 = iwrk.0

call fppara

do copyindex = 1 to nrdata.0
   iwrk.copyindex = nrdata.copyindex
   end copyindex
iwrk.0 = nrdata.0

j = ifp-1
do i = 1 to fpint.0
   j     = j+1
   wrk.j = fpint.i
   end i
j = iz-1
do i = 1 to z.0
   j     = j+1
   wrk.j = z.i
   end i

iindex = ia
do kindex = 1 to k1
   do jindex = 1 to nest
      wrk.iindex = a.jindex.kindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

iindex = ib
do kindex = 1 to k1
   do jindex = 1 to nest
      wrk.iindex = b.jindex.kindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

iindex = ig
do kindex = 1 to k1
   do jindex = 1 to nest
      wrk.iindex = g.jindex.kindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

iindex = iq
do kindex = 1 to k1
   do jindex = 1 to nest
      wrk.iindex = q.jindex.kindex
      iindex = iindex +1
      if iindex > wrk.0 then leave jindex
      end
   end

ncc = nc
return 


fppara:
procedure expose  iopt idim m u. mx x. w. ub ue k s nest tol maxit k1 k2 n t. nc c. fp fpint. z. a. b. g. q. nrdata. ier
/*  ..                                                                       */
/*  ..scalar arguments..                                                     */
/*      real ub,ue,s,tol,fp                                                  */
/*      integer iopt,idim,m,mx,k,nest,maxit,k1,k2,n,nc,ier                   */
/*  ..array arguments..                                                      */
/*      real u(m),x(mx),w(m),t(nest),c(nc),fpint(nest), z(nc),a(nest,k1),b(ne */
/*          st,k2),g(nest,k2),q(m,k1)                                        */

q.m.0    = k1 
q.0      = m 
g.nest.0 = k2
g.0      = nest
b.nest.0 = k2
b.0      = nest
a.nest.0 = k1
a.0      = nest
z.0      = nc
fpint.0  = nest
c.0      = nc
t.0      = nest
w.0      = m
x.0      = mx
u.0      = m
nrdata.0 = nest
xi.0     = 10
h.0      = 7

/*      integer nrdata(nest)                                                 */
/*  ..local scalars..                                                        */
/*      real acc,con1,con4,con9,cos,fac,fpart,fpms,fpold,fp0,f1,f2,f3, half,o */
/*ne,p,pinv,piv,p1,p2,p3,rn,sin,store,term,ui,wi                             */
/*      integer i,ich1,ich3,it,iter,i1,i2,i3,j,jj,j1,j2,k3,l,l0, mk1,new,nk1,*/
/*nmax,nmin,nplus,npl1,nrint,n8                                              */
/*  ..local arrays..                                                         */
/*      real h(7),xi(10)                                                     */
/*  ..function references                                                    */
/*      real abs,fprati                                                      */
/*      integer max0,min0                                                    */
/*  ..subroutine references..                                                */
/*    fpback,fpbspl,fpgivs,fpdisc,fpknot,fprota                              */
/*  ..                                                                       */

/*  set constants                                                            */
one = 0.1e+01
con1 = 0.1e0
con9 = 0.9e0
con4 = 0.4e-01
half = 0.5e0
/*ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    */
/*  part 1: determination of the number of knots and their position     c    */
/*  **************************************************************      c    */
/*  given a set of knots we compute the least-squares curve sinf(u),    c    */
/*  and the corresponding sum of squared residuals fp=f(p=inf).         c    */
/*  if iopt=-1 sinf(u) is the requested curve.                          c    */
/*  if iopt=0 or iopt=1 we check whether we can accept the knots:       c    */
/*    if fp <=s we will continue with the current set of knots.         c    */
/*    if fp > s we will increase the number of knots and compute the    c    */
/*       corresponding least-squares curve until finally fp<=s.         c    */
/*    the initial choice of knots depends on the value of s and iopt.   c    */
/*    if s=0 we have spline interpolation; in that case the number of   c    */
/*    knots equals nmax = m+k+1.                                        c    */
/*    if s > 0 and                                                      c    */
/*      iopt=0 we first compute the least-squares polynomial curve of   c    */
/*      degree k; n = nmin = 2*k+2                                      c    */
/*      iopt=1 we start with the set of knots found at the last         c    */
/*      call of the routine, except for the case that s > fp0; then     c    */
/*      we compute directly the polynomial curve of degree k.           c    */
/*ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    */

/*  determine nmin, the number of knots for polynomial approximation.        */
nmin = 2*k1

if(iopt < 0) then do 
   call FPPara_MainLoop
   return /* Leave fppara */ 
   end

/*  calculation of acc, the absolute tolerance for the root of f(p)=s.       */
acc = tol*s
/*  determine nmax, the number of knots for spline interpolation.            */
nmax = m+k1

if(s > 0.) then do /* go to 45 */
   /*  if s>0 our initial choice of knots depends on the value of iopt.         */
   /*  if iopt=0 or iopt=1 and s>=fp0, we start computing the least-squares     */
   /*  polynomial curve which is a spline curve without interior knots.         */
   /*  if iopt=1 and fp0>s we start computing the least squares spline curve    */
   /*  according to the set of knots found at the last call of the routine.     */
   if(iopt = 0) | (n = nmin) then nop
   else do
      fp0 = fpint.n
      nm1 = n-1
      fpold = fpint.nm1
      nplus = nrdata.n
      if(fp0 > s) then do 
         call FPPara_MainLoop
         return /* Leave fppara */ 
         end
      end
   n = nmin
   fpold = 0.
   nplus = 0
   nrdata.1 = m-2

   call FPPara_MainLoop
   return /* Leave fppara */ 
   end /* if(s > 0.) then ... */


/*  if s=0, s(u) is an interpolating curve.                                  */
/*  test whether the required storage space exceeds the available one.       */
n = nmax
if(nmax > nest) then do
   ier = 1
   return /* Leave fppara */ 
   end

Line10Label:
/*  find the position of the interior knots in case of interpolation.        */
mk1 = m-k1 /* Line Number 10 */
if(mk1 = 0) then  do 
   call FPPara_MainLoop
   return /* Leave fppara */ 
   end

k3 = trunc(k/2)
i  = k2
j  = k3+2

if(k3*2 = k) then do /* go to 30 */
   do l=1 to mk1 /* do 40 */ /* Line Number 30 */
      jm1 = j-1
      t.i = (u.j +u.jm1 )*half
      i   = i+1
      j   = j+1
      end l /* 40 */
   call FPPara_MainLoop
   return /* Leave fppara */ 
   end

else do
   do l=1 to mk1 /* do 20 */
      t.i  = u.j
      i = i+1
      j = j+1
      end l /* 20 */
   call FPPara_MainLoop
   return /* Leave fppara */ 
   end

call FPPara_MainLoop
return /* Leave fppara */ 

FPPara_MainLoop:
/*  main loop for the different sets of knots. m is a save upper bound       */
/*  for the number of trials.                                                */
do iter = 1 to m /* do 200 */ /* Line Number 60 */
   if(n = nmin) then ier = -2
   /*  find nrint, tne number of knot intervals.                             */
   nrint = n-nmin+1
   /*  find the position of the additional knots which are needed for        */
   /*  the b-spline representation of s(u).                                  */
   nk1 = n-k1
   i = n
   do j=1 to k1 /* do 70 */
      t.j  = ub
      t.i  = ue
      i    = i-1
      end j /* 70 */

   /*  compute the b-spline coefficients of the least-squares spline curve   */
   /*  sinf(u). the observation matrix a is built up row by row and          */
   /*  reduced to upper triangular form by givens transformations.           */
   /*  at the same time fp=f(p=inf) is computed.                             */

   fp = 0.
   /*  initialize the b-spline coefficients and the observation matrix a.    */
   do i=1 to nc
      z.i  = 0.
      end i

   do i=1 to nk1 
      do j=1 to k1
         a.i.j = 0.
         end j
      end i
   l  = k1
   jj = 0

   do it=1 to m /* do 130 */
      /*  fetch the current data point u(it),x(it).                                */
      ui = u.it
      wi = w.it
      do j=1 to idim
         jj   = jj+1
         xi.j = x.jj * wi
         end j
      /*  search for knot interval t(l) <= ui < t(l+1).                      */
      do ThisIsLoopTo85 = 1
         lp1 = l+1
         if(ui < t.lp1) |  (l = nk1) then leave ThisIsLoopTo85
         l = l+1
         end ThisIsLoopTo85

      /*  evaluate the (k+1) non-zero b-splines at ui and store them in q.   */
      ui = fpbspl(ui) /* t,n,k,ui,l,h */ /* Line Number 90 */

      do i=1 to k1
         q.it.i = h.i
         h.i    = h.i *wi
         end i 

      /*  rotate the new row of the observation matrix into triangle.        */
      j = l-k1
      do i=1 to k1 
         j   = j+1
         piv = h.i
         IF(PIV = 0.) THEN iterate i

         /*  calculate the parameters of the givens transformation.          */
         a.j.1 = fpgivs(a.j.1)

         /*  transformations to right hand side.                             */
         j1 = j
         do j2 =1 to idim
            rc = fprota(xi.j2 ,z.j1)
            parse var rc xi.j2 z.j1
            j1 = j1+n
            end j2 
      
         if(i = k1) then leave i
         i2 = 1
         i3 = i+1
         do i1 = i3 to k1
            i2 = i2+1
            /*  transformations to left hand side.                           */
            rc = fprota(h.i1, a.j.i2)
            parse var rc h.i1 a.j.i2
            end i1      
         end i
   
      /*  add contribution of this row to the sum of squares of residual     */
      /*  right hand sides.                                                  */
      do j2=1 to idim     /* Line Number 120 */
         fp  = fp+xi.j2 **2
         end j2
   
      end it

   if(ier = (-2)) then fp0 = fp
   fpint.n   = fp0
   nm1       = n-1
   fpint.nm1 = fpold
   nrdata.n  = nplus

   /*  backward substitution to obtain the b-spline coefficients.            */
   j1 = 1
   do j2=1 to idim
      rc = fpbackstarter(nk1,k1) /* a,z.j1 ,nk1,k1,c.j1 ,nest */
      parse var rc nk1 k1
      j1 = j1+n
      end j2

   /*  test whether the approximation sinf(u) is an acceptable solution.     */
   if(iopt < 0) then return
   fpms = fp-s

   if(abs(fpms)  < acc) then return

   /*  if f(p=inf) < s accept the choice of knots.                           */
   if(fpms < 0.) then leave iter

   /*  if n = nmax, sinf(u) is an interpolating spline curve.                */
   if(n = nmax) then do
      ier = -1
      return
      end

   /*  increase the number of knots.                                         */
   /*  if n=nest we cannot increase the number of knots because of           */
   /*  the storage capacity limitation.                                      */
   if(n = nest) then do
      ier = 1
      return
      end

   /*  determine the number of knots nplus we are going to add.              */
   if(ier = 0) then do
      npl1 = nplus*2 
      rn   = nplus
      if(fpold-fp > acc) then npl1 = rn*fpms/(fpold-fp)
      nplus = trunc(min(nplus*2,trunc(max(npl1,nplus/2,1))))
      end
   else do
      nplus = 1
      ier   = 0
      end

   fpold = fp 
   /*  compute the sum of squared residuals for each knot interval           */
   /*  t(j+k) <= u(i) <= t(j+k+1) and store it in fpint(j),j=1,2,...nrint.   */
   fpart = 0.
   i     = 1
   l     = k2
   new   = 0
   jj    = 0

   do it=1 to m /* do 180 */
      if(u.it  < t.l  ) |  (l > nk1) then nop
      else do
         new = 1
         l = l+1
         end /* else do ... */
      term = 0. /* Line Number 160 */
      l0 = l-k2
      do j2=1 to idim
         fac = 0.
         j1 = l0
         do j=1 to k1
            j1  = j1+1
            fac = fac+c.j1 * q.it.j 
            end j

         jj   = jj+1
         term = term+(w.it *(fac-x.jj ))**2
         l0   = l0+n
         end j2

      fpart = fpart+term
      IF(NEW = 0) THEN  iterate it
      store    = term*half
      fpint.i  = fpart-store
      i        = i+1
      fpart    = store
      new      = 0
      end it /* 180 */

   fpint.nrint  = fpart
   do l=1 to nplus /* do 190 */
      /*  add a new knot.                                                    */
       call fpknotstarter(1) /* u,m,t,n,fpint,nrdata,nrint,nest,1  */

      /*  if n=nmax we locate the knots as for interpolation                 */
      if(n = nmax) then call Line10Label

      /*  test whether we cannot further increase the number of knots.       */
      IF(N = NEST) THEN iterate iter
      end l /* 190 */

   /*  restart the computations with the new set of knots.                   */
   end iter  /* 200 */

/*  test whether the least-squares kth degree polynomial curve is a          */
/*  solution of our approximation problem.                                   */
if(ier = (-2)) then return /* Line Number 250 */

/*ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    */
/*  part 2: determination of the smoothing spline curve sp(u).          c    */
/*  **********************************************************          c    */
/*  we have determined the number of knots and their position.          c    */
/*  we now compute the b-spline coefficients of the smoothing curve     c    */
/*  sp(u). the observation matrix a is extended by the rows of matrix   c    */
/*  b expressing that the kth derivative discontinuities of sp(u) at    c    */
/*  the interior knots t(k+2),...t(n-k-1) must be zero. the corres-     c    */
/*  ponding weights of these additional rows are set to 1/p.            c    */
/*  iteratively we then have to determine the value of p such that f(p),c    */
/*  the sum of squared residuals be = s. we already know that the least c    */
/*  squares kth degree polynomial curve corresponds to p=0, and that    c    */
/*  the least-squares spline curve corresponds to p=infinity. the       c    */
/*  iteration process which is proposed here, makes use of rational     c    */
/*  interpolation. since f(p) is a convex and strictly decreasing       c    */
/*  function of p, it can be approximated by a rational function        c    */
/*  r(p) = (u*p+v)/(p+w). three values of p(p1,p2,p3) with correspond-  c    */
/*  ing values of f(p) (f1=f(p1)-s,f2=f(p2)-s,f3=f(p3)-s) are used      c    */
/*  to calculate the new value of p such that r(p)=s. convergence is    c    */
/*  guaranteed by taking f1>0 and f3<0.                                 c    */
/*ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    */

/*  evaluate the discontinuity jump of the kth derivative of the             */
/*  b-splines at the knots t(l),l=k+2,...n-k-1 and store in b.               */
call fpdisc /* t,n,k2,b,nest */

/*  initial value for p.                                                     */
p1 = 0.
f1 = fp0-s
p3 = -one
f3 = fpms
p  = 0.
do i=1 to nk1
   p = p+a.i.1
   end i

rn   = nk1
p    = rn/p
ich1 = 0
ich3 = 0
n8   = n-nmin

/*  iteration process to find the root of f(p) = s.                          */
do iter=1 to maxit /* do 360 */
   /*  the rows of matrix b with weight 1/p are rotated into the                */
   /*  triangularised observation matrix a which is stored in g.                */

   pinv = one/p
   do i=1 to nc /* do 255 */
      c.i  = z.i
      end i /* 255 */

   do i=1 to nk1 
      g.i.k2  = 0.
      do j=1 to k1
         g.i.j  = a.i.j 
         end j
      end i

   do it=1 to n8 /* do 300 */
      /*  the row of matrix b is rotated into triangle by givens transformation    */
      do i=1 to k2
         h.i  = b.it.i*pinv 
         end i

      do j=1 to idim
         xi.j  = 0.
         end j

      do j=it to nk1 /* do 290 */
         piv = h.1

         /*  calculate the parameters of the givens transformation.                   */
          g.j.1 = fpgivs(g.j.1) /* piv,g.j.1,cos,sin */

         /*  transformations to right hand side.                                      */
         j1 = j
         do j2=1 to idim
            rc = fprota(xi.j2,c.j1) /* cos,sin,xi.j2 ,c.j1 */
            parse var rc xi.j2 c.j1
            j1 = j1+n
            end j2

         IF(J = NK1) THEN iterate it
         i2 = k1
         if(j > n8) then i2 = nk1-j
         do i=1 to i2
            /*  transformations to left hand side.                                       */
            i1 = i+1
            rc = fprota(h.i1, g.j.i1) /* cos, sin, h.i1, g.j.i1 */
            parse var rc h.i1 g.j.i1
            h.i  = h.i1
            end i

         i2p1    = i2+1
         h.i2p1 = 0.
         end j
      end it /* 300 */

   /*  backward substitution to obtain the b-spline coefficients.               */
   j1 = 1
   do j2=1 to idim
      rc = fpback2starter(nk1,k2) /* g, c.j1, nk1, k2, c.j1 ,nest */
      parse var rc nk1 k2

      j1 =j1+n
      end j2

   /*  computation of f(p).                                                  */
   fp = 0.
   l  = k2
   jj = 0
   do it=1 to m
      if(u.it  < t.l  ) |  (l > nk1) then 
         nop
      else 
         l = l+1
      l0 = l-k2
      term = 0.
      do j2=1 to idim
         fac = 0.
         j1 = l0
         do j=1 to k1
            j1 = j1+1
            fac = fac+c.j1 *q.it.j
            end j

         jj   = jj+1
         term = term+(fac-x.jj )**2
         l0   = l0+n
         end j2

      fp = fp+term*w.it **2
      end it

   /*  test whether the approximation sp(u) is an acceptable solution.       */
   fpms = fp-s
   if(abs(fpms)  < acc) then return

   /*  test whether the maximal number of iterations is reached.             */
   if(iter = maxit) then do
      ier = 3
      return
      end

   /*  carry out one more step of the iteration process.                     */
   p2 = p
   f2 = fpms

   select
      when ich3    \= 0   then nop
      when (f2-f3) >  acc then do
         if(f2 < 0.) then ich3=1 
         end /* when */
      otherwise do
         /*  our initial choice of p is too large.                              */
         p3 = p2
         f3 = f2
         p = p*con4
         if(p <= p1) then p = p1*con9 + p2*con1
         iterate iter
         end /* otherwise */
      end  /* select */

   select
      when ich1    \= 0   then nop /* Line Number 340 */
      when (f1-f2) >  acc then do
         if(f2 > 0.) then ich1=1
         end /* when */
      otherwise do
         /*  our initial choice of p is too small                            */
         p1 = p2
         f1 = f2
         p = p/con4
         IF(P3 < 0.) then 
            iterate iter
         if(p >= p3) then 
            p = p2*con1 + p3*con9
         iterate iter
         end /* otherwise */
      end  /* select */

   /*  test whether the iteration process proceeds as theoretically          */
   /*  expected.                                                             */
   if(f2 >= f1 ) | ( f2 <= f3) then do /* Line Number 350 */
      ier = 2 /* Line Number 410 */
      return
      end /* do */

   /*  find the new value for p.                                             */
   p = fprati(p1,f1,p2,f2,p3,f3)

   end iter /* 360 */

return
 
/* Converted from PARCUR\FPPARA.F                                             */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 22 August 2000 6:10pm                                                      */


fprati:
procedure expose p1 f1 p2 f2 p3 f3

/* Example call:
p = fprati(p1,f1,p2,f2,p3,f3)
*/

/*  given three points (p1,f1),(p2,f2) and (p3,f3), function fprati           */
/*  gives the value of p such that the rational interpolating function        */
/*  of the form r(p) = (u*p+v)/(p+w) equals zero at p.                        */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  ..                                                                        */
/*  ..scalar arguments..                                                      */
/*      real p1,f1,p2,f2,p3,f3                                                */
/*  ..local scalars..                                                         */
/*      real h1,h2,h3,p                                                       */
/*  ..                                                                        */

if(p3 > 0.) then do
   /*  value of p in case p3 ^= infinity.                                     */
   h1 = f1*(f2-f3) /* Line Number 10 */
   h2 = f2*(f3-f1)
   h3 = f3*(f1-f2)
   p = -(p1*p2*h3+p2*p3*h1+p3*p1*h2)/(p1*h1+p2*h2+p3*h3)
   end
else do
   /*  value of p in case p3 = infinity.                                      */
   p = (p1*(f1-f3)*f2-p2*(f2-f3)*f1)/((f1-f2)*f3)
   end

/*  adjust the value of p1,f1,p3 and f3 such that f1 > 0 and f3 < 0.          */
if(f2 < 0.) then do
   p3 = p2
   f3 = f2
   end 
else do
   p1 = p2
   f1 = f2
   end
fprati = p /* Line Number 40 */

return fprati
/* Converted from D:\SOURCE\BSPLINE\CURFIT\FPRATI.F                           */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 15 August 2000 5:01pm                                                      */


fprota:
procedure expose  cos sin 
a = arg(1)
b = arg(2)

/* Example call:
rc = fprota(yi,z.j)
parse var rc yi z.j
*/

/*  subroutine fprota applies a givens rotation to a and b.                   */
/*                                                                            */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov          */
/*                                                                            */
/*  ..                                                                        */
/*  ..scalar arguments..                                                      */
/*      real cos,sin,a,b                                                      */
/* ..local scalars..                                                          */
/*      real stor1,stor2                                                      */
/*  ..                                                                        */
stor1 = a
stor2 = b
b = cos*stor2+sin*stor1
a = cos*stor1-sin*stor2
return a b
/* Converted from D:\SOURCE\BSPLINE\CURFIT\FPROTA.F                           */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 15 August 2000 5:01pm                                                      */


/* mnparc is a test program provided with the FITPACK library.  It is        */
/* retained here as it illustrates some additional options not implemented   */
/* in ParamBSpline.                                                          */

/* This subroutine is commented out. */
/*

/*ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    */
/*c                                                                    cc    */
/*c                mnparc : parcur test program                        cc    */
/*c                                                                    cc    */
/*ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    */
/*  REXX port by Doug Rickman, MSFC/NASA doug@hotrocks.msfc.nasa.gov         */

/*      real x(64),w(32),u(32),t(40),c(80),wrk(1200),sp(64)                  */

sp.0  = 64
wrk.0 = 1200
c.0   = 80
t.0   = 40
u.0   = 32
w.0   = 32
x.0   = 64
iwrk.0 = 40

/*      integer iwrk(40)                                                     */
/*      real al,del,fp,s,ub,ue                                               */
/*      integer i,idim,ier,iopt,ipar,is,i1,i2,j,j1,k,l,lwrk,l1,m,mx, n,nc,nes*/
/*      t,nk1                                                                */

/*  the data parameter values                                                */
u.1  =120.; u.2  =128.; u.3  =133.; u.4  =136.; u.5  =138.
u.6  =141.; u.7  =144.; u.8  =146.; u.9  =149.; u.10 =151.
u.11 =154.; u.12 =161.; u.13 =170.; u.14 =180.; u.15 =190.
u.16 =200.; u.17 =210.; u.18 =220.; u.19 =230.; u.20 =240.
u.21 =250.; u.22 =262.; u.23 =269.; u.24 =273.; u.25 =278.
u.26 =282.; u.27 =287.; u.28 =291.; u.29 =295.; u.30 =299.
u.31 =305.; u.32 =315.;

/*  the data absciss values                                                  */
x.1  =-1.5141; x.3  =-2.0906; x.5  =-1.9253; x.7  =-0.8724; x.9  =-0.3074
x.11 =-0.5534; x.13 = 0.0192; x.15 = 1.2298; x.17 = 2.5479; x.19 = 2.4710
x.21 = 1.7063; x.23 = 1.1183; x.25 = 0.5534; x.27 = 0.4727; x.29 = 0.3574
x.31 = 0.1998; x.33 = 0.2882; x.35 = 0.2613; x.37 = 0.2652; x.39 = 0.2805
x.41 = 0.4112; x.43 = 0.9377; x.45 = 1.3527; x.47 = 1.5564; x.49 = 1.6141
x.51 = 1.6333; x.53 = 1.1567; x.55 = 0.8109; x.57 = 0.2498; x.59 =-0.2306
x.61 =-0.7571; x.63 =-1.1222

/*  the data ordinate values                                                 */
x.2  = 0.5150; x.4  = 1.3412; x.6  = 2.6094; x.8  = 3.2358; x.10 = 2.7401
x.12 = 2.7823; x.14 = 3.5932; x.16 = 3.8353; x.18 = 2.5863; x.20 = 1.3105
x.22 = 0.6841; x.24 = 0.2575; x.26 = 0.2460; x.28 = 0.3689; x.30 = 0.2460
x.32 = 0.2998; x.34 = 0.3651; x.36 = 0.3343; x.38 = 0.3881; x.40 = 0.4573
x.42 = 0.5918; x.44 = 0.7110; x.46 = 0.4035; x.48 = 0.0769; x.50 =-0.3920
x.52 =-0.8570; x.54 =-1.3412; x.56 =-1.5641; x.58 =-1.7409; x.60 =-1.7178
x.62 =-1.2989; x.64 =-0.5572

/*  m denotes the number of data points                                      */
m = 32

/*  we set up the weights of the data points                                 */
do i=1 to m
   w.i  = 1.0
   end i

/*  we set up the dimension information.                                     */
nest = 40
lwrk = 1200
nc   = 80
mx   = 64

/*  we will determine a planar curve   x=sx(u) , y=sy(u)                     */
idim = 2

/*  for the first approximations we will use cubic splines                   */
k = 3

/*  we will also supply the parameter values u(i)                            */
ipar = 1
ub   = 120.
ue   = 320.

/*  loop for the different approximating spline curves                       */
do is=1 to 9 /* do 400 */
   select 
      when is = 1 then do
         /*  we start computing a polynomial curve ( s very large)                    */
         iopt = 0
         s    = 100.
         end /* do */
   
      when is = 2 then do
         /*  iopt =  1 from the second call on                                        */
         iopt = 1
         s = 1.0
         end /* do */
   
      when is = 3 then do
         /*  a smaller value for s to get a closer approximation                      */
         s = 0.05
         end /* do */
   
      when is = 4 then do
         /*  a larger value for s to get a smoother approximation                     */
         s = 0.25
         end /* do */
   
      when is = 5 then do
         /*  if a satisfactory fit is obtained we can calculate a curve of equal      */
         /*  quality of fit (same value for s) but possibly with fewer knots by       */
         /*  specifying iopt=0                                                        */
         iopt = 0
         s = 0.25
         end /* do */
   
      when is = 6 then do
         /*  we determine a spline curve with respect to the same smoothing           */
         /*  factor s,  but now we let the program determine parameter values u(i)    */
         ipar = 0 
         iopt = 0
         s = 0.25
         end /* do */
   
      when is = 7 then do
         /*  we choose a different degree of spline approximation                     */
         k = 5 
         iopt = 0
         s = 0.25
         end /* do */
   
      when is = 8 then do
         /*  we determine an interpolating curve                                      */
         s = 0.
         end /* do */
   
      when is = 9 then do
         /*  finally we calculate a least-squares spline curve with specified         */
         /*  knots                                                                    */
         iopt =-1
         n    = 9+2*k
         j    = k+2
         del  = (ue-ub)*0.125
         do l=1 to 7 
            al = l
            t.j  = ub+al*del
            j = j+1
            end l 
         end /* do */
   
      otherwise say 'Huh?'
      end  /* select */
   
   /*  determine the approximating curve                                        */
   call parcur /* iopt,ipar,idim,m,u,mx,x,w,ub,ue,k,s,nest,n,t, nc,c,fp,wrk,lwrk,iwrk,ier */ /* Line Number 300 */
   call PrintResults
   end is /* 400 */

Return 1

PrintResults:
/*  printing of the results.                                                 */
if(iopt >= 0) then do /* go to 310 */
   say  '0smoothing curve of degree ' format(k,1,0) '  ipar=' format(ipar,1,0)
   say  ' smoothing factor s=' format(s,7,2)
   end
else do
   say  '0least-squares curve of degree ' format(k,1,0) '  ipar=' format(ipar,1,0)
   end

say '' 'sum squared residuals =' format(fp,4,6,,0) '    ' 'error flag=' format(ier,3,0)
say '' 'total number of knots n=' format(n,3,0)
say '' 'position of the knots '
if(ipar = 1) then do
   txt = '    '
   do i = 1 to n   
      txt = txt||format(t.i,6,0)
      end i
   say txt
   end /* if(ipar = 1) then ... */
if(ipar = 0) then do
   txt = '    '
   do i = 1 to n   
      txt = txt||format(t.i,8,4)
      end i
   say txt
   end /* if(ipar = 1) then ... */

nk1 = n-k-1
say ' b-spline coefficients of sx(u)'
txt = '    '
do i = 1 to nk1
   txt = txt||format(c.i,5,4,,0)
   end /* do */
say txt

say '' 'b-spline coefficients of sy(u)'
i1 = n+1
i2 = n+nk1
txt = '    '
do i = i1 to i2
   txt = txt||format(c.i,5,4,,0)
   end /* do */
say txt

say  '              xi             yi         sx(ui)         sy(ui)             xi             yi         sx(ui)         sy(ui)'

/*  we evaluate the spline curve                                             */
call curevstarter /*  idim,t,n,c,nc,k,u,m,sp,mx,ier */

do i=1 to 8 /* do 330 */
   l = (i-1)*8+3
   l1 = l+1
   j = l+4
   j1 = j+1
   say  ' ' format(x.l,9,4) format(x.l1,9,4) format(sp.l,9,4) format(sp.l1,9,4) format(x.j,9,4) format(x.j1,9,4) format(sp.j,9,4) format(sp.j1,9,4)    
   end i /* 330 */

Return 1

/* 910  format(31h0least-squares curve of degree ,i1,7h  ipar=,i1)            */
/* 915  format(27h0smoothing curve of degree ,i1,7h  ipar=,i1)                */
/* 920  format(20h smoothing factor s=,f7.2)                                  */
/* 925  format(1x,23hsum squared residuals =,e15.6,5x,11herror flag=,i2)      */
/* 930  format(1x,24htotal number of knots n=,i3)                             */
/* 935  format(1x,22hposition of the knots )                                  */
/* 940  format(5x,10f6.0)                                                     */
/* 945  format(1x,30hb-spline coefficients of sx(u))                          */
/* 950  format(5x,8f8.4)                                                      */
/* 955  format(1x,30hb-spline coefficients of sy(u))                          */
/* 960  format(1h0,2(4x,2hxi,7x,2hyi,6x,6hsx(ui),3x,6hsy(ui)))                */
/* 965  format(1h ,8f9.4)                                                     */
 
/* Converted from BSPLINE\TESTING\MNPARC.F                                    */
/* with the aid of FORTRAN2REXX, version Aug 15, 2000, by D. Rickman.         */
/* 22 August 2000 4:31pm                                                      */

*/
/* end of subroutine mnparc. */

/* From Album of Algorithms and Techniques, by Vladimir Zabrodsky            */
SQRT: procedure 
parse arg N, P 
if P = "" then P = 9
numeric digits P 
parse value FORMAT(N,,,,0) with N "E" Exp 
if Exp = "" then Exp = 0 
if (Exp // 2) <> 0 then 
   if Exp > 0 then do
      N = N * 10
      Exp = Exp - 1
      end 
else do
   N = N / 10
   Exp = Exp + 1
   end 
X = 0.5 * (N + 1) 
do forever 
   NewX = 0.5 * (X + N / X) 
   if X = NewX then return X * 10 ** (Exp % 2) 
   X = NewX 
   end 