/* EXAMPLE1

   Uses CmdLine() to make a simple OS/2 command line emulator. 
*/

do forever
   Call Charout, "["directory()"]"
   CmdLine()
end
return
/* BEGINNING OF CmdLine CODE BY ALBERT CROSBY */
/*
       CmdLine.CMD Version 1.0
       (c) 1994 by Albert Crosby <acrosby@comp.uark.edu>

       This code may be distributed freely and used in other programs.
       Please give credit where credit is due.

       CmdLine.CMD is REXX code that creates a full featured version
       of the OS/2 command line parser that may be called from your
       programs.
*/

/* This is a CmdLine function for REXX.  It supports:
       *       OS/2 style command history. (1)
       *       Keeps insert state. (1)
       *       Command line _can_ include control chars.
       *       Allows for "hidden" input, for passwords.
       *       A call can be restricted from accessing the history.
       *       A call can be restricted from updating the history.
       *       A predefined value can be given to extended keys. (1) (2)

   NOTE:
       (1) These functions work ONLY if CmdLine is included in the source
           file for your program. 
       (2) Format: !history.nn="string" where nn is the DECIMAL value for
           the second character returned when the extended key is pressed.
*/

/* The following two lines are used in case CmdLine is called as an 
   external function */

parse source . . name
if translate(filespec("name",name))="CMDLINE.CMD" then signal extproc

CmdLine: procedure expose !history.
extproc: /* CmdLine called as an external proc or command line */

/* Parameters can be any combination of:
   Hidden : Characters are displayed as "*", no history, not kept.
   Forget : Do not add the result of this call to the history list.
   No History : Do not allow access to the history list.
   Clear : Clear the history list with this call (no input action made.)
           Also clears any predefined keys!
   Insert : Set insert mode ON.
   Overwrite : Set overwrite mode OFF.
   SameLine : Keep cursor on sameline after input. (Default: off)
   Required : null values are not accepted. (Default: off)7
   Valid : Next parameter specifies the valid charachters (no translation)
           unless specified elsewhere. (1)
   Upper : Translate input to upper case. (1)
   Lower : Translate input to lower case. (1)
   Width : Next parameter specifies the maximum width. (1)
   Autoskip : Do not wait for enter after last char on a field with a width.
   X : Next parameter specifies the initial X (column) position.
   Y : Next parameter specifies the initial Y (row) position.
   Prompt : Displays the next parameter as a prompt in front of the
            entry field.
   

   Only the first letter matters.  Enter each desired parameter seperated
   by commas.

   NOTES:
      (1)  Upper, Lower, Width, and VALID preclude access to the history 
           list.
*/

hidden=0
history=1
keep=1
sameline=0
required=0
reset=0
valid=xrange()
upper=0
lower=0
width=0
autoskip=0
parse value SysCurPos() with x y
do i=1 to arg()
   cmd=translate(left(arg(i),1))
   parm=""
   if pos("=",arg(i))\=0 then
      parse value arg(i) with ."="parm
   select
      when cmd="X" then
         do
         parse value SysCurPos() with x y
         if parm="" then
            do;i=i+1;parm=arg(i);end
         if datatype(parm,"W") then
            Call SysCurPos parm,y
         end
      when cmd="Y" then
         do
         parse value SysCurPos() with x y
         if parm="" then
            do;i=i+1;parm=arg(i);end
         if datatype(parm,"W") then
            Call SysCurPos x,parm
         end
      when cmd="T" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         call charout, parm
         end
      when cmd="H" then
         do
         hidden=1
         keep=0
         history=0
         end
      when cmd="C" then
         reset=1
      when cmd="O" then
         !history.insert=0
      /**/
say center("Data Entry Screen",80,"-")
id=CmdLine("X=2","Y=60","Tag=ID: ","W=4","Valid=1234567890","R")
operator=CmdLine("X=3","Y=48","Tag=Entry Operator: ","W=3","U","V="xrange("A","Z"),"R")
say center("Personal Info",80,"-")
sex=CmdLine("X=5","Y=0","Tag=Respondent's Sex: ","W=1","U","V=MF","R")
married=CmdLine("X=5","Y=30","Tag=Marital Status: ","W=1","V=MSDW","U")
r.age=CmdLine("X=6","Y=5","Tag=Respondent's Age: ","W=3","V=1234567890")
say
say "Educationa Level:"
say "   1=Some HS, 2=HS Grad, 3=Some Coll., 4=AS, 5=BS, 6=MS, 7=PhD, 8=+"
r.ed=CmdLine("X=7", "Y=4","Tag=Educational Level: ","W=2","V=12345678")
if married="M" then
   do
   s.age=CmdLine("X=6","Y=36","T=Spouse's Age: ","W=3","V=1234567890")
   s.ed=CmdLine("X=7", "Y=31","Tag=Educational Level: ","W=1","V=12345678")
   end
call Charout, copies("-",80)
call Charout, copies(" ",80)
income=CmdLine("X=9","Y=0","Tag=Family Income: $","W=6","V=1234567890")
ownhome=CmdLine("X=9","Y=40","T=Own your own home? ","W=1","V=YN","U")
famsize=CmdLine("X=10","Y=0","T=Size of household: ","W=2","V=1234567890")
malesunder18=0
femalesunder18=0
if famsize>1 then
   do
   malesunder18=CmdLine("X=10","Y=25","T=Males under 18: ","W=2","V=1234567890")
   femalesunder18=CmdLine("X=10","Y=55","T=Females under 18: ","W=2","V=1234567890")
   end
say center("Video Game Ownership",80,"-")
videogame=CmdLine("X=12","Y=0","T=Does your family own a video game system? ",,
               "W=1","U","V=YN")
if videogame="Y" then
   do
   say 
   say "  1=SEGA Genesis, 2=SEGA, 3=NES, 4=Super NES, 5=ATARI, 6=3DO, 7=OTHER"
   gametype=CmdLine("X=13","Y=5","T=Kind of System: ","W=1","V=1234567")
   if gametype=7 then
      gameother=CmdLine("X=13","Y=40","T=Description: ","W=25","U")
   Call Charout, copies(" ",80)
   say "   How many hours per week is it used by: "
   usage.r=CmdLine("T=You: ","W=2","V=1234567890","S")
   if married="M" then
      usage.s=CmdLine("Y=10","T=Spouse: ","W=2","V=1234567890","S")
   if malesunder18>0 then
      usage.s=CmdLine("Y=22","T=Males Under 18: ","W=3","V=1234567890","S")
   if femalesunder18>0 then
      usage.s=CmdLine("Y=42","T=Females Under 18: ","W=3","V=1234567890","S")
   usage.other=CmdLine("Y=65","T=Guests: ","W=3","V=1234567890","S")
   end
           �               �     �     �     �     �     �     �     �     �     �     �     �     �     �     �     �     �     �  C   �     8     3     .     =  
   8     :     3     /     7     6     4     -     (     4     /     +     8     1     ;     G     S  ,   O     s     o  E   h     �     �  	   �     �     �     �     �  .centerData Entry Screen80-CmdLineX=2Y=60Tag=ID: W=4Valid=1234567890RX=3Y=48Tag=Entry Operator: W=3UV=xrangeAZPersonal InfoX=5Y=0Tag=Respondent's Sex: W=1V=MFY=30Tag=Marital Status: V=MSDWX=6Y=5Tag=Respondent's Age: V=1234567890Educationa Level:   1=Some HS, 2=HS Grad, 3=Some Coll., 4=AS, 5=BS, 6=MS, 7=PhD, 8=+X=7Y=4Tag=Educational Level: W=2V=12345678MY=36T=Spouse's Age: Charoutcopies X=9Tag=Family Income: $W=6X=10T=Size of household: 1T=Males under 18: T=Females under 18: Video Game OwnershipX=12T=Does your family own a video game system? V=YNY  1=SEGA Genesis, 2=SEGA, 3=NES, 4=Super NES, 5=ATARI, 6=3DO, 7=OTHERX=13T=Kind of System: V=12345677Y=40T=Description: W=25 REXX.VARIABLEBUF         �      �      �      �      ~      ~      y      x      r      m      g      a      _      ^      b   	   h      i   	   i   rcsiglresultidoperatorsexmarriedr.ageeds.incomefamsizemalesunder18femalesunder18videogamegametypegameother 	REXX.TOKENSIMAGE     �     &              
    o    ] 
   �    X    g    �    `    �    g    �    �    \    o    ]     �    X    g    � 	   g    � 
   g    �    g    �    g    �    g    �    �    \    o    ]     �    X    g    �    g    �    g    �    g    �    g    �    g    @    o    ] N   �    X    g    �    g    �    �    g    � when cmd="I" then
         !history.insert=1
      when cmd="F" then
         keep=0
      when cmd="S" then
         sameline=1
      when cmd="R" then
         required=1
      when cmd="V" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         valid=parm
         history=0
         keep=0
         end
      when cmd="U" then
         do; upper=1; lower=0; history=0; keep=0; end
      when cmd="L" then
         do; upper=0; lower=1; history=0; keep=0; end
      when cmd="A" then
         autoskip=1
      when cmd="W" then
         do
         if parm="" then
            do;i=i+1;parm=arg(i);end
         width=parm
         if \datatype(width,"Whole") then width=0
         if width<0 then width=0
         history=0
         keep=0
         end
    otherwise nop
    end
end

if width=0 then autoskip=0

if reset then
   do
   drop !history.
   return ""
   end

if symbol("!history.0")="LIT" then
   !history.0=0
if symbol("!history.insert")="LIT" then
   !history.insert=1

historical=-1
key=SysGetKey("NoEcho")
word=""
pos=0
do forever /* while key\=d2c(13)*/
   if key=d2c(13) then /* Enter key */
      if required & word="" then nop;
      else leave
   else if (key=d2c(8)) then /* Backspace */
      do
      if length(word)>0 then
      do
      word=delstr(word,pos,1)
      call rubout 1
      pos=pos-1
      if pos<length(word) then
         do
         if \hidden then call charout, substr(word,pos+1)||" "
         else call charout, copies("*",length(substr(word,pos+1)))||" "
         call charout, copies(d2c(8),length(word)-pos+1)
         end
      end
      end
   else if key=d2c(27) then /* Escape */
      do
      if pos<length(word) then
         if \hidden then call charout, substr(word,pos+1)
         else call charout, copies("*",length(substr(word,pos+1)))
      call rubout length(word)
      word=""
      pos=0
      end
   else if key=d2c(10) | key=d2c(9) then /* Ctrl-Enter and TAB */
      nop; /* Ignored */
   else if key=d2c(224) | key=d2c(0) then /* Extended key handler */
      do
      key2=SysGetKey("NoEcho")
      select
         when key2=d2c(59) then /* F1 */
            if (history) & (!history.0<>0) then
               do
               if symbol('search')='LIT' then
                  search=word
               if symbol('LastFind')='LIT' then
                  search=word
               else if LastFind\=word
                  then search=word
               if historical=-1 then
                  start=!history.0
               else start=historical-1
               if start=0 then start=!history.0
               found=0
               do i=start to 1 by -1
                  if abbrev(!history.i,search) then
                     do
                     found=1
                     historical=i
                     LastFind=!history.i
                     leave
                     end
               end
               if found then
                  do
                  if pos<length(word) then
                     if \hidden then call charout, substr(word,pos+1)
                     else call charout, copies("*",length(substr(word,pos+1)))
                  call rubout length(word)
                  word=!history.historical
                  pos=length(word)
                  if \hidden then call charout, word
                  else call charout, copies("*",length(word))
                  end
               end
         when key2=d2c(72) then /* Up arrow */
            if (history) & (!history.0<>0) then
               do
               if historical=-1 then
                  historical=!history.0
               else historical=historical-1
               if historical=0 then
                  historical=!history.0
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=!history.historical
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
               end
         when key2=d2c(80) then /* Down arrow */
            if (history) & (!history.0<>0) then
               do
               if historical=-1 then
                  historical=1
               else historical=historical+1
               if historical>!history.0 then
                  historical=1
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=!history.historical
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
               end
         when key2=d2c(75) then /* Left arrow */
            if pos>0 then
               do
               call Charout, d2c(8)
               pos=pos-1
               end
         when key2=d2c(77) then /* Right arrow */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1,1)
               else call charout, "*"
               pos=pos+1
               end
         when key2=d2c(115) then /* Ctrl-Left arrow */
            if pos>0 then
               do
               call charout, d2c(8)
               pos=pos-1
               do forever
                  if pos=0 then leave
                  if substr(word,pos+1,1)\==" " & substr(word,pos,1)==" " then
                        leave
                  else
                     do
                     call charout, d2c(8)
                     pos=pos-1
                     end
               end
               end
         when key2=d2c(116) then /* Ctrl-Right arrow */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1,1)
               else call charout, "*"
               pos=pos+1
               do forever
                  if pos=length(word) then
                     leave
                  if subst