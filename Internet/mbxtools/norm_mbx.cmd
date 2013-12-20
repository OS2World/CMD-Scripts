/**/
'@Echo Off'
if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
 end

crlf = '0D0A'x

regular_write = 1  /* Whether to actually dump emails to new mailboxes */
dump = 0           /* Whether to dump to-be-fixed emails to separate mailboxes as well */
dump_mbx = 1       /* If =0 extra info is added to the 'browse mails-to-fix' mailboxes */

stats.1 = 'emails'
stats.2 = 'date_fix'
stats.3 = 'multipart'
stats.4 = 'eu_merged'
stats.5 = 'fakefrom'
stats.6 = 'lnfdconv'
stats.0 = 6

call time 'E'
etime = 0

parse arg target_spec sub_dirs
if translate(strip(sub_dirs)) = '/S' then
  flags = 'FOS'
else
  flags = 'FO'

call SysFileTree target_spec,victims,flags

Say 'Finished listing MailBoxes - Time elapsed: '||time('E')||'s.'

do i=1 to stats.0
  call value stats.i,0
  call value 't_'||stats.i,0
 end

do i=1 to victims.0
  if right(translate(victims.i),4) = '.MBX' then
    output = substr(victims.i,1,length(victims.i)-4)
  else
    output = 'OutPut.mbx'
  say
  say 'Now processing '||victims.i

  do j=1 to stats.0
    call value stats.j,0
   end

  newmail = ''
  do while lines(victims.i)>0
    txt = linein(victims.i)
    /*
       We're normalizing just Eudora MBXs
       -> From ???@??? IS MANDATORY as BOM mark
    */
    if pos('From ???@???',txt)>0 then do
      call count 'emails'
      /* Some sympathy from HTML emails and others */
      brpt = pos('From ???@???',txt)
      if brpt>1 then do
        say 
        say 'Warning: breaking unsplit line - CHECK DATA:'
        say '********************************************'
        say txt
        say '********************************************'
        newmail = newmail||substr(txt,1,brpt-1)||crlf
        txt = substr(txt,brpt)
       end
      /* Now back to work */
      call process_mail
      newmail = txt||crlf
     end
    else
     newmail = newmail||txt||crlf
   end
  call process_mail

  call charout stdout,'Stats: '
  do j=1 to stats.0
    if (value(stats.j) > 0) then 
      call charout stdout,stats.j||'='||value(stats.j)||' '
   end
  say
  say ' -> Time elapsed: '||format(time('E')-etime,,2)||'s.'
  etime = time('E')

 end
say
call charout stdout,'Totals: '
do i=1 to stats.0
  call charout stdout,stats.i||'='||value('t_'||stats.i)||' '
 end
say
say 'Total time elapsed: '||format(time('E'),,2)||'s.'
exit

count:
  parse arg var_name
  call value var_name,value(var_name)+1
  call value 't_'||var_name,value('t_'||var_name)+1
return

dump_mail:
  parse arg target
  if dump_mbx = 0 then do
    if value('lastdump_'||target) <> victims.i then do
      call lineout 'Trouble_'||target||'.mbx',''
      call lineout 'Trouble_'||target||'.mbx','Found in '||victims.i
      call lineout 'Trouble_'||target||'.mbx','********************************'
     end
    call lineout 'Trouble_'||target||'.mbx','컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴'
   end
  call lineout 'Trouble_'||target||'.mbx',newmail
  if dump_mbx = 0 then do
    call lineout 'Trouble_'||target||'.mbx',''
    call value 'lastdump_'||target,victims.i
   end
return

process_mail:
  if length(newmail)=0 then return
  bpoint = pos('0D0A0D0A'x,newmail)
  if bpoint > 0 then do
    header   = substr(newmail,1,bpoint+1)
    contents = substr(newmail,bpoint+2)   /* includes a first empty line */

    /* Now do some stuff */

    /*
       First a real fix: Eudora did NOT insert a FCC-mandatory Date field in
       the header of outgoing messages until God-knows-which-version
    */
    parse var header 'From ???@???' dw month dm time year '0D0A'x .
    date_loc = pos('0D0A'x||'DATE:',translate(header))
    if date_loc = 0 then do
      new_date = 'Date: '||dw||', '||dm||' '||month||' '||year||' '||time
      header = header||new_date||crlf
      header = header||'MBX_Normalizer: insert-date="'||new_date||'";'||crlf
      call count 'date_fix'
/*
      if dump = 1 then
        call dump_mail 'date_fix'
*/
     end

    /*
       Second fix: strip 'multipart' headers from Eudora multipart merged
        emails so that MozillaMail does not get confused
    */
    if pos('CONTENT-TYPE: MULTIPART/',translate(header))>0 then do
      call demime_mail
     end

    /*
       When MozillaMail finds a new line starting with 'From ', it assumes
       a new message begins (very well-defined mbox formats yeah...)
       MozillaMail covers its basis by silently changing that to ' From '
       in composed messages before sending them :/
       so we fake it just the same way
    */

    fp = pos('0D0A'x||'FROM ',translate(contents))
    if fp >0 then do
      oldfp = fp
      do while fp>0
        fp = pos('0D0A'x||'FROM ',translate(contents),oldfp)
        contents = substr(contents,1,fp+1)||' '||substr(contents,fp+2)
        oldfp = fp
       end
      header = header||'MBX_Normalizer: fake-from-fix;'||crlf
      call count 'fakefrom'
      if dump = 1 then
        call dump_mail 'fakefrom'
     end

    /*
       Final fix: '0D0A' means '0D0A'x for some weird MUAs :-?
    */
    fp = pos('0D0A',contents)
    if fp>0 then do
      if pos(substr(contents,fp+4,1),'0123456789ABCDEF"'';') = 0 then do
        contents = subst(contents,'0D0A','0D0A'x)
        header = header||'MBX_Normalizer: line-feed-convert;'||crlf
        if dump = 1 then
          call dump_mail 'lnfdconv'
       end
     end

    newmail = header||contents
    if regular_write = 1 then
      call charout output,newmail
   end
  else do
    say 'Warning: non-standard email - see dump: '||length(newmail)
    if dump = 1 then
      call dump_mail 'non_rfc'
   end
return

demime_mail:
  mp_start = pos('CONTENT-TYPE: MULTIPART/',translate(header))
  boundary_begin = pos('BOUNDARY=',translate(header),mp_start+25)
  if boundary_begin = 0 then do
    say "Couldn't de-mime multipart email: boundary start not found"
    return
   end
  boundary_begin = boundary_begin + 9
  if substr(header,boundary_begin,1) = '"' then do
    boundary_begin = boundary_begin+1
    terminators = '";'||'0D0A'x
   end
  else do
    terminators = ';'||'0D0A'x
   end
  boundary = ''
  curpos = boundary_begin
  do until pos(newchar,terminators)>0
    newchar = substr(header,curpos,1)
    if pos(newchar,terminators) = 0 then
      boundary = boundary||newchar
    curpos = curpos+1
   end
  boundary_found = pos(boundary,contents)
  /* Mainly we should leave real multipart msgs alone */
  if (boundary_found > 0) then do
    call count 'multipart'
    if dump = 1 then
      call dump_mail 'multipart'
    return
   end
  /* Remove the 'multipart' header, add ours */
  linebreak = pos('0D0A'x,header,boundary_begin)
  kill_me = substr(header,mp_start,linebreak-mp_start+2)
  parse var kill_me . '/' relationship ';' .
  if translate(relationship) = 'RELATED' then do
    parse var kill_me . '"multipart/' nr '";'
    if nr <> '' then
      relationship = relationship||'-'||nr
   end
  header  = subst(header,kill_me,'')
  header  = header||'MBX_Normalizer: kill-multipart-field="'||relationship||'"'||crlf
  call count 'eu_merged'
  if dump = 1 then
    call dump_mail 'eu_merged'
return

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
