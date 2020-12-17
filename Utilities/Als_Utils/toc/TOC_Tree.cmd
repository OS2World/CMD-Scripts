/* read a saved "TOCxxxxx.lst" file
   outputing a directory tree of unique PATHS */

/* note, OPT is presently unused.  We only need the input file name to read */
parse arg fn . '/' opt
if opt \= '' then opt = '/'||translate(opt)

call RxFuncAdd "SysLoadFuncs", RexxUtil, "SysLoadFuncs"
call SysLoadFuncs

n = 0
lastPath = ''

/* read the input file contents ASSUMED to be sorted by filename */
status = stream(fn,'c','open read')
Do While left(status,5) = 'READY'
   data = linein(fn)
   status = stream(fn,'s')
   if left(status,5) = 'READY' then do
      parse var data fDate fTime fSize fAttr fName .
      curPath = filespec('path',fName)

      /* keeping only paths that are unique */
      if curPath \= lastPath then do
         n = n + 1
         mLine.n = data
         lastPath = curPath
         say curPath
      end
   end
End
status = stream(fn,'c','close')
mLine.0 = n

