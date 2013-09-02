/* Convolve a square kernel with an array of data.                           */
/* Kernels must be square.  If the sum of the kernel weights does not equal  */
/* 0 or 1, then the weights are adjusted such that the sum of weights=1.     */
/* Doug Rickman  March 10, 1998; mod. Aug. 5, 1998                           */
signal on Halt
signal on NotReady

if rxfuncquery('sysloadfuncs') then do           /* this will start rexxutil */
	CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' 
	CALL SysLoadFuncs
	end

arg inData inKernel out
inData=strip(inData)
out=strip(out)

/* Check input arguments. */
if inData='' | inData='?' | inData='-?' | inData='/?' then call Help
if out   ='' then call Help

if dosisfile(inData)<>1 then do
   say 'The input file: ' inData' is not a valid file.'
	exit
	end /* do */

if dosisfile(inKernel)<>1 then do
   say 'The input file: ' inKernel' is not a valid file.'
	exit
	end /* do */

if dosisfile(out) then do
   say 'The file ' out' already exists, do you want it overwritten?'
	say 'Enter a "y" for yes, "h" will give help,'
	say 'any other response will abort processing.'
	key=translate(sysgetkey())
	say
	select
		when key='Y' then do
			rc=dosdel(out)
			if rc=1 then nop
				else do
       		say 'The file 'out' could not be deleted.  Goodbye, Sweet Prince.'
				exit
				end /* else do */
			end /* when key='Y' then ... */

		when key='H' then call Help
		otherwise exit
		end /* select */

	end /* if dosisfile(out) */

/* --------------------------------------------------------------------------*/
/* --- begin MAIN                                               -------------*/

Call ReadKernel
Call ReadData
Call PadData
Call Convolve
exit
/* --- end MAIN                                                 -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Kernel:                               -------------*/
ReadKernel:
/* Read the kernel. */
i=0
j=0
NWeights=0
SWeights=0

/* Determine the number of weights in a line of the filter.  Filters must    */
/* have the same number of lines as elements.  Minimum kernel size is 3x3.   */

data=linein(inKernel)
KernelSize=words(data)
rc=lineout(inKernel)
Pad=(KernelSize-1)/2

/* Read in the weights and store in an array centered at 0,0 */
do j=0 to KernelSize-1
   y=j-Pad
   data=linein(inKernel)
   do i=0 to KernelSize-1
      x=i-Pad
      parse var data k.x.y data
      if k.x.y<>0 then do
         NWeights=NWeights+1
         SWeights=SWeights+k.x.y
         end
      end i
   end j
rc=lineout(inKernel)

/* echo the kernel */
say 'Kernel weights:'
do j=0 to KernelSize-1
   y=j-Pad
   dataout=''
   do i=0 to KernelSize-1
      x=i-Pad
      dataout=dataout right(k.x.y,3)', '
      end i
   say dataout
   end j
say 'Number of weights: 'NWeights '  Sum of weights: 'SWeights

/* Condition the kernel weights */
select
   when SWeights=0 then nop
   when SWeights=1 then nop
   otherwise  
      do j=0 to KernelSize-1
         y=j-Pad
         do i=0 to KernelSize-1
            x=i-Pad
            k.x.y=k.x.y/SWeights
            end i
         end j
   end /* select */
return
/* --- end subroutine   - ReadKernel:                           -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - ReadData:                             -------------*/
ReadData:
/* Read in the data */

j=0
do while lines(inData)>0
   j=j+1
   data=linein(inData)
   if data='' then do /* A blank line was left at the end of the data. */
      j=j-1
      leave
      end
   i=0
   do while data<>''
      i=i+1
      parse var data d.i.j data
      end /* do while data ... */
   end /* do while lines(inData) ... */
rc=lineout(inData)
DataSizei=i
DataSizej=j

/* echo the data */
say 
say 'Data values:'
do j=1 to DataSizej
   dataout=''
   do i=1 to DataSizei
      dataout=dataout format(d.i.j,3,3)', '
      end i
   say dataout
   end j
return
/* --- end subroutine  - ReadData:                              -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - PadData:                              -------------*/
/* Pad the data to provide values to kernel along edges of data. */
PadData:

/* Replicate the first line as needed. */
do j=1-Pad to 0
   do i=1 to DataSizei
      d.i.j=d.i.1
      end i
   end j

/* Replicate the last line as needed. */
do j=DataSizej+1 to DataSizeJ+Pad
   do i=1 to DataSizei
      d.i.j=d.i.DataSizej
      end i
   end j

/* Replicate the first column as needed. */
do j=1-Pad to DataSizeJ+Pad
   do i=1-Pad to 0
      d.i.j=d.1.j
      end i
   end j

/* Replicate the last column as needed. */
do j=1-Pad to DataSizeJ+Pad
   do i=DataSizei+1 to DataSizei+Pad
      d.i.j=d.DataSizei.j
      end i
   end j

/* Remove the comments to see the padded array of data values.               */
/*
say 
say 'Data values:'
do j=1-Pad to DataSizej+Pad
   dataout=''
   do i=1-Pad to DataSizei+Pad
      dataout=dataout right(d.i.j,3)', '
      end i
   say dataout
   end j
*/
return

/* --- end subroutine  - PadData:                               -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Convolve:                             -------------*/
Convolve:
/* Loop kernel through the elements (i) then through lines (j) of the data */
/* Build one line of output at a time.                                     */
Output=''
do j=1 to DataSizeJ
   Output=''
   do i=1 to DataSizei
      Sum=0   
      /* for each i,j do a kernel */
      do y=0-Pad to Pad
         kj=j+y
         do x=0-Pad to Pad
            ki=i+x
            Sum=Sum+ (k.x.y*d.ki.kj)
            end x
         end y
      Output=Output format(Sum,3,3)', '
      end i
   rc=lineout(out, Output)
   end j
rc=lineout(out)  /* Closes the output file */

/* Show the result */
say 
say 'Filtered array:'
do j=1 to DataSizej
   say linein(out)
   end j
rc=lineout(out)

return

/* --- end subroutine   - Convolve:                             -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Help:                                 -------------*/
Help:
rc= charout(,'1b'x||'[31;7m'||'Convolution:'||'1b'x||'[0m'||'0d0a'x)
say 'Convolve a square kernel with an array of data.  A teaching tool.'

say ''
rc= charout(,'1b'x||'[33;1m'||'usage:'||'1b'x||'[0m')
say ' Convolution data kernel OutputFile'
say ''

rc= charout(,'1b'x||'[33;1m'||'where:'||'1b'x||'[0m')
say ' data = Array of data values to be filtered.'
say '     kernel = square array used as the kernel.'
say '     Output = file name into which filtered array is written.'
say ''

rc= charout(,'1b'x||'[33;1m'||'Exam: '||'1b'x||'[0m')
say ' convolution Conv.data Conv.kernel Conv.out '
say ''

rc= charout(,'1b'x||'[33;1m'||'notes:'||'1b'x||'[0m')
say ' The data array is padded by replication of the first & last rows & '
say ' columns.  Values in the data and kernel are blank separated, one row per'
say ' line.  If the sum of kernel weights equals either 0 or 1 the weights are'
say ' used as input, otherwise individual weights are divided by the sum of all'
say ' weights.   The kernel must be square, i.e. equal number of rows and '
say ' columns.'
say ''

say ''
say 'Doug Rickman  August 5, 1998'
exit
return

/* --- end  subroutine - Help:                                  -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Halt:                                 -------------*/
Halt:
say 'This is a graceful exit from a Cntl-C'
exit
/* --- end  subroutine - Halt:                                  -------------*/
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - NotReady:                             -------------*/
NotReady:
say 'It would seem that you are pointing at non-existant data.  Oops.  Bye!'
exit
/* --- end  subroutine - NotReady:                              -------------*/
/* --------------------------------------------------------------------------*/



