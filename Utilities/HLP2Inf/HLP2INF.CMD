/* Copy and convert a *.HLP file to an *.INF file readable by VIEW.EXE */
/* Lee S. Fields */

/* get input and output file names */
/* get input file parameter */
arg inparm
if inparm=''
then do
  call instruct
  exit
end

inparm = strip(inparm)
/* check if HLP extension is specified */
extension=lastpos('.HLP',inparm)
/* if not, then add .HLP to input file name and .INF to output file name */
if extension=0
then do
  infile = inparm'.hlp'
  outfile = inparm'.inf'
end
/* else remove and add .INF to output file name */
else do
  infile = inparm
  outfile = substr(inparm,1,extension - 1)'.inf'
end
say 'Creating 'outfile' from 'infile

/* copy file but change 4th byte to 0x01 */
/* read first 4 characters, but keep only first three */
buffer=substr(charin(infile,1,4),1,3)
/* write first 3 characters */
call charout outfile,buffer,1
/* write 4 character as 0x01 */
call charout outfile,X2C('1'),4
/* loop through rest of file, reading and writing 4K blocks */
do while chars(infile) \= 0
  buffer = charin(infile,,min(4096, chars(infile)))
  call charout outfile, buffer
end
exit

instruct:
say 'HLP2INF.CMD - Creates INF files from HLP files'
say 'Format: HLP2INF filename[.hlp]'
return