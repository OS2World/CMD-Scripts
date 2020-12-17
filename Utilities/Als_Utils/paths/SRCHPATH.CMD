/* Automatically invoking REXX for Windows NT.
@ECHO OFF
CLS
SET REXXPROG_NAME=%0
SET REXXPROG_PARMS=
:GET_PARMS
SET REXXPROG_PARMS=%REXXPROG_PARMS% %1 %2 %3 %4 %5 %6 %7 %8 %9
FOR %%A IN ( 1 2 3 4 5 6 7 8 9 ) DO SHIFT
IF NOT '.%1' == '.' GOTO GET_PARMS

REXX %REXXPROG_NAME% %REXXPROG_PARMS%

SET REXXPROG_PARMS=
SET REXXPROG_NAME=
@GOTO EndNT */

parse source OS . exname .
parse upper arg file . '!!' what .
parse upper arg . '(' options

environment = "OS2ENVIRONMENT"
If left(OS,7) == "Windows"
   then environment = "environment"
   else do
      call RxFuncAdd "SysLoadFuncs", RexxUtil, "SysLoadFuncs"
      call SysLoadFuncs
   end

If pos('\!!',options) > 0 Then Do
   parse upper arg all_before '(' .
   parse var all_before file . '\!!' what .
End

if file = '' | file = '?' then do
   say 'Syntax:' exname 'search_file < !! what> < ( options> '
   say '   Where   WHAT is environment variable to search (PATH, DPATH, etc).'
   say '                Defaults to something logical based on file extension.'
   say '           OPTIONS can be "NOISY" to display each directory searched.'
   exit 100
end

if pos('NOISY',options) = 0    /* display all things searched or just hits */
   then noisy = 0
   else noisy = 1

what = strip(what)

parse value filespec("NAME",file) with name '.' ext

if ext = '' then do
   file.0 = 4
   file.1 = name||'.CMD'
   file.2 = name||'.BAT'
   file.3 = name||'.EXE'
   file.4 = name||'.COM'
end
else do
   file.0 = 1
   file.1 = file
end

if what = '' then do
   parse value filespec("NAME",file.1) with . '.' test_ext
   select
     when test_ext = 'CMD' then what = 'PATH'
     when test_ext = 'BAT' then what = 'PATH'
     when test_ext = 'EXE' then what = 'PATH'
     when test_ext = 'COM' then what = 'PATH'
     when test_ext = 'DLL' then do
        If left(OS,7) == "Windows"
           then what = 'Os2LibPath'
           else what = 'LIBPATH'
     end
     when test_ext = 'LIB' then what = 'LIB'
     when test_ext = 'H'   then what = 'INCLUDE'
     when test_ext = 'HPP' then what = 'INCLUDE'
     when test_ext = 'HLP' then what = 'HELP'
     when test_ext = 'INF' then what = 'HELP'
     when test_ext = 'NDX' then what = 'HELP'
     otherwise what = 'DPATH'
   end
end

say "Searching " what

if what = 'LIBPATH' then do
  /* echo the current environment variables into a temporary file so we
     can parse through it looking for "BEGINLIBPATH" and "ENDLIBPATH" */
  tmp = value("TMP",,environment)
  if length(tmp) < 1
     then tmp = value("TEMP",,environment)
  if right(tmp,1) \= '\' & right(tmp,1) \= '/'
     then tmp = tmp||'\'
  parse value filespec('NAME',exname) with e '.' .
  tmp = tmp||e||'.$TM'
  '@set >' tmp

  bp = ''
  if stream(tmp,'c','query exists') \= '' then do
     e = stream(tmp,'c','open read')
     do until substr(stream(tmp,"D"),1,8) = 'NOTREADY'
        text = translate(linein(tmp))
        if left(text,12) = 'BEGINLIBPATH' then do
           parse var text with . '=' bp
           bp = strip(bp)
           leave
        end
     end
  end
  if (length(bp) > 1) & (right(bp,1) \= ';')
     then bp = bp||';'

  call RxFuncAdd 'SysBootDrive','RexxUtil','SysBootDrive'
  p = ''
  map = SysBootDrive()
  do i = 1 to words(map) while p = ''
     sz = word(map,i)||'\config.sys'
     if stream(sz,'c','query exists') \= '' then do
        e = stream(sz,'c','open read')
        do until substr(stream(sz,"D"),1,8) = 'NOTREADY'
           text = translate(linein(sz))
           if left(text,7) = 'LIBPATH' then do
              parse var text with . '=' p
              p = strip(p)
              leave
           end
        end
     end
  end

  ep = ''
  if stream(tmp,'c','query exists') \= '' then do
     e = stream(tmp,'c','open read')
     do until substr(stream(tmp,"D"),1,8) = 'NOTREADY'
        text = translate(linein(tmp))
        if left(text,10) = 'ENDLIBPATH' then do
           parse var text with . '=' ep
           ep = strip(ep)
           leave
        end
     end
     e = stream(tmp,'c','close')
     '@erase' tmp
  end

  if (length(p) > 1) & (right(p,1) \= ';')
     then p = p||';'
  p = bp||p||ep

end
else p = value(what,,environment)

If what = 'PATH' | what = 'DPATH' Then Do
   if (pos('.;',p) = 0)
      then p = '.;'||p
End

do while length(p) > 0
   parse var p path ';' p
   if length(path) > 0 then do
      if noisy
         then say path
      if right(path,1) \= '\'
         then path = path||'\'
      do i = 1 to file.0
         e = stream(path||file.i,'c','query exists')
           if e <> '' then do
              subfiles.0 = 1
              subfiles.1 = e
              /* If there was a wild card in the initial query */
              if pos('*',e) > 0 then do
                 subfiles.0 = 0
                 rc = SysFileTree(e,subfiles,'FO')
              end

              do j = 1 to subfiles.0
                 dt = stream(subfiles.j,'c','query datetime')
                 say '......' subfiles.j '    ' dt
              end
           end
      end
   end
end

/* This is where execution ends for Windows NT.  It's dead code for OS/2
:EndNT */
