/* CTORRENT Monitor by DGD. Freeware for OS/2 - ECS only. */
/* Starts and monitors torrents. This version only for new ACT.EXE. */
version= 'ÄÄ CTMA CTorrent Monitor ÄÄ'

call rxfuncadd 'sysloadfuncs', 'rexxutil', 'sysloadfuncs'
call sysloadfuncs

ulr= '35' /* KBytes/S UpLoadRate limit; value for cable modem of 40K/S up */

exec_dir= 'c:\act'  /* executable (v7a) modified for new ACT.EXE */
base_dir= 'c:\torrents'  /* torrents go here -- set in program object */
current_dir= base_dir||'\current' /* looks here for current & new ones */
info_dir= base_dir||'\info' /* v9 extracted text, holds current tracker # */
download_dir= 'c:\temp' /* <backspace> moves .torrents from here to above */
finished_dir= base_dir||'\finished' /* 'F' puts finished .torrents here */
/* ^^^ v7 starts these with -f force seed that skips hash check */
deleted_dir= base_dir||'\deleted' /* 'F' puts finished .torrents here */
/* ^^^ v7 delete_tor procedure moves from finished_dir to here */

'mkdir 'base_dir  /* v7 since these are vital, just do brute force creation */
'mkdir 'current_dir
'mkdir 'info_dir
'mkdir 'finished_dir
'mkdir 'deleted_dir

params= '-C 1 -e 168 -rate -pdown -u 3 -U '||ulr||' -win 80,20',
  '-S localhost:2780' /* params continued, this for CTCS */
/* v8 CHANGED PARAMS FOR ACT.EXE; '-S' for CTCS monitoring. (Ignore error
   messages "can't connect to CTCS" in ACT if PMCTM is NOT running.) */
/* v9 un-kludged setting of trackers (after got too annoying), so the -u
      param above doesn't mean anything; it's now set from .info files */

call constants /* moved color and key "constants" to end to reduce clutter */
call syscls
call help

call sysqueryswitchlist "rlist." /* v7 check if torrents already running */
sl= 0
do n= 1 to rlist.0
  if pos('ACT:', rlist.n) = 1 then sl= 1 /* how ctorrent9 lists itself */
end
if sl = 0 then do /* if no torrents, then do cold start-up delay */
  count= 120 /* number of seconds to delay */
  say
  say ' !!! Delay to allow rest of system to stabilize. Hit any key to skip.'
  do n= count to 0 by -1
    call charout, n' '
    if chars() > 0 then do
      n= 0 /* to exit early */
      k= ex_read_key() /* to clear */
    end  /* ^ (NOTE to self: waits if no key, so hangs if not placed here) */
    else call syssleep 1
  end
end
else call syssleep 3 /* v7 just for chance help to be seen */

updatetime= 15 /* seconds between updates */
uparrow= d2c(24); dnarrow= d2c(25); /* characters */
inststr= ' ÄÄÄ <backspace> new ÄÄ 'uparrow' 'dnarrow' select, then (S)top or (F)inish ÄÄ Ctrl-c exit ÄÄÄ'

initialize= 0 /* reset so first pass main loop starts all torrents */

count= updatetime + 1 /* so shows info on first pass through main */
sl= 0 /* flag and position for selection */
parse value systextscreensize() with maxy maxx /* to handle scrolling info */
maxy= maxy - 1; maxx= maxx - 1  /* adjust for schizo 0-based syscurpos */
last_n100= -1 /* initialize flag, later for when another torrent finishes */
tb= time('R')

do forever  /* main loop */
  if initialize = 0 then do
    params= '-f '||params  /* v7 force seed mode GREATLY speeds start-up */
    rc= sysfiletree(finished_dir||'\*.torrent', 'torrents.', 'FO')
    call initialize_all  /* this call only for those already 'finished' */
    params= delstr(params, pos('-f ', params), 3) /* (v9 bug) Remove, otherwise */
      /* stoopid ctorrent9.exe starts new torrents as if done, even though */
      /* it just created a new file! Result: garbage sent out, ANGRY peers. */
    rc= sysfiletree(current_dir||'\*.torrent', 'torrents.', 'FO')
    call initialize_all /* new or 'current' ones not yet complete */
  end
  if count > updatetime then do /* v5 low kybd latency */
    count= 0
    sl= 0 /* reset selection flag since operator was too slow */
    say   /* much hard-coded formatting - feel free to neaten */
    say dkgray||inststr||norcolr
    parse value syscurpos() with my x  /* save location for highlighting */
    if my = maxy then scroll= 1; else scroll= 0
    call sysqueryswitchlist "rlist."
    n100= 0; td= 0; tu= 0; wlist.0= 0; nu= 0; nd= 0; /* init counters */
    do n= 1 to rlist.0   /* assemble wlist of only running torrents */
      if pos('ACT:', rlist.n) > 0 & pos('%', rlist.n) > 0 then do
        w1= wlist.0 + 1               /* ^ present only after initialized */
        wlist.0= w1
        wlist.w1= substr(rlist.n, 6) /* drop "ACT: " */
        wlist.w1= insert(' ', wlist.w1, pos(dnarrow, wlist.w1)) /* v6 */
        if pos('100%', wlist.w1) > 0 then do  /* v6 */
          n100= n100 + 1 /* count the number done */
          wlist.w1= 'done '||delstr(wlist.w1, 1, 4)  /* so sorts right (v7a) */
        end
        else do  /* must be < 10 % done which screws up sort order */
          w2= word(wlist.w1, 1) /* w2 here = first word */
          if length(w2) < 5 then wlist.w1= '0'||wlist.w1 /* so sorts right */
        end  /* v6 After massaged as above window listing is like: */
      end    /* 49.6% 14.4d 4.0u Tonight_or__Never_(1931)__Gloria_Swanson */
    end      /* down arrow^    ^up arrow (symbols don't paste into my w/p) */

    if (last_n100 = -1 & n100 > 0) |, /* v8 fix, stop false runs when 0 done */
        n100 > last_n100 &, /* v7 1st pass or new done */
        wlist.0 > 0 then do /* v8 yet another duh for if none are done */
      call syscls
      say
      say pccolr' !!! A file reached 100%. Moving finished file(s) to 'finished_dir
      call syssleep 1
      do n= 1 to wlist.0  /* brute force move of all marked as 'done' avoids */
        if pos('done', wlist.n) = 1 then do         /* complex keeping track */
          w4= substr(wlist.n, wordindex(wlist.n, 4))
          'move "'substr(current_dir, 3)'\'w4'*" "'substr(finished_dir, 3)'"'
        end     /* >>> wildcard means possibly^ moving one that isn't 100% */
/*      call syssleep 1 */
      end       /* unavoidable risk because shortened in window list */
/* NOTE that .torrents names can be changed on disk as necessary */
      say; say norcolr'Moving of file(s) completed.'; say
    end
    last_n100= n100  /* remember for next loop */
    if wlist.0 > 0 then do /* v7 avoids crash when no torrents are running */
      n= sysstemsort("wlist.", "D", "I", , , 1, 4)  /* v6 SORT by % done */
      /* HMM. % done seems only useful way; others kind of randomly scramble */
      do n= 1 to wlist.0   /* v6 boy, it's just one "fix" after another! */
        wlist.n= strip(wlist.n, 'L', '0') /* now get rid of added lead zero */
      end                    /* ... and if < 1% too, but kind of like that */
      c1= 7; c2= 17; c3= 27; c4= 29; /* columns */
      do n= 1 to wlist.0    /* separate words, and use colors */
        ds= wlist.n
        parse value syscurpos() with y x
        w1= word(ds, 1)  /* percent done */
        call syscurpos y, c1 - length(w1)
        if pos('done', w1) > 0 then call charout, dkcyan||w1 /* low light */
          else call charout, pccolr||w1 /* inserting INTO didn't work, hmm */
        w2= word(ds, 2)  /* down rate */
        call syscurpos y, c2 - length(w2)
        call charout, dncolr||w2
        v= substr(w2, 1, length(w2) - 1)
        if v > 0 then nd= nd + 1 /* number downloading */
        td= td + v /* total download rate */
        w3= word(ds, 3)  /* up rate */
        v= delstr(w3, pos(uparrow, w3), 1)
        if v > 0 then nu= nu + 1 /* number uploading */
        call syscurpos y, c3 - length(w3)
        call charout, upcolr||w3
        tu= tu + v
        call syscurpos y, c4
        w4= substr(ds, wordindex(ds, 4)) /* length(ds) - wordindex(ds, 4) + 1) */
        call charout, norcolr||w4
        say
        if scroll then my= my - 1 /* FAIL if # of torrents > maxy */
      end /* do columns */
    end /* do wlist.0 > 0 */
    parse value syscurpos() with y x /* v7a */
    if wlist.0 > 0 then do /* v8 duh, fix for none */
      n100= n100'/'wlist.0
      call syscurpos y, c1 - length(n100) - 1
      call charout, pccolr||n100
      td= nd||'='||td
      call syscurpos y, c2 - length(td) - 1
      call charout, dncolr||td
      tu= nu||'='||tu
      call syscurpos y, c3 - length(tu) - 1
      call charout, upcolr||tu||norcolr
      call syscurpos y, c4
    end
    call charout, copies(' ', 9)||dkgray||version||norcolr
  end /* if count */
  if time('E') > 10 then do /* two stage sleep for improved kybd response, */
    call syssleep 1
    count= count + 1
  end
  else call syssleep 0.1 /* yet w/o the cpu hogging this can produce */
/*  ********************* key handling **********************************  */
  if chars() > 0 then do
    tb= time('R') /* reset elapsed time whenever user hits a key */
    k= ex_read_key()
    if length(k) = 1 then k= translate(k) /* else conflict w extended keys */
    select
    when k = k_bksp then do
      rc= sysfiletree(download_dir||'\*.torrent', 'torrents.', 'FO')
      do l= 1 to torrents.0
        tu= filespec('N', torrents.l)
        /* v9 suppose it's possible someone won't like the renaming... */
        say; say 'Original name ='tu; say
        do while pos(' ', tu) > 0   /* convert ALL spaces to underlines */
          tu= overlay('_', tu, pos(' ', tu))
        end
        do while pos('__', tu) > 0   /* get rid of multiple underlines */
          tu= delstr(tu, pos('__', tu), 1)
        end
        do while pos('The_', tu) = 1   /* get rid of "The_" */
          tu= delstr(tu, 1, 4)
        end
        /* v9 so just remove / comment out the above section */
        'copy "'torrents.l'" "'current_dir'\'tu'"'
        'del "'torrents.l'"'    /* copy-del because may not be on */
      end                       /* same drive and may be more than one */
      initialize= 0 /* set flag to make call when loops */
      count= updatetime + 1 /* forces display update */
    end
    when (k = 'S' | k = 'F') & sl > 0 then do    /* Stop - Finish */
      call close_torrent   /* v6 returns with w4 massaged; harmless error */
      'pgmcntrl /close /x:"'w4'*"'  /* if w4='' AS HAPPENS on wacky names! */
      sl= 0 /* reset selection flag */
      k= k_esc
    end
    when k = k_del then do  /* v7 */
      call delete_tor
      call syscls
      count= updatetime + 1 /* force update */
    end
    when k = k_tab then do  /* v9 switch mode to delete .info file */
      call delete_or_edit_info  /* to try another tracker or if messed up */
      call syscls
      count= updatetime + 1 /* force update */
    end
    when k = 'A' then do /* v6 All similar to 'S' or 'F' but loops */
      say; say
      say copies(d2c(22), 79)
      say ' STOPPING ALL TORRENTS!!! -- Does NOT move .torrent files.'
      do sl= 1 to wlist.0
        call close_torrent
        w3= copies(d2c(22), 12)
        say
        say w3' Activating torrent window with title text containing: 'w3
        say w4
        say
        say "Click on window's close box, 'Yes', WAIT for focus to return..."
        say "  OR to skip that torrent, hit <esc> here."
        say
        'pgmcntrl /AC /x:"'w4'*"' /* ACtivate window */
          /* LOOP until actually gone from window list or <esc> is pressed */
        gone= 0
        do until gone = 1 | k = k_esc
          k= ''
          still_there= 0
          call sysqueryswitchlist "rlist."
          do n= 1 to rlist.0
            if pos(w4, rlist.n) > 0 then still_there= 1
          end
          if still_there = 1 then gone= 0; else gone= 1
          if chars() > 0 then k= ex_read_key(); else call syssleep 1
        end
      end
      sl= 0 /* reset selection flag */
    end
    when (k = k_up | k = k_down) & wlist.0 > 0 then do
      count= 0 /* prevent updates while operator is tapping arrow keys */
      if sl = 0 then sl= wlist.0 % 2 + 1 /* initialize to mid-point */
      else do
        ds= wlist.sl  /* get from 4th word on */
        w4= substr(ds, wordindex(ds, 4), length(ds) - wordindex(ds, 4) + 1)
        call syscurpos my - 1 + sl, c4  /* simple way to remove any */
        call charout, norcolr||w4   /* previous highlighting in revcolr */
      end
      if k = k_up & sl > 1 then sl= sl - 1
      if k = k_down & sl < wlist.0 then sl= sl + 1
      ds= wlist.sl  /* get from 4th word on */
      w4= substr(ds, wordindex(ds, 4), length(ds) - wordindex(ds, 4) + 1)
      call syscurpos my - 1 + sl, c4 /* my was set in formatting section */
      call charout, revcolr||w4||norcolr /* reverse color highlight */
    end
    when k = k_F1 | k = '?' | k = 'H' then call help
    otherwise do
      count= updatetime + 1 /* forces display update */
      sl= 0
    end
    end /* select */
  end /* chars > 0 */
end

initialize_all:  /* called on program start or <backspace> hit */
do n= torrents.0 to 1 by -1  /* alpha order from file system REVERSES */
  info_fn= info_dir'\'filespec('N', torrents.n)'.info'
/* v9 all new tracker selection, SAVED in extracted info */
  if stream(info_fn, 'c', 'query exists') = "" then do
    'start /pgm /win /n c:\act\act.exe -x "'torrents.n'" 1> "'info_fn'"'
/* ^ IF "start" isn't used, title of window is set to filename... HUH? */
     say
     say ' WAIT for info creation and close...'
     say
     say ' Look at file list if you wish...'
     say
     say ' Type an asterisk in first column of desired tracker: "*3. http://..."'
     say
     say ' If not set, you will be prompted with a somewhat easier method.'
     call syssleep 3   /* viewing in same window is more pleasing */
    'tedit "'info_fn'"'  /* hmm, may comment this out, becomes annoying */
  end
  ndx= 0
  say
  say 'Reading: 'info_fn  /* (hoping) to get # of desired tracker */
  do until lines(info_fn) = 0
    ndx= ndx + 1
    fline.ndx= linein(info_fn)
    if pos('.', fline.ndx) = 3 then say fline.ndx
  end
  ok= stream(info_fn, 'c', 'close')
  fline.0= ndx
  ndx= 0
  k= ''
  tracker_n= ''
  do while tracker_n = ''  /* loop until '*' found; if not, manually set */
    do until tracker_n <> '' | ndx >= fline.0
      if pos('*', fline.ndx) = 1 then do   /* find line with asterisk */
        if ndx = 1 then tracker_n= '0'
          else tracker_n= substr(fline.ndx, 2, 1)
        if datatype(tracker_n, 'N') = 0 then tracker_n= ''
      end
      ndx= ndx + 1
    end
    do while tracker_n = ''
      say
      say ' !!! A tracker has not been set (or not correctly).'
      say '     Select tracker # from above list; type 0 - 9'
      do until chars() > 0
        call syssleep 1
      end
      k= ex_read_key()
      tracker_n= k
      if datatype(tracker_n, 'N') = 0 then do
        call beep 2000, 100
        tracker_n= ''
      end
      else do
        ndx= 1
        c2= ''
        if k <> '0' then do  /* not default tracker */
          do until tracker_n = c2 | ndx >= fline.0 /* find # in col 2 */
            ndx= ndx + 1
            if length(fline.ndx) > 1 then c2= substr(fline.ndx, 2, 1)
              else c2= '' /* check ^ because some lines are blank */
          end
        end  /* default overwrites "M" of "META" but don't care */
        if ndx > fline.0 then ndx= 1 /* didn't find, set to default */
        fline.ndx= '*'||delstr(fline.ndx, 1, 1) /* delete and tack on */
        'del "'info_fn'"' /* vA */
        say; say 'Saving tracker to:' info_fn
        call syssleep 1
        rc= stream(info_fn, 'c', 'open write')  /* save with change */
        do ndx= 1 to fline.0
          call charout info_fn, fline.ndx||d2c(13)||d2c(10)
        end
        ok= stream(info_fn, 'c', 'close')
      end /* key was valid # */
    end  /* inner tracker_n = '' */
    drop fline.
  end /* outer tracker_n = '' */
  if tracker_n = '0' & pos('-u ', params) > 0 then do /* v9 */
    params= delstr(params, pos('-u', params), 5)
  end
  if tracker_n > '0' & tracker_n < ':' then do /* v9 */
    if pos('-u ', params) = 0 then params= '-u   '||params
    params= overlay('-u '||tracker_n, params, pos('-u', params))
  end
  k= '' /* v9 just in case -- END OF NEW SECTION */
  tb= time('R')
  rv= start_torrent(torrents.n)
  if pos(rv, torrents.n) > 0 then do  /* rv is either sawl or '' */
    say ' ... Waiting for ACT.EXE to check existing files.'
    call charout, ' <backspace> to skip wait (and to continue if hangs)'
    parse value syscurpos() with my x  /* save location for timer */
    started= 0                /* WAIT until a '%' shows in 'ACT:' window */
    do until started = 1      /* because disk usage is HIGH and several */
      call sysqueryswitchlist "wlist."  /* checking at once slows to CRAWL */
      do l= 1 to wlist.0 /* scan all, set flag if found */
        if pos('ACT:', wlist.l) > 0 then do
          w2= wlist.l /* complex mangling, see start_torrent for why... */
          k= lastpos(uparrow, w2) + 2
          w3= substr(w2, k, length(w2) - k + 1)
          if length(w3) < length(rv) then rv= substr(rv, 1, length(w3))
          if pos(rv, w3) > 0 & pos('%', wlist.l) > 0 then started= 1
        end
      end
      call syscurpos my, x + 1
      tb= time('E')
      if length(tb) > 1 then call charout, substr(tb, 1, pos('.', tb) - 1)' seconds'
      if chars() > 0 then do /* v3: seemed to hang with new torrents */
        k= ex_read_key()  /* so with regret, added this to continue */
        if k = k_bksp then started= 1  /* v4: believe that's fixed! */
      end
      if started = 0 then call syssleep 5
    end /* started */
    say
  end
  else do
    say
    say dncolr||'!!! Appears to be already running! 'norcolr||torrents.n
  end
end
initialize= 1
return

start_torrent: /* IF not already running */
parse arg tts   /* parse so doesn't upcase! */
call sysqueryswitchlist "wlist."
sawl= substr(tts, lastpos('\', tts) + 1, length(tts) - lastpos('\', tts))
  /* filename (tts here) is shortened to 45 or so in window list, but */
running= 0 /* can only hope is enough to be unique... (later: not always) */
do l= 1 to wlist.0   /* scan all, set flag if found */
  if pos('ACT:', wlist.l) > 0 then do
    w2= wlist.l /* do some mangling because a simpler check failed when */
    k= lastpos(uparrow, w2) + 2 /* window list is shorter (is randomish, */
    w3= substr(w2, k, length(w2) - k + 1)  /* varies with actual numbers) */
    if length(w3) < length(sawl) then sawl= substr(sawl, 1, length(w3))
    if pos(sawl, w3) > 0 then running= 1
  end
end
if running = 0 then do  /* start windowed VIO, in background, minimized */
 'start /WIN /B /MIN 'exec_dir||'\act.exe 'params' "'tts'"'
 call syssleep 5
end
else sawl= '' /* to have some feedback */
return sawl

close_torrent:
ds= wlist.sl  /* get from 4th word on */
w4= substr(ds, wordindex(ds, 4))
w2= current_dir||'\'||w4||'*' /* NOTE ASTERISK; see below */
w2= substr(w2, 3) /* remove drive for 'move' syntax */
w3= finished_dir
w3= substr(w3, 3, length(w3) - 2)
call syscurpos maxy, 1
say /* w2 with '*' wildcard is necessary because names are shortened, */
if k = 'F' | k = 'A' then 'move "'w2'" "'w3'"' /* SO, possibly will */
say                                            /* move more than 1! */
if pos('(', w4) > 0 then do /* v6 NOW a similar anomaly with pgmcntrl! */
  w4= substr(w4, 1, pos('(', w4) - 1) /* has a "regular expression" */
end                 /* v6 "feature" that requires chopping at any "(" */
if pos('[', w4) > 0 then do   /* v6 yet ANOTHER char unacceptable to */
  w4= substr(w4, 1, pos('[', w4) - 1)   /* pgmcntrl; yet MUST use the */
end  /* "regular expresion" syntax because have only part names available */
return

ex_read_key: /* returns two bytes for extended codes */
xrkey= sysgetkey('noecho')
if xrkey = d2c(0) | xrkey = d2c(224) then xrkey= xrkey||sysgetkey('noecho')
return xrkey

delete_tor: /* v7 all new */
call show_new_list finished_dir||'\*.torrent'
if torrents.0 = 0 then do  /* bail out after message if none in dir */
  call beep 1000, 250
  say; say ' !!! No .torrent files in 'finished_dir
  call syssleep 3
  quit= 1
end
else do
  do while k <> k_esc
    if chars() > 0 then do
      k= ex_read_key()
      select
      when k = k_up | k = k_down then do /* move cursor */
        call syscurpos sl - 1, 0
        call charout, norcolr||torrents.sl   /* un-highlight */
        if k = k_up & sl > 1 then sl= sl - 1
        if k = k_down & sl < nmax then sl= sl + 1
        call syscurpos sl - 1, 0
        call charout, revcolr||torrents.sl||norcolr  /* highlight */
      end
      when k = k_del then do  /* remove drive letter for move */
        call syscurpos maxy, 0 /* position to bottom, still messy */
        'move "'substr(finished_dir, 3)'\'torrents.sl'*" "'substr(deleted_dir, 3)'"'
        'del "'info_dir'\'torrents.sl'*"'  /* assumes unique, but no big deal if not */
        call show_new_list finished_dir||'\*.torrent' /* wildcard because ^ may be shortened */
        if torrents.0 = 0 then k= k_esc /* to bail out when none left */
      end
      otherwise nop
      end /* select */
    end /* chars() > 0 */
    else call syssleep 0.1
  end  /* while k <> k_esc */
  call syscls
end /* some in dir */
return

delete_or_edit_info: /* v9 new by duplicating delete_tor */
call show_new_list info_dir||'\*.info'
if torrents.0 = 0 then do  /* bail out after message if none in dir */
  call beep 1000, 250
  say; say ' !!! No .info files in 'info_dir
  call syssleep 3
  quit= 1
end
else do
  do while k <> k_esc
    if chars() > 0 then do
      k= ex_read_key()
      select
      when k = k_up | k = k_down then do  /* move cursor */
        call syscurpos sl - 1, 0
        call charout, norcolr||torrents.sl   /* un-highlight */
        if k = k_up & sl > 1 then sl= sl - 1
        if k = k_down & sl < nmax then sl= sl + 1
        call syscurpos sl - 1, 0
        call charout, revcolr||torrents.sl||norcolr  /* highlight */
      end
      when k = k_del then do /* delete 1 file */
        call syscurpos maxy, 0 /* position to bottom, still messy */
        'del "'info_dir'\'torrents.sl'*"'
        call show_new_list info_dir||'\*.info'
        if torrents.0 = 0 then k= k_esc /* to bail out when none left */
      end
      when k = k_tab then do /* invoke tedit */
        rc= sysfiletree(pathnwild, 'torrents.', 'FO') /* names may have been */
        'tedit "'torrents.sl'"'    /* shortened, so get files again */
        call show_new_list info_dir||'\*.info' /* now go back to standard */
      end
      otherwise nop
      end /* select */
    end /* chars() > 0 */
    else call syssleep 0.1
  end  /* while k <> k_esc */
  call syscls
end /* some in dir */
return

show_new_list: /* v7 all new; v9 minor changes to use w delete_info */
parse arg pathnwild
say norcolr'Reading file list...' /* this avoids wrong colors: LEAVE */
rc= sysfiletree(pathnwild, 'torrents.', 'FO')
call syscls
if torrents.0 > 0 then do
  nmax= torrents.0
  if nmax > maxy + 1 then nmax= maxy + 1 /* for simplicity limit to screen */
  do n= 1 to nmax
    torrents.n= substr(torrents.n, lastpos('\', torrents.n) + 1) /* strip path */
    if length(torrents.n) > maxx then do
      torrents.n= substr(torrents.n, 1, maxx) /* shorten for display */
    end
    say torrents.n
  end
  call syscurpos maxy, 0
  call charout, '  ÄÄ Select with up & down arrows: <delete> ÄÄ <tab> edit ÄÄ <esc> exit ÄÄ'
  sl= nmax % 2
  call syscurpos sl - 1, 0
  call charout, revcolr||torrents.sl /* initial highlight */
end
return

constants:
/* text screen colors: used for highlighting */
black= 0; red= 1; green= 2; yellow= 3;
blue= 4; magenta= 5; cyan= 6; white= 7;
fgnd= 30   /* add color: 30 + 2 = 32 ==> green foreground */
bgnd= 40   /* add color: 40 + 7 = 47 ==> white background */
AEsc= '1B'x||'['  /* define ANSI-ESCape; + 0 = low, 1 = high int*/
norcolr= AEsc||'0;'||fgnd + white||';'||bgnd + black||'m' /* normal */
revcolr= AEsc||'0;'||fgnd + black||';'||bgnd + white||'m' /* reverse */
dkgray= AEsc||'1;'||fgnd + black||';'||bgnd + black||'m' /* divider, title */
dkcyan= AEsc||'0;'||fgnd + cyan||';'||bgnd + black||'m' /* low light 'done' */
pccolr= AEsc||'1;'||fgnd + cyan||';'||bgnd + black||'m' /* percent */
dncolr= AEsc||'1;'||fgnd + green||';'||bgnd + black||'m' /* download */
upcolr= AEsc||'1;'||fgnd + red||';'||bgnd + black||'m' /* upload */
ansi_clreol= AEsc||'K'

/* CONSTANTs for keys; see ex_read_key */
zky= d2c(0);  xky= d2c(224); /* prefixes for extended keys */
k_esc= x2c('1b');  k_enter= x2c('0d');  k_bksp= d2c(8);  k_tab= d2c(9);
k_up= 'àH';  k_down= 'àP';  k_left= 'àK';  k_right= 'àM'; k_del= 'àS';
k_f1= zky||';';
return

help:
say
say version
say '<backspace>: to start new torrents downloaded into 'download_dir
say '<up-arrow>, <down-arrow>: highlight to select, then'
say '  (S)top: closes the selected torrent window by means of PGMCNTRL'
say '  (F)inish: closes window and moves .torrent file to 'finished_dir
say '<delete>: starts selecting to move a .torrent to 'deleted_dir
say '  (You must Finish a torrent before available to delete. Actually,'
say '   torrent files remain in 'deleted_dir' in case you need again.)'
say '<tab>: switch to delete from list of .info files to try new tracker.'
say '(a)ll: starts a loop to close All torrent windows; can <esc> on each.'
say '<ctrl-c>: sort of exits (to be similar in operation to act.exe)'
say 'F1, '?', or 'h': displays these comprehensive instructions.'
say
say ' Starting a new torrent with <backspace> uses tedit to look at its info.'
say ' Set a desired tracker by putting an * in 1st column by number, OR'
say ' to set the default tracker, * as the first byte of the .info file.'
say ' If you do not, you will be presented with the list: just press 0 - 9.'
say ' Choice will be saved in the .info file. You can edit it again manually,'
say ' or delete the .info file to re-do the process upon start or <backspace>.'
say ' (Check that the tracker is actually working!)'
say
say upcolr'UpLoad Rate'norcolr' limit is currently: 'upcolr||ulr||norcolr' K Bytes/S'
say
say '  Hit <esc> to refresh before entering a command...'
return
