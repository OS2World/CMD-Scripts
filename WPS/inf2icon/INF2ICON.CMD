/* INF2ICON.CMD - makes icons from INF files
*/

parse arg filespec folder
if filespec = '' then do
   say 'Usage:'
   say 'INF2ICON inf_file [folder_name]'
   say ''
   say 'inf_file is the name of the INF file for which you want an icon'
   say 'folder_name is the a folder on the desktop where you want the ICONS to go'
   exit
end

if folder = '' then do
   folder = 'Online Help'
end

/* objectid = translate(folder, , '!@#$%^&*()_-_=+[]{};:"/?.>,<`~ ')
*/
objectid = '<'translate(folder, '_', ' ')'>'
objectid = translate(objectid)
say folder
say objectid

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

call SysFileTree filespec, 'files', 'FO', '*-***'
say 'Folder name:' folder
call SysCreateObject "WPFolder", folder, "<WP_DESKTOP>", 'OBJECTID='objectid, 'U'

do i = 1 to files.0
   filespec = translate(files.i)
   if right(filespec,4) == '.INF' then do
      say 'File:' filespec
      x = 0
      do forever
         c = charin(filespec, x + 108, 1)
         if c2d(c) = 0 then leave
         x = x + 1
      end
      title = charin(filespec, 108, x)
      dot = lastpos(".",filespec)
      slash = lastpos("\",filespec)
      filename = substr(filespec, slash + 1, 255)
      pathname = left(filespec, slash)
      basename = substr(filespec, slash + 1, dot - slash - 1)

      say 'Filename:' filename
      say 'Basename:' basename
      say 'Pathname:' pathname
      number = right(basename,1)
      if number >= '0' & number <= '9' then do
         say 'Number:' number
         call SysCreateObject "WPProgram", title, objectid, 'EXENAME=VIEW.EXE;STARTUPDIR='||pathname||';PARAMETERS='||basename, 'U'
      end
      call SysCreateObject "WPProgram", title, objectid, 'EXENAME=VIEW.EXE;STARTUPDIR='||pathname||';PARAMETERS='||basename, 'U'
   end
end
exit

title: procedure
   arg filespec
      say 'File:' filespec
      x = 0
      do forever
         c = charin(filespec, x + 108, 1)
         if c2d(c) = 0 then leave
         x = x + 1
      end
      if x = 0 then
         return 'Untitled'
      else
         return charin(filespec, 108, x)
