/* rexx */

tab = '09'x

signal on halt

if rxfuncquery('rxqprocstatus') then
  do
  call rxfuncadd 'yinit','ydbautil','rxydbautilinit'
  call yinit
  end

arg opts

if opts = '?' | opts = 'HELP' then
  do
  say;say 'Syntax:'
  say tab 'PI2  /switch=val';say
  say 'where:';say
  say tab 'switch -' tab 'P  = Prefix of executable file name'
  say tab tab tab        'N  = process number (hex/decimal)'
  say tab tab tab        'PN = parent process number (hex/decimal)'
  say tab tab tab        'F  = function:'
  say tab tab tab tab          'LIST'
  say tab tab tab tab          'CHILDREN'
  say tab tab tab tab          'DEPENDENTS'
  say tab tab tab tab          'PARENTS'
  say tab tab tab tab          'ANCESTORS'
  say;say 'Examples:';say
  say tab 'To list all processes whose executable file name begins with'
  say tab 'the characters PM, you would type:';say
  say tab tab 'pi2 /p=pm';say
  say tab 'To list the process whose process-id is decimal 13, you would type:'
  say tab tab 'pi2 /n=13';say
  say tab 'To list the process whose process-id is hex 1c, you would type:'
  say tab tab 'pi2 /n=x1c';say
  exit
  end

srchpn = ''
srchppn = ''
pref = ''
fargs = ''
func = ''
do i=1 to words(opts)
  opt = word(opts,i)
  select
    when wordpos(left(opt,1),'/ -') > 0 then
      do
      parse var opt . 2 optcd '=' optval
      select
        when optcd = 'P' then
          pref = optval
        when optcd = 'F' then
          do
          select
            when abbrev('LIST',optval) then
              func = 'LIST'
            when abbrev('CHILDREN',optval) then
              do
              func = 'CHILDREN'
              fargs = fargs || 'l'
              end
            when abbrev('DEPENDENTS',optval) then
              do
              func = 'DEPENDENTS'
              fargs = fargs || 'l'
              end
            when abbrev('PARENTS',optval) then
              do
              func = 'PARENTS'
              end
            when abbrev('ANCESTORS',optval) then
              do
              func = 'ANCESTORS'
              end
            otherwise
              do
              say '"'opt'" specifies an invalid function.'
              exit
              end
          end
          end
        when optcd = 'N' | optcd = 'PN' then
          do
          if left(optval,1) = 'X' then
            do
            pn = substr(optval,2)
            if \datatype(pn,'x') then
              do
              say '"'opt'" specifies an invalid hexadecimal process number.'
              exit
              end
            if optcd = 'N' then
              srchpn = x2d(pn)
            else
              srchppn = x2d(pn)
            end
          else
            do
            if \datatype(optval,'w') then
              do
              say '"'opt'" specifies an invalid decimal process number.'
              exit
              end
            if optcd = 'N' then
              srchpn = optval
            else
              srchppn = optval
            end
          end
        otherwise
          do
          say '"'opt'" is an invalid option.'
          exit
          end
      end
      end
    otherwise
      do
      if pref = '' then
        pref = opt
      end
  end
end

if func = 'DEPENDENTS' then
  do
  call rxqprocstatus 'q.',fargs
  do i=1 to q.0l.0
    idx = q.0l.i
    exename = translate(filespec('n',q.0l.idx.1))
    if (left(exename,length(pref)) = pref) then
      do
      lvl = 1
      found = ''
      call libname q.0l.i
      return
      end
  end
  return
  end

if func = '' then
  func = 'LIST'

if wordpos(func,'LIST CHILDREN') > 0 then
  do
  call rxqprocstatus 'q.',fargs
  do i=1 to q.0p.0
    ok = 1
    exename = translate(filespec('n',q.0p.i.6))
    if length(srchppn) > 0 then
      ok = ok & (x2d(q.0p.i.2) = srchppn)
    else
      ok = ok & 1
    if length(srchpn) > 0 then
      ok = ok & (x2d(q.0p.i.1) = srchpn)
    else
      ok = ok & 1
    if (left(exename,length(pref)) = pref) & ok then
      do
      say;say q.0p.i.6
      msg='pid='q.0p.i.1',ppid='q.0p.i.2',sgid='q.0p.i.5',status='
      if pos('?',q.0p.i.4) > 0 then
        msg = msg || q.0p.i.4
      else
        msg = msg || subword(q.0p.i.4,2)
      say msg
      do t=1 to q.0p.i.0t.0
        msg='tid='q.0p.i.0t.t.1',slot='q.0p.i.0t.t.2',slpid='q.0p.i.0t.t.3||,
            ',prty='right(q.0p.i.0t.t.4,4)',stime/utime='q.0p.i.0t.t.5'/'q.0p.i.0t.t.6',state='
        if pos('?',q.0p.i.0t.t.7) > 0 then
          msg = msg || q.0p.i.0t.t.7
        else
          msg = msg || subword(q.0p.i.0t.t.7,2)
        say msg
      end
      if func = 'CHILDREN' then
        do l=1 to q.0p.i.0l.0
          lvl = 1
          found = ''
          call libname q.0p.i.0l.l
        end
      end
  end
  return
  end

if func = 'ANCESTORS' then
  do
  call rxqprocstatus 'q.','l'
  do i=1 to q.0l.0
    idx = q.0l.i
    modname = translate(filespec('n',q.0l.idx.1))
    if modname = pref then
      do
      modidx = q.0l.i
      leave
      end
  end
  say 'Processes using the module' pref
  do i=1 to q.0p.0
    do l=1 to q.0p.i.0l.0
      if q.0p.i.0l.l = modidx then
        do
        say '  'q.0p.i.6
        leave l
        end
    end
  end
  return
  end

exit

libname: procedure expose q. lvl found
lvl = lvl + 1
do x=1 to q.0l.0
  if arg(1) = q.0l.x then
    do
    found = found q.0l.x
    idx = q.0l.x
    say copies(' ',2*lvl) || q.0l.idx.1
    do i=1 to q.0l.idx.0i.0
      if wordpos(q.0l.idx.0i.i,found) = 0 then
        call libname q.0l.idx.0i.i
    end
    lvl = lvl - 1
    return
    end
end
lvl = lvl - 1
return '?'

halt:
drop q.
exit
