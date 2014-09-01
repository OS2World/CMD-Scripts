/* REXX procedure than removes the REXX Extended Atributes from the CMD */
/* and ERX files (REXX macros for EPM).                                 */

/* Program by Salvador Parra Camacho                                    */
/* Started: 18/05/2002 (version 1.0)                                    */
/* Please, don't touch the four following lines.                        */

program_version='1.1'
program_date='18/09/2002'
program_website='Not available.'
programmer_email='x3265340@fedro.ugr.es'

/* Install the error handler for Ctrl+C.                                */

signal on halt name stop

/* Program name and description.                                        */

say ''
say '  rmrxea: removes REXX EAs from a set of CMD and ERX files.'

/* Register and load the RexxUtil functions: rexxutil.dll.              */

if RxFuncQuery('SysLoadFuncs') <> 0 then do
	rc = RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs')
	if rc <> 0 then do
	say ''
	say '  Error registering rexxutil.dll functions (required by rmrxea).'
	exit
	end
	end
else
	rc = SysLoadFuncs()
	if rc = 1 then do
	say ''
	say '  Error loading rexxutil.dll (required by rmrxea).'
	exit
	end

/* Read the options from the parameters.                                */

parse arg option directory

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
		call rmrxea_proc
		end
	when option = '-n' then do
		o = 'FO'
		call rmrxea_proc
		end
	otherwise
		say '  Incorrect parameters.'
		call _syntax
end
exit

/*********************** End of the main program ************************/
/************************************************************************/
/****************** Beginning of the program procedures *****************/

rmrxea_proc:
if directory = '' then directory = directory()
rc = SysFileTree(directory||'\*.cmd', cmd, o)
rc = SysFileTree(directory||'\*.erx', erx, o)
do i=1 to cmd.0
	say '  Deleting REXX EAs from '||cmd.i
	call SysPutEA cmd.i, REXX.LITERALPOOL, ''
	call SysPutEA cmd.i, REXX.METACONTROL, ''
	call SysPutEA cmd.i, REXX.TOKENSIMAGE, ''
	call SysPutEA cmd.i, REXX.VARIABLEBUF, ''
	call SysPutEA cmd.i, REXX.PROGRAMDATA, ''
	call SysPutEA cmd.i, .CLASSINFO, ''
	call SysPutEA cmd.i, .TYPE, ''
end
do i=1 to erx.0
	say '  Deleting REXX EAs from '||erx.i
	call SysPutEA erx.i, REXX.LITERALPOOL, ''
	call SysPutEA erx.i, REXX.METACONTROL, ''
	call SysPutEA erx.i, REXX.TOKENSIMAGE, ''
	call SysPutEA erx.i, REXX.VARIABLEBUF, ''
	call SysPutEA cmd.i, REXX.PROGRAMDATA, ''
	call SysPutEA erx.i, .CLASSINFO, ''
	call SysPutEA erx.i, .TYPE, ''
end
return

/* The following procedure shows the syntax.                            */

_syntax:
say ''
say '  Correct syntax:'
say '  rmrxea.cmd [option] [directory]; where [option] can be one of the'
say '  following:'
say '    -h: shows this help.'
say '    -v: shows the version info.'
say '    -r [directory]: remove REXX EAs from the CMDs and ERXs located'
say '    in [directory] and all subdirectories.'
say '    -n [directory]: remove REXX EAs from the CMDs and ERXs located'
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