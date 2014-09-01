/* REXX procedure than adds a generic icon to CMDs files and ERX files  */
/* (REXX macros for EPM).                                               */

/* Program by Salvador Parra Camacho                                    */
/* Started: 19/05/2002 (version 1.0)                                    */
/* Please, don't touch the four following lines.                        */

program_version='1.0'
program_date='19/05/2002'
program_website='Not available.'
programmer_email='x3265340@fedro.ugr.es'

/* Install the error handler for Ctrl+C.                                */

signal on halt name stop

/* Program name and description.                                        */

say ''
say '  ico4cmd: adds a generic icon to a set of CMDs and ERX files.'


/* Register and load the RexxUtil functions: rexxutil.dll.              */

if RxFuncQuery('SysLoadFuncs') <> 0 then do
	rc = RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs')
	if rc <> 0 then do
	say ''
	say '  Error registering rexxutil.dll functions (required by ico4cmd).'
	exit
	end
	end
else
	rc = SysLoadFuncs()
	if rc = 1 then do
	say ''
	say '  Error loading rexxutil.dll (required by ico4cmd).'
	exit
	end

/* Read the options from the parameters.                                */

parse arg option directory
parse source . . program

select
	when option = '' then do
		say '  You must specify some parameters.'
		call _syntax
		end
	when option = '-h' then do
		call _syntax
		end
	when option = '-v' then do
		call version
		end
	when option = '-r' then do
		o = 'FOS'
		call ico4cmd_proc
		end
	when option = '-n' then do
		o = 'FO'
		call ico4cmd_proc
		end
	otherwise
		say '  Incorrect parameters.'
		call _syntax
end
exit

/*********************** End of the main program ************************/
/************************************************************************/
/****************** Beginning of the program procedures *****************/

ico4cmd_proc:
rc = SysGetEA(program, '.ICON', data)
if directory = '' then directory = directory()
rc = SysFileTree(directory||'\*.cmd', cmd, o)
rc = SysFileTree(directory||'\*.erx', erx, o)
do i=1 to cmd.0
	rc = SysGetEA(cmd.i, '.ICON', ico.i)
	if ico.i = '' then do
		say '  Assign generic icon to '||cmd.i
		rc = SysPutEA(cmd.i, .ICON, data)
	end
end
do i=1 to erx.0
	rc = SysGetEA(erx.i, '.ICON', ico.i)
	if ico.i = '' then do
		say '  Assign generic icon to '||erx.i
		rc = SysPutEA(erx.i, .ICON, data)
	end
end
return

/* The following procedure shows the syntax.                            */

_syntax:
say ''
say '  Correct syntax:'
say '  icon4cmd.cmd [option] [directory]; where [option] can be one of the'
say '  following:'
say '    -h: shows this help.'
say '    -v: shows the version info.'
say '    -r [directory]: adds generic icon to the CMDs and ERXs located'
say '    in [directory] and all subdirectories.'
say '    -n [directory]: adds generic icon to the CMDs and ERXs located'
say '    in [directory].'
say '  If [directory] is not specified, then is considered the current'
say '  directory.'
return

/* The following procedure shows the version information.               */

version:
say ''
say '  Version (date): '||program_version||' ('||program_date||').'
say '  Web page: '||program_website
say '  Author (e-mail): Salvador Parra Camacho ('||programmer_email||').'
return

/* The following procedure defines the error handler for Ctrl+C.        */

stop:
	signal on halt name stop
	say ''
	say '  Program stopped by the user!'
return

/********************** End of the program procedures *******************/
/************************************************************************/