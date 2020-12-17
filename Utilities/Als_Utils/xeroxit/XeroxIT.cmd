/* sort of like a xcopy command, but will copy only missing files
   or optionally where the 'datestamp' (date, time, size) has changed.
   Also, subsequent lower level subdirectories can be copied too with '/s'

   Options:  /s  for include subdirectories
             /d  to compare date, time, and size
             /v  for verbose options  (/v2 is even more verbose)
             /h  to include hidden and system files too
             /l- to disable .LONGNAME attribute support on the destination
                 (Note, this can improve performance of this Rexx script
                        if the attribute checks are not needed.)
             /lst fn  means 'fn' is a file containing the list of source files.
                       (fn typically generated from 'DriveDir.cmd'

   Examples:
       xeroxit x: /s    will copy from the current directory on x: and subdirs
*/

/* remember where we presently are */
here = directory()

/* use our name as a base for an 'errors' file in the current directory */
parse source . . pgm .
exname = filespec('name',pgm)
ldot = lastpos('.',exname)
if ldot < 2 then ldot = length(exname) + 1
exbase = left(exname,ldot-1)
if right(here,1) \= '\'
   then errors = here||'\'||exbase||'.err'
   else errors = here||exbase||'.err'
parse arg args '(' recursion_level dest_is8.3 .

if args = '' then do
   say 'using' pgm
   say 'Function:  Makes a copy of missing (or changed files)'
   say '           Files copied might NOT retain the "read only" attribute'
   say ''
   say 'Syntax' exbase 'source_mask <dest> </s> </d> </v> </v2> </h> </l-> </erase>'
   say '  where <dest> defaults to the current directory'
   say '    Options: /s for include subdirectories'
   say '             /d to compare date, time, and size'
   say '                  allows copying of changed files that already exist'
   say '             /v for verbose options  (/v2 is even more verbose)'
   say '             /h to include hidden and system files too'
   say '             /l- to totally disable using long file names on the destination'
   say '                By default, the longfile name will be preserved'
   say '                   under the .LONGNAME EA on FAT file systems.'
   say '                Using /l- can greatly improve performance of this Rexx script'
   say '                   when the .LONGNAME processing is not needed.'
   say "             /erase will erase existing destination files and subdirectories "
   say '                that do not have a correspondence to the source.'
   say '                Use /erase- to erase extraneous files in subdirectories'
   say '                   BUT preserve extraneous files in the top subdirectory.'
   exit 100
end

if recursion_level = '' then do
   say pgm ' Begin execution:' date() time()
   recursion_level = 0
   if stream(errors,'c','query exists') \= '' then '@erase' errors
   say 'Errors (if any) will be written to' errors
end

verbose = 0        /* we aren't verbose */
mask = ''          /* mask of what to copy ...i.e. everything */
fnc = 0            /* we only have a source file mask, might be used later */
dest = '.'         /* assume currect directory  */
compare = ''       /* compare flag set from the /d option */
tattrib = '**-*-'  /* assume no hidden nor system files */
lfn_support = 1    /* assume we want to logically handle long file names */
erase_orphans = 0  /* do not erase extraneous files on the destination */
inclSubdirs = 0    /* assume no recursion into subdirectories */
lstFN = ''         /* assume no indirect lstFile containing the names to copy */

/* parse the command line arguments */
origArgs = ''
do while args <> ''
   parse var args next args
   if left(next,1) = '/' | left(next,1) = '-' then do
      origArgs = origArgs next
      next = translate(substr(next,2))
      if left(next,1) = 'S' then inclSubdirs = 1
      if left(next,1) = 'D' then compare = compare 'datestamp'
      if left(next,1) = 'V' then do
         verbose = substr(next,2)
         if verbose = '' then verbose = 1
      end
      if left(next,1) = 'H' then tattrib = '*****'
      if left(next,2) = 'L-' then lfn_support = 0
      if left(next,3) = 'LST'
         then parse var args lstFN args

      if left(next,5) = 'ERASE' then erase_orphans = 1   /* erase orphans even in 1st recursion */
      if left(next,6) = 'ERASE-' then erase_orphans = 2  /* erase only from subdirectories */
   end
   else do
      /* handle quoted file names that may have embedded blanks */
      if left(next,1) == '"' & right(next,1) \= '"' then do
         endQuote = pos('"',args)
         next = next substr(args,1,endQuote)
         args = substr(args,endQuote + 1)
      end
      next = strip(next,'B','"')

      fnc = fnc + 1
      select
         when fnc = 1 then mask = next
         when fnc = 2 then dest = next
         otherwise do
            say 'invalid argument' next
            exit 8
         end
      end
   end
end
recursion_level = recursion_level + 1

/* get information on all the SOURCE files fitting that mask */
call RxFuncAdd "SysLoadFuncs", RexxUtil, "SysLoadFuncs"
call SysLoadFuncs
if verbose > 1 then say '   processing' mask
if lstFN = ''
   then rc = SysFileTree(mask,srcFiles,'FL',tattrib)
else do
   si = 0
   status = stream(lstFN,'c','open read')
   Do While left(status,5) = 'READY'
      data = linein(lstFN)
      status = stream(lstFN,'s')
      if left(status,5) = 'READY' then do
         si = si + 1
         srcFiles.si = data
      end
   End
   status = stream(lstFN,'c','close')
   srcFiles.0 = si
end
if srcFiles.0 = 0 & pos('*',mask) = 0 then do
   /* nothing was found, so was the original specification a subdirectory? */
   rc = SysFileTree(mask,srcDirs,'DL')
   if srcDirs.0 = 1 then do
      source_path  = filespec('path',mask)
      if source_path = ''
         then mask = directory(mask)||'\*'
         else mask = mask||'\*'
      rc = SysFileTree(mask,srcFiles,'FL',tattrib)
   end
end

/* get information so we can compute relative directory location */
source_drive = filespec('drive',mask)
source_path  = filespec('path',mask)
relativeRoot = source_drive||source_path
mask  = filespec('name',mask)
if mask = '' then mask = '*'

source_cwd   = directory(source_drive)
if right(source_cwd,1)  \= '\'
   then source_cwd = source_cwd||'\'
if left(source_path,1) \= '\'
   then relativeRoot = source_cwd||source_path
back = directory(here)

if right(dest,1) = ':'
   then dest = dest||'.\'

if dest \= '' & right(dest,1) \= '\'
   then dest = dest||'\'

/* see if the destination supports native long file names */
if dest_is8.3 = '' then do
   fqDestName = SysTempFileName(dest||'$2345678?.123?')
   if fqDestName \= ''
      then dest_is8.3 = 0       /* native long file name support */
      else dest_is8.3 = 1       /* limited to DOS FAT 8.3 file names */
end
else if dest_is8.3 then do
   /* we need to insure the destination subdirectories fit the 8.3 restriction */
   rest = dest
   fqDestName = ''
   do while pos('\',rest) > 0
      /* create short 8.3 names of each directory in the path */
      parse var rest longname '\' rest
      shortName = shortName(longname)
      fqDestName = fqDestName || shortName

      /* if the directory doesn't exist, create it */
      back = directory(fqDestName)
      if back = '' then do
         '@mkdir "'||strip(fqDestName)||'"'
         back = directory(here)

         /* as necessary, set the .LONGNAME attribute */
         if shortName <> translate(longname) then
            rc = SysPutEA(fqDestName,'.LONGNAME','FDFF'x||D2C(LENGTH(longname))||'00'x||longname)
      end
      else back = directory(here)

      fqDestName = fqDestName || '\'
   end
   dest = fqDestName
end

/* list all the existing files in the DESTINATION directory */
rc = SysFileTree(dest||mask,destFiles,'FL')

/* and get the longname attribute of the existing DESTINATION files */
Do di = 1 to destFiles.0
   /* reformat the variable to quote the file name(s) */
   cur = destFiles.di
   parse var cur dtHere tmHere sizeHere attrHere fnHere
   fnHere = strip(fnHere)
   destFileName = filespec('name',fnHere)
   if lfn_support then do
      rc = SysGetEA(fnHere,'.LONGNAME','longname')
      if rc = 0 & length(longname) > 4
         then destFileName = delstr(longname,1,4)
   end
   destFiles.di = dtHere tmHere sizeHere attrHere '"'||fnHere||'" "'||destFileName||'"'

   /* just the essential data for sorting purposes */
   key.di = translate(destFileName)
End

/* insure the list of existing destination names is sorted into ascending order */
say 'Sorting' destFiles.0 'destination (existing files)...'
Do di = destFiles.0 to 1 by -1 until ordered = 1
   ordered = 1                /* assume list is ordered (Class bubble sort) */
   Do ni = 2 to di
      p = ni - 1
      if key.p > key.ni then do
         /* swap places in the list */
         this = key.p
         key.p  = key.ni          /* swap the keys */
         key.ni = this
         cur = destFiles.p        /* swap the data */
         destFiles.p  = destFiles.ni
         destFiles.ni = cur

         ordered = 0              /* list has changes to ripple */
      end
   End

   /* if no changes detected so we are sorted */
   if bReordered = 0 then leave
End

/* get the longname for each source file */
say 'Checking for the .LONGNAME extended attribute...'
Do si = 1 to srcFiles.0
   src = srcFiles.si
   parse var src d t s a sfn
   sfn = strip(sfn)
   sfn = strip(sfn,'B','"')
   rc = SysGetEA(sfn,'.LONGNAME','slongname')
   if rc \= 0 | length(slongname) <= 4 then slongname = ''
   srcFiles.si = d t s a '"'||sfn||'" "'||filespec('name',delstr(slongname,1,4))||'"'

   /* just the essential data for sorting purposes */
   key.si = translate(filespec('name',sfn))
end

/* insure the list of source names is sorted into ascending order */
say 'Sorting source files...'
Do si = srcFiles.0 to 1 by -1 until ordered = 1
   ordered = 1                /* assume list is ordered (Class bubble sort) */
   Do ni = 2 to si
      p = ni - 1
      if key.p > key.ni then do
         /* swap places in the list */
         this = key.p
         key.p  = key.ni          /* swap the keys */
         key.ni = this
         cur = srcFiles.p         /* swap the data */
         srcFiles.p  = srcFiles.ni
         srcFiles.ni = cur

         ordered = 0              /* list has changes to ripple */
      end
   End

   /* if no changes detected so we are sorted */
   if bReordered = 0 then leave
End

/* if we are to erase orphan files */
if  erase_orphans <> 0 & recursion_level >= erase_orphans then do
   say 'checking' destFiles.0 'existing destination files at' dest
   /* for each existing file in the destination directory */
   lastMatch = 0
   Do di = 1 to destFiles.0
      /* see if this existing file still exists in the source files list */
      cur = destFiles.di
      parse var cur . . . . '"' fn '"' . '"' longname '"'
      destFileName = translate(filespec('name',fn))

      bFound = 0
      peekAt = lastMatch + 1
      Do si = peekAt to srcFiles.0
         src = srcFiles.si
         parse var src . . . . '"' sfn '"' . '"' slongname '"'
         srcFileName = translate(filespec('name',sfn))

         /* first, see if we can find it by the long name EA */
         if lfn_support then do
            if slongname \= '' & translate(slongname) = destFileName then bFound = 1
            else if slongname \='' & translate(longname) = translate(slongname) then bFound = 1
            else if longname \= ''& translate(longname) = srcFileName then bFound = 1
         end

         /* now check for it via the native file system name */
         if srcFileName = destFileName then bFound = 1

         if bFound = 1 then do
            lastMatch = si  /* we might be able to take short next time */
            leave
         end
         else if lfn_support = 0 then do  /* if only care about file system names */
            /* as the list is ordered,
               if source file is past existing destination file names,
                  then we'll never find it in the source list, so it is orphaned. */
            if srcFileName > destFileName
               then leave
         end
         else if si = peekAt & lastMatch \= 0 then do
            /* we peeked ahead at the next item, but our guess was wrong.
               So as lfn processing is needed, we resume searching from item # 1 */
            lastMatch = 0
            si = 0
         end
      End

      /* if it wasn't found, then it is an orphaned file */
      if bFound = 0 then do
         say '@erase orphan file:' fn
         '@erase' fn
      end
   End

   /* are there any directories that no longer exist */
   rc = SysFileTree(dest||mask,destDirs,'DL')
   rc = SysFileTree(relativeRoot,srcDirs,'DL')
   Do di = 1 to destDirs.0
      aDir = destDirs.di
      parse var aDir . . . . destDir
      destDir = strip(destDir)
      destDirName = filespec('name',destDir)
      longname = ''
      if lfn_support then do
         rc = SysGetEA(destDir,'.LONGNAME','longname')
         if rc = 0 & length(longname) > 4
            then longname = delstr(longname,1,4)
      end

      bFound = 0
      Do si = 1 to srcDirs.0
         src = srcDirs.si
         parse var src . . . . srcDir
         srcDir = strip(srcDir)
         srcDirName = filespec('name',srcDir)
         slongname = ''

         if lfn_support then do
            rc = SysGetEA(srcDir,'.LONGNAME','slongname')
            if rc = 0 & length(slongname) > 4
               then slongname = delstr(slongname,1,4)
         end

         /* first, see if we can find it by the long name EA */
         if lfn_support then do
            if slongname \= '' & translate(slongname) = translate(destDirName) then bFound = 1
            else if slongname \='' & translate(longname) = translate(slongname) then bFound = 1
            else if longname \= ''& translate(longname) = translate(srcDirName) then bFound = 1
         end

         /* now check for it via the native file system name */
         if srcDirName = destDirName then bFound = 1

         if bFound = 1 then leave
      End

      if bFound = 0 then Do
         say 'directory deleted' destDir
         '@call rd! "'||destDir||'" (OK'
      end
   End
End

/* for each one of the candidate files */
say 'checking' srcFiles.0 'source candidate files at' relativeRoot
consecutiveErrorCount = 0
lastMatch = 0
Do si = 1 to srcFiles.0
   cur = srcFiles.si
   copy = 'Y'         /* assume we need to copy it */

   /* parse the current file information from the source */
   parse var cur d t s a '"' sfn '"' . '"' slongname '"'
   if verbose >= 1 then say '  checking' d t sfn
   sfn = strip(sfn)
   srcFileName = translate(filespec('name',sfn))

   bFound = 0
   peekAt = lastMatch + 1
   Do di = peekAt to destFiles.0
      parse value destFiles.di with dtHere tmHere sizeHere attrHere '"' fn '"' . '"' longname '"'
      destFileName = translate(filespec('name',fn))

      /* first, see if we can find it by the long name EA */
      if lfn_support then do
         if translate(longname) = srcFileName | slongname = longname then do
            copy = 'N'
            leave
         end
      end

      /* or find it by the the native file system names */
      if srcFileName = destFileName then do
         copy = 'N'
         lastMatch = di  /* we might be able to take short next time */
         leave
      end
      else if lfn_support = 0 then do  /* if only care about file system names */
         /* as the list is ordered,
            if destination list past source list,
               then we'll never find it so we should leave and copy it */
         if srcFileName < destFileName
            then leave
      end
      else if di = peekAt & lastMatch \= 0 then do
         /* we peeked ahead at the next item, but our guess was wrong.
            So as lfn processing is needed, we resume searching from item # 1 */
         lastMatch = 0
         di = 0
      end
   End

   /* if it wasn't missing, see if we need to compare other attributes */
   if copy = 'N' then do
      If pos('datestamp',compare) > 0 Then Do
         If dtHere <> d | tmHere <> t | sizeHere <> s
            Then copy = 'Y'   /* something different, so copy it */
      End
   End

   If copy = 'Y' Then Do
      if verbose < 1 then say '  copying' sfn
      fqDestName = ''

      /* validate the destination directory hierarchy
         and fully qualify the destination file path */
      rest = dest || substr(sfn,length(relativeRoot)+1)
      do while pos('\',rest) > 0
         parse var rest adir '\' rest
         if dest_is8.3
            then adir = shortName(adir)
         if fqDestName \= '' then fqDestName = fqDestName || '\'
         fqDestName = fqDestName || adir
         there = directory(fqDestName)
         if there = '' then do
            if verbose > 1 then say '   making subdirectory' fqDestName
            '@mkdir "'||strip(fqDestName)||'"'
         end
         back = directory(here)
      end
      if fqDestName \= '' then fqDestName = fqDestName || '\'

      /* if copying from a VFAT drive with a long name */
      setLFN_EA = 0
      if (lfn_support & length(slongname) > 0 & dest_is8.3 = 0)
         then destFileName = slongname    /* use the source longname attribute */
      else do  /* we don't want long names on the destination */
         if dest_is8.3 then do
            destFileName = shortName(rest)
            if translate(destFilename) \= translate(rest)
               then setLFN_EA = 1
            end
         else destFileName = rest
      end

      fqDestName = fqDestName || destFileName
      if pos('H',a) = 0 & pos('S',a) = 0 & s > 0
        then '@copy "'||strip(sfn)||'" "'||fqDestName||'"'
        else do  /* we let xcopy do the heavy lifting,
                    but to avoid a prompt by xcopy, we overlay a dummy file */
          rc = stream(fqDestName,'c','open write')
          rc = stream(fqDestName,'c','close')
          '@xcopy /h /o /t "'||strip(sfn)||'" "'||fqDestName||'"'
        end
      if rc \= 0 then do
         emsg = "Error rc" rc 'with copy "'||strip(sfn)||'" "'||fqDestName||'"'
         rc = lineout(errors,emsg)
         consecutiveErrorCount = consecutiveErrorCount + 1
         if consecutiveErrorCount > 4 then do
            Say 'Too many consecutive errors.  Aborting!'
            emsg = 'Too many consecutive errors.  Aborting!'
            rc = lineout(errors,emsg)
            leave
         end
      end
      else if setLFN_EA then do
         if slongname = '' then slongname = filespec('name',sfn)
         rc = SysPutEA(fqDestName,'.LONGNAME','FDFF'x||D2C(LENGTH(slongname))||'00'x||slongname)
         if rc = 0 then consecutiveErrorCount = 0
      end
      else if dest_is8.3 = 0 then do
         /* remove any unnecessary longname attribute copied from the source */
         rc = SysPutEA(fqDestName,'.LONGNAME','')
         if rc = 0 then consecutiveErrorCount = 0
      end
      else consecutiveErrorCount = 0
   End
End

if inclSubdirs then do
   rc = SysFileTree(relativeRoot,subDirs,'DO')
   do d = 1 to subDirs.0
      /* determine the best name for the next subdirectory */
      rc = SysGetEA(subDirs.d,'.LONGNAME','slongname')
      if rc = 0 & length(slongname) > 4
         then newRelativeDest = delstr(slongname,1,4)
         else newRelativeDest = filespec('name',subdirs.d)

      if verbose > 2 then say '   recursing' subDirs.d '  .LONGNAME="'||slongname||'"  newRelativeDest='||newRelativeDest

      if dest \= '' then newRelativeDest = dest || newRelativeDest
      cmdLine = '"' || subdirs.d || '\' || mask || '"'
      cmdLine = cmdLine '"' || newRelativeDest || '"'
      cmdLine = '@call' pgm cmdLine origArgs '(' recursion_level dest_is8.3
      cmdLine
   end
end

if recursion_level <= 1
   then say 'End execution:' date() time()

exit

shortName: procedure expose fqDestName
   parse arg rest
   parse var rest eight '.' three
   if length(eight) > 8 | length(three) > 3 then do
      longname = rest
      b6 = translate(strip(substr(eight||"      ",1,6)))
      e3 = translate(strip(substr(three||"   ",1,3)))
      if length(e3) > 0
         then e3 = '.'||e3
      do u = 1 to 9
         shortName = fqDestName||b6||'~'||u||e3
         if stream(shortName,'c','query exists') = '' then leave
         rc = SysGetEA(shortName,'.LONGNAME','existing_longname')
         if rc = 0 & delstr(existing_longname,1,4) = longname then leave
      end
      if u > 9 then do
         /* we exhausted the most common names, make a unique one */
         b2 = substr(b6||" ",1,2)
         shortName = fqDestName||b2||"????~1"||e3
         shortName = SysTempFileName(shortName)
      end
      rest = filespec('name',shortName)
   end

return rest
