/*rexx*/
/* Copyright 1994 John H. Lederer                CIS:  74020,210
Unlimited permission to use or modify is granted you so long as you agree
to make improvements of general applicability available to the public
by posting changed code on public BBS' or forums. */
/*program checks the ini files in  the directory c:\os2 for changes
by comparing ini.lst with a dir *.ini.  If there are changes it makes
a several level backup. "*.tmp" is a copy of the current .ini file.
"*.bak" is a backup copy of the prior ini file and *.bk2 is the prior
ini file to that. */

/*==========================================================main control block*/
/* main control block--- shows program logic */
call initialize
call getlists               /* get a new and old directory listing */
 
do x=6 to c-2               /* just the lines of directory having file listings*/
   call checkchanges        /* see if there are differences */
   if  changes then do      /* if there are then call a backup routine*/
      if oldini then
         call oldinibackup  /* backs up an exisiting, but changed file*/
      else
         call newinibackup  /* backs up a new file*/
   end
 
end
 
call printmessage          /* gives the user a screen saying waht was done*/ 
exit
/*=========================================================initialize*/
 
initialize:
 
   /* initialize */
   dirlist = "C:/OS2/INI.LST"
   filelist.=""
   c=0
   ct =0
   changes =0
return
/*=========================================================getlists*/ 
 
getlists:
 
   /* read in  old list */
   filelist = charin(dirlist,1,99999)
   ok = stream(dirlist,"C","CLOSE")
   /* make new ini.list */
   cmd ="DIR C:\OS2\*.INI > C:\OS2\INI.LST"
   cmd
   say "[BACKINI.CMD]: Wrote new ini.lst file."
   /* read in new list*/
 
   do until lines(dirlist) = 0
      c = c+1
      newlist.c= linein(dirlist)
   end
 
 
return

/*=========================================================checkchanges*/ 

/* see if need to do a backup */
 
checkchanges:
/*   sets flags, changes =1 if the directory listing for the file is different
     or nonexistent.  Oldini = 1 if it exists but is different.*/
 
   root = strip(word(newlist.x,1))
   /* see if the new directory line is in the old directory list */
  if  pos(newlist.x,filelist) > 0 then
      changes = 0  
   else do
      changes = 1
      oldini = 0
      if pos(root,filelist) > 0 then oldini = 1
   end
 
 
return
 
/*=========================================================oldinibackup*/
 
oldinibackup:
 
   /* file is a previously existing ini file that has changed */
   say "[BACKINI.CMD]: Backup of "root".ini file changes initiated"
   cmd = "ERASE "ROOT".BK2"
   cmd
   cmd = "RENAME "root".BAK *.BK2"
   cmd
   cmd = "RENAME "root".CUR *.BAK"
   cmd
   cmd = "COPY "root".INI  *.CUR"
   cmd
   ct = ct +1
   msg.ct = "Created backup of changes in "root".ini file"
 
return
 
/*=========================================================newinibackup*/ 
newinibackup:
 
   /* file is a new ini file */
   say  "[BACKINI.CMD]:    " root".INI is a new ini file, initial backups initiated"
   cmd = "COPY "||root||".INI  *.CUR"
   cmd
   cmd = "COPY "||root||".CUR *.BAK"
   cmd
   cmd = "COPY "||root||".BAK  *.BK2"
   cmd
   ct = ct +1
   msg.ct = "Created initial backups of "root".ini file"
 
return
 
/*=========================================================printmessage*/ 
printmessage:
   say " "
   say " "
   say "=========================Backini Actions ===================="
   ok = stream(dirlist,"C","CLOSE")
   if ct = 0  then
       say "No changes detected"
  
else
   do x = 1 to ct
      say msg.x
   end

   say "=========================Backini Completed===================="
   /* pause for 5 seconds to allow reading message */
if ct > 0 then do 
   x=time('E')
 
   do until (time('E') - x) > 5
      nop
   end
end
return
 
