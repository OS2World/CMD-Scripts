/*======================================================================
DSS_RMT.CMD v1.3 - REXX script for controlling Doodle's Screen Saver
======================================================================*/

parse arg input

numeric digits 12
call RxFuncAdd 'SysLoadFuncs', 'rexxutil', 'sysloadfuncs'
call SysLoadFuncs
call rxfuncadd 'rxuinit', 'rxu', 'rxuinit'
call rxuinit

file. = ''
dss.  = ''
hsem. = ''
def.  = 0
opt.  = 0
res.  = 0
mem.  = ''

def._version = '1.3'

dss._dll                  = 'sscore.dll'
dss._epnt_tempdisable     = 'SSCore_TempDisable'
dss._epnt_tempenable      = 'SSCore_TempEnable'
dss._epnt_startsavingnow  = 'SSCore_StartSavingNow'
dss._epnt_getcurrentstate = 'SSCore_GetCurrentState'
dss._epnt_getinfo         = 'SSCore_GetInfo'

def._timeout_reqdis = 10800    /* Timeout in Sek. fÅr DSSaver im deaktivertem Modus */
def._timeout_proc   =   300    /* Timeout in Sek. fÅr den Test auf Prozesse */
def._timeout_sem    =    20    /* Timeout in Sek. fÅr Zugriff auf Semaphoren */
def._timeout_server =    20    /* Timeout in Sek. fÅr Start und Ende des Servers */

sem._dss_dis     = '\sem32\dss_rmt\disable.sem'
sem._dss_ena     = '\sem32\dss_rmt\enable.sem'
sem._terminate   = '\sem32\dss_rmt\server_terminate.sem'
sem._status      = '\sem32\dss_rmt\status.sem'
sem._status_req  = '\sem32\dss_rmt\status_req.sem'
sem._status_acc  = '\sem32\dss_rmt\status_acc.sem'
sem._access      = '\sem32\dss_rmt\access_ctrl.sem'

parse upper source . . file._self
parse value reverse(file._self) with . '.' file._root
file._root = reverse(file._root)
file._cfg  = file._root'.CFG'
file._pid  = file._root'.PID'

cr = '0d'x ; lf = '0a'x ; crlf = cr||lf ; tab = '09'x ; nul = '00'x ; eof = '1a'x

common_var = 'cr lf crlf tab nul eof',
             'res.'   ,
             'file.'  ,
             'opt.'   ,
             'def.'   ,
             'dss.'   ,
             'mem.'   ,
             'sem.'   ,
             'hsem.'

select
  when input = '-Start_DSS_Remote_Server'
    then opt._server = 1
  when input = ''
    then call prg_help
  when words(input) <> 1
    then call error_254_2
  otherwise
    input = strip(translate(input))
    select
      when input = '-S'
        then nop                    /* Start server in background */
      when input = '-SFG'
        then def._debug = 1         /* Start server in foreground */
      when input = '-K'
        then opt._action = 1        /* Terminate server */
      when input = '-E'
        then opt._action = 2        /* Enable DSSaver */
      when input = '-D'
        then opt._action = 3        /* Disable DSSaver */
      when input = '-Q'
        then opt._action = 4        /* Read status */
      when input = '-B'
        then opt._action = 5        /* Blank screen immediately */
      otherwise
        call error_254_1
    end
end


select
  when opt._server = 1                        /* Server task */
    then call proc_server
  when opt._action = 5                        /* Blank screen immediately */
    then
    do
      call open_sem_access
      call init_sscore_dll
      say ': Request to blank screen immediately'
      if dss._version >= 1.50
        then y = rxcallentrypoint(dss._addr_getcurrentstate)
        else y = 0
      select
        when y > 1
          then call error_244_1 y, dss._epnt_getcurrentstate
        when y = 1
          then nop
        otherwise
          y = rxcallentrypoint(dss._addr_startsavingnow, 0)
          if y <> 0
            then call error_244_1 y, dss._epnt_startsavingnow
      end
      call syssleep 0.2
      call rxreleasemutexsem hsem._access
    end
  when opt._action = 4                        /* Read status */
    then
    do
      call request_server_comm
      call init_sscore_dll
      call read_status
    end
  when opt._action = 3                        /* Disable DSSaver */
    then
    do
      call request_server_comm
      call init_sscore_dll
      say ': Request to disable DSSaver ...'
      call rxposteventsem hsem._dss_dis
      call rxwaiteventsem hsem._status_req
      call read_status
    end
  when opt._action = 2                        /* Enable DSSaver */
    then
    do
      call request_server_comm
      call init_sscore_dll
      say ': Request to enable DSSaver ...'
      call rxposteventsem hsem._dss_ena
      call rxwaiteventsem hsem._status_req
      call read_status
    end
  when opt._action = 1                        /* Terminate server */
    then call server_terminate
  otherwise
    call server_start
end

call clean_up

exit res._term

/**********************************************************************/

error_244_1:
say '* Error' arg(1) 'function call' arg(2)
call clean_up
exit 244

error_245_1:
say '* Error reading status'
call clean_up
exit 245

error_246_1:
say '* Error creating semaphores'
call clean_up
exit 246

error_247_1:
say '* Error loading' dss._dll
call clean_up
exit 247

error_248_1:
say '* Timeout terminating server'
call clean_up
exit 248

error_249_1:
say '* Server is already running'
call clean_up
exit 249

error_250_1:
say '* Server is not running'
call clean_up
exit 250

error_251_1:
say '* Timeout starting server'
call clean_up
exit 251

error_252_1:
say '* Timeout requesting' sem._access
call clean_up
exit 252

error_253_1:
say '* Error creating or opening' sem._access
exit 253

error_254_2:
say '* Only one option allowed'
exit 254

error_254_1:
say '* Invalid option' input
exit 254

/**********************************************************************/

clean_up:

if dss._hmod \== ''
  then
  do
    res = rxfreemodule(dss._hmod)
    if res <> 0
      then
      do
        say '* Error' res 'freeing' dss._dll
        res._term = 200
      end
  end

if length(hsem._mux_main) = 4
  then call rxclosemuxwaitsem hsem._mux_main
if length(hsem._timer_term) = 4
  then
  do
    call rxposteventsem hsem._timer_term
    call rxcloseeventsem hsem._timer_term
  end
if length(hsem._timer) = 4
  then call rxcloseeventsem hsem._timer
if length(hsem._dss_dis) = 4
  then call rxcloseeventsem hsem._dss_dis
if length(hsem._dss_ena) = 4
  then call rxcloseeventsem hsem._dss_ena
if length(hsem._status_req) = 4
  then call rxcloseeventsem hsem._status_req
if length(hsem._terminate) = 4
  then call rxcloseeventsem hsem._terminate
if length(hsem._status_acc) = 4
  then
  do
    call rxreleasemutexsem hsem._status_acc
    call rxclosemutexsem hsem._status_acc
  end
if length(hsem._status) = 4
  then call rxcloseeventsem hsem._status

if length(hsem._access) = 4
  then
  do
    call rxreleasemutexsem hsem._access
    call rxclosemutexsem hsem._access
  end

if mem._addr.1 \== ''
  then call rxfree mem._addr.1


return

/**********************************************************************/

read_status: procedure expose (common_var)

call rxrequestmutexsem hsem._status_acc, 'Indefinite'
parse value rxqueryeventsem(hsem._status) with t.1 t.2
if t.1 <> 0 | t.2 < 0 | t.2 > 3
  then call error_245_1
parse value '01010011' with +(t.2) t.3 +1 =5 +(t.2) t.4 +1 .
say ': DSSaver' word('enabled disabled', (t.2 > 0) +1)': Request =' t.3', watchdog =' t.4
res._term = t.2
call rxreseteventsem hsem._status_req
call rxreleasemutexsem hsem._status_acc

if dss._version >= 1.50
  then
  do
    t.1 = rxcallentrypoint(dss._addr_getcurrentstate)
    if t.1 > 1
      then call error_244_1 t.1, dss._epnt_getcurrentstate
    if t.1 = 0
      then say ': DSSaver status: Normal'
      else say ': DSSaver status: Saving'
    res._term = res._term + t.1 *4
  end

call rxreleasemutexsem hsem._access

return

/**********************************************************************/

server_terminate: procedure expose (common_var)

call request_server_comm
call query_server_pid
call rxposteventsem hsem._terminate
call rxreleasemutexsem hsem._access

if def._server_pid <> ''
  then
  do
    say ': Terminating server (PID' def._server_pid') ...'
    call time 'r'
    pid = right(translate(d2x(def._server_pid), 'abcdef', 'ABCDEF'), 4, 0)
    do forever
      call rxqprocstatus 'p.'
      y = p.0p.0
      do until y = 0
        if p.0p.y.1 = pid
          then leave
        y = y -1
      end
      select
        when y = 0
          then
          do
            say ': Server terminated'
            leave
          end
        when time('e') < def._timeout_server
          then call syssleep 0.1
        otherwise
          call error_248_1
      end
    end
  end
  else
  do
    say '+ Unable to read' file._pid
    say ': Terminating server ...'
  end

return

/**********************************************************************/

server_start: procedure expose (common_var)

call open_sem_access
if open_sems() = 0
  then call error_249_1

call rxreleasemutexsem hsem._access

if def._debug
  then
  do
    say '+ Starting server in foreground session'
    '@start /f cmd.exe /c' file._self '-Start_DSS_Remote_Server'
  end
  else
  do
    call rxrsoe2f 'nul'
    '@detach' file._self '-Start_DSS_Remote_Server'
    call rxrsoe2f 'con'
  end

call time 'r'
do forever
  select
    when rxrequestmutexsem(hsem._access, 100) <> 0
      then if time('e') > def._timeout_server
        then call error_251_1
    when open_sems() = 0
      then
      do
        call query_server_pid
        call rxreleasemutexsem hsem._access
        leave
      end
    otherwise
      call rxreleasemutexsem hsem._access
      if time('e') > def._timeout_server
        then call error_251_1
      call syssleep 0.1
  end
end

say ': Server started (PID' def._server_pid')'

return

/**********************************************************************/

request_server_comm: procedure expose (common_var)

call open_sem_access
if open_sems() <> 0
  then call error_250_1       /* Server not running */

return

/**********************************************************************/

open_sem_access: procedure expose (common_var)

arg flag
call time 'r'
do forever
  select
    when rxcreatemutexsem('hsem._access', 'Shared', sem._access) = 0
      then leave
    when rxopenmutexsem('hsem._access', sem._access) = 0
      then leave
    when time('e') < def._timeout_sem
      then call syssleep 0.1
    otherwise
      call error_253_1
  end
end

select
  when flag <> ''
    then call rxrequestmutexsem hsem._access, 'Indefinite'
  when rxrequestmutexsem(hsem._access, def._timeout_sem *1000) <> 0
    then call error_252_1
  otherwise
end

return

/**********************************************************************/

open_sems: procedure expose (common_var)

select
  when rxopeneventsem('hsem._dss_dis', sem._dss_dis) <> 0
    then res = 1
  when rxopeneventsem('hsem._dss_ena', sem._dss_ena) <> 0
    then res = 1
  when rxopeneventsem('hsem._status_req', sem._status_req) <> 0
    then res = 1
  when rxopeneventsem('hsem._terminate', sem._terminate) <> 0
    then res = 1
  when rxopenmutexsem('hsem._status_acc', sem._status_acc) <> 0
    then res = 1
  when rxopeneventsem('hsem._status', sem._status) <> 0
    then res = 1
  otherwise
    res = 0
end

return res

/**********************************************************************/

query_server_pid: procedure expose (common_var)

if rxopen('fh.', file._pid, 'O', 'MnR') <> 0
  then def._server_pid = ''
  else
  do
    call rxread 'def._server_pid', fh.1, 10
    call rxcloseh fh.1
    parse var def._server_pid def._server_pid (cr) .
    if \datatype(def._server_pid, 'w') | def._server_pid < 0
      then def._server_pid = ''
  end

return def._server_pid

/**********************************************************************/

init_sscore_dll: procedure expose (common_var)

if rxloadmodule('dss._hmod', dss._dll) <> 0
  then
  do
    dss._hmod = ''
    call error_247_1
  end
if rxqueryprocaddr('dss._addr_getinfo'        , dss._hmod, dss._epnt_getinfo)         <> 0 |,
   rxqueryprocaddr('dss._addr_tempdisable'    , dss._hmod, dss._epnt_tempdisable)     <> 0 |,
   rxqueryprocaddr('dss._addr_tempenable'     , dss._hmod, dss._epnt_tempenable)      <> 0 |,
   rxqueryprocaddr('dss._addr_startsavingnow' , dss._hmod, dss._epnt_startsavingnow)  <> 0
  then call error_247_1
mem._addr.1 = rxmalloc(8)

y = rxcallentrypoint(dss._addr_getinfo, mem._addr.1, 8)
if y <> 0
  then call error_244_1 y, dss._epnt_getinfo
if rxcallentrypoint(dss._addr_getinfo, mem._addr.1, 8) <> 0
  then call error_247_1
parse value reverse(rxstorage(mem._addr.1, 8)) with t.1 +4 t.2 +4 .
dss._version = c2d(t.2)'.'c2d(t.1)
if dss._version >= 1.50
  then if rxqueryprocaddr('dss._addr_getcurrentstate', dss._hmod, dss._epnt_getcurrentstate) <> 0
    then call error_247_1

return

/**********************************************************************/

proc_server: procedure expose (common_var)

signal on halt name proc_server_exit

call open_sem_access 'i'
call init_sscore_dll
call read_prg_cfg

if rxcreateeventsem('hsem._terminate', 'Shared', sem._terminate) <> 0 |,
   rxcreatemutexsem('hsem._status_acc', 'Shared', sem._status_acc) <> 0 |,
   rxcreateeventsem('hsem._status', 'Shared', sem._status) <> 0 |,
   rxcreateeventsem('hsem._dss_dis', 'Shared', sem._dss_dis) <> 0 |,
   rxcreateeventsem('hsem._dss_ena', 'Shared', sem._dss_ena) <> 0 |,
   rxcreateeventsem('hsem._status_req', 'Shared', sem._status_req) <> 0
  then call error_246_1

mux_sem.0 = 3
mux_sem.1.1 = hsem._dss_dis     /* diable DSSaver */
mux_sem.1.2 = 1
mux_sem.2.1 = hsem._dss_ena     /* enable DSSaver */
mux_sem.2.2 = 2
mux_sem.3.1 = hsem._terminate   /* terminate server  */
mux_sem.3.2 = 3
call rxcreatemuxwaitsem 'hsem._mux_main', 'mux_sem.',, 'Y'


  /* Falls Prozess-Liste definiert ist, Timer starten */
if def._proclist \== '*' & def._timeout_proc > 0
  then
  do
    call rxcreateeventsem 'hsem._timer_term'
    call rxcreateeventsem 'hsem._timer'
    call rxaddmuxwaitsem hsem._mux_main, hsem._timer, 4
    call rxcreaterexxthread "$parse arg t, hsem._timer_term, hsem._timer;" ||,
                            "do while rxwaiteventsem(hsem._timer_term, t) = 640;" ||,
                              "call rxposteventsem hsem._timer;" ||,
                            "end;", def._timeout_proc *1000, hsem._timer_term, hsem._timer
  end

parse value rxprocid() with def._server_pid .
call rxopen 'hfile.', file._pid, 'CR', 'MwB'
call rxwrite hfile.1, def._server_pid || crlf

call rxreleasemutexsem hsem._access

call wlog ': DSS_RMT.CMD version' def._version
call wlog ': SSCore.Dll version' dss._version
call wlog ': Server PID' def._server_pid
call wlog ': Configuration file "'file._cfg'"'
call wlog file._cfg_status
do while file._cfg_error \== ''
  parse var file._cfg_error t.1 (cr) file._cfg_error
  call wlog '+' t.1
end
if def._pmprintf
  then call wlog ': PMPRINTF enabled'left(', queue', (def._pmprintf_queue <> '') *8) || def._pmprintf_queue
  else call wlog ': PMPRINTF disabled'
if def._timeout_reqdis = 0
  then call wlog ': Timeout disable request: Indefinite'
  else call wlog ': Timeout disable request:' def._timeout_reqdis 'sec.'
t.1 = rxscount('*', def._proclist) -1
if t.1 < 1
  then call wlog ': Process watchdog: disabled'
  else
  do
    call wlog ': Process watchdog:' t.1 word('process processes', min(t.1, 2)) 'listed'
    call wlog ': Timeout process watchdog:' def._timeout_proc 'sec.'
    t.1 = substr(def._proclist, 2)
    do while t.1 \== ''
      parse var t.1 t.2 '*' t.1
      call wlog ': Process "'t.2'"'
    end
  end
drop t.


do forever

  select
    when def._disable_req = 0
      then timeout = 'Indefinite'
    when def._timeout_reqdis = 0
      then timeout = 'Indefinite'
    otherwise
      timeout = max(0, format(def._timeout_reqdis - time('e'),, 0)) *1000
  end

  parse value rxwaitmuxwaitsem(hsem._mux_main, timeout) with mux_res_1 mux_res_2
  select
    when mux_res_2 = 1            /* Request to disable DSSaver */
      then
      do
        call time 'r'
        str = ': Req <1>  Wdog  'def._disable_proc'  '
        if def._disable_req = 0 & def._disable_proc = 0
          then str = str dss._epnt_tempdisable' rc =' rxcallentrypoint(dss._addr_tempdisable)
        def._disable_req = 1
        call wlog str
        call rxreseteventsem hsem._dss_dis
        call set_status_sem
        call rxposteventsem hsem._status_req
      end

    when mux_res_2 = 2            /* Request to enable DSSaver */
      then
      do
        str = ': Req <0>  Wdog  'def._disable_proc'  '
        if def._disable_req = 1 & def._disable_proc = 0
          then str = str dss._epnt_tempenable' rc =' rxcallentrypoint(dss._addr_tempenable)
        def._disable_req = 0
        call wlog str
        call rxreseteventsem hsem._dss_ena
        call set_status_sem
        call rxposteventsem hsem._status_req
      end

    when mux_res_2 = 3            /* Terminate server */
      then
      do
        call wlog ': Terminating server'
        if def._disable_req = 1 | def._disable_proc = 1
          then call rxcallentrypoint dss._addr_tempenable
        leave
      end

    when mux_res_2 = 4            /* Watchdog timer */
      then
      do
        call rxqprocstatus 'p.'
        y = p.0p.0
        do until y = 0
          if pos('*'filespec('n', p.0p.y.6)'*', def._proclist) > 0
            then leave
          if pos('*'p.0p.y.6'*', def._proclist) > 0
            then leave
          y = y -1
        end
        select
          when y = 0 & def._disable_proc = 1
            then
            do
              str = ': Req  'def._disable_req'   Wdog <0> '
              if def._disable_req = 0
                then str = str dss._epnt_tempenable' rc =' rxcallentrypoint(dss._addr_tempenable)
              def._disable_proc = 0
              call wlog str
              call set_status_sem
            end
          when y > 0 & def._disable_proc = 0
            then
            do
              str = ': Req  'def._disable_req'   Wdog <1> '
              if def._disable_req = 0
                then str = str dss._epnt_tempdisable' rc =' rxcallentrypoint(dss._addr_tempdisable)
              def._disable_proc = 1
              call wlog str
              call set_status_sem
            end
          otherwise
        end
        call rxreseteventsem hsem._timer
      end

    when mux_res_1 = 640          /* Timeout */
      then
      do
        str = ': Exp <0>  Wdog  'def._disable_proc'  '
        if def._disable_proc = 0
          then str = str dss._epnt_tempenable' rc =' rxcallentrypoint(dss._addr_tempenable)
        def._disable_req = 0
        call wlog str
        call set_status_sem
      end

    otherwise                     /* ??? */
      call wlog '* RxWaitMuxWaitSem() = "'mux_res_1 mux_res_2'"'
      leave
  end

end

call rxcloseh hfile.1
call sysfiledelete file._pid

return



proc_server_exit:

call rxcloseh hfile.1
call sysfiledelete file._pid
call clean_up

exit 100

/**********************************************************************/

set_status_sem: procedure expose (common_var)

call rxrequestmutexsem hsem._status_acc, 'Indefinite'
call rxreseteventsem hsem._status
do def._disable_req + def._disable_proc *2
  call rxposteventsem hsem._status
end
call rxreleasemutexsem hsem._status_acc

return

/**********************************************************************/

read_prg_cfg: procedure expose (common_var)

def._proclist = '*'

file._cfg_status = rxopen('fh.', file._cfg, 'O', 'MnR')
if file._cfg_status <> 0
  then
  do
    file._cfg_status = '+ Open error' file._cfg_status
    return
  end

cfg_str = ''
do forever
  parse value rxread('data', fh.1, 4096) with t.1 t.2
  if t.1 <> 0
    then leave
  if t.2 = 0
    then leave
  cfg_str = cfg_str || data
  if t.2 < 4096
    then leave
end
call rxcloseh fh.1
file._cfg_status = ':' length(cfg_str) 'bytes read'

s_begin = 1
do l = 1 until rest == ''
  parse var cfg_str =(s_begin)cfg_line(crlf) +2 rest +1
  s_begin = s_begin +length(cfg_line) +2

  parse var cfg_line keyword kwdata ';' .
  if keyword = ''
    then iterate
  keyword = translate(keyword)
  kwdata  = strip(kwdata)

  select
    when keyword = 'TIMEOUT_DIS'
      then
      do
        if \datatype(kwdata, 'w') | kwdata < 0 | kwdata > 999999
          then file._cfg_error = file._cfg_error || "Keyword TIMEOUT_DIS: Invalid value '" || kwdata || "'" || cr
          else def._timeout_reqdis = kwdata
      end
    when keyword = 'TIMEOUT_PROC'
      then
      do
        if \datatype(kwdata, 'w') | kwdata < 1 | kwdata > 999999
          then file._cfg_error = file._cfg_error || "Keyword TIMEOUT_PROC: Invalid value '" || kwdata || "'" || cr
          else def._timeout_proc = kwdata
      end
    when keyword = 'PMPRINTF'
      then
      do
        if words(kwdata) > 1 | length(kwdata) > 8
          then file._cfg_error = file._cfg_error || "Keyword PMPRINTF: Invalid queue name '" || kwdata || "'" || cr
          else
          do
            def._pmprintf = 1
            def._pmprintf_queue = kwdata
          end
      end
    when keyword = 'PROCESS'
      then
      do
        kwdata = strip(kwdata,, '"')
        if kwdata <> ''
          then def._proclist = def._proclist || translate(kwdata) || '*'
      end
    otherwise
      file._cfg_error = file._cfg_error || 'Unknown keyword' keyword || cr
  end

end

return

/**********************************************************************/

wlog: procedure expose (common_var)

parse arg l1 l2
l2 = l1 translate('1234/56/78', date('s'), '12345678')'-'time('n') 'DSS_RMT' l2
say l2
if def._pmprintf
  then call rxpmprintf def._pmprintf_queue, l2

return

/**********************************************************************/

prg_help:

say
say left(' -= DSS_RMT v'def._version' =-', 48) || right('(c) 2005 R.Wilke', 30)
say copies('-', 78)
say
say ' REXX script for controlling DSSaver'
say
say ' Usage:   DSS_RMT.CMD  [-S|-SFG|-K|-D|-E|-B|-Q]'
say
say ' Options: -S    start server in background session'
say '          -SFG  start server in foreground session'
say '          -K    terminate server'
say '          -D    request to disable DSSaver'
say '          -E    request to enable DSSaver'
say '          -Q    display status of server and DSSaver'
say '          -B    blank screen immediately'
say
say ' Calling DSS_RMT with no option will show this help.'
say

exit 99

