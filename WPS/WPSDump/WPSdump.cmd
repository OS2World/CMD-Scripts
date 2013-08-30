/*
 * WPSdump.cmd 0.1 (c) 2005 Yuri Dario <mc6530@mclink.it> 
 *
 * Backup WPS module
 *
*/

 	say 'WPSdump.cmd 0.1 (c) 2005 Yuri Dario <mc6530@mclink.it>' 
 
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

	/* parse command line */	
	parse arg source ' ' target

	if source = "" then do
		say 'Usage: WPDUMP source target_dir'
		say 'targer_dir must be a full path to allow proper icon restore.'
		exit 1
	end
	if target = "" then do
		say 'Usage: WPDUMP source target_dir'
		say 'targer_dir must be a full path to allow icon restore.'
		exit 1
	end	

	/* dump this folder */
	log_file = target'\backup.log'
	call SysMkDir(target)
	/* target must end with '\' */
	target = target'\'
	call DumpFolder source, target

	/* get directory tree */
	call SysFileTree source'\*', 'dir', 'DSO'

	do i = 1 to dir.0
		name = substr( dir.i, length(source)+2)
		call lineout log_file, 'Dumping folder:'name
		call SysMkDir(target''name)
		call DumpFolder dir.i, target''name'\'
	end

	/* copy restore module to target dir */
	'@copy WPSDump.txt 'target'WPSDump.txt > nul'
	'@copy WPSRestore.cmd 'target'WPSRestore.cmd > nul'
	'@copy wptools.dll 'target'wptools.dll > nul'
	'@copy wptools.txt 'target'wptools.txt > nul'

	/* program exit */
	exit 0

	
/*
 * DumpFolder
 * Dumps folder, object, file system objects setup strings
 *
 * param:
 *	arg(1)	object id or path
 *  arg(2)  target folder
*/	
DumpFolder:

	dump_file = arg(2)'folder.obj'
	class_file = arg(2)'folder.cla'
	call SysFileDelete(dump_file)
	call SysFileDelete(class_file)

	/* dump folder setup string */
	call DumpObject arg(1), arg(2), dump_file, 0 
	
	/* get folder abstract objects */
	rc = WPToolsFolderContent( arg(1), "list.")
	if rc = 0 Then Do
		call lineout log_file, 'ERROR: cannot query folder "'arg(1)'"'
		return 
	End
	do j = 1 to list.0
		call DumpObject list.j, arg(2), dump_file, 1
	end
	/* get folder file systems (not directories) objects */
	call SysFileTree arg(1)'\*', 'fs', 'FO'

	do j = 1 to fs.0
		call DumpObject fs.j, arg(2), dump_file, 1
	end

	/* close file */
	rc = lineout( dump_file)
	
	return

/*
 * DumpObject
 * Dumps object setup string, extracts abstract or folder icons.
 *
 * param:
 *	arg(1)	object id or path
 *  arg(2)  target folder
 *  arg(3)  target file for dump
 *  arg(4)  1 to extract abstract icon (usually 0==folder)
*/	
DumpObject:

	rc = WPToolsQueryObject(arg(1), "szclass", "sztitle", "szsetupstring", "szlocation")
	if rc = 0 Then do
		call lineout log_file, 'QueryObject failed for: 'arg(1)
		return
	end

	/* get hex id */		
	rc = WPToolsQueryObjectId(arg(1), "hexid");
	/* get obj id (if exists) */
	objectid = pos( 'OBJECTID=', szSetupString) 
	if  objectid > 0 then do
		comma = pos( ';', szSetupString, objectid)
		obj_id = substr( szSetupString, objectid+9, comma - 9 - objectid) 
	end 
	else do
		obj_id = '<WP_OBJID_'hexid'>'
		szsetupstring = szsetupstring'OBJECTID='obj_id';'
	end
	
	/* if title is empty, this could be a filesystem object, so use the file name; */
	/* otherwise use object id */
	if sztitle = "" then do
		if left(arg(1),1) = "<" then
			sztitle = obj_id
		else
			sztitle = filespec("name",arg(1)) /* file system, use name */
	end

	/* dump folder icons */
	foldericon = 0
	if arg(4) = 0 then do
		if SysGetEA( arg(1), ".ICON", "icon") = 0 then do
			if length(icon)>0 then do
				call WriteIcon arg(2)'icon.ico', substr(icon,5)
				szsetupstring = szsetupstring'ICONFILE='filespec("path",arg(2))'icon.ico;'
				foldericon = 1 /* set icon flag */
			end
		end
		if SysGetEA( arg(1), ".ICON1", "icon") = 0 then do
			if length(icon)>0 then do
				call WriteIcon arg(2)'icon1.ico', substr(icon,5)
				szsetupstring = szsetupstring'ICONNFILE=1,'filespec("path",arg(2))'icon1.ico;'
			end
		end
	end

	/* query abstract icon only if folder icon does not exist.
	   Discovered some folders with both icons set (and abstract one
	   is not necessary */
	if arg(4) = 1 & foldericon = 0 then do
		icon = SysIni( "USER", "PM_Abstract:Icons", hexid)
		if \(icon = 'ERROR:') then do
			iconfile = arg(2)'ico-'hexid'.ico'
			call WriteIcon iconfile, icon
			szsetupstring = szsetupstring'ICONFILE='filespec("path",arg(2))'ico-'hexid'.ico;'
		end
	end

	/* dump to file */
	call lineout arg(3), 'OBJECT 'obj_id
	call lineout arg(3), '   'szClass
	call lineout arg(3), '   'szTitle
	call lineout arg(3), '   'szSetupString
	call lineout arg(3), '   'szLocation

	return

/*
 * WriteIcon
 * Writes binary data to disk (icon files)
 *
 * param:
 *	arg(1)	target file (will be deleted)
 *  arg(2)  icon binary data
*/	
WriteIcon:

	call SysFileDelete(arg(1))
	call charout arg(1), arg(2)
	/* close file */
	rc = lineout( arg(1))
	return

