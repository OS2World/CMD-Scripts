/* CUTCOLS.CMD -- cut a wide text file into equal width pieces.
  Useful for printing wide files.
  This has only been tested under OS/2.
   
Created by Daniel Hellerstein, danielh@crosslink.net. August 1999.

Disclaimer:
  This program can be freely used for any purpose whatsoever.
  This program is to be used at one's own risk -- the author is NOT 
  responsible for any unwanted, undesirable, or otherwise disasterous effects
  from the use of this code
*/

parse arg infile 
call loadlibs
opsys='OS2'
 say  bold"  CUTCOLS" normal " is used to divide a wide text file into narrower files"

getin:
if infile="" then do
    call lineout,bold " Enter name of text file to divide (?DIR for a directory, EXIT to quit) "normal
    call charout,"  "reverse " :" normal
    parse pull infile ; infile=strip(infile)
end
if strip(translate(infile))='EXIT' then do
   if addonmode<>1 then say "bye "
   exit
end 
if abbrev(translate(infile),'?DIR')=1 then do
    parse var infile . thisdir
    if thisdir="" then do
        thisdir=strip(directory(),'t','\')||'\*.*'
    end
    say
    say reverse ' List of files in: ' normal bold thisdir normal
    do while queued()>0
            pull .
    end /* do */
    toget=thisdir
    '@DIR /b  '||toget||' | rxqueue'
    foo=show_dir_queue('*')
    say
    infile=''
    signal getin
end
if abbrev(translate(strip(infile)),'/DIR')=1 then do
    infile=substr(strip(infile),2)
    address cmd infile
    infile=''
    signal getin
end /* do */

/* maybe it's actually a file name */

infile=strip(infile)
infile0=infile
if pos('.',infile)=0 then infile=infile||'.htm'
inputfile=stream(infile,'c','query exists')              /* does it, or .html or .htm version of it, exist*/
if inputfile='' & pos('.',infile0)=0 then inputfile=stream(infile0,'c','query exists')
if inputfile='' then inputfile=stream(infile0||'.html','c','query exists')

if inputfile='' then do
    Say "Sorry. could not find: " infile
    exit
end /* do */

inputlen=stream(inputfile,'c','query size')
if inputlen=0 then do
   say " Sorry -- " inputfile " is empty "
   infile=''
   signal getin
end /* do */
stuff=charin(inputfile,1,inputlen)
Say "Reading " inputlen " characters from " inputfile

i=0;maxlen=0
do forever
   if length(stuff)=0 then leave
   i=i+1
   parse var stuff aline '0d0a'x stuff
   lins.i=aline
   lins.0=i
   maxlen=max(length(aline),maxlen)
end /* do */
Say "Maximum line width = "maxlen


outget: nop
   parse var inputfile tout '.' .
   tout=tout
   say " "
   say bold " Enter name (without extension) of output file (ENTER="tout")"normal
   call charout,"  "reverse " :" normal
   parse pull outfile
   if outfile='' then outfile=tout

/* get column width of output files */
do forever
    call lineout,bold " Enter width (in characters) of each 'column' (ENTER=80)"
    call charout,"  "reverse " :" normal
    parse pull width
    if width='' then width=80
    if datatype(width)<>'NUM' then do
         say "Please enter an integer value > 0 "
         iterate
    end 
    width=trunc(width)
    if width<1 then do
         say "Please enter an integer value > 0 "
         iterate
    end 
/* determine how many file will be needed */
    ipp=maxlen/width
    ipp2=trunc(ipp+0.99999)
    say "   "Cy_ye"Creating the following files: "normal
    do mm=1 to ipp2
        j1=((mm-1)*width)+1 ; j2=j1+width-1
        ofiles.mm=OUTFILE"."mm
        if stream(ofiles.mm,'c','query exist')<>'' then do
            say "WARNING: "ofiles.mm "exists."
            call charout,bold"  Enter Y to overwrite: "normal
            pull foof
            if foof<>'Y' then do
                say "Please delete old files, or use a different ouptut file basename".
                exit
            end /* do */
            else do
               '@DEL 'ofiles.mm
            end /* do */
        end /* do */
        say "    "bold||ofiles.mm||normal||" (cols "j1 " to "j2")"
    end /* do */
    leave
end

/* now cut each line, and write to appropriate output file */
do mm=1 to lins.0
  do nn=1 to ipp2
     j1=((nn-1)*width)+1 
     t=substr(lins.mm,j1,width)
     call lineout ofiles.nn,t
  end /* do */
end /* do */
do mm=1 to lins.0
    call lineout ofiles.nn
end /* do */

say "Done!"
exit



/***********************************/
/* load libraries, set ansi, set defaults */
loadlibs:
foo2=1
foo=rxfuncquery('sysloadfuncs')
if foo=1 then do
  foo2=RxFuncAdd('SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs')
  if foo2=0 then call SysLoadFuncs
  foo=rxfuncquery('sysloadfuncs')
end
if foo=0 then  do
   got_rexxutil=1
end
else do
  say "Note: RexxUtil is NOT installed, so some options will not be available."
  got_rexxutil=0
end

cy_ye=' '; normal=''; bold='';re_wh='';reverse='';aesc=''

cansi=0
cansi=checkansi()

if  (noansi<>1 & cansi=1) then do
  aesc='1B'x
  cy_ye=aesc||'[37;46;m'
  normal=aesc||'[0;m'
  bold=aesc||'[1;m'
  re_wh=aesc||'[31;47;m'
  reverse=aesc||'[7;m'
end
else do
  say "Warning: ANSI not available, output will be simpler."
end
return 1



/*********/
/* show stuff in queue as a list */
show_dir_queue:procedure expose qlist. opsys
parse arg lookfor
    ibs=0 ;mxlen=0
    if lookfor<>1 then
       nq=queued()
     else
        nq=qlist.0
    do ii=1 to nq
       if lookfor=1 then do
          aa=qlist.ii
          ii2=lastpos('\',aa) ; anam=substr(aa,ii2+1)
       end /* do */
       else do
          parse pull aa
          if pos(lookfor,aa)=0 & lookfor<>'*' then iterate
          parse var aa anam (lookfor) .
          if strip(anam)='.' | strip(anam)='..' then iterate
       end
       ibs=ibs+1
       blist.ibs=anam
       mxlen=max(length(anam),mxlen)
    end /* do */
arf=""
do il=1 to ibs
   anam=blist.il
   arf=arf||left(anam,mxlen+2)
   if length(arf)+mxlen+2>75  then do
        say arf
        arf=""
   end /* do */
end /* do */
if length(arf)>1 then say arf
say
return 1


 /* ------------------------------------------------------------------ */
 /* function: Check if ANSI is activated                               */
 /*                                                                    */
 /* call:     CheckAnsi                                                */
 /*                                                                    */
 /* where:    -                                                        */
 /*                                                                    */
 /* returns:  1 - ANSI support detected                                */
 /*           0 - no ANSI support available                            */
 /*          -1 - error detecting ansi                                 */
 /*                                                                    */
 /* note:     Tested with the German and the US version of OS/2 3.0    */
 /*                                                                    */
 /*                                                                    */
 CheckAnsi: PROCEDURE
   thisRC = -1

   trace off
                         /* install a local error handler              */
   SIGNAL ON ERROR Name InitAnsiEnd

   "@ANSI 2>NUL | rxqueue 2>NUL"

   thisRC = 0

   do while queued() <> 0
     queueLine = lineIN( "QUEUE:" )
     if pos( " on.", queueLine ) <> 0 | ,                       /* USA */
        pos( " (ON).", queueLine ) <> 0 then                    /* GER */
       thisRC = 1
   end /* do while queued() <> 0 */

 InitAnsiEnd:
 signal off error
 RETURN thisRC




