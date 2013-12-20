/**/
'@Echo Off'
if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
 end

call time 'E'
parse arg target_spec sub_dirs
if translate(strip(sub_dirs)) = '/S' then
  flags = 'FOS'
else
  flags = 'FO'

call SysFileTree target_spec,victims,flags
do i=1 to victims.0
  say
  say 'File: '||victims.i
  call lineout stderr,'File: '||victims.i
  data = charin(victims.i,1,chars(victims.i))
  call stream victims.i,'C','CLOSE'
  call lineout stderr,' data read'
  'del "'||victims.i||'" >NUL'
  data = subst(data,'0A0A'x,'0A'x)
  call lineout stderr,' 1st subst done'
  data = subst(data,'0D0D'x,'0D'x)
  call lineout stderr,' 2nd subst done'
  newdata = ''
  curpos = 1
  do until pos('0A'x,data,curpos) = 0
    offset = pos('0A'x,data,curpos)
    if substr(data,offset-1,1) <> '0D'x then do
      data = substr(data,1,offset-1)||'0D0A'||substr(data,offset+1)
      curpos = offset+2
     end
    else 
      curpos = offset+1
   end
  call lineout stderr,' 3rd subst done'
  data = newdata||data
  /* And now some sympathy mainly from multipart emails */
  curpos = 1
  do until pos('From ???@???',data,curpos) = 0
    brpt = pos('From ???@???',data,curpos)
    if (brpt>1) then
      if (substr(data,brpt-1,1) <> '0A'x) then do
        say
        say 'WARNING: breaking apparently unsplit line, see data: '
        say '*****************************************************'
        call lineout stdout,substr(data,brpt-100,400)
        say '*****************************************************'
        data = substr(data,1,brpt-1)||'0D0A'x||substr(data,brpt)
       end
    curpos = brpt+10
   end
  call lineout stderr,' 4th subst done'
  call charout victims.i,data
  call stream victims.i,'C','CLOSE'
  say ' -> Time elapsed: '||time('E')||'s.'
 end
exit

subst: procedure
  parse arg string,searchthis,replacement,howmany
  if howmany = '' then howmany = 0 
  len = length(searchthis)
  changes = 0
  ready = ''  
  do until (loc = 0) | changes=howmany
    loc = pos(searchthis,string)
    if loc > 0 then do
     ready = ready || substr(string,1,loc-1) || replacement 
     string = substr(string,loc+len)
     howmany=howmany+1
    end
   end
return ready || string
