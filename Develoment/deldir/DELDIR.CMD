/***********************************************************************/
/*DELDIR - starts at the current directory and deletes all files and   */
/*subdirectories in the target, then it deletes the target directory.  */
/*                                                                     */
/*This program supports HPFS long file names.  Simply type in the      */
/*long directory name without quotes. For example this command:        */
/*           DELDIR os!2 2.0 desktop                                   */
/*will delete the desktop directory structure.                         */
/*                                                                     */
/*                                                                     */
/* Written by Mark Polly - Progressive Insurance.                      */
/*            July 2, 1992                                             */
/*                                                                     */
/***********************************************************************/

ARG user_dir
IF STRIP(user_dir,'B') = '' THEN
	DO 
             SAY 'You must enter a directory name to erase.'
             SAY 'To erase the current directory and all the ones below'
	     SAY 'it, use a period (.).'
             EXIT 3
	END

/***********************************************************************/
/* Load the OS/2 2.0 RexxUtil DLL and make some functions available    */
/***********************************************************************/

CALL RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
CALL RxFuncAdd 'SysFileDelete', 'RexxUtil', 'SysFileDelete'
CALL RxFuncAdd 'SysRmDir', 'RexxUtil', 'SysRmDir'

/***********************************************************************/
/* Load text strings for SysFileDel and SysRmDir return codes.         */
/***********************************************************************/

CALL LoadDELRCText   /* provides text strings for SysFileDel return codes */
CALL LoadRDRCText    /* provides text strings for SysRmDir return codes   */

/**************************************************************************/
/*Check to make sure the directory exists - if it does prompt the user to */
/*make sure they really want to do this.   Otherwise issue a message and  */
/*exit                							  */
/**************************************************************************/

rc=SysFileTree(user_dir,dir_list, 'D')
IF dir_list.0 = 0  THEN
        DO
             SAY user_dir 'not found, try again.'
             EXIT 1
        END

DROP dir_list.

/***********************************************************/
/* Make sure the user really wants to do this              */
/***********************************************************/

SAY 'Are you sure? (Y/N)'
PULL answer .
IF LEFT(answer,1,1) <> 'Y' THEN EXIT 1

/***********************************************************/
/* Mark all the read-only files to be non read-only        */
/***********************************************************/

rc=SysFileTree(user_dir, dir_list, 'BO', '****','----')

DROP dir_list.

/***********************************************************/
/* Go through the list of files and delete each one        */
/***********************************************************/

rc=SysFileTree(user_dir || '\*.*', dir_list, 'FSO')
DO x = 1 TO dir_list.0
	rc = SysFileDelete(dir_list.x)
	SAY dir_list.x '........' DELRCText.RC
END

DROP dir_list.

/*************************************************************/
/* Go through all the subdirectories and remove them.        */
/* We go backwards through the list in order to delete the   */
/* lowest level sudirectories first and work our way back up */
/* the tree.                                                 */
/*************************************************************/

rc=SysFileTree(user_dir || '\*.*', dir_list, 'DSO')
DO x = dir_list.0 TO 1 BY -1
	rc=SysRmDir(dir_list.x)
	SAY dir_list.x '........' RDRCText.RC
END

DROP dir_list.

/**************************************************************/
/* Delete the directory the user passed  		      */
/**************************************************************/

rc=SysRmDir(user_dir)
SAY user_dir '........' RDRCText.RC

EXIT 0


/**************************************/
/* Local subroutines		      */
/**************************************/

LoadDELRCText:
	/* provides text strings for SysFileDel return codes */
	/* The return codes and strings are in the online Rexx manual */

	DELRCText.0 = 'File deleted successfully. '
	DELRCText.2 = 'Error.  File not found. '
	DELRCText.3 = 'Error.  Path not found. '
	DELRCText.5 = 'Error.  Access denied. '
	DELRCText.26 = 'Error.  Not DOS disk. '
	DELRCText.32 = 'Error.  Sharing violation. '
	DELRCText.36 = 'Error.  Sharing buffer exceeded. '
	DELRCText.87 = 'Error.  Invalid parameter. '
	DELRCText.206 = 'Error.  Filename exceeds range error. '
RETURN

LoadRDRCText:
	/* provides text strings for SysRmDir return codes */
	/* The return codes and strings are in the online Rexx manual */

	RDRCText.0 = 'Directory removal was successful. '
	RDRCText.2 = 'Error.  File not found. '
	RDRCText.3 = 'Error.  Path not found. '
	RDRCText.5 = 'Error.  Access denied. '
	RDRCText.16 = 'Error.  Current Directory. '
	RDRCText.26 = 'Error.  Not DOS disk. '
	RDRCText.87 = 'Error.  Invalid parameter. '
	RDRCText.108 = 'Error.  Drive locked. '
	RDRCText.206 = 'Error.  Filename exceeds range error. '
RETURN
 

