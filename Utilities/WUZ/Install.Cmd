/* Rexx install program */
/* Donated to the public domain Feb. 19, 1994 by Scott Maxwell. */

/* Note: I believe this to be a pretty intelligent install routine. */
/*       Please modify it and use it as you like.		    */

Call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
Call SysLoadFuncs

parse arg args
if Left(args,1) = '"' then do
  parse var args '"' where '"' tempdir
  tempdir = strip(tempdir)
end
else
  parse var args where tempdir


KeepCommandLineWindow = 1
WaitForUnzip  = 1
UnzipInCommandLineWindow = 1	/* KeepCommandLineWindow must be 1 for this */
UsePKZip = 0

foundInfoZip = ''
foundInfoUnZip = ''
foundPKZip = ''
foundPKUnZip = ''

  Say "Welcome to Workplace UnZip!"'0a'x

  Say "WUZ is a series of REXX functions to give you access to archive"
  Say "files (including .ARC, .ARJ, .LZH, .TAR, .Z, .ZIP and .ZOO) from"
  Say "the Workplace Shell or the command line."'0a'x

top:

ucnt = 1
final = ''
AutoMatic = 1

if where = '' then do
  where = ''
  path = Value('PATH',,'OS2ENVIRONMENT')

  i = 1
  found = 0
  dir. = ''
  do forever
    parse var path dir.i ';' path
    if Right(dir.i,1) \= '\' then
      dir.i = dir.i'\'
    if SubStr(dir.i,2,1) = ':' then do
      if foundInfoUnZip == '' then
        foundInfoUnZip = Stream( dir.i'unzip.exe', 'c', 'query exists' )
      if foundInfoZip == '' then
        foundInfoZip = Stream( dir.i'zip.exe', 'c', 'query exists' )
      if foundPKUnZip == '' then
        foundPKUnZip = Stream( dir.i'pkunzip.exe', 'c', 'query exists' )
      if foundPKZip == '' then
        foundPKZip = Stream( dir.i'pkzip.exe', 'c', 'query exists' )
      if Stream( dir.i'wuz.cmd', 'C', 'QUERY EXISTS' ) \= '' then do
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
          var = "KeepCommandLineWindow"
          if Abbrev(hold,var' = 0') | Abbrev(hold,var' = 1') then
            interpret var "= SubStr(hold,Length(var)+4,1)"

          hold = LineIn(dir.found'wuz.cmd')
          var = "WaitForUnzip"
          if Abbrev(hold,var' = 0') | Abbrev(hold,var' = 1') then
            interpret var "= SubStr(hold,Length(var)+4,1)"

          hold = LineIn(dir.found'wuz.cmd')
          var = "UnzipInCommandLineWindow"
          if Abbrev(hold,var' = 0') | Abbrev(hold,var' = 1') then
            interpret var "= SubStr(hold,Length(var)+4,1)"

          hold = LineIn(dir.found'wuz.cmd')
          var = "UsePKZip"
          if Abbrev(hold,var' = 0') | Abbrev(hold,var' = 1') then
            interpret var "= SubStr(hold,Length(var)+4,1)"
        end
	Call LineOut dir.found'wuz.cmd'
	if Stream( dir.found'Post-WUZ.cmd', 'C', 'QUERY EXISTS' ) \= '' then do
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
    Say "1) Copy over the current version, keep current settings"
    Say "2) Copy over the current version, change settings"
    Say "3) Remove the current copy of WUZ and install somewhere else"
    Say "4) Remove every last trace of WUZ from your computer"'0a'x
    Call CharOut ,"What would you like to do: "
    parse upper pull ans
    if ans = 0 | ans = '' then exit(0)
    if ans < 0 | ans > 4 then do
      say '0a'x"Please answer either 0, 1, 2, 3, 4 or <RETURN>"
      iterate
    end

    if ans>=3 then do
      say "Erasing:	wuz.cmd"
      say "		wuz.ico"
      say "		post-wuz.cmd"
      say "		zipstrip.cmd"
      say "		zip-dir.cmd"
      say "		zip-dir.ico"
      say "		fldzip.ico"
      say "		fldunzip.ico"
      say "		od.cmd"
      say "		open-dir.cmd"
      say "		wpset.cmd"
      say "		kd.cmd"
      say "		kill-dir.cmd from" dir.found'0a'x
      Call SysFileDelete dir.found'wuz.cmd'
      Call SysFileDelete dir.found'wuz.ico'
      Call SysFileDelete dir.found'post-wuz.cmd'
      Call SysFileDelete dir.found'zipstrip.cmd'
      Call SysFileDelete dir.found'zip-dir.cmd'
      Call SysFileDelete dir.found'zip-dir.ico'
      Call SysFileDelete dir.found'fldzip.ico'
      Call SysFileDelete dir.found'fldunzip.ico'
      Call SysFileDelete dir.found'od.cmd'
      Call SysFileDelete dir.found'open-dir.cmd'
      Call SysFileDelete dir.found'wpset.cmd'
      Call SysFileDelete dir.found'kill-dir.cmd'
      Call SysFileDelete dir.found'kd.cmd'
      Call SysDestroyObject '<WorkplaceUnZip>'
      Call SysDestroyObject '<ZipDir>'
      if ans = 4 then exit(1)
    end      
    if ans=1 then do
      where = dir.found
      AutoMatic = 1
    end
    if ans=2 then do
      where = dir.found
      AutoMatic = 0
    end
    leave
  end
  else
    Say "Apparently, this is the first time you are installing WPS UnZip."
  do while ans \=1 & ans \= 2
    Say "There are two ways to install:"'0a'x
    Say "1) Don't ask me any questions. Just do it!"
    Say "2) Hey, I want to know what's going on.  Ask me everything."
    Say "X) Actually, maybe I won't install right now."'0a'x
    Call CharOut ,"Which would you like to do: "
    parse upper pull ans
    if ans = 'X' | ans = '' then exit(0)
    if ans < 1 | ans > 2 then do
      say '0a'x"Please answer either 0, 1, 2, 3 or <RETURN>"
      iterate
    end
    if ans = 1 then
      AutoMatic = 1
    else
      AutoMatic = 0
    Call CharOut ,'0a'x
  end

  if where = '' then do
    i = i-1
    root=FileSpec('Drive',Value('SYSTEM_INI',,'OS2ENVIRONMENT'))
    if AutoMatic = 1 then do
      where = root'\OS2'
      Say "WUZ will be installed in" where
    end
    else do
      Say "WUZ must be installed in a directory on your PATH:"'0a'x
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
  if tempdir = '' then
    tempdir = '\'
  else
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
  if temp = '' then do
    free = 0
    drv = 'C:'
    map = SysDriveMap('C:','LOCAL')
    do i = 1 to words(map)
      temp = SysDriveInfo(Word(map,i))
      if Word(temp,2) > free then do
        free = Word(temp,2)
        drv = Word(map,i)
      end
    end
    temp = Left(drv,2)'\Temp'
  end
  Say "WUZ will create a temporary directory for each archive it extracts."
  if AutoMatic = 1 then
    Say "Let's try putting the them in" temp'.'
  else do
    Call CharOut ,"Where should it create them? (<RETURN> for" temp") "
    parse pull tempdir
    if tempdir\='' then
      temp = tempdir
    do while Right(tempdir,2) == '\\' then
      tempdir = Left(tempdir,Length(tempdir)-1)
    end
  end

  call Directory hold
  tempdir = directory(temp)
  if tempdir = '\' then do
    if AutoMatic = 1 then
      ans = 'Y'
    else do
      Call CharOut ,temp "does not exist.  Should I create it? "
      parse upper pull ans
    end
    if Left(ans,1) = 'Y' then do
      if SysMkDir(temp) then do
        say "Can't create" temp
        if AutoMatic = 1 then do
          say "Using" Left(temp,3) "instead."
          tempdir = Left(temp,3)
        end
      end
      else
        tempdir = temp
    end
  end
end
if Right(tempdir,1) \= '\' then tempdir = tempdir'\'

if AutoMatic = 0 then do
  say ""
  if foundInfoUnZip \= '' then
    say 'Found InfoUnZip:' foundInfoUnZip
  if foundInfoZip \= '' then
    say 'Found InfoZip  :' foundInfoZip
  if foundPKUnZip \= '' then
    say 'Found PKUnZip  :' foundPKUnZip
  if foundPKZip \= '' then
    say 'Found PKZip    :' foundPKZip
end
if foundPKZip \= '' then do
  foundPKZip = Stream( foundPKZip, 'c', 'query datetime' )
  parse var foundPKZip . '-' . '-' foundPKZip ' ' .
end
if foundPKUnZip \= '' then do
  foundPKUnZip = Stream( foundPKUnZip, 'c', 'query datetime' )
  parse var foundPKUnZip . '-' . '-' foundPKUnZip ' ' .
end
select
  when foundPKUnZip = '' & foundInfoUnZip = '' then
    UsePKZip = 0
  when foundPKUnZip = '' & foundInfoUnZip \= '' then
    UsePKZip = 0
  when foundPKUnZip \= '' & foundInfoUnZip = '' then
    UsePKZip = 1
  when foundPKUnZip < 93 & foundInfoUnZip \= '' then do
    if AutoMatic = 0 then
      say '0a'x"PKUnZip is old.  Using Info-UnZip."
    UsePKZip = 0
  end
  when foundPKZip = '' & foundInfoZip \= '' then do
    if AutoMatic = 0 then
      say '0a'x"Using Info-Zip/UnZip because PKZip could not be found."
    UsePKZip = 0
  end
  when foundPKZip > 92 & foundPKUnZip > 92 & foundInfoZip = '' then do
    if AutoMatic = 0 then
      say '0a'x"Using PKZip/UnZip because Info-Zip could not be found."
    UsePKZip = 1
  end
  when (foundPKZip > 92 & foundPKUnZip > 92 & foundInfoZip \= '') | (foundPKZip == '' & foundInfoZip == '') then
    if AutoMatic = 0 then do
      Say '0a'x"You seem to have both PKUnZip and Info-UnZip on your system."
      Say "Info-UnZip is probably an OS/2 application and PKUnZip probably is not."
      Say "Therefore, you may have better results with Info-UnZip."
      if UsePKZip = 0 then
        Call CharOut ,"Which would you prefer ('P' for PK, 'I' or <RETURN> for Info) "
      else
        Call CharOut ,"Which would you prefer ('I' for Info, 'P' or <RETURN> for PK) "
      parse upper pull aack
      if Abbrev(aack,'P') then UsePKZip = 1
      else if Abbrev(aack,'I') then UsePKZip = 0
    end
  otherwise nop
end

if AutoMatic = 0 then do
  Say '0a'x"If you are used to DOS, you may want a command line."
  Say "If you are a former MacIntosh user or a WPS purist, you probably don't."
  if KeepCommandLineWindow = 1 then
    ans = "Yes"
  else
    ans = "No"
  Call CharOut ,"Would you like to keep a command line? (<RETURN> for" ans") "
  parse upper pull keepAnswer
  if keepAnswer = '' then keepAnswer = ans
  if Left(keepAnswer,1) = 'Y' then do
    KeepCommandLineWindow = 1
    UnzipInCommandLineWindow = 1
  end
  else if Left(keepAnswer,1) = 'N' then do
    KeepCommandLineWindow = 0
    UnzipInCommandLineWindow = 0
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
  say "		od.cmd"
  say "		open-dir.cmd"
  say "		wpset.cmd"
  say "		kd.cmd"
  say "		kill-dir.cmd to "to

  Drive = Left(tempdir,2)
  Call SysFileDelete 'wuz.cmd'
  Call LineOut 'WUZ.cmd',linein(from'wuz.tpl')
  Call LineOut 'wuz.cmd',linein(from'wuz.tpl')
  Call LineOut 'wuz.cmd',linein(from'wuz.tpl')
  Call LineIn from'wuz.tpl'
  Call LineIn from'wuz.tpl'
  Call LineIn from'wuz.tpl'
  Call LineIn from'wuz.tpl'
  Call LineIn from'wuz.tpl'
  Call LineIn from'wuz.tpl'
  Call LineIn from'wuz.tpl'
  Call LineIn from'wuz.tpl'
  Call LineOut 'wuz.cmd',"Drive    = '"Drive"'"
  Call LineOut 'wuz.cmd',"DestPath = '"tempdir"'"
  Call LineOut 'wuz.cmd',"IconPath = '"to"'"
  Call LineOut 'wuz.cmd',""
  Call LineOut 'wuz.cmd',"KeepCommandLineWindow =" KeepCommandLineWindow
  Call LineOut 'wuz.cmd',"WaitForUnzip =" WaitForUnzip
  Call LineOut 'wuz.cmd',"UnzipInCommandLineWindow =" UnzipInCommandLineWindow"	/* KeepCommandLineWindow must be 1 for this */"
  Call LineOut 'wuz.cmd',"UsePKZip =" UsePKZip
  do while lines(from'wuz.tpl') > 0
    Call LineOut 'wuz.cmd',LineIn(from'wuz.tpl')
  end
  Call LineOut 'wuz.cmd'
  Call LineOut from'wuz.tpl'
  '@copy' from'wuz.ico WUZ.ico > nul'

  if ucnt > 2 | final \= '' then do
    Call SysFileDelete 'post-wuz.cmd'
    Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.tpl')
    Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.tpl')
    Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.tpl')
    Say ''
    if final \= '' then do
      Say "Preserving FinalCommand from" where"Post-WUZ.CMD"
      Say final
      Call LineIn from'Post-wuz.tpl'
      Call LineOut 'Post-WUZ.cmd',final
    end
    else
      Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.tpl')
    if ucnt > 2 then do
      Say "Preserving user lines from" where"Post-WUZ.CMD"
      Call LineIn from'Post-wuz.tpl'
      Call LineIn from'Post-wuz.tpl'
      do i=1 to ucnt
        Call LineOut 'Post-WUZ.cmd',user.i
      end
    end
    else do
      Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.tpl')
      Call LineOut 'Post-WUZ.cmd',linein(from'Post-wuz.tpl')
    end
    do while lines(from'Post-WUZ.tpl') > 0
      Call LineOut 'Post-WUZ.cmd',LineIn(from'post-wuz.tpl')
    end
    Call LineOut 'Post-wuz.cmd'
    Call LineOut 'Post-wuz.tpl'
  end
  else
    '@copy' from'post-wuz.tpl Post-WUZ.Cmd > nul'

  Call SysFileDelete 'ZipStrip.cmd'
  Call LineOut 'ZipStrip.cmd',linein(from'ZipStrip.tpl')
  Call LineOut 'ZipStrip.cmd',linein(from'ZipStrip.tpl')
  Call LineOut 'ZipStrip.cmd',linein(from'ZipStrip.tpl')
  Call LineIn from'ZipStrip.tpl'
  Call LineOut 'ZipStrip.cmd',"UsePKZip =" UsePKZip
  do while lines(from'ZipStrip.tpl') > 0
    Call LineOut 'ZipStrip.cmd',LineIn(from'ZipStrip.tpl')
  end
  Call LineOut 'ZipStrip.cmd'
  Call LineOut from'ZipStrip.tpl'
  Call SysFileDelete 'zip-dir.cmd'
  Call LineOut 'Zip-Dir.cmd',linein(from'zip-dir.tpl')
  Call LineOut 'zip-dir.cmd',linein(from'zip-dir.tpl')
  Call LineOut 'zip-dir.cmd',linein(from'zip-dir.tpl')
  Call LineIn from'zip-dir.tpl'
  Call LineIn from'zip-dir.tpl'
  Call LineOut 'zip-dir.cmd',"IconPath = '"to"'"
  Call LineOut 'zip-dir.cmd',"UsePKZip =" UsePKZip
  do while lines(from'zip-dir.tpl') > 0
    Call LineOut 'zip-dir.cmd',LineIn(from'zip-dir.tpl')
  end
  Call LineOut 'zip-dir.cmd'
  Call LineOut from'zip-dir.tpl'
  '@copy' from'zip-dir.ico > nul'
  '@copy' from'fldzip.ico > nul'
  '@copy' from'fldunzip.ico > nul'
  '@copy' from'open-dir.cmd > nul'
  '@copy' from'open-dir.cmd od.cmd > nul'
  '@copy' from'wpset.cmd > nul'
  '@copy' from'kill-dir.cmd > nul'
  '@copy' from'kill-dir.cmd kd.cmd > nul'
  Call Directory from
end
else
  to = directory()

Call SysDestroyObject '<WorkplaceUnZip>'
Call SysCreateObject "WPProgram", "WPS Unzip", "<WP_DESKTOP>",,
	"OBJECTID=<WorkplaceUnZip>;PROGTYPE=WINDOWABLEVIO;EXENAME="to"wuz.cmd;ASSOCFILTER=*.arc,*.arj,*.lzh,*.tar,*.z,*.zif,*.zip,*.zoo;SET=WUZMIN="keepAnswer
Call SysDestroyObject '<ZipDir>'
here = directory()
Call SysCreateObject "WPProgram", "Zip Directory", "<WP_DESKTOP>",,
	"OBJECTID=<ZipDir>;PROGTYPE=WINDOWABLEVIO;EXENAME="to"zip-dir.cmd"

Say '0a'x"Workplace UnZip v1.1 has been successfully installed."
Say "Try it out and see if you like it.  If you do, I would appreciate"
Say "a small cash donation of $20 or at least a note telling me what"
Say "you think.  My Usenet address is scott.maxwell@channel1.com."
Say "Any money should go to:"
Say "                         Patricia Maxwell"
Say "                         1587 E. Modesto Ave."
Say "                         Camarillo, CA 93010 U.S.A."'0a'x

Say "You may also rerun Install.Cmd to uninstall."
Say "For more information about Workplace UnZip, read ReadMe.WUZ and WUZ.Doc."
exit(0)

Directory: procedure
  arg Name
  Name = Strip(Name,,'"')
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)
  n = 'DIRECTORY'(Name)
  if Right(n,1) \= '\' then
    n = n'\'
return n
