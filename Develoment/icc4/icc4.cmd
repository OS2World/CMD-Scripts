/*************************************************************************

 $Author: root $
 $Date: 2001/03/01 12:32:43 $
 $Id: icc4.cmd,v 1.14 2001/03/01 12:32:43 root Exp $
 $Log: icc4.cmd,v $
 Revision 1.14  2001/03/01 12:32:43  root
 *** empty log message ***

 Revision 1.13  2001/01/31 12:54:10  root
 *** empty log message ***

 Revision 1.3  2000/08/21 11:28:03  tyano
 *** empty log message ***

 Revision 1.2  2000/08/20 12:56:45  tyano
 *** empty log message ***

 Revision 1.1.1.1  2000/08/20 03:05:18  tyano
 VAC++ 4.0 vacbld frontend like ICC

 $Revision: 1.14 $
 $Name:  $

*************************************************************************/
signal on novalue name error
if RxFuncQuery('SYSLOADFUNCS') then do
   call RxFuncAdd 'SYSLOADFUNCS', 'REXXUTIL', 'SYSLOADFUNCS'
   call SysLoadFuncs
end /* do */
if arg() = 0 then exit 4
!.alias = ''
!.bin = ''
!.call = 'optlink'
!.dbgunref = 0
!.debug = 0
!.dname = ''
!.dump = 0
!.enumsize = ''
!.exepack = ''
!.extlen = ''
!.fastfloat = 0
!.fastint = 0
!.gendll = 0
!.hidedeflib = 0
!.ignerrno = 0
!.ignprag = ''
!.initauto = ''
!.isocall = ''
!.libansi = 0
!.libdll = 0
!.longlong = 0
!.map = ''
!.mode = 'EXE'
!.mtlib = 1
!.nodigraph = 0
!.noro = 0
!.obj = ''
!.optchain = 0
!.optfunc = 0
!.optinline = 0
!.optlevel = ''
!.optsched = 0
!.optsize = 0
!.optstack = 0
!.pack = ''
!.parmdw = 0
!.pm = 'VIO'
!.profile = 0
!.remexcep = 0
!.remstackprob = 0
!.remunref = 0
!.report = ''
!.ring0 = 0
!.rtti = ''
!.signed = 0
!.signedbf = 0
!.stalone = 0
!.stack = ''
!.tiled = 0
!.tname = ''
!.tune = ''
!.verstr = ''
!.xname = ''
a = ' ' || arg(1)
defs.0 = 0
undefs.0 = 0
!.showprogress = 0
!.codestore = value('tmp', , 'os2environment') || '\icc4.ics'
!.clean = 0
incl.0 = 1
incl.1 = translate(directory(), '/', '\')
do forever
   parse var a b ' -' o a
   if o = '' then leave
   select
      when o = 'CLEANCODESTORE' then !.clean = 1
      when o = 'NOCODESTORE' then !.codestore = ''
      when o = 'W2' then !.report = 'W'
      when o = 'W3' then !.report = 'I'
      when o = 'J-' then !.signed = 0
      when o = 'Mp' then !.call = 'optlink'
      when o = 'Ms' then !.call = 'system'
      when o = 'Mc' then !.call = 'cdecl'
      when o = 'Mt' then !.call = 'stdcall'
      when o = 'O-' then !.optlevel = 0
      when o = 'O2' then !.optlevel = 2
      when o = 'O3' then !.optlevel = 3
      when o = 'qautothread' then nop
      when o = 'qnoautothread' then nop
      when o = 'qbitfields=signed' then !.signedbf = 1
      when o = 'qbitfields=unsigned' then !.signedbf = 0
      when o = 'qdbgunref' then !.dbgunref = 1
      when o = 'qnodbgunref' then !.dbgunref = 0
      when o = 'qdigraph' then !.nodigraph = 0
      when o = 'qnodigraph' then !.nodigraph = 1
      when o = 'qignerrno' then !.ignerrno = 1
      when o = 'qignprag=disjoint' then !.ignprag = 'opt(pragmaDisjoint,yes)'
      when o = 'qignprag=isolated' then !.ignprag = 'opt(pragmaIsolated,yes)'
      when o = 'qignprag=all' then !.ignprag = 'opt(pragmaDisjoint,yes),opt(pragmaIsolated,yes)'
      when o = 'qipa' then nop
      when o = 'qlibansi' then !.libansi = 1
      when o = 'qnolibansi' then !.libansi = 0
      when o = 'qloglong' then !.longlong = 1
      when o = 'qnolonglog' then !.longlong = 0
      when o = 'qmakedep' then nop
      when o = 'qro' then !.noro = 0
      when o = 'qnoro' then !.noro = 1
      when o = 'qnortti' then !.rtti = ''
      when o = 'qsomvolattr' then nop
      when o = 'qnosomvolattr' then nop
      when o = 'Su2' then !.enumsize = 'small'
      when o = 'Su1' then !.enumsize = '1'
      when o = 'Rn' then !.stalone = 1
      when o = 'Re' then !.stalone = 0
      when wordpos(o, 'C C+') > 0 then !.mode ='OBJ'
      when wordpos(o, 'W0 W1') > 0 then !.report = 'E'
      when wordpos(o, 'J J+') > 0 then !.signed = 1
      when wordpos(o, 'O O+ O4') then !.optlevel = 4
      when wordpos(o, 'Su Su- Su+ Su4') > 0 then !.enumsize = 'int'
      when abbrev(o, 'isolated_call', 13) then do
         parse var o . '=' o
         do while o <> ''
            parse var o a ':' o
            !.isocall = !.isocall || ',opt(isolatedCall,"' || a || '")'
         end /* do */
      end /* do */
      when abbrev(o, 'SHOWPROGRESS', 12) then parse var o . '=' !.showprogress
      when abbrev(o, 'CODESTORE', 9) then parse var o . '=' !.codestore
      when abbrev(o, 'NOOPTFUNC', 9) then !.optfunc = 0
      when abbrev(o, 'initauto', 8) then parse var o . '=' !.initauto
      when abbrev(o, 'EXEPACK', 7) then parse var o . '=' !.exepack
      when abbrev(o, 'OPTFUNC', 7) then !.optfunc = 1
      when abbrev(o, 'PMTYPE', 6) then parse var o . '=' !.pm
      when abbrev(o, 'STACK', 5) then parse var o . '=' !.stack
      when abbrev(o, 'qrtti', 5) then parse var o . '=' !.rtti
      when abbrev(o, 'qtune', 5) then parse var o . '=' !.tune
      when abbrev(o, 'Sp', 2) then !.pack = substr(o, 3)
      when abbrev(o, 'Tc', 2) then nop
      when abbrev(o, 'Td', 2) then nop
      when abbrev(o, 'Tp', 2) then nop
      when abbrev(o, 'S', 1) then nop
      when abbrev(o, 'T', 1) then call processoptiont o
      when abbrev(o, 'U', 1) then do
         i = undefs.0 + 1
         undefs.0 = i
         undefs.i = substr(o, 2)
      end /* do */
      when abbrev(o, 'V', 1) then parse var o "'" !.verstr "'"
      when abbrev(o, 'W', 1) then nop
      when abbrev(o, 'X', 1) then nop
      when abbrev(o, 'D', 1) then do
         i = defs.0 + 1
         defs.0 = i
         defs.i = substr(o, 2)
      end /* do */
      when abbrev(o, 'F', 1) then call processoptionf o
      when abbrev(o, 'G', 1) then call processoptiong o
      when abbrev(o, 'H', 1) then !.extlen = substr(o, 2)
      when abbrev(o, 'I', 1) then do
         o = substr(o, 2)
         do while o <> ''
            i = incl.0 + 1
            incl.0 = i
            parse var o f ';' o
            call SysFileTree f, 'd.', 'DO'
            if d.0 = 0 then exit 4
            incl.i = d.1
         end /* do */
      end /* do */
      when abbrev(o, 'L', 1) then nop
      when abbrev(o, 'N', 1) then do
         s = substr(o, 2, 1)
         select
            when s = 'd' then !.dname = substr(o, 3)
            when s = 't' then !.tname = substr(o, 3)
            when s = 'x' then !.xname = substr(o, 3)
         otherwise
         nop
         end  /* select */
      end /* do */
      when abbrev(o, 'O', 1) then call processoptiono o
      when abbrev(o, 'P', 1) then nop
   otherwise
   nop
   end  /* select */
   a = b a
end /* do */
a = b a
sourcefiles = ''
cppsourcefiles = ''
rcsourcefiles = ''
binarysourcefiles = ''
binonly = 1
source1 = word(a, 1)
do while a <> ''
   parse var a c a
   s = stream(c, 'c', 'query exist')
   if s = '' then exit 4
   parse upper value filespec('N', s) with . '.' t
   if pos(t, 'C CPP CXX RC DLG H HPP HXX SQC SQX') > 0 then binonly = 0
   select
      when pos(t, 'C CPP CXX H HPP HXX SQC SQX') > 0 | t = '' then cppsourcefiles = cppsourcefiles || ',"' || strip(s) || '"'
      when pos(t, 'RC DLG') > 0 then rcsourcefiles = rcsourcefiles || ',"' || strip(s) || '"'
   otherwise
     binarysourcefiles = binarysourcefiles || ',"' || strip(s) || '"'
   end  /* select */
   sourcefiles = sourcefiles || ',"' || strip(s) || '"'
end /* do */
sourcefiles = substr(sourcefiles, 2)
cppsourcefiles = substr(cppsourcefiles, 2)
rcsourcefiles = substr(rcsourcefiles, 2)
binarysourcefiles = substr(binarysourcefiles, 2)
if !.mode = 'OBJ' & !.obj = '' then do
   parse var sourcefiles '"' a '"' .
   parse value filespec('N', a) with b '.' .
   !.obj = filespec('D', a) || filespec('P', a) || b || '.obj'
end /* do */
if !.obj <> '' then do
   !.bin = !.obj
   if right(!.bin, 1) = '\' then do
      parse value filespec('N', source1) with b '.' .
      !.bin = !.bin || strip(b) || '.obj'
   end /* do */
end /* do */
if !.bin = '' then do
   parse var sourcefiles '"' a '"' .
   parse value filespec('N', a) with b '.' .
   a = filespec('D', a) || filespec('P', a) || b
   if !.gendll then !.bin = a || '.dll'
   else !.bin = a || '.exe'
end /* do */
if !.map = '.map' then do
   parse value filespec('N', !.bin) with !.map '.' .
   !.map = filespec('D', !.bin) || filespec('P', !.bin) || !.map || '.map'
end /* do */
sourceoption = ''
targetoption = ''
if !.ignprag <> '' then sourceoption = sourceoption || ',' || !.ignprag
if !.isocall <> '' then sourceoption = sourceoption || !.isocall
if !.optsize then sourceoption = sourceoption || ',opt(size,yes)'
if !.optinline then sourceoption = sourceoption || ',opt(inline,yes),opt(autoInline,yes)'
if !.optstack then sourceoption = sourceoption || 'opt(stack,yes)'
if !.optchain then sourceoption = sourceoption || 'opt(stackChaining,yes)'
if !.optsched then sourceoption = sourceoption || 'opt(schedule,yes)'
if !.optlevel <> '' then sourceoption = sourceoption || ",opt(level," || !.optlevel || ")"
if !.tune <> '' then sourceoption = sourceoption || ",opt(tune," || !.tune || ")"
if !.fastfloat then sourceoption = sourceoption || ",opt(float,yes)"
if !.fastint then sourceoption = sourceoption || ",opt(integer,yes)"
if !.nodigraph then sourceoption = sourceoption || ',lang(digraphs,no)'
if !.ignerrno then sourceoption = sourceoption || ',lang(ignerrno,yes)'
if !.signed then sourceoption = sourceoption || ',lang(signedChars,yes)'
if !.signedbf then sourceoption = sourceoption || ',lang(signedBitfields,yes)'
if !.longlong then sourceoption = sourceoption || ',lang(longLong,yes)'
if !.remexcep then sourceoption = sourceoption || ',gen(eh,no)'
if !.tiled then sourceoption = sourceoption || ',gen(tiledMemory,yes)'
if !.remstackprob then sourceoption = sourceoption || ',gen(probe,no)'
if !.ring0 then sourceoption = sourceoption || ',gen(ring0,yes)'
if !.parmdw then sourceoption = sourceoption || ',gen(parmDWord,yes)'
if !.initauto <> '' then sourceoption = sourceoption || ',gen(initAuto,' || !.initauto || ')'
if !.extlen <> '' then sourceoption = sourceoption || ",gen(maxMangling,ansi," || !.extlen || ")"
if !.pack <> '' then sourceoption = sourceoption || ",gen(pack," || !.pack || ")"
if !.enumsize <> '' then sourceoption = sourceoption || ",gen(enumSize," || !.enumsize || ")"
if !.profile then sourceoption = sourceoption || ",gen(profile,yes)"
if !.remunref then sourceoption = sourceoption || ",gen(unreferenced,yes)"
if !.dbgunref then sourceoption = sourceoption || ",gen(debugUnreferenced,yes)"
if !.noro then sourceoption = sourceoption || ",gen(readOnly,no)"
if !.dump then sourceoption = sourceoption || ",gen(dump,yes)"
if !.tname <> '' then sourceoption = sourceoption || ',gen(codeSeg,"' || !.tname || '")'
if !.rtti <> '' then do
   sourceoption = sourceoption || ',gen(rtti,' !.rtti || ')'
   targetoption = targetoption || ',gen(rtti,' !.rtti || ')'
end /* do */
if !.xname <> '' then do
   sourceoption = sourceoption || ',gen(ehCodeSeg,"' || !.xname || '")'
   sourceoption = sourceoption || ',gen(ehDataSeg,"' || !.xname || '")'
end /* do */
if !.dname <> '' then do
   sourceoption = sourceoption || ',gen(dataSeg,"' || !.dname || '")'
   sourceoption = sourceoption || ',gen(uninitSeg,"' || !.dname || '")'
   sourceoption = sourceoption || ',gen(constSeg,"' || !.dname || '")'
end /* do */
do i = 1 to defs.0
   parse var defs.i n '=' v
   if v = '' then sourceoption = sourceoption || ',define(' || strip(n) || ')'
   else sourceoption = sourceoption || ',define(' || strip(n) || ',"' || strip(v) ||  '")'
end /* do */
do i = 1 to undefs.0
   sourceoption = sourceoption || ',undefine(' || undefs.i || ')'
end /* do */
if \ binonly then do
   sourceoption = sourceoption || ',gen(call,' || !.call || ')'
   do i = 1 to incl.0
      sourceoption = sourceoption || ',incl(searchPath,"' || translate(incl.i, '/', '\') || '")'
   end /* do */
end /* do */
if !.stack <> '' then targetoption = targetoption || ',link(stack,' || !.stack || ')'
if !.verstr <> '' then targetoption = targetoption || ',link(versionString,"' || !.verstr || '")'
if !.mtlib then targetoption = targetoption || ',link(linkWithMultiThreadLib,yes)'
if !.hidedeflib then targetoption = targetoption || ',link(defaultLibs,no)'
if !.debug then targetoption = targetoption || ',link(debug,yes)'
if !.libdll then targetoption = targetoption || ',link(linkWithSharedLib,yes)'
if !.optfunc then targetoption = targetoption || ',link(optFunc,yes)'
if !.map <> '' then targetoption = targetoption || ',link(map,"' || translate(!.map,'/','\') || '")'
targetoption = targetoption || ',link(pmType,' || !.pm || ')'
if !.exepack <> '' then targetoption = targetoption || ',link(exePack,' || !.exepack || ')'
if !.report <> '' then sourceoption = sourceoption || ',report(level,' || !.report || '")'
f = SysTempFileName(value('tmp', , 'os2environment') || '\?????.icc')
if left(sourceoption, 1) = ',' then sourceoption = substr(sourceoption, 2)
if left(targetoption, 1) = ',' then targetoption = substr(targetoption, 2)
call stream f, 'c', 'open write'
if cppsourcefiles <> '' then call lineout f, 'group cppsourcefiles =' translate(cppsourcefiles, '/', '\')
if rcsourcefiles <> '' then call lineout f, 'group rcsourcefiles =' translate(rcsourcefiles, '/', '\')
if binarysourcefiles <> '' then call lineout f, 'group binarysourcefiles =' translate(binarysourcefiles, '/', '\')
if sourceoption <> '' then call lineout f, 'option sourceoption =' sourceoption
call lineout f, 'option targetoption =' targetoption
call lineout f, 'option targetoption {'
if !.mode = 'NUL' then call lineout f, '   target type(obj) "/dev/nul" {'
else call lineout f, '   target "' || translate(!.bin, '/', '\') ||  '" {'
if sourceoption <> '' then do
   call lineout f, '      option sourceoption {'
   if cppsourcefiles <> '' then call lineout f, '         source type(cpp) cppsourcefiles'
   if rcsourcefiles <> '' then call lineout f, '         source type(rc) rcsourcefiles'
   if binarysourcefiles <> '' then call lineout f, '         source binarysourcefiles'
   call lineout f, '      }'
end /* do */
else do
   if cppsourcefiles <> '' then call lineout f, '         source type(cpp) cppsourcefiles'
   if rcsourcefiles <> '' then call lineout f, '         source type(rc) rcsourcefiles'
   if binarysourcefiles <> '' then call lineout f, '         source binarysourcefiles'
end /* do */
call lineout f, '   }'
call lineout f, '}'
call stream f, 'c', 'close'
'@copy' f value('tmp', , 'os2environment') || '\lastbld.icc >nul 2>&1'
call setlocal
'@call' value('vacppmain', , 'os2environment') || '\bin\setenv'
if !.codestore = '' then o = '-NOC'
else o = '-C' !.codestore
if !.clean then do
   '@vacbld' o '-CLEAN'
   exit rc
end /* do */
if !.showprogress <> 0 then o = o '-SHOWPROGRESS=' || !.showprogress
'@vacbld' o f
code = rc
call endlocal
exit code

error:
ln = sigl
say condition()
say ln '@' condition('C')
say condition('I')
say condition('D')
say condition('S')
exit 8

processoptiont: procedure expose !.
parse arg opt
opt = substr(opt, 2)
do while opt <> ''
   parse var opt c 2 opt
   if pos(left(opt, 1), '+-*') > 0 then parse var opt v 2 opt
   else v = ''
   c = c || v
   select
      when abbrev(c, 'n', 1) then nop
      when wordpos(c, 'i i+ m m+') then !.debug = 1
      when c = 'i- m-' then !.debug = 0
      when wordpos(c, 'x x+') then !.dump = 1
      when c = 'x-' then !.dump = 0
   otherwise
   nop
   end  /* select */
end /* do */
return

processoptiono: procedure expose !.
parse arg opt
opt = substr(opt, 2)
do while opt <> ''
   parse var opt c 2 opt
   if pos(left(opt, 1), '+-*') > 0 then parse var opt v 2 opt
   else v = ''
   c = c || v
   select
      when abbrev(c, 'l m', 1) then nop
      when wordpos(c, 'c c+') then !.optsize = 1
      when c = 'c-' then !.optsize = 0
      when wordpos(c, 'i i+') then !.optinline = 1
      when c = 'i-' then !.optinline = 0
      when wordpos(c, 'p p+') then !.optstack = 1
      when c = 'p-' then !.optstack = 0
      when wordpos(c, 'q q+') then !.optchain = 1
      when c = 'q-' then !.optchain = 0
      when wordpos(c, 's s+') then !.optsched = 1
      when c = 's-' then !.optsched = 0
   otherwise
   nop
   end  /* select */
end /* do */
return

processoptiong: procedure expose !.
parse arg opt
opt = substr(opt, 2)
do while opt <> ''
   parse var opt c 2 opt
   if pos(left(opt, 1), '+-*') > 0 then parse var opt v 2 opt
   else v = ''
   c = c || v
   select
      when abbrev(c, 'a b k u v w y z', 1) then nop
      when wordpos(c, 'e e+') then !.gendll = 0
      when c = 'e-' then !.gendll = 1
      when wordpos(c, 'x x+') then !.remexcep = 1
      when c = 'x-' then !.remexcep = 0
      when wordpos(c, 'd d+') then !.libdll = 1
      when c = 'd-' then !.libdll = 0
      when wordpos(c, 't t+') then !.tiled = 1
      when c = 't-' then !.tiled = 0
      when wordpos(c, 's s+') then !.remstackprob = 1
      when c = 's-' then !.remstackprob = 0
      when wordpos(c, 'r r+') then !.ring0 = 1
      when c = 'r-' then !.ring0 = 0
      when wordpos(c, 'p p+') then !.parmdw = 1
      when c = 'p-' then !.parmdw = 0
      when wordpos(c, 'n n+') then !.hidedeflib = 1
      when c = 'n-' then !.hidedeflib = 0
      when wordpos(c, 'm m+') then !.mtlib = 1
      when c = 'm-' then !.mtlib = 0
      when wordpos(c, 'l l+') then !.remunref = 1
      when c = 'i-' then !.remunref = 0
      when wordpos(c, 'i i+') then !.fastint = 1
      when c = 'i-' then !.fastint = 0
      when wordpos(c, 'h h+') then !.profile = 1
      when c = 'h-' then !.profile = 0
      when wordpos(c, 'f f+') then !.fastfloat = 1
      when c = 'f-' then !.fastfloat = 0
      when c = '3' then !.tune = 'x86'
      when c = '4' then !.tune = '486'
      when c = '5' then !.tune = 'pentium'
      when c = '6' then !.tune = 'pentium2'
   otherwise
   nop
   end  /* select */
end /* do */
return

processoptionf: procedure expose !.
parse arg opt
opt = substr(opt, 2)
do while opt <> ''
   parse var opt c 2 opt
   if pos(left(opt, 1), '+-*') > 0 then parse var opt v 2 opt
   else v = ''
   c = c || v
   select
      when wordpos(c, 'a i l n t w') > 0 then leave
      when wordpos(c, 'a+ a- i+ i- l+ l- n+ n- t+ t- w+ w-') > 0 then nop
      when abbrev(c, 'b', 1) then nop
      when wordpos(c, 'c c+') > 0 then !.mode = 'NUL'
      when c = 'm' then do
         !.map = opt
         if !.map = '' then !.map = '.map'
         leave
      end /* do */
      when c = 'm+' then !.map = '.map'
      when c = 'o' then do
         !.mode = 'OBJ'
         !.obj = opt
         leave
      end /* do */
      when c = 'o+' then do
         !.mode = 'OBJ'
         !.obj = ''
      end /* do */
      when c = 'e' then do
         !.mode = 'EXE'
         !.bin = opt
         leave
      end /* do */
   otherwise
   nop
   end  /* select */
end /* do */
return
