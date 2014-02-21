/* Time-4-Z Scheduler Front End version - Plain OS/2 REXX and REXXUTIL */
/* for the Z! text-mode MP3 player by dink, http://dink.org/z/ */
splash= d2c(22)||' Time4Z by DGD -- Front-end scheduler for Dinks Z v1.4'
/* begun 11-16-2006; first recording 11-28-2006
- v0.9 spooling to RAM, much clean up and improvement 04-05-2007
    function key favorites; improvement? well, broke nothing obvious 12-21-2007
- v1.0 merged file selector for browse mode 12-27-2007
- v1.1 CLEAR frees up space; file selector less lag, help neater 03-12-2008
    QUERY SWITCH LIST (duh, was in rexxutil) to check z IS running 03-21-2008
- v1.2 MAX strategy limits size of save_path dir 04-08-2008
    Probably fixed MAX strategy bug of exiting on failed stream 05-28-2008
- v1.3 fixed major but simple bug if save_path dir was empty 11-12-2008
    problem of Z missing write command solved by increased delay 01-14-2008
- v1.4 added copy of \TZ dir to a RAMDRIVE with command line parameter so that
    HD can spin down indefinitely even with random streaming. Usage> tz z:
    REQUIRES manual re-sync if TZ.SCH is modified while TZ is running.
*/

/* INSTALLATION: existing TZ.SCH is unchanged, edit sched_name below */

/* NOTE: updating to http://dink.org/files/z_oct_16_2008.zip produces about
   one minute (@ 16kbps) duplicated with SPLIT recordings, perhaps because
   my method resets its buffer pointer. Doubt the effect is intentional, and
   it can even be HANDY as previously was a small gap. But it's peculiar...
*/

call rxfuncadd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call sysloadfuncs
Call SysCurState 'OFF'
call syscls

/* style point, spacing of "=": 'var=' indicates assignment, 'var =' test */

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
k_up= 'àH';      k_down= 'àP';    k_left= 'àK';    k_right= 'àM';
k_ins= 'àR';     k_del= 'àS';     k_home= 'àG';    k_end= 'àO';
k_pgup= 'àI';    k_pgdn= 'àQ';
k_cleft= 'às';   k_cright= 'àt';  k_cup= 'à'||d2c(141);  k_cdn= 'à'||d2c(145);
k_f1= zky||';';  k_f2= zky||'<';  k_f3= zky||'=';  k_f4= zky||'>';
k_f5= zky||'?';  k_f6= zky||'@';  k_f7= zky||'A';  k_f8= zky||'B';
k_f9= zky||'C';  k_f10= zky||'D'; k_f11= zky||d2c(133);  k_f12= zky||d2c(134);
fkeys= k_f1||k_f2||k_f3||k_f4||k_f5||k_f6||k_f7||k_f8||k_f9||k_f10||k_f11||k_f12

/* these VARs are pretty much CONSTANTS */
ramdrive= ''
parse arg ramdrive     /* v1.4 implement copying to ramdrive */
if ramdrive = '' then sched_drive= 'C:'
else do   /* copy TZ dir which MUST BE on 'C:', somewhat necessary kludge */
  sched_drive= ramdrive
  call delete_tree sched_drive||'\TZ' /* darn it, must remove if exists */
  'mkdir 'sched_drive'\TZ'
  'xcopy C:\TZ\* 'sched_drive'\TZ /s /e'
end
sched_path= sched_drive||'\TZ\'
sched_name= sched_path||'EXAMPLE.SCH' /* ***** EDIT ON INSTALL to TZ.SCH */
home_dir= sched_path||'favored\'
zwindowtitle= 'Z for named pipe'
numday= 'SunMonTueWedThuFriSat'
pipe_to= ' 1>\pipe\zmp3' /* the "1" refers to stdout; here for info because
  highly confusing when REXX changes literal " > \pipe\zmp3" to this anyway */
legend.1= d2c(205)||' MP3s in dir' /* change graphics key chars HERE */
legend.2= d2c(240)||'  ÀÄ & random'
legend.3= d2c(175)||' Stream'
legend.4= d2c(247)||'  ÀÄ & random'
legend.5= d2c(254)||' Record'
secsaday= 86400 /* seconds a day */

save_path= sched_path /* just to set other than nil */
clear= 0 /* CLEAR flag */
maxsp= 0 /* MAX space: set from keyword in TZ.SCH */
save_interval= 0
slin.0= 0 /* schedule file, 0 holds # of lines read */
show.0= '' /* 24x60 "array" for display. Initialized here only for info */
ref.0= '' /* similar to above, holds reference to line numbers of tz.sch */
pl.0= 0 /* playlist */

/* following VARs actually change */
curlin= '' /* current line running of tz.sch; when \= the character of */
  /* pseudo-array ref.[hour, minute], then some action is needed */
startday= ''
curact= ''
sleeptime= 1
refc= d2c(255) /* just to ensure \= to curlin */
last_message= '' /* avoids some tangles knowing which stream is playing */
interval= secsaday /* yet another kludge tacked on along with below */
split= secsaday /* time in seconds to split recordings */
looptime= 0  /* counts seconds to change random streams or split recordings */
move2= '' /* flag, set to dtfn formed below, without paths */
ready2move= '' /* 2nd flag, preserving if started writing another file */
rrst= ''
writing= 0

/* start File Selector specific */
parse value systextscreensize() with scry scrx
scry= scry - 1; scrx= scrx - 1; /* adj to 0, 0 based values */
numeric digits 12 /* necessary to display bytes of gigabytes */
glo_var= 'dirlist.'
dircolr= AEsc||'0;'||fgnd + white||';'||bgnd + black||'m' /* directory */
revcolr= AEsc||'0;'||fgnd + black||';'||bgnd + white||'m' /* reversed */
ansi_clreol= AEsc||'K'
/* end File Selector specific */

call protect sched_path

do forever
  if startday \= date('S') then do /* 1st run or passed midnight */
    startday = date('S')
    call read_file
    call syscls
    call interp_sched
    call message splash
    call show_sched
  end
  key = ''
  if chars()>0 then do
    key= ex_read_key()
    n= pos(key, fkeys) /* to convert rather random scan codes into simple # */
    select
      when n > 0 then do /* F1-F12 keys choose from favorite streams */
        call select_stream (n + 1) / 2
      end
      when (key = k_tab) & (writing = 0) then do /* if not recording, browse */
        call syscls
        call run_browse_mode
        call protect sched_path /* in case of sched change during browse... */
        call syscls
        call show_sched
      end
      when key = k_backspace then do /* re-start, re-read TZ.SCH */
        startday = ''
        curlin= '0'
      end
      when key = 'h' | key = 'H' then do
        call show_help
        call syscls
        call show_sched
      end
      when key = '`' then do  /* Refresh attempt for stream errors... */
        curlin= '0' /* triggers "new action" below; stops writing, quits z */
        if curact = 'REC' then split= secsaday
      end
      when key = '~' then do /* "Rem out" the current action to STOP it */
        curlin= '0' /* triggers "new action" below */
        refc= c2d(value('refc')) /* un-de-code the line # */
        slin.refc= '~'||slin.refc /* add tilde; remove to restore line... */
        call interp_sched /* and start over with that line being skipped */
      end
      otherwise select /* available commands vary with current action */
      when curact = 'RST' then do /* only this or "otherwise" at present... */
        key= translate(key)
        select
          when key = 'R' then do /* Random... */
            call z_quit
            call syssleep 1
            if save_interval > 0 then do /* restore to normal after a Stay */
              interval= save_interval
              save_interval= 0
            end
            call random_stream
          end
          when key = 'S' then do /* Stay on station (for rest of day) */
            save_interval= interval
            interval= secsaday
          end
          otherwise nop
        end /* RST key select */
      end /* RST mode */
      otherwise nop
      end /* of mode-dependent select */
    end /* outermost select */
    looptime= 0 /* for now, any key resets timer */
  end
  else call syssleep sleeptime
  if key = 'X' | key = 'x' then leave
  now= time('N')
  parse value now with ch ':' cm ':' cs
  if pos('0', ch) = 1 then ch= delstr(ch, 1, 1)
  if pos('0', cm) = 1 then cm= delstr(cm, 1, 1)
  if pos(':00:00', now) = 3 then call show_sched /* hourly full refresh */
  else if pos(':00', now) = 6 then do /* v1.1 EVERY MINUTE CHECK Z RUNNING */
    call sysqueryswitchlist "windowlist.", 'd' /* Umm, lately discovered by */
    zrunning= 0   /* accident this "new" function in standard rexxutil dll */
    do w= 1 to windowlist.0  /* which allows simple (crude) monitoring. */
      if pos(zwindowtitle, windowlist.w) > 0 then zrunning= 1
    end  /* So, if stream errors cause Z to quit, this tries re-start(s). */
    if zrunning = 0 & curact = 'REC' then do /* ONLY while recording. */
      call syscurpos 22, 1
      call charout, l_bk_wh||' !!! Z HAS APPARENTLY STOPPED! ATTEMPTING TO RE-START.'||l_wh_bk
      call syscurpos 23, 1
      curlin= '0'
      split= secsaday
    end
    call syscurpos ch, 16  /* line refresh cleans up some garbage highlight */
    call charout, show.ch  /*  chars left because of clock uncertainties */
  end         /* below flashes cursor white on black */
  if pos(substr(cs, 2, 1), '02468') > 0 then call charout, l_bk_wh
  call syscurpos ch, cm + 19 /* offset on screen */
  call charout, substr(show.ch, cm + 4, 1)
  call charout, l_wh_bk
  call syscurpos 23, 1
  call charout, now
  refc= substr(ref.ch, cm + 1, 1)
  looptime= looptime + 1
  /* CHECK IF NEW ACTION REQUIRED - (starts schedule even from middle) */
  if (curlin \= refc) | (looptime > interval) | (looptime > split) then DO
    interval= secsaday /* reset to max every pass through here */
    if curlin \= '' then do /* presumably every time except very first */
      if writing = 1 then do
        call z_writetodisk ''
        call message 'STOP writing...'
        writing= 0
        if move2 \= '' then do
          call message 'Setting MOVE flag...'
          ready2move= move2
        end
        else ready2move= ''
      /* problem of missing a recorded segment seemed to occur right here */
      /* possibly because drive has been spun down, so */
        call syssleep 5  /* give system PLENTY of time to react... */
      end /* writing */
      if split = secsaday then do /* effect is DON'T quit Z if splitting */
        call z_quit /* QUIT */
        call message 'Telling Z to quit...'
        call syssleep 3
      end
      move2= '' /* always set flag off */
    end /* curlin \= '' */
    /* REXX is just REPLETE with contortions; better explain this one to _me_*/
    refc= c2d(value('refc')) /* refc is char = line #; convert it to _#_ */
    curlin= slin.refc /* to refer to slin.# - curlin only a handy var here */
    /* n.b. curlin= value('slin.'refc) looks more elegant, but doesn't work */
    /* and tried other variations without success; the above works FINE */

    /* 2nd command because seems to not reliably QUIT after a stop writing */
    if refc = 0 then do
      call z_quit
      call message 'No event scheduled; again sending QUIT to Z...'
      call syssleep 3
    end
    kw= translate(left(curlin, 3)) /* vars duplicated from interp */
    parse value word(curlin.ndx, 3) with sth ':' stm
    dur= word(curlin, 4)
    /* may be other parameters present, processed by each type */
    remdr= right(curlin, length(curlin) - lastpos(':\', curlin) + 2)
    /* the above depends on each key type specifying drive:\dir last */
    select   /* start Z EVERY time; avoids problem when changing from */
      /* stream to local; Z EXITS then anyway - see z_stream proc below */
      /* seems streams can't use pipe, REQUIRE COMMAND LINE PARMS?! */
      when kw= 'DIR' | kw= 'RND' then do
        call z_start
        if lastpos('\', remdr) <> length(remdr) then remdr= remdr||'\'
        rc= sysfiletree(remdr||'*.MP3', "olist.", "FSO")
        if kw= 'RND' then do /* randomize list; tougher than appears... */
          m= olist.0  /* other methods tried were a bit less than random */
          list.0= olist.0
          do n= 1 to olist.0 - 1
            r= random(1, m)
            list.n= olist.r
            do x= r to m - 1
              y= x + 1
              olist.x= olist.y
            end
            m= m - 1
          end
          n= olist.0
          list.n= olist.1
        end
        else do  /* simulate the above kludge for a DIR */
          do n= 0 to olist.0
            list.n= olist.n
          end
        end
        drop olist.
        do n= 1 to list.0
          call message 'Sending: '||list.n
          list.n= '"'||list.n||'"'
          call z_play list.n
          call syssleep 3 /* hmm; is this enough time? */
        end
      end
      when kw= 'STR' then do
        call message d2c(22)||' Streaming: 'remdr
        call z_stream remdr
        call syssleep 3
      end
      when kw= 'RST' then do
        interval= word(curlin, 5)
        if datatype(interval) <> 'NUM' then interval= dur
        interval= interval * 60 /* convert to seconds */
        call get_playlists remdr
        call random_stream
      end
      when kw= 'REC' then do
        if pos('PATH', curlin) > 0 then do
          i= pos('"', curlin) + 1
          spool_path= substr(curlin, i, lastpos('"', curlin) - 1 - i)
        end
        else spool_path= save_path
        if lastpos('\', spool_path) \= length(spool_path) then
          spool_path= spool_path||'\'
        if split = secsaday then do /* start only if 1st pass */
          call z_stream remdr
          call message 'Z should be buffering stream: 'remdr
          call syssleep 20 /* v1.3 LONG because slow sites miss write start */
        end                /* or, may be due to running several torrents! */
        if wordpos('SPLIT', curlin) > 0 then do
          split= word(curlin, wordpos('SPLIT', curlin) + 1)
          split= split * 60 /* seconds */
        end
        else split = secsaday
        dtfn= substr(date('S'), 3, 6)||'_'||substr(time('N'), 1, 5)
        dtfn= delstr(dtfn, 10, 1) /* keep name separate for easy MOVE */
        if pos('MOVE', curlin) > 0 then move2= dtfn /* ^also a flag */
        dtfn= spool_path||dtfn
        call z_writetodisk dtfn
        call message 'Z should start writing file 'dtfn
        call syssleep 3
        call message d2c(22)||' Recording: 'remdr
        writing= 1
      end
    otherwise nop
    end /* select RUN */
    if ready2move \= '' then do /* FILE WAITING TO BE MOVED */
    /* could get rid of clutter with "@" and ">nul", but I like to see... */
      call syscls
      say ' Moving recorded file - possibly clearing space - and cleaning up...'
      rc= sysfiletree(spool_path||ready2move||'.MP3', vdl., 'F')
      reqsp= word(vdl.1, 3) /* required space for current file */
      if reqsp = '' then reqsp= 0 /* avoids crash at "do while" below */
      /* v1.2 - MAX strategy supplements CLEAR by limiting directory size */
      if maxsp > 0 then do
        rc= sysfiletree(save_path||'\*.MP3', vdl., 'F')
        used= 0
        if vdl.0 > 0 then do  /* IF any files, total up directory size */
          do f= 1 to vdl.0
            used= used + word(vdl.f, 3)
          end
        end
        say 'Used space in 'save_path' is: 'used' bytes; MAX is: 'maxsp'.'
        f= 1 /* assumes #1 is the OLDEST file, true if all named by TZ.SCH */
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
        f= 1  /* PRESUMED oldest because ONLY MP3s created by TZ in dir */
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
      'del 'spool_path||ready2move||'.MP3.TXT'
      ready2move= ''
    end
    if kw <> 'REC' then split= secsaday
    curlin= substr(ref.ch, cm + 1, 1) /* now current line # for outer loop */
    curact= kw
    call syscls
    call show_sched
    call syscurpos 20, 1
    call charout, 'Running # '||c2d(curlin)
    looptime= 0
  end /* curlin \= refc */
end /* main loop */
exit

run_browse_mode:
rbm_quit= 0
curpath= sched_path
cursel= ''
types= '*.MP3 *.WAV *.PLS *.M3U'
do while rbm_quit = 0
  rv= file_select(40, glo_var, curpath, types, '', cursel, 'N', 'M', '', 1)
  rk= word(rv, 1)
  if (rk = k_esc) | (rk = k_tab) then rbm_quit= 1
  else do /* þ */
    call syscurpos 23, 1
    call syssleep 1
    remdr= right(rv, length(rv) - wordindex(rv, 4) + 1) /* remainder */
    curpath= filespec("drive", remdr)||filespec("path", remdr)
    cursel= filespec("name", remdr)
    if pos('.', cursel) > 0 then
      rt= translate(substr(cursel, lastpos('.', cursel), 4))
    else rt= ''
    select
      when rk = k_enter & pos('.', rv) > 0 then do
        call z_quit
        call syscls
        if rt = '.MP3' | rt = '.WAV' then do
          call z_start
          call message d2c(22)||' 'remdr
          call z_play '"'||remdr||'"'
        end
        if rt = '.M3U' | rt = '.PLS' then do
          call syssleep 2 /* without delay Z doesn't start up again, hmm */
          call protect curpath
          call message d2c(22)||' 'remdr
          call z_stream remdr
        end
        call syssleep 1
      end /* k_enter */
      when rk = '\' then do /* make a new directory */
        call syscurpos 1, 1
        call charout, 'Make a new directory?'
        call syscurpos 2, 1
        call charout, 'Hit <enter> to exit without doing so.'
        call syscurpos 3, 1
        call charout, 'Make: '
        parse pull newname .
        if newname <> '' then do
          curpath= strip(curpath, 'T', '\')
          curpath= left(curpath, lastpos('\', curpath) - 1)
          'mkdir 'curpath||newname
          curpath= filespec("drive", remdr)||filespec("path", remdr)
        end     /* ^ MUST restore curpath so shows same dir */
        call syscls
      end
      when rk = k_home then do /* mark home directory */
        rt= word(rv, 2) /* get index; check really is dir */
        if (rt > 2) & (substr(dirlist.rt, wordindex(dirlist.rt, 4) + 1, 1) = 'D')
          then home_dir= remdr||'\'
      end
      when (rk = k_ins) & (rt = '.M3U' | rt = '.PLS') then do
        call syscurpos 1, 1                           /* copy IF playlist */
        call charout, 'Copying playlist to '||home_dir
        call syscurpos 2, 1
        call charout, 'Just hit <enter> to use current name.'
        call syscurpos 3, 1
        call charout, 'Currently: '||cursel
        call syscurpos 4, 1
        call charout, 'Rename to: '
        parse pull newname .
        if newname = '' then newname= cursel
          else newname= newname||rt
        'copy "'||remdr||'" "'||home_dir||newname||'"'
      end
      when (rk = k_del) & (rt = '.M3U' | rt = '.PLS') then do
        rc= SysFileTree(remdr, lists, 'FO', '****', '----')
        'del "'||remdr||'"'
        if length(word(rv, 3)) < 4 then do /* avoids bug when dir emptied */
          curpath= strip(curpath, 'T', '\') /* at cost of possible confusion */
          curpath= left(curpath, lastpos('\', curpath) - 1)
          cursel= ''
        end
        call syscls
      end
      otherwise call beep 2000, 50
    end /* select */
  end /* not <esc> or <tab> */
end /* rbm_quit */
return

show_help:
call syscls
say splash' (minimal) Help...'
say
say ' X eXit, leaves "'zwindowtitle'" running (if it is); this is a feature'
say
say ' ` Attempts to refresh stream (for stream errors that cause Z to exit)'
say ' ~ STOPS current action for the day (undo with <backspace>)'
say ' <backspace> re-start; useful if TZ.SCH changed'
say
say ' <tab> switch to Browse mode (if not recording). Sub-commands:'
say '   <enter> play a playlist or local file; interrupts any playing'
say '   <home> sets where to copy playlists to; currently 'home_dir
say '   <ins> copy playlist to home directory, optionally renaming'
say '   <del> IMMEDIATELY deletes a playlist (.M3U or .PLS) but NO other files'
say '   <tab> or <esc> returns to Scheduled mode'
say '   \ (backslash) make a new directory'
say '   <F1> help in File Selector; most important are lowercase a-z for drive'
say
say ' <F1> - <F12> are to be set up in TZ.SCH; if set, show left of number'
say
say ' These work only during Random STreaming:'
say '   R select a new Random Stream'
say '   S Stay on current stream (to end of day...)'
say
say ' Hit any key to resume, or wait 60 seconds...'
n= 0
do until chars() > 0 | n > 60
  call syssleep 1
  n= n + 1
end
if chars() > 0 then key= ex_read_key()
return

ex_read_key: /* returns two bytes for extended codes */
  xrkey= sysgetkey('noecho')
  if xrkey = zky | xrkey = xky then xrkey= xrkey||sysgetkey('noecho')
return xrkey

protect:
/* SET read-only attributes which are NOT set on playlists under \TZ */
/* This rather complex task turns out to be EASY to do ELEGANTLY in REXX! */
parse arg m
if substr(m, length(m), 1) \= '\' then m= m||'\'
rc= SysFileTree(m||'*.PLS', lists, 'FSO', '***-','---+')
drop lists.
rc= SysFileTree(m||'*.M3U', lists, 'FSO', '***-','---+')
drop lists.
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

random_stream:
  n= rrst
  do until n \= rrst  /* so doesn't pick the current */
    rrst= random(1, pl.0)
  end
  call message d2c(22)||' Random Stream: 'pl.rrst /* persistent message */
  call z_stream pl.rrst
return

/* attempts named pipe to not stop writing, despite apparent problem... */
select_stream:
  parse arg fkeyn
  call message d2c(22)||' Selected Stream: 'favlist.fkeyn
  call z_stream favlist.fkeyn
return

read_file:
if stream(sched_name, 'c', 'query exists') <> '' then do
  say 'Reading schedule...'  /* KEEP ALL lines for easy reference in .sch */
  ndx= 1
  do until lines(sched_name) = 0 /* make some minor modifications to text */
    tline= strip(linein(sched_name), 'B', ' ') /* filename case preserved */
    p= pos(':', tline) /* remove lead zero from hour for later ease */
    if p > 0 then if substr(tline, p - 2, 1) = '0' then
      tline= delstr(tline, p - 2, 1)
    p= pos(':', tline) /* remove lead zero from minutes for later ease */
    if p > 0 then if substr(tline, p + 1, 1) = '0' then
      tline= delstr(tline, p + 1, 1)
    slin.ndx= tline
    ndx= ndx + 1
  end
  ok= stream(sched_name, 'c', 'close')
  slin.0= ndx - 1
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
  select /* set graphics char (from legend.) for pseudo-array show. */
    when kw= 'DIR' then oc= substr(legend.1, 1, 1)
    when kw= 'RND' then oc= substr(legend.2, 1, 1)
    when kw= 'STR' then oc= substr(legend.3, 1, 1)
    when kw= 'RST' then oc= substr(legend.4, 1, 1)
    when kw= 'REC' then oc= substr(legend.5, 1, 1)
    when kw= 'FKY' then do /* function key defs */
      oc= '?' /* force skip on below test */
      n= word(slin.ndx, 2) /* format: FKY 1 c:\path\filename */
      favlist.n= word(slin.ndx, 3)
    end
  otherwise oc= '?'
  end /* select */
  if oc \= '?' then do  /* to skip if no keyword found */
    days= word(slin.ndx, 2)
    if substr(days, nd, 1) = substr(day, 1, 1) then do
      dur= word(slin.ndx, 4)
      if pos(':', dur) > 0 then do  /* optional hours:minutes form */
        parse value word(slin.ndx, 4) with sth ':' stm /* temporary use */
        if pos('0', stm) = 1 & length(stm) > 1 then /* strip any leading '0' */
          stm= delstr(stm, 1, 1) /* hmm, may not be necessary in REXX... */
        dur= sth * 60 + stm
      end
      parse value word(slin.ndx, 3) with sth ':' stm /* now re-use vars */
      remdr= right(slin.ndx, length(slin.ndx) - lastpos('\', slin.ndx))
      remdr= oc||remdr
      if kw= 'RST' then remdr= remdr||' '||word(slin.ndx, 5)
      if wordpos('SPLIT', slin.ndx) > 0 then do
        p= word(slin.ndx, wordpos('SPLIT', slin.ndx) + 1)
        remdr= remdr||' '||p
      end
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
  call syscurpos 0, 0
  call charout, '®ÄÄFavorites:Ä¯'
  call syscurpos 13, 0
  call charout, '®ÄÄÄLegend:ÄÄÄ¯'
  call syscurpos 19, 0
  call charout, '®ÄÄÄÄInfo:ÄÄÄÄ¯'
  call syscurpos l, 1
  select /* for displaying various info */
    when (l > 0) & (l < 13) then do /* function key list */
      n= filespec('N', favlist.l)
      if length(n) > 1 then call charout, substr(n, 1, pos('.', n) - 1)
    end
    when (l > 13) & (l < 19) then do
      n= l - 13
      call charout, legend.n
    end
    when l = 21 then call charout, date('N')
    when l = 22 then call charout, date('W')
    otherwise nop
  end
  call syscurpos l, 16
  call charout, show.l
  if substr(last_message, 1, 1) = d2c(22) then do
    call syscurpos 24, 1
    call charout, last_message
  end
  call syscurpos 24, 69
  call charout, 'H for Help'
end
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

exit /* catch all slips through... */

/* --- Z pipe control (not all routines are used) ------------------------ */
/* --- presumably, only the parts below need modified to use with PM123... */

/* --- n.b. now not sure whether pipe vs command line problems really exist */
/* --- seemed similar to problems others had with pipes not always present */
/* --- but it's too dicey and time consuming to re-do the 'right' way... */

/* START actually exits when already streaming; see z_stream below... */
z_start:
'@start "'zwindowtitle'" /N /B /PGM "C:\Z28\Z.EXE"'
call syssleep 3 /* give system some time... */
return

/* pause            - pause playback */
z_pause:
'@echo *pause' pipe_to
return

/* mute             - mute playback */
z_mute:
'@echo *mute' pipe_to
return

/* next             - jumps to the next track */
z_next:
'@echo *next' pipe_to
return

/* previous         - jumps to the previous track */
z_previous:
'@echo *previous' pipe_to
return

/* stop             - stops playback and returns to the file-selector */
z_stop:
'@echo *stop' pipe_to
return

/* seek [x]         - seek to position in track (in seconds, -# to seek back */
z_seek:
'@echo *seek' pipe_to
return

/* vol+             - raises the volume a bit */
z_volraise:
'@echo *vol+' pipe_to
return

/* vol-             - lowers the volume a bit */
z_vollower:
return
'@echo *vol-' pipe_to

/* quit             - quits z! */
z_quit:
'@echo *quit' pipe_to
 call syssleep 3 /* attempt "fix" for 1.1, 1.2 changes leaving z running */
return

/* play [x]         - plays file [x] if not already playing something, */
/*                    otherwise it just adds to the playlist */
z_play:
parse arg fs
'@echo *play 'fs pipe_to
return

/* STREAMING would use z_play IF it worked as expected, but doesn't seem */
/* to accept .pls from named pipe, so calling Z directly... */
z_stream:
parse arg fs
'@start "'zwindowtitle'" /N /B /PGM "C:\Z28\Z.EXE"' fs
call syssleep 3 /* hope enough time to establish stream... */
return

/* add [x]          - adds file [x] to the playlist */
z_add:
parse arg fs
'@echo *add' pipe_to
return

/* addlist [x]      - adds all the files in the playlist file [x] */
z_addlist:
parse arg pls
'@echo *addlist' pls pipe_to
return

/* addnext [x]      - adds file [x] after the current playing file */
z_addnext:
'@echo *addnext' pipe_to
return

/* shout [x]        - immediately plays file [x] then continues w/playlist */
z_shout:
'@echo *shout' pipe_to
return

/* clearlist        - clears the playlist */
z_clearlist:
'@echo *clearlist 'fs pipe_to
return

/* writetodisk [fn] - save http stream to [fn] (no [fn] = stop writing) */
z_writetodisk:
parse arg fs
'@echo *writetodisk 'fs pipe_to
return


/* ==================== File Selector section ==== (LD4) ================== */
/* calling parameters:
 fs_scol, glo_var, fs_path, fs_flspc, fs_attr, fs_cur, fs_sort, fs_initpos, fs_view, fs_filter
example:
rv= file_select(40, glo_var, 'C:\OS2', '*.ico', '', 'REXX.ICO', 'N', 'M', 'DTSAL', 1)
*/
/* ============== All code BELOW is necessary for file_select ============ */

/* file_select does not save or restore the screen. */
file_select:
parse arg fs_scol, glo_var, fs_path, fs_flspc, fs_attr, fs_cur, fs_sort, fs_initpos, fs_view, fs_filter
  ndx= 0; scrx= scrx; fs_showln= scry; /* initialize */
  fs_sort= translate(fs_sort); fs_initpos= translate(fs_initpos); fs_view= translate(fs_view);
  if pos(fs_sort, 'DENS') = 0 then fs_sort= 'N' /* useful default: fs_sort on Name */
  if pos(fs_initpos, 'HMT') = 0 then fs_initpos= 'M' /* show Middle of list */
  if fs_attr = '' then fs_attr= '*****'
  fs_dtlwid= 1; /* too complex to check fs_view correctness, SO UP TO YOU */
  if length(fs_view) > 0 then do fs_loop= 1 to length(fs_view)
    v= substr(fs_view, fs_loop, 1) /* always GET details, CHOOSE which to display */
    if v= 'D' then fs_dtlwid= fs_dtlwid + 9
    if v= 'T' then fs_dtlwid= fs_dtlwid + 6
    if v= 'S' then fs_dtlwid= fs_dtlwid + 11
    if v= 'A' then fs_dtlwid= fs_dtlwid + 6
    if v= 'L' then fs_dtlwid= fs_dtlwid + 5 /* show Long (Y2K) */
  end
  /* end \ is crucial, ensure ALWAYS present, starting here to count fs_lvls */
  /* # of levels is actually limited only by a literal '10' in fs_enter_dir */
  /* DON'T advise entering here with more than 9 levels in path! */
  if substr(fs_path, length(fs_path), 1) \= '\' then fs_path= fs_path||'\'
  fs_lvl= 0
  do fs_loop= 1 to length(fs_path)
    if substr(fs_path, fs_loop, 1) = '\' then fs_lvl= fs_lvl + 1
  end
  fs_ndx= get_1_directory(glo_var, fs_path, fs_flspc, fs_attr, fs_filter, 1)
  if fs_ndx = 2 then do /* only dots back? turn off fs_filter and try for ANY */
    fs_filter= 0
    fs_ndx= get_1_directory(glo_var, fs_path, fs_flspc, fs_attr, fs_filter, 1)
  end
  if fs_ndx > 2 then do /* found more than dot dirs (no indent saves space) */
  fs_tags= copies('ú', fs_ndx) /* prepare tag "array" */
  call fs_set_sel
  call fs_show_new_dir
  do fs_loop= 0 to fs_showln /* helps to set off from previous text */
    call syscurpos fs_loop, fs_scol - fs_dtlwid
    call charout, 'Ç'
  end
  fs_quit= 0
  fs_t= time('R') /* BUSY in keyboard poll, but SLOW if sleeps every loop */
  /* sleeps after 10 seconds of no keys -- reset may conflict with app... */
  do while fs_quit < 1  /* begin key control */
    if chars() > 0 then do
    fs_kd= ex_read_key()
    fs_t= time('R') /* reset timer on every keypress */
    fs_n= fs_ndx_ofs.fs_lvl + fs_sel.fs_lvl /* used several times */
    select /* keyboard constants avoid lengthy expose list... */
    when fs_kd = 'àK' then call fs_exit_dir /* left arrow */
    when fs_kd = 'àM' then call fs_enter_dir /* right arrow */
    when fs_kd = 'àH' then do /* up arrow */
      if fs_sel.fs_lvl > 1 then do
        call fs_lowlight
        fs_sel.fs_lvl= fs_sel.fs_lvl - 1
        call fs_highlight
      end
      else do /* fs_sel.fs_lvl = 1 so scroll down */
        if fs_ndx_ofs.fs_lvl > 0 then do
          fs_ndx_ofs.fs_lvl= fs_ndx_ofs.fs_lvl - 1
          call fs_show_section
        end
      end
    end
    when fs_kd = 'àP' then do /* down arrow */
      if fs_sel.fs_lvl <= fs_maxln - 1 then do
        call fs_lowlight
        if fs_n < fs_ndx then fs_sel.fs_lvl= fs_sel.fs_lvl + 1
        call fs_highlight
      end
      else do /* fs_sel.fs_lvl > fs_maxln so scroll up */
        if fs_ndx_ofs.fs_lvl < fs_ndx - fs_showln then do
          if fs_sel.fs_lvl < fs_ndx - 1 then fs_ndx_ofs.fs_lvl= fs_ndx_ofs.fs_lvl + 1
          call fs_show_section
        end
      end
    end
    when fs_kd = 'àI' then do /* page up */
      fs_ndx_ofs.fs_lvl= fs_ndx_ofs.fs_lvl - fs_showln
      if fs_ndx_ofs.fs_lvl < 0 then do
        fs_ndx_ofs.fs_lvl= 0
        fs_sel.fs_lvl= 1
      end
      call fs_show_section
    end
    when fs_kd = 'à'||d2c(132) then do /* ctrl-page up */
      fs_ndx_ofs.fs_lvl= 0
      fs_sel.fs_lvl= 1
      call fs_show_section
    end
    when fs_kd = 'àQ' then do /* page down */
      if fs_ndx > fs_showln then do

        if fs_n + fs_showln < fs_ndx then do
          fs_ndx_ofs.fs_lvl= fs_ndx_ofs.fs_lvl + fs_showln
        end
        else do
          fs_ndx_ofs.fs_lvl= fs_ndx - fs_showln
          fs_sel.fs_lvl= fs_showln
        end

      end
      else fs_sel.fs_lvl= fs_ndx
      call fs_show_section
    end
    when fs_kd = 'àv' then do /* ctrl-page down */
      if fs_ndx > fs_showln then do
        fs_ndx_ofs.fs_lvl= fs_ndx - fs_showln
        fs_sel.fs_lvl= fs_showln
        call fs_show_section
      end
    end
    when fs_kd > '`' & fs_kd < '{' then do /* LOWERCASE a-z, select drive */
      fs_kd = translate(fs_kd)
      if pos(fs_kd, sysdrivemap('A:', 'USED')) > 0 then do /* select new drive */
        fs_path= fs_kd||':\'
        fs_lvl= 1
/*        fs_filter= 0 *//* cures not finding files when changing drive */
/*    NOT ^ in time4z because want to find only .m3u, .pls, .wav, or .mp3 */
        fs_ndx= get_1_directory(glo_var, fs_path, fs_flspc, fs_attr, fs_filter, 1)
        fs_cur= ''
        fs_tags= copies('ú', fs_ndx)
        call fs_set_sel
        call fs_show_new_dir
      end
    end
    when fs_kd = 'F' then do  /* fs_filter toggle */
      if fs_filter = 1 then fs_filter= 0; else fs_filter= 1
      fs_ndx= get_1_directory(glo_var, fs_path, fs_flspc, fs_attr, fs_filter, 1)
      fs_tags= copies('ú', fs_ndx)
      call fs_set_sel
      call fs_show_new_dir
    end
    when fs_kd = 'H' | fs_kd = 'M' | fs_kd = 'T' then do
      fs_initpos= fs_kd
      fs_cur= '' /* set off so fs_set_sel uses fs_initpos rather than finds this */
      call fs_set_sel
      call fs_show_new_dir
    end
    when fs_kd = 'D' | fs_kd = 'E'| fs_kd = 'N' | fs_kd = 'S' then do
      fs_sort= 'N'; call fs_sort_list; /* always fs_sort first by name */
      if fs_kd <> 'N' then do       /* results in better ordering */
        fs_sort= fs_kd; call fs_sort_list;
      end
      call fs_show_new_dir
    end
    when fs_kd = 'à'||d2c(141) then do /* ctrl-up; SET tag and move up */
      if fs_n > 2 then fs_tags= overlay('Û', fs_tags, fs_n) /* don't tag dot dirs */
      if fs_sel.fs_lvl > 2 then do
        call syscurpos fs_sel.fs_lvl - 1, fs_scol
        call fs_show_tag(fs_n)
        call fs_lowlight
        fs_sel.fs_lvl= fs_sel.fs_lvl - 1
        call fs_highlight
      end
      else do
        if fs_ndx_ofs.fs_lvl > 0 then do
          fs_ndx_ofs.fs_lvl= fs_ndx_ofs.fs_lvl - 1
          call fs_show_section
        end
      end
    end
    when fs_kd = ' ' |,   /* <space> TOGGLE tag and move down */
      fs_kd = 'à'||d2c(145) then do /* ctrl-down; SET tag and move down */
      if fs_n > 2 then do
        if fs_kd= ' ' & substr(fs_tags, fs_n, 1) = 'Û' then fs_tags= overlay('ú', fs_tags, fs_n)
          else fs_tags= overlay('Û', fs_tags, fs_n)
          call syscurpos fs_sel.fs_lvl - 1, fs_scol
          call fs_show_tag(fs_n)
          if fs_sel.fs_lvl <= fs_maxln - 1 then do
          call fs_lowlight
          if fs_n < fs_ndx then fs_sel.fs_lvl= fs_sel.fs_lvl + 1
          call fs_highlight
        end
        else do
          if fs_ndx_ofs.fs_lvl < fs_ndx - fs_showln then do
            if fs_sel.fs_lvl < fs_ndx - 1 then fs_ndx_ofs.fs_lvl= fs_ndx_ofs.fs_lvl + 1
            call fs_show_section
          end
        end
      end
    end
    when fs_kd = d2c(0)||';' then do /* F1 Help */
      call fs_show_instructions fs_scol
      call fs_show_section
    end
    when fs_kd = x2c('0d') then do /* <enter>, return selected name */
      if fs_n < 3  then call fs_exit_dir /* EXCEPT on dot dir, go up */
      else do
        fs_action= fs_kd
        fs_quit= 1
      end
    end
    otherwise do /* EXIT all other keys, handle in caller. May be annoying */
      fs_action= fs_kd /* because loses settings merely to discard a key. */
      fs_quit= 1 /* Can add code here of course. Not easy to re-enter */
    end        /* without re-initializing; need static variables. */
    end /* select */
    end /* if charin > 0 */
    else do /* without sleep keyboard poll keeps CPU BUSY */
      if time('E') > 10 then call syssleep 0.5 /* makes response lag, though */
    end /* uhh... previous to v11 someone thought syssleep took only integer */
  end /* while fs_quit */
  end /* fs_ndx > 0 so some found */
  else do
    fs_action= 'Not_Found'
    fs_n= 0
    fs_rv= ''
  end
return fs_action' '||fs_n||' '||fs_tags||' '||fs_path||fs_filnam(fs_n)

fs_fildat: /* word 1, year 2 or 4 chars depending whether 'L' in fs_view */
arg fs_ni
fs_rv= word(dirlist.fs_ni, 1)
if pos('L', fs_view) = 0 then fs_rv= substr(fs_rv, 3, 8)
return fs_rv

fs_filtim: /* word 2, colon and seconds omitted in short form */
arg fs_ni
fs_rv= word(dirlist.fs_ni, 2)
if pos('L', fs_view) = 0 then fs_rv= substr(fs_rv, 1, 5)
return fs_rv

fs_filsiz: /* word 3 WITH spaces for ease in display */
arg fs_ni
fs_twi= wordindex(dirlist.fs_ni, 2) + length(word(dirlist.fs_ni, 2)) + 1
return substr(dirlist.fs_ni, fs_twi, 10)

fs_filatt: /* word 4 attributes */
arg fs_ni
return word(dirlist.fs_ni, 4)

fs_filnam: /* word 5 --> remainder INCLUDING spaces */
arg fs_ni
fs_twi= wordindex(dirlist.fs_ni, 5)
return substr(dirlist.fs_ni, fs_twi, length(dirlist.fs_ni) - fs_twi + 1)

fs_ellipsis: /* shorten fs_filnam if necessary to fit available space */
arg fs_ni, fs_nw
fs_twi= fs_filnam(fs_ni)
if length(fs_twi) > fs_nw then
  fs_twi= left(fs_twi, fs_nw % 2)||'/÷/'||right(fs_twi, (fs_nw % 2) - 3)
return fs_twi

fs_show_section: /* displays however much of dirlist. fits screen space */
  do fs_loop= 0 to scry - 1/* sim clear screen; remove all of previous */
    if length(fs_view) = 0 then call syscurpos fs_loop, fs_scol
      else call syscurpos fs_loop, fs_scol - fs_dtlwid + 1
    call charout, ansi_clreol
  end
  fs_totlsiz= 0
  do fs_loop= 3 to fs_ndx
    fs_totlsiz= fs_totlsiz + fs_filsiz(fs_loop)
  end
  fs_loop= 0 /* 0 based for screen line */
  do until (fs_loop + fs_ndx_ofs.fs_lvl >= fs_ndx) | (fs_loop >= fs_maxln)
    fs_n= fs_loop + fs_ndx_ofs.fs_lvl + 1
    if length(fs_view) > 0 then do
      call syscurpos fs_loop, fs_scol - fs_dtlwid + 1
      call charout, ansi_clreol
      do fs_a= 1 to length(fs_view) /* order in fs_view sets displayed order! */
        fs_v= substr(fs_view, fs_a, 1)
        if fs_v= 'D' then call charout, fs_fildat(fs_n)' '
        if fs_v= 'T' then call charout, fs_filtim(fs_n)' '
        if fs_v= 'A' then call charout, fs_filatt(fs_n)' '
        if fs_v= 'S' then call charout, fs_filsiz(fs_n)' '
      end
    end
    call syscurpos fs_loop, fs_scol
    call charout, ansi_clreol
    select
      when fs_n = 1 then do
        call charout, d2c(17)||'.   '||fs_ndx - 2' files'
      end
      when fs_n = 2 then do
        call charout, d2c(17)||'..  'fs_totlsiz' bytes'
      end
      when (fs_n > 2) then do
        call fs_show_tag(fs_n)
        call charout, fs_ellipsis(fs_n, scrx - fs_scol)
      end
      otherwise nop
    end /* select */
    fs_loop= fs_loop + 1
  end /* do until */
  call fs_highlight
return

fs_show_path: /* assembles bottom line, then truncates to available space */
  fs_ps= ' (F1 Help)  ['||word(sysdriveinfo(substr(fs_path, 1, 2)), 4)||']  '||fs_path
  fs_width= scrx - fs_scol + fs_dtlwid - 1
  do while length(fs_ps) < fs_width + 1
    fs_ps= fs_ps||'_' /* to clear prev */
  end
  call syscurpos scry, fs_scol - fs_dtlwid + 1 /* 0, 0 based */
  call charout, substr(fs_ps, length(fs_ps) - fs_width, fs_width)
return

fs_show_new_dir: /* code needed several times */
  if fs_ndx < fs_showln then fs_maxln= fs_ndx; else fs_maxln= fs_showln
  call fs_show_section
  call fs_show_path
return

fs_exit_dir: /* for left-arrow at any time, or <enter> on a dot dir */
  if fs_lvl > 1 & length(fs_path) > 3 then do /* backs up one fs_lvl */
    if fs_lvl > 2 then do
      fs_loop= length(fs_path) - 1
      do until substr(fs_path, fs_loop, 1) = '\' | length(fs_path) < 4
        fs_loop= fs_loop - 1
      end
      fs_loop= fs_loop + 1
    end
    else fs_loop= 4
    fs_cur= substr(fs_path, fs_loop, length(fs_path) - fs_loop)
    fs_loop= length(fs_path)
    do until substr(fs_path, fs_loop, 1) = '\' | length(fs_path) < 4
      fs_loop= fs_loop - 1
    end
    fs_path= substr(fs_path, 1, fs_loop)
    fs_lvl= fs_lvl - 1
/* fs_filter= 0 */ /* going up, so off likely better (re-filter with alt-h) */
/* ^COMMENTED OUT from LD4 because distracting for this application */
/* (and does not require new coding for LOCK effect; can still turn off too) */
    fs_ndx= get_1_directory(glo_var, fs_path, fs_flspc, fs_attr, fs_filter, 1)
    fs_tags= copies('ú', fs_ndx)
    call fs_set_sel
    call fs_show_new_dir
  end
return

fs_enter_dir: /* for right-arrow or <enter> on a non-dot dir; 10 LEVEL LIMIT */
  fs_n= fs_ndx_ofs.fs_lvl + fs_sel.fs_lvl
  if fs_lvl < 10 & fs_n > 2 & substr(fs_filatt(fs_n), 2, 1) = 'D' then do
    fs_cur= '' /* current selection always set off upon enter */
    fs_path= fs_path||fs_filnam(fs_n)||'\'
    fs_lvl= fs_lvl + 1
    fs_sel.fs_lvl= 1
    fs_ndx= get_1_directory(glo_var, fs_path, fs_flspc, fs_attr, fs_filter, 1)
    fs_tags= copies('ú', fs_ndx)
    call fs_set_sel
    call fs_show_new_dir
  end
return

fs_highlight: /* show selected item (only the name...) in reverse color */
  call syscurpos fs_sel.fs_lvl - 1, fs_scol + 1
  call charout, revcolr||fs_ellipsis(fs_ndx_ofs.fs_lvl + fs_sel.fs_lvl, scrx - fs_scol)||dircolr
return

fs_lowlight: /* show name back in standard color */
  call syscurpos fs_sel.fs_lvl - 1, fs_scol + 1
  call charout, dircolr||fs_ellipsis(fs_ndx_ofs.fs_lvl + fs_sel.fs_lvl, scrx - fs_scol)
return

fs_show_tag: /* show tag (for dirs, simulate block w reverse color) */
  arg fs_ni
  if substr(fs_filatt(fs_ni), 2, 1) = 'D' then do
    if substr(fs_tags, fs_ni, 1) = 'Û' then call charout, revcolr||d2c(16)||dircolr
    else call charout, d2c(16)
  end
  else call charout, substr(fs_tags, fs_ni, 1)
return

fs_set_sel: /* figures out what part of list to display, and item to select */
  fs_n= 0
  if length(fs_cur) > 0 then do /* assumes fs_cur is valid... */
    fs_cs= 1
    do until fs_cs >= fs_ndx | pos(fs_cur, fs_filnam(fs_cs)) = 1
      fs_cs= fs_cs + 1
    end
  end
  else fs_cs= fs_ndx + 1
  if fs_cs <= fs_ndx then do
    if fs_cs > fs_showln then do
      fs_ndx_ofs.fs_lvl= fs_cs - fs_showln
      fs_sel.fs_lvl= fs_showln
      fs_n= fs_showln % 2
      if fs_ndx_ofs.fs_lvl + fs_sel.fs_lvl + fs_n < fs_ndx then do
        fs_ndx_ofs.fs_lvl= fs_ndx_ofs.fs_lvl + fs_n
        fs_sel.fs_lvl= fs_sel.fs_lvl - fs_n
      end
    end
    else do
      fs_ndx_ofs.fs_lvl= 0;
      fs_sel.fs_lvl= fs_cs;
    end
  end
  else do
    select
    when fs_initpos = 'H' then do /* show list from Head (top) */
      if fs_lvl > 1 & fs_ndx > 2 then fs_sel.fs_lvl= 3; else fs_sel.fs_lvl= 2
      fs_ndx_ofs.fs_lvl= 0
    end
    when fs_initpos = 'M' then do /* Middle */
      if fs_ndx > fs_showln then do /* more files than screen lines */
        fs_sel.fs_lvl= fs_showln % 2 + 1
        if (fs_ndx > 2 * fs_showln - 1) then fs_ndx_ofs.fs_lvl= fs_ndx % 2 - fs_sel.fs_lvl
          else fs_ndx_ofs.fs_lvl= (fs_ndx - fs_showln) % 2
      end
      else do
        if fs_ndx > 2 then fs_sel.fs_lvl= fs_ndx % 2 + 2; else fs_sel.fs_lvl = 2
        fs_ndx_ofs.fs_lvl= 0
      end
    end
    when fs_initpos = 'T' then do /* Tail (end) */
      if fs_ndx > fs_showln then do
        fs_sel.fs_lvl= fs_showln
        fs_ndx_ofs.fs_lvl= fs_ndx - fs_showln
      end
      else do
        fs_sel.fs_lvl= fs_ndx
        fs_ndx_ofs.fs_lvl= 0
      end
    end
    end /* select */
  end /* else of fs_cs <= fs_ndx */
return

get_1_directory:
parse arg glo_var, g1_path, g1_flspc, tattr, g1_filter, g1_dirs
/* get JUST ONE dir in Long (Y2K) form, and re-format:
2000-09-06 12:43:00  1234567890  A----  C:\os2\SWITCHRX.CMD
by removing unnecessary spaces and (known elsewhere) path to:
2000-09-06 12:43:00 1234567890 A---- SWITCHRX.CMD
1  words   2        3          4     5 --> remainder inc spaces */
  drop value(glo_var) /* toss any previous list */
  g1_addl= '____Date__ _Time___ ___Size___ Attrb  .'
  rc= value(glo_var||'1', g1_addl) /* fake dot dirs for sake of convention */
  g1_addl= 'yyyy-mm-dd hh:mm:ss          0 ADHRS  ..'
  rc= value(glo_var||'2', g1_addl) /* though will use the space for info */
  g1_addl= 2 /* additional, now is offset for accumulating to glo_var.0 */
  if substr(g1_path, length(g1_path), 1) \= '\' then g1_path= g1_path||'\'
  if g1_filter = 0 then do; g1_flspc= '*'; tattr= '*****'; end;
  do g1_nspec= 0 to words(g1_flspc) /* space delim'd, so NO OTHER spaces */
    ts.0= 0
    if g1_nspec > 0 then do
      rc= SysFileTree(g1_path||word(g1_flspc, g1_nspec), 'ts', 'FTL', tattr)
    end
    else do /* check get dirs */
      if g1_dirs = 1 then rc= SysFileTree(g1_path||'*', 'ts', 'DTL', tattr)
    end
    if ts.0 > 0 then do
      do g1_n= 1 to ts.0
        ts.g1_n= delstr(ts.g1_n, wordindex(ts.g1_n, 3) - 1, 1)
        ts.g1_n= delstr(ts.g1_n, wordindex(ts.g1_n, 4) - 1, 1)
        ts.g1_n= delstr(ts.g1_n, wordindex(ts.g1_n, 5) - 1, 1)
        p= pos(':\', ts.g1_n) - 1
        ts.g1_n= delstr(ts.g1_n, p, lastpos('\', ts.g1_n) - p + 1) /* strip out path */
        l= g1_n + g1_addl /* arithmetic */
        p= value(glo_var||l, ts.g1_n) /* SET (global) glo_var.[g1_n + addl] TO ts.g1_n */
      end
    end
    g1_addl= g1_addl + ts.0 /* sum # in current list plus all previous */
    p= value(glo_var||'0', g1_addl) /* set the number of elements */
  end
return g1_addl /* becomes fs_ndx, # of entries found */

fs_sort_list:
  if fs_ndx > 3 then do
    if substr(fs_filnam(2), 2, 1) = '.' then fs_head= 3; else fs_head= 1
    do until fs_head >= fs_ndx
      fs_cnt= fs_head + 1
      do until fs_cnt > fs_ndx
        select /* get which field: Date, Extension, Name, or Size */
          when fs_sort = 'D' then do
            v1= word(dirlist.fs_cnt, 1)||word(dirlist.fs_cnt, 2)
            v2= word(dirlist.fs_head, 1)||word(dirlist.fs_head, 2)
          end
          when fs_sort = 'E' then do /* Simplistic. Scrambles re full name. */
            parse upper var dirlist.fs_cnt with dummy '.' v1
            parse upper var dirlist.fs_head with dummy '.' v2
          end
          when fs_sort = 'N' then do
            fs_twi= wordindex(dirlist.fs_cnt, 5)
            v1= substr(dirlist.fs_cnt, fs_twi, length(dirlist.fs_cnt) - fs_twi + 1)
            fs_twi= wordindex(dirlist.fs_head, 5)
            v2= substr(dirlist.fs_head, fs_twi, length(dirlist.fs_head) - fs_twi + 1)
          end
          when fs_sort = 'S' then do
            v1= word(dirlist.fs_cnt, 3)
            v2= word(dirlist.fs_head, 3)
          end
        end /* select */
        if v1 < v2 then do /* compare and swap */
          fs_twi= dirlist.fs_cnt
          dirlist.fs_cnt= dirlist.fs_head
          dirlist.fs_head= fs_twi
        end
        fs_cnt= fs_cnt + 1
      end
      fs_head= fs_head + 1
    end
  end
return

fs_show_instructions:
arg ix
if ix > 40 then ix= 40 /* caller handles all screen clean-up, heh */
iy= 2
call say_inc 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
call say_inc 'º arrows:             uppercase:    º'
call say_inc 'º 'd2c(30)' up                Filter toggle º'
call say_inc 'º 'd2c(31)' down                            º'
call say_inc 'º 'd2c(16)' into directory    sort by:      º'
call say_inc 'º 'd2c(17)' out of directory  D: Date/Time  º'
call say_inc 'º                     E: Extension  º'
call say_inc 'º <enter> select      N: Name       º'
call say_inc 'º <escape>            S: Size       º'
call say_inc 'º                                   º'
call say_inc 'º lowercase a-z:      display from: º'
call say_inc 'º   select drive      H: Head       º'
call say_inc 'º                     M: Middle     º'
call say_inc 'º tagging:            T: Tail       º'
call say_inc 'º ctrl-up tag and up                º'
call say_inc 'º ctrl-down " " down  DGDs  v1.0 of º'
call say_inc 'º <space> toggle      File Selector º'
call say_inc 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
kd= 0
do while chars() = 0
 if kd // 5 = 0 then do
   call syscurpos 2, ix + 5; call charout, ' Hit any key '
 end
 else do
   call syscurpos 2, ix + 5; call charout, 'ÍÍÍÍÍÍÍÍÍÍÍÍÍ'
 end
 call syssleep 0.5
 kd= kd + 1
end
kd= ex_read_key()
kd= ''
return

say_inc:
parse arg it
call syscurpos iy, ix
call charout, it
iy= iy + 1
return
