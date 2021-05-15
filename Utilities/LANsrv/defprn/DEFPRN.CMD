/* Sample code to query the default printer port */
/* Lee S. Fields                                 */
/*                                               */
/* No guarantees, but it works for me.           */
/*                                               */
/* Modified 1998/12/21, by Rob van der Woude:    */
/* added RPL support                             */

parse arg bootdrive dummy
if dummy <> "" then call Syntax
if bootdrive = "" then do
	parse upper value value( "PATH", , "OS2ENVIRONMENT" ) with ":\OS2\SYSTEM" -1 bootdrive +2
end
bootdrive = strip( bootdrive, "T", "\" )||"\"
user   = bootdrive||"OS2\OS2.INI"
system = bootdrive||"OS2\OS2SYS.INI"

if RxFuncQuery( "SysLoadFuncs" ) <> 0 then do
	call rxfuncadd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
	call sysloadfuncs
end

defprn  = SysIni( user, "PM_SPOOLER", "PRINTER" )
defprn  = strip( defprn, , "00"X )
defprn  = strip( defprn, , ";"   )
defport = SysIni( system, "PM_SPOOLER_PRINTER", defprn )
parse value defport with defport";"defprn";".
parse value defprn with dummy"."defprn

say "Default printer is "||defprn||" on "||defport
exit

Syntax:
	say
	say "Usage: DEFPRN  [ boot_drive ]"
	say
	say "       For RPL images boot_drive should be specified as"
	say "       \\ripl_server\WRKFILES\pc_id\"
	exit
return
