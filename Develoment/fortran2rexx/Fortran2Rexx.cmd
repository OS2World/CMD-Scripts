/* Assist in the conversion of FORTRAN source to REXX source.  This does not */
/* attempt to convert the logic of the source, only the syntax related       */
/* characteristics.  It is assumed the programmer will manually check and    */
/* complete the conversion.                                                  */
/*                                                                           */
/* FORTRAN2REXX is not intended to make "pretty" output.  To format the REXX */
/* program I recommend something like RexxCodeFormater by RKE_Software.      */
/*                                                                           */
/* The following actions are performed:                                      */
/*   Convert comment lines to REXX format.                                   */
/*   Continuations are removed.                                              */
/*   Type Declarations, including DIMENSION, are converted to comments and   */
/*       all variable names retained in the variables:                       */
/*          VariableList._Simple.                                            */
/*          VariableList._Array.                                             */
/*          VariableList._MIndexArray. (multiple indexed arrays)             */
/*      Array and multiple indexed arrays have the 0th value set.            */
/*   First lines containing "SUBROUTINE" or "FUNCTION" are made into         */
/*      subroutines and the call list made into expose variables.            */
/*   DATA and PARAMETER statements are made into lines of REXX code.         */
/*   Logical operations such as ".GT." are converted to REXX ">".            */
/*   IF statements have "THEN" added after the last ")". *                   */
/*   FORMAT statements are partially interpreted into REXX, the              */
/*      interpretations are stored and used with WRITE(6,... statements.     */
/*      The original FORMAT statement is then converted to a comment.        */
/*   WRITE(6,nnn) statements are partially converted to SAY and marked for   */
/*      further manual editing.                                              */
/*   DO statements are found, recorded and converted to REXX format.         */
/*   END statements are add for the do loops.  DO variables are specified.   */
/*   Single indexed arrays are converted to compound variables.  For example */
/*      a(i) becomes a.i  For these variables indeices that are computed by  */
/*      addition or subtraction of a constant are converted as following:    */
/*         a(i+1) = ... becomes                                              */
/*         ap1 = a+1                                                         */
/*         a.ap1 =                                                           */
/*   CONTINUE statements are converted to "nop".                             */
/*   Code containing array variables which use multiple indices are flagged. */
/*   The last last line of the source is dropped.                            */
/*   "STOP" statements are converted to "RETURN 1"                           */
/*   GO TO nnn pointing to the final return are converted to RETURN          */
/*   GO TO nnn within a DO loop and pointing to the DO's END are changed to  */
/*      ITERATE statements.                                                  */
/*   CALL statements have the bounding "( )" removed.                        */
/*   Line numbers are moved to the end of each line as comments.             */
/*                                                                           */
/*   * Means there is a known limitation to the logic used.  See appropriate */
/*     subroutine.                                                           */
/*                                                                           */
/* The variable "messages." is used to record notes to the user.  These are  */
/* appended to the output program as comments.                               */
/*                                                                           */
/* Be sure to look through the fortran source for function references.       */
/*  Calls to subroutines have to be checked and formated manually.           */
/*  Calls to functions having the form abs(v) will be converted as though    */
/*  they are simple arrays.                                                  */
/*                                                                           */
/* A simple way to handle the swapping of variables which FORTRAN permits in */
/* subroutine calls adds an intermediate subroutine, as follows:             */
/*                                                                           */
/*    Source has --                                                          */
/*              call splev(t,n,c,k,x,sp,m,ier)                               */
/*       . . .                                                               */
/*              subroutine splev(t,n,c,k,x,y,m,ier)                          */
/*                                                                           */
/*    REXX has --                                                            */
/*              call SplevStarter /* t,n,c,k,x,sp,m,ier */                   */
/*       . . .                                                               */
/*              SplevStarter:                                                */
/*              procedure expose t. n c. k x. sp. m ier                      */
/*              rc= arraycopy(sp.,y.)                                        */
/*              call splev                                                   */
/*              rc= arraycopy(y.,sp.)                                        */
/*              return                                                       */
/*       . . .                                                               */
/*              splev:                                                       */
/*              procedure expose  t. n c. k x. y. m ier                      */
/*                                                                           */
/*                                                                           */
/* You are invited to extend or improve this code.  Please add your name to  */
/* the author list below, send a copy to D. Rickman. and I will repost it to */
/* the web.                                                                  */
/*                                                                           */
/* Doug Rickman August 23, 2000  doug@hotrocks.msfc.nasa.gov                 */

signal on Halt
signal on NotReady

if rxfuncquery('rexxlibregister') then do         /* this will start rexxlib */
	call rxfuncadd 'rexxlibregister', 'rexxlib', 'rexxlibregister'  
	call rexxlibregister
	end
if rxfuncquery('sysloadfuncs') then do           /* this will start rexxutil */
	CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' 
	CALL SysLoadFuncs
	end

arg in 
in=strip(in)
out=strip(out)

if in='' | in='?' | in='-?' | in='/?' then call Help
if dosisfile(in)<>1 then do
   say 'The input file: ' in' is not a valid file.'
	exit
	end /* do */

out     = left(in,length(in)-2) || '.cmd'
rc = dosdel(out)

/* --------------------------------------------------------------------------*/
/* --- begin MAIN                                               -------------*/

rc=stream(in,'c','open read')

/* Read in the source code. */
do i = 1
   line.i = linein(in)
   if lines(in) = 0 then leave i
   end i
Line.0 = i
rc=lineout(in)

messages.0 = 0
VariableList._Simple.0      = 0
VariableList._Array.0       = 0
VariableList._MIndexArray.0 = 0


rc = ConvertCommentLines()

rc = RemoveContinuations()

rc = ConvertTypeDeclarations() /* Includes DIMENSION */

rc = ConvertFirstLines() /* Looks for subroutines and functions. */

rc = ConvertData()

rc = ConvertParameter()

rc = Convert_GT_Lines()

rc = AddThen2IFStatements()

rc = EditFormatsStatements()

rc = EditWriteStatements()

rc = FindDO_Statements()

rc = AddEnds4DOs()

rc = MakeArrays()

rc = ConvertContinue() /* convert to "nop" */

rc = Check4MultiIndexArrayVariable()

/* Drop last line. */
Line.0 = Line.0 - 1

rc = ConvertGOTO_END()

rc = ConvertSTOP()

rc = EditCALLStatements()

rc = MoveLineNumbers()


/* Write out the REXX source. */
do i = 1 to Line.0
   rc=lineout(out,Line.i)
   end i

rc  = lineout(out,' ')

txt = 'Converted from 'in
txt = left(txt,74)
rc  = lineout(out,'/*' txt '*/')

txt = 'with the aid of FORTRAN2REXX, version Aug 23, 2000, by D. Rickman.'
txt = left(txt,74)
rc  = lineout(out,'/*' txt '*/')

txt = Date('L') Time('C')
txt = left(txt,74)
rc  = lineout(out,'/*' txt '*/')

/* Setup variable lists. */
txt1 = "Simple variables declared:"
do i = 1 to VariableList._Simple.0
   txt1 = txt1 VariableList._Simple.i',' 
   end i
txt1 = strip(txt1,'T',',')
messageN = messages.0 + 1
messages.messageN = txt1
messages.0 = messageN

txt1 = "Single indexed compound variables declared:"
do i = 1 to VariableList._Array.0
   txt1 = txt1 VariableList._Array.i','
   end i
txt1 = strip(txt1,'T',',')
messageN = messages.0 + 1
messages.messageN = txt1
messages.0 = messageN

txt1 = "Multiply indexed compound variables declared:"
do i = 1 to VariableList._MIndexArray.0 
   txt1 = txt1 VariableList._MIndexArray.i','
   end i
txt1 = strip(txt1,'T',',')
messageN = messages.0 + 1
messages.messageN = txt1
messages.0 = messageN

do i = 1 to messages.0
   if length(messages.i) < 75 then
      rc = lineout(out,'/* 'left(messages.i,74)' */')
   else
      rc = lineout(out,'/* 'messages.i' */')
   end

rc=lineout(out)
return 1

rc = stream(out,'c','close')

/* --- end MAIN                                                 -------------*/
/* --------------------------------------------------------------------------*/

/* Find numbered statements, insert 'end' statements if matched to a 'do'.   */
AddEnds4DOs:
procedure expose Line. Do.
do j = 1 to do.0
   do i = 1 to line.0
      if left(Line.i,1) \= ' ' then iterate i      /* Skip comments.         */
      parse var Line.i LineN 7 Stuff
      if words(LineN) = 0 then iterate i           /* Skip unnumbered lines. */
      /* Does this match a do loop? */
      LineN = strip(LineN)
      if do._LineN.j = LineN then do               /* Goes with a do loop.   */
         rc=MoveUp1Line(i)
         Line.i = '         end 'Do._Var.j' /* 'LineN' */'
         i = i + 1
         iterate j
         end /* do */
      end i
   end j
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Look for 'if' statements and add 'then'.                                  */
/* This logic has a problem if there is a ")" after the if clause.           */
AddThen2IFStatements:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i         /* Skip comments.         */
   parse var Line.i LineN 7 Stuff
   Stuff = translate(strip(Stuff))
   if left(Stuff,3) = 'IF(' then do
      v = lastpos(')',Line.i)
      Line.i = insert(' then',Line.i,v)
      end /* do */
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

Check4MultiIndexArrayVariable:
procedure expose Line. messages. VariableList.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   if pos(')',Line.i) < 12 then iterate i
   if pos(',',Line.i) < 10 then iterate i
   /* Only lines that have "( , )" will be checked. */
   CleanStuff = translate(Line.i,'        ','+-/*,).=')
   do j = 1 to VariableList._MIndexArray.0
      pattern = VariableList._MIndexArray.j || '('
      rc = grep(pattern,CleanStuff)
      if word(rc,1) > 0 then do
         Line.i = strip(Line.i,'T') '   <<--'
         txt1= 'Probable multi-index array at approx. line' i
         messageN = messages.0 + 1
         messages.messageN = txt1
         messages.0 = messageN
         end /* do */
      end j
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Convert .gt. lines. */
Convert_GT_Lines:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments. */
   Line.i = change(Line.i,'.gt.',' > ')
   Line.i = change(Line.i,'.lt.',' < ')
   Line.i = change(Line.i,'.ge.',' >= ')
   Line.i = change(Line.i,'.le.',' <= ')
   Line.i = change(Line.i,'.and.',') & (')
   Line.i = change(Line.i,'.or.' ,') | (')
   Line.i = change(Line.i,'.eq.',' = ')
   Line.i = change(Line.i,'.ne.',' \= ')

   Line.i = change(Line.i,'.GT.',' > ')
   Line.i = change(Line.i,'.LT.',' < ')
   Line.i = change(Line.i,'.GE.',' >= ')
   Line.i = change(Line.i,'.LE.',' <= ')
   Line.i = change(Line.i,'.AND.',') & (')
   Line.i = change(Line.i,'.OR.' ,') | (')
   Line.i = change(Line.i,'.EQ.',' = ')
   Line.i = change(Line.i,'.NE.',' \= ')
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Convert comment lines. */
ConvertCommentLines:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then 
      Line.i = '/*'||substr(Line.i,2,75,' ')||'*/'
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Find 'continue' statements and convert to 'nop'.                          */
ConvertContinue:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   if words(LineN) = 0 then iterate i /* Skip unnumbered lines. */
   Stuff2 = translate(Stuff)
   if Stuff2 = 'CONTINUE' then 
      Line.i = change(Line.i,Stuff,'nop')
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Convert DATA statements.                                                  */
ConvertData:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   CapStuff = strip(translate(Stuff))
   if left(CapStuff,4) = 'DATA ' then do
      data = ''

      /* parse the list of variables */
      parse var Stuff . VariablesList '/' ValuesList '/' .
      Start  = 2
      pcomma = 1
      do j = 1
         if pcomma = 0 then leave j
         pcomma = pos(',',VariablesList,Start)
         popen  = pos('(',VariablesList,Start)
         pclose = pos(')',VariablesList,Start+1)

         if pcomma < pclose then 
            pcomma = pos(',',VariablesList,pclose)

         if pcomma = 0 then do
            variable = VariablesList
            VariablesList = ''
            end
         else 
            parse var VariablesList variable =(pcomma) . ',' VariablesList
         /* "variable" is the declaration of the jth variable. */
         variable = strip(variable) 

         parse var ValuesList value ',' ValuesList
         data = data strip(variable) || '=' || value || ';'
         end j
      Line.i = LineN || data
      end
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Convert first line. */
ConvertFirstLines:
procedure expose Line. VariableList.
parse var Line.1 v1 v2 v3 v4
select
   when 'FUNCTION'= translate(v2) then
      parse var Line.1 . . name '(' variables ')'
   when 'SUBROUTINE' = translate(v1) then
      parse var Line.1 . name '(' variables ')'
   otherwise return 0
   end  /* select */

Line.1 = name||':'
rc = MoveUp1Line(2)

/* Add "." to all array variables. */
ExposeList = ''
do j = 1
   if variables = '' then leave j
   parse var variables v ',' variables
   v = strip(v)
   do i = 1 to VariableList._Array.0
      if v = VariableList._Array.i then do
         ExposeList = ExposeList v||'.'
         iterate j
         end /* do */
      end i
   do i = 1 to VariableList._MIndexArray.0 
      if v = VariableList._MIndexArray.i then do
         ExposeList = ExposeList v||'.'
         iterate j
         end /* do */
      end i
   ExposeList = ExposeList v
   end j

Line.2 = 'procedure expose 'ExposeList
return 1

/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Get line number of return at end of program and replace all go to returns.*/
ConvertGOTO_END:
procedure expose Line.
i = Line.0
parse var Line.i LineN 7 Stuff
if words(LineN) \= 0 then do
   LineN = strip(LineN)
   do i = 1 to Line.0
      if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
      if pos('go to',Line.i) > 0 then do
         Line.i = change(Line.i,'go to' LineN,'return')
         iterate i
         end /* do */
      if pos('GO TO',Line.i) > 0 then do
         Line.i = change(Line.i,'GO TO' LineN,'return')
         iterate i
         end /* do */
      end i
   end 
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Convert Parameter Statements into lines of code. */
ConvertParameter:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   if left(Stuff,9) = 'PARAMETER' | left(Stuff,9) = 'parameter' then do
      v = pos('(',Stuff)
      parse var Stuff . =(v) v2
      v2 = strip(v2,'T')
      v2 = strip(v2,'T',')')
      v2 = strip(v2,'T')
      v2 = change(v2,',',';')
      end /* do */
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Convert STOP to RETURN 1                                                  */
ConvertSTOP:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   CapStuff = translate(strip(Stuff))
   if left(CapStuff,4) = 'STOP' then 
      Line.i = 'Return 1'
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Convert type declarations to comments.  Store names of declared variables.*/
/* Generate compound variable 0th terms from array dimensions.               */
ConvertTypeDeclarations:
procedure expose Line. messages. VariableList.

m = 0
do i = 1
   if i > Line.0 then leave i
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   if i = 1 then iterate i
   parse var Line.i LineN 7 Stuff
   CapStuff = translate(strip(Stuff))
   if left(CapStuff,4) = 'REAL' |,
      left(CapStuff,7) = 'INTEGER' |,
      left(CapStuff,9) = 'DIMENSION' then do

      /* Break line into variables.                                       */
      parse var Stuff . MoreStuff  /* Remove the leading "type".          */
      MoreStuff = strip(MoreStuff)
      Start  = 2
      pcomma = 1
      do j = 1
         if pcomma = 0 then leave j
         pcomma = pos(',',MoreStuff,Start)
         popen  = pos('(',MoreStuff,Start)
         pclose = pos(')',MoreStuff,Start+1)

         if pcomma < pclose then 
            pcomma = pos(',',MoreStuff,pclose)

         if pcomma = 0 then do
            variable = MoreStuff
            MoreStuff = ''
            end
         else 
            parse var MoreStuff variable =(pcomma) . ',' MoreStuff
         /* "variable" is the declaration of the jth variable. */
         variable = strip(variable) 

         select 
            when pos('(',variable) = 0 then do
               N = VariableList._Simple.0 + 1
               VariableList._Simple.N = variable
               VariableList._Simple.0 = N
               iterate j
               end /* do */

            when pos(',',variable) = 0 then do
               parse var variable name '(' v ')'
               N = VariableList._Array.0 + 1
               VariableList._Array.N = name
               VariableList._Array.0 = N

               rc = MoveUp1Line(i)
               ip1 = i + 1
               line.ip1 = name'.0 = 'v
               
               iterate j
               end /* do */

            otherwise do
               parse var variable name '(' v 
               v = strip(v,'T',')')
               /* Count the number of commas in the definition. */
               StartCommaCount = 1
               NCommas = 0
               do k = 1
                  StartCommaCount = pos(',',v,StartCommaCount+1)
                  if StartCommaCount = 0 then leave k
                  NCommas = NCommas + 1
                  end k
               N = VariableList._MIndexArray.0 + 1
               VariableList._MIndexArray.N = name
               VariableList._MIndexArray.0 = N
               txt1= 'There are 'NCommas+1' indices in the variable 'name
               messageN = messages.0 + 1
               messages.messageN = txt1
               messages.0 = messageN
               insert = ''
               do k = 1 to NCommas+1
                  parse var v v1 ',' v
                  rc = MoveUp1Line(i)
                  ip1 = i + 1
                  line.ip1 = name||insert||'.0 = 'v1 '   /* <<<<<-----  Compound variable */'                 
                  insert = insert || '.i'k
                  end k
               end /* otherwise ... */

            end  /* select */
         end j

      rc = MakeIntoComments(i,Line.i)
      end /* if then ... */
   end i
/* 
do i = 1 to line.0
   say i line.i
end /* do */
*/
MultiIndexArrayVariable.0 = m
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Remove the bounding "( ) from CALL statements.                            */
EditCALLStatements:
procedure expose Line.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   CapStuff = translate(strip(Stuff))
   pos =  pos('CALL ',CapStuff)
   if pos > 0  then do
      pos = pos + 5
      parse var Stuff =(pos) SubroutineName '(' MoreStuff 
      if datatype(SubroutineName,'A') &,
         SubroutineName == strip(SubroutineName) then do
         pos   = pos('(',Stuff,pos+5)
         pos2  = lastpos(')',Stuff)
         Stuff = overlay(' ',Stuff,pos)
         Stuff = overlay(' ',Stuff,pos2)
         Stuff = space(Stuff)
         line.i = LineN Stuff
         end /* do */
      end /* if pos> 0 then ... */
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Edit formats into something that is pseudo REXX, store this in "Format."  */
/* and convert format statements into comments.                              */
EditFormatsStatements:
procedure expose Line. messages. Format.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   CapStuff = translate(strip(Stuff))
   if left(CapStuff,7) = 'FORMAT(' then do

      len   = length(Stuff)
      Stuff = substr(Stuff,1,len-1) /* Get rid of trailing ")". */
      parse var Stuff . 8 MoreStuff
      LineN2 = strip(LineN)
      do j = 1
         if strip(MoreStuff) = '' then leave j

         /* Check for hollerith */
         temp = translate(MoreStuff)
         hpos = pos('H',temp)
         if hpos > 1 then do
            parse var temp v =(hpos) 'H' v2
            if datatype(v,'W') & v == strip(v) then do /* This is a hollerith. */
               hpos = hpos + 1
               v = v + hpos
               parse var MoreStuff . =(hpos) FormatPart.LineN2.j =(v) ',' MoreStuff
               iterate j
               end /* do */
            end

         /* Find 1st comma outside of a ( ). */
         rc = ParseUsingCommas(i,MoreStuff)
         select
            when rc > 0 then do
               parse var MoreStuff FormatPart.LineN2.j =(rc) ',' MoreStuff
               end /* do */
            when rc = 0 then do
               FormatPart.LineN2.j = MoreStuff
               MoreStuff = ''
               end
            when rc < 0 then do
               say 'In EditFormatsStatements() - Error in parsing line 'i
               say '---' Line.i
               iterate i
               end
            end /* select */
         end j  
      FormatPart.LineN2.0 = j - 1

      Format.LineN2 = ''
      do j = 1 to FormatPart.LineN2.0
         /* Find and expand blank spaces. */
         len = length(FormatPart.LineN2.j)
         v = substr(FormatPart.LineN2.j,1,len-1)
         if translate(right(FormatPart.LineN2.j,1)) = 'X' &,
           datatype(v,'W') &  v == strip(v) then do
            Format.LineN2 = Format.LineN2||"'"||left(' ',v-1)||"'"
            iterate j
            end

         /* Check for repeated stuff. */
         pos = pos('(',FormatPart.LineN2.j)
         parse var FormatPart.LineN2.j v =(pos) v2
         if datatype(v,'W') &  v == strip(v) then do
            do k = 1 to v
               Format.LineN2 = Format.LineN2 v2
               end k
            iterate j
            end

         pos = pos('F',translate(FormatPart.LineN2.j))
         parse var FormatPart.LineN2.j v =(pos) v2
         if datatype(v,'W') &  v == strip(v) then do
            parse var v2 . 2 before '.' after
            v2 = 'format(vvvv,'before','after')'
            do k = 1 to v
               Format.LineN2 = Format.LineN2 v2
               end k
            iterate j
            end

         pos = pos('E',translate(FormatPart.LineN2.j))
         parse var FormatPart.LineN2.j v =(pos) v2
         if datatype(v,'W') &  v == strip(v) then do
            parse var v2 . 2 before '.' after
            v2 = 'format(vvvv,4,'after',,0)'
            do k = 1 to v
               Format.LineN2 = Format.LineN2 v2
               end k
            iterate j
            end

         pos = pos('I',translate(FormatPart.LineN2.j))
         parse var FormatPart.LineN2.j v =(pos) v2
         if datatype(v,'W') &  v == strip(v) then do
            parse var v2 . 2 before
            v2 = 'format(vvvv,'before',,,)'
            do k = 1 to v
               Format.LineN2 = Format.LineN2 v2
               end k
            iterate j
            end

         Format.LineN2 = Format.LineN2 "'"FormatPart.LineN2.j"'"
         end j
      /* say LineN2 Format.LineN2 */
      rc = MakeIntoComments(i,Line.i)
      end  /* if this is a format statement ... */

   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

EditWriteStatements:
procedure expose Line. Format.
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   CapStuff = translate(strip(Stuff))
   if left(CapStuff,7) = 'WRITE(6' then do 

      parse var CapStuff .  ',' LineN2 ')' v3
      if Format.LineN2 \= 'FORMAT.'LineN2 then do
         line.i = 'say 'Format.LineN2  '   |--- EDITING WRITE STATEMENT --->> 'line.i
         end 
      end /* if left( ) then ... */
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Find all do statements.  Record the end line number and variable name.    */
/* Convert GO TO statements within limits of each DO to iterate.             */
FindDO_Statements:
procedure expose Line. do.
j=0
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.    */
   parse var Line.i LineN 7 Stuff
   CapStuff = translate(strip(Stuff))
   if word(CapStuff,1) = 'DO' then do
      /* First reformat the DO statement into REXX. */
      v  = pos(',',Stuff)
      v2 = pos(',',Stuff,v+1)
      if v2 > 0 then do
         Stuff = insert(' by ',Stuff,v2)
         Stuff = delstr(Stuff,v2,1)
         end
      Stuff = insert(' to ',Stuff,v)
      Stuff = delstr(Stuff,v,1)

      parse var Stuff  Stuff1 ELineN Stuff2
      Line.i = LineN||Stuff1 strip(Stuff2) '/* do 'ELineN' */'
      /* Record associated line number for later use. */
      j=j+1
      do._LineN.j = strip(ELineN)
      parse var Stuff2 Do._Var.j '=' .


      /* Now look for GO TO statements to convert to ITERATE.                */
      do k = i+1 to Line.0
         parse var Line.k LineN 7 Stuff
         if strip(LineN) = ELineN then leave k
         CapStuff = translate(strip(Stuff))
         pos = pos('GO TO',CapStuff)
         if pos > 0 then do
            parse var CapStuff v 'GO TO' GLineN
            if ELineN = strip(GLineN) then 
               Line.k = LineN v 'iterate 'Do._Var.j
            end /* if pos > 0 then ... */         
         end k

      end /* do */
   end i
do.0 = j
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Treat numbers and variables of form  string(nnn) as array indexes.        */
/* This does not handle double indexed arrays.                               */
MakeArrays:
procedure expose line. messages.
do i = 1
   if i > Line.0 then leave i
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments.               */
   parse var Line.i LineN 7 Stuff
   Start = 1
   Stuff = strip(Stuff)
   do j = 1
      /* Begin looking for opening parentheses. */
      v  = pos('(',Stuff,Start)
      v2 = pos(')',Stuff,v+1)
      if v = 0 | v2 = 0 then 
         /* No "(" or ")" in rest of line. */
         leave j                

      if v = 1 then do
         /* Paren. at start of line??? */
         Start = v +1
         iterate j
         end

      if v > 2 then do
         if translate(substr(Stuff,v-2,2)) = 'IF' then do
            /* This is an IF statement. */
            Start = v +1
            iterate j
            end
         end

      if datatype(substr(Stuff,v-1,1),'A') \= 1 then do
         /* "(" preceded by blank space or a non Alphanumeric character. */
         Start = v +1
         iterate j
         end

      /* Is this the first variable of a call statement? */
      RStuff = reverse(Stuff)
      RStuff2 = translate(translate(RStuff,'   ',',()'))
      BlankN1 = pos(' ',RStuff2,length(RStuff2)-v)
      if pos(' LLAC',RStuff2, length(RStuff2)-v) = BlankN1 then do
         Start = v +1
         iterate j
         end /* if then ... */

      v3 = substr(Stuff,v+1,v2-v-1)
      /* v3 holds what was between the ( ) */
      if pos(',',v3) > 0 then do
          /* Contains "," */
         Start = v +1
         iterate j
         end /* if then ... */

      if datatype(v3,'W') then do
         /* A whole number.  This has to be an index. */
         Stuff = overlay('.',Stuff,v)
         Stuff = overlay(' ',Stuff,v2)
         Start = v +1
         iterate j
         end /* if then ... */

      if datatype(v3,'A') & words(v3) = 1 then do
         /* A single alphanumeric string.  This has to be an index. */
         Stuff = overlay('.',Stuff,v)
         Stuff = overlay(' ',Stuff,v2)
         Start = v +1
         iterate j
         end /* if then ... */

      /* Looking for indexes of the form (variable-variable) */
      v4 = pos('-',v3)
      if v4 > 0 then do
         parse var v3 before '-' after
         if datatype(before,'A') & words(before)=1 & datatype(after,'W') then do
            /* A variable minus an offset. */
            string = '.'before'm'after
            Stuff = overlay(string,Stuff,v)
            Stuff = overlay(' ',Stuff,v2)
            rc = MoveUp1Line(i)
            Line.i = before'm'after '=' v3
            i = i+1
            txt1= 'Array index variable 'before'm'after' created.  Approx. output line 'i+3
            messageN = messages.0 + 1
            messages.messageN = txt1
            messages.0 = messageN
            txt1= line.i
            messageN = messages.0 + 1
            messages.messageN = txt1
            messages.0 = messageN
            end
         Start = v +1
         iterate j
         end /* if then ... */

      /* Looking for indexes of the form (variable+variable) */
      v4 = pos('+',v3)
      if v4 > 0 then do
         parse var v3 before '+' after
         if datatype(before,'A') & words(before)=1 & datatype(after,'W') then do
            /* A variable minus an offset. */
            string = '.'before'p'after
            Stuff = overlay(string,Stuff,v)
            Stuff = overlay(' ',Stuff,v2)
            rc = MoveUp1Line(i)
            Line.i = before'p'after '=' v3
            i = i+1
            txt1= 'Array index variable 'before'p'after' created.  Approx. output line 'i+3
            messageN = messages.0 + 1
            messages.messageN = txt1
            messages.0 = messageN
            txt1= line.i
            messageN = messages.0 + 1
            messages.messageN = txt1
            messages.0 = messageN
            end
         Start = v +1
         iterate j
         end /* if then ... */

      end j
   Line.i = LineN||Stuff
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

/* Convert the input string into comments. */
MakeIntoComments:
procedure expose Line.
i     = arg(1)
Stuff = arg(2)
k = length(strip(Stuff,'T'))/76
do j = 1 to k
   rc = MoveUp1Line(i)
   end j
do j = 0 to k
   parse var Stuff v 76 Stuff
   ipj = i + j        
   Line.ipj = '/*'||left(v,76)||'*/'
   end j
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

MoveDown1Line:
procedure expose Line.
i = arg(1) /* Line at which to start moving down, i.e. from line 4 to line 3. */
do j = i to Line.0
   jp1 = j + 1
   Line.j = Line.jp1
   end j
Line.0 = Line.0 - 1
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */

MoveLineNumbers:
procedure expose Line.
/* Move line numbers to end of each line as comments. */
do i = 1 to Line.0
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments. */
   parse var Line.i LineN 7 Stuff
   if words(LineN) = 0 then
      Line.i = strip(Stuff,'T')
   else
      Line.i = strip(Stuff,'T') '/* Line Number 'strip(LineN)' */'
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */ 

MoveUp1Line:
procedure expose line.
i = arg(1)  /* Line at which to start moving up, i.e. from line 3 to line 4. */
do j = Line.0 to i by -1
   jp1 = j + 1
   Line.jp1 = Line.j
   end j
Line.0 = Line.0 + 1
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Find the end position of the first logical portion of the input string.   */
ParseUsingCommas:
procedure expose Line. messages.
LineN = arg(1)
data  = arg(2)

pcomma.1 = pos(',',Data,2)
popen.1  = pos('(',Data,1)
pclose.1 = pos(')',Data,1)

if pcomma.1 = 0       then return 0         /* No commas present.            */
if popen.1  = 0       then return pcomma.1  /* No ( ) before first comma.    */
if pcomma.1 < popen.1 then return pcomma.1  /* 1st unit has no ( )           */

/* 1st unit must have ( ), now be sure the "," is outside of them.           */
/* Count the number of "(" and the number of ")".                            */
do j = 2
   jm1 = j - 1
   popen.j    = pos('(',Data,popen.jm1+1)
   if popen.j = 0 then leave j
   end j
popen.0 = j - 1

do j = 2
   jm1 = j - 1
   pclose.j    = pos(')',Data,pclose.jm1+1)
   if pclose.j = 0 then leave j
   end j
pclose.0 = j - 1

if popen.0 <> pclose.0 then do
   txt1= 'Warning - There is a mismatch in ( and ) in approx. line 'LineN' :' data
   messageN = messages.0 + 1
   messages.messageN = txt1
   messages.0 = messageN
   end

/* Count "(" before first ")". */
do j = 1 to pclose.0
   do k = 1 to popen.0
      if popen.k > pclose.j then leave k
      end k
   if k > popen.0 then do /* Use position of last ")"  */
      j = pclose.0
      leave j
   else do
      k = k - 1
      if k = j then leave j   /* pclose.k is last ")" in this set.           */
      if k < j then return -1 /* Something is wrong. */
      if k > j then iterate j /* More "(" and ")" so far.  Add another ")".  */
      end

   end j
pcomma = pos(',',data,pclose.j)
return pcomma
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */


/* Remove continuations. */
RemoveContinuations:
procedure expose Line.
do i = 1 
   /* say right(i,4) line.0 */
   if i > Line.0 then leave i
   if left(Line.i,1) \= ' ' then iterate i /* Skip comments. */
   if substr(Line.i,6,1) \= '' then do
      im1 = i - 1
      line.im1 = line.im1 || substr(Line.i,7,70)
      Line.im1 = strip(line.im1,'T')
      rc=MoveDown1Line(i)
      i = i-1
      end
   end i
return 1
/*    -    -    -    -    -    -    -    -    -    -    -    -    -    -     */ 

/* --------------------------------------------------------------------------*/
/* --- begin subroutine - Help:                                 -------------*/
Help:
rc= charout(,'1b'x||'[31;7m'||'FORTRAN2REXX:'||'1b'x||'[0m'||'0d0a'x)
say 'Assist in conversion of FORTRAN source to REXX code.'

say ''
rc= charout(,'1b'x||'[33;1m'||'usage:'||'1b'x||'[0m')
say ' FORTRAN2REXX in'
say ''

rc= charout(,'1b'x||'[33;1m'||'where:'||'1b'x||'[0m')
say ' in = FORTRAN source file, must end in ".f" '
say ''

rc= charout(,'1b'x||'[33;1m'||'Exam: '||'1b'x||'[0m')
say ' FORTRAN2REXX curfit.f'
say ''

rc= charout(,'1b'x||'[33;1m'||'notes:'||'1b'x||'[0m')
say ' The output is named using the input with .f replaced by .cmd'
say ''

say ''
say 'Doug Rickman  August 24, 2000'
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


* --- begin subroutine - Change:                               -------------*/
/*Here's my [Mike Cowlishaw] CHANGE.REX (circa 1982). It should be reasonably*/
/*fast on most platforms.                                                    */
/*Provided to Dick Thaxter <rtha@loc.gov> Thu Aug 20 08:32:23 1998 in        */
/*comp.lang.rexx  Comments edited by DLR Aug 20, 1998.                       */
/* CHANGE(string,old,new)                                                    */
/* Changes all occurrences of "old" in "string" to "new".                    */
/* If "old"=='', then "new" is prefixed to "string".  MFC                    */

Change: procedure
parse arg string, old, new
if old='' then return new||string
out=''
do while pos(old,string)\=0
   parse var string prefix (old) string
   out=out||prefix||new
   end
return out||string
/* --- end subroutine  - Change:                                -------------*/
/* --------------------------------------------------------------------------*/

