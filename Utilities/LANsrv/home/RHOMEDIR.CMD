/* Restore remote home directory shares */

/* Initialize RexxUtil */
if RxFuncQuery( "SysFileTree" ) <> 0 then do
	call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
	call SysLoadFuncs
end

/* Do not display external commands */
"@ECHO OFF"

/* Check and interpret command line parameter */
parse upper arg "\\"server"\"drive"$\"homedir_path dummy
if dummy          <> "" then call Syntax
if server          = "" then call Syntax
if drive           = "" then call Syntax
if length( drive ) <> 1 then call Syntax
if homedir_path    = "" then call Syntax

/* Read a list of all home directories */
homedir_path = strip( homedir_path, "T", "\" )
homedirs     = "\\"||server||"\"||drive||"$\"||homedir_path||"\*"
call SysFileTree homedirs, "homedir.", "DO"
if homedir.0 < 1 then do
	call Syntax "NoDirs"
end
else do i = 1 to homedir.0
	backslash  = lastpos( "\", homedir.i )
	share_name = substr( homedir.i, backslash + 1 )
	commando = "NET ADMIN \\"||server||" /C"
	commando = commando||" NET SHARE "||share_name||"="
	commando = commando||drive||":\"||homedir_path||"\"||share_name
	address CMD commando
end
EXIT 0


Syntax:
	param = translate( arg( 1 ) )
	call SysCls
	say
	say "RHOMEDIR,  Version 1.02"
	say "Written by Rob van der Woude"
	say "http://www.robvanderwoude.com"
	say
	say "Remotely restore the shares of all home directories."
	say
	say "Use LHomeDir if you want to restore local shares."
	say
	if param = "NODIRS" then do
		say "No subdirectories found in"
		say "\\"||server||"\"||drive||"$\"||homedir_path
		say
	end
	say "Usage:  RHOMEDIR  <homedir_unc>"
	say
	say "where <homedir_unc> is the UNC name of the directory"
	say "containing the home directories"
	EXIT 1
return
