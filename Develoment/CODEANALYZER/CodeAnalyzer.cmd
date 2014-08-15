/* Find subroutine calls and provide map of same for a REXX program.         */
/*                                                                           */
/* For information see documentation.                                        */
/*                                                                           */
/* Doug Rickman March 11, 2003                                               */
/*                                                                           */
/* Contributors:                                                             */
/*   Peter Skye, Mark Hessling                                               */
/*                                                                           */
/* Aug. 19, 2003                                                             */
/* - Changed compound variable names which included strings .Str., .End.,    */
/*   .Typ., .Txt. to ._Str., ._End., ._Typ., ._Txt..  The previous naming    */
/*   was very bad practice and had caused an error.                          */
/* - Patched subroutine RebuildALineComment for lines ending in "/" within a */
/*   multiline comment.                                                      */

/* Error handling. */
GenericErrorQUIET = 'DECODE'
/* GenericErrorQUIET = 'NO' */
signal on syntax name GenericError

signal on Halt
signal on NotReady

/* Load the DLLs. */
DLL = 'RexxUtil' ; LoadFunc = 'sysloadfuncs'
rc = LoadMyDll(DLL,LoadFunc)
if rc \= 1 then do
   say 'Failure loading the dll ' DLL
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end

/* DLL = 'RexxLib' ; LoadFunc = 'rexxlibregister'      */
/* rc = LoadMyDll(DLL,LoadFunc)                        */
/* if rc \= 1 then do                                  */
/*    say 'Failure loading the dll ' DLL               */
/*    parse var SubRoutineHistory . SubRoutineHistory  */
/*    return 0                                         */
/*    end                                              */
 
rc = Test4CountStr()
if rc \=1 then do    /* if missing then do */
   /* contributed by Peter Skye */
   say "ALERT - the internal Rexx function COUNTSTR() is not available."
   say "You need to switch to the newer Rexx DLL containing the COUNTSTR() function."
   say "This DLL is supplied with Object Rexx and is fully compatible with the older"
   say "classic Rexx."
   say "One simple way to do this is to run SWITCHRX.CMD in the x:\OS2\ directory and"
   say "then reboot.  This will completely switch your Rexx to Object Rexx which is"
   say "fully compatible with classic Rexx programs.  You can always switch back to"
   say "classic Rexx by running SWITCHRX.CMD again and then rebooting."
   say "Other alternatives are to use other DLL libraries that have this function,"
   say "for example RXSCOUNT in RXU."
   "pause"
   return 0
   end

rc = Test4SysStemSort()
if rc \=1 then do    /* if missing then do */
   /* contributed by Peter Skye */
   say "ALERT - the internal Rexx function SYSSTEMSORT() is not available."
   say "Possible options:"
   say "   Switch to a newer Rexx DLL containing the function."
   say "   Obtain a copy of Patrick McPhee's REGUTIL.  Be sure to load the DLL."
   say "   Obtain a copy of REXXLIB, which is available for OS/2.  Then edit the"
   say "      lines that make the SysStemSort call to use the ARRAYSORT( ) call."
   say "      And of course be sure to load the REXXLIB dll."
   say "   Write a subroutine to do the sorting.  There are several generic sort"
   say "      routines available on the web."
   "pause"
   return 0
   end

SubRoutineHistory = 'Begin_Program'

DefaultExposeList  = 'out'              ,
                     'GenericErrorQUIET',
                     'SubRoutineHistory',
                     'Function.'        ,
                     'FunctionLib.'     ,
                     'Conditions.'      ,
                     'SourceIndex.'     ,
                     'DefaultTxtObjt'   , 
                     'DefaultMLEObjt'   ,
                     'DefaultSayInst'

MasterM = 'CodeAnalyzer'

parse arg temp /* Case sensitive argument input. */
if datatype(temp,'N') \= 1 then
   /* If run within VisPro temp will be a number. */
   in = temp

in=strip(in)

if in='' | in='?' | in='-?' | in='/?' then do
   say 'There is no command line help.  Yet.'
   return 0
   end

in=stream(in,'c','query exists')
if in = '' then do
   say 'The input file: 'in' is not a valid file.'   
   return 0
   end
/* We now have the full name, including drive and path in the variable "in". */

rc=stream(in,'c','open')
if rc \= 'READY:' then do
   say 'The input file: 'in' could not be opened.'
   say 'Is it locked by another program?  Do you have write permission?'
   return 0
   end 

say quote()

out = in || '.AnalOCode.txt'
rc  = SysFileDelete(out)

rc = Main(in)
rc = beep(300,50)
rc = beep(38,50)
rc = beep(300,50)

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   Begin_Program                                      -------------*/
/* --------------------------------------------------------------------------*/


Change:
/* --- begin subroutine - Change:                               -------------*/
/*Here's my [Mike Cowlishaw] CHANGE.REX (circa 1982). It should be reasonably*/
/*fast on most platforms.                                                    */
/*Provided to Dick Thaxter <rtha@loc.gov> Thu Aug 20 08:32:23 1998 in        */
/*comp.lang.rexx  Comments edited by DLR Aug 20, 1998.                       */
/* CHANGE(string,old,new)                                                    */
/* Changes all occurrences of "old" in "string" to "new".                    */
/* If "old"=='', then "new" is prefixed to "string".  MFC                    */
procedure
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


ClearCommentBlock: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - ClearCommentBlock:                    -------------*/
/* Replace a comment with blanks. The comment may extend over multiple lines.*/
/* June 24, 2003 Fixed computation of SegLength for first case.              */
procedure expose (DefaultExposeList) Temp.
SubRoutineHistory = 'ClearCommentBlock' SubRoutineHistory

Start = arg(1) /* A decimal encoding of line and character position. */
End   = arg(2) /* A decimal encoding of line and character position. */

parse var Start StrLine '.' StrChar
parse var End   EndLine '.' EndChar

StrLine = StrLine/1
EndLine = EndLine/1
StrChar = StrChar/1
EndChar = EndChar/1
      
do j = StrLine to EndLine
   if j = StrLine then
      StrChar = StrChar
   else
      StrChar = 1

   if j = EndLine then 
      SegLength = EndChar+2 - StrChar
   else 
      SegLength = length(Temp.j)+1 - StrChar

   /* overlay(new target n length pad)  */
   Temp.j = overlay(' ',Temp.j,StrChar,SegLength,' ')
   end

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - ClearCommentBlock:                    -------------*/
/* --------------------------------------------------------------------------*/


ClearLiteralStrings: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine -ClearLiteralStrings:                   -------------*/
/* Replace a literal with blanks. The literal values is stored in "Literal.".*/
procedure expose (DefaultExposeList) data StrLiteral. EndLiteral. Literal.
SubRoutineHistory = 'ClearLiteralStrings' SubRoutineHistory

data    = arg(1)
n2Clear = arg(2)
      
do i = 1 to n2Clear
   Literal.i = substr(data,StrLiteral.i+1,EndLiteral.i-StrLiteral.i-1)
   /* overlay(new target n length pad)  */
   data = overlay(' ',data,StrLiteral.i,EndLiteral.i-StrLiteral.i+1,' ')
   end

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - ClearLiteralStrings:                  -------------*/
/* --------------------------------------------------------------------------*/


FindCallInstructions: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FindCallInstructions:                 -------------*/
/* Find usages of the CALL instruction.  This routine assumes the string     */
/* "CALL" (case insensitive) is known to exist in the line being evaluated.  */
/*   **** This does not handle more than one CALL on a single line.          */
/* Returns:                                                                  */
/*   0    - an error condition detected.                                     */
/*   1    - normal return.  FRef. variables are set.                         */
/*   2    - there is no CALL instruction on this line.                       */
/*   3    - a call to a variable subroutine was found.                       */
/* FRef.line._Open.k = FRef.line._Close.k when there are no arguments passed.*/
procedure expose (DefaultExposeList)                          ,
                 Comment.      Label.         Fref.           ,
                 Literal.      SRMap.        CurRoutine       ,
                 SignalFlag
                 
ThisSubroutine    = 'FindCallInstructions'
SubRoutineHistory = ThisSubroutine SubRoutineHistory

Line       = arg(1) /* Logical line number.                */
posCALL    = arg(2) /* Character number where CALL starts. */
data1      = arg(3) /* without comments.                   */
data2      = arg(4) /* without comments and literals.      */ 
CurRoutine = arg(5)

if posCall = 1 then 
   v = ''
else
   v =substr(data1,posCALL-1,1) /* Get character in front of CALL. */

/* Two tests to make sure this is a CALL instruction. */
if datatype(v,'A') then do
   /* This is not a call. */
   parse var SubRoutineHistory . SubRoutineHistory
   return 2
   end

if v=' ' | v='' then do
   /* This is a call. */
   /* say 'CALL instruction in line 'Line */
   end
else do
   parse var SubRoutineHistory . SubRoutineHistory
   return 2
   end
   
string = substr(data2,posCALL+5)
if left(string,1) = '(' then do
   /* say 'A CALL to a variable routine was found on line 'line */

   /* Find closing right parenthesis */
   rc = FindParentheses(string)
   if rc \= 1 then do
      parse var SubRoutineHistory . SubRoutineHistory
      return 0
      end
   ClosPar = EndOParen+posCALL+4

   k = FRef.line.0 /* Number of function references in this line. */
   k = k+1
   FRef.line.0 = k
   /* character positions of start and stop of function name, the function   */
   /* name, the type of function, and the character positions of the left and*/
   /* right parentheses.                                                     */
            
   FRef.line._Str.k   = posCALL+5 
   FRef.line._End.k   = ClosPar
   FRef.line._Txt.k   = substr(string,2,EndOParen-StrOParen-1)
   FRef.line._Typ.k   = '"Variable CALL"'
   FRef.line._Open.k  = posCALL+5
   FRef.line._Close.k = ClosPar
   FRef.line._Knd.k   = "Var_CALL"

   parse var SubRoutineHistory . SubRoutineHistory
   return 3
   end /* if left(string,1) = '(' then ... */
      
/* Get string after CALL and determine what routine is being referenced*/
string    = substr(data1,posCALL+5)
/* The parse is set up for future use when handling signal control.    */
/*               ON ANY NAME TRAPNAME */
parse var string v1 v2    v3   v4    .
v1U = translate(v1)
select
   when v1U = 'ON' then do
      rc = SignalAnalysis('CALL',Line,posCALL,data1,data2,CurRoutine)
      if rc \= 1 then do
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end
      end /* when v1U = 'ON' then ... */
   when v1U = 'OFF' then
      nop
   otherwise do
      /* To get here we know we do have a CALL and it is not have a SIGNAL.  */

      /* if Line > 24 then do ;  say line data1 ; trace ?i ; end */
      
      /* Get first character to left of possible function name. */
      LitString =left(v1,1)
      if LitString = '"' | LitString = "'" then do
         /* This is a "quoted" reference to a function name.                    */
         /* This logic also used in FunctionAnalysis().  See for more comments. */
         do j = 1 to Literal.line.0 
            if Literal.line._Str.j = posCALL+5 then do
               Fname = LitString||Literal.line._Txt.j||LitString
               StrFname = Literal.line._Str.j
               EndFname = Literal.line._End.j
               Ref_Type = "Lit_CALL"
               end
            end j
         end /* if LitString = '"' | LitString = "'" then ... */

      else do /* start else do #1 */

/*
         /* If the positions are moved then the line has to be re analyzed.  */
         /* The following is not complete logic!!!                           */
         string = change(string,',',' , ') /* insert spaces around any commas*/
         rc = MapNMaskCommentsNLiterals('1Line_C','MAP',linenumber)
         if rc \= 1 then do
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end
         rc = MapNMaskCommentsNLiterals('1Line_L','MAP',linenumber)
         if rc \= 1 then do
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end
*/         


         /* August 27, 2003  DLR                                             */
         /* This code needs to handle something like:                        */
         /* CALL Fname, arg , arg,Fname(arg) arg, arg 'string',arg           */
         /* All is currently handles is basically                            */
         /*    CALL Fname(parameter) | CALL Fname parameter                  */
         /* Not good enough.  The logic in FunctionAnalysis( ) is much more  */
         /* robust and something like it needs to be implemented here.       */
         
         /* Look for the start and stop of the function name. */
         Fname = v1
         cpar  = pos(',',Fname)
         ppar  = pos('(',Fname)
         select
            when ppar>0 & (ppar<cpar | cpar=0) then do
               /* Must handle syntax of the form "CALL Fname(parameter)"      */
               Fname = translate(Fname,' ','(')
               parse var Fname Fname v2
               /* Get rid of trailing blanks, which may be hidden comments.   */
               open  = posCall+5 + length(Fname)
               close = open + length(strip(v2,'T'))         
               end
            when cpar > 0 then do
               Fname = overlay(' ',Fname,cpar,1,) /* Drop the offending comma.        */
               parse var Fname Fname v1
               parse var string . v2
               v2 = v1 || v2               
               open  = posCall+5 + length(Fname) + 1
               close = open + length(strip(v2,'T')) -1
               end
               
            otherwise do /* start else do #2 */
               /* Syntax of the form "CALL Fname parameter"                   */
               parse var string . v2
               /* Get rid of trailing blanks, which may be hidden comments.   */
               open  = posCall+5 + length(Fname) + 1
               close = open + length(strip(v2,'T')) -1
               end /* otherwise do ... */
            end /* select */
         
         StrFname = posCALL+5
         EndFname = posCALL+5 + length(Fname)-1
         Ref_Type = "CALL"
         end /* else do #1 */

      rc = MatchSubroutine(line,Fname)
      if rc \= 1 then do
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end
            
      k = FRef.line.0 /* Number of function references in this line. */
      k = k+1
      FRef.line.0 = k
      /* character positions of start and stop of function name, the function   */
      /* name, the type of function, and the character positions of the left and*/
      /* right parentheses.                                                     */
           
      FRef.line._Str.k   = StrFname
      FRef.line._End.k   = EndFname
      FRef.line._Txt.k   = Fname
      FRef.line._Typ.k   = TypFname
      FRef.line._Open.k  = open 
      FRef.line._Close.k = close
      FRef.line._Knd.k   = Ref_Type
            
      if FRef.line._Close.k < FRef.line._Open.k then
         /* This happens when there are no arguments. */
         FRef.line._Close.k = FRef.line._Open.k

      if FRef.line._Typ.k = '"Internal"' then do
         /* say 'In 'CurRoutine FRef.line._Txt.k */
         v = '_'CurRoutine'._'FRef.line._Txt.k
         /* say 'In2 'ThisSubroutine": |"v"|" */
         SRMap.v = 1
         end


      end /* otherwise do ... */
   end /* select */

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FindCallInstructions:                 -------------*/
/* --------------------------------------------------------------------------*/



FindCalls2Subroutines: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FindCalls2Subroutines:                -------------*/
/* Find all usages of the internal, builtin and external subroutines and     */
/* functions.                                                                */
procedure expose (DefaultExposeList)                          ,
                 LogicalLineI.  LogicalLine1.    LogicalLine2.,
                 Label.         Literal.         FRef.        ,
                 Comment.       SRMap.
ThisSubroutine    = 'FindCalls2Subroutines'
SubRoutineHistory = ThisSubroutine SubRoutineHistory

/* Look for usages of the form " SubroutineLabel(" and "CALL Subroutine "    */

CurRoutine    = 'TheProgramBegan'  /* Initialize name of current subroutine. */
k             = 1                 /* Current subroutine counter.             */
SignalFlag    = 0                 /* Number of SIGNALs. Control printing.    */

parse var Label.k StrLSub Type NextRoutine 
                               /* StrLSub - Starting line of next subroutine.*/
                               
do i = 1 to LogicalLine1.0
   
   FRef.i.0 = 0

   if i = StrLSub then do j = 1
      /* Update name of current subroutine. */
      CurRoutine = NextRoutine
      k = k+1
      parse var Label.k StrLSub Type NextRoutine
      if k >= Label.0 then            /* The last subroutine.                */
         StrLSub = LogicalLine1.0 + 1 /* Can't get here, but it is a number. */
      if i = 1 then 
         leave j    /* This happens when there is no comment on first line.  */
      iterate i
      end j

   data = LogicalLine2.i
   if strip(data) = '' then /* A blank line. */
      iterate i

   /* Is there a reference to a subroutine in this line?  CALLs must be      */
   /* handled first because clauses of the form "CALL (variable)", which     */
   /* confuse the search for references of the form rc=function(arg).        */

   data = translate(LogicalLine2.i)

   posCALL = pos('CALL ',data)
   if posCALL\=0 then do
      rc = FindCallInstructions(i,posCALL,LogicalLine1.i,LogicalLine2.i,CurRoutine)
      select
         when rc = 1 then /* Normal return.                          */
            nop
         when rc = 2 then /* this was not a CALL instruction.        */
            nop
         when rc = 3 then /* A call to a variable routine was found. */
            nop
         when rc = 0 then do 
            say 'In FindCalls2Subroutines() the call to FindCallInstructions()'
            say 'returned with error code 0.'
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end

         otherwise do
            say 'In FindCalls2Subroutines() the call to FindCallInstructions()'
            say 'returned an unknown error code.  rc='rc
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end
         end /* select */
      end

   posSIGNAL = pos('SIGNAL ',data)
   if posSIGNAL\=0 then do
      rc = SignalAnalysis('SIGNAL',i,posSIGNAL,LogicalLine1.i,LogicalLine2.i,CurRoutine)
      select
         when rc = 1 then /* Normal return.                          */
            nop
         when rc = 2 then /* this was not a SIGNAL instruction.      */
            nop
         when rc = 3 then /* A call to a variable routine was found. */
            nop
         when rc = 0 then do 
            say 'In FindCalls2Subroutines() the call to SignalAnalysis()'
            say 'returned with error code 0.'
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end

         otherwise do
            say 'In FindCalls2Subroutines() the call to SignalAnalysis()'
            say 'returned an unknown error code.  rc='rc
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end
         end /* select */
      end

   /* Now find functions. */

   /* This logic does not handle a comment between the function_name and the */
   /* opening parenthesis.  To do so reference Comment.i._Str. and            */
   /* Comment.i._End. and see if one of the comments fills the space.         */

   posLPar = pos('(',LogicalLine2.i)
   if posLPar>0 then do
      /* A left paranthesis exists after stripping comments and literals.    */
      tableOut = '           '
      tableIn  = ',(|=></%*+-'
      string = translate(LogicalLine1.i,tableOut,tableIn)
      if substr(string,posLPar-1,1) \= ' ' then do
         /* A function may exist. */
         rc = FunctionAnalysis(i,posLPar,tableOut,tableIn)
         if rc \= 1 then do
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end
         do j = 1 to FRef.i.0
            if FRef.i._Typ.j = '"Internal"' then do
               /* say 'In 'CurRoutine FRef.i._Txt.j */
               v = '_'CurRoutine'._'FRef.i._Txt.j
               /* say 'In1 'ThisSubroutine": "i j "|"CurRoutine"|" "|"FRef.i._Txt.j"|" "|"v"|" */
               SRMap.v = 1
               end
            end j
         end
      end

   end i

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FindCalls2Subroutines:                -------------*/
/* --------------------------------------------------------------------------*/


FindDirectives: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FindDirectives:                       -------------*/
/* To get here we know we have no semicolons.                                */
/* Directive. contains the line number and the text of the directive.        */
/* Returns: 0 - "::" not at start of clause.                                 */
/*          1 - No directive.                                                */
/*          2 - Directive                                                    */
procedure expose (DefaultExposeList) Directive.
SubRoutineHistory = 'FindDirectives' SubRoutineHistory

string1 = arg(1)
string2 = arg(2)
line    = arg(3)

string1   = strip(string1)
posDColon = pos('::',string1)
if posDColon>1 then do
   say 'In line 'SourceIndex.line': |'string2'|' 
   say 'A double colon "::" was found, but it is not at the start of a clause!'
   say 'I don''t know what to do with this, so I quit.'
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end

if posDColon=1 then do
   /* A directive has been found. */
   lDirective = length(string2)
   Directive = right(string2,lDirective-2)
   say 'Directive in line' SourceIndex.line':' Directive
   k = Directive.0 + 1
   Directive.0 = k
   Directive.k = line Directive
   parse var SubRoutineHistory . SubRoutineHistory
   return 2
   end

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FindDirectives:                       -------------*/
/* --------------------------------------------------------------------------*/


FindLabels: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FindLabels:                           -------------*/
/* To get here we know we have no semicolons and no double colons.           */
/* Line number, type of label (string or symbol), and label string are       */
/* returned in "Label."                                                      */
/*                                                                           */
/*    Label.i         = Line# || Type ("STRING"|"SYMBOL") || FunctionName    */
/*                                                                           */
/* In FindLabelsNDirectives() a check is made for duplicate labels.  The     */
/* resulting information is stored in Label._Duplicate.i                     */
procedure expose (DefaultExposeList) Label.
SubRoutineHistory = 'FindLabels' SubRoutineHistory

string1 = arg(1)
string2 = arg(2)
line    = arg(3)

k = Label.0

/* To get here one or more single colons must exist in the string.*/
nColon  = countstr(':',string1)

do i = 1 to nColon
   k = k+1
   posColon = pos(':',string1)
   parse var string1 .     =(posColon) string1
   parse var string2 LabelI =(posColon) string2
   LabelI = strip(LabelI)
   Label = strip(LabelI,'B,','"')
   Label = strip(Label,'B,',"'")
   l1    = length(LabelI)
   l2    = length(Label)
   if l1\=l2  & Label\=translate(Label) then do
      /* If it is in quotes and is not all uppercase store as type=STRING.   */
      LabelType = 'STRING'
      end
   else do
      LabelType = 'SYMBOL'
      Label = translate(Label)
      end

   Label.k = line LabelType Label
   /* say "In FindLabels "label.k */
   end i

Label.0 = k

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FindLabels:                           -------------*/
/* --------------------------------------------------------------------------*/


FindLabelsNDirectives: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FindLabelsNDirectives:                -------------*/
/* Find all labels and Directives.                                           */
/* Mark all duplicate labels in Label._Duplicate.i                           */
procedure expose (DefaultExposeList)                          ,
                 LogicalLineI.  LogicalLine1.    LogicalLine2.,
                 Label.         Directive.
SubRoutineHistory = 'FindLabelsNDirectives' SubRoutineHistory

Label.0     = 1
Directive.0 = 0

/* Provide a default name for the opening portion of a program.*/
Label.1 = 1 "SYMBOL" 'ProgramBegan' 


do i = 1 to LogicalLineI.0
   posColon = pos(':',LogicalLine2.i)
   if posColon=0 then /* Most lines have no colon. */
      iterate i

   /* To get here there has to be a colon. */
   
   /* To handle string labels we now have to work with LogicalLine1.i          */
   rc = FindDirectives(LogicalLine2.i,LogicalLine1.i,i)
   select
      when rc = 0 then do
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end
      when rc = 2 then 
         nop
      when rc = 1 then do
         /* This must be a label. */
         rc = FindLabels(LogicalLine2.i,LogicalLine1.i,i)
         if rc \= 1 then do
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end
         end
      otherwise do
         say 'Something is wrong.  I should never have gotten here in FindSubroutines().'
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end
      end /* select */

   end i

/* do i = 1 to Label.0 ; say 'Label 'i'  'label.i ; end i */

/* Check for existance of duplicate labels. */
MaxL=0
do i = 1 to Label.0
   parse var Label.i Line Type FunctionName1
   MaxL = max(MaxL,length(FunctionName1))
   Label._Duplicate.i = 0
   /* say right(i,3) right(SourceIndex.Line,5,'0') Type FunctionName1  */
   end i
Flag = 0

rc  = lineout(out,' ')
txt = 'Duplicate Labels on Lines:'
rc  = lineout(out,txt)

do i = 1 to Label.0-1
   parse var Label.i LineN1 Type FunctionName1
   FunctionName1 = strip(FunctionName1,,'"')
   FunctionName1 = strip(FunctionName1,,"'")
   if Type = 'STRING' then 
      nop
   else
      FunctionName1 = translate(FunctionName1)
   
   do j = i+1 to Label.0
      parse var Label.j LineN2 Type FunctionName2
      FunctionName2 = strip(FunctionName2,,'"')
      FunctionName2 = strip(FunctionName2,,"'")   
      if Type = 'STRING' then 
         nop
      else
         FunctionName2 = translate(FunctionName2)
      if FunctionName1 = FunctionName2 then do
         if Flag = 0 then do
            txt = ' Line   Line ' left('ROUTINE',MaxL)
            rc  = lineout(out,txt)
            end
         txt = right(SourceIndex.LineN1,6,'0') right(SourceIndex.LineN2,6,'0') left(FunctionName1,MaxL)
         rc  = lineout(out,txt)
         Flag = 1
         Label._Duplicate.j = 1
         end
      end j
   end i

if Flag = 0 then do
   txt = '   There are no duplicate labels.'
   rc  = lineout(out,txt)
   end

rc = stream(out,c,'close')

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FindLabelsNDirectives:                -------------*/
/* --------------------------------------------------------------------------*/


FindLiterals: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FindLiterals:                         -------------*/
/* Literals must occur on a single line and are defined by " " or ' '.       */
/* This subroutine does not break lines based on ';' as it is assumed the    */
/* program being analyzed works.                                             */
/* The starting character and the ending character for each literal string   */
/* in "data" is returned in StrLiteral. and EndLiteral.  The type of literal,*/
/* either single quote, "S", or double quote, "D", is in TypLiteral.         */
/*                                                                           */ 
/* At present this routine is more general than is needed.  For example it   */
/* finds all literals in a string although only the first is needed.  The    */
/* speed penalty is not enough to worry about and the functionality may be   */
/* useful in the future.                                                     */ 
procedure expose (DefaultExposeList)                            ,
                 StrLiteral. EndLiteral. TypLiteral. TxtLiteral.
SubRoutineHistory = 'FindLiterals' SubRoutineHistory

data   = arg(1)
StartI = arg(2) /* Starting character to look for quotes. */
mode   = arg(3)

if datatype(StartI,'N')\=1 then /* If start is not specified set to 1. */
   StartI = 1

/* Tabulate all single quotes.  Store in array "Quote." with "S". */
k = 0
Start = StartI
do i = 1
   pos = pos("'",data,Start)
   if pos = 0 then
      leave i
   k = k+1
   Quote.k = right(pos,6,'0') 'S'
   Start = pos + 1
   end i

/* Tabulate all double quotes.  Store in array "Quote." with "D". */
Start = StartI
do i = 1
   pos = pos('"',data,Start)
   if pos = 0 then
      leave i
   k = k+1
   Quote.k = right(pos,6,'0') 'D'
   Start = pos + 1
   end i

Quote.0 = k

if k=0 then do /* No literals defined. */
   StrLiteral.0 = 0
   parse var SubRoutineHistory . SubRoutineHistory
   return 1
   end

/* rc = arraysort(Quote, , , ,6, ,'N') */ /* REXXLIB version */
rc = SysStemSort(Quote.,  , , , , 1, 6 ) 

h = 1 /* Quote.   index */
k = 0 /* Literal. index */
do i = 1 /* Find range of each literal. */
   parse var Quote.h Char StrType
   k=k+1
   StrLiteral.k = strip(Char,'L','0')
   TypLiteral.k = StrType
   h = h+1
   do j = h to Quote.0
      parse var Quote.j Char Type
      if Type = StrType then do /* The end of a literal. */
         EndLiteral.k = strip(Char,'L','0')
         TxtLiteral.k = substr(data,StrLiteral.k+1,EndLiteral.k-StrLiteral.k-1)
         h = h+1
         if h>Quote.0 then
            leave i
         iterate i
         end
      h = h+1
      end j
   /* A apostrophe or single quote in a comment can legally happen, so skip  */
   /* it.  Otherwise there is a problem.                                     */
   if mode\='RAW_C' & mode\='LOGICAL_C' then do
      say 'I should never get here! In FindLiterals()'
      say 'data: ' data
      parse var SubRoutineHistory . SubRoutineHistory
      return 1
      end
   leave i
   end i

StrLiteral.0 = k
EndLiteral.0 = k
TypLiteral.0 = k
TxtLiteral.0 = k

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FindLiterals:                         -------------*/
/* --------------------------------------------------------------------------*/


FindParentheses: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FindParentheses:                      -------------*/
/* In a string, "Data", find the character position of the right parenthesis */
/* that matches the first left parenthesis in the string.  Return the left   */
/* and right positions in "StrOParen" and "EndOParen".  Positions are        */
/* to the string which was passed as "data".                                 */
procedure expose (DefaultExposeList) StrOParen EndOParen
SubRoutineHistory = 'FindParentheses' SubRoutineHistory

data = arg(1)

/* Tabulate all left paren. Store in array "Paren." "L". */
k = 0
Start = 1
nLPar = countstr("(",data)
do i = 1 to nLPar
   pos = pos("(",data,Start)
   k = k+1
   Paren.k = right(pos,6,'0') '1'
   Start = pos + 1
   end i

/* Tabulate all right paren. Store in array "Paren." "-1". */
Start = 1
nRPar = countstr(')',data)
do i = 1 to nRPar
   pos = pos(')',data,Start)
   k = k+1
   Paren.k = right(pos,6,'0') '-1'
   Start = pos + 1
   end i

Paren.0 = k

if k=0 then do /* No parentheses defined. */
   LParen.0 = 0
   parse var SubRoutineHistory . SubRoutineHistory
   return 1
   end

/* rc = arraysort(Paren., , , ,6, ,'N') */ /* REXXLIB version */
rc = SysStemSort(Paren.,  , , , , 1, 6 ) 

/* do i = 1 to Paren.0 ; say Paren.i ; end i */

total=0
do i = 1 to Paren.0
   if total = 0 then 
      /* Start of a parenthesis block. */
      parse var Paren.i StrOParen v
   else 
      parse var Paren.i EndOParen v

   total = total + v
   if total = 0 then do 
      /* Parentheses closed */ 
      /* say StrOParen EndOParen */
      leave i
      end
   end i

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FindParentheses:                      -------------*/
/* --------------------------------------------------------------------------*/


FunctionAnalysis: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - FunctionAnalysis:                     -------------*/
/* Find function references on a single logical line.                        */
/*    FRef.i.0        = Number of functions referenced in line i.            */
/*    FRef.i._Str.k   = First character of kth function referenced in line i.*/
/*    FRef.i._End.k   = Last  character of kth function referenced in line i.*/
/*    FRef.i._Txt.k   = Text string (name) kth function referenced in line i.*/
/*    FRef.i._Typ.k   = Type of function,  kth function referenced in line i.*/
/*    FRef.i._Open.k  = Postion of "(" for kth function referenced in line i.*/
/*    FRef.i._Close.k = Postion of ")" for kth function referenced in line i.*/
/*    FRef.i._Knd.k   = Nature of reference, subroutine call or function.    */
/* Note - Positions are relative to the first non-blank character in the line*/
procedure expose (DefaultExposeList)                          ,
                 LogicalLineI.  LogicalLine1.    LogicalLine2.,
                 Literal.       FRef.            Label. 

ThisSubroutine    = 'FunctionAnalysis'
SubRoutineHistory = ThisSubroutine SubRoutineHistory

line     = arg(1)
posLPar  = arg(2)
tableOut = arg(3) /* All blanks     */
tableIn  = arg(4) /* ',(|=></%*+-'  */

nLPar = countstr('(',LogicalLine2.line)
Start = 1

/* Redo the translate for now.  I may want to do something different later.  */
data   = translate(LogicalLine1.line,tableOut,tableIn)

do i = 1 to nLPar

   /* Need to increment through all left paren. */

   posLPar = pos('(',LogicalLine1.line,Start)

   /* Get first character to left of "(" being tested. */
   LitString =substr(data,posLPar-1,1)

   if LitString = ' ' then /* This is not a reference to a function. */
      iterate i

   if LitString = '"' | LitString = "'" then do
      /* This is a "quoted" reference to a function name. Find the stored    */
      /* literal.  Doing it this way means I can use the already known end   */
      /* of the literal and, in the future, if the stored literal has been   */
      /* edited it will replace the value in the line with a corrected value.*/
      /* This logic also used in FindCallInstructions( ).                    */
      do j = 1 to Literal.line.0 
         if Literal.line._End.j = posLPar-1 then do
            /* say 'Function call,"'Literal.line._txt.j'", to builtin or external in source line 'SourceIndex.Line */
            /* Literal string start, stop, type and text */
            /* say Literal.line._Str.j Literal.line._End.j Literal.line._Typ.j Literal.line._txt.j */
            Fname = LitString||Literal.line._txt.j||LitString
            StrFname = Literal.line._Str.j
            EndFname = Literal.line._End.j
            Ref_Type = "Lit_FUNC"
            end
         end j
      end

   else do
      /* Now find the character string preceding the left paranthesis.          */
      /* Find first blank in the edited string preceeding the left paranthesis. */
      /* First remove any remaining " and '.                                    */
      string = translate(data,'  ','"'"'")
      parse var string string =(posLPar) .
      /* parse var data string =(posLPar) .  */
      gnirts   = reverse(string)
      parse var gnirts emanF .
      Fname    = reverse(emanF)

      if translate(Fname) = 'IF' then do
         /* Ignore things of the form if(a<b) then do ... */
         Start = posLPar+1
         iterate i
         end

      lFname   = length(Fname)
      StrFname = posLPar-lFname

      k = FRef.line.0      
      if FRef.line._Str.k = StrFname then do
         /* This is a call in the form "CALL Fname(parameter)" */
         Start = posLPar+1
         iterate i
         end
      
      EndFname = posLPar-1
      Ref_Type = "FUNCTION" 
      end /* else do ... */

   OpenPar  = posLPar

   rc = MatchSubroutine(line,Fname)
   if rc \= 1 then do
      parse var SubRoutineHistory . SubRoutineHistory
      return 0
      end
   TxtFname = Fname

   /* Find closing right parenthesis */
   parse var LogicalLine1.line . =(posLPar) string
   rc = FindParentheses(string)
   if rc \= 1 then do
      parse var SubRoutineHistory . SubRoutineHistory
      return 0
      end
   ClosPar = EndOParen+posLPar-1
   if ClosPar < OpenPar then /* This happens when there are no arguments */
      ClosPar = OpenPar + 1

   /*   
   say 'Reference to 'TypFname' function, "'TxtFname'", in source line 'SourceIndex.Line
   say 'Open paren at 'OpenPar' and close paren at 'ClosPar
   */

   k = FRef.line.0 /* Number of function references in this line. */
   k = k+1
   FRef.line.0 = k
   /* character positions of start and stop of function name, the function   */
   /* name, the type of function, and the character positions of the left and*/
   /* right parentheses.                                                     */
   FRef.line._Str.k   = StrFname 
   FRef.line._End.k   = EndFname
   FRef.line._Txt.k   = TxtFname
   FRef.line._Typ.k   = TypFname
   FRef.line._Open.k  = OpenPar 
   FRef.line._Close.k = ClosPar
   FRef.line._Knd.k   = Ref_Type

   /* if FRef.line._Typ.k = '"Internal"' then say SourceIndex.line TxtFname  */

   Start = posLPar+1
   end i

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - FunctionAnalysis:                     -------------*/
/* --------------------------------------------------------------------------*/


GenericError: 
/* --- begin subroutine - GenericError:                         -------------*/
/* A generic error handler.  The user will get information about the error   */
/* and processing will continue.  Hopefully the calling routine will be able */
/* to handle the fact something is messed up.                                */
/*                                                                           */
/* This routine is designed to be used within a generic REXX program or in a */
/* VisProRexx program.  It will handle VisProRexx routines when executed in  */
/* testing mode, i.e. when doing a "CNTRL-R" while editing a VisProRexx      */
/* program, and when running a VisProRexx .exe.                              */
/*                                                                           */
/* What will happen depends on two things.                                   */
/*   1. If this is not running inside a VisProRexx program the SAY           */
/*      instruction is used.                                                 */
/*   2. If run inside a VisProRexx program the variable "GenericErrorQUIET"  */
/*      is checked.  It can have the following values:                       */
/*      'YES'    - Output to the user is suppressed.                         */
/*      'NO'     - Same a blank, user receives a warning dialog box.  The    */
/*                 dialog gives the user the option of dumping all of the    */
/*                 program's variables to a file called "VariableDump" in    */
/*                 current directory.                                        */
/*      'DECODE' - In addition to the dialog box given for "NO", the code in */
/*                 program which generated an error is broken into pieces    */
/*                 and the values of the variables within it are given in a  */
/*                 VIO window. This can be very, very useful!                */
/*                                                                           */
/* Returns:                                                                  */
/*    The condition and line number.                                         */
/* The general form of the return is:                                        */
/*    condition('c') 'Error:' SourceLineN_generating_error                   */
/* Example: SYNTAX Error: 3023                                               */
/*                                                                           */
/* If a variable called "SubRoutineHistory" is used GenericError will        */
/* display this variable's contents.  This variable should contain a record  */
/* of each subroutine that has been entered and not exited.  In other words  */
/* it is modified by each subroutine and is a record of which subroutines    */
/* were called and the order.  GenericError will remove the last entry in the*/
/* variable before it returns. If "SubRoutineHistory" has not been set or it */
/* equals 'Unknown' then it will be dropped before GenericError returns.     */
/*                                                                           */
/* With four exceptions variables used internal to this routine start with   */
/* the string "GenericError."  Example:  "GenericError.1SourceLineN"         */
/* Note that tails of "GenericError." all start with the character "1".      */
/* These are all dropped before the routine returns.                         */
/*    Exception 1: the variable "RC".  I figured this one was surely safe.   */
/*    Exception 2: "GenericErrorQUIET".                                      */
/*    Exception 3: "SubRoutineHistory".                                      */
/*    Exception 4: The loop counters "GenericError_i" and "GenericError_j".  */
/*                                                                           */
/* Programmer's notes:                                                       */
/* I created this because I've a large suite of binary files which I must    */
/* read and decipher.  The files are buggy and trying to handle all possible */
/* syntax errors was too difficult.  Therefore a graceful syntax handler was */
/* needed.  I realized that what I created was not specific to syntax and    */
/* could be used generically if desired.                                     */
/*                                                                           */
/* SEE THE NOTE AT THE END OF THIS SUBROUTINE IF USING VISPROREXX!           */
/*                                                                           */
/* Doug Rickman May 8, 2000, mod. May 16,2000, May 23, 2000, July 13, 2000   */
/* Feb. 13, 2001; Aug 29, 2001; Aug 1, 2002; Aug 28, 2003                    */

GenericError.1SourceLineN     = SIGL
GenericError.1ReturnErrorCode = RC

/* Default values.  These will be changed if program is not VisProREXX code. */
GenericError.1VisProRexx = 'YES'
GenericError.1Offset     = 2
GenericError.1LineFeed   = '0a'x           /* Some systems may need '0d0a'x  */

parse source . . GenericError.1Source

/* get drive, path, filename and extension using RexxUtil. */
GenericError.1drive     = filespec('Drive',GenericError.1Source)
GenericError.1path      = filespec('Path',GenericError.1Source)
GenericError.1exe       = filespec('Name',GenericError.1Source)
last                    = lastpos('.',GenericError.1exe)
parse var GenericError.1exe GenericError.1exe =(last) GenericError.1extension
GenericError.1extension = strip(GenericError.1extension,'L','.')
       
/* Read the source file into memory. */
GenericError.1Size=stream(GenericError.1Source,'c','query size')
GenericError.1rc  =stream(GenericError.1Source,'c','open read')
GenericError.1Data=charin(GenericError.1Source,,GenericError.1Size)
GenericError.1rc  =stream(GenericError.1Source,'c','close')

/* Find where to start.  A VisProRexx program adds complication.             */
/* We are looking for a string VisPro uses at the start of a program.  But   */
/* we have to dodge the fact that the same string is in the comment block at */
/* the end of this subroutine.                                               */

GenericError.1Start  = pos('_VPAppHandle = VpInit()'  ,GenericError.1Data)
GenericError.1Startb = pos("'_VPAppHandle = VpInit()'",GenericError.1Data)
if GenericError.1Startb = GenericError.1Start-1 then do
   GenericError.1VisProRexx = 'NO'
   GenericError.1start      = 1
   GenericError.1Offset     = 0
   GenericError.1LineFeed   = '0d0a'x
   end
parse var GenericError.1Data . =(GenericError.1Start) GenericError.1Data

/* Now get the offending line of code. */
GenericError.1v = strip(sourceline(GenericError.1SourceLineN))


/* The chain of subroutines, i.e. the history used to get to the problem were*/
/* stored in "SubroutineHistory".   If the variable is not set create a      */
/* default.                                                                  */
if SubroutineHistory = 'SUBROUTINEHISTORY' then SubroutineHistory = 'Unknown'

/* Reformat the subroutine history to make it easier to read when printed.   */
GenericError.n = words(SubroutineHistory)
do GenericError_i = 1 to GenericError.n
   parse var SubroutineHistory GenericError.v.GenericError_i SubroutineHistory
   end GenericError_i
GenericError.pad = ''
do GenericError_i = 1 to GenericError.n
   SubroutineHistory = SubroutineHistory ||,
       right(GenericError.pad,3*(GenericError.n+1-GenericError_i))||,
       GenericError.v.GenericError_i'()'||,
       GenericError.1LineFeed
   end GenericError_i


/* Get then message for this error code. */
select
   when GenericError.1ReturnErrorCode='RC' then do 
      GenericError.1rc=' '
      GenericError.1mesg=' '
      end
   
   /* If there is special handling for certain error codes, insert them here.*/
      
   otherwise GenericError.1mesg=sysgetmessage(GenericError.1ReturnErrorCode)
   end /* select */


if GenericErrorQUIET = 'DECODE' then do
   say
   say '-   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -'
   say 'Analysis of the code:' GenericError.1v
   
   /* Parse the source line into variables and literals.  Then SAY the value */
   /* of all variables and literals.                                         */
   GenericError.1temp = GenericError.1v

   /* First get rid of literal text strings. */
   do GenericError_i= 1
      GenericError.1StartPos = pos("'",GenericError.1temp)
      GenericError.1EndPos   = pos("'",GenericError.1temp,GenericError.1StartPos+1)
      if GenericError.1StartPos > 0 & GenericError.1EndPos > 0  then
         GenericError.1temp = overlay(' ',GenericError.1temp,GenericError.1StartPos,GenericError.1EndPos-GenericError.1StartPos+1)
      else 
         leave GenericError_i
      end GenericError_i
   do GenericError_i= 1
      GenericError.1StartPos = pos('"',GenericError.1temp)
      GenericError.1EndPos   = pos('"',GenericError.1temp,GenericError.1StartPos+1)
      if GenericError.1StartPos > 0 & GenericError.1EndPos > 0  then
         GenericError.1temp = overlay(' ',GenericError.1temp,GenericError.1StartPos,GenericError.1EndPos-GenericError.1StartPos+1)
      else 
         leave GenericError_i
      end GenericError_i
   
   GenericError.1temp = translate(GenericError.1temp,'         ','/*+-,()=|')
   GenericError.1temp = strip(space(GenericError.1temp))

   do GenericError_i= 1 to words(GenericError.1temp)
      GenericError.1t1 = word(GenericError.1temp,GenericError_i)
      if translate(GenericError.1t1) = 'IF'        |,
         translate(GenericError.1t1) = 'WHEN'      |,
         translate(GenericError.1t1) = 'SELECT'    |,
         translate(GenericError.1t1) = 'DO'        |,
         translate(GenericError.1t1) = 'TO'        |,
         translate(GenericError.1t1) = 'ELSE'      |,
         translate(GenericError.1t1) = 'INTERPRET' |,
         translate(GenericError.1t1) = 'OTHERWISE' |,
         translate(GenericError.1t1) = 'END'       |,
         translate(GenericError.1t1) = 'ITERATE'   |,
         translate(GenericError.1t1) = 'LEAVE'     |,
         translate(GenericError.1t1) = 'PARSE'     |,      
         translate(GenericError.1t1) = 'SAY'       |,
         translate(GenericError.1t1) = 'CALL'      |,
         translate(GenericError.1t1) = 'DATATYPE'  |,
         translate(GenericError.1t1) = 'FORMAT'    |,
         translate(GenericError.1t1) = 'STRIP'     |,
         translate(GenericError.1t1) = 'RETURN'    |,
         datatype(GenericError.1t1,'N')             then
         iterate GenericError_i
      GenericError.1t2 = symbol(GenericError.1t1)

      select 
         when GenericError.1t2 = 'VAR' then
            say 'VAR "'GenericError.1t1'" =' value(GenericError.1t1)
         when GenericError.1t2 = 'LIT' then
            say 'LIT "'GenericError.1t1'" =' value(GenericError.1t1)
         otherwise nop
         end /* end select */

      if pos('.',GenericError.1t1) >0 then do GenericError_j = 1
         parse var GenericError.1t1 GenericError.1t2 '.' GenericError.1t1
         GenericError.1t3 = symbol(GenericError.1t2)
         select
            when datatype((GenericError.1t2),'N') then
               nop
            when GenericError.1t3 = 'VAR' then
               say 'VAR "'GenericError.1t2'" =' value(GenericError.1t2)
            when GenericError.1t3 = 'LIT' then
               say 'LIT "'GenericError.1t2'" =' value(GenericError.1t2)
            otherwise
               nop
            end /* end select */   
         if length(GenericError.1t1) = 0 then
            leave GenericError_j
         end GenericError_j /* if pos(... */
      end GenericError_i

   say '-   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -'
   say
   end /* if GenericErrorQUIET = 'DECODE' ... */

/* Build the text of the error message. */
GenericError.1L.1  = 'A serious REXX ERROR has occurred!  I do not know what.'          GenericError.1LineFeed
GenericError.1L.2  =                                                                    GenericError.1LineFeed
GenericError.1L.3  = "Other information for a programmer's use:"                        GenericError.1LineFeed
GenericError.1L.4  = 'The line that generated this error is:' GenericError.1SourceLineN GenericError.1LineFeed
GenericError.1L.5  = '"' GenericError.1v '"'                                            GenericError.1LineFeed

GenericError.1L.6  =                                                                    GenericError.1LineFeed
GenericError.1L.7  = 'Subroutine history to point of failure, most recent first:'       GenericError.1LineFeed
GenericError.1L.8  = SubroutineHistory                                                  GenericError.1LineFeed
GenericError.1L.9  =                                                                    GenericError.1LineFeed
GenericError.1L.10 = 'Condition:'  condition('c')                                       GenericError.1LineFeed

GenericError.1L.11 = 'Instruction:' condition('i')                                      GenericError.1LineFeed
GenericError.1L.12 = 'Description:' condition('d')                                      GenericError.1LineFeed
GenericError.1L.13 = 'Status:' condition('s')                                           GenericError.1LineFeed
GenericError.1L.14 = 'RC: 'GenericError.1ReturnErrorCode  GenericError.1mesg            GenericError.1LineFeed
GenericError.1L.15 =                                                                    GenericError.1LineFeed

GenericError.1L.16 = 'Good luck!'

GenericError.1L.0=16

GenericError.1message = ''
do GenericError_i = 1 to GenericError.1L.0
   GenericError.1message = GenericError.1message GenericError.1L.GenericError_i
   end GenericError_i

/* Now output as directed. */
select /* Options are Quiet, VisPro, Say */
   when GenericErrorQUIET = 'YES' then nop
   when GenericError.1VisProRexx = 'YES' then do
      txt1 = 'Oops! Oh now what is the problem! Do you want the variables saved?  '
      txt2 = GenericError.1message GenericError.1LineFeed GenericError.1LineFeed,
             'Selecting "YES" will cause all variables in scope to be appended to the',
             'file 'VariableDump' in the current directory.'
      response=VpMessageBox(window,Txt1,Txt2,'YESNO')
      select
         when response = 'YES' then do
            /* rc = vardump('VariableDump','E','GENERICERROR.','TXT2') */
            rc = SysDumpVariables('VariableDump')
            rc = stream('VariableDump','c','close')
            end
         when response = 'NO'  then do
            end
         otherwise say 'Oh bother'
         end /* select */
      end

   otherwise say GenericError.1message
   end /* select */

rc = condition('c') 'Error:' GenericError.1SourceLineN

drop GenericError.   GenericError_LoopCounter GenericError_i GenericError_j
if SubroutineHistory = 'Unknown' then drop SubRoutineHistory

/* Remove record of subroutine whose crash got us here. */
parse var SubRoutineHistory . SubRoutineHistory

/* THIS NOTE MUST NOT BE MOVED TO HEAD OF SUBROUTINE.  IT CONTAINS A COPY OF */
/* THE KEY STRING USED TO RECOGNIZE A VISPROREXX PROGRAM.                    */
/*                                                                           */
/* GenericError searches the source for the string "_VPAppHandle = VpInit()" */
/* which normally denotes the start of a VisProREXX program.  If your code   */
/* also explicitly has this string and is not a VisProREXX program you will  */
/* want to add an additional check or modify GenericError().                 */
/*                                                                           */
/* --- end  subroutine - GenericError:                          -------------*/
/* --------------------------------------------------------------------------*/
return rc


LoadDefaultConditions: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - LoadDefaultConditions:                -------------*/
procedure expose (DefaultExposeList)

ThisSubroutine    = 'LoadDefaultConditions'
SubRoutineHistory = ThisSubroutine SubRoutineHistory

Conditions.1  = 'ANY'
Conditions.2  = 'ERROR' 
Conditions.3  = 'FAILURE' 
Conditions.4  = 'HALT' 
Conditions.5  = 'LOSTDIGITS' 
Conditions.6  = 'NOMETHOD' 
Conditions.7  = 'NOSTRING' 
Conditions.8  = 'NOTREADY' 
Conditions.9  = 'NOVALUE' 
Conditions.10 = 'SYNTAX' 
Conditions.11 = 'USER'
Conditions.0  = 11

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - LoadDefaultConditions:                -------------*/
/* --------------------------------------------------------------------------*/


LoadKnownFunctions: 
procedure expose Function. FunctionLib.

/* To add or eliminate a library edit the "FunctionLib." list, change        */
/* FunctionLib.0.  Any library not in "FunctionLib." will not be used in     */
/* the analysis of function references.                                      */ 
/* When adding a library BE SURE TO USE UPPER CASE!                          */
/*                                                                           */
/* Function Libraries (DLLs) currently recognized:                           */

FunctionLib.1 = '_BI' /* Builtin*/
FunctionLib.2 = '_REXXUTIL'
FunctionLib.3 = '_REXXLIB'
FunctionLib.4 = '_RXU'
FunctionLib.5 = '_FTP'
FunctionLib.6 = '_SOCK'
FunctionLib.7 = '_VPREXX'
FunctionLib.8 = '_RXGDUTIL'
FunctionLib.0 = 8

/* REXX Instructions and reserved words -                                    */
/* By Call Do Drop Else End Engineering Exit Expose For Forever If Interpret */
/* Iterate Leave Name Nop Numeric Off On Options Otherwise Parse Procedure   */
/* Pull Push Queue Return Say Scientific Select Signal Source Then To Until  */
/* Upper Var Version When While With                                         */

Function._FTP.FTPAPPEND                        = 1 
Function._FTP.FTPCHDIR                         = 1 
Function._FTP.FTPDELETE                        = 1 
Function._FTP.FTPDIR                           = 1 
Function._FTP.FTPDROPFUNCS                     = 1 
Function._FTP.FTPGET                           = 1 
Function._FTP.FTPLOADFUNCS                     = 1 
Function._FTP.FTPLOGOFF                        = 1 
Function._FTP.FTPLS                            = 1 
Function._FTP.FTPMKDIR                         = 1 
Function._FTP.FTPPING                          = 1 
Function._FTP.FTPPROXY                         = 1 
Function._FTP.FTPPUT                           = 1 
Function._FTP.FTPPUTUNIQUE                     = 1 
Function._FTP.FTPPWD                           = 1 
Function._FTP.FTPQUOTE                         = 1 
Function._FTP.FTPRENAME                        = 1 
Function._FTP.FTPRMDIR                         = 1 
Function._FTP.FTPSETACTIVEMODE                 = 1 
Function._FTP.FTPSETBINARY                     = 1 
Function._FTP.FTPSETUSER                       = 1 
Function._FTP.FTPSITE                          = 1 
Function._FTP.FTPSYS                           = 1 
Function._FTP.FTPVERSION                       = 1 
 
Function._SOCK.SOCKLOADFUNCS                   = 1 
Function._SOCK.SOCKDROPFUNCS                   = 1 
Function._SOCK.SOCKVERSION                     = 1 
Function._SOCK.SOCKBIND                        = 1 
Function._SOCK.SOCKCLOSE                       = 1 
Function._SOCK.SOCKCONNECT                     = 1 
Function._SOCK.SOCKGETHOSTBYADDR               = 1 
Function._SOCK.SOCKGETHOSTID                   = 1 
Function._SOCK.SOCKGETPEERNAME                 = 1 
Function._SOCK.SOCKGETSOCKNAME                 = 1 
Function._SOCK.SOCKGETSOCKOPT                  = 1 
Function._SOCK.SOCKINIT                        = 1 
Function._SOCK.SOCKLOCTL                       = 1 
Function._SOCK.SOCKLISTEN                      = 1 
Function._SOCK.SOCKPSOCK_ERRNO                 = 1 
Function._SOCK.SOCKRECV                        = 1 
Function._SOCK.SOCKRECVFROM                    = 1 
Function._SOCK.SOCKSELECT                      = 1 
Function._SOCK.SOCKSEND                        = 1 
Function._SOCK.SOCKSENDTO                      = 1 
Function._SOCK.SOCKSETSOCKOPT                  = 1 
Function._SOCK.SOCKSHUTDOWN                    = 1 
Function._SOCK.SOCKSOCK_ERRNO                  = 1 
Function._SOCK.SOCKSOCKET                      = 1 
Function._SOCK.SOCKSOCLOSE                     = 1 
 
Function._REXXUTIL.RXQUEUE                      = 1 
Function._REXXUTIL.RXMESSAGEBOX                 = 1 
Function._REXXUTIL.RXWINEXEC                    = 1  /* Non OS/2 */
Function._REXXUTIL.SYSADDFILEHANDLE             = 1 
Function._REXXUTIL.SYSADDREXXMACRO              = 1 
Function._REXXUTIL.SYSBOOTDRIVE                 = 1 
Function._REXXUTIL.SYSCLEARREXXMACROSPACE       = 1 
Function._REXXUTIL.SYSCLOSEEVENTSEM             = 1 
Function._REXXUTIL.SYSCLOSEMUTEXSEM             = 1 
Function._REXXUTIL.SYSCLS                       = 1 
Function._REXXUTIL.SYSCOPYOBJECT                = 1 
Function._REXXUTIL.SYSCREATEEVENTSEM            = 1 
Function._REXXUTIL.SYSCREATEMUTEXSEM            = 1 
Function._REXXUTIL.SYSCREATEOBJECT              = 1 
Function._REXXUTIL.SYSCREATESHADOW              = 1 
Function._REXXUTIL.SYSCURPOS                    = 1 
Function._REXXUTIL.SYSCURSTATE                  = 1 
Function._REXXUTIL.SYSDEREGISTEROBJECTCLASS     = 1 
Function._REXXUTIL.SYSDESTROYOBJECT             = 1 
Function._REXXUTIL.SYSDRIVEINFO                 = 1 
Function._REXXUTIL.SYSDRIVEMAP                  = 1 
Function._REXXUTIL.SYSDROPFUNCS                 = 1 
Function._REXXUTIL.SYSDROPREXXMACRO             = 1 
Function._REXXUTIL.SYSDUMPVARIABLES             = 1 
Function._REXXUTIL.SYSFILEDELETE                = 1 
Function._REXXUTIL.SYSELAPSEDTIME               = 1 
Function._REXXUTIL.SYSFILEDELETE                = 1 
Function._REXXUTIL.SYSFILESEARCH                = 1 
Function._REXXUTIL.SYSFILESYSTEMTYPE            = 1 
Function._REXXUTIL.SYSFILETREE                  = 1 
Function._REXXUTIL.SYSGETCOLLATE                = 1 
Function._REXXUTIL.SYSGETEA                     = 1 
Function._REXXUTIL.SYSGETKEY                    = 1 
Function._REXXUTIL.SYSGETMESSAGE                = 1 
Function._REXXUTIL.SYSINI                       = 1 
Function._REXXUTIL.SYSLOADFUNCS                 = 1 
Function._REXXUTIL.SYSLOADREXXMACROSPACE        = 1 
Function._REXXUTIL.SYSMAPCASE                   = 1 
Function._REXXUTIL.SYSMKDIR                     = 1 
Function._REXXUTIL.SYSMOVEOBJECT                = 1 
Function._REXXUTIL.SYSNATIONALLANGUAGECOMPARE   = 1 
Function._REXXUTIL.SYSOPENEVENTSEM              = 1 
Function._REXXUTIL.SYSOPENMUTEXSEM              = 1 
Function._REXXUTIL.SYSOPENOBJECT                = 1 
Function._REXXUTIL.SYSOS2VER                    = 1 
Function._REXXUTIL.SYSPOSTEVENTSEM              = 1 
Function._REXXUTIL.SYSPROCESSTYPE               = 1 
Function._REXXUTIL.SYSPUTEA                     = 1 
Function._REXXUTIL.SYSQUERYCLASSLIST            = 1 
Function._REXXUTIL.SYSQUERYEALIST               = 1 
Function._REXXUTIL.SYSQUERYPROCESSCODEPAGE      = 1 
Function._REXXUTIL.SYSQUERYREXXMACRO            = 1 
Function._REXXUTIL.SYSREGISTEROBJECTCLASS       = 1 
Function._REXXUTIL.SYSRELEASEMUTEXSEM           = 1 
Function._REXXUTIL.SYSREORDERREXXMACRO          = 1 
Function._REXXUTIL.SYSREQUESTMUTEXSEM           = 1 
Function._REXXUTIL.SYSRESETEVENTSEM             = 1 
Function._REXXUTIL.SYSRMDIR                     = 1 
Function._REXXUTIL.SYSSAVEOBJECT                = 1 
Function._REXXUTIL.SYSSAVEREXXMACROSPACE        = 1 
Function._REXXUTIL.SYSSEARCHPATH                = 1 
Function._REXXUTIL.SYSSETFILEHANDLE             = 1 
Function._REXXUTIL.SYSSETICON                   = 1 
Function._REXXUTIL.SYSSETOBJECTDATA             = 1 
Function._REXXUTIL.SYSSETPRIORITY               = 1 
Function._REXXUTIL.SYSSETPROCESSCODEPAGE        = 1 
Function._REXXUTIL.SYSSHUTDOWNSYSTEM            = 1 
Function._REXXUTIL.SYSSLEEP                     = 1 
Function._REXXUTIL.SYSSTEMSORT                  = 1 
Function._REXXUTIL.SYSSWITCHSCREEN              = 1  /* Non OS/2 */
Function._REXXUTIL.SYSSYSTEMDIRECTORY           = 1  /* Non OS/2 */
Function._REXXUTIL.SYSTEMPFILENAME              = 1 
Function._REXXUTIL.SYSTEXTSCREENREAD            = 1 
Function._REXXUTIL.SYSTEXTSCREENSIZE            = 1 
Function._REXXUTIL.SYSVOLUMELABEL               = 1 /* Non OS/2 */
Function._REXXUTIL.SYSWAITEVENTSEM              = 1 
Function._REXXUTIL.SYSWAITFORSHELL              = 1 
Function._REXXUTIL.SYSWAITNAMEDPIPE             = 1 
Function._REXXUTIL.SYSWILDCARD                  = 1 
Function._REXXUTIL.SYSWINVER                    = 1 /* Non OS/2 */
 
 
Function._BI.ABBREV                            = 1 
Function._BI.ABS                               = 1 
Function._BI.ADDRESS                           = 1 
Function._BI.ARG                               = 1 
Function._BI.BEEP                              = 1 
Function._BI.BITAND                            = 1 
Function._BI.BITOR                             = 1 
Function._BI.BITXOR                            = 1 
Function._BI.B2D                               = 1 
Function._BI.B2X                               = 1 
Function._BI.CENTER                            = 1 
Function._BI.CENTRE                            = 1 
Function._BI.CHANGESTR                         = 1 
Function._BI.CHARIN                            = 1 
Function._BI.CHAROUT                           = 1 
Function._BI.CHARS                             = 1 
Function._BI.COMPARE                           = 1 
Function._BI.CONDITION                         = 1 
Function._BI.COUNTSTR                          = 1 
Function._BI.COPIES                            = 1 
Function._BI.C2X                               = 1 
Function._BI.C2D                               = 1 
Function._BI.DATATYPE                          = 1 
Function._BI.DATE                              = 1 
Function._BI.DELSTR                            = 1 
Function._BI.DELWORD                           = 1 
Function._BI.DIGITS                            = 1 
Function._BI.DIRECTORY                         = 1 
Function._BI.D2B                               = 1 
Function._BI.D2C                               = 1 
Function._BI.D2X                               = 1 
Function._BI.ERRORTEXT                         = 1 
Function._BI.FILESPEC                          = 1 
Function._BI.FORM                              = 1 
Function._BI.FORMAT                            = 1 
Function._BI.FUZZ                              = 1 
Function._BI.INSERT                            = 1 
Function._BI.JUSTIFY                           = 1 
Function._BI.LASTPOS                           = 1 
Function._BI.LEFT                              = 1 
Function._BI.LENGTH                            = 1 
Function._BI.LINEIN                            = 1 
Function._BI.LINEOUT                           = 1 
Function._BI.LINES                             = 1 
Function._BI.MAX                               = 1 
Function._BI.MIN                               = 1 
Function._BI.OVERLAY                           = 1 
Function._BI.POS                               = 1 
Function._BI.QUALIFY                           = 1
Function._BI.QUEUED                            = 1 
Function._BI.RANDOM                            = 1 
Function._BI.REVERSE                           = 1 
Function._BI.RIGHT                             = 1 
Function._BI.RXFUNCADD                         = 1 
Function._BI.RXFUNCDROP                        = 1 
Function._BI.RXFUNCQUERY                       = 1 
Function._BI.SOURCELINE                        = 1 
Function._BI.SPACE                             = 1 
Function._BI.STREAM                            = 1 
Function._BI.STRIP                             = 1 
Function._BI.SUBSTR                            = 1 
Function._BI.SUBWORD                           = 1 
Function._BI.SYMBOL                            = 1 
Function._BI.TIME                              = 1 
Function._BI.TRACE                             = 1 
Function._BI.TRANSLATE                         = 1 
Function._BI.TRUNC                             = 1 
Function._BI.VALUE                             = 1 
Function._BI.VERIFY                            = 1 
Function._BI.WORD                              = 1 
Function._BI.WORDINDEX                         = 1 
Function._BI.WORDLENGTH                        = 1 
Function._BI.WORDPOS                           = 1 
Function._BI.WORDS                             = 1 
Function._BI.XRANGE                            = 1 
Function._BI.X2B                               = 1 
Function._BI.X2C                               = 1 
Function._BI.X2D                               = 1 

Function._REXXLIB.ACOS                         = 1
Function._REXXLIB.ARRAYCOPY                    = 1
Function._REXXLIB.ARRAYDELETE                  = 1
Function._REXXLIB.ARRAYINSERT                  = 1
Function._REXXLIB.ARRAYSEARCH                  = 1
Function._REXXLIB.ARRAYSORT                    = 1
Function._REXXLIB.ASIN                         = 1
Function._REXXLIB.ATAN                         = 1
Function._REXXLIB.ATAN2                        = 1
Function._REXXLIB.C2F                          = 1
Function._REXXLIB.CHARSIZE                     = 1
Function._REXXLIB.COS                          = 1
Function._REXXLIB.COSH                         = 1
Function._REXXLIB.CURSOR                       = 1
Function._REXXLIB.CURSORTYPE                   = 1
Function._REXXLIB.CVCOPY                       = 1
Function._REXXLIB.CVREAD                       = 1
Function._REXXLIB.CVSEARCH                     = 1
Function._REXXLIB.CVTAILS                      = 1
Function._REXXLIB.CVWRITE                      = 1
Function._REXXLIB.DATECONV                     = 1
Function._REXXLIB.DELAY                        = 1
Function._REXXLIB.DETAB                        = 1
Function._REXXLIB.DOSAPPTYPE                   = 1
Function._REXXLIB.DOSBOOTDRIVE                 = 1
Function._REXXLIB.DOSCD                        = 1
Function._REXXLIB.DOSCHDIR                     = 1
Function._REXXLIB.DOSCHMOD                     = 1
Function._REXXLIB.DOSCLOSE                     = 1
Function._REXXLIB.DOSCOMMANDFIND               = 1
Function._REXXLIB.DOSCOPY                      = 1
Function._REXXLIB.DOSCREAT                     = 1
Function._REXXLIB.DOSDEL                       = 1
Function._REXXLIB.DOSDIR                       = 1
Function._REXXLIB.DOSDIRCLOSE                  = 1
Function._REXXLIB.DOSDIRPOS                    = 1
Function._REXXLIB.DOSDISK                      = 1
Function._REXXLIB.DOSDRIVE                     = 1
Function._REXXLIB.DOSEALIST                    = 1
Function._REXXLIB.DOSEASIZE                    = 1
Function._REXXLIB.DOSEDITNAME                  = 1
Function._REXXLIB.DOSENV                       = 1
Function._REXXLIB.DOSENVLIST                   = 1
Function._REXXLIB.DOSENVSIZE                   = 1
Function._REXXLIB.DOSFDATE                     = 1
Function._REXXLIB.DOSFILEHANDLES               = 1
Function._REXXLIB.DOSFILEINFO                  = 1
Function._REXXLIB.DOSFILESYS                   = 1
Function._REXXLIB.DOSFNAME                     = 1
Function._REXXLIB.DOSFSIZE                     = 1
Function._REXXLIB.DOSISDEV                     = 1
Function._REXXLIB.DOSISDIR                     = 1
Function._REXXLIB.DOSISFILE                    = 1
Function._REXXLIB.DOSISPIPE                    = 1
Function._REXXLIB.DOSKILLPROCESS               = 1
Function._REXXLIB.DOSMAKEDIR                   = 1
Function._REXXLIB.DOSMAXPATH                   = 1
Function._REXXLIB.DOSMKDIR                     = 1
Function._REXXLIB.DOSPATHFIND                  = 1
Function._REXXLIB.DOSPID                       = 1
Function._REXXLIB.DOSPIDLIST                   = 1
Function._REXXLIB.DOSPRIORITY                  = 1
Function._REXXLIB.DOSPROCINFO                  = 1
Function._REXXLIB.DOSREAD                      = 1
Function._REXXLIB.DOSRENAME                    = 1
Function._REXXLIB.DOSRMDIR                     = 1
Function._REXXLIB.DOSSESSIONTYPE               = 1
Function._REXXLIB.DOSSHUTDOWN                  = 1
Function._REXXLIB.DOSSWITCHLIST                = 1
Function._REXXLIB.DOSTEMPNAME                  = 1
Function._REXXLIB.DOSTID                       = 1
Function._REXXLIB.DOSVOLINFO                   = 1
Function._REXXLIB.DOSVOLUME                    = 1
Function._REXXLIB.DOSWRITE                     = 1
Function._REXXLIB.ENTAB                        = 1
Function._REXXLIB.ERF                          = 1
Function._REXXLIB.ERFC                         = 1
Function._REXXLIB.EVENTSEM_CLOSE               = 1
Function._REXXLIB.EVENTSEM_CREATE              = 1
Function._REXXLIB.EVENTSEM_POST                = 1
Function._REXXLIB.EVENTSEM_QUERY               = 1
Function._REXXLIB.EVENTSEM_RESET               = 1
Function._REXXLIB.EVENTSEM_WAIT                = 1
Function._REXXLIB.EXP                          = 1
Function._REXXLIB.F2C                          = 1
Function._REXXLIB.FILECRC                      = 1
Function._REXXLIB.FILEREAD                     = 1
Function._REXXLIB.FILESEARCH                   = 1
Function._REXXLIB.FILEWRITE                    = 1
Function._REXXLIB.GAMMA                        = 1
Function._REXXLIB.GREP                         = 1
Function._REXXLIB.INKEY                        = 1
Function._REXXLIB.LOG                          = 1
Function._REXXLIB.LOG10                        = 1
Function._REXXLIB.LOWER                        = 1
Function._REXXLIB.MACROADD                     = 1
Function._REXXLIB.MACROCLEAR                   = 1
Function._REXXLIB.MACRODROP                    = 1
Function._REXXLIB.MACROLOAD                    = 1
Function._REXXLIB.MACROQUERY                   = 1
Function._REXXLIB.MACROREORDER                 = 1
Function._REXXLIB.MACROSAVE                    = 1
Function._REXXLIB.MUTEXSEM_CLOSE               = 1
Function._REXXLIB.MUTEXSEM_CREATE              = 1
Function._REXXLIB.MUTEXSEM_QUERY               = 1
Function._REXXLIB.MUTEXSEM_RELEASE             = 1
Function._REXXLIB.MUTEXSEM_REQUEST             = 1
Function._REXXLIB.NMPIPE_CALL                  = 1
Function._REXXLIB.NMPIPE_CLOSE                 = 1
Function._REXXLIB.NMPIPE_CONNECT               = 1
Function._REXXLIB.NMPIPE_CREATE                = 1
Function._REXXLIB.NMPIPE_DISCONNECT            = 1
Function._REXXLIB.NMPIPE_OPEN                  = 1
Function._REXXLIB.NMPIPE_PEEK                  = 1
Function._REXXLIB.NMPIPE_QUERY                 = 1
Function._REXXLIB.NMPIPE_READ                  = 1
Function._REXXLIB.NMPIPE_SET                   = 1
Function._REXXLIB.NMPIPE_TRANSACT              = 1
Function._REXXLIB.NMPIPE_WAIT                  = 1
Function._REXXLIB.NMPIPE_WRITE                 = 1
Function._REXXLIB.PARSEFN                      = 1
Function._REXXLIB.PCCOPROCESSOR                = 1
Function._REXXLIB.PCDISK                       = 1
Function._REXXLIB.PCFLOPPY                     = 1
Function._REXXLIB.PCMODEL                      = 1
Function._REXXLIB.PCPARALLEL                   = 1
Function._REXXLIB.PCRAM                        = 1
Function._REXXLIB.PCSERIAL                     = 1
Function._REXXLIB.PCSUBMODEL                   = 1
Function._REXXLIB.PCVIDEOCONFIG                = 1
Function._REXXLIB.PCVIDEOMODE                  = 1
Function._REXXLIB.PMPRINTF                     = 1
Function._REXXLIB.PMQUERYSYSVALUE              = 1
Function._REXXLIB.POW                          = 1
Function._REXXLIB.REXXLIBDEREGISTER            = 1
Function._REXXLIB.REXXLIBLIST                  = 1
Function._REXXLIB.REXXLIBREGISTER              = 1
Function._REXXLIB.REXXLIBVER                   = 1
Function._REXXLIB.REXXRUN                      = 1
Function._REXXLIB.REXXTHREAD                   = 1
Function._REXXLIB.SCRBLINK                     = 1
Function._REXXLIB.SCRBORDER                    = 1
Function._REXXLIB.SCRCLEAR                     = 1
Function._REXXLIB.SCROLLDOWN                   = 1
Function._REXXLIB.SCROLLLEFT                   = 1
Function._REXXLIB.SCROLLRIGHT                  = 1
Function._REXXLIB.SCROLLUP                     = 1
Function._REXXLIB.SCRPUT                       = 1
Function._REXXLIB.SCRREAD                      = 1
Function._REXXLIB.SCRSIZE                      = 1
Function._REXXLIB.SCRWRITE                     = 1
Function._REXXLIB.SHIFTSTATE                   = 1
Function._REXXLIB.SIN                          = 1
Function._REXXLIB.SINH                         = 1
Function._REXXLIB.SOUND                        = 1
Function._REXXLIB.SQRT                         = 1
Function._REXXLIB.STRINGCRC                    = 1
Function._REXXLIB.STRINGIN                     = 1
Function._REXXLIB.TAN                          = 1
Function._REXXLIB.TANH                         = 1
Function._REXXLIB.TOKENIZEFILE                 = 1
Function._REXXLIB.TOKENIZESTRING               = 1
Function._REXXLIB.TYPEMATIC                    = 1
Function._REXXLIB.UPPER                        = 1
Function._REXXLIB.VALIDNAME                    = 1
Function._REXXLIB.VARDUMP                      = 1
Function._REXXLIB.VARREAD                      = 1
Function._REXXLIB.VARWRITE                     = 1
Function._REXXLIB.WPSDESTROYOBJECT             = 1
Function._REXXLIB.WPSQUERYOBJECT               = 1
Function._REXXLIB.WPSSETOBJECTDATA             = 1
 
Function._RXU.RxAdd2Ptr                        = 1
Function._RXU.RxAddMacro                       = 1
Function._RXU.RxAddMuxWaitSem                  = 1
Function._RXU.RxAddQueue                       = 1
Function._RXU.RxAllocMem                       = 1
Function._RXU.RxAllocSharedMem                 = 1
Function._RXU.RxC2F                            = 1
Function._RXU.RxCallEntryPoint                 = 1
Function._RXU.RxCallFuncAddress                = 1
Function._RXU.RxCallInStore                    = 1
Function._RXU.RxCallProcAddr                   = 1
Function._RXU.RxClearMacroSpace                = 1
Function._RXU.RxCloseEventSem                  = 1
Function._RXU.RxCloseH                         = 1
Function._RXU.RxCloseMutexSem                  = 1
Function._RXU.RxCloseMuxWaitSem                = 1
Function._RXU.RxCloseQueue                     = 1
Function._RXU.RxConnectNPipe                   = 1
Function._RXU.RxCreateEventSem                 = 1
Function._RXU.RxCreateMutexSem                 = 1
Function._RXU.RxCreateMuxWaitSem               = 1
Function._RXU.RxCreateNPipe                    = 1
Function._RXU.RxCreatePipe                     = 1
Function._RXU.RxCreateQueue                    = 1
Function._RXU.RxCreateRexxThread               = 1
Function._RXU.RxCreateThread                   = 1
Function._RXU.RxDeleteMuxWaitSem               = 1
Function._RXU.RxDeregisterExit                 = 1
Function._RXU.RxDestroyPipe                    = 1
Function._RXU.RxDetachRexxPgm                  = 1
Function._RXU.RxDevConfig                      = 1
Function._RXU.RxDevIOCtl                       = 1
Function._RXU.RxDisConnectNPipe                = 1
Function._RXU.RxDosRead                        = 1
Function._RXU.RxDosWrite                       = 1
Function._RXU.RxDropMacro                      = 1
Function._RXU.RxDupHandle                      = 1
Function._RXU.RxExecI                          = 1
Function._RXU.RxExecO                          = 1
Function._RXU.RxExecPgm                        = 1
Function._RXU.RxExitList                       = 1
Function._RXU.RxF2C                            = 1
Function._RXU.RxFree                           = 1
Function._RXU.RxFreeMem                        = 1
Function._RXU.RxFreeModule                     = 1
Function._RXU.RxGetInfoBlocks                  = 1
Function._RXU.RxGetNamedSharedMem              = 1
Function._RXU.RxGetSharedMem                   = 1
Function._RXU.RxGiveSharedMem                  = 1
Function._RXU.RxGlobalVar                      = 1
Function._RXU.RXUINIT                          = 1
Function._RXU.RxKbdCharIn                      = 1
Function._RXU.RxKillProcess                    = 1
Function._RXU.RxKillThread                     = 1
Function._RXU.RxLineInH                        = 1
Function._RXU.RxLoadMacroSpace                 = 1
Function._RXU.RxLoadModule                     = 1
Function._RXU.RxMalloc                         = 1
Function._RXU.RxNbSessionStatus                = 1
Function._RXU.RxNet                            = 1
Function._RXU.RxOpen                           = 1
Function._RXU.RxOpenEventSem                   = 1
Function._RXU.RxOpenMutexSem                   = 1
Function._RXU.RxOpenMuxWaitSem                 = 1
Function._RXU.RxOpenQueue                      = 1
Function._RXU.RxPBNBufSize                     = 1
Function._RXU.RxPassByName                     = 1
Function._RXU.RxPeekQueue                      = 1
Function._RXU.RxPhysicalDisk                   = 1
Function._RXU.RxPmPrintf                       = 1
Function._RXU.RxPostEventSem                   = 1
Function._RXU.RxProcId                         = 1
Function._RXU.RxPullQueue                      = 1
Function._RXU.RxPurgeQueue                     = 1
Function._RXU.RxQExists                        = 1
Function._RXU.RxQProcStatus                    = 1
Function._RXU.RxQueryAppType                   = 1
Function._RXU.RxQueryEventSem                  = 1
Function._RXU.RxQueryExit                      = 1
Function._RXU.RxQueryExtLibPath                = 1
Function._RXU.RxQueryFHState                   = 1
Function._RXU.RxQueryMacro                     = 1
Function._RXU.RxQueryMem                       = 1
Function._RXU.RxQueryModuleHandle              = 1
Function._RXU.RxQueryModuleName                = 1
Function._RXU.RxQueryMutexSem                  = 1
Function._RXU.RxQueryMuxWaitSem                = 1
Function._RXU.RxQueryProcAddr                  = 1
Function._RXU.RxQueryProcType                  = 1
Function._RXU.RxQueryQueue                     = 1
Function._RXU.RxQuerySysInfo                   = 1
Function._RXU.RxQueued                         = 1
Function._RXU.RxRSi2F                          = 1
Function._RXU.RxRead                           = 1
Function._RXU.RxReadQueue                      = 1
Function._RXU.RxReadQueueStr                   = 1
Function._RXU.RxRegisterExitDll                = 1
Function._RXU.RxRegisterExitExe                = 1
Function._RXU.RxRegisterFuncAddress            = 1
Function._RXU.RxRegisterFunctionExe            = 1
Function._RXU.RxReleaseMutexSem                = 1
Function._RXU.RxReorderMacro                   = 1
Function._RXU.RxReplaceModule                  = 1
Function._RXU.RxRequestMutexSem                = 1
Function._RXU.RxResetEventSem                  = 1
Function._RXU.RxResumeThread                   = 1
Function._RXU.RxReturnByName                   = 1
Function._RXU.RxRsoe2f                         = 1
Function._RXU.RxRsoe2q                         = 1
Function._RXU.RxSaveMacroSpace                 = 1
Function._RXU.RxScount                         = 1
Function._RXU.RxSearchPath                     = 1
Function._RXU.RxSetError                       = 1
Function._RXU.RxSetExceptionExit               = 1
Function._RXU.RxSetExtLibPath                  = 1
Function._RXU.RxSetFHState                     = 1
Function._RXU.RxSetMaxFH                       = 1
Function._RXU.RxSetMem                         = 1
Function._RXU.RxSetNPHState                    = 1
Function._RXU.RxSetPriority                    = 1
Function._RXU.RxSetRelMaxFH                    = 1
Function._RXU.RxSi2H                           = 1
Function._RXU.RxSoSe2H                         = 1
Function._RXU.RxStartRexxSession               = 1
Function._RXU.RxStartSession                   = 1
Function._RXU.RxStem2Struct                    = 1
Function._RXU.RxStorage                        = 1
Function._RXU.RxStruct2Stem                    = 1
Function._RXU.RxStructMap                      = 1
Function._RXU.RxSubAllocMem                    = 1
Function._RXU.RxSubFreeMem                     = 1
Function._RXU.RxSubSetMem                      = 1
Function._RXU.RxSubUnsetMem                    = 1
Function._RXU.RxSuspendThread                  = 1
Function._RXU.RxThunkAddr                      = 1
Function._RXU.RxTmrQueryFreq                   = 1
Function._RXU.RxTmrQueryTime                   = 1
Function._RXU.RxTokenize                       = 1
Function._RXU.RxUpm                            = 1
Function._RXU.RxVioEndPopUp                    = 1
Function._RXU.RxVioPopUp                       = 1
Function._RXU.RxVioWrtCharStrAtt               = 1
Function._RXU.RxVlist                          = 1
Function._RXU.RxWaitChild                      = 1
Function._RXU.RxWaitEventSem                   = 1
Function._RXU.RxWaitMuxWaitSem                 = 1
Function._RXU.RxWinDestroyObject               = 1
Function._RXU.RxWinQueryObject                 = 1
Function._RXU.RxWinSetPresParam                = 1
Function._RXU.RxWinSetSelf                     = 1
Function._RXU.RxWrite                          = 1
Function._RXU.RxWriteQueue                     = 1
Function._RXU.RxuMthacos                       = 1
Function._RXU.RxuMthasin                       = 1
Function._RXU.RxuMthatan                       = 1
Function._RXU.RxuMthatan2                      = 1
Function._RXU.RxuMthceil                       = 1
Function._RXU.RxuMthcos                        = 1
Function._RXU.RxuMthcosh                       = 1
Function._RXU.RxuMtherf                        = 1
Function._RXU.RxuMtherfc                       = 1
Function._RXU.RxuMthexp                        = 1
Function._RXU.RxuMthfabs                       = 1
Function._RXU.RxuMthfloor                      = 1
Function._RXU.RxuMthfmod                       = 1
Function._RXU.RxuMthfrexp                      = 1
Function._RXU.RxuMthgamma                      = 1
Function._RXU.RxuMthhypot                      = 1
Function._RXU.RxuMthldexp                      = 1
Function._RXU.RxuMthlog                        = 1
Function._RXU.RxuMthlog10                      = 1
Function._RXU.RxuMthmodf                       = 1
Function._RXU.RxuMthpow                        = 1
Function._RXU.RxuMthsin                        = 1
Function._RXU.RxuMthsinh                       = 1
Function._RXU.RxuMthsqrt                       = 1
Function._RXU.RxuMthtan                        = 1
Function._RXU.RxuMthtanh                       = 1
Function._RXU.RxuQuery                         = 1
Function._RXU.RxuTerm                          = 1

Function._VPREXX.VPADDITEM                     = 1
Function._VPREXX.VPDELETEITEM                  = 1
Function._VPREXX.VPDRAW                        = 1
Function._VPREXX.VPFILEDIALOG                  = 1
Function._VPREXX.VPINIT                        = 1
Function._VPREXX.VPISSELECTED                  = 1
Function._VPREXX.VPGETINDEX                    = 1
Function._VPREXX.VPGETITEMCOUNT                = 1
Function._VPREXX.VPGETITEMINDEX                = 1
Function._VPREXX.VPGETITEMVALUE                = 1
Function._VPREXX.VPGETMSG                      = 1
Function._VPREXX.VPISSELECTED                  = 1
Function._VPREXX.VPITEM                        = 1
Function._VPREXX.VPITEMCOUNT                   = 1
Function._VPREXX.VPMESSAGEBOX                  = 1
Function._VPREXX.VPOPENFORM                    = 1
Function._VPREXX.VPQUIT                        = 1
Function._VPREXX.VPSELECT                      = 1
Function._VPREXX.VPSETITEMVALUE                = 1
Function._VPREXX.VPSETRANGE                    = 1
Function._VPREXX.VPWINDOW                      = 1

Function._RXGDUTIL.RxgdImageCreate             = 1
Function._RXGDUTIL.RxgdImageCreateFromGIF      = 1
Function._RXGDUTIL.RxgdImageDestroy            = 1
Function._RXGDUTIL.RxgdImageGIF                = 1
Function._RXGDUTIL.RxgdImageSetPixel           = 1
Function._RXGDUTIL.RxgdImageLine               = 1
Function._RXGDUTIL.RxgdImagePolygon            = 1
Function._RXGDUTIL.RxgdImageFilledPolygon      = 1
Function._RXGDUTIL.RxgdImageRectangle          = 1
Function._RXGDUTIL.RxgdImageFilledRectangle    = 1
Function._RXGDUTIL.RxgdImageArc                = 1
Function._RXGDUTIL.RxgdImageFillToBorder       = 1
Function._RXGDUTIL.RxgdImageFill               = 1
Function._RXGDUTIL.RxgdImageSetBrush           = 1
Function._RXGDUTIL.RxgdImageSetTile            = 1
Function._RXGDUTIL.RxgdImageSetStyle           = 1
Function._RXGDUTIL.RxgdImageGetStyleBrushed    = 1
Function._RXGDUTIL.RxgdImageBlue               = 1
Function._RXGDUTIL.RxgdImageRed                = 1
Function._RXGDUTIL.RxgdImageGreen              = 1
Function._RXGDUTIL.RxgdImageGetPixel           = 1
Function._RXGDUTIL.RxgdImageSX                 = 1
Function._RXGDUTIL.RxgdImageSY                 = 1
Function._RXGDUTIL.RxgdImageString             = 1
Function._RXGDUTIL.RxgdImageStringUp           = 1
Function._RXGDUTIL.RxgdImageColorAllocate      = 1
Function._RXGDUTIL.RxgdImageColorClosest       = 1
Function._RXGDUTIL.RxgdImageColorExact         = 1
Function._RXGDUTIL.RxgdImageColorsTotal        = 1
Function._RXGDUTIL.RxgdImageGetInterlaced      = 1
Function._RXGDUTIL.RxgdImageInterlaced         = 1
Function._RXGDUTIL.RxgdImageGetTransparent     = 1
Function._RXGDUTIL.RxgdImageColorTransparent   = 1
Function._RXGDUTIL.RxgdImageColorDeallocate    = 1
Function._RXGDUTIL.RxgdImageCopy               = 1
Function._RXGDUTIL.RxgdImageCopyResized        = 1
Function._RXGDUTIL.RXGDLOADFUNCS               = 1

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   LoadKnownFunctions:                                -------------*/
/* --------------------------------------------------------------------------*/


LoadMyDll:
/* Generic DLL loader with check to confirm it is really loaded.             */
/* returns : 1 - dll load ok                                                 */ 
/*           0 - dll load error                                              */ 
/* Derived from REXX Tips & Tricks by Bernd Schemmer                         */ 
procedure

DLL      = arg(1)
LoadFunc = arg(2)

/* Install a temporary error handler. The previous error handler is          */
/* automatically restored a the end of the routine                           */ 
SIGNAL ON SYNTAX NAME LoadDllError 

dllLoadOK = 0                             /* Set a marker                    */

call rxFuncDrop LoadFunc                  /* Deregister the load function.   */
dummy = rxFuncAdd(LoadFunc,DLL,LoadFunc)  /* Load the load function          */ 
interpret 'call' LoadFunc                 /* Call the load function          */ 
dllLoadOK = 1                             /* Sets the marker if load was OK. */ 

LoadDllError: 
/* DeRegister the name if the load call failed                               */ 
if dllLoadOK = 0 then 
   call rxFuncDrop LoadFunc
RETURN dllLoadOK
/* --- end   LoadMyDLL:                                         -------------*/
/* --------------------------------------------------------------------------*/


Main: 
/* --------------------------------------------------------------------------*/
/* --- begin MAIN                                               -------------*/
/* Major variables:                                                          */
/* Created in ReadRawSource().                                               */
/*    data.          - Original source code.                                 */
/*                                                                           */
/* Created in MapNMaskCommentsNLiterals().                                   */
/*    dataEdited1.   - Source after replacing all comments with blanks.      */
/*    dataEdited2.   - Source after blanking comments and literal strings.   */
/*                                                                           */
/* LogicalLines are lines after editing out of continuations, semicolons     */
/* and blank lines.                                                          */
/* Created in MakeLogicalLines().                                            */
/*    LogicalLineI.   = Original source code.                                */
/*    LogicalLine1.   = Comments are blanked out.                            */
/*    LogicalLine2.   = Comments and literal strings are blanked out.        */
/*    SourceIndex.j   = First line in original source of logical line j.     */
/*    Notes -                                                                */
/*                                                                           */
/*    Comment.i.0     = Number of comments in line i.                        */
/*    Comment.i._Str.k = Character position for start of comment k in line i. */
/*    Comment.i._End.k = Character position for end   of comment k in line i. */
/*    Comment.i._txt.k = Text of comment k in line i.                         */
/*                                                                           */
/*    Literal.i.0     = Number of literals in line i.                        */
/*    Literal.i._Str.j = Character position for start of literal k in line i. */
/*    Literal.i._End.j = Character position for end   of literal k in line i. */
/*    Literal.i._Typ.j = Type of literal k in line i (S|D - single or double).*/
/*    Literal.i._txt.j = Text of literal k in line i.                         */
/*                                                                           */
/* Created in FindLabels().                                                  */
/*    Label.i         = Line# || Type ("STRING"|"SYMBOL") || FunctionName    */
/*                                                                           */
/* Created in FindCallInstructions() & FindCalls2Subroutines().              */
/*    SRMap.v = 1       Where v = '_'CurRoutine'._'Label                     */
/* Notes - This provides a way to find which routines call or are called by  */
/*    which routines.                                                        */
/*                                                                           */
/* Created in FunctionAnalysis().                                            */
/*    FRef.i.0        = Number of functions referenced in line i.            */
/*    FRef.i._Str.k   = char 1 in name of kth function referenced in line i. */
/*    FRef.i._End.k   = Last char of name of kth function referenced in i.   */
/*    FRef.i._Txt.k   = Text string (name) kth function referenced in line i.*/
/*    FRef.i._Typ.k   = Type of function,  kth function referenced in line i.*/
/*    FRef.i._Open.k  = Postion of "(" for kth function referenced in line i.*/
/*    FRef.i._Close.k = Postion of ")" for kth function referenced in line i.*/
/*    FRef.i._Knd.k   = Nature of reference, subroutine call or function.    */
/* Notes -                                                                   */
/* 1. Positions are relative to the first non-blank character in the line.   */
/* 2. FRef.line._Open.k = FRef.line._Close.k when the reference is done      */
/*    using the CALL instruction and there are no arguments passed.          */
/* 3. For CALL instructions FRef.i._Open.k and FRef.i._Close.k give positions*/
/*    of first and last characters of argument string.  If there are no      */
/*    arguments FRef.i._Close.k = FRef.i._Open.k.                            */
/* 4. For a CALL (variable) FRef.i._Str.k and FRef.i._End.k are the same as  */
/*    FRef.i._Open.k and FRef.i._Close.k.                                    */
/* 5. FRef.i._Knd.k = nature or manner of reference                          */
/*           "CALL" - of the form: CALL function_name                        */
/*       "Var_CALL" - of the form: CALL (VAR)                                */
/*       "Lit_CALL" - of the form: CALL "function_name"                      */
/*       "FUNCTION" - of the form: rc=function_name()                        */
/*       "Lit_FUNC" - of the form: rc="function_name"()                      */
/* 6. For CALL instructions FRef.i._Open.k and FRef.i._Close.k are computed  */
/*    after all comment blocks have been deleted.                            */

/* Warnings:                                                                 */
/*    If the program is recursive, i.e. it calls itself.                     */
/*    If a subroutine is never explicitly referenced.                        */
/*    If a two or more labels have the same name.                            */

/* Debugging notes.                                                          */
/* First turn on the lines in this subroutine that dump the lines as read    */
/* at the several stages of preliminary processing.  The specific variables: */
/* data., dataEdited1., dataEdited2., LogicalLineI., LogicalLine1.,          */
/* LogicalLine2..  Do this before anything else.  I.e. make sure the lines   */
/* are being properly read and readied for subsequent processing.            */

SubRoutineHistory = 'Main' SubRoutineHistory

call time 'r'

in = arg(1)

txt = 'Analysis of program 'in
rc  = lineout(out,txt)
rc  = lineout(out,'at' date() time())

rc = ReadRawSource(in)
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Read 'data.0' lines from source file,' in'.'

rc = MapNMaskCommentsNLiterals('RAW_C',)
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished finding comments in source.'

rc = MapNMaskCommentsNLiterals('RAW_L',)
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished finding literals in source.'

/* Set Debut = 'YES' then the following variables will be printed.           */
/*     data., dataEdited1., dataEdited2., LogicalLineI., LogicalLine1.,      */
/*     LogicalLine2., Comment., Literal.                                     */

Debug = 'NO' 
/* Comments and literals in raw source are now blanked out. */
if Debug = 'YES' then do
   say "Dumping data.       " ; do i = 1 to data.0       ; say 'I line 'right(i,5,'0')':'  data.i        ;  end i 
   say "Dumping dataEdited1." ; do i = 1 to dataEdited2.0; say '1 line 'right(i,5,'0')':'  dataEdited1.i ;  end i 
   say "Dumping dataEdited2." ; do i = 1 to dataEdited2.0; say '2 line 'right(i,5,'0')':'  dataEdited2.i ;  end i 
   end /* if Debug = 'YES' then ... */

rc = MakeLogicalLines()
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished making 'LogicalLineI.0' logical lines.'

/* do i = 1 to LogicalLineI.0 ; say 'Logical line 'right(i,5,'0')':'  LogicalLineI.i ;  end i  */

/* Find and record the location and length of all comments and literals in the logical lines. */
rc = MapNMaskCommentsNLiterals('LOGICAL_C','MAP')
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished finding comments in logical lines.'

rc = MapNMaskCommentsNLiterals('LOGICAL_L','MAP')
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished finding literals in logical lines.'

/* do i = 1 to LogicalLine2.0 ; say 'line 'right(i,5,'0')':'  LogicalLine2.i ;  end i */


/* Debugging aid and illustration of how to use variables defined so far.    */
Debug = 'NO'
if Debug = yes then do
   do i = 1 to LogicalLineI.0
      say 'Source Line 'SourceIndex.i',  Logical Line 'i
      say 'LogicalLineI:' '|'LogicalLineI.i'|'
      say 'LogicalLine1:' '|'LogicalLine1.i'|'
      say 'LogicalLine2:' '|'LogicalLine2.i'|'
      do j = 1 to Comment.i.0
         say 'Comments:' Comment.i._Str.j Comment.i._End.j '|'Comment.i._txt.j'|' 
         end j
      do j = 1 to Literal.i.0
         say 'Literals:' Literal.i._Str.j Literal.i._End.j Literal.i._Typ.j '|'Literal.i._txt.j'|'
         end j
      say
      end i
   end /* if Debug = 'YES' then ... */

rc = FindLabelsNDirectives()
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished finding labels and directives.'

rc = LoadKnownFunctions()
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished loading table of known functions.'

rc = LoadDefaultConditions()
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished loading table of default conditions.'

rc = FindCalls2Subroutines() /* Find all usages of the internal subroutines. */
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished finding calls to subroutines.'

rc = WriteFRefTable()
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished writing function references table.'

rc = SubroutineAnalyzer(in)
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
say 'Finished with the subroutine analyzer.'

say 'Analysis took' time( 'e' ) 'seconds'

parse var SubRoutineHistory . SubRoutineHistory
return 1


MakeLogicalLines: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - MakeLogicalLines:                     -------------*/
/* Make logical lines.  Keep track of physical line numbers.                 */
/* Reassemble complete lines by eliminating continuations, semicolons and    */
/* blanks lines.  Keeps track of original line numbers.                      */
/* Major variables:                                                          */
/*    data.          - Original source code.                                 */
/*    dataEdited1.   - Source after replacing all comments with blanks.      */
/*    dataEdited2.   - Source after blanking comments and literal strings.   */
/*    LogicalLines are lines after editing out of continuations, semicolons  */
/*    and blank lines.                                                       */
/*    LogicalLineI.  - Original source code.                                 */
/*    LogicalLine1.  - Comments are blanked out.                             */
/*    LogicalLine2.  - Comments and literal strings are blanked out.         */
/*    SourceIndex.j  - First line in original source of logical line j.      */
procedure expose (DefaultExposeList),
                 data.          dataEdited1.     dataEdited2.,
                 LogicalLineI.  LogicalLine1.    LogicalLine2.
SubRoutineHistory = 'MakeLogicalLines' SubRoutineHistory

NewLineN  = 0
SkipLines = 0 /* Number of lines from input to be skipped.  This avoids      */
              /* editing "i" internal to the loop.                           */

do i = 1 to dataEdited2.0
   
   if SkipLines > 0 then do
      SkipLines = SkipLines -1
      iterate i
      end

   dataI = strip(data.i)      
   data1 = strip(dataEdited1.i)
   data2 = strip(dataEdited2.i)
   if dataI = '' then /* Skip completely blank lines. */
      iterate i

   NewLineN = NewLineN+1
   LogicalLineI.NewLineN = dataI
   LogicalLine1.NewLineN = data1
   LogicalLine2.NewLineN = data2
   SourceIndex.NewLineN  = i /* Line in original code for the new line.      */

   if right(data1,1) = ',' then do
      /* Literals ARE needed here!!! There are commas separating             */
      /* literals as arguments.                                              */ 
      rc1 = RebuildALineContinuation(i)
      if word(rc1,1) \= 1 then do
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end

      /* say 'NewLine after Continuation 'NewLine1.1 */

      /* Replace existing logical lines. */
      LogicalLineI.NewLineN = NewLineI.1
      LogicalLine1.NewLineN = NewLine1.1
      LogicalLine2.NewLineN = NewLine2.1
      SourceIndex.NewLineN  = i /* Line in original code for the new line. */
      
      SkipLines = word(rc1,2)
      end /* if right(data,1) = ',' then ... */

   
   if pos(';',LogicalLine2.NewLineN)>0 then do /* Literals are not needed here. */
      rc = RebuildALineSemiColon(NewLineN)
      if rc \= 1 then do
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end

      NewLineN = NewLineN-1
      do k = 1 to NewLine2.0
         /* say 'NewLine after semicolon 'NewLine1.k */
         NewLineN = NewLineN+1
         LogicalLineI.NewLineN = strip(NewLineI.k)
         LogicalLine1.NewLineN = NewLine1.k
         LogicalLine2.NewLineN = strip(NewLine2.k)
         SourceIndex.NewLineN  = i /* Line in original code for the new line.*/
         end
      end /* if pos(';', ... */

   end i

LogicalLineI.0 = NewLineN
LogicalLine1.0 = NewLineN
LogicalLine2.0 = NewLineN


/* 
do i = 1 to LogicalLineI.0
   say 'From source line 'SourceIndex.i' comes logical line 'i':  'LogicalLineI.i
   end
*/

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - MakeLogicalLines:                     -------------*/
/* --------------------------------------------------------------------------*/


MapNMaskCommentsNLiterals: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - MapNMaskCommentsNLiterals:            -------------*/
/* This is used to eliminate and optionally map the location of all          */
/* comments and literal strings.                                             */
/* Logic:                                                                    */
/* 1. Tablulate all - potential comment beginnings,                          */
/*                  - potential comment endings,                             */
/*                  - single quote marks,                                    */
/*                  - double quote marks.                                    */
/*    Store this information in a table by line and character position.      */
/* 2. Sort the table.                                                        */
/* 3. Going through the table find an initial comment beginning or a quote   */
/*    mark. Then find the corresponding close of the comment or quote.  Mask */
/*    everything in between with blanks. Optionally retain record of start,  */
/*    stop, content and for literal its type of each item blanked out.       */
/*                                                                           */
/* Parameter switches                                                        */
/*    mode   - RAW_C     - read raw source and blank comments.               */
/*             Output is in "dataEdited1.".                                  */
/*           - RAW_L     - read dataEdited1. and blank literals.             */
/*             Output is in "dataEdited2.".                                  */
/*           - LOGICAL_C - read LogicalLineI. and blank comments.  Output is */
/*             in "LogicalLine1.".  see note below.                          */
/*           - LOGICAL_L - read LogicalLine1. and blank literals.  Output is */
/*             in "LogicalLine2.".                                           */
/*           - 1Line_C   - Process only the line given in the third argument,*/
/*             "ALine". This option automatically set map = 'MAP' and should */
/*             only be used on a logical line! Read LogicalLineI.ALine.      */
/*             Output is in "LogicalLine1.ALine".                            */
/*           - 1Line_L   - Process only the line given in the third argument,*/
/*             "ALine". This option automatically set map = 'MAP' and should */
/*             only be used on a logical line! Read LogicalLine1.ALine.      */
/*             Output is in "LogicalLine2.ALine".                            */
/*     map"  - 'MAP' indices to all comments and literals is built.  Start   */
/*             and stop positions include the delimiting characters, "/",    */
/*             "*", "'", and '"'.  Text is the string without the            */
/*             delimiting characters.                                        */
/*    ALine  - Number of a logical line.  Used only when mode='1Line'.       */
/*                                                                           */
/* Comment and Literal maps are in the following arrays.                     */
/*    Comment.i.0     = Number of comments in line i.                        */
/*    Comment.i._Str.k = Character position for start of comment k in line i.*/
/*    Comment.i._End.k = Character position for end   of comment k in line i.*/
/*    Comment.i._Txt.k = Text of comment k in line i.                        */
/*    Literal.i.0     = Number of literals in line i.                        */
/*    Literal.i._Str.j = Character position for start of literal k in line i.*/
/*    Literal.i._End.j = Character position for end   of literal k in line i.*/
/*    Literal.i._Typ.j = Type of literal k in line i (S|D - single or double)*/
/*    Literal.i._Txt.j = Text of literal k in line i.                        */
/*                                                                           */
/*    Aug 26,2003 - Added 1Line option.  DLR.                                */
/*    Sep 03,2003 - Removed CL options.  DLR.                                */
procedure expose (DefaultExposeList)                          ,
                 data.          dataEdited1.     dataEdited2. ,
                 LogicalLineI.  LogicalLine1.    LogicalLine2.,
                 Comment.       Literal.
SubRoutineHistory = 'MapNMaskCommentsNLiterals' SubRoutineHistory

mode = arg(1) /* RAW_C | RAW_L | LOGICAL_C | LOGICAL_L  | 1Line_C | 1Line_L  */
map  = arg(2) /* MAP | .        This should only be used with Logical Lines. */
ALine= arg(3) /* Line number.  Used if mode=1Line_C | 1Line_A                */

Numeric Digits 13

/* Copy data., dataEdited1., LogicalLineI. or LogicalLine1. into Temp. */
select
   when mode='RAW_C'                         then do i = 1 to data.0 
      Temp.i = data.i
      end i
   when mode='RAW_L'                         then do i = 1 to dataEdited1.0 
      Temp.i = dataEdited1.i
      end i
   when mode='LOGICAL_C'                     then do i = 1 to LogicalLineI.0
      Temp.i = LogicalLineI.i
      end i
   when mode='LOGICAL_L'                     then do i = 1 to LogicalLine1.0
      Temp.i = LogicalLine1.i
      /* say 'Input line ' right(i,4) '|'Temp.i'|' */
      end i
   when mode = '1Line_C'                     then do
      map = 'MAP'
      Temp.1 = LogicalLineI.ALine
      Comment.Line.0 = 0
      Literal.Line.0 = 0
      i = 2
      end
   when mode = '1Line_L'                     then do
      map = 'MAP'
      Temp.1 = LogicalLine1.ALine
      Comment.Line.0 = 0
      Literal.Line.0 = 0
      i = 2
      end
   otherwise do
      say 'Doug, you messed up the select again.  This one is in MaskCommentsNLiterals.'
      parse var SubRoutineHistory . SubRoutineHistory
      return 0
      end
   end /* select */
Temp.0 = i-1

rc = TabulateCommentsNQuotes('BOTH')
if rc \= 1 then do
   parse var SubRoutineHistory . SubRoutineHistory
   return 0
   end
if (mode='1Line_C' | mode='1Line_L') then do i = 1 to Temp1.0
   parse var Temp1.i indexL '.' indexC Key
   Temp1.i = right(ALine,6,'0') || '.' || indexC Key
   end i

/* A check of the number of comments can be done by summing contents of      */
/* Temp1. for all instances where key is a number. I do not recommend this   */
/* test logic until after literals have been handled.                        */
/* Sum = 0                                                                   */
/* do i = 1 to Temp1.0                                                       */
/*    parse var Temp1.i index Key                                            */
/*    if datatype(key,'N') then                                              */
/*       Sum = Sum + key                                                     */
/*    end i                                                                  */
/* if Sum \= 0 then do                                                       */
/*    say 'The number of comment starts \= the number of comment ends.'      */
/*    parse var SubRoutineHistory . SubRoutineHistory                        */
/*    return 0                                                               */
/*    end                                                                    */

/* Intialize mapping indices for all lines. */
if map = 'MAP' & Comment.1.0 = 'COMMENT.1.0' then do i = 1 to Temp.0
   Comment.i.0 = 0
   Literal.i.0 = 0
   end

/* Starting at line 1, character 1 read through indices of comments & quotes.*/
/* Whichever is encountered first, all characters up to and including the    */
/* corresponding end mark are blanked out.                                   */

do i = 1 to Temp1.0 
   parse var Temp1.i index Key 

   /* if left(mode,1)='L' & i=406 then trace ?i */
   /* if mode='RAW_C' & i = 7 then trace ?i */
   /*     
   if left(mode,1)='L' & i>400 & i<415 then do /* Show Temp1. position and Temp. contents. */
      parse var index indexL '.' indexC
      indexL = indexL/1
      say 'Temp1.'i': 'Temp1.i'  Temp.'indexL':' Temp.indexL
      end
   */
   
   select
      when Key = 'nul' then do
         /* Something inside a block or the end of a literal or a comment.    */
         nop
         end

      when Key = 1 then do
         /* Now we start looking for a matching close comment string.        */
         Temp1.i = index 'nul' /* Mark the fact we have looked at this entry.*/
         StrOCom = index
         total=1
         do j = i+1 to Temp1.0
            parse var Temp1.j index Key
            select
               when Key=-1 | Key=1 then do
                  Temp1.j = index 'nul'
                  total = total+Key
                  end
               when Key='S' | Key='D' then
                  Temp1.j = index 'nul'
               when Key='nul' then
                  nop
               otherwise do
                  say 'Programmer error: Something wrong in MapCommentsNLiterals, select 1 '
                  parse var SubRoutineHistory . SubRoutineHistory
                  return 0
                  end     
               end /* select */
            
            if total = 0 then do
                        
               EndOCom = index

               parse var StrOCom indexLs '.' indexCs .
               parse var EndOCom indexLe '.' indexCe .

               if mode='RAW_C' & indexLe>indexLs then do
                  /* Add "star slash" to lines of a multi-line comment block. */
                  rc = RebuildALineComment(StrOCom,EndOCom) 
                  if rc \= 1 then do
                     parse var SubRoutineHistory . SubRoutineHistory
                     return 0
                     end
                  EndOCom = indexLe'.'right(indexCe+2,6,'0')
                  end

               if map = 'MAP' then do
                  /* Remember where comments are and the comment string.     */
                  indexL = indexLs/1
                  k = Comment.indexL.0 +1
                  Comment.indexL.0 = k
                  Comment.indexL._Str.k = indexCs/1
                  Comment.indexL._End.k = indexCe/1+1
                  Comment.indexL._Txt.k = substr(temp.indexL,indexCs/1+2,indexCe-indexCs/1-2)
                  end
               
               if mode='RAW_C' | mode='LOGICAL_C' | mode='1Line_C' then do
                  rc = ClearCommentBlock(StrOCom,EndOCom)
                  if rc \= 1 then do
                     parse var SubRoutineHistory . SubRoutineHistory
                     return 0
                     end
                  end
               leave j
               end
            end j
         end /* when Key = 1 ... */

      when Key = -1 then do 
         say 'An unmatched "star slash (close comment)" was found on Source Line: 'indexL', Character: 'indexC
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end

      when (Key='S' | Key='D') then do
         /* Now we start looking for a matching quote string. */                     
         parse var index indexL '.' indexC .
         indexL = indexL/1
         indexC = indexC/1
         data = temp.indexL
         rc = FindLiterals(data,indexC,mode)
            if rc \= 1 then do
            parse var SubRoutineHistory . SubRoutineHistory
            return 0
            end

         if map='MAP' &  (mode='LOGICAL_L' | mode='1Line_L') then do
            /* Remember where the literals are, their type and the string. */
            k = Literal.indexL.0 +1
            Literal.indexL.0 = k
            Literal.indexL._Str.k = StrLiteral.1
            Literal.indexL._End.k = EndLiteral.1
            Literal.indexL._Typ.k = TypLiteral.1
            Literal.indexL._Txt.k = TxtLiteral.1
            end

         if mode='RAW_L' | mode='LOGICAL_L' | mode='1Line_L' then do
            /* Mask the literal strings. */
            rc = ClearLiteralStrings(data,1)
            if rc \= 1 then do
               parse var SubRoutineHistory . SubRoutineHistory
               return 0
               end
            temp.indexL = data
            end

         /* Update the contents of Temp1., the array of indices. */
         Temp1.i = index 'nul'  
         do j = i+1 to Temp1.0
            /* This logic only works if there are matched quotes on this line! */
            parse var Temp1.j indexL '.' indexC .
            Temp1.j = indexL'.'indexC 'nul'
            if indexC = EndLiteral.1 then
               leave j
            end j
         end /* when (Key='S' ... */
 
      otherwise do
         parse var index indexL '.' indexC 
         say 'Programmer error: Something wrong in MapCommentsNLiterals, select 2, Source Line: 'indexL', Character: 'indexC
         say 
         parse var SubRoutineHistory . SubRoutineHistory
         return 0
         end     
      end /* select */
   end i


/* Copy data., dataEdited1., LogicalLineI. or LogicalLine1. from Temp. */
select
   when mode='RAW_C'                         then do i = 1 to temp.0 
      dataEdited1.i = Temp.i
      dataEdited1.0 = Temp.0
      end i
   when mode='RAW_L'                         then do i = 1 to temp.0 
      dataEdited2.i = Temp.i
      dataEdited2.0 = Temp.0
      end i
   when mode='LOGICAL_C'                     then do i = 1 to temp.0
      LogicalLine1.i = Temp.i
      LogicalLine1.0 = Temp.0
      end i
   when mode='LOGICAL_L'                     then do i = 1 to temp.0
      LogicalLine2.i = Temp.i
      LogicalLine2.0 = Temp.0
      end i
   when mode = '1Line_C'                     then do
      LogicalLine1.ALine = Temp.1
      end
   when mode = '1Line_L'                     then do
      LogicalLine2.ALine = Temp.1
      end
   otherwise do
      say 'The select at the end of MapNMaskCommentsNLiterals() does not',
      'match the select at the start of the subroutine.  Boy is that dumb!'
      parse var SubRoutineHistory . SubRoutineHistory
      return 0
      end
   end /* select */

drop Temp. Temp1.

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - MapNMaskCommentsNLiterals:            -------------*/
/* --------------------------------------------------------------------------*/


MatchSubroutine:
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - MatchSubroutine:                      -------------*/
/* Match the subroutine name against the lists of known libraries and        */
/* interal routines.                                                         */
/* Returns: 1                                                                */
/*          TypFname  - Type of reference, internal, library or unknown.     */
/*          Fname     - Name of routine, standardized in case.               */
procedure expose (DefaultExposeList) Label. CurRoutine TypFname Fname
SubRoutineHistory = 'MatchSubroutine' SubRoutineHistory

line    = arg(1)
stringI = arg(2)

stringI = strip(stringI)
string  = strip(stringI,,'"')
string  = strip(string,,"'")
l1      = length(stringI)
l2      = length(string)

/* If l1\=l2 reference must be BI or external */

TypFname = '"Unknown"' /* This is a default.  It is changed below in most cases. */

/* Do not merge "Label." into "Function.", "Label." carries more information */

/* Try internal routines first. */
if l1=l2 then do i = 1 to Label.0
   v = word(Label.i,3)
   if word(Label.i,2) = 'STRING' then
      v = Fname
   else do/* SYMBOL */
      Fname  = translate(v)
      string = translate(string)
      end

   if string = Fname then do
      /* say 'Reference to label 'Fname' found at line 'SourceIndex.line' in routine "'CurRoutine'"' */
      TypFname = '"Internal"'
      leave i
      end
   end i
   
if TypFname = '"Unknown"' then do i = 1 to FunctionLib.0
   /* Cycle through each function library.  Stored LoadKnownFunctions(). */
   Library = FunctionLib.i 
   Fname = translate(string)
   if Function.Library.Fname = 1 then do
      Library  = strip(Library,'L','_')
      TypFname = '"'Library 'Library"'
      leave i
      end
   end i

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine -  MatchSubroutine:                     -------------*/
/* --------------------------------------------------------------------------*/


Quote: /* Select a quote at random. */
procedure

quote.1 ="Apathy, Apathy, Apathy - Is there no end to the apathy?  I don't care. (Comic strip BC.)"
quote.2 ="Be sure brain is in gear before mouth is engaged."
quote.3 ="Back to the subterranean sodium chloride production facility."
quote.4 ="Sometimes I feel like an idiot studying hard to be a moron, but failing miserably due to stupidity."
quote.5 ="One man's noise is another man's signal. (unknown)"
quote.6 ="This unadulterated piece of miscellaneous machinery!"
quote.7 ="This unadulterated pile miscellaneous muck!"
quote.8 ="There is more than one way to separate the proverbial feline from its epidermal cover."
quote.9 ="Brain Abort! Brain Abort!"
quote.10='"Curioser and curiouser," cried Alice.  (Alice in Wonderland)'

quote.11="No one has ever accused me of subtlety and been able to prove it!"
quote.12="This sorry son of a sap-sucking Siberian sea biscuit."
quote.13="Ooooohhhh muck!"
quote.14="What is it about 'no' that you don't understand? (unknown)"
quote.15="This is more fun and a frontal lobotomy with a chain saw."
quote.16="If it ain't nailed down, they meant you to take it.  If someone accidentally left nails in it, that's why you brought the crowbar."
quote.17="Facts are hard nobbly things, and they care little for our opinions or beliefs."
quote.18='"Trying to make something fool proof is a lost cause.  Fools are so damned ingenious." Joy Aycock 1977' 
quote.19="I am a bad influence on myself."

quote.20="If you aren't confused, you don't understand the situation. (unknown)"
quote.21="'No one is born a cynic.'  The most cynical comment."
quote.22="'An intellectually honest atheist' is an oxymoron."
quote.23="'Cognito ergo oops.' I think therefore I make mistakes."
quote.24="'Non computus mentus.' The computer is out of its ever loving mind!"
quote.25="The simplest can ask questions the wisest can not answer. (unknown)"
quote.26="'He who knows not that he knows not, he is a fool - Shun him' (Arabic saying?)"
quote.27="'He who knows not, and knows that he knows not, he is simple - Teach him' (Arabic saying?)"
quote.28="'He who knows, and knows not that he knows, he is asleep - Wake him' (Arabic saying?)"
quote.29="'He who thinks he knows but he doesn't - is a great fool who has indeed strayed by his own pride and ego.' (Arabic saying?)"

quote.30="Your ignorance does not define my limits and mine should not define yours."
quote.31="That everyone else is making a mistake does not justify my making the same mistake."
quote.32="The brain you have reached is no longer in service.  Should you require assistance, give up."
quote.33="The brain you have reached is in service.  However, it is not sure about yours."
quote.33='"Thar''s gold in them thar hills!"  But you have to know how to find it and mine it.'
quote.34="Ask only questions that can be answered.  Doing this will help you seem smart."
quote.35="If you really want answers ask only questions that can be answered."
quote.36="Absence of data is not data for absence. (unknown)"
quote.37="Never tire of doing what is right. (St. Paul)"
quote.38="Orthogonal inversions!"
quote.39='"All that is needed for the forces of evil to triumph is for enough good men to do nothing." (Edmond Burke)'

quote.40="The problem with knowing what you are doing is that you have deluded yourself. 2/17/94"
quote.41="The difference between genius and stupidity is that genius has limits." '(bumper sticker Picayune MS, approx 1992)'
quote.42="Words are only useful when the recipient comprehends them, otherwise",
         "they are displayed, like plumage, for self gratification. Richard Korejwo 15 May 1994"
quote.43="A goof a day keeps divinity away. And I am in no danger of becoming divine today! 5/18/94"
quote.44="Like so many other things, we have to live with the state of our ignorance. Richard Korejwo 7 Jun 1994"
quote.45="To speak the truth is dangerous; to listen to it is uncomfortable. (Danish Proverb)"
quote.46='"I don''t remember exactly where, but it was rather cool." a motto for the whole Web. Jeffrey C. Ollie & Ade Rixon'
quote.47="Procreate early and often, before they get you! August 5, 1994"
quote.48="Ignorance is not bliss, it is merely the state of the average vegetable. 10/24/94"
quote.49="He who has no access to a resource can not abuse it. 10/25/94"

quote.50="When the truth offends, it is not being heard often enough. 11/02/94"
quote.51="Everyone has the right to go to hell in the manner of their chosing.",
         "Society will work nicely if all would grant this right to not just",
         "themselves but to their neighbors.  2/21/95"
quote.52='"NASA never lets facts stand in the way of progress." Heard at SSL staff meeting August 23, 1995'
quote.53='"The answer is intuitively obvious." IF you already know the answer!'
quote.54='Why is it so many confuse a gift for sarcasm for wisdom?  Nov 2002'
quote.55='"Violence never solved anything." This has got to be one of the most egregiously delusional statements of all time. Dec 10, 2002'
quote.56='Can you repeat his question verbatim?  If not you probably were not paying attention. Dec. 10, 2002'
quote.57='Can you repeat your own question verbatim?  If not you probably were not thinking. Dec 10, 2002'
quote.58="You can't know where you are unless you know where you have been. anon."
quote.59='"Power wants more power."  Jan 15, 2002'

quote.60='"Correlation is not causation."  unknown.'
quote.61='"Drinking water is fatal.  Everyone who does, dies."  So much for correlations.'
quote.62='The only way to guarantee failure is to not try at all.'
quote.63="Grandchildren are a parent's best revenge."
quote.64='"You can't know where you are if you don't know where you have been." unknown'
quote.65='"In a bureaucracy it is easier to get forgiveness than to get permission." Ken Cashion, approx. 1987'
quote.66='"Rocks are just dirt waiting to happen." Barbara Rickman, June 2002'
quote.67='"Models are a way of measuring our ignorance." July 25, 2003'
quote.68='"Illegitimi non carborundum." Don''t let the bastards grind you down. (unknown)'
quote.69="'The trouble with trying to make something foolproof is fools are so damned ingenious!' Melvin Joy Aycock, approx. 1977"

quote.70='"If you can measure that of which you speak, and can express it by a number, you know',
         'something of your subject; but if you can not measure it, your knowledge is meager and',
         'unsatisfactory." William Thompson (Lord Kelvin)'
quote.71='It is amazing how many confuse a gift for sarcasm for wisdom. Jan, 2003'
quote.72='"The average of heterogeneity is homogeneity." Doug Rickman, April 15, 2003'
quote.73='"The first animal species caused the second plant species." April 15, 2003'
quote.74='"First liar doesn''t stand a chance." Heard from Betty Rickman prior 1960.'
quote.75='"Correlation is a weak straw for a model to lean on." Doug Rickman, Sept 2003.'
quote.0=75

rc=random(1,quote.0)
return quote.rc


ReadRawSource: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - ReadRawSource:                        -------------*/
/* Read all lines of program into the array "data.".                         */
procedure expose (DefaultExposeList) data. 
SubRoutineHistory = 'ReadData' SubRoutineHistory

in = arg(1)

do i = 1
   if lines(in) = 0 then
      leave i
   w = linein(in)
   w = strip(w)
   data.i = w
   end
data.0 = i-1

/* For testing */
/* if data.0 > 300 then
   data.0 = 300
*/

rc = stream(in,'c','close')

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - ReadRawSource:                        -------------*/
/* --------------------------------------------------------------------------*/


RebuildALineComment: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - RebuildALineComment:                  -------------*/
/* Apppend "star slash" to each line of a multi-line comment block.  This    */
/* routine assumes that the "slash star" and "star slash" pairs in the       */
/* data., dataEdited1, and dataEdited2. are properly balanced.               */
/* If a line that will have a "star slash" appended ends in "/", a trailing  */
/* space is first added.   This prevents a "slash star slash", which is BAD! */
/* Update the "Data." and "Temp." arrays.   This routine is called by        */
/* MapNMaskCommentsNLiterals() in the process of building "dataEdited.".     */
/* Aug. 14, 2003 DLR Patch for lines ending in "/" within a multiline        */
/*                   comment.                                                */
/* Aug. 22, 2003 DLR Patch for lines starting with "/" within a multiline    */
/*                   comment.                                                */
procedure expose (DefaultExposeList) Data.     Temp. 
SubRoutineHistory = 'RebuildALineComment' SubRoutineHistory

Start = arg(1) /* A decimal encoding of line and character position. */
End   = arg(2) /* A decimal encoding of line and character position. */

SlashStar = '2F2A'x  /* Start of comment block in REXX. */
StarSlash = '2A2F'x  /* End   of comment block in REXX. */

parse var Start StrLine '.' StrChar
parse var End   EndLine '.' EndChar

StrLine = StrLine/1
EndLine = EndLine/1

if lastpos('/',Temp.StrLine) = length(Temp.StrLine) then
   Temp.StrLine = Temp.StrLine || ' '
Temp.StrLine = Temp.StrLine || StarSlash      
Data.StrLine = Temp.StrLine
do j = StrLine+1 to EndLine-1
   if pos('/',Temp.j) = 1 then
      Temp.j = ' ' || Temp.j
   if lastpos('/',Temp.j) = length(Temp.j) then
      Temp.j = Temp.j || ' '
   Temp.j = SlashStar || Temp.j || StarSlash
   Data.j = Temp.j
   end j
if pos('/',Temp.j) = 1 then
   Temp.j = ' ' || Temp.j
Temp.j = SlashStar || Temp.j 
Data.j = Temp.j

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - RebuildALineComment:                  -------------*/
/* --------------------------------------------------------------------------*/


RebuildALineContinuation:
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - RebuildALineContinuation:             -------------*/
/* The specified line in known to end in a continuation.                     */
/* Returns the new lines in "NewLine1.1" and "NewLine2.1" and the number of  */
/* dropped lines in "Dropped".                                               */
procedure expose (DefaultExposeList),
                 data.     dataEdited1. dataEdited2. ,
                 NewLineI. NewLine1.    NewLine2.
SubRoutineHistory = 'RebuildALineContinuation' SubRoutineHistory

line   = arg(1) /* Number of line to start reassembly of continuations. */

k       = 1
Dropped = 0

stringI = data.line
/* string1 = dataEdited1.line */
string2 = dataEdited2.line

do i = line to dataEdited2.0-1
   /* Source can have "," followed by a comment. Move "," to end of line.    */
   CommaAt = lastpos(",",strip(string2))
   parse var stringI vI1 =(CommaAt) +1 vI2
   parse var string2 v21 =(CommaAt) +1 v22
   stringI = vI1 || vI2
   string2 = v21 || v22

   ip1     = i+1
   stringI = stringI data.ip1 
   string2 = string2 dataEdited2.ip1
   Dropped = Dropped + 1
   stringI = strip(stringI)
   string2 = strip(string2)
   if right(string2,1) \= ',' then 
      leave i
   end i

NewLineI.1 = stringI
/* NewLine1.1 = string1 */
NewLine2.1 = string2

parse var SubRoutineHistory . SubRoutineHistory
return 1 Dropped
/* --- end   subroutine - RebuildALineContinuation              -------------*/
/* --------------------------------------------------------------------------*/


RebuildALineSemiColon: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - RebuildALineSemiColon:                -------------*/
/* Break lines at semicolons. Returns the new lines in "NewLine1." and       */
/* NewLine2.".  When called the source line is known to have at least one    */
/* semicolon which requires the line to be subdivided.                       */
procedure expose (DefaultExposeList)                      ,
                 LogicalLineI. LogicalLine1. LogicalLine2.,
                 NewLineI.     NewLine1.     NewLine2.
SubRoutineHistory = 'RebuildALineSemiColon' SubRoutineHistory

line   = arg(1) /* Number of logical line to break at semicolons. */

/* Get position of all semicolons outside of literal strings. */

data = LogicalLine2.line /* No comments and no literals left. */

/* say line data */

nSColon = countstr(';',data)
Start = 1
do j = 1 to nSColon
   posSColon.j = pos(';',data,start)
   start = posSColon.j+1
   end j

dataI = LogicalLineI.line /*  Original source line.        */
/* data1 = LogicalLine1.line  */ /* literals are still present.   */
data2 = LogicalLine2.line /* No comments or literals left. */

k  = 1

p1   = posSColon.1
p1p1 = p1+1
parse var dataI NewLineI.k =(p1) . =(p1p1) stringI
/* parse var data1 NewLine1.k =(p1) . =(p1p1) string1 */
parse var data2 NewLine2.k =(p1) . =(p1p1) string2

do j = 1 to nSColon -1 /* Subdivide using semicolons. */
   p1   = posSColon.j 
   p1p1 = p1+1

   jp1 = j+1
   p2   = posSColon.jp1 
   p2p1 = p2+1

   k = k+1
   parse var dataI . =(p1p1) NewLineI.k =(p2) . =(p2p1) stringI
   /* parse var data1 . =(p1p1) NewLine1.k =(p2) . =(p2p1) string1 */
   parse var data2 . =(p1p1) NewLine2.k =(p2) . =(p2p1) string2

   end j

k = k+1
NewLineI.k = strip(stringI)
/* NewLine1.k = strip(string1) */
NewLine2.k = strip(string2)

NewLineI.0 = k
/* NewLine1.0 = k */
NewLine2.0 = k

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - RebuildALineSemiColon:                -------------*/
/* --------------------------------------------------------------------------*/

SignalAnalysis:
/* --- begin subroutine - :                                     -------------*/
/* Examine usages of SIGNAL and CALL related to condition traps.             */
procedure expose (DefaultExposeList)                          ,
                 FRef.   Label.    SRMap.   SignalFlag

ThisSubroutine    = 'SignalAnalysis'
SubRoutineHistory = ThisSubroutine SubRoutineHistory

mode       = arg(1) /* "CALL"|"SIGNAL"                               */
Line       = arg(2) /* Logical line number.                          */
posStart   = arg(3) /* Character number where CALL or SIGNAL starts. */
data1      = arg(4) /* without comments.                             */
data2      = arg(5) /* without comments and literals.                */ 
CurRoutine = arg(6)

if posStart = 1 then 
   v = ''
else
   v =substr(data2,posStart-1,1) /* Get character in front of CALL. */

/* Two tests to make sure this is a CALL|SIGNAL instruction. */
if datatype(v,'A') then do
   /* This is not a call or a signal. */
   parse var SubRoutineHistory . SubRoutineHistory
   return 2
   end

if v=' ' | v='' then do
   /* This is a call or a signal. */
   /* say 'SIGNAL instruction in line 'Line */
   end
else do
   parse var SubRoutineHistory . SubRoutineHistory
   return 2
   end


/* Get string after CALL|SIGNAL and determine what routine is being referenced*/
if mode = 'CALL' then 
   offset = 5
else 
   offset = 7

string    = substr(data1,posStart+offset)
/* The parse is set up for future use when handling signal control.    */
/*               ON ANY NAME TRAPNAME */
parse var string v1 v2   v3    v4      v5
v1U = translate(v1)
select
   when v1U = 'ON' then do
      txt2 = ' a 'mode
      txt3 = ' is turned ON in line 'SourceIndex.Line'.'
      end
   when v1U = 'OFF' then do
      txt2 = ' a 'mode
      txt3 = 'is turned OFF in line 'SourceIndex.Line'.'
      end
   otherwise do
      txt2 = mode' used in line 'SourceIndex.Line'.'
      txt3 = ''
      end
   end /* select */

/*
v2U = translate(v2)
do i = 1 to Condition.0
   if v2U = Condition.i then do
      nop  /* Future work.  What happens for various conditions. */
      end
   end i 
*/
if SignalFlag = 0 then do
   rc = lineout(out,' ')
   txt = 'List of SIGNALs used'
   rc = lineout(out,txt)
   end


SignalFlag = SignalFlag + 1

do i = 1 to Label.0
   v = word(Label.i,3)
   if word(Label.i,2) = 'STRING' then
      nop
   else do/* SYMBOL */
      v      = translate(v)
      string = translate(string)
      end

   if pos(' 'v' ',string' ') > 0 then do
      v = '_'mode'_INSTRUCTION._'word(Label.i,3)
      SRMap.v = 1
      leave i
      end
   end i
if i < Label.0+1 then do
   txt = 'In subroutine 'CurRoutine txt2 'to label 'word(Label.i,3) txt3
   rc = lineout(out,txt)
   end
else
   txt = 'In subroutine 'CurRoutine txt2 txt3
   rc = lineout(out,txt)

rc = stream(out,c,'close')

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - SignalAnalysis:                       -------------*/
/* --------------------------------------------------------------------------*/

/*

    SIGNALÄÄÂÄlabelnameÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄ;ÄÄÄÄÄÄÄÄ>< 
    ³             ÃÄÂÄÄÄÄÄÄÄÂÄÄexpressionÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´              
    ³             ³ ÀÄVALUE


ÄÄÂÄCALLÄÄÄÂÄÄÂÄOFFÄÄÂÄconditionÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄ;ÄÄ><
  ÀÄSIGNALÄÙ  ³      ÀÄUSERÄÄuserconditionÄÙ                    ³
              ÀÄONÄÄÂÄconditionÄÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÙ
                    ÀÄUSERÄÄuserconditionÄÙ  ÀÄNAMEÄÄtrapnameÄÙ

Note:    If you use CALL, the trapname can be an internal label, a built-in function, or an external routine. If you use SIGNAL, the trapname can be only an internal label. 

*/


SubroutineAnalyzer: 
/* --------------------------------------------------------------------------*/
/* Major variables:                                                          */
/*                                                                           */
/*                                                                           */
/* Created in FindLabels().                                                  */
/*    Label.i         = Line# || Type ("STRING"|"SYMBOL") || FunctionName    */
/*                                                                           */
/* Created in FunctionAnalysis().                                            */
/*    FRef.i.0        = Number of functions referenced in line i.            */
/*    FRef.i._Str.k   = char 1 in name of kth function referenced in line i. */
/*    FRef.i._End.k   = Last char of name of kth function referenced in i.   */
/*    FRef.i._Txt.k   = Text string (name) kth function referenced in line i.*/
/*    FRef.i._Typ.k   = Type of function,  kth function referenced in line i.*/
/*    FRef.i._Open.k  = Postion of "(" for kth function referenced in line i.*/
/*    FRef.i._Close.k = Postion of ")" for kth function referenced in line i.*/
/*    FRef.i._Knd.k   = Nature of reference, subroutine call or function.    */
procedure expose (DefaultExposeList),
                 LogicalLineI.  LogicalLine1.    LogicalLine2.,
                 Label.         FRef.            SRMap.       

ThisSubroutine    = 'SubRoutineAnalyzer'
SubRoutineHistory = ThisSubroutine SubRoutineHistory

in = arg(1)

/* Initiallize Called., find the max length of a subroutine name, and check  */
/* if routine is target of a signal instruction.                             */
MaxL=0
do i = 1 to Label.0
   Called.i = 0
   parse var Label.i Line . FunctionName1
   MaxL = max(MaxL,length(FunctionName1))
   /* To dump all Label. index, source line number and function names turn on*/
   /* say right(i,3) right(SourceIndex.Line,5,'0') FunctionName1             */

   v = '_'CALL'_INSTRUCTION._'FunctionName1   
   if SRMap.v = 1 then     
      Called.i = 1
   v = '_'SIGNAL'_INSTRUCTION._'FunctionName1   
   if SRMap.v = 1 then    
      Called.i = 1
   end i

/* Mark the routines that are referenced. */
do i = 1 to Label.0
   parse var Label.i LineN1 Type FunctionName1
   do j = 1 to Label.0
      parse var Label.j Line Type FunctionName2
      v = '_'FunctionName1'._'FunctionName2
      if SRMap.v = 1 then
         Called.j = 1
      end j
   end i

/* Is each subroutine referenced at least once? */
MaxL = max(MaxL,length('ROUTINE'))
rc  = lineout(out,' ')
txt = 'Routines Never Explictily Referenced'
rc  = lineout(out,txt)
Flag = 0

do i = 2 to Label.0
   if Label._Duplicate.i = 1 then /* A duplicate label.  Ignore it. */
      iterate i
   if Called.i = 0 then do
      if Flag = 0 then do 
         /* Write the header line. */
         txt = ' Line ' left('ROUTINE',MaxL)
         rc  = lineout(out,txt)
         end
      parse var Label.i LineN1 Type FunctionName1
      txt = right(SourceIndex.LineN1,6,'0') left(FunctionName1,MaxL)
      rc  = lineout(out,txt)
      Flag = 1
      end
   end i
if Flag = 0 then do
   txt ='All internal routines are explicitly referenced at least once.'
   rc  = lineout(out,txt)
   end


/* Check for self recursion. */
filename = FileSpec('NAME',in)
parse var filename filename '.' .
filename = translate(filename)
do i = 1 to LogicalLineI.0
   do k = 1 to FRef.i.0
      if translate(FRef.i._Txt.k)=filename  & FRef.i._Typ.k = '"Unknown"' then do
         rc  = lineout(out,' ')
         txt = 'WARNING: The program is recursive.'
         rc  = lineout(out,txt)
         end
      end k
   end i
    

/* Write tables showing paths through routines. */
MaxL = max(MaxL,length('WAS CALLED BY'))

/* Table 1: Which internal subroutines are called by each routine. */
rc  = lineout(out,' ')
txt = center('Subroutine Reference Map 1:',2*MaxL+1,' ')
rc  = lineout(out,txt)
txt = center('ROUTINE',MaxL)' - 'center('CALLED',MaxL)
rc  = lineout(out,txt)
txt = left('_',MaxL,'_')'   'left('_',MaxL,'_')
rc  = lineout(out,txt)
Flag = 0 
do i = 1 to Label.0
   if Label._Duplicate.i = 1 then /* A duplicate label.  Ignore it. */
      iterate i
   parse var Label.i LineN1 Type FunctionName1
   do j = 1 to Label.0 /* Must use j=1 as recursion is possible. */
      if Label._Duplicate.j = 1 then /* A duplicate label.  Ignore it. */
         iterate j
      parse var Label.j Line Type FunctionName2
      v = '_'FunctionName1'._'FunctionName2
      if SRMap.v = 1 then do
         if Flag = 1 then 
            txt = left(' ',MaxL)' - 'FunctionName2
         else 
            txt = left(FunctionName1,MaxL)' - 'FunctionName2
         rc   = lineout(out,txt)
         Flag = 1
         end
      end j
   if Flag = 1 then do
      txt = center('.',MaxL,'.')'   'center('.',MaxL,'.')
      rc  = lineout(out,txt)
      Flag = 0
      end
   end i


/* Table 2: Which routines are called by each subroutine. */
rc  = lineout(out,' ')
txt = center('Subroutine Reference Map 2:',2*MaxL+1,' ')
rc  = lineout(out,txt)
txt = center('ROUTINE',MaxL)' - 'center('WAS CALLED BY',MaxL)
rc  = lineout(out,txt)
txt = left('_',MaxL,'_')'   'left('_',MaxL,'_')
rc  = lineout(out,txt)
Flag = 0 
do i = 1 to Label.0
   if Label._Duplicate.i = 1 then /* A duplicate label.  Ignore it. */
      iterate i
   parse var Label.i LineN1 Type FunctionName1
   do j = 1 to Label.0 /* Must use j=1 as recursion is possible. */
      if Label._Duplicate.j = 1 then /* A duplicate label.  Ignore it. */
         iterate j
      parse var Label.j Line Type FunctionName2
      v = '_'FunctionName2'._'FunctionName1
      if SRMap.v = 1 then do
         if Flag = 1 then 
            txt = left(' ',MaxL)' - 'FunctionName2
         else 
            txt = left(FunctionName1,MaxL)' - 'FunctionName2
         rc   = lineout(out,txt)
         Flag = 1
         end
      end j
   if Flag = 1 then do
      txt  = center('.',MaxL,'.')'   'center('.',MaxL,'.')
      rc   = lineout(out,txt)
      Flag = 0
      end
   end i

rc = stream(out,c,'close')

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - SubRoutineAnalyzer:                   -------------*/
/* --------------------------------------------------------------------------*/


TabulateCommentsNQuotes: 
/* --------------------------------------------------------------------------*/
/* --- begin subroutine - TabulateCommentsNQuotes:              -------------*/
/* Input data are assumed to be in the array "Temp.".                        */
/* Information is returned in the array "Temp1."                             */
/* Temp1. format: Line_in_Temp._array "." Character_in_line  Flag            */
/*       Example: "000004.000076 -1".                                        */
/* "Character_in_line" is the first character of the string.                 */
/* "Flag" =  1 - a "slash-star" combination.                                 */
/*        = -1 - a "star-slash" combination.                                 */
/*        =  S - a single quote.                                             */
/*        =  D - a double quote.                                             */
/* Before return values in Temp1. are sorted by line and character.          */
procedure expose (DefaultExposeList)                          ,
                 Temp.          Temp1.
SubRoutineHistory = 'TabulateCommentsNQuotes' SubRoutineHistory

mode = arg(1) /* COMMENTS | QUOTES | BOTH                                    */

Numeric Digits 13

/* Tabluate all Start of Comments. Comment starts are given a value of 1.    */
/* Encode line and character position as decimal number. The line number is  */
/* before the decimal, character position is after the decimal.  There can   */
/* be 999,999 lines and 999,999 characters per line.                         */

SlashStar = '2F2A'x  /* Start of comment block in REXX. */
StarSlash = '2A2F'x  /* End   of comment block in REXX. */

drop Temp1.

/* Start building table, "Temp1.". */
if mode = "COMMENTS" | mode = "BOTH" then do

   k = 0
   /* Tabulate all comment starts and ends. Comment starts are given a value of  1.*/
   do i = 1 to Temp.0
      Start = 1
      do j = 1
         posStrs = pos(SlashStar,Temp.i,Start)
         posStre = pos(StarSlash,Temp.i,Start)
         select 
            when posStrs=0 & posStre=0 then
               /* Neither comment begin or end. */
               leave j
            
            /* To get here a comment begin or end must exist. */
            
            when posStre = 0 then do
               /* To get here a begin comment must exist by itself. */
               k = k+1
               Temp1.k = right(i,6,'0') ||'.' || right(posStrs,6,'0') '1'
               Start = posStrs + 2
               iterate j
               end
            
            when posStrs = 0 then do
               /* To get here a comment end must exist by itself.   */
               k = k+1
               Temp1.k = right(i,6,'0') ||'.' || right(posStre,6,'0') '-1'
               Start = posStre + 2
               iterate j
               end

            /* To get here both begin and end comments may exist. */
               
            when posStrs < posStre then do
            /* To get here a begin comment found before a possible end comment. */
               k = k+1
               Temp1.k = right(i,6,'0') ||'.' || right(posStrs,6,'0') '1'
               Start = posStrs + 2
               iterate j
               end

            otherwise do
               /* To get here a comment end must come before a possible begin. */
               k = k+1
               Temp1.k = right(i,6,'0') ||'.' || right(posStre,6,'0') '-1'
               Start = posStre + 2
               iterate j
               end
            end /* select */
         end j
      end i
   end /* if mode = "COMMENTS" | mode = 'BOTH" then ... */

if mode = "QUOTES" | mode = "BOTH" then do
   /* Tabulate all single quotes.  Store in array "Temp1." with "S". */
   do i = 1 to Temp.0
      Start = 1
      nSQ = countstr("'",Temp.i)
      do j = 1 to nSQ
         posSQ = pos("'",Temp.i,Start)
         k = k+1
         temp1.k = right(i,6,'0') ||'.' || right(posSQ,6,'0') 'S'
         Start = posSQ + 1
         end j
      end i

   /* Tabulate all double quotes.  Store in array "Temp1." with "D". */
   do i = 1 to Temp.0
      Start = 1
      nDQ = countstr('"',Temp.i)
      do j = 1 to nDQ
         posDQ = pos('"',Temp.i,Start)
         k = k+1
         Temp1.k = right(i,6,'0') ||'.' || right(posDQ,6,'0') 'D'
         Start = posDQ + 1
         end j
      end i
   end /* if mode = "QUOTES" | mode = "BOTH" then ... */ 

Temp1.0 = k

if k>0 then do /* Patched August 14, 2003 for k=0. DLR */
   /* Sort the table by line.character. */
   /* rc = arraysort(Temp1., , , ,13, ,'N') */ /* REXXLIB version */
   rc = SysStemSort(Temp1. ,  , , , , 1, 13 ) 
   end

/* To dump contents of Temp1. array turn the following line on.              */
/* do i = 1 to Temp1.0 ; say right(i,3) Temp1.i ; end i                      */

parse var SubRoutineHistory . SubRoutineHistory
return 1
/* --- end   subroutine - TabulateCommentsNQuotes:              -------------*/
/* --------------------------------------------------------------------------*/


Test4CountStr:
/* Does the builtin function COUNTSTR( ) exist.  Returns 1 if it does.       */
/* Install a temporary error handler. The previous error handler is          */
/* automatically restored a the end of the routine                           */ 
procedure
SIGNAL ON SYNTAX NAME Test4CountStrError 
OK = 0 
OK = countstr('a','abc')
Test4CountStrError: 
return OK
/* --- end   subroutine - Test4CountStr:                        -------------*/
/* --------------------------------------------------------------------------*/


Test4SysStemSort:
/* Does the builtin function SysStemSort( ) exist.  Returns 1 if it does.       */
/* Install a temporary error handler. The previous error handler is          */
/* automatically restored a the end of the routine                           */ 
procedure
SIGNAL ON SYNTAX NAME Test4SysStemSortError
OK = 0
a.0 = 1
a.1 = a 
OK = SysStemSort('a.')
if OK=0 then
   OK = 1
Test4SysStemSortError: 
return OK
/* --- end   subroutine - Test4CountStr:                        -------------*/
/* --------------------------------------------------------------------------*/


WriteFRefTable:
/* --------------------------------------------------------------------------*/
/* --- begin WriteFRefTable:                                    -------------*/
procedure expose (DefaultExposeList) LogicalLineI. FRef. 

ThisSubroutine    = 'WriteFRefTable'
SubRoutineHistory = ThisSubroutine SubRoutineHistory


/* Debugging aid and illustration of how to use FRef variables.              */
MaxL = 4
MaxM = 8
MaxN = 1
do i = 1 to LogicalLineI.0
   do k = 1 to FRef.i.0
      MaxL = max(MaxL,length(FRef.i._Txt.k))
      MaxM = max(MaxM,length(FRef.i._Typ.k))
      /* say right(MaxM,3) right(length(FRef.i._Typ.k),3) FRef.i._Typ.k */
      end k
   MaxN = max(MaxN,FRef.i.0)
   end i
string = 'Ref_Type Beg End 'left(Name,MaxL) left(Source,MaxM)' BegA EndA'
txt1    = string
do i = 2 to MaxN
   txt1 = txt1 '|' string 
   end i

rc  = lineout(out,' ')
txt = 'All Recognized Function and Subroutine References'
rc  = lineout(out,txt)
txt = ' Line 'txt1
rc  = lineout(out,txt)

do i = 1 to LogicalLineI.0
   if FRef.i.0 > 0 then do
      txt = right(SourceIndex.i,5,'0')
      do k = 1 to FRef.i.0
         if FRef.i._Typ.k = '"Unknown"' then iterate k /* Turn this off to show ALL references!*/
         txt = txt right(FRef.i._Knd.k,8)   /* CALL or FUNCTION                                */
         txt = txt right(FRef.i._Str.k,3)   /* Start position of func name.                    */
         txt = txt right(FRef.i._End.k,3)   /* End   position of func name.                    */
         txt = txt left(FRef.i._Txt.k,MaxL) /* Function name, with quotes if literal.          */
         txt = txt left(FRef.i._Typ.k,MaxM) /* Type, library, internal, etc. in double quotes. */
         txt = txt right(FRef.i._Open.k,4)  /* Start positon of arguments.                     */
         txt = txt right(FRef.i._Close.k,4) /* End position of arguments.                      */
         txt = txt '|'
         end k
      if length(txt) = 5 then iterate i
      rc = lineout(out,txt)
      end /* if ... */
   end i

rc  = lineout(out,' ')
txt = 'All Unrecognized Function and Subroutine References'
rc  = lineout(out,txt)
txt = ' Line 'txt1
rc  = lineout(out,txt)

do i = 1 to LogicalLineI.0
   if FRef.i.0 > 0 then do
      txt = right(SourceIndex.i,5,'0')
      do k = 1 to FRef.i.0
         if FRef.i._Typ.k \= '"Unknown"' then iterate k 
         txt = txt right(FRef.i._Knd.k,8)   /* CALL or FUNCTION                                */
         txt = txt right(FRef.i._Str.k,3)   /* Start position of func name.                    */
         txt = txt right(FRef.i._End.k,3)   /* End   position of func name.                    */
         txt = txt left(FRef.i._Txt.k,MaxL) /* Function name, with quotes if literal.          */
         txt = txt left(FRef.i._Typ.k,MaxM) /* Type, library, internal, etc. in double quotes. */
         txt = txt right(FRef.i._Open.k,4)  /* Start positon of arguments.                     */
         txt = txt right(FRef.i._Close.k,4) /* End position of arguments.                      */
         txt = txt '|'
         end k
      if length(txt) = 5 then iterate i
      rc = lineout(out,txt)
      end /* if ... */
   end i
rc = stream(out,c,'close')

parse var SubRoutineHistory . SubRoutineHistory
return 1