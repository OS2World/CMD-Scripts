/* REXX procedure than removes the Extended Atributes from a set of     */
/* files.                                                               */

/* Program by Salvador Parra Camacho                                    */
/* Started: 05/10/2002 (version 1.0)                                    */
/* Please, don't touch the four following lines.                        */

program_version='1.0'
program_date='05/10/2002'
program_website='Not available.'
programmer_email='x3265340@fedro.ugr.es'

/* Install the error handler for Ctrl+C.                                */

signal on halt name stop

/* Program name and description.                                        */

say ''
say '  rmea: removes EAs from a set of files.'

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

parse arg option _filespec _ea

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
		call rmea_proc
		end
	when option = '-n' then do
		o = 'FO'
		call rmea_proc
		end
	otherwise
		say '  Incorrect parameters.'
		call _syntax
end
exit

/*********************** End of the main program ************************/
/************************************************************************/
/****************** Beginning of the program procedures *****************/

rmea_proc:
if _filespec = '' then
	do
	say '  You must specify a rule to select the files.'
	call _syntax
	end

rc = SysFileTree(_filespec, _files, o)

if _ea = '' then
	do
	say '  You must specify a EA to delete.'
	call _syntax
	end

do i=1 to _files.0
	say '  Removing '||_ea||' from '||_files.i
	call SysPutEA _files.i, _ea, ''
end
return

/* The following procedure shows the syntax.                            */

_syntax:
say ''
say '  Correct syntax:'
say '  rmea.cmd [option] [filespec] [ea]; where [option] can be one of the'
say '  following:'
say '    -h: shows this help.'
say '    -v: shows the version info.'
say '    -r [filespec] [ea]: remove [ea] EA from files with [filespec] located'
say '    in current directory and all subdirectories.'
say '    -n [filespec] [ea]: remove [ea] EA from files with [filespec] located'
say '    in current.'
exit

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