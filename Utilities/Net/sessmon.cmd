/* Get session information */
/* Bill Marshall */

/* monitor sessions on OS/2 servers */

  call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
  call LoadLsRxutFuncs

parse arg srvname computername
  
  NETSESSION   = 180

if (srvname = "") then do
   say "Syntax: sessmon server client "
   exit
end /* do */

if (left(computername,2) <> "\\") then
  computername = "\\" || computername

if (left(srvname,2) <> "\\") then
  srvname = "\\" || srvname

  srvname = strip(srvname)
  computername = strip(computername)

fname = computername || ".log"
fname = strip(translate(fname,'',"\"))

debug = 0

expidle = 60*4  /* initially start at 4 minutes */

do while 1
  idletime = chkidle()

  if (idletime = -1) then do 
        delay = 60*30   /* sleep 30 minutes if no connection */
        call syssleep delay
        outline = date(S) time() left(srvname,10) left(sessionInfo.cname,8) "No connection"
        rc = lineout(FNAME, outline)
        iterate /* next */
  end /* do */

  if (idletime > expidle) then expidle = 60*5   /* up to 5 minutes if we get over 4 */
  stime = expidle - idletime   /* sleep until right before the time */
  if (stime > 0) then do
    if debug then say 'Sleeping' stime  
    call syssleep stime  

  end /* do */
  else do   /* hmm - not an expected time, wake up every 30 */
    delay = 30
    if debug then say 'Sleeping' delay

    call syssleep delay
  end /* do */

end 
exit 0


chkidle: 
  
  myRc = NetGetInfo(NETSESSION, 'sessionInfo', SrvName, ComputerName)
  
  if myRc <> '0' then do
   say 'Error from NetGetInfo()' srvname computername myRc
   return -1
  end
  
/*   say
  say 'The computer name:    ' sessionInfo.cname
  say 'Userid:               ' sessionInfo.username
  say 'Connections made:     ' sessionInfo.num_conns
  say 'Number opens:         ' sessionInfo.num_opens
  say 'Sessions established: ' sessionInfo.num_users
  say 'Session time:         ' sessionInfo.time
  say 'Idle time:            ' sessionInfo.idle_time / 60 ' min'  */
x = format(sessionInfo.idle_time / 60, 4, 1)
outline = date(S) time() left(srvname,10) left(sessionInfo.cname,8) format(sessionInfo.num_conns,3) sessionInfo.num_opens x 'min' 
say outline
/*   say 'User flags:           ' sessionInfo.user_flags
  say 'Client type:          ' sessionInfo.cltype_name  */
  
rc = lineout(FNAME, outline)
    if debug then say "RC:::" rc FNAME
return  sessionInfo.idle_time
 
  exit 0
  
    
