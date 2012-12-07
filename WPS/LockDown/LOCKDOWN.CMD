/********************************************************************
                                                         LOCKDOWN.CMD
                                                         Version 1.03

                                                      28 January 1998

                                                  by Kathleen L. Long
                                                        k2lan@aol.com


 REXX script to change folders and icons with known objectid's to
   prevent deleting, copying, moving, renaming, shadowing or changing
   of their settings.  

 When the variable switch is set to "YES", settings for NODELETE, 
   NOCOPY, NOMOVE, NORENAME, NOSETTINGS, NOSHADOW will be set to
   YES, which will remove the options for DELETE, COPY, MOVE, 
   RENAME, SETTING and SHADOW, respectively, from the icon's 
   popup window. 

 Changing the variable switch to "NO" will do just the opposite, 
   returning these options to icons from which they are missing.

 The script will alter ALL objectid's listed in the companion file,
   LOCKDOWN.DAT.  Edit the file accordnig to your needs, leaving
   only one objectid per line.  (A file LOCKDOWN.BAK has been
   provided that contains some 300 known object id's, for OS/2 and
   other common OS/2 applications.)

********************************************************************/

   call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
   call SysLoadFuncs

   switch="YES"

   do while lines(lockdown.dat) > 0
      object = strip(linein(lockdown.dat))
      call Lock
   end /* do */

RETURN

Lock:
   say Object
   if SysSetObjectData(object,"NODELETE="||switch) Then Say object 'settings have been updated to NODELETE = '||switch
   if SysSetObjectData(object,"NOCOPY="||switch) Then Say object 'settings have been updated to NOCOPY = '||switch
   if SysSetObjectData(object,"NOMOVE="||switch) Then Say object 'settings have been updated to NOMOVE = '||switch
   if SysSetObjectData(object,"NORENAME="||switch) Then Say object 'settings have been updated to NORENAME = '||switch
   if SysSetObjectData(object,"NOSETTINGS="||switch) Then Say object 'settings have been updated to NOSETTINGS = '||switch
   if SysSetObjectData(object,"NOSHADOW="||switch) Then Say object 'settings have been updated to NOSHADOW = '||switch
   call SysSleep 1 /* pause for legibility */
   say
return

