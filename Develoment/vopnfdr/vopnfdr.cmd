/* ================================================================ */
/* VOPNFDR.CMD v1.3 by M. Woo, Champaign-Urbana OS/2 Users Group    */
/* -- choose a folder to open from a PM listbox.                    */
/* Requires OS/2 (R) REXX and the IBM EWS package, VREXX (by        */
/* Richard B. Lam)                                                  */
/*                                                                  */
/* NOTE: if your desktop doesn't reside on the C: drive, or you are */
/* using OS/2 v2.0, you will have to modify this script where       */
/* indicated to reflect your actual desktop's subdirectory.         */
/*                                                                  */
/* The user assumes responsibility for any damage caused by this    */
/* program.  There is no warranty, and the program is guaranteed    */
/* only to waste space on your hard drive.                          */
/* ================================================================ */

/* Load the external REXXUtil functions and VREXX */
/* Include VREXX error-checking                   */
call RxFuncAdd "SysLoadFuncs", "REXXutil", "SysLoadFuncs"
call RxFuncAdd 'VInit', 'VREXX', 'VINIT' 
call SysLoadFuncs

signal on failure name CLEANUP 
signal on halt name CLEANUP
signal on error name CLEANUP
signal on syntax name CLEANUP

if RxFuncQuery(VInit)<>1 then
   if VInit()=="ERROR" then signal CLEANUP 

/* ============================================== */
/* Create subdirectory array.  If your desktop's  */
/* directory doesn't reside on the C: drive,      */
/* and/or you are using OS/2 2.0, you will need   */
/* to modify the script here.                     */
/* Note: the desktop under OS/2 2.0 is of the     */
/* format: <drive>:\OS!2 2.0 DESKTOP\             */
/* FAT drives: <drive>:\OS!2 2.0 D\               */
/* ============================================== */
call SysFileTree "c:\desktop\*", "dirs.", "DSO" 

/* ============================================== */
/* Get folder names by reading subdir array and   */
/* truncating after the last backslash, then call */
/* Jack S. Tan's add and sort routines.           */
/* ============================================== */
do i=1 to dirs.0 
	lastslash=lastpos("\", dirs.i) 
	dirname.i=delstr(dirs.i, 1, lastslash)
	call add list, dirname.i 
end /* folder name loop */

call sort list 

/* ============================================== */
/* Draw dialog listbox and keep it onscreen until */
/* the user hits "cancel."                        */
/*                                                */
/* Search the folder name array until the user's  */
/* choice matches, then open the corresponding    */
/* folder.                                        */
/* ============================================== */

call VDialogPos 0,90 

do forever 
	result= VListBox('Choose a folder to open', list, 22, 4, 3) 
	if result = 'CANCEL'
		then signal CLEANUP 
		else
		selection_string=list.vstring 

	do k=1 to dirs.0 until (selection_string=dirname.k) = 1
		thedir=dirs.k
	end /* do k loop */

	call SysSetObjectData thedir, "OPEN=DEFAULT"; 
	call SysSetObjectData thedir, "OPEN=DEFAULT"; 

end /* do forever loop */

CLEANUP:
	call Vexit
exit

/* ============================================== */
/* Jack S. Tan's add routine to add objects to an */
/* array more conveniently. The syntax is:        */
/* "call add <stem>, <item>"                      */
/* ============================================== */
add:
   exposeList = arg(1)||"."
   call internalAdd arg(1) arg(2)
return

internalAdd: procedure expose (exposeList)
   parse arg stem newVal
   n = value(value(stem).0)
   if DATATYPE(n)<>"NUM" then
      n = 0
    n = n + 1
   interpret value(stem)".0 = " n
   interpret value(stem)"."n "= '"newVal"'"
return

/* ============================================== */
/* Jack S. Tan's sort routine.  The syntax is     */ 
/* "call sort <stem>"                             */
/* Uses output of the above "add" routine         */
/* ============================================== */
sort:
   exposeList = arg(1)||"."
   call internalSort arg(1)
return

internalSort: procedure expose (exposeList)
   parse arg stem
   n = value(value(stem).0)
   do j=2 to n
      key = value(value(stem).j)
      i = j-1
      do while (i>0) & (value(value(stem).i)>key)
         interpret value(stem)"."i+1 "= '"value(value(stem).i)"'"
         i = i-1
      end /* do */
      interpret value(stem)"."i+1 "= '"key"'"
   end /* do */
return
