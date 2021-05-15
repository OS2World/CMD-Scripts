/* Restore local home directory shares */

/* Initialize RexxUtil */
if RxFuncQuery( "SysFileTree" ) <> 0 then do
	call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
	call SysLoadFuncs
end

/* Do not display external commands */
"@ECHO OFF"

/* Check and interpret command line parameter */
parse upper arg drive":\"homedir_path dummy
if dummy          <> "" then call Syntax
if drive           = "" then call Syntax
if length( drive ) <> 1 then call Syntax
if homedir_path    = "" then call Syntax

/* Read a list of all home directories */
homedir_path = strip( homedir_path, "T", "\" )
homedirs     = drive||":\"||homedir_path||"\*"
call SysFileTree homedirs, "homedir.", "DO"
if homedir.0 < 1 then do
	call Syntax "NoDirs"
end
else do i = 1 to homedir.0
	backslash  = lastpos( "\", homedir.i )
	share_name = substr( homedir.i, backslash + 1 )
	commando = "NET SHARE "||share_name||"="||drive||":\"
	commando = commando||homedir_path||"\"||share_name
	address CMD commando
end
EXIT 0


Syntax:
	param = translate( arg( 1 ) )
	call SysCls
	say
	say "LHOMEDIR,  Version 1.02"
	say "Written by Rob van der Woude"
	say "http://www.robvanderwoude.com"
	say
	say "Locally restore the shares of all home directories."
	say "Should be run from the console of the home"
	say "directories server."
	say
	say "Use RHomeDir if you want to restore remote shares."
	say
	if param = "NODIRS" then do
		say "No subdirectories found in"
		say drive||":\"||homedir_path
		say
	end
	say "Usage:  LHOMEDIR  <homedir_path>"
	say
	say "where <homedir_path> is the directory containing"
	say "the home directories"
	EXIT 1
return
