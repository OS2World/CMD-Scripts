/* EXAMPLE2

   A Unix-ish prompt with CmdLine()
*/
"@echo off"

!history.0=0
do forever
   Call Charout, "%"!history.0+1" "
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
      when cmd="I" then
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
                  if substr(word,pos,1)==" " & substr(word,pos+1,1)\==" " then
                     leave
                  else
                     do
                     if \hidden then call Charout, substr(word,pos+1,1)
                     else call charout, "*"
                     pos=pos+1
                     end
               end
               end
         when key2=d2c(83) then /* Delete key */
            if pos<length(word) then
               do
               word=delstr(word,pos+1,1)
               if \hidden then call Charout, substr(word,pos+1)||" "
               else call Charout, copies("*",length(substr(word,pos+1)))||" "
               call charout, copies(d2c(8),length(word)-pos+1)
               end
         when key2=d2c(82) then /* Insert key */
            !history.insert=\!history.insert
         when key2=d2c(79) then /* End key */
            if pos<length(word) then
               do
               if \hidden then call Charout, substr(word,pos+1)
               else call Charout, copies("*",length(substr(word,pos+1)))
               pos=length(word)
               end
         when key2=d2c(71) then /* Home key */
            if pos\=0 then
               do
               call Charout, copies(d2c(8),pos)
               pos=0
               end
         when key2=d2c(117) then /* Control-End key */
            if pos<length(word) then
               do
               call Charout, copies(" ",length(word)-pos)
               call Charout, copies(d2c(8),length(word)-pos)
               word=left(word,pos)
               end
         when key2=d2c(119) then /* Control-Home key */
            if pos>0 then
               do
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               word=substr(word,pos+1)
               if \hidden then call Charout, word
               else call Charout, copies("*",length(word))
               call Charout, copies(d2c(8),length(word))
               pos=0
               end
      otherwise 
         if history & symbol('!history.key.'||c2d(key2))\='LIT' then /* Is there a defined string? */
            do
               if pos<length(word) then
                  if \hidden then call charout, substr(word,pos+1)
                  else call charout, copies("*",length(substr(word,pos+1)))
               call rubout length(word)
               i=c2d(key2)
               word=!history.key.i
               pos=length(word)
               if \hidden then call charout, word
               else call charout, copies("*",length(word))
            end
      end
      end
   else if width=0 | length(word)<width then /* The key is a normal key & within width */
      do
      if upper then key=translate(key);
      if lower then key=translate(key,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
      if pos(key,valid)\=0 then
         do;
         if \hidden then call Charout, key;
         else call charout, "*"
         if !history.insert then
            word=insert(key,word,pos);
         else word=overlay(key,word,pos+1)
         pos=pos+1; 
         if pos<length(word) then
            do
            if \hidden then 
               call Charout, substr(word,pos+1)
            else call Charout, copies("*", length(substr(word,pos+1)))
            call Charout, copies(d2c(8),length(word)-pos)
            end
         end
      else beep(400,4)
      end
   if autoskip & length(word)=width then leave
   key=SysGetKey("NoEcho")
end
if \sameline then say
if (keep) & (word\=="") then
   do
   historical=!history.0
   if word\=!history.historical then
      do
      !history.0=!history.0+1
      historical=!history.0
      !history.historical=word
      end
   end
return word

rubout: procedure
arg n
do i=1 to n
   call Charout, d2c(8)||" "||d2c(8)
end
return
/* END OF CmdLine CODE BY ALBERT CROSBY */
