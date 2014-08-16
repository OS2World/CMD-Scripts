/* ================================================================ */
/* OPENFDR.CMD v.1.4 - by M. Woo, Champaign-Urbana OS/2 Users Group */
/* -- choose a folder to open from a popup list under 4OS2.         */
/* Requires OS/2 (R) REXX, J.P. Software Inc.'s 4OS2 (TM).          */
/*                                                                  */
/* My contact addresses through Dec, 1993 (I don't know where I'll  */
/* be after then) are: Internet: m-woo@uiuc.edu, Fidonet: 1:233/4.0 */
/*                                                                  */
/* NOTE: if your desktop doesn't reside on the C: drive, or you are */
/* using OS/2 v2.0, you will have to modify this script where       */
/* indicated to reflect your actual desktop's subdirectory.         */
/*                                                                  */
/* The user assumes responsibility for any damage caused by this    */
/* program.  There is no warranty, and the program is guaranteed    */
/* only to waste space on your hard drive.                          */
/* ================================================================ */

/* Loads the external REXXUtil functions.         */

call RxFuncAdd "SysLoadFuncs", "REXXutil", "SysLoadFuncs"
call SysLoadFuncs
'@echo off'

/* ============================================== */
/* If your desktop is somewhere OTHER than        */
/* c:\desktop\, you'll have to make changes to    */
/* the script to point to your desktop.           */
/* Note: the desktop name under OS/2 2.0 is of    */
/* the format <drive>:\OS!2 2.0 DESKTOP\, and     */
/* a FAT drive will have <drive>:\OS!2 2.0 D\     */
/* ============================================== */

/* Creates an array of all the subdirectories     */
/* below "desktop" (recursively).                 */

call SysFileTree "c:\desktop\*", "dirs.", "DSO" 

/* Creates an array of folder names by reading    */
/* the subdirectory array and truncating them     */
/* after the final backslash.                     */

do i=1 to dirs.0 
	lastslash=lastpos("\", dirs.i) 
	dirname.i=delstr(dirs.i, 1, lastslash)
	name=dirname.i
	call lineout folder,name
end /* folder name loop */

/* ============================================== */
/* This section closes the newly-created text     */
/* file, sorts it alphabetically, then runs the   */
/* 4OS/2 variable function %@select on the text   */
/* file to create the popup menu.                 */
/* ============================================== */

/* Closes the text file called "folder," then     */
/* sorts the output into a new file called        */
/* "folder.txt"                                   */

	call lineout folder
	'sort < folder > folder.txt' 

/* Directs the user's selection into a file named */
/* "choice," and pipes any error messages to nul. */

	'echos %@select[folder.txt,1,1,15,30,Folder] 1>choice 2>nul' 

/* Assigns the text in "choice" to the variable   */
/* "answer" and closes "choice."                  */

	answer=linein(choice)
	call lineout choice

/* In case the user presses Esc to cancel the     */
/* popup menu, this if-then-do loop will catch    */
/* it and exit the script, after cleaning up.     */

	if answer='' then 
		do
		'del folder.txt folder choice /q /f' 
		exit
		end /* of answer loop */

/* ============================================== */
/* This section reads the array of your           */
/* folder names.  When the user's choice is the   */
/* same as the folder name, the correct folder    */
/* will be opened.                                */
/* ============================================== */

	do k=1 to dirs.0 until (answer=dirname.k)
		thedir=dirs.k
	end /* do k loop */

/* open correct folder, specified by "thedir"     */ 

	call SysSetObjectData thedir, "OPEN=DEFAULT"; 

/* The cleanup of those messy little files that   */
/* were created by this program.                  */

	'del folder.txt folder choice /q /f' 
exit
