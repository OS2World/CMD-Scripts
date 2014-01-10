/* Time4SR - Plain OS/2 REXX and REXXUTIL */
splash= d2c(22)||' Time4SR v1 by DGD - Scheduler front-end for StreamRipper'
/* highly modified version of tz.cmd begun Feb 6, 2010 ... done-ish Feb 9 */

call rxfuncadd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call sysloadfuncs
Call SysCurState 'OFF'
call syscls
say splash

call keys_and_colors /* moved key and color "constants" to reduce clutter */

say 'Initializing: a random wait here in case of multiple in Start folder.'
call syssleep (1 + random(5)) /* hope to ensure time to update window list */
f= 0  /* find how many instances of TIME4SR are running, so can later check */
call sysqueryswitchlist "windowlist.", 'd' /* for vio _this_ one starts */ 
do w= 1 to windowlist.0         /* !!! ALSO finds corresponding #'d sched! */
  windowlist.w= translate(windowlist.w)  /* properties may be in mixed case */
  if pos('TIME4SR', windowlist.w) > 0 then f= f + 1
end
vio_title= 'StreamRipper #'f /* up to 9, anyway */

parse arg ramdrive  /* don't put '\' on param */
if ramdrive = '' then sched_drive= 'C:'
else do   /* copy TSR dir from 'C:', soft-coded kludge */
  sched_drive= ramdrive
  call delete_tree sched_drive||'\TSR' /* darn it, must remove if exists */
  'mkdir 'sched_drive'\TSR'
  'xcopy C:\TSR\* 'sched_drive'\TSR /s /e'
end
sched_path= sched_drive||'\TSR\'
sched_name= sched_path||'Time4SR'||f||'.sch'     /* AUTO-NUMBERED SCHEDS! */
save_path= sched_path /* just to set other than nil */
clear= 0 /* CLEAR flag */
maxsp= 0 /* MAX space: will be set from keyword in TIME4SRx.SCH */
show.0= '' /* 24x60 "array" for display. Initialized here only for info */
slin.0= 0 /* schedule file, 0 holds # of lines read */
ref.0= '' /* similar to above, holds reference to line numbers of tsr.sch */
pl.0= 0 /* list of playlists */

curlin= '' /* current line running of time4srx.sch; when \= the character of */
  /* pseudo-array ref.[hour, minute], then some action is needed */
startday= ''
curact= ''
sleeptime= 1
refc= d2c(255) /* to ensure \= to curlin */
last_message= '' /* avoids some tangles knowing which stream is playing */
move2= '' /* flag, set to dtfn formed below, without paths */
ready2move= '' /* 2nd flag, preserving if started writing another file */
writing= 0

do forever
  if startday \= date('S') then do /* 1st run or passed midnight */
    startday= date('S')
    call read_file
    call syscls
    call interp_sched
    call message splash
    call show_sched
  end
  key= ''
  if chars()>0 then do
    key= ex_read_key()
    select
      when key = k_backspace then do /* re-start, re-read TIME4SRx.SCH */
        startday = ''
        curlin= '0'
      end
      when key = 'h' | key = 'H' then do
        call show_help
        call syscls
        call show_sched
      end
      when key = '~' then do /* "Rem out" the current action to STOP it */
        curlin= '0' /* triggers "new action" below */
        refc= c2d(value('refc')) /* un-de-code the line # */
        slin.refc= '~'||slin.refc /* add tilde; remove to restore line... */
        call interp_sched /* and start over with that line being skipped */
      end
      otherwise nop
    end /* outermost select */
  end
  else call syssleep sleeptime
  if key = 'X' | key = 'x' then leave
  now= time('N')
  parse value now with ch ':' cm ':' cs
  if pos('0', ch) = 1 then ch= delstr(ch, 1, 1)
  if pos('0', cm) = 1 then cm= delstr(cm, 1, 1)
  if pos(':00:00', now) = 3 then call show_sched /* hourly full refresh */
  else if pos(':00', now) = 6 then do /* EVERY MINUTE CHECK RUNNING */
    call check_running /* if stream errors cause sr to quit, try re-start(s) */
    if sr_running = 0 & curact = 'REC' then do /* but ONLY while recording. */
      call syscurpos 22, 1  /* there's a good reason to locate cursor here */
      call charout, l_bk_wh||' !!! 'vio_title' HAS APPARENTLY STOPPED! ATTEMPTING RE-START.'||l_wh_bk
      call syscurpos 23, 1
      curlin= '0' /* this triggers new action below */
    end
    call syscurpos ch, 16  /* line refresh cleans up some garbage highlight */
    call charout, show.ch  /*  chars left because of clock uncertainties */
  end 
  if pos(substr(cs, 2, 1), '02468') > 0 then call charout, l_bk_wh
  call syscurpos ch, cm + 19 /* offset on screen */
  call charout, substr(show.ch, cm + 4, 1)
  call charout, l_wh_bk    /* this section flashes cursor */
  call syscurpos 23, 1
  call charout, now
  refc= substr(ref.ch, cm + 1, 1)
  /* CHECK IF NEW ACTION REQUIRED - (starts even from middle of event) */
  if (curlin \= refc) then do
    if curlin \= '' then do /* presumably every time except very first */
      if writing = 1 then do
        call message 'WAITING for 'vio_title' to shut down...'
        l= 0
        do until sr_running = 0 | l > 60 /* HMM... may be IFFY */
          call check_running    /* WAS iffy: nearly fixed by more accurate */
          call syssleep 1       /* calculation of durations, below */
          l= l + 1
        end
        writing= 0
        if move2 \= '' then do
          call message 'Setting MOVE flag...'
          ready2move= move2
        end
        else ready2move= ''
        call syssleep 1
      end /* writing */
      move2= '' /* always set flag off */
    end /* curlin \= '' */
    refc= c2d(value('refc')) /* refc is char = line #; convert it to _#_ */
    curlin= slin.refc /* to refer to slin.# - curlin only a handy var here */
    kw= translate(left(curlin, 3)) /* vars duplicated from interp */
    if kw= 'REC' then do  /* the only function left from tz.cmd */
      parse value word(curlin.ndx, 3) with sth ':' stm
      /* DURATION MODE ISN'T SIMPLE with flying start and re-starts. */
      wi= substr(show.ch, cm + 4, 1)  /* encoded character current minute */
      f= substr(time('N'), 7, 2) + 15  /* to compensate for lag time */
      select
        when wi = 'Þ' then do  /* "normal" entry at start of event */
          dur= word(curlin, 4) * 60 - f /* make time in SECONDS, less lag */
        end
        when wi = d2c(16) | wi = 'þ' | wi = d2c(17) then do /* more usual */
          waddr= ''                  /* case of entry in MIDDLE of period */
          do l= ch to 23 /* concat show lines to find next Ý character */
            waddr= waddr||substr(show.l, 4) /* which marks end of recording */
          end          /* skip the shown ^hour # */
          waddr= delstr(waddr, 1, cm) /* get rid of up to current minute */
          dur= pos('Ý', waddr) * 60 - f /* pretty clever kludge for */
        end   /* otherwise complex prob that'd require math on times, huh? */
        when wi = 'Ý' then do
          call message 'LAST minute! Not bothering to start recording...'
          do until substr(time('N'), 4, 2) <> cm
            call syssleep 1
            call syscurpos 23, 1
            call charout, time('N')
          end
          dur= 0
        end
        otherwise dur= 0 /* say 'May be a bug if even gets to here...' */
      end  /* duration calc */
      if dur > 60 then do   /* SKIP recording if somehow short */
        remdr= substr(curlin, lastpos(':\', curlin) - 1) /* remainder */
        if pos('PATH', curlin) > 0 then do
          i= pos('"', curlin) + 1
          spool_path= substr(curlin, i, lastpos('"', curlin) - 1 - i)
        end
        else spool_path= save_path
        if lastpos('\', spool_path) \= length(spool_path) then
          spool_path= spool_path||'\'
        dtfn= substr(date('S'), 3, 6)||'_'||substr(time('N'), 1, 5)
        dtfn= delstr(dtfn, 10, 1)
        fnne= substr(remdr, lastpos('\', remdr) + 1) /* get file name */
        fnne= substr(fnne, 1, pos('.', fnne) - 1) /* no extension */
        dtfn= fnne||'_'||dtfn  /* add to stream name, keep for vio title */
        if pos('MOVE', curlin) > 0 then move2= dtfn /* separate for MOVE */
        dtfn= spool_path||dtfn
        call read_pls remdr  /* read in the text, not the files list */
        waddr= '' /* extract address from playlist whether .pls or .m3u */
        do wi= 1 to pls_text.0  /* simplistic get first listed web addr */
          if pos('http', pls_text.wi) > 0 & waddr = '' then do
            waddr= substr(pls_text.wi, pos('http', pls_text.wi))
          end
        end
        drop pls_text.
        srp= 'C:\StreamRipper\SR.EXE '||waddr||' -a '||dtfn||' -l '||dur||,
          ' -s -A -u WinampMPEG/5.18'
        'start "'vio_title' : 'fnne'" /N /B /PGM 'srp
        call message d2c(22)||' Recording: 'dtfn' for 'dur'S'
        writing= 1
      end /* dur > a lower limit */
    end /* REC */
    if ready2move \= '' then do /* FILE WAITING TO BE MOVED */
    /* could get rid of clutter with "@" and ">nul", but I like to see... */
      call syscls
      say ' Moving recorded file - possibly clearing space - and cleaning up...'
      rc= sysfiletree(spool_path||ready2move||'.MP3', vdl., 'F')
      reqsp= word(vdl.1, 3) /* required space for current file */
      if reqsp = '' then reqsp= 0 /* avoids crash at "do while" below */
      if maxsp > 0 then do /* MAX strategy supplements CLEAR */
        rc= sysfiletree(save_path||'\*.MP3', vdl., 'F')
        used= 0
        if vdl.0 > 0 then do  /* IF any files, total up directory size */
          do f= 1 to vdl.0
            used= used + word(vdl.f, 3)
          end
        end
        say 'Used space in 'save_path' is: 'used' bytes; MAX is: 'maxsp'.'
        f= 1 /* assumes #1 is OLDEST file, true if all named by TIME4SR.SCH */
        if vdl.0 > 0 then do
          do while (used + reqsp > maxsp) | (f > vdl.0)
            'del 'right(vdl.f, length(vdl.f) - wordindex(vdl.f, 5) + 1)
            f= f + 1
            used= used - word(vdl.f, 3)
            say 'Used space in 'save_path' is now: 'used' bytes.'
            call syssleep 1
          end
        end
      end
      /* CLEAR space routine */
      freesp= word(sysdriveinfo(substr(save_path, 1, 2)), 2)
      say 'Free space is: 'freesp' bytes.'
      if reqsp > freesp & clear = 1 then do /* delete (oldest) files */
        rc= sysfiletree(save_path||'\*.MP3', vdl., 'F')
        f= 1 /* PRESUMED oldest because ONLY MP3s created by TIME4SR in dir */
        do until (freesp > reqsp) | (f > vdl.0)
          'del 'right(vdl.f, length(vdl.f) - wordindex(vdl.f, 5) + 1)
          f= f + 1
          freesp= word(sysdriveinfo(substr(save_path, 1, 2)), 2)
          say 'Free space is now: 'freesp' bytes.'
          call syssleep 1
        end
      end
      drop vdl.
      say  /* if enough files couldn't be deleted, copy fails normally... */
      'copy 'spool_path||ready2move||'.MP3 '||save_path
      'del 'spool_path||ready2move||'.MP3'
      'copy 'spool_path||ready2move||'.CUE '||save_path
/* .cue files will clutter drive, THOUGH have potentially useful info */
      'del 'spool_path||ready2move||'.CUE'
      ready2move= ''
    end
    curlin= substr(ref.ch, cm + 1, 1) /* now current line # for outer loop */
    curact= kw
    call syscls
    call show_sched
    call syscurpos 20, 1
    call charout, 'Running # '||c2d(curlin)
  end /* curlin \= refc */
end /* main loop */
exit

check_running: /* sets sr_running, avoids duplicating code */
  sr_running= 0
  call sysqueryswitchlist "windowlist.", 'd'
  do w= 1 to windowlist.0
    if pos(vio_title, windowlist.w) > 0 then sr_running= 1
  end
return

read_pls: /* can also be .m3u! */
parse arg pls_name
if stream(pls_name, 'c', 'query exists') <> '' then do
  say 'Reading playlist...'
  ndx= 0
  do until lines(pls_name) = 0
    ndx= ndx + 1
    pls_text.ndx= linein(pls_name)
  end
  ok= stream(pls_name, 'c', 'close')
  pls_text.0= ndx
end /* file exists */
else do
  say 'Cannot find playlist: 'pls_name
  exit
end
return

message:
  parse arg m
  m= left(m, 78) /* n.b. left() PADS with spaces, handy here */
  call syscurpos 24, 1
  call charout, m
  last_message= m /* kludge for persistent messages, such as stream name */
return

get_playlists: /* for random stream */
  parse arg pld
  if lastpos('\', pld) \= length(pld) then pld= pld||'\'
  pld= pld||'*'
  drop pl. /* clear any existing playlist */
  rc= SysFileTree(pld, "pl.", "FO")
  i= 1
  do while i <= pl.0 /* get rid of any non-playlist */
    fext= translate( right(pl.i, (length(pl.i) - lastpos(".", pl.i) + 1 )))
    if fext <> '.M3U' & fext <> '.PLS' then do
      do j= i to pl.0 - 1
        k= j + 1 /* hmm; any other way to handle math on stem. index #s? */
        pl.j= pl.k
      end
      drop pl.k
      pl.0= pl.0 - 1
    end
    i= i + 1
  end /* while */
return

read_file:
if stream(sched_name, 'c', 'query exists') <> '' then do
  say 'Reading schedule...'  /* KEEP ALL lines for easy reference in .sch */
  ndx= 0
  do until lines(sched_name) = 0 /* make some minor modifications to text */
    tline= strip(linein(sched_name), 'B', ' ') /* filename case preserved */
    p= pos(':', tline) /* remove lead zero from hour for later ease */
    if p > 0 then if substr(tline, p - 2, 1) = '0' then
      tline= delstr(tline, p - 2, 1)
    p= pos(':', tline) /* remove lead zero from minutes for later ease */
    if p > 0 then if substr(tline, p + 1, 1) = '0' then
      tline= delstr(tline, p + 1, 1)
    ndx= ndx + 1
    slin.ndx= tline
  end
  ok= stream(sched_name, 'c', 'close')
  slin.0= ndx
end /* file exists */
else do
  say 'Cannot find schedule file: 'sched_name
  exit
end
return

init_scheds:  /* ref.23 used temporary for convenience */
ref.23= '|'||copies('ù', 4)||d2c(179)||copies('ù', 4)||d2c(179)||copies('ù', 4)
do l=0 to 23
  show.l= l||' '||copies(ref.23, 4) /* copy 4 of quarter hour marks */
  if (l<10) then show.l='0'||show.l
  ref.l= copies(d2c(0), 60)
end
return

interp_sched:
day= substr(date('W'), 1, 3)
nd= (pos(day, numday) - 1) / 3 + 1 /* find a # 1-7 representing day */
call init_scheds
do ndx= 1 to slin.0
  if pos('SAVEPATH', slin.ndx) = 1 then do  /* WILL CREATE IF DOESN'T EXIST */
    save_path= right(slin.ndx, length(slin.ndx) - wordindex(slin.ndx, 2) + 1)
    curdir= directory() /* must save start point */
    rc= directory(save_path) /* changes TO if exists! */
    call directory(curdir) /* change back on logged drive */
    if rc= '' then do /* null means does not exist */
      rc= sysmkdir(save_path)
      if rc <> 0 then do
        say 'Problem creating directory 'save_path
        exit
      end
    end
  end                     /* v1.4 kludge to PATCH UP drive letter */
  else if ramdrive <> '' & lastpos(':\', slin.ndx) > 0 then do
    slin.ndx= overlay(ramdrive, slin.ndx, lastpos(':\', slin.ndx) - 1)
  end  /* NOTE else clause so definitely DOES NOT 'patch up' SAVEPATH! */
  if pos('CLEAR', slin.ndx) = 1 then do
    clear = 1 /* SET FLAG TO CLEAR (OLDEST) FILES FROM SAVE_PATH */
  end
  if pos('MAX', slin.ndx) = 1 then do
    maxsp= translate(word(slin.ndx, 2)) /* format 1.8G or 700M or 500000000 */
    if maxsp = '' then maxsp= '1G'
    m= substr(maxsp, length(maxsp), 1)
    if (m = 'G' | m = 'M') then do
      maxsp= left(maxsp, length(maxsp) - 1)
      if m = 'G' then maxsp= maxsp * 1000000000
      if m = 'M' then maxsp= maxsp * 1000000
    end
  end
  kw= translate(left(slin.ndx, 3))
  if kw= 'REC' then do  /* the only keyword left from tz.cmd */
    oc= substr(legend.5, 1, 1)
    days= word(slin.ndx, 2)
    if substr(days, nd, 1) = substr(day, 1, 1) then do
      dur= word(slin.ndx, 4)
      if pos(':', dur) > 0 then do  /* optional hours:minutes form */
        parse value word(slin.ndx, 4) with sth ':' stm /* temporary use */
        if pos('0', stm) = 1 & length(stm) > 1 then /* strip any leading '0' */
          stm= delstr(stm, 1, 1) /* hmm, another way to do this in REXX... */
        dur= sth * 00 + stm 
        wi= wordindex(slin.ndx, 4)
        s= delstr(slin.ndx, wi, length(word(slin.ndx, 4)))
        s= insert(dur, slin.ndx, wi - 1) /* replace h:m form of duration */
      end
      parse value word(slin.ndx, 3) with sth ':' stm /* now re-use vars */
      remdr= oc||substr(slin.ndx, lastpos('\', slin.ndx) + 1)
      remdr= substr(remdr, 1, lastpos('.', remdr) - 1)
      if length(remdr) + 5 > dur then remdr = left(remdr, dur - 5)
      cl= sth
      n= 1
      m= stm
      do while n <= dur
        select
        when n = 1 then tc= 'Þ'
        when n = 2 then tc= d2c(16)
        when n > 2 & n < length(remdr) + 3 then tc = substr(remdr, n - 2, 1)
        when n = dur - 1 then tc= d2c(17)
        when n = dur then tc= 'Ý'
        otherwise tc= oc /* if possible fill out with code char */
        end
        show.cl= overlay(tc, show.cl, m + 4) /* offset in show. for hour digits */
        ref.cl= overlay(d2c(ndx), ref.cl, m + 1)
        n= n + 1
        m= m + 1
        if m > 59 then do
          cl= cl + 1
          if cl > 23 then cl= 0 /* primitive protection; just wraps around */
          m= 0
        end
      end /* while n <= dur */
    end /* passed check, runs today */
  end /* oc \= '?' */
end /* do */
return /* interpret */

show_sched:
do l= 0 to 23
  call syscurpos l, 1
  select /* for displaying various info */
    when l = 21 then call charout, date('N')
    when l = 22 then call charout, date('W')
    otherwise nop
  end
  call syscurpos l, 16
  call charout, show.l
end
call syscurpos 1, 0
call charout, vio_title
call syscurpos 2, 0
call charout, ' scheduler v1'
call syscurpos 19, 0
call charout, '®ÄÄÄÄInfo:ÄÄÄÄ¯'
if substr(last_message, 1, 1) = d2c(22) then do
  call syscurpos 24, 1
  call charout, last_message
end
call syscurpos 24, 69
call charout, 'H for Help'
return

delete_tree:
parse arg ttd
/*  section modified from DELTREE.CMD by Mark Polly & Carl Harding */
rc= sysfiletree(ttd||'\*.*', dl2, 'BSO', '***+*', '-**-*') /* for safety, */
rc= sysfiletree(ttd||'\*.*', dl2, 'FSO')   /* clears ^ just read-only */
do x = 1 to dl2.0
  rc = sysfiledelete(dl2.x)
end
rc=sysfiletree(ttd||'\*.*', dl2, 'DSO')
do x = dl2.0 to 1 by -1
  rc=sysrmdir(dl2.x)
end
rc=sysrmdir(ttd)
drop dl2.
/* end of cribbed section */
return

ex_read_key: /* returns two bytes for extended codes */
  xrkey= sysgetkey('noecho')
  if xrkey = zky | xrkey = xky then xrkey= xrkey||sysgetkey('noecho')
return xrkey

keys_and_colors:
/* ANSI screen color thanks to someone, modified */
black= 0; red= 1; green= 2; yellow= 3; blue= 4; magenta= 5; cyan= 6; white= 7;
fgnd= 30         /* add color: 30 + 2= 32 ==> green foreground */
bgnd= 40         /* add color: 40 + 7= 47 ==> white background */
AEsc= '1B'x || '['  /* define ANSI-Escape; + 0 = low, 1 = high int*/
l_wh_bk= AEsc||'0;'||fgnd + white||';'||bgnd + black||'m'
l_bk_wh= AEsc||'0;'||fgnd + black||';'||bgnd + white||'m'
call charout, l_wh_bk /* ensure low white on black esp after testing */

/* codes for most useful keys; see ex_read_key */
zky= x2c('00') /* prefix for some extended keys */
xky= 'à' /* another prefix for some extended keys */
k_esc= x2c('1b');  k_enter= x2c('0d');  k_backspace= d2c(8);  k_tab= d2c(9);
numday= 'SunMonTueWedThuFriSat'
legend.1= d2c(205) /* change graphics key chars HERE */
legend.2= d2c(240) /* leftovers from tz.cmd because a bit entangled */
legend.3= d2c(175)
legend.4= d2c(247)
legend.5= d2c(254)||' Record'
return

show_help:
call syscls
say splash' (minimal) Help...'
say
say ' Er... Not sure how useful these are, but leaving for now...'
say
say ' X eXit, leaves "'vio_title'" running (if it is); this is a feature'
say
say ' ` Attempts to refresh stream (for stream errors that cause an exit)'
say ' ~ STOPS current action for the day (undo with <backspace>)'
say ' <backspace> re-start; useful if TIME4SRx.SCH changed'
say
say ' Hit any key to resume, or wait 60 seconds...'
n= 0
do until chars() > 0 | n > 60
  call syssleep 1
  n= n + 1
end
if chars() > 0 then key= ex_read_key()
return

