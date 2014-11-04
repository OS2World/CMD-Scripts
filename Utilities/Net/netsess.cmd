/* Get the sessions on a server */
/* Bill Marshall         */
/* IBM Rochester IGS PC Server Support                            */
/* bmarsh@us.ibm.com                                              */
/*                                                                      */
/* notes:                                                       */
/*
*/
/* 07/27/01 wrm created                 */
/***********************************************************************/
 call RxFuncAdd 'LoadLsRxutFuncs', 'LSRXUT', 'LoadLsRxutFuncs'
 call LoadLsRxutFuncs

call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs
 
call RxFuncAdd 'RxLoadFuncs', 'RXUTILS', 'RxLoadFuncs'
call RxLoadFuncs "quiet"

arg srvname d_idletime


if srvname = prompt then call prompt
srvname = strip(srvname)

if srvname = "" then do
   say "NETSESS \\srvname "
   exit
end /* do */
if ( left(srvname,2) <> "\\") then srvname = "\\" || srvname


 NETSESSION = 180
/* SrvName    = '\\rchs06gd' */
 
 myRc = NetEnumerate(NETSESSION, 'sessionInfo', SrvName)
 
 if myRc <> '0' then do
  say 'Got error from NetEnumerate() ' myRc
  call DropLsRxutFuncs
  exit 9
 end
 
 if sessionInfo.0 = 0 then do
  say 'No session established on server'
  call DropLsRxutFuncs
  exit 0
 end

say date() time() 
if (d_idletime = "") then d_idletime = 999999
else say "Sessions with idle time under" d_idletime

 do i=1 to sessionInfo.0
    sname = sessioninfo.i  /* get the name */
    sessname.i = sname  /* make new stem  & save values on machine name not index */
    sessvalue.sname.username = sessionInfo.i.username
    sessvalue.sname.num_conns = sessionInfo.i.num_conns 
    sessvalue.sname.num_opens = sessionInfo.i.num_opens
    sessvalue.sname.idle_time = sessionInfo.i.idle_time

    sessvalue.sname.num_users = sessionInfo.i.num_users
    sessvalue.sname.time = sessionInfo.i.time
    sessvalue.sname.cltype_name = sessionInfo.i.cltype_name
    sessvalue.sname.user_flags = sessionInfo.i.user_flags
/*     sessvalue.sname. = sessionInfo.i. */

 end

sessname.0 = sessionInfo.0  /* same count */
myrc = RxStemSort("sessname","a")

 say 'Number of computers having a session to server: ' sessionInfo.0
 say
  say "                                 CON OPEN   IDLE USR  ACT    OS"
 do i=1 to sessname.0
  sname = sessname.i

  idlemin = sessvalue.sname.idle_time / 60 
  actmin = sessvalue.sname.time / 60 
 if (sessvalue.sname.user_flags = 1) then FLAG = "GUEST"
 else FLAG = ""

  if (idlemin < d_idletime) then do
    say left(sname,16) left(sessvalue.sname.username,16)  sessvalue.sname.num_conns  right(sessvalue.sname.num_opens,3) format(idlemin,5,2) format(sessvalue.sname.num_users,2,0) format(actmin,5,2) right(sessvalue.sname.cltype_name,11) FLAG
/*      say format(sessionvalue.sname.num_users,5,0) format(actmin,5,2) FLAG */

  end 

 end
 
 
 exit 0
 
 
prompt:

call makeform "netsess" "What server to you want the sessions from?**(optional) Display idle time less than:"

exit
