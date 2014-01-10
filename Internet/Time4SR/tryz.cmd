/* TryZ - Feb 9, 2010 */
splash= ' TryZ v1 - Invoke Z! on all .pls and .m3u files in directory.'
/* in between, ask whether to keep that file, then do easy re-name and move*/ 

call rxfuncadd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call sysloadfuncs

say
say splash
say
say ' NOTE: the AUTO RENAME routine may NOT produce a unique name!'
say
say ' Be in directory with .pls and .m3u files; may have to put this in PATH.'

home_dir= 'C:\TSR\tryz'
'mkdir 'home_dir
home_dir= home_dir||'\' /* now need trailing '\' */
zky= x2c('00'); xky= 'à' /* constants for ex_read_key */

'attrib *.pls +r' /* MUST do so Z doesn't EAT them! GRRR! */
'attrib *.m3u +r'

rc= sysfiletree('*.pls', fl., 'FO')
call loop_z
rc= sysfiletree('*.m3u', fl., 'FO')
call loop_z
say
say 'For safety, must delete original files manually.'

exit

loop_z:
do l= 1 to fl.0
  say
  'C:\Z28\Z.EXE 'fl.l  /* edit path as necessary, or PM123, mplayer... */
  say
  say '? Do you want to keep 'fl.l'?  [ #'l' of 'fl.0' ]'
  say '> (Y)es (Auto rename) - (K)eep - (R)ename - any other key = (N)o'
  say
  do until chars()>0
    call syssleep 1
  end
  key= translate(ex_read_key())
  ext= translate(substr(fl.l, pos('.', fl.l)))  /* get extension */
  nam= substr(fl.l, lastpos('\', fl.l) + 1)     /* remove path */
  nam= substr(nam, 1, pos('.', nam) - 1)        /* remove extension */
  if key = 'R' | (key = 'Y' & ext = '.M3U') then do  /* RENAME */
    if ext = '.M3U' then do
      say
      say "An .m3u doesn't have title text inside, must manually rename."
      say
    end
    say 'Rename "'fl.l'" to (omit extension) - <enter> = keep as is :'
    parse pull newname .
    if newname = '' then newname= nam||ext
      else newname= newname||ext
  end
  if key = 'K' then do   /* KEEP (same as r, <enter> */
    newname= nam||ext
  end
  if key = 'Y' & ext = '.PLS' then do   /* AUTO rename */
    call read_pls fl.l
    pl_title = ''
    do wi= 1 to pls_text.0 /* find first; ignore rest, probably same */
      if pos('Title', pls_text.wi) > 0 & pl_title = '' then do
        /* OF COURSE, titles aren't uniform; you may need to massage more */
        pl_title= substr(pls_text.wi, pos('=', pls_text.wi) + 1)
        if pos(')', pl_title) > 0 then do
          pl_title= delstr(pl_title, 1, pos(')', pl_title) + 1)
        end
      end
    end
    do while pos(' ', pl_title) > 0  /* delete spaces */
      pl_title= delstr(pl_title, pos(' ', pl_title), 1)
    end
    do while pos(':', pl_title) > 0  /* delete illegal character */
      pl_title= delstr(pl_title, pos(':', pl_title), 1)
    end
    do while pos('&', pl_title) > 0  /* delete illegal character */
      pl_title= delstr(pl_title, pos('&', pl_title), 1)
    end
    do while pos('.', pl_title) > 0  /* delete unwanted character */
      pl_title= delstr(pl_title, pos('.', pl_title), 1)
    end
    do while pos('www', pl_title) > 0  /* delete unwanted character */
      pl_title= delstr(pl_title, pos('www', pl_title), 1)
    end
      /* ^^^ there's SO many illegal/unwanted that might routine-ize... */
    newname= pl_title
    if length(newname) > 12 then do
      newname= substr(newname, 1, 16) /* may want more or fewer characters */
      newname= strip(newname) /* because the above may PAD, dang it */
    end
    newname= newname||ext
  end
  if key = 'Y' | key = 'K' | key = 'R' then do
    'copy "'fl.l'" "'home_dir||newname'"'
  end
  call syssleep 1 /* just for a glimpse */
end
return

read_pls: /* can also be .m3u! */
parse arg pls_name
drop pls_text.
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

ex_read_key: /* returns two bytes for extended codes */
  xrkey= sysgetkey('noecho')
  if xrkey = zky | xrkey = xky then xrkey= xrkey||sysgetkey('noecho')
return xrkey
