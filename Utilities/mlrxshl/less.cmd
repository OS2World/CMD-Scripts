/* less.cmd 951116 */
trace off; call on error; '@echo off'

call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call SysLoadFuncs
parse value SysTextScreenSize() 1 1 1 1 'stdin: = <>' '08'x '0d'x arg() arg(1) with r c m d l n t.1 E H B G f A

if f then m = 0
do _ = 1 to words(A)
   call SysFileTree word(A,_),p,OF; do z = 1 to p.0; m = m+1; t.m = p.z; end;
end
if m = 0 then do; say SysGetMessage(2); exit 1; end

main:
file = t.n; call seek l
signal on syntax
do forever
   if \ in(E||G) then do; call SysCurPos 0,0; do r-1; call emit; end; end
   if \ in(E) then call out ':'word(EOF,1+lines(file))

   key = SysGetKey(); if in('00E0'x) then key = translate(SysGetKey(NOECHO),B'1b'x' NP'H,'I=Q†…KM')
   select
      when in(E) then call out B'    <'file' line='l' col='d' pos='exc(SEEK)'/'exc(QUERY SIZE)' file 'n' of 'm'>'
      when in(' ') then l = l+r-1
      when in(B'.') then call seek l-(r-1)*(key = B)
      when in('/') then do; call exc CLOSE; s = cmdin(); if s = '' then i = i+1; else do; call SysFileSearch s,file,p.,'n'; i = 1; end; call seek word(p.i,1); end
      when in(H) then do; d = max(1,d+20*(c2d(key)-61)); call seek l; end
      when in(NP) then do; call exc CLOSE; d = 1; l = 1; n = max(1,min(m,n+79-c2d(key))); signal main; end
      when in(G) then do; call emit; l = l+1; end
      when in('1b'x) then do; call out; call SysCurPos r-2,0; exit; end
      when in(123456789) then call seek cmdin(key)
      when in('+-') then call seek l+cmdin(key)
   otherwise
      interpret cmdin(key); key = G
   end
end

in:
   return pos(key,arg(1)) > 0

exc:
   return stream(file,'c',arg(1))

cmdin:
   return arg(1)linein('con:')

out:
   call charout ,left(arg(1),c-3)
   return SysCurPos(r-1,1)

emit:
   return charout(,left(substr(translate(linein(file),' þú',B'0709'x),d),c))

seek:
   if f then do; l = max(arg(1),1); call linein file,1,0; do l-1; call linein file; end; end
error:
   return

syntax:
   key = E; call charout ,':'
   signal main
