/*
 * WPSrestore.cmd 0.1 (c) 2005 Yuri Dario <mc6530@mclink.it> 
 *
 * Restore WPS module
 *
*/

 	say 'WPSrestore.cmd 0.1 (c) 2005 Yuri Dario <mc6530@mclink.it>' 
 
	/* force loading dll from current directory, also if wptool.dll is
	   already in memory (e.g. older version) */
	parse source os call arg0
	'@SET LIBPATHSTRICT=T'
	'@SET BEGINLIBPATH='filespec("drive",arg0)''filespec("path",arg0)';%BEGINLIBPATH%'

	call RxFuncAdd 'WPToolsLoadFuncs', 'WPTOOLS', 'WPToolsLoadFuncs'
	call WPToolsLoadFuncs

	call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
	call SysLoadFuncs
	
	/* check version */
	Version = WPToolsVersion();
	if Version<"2.13" then do
		say 'Current WPTOOL.DLL version is not correct.'
		say 'Version' Version 'found, but required at least 2.13'
		exit 1
	end

	parse arg opt mode
	if opt = "" then do
		say 'Usage: WPSrestore -1|-s [-u|-r|-f]'
		say '-1|-s: restore only this folder or recurse into subdirectories.'
		say '[-u|-r|-f]: action for existing objects Update (default),Replace,Fail.'
		exit 1
	end
	
	
	recurse = 0
	option = 'u' /* Fail Replace Update*/
	if opt = '-s' then recurse = 1
	if mode = '-u' then option = 'u'
	if mode = '-r' then option = 'r'
	if mode = '-f' then option = 'f'
	
	log_file = 'restore.log'
	call lineout log_file, 'Restoring current folder.'
	call RestoreFolder
	
	if recurse = 1 then do
		/* get directory tree */
		call SysFileTree '*', 'dir', 'DSO'
	
		do i = 1 to dir.0
			name = substr( dir.i, length(source)+2)
			call lineout log_file, 'Restoring folder: 'dir.i
			/* change to directory */
			rc = directory( dir.i)
			/* restore data */
			call RestoreFolder
		end
	end

	/* program exit */
	exit 0


/*
 * RestoreFolder
 * Reads folder.obj in the current directory and restores objects.
 *
 * param:
 * 		none
*/	
RestoreFolder:

	do while lines( 'folder.obj')
		object = linein( 'folder.obj')
		parse value object with text id 
		if \(text = 'OBJECT') then do
			say 'parse error:' object
			call lineout log_file, 'Parsing error for object: 'object
			exit 1
		end
		class = strip( linein( 'folder.obj'))
		title = strip( linein( 'folder.obj'))
		if title = "" then
			title = "?" /* rexx api does not accept empty titles! */
		setupstring = strip( linein( 'folder.obj'))
		location = strip( linein( 'folder.obj'))
		/*parse value object with id ',' class ',' title ',' setupstring ',' location*/
		/* say id location*/
		rc = SysCreateObject( class, title, location ,setupstring, option) 
		if rc = 0 then do
			call lineout log_file, 'CreateObject failed for 'id
			call lineout log_file, '             class: 'class
			call lineout log_file, '             location: 'location
			call lineout log_file, '             setup: 'setupstring
		end
	end
	/* close file */
	rc = lineout( 'folder.obj')
	
	return

