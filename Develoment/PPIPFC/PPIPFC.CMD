/*-- REXX ------------------------------------------------------------*/
/*                                                                    */
/* Module name: PPIPFC.CMP                                            */
/*                                                                    */
/* Function:    Takes as its primary input an ipf file with 'res=xxx' */
/*              parameters on ':h' tags and replaces the 'xxx' parm   */
/*              with the appropriate '#define' from the definitions   */
/*              file.                                                 */
/*                                                                    */
/* Author:      W. David Ashley                                       */
/*                                                                    */
/* Date:        21 March 1991                                         */
/*                                                                    */
/* (C) W. David Ashley 1991                                           */
/*                                                                    */
/* Notes and Program Limitations:                                     */
/*                                                                    */
/*   1. All :h tags in the input file must start in column 1.         */
/*                                                                    */
/*   2. :h tags that do not contain res= parms are not modified.      */
/*                                                                    */
/*   3. The input and output files must not be the same. This is so   */
/*      that the input file can be modified repeatedly if necessary.  */
/*                                                                    */
/*   4. The definitions file can contain text other than #define      */
/*      statements, but the program could have problems creating      */
/*      a REXX statement that can be properly interpreted from the    */
/*      input. The best way to handle this problem is to create a     */
/*      seperate .h that contains only help identifer #define         */
/*      statements.                                                   */
/*                                                                    */
/*   5. It is possible for #define statements to define REXX variables*/
/*      which conflict with this program's variables. A list of all   */
/*      the known conflicts follows:                                  */
/*                                                                    */
/*        inname     outname     defname      notready                */
/*        fileopen   text        define       rest                    */
/*        statement  name        i            j                       */
/*        k          id          value                                */
/*                                                                    */
/*      Do not #define these names or programm errors will result.    */
/*                                                                    */
/*                                                                    */
/* Modifications:                                                     */
/* --------  ---  --------------------------------------------------- */
/* 03/21/91  WDA  Initial Release                                     */
/*                                                                    */
/*--------------------------------------------------------------------*/

if arg() = 0 | arg() > 1 then do
  say 'Incorrect input parms.'
  say 'Invocation example:'
  say '   ppipfc infile.txt outfile.ipf deffile.h'
  say
  exit
  end

parse arg inname outname defname
if length(inname) = 0 | length(outname) = 0 | length(defname) = 0 then do
  say 'Incorrect input parms.'
  say 'Invocation example:'
  say '   ppipfc infile.txt outfile.ipf deffile.h'
  say
  exit
  end

if inname = outname then do
  say 'Incorrect input parms.'
  say 'Input and Output files cannot be the same.'
  say 'Invocation example:'
  say '   ppipfc infile.txt outfile.ipf deffile.h'
  say
  exit
  end

say 'Input file:      ' inname
say 'Output file:     ' outname
say 'Definitions file:' defname
say

/* read .h file and assign defined variables */
call on notready
fileopen = 1
text = linein(defname)
say 'Beginning parse of definitions file' defname'.'
say
do while fileopen
   parse var text define rest
   if define = '#define' then do
      parse var rest name value rest
      if rest = '' then do
         statement = name || '=' || value /* create rexx statement */
         say statement /* echo assignment */
         interpret statement /* execute rexx statement */
         end
      end
   text = linein(defname)
   end
call lineout defname /* close file */
say
say 'Parsing of the definitions file complete.'
say

/* must delete the output file because REXX output files are not      */
/* truncated on close and the output file will probably be smaller    */
'@del' outname

/* read input file, replace res=values, and write text to output file */
call lineout outname, , 1 /* open output file */
fileopen = 1
text = linein(inname)
say 'Beginning parse of input file' inname'.'
say
do while fileopen
   if length(text) > 8 then do
      select
         when translate(substr(text, 1, 2)) = ':H' then do
            i = pos('res=', text) /* find beginning of clause */
            if i > 0 then do
               j = pos(' ', text, i) /* find possible end of clause */
               k = pos('.', text, i) /* find possible end of clause */
               if k < j then j = k /* find real end of clause */
               if j <> 0 then do
                  id = substr(text, i+4, j-i-4) /* get res identifier */
                  interpret 'id='id /* get res value */
                  /* substitute value for identifer */
                  text = substr(text, 1, i+3) || id || substr(text, j)
                  say text /* echo changed line */
                  end
               end
            end
         otherwise
         end
      end
   call lineout outname, text
   text = linein(inname)
   end
call lineout outname /* close file */
call lineout inname  /* close file */
say
say 'Parsing of the input file complete.'
exit

notready:
fileopen = 0
return
