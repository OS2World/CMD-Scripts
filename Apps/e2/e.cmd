/*****************************************************************************/
/* Intelligent E                             (c) 1993 by Carsten Wimmer      */
/* For use with Rexx/2                                   cawim@train.fido.de */
/* Modified 2002 by David Mediavilla <davidme * bigfootNO.SPAMcom> */
/*****************************************************************************/
/* This is a small rexx script that blows some intelligence into the         */
/* system editor of OS/2. I always hated E for asking me to associate        */
/* a file type. This script takes care of the file type and prevents E       */
/* from asking anymore.                                                      */
/* Send suggestions and bug-reports to my email address.                     */
/*****************************************************************************/

signal on novalue name errorHandling
/* Load the system functions */
Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

/* Get the filename from the command-line and convert it to upper case */
parse upper arg file
parse arg filePreservingCase

if( ''ª= file) then do
	if( ''ª= stream( file, 'c', 'query exists')) then do
	/* The file exists */
		/* Save the extension for later reference (only if there is one!) */
		dotPosition= lastpos( '.', file)
		if 0== dotPosition then ext= ''
		else
			if dotPosition > lastpos( '\', file) then,
				parse upper value substr( file, dotPosition),
				/* This includes the dot in the extension */ with ext
			else ext=''

		/* If there is already an associated file type, skip the rest */
		/* There will be an error trying to get the EA from a filesystem
		    with no EAs */
		call SysGetEA file, ".TYPE", "typeinfo" 
		if 0== result then do
			parse var typeinfo 11 oldtype
			if oldtype == "" then do
				/* Set file type according to the extension */
				select
					when ".CMD"== ext then
						newtype = "OS/2 Command File"
					when ".BAT"== ext then
						newtype = "DOS Command File"
					when ".HTML"== ext | ".HTM"== ext then
						newtype = "HTML"
					when ".C"== ext | ".CPP"== ext | ".H"== ext then
						newtype = "C Code"
					when ".JAVA"== ext then
						newtype = "Java Code"
					otherwise
						newtype = "Plain Text"
				end	/* select */

				/* Create EA data */
				  EAdata = 'DFFF00000100FDFF'x || d2c(length(newtype)) ,
				  	|| '00'x || newtype
				/* Write EA data to the file */
				  call SysPutEA file, ".TYPE", EAdata			
			end	/* oldtype== "" */ 
		end	/* No error when Getting the EA */
	end	/* The file exists*/

	/* Finally, start E */
	/* Even with /f, E doesn't come to the foreground. Strange */
	/* strip removes the " and " inserted automatically when the filename has blanks */
	'start "E - ' strip( filePreservingCase, , '"' ) '" /f e.exe' filePreservingCase
	end	/* There are parameters */
else do	/* No parameters */
	'start "E" /f e.exe'
     end	/* No parameters */
exit rc	

errorHandling:
   call LineOut 'STDERR:', 'Error "' condition( 'condition') '" happened'
   call LineOut 'STDERR:', 'Error processing "' condition('description') '"'
   call LineOut 'STDERR:', 'Line ' sigl
   call LineOut 'STDERR:', 'RC= ' rc
   call LineOut 'STDERR:', 'RESULT= ' result
exit
 
 
   

