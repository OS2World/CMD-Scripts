/* Rexx install program */
/* (c) Copyright 1994 Scott Maxwell. */

/* Note: I believe this to be a pretty intelligent install routine. */
/*       If anyone wants to use it you can as long as you just      */
/*	 credit me as the original author.  Please don't modify the */
/*	 top seven lines of this file.				    */

Call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
Call SysLoadFuncs

arg where tempdir

KeepCommandLineWindow = 1
WaitForUnzip  = 1
UnzipInCommandLineWindow = 1	/* KeepCommandLineWindow must be 1 for this */

  Say "Welcome to Workplace UnZip!"'0a'x

  Say "WUZ is a series of REXX functions to give you access to archive"
  Say "files (including .ARC, .ARJ, .LZH, .TAR, .Z, .ZIP and .ZOO) from"
  Say "the Workplace Shell or the command line."'0a'x

top:

ucnt = 1
final = ''

if where = '' | tempdir = '' then do
  where = ''
  path = Value('PATH',,'OS2ENVIRONMENT')

  Say "WUZ must be installed in a directory on your PATH:"'0a'x
  i = 1
  found = 0
  dir. = ''
  do forever
    parse var path dir.i ';' path
    if Right(dir.i,1) \= '\' then
      dir.i = dir.i'\'
    if SubStr(dir.i,2,1) = ':' then do
      if Length(CharIn(dir.i'wuz.cmd',1,1)) = 1 then do
        found=i
        Call LineIn dir.found'wuz.cmd'
        Call LineIn dir.found'wuz.cmd'
        Call LineIn dir.found'wuz.cmd'
        Call LineIn dir.found'wuz.cmd'
        old = LineIn(dir.found'wuz.cmd')
        if Left(old,8) \= 'DestPath' then do
          preamble = "A version of WUZ.CMD I don't recognize"
	  old = ''
	  end
        else do
          old = SubStr(old,13,Length(old)-13)
	  preamble = 'WUZ'
          Call LineIn dir.found'wuz.cmd'
          Call LineIn dir.found'wuz.cmd'
          hold = LineIn(dir.found'wuz.cmd')
          if Left(hold,24) = 'KeepCommandLineWindow = ',
             & (SubStr(hold,25,1) = '0' | SubStr(hold,25,1) = '1') then
            KeepCommandLineWindow = SubStr(hold,25,1)
          hold = LineIn(dir.found'wuz.cmd')
          if Left(hold,15) = 'WaitForUnzip = ',
             & (SubStr(hold,16,1) = '0' | SubStr(hold,16,1) = '1') then
            WaitForUnzip = SubStr(hold,16,1)
          hold = LineIn(dir.found'wuz.cmd')
          if Left(hold,27) = 'UnzipInCommandLineWindow = ',
             & (SubStr(hold,28,1) = '0' | SubStr(hold,28,1) = '1') then
            UnzipInCommandLineWindow = SubStr(hold,28,1)
        end
	Call LineOut dir.found'wuz.cmd'
	if Length(CharIn(dir.found'Post-WUZ.cmd',1,1)) = 1 then do
	  Call Linein(dir.found'Post-wuz.cmd')
	  Call Linein(dir.found'Post-wuz.cmd')
	  Call Linein(dir.found'Post-wuz.cmd')
	  final = Linein(dir.found'Post-wuz.cmd')
	  if Left(final,12)\='FinalCommand' | Right(final,3) = "=''" then
	    final=''
	  ucnt = 1
	  user.ucnt = Linein(dir.found'Post-wuz.cmd')
	  if Left(user.ucnt,11) = '/* ---- You' then
	  do ucnt=2 to 50
	    user.ucnt = Linein(dir.found'Post-wuz.cmd')
	    if Left(user.ucnt,12) = '/* ---- They' then leave
	  end
	end
	Call LineOut dir.found'Post-wuz.cmd'
      end
      i=i+1
    end
    if path='' then leave
  end

  if found > 0 then
  do forever
    Say preamble "seems to be installed in" dir.found'0a'x
    Say "0) Use the current copy (i.e. aborting this install)"
    Say "1) Copy over the current version"
    Say "2) Remove the current copy of WUZ and install somewhere else"
    Say "3) Remove every last trace of WUZ from your computer"'0a'x
    Call CharOut ,"What would you like to do: "
    parse upper pull ans
    if ans = 0 | ans = '' then exit(0)
    if ans < 0 | ans > 3 then do
      say '0a'x"Please answer either 0, 1, 2, 3 or <RETURN>"
      iterate
    end

    if ans>=2 then do
      say "Erasing:	wuz.cmd"
      say "		wuz.ico"
      say "		post-wuz.cmd"
      say "		zipstrip.cmd"
      say "		zip-dir.cmd"
      say "		zip-dir.ico"
      say "		fldzip.ico"
      say "		fldunzip.ico"
      say "		open-dir.cmd"
      say "		od.cmd"
      say "		kill-dir.cmd from" dir.found
      Call SysFileDelete dir.found'wuz.cmd'
      Call SysFileDelete dir.found'wuz.ico'
      Call SysFileDelete dir.found'post-wuz.cmd'
      Call SysFileDelete dir.found'zipstrip.cmd'
      Call SysFileDelete dir.found'zip-dir.cmd'
      Call SysFileDelete dir.found'zip-dir.ico'
      Call SysFileDelete dir.found'fldzip.ico'
      Call SysFileDelete dir.found'fldunzip.ico'
      Call SysFileDelete dir.found'open-dir.cmd'
      Call SysFileDelete dir.found'od.cmd'
      Call SysFileDelete dir.found'kill-dir.cmd'
      Call SysDestroyObject '<WorkplaceUnZip>'
      Call SysDestroyObject '<ZipDir>'
      if ans = 3 then exit(1)
    end      
    if ans=1 then
      where = dir.found
    leave
  end

  if where = '' then do
    i = i-1
    root=FileSpec('Drive',Value('SYSTEM_INI',,'OS2ENVIRONMENT'))
    base=1
    nonbase=1
    basedir. = ''
    do j=1 to i
      if Left(dir.j,6) = root'\OS2' | Left(dir.j,8) = root'\MMOS2' | dir.j = root'\' then do
        basedir.base = dir.j
	base = base+1
      end
      else do
        dir.nonbase = dir.j
        nonbase = nonbase+1
      end
    end
    if base > 0 then do
      k = 1
      do j=nonbase to i
        dir.j = basedir.k
        k = k+1
      end
    end
    dir.0 = i
    tr = Trunc((i+1)/2)
    do i=1 to tr
      i2 = i+tr
      build  = '('i')' dir.i
      if dir.i2 \= '' then
        build2 = '('i2')' dir.i2
      else
        build2 = ''
      say insert(build,build2,,40)
    end
    Call CharOut ,'0a'x"Enter the number of your selection: "
    parse pull ans
    if ans > 0 & ans <= dir.0 then
      where = dir.ans
    else do
      say "Invalid number.  Aborting"
      exit(0)
    end
  end
  tempdir = '\'
  hold = directory()
end
else do
  hold = directory()
  where2 = directory(where)
  if where2 = '\' then do
    say "Unknown directory:" where
    where = ''
    Call Directory hold
    Signal top
  end
  where = where2
  tempdir = directory(tempdir)
end

do while tempdir = '\'
  temp = ''
  if found > 0 then temp = old
  if temp = '' then
    temp = Value('TMP',,'OS2ENVIRONMENT')
    if temp = '' then
      temp = Value('TEMP',,'OS2ENVIRONMENT')
  if SubStr(temp,2,1) != ':' then temp = ''
  slash = 1
  if Right(temp,1) = '/' then
    temp = Left(temp,Length(temp)-1)
  do while slash > 0
    slash = LastPos('/',temp)
    if slash > 0 then
      temp = Left(temp,slash-1)'\'Right(temp,slash+1)
  end
  if temp = '' then
    temp = Left(where,2)'\Temp'
  Say "WUZ will create a temporary directory for each archive it extracts."
  Call CharOut ,"Where should it create them? (<RETURN> for" temp") "
  parse pull tempdir
  if tempdir\='' then
    temp = tempdir

  call Directory hold
  tempdir = directory(temp)
  if tempdir = '\' then do
    Call CharOut ,temp "does not exist.  Should I create it? "
    parse upper pull ans
    if Left(ans,1) = 'Y' then do
      if SysMkDir(temp) then
        say "Can't create" temp
      else
        tempdir = temp
    end
  end
end

call Directory hold

if where \= '.' then do
  from = directory()
  to = directory(where)
  if to = '\' then do
    say where': directory not found'
    exit(1)
  end
  say '0a'x"Copying:	wuz.cmd"
  say "		wuz.ico"
  say "		post-wuz.cmd"
  say "		zipstrip.cmd"
  say "		zip-dir.cmd"
  say "		zip-dir.ico"
  say "		fldzip.ico"
  say "		fldunzip.ico"
  say "		open-dir.cmd"
  say "		od.cmd"
  say "		kill-dir.cmd to "to

  Drive = Left(tempdir,2)
  Call SysFileDelete 'wuz.cmd'
  Call LineOut 'WUZ.cmd',linein(from'wuz.cmd')
  Call LineOut 'wuz.cmd',linein(from'wuz.cmd')
  Call LineOut 'wuz.cmd',linein(from'wuz.cmd')
  Call LineIn from'wuz.cmd'
  Call LineIn from'wuz.cmd'
  Call LineIn from'wuz.cmd'
  Call LineIn from'wuz.cmd'
  Call LineIn from'wuz.cmd'
  Call LineIn from'wuz.cmd'
  Call LineIn from'wuz.cmd'
  Call LineOut 'wuz.cmd',"Drive    = '"Drive"'"
  Call LineOut 'wuz.cmd',"DestPath = '"tempdir"'"
  Call LineOut 'wuz.cmd',"IconPath = '"to"'"
  Call LineOut 'wuz.cmd',""
  Call LineOut 'wuz.cmd',"KeepCommandLineWindow =" KeepCommandLineWindow
  Call LineOut 'wuz.cmd',"WaitForUnzip =" WaitForUnzip
  Call LineOut 'wuz.cmd',"UnzipInCommandLineWindow =" UnzipInCommandLineWindow"	/* KeepCommandLineWindow must be 1 for this */"
  do while lines(from'wuz.cmd') > 0
    Call LineOut 'wuz.cmd',LineIn(from'wuz.cmd')
  end
  Call LineOut 'wuz.cmd'
  '@copy' from'wuz.ico WUZ.ico > nul'

  if ucnt > 2 | final \= '' then do
    Call SysFileDelete 'post-wuz.cmd'
    Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.cmd')
    Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.cmd')
    Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.cmd')
    Say ''
    if final \= '' then do
      Say "Preserving FinalCommand from" where"Post-WUZ.CMD"
      Say final
      Call LineIn from'Post-wuz.cmd'
      Call LineOut 'Post-WUZ.cmd',final
    end
    else
      Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.cmd')
    if ucnt > 2 then do
      Say "Preserving user lines from" where"Post-WUZ.CMD"
      Call LineIn from'Post-wuz.cmd'
      Call LineIn from'Post-wuz.cmd'
      do i=1 to ucnt
        Call LineOut 'Post-WUZ.cmd',user.i
      end
    end
    else do
      Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.cmd')
      Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.cmd')
    end
    do while lines(from'Post-WUZ.cmd') > 0
      Call LineOut 'Post-WUZ.cmd',LineIn(from'post-wuz.cmd')
    end
    Call LineOut 'Post-wuz.cmd'
  end
  else
    '@copy' from'post-wuz.cmd > nul'

  '@copy' from'zipstrip.cmd > nul'
  Call SysFileDelete 'zip-dir.cmd'
  Call LineOut 'Zip-Dir.cmd',linein(from'zip-dir.cmd')
  Call LineOut 'zip-dir.cmd',linein(from'zip-dir.cmd')
  Call LineOut 'zip-dir.cmd',linein(from'zip-dir.cmd')
  Call LineIn from'zip-dir.cmd'
  Call LineOut 'zip-dir.cmd',"IconPath = '"to"'"
  do while lines(from'zip-dir.cmd') > 0
    Call LineOut 'zip-dir.cmd',LineIn(from'zip-dir.cmd')
  end
  '@copy' from'zip-dir.ico > nul'
  '@copy' from'fldzip.ico > nul'
  '@copy' from'fldunzip.ico > nul'
  '@copy' from'open-dir.cmd > nul'
  '@copy' from'open-dir.cmd OD.cmd > nul'
  '@copy' from'kill-dir.cmd > nul'
  Call Directory from
end
else
  to = directory()

Call SysDestroyObject '<WorkplaceUnZip>'
Call SysCreateObject "WPProgram", "WPS Unzip", "<WP_DESKTOP>",,
	"OBJECTID=<WorkplaceUnZip>;PROGTYPE=WINDOWABLEVIO;EXENAME="to"wuz.cmd;ASSOCFILTER=*.arc,*.arj,*.lzh,*.tar,*.z,*.zif,*.zip,*.zoo"
Call SysDestroyObject '<ZipDir>'
here = directory()
Call SysCreateObject "WPProgram", "Zip Directory", "<WP_DESKTOP>",,
	"OBJECTID=<ZipDir>;PROGTYPE=WINDOWABLEVIO;EXENAME="to"zip-dir.cmd"

Say '0a'x"Workplace UnZip v1.1 has been successfully installed."
Say "Try it out and see if you like it.  If you do, I would appreciate"
Say "a small cash donation of $20 or at least a note telling me what"
Say "you think.  My Usenet address is scott.maxwell@channel1.com."
Say "Any money should go to:"
Say "                         Pat Maxwell"
Say "                         1587 E. Modesto Ave."
Say "                         Camarillo, CA 93010 U.S.A."'0a'x

Say "You may also rerun Inst-WUZ.Cmd to uninstall."
Say "For more information about Workplace UnZip, read ReadMe.WUZ and WUZ.Doc."
exit(0)

Directory: procedure
  arg Name
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)
  n = 'DIRECTORY'(Name)
  if Right(n,1) \= '\' then
    n = n'\'
  return n
