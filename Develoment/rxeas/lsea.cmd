/* REXX procedure than lists EAs of a set of files                      */

/* Program by Salvador Parra Camacho                                    */
/* Started: 04/10/2002 (version 1.0)                                    */
/* Please, don't touch the four following lines.                        */

program_version='1.0'
program_date='04/10/2002'
program_website='Not available.'
programmer_email='x3265340@fedro.ugr.es'

/* Install the error handler for Ctrl+C.                                */

signal on halt name stop

/* Program name and description.                                        */

say ''
say '  lsea: lists EAs of a set of files.'


/* Register and load the RexxUtil functions: rexxutil.dll.              */

if RxFuncQuery('SysLoadFuncs') <> 0 then do
	rc = RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs')
	if rc <> 0 then do
	say ''
	say '  Error registering rexxutil.dll functions (required by lsea).'
	exit
	end
	end
else
	rc = SysLoadFuncs()
	if rc = 1 then do
	say ''
	say '  Error loading rexxutil.dll (required by lsea).'
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
		call lsea_proc
		end
	when option = '-n' then do
		o = 'FO'
		call lsea_proc
		end
	otherwise
		say '  Incorrect parameters.'
		call _syntax
end
exit

/*********************** End of the main program ************************/
/************************************************************************/
/****************** Beginning of the program procedures *****************/

lsea_proc:
if directory = '' then directory = directory()
rc = SysFileTree(directory||'\*', filesystemobject, o)

say ''
say '  Listing...'
say ''

do i=1 to filesystemobject.0
	say '  'filesystemobject.i
	rc = SysQueryEAList(filesystemobject.i, 'ealist.')
	
	do j = 1 to ealist.0
		say '    'ealist.j
	end
end
return

/* The following procedure shows the syntax.                            */

_syntax:
say ''
say '  Correct syntax:'
say '  lsea.cmd [option] [directory]; where [option] can be one of the'
say '  following:'
say '    -h: shows this help.'
say '    -v: shows the version info.'
say '    -r [directory]: shows the EAs of the files and subdirectories located'
say '    in [directory] and all subdirectories.'
say '    -n [directory]: shows the EAs of the files and subdirectories located'
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