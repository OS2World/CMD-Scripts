/* #! /usr/bin/regina */
/* Enhanced Directory Tree Utility */

numeric digits 16        /* increase the precision for byte totals */

parse source OpSys . exname .
fsSeparator = '\'
if OpSys = 'UNIX' then fsSeparator = '/'

parse arg args
if pos('/',args) > 0
   then do
      parse arg mask '/' args '(' opts
      args = '/'||strip(args)
   end
   else do
      parse arg mask '(' opts
      args = ''
   end

mask = strip(mask)
if left(mask,1) = '"'
   then mask = strip(mask,'B','"')

if mask = '?' | mask = '-?' | mask = '-h' then do
   say 'Enhanced directory command for a drive.  Displays entire drive contents.'
   say '  a file mask may be specified.  Defaults to *.*'
   say '  Use a mask of "." to start from the current relative subdirectory.'
   say ''
   say 'Syntax:'
   say ' ' exname '<mask> <modifiers> ( <DIR | FILES | BOTH> <COUNT | ROLLUP>'
   say ''
   say 'Options:'
   say '  Default is to display only files in ALL subdirectories'
   say '  Option DIR means only the directory tree in ALL subdirectories'
   say '  Option FILES means only Files in the one SPECIFIED subdirectory'
   say '  Option BOTH displays all files and directory names in ALL subdirectories'
   say ''
   say '  Option COUNT will output only summary information of # matches, bytes'
   say '    A minimum COUNT may be specified, i.e. "COUNT 2", to display only'
   say '    the entries that have 2 or more mask matches.  Default is 0 or more.'
   say '  Option ROLLUP is same as COUNT with the addition of lower level subdirectory'
   say '    summary count information is rolled up into the parent directory.'
   say ''
   say 'Modifiers may be:'
   '@pause'
   say '   /d: signals a date comparison for greater than or equal to specified date.'
   say '            Note: date format is mm-dd-yy.  mm/dd/yy is not allowed.  Year may be yy or yyyy'
   say '        if /d: is given without a date, defaults to today.'
   say '        optionally, /de: for date equal to,'
   say '                 or /dl: for date less than or equal.'
   say '                 or /dg: for date greater than or equal.'
   say '   /t: signals a time comparison for greater than or equal to specified time.'
   say '        if /t: given without a date, defaults to today.'
   say '     Typically, if a /dg: is specified, specify only /t: to select those'
   say '           files newer than that date and time.  If a /tg: is specified,'
   say '           then BOTH the Date and the Time must be greater.'
   say '           That probably would not be what you intended.'
   say '        optionally, /te: for time equal to,'
   say '                 or /tl: for time less than or equal.'
   say '                 or /tg: for time greater than or equal.'
   say '   /s: signals a size comparison.  (defaults to /sg:1  greater than zero)'
   say '   /l /l+ display the .LONGNAME extended attribute as the file name'
   say '        instead of the actual short name on a VFAT file system'
   say '   /f  shows only the fully qualified file name'
   say '   /a: attributes must have.  For example /a:a-r for Archive not readonly'
   say '                                  or /a:hs for hidden and system files'
   exit 100
end

If mask = '' Then mask = '*'
If mask = '.' Then mask = mask || '\*'

what = 'F'      /* only files listed by default */
If wordpos('DIR',translate(strip(opts))) > 0 Then what = 'D'
If wordpos('BOTH',translate(strip(opts))) > 0 Then what = 'B'

nesting = 1   /* assume we will traverse all nested subdirectories */
If wordpos('FILES',translate(strip(opts))) > 0 Then nesting = 0

countOnly = -1 /* by default, names will be displayed */
rollup = 0     /* by default, counts are not rolled up to parent directory */
i = wordpos('COUNT',translate(strip(opts)))
If i = 0 then do
   i = wordpos('ROLLUP',translate(strip(opts)))
   If i > 0
      then rollup = 1
End
If i > 0 Then Do
   countOnly = 0
   if words(opts) > i & datatype(word(opts,i+1)) = 'NUM'
      then countOnly = word(opts,i+1)
end

show_longname = 0
i = pos('/L',translate(args))
if i > 0 then do
   parse value substr(args,i) with _OptValue .
   show_longname = 1
   if length(_OptValue > 2) & right(_OptValue,1) = '+'
      then show_longname = 2
   args = delstr(args,i,length(_OptValue))
end

showFullNameOnly = 0
if pos('/F',translate(args)) > 0
   then showFullNameOnly = 1

if pos('/d:',args) > 0 | pos('/de:',args) > 0 | pos('/dg:',args) > 0 | pos('/dl:',args) > 0 then do
   parse var args . '/d' comparator ':' begin_date . '/' .
   comparator = translate(comparator)
   if begin_date = '' then do
      begin_date = date('U')
      say '   defaulting date to today =' begin_date
   end
   if pos('-',begin_date) > 0
      then parse var begin_date mm '-' dd '-' yy
      else  parse var begin_date mm '/' dd '/' yy
   if yy = '' then yy = left(date('S'),4)
   if yy <= 99 & yy >= 70
      then yy = yy + 1900
      else if yy < 100 then yy = yy + 2000
   begin_date = yy||'-'||right(100+mm,2)||'-'||right(100+dd,2)
   if (( mm < 1 | mm > 12) | (dd < 1 | dd > 31)) then do
      say '  Date entered was not in proper month-day-year form:'
      say '     a date of' begin_date 'is not appropriate.'
      exit 8
   end
end
else do
  begin_date = 0
  comparator = ''
end

parse var args . '/t' t_comparator ':' time_arg . '/' .
t_comparator = translate(t_comparator)
if time_arg = '' then time_arg = '00:00'
pm = 0
parse var time_arg hr ':' min ':' .
if min = '' then min = 0
if right(min,1) = 'p' then do
   pm = 12
   min = left(min,length(min)-1)
end
begin_time = ((hr + pm) * 60) + min

if begin_time > 0 & begin_date = 0
   then begin_date = substr(date('S'),1,4)||'-'||substr(date('S'),5,2)||'-'||substr(date('S'),7,2)

/* is there a "size" option? */
s_comparator = ''
if pos('/S',translate(args)) > 0 then do
   parse var args . '/s' s_comparator ':' size_arg . '/' .
   s_comparator = translate(s_comparator)
   if s_comparator = '' then s_comparator = 'G'
   if size_arg = '' then size_arg = 1
end

tAttrib = "*****"   /* ADHRS attribute mask for SysFileTree */
parse var args . '/a:' attributeFilter .
do while attributeFilter \= ''
   /* parse out the target attribute specification... i.e.  '/a:-r' for not read only */
   anAttr = left(attributeFilter,1)
   anAttrMask = '+'
   if anAttr = '-' then do
      anAttr = left(attributeFilter,2)
      anAttrMask = '-'
   end
   if anAttr = '+' then do
      anAttr = left(attributeFilter,2)
      anAttrMask = '+'
   end
   attributeFilter = substr(attributeFilter,length(anAttr)+1)

   anAttr = translate(right(anAttr,1))
   maskPos = pos(anAttr,'ADHRS')

   tAttrib = overlay(anAttrMask,tAttrib,maskPos,1)
end
if substr(tAttrib,2,1) = '+'
   then what = 'D'

/* On Unix/Linux, Hidden files start with a . */
if OpSys = 'UNIX' & substr(tAttrib,3,1) = '+' & left(mask,1) \= '.' then do
   mask = '.'||mask
   tAttrib = substr(tAttrib,1,2) || '*' || substr(tAttrib,4)
end

call rxfuncadd "sysloadfuncs", RexxUtil, "sysloadfuncs"
call sysloadfuncs

/* set up for recursion down the directory tree */
rootDir = filespec('drive',mask) || filespec('path',mask)
if rootDir = '' then rootDir = '.'
if filespec('path',mask) = '' & filespec('drive',mask) \= '' then do
   here = directory()
   rootDir = directory(rootDir||'.')
   here = directory(here)
end
mask = filespec('name',mask)

call listDirectory rootDir
parse pull thisCount ',' thisSize

if countOnly >= 0 then do
   say '"'||rootDir||'"' thisCount 'entries' prettyNum(thisSize) 'bytes'
end

exit

prettyNum: procedure
parse arg aNumber .
   prettyNumber = reverse(aNumber)
   do nCommas = 1 while length(prettyNumber) >= 4*nCommas
      prettyNumber = substr(prettyNumber,1,4*(nCommas)-1)||','||substr(prettyNumber,4*(nCommas))
   end
   prettyNumber = reverse(prettyNumber)
return prettyNumber

listDirectory: procedure expose mask begin_date begin_time comparator t_comparator s_comparator size_arg show_longname nesting what tAttrib countOnly rollup showFullNameOnly fsSeparator OpSys
parse arg rootDir
rootDir = strip(rootDir,'T',fsSeparator)

/* list the contents this directory */
options = what||'L' /* 'L' returns date as YYYY-MM-DD HH:MM:SS */

thisCount = 0
thisSize = 0

wCard = pos('*',rootDir) + pos('?',rootDir)
if wCard <> 0 then do
   rc = SysFileTree(rootDir,dirs,'D',tAttrib)
   do i = 1 to dirs.0
       aSubDir = subword(dirs.i,5)
       call listDirectory aSubDir||fsSeparator
       parse pull subCount ',' subSize
       thisCount = thisCount + subCount
       thisSize = thisSize + subSize
   end
end
else do
   /* Hidden files work differently on Unix/Linux */
   if OpSys = 'UNIX' & substr(tAttrib,3,1) = '-'
      then rc = SysFileTree(rootDir || fsSeparator || mask ,files,options,substr(tAttrib,1,2)||'*'||substr(tAttrib,4))
      else rc = SysFileTree(rootDir || fsSeparator || mask ,files,options,tAttrib)

   Do i = 1 to files.0
     l = files.i
     parse var l dt tm size attr fname
     fname = strip(fname,'L')      /* remove any leading blanks */
     shortName = filespec('name',fname)

     /* if on Unix/Linux and requesting non hidden files,
                then file name must not start with a '.'             */
     if OpSys = 'UNIX' & substr(tAttrib,3,1) = '-' & left(shortname,1) = '.'
        then iterate

     spot = pos(fname,l)-1

     if show_longname > 0 then do
        rc = SysGetEA(fname,'.LONGNAME','longname')
        if (rc = 0 & length(longname) > 4) then do
           fname = filespec('drive',fname)||filespec('path',fname)||delstr(longname,1,4)
        end
        else shortName = ''
     end

     if begin_date > 0 then do
        if pos('/',dt) > 0 then do
           parse var dt mm '/' dd '/' yy
           if yy <= 99 & yy >= 70
              then yy = yy + 1900
              else yy = yy + 2000
           compare_date = yy||'-'||right(100+mm,2)||'-'||right(100+dd,2)
        end
        else do
           compare_date = dt
        end

        select
          when comparator = '' then do
               if compare_date < begin_date then iterate
            end
          when comparator = 'E' then do
               if compare_date \= begin_date then iterate
            end
          when comparator = 'G' then do
               if compare_date < begin_date then iterate
            end
          when comparator = 'L' then do
               if compare_date > begin_date then iterate
            end
          otherwise if compare_date < begin_date then iterate
        end

        pm = 0
        if right(tm,1) = 'p' then pm = 12
        parse value left(tm,length(tm)-1) with hr ':' min ':' sec
        minutes = ((hr + pm) * 60) + min
        select
          when t_comparator = '' then do
               /* interpret the time comparator using date rules */
               if compare_date = begin_date then do
                  if comparator = 'L' then do
                     if minutes >= begin_time then iterate
                  end
                  else do
                     if minutes < begin_time then iterate
                  end
               end
               /* else the time component is irrelevant as the date argument
                  has already filtered the file's timestamp */
            end
          when t_comparator = 'E' then do
               if minutes \= begin_time then iterate
            end
          when t_comparator = 'G' then do
               if minutes < begin_time then iterate
            end
          when t_comparator = 'L' then do
               if minutes > begin_time then iterate
            end
          otherwise if minutes < begin_time then iterate
        end

     end

     if s_comparator \= '' then do
        select
           when s_comparator = 'E' then do
                if size \= size_arg then iterate
             end
           when s_comparator = 'G' then do
                if size <= size_arg then iterate
             end
           when s_comparator = 'L' then do
                if size >= size_arg then iterate
             end
           otherwise do
                say 'Error in logic.  s_comparator value "'||s_comparator||'" is unprogrammed!'
             end
        end
     end

     /* reformat the output to enclose the file name in quotes in case of blanks */
     output = left(l,spot)||'"'||fname||'"'
     if show_longname > 1 then
        output = left(l,spot)|| left(shortName||"            ",12) '"'||fname||'"'
     if countOnly < 0 then do
        if showFullNameOnly = 1
           then parse var output with '"' output '"'

        say output
     end

     thisCount = thisCount + 1
     thisSize = thisSize + size

   End
End

/* if to display the nested directory information */;
if nesting \= 0 then do
  rc = SysFileTree(rootDir || fsSeparator||'*',subDirs,'O',"*+***")

  Do d = 1 to subDirs.0
     call listDirectory subDirs.d
     parse pull subCount ',' subSize
     if countOnly >= 0 & subCount >= countOnly then do
        say '"'||subdirs.d||'"' subCount 'entries' prettyNum(subSize) 'bytes'
     end
     if rollup > 0 then do
        thisCount = thisCount + subCount
        thisSize = thisSize + subSize
     end
  End
End

push thisCount||','||thisSize
return
